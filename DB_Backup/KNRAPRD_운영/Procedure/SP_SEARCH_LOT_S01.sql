--------------------------------------------------------
--  DDL for Procedure SP_SEARCH_LOT_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SEARCH_LOT_S01" (
	P_TYPE         IN    varchar2, --
	P_JSON_STR     IN    CLOB,
	P_SUCCESS      OUT   varchar2,
	P_RS_LIST      OUT   SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_SEARCH_LOT_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 공통 LOT번호 조회 {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 공통 LOT번호 조회 팝업 프로시저
 *                 
 * AUTHOR NAME   : 안상현{최초 작성자 명 기술}
 * CREATE DATE   : 2022/08/25 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   안상현         Initial Version 
 *==============================================================================
 *  관련 테이블 - 모든 테이블 조회만 함
 *        HL 실적테이블 		: ( R  ) TB_WRK001
 *        PS 실적테이블    		: ( R  ) TB_WRK002
 *        설비 마스터 정보 		: ( R  ) TB_MAS012                                  
 *        공정 마스터 정보 		: ( R  ) TB_MAS013
 *        품목 마스터 정보 		: ( R  ) TB_MAS001
 *        사용자 정보 			: ( R  ) USRMA
 *=============================================================================*/

AS
    V_PRG_NM            VARCHAR2(100)  := 'SP_SEARCH_LOT_S01';     -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER    EXCEPTION;
    E_SQL_ERR_CD        NUMBER(5)   := 0;
    E_SQL_ERR_MSG       VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON              JSON_OBJECT_T;
    V_ARR_LIST          JSON_ARRAY_T;
    V_ARR_HEAD          JSON_ARRAY_T;
    V_OBJ               JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL               CLOB;
    V_RUN_SQL           varchar2(1);
    V_RANGE_SQL         varchar2(4000);
    V_DEBUG             varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD            varchar2(2);
    V_SESS_USER_ID      varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS		        TB_WRK001.WERKS%TYPE;			--플랜트코드
    V_PROC_GRP_CD		TB_MAS013.PROC_GRP_CD%TYPE;		--공정그룹코드
    V_MACH_CD			TB_WRK001.MACH_CD%TYPE;			--설비코드
    V_MATNR				TB_WRK001.MATNR%TYPE;			--자재코드
    V_MATNR_NM			TB_MAS001.MATNR_NM%TYPE;		--자재명
    V_IND_BCD			TB_WRK001.IND_BCD%TYPE;			--개별바코드

BEGIN
    OPEN P_RS_LIST FOR 

    SELECT NULL FROM DUAL WHERE ROWNUM = 0;

    V_DEBUG 			:= 'N';
    V_RUN_SQL			:= 'Y';

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

    V_SESS_USER_ID      :=      V_JSON.get_string('SES_USER_ID');
    V_PLT_CD            :=      V_JSON.get_string('SES_PLNTKY');

	V_RANGE_SQL 		:=		V_JSON.get_string('RANGE_SQL');   	--실적일자, 생산일자   
    V_WERKS				:= 		V_JSON.get_string('WERKS');			--플랜트코드  
    V_PROC_GRP_CD		:= 		V_JSON.get_string('PROC_GRP_CD');	--공정그룹코드
    V_MACH_CD			:= 		V_JSON.get_string('MACH_CD');		--설비코드 
    V_MATNR				:= 		V_JSON.get_string('MATNR');			--자재코드 
    V_MATNR_NM			:= 		V_JSON.get_string('MATNR_NM');		--자재명 
    V_IND_BCD			:= 		V_JSON.get_string('IND_BCD');		--개별바코드 

    IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/
        V_SQL :=  
        ' 	
		SELECT 
			s.PRFM_DT 												AS PRFM_DT		--실적일자
		,	s.MACH_CD												AS MACH_CD 		--설비코드
		,	s.MACH_NM 												AS MACH_NM		--설비명
		,	s.MATNR 												AS MATNR		--자재코드
		,	s.MATNR_NM												AS MATNR_NM		--자재명
		,	s.LOT_NO												AS LOT_NO		--LOT번호
		,	s.PRD_DT					 							AS PRD_DT		--생산일자
		,	s.WRK_CLASS												AS WRK_CLASS	--작업반
		,	s.WRK_SHIFT												AS WRK_SHIFT	--작업조
		,	s.REGNM													AS REGNM		--작업자명
		,	COUNT(*)												AS PRFM_CNT		--실적건수
		FROM 
		(
		SELECT 
			WRK001.PRFM_DT 											AS PRFM_DT		--실적일자
		,	WRK001.MACH_CD											AS MACH_CD 		--설비코드
		,	MAS012.MACH_NM 											AS MACH_NM		--설비명
		,	WRK001.MATNR 											AS MATNR		--자재코드
		,	MAS001.MATNR_NM											AS MATNR_NM		--자재명
		,	WRK001.LOT_NO											AS LOT_NO		--LOT번호
		,	WRK001.PRD_DT					 						AS PRD_DT		--생산일자
		,	WRK001.WRK_CLASS										AS WRK_CLASS	--작업반
		,	WRK001.WRK_SHIFT										AS WRK_SHIFT	--작업조
		,	WRK001.REGID											AS REGID		--작업자 ID
		,	USR.NMLAST												AS REGNM		--작업자명
		,	WRK001.WERKS 											AS WERKS		--플랜트코드
		,	MAS013.PROC_GRP_CD										AS PROC_GRP_CD	--공정그룹코드
		,	WRK001.IND_BCD 											AS IND_BCD		--개별바코드
		FROM 
			TB_WRK001 WRK001
		LEFT JOIN TB_MAS012 MAS012 ON (MAS012.MACH_CD = WRK001.MACH_CD)
		LEFT JOIN TB_MAS001 MAS001 ON (MAS001.WERKS = WRK001.WERKS AND MAS001.MATNR = WRK001.MATNR)
		LEFT JOIN TB_MAS013 MAS013 ON (MAS013.PROC_CD = MAS012.PROC_CD)
		LEFT JOIN USRMA USR ON (USR.USERID = WRK001.REGID)
		WHERE 1=1
		AND NVL(WRK001.CNL_YN,''N'') = ''N''

		UNION ALL 

		SELECT 
			WRK002.PRFM_DT 											AS PRFM_DT		--실적일자
		,	WRK002.MACH_CD											AS MACH_CD 		--설비코드
		,	MAS012.MACH_NM 											AS MACH_NM		--설비명
		,	WRK002.MATNR 											AS MATNR		--자재코드
		,	MAS001.MATNR_NM											AS MATNR_NM		--자재명
		,	WRK002.LOT_NO											AS LOT_NO		--LOT번호
		,	WRK002.PRD_DT					 						AS PRD_DT		--생산일자
		,	WRK002.WRK_CLASS										AS WRK_CLASS	--작업반
		,	WRK002.WRK_SHIFT										AS WRK_SHIFT	--작업조
		,	WRK002.REGID											AS REGID		--작업자 ID
		,	USR.NMLAST												AS REGNM		--작업자명 
		,	WRK002.WERKS 											AS WERKS		--플랜트코드
		,	MAS013.PROC_GRP_CD										AS PROC_GRP_CD	--공정그룹코드
		,	WRK002.IND_BCD 											AS IND_BCD		--개별바코드
		FROM 
			TB_WRK002 WRK002
		LEFT JOIN TB_MAS012 MAS012 ON (MAS012.MACH_CD = WRK002.MACH_CD)
		LEFT JOIN TB_MAS001 MAS001 ON (MAS001.WERKS = WRK002.WERKS AND MAS001.MATNR = WRK002.MATNR)
		LEFT JOIN TB_MAS013 MAS013 ON (MAS013.PROC_CD = MAS012.PROC_CD)
		LEFT JOIN USRMA USR ON (USR.USERID = WRK002.REGID)
		WHERE 1=1
		AND NVL(WRK002.CNL_YN,''N'') = ''N''
		) s
		WHERE 1=1';

       	--플랜트코드
        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN	   				
            V_SQL := V_SQL || ' AND WERKS = ''' || V_WERKS || '''';        
        END IF;

		--공정그룹코드
        IF  V_PROC_GRP_CD IS NOT NULL OR TRIM(V_PROC_GRP_CD) != '' THEN	   	
            V_SQL := V_SQL || ' AND PROC_GRP_CD = ''' || V_PROC_GRP_CD || '''';        
        END IF;

		--설비코드
        IF  V_MACH_CD IS NOT NULL OR TRIM(V_MACH_CD) != '' THEN	   	
            V_SQL := V_SQL || ' AND MACH_CD = ''' || V_MACH_CD || '''';        
        END IF;

		--자재코드
        IF  V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN	   	
            V_SQL := V_SQL || ' AND MATNR = ''' || V_MATNR || '''';        
        END IF;

		--자재명
        IF  V_MATNR_NM IS NOT NULL OR TRIM(V_MATNR_NM) != '' THEN	   	
            V_SQL := V_SQL || ' AND MATNR_NM = ''' || V_MATNR_NM || '''';        
        END IF;

		--개별바코드
        IF  V_IND_BCD IS NOT NULL OR TRIM(V_IND_BCD) != '' THEN	   	
            V_SQL := V_SQL || ' AND IND_BCD = ''' || V_IND_BCD || '''';        
        END IF;

		--실적일자, 생산일자
       	IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_SQL := V_SQL || V_RANGE_SQL ;			                       	                 
        END IF;

       	V_SQL := V_SQL || ' GROUP BY s.PRFM_DT, s.MACH_CD, s.MACH_NM, s.MATNR, s.MATNR_NM, s.LOT_NO, s.PRD_DT, s.WRK_CLASS, s.WRK_SHIFT, s.REGID, s.REGNM';
        V_SQL := V_SQL || ' ORDER BY PRFM_DT, PRD_DT, MATNR';

        V_DEBUG := 'Y';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;

    END IF;

    P_SUCCESS := 'Y';

    EXCEPTION
    WHEN E_EXCEPTION_USER THEN

        -- 에러 내역 SET
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

    WHEN OTHERS THEN
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;

/
