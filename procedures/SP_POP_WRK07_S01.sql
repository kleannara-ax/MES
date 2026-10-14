
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK07_S01" 
(
    P_WERKS         IN VARCHAR2
    ,P_PROC_CD      IN VARCHAR2
    ,P_MACH_CD      IN VARCHAR2
    ,P_IOTYPE       IN VARCHAR2
    ,P_MACHINE      IN VARCHAR2
    ,P_PRD_STR_DATE IN VARCHAR2     --YYYYMMDD
    ,P_PRD_END_DATE IN VARCHAR2     --YYYYMMDD
    ,P_PCODE        IN VARCHAR2
    ,P_WEIGHT       IN VARCHAR2
    ,P_MATNR        IN VARCHAR2
    ,P_USERID       IN VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK07
 * PROGRAM NAME  : HL 작업지시 목록조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 현재 설비의 작업지시 목록을 조회한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/05/11
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/11    1.0.0   김기연         Initial Version(재작업)
 *==============================================================================
 *  관련 테이블
 * - [TB_SCH002] : (.R..) 화장지 합지기 생산오더
 * - [TB_SCH011] : (.R..) 화장지 합지기 작업지시
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 * - [TB_WRK001] : (.R..) HL 생산실적 이력
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK07_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리
    V_COLINFO VARCHAR2(1000);--컬럼설정1
    V_COLTYPE VARCHAR2(1000);--컬럼설정2
    V_WRK_CD VARCHAR2(8);--설비별 작업장코드
BEGIN
    --예외처리 시작(try)
    BEGIN

        --공정별 조회프로시저 변경
        --화장지 합지기
        IF P_PROC_CD = 'AA' THEN
            --grid 컬럼 정보 설정
            V_COLINFO := '선택@C^50|생산요청일@C^110|생산오더@H|작업지시번호@C^250|작업지시번호@H^200|순번@H|작업순번@R^90|자재코드@C^160|자재명@L^400|규격@H|계획량@R^100|단위@C^70|지시사항@C^300|상세보기@C^100';
            V_COLTYPE := 'CHK@Button|PRD_REQ_DT@varchar|ORDER_NO@varchar|WRK_ORDR_NO_SEQ@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|WRK_SEQNO@varchar|MATNR@varchar|MATNR_NM@varchar|MATNR_SPEC@varchar|WRK_ORDR_QTY@varchar|UNIT@varchar|ORDER_RMK@varchar|DBTN@Button';
            --컬럼설정 반환 테이블 작성
            OPEN CUR_1 FOR
            SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

            --지시목록 조회
            OPEN CUR_2 FOR
            SELECT '-' AS CHK
                 , TO_CHAR(TO_DATE(S011.PRD_REQ_DT,'YYYYMMDD'),'YYYY-MM-DD') AS PRD_REQ_DT       --생산요청일
                 , S011.ORDER_NO            --생산오더
                 , S011.WRK_ORDR_NO || '-' || LPAD(S011.WRK_ORDR_SEQNO,2,'0') AS WRK_ORDR_NO_SEQ --작업지시+순번
                 , S011.WRK_ORDR_NO         --작업지시
                 , S011.WRK_ORDR_SEQNO      --작업지시 순번
                 , S011.WRK_SEQNO           --작업순번
                 , S011.MATNR               --자재코드
                 , M001.MATNR_NM            --자재명
                 , M001.MATNR_SPEC          --규격
                 , TO_CHAR(S011.WRK_ORDR_QTY, 'FM999,999,990') AS WRK_ORDR_QTY --지시수량
                 , S011.UNIT                --단위
                 , S011.WRK_ORDR_RMK AS ORDER_RMK --작업지시사항
                 , '상세보기' AS DBTN    --상세보기
              FROM TB_SCH011 S011, --화장지 합지기 작업지시
                   TB_MAS001 M001 --자재정보
             WHERE 1=1
               AND S011.WERKS = M001.WERKS(+)
               AND S011.MATNR = M001.MATNR(+)
               AND S011.WERKS = P_WERKS
               AND S011.MACH_CD = P_MACH_CD
               AND S011.PRD_REQ_DT >= P_PRD_STR_DATE
               AND S011.PRD_REQ_DT <= P_PRD_END_DATE
               AND NVL(M001.PCODE,' ') LIKE '%' || P_PCODE || '%'
               --AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_WEIGHT || '%'
               AND NVL(S011.MATNR,' ') LIKE '%' || P_MATNR || '%'
               AND S011.COMP_YN != 'Y'
               AND S011.USE_YN = 'Y'
               --AND S011.WRK_CD = V_WRK_CD
             ORDER BY S011.PRD_REQ_DT, S011.WRK_SEQNO, S011.WRK_ORDR_NO, S011.WRK_ORDR_SEQNO;
        --화장지
        ELSIF P_PROC_CD = 'RA' THEN
            --grid 컬럼 정보 설정
            V_COLINFO := '선택@C^50|생산요청일@C^110|생산오더@H|작업지시번호@C^250|작업지시번호@H^200|순번@H|작업순번@R^90|자재코드@C^160|자재명@L^400|규격@H|계획량@R^100|단위@C^70|지시사항@C^300|상세보기@C^100';
            V_COLTYPE := 'CHK@Button|PRD_REQ_DT@varchar|ORDER_NO@varchar|WRK_ORDR_NO_SEQ@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|WRK_SEQNO@varchar|MATNR@varchar|MATNR_NM@varchar|MATNR_SPEC@varchar|WRK_ORDR_QTY@varchar|UNIT@varchar|ORDER_RMK@varchar|DBTN@Button';
            --컬럼설정 반환 테이블 작성
            OPEN CUR_1 FOR
            SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

            --지시목록 조회
            OPEN CUR_2 FOR
            SELECT '-' AS CHK
                 , TO_CHAR(TO_DATE(S012.PRD_REQ_DT,'YYYYMMDD'),'YYYY-MM-DD') AS PRD_REQ_DT       --생산요청일
                 , S012.ORDER_NO            --생산오더
                 , S012.WRK_ORDR_NO || '-' || LPAD(S012.WRK_ORDR_SEQNO,2,'0') AS WRK_ORDR_NO_SEQ --작업지시+순번
                 , S012.WRK_ORDR_NO         --작업지시
                 , S012.WRK_ORDR_SEQNO      --작업지시 순번
                 , S012.WRK_SEQNO           --작업순번
                 , S012.MATNR               --자재코드
                 , M001.MATNR_NM            --자재명
                 , M001.MATNR_SPEC          --규격
                 , TO_CHAR(S012.WRK_ORDR_QTY, 'FM999,999,990') AS WRK_ORDR_QTY        --지시수량
                 , S012.UNIT                --단위
                 , S012.WRK_ORDR_RMK AS ORDER_RMK --작업지시사항
                 , '상세보기' AS DBTN    --상세보기
              FROM TB_SCH012 S012, --화장지 가공기 작업지시
                   TB_MAS001 M001 --자재정보
             WHERE 1=1
               AND S012.WERKS = M001.WERKS(+)
               AND S012.MATNR = M001.MATNR(+)
               AND S012.WERKS = P_WERKS
               AND S012.MACH_CD = P_MACH_CD
               AND S012.PRD_REQ_DT >= P_PRD_STR_DATE
               AND S012.PRD_REQ_DT <= P_PRD_END_DATE
               AND S012.COMP_YN != 'Y'
               AND S012.USE_YN = 'Y'
               AND NVL(M001.PCODE,' ') LIKE '%' || P_PCODE || '%'
--               AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_WEIGHT || '%'
               AND NVL(S012.MATNR,' ') LIKE '%' || P_MATNR || '%'
               AND ((P_IOTYPE = 'O' 
                        AND S012.WRK_ORDR_NO IN (SELECT WRK_ORDR_NO FROM TB_WRK011 WHERE MACH_CD = P_MACH_CD)
                        AND S012.COMP_YN = 'I')
                    OR P_IOTYPE != 'O')
             ORDER BY S012.PRD_REQ_DT, S012.WRK_SEQNO, S012.WRK_ORDR_NO, S012.WRK_ORDR_SEQNO;
        --생리대
        ELSIF P_PROC_CD = 'RB' THEN
            --grid 컬럼 정보 설정
            V_COLINFO := '선택@C^50|생산요청일@C^110|생산오더@H|작업지시번호@C^250|작업지시번호@H^200|순번@H|작업순번@R^90|자재코드@C^160|자재명@L^400|규격@H|계획량@R^100|단위@C^70|지시사항@C^300|상세보기@C^100';
            V_COLTYPE := 'CHK@Button|PRD_REQ_DT@varchar|ORDER_NO@varchar|WRK_ORDR_NO_SEQ@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|WRK_SEQNO@varchar|MATNR@varchar|MATNR_NM@varchar|MATNR_SPEC@varchar|WRK_ORDR_QTY@varchar|UNIT@varchar|ORDER_RMK@varchar|DBTN@Button';
            --컬럼설정 반환 테이블 작성
            OPEN CUR_1 FOR
            SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

            --지시목록 조회
            OPEN CUR_2 FOR
            SELECT '-' AS CHK
                 , TO_CHAR(TO_DATE(S013.PRD_REQ_DT,'YYYYMMDD'),'YYYY-MM-DD') AS PRD_REQ_DT       --생산요청일
                 , S013.ORDER_NO            --생산오더
                 , S013.WRK_ORDR_NO || '-' || LPAD(S013.WRK_ORDR_SEQNO,2,'0') AS WRK_ORDR_NO_SEQ --작업지시+순번
                 , S013.WRK_ORDR_NO         --작업지시
                 , S013.WRK_ORDR_SEQNO      --작업지시 순번
                 , S013.WRK_SEQNO           --작업순번
                 , S013.MATNR               --자재코드
                 , M001.MATNR_NM            --자재명
                 , M001.MATNR_SPEC          --규격
                 , TO_CHAR(S013.WRK_ORDR_QTY, 'FM999,999,990') AS WRK_ORDR_QTY        --지시수량
                 , S013.UNIT                --단위
                 , S013.WRK_ORDR_RMK AS ORDER_RMK --작업지시사항
                 , '상세보기' AS DBTN    --상세보기
              FROM TB_SCH013 S013, --화장지 가공기 작업지시
                   TB_MAS001 M001 --자재정보
             WHERE 1=1
               AND S013.WERKS = M001.WERKS(+)
               AND S013.MATNR = M001.MATNR(+)
               AND S013.WERKS = P_WERKS
               AND S013.MACH_CD = P_MACH_CD
               AND S013.PRD_REQ_DT >= P_PRD_STR_DATE
               AND S013.PRD_REQ_DT <= P_PRD_END_DATE
               AND S013.COMP_YN != 'Y'
               AND S013.USE_YN = 'Y'
               AND NVL(M001.PCODE,' ') LIKE '%' || P_PCODE || '%'
               AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_WEIGHT || '%'
               AND NVL(S013.MATNR,' ') LIKE '%' || P_MATNR || '%'
               AND ((P_IOTYPE = 'O' 
                        AND S013.WRK_ORDR_NO IN (SELECT WRK_ORDR_NO FROM TB_WRK011 WHERE MACH_CD = P_MACH_CD)
                        AND S013.COMP_YN = 'I')
                    OR P_IOTYPE != 'O')
             ORDER BY S013.PRD_REQ_DT, S013.WRK_SEQNO, S013.WRK_ORDR_NO, S013.WRK_ORDR_SEQNO;            
        --기저귀
        ELSIF P_PROC_CD = 'RC' THEN
            --grid 컬럼 정보 설정
            V_COLINFO := '선택@C^50|생산요청일@C^110|생산오더@H|작업지시번호@C^250|작업지시번호@H^200|순번@H|작업순번@R^90|자재코드@C^160|자재명@L^400|규격@H|계획량@R^100|단위@C^70|지시사항@C^300|상세보기@C^100';
            V_COLTYPE := 'CHK@Button|PRD_REQ_DT@varchar|ORDER_NO@varchar|WRK_ORDR_NO_SEQ@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|WRK_SEQNO@varchar|MATNR@varchar|MATNR_NM@varchar|MATNR_SPEC@varchar|WRK_ORDR_QTY@varchar|UNIT@varchar|ORDER_RMK@varchar|DBTN@Button';
            --컬럼설정 반환 테이블 작성
            OPEN CUR_1 FOR
            SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

            --지시목록 조회
            OPEN CUR_2 FOR
            SELECT '-' AS CHK
                 , TO_CHAR(TO_DATE(S014.PRD_REQ_DT,'YYYYMMDD'),'YYYY-MM-DD') AS PRD_REQ_DT       --생산요청일
                 , S014.ORDER_NO            --생산오더
                 , S014.WRK_ORDR_NO || '-' || LPAD(S014.WRK_ORDR_SEQNO,2,'0') AS WRK_ORDR_NO_SEQ --작업지시+순번
                 , S014.WRK_ORDR_NO         --작업지시
                 , S014.WRK_ORDR_SEQNO      --작업지시 순번
                 , S014.WRK_SEQNO           --작업순번
                 , S014.MATNR               --자재코드
                 , M001.MATNR_NM            --자재명
                 , M001.MATNR_SPEC          --규격
                 , TO_CHAR(S014.WRK_ORDR_QTY, 'FM999,999,990') AS WRK_ORDR_QTY        --지시수량
                 , S014.UNIT                --단위
                 , S014.WRK_ORDR_RMK AS ORDER_RMK --작업지시사항
                 , '상세보기' AS DBTN    --상세보기
              FROM TB_SCH014 S014, --화장지 가공기 작업지시
                   TB_MAS001 M001 --자재정보
             WHERE 1=1
               AND S014.WERKS = M001.WERKS(+)
               AND S014.MATNR = M001.MATNR(+)
               AND S014.WERKS = P_WERKS
               AND S014.MACH_CD = P_MACH_CD
               AND S014.PRD_REQ_DT >= P_PRD_STR_DATE
               AND S014.PRD_REQ_DT <= P_PRD_END_DATE
               AND S014.COMP_YN != 'Y'
               AND S014.USE_YN = 'Y'
               AND NVL(M001.PCODE,' ') LIKE '%' || P_PCODE || '%'
               AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_WEIGHT || '%'
               AND NVL(S014.MATNR,' ') LIKE '%' || P_MATNR || '%'
               --포장기에서 문서 완료처리를 위하여 조회제한 삭제
--               AND ((P_IOTYPE = 'O' AND S014.WRK_ORDR_NO IN (SELECT WRK_ORDR_NO FROM TB_WRK011 WHERE MACH_CD = P_MACH_CD))
--                    OR P_IOTYPE != 'O')
             ORDER BY S014.PRD_REQ_DT, S014.WRK_SEQNO, S014.WRK_ORDR_NO, S014.WRK_ORDR_SEQNO;
        ELSE --예외 생산
            --grid 컬럼 정보 설정
            V_COLINFO := '선택@C^70|생산요청일@C^120|생산오더@H|작업지시번호@C^220|작업지시번호@H^150|순번@H|작업순번@R^90|자재코드@C^160|자재명@L^400|규격@H|계획량@R^100|단위@C^70|지시사항@H^300|상세보기@H^100';
            V_COLTYPE := 'CHK@Button|PRD_REQ_DT@varchar|ORDER_NO@varchar|WRK_ORDR_NO_SEQ@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|WRK_SEQNO@varchar|MATNR@varchar|MATNR_NM@varchar|MATNR_SPEC@varchar|WRK_ORDR_QTY@varchar|UNIT@varchar|ORDER_RMK@varchar|DBTN@Button';
            --컬럼설정 반환 테이블 작성
            OPEN CUR_1 FOR
            SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

            --지시목록 조회
            OPEN CUR_2 FOR
            SELECT '-' AS CHK
                 , TO_CHAR(TO_DATE(S019.PRD_REQ_DT,'YYYYMMDD'),'YYYY-MM-DD') AS PRD_REQ_DT       --생산요청일
                 , S019.ORDER_NO            --생산오더
                 , S019.WRK_ORDR_NO || '-' || LPAD(S019.WRK_ORDR_SEQNO,2,'0') AS WRK_ORDR_NO_SEQ --작업지시+순번
                 , S019.WRK_ORDR_NO         --작업지시
                 , S019.WRK_ORDR_SEQNO      --작업지시 순번
                 , S019.WRK_SEQNO           --작업순번
                 , S019.MATNR               --자재코드
                 , M001.MATNR_NM            --자재명
                 , M001.MATNR_SPEC          --규격
                 , TO_CHAR(S019.WRK_ORDR_QTY, 'FM999,999,990') AS WRK_ORDR_QTY        --지시수량
                 , S019.UNIT                --단위
                 , WRK_ORDR_REMARK AS ORDER_RMK --작업지시사항
                 , '상세보기' AS DBTN    --상세보기
              FROM TB_SCH019 S019, --화장지 가공기 작업지시
                   TB_MAS001 M001 --자재정보
             WHERE 1=1
               AND S019.WERKS = M001.WERKS(+)
               AND S019.MATNR = M001.MATNR(+)
               AND S019.WERKS = P_WERKS
               --AND S019.MACH_CD = P_MACH_CD
               AND S019.PRD_REQ_DT >= P_PRD_STR_DATE
               AND S019.PRD_REQ_DT <= P_PRD_END_DATE
               AND S019.COMP_YN != 'Y'
               AND S019.USE_YN = 'Y'
               AND NVL(M001.PCODE,' ') LIKE '%' || P_PCODE || '%'
               AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_WEIGHT || '%'
               AND NVL(S019.MATNR,' ') LIKE '%' || P_MATNR || '%'
             ORDER BY S019.PRD_REQ_DT, S019.WRK_SEQNO, S019.WRK_ORDR_NO, S019.WRK_ORDR_SEQNO;     
        END IF;
        --작업 정상 종료 코드 등록
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
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END SP_POP_WRK07_S01;
/
