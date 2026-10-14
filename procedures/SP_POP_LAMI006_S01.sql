
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_LAMI006_S01" SP_POP_LAMI006_S01
(
     P_WERKS    IN  VARCHAR2             -- 플랜트 코드
    ,P_PROC_CD  IN  VARCHAR2             -- 공정코드 (JA, MA, CA, PB_PC ...)
    ,P_PRFM_DT  IN  VARCHAR2             -- 생산실적일자
    ,P_MACH_CD	IN  VARCHAR2			 -- 설비호기
    ,P_ORDER_NO IN  VARCHAR2             
    ,P_IND_BCD  IN  VARCHAR2  
    ,P_PCODE    IN  VARCHAR2
    ,P_BS_WGT   IN  VARCHAR2 
    ,P_COLINFO  OUT TB_LAMI_PC_IFR015.AUFNR%TYPE        -- grid 칼럼명
    ,P_COLTYPE  OUT TB_LAMI_PC_IFR015.AUFNR%TYPE        -- grid 칼럼 데이터 타입
--    ,P_COLINFO  OUT VARCHAR2        -- grid 칼럼명
--    ,P_COLTYPE  OUT VARCHAR2        -- grid 칼럼 데이터 타입
    ,Lang       IN  VARCHAR2 DEFAULT 'KO'
    ,RS_CODE    OUT VARCHAR2 
    ,RS_MSG     OUT VARCHAR2 
    ,CUR_1      OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_LAMI006_S01
 * PROGRAM NAME  : 생산실적 이력 조회
 * VERSION       : 1.0.1
 * DESCRIPTION   : 생산실적 이력 조회
 *                 
 * AUTHOR NAME   : 백우종
 * CREATE DATE   : 2024/05/12
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/12/09    1.0.0   김수현         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK002] : (.R..) 라미네이팅 생산실적 이력
 * - [TB_LAMI_SL] : (.R..) 슬리팅 생산실적 이력
 *=============================================================================*/
AS
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_LAMI006_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    TSQL VARCHAR2(4000) := '';
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리
BEGIN
	IF	P_PROC_CD = 'LP'	THEN
        --grid 컬럼 정보 설정
        P_COLINFO := '선택@C^60|실적일자@C^100|오더구분@H|개별바코드@C^130|LOT_NO@C^130|제품코드@L^200|제품명@L350|단위@C40|실적량@R80|작업지시번호@H|순번@H|오더번호@L80|확정문서번호@H|확정문서순번@H';
        P_COLTYPE := 'CHK@Button|PRFM_DT@varchar|ORDER_GB@varchar|IND_BCD@varchar|LOT_NO@varchar|MATNR@varchar|MATNR_NM@varchar|UNIT@varchar|PRFM_QTY@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|ORDER_NO@varchar|SDOC_NO@varchar|SDOC_SEQNO@varchar';

       	OPEN CUR_1	FOR
--			SELECT	'-'	AS CHK
--					, W002.PRFM_DT
--					, '라미네이팅 인쇄코팅' AS ORDER_GB
--					, W002.IND_BCD AS IND_BCD
--					, W002.LOT_NO AS LOT_NO
--					, W002.MATNR
--					, M001.MATNR_NM
--					, M001.UNIT
--					, W002.PRFM_QTY AS PRFM_QTY
--					, W002.WRK_ORDR_NO AS WRK_ORDR_NO
--					, W002.WRK_ORDR_SEQNO AS WRK_ORDR_SEQNO
--					, W002.ORDER_NO AS ORDER_NO
--					, CASE	WHEN	W002.PRFM_GTHR_YN = 'Y'	THEN W002.DOC_NO ELSE	''	END AS SDOC_NO
--					, CASE	WHEN	W002.PRFM_GTHR_YN = 'Y'	THEN W002.DOC_SEQNO ELSE	0	END AS SDOC_SEQNO
----					, W002.DOC_NO AS SDOC_NO
----					, W002.DOC_SEQNO AS SDOC_SEQNO
--					, W004.DOC_NO AS DOC_NO
--					, W004.DOC_SEQNO AS DOC_SEQNO
--			FROM	TB_WRK002 W002	INNER JOIN		TB_MAS001 M001	ON	W002.WERKS = M001.WERKS AND W002.MATNR = M001.MATNR
--									LEFT OUTER JOIN TB_WRK004 W004	ON	W002.WRK_ORDR_NO = W004.WRK_ORDR_NO
--																	AND W002.WRK_ORDR_SEQNO = W004.WRK_ORDR_SEQNO
--																	AND NVL(W004.CNL_YN, 'N') = 'N'
--																	AND W002.LOT_NO = W004.LOT_NO
--																	AND W002.IND_BCD = W004.IND_BCD
--			WHERE 	W002.WERKS = P_WERKS
--				AND	W002.MACH_CD = P_MACH_CD
--				AND	W002.PRFM_DT = P_PRFM_DT
--				AND	NVL(W002.CNL_YN , 'N') = 'N'
--				AND	W002.ORDER_NO LIKE '%' || P_ORDER_NO || '%'
--				AND	W002.IND_BCD LIKE '%' || P_IND_BCD || '%'
--				AND NVL(W002.PRFM_GTHR_YN, 'N') = 'Y'
--			ORDER BY W002.IND_BCD DESC;

			SELECT	'-'	AS CHK
					, W002.PRFM_DT
					, '라미네이팅 인쇄코팅' AS ORDER_GB
					, W002.IND_BCD AS IND_BCD
					, W002.LOT_NO AS LOT_NO
					, W002.MATNR
					, M001.MATNR_NM
					, M001.UNIT
					, W002.PRFM_QTY AS PRFM_QTY
					, W002.WRK_ORDR_NO AS WRK_ORDR_NO
					, W002.WRK_ORDR_SEQNO AS WRK_ORDR_SEQNO
					, W002.ORDER_NO AS ORDER_NO
					, CASE	WHEN	W002.PRFM_GTHR_YN = 'Y'	THEN W002.DOC_NO ELSE	''	END AS SDOC_NO
					, CASE	WHEN	W002.PRFM_GTHR_YN = 'Y'	THEN W002.DOC_SEQNO ELSE	0	END AS SDOC_SEQNO
					, W004.DOC_NO AS DOC_NO
					, W004.DOC_SEQNO AS DOC_SEQNO
			FROM	TB_WRK002 W002	INNER JOIN		TB_MAS001 M001	ON	W002.WERKS = M001.WERKS AND W002.MATNR = M001.MATNR
									LEFT OUTER JOIN TB_WRK004 W004	ON	W002.WRK_ORDR_NO = W004.WRK_ORDR_NO
																	AND W002.WRK_ORDR_SEQNO = W004.WRK_ORDR_SEQNO
																	AND NVL(W004.CNL_YN, 'N') = 'N'
																	AND W002.LOT_NO = W004.LOT_NO
																	AND W002.IND_BCD = W004.IND_BCD
			WHERE 	W002.WERKS = P_WERKS
				AND	W002.MACH_CD = P_MACH_CD
				AND	W002.PRFM_DT = P_PRFM_DT
				AND	NVL(W002.CNL_YN , 'N') = 'N'
				AND	W002.ORDER_NO LIKE '%' || P_ORDER_NO || '%'
				AND	W002.IND_BCD LIKE '%' || P_IND_BCD || '%'
				AND NVL(W002.PRFM_GTHR_YN, 'N') = 'Y'

			UNION ALL

			SELECT 
			    '-' AS CHK,
			    NULL AS PRFM_DT,
			    '라미네이팅 인쇄코팅' AS ORDER_GB,
			    '자재합계' AS IND_BCD,
			    NULL AS LOT_NO,
			    W002.MATNR,
			    M001.MATNR_NM,
			    M001.UNIT,
			    SUM(W002.PRFM_QTY) AS PRFM_QTY,
			    NULL AS WRK_ORDR_NO,
			    NULL AS WRK_ORDR_SEQNO,
			    NULL AS ORDER_NO,
			    NULL AS SDOC_NO,
			    NULL AS SDOC_SEQNO,
			    NULL AS DOC_NO,
			    NULL AS DOC_SEQNO
			FROM TB_WRK002 W002
			INNER JOIN TB_MAS001 M001 
			    ON W002.WERKS = M001.WERKS 
			    AND W002.MATNR = M001.MATNR
			WHERE 	W002.WERKS = P_WERKS
				AND	W002.MACH_CD = P_MACH_CD
				AND	W002.PRFM_DT = P_PRFM_DT
				AND	NVL(W002.CNL_YN , 'N') = 'N'
				AND	W002.ORDER_NO LIKE '%' || P_ORDER_NO || '%'
				AND	W002.IND_BCD LIKE '%' || P_IND_BCD || '%'
				AND NVL(W002.PRFM_GTHR_YN, 'N') = 'Y'
			GROUP BY W002.MATNR, M001.MATNR_NM, M001.UNIT
			ORDER BY 7 DESC, 5 DESC;

	ELSIF	P_PROC_CD = 'LS'	THEN
        --grid 컬럼 정보 설정
        P_COLINFO := '선택@C^60|실적일자@C^100|오더구분@H|개별바코드@C^130|LOT_NO@C^130|제품코드@L^200|제품명@L400|단위@C40|실적량@R80|작업지시번호@L250|순번@R50|오더번호@L80|확정문서번호@H|확정문서순번@H';
        P_COLTYPE := 'CHK@Button|PRFM_DT@varchar|ORDER_GB@varchar|IND_BCD@varchar|LOT_NO@varchar|MATNR@varchar|MATNR_NM@varchar|UNIT@varchar|PRFM_QTY@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|ORDER_NO@varchar|SDOC_NO@varchar|SDOC_SEQNO@varchar';

       	OPEN CUR_1	FOR
--			SELECT	'-'	AS CHK
--					, W002.PRFM_DT
--					, '라미네이팅 슬리팅' AS ORDER_GB
--					, W002.IND_BCD AS IND_BCD
--					, W002.LOT_NO AS LOT_NO
--					, W002.MATNR
--					, M001.MATNR_NM
--					, M001.UNIT
--					, W002.PRFM_QTY AS PRFM_QTY
--					, W002.WRK_ORDR_NO AS WRK_ORDR_NO
--					, W002.WRK_ORDR_SEQNO AS WRK_ORDR_SEQNO
--					, W002.ORDER_NO AS ORDER_NO
--					, CASE	WHEN	W002.PRFM_GTHR_YN = 'Y'	THEN W002.DOC_NO ELSE	''	END AS SDOC_NO
--					, CASE	WHEN	W002.PRFM_GTHR_YN = 'Y'	THEN W002.DOC_SEQNO ELSE	0	END AS SDOC_SEQNO
--					, I010.DOC_NO AS IDOC_NO
--					, I010.DOC_SEQNO AS IDOC_SEQNO
--			FROM	TB_WRK002 W002	INNER JOIN		TB_MAS001 M001	ON	W002.WERKS = M001.WERKS AND W002.MATNR = M001.MATNR
--									LEFT OUTER JOIN TB_INV010 I010	ON	W002.WRK_ORDR_NO = I010.WRK_ORDR_NO
--																	AND W002.WRK_ORDR_SEQNO = I010.WRK_ORDR_SEQNO
--																	AND NVL(I010.CNL_YN, 'N') = 'N'
--																	AND W002.LOT_NO = I010.LOT_NO
--																	AND W002.IND_BCD = I010.IND_BCD
--			WHERE 	W002.WERKS = P_WERKS
--				AND	W002.MACH_CD = P_MACH_CD
--				AND	W002.PRFM_DT = P_PRFM_DT
--				AND	NVL(W002.CNL_YN , 'N') = 'N'
--				AND	W002.ORDER_NO LIKE '%' || P_ORDER_NO || '%'
--				AND	W002.IND_BCD LIKE '%' || P_IND_BCD || '%'
--				AND NVL(W002.PRFM_GTHR_YN, 'N') = 'Y'
--			ORDER BY W002.IND_BCD DESC;
       	
       	
			SELECT	'-'	AS CHK
					, W002.PRFM_DT
					, '라미네이팅 슬리팅' AS ORDER_GB
					, W002.IND_BCD AS IND_BCD
					, W002.LOT_NO AS LOT_NO
					, W002.MATNR
					, M001.MATNR_NM
					, M001.UNIT
					, W002.PRFM_QTY AS PRFM_QTY
					, W002.WRK_ORDR_NO AS WRK_ORDR_NO
					, W002.WRK_ORDR_SEQNO AS WRK_ORDR_SEQNO
					, W002.ORDER_NO AS ORDER_NO
					, CASE	WHEN	W002.PRFM_GTHR_YN = 'Y'	THEN W002.DOC_NO ELSE	''	END AS SDOC_NO
					, CASE	WHEN	W002.PRFM_GTHR_YN = 'Y'	THEN W002.DOC_SEQNO ELSE	0	END AS SDOC_SEQNO
					, I010.DOC_NO AS IDOC_NO
					, I010.DOC_SEQNO AS IDOC_SEQNO
			FROM	TB_WRK002 W002	INNER JOIN		TB_MAS001 M001	ON	W002.WERKS = M001.WERKS AND W002.MATNR = M001.MATNR
									LEFT OUTER JOIN TB_INV010 I010	ON	W002.WRK_ORDR_NO = I010.WRK_ORDR_NO
																	AND W002.WRK_ORDR_SEQNO = I010.WRK_ORDR_SEQNO
																	AND NVL(I010.CNL_YN, 'N') = 'N'
																	AND W002.LOT_NO = I010.LOT_NO
																	AND W002.IND_BCD = I010.IND_BCD
			WHERE 	W002.WERKS = P_WERKS
				AND	W002.MACH_CD = P_MACH_CD
				AND	W002.PRFM_DT = P_PRFM_DT
				AND	NVL(W002.CNL_YN , 'N') = 'N'
				AND	W002.ORDER_NO LIKE '%' || P_ORDER_NO || '%'
				AND	W002.IND_BCD LIKE '%' || P_IND_BCD || '%'
				AND NVL(W002.PRFM_GTHR_YN, 'N') = 'Y'
				
UNION ALL

			SELECT	'-'	AS CHK,
					NULL AS PRFM_DT,
					'라미네이팅 슬리팅' AS ORDER_GB,
					NULL AS IND_BCD,
					NULL AS LOT_NO,
					W002.MATNR,
					M001.MATNR_NM,
					M001.UNIT,
				    SUM(W002.PRFM_QTY) AS PRFM_QTY,
				    NULL AS WRK_ORDR_NO,
				    NULL AS WRK_ORDR_SEQNO,
				    NULL AS ORDER_NO,
				    NULL AS SDOC_NO,
				    NULL AS SDOC_SEQNO,
				    NULL AS DOC_NO,
				    NULL AS DOC_SEQNO
			FROM	TB_WRK002 W002	INNER JOIN		TB_MAS001 M001	ON	W002.WERKS = M001.WERKS AND W002.MATNR = M001.MATNR
									LEFT OUTER JOIN TB_INV010 I010	ON	W002.WRK_ORDR_NO = I010.WRK_ORDR_NO
																	AND W002.WRK_ORDR_SEQNO = I010.WRK_ORDR_SEQNO
																	AND NVL(I010.CNL_YN, 'N') = 'N'
																	AND W002.LOT_NO = I010.LOT_NO
																	AND W002.IND_BCD = I010.IND_BCD
			WHERE 	W002.WERKS = P_WERKS
				AND	W002.MACH_CD = P_MACH_CD
				AND	W002.PRFM_DT = P_PRFM_DT
				AND	NVL(W002.CNL_YN , 'N') = 'N'
				AND	W002.ORDER_NO LIKE '%' || P_ORDER_NO || '%'
				AND	W002.IND_BCD LIKE '%' || P_IND_BCD || '%'
				AND NVL(W002.PRFM_GTHR_YN, 'N') = 'Y'
			GROUP BY W002.MATNR, M001.MATNR_NM, M001.UNIT
			
			ORDER BY 7 DESC, 5 DESC;
       	
       	
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
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;

        RETURN;
    --예외처리 종료
END ;
/
