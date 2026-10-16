
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
 *==============================================================================
 *  관련 테이블
 *      - [TB_INV010] : (.R..) 자재투입이력
 *      - [TB_MAS012] : (.R..) 설비 마스터
 *      - [TB_MAS001] : (.R..) 자재
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
    V_YEAR_CONFIRMED       VARCHAR2(1) := 'N';   -- 사용자 확인 여부(다른 연도 일자 + 기존 사용이력 바코드)
    V_OTHER_YEAR_DATES     VARCHAR2(3000);
    V_CHECK_DATE           DATE;
    V_USED_BCD_MSG         VARCHAR2(32767);       -- 기존 자재사용이력 등록 바코드 전체 목록
    V_CONFIRM_MSG          VARCHAR2(32767);       -- 사용자 확인 메시지

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
                   AND NOT EXISTS (
                        SELECT 1
                          FROM TB_INV003 I003
                         WHERE I003.WERKS = T.WERKS
                           AND I003.MACH_CD = T.MACH_CD
                           AND I003.IND_BCD = T.IND_BCD_M
                           AND NVL(I003.STCK_QTY, 0) > 0
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
                   AND NOT EXISTS (
                        SELECT 1
                          FROM TB_INV003 I003
                         WHERE I003.WERKS = T.WERKS
                           AND I003.MACH_CD = T.MACH_CD
                           AND I003.IND_BCD = T.IND_BCD_M
                           AND NVL(I003.STCK_QTY, 0) > 0
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
         * 사용자 확인 대상(기존 사용이력 바코드, 현재 연도가 아닌 일자)을 하나의 메시지로 묶어
         * 한 번만 확인 받는다. 확인 전에는 TEMP 적재도 롤백하며, 확인 후 동일 데이터를 다시 전송한다.
         */
        IF (V_DUP_CNT > 0 OR V_OTHER_YEAR_DATES IS NOT NULL) AND V_YEAR_CONFIRMED <> 'Y' THEN
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
