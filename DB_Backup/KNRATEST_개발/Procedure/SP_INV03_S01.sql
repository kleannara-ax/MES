--------------------------------------------------------
--  DDL for Procedure SP_INV03_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_INV03_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB ,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : INV03{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 고지, 펄프 사용량 관리{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 고지, 펄프 사용량을 관리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 여한진{최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/08 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   여한진         Initial Version 
 *==============================================================================
 *  관련 테이블
         - [TB_INV006] : (CRUD) 고치, 펄프 사용이력
         - [TB_MAS001] : (.R..) 자재관리
         - [TB_MAS009] : (.R..) 거래처 관리
         - [TB_MAS022] : (.R..) 일자별 베일 중량
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_INV03_S01';     -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);


   -- V_RTN_CLOB       CLOB;
   -- V_RTN_CURSOR     SYS_REFCURSOR;
   -- V_ERROR          CLOB;


    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_OBJECT_T;
    V_OBJ            JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(4);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역
    V_MACHINE       	TB_INV006.MACHINE%TYPE;			-- 생산호기
    V_MAT_LINE_CD		TB_INV006.MAT_LINE_CD%TYPE;		-- 원료라인
    V_INP_DT			TB_INV006.INP_DT%TYPE;			-- 투입일자
    V_WRK_METH        	TB_INV006.WRK_METH%TYPE;		-- 근무방식
    V_MATNR				TB_INV006.MATNR%TYPE;			-- 자재코드
    V_SUPY_CD			TB_INV006.SUPY_CD%TYPE;			-- 공급업체
    V_IN_QTY			TB_INV006.IN_QTY%TYPE;			-- 베일수
	V_UNIT				TB_INV006.UNIT%TYPE;			-- 단위
    V_WRK_CLASS			TB_INV006.WRK_CLASS%TYPE;		-- 반
    V_WEIGHT_V			TB_MAS022.WEIGHT_V%TYPE;		-- 베일중량
    V_DATE              TB_MAS022.DT%TYPE;              -- 일자

BEGIN

   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'N';
   V_RUN_SQL := 'Y';

   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=       V_JSON.get_string('SES_PLNTKY');

   /* 조건값 할당 */
   V_RANGE_SQL          :=       V_JSON.get_string('RANGE_SQL');

   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

        V_SQL := ' SELECT DISTINCT
						   I006.WERKS    		AS "WERKS",      		-- 플랜트
                           I006.MACHINE         AS "MACHINE",           -- 생산호기(호기)
                           I006.MAT_LINE_CD     AS "MAT_LINE_CD",       -- 원료라인
                           I006.INP_DT       	AS "INP_DT",    -- 투입일자
						   NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = I006.REGID),'''')     AS "INP_NM",	-- 투입자명
                           I006.WRK_METH       	AS "WRK_METH",          -- 근무방식
                           I006.MATNR           AS "MATNR",             -- 자재코드
						   M001.MATNR_NM		AS "MATNR_NM",			-- 자재명
						   I006.SUPY_CD			AS "SUPY_CD",			-- 공급업체
						   M009.CUST_NM			AS "SUPY_NM",			-- 공급업체명
						   M022.WEIGHT_V		AS "WEIGHT_V",			-- 베일당중량
						   I006.IN_QTY			AS "IN_QTY",			-- 베일수
						   I006.UNIT			AS "UNIT",				-- 단위
						   I006.USE_QTY 	    AS "USE_QTY",			-- 사용량
						   I006.WRK_CLASS		AS "WRK_CLASS",			-- 반
                           I006.REGDATE           AS "REGDATE",
                           NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = I006.REGID),I006.REGID) AS "REGNM",
                           I006.UPDDATE           AS "UPDDATE",
                           NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = I006.UPDID),I006.UPDID) AS "UPDNM"
                     FROM  TB_INV006 I006,	-- 고지, 펄프 사용량이력
                           TB_MAS001 M001, 	-- 자재관리
						   TB_MAS009 M009,	-- 거래처 관리
						   TB_MAS022 M022 	-- 일자별 베일 중량
                    WHERE  I006.WERKS = M001.WERKS(+)
                      AND  I006.MATNR = M001.MATNR(+)
					  AND  I006.SUPY_CD = M009.CUST_CD(+)
					  AND  I006.INP_DT = M022.DT(+)
					  AND  I006.WERKS = ''P100'' ';

        V_SQL := V_SQL || V_RANGE_SQL;

		V_SQL := V_SQL || ' ORDER BY INP_DT, I006.REGDATE';

        --V_DEBUG := 'Y';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SUB_LIST' THEN  /* */

       RETURN;

	ELSIF P_TYPE = 'SAVE' THEN
        --V_ARR_HEAD        := V_JSON.get_array('head');
    	V_ARR_LIST        := V_JSON.get_array('list');

		FOR i IN 0..V_ARR_LIST.get_size-1 LOOP

			V_OBJ           	:= TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ           	:= TREAT (V_OBJ.get ('map') AS json_object_t);

            V_INP_DT            := V_OBJ.get_string('INP_DT');    
            V_MACHINE       	:= V_OBJ.get_string('MACHINE');
            V_MAT_LINE_CD		:= V_OBJ.get_string('MAT_LINE_CD');
            V_WRK_METH          := V_OBJ.get_string('WRK_METH');
            V_MATNR		        := V_OBJ.get_string('MATNR');
            V_SUPY_CD			:= V_OBJ.get_string('SUPY_CD');
            V_IN_QTY			:= TO_NUMBER(TRIM(V_OBJ.get_string('IN_QTY')));
            V_UNIT				:= V_OBJ.get_string('UNIT');
            V_WEIGHT_V			:= TO_NUMBER(NVL(TRIM(V_OBJ.get_string('WEIGHT_V')), 0));            

            IF V_OBJ.get_string('GRowState') = 'C' THEN

            	IF (V_RUN_SQL = 'Y') THEN

                	INSERT INTO TB_INV006
                    (
                    	WERKS ,
                    	MACHINE ,
                    	MAT_LINE_CD ,
                    	INP_DT ,
                    	WRK_METH ,
                    	MATNR ,
                    	SUPY_CD ,
                    	IN_QTY ,
                    	UNIT ,
                        USE_QTY,
                    	WRK_CLASS ,
                    	REGDATE ,
                    	REGID
                    ) VALUES (
                            'P100' ,
                            V_MACHINE ,
                            V_MAT_LINE_CD ,
                            V_INP_DT ,
                            V_WRK_METH ,
                            V_MATNR , 
                            V_SUPY_CD ,
                            V_IN_QTY ,
                            V_UNIT ,
                            V_IN_QTY * V_WEIGHT_V,
                            V_WRK_CLASS ,
							SYSDATE, 
							V_SESS_USER_ID
						);

                END IF;

            ELSIF V_OBJ.get_string('GRowState') = 'U' THEN

                IF (V_RUN_SQL = 'Y') THEN

                    UPDATE TB_INV006
                       SET SUPY_CD = V_SUPY_CD,
                           IN_QTY  = V_IN_QTY,
                           UNIT    = V_UNIT,
                           USE_QTY = V_IN_QTY * V_WEIGHT_V,
                           UPDDATE = SYSDATE,
                           UPDID   = V_SESS_USER_ID
                     WHERE WERKS   = 'P100'
                       AND MACHINE = V_MACHINE
                       AND MAT_LINE_CD = V_MAT_LINE_CD
                       AND INP_DT = V_INP_DT
                       AND WRK_METH = V_WRK_METH
                       AND MATNR = V_MATNR;

                END IF;                   

			ELSIF V_OBJ.get_string('GRowState') = 'D' THEN

				DELETE FROM TB_INV006 WHERE WERKS = 'P100' AND MACHINE = V_MACHINE AND MAT_LINE_CD = V_MAT_LINE_CD AND INP_DT = V_INP_DT AND WRK_METH = V_WRK_METH AND MATNR = V_MATNR;

            END IF;

    	END LOOP;

    ELSIF P_TYPE = 'SUB_SAVE' THEN

        RETURN;

    END IF;

    P_SUCCESS := 'Y';

--    EXCEPTION
--    WHEN E_EXCEPTION_USER THEN
--
--        -- 에러 내역 SET
--	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := SQLCODE;
--        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);
--
--        ROLLBACK;
--        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--
--    WHEN OTHERS THEN
--	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := -20990;
--        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--        ROLLBACK;
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END SP_INV03_S01;


/
