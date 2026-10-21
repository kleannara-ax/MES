
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_INV10_S01" (
    P_TYPE           IN    varchar2, -- LIST, SUB_LIST
    P_JSON_STR       IN    CLOB ,
    P_SUCCESS       OUT    varchar2,
    P_ERR_MSG       OUT    varchar2,
    P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : INV10{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 자재사용이력{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 자재사용이력을 관리한다.{프로그램에 대한 상세한 내용 기술}
 *
 * AUTHOR NAME   : 여한진{최초 작성자 명 기술}
 * CREATE DATE   : 2022/11/18 {최초 작성일자 기술}
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
 * 2026/10/16    1.0.1                  엑셀업로드: 기존 사용이력/파일 내 중복 개별바코드 차단 해제,
 *                                       기존 사용이력 바코드 전체를 모아 한 번에 사용자 확인
 * 2026/10/16    1.0.2                  엑셀업로드: 전량 사용되어 TB_INV003 행이 DELETE되고 동일 플랜트/설비
 *                                       사용이력만 남은 바코드(사용완료)는 확인/취소 없이 업로드 차단,
 *                                       해당 바코드 전체를 모아 한 번에 안내
 * 2026/10/21    1.0.3                  엑셀업로드: TB_INV001 기준 투입자재 개별바코드 LOT번호/단위 검증
 *                                       (바코드 없음/LOT 오류/단위 오류는 차단, 단위가 모두 빈칸이면 확인)
 *==============================================================================
 *  관련 테이블
 *      - [TB_INV010] : (.R..) 자재투입이력
 *      - [TB_MAS012] : (.R..) 설비 마스터
 *      - [TB_MAS001] : (.R..) 자재
 *      - [TB_INV001] : (.R..) 공정재고 (엑셀업로드 투입자재 LOT번호/단위 기준)
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_INV10_S01';     -- PROCEDURE NAME

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
    V_DATE          DATE := SYSDATE;
    V_WERKS			TB_INV010.WERKS%TYPE;
    V_MACH_CD       TB_INV010.MACH_CD%TYPE;
    V_MATNR 		TB_INV010.MATNR%TYPE;
    V_IND_BCD       TB_INV010.IND_BCD%TYPE;

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역
    V_PRFM_DT     		TB_INV010.PRFM_DT%TYPE;
    V_INP_DT			TB_INV010.INP_DT%TYPE;
    V_LOT_NO			TB_INV010.LOT_NO%TYPE;
    V_SEQNO				TB_INV010.SEQNO%TYPE;
    V_WRK_ORDR_NO		TB_INV010.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO	TB_INV010.WRK_ORDR_SEQNO%TYPE;
    V_MATNR_M    		TB_INV010.MATNR_M%TYPE;
    V_IND_BCD_M   		TB_INV010.IND_BCD_M%TYPE;
    V_LOT_NO_M			TB_INV010.LOT_NO_M%TYPE;
    V_USE_QTY    		TB_INV010.USE_QTY%TYPE;
    V_STCK_QTY1         TB_INV010.USE_QTY%TYPE;
    V_STCK_QTY2         TB_INV010.USE_QTY%TYPE;
    V_USE_CHG_QTY       TB_INV010.USE_QTY%TYPE;
    V_UNIT   			TB_INV010.UNIT%TYPE;
    V_ORDER_NO          TB_INV001.ORDER_NO%TYPE;
    V_CHG_QTY           TB_INV010.USE_QTY%TYPE;
    V_STCK_QTY_PRE      TB_INV001.STCK_QTY%TYPE;
    V_SEQNO1            TB_INV010.SEQNO%TYPE;
    PROD_CUR            SYS_REFCURSOR;		-- 커서 정의
    PROD_CUR2           SYS_REFCURSOR;		-- 커서 정의
    V_TEMP_ROWID        ROWID;              -- 엑셀업로드 TEMP 행 식별(동일 키 중복 행 대응)

    -- 사용완료 바코드(투입 후 전량 사용되어 TB_INV003 행이 DELETE되고, 자재사용이력만 남은 바코드) → 업로드 차단
    V_USED_UP_CNT       NUMBER := 0;
    V_USED_UP_MSG       VARCHAR2(32767);    -- 사용완료 바코드 전체 목록

    V_STCK_QTY_INV003		NUMBER(15, 0);
    V_STCK_QTY_INV001		NUMBER(15, 0);

    -- 엑셀 업로드 검증용 변수
    V_DUP_CNT              NUMBER := 0;
    V_DUP_IND_BCD_M        VARCHAR2(3000);
    V_FILE_DUP_CNT         NUMBER := 0;
    V_FILE_DUP_IND_BCD_M   VARCHAR2(3000);
    V_NOT_INPUT_CNT        NUMBER := 0;
    V_NOT_INPUT_BCD        VARCHAR2(3000);
    V_SHORT_STCK_CNT       NUMBER := 0;
    V_SHORT_STCK_BCD       VARCHAR2(3000);
    V_YEAR_CONFIRMED       VARCHAR2(1) := 'N';   -- 사용자 확인 여부(다른 연도 일자 + 기존 사용이력 바코드 + 단위 빈칸)
    V_OTHER_YEAR_DATES     VARCHAR2(3000);
    V_CHECK_DATE           DATE;
    V_USED_BCD_MSG         VARCHAR2(32767);       -- 기존 자재사용이력 등록 바코드 전체 목록
    V_CONFIRM_MSG          VARCHAR2(32767);       -- 사용자 확인 메시지

    -- TB_INV001(공정재고) 기준 투입자재 개별바코드 LOT번호/단위 검증용 변수
    V_I001_CNT             NUMBER := 0;           -- 개별바코드의 TB_INV001 행 수
    V_LOT_OK_CNT           NUMBER := 0;           -- 엑셀 LOT번호와 일치하는 TB_INV001 행 수
    V_UNIT_OK_CNT          NUMBER := 0;           -- 엑셀 단위와 일치하는 TB_INV001 행 수
    V_I001_LOTS            VARCHAR2(4000);        -- TB_INV001의 올바른 LOT번호
    V_I001_UNITS           VARCHAR2(4000);        -- TB_INV001의 올바른 단위
    V_SHOW_LOT             VARCHAR2(4000);        -- 단위 메시지에 표시할 LOT번호
    V_NO_BCD_CNT           NUMBER := 0;           -- TB_INV001에 없는 개별바코드 수
    V_NO_BCD_MSG           VARCHAR2(10000);
    V_LOT_ERR_CNT          NUMBER := 0;           -- LOT번호 오류 수
    V_LOT_ERR_MSG          VARCHAR2(10000);
    V_UNIT_ERR_CNT         NUMBER := 0;           -- 단위 오류 수
    V_UNIT_ERR_MSG         VARCHAR2(10000);
    V_BLANK_UNIT_CNT       NUMBER := 0;           -- 엑셀/TB_INV001 모두 단위가 빈칸인 수 (사용자 확인)
    V_BLANK_UNIT_MSG       VARCHAR2(10000);
    V_BLOCK_MSG            VARCHAR2(32767);       -- 차단 메시지

BEGIN

    OPEN P_RS_LIST FOR
        SELECT NULL FROM DUAL WHERE ROWNUM = 0;

    V_DEBUG := 'N';
    V_RUN_SQL := 'Y';

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

    V_SESS_USER_ID       :=      V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=      V_JSON.get_string('SES_PLNTKY');

    IF V_JSON.has('P_YEAR_CONFIRMED') THEN
        V_YEAR_CONFIRMED := NVL(V_JSON.get_string('P_YEAR_CONFIRMED'), 'N');
    END IF;

    /* 조건값 할당 */
    V_RANGE_SQL         :=      V_JSON.get_string('RANGE_SQL');	--실적일자, 자재코드
    V_WERKS		        :=      V_JSON.get_string('WERKS');     --플랜트
    V_MACH_CD           :=      V_JSON.get_string('MACH_CD');   --설비코드
    V_IND_BCD           :=      V_JSON.get_string('IND_BCD');   --개별바코드

    IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

        V_SQL := ' SELECT I010.WERKS,      		--플랜트
                          I010.PRFM_DT,     	--실적일자
					  	  I010.INP_DT,			--투입일자
                          I010.MACH_CD,    		--설비코드
                          M012.MACH_NM,    		--설비명
                          I010.MATNR,      		--자재코드
                          M001.MATNR_NM,   		--자재명
					      I010.LOT_NO,			--LOT번호
                          I010.IND_BCD,    		--개별 바코드
						  I010.SEQNO,			--순번
						  I001.ORDER_NO,		--오더번호
						  I010.WRK_ORDR_NO,		--작업지시번호
						  I010.WRK_ORDR_SEQNO,	--작업지시순번
                          I010.MATNR_M,    		--투입자재코드
                          M002.MATNR_NM    IN_MATNR_NM,    --투입자재명
                          I010.IND_BCD_M,   --투입개별 바코드
						  I010.LOT_NO_M,	--투입LOTNO
                          I010.USE_QTY,    --사용량
                          ''0'' AS USE_CHG_QTY,     --사용량보정
                          I010.UNIT,   		--단위
                          CASE WHEN I010.USE_DIV = ''1'' THEN ''정상'' WHEN  I010.USE_DIV = ''2'' THEN ''사용량 보정'' ELSE ''폐품''END USE_DIV_NM,   --자재사용량 보정
                          I010.REGDATE,     --등록일시
                          (SELECT NMLAST FROM USRMA WHERE USERID = I010.REGID) REGNM,   --등록자
                          I010.UPDDATE,     --수정일시
                          (SELECT NMLAST FROM USRMA WHERE USERID = I010.UPDID) UPDNM   --수정자
                     FROM TB_INV010 I010,  --자재투입이력
						  TB_INV001 I001,	--공정재고
                          TB_MAS012 M012,  --설비 마스터
                          TB_MAS001 M001,  --자재
                          TB_MAS001 M002   --자재
                    WHERE I010.MACH_CD = M012.MACH_CD(+)
                      AND I010.WERKS = M001.WERKS(+)
                      AND I010.MATNR = M001.MATNR(+)
                      AND I010.WERKS = M002.WERKS(+)
                      AND I010.MATNR_M = M002.MATNR(+)
					  AND I010.WERKS = I001.WERKS(+)
				 	  AND I010.IND_BCD = I001.IND_BCD(+)
                      AND NVL(I010.CNL_YN, ''N'') = ''N'' ';

        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN  --투입일자, 자재코드
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'PRFM_DT', 'I010.PRFM_DT');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MATNR', 'I010.MATNR_M');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MACH_CD', 'I010.MACH_CD');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'IND_BCD', 'I010.IND_BCD_M');
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;

        IF V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN     --플랜트
            V_SQL := V_SQL || ' AND I010.WERKS = ''' || V_WERKS || ''' ';
        END IF;

        V_SQL := V_SQL || ' ORDER BY I010.WERKS, I010.MACH_CD, I010.INP_DT, I010.REGDATE ';

--        SZP_MES_PLSQL_LOG(V_SQL, 'INV10 LIST V_SQL');

        OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SAVE' THEN      --저장(사용량보정)

        V_ARR_LIST              := V_JSON.get_array ('list');
        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
                V_OBJ					:= TREAT (V_ARR_LIST.get (i) AS json_object_t);
                V_OBJ					:= TREAT (V_OBJ.get ('map') AS json_object_t);

                V_WERKS     			:= V_OBJ.get_string('WERKS');    				--플랜트
                V_MACH_CD    			:= V_OBJ.get_string('MACH_CD');   				--설비코드
                V_MATNR      			:= V_OBJ.get_string('MATNR');      				--자재코드
                V_LOT_NO				:= V_OBJ.get_string('LOT_NO');					--LOT번호
                V_IND_BCD    			:= V_OBJ.get_string('IND_BCD');    				--개별 바코드
                V_SEQNO					:= V_OBJ.get_string('SEQNO');					--순번
                V_WRK_ORDR_NO			:= V_OBJ.get_string('WRK_ORDR_NO');				--작업지시번호
                V_WRK_ORDR_SEQNO		:= V_OBJ.get_string('WRK_ORDR_SEQNO');			--작업지시순번
                V_ORDER_NO              := V_OBJ.get_string('ORDER_NO');			    --작업지시순번
                V_PRFM_DT               := V_OBJ.get_string('PRFM_DT');			        --실적일자
                V_MATNR_M    			:= V_OBJ.get_string('MATNR_M');    				--투입자재코드
                V_IND_BCD_M   			:= V_OBJ.get_string('IND_BCD_M');   			--투입개별 바코드
                V_LOT_NO_M				:= V_OBJ.get_string('LOT_NO_M');				--투입LOTNO
                V_USE_QTY    			:= V_OBJ.get_string('USE_QTY');    				--사용량
                V_CHG_QTY               := V_OBJ.get_string('USE_CHG_QTY');    			--사용량보정
                V_UNIT   				:= V_OBJ.get_string('UNIT');   					--단위

                BEGIN
                    SELECT NVL(I001.STCK_QTY, 0) + NVL(I003.STCK_QTY, 0), NVL(I001.STCK_QTY, 0), NVL(I003.STCK_QTY, 0)
                    INTO V_STCK_QTY_PRE, V_STCK_QTY_INV001, V_STCK_QTY_INV003
                    FROM TB_INV001 I001,
                         (SELECT WERKS, IND_BCD, NVL(SUM(STCK_QTY), 0) AS STCK_QTY
                          FROM TB_INV003
                          WHERE WERKS = V_WERKS
                            AND IND_BCD = V_IND_BCD_M
                          GROUP BY WERKS, IND_BCD
                         ) I003
                    WHERE I001.WERKS = I003.WERKS(+)
                      AND I001.IND_BCD = I003.IND_BCD(+)
                      AND I001.WERKS =  V_WERKS
                      AND I001.IND_BCD = V_IND_BCD_M;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_STCK_QTY_PRE := 0;
                END;

                --사용량 보정값
                V_USE_CHG_QTY := NVL(V_CHG_QTY, 0) - NVL(V_USE_QTY, 0);

                IF NVL(V_STCK_QTY_PRE, 0) - V_USE_CHG_QTY < 0 THEN
                    P_ERR_MSG := V_IND_BCD_M || ' 의 개별바코드의 재고수량 : ' || TO_CHAR(0 - (V_STCK_QTY_PRE - V_USE_CHG_QTY)) || ' ' || V_UNIT || ' 이 부족합니다.';
                    P_SUCCESS := 'N';
                    ROLLBACK;
                    RETURN;
                END IF;

                IF NVL(V_STCK_QTY_INV003, 0) - V_USE_CHG_QTY < 0 THEN
                    P_ERR_MSG := V_IND_BCD_M || ' 의 개별바코드의 재고수량 : ' || TO_CHAR(0 - (V_STCK_QTY_INV003 - V_USE_CHG_QTY)) || ' ' || V_UNIT || ' 이 부족합니다. 투입 후 보정 진행 해 주세요';
                    P_SUCCESS := 'N';
                    ROLLBACK;
                    RETURN;
                END IF;

                BEGIN
                    SELECT MAX(SEQNO) INTO V_SEQNO
                    FROM TB_INV010
                    WHERE WERKS = V_WERKS
                      AND IND_BCD = V_IND_BCD;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_SEQNO := 0;
                END;

                V_SEQNO := V_SEQNO + 1;

                INSERT INTO TB_INV010(WERKS, MACH_CD, MATNR, IND_BCD, SEQNO,
                                      WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO,
                                      IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, PRFM_DT,
                                      USE_QTY, UNIT, CHG_FLG, STCK_KY, LOT_NUM,
                                      REGDATE, REGID, USE_DIV)
                SELECT A.WERKS, A.MACH_CD, A.MATNR, A.IND_BCD, V_SEQNO,
                       A.WRK_ORDR_NO, A.WRK_ORDR_SEQNO, A.LOT_NO,
                       A.IND_BCD_M, A.LOT_NO_M, A.MATNR_M, A.INP_DT, A.PRFM_DT,
                       V_USE_CHG_QTY, A.UNIT, A.CHG_FLG, A.STCK_KY, A.LOT_NUM,
                       V_DATE, V_SESS_USER_ID, '2'
                FROM(
                        SELECT *
                        FROM TB_INV010
                        WHERE WERKS = V_WERKS
                          AND MACH_CD = V_MACH_CD
                          AND MATNR = V_MATNR
                          AND IND_BCD = V_IND_BCD
                          AND IND_BCD_M = V_IND_BCD_M
                          AND PRFM_DT = V_PRFM_DT
                        ORDER BY PRFM_DT DESC ) A
                WHERE ROWNUM = 1;


                UPDATE TB_INV003
                SET USE_QTY = USE_QTY + V_USE_CHG_QTY,
                    STCK_QTY = STCK_QTY - V_USE_CHG_QTY
                WHERE WERKS = V_WERKS
                  AND MACH_CD = V_MACH_CD
                  AND IND_BCD = V_IND_BCD_M;

                IF SQL%ROWCOUNT = 0 THEN
                    --                UPDATE TB_INV001
--                   SET STCK_QTY = NVL(STCK_QTY, 0) - V_USE_CHG_QTY
--                 WHERE WERKS = V_WERKS
--                   AND IND_BCD = V_IND_BCD_M;

                    UPDATE TB_INV003
                    SET SEQNO = SEQNO + 1
                    WHERE WERKS = V_WERKS
                      AND MACH_CD = V_MACH_CD
                      AND MATNR = V_MATNR_M;

                    INSERT INTO TB_INV003(WERKS, MACH_CD, MATNR, IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO
                                         , LOT_NO, INP_DT, IN_QTY, USE_QTY, STCK_QTY, UNIT, REGDATE, REGID)
                    VALUES(V_WERKS, V_MACH_CD, V_MATNR_M, V_IND_BCD_M, 1, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO
                          , V_LOT_NO_M, TO_CHAR(V_DATE, 'YYYYMMDD'), 0 - V_USE_CHG_QTY, 0, 0 - V_USE_CHG_QTY, V_UNIT, V_DATE, V_SESS_USER_ID);
                END IF;


            END LOOP;

    ELSIF P_TYPE = 'SAVE2' THEN     --엑셀업로드 저장

        /*
         * PDA_INV02에서 원부자재 투입이 완료되면 TB_INV003에 설비별 투입재고가 생성된다.
         * 엑셀의 투입자재 개별바코드가 해당 플랜트/설비에 투입되어 있지 않으면
         * TB_INV010 등 업무 테이블을 변경하기 전에 업로드 전체를 중단한다.
         */
        SELECT COUNT(*),
               SUBSTR(
                   LISTAGG(IND_BCD_M, ', ' ON OVERFLOW TRUNCATE '...' WITH COUNT)
                       WITHIN GROUP (ORDER BY IND_BCD_M),
                   1, 3000
               )
          INTO V_NOT_INPUT_CNT, V_NOT_INPUT_BCD
          FROM (
                SELECT DISTINCT T.IND_BCD_M
                  FROM TB_INV010_TEMP T
                 WHERE T.REGID = V_SESS_USER_ID
                   -- TB_INV003에 투입 행 자체가 없고
                   AND NOT EXISTS (
                        SELECT 1
                          FROM TB_INV003 I003
                         WHERE I003.WERKS = T.WERKS
                           AND I003.MACH_CD = T.MACH_CD
                           AND I003.IND_BCD = T.IND_BCD_M
                   )
                   /*
                    * 같은 플랜트/설비의 자재사용이력도 없으면 미투입으로 차단한다.
                    * (사용이력이 있는 바코드는 아래 '사용완료 바코드 차단'에서 별도 메시지로 차단)
                    */
                   AND NOT EXISTS (
                        SELECT 1
                          FROM TB_INV010 I010
                         WHERE I010.WERKS = T.WERKS
                           AND I010.MACH_CD = T.MACH_CD
                           AND I010.IND_BCD_M = T.IND_BCD_M
                           AND NVL(I010.CNL_YN, 'N') = 'N'
                   )
               );

        IF V_NOT_INPUT_CNT > 0 THEN
            P_SUCCESS := 'N';
            P_ERR_MSG := '원부자재 투입이 완료되지 않은 개별바코드가 있습니다.'
                         || CHR(10) || '미투입 바코드: ' || V_NOT_INPUT_BCD
                         || CHR(10) || 'PDA 원부자재 투입 후 다시 업로드해 주세요.';
            ROLLBACK;
            RETURN;
        END IF;

        /*
         * 사용완료 바코드 차단
         * 투입 후 전량 사용되어 TB_INV003 행이 DELETE되고, 같은 플랜트/설비에 자재사용이력만 남은
         * 투입자재 개별바코드는 더 사용할 재고가 없으므로 확인/취소 없이 업로드 전체를 중단한다.
         * 해당 바코드는 업로드 데이터 전체를 검토하여 한 번에 안내한다.
         */
        V_USED_UP_CNT := 0;
        V_USED_UP_MSG := NULL;
        FOR U IN (
                SELECT T.IND_BCD_M,
                       COUNT(*)          AS USED_CNT,
                       MAX(I010.PRFM_DT) AS LAST_PRFM_DT
                  FROM (SELECT DISTINCT WERKS, MACH_CD, IND_BCD_M
                          FROM TB_INV010_TEMP
                         WHERE REGID = V_SESS_USER_ID
                           AND IND_BCD_M IS NOT NULL) T,
                       TB_INV010 I010
                 WHERE I010.WERKS = T.WERKS
                   AND I010.MACH_CD = T.MACH_CD
                   AND I010.IND_BCD_M = T.IND_BCD_M
                   AND NVL(I010.CNL_YN, 'N') = 'N'
                   AND NOT EXISTS (
                        SELECT 1
                          FROM TB_INV003 I003
                         WHERE I003.WERKS = T.WERKS
                           AND I003.MACH_CD = T.MACH_CD
                           AND I003.IND_BCD = T.IND_BCD_M
                   )
                 GROUP BY T.IND_BCD_M
                 ORDER BY T.IND_BCD_M
        ) LOOP
            V_USED_UP_CNT := V_USED_UP_CNT + 1;
            -- 메시지 길이 한도(32767) 내에서 전체 바코드를 누적한다.
            IF NVL(LENGTH(V_USED_UP_MSG), 0) < 30000 THEN
                V_USED_UP_MSG := V_USED_UP_MSG || CHR(10)
                                 || V_USED_UP_CNT || '. ' || U.IND_BCD_M
                                 || ' (기존 사용 ' || U.USED_CNT || '건, 최근 실적일자: '
                                 || NVL(U.LAST_PRFM_DT, '-') || ')';
            END IF;
        END LOOP;

        IF V_USED_UP_CNT > 0 THEN
            P_SUCCESS := 'N';
            P_ERR_MSG := '투입재고가 모두 사용되어(사용완료) 더 이상 사용할 수 없는 투입자재 개별바코드가 있습니다. (총 '
                         || V_USED_UP_CNT || '개)'
                         || V_USED_UP_MSG
                         || CASE WHEN NVL(LENGTH(V_USED_UP_MSG), 0) >= 30000
                                 THEN CHR(10) || '... (이하 생략)' ELSE '' END
                         || CHR(10) || CHR(10) || '해당 바코드를 엑셀에서 제외한 후 다시 업로드해 주세요.';
            ROLLBACK;
            RETURN;
        END IF;

        /* 동일 바코드가 여러 행이면 사용량을 합산하여 실제 투입잔량과 비교한다. */
        SELECT COUNT(*),
               SUBSTR(
                   LISTAGG(
                       IND_BCD_M || '(투입잔량:' || TO_CHAR(INPUT_STCK_QTY)
                       || ', 엑셀사용량:' || TO_CHAR(EXCEL_USE_QTY) || ')',
                       ', ' ON OVERFLOW TRUNCATE '...' WITH COUNT
                   ) WITHIN GROUP (ORDER BY IND_BCD_M),
                   1, 3000
               )
          INTO V_SHORT_STCK_CNT, V_SHORT_STCK_BCD
          FROM (
                SELECT T.WERKS,
                       T.MACH_CD,
                       T.IND_BCD_M,
                       SUM(NVL(T.USE_QTY, 0)) AS EXCEL_USE_QTY,
                       (SELECT NVL(SUM(I003.STCK_QTY), 0)
                          FROM TB_INV003 I003
                         WHERE I003.WERKS = T.WERKS
                           AND I003.MACH_CD = T.MACH_CD
                           AND I003.IND_BCD = T.IND_BCD_M) AS INPUT_STCK_QTY
                  FROM TB_INV010_TEMP T
                 WHERE T.REGID = V_SESS_USER_ID
                 GROUP BY T.WERKS, T.MACH_CD, T.IND_BCD_M
               )
         WHERE INPUT_STCK_QTY < EXCEL_USE_QTY;

        IF V_SHORT_STCK_CNT > 0 THEN
            P_SUCCESS := 'N';
            P_ERR_MSG := '원부자재 투입잔량보다 엑셀 사용량이 큰 개별바코드가 있습니다.'
                         || CHR(10) || '재고 부족 바코드: ' || V_SHORT_STCK_BCD;
            ROLLBACK;
            RETURN;
        END IF;

        /*
         * 기존 자재사용이력에 등록된 투입자재 개별바코드는 SAVE3에서 사용자에게
         * 한 번에 안내하고 확인을 받으므로 SAVE2에서는 차단하지 않는다.
         */

--        OPEN PROD_CUR FOR
--            SELECT WERKS, IND_BCD_M, UNIT, SUM(USE_QTY)
--                INTO V_WERKS, V_IND_BCD_M, V_UNIT, V_USE_QTY
--              FROM TB_INV010_TEMP
--             WHERE REGID = V_SESS_USER_ID
--            GROUP BY WERKS, IND_BCD_M, UNIT;
--        LOOP
--        FETCH PROD_CUR INTO V_WERKS, V_IND_BCD_M, V_UNIT, V_USE_QTY ;
--        EXIT WHEN PROD_CUR %NOTFOUND;
--
--            BEGIN
--            SELECT NVL(I001.STCK_QTY, 0) INTO V_STCK_QTY1
--              FROM TB_INV001 I001
--              WHERE I001.WERKS =  V_WERKS
--                AND I001.IND_BCD = V_IND_BCD_M;
--            EXCEPTION
--                WHEN NO_DATA_FOUND THEN
--                    V_STCK_QTY1 := 0;
--            END;
--
--            BEGIN
--            SELECT NVL(I003.STCK_QTY, 0) INTO V_STCK_QTY2
--              FROM TB_INV003 I003
--              WHERE I003.WERKS =  V_WERKS
--                AND I003.IND_BCD = V_IND_BCD_M;
--            EXCEPTION
--                WHEN NO_DATA_FOUND THEN
--                    V_STCK_QTY2 := 0;
--            END;
--
--            V_STCK_QTY_PRE := NVL(V_STCK_QTY1, 0) + NVL(V_STCK_QTY2, 0);
--
--            IF NVL(V_STCK_QTY_PRE, 0) - NVL(V_USE_QTY, 0) < 0 THEN
--                P_ERR_MSG := V_IND_BCD_M || ' 의 개별바코드의 재고수량 : ' || TO_CHAR(0 - (V_STCK_QTY_PRE - V_USE_QTY)) || ' ' || V_UNIT || ' 이 부족합니다.';
--                P_SUCCESS := 'N';
--                ROLLBACK;
--                RETURN;
--            END IF;
--
--        END LOOP;
--
        OPEN PROD_CUR2 FOR
            SELECT ROWID, WERKS, IND_BCD, LOT_NO, MATNR, MACH_CD, IND_BCD_M, LOT_NO_M, USE_QTY, NVL(SEQNO, 0)
            FROM TB_INV010_TEMP
            WHERE REGID = V_SESS_USER_ID;
        LOOP
            FETCH PROD_CUR2 INTO V_TEMP_ROWID, V_WERKS, V_IND_BCD, V_LOT_NO, V_MATNR, V_MACH_CD, V_IND_BCD_M, V_LOT_NO_M, V_USE_QTY, V_SEQNO1;
            EXIT WHEN PROD_CUR2 %NOTFOUND;

            BEGIN
                SELECT MAX(SEQNO) INTO V_SEQNO
                FROM TB_INV010
                WHERE WERKS = V_WERKS
                  AND MACH_CD = V_MACH_CD
                  AND MATNR = V_MATNR
                  AND IND_BCD = V_IND_BCD;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_SEQNO := 0;
            END;

            IF NVL(V_SEQNO1, 0) > 0 THEN
                V_SEQNO := V_SEQNO1;
            ELSE
                V_SEQNO := NVL(V_SEQNO, 0) + 1;
            END IF;

            INSERT INTO TB_INV010 (
                                    WERKS, PRFM_DT, INP_DT, MACH_CD, MATNR, LOT_NO
                                  , IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO
                                  , MATNR_M, IND_BCD_M, LOT_NO_M, USE_QTY, UNIT, USE_DIV, REGDATE, REGID)
            SELECT tit.WERKS, tit.PRFM_DT, tit.INP_DT, tit.MACH_CD, tit.MATNR, tit.LOT_NO
                 , tit.IND_BCD, V_SEQNO --tit.SEQNO + 300
                 , tit.WRK_ORDR_NO, tit.WRK_ORDR_SEQNO
                 , tit.MATNR_M, tit.IND_BCD_M, tit.LOT_NO_M, tit.USE_QTY, tit.UNIT, '1', SYSDATE, V_SESS_USER_ID
            FROM TB_INV010_TEMP tit
            -- 엑셀 내 동일 바코드 행을 허용하므로 커서의 현재 행(ROWID)만 1건씩 등록한다.
            WHERE tit.ROWID = V_TEMP_ROWID;


            UPDATE TB_INV003
            SET USE_QTY = NVL(USE_QTY, 0) + V_USE_QTY,
                STCK_QTY = STCK_QTY - V_USE_QTY
            WHERE WERKS = V_WERKS
              AND MACH_CD = V_MACH_CD
              AND IND_BCD = V_IND_BCD_M
              AND NVL(STCK_QTY, 0) >= V_USE_QTY;

            IF SQL%ROWCOUNT = 0 THEN
                P_SUCCESS := 'N';
                P_ERR_MSG := V_IND_BCD_M
                             || ' 개별바코드의 원부자재 투입재고가 없거나 부족합니다.'
                             || CHR(10) || 'PDA 원부자재 투입 상태를 확인해 주세요.';
                ROLLBACK;
                RETURN;
            END IF;


        END LOOP;

        --    	INSERT INTO TB_INV010 (
--    			WERKS, PRFM_DT, INP_DT, MACH_CD, MATNR, LOT_NO
--			  , IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO
--			  , MATNR_M, IND_BCD_M, LOT_NO_M, USE_QTY, UNIT, USE_DIV, REGDATE, REGID)
--    	 SELECT tit.WERKS, tit.PRFM_DT, tit.INP_DT, tit.MACH_CD, tit.MATNR, tit.LOT_NO
--    	 	  , tit.IND_BCD, CASE WHEN (SELECT MAX(SEQNO)  FROM TB_INV010 WHERE WERKS = tit.WERKS AND IND_BCD = tit.IND_BCD) > 0
--                                   THEN (SELECT MAX(A.SEQNO) FROM TB_INV010 A WHERE A.WERKS = tit.WERKS AND A.IND_BCD = tit.IND_BCD)
--                                   ELSE 1 END + ROW_NUMBER() OVER(ORDER BY PRFM_DT)
--              , tit.WRK_ORDR_NO, tit.WRK_ORDR_SEQNO
--    	 	  , tit.MATNR_M, tit.IND_BCD_M, tit.LOT_NO_M, tit.USE_QTY, tit.UNIT, '1', SYSDATE, V_SESS_USER_ID
--    	   FROM TB_INV010_TEMP tit
--    	  WHERE tit. REGID = V_SESS_USER_ID;

        DELETE
        FROM TB_INV010_TEMP tit
        WHERE REGID = V_SESS_USER_ID;

    ELSIF P_TYPE = 'SAVE3' THEN     --엑셀업로드

        DELETE
        FROM TB_INV010_TEMP tit
        WHERE REGID = V_SESS_USER_ID;

        V_ARR_LIST        := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP

                V_OBJ					:= TREAT (V_ARR_LIST.get (i) AS json_object_t);
                V_OBJ					:= TREAT (V_OBJ.get ('map') AS json_object_t);

                V_WERKS     			:= V_OBJ.get_string('WERKS');    				--플랜트
                V_PRFM_DT     			:= V_OBJ.get_string('PRFM_DT');     			--실적일자
                V_INP_DT				:= V_OBJ.get_string('INP_DT');					--투입일자
                V_MACH_CD    			:= V_OBJ.get_string('MACH_CD');   				--설비코드
                V_MATNR      			:= V_OBJ.get_string('MATNR');      				--자재코드
                V_LOT_NO				:= V_OBJ.get_string('LOT_NO');					--LOT번호
                V_IND_BCD    			:= V_OBJ.get_string('IND_BCD');    				--개별 바코드
                V_SEQNO					:= NVL(REPLACE(V_OBJ.get_string('SEQNO'), ' ', '') ,0);					--순번
                V_WRK_ORDR_NO			:= V_OBJ.get_string('WRK_ORDR_NO');				--작업지시번호
                V_WRK_ORDR_SEQNO		:= TO_NUMBER(V_OBJ.get_string('WRK_ORDR_SEQNO'));			--작업지시순번
                V_MATNR_M    			:= V_OBJ.get_string('MATNR_M');    				--투입자재코드
                V_IND_BCD_M   			:= REPLACE(V_OBJ.get_string('IND_BCD_M'), CHR(39), '');   			--투입개별 바코드
                V_LOT_NO_M				:= REPLACE(V_OBJ.get_string('LOT_NO_M'), CHR(39), '');				--투입LOTNO
                V_USE_QTY    			:= TO_NUMBER(REPLACE(V_OBJ.get_string('USE_QTY'), ',', ''));    				--사용량
                V_UNIT   				:= V_OBJ.get_string('UNIT');   					--단위

                /*
                 * 투입일자/실적일자는 YYYYMMDD 8자리이며 실제 존재하는 날짜여야 한다.
                 * FX 형식을 사용하여 20269010, 20260230 같은 값을 허용하지 않는다.
                 */
                IF NOT REGEXP_LIKE(V_INP_DT, '^[0-9]{8}$') THEN
                    P_SUCCESS := 'N';
                    P_ERR_MSG := '투입일자 입력이 올바르지 않습니다. [개별바코드: '
                                 || V_IND_BCD_M || ', 입력값: ' || NVL(V_INP_DT, 'NULL') || ']';
                    ROLLBACK;
                    RETURN;
                END IF;

                BEGIN
                    V_CHECK_DATE := TO_DATE(V_INP_DT, 'FXYYYYMMDD');
                EXCEPTION
                    WHEN OTHERS THEN
                        P_SUCCESS := 'N';
                        P_ERR_MSG := '투입일자 입력이 올바르지 않습니다. [개별바코드: '
                                     || V_IND_BCD_M || ', 입력값: ' || V_INP_DT || ']';
                        ROLLBACK;
                        RETURN;
                END;

                IF NOT REGEXP_LIKE(V_PRFM_DT, '^[0-9]{8}$') THEN
                    P_SUCCESS := 'N';
                    P_ERR_MSG := '실적일자 입력이 올바르지 않습니다. [개별바코드: '
                                 || V_IND_BCD_M || ', 입력값: ' || NVL(V_PRFM_DT, 'NULL') || ']';
                    ROLLBACK;
                    RETURN;
                END IF;

                BEGIN
                    V_CHECK_DATE := TO_DATE(V_PRFM_DT, 'FXYYYYMMDD');
                EXCEPTION
                    WHEN OTHERS THEN
                        P_SUCCESS := 'N';
                        P_ERR_MSG := '실적일자 입력이 올바르지 않습니다. [개별바코드: '
                                     || V_IND_BCD_M || ', 입력값: ' || V_PRFM_DT || ']';
                        ROLLBACK;
                        RETURN;
                END;

                -- 올해가 아닌 날짜는 오류가 아니라 사용자 확인 대상으로 모은다.
                IF SUBSTR(V_INP_DT, 1, 4) <> TO_CHAR(SYSDATE, 'YYYY')
                   AND INSTR(',' || V_OTHER_YEAR_DATES || ',', ',' || V_INP_DT || ',') = 0 THEN
                    V_OTHER_YEAR_DATES := V_OTHER_YEAR_DATES
                                          || CASE WHEN V_OTHER_YEAR_DATES IS NULL THEN '' ELSE ', ' END
                                          || V_INP_DT;
                END IF;

                IF SUBSTR(V_PRFM_DT, 1, 4) <> TO_CHAR(SYSDATE, 'YYYY')
                   AND INSTR(',' || V_OTHER_YEAR_DATES || ',', ',' || V_PRFM_DT || ',') = 0 THEN
                    V_OTHER_YEAR_DATES := V_OTHER_YEAR_DATES
                                          || CASE WHEN V_OTHER_YEAR_DATES IS NULL THEN '' ELSE ', ' END
                                          || V_PRFM_DT;
                END IF;

                IF V_OBJ.get_string('GRowState') = 'C' THEN
                    INSERT INTO TB_INV010_TEMP (WERKS, PRFM_DT, INP_DT, MACH_CD, MATNR, LOT_NO
                                               , IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO
                                               ,	MATNR_M, IND_BCD_M, LOT_NO_M, USE_QTY, UNIT, REGDATE, REGID)
                    VALUES (V_WERKS, V_PRFM_DT, V_INP_DT, V_MACH_CD, V_MATNR, V_LOT_NO
                           , V_IND_BCD, V_SEQNO, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO
                           , V_MATNR_M, V_IND_BCD_M, V_LOT_NO_M, V_USE_QTY, V_UNIT, SYSDATE, V_SESS_USER_ID
                           );
                END IF;
            END LOOP;

        /*
         * TB_INV001(공정재고) 기준 투입자재 개별바코드 LOT번호 / 단위 검증
         *  - WMS 불출 시 TB_INV001에 개별바코드별 LOT번호/단위가 등록되므로 이를 기준값으로 사용한다.
         *  - 아래 1~3은 업로드 데이터 전체를 검토한 뒤 한 번에 안내하고 확인/취소 없이 업로드를 중단한다.
         *    1) TB_INV001에 없는 개별바코드
         *    2) 엑셀 LOT번호가 TB_INV001 LOT번호와 다른 경우 (올바른 LOT번호 안내)
         *    3) 엑셀 단위가 TB_INV001 단위와 다른 경우 (올바른 단위 안내)
         *  - 엑셀/TB_INV001 단위가 모두 빈칸이면 오류가 아니라 사용자 확인 대상으로 모은다.
         *  - 공백은 TRIM 후 비교하며, 빈칸은 메시지에 '(빈칸)'으로 표시한다.
         */
        V_NO_BCD_CNT := 0;      V_NO_BCD_MSG := NULL;
        V_LOT_ERR_CNT := 0;     V_LOT_ERR_MSG := NULL;
        V_UNIT_ERR_CNT := 0;    V_UNIT_ERR_MSG := NULL;
        V_BLANK_UNIT_CNT := 0;  V_BLANK_UNIT_MSG := NULL;

        FOR T IN (
                SELECT DISTINCT
                       WERKS,
                       TRIM(IND_BCD_M)          AS IND_BCD_M,
                       NVL(TRIM(LOT_NO_M), ' ') AS LOT_NO_M,
                       NVL(TRIM(UNIT), ' ')     AS UNIT
                  FROM TB_INV010_TEMP
                 WHERE REGID = V_SESS_USER_ID
                   AND TRIM(IND_BCD_M) IS NOT NULL
                 ORDER BY 2, 3, 4
        ) LOOP
            SELECT COUNT(*)
              INTO V_I001_CNT
              FROM TB_INV001 I001
             WHERE I001.WERKS = T.WERKS
               AND I001.IND_BCD = T.IND_BCD_M;

            IF V_I001_CNT = 0 THEN
                /* 1) TB_INV001에 없는 개별바코드 (같은 바코드는 1번만 표시) */
                IF INSTR(V_NO_BCD_MSG || CHR(10), '. ' || T.IND_BCD_M || CHR(10)) = 0 THEN
                    V_NO_BCD_CNT := V_NO_BCD_CNT + 1;
                    IF NVL(LENGTH(V_NO_BCD_MSG), 0) < 9000 THEN
                        V_NO_BCD_MSG := V_NO_BCD_MSG || CHR(10) || V_NO_BCD_CNT || '. ' || T.IND_BCD_M;
                    END IF;
                END IF;
            ELSE
                /* TB_INV001의 올바른 LOT번호 (여러 행이면 모두 표시) */
                SELECT COUNT(CASE WHEN LOT_NO = T.LOT_NO_M THEN 1 END),
                       SUBSTR(LISTAGG(CASE WHEN LOT_NO = ' ' THEN '(빈칸)' ELSE LOT_NO END, ', ')
                                  WITHIN GROUP (ORDER BY LOT_NO), 1, 4000)
                  INTO V_LOT_OK_CNT, V_I001_LOTS
                  FROM (SELECT DISTINCT NVL(TRIM(I001.LOT_NO), ' ') AS LOT_NO
                          FROM TB_INV001 I001
                         WHERE I001.WERKS = T.WERKS
                           AND I001.IND_BCD = T.IND_BCD_M);

                /* 2) LOT번호 오류 */
                IF V_LOT_OK_CNT = 0 THEN
                    V_LOT_ERR_CNT := V_LOT_ERR_CNT + 1;
                    IF NVL(LENGTH(V_LOT_ERR_MSG), 0) < 9000 THEN
                        V_LOT_ERR_MSG := V_LOT_ERR_MSG || CHR(10)
                                         || V_LOT_ERR_CNT || '. 개별바코드 ' || T.IND_BCD_M
                                         || ' : 올바른 LOT번호는 [' || V_I001_LOTS || '] 인데 Excel에는 ['
                                         || CASE WHEN T.LOT_NO_M = ' ' THEN '(빈칸)' ELSE T.LOT_NO_M END
                                         || '] 로 입력하셨습니다.';
                    END IF;
                END IF;

                /*
                 * 단위 비교 기준 : LOT번호가 일치하는 TB_INV001 행
                 * (LOT번호가 틀린 경우에도 단위 오류를 함께 안내하기 위해 바코드의 전체 행과 비교)
                 */
                SELECT COUNT(CASE WHEN UNIT = T.UNIT THEN 1 END),
                       SUBSTR(LISTAGG(CASE WHEN UNIT = ' ' THEN '(빈칸)' ELSE UNIT END, ', ')
                                  WITHIN GROUP (ORDER BY UNIT), 1, 4000)
                  INTO V_UNIT_OK_CNT, V_I001_UNITS
                  FROM (SELECT DISTINCT NVL(TRIM(I001.UNIT), ' ') AS UNIT
                          FROM TB_INV001 I001
                         WHERE I001.WERKS = T.WERKS
                           AND I001.IND_BCD = T.IND_BCD_M
                           AND (V_LOT_OK_CNT = 0 OR NVL(TRIM(I001.LOT_NO), ' ') = T.LOT_NO_M));

                V_SHOW_LOT := CASE WHEN V_LOT_OK_CNT > 0
                                   THEN CASE WHEN T.LOT_NO_M = ' ' THEN '(빈칸)' ELSE T.LOT_NO_M END
                                   ELSE V_I001_LOTS END;

                IF V_UNIT_OK_CNT = 0 THEN
                    /* 3) 단위 오류 */
                    V_UNIT_ERR_CNT := V_UNIT_ERR_CNT + 1;
                    IF NVL(LENGTH(V_UNIT_ERR_MSG), 0) < 9000 THEN
                        V_UNIT_ERR_MSG := V_UNIT_ERR_MSG || CHR(10)
                                          || V_UNIT_ERR_CNT || '. 개별바코드 ' || T.IND_BCD_M
                                          || ' 의 LOT번호 ' || V_SHOW_LOT
                                          || ' 는 단위가 [' || V_I001_UNITS || '] 인데 Excel에는 ['
                                          || CASE WHEN T.UNIT = ' ' THEN '(빈칸)' ELSE T.UNIT END
                                          || '] 로 입력하셨습니다.';
                    END IF;
                ELSIF T.UNIT = ' ' THEN
                    /* 엑셀/TB_INV001 모두 단위 빈칸 → 사용자 확인 대상 */
                    V_BLANK_UNIT_CNT := V_BLANK_UNIT_CNT + 1;
                    IF NVL(LENGTH(V_BLANK_UNIT_MSG), 0) < 9000 THEN
                        V_BLANK_UNIT_MSG := V_BLANK_UNIT_MSG || CHR(10)
                                            || V_BLANK_UNIT_CNT || '. 개별바코드 ' || T.IND_BCD_M
                                            || ' (LOT번호 ' || V_SHOW_LOT || ')';
                    END IF;
                END IF;
            END IF;
        END LOOP;

        IF V_NO_BCD_CNT > 0 OR V_LOT_ERR_CNT > 0 OR V_UNIT_ERR_CNT > 0 THEN
            V_BLOCK_MSG := NULL;

            IF V_NO_BCD_CNT > 0 THEN
                V_BLOCK_MSG := '■ 투입자재 개별바코드가 없습니다. (총 ' || V_NO_BCD_CNT || '개)'
                               || V_NO_BCD_MSG
                               || CASE WHEN NVL(LENGTH(V_NO_BCD_MSG), 0) >= 9000
                                       THEN CHR(10) || '... (이하 생략)' ELSE '' END;
            END IF;

            IF V_LOT_ERR_CNT > 0 THEN
                V_BLOCK_MSG := V_BLOCK_MSG
                               || CASE WHEN V_BLOCK_MSG IS NULL THEN '' ELSE CHR(10) || CHR(10) END
                               || '■ LOT번호가 잘못 입력되었습니다. (총 ' || V_LOT_ERR_CNT || '건)'
                               || V_LOT_ERR_MSG
                               || CASE WHEN NVL(LENGTH(V_LOT_ERR_MSG), 0) >= 9000
                                       THEN CHR(10) || '... (이하 생략)' ELSE '' END;
            END IF;

            IF V_UNIT_ERR_CNT > 0 THEN
                V_BLOCK_MSG := V_BLOCK_MSG
                               || CASE WHEN V_BLOCK_MSG IS NULL THEN '' ELSE CHR(10) || CHR(10) END
                               || '■ 단위가 잘못 입력되었습니다. (총 ' || V_UNIT_ERR_CNT || '건)'
                               || V_UNIT_ERR_MSG
                               || CASE WHEN NVL(LENGTH(V_UNIT_ERR_MSG), 0) >= 9000
                                       THEN CHR(10) || '... (이하 생략)' ELSE '' END;
            END IF;

            P_SUCCESS := 'N';
            P_ERR_MSG := V_BLOCK_MSG || CHR(10) || CHR(10) || '엑셀을 수정한 후 다시 업로드해 주세요.';
            ROLLBACK;
            RETURN;
        END IF;

        /*
         * 업로드 파일 내부의 투입자재 개별바코드 중복은 화면(INV10.jsp)에서
         * 중복 대상 전체를 안내하고 사용자 확인을 받으므로 차단하지 않는다.
         * (동일 바코드 사용량은 아래 투입잔량 검증에서 합산하여 비교한다.)
         */

        /* PDA_INV02 원부자재 투입 완료 및 투입잔량 검증 */
        SELECT COUNT(*),
               SUBSTR(
                   LISTAGG(IND_BCD_M, ', ' ON OVERFLOW TRUNCATE '...' WITH COUNT)
                       WITHIN GROUP (ORDER BY IND_BCD_M),
                   1, 3000
               )
          INTO V_NOT_INPUT_CNT, V_NOT_INPUT_BCD
          FROM (
                SELECT DISTINCT T.IND_BCD_M
                  FROM TB_INV010_TEMP T
                 WHERE T.REGID = V_SESS_USER_ID
                   -- TB_INV003에 투입 행 자체가 없고
                   AND NOT EXISTS (
                        SELECT 1
                          FROM TB_INV003 I003
                         WHERE I003.WERKS = T.WERKS
                           AND I003.MACH_CD = T.MACH_CD
                           AND I003.IND_BCD = T.IND_BCD_M
                   )
                   /*
                    * 같은 플랜트/설비의 자재사용이력도 없으면 미투입으로 차단한다.
                    * (사용이력이 있는 바코드는 아래 '사용완료 바코드 차단'에서 별도 메시지로 차단)
                    */
                   AND NOT EXISTS (
                        SELECT 1
                          FROM TB_INV010 I010
                         WHERE I010.WERKS = T.WERKS
                           AND I010.MACH_CD = T.MACH_CD
                           AND I010.IND_BCD_M = T.IND_BCD_M
                           AND NVL(I010.CNL_YN, 'N') = 'N'
                   )
               );

        IF V_NOT_INPUT_CNT > 0 THEN
            P_SUCCESS := 'N';
            P_ERR_MSG := '원부자재 투입이 완료되지 않은 개별바코드가 있습니다.'
                         || CHR(10) || '미투입 바코드: ' || V_NOT_INPUT_BCD
                         || CHR(10) || 'PDA 원부자재 투입 후 다시 업로드해 주세요.';
            ROLLBACK;
            RETURN;
        END IF;

        /*
         * 사용완료 바코드 차단
         * 투입 후 전량 사용되어 TB_INV003 행이 DELETE되고, 같은 플랜트/설비에 자재사용이력만 남은
         * 투입자재 개별바코드는 더 사용할 재고가 없으므로 확인/취소 없이 업로드 전체를 중단한다.
         * 해당 바코드는 업로드 데이터 전체를 검토하여 한 번에 안내한다.
         */
        V_USED_UP_CNT := 0;
        V_USED_UP_MSG := NULL;
        FOR U IN (
                SELECT T.IND_BCD_M,
                       COUNT(*)          AS USED_CNT,
                       MAX(I010.PRFM_DT) AS LAST_PRFM_DT
                  FROM (SELECT DISTINCT WERKS, MACH_CD, IND_BCD_M
                          FROM TB_INV010_TEMP
                         WHERE REGID = V_SESS_USER_ID
                           AND IND_BCD_M IS NOT NULL) T,
                       TB_INV010 I010
                 WHERE I010.WERKS = T.WERKS
                   AND I010.MACH_CD = T.MACH_CD
                   AND I010.IND_BCD_M = T.IND_BCD_M
                   AND NVL(I010.CNL_YN, 'N') = 'N'
                   AND NOT EXISTS (
                        SELECT 1
                          FROM TB_INV003 I003
                         WHERE I003.WERKS = T.WERKS
                           AND I003.MACH_CD = T.MACH_CD
                           AND I003.IND_BCD = T.IND_BCD_M
                   )
                 GROUP BY T.IND_BCD_M
                 ORDER BY T.IND_BCD_M
        ) LOOP
            V_USED_UP_CNT := V_USED_UP_CNT + 1;
            -- 메시지 길이 한도(32767) 내에서 전체 바코드를 누적한다.
            IF NVL(LENGTH(V_USED_UP_MSG), 0) < 30000 THEN
                V_USED_UP_MSG := V_USED_UP_MSG || CHR(10)
                                 || V_USED_UP_CNT || '. ' || U.IND_BCD_M
                                 || ' (기존 사용 ' || U.USED_CNT || '건, 최근 실적일자: '
                                 || NVL(U.LAST_PRFM_DT, '-') || ')';
            END IF;
        END LOOP;

        IF V_USED_UP_CNT > 0 THEN
            P_SUCCESS := 'N';
            P_ERR_MSG := '투입재고가 모두 사용되어(사용완료) 더 이상 사용할 수 없는 투입자재 개별바코드가 있습니다. (총 '
                         || V_USED_UP_CNT || '개)'
                         || V_USED_UP_MSG
                         || CASE WHEN NVL(LENGTH(V_USED_UP_MSG), 0) >= 30000
                                 THEN CHR(10) || '... (이하 생략)' ELSE '' END
                         || CHR(10) || CHR(10) || '해당 바코드를 엑셀에서 제외한 후 다시 업로드해 주세요.';
            ROLLBACK;
            RETURN;
        END IF;

        SELECT COUNT(*),
               SUBSTR(
                   LISTAGG(
                       IND_BCD_M || '(투입잔량:' || TO_CHAR(INPUT_STCK_QTY)
                       || ', 엑셀사용량:' || TO_CHAR(EXCEL_USE_QTY) || ')',
                       ', ' ON OVERFLOW TRUNCATE '...' WITH COUNT
                   ) WITHIN GROUP (ORDER BY IND_BCD_M),
                   1, 3000
               )
          INTO V_SHORT_STCK_CNT, V_SHORT_STCK_BCD
          FROM (
                SELECT T.WERKS,
                       T.MACH_CD,
                       T.IND_BCD_M,
                       SUM(NVL(T.USE_QTY, 0)) AS EXCEL_USE_QTY,
                       (SELECT NVL(SUM(I003.STCK_QTY), 0)
                          FROM TB_INV003 I003
                         WHERE I003.WERKS = T.WERKS
                           AND I003.MACH_CD = T.MACH_CD
                           AND I003.IND_BCD = T.IND_BCD_M) AS INPUT_STCK_QTY
                  FROM TB_INV010_TEMP T
                 WHERE T.REGID = V_SESS_USER_ID
                 GROUP BY T.WERKS, T.MACH_CD, T.IND_BCD_M
               )
         WHERE INPUT_STCK_QTY < EXCEL_USE_QTY;

        IF V_SHORT_STCK_CNT > 0 THEN
            P_SUCCESS := 'N';
            P_ERR_MSG := '원부자재 투입잔량보다 엑셀 사용량이 큰 개별바코드가 있습니다.'
                         || CHR(10) || '재고 부족 바코드: ' || V_SHORT_STCK_BCD;
            ROLLBACK;
            RETURN;
        END IF;

        /*
         * 기존 자재사용이력에 이미 등록된 투입자재 개별바코드는 차단하지 않고,
         * 업로드 데이터 전체를 검토하여 해당 바코드를 모두 모은 뒤 사용자에게 한 번에 안내한다.
         */
        V_DUP_CNT := 0;
        FOR R IN (
                SELECT T.IND_BCD_M,
                       COUNT(*)        AS USED_CNT,
                       MAX(I010.PRFM_DT) AS LAST_PRFM_DT
                  FROM (SELECT DISTINCT IND_BCD_M
                          FROM TB_INV010_TEMP
                         WHERE REGID = V_SESS_USER_ID
                           AND IND_BCD_M IS NOT NULL) T,
                       TB_INV010 I010
                 WHERE I010.IND_BCD_M = T.IND_BCD_M
                 GROUP BY T.IND_BCD_M
                 ORDER BY T.IND_BCD_M
        ) LOOP
            V_DUP_CNT := V_DUP_CNT + 1;
            -- 메시지 길이 한도(32767) 내에서 전체 바코드를 누적한다.
            IF NVL(LENGTH(V_USED_BCD_MSG), 0) < 30000 THEN
                V_USED_BCD_MSG := V_USED_BCD_MSG || CHR(10)
                                  || V_DUP_CNT || '. ' || R.IND_BCD_M
                                  || ' (기존 사용 ' || R.USED_CNT || '건, 최근 실적일자: '
                                  || NVL(R.LAST_PRFM_DT, '-') || ')';
            END IF;
        END LOOP;

        /*
         * 사용자 확인 대상(기존 사용이력 바코드, 현재 연도가 아닌 일자, 단위 빈칸)을 하나의 메시지로 묶어
         * 한 번만 확인 받는다. 확인 전에는 TEMP 적재도 롤백하며, 확인 후 동일 데이터를 다시 전송한다.
         */
        IF (V_DUP_CNT > 0 OR V_OTHER_YEAR_DATES IS NOT NULL OR V_BLANK_UNIT_CNT > 0)
           AND V_YEAR_CONFIRMED <> 'Y' THEN
            IF V_DUP_CNT > 0 THEN
                V_CONFIRM_MSG := '이미 자재사용이력에 등록된 투입자재 개별바코드가 있습니다. (총 '
                                 || V_DUP_CNT || '개)'
                                 || V_USED_BCD_MSG;
                IF NVL(LENGTH(V_USED_BCD_MSG), 0) >= 30000 THEN
                    V_CONFIRM_MSG := V_CONFIRM_MSG || CHR(10) || '... (이하 생략)';
                END IF;
            END IF;

            IF V_OTHER_YEAR_DATES IS NOT NULL THEN
                V_CONFIRM_MSG := V_CONFIRM_MSG
                                 || CASE WHEN V_CONFIRM_MSG IS NULL THEN '' ELSE CHR(10) || CHR(10) END
                                 || '현재 연도(' || TO_CHAR(SYSDATE, 'YYYY')
                                 || '년)가 아닌 투입/실적일자가 있습니다. ['
                                 || V_OTHER_YEAR_DATES || ']';
            END IF;

            -- 엑셀/TB_INV001 모두 단위가 빈칸인 투입자재 개별바코드
            IF V_BLANK_UNIT_CNT > 0 THEN
                V_CONFIRM_MSG := V_CONFIRM_MSG
                                 || CASE WHEN V_CONFIRM_MSG IS NULL THEN '' ELSE CHR(10) || CHR(10) END
                                 || '단위가 빈칸인 투입자재 개별바코드가 있습니다. (총 '
                                 || V_BLANK_UNIT_CNT || '건)'
                                 || V_BLANK_UNIT_MSG
                                 || CASE WHEN NVL(LENGTH(V_BLANK_UNIT_MSG), 0) >= 9000
                                         THEN CHR(10) || '... (이하 생략)' ELSE '' END
                                 || CHR(10) || '단위가 빈칸인데 진행하시겠습니까?';
            END IF;

            P_SUCCESS := 'C';
            P_ERR_MSG := V_CONFIRM_MSG || CHR(10) || CHR(10) || '그래도 진행하시겠습니까?';
            ROLLBACK;
            RETURN;
        END IF;
    ELSIF P_TYPE = 'SELECT' THEN	-- 부서코드 조회
        V_SQL := V_SQL || ' SELECT	NVL(DEPART, ''null'') AS DEPART FROM USRMA WHERE USERID = ''' || V_SESS_USER_ID || ''' ';

        OPEN P_RS_LIST FOR V_SQL;
    END IF;

    P_SUCCESS := 'Y';
    COMMIT;

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
        E_SQL_ERR_CD        := -20990;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
