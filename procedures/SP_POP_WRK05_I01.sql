
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK05_I01" 
(
    P_WERKS         IN VARCHAR2         --플랜트
    ,P_WRK_DT       IN VARCHAR2         --근무일자(YYYY-MM-DD)
    ,P_WRK_TIME     IN VARCHAR2         --근무방식
    ,P_WRK_CLASS    IN VARCHAR2         --작업반
    ,P_WORKER       IN VARCHAR2         --작업자
    ,P_WORKERCNT    IN VARCHAR2         --인원수
    ,P_MACH_CD      IN VARCHAR2         --설비코드
    ,P_IOTYPE       IN VARCHAR2         --구분자
    ,P_USERID       IN VARCHAR2         --
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK05
 * PROGRAM NAME  : 작업자 선택
 * VERSION       : 1.0.0
 * DESCRIPTION   : 선택된 작업자 정보를 저장한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/04/21
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/04/21    1.0.0   김기연         Initial Version 
 * 2022/05/12    1.0.1   김기연         저장항목 변경 및 가동현황 연동
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK011] : (C.U.) 작업장 현황
 * - [TB_WRK012] : (C.U.) 작업장 가동현황
 * - [TB_WRK013] : (C.U.) 작업자 투입 현황
 *=============================================================================*/
AS 
    V_USERID    VARCHAR(20) := CASE WHEN P_USERID IS NULL 
                                    THEN P_WORKER ELSE P_USERID END;
    --프로그램 ID
    V_PRG_NM            VARCHAR2(100)  := 'SP_POP_WRK05_I01';
    V_PLT_CD            VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID      VARCHAR2(20) := V_USERID;
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER    EXCEPTION;
    E_SQL_ERR_CD        NUMBER(5) := 0;
    E_SQL_ERR_MSG       VARCHAR2(4000);

    --파리미터 처리
    V_WORKERCNT         NUMBER := TO_NUMBER(P_WORKERCNT);
    V_IOTYPE 			VARCHAR2(10) := CASE WHEN P_WERKS = 'P500' THEN 'N' ELSE P_IOTYPE END;
    --내부변수 처리
    V_DATE              DATE := SYSDATE;
    V_STR_DTM           VARCHAR2(20); --시작시간 문자열
    V_STR_DATE          DATE;
    V_END_DATE          DATE;
    V_WRK_ORDR_NO       VARCHAR2(20); --작업지시
    V_WRK_ORDR_SEQNO    NUMBER;
    V_ORDER_NO          VARCHAR2(20); --생산오더
    V_ORDER_SEQNO       NUMBER;
    V_MATNR             VARCHAR2(20); --자재코드
    V_LINE_STA          VARCHAR2(10) := 'S' ; --설비상태(초기상태 정지:S)
    V_ABN_CD            VARCHAR2(10); --비가동 코드
    V_WRK_SHIFT         VARCHAR2(10); --이전 작업반 근무정보
    V_BEF_STR_DATE      DATE; --이전 가동현황 시작시간
    V_BEF_FLAG          INT; --이전 이력 확인 플래그
    V_BEF_FLAG2         INT; --이전 이력 확인 플래그
    V_FLAG              NUMBER := 0; --중복여부 확인
    V_PRFM_DT           VARCHAR2(10);
BEGIN
    --예외처리 시작(try)
    BEGIN
--	    IF P_WRK_DT != TO_CHAR(V_DATE,'YYYYMMDD') THEN
--	    	RS_CODE := 'E';
--            RS_MSG  := '당일의 작업자 등록만 가능합니다.\n작업일을 확인하여 주시기 바랍니다.';
--            RETURN;
--	    END IF;

        -- 현재 작업지시 조회
        BEGIN
            SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, MATNR
              INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, V_MATNR
              FROM TB_WRK011     --작업장(설비)별 현재 진행현황
             WHERE 1=1
               AND WERKS   = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND IN_OUT  = V_IOTYPE ;   --구분  N:미설정 I:투입 O:실적
        EXCEPTION WHEN NO_DATA_FOUND THEN
            --이전 작업지시가 없는 경우 입력
            V_WRK_ORDR_NO := '';
            V_WRK_ORDR_SEQNO := 0;
            --작업장 현황 이력 추가
            INSERT INTO TB_WRK011 ( WERKS, MACH_CD, IN_OUT, MACH_STA, 
                                    REGDATE, REGID )
                        VALUES( P_WERKS, P_MACH_CD, V_IOTYPE, 'N', 
                                V_DATE, P_USERID );
        END;

        --근무시간 Master에서 시작일시 조회
        BEGIN
            SELECT P_WRK_DT || STR_TM
              INTO V_STR_DTM 
              FROM TB_MAS027
             WHERE WERKS    = P_WERKS
               AND MACH_CD  = P_MACH_CD
               AND WRK_METH = P_WRK_TIME ;
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN  
                V_STR_DTM := 'N/A';
        END;

        --시작일시 등록여부 확인
        IF NVL(V_STR_DTM,'N/A') = 'N/A' THEN
            RS_CODE := 'E';
            RS_MSG  := '설비별 작업시간 정보를 등록하여 주시기 바랍니다.';
            RETURN;
        ELSE 
            V_STR_DATE := TO_DATE(V_STR_DTM ||'00','YYYYMMDDHH24MISS');
        END IF;

        --작업장(설비별)투입작업자 관리 중복투입여부 확인
        SELECT COUNT(1)
          INTO V_FLAG
          FROM TB_WRK013    --작업장(설비별)투입작업자 관리
         WHERE 1=1
           AND WERKS    = P_WERKS
           AND MACH_CD  = P_MACH_CD
           AND IN_OUT   = V_IOTYPE
           AND STR_DATE = V_STR_DATE;

        --작업설비 작업관리 table 중복 투입 확인
        IF V_FLAG = 0 THEN

            SELECT COUNT(1)
              INTO V_FLAG
              FROM TB_WRK012    --작업설비 작업 관리
             WHERE 1=1
               AND WERKS    = P_WERKS
               AND MACH_CD  = P_MACH_CD
               AND STR_DATE = V_STR_DATE   -- index 순서가 다름.
               AND IN_OUT   = V_IOTYPE ;

        END IF;

        IF NVL(V_FLAG,0) > 0 THEN
            RS_CODE := 'E';
            RS_MSG  := '선택된 일자 및 시간에 이미 작업자가 등록 되어있습니다.\n다른 작업시간을 선택하거나 작업자 수정을 하길 바랍니다.';
            RETURN;
        END IF;

         -- 설비별 작업장 현황 수정
        UPDATE TB_WRK011
           SET WRK_CLASS = P_WRK_CLASS
             , WRK_SHIFT = P_WRK_TIME
             , EMPLY_NO  = P_WORKER
             , WRKER_CNT = V_WORKERCNT
             , UPDDATE   = V_DATE
             , UPDID     = P_WORKER
         WHERE 1=1
           AND WERKS   = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND IN_OUT  = V_IOTYPE ; 

        --기존이력 여부 확인
        BEGIN
            SELECT COUNT(STR_DATE)
              INTO V_BEF_FLAG
              FROM TB_WRK013
             WHERE 1=1
               AND WERKS   = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND IN_OUT  = V_IOTYPE;
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN  
                V_BEF_FLAG := 0;
        END;

        --기존의 작업자가 투입된 경우 투입자를 변경하여 가동이력 재생성   
        IF V_BEF_FLAG > 0 THEN

            --설비가동이력에서 진행중인 작업이 있는지 확인
            SELECT COUNT(STR_DATE) 
              INTO V_BEF_FLAG
              FROM TB_WRK012
             WHERE 1=1
               AND WERKS    = P_WERKS
               AND MACH_CD  = P_MACH_CD
               AND IN_OUT   = V_IOTYPE
               AND END_DATE IS NULL;

            IF V_BEF_FLAG > 0 THEN   
                --설비별 작업자에서 진행중인 작업을 완료시킴.
                UPDATE TB_WRK013
                   SET END_DATE = V_STR_DATE
                     , UPDDATE  = V_DATE
                     , UPDID    = V_USERID
                 WHERE 1=1
                   AND WERKS    = P_WERKS
                   AND MACH_CD  = P_MACH_CD
                   AND IN_OUT   = V_IOTYPE
                   AND END_DATE IN NULL;

                --이전 가동현황 조회  
                BEGIN
                    SELECT ORDER_NO, ORDER_SEQNO
                         , MATNR, STR_DATE, LINE_STA, ABN_CD
                      INTO V_ORDER_NO, V_ORDER_SEQNO
                         , V_MATNR, V_BEF_STR_DATE, V_LINE_STA, V_ABN_CD
                      FROM (SELECT ORDER_NO, ORDER_SEQNO
                                 , MATNR, STR_DATE, LINE_STA, ABN_CD 
                              FROM TB_WRK012
                             WHERE 1=1
                               AND ROWNUM  = 1
                               AND WERKS   = P_WERKS
                               AND MACH_CD = P_MACH_CD
                               AND IN_OUT  = V_IOTYPE
                               AND END_DATE IS NULL
                             ORDER BY REGDATE DESC );

                EXCEPTION 
                    WHEN NO_DATA_FOUND THEN  
                        V_ORDER_NO      := NULL;
                        V_ORDER_SEQNO   := NULL;
                        V_MATNR         := NULL;
                        V_BEF_STR_DATE  := NULL;
                        V_LINE_STA      := NULL;
                        V_ABN_CD        := NULL;
                END;

                --이전 설비별 가동현황 수정
                UPDATE TB_WRK012
                   SET END_DATE = V_STR_DATE
                     , UPDDATE = V_DATE
                     , UPDID = V_USERID
                 WHERE 1=1
                   AND WERKS   = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IN_OUT  = V_IOTYPE
                   AND END_DATE IS NULL ;
                   --AND STR_DATE = V_BEF_STR_DATE;

                --설비별 가동현황 신규작업자 이력 추가
                SELECT COUNT(STR_DATE) 
                  INTO V_BEF_FLAG2
                  FROM TB_WRK012
                 WHERE 1=1
                   AND WERKS    = P_WERKS
                   AND MACH_CD  = P_MACH_CD
                   AND IN_OUT   = V_IOTYPE
                   AND END_DATE = V_STR_DATE;

                IF V_BEF_FLAG2 > 0 THEN
                    INSERT INTO TB_WRK012 (WERKS, MACH_CD, IN_OUT, STR_DATE, 
                                                WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, ORDER_SEQNO,
                                                MATNR, LINE_STA, BEF_LINE_STA, ABN_CD,
                                                REGDATE, REGID)
                                        VALUES(P_WERKS, P_MACH_CD, V_IOTYPE, V_STR_DATE, 
                                                V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, V_ORDER_SEQNO,
                                                V_MATNR, V_LINE_STA, V_LINE_STA, V_ABN_CD,
                                                V_DATE, V_USERID);
                ELSE
                    RS_CODE := 'E';
                    RS_MSG  := '선택된 일자 및 시간에 이미 작업자가 등록 되어있습니다.\n작업시간을 수정하시거나 작업반 수정을 선택하여 주시기 바랍니다.';
                    RETURN;
                END IF;
            END IF;
        --작업자가 처음 투입된 경우 초기 가동현황 생성
        ELSE
            --이전 설비별 가동현황 수정
            UPDATE TB_WRK012
               SET UPDDATE = V_DATE
                 , UPDID = V_USERID
             WHERE 1=1
               AND WERKS    = P_WERKS
               AND MACH_CD  = P_MACH_CD
               AND IN_OUT   = V_IOTYPE
               AND STR_DATE = V_STR_DATE;

            IF SQL%ROWCOUNT = 0 THEN
                INSERT INTO TB_WRK012 ( WERKS, MACH_CD, IN_OUT, STR_DATE, 
                                        WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, ORDER_SEQNO,
                                        MATNR, LINE_STA, BEF_LINE_STA, ABN_CD, REGDATE, REGID )
                                VALUES( P_WERKS, P_MACH_CD, V_IOTYPE, V_STR_DATE, 
                                        V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, V_ORDER_SEQNO,
                                        V_MATNR, 'N', '', '', V_DATE, V_USERID );
            END IF;

        END IF;

        -- 설비별 작업자 투입현황 등록
        -- 기존 투입이력 완료처리
        UPDATE TB_WRK013 
           SET END_DATE = V_STR_DATE
             , UPDDATE = V_DATE
             , UPDID = V_USERID
         WHERE 1=1
           AND WERKS   = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND IN_OUT  = V_IOTYPE
           AND END_DATE IS NULL;

        --신규 이력 등록
        V_PRFM_DT := FN_RECDATE(V_STR_DATE);

        INSERT INTO TB_WRK013 ( WERKS, MACH_CD, IN_OUT, WRK_ORDR_NO, WRK_ORDR_SEQNO, PRFM_DT
                              , WRK_CLASS, WRK_SHIFT, STR_DATE, EMPLY_NO, WRKER_CNT, LINE_STA
                              , REGDATE, REGID )
                        VALUES(P_WERKS, P_MACH_CD, V_IOTYPE, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_PRFM_DT
                               , P_WRK_CLASS, P_WRK_TIME, V_STR_DATE, P_WORKER, V_WORKERCNT, V_LINE_STA
                               , V_DATE, V_USERID );

        --작업 정상 종료 코드 등록
--         --작업 정상 종료 코드 등록
--             INSERT INTO TB_WRK013_TEMP ( WERKS, MACH_CD, IN_OUT,  REGDATE, REGID )
--                        VALUES(P_WERKS, P_MACH_CD, 'I',  V_DATE, V_USERID );
        RS_CODE := 'S';

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
        E_SQL_ERR_CD        := -20001;
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
