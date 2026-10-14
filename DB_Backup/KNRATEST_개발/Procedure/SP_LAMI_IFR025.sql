--------------------------------------------------------
--  DDL for Procedure SP_LAMI_IFR025
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_LAMI_IFR025" (
            i_IF_IFR_NO      IN   NUMBER   /* MES Interface Sequence(수신번호)        */
            ,i_AUFNR          IN   VARCHAR2
            ,i_ZCOR           IN   VARCHAR2                      
            ,o_msg_CODE       OUT  VARCHAR2
            ,o_msg_MSG        OUT  VARCHAR2
            )
/*==============================================================================
 * PROGRAM ID    : SP_LAMI_IFR024{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 라미네이팅 슬리팅 작업지시 저장{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 라미네이팅 슬리팅 작업지시 저장한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 김수현{최초 작성자 명 기술}
 * CREATE DATE   : 2022/12/09 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/12/08    1.0.0   김수현         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_LAMI_IFR025] : (CRUD)SAP I/F TABLE                                
 *=============================================================================*/

AS

  V_CNT           NUMBER          := 0;      -- 카운트(작업지시존재여부) 
  V_BOM_CNT       NUMBER          := 0;      -- 카운트(작업지시BOM존재여부)

  V_WO_DT         VARCHAR2(50)    := '';      -- 지시일자(작업지시생성하기 위해서..)  

  V_WO_NO         VARCHAR2(50)    := '';      -- 작업지시번호 (작업지시BOM생성을 위해서..)  
  V_WO_SEQ        NUMBER          := 0;      --작업지시순번 (작업지시BOM생성을 위해서..)  
  V_WERKS         VARCHAR2(50)    := '';      -- 플랜트 (작업지시BOM생성을 위해서..) 

  V_DLFL          VARCHAR2(50)    := '';      -- 삭제FLAG

  V_DOC_NO        VARCHAR2(50)    := '';      -- MES문서번호  
  V_DOC_SEQ       NUMBER          := 1;      -- MES문서순번  

  V_FRAUFNR       VARCHAR2(50)    := '';      -- WCS로 넘기기 위한 이전오더번호 
  V_MILLROLL_BAR  VARCHAR2(50)    := '';      -- WCS로 넘기기 위한 밀롤바코드 
BEGIN

    SELECT NVL(DLFL,' ') INTO V_DLFL
    FROM TB_LAMI_IFR025
    WHERE AUFNR = i_AUFNR
    AND IF_IFR_NO = i_IF_IFR_NO;    

DBMS_OUTPUT.PUT_LINE('1' );

    IF V_DLFL = 'X' THEN
      UPDATE TB_LAMI_SL_ORDER
         SET DLFL = V_DLFL
           , UPDDATE = SYSDATE
           , UPDID = 'SP_LAMI_IFR024'
       WHERE AUFNR =  i_AUFNR;

      UPDATE TB_LAMI_SL
         SET USE_YN = 'N'
           , UPDDATE = SYSDATE
           , UPDID = 'SP_LAMI_IFR024'
       WHERE ORDER_NO =  i_AUFNR;             

      o_msg_MSG  :=  'TB_LAMI_IFR025, 생산오더-라미네이팅 슬리팅 삭제 수신되었습니다.1'; -- || ',' || SQLERRM ;

      UPDATE  TB_LAMI_IFR025
      SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
            , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
            , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
      WHERE  AUFNR     =  i_AUFNR
      AND    IF_IFR_NO =  i_IF_IFR_NO           
      ;

      o_msg_MSG  :=  'TB_LAMI_IFR025, 생산오더-라미네이팅 슬리팅 삭제 수신되었습니다.2'; -- || ',' || SQLERRM ;
      o_msg_code := '0' ;
      RETURN;    
    END IF;

    --재단출고여부 'X'이면 WCS로 I/F 한다.(sp_ifr020_X 분리된것을 여기에 통합함) 22-08-31 

    ----당분간 보류해서 진행한다. 해제해야 함. 
    IF i_ZCOR = 'X' THEN
      V_DOC_NO := FN_GET_MDOCNO('M','IFWC006');

      SELECT NVL(FRAUFNR,'@') INTO V_FRAUFNR
      FROM TB_LAMI_IFR025
      WHERE IF_IFR_NO =  i_IF_IFR_NO;

      IF  V_FRAUFNR = '@' THEN
          o_msg_MSG  :=  'TB_LAMI_IFR025, 이전오더번호가 없습니다.';
          o_msg_code := '-1' ;
          DBMS_OUTPUT.PUT_LINE (o_msg_msg );
          ROLLBACK;

          UPDATE  TB_LAMI_IFR025
          SET     IF_STATUS   =  'E'                --  I/F상태, N:신규, S:성공, E:오류              
                , IF_SET_DATE =  sysdate            --  데이터 처리시간(MES I/F 테이블 → MES 운영테이블)
                , IF_ERR_MESS =  o_msg_MSG          -- 데이터 처리 결과 Message(Oracle)             
          WHERE  IF_IFR_NO =  i_IF_IFR_NO;    

          RETURN;      
      END IF;

      -----------------------------------------------------------------------------------------------------------------------
      --조회하는 내용이 한건도 조회 안될때 아래와 같이 처리해야 함. KHJ 22-09-19
      --다른방법1:데이타 존재여부를 V_CNT로 판단을 하고 존해했을때 변수에 넣는 방법으로 할수도 있다.(★)
      --다른방법2:아래와 같이 BEGIN~END문을 이용 할수도 있다.(★)
      --              BEGIN
      --               ~      
      --               EXCEPTION
      --                  WHEN NO_DATA_FOUND THEN      
      --               END                  
      -----------------------------------------------------------------------------------------------------------------------      
--      SELECT NVL((SELECT IND_BCD 
--                  FROM TB_INV001 
--                  WHERE (ORDER_NO = V_FRAUFNR or LOT_NO = V_FRAUFNR) 
--                  AND STCK_QTY > 0 
--                  AND ROWNUM=1),'@') INTO V_MILLROLL_BAR 
--      FROM DUAL;
--      
--      IF  V_MILLROLL_BAR = '@' THEN
--          o_msg_MSG  :=  'TB_IFR020, WCS를 위한 밀롤바코드번호를 찾지 못했습니다.';
--          o_msg_code := '-1' ;
--          DBMS_OUTPUT.PUT_LINE (o_msg_msg );
--          ROLLBACK;
--
--          UPDATE  TB_IFR020
--          SET     IF_STATUS   =  'E'                -- I/F상태, N:신규, S:성공, E:오류               
--                , IF_SET_DATE =  sysdate            --  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
--                , IF_ERR_MESS =  o_msg_MSG          --  데이터 처리 결과 Message(Oracle)              
--          WHERE  IF_IFR_NO =  i_IF_IFR_NO;    
--          
--          RETURN;      
--      END IF;      

--    V_DOC_NO := FN_GET_MDOCNO('M','IFWC006');
--
--      INSERT INTO TB_IFSWC006(
--         DOC_NO     							 --문서번호                                         
--        ,DOC_NOSEQ                 --문서번호 순번   
--
--        ,BARCODE                   --밀롤바코드
--        ,CT_LOT_ID
--        ,WRKORD                    --ERP 생산오더번호                                 
--        ,PLNT_CD                   --플랜트                                           
--        ,WORK_DT                   --생산 계획일 (YYYYMMDD)                           
--        ,MCHN_CD                   --투입할 Cutter 호기(PM3)                          
--        ,REMARK5                   --비고5                                            
--        ,REMARK6                   --비고6                                            
--        ,SPECIAL_NO                --ERP 특별재고번호                                 
--        ,REMARK7                   --포장타입(PACKTYPE)                               
--        ,REMARK8                   --폭수                                                          
--        ,REMARK1                   --비고1                                            
--        ,REMARK2                   --비고2                                            
--        ,LOT_ID                    --MR LOTID                                         
--        ,CLASS                     --반                                               
--        ,MATERIAL_NO               --ERP 자재코드 (커터 자재코드)                     
--        ,LENGTH                    --권치수, 길이(M)                                  
--        ,WEIGHT                    --중량(KG)   
--        ,WORK_DRCT                 --생산 작업 지시사항
--        ,WORK_TIME                 --생산 계획 시간 (HHMM)
--        ,WORK_SEQ                  --생산 계획 순번
--        ,AUFNR                     --오더번호
--
--        ,IF_STATUS                 --WCS 결과값 Return( N:대기,S:성공, E:오류 )       
--        ,IF_GET_DATE               --MES 등록일시                                     
--        ,IF_SET_DATE               --WCS 전송일시                                     
--        ,IF_ERR_MESS               --WCS 결과 메시지                                  
--        ,IF_MES_KEY                --MES Inserface Key
--        
--        ,REMARK3                   --A.PCODE AS "지종"  
--        ,REMARK4                  --A.WEIGHT AS "평량"
--      )
--      SELECT 
--         V_DOC_NO
--        ,V_DOC_SEQ
--
--        ,V_MILLROLL_BAR            --밀롤바코드
--        ,'*'
--        ,AUFNR                     --ERP 생산오더번호                       
--        ,WERKS                     --플랜트                              
--        ,BUDAT                     --생산 계획일 (YYYYMMDD)                
--        ,MACHINE                   --투입할 Cutter 호기(PM3)               
--        ,WLEN                      --비고5                              
--        ,VLEN                      --비고6                              
--        ,VBELN                     --ERP 특별재고번호                       
--        ,PACKTYPE                  --비고7-포장타입                              
--        ,CTCNT                     --비고8폭수                           
--        --,KUNNR                     --비고1
--        ,LPAD(KUNNR, 10, '0')      --비고1(10자리)               
--        ,NAME1                     --비고2                              
--        ,MRLOT                     --MR LOTID                         
--        ,WORKGROUP                 --반                                
--        ,MMATNR                    --ERP 자재코드 (커터 자재코드)               
--        ,MROLLCNT                  --권치수, 길이(M)                       
--        ,MBRGEW                    --중량(KG)  
--        ,REMARK                                         --생산 작업 지시사항
--        ,PTIM                      --생산 계획 시간 (HHMM)
--        ,PSEQ                      --생산 계획 순번
--        ,AUFNR                     --오더번호
--
--        ,'N'
--        ,sysdate
--        ,null
--        ,null
--        ,null
--        ,PCODE                   --REMARK9 지종
--        ,WEIGHT                  --REMARK10 평량
--      FROM TB_IFR020 
--      WHERE IF_IFR_NO =  i_IF_IFR_NO;        
    END IF; 



  -----------------------------------------------------------------------------------------------------------------------------
  --생산오더
  -----------------------------------------------------------------------------------------------------------------------------
    SELECT COUNT(1) INTO V_CNT FROM TB_LAMI_SL_ORDER WHERE AUFNR = i_AUFNR; 
DBMS_OUTPUT.PUT_LINE('2' );

    IF V_CNT > 0 THEN    
DBMS_OUTPUT.PUT_LINE('3' );
      UPDATE TB_LAMI_SL_ORDER
      SET(        
--            MRPO	         																		--MRPO	,		밀롤 오더 번호		                         
          	WERKS	         																		--WERKS	,		플랜트		                         
          ,	BUDAT	         																		--BUDAT	,		시작일자		                       
          ,	AUART	         																		--AUART	,		오더유형		                       
          ,	AUARTXT	       																		--AUARTXT	,		오더유형 텍스트		                     
          ,	MACHINE	       																		--MACHINE	,		FROM 생산호기		                    
          ,	MACHINETXT	   																		--MACHINETXT	,		FROM 생산 호기명		             
--          ,	TOMACHINE	     																		--TOMACHINE	,		TO 생산호기		                 
--          ,	TOMACHINETXT	 																		--TOMACHINETXT	,		TO 생산 호기명		                 
          ,	CMATNR	       																		--CMATNR	,		재단 자재 코드		                    
          ,	PCODE	         																		--PCODE	,		지종		                         
          ,	WEIGHT	       																		--WEIGHT	,		평량		                        
          ,	WLEN	         																		--WLEN	,		가로길		                               
          ,	VLEN	         																		--VLEN	,		세로길		                               
--          ,	CTCNT	         																		--CTCNT	,		폭수		                         
          ,	CNT	           																		--CNT	,		수량		                               
          ,	CGEWEW	       																		--CGEWEW	,		총중량		                         
          ,	CGEWEI	       																		--CGEWEI	,		단위		                         
--          ,	ZZATT1	       																		--ZZATT1	,		팔레트당연수		                       
--          ,	ZZATT2	       																		--ZZATT2	,		속당매수		                        
--          ,	DOUBLEFLAG	   																		--DOUBLEFLAG	,		쌍팔레트		                    
--          ,	VBELN	         																		--VBELN	,		판매문서		                        
--          ,	POSNR	         																		--POSNR	,		판매문서 항목번호		                      
--          ,	SAUART	       																		--SAUART	,		판매문서 유형		                       
--          ,	SAUARTXT	     																		--SAUARTXT	,		판매 문서 오더 유형 텍스트		                  
--          ,	OVBELN	       																		--OVBELN	,		판매문서		                        
--          ,	OPOSNR	       																		--OPOSNR	,		판매문서 항목번호		                      
--          ,	OAUART	       																		--OAUART	,		판매문서 유형		                       
--          ,	OAUARTXT	     																		--OAUARTXT	,		판매 문서 오더 유형 텍스트		                  
--          ,	CUTTER	       																		--CUTTER	,		카터		                          
          ,	STLNR	         																		--STLNR	,		BOM Num		                     
          ,	STLAL	         																		--STLAL	,		대체Bom		                        
--          ,	BMENG	         																		--BMENG	,		모품목기준수량		                        
--          ,	BMEIN	         																		--BMEIN	,		모품목기준수량 단위		                     
          ,	DLFL	         																		--DLFL	,		오더 삭제 지시자		                            
          ,	ROUTE	         																		--ROUTE	,		항차		                          
--          , ZCOR           																		--재단출고오더여부                                 
          , ORDER_RMK      																		--비고                                       
          , KUNNR          																		--판매처                                      
--          , KUNNRT         																		--판매처명                                     
--          , FRAUFNR        																		--이전오더                                     
--          , MWIDTH_INPUT   																		--M/R 지폭                                   
--          ,	MMATNR	       																		--CMATNR	,		원자재 코드		                    
--          ,	MAUFNR	       																		--CMATNR	,		원자재LOT		                    
--          ,	MBRGEW	       																		--CMATNR	,		원자재중량		                    
--          , MRCNT          																		--폭수                                       
--          , MCNT           																		--수량                                       
--          , SCNT           																		--수량                                       
--          , CONTYPE        																		--컨테이너유형                                   
          , SIZE_VAL       																		--규격                                       

          , UPDDATE        																		--수정일자                                                 
          , UPDID          																		--수정자                           
      )=(SELECT                         										
--           MRPO		              															--MRPO	,		밀롤 오더 번호		                                  
          WERKS		                                          --WERKS	,		플랜트		                                        
          ,BUDAT		                                          --BUDAT	,		시작일자		                                      
          ,AUART		                                          --AUART	,		오더유형		                                      
          ,AUARTXT		                                        --AUARTXT	,		오더유형 텍스트		                                
          ,MACHINE		                                        --MACHINE	,		FROM 생산호기		                                
          ,MACHINETXT		                                      --MACHINETXT	,		FROM 생산 호기명		                          
--          ,TOMACHINE		                                      --TOMACHINE	,		TO 생산호기		                                
--          ,TOMACHINETXT		                                    --TOMACHINETXT	,		TO 생산 호기명		                          
          ,CMATNR		                                          --CMATNR	,		재단 자재 코드		                                
          ,PCODE		                                          --PCODE	,		지종		                                        
          ,WEIGHT		                                          --WEIGHT	,		평량		                                      
          ,WLEN		                                            --WLEN	,		가로길		                                        
          ,VLEN		                                            --VLEN	,		세로길		                                        
--          ,CTCNT		                                          --CTCNT	,		폭수		                                        
          ,CNT		                                            --CNT	,		수량		                                          
          ,CGEWEW		                                          --CGEWEW	,		총중량		                                      
          ,CGEWEI		                                          --CGEWEI	,		단위		                                      
--          ,ZZATT1		                                          --ZZATT1	,		팔레트당연수		                                  
--          ,ZZATT2		                                          --ZZATT2	,		속당매수		                                    
--          ,DOUBLEFLAG		                                      --DOUBLEFLAG	,		쌍팔레트		                                
--          ,VBELN		                                          --VBELN	,		판매문서		                                      
--          ,POSNR		                                          --POSNR	,		판매문서 항목번호		                                  
--          ,SAUART		                                          --SAUART	,		판매문서 유형		                                  
--          ,SAUARTXT		                                        --SAUARTXT	,		판매 문서 오더 유형 텍스트		                        
--          ,OVBELN		                                          --OVBELN	,		판매문서		                                    
--          ,OPOSNR		                                          --OPOSNR	,		판매문서 항목번호		                                
--          ,OAUART		                                          --OAUART	,		판매문서 유형		                                  
--          ,OAUARTXT		                                        --OAUARTXT	,		판매 문서 오더 유형 텍스트		                        
--          ,CUTTER		                                          --CUTTER	,		카터		                                      
          ,STLNR		                                          --STLNR	,		BOM Num		                                    
          ,STLAL		                                          --STLAL	,		대체Bom		                                      
--          ,BMENG		                                          --BMENG	,		모품목기준수량		                                    
--          ,BMEIN		                                          --BMEIN	,		모품목기준수량 단위		                                
          ,DLFL		                                            --DLFL	,		오더 삭제 지시자		                                  
          ,ROUTE		                                          --ROUTE	,		항차		                                        
--          ,ZCOR                                               --재단출고오더여부                                                       
          ,REMARK                                                                                         --비고                                                       
          ,KUNNR                                              --판매처                                                       
--          ,MMATNR                                              --판매처                                                       
--          ,MRLOT                                              --판매처                                                       
--          ,MBRGEW	       																		--CMATNR	,		원자재중량		                    
--          ,NAME1                                              --판매처명                                                       
--          ,FRAUFNR                                            --이전오더                                                       
--          ,MWIDTH_INPUT                                       --M/R 지폭                                                   
--          ,MRCNT                                              --폭수                                                       
--          ,MCNT                                               --수량                                                       
--          ,SCNT                                               --수량                                                       
--          ,CONTYPE                                            --컨테이너유형                                                       
          ,SIZE_VAL                                           --규격                                        

          ,sysdate                      										  --  수정일자                                                         
          ,'SP_LAMI_IFR025'             										      --  수정자                                                                  
         FROM TB_LAMI_IFR025 
         WHERE  IF_IFR_NO = i_IF_IFR_NO      
      )
      WHERE  AUFNR   = i_AUFNR;       
    ELSE    
DBMS_OUTPUT.PUT_LINE('4' );
      INSERT INTO TB_LAMI_SL_ORDER(  
				 AUFNR			              													--AUFNR	,		오더번호		                                                              
--				,MRPO			                													--MRPO	,		밀롤 오더 번호		                                                          
				,WERKS			              													--WERKS	,		플랜트		                                                                
				,BUDAT			              													--BUDAT	,		시작일자		                                                              
				,AUART			              													--AUART	,		오더유형		                                                              
				,AUARTXT			            													--AUARTXT	,		오더유형 텍스트		                                                        
				,MACHINE			            													--MACHINE	,		FROM 생산호기		                                                        
				,MACHINETXT			          													--MACHINETXT	,		FROM 생산 호기명		                                                  
--				,TOMACHINE			          													--TOMACHINE	,		TO 생산호기		                                                        
--				,TOMACHINETXT			        													--TOMACHINETXT	,		TO 생산 호기명		                                                  
				,CMATNR			              													--CMATNR	,		재단 자재 코드		                                                        
				,PCODE			              													--PCODE	,		지종		                                                                
				,WEIGHT			              													--WEIGHT	,		평량		                                                              
				,WLEN			                													--WLEN	,		가로길		                                                                
				,VLEN			                													--VLEN	,		세로길		                                                                
--				,CTCNT			              													--CTCNT	,		폭수		                                                                
				,CNT			                													--CNT	,		수량		                                                                  
				,CGEWEW			              													--CGEWEW	,		총중량		                                                              
				,CGEWEI			              													--CGEWEI	,		단위		                                                              
--				,ZZATT1			              													--ZZATT1	,		팔레트당연수		                                                          
--				,ZZATT2			              													--ZZATT2	,		속당매수		                                                            
--				,DOUBLEFLAG			          													--DOUBLEFLAG	,		쌍팔레트		                                                        
--				,VBELN			              													--VBELN	,		판매문서		                                                              
--				,POSNR			              													--POSNR	,		판매문서 항목번호		                                                          
--				,SAUART			              													--SAUART	,		판매문서 유형		                                                          
--				,SAUARTXT			            													--SAUARTXT	,		판매 문서 오더 유형 텍스트		                                                
--				,OVBELN			              													--OVBELN	,		판매문서		                                                            
--				,OPOSNR			              													--OPOSNR	,		판매문서 항목번호		                                                        
--				,OAUART			              													--OAUART	,		판매문서 유형		                                                          
--				,OAUARTXT			            													--OAUARTXT	,		판매 문서 오더 유형 텍스트		                                                
--				,CUTTER			              													--CUTTER	,		카터		                                                              
				,STLNR			              													--STLNR	,		BOM Num		                                                            
				,STLAL			              													--STLAL	,		대체Bom		                                                              
--				,BMENG			              													--BMENG	,		모품목기준수량		                                                            
--				,BMEIN			              													--BMEIN	,		모품목기준수량 단위		                                                        
				,DLFL			                													--DLFL	,		오더 삭제 지시자		                                                          
				,ROUTE			              													--ROUTE	,		항차		                                                                
--				,ZCOR                     													--재단출고오더여부                                                                        
				,ORDER_RMK                													--비고                                                                              
				,KUNNR                    													--판매처                                                                             
--				,KUNNRT                   													--판매처명                                                                            
--				,MAUFNR																							--M/R LOT Number                                                                  
				,PTIM                     													--생산 계획 시간 (HHMM)                                                                 
				,PSEQ                     													--IS-M: Production Sequence                                                       
				,WORKGROUP                													--반                                                                               
--                ,MMATNR	       																		--CMATNR	,		원자재 코드		                    
--                ,MAUFNR	       																		--CMATNR	,		원자재LOT		                    
--                ,MBRGEW	       																		--CMATNR	,		원자재중량		                    
--				,MROLLCNT                 													--M/R 권치수                                                                         
--				,MGEWEI                   													--중량 단위                                                                           
--				,CORESIZE                 													--밀롤 지관 인치(SIZE)                                                                  
--				,PACKTYPE                 													--포장타입                                                                            
--				,FRAUFNR                  													--이전오더                                                                            
--				,MWIDTH_INPUT             													--M/R 지폭                                                                          
--				,MRCNT                    													--폭수                                                                              
--				,MCNT                     													--수량                                                                              
--				,SCNT                     													--수량                                                                              
--				,CONTYPE                  													--컨테이너유형                                                                          
				,SIZE_VAL                 													--규격                                                                                

				,REGDATE							    													--등록일자			                                                                      
				,REGID							      													--등록자			                                                                        
				,UPDDATE							    													--수정일자			                                                                    
				,UPDID							      													--수정자			                   		                  
      )                                           					                              
      SELECT                                      					                              
         AUFNR			                											--AUFNR	,		오더번호		                       
--        ,MRPO			                  											--MRPO	,		밀롤 오더 번호		                   
        ,WERKS			                											--WERKS	,		플랜트		                         
        ,BUDAT			                											--BUDAT	,		시작일자		                       
        ,AUART			                											--AUART	,		오더유형		                       
        ,AUARTXT			              											--AUARTXT	,		오더유형 텍스트		                    
        ,MACHINE			              											--MACHINE	,		FROM 생산호기		                 
        ,MACHINETXT			            											--MACHINETXT	,		FROM 생산 호기명		           
--        ,TOMACHINE			            											--TOMACHINE	,		TO 생산호기		                 
--        ,TOMACHINETXT			          											--TOMACHINETXT	,		TO 생산 호기명		           
        ,CMATNR			                											--CMATNR	,		재단 자재 코드		                 
        ,PCODE			                											--PCODE	,		지종		                         
        ,WEIGHT			                											--WEIGHT	,		평량		                       
        ,WLEN			                  											--WLEN	,		가로길		                         
        ,VLEN			                  											--VLEN	,		세로길		                         
--        ,CTCNT			                											--CTCNT	,		폭수		                         
        ,CNT			                  											--CNT	,		수량		                           
        ,CGEWEW			                											--CGEWEW	,		총중량		                       
        ,CGEWEI			                											--CGEWEI	,		단위		                       
--        ,ZZATT1			                											--ZZATT1	,		팔레트당연수		                   
--        ,ZZATT2			                											--ZZATT2	,		속당매수		                     
--        ,DOUBLEFLAG			            											--DOUBLEFLAG	,		쌍팔레트		                 
--        ,VBELN			                											--VBELN	,		판매문서		                       
--        ,POSNR			                											--POSNR	,		판매문서 항목번호		                       
--        ,SAUART			                											--SAUART	,		판매문서 유형		                   
--        ,SAUARTXT			              											--SAUARTXT	,		판매 문서 오더 유형 텍스트		              
--        ,OVBELN			                											--OVBELN	,		판매문서		                     
--        ,OPOSNR			                											--OPOSNR	,		판매문서 항목번호		                   
--        ,OAUART			                											--OAUART	,		판매문서 유형		                   
--        ,OAUARTXT			              											--OAUARTXT	,		판매 문서 오더 유형 텍스트		              
--        ,CUTTER			                											--CUTTER	,		카터		                       
        ,STLNR			                											--STLNR	,		BOM Num		                     
        ,STLAL			                											--STLAL	,		대체Bom		                       
--        ,BMENG			                											--BMENG	,		모품목기준수량		                        
--        ,BMEIN			                											--BMEIN	,		모품목기준수량 단위		                      
        ,DLFL			                  											--DLFL	,		오더 삭제 지시자		                    
        ,ROUTE			                											--ROUTE	,		항차		                         
--        ,ZCOR                       											--재단출고오더여부                                    
        ,REMARK                     											                        --비고                                       
        ,KUNNR                      											--판매처                                      
--        ,NAME1                      											--판매처명                                     
--        ,MAUFNR																						--M/R LOT Number                           
        ,PTIM                       											--생산 계획 시간 (HHMM)                          
        ,PSEQ                       											--IS-M: Production Sequence                
        ,WORKGROUP                  											--반                                        
--        ,MMATNR                     											--원자재 번호                                    
--        ,MRLOT                     											--원자재 LOT                                    
--        ,MBRGEW	       																		--CMATNR	,		원자재중량		                    
--        ,MROLLCNT                   											--M/R 권치수                                  
--        ,MBRGEW                     											--M/ROLL 중량                                
--        ,MGEWEI                     											--중량 단위                                    
--        ,CORESIZE                   											--밀롤 지관 인치(SIZE)                           
--        ,PACKTYPE                   											--포장타입                                     
--        ,FRAUFNR                    											--이전오더                                     
--        ,MWIDTH_INPUT               											--M/R 지폭                                   
--        ,MRCNT                      											--폭수                                       
--        ,MCNT                       											--수량                                       
--        ,SCNT                       											--수량                                       
--        ,CONTYPE                    											--컨테이너유형                                    
        ,SIZE_VAL                   											--규격                                       

        ,sysdate                    											--등록일자                                           
        ,'SP_LAMI_IFR025'                										--등록자                                           
        , null                      											--수정일자                                           
        , null                      											--수정자                                                                
      FROM  TB_LAMI_IFR025
      WHERE  IF_IFR_NO = i_IF_IFR_NO;                      
    END IF; 

DBMS_OUTPUT.PUT_LINE('3' );

    --========================================
    --KHJ추가 2022-05-02:작업지시-재단
    --========================================
    ------------------------------------------
    --작업지시가 존재하지 않으면 작업지시 번호 생성
    SELECT COUNT(ORDER_NO) INTO V_CNT
    FROM TB_LAMI_SL
    WHERE ORDER_NO = i_AUFNR;

    IF V_CNT = 0 THEN
      SELECT BUDAT INTO V_WO_DT
      FROM TB_LAMI_IFR025
      WHERE IF_IFR_NO  =  i_IF_IFR_NO;

      SP_GET_DOC_SEQ('LS',V_WO_DT,V_WO_NO); 
    END IF;
    ------------------------------------------

    IF V_CNT > 0 THEN    
      UPDATE TB_LAMI_SL
      SET(        
--            PRE_ORDER_NO         																--이전 오더 번호
           WERKS                																--플랜트코드
           ,PRD_REQ_DT           																--생산요청일자
           ,ORDER_DIV            																--오더유형
           ,ORDER_DIV_NM         																--오더유형 텍스트
           ,MACHINE              																--FROM 생산호기
--           ,TO_MACHINE           																--TO 생산호기
--           ,TO_MACHINE_NM        																--TO 생산 호기명
           ,MACH_CD               																--생산호기
           ,MATNR                																--자재 코드
           ,PPCODE                																--지종
           ,EQUIL               																--평량
           ,HEIGHT               																--평량
           ,STD               																--평량
           ,VLEN                 																--세로길
           ,WLEN                 																--가로길
--           ,PKCNT                																--폭수
           ,WRK_ORDR_QTY         																--생산지시량
           ,ORDER_QTY         																--생산지시량
           ,REMAIN_QTY              																--총중량
           ,PRFM_QTY
           ,UNIT                 																--단위
--           ,PLT_PER_CNT          																--팔레트당연수
--           ,IN_PER_CNT           																--속당매수
--           ,DBL_FLAG             																--쌍팔레트
--           ,VBELN                																--판매문서
--           ,POSNR                																--판매문서 항목번호
--           ,SAUART_DIV           																--판매문서 유형
--           ,SAUART_NM            																--판매 문서 오더 유형 텍스트
--           ,OVBELN               																--판매문서
--           ,OPOSNR               																--판매문서 항목번호
--           ,OAUART_DIV           																--판매문서 유형
--           ,OAUART_NM            																--판매 문서 오더 유형 텍스트
--           ,CUTTER               																--카터
           ,BOM_NO               																--BOM Num
           ,ATN_BOM_NO           																--대체Bom
--           ,PRT_MATNR_QTY        																--모품목기준수량
--           ,PRT_MATNR_UNIT       																--모품목기준수량 단위
           ,DLFL                 																--오더 삭제 지시자
--           ,ZCOR                 																--재단출고 오더 여부
           ,ORDER_RMK            																--비고
--           ,ROUTE                																--항차
           ,KUNNR                																--판매처
--           ,KUNNRT               																--판매처명
--           ,MAUFNR				  		 																--M/R LOT Number
--           ,PTIM                 																--생산 계획 시간 (HHMM)
--           ,PSEQ                 																--IS-M: Production Sequence
--           ,WORKGROUP            																--반
--           ,MMATNR               																--자재 번호
--           ,MROLLCNT             																--M/R 권치수
--           ,MBRGEW               																--M/ROLL 중량
--           ,MGEWEI               																--중량 단위
--           ,CORESIZE             																--밀롤 지관 인치(SIZE)
--           ,PACKTYPE             																--포장타입
--           ,MWIDTH_INPUT         																--M/R 지폭
--           ,MRCNT                																--폭수
--           ,MCNT                 																--수량
--           ,SCNT                 																--수량
--           ,CONTYPE              																--컨테이너유형
--           ,SIZE_VAL             																--규격   					 
--           ,M_LOT_BUF               																--원자재LOT(Y:사용 N:미사용)
--           ,M_MATNR               																--원자재코드(Y:사용 N:미사용)
--           ,M_ORDER_QTY           																--원자재무게(Y:사용 N:미사용)
           ,UPDDATE              																--수정일시
           ,UPDID                																--수정자ID
           ,USE_YN               																--사용여부(Y:사용 N:미사용)
      )=(SELECT                         										
--            FRAUFNR                        											--이전 오더 번호
           WERKS                          											--플랜트코드
           ,BUDAT                          											--생산요청일자
           ,AUART                          											--오더유형
           ,AUARTXT                        											--오더유형 텍스트
           ,MACHINE                        											--FROM 생산호기
--           ,MACHINETXT                     											--FROM 생산 호기명
--           ,TOMACHINE                      											--TO 생산호기
--           ,TOMACHINETXT                   											--TO 생산 호기명
           ,MACHINE                        											--FROM 생산호기
           ,CMATNR                         											--자재 코드
           ,PCODE                          											--지종
           ,WEIGHT                         											--평량
           ,WLEN                           											--가로길
           ,SIZE_VAL                       											--규격   					 
           ,VLEN                           											--세로길
           ,WLEN                           											--가로길
--           ,CTCNT                          											--폭수
           ,CNT                            											--생산지시량
           ,CGEWEW                         											--총중량
           ,CNT                            											--생산지시량
           ,0
           ,CGEWEI                         											--단위
--           ,ZZATT1                         											--팔레트당연수
--           ,ZZATT2                         											--속당매수
--           ,DOUBLEFLAG                     											--쌍팔레트
--           ,VBELN                          											--판매문서
--           ,POSNR                          											--판매문서 항목번호
--           ,SAUART                         											--판매문서 유형
--           ,SAUARTXT                       											--판매 문서 오더 유형 텍스트
--           ,OVBELN                         											--판매문서
--           ,OPOSNR                         											--판매문서 항목번호
--           ,OAUART                         											--판매문서 유형
--           ,OAUARTXT                       											--판매 문서 오더 유형 텍스트
--           ,CUTTER                         											--카터
           ,STLNR                          											--BOM Num
           ,STLAL                          											--대체Bom
--           ,BMENG                          											--모품목기준수량
--           ,BMEIN                          											--모품목기준수량 단위
           ,DLFL                           											--오더 삭제 지시자
--           ,ZCOR                           											--재단출고 오더 여부
           ,REMARK                         											                        --비고
--           ,ROUTE                          											--항차
           ,KUNNR                          											--판매처
--           ,NAME1                          											--판매처명
--           ,MAUFNR     					  															--M/R LOT Number
--           ,PTIM                           											--생산 계획 시간 (HHMM)
--           ,PSEQ                           											--IS-M: Production Sequence
--           ,WORKGROUP                      											--반
--           ,MMATNR                         											--자재 번호
--           ,MROLLCNT                       											--M/R 권치수
--           ,MBRGEW                         											--M/ROLL 중량
--           ,MGEWEI                         											--중량 단위
--           ,CORESIZE                       											--밀롤 지관 인치(SIZE)
--           ,PACKTYPE                       											--포장타입
--           ,MWIDTH_INPUT                   											--M/R 지폭
--           ,MRCNT                          											--폭수
--           ,MCNT                           											--수량
--           ,SCNT                           											--수량
--           ,CONTYPE                        											--컨테이너유형
--             ,MRLOT                     											--원자재 LOT                                    
--             ,MMATNR                     											--원자재 번호                                    
--             ,MBRGEW	       																		--CMATNR	,		원자재중량		                    
             ,sysdate                               							--수정일시
             ,'SP_LAMI_IFR025'                           						--수정자ID
           ,case when DLFL = 'X' then 'N'  							          
                 when DLFL = 'N' then 'Y'  							
            end                                  								--사용여부(Y:사용 N:미사용)                                                           
         FROM TB_LAMI_IFR025 
         WHERE  IF_IFR_NO = i_IF_IFR_NO      
      )
      WHERE ORDER_NO = i_AUFNR;
--        AND NVL(MAN_CUT_YN,'N') <> 'X';       
    ELSE    
      INSERT INTO TB_LAMI_SL(  
           WRK_ORDR_NO                              					--작업지시번호-->작업지시 생성자 사용 WO + R  
          ,WRK_ORDR_SEQNO                           					--작업지시순번
          ,WRK_SEQNO                                					--작업순서
          ,ORDR_GEN_DT                              					--지시생성일자
          ,ORDER_NO																					  --오더번호
--          ,PRE_ORDER_NO          														--이전 오더 번호
          ,WERKS                 														--플랜트코드
          ,PRD_REQ_DT            														--생산요청일자
          ,ORDER_DIV             														--오더유형
          ,ORDER_DIV_NM          														--오더유형 텍스트
          ,MACHINE               														--FROM 생산호기
--          ,MACHINE_NM            														--FROM 생산 호기명
          ,TO_MACHINE            														--TO 생산호기
--          ,TO_MACHINE_NM         														--TO 생산 호기명
          ,MACH_CD               																--생산호기
          ,MATNR                 														--자재 코드
          ,PPCODE                 														--지종
          ,EQUIL                														--평량
          ,HEIGHT                														--길이
          ,STD                       											--규격   					 
          ,VLEN                  														--세로길
          ,WLEN                  														--가로길
--          ,PKCNT                 														--폭수
          ,WRK_ORDR_QTY          														--생산지시량
          ,ORDER_QTY          														--생산지시량
          ,REMAIN_QTY               														--총중량
          ,PRFM_QTY
          ,UNIT                  														--단위
--          ,PLT_PER_CNT           														--팔레트당연수
--          ,IN_PER_CNT            														--속당매수
--          ,DBL_FLAG              														--쌍팔레트
          ,VBELN                 														--판매문서
          ,POSNR                 														--판매문서 항목번호
--          ,SAUART_DIV            														--판매문서 유형
--          ,SAUART_NM             														--판매 문서 오더 유형 텍스트
--          ,OVBELN                														--판매문서
--          ,OPOSNR                														--판매문서 항목번호
--          ,OAUART_DIV            														--판매문서 유형
--          ,OAUART_NM             														--판매 문서 오더 유형 텍스트
          ,CUTTER                														--카터
          ,BOM_NO                														--BOM Num
          ,ATN_BOM_NO            														--대체Bom
          ,PRT_MATNR_QTY         														--모품목기준수량
          ,PRT_MATNR_UNIT        														--모품목기준수량 단위
          ,DLFL                  														--오더 삭제 지시자
--          ,ZCOR                  														--재단출고 오더 여부
          ,ORDER_RMK                                					--비고
--          ,ROUTE                                    					--항차
          ,KUNNR                                    					--판매처
--          ,KUNNRT                                   					--판매처명
--          ,MAUFNR								  													--M/R LOT Numb
--          ,PTIM                                     					--생산 계획 시간
--          ,PSEQ                                     					--IS-M: Produc
--          ,WORKGROUP                                					--반
--          ,MMATNR                                   					--자재 번호
--          ,MROLLCNT                                 					--M/R 권치수
--          ,MBRGEW                                   					--M/ROLL 중량
--          ,MGEWEI                                   					--중량 단위
--          ,CORESIZE                                 					--밀롤 지관 인치(
--          ,PACKTYPE                                 					--포장타입
--          ,MAN_CUT_YN                               					--수재단여부(6/14 무조건 N으로 처리함)
--          ,MWIDTH_INPUT                             					--M/R 지폭
--          ,MRCNT                                    					--폭수
--          ,MCNT                                     					--수량
--          ,SCNT                                     					--수량
--          ,CONTYPE                                  					--컨테이너유형
--          ,SIZE_VAL                                 					--규격
--          ,M_LOT_BUF               																--사용여부(Y:사용 N:미사용)
--          ,M_MATNR               																--사용여부(Y:사용 N:미사용)
--          ,M_ORDER_QTY           																--원자재무게(Y:사용 N:미사용)
          ,COMP_YN                                  					--완료여부
          ,REGDATE                                  					--등록일시
          ,REGID                                    					--등록자ID
          ,UPDDATE                                  					--수정일시
          ,UPDID                                    					--수정자ID
          ,USE_YN                                   					--사용여부(Y:사용 N:미사용)              
      )                                           					                              
      SELECT                                      					                              
           V_WO_NO														    							--작업지시번호
          ,1                                                   --작업지시순번
          ,SUBSTR(V_WO_NO,-4)                                  --작업순서(작업지시번호,-4)
          ,TO_CHAR(sysdate,'YYYYMMDD')                         --지시생성일자
          ,AUFNR     																		      --오더번호
--          ,FRAUFNR                         										--이전 오더 번호
          ,WERKS                          											--플랜트코드
          ,BUDAT                          											--생산요청일자
          ,AUART                          											--오더유형
          ,AUARTXT                        											--오더유형 텍스트
          ,MACHINE                        											--FROM 생산호기
--          ,MACHINETXT                     											--FROM 생산 호기명
          ,''                      											--TO 생산호기
--          ,TOMACHINETXT                   											--TO 생산 호기명
          ,MACHINE                        											--FROM 생산호기
          ,CMATNR                         											--자재 코드
          ,PCODE                          											--지종
          ,WEIGHT                         											--평량
          ,WLEN                           											--가로길
          ,SIZE_VAL                       											--규격   					 
          ,VLEN                           											--세로길
          ,WLEN                           											--가로길
--          ,CTCNT                          											--폭수
          ,CGEWEW                            											--생산지시량
          ,CGEWEW                         											--총중량
          ,CGEWEW                            											--생산지시량
          ,0
          ,CGEWEI                         											--단위
--          ,ZZATT1                         											--팔레트당연수
--          ,ZZATT2                         											--속당매수
--          ,DOUBLEFLAG                     											--쌍팔레트
          ,''                          											--판매문서
          ,''                          											--판매문서 항목번호
--          ,SAUART                         											--판매문서 유형
--          ,SAUARTXT                       											--판매 문서 오더 유형 텍스트
--          ,OVBELN                         											--판매문서
--          ,OPOSNR                         											--판매문서 항목번호
--          ,OAUART                         											--판매문서 유형
--          ,OAUARTXT                       											--판매 문서 오더 유형 텍스트
          ,0                         											--카터
          ,STLNR                          											--BOM Num
          ,STLAL                          											--대체Bom
          ,''                          											--모품목기준수량
          ,''                          											--모품목기준수량 단위
          ,DLFL                           											--오더 삭제 지시자
--          ,ZCOR                           											--재단출고 오더 여부
          ,REMARK                                       				                                        --오더비고
--          ,ROUTE                                        				--항차
          ,KUNNR                                        				--판매처 
--          ,NAME1                                        				--판매처명
--          ,MAUFNR     																					--M/R LOT Number
--          ,PTIM                           											--생산 계획 시간 (HHMM)
--          ,PSEQ                           											--IS-M: Production Sequence
--          ,WORKGROUP                      											--반
--          ,MMATNR                         											--자재 번호
--          ,MROLLCNT                       											--M/R 권치수
--          ,MBRGEW                         											--M/ROLL 중량
--          ,MGEWEI                         											--중량 단위
--          ,CORESIZE                       											--밀롤 지관 인치(SIZE)
--          ,PACKTYPE                       											--포장타입
--          ,''                                                       --수재단여부(6/14 무조건 N으로 처리함)
--          ,MWIDTH_INPUT                                				--M/R 지폭
--          ,MRCNT                                       				--폭수
--          ,MCNT                                        				--수량
--          ,SCNT                                        				--수량
--          ,CONTYPE                                     				--컨테이너유형
--          ,SIZE_VAL                                    				--규격
--          ,MRLOT                     											--원자재 LOT                                    
--          ,MMATNR                     											--원자재 번호                                    
--          ,MBRGEW	       																		--CMATNR	,		원자재중량		                    
          ,'N'                                                 --완료여부
          ,sysdate                                             --등록일시
          ,'SP_LAMI_IFR025'                                         --등록자ID
          ,null                                                --수정일시
          ,null                                                --수정자ID 
          ,case when DLFL = 'X' then 'N'
               else 'Y'
          end                                                 --사용여부(Y:사용 N:미사용)                                      
      FROM  TB_LAMI_IFR025
      WHERE  IF_IFR_NO = i_IF_IFR_NO;                      
    END IF;  


    --작업지시 생성되면 작업지시BOM을 구성한다. 
    --작업지시정보 추출
    SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, WERKS INTO V_WO_NO,V_WO_SEQ,V_WERKS
    FROM TB_LAMI_SL
    WHERE ORDER_NO = i_AUFNR;
--    AND NVL(MAN_CUT_YN,'N') <> 'X';

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
            ,'SP_LAMI_IFR024'
            ,null
            ,null
      FROM TB_SCH001          
      WHERE  AUFNR  =  i_AUFNR;       
    END IF;                          

DBMS_OUTPUT.PUT_LINE('AAAA' );


    o_msg_MSG  :=  'TB_LAMI_IFR025, 생산오더-라미네이팅 슬리팅이 수신되었습니다.1'; -- || ',' || SQLERRM ;

DBMS_OUTPUT.PUT_LINE('BBB' );
    UPDATE  TB_LAMI_IFR025
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    AUFNR     =  i_AUFNR
    AND    IF_IFR_NO =  i_IF_IFR_NO    
    ;
DBMS_OUTPUT.PUT_LINE('CCC' );
    o_msg_MSG  :=  'TB_LAMI_IFR025, 생산오더-라미네이팅 슬리팅이 수신되었습니다.2'; -- || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
                o_msg_MSG  :=  'TB_LAMI_IFR025, 생산오더-라미네이팅 슬리팅 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                o_msg_code      := '-1' ;
                DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                ROLLBACK;

                UPDATE  TB_LAMI_IFR025
                SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                      , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                      , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
                WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
                AND    AUFNR     =  i_AUFNR
                AND    IF_IFR_NO =  i_IF_IFR_NO    
                ;
END;

/
