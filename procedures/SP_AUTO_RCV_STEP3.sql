
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_AUTO_RCV_STEP3" 
(
    P_JSONSTR           IN CLOB
    ,P_WERKS		    IN VARCHAR2
    ,P_MATNR		    IN VARCHAR2
    ,P_IND_BCD		    IN VARCHAR2
    ,P_DOC_NO		    IN VARCHAR2
    ,P_DOC_SEQ		    IN VARCHAR2
    ,P_USERID		    IN VARCHAR2
    ,P_LOT_NO		    IN VARCHAR2
    ,P_MACH_CD		    IN VARCHAR2
    ,P_WRK_ORDR_NO		IN VARCHAR2
    ,P_WRK_ORDR_SEQNO	IN VARCHAR2
    ,P_DOC_NO_TRANS     OUT VARCHAR2 -- SAP 재고이전 문서코드
    ,P_DOC_NO_WMS       OUT VARCHAR2 -- WMS 입고 문서코드
    ,P_MOVE_FUNC        OUT VARCHAR2 -- 재고이전 FUNC
    ,Lang               IN VARCHAR2 DEFAULT 'KO'-- 재고이전 FUNC
    ,RS_CODE            OUT VARCHAR2
    ,RS_MSG             OUT VARCHAR2
    ,CUR_1              OUT SYS_REFCURSOR
    ,CUR_2              OUT SYS_REFCURSOR
)
/*==============================================================================
 *=============================================================================*/
AS
    --프로그램 ID
    V_PRG_NM                VARCHAR2(100)  := 'SP_AUTO_RCV_STEP3';     -- PROCEDURE NAME
    V_PLT_CD                VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID          VARCHAR2(20) := 'TEST'; -- := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER        EXCEPTION;
    E_SQL_ERR_CD            NUMBER(5) := 0;
    E_SQL_ERR_MSG           VARCHAR2(4000);

    --내부변수 관리
    V_DATE                  DATE := SYSDATE;
    V_DOC_NO                VARCHAR2(20); --불출요청 문서번호
    V_DOC_SEQ               VARCHAR2(6);
    V_STOR_LOC_FR           VARCHAR2(20); --MES 위치
    V_STOR_LOC_TO           VARCHAR2(20); --WMS위치
    V_ORDER_NO              VARCHAR2(20); --생산오더
    V_EMPLY_NO              VARCHAR(20); --작업자번호
    V_PRFM_DT               VARCHAR(10); --실적일자
    --커서용 변수
    V_PRFM_QTY              NUMBER(20,0);
    V_UNIT                  VARCHAR(10);
    V_COMP_YN_WMS           VARCHAR(100);
    V_LOTNUM                VARCHAR(100);
    V_STOKKY                VARCHAR(100);
    V_VGPOS                 VARCHAR(50);

    V_JSON                  JSON_OBJECT_T;
    V_ARR_LIST              JSON_ARRAY_T;
    V_OBJ                   JSON_OBJECT_T;
    V_JSONSTR				VARCHAR(1000);
    V_PARAM_LIST			VARCHAR2(4000);

    V_ERR_MSG				VARCHAR2(4000);			-- WMS DATA INSERT MSG
    V_ERR_CODE				VARCHAR2(10);			-- WMS DATA INSERT CODE
    V_IF_MES_KEY			VARCHAR(1000);			-- IF_MES_KEY

    V_BUDAT				    VARCHAR2(10);
    V_LIST				    VARCHAR2(4000);	-- 입고 변수
    V_IFRWM006_CNT		    VARCHAR2(5);	-- 완제품 출고정보 카운트

    V_IF_ID_MOVE        VARCHAR2(20); --자재이전
    V_SQL               VARCHAR2(4000);
BEGIN
    BEGIN
        SZP_MES_PLSQL_LOG('--------------진입---------------', 'SP_AUTO_RCV_STEP3');
--         V_STOR_LOC_FR := '3100';
        V_STOR_LOC_TO := '3000';

        SELECT I001.STOR_LOC_CD
                   , I001.ORDER_NO
                   , I001.PRFM_DT
                   , I001.UNIT
                   , W001.PRFM_QTY
                   , W001.COMP_YN
                INTO V_STOR_LOC_FR, V_ORDER_NO, V_PRFM_DT, V_UNIT, V_PRFM_QTY, V_COMP_YN_WMS
                FROM TB_INV001 I001
            INNER JOIN TB_WRK001 W001 ON I001.IND_BCD = W001.IND_BCD AND I001.MATNR = W001.MATNR
            WHERE 1=1
                AND I001.WERKS = P_WERKS
                AND I001.MATNR = P_MATNR
                AND I001.IND_BCD = P_IND_BCD
                AND ROWNUM = 1;

        -- WMS 입고 Table Insert Procedure Call
        SZP_MES_PLSQL_LOG('WMS 입고요청 문서번호 P_DOC_NO ' || P_DOC_NO, 'SP_AUTO_RCV_STEP3');
        SZP_MES_PLSQL_LOG('V_JSONSTR 값 확인 : ' || V_JSONSTR, 'SP_AUTO_RCV_STEP3');

        V_JSONSTR := REPLACE(P_JSONSTR, '^', '"');

        -- WMS 생산출고요청 Table Insert Procedure Call
        V_JSON := JSON_OBJECT_T.parse(V_JSONSTR);
        V_DOC_NO		:=	V_JSON.get_string('DOC_NO');
        V_DOC_SEQ		:=	V_JSON.get_string('DOC_SEQNO');
        V_PARAM_LIST := V_JSON.to_string();

        SZP_MES_PLSQL_LOG('DBLINK_WMSIF205 V_DOC_NO : ' || V_DOC_NO, 'SP_AUTO_RCV_STEP3');

--         IF MOD(SUBSTR(P_IND_BCD, -1), 2) = 0 THEN
--             RAISE E_EXCEPTION_USER;
--         end if;

        -- WMS 입고요청
        DBLINK_WMSIF205@KNRAWMSLINK (V_PARAM_LIST, V_ERR_CODE, V_ERR_MSG);

        IF V_ERR_CODE <> 'S'	THEN
            RS_CODE := 'E';
            RS_MSG := 'WMS 입고요청 실패 : ' || V_ERR_MSG;
            RAISE E_EXCEPTION_USER;
        ELSE
            --출고요청시 상태 변경
            UPDATE TB_INV001
            SET STCK_STA = '80' --요청
            WHERE 1=1
                AND WERKS = P_WERKS
                AND MATNR = P_MATNR
                AND IND_BCD = P_IND_BCD;

            SELECT 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000')))	INTO V_IF_MES_KEY FROM DUAL;

            -- 출고요청 테이블 상태 변경
            UPDATE	TB_IFSWM005
            SET   IF_STATUS = V_ERR_CODE
                , IF_ERR_MESS = V_ERR_MSG
                , IF_SET_DATE = SYSDATE
                , IF_MES_KEY = V_IF_MES_KEY
            WHERE IND_BCD = P_IND_BCD
                AND	IF_STATUS = 'N'
                AND DOC_NO = V_DOC_NO;

            -- 실적 테이블 업데이트
            UPDATE	TB_WRK001
            SET   CHK_PP_YN = 'Y'           --생산확인여부
                , CHK_PP_DATE = V_DATE      --생산확인일시
                , CHK_PP_ID = V_EMPLY_NO    --생산확인자
            WHERE WERKS = P_WERKS
                AND MACH_CD = P_MACH_CD
                AND IND_BCD = P_IND_BCD;

            -- WMS 입고
            SZP_MES_PLSQL_LOG('DBLINK_WMSIF103 P_DOC_NO : ' || P_DOC_NO, 'SP_AUTO_RCV_STEP3');
            SZP_MES_PLSQL_LOG('DBLINK_WMSIF103 V_DOC_NO : ' || V_DOC_NO, 'SP_AUTO_RCV_STEP3');
            --         DBLINK_WMSIF103@KNRAWMSLINK(V_COMP_YN_WMS, P_DOC_NO, V_ERR_CODE, V_ERR_MSG);
            DBLINK_WMSIF103@KNRAWMSLINK('C', V_DOC_NO, V_ERR_CODE, V_ERR_MSG, V_STOKKY, V_LOTNUM);

            P_DOC_NO_WMS := V_ERR_MSG;

            SZP_MES_PLSQL_LOG('DBLINK_WMSIF103 V_ERR_MSG : ' || V_ERR_MSG, 'SP_AUTO_RCV_STEP3');

            COMMIT;
            IF V_ERR_CODE <> 'S'	THEN
                RS_CODE := 'E';
                RS_MSG := 'WMS 입고 실패 : ' || V_ERR_MSG;
                RAISE E_EXCEPTION_USER;
            ELSE
                V_VGPOS := '000010';

                V_LIST:= '{''list'': [{''WERKS'': ''' || P_WERKS || ''''||
                         ', ''MATNR'' : ''' || P_MATNR || ''''||
                         ', ''LOT_NO'' : ''' || P_LOT_NO || ''''||
                         ', ''IND_BCD'' : ''' || P_IND_BCD || ''''||
                         ', ''UNIT'' : ''' || V_UNIT || ''''||
                         ', ''DOC_NO'' :  ''' || V_DOC_NO || ''''||
                         ', ''DOC_SEQNO'' :  ''' || V_DOC_SEQ || ''''||
                         ', ''VGBEL'' :  ''' || P_DOC_NO_WMS || ''''||  -- WMS 입고키
                         ', ''VGPOS'' :  ''' || V_VGPOS || ''''||       -- WMS
                         ', ''STOK_KY'' :  ''' || V_STOKKY || ''''||    -- WMS STOKKY
                         ', ''LOT_NUM'' :  ''' || V_LOTNUM || ''''||    -- WMS LOTNUM
                         ', ''DLFL'' :  ''' || 'C' || ''''||
                         ', ''QTY'' : ''' || V_PRFM_QTY || ''''||
                         ', ''STOR_LOC_FROM'' : ''' || V_STOR_LOC_FR || ''''||
                         ', ''STOR_LOC_TO'' : ''' || V_STOR_LOC_TO || '''}]}';
                /* 입고 로직 추가 */
                SP_DBLINK_IFRWM006(V_LIST, V_ERR_CODE, V_ERR_MSG);

                SZP_MES_PLSQL_LOG('입고로직 진입 V_ERR_CODE : ' || V_ERR_CODE, 'STEP3');
                SZP_MES_PLSQL_LOG('입고로직 진입 V_ERR_MSG : ' || V_ERR_MSG, 'STEP3');

                IF V_ERR_CODE <> 'S'	THEN
                    RS_CODE := 'E';
                    RS_MSG := 'TB_IFRWM006 INSERT 실패(입고로직) : ' || V_ERR_MSG;
                    RAISE E_EXCEPTION_USER;
                ELSE
                    --재고이전을 위한 데이터값 TB_IFS009 UPDATE
                    V_DOC_NO := FN_GET_MDOCNO('M','IF131');
                    V_IF_ID_MOVE := 'MES_IF_131';
                    V_DOC_SEQ := 1;
                    V_BUDAT := FN_RECDATE(V_DATE);
                    SZP_MES_PLSQL_LOG('재고이전 문서번호 : ' || V_DOC_NO, 'STEP3');

                    BEGIN
                        -- 재고이전 이력(저장위치 3100 --> 3000)
                        INSERT INTO TB_WRK017(DOC_NO, DOC_SEQNO, MOVE_DIV, WERKS_FR, WERKS_TO,
                            MATNR_FR, MATNR_TO, STOR_LOC_FR, STOR_LOC_TO, CHARG_FR, CHARG_TO, MOVE_QTY, UNIT,
                            AUFNR, WRK_ORDR_NO_FR, WRK_ORDR_SEQNO_FR, WRK_ORDR_NO_TO, WRK_ORDR_SEQNO_TO, UCFMTY_YN,
                            RMK, REGDATE, REGID, IND_BCD, BUDAT)
                        VALUES(V_DOC_NO, V_DOC_SEQ, '311', P_WERKS, P_WERKS,
                            P_MATNR, P_MATNR, V_STOR_LOC_FR, V_STOR_LOC_TO, P_LOT_NO, P_LOT_NO, V_PRFM_QTY, V_UNIT,
                            V_ORDER_NO, P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO, P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO, 'N',
                            '', V_DATE, P_USERID, P_IND_BCD, V_BUDAT);
                    EXCEPTION
                    WHEN OTHERS THEN
                        RS_CODE := 'E';
                        RS_MSG := 'TB_WRK017 INSERT 실패(재고이전 이력) : ' + SQLERRM;
                    END;


                    BEGIN
                        -- TB_IFS009 INSERT 시에 변경품목이나 장소이동값(3100->3000)
                        INSERT INTO TB_IFS009(BWART, WERKS_FROM, WERKS_TO, MATNR_FROM, MATNR_TO, LGORT_FROM, LGORT_TO,
                                            CHARG_FROM, CHARG_TO, AUFNR, MENGE, MEINS, FAULTY, MDOCNO, MDOCSEQ, ZRESULT,
                                            MAKE_DATE, MAKER, BUDAT)
                        VALUES ( '311', P_WERKS, P_WERKS, P_MATNR, P_MATNR, V_STOR_LOC_FR, V_STOR_LOC_TO
                                , P_LOT_NO, P_LOT_NO, V_ORDER_NO, V_PRFM_QTY, V_UNIT, '', V_DOC_NO, V_DOC_SEQ
                                , 'N', V_DATE, P_USERID, replace(V_BUDAT, '-', '') );
                    EXCEPTION
                    WHEN OTHERS THEN
                        RS_CODE := 'E';
                        RS_MSG := 'TB_IFS009 INSERT 실패(재고이전) : ' + SQLERRM;
                    END;

                    BEGIN
                        -- 문서이력
                        INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                            IND_BCD, LOT_NO, ORDER_NO, CNL_YN, REGDATE, REGID)
                        VALUES(V_DOC_NO, V_DOC_SEQ, '6', P_WERKS, P_MACH_CD, P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO,
                                P_IND_BCD, P_LOT_NO, V_ORDER_NO, 'N', V_DATE, P_USERID);
                    EXCEPTION
                    WHEN OTHERS THEN
                        RS_CODE := 'E';
                        RS_MSG := 'TB_WRK021 INSERT 실패(문서이력) : ' + SQLERRM;
                    END;

                    P_DOC_NO_TRANS := V_DOC_NO;
                    SZP_MES_PLSQL_LOG('RCV_STEP3 끝', 'SP_AUTO_RCV_STEP3');
                END IF;
            END IF;
        END IF;

        --SAP FUNC ID 130
        SELECT RFCFN
          INTO P_MOVE_FUNC
          FROM TB_ITFMA
         WHERE 1=1
           AND IFID = V_IF_ID_MOVE;

        --인터페이스 파라미터(재고이전)
--         OPEN CUR_1 FOR
--         SELECT V_IF_ID_MOVE AS I_IF_ID
--              , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
--              , V_PRFM_DT AS I_DATE
--           FROM dual;
--         --인터페이스 상세 파라미터
--         V_SQL := FN_IF_QUERY(V_IF_ID_MOVE, P_DOC_NO_TRANS);
--         IF V_SQL IS NOT NULL THEN
--         	OPEN CUR_2 FOR V_SQL;
--         END IF;

        RS_CODE := V_ERR_CODE;
        RS_MSG := V_ERR_MSG;

        SZP_MES_PLSQL_LOG('3 마지막 RS_CODE : ' || RS_CODE, 'STEP3 EXCEPTION');
        SZP_MES_PLSQL_LOG('3 마지막 RS_MSG : ' || RS_MSG, 'STEP3 EXCEPTION');

        --RFC 미사용 항목에 대하여 기본값 등록
        IF CUR_1%ISOPEN = FALSE THEN
            OPEN CUR_1 FOR SELECT 1 FROM dual;
        END IF;
        IF CUR_2%ISOPEN = FALSE THEN
            OPEN CUR_2 FOR SELECT 1 FROM dual;
        END IF;
SZP_MES_PLSQL_LOG('--------------끝---------------', 'SP_AUTO_RCV_STEP3');
    EXCEPTION
    when E_EXCEPTION_USER THEN
        SZP_MES_PLSQL_LOG('EXCEPTION E_EXCEPTION_USER 진입', 'SP_AUTO_RCV_STEP3');
		-- 에러 내역 SET
		E_SQL_ERR_CD        := SQLCODE;
		E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

		/* 추가적으로 TB_IFRWM006 추가된 row 체크하고
		    D로 INSERT
        */
        SELECT COUNT(*) INTO V_IFRWM006_CNT
        FROM TB_IFRWM006
        WHERE 1=1
            AND VGBEL = P_DOC_NO_WMS
            AND DLFL = 'C';

        IF V_IFRWM006_CNT > 0 THEN
            V_JSON      := JSON_OBJECT_T.parse(V_LIST);
            V_ARR_LIST  := V_JSON.get_array ('list');
            V_OBJ		:= TREAT (V_ARR_LIST.get (0) AS json_object_t);
            IF V_OBJ.get_string('DLFL') = 'C' THEN
                V_OBJ.put('DLFL', 'D');
            END IF;
            V_LIST := V_JSON.to_string(); --변경된 JSON을 다시 V_LIST에 반영

            SP_DBLINK_IFRWM006(V_LIST, V_ERR_CODE, V_ERR_MSG);

            SZP_MES_PLSQL_LOG('3 V_ERR_CODE : ' || V_ERR_CODE, 'STEP3 EXCEPTION');
            SZP_MES_PLSQL_LOG('3 V_ERR_MSG : ' || V_ERR_MSG, 'STEP3 EXCEPTION');
        END IF;

-- 		ROLLBACK;
		SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

		RETURN;
	WHEN OTHERS THEN
	    SZP_MES_PLSQL_LOG('EXCEPTION OTHERS 진입', 'SP_AUTO_RCV_STEP3');
		E_SQL_ERR_CD        := SQLCODE;
		E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

-- 		ROLLBACK;
		RAISE_APPLICATION_ERROR(-20001, E_SQL_ERR_MSG);

    --예외처리 종료
    END;
END;
/
