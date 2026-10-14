--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK04_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK04_S01" 
(
    P_WERKS         IN VARCHAR2 
    ,P_MACH_CD      IN VARCHAR2
    ,P_WRK_DT       IN VARCHAR2
    ,P_USERID       IN VARCHAR2
    ,P_CHKSEQ       OUT VARCHAR2
    ,P_CHKLIST      OUT VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK05
 * PROGRAM NAME  : 공정체크
 * VERSION       : 1.0.0
 * DESCRIPTION   : 공정체크 검사목록을 조회한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/05/19
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/13    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK003] : (.R..) 비가동 실적
 * - [TB_MAS020] : (.R..) 비가동 항목정보
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK04_S01';     -- PROCEDURE NAME
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

BEGIN
    --예외처리 시작(try)
    BEGIN
        --마지막 차수정보 조회
        BEGIN
        SELECT NVL(MAX(CHK_SEQNO),0) + 1
             , REGEXP_REPLACE(LISTAGG(CHK_SEQNO,',') WITHIN GROUP(ORDER BY CHK_SEQNO), '([^,]+)(,\1)*(,|$)', '\1\3')
          INTO P_CHKSEQ, P_CHKLIST
          FROM TB_WRK014 
         WHERE WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND CHK_DT = P_WRK_DT;
        EXCEPTION WHEN NO_DATA_FOUND THEN 
            P_CHKSEQ := 1;
        END;

        --컬럼설정
        V_COLINFO := '순번@C^80|분류@C^200|체크항목코드@H|체크항목@L^400|기준값@C^100|하한치@C^100|상한치@C^100|측정주기@H|입력타입@H|입력방법@H|입력방법상세@H|결과@C^150|판정코드@H|판정@C^100';
        V_COLTYPE := 'SEQ@varchar|CAT_NM@varchar|ITEM_CD@varchar|ITEM_NM@varchar|STD_VAL@varchar|LOW_VAL@varchar|UPP_VAL@varchar|MSRM_CYC@varchar|INPT_TYP@varchar|INPT_MTD@varchar|INPT_MTD_DESC@varchar|RES_VAL@Button|RESULT@varchar|RESULT_DESC@varchar';
        --컬럼설정 반환 테이블 작성
        OPEN CUR_1 FOR
        SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

        --결과 테이블 반환용 변수
        OPEN CUR_2 FOR
        --자재 불출요청 목록 조회
        SELECT ROW_NUMBER() OVER (ORDER BY M026.CHK_ITEM_CD) AS SEQ --순번
             , M025.BIG_CAT_NM AS CAT_NM
             , M025.CHK_ITEM_CD AS ITEM_CD
             , M025.CHK_ITEM_NM AS ITEM_NM
             , CASE WHEN M025.INPT_TYP = 'N' THEN TO_CHAR(M026.STD_VAL1)
                    ELSE M026.STD_VAL2 END AS STD_VAL
             , M026.LOW_VAL
             , M026.UPP_VAL
             , C001.USARG1 || ',' || C001.USARG2 AS MSRM_CYC
             , M025.INPT_TYP
             , M025.INPT_MTD
             , C002.CDESC1 AS INPT_MTD_DESC
             , '' AS RES_VAL
             , '' AS RESULT
             , '' AS RESULT_DESC
        FROM TB_MAS025 M025,            --공정체크 정보
             TB_MAS026 M026,             --설비별 검사항목
             (SELECT * FROM CMCDV WHERE CMCDKY = 'MSRMUNIT') C001, --측정주기
             (SELECT * FROM CMCDV WHERE CMCDKY = 'INPTMTD') C002 --입력방법
--             (SELECT * FROM TB_WRK014 WHERE WERKS = P_WERKS
--                                        AND MACH_CD = P_MACH_CD
--                                        AND CHK_DT = P_WRK_DT
--                                        AND CHK_SEQNO = (SELECT MAX(CHK_SEQNO) 
--                                                           FROM TB_WRK014 
--                                                          WHERE WERKS = P_WERKS
--                                                            AND MACH_CD = P_MACH_CD
--                                                            AND CHK_DT = P_WRK_DT)) W014 --검사이력
        WHERE 1=1
        AND M026.WERKS = M025.WERKS(+)
        AND M026.CHK_ITEM_CD = M025.CHK_ITEM_CD(+)
        AND M025.MSRM_CYC = C001.CMCDVL(+)
        AND M025.INPT_MTD = C002.CMCDVL(+)
        AND M026.WERKS = P_WERKS
        AND M026.MACH_CD = P_MACH_CD;

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
END SP_POP_WRK04_S01;

/
