
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK27_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK27_S01
 * PROGRAM NAME  : 재단작업 현황 조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 재단작업 현황를 관리한다.
 *                 
 * AUTHOR NAME   : 박충식
 * CREATE DATE   : 2022/06/08
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/06/08    1.0.0   박충식         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_INV001] 	: ( R  ) 공정재고 테이블
 *        - [TB_WRK002] 	: ( R  ) 생산실적 테이블
 *        - [TB_MAS012] 	: ( R  ) 설비 마스터 테이블
 *        - [V_WRK_ORDR] 	: ( R  ) 작업지시 뷰(가상 테이블)
 *=============================================================================*/


AS
	V_PRG_NM          	VARCHAR2(100) 	:= 'SP_WRK27_S01';     -- PROCEDURE NAME

	-- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  	EXCEPTION;
    E_SQL_ERR_CD      	NUMBER(5) 		:= 0;
    E_SQL_ERR_MSG		VARCHAR2(4000);

   -- JSON을 위한 변수선언 영역
    V_JSON				JSON_OBJECT_T;
    V_ARR_LIST       	JSON_ARRAY_T;
	V_OBJ            	JSON_OBJECT_T;

	-- 세션값 처리용 변수선언 영역
    V_SESS_USER_ID   	varchar2(20);
    V_PLT_CD         	varchar2(2);
   	V_DEBUG          	varchar2(1) := 'Y';

	-- 조건절 처리용 변수선언 영역
    V_SDATE             varchar2(20);			--생산시작일자
    V_EDATE             varchar2(20);			--생산종료일자
    V_CNL_YN            TB_WRK002.CNL_YN%TYPE;          --취소여부
    V_PCODE             TB_SCH017.PCODE%TYPE;			--지종
    V_BS_WGT	        TB_SCH017.BS_WGT%TYPE;          --평량
    V_WLEN	            TB_SCH017.WLEN%TYPE;            --가로길
    V_VLEN	            TB_SCH017.VLEN%TYPE;            --세로길
    V_PRFM_DT			TB_WRK002.PRFM_DT%TYPE;		--실적일자
	V_VBELN			TB_WRK002.VBELN%TYPE;				--판매문서번호
    V_POSNR			TB_WRK002.POSNR%TYPE;				--판매문서항목번호
    V_CUST_CD		TB_WRK002.KUNNR%TYPE;				--거래처코드
    V_LOT_NO		TB_WRK002.LOT_NO%TYPE;				--LOT번호
    V_IND_BCD		TB_WRK002.IND_BCD%TYPE;				--개별바코드
    
    V_MATNR             varchar2(20);
    V_MACH_CD           varchar2(20);  

	V_RANGE_SQL    VARCHAR2(4000);						--실적일자
	V_SQL				CLOB;

BEGIN
	OPEN P_RS_LIST FOR 

	SELECT NULL FROM DUAL WHERE ROWNUM = 0;

	V_JSON 				:= JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID		:= V_JSON.get_string('SES_USER_ID');
	V_PLT_CD			:= V_JSON.get_string('SES_PLNTKY');

    V_SDATE             := V_JSON.get_string('SDATE');			--생산시작일자
    V_EDATE             := V_JSON.get_string('EDATE');			--생산종료일자
	--V_PRFM_DT			:= V_JSON.get_string('PRFM_DT');		--실적일자
    V_PCODE             := V_JSON.get_string('PCODE');			--지종
    V_BS_WGT	        := V_JSON.get_string('BS_WGT');         --평량
    V_CNL_YN            := V_JSON.get_string('CNL_YN');         --취소여부
    --V_WLEN	            := V_JSON.get_string('WLEN');           --가로길
    --V_VLEN	            := V_JSON.get_string('VLEN');           --세로길

    --V_MATNR             varchar2(20);
    --V_MACH_CD           varchar2(20);  
    V_MATNR	        := V_JSON.get_string('MATNR');   
    V_MACH_CD	    := V_JSON.get_string('MACH_CD');
    
    V_VBELN			:=	V_JSON.get_string('VBELN');		--판매문서번호	
	V_POSNR		    :=	V_JSON.get_string('POSNR');		--판매문서항목번호
	V_CUST_CD	    :=	V_JSON.get_string('CUST_CD');	--거래처코드
	V_LOT_NO	    :=	V_JSON.get_string('LOT_NO');	--LOT번호
	V_IND_BCD	    :=	V_JSON.get_string('IND_BCD');	--개별바코드
 
	V_RANGE_SQL 	:= V_JSON.GET_STRING('RANGE_SQL');		--실적일자

	IF P_TYPE = 'LIST' THEN
		V_SQL := 'SELECT  M001.PCODE, 
                        M001.PCODE_NM, 
                        M001.BS_WGT,
                        CASE WHEN NVL(A.MAN_CUT_YN, ''N'') = ''N'' THEN  TO_NUMBER(SUBSTR(A.MATNR, 10, 4)) ELSE A.WLEN END AS WLEN,
                        CASE WHEN NVL(A.MAN_CUT_YN, ''N'') = ''N'' THEN  TO_NUMBER(SUBSTR(A.MATNR, 14, 4)) ELSE A.VLEN END AS VLEN,
                        A.MATNR, 
                        M001.MATNR_NM,
                        A.WRK_ORDR_NO,
                        FN_CMCDV(''PACK_TYPE'', S017.PACKTYPE) AS PACKTYPE,     --포장타입
                        CASE WHEN SUBSTR(A.MATNR, 5, 1) = ''2'' THEN ''수출'' ELSE ''내수'' END AS DOMESTIC,  --내수구분
						S017.KUNNR		AS CUST_CD, --거래처코드
                        S017.KUNNRT  AS CUST_NM,  --거래처명
                        FN_CD_VAL(''NTN_CD'', (SELECT LAND1 FROM TB_MAS009 WHERE S017.KUNNR = CUST_CD AND CUST_DIV = ''C'')) AS NTN_NM,  --국가명
                        A.MR_LOT_NO  AS MLOT_NO, --밀롤 LOTNO
                        CASE WHEN W002.IND_BCD IS NULL THEN I001_M.IND_BCD ELSE W002.IND_BCD END AS MIND_BCD, --밀롤개별바코드
                        CASE WHEN W002.PRD_DT IS NULL THEN I001_M.PRD_DT ELSE W002.PRD_DT END AS MPRD_DT, --밀롤 생산일자
                        FN_GET_CODE_NM(''MACH_CD'', A.WERKS, W002.MACH_CD) AS MACH_NM, --밀롤 설비명
                        (SELECT NMLAST FROM USRMA WHERE USERID = W002.REGID) AS MREGNM,       --밀롤 작업자
                        CASE WHEN W002.ROLLCNT IS NULL THEN I001_M.ROLLCNT ELSE W002.ROLLCNT END AS MROLLCNT, --밀롤 권치수
                        ''M''       AS MRUNIT,  --변경 밀롤 권치수 단위
                        --CASE WHEN W002.UNIT IS NULL THEN I001_M.UNIT ELSE W002.UNIT END AS MRUNIT, --밀롤 단위
                        W002.WIDTH                                      AS MWIDTH,       --밀롤지폭
                        S017.PLT_PER_CNT,       --팔레트당연수
                        ''R''    AS   PLTUNIT,  -- 팔레트당 연수 단위 --추가
                        FN_CMCDV(''LOC_CD'',I001.LOC_CD) AS LOC_CD, -- 로케이션
                        A.PRD_DT,   --재단 생산일자
                        A.PRFM_DT,  --재단 실적일자
                        A.PRD_STR_DATE AS PRD_STR_DT, --생산시작일자
                        A.PRD_END_DT, --생산종료일자
                        ROUND((A.PRD_END_DT - A.PRD_STR_DATE) * 24 * 60) AS TM2,        -- 생산시간(MES)
                        A.TM AS TM1,         -- 생산시간(SAP)
                        FN_GET_CODE_NM(''MACH_CD'', A.WERKS, A.MACH_CD) AS CMACH_NM, --재단 설비명
                        A.WRK_CLASS,        --반
                        (SELECT NMLAST FROM USRMA WHERE USERID = A.REGID) AS CREGNM,       --재단작업자
                        A.CLOT_NO,          --재단 LOTNO
                        A.CIND_BCD,         --재단 개별바코드
                        A.CUNIT,            --재단 실적 단위 -- 추가    
                        A.CPRFM_QTY,        --재단실적
                        A.CPCNT,            --재단연수
                        ''R''   AS CRUNIT,  --재단 연수 단위  --추가
                        A.CWGT,             --재단중량
                        ''KG''  AS CWUNIT,  --재단 중량 단위  --추가
                        S017.IN_PER_CNT,    --속당매수
                        ''EA''  AS CEUNIT,  --매수단위 -- 추가
                        A.CNL_YN,           --취소여부    
                        A.DISPO_CD,         --폐품코드
                        A.DISPO_PCNT,       --폐품연수
                        ''R''       AS DIRUNIT,  --폐품연수단위 --추가
                        A.DISPO_WGT,        --폐품중량
                        ''KG''       AS DIwUNIT,  --폐품중량단위 --추가
                        A.RMK,              --재단비고
                        S017.VBELN     AS VBELN, --판매문서번호
                        S017.POSNR     AS POSNR, --판매문서 품목번호(변경)
                        A.SDOC_NO,          --재단확정문서
                        A.SDOC_SEQNO,        --재단확정문서 순번
                        S017.COMP_YN    AS CUT_COMP_YN,    --재단 작업지시 완료여부      
                        S016.COMP_YN    AS MIL_COMP_YN    --밀롤 작업지시 완료여부      
                FROM(
                        SELECT /*+ INDEX(TB_WRK002 TB_WRK002_IDX2 +*/ WERKS, MACH_CD, MATNR, LOT_NO AS CLOT_NO, IND_BCD AS CIND_BCD,
                               WRK_ORDR_NO, WRK_ORDR_SEQNO,
                               PRD_DT, PRFM_DT, PRD_STR_DATE, PRD_END_DATE AS PRD_END_DT, TM, WRK_CLASS,
                               UNIT AS CUNIT, PRFM_QTY CPRFM_QTY, PCNT AS CPCNT, WGT AS CWGT,
                               '''' AS DISPO_CD, 0 AS DISPO_PCNT, 0 AS DISPO_WGT,
                               NVL(CNL_YN, ''N'') AS CNL_YN, RMK,
                               VBELN, POSNR, SDOC_NO, SDOC_SEQNO, REGID, DECODE(MER_YN, ''Y'', FN_LOT_TRK(FN_LOT_TRK(IND_BCD, 1), 1), FN_LOT_TRK(IND_BCD, 1)) AS MR_LOT_NO,
                               MAN_CUT_YN, WLEN, VLEN, MER_YN
                          FROM TB_WRK002
                         WHERE WERKS = ''P100''
                           AND MACH_CD IN (SELECT MACH_CD
                                             FROM TB_MAS012
                                            WHERE PROC_CD IN (''CA'') 
                                            ) ';
        
        V_SQL := V_SQL || ' AND NVL(PRFM_GTHR_YN, ''Y'') = ''Y''
                            AND NVL(CNL_YN, ''N'') = ''' || V_CNL_YN || ''' 
                         UNION ALL
                        SELECT /*+ INDEX(TB_WRK004 TB_WRK004_IDX2 +*/ WERKS, MACH_CD, MATNR, LOT_NO AS CLOT_NO, IND_BCD AS CIND_BCD,
                               WRK_ORDR_NO, WRK_ORDR_SEQNO,
                               TO_CHAR(REGDATE, ''YYYYMMDD'') AS PRD_DT, PRFM_DT, PRD_STR_DATE, PRD_END_DATE AS PRD_END_DT,
                               DECODE(TM, NULL, ROUND((NVL(WGT, 0)/1000) * 17), TM) AS TM,
                               --ROUND((PRD_END_DATE - PRD_STR_DATE) * 24 * 60) AS TM,
                               WRK_CLASS,
                               ''EA'' AS CUNIT, 0 AS CPRFM_QTY, 0 AS CPCNT, 0 AS CWGT,
                               DISPO_CD, (DISPO_QTY / 500) AS DISPO_PCNT, WGT AS DISPO_WGT,
                               NVL(CNL_YN, ''N'') AS CNL_YN, RMK,
                               '''' AS VBELN, 0 AS POSNR, SDOC_NO, SDOC_SEQNO, REGID, LOT_NO_M AS MR_LOT_NO,
                               ''N'' AS MAN_CUT_YN, NULL AS WLEN, NULL AS VLEN, ''N'' AS MER_YN
                          FROM TB_WRK004
                         WHERE WERKS = ''P100''
                           AND MACH_CD IN (SELECT MACH_CD
                                             FROM TB_MAS012
                                            WHERE PROC_CD IN (''CA'') 
                                            ) 
                           AND NVL(CNL_YN, ''N'') = ''' || V_CNL_YN || ''' 
                         UNION ALL  
                         SELECT WERKS, MACH_CD, MATNR, LOT_NO AS CLOT_NO, IND_BCD AS CIND_BCD,
                               WRK_ORDR_NO, WRK_ORDR_SEQNO,
                               TO_CHAR(REGDATE, ''YYYYMMDD'') AS PRD_DT, PRFM_DT, REGDATE AS PRD_STR_DATE, REGDATE AS PRD_END_DT, TM, WRK_CLASS,
                               ''EA'' AS CUNIT, 0 AS CPRFM_QTY, 0 AS CPCNT, 0 AS CWGT,
                               DISPO_CD, 
                               ROUND((WGT / (TO_NUMBER(SUBSTR(MATNR, 10, 4)) / 1000 * TO_NUMBER(SUBSTR(MATNR, 14, 4)) / 1000 * TO_NUMBER(SUBSTR(MATNR, 6, 3)) / 1000)) / 500, 3) AS DISPO_PCNT,                   
                               WGT AS DISPO_WGT,
                               NVL(CNL_YN, ''N'') AS CNL_YN, RMK,
                               '''' AS VBELN, 0 AS POSNR, SDOC_NO, SDOC_SEQNO, REGID, LOT_NO_M AS MR_LOT_NO,
                               ''N'' AS MAN_CUT_YN, NULL AS WLEN, NULL AS VLEN, ''N'' AS MER_YN
                          FROM TB_WRK022
                         WHERE WERKS = ''P100''
                           AND MACH_CD IN (SELECT MACH_CD
                                             FROM TB_MAS012
                                            WHERE PROC_CD IN (''CA'') 
                                            ) 
                           AND NVL(CNL_YN, ''N'') = ''' || V_CNL_YN || '''    
                         ORDER BY PRFM_DT, PRD_STR_DATE
                           ) A
                  JOIN TB_MAS001 M001
                  ON A.WERKS = M001.WERKS
                  AND A.MATNR = M001.MATNR
                  LEFT JOIN TB_WRK002 W002
                  ON A.MR_LOT_NO = W002.LOT_NO
                  AND NVL(W002.CNL_YN, ''N'') = ''N''
                  LEFT JOIN TB_INV001 I001_M
                  ON A.MR_LOT_NO = I001_M.LOT_NO
                  AND NVL(I001_M.DLFL, ''N'') = ''N''
                  LEFT JOIN TB_SCH016 S016
                  ON W002.WRK_ORDR_NO = S016.WRK_ORDR_NO
                  AND W002.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO
                  LEFT JOIN TB_SCH017 S017
                  ON S017.WRK_ORDR_NO = A.WRK_ORDR_NO
                  AND S017.WRK_ORDR_SEQNO = A.WRK_ORDR_SEQNO
                  LEFT JOIN TB_INV001 I001
                  ON A.CIND_BCD = I001.IND_BCD 
                  AND NVL(I001.DLFL, ''N'') = ''N''
             WHERE 1 = 1 ';
			   
        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'CUST_CD', 'S017.KUNNR');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MACH_CD', 'A.MACH_CD');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MATNR', 'A.MATNR');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'PCODE', 'M001.PCODE');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'BS_WGT', 'M001.BS_WGT');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'LOT_NO', 'A.CLOT_NO');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'IND_BCD', 'A.CIND_BCD');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'VBELN', 'S017.VBELN');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'POSNR', 'S017.POSNR');
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;
        
        /*IF V_VBELN IS NOT NULL OR TRIM(V_VBELN) != '' THEN								--판매문서번호
            V_SQL := V_SQL || ' AND S017.OVBELN LIKE ''' || V_VBELN || '%''';
        END IF;
       
        IF V_POSNR IS NOT NULL OR TRIM(V_POSNR) != '' THEN								--판매문서항목번호
            V_SQL := V_SQL || ' AND S017.OPOSNR LIKE ''' || V_POSNR || '%''';
        END IF;
       
        IF V_IND_BCD IS NOT NULL OR TRIM(V_IND_BCD) != '' THEN							--개별바코드
            V_SQL := V_SQL || ' AND A.CIND_BCD LIKE ''' || V_IND_BCD || '%''';
        END IF;*/
       
        IF (V_DEBUG = 'Y') THEN
        	INSERT INTO PROC_LOG (SQL_STR) VALUES (V_SQL);
            COMMIT;
        END IF;

		OPEN P_RS_LIST FOR V_SQL;

	END IF;

	P_SUCCESS := 'Y';

	/*EXCEPTION
    WHEN E_EXCEPTION_USER THEN

    	-- 에러 내역 SET
    	P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
		E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

		ROLLBACK;
		SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

	WHEN OTHERS THEN
		P_SUCCESS			:= 'N';
        E_SQL_ERR_CD        := SQLCODE;
		E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

		ROLLBACK;
		RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);*/
END;
/
