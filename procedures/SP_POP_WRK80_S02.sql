
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK80_S02" 
(
    P_WERKS    		IN VARCHAR2 			--플랜트코드
    ,P_LINE    		IN VARCHAR2				--호기 (H2=2호기, H3=3호기)
    ,P_PCODE    	IN VARCHAR2				--지종코드 
    ,P_WEIGHT     	IN VARCHAR2				--평량 (3자리)
	,P_WIDTH		IN VARCHAR2				--가로 (4자리)
	,P_LENGTH		IN VARCHAR2				--세로 (4자리)
    ,P_COLINFO      OUT VARCHAR2
    ,P_COLTYPE      OUT VARCHAR2
    ,Lang       IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     OUT VARCHAR2 
    ,RS_MSG      OUT VARCHAR2
    ,CUR_1       OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK80_S02
 * PROGRAM NAME  : 포장 자재코드 조회(등급변경시 사용)
 * VERSION       : 1.0.0
 * DESCRIPTION   : 
 *                 
 * AUTHOR NAME   : 김병무
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
 * 2022/05/04    1.0.0   김병무         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_MAS001] : (.R..) 플랜트별 제품/자재 마스터
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK80_S02';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리
    V_LINE 		VARCHAR2(2) := P_LINE;
    V_WIDTH   	VARCHAR2(4) := SUBSTR('0000' || NVL(P_WIDTH, ''), -4);
    V_LENGTH   	VARCHAR2(4) := SUBSTR('0000' || NVL(P_LENGTH, ''), -4);

    --V_MATNR 	VARCHAR2(200) := P_LINE || P_PCODE || V_WEIGHT || '-';
    V_MATNR 	VARCHAR2(200);

BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
--            P_COLINFO := '';
--            P_COLTYPE := '';
            P_COLINFO := 'NO@C^100|자재코드@C^220|자재내역@L^600|지종명@H|평량@H|가로@H|세로@H';
            P_COLTYPE := 'NO@varchar|MATNR@varchar|MATNR_NM@varchar|PCODE_NM@varchar|BS_WGT@varchar|WLEN@varchar|VLEN@varchar';

            IF V_LINE = 'H2' THEN
                V_LINE := 'F2';
            ELSIF V_LINE = 'H3' THEN
                V_LINE := 'F3';
            END IF;
            V_MATNR := V_LINE || P_PCODE || P_WEIGHT || '-';

            IF V_WIDTH = '0000' THEN
                V_MATNR := V_MATNR || '%';
            ELSE 
                V_MATNR := V_MATNR || V_WIDTH;
            END IF;

            IF V_LENGTH = '0000' THEN
                V_MATNR := V_MATNR || '%';
            ELSE 
                V_MATNR := V_MATNR || V_LENGTH;
            END IF;

            V_MATNR := V_MATNR || '%';

            -- dbms_output.put_line(V_MATNR);
            
            --결과 테이블 반환용 변수
            OPEN CUR_1 FOR
            --합지기 지시목록 조회
            SELECT  ROWNUM          AS NO         --번호
                 , M001.MATNR       AS MATNR      --자재코드
                 , M001.MATNR_NM    AS MATNR_NM   --자재내역
                 , M001.PCODE_NM    AS PCODE_NM  --지종명
                 , M001.BS_WGT      AS BS_WGT    --평량
                 , M001.WLEN        AS WLEN      --가로
                 , M001.VLEN        AS VLEN      --세로
            FROM TB_MAS001 M001 			--자재정보
            WHERE 1=1
            AND WERKS = P_WERKS
            AND MATNR LIKE V_MATNR;
            --SELECT * FROM TB_MAS001 WHERE MATNR LIKE 'F3S11350-%%%';
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
END SP_POP_WRK80_S02;
/
