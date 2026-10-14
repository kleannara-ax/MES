
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRKLAMI_008_S01" 
(
    P_WERKS         IN VARCHAR2
    ,P_MATNR		IN VARCHAR2
    ,P_WRK_DT       IN VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK75
 * PROGRAM NAME  : 라미네이팅 비가동 이력조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 비가동 이력 목록을 조회한다.
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
 * - [TB_WRK003] : (.R..) 비가동 실적
 * - [TB_MAS020] : (.R..) 비가동 항목정보
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRKLAMI_008_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := ''; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --파라미터 처리
    --내부변수 관리
    V_COLINFO VARCHAR2(4000);
    V_COLTYPE VARCHAR2(4000);

BEGIN
    --예외처리 시작(try)
    BEGIN
        --컬럼설정
        V_COLINFO := '선택@C^60|자재코드@C^100|자재명@C^350|LOT_NO@C^200|개별바코드@C^200|단위@C^140|중량@C^150';
        V_COLTYPE := 'CHK@Button|MATNR@varchar|MATNR_NM@varchar|LOT_NO@varchar|IND_BCD@varchar|UNIT@varchar|STCK_QTY@varchar';
        --컬럼설정 반환 테이블 작성
        OPEN CUR_1 FOR
        SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

        --결과 테이블 반환용 변수
        OPEN CUR_2 FOR
        --비가동 이력목록 조회
        SELECT '-' AS CHK               --선택여부
        	,M001.MATNR
        	,M001.MATNR_NM
        	,I001.LOT_NO
        	,I001.IND_BCD
        	,I001.UNIT
        	,I001.STCK_QTY
        FROM TB_INV001 I001,            --비가동 이력
             TB_MAS001 M001             --비가동항목 정보
        WHERE 1=1
        AND I001.WERKS = M001.WERKS(+)
        AND I001.MATNR = M001.MATNR(+)
        AND I001.WERKS = P_WERKS
        AND	I001.MATNR LIKE '%' || P_MATNR || '%'
        AND I001.PRD_DT = P_WRK_DT
        AND	M001.MATNR_GRP_CD IN ('3B01', '3B02')
        AND	I001.STCK_QTY <> 0
        ORDER BY I001.MATNR, I001.IND_BCD;

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
        RAISE_APPLICATION_ERROR('-20001', E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END;
/
