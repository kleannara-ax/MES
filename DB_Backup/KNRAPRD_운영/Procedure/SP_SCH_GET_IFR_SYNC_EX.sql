--------------------------------------------------------
--  DDL for Procedure SP_SCH_GET_IFR_SYNC_EX
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SCH_GET_IFR_SYNC_EX" 
AS                                                                                     
/*==============================================================================
 * PROGRAM ID    : 마이그레이션
 * PROGRAM NAME  : 생산오더의 데이타 수신후 누락된부분 각 I/F테이블과 동기화 한다.
 * VERSION       : 1.0.0
 * DESCRIPTION   : 생산오더 예외->작업지시 동기화
 *                 
 * AUTHOR NAME   : 강현주
 * CREATE DATE   : 2022/10/05
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/10/05  1.0.0   강현주         Initial Version 
 *==============================================================================
 * 관련 테이블
 * - [XXX] : (.I..)데이타 생성  
--------------------------------------------------------------------------------------------------------------------------------   
--화장지 합지 : AA
--화장지 가공 : RA
--생리대     : RB
--기저귀     : RC
--
--점보롤 : JA
--밀롤 : MA
--재단 : CA
--포장 : PA
--예외생산: EX    
 *=============================================================================*/
 
  o_msg_code         VARCHAR2(1000)   := '';
  o_msg_MSG          VARCHAR2(4000)   := '';
   
 
  E_EXCEPTION_USER  EXCEPTION;                        -- 사용자 에러 처리용 변수선언 영역 
  
  --오더별 마지막 IF_MES_KEY를 잡아와서 처리 한다.
  CURSOR  CUR_DATA IS 
    SELECT INFO.*
    FROM (
          SELECT K.AUFNR,(SELECT MAX(IF_MES_KEY) FROM TB_IFR022 WHERE AUFNR = K.AUFNR) IF_MES_KEY  
          FROM (SELECT DISTINCT AUFNR 
                FROM TB_IFR022) K      
          WHERE K.AUFNR NOT IN(SELECT ORDER_NO FROM TB_SCH019 WHERE ORDER_NO = K.AUFNR)
         ) DATA
        ,TB_IFR022 INFO
    WHERE  DATA.AUFNR       = INFO.AUFNR
    AND    DATA.IF_MES_KEY  = INFO.IF_MES_KEY 
    AND    INFO.IF_STATUS IN('N','E')
    ORDER BY IF_IFR_NO;
 

  
  
  V_CNT           NUMBER          := 0;      -- 카운트(작업지시존재여부) 
  V_BOM_CNT       NUMBER          := 0;      -- 카운트(작업지시BOM존재여부)

  V_WO_DT         VARCHAR2(50)    := '';      -- 지시일자(작업지시생성하기 위해서..)  

  V_WO_NO         VARCHAR2(50)    := '';      -- 작업지시번호 (작업지시BOM생성을 위해서..)  
  V_WO_SEQ        NUMBER          := 0;      --작업지시순번 (작업지시BOM생성을 위해서..)  
  V_WERKS         VARCHAR2(50)    := '';      -- 플랜트 (작업지시BOM생성을 위해서..) 

  V_DLFL          VARCHAR2(50)    := '';      -- 삭제FLAG   
         
  V_DLFL_CNT      NUMBER          := 0;      -- 생산오더 모두 삭제 되었으면 작업지시 삭제 하기 위해서 사용함. 
  
  i_IF_IFR_NO     NUMBER          := 0;      -- MES Interface Sequence(수신번호)   
  i_AUFNR         VARCHAR2(50)    := '';  

BEGIN
  
  FOR cur_row in CUR_DATA LOOP
  BEGIN
    i_IF_IFR_NO := cur_row.IF_IFR_NO;
    i_AUFNR     := cur_row.AUFNR;
  
    SELECT NVL(DLFL,' ') INTO V_DLFL
    FROM TB_IFR022
    WHERE AUFNR = i_AUFNR
    AND IF_IFR_NO = i_IF_IFR_NO;    

    IF V_DLFL = 'X' THEN
      UPDATE TB_SCH010
      SET DLFL = V_DLFL
      WHERE AUFNR =  i_AUFNR;

      UPDATE TB_SCH019
      SET USE_YN = 'N'
      WHERE ORDER_NO =  i_AUFNR;             

      o_msg_MSG  :=  'TB_IFR022, 생산오더-예외 삭제 수신되었습니다.1' || ',' || SQLERRM ;

      UPDATE  TB_IFR022
      SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
            , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
            , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
      WHERE  AUFNR     =  i_AUFNR
      AND    IF_IFR_NO =  i_IF_IFR_NO           
      ;

      o_msg_MSG  :=  'TB_IFR022, 생산오더-예외 삭제 수신되었습니다.2' || ',' || SQLERRM ;
      o_msg_code := '0' ;
      RETURN;    
    END IF;
    
    
  -----------------------------------------------------------------------------------------------------------------------------
  --생산오더
  -----------------------------------------------------------------------------------------------------------------------------
    SELECT COUNT(1) INTO V_CNT FROM TB_SCH010 WHERE AUFNR = i_AUFNR; 
    
    IF V_CNT > 0 THEN    
      UPDATE TB_SCH010
      SET(        
           WERKS		   														--WERKS	,	플랜트		                	                   
          ,GSTRS		       	                      --GSTRS	,	시작일자		          
          ,AUART		       	                      --AUART	,	오더유형		          
          ,AUARTXT		     		                    --AUARTXT	,	오더유형 텍스트	      
          ,MATNR		       	                      --MATNR	,	제품코드		          
          ,GAMNG		       	                      --GAMNG	,	생산지시량		          
          ,GMEIN		       	                      --GMEIN	,	생산지시단위		        
          ,ARBPL		       	                      --ARBPL	,	Work Center		    
          ,VERID		       	                      --VERID	,	생산버전		          
          ,STLNR		       	                      --STLNR	,	BOM Num		        
          ,STLAL		       	                      --STLAL	,	대체Bom		          
          ,BMENG		       	                      --BMENG	,	모품목기준수량		        
          ,BMEIN		       	                      --BMEIN	,	모품목기준수량 단위        
          ,FTRMI		       	                      --FTRMI	,	릴리즈일자		          
          ,VBELN		       	                      --VBELN	,	판매문서번호		        
          ,POSNR		       	                      --POSNR	,	판매문서Item번호	      
          ,PCODE        	       		              --지종                        
          ,WEIGHT                                 --평량                        
          ,WLEN                                   --가로길                       
          ,VLEN                                   --세로길                       
          ,ZZATT1                                 --팔레트당연수                    
          ,ZZATT2                                 --속당매수                      
          ,PACKTYPE                               --포장타입                      
          ,MCNT                                   --매                         
          ,SCNT                                   --속                         
          ,KUNNR                                  --판매처 코드                    
          ,NAME1                                  --판매처                       
                                                                              
          ,DLFL		         	                      --DLFL	,	오더삭제지시자		          
          ,UPDDATE		                            --EDIT_DATE	,	수정일자		         
          ,UPDID		                              --EDITOR	,	수정자                        
      )=(SELECT                         										
           WERKS																	--WERKS	,	플랜트		            	         
          ,GSTRS		                              --GSTRS	,	시작일자		          
          ,AUART		                              --AUART	,	오더유형		          
          ,AUARTXT		                            --AUARTXT	,	오더유형 텍스트	      
          ,MATNR		                              --MATNR	,	제품코드		          
          ,GAMNG		                              --GAMNG	,	생산지시량		          
          ,GMEIN		                              --GMEIN	,	생산지시단위		        
          ,ARBPL		                              --ARBPL	,	Work Center		    
          ,VERID		                              --VERID	,	생산버전		          
          ,STLNR		                              --STLNR	,	BOM Num		        
          ,STLAL		                              --STLAL	,	대체Bom		          
          ,BMENG		                              --BMENG	,	모품목기준수량		        
          ,BMEIN		                              --BMEIN	,	모품목기준수량 단위        
          ,FTRMI		                              --FTRMI	,	릴리즈일자		          
          ,VBELN		                              --VBELN	,	판매문서번호		        
          ,POSNR		                              --POSNR	,	판매문서Item번호	      
          ,PCODE         		                      --지종                        
          ,WEIGHT                                 --평량                        
          ,WLEN                                   --가로길                       
          ,VLEN                                   --세로길                       
          ,ZZATT1                                 --팔레트당연수                    
          ,ZZATT2                                 --속당매수                      
          ,PACKTYPE                               --포장타입                      
          ,MCNT                                   --매                         
          ,SCNT                                   --속                         
          ,KUNNR                                  --판매처 코드                    
          ,NAME1                                  --판매처                       
                                                                              
          ,DLFL		                                --DLFL	,	오더삭제지시자		        
          ,sysdate		                            --EDIT_DATE	,	수정일자		      
          ,'SP_SCH_SYNC_EX'		                      --EDITOR	,	수정자                                                                
         FROM TB_IFR022 
         WHERE  IF_IFR_NO = i_IF_IFR_NO      
      )
      WHERE  AUFNR   = i_AUFNR;       
    ELSE    
      INSERT INTO TB_SCH010(  
           AUFNR				                          --AUFNR	,	오더번호		                              
          ,WERKS				                          --WERKS	,	플랜트		                                
          ,GSTRS				                          --GSTRS	,	시작일자		                              
          ,AUART				                          --AUART	,	오더유형		                              
          ,AUARTXT				                        --AUARTXT	,	오더유형 텍스트		                           
          ,MATNR				                          --MATNR	,	제품코드		                              
          ,GAMNG				                          --GAMNG	,	생산지시량		                              
          ,GMEIN				                          --GMEIN	,	생산지시단위		                             
          ,ARBPL				                          --ARBPL	,	Work Center		                      
          ,VERID				                          --VERID	,	생산버전		                             
          ,STLNR				                          --STLNR	,	BOM Num		                          
          ,STLAL				                          --STLAL	,	대체Bom		                             
          ,BMENG				                          --BMENG	,	모품목기준수량		                             
          ,BMEIN				                          --BMEIN	,	모품목기준수량 단위	                            
          ,FTRMI				                          --FTRMI	,	릴리즈일자		                               
          ,VBELN				                          --VBELN	,	판매문서번호		                             
          ,POSNR				                          --POSNR	,	판매문서Item번호		                         
          ,PCODE       														--지종                          
          ,WEIGHT                                 --평량                          
          ,WLEN                                   --가로길                         
          ,VLEN                                   --세로길                         
          ,ZZATT1                                 --팔레트당연수                      
          ,ZZATT2                                 --속당매수                        
          ,PACKTYPE                               --포장타입                        
          ,MCNT                                   --매                           
          ,SCNT                                   --속                           
          ,KUNNR                                  --판매처 코드                      
          ,NAME1                                  --판매처                         
                                                                                
          ,DLFL				                            --DLFL	,	오더삭제지시자		                               
          ,REGDATE				                        --MAKE_DATE	,	등록일자		                            
          ,REGID				                          --MAKER	,	등록자		                                
          ,UPDDATE				                        --EDIT_DATE	,	수정일자		                            
          ,UPDID				                          --EDITOR	,	수정자			                   		                  
      )                                           					                              
      SELECT                                      					                              
           AUFNR				                          --AUFNR	,	오더번호		                                          
          ,WERKS				                          --WERKS	,	플랜트		                                            
          ,GSTRS				                          --GSTRS	,	시작일자		                                           
          ,AUART				                          --AUART	,	오더유형		                                           
          ,AUARTXT				                        --AUARTXT	,	오더유형 텍스트		                                        
          ,MATNR				                          --MATNR	,	제품코드		                                           
          ,GAMNG				                          --GAMNG	,	생산지시량		                                           
          ,GMEIN				                          --GMEIN	,	생산지시단위		                                          
          ,ARBPL				                          --ARBPL	,	Work Center		                                    
          ,VERID				                          --VERID	,	생산버전		                                           
          ,STLNR				                          --STLNR	,	BOM Num		                                        
          ,STLAL				                          --STLAL	,	대체Bom		                                           
          ,BMENG				                          --BMENG	,	모품목기준수량		                                           
          ,BMEIN				                          --BMEIN	,	모품목기준수량 단위		                                        
          ,FTRMI				                          --FTRMI	,	릴리즈일자		                                            
          ,VBELN				                          --VBELN	,	판매문서번호		                                          
          ,POSNR				                          --POSNR	,	판매문서Item번호		                                      
          ,PCODE       														--지종                                       
          ,WEIGHT                                 --평량                                       
          ,WLEN                                   --가로길                                      
          ,VLEN                                   --세로길                                      
          ,ZZATT1                                 --팔레트당연수                                   
          ,ZZATT2                                 --속당매수                                     
          ,PACKTYPE                               --포장타입                                     
          ,MCNT                                   --매                                        
          ,SCNT                                   --속                                        
          ,KUNNR                                  --판매처 코드                                   
          ,NAME1                                  --판매처                                      
                                                     
          ,DLFL				                            --DLFL	,	오더삭제지시자		                                            
          ,sysdate				                        --MAKE_DATE	,	등록일자		                                                
          ,'SP_SCH_SYNC_EX'				                  --MAKER	,	등록자		                                                       
          ,null				                            --EDIT_DATE	,	수정일자		                                             
          ,null				                            --EDITOR	,	수정자	                                                             
      FROM  TB_IFR022
      WHERE  IF_IFR_NO = i_IF_IFR_NO;                      
    END IF;     
    
    


    --========================================
    --KHJ추가 2022-05-02:작업지시-예외(리커팅,리패킹,수재단)
    --========================================
    ------------------------------------------
    --작업지시가 존재하지 않으면 작업지시 번호 생성
    SELECT COUNT(ORDER_NO) INTO V_CNT
    FROM TB_SCH019
    WHERE ORDER_NO = i_AUFNR;

    IF V_CNT = 0 THEN
      SELECT GSTRS INTO V_WO_DT
      FROM TB_IFR022
      WHERE IF_IFR_NO  =  i_IF_IFR_NO;

      SP_GET_DOC_SEQ('WOEX',V_WO_DT,V_WO_NO); 
    END IF;
    ------------------------------------------
    IF V_CNT > 0 THEN    
      UPDATE TB_SCH019
      SET(        
           WERKS       														--플랜트코드                    
          ,PRD_REQ_DT                             --생산요청일자                   
          ,PCODE				                          --지종                       
          ,BS_WGT                                 --평량                       
          ,WLEN                                   --가로길                      
          ,VLEN                                   --세로길                      
          ,PLT_PER_CNT                            --팔레트당연수                   
          ,IN_PER_CNT                             --속당매수                     
          ,PACKTYPE                               --포장타입                     
          ,MCNT                                   --매                        
          ,SCNT                                   --속                        
          ,KUNNR                                  --판매처 코드                   
          ,KUNNRT                                 --판매처                      
                                                                             
          ,ORDER_DIV                              --오더유형                     
          ,AUARTXT                                --오더유형 텍스트                 
          ,MATNR                                  --제품코드                     
          ,UNIT                                   --생산지시단위                   
          ,WRK_CD                                 --Work Center              
          ,VERID                                  --생산버전                     
          ,STLNR                                  --BOM Num                  
          ,STLAL                                  --대체Bom                    
          ,BMENG                                  --모품목기준수량                  
          ,BMEIN                                  --모품목기준수량 단위               
          ,FTRMI                                  --릴리즈일자                    
          ,VBELN                                  --판매문서번호	                 
          ,POSNR                                  --판매문서Item번호	             
          ,WRK_ORDR_QTY                           --생산지시량								     
          ,GSTRS   		                            --생산요청일자     	             
          ,GAMNG                                  --생산지시량                    
          ,GMEIN                                  --생산지시단위                   
          ,ARBPL                                  --Work Center              
          ,DLFL                                   --오더삭제지시자                  
                                                                             
          ,UPDDATE                                --수정일시                     
          ,UPDID                                  --수정자ID                    
          ,USE_YN                                 --사용여부(Y:사용 N:미사용)                              
      )=(SELECT                         										
           WERKS                          				--플랜트코드                    
          ,GSTRS                                  --생산요청일자                   
          ,PCODE 												          --지종                       
          ,WEIGHT                                 --평량                       
          ,WLEN                                   --가로길                      
          ,VLEN                                   --세로길                      
          ,ZZATT1                                 --팔레트당연수                   
          ,ZZATT2                                 --속당매수                     
          ,PACKTYPE                               --포장타입                     
          ,MCNT                                   --매                        
          ,SCNT                                   --속                        
          ,KUNNR                                  --판매처 코드                   
          ,NAME1                                  --판매처                      
                                                                             
          ,AUART                                  --오더유형                     
          ,AUARTXT                                --오더유형 텍스트                 
          ,MATNR                                  --제품코드                     
          ,GMEIN                                  --생산지시단위                   
          ,ARBPL                                  --Work Center              
          ,VERID                                  --생산버전                     
          ,STLNR                                  --BOM Num                  
          ,STLAL                                  --대체Bom                    
          ,BMENG                                  --모품목기준수량                  
          ,BMEIN                                  --모품목기준수량 단위               
          ,FTRMI                                  --릴리즈일자                    
          ,VBELN                                  --판매문서번호	                 
          ,POSNR                                  --판매문서Item번호	             
          ,GAMNG                                  --생산지시량								     
          ,GSTRS													        --생산요청일자     	             
          ,GAMNG                                  --생산지시량                    
          ,GMEIN                                  --생산지시단위                   
          ,ARBPL                                  --Work Center              
          ,DLFL                                   --오더삭제지시자                  
                                                                             
          ,sysdate                                --수정일시                     
          ,'SP_SCH_SYNC_EX'                          --수정자ID                    
          ,case when DLFL = 'Y' then 'N'            --사용여부(Y:사용 N:미사용)         
                when DLFL = 'N' then 'Y' 
           end                                                                          
         FROM TB_IFR022 
         WHERE  IF_IFR_NO = i_IF_IFR_NO      
      )
      WHERE ORDER_NO = i_AUFNR;      
    ELSE    
      INSERT INTO TB_SCH019(  
           WRK_ORDR_NO                            --작업지시번호-->작업지시 생성자 사용 WO + R                         
          ,WRK_ORDR_SEQNO                         --작업지시순번                                              
          ,WRK_SEQNO                              --작업순서                                                
          ,ORDR_GEN_DT                            --지시생성일자              					                      
                                                                                                        
          ,PRD_REQ_DT                           	--생산요청일자                               	              	                
          ,ORDER_NO                               --오더번호                                                
          ,WERKS                                  --플랜트코드                                               
          ,PCODE							   								  --지종                                                  
          ,BS_WGT                                 --평량                                                  
          ,WLEN                                   --가로길                                                 
          ,VLEN                                   --세로길                                                 
          ,PLT_PER_CNT                            --팔레트당연수                                              
          ,IN_PER_CNT                             --속당매수                                                
          ,PACKTYPE                               --포장타입                                                
          ,MCNT                                   --매                                                   
          ,SCNT                                   --속                                                   
          ,KUNNR                                  --판매처 코드                                              
          ,KUNNRT                                 --판매처 	                                              
          ,MACH_CD                                --설비코드	                                              
                                                                                                        
          ,ORDER_DIV                              --오더유형                                                
          ,AUARTXT                                --오더유형 텍스                                             
          ,MATNR                                  --제품코드                                                
          ,UNIT                                   --생산지시단위                                              
          ,WRK_CD                                 --Work Cente                                          
          ,VERID                                  --생산버전                                                
          ,STLNR                                  --BOM Num                                             
          ,STLAL                                  --대체Bom                                               
          ,BMENG                                  --모품목기준수량                                             
          ,BMEIN                                  --모품목기준수량                                             
          ,FTRMI                                  --릴리즈일자                                               
          ,VBELN                                  --판매문서번호	                                            
          ,POSNR                                  --판매문서Item                                            
          ,WRK_ORDR_QTY                           --생산지시량	 	                                            
          ,GSTRS   						 					          --생산요청일자                                              
          ,GAMNG                                  --생산지시량                                               
          ,GMEIN                                  --생산지시단위                                              
          ,ARBPL                                  --Work Cente                                          
          ,DLFL                                   --오더삭제지시자                                             
                                                                                                                                                                                                                
          ,COMP_YN                                --완료여부                                                
          ,REGDATE                                --등록일시                                                
          ,REGID                                  --등록자ID                                               
          ,UPDDATE                                --수정일시                                                
          ,UPDID                                  --수정자ID                                               
          ,USE_YN                                 --사용여부(Y:사용 N:미사용) 
      )                                           					                              
      SELECT                                      					                              
           V_WO_NO																					--작업지시번호                           
          ,1                                                --작업지시순번                           
          ,SUBSTR(V_WO_NO,-4)                               --작업순서(작업지시번호,-4)                      
          ,TO_CHAR(sysdate,'YYYYMMDD')                      --지시생성일자   						             	
                                                                                         
          ,GSTRS                                            --생산요청일자                                               							                                                                       
          ,AUFNR                                            --오더번호                           
          ,WERKS                                            --플랜트코드                           
          ,PCODE 																						--지종                           
          ,WEIGHT                          									--평량                           
          ,WLEN                            									--가로길                           
          ,VLEN                            									--세로길                           
          ,ZZATT1                          									--팔레트당연수                           
          ,ZZATT2                          									--속당매수                           
          ,PACKTYPE                        									--포장타입                           
          ,MCNT                            									--매                           
          ,SCNT                            									--속                           
          ,KUNNR                           									--판매처 코드                          
          ,NAME1                           									--판매처                           
          ,CASE WHEN WERKS = 'P200' THEN 'TPG01'                                         
                WHEN WERKS = 'P300' THEN 'SPF03'                                         
                WHEN WERKS = 'P500' THEN 'BPI02'                                         
                ELSE ''                                                                      
           END                                     					--설비코드(YSH 2022.09.05)       
                                                                                             
          ,AUART                           									--오더유형                              
          ,AUARTXT                         									--오더유형 텍스트                       
          ,MATNR                           									--제품코드                             
          ,GMEIN                           									--생산지시단위                     
          ,ARBPL                           									--Work Center                    
          ,VERID                           									--생산버전                       
          ,STLNR                           									--BOM Num                      
          ,STLAL                           									--대체Bom                             
          ,BMENG                           									--모품목기준수량                             
          ,BMEIN                           									--모품목기준수량 단위                      
          ,FTRMI                           									--릴리즈일자                            
          ,VBELN                           									--판매문서번호	                         
          ,POSNR                           									--판매문서Item번호	                  
          ,GAMNG                           									--생산지시량										         																																																													
          ,GSTRS																						--생산요청일자     	                    
          ,GAMNG                           									--생산지시량                            
          ,GMEIN                           									--생산지시단위                     
          ,ARBPL                           									--Work Center                     
          ,DLFL                            									--오더삭제지시자								     
                                                                                             
          ,'N'                                              --완료여부                           
          ,sysdate                                          --등록일시                          
          ,'SP_SCH_SYNC_EX'                                 --등록자ID                       
          ,null                                             --수정일시                          
          ,null                                             --수정자ID                      
          ,case when DLFL = 'X' then 'N'								                                 
                else 'Y'							                                                            
           end                                              --사용여부(Y:사용 N:미사용)	         	                                  
      FROM  TB_IFR022
      WHERE  IF_IFR_NO = i_IF_IFR_NO;                      
    END IF;  


    --작업지시 생성되면 작업지시BOM을 구성한다.     
    --작업지시정보 추출
    SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, WERKS INTO V_WO_NO,V_WO_SEQ,V_WERKS
    FROM TB_SCH019
    WHERE ORDER_NO = i_AUFNR;

    SELECT COUNT(ORDER_NO) INTO V_BOM_CNT 
    FROM TB_SCH020 
    WHERE WRK_ORDR_NO = V_WO_NO
    AND WRK_ORDR_SEQNO = V_WO_SEQ; 

    --작업지시BOM이 존재하지 않으면 생산BOM->작업지시BOM을 생성 한다.
    IF V_BOM_CNT = 0 THEN 
      INSERT INTO TB_SCH020 
      (      ORDER_NO                  		--오더번호        
            ,ORDER_ITM_NO                 --오더Item번호    
            ,MATNR                        --자품목자재       
            ,ORDER_BOM_QTY                --오더BOM 수량    
            ,UNIT                         --오더BOM 수량단위  
            ,LOT_NO                       --LOT NO      
            ,STOR_LOC_CD                  --저장위치        
            ,DLFL                         --삭제 지시자(불출요청)
            ,WERKS                        --플랜트         
            ,WRK_ORDR_NO                  --작업지시번호      
            ,WRK_ORDR_SEQNO               --작업지시번호 순번  

            ,REGDATE                       /*     등록일자                       */
            ,REGID                         /*     등록자                        */
            ,UPDDATE                       /*     수정일자                       */
            ,UPDID                         /*     수정자                        */                   
      )
      SELECT AUFNR				                 /*		오더번호					                */
            ,POSNR				                 /*		오더Item번호					            */
            ,MATNR				                 /*		자품목자재					                */
            ,BDMNG				                 /*		오더BOM 수량					            */
            ,MEINS				                 /*		오더BOM 수량단위					          */
            ,LOT_NO                        --LOT번호            
            ,LGORT                         /*   저장위치                          */
            ,case when XLOEK = 'X' then 'Y'
                  else 'N'                           
             end				                 /*		삭제여부					                */
            ,V_WERKS
            ,V_WO_NO
            ,1  

            ,sysdate
            ,'SP_SCH_SYNC_EX'
            ,null
            ,null
      FROM TB_SCH001          
      WHERE  AUFNR  =  i_AUFNR;       
    END IF;                             

    
    o_msg_MSG  := 'SP_SCH_SYNC_EX==>완료==>'|| i_AUFNR ||'=>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS');

    UPDATE  TB_IFR022
    SET     IF_STATUS   =  'S'                                                    -- I/F상태, N:신규, S:성공, E:오류
          , IF_SET_DATE =  sysdate            
          , IF_ERR_MESS =  o_msg_MSG          
    WHERE IF_IFR_NO =  i_IF_IFR_NO;

    o_msg_MSG  := 'SP_SCH_SYNC_EX==>완료==>'|| i_AUFNR ||'=>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS');
    o_msg_code := '0';
                                    
    DBMS_OUTPUT.PUT_LINE(o_msg_msg);
    SP_IF_MIG_LOG('SP_SCH_SYNC_EX',o_msg_code,o_msg_MSG);
    COMMIT;
      
    EXCEPTION  
      WHEN E_EXCEPTION_USER THEN        
            DBMS_OUTPUT.PUT_LINE(o_msg_MSG);
            ROLLBACK;
       
            UPDATE  TB_IFR022
            SET     IF_STATUS   =  'E'  
                  , IF_SET_DATE =  sysdate                                      --I/F상태, N:신규, S:성공, E:오류               
                  , IF_ERR_MESS =  o_msg_MSG                                                            
            WHERE IF_IFR_NO =  i_IF_IFR_NO; 
            
            DBMS_OUTPUT.PUT_LINE (o_msg_msg );            
            SP_IF_MIG_LOG('USER:SP_SCH_SYNC_EX',o_msg_code,o_msg_msg);                                        
            COMMIT;                                    
                                      
      WHEN OTHERS THEN
            o_msg_msg  :=  'OTHER:SP_SCH_SYNC_EX에서 오류가 발생 되었습니다=>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS') || ',' || SQLERRM ;
            o_msg_code := '-1' ;
            ROLLBACK;

            UPDATE  TB_IFR022
            SET     IF_STATUS   =  'E'                                            --I/F상태, N:신규, S:성공, E:오류               
                  , IF_ERR_MESS =  o_msg_MSG                                                            
            WHERE IF_IFR_NO =  i_IF_IFR_NO;
            
            DBMS_OUTPUT.PUT_LINE (o_msg_msg );            
            SP_IF_MIG_LOG('SP_SCH_SYNC_EX',o_msg_code,o_msg_msg);                                        
            COMMIT;       
  END;
  END LOOP;

  o_msg_code      := '0' ;
  o_msg_msg       := 'End:SP_SCH_SYNC_EX 종료 되었습니다..=>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS');
  DBMS_OUTPUT.PUT_LINE(o_msg_msg);  
  SP_IF_MIG_LOG('SP_SCH_SYNC_EX',o_msg_code,o_msg_msg);
  COMMIT;                                                                   
                                                                      
       
 EXCEPTION
    WHEN OTHERS THEN
      o_msg_code      := '-1' ;
      o_msg_msg       := 'Error: SP_SCH_SYNC_EX에서 오류가 발생하였습니다.=>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS') || ',' || to_char(SQLCODE) || ',' || SQLERRM ;
      rollback ;

      DBMS_OUTPUT.PUT_LINE(o_msg_msg);      
      SP_IF_MIG_LOG('SP_SCH_SYNC_EX',o_msg_code,o_msg_msg);
      COMMIT;       

END;

/
