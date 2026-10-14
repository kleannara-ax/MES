--------------------------------------------------------
--  DDL for Procedure SP_WRK21_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK21_S01" (
	P_TYPE           IN    varchar2,
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
    P_ERR_MSG       OUT    VARCHAR2,
    P_DOC_NO1        OUT    VARCHAR2,       --폐품 실적 취소 문서
    P_DOC_NO2        OUT    VARCHAR2,       --실적취소 문서
--    P_DOC_NO3        OUT    VARCHAR2,       --투입자재 취소 문서
--    P_DOC_NO4        OUT    VARCHAR2,       --투입자재 등록 문서
    P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK21_S01
 * PROGRAM NAME  : 폐품 현황 
 * VERSION       : 1.0.0
 * DESCRIPTION   : 폐품 현황을 관리한다.
 *                 
 * AUTHOR NAME   : 안상현
 * CREATE DATE   : 2022/07/11
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/07/11    1.0.0   안상현         Initial Version
 * 2022 08/30    1.0.1   박성철
 *==============================================================================
 *  관련 테이블
 *        - [TB_WRK004] 	: ( R  ) 폐품 실적(PS, HL(합지기))
 *        - [TB_WRK016] 	: ( R  ) 폐품등록현황(HL)	
 *        - [TB_WRK001] 	: ( R  ) 실적테이블(HL)	
 *        - [TB_WRK002] 	: ( R  ) 실적테이블(PS)	
 *        - [TB_MAS023] 	: ( R  ) 폐품(불량)항목 관리	
 *        - [TB_MAS012] 	: ( R  ) 설비 마스트 정보	
 *        - [TB_MAS013] 	: ( R  ) 공정 마스터 정보	
 *        - [V_WRK_ORDR] 	: ( R  ) 작업지시 가상 테이블(VIEW)
 *=============================================================================*/

AS
	V_PRG_NM          	VARCHAR2(100) 	:= 'SP_WRK21_S01';     -- PROCEDURE NAME

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
	V_WERKS          	TB_WRK004.WERKS%TYPE; 			--플랜트코드
	V_PROC_CD         	TB_MAS024.PROC_CD%TYPE; 		--공정코드
	V_MACH_CD         	TB_WRK004.MACH_CD%TYPE; 		--설비코드
	V_RANGE_SQL      	varchar2(4000);					--실적일자

    V_DATE              DATE := SYSDATE;
	V_SQL				CLOB;

    V_DOC_NO_1          VARCHAR2(20);
    V_DOC_NO_2          VARCHAR2(20);
    V_DOC_NO_3          VARCHAR2(20);
    V_DOC_NO_4          VARCHAR2(20);
    V_DOC_NO            VARCHAR2(20);
    V_DOC_SEQNO_1       NUMBER;
    V_DOC_SEQNO_2       NUMBER;
    V_DOC_SEQNO_3       NUMBER;
    V_DOC_SEQNO_4       NUMBER;
    V_DOC_SEQNO         NUMBER;

    V_SDOC_NO           VARCHAR2(20); 
    V_SDOC_SEQNO        VARCHAR2(20); 
    V_WRK_ORDR_NO       VARCHAR2(20);
    V_WRK_ORDR_SEQNO    NUMBER;
    V_ORDER_NO          VARCHAR2(20);
    V_IND_BCD           VARCHAR2(20);
    V_LOT_NO            VARCHAR2(10);
    V_IND_BCD_M         VARCHAR2(20);
    V_LOT_NO_M          VARCHAR2(10);
    V_MATNR_M           VARCHAR2(20);
    V_DISPO_QTY         NUMBER(13,3);
    V_PRFM_DT           VARCHAR2(10);
    V_CNL_RMK           VARCHAR2(100);
    V_SAP_WRK_CD        VARCHAR2(10);    
    V_DOC_DIV           VARCHAR2(5);
    V_B_SEQNO_M         TB_INV010.SEQNO%TYPE;
    V_B_INP_DT_M        TB_INV010.INP_DT%TYPE;
    V_B_USE_QTY_M       TB_INV010.USE_QTY%TYPE;
    V_B_UNIT_M          TB_INV010.UNIT%TYPE;
    V_B_ROLLCNT_M       TB_INV010.ROLLCNT%TYPE;
    V_B_WGT_M           TB_INV010.INP_DT%TYPE;    
    V_B_CHG_FLG_M       TB_INV010.CHG_FLG%TYPE;
    V_B_STCK_KY_M       TB_INV010.STCK_KY%TYPE;
    V_B_LOT_NUM_M       TB_INV010.LOT_NUM%TYPE;
    V_B_USE_DIV         TB_INV010.USE_DIV%TYPE;
    V_RUNTIME			TB_WRK001.TM%TYPE; --실적 가동시간
    V_STOR_LOC_CD       VARCHAR2(10);
    PROD_CUR            SYS_REFCURSOR;		-- 커서 정의
    V_PAUFNR            TB_WRK001.PAUFNR%TYPE;

    P_CHRT_TYPE      	VARCHAR2(200);		     --차트타입
    v_DISPO_CD          TB_MAS023.DISPO_CD%TYPE; --폐품코드

BEGIN
	OPEN P_RS_LIST FOR 

	SELECT NULL FROM DUAL WHERE ROWNUM = 0;

	V_JSON 				:= JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID		:= V_JSON.get_string('SES_USER_ID');
	V_PLT_CD			:= V_JSON.get_string('SES_PLNTKY');

	V_WERKS				:= V_JSON.get_string('WERKS'); 		--플랜트코드
    V_PROC_CD			:= V_JSON.get_string('PROC_CD'); 	--공정코드
    V_MACH_CD			:= V_JSON.get_string('MACH_CD'); 	--생산호기
	V_CNL_RMK           := V_JSON.get_string('CNL_RMK');	--취소사유
    V_RANGE_SQL         := V_JSON.get_string('RANGE_SQL');	--실적일자

    P_CHRT_TYPE         := V_JSON.get_string('P_CHRT_TYPE');  --차트타입
    v_DISPO_CD          := V_JSON.get_string('CHRT_PRM2');    --폐품코드(차트파람)


	IF P_TYPE = 'LIST' THEN
		V_SQL := 
		' SELECT
			    A.WERKS                     				AS WERKS            --플랜트코드
			,   A.PRFM_DT                   				AS PRFM_DT          --실적일자
			,   A.WRK_ORDR_NO               				AS WRK_ORDR_NO      --작업지시번호
			,   A.WRK_ORDR_SEQNO            				AS WRK_ORDR_SEQNO   --작업지시순번
			,   MAS012.PROC_CD                				AS PROC_CD          --공정코드
			,   MAS013.PROC_NM              				AS PROC_NM          --공정명
			,   A.MACH_CD                   				AS MACH_CD          --설비코드
			,   MAS012.MACH_NM              				AS MACH_NM          --설비명
			,   MAS012.MACHINE              				AS MACHINE          --생산호기
			,   A.ORDER_NO               					AS ORDER_NO         --오더번호
            ,   A.LOT_NO                 	 			    AS LOT_NO           --LOT NO(그리드에 보이지 않아도됨)
            ,   A.IND_BCD                 	 			    AS IND_BCD          --개별바코드(그리드에 보이지 않아도됨)
            ,   A.MATNR_M                 	 			    AS MATNR_M          --투입자재 코드
            ,   A.IND_BCD_M                 	 			AS IND_BCD_M        --투입자재 개별바코드
			,   A.LOT_NO_M                   	 			AS LOT_NO_M         --투입자재 LOT번호
            ,   A.UNIT                      				AS UNIT             --단위코드
			,   FN_CD_VAL(''UNIT'',A.UNIT)    				AS UNIT_NM          --단위명
			,   A.DISPO_QTY                 				AS DISPO_CAPA_QTY   --폐품수량
			,   A.PRFM_QTY                 					AS PRFM_QTY        	--실적량
			,	A.DISPO_CD									AS DISPO_CD			--폐품코드
			,	MAS023.DISPO_NM								AS DISPO_NM			--폐품명
			,	FN_CD_VAL(''PROCGRP'',MAS023.DISPO_DIV)		AS DISPO_DIV_NM		--폐품유형명
			,	A.REGID										AS REGID			--등록자ID
			,	USR.NMLAST 									AS REGNM			--등록자명
			,	A.WRK_SHIFT									AS WRK_SHIFT		--작업조
			,	A.WRK_CLASS									AS WRK_CLASS		--작업반
			,	A.REGDATE									AS REGDATE			--등록일시
			,   A.WGT                     				    AS DISPO_CAPA_WGT   --폐품중량
			FROM
			(
			SELECT
			    WRK004.WERKS            AS WERKS            --플랜트코드
			,   WRK004.PRFM_DT          AS PRFM_DT          --실적일자
			,   WRK004.WRK_ORDR_NO      AS WRK_ORDR_NO      --작업지시번호
			,   WRK004.WRK_ORDR_SEQNO   AS WRK_ORDR_SEQNO   --작업지시순번
			,   WRK004.MACH_CD          AS MACH_CD          --설비코드
            ,	WRK002.ORDER_NO			AS ORDER_NO			--오더번호
            ,   WRK004.IND_BCD          AS IND_BCD          --개별바코드(그리드에 보이지 않아도됨)
            ,	WRK004.LOT_NO			AS LOT_NO			--LOT NO
            ,	WRK004.MMATNR			AS MATNR_M			--투입자재코드
			,	WRK004.IND_BCD_M		AS IND_BCD_M		--투입자재 개별바코드
            ,   WRK004.LOT_NO_M         AS LOT_NO_M         --투입자재 LOT번호
            ,   WRK004.UNIT             AS UNIT             --단위코드
			,   WRK002.PRFM_QTY         AS PRFM_QTY         --PS 실적수량
			,   WRK004.DISPO_QTY        AS DISPO_QTY        --폐품수량
			,   WRK004.DISPO_CD         AS DISPO_CD         --폐품코드
			,	WRK004.REGID			AS REGID			--등록자ID
			,	WRK004.WRK_SHIFT		AS WRK_SHIFT		--작업조
			,	WRK004.WRK_CLASS		AS WRK_CLASS		--작업반
			,	WRK004.REGDATE			AS REGDATE			--등록일시
			,	WRK004.WGT				AS WGT				--중량
			FROM
			    TB_WRK004 WRK004
			LEFT JOIN
			(
			    SELECT
			        WRK002.WRK_ORDR_NO      AS WRK_ORDR_NO     	--작업지시번호
			    ,   WRK002.WRK_ORDR_SEQNO   AS WRK_ORDR_SEQNO  	--작업지시순번
			    ,	WRK002.ORDER_NO			AS ORDER_NO			--오더번호
			    ,   SUM(WRK002.PRFM_QTY)    AS PRFM_QTY        	--PS실적수량
			    FROM
			        TB_WRK002 WRK002
                WHERE NVL(CNL_YN, ''N'') = ''N''   
			    GROUP BY WRK002.WRK_ORDR_NO, WRK002.WRK_ORDR_SEQNO, WRK002.ORDER_NO
			) WRK002 ON (WRK002.WRK_ORDR_NO = WRK004.WRK_ORDR_NO AND WRK002.WRK_ORDR_SEQNO = WRK004.WRK_ORDR_SEQNO)
			WHERE 1=1
			AND WRK004.WERKS = ''P100''
			AND NVL(WRK004.CNL_YN, ''N'') = ''N''
			UNION ALL

			SELECT
			    WRK004.WERKS            AS WERKS            --플랜트코드
			,   WRK004.PRFM_DT          AS PRFM_DT          --실적일자
			,   WRK004.WRK_ORDR_NO      AS WRK_ORDR_NO      --작업지시번호
			,   WRK004.WRK_ORDR_SEQNO   AS WRK_ORDR_SEQNO   --작업지시순번
			,   WRK004.MACH_CD          AS MACH_CD          --설비코드
			,	WRK001.ORDER_NO			AS ORDER_NO			--오더번호
            ,   WRK004.IND_BCD          AS IND_BCD          --개별바코드(그리드에 보이지 않아도됨)
            ,	WRK004.LOT_NO			AS LOT_NO			--LOT NO
            ,	WRK004.MMATNR			AS MATNR_M			--투입자재코드
            ,	WRK004.IND_BCD_M		AS IND_BCD_M		--투입자재 개별바코드
			,   WRK004.LOT_NO_M         AS LOT_NO_M         --투입자재 LOT번호
            ,   WRK004.UNIT             AS UNIT             --단위코드
			,   WRK001.PRFM_QTY         AS PRFM_QTY         --HL(합지기) 실적수량
			,   WRK004.DISPO_QTY        AS DISPO_QTY        --폐품수량
			,   WRK004.DISPO_CD         AS DISPO_CD         --폐품코드
			,	WRK004.REGID			AS REGID			--등록자ID
			,	WRK004.WRK_SHIFT		AS WRK_SHIFT		--작업조
			,	WRK004.WRK_CLASS		AS WRK_CLASS		--작업반
			,	WRK004.REGDATE			AS REGDATE			--등록일시
			,	WRK004.WGT				AS WGT				--중량
			FROM
			    TB_WRK004 WRK004
			LEFT JOIN
			(
			    SELECT
			        WRK001.WRK_ORDR_NO      AS WRK_ORDR_NO     	--작업지시번호
			    ,   WRK001.WRK_ORDR_SEQNO   AS WRK_ORDR_SEQNO  	--작업지시순번
			    ,	WRK001.ORDER_NO			AS ORDER_NO			--오더번호
                ,   WRK001.IND_BCD          AS IND_BCD          --개별바코드
                ,   WRK001.PRFM_GTHR_YN     AS PRFM_GTHR_YN     --실적집계여부
			    ,   SUM(WRK001.PRFM_QTY)    AS PRFM_QTY        	--HL(합지기) 실적수량
			    FROM
			        TB_WRK001 WRK001
                WHERE NVL(CNL_YN, ''N'') = ''N''    
                  AND NVL(PRFM_GTHR_YN, ''Y'') = ''Y''
			    GROUP BY WRK001.WRK_ORDR_NO, WRK001.WRK_ORDR_SEQNO, WRK001.ORDER_NO, WRK001.IND_BCD, WRK001.PRFM_GTHR_YN
			) WRK001 ON (WRK001.WRK_ORDR_NO = WRK004.WRK_ORDR_NO AND WRK001.WRK_ORDR_SEQNO = WRK004.WRK_ORDR_SEQNO AND WRK001.IND_BCD = WRK004.IND_BCD)
			WHERE 1=1
			AND WRK004.WERKS != ''P100''
			AND NVL(WRK004.CNL_YN, ''N'') = ''N''
            --AND NVL(WRK001.PRFM_GTHR_YN, ''Y'') = ''Y''     --YSH 2022.09.14 
            UNION ALL

			SELECT
			    WRK016.WERKS            AS WERKS            --플랜트코드
			,   WRK016.PRFM_DT          AS PRFM_DT          --실적일자
			,   WRK016.WRK_ORDR_NO      AS WRK_ORDR_NO      --작업지시번호
			,   WRK016.WRK_ORDR_SEQNO   AS WRK_ORDR_SEQNO   --작업지시순번
			,   WRK016.MACH_CD          AS MACH_CD          --설비코드
			,	WRK016.ORDER_NO			AS ORDER_NO			--오더번호
			,   WRK016.IND_BCD          AS IND_BCD          --개별바코드
            ,   WRK016.LOT_NO           AS LOT_NO           --LOT번호
            ,   WRK016.MATNR_M          AS MATNR_M          --투입자재코드
            ,   WRK016.IND_BCD_M        AS IND_BCD_M          --투입자재 개별바코드
            ,   WRK016.LOT_NO_M         AS LOT_NO_M         --투입자재 LOT NO
			,   WRK016.UNIT             AS UNIT             --단위코드
			,   CASE WHEN WRK016.UNIT = ''KG'' THEN WRK016.PRFM_WGT ELSE WRK016.PRFM_QTY END         AS PRFM_QTY         --실적수량
			,   CASE WHEN WRK016.UNIT = ''KG'' THEN WRK016.DISPO_WGT ELSE WRK016.DISPO_QTY END        AS DISPO_QTY        --폐품수량
			,   WRK016.DISPO_CD         AS DISPO_CD         --폐품코드
			,	WRK016.REGID			AS REGID			--등록자ID
			,	WRK016.WRK_SHIFT		AS WRK_SHIFT		--작업조
			,	WRK016.WRK_CLASS		AS WRK_CLASS		--작업반
			,	WRK016.REGDATE			AS REGDATE			--등록일시
			,	WRK016.DISPO_WGT		AS WGT				--폐품중량
			FROM
			    TB_WRK016 WRK016
             WHERE NVL(WRK016.CNL_YN, ''N'') = ''N''
		   UNION ALL  --총괄님 지시로 추가
			SELECT 
			       WERKS
			     , PRFM_DT
			     , WRK_ORDR_NO
			     , WRK_ORDR_SEQNO
			     , MACH_CD
			     , ORDER_NO
			     , IND_BCD
			     , LOT_NO
			     , MATNR_M
			     , IND_BCD_M
			     , LOT_NO_M
			     , UNIT
			     , NULL PRFM_QTY      --실적수량
				 , DISPO_QTY          --폐품수량
			     , DISPO_CD
			     , REGID
			     , WRK_SHIFT
			     , WRK_CLASS
			     , REGDATE
			     , WGT
			  FROM TB_WRK022
	 		 WHERE 1=1 
               AND PRFM_GTHR_YN = ''Y'' AND NVL(CNL_YN, ''N'') = ''N''
			) A
			LEFT JOIN TB_MAS012 MAS012 ON (MAS012.MACH_CD = A.MACH_CD)
			LEFT JOIN TB_MAS013 MAS013 ON (MAS013.PROC_CD = MAS012.PROC_CD)
			LEFT JOIN TB_MAS023 MAS023 ON (MAS023.WERKS = A.WERKS AND MAS023.DISPO_CD = A.DISPO_CD)
			LEFT JOIN USRMA USR ON (USR.USERID = A.REGID)
			WHERE 1=1 ';

		IF (V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '') THEN               
			V_SQL := V_SQL || ' AND A.WERKS = ''' || V_WERKS || '''';			--플랜트        
        END IF;

       	IF (V_PROC_CD IS NOT NULL OR TRIM(V_PROC_CD) != '') THEN                   
			V_SQL := V_SQL || ' AND MAS012.PROC_CD LIKE ''%' || V_PROC_CD || '%''';	--공정코드
        END IF;

       	IF (V_MACH_CD IS NOT NULL OR TRIM(V_MACH_CD) != '') THEN                   
			V_SQL := V_SQL || ' AND A.MACH_CD LIKE ''%' || V_MACH_CD || '%''';		--설비코드
        END IF;

       	IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_SQL := V_SQL || V_RANGE_SQL ;			                       	    --실적일자  
        END IF;







		IF P_CHRT_TYPE = 'loadChrt1Bar' THEN  --공정별 폐품현황

			V_SQL := ' WITH BASE AS ( ' || V_SQL ||  ' ) ';
			V_SQL := V_SQL || ' SELECT PROC_CD
					  		         , PROC_NM
								     --, SUM(NVL(DISPO_CAPA_WGT, 0) ) WGT
								     , TRUNC(SUM(
								     	 NVL(DECODE(UNIT, ''KG'',DISPO_CAPA_WGT, DISPO_CAPA_QTY), 0)
								       ), 2) WGT
								  FROM BASE
								 GROUP BY PROC_CD, PROC_NM
								 ORDER BY PROC_NM ';


		ELSIF P_CHRT_TYPE = 'loadChrt2Pie' THEN  --유형별 폐품비율

			V_SQL := ' WITH BASE AS ( ' || V_SQL ||  ' ) ';
			V_SQL := V_SQL || ' SELECT DISPO_CD
								     , DISPO_NM
								     , CASE WHEN TOT.WGT = 0 THEN 0
								            ELSE TRUNC(BASE.WGT * 100 / TOT.WGT, 2) END WGT
								  FROM (
									SELECT DISPO_CD
									     , DISPO_NM
									     --, SUM(NVL(DISPO_CAPA_WGT, 0) ) WGT
										 , SUM(NVL(DECODE(UNIT, ''KG'',DISPO_CAPA_WGT, DISPO_CAPA_QTY), 0) ) WGT
									  FROM BASE
									 WHERE 1=1 ';

			V_PROC_CD			:= V_JSON.get_string('CHRT_PRM'); 	--차트파람
			V_SQL := V_SQL || ' AND PROC_CD = ''' || V_PROC_CD || ''' ';

			V_SQL := V_SQL ||   ' GROUP BY DISPO_CD, DISPO_NM
								  ) BASE
								  JOIN (SELECT SUM(NVL(DECODE(UNIT, ''KG'',DISPO_CAPA_WGT, DISPO_CAPA_QTY), 0)) WGT
										  FROM BASE
								         WHERE 1=1';

			V_SQL := V_SQL || ' AND PROC_CD = ''' || V_PROC_CD || ''' ) TOT ON 1=1';
			V_SQL := V_SQL || ' ORDER BY DISPO_NM ';


--			V_SQL := ' WITH BASE AS ( ' || V_SQL ||  ' ) ';
--			V_SQL := V_SQL || '  SELECT DISPO_CD
--			                          , DISPO_NM
--								      , SUM(NVL(DISPO_CAPA_WGT, 0) ) WGT
--								   FROM BASE
--								   --LEFT JOIN TB_MAS023 MAS023  --폐품(불량)항목 관리
--								     --ON DISPO_CD = BASE.DISPO_CD
--								    --AND WERKS = BASE.WERKS
--								  WHERE 1=1 ';
--						
--			V_PROC_CD			:= V_JSON.get_string('CHRT_PRM'); 	--차트파람
--			V_SQL := V_SQL || ' AND PROC_CD = ''' || V_PROC_CD || ''' ';
--			
--			V_SQL := V_SQL ||   ' GROUP BY DISPO_CD, DISPO_NM
--						          ORDER BY DISPO_NM ';


		ELSIF P_CHRT_TYPE = 'loadChrt3Bar' THEN  --폐품 전월대비 당월현황

			V_SQL := ' WITH BASE AS ( ' || V_SQL ||  ' ) ';
			V_SQL := V_SQL || '  SELECT 
								       --NVL(SUM(CASE WHEN PRFM_DT < TO_CHAR(SYSDATE, ''YYYYMM'') || ''01''
								            --THEN DISPO_CAPA_WGT ELSE 0 END), 0) AS PRV_MNTH   --PRE_MNTH_WGT_SUM
								     --, NVL(SUM(CASE WHEN PRFM_DT > TO_CHAR(LAST_DAY(ADD_MONTHS(SYSDATE,-1)), ''YYYYMMDD'')
								            --THEN DISPO_CAPA_WGT ELSE 0 END), 0) AS THIS_MNTH   --CUR_MNTH_WGT_SUM
								       SUM(NVL(CASE WHEN PRFM_DT < TO_CHAR(SYSDATE, ''YYYYMM'') || ''01''
								            THEN DECODE(UNIT, ''KG'',DISPO_CAPA_WGT, DISPO_CAPA_QTY) ELSE 0 END, 0)) AS PRV_MNTH   --PRE_MNTH_WGT_SUM
								     , SUM(NVL(CASE WHEN PRFM_DT > TO_CHAR(LAST_DAY(ADD_MONTHS(SYSDATE,-1)), ''YYYYMMDD'')
								            THEN DECODE(UNIT, ''KG'',DISPO_CAPA_WGT, DISPO_CAPA_QTY) ELSE 0 END, 0)) AS THIS_MNTH   --CUR_MNTH_WGT_SUM
								  FROM BASE
								  WHERE 1=1 ';

			V_PROC_CD			:= V_JSON.get_string('CHRT_PRM'); 	       --공정코드(차트파람)
			V_SQL := V_SQL || ' AND PROC_CD = ''' || V_PROC_CD || ''' ';

			V_SQL := V_SQL || ' AND DISPO_CD = ''' || v_DISPO_CD || ''' ';  --폐품코드(차트파람)

			V_SQL := V_SQL ||   ' AND PRFM_DT BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE,-1), ''YYYYMM'') || ''01''
	               				                  AND TO_CHAR(LAST_DAY(SYSDATE), ''YYYYMMDD'') ';


		ELSE

			V_SQL := V_SQL || ' ORDER BY A.WERKS, A.PRFM_DT';

		END IF;




        V_DEBUG := 'Y';

        IF (V_DEBUG = 'Y') THEN
        	INSERT INTO PROC_LOG (SQL_STR) VALUES (V_SQL);
        END IF;





		OPEN P_RS_LIST FOR V_SQL;







	ELSIF P_TYPE = 'DELETE' THEN        --폐품삭제
        V_ARR_LIST        := V_JSON.get_array('list');

        --SAP 페품실적 취소 전송 문서번호
        V_DOC_SEQNO_1 := 0;
        V_DOC_NO_1 := FN_GET_MDOCNO('M','IF144');

        --SAP 실적취소 전송 문서번호
        V_DOC_SEQNO_2 := 0;
        V_DOC_NO_2 := FN_GET_MDOCNO('M','IF129');

--        --SAP 투입자재취소 전송 문서번호
--        V_DOC_SEQNO_3 := 0;
--        V_DOC_NO_3 := FN_GET_MDOCNO('M','IF143');
--        
--        --SAP 투입자재 전송 문서번호
--        V_DOC_SEQNO_4 := 0;
--        V_DOC_NO_4 := FN_GET_MDOCNO('M','IF130');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ               := TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ               := TREAT (V_OBJ.get ('map') AS json_object_t);

            V_WERKS             := V_OBJ.get_string('WERKS');
            V_MACH_CD           := V_OBJ.get_string('MACH_CD');
            V_WRK_ORDR_NO       := V_OBJ.get_string('WRK_ORDR_NO');
            V_WRK_ORDR_SEQNO    := V_OBJ.get_string('WRK_ORDR_SEQNO');
            V_ORDER_NO          := V_OBJ.get_string('ORDER_NO');

            V_IND_BCD           := V_OBJ.get_string('IND_BCD');       --개별바코드
            V_LOT_NO           := V_OBJ.get_string('LOT_NO');       --개별바코드
            V_IND_BCD_M         := V_OBJ.get_string('IND_BCD_M');     --투입자재 개별바코드
            V_LOT_NO_M          := V_OBJ.get_string('LOT_NO_M');      --투입자재 LOT NO
            V_MATNR_M           := V_OBJ.get_string('MATNR_M');       --투입자재 코드  
            V_DISPO_QTY         := V_OBJ.get_string('DISPO_QTY');
            V_PRFM_DT           := V_OBJ.get_string('PRFM_DT');

            SELECT PROC_CD, SAP_WRK_CD INTO V_PROC_CD, V_SAP_WRK_CD
              FROM TB_MAS012
             WHERE MACH_CD = V_MACH_CD; 
--            P_SUCCESS := 'N';
--            P_ERR_MSG := V_WERKS || '-' || V_MACH_CD || '-' || V_WRK_ORDR_NO || '-' || V_WRK_ORDR_SEQNO || '-' || V_IND_BCD;
--            ROLLBACK;
--            RETURN;  
            OPEN PROD_CUR FOR
                SELECT DOC_NO, DOC_SEQNO, DOC_DIV, IND_BCD, ORDER_NO, SDOC_NO, SDOC_SEQNO
                        INTO V_DOC_NO, V_DOC_SEQNO, V_DOC_DIV, V_IND_BCD, V_ORDER_NO, V_SDOC_NO, V_SDOC_SEQNO
                    FROM TB_WRK021
                   WHERE WERKS = V_WERKS
                     AND MACH_CD = V_MACH_CD
                     AND WRK_ORDR_NO = V_WRK_ORDR_NO
                     AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                     AND IND_BCD = V_IND_BCD
                     AND CNL_YN = 'N'
                   ORDER BY DOC_DIV;
            LOOP
            FETCH PROD_CUR INTO V_DOC_NO, V_DOC_SEQNO, V_DOC_DIV, V_IND_BCD, V_ORDER_NO, V_SDOC_NO, V_SDOC_SEQNO;

            EXIT WHEN PROD_CUR %NOTFOUND;     

                UPDATE TB_WRK021
                   SET CNL_YN = 'Y'
                 WHERE DOC_NO = V_DOC_NO
                   AND DOC_SEQNO = V_DOC_SEQNO;
                IF V_WERKS <> 'P100' THEN
                    --실적 취소 문서 전송(합지기(와딩티슈제외), 생리대, 기저귀는 
                    --폐품등록 시 폐품처리시 실적등록을 하기때문에 실적취소를 함
                    IF V_DOC_DIV = '1' THEN
                        V_DOC_SEQNO_2 :=  V_DOC_SEQNO_2 + 1;

                        IF SUBSTR(V_MACH_CD, 2, 2) = 'AA' OR SUBSTR(V_MACH_CD, 2, 2) = 'RA' THEN -- 합지기/화장지
                            IF SUBSTR(V_MACH_CD, 2, 2) = 'AA' THEN
                                BEGIN
                                SELECT TM INTO V_RUNTIME
                                  FROM TB_WRK001
                                 WHERE WERKS = V_WERKS
                                   AND MACH_CD = V_MACH_CD
                                   AND IND_BCD = V_IND_BCD;
                                EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                        V_RUNTIME := 0;
                                END;
                            END IF;

                            INSERT INTO TB_IFS007(RUECK, RMZHL, MDOCNO, MDOCSEQ, MAKE_DATE, MAKER,
                                                WORKCENTERCODE, AUFNR, ROLLCNT, MBLNR, LOTNO)
                                   VALUES(V_SDOC_NO, V_SDOC_SEQNO, V_DOC_NO_2, TO_CHAR(V_DOC_SEQNO_2), V_DATE, V_SESS_USER_ID,
                                        V_SAP_WRK_CD, V_ORDER_NO, CASE WHEN SUBSTR(V_MACH_CD, 2, 2) = 'AA' AND V_RUNTIME > 0 THEN V_RUNTIME  ELSE NULL END ,
                                        V_SDOC_NO, V_LOT_NO);
                        ELSE
                            SELECT PAUFNR  INTO V_PAUFNR
                              FROM TB_WRK001
                             WHERE WERKS = V_WERKS
                               AND MACH_CD = V_MACH_CD
                               AND IND_BCD = V_IND_BCD;

                            INSERT INTO TB_IFS007(RUECK, RMZHL, MDOCNO, MDOCSEQ, MAKE_DATE, MAKER,
                                                WORKCENTERCODE, AUFNR, ROLLCNT, MBLNR, LOTNO)
                                   VALUES(V_SDOC_NO, V_SDOC_SEQNO, V_DOC_NO_2, TO_CHAR(V_DOC_SEQNO_2), V_DATE, V_SESS_USER_ID,
                                        V_SAP_WRK_CD, V_PAUFNR, '', V_SDOC_NO, V_LOT_NO);
                        END IF;

                        UPDATE TB_WRK001
                           SET CNL_YN = 'Y',
                               CNL_RMK = V_CNL_RMK,
                               UPDDATE = V_DATE,
                               UPDID = V_SESS_USER_ID
                         WHERE WERKS = V_WERKS
                           AND MACH_CD = V_MACH_CD
                           AND IND_BCD = V_IND_BCD;
                    END IF;

                    --폐품취소 전송
                    IF V_DOC_DIV = '2' THEN
                        --폐품취소 전송
                        V_DOC_SEQNO_1 := V_DOC_SEQNO_1 + 1;

--                       P_SUCCESS := 'N';
--                        P_ERR_MSG := V_SAP_WRK_CD || '-' ||  V_ORDER_NO || '-' ||  '10' || '-' ||  V_PRFM_DT || '-' ||  V_MATNR_M || '-' ||  V_DISPO_QTY || '-' || 
--                                             V_WERKS || '-' ||  V_STOR_LOC_CD || '-' ||  V_LOT_NO_M || '-' ||  V_DOC_NO_1 || '-' ||  TO_CHAR(V_DOC_SEQNO_1) || '-' ||  V_SDOC_NO || '-' ||  V_SDOC_SEQNO || '-' ||  V_DATE;
--                        ROLLBACK;
--                        RETURN;  
--                        
                        SELECT LGPRO  INTO V_STOR_LOC_CD
                          FROM TB_MAS001
                         WHERE WERKS = V_WERKS 
                           AND MATNR = V_MATNR_M;

                        INSERT INTO TB_IFS022(WORKCENTERCODE, AUFNR, POSNR, BUDAT, MATNR, MENGE,
                                                WERKS, LGORT, CHARG, MDOCNO, MDOCSEQ, MBLNR, MJAHR, MAKE_DATE)
                                      VALUES(V_SAP_WRK_CD, V_ORDER_NO, '10', V_PRFM_DT, V_MATNR_M, V_DISPO_QTY,
                                             V_WERKS, V_STOR_LOC_CD, V_LOT_NO_M, V_DOC_NO_1, TO_CHAR(V_DOC_SEQNO_1), V_SDOC_NO, V_SDOC_SEQNO, V_DATE);     


                        IF  V_PROC_CD = 'RA' OR V_PROC_CD = 'RB' OR V_PROC_CD = 'RC' THEN  --화장지, 생리대, 기저귀 가공기
                            UPDATE TB_WRK016
                               SET DISPO_QTY = 0,
                                   DISPO_WGT = 0,
                                   CNL_YN = 'Y',
                                   CNL_RMK = V_CNL_RMK,
                                   UPDDATE = V_DATE,
                                   UPDID = V_SESS_USER_ID
                             WHERE WERKS = V_WERKS
                               AND MACH_CD = V_MACH_CD
                               AND WRK_ORDR_NO = V_WRK_ORDR_NO
                               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                               AND IND_BCD = V_IND_BCD;
                        ELSE
                            UPDATE TB_WRK004
                               SET CNL_YN = 'Y',
                                   CNL_RMK = V_CNL_RMK,
                                   UPDDATE = V_DATE,
                                   UPDID = V_SESS_USER_ID
                             WHERE WERKS = V_WERKS
                               AND MACH_CD = V_MACH_CD
                               AND IND_BCD = V_IND_BCD;
                        END IF;
                    END IF;

                    --투입자재 취소 문서 전송
                    IF V_DOC_DIV = '5' THEN                        
                        SELECT SEQNO, INP_DT, USE_QTY, UNIT, ROLLCNT, WGT, CHG_FLG, STCK_KY, LOT_NUM, USE_DIV
                            INTO
                            V_B_SEQNO_M, V_B_INP_DT_M, V_B_USE_QTY_M, V_B_UNIT_M, 
                            V_B_ROLLCNT_M, V_B_WGT_M, V_B_CHG_FLG_M, V_B_STCK_KY_M, V_B_LOT_NUM_M, V_B_USE_DIV
                          FROM TB_INV010
                         WHERE WERKS = V_WERKS 
                           AND MACH_CD = V_MACH_CD
                           AND IND_BCD = V_IND_BCD
                           AND DOC_NO = V_DOC_NO
                           AND DOC_SEQNO = V_DOC_SEQNO
                           AND NVL(CNL_YN, 'N') = 'N';

                         IF V_B_USE_DIV = '1' OR (V_B_USE_DIV = '2' AND V_B_USE_QTY_M > 0) THEN       
                            UPDATE TB_INV003
                               SET USE_QTY = USE_QTY - V_B_USE_QTY_M,
                                   STCK_QTY = STCK_QTY +  V_B_USE_QTY_M
                             WHERE WERKS = V_WERKS
                               AND MACH_CD = V_MACH_CD
                               AND IND_BCD = V_IND_BCD_M;  

                             IF SQL%ROWCOUNT =0 THEN    
                                INSERT INTO TB_INV003(WERKS, MACH_CD, MATNR, IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                                    LOT_NO, INP_DT, IN_QTY, USE_QTY, STCK_QTY, UNIT, ROLLCNT, WGT,
                                                    CHG_FLG, STCK_KY, LOT_NUM, REGDATE, REGID)
                                            VALUES(V_WERKS, V_MACH_CD, V_MATNR_M, V_IND_BCD_M, V_B_SEQNO_M, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                                    V_LOT_NO_M, V_B_INP_DT_M, V_B_USE_QTY_M, 0, V_B_USE_QTY_M, V_B_UNIT_M, V_B_ROLLCNT_M, V_B_USE_QTY_M,
                                                    V_B_CHG_FLG_M, V_B_STCK_KY_M, V_B_LOT_NUM_M, V_DATE, V_SESS_USER_ID);
                             END IF;    
                         ELSE
                            UPDATE TB_INV003
                               SET USE_QTY = USE_QTY + V_B_USE_QTY_M,
                                   STCK_QTY = STCK_QTY -  V_B_USE_QTY_M
                             WHERE WERKS = V_WERKS
                               AND MACH_CD = V_MACH_CD
                               AND IND_BCD = V_IND_BCD_M;  
                         END IF;

                        UPDATE TB_INV010
                           SET CNL_YN = 'Y',
                               CNL_RMK = V_CNL_RMK
                         WHERE WERKS = V_WERKS 
                           AND MACH_CD = V_MACH_CD
                           AND IND_BCD = V_IND_BCD
                           AND DOC_NO = V_DOC_NO
                           AND DOC_SEQNO = V_DOC_SEQNO;    

                    END IF;
                ELSE        -- P100
                    RETURN;
                END IF;

            END LOOP;
            CLOSE PROD_CUR; 
        END LOOP;

    END IF;

    IF V_DOC_SEQNO_1 > 0 THEN
       P_DOC_NO1 := V_DOC_NO_1; 
    END IF;
    IF V_DOC_SEQNO_2 > 0 THEN
       P_DOC_NO2 := V_DOC_NO_2; 
    END IF;

	P_SUCCESS := 'Y';
    COMMIT;
--	EXCEPTION
--    WHEN E_EXCEPTION_USER THEN
--
--    	-- 에러 내역 SET
--    	P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := SQLCODE;
--		E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);
--
--		ROLLBACK;
--		SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--
--	WHEN OTHERS THEN
--		P_SUCCESS			:= 'N';
--        E_SQL_ERR_CD        := SQLCODE;
--		E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--		ROLLBACK;
--		RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;

/
