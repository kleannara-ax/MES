--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK75_D01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK75_D01" 
(
    P_WERKS     IN VARCHAR2
    ,P_MACH_CD  IN VARCHAR2
    ,P_IOTYPE   IN VARCHAR2
    ,P_LIST     IN VARCHAR2
    ,P_USERID   IN VARCHAR2
    ,P_ABN_FUNC OUT VARCHAR2 
    ,Lang       IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE    OUT VARCHAR2 
    ,RS_MSG     OUT VARCHAR2
    ,CUR_1      OUT SYS_REFCURSOR
    ,CUR_2      OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK75
 * PROGRAM NAME  : 비가동 이력 조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 선택된 비가동 이력을 취소처리한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/05/04
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/04    1.0.0   김기연         Initial Version 
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK011] : (..U.) 작업장 현황
 * - [TB_WRK013] : (..U.) 작업자 투입 현황
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM			VARCHAR2(100)  := 'SP_POP_WRK75_D01';     -- PROCEDURE NAME
    V_PLT_CD			VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID		VARCHAR2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER	EXCEPTION;
    E_SQL_ERR_CD		NUMBER(5) := 0;
    E_SQL_ERR_MSG		VARCHAR2(4000);
    --내부 변수 등록
    V_DATE				DATE := SYSDATE;
    V_WRK_ORDR_NO		VARCHAR2(20);
    V_WRK_ORDR_SEQ_NO	NUMBER;
    V_ORDER_NO			VARCHAR2(20);
    V_MATNR				VARCHAR2(20);
    V_IOTYPE			VARCHAR2(10) := CASE WHEN P_WERKS = 'P500' THEN 'N' ELSE P_IOTYPE END;
    V_PROC_CD			TB_MAS012.PROC_CD%TYPE;
    V_ORDR_STA			VARCHAR(1); --지시상태
    V_RTN_STA			VARCHAR(1); --복구시 상태
    V_STR_DATE			DATE;
    V_END_DATE			DATE;
    V_IF_ID				VARCHAR2(20) := 'MES_IF_146'; --비가동 등록
    V_SQL				VARCHAR2(4000);
    V_DOC_LIST			VARCHAR2(300); --취소대상 목록
BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            -- 현장 작업장 현황 조회
            SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, MATNR
              INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQ_NO, V_ORDER_NO, V_MATNR
              FROM TB_WRK011
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND IN_OUT = V_IOTYPE;
            --진행중 비가동인 경우 완료처리후 정상이력 추가
            BEGIN 
            SELECT STR_DATE, END_DATE
              INTO V_STR_DATE, V_END_DATE
              FROM TB_WRK012
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND IN_OUT = V_IOTYPE
               AND STR_DATE IN (SELECT TO_DATE(RTN_VALUES,'YYYY-MM-DD HH24:MI:SS') FROM FN_SPLIT(P_LIST,','));
               --AND END_DATE IS NULL;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                V_STR_DATE := '';
            END;  
            BEGIN
				SELECT PROC_CD 
				  INTO V_PROC_CD
				  FROM TB_MAS012
				 WHERE MACH_CD = P_MACH_CD;
			EXCEPTION WHEN NO_DATA_FOUND THEN
				RS_CODE := 'E';
		        RS_MSG  := '해당 설비의 공정이 지정되지 않았습니다.\n기준정보를 확인하여 주시기 바랍니다.';
		        RETURN;
			END;

			IF V_WRK_ORDR_NO IS NULL THEN
                V_ORDR_STA := 'N'; --COMP_YN => N : 대기, I : 진행, Y : 완료
            ELSE
                --지시정보
                IF P_WERKS = 'P100' THEN
                    --제지 지시별 상태 조회
                    IF V_PROC_CD = 'JA' THEN --점보롤
                        SELECT COMP_YN 
                          INTO V_ORDR_STA 
                          FROM TB_SCH015
                         WHERE 1=1
                           AND WRK_ORDR_NO = V_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQ_NO;
                    ELSIF V_PROC_CD = 'MA' THEN --밀롤
                        SELECT MAX(COMP_YN)
                          INTO V_ORDR_STA 
                          FROM TB_SCH016
                         WHERE 1=1
                           AND PRE_ORDER_NO = V_ORDER_NO
                           AND COMP_YN <> 'Y'
                           AND COMP_YN IS NOT NULL;
                        -- 모두 'Y'인경우 예외처리 추가
                    ELSIF V_PROC_CD = 'CA' THEN --재단
                        SELECT COMP_YN
                          INTO V_ORDR_STA 
                          FROM TB_SCH017
                         WHERE 1=1
                           AND PRE_ORDER_NO = V_ORDER_NO;
                    ELSIF V_PROC_CD = 'LP1' THEN --라미네이팅 인쇄코팅
                        SELECT COMP_YN
                          INTO V_ORDR_STA 
                          FROM TB_LAMI_PC
                         WHERE 1=1
                           AND ORDER_NO = V_ORDER_NO;
                    ELSIF V_PROC_CD = 'LS1' THEN --라미네이팅 슬리팅
                        SELECT COMP_YN
                          INTO V_ORDR_STA 
                          FROM TB_LAMI_PC
                         WHERE 1=1
                           AND ORDER_NO = V_ORDER_NO;
                    ELSIF V_PROC_CD = 'PB' OR  V_PROC_CD = 'PC'  OR  V_PROC_CD = 'ZA' THEN --자동포장, 수축포장, 문제재기 적재소
                    	BEGIN
                        SELECT COMP_YN
                          INTO V_ORDR_STA 
                          FROM TB_SCH018
                         WHERE 1=1
                           AND ORDER_NO = V_ORDER_NO;     
                        EXCEPTION WHEN NO_DATA_FOUND THEN
                        	V_ORDR_STA := 'N';
                        END;
                    END IF;                
                ELSIF P_WERKS = 'P200' THEN
                    IF V_PROC_CD = 'AA' THEN --화장지 합지기
                        SELECT COMP_YN 
                          INTO V_ORDR_STA 
                          FROM TB_SCH011
                         WHERE 1=1
                           AND WRK_ORDR_NO = V_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQ_NO;
                    ELSIF V_PROC_CD = 'RA' THEN --화장지 가공기
                        SELECT COMP_YN 
                          INTO V_ORDR_STA 
                          FROM TB_SCH012
                         WHERE 1=1
                           AND WRK_ORDR_NO = V_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQ_NO;
                    ELSE
                        V_ORDR_STA := '';
                    END IF;
                ELSIF P_WERKS = 'P300' THEN
                    IF V_PROC_CD = 'RB' THEN --생리대 가공기
                        SELECT COMP_YN 
                          INTO V_ORDR_STA 
                          FROM TB_SCH013
                         WHERE 1=1
                           AND WRK_ORDR_NO = V_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQ_NO;  
                    ELSE --생리대 예외생산
                        SELECT COMP_YN 
                          INTO V_ORDR_STA 
                          FROM TB_SCH019
                         WHERE 1=1
                           AND WRK_ORDR_NO = V_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQ_NO;
                    END IF;
                ELSIF P_WERKS = 'P500' THEN --기저귀 가공기
                    SELECT COMP_YN 
                      INTO V_ORDR_STA 
                      FROM TB_SCH014
                     WHERE 1=1
                       AND WRK_ORDR_NO = V_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQ_NO;  
                ELSE  --Default
                    V_ORDR_STA := 'I';
                END IF;
            END IF;

            V_RTN_STA := CASE WHEN V_ORDR_STA = 'I' THEN 'R' ELSE 'N' END;

            --현장 작업장 현황 수정
            UPDATE TB_WRK011
               SET MACH_STA = V_RTN_STA
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND IN_OUT = V_IOTYPE;

            -- 비가동 이력 수정
            UPDATE TB_WRK003
               SET RMK = RMK
                 , CNL_YN = 'Y'
                 , CNL_RMK = ' '
                 , END_DATE = STR_DATE
                 , UPDDATE = V_DATE
                 , UPDID = P_USERID
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND IN_OUT = P_IOTYPE
               AND STR_DATE IN (SELECT TO_DATE(RTN_VALUES,'YYYY-MM-DD HH24:MI:SS') FROM FN_SPLIT(P_LIST,','));


            --진행중인 비가동 존재시 처리
            IF V_STR_DATE IS NOT NULL THEN
--                UPDATE TB_WRK012
--                   SET END_DATE = V_STR_DATE
--                     , UPDDATE = V_DATE
--                     , UPDID = P_USERID
--                 WHERE 1=1
--                   AND WERKS = P_WERKS
--                   AND MACH_CD = P_MACH_CD
--                   AND IN_OUT = P_IOTYPE
--                   AND STR_DATE = V_STR_DATE;
                DELETE TB_WRK012
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IN_OUT = V_IOTYPE
                   AND STR_DATE = V_STR_DATE;
--                IF SQL%ROWCOUNT > 0 THEN
--                    INSERT INTO TB_WRK012 (WERKS, MACH_CD, IN_OUT, STR_DATE,
--                                            WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO,
--                                            MATNR, LINE_STA, BEF_LINE_STA,
--                                            REGDATE, REGID)
--                                    VALUES(P_WERKS, P_MACH_CD, V_IOTYPE, V_STR_DATE,
--                                            V_WRK_ORDR_NO, V_WRK_ORDR_SEQ_NO, V_ORDER_NO,
--                                            V_MATNR, 'R', 'S',
--                                            V_DATE, P_USERID);
--                END IF;
                DELETE TB_WRK012
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IN_OUT = V_IOTYPE
                   AND STR_DATE = V_END_DATE;
            END IF;


         	IF P_WERKS != 'P100' OR V_PROC_CD = 'JA' THEN
                --비가동 취소 인터페이스 등록(기존의 비가동 등록정보 전송)
                INSERT INTO TB_IFS016 (WERKS, MACHINE, IFMC, BUDAT, STATM, PRODT, ENDTM, RUNTIME
                                        , ARBPL, WORKGROUP, WORKER, STSCODE, STSTEXT, RSNCODE, RSNTEXT
                                        , REMARK, MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                                SELECT WERKS, MACHINE, IFMC, BUDAT, STATM, PRODT, ENDTM, RUNTIME
                                        , ARBPL, WORKGROUP, MAKER, STSCODE, STSTEXT, RSNCODE, RSNTEXT
                                        , REMARK, MDOCNO, MDOCSEQ, V_DATE, P_USERID
                                  FROM TB_IFS013
                                 WHERE 1=1
                                   AND MDOCNO IN (SELECT DOC_NO
                                                    FROM TB_WRK003
                                                   WHERE 1=1
                                                     AND WERKS = P_WERKS
                                                     AND MACH_CD = P_MACH_CD
                                                     AND IN_OUT = P_IOTYPE
                                                     AND STR_DATE IN (SELECT TO_DATE(RTN_VALUES,'YYYY-MM-DD HH24:MI:SS') FROM FN_SPLIT(P_LIST,',')));

                --취소 목록 조회
                SELECT LISTAGG(DOC_NO,',')
                  INTO V_DOC_LIST
                  FROM TB_WRK003
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IN_OUT = P_IOTYPE
                   AND STR_DATE IN (SELECT TO_DATE(RTN_VALUES,'YYYY-MM-DD HH24:MI:SS') FROM FN_SPLIT(P_LIST,','));

                --SAP FUNC ID
                SELECT RFCFN
                  INTO P_ABN_FUNC
                  FROM TB_ITFMA
                 WHERE 1=1
                   AND IFID = V_IF_ID;

                --인터페이스 파라미터
                OPEN CUR_1 FOR
                SELECT V_IF_ID AS I_IF_ID
                     , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                FROM dual;
                --인터페이스 상세 파라미터
                V_SQL := FN_IF_QUERY(V_IF_ID, V_DOC_LIST);
                IF V_SQL IS NOT NULL THEN
                    OPEN CUR_2 FOR V_SQL;
                END IF;
            END IF;

            IF CUR_1%ISOPEN = FALSE THEN
                OPEN CUR_1 FOR SELECT 1 FROM dual;
            END IF;

            IF CUR_2%ISOPEN = FALSE THEN
                OPEN CUR_2 FOR SELECT 1 FROM dual;
            END IF;

            --작업 정상 종료 코드 등록
            RS_CODE := 'S';
        END;
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
--    WHEN OTHERS THEN
--        E_SQL_ERR_CD        := -20001;
--        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--        ROLLBACK;
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
--
--        RS_CODE := 'E';
--        RS_MSG  := SQLERRM;
--        RETURN;
    --예외처리 종료
    END;
END SP_POP_WRK75_D01;

/
