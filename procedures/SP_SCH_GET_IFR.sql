
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SCH_GET_IFR" (  i_IF_MES_ID        IN    VARCHAR2
                                                    ,i_IF_MES_KEY       IN    VARCHAR2
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
       ,  BDMNG
       ,  MEINS
       ,  CHARG
       ,  LGORT
       ,  XLOEK
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM    TB_IFR014
  WHERE   IF_STATUS  in  ( 'N','E' )  /*  I/F상태, N:신규, S:성공, E:오류   */
  AND     IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  AND     IF_MES_KEY =   i_IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)     */
  --AND     ROWNUM <= 100
  ORDER  BY IF_GET_DATE
  --           AUFNR
  --       ,   POSNR
  --       ,   IF_GET_DATE
  ;
/* ------- TB_IFR014 : 생산오더 BOM End --------------------------------- */

/* ------- TB_IFR015 : 생산오더-화장지초지  Begin ------------------------- */
CURSOR  cur_ifr015 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  AUFNR
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM    TB_IFR015
  WHERE   IF_STATUS  in  ( 'N','E' )  /*  I/F상태, N:신규, S:성공, E:오류   */
  AND     IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  AND     IF_MES_KEY =   i_IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)     */
--  AND     ROWNUM <= 100
  ORDER  BY  IF_IFR_NO
  ;
/* ------- TB_IFR015 : 생산오더-화장지초지  End --------------------------- */

/* ------- TB_IFR016 : 생산오더-화장지가공  Begin ------------------------- */
CURSOR  cur_ifr016 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  AUFNR
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM    TB_IFR016
  WHERE   IF_STATUS  in  ( 'N','E' )  /*  I/F상태, N:신규, S:성공, E:오류   */
  AND     IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  AND     IF_MES_KEY =   i_IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)     */
--  AND     ROWNUM <= 100
  ORDER  BY  IF_IFR_NO
  ;
/* ------- TB_IFR016 : 생산오더-화장지가공  End --------------------------- */

/* ------- TB_IFR017 : 생산오더-패드  Begin ------------------------------ */
CURSOR  cur_ifr017 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  AUFNR
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM    TB_IFR017
  WHERE   IF_STATUS  in  ( 'N','E' ) 	/*  I/F상태, N:신규, S:성공, E:오류   */
  AND     IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  AND     IF_MES_KEY =   i_IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)     */
--  AND     ROWNUM <= 100
  ORDER  BY  IF_IFR_NO
  ;
/* ------- TB_IFR017 : 생산오더-패드  End -------------------------------- */

/* ------- TB_IFR018 : 생산오더-점보롤  Begin ---------------------------- */
CURSOR  cur_ifr018 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  AUFNR
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM    TB_IFR018
  WHERE   IF_STATUS  in  ( 'N','E' )  /*  I/F상태, N:신규, S:성공, E:오류   */
  AND     IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  AND     IF_MES_KEY =   i_IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)     */
--  AND     ROWNUM <= 100
  ORDER  BY  IF_IFR_NO
  ;
/* ------- TB_IFR018 : 생산오더-점보롤  End ------------------------------ */

/* ------- TB_IFR019 : 생산오더-밀롤,슬리터  Begin ------------------------ */
CURSOR  cur_ifr019 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  AUFNR
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
       ,  SLITER
       ,  ZSIZE
       ,  ZCAP
       ,  ZBOX
       ,  ZPACK
  FROM    TB_IFR019
  WHERE   IF_STATUS  in  ( 'N','E' )  /*  I/F상태, N:신규, S:성공, E:오류   */
  AND     IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  AND     IF_MES_KEY =   i_IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)     */
--  AND     ROWNUM <= 100
  ORDER  BY  IF_IFR_NO
  ;
/* ------- TB_IFR019 : 생산오더-밀롤,슬리터  End -------------------------- */

/* ------- TB_IFR020 : 생산오더-재단  Begin ------------------------------ */
CURSOR  cur_ifr020 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  AUFNR
       ,  ZCOR
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM    TB_IFR020
  WHERE   IF_STATUS  in  ( 'N','E')  /*  I/F상태, N:신규, S:성공, E:오류   */
  AND     IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  AND     IF_MES_KEY =   i_IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)     */
--AND     NVL(ZCOR,' ') <> 'X'                    --재단출고여부'X'인것은 작업지시생성에서 제외하며 WCS로 보내줘야 함. 22-06-09 유상호BJ요청,  전재진책임 X인것을 재확인함. 22-06-16
 -- AND     ROWNUM <= 100
  ORDER  BY  IF_IFR_NO
  ;
/* ------- TB_IFR020 : 생산오더-재단 End --------------------------------- */

/* ------- TB_IFR021 : 생산오더-포장  Begin ------------------------------ */
CURSOR  cur_ifr021 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  AUFNR
       ,  PACKSEQ
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM    TB_IFR021
  WHERE   IF_STATUS  in  ( 'N','E' )  /*  I/F상태, N:신규, S:성공, E:오류   */
  AND     IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  AND     IF_MES_KEY =   i_IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)     */
 -- AND     ROWNUM <= 100
  ORDER  BY  IF_IFR_NO
  ;
/* ------- TB_IFR021 : 생산오더-포장  End -------------------------------- */

/* ------- TB_IFR022 : 생산오더-예외생산  Begin ------------------------------ */
CURSOR  cur_ifr022 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  AUFNR
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM    TB_IFR022
  WHERE   IF_STATUS  in  ( 'N','E' )  /*  I/F상태, N:신규, S:성공, E:오류   */
  AND     IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  AND     IF_MES_KEY =   i_IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)     */
 -- AND     ROWNUM <= 100
  ORDER  BY  IF_IFR_NO
  ;
/* ------- TB_IFR022 : 생산오더-예오생산  Begin ------------------------------ */




/* ------- TB_IFR014 : 생산오더 BOM Begin -------------------------------- */
PROCEDURE sp_ifr014 (  i_IF_IFR_NO      IN   NUMBER   /* MES Interface Sequence(수신번호)        */
                      ,i_AUFNR          IN   VARCHAR2	--오더번호
                      ,i_POSNR          IN   VARCHAR2	--오더item번호
                      ,i_MATNR          IN   VARCHAR2	--자품목자재
                      ,i_BDMNG			IN   VARCHAR2	--오더BOM수량
					  ,i_MEINS			IN 	 VARCHAR2	--오더BOM수량단위
					  ,i_CHARG			IN	 VARCHAR2	--LOT번호
					  ,i_LGORT			IN   VARCHAR2	--저장위치
					  ,i_XLOEK			IN	 VARCHAR2	--삭제여부
                      ,o_msg_CODE       OUT  VARCHAR2
                      ,o_msg_MSG        OUT  VARCHAR2  ) is
  V_CNT             NUMBER    DEFAULT 1;
  V_BOM_CNT         NUMBER    DEFAULT 1;

  V_WO_CNT          NUMBER    DEFAULT 1;

  V_WERKS           VARCHAR2(100)  DEFAULT '';
  V_WO_NO           VARCHAR2(100)  DEFAULT '';
  V_WO_SEQ          NUMBER         DEFAULT 0;

  V_BDMNG			TB_SCH001.BDMNG%TYPE;	--BOM수량
  V_MEINS			TB_SCH001.MEINS%TYPE;	--BOM단위
  V_LGORT			TB_SCH001.LGORT%TYPE;	--저장위치
  V_XLOEK			TB_SCH001.XLOEK%TYPE;	--삭제여부
  V_LOT_NO			TB_SCH001.LOT_NO%TYPE;	--LOT번호
BEGIN
    BEGIN
	    SELECT BDMNG, MEINS, LGORT, DECODE(XLOEK, 'Y', 'X', 'N'), LOT_NO
	      INTO V_BDMNG, V_MEINS, V_LGORT, V_XLOEK, V_LOT_NO
	      FROM TB_SCH001
	     WHERE AUFNR = i_AUFNR
	       AND POSNR = i_POSNR
	       AND MATNR = i_MATNR;

	    V_CNT := 1;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			V_CNT := 0;
	END;

    IF V_CNT = 0 THEN
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
           WHERE  IF_IFR_NO  =  i_IF_IFR_NO;
    ELSE
    	IF i_BDMNG != V_BDMNG OR i_MEINS != V_MEINS OR i_CHARG != V_LOT_NO OR i_LGORT != V_LGORT OR i_XLOEK != V_XLOEK THEN
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
	            FROM TB_IFR014
	            WHERE  IF_IFR_NO =  i_IF_IFR_NO
	           )
             WHERE AUFNR = i_AUFNR
          	   AND POSNR = i_POSNR
          	   AND MATNR = i_MATNR;
    	END IF;
    END IF;

    BEGIN
      --작업지시정보 추출
      SELECT NVL(X.WERKS,''), NVL(X.WRK_ORDR_NO,''), NVL(X.WRK_ORDR_SEQNO,'')
        INTO V_WERKS, V_WO_NO, V_WO_SEQ
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
	        SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_SCH017 WHERE ORDER_NO = i_AUFNR AND NVL(MAN_CUT_YN,'N') <> 'X' AND USE_YN = 'Y'
	        UNION
	        SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_SCH018 WHERE ORDER_NO = i_AUFNR AND USE_YN = 'Y'
	        UNION
	        SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_SCH019 WHERE ORDER_NO = i_AUFNR AND USE_YN = 'Y'
	        UNION
	        SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_LAMI_PC WHERE ORDER_NO = i_AUFNR AND USE_YN = 'Y'
	        UNION
	        SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_LAMI_SL WHERE ORDER_NO = i_AUFNR AND USE_YN = 'Y'
		     ) X;

		V_WO_CNT := 1;
  	EXCEPTION
  		WHEN NO_DATA_FOUND THEN
  			V_WO_CNT := 0;
  	END;

	IF V_WO_CNT = 1 THEN
      BEGIN
	      SELECT ORDER_BOM_QTY, UNIT, STOR_LOC_CD, LOT_NO, DECODE(DLFL, 'Y', 'X', 'N')
	        INTO V_BDMNG, V_MEINS, V_LGORT, V_LOT_NO, V_XLOEK
	        FROM TB_SCH020
	       WHERE WERKS = V_WERKS
	         AND WRK_ORDR_NO = V_WO_NO
	         AND WRK_ORDR_SEQNO = V_WO_SEQ
	         AND MATNR = i_MATNR
	         AND ORDER_NO = i_AUFNR
		  	 AND ORDER_ITM_NO = i_POSNR;
		  V_BOM_CNT := 1;
	  EXCEPTION
	  	WHEN NO_DATA_FOUND THEN
	  		V_BOM_CNT := 0;
	  END;

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
         FROM TB_IFR014
        WHERE  IF_IFR_NO =  i_IF_IFR_NO;
      ELSE
      	IF i_BDMNG != V_BDMNG OR i_MEINS != V_MEINS OR i_CHARG != V_LOT_NO OR i_LGORT != V_LGORT OR i_XLOEK != V_XLOEK THEN
    		UPDATE TB_SCH020
	           SET(     ORDER_BOM_QTY				                 /*		오더BOM 수량					            */
	                  ,	UNIT				                 /*		오더BOM 수량단위					          */
	                  , STOR_LOC_CD                         /*     저장위치                          */
	                  , LOT_NO                        --LOT번호
	                  ,	DLFL				                 /*		삭제여부					                */

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
	              FROM TB_IFR014
	             WHERE IF_IFR_NO =  i_IF_IFR_NO
	           )
             WHERE WERKS = V_WERKS
	           AND WRK_ORDR_NO = V_WO_NO
	           AND WRK_ORDR_SEQNO = V_WO_SEQ
	           AND MATNR = i_MATNR
	           AND ORDER_NO = i_AUFNR
		  	   AND ORDER_ITM_NO = i_POSNR;
    	END IF;
      END IF;
	END IF;--//End Of IF V_WO_CNT > 0 THEN

    o_msg_MSG  :=  'TB_IFR014, 생산오더 BOM 수신되었습니다.1'; -- || ',' || SQLERRM ;

    UPDATE  TB_IFR014
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    POSNR     =  i_POSNR
    AND    AUFNR     =  i_AUFNR
    AND    IF_IFR_NO =  i_IF_IFR_NO
    ;

    o_msg_MSG  :=  'TB_IFR014, 생산오더 BOM 수신되었습니다.2'; -- || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
                o_msg_MSG  :=  'TB_IFR014, 생산오더 BOM 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                o_msg_code      := '-1' ;
                DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                ROLLBACK;

                UPDATE  TB_IFR014
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

/* ------- TB_IFR015 : 생산오더-화장지초지공정  Begin ------------------------- */
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
    FROM TB_IFR015
    WHERE AUFNR = i_AUFNR
    AND IF_IFR_NO = i_IF_IFR_NO;

    IF V_DLFL = 'X' THEN
      UPDATE TB_SCH002
         SET DLFL = V_DLFL
           , UPDDATE = SYSDATE
           , UPDID = 'sp_IFR015'
       WHERE AUFNR =  i_AUFNR;

      UPDATE TB_SCH011
         SET USE_YN = 'N'
           , UPDDATE = SYSDATE
           , UPDID = 'sp_IFR015'
       WHERE ORDER_NO =  i_AUFNR;

      o_msg_MSG  :=  'TB_IFR015, 생산오더-화장지초지 삭제 수신되었습니다.1'; -- || ',' || SQLERRM ;

      UPDATE  TB_IFR015
      SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
            , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
            , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
      WHERE  AUFNR     =  i_AUFNR
      AND    IF_IFR_NO =  i_IF_IFR_NO
      ;

      o_msg_MSG  :=  'TB_IFR015, 생산오더-화장지초지 삭제 수신되었습니다.2'; -- || ',' || SQLERRM ;
      o_msg_code := '0' ;
      RETURN;
    END IF;


    --생산오더
    MERGE
        INTO  TB_SCH002 SCH002
        USING TB_IFR015 IFR015
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
      FROM TB_IFR015
      WHERE IF_IFR_NO  =  i_IF_IFR_NO;

      SP_GET_DOC_SEQ('WOAA',V_WO_DT,V_WO_NO);
    END IF;

    ------------------------------------------

    MERGE
        INTO  TB_SCH011 SCH011
        USING TB_IFR015 IFR015
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
           ,SCH011.USE_YN               =  case when IFR015.DLFL = 'X' then 'N'
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




    o_msg_MSG  :=  'TB_IFR015, 생산오더-화장지초지 수신되었습니다.1'; -- || ',' || SQLERRM ;

    UPDATE  TB_IFR015
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    AUFNR     =  i_AUFNR
    AND    IF_IFR_NO =  i_IF_IFR_NO
    ;

    o_msg_MSG  :=  'TB_IFR015, 생산오더-화장지초지 수신되었습니다.2'; -- || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
                o_msg_MSG  :=  'TB_IFR015, 생산오더-화장지초지 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                o_msg_code      := '-1' ;
                DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                ROLLBACK;

                UPDATE  TB_IFR015
                SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                      , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                      , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
                WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
                AND    AUFNR     =  i_AUFNR
                AND    IF_IFR_NO =  i_IF_IFR_NO
                ;

END  sp_ifr015 ;
/* ------- TB_IFR015 : 생산오더-화장지초지  End --------------------------- */

/* ------- TB_IFR016 : 생산오더-화장지가공공정  Begin ------------------------- */
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
    FROM TB_IFR016
    WHERE AUFNR = i_AUFNR
    AND IF_IFR_NO = i_IF_IFR_NO;

    IF V_DLFL = 'X' THEN
      UPDATE TB_SCH003
         SET DLFL = V_DLFL
           , UPDDATE = SYSDATE
           , UPDID = 'sp_IFR016'
       WHERE AUFNR =  i_AUFNR;

      UPDATE TB_SCH012
         SET USE_YN = 'N'
           , UPDDATE = SYSDATE
           , UPDID = 'sp_IFR016'
       WHERE ORDER_NO =  i_AUFNR;

      o_msg_MSG  :=  'TB_IFR016, 생산오더-화장지가공 삭제 수신되었습니다.1'; -- || ',' || SQLERRM ;

      UPDATE  TB_IFR016
      SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
            , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
            , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
      WHERE  AUFNR     =  i_AUFNR
      AND    IF_IFR_NO =  i_IF_IFR_NO
      ;

      o_msg_MSG  :=  'TB_IFR016, 생산오더-화장지가공 삭제 수신되었습니다.2'; -- || ',' || SQLERRM ;
      o_msg_code := '0' ;
      RETURN;
    END IF;

    MERGE
    INTO  TB_SCH003 SCH003
    USING TB_IFR016 IFR016
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
      FROM TB_IFR016
      WHERE IF_IFR_NO  =  i_IF_IFR_NO;

      SP_GET_DOC_SEQ('WORA',V_WO_DT,V_WO_NO);
    END IF;
    ------------------------------------------

    MERGE
        INTO  TB_SCH012 SCH012
        USING TB_IFR016 IFR016
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
           ,SCH012.USE_YN               =  case when IFR016.DLFL = 'X' then 'N'
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
           ,SCH012.WRK_ORDR_RMK
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
           ,CASE	WHEN IFR016.PRCMC LIKE '%A'	THEN	'초지 5호기 원단'
           			WHEN IFR016.PRCMC LIKE '%X' THEN	'사입 원단'
           END
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






    o_msg_MSG  :=  'TB_IFR016, 생산오더-화장지가공 수신되었습니다.1'; -- || ',' || SQLERRM ;

    UPDATE  TB_IFR016
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    AUFNR     =  i_AUFNR
    AND    IF_IFR_NO =  i_IF_IFR_NO
    ;

    o_msg_MSG  :=  'TB_IFR016, 생산오더-화장지가공 수신되었습니다.2'; -- || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
                o_msg_MSG  :=  'TB_IFR016, 생산오더-화장지가공 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                o_msg_code      := '-1' ;
                DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                ROLLBACK;

                UPDATE  TB_IFR016
                SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                      , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                      , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
                WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
                AND    AUFNR     =  i_AUFNR
                AND    IF_IFR_NO =  i_IF_IFR_NO
                ;

END  sp_ifr016 ;
/* ------- TB_IFR016 : 생산오더-화장지가공  End --------------------------- */


/* ------- TB_IFR017 : 생산오더 패드공정  Begin ------------------------- */
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
    FROM TB_IFR017
    WHERE AUFNR = i_AUFNR
    AND IF_IFR_NO = i_IF_IFR_NO;

    IF V_DLFL = 'X' THEN
      UPDATE TB_SCH004
         SET DLFL = V_DLFL
           , UPDDATE = SYSDATE
           , UPDID = 'sp_IFR017'
       WHERE AUFNR =  i_AUFNR;

      UPDATE TB_SCH013
         SET USE_YN = 'N'
           , UPDDATE = SYSDATE
           , UPDID = 'sp_IFR017'
       WHERE ORDER_NO =  i_AUFNR;

      UPDATE TB_SCH005
         SET DLFL = V_DLFL
           , UPDDATE = SYSDATE
           , UPDID = 'sp_IFR017'
       WHERE AUFNR =  i_AUFNR;

      UPDATE TB_SCH014
         SET USE_YN = 'N'
           , UPDDATE = SYSDATE
           , UPDID = 'sp_IFR017'
       WHERE ORDER_NO =  i_AUFNR;

      o_msg_MSG  :=  'TB_IFR017, 생산오더-패드 삭제 수신되었습니다.1'; -- || ',' || SQLERRM ;

      UPDATE  TB_IFR017
      SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
            , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
            , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
      WHERE  AUFNR     =  i_AUFNR
      AND    IF_IFR_NO =  i_IF_IFR_NO
      ;

      o_msg_MSG  :=  'TB_IFR017, 생산오더-패드 삭제 수신되었습니다.2'; -- || ',' || SQLERRM ;
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
    FROM TB_IFR017
    WHERE IF_IFR_NO  =  i_IF_IFR_NO;

    --************************************************************************************************************************
    --패드
    --************************************************************************************************************************
    IF V_WC = 'SP' THEN
    --패드
    MERGE
    INTO  TB_SCH004 SCH004
    USING TB_IFR017 IFR017
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
      FROM TB_IFR017
      WHERE IF_IFR_NO  =  i_IF_IFR_NO;

      SP_GET_DOC_SEQ('WORB',V_WO_DT,V_WO_NO);
    END IF;
    ------------------------------------------

    MERGE
        INTO  TB_SCH013 SCH013
        USING TB_IFR017 IFR017
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
           ,SCH013.USE_YN               =  case when IFR017.DLFL = 'X' then 'N'
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
    USING TB_IFR017 IFR017
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
      FROM TB_IFR017
      WHERE IF_IFR_NO  =  i_IF_IFR_NO;

      SP_GET_DOC_SEQ('WORC',V_WO_DT,V_WO_NO);
    END IF;
    ------------------------------------------

    MERGE
        INTO  TB_SCH014 SCH014
        USING TB_IFR017 IFR017
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
           ,SCH014.USE_YN               =  case when IFR017.DLFL = 'X' then 'N'
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



    o_msg_MSG  :=  'TB_IFR017, 생산오더 패드가 수신되었습니다.1'; -- || ',' || SQLERRM ;

    UPDATE  TB_IFR017
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    AUFNR     =  i_AUFNR
    AND    IF_IFR_NO =  i_IF_IFR_NO
    ;

    o_msg_MSG  :=  'TB_IFR017, 생산오더 패드가 수신되었습니다.2'; -- || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
                o_msg_MSG  :=  'TB_IFR017, 생산오더 패드 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                o_msg_code      := '-1' ;
                DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                ROLLBACK;

                UPDATE  TB_IFR017
                SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                      , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                      , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
                WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
                AND    AUFNR     =  i_AUFNR
                AND    IF_IFR_NO =  i_IF_IFR_NO
                ;

END  sp_ifr017 ;
/* ------- TB_IFR017 : 생산오더 패드  End --------------------------- */


/* ------- TB_IFR018 : 생산오더-점보롤공정  Begin ------------------------- */
PROCEDURE sp_ifr018 (  i_IF_IFR_NO      IN   NUMBER   /* MES Interface Sequence(수신번호)        */
                      ,i_AUFNR          IN   VARCHAR2
                      ,o_msg_CODE       OUT  VARCHAR2
                      ,o_msg_MSG        OUT  VARCHAR2  ) is

  V_CNT           NUMBER          := 0;      -- 카운트(작업지시존재여부)
  V_BOM_CNT       NUMBER          := 0;      -- 카운트(작업지시BOM존재여부)

  V_WO_DT         VARCHAR2(50)    := '';     -- 지시일자(작업지시생성하기 위해서..)
  V_WO_NO         VARCHAR2(50)    := '';     -- 작업지시번호 (작업지시BOM생성을 위해서..)
  V_WO_SEQ        NUMBER          := 0;      -- 작업지시순번 (작업지시BOM생성을 위해서..)
  V_WERKS         VARCHAR2(50)    := '';     -- 플랜트 (작업지시BOM생성을 위해서..)
  V_DLFL          VARCHAR2(50)    := '';     -- 삭제FLAG
BEGIN


    SELECT NVL(DLFL,' ') INTO V_DLFL
    FROM TB_IFR018
    WHERE AUFNR = i_AUFNR
    AND IF_IFR_NO = i_IF_IFR_NO;

    IF V_DLFL = 'X' THEN
      UPDATE TB_SCH006
         SET DLFL = V_DLFL
           , UPDDATE = SYSDATE
           , UPDID = 'sp_IFR018'
       WHERE AUFNR =  i_AUFNR;

      UPDATE TB_SCH015
         SET USE_YN = 'N'
           , UPDDATE = SYSDATE
           , UPDID = 'sp_IFR018'
       WHERE ORDER_NO =  i_AUFNR;

      o_msg_MSG  :=  'TB_IFR018, 생산오더-점보롤 삭제 수신되었습니다.1'; -- || ',' || SQLERRM ;

      UPDATE  TB_IFR018
         SET  IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
            , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
            , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
       WHERE  AUFNR     =  i_AUFNR
         AND  IF_IFR_NO =  i_IF_IFR_NO
      ;

      o_msg_MSG  :=  'TB_IFR018, 생산오더-점보롤 삭제 수신되었습니다.2'; -- || ',' || SQLERRM ;
      o_msg_code := '0' ;
      RETURN;
    END IF;


  -----------------------------------------------------------------------------------------------------------------------------
  --생산오더
  -----------------------------------------------------------------------------------------------------------------------------
    SELECT COUNT(1) INTO V_CNT FROM TB_SCH006 WHERE AUFNR = i_AUFNR;

    IF V_CNT > 0 THEN
      UPDATE TB_SCH006
      SET(
           WERKS							     								--플랜트
          ,BUDAT							     								--시작일자
          ,PRDTYPE		    		     								--생산라인구분
          ,PRDTYPETXT	    	       								--생산라인구분명
          ,MATNR							     								--제품코드
          ,PCODE							     								--지종코드
          ,WEIGHT						       								--평량
          ,JWIDTH						       								--J/R 지폭
          ,JROLLCNT		    	       								--J/R 권치수
          ,JBRGEW						       								--총중량
          ,JRCNT							     								--J/R 개수
          ,MEINS							     								--생산지시단위
          ,SHEET							     								--판지구분자
          ,AENAM							     								--작업지시자
          ,MACHINE		    		     								--FROM 생산호기
          ,MACHINETXT				       								-- FROM 생산호기명
          ,TOMACHINE	    		     								--TO 생산호기
          ,TOMACHINETXT				     								--TO 생산호기명
          ,STLNR							     								--BOM Num
          ,STLAL							     								--대체Bom
          ,BMENG							     								--모품목기준수량
          ,BMEIN							     								--모품목기준수량 단위
          ,NAUFNR						       								--오더 변경 번호
          ,DLFL			    		       								--오더 삭제 지시자
          ,ORDER_RMK  				     								--특이사항
          ,WRK_CD     				     								--작업장
          ,REM        				     								            --반복생산지시자
          ,ROUTE      				     								--항차

          ,UPDDATE          	     								--수정일자
          ,UPDID            	     								--수정자
      )=(SELECT
           WERKS			         										--플랜트
          ,BUDAT			                            --시작일자
          ,PRDTYPE			                          --생산라인구분
          ,PRDTYPETXT			                        --생산라인구분명
          ,MATNR			                            --제품코드
          ,PCODE			                            --지종코드
          ,WEIGHT			                            --평량
          ,JWIDTH			                            --J/R 지폭
          ,JROLLCNT			                          --J/R 권치수
          ,JBRGEW			                            --총중량
          ,JRCNT			                            --J/R 개수
          ,MEINS			                            --생산지시단위
          ,SHEET			                            --판지구분자
          ,AENAM			                            --작업지시자
          ,MACHINE			                          --FROM 생산호기
          ,MACHINETXT		                          -- FROM 생산호기명
          ,TOMACHINE		                          --TO 생산호기
          ,TOMACHINETXT			                      --TO 생산호기명
          ,STLNR			                            --BOM Num
          ,STLAL			                            --대체Bom
          ,BMENG			                            --모품목기준수량
          ,BMEIN			                            --모품목기준수량 단위
          ,NAUFNR			                            --오더 변경 번호
          ,DLFL			                              --오더 삭제 지시자
          ,ZMEMO                                  --특이사항
          ,ARBPL                                  --작업장
          ,REM                                                                        --반복생산지시자
          ,ROUTE                                  --항차

          ,sysdate                                --수정일자
          ,'sp_IFR018'                                --수정자
         FROM TB_IFR018
         WHERE  IF_IFR_NO = i_IF_IFR_NO
      )
      WHERE  AUFNR   = i_AUFNR;
    ELSE
      INSERT INTO TB_SCH006(
           AUFNR							                    --오더번호
          ,WERKS							                    --플랜트
          ,BUDAT							                    --시작일자
          ,PRDTYPE							                  --생산라인구분
          ,PRDTYPETXT							                --생산라인구분명
          ,MATNR							                    --제품코드
          ,PCODE							                    --지종코드
          ,WEIGHT							                    --평량
          ,JWIDTH							                    --J/R 지폭
          ,JROLLCNT							                  --J/R 권치수
          ,JBRGEW							                    --총중량
          ,JRCNT							                    --J/R 개수
          ,MEINS							                    --생산지시단위
          ,SHEET							                    --판지구분자
          ,AENAM							                    --작업지시자
          ,MACHINE							                  --FROM 생산호기
          ,MACHINETXT							                --FROM 생산호기명
          ,TOMACHINE							                --TO 생산호기명
          ,TOMACHINETXT							              --TO 생산호기명
          ,STLNR							                    --BOM Num
          ,STLAL							                    --대체Bom
          ,BMENG							                    --모품목기준수량
          ,BMEIN							                    --모품목기준수량 단위
          ,NAUFNR							                    --오더 변경 번호
          ,DLFL							                      --오더 삭제 지시자
          ,REM                                                                        --반복생산 지시자
          ,ROUTE                                  --항차
          ,ORDER_RMK                              --특이사항
          ,WRK_CD                                 --작업장

          ,REGDATE                                --등록일자
          ,REGID                                  --등록자
          ,UPDDATE                                --수정일자
          ,UPDID                                  --수정자
      )
      SELECT
           AUFNR				                          --오더번호
          ,WERKS				                          --플랜트
          ,BUDAT				                          --시작일자
          ,PRDTYPE				               		      --생산라인구분
          ,PRDTYPETXT				             	        --생산라인구분명
          ,MATNR				                          --제품코드
          ,PCODE				                          --지종코드
          ,WEIGHT				                          --평량
          ,JWIDTH				                          --J/R 지폭
          ,JROLLCNT				                        --J/R 권치수
          ,JBRGEW				                          --총중량
          ,JRCNT				                          --J/R 개수
          ,MEINS				                 		      --생산지시단위
          ,SHEET				                          --판지구분자
          ,AENAM				                          --작업지시자
          ,MACHINE				               		      --FROM 생산호기
          ,MACHINETXT				             	        --FROM 생산호기명
          ,TOMACHINE				                      --TO 생산호기
          ,TOMACHINETXT				                    --TO 생산호기명
          ,STLNR				                          --BOM Num
          ,STLAL				                          --대체Bom
          ,BMENG				                 		      --모품목기준수량
          ,BMEIN				                 		      --모품목기준수량 단위
          ,NAUFNR				                 	        --오더 변경 번호
          ,DLFL				                   	        --오더 삭제 지시자
          ,REM                                                                        --반복생산 지시자
          ,ROUTE                                  --항차
          ,ZMEMO                                  --특이사항
          ,ARBPL                                  --작업장

          ,sysdate                                --등록일자
          ,'sp_IFR018'                                --등록자
          ,null                                   --수정일자
          ,null                                   --수정자
      FROM  TB_IFR018
      WHERE  IF_IFR_NO = i_IF_IFR_NO;
    END IF;


    --========================================
    --KHJ추가 2022-05-01:작업지시
    --========================================
    ------------------------------------------
    --작업지시가 존재하지 않으면 작업지시 번호 생성
    SELECT COUNT(ORDER_NO) INTO V_CNT
    FROM TB_SCH015
    WHERE ORDER_NO = i_AUFNR;

    IF V_CNT = 0 THEN
      SELECT BUDAT INTO V_WO_DT
      FROM TB_IFR018
      WHERE IF_IFR_NO  =  i_IF_IFR_NO;

      SP_GET_DOC_SEQ('WOJA',V_WO_DT,V_WO_NO);
    END IF;
    ------------------------------------------
    IF V_CNT > 0 THEN
      UPDATE TB_SCH015
      SET(
         WERKS                 									--플랜트코드
        ,PRD_REQ_DT            									--생산요청일자
        ,PRDTYPE               									--생산라인구분
        ,PRDTYPETXT            									--생산라인구분명
        ,MATNR                 									--자재 코드
        ,PCODE                 									--지종
        ,BS_WGT                									--평량
        ,JWIDTH                									--J/R 지폭
        ,JROLLCNT              									--J/R 권치수
        ,TOT_WGT               									--총중량
        ,JRCNT                 									--J/R 개수
        ,UNIT                  									--단위
        ,SHEET                 									--판지구분자
        ,WORK_ORDER            									--작업지시자
        ,MACHINE               									--FROM 생산호기
        ,MACHINE_NM            									--FROM 생산 호기명
        ,TO_MACHINE            									--TO 생산호기
        ,TO_MACHINE_NM         									--TO 생산 호기명
        ,WRK_CD                									--작업장코드
        ,BOM_NO                									--BOM Num
        ,ATN_BOM_NO            									--대체Bom
        ,PRT_MATNR_QTY         									--모품목기준수량 수량
        ,PRT_MATNR_UNIT        									--모품목기준수량 단위
        ,NAUFNR                									--오더 변경 번호
        ,DLFL                  									--오더 삭제 지시자
        ,ORDER_RMK             									--특이사항
        ,REM                   									                    --반복생산지시자
        ,ROUTE                 									--항차
        ,WRK_ORDR_QTY          									--지시수량


        ,UPDDATE               									--수정일시
        ,UPDID                 									--수정자ID
        ,USE_YN                									--사용여부(Y:사용 N:미사용)
      )=(SELECT
         WERKS                          				--플랜트코드
        ,BUDAT                          				--생산요청일자
        ,PRDTYPE                        				--생산라인구분
        ,PRDTYPETXT                     				--생산라인구분명
        ,MATNR                          				--자재 코드
        ,PCODE                          				--지종
        ,WEIGHT                         				--평량
        ,JWIDTH                         				--J/R 지폭
        ,JROLLCNT                       				--J/R 권치수
        ,JBRGEW                         				--총중량
        ,JRCNT                          				--J/R 개수
        ,MEINS                          				--단위
        ,SHEET                          				--판지구분자
        ,AENAM                          				--작업지시자
        ,MACHINE                        				--FROM 생산호기
        ,MACHINETXT                     				--FROM 생산 호기명
        ,TOMACHINE                      				--TO 생산호기
        ,TOMACHINETXT                   				--TO 생산 호기명
        ,ARBPL                          				--작업장코드
        ,STLNR                          				--BOM Num
        ,STLAL                          				--대체Bom
        ,BMENG                          				--모품목기준수량 수량
        ,BMEIN                          				--모품목기준수량 단위
        ,NAUFNR                         				--오더 변경 번호
        ,DLFL                           				--오더 삭제 지시자
        ,ZMEMO                          				--특이사항
        ,REM                            				                            --반복생산지시자
        ,ROUTE                          				--항차
        ,JBRGEW                         				--지시수량

        ,sysdate                               	--수정일시
        ,'sp_ifr018'                      	        --수정자ID
        ,case when DLFL = 'Y' then 'N'
              when DLFL = 'N' then 'Y'
         end                                   	--사용여부(Y:사용 N:미사용)
         FROM TB_IFR018
         WHERE  IF_IFR_NO = i_IF_IFR_NO
      )
      WHERE ORDER_NO = i_AUFNR;
    ELSE
      INSERT INTO TB_SCH015(
         WRK_ORDR_NO                     				--작업지시번호-->작업지시 생성자 사용 WO + R
        ,WRK_ORDR_SEQNO                  				--작업지시순번
        ,WRK_SEQNO                       				--작업순서
        ,ORDR_GEN_DT                     				--지시생성일자

        ,ORDER_NO             									--오더번호
        ,WERKS                									--플랜트코드
        ,PRD_REQ_DT           									--생산요청일자
        ,PRDTYPE              									--생산라인구분
        ,PRDTYPETXT           									--생산라인구분명
        ,MATNR                									--자재 코드
        ,PCODE                									--지종
        ,BS_WGT               									--평량
        ,JWIDTH               									--J/R 지폭
        ,JROLLCNT             									--J/R 권치수
        ,TOT_WGT              									--총중량
        ,JRCNT                									--J/R 개수
        ,UNIT                 									--단위
        ,SHEET                									--판지구분자
        ,WORK_ORDER           									--작업지시자
        ,MACHINE              									--FROM 생산호기
        ,MACHINE_NM           									--FROM 생산 호기명
        ,TO_MACHINE           									--TO 생산호기
        ,TO_MACHINE_NM        									--TO 생산 호기명
        ,WRK_CD               									--작업장코드
        ,BOM_NO               									--BOM Num
        ,ATN_BOM_NO           									--대체Bom
        ,PRT_MATNR_QTY        									--모품목기준수량 수량
        ,PRT_MATNR_UNIT       									--모품목기준수량 단위
        ,NAUFNR               									--오더 변경 번호
        ,DLFL                 									--오더 삭제 지시자
        ,ORDER_RMK                       				--특이사항
        ,REM                             				                            --반복생산지시자
        ,ROUTE                           				--항차
        ,WRK_ORDR_QTY                    				--지시수량

        ,COMP_YN                         				--완료여부
        ,REGDATE                         				--등록일시
        ,REGID                           				--등록자ID
        ,UPDDATE                         				--수정일시
        ,UPDID                           				--수정자ID
        ,USE_YN                          				--사용여부(Y:사용 N:미사용)
      )
      SELECT
         V_WO_NO     																			--작업지시번호
        ,1                                                --작업지시순번
        ,SUBSTR(V_WO_NO,-4)                               --작업순서(작업지시번호,-4)
        ,TO_CHAR(sysdate,'YYYYMMDD')                       --지시생성일자

        ,AUFNR       																			--오더번호
        ,WERKS                          									--플랜트코드
        ,BUDAT                          									--생산요청일자
        ,PRDTYPE                        									--생산라인구분
        ,PRDTYPETXT                     									--생산라인구분명
        ,MATNR                          									--자재 코드
        ,PCODE                          									--지종
        ,WEIGHT                         									--평량
        ,JWIDTH                         									--J/R 지폭
        ,JROLLCNT                       									--J/R 권치수
        ,JBRGEW                         									--총중량
        ,JRCNT                          									--J/R 개수
        ,MEINS                          									--단위
        ,SHEET                          									--판지구분자
        ,AENAM                          									--작업지시자
        ,MACHINE                        									--FROM 생산호기
        ,MACHINETXT                     									--FROM 생산 호기명
        ,TOMACHINE                      									--TO 생산호기
        ,TOMACHINETXT                   									--TO 생산 호기명
        ,ARBPL                          									--작업장코드
        ,STLNR                          									--BOM Num
        ,STLAL                          									--대체Bom
        ,BMENG                          									--모품목기준수량 수량
        ,BMEIN                          									--모품목기준수량 단위
        ,NAUFNR                         									--오더 변경 번호
        ,DLFL                           									--오더 삭제 지시자
        ,ZMEMO                                            --특이사항
        ,REM                                                                                            --반복생산지시자
        ,ROUTE                                            --항차
        ,JBRGEW                                           --지시수량

        ,'N'                                                --완료여부
        ,sysdate                                          --등록일시
        ,'sp_ifr018'                                          --등록자ID
        ,null                                             --수정일시
        ,null                                             --수정자ID
        ,case when DLFL = 'X' then 'N'
             else 'Y'
        end                                               --사용여부(Y:사용 N:미사용)
      FROM  TB_IFR018
      WHERE  IF_IFR_NO = i_IF_IFR_NO;
    END IF;


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




    o_msg_MSG  :=  'TB_IFR018, 생산오더-점보롤 수신되었습니다.1'; -- || ',' || SQLERRM ;

    UPDATE  TB_IFR018
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    AUFNR     =  i_AUFNR
    AND    IF_IFR_NO =  i_IF_IFR_NO
    ;

    o_msg_MSG  :=  'TB_IFR018, 생산오더-점보롤가 수신되었습니다.2'; -- || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
                o_msg_MSG  :=  'TB_IFR018, 생산오더-점보롤 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                o_msg_code      := '-1' ;
                DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                ROLLBACK;

                UPDATE  TB_IFR018
                SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                      , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                      , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
                WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
                AND    AUFNR     =  i_AUFNR
                AND    IF_IFR_NO =  i_IF_IFR_NO
                ;

END  sp_ifr018 ;
/* ------- TB_IFR018 : 생산오더-점보롤  End --------------------------- */


/* ------- TB_IFR019 : 생산오더-밀롤공정(슬리터공정)  Begin ------------------------- */
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
    FROM TB_IFR019
    WHERE AUFNR = i_AUFNR
    AND IF_IFR_NO = i_IF_IFR_NO;

    IF V_DLFL = 'X' THEN
      UPDATE TB_SCH007
         SET DLFL = V_DLFL
           , UPDDATE = SYSDATE
           , UPDID = 'sp_IFR019'
       WHERE AUFNR =  i_AUFNR;

      UPDATE TB_SCH016
         SET USE_YN = 'N'
           , UPDDATE = SYSDATE
           , UPDID = 'sp_IFR019'
       WHERE ORDER_NO =  i_AUFNR;

      o_msg_MSG  :=  'TB_IFR019, 생산오더-밀롤 삭제 수신되었습니다.1'; -- || ',' || SQLERRM ;

      UPDATE  TB_IFR019
      SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
            , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
            , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
      WHERE  AUFNR     =  i_AUFNR
      AND    IF_IFR_NO =  i_IF_IFR_NO
      ;

      o_msg_MSG  :=  'TB_IFR019, 생산오더-밀롤 삭제 수신되었습니다.2'; -- || ',' || SQLERRM ;
      o_msg_code := '0' ;
      RETURN;
    END IF;


  -----------------------------------------------------------------------------------------------------------------------------
  --생산오더
  -----------------------------------------------------------------------------------------------------------------------------
    SELECT COUNT(1) INTO V_CNT FROM TB_SCH007 WHERE AUFNR = i_AUFNR;

    IF V_CNT > 0 THEN
      UPDATE TB_SCH007
      SET(
         JRPO			     								--오더 번호
        ,WERKS			     							--플랜트
        ,ORDER_NUM			 							--생산지시 No
        ,ORDER_SEQ			 							--생산지시 seq
        ,BUDAT			     							--시작일자
        ,AUART			     							--오더유형
        ,AUARTXT			   							--오더유형 텍스트
        ,MMATNR			   								--밀롤 자재 코드
        ,MACHINE        							--FROM 생산호기
        ,MACHINETXT     							--FROM 생산 호기명
        ,TOMACHINE      							--TO 생산호기
        ,TOMACHINETXT   							--TO 생산 호기명
        ,MATNR			     							--점보롤 자재 코드
        ,PCODE			     							--지종코드
        ,WEIGHT			   								--평량
        ,MWIDTH			   								--M/R 지폭
        ,MWIDTH_INPUT									--M/R 지폭_INPUT
        ,MWIDTH_SLITER	 							    --M/R 지폭_SLITER
        ,MROLLCNT			 							--M/R 권치수
        ,MRCNT			     							--M/R 폭수
        ,MBRGEW			   								--M/R 중량
        ,MGEWEI			   								--단위
        ,JRCNT			     							--J/R 개수
        ,OVBELN			   								--판매 문서
        ,OPOSNR			   								--판매 문서 품목 번호
        ,OAUART			   								--판매 문서 오더 유형
        ,OAUARTXT			 							--판매 문서 오더 유형 텍스트
        ,VBELN			     							--판매 문서
        ,POSNR			     							--판매 문서 품목 번호
        ,VDATU			     							--납품 요청일자
        ,SAUART			   								--판매 문서 오더 유형
        ,SAUARTXT			 							--판매 문서 오더 유형 텍스트
        ,REMARK			   								--비고
        ,SHEET			     							--판지 구분자
        ,SLITER_SET										--슬리터 구분
        ,MRLDCK			   								--밀롤 창고 적치 여부
        ,CUTTER			   								--카터
        ,STLNR			     							--BOM Num
        ,STLAL			     							--대체Bom
        ,BMENG			     							--모품목기준수량
        ,BMEIN			     							--모품목기준수량 단위
        ,ROUTE          							    --항차
        ,DLFL			     							--오더 삭제 지시자
        ,KUNNR          							    --판매처
        ,KUNNRT         							    --판매처명
        ,ZSIZE         							        --지관사이즈(인치)
        ,ZCAP         							        --지관마개여부
        ,ZBOX         							        --골판지여부
        ,ZPACK         							        --포장여부

        ,UPDDATE        							    --수정일자
        ,UPDID          							    --수정자
      )=(SELECT
         JRPO			      							--오더 번호
        ,WERKS			                                --플랜트
        ,ORDER_NUM			                            --생산지시 No
        ,ORDER_SEQ			                            --생산지시 seq
        ,BUDAT			                                --시작일자
        ,AUART			                                --오더유형
        ,AUARTXT			                            --오더유형 텍스트
        ,MMATNR			                                --밀롤 자재 코드
        ,MACHINE                                        --FROM 생산호기
        ,MACHINETXT                                     --FROM 생산 호기명
        ,TOMACHINE                                      --TO 생산호기
        ,TOMACHINETXT                                   --TO 생산 호기명
        ,MATNR			                                --점보롤 자재 코드
        ,PCODE			                                --지종코드
        ,WEIGHT			                                --평량
        ,MWIDTH			                                --M/R 지폭
        ,MWIDTH_INPUT		                            --M/R 지폭_INPUT
        ,MWIDTH_SLITER	                                --M/R 지폭_SLITER
        ,MROLLCNT			                            --M/R 권치수
        ,MRCNT			                                --M/R 폭수
        ,MBRGEW			                                --M/R 중량
        ,MGEWEI			                                --단위
        ,JRCNT			                                --J/R 개수
        ,OVBELN			                                --판매 문서
        ,OPOSNR			                                --판매 문서 품목 번호
        ,OAUART			                                --판매 문서 오더 유형
        ,OAUARTXT			                            --판매 문서 오더 유형 텍스트
        ,VBELN			                                --판매 문서
        ,POSNR			                                --판매 문서 품목 번호
        ,VDATU			                                --납품 요청일자
        ,SAUART			                                --판매 문서 오더 유형
        ,SAUARTXT			                            --판매 문서 오더 유형 텍스트
        ,REMARK			                                --비고
        ,SHEET			                                --판지 구분자
        ,SLITER_SET			                            --슬리터 구분
        ,MRLDCK			                                --밀롤 창고 적치 여부
        ,CUTTER			                                --카터
        ,STLNR			                                --BOM Num
        ,STLAL			                                --대체Bom
        ,BMENG			                                --모품목기준수량
        ,BMEIN			                                --모품목기준수량 단위
        ,ROUTE                                          --항차
        ,DLFL			                                --오더 삭제 지시자
        ,KUNNR                                          --판매처
        ,NAME1                                          --판매처명
        ,ZSIZE         							        --지관사이즈(인치)
        ,ZCAP         							        --지관마개여부
        ,ZBOX         							        --골판지여부
        ,ZPACK         							        --포장여부

        ,sysdate                                        --수정일자
        ,'sp_ifr019'                                    --수정자
         FROM TB_IFR019
         WHERE  IF_IFR_NO = i_IF_IFR_NO
      )
      WHERE  AUFNR   = i_AUFNR;
    ELSE
      INSERT INTO TB_SCH007(
         AUFNR							            --오더번호
        ,JRPO							            --점보롤 오더 번호
        ,WERKS							            --플랜트
        ,ORDER_NUM							        --생산지시 No
        ,ORDER_SEQ							        --생산지시 seq
        ,BUDAT							            --시작일자
        ,AUART							            --오더유형
        ,AUARTXT							        --오더유형 텍스트
        ,MMATNR							            --밀롤 자재 코드
        ,MACHINE                                    --FROM 생산호기
        ,MACHINETXT                                 --FROM 생산 호기명
        ,TOMACHINE                                  --TO 생산호기
        ,TOMACHINETXT                               --TO 생산호기명
        ,MATNR							            --점보롤 자재 코드
        ,PCODE							            --지종코드
        ,WEIGHT							            --평량
        ,MWIDTH							            --M/R 지폭
        ,MWIDTH_INPUT							    --M/R 지폭_INPUT
        ,MWIDTH_SLITER							    --M/R 지폭_SLITER
        ,MROLLCNT							        --M/R 권치수
        ,MRCNT							            --M/R 폭수
        ,MBRGEW							            --M/R 중량
        ,MGEWEI							            --단위
        ,JRCNT							            --J/R 개수
        ,OVBELN							            --판매 문서
        ,OPOSNR							            --판매 문서 품목 번호
        ,OAUART							            --판매 문서 오더 유형
        ,OAUARTXT							        --판매 문서 오더 유형 텍스트
        ,VBELN							            --판매 문서
        ,POSNR							            --판매 문서 품목 번호
        ,VDATU							            --납품 요청일자
        ,SAUART							            --판매 문서 오더 유형
        ,SAUARTXT							        --판매 문서 오더 유형 텍스트
        ,REMARK							            --비고
        ,SHEET							            --판지 구분자
        ,SLITER_SET							        --슬리터 구분
        ,MRLDCK							            --밀롤 창고 적치 여부
        ,CUTTER							            --카터
        ,STLNR							            --BOM Num
        ,STLAL							            --대체Bom
        ,BMENG							            --모품목기준수량
        ,BMEIN							            --모품목기준수량 단위
        ,ROUTE                                      --항차
        ,DLFL							            --오더 삭제 지시자
        ,KUNNR                                      --판매처
        ,KUNNRT                                     --판매처명
        ,SLITER                                     --슬리터구분
        ,FRAUFNR                                    --이전오더
        ,ZSIZE         							    --지관사이즈(인치)
        ,ZCAP         							    --지관마개여부
        ,ZBOX         							    --골판지여부
        ,ZPACK         							    --포장여부

        ,REGDATE                                    --등록일자
        ,REGID                                      --등록자
        ,UPDDATE                                    --수정일자
        ,UPDID                                      --수정자
      )
      SELECT
         AUFNR				         				--오더번호
        ,JRPO				                        --점보롤 오더 번호
        ,WERKS				                        --플랜트
        ,ORDER_NUM				                    --생산지시 No
        ,ORDER_SEQ				                    --생산지시 seq
        ,BUDAT				                        --시작일자
        ,AUART				                        --오더유형
        ,AUARTXT				                    --오더유형 텍스트
        ,MMATNR				                        --밀롤 자재 코드
        ,MACHINE                                    --FROM 생산호기
        ,MACHINETXT                                 --FROM 생산 호기명
        ,TOMACHINE                                  --TO 생산호기
        ,TOMACHINETXT			                    --TO 생산호기명
        ,MATNR				                        --점보롤 자재 코드
        ,PCODE				                        --지종코드
        ,WEIGHT				                        --평량
        ,MWIDTH				                        --M/R 지폭
        ,MWIDTH_INPUT				                --M/R 지폭_INPUT
        ,MWIDTH_SLITER				                --M/R 지폭_SLITER
        ,MROLLCNT				                    --M/R 권치수
        ,MRCNT				                        --M/R 폭수
        ,MBRGEW				                        --M/R 중량
        ,MGEWEI				                        --단위
        ,JRCNT				                        --J/R 개수
        ,OVBELN				                        --판매 문서
        ,OPOSNR				                        --판매 문서 품목 번호
        ,OAUART				                        --판매 문서 오더 유형
        ,OAUARTXT				                    --판매 문서 오더 유형 텍스트
        ,VBELN				                        --판매 문서
        ,POSNR				                        --판매 문서 품목 번호
        ,VDATU				                        --납품 요청일자
        ,SAUART				                        --판매 문서 오더 유형
        ,SAUARTXT				                    --판매 문서 오더 유형 텍스트
        ,REMARK				                        --비고
        ,SHEET				                        --판지 구분자
        ,SLITER_SET				                    --슬리터 구분
        ,MRLDCK				                        --밀롤 창고 적치 여부
        ,CUTTER				                        --카터
        ,STLNR				                        --BOM Num
        ,STLAL				                        --대체Bom
        ,BMENG				                        --모품목기준수량
        ,BMEIN				                        --모품목기준수량 단위
        ,ROUTE                                      --항차
        ,DLFL				                        --오더 삭제 지시자
        ,KUNNR                                      --판매처
        ,NAME1                              --판매처명
        ,SLITER                                     --슬리터구분
        ,FRAUFNR                                    --이전오더
        ,ZSIZE         							    --지관사이즈(인치)
        ,ZCAP         							    --지관마개여부
        ,ZBOX         							    --골판지여부
        ,ZPACK         							    --포장여부

        ,sysdate                           --등록일자
        ,'sp_ifr019'                         --등록자
        ,null                             --수정일자
        ,null                                --수정자
      FROM  TB_IFR019
      WHERE  IF_IFR_NO = i_IF_IFR_NO;
    END IF;


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
      FROM TB_IFR019
      WHERE IF_IFR_NO  =  i_IF_IFR_NO;

      SP_GET_DOC_SEQ('WOMA',V_WO_DT,V_WO_NO);
    END IF;
    ------------------------------------------

    IF V_CNT > 0 THEN
      UPDATE TB_SCH016
      SET(
         PRE_ORDER_NO         									--이전 오더 번호
        ,WERKS                									--플랜트코드
        ,ORDER_NUM            									--생산지시 No
        ,ORDER_SEQ            									--생산지시 seq
        ,PRD_REQ_DT           									--생산요청일자
        ,ORDER_DIV            									--오더유형
        ,ORDER_DIV_NM         									--오더유형 텍스트
        ,MATNR                									--자재 코드
        ,MACHINE              									--생산호기
        ,MACHINE_NM           									--생산 호기명
        ,TO_MACHINE           									--TO 생산호기
        ,TO_MACHINE_NM        									--TO 생산 호기명
        ,JMATNR               									--점보롤 자재 코드
        ,PCODE                									--지종코드
        ,BS_WGT               									--평량
        ,MWIDTH               									--M/R 지폭
        ,MWIDTH_INPUT         									--M/R 지폭_INPUT
        ,MWIDTH_SLITER        									--M/R 지폭_SLITER
        ,MROLLCNT             									--M/R 권치수
        ,MRCNT                									--M/R 폭수
        ,MBRGEW               									--M/R 중량
        ,UNIT                 									--단위
        ,JRCNT                									--J/R 개수
        ,OVBELN               									--판매문서
        ,OPOSNR               									--판매문서 항목번호
        ,OAUART_DIV           									--판매문서 유형
        ,OAUART_NM            									--판매 문서 오더 유형 텍스트
        ,VBELN                									--판매문서
        ,POSNR                									--판매문서 항목번호
        ,VDATU                									--납품 요청일자
        ,SAUART_DIV           									--판매문서 유형
        ,SAUART_NM            									--판매 문서 오더 유형 텍스트
        ,ORDER_RMK            									--비고(22-06-08:REMARK->ORDER_RMK로 변경함)
        ,SHEET                									--판지 구분자
        ,SLITER_SET           									--슬리터 구분
        ,MRLDCK               									--밀롤 창고 적치 여부
        ,CUTTER               									--카터
        ,ATN_BOM_NO           									--대체Bom
        ,BOM_NO               									--BOM Num
        ,PRT_MATNR_QTY        									--모품목기준수량
        ,PRT_MATNR_UNIT       									--모품목기준수량 단위
        ,DLFL                 									--오더 삭제 지시자
        ,ROUTE                									--항차
        ,KUNNR                									--판매처
        ,KUNNRT               									--판매처명
        ,SLITER               									--슬리터구분
        ,CORE_INCH         							            --지관사이즈(인치)
        ,COVER_YN         							            --지관마개여부
        ,CORR_YN         							            --골판지여부
        ,PACK_YN         							            --포장여부

        ,UPDDATE              									--수정일시
        ,UPDID                									--수정자ID
        ,USE_YN               									--사용여부(Y:사용 N:미사용)
      )=(SELECT
         FRAUFNR                        				--이전 오더 번호
        ,WERKS                          				--플랜트코드
        ,ORDER_NUM                      				--생산지시 No
        ,ORDER_SEQ                      				--생산지시 seq
        ,BUDAT                          				--생산요청일자
        ,AUART                          				--오더유형
        ,AUARTXT                        				--오더유형 텍스트
        ,MMATNR                         				--자재 코드
        ,MACHINE                        				--생산호기
        ,MACHINETXT                     				--생산 호기명
        ,TOMACHINE                      				--TO 생산호기
        ,TOMACHINETXT                   				--TO 생산 호기명
        ,MATNR                          				--점보롤 자재 코드
        ,PCODE                          				--지종코드
        ,WEIGHT                         				--평량
        ,MWIDTH                         				--M/R 지폭
        ,MWIDTH_INPUT                   				--M/R 지폭_INPUT
        ,MWIDTH_SLITER                  				--M/R 지폭_SLITER
        ,MROLLCNT                       				--M/R 권치수
        ,MRCNT                          				--M/R 폭수
        ,MBRGEW                         				--M/R 중량
        ,MGEWEI                         				--단위
        ,JRCNT                          				--J/R 개수
        ,OVBELN                         				--판매문서
        ,OPOSNR                         				--판매문서 항목번호
        ,OAUART                         				--판매문서 유형
        ,OAUARTXT                       				--판매 문서 오더 유형 텍스트
        ,VBELN                          				--판매문서
        ,POSNR                          				--판매문서 항목번호
        ,VDATU                          				--납품 요청일자
        ,SAUART                         				--판매문서 유형
        ,SAUARTXT                       				--판매 문서 오더 유형 텍스트
        ,REMARK                         				--비고(22-06-08:REMARK->ORDER_RMK로 변경함)
        ,SHEET                          				--판지 구분자
        ,SLITER_SET                     				--슬리터 구분
        ,MRLDCK                         				--밀롤 창고 적치 여부
        ,CUTTER                         				--카터
        ,STLNR                          				--대체Bom
        ,STLAL                          				--BOM Num
        ,BMENG                          				--모품목기준수량
        ,BMEIN                          				--모품목기준수량 단위
        ,DLFL                           				--오더 삭제 지시자
        ,ROUTE                          				--항차
        ,KUNNR                          				--판매처
        ,NAME1                          				--판매처명
        ,SLITER                         				--슬리터구분
        ,ZSIZE         							        --지관사이즈(인치)
        ,ZCAP         							        --지관마개여부
        ,ZBOX         							        --골판지여부
        ,ZPACK         							        --포장여부

        ,sysdate                                        --수정일시
        ,'sp_ifr019'                                    --수정자ID
        ,case when DLFL = 'Y' then 'N'
              when DLFL = 'N' then 'Y'
         end                                            --사용여부(Y:사용 N:미사용)
         FROM TB_IFR019
         WHERE  IF_IFR_NO = i_IF_IFR_NO
      )
      WHERE ORDER_NO = i_AUFNR;
    ELSE
      INSERT INTO TB_SCH016(
           WRK_ORDR_NO                                              --작업지시번호-->작업지시 생성자 사용 WO + R
          ,WRK_ORDR_SEQNO                                           --작업지시순번
          ,WRK_SEQNO                                                --작업순서
          ,ORDR_GEN_DT                                              --지시생성일자

          ,ORDER_NO													--오더번호
          ,PRE_ORDER_NO         									--이전 오더 번호
          ,WERKS                									--플랜트코드
          ,ORDER_NUM            									--생산지시 No
          ,ORDER_SEQ            									--생산지시 seq
          ,PRD_REQ_DT           									--생산요청일자
          ,ORDER_DIV            									--오더유형
          ,ORDER_DIV_NM         									--오더유형 텍스트
          ,MATNR                									--자재 코드
          ,MACHINE              									--생산호기
          ,MACHINE_NM           									--생산 호기명
          ,TO_MACHINE           									--TO 생산호기
          ,TO_MACHINE_NM        									--TO 생산 호기명
          ,JMATNR               									--점보롤 자재 코드
          ,PCODE                									--지종코드
          ,BS_WGT               									--평량
          ,MWIDTH               									--M/R 지폭
          ,MWIDTH_INPUT         									--M/R 지폭_INPUT
          ,MWIDTH_SLITER        									--M/R 지폭_SLITER
          ,MROLLCNT             									--M/R 권치수
          ,MRCNT                									--M/R 폭수
          ,MBRGEW               									--M/R 중량
          ,UNIT                 									--단위
          ,JRCNT                									--J/R 개수
          ,OVBELN               									--판매문서
          ,OPOSNR               									--판매문서 항목번호
          ,OAUART_DIV           									--판매문서 유형
          ,OAUART_NM            									--판매 문서 오더 유형 텍스트
          ,VBELN                									--판매문서
          ,POSNR                									--판매문서 항목번호
          ,VDATU                									--납품 요청일자
          ,SAUART_DIV           									--판매문서 유형
          ,SAUART_NM            									--판매 문서 오더 유형 텍스트
          ,ORDER_RMK             									--비고(22-06-08:REMARK->ORDER_RMK로 변경함)
          ,SHEET                									--판지 구분자
          ,SLITER_SET           									--슬리터 구분
          ,MRLDCK               									--밀롤 창고 적치 여부
          ,CUTTER               									--카터
          ,ATN_BOM_NO           									--대체Bom
          ,BOM_NO               									--BOM Num
          ,PRT_MATNR_QTY        									--모품목기준수량
          ,PRT_MATNR_UNIT       									--모품목기준수량 단위
          ,DLFL                 									--오더 삭제 지시자
          ,ROUTE                                                    --항차
          ,KUNNR                                                    --판매처
          ,KUNNRT                                                   --판매처명
          ,SLITER			 					                    --슬리터구분
          ,WRK_ORDR_QTY
          ,CORE_INCH         					                    --지관사이즈(인치)
          ,COVER_YN         					                    --지관마개여부
          ,CORR_YN         						                    --골판지여부
          ,PACK_YN         						                    --포장여부

          ,COMP_YN                                                  --완료여부
          ,REGDATE                                                  --등록일시
          ,REGID                                                    --등록자ID
          ,UPDDATE                                                  --수정일시
          ,UPDID                                                    --수정자ID
          ,USE_YN                                                   --사용여부(Y:사용 N:미사용)
      )
      SELECT
           V_WO_NO     														--작업지시번호
          ,1                                      --작업지시순번
          ,SUBSTR(V_WO_NO,-4)                     --작업순서(작업지시번호,-4)
          ,TO_CHAR(sysdate,'YYYYMMDD')            --지시생성일자

          ,AUFNR																	--오더번호
          ,FRAUFNR                           			--이전 오더 번호
          ,WERKS                          				--플랜트코드
          ,ORDER_NUM                      				--생산지시 No
          ,ORDER_SEQ                      				--생산지시 seq
          ,BUDAT                          				--생산요청일자
          ,AUART                          				--오더유형
          ,AUARTXT                        				--오더유형 텍스트
          ,MMATNR                         				--자재 코드
          ,MACHINE                        				--생산호기
          ,MACHINETXT                     				--생산 호기명
          ,TOMACHINE                      				--TO 생산호기
          ,TOMACHINETXT                   				--TO 생산 호기명
          ,MATNR                          				--점보롤 자재 코드
          ,PCODE                          				--지종코드
          ,WEIGHT                         				--평량
          ,MWIDTH                         				--M/R 지폭
          ,MWIDTH_INPUT                   				--M/R 지폭_INPUT
          ,MWIDTH_SLITER                  				--M/R 지폭_SLITER
          ,MROLLCNT                       				--M/R 권치수
          ,MRCNT                          				--M/R 폭수
          ,MBRGEW                         				--M/R 중량
          ,MGEWEI                         				--단위
          ,JRCNT                          				--J/R 개수
          ,OVBELN                         				--판매문서
          ,OPOSNR                         				--판매문서 항목번호
          ,OAUART                         				--판매문서 유형
          ,OAUARTXT                       				--판매 문서 오더 유형 텍스트
          ,VBELN                          				--판매문서
          ,POSNR                          				--판매문서 항목번호
          ,VDATU                          				--납품 요청일자
          ,SAUART                         				--판매문서 유형
          ,SAUARTXT                       				--판매 문서 오더 유형 텍스트
          ,REMARK                         				--비고
          ,SHEET                          				--판지 구분자
          ,SLITER_SET                     				--슬리터 구분
          ,MRLDCK                         				--밀롤 창고 적치 여부
          ,CUTTER                         				--카터
          ,STLNR                          				--대체Bom
          ,STLAL                          				--BOM Num
          ,BMENG                          				--모품목기준수량
          ,BMEIN                          				--모품목기준수량 단위
          ,DLFL                           				--오더 삭제 지시자
          ,ROUTE                                  --항차
          ,KUNNR                                  --판매처
          ,NAME1                                  --판매처명
          ,SLITER			 					                  --슬리터구분
          ,MBRGEW               									--M/R 중량
          , ZSIZE         							                --지관사이즈(인치)
          , ZCAP         							                --지관마개여부
          , ZBOX         							                --골판지여부
          , ZPACK         							                --포장여부

          ,'N'                                     --완료여부
          ,sysdate                                --등록일시
          ,'sp_ifr019'                                --등록자ID
          ,null                                   --수정일시
          ,null                                   --수정자ID
          ,case when DLFL = 'X' then 'N'
                else 'Y'
           end                                    --사용여부(Y:사용 N:미사용)
      FROM  TB_IFR019
      WHERE  IF_IFR_NO = i_IF_IFR_NO;
    END IF;


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



    o_msg_MSG  :=  'TB_IFR019, 생산오더-밀롤,슬리터가 수신되었습니다.1'; -- || ',' || SQLERRM ;

    UPDATE  TB_IFR019
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    AUFNR     =  i_AUFNR
    AND    IF_IFR_NO =  i_IF_IFR_NO
    ;

    o_msg_MSG  :=  'TB_IFR019, 생산오더-밀롤,슬리터가 수신되었습니다.2'; -- || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
                o_msg_MSG  :=  'TB_IFR019, 생산오더-밀롤,슬리터 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                o_msg_code      := '-1' ;
                DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                ROLLBACK;

                UPDATE  TB_IFR019
                SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                      , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                      , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
                WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
                AND    AUFNR     =  i_AUFNR
                AND    IF_IFR_NO =  i_IF_IFR_NO
                ;

END  sp_ifr019 ;
/* ------- TB_IFR019 : 생산오더-밀롤,슬리터  End --------------------------- */


/* ------- TB_IFR020 : 생산오더-재단공정  Begin ------------------------->22-08-31 재단출고여부'X'일때 WCS로 넘기는 S/P통합함. */
PROCEDURE sp_ifr020 (  i_IF_IFR_NO      IN   NUMBER   /* MES Interface Sequence(수신번호)        */
                      ,i_AUFNR          IN   VARCHAR2
                      ,i_ZCOR           IN   VARCHAR2
                      ,o_msg_CODE       OUT  VARCHAR2
                      ,o_msg_MSG        OUT  VARCHAR2  ) is

  V_CNT           NUMBER          := 0;      -- 카운트(작업지시존재여부)
  V_EXIST_CNT     NUMBER          := 0;      -- 카운트(작업지시존재여부(미사용여부확인용))
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
    FROM TB_IFR020
    WHERE AUFNR = i_AUFNR
    AND IF_IFR_NO = i_IF_IFR_NO;

    IF V_DLFL = 'X' THEN
      UPDATE TB_SCH008
         SET DLFL = V_DLFL
           , UPDDATE = SYSDATE
           , UPDID = 'sp_IFR020'
       WHERE AUFNR =  i_AUFNR;

      UPDATE TB_SCH017
         SET USE_YN = 'N'
           , UPDDATE = SYSDATE
           , UPDID = 'sp_IFR020'
       WHERE ORDER_NO =  i_AUFNR;

      o_msg_MSG  :=  'TB_IFR020, 생산오더-재단 삭제 수신되었습니다.1'; -- || ',' || SQLERRM ;

      UPDATE  TB_IFR020
      SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
            , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
            , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
      WHERE  AUFNR     =  i_AUFNR
      AND    IF_IFR_NO =  i_IF_IFR_NO
      ;

      o_msg_MSG  :=  'TB_IFR020, 생산오더-재단 삭제 수신되었습니다.2'; -- || ',' || SQLERRM ;
      o_msg_code := '0' ;
      RETURN;
    END IF;

    --재단출고여부 'X'이면 WCS로 I/F 한다.(sp_ifr020_X 분리된것을 여기에 통합함) 22-08-31

    ----당분간 보류해서 진행한다. 해제해야 함.
    IF i_ZCOR = 'X' THEN
      V_DOC_NO := FN_GET_MDOCNO('M','IFWC006');

      SELECT NVL(FRAUFNR,'@') INTO V_FRAUFNR
      FROM TB_IFR020
      WHERE IF_IFR_NO =  i_IF_IFR_NO;

      IF  V_FRAUFNR = '@' THEN
          o_msg_MSG  :=  'TB_IFR020, 이전오더번호가 없습니다.';
          o_msg_code := '-1' ;
          DBMS_OUTPUT.PUT_LINE (o_msg_msg );
          ROLLBACK;

          UPDATE  TB_IFR020
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

          UPDATE  TB_IFR020
          SET     IF_STATUS   =  'E'                -- I/F상태, N:신규, S:성공, E:오류
                , IF_SET_DATE =  sysdate            --  데이터 처리시간(MES I/F 테이블 → MES 운영테이블)
                , IF_ERR_MESS =  o_msg_MSG          --  데이터 처리 결과 Message(Oracle)
          WHERE  IF_IFR_NO =  i_IF_IFR_NO;

          RETURN;
      END IF;

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
        ,REMARK7                   --포장타입(PACKTYPE)
        ,REMARK8                   --폭수
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

        ,REMARK3                   --A.PCODE AS "지종"
        ,REMARK4                  --A.WEIGHT AS "평량"
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
        ,PACKTYPE                  --비고7-포장타입
        ,CTCNT                     --비고8폭수
        --,KUNNR                     --비고1
        ,LPAD(KUNNR, 10, '0')      --비고1(10자리)
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
        ,PCODE                   --REMARK9 지종
        ,WEIGHT                  --REMARK10 평량
      FROM TB_IFR020
      WHERE IF_IFR_NO =  i_IF_IFR_NO;
    END IF;



  -----------------------------------------------------------------------------------------------------------------------------
  --생산오더
  -----------------------------------------------------------------------------------------------------------------------------
    SELECT COUNT(1) INTO V_CNT FROM TB_SCH008 WHERE AUFNR = i_AUFNR;

    IF V_CNT > 0 THEN
      UPDATE TB_SCH008
      SET(
            MRPO	         																		--MRPO	,		밀롤 오더 번호
          ,	WERKS	         																		--WERKS	,		플랜트
          ,	BUDAT	         																		--BUDAT	,		시작일자
          ,	AUART	         																		--AUART	,		오더유형
          ,	AUARTXT	       																		--AUARTXT	,		오더유형 텍스트
          ,	MACHINE	       																		--MACHINE	,		FROM 생산호기
          ,	MACHINETXT	   																		--MACHINETXT	,		FROM 생산 호기명
          ,	TOMACHINE	     																		--TOMACHINE	,		TO 생산호기
          ,	TOMACHINETXT	 																		--TOMACHINETXT	,		TO 생산 호기명
          ,	CMATNR	       																		--CMATNR	,		재단 자재 코드
          ,	PCODE	         																		--PCODE	,		지종
          ,	WEIGHT	       																		--WEIGHT	,		평량
          ,	WLEN	         																		--WLEN	,		가로길
          ,	VLEN	         																		--VLEN	,		세로길
          ,	CTCNT	         																		--CTCNT	,		폭수
          ,	CNT	           																		--CNT	,		수량
          ,	CGEWEW	       																		--CGEWEW	,		총중량
          ,	CGEWEI	       																		--CGEWEI	,		단위
          ,	ZZATT1	       																		--ZZATT1	,		팔레트당연수
          ,	ZZATT2	       																		--ZZATT2	,		속당매수
          ,	DOUBLEFLAG	   																		--DOUBLEFLAG	,		쌍팔레트
          ,	VBELN	         																		--VBELN	,		판매문서
          ,	POSNR	         																		--POSNR	,		판매문서 항목번호
          ,	SAUART	       																		--SAUART	,		판매문서 유형
          ,	SAUARTXT	     																		--SAUARTXT	,		판매 문서 오더 유형 텍스트
          ,	OVBELN	       																		--OVBELN	,		판매문서
          ,	OPOSNR	       																		--OPOSNR	,		판매문서 항목번호
          ,	OAUART	       																		--OAUART	,		판매문서 유형
          ,	OAUARTXT	     																		--OAUARTXT	,		판매 문서 오더 유형 텍스트
          ,	CUTTER	       																		--CUTTER	,		카터
          ,	STLNR	         																		--STLNR	,		BOM Num
          ,	STLAL	         																		--STLAL	,		대체Bom
          ,	BMENG	         																		--BMENG	,		모품목기준수량
          ,	BMEIN	         																		--BMEIN	,		모품목기준수량 단위
          ,	DLFL	         																		--DLFL	,		오더 삭제 지시자
          ,	ROUTE	         																		--ROUTE	,		항차
          , ZCOR           																		--재단출고오더여부
          , ORDER_RMK      																		--비고
          , KUNNR          																		--판매처
          , KUNNRT         																		--판매처명
          , FRAUFNR        																		--이전오더
          , MWIDTH_INPUT   																		--M/R 지폭
          , MRCNT          																		--폭수
          , MCNT           																		--수량
          , SCNT           																		--수량
          , CONTYPE        																		--컨테이너유형
          , SIZE_VAL       																		--규격

          , UPDDATE        																		--수정일자
          , UPDID          																		--수정자
      )=(SELECT
           MRPO		              															--MRPO	,		밀롤 오더 번호
          ,WERKS		                                          --WERKS	,		플랜트
          ,BUDAT		                                          --BUDAT	,		시작일자
          ,AUART		                                          --AUART	,		오더유형
          ,AUARTXT		                                        --AUARTXT	,		오더유형 텍스트
          ,MACHINE		                                        --MACHINE	,		FROM 생산호기
          ,MACHINETXT		                                      --MACHINETXT	,		FROM 생산 호기명
          ,TOMACHINE		                                      --TOMACHINE	,		TO 생산호기
          ,TOMACHINETXT		                                    --TOMACHINETXT	,		TO 생산 호기명
          ,CMATNR		                                          --CMATNR	,		재단 자재 코드
          ,PCODE		                                          --PCODE	,		지종
          ,WEIGHT		                                          --WEIGHT	,		평량
          ,WLEN		                                            --WLEN	,		가로길
          ,VLEN		                                            --VLEN	,		세로길
          ,CTCNT		                                          --CTCNT	,		폭수
          ,CNT		                                            --CNT	,		수량
          ,CGEWEW		                                          --CGEWEW	,		총중량
          ,CGEWEI		                                          --CGEWEI	,		단위
          ,ZZATT1		                                          --ZZATT1	,		팔레트당연수
          ,ZZATT2		                                          --ZZATT2	,		속당매수
          ,DOUBLEFLAG		                                      --DOUBLEFLAG	,		쌍팔레트
          ,VBELN		                                          --VBELN	,		판매문서
          ,POSNR		                                          --POSNR	,		판매문서 항목번호
          ,SAUART		                                          --SAUART	,		판매문서 유형
          ,SAUARTXT		                                        --SAUARTXT	,		판매 문서 오더 유형 텍스트
          ,OVBELN		                                          --OVBELN	,		판매문서
          ,OPOSNR		                                          --OPOSNR	,		판매문서 항목번호
          ,OAUART		                                          --OAUART	,		판매문서 유형
          ,OAUARTXT		                                        --OAUARTXT	,		판매 문서 오더 유형 텍스트
          ,CUTTER		                                          --CUTTER	,		카터
          ,STLNR		                                          --STLNR	,		BOM Num
          ,STLAL		                                          --STLAL	,		대체Bom
          ,BMENG		                                          --BMENG	,		모품목기준수량
          ,BMEIN		                                          --BMEIN	,		모품목기준수량 단위
          ,DLFL		                                            --DLFL	,		오더 삭제 지시자
          ,ROUTE		                                          --ROUTE	,		항차
          ,ZCOR                                               --재단출고오더여부
          ,REMARK                                                                                         --비고
          ,KUNNR                                              --판매처
          ,NAME1                                              --판매처명
          ,FRAUFNR                                            --이전오더
          ,MWIDTH_INPUT                                       --M/R 지폭
          ,MRCNT                                              --폭수
          ,MCNT                                               --수량
          ,SCNT                                               --수량
          ,CONTYPE                                            --컨테이너유형
          ,SIZE_VAL                                           --규격

          ,sysdate                      										  --  수정일자
          ,'SP_SCH_GET_IFR_CA'             										      --  수정자
         FROM TB_IFR020
         WHERE  IF_IFR_NO = i_IF_IFR_NO
      )
      WHERE  AUFNR   = i_AUFNR;
    ELSE
      INSERT INTO TB_SCH008(
				 AUFNR			              													--AUFNR	,		오더번호
				,MRPO			                													--MRPO	,		밀롤 오더 번호
				,WERKS			              													--WERKS	,		플랜트
				,BUDAT			              													--BUDAT	,		시작일자
				,AUART			              													--AUART	,		오더유형
				,AUARTXT			            													--AUARTXT	,		오더유형 텍스트
				,MACHINE			            													--MACHINE	,		FROM 생산호기
				,MACHINETXT			          													--MACHINETXT	,		FROM 생산 호기명
				,TOMACHINE			          													--TOMACHINE	,		TO 생산호기
				,TOMACHINETXT			        													--TOMACHINETXT	,		TO 생산 호기명
				,CMATNR			              													--CMATNR	,		재단 자재 코드
				,PCODE			              													--PCODE	,		지종
				,WEIGHT			              													--WEIGHT	,		평량
				,WLEN			                													--WLEN	,		가로길
				,VLEN			                													--VLEN	,		세로길
				,CTCNT			              													--CTCNT	,		폭수
				,CNT			                													--CNT	,		수량
				,CGEWEW			              													--CGEWEW	,		총중량
				,CGEWEI			              													--CGEWEI	,		단위
				,ZZATT1			              													--ZZATT1	,		팔레트당연수
				,ZZATT2			              													--ZZATT2	,		속당매수
				,DOUBLEFLAG			          													--DOUBLEFLAG	,		쌍팔레트
				,VBELN			              													--VBELN	,		판매문서
				,POSNR			              													--POSNR	,		판매문서 항목번호
				,SAUART			              													--SAUART	,		판매문서 유형
				,SAUARTXT			            													--SAUARTXT	,		판매 문서 오더 유형 텍스트
				,OVBELN			              													--OVBELN	,		판매문서
				,OPOSNR			              													--OPOSNR	,		판매문서 항목번호
				,OAUART			              													--OAUART	,		판매문서 유형
				,OAUARTXT			            													--OAUARTXT	,		판매 문서 오더 유형 텍스트
				,CUTTER			              													--CUTTER	,		카터
				,STLNR			              													--STLNR	,		BOM Num
				,STLAL			              													--STLAL	,		대체Bom
				,BMENG			              													--BMENG	,		모품목기준수량
				,BMEIN			              													--BMEIN	,		모품목기준수량 단위
				,DLFL			                													--DLFL	,		오더 삭제 지시자
				,ROUTE			              													--ROUTE	,		항차
				,ZCOR                     													--재단출고오더여부
				,ORDER_RMK                													--비고
				,KUNNR                    													--판매처
				,KUNNRT                   													--판매처명
				,MAUFNR																							--M/R LOT Number
				,PTIM                     													--생산 계획 시간 (HHMM)
				,PSEQ                     													--IS-M: Production Sequence
				,WORKGROUP                													--반
				,MMATNR                   													--자재 번호
				,MROLLCNT                 													--M/R 권치수
				,MBRGEW                   													--M/ROLL 중량
				,MGEWEI                   													--중량 단위
				,CORESIZE                 													--밀롤 지관 인치(SIZE)
				,PACKTYPE                 													--포장타입
				,FRAUFNR                  													--이전오더
				,MWIDTH_INPUT             													--M/R 지폭
				,MRCNT                    													--폭수
				,MCNT                     													--수량
				,SCNT                     													--수량
				,CONTYPE                  													--컨테이너유형
				,SIZE_VAL                 													--규격

				,REGDATE							    													--등록일자
				,REGID							      													--등록자
				,UPDDATE							    													--수정일자
				,UPDID							      													--수정자
      )
      SELECT
         AUFNR			                											--AUFNR	,		오더번호
        ,MRPO			                  											--MRPO	,		밀롤 오더 번호
        ,WERKS			                											--WERKS	,		플랜트
        ,BUDAT			                											--BUDAT	,		시작일자
        ,AUART			                											--AUART	,		오더유형
        ,AUARTXT			              											--AUARTXT	,		오더유형 텍스트
        ,MACHINE			              											--MACHINE	,		FROM 생산호기
        ,MACHINETXT			            											--MACHINETXT	,		FROM 생산 호기명
        ,TOMACHINE			            											--TOMACHINE	,		TO 생산호기
        ,TOMACHINETXT			          											--TOMACHINETXT	,		TO 생산 호기명
        ,CMATNR			                											--CMATNR	,		재단 자재 코드
        ,PCODE			                											--PCODE	,		지종
        ,WEIGHT			                											--WEIGHT	,		평량
        ,WLEN			                  											--WLEN	,		가로길
        ,VLEN			                  											--VLEN	,		세로길
        ,CTCNT			                											--CTCNT	,		폭수
        ,CNT			                  											--CNT	,		수량
        ,CGEWEW			                											--CGEWEW	,		총중량
        ,CGEWEI			                											--CGEWEI	,		단위
        ,ZZATT1			                											--ZZATT1	,		팔레트당연수
        ,ZZATT2			                											--ZZATT2	,		속당매수
        ,DOUBLEFLAG			            											--DOUBLEFLAG	,		쌍팔레트
        ,VBELN			                											--VBELN	,		판매문서
        ,POSNR			                											--POSNR	,		판매문서 항목번호
        ,SAUART			                											--SAUART	,		판매문서 유형
        ,SAUARTXT			              											--SAUARTXT	,		판매 문서 오더 유형 텍스트
        ,OVBELN			                											--OVBELN	,		판매문서
        ,OPOSNR			                											--OPOSNR	,		판매문서 항목번호
        ,OAUART			                											--OAUART	,		판매문서 유형
        ,OAUARTXT			              											--OAUARTXT	,		판매 문서 오더 유형 텍스트
        ,CUTTER			                											--CUTTER	,		카터
        ,STLNR			                											--STLNR	,		BOM Num
        ,STLAL			                											--STLAL	,		대체Bom
        ,BMENG			                											--BMENG	,		모품목기준수량
        ,BMEIN			                											--BMEIN	,		모품목기준수량 단위
        ,DLFL			                  											--DLFL	,		오더 삭제 지시자
        ,ROUTE			                											--ROUTE	,		항차
        ,ZCOR                       											--재단출고오더여부
        ,REMARK                     											                        --비고
        ,KUNNR                      											--판매처
        ,NAME1                      											--판매처명
        ,MAUFNR																						--M/R LOT Number
        ,PTIM                       											--생산 계획 시간 (HHMM)
        ,PSEQ                       											--IS-M: Production Sequence
        ,WORKGROUP                  											--반
        ,MMATNR                     											--자재 번호
        ,MROLLCNT                   											--M/R 권치수
        ,MBRGEW                     											--M/ROLL 중량
        ,MGEWEI                     											--중량 단위
        ,CORESIZE                   											--밀롤 지관 인치(SIZE)
        ,PACKTYPE                   											--포장타입
        ,FRAUFNR                    											--이전오더
        ,MWIDTH_INPUT               											--M/R 지폭
        ,MRCNT                      											--폭수
        ,MCNT                       											--수량
        ,SCNT                       											--수량
        ,CONTYPE                    											--컨테이너유형
        ,SIZE_VAL                   											--규격

        ,sysdate                    											--등록일자
        ,'SP_SCH_GET_IFR_CA'                										--등록자
        , null                      											--수정일자
        , null                      											--수정자
      FROM  TB_IFR020
      WHERE  IF_IFR_NO = i_IF_IFR_NO;
    END IF;


    --========================================
    --KHJ추가 2022-05-02:작업지시-재단
    --========================================
    ------------------------------------------
    --작업지시가 존재하지 않으면 작업지시 번호 생성
    SELECT COUNT(ORDER_NO) INTO V_CNT
    FROM TB_SCH017
    WHERE ORDER_NO = i_AUFNR
    AND NVL(MAN_CUT_YN,'N') <> 'X';

    IF V_CNT = 0 THEN
      SELECT BUDAT INTO V_WO_DT
      FROM TB_IFR020
      WHERE IF_IFR_NO  =  i_IF_IFR_NO;

      SP_GET_DOC_SEQ('WOCA',V_WO_DT,V_WO_NO);
    END IF;
    ------------------------------------------

    IF V_CNT > 0 THEN
      UPDATE TB_SCH017
      SET(
            PRE_ORDER_NO         																--이전 오더 번호
           ,WERKS                																--플랜트코드
           ,PRD_REQ_DT           																--생산요청일자
           ,ORDER_DIV            																--오더유형
           ,ORDER_DIV_NM         																--오더유형 텍스트
           ,MACHINE              																--FROM 생산호기
           ,MACHINE_NM           																--FROM 생산 호기명
           ,TO_MACHINE           																--TO 생산호기
           ,TO_MACHINE_NM        																--TO 생산 호기명
           ,MATNR                																--자재 코드
           ,PCODE                																--지종
           ,BS_WGT               																--평량
           ,VLEN                 																--세로길
           ,WLEN                 																--가로길
           ,PKCNT                																--폭수
           ,WRK_ORDR_QTY         																--생산지시량
           ,TOT_WGT              																--총중량
           ,UNIT                 																--단위
           ,PLT_PER_CNT          																--팔레트당연수
           ,IN_PER_CNT           																--속당매수
           ,DBL_FLAG             																--쌍팔레트
           ,VBELN                																--판매문서
           ,POSNR                																--판매문서 항목번호
           ,SAUART_DIV           																--판매문서 유형
           ,SAUART_NM            																--판매 문서 오더 유형 텍스트
           ,OVBELN               																--판매문서
           ,OPOSNR               																--판매문서 항목번호
           ,OAUART_DIV           																--판매문서 유형
           ,OAUART_NM            																--판매 문서 오더 유형 텍스트
           ,CUTTER               																--카터
           ,BOM_NO               																--BOM Num
           ,ATN_BOM_NO           																--대체Bom
           ,PRT_MATNR_QTY        																--모품목기준수량
           ,PRT_MATNR_UNIT       																--모품목기준수량 단위
           ,DLFL                 																--오더 삭제 지시자
           ,ZCOR                 																--재단출고 오더 여부
           ,ORDER_RMK            																--비고
           ,ROUTE                																--항차
           ,KUNNR                																--판매처
           ,KUNNRT               																--판매처명
           ,MAUFNR				  		 																--M/R LOT Number
           ,PTIM                 																--생산 계획 시간 (HHMM)
           ,PSEQ                 																--IS-M: Production Sequence
           ,WORKGROUP            																--반
           ,MMATNR               																--자재 번호
           ,MROLLCNT             																--M/R 권치수
           ,MBRGEW               																--M/ROLL 중량
           ,MGEWEI               																--중량 단위
           ,CORESIZE             																--밀롤 지관 인치(SIZE)
           ,PACKTYPE             																--포장타입
           ,MWIDTH_INPUT         																--M/R 지폭
           ,MRCNT                																--폭수
           ,MCNT                 																--수량
           ,SCNT                 																--수량
           ,CONTYPE              																--컨테이너유형
           ,SIZE_VAL             																--규격
           ,UPDDATE              																--수정일시
           ,UPDID                																--수정자ID
           ,USE_YN               																--사용여부(Y:사용 N:미사용)
      )=(SELECT
            FRAUFNR                        											--이전 오더 번호
           ,WERKS                          											--플랜트코드
           ,BUDAT                          											--생산요청일자
           ,AUART                          											--오더유형
           ,AUARTXT                        											--오더유형 텍스트
           ,MACHINE                        											--FROM 생산호기
           ,MACHINETXT                     											--FROM 생산 호기명
           ,TOMACHINE                      											--TO 생산호기
           ,TOMACHINETXT                   											--TO 생산 호기명
           ,CMATNR                         											--자재 코드
           ,PCODE                          											--지종
           ,WEIGHT                         											--평량
           ,VLEN                           											--세로길
           ,WLEN                           											--가로길
           ,CTCNT                          											--폭수
           ,CNT                            											--생산지시량
           ,CGEWEW                         											--총중량
           ,CGEWEI                         											--단위
           ,ZZATT1                         											--팔레트당연수
           ,ZZATT2                         											--속당매수
           ,DOUBLEFLAG                     											--쌍팔레트
           ,VBELN                          											--판매문서
           ,POSNR                          											--판매문서 항목번호
           ,SAUART                         											--판매문서 유형
           ,SAUARTXT                       											--판매 문서 오더 유형 텍스트
           ,OVBELN                         											--판매문서
           ,OPOSNR                         											--판매문서 항목번호
           ,OAUART                         											--판매문서 유형
           ,OAUARTXT                       											--판매 문서 오더 유형 텍스트
           ,CUTTER                         											--카터
           ,STLNR                          											--BOM Num
           ,STLAL                          											--대체Bom
           ,BMENG                          											--모품목기준수량
           ,BMEIN                          											--모품목기준수량 단위
           ,DLFL                           											--오더 삭제 지시자
           ,ZCOR                           											--재단출고 오더 여부
           ,REMARK                         											                        --비고
           ,ROUTE                          											--항차
           ,KUNNR                          											--판매처
           ,NAME1                          											--판매처명
           ,MAUFNR     					  															--M/R LOT Number
           ,PTIM                           											--생산 계획 시간 (HHMM)
           ,PSEQ                           											--IS-M: Production Sequence
           ,WORKGROUP                      											--반
           ,MMATNR                         											--자재 번호
           ,MROLLCNT                       											--M/R 권치수
           ,MBRGEW                         											--M/ROLL 중량
           ,MGEWEI                         											--중량 단위
           ,CORESIZE                       											--밀롤 지관 인치(SIZE)
           ,PACKTYPE                       											--포장타입
           ,MWIDTH_INPUT                   											--M/R 지폭
           ,MRCNT                          											--폭수
           ,MCNT                           											--수량
           ,SCNT                           											--수량
           ,CONTYPE                        											--컨테이너유형
           ,SIZE_VAL                       											--규격
           ,sysdate                               							--수정일시
           ,'SP_SCH_GET_IFR_CA'                           						--수정자ID
           ,case when DLFL = 'X' then 'N'
                 when DLFL = 'N' then 'Y'
            end                                  								--사용여부(Y:사용 N:미사용)
         FROM TB_IFR020
         WHERE  IF_IFR_NO = i_IF_IFR_NO
      )
      WHERE ORDER_NO = i_AUFNR
        AND NVL(MAN_CUT_YN,'N') <> 'X';
    ELSE
        /*20260827 KJE start*/
        SELECT COUNT(*)
        INTO V_EXIST_CNT
        FROM TB_SCH017
        WHERE PRE_ORDER_NO = (SELECT FRAUFNR
                              FROM TB_IFR020
                              WHERE DLFL != 'X'
                                and IF_IFR_NO = i_IF_IFR_NO);

        IF V_EXIST_CNT > 0 THEN
            UPDATE TB_SCH017
            SET USE_YN = 'N'
            WHERE PRE_ORDER_NO IN (
                SELECT FRAUFNR
                FROM TB_IFR020
                WHERE DLFL != 'X'
                  AND IF_IFR_NO = i_IF_IFR_NO);
        end if;
        /*20260827 KJE end*/

      INSERT INTO TB_SCH017(
           WRK_ORDR_NO                              					--작업지시번호-->작업지시 생성자 사용 WO + R
          ,WRK_ORDR_SEQNO                           					--작업지시순번
          ,WRK_SEQNO                                					--작업순서
          ,ORDR_GEN_DT                              					--지시생성일자
          ,ORDER_NO																					  --오더번호
          ,PRE_ORDER_NO          														--이전 오더 번호
          ,WERKS                 														--플랜트코드
          ,PRD_REQ_DT            														--생산요청일자
          ,ORDER_DIV             														--오더유형
          ,ORDER_DIV_NM          														--오더유형 텍스트
          ,MACHINE               														--FROM 생산호기
          ,MACHINE_NM            														--FROM 생산 호기명
          ,TO_MACHINE            														--TO 생산호기
          ,TO_MACHINE_NM         														--TO 생산 호기명
          ,MATNR                 														--자재 코드
          ,PCODE                 														--지종
          ,BS_WGT                														--평량
          ,VLEN                  														--세로길
          ,WLEN                  														--가로길
          ,PKCNT                 														--폭수
          ,WRK_ORDR_QTY          														--생산지시량
          ,TOT_WGT               														--총중량
          ,UNIT                  														--단위
          ,PLT_PER_CNT           														--팔레트당연수
          ,IN_PER_CNT            														--속당매수
          ,DBL_FLAG              														--쌍팔레트
          ,VBELN                 														--판매문서
          ,POSNR                 														--판매문서 항목번호
          ,SAUART_DIV            														--판매문서 유형
          ,SAUART_NM             														--판매 문서 오더 유형 텍스트
          ,OVBELN                														--판매문서
          ,OPOSNR                														--판매문서 항목번호
          ,OAUART_DIV            														--판매문서 유형
          ,OAUART_NM             														--판매 문서 오더 유형 텍스트
          ,CUTTER                														--카터
          ,BOM_NO                														--BOM Num
          ,ATN_BOM_NO            														--대체Bom
          ,PRT_MATNR_QTY         														--모품목기준수량
          ,PRT_MATNR_UNIT        														--모품목기준수량 단위
          ,DLFL                  														--오더 삭제 지시자
          ,ZCOR                  														--재단출고 오더 여부
          ,ORDER_RMK                                					--비고
          ,ROUTE                                    					--항차
          ,KUNNR                                    					--판매처
          ,KUNNRT                                   					--판매처명
          ,MAUFNR								  													--M/R LOT Numb
          ,PTIM                                     					--생산 계획 시간
          ,PSEQ                                     					--IS-M: Produc
          ,WORKGROUP                                					--반
          ,MMATNR                                   					--자재 번호
          ,MROLLCNT                                 					--M/R 권치수
          ,MBRGEW                                   					--M/ROLL 중량
          ,MGEWEI                                   					--중량 단위
          ,CORESIZE                                 					--밀롤 지관 인치(
          ,PACKTYPE                                 					--포장타입
          ,MAN_CUT_YN                               					--수재단여부(6/14 무조건 N으로 처리함)
          ,MWIDTH_INPUT                             					--M/R 지폭
          ,MRCNT                                    					--폭수
          ,MCNT                                     					--수량
          ,SCNT                                     					--수량
          ,CONTYPE                                  					--컨테이너유형
          ,SIZE_VAL                                 					--규격
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
          ,FRAUFNR                         										--이전 오더 번호
          ,WERKS                          											--플랜트코드
          ,BUDAT                          											--생산요청일자
          ,AUART                          											--오더유형
          ,AUARTXT                        											--오더유형 텍스트
          ,MACHINE                        											--FROM 생산호기
          ,MACHINETXT                     											--FROM 생산 호기명
          ,TOMACHINE                      											--TO 생산호기
          ,TOMACHINETXT                   											--TO 생산 호기명
          ,CMATNR                         											--자재 코드
          ,PCODE                          											--지종
          ,WEIGHT                         											--평량
          ,VLEN                           											--세로길
          ,WLEN                           											--가로길
          ,CTCNT                          											--폭수
          ,CNT                            											--생산지시량
          ,CGEWEW                         											--총중량
          ,CGEWEI                         											--단위
          ,ZZATT1                         											--팔레트당연수
          ,ZZATT2                         											--속당매수
          ,DOUBLEFLAG                     											--쌍팔레트
          ,VBELN                          											--판매문서
          ,POSNR                          											--판매문서 항목번호
          ,SAUART                         											--판매문서 유형
          ,SAUARTXT                       											--판매 문서 오더 유형 텍스트
          ,OVBELN                         											--판매문서
          ,OPOSNR                         											--판매문서 항목번호
          ,OAUART                         											--판매문서 유형
          ,OAUARTXT                       											--판매 문서 오더 유형 텍스트
          ,CUTTER                         											--카터
          ,STLNR                          											--BOM Num
          ,STLAL                          											--대체Bom
          ,BMENG                          											--모품목기준수량
          ,BMEIN                          											--모품목기준수량 단위
          ,DLFL                           											--오더 삭제 지시자
          ,ZCOR                           											--재단출고 오더 여부
          ,REMARK                                       				                                        --오더비고
          ,ROUTE                                        				--항차
          ,KUNNR                                        				--판매처
          ,NAME1                                        				--판매처명
          ,MAUFNR     																					--M/R LOT Number
          ,PTIM                           											--생산 계획 시간 (HHMM)
          ,PSEQ                           											--IS-M: Production Sequence
          ,WORKGROUP                      											--반
          ,MMATNR                         											--자재 번호
          ,MROLLCNT                       											--M/R 권치수
          ,MBRGEW                         											--M/ROLL 중량
          ,MGEWEI                         											--중량 단위
          ,CORESIZE                       											--밀롤 지관 인치(SIZE)
          ,PACKTYPE                       											--포장타입
          ,''                                                       --수재단여부(6/14 무조건 N으로 처리함)
          ,MWIDTH_INPUT                                				--M/R 지폭
          ,MRCNT                                       				--폭수
          ,MCNT                                        				--수량
          ,SCNT                                        				--수량
          ,CONTYPE                                     				--컨테이너유형
          ,SIZE_VAL                                    				--규격
          ,'N'                                                 --완료여부
          ,sysdate                                             --등록일시
          ,'SP_SCH_GET_IFR_CA'                                         --등록자ID
          ,null                                                --수정일시
          ,null                                                --수정자ID
          ,case when DLFL = 'X' then 'N'
               else 'Y'
          end                                                 --사용여부(Y:사용 N:미사용)
      FROM  TB_IFR020
      WHERE  IF_IFR_NO = i_IF_IFR_NO;
    END IF;


    --작업지시 생성되면 작업지시BOM을 구성한다.
    --작업지시정보 추출
    SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, WERKS INTO V_WO_NO,V_WO_SEQ,V_WERKS
    FROM TB_SCH017
    WHERE ORDER_NO = i_AUFNR
    AND NVL(MAN_CUT_YN,'N') <> 'X';

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

DBMS_OUTPUT.PUT_LINE('AAAA' );


    o_msg_MSG  :=  'TB_IFR020, 생산오더-재단가 수신되었습니다.1'; -- || ',' || SQLERRM ;

DBMS_OUTPUT.PUT_LINE('BBB' );
    UPDATE  TB_IFR020
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    AUFNR     =  i_AUFNR
    AND    IF_IFR_NO =  i_IF_IFR_NO
    ;
DBMS_OUTPUT.PUT_LINE('CCC' );
    o_msg_MSG  :=  'TB_IFR020, 생산오더-재단가 수신되었습니다.2'; -- || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
                o_msg_MSG  :=  'TB_IFR020, 생산오더-재단 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                o_msg_code      := '-1' ;
                DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                ROLLBACK;

                UPDATE  TB_IFR020
                SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                      , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                      , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
                WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
                AND    AUFNR     =  i_AUFNR
                AND    IF_IFR_NO =  i_IF_IFR_NO
                ;

END  sp_ifr020 ;
/* ------- TB_IFR020 : 생산오더-재단  End --------------------------- */


/* ------- TB_IFSWC006 : 생산오더-재단공정(22-08-31 사용안함. sp_ifr020내로 삽입됨).*/
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
			,REMARK7                   --포장타입(PACKTYPE)
			,REMARK8                   --폭수
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
			,REMARK3                   --A.PCODE AS "지종"
            ,REMARK4                  --A.WEIGHT AS "평량"
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
			,PACKTYPE                --포장타입(PACKTYPE)
			,CTCNT                   --폭수
			--,KUNNR                     --비고1
			,LPAD(KUNNR, 10, '0')      --비고1(10자리)
			,NAME1                     --비고2
			--,MAUFNR                  --MR LOTID  ---100
			,MRLOT                     --MR LOTID  ---20221011 WSW UPDATE
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
			,K.PCODE                   --REMARK9 지종
            ,K.WEIGHT                  --REMARK10 평량
    FROM TB_IFR020 K
    WHERE IF_IFR_NO =  i_IF_IFR_NO
    ;
DBMS_OUTPUT.PUT_LINE('FFF' );
    o_msg_MSG  :=  'TB_IFSWC006, 생산오더-재단=>WCS가 수신되었습니다.1'; -- || ',' || SQLERRM ;

    UPDATE  TB_IFR020
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    AUFNR     =  i_AUFNR
    AND    IF_IFR_NO =  i_IF_IFR_NO
    ;

    o_msg_MSG  :=  'TB_IFSWC006, 생산오더-재단=>WCS가 수신되었습니다.2'; -- || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
                o_msg_MSG  :=  'TB_IFSWC006, 생산오더-재단=>WCS 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                o_msg_code      := '-1' ;
                DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                ROLLBACK;

                UPDATE  TB_IFR020
                SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                      , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                      , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
                WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
                AND    AUFNR     =  i_AUFNR
                AND    IF_IFR_NO =  i_IF_IFR_NO
                ;

END  sp_ifr020_X ;
/* ------- TB_IFSWC006 : 생산오더-재단===>WCS  End --------------------------- */



/* ------- TB_IFR021 : 생산오더-포장공정  Begin ------------------------- */
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
    FROM TB_IFR021
    WHERE AUFNR     = i_AUFNR
    AND   PACKSEQ   = i_PACKSEQ
    AND   IF_IFR_NO = i_IF_IFR_NO;

    IF V_DLFL = 'X' THEN
      UPDATE TB_SCH009
         SET DLFL = V_DLFL
           , UPDDATE = SYSDATE
           , UPDID = 'sp_IFR021'
       WHERE AUFNR   =  i_AUFNR
         AND PACKSEQ =  i_PACKSEQ;


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


      IF V_DLFL_CNT > 0 THEN
        UPDATE TB_SCH018
           SET USE_YN = 'N'
             , UPDDATE = SYSDATE
             , UPDID = 'sp_IFR021'
         WHERE ORDER_NO =  i_AUFNR;
      END IF;


      o_msg_MSG  :=  'TB_IFR021, 생산오더-포장 삭제 수신되었습니다.1'; -- || ',' || SQLERRM ;

      UPDATE  TB_IFR021
      SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
            , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
            , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
      WHERE  AUFNR     =  i_AUFNR
      AND    IF_IFR_NO =  i_IF_IFR_NO
      ;

      o_msg_MSG  :=  'TB_IFR021, 생산오더-포장 삭제 수신되었습니다.2'; -- || ',' || SQLERRM ;
      o_msg_code := '0' ;
      RETURN;
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
          ,'sp_ifr021'             										          --  수정자
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
        , 'sp_ifr021'                        					          --  등록자
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
    SELECT COUNT(ORDER_NO) INTO V_CNT
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
           ,'sp_ifr021'                           				      --수정자ID
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
			 ,'sp_ifr021'                                                             --등록자ID
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
            ,'sp_ifr021'
            ,null
            ,null
      FROM TB_SCH001
      WHERE  AUFNR  =  i_AUFNR;
    END IF;




    o_msg_MSG  :=  'TB_IFR021, 생산오더-포장 오더가 수신되었습니다.1'; -- || ',' || SQLERRM ;

    UPDATE  TB_IFR021
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    AUFNR     =  i_AUFNR
    AND    IF_IFR_NO =  i_IF_IFR_NO
    ;

    o_msg_MSG  :=  'TB_IFR021, 생산오더-포장 오더가 수신되었습니다.2'; -- || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
                o_msg_MSG  :=  'TB_IFR021, 생산오더-포장 오더 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                o_msg_code      := '-1' ;
                DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                ROLLBACK;

                UPDATE  TB_IFR021
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
    FROM TB_IFR022
    WHERE AUFNR = i_AUFNR
    AND IF_IFR_NO = i_IF_IFR_NO;

    IF V_DLFL = 'X' THEN
      UPDATE TB_SCH010
         SET DLFL = V_DLFL
           , UPDDATE = SYSDATE
           , UPDID = 'sp_IFR022'
       WHERE AUFNR =  i_AUFNR;

      UPDATE TB_SCH019
         SET USE_YN = 'N'
           , UPDDATE = SYSDATE
           , UPDID = 'sp_IFR022'
       WHERE ORDER_NO =  i_AUFNR;

      o_msg_MSG  :=  'TB_IFR022, 생산오더-예외 삭제 수신되었습니다.1'; -- || ',' || SQLERRM ;

      UPDATE  TB_IFR022
      SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
            , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
            , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
      WHERE  AUFNR     =  i_AUFNR
      AND    IF_IFR_NO =  i_IF_IFR_NO
      ;

      o_msg_MSG  :=  'TB_IFR022, 생산오더-예외 삭제 수신되었습니다.2'; -- || ',' || SQLERRM ;
      o_msg_code := '0' ;
      RETURN;
    END IF;

    MERGE
    INTO  TB_SCH010 SCH010
    USING TB_IFR022 IFR022
    ON    ( SCH010.AUFNR      =  IFR022.AUFNR
    AND     IFR022.AUFNR      =  i_AUFNR
    AND     IFR022.IF_IFR_NO  =  i_IF_IFR_NO  )
    WHEN MATCHED THEN
         UPDATE
         SET    	SCH010.WERKS		        =	IFR022.WERKS		            --플랜트
                ,	SCH010.GSTRS		        =	IFR022.GSTRS		            --시작일자
                ,	SCH010.AUART		        =	IFR022.AUART		            --오더유형
                ,	SCH010.AUARTXT		        =	IFR022.AUARTXT		            --오더유형 텍스트
                ,	SCH010.MATNR		        =	IFR022.MATNR		            --제품코드
                ,	SCH010.GAMNG		        =	IFR022.GAMNG		            --생산지시량
                ,	SCH010.GMEIN		        =	IFR022.GMEIN		            --생산지시단위
                ,	SCH010.ARBPL		        =	IFR022.ARBPL		            --Work Center
                ,	SCH010.VERID		        =	IFR022.VERID		            --생산버전
                ,	SCH010.STLNR		        =	IFR022.STLNR		            --BOM Num
                ,	SCH010.STLAL		        =	IFR022.STLAL		            --대체Bom
                ,	SCH010.BMENG		        =	IFR022.BMENG		            --모품목기준수량
                ,	SCH010.BMEIN		        =	IFR022.BMEIN		            --모품목기준수량 단위
                ,	SCH010.FTRMI		        =	IFR022.FTRMI		            --릴리즈일자
                ,	SCH010.VBELN		        =	IFR022.VBELN		            --판매문서번호
                ,	SCH010.POSNR		        =	IFR022.POSNR		            --판매문서Item번호
                ,   SCH010.PCODE        	    =   IFR022.PCODE         		    --지종
                ,   SCH010.WEIGHT               =   IFR022.WEIGHT                   --평량
                ,   SCH010.WLEN                 =   IFR022.WLEN                     --가로길
                ,   SCH010.VLEN                 =   IFR022.VLEN                     --세로길
                ,   SCH010.ZZATT1               =   IFR022.ZZATT1                   --팔레트당연수
                ,   SCH010.ZZATT2               =   IFR022.ZZATT2                   --속당매수
                ,   SCH010.PACKTYPE             =   IFR022.PACKTYPE                 --포장타입
                ,   SCH010.MCNT                 =   IFR022.MCNT                     --매
                ,   SCH010.SCNT                 =   IFR022.SCNT                     --속
                ,   SCH010.KUNNR                =   IFR022.KUNNR                    --판매처 코드
                ,   SCH010.NAME1                =   IFR022.NAME1                    --판매처

                ,   SCH010.ZSIZE                =   IFR022.ZSIZE                    --지관사이즈(인치)
                ,   SCH010.ZCAP                 =   IFR022.ZCAP                     --지관마개여부
                ,   SCH010.ZBOX                 =   IFR022.ZBOX                     --골판지여부
                ,   SCH010.ZPACK                =   IFR022.ZPACK                    --포장여부

                ,	SCH010.DLFL		            =	IFR022.DLFL		                --오더삭제지시자
                ,	SCH010.UPDDATE		        =	sysdate		                    --수정일자
                ,	SCH010.UPDID		        =	'sp_ifr022'		                --수정자
          WHERE  IFR022.IF_STATUS in ('N','E')                       /*  I/F상태, N:신규, S:성공, E:오류                      */
          AND    IFR022.AUFNR     =  i_AUFNR
          AND    IFR022.IF_IFR_NO =  i_IF_IFR_NO
    WHEN NOT MATCHED THEN
         INSERT (  	SCH010.AUFNR				                             --오더번호
                  ,	SCH010.WERKS				                             --플랜트
                  ,	SCH010.GSTRS				                             --시작일자
                  ,	SCH010.AUART				                             --오더유형
                  ,	SCH010.AUARTXT				                             --오더유형 텍스트
                  ,	SCH010.MATNR				                             --제품코드
                  ,	SCH010.GAMNG				                             --생산지시량
                  ,	SCH010.GMEIN				                             --생산지시단위
                  ,	SCH010.ARBPL				                             --Work Center
                  ,	SCH010.VERID				                             --생산버전
                  ,	SCH010.STLNR				                             --BOM Num
                  ,	SCH010.STLAL				                             --대체Bom
                  ,	SCH010.BMENG				                             --모품목기준수량
                  ,	SCH010.BMEIN				                             --모품목기준수량 단위
                  ,	SCH010.FTRMI				                             --릴리즈일자
                  ,	SCH010.VBELN				                             --판매문서번호
                  ,	SCH010.POSNR				                             --판매문서Item번호
                  , SCH010.PCODE       										 --지종
                  , SCH010.WEIGHT                                            --평량
                  , SCH010.WLEN                                              --가로길
                  , SCH010.VLEN                                              --세로길
                  , SCH010.ZZATT1                                            --팔레트당연수
                  , SCH010.ZZATT2                                            --속당매수
                  , SCH010.PACKTYPE                                          --포장타입
                  , SCH010.MCNT                                              --매
                  , SCH010.SCNT                                              --속
                  , SCH010.KUNNR                                             --판매처 코드
                  , SCH010.NAME1                                             --판매처

                  , SCH010.ZSIZE                                             --지관사이즈(인치)
                  , SCH010.ZCAP                                              --지관마개여부
                  , SCH010.ZBOX                                              --골판지여부
                  , SCH010.ZPACK                                             --포장여부

                  ,	SCH010.DLFL				                                 --오더삭제지시자
                  ,	SCH010.REGDATE				                             --등록일자
                  ,	SCH010.REGID				                             --등록자
                  ,	SCH010.UPDDATE				                             --수정일자
                  ,	SCH010.UPDID				                             --수정자
                    )
         VALUES (   IFR022.AUFNR				                             --오더번호
                  ,	IFR022.WERKS				                             --플랜트
                  ,	IFR022.GSTRS				                             --시작일자
                  ,	IFR022.AUART				                             --오더유형
                  ,	IFR022.AUARTXT				                             --오더유형 텍스트
                  ,	IFR022.MATNR				                             --제품코드
                  ,	IFR022.GAMNG				                             --생산지시량
                  ,	IFR022.GMEIN				                             --생산지시단위
                  ,	IFR022.ARBPL				                             --Work Center
                  ,	IFR022.VERID				                             --생산버전
                  ,	IFR022.STLNR				                             --BOM Num
                  ,	IFR022.STLAL				                             --대체Bom
                  ,	IFR022.BMENG				                             --모품목기준수량
                  ,	IFR022.BMEIN				                             --모품목기준수량 단위
                  ,	IFR022.FTRMI				                             --릴리즈일자
                  ,	IFR022.VBELN				                             --판매문서번호
                  ,	IFR022.POSNR				                             --판매문서Item번호
                  , IFR022.PCODE       										 --지종
                  , IFR022.WEIGHT                                            --평량
                  , IFR022.WLEN                                              --가로길
                  , IFR022.VLEN                                              --세로길
                  , IFR022.ZZATT1                                            --팔레트당연수
                  , IFR022.ZZATT2                                            --속당매수
                  , IFR022.PACKTYPE                                          --포장타입
                  , IFR022.MCNT                                              --매
                  , IFR022.SCNT                                              --속
                  , IFR022.KUNNR                                             --판매처 코드
                  , IFR022.NAME1                                             --판매처

                  , IFR022.ZSIZE                                             --지관사이즈(인치)
                  , IFR022.ZCAP                                              --지관마개여부
                  , IFR022.ZBOX                                              --골판지여부
                  , IFR022.ZPACK                                             --포장여부

                  ,	IFR022.DLFL				                                 --오더삭제지시자
                  ,	sysdate				                         --등록일자
                  ,	'sp_ifr022'				                         --등록자
                  ,	null				                             --수정일자
                  ,	null				                                 --수정자
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
      FROM TB_IFR022
      WHERE IF_IFR_NO  =  i_IF_IFR_NO;

      SP_GET_DOC_SEQ('WOEX',V_WO_DT,V_WO_NO);
    END IF;
    ------------------------------------------

    MERGE
        INTO  TB_SCH019 SCH019
        USING TB_IFR022 IFR022
           ON ( SCH019.ORDER_NO   =  IFR022.AUFNR
           AND  IFR022.AUFNR      =  i_AUFNR
           AND  IFR022.IF_IFR_NO  =  i_IF_IFR_NO   )
    WHEN MATCHED THEN
        UPDATE SET
             SCH019.WERKS                = IFR022.WERKS                         	--플랜트코드
            ,SCH019.PRD_REQ_DT           = IFR022.GSTRS                         	--생산요청일자
            ,SCH019.PCODE				 = IFR022.PCODE 							--지종
            ,SCH019.BS_WGT               = IFR022.WEIGHT                            --평량
            ,SCH019.WLEN                 = IFR022.WLEN                              --가로길
            ,SCH019.VLEN                 = IFR022.VLEN                              --세로길
            ,SCH019.PLT_PER_CNT          = IFR022.ZZATT1                            --팔레트당연수
            ,SCH019.IN_PER_CNT           = IFR022.ZZATT2                            --속당매수
            ,SCH019.PACKTYPE             = IFR022.PACKTYPE                          --포장타입
            ,SCH019.MCNT                 = IFR022.MCNT                              --매
            ,SCH019.SCNT                 = IFR022.SCNT                              --속
            ,SCH019.KUNNR                = IFR022.KUNNR                             --판매처 코드
            ,SCH019.KUNNRT               = IFR022.NAME1                             --판매처

            ,SCH019.ORDER_DIV            = IFR022.AUART                             --오더유형
            ,SCH019.AUARTXT              = IFR022.AUARTXT                           --오더유형 텍스트
            ,SCH019.MATNR                = IFR022.MATNR                             --제품코드
            ,SCH019.UNIT                 = IFR022.GMEIN                             --생산지시단위
            ,SCH019.WRK_CD               = IFR022.ARBPL                             --Work Center
            ,SCH019.VERID                = IFR022.VERID                             --생산버전
            ,SCH019.STLNR                = IFR022.STLNR                             --BOM Num
            ,SCH019.STLAL                = IFR022.STLAL                             --대체Bom
            ,SCH019.BMENG                = IFR022.BMENG                             --모품목기준수량
            ,SCH019.BMEIN                = IFR022.BMEIN                             --모품목기준수량 단위
            ,SCH019.FTRMI                = IFR022.FTRMI                             --릴리즈일자
            ,SCH019.VBELN                = IFR022.VBELN                             --판매문서번호
            ,SCH019.POSNR                = IFR022.POSNR                             --판매문서Item번호
            ,SCH019.WRK_ORDR_QTY         = IFR022.GAMNG                             --생산지시량
            ,SCH019.GSTRS   			 = IFR022.GSTRS				  				--생산요청일자
            ,SCH019.GAMNG                = IFR022.GAMNG                             --생산지시량
            ,SCH019.GMEIN                = IFR022.GMEIN                             --생산지시단위
            ,SCH019.ARBPL                = IFR022.ARBPL                             --Work Center

            ,SCH019.CORE_INCH            = IFR022.ZSIZE                             --지관사이즈(인치)
            ,SCH019.COVER_YN             = IFR022.ZCAP                              --지관마개여부
            ,SCH019.CORR_YN              = IFR022.ZBOX                              --골판지여부
            ,SCH019.PACK_YN              = IFR022.ZPACK                             --포장여부

            ,SCH019.DLFL                 = IFR022.DLFL                              --오더삭제지시자

            ,SCH019.UPDDATE              = sysdate                              	--수정일시
            ,SCH019.UPDID                = 'sp_IFR022'                          	--수정자ID
            ,SCH019.USE_YN               =  case when IFR022.DLFL = 'X' then 'N'
                                                 when IFR022.DLFL = 'N' then 'Y'
                                            end                                  --사용여부(Y:사용 N:미사용)
        WHERE IFR022.IF_STATUS in ('N','E')                                      --I/F상태, N:신규, S:성공, E:오류
        AND   IFR022.AUFNR     =  i_AUFNR
        AND   IFR022.IF_IFR_NO =  i_IF_IFR_NO
    WHEN NOT MATCHED THEN
        INSERT (
			  SCH019.WRK_ORDR_NO                                                    --작업지시번호-->작업지시 생성자 사용 WO + R
			, SCH019.WRK_ORDR_SEQNO                                                 --작업지시순번
            , SCH019.WRK_SEQNO                                                      --작업순서
			, SCH019.ORDR_GEN_DT                                                    --지시생성일자

			, SCH019.PRD_REQ_DT                                                     --생산요청일자
			, SCH019.ORDER_NO                                                       --오더번호
			, SCH019.WERKS                                                          --플랜트코드
			, SCH019.PCODE							   							    --지종
			, SCH019.BS_WGT                                      				    --평량
			, SCH019.WLEN                                        				    --가로길
			, SCH019.VLEN                                        				    --세로길
			, SCH019.PLT_PER_CNT                                 				    --팔레트당연수
			, SCH019.IN_PER_CNT                                  				    --속당매수
			, SCH019.PACKTYPE                                    				    --포장타입
			, SCH019.MCNT                                        				    --매
			, SCH019.SCNT                                        				    --속
			, SCH019.KUNNR                                       				    --판매처 코드
			, SCH019.KUNNRT                                      				    --판매처
			, SCH019.MACH_CD                                                        --설비코드

			, SCH019.ORDER_DIV                                                      --오더유형
			, SCH019.AUARTXT                                                        --오더유형 텍스
			, SCH019.MATNR                                                          --제품코드
			, SCH019.UNIT                                                           --생산지시단위
			, SCH019.WRK_CD                                                         --Work Cente
			, SCH019.VERID                                                          --생산버전
			, SCH019.STLNR                                                          --BOM Num
			, SCH019.STLAL                                                          --대체Bom
			, SCH019.BMENG                                                          --모품목기준수량
			, SCH019.BMEIN                                                          --모품목기준수량
			, SCH019.FTRMI                                                          --릴리즈일자
			, SCH019.VBELN                                                          --판매문서번호
			, SCH019.POSNR                                                          --판매문서Item
			, SCH019.WRK_ORDR_QTY                                                   --생산지시량
			, SCH019.GSTRS   						 					            --생산요청일자
			, SCH019.GAMNG                                                          --생산지시량
			, SCH019.GMEIN                                                          --생산지시단위
			, SCH019.ARBPL                                                          --Work Cente

			, SCH019.CORE_INCH                                                      --지관사이즈(인치)
			, SCH019.COVER_YN                                                       --지관마개여부
			, SCH019.CORR_YN                                                        --골판지여부
			, SCH019.PACK_YN                                                        --포장여부

            , SCH019.DLFL                                                           --오더삭제지시자

			, SCH019.COMP_YN                                                        --완료여부
			, SCH019.REGDATE                                                        --등록일시
			, SCH019.REGID                                                          --등록자ID
			, SCH019.UPDDATE                                                        --수정일시
			, SCH019.UPDID                                                          --수정자ID
			, SCH019.USE_YN                                                         --사용여부(Y:사용 N:미사용)
        )VALUES(
            V_WO_NO													--작업지시번호
            ,1                                                     --작업지시순번
            ,SUBSTR(V_WO_NO,-4)                                         --작업순서(작업지시번호,-4)
            ,TO_CHAR(sysdate,'YYYYMMDD')                               --지시생성일자

			,IFR022.GSTRS                                               --생산요청일자
			,IFR022.AUFNR                                                --오더번호
			,IFR022.WERKS                                                           --플랜트코드
			,IFR022.PCODE 															--지종
			,IFR022.WEIGHT                          						--평량
			,IFR022.WLEN                            								--가로길
			,IFR022.VLEN                            								--세로길
			,IFR022.ZZATT1                          					--팔레트당연수
			,IFR022.ZZATT2                          						--속당매수
			,IFR022.PACKTYPE                        								--포장타입
			,IFR022.MCNT                            								--매
			,IFR022.SCNT                            								--속
			,IFR022.KUNNR                           								--판매처 코드
			,IFR022.NAME1                           						--판매처
			, CASE WHEN IFR022.WERKS = 'P200' THEN 'TPG01'
                   WHEN IFR022.WERKS = 'P300' THEN 'SPF03'
                   WHEN IFR022.WERKS = 'P500' THEN 'BPI02'
                   ELSE '' END                                                      --설비코드(YSH 2022.09.05)
            --,(SELECT M012.MACH_CD FROM TB_MAS012 M012,TB_MAS013 M013 WHERE M012.PROC_CD = M013.PROC_CD(+) AND M012.SAP_WRK_CD = IFR022.ARBPL AND M013.WERKS = IFR022.WERKS AND ROWNUM = 1) --설비코드

			, IFR022.AUART                           					--오더유형
			, IFR022.AUARTXT                         								--오더유형 텍스트
			, IFR022.MATNR                           								--제품코드
			, IFR022.GMEIN                           							--생산지시단위
			, IFR022.ARBPL                           						--Work Center
			, IFR022.VERID                           								--생산버전
			, IFR022.STLNR                           								--BOM Num
			, IFR022.STLAL                           								--대체Bom
			, IFR022.BMENG                           								--모품목기준수량
			, IFR022.BMEIN                           								--모품목기준수량 단위
			, IFR022.FTRMI                           								--릴리즈일자
			, IFR022.VBELN                           								--판매문서번호
			, IFR022.POSNR                           								--판매문서Item번호
			, IFR022.GAMNG                           				--생산지시량
			, IFR022.GSTRS															--생산요청일자
			, IFR022.GAMNG                           								--생산지시량
			, IFR022.GMEIN                           								--생산지시단위
			, IFR022.ARBPL                           								--Work Center

			, IFR022.ZSIZE                            					--지관사이즈(인치)
			, IFR022.ZCAP                            						--지관마개여부
			, IFR022.ZBOX                            						--골판지여부
			, IFR022.ZPACK                            						--포장여부

			, IFR022.DLFL                            								--오더삭제지시자

			, 'N'                                                         --완료여부
			, sysdate                                                      --등록일시
			, 'sp_IFR022'                                                    --등록자ID
			, null                                                        --수정일시
			, null                                                          --수정자ID
			, case when IFR022.DLFL = 'X' then 'N'
                    else 'Y'
             end                                                                    --사용여부(Y:사용 N:미사용)
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




    o_msg_MSG  :=  'TB_IFR022, 생산오더-예외생산 오더가 수신되었습니다.1'; -- || ',' || SQLERRM ;

    UPDATE  TB_IFR022
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    AUFNR     =  i_AUFNR
    AND    IF_IFR_NO =  i_IF_IFR_NO
    ;

    o_msg_MSG  :=  'TB_IFR022, 생산오더-예외생산 오더가 수신되었습니다.2'; -- || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
                o_msg_MSG  :=  'TB_IFR022, 생산오더-예외생산 오더 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                o_msg_code      := '-1' ;
                DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                ROLLBACK;

                UPDATE  TB_IFR022
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

            sp_ifr014(  ifr014.IF_IFR_NO	--MES 수신번호
                      , ifr014.AUFNR		--오더번호
                      , ifr014.POSNR		--오더ITEM번호
                      , ifr014.MATNR		--자품목자재
                      , ifr014.BDMNG		--오더BOM수량
                      , ifr014.MEINS		--오더BOM수량단위
                      , ifr014.CHARG		--LOT번호
                      , ifr014.LGORT		--저장위치
                      , ifr014.XLOEK		--삭제여부
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

        /* 정규(슬리터) 원지포장자동화 옵션 UPDATE */
        FOR ifr019 IN cur_ifr019 LOOP
            IF ifr019.SLITER = 'Y' THEN /* 슬리터 이동 작업지시면 */
                UPDATE TB_SCH016
                SET CORE_INCH = ifr019.ZSIZE
                  , COVER_YN  = ifr019.ZCAP
                  , CORR_YN   = ifr019.ZBOX
                  , PACK_YN   = ifr019.ZPACK
                WHERE 1 = 1
                  AND PRE_ORDER_NO = ifr019.AUFNR
                  AND SLITER = 'X';
            END IF;

            COMMIT ;
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('MES_IF_119 슬리터 생산지시 UPDATE ==>END');

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

DBMS_OUTPUT.PUT_LINE('AAAAA');

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

END ;
/
