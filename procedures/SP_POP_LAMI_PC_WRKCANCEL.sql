
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_LAMI_PC_WRKCANCEL" SP_POP_LAMI_PC_WRKCANCEL
(
    P_WRK_ORDR_NO       IN VARCHAR2                     --작업지시번호 --HBLA202210110002
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2                     --작업지시번호SEQ --2
    ,P_USERID           IN VARCHAR2                     --USER ID
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
    ,RS_PRFM_RFCFN      OUT  VARCHAR2                      --실적 RFCFN값
    ,RS_DISPO_RFCFN      OUT  VARCHAR2                      --실적 RFCFN값
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
    ,CUR_3          OUT SYS_REFCURSOR
    ,CUR_4          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_LAMI_PC_WRKCANCEL{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 라미네이팅 인쇄코팅 실적취소 검색
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 라미네이팅 인쇄코팅 실적취소 검색
 *                 
 * AUTHOR NAME   : 김수현{최초 작성자 명 기술}
 * CREATE DATE   : 2022/12/28 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/12/28    1.0.0   김수현         Initial Version 
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/
AS 
    --프로그램 ID : 재단 ROLLBACK 
    V_PRG_NM         VARCHAR2(100) := 'SP_POP_LAMI_PC_WRKCANCEL';  -- PROCEDURE NAME
    V_PLT_CD         VARCHAR2(2)   := '99';     --PLANTCODE TEST
    V_SESS_USER_ID   VARCHAR2(20)  := P_USERID; --USERID

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_OBJ            JSON_OBJECT_T;

    --parameter변수 처리
    V_YMCHK             TB_MAS011.YMCHK%TYPE;        --실적등록 가능 여부 

    V_DOC_NO          VARCHAR2(20);
    V_DOC_NO_SCR      VARCHAR2(20);
    V_ORDER_NO        VARCHAR2(30);
    V_SQL             VARCHAR2(4000);

BEGIN
  BEGIN
  
      SELECT ORDER_NO
      INTO V_ORDER_NO
      FROM TB_LAMI_PC
      WHERE 1 = 1
      AND WRK_ORDR_NO = P_WRK_ORDR_NO
      AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;

    -- ROLLBACK 문서번호 SELECT---------------------------------------------------------------------------------
--    	BEGIN
--            SELECT   MDOCNO
--            INTO   V_DOC_NO
--            FROM  TB_LAMI_PC_IFS001
--            WHERE AUFNR = V_ORDER_NO;
--    	EXCEPTION
--            WHEN NO_DATA_FOUND THEN
--                RS_CODE      := 'E';
--                RS_MSG       := 'ROLLBACK[SP_POP_LAMI_PC_WRKCANCEL] 문서번호가 조회되지 않습니다';
--                ROLLBACK;
--                RETURN;
--            WHEN OTHERS THEN
--                RS_CODE      := 'E';
--                RS_MSG       := 'ROLLBACK[SP_POP_LAMI_PC_WRKCANCEL] ERROR';
--                ROLLBACK;
--                RETURN;
--    	END;

    	BEGIN
            SELECT   MDOCNO
            INTO   V_DOC_NO_SCR
            FROM  TB_IFS012
            WHERE AUFNR = V_ORDER_NO;
    	EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RS_CODE      := 'E';
                RS_MSG       := 'ROLLBACK[SP_POP_LAMI_PC_WRKCANCEL] 문서번호가 조회되지 않습니다';
                ROLLBACK;
                RETURN;
            WHEN OTHERS THEN
                RS_CODE      := 'E';
                RS_MSG       := 'ROLLBACK[SP_POP_LAMI_PC_WRKCANCEL] ERROR';
                ROLLBACK;
                RETURN;
    	END;

        IF LENGTH(V_DOC_NO) > 0 THEN   --실적

            RS_PRFM_RFCFN := 'Z_MES_LAMI1_CONF'; --라미네이팅 인쇄코팅 RFC FUNCTION으로 변경해야 함

             --인터페이스 파라미터
             OPEN CUR_1 FOR
             SELECT 'MES_IF_972' AS I_IF_ID
                  , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
               FROM dual;

             --인터페이스 상세 파라미터
--             V_SQL := FN_IF_QUERY('MES_IF_972', V_DOC_NO);
--             OPEN CUR_2 FOR V_SQL;
             OPEN CUR_2 FOR
            SELECT PRDCD AS PRDCD,WERKS AS WERKS,WORKCENTERCODE AS WORKCENTERCODE,PRDDT AS PRDDT,AUFNR AS AUFNR,PRODT AS PRODT,LOTNO AS LOTNO
            ,MACHINE AS MACHINE,WORKGROUP AS WORKGROUP,LEADER AS LEADER,WORKER AS WORKER,CW_WORKER AS CW_WORKER,PUPOS AS PUPOS,PROQTY AS PROQTY
            ,SCRQTY AS SCRQTY,RUNTIME AS RUNTIME,SCPAP AS SCPAP,SAIP AS SAIP,CONF AS CONF,SDATE AS SDATE,STIME AS STIME,EDATE AS EDATE,ETIME AS ETIME
            ,MDOCNO AS MDOCNO,MDOCSEQ AS MDOCSEQ ,SDOC_NO AS SDOC_NO, SDOC_SEQNO AS SDOC_SEQNO
            FROM TB_LAMI_PC_IFS001 
            WHERE 1=1  
            AND AUFNR = V_ORDER_NO
            ORDER BY MDOCNO;

        END IF ;

        IF LENGTH(V_DOC_NO_SCR) > 0 THEN   --폐품 ( MAX 2개까지 )

             --SAP FUNC ID
             SELECT RFCFN
               INTO RS_DISPO_RFCFN
               FROM TB_ITFMA
              WHERE 1=1
                AND IFID = 'MES_IF_134';   --생산오더별 실적 취소 TXN

             --인터페이스 파라미터
             OPEN CUR_3 FOR
             SELECT 'MES_IF_134' AS I_IF_ID
                  , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
               FROM dual;

             --인터페이스 상세 파라미터
             V_SQL := FN_IF_QUERY('MES_IF_134', V_DOC_NO_SCR );
             OPEN CUR_4 FOR V_SQL;

        END IF ;  


        IF CUR_1%ISOPEN = FALSE THEN
            OPEN CUR_1 FOR SELECT 1 FROM dual;
        END IF;

        IF CUR_2%ISOPEN = FALSE THEN
            OPEN CUR_2 FOR SELECT 1 FROM dual;
        END IF;

        IF CUR_3%ISOPEN = FALSE THEN
            OPEN CUR_3 FOR SELECT 1 FROM dual;
        END IF;

        IF CUR_4%ISOPEN = FALSE THEN
            OPEN CUR_4 FOR SELECT 1 FROM dual;
        END IF;
    --예외처리(catch)
    EXCEPTION
    WHEN E_EXCEPTION_USER THEN

        -- 에러 내역 SET
        E_SQL_ERR_CD  := SQLCODE;
        E_SQL_ERR_MSG := SUBSTRB(SQLERRM,1,300);

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;

    WHEN OTHERS THEN

        E_SQL_ERR_CD  := SQLCODE;
        E_SQL_ERR_MSG := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
        --예외처리 종료
    END;
END;
/
