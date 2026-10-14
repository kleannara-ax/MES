--------------------------------------------------------
--  DDL for Procedure SP_WRK47_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK47_S01" (
	P_TYPE         IN    varchar2, -- LIST, SUB_LIST-A, SUB_LIST-B
	P_JSON_STR     IN    CLOB,
	P_SUCCESS      OUT   varchar2,
	P_RS_LIST      OUT   SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK47_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 일일생산실적현황 {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 일일생산실적현황 {프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박성철{최초 작성자 명 기술}
 * CREATE DATE   : 2022/06/22 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   박성철         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_WRK002] : (R) 실적테이블(PS)
 *        - [TB_WRK001] : (R) 실적테이블(HL)                                 
 *        - [TB_MAS012] : (R) 설비코드
 *        - [TB_MAS013] : (R) 공정마스터                              
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK47_S01';     -- PROCEDURE NAME


    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_ARRAY_T;
    V_OBJ            JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS			    TB_WRK001.WERKS%TYPE;			    -- 플랜트
--    V_PRD_DT		    TB_WRK001.PRD_DT%TYPE;			    -- 생산일자
    V_MACH_CD			TB_WRK001.MACH_CD%TYPE;			    -- 설비코드
    V_PROC_CD			TB_MAS013.PROC_CD%TYPE;			    -- 공정코드
    V_MATNR			    TB_WRK001.MATNR%TYPE;			    -- 자재코드
    V_MACHINE           TB_MAS012.MACHINE%TYPE;             --생산호기



    P_CHRT_TYPE      	VARCHAR2(200);		     --차트타입





BEGIN
    OPEN P_RS_LIST FOR 

    SELECT NULL FROM DUAL WHERE ROWNUM = 0;

    V_DEBUG := 'N';
    V_RUN_SQL := 'Y';

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

    V_SESS_USER_ID       :=      V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=      V_JSON.get_string('SES_PLNTKY');

    /* 조건값 할당 */
    V_RANGE_SQL         :=      V_JSON.get_string('RANGE_SQL');
    V_WERKS			    := 		V_JSON.get_string('WERKS');		-- 플랜트  
--    V_PRD_DT		    := 		V_JSON.get_string('PRD_DT');	-- 생산일자
    V_MACH_CD			:= 		V_JSON.get_string('MACH_CD');	-- 설비코드
    V_PROC_CD			:= 		V_JSON.get_string('PROC_CD');	-- 공정
    V_MATNR				:= 		V_JSON.get_string('MATNR');		-- 자재코드
    V_MACHINE           :=      V_JSON.get_string('MACHINE');   --생산호기


    P_CHRT_TYPE         := V_JSON.get_string('P_CHRT_TYPE');  --차트타입




    IF P_TYPE = 'LIST_A' THEN /*PS 실적*/
        V_SQL :=  ' SELECT WRK002.WERKS                         AS PLANT          --플랜트코드
					     , WRK002.PRFM_DT                       AS PRFM_DT        --실적일자
						 , MAS013.PROC_CD                       AS PROC_CD        --공정코드
					     , MAS013.PROC_NM                       AS PROC_NM        --공정명
					     , WRK002.MACH_CD       				AS MACH_CD        --설비코드
					     , MAS012.MACH_NM       				AS MACH_NM        --설비명
					     , WRK002.ORDER_NO       				AS ORDER_NO       --오더번호
					     , WRK002.WRK_ORDR_NO       			AS WRK_ORDR_NO    --작업지시번호
					     , WRK002.WRK_ORDR_SEQNO       			AS WRK_ORDR_SEQNO --작업지시순번
					     , WRK002.LOT_NO       			        AS LOT_NO         --LOT번호
					     , WRK002.IND_BCD       			    AS IND_BCD        --개별바코드
                         , WRK002.MATNR                         AS MATNR 
                         , MAS001.MATNR_NM                      AS MATNR_NM
                         , MAS013.DISP_SEQ                      AS DISP_SEQ
					     , WRK002.UNIT       			        AS UNIT           --단위
					     , WRK002.PCNT       			        AS PCNT           --연수
					     , WRK002.SCNT       			        AS SCNT           --속수
					     , WRK002.MCNT       			        AS MCNT           --매
					     , WRK002.WIDTH       			        AS WIDTH          --실지폭
					     , WRK002.ROLLCNT       			    AS ROLLCNT        --권치수
						 , WRK002.PRFM_QTY       			    AS PRFM_QTY       --실적수량
					     , WRK002.WGT       			        AS WGT            --실적중량
					     , WRK002.MACHINE       			    AS MACHINE        --생산호기
					     , WRK002.PRD_STR_DATE       			AS PRD_STR_DATE   --시작시간
					     , WRK002.PRD_END_DATE       			AS PRD_END_DATE   --종료시간
					     , WRK002.PRD_DT       			        AS PRD_DT         --생산일자
					     , WRK002.REGID       			        AS REGID          --등록자ID
						 , USR.NMLAST 							AS REGNM		  --등록자명
					     , WRK002.WRK_SHIFT       			    AS WRK_SHIFT      --작업조
					     , WRK002.WRK_CLASS       			    AS WRK_CLASS      --반
					  FROM TB_WRK002 WRK002  --실적테이블(PS)
					--  LEFT JOIN TB_MAS012 MAS012  --설비코드
					  JOIN TB_MAS012 MAS012  --설비코드
					    ON MAS012.MACH_CD = WRK002.MACH_CD
					  LEFT JOIN TB_MAS013 MAS013  --공정마스터
					    ON MAS013.PROC_CD = MAS012.PROC_CD
					  LEFT JOIN USRMA USR ON (USR.USERID = WRK002.REGID)
                      LEFT JOIN TB_MAS001 MAS001
                        ON MAS001.WERKS = WRK002.WERKS AND MAS001.MATNR = WRK002.MATNR
					 WHERE 1=1
                       AND NVL(WRK002.CNL_YN, ''N'') != ''Y''
					   AND NVL(WRK002.PRFM_GTHR_YN, ''N'') = ''Y''
                     ';


        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN			-- 플랜트
            V_SQL := V_SQL || ' AND WRK002.WERKS = ''' || V_WERKS || '''';        
        END IF;

        IF  V_MACH_CD IS NOT NULL OR TRIM(V_MACH_CD) != '' THEN		-- 설비코드
            V_SQL := V_SQL || ' AND MAS012.MACH_CD = ''' || V_MACH_CD || '''';        
        END IF;


        IF  V_PROC_CD IS NOT NULL OR TRIM(V_PROC_CD) != '' THEN		-- 공정
            V_SQL := V_SQL || ' AND MAS012.PROC_CD = ''' || V_PROC_CD || '''';        
        END IF;

        IF  V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN		-- 자재
            V_SQL := V_SQL || ' AND WRK002.MATNR = ''' || V_MATNR || '''';        
        END IF;
        
        IF V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '' THEN      --생산호기
            V_SQL := V_SQL || ' AND MAS012.MACHINE = ''' || V_MACHINE || ''' ';
        END IF;
        
--        IF  V_PRD_DT IS NOT NULL OR TRIM(V_PRD_DT) != '' THEN	   -- 생산일자
--            V_SQL := V_SQL || ' AND WRK002.PRD_DT = ''' || V_PRD_DT || '''';        
--        END IF;

        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;

		IF P_CHRT_TYPE = 'loadChrt1Bar' THEN  --공정별 실적현황 차트

			V_SQL := ' WITH BASE AS ( ' || V_SQL ||  ' ) ';
			V_SQL := V_SQL || ' SELECT PROC_CD, PROC_NM AS PROC_NM, DISP_SEQ
								     --, TRUNC(SUM(NVL(WGT, 0)), 2) WGT_SUM
								     , TRUNC(SUM(
								     	 NVL(DECODE(UNIT,''R'', PCNT, ''KG'', WGT, ''EA'',PCNT, 0), 0)
								       ), 2) WGT_SUM
								  FROM BASE
								 GROUP BY PROC_CD, PROC_NM, DISP_SEQ
								 ORDER BY DISP_SEQ ';


		ELSIF P_CHRT_TYPE = 'loadChrt2HBar' THEN  --설비별 실적현황 차트

       			V_SQL := ' WITH BASE AS ( ' || V_SQL ||  ' ) ';
				V_SQL := V_SQL || ' SELECT MACH_CD, MACH_NM
									     --, TRUNC(SUM(NVL(WGT, 0)), 2) WGT_SUM
									     , TRUNC(SUM(
									     	 NVL(DECODE(UNIT,''R'',PCNT, ''KG'',WGT, ''EA'',PCNT, 0), 0)
									       ), 2) WGT_SUM
									  FROM BASE
									 WHERE 1=1 ';

       			V_PROC_CD			:= V_JSON.get_string('CHRT_PRM'); 	--공정코드(차트파람)
				V_SQL := V_SQL ||  '	   AND PROC_CD = ''' || V_PROC_CD || ''' ';

       			V_SQL := V_SQL ||  '  GROUP BY MACH_CD, MACH_NM
									  ORDER BY MACH_NM ';


		ELSIF P_CHRT_TYPE = 'loadChrt3Line' THEN  --기간별 실적현황 차트

       			V_SQL := ' WITH BASE AS ( ' || V_SQL ||  ' ) ';
				V_SQL := V_SQL || ' SELECT TO_CHAR(TO_DATE(PRFM_DT), ''MM/DD/YYYY'') PRFM_DT
									     --, TRUNC(SUM(NVL(WGT, 0)), 2) WGT_SUM
									     , TRUNC(SUM(
									     	 NVL(DECODE(UNIT,''R'',PCNT, ''KG'',WGT, ''EA'',PCNT, 0), 0)
									       ), 2) WGT_SUM
									  FROM BASE
									 WHERE 1=1 ';

       			V_PROC_CD			:= V_JSON.get_string('CHRT_PRM'); 	--공정코드(차트파람)
				V_SQL := V_SQL ||  '	   AND PROC_CD = ''' || V_PROC_CD || ''' ';

       			V_MACH_CD			:= V_JSON.get_string('CHRT_PRM2'); 	--설비코드(차트파람)
				V_SQL := V_SQL ||  '	   AND MACH_CD = ''' || V_MACH_CD || ''' ';

       			V_SQL := V_SQL ||  '  GROUP BY PRFM_DT
									  ORDER BY PRFM_DT ';


        ELSE

       		V_SQL := V_SQL || ' ORDER BY WRK002.WERKS, WRK002.PRFM_DT';

		END IF;






        V_DEBUG := 'Y';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;






		OPEN P_RS_LIST FOR V_SQL;


--    ELSIF P_TYPE = 'SAVE' THEN
--    	RETURN;


    END IF;

    IF P_TYPE = 'LIST_B' THEN /*HL 실적*/
        V_SQL :=  ' SELECT WRK001.WERKS                         AS PLANT          --플랜트코드
					     , WRK001.PRFM_DT                       AS PRFM_DT        --실적일자
						 , MAS013.PROC_CD                       AS PROC_CD        --공정코드
					     , MAS013.PROC_NM                       AS PROC_NM        --공정명
					     , WRK001.MACH_CD       				AS MACH_CD        --설비코드
					     , MAS012.MACH_NM       				AS MACH_NM        --설비명
					     , WRK001.ORDER_NO       				AS ORDER_NO       --오더번호
					     , WRK001.WRK_ORDR_NO       			AS WRK_ORDR_NO    --작업지시번호
					     , WRK001.WRK_ORDR_SEQNO       			AS WRK_ORDR_SEQNO --작업지시순번
					     , WRK001.LOT_NO       			        AS LOT_NO         --LOT번호
					     , WRK001.IND_BCD       			    AS IND_BCD        --개별바코드

                         , WRK001.MATNR                         AS MATNR 
                         , MAS001.MATNR_NM                      AS MATNR_NM

					     , WRK001.UNIT       			        AS UNIT           --단위
					     , WRK001.PLT_QTY       			    AS PLT_QTY        --PLT
					     , WRK001.BOX_QTY       			    AS BOX_QTY        --BOX
					     , WRK001.BAG_QTY       			    AS BAG_QTY        --BAG
					     , WRK001.EA_QTY       			        AS EA_QTY         --EA
					     , WRK001.WGT       			        AS WGT            --실적중량
					     , WRK001.ROLLCNT       			    AS ROLLCNT        --권치수
					     , WRK001.WIDTH       			        AS WIDTH          --지폭
					--     , WRK001.MACHINE       			    AS MACHINE        --생산호기
					     , WRK001.PRD_STR_DATE       			AS PRD_STR_DATE   --시작시간
					     , WRK001.PRD_END_DATE       			AS PRD_END_DATE   --종료시간
					     , WRK001.PRD_DT       			        AS PRD_DT         --생산일자
					     , WRK001.REGID       			        AS REGID          --등록자ID
						 , USR.NMLAST 							AS REGNM		  --등록자명
					     , WRK001.WRK_SHIFT       			    AS WRK_SHIFT      --작업조
					     , WRK001.WRK_CLASS       			    AS WRK_CLASS      --반
					  FROM TB_WRK001 WRK001  --실적테이블(HL)
					--  LEFT JOIN TB_MAS012 MAS012  --설비코드
					  JOIN TB_MAS012 MAS012  --설비코드
					    ON MAS012.MACH_CD = WRK001.MACH_CD
					  LEFT JOIN TB_MAS013 MAS013  --공정마스터
					    ON MAS013.PROC_CD = MAS012.PROC_CD
					  LEFT JOIN USRMA USR ON (USR.USERID = WRK001.REGID)
                      LEFT JOIN TB_MAS001 MAS001
                        ON MAS001.WERKS = WRK001.WERKS AND MAS001.MATNR = WRK001.MATNR
					 WHERE 1=1
					AND NVL(WRK001.CNL_YN, ''N'') != ''Y''
					AND NVL(WRK001.PRFM_GTHR_YN, ''N'') = ''Y'' ';

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN			-- 플랜트
            V_SQL := V_SQL || ' AND WRK001.WERKS = ''' || V_WERKS || '''';        
        END IF;

        IF  V_MACH_CD IS NOT NULL OR TRIM(V_MACH_CD) != '' THEN		-- 설비코드
            V_SQL := V_SQL || ' AND MAS012.MACH_CD = ''' || V_MACH_CD || '''';        
        END IF;

        IF  V_PROC_CD IS NOT NULL OR TRIM(V_PROC_CD) != '' THEN		-- 공정
            V_SQL := V_SQL || ' AND MAS012.PROC_CD = ''' || V_PROC_CD || '''';        
        END IF;

        IF  V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN		-- 자재
            V_SQL := V_SQL || ' AND WRK001.MATNR = ''' || V_MATNR || '''';        
        END IF;

--        IF  V_PRD_DT IS NOT NULL OR TRIM(V_PRD_DT) != '' THEN	   -- 생산일자
--            V_SQL := V_SQL || ' AND WRK001.PRD_DT = ''' || V_PRD_DT || '''';        
--        END IF;

        IF V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '' THEN      --생산호기
            IF V_PROC_CD = 'AA' THEN
                V_SQL := V_SQL || ' AND MAS012.MACH_CD = ''TAA' || LPAD(SUBSTR(V_MACHINE, -1), 2, '00') || '''' ;
            ELSIF V_PROC_CD = 'RA' THEN
                V_SQL := V_SQL || ' AND MAS012.MACH_CD = ''TRA' || LPAD(SUBSTR(V_MACHINE, -1), 2, '00') || '''' ;
            ELSIF V_PROC_CD = 'PG' THEN
                V_SQL := V_SQL || ' AND MAS012.MACHINE = ''' || V_MACHINE || '''';
            END IF;
        END IF;

        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;

		IF P_CHRT_TYPE = 'loadChrt1Bar' THEN  --공정별 실적현황 차트

			V_SQL := ' WITH BASE AS ( ' || V_SQL ||  ' ) ';
			V_SQL := V_SQL || ' SELECT PROC_CD, PROC_NM, UNIT
								     --, TRUNC(SUM(NVL(WGT, 0)), 2) WGT_SUM
								     , TRUNC(SUM(
								     	 NVL(DECODE(UNIT, ''R'',ROLLCNT, ''KG'',WGT, ''PLT'',PLT_QTY, ''BOX'',BOX_QTY, ''BAG'',BAG_QTY, ''EA'',EA_QTY, 0), 0)
								       ), 2) WGT_SUM
								  FROM BASE
								 GROUP BY PROC_CD, PROC_NM, UNIT
								 ORDER BY PROC_NM, UNIT ';


		ELSIF P_CHRT_TYPE = 'loadChrt2HBar' THEN  --설비별 실적현황 차트

       			V_SQL := ' WITH BASE AS ( ' || V_SQL ||  ' ) ';
				V_SQL := V_SQL || ' SELECT MACH_CD, MACH_NM
									     --, TRUNC(SUM(NVL(WGT, 0)), 2) WGT_SUM
									     , TRUNC(SUM(
									     	 NVL(DECODE(UNIT, ''R'',ROLLCNT, ''KG'',WGT, ''PLT'',PLT_QTY, ''BOX'',BOX_QTY, ''BAG'',BAG_QTY, ''EA'',EA_QTY, 0), 0)
									       ), 2) WGT_SUM
									  FROM BASE
									 WHERE 1=1 ';

       			V_PROC_CD			:= V_JSON.get_string('CHRT_PRM'); 	--공정코드(차트파람)
				V_SQL := V_SQL ||  '	   AND PROC_CD = ''' || V_PROC_CD || ''' ';

       			V_SQL := V_SQL ||  '  GROUP BY MACH_CD, MACH_NM
									  ORDER BY MACH_NM ';


		ELSIF P_CHRT_TYPE = 'loadChrt3Line' THEN  --기간별 실적현황 차트

       			V_SQL := ' WITH BASE AS ( ' || V_SQL ||  ' ) ';
				V_SQL := V_SQL || ' SELECT TO_CHAR(TO_DATE(PRFM_DT), ''MM/DD/YYYY'') PRFM_DT
									     --, TRUNC(SUM(NVL(WGT, 0)), 2) WGT_SUM
									     , TRUNC(SUM(
									     	 NVL(DECODE(UNIT, ''R'',ROLLCNT, ''KG'',WGT, ''PLT'',PLT_QTY, ''BOX'',BOX_QTY, ''BAG'',BAG_QTY, ''EA'',EA_QTY, 0), 0)
									       ), 2) WGT_SUM
									  FROM BASE
									 WHERE 1=1 ';

       			V_PROC_CD			:= V_JSON.get_string('CHRT_PRM'); 	--공정코드(차트파람)
				V_SQL := V_SQL ||  '	   AND PROC_CD = ''' || V_PROC_CD || ''' ';

       			V_MACH_CD			:= V_JSON.get_string('CHRT_PRM2'); 	--설비코드(차트파람)
				V_SQL := V_SQL ||  '	   AND MACH_CD = ''' || V_MACH_CD || ''' ';

       			V_SQL := V_SQL ||  '  GROUP BY PRFM_DT
									  ORDER BY PRFM_DT ';


        ELSE

       		V_SQL := V_SQL || ' ORDER BY WRK001.WERKS, WRK001.PRFM_DT';

		END IF;
        
        V_DEBUG := 'Y';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;
        
		OPEN P_RS_LIST FOR V_SQL;


--    ELSIF P_TYPE = 'SAVE' THEN
--    	RETURN;


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
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;
END;

/
