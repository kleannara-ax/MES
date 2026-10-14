--------------------------------------------------------
--  DDL for Procedure SP_SCH_GET_IFR_MULTI_MANUAL_AUTO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SCH_GET_IFR_MULTI_MANUAL_AUTO" (  i_IF_MES_ID        IN    VARCHAR2
                                                                    ,o_msg_CODE         OUT   VARCHAR2
                                                                    ,o_msg_MSG          OUT   VARCHAR2
) is


/*==============================================================================
 * PROGRAM ID    : 인터페이스
 * PROGRAM NAME  : 생산오더 수신
 * VERSION       : 1.0.0
 * DESCRIPTION   : 생산오더 수신
 *                 
 * AUTHOR NAME   : 강현주
 * CREATE DATE   : 2022/07/29
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/07/29    1.0.0   강현주         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        인터페이스설계서(총괄표) 참조
 *=============================================================================*/



----------------------------------------------------[작업지시번호 생성규칙]--------------------------------------------------
--22-06-16 아래와 같이 작업지시 생성시 구분자로 활용하는것으로 결정 함.
--화장지 합지 : AA
--화장지 가공 : RA
--생리대     : RB
--기저귀     : RC
--
--점보롤 : JA
--밀롤 : MA
--재단 : CA
--포장 : PA
--예외생산: ?
--------------------------------------------------------------------------------------------------------------------------------

/* ------- TB_IFR014 : 생산오더 BOM Begin -------------------------------- */
CURSOR  cur_ifr014 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  AUFNR
       ,  POSNR
       ,  MATNR
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM    TB_IFR014
  WHERE   IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  ORDER  BY IF_GET_DATE  
  ;
/* ------- TB_IFR014 : 생산오더 BOM End --------------------------------- */

/* ------- TB_IFR015 : 생산오더-화장지초지  Begin ------------------------- */
CURSOR  cur_ifr015 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  AUFNR
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM    TB_IFR015_TMP
  WHERE   IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  ORDER  BY IF_GET_DATE  
  ;
/* ------- TB_IFR015 : 생산오더-화장지초지  End --------------------------- */

/* ------- TB_IFR016 : 생산오더-화장지가공  Begin ------------------------- */
CURSOR  cur_ifr016 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  AUFNR
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM    TB_IFR016_TMP
  WHERE   IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  ORDER  BY IF_GET_DATE 
  ;
/* ------- TB_IFR016 : 생산오더-화장지가공  End --------------------------- */

/* ------- TB_IFR017 : 생산오더-패드  Begin ------------------------------ */
CURSOR  cur_ifr017 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  AUFNR
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM    TB_IFR017_TMP
  WHERE   IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  ORDER  BY IF_GET_DATE  
  ;
/* ------- TB_IFR017 : 생산오더-패드  End -------------------------------- */

/* ------- TB_IFR018 : 생산오더-점보롤  Begin ---------------------------- */
CURSOR  cur_ifr018 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  AUFNR
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM    TB_IFR018_TMP
  WHERE   IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  ORDER  BY IF_GET_DATE 
  ;
/* ------- TB_IFR018 : 생산오더-점보롤  End ------------------------------ */

/* ------- TB_IFR019 : 생산오더-밀롤,슬리터  Begin ------------------------ */
CURSOR  cur_ifr019 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  AUFNR
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM    TB_IFR019_TMP
  WHERE   IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  ORDER  BY IF_GET_DATE 
  ;
/* ------- TB_IFR019 : 생산오더-밀롤,슬리터  End -------------------------- */

/* ------- TB_IFR020 : 생산오더-재단  Begin ------------------------------ */
CURSOR  cur_ifr020 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  AUFNR
       ,  ZCOR
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM    TB_IFR020_TMP
  WHERE   IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  ORDER  BY IF_GET_DATE  
  ;
/* ------- TB_IFR020 : 생산오더-재단 End --------------------------------- */

/* ------- TB_IFR021 : 생산오더-포장  Begin ------------------------------ */
CURSOR  cur_ifr021 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  AUFNR
       ,  PACKSEQ
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM    TB_IFR021_TMP
  WHERE   IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  ORDER  BY IF_GET_DATE 
  ;
/* ------- TB_IFR021 : 생산오더-포장  End -------------------------------- */

/* ------- TB_IFR022 : 생산오더-예외생산  Begin ------------------------------ */
CURSOR  cur_ifr022 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  AUFNR
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM    TB_IFR022_TMP
  WHERE   IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  ORDER  BY IF_GET_DATE  
  ;
/* ------- TB_IFR022 : 생산오더-예오생산  Begin ------------------------------ */




/* ------- TB_IFR014 : 생산오더 BOM Begin -------------------------------- */
PROCEDURE sp_ifr014 (  i_IF_IFR_NO      IN   NUMBER   /* MES Interface Sequence(수신번호)        */
                      ,i_AUFNR          IN   VARCHAR2
                      ,i_POSNR          IN   VARCHAR2
                      ,i_MATNR          IN   VARCHAR2
                      ,o_msg_CODE       OUT  VARCHAR2
                      ,o_msg_MSG        OUT  VARCHAR2  ) is
  V_CNT             NUMBER    DEFAULT 0;
  V_BOM_CNT         NUMBER    DEFAULT 0;

  V_WO_CNT          NUMBER    DEFAULT 0;    

  V_WERKS           VARCHAR2(100)  DEFAULT '';
  V_WO_NO           VARCHAR2(100)  DEFAULT '';
  V_WO_SEQ          NUMBER         DEFAULT 0;
  V_MATNR           VARCHAR2(100)  DEFAULT '';  

  V_ORDER_NO        VARCHAR2(100)  DEFAULT '';
  V_ORDER_ITEM_NO   VARCHAR2(100)  DEFAULT '';                 
BEGIN


    --데이트량증가로 인한 속도저하 개선
    SELECT COUNT(MATNR) INTO V_CNT 
    FROM TB_SCH001 
    WHERE AUFNR = i_AUFNR 
    AND POSNR = i_POSNR
    AND MATNR = i_MATNR; 

    IF V_CNT > 0 THEN
           UPDATE TB_SCH001
           SET(     BDMNG				                 /*		오더BOM 수량					            */
                  ,	MEINS				                 /*		오더BOM 수량단위					          */
                  , LGORT                         /*     저장위치                          */
                  , LOT_NO                        --LOT번호
                  ,	XLOEK				                 /*		삭제여부					                */

                  , UPDDATE                        /* 수정일자-KHJ:EDIT_DATE->UPDDATE                   */
                  , UPDID                          /* 수정자-KHJ:EDITOR->UPDID                           */
           )=
           (SELECT  BDMNG				                 /*		오더BOM 수량					            */
                  ,	MEINS				                 /*		오더BOM 수량단위					          */
                  , LGORT                         /*   저장위치                          */
                  , CHARG                         --LOT번호
                  ,	case when XLOEK = 'X' then 'Y'
                         else 'N'                           
                    end				                 /*		삭제여부					                */

                  , sysdate                      		/* 수정일자-KHJ:EDIT_DATE->UPDDATE                   */
                  , 'sp_ifr014'                  				/* 수정자-KHJ:EDITOR->UPDID                           */
            FROM TB_IFR014_TMP
            WHERE  IF_IFR_NO =  i_IF_IFR_NO
           )
          WHERE AUFNR = i_AUFNR 
          AND POSNR = i_POSNR
          AND MATNR = i_MATNR;               

    ELSE
           INSERT INTO TB_SCH001 
           (        AUFNR				                 /*		오더번호					                */
                  ,	POSNR				                 /*		오더Item번호					            */
                  ,	MATNR				                 /*		자품목자재					                */
                  ,	BDMNG				                 /*		오더BOM 수량					            */
                  ,	MEINS				                 /*		오더BOM 수량단위					          */
                  , LGORT                         /*     저장위치                          */
                  , LOT_NO                        --LOT번호
                  ,	XLOEK				                 /*		삭제여부					                */

                  , REGDATE                       /*     등록일자                       */
                  , REGID                         /*     등록자                        */
                  , UPDDATE                       /*     수정일자                       */
                  , UPDID                         /*     수정자                        */                   
           )
           SELECT   AUFNR				                 /*		오더번호					                */
                  ,	POSNR				                 /*		오더Item번호					            */
                  ,	MATNR				                 /*		자품목자재					                */
                  ,	BDMNG				                 /*		오더BOM 수량					            */
                  ,	MEINS				                 /*		오더BOM 수량단위					          */
                  , LGORT                         /*   저장위치                          */
                  , CHARG                         --LOT번호
                  ,	case when XLOEK = 'X' then 'Y'
                         else 'N'                           
                    end				                 /*		삭제여부					                */

                  , sysdate
                  , 'sp_ifr014'
                  , null
                  , null
           FROM TB_IFR014          
           WHERE  IF_IFR_NO  =  i_IF_IFR_NO     
           ;

    END IF;


    --작업지시를 찾아서 작업지시BOM을 생성 한다. 2022-06-22추가          
    SELECT count(X.WERKS) INTO V_WO_CNT
    FROM (
      SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_SCH011 WHERE ORDER_NO = i_AUFNR AND USE_YN = 'Y'
      UNION
      SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_SCH012 WHERE ORDER_NO = i_AUFNR AND USE_YN = 'Y'
      UNION
      SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_SCH013 WHERE ORDER_NO = i_AUFNR AND USE_YN = 'Y'
      UNION
      SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_SCH014 WHERE ORDER_NO = i_AUFNR AND USE_YN = 'Y'
      UNION
      SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_SCH015 WHERE ORDER_NO = i_AUFNR AND USE_YN = 'Y'
      UNION
      SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_SCH016 WHERE ORDER_NO = i_AUFNR AND USE_YN = 'Y'
      UNION
      SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_SCH017 WHERE ORDER_NO = i_AUFNR AND USE_YN = 'Y'
      UNION
      SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_SCH018 WHERE ORDER_NO = i_AUFNR AND USE_YN = 'Y'
      UNION
      SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_SCH019 WHERE ORDER_NO = i_AUFNR  AND USE_YN = 'Y') X;

    IF V_WO_CNT > 0 THEN

      --작업지시정보 추출
      SELECT NVL(X.WERKS,''), NVL(X.WRK_ORDR_NO,''), NVL(X.WRK_ORDR_SEQNO,'')
      INTO V_WERKS, V_WO_NO, V_WO_SEQ
      FROM (
        SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_SCH011 WHERE ORDER_NO = i_AUFNR
        UNION
        SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_SCH012 WHERE ORDER_NO = i_AUFNR
        UNION
        SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_SCH013 WHERE ORDER_NO = i_AUFNR
        UNION
        SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_SCH014 WHERE ORDER_NO = i_AUFNR
        UNION
        SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_SCH015 WHERE ORDER_NO = i_AUFNR
        UNION
        SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_SCH016 WHERE ORDER_NO = i_AUFNR
        UNION
        SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_SCH017 WHERE ORDER_NO = i_AUFNR
        UNION
        SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_SCH018 WHERE ORDER_NO = i_AUFNR
        UNION
        SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_SCH019 WHERE ORDER_NO = i_AUFNR) X;    


      SELECT MATNR INTO V_MATNR
      FROM TB_IFR014_TMP
      WHERE  IF_IFR_NO =  i_IF_IFR_NO;  

      SELECT COUNT(WERKS) INTO V_BOM_CNT 
      FROM TB_SCH020 
      WHERE WERKS = V_WERKS
      AND WRK_ORDR_NO = V_WO_NO
      AND WRK_ORDR_SEQNO = V_WO_SEQ
      AND MATNR = V_MATNR;

      --작업지시BOM이 존재하지 않으면 생산BOM->작업지시BOM을 생성 한다.
      --동일오더에 동일아이템이 1개이상 내려오면 SUM 한다.
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
              ,CHARG                         --LOT번호            
              ,LGORT                         /*   저장위치                          */
              ,case when XLOEK = 'X' then 'Y'
                    else 'N'                           
               end				                 /*		삭제여부					                */
              ,V_WERKS
              ,V_WO_NO
              ,V_WO_SEQ  

              ,sysdate
              ,'sp_ifr014'
              ,null
              ,null
        FROM TB_IFR014_TMP
        WHERE  IF_IFR_NO =  i_IF_IFR_NO; 
    /*        
       ELSE  --SUM하는 부분은 결정이 필요한 사항으로 보류 함.  22-06-24        
        UPDATE TB_SCH020
        SET ORDER_BOM_QTY = NVL(ORDER_BOM_QTY,0) + (SELECT NVL(BDMNG,0) FROM TB_IFR014 WHERE  IF_IFR_NO =  i_IF_IFR_NO)
        WHERE WERKS = V_WERKS
        AND WRK_ORDR_NO = V_WO_NO
        AND WRK_ORDR_SEQNO = V_WO_SEQ
        AND MATNR = V_MATNR; 
        */ 

      END IF; --//End Of IF V_WO_CNT > 0 THEN       
    END IF;


    o_msg_MSG  :=  'TB_IFR014, 생산오더 BOM 수신되었습니다.1' || ',' || SQLERRM ;

    UPDATE  TB_IFR014_TMP
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    POSNR     =  i_POSNR
    AND    AUFNR     =  i_AUFNR
    AND    IF_IFR_NO =  i_IF_IFR_NO
    ;

    o_msg_MSG  :=  'TB_IFR014, 생산오더 BOM 수신되었습니다.2' || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
                o_msg_MSG  :=  'TB_IFR014, 생산오더 BOM 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                o_msg_code      := '-1' ;
                DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                ROLLBACK;

                UPDATE  TB_IFR014_TMP
                SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                      , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                      , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
                WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
                AND    POSNR     =  i_POSNR
                AND    AUFNR     =  i_AUFNR
                AND    IF_IFR_NO =  i_IF_IFR_NO
                ;

END  sp_ifr014 ;
/* ------- TB_IFR014 : 생산오더 BOM End ----------------------------------- */

/* ------- TB_IFR015 : 생산오더-화장지초지  Begin ------------------------- */
PROCEDURE sp_ifr015 (  i_IF_IFR_NO      IN   NUMBER   /* MES Interface Sequence(수신번호)        */
                      ,i_AUFNR          IN   VARCHAR2
                      ,o_msg_CODE       OUT  VARCHAR2
                      ,o_msg_MSG        OUT  VARCHAR2  ) is

  V_CNT           NUMBER          := 0;      -- 카운트(작업지시존재여부) 
  V_BOM_CNT       NUMBER          := 0;      -- 카운트(작업지시BOM존재여부)

  V_WO_DT         VARCHAR2(50)    := '';      -- 지시일자(작업지시생성하기 위해서..)  

  V_WO_NO         VARCHAR2(50)    := '';      -- 작업지시번호 (작업지시BOM생성을 위해서..)  
  V_WO_SEQ        NUMBER          := 0;      --작업지시순번 (작업지시BOM생성을 위해서..)  
  V_WERKS         VARCHAR2(50)    := '';      -- 플랜트 (작업지시BOM생성을 위해서..)   

  V_DLFL          VARCHAR2(50)    := '';      -- 삭제FLAG  
BEGIN


    SELECT NVL(DLFL,' ') INTO V_DLFL
    FROM TB_IFR015_TMP
    WHERE AUFNR = i_AUFNR
    AND IF_IFR_NO = i_IF_IFR_NO;    

    IF V_DLFL = 'X' THEN
      UPDATE TB_SCH002
      SET DLFL = V_DLFL
      WHERE AUFNR =  i_AUFNR;

      UPDATE TB_SCH011
      SET USE_YN = 'N'
      WHERE ORDER_NO =  i_AUFNR;             

      o_msg_MSG  :=  'TB_IFR015, 생산오더-화장지초지 삭제 수신되었습니다.1' || ',' || SQLERRM ;

      UPDATE  TB_IFR015_TMP
      SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
            , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
            , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
      WHERE  AUFNR     =  i_AUFNR
      AND    IF_IFR_NO =  i_IF_IFR_NO           
      ;

      o_msg_MSG  :=  'TB_IFR015, 생산오더-화장지초지 삭제 수신되었습니다.2' || ',' || SQLERRM ;
      o_msg_code := '0' ;
      RETURN;    
    END IF;


    --생산오더 
    MERGE
        INTO  TB_SCH002 SCH002
        USING TB_IFR015_TMP IFR015
           ON ( SCH002.AUFNR      =  IFR015.AUFNR
           AND  IFR015.AUFNR      =  i_AUFNR 
           AND  IFR015.IF_IFR_NO  =  i_IF_IFR_NO   )
    WHEN MATCHED THEN
         UPDATE
         SET    	SCH002.WERKS			=	IFR015.WERKS			           /*		플랜트				                   */
                ,	SCH002.GSTRP			=	IFR015.GSTRP			           /*		시작일자				                 */
                --,	SCH002.GLTRP			=	IFR015.GLTRP			           /*		종료일자				                 */
                --,	SCH002.AUART			=	IFR015.AUART			           /*		오더유형				                 */
                --,	SCH002.AUARTXT		=	IFR015.AUARTXT			         /*		오더유형 텍스트				           */
                ,	SCH002.MATNR			=	IFR015.MATNR			           /*		제품코드				                 */
                ,	SCH002.FQTY			  =	IFR015.FQTY			             /*		생산지시량				                 */
                ,	SCH002.MEINS			=	IFR015.MEINS			           /*		생산지시단위				               */
                ,	SCH002.AENAM			=	IFR015.AENAM			           /*		작업지시자				                 */
                ,	SCH002.PRCMC			=	IFR015.PRCMC			           /*		가공호기				                 */
                ,	SCH002.MACHINE		=	IFR015.MACHINE			         /*		생산호기				                 */
                ,	SCH002.STLNR			=	IFR015.STLNR			           /*		BOM Num				                  */
                ,	SCH002.STLAL			=	IFR015.STLAL			           /*		대체Bom				                   */
                ,	SCH002.BMENG			=	IFR015.BMENG			           /*		모품목기준수량				              */
                ,	SCH002.BMEIN			=	IFR015.BMEIN			           /*		모품목기준수량 단위				         */
                --,	SCH002.FTRMI			=	IFR015.FTRMI			           /*		릴리즈일자				                 */
                --,	SCH002.VBELN			=	IFR015.VBELN			           /*		판매문서번호				               */
                --,	SCH002.POSNR			=	IFR015.POSNR			           /*		판매문서Item번호				           */
                ,	SCH002.SPEC1			=	IFR015.SPEC1			           /*		규격				                      */
                ,	SCH002.WDTH1			=	IFR015.WDTH1			           /*		폭수				                      */
                ,	SCH002.PUPOS			=	IFR015.PUPOS			           /*		용도				                      */
                ,	SCH002.PUPNM			=	IFR015.PUPNM			           /*		용도내역				                   */
                --,	SCH002.LMNGA			=	IFR015.LMNGA			           /*		생산실적수량				                */
                --,	SCH002.MEINS2			=	IFR015.MEINS2			           /*		단위				                      */
                --,	SCH002.BUDAT			=	IFR015.BUDAT			           /*		생산일				                      */
                ,	SCH002.REMRK			=	IFR015.REMRK			           /*		비고				                       */
                ,	SCH002.DLFL			  =	IFR015.DLFL			             /*		오더 삭제 지시자				              */
                , SCH002.REM        = IFR015.REM                   /*    반복생산 지시자                      */
                , SCH002.SEQ        = IFR015.SEQ                    --작업순서

                , SCH002.UPDDATE    = sysdate                      /*    수정일자                             */
                , SCH002.UPDID      = 'sp_ifr015'                  /*    수정자                               */
          WHERE  IFR015.IF_STATUS in ('N','E')                     /*  I/F상태, N:신규, S:성공, E:오류        */
          AND    IFR015.AUFNR     =  i_AUFNR
          AND    IFR015.IF_IFR_NO =  i_IF_IFR_NO   
    WHEN NOT MATCHED THEN
         INSERT (  	SCH002.AUFNR			                             /*		오더번호				                      */
                  ,	SCH002.WERKS			                             /*		플랜트				                        */
                  ,	SCH002.GSTRP			                             /*		시작일자				                      */
                  --,	SCH002.GLTRP			                             /*		종료일자				                      */
                  --,	SCH002.AUART			                             /*		오더유형				                      */
                  --,	SCH002.AUARTXT			                           /*		오더유형 텍스트				                  */
                  ,	SCH002.MATNR			                             /*		제품코드				                      */
                  ,	SCH002.FQTY			                               /*		생산지시량				                      */
                  ,	SCH002.MEINS			                             /*		생산지시단위				                    */
                  ,	SCH002.AENAM			                             /*		작업지시자				                      */
                  ,	SCH002.PRCMC			                             /*		가공호기				                      */
                  ,	SCH002.MACHINE			                           /*		생산호기				                      */
                  ,	SCH002.STLNR			                             /*		BOM Num				                       */
                  ,	SCH002.STLAL			                             /*		대체Bom				                        */
                  ,	SCH002.BMENG			                             /*		모품목기준수량				                   */
                  ,	SCH002.BMEIN			                             /*		모품목기준수량 단위				              */
                  --,	SCH002.FTRMI			                             /*		릴리즈일자				                       */
                  --,	SCH002.VBELN			                             /*		판매문서번호				                    */
                  --,	SCH002.POSNR			                             /*		판매문서Item번호				                */
                  ,	SCH002.SPEC1			                             /*		규격				                           */
                  ,	SCH002.WDTH1			                             /*		폭수				                           */
                  ,	SCH002.PUPOS			                             /*		용도				                           */
                  ,	SCH002.PUPNM			                             /*		용도내역				                        */
                  --,	SCH002.LMNGA			                             /*		생산실적수량				                     */
                  --,	SCH002.MEINS2			                             /*		단위				                           */
                  --,	SCH002.BUDAT			                             /*		생산일				                           */
                  ,	SCH002.REMRK			                             /*		비고				                           */
                  ,	SCH002.DLFL			                               /*		오더 삭제 지시자				                  */
                  , SCH002.REM                                     /*    반복생산 지시자                          */
                  , SCH002.WRK_CD                                   --작업장코드
                  , SCH002.SEQ                                      --작업순서

                  , SCH002.REGDATE                                 /*    등록일자                                */
                  , SCH002.REGID                                   /*    등록자                                 */
                  , SCH002.UPDDATE                                 /*    수정일자                                */
                  , SCH002.UPDID                                   /*    수정자                                 */
                    )
         VALUES (   IFR015.AUFNR			                             /*		오더번호				                        */
                  ,	IFR015.WERKS			                             /*		플랜트				                           */
                  ,	IFR015.GSTRP			                             /*		시작일자				                         */
                  --,	IFR015.GLTRP			                             /*		종료일자				                         */
                  --,	IFR015.AUART			                             /*		오더유형				                         */
                  --,	IFR015.AUARTXT			                           /*		오더유형 텍스트				                   */
                  ,	IFR015.MATNR			                             /*		제품코드				                         */
                  ,	IFR015.FQTY			                               /*		생산지시량				                         */
                  ,	IFR015.MEINS			                             /*		생산지시단위				                      */
                  ,	IFR015.AENAM			                             /*		작업지시자				                         */
                  ,	IFR015.PRCMC			                             /*		가공호기				                          */
                  ,	IFR015.MACHINE			                           /*		생산호기				                          */
                  ,	IFR015.STLNR			                             /*		BOM Num				                          */
                  ,	IFR015.STLAL			                             /*		대체Bom				                           */
                  ,	IFR015.BMENG			                             /*		모품목기준수량				                      */
                  ,	IFR015.BMEIN			                             /*		모품목기준수량 단위				                 */
                  --,	IFR015.FTRMI			                             /*		릴리즈일자				                         */
                  --,	IFR015.VBELN			                             /*		판매문서번호				                       */
                  --,	IFR015.POSNR			                             /*		판매문서Item번호				                   */
                  ,	IFR015.SPEC1			                             /*		규격				                              */
                  ,	IFR015.WDTH1			                             /*		폭수				                              */
                  ,	IFR015.PUPOS			                             /*		용도				                              */
                  ,	IFR015.PUPNM			                             /*		용도내역				                           */
                  --,	IFR015.LMNGA			                             /*		생산실적수량				                        */
                  --,	IFR015.MEINS2			                             /*		단위				                              */
                  --,	IFR015.BUDAT			                             /*		생산일				                              */
                  ,	IFR015.REMRK			                             /*		비고				                              */
                  ,	IFR015.DLFL			                               /*		오더 삭제 지시자				                     */
                  , IFR015.REM                                     /*    반복생산 지시자                             */
                  , IFR015.ARBPL                                    --작업장코드
                  , IFR015.SEQ                                      --작업순서

                  , sysdate                                        /*    등록일자                                   */
                  , 'sp_ifr015'                                    /*    등록자                                     */
                  , null                                           /*    수정일자                                   */
                  , null                                           /*    수정자                                     */
                    )
         WHERE  IFR015.IF_STATUS in ('N','E')  /*  I/F상태, N:신규, S:성공, E:오류   */
         AND    IFR015.AUFNR     =  i_AUFNR
         AND    IFR015.IF_IFR_NO =  i_IF_IFR_NO   
         ;

    --========================================
    --KHJ추가 2022-04-27:작업지시-초지
    --========================================
    ------------------------------------------
    --작업지시가 존재하지 않으면 작업지시 번호 생성
    SELECT COUNT(ORDER_NO) INTO V_CNT
    FROM TB_SCH011
    WHERE ORDER_NO = i_AUFNR;

    IF V_CNT = 0 THEN
      SELECT GSTRP INTO V_WO_DT
      FROM TB_IFR015_TMP
      WHERE IF_IFR_NO  =  i_IF_IFR_NO;

      SP_GET_DOC_SEQ('WOAA',V_WO_DT,V_WO_NO); 
    END IF;

    ------------------------------------------

    MERGE
        INTO  TB_SCH011 SCH011
        USING TB_IFR015_TMP IFR015
           ON ( SCH011.ORDER_NO   =  IFR015.AUFNR
           AND  IFR015.AUFNR      =  i_AUFNR 
           AND  IFR015.IF_IFR_NO  =  i_IF_IFR_NO   )
    WHEN MATCHED THEN    
        UPDATE SET
					  SCH011.WERKS         = IFR015.WERKS                                 --플랜트코드     
					 ,SCH011.PRD_REQ_DT    = IFR015.GSTRP                                 --생산요청일자    
					 ,SCH011.ORDER_DIV     = IFR015.AUART                                 --오더유형      
					 ,SCH011.ORDER_DIV_NM  = IFR015.AUARTXT                               --오더유형 텍스트  
					 ,SCH011.MATNR         = IFR015.MATNR                                 --제품코드      
					 ,SCH011.WRK_ORDR_QTY  = IFR015.FQTY                                  --생산지시량     
					 ,SCH011.UNIT          = IFR015.MEINS                                 --생산지시단위    
					 ,SCH011.WRK_CD        = IFR015.ARBPL                                 --작업장코드     
					 ,SCH011.WORK_ORDER    = IFR015.AENAM                                 --작업지시자     
					 ,SCH011.MACHINE       = IFR015.PRCMC                                 --생산호기      
					 ,SCH011.BOM_NO        = IFR015.STLNR                                 --BOM Num   
					 ,SCH011.ATN_BOM_NO    = IFR015.STLAL                                 --대체Bom     
					 ,SCH011.PRT_MATNR_QTY = IFR015.BMENG                                 --모품목기준수량   
					 ,SCH011.PRT_MATNR_UNIT= IFR015.BMEIN                                 --모품목기준수량 단위
					 ,SCH011.RES_DT        = IFR015.FTRMI                                 --릴리즈일자     
					 ,SCH011.SPEC          = IFR015.SPEC1                                 --규격        
					 ,SCH011.WIDTH_CNT     = IFR015.WDTH1                                 --폭수        
					 ,SCH011.PUPOS         = IFR015.PUPOS                                 --용도        
					 ,SCH011.PUPNM         = IFR015.PUPNM                                 --용도내역      
					 ,SCH011.ORDER_RMK     = IFR015.REMRK                                 --오더비고      
					 ,SCH011.DLFL          = IFR015.DLFL                                  --오더 삭제 지시자 
					 ,SCH011.VBELN         = IFR015.VBELN                                 --판매문서번호    
					 ,SCH011.POSNR         = IFR015.POSNR                                 --판매문서Item번호
					 ,SCH011.REM           = IFR015.REM                                   --반복생산지시자
					 ,SCH011.ORDER_QTY     = IFR015.FQTY                                  --오더수량   
					 ,SCH011.ORDER_SEQNO   = IFR015.SEQ                                   --작업순서

           ,SCH011.UPDDATE              = sysdate                               --수정일시
           ,SCH011.UPDID                = 'sp_ifr015'                           --수정자ID
           ,SCH011.USE_YN               =  case when IFR015.DLFL = 'Y' then 'N'            
                                                when IFR015.DLFL = 'N' then 'Y'
                                           end                                  --사용여부(Y:사용 N:미사용)	           
        WHERE IFR015.IF_STATUS in ('N','E')                                     --I/F상태, N:신규, S:성공, E:오류                
        AND   IFR015.AUFNR     =  i_AUFNR
        AND   IFR015.IF_IFR_NO =  i_IF_IFR_NO
    WHEN NOT MATCHED THEN
        INSERT (
            SCH011.WRK_ORDR_NO                                                  --작업지시번호-->작업지시 생성자 사용 WO + R    
           ,SCH011.WRK_ORDR_SEQNO                                               --작업지시순번
           ,SCH011.WRK_SEQNO                                                    --작업순서
           ,SCH011.ORDR_GEN_DT                                                  --지시생성일자

					 ,SCH011.ORDER_NO      																								--오더번호                 
					 ,SCH011.WERKS                                                        --플랜트코드                
					 ,SCH011.PRD_REQ_DT                                                   --생산요청일자               
					 ,SCH011.ORDER_DIV                                                    --오더유형                 
					 ,SCH011.ORDER_DIV_NM                                                 --오더유형 텍스트             
					 ,SCH011.MATNR                                                        --제품코드                 
					 ,SCH011.WRK_ORDR_QTY                                                 --생산지시량                
					 ,SCH011.UNIT                                                         --생산지시단위               
					 ,SCH011.WRK_CD                                                       --작업장코드 
					 ,SCH011.MACH_CD                                                      --설비코드               
					 ,SCH011.WORK_ORDER                                                   --작업지시자                
					 ,SCH011.MACHINE                                                      --생산호기                 
					 ,SCH011.BOM_NO                                                       --BOM Num              
					 ,SCH011.ATN_BOM_NO                                                   --대체Bom                
					 ,SCH011.PRT_MATNR_QTY                                                --모품목기준수량              
					 ,SCH011.PRT_MATNR_UNIT                                               --모품목기준수량 단위           
					 ,SCH011.RES_DT                                                       --릴리즈일자                
					 ,SCH011.SPEC                                                         --규격                   
					 ,SCH011.WIDTH_CNT                                                    --폭수                   
					 ,SCH011.PUPOS                                                        --용도                   
					 ,SCH011.PUPNM                                                        --용도내역                 
					 ,SCH011.ORDER_RMK                                                    --오더비고                                
					 ,SCH011.DLFL                                                         --오더 삭제 지시자            
					 ,SCH011.VBELN                                                        --판매문서번호               
					 ,SCH011.POSNR                                                        --판매문서Item번호  
					 ,SCH011.REM                                                          --반복생산지시자
					 ,SCH011.ORDER_QTY                                                    --오더수량
					 ,SCH011.ORDER_SEQNO                                                  --오더순번

           ,SCH011.COMP_YN                                                      --완료여부
           ,SCH011.REGDATE                                                      --등록일시
           ,SCH011.REGID                                                        --등록자ID
           ,SCH011.UPDDATE                                                      --수정일시
           ,SCH011.UPDID                                                        --수정자ID
           ,SCH011.USE_YN                                                       --사용여부(Y:사용 N:미사용)
        )VALUES(
            V_WO_NO														                                  --작업지시번호       
           ,CAST(IFR015.SEQ AS INTEGER)                                         --작업지시순번
           ,IFR015.SEQ                                                          --작업순서( 22-06-13:1-> 오더순서로 변경요청으로 변경함.
           ,TO_CHAR(sysdate,'YYYYMMDD')                                          --지시생성일자           

					 ,IFR015.AUFNR     				 										 											  --오더번호              
					 ,IFR015.WERKS                                 											  --플랜트코드            
					 ,IFR015.GSTRP                                 											  --생산요청일자           
					 ,IFR015.AUART                                 											  --오더유형             
					 ,IFR015.AUARTXT                               											  --오더유형 텍스트         
					 ,IFR015.MATNR                                 											  --제품코드             
					 ,IFR015.FQTY                                  											  --생산지시량            
					 ,IFR015.MEINS                                 											  --생산지시단위           
					 ,IFR015.ARBPL                                 											  --작업장코드  
           ,(SELECT M012.MACH_CD FROM TB_MAS012 M012,TB_MAS013 M013 WHERE M012.PROC_CD = M013.PROC_CD(+) AND M012.SAP_WRK_CD = IFR015.ARBPL AND M013.WERKS = IFR015.WERKS AND ROWNUM = 1) --설비코드
					 ,IFR015.AENAM                                 											  --작업지시자            
					 ,IFR015.PRCMC                                 											  --생산호기             
					 ,IFR015.STLNR                                 											  --BOM Num          
					 ,IFR015.STLAL                                 											  --대체Bom            
					 ,IFR015.BMENG                                 											  --모품목기준수량          
					 ,IFR015.BMEIN                                 											  --모품목기준수량 단위       
					 ,IFR015.FTRMI                                 											  --릴리즈일자            
					 ,IFR015.SPEC1                                 											  --규격               
					 ,IFR015.WDTH1                                 											  --폭수               
					 ,IFR015.PUPOS                                 											  --용도               
					 ,IFR015.PUPNM                                 											  --용도내역             
					 ,IFR015.REMRK                                 											  --오더비고                        
					 ,IFR015.DLFL                                  											  --오더 삭제 지시자        
					 ,IFR015.VBELN                                 											  --판매문서번호           
					 ,IFR015.POSNR                                 											  --판매문서Item번호 
					 ,IFR015.REM                                                          --반복생산지시자
					 ,IFR015.FQTY                                  											  --오더수량 	
					 ,IFR015.SEQ                                                          --오더순번				 

           ,'N'                                                                  --완료여부         
           ,sysdate                                                             --등록일시         
           ,'sp_ifr015'                                                             --등록자ID        
           ,null                                                                --수정일시         
           ,null                                                                --수정자ID 
           , case when IFR015.DLFL = 'X' then 'N'                 
                  else 'Y'
             end                                                                --사용여부(Y:사용 N:미사용)			                                              
        )
        WHERE IFR015.IF_STATUS in ('N','E')  /*  I/F상태, N:신규, S:성공, E:오류   */
        AND   IFR015.AUFNR     =  i_AUFNR
        AND   IFR015.IF_IFR_NO =  i_IF_IFR_NO 

    ; 

    --작업지시 생성되면 작업지시BOM을 구성한다.(초지는 생산BOM이 없음,22-06-09 존재한다고 해서 다시 추가함.)
     
    --작업지시정보 추출
    SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, WERKS INTO V_WO_NO,V_WO_SEQ,V_WERKS
    FROM TB_SCH011
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
            ,V_WO_SEQ  

            ,sysdate
            ,'sp_ifr015'
            ,null
            ,null
      FROM TB_SCH001          
      WHERE  AUFNR  =  i_AUFNR;                          
    END IF;    




    o_msg_MSG  :=  'TB_IFR015, 생산오더-화장지초지 수신되었습니다.1' || ',' || SQLERRM ;

    UPDATE  TB_IFR015_TMP
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    AUFNR     =  i_AUFNR
    AND    IF_IFR_NO =  i_IF_IFR_NO   
    ;

    o_msg_MSG  :=  'TB_IFR015, 생산오더-화장지초지 수신되었습니다.2' || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
                o_msg_MSG  :=  'TB_IFR015, 생산오더-화장지초지 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                o_msg_code      := '-1' ;
                DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                ROLLBACK;

                UPDATE  TB_IFR015_TMP
                SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                      , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                      , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
                WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
                AND    AUFNR     =  i_AUFNR
                AND    IF_IFR_NO =  i_IF_IFR_NO   
                ;

END  sp_ifr015 ;
/* ------- TB_IFR015 : 생산오더-화장지초지  End --------------------------- */

/* ------- TB_IFR016 : 생산오더-화장지가공  Begin ------------------------- */
PROCEDURE sp_ifr016 (  i_IF_IFR_NO      IN   NUMBER   /* MES Interface Sequence(수신번호)        */
                      ,i_AUFNR          IN   VARCHAR2
                      ,o_msg_CODE       OUT  VARCHAR2
                      ,o_msg_MSG        OUT  VARCHAR2  ) is

  V_CNT           NUMBER          := 0;      -- 카운트(작업지시존재여부) 
  V_BOM_CNT       NUMBER          := 0;      -- 카운트(작업지시BOM존재여부)

  V_WO_DT         VARCHAR2(50)    := '';      -- 지시일자(작업지시생성하기 위해서..)  

  V_WO_NO         VARCHAR2(50)    := '';      -- 작업지시번호 (작업지시BOM생성을 위해서..)  
  V_WO_SEQ        NUMBER          := 0;      --작업지시순번 (작업지시BOM생성을 위해서..)  
  V_WERKS         VARCHAR2(50)    := '';      -- 플랜트 (작업지시BOM생성을 위해서..)   

  V_DLFL          VARCHAR2(50)    := '';      -- 삭제FLAG

BEGIN

    SELECT NVL(DLFL,' ') INTO V_DLFL
    FROM TB_IFR016_TMP
    WHERE AUFNR = i_AUFNR
    AND IF_IFR_NO = i_IF_IFR_NO;    

    IF V_DLFL = 'X' THEN
      UPDATE TB_SCH003
      SET DLFL = V_DLFL
      WHERE AUFNR =  i_AUFNR;

      UPDATE TB_SCH012
      SET USE_YN = 'N'
      WHERE ORDER_NO =  i_AUFNR;             

      o_msg_MSG  :=  'TB_IFR016, 생산오더-화장지가공 삭제 수신되었습니다.1' || ',' || SQLERRM ;

      UPDATE  TB_IFR016_TMP
      SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
            , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
            , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
      WHERE  AUFNR     =  i_AUFNR
      AND    IF_IFR_NO =  i_IF_IFR_NO           
      ;

      o_msg_MSG  :=  'TB_IFR016, 생산오더-화장지가공 삭제 수신되었습니다.2' || ',' || SQLERRM ;
      o_msg_code := '0' ;
      RETURN;    
    END IF;

    MERGE
    INTO  TB_SCH003 SCH003
    USING TB_IFR016_TMP IFR016
    ON    ( SCH003.AUFNR      =  IFR016.AUFNR
    AND     IFR016.AUFNR      =  i_AUFNR 
    AND     IFR016.IF_IFR_NO  =  i_IF_IFR_NO           )
    WHEN MATCHED THEN
         UPDATE
         SET    	SCH003.WERKS	    =	IFR016.WERKS		               /*	WERKS	,	플랜트		                    */
                ,	SCH003.GSTRP	    =	IFR016.PRDDT		               /*	PRDDT	,	시작일자		                  */
                ,	SCH003.AUART	    =	IFR016.AUART		               /*	AUART	,	오더유형		                  */
                ,	SCH003.AUARTXT	    =	IFR016.AUARTXT		               /*	AUARTXT	,	오더유형 텍스트		          */
                ,	SCH003.MATNR	    =	IFR016.MATNR		               /*	MATNR	,	제품코드		                  */
                ,	SCH003.FQTY	        =	IFR016.FQTY		                   /*	FQTY	     ,	생산지시량		                  */
                ,	SCH003.MEINS	    =	IFR016.MEINS		               /*	MEINS	,	생산지시단위		                */
                --,	SCH003.ARBPL	    =	IFR016.ARBPL		               /*	ARBPL	,	Work Center		               */
                ,	SCH003.AENAM	    =	IFR016.AENAM		               /*	AENAM	,	작업지시자		                  */
                ,	SCH003.PRCMC	    =	IFR016.PRCMC		               /*	PRCMC	,	생산버전		                  */
                ,	SCH003.STLNR	    =	IFR016.STLNR		               /*	STLNR	,	BOM Num		                   */
                ,	SCH003.STLAL	    =	IFR016.STLAL		               /*	STLAL	,	대체Bom		                     */
                ,	SCH003.BMENG	    =	IFR016.BMENG		               /*	BMENG	,	모품목기준수량		                */
                ,	SCH003.BMEIN	    =	IFR016.BMEIN		               /*	BMEIN	,	모품목기준수량 단위		           */
                ,	SCH003.FTRMI	    =	IFR016.FTRMI		               /*	FTRMI	,	릴리즈일자		                   */
                ,	SCH003.SEQ	        =	IFR016.SEQ		                   /*	SEQ	,	작업순서		                      */
                ,	SCH003.DLFL	        =	IFR016.DLFL		                   /*	DLFL	,	오더 삭제 지시자		              */
                , SCH003.ORDER_RMK    = IFR016.REMRK                      --비고

                ,   SCH003.UPDDATE      =   sysdate                            /*  수정일자                              */
                ,   SCH003.UPDID        =   'sp_ifr016'                        /*  수정자                                */
          WHERE  IFR016.IF_STATUS in ('N','E')                       /*  I/F상태, N:신규, S:성공, E:오류        */
          AND    IFR016.AUFNR     =  i_AUFNR
          AND    IFR016.IF_IFR_NO =  i_IF_IFR_NO           
    WHEN NOT MATCHED THEN
         INSERT (  	SCH003.AUFNR				                         /*	AUFNR	,	오더번호		                       */
                  ,	SCH003.WERKS				                         /*	WERKS	,	플랜트		                         */
                  ,	SCH003.GSTRP				                         /*	PRDDT	,	시작일자		                       */
                  ,	SCH003.AUART				                         /*	AUART	,	오더유형		                       */
                  ,	SCH003.AUARTXT				                         /*	AUARTXT	,	오더유형 텍스트		               */
                  ,	SCH003.MATNR				                         /*	MATNR	,	제품코드		                       */
                  ,	SCH003.FQTY				                             /*	FQTY	,	생산지시량		                       */
                  ,	SCH003.MEINS				                         /*	MEINS	,	생산지시단위		                     */
                --  ,	SCH003.ARBPL				                         /*	ARBPL	,	Work Center		                    */
                  ,	SCH003.AENAM				                         /*	AENAM	,	작업지시자		                       */
                  ,	SCH003.PRCMC				                         /*	PRCMC	,	생산버전		                       */
                  ,	SCH003.STLNR				                         /*	STLNR	,	BOM Num		                        */
                  ,	SCH003.STLAL				                         /*	STLAL	,	대체Bom		                         */
                  ,	SCH003.BMENG				                         /*	BMENG	,	모품목기준수량		                    */
                  ,	SCH003.BMEIN				                         /*	BMEIN	,	모품목기준수량 단위		               */
                  ,	SCH003.FTRMI				                         /*	FTRMI	,	릴리즈일자		                       */
                  ,	SCH003.SEQ				                             /*	SEQ	,	작업순서		                         */
                  ,	SCH003.DLFL				                             /*	DLFL	,	오더 삭제 지시자		                 */
                  , SCH003.ORDER_RMK                                     --비고

                  , SCH003.REGDATE                                       /* 등록일자                                 */
                  , SCH003.REGID                                         /* 등록자                                  */
                  , SCH003.UPDDATE                                       /* 수정일자                                 */
                  , SCH003.UPDID                                         /* 수정자                                  */
                    )
         VALUES (   IFR016.AUFNR				                         /*	AUFNR	,	오더번호		                       */
                  ,	IFR016.WERKS				                         /*	WERKS	,	플랜트		                         */
                  ,	IFR016.PRDDT				                         /*	PRDDT	,	시작일자		                       */
                  ,	IFR016.AUART				                         /*	AUART	,	오더유형		                       */
                  ,	IFR016.AUARTXT				                         /*	AUARTXT	,	오더유형 텍스트		               */
                  ,	IFR016.MATNR				                         /*	MATNR	,	제품코드		                       */
                  ,	IFR016.FQTY				                             /*	FQTY	,	생산지시량		                       */
                  ,	IFR016.MEINS				                         /*	MEINS	,	생산지시단위		                     */
                --  ,	IFR016.ARBPL				                         /*	ARBPL	,	Work Center		                    */
                  ,	IFR016.AENAM				                         /*	AENAM	,	작업지시자		                       */
                  ,	IFR016.PRCMC				                         /*	PRCMC	,	생산버전		                       */
                  ,	IFR016.STLNR				                         /*	STLNR	,	BOM Num		                        */
                  ,	IFR016.STLAL				                         /*	STLAL	,	대체Bom		                         */
                  ,	IFR016.BMENG				                         /*	BMENG	,	모품목기준수량		                    */
                  ,	IFR016.BMEIN				                         /*	BMEIN	,	모품목기준수량 단위		               */
                  ,	IFR016.FTRMI				                         /*	FTRMI	,	릴리즈일자		                       */
                  ,	IFR016.SEQ				                             /*	SEQ	,	작업순서		                         */
                  ,	IFR016.DLFL				                             /*	DLFL	,	오더 삭제 지시자		                 */
                  , IFR016.REMRK

                  , sysdate                                              /* 등록일자                                      */
                  , 'sp_ifr016'                                          /* 등록자                                       */
                  , null                                                 /* 수정일자                                      */
                  , null                                                 /* 수정자                                       */
                    )
         WHERE  IFR016.IF_STATUS in ('N','E')  /*  I/F상태, N:신규, S:성공, E:오류   */
         AND    IFR016.AUFNR     =  i_AUFNR
         AND    IFR016.IF_IFR_NO =  i_IF_IFR_NO           
         ;

    --========================================         
    --KHJ추가 2022-04-27:작업지시-가공
    --========================================
    ------------------------------------------
    --작업지시가 존재하지 않으면 작업지시 번호 생성
    SELECT COUNT(ORDER_NO) INTO V_CNT
    FROM TB_SCH012
    WHERE ORDER_NO = i_AUFNR;

    IF V_CNT = 0 THEN
      SELECT PRDDT INTO V_WO_DT
      FROM TB_IFR016_TMP
      WHERE IF_IFR_NO  =  i_IF_IFR_NO;

      SP_GET_DOC_SEQ('WORA',V_WO_DT,V_WO_NO); 
    END IF;
    ------------------------------------------

    MERGE
        INTO  TB_SCH012 SCH012
        USING TB_IFR016_TMP IFR016
           ON ( SCH012.ORDER_NO   =  IFR016.AUFNR
           AND  IFR016.AUFNR      =  i_AUFNR 
           AND  IFR016.IF_IFR_NO  =  i_IF_IFR_NO   )
    WHEN MATCHED THEN    
        UPDATE SET
					  SCH012.WERKS                = IFR016.WERKS                          --플랜트코드     
					 ,SCH012.PRD_REQ_DT           = IFR016.PRDDT                          --생산요청일자    
					 ,SCH012.ORDER_DIV            = IFR016.AUART                          --오더유형      
					 ,SCH012.ORDER_DIV_NM         = IFR016.AUARTXT                        --오더유형 텍스트  
					 ,SCH012.MATNR                = IFR016.MATNR                          --제품코드      
					 ,SCH012.WRK_ORDR_QTY         = IFR016.FQTY                           --생산지시량     
					 ,SCH012.UNIT                 = IFR016.MEINS                          --생산지시단위    
					 ,SCH012.WRK_CD               = IFR016.ARBPL                          --작업장코드     
					 ,SCH012.WORK_ORDER           = IFR016.AENAM                          --작업지시자     
					 ,SCH012.MACHINE              = IFR016.PRCMC                          --생산호기      
					 ,SCH012.BOM_NO               = IFR016.STLNR                          --BOM Num   
					 ,SCH012.ATN_BOM_NO           = IFR016.STLAL                          --대체Bom     
					 ,SCH012.PRT_MATNR_QTY        = IFR016.BMENG                          --모품목기준수량   
					 ,SCH012.PRT_MATNR_UNIT       = IFR016.BMEIN                          --모품목기준수량 단위
					 ,SCH012.RES_DT               = IFR016.FTRMI                          --릴리즈일자     
					 ,SCH012.ORDER_SEQNO          = IFR016.SEQ                            --오더순번      
					 ,SCH012.DLFL                 = IFR016.DLFL                           --오더 삭제 지시자 
					 ,SCH012.ORDER_RMK            = IFR016.REMRK                          --비고   
					 ,SCH012.ORDER_QTY            = IFR016.FQTY                           --오더수량                  

           ,SCH012.UPDDATE              = sysdate                               --수정일시
           ,SCH012.UPDID                = 'sp_ifr016'                           --수정자ID
           ,SCH012.USE_YN               =  case when IFR016.DLFL = 'Y' then 'N'            
                                                when IFR016.DLFL = 'N' then 'Y'
                                           end                                  --사용여부(Y:사용 N:미사용)	            
        WHERE IFR016.IF_STATUS in ('N','E')                                     --I/F상태, N:신규, S:성공, E:오류        
        AND   IFR016.AUFNR     =  i_AUFNR
        AND   IFR016.IF_IFR_NO =  i_IF_IFR_NO
    WHEN NOT MATCHED THEN
        INSERT (
            SCH012.WRK_ORDR_NO                                                  --작업지시번호-->작업지시 생성자 사용 WO + R  
           ,SCH012.WRK_ORDR_SEQNO                                               --작업지시순번
           ,SCH012.WRK_SEQNO                                                    --작업순서
           ,SCH012.ORDR_GEN_DT                                                  --지시생성일자           

					 ,SCH012.ORDER_NO							 																				--오더번호      
					 ,SCH012.WERKS                                        								--플랜트코드     
					 ,SCH012.PRD_REQ_DT                                   								--생산요청일자    
					 ,SCH012.ORDER_DIV                                    								--오더유형      
					 ,SCH012.ORDER_DIV_NM                                 								--오더유형 텍스트  
					 ,SCH012.MATNR                                        								--제품코드      
					 ,SCH012.WRK_ORDR_QTY                                 								--생산지시량     
					 ,SCH012.UNIT                                         								--생산지시단위    
					 ,SCH012.WRK_CD                                       								--작업장코드    
           ,SCH012.MACH_CD                                                      --설비코드
					 ,SCH012.WORK_ORDER                                   								--작업지시자     
					 ,SCH012.MACHINE                                      								--생산호기      
					 ,SCH012.BOM_NO                                       								--BOM Num   
					 ,SCH012.ATN_BOM_NO                                   								--대체Bom     
					 ,SCH012.PRT_MATNR_QTY                                								--모품목기준수량   
					 ,SCH012.PRT_MATNR_UNIT                               								--모품목기준수량 단위
					 ,SCH012.RES_DT                                       								--릴리즈일자     
					 ,SCH012.ORDER_SEQNO                                  								--오더순번      
					 ,SCH012.DLFL                                         								--오더 삭제 지시자  
					 ,SCH012.ORDER_RMK                                                    --비고 
					 ,SCH012.ORDER_QTY                                                    --오더수량

           ,SCH012.COMP_YN                                                      --완료여부
           ,SCH012.REGDATE                                                      --등록일시
           ,SCH012.REGID                                                        --등록자ID
           ,SCH012.UPDDATE                                                      --수정일시
           ,SCH012.UPDID                                                        --수정자ID
           ,SCH012.USE_YN                                                       --사용여부(Y:사용 N:미사용)           
        )VALUES(
            V_WO_NO														                                  --작업지시번호             
           ,CAST(IFR016.SEQ AS INTEGER)                                         --작업지시순번
           ,IFR016.SEQ                                                          --작업순서( 22-06-13:1-> 오더순서로 변경요청으로 변경함.)
           ,TO_CHAR(sysdate,'YYYYMMDD')                                          --지시생성일자                    

					 ,IFR016.AUFNR   																											--오더번호               
					 ,IFR016.WERKS                          															--플랜트코드              
					 ,IFR016.PRDDT                          															--생산요청일자            
					 ,IFR016.AUART                          															--오더유형               
					 ,IFR016.AUARTXT                        															--오더유형 텍스트          
					 ,IFR016.MATNR                          															--제품코드               
					 ,IFR016.FQTY                           															--생산지시량              
					 ,IFR016.MEINS                          															--생산지시단위            
					 ,IFR016.ARBPL                          															--작업장코드  
           ,(SELECT M012.MACH_CD FROM TB_MAS012 M012,TB_MAS013 M013 WHERE M012.PROC_CD = M013.PROC_CD(+) AND M012.SAP_WRK_CD = IFR016.ARBPL AND M013.WERKS = IFR016.WERKS AND ROWNUM = 1) --설비코드            
					 ,IFR016.AENAM                          															--작업지시자              
					 ,IFR016.PRCMC                          															--생산호기               
					 ,IFR016.STLNR                          															--BOM Num              
					 ,IFR016.STLAL                          															--대체Bom               
					 ,IFR016.BMENG                          															--모품목기준수량           
					 ,IFR016.BMEIN                          															--모품목기준수량 단위       
					 ,IFR016.FTRMI                          															--릴리즈일자              
					 ,IFR016.SEQ                            															--오더순번               
					 ,IFR016.DLFL                           															--오더 삭제 지시자 
					 ,IFR016.REMRK                                                        --비고 
					 ,IFR016.FQTY                           															--오더수량

           ,'N'                                                                  --완료여부               
           ,sysdate                                                             --등록일시               
           ,'sp_ifr016'                                                             --등록자ID              
           ,null                                                                --수정일시               
           ,null                                                                --수정자ID 
           ,case when IFR016.DLFL = 'X' then 'N'            
                 else 'Y'                 
            end                                                                 --사용여부(Y:사용 N:미사용)	                        
        )
        WHERE IFR016.IF_STATUS in ('N','E')  /*  I/F상태, N:신규, S:성공, E:오류   */
        AND   IFR016.AUFNR     =  i_AUFNR
        AND   IFR016.IF_IFR_NO =  i_IF_IFR_NO         
    ;


    --작업지시 생성되면 작업지시BOM을 구성한다.
    
    --작업지시정보 추출
    SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, WERKS INTO V_WO_NO,V_WO_SEQ,V_WERKS
    FROM TB_SCH012
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
            ,V_WO_SEQ  

            ,sysdate
            ,'sp_ifr016'
            ,null
            ,null
      FROM TB_SCH001          
      WHERE  AUFNR  =  i_AUFNR;       
    END IF;                    
  





    o_msg_MSG  :=  'TB_IFR016, 생산오더-화장지가공 수신되었습니다.1' || ',' || SQLERRM ;

    UPDATE  TB_IFR016_TMP
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    AUFNR     =  i_AUFNR
    AND    IF_IFR_NO =  i_IF_IFR_NO           
    ;

    o_msg_MSG  :=  'TB_IFR016, 생산오더-화장지가공 수신되었습니다.2' || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
                o_msg_MSG  :=  'TB_IFR016, 생산오더-화장지가공 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                o_msg_code      := '-1' ;
                DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                ROLLBACK;

                UPDATE  TB_IFR016_TMP
                SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                      , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                      , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
                WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
                AND    AUFNR     =  i_AUFNR
                AND    IF_IFR_NO =  i_IF_IFR_NO           
                ;

END  sp_ifr016 ;
/* ------- TB_IFR016 : 생산오더-화장지가공  End --------------------------- */


/* ------- TB_IFR017 : 생산오더 패드  Begin ------------------------- */
PROCEDURE sp_ifr017 (  i_IF_IFR_NO      IN   NUMBER   /* MES Interface Sequence(수신번호)        */
                      ,i_AUFNR          IN   VARCHAR2
                      ,o_msg_CODE       OUT  VARCHAR2
                      ,o_msg_MSG        OUT  VARCHAR2  ) is

  V_WC            VARCHAR2(50)    := '';      -- WORK CENTER

  V_CNT           NUMBER          := 0;      -- 카운트(작업지시존재여부) 
  V_BOM_CNT       NUMBER          := 0;      -- 카운트(작업지시BOM존재여부)

  V_WO_DT         VARCHAR2(50)    := '';      -- 지시일자(작업지시생성하기 위해서..)  

  V_WO_NO         VARCHAR2(50)    := '';      -- 작업지시번호 (작업지시BOM생성을 위해서..)  
  V_WO_SEQ        NUMBER          := 0;      --작업지시순번 (작업지시BOM생성을 위해서..)  
  V_WERKS         VARCHAR2(50)    := '';      -- 플랜트 (작업지시BOM생성을 위해서..)   

  V_DLFL          VARCHAR2(50)    := '';      -- 삭제FLAG                         
BEGIN


    SELECT NVL(DLFL,' ') INTO V_DLFL
    FROM TB_IFR017_TMP
    WHERE AUFNR = i_AUFNR
    AND IF_IFR_NO = i_IF_IFR_NO;    

    IF V_DLFL = 'X' THEN
      UPDATE TB_SCH004
      SET DLFL = V_DLFL
      WHERE AUFNR =  i_AUFNR;

      UPDATE TB_SCH013
      SET USE_YN = 'N'
      WHERE ORDER_NO =  i_AUFNR;     

      UPDATE TB_SCH005
      SET DLFL = V_DLFL
      WHERE AUFNR =  i_AUFNR;

      UPDATE TB_SCH014
      SET USE_YN = 'N'
      WHERE ORDER_NO =  i_AUFNR;                

      o_msg_MSG  :=  'TB_IFR017, 생산오더-패드 삭제 수신되었습니다.1' || ',' || SQLERRM ;

      UPDATE  TB_IFR017_TMP
      SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
            , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
            , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
      WHERE  AUFNR     =  i_AUFNR
      AND    IF_IFR_NO =  i_IF_IFR_NO           
      ;

      o_msg_MSG  :=  'TB_IFR017, 생산오더-패드 삭제 수신되었습니다.2' || ',' || SQLERRM ;
      o_msg_code := '0' ;
      RETURN;    
    END IF;




    --SP:생리대, BP:기저귀로 내려온다고 했는데 4자리로 내려와서 아래내용 추가해서 주석처리 함.
    --SELECT NVL(ARBPL,' ') INTO V_WC
    --FROM TB_IFR017
    --WHERE IF_IFR_NO  =  i_IF_IFR_NO;

    --SELECT DECODE(NVL(ARBPL,''),'','',SUBSTR(ARBPL,1,2)) INTO V_WC
    --FROM TB_IFR017
    --WHERE IF_IFR_NO  =  i_IF_IFR_NO;

    SELECT SUBSTR(ARBPL,1,2) INTO V_WC
    FROM TB_IFR017_TMP
    WHERE IF_IFR_NO  =  i_IF_IFR_NO;    

    --************************************************************************************************************************
    --패드
    --************************************************************************************************************************    
    IF V_WC = 'SP' THEN
    --패드
    MERGE
    INTO  TB_SCH004 SCH004
    USING TB_IFR017_TMP IFR017
    ON    ( SCH004.AUFNR      =  IFR017.AUFNR
    AND     IFR017.AUFNR      =  i_AUFNR 
    AND     IFR017.IF_IFR_NO  =  i_IF_IFR_NO           )
    WHEN MATCHED THEN
         UPDATE
         SET    	SCH004.WERKS			=	IFR017.WERKS			             /*		플랜트					                            */
                ,	SCH004.SDATE			=	IFR017.SDATE			             /*		시작일자					                          */
                ,	SCH004.AUART			=	IFR017.AUART			             /*		오더유형					                          */
                ,	SCH004.AUARTXT		    =	IFR017.AUARTXT			             /*		오더유형 텍스트					                      */
                ,	SCH004.MATNR			=	IFR017.MATNR			             /*		제품코드					                          */
                ,	SCH004.FQTY			    =	IFR017.FQTY			                 /*		생산지시량					                          */
                ,	SCH004.MEINS			=	IFR017.MEINS			             /*		생산지시단위					                        */
                ,	SCH004.ARBPL			=	IFR017.ARBPL			             /*		Work Center					                      */
                ,	SCH004.AENAM			=	IFR017.AENAM			             /*		작업지시자					                          */
                ,	SCH004.PRCMC			=	IFR017.PRCMC			             /*		생산버전					                          */
                ,	SCH004.STLNR			=	IFR017.STLNR			             /*		BOM Num					                          */
                ,	SCH004.STLAL			=	IFR017.STLAL			             /*		대체Bom					                            */
                ,	SCH004.BMENG			=	IFR017.BMENG			             /*		모품목기준수량					                       */
                ,	SCH004.BMEIN			=	IFR017.BMEIN			             /*		모품목기준수량 단위					                  */
                ,	SCH004.FTRMI			=	IFR017.FTRMI			             /*		릴리즈일자					                           */
                ,	SCH004.SEQ			  =	IFR017.SEQ			               /*		작업순서					                           */
                ,	SCH004.EDATE			=	IFR017.EDATE			             /*		생산종료일					                           */
                ,	SCH004.DLFL			  =	IFR017.DLFL			               /*		오더 삭제 지시자					                       */
                , SCH004.ORDER_RMK  = IFR017.REMRK                   --비고

                , SCH004.UPDDATE    =  sysdate                       /*  수정일자                                      */
                , SCH004.UPDID      =  'sp_ifr017'                       /*  수정자                                       */
          WHERE  IFR017.IF_STATUS in ('N','E')                       /*  I/F상태, N:신규, S:성공, E:오류                */
          AND    IFR017.AUFNR     =  i_AUFNR
          AND    IFR017.IF_IFR_NO =  i_IF_IFR_NO           
    WHEN NOT MATCHED THEN
         INSERT (  	SCH004.AUFNR							                       /*		오더번호					                           */
                  ,	SCH004.WERKS							                       /*		플랜트					                             */
                  ,	SCH004.SDATE							                       /*		시작일자					                           */
                  ,	SCH004.AUART							                       /*		오더유형					                           */
                  ,	SCH004.AUARTXT							                       /*		오더유형 텍스트					                     */
                  ,	SCH004.MATNR							                       /*		제품코드					                           */
                  ,	SCH004.FQTY							                           /*		생산지시량					                           */
                  ,	SCH004.MEINS							                       /*		생산지시단위					                         */
                  ,	SCH004.ARBPL							                       /*		Work Center					                        */
                  ,	SCH004.AENAM							                       /*		작업지시자					                           */
                  ,	SCH004.PRCMC							                       /*		생산버전					                           */
                  ,	SCH004.STLNR							                       /*		BOM Num					                            */
                  ,	SCH004.STLAL							                       /*		대체Bom					                             */
                  ,	SCH004.BMENG							                       /*		모품목기준수량					                        */
                  ,	SCH004.BMEIN							                       /*		모품목기준수량 단위					                   */
                  ,	SCH004.FTRMI							                       /*		릴리즈일자					                           */
                  ,	SCH004.SEQ							                         /*		작업순서					                            */
                  ,	SCH004.EDATE							                       /*		생산종료일					                           */
                  ,	SCH004.DLFL							                           /*		오더 삭제 지시자					                      */
                  , SCH004.ORDER_RMK                                  --비고

                  , SCH004.REGDATE                                                 /*       등록일자                                     */
                  , SCH004.REGID                                                   /*       등록자                                       */
                  , SCH004.UPDDATE                                                 /*       수정일자                                      */
                  , SCH004.UPDID                                                   /*       수정자                                       */
                    )
         VALUES (   IFR017.AUFNR				                             /*		오더번호					                            */
                  ,	IFR017.WERKS				                             /*		플랜트					                              */
                  ,	IFR017.SDATE				                             /*		시작일자					                            */
                  ,	IFR017.AUART				                             /*		오더유형					                            */
                  ,	IFR017.AUARTXT				                             /*		오더유형 텍스트					                        */
                  ,	IFR017.MATNR				                             /*		제품코드					                            */
                  ,	IFR017.FQTY				                                 /*		생산지시량					                            */
                  ,	IFR017.MEINS				                             /*		생산지시단위					                          */
                  ,	IFR017.ARBPL				                             /*		Work Center					                          */
                  ,	IFR017.AENAM				                             /*		작업지시자					                            */
                  , (SELECT M012.MACHINE FROM TB_MAS012 M012,TB_MAS013 M013 WHERE M012.PROC_CD = M013.PROC_CD(+) AND M012.SAP_WRK_CD = IFR017.ARBPL AND M013.WERKS = IFR017.WERKS AND ROWNUM = 1)	
                                                                             /*		생산버전					                             */
                  ,	IFR017.STLNR				                             /*		BOM Num					                              */
                  ,	IFR017.STLAL				                             /*		대체Bom					                               */
                  ,	IFR017.BMENG				                             /*		모품목기준수량					                          */
                  ,	IFR017.BMEIN				                             /*		모품목기준수량 단위					                     */
                  ,	IFR017.FTRMI				                             /*		릴리즈일자					                              */
                  ,	IFR017.SEQ				                                 /*		작업순서					                              */
                  ,	IFR017.EDATE				                             /*		생산종료일					                              */
                  ,	IFR017.DLFL				                                 /*		오더 삭제 지시자					                         */
                  , IFR017.REMRK                                     --비고

                  , sysdate                                                  /*     등록일자                                        */
                  , 'sp_ifr017'                                              /*     등록자                                          */
                  , null                                                     /*     수정일자                                         */
                  , null                                                     /*     수정자                                          */
                    )
         WHERE  IFR017.IF_STATUS in ('N','E')  /*  I/F상태, N:신규, S:성공, E:오류   */
         AND    IFR017.AUFNR     =  i_AUFNR
         AND    IFR017.IF_IFR_NO =  i_IF_IFR_NO           
         ;

    --========================================
    --KHJ추가 2022-05-01:작업지시-패드
    --========================================
    ------------------------------------------
    --작업지시가 존재하지 않으면 작업지시 번호 생성
    SELECT COUNT(ORDER_NO) INTO V_CNT
    FROM TB_SCH013
    WHERE ORDER_NO = i_AUFNR;

    IF V_CNT = 0 THEN
      SELECT SDATE INTO V_WO_DT
      FROM TB_IFR017_TMP
      WHERE IF_IFR_NO  =  i_IF_IFR_NO;

      SP_GET_DOC_SEQ('WORB',V_WO_DT,V_WO_NO); 
    END IF;
    ------------------------------------------

    MERGE
        INTO  TB_SCH013 SCH013
        USING TB_IFR017_TMP IFR017
           ON ( SCH013.ORDER_NO   =  IFR017.AUFNR
           AND  IFR017.AUFNR      =  i_AUFNR 
           AND  IFR017.IF_IFR_NO  =  i_IF_IFR_NO   )
    WHEN MATCHED THEN    
        UPDATE SET
            SCH013.WERKS                = IFR017.WERKS                          --플랜트코드
           ,SCH013.PRD_REQ_DT           = IFR017.SDATE                          --생산요청일자
           ,SCH013.ORDR_GEN_DT          = IFR017.SDATE                          --지시생성일자                      
					 --,SCH013.WERKS                = IFR017.WERKS                          --플랜트코드     
					 --,SCH013.PRD_REQ_DT           = IFR017.SDATE                          --생산요청일자    
					 ,SCH013.ORDER_DIV            = IFR017.AUART                          --오더유형      
					 ,SCH013.ORDER_DIV_NM         = IFR017.AUARTXT                        --오더유형 텍스트  
					 ,SCH013.MATNR                = IFR017.MATNR                          --제품코드      
					 ,SCH013.WRK_ORDR_QTY         = IFR017.FQTY                           --생산지시량     
					 ,SCH013.UNIT                 = IFR017.MEINS                          --생산지시단위    
					 ,SCH013.WRK_CD               = IFR017.ARBPL                          --작업장코드     
					 ,SCH013.WORK_ORDER           = IFR017.AENAM                          --작업지시자     
					 ,SCH013.MACHINE              = IFR017.PRCMC                          --생산호기      
					 ,SCH013.BOM_NO               = IFR017.STLNR                          --BOM Num   
					 ,SCH013.ATN_BOM_NO           = IFR017.STLAL                          --대체Bom     
					 ,SCH013.PRT_MATNR_QTY        = IFR017.BMENG                          --모품목기준수량   
					 ,SCH013.PRT_MATNR_UNIT       = IFR017.BMEIN                          --모품목기준수량 단위
					 ,SCH013.RES_DT               = IFR017.FTRMI                          --릴리즈일자     
					 ,SCH013.ORDER_SEQNO          = IFR017.SEQ                            --오더순번      
					 ,SCH013.PRD_END_DT           = IFR017.EDATE                          --생산종료일     
					 ,SCH013.DLFL                 = IFR017.DLFL                           --오더 삭제 지시자 
					 ,SCH013.ORDER_RMK            = IFR017.REMRK                          --비고   
					 ,SCH013.ORDER_QTY            = IFR017.FQTY                           --오더수량            

           ,SCH013.UPDDATE              = sysdate                               --수정일시
           ,SCH013.UPDID                = 'sp_IFR017'                           --수정자ID
           ,SCH013.USE_YN               =  case when IFR017.DLFL = 'Y' then 'N'            
                                                when IFR017.DLFL = 'N' then 'Y'
                                           end                                  --사용여부(Y:사용 N:미사용)	            
        WHERE IFR017.IF_STATUS in ('N','E')                                     --I/F상태, N:신규, S:성공, E:오류        
        AND   IFR017.AUFNR     =  i_AUFNR
        AND   IFR017.IF_IFR_NO =  i_IF_IFR_NO
    WHEN NOT MATCHED THEN
        INSERT (
            SCH013.WRK_ORDR_NO                                                  --작업지시번호-->작업지시 생성자 사용 WO + R  
           ,SCH013.WRK_ORDR_SEQNO                                               --작업지시순번
           ,SCH013.WRK_SEQNO                                                    --작업순서
           ,SCH013.ORDR_GEN_DT                                                  --지시생성일자             

					 ,SCH013.ORDER_NO																											--오더번호                  
					 ,SCH013.WERKS                                                        --플랜트코드                 
					 ,SCH013.PRD_REQ_DT                                                   --생산요청일자                
					 ,SCH013.ORDER_DIV                                                    --오더유형                  
					 ,SCH013.ORDER_DIV_NM                                                 --오더유형 텍스트              
					 ,SCH013.MATNR                                                        --제품코드                  
					 ,SCH013.WRK_ORDR_QTY                                                 --생산지시량                 
					 ,SCH013.UNIT                                                         --생산지시단위                
					 ,SCH013.WRK_CD                                                       --작업장코드
           ,SCH013.MACH_CD                                                      --설비코드      
					 ,SCH013.WORK_ORDER                                                   --작업지시자                 
					 ,SCH013.MACHINE                                                      --생산호기                  
					 ,SCH013.BOM_NO                                                       --BOM Num               
					 ,SCH013.ATN_BOM_NO                                                   --대체Bom                 
					 ,SCH013.PRT_MATNR_QTY                                                --모품목기준수량               
					 ,SCH013.PRT_MATNR_UNIT                                               --모품목기준수량 단위            
					 ,SCH013.RES_DT                                                       --릴리즈일자                 
					 ,SCH013.ORDER_SEQNO                                                  --오더순번                  
					 ,SCH013.PRD_END_DT                                                   --생산종료일                 
           ,SCH013.DLFL                                                         --오더 삭제 지시자 
           ,SCH013.ORDER_RMK                                                    --비고
           ,SCH013.ORDER_QTY                                                    --오더수량

           ,SCH013.COMP_YN                                                      --완료여부
           ,SCH013.REGDATE                                                      --등록일시
           ,SCH013.REGID                                                        --등록자ID
           ,SCH013.UPDDATE                                                      --수정일시
           ,SCH013.UPDID                                                        --수정자ID
           ,SCH013.USE_YN                                                       --사용여부(Y:사용 N:미사용)           
        )VALUES(
            V_WO_NO														                                  --작업지시번호             
           ,CAST(IFR017.SEQ AS INTEGER)                                         --작업지시순번
           ,IFR017.SEQ                                                          --작업순서( 22-06-13:1-> 오더순서로 변경요청으로 변경함.)
           ,TO_CHAR(sysdate,'YYYYMMDD')                                          --지시생성일자             

					 ,IFR017.AUFNR  																											--오더번호                      
					 ,IFR017.WERKS                        																--플랜트코드                     
					 ,IFR017.SDATE                        																--생산요청일자                    
					 ,IFR017.AUART                        																--오더유형                      
					 ,IFR017.AUARTXT                      																--오더유형 텍스트                  
					 ,IFR017.MATNR                        																--제품코드                      
					 ,IFR017.FQTY                         																--생산지시량                     
					 ,IFR017.MEINS                        																--생산지시단위                    
					 ,IFR017.ARBPL                        																--작업장코드 
           ,(SELECT M012.MACH_CD FROM TB_MAS012 M012,TB_MAS013 M013 WHERE M012.PROC_CD = M013.PROC_CD(+) AND M012.SAP_WRK_CD = IFR017.ARBPL AND M013.WERKS = IFR017.WERKS AND ROWNUM = 1) --설비코드                    
					 ,IFR017.AENAM                        																--작업지시자                     
           ,(SELECT M012.MACHINE FROM TB_MAS012 M012,TB_MAS013 M013 WHERE M012.PROC_CD = M013.PROC_CD(+) AND M012.SAP_WRK_CD = IFR017.ARBPL AND M013.WERKS = IFR017.WERKS AND ROWNUM = 1) --설비코드                      
					 ,IFR017.STLNR                        																--BOM Num                   
					 ,IFR017.STLAL                        																--대체Bom                     
					 ,IFR017.BMENG                        																--모품목기준수량                   
					 ,IFR017.BMEIN                        																--모품목기준수량 단위                
					 ,IFR017.FTRMI                        																--릴리즈일자                     
					 ,IFR017.SEQ                          																--오더순번                      
					 ,IFR017.EDATE                        																--생산종료일                     
           ,IFR017.DLFL                         																--오더 삭제 지시자 
           ,IFR017.REMRK                                                        --비고
           ,IFR017.FQTY                         																--오더수량    
                  

           ,'N'                                                                  --완료여부               
           ,sysdate                                                             --등록일시               
           ,'sp_IFR017'                                                             --등록자ID              
           ,null                                                                --수정일시               
           ,null                                                                --수정자ID 
           ,case when IFR017.DLFL = 'X' then 'N'                     
                 else 'Y'                 
            end                                                                 --사용여부(Y:사용 N:미사용)	                        
        )
        WHERE IFR017.IF_STATUS in ('N','E')  /*  I/F상태, N:신규, S:성공, E:오류   */
        AND   IFR017.AUFNR     =  i_AUFNR
        AND   IFR017.IF_IFR_NO =  i_IF_IFR_NO         
    ;       


     
    --작업지시정보 추출
    SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, WERKS INTO V_WO_NO,V_WO_SEQ,V_WERKS
    FROM TB_SCH013
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
            ,V_WO_SEQ  

            ,sysdate
            ,'sp_ifr017'
            ,null
            ,null
      FROM TB_SCH001          
      WHERE  AUFNR  =  i_AUFNR;       
    END IF;                        


    END IF;--//END OF 패드 
    --************************************************************************************************************************   


    --#####################################################################################
    --기저귀
    --#####################################################################################

    IF V_WC = 'BP' THEN         
    --기저귀 
    MERGE
    INTO  TB_SCH005 SCH005
    USING TB_IFR017_TMP IFR017
    ON    ( SCH005.AUFNR      =  IFR017.AUFNR
    AND     IFR017.AUFNR      =  i_AUFNR 
    AND     IFR017.IF_IFR_NO  =  i_IF_IFR_NO           )
    WHEN MATCHED THEN
         UPDATE
         SET    	SCH005.WERKS			=	IFR017.WERKS			             /*		플랜트					                            */
                ,	SCH005.SDATE			=	IFR017.SDATE			             /*		시작일자					                          */
                ,	SCH005.AUART			=	IFR017.AUART			             /*		오더유형					                          */
                ,	SCH005.AUARTXT		    =	IFR017.AUARTXT			             /*		오더유형 텍스트					                      */
                ,	SCH005.MATNR			=	IFR017.MATNR			             /*		제품코드					                          */
                ,	SCH005.FQTY			    =	IFR017.FQTY			                 /*		생산지시량					                          */
                ,	SCH005.MEINS			=	IFR017.MEINS			             /*		생산지시단위					                        */
                ,	SCH005.ARBPL			=	IFR017.ARBPL			             /*		Work Center					                      */
                ,	SCH005.AENAM			=	IFR017.AENAM			             /*		작업지시자					                          */
                ,	SCH005.PRCMC			=	IFR017.PRCMC			             /*		생산버전					                          */
                ,	SCH005.STLNR			=	IFR017.STLNR			             /*		BOM Num					                          */
                ,	SCH005.STLAL			=	IFR017.STLAL			             /*		대체Bom					                            */
                ,	SCH005.BMENG			=	IFR017.BMENG			             /*		모품목기준수량					                       */
                ,	SCH005.BMEIN			=	IFR017.BMEIN			             /*		모품목기준수량 단위					                  */
                ,	SCH005.FTRMI			=	IFR017.FTRMI			             /*		릴리즈일자					                           */
                ,	SCH005.SEQ			    =	IFR017.SEQ			             /*		작업순서					                           */
                ,	SCH005.EDATE			=	IFR017.EDATE			             /*		생산종료일					                           */
                ,	SCH005.DLFL			  =	IFR017.DLFL			               /*		오더 삭제 지시자					                       */
                , SCH005.ORDER_RMK  = IFR017.REMRK                   --비고


                , SCH005.UPDDATE    =  sysdate                       /*  수정일자                                      */
                , SCH005.UPDID      =  'sp_ifr017'                       /*  수정자                                       */
          WHERE  IFR017.IF_STATUS in ('N','E')                       /*  I/F상태, N:신규, S:성공, E:오류                */
          AND    IFR017.AUFNR     =  i_AUFNR
          AND    IFR017.IF_IFR_NO =  i_IF_IFR_NO           
    WHEN NOT MATCHED THEN
         INSERT (  	SCH005.AUFNR							                       /*		오더번호					                           */
                  ,	SCH005.WERKS							                       /*		플랜트					                             */
                  ,	SCH005.SDATE							                       /*		시작일자					                           */
                  ,	SCH005.AUART							                       /*		오더유형					                           */
                  ,	SCH005.AUARTXT							                       /*		오더유형 텍스트					                     */
                  ,	SCH005.MATNR							                       /*		제품코드					                           */
                  ,	SCH005.FQTY							                           /*		생산지시량					                           */
                  ,	SCH005.MEINS							                       /*		생산지시단위					                         */
                  ,	SCH005.ARBPL							                       /*		Work Center					                        */
                  ,	SCH005.AENAM							                       /*		작업지시자					                           */
                  ,	SCH005.PRCMC							                       /*		생산버전					                           */
                  ,	SCH005.STLNR							                       /*		BOM Num					                            */
                  ,	SCH005.STLAL							                       /*		대체Bom					                             */
                  ,	SCH005.BMENG							                       /*		모품목기준수량					                        */
                  ,	SCH005.BMEIN							                       /*		모품목기준수량 단위					                   */
                  ,	SCH005.FTRMI							                       /*		릴리즈일자					                           */
                  ,	SCH005.SEQ							                         /*		작업순서					                            */
                  ,	SCH005.EDATE							                       /*		생산종료일					                           */
                  ,	SCH005.DLFL							                           /*		오더 삭제 지시자					                      */
                  , SCH005.ORDER_RMK                                 --비고

                  , SCH005.REGDATE                                                 /*       등록일자                                     */
                  , SCH005.REGID                                                   /*       등록자                                       */
                  , SCH005.UPDDATE                                                 /*       수정일자                                      */
                  , SCH005.UPDID                                                   /*       수정자                                       */
                    )
         VALUES (   IFR017.AUFNR				                             /*		오더번호					                            */
                  ,	IFR017.WERKS				                             /*		플랜트					                              */
                  ,	IFR017.SDATE				                             /*		시작일자					                            */
                  ,	IFR017.AUART				                             /*		오더유형					                            */
                  ,	IFR017.AUARTXT				                             /*		오더유형 텍스트					                        */
                  ,	IFR017.MATNR				                             /*		제품코드					                            */
                  ,	IFR017.FQTY				                                 /*		생산지시량					                            */
                  ,	IFR017.MEINS				                             /*		생산지시단위					                          */
                  ,	IFR017.ARBPL				                             /*		Work Center					                          */
                  ,	IFR017.AENAM				                             /*		작업지시자					                            */
                  ,	IFR017.PRCMC				                             /*		생산버전					                             */
                  ,	IFR017.STLNR				                             /*		BOM Num					                              */
                  ,	IFR017.STLAL				                             /*		대체Bom					                               */
                  ,	IFR017.BMENG				                             /*		모품목기준수량					                          */
                  ,	IFR017.BMEIN				                             /*		모품목기준수량 단위					                     */
                  ,	IFR017.FTRMI				                             /*		릴리즈일자					                              */
                  ,	IFR017.SEQ				                                 /*		작업순서					                              */
                  ,	IFR017.EDATE				                             /*		생산종료일					                              */
                  ,	IFR017.DLFL				                                 /*		오더 삭제 지시자					                         */
                  , IFR017.REMRK                                        --비고

                  , sysdate                                                  /*     등록일자                                        */
                  , 'sp_ifr017'                                              /*     등록자                                          */
                  , null                                                     /*     수정일자                                         */
                  , null                                                     /*     수정자                                          */
                    )
         WHERE  IFR017.IF_STATUS in ('N','E')  /*  I/F상태, N:신규, S:성공, E:오류   */
         AND    IFR017.AUFNR     =  i_AUFNR
         AND    IFR017.IF_IFR_NO =  i_IF_IFR_NO           
         ;         


    --========================================
    --KHJ추가 2022-05-01:작업지시-기저귀
    --========================================
    ------------------------------------------
    --작업지시가 존재하지 않으면 작업지시 번호 생성
    SELECT COUNT(ORDER_NO) INTO V_CNT
    FROM TB_SCH014
    WHERE ORDER_NO = i_AUFNR;

    IF V_CNT = 0 THEN
      SELECT SDATE INTO V_WO_DT
      FROM TB_IFR017_TMP
      WHERE IF_IFR_NO  =  i_IF_IFR_NO;

      SP_GET_DOC_SEQ('WORC',V_WO_DT,V_WO_NO); 
    END IF;
    ------------------------------------------

    MERGE
        INTO  TB_SCH014 SCH014
        USING TB_IFR017_TMP IFR017
           ON ( SCH014.ORDER_NO   =  IFR017.AUFNR
           AND  IFR017.AUFNR      =  i_AUFNR 
           AND  IFR017.IF_IFR_NO  =  i_IF_IFR_NO   )
    WHEN MATCHED THEN    
        UPDATE SET
					  SCH014.WERKS                = IFR017.WERKS                          --플랜트코드     
					 ,SCH014.PRD_REQ_DT           = IFR017.SDATE                          --생산요청일자    
					 ,SCH014.ORDER_DIV            = IFR017.AUART                          --오더유형      
					 ,SCH014.ORDER_DIV_NM         = IFR017.AUARTXT                        --오더유형 텍스트  
					 ,SCH014.MATNR                = IFR017.MATNR                          --제품코드      
					 ,SCH014.WRK_ORDR_QTY         = IFR017.FQTY                           --생산지시량     
					 ,SCH014.UNIT                 = IFR017.MEINS                          --생산지시단위    
					 ,SCH014.WRK_CD               = IFR017.ARBPL                          --작업장코드     
					 ,SCH014.WORK_ORDER           = IFR017.AENAM                          --작업지시자     
					 ,SCH014.MACHINE              = IFR017.PRCMC                          --생산호기      
					 ,SCH014.BOM_NO               = IFR017.STLNR                          --BOM Num   
					 ,SCH014.ATN_BOM_NO           = IFR017.STLAL                          --대체Bom     
					 ,SCH014.PRT_MATNR_QTY        = IFR017.BMENG                          --모품목기준수량   
					 ,SCH014.PRT_MATNR_UNIT       = IFR017.BMEIN                          --모품목기준수량 단위
					 ,SCH014.RES_DT               = IFR017.FTRMI                          --릴리즈일자     
					 ,SCH014.ORDER_SEQNO          = IFR017.SEQ                            --오더순번      
					 ,SCH014.PRD_END_DT           = IFR017.EDATE                          --생산종료일     
					 ,SCH014.DLFL                 = IFR017.DLFL                           --오더 삭제 지시자   
					 ,SCH014.ORDER_RMK            = IFR017.REMRK                          --비고
					 ,SCH014.ORDER_QTY            = IFR017.FQTY                           --오더수량

           ,SCH014.UPDDATE              = sysdate                               --수정일시
           ,SCH014.UPDID                = 'sp_IFR017'                           --수정자ID
           ,SCH014.USE_YN               =  case when IFR017.DLFL = 'Y' then 'N'            
                                                when IFR017.DLFL = 'N' then 'Y'
                                           end                                  --사용여부(Y:사용 N:미사용)	            
        WHERE IFR017.IF_STATUS in ('N','E')                                     --I/F상태, N:신규, S:성공, E:오류        
        AND   IFR017.AUFNR     =  i_AUFNR
        AND   IFR017.IF_IFR_NO =  i_IF_IFR_NO
    WHEN NOT MATCHED THEN
        INSERT (
            SCH014.WRK_ORDR_NO                                                  --작업지시번호-->작업지시 생성자 사용 WO + R  
           ,SCH014.WRK_ORDR_SEQNO                                               --작업지시순번
           ,SCH014.WRK_SEQNO                                                    --작업순서
           ,SCH014.ORDR_GEN_DT                                                  --지시생성일자           

					 ,SCH014.ORDER_NO																											--오더번호                  
					 ,SCH014.WERKS                                                        --플랜트코드                 
					 ,SCH014.PRD_REQ_DT                                                   --생산요청일자                
					 ,SCH014.ORDER_DIV                                                    --오더유형                  
					 ,SCH014.ORDER_DIV_NM                                                 --오더유형 텍스트              
					 ,SCH014.MATNR                                                        --제품코드                  
					 ,SCH014.WRK_ORDR_QTY                                                 --생산지시량                 
					 ,SCH014.UNIT                                                         --생산지시단위                
					 ,SCH014.WRK_CD                                                       --작업장코드
           ,SCH014.MACH_CD                                                      --설비코드      
					 ,SCH014.WORK_ORDER                                                   --작업지시자                 
					 ,SCH014.MACHINE                                                      --생산호기                  
					 ,SCH014.BOM_NO                                                       --BOM Num               
					 ,SCH014.ATN_BOM_NO                                                   --대체Bom                 
					 ,SCH014.PRT_MATNR_QTY                                                --모품목기준수량               
					 ,SCH014.PRT_MATNR_UNIT                                               --모품목기준수량 단위            
					 ,SCH014.RES_DT                                                       --릴리즈일자                 
					 ,SCH014.ORDER_SEQNO                                                  --오더순번                  
					 ,SCH014.PRD_END_DT                                                   --생산종료일                 
           ,SCH014.DLFL                                                         --오더 삭제 지시자 
           ,SCH014.ORDER_RMK                                                    --비고
           ,SCH014.ORDER_QTY                                                    --오더수량

           ,SCH014.COMP_YN                                                      --완료여부
           ,SCH014.REGDATE                                                      --등록일시
           ,SCH014.REGID                                                        --등록자ID
           ,SCH014.UPDDATE                                                      --수정일시
           ,SCH014.UPDID                                                        --수정자ID
           ,SCH014.USE_YN                                                       --사용여부(Y:사용 N:미사용)           
        )VALUES(
            V_WO_NO														                                  --작업지시번호             
           ,CAST(IFR017.SEQ AS INTEGER)                                         --작업지시순번  
           ,IFR017.SEQ                                                          --작업순서( 22-06-13:1-> 오더순서로 변경요청으로 변경함.)
           ,TO_CHAR(sysdate,'YYYYMMDD')                                          --지시생성일자               

					 ,IFR017.AUFNR  																											--오더번호                      
					 ,IFR017.WERKS                        																--플랜트코드                     
					 ,IFR017.SDATE                        																--생산요청일자                    
					 ,IFR017.AUART                        																--오더유형                      
					 ,IFR017.AUARTXT                      																--오더유형 텍스트                  
					 ,IFR017.MATNR                        																--제품코드                      
					 ,IFR017.FQTY                         																--생산지시량                     
					 ,IFR017.MEINS                        																--생산지시단위                    
					 ,IFR017.ARBPL                        																--작업장코드 
           ,(SELECT M012.MACH_CD FROM TB_MAS012 M012,TB_MAS013 M013 WHERE M012.PROC_CD = M013.PROC_CD(+) AND M012.SAP_WRK_CD = IFR017.ARBPL AND M013.WERKS = IFR017.WERKS AND ROWNUM = 1) --설비코드                    
					 ,IFR017.AENAM                        																--작업지시자                     
           ,(SELECT M012.MACHINE FROM TB_MAS012 M012,TB_MAS013 M013 WHERE M012.PROC_CD = M013.PROC_CD(+) AND M012.SAP_WRK_CD = IFR017.ARBPL AND M013.WERKS = IFR017.WERKS AND ROWNUM = 1) --설비코드                      
					 ,IFR017.STLNR                        																--BOM Num                   
					 ,IFR017.STLAL                        																--대체Bom                     
					 ,IFR017.BMENG                        																--모품목기준수량                   
					 ,IFR017.BMEIN                        																--모품목기준수량 단위                
					 ,IFR017.FTRMI                        																--릴리즈일자                     
					 ,IFR017.SEQ                          																--오더순번                      
					 ,IFR017.EDATE                        																--생산종료일                     
           ,IFR017.DLFL                         																--오더 삭제 지시자  
           ,IFR017.REMRK                                                        --비고
					 ,IFR017.FQTY                         																--오더수량     
					       

           ,'N'                                                                 --완료여부               
           ,sysdate                                                             --등록일시               
           ,'sp_IFR017'                                                         --등록자ID              
           ,null                                                                --수정일시               
           ,null                                                                --수정자ID 
           ,case when IFR017.DLFL = 'X' then 'N'                       
                 else 'Y'                 
            end                                                                 --사용여부(Y:사용 N:미사용)	                        
        )
        WHERE IFR017.IF_STATUS in ('N','E')  /*  I/F상태, N:신규, S:성공, E:오류   */
        AND   IFR017.AUFNR     =  i_AUFNR
        AND   IFR017.IF_IFR_NO =  i_IF_IFR_NO         
    ;      


    --작업지시 생성되면 작업지시BOM을 구성한다.  
    --작업지시정보 추출
    SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, WERKS INTO V_WO_NO,V_WO_SEQ,V_WERKS
    FROM TB_SCH014
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
            ,V_WO_SEQ  

            ,sysdate
            ,'sp_ifr017'
            ,null
            ,null
      FROM TB_SCH001          
      WHERE  AUFNR  =  i_AUFNR;       
    END IF;                       


    END IF; --IF V_WC = 'BP' THEN
    --#####################################################################################         



    o_msg_MSG  :=  'TB_IFR017, 생산오더 패드가 수신되었습니다.1' || ',' || SQLERRM ;

    UPDATE  TB_IFR017_TMP
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    AUFNR     =  i_AUFNR
    AND    IF_IFR_NO =  i_IF_IFR_NO           
    ;

    o_msg_MSG  :=  'TB_IFR017, 생산오더 패드가 수신되었습니다.2' || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
                o_msg_MSG  :=  'TB_IFR017, 생산오더 패드 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                o_msg_code      := '-1' ;
                DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                ROLLBACK;

                UPDATE  TB_IFR017_TMP
                SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                      , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                      , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
                WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
                AND    AUFNR     =  i_AUFNR
                AND    IF_IFR_NO =  i_IF_IFR_NO           
                ;

END  sp_ifr017 ;
/* ------- TB_IFR017 : 생산오더 패드  End --------------------------- */


/* ------- TB_IFR018 : 생산오더-점보롤  Begin ------------------------- */
PROCEDURE sp_ifr018 (  i_IF_IFR_NO      IN   NUMBER   /* MES Interface Sequence(수신번호)        */
                      ,i_AUFNR          IN   VARCHAR2
                      ,o_msg_CODE       OUT  VARCHAR2
                      ,o_msg_MSG        OUT  VARCHAR2  ) is

  V_CNT           NUMBER          := 0;      -- 카운트(작업지시존재여부) 
  V_BOM_CNT       NUMBER          := 0;      -- 카운트(작업지시BOM존재여부)

  V_WO_DT         VARCHAR2(50)    := '';      -- 지시일자(작업지시생성하기 위해서..)  

  V_WO_NO         VARCHAR2(50)    := '';      -- 작업지시번호 (작업지시BOM생성을 위해서..)  
  V_WO_SEQ        NUMBER          := 0;      --작업지시순번 (작업지시BOM생성을 위해서..)  
  V_WERKS         VARCHAR2(50)    := '';      -- 플랜트 (작업지시BOM생성을 위해서..)

  V_DLFL          VARCHAR2(50)    := '';      -- 삭제FLAG     
BEGIN


    SELECT NVL(DLFL,' ') INTO V_DLFL
    FROM TB_IFR018_TMP
    WHERE AUFNR = i_AUFNR
    AND IF_IFR_NO = i_IF_IFR_NO;    

    IF V_DLFL = 'X' THEN
      UPDATE TB_SCH006
      SET DLFL = V_DLFL
      WHERE AUFNR =  i_AUFNR;

      UPDATE TB_SCH015
      SET USE_YN = 'N'
      WHERE ORDER_NO =  i_AUFNR;             

      o_msg_MSG  :=  'TB_IFR018, 생산오더-점보롤 삭제 수신되었습니다.1' || ',' || SQLERRM ;

      UPDATE  TB_IFR018_TMP
      SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
            , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
            , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
      WHERE  AUFNR     =  i_AUFNR
      AND    IF_IFR_NO =  i_IF_IFR_NO           
      ;

      o_msg_MSG  :=  'TB_IFR018, 생산오더-점보롤 삭제 수신되었습니다.2' || ',' || SQLERRM ;
      o_msg_code := '0' ;
      RETURN;    
    END IF;


    MERGE
    INTO  TB_SCH006 SCH006
    USING TB_IFR018_TMP IFR018
    ON    ( SCH006.AUFNR      =  IFR018.AUFNR
    AND     IFR018.AUFNR      =  i_AUFNR 
    AND     IFR018.IF_IFR_NO  =  i_IF_IFR_NO           )
    WHEN MATCHED THEN
         UPDATE
         SET    	SCH006.WERKS			=	IFR018.WERKS			             /*		플랜트					                                 */
                ,	SCH006.BUDAT			=	IFR018.BUDAT			             /*		시작일자					                               */
                ,	SCH006.PRDTYPE		    =	IFR018.PRDTYPE			             /*		생산라인구분					                             */
                ,	SCH006.PRDTYPETXT	    =	IFR018.PRDTYPETXT			         /*		생산라인구분명					                             */
                ,	SCH006.MATNR			=	IFR018.MATNR			             /*		제품코드					                               */
                ,	SCH006.PCODE			=	IFR018.PCODE			             /*		지종코드					                               */
                ,	SCH006.WEIGHT			=	IFR018.WEIGHT			             /*		평량					                                  */
                ,	SCH006.JWIDTH			=	IFR018.JWIDTH			             /*		J/R 지폭					                              */
                ,	SCH006.JROLLCNT		    =	IFR018.JROLLCNT			             /*		J/R 권치수					                              */
                ,	SCH006.JBRGEW			=	IFR018.JBRGEW			             /*		총중량					                                  */
                ,	SCH006.JRCNT			=	IFR018.JRCNT			             /*		J/R 개수					                              */
                ,	SCH006.MEINS			=	IFR018.MEINS			             /*		생산지시단위					                              */
                ,	SCH006.SHEET			=	IFR018.SHEET			             /*		판지구분자					                                */
                ,	SCH006.AENAM			=	IFR018.AENAM			             /*		작업지시자					                                */
                ,	SCH006.MACHINE		    =	IFR018.MACHINE			             /*		FROM 생산호기					                                */
                ,	SCH006.MACHINETXT		=	IFR018.MACHINETXT		             --     FROM 생산호기명 
                ,	SCH006.TOMACHINE	    =	IFR018.TOMACHINE		             --		TO 생산호기					                                
                ,	SCH006.TOMACHINETXT		=	IFR018.TOMACHINETXT			         --     TO 생산호기명                                               
                ,	SCH006.STLNR			=	IFR018.STLNR			             /*		BOM Num					                                */
                ,	SCH006.STLAL			=	IFR018.STLAL			             /*		대체Bom					                                 */
                ,	SCH006.BMENG			=	IFR018.BMENG			             /*		모품목기준수량					                            */
                ,	SCH006.BMEIN			=	IFR018.BMEIN			             /*		모품목기준수량 단위					                        */
                ,	SCH006.NAUFNR			=	IFR018.NAUFNR			             /*		오더 변경 번호					                          */
                ,	SCH006.DLFL			    =	IFR018.DLFL			                 /*		오더 삭제 지시자					                          */
                , SCH006.ORDER_RMK  = IFR018.ZMEMO                    --특이사항
                , SCH006.WRK_CD     = IFR018.ARBPL                    --작업장
                , SCH006.REM        = IFR018.REM                      --반복생산지시자
                , SCH006.ROUTE      = IFR018.ROUTE                    --항차

                , SCH006.UPDDATE          =   sysdate                              /*     수정일자                                            */
                , SCH006.UPDID            =   'sp_ifr018'                          /*     수정자                                             */
          WHERE  IFR018.IF_STATUS in ('N','E')                    /*  I/F상태, N:신규, S:성공, E:오류                      */
          AND    IFR018.AUFNR     =  i_AUFNR
          AND    IFR018.IF_IFR_NO =  i_IF_IFR_NO           
    WHEN NOT MATCHED THEN
         INSERT (  	SCH006.AUFNR							                       /*		오더번호					                           */
                  ,	SCH006.WERKS							                       /*		플랜트					                             */
                  ,	SCH006.BUDAT							                       /*		시작일자					                           */
                  ,	SCH006.PRDTYPE							                       /*		생산라인구분					                         */
                  ,	SCH006.PRDTYPETXT							                   /*		생산라인구분명					                         */
                  ,	SCH006.MATNR							                       /*		제품코드					                           */
                  ,	SCH006.PCODE							                       /*		지종코드					                           */
                  ,	SCH006.WEIGHT							                       /*		평량					                              */
                  ,	SCH006.JWIDTH							                       /*		J/R 지폭					                          */
                  ,	SCH006.JROLLCNT							                       /*		J/R 권치수					                          */
                  ,	SCH006.JBRGEW							                       /*		총중량					                              */
                  ,	SCH006.JRCNT							                       /*		J/R 개수					                          */
                  ,	SCH006.MEINS							                       /*		생산지시단위					                          */
                  ,	SCH006.SHEET							                       /*		판지구분자					                            */
                  ,	SCH006.AENAM							                       /*		작업지시자					                            */
                  ,	SCH006.MACHINE							                       /*		FROM 생산호기					                            */
                  ,	SCH006.MACHINETXT							                   --		FROM 생산호기명					                                              
                  ,	SCH006.TOMACHINE							                   --		TO 생산호기명
                  ,	SCH006.TOMACHINETXT							                   --		TO 생산호기명                                    
                  ,	SCH006.STLNR							                       /*		BOM Num					                             */
                  ,	SCH006.STLAL							                       /*		대체Bom					                              */
                  ,	SCH006.BMENG							                       /*		모품목기준수량					                         */
                  ,	SCH006.BMEIN							                       /*		모품목기준수량 단위					                    */
                  ,	SCH006.NAUFNR							                       /*		오더 변경 번호					                       */
                  ,	SCH006.DLFL							                           /*		오더 삭제 지시자					                       */
                  , SCH006.REM                                                   /*       반복생산 지시자                               */
                  , SCH006.ROUTE                                                 /*       항차                                         */
                  , SCH006.ORDER_RMK                                 --특이사항    
                  , SCH006.WRK_CD                                     --작업장      

                  , SCH006.REGDATE                                                 /*       등록일자                                     */
                  , SCH006.REGID                                                   /*       등록자                                       */
                  , SCH006.UPDDATE                                                 /*       수정일자                                      */
                  , SCH006.UPDID                                                   /*       수정자                                       */
                    )
         VALUES (   IFR018.AUFNR				                             /*		오더번호					                            */
                  ,	IFR018.WERKS				                             /*		플랜트					                              */
                  ,	IFR018.BUDAT				                             /*		시작일자					                            */
                  ,	IFR018.PRDTYPE				                             /*		생산라인구분					                          */
                  ,	IFR018.PRDTYPETXT				                         /*		생산라인구분명					                          */
                  ,	IFR018.MATNR				                             /*		제품코드					                            */
                  ,	IFR018.PCODE				                             /*		지종코드					                            */
                  ,	IFR018.WEIGHT				                             /*		평량					                              */
                  ,	IFR018.JWIDTH				                             /*		J/R 지폭					                          */
                  ,	IFR018.JROLLCNT				                             /*		J/R 권치수					                          */
                  ,	IFR018.JBRGEW				                             /*		총중량					                              */
                  ,	IFR018.JRCNT				                             /*		J/R 개수					                          */
                  ,	IFR018.MEINS				                             /*		생산지시단위					                          */
                  ,	IFR018.SHEET				                             /*		판지구분자					                            */
                  ,	IFR018.AENAM				                             /*		작업지시자					                            */
                  ,	IFR018.MACHINE				                             /*		FROM 생산호기					                            */
                  ,	IFR018.MACHINETXT				                         --		FROM 생산호기명					                                              
                  ,	IFR018.TOMACHINE				                         --		TO 생산호기
                  ,	IFR018.TOMACHINETXT				                         --		TO 생산호기명                                    
                  ,	IFR018.STLNR				                             /*		BOM Num					                            */
                  ,	IFR018.STLAL				                             /*		대체Bom					                              */
                  ,	IFR018.BMENG				                             /*		모품목기준수량					                            */
                  ,	IFR018.BMEIN				                             /*		모품목기준수량 단위					                        */
                  ,	IFR018.NAUFNR				                             /*		오더 변경 번호					                          */
                  ,	IFR018.DLFL				                                 /*		오더 삭제 지시자					                          */
                  , IFR018.REM                                             /*     반복생산 지시자                               */
                  , IFR018.ROUTE                                           /*     항차                                         */
                  , IFR018.ZMEMO                                     --특이사항
                  , IFR018.ARBPL                                      --작업장

                  , sysdate                                                  /*     등록일자                                        */
                  , 'sp_ifr018'                                              /*     등록자                                          */
                  , null                                                     /*     수정일자                                         */
                  , null                                                     /*     수정자                                          */
                    )
         WHERE  IFR018.IF_STATUS in ('N','E')  /*  I/F상태, N:신규, S:성공, E:오류   */
         AND    IFR018.AUFNR     =  i_AUFNR
         AND    IFR018.IF_IFR_NO =  i_IF_IFR_NO           
         ;


    --========================================         
    --KHJ추가 2022-05-01:작업지시-점보롤
    --========================================
    ------------------------------------------
    --작업지시가 존재하지 않으면 작업지시 번호 생성
    SELECT COUNT(ORDER_NO) INTO V_CNT
    FROM TB_SCH015
    WHERE ORDER_NO = i_AUFNR;

    IF V_CNT = 0 THEN
      SELECT BUDAT INTO V_WO_DT
      FROM TB_IFR018_TMP
      WHERE IF_IFR_NO  =  i_IF_IFR_NO;

      SP_GET_DOC_SEQ('WOJA',V_WO_DT,V_WO_NO); 
    END IF;
    ------------------------------------------

    MERGE
        INTO  TB_SCH015 SCH015
        USING TB_IFR018_TMP IFR018
           ON ( SCH015.ORDER_NO   =  IFR018.AUFNR
           AND  IFR018.AUFNR      =  i_AUFNR 
           AND  IFR018.IF_IFR_NO  =  i_IF_IFR_NO   )
    WHEN MATCHED THEN    
        UPDATE SET
					  SCH015.WERKS                = IFR018.WERKS                          --플랜트코드      
					 ,SCH015.PRD_REQ_DT           = IFR018.BUDAT                          --생산요청일자     
					 ,SCH015.PRDTYPE              = IFR018.PRDTYPE                        --생산라인구분     
					 ,SCH015.PRDTYPETXT           = IFR018.PRDTYPETXT                     --생산라인구분명    
					 ,SCH015.MATNR                = IFR018.MATNR                          --자재 코드      
					 ,SCH015.PCODE                = IFR018.PCODE                          --지종         
					 ,SCH015.BS_WGT               = IFR018.WEIGHT                         --평량         
					 ,SCH015.JWIDTH               = IFR018.JWIDTH                         --J/R 지폭     
					 ,SCH015.JROLLCNT             = IFR018.JROLLCNT                       --J/R 권치수    
					 ,SCH015.TOT_WGT              = IFR018.JBRGEW                         --총중량        
					 ,SCH015.JRCNT                = IFR018.JRCNT                          --J/R 개수     
					 ,SCH015.UNIT                 = IFR018.MEINS                          --단위         
					 ,SCH015.SHEET                = IFR018.SHEET                          --판지구분자      
					 ,SCH015.WORK_ORDER           = IFR018.AENAM                          --작업지시자      
					 ,SCH015.MACHINE              = IFR018.MACHINE                        --FROM 생산호기  
					 ,SCH015.MACHINE_NM           = IFR018.MACHINETXT                     --FROM 생산 호기명
					 ,SCH015.TO_MACHINE           = IFR018.TOMACHINE                      --TO 생산호기    
					 ,SCH015.TO_MACHINE_NM        = IFR018.TOMACHINETXT                   --TO 생산 호기명  
					 ,SCH015.WRK_CD               = IFR018.ARBPL                          --작업장코드      
					 ,SCH015.BOM_NO               = IFR018.STLNR                          --BOM Num    
					 ,SCH015.ATN_BOM_NO           = IFR018.STLAL                          --대체Bom      
					 ,SCH015.PRT_MATNR_QTY        = IFR018.BMENG                          --모품목기준수량 수량 
					 ,SCH015.PRT_MATNR_UNIT       = IFR018.BMEIN                          --모품목기준수량 단위 
					 ,SCH015.NAUFNR               = IFR018.NAUFNR                         --오더 변경 번호   
					 ,SCH015.DLFL                 = IFR018.DLFL                           --오더 삭제 지시자
					 ,SCH015.ORDER_RMK            = IFR018.ZMEMO                          --특이사항
					 ,SCH015.REM                  = IFR018.REM                            --반복생산지시자
					 ,SCH015.ROUTE                = IFR018.ROUTE                          --항차
					 ,SCH015.WRK_ORDR_QTY         = IFR018.JBRGEW                         --지시수량


           ,SCH015.UPDDATE              = sysdate                               --수정일시
           ,SCH015.UPDID                = 'sp_IFR018'                           --수정자ID
           ,SCH015.USE_YN               =  case when IFR018.DLFL = 'Y' then 'N'            
                                                when IFR018.DLFL = 'N' then 'Y'
                                           end                                  --사용여부(Y:사용 N:미사용)	            
        WHERE IFR018.IF_STATUS in ('N','E')                                     --I/F상태, N:신규, S:성공, E:오류        
        AND   IFR018.AUFNR     =  i_AUFNR
        AND   IFR018.IF_IFR_NO =  i_IF_IFR_NO
    WHEN NOT MATCHED THEN
        INSERT (
            SCH015.WRK_ORDR_NO                                                  --작업지시번호-->작업지시 생성자 사용 WO + R  
           ,SCH015.WRK_ORDR_SEQNO                                               --작업지시순번
           ,SCH015.WRK_SEQNO                                                    --작업순서
           ,SCH015.ORDR_GEN_DT                                                  --지시생성일자           

					 ,SCH015.ORDER_NO             																				--오더번호       
					 ,SCH015.WERKS                													              --플랜트코드      
					 ,SCH015.PRD_REQ_DT           													              --생산요청일자     
					 ,SCH015.PRDTYPE              													              --생산라인구분     
					 ,SCH015.PRDTYPETXT           													              --생산라인구분명    
					 ,SCH015.MATNR                													              --자재 코드      
					 ,SCH015.PCODE                													              --지종         
					 ,SCH015.BS_WGT               													              --평량         
					 ,SCH015.JWIDTH               													              --J/R 지폭     
					 ,SCH015.JROLLCNT             													              --J/R 권치수    
					 ,SCH015.TOT_WGT              													              --총중량        
					 ,SCH015.JRCNT                													              --J/R 개수     
					 ,SCH015.UNIT                 													              --단위         
					 ,SCH015.SHEET                													              --판지구분자      
					 ,SCH015.WORK_ORDER           													              --작업지시자      
					 ,SCH015.MACHINE              													              --FROM 생산호기  
					 ,SCH015.MACHINE_NM           													              --FROM 생산 호기명
					 ,SCH015.TO_MACHINE           													              --TO 생산호기    
					 ,SCH015.TO_MACHINE_NM        													              --TO 생산 호기명  
					 ,SCH015.WRK_CD               													              --작업장코드      
					 ,SCH015.BOM_NO               													              --BOM Num    
					 ,SCH015.ATN_BOM_NO           													              --대체Bom      
					 ,SCH015.PRT_MATNR_QTY        													              --모품목기준수량 수량
					 ,SCH015.PRT_MATNR_UNIT       													              --모품목기준수량 단위 					  
					 ,SCH015.NAUFNR               													              --오더 변경 번호   
					 ,SCH015.DLFL                 													              --오더 삭제 지시자   
					 ,SCH015.ORDER_RMK                                                    --특이사항
					 ,SCH015.REM                                                          --반복생산지시자
					 ,SCH015.ROUTE                                                        --항차
					 ,SCH015.WRK_ORDR_QTY                                                 --지시수량

           ,SCH015.COMP_YN                                                      --완료여부
           ,SCH015.REGDATE                                                      --등록일시
           ,SCH015.REGID                                                        --등록자ID
           ,SCH015.UPDDATE                                                      --수정일시
           ,SCH015.UPDID                                                        --수정자ID
           ,SCH015.USE_YN                                                       --사용여부(Y:사용 N:미사용)           
        )VALUES(
            V_WO_NO     																												--작업지시번호             
           ,1                                                                   --작업지시순번 
           ,SUBSTR(V_WO_NO,-4)                                                  --작업순서(작업지시번호,-4)
           ,TO_CHAR(sysdate,'YYYYMMDD')                                          --지시생성일자           

					 ,IFR018.AUFNR       																									--오더번호       
					 ,IFR018.WERKS                          															--플랜트코드      
					 ,IFR018.BUDAT                          															--생산요청일자     
					 ,IFR018.PRDTYPE                        															--생산라인구분     
					 ,IFR018.PRDTYPETXT                     															--생산라인구분명    
					 ,IFR018.MATNR                          															--자재 코드      
					 ,IFR018.PCODE                          															--지종         
					 ,IFR018.WEIGHT                         															--평량         
					 ,IFR018.JWIDTH                         															--J/R 지폭     
					 ,IFR018.JROLLCNT                       															--J/R 권치수    
					 ,IFR018.JBRGEW                         															--총중량        
					 ,IFR018.JRCNT                          															--J/R 개수     
					 ,IFR018.MEINS                          															--단위         
					 ,IFR018.SHEET                          															--판지구분자      
					 ,IFR018.AENAM                          															--작업지시자      
					 ,IFR018.MACHINE                        															--FROM 생산호기  
					 ,IFR018.MACHINETXT                     															--FROM 생산 호기명
					 ,IFR018.TOMACHINE                      															--TO 생산호기    
					 ,IFR018.TOMACHINETXT                   															--TO 생산 호기명  
					 ,IFR018.ARBPL                          															--작업장코드      
					 ,IFR018.STLNR                          															--BOM Num    
					 ,IFR018.STLAL                          															--대체Bom      
					 ,IFR018.BMENG                          															--모품목기준수량 수량 
					 ,IFR018.BMEIN                          															--모품목기준수량 단위 
					 ,IFR018.NAUFNR                         															--오더 변경 번호   
					 ,IFR018.DLFL                           															--오더 삭제 지시자 
					 ,IFR018.ZMEMO                                                        --특이사항
					 ,IFR018.REM                                                          --반복생산지시자
					 ,IFR018.ROUTE                                                        --항차
					 ,IFR018.JBRGEW                                                       --지시수량

           ,'N'                                                                 --완료여부               
           ,sysdate                                                             --등록일시               
           ,'sp_IFR018'                                                         --등록자ID              
           ,null                                                                --수정일시               
           ,null                                                                --수정자ID 
           ,case when IFR018.DLFL = 'X' then 'N'                     
                 else 'Y'                 
            end                                                                 --사용여부(Y:사용 N:미사용)	                        
        )
        WHERE IFR018.IF_STATUS in ('N','E')  /*  I/F상태, N:신규, S:성공, E:오류   */
        AND   IFR018.AUFNR     =  i_AUFNR
        AND   IFR018.IF_IFR_NO =  i_IF_IFR_NO         
    ;   


    --작업지시 생성되면 작업지시BOM을 구성한다.(점보롤은 생산BOM이 없음, 22-06-09 존재한다고 해서 다시 추가함)              
      --작업지시정보 추출
      SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, WERKS INTO V_WO_NO,V_WO_SEQ,V_WERKS
      FROM TB_SCH015
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
            ,'sp_ifr018'
            ,null
            ,null
      FROM TB_SCH001          
      WHERE  AUFNR  =  i_AUFNR;       
    END IF;                    
           



    o_msg_MSG  :=  'TB_IFR018, 생산오더-점보롤 수신되었습니다.1' || ',' || SQLERRM ;

    UPDATE  TB_IFR018_TMP
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    AUFNR     =  i_AUFNR
    AND    IF_IFR_NO =  i_IF_IFR_NO           
    ;

    o_msg_MSG  :=  'TB_IFR018, 생산오더-점보롤가 수신되었습니다.2' || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
                o_msg_MSG  :=  'TB_IFR018, 생산오더-점보롤 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                o_msg_code      := '-1' ;
                DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                ROLLBACK;

                UPDATE  TB_IFR018_TMP
                SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                      , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                      , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
                WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
                AND    AUFNR     =  i_AUFNR
                AND    IF_IFR_NO =  i_IF_IFR_NO           
                ;

END  sp_ifr018 ;
/* ------- TB_IFR018 : 생산오더-점보롤  End --------------------------- */


/* ------- TB_IFR019 : 생산오더-밀롤,슬리터  Begin ------------------------- */
PROCEDURE sp_ifr019 (  i_IF_IFR_NO      IN   NUMBER   /* MES Interface Sequence(수신번호)        */
                      ,i_AUFNR          IN   VARCHAR2
                      ,o_msg_CODE       OUT  VARCHAR2
                      ,o_msg_MSG        OUT  VARCHAR2  ) is

  V_CNT           NUMBER          := 0;      -- 카운트(작업지시존재여부) 
  V_BOM_CNT       NUMBER          := 0;      -- 카운트(작업지시BOM존재여부)

  V_WO_DT         VARCHAR2(50)    := '';      -- 지시일자(작업지시생성하기 위해서..)  

  V_WO_NO         VARCHAR2(50)    := '';      -- 작업지시번호 (작업지시BOM생성을 위해서..)  
  V_WO_SEQ        NUMBER          := 0;      --작업지시순번 (작업지시BOM생성을 위해서..)  
  V_WERKS         VARCHAR2(50)    := '';      -- 플랜트 (작업지시BOM생성을 위해서..)  

  V_DLFL          VARCHAR2(50)    := '';      -- 삭제FLAG  
BEGIN

    SELECT NVL(DLFL,' ') INTO V_DLFL
    FROM TB_IFR019_TMP
    WHERE AUFNR = i_AUFNR
    AND IF_IFR_NO = i_IF_IFR_NO;    

    IF V_DLFL = 'X' THEN
      UPDATE TB_SCH007
      SET DLFL = V_DLFL
      WHERE AUFNR =  i_AUFNR;

      UPDATE TB_SCH016
      SET USE_YN = 'N'
      WHERE ORDER_NO =  i_AUFNR;             

      o_msg_MSG  :=  'TB_IFR019, 생산오더-밀롤 삭제 수신되었습니다.1' || ',' || SQLERRM ;

      UPDATE  TB_IFR019_TMP
      SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
            , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
            , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
      WHERE  AUFNR     =  i_AUFNR
      AND    IF_IFR_NO =  i_IF_IFR_NO           
      ;

      o_msg_MSG  :=  'TB_IFR019, 생산오더-밀롤 삭제 수신되었습니다.2' || ',' || SQLERRM ;
      o_msg_code := '0' ;
      RETURN;    
    END IF;


    MERGE
    INTO  TB_SCH007 SCH007
    USING TB_IFR019_TMP IFR019
    ON    ( SCH007.AUFNR      =  IFR019.AUFNR
    AND     IFR019.AUFNR      =  i_AUFNR 
    AND     IFR019.IF_IFR_NO  =  i_IF_IFR_NO      )
    WHEN MATCHED THEN
         UPDATE
         SET    	SCH007.JRPO			         =	IFR019.JRPO			           /*		점보롤 오더 번호			             	*/
                ,	SCH007.WERKS			     =	IFR019.WERKS			       /*		플랜트			                      */
                ,	SCH007.ORDER_NUM			 =	IFR019.ORDER_NUM			   /*		생산지시 No			                  */
                ,	SCH007.ORDER_SEQ			 =	IFR019.ORDER_SEQ			   /*		생산지시 seq			                */
                ,	SCH007.BUDAT			     =	IFR019.BUDAT			       /*		시작일자			                    */
                ,	SCH007.AUART			     =	IFR019.AUART			       /*		오더유형			                    */
                ,	SCH007.AUARTXT			     =	IFR019.AUARTXT			       /*		오더유형 텍스트			                */
--                ,	SCH007.PRDTYPE			     =	IFR019.PRDTYPE			       /*		생산라인구분			                  */
--                ,	SCH007.PRDTYPETXT			 =	IFR019.PRDTYPETXT			   /*		생산라인구분명			                  */
                --,	SCH007.MVERID			     =	IFR019.MVERID			       /*		생산 호기			                    */
                --,	SCH007.MVERIDTXT			 =	IFR019.MVERIDTXT			   /*		생산 호기 명			                  */
                ,	SCH007.MMATNR			     =	IFR019.MMATNR			       /*		밀롤 자재 코드			                */
                --,	SCH007.VERID			     =	IFR019.VERID			       /*		생산 호기			                    */
                --,	SCH007.VERIDTXT			     =	IFR019.VERIDTXT			       /*		생산 호기 명			                  */
                ,   SCH007.MACHINE               =  IFR019.MACHINE                 /*       FROM 생산호기                       */
                ,   SCH007.MACHINETXT            =  IFR019.MACHINETXT              /*       FROM 생산 호기명                     */
                ,   SCH007.TOMACHINE             =  IFR019.TOMACHINE               /*       TO 생산호기                     */
                ,   SCH007.TOMACHINETXT          =  IFR019.TOMACHINETXT            /*       TO 생산 호기명                   */
                ,	SCH007.MATNR			     =	IFR019.MATNR			       /*		점보롤 자재 코드			                */
                ,	SCH007.PCODE			     =	IFR019.PCODE			       /*		지종코드			                    */
                ,	SCH007.WEIGHT			     =	IFR019.WEIGHT			       /*		평량			                       */
                ,	SCH007.MWIDTH			     =	IFR019.MWIDTH			       /*		M/R 지폭			                   */
                ,	SCH007.MWIDTH_INPUT		     =	IFR019.MWIDTH_INPUT			   /*		M/R 지폭_INPUT			             */
                ,	SCH007.MWIDTH_SLITER	     =	IFR019.MWIDTH_SLITER		   /*		M/R 지폭_SLITER			             */
                ,	SCH007.MROLLCNT			     =	IFR019.MROLLCNT			       /*		M/R 권치수			                   */
                ,	SCH007.MRCNT			     =	IFR019.MRCNT			       /*		M/R 폭수			                   */
                ,	SCH007.MBRGEW			     =	IFR019.MBRGEW			       /*		M/R 중량			                   */
                ,	SCH007.MGEWEI			     =	IFR019.MGEWEI			       /*		단위			                       */
                ,	SCH007.JRCNT			     =	IFR019.JRCNT			       /*		J/R 개수			                   */
                ,	SCH007.OVBELN			     =	IFR019.OVBELN			       /*		판매 문서			                     */
                ,	SCH007.OPOSNR			     =	IFR019.OPOSNR			       /*		판매 문서 품목 번호			               */
                ,	SCH007.OAUART			     =	IFR019.OAUART			       /*		판매 문서 오더 유형			               */
                ,	SCH007.OAUARTXT			     =	IFR019.OAUARTXT			       /*		판매 문서 오더 유형 텍스트			           */
                ,	SCH007.VBELN			     =	IFR019.VBELN			       /*		판매 문서			                     	*/
                ,	SCH007.POSNR			     =	IFR019.POSNR			       /*		판매 문서 품목 번호			                */
                ,	SCH007.VDATU			     =	IFR019.VDATU			       /*		납품 요청일자			                    */
                ,	SCH007.SAUART			     =	IFR019.SAUART			       /*		판매 문서 오더 유형			                */
                ,	SCH007.SAUARTXT			     =	IFR019.SAUARTXT			       /*		판매 문서 오더 유형 텍스트			            */
                ,	SCH007.REMARK			     =	IFR019.REMARK			       /*		비고			                        	*/
                ,	SCH007.SHEET			     =	IFR019.SHEET			       /*		판지 구분자			                      */
                ,	SCH007.SLITER_SET			 =	IFR019.SLITER_SET			   /*		슬리터 구분			                      */
                ,	SCH007.MRLDCK			     =	IFR019.MRLDCK			       /*		밀롤 창고 적치 여부			                  */
                ,	SCH007.CUTTER			     =	IFR019.CUTTER			       /*		카터			                            */
                ,	SCH007.STLNR			     =	IFR019.STLNR			       /*		BOM Num			                         */
                ,	SCH007.STLAL			     =	IFR019.STLAL			       /*		대체Bom			                           */
                ,	SCH007.BMENG			     =	IFR019.BMENG			       /*		모품목기준수량			                      */
                ,	SCH007.BMEIN			     =	IFR019.BMEIN			       /*		모품목기준수량 단위			                  */
                --,	SCH007.MRPO			         =	IFR019.MRPO			           /*		밀롤 오더 번호			                    */
                , SCH007.ROUTE           =  IFR019.ROUTE                   /*   항차                                   */
                ,	SCH007.DLFL			       =	IFR019.DLFL			           /*		오더 삭제 지시자			                    */
                , SCH007.KUNNR           =  IFR019.KUNNR             --판매처
                , SCH007.KUNNRT          =  IFR019.NAME1             --판매처명                

                , SCH007.UPDDATE         =  sysdate                        /*  수정일자                                            */
                , SCH007.UPDID           =  'sp_ifr019'                    /*  수정자                                             */
          WHERE  IFR019.IF_STATUS in ('N','E')                       /*  I/F상태, N:신규, S:성공, E:오류                      */
          AND    IFR019.AUFNR     =  i_AUFNR
          AND    IFR019.IF_IFR_NO =  i_IF_IFR_NO      
    WHEN NOT MATCHED THEN
         INSERT (  	SCH007.AUFNR							                       /*		오더번호			                                     */
                  ,	SCH007.JRPO							                           /*		점보롤 오더 번호			                               */
                  ,	SCH007.WERKS							                       /*		플랜트			                                       */
                  ,	SCH007.ORDER_NUM							                   /*		생산지시 No			                                   */
                  ,	SCH007.ORDER_SEQ							                   /*		생산지시 seq			                                 */
                  ,	SCH007.BUDAT							                       /*		시작일자			                                     */
                  ,	SCH007.AUART							                       /*		오더유형			                                     */
                  ,	SCH007.AUARTXT							                       /*		오더유형 텍스트			                               */
                  --,	SCH007.PRDTYPE							                       /*		생산라인구분			                                  */
                  --,	SCH007.PRDTYPETXT							                   /*		생산라인구분명			                                  */
                  --,	SCH007.MVERID							                       /*		생산 호기			                                     */
                  --,	SCH007.MVERIDTXT							                   /*		생산 호기 명			                                   */
                  ,	SCH007.MMATNR							                       /*		밀롤 자재 코드			                                 */
                  --,	SCH007.VERID							                       /*		생산 호기			                                      */
                  --,	SCH007.VERIDTXT							                       /*		생산 호기 명			                                    */
                  , SCH007.MACHINE                                                 /*       FROM 생산호기                       */
                  , SCH007.MACHINETXT                                              /*       FROM 생산 호기명                     */
                  , SCH007.TOMACHINE                                               /*       TO 생산호기                     */
                  , SCH007.TOMACHINETXT                                            /*       TO 생산호기명                            */ 
                  ,	SCH007.MATNR							                       /*		점보롤 자재 코드			                                  */
                  ,	SCH007.PCODE							                       /*		지종코드			                                      */
                  ,	SCH007.WEIGHT							                       /*		평량			                                          */
                  ,	SCH007.MWIDTH							                       /*		M/R 지폭			                                      */
                  ,	SCH007.MWIDTH_INPUT							                   /*		M/R 지폭_INPUT			                                */
                  ,	SCH007.MWIDTH_SLITER							               /*		M/R 지폭_SLITER			                                */
                  ,	SCH007.MROLLCNT							                       /*		M/R 권치수			                                      */
                  ,	SCH007.MRCNT							                       /*		M/R 폭수			                                      */
                  ,	SCH007.MBRGEW							                       /*		M/R 중량			                                      */
                  ,	SCH007.MGEWEI							                       /*		단위			                                          */
                  ,	SCH007.JRCNT							                       /*		J/R 개수			                                      */
                  ,	SCH007.OVBELN							                       /*		판매 문서			                                        */
                  ,	SCH007.OPOSNR							                       /*		판매 문서 품목 번호			                               */
                  ,	SCH007.OAUART							                       /*		판매 문서 오더 유형			                               */
                  ,	SCH007.OAUARTXT							                       /*		판매 문서 오더 유형 텍스트			                          */
                  ,	SCH007.VBELN							                       /*		판매 문서			                                        */
                  ,	SCH007.POSNR							                       /*		판매 문서 품목 번호			                                */
                  ,	SCH007.VDATU							                       /*		납품 요청일자			                                      */
                  ,	SCH007.SAUART							                       /*		판매 문서 오더 유형			                                 */
                  ,	SCH007.SAUARTXT							                       /*		판매 문서 오더 유형 텍스트			                           */
                  ,	SCH007.REMARK							                       /*		비고			                                             */
                  ,	SCH007.SHEET							                       /*		판지 구분자			                                       */
                  ,	SCH007.SLITER_SET							                   /*		슬리터 구분			                                       */
                  ,	SCH007.MRLDCK							                       /*		밀롤 창고 적치 여부			                                  */
                  ,	SCH007.CUTTER							                       /*		카터			                                             */
                  ,	SCH007.STLNR							                       /*		BOM Num			                                          */
                  ,	SCH007.STLAL							                       /*		대체Bom			                                            */
                  ,	SCH007.BMENG							                       /*		모품목기준수량			                                       */
                  ,	SCH007.BMEIN							                       /*		모품목기준수량 단위			                                   */
                  --,	SCH007.MRPO							                           /*		밀롤 오더 번호			                                      */
                  , SCH007.ROUTE                                                 /*   항차                                                  */
                  ,	SCH007.DLFL							                           /*		오더 삭제 지시자			                                      */
                  , SCH007.KUNNR                                      --판매처
                  , SCH007.KUNNRT                                     --판매처명
                  , SCH007.SLITER                                     --슬리터구분
                  , SCH007.FRAUFNR                                    --이전오더

                  , SCH007.REGDATE                                                 /*   등록일자                                                  */
                  , SCH007.REGID                                                   /*   등록자                                                   */
                  , SCH007.UPDDATE                                                 /*   수정일자                                                  */
                  , SCH007.UPDID                                                   /*   수정자                                                   */
                    )
         VALUES (   IFR019.AUFNR				                             /*		오더번호			                                          */
                  ,	IFR019.JRPO				                                 /*		점보롤 오더 번호			                                      */
                  ,	IFR019.WERKS				                             /*		플랜트			                                            */
                  ,	IFR019.ORDER_NUM				                         /*		생산지시 No			                                        */
                  ,	IFR019.ORDER_SEQ				                         /*		생산지시 seq			                                      */
                  ,	IFR019.BUDAT				                             /*		시작일자			                                          */
                  ,	IFR019.AUART				                             /*		오더유형			                                          */
                  ,	IFR019.AUARTXT				                             /*		오더유형 텍스트			                                      */
                  --,	IFR019.PRDTYPE				                             /*		생산라인구분			                                        */
                  --,	IFR019.PRDTYPETXT				                         /*		생산라인구분명			                                        */
                  --,	IFR019.MVERID				                             /*		생산 호기			                                          */
                  --,	IFR019.MVERIDTXT				                         /*		생산 호기 명			                                        */
                  ,	IFR019.MMATNR				                             /*		밀롤 자재 코드			                                      */
                  --,	IFR019.VERID				                             /*		생산 호기			                                          */
                  --,	IFR019.VERIDTXT				                             /*		생산 호기 명			                                        */
                  , IFR019.MACHINE                                           /*       FROM 생산호기                       */
                  , IFR019.MACHINETXT                                       /*       FROM 생산 호기명                     */
                  , IFR019.TOMACHINE                                          /*       TO 생산호기                     */
                  , IFR019.TOMACHINETXT			                        	/*       TO 생산호기명                     */
                  ,	IFR019.MATNR				                             /*		점보롤 자재 코드			                                      */
                  ,	IFR019.PCODE				                             /*		지종코드			                                          */
                  ,	IFR019.WEIGHT				                             /*		평량			                                            */
                  ,	IFR019.MWIDTH				                             /*		M/R 지폭			                                        */
                  ,	IFR019.MWIDTH_INPUT				                         /*		M/R 지폭_INPUT			                                  */
                  ,	IFR019.MWIDTH_SLITER				                     /*		M/R 지폭_SLITER			                                  */
                  ,	IFR019.MROLLCNT				                             /*		M/R 권치수			                                        */
                  ,	IFR019.MRCNT				                             /*		M/R 폭수			                                        */
                  ,	IFR019.MBRGEW				                             /*		M/R 중량			                                        */
                  ,	IFR019.MGEWEI				                             /*		단위			                                            */
                  ,	IFR019.JRCNT				                             /*		J/R 개수			                                        */
                  ,	IFR019.OVBELN				                             /*		판매 문서			                                          */
                  ,	IFR019.OPOSNR				                             /*		판매 문서 품목 번호			                                    */
                  ,	IFR019.OAUART				                             /*		판매 문서 오더 유형			                                    */
                  ,	IFR019.OAUARTXT				                             /*		판매 문서 오더 유형 텍스트			                                */
                  ,	IFR019.VBELN				                             /*		판매 문서			                                          */
                  ,	IFR019.POSNR				                             /*		판매 문서 품목 번호			                                    */
                  ,	IFR019.VDATU				                             /*		납품 요청일자			                                        */
                  ,	IFR019.SAUART				                             /*		판매 문서 오더 유형			                                    */
                  ,	IFR019.SAUARTXT				                             /*		판매 문서 오더 유형 텍스트			                                */
                  ,	IFR019.REMARK				                             /*		비고			                                                */
                  ,	IFR019.SHEET				                             /*		판지 구분자			                                            */
                  ,	IFR019.SLITER_SET				                         /*		슬리터 구분			                                            */
                  ,	IFR019.MRLDCK				                             /*		밀롤 창고 적치 여부			                                        */
                  ,	IFR019.CUTTER				                             /*		카터			                                                  */
                  ,	IFR019.STLNR				                             /*		BOM Num			                                              */
                  ,	IFR019.STLAL				                             /*		대체Bom			                                                */
                  ,	IFR019.BMENG				                             /*		모품목기준수량			                                              */
                  ,	IFR019.BMEIN				                             /*		모품목기준수량 단위			                                          */
                  --,	IFR019.MRPO				                                 /*		밀롤 오더 번호			                                            */
                  , IFR019.ROUTE                                           /*     항차                                                  */
                  ,	IFR019.DLFL				                                 /*		오더 삭제 지시자			                                            */
                  , IFR019.KUNNR                                     --판매처
                  , IFR019.NAME1                                     --판매처명
                  , IFR019.SLITER                                     --슬리터구분
                  , IFR019.FRAUFNR                                    --이전오더                  

                  , sysdate                                                  /*     등록일자                                                      */
                  , 'sp_ifr019'                                              /*     등록자                                                       */
                  , null                                                     /*     수정일자                                                      */
                  , null                                                     /*     수정자                                                       */
                    )
         WHERE  IFR019.IF_STATUS in ('N','E')  /*  I/F상태, N:신규, S:성공, E:오류   */
         AND    IFR019.AUFNR     =  i_AUFNR
         AND    IFR019.IF_IFR_NO =  i_IF_IFR_NO      
         ;


    --========================================         
    --KHJ추가 2022-05-01:작업지시-밀롤
    --========================================
    ------------------------------------------
    --작업지시가 존재하지 않으면 작업지시 번호 생성
    SELECT COUNT(ORDER_NO) INTO V_CNT
    FROM TB_SCH016
    WHERE ORDER_NO = i_AUFNR;

    IF V_CNT = 0 THEN
      SELECT BUDAT INTO V_WO_DT
      FROM TB_IFR019_TMP
      WHERE IF_IFR_NO  =  i_IF_IFR_NO;

      SP_GET_DOC_SEQ('WOMA',V_WO_DT,V_WO_NO); 
    END IF;
    ------------------------------------------

    MERGE
        INTO  TB_SCH016 SCH016
        USING TB_IFR019_TMP IFR019
           ON ( SCH016.ORDER_NO   =  IFR019.AUFNR
           AND  IFR019.AUFNR      =  i_AUFNR 
           AND  IFR019.IF_IFR_NO  =  i_IF_IFR_NO   )
    WHEN MATCHED THEN    
        UPDATE SET
					  SCH016.PRE_ORDER_NO         = IFR019.FRAUFNR                        --이전 오더 번호       
					 ,SCH016.WERKS                = IFR019.WERKS                          --플랜트코드          
					 ,SCH016.ORDER_NUM            = IFR019.ORDER_NUM                      --생산지시 No        
					 ,SCH016.ORDER_SEQ            = IFR019.ORDER_SEQ                      --생산지시 seq       
					 ,SCH016.PRD_REQ_DT           = IFR019.BUDAT                          --생산요청일자         
					 ,SCH016.ORDER_DIV            = IFR019.AUART                          --오더유형           
					 ,SCH016.ORDER_DIV_NM         = IFR019.AUARTXT                        --오더유형 텍스트       
					 ,SCH016.MATNR                = IFR019.MMATNR                         --자재 코드          
					 ,SCH016.MACHINE              = IFR019.MACHINE                        --생산호기           
					 ,SCH016.MACHINE_NM           = IFR019.MACHINETXT                     --생산 호기명         
					 ,SCH016.TO_MACHINE           = IFR019.TOMACHINE                      --TO 생산호기        
					 ,SCH016.TO_MACHINE_NM        = IFR019.TOMACHINETXT                   --TO 생산 호기명      
					 ,SCH016.JMATNR               = IFR019.MATNR                          --점보롤 자재 코드      
					 ,SCH016.PCODE                = IFR019.PCODE                          --지종코드           
					 ,SCH016.BS_WGT               = IFR019.WEIGHT                         --평량             
					 ,SCH016.MWIDTH               = IFR019.MWIDTH                         --M/R 지폭         
					 ,SCH016.MWIDTH_INPUT         = IFR019.MWIDTH_INPUT                   --M/R 지폭_INPUT   
					 ,SCH016.MWIDTH_SLITER        = IFR019.MWIDTH_SLITER                  --M/R 지폭_SLITER  
					 ,SCH016.MROLLCNT             = IFR019.MROLLCNT                       --M/R 권치수        
					 ,SCH016.MRCNT                = IFR019.MRCNT                          --M/R 폭수         
					 ,SCH016.MBRGEW               = IFR019.MBRGEW                         --M/R 중량         
					 ,SCH016.UNIT                 = IFR019.MGEWEI                         --단위             
					 ,SCH016.JRCNT                = IFR019.JRCNT                          --J/R 개수         
					 ,SCH016.OVBELN               = IFR019.OVBELN                         --판매문서           
					 ,SCH016.OPOSNR               = IFR019.OPOSNR                         --판매문서 항목번호      
					 ,SCH016.OAUART_DIV           = IFR019.OAUART                         --판매문서 유형        
					 ,SCH016.OAUART_NM            = IFR019.OAUARTXT                       --판매 문서 오더 유형 텍스트
					 ,SCH016.VBELN                = IFR019.VBELN                          --판매문서           
					 ,SCH016.POSNR                = IFR019.POSNR                          --판매문서 항목번호      
					 ,SCH016.VDATU                = IFR019.VDATU                          --납품 요청일자        
					 ,SCH016.SAUART_DIV           = IFR019.SAUART                         --판매문서 유형        
					 ,SCH016.SAUART_NM            = IFR019.SAUARTXT                       --판매 문서 오더 유형 텍스트
					 ,SCH016.ORDER_RMK            = IFR019.REMARK                         --비고(22-06-08:REMARK->ORDER_RMK로 변경함)             
					 ,SCH016.SHEET                = IFR019.SHEET                          --판지 구분자         
					 ,SCH016.SLITER_SET           = IFR019.SLITER_SET                     --슬리터 구분         
					 ,SCH016.MRLDCK               = IFR019.MRLDCK                         --밀롤 창고 적치 여부    
					 ,SCH016.CUTTER               = IFR019.CUTTER                         --카터             
					 ,SCH016.ATN_BOM_NO           = IFR019.STLNR                          --대체Bom          
					 ,SCH016.BOM_NO               = IFR019.STLAL                          --BOM Num        
					 ,SCH016.PRT_MATNR_QTY        = IFR019.BMENG                          --모품목기준수량        
					 ,SCH016.PRT_MATNR_UNIT       = IFR019.BMEIN                          --모품목기준수량 단위     
					 ,SCH016.DLFL                 = IFR019.DLFL                           --오더 삭제 지시자  
					 ,SCH016.ROUTE                = IFR019.ROUTE                          --항차 
					 ,SCH016.KUNNR                = IFR019.KUNNR                          --판매처 
					 ,SCH016.KUNNRT               = IFR019.NAME1                          --판매처명	
					 ,SCH016.SLITER               = IFR019.SLITER                         --슬리터구분		 					 					  

           ,SCH016.UPDDATE              = sysdate                               --수정일시
           ,SCH016.UPDID                = 'sp_IFR019'                           --수정자ID
           ,SCH016.USE_YN               =  case when IFR019.DLFL = 'Y' then 'N'            
                                                when IFR019.DLFL = 'N' then 'Y'
                                           end                                  --사용여부(Y:사용 N:미사용)	            
        WHERE IFR019.IF_STATUS in ('N','E')                                     --I/F상태, N:신규, S:성공, E:오류        
        AND   IFR019.AUFNR     =  i_AUFNR
        AND   IFR019.IF_IFR_NO =  i_IF_IFR_NO
    WHEN NOT MATCHED THEN
        INSERT (
            SCH016.WRK_ORDR_NO                                                  --작업지시번호-->작업지시 생성자 사용 WO + R  
           ,SCH016.WRK_ORDR_SEQNO                                               --작업지시순번
           ,SCH016.WRK_SEQNO                                                    --작업순서
           ,SCH016.ORDR_GEN_DT                                                  --지시생성일자           

 					 ,SCH016.ORDER_NO																											--오더번호                   
					 ,SCH016.PRE_ORDER_NO         											                  --이전 오더 번호       
					 ,SCH016.WERKS                											                  --플랜트코드          
					 ,SCH016.ORDER_NUM            											                  --생산지시 No        
					 ,SCH016.ORDER_SEQ            											                  --생산지시 seq       
					 ,SCH016.PRD_REQ_DT           											                  --생산요청일자         
					 ,SCH016.ORDER_DIV            											                  --오더유형           
					 ,SCH016.ORDER_DIV_NM         											                  --오더유형 텍스트       
					 ,SCH016.MATNR                											                  --자재 코드          
					 ,SCH016.MACHINE              											                  --생산호기           
					 ,SCH016.MACHINE_NM           											                  --생산 호기명         
					 ,SCH016.TO_MACHINE           											                  --TO 생산호기        
					 ,SCH016.TO_MACHINE_NM        											                  --TO 생산 호기명      
					 ,SCH016.JMATNR               											                  --점보롤 자재 코드      
					 ,SCH016.PCODE                											                  --지종코드           
					 ,SCH016.BS_WGT               											                  --평량             
					 ,SCH016.MWIDTH               											                  --M/R 지폭         
					 ,SCH016.MWIDTH_INPUT         											                  --M/R 지폭_INPUT   
					 ,SCH016.MWIDTH_SLITER        											                  --M/R 지폭_SLITER  
					 ,SCH016.MROLLCNT             											                  --M/R 권치수        
					 ,SCH016.MRCNT                											                  --M/R 폭수         
					 ,SCH016.MBRGEW               											                  --M/R 중량         
					 ,SCH016.UNIT                 											                  --단위             
					 ,SCH016.JRCNT                											                  --J/R 개수         
					 ,SCH016.OVBELN               											                  --판매문서           
					 ,SCH016.OPOSNR               											                  --판매문서 항목번호      
					 ,SCH016.OAUART_DIV           											                  --판매문서 유형        
					 ,SCH016.OAUART_NM            											                  --판매 문서 오더 유형 텍스트
					 ,SCH016.VBELN                											                  --판매문서           
					 ,SCH016.POSNR                											                  --판매문서 항목번호      
					 ,SCH016.VDATU                											                  --납품 요청일자        
					 ,SCH016.SAUART_DIV           											                  --판매문서 유형        
					 ,SCH016.SAUART_NM            											                  --판매 문서 오더 유형 텍스트
					 ,SCH016.ORDER_RMK             											                  --비고(22-06-08:REMARK->ORDER_RMK로 변경함)              
					 ,SCH016.SHEET                											                  --판지 구분자         
					 ,SCH016.SLITER_SET           											                  --슬리터 구분         
					 ,SCH016.MRLDCK               											                  --밀롤 창고 적치 여부    
					 ,SCH016.CUTTER               											                  --카터             
					 ,SCH016.ATN_BOM_NO           											                  --대체Bom          
					 ,SCH016.BOM_NO               											                  --BOM Num        
					 ,SCH016.PRT_MATNR_QTY        											                  --모품목기준수량        
					 ,SCH016.PRT_MATNR_UNIT       											                  --모품목기준수량 단위     
					 ,SCH016.DLFL                 											                  --오더 삭제 지시자 
					 ,SCH016.ROUTE                                                        --항차
					 ,SCH016.KUNNR                                                        --판매처
					 ,SCH016.KUNNRT                                                       --판매처명	
					 ,SCH016.SLITER			 					                                        --슬리터구분
					 ,SCH016.WRK_ORDR_QTY

           ,SCH016.COMP_YN                                                      --완료여부
           ,SCH016.REGDATE                                                      --등록일시
           ,SCH016.REGID                                                        --등록자ID
           ,SCH016.UPDDATE                                                      --수정일시
           ,SCH016.UPDID                                                        --수정자ID
           ,SCH016.USE_YN                                                       --사용여부(Y:사용 N:미사용)           
        )VALUES(
            V_WO_NO     																												--작업지시번호             
           ,1                                                                   --작업지시순번   
           ,SUBSTR(V_WO_NO,-4)                                                  --작업순서(작업지시번호,-4)
           ,TO_CHAR(sysdate,'YYYYMMDD')                                          --지시생성일자             

					 ,IFR019.AUFNR																												--오더번호                   
					 ,IFR019.FRAUFNR                           														--이전 오더 번호       
					 ,IFR019.WERKS                          															--플랜트코드          
					 ,IFR019.ORDER_NUM                      															--생산지시 No        
					 ,IFR019.ORDER_SEQ                      															--생산지시 seq       
					 ,IFR019.BUDAT                          															--생산요청일자         
					 ,IFR019.AUART                          															--오더유형           
					 ,IFR019.AUARTXT                        															--오더유형 텍스트       
					 ,IFR019.MMATNR                         															--자재 코드          
					 ,IFR019.MACHINE                        															--생산호기           
					 ,IFR019.MACHINETXT                     															--생산 호기명         
					 ,IFR019.TOMACHINE                      															--TO 생산호기        
					 ,IFR019.TOMACHINETXT                   															--TO 생산 호기명      
					 ,IFR019.MATNR                          															--점보롤 자재 코드      
					 ,IFR019.PCODE                          															--지종코드           
					 ,IFR019.WEIGHT                         															--평량             
					 ,IFR019.MWIDTH                         															--M/R 지폭         
					 ,IFR019.MWIDTH_INPUT                   															--M/R 지폭_INPUT   
					 ,IFR019.MWIDTH_SLITER                  															--M/R 지폭_SLITER  
					 ,IFR019.MROLLCNT                       															--M/R 권치수        
					 ,IFR019.MRCNT                          															--M/R 폭수         
					 ,IFR019.MBRGEW                         															--M/R 중량         
					 ,IFR019.MGEWEI                         															--단위             
					 ,IFR019.JRCNT                          															--J/R 개수         
					 ,IFR019.OVBELN                         															--판매문서           
					 ,IFR019.OPOSNR                         															--판매문서 항목번호      
					 ,IFR019.OAUART                         															--판매문서 유형        
					 ,IFR019.OAUARTXT                       															--판매 문서 오더 유형 텍스트
					 ,IFR019.VBELN                          															--판매문서           
					 ,IFR019.POSNR                          															--판매문서 항목번호      
					 ,IFR019.VDATU                          															--납품 요청일자        
					 ,IFR019.SAUART                         															--판매문서 유형        
					 ,IFR019.SAUARTXT                       															--판매 문서 오더 유형 텍스트
					 ,IFR019.REMARK                         															--비고             
					 ,IFR019.SHEET                          															--판지 구분자         
					 ,IFR019.SLITER_SET                     															--슬리터 구분         
					 ,IFR019.MRLDCK                         															--밀롤 창고 적치 여부    
					 ,IFR019.CUTTER                         															--카터             
					 ,IFR019.STLNR                          															--대체Bom          
					 ,IFR019.STLAL                          															--BOM Num        
					 ,IFR019.BMENG                          															--모품목기준수량        
					 ,IFR019.BMEIN                          															--모품목기준수량 단위     
					 ,IFR019.DLFL                           															--오더 삭제 지시자 
					 ,IFR019.ROUTE                                                        --항차
					 ,IFR019.KUNNR                                                        --판매처
					 ,IFR019.NAME1                                                        --판매처명				 					 
           ,IFR019.SLITER			 					                                        --슬리터구분
					 ,IFR019.MBRGEW               											                  --M/R 중량             

           ,'N'                                                                  --완료여부               
           ,sysdate                                                             --등록일시               
           ,'sp_IFR019'                                                             --등록자ID              
           ,null                                                                --수정일시               
           ,null                                                                --수정자ID 
           ,case when IFR019.DLFL = 'X' then 'N'                    
                 else 'Y'                 
            end                                                                 --사용여부(Y:사용 N:미사용)	                        
        )
        WHERE IFR019.IF_STATUS in ('N','E')  /*  I/F상태, N:신규, S:성공, E:오류   */
        AND   IFR019.AUFNR     =  i_AUFNR
        AND   IFR019.IF_IFR_NO =  i_IF_IFR_NO         
    ; 


    --작업지시 생성되면 작업지시BOM을 구성한다.                           
      --작업지시정보 추출
      SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, WERKS INTO V_WO_NO,V_WO_SEQ,V_WERKS
      FROM TB_SCH016
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
            ,'sp_ifr019'
            ,null
            ,null
      FROM TB_SCH001          
      WHERE  AUFNR  =  i_AUFNR;       
    END IF;                               



    o_msg_MSG  :=  'TB_IFR019, 생산오더-밀롤,슬리터가 수신되었습니다.1' || ',' || SQLERRM ;

    UPDATE  TB_IFR019_TMP
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    AUFNR     =  i_AUFNR
    AND    IF_IFR_NO =  i_IF_IFR_NO      
    ;

    o_msg_MSG  :=  'TB_IFR019, 생산오더-밀롤,슬리터가 수신되었습니다.2' || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
                o_msg_MSG  :=  'TB_IFR019, 생산오더-밀롤,슬리터 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                o_msg_code      := '-1' ;
                DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                ROLLBACK;

                UPDATE  TB_IFR019_TMP
                SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                      , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                      , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
                WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
                AND    AUFNR     =  i_AUFNR
                AND    IF_IFR_NO =  i_IF_IFR_NO      
                ;

END  sp_ifr019 ;
/* ------- TB_IFR019 : 생산오더-밀롤,슬리터  End --------------------------- */


/* ------- TB_IFR020 : 생산오더-재단  Begin ------------------------->22-08-31 재단출고여부'X'일때 WCS로 넘기는 S/P통합함. */
PROCEDURE sp_ifr020 (  i_IF_IFR_NO      IN   NUMBER   /* MES Interface Sequence(수신번호)        */
                      ,i_AUFNR          IN   VARCHAR2
                      ,i_ZCOR           IN   VARCHAR2                      
                      ,o_msg_CODE       OUT  VARCHAR2
                      ,o_msg_MSG        OUT  VARCHAR2  ) is

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
    FROM TB_IFR020_TMP
    WHERE AUFNR = i_AUFNR
    AND IF_IFR_NO = i_IF_IFR_NO;    

    IF V_DLFL = 'X' THEN
      UPDATE TB_SCH008
      SET DLFL = V_DLFL
      WHERE AUFNR =  i_AUFNR;

      UPDATE TB_SCH017
      SET USE_YN = 'N'
      WHERE ORDER_NO =  i_AUFNR;             

      o_msg_MSG  :=  'TB_IFR020, 생산오더-재단 삭제 수신되었습니다.1' || ',' || SQLERRM ;

      UPDATE  TB_IFR020_TMP
      SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
            , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
            , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
      WHERE  AUFNR     =  i_AUFNR
      AND    IF_IFR_NO =  i_IF_IFR_NO           
      ;

      o_msg_MSG  :=  'TB_IFR020, 생산오더-재단 삭제 수신되었습니다.2' || ',' || SQLERRM ;
      o_msg_code := '0' ;
      RETURN;    
    END IF;

    --재단출고여부 'X'이면 WCS로 I/F 한다.(sp_ifr020_X 분리된것을 여기에 통합함) 22-08-31 
    IF i_ZCOR = 'X' THEN
      V_DOC_NO := FN_GET_MDOCNO('M','IFWC006');
      
      SELECT NVL(FRAUFNR,'@') INTO V_FRAUFNR
      FROM TB_IFR020_TMP
      WHERE IF_IFR_NO =  i_IF_IFR_NO;
      
      IF  V_FRAUFNR = '@' THEN
          o_msg_MSG  :=  'TB_IFR020, 이전오더번호가 없습니다.';
          o_msg_code := '-1' ;
          DBMS_OUTPUT.PUT_LINE (o_msg_msg );
          ROLLBACK;

          UPDATE  TB_IFR020_TMP
          SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
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
      SELECT NVL((SELECT IND_BCD 
                  FROM TB_INV001 
                  WHERE (ORDER_NO = V_FRAUFNR or LOT_NO = V_FRAUFNR) 
                  AND STCK_QTY > 0 
                  AND ROWNUM=1),'@') INTO V_MILLROLL_BAR 
      FROM DUAL;
      
      IF  V_MILLROLL_BAR = '@' THEN
          o_msg_MSG  :=  'TB_IFR020, WCS를 위한 밀롤바코드번호를 찾지 못했습니다.';
          o_msg_code := '-1' ;
          DBMS_OUTPUT.PUT_LINE (o_msg_msg );
          ROLLBACK;

          UPDATE  TB_IFR020_TMP
          SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
          WHERE  IF_IFR_NO =  i_IF_IFR_NO;    
          
          RETURN;      
      END IF;      

      INSERT INTO TB_IFSWC006(
         DOC_NO     							 --문서번호                                         
        ,DOC_NOSEQ                 --문서번호 순번   

        ,BARCODE                   --밀롤바코드
        ,CT_LOT_ID
        ,WRKORD                    --ERP 생산오더번호                                 
        ,PLNT_CD                   --플랜트                                           
        ,WORK_DT                   --생산 계획일 (YYYYMMDD)                           
        ,MCHN_CD                   --투입할 Cutter 호기(PM3)                          
        ,REMARK5                   --비고5                                            
        ,REMARK6                   --비고6                                            
        ,SPECIAL_NO                --ERP 특별재고번호                                 
        ,REMARK8                   --비고8                                            
        ,REMARK1                   --비고1                                            
        ,REMARK2                   --비고2                                            
        ,LOT_ID                    --MR LOTID                                         
        ,CLASS                     --반                                               
        ,MATERIAL_NO               --ERP 자재코드 (커터 자재코드)                     
        ,LENGTH                    --권치수, 길이(M)                                  
        ,WEIGHT                    --중량(KG)   
        ,WORK_DRCT                 --생산 작업 지시사항
        ,WORK_TIME                 --생산 계획 시간 (HHMM)
        ,WORK_SEQ                  --생산 계획 순번
        ,AUFNR                     --오더번호

        ,IF_STATUS                 --WCS 결과값 Return( N:대기,S:성공, E:오류 )       
        ,IF_GET_DATE               --MES 등록일시                                     
        ,IF_SET_DATE               --WCS 전송일시                                     
        ,IF_ERR_MESS               --WCS 결과 메시지                                  
        ,IF_MES_KEY                --MES Inserface Key
      )
      SELECT 
         V_DOC_NO
        ,V_DOC_SEQ

        ,V_MILLROLL_BAR            --밀롤바코드
        ,'*'
        ,AUFNR                     --ERP 생산오더번호                       
        ,WERKS                     --플랜트                              
        ,BUDAT                     --생산 계획일 (YYYYMMDD)                
        ,MACHINE                   --투입할 Cutter 호기(PM3)               
        ,WLEN                      --비고5                              
        ,VLEN                      --비고6                              
        ,VBELN                     --ERP 특별재고번호                       
        ,PACKTYPE                  --비고8-포장타입                              
        ,KUNNR                     --비고1                              
        ,NAME1                     --비고2                              
        ,MRLOT                     --MR LOTID                         
        ,WORKGROUP                 --반                                
        ,MMATNR                    --ERP 자재코드 (커터 자재코드)               
        ,MROLLCNT                  --권치수, 길이(M)                       
        ,MBRGEW                    --중량(KG)  
        ,REMARK                                         --생산 작업 지시사항
        ,PTIM                      --생산 계획 시간 (HHMM)
        ,PSEQ                      --생산 계획 순번
        ,AUFNR                     --오더번호

        ,'N'
        ,sysdate
        ,null
        ,null
        ,null
      FROM TB_IFR020_TMP 
      WHERE IF_IFR_NO =  i_IF_IFR_NO;        
    END IF; 
    
    
    
    MERGE
    INTO  TB_SCH008 SCH008
    USING TB_IFR020_TMP IFR020
    ON    ( SCH008.AUFNR      =  IFR020.AUFNR
    AND     IFR020.AUFNR      =  i_AUFNR 
    AND     IFR020.IF_IFR_NO  =  i_IF_IFR_NO    )
    WHEN MATCHED THEN
         UPDATE
         SET    	SCH008.MRPO	             =	IFR020.MRPO		            /*	MRPO	,		밀롤 오더 번호		                    */
                ,	SCH008.WERKS	         =	IFR020.WERKS		        /*	WERKS	,		플랜트		                            */
                ,	SCH008.BUDAT	         =	IFR020.BUDAT		        /*	BUDAT	,		시작일자		                         */
                ,	SCH008.AUART	         =	IFR020.AUART		        /*	AUART	,		오더유형		                         */
                ,	SCH008.AUARTXT	         =	IFR020.AUARTXT		        /*	AUARTXT	,		오더유형 텍스트		                 */
                ,	SCH008.MACHINE	         =	IFR020.MACHINE		        /*	MACHINE	,		FROM 생산호기		                   */
                ,	SCH008.MACHINETXT	     =	IFR020.MACHINETXT		    /*	MACHINETXT	,		FROM 생산 호기명		             */
                ,	SCH008.TOMACHINE	     =	IFR020.TOMACHINE		    /*	TOMACHINE	,		TO 생산호기		                   */
                ,	SCH008.TOMACHINETXT	     =	IFR020.TOMACHINETXT		    /*	TOMACHINETXT	,		TO 생산 호기명		             */
                --,	SCH008.CVERID	         =	IFR020.CVERID		        /*	CVERID	,		생산 호기		                       */
                --,	SCH008.CVERIDTXT	     =	IFR020.PVERIDTXT		    /*	PVERIDTXT	,		생산 호기명		                   */
                ,	SCH008.CMATNR	         =	IFR020.CMATNR		        /*	CMATNR	,		재단 자재 코드		                   */
                ,	SCH008.PCODE	         =	IFR020.PCODE		        /*	PCODE	,		지종		                             */
                ,	SCH008.WEIGHT	         =	IFR020.WEIGHT		        /*	WEIGHT	,		평량		                           */
                ,	SCH008.WLEN	             =	IFR020.WLEN		            /*	WLEN	,		가로길		                             */
                ,	SCH008.VLEN	             =	IFR020.VLEN		            /*	VLEN	,		세로길		                             */
                ,	SCH008.CTCNT	         =	IFR020.CTCNT		        /*	CTCNT	,		폭수		                              */
                ,	SCH008.CNT	             =	IFR020.CNT		            /*	CNT	,		수량		                                */
                ,	SCH008.CGEWEW	         =	IFR020.CGEWEW		        /*	CGEWEW	,		총중량		                           */
                ,	SCH008.CGEWEI	         =	IFR020.CGEWEI		        /*	CGEWEI	,		단위		                            */
                ,	SCH008.ZZATT1	         =	IFR020.ZZATT1		        /*	ZZATT1	,		팔레트당연수		                      */
                ,	SCH008.ZZATT2	         =	IFR020.ZZATT2		        /*	ZZATT2	,		속당매수		                         */
                ,	SCH008.DOUBLEFLAG	     =	IFR020.DOUBLEFLAG		    /*	DOUBLEFLAG	,		쌍팔레트		                     */
                ,	SCH008.VBELN	         =	IFR020.VBELN		        /*	VBELN	,		판매문서		                           */
                ,	SCH008.POSNR	         =	IFR020.POSNR		        /*	POSNR	,		판매문서 항목번호		                     */
                ,	SCH008.SAUART	         =	IFR020.SAUART		        /*	SAUART	,		판매문서 유형		                      */
                ,	SCH008.SAUARTXT	         =	IFR020.SAUARTXT		        /*	SAUARTXT	,		판매 문서 오더 유형 텍스트		         */
                ,	SCH008.OVBELN	         =	IFR020.OVBELN		        /*	OVBELN	,		판매문서		                         */
                ,	SCH008.OPOSNR	         =	IFR020.OPOSNR		        /*	OPOSNR	,		판매문서 항목번호		                   */
                ,	SCH008.OAUART	         =	IFR020.OAUART		        /*	OAUART	,		판매문서 유형		                      */
                ,	SCH008.OAUARTXT	         =	IFR020.OAUARTXT		        /*	OAUARTXT	,		판매 문서 오더 유형 텍스트		         */
                ,	SCH008.CUTTER	         =	IFR020.CUTTER		        /*	CUTTER	,		카터		                             */
                ,	SCH008.STLNR	         =	IFR020.STLNR		        /*	STLNR	,		BOM Num		                            */
                ,	SCH008.STLAL	         =	IFR020.STLAL		        /*	STLAL	,		대체Bom		                             */
                ,	SCH008.BMENG	         =	IFR020.BMENG		        /*	BMENG	,		모품목기준수량		                        */
                ,	SCH008.BMEIN	         =	IFR020.BMEIN		        /*	BMEIN	,		모품목기준수량 단위		                   */
                ,	SCH008.DLFL	             =	IFR020.DLFL		            /*	DLFL	,		오더 삭제 지시자		                      */
                ,	SCH008.ROUTE	         =	IFR020.ROUTE		        /*	ROUTE	,		항차		                               */
                , SCH008.ZCOR            =  IFR020.ZCOR             --재단출고오더여부
                , SCH008.ORDER_RMK       =  IFR020.REMARK           --비고
                , SCH008.KUNNR           =  IFR020.KUNNR            --판매처
                , SCH008.KUNNRT          =  IFR020.NAME1            --판매처명 
                , SCH008.FRAUFNR         =  IFR020.FRAUFNR          --이전오더                             

                , SCH008.UPDDATE             =  sysdate                     /*  수정일자                                          */
                , SCH008.UPDID               =  'sp_ifr020'                 /*  수정자                                            */
          WHERE  IFR020.IF_STATUS in ('N','E')                              /*  I/F상태, N:신규, S:성공, E:오류                     */
          AND    IFR020.AUFNR     =  i_AUFNR
          AND    IFR020.IF_IFR_NO =  i_IF_IFR_NO    
    WHEN NOT MATCHED THEN
         INSERT (  	SCH008.AUFNR			                               /*	AUFNR	,		오더번호		                               */
                  ,	SCH008.MRPO			                                   /*	MRPO	,		밀롤 오더 번호		                          */
                  ,	SCH008.WERKS			                               /*	WERKS	,		플랜트		                                  */
                  ,	SCH008.BUDAT			                               /*	BUDAT	,		시작일자		                                */
                  ,	SCH008.AUART			                               /*	AUART	,		오더유형		                                */
                  ,	SCH008.AUARTXT			                               /*	AUARTXT	,		오더유형 텍스트		                        */
                  ,	SCH008.MACHINE			                               /*	MACHINE	,		FROM 생산호기		                          */
                  ,	SCH008.MACHINETXT			                           /*	MACHINETXT	,		FROM 생산 호기명		                   */
                  ,	SCH008.TOMACHINE			                           /*	TOMACHINE	,		TO 생산호기		                          */
                  ,	SCH008.TOMACHINETXT			                           /*	TOMACHINETXT	,		TO 생산 호기명		                   */
                  --,	SCH008.CVERID			                               /*	CVERID	,		생산 호기		                              */
                  --,	SCH008.CVERIDTXT			                           /*	PVERIDTXT	,		생산 호기명		                         */
                  ,	SCH008.CMATNR			                               /*	CMATNR	,		재단 자재 코드		                         */
                  ,	SCH008.PCODE			                               /*	PCODE	,		지종		                                   */
                  ,	SCH008.WEIGHT			                               /*	WEIGHT	,		평량		                                 */
                  ,	SCH008.WLEN			                                   /*	WLEN	,		가로길		                                   */
                  ,	SCH008.VLEN			                                   /*	VLEN	,		세로길		                                   */
                  ,	SCH008.CTCNT			                               /*	CTCNT	,		폭수		                                    */
                  ,	SCH008.CNT			                                   /*	CNT	,		수량		                                      */
                  ,	SCH008.CGEWEW			                               /*	CGEWEW	,		총중량		                                  */
                  ,	SCH008.CGEWEI			                               /*	CGEWEI	,		단위		                                  */
                  ,	SCH008.ZZATT1			                               /*	ZZATT1	,		팔레트당연수		                            */
                  ,	SCH008.ZZATT2			                               /*	ZZATT2	,		속당매수		                                */
                  ,	SCH008.DOUBLEFLAG			                           /*	DOUBLEFLAG	,		쌍팔레트		                            */
                  ,	SCH008.VBELN			                               /*	VBELN	,		판매문서		                                  */
                  ,	SCH008.POSNR			                               /*	POSNR	,		판매문서 항목번호		                           */
                  ,	SCH008.SAUART			                               /*	SAUART	,		판매문서 유형		                             */
                  ,	SCH008.SAUARTXT			                               /*	SAUARTXT	,		판매 문서 오더 유형 텍스트		                */
                  ,	SCH008.OVBELN			                               /*	OVBELN	,		판매문서		                                */
                  ,	SCH008.OPOSNR			                               /*	OPOSNR	,		판매문서 항목번호		                          */
                  ,	SCH008.OAUART			                               /*	OAUART	,		판매문서 유형		                             */
                  ,	SCH008.OAUARTXT			                               /*	OAUARTXT	,		판매 문서 오더 유형 텍스트		                */
                  ,	SCH008.CUTTER			                               /*	CUTTER	,		카터		                                    */
                  ,	SCH008.STLNR			                               /*	STLNR	,		BOM Num		                                   */
                  ,	SCH008.STLAL			                               /*	STLAL	,		대체Bom		                                    */
                  ,	SCH008.BMENG			                               /*	BMENG	,		모품목기준수량		                              */
                  ,	SCH008.BMEIN			                               /*	BMEIN	,		모품목기준수량 단위		                          */
                  ,	SCH008.DLFL			                                   /*	DLFL	,		오더 삭제 지시자		                            */
                  ,	SCH008.ROUTE			                           /*	ROUTE	,		항차		                                      */
                  , SCH008.ZCOR                                      --재단출고오더여부
                  , SCH008.ORDER_RMK                                 --비고
                  , SCH008.KUNNR                                     --판매처
                  , SCH008.KUNNRT                                    --판매처명  
                  , SCH008.MAUFNR												 						 --M/R LOT Number           
                  , SCH008.PTIM                          						 --생산 계획 시간 (HHMM)          
                  , SCH008.PSEQ                          						 --IS-M: Production Sequence
                  , SCH008.WORKGROUP                     						 --반                        
                  , SCH008.MMATNR                        						 --자재 번호                    
                  , SCH008.MROLLCNT                      						 --M/R 권치수                  
                  , SCH008.MBRGEW                        						 --M/ROLL 중량                
                  , SCH008.MGEWEI                        						 --중량 단위                    
                  , SCH008.CORESIZE                      						 --밀롤 지관 인치(SIZE)           
                  , SCH008.PACKTYPE                      						 --포장타입    
                  , SCH008.FRAUFNR                                   --이전오더                                            

                  ,	SCH008.REGDATE							               /*	등록일자			                                     */
                  ,	SCH008.REGID							               /*	등록자			                                       */
                  ,	SCH008.UPDDATE							               /*	수정일자			                                     */
                  ,	SCH008.UPDID							               /*	수정자			                                       */
                    )
         VALUES (   IFR020.AUFNR			                               /*	AUFNR	,		오더번호		                               */
                  ,	IFR020.MRPO			                                   /*	MRPO	,		밀롤 오더 번호		                          */
                  ,	IFR020.WERKS			                               /*	WERKS	,		플랜트		                                  */
                  ,	IFR020.BUDAT			                               /*	BUDAT	,		시작일자		                                */
                  ,	IFR020.AUART			                               /*	AUART	,		오더유형		                                */
                  ,	IFR020.AUARTXT			                               /*	AUARTXT	,		오더유형 텍스트		                        */
                  ,	IFR020.MACHINE			                               /*	MACHINE	,		FROM 생산호기		                          */
                  ,	IFR020.MACHINETXT			                           /*	MACHINETXT	,		FROM 생산 호기명		                   */
                  ,	IFR020.TOMACHINE			                           /*	TOMACHINE	,		TO 생산호기		                          */
                  ,	IFR020.TOMACHINETXT			                           /*	TOMACHINETXT	,		TO 생산 호기명		                   */
                  --,	IFR020.CVERID			                               /*	CVERID	,		생산 호기		                              */
                  --,	IFR020.PVERIDTXT			                           /*	PVERIDTXT	,		생산 호기명		                         */
                  ,	IFR020.CMATNR			                               /*	CMATNR	,		재단 자재 코드		                         */
                  ,	IFR020.PCODE			                               /*	PCODE	,		지종		                                   */
                  ,	IFR020.WEIGHT			                               /*	WEIGHT	,		평량		                                 */
                  ,	IFR020.WLEN			                                   /*	WLEN	,		가로길		                                   */
                  ,	IFR020.VLEN			                                   /*	VLEN	,		세로길		                                   */
                  ,	IFR020.CTCNT			                               /*	CTCNT	,		폭수		                                    */
                  ,	IFR020.CNT			                                   /*	CNT	,		수량		                                      */
                  ,	IFR020.CGEWEW			                               /*	CGEWEW	,		총중량		                                  */
                  ,	IFR020.CGEWEI			                               /*	CGEWEI	,		단위		                                  */
                  ,	IFR020.ZZATT1			                               /*	ZZATT1	,		팔레트당연수		                            */
                  ,	IFR020.ZZATT2			                               /*	ZZATT2	,		속당매수		                                */
                  ,	IFR020.DOUBLEFLAG			                           /*	DOUBLEFLAG	,		쌍팔레트		                            */
                  ,	IFR020.VBELN			                               /*	VBELN	,		판매문서		                                  */
                  ,	IFR020.POSNR			                               /*	POSNR	,		판매문서 항목번호		                           */
                  ,	IFR020.SAUART			                               /*	SAUART	,		판매문서 유형		                             */
                  ,	IFR020.SAUARTXT			                               /*	SAUARTXT	,		판매 문서 오더 유형 텍스트		                */
                  ,	IFR020.OVBELN			                               /*	OVBELN	,		판매문서		                                */
                  ,	IFR020.OPOSNR			                               /*	OPOSNR	,		판매문서 항목번호		                          */
                  ,	IFR020.OAUART			                               /*	OAUART	,		판매문서 유형		                             */
                  ,	IFR020.OAUARTXT			                               /*	OAUARTXT	,		판매 문서 오더 유형 텍스트		                */
                  ,	IFR020.CUTTER			                               /*	CUTTER	,		카터		                                    */
                  ,	IFR020.STLNR			                               /*	STLNR	,		BOM Num		                                   */
                  ,	IFR020.STLAL			                               /*	STLAL	,		대체Bom		                                    */
                  ,	IFR020.BMENG			                               /*	BMENG	,		모품목기준수량		                              */
                  ,	IFR020.BMEIN			                               /*	BMEIN	,		모품목기준수량 단위		                          */
                  ,	IFR020.DLFL			                                   /*	DLFL	,		오더 삭제 지시자		                            */
                  ,	IFR020.ROUTE			                           /*	ROUTE	,		항차		                                      */
                  , IFR020.ZCOR                                       --재단출고오더여부
                  , IFR020.REMARK                                     --비고
                  , IFR020.KUNNR                                      --판매처
                  , IFR020.NAME1                                      --판매처명
                  , IFR020.MAUFNR												 						  --M/R LOT Number           
                  , IFR020.PTIM                          						  --생산 계획 시간 (HHMM)          
                  , IFR020.PSEQ                          						  --IS-M: Production Sequence
                  , IFR020.WORKGROUP                     						  --반                        
                  , IFR020.MMATNR                        						  --자재 번호                    
                  , IFR020.MROLLCNT                      						  --M/R 권치수                  
                  , IFR020.MBRGEW                        						  --M/ROLL 중량                
                  , IFR020.MGEWEI                        						  --중량 단위                    
                  , IFR020.CORESIZE                      						  --밀롤 지관 인치(SIZE)           
                  , IFR020.PACKTYPE                      						  --포장타입  
                  , IFR020.FRAUFNR                                    --이전오더                      

                  , sysdate                                                /*   등록일자                                               */
                  , 'sp_ifr020'                                            /*   등록자                                                 */
                  , null                                                   /*   수정일자                                                */
                  , null                                                   /*   수정자                                                 */
                    )
         WHERE  IFR020.IF_STATUS in ('N','E')  /*  I/F상태, N:신규, S:성공, E:오류   */
         AND    IFR020.AUFNR     =  i_AUFNR
         AND    IFR020.IF_IFR_NO =  i_IF_IFR_NO    
         ;


    --========================================
    --KHJ추가 2022-05-02:작업지시-재단
    --========================================
    ------------------------------------------
    --작업지시가 존재하지 않으면 작업지시 번호 생성
    SELECT COUNT(ORDER_NO) INTO V_CNT
    FROM TB_SCH017
    WHERE ORDER_NO = i_AUFNR;

    IF V_CNT = 0 THEN
      SELECT BUDAT INTO V_WO_DT
      FROM TB_IFR020_TMP
      WHERE IF_IFR_NO  =  i_IF_IFR_NO;

      SP_GET_DOC_SEQ('WOCA',V_WO_DT,V_WO_NO); 
    END IF;
    ------------------------------------------

    MERGE
        INTO  TB_SCH017 SCH017
        USING TB_IFR020_TMP IFR020
           ON ( SCH017.ORDER_NO   =  IFR020.AUFNR
           AND  IFR020.AUFNR      =  i_AUFNR 
           AND  IFR020.IF_IFR_NO  =  i_IF_IFR_NO   )
    WHEN MATCHED THEN    
        UPDATE SET
					  SCH017.PRE_ORDER_NO         = IFR020.FRAUFNR                        --이전 오더 번호       
					 ,SCH017.WERKS                = IFR020.WERKS                          --플랜트코드          
					 ,SCH017.PRD_REQ_DT           = IFR020.BUDAT                          --생산요청일자         
					 ,SCH017.ORDER_DIV            = IFR020.AUART                          --오더유형           
					 ,SCH017.ORDER_DIV_NM         = IFR020.AUARTXT                        --오더유형 텍스트       
					 ,SCH017.MACHINE              = IFR020.MACHINE                        --FROM 생산호기      
					 ,SCH017.MACHINE_NM           = IFR020.MACHINETXT                     --FROM 생산 호기명    
					 ,SCH017.TO_MACHINE           = IFR020.TOMACHINE                      --TO 생산호기        
					 ,SCH017.TO_MACHINE_NM        = IFR020.TOMACHINETXT                   --TO 생산 호기명      
					 ,SCH017.MATNR                = IFR020.CMATNR                         --자재 코드          
					 ,SCH017.PCODE                = IFR020.PCODE                          --지종             
					 ,SCH017.BS_WGT               = IFR020.WEIGHT                         --평량             
					 ,SCH017.VLEN                 = IFR020.VLEN                           --세로길            
					 ,SCH017.WLEN                 = IFR020.WLEN                           --가로길            
					 ,SCH017.PKCNT                = IFR020.CTCNT                          --폭수             
					 ,SCH017.WRK_ORDR_QTY         = IFR020.CNT                            --생산지시량          
					 ,SCH017.TOT_WGT              = IFR020.CGEWEW                         --총중량            
					 ,SCH017.UNIT                 = IFR020.CGEWEI                         --단위             
					 ,SCH017.PLT_PER_CNT          = IFR020.ZZATT1                         --팔레트당연수         
					 ,SCH017.IN_PER_CNT           = IFR020.ZZATT2                         --속당매수           
					 ,SCH017.DBL_FLAG             = IFR020.DOUBLEFLAG                     --쌍팔레트           
					 ,SCH017.VBELN                = IFR020.VBELN                          --판매문서           
					 ,SCH017.POSNR                = IFR020.POSNR                          --판매문서 항목번호      
					 ,SCH017.SAUART_DIV           = IFR020.SAUART                         --판매문서 유형        
					 ,SCH017.SAUART_NM            = IFR020.SAUARTXT                       --판매 문서 오더 유형 텍스트
					 ,SCH017.OVBELN               = IFR020.OVBELN                         --판매문서           
					 ,SCH017.OPOSNR               = IFR020.OPOSNR                         --판매문서 항목번호      
					 ,SCH017.OAUART_DIV           = IFR020.OAUART                         --판매문서 유형        
					 ,SCH017.OAUART_NM            = IFR020.OAUARTXT                       --판매 문서 오더 유형 텍스트
					 ,SCH017.CUTTER               = IFR020.CUTTER                         --카터             
					 ,SCH017.BOM_NO               = IFR020.STLNR                          --BOM Num        
					 ,SCH017.ATN_BOM_NO           = IFR020.STLAL                          --대체Bom          
					 ,SCH017.PRT_MATNR_QTY        = IFR020.BMENG                          --모품목기준수량        
					 ,SCH017.PRT_MATNR_UNIT       = IFR020.BMEIN                          --모품목기준수량 단위     
					 ,SCH017.DLFL                 = IFR020.DLFL                           --오더 삭제 지시자      
					 ,SCH017.ZCOR                 = IFR020.ZCOR                           --재단출고 오더 여부  
					 ,SCH017.ORDER_RMK            = IFR020.REMARK                         --비고
					 ,SCH017.ROUTE                = IFR020.ROUTE                          --항차
					 ,SCH017.KUNNR                = IFR020.KUNNR                          --판매처
					 ,SCH017.KUNNRT               = IFR020.NAME1                          --판매처명
					 ,SCH017.MAUFNR								= IFR020.MAUFNR     										--M/R LOT Number           
					 ,SCH017.PTIM                 = IFR020.PTIM                           --생산 계획 시간 (HHMM)          
					 ,SCH017.PSEQ                 = IFR020.PSEQ                           --IS-M: Production Sequence
					 ,SCH017.WORKGROUP            = IFR020.WORKGROUP                      --반                        
					 ,SCH017.MMATNR               = IFR020.MMATNR                         --자재 번호                    
					 ,SCH017.MROLLCNT             = IFR020.MROLLCNT                       --M/R 권치수                  
					 ,SCH017.MBRGEW               = IFR020.MBRGEW                         --M/ROLL 중량                
					 ,SCH017.MGEWEI               = IFR020.MGEWEI                         --중량 단위                    
					 ,SCH017.CORESIZE             = IFR020.CORESIZE                       --밀롤 지관 인치(SIZE)           
					 ,SCH017.PACKTYPE             = IFR020.PACKTYPE                       --포장타입 					 

           ,SCH017.UPDDATE              = sysdate                               --수정일시
           ,SCH017.UPDID                = 'sp_IFR020'                               --수정자ID
           ,SCH017.USE_YN               =  case when IFR020.DLFL = 'Y' then 'N'            
                                                when IFR020.DLFL = 'N' then 'Y'
                                           end                                  --사용여부(Y:사용 N:미사용)	            
        WHERE IFR020.IF_STATUS in ('N','E')                                     --I/F상태, N:신규, S:성공, E:오류        
        AND   IFR020.AUFNR     =  i_AUFNR
        AND   IFR020.IF_IFR_NO =  i_IF_IFR_NO
    WHEN NOT MATCHED THEN
        INSERT (
            SCH017.WRK_ORDR_NO                                                  --작업지시번호-->작업지시 생성자 사용 WO + R  
           ,SCH017.WRK_ORDR_SEQNO                                               --작업지시순번
           ,SCH017.WRK_SEQNO                                                    --작업순서
           ,SCH017.ORDR_GEN_DT                                                  --지시생성일자           

					 ,SCH017.ORDER_NO																											--오더번호             
					 ,SCH017.PRE_ORDER_NO          													              --이전 오더 번호       
					 ,SCH017.WERKS                 													              --플랜트코드          
					 ,SCH017.PRD_REQ_DT            													              --생산요청일자         
					 ,SCH017.ORDER_DIV             													              --오더유형           
					 ,SCH017.ORDER_DIV_NM          													              --오더유형 텍스트       
					 ,SCH017.MACHINE               													              --FROM 생산호기      
					 ,SCH017.MACHINE_NM            													              --FROM 생산 호기명    
					 ,SCH017.TO_MACHINE            													              --TO 생산호기        
					 ,SCH017.TO_MACHINE_NM         													              --TO 생산 호기명      
					 ,SCH017.MATNR                 													              --자재 코드          
					 ,SCH017.PCODE                 													              --지종             
					 ,SCH017.BS_WGT                													              --평량             
					 ,SCH017.VLEN                  													              --세로길            
					 ,SCH017.WLEN                  													              --가로길            
					 ,SCH017.PKCNT                 													              --폭수             
					 ,SCH017.WRK_ORDR_QTY          													              --생산지시량          
					 ,SCH017.TOT_WGT               													              --총중량            
					 ,SCH017.UNIT                  													              --단위             
					 ,SCH017.PLT_PER_CNT           													              --팔레트당연수         
					 ,SCH017.IN_PER_CNT            													              --속당매수           
					 ,SCH017.DBL_FLAG              													              --쌍팔레트           
					 ,SCH017.VBELN                 													              --판매문서           
					 ,SCH017.POSNR                 													              --판매문서 항목번호      
					 ,SCH017.SAUART_DIV            													              --판매문서 유형        
					 ,SCH017.SAUART_NM             													              --판매 문서 오더 유형 텍스트
					 ,SCH017.OVBELN                													              --판매문서           
					 ,SCH017.OPOSNR                													              --판매문서 항목번호      
					 ,SCH017.OAUART_DIV            													              --판매문서 유형        
					 ,SCH017.OAUART_NM             													              --판매 문서 오더 유형 텍스트
					 ,SCH017.CUTTER                													              --카터             
					 ,SCH017.BOM_NO                													              --BOM Num        
					 ,SCH017.ATN_BOM_NO            													              --대체Bom          
					 ,SCH017.PRT_MATNR_QTY         													              --모품목기준수량        
					 ,SCH017.PRT_MATNR_UNIT        													              --모품목기준수량 단위     
					 ,SCH017.DLFL                  													              --오더 삭제 지시자      
					 ,SCH017.ZCOR                  													              --재단출고 오더 여부  
					 ,SCH017.ORDER_RMK                                                    --비고
					 ,SCH017.ROUTE                                                        --항차
					 ,SCH017.KUNNR                                                        --판매처
					 ,SCH017.KUNNRT                                                       --판매처명
					 ,SCH017.MAUFNR								  																			--M/R LOT Numb					 
					 ,SCH017.PTIM                                       									--생산 계획 시간    
					 ,SCH017.PSEQ                                       									--IS-M: Produc
					 ,SCH017.WORKGROUP                                  									--반           
					 ,SCH017.MMATNR                                     									--자재 번호       
					 ,SCH017.MROLLCNT                                   									--M/R 권치수     
					 ,SCH017.MBRGEW                                     									--M/ROLL 중량   
					 ,SCH017.MGEWEI                                     									--중량 단위       
					 ,SCH017.CORESIZE                                   									--밀롤 지관 인치(   
					 ,SCH017.PACKTYPE                                   									--포장타입
					 ,SCH017.MAN_CUT_YN                                                   --수재단여부(6/14 무조건 N으로 처리함) 					 				 					 

           ,SCH017.COMP_YN                                                      --완료여부
           ,SCH017.REGDATE                                                      --등록일시
           ,SCH017.REGID                                                        --등록자ID
           ,SCH017.UPDDATE                                                      --수정일시
           ,SCH017.UPDID                                                        --수정자ID
           ,SCH017.USE_YN                                                       --사용여부(Y:사용 N:미사용)           
        )VALUES(
            V_WO_NO														                                  --작업지시번호             
           ,1                                                                   --작업지시순번
           ,SUBSTR(V_WO_NO,-4)                                                  --작업순서(작업지시번호,-4)
           ,TO_CHAR(sysdate,'YYYYMMDD')                                          --지시생성일자              

					 ,IFR020.AUFNR     																										--오더번호             
					 ,IFR020.FRAUFNR                         															--이전 오더 번호       
					 ,IFR020.WERKS                          															--플랜트코드          
					 ,IFR020.BUDAT                          															--생산요청일자         
					 ,IFR020.AUART                          															--오더유형           
					 ,IFR020.AUARTXT                        															--오더유형 텍스트       
					 ,IFR020.MACHINE                        															--FROM 생산호기      
					 ,IFR020.MACHINETXT                     															--FROM 생산 호기명    
					 ,IFR020.TOMACHINE                      															--TO 생산호기        
					 ,IFR020.TOMACHINETXT                   															--TO 생산 호기명      
					 ,IFR020.CMATNR                         															--자재 코드          
					 ,IFR020.PCODE                          															--지종             
					 ,IFR020.WEIGHT                         															--평량             
					 ,IFR020.VLEN                           															--세로길            
					 ,IFR020.WLEN                           															--가로길            
					 ,IFR020.CTCNT                          															--폭수             
					 ,IFR020.CNT                            															--생산지시량          
					 ,IFR020.CGEWEW                         															--총중량            
					 ,IFR020.CGEWEI                         															--단위             
					 ,IFR020.ZZATT1                         															--팔레트당연수         
					 ,IFR020.ZZATT2                         															--속당매수           
					 ,IFR020.DOUBLEFLAG                     															--쌍팔레트           
					 ,IFR020.VBELN                          															--판매문서           
					 ,IFR020.POSNR                          															--판매문서 항목번호      
					 ,IFR020.SAUART                         															--판매문서 유형        
					 ,IFR020.SAUARTXT                       															--판매 문서 오더 유형 텍스트
					 ,IFR020.OVBELN                         															--판매문서           
					 ,IFR020.OPOSNR                         															--판매문서 항목번호      
					 ,IFR020.OAUART                         															--판매문서 유형        
					 ,IFR020.OAUARTXT                       															--판매 문서 오더 유형 텍스트
					 ,IFR020.CUTTER                         															--카터             
					 ,IFR020.STLNR                          															--BOM Num        
					 ,IFR020.STLAL                          															--대체Bom          
					 ,IFR020.BMENG                          															--모품목기준수량        
					 ,IFR020.BMEIN                          															--모품목기준수량 단위     
					 ,IFR020.DLFL                           															--오더 삭제 지시자      
					 ,IFR020.ZCOR                           															--재단출고 오더 여부  
					 ,IFR020.REMARK                                                       --오더비고
					 ,IFR020.ROUTE                                                        --항차 
					 ,IFR020.KUNNR                                                        --판매처 
					 ,IFR020.NAME1                                                        --판매처명
					 ,IFR020.MAUFNR     																									--M/R LOT Number           
					 ,IFR020.PTIM                           															--생산 계획 시간 (HHMM)          
					 ,IFR020.PSEQ                           															--IS-M: Production Sequence
					 ,IFR020.WORKGROUP                      															--반                        
					 ,IFR020.MMATNR                         															--자재 번호                    
					 ,IFR020.MROLLCNT                       															--M/R 권치수                  
					 ,IFR020.MBRGEW                         															--M/ROLL 중량                
					 ,IFR020.MGEWEI                         															--중량 단위                    
					 ,IFR020.CORESIZE                       															--밀롤 지관 인치(SIZE)           
					 ,IFR020.PACKTYPE                       															--포장타입 	
           ,'N'                                                                  --수재단여부(6/14 무조건 N으로 처리함) 					 				 					  					 

           ,'N'                                                                  --완료여부               
           ,sysdate                                                             --등록일시               
           ,'sp_IFR020'                                                            --등록자ID              
           ,null                                                                --수정일시               
           ,null                                                                --수정자ID 
           ,case when IFR020.DLFL = 'X' then 'N'                      
                 else 'Y'                 
            end                                                                 --사용여부(Y:사용 N:미사용)	                        
        )
        WHERE IFR020.IF_STATUS in ('N','E')  /*  I/F상태, N:신규, S:성공, E:오류   */
        AND   IFR020.AUFNR     =  i_AUFNR
        AND   IFR020.IF_IFR_NO =  i_IF_IFR_NO         
    ; 



    --작업지시 생성되면 작업지시BOM을 구성한다. 
    --작업지시정보 추출
    SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, WERKS INTO V_WO_NO,V_WO_SEQ,V_WERKS
    FROM TB_SCH017
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
            ,'sp_ifr020'
            ,null
            ,null
      FROM TB_SCH001          
      WHERE  AUFNR  =  i_AUFNR;       
    END IF;                          



    o_msg_MSG  :=  'TB_IFR020, 생산오더-재단가 수신되었습니다.1' || ',' || SQLERRM ;

    UPDATE  TB_IFR020_TMP
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    AUFNR     =  i_AUFNR
    AND    IF_IFR_NO =  i_IF_IFR_NO    
    ;

    o_msg_MSG  :=  'TB_IFR020, 생산오더-재단가 수신되었습니다.2' || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
                o_msg_MSG  :=  'TB_IFR020, 생산오더-재단 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                o_msg_code      := '-1' ;
                DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                ROLLBACK;

                UPDATE  TB_IFR020_TMP
                SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                      , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                      , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
                WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
                AND    AUFNR     =  i_AUFNR
                AND    IF_IFR_NO =  i_IF_IFR_NO    
                ;

END  sp_ifr020 ;
/* ------- TB_IFR020 : 생산오더-재단  End --------------------------- */


/* ------- TB_IFSWC006 : 생산오더-재단===>WCS  Begin ------------------------- >22-08-31 사용안함. sp_ifr020내로 삽입됨.*/
PROCEDURE sp_ifr020_X (  i_IF_IFR_NO      IN   NUMBER   /* MES Interface Sequence(수신번호)        */
                      ,i_AUFNR          IN   VARCHAR2
                      ,o_msg_CODE       OUT  VARCHAR2
                      ,o_msg_MSG        OUT  VARCHAR2  ) is

  V_DOC_NO        VARCHAR2(50)    := '';      -- MES문서번호  
  V_DOC_SEQ       NUMBER          := 1;      -- MES문서순번 

BEGIN

  --삭제처리는 보류주석처리함.
  /*
    SELECT NVL(DLFL,' ') INTO V_DLFL
    FROM TB_IFR020
    WHERE AUFNR = i_AUFNR
    AND IF_IFR_NO = i_IF_IFR_NO;    

    IF V_DLFL = 'X' THEN
      UPDATE TB_SCH008
      SET DLFL = V_DLFL
      WHERE AUFNR =  i_AUFNR;          

      o_msg_MSG  :=  'TB_IFR020, 생산오더-재단 삭제 수신되었습니다.1' || ',' || SQLERRM ;

      UPDATE  TB_IFR020
      SET     IF_STATUS   =  'S'                  --  I/F상태, N:신규, S:성공, E:오류               
            , IF_SET_DATE =  sysdate             --  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
            , IF_ERR_MESS =  o_msg_MSG           --  데이터 처리 결과 Message(Oracle)              
      WHERE  AUFNR     =  i_AUFNR
      AND    IF_IFR_NO =  i_IF_IFR_NO           
      ;

      o_msg_MSG  :=  'TB_IFR020, 생산오더-재단 삭제 수신되었습니다.2' || ',' || SQLERRM ;
      o_msg_code := '0' ;
      RETURN;    
    END IF;
    */
    V_DOC_NO := FN_GET_MDOCNO('M','IFWC006');

    INSERT INTO TB_IFSWC006(
			 DOC_NO     							 --문서번호                                         
			,DOC_NOSEQ                 --문서번호 순번   

			,BARCODE                   --밀롤바코드
			,CT_LOT_ID
			,WRKORD                    --ERP 생산오더번호                                 
			,PLNT_CD                   --플랜트                                           
			,WORK_DT                   --생산 계획일 (YYYYMMDD)                           
			,MCHN_CD                   --투입할 Cutter 호기(PM3)                          
			,REMARK5                   --비고5                                            
			,REMARK6                   --비고6                                            
			,SPECIAL_NO                --ERP 특별재고번호                                 
			,REMARK8                   --비고8                                            
			,REMARK1                   --비고1                                            
			,REMARK2                   --비고2                                            
			,LOT_ID                    --MR LOTID                                         
			,CLASS                     --반                                               
			,MATERIAL_NO               --ERP 자재코드 (커터 자재코드)                     
			,LENGTH                    --권치수, 길이(M)                                  
			,WEIGHT                    --중량(KG)   
			,WORK_DRCT                 --생산 작업 지시사항
			,WORK_TIME                 --생산 계획 시간 (HHMM)
			,WORK_SEQ                  --생산 계획 순번

			,IF_STATUS                 --WCS 결과값 Return( N:대기,S:성공, E:오류 )       
			,IF_GET_DATE               --MES 등록일시                                     
			,IF_SET_DATE               --WCS 전송일시                                     
			,IF_ERR_MESS               --WCS 결과 메시지                                  
			,IF_MES_KEY                --MES Inserface Key
    )
    SELECT 
       V_DOC_NO
      ,V_DOC_SEQ

      ,(SELECT IND_BCD FROM TB_INV001 WHERE (ORDER_NO = K.FRAUFNR or LOT_NO = K.FRAUFNR)AND STCK_QTY > 0 AND ROWNUM=1) --밀롤바코드
      ,'*'
			,AUFNR                     --ERP 생산오더번호                       
			,WERKS                     --플랜트                              
			,BUDAT                     --생산 계획일 (YYYYMMDD)                
			,MACHINE                   --투입할 Cutter 호기(PM3)               
			,WLEN                      --비고5                              
			,VLEN                      --비고6                              
			,VBELN                     --ERP 특별재고번호                       
			,PACKTYPE                  --비고8-포장타입                              
			,KUNNR                     --비고1                              
			,NAME1                     --비고2                              
			,MAUFNR                    --MR LOTID                         
			,WORKGROUP                 --반                                
			,MMATNR                    --ERP 자재코드 (커터 자재코드)               
			,MROLLCNT                  --권치수, 길이(M)                       
			,MBRGEW                    --중량(KG)  
			,REMARK                                         --생산 작업 지시사항
			,PTIM                      --생산 계획 시간 (HHMM)
			,PSEQ                      --생산 계획 순번

			,'N'
			,sysdate
			,null
			,null
			,null
    FROM TB_IFR020_TMP K
    WHERE IF_IFR_NO =  i_IF_IFR_NO    
    ;

    o_msg_MSG  :=  'TB_IFSWC006, 생산오더-재단=>WCS가 수신되었습니다.1' || ',' || SQLERRM ;

    UPDATE  TB_IFR020_TMP
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    AUFNR     =  i_AUFNR
    AND    IF_IFR_NO =  i_IF_IFR_NO    
    ;

    o_msg_MSG  :=  'TB_IFSWC006, 생산오더-재단=>WCS가 수신되었습니다.2' || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
                o_msg_MSG  :=  'TB_IFSWC006, 생산오더-재단=>WCS 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                o_msg_code      := '-1' ;
                DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                ROLLBACK;

                UPDATE  TB_IFR020_TMP
                SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                      , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                      , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
                WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
                AND    AUFNR     =  i_AUFNR
                AND    IF_IFR_NO =  i_IF_IFR_NO    
                ;

END  sp_ifr020_X ;
/* ------- TB_IFSWC006 : 생산오더-재단===>WCS  End --------------------------- */



/* ------- TB_IFR021 : 생산오더-포장  Begin ------------------------- */
PROCEDURE sp_ifr021 (  i_IF_IFR_NO      IN   NUMBER   /* MES Interface Sequence(수신번호)        */
                      ,i_AUFNR          IN   VARCHAR2
                      ,i_PACKSEQ        IN   VARCHAR2
                      ,o_msg_CODE       OUT  VARCHAR2
                      ,o_msg_MSG        OUT  VARCHAR2  ) is

  V_CNT           NUMBER          := 0;      -- 카운트(작업지시존재여부) 
  V_BOM_CNT       NUMBER          := 0;      -- 카운트(작업지시BOM존재여부)

  V_WO_DT         VARCHAR2(50)    := '';      -- 지시일자(작업지시생성하기 위해서..)  

  V_WO_NO         VARCHAR2(50)    := '';      -- 작업지시번호 (작업지시BOM생성을 위해서..)  
  V_WO_SEQ        NUMBER          := 0;      --작업지시순번 (작업지시BOM생성을 위해서..)  
  V_WERKS         VARCHAR2(50)    := '';      -- 플랜트 (작업지시BOM생성을 위해서..) 

  V_DLFL          VARCHAR2(50)    := '';      -- 삭제FLAG   
         
  V_DLFL_CNT      NUMBER          := 0;      -- 생산오더 모두 삭제 되었으면 작업지시 삭제 하기 위해서 사용함.   
BEGIN

    SELECT NVL(DLFL,' ') INTO V_DLFL
    FROM TB_IFR021_TMP
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
      
                  
      o_msg_MSG  :=  'TB_IFR021, 생산오더-포장 삭제 수신되었습니다.1' || ',' || SQLERRM ;

      UPDATE  TB_IFR021_TMP
      SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
            , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
            , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
      WHERE  AUFNR     =  i_AUFNR
      AND    IF_IFR_NO =  i_IF_IFR_NO           
      ;

      o_msg_MSG  :=  'TB_IFR021, 생산오더-포장 삭제 수신되었습니다.2' || ',' || SQLERRM ;
      o_msg_code := '0' ;
      RETURN;    
    END IF;

    MERGE
    INTO  TB_SCH009 SCH009
    USING TB_IFR021_TMP IFR021
    ON    ( SCH009.AUFNR      =  IFR021.AUFNR
    AND     LPAD(SCH009.PACKSEQ, 2,'0')    =  IFR021.PACKSEQ     
    AND     IFR021.AUFNR      =  i_AUFNR
    AND     IFR021.PACKSEQ    =  i_PACKSEQ 
    AND     IFR021.IF_IFR_NO  =  i_IF_IFR_NO  )
    WHEN MATCHED THEN
         UPDATE
         SET      SCH009.CTPO			         =	IFR021.CTPO			           /*		재단 오더 번호			             */
                ,	SCH009.WERKS			     =	IFR021.WERKS			       /*		플랜트			                     */
                ,	SCH009.BUDAT			     =	IFR021.BUDAT			       /*		시작일자			                   */
                ,	SCH009.AUART			     =	IFR021.AUART			       /*		오더유형			                   */
                ,	SCH009.AUARTXT			     =	IFR021.AUARTXT			       /*		오더유형 텍스트			             */
                ,	SCH009.MACHINE			     =	IFR021.MACHINE			       /*		FROM 생산호기			               */
                ,	SCH009.MACHINETXT			 =	IFR021.MACHINETXT			   /*		FROM 생산 호기명			             */
                ,	SCH009.TOMACHINE			 =	IFR021.TOMACHINE			   /*		TO 생산호기			                 */
                ,	SCH009.TOMACHINETXT	         =	IFR021.TOMACHINETXT			   /*		TO 생산 호기명			               */
                --,	SCH009.PVERID			     =	IFR021.PVERID			       /*		생산 호기			                   */
                --,	SCH009.PVERIDTXT			 =	IFR021.PVERIDTXT			   /*		생산 호기명			                 */
                ,	SCH009.PMATNR			     =	IFR021.PMATNR			       /*		재단 자재 코드			               */
                ,	SCH009.PCODE			     =	IFR021.PCODE			       /*		지종			                       */
                ,	SCH009.WEIGHT			     =	IFR021.WEIGHT			       /*		평량			                       */
                ,	SCH009.WLEN			         =	IFR021.WLEN			           /*		가로길			                       */
                ,	SCH009.VLEN			         =	IFR021.VLEN			           /*		세로길			                       */
                ,	SCH009.PTCNT			     =	IFR021.PCNT			       /*		수량			                       */
                ,	SCH009.PCNT			         =	IFR021.PCNT			           /*		수량			                       */
                ,	SCH009.PGEWEW			     =	IFR021.PGEWEW			       /*		총중량			                       */
                ,	SCH009.PGEWEI			     =	IFR021.PGEWEI			       /*		단위			                       */
                ,	SCH009.ZZATT1			     =	IFR021.ZZATT1			       /*		팔레트당연수			                 */
                ,	SCH009.ZZATT2			     =	IFR021.ZZATT2			       /*		속당매수			                     */
                ,	SCH009.DOUBLEFLAG			 =	IFR021.DOUBLEFLAG			   /*		쌍팔레트			                     */
                ,	SCH009.PALETTECNT			 =	IFR021.PALETTECNT			   /*		팔레트당연수			                  */
                ,	SCH009.CONTYPE			     =	IFR021.CONTYPE			       /*		컨테이너 타입			                 */
                ,	SCH009.PACKTYPE			     =	IFR021.PACKTYPE			       /*		포장 타입			                     */
                ,	SCH009.VBELN			     =	IFR021.VBELN			       /*		판매문서			                     */
                ,	SCH009.POSNR			     =	IFR021.POSNR			       /*		판매문서 항목번호			               */
                ,	SCH009.SAUART			     =	IFR021.SAUART			       /*		판매문서 유형			                  */
                ,	SCH009.SAUARTXT			     =	IFR021.SAUARTXT			       /*		판매 문서 오더 유형 텍스트			       */
                ,	SCH009.OVBELN			     =	IFR021.OVBELN			       /*		판매문서			                     */
                ,	SCH009.OPOSNR			     =	IFR021.OPOSNR			       /*		판매문서 항목번호			               */
                ,	SCH009.OAUART			     =	IFR021.OAUART			       /*		판매문서 유형			                   */
                ,	SCH009.OAUARTXT			     =	IFR021.OAUARTXT			       /*		판매 문서 오더 유형 텍스트			        */
                ,	SCH009.KUNNR			     =	IFR021.KUNNR			       /*		판매처			                         */
                ,	SCH009.REMARK			     =	IFR021.REMARK			       /*		비고			                         */
                ,	SCH009.STLNR			     =	IFR021.STLNR			       /*		BOM Num			                      */
                ,	SCH009.STLAL			     =	IFR021.STLAL			       /*		대체Bom			                       */
                ,	SCH009.BMENG			     =	IFR021.BMENG			       /*		모품목기준수량			                  */
                ,	SCH009.BMEIN			     =	IFR021.BMEIN			       /*		모품목기준수량 단위			             */
                ,	SCH009.DLFL			       =	IFR021.DLFL			         /*		오더 삭제 지시자			                */
                , SCH009.ROUTE           =  IFR021.ROUTE             /*       항차                               */
                , SCH009.KUNNRT          =  IFR021.NAME1             --판매처명              
                , SCH009.FRAUFNR         =  IFR021.FRAUFNR           --이전오더                 

                , SCH009.UPDDATE         =  sysdate                  /*       수정일자                             */
                , SCH009.UPDID           =  'sp_ifr021'                  /*       수정자                               */
          WHERE  IFR021.IF_STATUS in ('N','E')                       /*  I/F상태, N:신규, S:성공, E:오류        */
          AND    IFR021.AUFNR     =  i_AUFNR
          AND    IFR021.PACKSEQ   =  i_PACKSEQ
          AND    IFR021.IF_IFR_NO =  i_IF_IFR_NO  
    WHEN NOT MATCHED THEN
         INSERT (  	SCH009.AUFNR							                       /*		오더번호			                       */
                  ,	SCH009.PACKSEQ  			                           /*		PACKING SEQ			                  */         
                  ,	SCH009.CTPO							                           /*		재단 오더 번호			                  */
                  ,	SCH009.WERKS							                       /*		플랜트			                          */
                  ,	SCH009.BUDAT							                       /*		시작일자			                       */
                  ,	SCH009.AUART							                       /*		오더유형			                       */
                  ,	SCH009.AUARTXT							                       /*		오더유형 텍스트			                 */
                  ,	SCH009.MACHINE							                       /*		FROM 생산호기			                   */
                  ,	SCH009.MACHINETXT							                   /*		FROM 생산 호기명			                 */
                  ,	SCH009.TOMACHINE							                   /*		TO 생산호기			                     */
                  ,	SCH009.TOMACHINETXT							                   /*		TO 생산 호기명			                  */
                  --,	SCH009.PVERID							                       /*		생산 호기			                       */
                  --,	SCH009.PVERIDTXT							                   /*		생산 호기명			                    */
                  ,	SCH009.PMATNR							                       /*		재단 자재 코드			                  */
                  ,	SCH009.PCODE							                       /*		지종			                          */
                  ,	SCH009.WEIGHT							                       /*		평량			                          */
                  ,	SCH009.WLEN							                           /*		가로길			                          */
                  ,	SCH009.VLEN							                           /*		세로길			                          */
                  ,	SCH009.PTCNT							                       /*		수량			                          */
                  ,	SCH009.PCNT							                           /*		수량			                          */
                  ,	SCH009.PGEWEW							                       /*		총중량			                          */
                  ,	SCH009.PGEWEI							                       /*		단위			                          */
                  ,	SCH009.ZZATT1							                       /*		팔레트당연수			                    */
                  ,	SCH009.ZZATT2							                       /*		속당매수			                       */
                  ,	SCH009.DOUBLEFLAG							                   /*		쌍팔레트			                       */
                  ,	SCH009.PALETTECNT							                   /*		팔레트당연수			                    */
                  ,	SCH009.CONTYPE							                       /*		컨테이너 타입			                    */
                  ,	SCH009.PACKTYPE							                       /*		포장 타입			                       */
                  ,	SCH009.VBELN							                       /*		판매문서			                       */
                  ,	SCH009.POSNR							                       /*		판매문서 항목번호			                 */
                  ,	SCH009.SAUART							                       /*		판매문서 유형			                    */
                  ,	SCH009.SAUARTXT							                       /*		판매 문서 오더 유형 텍스트			         */
                  ,	SCH009.OVBELN							                       /*		판매문서			                        */
                  ,	SCH009.OPOSNR							                       /*		판매문서 항목번호			                  */
                  ,	SCH009.OAUART							                       /*		판매문서 유형			                     */
                  ,	SCH009.OAUARTXT							                       /*		판매 문서 오더 유형 텍스트			          */
                  ,	SCH009.KUNNR							                       /*		판매처			                           */
                  ,	SCH009.REMARK							                       /*		비고			                            */
                  ,	SCH009.STLNR							                       /*		BOM Num			                         */
                  ,	SCH009.STLAL							                       /*		대체Bom			                          */
                  ,	SCH009.BMENG							                       /*		모품목기준수량			                     */
                  ,	SCH009.BMEIN							                       /*		모품목기준수량 단위			                */
                  ,	SCH009.DLFL							                       /*		오더 삭제 지시자			                   */
                  , SCH009.ROUTE                                                 /*       항차                                  */
                  , SCH009.KUNNRT                                     --판매처명 
                  , SCH009.FRAUFNR                                    --이전오더                 

                  ,	SCH009.REGDATE							                       /*		등록일자			                         */
                  ,	SCH009.REGID							                       /*		등록자			                            */
                  ,	SCH009.UPDDATE							                       /*		수정일자			                         */
                  ,	SCH009.UPDID							                       /*		수정자			                           */
                    )
         VALUES (   IFR021.AUFNR				                                   /*		오더번호			                         */
                  ,	IFR021.PACKSEQ	                                       /*		PACKING SEQ			                    */         
                  ,	IFR021.CTPO				                                       /*		재단 오더 번호			                    */
                  ,	IFR021.WERKS				                                   /*		플랜트			                           */
                  ,	IFR021.BUDAT				                                   /*		시작일자			                         */
                  ,	IFR021.AUART				                                   /*		오더유형			                         */
                  ,	IFR021.AUARTXT				                                   /*		오더유형 텍스트			                    */
                  ,	IFR021.MACHINE				                                   /*		FROM 생산호기			                     */
                  ,	IFR021.MACHINETXT				                               /*		FROM 생산 호기명			                   */
                  ,	IFR021.TOMACHINE				                               /*		TO 생산호기			                       */
                  ,	IFR021.TOMACHINETXT				                               /*		TO 생산 호기명			                     */
                  --,	IFR021.PVERID				                                   /*		생산 호기			                         */
                  --,	IFR021.PVERIDTXT				                               /*		생산 호기명			                       */
                  ,	IFR021.PMATNR				                                   /*		재단 자재 코드			                     */
                  ,	IFR021.PCODE				                                   /*		지종			                            */
                  ,	IFR021.WEIGHT				                                   /*		평량			                            */
                  ,	IFR021.WLEN				                                       /*		가로길			                            */
                  ,	IFR021.VLEN				                                       /*		세로길			                            */
                  ,	IFR021.PCNT				                                   /*		수량			                            */
                  ,	IFR021.PCNT				                                       /*		수량			                            */
                  ,	IFR021.PGEWEW				                                   /*		총중량			                           */
                  ,	IFR021.PGEWEI				                                   /*		단위			                            */
                  ,	IFR021.ZZATT1				                                   /*		팔레트당연수			                      */
                  ,	IFR021.ZZATT2				                                   /*		속당매수			                         */
                  ,	IFR021.DOUBLEFLAG				                               /*		쌍팔레트			                         */
                  ,	IFR021.PALETTECNT				                               /*		팔레트당연수			                      */
                  ,	IFR021.CONTYPE				                                   /*		컨테이너 타입			                      */
                  ,	IFR021.PACKTYPE				                                   /*		포장 타입			                         */
                  ,	IFR021.VBELN				                                   /*		판매문서			                         */
                  ,	IFR021.POSNR				                                   /*		판매문서 항목번호			                   */
                  ,	IFR021.SAUART				                                   /*		판매문서 유형			                      */
                  ,	IFR021.SAUARTXT				                                   /*		판매 문서 오더 유형 텍스트			           */
                  ,	IFR021.OVBELN				                                   /*		판매문서			                          */
                  ,	IFR021.OPOSNR				                                   /*		판매문서 항목번호			                   */
                  ,	IFR021.OAUART				                                   /*		판매문서 유형			                      */
                  ,	IFR021.OAUARTXT				                                   /*		판매 문서 오더 유형 텍스트			           */
                  ,	IFR021.KUNNR				                                   /*		판매처			                            */
                  ,	IFR021.REMARK				                                   /*		비고			                             */
                  ,	IFR021.STLNR				                                   /*		BOM Num			                          */
                  ,	IFR021.STLAL				                                   /*		대체Bom			                           */
                  ,	IFR021.BMENG				                                   /*		모품목기준수량			                      */
                  ,	IFR021.BMEIN				                                   /*		모품목기준수량 단위			                 */
                  ,	IFR021.DLFL				                                   /*		오더 삭제 지시자			                    */
                  , IFR021.ROUTE                                                 /*   항차                                   */
                  , IFR021.NAME1                                           --판매처명      
                  , IFR021.FRAUFNR                                         --이전오더

                  , sysdate                                                        /*   등록일자                                */
                  , 'sp_ifr021'                                                    /*   등록자                                  */
                  , null                                                           /*   수정일자                                 */
                  , null                                                           /*   수정자                                  */
                    )
         WHERE  IFR021.IF_STATUS in ('N','E')  /*  I/F상태, N:신규, S:성공, E:오류   */
         AND    IFR021.AUFNR     =  i_AUFNR
         AND    IFR021.PACKSEQ   =  i_PACKSEQ
         AND    IFR021.IF_IFR_NO =  i_IF_IFR_NO  
         ;

    --========================================
    --KHJ추가 2022-05-02:작업지시-포장
    --========================================
    ------------------------------------------
    --작업지시가 존재하지 않으면 작업지시 번호 생성
    SELECT COUNT(ORDER_NO) INTO V_CNT
    FROM TB_SCH018
    WHERE ORDER_NO = i_AUFNR;

    IF V_CNT = 0 THEN
      SELECT BUDAT INTO V_WO_DT
      FROM TB_IFR021_TMP
      WHERE IF_IFR_NO  =  i_IF_IFR_NO;

      SP_GET_DOC_SEQ('WOPA',V_WO_DT,V_WO_NO); 
    END IF;
    ------------------------------------------

    MERGE
        INTO  TB_SCH018 SCH018
        USING TB_IFR021_TMP IFR021
           ON ( SCH018.ORDER_NO   =  IFR021.AUFNR
           AND  IFR021.AUFNR      =  i_AUFNR
           AND  IFR021.IF_IFR_NO  =  i_IF_IFR_NO   )
    WHEN MATCHED THEN    
        UPDATE SET
					  SCH018.PRE_ORDER_NO         = IFR021.FRAUFNR                        --이전 오더 번호       
					 ,SCH018.WERKS                = IFR021.WERKS                          --플랜트코드          
					 ,SCH018.PRD_REQ_DT           = IFR021.BUDAT                          --생산요청일자         
					 ,SCH018.ORDER_DIV            = IFR021.AUART                          --오더유형           
					 ,SCH018.ORDER_DIV_NM         = IFR021.AUARTXT                        --오더유형 텍스트       
					 ,SCH018.MACHINE              = IFR021.MACHINE                        --FROM 생산 호기     
					 ,SCH018.MACHINE_NM           = IFR021.MACHINETXT                     --FROM 생산 호기명    
					 ,SCH018.TO_MACHINE           = IFR021.TOMACHINE                      --TO 생산호기        
					 ,SCH018.TO_MACHINE_NM        = IFR021.TOMACHINETXT                   --TO 생산 호기명      
					 ,SCH018.MATNR                = IFR021.PMATNR                         --자재 코드          
					 ,SCH018.PCODE                = IFR021.PCODE                          --지종             
					 ,SCH018.BS_WGT               = IFR021.WEIGHT                         --평량             
					 ,SCH018.WLEN                 = IFR021.WLEN                           --가로길            
					 ,SCH018.VLEN                 = IFR021.VLEN                           --세로길            
					 ,SCH018.WRK_ORDR_QTY         = IFR021.PCNT                           --생산지시량(SAP에서 사용안하는필드로 PCNT와 동일값 저장 22-08-05)         
					 ,SCH018.PCNT                 = IFR021.PCNT                           --수량             
					 ,SCH018.TOT_WGT              = IFR021.PGEWEW                         --총중량            
					 ,SCH018.UNIT                 = IFR021.PGEWEI                         --단위             
					 ,SCH018.PLT_PER_CNT          = IFR021.ZZATT1                         --팔레트당연수         
					 ,SCH018.IN_PER_CNT           = IFR021.ZZATT2                         --속당매수           
					 ,SCH018.DBL_FLAG             = IFR021.DOUBLEFLAG                     --쌍팔레트           
					 ,SCH018.PALETTECNT           = IFR021.PALETTECNT                     --팔레트당연수         
					 ,SCH018.CON_TYPE             = IFR021.CONTYPE                        --컨테이너 타입        
					 ,SCH018.PACKTYPE             = IFR021.PACKTYPE                       --포장 타입          
					 ,SCH018.PKCNT                = IFR021.PKCNT                          --폭수             
					 ,SCH018.MCNT                 = IFR021.MCNT                           --매              
					 ,SCH018.SCNT                 = IFR021.SCNT                           --속              
					 ,SCH018.VBELN                = IFR021.VBELN                          --판매문서           
					 ,SCH018.POSNR                = IFR021.POSNR                          --판매문서 항목번호      
					 ,SCH018.SAUART_DIV           = IFR021.SAUART                         --판매문서 유형        
					 ,SCH018.SAUART_NM            = IFR021.SAUARTXT                       --판매 문서 오더 유형 텍스트
					 ,SCH018.OVBELN               = IFR021.OVBELN                         --판매문서           
					 ,SCH018.OPOSNR               = IFR021.OPOSNR                         --판매문서 항목번호      
					 ,SCH018.OAUART_DIV           = IFR021.OAUART                         --판매문서 유형        
					 ,SCH018.OAUART_NM            = IFR021.OAUARTXT                       --판매 문서 오더 유형 텍스트
					 ,SCH018.KUNNR                = IFR021.KUNNR                          --판매처            
					 ,SCH018.ORDER_RMK            = IFR021.REMARK                         --비고(22-06-08:REMARK->ORDER_RMK)             
					 ,SCH018.BOM_NO               = IFR021.STLNR                          --BOM Num        
					 ,SCH018.ATN_BOM_NO           = IFR021.STLAL                          --대체Bom          
					 ,SCH018.PRT_MATNR_QTY        = IFR021.BMENG                          --모품목기준수량        
					 ,SCH018.PRT_MATNR_UNIT       = IFR021.BMEIN                          --모품목기준수량 단위     
					 ,SCH018.DLFL                 = IFR021.DLFL                           --오더 삭제 지시자
					 ,SCH018.ROUTE                = IFR021.ROUTE                          --항차  
					 ,SCH018.KUNNRT               = IFR021.NAME1                          --판매처명  
					 ,SCH018.PACKSEQ					    = IFR021.PACKSEQ                        --PACKING SEQ

           ,SCH018.UPDDATE              = sysdate                               --수정일시
           ,SCH018.UPDID                = 'sp_IFR021'                               --수정자ID
           ,SCH018.USE_YN               =  case when IFR021.DLFL = 'Y' then 'N'            
                                                when IFR021.DLFL = 'N' then 'Y'
                                           end                                  --사용여부(Y:사용 N:미사용)	            
        WHERE IFR021.IF_STATUS in ('N','E')                                        --I/F상태, N:신규, S:성공, E:오류        
        AND   IFR021.AUFNR     =  i_AUFNR
        AND   IFR021.IF_IFR_NO =  i_IF_IFR_NO
    WHEN NOT MATCHED THEN
        INSERT (
					  SCH018.WRK_ORDR_NO                                                  --작업지시번호-->작업지시 생성자 사용 WO + R  
					 ,SCH018.WRK_ORDR_SEQNO                                               --작업지시순번
           ,SCH018.WRK_SEQNO                                                    --작업순서
           ,SCH018.ORDR_GEN_DT                                                  --지시생성일자					 

					 ,SCH018.ORDER_NO            																					--오더번호           
					 ,SCH018.PRE_ORDER_NO         												                --이전 오더 번호       
					 ,SCH018.WERKS                												                --플랜트코드          
					 ,SCH018.PRD_REQ_DT           												                --생산요청일자         
					 ,SCH018.ORDER_DIV            												                --오더유형           
					 ,SCH018.ORDER_DIV_NM         												                --오더유형 텍스트       
					 ,SCH018.MACHINE              												                --FROM 생산 호기     
					 ,SCH018.MACHINE_NM           												                --FROM 생산 호기명    
					 ,SCH018.TO_MACHINE           												                --TO 생산호기        
					 ,SCH018.TO_MACHINE_NM        												                --TO 생산 호기명      
					 ,SCH018.MATNR                												                --자재 코드          
					 ,SCH018.PCODE                												                --지종             
					 ,SCH018.BS_WGT               												                --평량             
					 ,SCH018.WLEN                 												                --가로길            
					 ,SCH018.VLEN                 												                --세로길            
					 ,SCH018.WRK_ORDR_QTY         												                --생산지시량(*)          
					 ,SCH018.PCNT                 												                --연수(*)             
					 ,SCH018.TOT_WGT              												                --총중량(*)            
					 ,SCH018.UNIT                 												                --단위             
					 ,SCH018.PLT_PER_CNT          												                --팔레트당연수         
					 ,SCH018.IN_PER_CNT           												                --속당매수           
					 ,SCH018.DBL_FLAG             												                --쌍팔레트           
					 ,SCH018.PALETTECNT           												                --팔레트당연수         
					 ,SCH018.CON_TYPE             												                --컨테이너 타입        
					 ,SCH018.PACKTYPE             												                --포장 타입          
					 ,SCH018.PKCNT                												                --폭수             
					 ,SCH018.MCNT                 												                --매              
					 ,SCH018.SCNT                 												                --속              
					 ,SCH018.VBELN                												                --판매문서           
					 ,SCH018.POSNR                												                --판매문서 항목번호      
					 ,SCH018.SAUART_DIV           												                --판매문서 유형        
					 ,SCH018.SAUART_NM            												                --판매 문서 오더 유형 텍스트
					 ,SCH018.OVBELN               												                --판매문서           
					 ,SCH018.OPOSNR               												                --판매문서 항목번호      
					 ,SCH018.OAUART_DIV           												                --판매문서 유형        
					 ,SCH018.OAUART_NM            												                --판매 문서 오더 유형 텍스트
					 ,SCH018.KUNNR                												                --판매처            
					 ,SCH018.ORDER_RMK               												              --비고(22-06-08:REMARK->ORDER_RMK)              
					 ,SCH018.BOM_NO               												                --BOM Num        
					 ,SCH018.ATN_BOM_NO           												                --대체Bom          
					 ,SCH018.PRT_MATNR_QTY        												                --모품목기준수량        
					 ,SCH018.PRT_MATNR_UNIT       												                --모품목기준수량 단위     
					 ,SCH018.DLFL                 												                --오더 삭제 지시자 
					 ,SCH018.ROUTE                                                        --항차
					 ,SCH018.KUNNRT                                                       --판매처명
					 ,SCH018.PACKSEQ                                                      --PACKING SEQ						 					 

					 ,SCH018.COMP_YN                                                      --완료여부
					 ,SCH018.REGDATE                                                      --등록일시
					 ,SCH018.REGID                                                        --등록자ID
				   ,SCH018.UPDDATE                                                      --수정일시
					 ,SCH018.UPDID                                                        --수정자ID
					 ,SCH018.USE_YN                                                       --사용여부(Y:사용 N:미사용)           
        )VALUES(
					  V_WO_NO	    																											  --작업지시번호             
					 ,1                                                                   --작업지시순번 
           ,SUBSTR(V_WO_NO,-4)                                                  --작업순서(작업지시번호,-4)
           ,TO_CHAR(sysdate,'YYYYMMDD')                                          --지시생성일자 					 

					 ,IFR021.AUFNR        																								--오더번호           
					 ,IFR021.FRAUFNR                         															--이전 오더 번호       
					 ,IFR021.WERKS                          															--플랜트코드          
					 ,IFR021.BUDAT                          															--생산요청일자         
					 ,IFR021.AUART                          															--오더유형           
					 ,IFR021.AUARTXT                        															--오더유형 텍스트       
					 ,IFR021.MACHINE                        															--FROM 생산 호기     
					 ,IFR021.MACHINETXT                     															--FROM 생산 호기명    
					 ,IFR021.TOMACHINE                      															--TO 생산호기        
					 ,IFR021.TOMACHINETXT                   															--TO 생산 호기명      
					 ,IFR021.PMATNR                         															--자재 코드          
					 ,IFR021.PCODE                          															--지종             
					 ,IFR021.WEIGHT                         															--평량             
					 ,IFR021.WLEN                           															--가로길            
					 ,IFR021.VLEN                           															--세로길            
					 ,IFR021.PCNT                          															  --생산지시량(SAP에서 사용안하는필드로 PCNT와 동일값 저장 22-08-05)          
					 ,IFR021.PCNT                           															--수량             
					 ,IFR021.PGEWEW                         															--총중량            
					 ,IFR021.PGEWEI                         															--단위             
					 ,IFR021.ZZATT1                         															--팔레트당연수         
					 ,IFR021.ZZATT2                         															--속당매수           
					 ,IFR021.DOUBLEFLAG                     															--쌍팔레트           
					 ,IFR021.PALETTECNT                     															--팔레트당연수         
					 ,IFR021.CONTYPE                        															--컨테이너 타입        
					 ,IFR021.PACKTYPE                       															--포장 타입          
					 ,IFR021.PKCNT                          															--폭수             
					 ,IFR021.MCNT                           															--매              
					 ,IFR021.SCNT                           															--속              
					 ,IFR021.VBELN                          															--판매문서           
					 ,IFR021.POSNR                          															--판매문서 항목번호      
					 ,IFR021.SAUART                         															--판매문서 유형        
					 ,IFR021.SAUARTXT                       															--판매 문서 오더 유형 텍스트
					 ,IFR021.OVBELN                         															--판매문서           
					 ,IFR021.OPOSNR                         															--판매문서 항목번호      
					 ,IFR021.OAUART                         															--판매문서 유형        
					 ,IFR021.OAUARTXT                       															--판매 문서 오더 유형 텍스트
					 ,IFR021.KUNNR                          															--판매처            
					 ,IFR021.REMARK                         															--비고             
					 ,IFR021.STLNR                          															--BOM Num        
					 ,IFR021.STLAL                          															--대체Bom          
					 ,IFR021.BMENG                          															--모품목기준수량        
					 ,IFR021.BMEIN                          															--모품목기준수량 단위     
					 ,IFR021.DLFL                           															--오더 삭제 지시자  
					 ,IFR021.ROUTE                                                        --항차
					 ,IFR021.NAME1                                                        --판매처명 
					 ,IFR021.PACKSEQ                                                      --PACKING SEQ 					 					  

					 ,'N'                                                                  --완료여부               
					 ,sysdate                                                             --등록일시               
					 ,'sp_IFR021'                                                            --등록자ID              
					 ,null                                                                --수정일시               
					 ,null                                                                --수정자ID 
					 ,case when IFR021.DLFL = 'X' then 'N'					            
                 else 'Y'					       
					  end                                                                 --사용여부(Y:사용 N:미사용)	                        
        )
        WHERE IFR021.IF_STATUS in ('N','E')  /*  I/F상태, N:신규, S:성공, E:오류   */
        AND   IFR021.AUFNR     =  i_AUFNR
        AND   IFR021.IF_IFR_NO =  i_IF_IFR_NO         
    ;
          
    
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
            ,'sp_ifr021'
            ,null
            ,null
      FROM TB_SCH001          
      WHERE  AUFNR  =  i_AUFNR;       
    END IF;                        




    o_msg_MSG  :=  'TB_IFR021, 생산오더-포장 오더가 수신되었습니다.1' || ',' || SQLERRM ;

    UPDATE  TB_IFR021_TMP
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    AUFNR     =  i_AUFNR
    AND    IF_IFR_NO =  i_IF_IFR_NO  
    ;

    o_msg_MSG  :=  'TB_IFR021, 생산오더-포장 오더가 수신되었습니다.2' || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
                o_msg_MSG  :=  'TB_IFR021, 생산오더-포장 오더 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                o_msg_code      := '-1' ;
                DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                ROLLBACK;

                UPDATE  TB_IFR021_TMP
                SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                      , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                      , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
                WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
                AND    AUFNR     =  i_AUFNR
                AND    IF_IFR_NO =  i_IF_IFR_NO  
                ;

END  sp_ifr021 ;
/* ------- TB_IFR021 : 생산오더-포장  End --------------------------- */


/* ------- TB_IFR022 : 생산오더-예외생산  Begin ------------------------- */
PROCEDURE sp_ifr022 (  i_IF_IFR_NO      IN   NUMBER   /* MES Interface Sequence(수신번호)        */
                      ,i_AUFNR          IN   VARCHAR2
                      ,o_msg_CODE       OUT  VARCHAR2
                      ,o_msg_MSG        OUT  VARCHAR2  ) is

  V_CNT           NUMBER          := 0;      -- 카운트(작업지시존재여부) 
  V_BOM_CNT       NUMBER          := 0;      -- 카운트(작업지시BOM존재여부)

  V_WO_DT         VARCHAR2(50)    := '';      -- 지시일자(작업지시생성하기 위해서..)  

  V_WO_NO         VARCHAR2(50)    := '';      -- 작업지시번호 (작업지시BOM생성을 위해서..)  
  V_WO_SEQ        NUMBER          := 0;      --작업지시순번 (작업지시BOM생성을 위해서..)  
  V_WERKS         VARCHAR2(50)    := '';      -- 플랜트 (작업지시BOM생성을 위해서..) 

  V_DLFL          VARCHAR2(50)    := '';      -- 삭제FLAG   
BEGIN

    SELECT NVL(DLFL,' ') INTO V_DLFL
    FROM TB_IFR022_TMP
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

      UPDATE  TB_IFR022_TMP
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

    MERGE
    INTO  TB_SCH010 SCH010
    USING TB_IFR022_TMP IFR022
    ON    ( SCH010.AUFNR      =  IFR022.AUFNR
    AND     IFR022.AUFNR      =  i_AUFNR 
    AND     IFR022.IF_IFR_NO  =  i_IF_IFR_NO  )
    WHEN MATCHED THEN
         UPDATE
         SET    	SCH010.WERKS		       =	IFR022.WERKS		         /*	WERKS	,	플랜트		                           */
                ,	SCH010.GSTRS		       =	IFR022.GSTRS		         /*	GSTRS	,	시작일자		                        */
                ,	SCH010.AUART		       =	IFR022.AUART		         /*	AUART	,	오더유형		                        */
                ,	SCH010.AUARTXT		     =	IFR022.AUARTXT		         /*	AUARTXT	,	오더유형 텍스트		                */
                ,	SCH010.MATNR		       =	IFR022.MATNR		         /*	MATNR	,	제품코드		                        */
                ,	SCH010.GAMNG		       =	IFR022.GAMNG		         /*	GAMNG	,	생산지시량		                       */
                ,	SCH010.GMEIN		       =	IFR022.GMEIN		         /*	GMEIN	,	생산지시단위		                    */
                ,	SCH010.ARBPL		       =	IFR022.ARBPL		         /*	ARBPL	,	Work Center		                    */
                ,	SCH010.VERID		       =	IFR022.VERID		         /*	VERID	,	생산버전		                       */
                ,	SCH010.STLNR		       =	IFR022.STLNR		         /*	STLNR	,	BOM Num		                        */
                ,	SCH010.STLAL		       =	IFR022.STLAL		         /*	STLAL	,	대체Bom		                         */
                ,	SCH010.BMENG		       =	IFR022.BMENG		         /*	BMENG	,	모품목기준수량		                    */
                ,	SCH010.BMEIN		       =	IFR022.BMEIN		         /*	BMEIN	,	모품목기준수량 단위		               */
                ,	SCH010.FTRMI		       =	IFR022.FTRMI		         /*	FTRMI	,	릴리즈일자		                       */
                ,	SCH010.VBELN		       =	IFR022.VBELN		         /*	VBELN	,	판매문서번호		                     */
                ,	SCH010.POSNR		       =	IFR022.POSNR		         /*	POSNR	,	판매문서Item번호		                 */
								, SCH010.PCODE        	 = IFR022.PCODE         		 --지종    
								, SCH010.WEIGHT          = IFR022.WEIGHT             --평량    
								, SCH010.WLEN            = IFR022.WLEN               --가로길   
								, SCH010.VLEN            = IFR022.VLEN               --세로길   
								, SCH010.ZZATT1          = IFR022.ZZATT1             --팔레트당연수
								, SCH010.ZZATT2          = IFR022.ZZATT2             --속당매수  
								, SCH010.PACKTYPE        = IFR022.PACKTYPE           --포장타입  
								, SCH010.MCNT            = IFR022.MCNT               --매     
								, SCH010.SCNT            = IFR022.SCNT               --속     
								, SCH010.KUNNR           = IFR022.KUNNR              --판매처 코드
								, SCH010.NAME1           = IFR022.NAME1              --판매처                 

                ,	SCH010.DLFL		           =	IFR022.DLFL		             /*	DLFL	,	오더삭제지시자		                    */
                ,	SCH010.UPDDATE		       =	sysdate		                 /*	EDIT_DATE	,	수정일자		                    */
                ,	SCH010.UPDID		       =	'sp_ifr022'		             /*	EDITOR	,	수정자		                         */
          WHERE  IFR022.IF_STATUS in ('N','E')                       /*  I/F상태, N:신규, S:성공, E:오류                      */
          AND    IFR022.AUFNR     =  i_AUFNR
          AND    IFR022.IF_IFR_NO =  i_IF_IFR_NO  
    WHEN NOT MATCHED THEN
         INSERT (  	SCH010.AUFNR				                             /*	AUFNR	,	오더번호		                              */
                  ,	SCH010.WERKS				                             /*	WERKS	,	플랜트		                                 */
                  ,	SCH010.GSTRS				                             /*	GSTRS	,	시작일자		                              */
                  ,	SCH010.AUART				                             /*	AUART	,	오더유형		                              */
                  ,	SCH010.AUARTXT				                             /*	AUARTXT	,	오더유형 텍스트		                      */
                  ,	SCH010.MATNR				                             /*	MATNR	,	제품코드		                              */
                  ,	SCH010.GAMNG				                             /*	GAMNG	,	생산지시량		                             */
                  ,	SCH010.GMEIN				                             /*	GMEIN	,	생산지시단위		                           */
                  ,	SCH010.ARBPL				                             /*	ARBPL	,	Work Center		                          */
                  ,	SCH010.VERID				                             /*	VERID	,	생산버전		                             */
                  ,	SCH010.STLNR				                             /*	STLNR	,	BOM Num		                              */
                  ,	SCH010.STLAL				                             /*	STLAL	,	대체Bom		                               */
                  ,	SCH010.BMENG				                             /*	BMENG	,	모품목기준수량		                          */
                  ,	SCH010.BMEIN				                             /*	BMEIN	,	모품목기준수량 단위		                     */
                  ,	SCH010.FTRMI				                             /*	FTRMI	,	릴리즈일자		                              */
                  ,	SCH010.VBELN				                             /*	VBELN	,	판매문서번호		                           */
                  ,	SCH010.POSNR				                             /*	POSNR	,	판매문서Item번호		                       */
									, SCH010.PCODE       															 --지종      
                  , SCH010.WEIGHT                                    --평량    
                  , SCH010.WLEN                                      --가로길   
                  , SCH010.VLEN                                      --세로길   
                  , SCH010.ZZATT1                                    --팔레트당연수
                  , SCH010.ZZATT2                                    --속당매수  
                  , SCH010.PACKTYPE                                  --포장타입  
                  , SCH010.MCNT                                      --매     
                  , SCH010.SCNT                                      --속     
                  , SCH010.KUNNR                                     --판매처 코드
                  , SCH010.NAME1                                     --판매처                   

                  ,	SCH010.DLFL				                                 /*	DLFL	,	오더삭제지시자		                          */
                  ,	SCH010.REGDATE				                             /*	MAKE_DATE	,	등록일자		                          */
                  ,	SCH010.REGID				                             /*	MAKER	,	등록자		                                 */
                  ,	SCH010.UPDDATE				                             /*	EDIT_DATE	,	수정일자		                          */
                  ,	SCH010.UPDID				                             /*	EDITOR	,	수정자		                              */
                    )
         VALUES (   IFR022.AUFNR				                             /*	AUFNR	,	오더번호		                              */
                  ,	IFR022.WERKS				                             /*	WERKS	,	플랜트		                                 */
                  ,	IFR022.GSTRS				                             /*	GSTRS	,	시작일자		                               */
                  ,	IFR022.AUART				                             /*	AUART	,	오더유형		                               */
                  ,	IFR022.AUARTXT				                             /*	AUARTXT	,	오더유형 텍스트		                       */
                  ,	IFR022.MATNR				                             /*	MATNR	,	제품코드		                               */
                  ,	IFR022.GAMNG				                             /*	GAMNG	,	생산지시량		                              */
                  ,	IFR022.GMEIN				                             /*	GMEIN	,	생산지시단위		                            */
                  ,	IFR022.ARBPL				                             /*	ARBPL	,	Work Center		                            */
                  ,	IFR022.VERID				                             /*	VERID	,	생산버전		                               */
                  ,	IFR022.STLNR				                             /*	STLNR	,	BOM Num		                                */
                  ,	IFR022.STLAL				                             /*	STLAL	,	대체Bom		                                 */
                  ,	IFR022.BMENG				                             /*	BMENG	,	모품목기준수량		                            */
                  ,	IFR022.BMEIN				                             /*	BMEIN	,	모품목기준수량 단위		                       */
                  ,	IFR022.FTRMI				                             /*	FTRMI	,	릴리즈일자		                               */
                  ,	IFR022.VBELN				                             /*	VBELN	,	판매문서번호		                            */
                  ,	IFR022.POSNR				                             /*	POSNR	,	판매문서Item번호		                        */
									, IFR022.PCODE       															 --지종    
									, IFR022.WEIGHT                                    --평량    
									, IFR022.WLEN                                      --가로길   
									, IFR022.VLEN                                      --세로길   
									, IFR022.ZZATT1                                    --팔레트당연수
									, IFR022.ZZATT2                                    --속당매수  
									, IFR022.PACKTYPE                                  --포장타입  
									, IFR022.MCNT                                      --매     
									, IFR022.SCNT                                      --속     
									, IFR022.KUNNR                                     --판매처 코드
									, IFR022.NAME1                                     --판매처                    

                  ,	IFR022.DLFL				                                 /*	DLFL	,	오더삭제지시자		                           */
                  ,	sysdate				                                     /*	MAKE_DATE	,	등록일자		                           */
                  ,	'sp_ifr022'				                                 /*	MAKER	,	등록자		                                  */
                  ,	null				                                     /*	EDIT_DATE	,	수정일자		                           */
                  ,	null				                                     /*	EDITOR	,	수정자		                                */
                    )
         WHERE  IFR022.IF_STATUS in ('N','E')  /*  I/F상태, N:신규, S:성공, E:오류   */
         AND    IFR022.AUFNR     =  i_AUFNR
         AND    IFR022.IF_IFR_NO =  i_IF_IFR_NO  
         ;


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
      FROM TB_IFR022_TMP
      WHERE IF_IFR_NO  =  i_IF_IFR_NO;

      SP_GET_DOC_SEQ('WOEX',V_WO_DT,V_WO_NO); 
    END IF;
    ------------------------------------------

    MERGE
        INTO  TB_SCH019 SCH019
        USING TB_IFR022_TMP IFR022
           ON ( SCH019.ORDER_NO   =  IFR022.AUFNR
           AND  IFR022.AUFNR      =  i_AUFNR 
           AND  IFR022.IF_IFR_NO  =  i_IF_IFR_NO   )
    WHEN MATCHED THEN    
        UPDATE SET
             SCH019.WERKS                = IFR022.WERKS                         	--플랜트코드
            ,SCH019.PRD_REQ_DT           = IFR022.GSTRS                         	--생산요청일자
						,SCH019.PCODE							   = IFR022.PCODE 													--지종      
						,SCH019.BS_WGT               = IFR022.WEIGHT                          --평량    
						,SCH019.WLEN                 = IFR022.WLEN                            --가로길   
						,SCH019.VLEN                 = IFR022.VLEN                            --세로길   
						,SCH019.PLT_PER_CNT          = IFR022.ZZATT1                          --팔레트당연수
						,SCH019.IN_PER_CNT           = IFR022.ZZATT2                          --속당매수  
						,SCH019.PACKTYPE             = IFR022.PACKTYPE                        --포장타입  
						,SCH019.MCNT                 = IFR022.MCNT                            --매     
						,SCH019.SCNT                 = IFR022.SCNT                            --속     
						,SCH019.KUNNR                = IFR022.KUNNR                           --판매처 코드
						,SCH019.KUNNRT               = IFR022.NAME1                           --판매처 

						,SCH019.ORDER_DIV            = IFR022.AUART                           --오더유형
						,SCH019.AUARTXT              = IFR022.AUARTXT                         --오더유형 텍스트
						,SCH019.MATNR                = IFR022.MATNR                           --제품코드
						,SCH019.UNIT                 = IFR022.GMEIN                           --생산지시단위
						,SCH019.WRK_CD               = IFR022.ARBPL                           --Work Center
						,SCH019.VERID                = IFR022.VERID                           --생산버전
						,SCH019.STLNR                = IFR022.STLNR                           --BOM Num
						,SCH019.STLAL                = IFR022.STLAL                           --대체Bom
						,SCH019.BMENG                = IFR022.BMENG                           --모품목기준수량
						,SCH019.BMEIN                = IFR022.BMEIN                           --모품목기준수량 단위
						,SCH019.FTRMI                = IFR022.FTRMI                           --릴리즈일자
						,SCH019.VBELN                = IFR022.VBELN                           --판매문서번호	
						,SCH019.POSNR                = IFR022.POSNR                           --판매문서Item번호	
						,SCH019.WRK_ORDR_QTY         = IFR022.GAMNG                           --생산지시량																																																																								
						,SCH019.GSTRS   						 = IFR022.GSTRS														--생산요청일자     	
						,SCH019.GAMNG                = IFR022.GAMNG                           --생산지시량      
						,SCH019.GMEIN                = IFR022.GMEIN                           --생산지시단위     
						,SCH019.ARBPL                = IFR022.ARBPL                           --Work Center 
						,SCH019.DLFL                 = IFR022.DLFL                            --오더삭제지시자

            ,SCH019.UPDDATE              = sysdate                              	--수정일시
            ,SCH019.UPDID                = 'sp_IFR022'                          	--수정자ID
            ,SCH019.USE_YN               =  case when IFR022.DLFL = 'Y' then 'N'            
                                                 when IFR022.DLFL = 'N' then 'Y'
                                            end                                  --사용여부(Y:사용 N:미사용)	            
        WHERE IFR022.IF_STATUS in ('N','E')                                      --I/F상태, N:신규, S:성공, E:오류        
        AND   IFR022.AUFNR     =  i_AUFNR
        AND   IFR022.IF_IFR_NO =  i_IF_IFR_NO
    WHEN NOT MATCHED THEN
        INSERT (
							 SCH019.WRK_ORDR_NO                                                  --작업지시번호-->작업지시 생성자 사용 WO + R  
							,SCH019.WRK_ORDR_SEQNO                                               --작업지시순번
              ,SCH019.WRK_SEQNO                                                    --작업순서
							,SCH019.ORDR_GEN_DT                                                  --지시생성일자              					

							,SCH019.PRD_REQ_DT                                                   --생산요청일자                               	            							                
							,SCH019.ORDER_NO                                                     --오더번호
							,SCH019.WERKS                                                        --플랜트코드
							,SCH019.PCODE							   																				 --지종      
							,SCH019.BS_WGT                                      								 --평량    
							,SCH019.WLEN                                        								 --가로길   
							,SCH019.VLEN                                        								 --세로길   
							,SCH019.PLT_PER_CNT                                 								 --팔레트당연수
							,SCH019.IN_PER_CNT                                  								 --속당매수  
							,SCH019.PACKTYPE                                    								 --포장타입  
							,SCH019.MCNT                                        								 --매     
							,SCH019.SCNT                                        								 --속     
							,SCH019.KUNNR                                       								 --판매처 코드
							,SCH019.KUNNRT                                      								 --판매처 	
							,SCH019.MACH_CD                                                      --설비코드	

						  ,SCH019.ORDER_DIV                                                    --오더유형    
						  ,SCH019.AUARTXT                                                      --오더유형 텍스
						  ,SCH019.MATNR                                                        --제품코드    
						  ,SCH019.UNIT                                                         --생산지시단위 
						  ,SCH019.WRK_CD                                                       --Work Cente
						  ,SCH019.VERID                                                        --생산버전    
						  ,SCH019.STLNR                                                        --BOM Num   
						  ,SCH019.STLAL                                                        --대체Bom    
						  ,SCH019.BMENG                                                        --모품목기준수량
						  ,SCH019.BMEIN                                                        --모품목기준수량
						  ,SCH019.FTRMI                                                        --릴리즈일자   
						  ,SCH019.VBELN                                                        --판매문서번호	
						  ,SCH019.POSNR                                                        --판매문서Item
						  ,SCH019.WRK_ORDR_QTY                                                 --생산지시량	 	
						  ,SCH019.GSTRS   						 					                               --생산요청일자  
						  ,SCH019.GAMNG                                                        --생산지시량   
						  ,SCH019.GMEIN                                                        --생산지시단위 
						  ,SCH019.ARBPL                                                        --Work Cente
						  ,SCH019.DLFL                                                         --오더삭제지시자


							,SCH019.COMP_YN                                                      --완료여부
							,SCH019.REGDATE                                                      --등록일시
							,SCH019.REGID                                                        --등록자ID
							,SCH019.UPDDATE                                                      --수정일시
							,SCH019.UPDID                                                        --수정자ID
							,SCH019.USE_YN                                                       --사용여부(Y:사용 N:미사용)           
        )VALUES(
							 V_WO_NO																												     --작업지시번호             
							,1                                                                   --작업지시순번  
              ,SUBSTR(V_WO_NO,-4)                                                  --작업순서(작업지시번호,-4)
              ,TO_CHAR(sysdate,'YYYYMMDD')                                          --지시생성일자   						

							,IFR022.GSTRS                                                        --생산요청일자                                        							                                                                       
							,IFR022.AUFNR                                                        --오더번호               
							,IFR022.WERKS                                                        --플랜트코드 
							,IFR022.PCODE 																											 --지종      
							,IFR022.WEIGHT                          														 --평량    
							,IFR022.WLEN                            														 --가로길   
							,IFR022.VLEN                            														 --세로길   
							,IFR022.ZZATT1                          														 --팔레트당연수
							,IFR022.ZZATT2                          														 --속당매수  
							,IFR022.PACKTYPE                        														 --포장타입  
							,IFR022.MCNT                            														 --매     
							,IFR022.SCNT                            														 --속     
							,IFR022.KUNNR                           														 --판매처 코드
							,IFR022.NAME1                           														 --판매처
							, CASE WHEN IFR022.WERKS = 'P200' THEN 'TPG01' 
                                   WHEN IFR022.WERKS = 'P300' THEN 'SPF03'
                                   WHEN IFR022.WERKS = 'P500' THEN 'BPI02'
                                   ELSE '' END                                                                              --설비코드(YSH 2022.09.05)
                            --,(SELECT M012.MACH_CD FROM TB_MAS012 M012,TB_MAS013 M013 WHERE M012.PROC_CD = M013.PROC_CD(+) AND M012.SAP_WRK_CD = IFR022.ARBPL AND M013.WERKS = IFR022.WERKS AND ROWNUM = 1) --설비코드 														  

						  ,IFR022.AUART                           														 --오더유형
						  ,IFR022.AUARTXT                         														 --오더유형 텍스트
						  ,IFR022.MATNR                           														 --제품코드
						  ,IFR022.GMEIN                           														 --생산지시단위
						  ,IFR022.ARBPL                           														 --Work Center
						  ,IFR022.VERID                           														 --생산버전
						  ,IFR022.STLNR                           														 --BOM Num
						  ,IFR022.STLAL                           														 --대체Bom
						  ,IFR022.BMENG                           														 --모품목기준수량
						  ,IFR022.BMEIN                           														 --모품목기준수량 단위
						  ,IFR022.FTRMI                           														 --릴리즈일자
						  ,IFR022.VBELN                           														 --판매문서번호	
						  ,IFR022.POSNR                           														 --판매문서Item번호	
						  ,IFR022.GAMNG                           														 --생산지시량																																																																									
						  ,IFR022.GSTRS																												 --생산요청일자     	
						  ,IFR022.GAMNG                           														 --생산지시량      
						  ,IFR022.GMEIN                           														 --생산지시단위     
						  ,IFR022.ARBPL                           														 --Work Center
						  ,IFR022.DLFL                            														 --오더삭제지시자								

							,'N'                                                                  --완료여부               
							,sysdate                                                             --등록일시               
							,'sp_IFR022'                                                            --등록자ID              
							,null                                                                --수정일시               
							,null                                                                --수정자ID 
							,case when IFR022.DLFL = 'X' then 'N'								         
                    else 'Y'							      
							 end                                                                 --사용여부(Y:사용 N:미사용)	                        
        )
        WHERE IFR022.IF_STATUS in ('N','E')  /*  I/F상태, N:신규, S:성공, E:오류   */
        AND   IFR022.AUFNR     =  i_AUFNR
        AND   IFR022.IF_IFR_NO =  i_IF_IFR_NO         
    ; 


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
            ,'sp_ifr022'
            ,null
            ,null
      FROM TB_SCH001          
      WHERE  AUFNR  =  i_AUFNR;       
    END IF;                      




    o_msg_MSG  :=  'TB_IFR022, 생산오더-예외생산 오더가 수신되었습니다.1' || ',' || SQLERRM ;

    UPDATE  TB_IFR022
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    AUFNR     =  i_AUFNR
    AND    IF_IFR_NO =  i_IF_IFR_NO  
    ;

    o_msg_MSG  :=  'TB_IFR022, 생산오더-예외생산 오더가 수신되었습니다.2' || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
                o_msg_MSG  :=  'TB_IFR022, 생산오더-예외생산 오더 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                o_msg_code      := '-1' ;
                DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                ROLLBACK;

                UPDATE  TB_IFR022_TMP
                SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                      , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                      , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
                WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
                AND    AUFNR     =  i_AUFNR
                AND    IF_IFR_NO =  i_IF_IFR_NO  
                ;

END  sp_ifr022 ;
/* ------- TB_IFR022 : 생산오더-예외생산  End --------------------------- */





BEGIN

/* ------- TB_IFR014 : 생산오더 BOM Begin -------------------------------- */
    IF  i_IF_MES_ID  = 'MES_IF_114'  THEN

        DBMS_OUTPUT.PUT_LINE('MES_IF_114==>START');

        for ifr014 in cur_ifr014 loop

            sp_ifr014(  ifr014.IF_IFR_NO
                      , ifr014.AUFNR
                      , ifr014.POSNR
                      , ifr014.MATNR
                      , o_msg_CODE
                      , o_msg_MSG
                      ) ;
            IF o_msg_CODE <> '0' THEN
               DBMS_OUTPUT.PUT_LINE('MES_IF_114 개별처리중 ERROR==>'|| ifr014.aufnr || ',' || ifr014.posnr || ',' || o_msg_MSG) ;
            END IF ;

            Commit ;

        end loop;

        DBMS_OUTPUT.PUT_LINE('MES_IF_114==>END');        

    END IF ;
/* ------- TB_IFR014 : 생산오더 BOM End ---------------------------------- */

/* ------- TB_IFR015 : 생산오더-화장지초지  Begin --------------------------- */
    IF  i_IF_MES_ID  = 'MES_IF_115'  THEN

        DBMS_OUTPUT.PUT_LINE('MES_IF_115==>START');

        for ifr015 in cur_ifr015 loop

            sp_ifr015(  ifr015.IF_IFR_NO
                      , ifr015.AUFNR
                      , o_msg_CODE
                      , o_msg_MSG
                      ) ;
            IF o_msg_CODE <> '0' THEN
               DBMS_OUTPUT.PUT_LINE('MES_IF_115 개별처리중 ERROR==>'|| ifr015.aufnr || ',' || o_msg_MSG) ;
            END IF ;

            Commit ;

        end loop;

        DBMS_OUTPUT.PUT_LINE('MES_IF_115==>END');        

    END IF ;
/* ------- TB_IFR015 : 생산오더-화장지초지  End --------------------------- */


/* ------- TB_IFR016 : 생산오더-화장지가공  Begin --------------------------- */
    IF  i_IF_MES_ID  = 'MES_IF_116'  THEN

        DBMS_OUTPUT.PUT_LINE('MES_IF_116==>START');

        for ifr016 in cur_ifr016 loop

            sp_ifr016(  ifr016.IF_IFR_NO
                      , ifr016.AUFNR
                      , o_msg_CODE
                      , o_msg_MSG
                      ) ;
            IF o_msg_CODE <> '0' THEN
               DBMS_OUTPUT.PUT_LINE('MES_IF_116 개별처리중 ERROR==>'|| ifr016.aufnr || ',' || o_msg_MSG) ;
            END IF ;

            Commit ;

        end loop;

        DBMS_OUTPUT.PUT_LINE('MES_IF_116==>END');        

    END IF ;
/* ------- TB_IFR016 : 생산오더-화장지가공  End --------------------------- */


/* ------- TB_IFR017 : 생산오더-패드  Begin --------------------------- */
    IF  i_IF_MES_ID  = 'MES_IF_117'  THEN


        DBMS_OUTPUT.PUT_LINE('MES_IF_117==>START');

        for ifr017 in cur_ifr017 loop

            sp_ifr017(  ifr017.IF_IFR_NO
                      , ifr017.AUFNR
                      , o_msg_CODE
                      , o_msg_MSG
                      ) ;
            IF o_msg_CODE <> '0' THEN
               DBMS_OUTPUT.PUT_LINE('MES_IF_117 개별처리중 ERROR==>'|| ifr017.aufnr || ',' || o_msg_MSG) ;
            END IF ;

            Commit ;

        end loop;

        DBMS_OUTPUT.PUT_LINE('MES_IF_117==>END');        

    END IF ;
/* ------- TB_IFR017 : 생산오더-패드  End --------------------------- */


/* ------- TB_IFR018 : 생산오더-점보롤  Begin ------------------------- */
    IF  i_IF_MES_ID  = 'MES_IF_118'  THEN

        DBMS_OUTPUT.PUT_LINE('MES_IF_118==>START'); 

        for ifr018 in cur_ifr018 loop

            sp_ifr018(  ifr018.IF_IFR_NO
                      , ifr018.AUFNR
                      , o_msg_CODE
                      , o_msg_MSG
                      ) ;
            IF o_msg_CODE <> '0' THEN
               DBMS_OUTPUT.PUT_LINE('MES_IF_118 개별처리중 ERROR==>'|| ifr018.aufnr || ',' || o_msg_MSG) ;
            END IF ;

            Commit ;

        end loop;

        DBMS_OUTPUT.PUT_LINE('MES_IF_118==>END');         

    END IF ;
/* ------- TB_IFR018 : 생산오더-점보롤  End --------------------------- */


/* ------- TB_IFR019 : 생산오더-밀롤,슬리터  Begin ------------------------- */
    IF  i_IF_MES_ID  = 'MES_IF_119'  THEN

        DBMS_OUTPUT.PUT_LINE('MES_IF_119==>START'); 

        for ifr019 in cur_ifr019 loop

            sp_ifr019(  ifr019.IF_IFR_NO
                      , ifr019.AUFNR
                      , o_msg_CODE
                      , o_msg_MSG
                      ) ;
            IF o_msg_CODE <> '0' THEN
               DBMS_OUTPUT.PUT_LINE('MES_IF_119 개별처리중 ERROR==>'|| ifr019.aufnr || ',' || o_msg_MSG) ;
            END IF ;

            Commit ;

        end loop;

        DBMS_OUTPUT.PUT_LINE('MES_IF_119==>END');         

    END IF ;
/* ------- TB_IFR019 : 생산오더-밀롤,슬리터  End --------------------------- */


/* ------- TB_IFR020 : 생산오더-재단  Begin ------------------------- */
    IF  i_IF_MES_ID  = 'MES_IF_120'  THEN

        DBMS_OUTPUT.PUT_LINE('MES_IF_120==>START'); 

        for ifr020 in cur_ifr020 loop

          sp_ifr020(  ifr020.IF_IFR_NO
                    , ifr020.AUFNR
                    , ifr020.ZCOR
                    , o_msg_CODE
                    , o_msg_MSG
          );

          IF o_msg_CODE <> '0' THEN
             DBMS_OUTPUT.PUT_LINE('MES_IF_120 개별처리중 ERROR==>'|| ifr020.aufnr || ',' || o_msg_MSG) ;
          END IF ;

          Commit ;

        end loop;

        DBMS_OUTPUT.PUT_LINE('MES_IF_120==>END');         

    END IF ;
/* ------- TB_IFR020 : 생산오더-재단  End --------------------------- */


/* ------- TB_IFR021 : 생산오더-포장  Begin ------------------------- */
    IF  i_IF_MES_ID  = 'MES_IF_121'  THEN

        DBMS_OUTPUT.PUT_LINE('MES_IF_121==>START'); 

        for ifr021 in cur_ifr021 loop

            sp_ifr021(  ifr021.IF_IFR_NO
                      , ifr021.AUFNR
                      , ifr021.PACKSEQ
                      , o_msg_CODE
                      , o_msg_MSG
                      ) ;
            IF o_msg_CODE <> '0' THEN
               DBMS_OUTPUT.PUT_LINE('MES_IF_121 개별처리중 ERROR==>'|| ifr021.aufnr || ',' || o_msg_MSG) ;
            END IF ;

            Commit ;

        end loop;

        DBMS_OUTPUT.PUT_LINE('MES_IF_121==>END');         

    END IF ;
/* ------- TB_IFR021 : 생산오더-포장  End --------------------------- */


/* ------- TB_IFR022 : 생산오더-예외생산  Begin ------------------------- */
    IF  i_IF_MES_ID  = 'MES_IF_122'  THEN

        DBMS_OUTPUT.PUT_LINE('MES_IF_122==>START'); 

        for ifr022 in cur_ifr022 loop

            sp_ifr022(  ifr022.IF_IFR_NO
                      , ifr022.AUFNR
                      , o_msg_CODE
                      , o_msg_MSG
                      ) ;
            IF o_msg_CODE <> '0' THEN
               DBMS_OUTPUT.PUT_LINE('MES_IF_122 개별처리중 ERROR==>'|| ifr022.aufnr || ',' || o_msg_MSG) ;
            END IF ;

            Commit ;

        end loop;

        DBMS_OUTPUT.PUT_LINE('MES_IF_122==>END');         

    END IF ;
/* ------- TB_IFR022 : 생산오더-예외생산  End --------------------------- */





EXCEPTION
  WHEN OTHERS THEN
    o_msg_code      := '-1' ;
    o_msg_msg       := 'Error,생산오더 수신 중 MAIN에서 오류가 발생하였습니다.' ||
                       ',' || to_char(SQLCODE) || ',' || SQLERRM ;
    DBMS_OUTPUT.PUT_LINE(o_msg_msg);
    rollback ;

END SP_SCH_GET_IFR_MULTI_MANUAL_AUTO ;

/
