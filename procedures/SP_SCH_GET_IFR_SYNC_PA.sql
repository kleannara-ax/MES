
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SCH_GET_IFR_SYNC_PA" 
AS                                                                                     
/*==============================================================================
 * PROGRAM ID    : 마이그레이션
 * PROGRAM NAME  : 생산오더의 데이타 수신후 누락된부분 각 I/F테이블과 동기화 한다.
 * VERSION       : 1.0.0
 * DESCRIPTION   : 생산오더 포장->작업지시 동기화
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
          SELECT K.AUFNR,(SELECT MAX(IF_MES_KEY) FROM TB_IFR021 WHERE AUFNR = K.AUFNR) IF_MES_KEY  
          FROM (SELECT DISTINCT AUFNR 
                FROM TB_IFR021) K      
         ) DATA
        ,TB_IFR021 INFO
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
  i_PACKSEQ       VARCHAR2(50)    := '';     

BEGIN
  
  FOR cur_row in CUR_DATA LOOP
  BEGIN
    i_IF_IFR_NO := cur_row.IF_IFR_NO;
    i_PACKSEQ   := cur_row.PACKSEQ;
    i_AUFNR     := cur_row.AUFNR;
  
    SELECT NVL(DLFL,' ') INTO V_DLFL
    FROM TB_IFR021
    WHERE AUFNR     = i_AUFNR
    AND   PACKSEQ   = i_PACKSEQ
    AND   IF_IFR_NO = i_IF_IFR_NO;    

    IF V_DLFL = 'X' THEN
      UPDATE TB_SCH009
      SET DLFL = V_DLFL
      WHERE AUFNR   =  i_AUFNR
      AND   PACKSEQ =  i_PACKSEQ;


      --포장공정은 작업지시 SUM하는것으로 변경 22-08-18 
      UPDATE TB_SCH018
      SET WRK_ORDR_QTY  = (SELECT SUM(PCNT)  FROM TB_SCH009 WHERE AUFNR      =  i_AUFNR AND DLFL  <> 'X')  --생산지시량(*)
         ,PCNT          = (SELECT SUM(PCNT)   FROM TB_SCH009 WHERE AUFNR     =  i_AUFNR AND DLFL  <> 'X')  --연수(*)  
         ,TOT_WGT       = (SELECT SUM(PGEWEW) FROM TB_SCH009 WHERE AUFNR     =  i_AUFNR AND DLFL  <> 'X')  --총중량(*)  
      WHERE ORDER_NO = i_AUFNR; 
      
      SELECT count(1) INTO V_DLFL_CNT
      FROM TB_SCH009
      WHERE AUFNR   =  i_AUFNR
      AND DLFL <> 'X';       

      --오더번호가 모두 삭제 되면 작업지시도 삭제된것으로 처리 됨.
      IF V_DLFL_CNT = 0 THEN
        UPDATE TB_SCH018
        SET USE_YN = 'N'
        WHERE ORDER_NO =  i_AUFNR;
      END IF;       
      
                  
      o_msg_MSG  := 'SP_SCH_SYNC_PA==>완료==>'|| i_AUFNR ||'=>' || TO_CHAR(i_PACKSEQ) ||'=>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS');      
           
      UPDATE  TB_IFR021
      SET     IF_STATUS   =  'S'                                                    -- I/F상태, N:신규, S:성공, E:오류
            , IF_SET_DATE =  sysdate            
            , IF_ERR_MESS =  o_msg_MSG          
      WHERE AUFNR   =  i_AUFNR
      AND   PACKSEQ =  i_PACKSEQ;

      o_msg_MSG  := 'SP_SCH_SYNC_PA==>완료==>'|| i_AUFNR ||'=>' || TO_CHAR(i_PACKSEQ) ||'=>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS');
      o_msg_code := '0' ;
                                      
      DBMS_OUTPUT.PUT_LINE(o_msg_MSG);
      SP_IF_MIG_LOG('SP_SCH_SYNC_PA','0',o_msg_MSG);
      COMMIT;      
                        
      CONTINUE;    
    END IF;
    
    
    SELECT COUNT(1) INTO V_CNT FROM TB_SCH009 WHERE AUFNR = i_AUFNR AND PACKSEQ = i_PACKSEQ; 
    
       
    IF V_CNT > 0 THEN    
      UPDATE TB_SCH009
      SET(        
          CTPO			    																		--	재단 오더 번호			                 
        ,	WERKS			                    										--	플랜트			                       
        ,	BUDAT			                    										--	시작일자			                     
        ,	AUART			                    										--	오더유형			                     
        ,	AUARTXT			                  										--	오더유형 텍스트			                 
        ,	MACHINE			                  										--	FROM 생산호기			                 
        ,	MACHINETXT		                										--	FROM 생산 호기명			               
        ,	TOMACHINE		                  										--	TO 생산호기			                   
        ,	TOMACHINETXT                  										--	TO 생산 호기명			                 
        ,	PMATNR			                  										--	재단 자재 코드			                 
        ,	PCODE			                    										--	지종			                       
        ,	WEIGHT			                  										--	평량			                       
        ,	WLEN			                    										--	가로길			                       
        ,	VLEN			                    										--	세로길			                       
        ,	PTCNT			                    										--	수량			                       
        ,	PCNT			                    										--	수량			                       
        ,	PGEWEW			                  										--	총중량			                       
        ,	PGEWEI			                  										--	단위			                       
        ,	ZZATT1			                  										--	팔레트당연수			                   
        ,	ZZATT2			                  										--	속당매수			                     
        ,	DOUBLEFLAG		                										--	쌍팔레트			                     
        ,	PALETTECNT		                										--	팔레트당연수			                   
        ,	CONTYPE			                  										--	컨테이너 타입			                   
        ,	PACKTYPE			                										--	포장 타입			                     
        ,	VBELN			                    										--	판매문서			                     
        ,	POSNR			                    										--	판매문서 항목번호			                 
        ,	SAUART			                  										--	판매문서 유형			                   
        ,	SAUARTXT			                										--	판매 문서 오더 유형 텍스트                
        ,	OVBELN			                  										--	판매문서			                     
        ,	OPOSNR			                  										--	판매문서 항목번호			                 
        ,	OAUART			                  										--	판매문서 유형			                   
        ,	OAUARTXT			                										--	판매 문서 오더 유형 텍스트                
        ,	KUNNR			                    										--	판매처			                       
        ,	REMARK			                  										                    --	비고			                       
        ,	STLNR			                    										--	BOM Num			                   
        ,	STLAL			                    										--	대체Bom			                     
        ,	BMENG			                    										--	모품목기준수량			                   
        ,	BMEIN			                    										--	모품목기준수량 단위			               
        ,	DLFL			                    										--	오더 삭제 지시자			                 
        , ROUTE                         										--  항차                             
        , KUNNRT                        										--	판매처명                           
        , FRAUFNR                       										--	이전오더                           
                                        										                                   
        , UPDDATE                       										--  수정일자                           
        , UPDID                         										--  수정자                            
      )=(SELECT                         										
           CTPO			                    										--	재단 오더 번호			                          
          ,WERKS			                  										--	플랜트			                               
          ,BUDAT			                  										--	시작일자			                              
          ,AUART			                  										--	오더유형			                              
          ,AUARTXT			                										--	오더유형 텍스트			                           
          ,MACHINE			                										--	FROM 생산호기			                        
          ,MACHINETXT			              										--	FROM 생산 호기명			                         
          ,TOMACHINE			              										--	TO 생산호기			                            
          ,TOMACHINETXT		              										--	TO 생산 호기명			                     
          ,PMATNR			                  										--	재단 자재 코드			                            
          ,PCODE			                  										--	지종			                              
          ,WEIGHT			                  										--	평량			                              
          ,WLEN			                    										--	가로길			                             
          ,VLEN			                    										--	세로길			                             
          ,PCNT			                    										--	수량			                              
          ,PCNT			                    										--	수량			                            
          ,PGEWEW			                  										--	총중량			                               
          ,PGEWEI			                  										--	단위			                              
          ,ZZATT1			                  										--	팔레트당연수			                              
          ,ZZATT2			                  										--	속당매수			                              
          ,DOUBLEFLAG			              										--	쌍팔레트			                              
          ,PALETTECNT			              										--	팔레트당연수			                              
          ,CONTYPE			                										--	컨테이너 타입			                                  
          ,PACKTYPE			                										--	포장 타입			                            
          ,VBELN			                  										--	판매문서			                              
          ,POSNR			                  										--	판매문서 항목번호			                              
          ,SAUART			                  										--	판매문서 유형			                              
          ,SAUARTXT			                										--	판매 문서 오더 유형 텍스트                            
          ,OVBELN			                  										--	판매문서			                              
          ,OPOSNR			                  										--	판매문서 항목번호			                              
          ,OAUART			                  										--	판매문서 유형			                              
          ,OAUARTXT			                										--	판매 문서 오더 유형 텍스트                            
          ,KUNNR			                  										--	판매처			                               
          ,REMARK			                  										                    --	비고			                              
          ,STLNR			                  										--	BOM Num			                        
          ,STLAL			                  										--	대체Bom			                            
          ,BMENG			                  										--	모품목기준수량			                               
          ,BMEIN			                  										--	모품목기준수량 단위			                             
          ,DLFL			                    										--	오더 삭제 지시자			                             
          ,ROUTE                        										--  항차                                    
          ,NAME1                        										--	판매처명                                      
          ,FRAUFNR                      										--	이전오더                                      
                                        										                                                                                 
          ,sysdate                      										--  수정일자                                                         
          ,'SP_SCH_SYNC_PA'             										    --  수정자                                                                  
         FROM TB_IFR021 
         WHERE  IF_IFR_NO = i_IF_IFR_NO      
      )
      WHERE  AUFNR   = i_AUFNR 
      AND    PACKSEQ = TO_NUMBER(i_PACKSEQ);       
    ELSE    
      INSERT INTO TB_SCH009(  
          AUFNR							                      					--	오더번호			                
        ,	PACKSEQ  			                          					--	PACKING SEQ			             
        ,	CTPO							                      					--	재단 오더 번호			              
        ,	WERKS							                      					--	플랜트			                  
        ,	BUDAT							                      					--	시작일자			                
        ,	AUART							                      					--	오더유형			                
        ,	AUARTXT							                    					--	오더유형 텍스트			            
        ,	MACHINE							                    					--	FROM 생산호기			            
        ,	MACHINETXT							                					--	FROM 생산 호기명			          
        ,	TOMACHINE							                  					--	TO 생산호기			              
        ,	TOMACHINETXT							              					--	TO 생산 호기명			             
        ,	PMATNR							                    					--	재단 자재 코드			            
        ,	PCODE							                      					--	지종			                  
        ,	WEIGHT							                    					--	평량			                  
        ,	WLEN							                      					--	가로길			                   
        ,	VLEN							                      					--	세로길			                   
        ,	PTCNT							                      					--	수량			                  
        ,	PCNT							                      					--	수량			                  
        ,	PGEWEW							                    					--	총중량			                  
        ,	PGEWEI							                    					--	단위			                  
        ,	ZZATT1							                    					--	팔레트당연수			              
        ,	ZZATT2							                    					--	속당매수			                
        ,	DOUBLEFLAG							                					--	쌍팔레트			                
        ,	PALETTECNT							                					--	팔레트당연수			              
        ,	CONTYPE							                    					--	컨테이너 타입			              
        ,	PACKTYPE							                  					--	포장 타입			                 
        ,	VBELN							                      					--	판매문서			                
        ,	POSNR							                      					--	판매문서 항목번호			            
        ,	SAUART							                    					--	판매문서 유형			              
        ,	SAUARTXT							                  					--	판매 문서 오더 유형 텍스트               
        ,	OVBELN							                    					--	판매문서			                
        ,	OPOSNR							                    					--	판매문서 항목번호			              
        ,	OAUART							                    					--	판매문서 유형			               
        ,	OAUARTXT							                  					--	판매 문서 오더 유형 텍스트                
        ,	KUNNR							                      					--	판매처			                  
        ,	REMARK							                    					                    --	비고			                  
        ,	STLNR							                      					--	BOM Num			              
        ,	STLAL							                      					--	대체Bom			                
        ,	BMENG							                      					--	모품목기준수량			              
        ,	BMEIN							                      					--	모품목기준수량 단위			           
        ,	DLFL							                      					--	오더 삭제 지시자			            
        , ROUTE                                   					--  항차                                       
        , KUNNRT                                  					--	판매처명                      
        , FRAUFNR                                 					--	이전오더                      
                                                  					                              
        ,	REGDATE							                    					--	등록일자			                 
        ,	REGID							                      					--	등록자			                  
        ,	UPDDATE							                    					--	수정일자			                 
        ,	UPDID							                      					--	수정자			                  
      )                                           					                              
      SELECT                                      					                              
          AUFNR				                            					--	오더번호			                     
        ,	PACKSEQ	                                					--	PACKING SEQ			                     
        ,	CTPO				                            					--	재단 오더 번호			                      
        ,	WERKS				                            					--	플랜트			                      
        ,	BUDAT				                            					--	시작일자			                     
        ,	AUART				                            					--	오더유형			                     
        ,	AUARTXT				                          					--	오더유형 텍스트			                     
        ,	MACHINE				                          					--	FROM 생산호기			                   
        ,	MACHINETXT				                      					--	FROM 생산 호기명			                  
        ,	TOMACHINE				                        					--	TO 생산호기			                   
        ,	TOMACHINETXT				                    					--	TO 생산 호기명			                      
        ,	PMATNR				                          					--	재단 자재 코드			                     
        ,	PCODE				                            					--	지종			                      
        ,	WEIGHT				                          					--	평량			                        
        ,	WLEN				                            					--	가로길			                           
        ,	VLEN				                            					--	세로길			                           
        ,	PCNT				                            					--	수량			                      
        ,	PCNT				                            					--	수량			                          
        ,	PGEWEW				                          					--	총중량			                        
        ,	PGEWEI				                          					--	단위			                        
        ,	ZZATT1				                          					--	팔레트당연수			                      
        ,	ZZATT2				                          					--	속당매수			                       
        ,	DOUBLEFLAG				                      					--	쌍팔레트			                       
        ,	PALETTECNT				                      					--	팔레트당연수			                      
        ,	CONTYPE				                          					--	컨테이너 타입			                      
        ,	PACKTYPE				                        					--	포장 타입			                         
        ,	VBELN				                            					--	판매문서			                     
        ,	POSNR				                            					--	판매문서 항목번호			                   
        ,	SAUART				                          					--	판매문서 유형			                      
        ,	SAUARTXT				                        					--	판매 문서 오더 유형 텍스트                      
        ,	OVBELN				                          					--	판매문서			                        
        ,	OPOSNR				                          					--	판매문서 항목번호			                     
        ,	OAUART				                          					--	판매문서 유형			                      
        ,	OAUARTXT				                        					--	판매 문서 오더 유형 텍스트                      
        ,	KUNNR				                            					--	판매처			                       
        ,	REMARK				                          					                            --	비고			                         
        ,	STLNR				                            					--	BOM Num			                  
        ,	STLAL				                            					--	대체Bom			                     
        ,	BMENG				                            					--	모품목기준수량			                     
        ,	BMEIN				                            					--	모품목기준수량 단위			                  
        ,	DLFL				                            					--	오더 삭제 지시자			                   
        , ROUTE                                   					--  항차                                    
        , NAME1                                   					--	판매처명                      
        , FRAUFNR                                 					--	이전오더                      
                                                  					                              
        , sysdate                                 					--  등록일자                                            
        , 'SP_SCH_SYNC_PA'                        					    --  등록자                                                  
        , null                                    					--  수정일자                                             
        , null                                    					--  수정자                                             
      FROM  TB_IFR021
      WHERE  IF_IFR_NO = i_IF_IFR_NO;                      
    END IF;  
    

    --========================================
    --KHJ추가 2022-05-02:작업지시-포장
    --========================================
    ------------------------------------------
    --작업지시가 존재하지 않으면 작업지시 번호 생성
    SELECT COUNT(1) INTO V_CNT
    FROM TB_SCH018
    WHERE ORDER_NO = i_AUFNR;

    IF V_CNT = 0 THEN
      SELECT BUDAT INTO V_WO_DT
      FROM TB_IFR021
      WHERE IF_IFR_NO  =  i_IF_IFR_NO;

      SP_GET_DOC_SEQ('WOPA',V_WO_DT,V_WO_NO); 
    END IF;
    ------------------------------------------
           
    IF V_CNT > 0 THEN    
      UPDATE TB_SCH018
      SET(        
            PRE_ORDER_NO         																--이전 오더 번호       
           ,WERKS                																--플랜트코드          
           ,PRD_REQ_DT           																--생산요청일자         
           ,ORDER_DIV            																--오더유형           
           ,ORDER_DIV_NM         																--오더유형 텍스트       
           ,MACHINE              																--FROM 생산 호기     
           ,MACHINE_NM           																--FROM 생산 호기명    
           ,TO_MACHINE           																--TO 생산호기        
           ,TO_MACHINE_NM        																--TO 생산 호기명      
           ,MATNR                																--자재 코드          
           ,PCODE                																--지종             
           ,BS_WGT               																--평량             
           ,WLEN                 																--가로길            
           ,VLEN                 																--세로길            
           ,WRK_ORDR_QTY         																--생산지시량(SAP에서 사용안하는필드로 PCNT와 동일값 저장 22-08-05)         
           ,PCNT                 																--수량             
           ,TOT_WGT              																--총중량            
           ,UNIT                 																--단위             
           ,PLT_PER_CNT          																--팔레트당연수         
           ,IN_PER_CNT           																--속당매수           
           ,DBL_FLAG             																--쌍팔레트           
           ,PALETTECNT           																--팔레트당연수         
           ,CON_TYPE             																--컨테이너 타입        
           ,PACKTYPE             																--포장 타입          
           ,PKCNT                																--폭수             
           ,MCNT                 																--매              
           ,SCNT                 																--속              
           ,VBELN                																--판매문서           
           ,POSNR                																--판매문서 항목번호      
           ,SAUART_DIV           																--판매문서 유형        
           ,SAUART_NM            																--판매 문서 오더 유형 텍스트
           ,OVBELN               																--판매문서           
           ,OPOSNR               																--판매문서 항목번호      
           ,OAUART_DIV           																--판매문서 유형        
           ,OAUART_NM            																--판매 문서 오더 유형 텍스트
           ,KUNNR                																--판매처            
           ,ORDER_RMK            																--비고(22-06-08:REMARK->ORDER_RMK)             
           ,BOM_NO               																--BOM Num        
           ,ATN_BOM_NO           																--대체Bom          
           ,PRT_MATNR_QTY        																--모품목기준수량        
           ,PRT_MATNR_UNIT       																--모품목기준수량 단위     
           ,DLFL                 																--오더 삭제 지시자
           ,ROUTE                																--항차  
           ,KUNNRT               																--판매처명  
           ,PACKSEQ					    																--PACKING SEQ
                                                                
           ,UPDDATE              																--수정일시
           ,UPDID                														    --수정자ID
           ,USE_YN               														    --사용여부(Y:사용 N:미사용)	                           
      )=(SELECT                         										
					  FRAUFNR                        									--이전 오더 번호       
					 ,WERKS                          									--플랜트코드          
					 ,BUDAT                          									--생산요청일자         
					 ,AUART                          									--오더유형           
					 ,AUARTXT                        									--오더유형 텍스트       
					 ,MACHINE                        									--FROM 생산 호기     
					 ,MACHINETXT                     									--FROM 생산 호기명    
					 ,TOMACHINE                      									--TO 생산호기        
					 ,TOMACHINETXT                   									--TO 생산 호기명      
					 ,PMATNR                         									--자재 코드          
					 ,PCODE                          									--지종             
					 ,WEIGHT                         									--평량             
					 ,WLEN                           									--가로길            
					 ,VLEN                           									--세로길            
					 ,PCNT                           									--생산지시량(SAP에서 사용안하는필드로 PCNT와 동일값 저장 22-08-05)         
					 ,PCNT                           									--수량             
					 ,PGEWEW                         									--총중량            
					 ,PGEWEI                         									--단위             
					 ,ZZATT1                         									--팔레트당연수         
					 ,ZZATT2                         									--속당매수           
					 ,DOUBLEFLAG                     									--쌍팔레트           
					 ,PALETTECNT                     									--팔레트당연수         
					 ,CONTYPE                        									--컨테이너 타입        
					 ,PACKTYPE                       									--포장 타입          
					 ,PKCNT                          									--폭수             
					 ,MCNT                           									--매              
					 ,SCNT                           									--속              
					 ,VBELN                          									--판매문서           
					 ,POSNR                          									--판매문서 항목번호      
					 ,SAUART                         									--판매문서 유형        
					 ,SAUARTXT                       									--판매 문서 오더 유형 텍스트
					 ,OVBELN                         									--판매문서           
					 ,OPOSNR                         									--판매문서 항목번호      
					 ,OAUART                         									--판매문서 유형        
					 ,OAUARTXT                       									--판매 문서 오더 유형 텍스트
					 ,KUNNR                          									--판매처            
					 ,REMARK                         									                        --비고(22-06-08:REMARK->ORDER_RMK)             
					 ,STLNR                          									--BOM Num        
					 ,STLAL                          									--대체Bom          
					 ,BMENG                          									--모품목기준수량        
					 ,BMEIN                          									--모품목기준수량 단위     
					 ,DLFL                           									--오더 삭제 지시자
					 ,ROUTE                          									--항차  
					 ,NAME1                          									--판매처명  
					 ,PACKSEQ                        									--PACKING SEQ
                                                  					
           ,sysdate                               					--수정일시
           ,'SP_SCH_SYNC_PA'                           				--수정자ID
           , case when DLFL = 'Y' then 'N' 					           
                  when DLFL = 'N' then 'Y' 					
             end                                  					--사용여부(Y:사용 N:미사용)	                                                             
         FROM TB_IFR021 
         WHERE  IF_IFR_NO = i_IF_IFR_NO      
      )
      WHERE  ORDER_NO   = i_AUFNR;       
    ELSE    
      INSERT INTO TB_SCH018(  
         WRK_ORDR_NO                                                  --작업지시번호-->작업지시 생성자 사용 WO + R  
        ,WRK_ORDR_SEQNO                                               --작업지시순번
        ,WRK_SEQNO                                                    --작업순서
        ,ORDR_GEN_DT                                                  --지시생성일자					 

        ,ORDER_NO            																				  --오더번호           
        ,PRE_ORDER_NO         												                --이전 오더 번호       
        ,WERKS                												                --플랜트코드          
        ,PRD_REQ_DT           												                --생산요청일자         
        ,ORDER_DIV            												                --오더유형           
        ,ORDER_DIV_NM         												                --오더유형 텍스트       
        ,MACHINE              												                --FROM 생산 호기     
        ,MACHINE_NM           												                --FROM 생산 호기명    
        ,TO_MACHINE           												                --TO 생산호기        
        ,TO_MACHINE_NM        												                --TO 생산 호기명      
        ,MATNR                												                --자재 코드          
        ,PCODE                												                --지종             
        ,BS_WGT               												                --평량             
        ,WLEN                 												                --가로길            
        ,VLEN                 												                --세로길            
        ,WRK_ORDR_QTY         												                --생산지시량(*)          
        ,PCNT                 												                --연수(*)             
        ,TOT_WGT              												                --총중량(*)            
        ,UNIT                 												                --단위             
        ,PLT_PER_CNT          												                --팔레트당연수         
        ,IN_PER_CNT           												                --속당매수           
        ,DBL_FLAG             												                --쌍팔레트           
        ,PALETTECNT           												                --팔레트당연수         
        ,CON_TYPE             												                --컨테이너 타입        
        ,PACKTYPE             												                --포장 타입          
        ,PKCNT                												                --폭수             
        ,MCNT                 												                --매              
        ,SCNT                 												                --속              
        ,VBELN                												                --판매문서           
        ,POSNR                												                --판매문서 항목번호      
        ,SAUART_DIV           												                --판매문서 유형        
        ,SAUART_NM            												                --판매 문서 오더 유형 텍스트
        ,OVBELN               												                --판매문서           
        ,OPOSNR               												                --판매문서 항목번호      
        ,OAUART_DIV           												                --판매문서 유형        
        ,OAUART_NM            												                --판매 문서 오더 유형 텍스트
        ,KUNNR                												                --판매처            
        ,ORDER_RMK               												              --비고(22-06-08:REMARK->ORDER_RMK)              
        ,BOM_NO               												                --BOM Num        
        ,ATN_BOM_NO           												                --대체Bom          
        ,PRT_MATNR_QTY        												                --모품목기준수량        
        ,PRT_MATNR_UNIT       												                --모품목기준수량 단위     
        ,DLFL                 												                --오더 삭제 지시자 
        ,ROUTE                                                        --항차
        ,KUNNRT                                                       --판매처명
        ,PACKSEQ                                                      --PACKING SEQ						 					 

        ,COMP_YN                                                      --완료여부
        ,REGDATE                                                      --등록일시
        ,REGID                                                        --등록자ID
        ,UPDDATE                                                      --수정일시
        ,UPDID                                                        --수정자ID
        ,USE_YN                                                       --사용여부(Y:사용 N:미사용)                 
      )                                           					                              
      SELECT                                      					                              
			  V_WO_NO	    																											  --작업지시번호             
			 ,1                                                                   --작업지시순번 
       ,SUBSTR(V_WO_NO,-4)                                                  --작업순서(작업지시번호,-4)
       ,TO_CHAR(sysdate,'YYYYMMDD')                                          --지시생성일자 					 

			 ,AUFNR        																												--오더번호           
			 ,FRAUFNR                         																		--이전 오더 번호       
			 ,WERKS                          																			--플랜트코드          
			 ,BUDAT                          																			--생산요청일자         
			 ,AUART                          																			--오더유형           
			 ,AUARTXT                        																			--오더유형 텍스트       
			 ,MACHINE                        																			--FROM 생산 호기     
			 ,MACHINETXT                     																			--FROM 생산 호기명    
			 ,TOMACHINE                      																			--TO 생산호기        
			 ,TOMACHINETXT                   																			--TO 생산 호기명      
			 ,PMATNR                         																			--자재 코드          
			 ,PCODE                          																			--지종             
			 ,WEIGHT                         																			--평량             
			 ,WLEN                           																			--가로길            
			 ,VLEN                           																			--세로길            
			 ,PCNT                          																			--생산지시량(SAP에서 사용안하는필드로 PCNT와 동일값 저장 22-08-05)          
			 ,PCNT                           																			--수량             
			 ,PGEWEW                         																			--총중량            
			 ,PGEWEI                         																			--단위             
			 ,ZZATT1                         																			--팔레트당연수         
			 ,ZZATT2                         																			--속당매수           
			 ,DOUBLEFLAG                     																			--쌍팔레트           
			 ,PALETTECNT                     																			--팔레트당연수         
			 ,CONTYPE                        																			--컨테이너 타입        
			 ,PACKTYPE                       																			--포장 타입          
			 ,PKCNT                          																			--폭수             
			 ,MCNT                           																			--매              
			 ,SCNT                           																			--속              
			 ,VBELN                          																			--판매문서           
			 ,POSNR                          																			--판매문서 항목번호      
			 ,SAUART                         																			--판매문서 유형        
			 ,SAUARTXT                       																			--판매 문서 오더 유형 텍스트
			 ,OVBELN                         																			--판매문서           
			 ,OPOSNR                         																			--판매문서 항목번호      
			 ,OAUART                         																			--판매문서 유형        
			 ,OAUARTXT                       																			--판매 문서 오더 유형 텍스트
			 ,KUNNR                          																			--판매처            
			 ,REMARK                         																			                        --비고             
			 ,STLNR                          																			--BOM Num        
			 ,STLAL                          																			--대체Bom          
			 ,BMENG                          																			--모품목기준수량        
			 ,BMEIN                          																			--모품목기준수량 단위     
			 ,DLFL                           																			--오더 삭제 지시자  
			 ,ROUTE                                                       				--항차
			 ,NAME1                                                       				--판매처명 
			 ,PACKSEQ                                                     				--PACKING SEQ 					 					  

			 ,'N'                                                                  --완료여부               
			 ,sysdate                                                             --등록일시               
			 ,'SP_SCH_SYNC_PA'                                                       --등록자ID              
			 ,null                                                                --수정일시               
			 ,null                                                                --수정자ID 
			 ,case when DLFL = 'X' then 'N'					            
             else 'Y'					       
			  end                                         
      FROM  TB_IFR021
      WHERE  IF_IFR_NO = i_IF_IFR_NO;                      
    END IF;  

              
    --포장공정은 작업지시 SUM하는것으로 변경 22-08-18    
    UPDATE TB_SCH018
    SET WRK_ORDR_QTY  = (SELECT SUM(PCNT)  FROM TB_SCH009 WHERE AUFNR     =  i_AUFNR AND DLFL  <> 'X')  --생산지시량(*)
       ,PCNT          = (SELECT SUM(PCNT)   FROM TB_SCH009 WHERE AUFNR     =  i_AUFNR AND DLFL  <> 'X')  --연수(*)  
       ,TOT_WGT       = (SELECT SUM(PGEWEW) FROM TB_SCH009 WHERE AUFNR     =  i_AUFNR AND DLFL  <> 'X')  --총중량(*)  
    WHERE ORDER_NO = i_AUFNR;   


    --작업지시 생성되면 작업지시BOM을 구성한다.   
    --작업지시정보 추출
    SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, WERKS INTO V_WO_NO,V_WO_SEQ,V_WERKS
    FROM TB_SCH018
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
            ,'SP_SCH_SYNC_PA'
            ,null
            ,null
      FROM TB_SCH001          
      WHERE  AUFNR  =  i_AUFNR;       
    END IF;                        

    
    o_msg_MSG  := 'SP_SCH_SYNC_PA==>완료==>'|| i_AUFNR ||'=>' || TO_CHAR(i_PACKSEQ) ||'=>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS');

    UPDATE  TB_IFR021
    SET     IF_STATUS   =  'S'                                                    -- I/F상태, N:신규, S:성공, E:오류
          , IF_SET_DATE =  sysdate            
          , IF_ERR_MESS =  o_msg_MSG          
    WHERE AUFNR   =  i_AUFNR
    AND   PACKSEQ =  i_PACKSEQ;

    o_msg_MSG  := 'SP_SCH_SYNC_PA==>완료==>'|| i_AUFNR ||'=>' || TO_CHAR(i_PACKSEQ) ||'=>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS');
    o_msg_code := '0';
                                    
    DBMS_OUTPUT.PUT_LINE(o_msg_msg);
    SP_IF_MIG_LOG('SP_SCH_SYNC_PA',o_msg_code,o_msg_MSG);
    COMMIT;
      
    EXCEPTION  
      WHEN E_EXCEPTION_USER THEN        
            DBMS_OUTPUT.PUT_LINE(o_msg_MSG);
            ROLLBACK;
       
            UPDATE  TB_IFR021
            SET     IF_STATUS   =  'E'  
                  , IF_SET_DATE =  sysdate                                      --I/F상태, N:신규, S:성공, E:오류               
                  , IF_ERR_MESS =  o_msg_MSG                                                            
            WHERE IF_IFR_NO   =  i_IF_IFR_NO; 
            
            DBMS_OUTPUT.PUT_LINE (o_msg_msg );            
            SP_IF_MIG_LOG('USER:SP_SCH_SYNC_PA',o_msg_code,o_msg_msg);                                        
            COMMIT;                                    
                                      
      WHEN OTHERS THEN
            o_msg_msg  :=  'OTHER:SP_SCH_SYNC_PA에서 오류가 발생 되었습니다=>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS') || ',' || SQLERRM ;
            o_msg_code := '-1' ;
            ROLLBACK;

            UPDATE  TB_IFR021
            SET     IF_STATUS   =  'E'                                            --I/F상태, N:신규, S:성공, E:오류               
                  , IF_ERR_MESS =  o_msg_MSG                                                            
            WHERE IF_IFR_NO   =  i_IF_IFR_NO;
            
            DBMS_OUTPUT.PUT_LINE (o_msg_msg );            
            SP_IF_MIG_LOG('SP_SCH_SYNC_PA',o_msg_code,o_msg_msg);                                        
            COMMIT;       
  END;
  END LOOP;

  o_msg_code      := '0' ;
  o_msg_msg       := 'End:SP_SCH_SYNC_PA 종료 되었습니다..=>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS');
  DBMS_OUTPUT.PUT_LINE(o_msg_msg);  
  SP_IF_MIG_LOG('SP_SCH_SYNC_PA',o_msg_code,o_msg_msg);
  COMMIT;                                                                   
                                                                      
       
 EXCEPTION
    WHEN OTHERS THEN
      o_msg_code      := '-1' ;
      o_msg_msg       := 'Error: SP_SCH_SYNC_PA에서 오류가 발생하였습니다.=>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS') || ',' || to_char(SQLCODE) || ',' || SQLERRM ;
      rollback ;

      DBMS_OUTPUT.PUT_LINE(o_msg_msg);      
      SP_IF_MIG_LOG('SP_SCH_SYNC_PA',o_msg_code,o_msg_msg);
      COMMIT;       

END;
/
