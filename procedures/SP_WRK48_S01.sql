
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK48_S01" (
    P_TYPE     IN VARCHAR2, -- LIST, SAVE
    P_JSON_STR IN CLOB,
    P_SUCCESS  OUT VARCHAR2,
    P_RS_LIST  OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK48_S01
 * PROGRAM NAME  : 밀롤 실적 조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 밀롤 실적 현황을 관리한다.
 *                 
 * AUTHOR NAME   : 안상현
 * CREATE DATE   : 2022/06/29
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    DATE        VER       NAME          DESCRIPTION      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/06/29    1.0.0   안상현         INITIAL VERSION 
 *==============================================================================
 *  관련 테이블
 *        - [TB_WRK002] : ( R  ) 실적테이블(PS)
 *        - [TB_WRK004] : ( R  ) 폐품 실적(PS) 테이블
 *        - [TB_SCH015] : ( R  ) 작업지시 점보롤	
 *        - [TB_SCH016] : ( R  ) 작업지시 밀롤,슬리터	
 *        - [TB_MAS012] : ( R  ) 설비 마스터 정보	
 *        - [TB_MAS013] : ( R  ) 공정 마스터 정보	
 *        - [TB_MAS001] : ( R  ) 자재기준정보(자재 마스터)	
 *=============================================================================*/ AS

    V_PRG_NM       VARCHAR2(100) := 'SP_WRK48_S01';     -- PROCEDURE NAME

	-- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER EXCEPTION;
    E_SQL_ERR_CD   NUMBER(5) := 0;
    E_SQL_ERR_MSG  VARCHAR2(4000);

   -- JSON을 위한 변수선언 영역
    V_JSON         JSON_OBJECT_T;
    V_ARR_LIST     JSON_ARRAY_T;
    V_OBJ          JSON_OBJECT_T;

	-- 세션값 처리용 변수선언 영역
    V_SESS_USER_ID VARCHAR2(20);
    V_PLT_CD       VARCHAR2(2);
    V_DEBUG        VARCHAR2(1) := 'Y';

	-- 조건절 처리용 변수선언 영역   
    V_MACHINE      TB_WRK002.MACHINE%TYPE;				--생산호기
    V_RUN_STA      TB_WRK002.RUN_STA%TYPE;				--운전상태
    V_MACH_CD      TB_WRK002.MACH_CD%TYPE;				--운전상태
    V_CNL_YN		TB_WRK002.CNL_YN%TYPE;				--취소여부
    --20230216 여한진 자재코드, 오더번호, 판매문서번호, 판매문서 항목번호, 거래처코드, LOT번호, 개별바코드 검색조건 추가
    V_MATNR		 	TB_WRK002.MATNR%TYPE;				--자재코드
    V_ORDER_NO		TB_WRK002.ORDER_NO%TYPE;			--오더번호
    V_VBELN			TB_WRK002.VBELN%TYPE;				--판매문서번호
    V_POSNR			TB_WRK002.POSNR%TYPE;				--판매문서항목번호
    V_CUST_CD		TB_WRK002.KUNNR%TYPE;				--거래처코드
    V_LOT_NO		TB_WRK002.LOT_NO%TYPE;				--LOT번호
    V_IND_BCD		TB_WRK002.IND_BCD%TYPE;				--개별바코드
    
    V_RANGE_SQL    VARCHAR2(4000);						--실적일자

    V_SQL          CLOB;
BEGIN
    OPEN P_RS_LIST FOR SELECT
                           NULL
                       FROM
                           DUAL
                       WHERE
                           ROWNUM = 0;

    V_JSON := JSON_OBJECT_T.PARSE(P_JSON_STR);
    V_SESS_USER_ID := V_JSON.GET_STRING('SES_USER_ID');
    V_PLT_CD := V_JSON.GET_STRING('SES_PLNTKY');
    V_MACHINE := V_JSON.GET_STRING('MACHINE');	--생산호기
    V_RUN_STA := V_JSON.GET_STRING('RUN_STA');	--운전상태
    V_MACH_CD := V_JSON.GET_STRING('MACH_CD');	--운전상태
    V_CNL_YN	:=	V_JSON.get_string('CNL_YN');	--취소여부
    V_RANGE_SQL := V_JSON.GET_STRING('RANGE_SQL');	--실적일자
    
    V_MATNR			:=	V_JSON.get_string('MATNR');		--자재코드
	V_ORDER_NO		:=	V_JSON.get_string('ORDER_NO');	--오더번호
	V_VBELN			:=	V_JSON.get_string('VBELN');		--판매문서번호	
	V_POSNR		    :=	V_JSON.get_string('POSNR');		--판매문서항목번호
	V_CUST_CD	    :=	V_JSON.get_string('CUST_CD');	--거래처코드
	V_LOT_NO	    :=	V_JSON.get_string('LOT_NO');	--LOT번호
	V_IND_BCD	    :=	V_JSON.get_string('IND_BCD');	--개별바코드

    IF P_TYPE = 'LIST' THEN
        V_SQL := ' SELECT 
                  A.WERKS									                                            AS WERKS			--플랜트코드
                , A.WRK_ORDR_NO							                                                AS WRK_ORDR_NO		--작업지시번호
                , A.WRK_ORDR_SEQNO						                                                AS WRK_ORDR_SEQNO	--작업지시순번
                , SCH016.MACHINE							                                            AS MACHINE			--생산호기
                , C.PROC_NM								                                                AS PROC_NM			--공정명
                , A.MACH_CD								                                                AS MACH_CD			--설비코드
                , C.MACH_NM								                                                AS MACH_NM			--설비명
                , A.PRD_STR_DATE							                                            AS PRD_STR_DATE		--생산시작일시
                , A.PRD_END_DATE							                                            AS PRD_END_DATE		--생산종료일시
                , A.WRK_CLASS								                                            AS WRK_CLASS		--작업반
                , MAS001.PCODE_NM 						                                                AS PCODE_NM			--지종명
                , SCH016.BS_WGT							                                                AS BS_WGT			--평량
                , A.RSPEED								                                                AS RSPEED			--선속
                , A.WIDTH                                                                               AS WIDTH            --실지폭
                , A.WIDTH_NO                                                                            AS WIDTH_NO         --지폭순번
                , A.LOT_NO								                                                AS LOT_NO			--LOT NO
                , A.IND_BCD								                                                AS IND_BCD			--개별바코드
                , FN_CD_VAL(''RUNSTA'', A.RUN_STA)                                                      AS RUN_STA			--운전상태
                , A.PRFM_ROLLCNT							                                            AS PRFM_ROLLCNT		--실적권치수
                , ''M''                                                                                 AS PRMUNIT          --실적권치수 단위
                , A.PRFM_WGT								                                            AS PRFM_WGT			--실적중량
                , ''KG''                                                                                AS PRWUNIT          --실적중량 단위
                , A.DISPO_ROLLCNT							                                            AS DISPO_ROLLCNT	--폐품권치수
                , ''M''                                                                                 AS DIMUNIT          --폐품권치수 단위
                , A.DISPO_WGT								                                            AS DISPO_WGT		--폐품중량
                , ''KG''                                                                                AS DIWUNIT          --폐품중량 단위
                , M023.DISPO_NM                                                                         AS DISPO_CD			--폐품코드
                --,	A.DISPO_CD								                                            AS DISPO_CD			--폐품코드
                , A.PRFM_DT								                                                AS PRFM_DT			--실적일자
                , A.PRD_DATE								                                            AS PRD_DATE			--등록일시
                , SCH016.PRE_ORDER_NO						                                            AS PRE_ORDER_NO		--이전오더번호
                , A.REGID									                                            AS REGNM			--등록자
                , SCH016.ORDER_RMK						                                                AS ORDER_RMK		--오더비고
                , SCH016.ORDER_NO							                                            AS ORDER_NO			--오더번호
                , A.CNL_YN                    			                                                AS CNL_YN           --취소여부
                , A.CNL_RMK                                                                             AS CNL_RMK          --취소사유
                , A.MATNR                    				                                            AS MATNR            --자재코드
                , MAS001.MATNR_NM                  		                                                AS MATNR_NM         --자재명
                , A.RMK                                                                                 AS RMK              --비고
                , SCH016.VBELN                                                                          AS VBELN            --판매문서번호
                , SCH016.POSNR                                                                          AS POSNR            --판매문서 품목번호(변경)
                , SCH016.KUNNR									                                        AS CUST_CD	        --거래처
                , (SELECT CUST_NM FROM TB_MAS009 WHERE CUST_CD = SCH016.KUNNR  AND CUST_DIV = ''C'' )   AS KUNNR_NM         --
                , A.SDOC_NO                                                                             AS SDOC_NO          --SAP확정문서번호
                , A.SDOC_SEQNO                                                                          AS SDOC_SEQNO       --SAP확정문서번호 순번
                , A.TM                                                                                  AS TM               --생산시간(분)
                , A.MRCOM_YN                                                                            AS MRCOM_YN         --밀롤완료
                , A.JRCOM_YN                                                                            AS JRCOM_YN         --점보롤완료
                , SUBSTR(A.MATNR, 10, 4) || ''*'' || SUBSTR(A.MATNR, 14, 4)			                    AS SPEC			    --규격
                , SCH016.SHEET                                                                          AS SHEET            --판지구분자
                , SCH015.ORDER_NO                                                                       AS ORDER_NO         --점보롤 오더
                , SCH015.WRK_ORDR_NO                                                                    AS WRK_ORDR_NO      --점보롤 작업지시
                , WRK002_J.LOT_NO                                                                       AS JR_LOT_NO        --점보롤 LOT_NO
                , WRK002_J.IND_BCD                                                                      AS JR_IND_BCD       --점보롤 IND_BCD
                , WRK002_J.PRD_STR_DATE                                                                 AS JR_PRD_STR_DATE  --점보롤 PRD_STR_DATE
			FROM
			(
				SELECT 
                      WRK002.WRK_ORDR_NO 			                	                    AS WRK_ORDR_NO			--작업지시번호
				    , WRK002.WRK_ORDR_SEQNO 		                                        AS WRK_ORDR_SEQNO		--작업지시순번
				    , WRK002.MATNR 							                                AS MATNR				--자재코드
				    , WRK002.MACHINE 						                                AS MACHINE				--생산호기
				    , WRK002.MACH_CD 						                                AS MACH_CD				--설비코드
				    , WRK002.PRD_STR_DATE 			                                        AS PRD_STR_DATE			--생산시작일시
				    , WRK002.PRD_END_DATE 			                                        AS PRD_END_DATE			--생산종료일시
				    , WRK002.WRK_CLASS 					                                    AS WRK_CLASS			--작업반
				    , CASE WHEN NVL(WRK002.TM, 0) = 0 THEN 0 ELSE ROUND(NVL(WRK002.ROLLCNT, 1) / NVL(WRK002.TM, 1), 0) END  AS RSPEED				--선속
                    , WRK002.WIDTH                                                          AS WIDTH                --실지폭
                    , WRK002.WIDTH_NO                                                       AS WIDTH_NO             --지폭순번
				    , WRK002.LOT_NO 						                                AS LOT_NO				--LOT NO
				    , WRK002.RUN_STA 						                                AS RUN_STA				--운전 상태
				    , WRK002.ROLLCNT	                                                    AS PRFM_ROLLCNT			--실적권치수
				    , WRK002.WGT 										                    AS PRFM_WGT				--실적중량
				    , WRK002.PRFM_DT 						                                AS PRFM_DT				--실적일자
				    , WRK002.REGDATE 						                                AS PRD_DATE				--등록일시
				    , (SELECT NMLAST FROM USRMA WHERE USERID = WRK002.REGID) 			    AS REGID				--등록자
				    , WRK002.WERKS                                                          AS WERKS				--플랜트코드
				    , WRK002.IND_BCD                                                        AS IND_BCD				--개별바코드
				    , NULL 										                            AS DISPO_ROLLCNT		--폐품권치수
				    , NULL 											                        AS DISPO_WGT			--폐품중량
				    , NULL											                        AS DISPO_CD				--폐품코드
				    , NVL(WRK002.CNL_YN, ''N'')						                        AS CNL_YN			    --취소여부
                    , WRK002.CNL_RMK									                    AS CNL_RMK			    --취소사유
                    , NVL(WRK002.PRFM_GTHR_YN, ''N'')				                        AS PRFM_GTHR_YN		    --실적여부
                    , WRK002.RMK                                                            AS RMK                  --비고
                    , WRK002.SDOC_NO                                                        AS SDOC_NO              --SAP확정문서번호
                    , WRK002.SDOC_SEQNO                                                     AS SDOC_SEQNO           --SAP확정문서번호 순번
                    , WRK002.TM                                                             AS TM                   --생산시간(분)
                    , WRK002.MRCOM_YN                                                       AS MRCOM_YN             --밀롤완료
                    , WRK002.JRCOM_YN                                                       AS JRCOM_YN             --점보롤완료
                FROM TB_WRK002 WRK002
                WHERE WERKS = ''P100''
                    AND MACH_CD IN (SELECT MACH_CD FROM TB_MAS012 WHERE PROC_CD IN (''MA''))
                UNION ALL
             	SELECT 
				      WRK004.WRK_ORDR_NO 				                                    AS WRK_ORDR_NO			--작업지시번호
				    , WRK004.WRK_ORDR_SEQNO 		                                        AS WRK_ORDR_SEQNO		--작업지시순번
				    , WRK004.MATNR 							                                AS MATNR				--자재코드
				    , NULL 						                                            AS MACHINE				--생산호기
				    , WRK004.MACH_CD 						                                AS MACH_CD				--설비코드
				    , WRK004.PRD_STR_DATE 			                                        AS PRD_STR_DATE			--생산시작일시
				    , WRK004.PRD_END_DATE 			                                        AS PRD_END_DATE			--생산종료일시
				    , WRK004.WRK_CLASS 					                                    AS WRK_CLASS			--작업반
				    , CASE WHEN NVL(WRK004.TM, 0) = 0 THEN 0 ELSE ROUND(NVL(WRK004.ROLLCNT, 1) / NVL(WRK004.TM, 1), 0) END AS RSPEED				--선속
                    , NULL                                                                  AS WIDTH                --실지폭
                    , NULL                                                                  AS WIDTH_NO             --지폭순번
				    , WRK004.LOT_NO 						                                AS LOT_NO				--LOT NO
				    , NULL 						                                            AS RUN_STA				--운전 상태
				    , NULL	                                                                AS PRFM_ROLLCNT			--실적권치수
				    , NULL 										                            AS PRFM_WGT				--실적중량
				    , WRK004.PRFM_DT 						                                AS PRFM_DT				--실적일자
				    , WRK004.REGDATE 						                                AS PRD_DATE				--등록일시
				    , (SELECT NMLAST FROM USRMA WHERE USERID = WRK004.REGID) 	            AS REGID				--등록자
				    , WRK004.WERKS                                                          AS WERKS				--플랜트코드
				    , WRK004.IND_BCD                                                        AS IND_BCD				--개별바코드
				    , WRK004.ROLLCNT 							                    	    AS DISPO_ROLLCNT		--폐품권치수
				    , WRK004.WGT 								                    	    AS DISPO_WGT			--폐품중량
				    , WRK004.DISPO_CD							                    	    AS DISPO_CD				--폐품코드
				    , NVL(WRK004.CNL_YN, ''N'')						                        AS CNL_YN			    --취소여부
			        , WRK004.CNL_RMK									                    AS CNL_RMK			    --취소사유
                    , CASE WHEN NVL(WRK004.CNL_YN, ''N'') = ''N'' THEN ''Y'' ELSE ''N'' END AS PRFM_GTHR_YN		    --실적여부
                    , WRK004.RMK                                                            AS RMK                  --비고
                    , WRK004.SDOC_NO                                                        AS SDOC_NO              --SAP확정문서번호
                    , WRK004.SDOC_SEQNO                                                     AS SDOC_SEQNO           --SAP확정문서번호 순번
                    , WRK004.TM                                                             AS TM                   --생산시간(분)
                    , WRK004.MRCOM_YN                                                       AS MRCOM_YN             --밀롤완료
                    , WRK004.JRCOM_YN                                                       AS JRCOM_YN             --점보롤완료
            	FROM TB_WRK004 WRK004 -- (폐품실적)
                WHERE WERKS = ''P100''   
                    AND MACH_CD IN (SELECT MACH_CD FROM TB_MAS012 WHERE PROC_CD IN (''MA''))
                UNION ALL
             	SELECT 
				      WRK022.WRK_ORDR_NO 				                                    AS WRK_ORDR_NO			--작업지시번호
				    , WRK022.WRK_ORDR_SEQNO 		                                        AS WRK_ORDR_SEQNO		--작업지시순번
				    , WRK022.MATNR 							                                AS MATNR				--자재코드
				    , NULL 						                                            AS MACHINE				--생산호기
				    , WRK022.MACH_CD 						                                AS MACH_CD				--설비코드
				    , WRK022.PRD_STR_DATE 			                                        AS PRD_STR_DATE			--생산시작일시
				    , WRK022.PRD_END_DATE 			                                        AS PRD_END_DATE			--생산종료일시
				    , WRK022.WRK_CLASS 					                                    AS WRK_CLASS			--작업반
				    , CASE WHEN NVL(WRK022.TM, 0) = 0 THEN 0 ELSE ROUND(NVL(WRK022.ROLLCNT, 1) / NVL(WRK022.TM, 1), 0) END AS RSPEED				--선속
                    , NULL                                                                  AS WIDTH                --실지폭
                    , NULL                                                                  AS WIDTH_NO             --지폭순번
				    , WRK022.LOT_NO 						                                AS LOT_NO				--LOT NO
				    , NULL 						                                            AS RUN_STA				--운전 상태
				    , NULL	                                                                AS PRFM_ROLLCNT			--실적권치수
				    , NULL 										                            AS PRFM_WGT				--실적중량
				    , WRK022.PRFM_DT 						                                AS PRFM_DT				--실적일자
				    , WRK022.REGDATE 						                                AS PRD_DATE				--등록일시
				    , (SELECT NMLAST FROM USRMA WHERE USERID = WRK022.REGID) 	            AS REGID		        --등록자
				    , WRK022.WERKS                                                          AS WERKS				--플랜트코드
				    , WRK022.IND_BCD                                                        AS IND_BCD				--개별바코드
				    , CASE WHEN NVL(WRK022.ROLLCNT, 0) = 0 THEN ROUND(NVL(WRK022.WGT, 0) / (TO_NUMBER(SUBSTR(WRK022.MATNR, 10, 4)) /1000 *  TO_NUMBER(SUBSTR(WRK022.MATNR, 6, 3)) /1000))
                      ELSE WRK022.ROLLCNT END                                               AS DISPO_ROLLCNT		--폐품권치수
				    , WRK022.WGT 										                    AS DISPO_WGT			--폐품중량
				    , WRK022.DISPO_CD									                    AS DISPO_CD				--폐품코드
				    , NVL(WRK022.CNL_YN, ''N'')                                             AS CNL_YN			    --취소여부
			        , ''''          									                    AS CNL_RMK			    --취소사유
                    , CASE WHEN NVL(WRK022.CNL_YN, ''N'') = ''N'' THEN ''Y'' ELSE ''N'' END AS PRFM_GTHR_YN		    --실적여부
                    , WRK022.RMK                                                            AS RMK                  --비고
                    , WRK022.SDOC_NO                                                        AS SDOC_NO              --SAP확정문서번호
                    , WRK022.SDOC_SEQNO                                                     AS SDOC_SEQNO           --SAP확정문서번호 순번
                    , WRK022.TM                                                             AS TM                   --생산시간(분)
                    , ''Y''                                                                 AS MRCOM_YN             --밀롤완료
                    , ''Y''                                                                 AS JRCOM_YN             --점보롤완료
            	FROM TB_WRK022 WRK022 -- (폐품실적)
                WHERE WERKS = ''P100''   
                    AND MACH_CD IN (SELECT MACH_CD FROM TB_MAS012 WHERE PROC_CD IN (''MA''))
            ) A 
			INNER JOIN TB_SCH016 SCH016 ON (SCH016.WRK_ORDR_NO = A.WRK_ORDR_NO AND SCH016.WRK_ORDR_SEQNO = A.WRK_ORDR_SEQNO)
            LEFT JOIN TB_SCH015 SCH015 ON (SCH015.WERKS = A.WERKS AND SCH015.ORDER_NO = SCH016.PRE_ORDER_NO)
            LEFT JOIN TB_INV010 INV010 ON A.LOT_NO = INV010.LOT_NO AND A.IND_BCD = INV010.IND_BCD
                                        AND A.WRK_ORDR_NO = INV010.WRK_ORDR_NO
                                        AND A.WRK_ORDR_SEQNO = INV010.WRK_ORDR_SEQNO
            LEFT JOIN TB_WRK002 WRK002_J ON (WRK002_J.WERKS = A.WERKS AND WRK002_J.WRK_ORDR_NO = SCH015.WRK_ORDR_NO
                                        AND WRK002_J.WRK_ORDR_SEQNO = SCH015.WRK_ORDR_SEQNO)
                                        AND INV010.LOT_NO_M = WRK002_J.LOT_NO
			LEFT JOIN TB_MAS001 MAS001 ON (MAS001.WERKS = A.WERKS AND MAS001.MATNR = A.MATNR)
			LEFT JOIN 
			(
				SELECT 
				      MAS012.MACH_CD	AS MACH_CD	--설비코드
				    , MAS012.MACH_NM	AS MACH_NM	--설비명
				    , MAS013.PROC_NM	AS PROC_NM	--공정명
				    , MAS012.MACHINE	AS MACHINE	--생산호기
				FROM TB_MAS012 MAS012
				LEFT JOIN TB_MAS013 MAS013 ON (MAS013.PROC_CD = MAS012.PROC_CD)
				WHERE WERKS = ''P100'' 
                    AND MAS012.PROC_CD IN (''MA'')
			) C ON (C.MACH_CD = A.MACH_CD)
            LEFT JOIN TB_MAS023 M023 ON A.WERKS = M023.WERKS AND A.DISPO_CD = M023.DISPO_CD
			WHERE 1=1
                AND NVL(A.PRFM_GTHR_YN, ''N'') = ''Y''';
            
        IF V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '' THEN
            V_SQL := V_SQL || ' AND SCH016.MACHINE = ''' || V_MACHINE || '''';
        END IF;

        IF V_RUN_STA IS NOT NULL OR TRIM(V_RUN_STA) != '' THEN
            V_SQL := V_SQL || ' AND A.RUN_STA = ''' || V_RUN_STA || '''';
        END IF;     
        
        IF V_CNL_YN IS NOT NULL OR TRIM(V_CNL_YN) != '' THEN
            V_SQL := V_SQL || ' AND NVL(A.CNL_YN, ''N'') = ''' || V_CNL_YN || '''';
        END IF;
       
        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'CUST_CD', 'SCH016.KUNNR');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'ORDER_NO', 'SCH016.ORDER_NO');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'VBELN', 'SCH016.VBELN');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'POSNR', 'SCH016.POSNR');
            
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;

        V_SQL := V_SQL || ' ORDER BY A.MACHINE, A.PRD_STR_DATE';
        
        IF ( V_DEBUG = 'Y' ) THEN
            INSERT INTO PROC_LOG ( SQL_STR, SQL_PARAM1 ) VALUES ( V_SQL, 'WRK48_S01' );
        END IF;

        OPEN P_RS_LIST FOR V_SQL;

    END IF;

    P_SUCCESS := 'Y';
EXCEPTION
    WHEN E_EXCEPTION_USER THEN

    	-- 에러 내역 SET
        P_SUCCESS := 'N';
        E_SQL_ERR_CD := SQLCODE;
        E_SQL_ERR_MSG := SUBSTRB(SQLERRM, 1, 300);
        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
    WHEN OTHERS THEN
        P_SUCCESS := 'N';
        E_SQL_ERR_CD := SQLCODE;
        E_SQL_ERR_MSG := 'EXCEPTION OTHER ERROR. ['
                         || SUBSTR(SQLERRM, 1, 500)
                         || ']';
        ROLLBACK;
		--RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;
END;
/
