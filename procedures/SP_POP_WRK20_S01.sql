
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK20_S01" 
(
    P_WERKS         IN VARCHAR2 
    ,P_MACH_CD      IN VARCHAR2
    ,P_WRK_DT       IN VARCHAR2
    ,P_CHKFLAG      IN VARCHAR2
    ,P_CHKFLAG2     IN VARCHAR2
    ,P_USERID       IN VARCHAR2
    ,P_STCKSTA      OUT VARCHAR2
    ,P_STCKSTANM    OUT VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK20
 * PROGRAM NAME  : 생산실적 이력조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 생산실적 이력을 조회한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/05/09
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/09    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK001] : (.R..) HL 생산실적
 * - [TB_SCH011] : (.R..) 합지기 작업지시
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK20_S01';     -- PROCEDURE NAME
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
        V_PRTINFO := '|입고일자@H|생산호기@H|제품종류@H|KAN코드@H|기본단위@H|팔레트단위@H|품목구분@H';
        V_PRTTYPE := '|PRFM_DT@varchar|MACH_NM@varchar|WERKS_NM@varchar|KAN_CD@varchar|BAG2BOX@varchar|BOX2PLT@varchar|MATNR_DIV_NM@varchar';
        --컬럼설정
        V_COLINFO := '선택@C^60|플랜트@H|설비코드@H|작업지시@H|작업지시순번@H|자재코드@L^150|자재명@L^300|LOT번호@C^120|개별바코드@C^180|실적량@H^100|단위@H|PLT@R^80|BOX@R^80|BAG@R^80|EA@R^80|생산확인@C^80|투입량(KG)@R^150|부적합(BAG)@R^115|부적합여부@H|생산확인코드@H|생산확인일자@C^190|입고요청@C^80|비고@H|등록자@C^150'||V_PRTINFO;
        V_COLTYPE := 'CHK@Button|WERKS@varchar|MACH_CD@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|MATNR@varchar|MATNR_NM@varchar|LOT_NO@varchar|IND_BCD@varchar|PRFM_QTY@varchar|UNIT@varchar|PLT_QTY@varchar|BOX_QTY@varchar|BAG_QTY@varchar|EA_QTY@varchar|CHK_YN_NM@varchar|USE_QTY@varchar|DISPO_QTY@varchar|STCK_STA@varchar|CHK_YN@varchar|CHK_PP_DATE@varchar|WMS_STA@varchar|RMK@varchar|USERID@varchar'||V_PRTTYPE;
        --컬럼설정 반환 테이블 작성
        OPEN CUR_1 FOR
        SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

        --결과 테이블 반환용 변수
        OPEN CUR_2 FOR
        --설비 및 일자별 실적 조회
        SELECT '-' 															AS CHK				--선택여부
             , W001.WERKS 													AS WERKS			--플랜트 코드
             , W001.MACH_CD 												AS MACH_CD			--작업장코드(설비)
             , W001.WRK_ORDR_NO 											AS WRK_ORDR_NO		--작업지시번호
             , W001.WRK_ORDR_SEQNO 											AS WRK_ORDR_SEQNO	--작업지시순번
             , W001.MATNR 													AS MATNR			--생산제품
             , M001.MATNR_NM 												AS MATNR_NM			--제품명
             , W001.LOT_NO 													AS LOT_NO			--LOT 번호
             , W001.IND_BCD 												AS IND_BCD			--개별 바코드
             , TO_CHAR(W001.BAG_QTY,'FM999,990') 							AS PRFM_QTY			--실적량(BAG으로 테스트)
             , M001.UNIT 													AS UNIT				--기준단위
             --출고완료시 수량이 0으로 보이기에 실적의 수량으로 표시
             , RTRIM(TO_CHAR(NVL(W001.PLT_QTY,0),'FM999,990.0'),'.') 		AS PLT_QTY			--팔레트 수량
             , TO_CHAR(CEIL(NVL(W001.BOX_QTY,0)),'FM999,990') 				AS BOX_QTY			--박수 수량
             , TO_CHAR(CEIL(NVL(W001.BAG_QTY,0)),'FM999,990') 				AS BAG_QTY			--폴리백 수량
             , TO_CHAR(CEIL(NVL(W001.EA_QTY,0)),'FM999,990') 				AS EA_QTY			--개별 수량
             , CASE WHEN W001.CHK_PP_YN = 'Y' THEN '확인'
                                              ELSE '미확인' END 				AS CHK_YN_NM		--확인 여부 명칭
             , TO_CHAR(NVL(I010.USE_QTY,0),'FM999,990.000') 				AS USE_QTY			--투입 수량
             , TO_CHAR(CEIL(NVL(I001.UCFMTY_AMT,0)),'FM999,990') 			AS DISPO_QTY		--부적합 수량
             , I001.STCK_STA 												AS STCK_STA			--재고상태
             , W001.CHK_PP_YN 												AS CHK_YN			--확인 여부
             , TO_CHAR(W001.CHK_PP_DATE,'YYYY-MM-DD hh24:MI:DD')			AS CHK_PP_DATE		--확인 일자
             , 
             (
             	CASE
             	    WHEN I001.STOR_LOC_CD = '2000' THEN '완료'
                    WHEN I001.STCK_STA = '00' THEN '미요청'
                    WHEN I001.STCK_STA = '10' THEN '투입'
                    WHEN I001.STCK_STA = '20' THEN '생산실적'
                    WHEN I001.STCK_STA = '25' THEN '등급변경'
                    WHEN I001.STCK_STA = '30' THEN '불용'
                    WHEN I001.STCK_STA = '40' THEN '부적합'
                    WHEN I001.STCK_STA = '50' THEN '폐기재고'
                    WHEN I001.STCK_STA = '60' THEN '보류재고'
                    WHEN I001.STCK_STA = '70' THEN '완료'
             	ELSE '요청'
             	END
             )																AS WMS_STA --입고요청 상태
             , W001.RMK 													AS RMK              --비고
             , W001.REGID 													AS USERID			--등록자
             , W001.PRFM_DT 												AS PRFM_DT          --실적일자
             , M012.MACH_NM 												AS MACH_NM          --설비명
             , CASE WHEN W001.WERKS = 'P200' THEN '화장지'
                    WHEN W001.WERKS = 'P300' THEN '생리대'
                    WHEN W001.WERKS = 'P500' THEN '기저귀'
                    END 													AS WERKS_NM         --제품종류
            , M001.KAN_NO AS KAN_CD         --KAN코드
            , FN_CHG_UNIT(W001.MATNR, W001.WERKS, 'BAG', 'EA', 1) || 'x' 
                || FN_CHG_UNIT(W001.MATNR, W001.WERKS, 'BOX', 'BAG', 1) 	AS BAG2BOX			--박스당 폴리백수량
            , FN_CHG_UNIT(W001.MATNR, W001.WERKS, 'PAL', 'BOX', 1) 			AS BOX2PLT			--팔레트당 박스수량
            , FN_CD_VAL('PART_DIV', M001.PART_DIV) 							AS MATNR_DIV_NM
        FROM TB_WRK001 W001,                --HL 실적
             TB_MAS001 M001,                --자재정보
             TB_MAS012 M012,                --설비정보
             TB_INV001 I001,                --재고정보
             (
             	SELECT WERKS, MACH_CD, IND_BCD, WRK_ORDR_NO, WRK_ORDR_SEQNO, SUM(USE_QTY) AS USE_QTY
	             FROM	TB_INV010
	             WHERE	WERKS = P_WERKS
	             AND	MACH_CD = P_MACH_CD
	             AND	PRFM_DT = P_WRK_DT
	             AND	NVL(CNL_YN, 'N') = 'N'
	             GROUP BY	WERKS, MACH_CD, IND_BCD, WRK_ORDR_NO, WRK_ORDR_SEQNO
             ) I010							-- 사용량 조회
        WHERE 1=1
        AND W001.WERKS = M001.WERKS(+)
        AND W001.MATNR = M001.MATNR(+)
        AND W001.MACH_CD = M012.MACH_CD(+)
        AND W001.WERKS = I001.WERKS(+)
        AND W001.MATNR = I001.MATNR(+)
        AND W001.IND_BCD = I001.IND_BCD(+)
        AND W001.WERKS = I010.WERKS
        AND W001.MACH_CD = I010.MACH_CD
        AND W001.IND_BCD = I010.IND_BCD
        AND W001.WRK_ORDR_NO = I010.WRK_ORDR_NO
        AND W001.WRK_ORDR_SEQNO = I010.WRK_ORDR_SEQNO
--        AND I001.STOR_LOC_CD = '3100'
        AND W001.WERKS = P_WERKS
        AND W001.MACH_CD = P_MACH_CD
        AND W001.PRFM_DT = P_WRK_DT
        AND ((P_WERKS = 'P200' AND W001.CHK_PP_YN LIKE P_CHKFLAG || '%')
            OR(P_WERKS = 'P300' AND W001.CHK_PP_YN LIKE P_CHKFLAG || '%')
            OR(P_WERKS = 'P500' AND W001.CHK_PP_YN LIKE P_CHKFLAG || '%'))
--        AND ((P_CHKFLAG2 = '00' AND I001.STCK_STA IN ('00','70','80'))
--            OR (NVL(P_CHKFLAG2,'N') != '00' AND I001.STCK_STA LIKE P_CHKFLAG2 || '%'))
        AND W001.PRFM_GTHR_YN = 'Y'
        AND NVL(W001.CNL_YN, 'N') = 'N'

UNION ALL

        SELECT '-' AS CHK				--선택여부
             , '' AS WERKS 													--플랜트 코드
             , '' AS MACH_CD --작업장코드(설비)
             , '' AS WRK_ORDR_NO --작업지시번호
             , 1 AS WRK_ORDR_SEQNO --작업지시순번
             , W001.MATNR  AS MATNR			--생산제품
             , M001.MATNR_NM AS MATNR_NM			--제품명
             , '자재합계'  AS LOT_NO			--LOT 번호
             , ''  AS IND_BCD			--개별 바코드
             , TO_CHAR(SUM(W001.BAG_QTY),'FM999,990')						AS PRFM_QTY			--실적량(BAG으로 테스트)
             , ''  AS UNIT				--기준단위
             --출고완료시 수량이 0으로 보이기에 실적의 수량으로 표시
             , RTRIM(TO_CHAR(SUM(NVL(W001.PLT_QTY,0)),'FM999,990.0'),'.') 		AS PLT_QTY			--팔레트 수량
             , TO_CHAR(CEIL(SUM(NVL(W001.BOX_QTY,0))),'FM999,990') 				AS BOX_QTY			--박수 수량
             , TO_CHAR(CEIL(SUM(NVL(W001.BAG_QTY,0))),'FM999,990') 				AS BAG_QTY			--폴리백 수량
             , TO_CHAR(CEIL(SUM(NVL(W001.EA_QTY,0))),'FM999,990') 				AS EA_QTY			--개별 수량
             , '' AS CHK_YN_NM		--확인 여부 명칭
             , TO_CHAR(SUM(NVL(I010.USE_QTY,0)),'FM999,990.000') 					AS USE_QTY			--투입 수량
             , TO_CHAR(CEIL(SUM(NVL(I001.UCFMTY_AMT,0))),'FM999,990') 			AS DISPO_QTY		--부적합 수량
             , ''  AS STCK_STA			--재고상태
             , ''  AS CHK_YN			--확인 여부
             , '' AS CHK_PP_DATE		--확인 일자
             , '' AS WMS_STA --입고요청 상태
             , ''  AS RMK              --비고
             , ''  AS USERID			--등록자
             , ''  AS PRFM_DT          --실적일자
             , ''  AS MACH_NM          --설비명
             , '' AS WERKS_NM         --제품종류
             , '' AS KAN_CD         --KAN코드
             , '' AS BAG2BOX			--박스당 폴리백수량
             , 0 AS BOX2PLT			--팔레트당 박스수량
             , '' AS MATNR_DIV_NM
        FROM TB_WRK001 W001,                --HL 실적
             TB_MAS001 M001,                --자재정보
             TB_MAS012 M012,                --설비정보
             TB_INV001 I001,                --재고정보
             (
             	SELECT WERKS, MACH_CD, IND_BCD, WRK_ORDR_NO, WRK_ORDR_SEQNO, SUM(USE_QTY) AS USE_QTY
	             FROM	TB_INV010
	             WHERE	WERKS = P_WERKS
	             AND	MACH_CD = P_MACH_CD
	             AND	PRFM_DT = P_WRK_DT
	             AND	NVL(CNL_YN, 'N') = 'N'
	             GROUP BY	WERKS, MACH_CD, IND_BCD, WRK_ORDR_NO, WRK_ORDR_SEQNO
             ) I010							-- 사용량 조회
        WHERE 1=1
        AND W001.WERKS = M001.WERKS(+)
        AND W001.MATNR = M001.MATNR(+)
        AND W001.MACH_CD = M012.MACH_CD(+)
        AND W001.WERKS = I001.WERKS(+)
        AND W001.MATNR = I001.MATNR(+)
        AND W001.IND_BCD = I001.IND_BCD(+)
        AND W001.WERKS = I010.WERKS
        AND W001.MACH_CD = I010.MACH_CD
        AND W001.IND_BCD = I010.IND_BCD
        AND W001.WRK_ORDR_NO = I010.WRK_ORDR_NO
        AND W001.WRK_ORDR_SEQNO = I010.WRK_ORDR_SEQNO
--        AND I001.STOR_LOC_CD = '3100'
        AND W001.WERKS = P_WERKS
        AND W001.MACH_CD = P_MACH_CD
        AND W001.PRFM_DT = P_WRK_DT
        AND ((P_WERKS = 'P200' AND W001.CHK_PP_YN LIKE P_CHKFLAG || '%')
            OR(P_WERKS = 'P300' AND W001.CHK_PP_YN LIKE P_CHKFLAG || '%')
            OR(P_WERKS = 'P500' AND W001.CHK_PP_YN LIKE P_CHKFLAG || '%'))
--        AND ((P_CHKFLAG2 = '00' AND I001.STCK_STA IN ('00','70','80'))
--            OR (NVL(P_CHKFLAG2,'N') != '00' AND I001.STCK_STA LIKE P_CHKFLAG2 || '%'))
        AND W001.PRFM_GTHR_YN = 'Y'
        AND NVL(W001.CNL_YN, 'N') = 'N'
        GROUP BY W001.MATNR, M001.MATNR_NM

UNION ALL

        SELECT '-' AS CHK				--선택여부
             , '' AS WERKS 													--플랜트 코드
             , '' AS MACH_CD --작업장코드(설비)
             , '' AS WRK_ORDR_NO --작업지시번호
             , 1 AS WRK_ORDR_SEQNO --작업지시순번
             , '' AS MATNR			--생산제품
             , '' AS MATNR_NM			--제품명
             , '전체합계'  AS LOT_NO			--LOT 번호
             , ''  AS IND_BCD			--개별 바코드
             , TO_CHAR(SUM(W001.BAG_QTY),'FM999,990')						AS PRFM_QTY			--실적량(BAG으로 테스트)
             , ''  AS UNIT				--기준단위
             --출고완료시 수량이 0으로 보이기에 실적의 수량으로 표시
             , RTRIM(TO_CHAR(SUM(NVL(W001.PLT_QTY,0)),'FM999,990.0'),'.') 		AS PLT_QTY			--팔레트 수량
             , TO_CHAR(CEIL(SUM(NVL(W001.BOX_QTY,0))),'FM999,990') 				AS BOX_QTY			--박수 수량
             , TO_CHAR(CEIL(SUM(NVL(W001.BAG_QTY,0))),'FM999,990') 				AS BAG_QTY			--폴리백 수량
             , TO_CHAR(CEIL(SUM(NVL(W001.EA_QTY,0))),'FM999,990') 				AS EA_QTY			--개별 수량
             , '' AS CHK_YN_NM		--확인 여부 명칭
             , TO_CHAR(SUM(NVL(I010.USE_QTY,0)),'FM999,990.000') 					AS USE_QTY			--투입 수량
             , TO_CHAR(CEIL(SUM(NVL(I001.UCFMTY_AMT,0))),'FM999,990') 			AS DISPO_QTY		--부적합 수량
             , ''  AS STCK_STA			--재고상태
             , ''  AS CHK_YN			--확인 여부
             , '' AS CHK_PP_DATE		--확인 일자
             , '' AS WMS_STA --입고요청 상태
             , ''  AS RMK              --비고
             , ''  AS USERID			--등록자
             , ''  AS PRFM_DT          --실적일자
             , ''  AS MACH_NM          --설비명
             , '' AS WERKS_NM         --제품종류
             , '' AS KAN_CD         --KAN코드
             , '' AS BAG2BOX			--박스당 폴리백수량
             , 0 AS BOX2PLT			--팔레트당 박스수량
             , '' AS MATNR_DIV_NM
        FROM TB_WRK001 W001,                --HL 실적
             TB_MAS001 M001,                --자재정보
             TB_MAS012 M012,                --설비정보
             TB_INV001 I001,                --재고정보
             (
             	SELECT WERKS, MACH_CD, IND_BCD, WRK_ORDR_NO, WRK_ORDR_SEQNO, SUM(USE_QTY) AS USE_QTY
	             FROM	TB_INV010
	             WHERE	WERKS = P_WERKS
	             AND	MACH_CD = P_MACH_CD
	             AND	PRFM_DT = P_WRK_DT
	             AND	NVL(CNL_YN, 'N') = 'N'
	             GROUP BY	WERKS, MACH_CD, IND_BCD, WRK_ORDR_NO, WRK_ORDR_SEQNO
             ) I010							-- 사용량 조회
        WHERE 1=1
        AND W001.WERKS = M001.WERKS(+)
        AND W001.MATNR = M001.MATNR(+)
        AND W001.MACH_CD = M012.MACH_CD(+)
        AND W001.WERKS = I001.WERKS(+)
        AND W001.MATNR = I001.MATNR(+)
        AND W001.IND_BCD = I001.IND_BCD(+)
        AND W001.WERKS = I010.WERKS
        AND W001.MACH_CD = I010.MACH_CD
        AND W001.IND_BCD = I010.IND_BCD
        AND W001.WRK_ORDR_NO = I010.WRK_ORDR_NO
        AND W001.WRK_ORDR_SEQNO = I010.WRK_ORDR_SEQNO
--        AND I001.STOR_LOC_CD = '3100'
        AND W001.WERKS = P_WERKS
        AND W001.MACH_CD = P_MACH_CD
        AND W001.PRFM_DT = P_WRK_DT
        AND ((P_WERKS = 'P200' AND W001.CHK_PP_YN LIKE P_CHKFLAG || '%')
            OR(P_WERKS = 'P300' AND W001.CHK_PP_YN LIKE P_CHKFLAG || '%')
            OR(P_WERKS = 'P500' AND W001.CHK_PP_YN LIKE P_CHKFLAG || '%'))
--        AND ((P_CHKFLAG2 = '00' AND I001.STCK_STA IN ('00','70','80'))
--            OR (NVL(P_CHKFLAG2,'N') != '00' AND I001.STCK_STA LIKE P_CHKFLAG2 || '%'))
        AND W001.PRFM_GTHR_YN = 'Y'
        AND NVL(W001.CNL_YN, 'N') = 'N'

        ORDER BY 8 DESC, 9 DESC, 6 ASC;

        SELECT CMCDVL AS ItemCode
             , CDESC1 AS ItemName
          INTO P_STCKSTA, P_STCKSTANM
          FROM CMCDV
         WHERE 1=1
           AND CMCDKY = 'STCK_STA'
           AND CMCDVL = '00'
         ORDER BY CMCDVL;

        --작업 정상 종료 코드 등록
        RS_CODE := 'S';
    --예외처리(catch)
    EXCEPTION
    WHEN E_EXCEPTION_USER THEN
        -- 에러 내역 SET
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(-20000,1,300);

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    WHEN OTHERS THEN
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20000, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END;
/
