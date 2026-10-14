
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK_LAMI007_S01" SP_POP_WRK_LAMI007_S01
(
    P_WERKS         	IN VARCHAR2     -- 플래트 코드
--    ,P_LOC_CD       	IN VARCHAR2     -- 로케이션 코드
    ,P_WRK_ORDR_NO  	IN VARCHAR2
    ,P_WRK_ORDR_SEQNO 	IN VARCHAR2	 
    ,P_COLINFO      	OUT VARCHAR2    -- grid 칼럼명
    ,P_COLTYPE      	OUT VARCHAR2   -- grid 칼럼 데이터 타입
    ,Lang           	IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        	OUT VARCHAR2 
    ,RS_MSG         	OUT VARCHAR2
    ,CUR_1          	OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK_LAMI_007
 * PROGRAM NAME  : 공정투입
 *                 
 * AUTHOR NAME   : 신진호
 * CREATE DATE   : 2023/01/11
 * SYSTEM NAME   : POP
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2023/01/11    1.0.0   신진호         Initial Version(재작업)
 *==============================================================================
 *  관련 테이블
 * - [TB_LAMI_PC] : (.R..) 작업지시 라미네이팅
 * - [TB_SCH020] : (.R..) 작업지시 투입bom
 * - [TB_INV001] : (.R..) 창고별 재고 관리
 * - [TB_MAS001] : (.R..) 플랜트별 제품/자재 마스터
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK_LAMI007_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

BEGIN
    --예외처리 시작(try)
    BEGIN
             P_COLINFO := '선택@C^50|생산일시@C^170|품목코드@H|품목@C^320|개별바코드@C^200|LOT.NO@C^200|투입지시량@R^150|재고수량@R^150|작업지시번호@H|작업지시순번@H|구분@H';
             P_COLTYPE := 'CHK@Button|PRD_DT@varchar|MATNR@varchar|MATNR_NM@varchar|IND_BCD@varchar|LOT_NO@varchar|ORDER_BOM_QTY@varchar|STCK_QTY@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|GU@varchar';

            --지시목록 조회
--            OPEN CUR_1 FOR
--             SELECT '-' AS CHK
--				, TO_CHAR(TO_DATE(INV001.PRD_DT), 'YYYY-MM-DD HH24:MI') AS PRD_DT -- 생산일자
--				, M001.MATNR                        -- 품목코드
--				, M001.MATNR_NM                         -- 품목명
--				, INV001.IND_BCD AS IND_BCD               -- 개별바코드
--				, INV001.LOT_NO AS LOT_NO                -- LOTNO
--				, S020.ORDER_BOM_QTY                    -- 투입지시량
--				, INV001.STCK_QTY AS STCK_QTY              -- 재고수량
--				, SL.WRK_ORDR_NO     		   -- 작업지시번호
--				, SL.WRK_ORDR_SEQNO		   -- 작업지시순번
--                , '정상' AS GUBUN                       --
--			FROM TB_LAMI_SL SL    --작업지시        
--				INNER JOIN TB_SCH020 S020   --투입정보BOM
--					ON SL.WERKS = S020.WERKS
--				   AND SL.WRK_ORDR_NO = S020.WRK_ORDR_NO
--				   AND SL.WRK_ORDR_SEQNO = S020.WRK_ORDR_SEQNO
--				INNER JOIN TB_INV001 INV001 --창고별 재고 관리
--					ON S020.WERKS = INV001.WERKS
--				   AND INV001.LOC_CD = P_LOC_CD
--				   AND S020.MATNR = INV001.MATNR
--				   AND S020.LOT_NO = INV001.LOT_NO
--                   AND S020.ORDER_BOM_QTY = INV001.STCK_QTY
--				INNER JOIN TB_MAS001 M001   -- 플랜트별 제품/자재 마스터       
--					ON S020.WERKS = M001.WERKS
--				   AND S020.MATNR = M001.MATNR
--			WHERE SL.WERKS = P_WERKS
--			  AND SL.WRK_ORDR_NO = P_WRK_ORDR_NO
--			  AND SL.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
--			ORDER BY INV001.PRD_DT,INV001.IND_BCD;

            OPEN CUR_1 FOR
             SELECT DISTINCT '-' AS CHK
				, TO_CHAR(TO_DATE(A.PRD_DT), 'YYYY-MM-DD HH24:MI') AS PRD_DT -- 생산일자
				, B.MATNR                        -- 품목코드
				, B.MATNR_NM                         -- 품목명
				, A.IND_BCD AS IND_BCD               -- 개별바코드
				, A.LOT_NO AS LOT_NO                -- LOTNO
				, C.ORDER_BOM_QTY                    -- 투입지시량
				, A.STCK_QTY AS STCK_QTY              -- 재고수량
				, A.WRK_ORDR_NO     		   -- 작업지시번호
				, A.WRK_ORDR_SEQNO		   -- 작업지시순번
                , CASE WHEN A.STCK_STA = '00' THEN '정상' ELSE '사용중' END AS GUBUN
			FROM TB_INV001 A    --작업지시        
            INNER JOIN TB_MAS001 B   -- 플랜트별 제품/자재 마스터       
                ON A.WERKS = B.WERKS
               AND A.MATNR = B.MATNR
            INNER JOIN TB_SCH020 C
                ON A.WERKS = C.WERKS
                AND A.MATNR = C.MATNR
                AND A.LOT_NO = C.LOT_NO 
--                AND NVL(REPLACE(A.LOT_NO, ' ', ''), '-') = NVL(C.LOT_NO, '-')
                --AND A.STCK_QTY = C.ORDER_BOM_QTY
                AND A.STOR_LOC_CD = C.STOR_LOC_CD
                AND C.WRK_ORDR_NO = P_WRK_ORDR_NO
                AND C.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
			WHERE A.WERKS = P_WERKS
			AND NVL(A.DLFL, ' ') = 'N'
           -- AND A.MACH_CD = 'PLS01'
            -- 라미네이팅 원재료 창고, 반제품 창고 둘다 가능
            AND A.STOR_LOC_CD IN ('2800', '2810')
            AND A.STCK_STA = '00'
            AND A.STCK_QTY > 0
			ORDER BY 2, 5;
--			ORDER BY A.PRD_DT,A.IND_BCD;

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
       -- RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
        --예외처리 종료
    END;
END;
/
