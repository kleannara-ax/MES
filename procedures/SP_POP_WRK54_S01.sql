
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK54_S01" SP_POP_WRK54_S01
(
    P_WERKS         IN VARCHAR2 
    ,P_MACH_CD      IN VARCHAR2
    ,P_WRK_DT       IN VARCHAR2
    ,P_USERID       IN VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK54
 * PROGRAM NAME  : 판매용 원단 생산실적 이력조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 생산실적 이력을 조회한다.
 *                 
 * AUTHOR NAME   : 백우종
 * CREATE DATE   : 2023/03/01
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/03/01    1.0.0   백우종          Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK001] : (.R..) HL 생산실적
 * - [TB_SCH011] : (.R..) 합지기 작업지시
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK54_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --파라미터 처리
    --내부변수 관리
    V_COLINFO VARCHAR2(1000);
    V_COLTYPE VARCHAR2(1000);
    V_PRTINFO VARCHAR2(1000); --라벨출력정보 항목
    V_PRTTYPE VARCHAR2(1000); --라벨출력정보 항목

BEGIN
    --예외처리 시작(try)
    BEGIN
        --라벨 출력정보 작성하여 그리드 정보에 추가
        V_PRTINFO := '|설비호기명@H|자재명@H|평량@H|색상@H|작업자명@H|판정@H';
        V_PRTTYPE := '|MACH_NM@varchar|MATNR_NM@varchar|BS_WGT@varchar|COLOR@varchar|WRK_NAME@varchar|QCJUD@varchar';
        --컬럼설정
        V_COLINFO := '선택@C^60|품목@L^150|품목명@L^350|LOT번호@C^140|개별바코드@C^180|지폭@C^60|실적길이@R^60|중량@R^120|비고@H|등록자ID@H|등록자@C^120'||V_PRTINFO;
        V_COLTYPE := 'CHK@Button|MATNR@varchar|MATNR_NMG@varchar|LOT_NO@varchar|IND_BCD@varchar|SPEC@varchar|ROLLCNT@varchar|PRFM_WGT@varchar|RMK@varchar|USERID@varchar|USERNM@varchar'||V_PRTTYPE;
        --컬럼설정 반환 테이블 작성
        OPEN CUR_1 FOR
        SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

        --결과 테이블 반환용 변수
        OPEN CUR_2 FOR
        --합지기 지시목록 조회
        SELECT '-' AS CHK                   --선택여부
        	 , W001.MATNR					-- 품목코드
        	 , M001.MATNR_NM AS MATNR_NMG	-- 품목명
             , W001.LOT_NO                  --LOT 번호
             , W001.IND_BCD                 --개별 바코드
             , TO_CHAR(S011.SPEC,'FM999,990') AS SPEC --규격
             , TO_CHAR(W001.ROLLCNT,'FM999,990') AS ROLLCNT --실적길이
             , RTRIM(TO_CHAR(W001.WGT,'FM999,990.999'),'.') AS PRFM_WGT         --실적중량
             , W001.RMK                     --비고
             , W001.REGID AS USERID         --등록자
             , U001.NMLAST AS USERNM        --등록자명
             , M012.MACH_NM                 --설비명
             , M001.MATNR_NM                --자재명
             , M001.BS_WGT                  --평량
             , ' ' AS COLOR                 --색상
             , U001.NMLAST AS WRK_NAME      --작업자명
             , '합격' AS QCJUD              --합격판정
        FROM TB_WRK001 W001,                --HL 실적
             TB_SCH011 S011,                --합지기 작업지시
             TB_MAS001 M001,                --자재정보
             TB_MAS012 M012,                --설비정보
             USRMA U001                     --사용자 정보
        WHERE 1=1
        AND W001.WRK_ORDR_NO = S011.WRK_ORDR_NO(+)
        AND W001.WRK_ORDR_SEQNO = S011.WRK_ORDR_SEQNO(+)
        AND W001.MACH_CD = M012.MACH_CD(+)
        AND W001.WERKS = M001.WERKS(+)
        AND W001.MATNR = M001.MATNR(+)
        AND W001.REGID = U001.USERID(+)
        AND W001.WERKS = P_WERKS
        AND W001.MACH_CD = P_MACH_CD
        AND W001.PRFM_GTHR_YN = 'Y'
        AND NVL(W001.CNL_YN,'N') = 'N'
        AND W001.PRFM_DT = P_WRK_DT
        AND SUBSTR(W001.MATNR, -1) = 'M'

        UNION ALL

        SELECT '-' AS CHK                   --선택여부
        	 , W001.MATNR					-- 품목코드
        	 , M001.MATNR_NM AS MATNR_NMG	-- 품목명
             , '자재합계' AS LOT_NO                  --LOT 번호
             , '' AS IND_BCD                 --개별 바코드
             , '' AS SPEC --규격
             , '' AS ROLLCNT --실적길이
             , RTRIM(TO_CHAR(SUM(W001.WGT), 'FM999,990.999'), '.') AS PRFM_WGT         --실적중량
             , '' AS RMK                     --비고
             , '' AS USERID         --등록자
             , '' AS USERNM        --등록자명
             , '' AS MACH_NM                 --설비명
             , '' AS MATNR_NM                --자재명
             , 0  AS BS_WGT                  --평량
             , '' AS COLOR                 --색상
             , '' AS WRK_NAME      --작업자명
             , '' AS QCJUD              --합격판정
        FROM TB_WRK001 W001,                --HL 실적
             TB_SCH011 S011,                --합지기 작업지시
             TB_MAS001 M001,                --자재정보
             TB_MAS012 M012,                --설비정보
             USRMA U001                     --사용자 정보
        WHERE 1=1
        AND W001.WRK_ORDR_NO = S011.WRK_ORDR_NO(+)
        AND W001.WRK_ORDR_SEQNO = S011.WRK_ORDR_SEQNO(+)
        AND W001.MACH_CD = M012.MACH_CD(+)
        AND W001.WERKS = M001.WERKS(+)
        AND W001.MATNR = M001.MATNR(+)
        AND W001.REGID = U001.USERID(+)
        AND W001.WERKS = P_WERKS
        AND W001.MACH_CD = P_MACH_CD
        AND W001.PRFM_GTHR_YN = 'Y'
        AND NVL(W001.CNL_YN,'N') = 'N'
        AND W001.PRFM_DT = P_WRK_DT
        AND SUBSTR(W001.MATNR, -1) = 'M'
        GROUP BY W001.MATNR, M001.MATNR_NM

        UNION ALL

        SELECT '-' AS CHK                   --선택여부
        	 , '' AS MATNR					-- 품목코드
        	 , '' AS MATNR_NMG	-- 품목명 
             , '전체합계' AS LOT_NO                  --LOT 번호
             , '' AS IND_BCD                 --개별 바코드
             , '' AS SPEC --규격
             , '' AS ROLLCNT --실적길이
             , RTRIM(TO_CHAR(SUM(W001.WGT), 'FM999,990.999'), '.') AS PRFM_WGT         --실적중량
             , '' AS RMK                     --비고
             , '' AS USERID         --등록자
             , '' AS USERNM        --등록자명
             , '' AS MACH_NM                 --설비명
             , '' AS MATNR_NM                --자재명
             , 0  AS BS_WGT                  --평량
             , '' AS COLOR                 --색상
             , '' AS WRK_NAME      --작업자명
             , '' AS QCJUD              --합격판정
        FROM TB_WRK001 W001,                --HL 실적
             TB_SCH011 S011,                --합지기 작업지시
             TB_MAS001 M001,                --자재정보
             TB_MAS012 M012,                --설비정보
             USRMA U001                     --사용자 정보
        WHERE 1=1
        AND W001.WRK_ORDR_NO = S011.WRK_ORDR_NO(+)
        AND W001.WRK_ORDR_SEQNO = S011.WRK_ORDR_SEQNO(+)
        AND W001.MACH_CD = M012.MACH_CD(+)
        AND W001.WERKS = M001.WERKS(+)
        AND W001.MATNR = M001.MATNR(+)
        AND W001.REGID = U001.USERID(+)
        AND W001.WERKS = P_WERKS
        AND W001.MACH_CD = P_MACH_CD
        AND W001.PRFM_GTHR_YN = 'Y'
        AND NVL(W001.CNL_YN,'N') = 'N'
        AND W001.PRFM_DT = P_WRK_DT
        AND SUBSTR(W001.MATNR, -1) = 'M'

        ORDER BY 5 DESC, 4 DESC, 2;

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
END ;
/
