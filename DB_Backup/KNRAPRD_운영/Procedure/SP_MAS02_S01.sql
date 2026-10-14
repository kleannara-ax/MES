--------------------------------------------------------
--  DDL for Procedure SP_MAS02_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_MAS02_S01" (
	P_TYPE           IN    varchar2, -- LIST, SUB_LIST-A, SUB_LIST-B
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_MAS02_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 자재별 단위 환산 마스터 {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 자재별 단위 환산 마스터 관리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 공진우{최초 작성자 명 기술}
 * CREATE DATE   : 2022/04/15 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   공진우         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_MAS001] : (.R..) 자재관리
 *        - [TB_MAS007] : (.R..) 생산버전 - 생산버전 - (비계획) 정보
 *        - [TB_MAS008] : (.R..) BOM 마스터 정보                                      
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_MAS02_S01';     -- PROCEDURE NAME


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
    V_MATNR					TB_MAS001.MATNR%TYPE;			    -- 자재코드
    V_WERKS					TB_MAS001.WERKS%TYPE;			    -- 플랜트코드
    V_MATNR_NM				TB_MAS001.MATNR_NM%TYPE;		    -- 품명
    V_MATNR_DIV             TB_MAS001.MATNR_DIV%TYPE;           -- 자재유형
    V_MATNR_GRP_CD			TB_MAS001.MATNR_GRP_CD%TYPE;	    -- 자재그룹
    V_PROD_GRP_CD           TB_MAS001.PROD_GRP_CD%TYPE;         -- 제품군
    V_BUSICD                TB_MAS001.BUSICD%TYPE;              -- 사업부
    V_KZAUS                 VARCHAR(2);                         --단종여부
    V_PART_DIV              TB_MAS001.PART_DIV%TYPE;            --품목구분

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역
    V_BS_WGT                TB_MAS001.BS_WGT%TYPE;    
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
    V_WERKS				:= 		V_JSON.get_string('WERKS');		        -- 플랜트
    V_MATNR				:= 		V_JSON.get_string('MATNR');		        -- 자재코드
    V_MATNR_NM			:= 		V_JSON.get_string('MATNR_NM');		    -- 자재명
    V_MATNR_DIV         :=      V_JSON.get_string('MATNR_DIV');         -- 자재유형
    V_MATNR_GRP_CD      := 		V_JSON.get_string('MATNR_GRP_CD');      -- 자재그룹 
    V_PROD_GRP_CD       :=      V_JSON.get_string('PROD_GRP_CD');       -- 제품군
    V_BUSICD            :=      V_JSON.get_string('BUSICD');            -- 사업부
    V_KZAUS             :=      V_JSON.get_string('KZAUS');             --단종여부
    V_PART_DIV          :=      V_JSON.get_string('PART_DIV');          --품목구분

    IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

        V_SQL :=  ' SELECT	 M001.MATNR				AS  "MATNR"			    -- 품목코드
                            ,M001.WERKS				AS  "WERKS"			    -- 플랜트
                            ,M001.MATNR_NM			AS  "MATNR_NM"		    -- 자재명(SHORT)
                            ,M001.MATNR_SHRT_NM     AS  "MATNR_SHRT_NM"     -- 자재명(LONG)
                            ,M001.MATNR_SPEC		AS  "MATNR_SPEC"	    -- 규격
                            ,M001.MATNR_DIV			AS  "MATNR_DIV"	        -- 유형
                            ,M001.MATNR_DIV_NM		AS  "MATNR_DIV_NM"      -- 유형명
                            ,M001.MATNR_GRP_CD		AS  "MATNR_GRP_CD"	    -- 자재그룹
                            ,M001.MATNR_GRP_NM		AS  "MATNR_GRP_NM"      -- 자재그룹명
                            ,M001.PROD_GRP_CD		AS  "PROD_GRP_CD"	    -- 제품군
                        	,M001.PROD_GRP_NM		AS  "PROD_GRP_NM"  	    -- 제품군명
                        	,M001.UNIT				AS  "UNIT" 			    -- 기본단위
							,FN_CD_VAL(''PART_DIV'',M001.PART_DIV)			AS  "PART_DIV"			 --품목구분
                            ,(SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''UNIT'' AND CMCDVL = M001.UNIT)      AS  "UNIT_NM"       -- 단위(명)
                    		,M001.RCV_UNIT			AS RCV_UNIT			    -- 입고단위
                            ,(SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''UNIT'' AND CMCDVL = M001.RCV_UNIT)  AS "RCV_UNIT_NM"    -- 입고단위(명)
                    		,M001.IN_UNIT			AS  "IN_UNIT"			-- 투입단위
                           ,(SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''UNIT'' AND CMCDVL = M001.IN_UNIT)   AS "IN_UNIT_NM"     -- 투입단위(명)
                            ,M001.PROD_UNIT			AS  "PROD_UNIT"		    -- 생산단위
                            ,(SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''UNIT'' AND CMCDVL = M001.PROD_UNIT) AS "PROD_UNIT_NM"   -- 생산단위(명)
                            ,M001.LGFSB				AS  "LGFSB"			    -- 외부입고저장위치
                            ,M001.LGPRO				AS  "LGPRO"			    -- 투입저장위치
                            ,M001.BESKZ				AS  "BESKZ"			    -- 조달유형
                            ,M001.LOT_YN			AS  "LOT_YN"		    -- LOT 관리여부
                            ,M001.BISMT				AS  "BISMT"		    	-- 기존품목코드
                            ,M001.MMSTA				AS  "MMSTA"			    -- 플랜트 고유 자재상태
                            ,M001.MMSTA_NM			AS  "MMSTA_NM"		    -- 플랜트 고유 자재상태 텍스트
                            ,M001.PRDHA				AS  "PRDHA"			    -- 제품계층구조       
                            ,M001.SOBSL				AS  "SOBSL"			    -- 특별조달유형       
                            ,M001.MATNR_STA			AS  "MSTAE"		        -- 자재상태           
                            ,M001.MATNR_STA_NM		AS  "MATNR_STA_NM"	    -- 자재상태 텍스트
                            ,M001.MIN_LOT_SIZE		AS  "MIN_LOT_SIZE"      -- 최소LOT크기        
                            ,M001.MAX_LOT_SIZE		AS  "MAX_LOT_SIZE"      -- 최대LOT크기        
                            ,M001.FIX_LOT_SIZE		AS  "FIX_LOT_SIZE"      -- 고정LOT크기        
                            ,M001.SV_STCK_QTY		AS  "SV_STCK_QTY"       -- 안전재고
                            ,M001.DISLS				AS  "DISLS"			    -- 로트크기유형       
                            ,M001.MATTYPE			AS  "MATTYPE"   	    -- HL LOT 구분
                            ,M001.MATTP_NM			AS  "MATTP_NM"		    -- HL LOT 구분명
                            ,M001.BUSICD			AS  "BUSICD"		    -- 사업부
                            ,M001.BUSINM			AS  "BUSINM"		    -- 사업부명
                            ,M001.PCODE				AS  "PCODE"			    -- 지종
                            ,M001.PCODE_NM			AS  "PCODE_NM"		    -- 지종명
                            ,M001.BS_WGT			AS  "BS_WGT"		    -- 평량
                        	,M001.TSPEED			AS  "TSPEED"		    -- 목표 선속
                            ,M001.INSP_MATNR		AS  "INSP_MATNR"	    -- 자재검사대상여부
                            --,M001.KZAUS				AS  "KZAUS"			    -- 단종여부
                            ,M001.MSTDE				AS  "MSTDE"			    -- 단종일자
                            ,M001.BRAND_ID			AS  "BRAND_ID"		    -- 브랜드
                            ,M001.BRAND_DESCR		AS  "BRAND_DESCR"	    -- 브랜드명
                            ,M001.DL_YN				AS  "DL_YN"			    -- 삭제여부
                            ,M001.STRGR				AS  "STRGR"			    -- 생산전략
                            ,M001.DOMESTIC			AS  "DOMESTIC"		    -- 내수구분(내수:Y, 외자:N)
                            ,(SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''UNIT'' AND CMCDVL = M001.DOMESTIC)  AS  "DOMESTIC_NM"   -- 내수구분(명)
                            ,M001.USE_YN			AS  "USE_YN"		    -- 사용유무
                            ,M001.INSP_YN			AS  "INSP_YN"		    -- 품질검사 대상 여부
                            ,M001.DSTBT_DDLIN		AS  "DSTBT_DDLIN"	    -- 유통기간
                            ,M001.KAN_NO			AS  "KAN_NO"		    -- KAN 번호
                            ,M001.REGDATE			AS  "REGDATE"		    -- 등록일시
                            ,NVL((SELECT NMLAST FROM USRMA WHERE USERID = M001.REGID), '' '')	    		AS  "REGNM"			-- 등록자
                            ,M001.UPDDATE			AS  "UPDDATE"		    -- 수정일시
                            ,NVL((SELECT NMLAST FROM USRMA WHERE USERID = M001.UPDID), '' '')				AS  "UPDNM"		    -- 수정자
                      FROM TB_MAS001 M001  -- 자재관리
			         WHERE 1 = 1 ';

        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN			    -- 플랜트
            V_SQL := V_SQL || ' AND M001.WERKS = ''' || V_WERKS || '''';        
        END IF;

        IF  V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN			    -- 자재코드
            V_SQL := V_SQL || ' AND M001.MATNR LIKE ''%' || V_MATNR || '%''';        
        END IF;

        IF  V_MATNR_NM IS NOT NULL OR TRIM(V_MATNR_NM) != '' THEN       -- 자재명
            V_SQL := V_SQL || ' AND ( M001.MATNR_NM LIKE ''%' || V_MATNR_NM || '%'''; 
            V_SQL := V_SQL || ' OR M001.MATNR_SHRT_NM LIKE ''%' || V_MATNR_NM || '%'' )';
        END IF;

        IF  V_MATNR_DIV IS NOT NULL OR TRIM(V_MATNR_DIV) != '' THEN       -- 자재유형
            V_SQL := V_SQL || ' AND M001.MATNR_DIV = ''' || V_MATNR_DIV || '''';        
        END IF;

        IF  V_MATNR_GRP_CD IS NOT NULL OR TRIM(V_MATNR_GRP_CD) != '' THEN		-- 자재그룹
            V_SQL := V_SQL || ' AND M001.MATNR_GRP_CD = ''' || V_MATNR_GRP_CD || '''';        
        END IF;

        IF  V_PROD_GRP_CD IS NOT NULL OR TRIM(V_PROD_GRP_CD) != '' THEN			-- 제품군
            V_SQL := V_SQL || ' AND M001.PROD_GRP_CD = ''' || V_PROD_GRP_CD || '''';        
        END IF;

        IF  V_BUSICD IS NOT NULL OR TRIM(V_BUSICD) != '' THEN			-- 사업부
            V_SQL := V_SQL || ' AND M001.BUSICD = ''' || V_BUSICD || '''';        
        END IF;

        IF  V_PART_DIV IS NOT NULL OR TRIM(V_PART_DIV) != '' THEN			-- 품목구분
            V_SQL := V_SQL || ' AND M001.PART_DIV = ''' || V_PART_DIV || '''';        
        END IF;

        IF  V_KZAUS IS NOT NULL OR TRIM(V_KZAUS) != '' THEN			-- 단종여부
            IF V_KZAUS = 'Y' THEN
                V_SQL := V_SQL || ' AND M001.MATNR_STA IS NOT NULL';
            ELSE
                V_SQL := V_SQL || ' AND M001.MATNR_STA IS NULL';
            END IF;

        END IF;

        V_SQL := V_SQL || ' ORDER BY M001.WERKS, M001.MATNR';

        --V_DEBUG := 'Y';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SUB_LIST-A' THEN  /* 단위 환산 리스트*/

    	V_SQL :=  'SELECT	 M005.MATNR			AS  "MATNR"         -- 자재코드
							,M005.UNIT			AS  "UNIT" 		    -- 단위
							,M005.UMREZ			AS  "UMREZ"		    -- 분자
							,M005.UMREN			AS  "UMREN"		    -- 분모
							,M005.USE_YN		AS  "USE_YN"	    -- 사용유무
							,M005.REGDATE		AS  "REGDATE"       -- 등록일자
							,NVL((SELECT NMLAST FROM USRMA WHERE USERID = M005.REGID), '' '')			AS  "REGNM"     -- 등록자
							,M005.UPDDATE		AS  "UPDDATE"	    -- 수정일자
							,NVL((SELECT NMLAST FROM USRMA WHERE USERID = M005.UPDID), '' '')			AS  "UPDNM"		-- 수정자
					  FROM  TB_MAS005 M005
					  WHERE MATNR = ''' || V_MATNR || ''' ';	

		V_SQL := V_SQL || ' ORDER BY M005.MATNR ';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SUB_LIST-B' THEN /*BOM 리스트*/

 		V_SQL :=  ' SELECT	 M007.MATNR			        AS  "MATNR"                 -- 자재코드
							,M007.WERKS			        AS  "WERKS"		            -- 플랜트코드
							,M007.BOM_NO		        AS  "BOM_NO"	            -- BOM Num
							,M007.ATN_BOM_NO            AS  "ATN_BOM_NO"            --  대체BOM
							,M007.DL_YN			        AS  "DL_YN"     		    -- 삭제여부
							,M007.USE_YN		        AS  "USE_YN"		        -- 사용유무
							,M007.PRCMC			        AS  "PRCMC" 		        -- 생산버전
							,M007.PRCMC_NM			    AS  "PRCMC_NM"  		    -- 생산버전내용
							,M008.PRT_MATNR_QTY		    AS  "PRT_MATNR_QTY"         -- 모품목기준수량
							,M008.PRT_MATNR_UNIT        AS  "PRT_MATNR_UNIT"	    -- 모품목기준수량 단위
							,M008.ITEM_NO		        AS  "ITEM_NO"       	    -- 항목 번호
							,M008.SUB_MATNR		        AS  "SUB_MATNR"	            -- 자품목자재
                            ,M001.MATNR_NM              AS  "SUB_MATNR_NM"          --자품목자재명
							,M008.SUB_MATNR_QTY		    AS  "SUB_MATNR_QTY"		    -- 수량
							,M008.SUB_MATNR_UNIT	    AS  "SUB_MATNR_UNIT"        -- 수량단위
							,M008.AUSCH			        AS  "AUSCH"		            -- 스크랩
							,M008.ITSOB			        AS  "ITSOB" 		        -- 특별유형
							,M007.REGDATE		        AS  "REGDATE"   		    -- 등록일시
							,NVL((SELECT NMLAST FROM USRMA WHERE USERID = M007.REGID), '' '')	        AS  "REGNM"		-- 등록자
							,M007.UPDDATE		        AS  "UPDDATE"	            -- 수정일시
							,NVL((SELECT NMLAST FROM USRMA WHERE USERID = M007.UPDID), '' '')	        AS  "UPDNM"		-- 수정자
					  FROM	TB_MAS007 M007, --생산버전 
                            TB_MAS008 M008, --BOM 
                            TB_MAS001 M001  --자재
					 WHERE	M007.WERKS = M008.WERKS(+) 
					   AND	M007.MATNR = M008.MATNR(+)
                       --AND  M007.BOM_NO = M008.BOM_NO(+)
                       AND  M007.ATN_BOM_NO = M008.ATN_BOM_NO(+)
                       AND  M008.WERKS = M001.WERKS(+)
                       AND  M008.MATNR = M001.MATNR(+)
                       AND  M007.MATNR = ''' || V_MATNR || ''' ';

        V_SQL := V_SQL || ' ORDER BY M007.WERKS, M007.MATNR';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;							

    ELSIF P_TYPE = 'SAVE' THEN
--        V_ARR_LIST        := V_JSON.get_array('list');
--
--        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
--            V_OBJ					:= TREAT (V_ARR_LIST.get (i) AS json_object_t);
--            V_OBJ					:= TREAT (V_OBJ.get ('map') AS json_object_t);
--
--            V_WERKS                 := V_OBJ.get_string('WERKS');       --플랜트
--            V_MATNR                 := V_OBJ.get_string('MATNR');       --자재코드
--            V_BS_WGT				:= V_OBJ.get_string('BS_WGT');		--평량
--
--            IF V_OBJ.get_string('GRowState') = 'U' THEN
--                UPDATE TB_MAS001
--                   SET BS_WGT   = V_BS_WGT
--                      ,UPDDATE  = SYSDATE
--                      ,UPDID    = V_SESS_USER_ID
--                 WHERE WERKS    = V_WERKS
--                   AND MATNR    = V_MATNR;
--            END IF;
--        END LOOP;
        RETURN;

    ELSIF P_TYPE = 'SUB_SAVE' THEN

          RETURN;

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
