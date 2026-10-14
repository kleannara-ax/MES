
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK32_LOT_MERGE" 
(
    P_WERKS         IN VARCHAR2             -- 플랜트 코드
,P_MACH_CD      IN VARCHAR2             -- 작업장코드(설비코드)
,P_MERGE_LIST   IN CLOB
,P_USERID       IN VARCHAR2
,P_MERGE_FUNC   OUT VARCHAR2            -- merge RFCFN ID값
,Lang           IN VARCHAR2 DEFAULT 'KO'
,RS_CODE        OUT VARCHAR2
,RS_MSG         OUT VARCHAR2
,CUR_1          OUT SYS_REFCURSOR
,CUR_2          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK32_LOT_MERGE
 * PROGRAM NAME  : 생산실적 이력 조회 (LOT병합)
 * VERSION       : 1.0.1
 * DESCRIPTION   : 생산실적 이력 조회 (LOT병합)
 *
 * AUTHOR NAME   : 김병무
 * CREATE DATE   : 2026/05/08
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description
 * ------------ ------- ------------- ------------------------------------------
 * 2026/05/08    1.0.0   김지언         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK002] : (.R..) PS 생산실적 이력
 *=============================================================================*/
AS
    --프로그램 ID
    V_PRG_NM                    VARCHAR2(100)   := 'SP_POP_WRK32_LOT_MERGE';     -- PROCEDURE NAME
    V_SESS_USER_ID              varchar2(20)    := P_USERID; --USERID

    -- JSON을 위한 변수선언 영역
    V_JSON                      JSON_OBJECT_T;
    V_ARR_LIST                  JSON_ARRAY_T;
    V_OBJ                       JSON_OBJECT_T;

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER            EXCEPTION;
    E_SQL_ERR_CD                NUMBER(5) := 0;
    E_SQL_ERR_MSG               VARCHAR2(4000);

    --내부변수 관리
    V_BASE_FLAG                  VARCHAR2(2);
    V_LOT_NO                     TB_INV001.LOT_NO%TYPE;
    V_IND_BCD                    TB_INV001.IND_BCD%TYPE;
    V_MATNR                      TB_INV001.MATNR%type;
    V_STCK_QTY                   TB_INV001.STCK_QTY%type;

    V_BASE_IND_BCD               TB_INV001.IND_BCD%TYPE;
    V_BASE_LOT_NO                TB_INV001.LOT_NO%TYPE;
    V_BASE_WERKS                 TB_INV001.WERKS%TYPE;
    V_BASE_STOR_LOC_CD           TB_INV001.STOR_LOC_CD%TYPE;
    V_BASE_LOC_CD                TB_INV001.LOC_CD%type;
    V_BASE_ORDER_NO              TB_INV001.ORDER_NO%type;
    V_BASE_UNIT                  TB_INV001.UNIT%TYPE;
    V_BASE_VBELN                 TB_INV001.VBELN%TYPE;
    V_BASE_POSNR                 TB_INV001.POSNR%type;
    V_BASE_DOC_NO                TB_INV001.DOC_NO%type;
    V_BASE_DOC_SEQNO             TB_INV001.DOC_SEQNO%type;

    V_ORDER_NO                   TB_INV001.ORDER_NO%type;
    V_VBELN                      TB_INV001.VBELN%TYPE;
    V_POSNR                      TB_INV001.POSNR%type;
    V_DOC_NO                     TB_INV001.DOC_NO%type;
    V_DOC_SEQNO                  TB_INV001.DOC_SEQNO%type;
    V_DATE                       VARCHAR2(8) := TO_CHAR(SYSDATE,'YYYYMMDD');

    V_TOTAL_STCK_QTY             NUMBER := 0;   -- 병합될 총 수량 합산용
    V_SINGLE_STCK_QTY             NUMBER := 0;   -- 병합될 총 수량 합산용
    V_TARGET_STCK_QTY            NUMBER := 0;   -- 각 바코드별 숫자 변환 수량

    V_TRANS_DOC_NO               TB_WRK002.DOC_NO%TYPE;		 --DOC No (재고이동)
    V_TRANS_DOC_SEQ              TB_WRK002.DOC_SEQNO%TYPE := 0;	 --DOC SEQ (재고이동)
    V_SQL                        VARCHAR2(4000);
    V_IF_KEY                     VARCHAR2(100);
BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            V_JSON := JSON_OBJECT_T.parse(P_MERGE_LIST);
        EXCEPTION
            WHEN OTHERS THEN
                RS_CODE := 'E';
                RS_MSG := 'JSON 파싱 오류';
                RAISE E_EXCEPTION_USER;
        END;

        V_ARR_LIST := V_JSON.get_array('list');

        V_TRANS_DOC_NO := FN_GET_MDOCNO('M', 'IF131');

        -- INV001 에 UPDATE 했다는 기준으로
        -- INV003 삭제 , INV001 기준으로 다 합치고 STA 00, 2000번창고
        -- IFS009 에 INSERT
        -- WRK021 에 넣기
        -- INV001 에 BASE LOT_NO 총수량 UPDATE
        -- BASE 이외 LOT_NO 수량 0 으로 UPDATE

        V_BASE_IND_BCD   := NULL;
        V_BASE_LOT_NO    := NULL;
        V_TOTAL_STCK_QTY := 0;

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
                V_OBJ := TREAT (V_ARR_LIST.get (i) AS json_object_t);
                V_OBJ := TREAT (V_OBJ.get ('map') AS json_object_t);

                -- BASE_FLAG가 'Y'인 딱 1건을 찾으면 기준 변수에 담고 첫 번째 루프 탈출
                IF V_OBJ.get_string('BASE_FLAG') = 'Y' THEN
                    V_BASE_IND_BCD   := V_OBJ.get_string('IND_BCD');
                    V_BASE_LOT_NO    := V_OBJ.get_string('LOT_NO');
                    V_MATNR          := V_OBJ.get_string('MATNR'); -- 자재코드는 다 같을 테니 여기서 확보

                    BEGIN
                        SELECT I001.STOR_LOC_CD
                             , I001.LOC_CD
                             , I001.ORDER_NO
                             , I001.UNIT
                             , W002.VBELN
                             , W002.POSNR
                             , I001.DOC_NO
                             , I001.DOC_SEQNO
                        INTO V_BASE_STOR_LOC_CD, V_BASE_LOC_CD, V_BASE_ORDER_NO, V_BASE_UNIT
                            , V_BASE_VBELN, V_BASE_POSNR, V_BASE_DOC_NO, V_BASE_DOC_SEQNO
                        FROM TB_INV001 I001
                                 left outer join tb_wrk002 W002 on W002.WERKS = I001.WERKS and W002.IND_BCD = I001.IND_BCD
                        WHERE 1=1
                          AND I001.LOT_NO = V_BASE_LOT_NO
                          AND I001.IND_BCD = V_BASE_IND_BCD
                          AND I001.MATNR = V_MATNR;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            RS_CODE := 'E';
                            RS_MSG := '기준 LOT 재고정보가 존재하지 않습니다.';
                            RAISE E_EXCEPTION_USER;

                        WHEN TOO_MANY_ROWS THEN
                            RS_CODE := 'E';
                            RS_MSG := '기준 LOT 재고정보가 중복되었습니다.';
                            RAISE E_EXCEPTION_USER;
                    END;

                    EXIT; -- 찾았으니 이 루프는 끝냅니다.
                END IF;
            END LOOP;

        IF V_BASE_LOT_NO IS NULL OR V_BASE_IND_BCD IS NULL THEN
            RS_CODE := 'E';
            RS_MSG  := '병합 기준(BASE_FLAG=Y) LOT 정보가 존재하지 않습니다.';
            RAISE E_EXCEPTION_USER;
        END IF;

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
                V_OBJ := TREAT (V_ARR_LIST.get (i) AS json_object_t);
                V_OBJ := TREAT (V_OBJ.get ('map') AS json_object_t);

                V_BASE_FLAG             := V_OBJ.get_string('BASE_FLAG');
                V_LOT_NO                := V_OBJ.get_string('LOT_NO');
                V_IND_BCD               := V_OBJ.get_string('IND_BCD');
                V_MATNR                 := V_OBJ.get_string('MATNR');
                V_STCK_QTY              := V_OBJ.get_string('STCK_QTY');

                BEGIN
                    V_TARGET_STCK_QTY := TO_NUMBER(NVL(V_STCK_QTY, '0'));
                EXCEPTION
                    WHEN VALUE_ERROR THEN
                        RS_CODE := 'E';
                        RS_MSG := '수량(STCK_QTY) 데이터가 숫자가 아닙니다.';
                        RAISE E_EXCEPTION_USER;
                END;

                -- 전체 수량은 Base 여부 상관없이 무조건 누적 합산
                V_TOTAL_STCK_QTY  := V_TOTAL_STCK_QTY + (V_TARGET_STCK_QTY * 500);
                V_SINGLE_STCK_QTY := V_TARGET_STCK_QTY * 500;

                DBMS_OUTPUT.PUT_LINE('V_BASE_FLAG = ' || V_BASE_FLAG || ' | V_LOT_NO = ' || V_LOT_NO);

                -- Base가 아닌 쩌리(?) 바코드들만 양도 처리를 진행합니다.
                IF V_BASE_FLAG <> 'Y' THEN
                    V_TRANS_DOC_SEQ := V_TRANS_DOC_SEQ + 1;
                    BEGIN
                        SELECT I001.ORDER_NO,
                               I001.DOC_NO,
                               I001.DOC_SEQNO,
                               W002.VBELN,
                               W002.POSNR
                        INTO V_ORDER_NO, V_DOC_NO, V_DOC_SEQNO, V_VBELN, V_POSNR
                        FROM TB_INV001 I001
                                 left outer join tb_wrk002 W002 on W002.WERKS = I001.WERKS and W002.IND_BCD = I001.IND_BCD
                        WHERE 1=1
                          AND I001.LOT_NO = V_LOT_NO
                          AND I001.IND_BCD = V_IND_BCD
                          AND I001.MATNR = V_MATNR;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            RS_CODE := 'E';
                            RS_MSG := '기준 LOT 재고정보가 존재하지 않습니다.';
                            RAISE E_EXCEPTION_USER;

                        WHEN TOO_MANY_ROWS THEN
                            RS_CODE := 'E';
                            RS_MSG := '기준 LOT 재고정보가 중복되었습니다.';
                            RAISE E_EXCEPTION_USER;
                    END;

                    --                 IF V_BASE_VBELN <> V_VBELN THEN
--                     RS_CODE := 'E';
--                     RS_MSG := '병합하려는 판매오더가 서로 다릅니다. 확인해주세요.';
--                     RAISE E_EXCEPTION_USER;
--                 end if;

                    -- 1) MES 기존 재고 테이블에서 수량 0으로 밀기 (차감)
                    UPDATE TB_INV001 SET STCK_QTY = 0, RMK = 'LOT병합으로재고처리' WHERE IND_BCD = V_IND_BCD;
                    --                 UPDATE TB_INV003 SET USE_QTY = IN_QTY, STCK_QTY = 0, RMK = 'LOT병합으로재고처리' WHERE IND_BCD = V_IND_BCD;
                    -- 개발테스트해서 UPDATE 정상적으로 되면 DELETE로 변경
                    DELETE FROM TB_INV003 WHERE 1=1 AND IND_BCD = V_IND_BCD;

                    BEGIN
                        -- lot merge
                        INSERT INTO TB_WRK017(DOC_NO, DOC_SEQNO, MOVE_DIV, WERKS_FR, WERKS_TO,
                                              MATNR_FR, MATNR_TO, STOR_LOC_FR, STOR_LOC_TO, CHARG_FR, CHARG_TO, MOVE_QTY, UNIT,
                                              AUFNR, UCFMTY_YN, RMK, REGDATE, REGID, IND_BCD, BUDAT)
                        VALUES(V_TRANS_DOC_NO, V_TRANS_DOC_SEQ, '413', P_WERKS, P_WERKS,
                               V_MATNR, V_MATNR, V_BASE_STOR_LOC_CD, V_BASE_STOR_LOC_CD
                              , V_LOT_NO, V_BASE_LOT_NO , V_SINGLE_STCK_QTY, V_BASE_UNIT
                              , V_BASE_ORDER_NO,'N', 'LOT병합', sysdate, P_USERID
                              , V_BASE_IND_BCD, V_DATE);
                    EXCEPTION
                        WHEN OTHERS THEN
                            RS_CODE := 'E';
                            RS_MSG := 'TB_WRK017 INSERT 실패(재고이전 이력) : ' || SQLERRM;
                    END;
                    /* RFC 필수값
                    플랜트 FROM        => WERKS_FROM
                    자재번호 FROM       => MATNR_FROM
                    자재번호 TO         => MATNR_TO
                    저장위치 FROM       => LGORT_FROM
                    저장위치  TO        => LGORT_TO
                    배치번호 FROM       => CHARG_FROM
                    배치번호 TO         => CHARG_TO
                    수량               => MENGE
                    단위               => MEINS
                    구분값 'Y'         => LTCHG
                    판매문서번호 FROM   => VBELN_FROM
                    품목번호      FROM  => POSNR_FROM
                    판매문서번호  TO     => VBELN_TO
                    품목번호  TO        => POSNR_TO
                   */

                    -- 2) SAP 이전을 위한 I/F 테이블(IFS009) Insert
                    INSERT INTO TB_IFS009 (
                                            BWART, WERKS_TO, WERKS_FROM, MATNR_FROM, MATNR_TO, LGORT_FROM, LGORT_TO
                                          , CHARG_FROM, CHARG_TO, MENGE, MEINS, LTCHG, AUFNR
                                          , VBELN_FROM, VBELN_TO, POSNR_FROM, POSNR_TO
                                          , ZRESULT, MAKE_DATE, MAKER, MDOCNO, MDOCSEQ, BUDAT
                    ) VALUES (
                               '413'
                             , P_WERKS
                             , P_WERKS
                             , V_MATNR
                             , V_MATNR
                             , V_BASE_STOR_LOC_CD
                             , V_BASE_STOR_LOC_CD
                             , V_LOT_NO
                             , V_BASE_LOT_NO
                             , V_SINGLE_STCK_QTY
                             , V_BASE_UNIT
                             , 'Y'
                             , V_BASE_ORDER_NO
                             , LPAD(TO_CHAR(V_VBELN), 10, '0')
                             , LPAD(TO_CHAR(V_BASE_VBELN), 10, '0')
                             , V_POSNR
                             , V_BASE_POSNR
                             , 'N'
                             , SYSDATE
                             , V_SESS_USER_ID
                             , V_TRANS_DOC_NO
                             , V_TRANS_DOC_SEQ
                             , V_DATE
                             );

                    -- 1=실적, 2=생산폐품, 3=영업폐품, 4=잔량폐품, 5=투입자재 소요량, 6=재고이전(위치), 7=재고이전(자재변경), 8=재고이전(재고실사)
                    -- 9=LOT변경, 10=등급변경, 11=LOT병합, 12=LIFT출고, 20=오더완료
                    -- 3) WRK021 (문서 이력 테이블) 생성
                    INSERT INTO tb_WRK021 (
                                            DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD, IND_BCD, LOT_NO
                                          , ORDER_NO, REGDATE, REGID, REMARK
                    ) VALUES (
                               V_TRANS_DOC_NO
                             , V_TRANS_DOC_SEQ
                             , 11
                             , P_WERKS
                             , P_MACH_CD
                             , V_BASE_IND_BCD
                             , V_BASE_LOT_NO
                             , V_BASE_ORDER_NO
                             , SYSDATE
                             , V_SESS_USER_ID
                             , '병합기준: (병합된 자재) : ' || V_LOT_NO || ' / ' || V_IND_BCD
                             );
                END IF;
            END LOOP;

        DELETE FROM TB_INV003 WHERE 1=1 AND IND_BCD = V_BASE_IND_BCD;
        -- 기준 IND_BCD 에 총재고 UPDATE
        update TB_INV001 set
            STCK_QTY           = STCK_QTY + V_TOTAL_STCK_QTY
                           , STOR_LOC_CD       = V_BASE_STOR_LOC_CD
                           , STCK_STA          = '00'
                           , UPDID             = V_SESS_USER_ID
                           , UPDDATE           = SYSDATE
                           , RMK               = 'LOT병합처리'
        where 1=1
          and WERKS = P_WERKS
          and MATNR = V_MATNR
          and LOT_NO = V_BASE_LOT_NO
          and IND_BCD = V_BASE_IND_BCD;

        --SAP FUNC ID
        SELECT RFCFN
        INTO P_MERGE_FUNC
        FROM TB_ITFMA
        WHERE IFID = 'MES_IF_131';

        --         OPEN CUR_1 FOR
--             SELECT 'MES_IF_131' AS I_IF_ID
--                  , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
--                  , V_DATE AS I_DATE
--             FROM dual;

        SELECT 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000')))
        INTO V_IF_KEY
        FROM DUAL;

        OPEN CUR_1 FOR
            SELECT 'MES_IF_131' AS I_IF_ID
                 , V_IF_KEY     AS I_IF_KEY
                 , V_DATE       AS I_DATE
            FROM DUAL;

        --인터페이스 상세 파라미터
        V_SQL := FN_IF_QUERY('MES_IF_131', V_TRANS_DOC_NO);
        OPEN CUR_2 FOR V_SQL;


        IF CUR_1%ISOPEN = FALSE THEN
            OPEN CUR_1 FOR SELECT 1 FROM dual;
        END IF;
        IF CUR_2%ISOPEN = FALSE THEN
            OPEN CUR_2 FOR SELECT 1 FROM dual;
        END IF;

        RS_CODE := 'S';
        RS_MSG  := '성공';
        --예외처리(catch)
    EXCEPTION
        WHEN E_EXCEPTION_USER THEN
            -- 에러 내역 SET
            E_SQL_ERR_CD        := SQLCODE;
            E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

--             ROLLBACK;
            SP_PROC_ERROR(P_WERKS, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

            RS_CODE := 'E';
        WHEN OTHERS THEN
            E_SQL_ERR_CD        := SQLCODE;
            E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

--             ROLLBACK;
            SP_PROC_ERROR(P_WERKS, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
            --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
            IF NOT CUR_1%ISOPEN THEN OPEN CUR_1 FOR SELECT NULL FROM DUAL WHERE 1=0; END IF;
            IF NOT CUR_2%ISOPEN THEN OPEN CUR_2 FOR SELECT NULL FROM DUAL WHERE 1=0; END IF;

            RS_CODE := 'E';
            RS_MSG  := E_SQL_ERR_MSG;
        --예외처리 종료
    END;
END SP_POP_WRK32_LOT_MERGE;
/
