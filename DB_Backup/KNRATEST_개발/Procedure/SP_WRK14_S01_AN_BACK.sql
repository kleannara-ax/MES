--------------------------------------------------------
--  DDL for Procedure SP_WRK14_S01_AN_BACK
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK14_S01_AN_BACK" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
    P_CNL_RMK        IN    VARCHAR2,
    P_DOC_NO1       OUT     VARCHAR2,       --실적문서번호
    P_DOC_NO2       OUT     VARCHAR2,       --투입자재 문서번호
	P_SUCCESS       OUT    varchar2,
    P_ERR_MSG       OUT    VARCHAR2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK14_S01_AN_BACK
 * PROGRAM NAME  : HL 생산현황(화장지, 생리대, 기저귀)
 * VERSION       : 1.0.0
 * DESCRIPTION   : HL 생산현황(화장지, 생리대, 기저귀)을 관리한다.
 *                 
 * AUTHOR NAME   : 안상현
 * CREATE DATE   : 2022/05/23
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/22    1.0.0   안상현         Initial Version
 * 2022/08/07    1.0.1   여한진         실적재전송 추가
 *==============================================================================
 *  관련 테이블
 *        - [TB_WRK001]  : ( R  ) HL 생산 실적 테이블
 *        - [TB_MAS001]  : ( R  ) 자재 기준정보 테이블
 *        - [V_WRK_ORDR] : ( R  ) 작업지시 전체 뷰 테이블
 *        - [USRMA] 	 : ( R  ) 사용자 테이블
 *=============================================================================*/

AS
	V_PRG_NM          	VARCHAR2(100) 	:= 'SP_WRK14_S01_AN_BACK';     -- PROCEDURE NAME

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
   	V_DEBUG          	varchar2(1);

	-- 조건절 처리용 변수선언 영역
	V_WERKS        		TB_WRK001.WERKS%TYPE;				--플랜트코드
	V_MACH_CD	 		TB_WRK001.MACH_CD%TYPE;				--설비코드
	V_MATNR	 			TB_WRK001.MATNR%TYPE;				--자재코드
    V_CNL_YN	 		TB_WRK001.CNL_YN%TYPE;				--취소여부
	V_WRK_SHIFT			TB_WRK001.WRK_SHIFT%TYPE;			--작업조
	V_RANGE_SQL      	varchar2(4000);						--실적일자
	V_SQL				CLOB;

    V_DOC_DIV           NUMBER;
    V_SDOC_NO           VARCHAR2(30);
    V_SDOC_SEQNO        VARCHAR2(10);
    V_PRFM_DT           VARCHAR2(10);
    V_IND_BCD           VARCHAR2(20);
    V_WRK_ORDR_NO       VARCHAR2(20);
    V_WRK_ORDR_SEQNO    NUMBER;


    V_SAP_WRK_CD        TB_MAS012.SAP_WRK_CD%TYPE;
    V_DOC_NO            TB_WRK001.DOC_NO%TYPE;
    V_DOC_SEQNO         TB_WRK001.DOC_SEQNO%TYPE;
    V_ORDER_NO          TB_WRK001.ORDER_NO%TYPE;
    V_ROLLCNT           TB_WRK001.ROLLCNT%TYPE;
    V_STA               VARCHAR2(10);
    V_SEQNO_M           TB_INV003.SEQNO%TYPE;
    V_WRK_ORDR_NO_M     TB_INV003.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO_M  TB_INV003.WRK_ORDR_SEQNO%TYPE;
    V_IND_BCD_M         TB_INV003.IND_BCD%TYPE;
    V_LOT_NO_M          TB_INV003.LOT_NO%TYPE;
    V_MATNR_M           TB_INV003.MATNR%TYPE;
    V_INP_DT_M          TB_INV003.INP_DT%TYPE;
    V_USE_QTY_M         TB_INV003.USE_QTY%TYPE;
    V_T_USE_QTY         TB_INV003.USE_QTY%TYPE;
    V_UNIT_M            TB_INV003.UNIT%TYPE;
    V_ROLLCNT_M         TB_INV003.ROLLCNT%TYPE;
    V_WGT_M             TB_INV003.WGT%TYPE;    
    V_CHG_FLG_M         TB_INV003.CHG_FLG%TYPE;    
    V_STCK_KY_M         TB_INV003.STCK_KY%TYPE;
    V_LOT_NUM_M         TB_INV003.LOT_NUM%TYPE;
    V_CHK_PP_YN         TB_WRK001.CHK_PP_YN%TYPE; 
    V_CHK_QC_YN         TB_WRK001.CHK_QC_YN%TYPE; 

    V_VGBEL             VARCHAR2(30); 
    V_VGPOS             VARCHAR2(6);
    V_DATE              DATE := SYSDATE;
	PROD_CUR            SYS_REFCURSOR;		-- 커서 정의

    V_LOT_NO            TB_WRK001.LOT_NO%TYPE;
    V_CNL_RMK           TB_WRK001.CNL_RMK%TYPE;
    V_DOC_NO_1          TB_WRK001.DOC_NO%TYPE;
    V_DOC_NO_2          TB_WRK001.DOC_NO%TYPE;
    V_DOC_SEQNO_1       TB_WRK001.DOC_SEQNO%TYPE;
    V_DOC_SEQNO_2       TB_WRK001.DOC_SEQNO%TYPE;

    V_STCK_STA          TB_INV001.STCK_STA%TYPE;
    V_YMCHK             TB_MAS011.YMCHK%TYPE;
    V_CNT               NUMBER;
    V_DOC_NO1           VARCHAR2(4000);
BEGIN
	OPEN P_RS_LIST FOR 

	SELECT NULL FROM DUAL WHERE ROWNUM = 0;

	V_JSON 				:= JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID		:= V_JSON.get_string('SES_USER_ID');
	V_PLT_CD			:= V_JSON.get_string('SES_PLNTKY');

	V_WERKS				:= V_JSON.get_string('WERKS');			--플랜트코드
	V_MACH_CD			:= V_JSON.get_string('MACH_CD');		--설비코드
	V_MATNR				:= V_JSON.get_string('MATNR');			--자재코드
	V_IND_BCD			:= V_JSON.get_string('IND_BCD');		--개별바코드
	V_LOT_NO        	:= V_JSON.get_string('LOT_NO');      	--LOT NO
    V_CNL_YN        	:= V_JSON.get_string('CNL_YN');      	--취소여부

	V_RANGE_SQL 		:= V_JSON.get_string('RANGE_SQL');   	--실적일자
	V_CNL_RMK           := P_CNL_RMK;

	IF P_TYPE = 'LIST_A' THEN
		V_SQL := 
		' SELECT
				WRK001.WERKS						AS WERKS			--플랜트코드
			,	WRK001.PRFM_DT						AS PRFM_DT			--실적일자
			,	WRK001.MATNR						AS MATNR			--자재코드
			,	MAS001.MATNR_NM 					AS MATNR_NM			--자재명	
			,	WRK001.MACH_CD 						AS MACH_CD			--설비코드
			,	SUM(NVL(WRK001.PLT_QTY, 0))			AS PLT_QTY			--PLT수량
			,	SUM(NVL(WRK001.BOX_QTY, 0))			AS BOX_QTY			--BOX수량
			,	SUM(NVL(WRK001.BAG_QTY, 0))			AS BAG_QTY			--BAG수량
			,	SUM(NVL(WRK001.EA_QTY, 0))			AS EA_QTY			--EA수량
			,	SUM(NVL(WRK001.WGT, 0)) 			AS WGT				--중량
			FROM 
				TB_WRK001 WRK001
			LEFT JOIN TB_MAS001 MAS001 ON (WRK001.MATNR = MAS001.MATNR AND WRK001.WERKS = MAS001.WERKS)
			WHERE NVL(WRK001.CNL_YN, ''N'') != ''Y''
			  AND WRK001.PRFM_GTHR_YN = ''Y''
		      AND MAS001.MATNR_DIV <> ''HALB'' 
            ';	

			IF (V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '') THEN
            	V_SQL := V_SQL || ' AND WRK001.WERKS = ''' || V_WERKS || ''''; --플랜트코드				      
        	END IF;

        	IF (V_MACH_CD IS NOT NULL OR TRIM(V_MACH_CD) != '') THEN
            	V_SQL := V_SQL || ' AND WRK001.MACH_CD = ''' || V_MACH_CD || ''''; --설비코드				      
        	END IF;

        	IF (V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '') THEN
            	V_SQL := V_SQL || ' AND WRK001.MATNR = ''' || V_MATNR || ''''; --자재코드				      
        	END IF;

        	IF (V_WRK_SHIFT IS NOT NULL OR TRIM(V_WRK_SHIFT) != '') THEN
            	V_SQL := V_SQL || ' AND WRK001.WRK_SHIFT = ''' || V_WRK_SHIFT || ''''; --작업조				      
        	END IF;	
        
        	IF (V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '') THEN
	        	V_SQL := V_SQL || V_RANGE_SQL; --실적일자  
	        END IF;

	       	V_SQL := V_SQL || ' GROUP BY WRK001.WERKS, WRK001.PRFM_DT, WRK001.MATNR, MAS001.MATNR_NM, WRK001.MACH_CD ';

        	V_SQL := V_SQL || ' ORDER BY MATNR';

        IF (V_DEBUG = 'Y') THEN
        	INSERT INTO PROC_LOG (SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;

	ELSIF P_TYPE = 'LIST_B' THEN
		V_SQL := 
		' SELECT  WRK001.WERKS				AS WERKS			--플랜트코드
			,	WRK001.PRFM_DT				AS PRFM_DT			--실적일자
			,	WRK001.MATNR				AS MATNR			--자재코드
			,	MAS001.MATNR_NM 			AS MATNR_NM			--자재명	
			,	WRK001.MACH_CD 				AS MACH_CD			--설비코드
            ,   WRK001.WRK_ORDR_NO			AS WRK_ORDR_NO  	--작업지시번호
            ,   WRK001.WRK_ORDR_SEQNO		AS WRK_ORDR_SEQNO   --작업지시순번
			,	WRK001.LOT_NO				AS LOT_NO			--LOT번호
			,	WRK001.PLT_QTY				AS PLT_QTY			--PLT수량
			,	WRK001.BOX_QTY				AS BOX_QTY			--BOX수량
			,	WRK001.BAG_QTY				AS BAG_QTY			--BAG수량
			,	WRK001.EA_QTY				AS EA_QTY			--EA수량
			,	WRK001.WGT 					AS WGT				--중량
			,	WRK001.IND_BCD 				AS IND_BCD			--개별바코드
			,	WRK001.PRD_STR_DATE			AS START_DATE		--생산시작일시
			,	WRK001.PRD_END_DATE			AS END_DATE			--생산종료일시
			,	WRK001.WRK_SHIFT			AS WRK_SHIFT		--작업조
			, 	WRK001.WRK_CLASS			AS WRK_CLASS		--작업반
            ,   WRK001.ORDER_NO             AS ORDER_NO         --오더번호
            ,   WRK001.DOC_NO               AS DOC_NO           --MES문서번호
            ,   WRK001.DOC_SEQNO            AS DOC_SEQNO        --MES문서순번
            ,   DECODE(NVL(WRK001.SDOC_NO, '' ''), '' '', ''미전송'', ''E'', ''실패'', ''성공'')     AS SAP_YN
            ,   DECODE(NVL(WRK001.CNL_YN,''N''), ''N'', ''N'', ''Y'')               AS CNL_YN           --취소여부
            ,   WRK001.REGDATE              AS REGDATE          --등록일시
			,	USR.NMLAST 					AS REGNM			--등록자(작업자)
			FROM 
				TB_WRK001 WRK001
			LEFT JOIN TB_MAS001 MAS001 ON (WRK001.MATNR = MAS001.MATNR AND WRK001.WERKS = MAS001.WERKS)
			LEFT JOIN USRMA USR ON (WRK001.REGID = USR.USERID)
			WHERE WRK001.PRFM_GTHR_YN = ''Y'' 
  			  AND MAS001.MATNR_DIV <> ''HALB''
			--AND NVL(WRK001.CNL_YN, ''N'') != ''Y''
			';	

			IF (V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '') THEN
            	V_SQL := V_SQL || ' AND WRK001.WERKS = ''' || V_WERKS || ''''; 			--플랜트코드				      
        	END IF;

        	IF (V_MACH_CD IS NOT NULL OR TRIM(V_MACH_CD) != '') THEN
            	V_SQL := V_SQL || ' AND WRK001.MACH_CD = ''' || V_MACH_CD || ''''; 		--설비코드				      
        	END IF;

        	IF (V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '') THEN
            	V_SQL := V_SQL || ' AND WRK001.MATNR = ''' || V_MATNR || ''''; 			--자재코드				      
        	END IF;

        	IF (V_WRK_SHIFT IS NOT NULL OR TRIM(V_WRK_SHIFT) != '') THEN
            	V_SQL := V_SQL || ' AND WRK001.WRK_SHIFT = ''' || V_WRK_SHIFT || ''''; --작업조				      
        	END IF;	
        
        	IF (V_IND_BCD IS NOT NULL OR TRIM(V_IND_BCD) != '') THEN
            	V_SQL := V_SQL || ' AND WRK001.IND_BCD = ''' || V_IND_BCD || ''''; 		--개별바코드				      
        	END IF;

        	IF (V_LOT_NO IS NOT NULL OR TRIM(V_LOT_NO) != '') THEN
            	V_SQL := V_SQL || ' AND WRK001.LOT_NO = ''' || V_LOT_NO || ''''; 		--LOT NO				      
        	END IF;

--            IF (V_CNL_YN IS NOT NULL OR TRIM(V_CNL_YN) != '') THEN              --취소여부
--            	IF V_CNL_YN = 'Y' THEN
--                    V_SQL := V_SQL || ' AND WRK001.PRFM_GTHR_YN = ''N'' ';
--                ELSE
--                    V_SQL := V_SQL || ' AND NVL(WRK001.CNL_YN, ''N'') = ''N'' ';
--                END IF;				      
--        	END IF;

        	IF (V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '') THEN
	        	V_SQL := V_SQL || V_RANGE_SQL; --실적일자  
	        END IF;
        		OPEN P_RS_LIST FOR V_SQL;

        	V_SQL := V_SQL || ' ORDER BY PRFM_DT, PRD_STR_DATE,IND_BCD';

        IF (V_DEBUG = 'Y') THEN
        	INSERT INTO PROC_LOG (SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;
    ELSIF P_TYPE = 'SEND' THEN  --합지기 실적 재전송
        V_ARR_LIST        := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ           := TREAT (V_OBJ.get ('map') AS json_object_t);

            V_WERKS         := V_OBJ.get_string('WERKS');
            V_MACH_CD       := V_OBJ.get_string('MACH_CD');
            V_ORDER_NO      := V_OBJ.get_string('ORDER_NO');
            V_DOC_NO        := V_OBJ.get_string('DOC_NO');
            V_DOC_SEQNO     := V_OBJ.get_number('DOC_SEQNO');

            IF V_WERKS = 'P200' THEN
                IF SUBSTR(V_MACH_CD, 0, 3) = 'TPG' THEN
                    UPDATE TB_IFS019
                       SET ZRESULT = 'N'
                     WHERE AUFNR = V_ORDER_NO
                       AND MDOCNO = V_DOC_NO
                       AND MDOCSEQ = V_DOC_SEQNO;
                ELSE 
                    UPDATE TB_IFS002
                       SET ZRESULT = 'N'
                     WHERE AUFNR = V_ORDER_NO
                       AND MDOCNO = V_DOC_NO
                       AND MDOCSEQ = V_DOC_SEQNO;
                END IF;
            ELSE
                IF SUBSTR(V_MACH_CD, 0, 3) = 'SPF' OR SUBSTR(V_MACH_CD, 0, 3) = 'BPI' THEN
                    UPDATE TB_IFS019
                       SET ZRESULT = 'N'
                     WHERE AUFNR = V_ORDER_NO
                       AND MDOCNO = V_DOC_NO
                       AND MDOCSEQ = V_DOC_SEQNO;
                ELSE
                    UPDATE TB_IFS011
                       SET ZRESULT = 'N'
                     WHERE AUFNR = V_ORDER_NO
                       AND MDOCNO = V_DOC_NO
                       AND MDOCSEQ = V_DOC_SEQNO;
                END IF;
            END IF;
        END LOOP;
	ELSIF P_TYPE = 'DELETE' THEN
        V_ARR_LIST        := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ           := TREAT (V_OBJ.get ('map') AS json_object_t);

            V_WERKS         := V_OBJ.get_string('WERKS');
            V_MACH_CD       := V_OBJ.get_string('MACH_CD');
            V_IND_BCD       := V_OBJ.get_string('IND_BCD');
            V_MATNR         := V_OBJ.get_string('MATNR');
            V_PRFM_DT       := V_OBJ.get_string('PRFM_DT');

            BEGIN
            SELECT YMCHK INTO  V_YMCHK
              FROM TB_MAS011
             WHERE WERKS = V_WERKS
               AND YYMM = SUBSTR(V_PRFM_DT, 0, 6);

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_YMCHK := 'N';
            END;

            IF V_YMCHK = 'N' THEN
                P_SUCCESS := 'N';
                P_ERR_MSG := V_MATNR || ' 는 실적취소 가능한 월이 아닙니다.';
                ROLLBACK;
                RETURN;
            END IF;
           
			BEGIN
	            SELECT STCK_STA INTO V_STCK_STA
	              FROM TB_INV001
	             WHERE WERKS = V_WERKS
	               AND MACH_CD = V_MACH_CD
	               AND IND_BCD = V_IND_BCD;
            EXCEPTION WHEN NO_DATA_FOUND THEN
            	P_SUCCESS := 'N';
            	P_ERR_MSG := V_IND_BCD || '는 폐품실적이므로 생산 폐품 현황에서 취소할 수 있습니다.';
            	ROLLBACK;
            	RETURN;
	        END;  

            IF NVL(V_STCK_STA , '') = '80' THEN
                P_SUCCESS           := 'N';
                P_ERR_MSG := V_MATNR || ' 는 완제품 입고 요청 상태이므로 실적을 취소할 수 없습니다. 출고요청을 취소하세요!';
                ROLLBACK;
                RETURN;
            ELSIF  NVL(V_STCK_STA , '') = '70' THEN
                P_SUCCESS           := 'N';
                P_ERR_MSG := V_MATNR || ' 는 완제품 출고 상태이므로 실적을 취소할 수 없습니다.';
                ROLLBACK;
                RETURN;
            END IF;

        END LOOP;
--        V_DOC_NO_2 := FN_GET_MDOCNO('M','IF143');
--        V_DOC_SEQNO_2 := 0;

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ           := TREAT (V_OBJ.get ('map') AS json_object_t);

            V_WERKS         := V_OBJ.get_string('WERKS');
            V_MACH_CD       := V_OBJ.get_string('MACH_CD');
            V_PRFM_DT       := V_OBJ.get_string('PRFM_DT');
            V_IND_BCD       := V_OBJ.get_string('IND_BCD');
            V_MATNR         := V_OBJ.get_string('MATNR');
            V_LOT_NO        := V_OBJ.get_string('LOT_NO');      --추가
            V_WRK_ORDR_NO           := V_OBJ.get_string('WRK_ORDR_NO');
            V_WRK_ORDR_SEQNO        := TO_NUMBER(V_OBJ.get_string('WRK_ORDR_SEQNO'));

            SELECT SAP_WRK_CD INTO V_SAP_WRK_CD
              FROM TB_MAS012
             WHERE MACH_CD = V_MACH_CD;

            SELECT ORDER_NO, ROLLCNT, CHK_PP_YN, CHK_QC_YN, DOC_NO, DOC_SEQNO, SDOC_NO, SDOC_SEQNO
                INTO V_ORDER_NO, V_ROLLCNT, V_CHK_PP_YN, V_CHK_QC_YN, V_DOC_NO, V_DOC_SEQNO, V_SDOC_NO, V_SDOC_SEQNO
              FROM TB_WRK001
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD;

            --실적 취소
            UPDATE TB_WRK001
               SET CNL_YN = 'Y',
                CNL_RMK = V_CNL_RMK,
                PRFM_GTHR_YN = 'N',
                UPDDATE = SYSDATE,
                UPDID = V_SESS_USER_ID
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD;

            --재고삭제
            UPDATE TB_INV001
                SET STCK_QTY = 0,
                    DLFL = 'Y',
                    UPDDATE = SYSDATE,
                    UPDID = V_SESS_USER_ID
              WHERE WERKS = V_WERKS
                AND MACH_CD = V_MACH_CD
                AND IND_BCD = V_IND_BCD;      

            --작업지시 작업완료 FLAG 취소
            IF V_WERKS = 'P200' THEN
                IF SUBSTR(V_MACH_CD, 2, 2) = 'RA' THEN 
                    UPDATE TB_SCH012
                       SET COMP_YN = CASE WHEN COMP_YN = 'Y' THEN 'N' ELSE 'I' END
                     WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;  
                ELSE
                    UPDATE TB_SCH019
                       SET COMP_YN = CASE WHEN COMP_YN = 'Y' THEN 'N' ELSE 'I' END
                     WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;  
                END IF;
             ELSIF V_WERKS = 'P300' THEN
                IF SUBSTR(V_MACH_CD, 2, 2) = 'RB' THEN 
                    UPDATE TB_SCH013
                       SET COMP_YN = CASE WHEN COMP_YN = 'Y' THEN 'N' ELSE 'I' END
                     WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;  
                ELSE
                    UPDATE TB_SCH019
                       SET COMP_YN = CASE WHEN COMP_YN = 'Y' THEN 'N' ELSE 'I' END
                     WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;  
                END IF;
             ELSIF V_WERKS = 'P500' THEN
                IF SUBSTR(V_MACH_CD, 2, 2) = 'RC' THEN 
                    UPDATE TB_SCH014
                       SET COMP_YN = CASE WHEN COMP_YN = 'Y' THEN 'N' ELSE 'I' END
                     WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;  
                ELSE
                     UPDATE TB_SCH019
                       SET COMP_YN = CASE WHEN COMP_YN = 'Y' THEN 'N' ELSE 'I' END
                     WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;  
                END IF;
             END IF;

            IF NVL(V_SDOC_NO, ' ') <> ' ' AND NVL(V_SDOC_NO, ' ') <> 'E' THEN
                V_DOC_SEQNO_1 := 1;
            
                V_DOC_NO_1 := FN_GET_MDOCNO('M','IF129');
                
                IF NVL(V_DOC_NO1, ' ') = ' ' THEN
                    V_DOC_NO1 := V_DOC_NO_1;
                ELSE
                    V_DOC_NO1 := V_DOC_NO1 || ',' || V_DOC_NO_1;
                END IF;

                INSERT INTO TB_IFS007(RUECK, RMZHL, MDOCNO, MDOCSEQ, MAKE_DATE, MAKER,
                                        WORKCENTERCODE, AUFNR, ROLLCNT, MBLNR, LOTNO)
                           VALUES(V_SDOC_NO, V_SDOC_SEQNO, V_DOC_NO_1, TO_CHAR(V_DOC_SEQNO_1), V_DATE, V_SESS_USER_ID,
                                V_SAP_WRK_CD, V_ORDER_NO, V_ROLLCNT, V_SDOC_NO, V_LOT_NO);    
            END IF;

            --LOT 추적 이력 삭제    
            DELETE
              FROM TB_WRK008
             WHERE WERKS = V_WERKS
               AND IND_BCD = V_IND_BCD;

            UPDATE TB_WRK021
               SET CNL_YN = 'Y'
             WHERE DOC_NO = V_DOC_NO
               AND DOC_SEQNO = V_DOC_SEQNO;

            OPEN PROD_CUR FOR
                SELECT SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO, IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, 
                        USE_QTY, UNIT, ROLLCNT, WGT, CHG_FLG, STCK_KY, LOT_NUM
                        INTO
                        V_SEQNO_M, V_WRK_ORDR_NO_M, V_WRK_ORDR_SEQNO_M, V_IND_BCD_M, V_LOT_NO_M, V_MATNR_M, V_INP_DT_M, 
                        V_USE_QTY_M, V_UNIT_M, V_ROLLCNT_M, V_WGT_M, V_CHG_FLG_M, V_STCK_KY_M, V_LOT_NUM_M
                  FROM TB_INV010
                 WHERE WERKS = V_WERKS 
                   AND MACH_CD = V_MACH_CD
                   AND IND_BCD = V_IND_BCD;
            LOOP
            FETCH PROD_CUR INTO  V_SEQNO_M, V_WRK_ORDR_NO_M, V_WRK_ORDR_SEQNO_M, V_IND_BCD_M, V_LOT_NO_M, V_MATNR_M, V_INP_DT_M, 
                            V_USE_QTY_M, V_UNIT_M, V_ROLLCNT_M, V_WGT_M, V_CHG_FLG_M, V_STCK_KY_M, V_LOT_NUM_M;

            EXIT WHEN PROD_CUR %NOTFOUND;    
                UPDATE TB_INV003
                   SET USE_QTY = USE_QTY - V_USE_QTY_M,
                       STCK_QTY = STCK_QTY + V_USE_QTY_M,
                       WGT = WGT + V_USE_QTY_M,
                       UPDDATE = SYSDATE,
                       UPDID = V_SESS_USER_ID
                  WHERE WERKS = V_WERKS
                    AND MACH_CD = V_MACH_CD
                    AND IND_BCD = V_IND_BCD_M;

                IF SQL%ROWCOUNT =0 THEN
                    SELECT SUM(USE_QTY)  INTO V_T_USE_QTY
                      FROM TB_INV010
                     WHERE WERKS = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND IND_BCD = V_IND_BCD
                       AND IND_BCD_M = V_IND_BCD_M
                       AND USE_QTY > 0
                       AND NVL(CNL_YN, 'N') = 'N';
                      
                    --220825 KKY 자재투입이력 순번처리 수정
                    SELECT COUNT(*) INTO V_CNT
                      FROM TB_INV003
                     WHERE WERKS = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND MATNR = V_MATNR_M
                       AND SEQNO = 1;
                    
                    IF V_CNT > 0 THEN
                        UPDATE TB_INV003
                           SET SEQNO = SEQNO + 1
                         WHERE WERKS = V_WERKS
                           AND MACH_CD = V_MACH_CD
                           AND MATNR = V_MATNR_M;
                    END IF;
                    
--                    SELECT NVL(MAX(SEQNO), 0) + 1
--					  INTO V_SEQNO_M
--					  FROM TB_INV003
--					 WHERE WERKS = V_WERKS
--                       AND MACH_CD = V_MACH_CD
--                       AND MATNR = V_MATNR_M;
                    V_SEQNO_M := 1;   
                    INSERT INTO TB_INV003(WERKS, MACH_CD, MATNR, IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                        LOT_NO, INP_DT, IN_QTY, USE_QTY, STCK_QTY, 
                                        UNIT, ROLLCNT, WGT,
                                        CHG_FLG, STCK_KY, LOT_NUM, REGDATE, REGID)
                                VALUES(V_WERKS, V_MACH_CD, V_MATNR_M, V_IND_BCD_M, V_SEQNO_M, V_WRK_ORDR_NO_M, V_WRK_ORDR_SEQNO_M,
                                        V_LOT_NO_M, V_INP_DT_M, V_T_USE_QTY, V_T_USE_QTY - V_USE_QTY_M, V_T_USE_QTY -(V_T_USE_QTY - V_USE_QTY_M),
                                        V_UNIT_M, V_ROLLCNT_M, V_USE_QTY_M,
                                        V_CHG_FLG_M, V_STCK_KY_M, V_LOT_NUM_M, V_DATE, V_SESS_USER_ID);
                END IF;

                UPDATE TB_INV010
                   SET CNL_YN = 'Y',
                       UPDDATE = SYSDATE,
                       UPDID = V_SESS_USER_ID
                 WHERE WERKS = V_WERKS 
                   AND MACH_CD = V_MACH_CD
                   AND IND_BCD = V_IND_BCD
                   AND IND_BCD_M = V_IND_BCD_M
                   AND MATNR_M = V_MATNR_M;   
            END LOOP;
            CLOSE PROD_CUR;
        END LOOP;
	END IF;

    IF V_DOC_SEQNO_1 > 0 THEN
        P_DOC_NO1 := V_DOC_NO1;
    ELSE
        P_DOC_NO1 := '';
    END IF;

	P_SUCCESS := 'Y';
    COMMIT;

--   EXCEPTION
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
