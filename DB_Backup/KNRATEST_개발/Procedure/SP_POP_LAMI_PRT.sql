--------------------------------------------------------
--  DDL for Procedure SP_POP_LAMI_PRT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_LAMI_PRT" 
(
    P_WERKS     		IN VARCHAR2 	    --플랜트
    ,P_MACH_CD   		IN VARCHAR2 	    --설비코드
    ,P_IND_BCD          IN VARCHAR2 	    --개별바코드
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
    ,CUR_1       		OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : WRK073
 * PROGRAM NAME  : 인쇄/코팅 라벨 프린팅
 * VERSION       : 1.0.0
 * DESCRIPTION   : 인쇄/코팅 라벨 프린팅을 하기 위한 SP.
 *                 
 * AUTHOR NAME   : 김수현
 * CREATE DATE   : 2022/11/17
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/10    1.0.0   김수현         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_LAMI_PC] : (.R..) 인쇄/코팅 작업지시
 *=============================================================================*/
AS 
    --프로그램 ID - 밀롤 인쇄용 조회
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_LAMI_PC_PRT';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID

    V_WRK_TYPE          varchar2(2);
    V_LINE              varchar2(10);
    V_PROC_CD           varchar2(20);
    V_CNT               NUMBER;
    V_CNT2               NUMBER;
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리
BEGIN
    BEGIN

    SELECT PROC_CD
    INTO V_PROC_CD
    FROM TB_MAS012
    WHERE 1 = 1
    AND MACH_CD = P_MACH_CD
    AND ROWNUM = 1
    ;

    IF V_PROC_CD = 'LP1' THEN
        BEGIN
            SELECT COUNT(*)
            INTO V_CNT2
            FROM TB_LAMI_PC_RESULT
            WHERE 1 = 1
            AND WERKS = P_WERKS
            AND MACH_CD = P_MACH_CD
            AND IND_BCD = P_IND_BCD
            ;
--                BEGIN
--                    SELECT DECODE(SUBSTR(WRK_ORDR_NO,1,4), 'WOEX', 'X', 'Y')   -- 작업유형 : 'Y'는 정규생산, 'X'는 예외생산
--                        INTO V_WRK_TYPE
--                        FROM TB_WRK002
--                        WHERE WERKS = P_WERKS
--                           AND MACH_CD = P_MACH_CD
--                           AND IND_BCD  = P_IND_BCD;
--                EXCEPTION
--                    WHEN NO_DATA_FOUND THEN
--                    RS_CODE := 'E';
--                    RS_MSG := 'NO_DATA_FOUND';
--                    RETURN;            
--                END;

                --라미네이팅의 경우 정규생산만 있다는 전제로 작성
                V_WRK_TYPE := 'Y';

                BEGIN
                    SELECT LINE || 'win'
                        INTO V_LINE
                    FROM TB_MAS012
                    WHERE MACH_CD = P_MACH_CD;
                EXCEPTION 
                    WHEN NO_DATA_FOUND THEN
                    V_LINE := 'win';
                END;

                SELECT COUNT(IND_BCD)
                INTO V_CNT
                FROM TB_LAMI_PC
                WHERE 1 = 1
                AND IND_BCD = P_IND_BCD;

                --작업유형 : 'Y'는 정규생산, 'X'는 예외생산
--                IF V_WRK_TYPE = 'Y' AND V_CNT > 0 THEN
                IF V_WRK_TYPE = 'Y' AND V_CNT2 = 0 THEN
                    BEGIN
                        OPEN CUR_1 FOR
                        SELECT '깨끗한 나라 CI' AS TITLE_NAME
                            ,TO_CHAR(TO_DATE(S016.PRD_END_DTM,'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD') AS PRD_DATE --생산일자
                            ,NVL(S016.STD,'') AS SPEC --규격
                            ,TO_CHAR(NVL(S016.PRFM_QTY, 0)) || 'KG' AS PRFM_WGT --중량                                --
                            ,NVL(S016.HEIGHT,0) AS HEIGHT
                            ,M001.PCODE_NM                                                   --지종
                            ,TO_CHAR(NVL(S016.EQUIL, 0)) || 'g/㎡' AS BS_WGT                                    --평량
                            ,'김대식' || '/' || USRMA.NMLAST  AS WRK_NAME                 -- 반, 작업자
                            ,NVL(S016.LOT_BUF,' ') AS LOT_NO
                            ,NVL(S016.IND_BCD,' ') AS IND_BCD
                            ,NVL(S016.IND_BCD,' ') AS BAR_CODE
                          FROM TB_LAMI_PC S016,
                               TB_MAS001 M001,
                               USRMA USRMA
                         WHERE  S016.WERKS = M001.WERKS(+)
                           AND S016.MATNR = M001.MATNR(+)
                           AND S016.REGID = USRMA.USERID(+)
                           AND S016.WERKS = P_WERKS
                           AND S016.MACH_CD = P_MACH_CD
                           AND NVL(S016.COMP_YN,'Y') = 'Y'
                           AND NVL(S016.USE_YN,'N') = 'N'
                           AND S016.IND_BCD = P_IND_BCD;

                    END;
                ELSIF V_WRK_TYPE = 'Y' AND V_CNT2 > 0 THEN
                    BEGIN
                        OPEN CUR_1 FOR
                        SELECT '깨끗한 나라 CI' AS TITLE_NAME
                            ,TO_CHAR(S016.PRD_END_DATE,'YYYY-MM-DD') AS PRD_DATE --생산일자
                            ,NVL(D.STD,M001.MATNR_SPEC) AS SPEC --규격
                            ,TO_CHAR(NVL(S016.PRFM_QTY, 0)) || 'KG' AS PRFM_WGT --중량                                --
                            ,NVL(D.HEIGHT,M001.VLEN) AS HEIGHT
                            ,M001.PCODE_NM                                                   --지종
                            ,TO_CHAR(NVL(D.EQUIL, M001.BS_WGT)) || 'g/㎡' AS BS_WGT                                    --평량
                            ,'김대식' || '/' || USRMA.NMLAST  AS WRK_NAME                 -- 반, 작업자
                            ,NVL(S016.LOT_NO,' ') AS LOT_NO
                            ,NVL(S016.IND_BCD,' ') AS IND_BCD
                            ,NVL(S016.IND_BCD,' ') AS BAR_CODE
                          FROM TB_LAMI_PC_RESULT S016,
                               TB_MAS001 M001,
                               USRMA USRMA,
                               TB_LAMI_PC D
                         WHERE  S016.WERKS = M001.WERKS(+)
                           AND S016.MATNR = M001.MATNR(+)
                           AND S016.REGID = USRMA.USERID(+)
                           AND S016.WRK_ORDR_NO = D.WRK_ORDR_NO
                           AND S016.WRK_ORDR_SEQNO = D.WRK_ORDR_SEQNO
                           AND S016.WERKS = P_WERKS
                           AND S016.MACH_CD = P_MACH_CD
                           AND S016.IND_BCD = P_IND_BCD;
                    END;
                END IF;
            RS_CODE := 'S';
        END;
    ELSIF V_PROC_CD = 'LS1' THEN
        BEGIN

            SELECT COUNT(*)
            INTO V_CNT2
            FROM TB_LAMI_SL_RESULT
            WHERE 1 = 1
            AND WERKS = P_WERKS
            AND MACH_CD = P_MACH_CD
            AND IND_BCD = P_IND_BCD
            ;

--            BEGIN
--                SELECT DECODE(SUBSTR(WRK_ORDR_NO,1,4), 'WOEX', 'X', 'Y')   -- 작업유형 : 'Y'는 정규생산, 'X'는 예외생산
--                    INTO V_WRK_TYPE
--                    FROM TB_WRK002
--                    WHERE WERKS = P_WERKS
--                       AND MACH_CD = P_MACH_CD
--                       AND IND_BCD  = P_IND_BCD;
--            EXCEPTION
--                WHEN NO_DATA_FOUND THEN
--                RS_CODE := 'E';
--                RS_MSG := 'NO_DATA_FOUND';
--                RETURN;            
--            END;

            --라미네이팅의 경우 정규생산만 있다는 전제로 작성
            V_WRK_TYPE := 'Y';

            BEGIN
                SELECT LINE || 'win'
                    INTO V_LINE
                FROM TB_MAS012
                WHERE MACH_CD = P_MACH_CD;
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN
                V_LINE := 'win';
            END;

                SELECT COUNT(IND_BCD)
                INTO V_CNT
                FROM TB_LAMI_SL
                WHERE 1 = 1
                AND IND_BCD = P_IND_BCD;

            --작업유형 : 'Y'는 정규생산, 'X'는 예외생산
--            IF V_WRK_TYPE = 'Y' AND V_CNT > 0 THEN
                IF V_WRK_TYPE = 'Y' AND V_CNT2 = 0 THEN
                    BEGIN
                        OPEN CUR_1 FOR
                        SELECT '깨끗한 나라 CI' AS TITLE_NAME
                            ,TO_CHAR(TO_DATE(S016.PRD_END_DTM,'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD') AS PRD_DATE --생산일자
                            ,NVL(S016.STD,'') AS SPEC --규격
                            ,TO_CHAR(NVL(S016.PRFM_QTY, 0)) || 'KG' AS PRFM_WGT --중량                                --
                            ,NVL(S016.HEIGHT,0) AS HEIGHT
                            ,M001.PCODE_NM                                                   --지종
                            ,TO_CHAR(NVL(S016.EQUIL, 0)) || 'g/㎡' AS BS_WGT                                    --평량
                            ,'김대식' || '/' || USRMA.NMLAST  AS WRK_NAME                 -- 반, 작업자
                            ,NVL(S016.LOT_BUF,' ') AS LOT_NO
                            ,NVL(S016.IND_BCD,' ') AS IND_BCD
                            ,NVL(S016.IND_BCD,' ') AS BAR_CODE
                          FROM TB_LAMI_SL S016,
                               TB_MAS001 M001,
                               USRMA USRMA
                         WHERE  S016.WERKS = M001.WERKS(+)
                           AND S016.MATNR = M001.MATNR(+)
                           AND S016.REGID = USRMA.USERID(+)
                           AND S016.WERKS = P_WERKS
                           AND S016.MACH_CD = P_MACH_CD
                           AND NVL(S016.COMP_YN,'Y') = 'Y'
                           AND NVL(S016.USE_YN,'N') = 'N'
                           AND S016.IND_BCD = P_IND_BCD;
                    END;
                ELSIF V_WRK_TYPE = 'Y' AND V_CNT2 > 0 THEN
                    BEGIN
                        OPEN CUR_1 FOR
                        SELECT '깨끗한 나라 CI' AS TITLE_NAME
                            ,TO_CHAR(S016.PRD_END_DATE,'YYYY-MM-DD') AS PRD_DATE --생산일자
                            ,NVL(D.STD,M001.MATNR_SPEC) AS SPEC --규격
                            ,TO_CHAR(NVL(S016.PRFM_QTY, 0)) || 'KG' AS PRFM_WGT --중량                                --
                            ,NVL(D.HEIGHT,M001.VLEN) AS HEIGHT
                            ,M001.PCODE_NM                                                   --지종
                            ,TO_CHAR(NVL(D.EQUIL, M001.BS_WGT)) || 'g/㎡' AS BS_WGT                                    --평량
                            ,'김대식' || '/' || USRMA.NMLAST  AS WRK_NAME                 -- 반, 작업자
                            ,NVL(S016.LOT_NO,' ') AS LOT_NO
                            ,NVL(S016.IND_BCD,' ') AS IND_BCD
                            ,NVL(S016.IND_BCD,' ') AS BAR_CODE
                          FROM TB_LAMI_SL_RESULT S016,
                               TB_MAS001 M001,
                               USRMA USRMA,
                               TB_LAMI_SL D
                         WHERE  S016.WERKS = M001.WERKS(+)
                           AND S016.MATNR = M001.MATNR(+)
                           AND S016.REGID = USRMA.USERID(+)
                           AND S016.WRK_ORDR_NO = D.WRK_ORDR_NO
                           AND S016.WRK_ORDR_SEQNO = D.WRK_ORDR_SEQNO
                           AND S016.WERKS = P_WERKS
                           AND S016.MACH_CD = P_MACH_CD
                           AND S016.IND_BCD = P_IND_BCD;
                    END;
                END IF;
            RS_CODE := 'S';
        END;
    END IF;

--        RS_CODE := 'S';

    --예외처리(catch)
    EXCEPTION
    WHEN E_EXCEPTION_USER THEN
        -- 에러 내역 SET
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    WHEN OTHERS THEN
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

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
