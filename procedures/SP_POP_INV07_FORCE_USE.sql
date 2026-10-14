
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_INV07_FORCE_USE" 
(
    P_WERKS             IN VARCHAR2
    ,P_MATNR            IN VARCHAR2 DEFAULT ''
    ,P_MACH_CD          IN VARCHAR2
    ,P_PRD_STR_DT       IN VARCHAR2
    ,P_PRD_END_DT       IN VARCHAR2
    ,P_WRK_ORDR_NO      IN VARCHAR2
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2
    ,P_USERID           IN VARCHAR2
    ,P_TYPE             IN VARCHAR2
    ,RS_SINPUT_RFCFN    OUT VARCHAR2                    --사용량(투입량) RFCFN값
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2
    ,RS_MSG             OUT VARCHAR2
    ,CUR_1              OUT SYS_REFCURSOR
    ,CUR_2              OUT SYS_REFCURSOR
    ,CUR_3              OUT SYS_REFCURSOR
    ,CUR_4              OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_INV07_FORCE_USE
 * PROGRAM NAME  : 수재단(예외), 포장(예외) 완료 미처리 이력조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 수재단(예외), 포장(예외) 완료건 중 재고량미처리건에 대해 조회 및 사용처리
 *
 * AUTHOR NAME   : 김지언
 * CREATE DATE   : 2025/04/07
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description
 * ------------ ------- ------------- ------------------------------------------
 * 2025/04/07    1.0.0      김지언         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK002] : (.R..) PS 실적정보
 * - [TB_INV003] : (.R..) 자재투입 정보
 *=============================================================================*/
AS
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_INV07_FORCE_USE';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := P_USERID; --USERID

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    --파라미터 처리
--     V_PRD_STR_DT DATE := TO_DATE(P_PRD_STR_DT,'YYYYMMDD');
--     V_PRD_END_DT DATE := TO_DATE(P_PRD_END_DT,'YYYYMMDD') + INTERVAL '1' DAY; --시간정보 누락으로 인한 보정

    --내부변수 관리
    V_COLINFO VARCHAR2(1000);
    V_COLTYPE VARCHAR2(1000);

    V_DATE                DATE := SYSDATE;
    V_MATNR_M             TB_INV003.MATNR%TYPE := P_MATNR;
    V_IND_BCD_M           TB_INV003.IND_BCD%TYPE;
    V_SEQNO               TB_INV003.SEQNO%TYPE;
    V_LOT_NO_M            TB_INV003.LOT_NO%TYPE;
    V_IN_QTY              TB_INV003.IN_QTY%TYPE;
    V_STCK_QTY            TB_INV003.STCK_QTY%TYPE;
    V_UNIT                TB_INV003.UNIT%TYPE;
    V_WGT                 TB_INV003.WGT%TYPE;
    V_PRE_IN_QTY          TB_INV003.PRE_IN_QTY%TYPE;

    V_MATNR               TB_WRK022.MATNR%TYPE;
    V_IND_BCD             TB_WRK022.IND_BCD%TYPE;
    V_LOT_NO              TB_WRK022.LOT_NO%TYPE;
    V_USE_QTY             TB_INV010.USE_QTY%TYPE;
    V_WRK_CLASS           TB_WRK022.WRK_CLASS%TYPE;
    V_WRK_SHIFT           TB_WRK022.WRK_SHIFT%TYPE;

    V_DOC_NO              TB_IFS008.MDOCNO%TYPE;
    V_DOC_SEQNO           TB_IFS008.MDOCSEQ%TYPE;
    V_ORDER_NO            TB_IFS008.AUFNR%TYPE;
    V_ORDER_SEQ           TB_IFS008.POSNR%TYPE;

    V_STOR_LOC_CD         VARCHAR2(10);
    V_SAP_WRK_CD          TB_MAS012.SAP_WRK_CD%TYPE;          --SAP작업장코드

    V_SQL                 VARCHAR2(4000);
BEGIN
    --예외처리 시작(try)
    BEGIN
        IF P_TYPE = 'LIST' THEN  /* 그리드 조회 */
            --컬럼설정
            V_COLINFO := '선택@C^50|순번@R^50|설비코드@C^80|작업지시@C^210|자재코드@C^200|자재명@L^340|투입량@R^100|실적량@R^100|잔량@R^100|단위@R^50|비고@R^230|생산일@C^160|완료여부@C^80|작업지시seq@C^0';
            V_COLTYPE := 'CHK@Button|SEQ@varchar|MACH_CD@varchar|WRK_ORDR_NO@varchar|MATNR@varchar|MATNR_NM@varchar|SUM_IN_QTY@varchar|SUM_USE_QTY@varchar|SUM_STCK_QTY@varchar|UNIT@varchar|AUARTXT@varchar|PRD_DT@varchar|COMP_YN@varchar|WRK_ORDR_SEQNO@varchar';
            --컬럼설정 반환 테이블 작성
            OPEN CUR_1 FOR
            SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

            --결과 테이블 반환용 변수
            OPEN CUR_2 FOR

            --수재단(예외) 완료 잔량 목록 조회
            WITH TB_INPUT_SUM AS (
                SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO
                     , SUM(STCK_QTY)    AS SUM_STCK_QTY
                     , SUM(IN_QTY)      AS SUM_IN_QTY
                     , SUM(USE_QTY)     AS SUM_USE_QTY
                     , UNIT
                     , MACH_CD
                FROM TB_INV003 I003
                    WHERE 1=1
--                         AND I003.WRK_ORDR_NO LIKE '%' || P_WRK_ORDR_NO || '%' -- 테스트용 
--                         AND SUBSTR(INP_DT, 1, 6) IN (
--                                TO_CHAR(SYSDATE, 'YYYYMM'),
--                                TO_CHAR(ADD_MONTHS(SYSDATE, -1), 'YYYYMM')
--     )
                      AND SUBSTR(INP_DT, 1, 6) = TO_CHAR(SYSDATE, 'YYYYMM')
                        AND I003.WERKS = P_WERKS
                        AND WRK_ORDR_NO LIKE 'WOEX%'
                        AND (UNIT = 'KG' OR UNIT = 'R')
                        AND STCK_QTY > 0.002
                GROUP BY WRK_ORDR_NO, WRK_ORDR_SEQNO, UNIT, MACH_CD
            )
            SELECT '-' AS CHK                           --체크버튼
                 , ROW_NUMBER() OVER (ORDER BY PRD_END_DTM DESC) AS SEQ                     --순번
                 , TIS.MACH_CD                          --설비호기
                 , S019.WRK_ORDR_NO || '-' || LPAD(S019.WRK_ORDR_SEQNO,2,'0') AS WRK_ORDR_NO --작업지시
                 , S019.MATNR                           --자재코드
                 , M001.MATNR_NM                        --자재명
                 , TIS.SUM_IN_QTY                       --투입량
                 , TIS.SUM_USE_QTY                      --사용량
                 , TIS.SUM_STCK_QTY                     --잔량
                 , TIS.UNIT                             --단위
                 , S019.AUARTXT                         --오더유형 텍스트
                 , TO_DATE(SUBSTR(PRD_END_DTM, 0, 8), 'YYYY-MM-DD') AS PRD_DT    --생산완료일시
                 , S019.COMP_YN                          --지시완료여부
                 , S019.WRK_ORDR_SEQNO                  --작업지시seq
            FROM TB_SCH019 S019
                INNER JOIN TB_INPUT_SUM TIS ON TIS.WRK_ORDR_NO = S019.WRK_ORDR_NO AND TIS.WRK_ORDR_SEQNO = S019.WRK_ORDR_SEQNO
                LEFT OUTER JOIN TB_MAS001 M001 on S019.MATNR = M001.MATNR
            WHERE 1=1
                AND (TIS.MACH_CD like 'PCB%' AND NVL(COMP_YN, 'N') = 'Y'
                    OR TIS.MACH_CD IS NOT NULL
                )
                AND S019.WERKS = P_WERKS
                AND S019.WRK_ORDR_NO LIKE '%' || P_WRK_ORDR_NO || '%'
--                 AND TO_DATE(SUBSTR(PRD_END_DTM, 0, 8), 'YYYY-MM-DD') BETWEEN P_PRD_STR_DT AND P_PRD_END_DT
                AND TIS.SUM_STCK_QTY > 0
            ORDER BY SEQ;

        ELSIF P_TYPE = 'FORCE_USE' THEN /* 폐품처리를 위한 테이블 INSERT */
            V_STOR_LOC_CD := '2000'; -- 저장위치(불출받아서 사용하는것이므로 2000으로 고정)
            V_DOC_SEQNO := 1;        -- 문서번호 SEQ

            -- 설비정보 조회
            SELECT SAP_WRK_CD
                INTO V_SAP_WRK_CD
            FROM TB_MAS012
            WHERE 1=1
                AND MACH_CD = P_MACH_CD;

            -- WRK002 생산자재 정보
            SELECT MAX(IND_BCD), WRK_CLASS, WRK_SHIFT
                INTO V_IND_BCD, V_WRK_CLASS, V_WRK_SHIFT
            FROM TB_WRK002
            WHERE 1=1
                AND WERKS               = P_WERKS
                AND WRK_ORDR_NO         = P_WRK_ORDR_NO
                AND NVL(CNL_YN, 'N')    = 'N'
            GROUP BY WRK_CLASS, WRK_SHIFT;

            DECLARE
                CURSOR c_i003 IS
                    -- 투입정보 조회
                    SELECT IND_BCD,
                           LOT_NO,
                           MATNR,
                           IN_QTY,
                           STCK_QTY,
                           WGT,
                           PRE_IN_QTY
                    FROM TB_INV003
                    WHERE 1=1
		                AND WERKS           = P_WERKS
		                AND MACH_CD         = P_MACH_CD
		                AND WRK_ORDR_NO     = P_WRK_ORDR_NO
		                AND WRK_ORDR_SEQNO  = P_WRK_ORDR_SEQNO
		                AND STCK_QTY > 0;
                BEGIN
                FOR r IN c_i003 LOOP
                    begin
SZP_MES_PLSQL_LOG('r.IND_BCD : ' || r.IND_BCD, 'INV07_FORCE_USE');
SZP_MES_PLSQL_LOG('r.LOT_NO : ' || r.LOT_NO, 'INV07_FORCE_USE');
                    SELECT MATNR, LOT_NO
                        INTO V_MATNR, V_LOT_NO
                    FROM TB_INV010
                    where 1=1
--                         AND NVL(CNL_YN, 'N') ='N' --사용이력이 없는경우 오류발생하여 일단풀어놓음 260401
                        and LOT_NO_M = r.LOT_NO
                        and IND_BCD_M = r.IND_BCD
                        AND ROWNUM = 1;

                    --개별바코드
                    -- 필수 변수 대입
                    V_IND_BCD_M := r.IND_BCD;
                    V_MATNR_M := r.MATNR;
--                     V_IND_BCD := FN_INCB_CODE(V_IND_BCD);
                    --개별 바코드
                    SP_GET_BARCODE_SEQ('IND', P_WERKS, 'U', P_MATNR, TO_CHAR(V_DATE,'YYYY-MM-DD HH24:MI:SS'), V_IND_BCD);
                    V_LOT_NO_M := r.LOT_NO;
                    V_IN_QTY := r.IN_QTY;
                    V_STCK_QTY := r.STCK_QTY;
                    V_WGT := r.WGT;
                    V_PRE_IN_QTY := r.PRE_IN_QTY;


SZP_MES_PLSQL_LOG('r.IND_BCD : ' || r.IND_BCD, 'INV07_FORCE_USE');
SZP_MES_PLSQL_LOG('V_IND_BCD : ' || V_IND_BCD, 'INV07_FORCE_USE');
SZP_MES_PLSQL_LOG('V_LOT_NO_M : ' || V_LOT_NO_M, 'INV07_FORCE_USE');

                    DBMS_OUTPUT.PUT_LINE('재단 개별바코드 V_IND_BCD : ' || V_IND_BCD);
                    DBMS_OUTPUT.PUT_LINE('재단 자재 P_MATNR : ' || P_MATNR);
                    DBMS_OUTPUT.PUT_LINE('재단 자재 V_MATNR : ' || V_MATNR);

                    DBMS_OUTPUT.PUT_LINE('투입 개별바코드 V_IND_BCD_M : ' || V_IND_BCD_M);
                    DBMS_OUTPUT.PUT_LINE('투입 자재 V_MATNR_M : ' || V_MATNR_M);
                    DBMS_OUTPUT.PUT_LINE('투입 LOTNO V_LOT_NO_M : ' || V_LOT_NO_M);
                    DBMS_OUTPUT.PUT_LINE('투입 투입량 V_IN_QTY : ' || V_IN_QTY);
                    DBMS_OUTPUT.PUT_LINE('투입 재고량 V_STCK_QTY : ' || V_STCK_QTY);
                    DBMS_OUTPUT.PUT_LINE('투입 중량 V_WGT : ' || V_WGT);
                    DBMS_OUTPUT.PUT_LINE('투입 투입연수 V_PRE_IN_QTY : ' || V_PRE_IN_QTY);

                    BEGIN
                    -- 생산오더번호 조회(예외)
                        SELECT ORDER_NO, ORDER_ITM_NO, UNIT
                            INTO V_ORDER_NO, V_ORDER_SEQ, V_UNIT
                        FROM TB_SCH020
                        WHERE 1=1
                            AND WRK_ORDR_NO     = P_WRK_ORDR_NO
                            AND WRK_ORDR_SEQNO  = P_WRK_ORDR_SEQNO
                            AND LOT_NO          = V_LOT_NO_M;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            SZP_MES_PLSQL_LOG('TB_SCH020에서 데이터가 없습니다.', 'INV07_FORCE_USE');
                            DBMS_OUTPUT.PUT_LINE('TB_SCH020에서 데이터가 없습니다.');
                        CONTINUE;
                        WHEN TOO_MANY_ROWS THEN
                            SZP_MES_PLSQL_LOG('TB_SCH020에서 다중 행이 반환되었습니다.', 'INV07_FORCE_USE');
                            DBMS_OUTPUT.PUT_LINE('TB_SCH020에서 다중 행이 반환되었습니다.');
                        CONTINUE;
                    END;

--                     -- 체크필요
                    -- 투입연수 계산 (KG -> R)
                    V_USE_QTY := (V_STCK_QTY / (V_IN_QTY / V_PRE_IN_QTY));

                    -- 문서번호 생성
                    V_DOC_NO := FN_GET_MDOCNO('M','IF130');

--                  폐품처리아니고 사용처리로 변경해야함
                    --자재 투입이력
                    INSERT INTO TB_INV010( WERKS, MACH_CD, MATNR, IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                        LOT_NO, IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, PRFM_DT,
                                        USE_QTY, UNIT, ROLLCNT, WGT, CHG_FLG, STCK_KY, LOT_NUM,
                                        REGDATE, REGID, USE_DIV, DOC_NO, DOC_SEQNO)
                                VALUES(P_WERKS, P_MACH_CD, V_MATNR, V_IND_BCD, 1, P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO,
                                        V_LOT_NO, V_IND_BCD_M, V_LOT_NO_M, V_MATNR_M, TO_CHAR(V_DATE, 'YYYYMMDD'), TO_CHAR(V_DATE, 'YYYYMMDD'),
                                        V_USE_QTY, V_UNIT, 0, V_WGT, 'N', '', '',
                                        V_DATE, P_USERID, '1', V_DOC_NO, V_DOC_SEQNO);

                    IF SQL%ROWCOUNT = 0 THEN
                        SZP_MES_PLSQL_LOG('TB_INV010 insert 실패', 'INV07_FORCE_USE');
                    end if;

                    --확인필요
                    -- 디버그해서 확인필요함
                    INSERT INTO TB_IFS008(AUFNR, POSNR, BUDAT, MATNR, MENGE, LGORT, CHARG,
                                              MDOCNO, MDOCSEQ, MAKE_DATE, MAKER, WORKCENTERCODE, WERKS)
                                    VALUES( V_ORDER_NO, V_ORDER_SEQ, TO_CHAR(V_DATE, 'YYYYMMDD'), V_MATNR_M, V_USE_QTY, V_STOR_LOC_CD, V_LOT_NO_M,
                                            V_DOC_NO, V_DOC_SEQNO, V_DATE, P_USERID, V_SAP_WRK_CD, P_WERKS);

                    IF SQL%ROWCOUNT = 0 THEN
                        SZP_MES_PLSQL_LOG('TB_IFS008 insert 실패', 'INV07_FORCE_USE');
                    end if;

                    -- 재고 소진처리
                    UPDATE TB_INV003
                        SET USE_QTY = IN_QTY
                        , STCK_QTY  = 0
                        , RMK       = '[예외오더]사용처리'
                        , UPDDATE   = SYSDATE
                        , UPDID     = P_USERID
                    WHERE WERKS = P_WERKS
                        AND MACH_CD = P_MACH_CD
                        AND IND_BCD = V_IND_BCD_M;

                    IF SQL%ROWCOUNT = 0 THEN
                        SZP_MES_PLSQL_LOG('TB_INV003 update 실패', 'INV07_FORCE_USE');
                    end if;

                    -- 문서이력(5=투입자재 소요량)
                    -- 1=실적, 2=생산폐품, 3=영업폐품, 4=잔량폐품, 5=투입자재 소요량, 6=재고이전(위치), 7=재고이전(자재변경), 8=재고이전(재고실사), 9=LOT변경, 10=등급변경, 11=LOT병합, 12=LIFT출고, 20=오더완료
                    INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD,
                                        WRK_ORDR_NO, WRK_ORDR_SEQNO, IND_BCD, LOT_NO, ORDER_NO,
                                        CNL_YN, REGDATE, REGID )
                                VALUES( V_DOC_NO, V_DOC_SEQNO, 5, P_WERKS, P_MACH_CD,
                                        P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO, V_IND_BCD, V_LOT_NO, V_ORDER_NO,
                                        'N', V_DATE, P_USERID );

                    IF SQL%ROWCOUNT = 0 THEN
                        SZP_MES_PLSQL_LOG('TB_WRK021 insert 실패', 'INV07_FORCE_USE');
                    end if;

                    -- LOT 추적(사용이후 추가잔량사용이므로 seq 2로)
                    INSERT INTO TB_WRK008(WERKS, IND_BCD, IND_BCD_M, SEQNO, LOT_NO,
                                        MATNR, LOT_NO_M, MATNR_M, UNIT, PRFM_QTY, USE_QTY,
                                        WRK_ORDR_NO, WRK_ORDR_SEQNO, SUB_WRK_ORDR_NO, SUB_WRK_ORDR_SEQNO,
                                        MACH_CD, REGDATE, REGID)
                                VALUES(P_WERKS, V_IND_BCD, V_IND_BCD_M, 2, V_LOT_NO,
                                        V_MATNR, V_LOT_NO_M, V_MATNR, V_UNIT, V_WGT, V_STCK_QTY,
                                        P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO, P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO,
                                        P_MACH_CD, V_DATE, P_USERID);

                    IF SQL%ROWCOUNT = 0 THEN
                        SZP_MES_PLSQL_LOG('TB_WRK008 insert 실패', 'INV07_FORCE_USE');
                    end if;

                    EXCEPTION
                        WHEN OTHERS THEN
                            SZP_MES_PLSQL_LOG('알 수 없는 오류: ' || SQLERRM, 'INV07_FORCE_USE');
                            DBMS_OUTPUT.PUT_LINE('알 수 없는 오류: ' || SQLERRM);
                        CONTINUE;
                    END;
                END LOOP;
            END;
        END IF;

        SZP_MES_PLSQL_LOG('V_DOC_NO : ' || V_DOC_NO, 'INV07_FORCE_USE');
        IF LENGTH(V_DOC_NO) > 0   THEN    -- 투입(사용)
            --SAP FUNC ID
            SELECT RFCFN
              INTO RS_SINPUT_RFCFN
              FROM TB_ITFMA
             WHERE 1=1
               AND IFID = 'MES_IF_130';   --생산오더별 실적 취소 TXN

            SZP_MES_PLSQL_LOG('RS_SINPUT_RFCFN : ' || RS_SINPUT_RFCFN, 'INV07_FORCE_USE');
            --인터페이스 파라미터
            OPEN CUR_3 FOR
            SELECT 'MES_IF_130' AS I_IF_ID
                 , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
              FROM dual;

            --인터페이스 상세 파라미터
            V_SQL := FN_IF_QUERY('MES_IF_130', V_DOC_NO);
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

        --작업 정상 종료 코드 등록
        RS_CODE := 'S';
        SZP_MES_PLSQL_LOG(RS_CODE, 'INV07_FORCE_USE');
    --예외처리(catch)
    EXCEPTION
    WHEN E_EXCEPTION_USER THEN
        -- 에러 내역 SET
        E_SQL_ERR_CD        := -20000;
        E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    WHEN OTHERS THEN
        E_SQL_ERR_CD        := -20000;
        E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END;
/
