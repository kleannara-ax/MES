
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_AUTO_CANC_SAP" 
(
    ROLLBACK_TYPE           IN VARCHAR2
    ,P_WERKS                IN VARCHAR2
    ,P_MACH_CD		        IN VARCHAR2
    ,P_IND_BCD		        IN VARCHAR2
    ,P_USERID               IN VARCHAR2
    ,P_WMS_CANC_KEY         IN VARCHAR2
    ,P_TRANS_CANC_KEY       IN VARCHAR2
    ,P_TYPE                 IN VARCHAR2 DEFAULT 'AUTO'
    ,RS_CODE_RB             OUT VARCHAR2
    ,RS_MSG_RB              OUT VARCHAR2
    ,P_DOC_NO_CANC_TRANS    OUT VARCHAR2
    ,P_DOC_NO_CANC_WRK      OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK20
 * PROGRAM NAME  : 오토라벨러 롤백 프로세스 1 - SAP 실적취소
 * VERSION       : 1.0.0
 * DESCRIPTION   : 오토라벨러 SAP 전송된 실적을 취소한다.
 *
 * AUTHOR NAME   : 백우종
 * CREATE DATE   : 2023/09/22
 * SYSTEM NAME   : AUTO Labeller
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description
 * ------------ ------- ------------- ------------------------------------------
 * 2023/09/22    1.0.0   	백우종         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_SCH003] : (.R..) 화장지 가공기 생산오더
 * - [TB_SCH012] : (.R..) 화장지 가공기 작업지시
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 * - [TB_WRK001] : (.R..) HL 생산실적 이력
 *=============================================================================*/
AS
    --프로그램 ID
    V_PRG_NM                VARCHAR2(100)  := 'SP_AUTO_CANC_SAP';     -- PROCEDURE NAME
    V_PLT_CD                VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID          VARCHAR2(20) := P_USERID; --USERID
	-- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  	EXCEPTION;
    E_SQL_ERR_CD      	NUMBER(5) 		:= 0;
    E_SQL_ERR_MSG		VARCHAR2(4000);

	-- 조건절 처리용 변수선언 영역
-- 	V_WERKS        		TB_WRK001.WERKS%TYPE;				--플랜트코드
	V_MACH_CD	 		TB_WRK001.MACH_CD%TYPE;				--설비코드
	V_MATNR	 			TB_WRK001.MATNR%TYPE;				--자재코드
    V_CNL_YN	 		TB_WRK001.CNL_YN%TYPE;				--취소여부

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

    V_DATE              DATE := SYSDATE;
    PROD_CUR            SYS_REFCURSOR;		-- 커서 정의

    V_LOT_NO            TB_WRK001.LOT_NO%TYPE;
    V_CNL_RMK           TB_WRK001.CNL_RMK%TYPE;
    V_PRFM_TYPE         TB_WRK001.PRFM_TYPE%TYPE;

    V_DOC_NO_CANC_TRANS   TB_WRK001.DOC_NO%TYPE; /*재고이전취소 문서번호*/
    V_DOC_SEQNO_CANC_TRANS       TB_WRK001.DOC_SEQNO%TYPE;

    V_DOC_NO_CANC_WRK   TB_WRK001.DOC_NO%TYPE; /*실적취소 문서번호*/
    V_DOC_SEQNO_CANC_WRK       TB_WRK001.DOC_SEQNO%TYPE;

    V_CNT               NUMBER;
    V_DOC_NO1           VARCHAR2(4000);

    V_DOC_NO_PRE        TB_WRK021.DOC_NO%TYPE;
    V_DOC_SEQNO_PRE     TB_WRK021.DOC_SEQNO%TYPE;
    V_SDOC_NO_PRE       TB_WRK021.SDOC_NO%TYPE;
    V_SDOC_SEQNO_PRE    TB_WRK021.SDOC_SEQNO%TYPE;

    V_PRFM_QTY          TB_INV003.USE_QTY%TYPE;
    V_DISPO_CNT			NUMBER;
    V_DOC_NO_DEL		VARCHAR2(50);
    V_WMS_CANC_CD		VARCHAR2(100); -- WMS 입고 취소를 위한 코드
    V_ERR_MSG				VARCHAR2(4000);			-- WMS DATA INSERT MSG
    V_ERR_CODE				VARCHAR2(10);			-- WMS DATA INSERT CODE

    V_LOTNUM                VARCHAR(100);
    V_STOKKY                VARCHAR(100);
    V_VGPOS                VARCHAR(50);
    V_WMS_STORE_CNT          NUMBER;
BEGIN
    BEGIN
    --예외처리 시작(try)
        BEGIN
            SZP_MES_PLSQL_LOG('--------------진입---------------', 'SP_AUTO_CANC_SAP');
            V_CNL_RMK :='오토라벨러실적오류에의한 롤백';

            SELECT SAP_WRK_CD INTO V_SAP_WRK_CD
            FROM TB_MAS012
            WHERE MACH_CD = P_MACH_CD;

            BEGIN
                SELECT ORDER_NO,
                       ROLLCNT,
                       CHK_PP_YN,
                       CHK_QC_YN,
                       DOC_NO,
                       DOC_SEQNO,
                       SDOC_NO,
                       SDOC_SEQNO,
                       LOT_NO,
                       WRK_ORDR_NO,
                       WRK_ORDR_SEQNO,
                       MATNR,
                        PRFM_QTY
                INTO V_ORDER_NO, V_ROLLCNT, V_CHK_PP_YN, V_CHK_QC_YN, V_DOC_NO, V_DOC_SEQNO, V_SDOC_NO, V_SDOC_SEQNO, V_LOT_NO, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_MATNR, V_PRFM_QTY
                FROM	TB_WRK001
                WHERE	WERKS = P_WERKS
                AND		MACH_CD = P_MACH_CD
                AND		IND_BCD = P_IND_BCD;

				EXCEPTION	WHEN NO_DATA_FOUND THEN
					RS_CODE_RB := 'S';
					RS_MSG_RB := '[롤백완료]HL 실적입력 전 오류발생건';
					RETURN;
			END;

            -- Step 1 실행
            -- 재고이전취소(250218 실행될일없을듯함 혹시모르니 일단남겨둠)
--             IF ROLLBACK_TYPE IN ('DELETE_WCS_RB') THEN
--                 SZP_MES_PLSQL_LOG('1', 'SP_AUTO_CAN_SAP ' || ROLLBACK_TYPE);
--                 DBMS_OUTPUT.PUT_LINE('DELETE_WCS_RB');
--
--                 V_CNT := 1;
--                 BEGIN
--                     /* 1. 문서이력 테이블 체크 */
--                     SELECT DOC_NO, DOC_SEQNO, SDOC_NO, SDOC_SEQNO
--                         INTO V_DOC_NO_PRE, V_DOC_SEQNO_PRE, V_SDOC_NO_PRE, V_SDOC_SEQNO_PRE
--                     FROM TB_WRK021
--                     WHERE DOC_DIV = '6'
--                         AND WERKS = P_WERKS
--                         AND IND_BCD = V_IND_BCD
--                         AND CNL_YN = 'N';
--
--                     SZP_MES_PLSQL_LOG('취소 프로시저 TB_WRK021 DOC_NO, DOC_SEQNO, SDOC_NO, SDOC_SEQNO : ' || V_DOC_NO_PRE || ' ' || V_DOC_SEQNO_PRE|| ' ' || V_SDOC_NO_PRE|| ' ' || V_SDOC_SEQNO_PRE, 'CANC_SAP');
--                     EXCEPTION
--                         WHEN NO_DATA_FOUND THEN
--                             V_CNT := 0;
--                 END;
--
--                 /* 2. 문서이력테이블에 데이터 존재하면 재고이전 취소 진행 */
--                 IF V_CNT > 0 THEN
--                     --재고이전 취소
--                     --변수명 변경
--                     V_DOC_NO_CANC_TRANS := FN_GET_MDOCNO('M','IF132');
--                     V_DOC_SEQNO_CANC_TRANS := 1;
--
--                     SELECT SAP_WRK_CD INTO V_SAP_WRK_CD
--                     FROM TB_MAS012
--                     WHERE MACH_CD = V_MACH_CD;
--
--                     V_PRFM_DT := FN_RECDATE(V_DATE);
--
--                     /* 재고이전 테이블 INSERT */
--                     INSERT INTO TB_IFS010(AUFNR, POSNR, BUDAT, MATNR, MENGE,
--                                             WERKS, LGORT, CHARG, WORKCENTERCODE,
--                                             MDOCNO, MDOCSEQ, MBLNR, MJAHR,
--                                             ZRESULT, MAKE_DATE, MAKER, GRCHK)
--                                    VALUES('', '10', V_PRFM_DT, V_MATNR, V_PRFM_QTY,
--                                             P_WERKS, '3100', V_LOT_NO, V_SAP_WRK_CD,
--                                             V_DOC_NO_CANC_TRANS, TO_CHAR(V_DOC_SEQNO_CANC_TRANS), V_SDOC_NO_PRE, V_SDOC_SEQNO_PRE,
--                                             'N', V_DATE, V_SESS_USER_ID, '');
--
--                     /* 문서이력테이블 CNL_YN UPDATE */
--                     UPDATE TB_WRK021
--                        SET CNL_YN = 'Y',
--                            UPDDATE = V_DATE,
--                            UPDID = V_SESS_USER_ID
--                      WHERE DOC_NO = V_DOC_NO_PRE
--                        AND DOC_SEQNO = V_DOC_SEQNO_PRE;
--                 END IF;
--             END IF;

            -- Step 2 실행
            -- WMS 입고 취소
            IF ROLLBACK_TYPE IN ('DELETE_transferSap_RB', 'DELETE_storeWms_RB') THEN
                SZP_MES_PLSQL_LOG('--------------진입---------------', 'STEP2 SP_AUTO_CANC_SAP');

                /* P_WMS_CANC_KEY : WCS 입고 프로시저내에서 RETURN 받은 KEY 넣어줘야함 */
                SZP_MES_PLSQL_LOG('2 : P_WMS_CANC_KEY ' || P_WMS_CANC_KEY, 'SP_AUTO_CAN_SAP ' || ROLLBACK_TYPE);

                IF P_WMS_CANC_KEY IS NOT NULL THEN
                    SELECT COUNT(*) INTO V_WMS_STORE_CNT
                    FROM RECDI@KNRAWMSLINK
                    WHERE 1=1
                        AND RECVKY = P_WMS_CANC_KEY;

                    SZP_MES_PLSQL_LOG('2 : V_WMS_STORE_CNT ' || V_WMS_STORE_CNT, 'SP_AUTO_CAN_SAP ' || ROLLBACK_TYPE);

                    IF V_WMS_STORE_CNT IS NOT NULL THEN
                        -- 디비링크로 호출해서 WMS 입고 취소
                        DBLINK_WMSIF103@KNRAWMSLINK('D', P_WMS_CANC_KEY, V_ERR_CODE, V_ERR_MSG, V_STOKKY, V_LOTNUM);

                        SZP_MES_PLSQL_LOG('2 : V_ERR_CODE ' || V_ERR_CODE, 'SP_AUTO_CAN_SAP ' || ROLLBACK_TYPE);
                        SZP_MES_PLSQL_LOG('2 : V_ERR_MSG ' || V_ERR_MSG, 'SP_AUTO_CAN_SAP ' || ROLLBACK_TYPE);
                    END IF;
                END IF;

                /* 재고이전 관련 테이블 삭제 */
                IF P_TRANS_CANC_KEY IS NOT NULL THEN
                    DELETE FROM TB_WRK017
                    WHERE DOC_NO = P_TRANS_CANC_KEY;

                    DELETE FROM TB_IFS009
                    WHERE MDOCNO = P_TRANS_CANC_KEY;

                    DELETE FROM TB_WRK021
                    WHERE DOC_NO = P_TRANS_CANC_KEY;

                    SZP_MES_PLSQL_LOG('--------------끝---------------', 'STEP2 SP_AUTO_CANC_SAP');
                END IF;
            END IF;

            -- Step 3 실행
            -- SAP 실적취소 를 위한 테이블 INSERT
            IF ROLLBACK_TYPE IN ('DELETE_transferSap_RB', 'DELETE_storeWms_RB') THEN
                SZP_MES_PLSQL_LOG('--------------진입----------------', 'STEP3 SP_AUTO_CANC_SAP');
                /* SAP 문서확정번호 공백이 아니라면 wrk001 에서 가져온 sdoc_no 임 */
                /* V_DOC_NO_CANC_WRK 실적취소 문서번호 */
                IF NVL(V_SDOC_NO, ' ') <> ' ' AND NVL(V_SDOC_NO, ' ') <> 'E' THEN
                    V_DOC_NO_CANC_WRK := FN_GET_MDOCNO('M','IF129');
                    V_DOC_SEQNO_CANC_WRK := 1;

                    SZP_MES_PLSQL_LOG('V_DOC_NO_CANC_WRK ' || V_DOC_NO_CANC_WRK, 'SP_AUTO_CAN_SAP ' || ROLLBACK_TYPE);
                    SZP_MES_PLSQL_LOG('TB_IFS007 V_SDOC_NO ' || V_SDOC_NO, 'SP_AUTO_CAN_SAP ' || ROLLBACK_TYPE);

                    /* 실적취소테이블 INSERT */
                    IF P_TYPE = 'AUTO' THEN
                        INSERT INTO TB_IFS007(RUECK, RMZHL, MDOCNO, MDOCSEQ, MAKE_DATE, MAKER,
                                        WORKCENTERCODE, AUFNR, ROLLCNT, MBLNR, LOTNO)
                           VALUES(V_SDOC_NO, V_SDOC_SEQNO, V_DOC_NO_CANC_WRK, TO_CHAR(V_DOC_SEQNO_CANC_WRK), V_DATE, V_SESS_USER_ID,
                                V_SAP_WRK_CD, V_ORDER_NO, V_ROLLCNT, V_SDOC_NO, V_LOT_NO);
                    END IF;

                    SZP_MES_PLSQL_LOG('--------------끝---------------', 'STEP3 SP_AUTO_CANC_SAP');
                END IF;
            END IF;

            -- Step 4 실행
            -- MES 실적취소 를 위한 테이블 INSERT
            IF ROLLBACK_TYPE IN ('DELETE_transferSap_RB', 'DELETE_storeWms_RB', 'DELETE_workSap_RB', 'DELETE_workMes_RB')  THEN
                SZP_MES_PLSQL_LOG('--------------진입---------------', 'STEP4 SP_AUTO_CANC_SAP');
                SELECT PRFM_TYPE
                    INTO V_PRFM_TYPE
                FROM TB_WRK001
                WHERE 1 = 1
                  AND WERKS = P_WERKS
                  AND MACH_CD = P_MACH_CD
                  AND IND_BCD = P_IND_BCD;

                IF V_PRFM_TYPE IS NULL THEN
                    V_CNL_RMK := 'POP실적오류에의한 롤백';
                END IF;
                -- MES Data Rollback 처리
                UPDATE TB_WRK001
                   SET CNL_YN = 'Y',
                    CNL_RMK = V_CNL_RMK,
                    PRFM_GTHR_YN = 'N',
                    UPDDATE = SYSDATE,
                    UPDID = V_SESS_USER_ID
                WHERE WERKS = P_WERKS
                    AND MACH_CD = P_MACH_CD
                    AND IND_BCD = P_IND_BCD;

                --재고삭제
                UPDATE TB_INV001
                    SET STCK_QTY = 0,
                        DLFL = 'Y',
                        UPDDATE = SYSDATE,
                        UPDID = V_SESS_USER_ID
                WHERE WERKS = P_WERKS
                    AND MACH_CD = P_MACH_CD
                    AND IND_BCD = P_IND_BCD;

                --작업지시 작업완료 FLAG 취소
                IF P_WERKS = 'P200' THEN
                    IF SUBSTR(P_MACH_CD, 2, 2) = 'RA' THEN
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
                ELSIF P_WERKS = 'P300' THEN
                    IF SUBSTR(P_MACH_CD, 2, 2) = 'RB' THEN
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
                ELSIF P_WERKS = 'P500' THEN
                    IF SUBSTR(P_MACH_CD, 2, 2) = 'RC' THEN
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

                /* LOT 추적 테이블 */
                DELETE
                FROM TB_WRK008
                WHERE WERKS = P_WERKS
                   AND IND_BCD = P_IND_BCD;

                /* 문서이력 테이블 */
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
                     WHERE WERKS = P_WERKS
                       AND MACH_CD = P_MACH_CD
                       AND IND_BCD = P_IND_BCD
                       AND USE_DIV = '1';
                LOOP
                FETCH PROD_CUR INTO  V_SEQNO_M, V_WRK_ORDR_NO_M, V_WRK_ORDR_SEQNO_M, V_IND_BCD_M, V_LOT_NO_M, V_MATNR_M, V_INP_DT_M,
                                V_USE_QTY_M, V_UNIT_M, V_ROLLCNT_M, V_WGT_M, V_CHG_FLG_M, V_STCK_KY_M, V_LOT_NUM_M;

                EXIT WHEN PROD_CUR %NOTFOUND;
                SZP_MES_PLSQL_LOG('EXIT WHEN PROD_CUR %NOTFOUND 진입', 'SP_AUTO_CANC_SAP');
                    UPDATE TB_INV003
                       SET USE_QTY = USE_QTY - V_USE_QTY_M,
                           STCK_QTY = STCK_QTY + V_USE_QTY_M,
                           WGT = WGT + V_USE_QTY_M,
                           UPDDATE = SYSDATE,
                           UPDID = V_SESS_USER_ID
                      WHERE WERKS = P_WERKS
                        AND MACH_CD = P_MACH_CD
                        AND IND_BCD = V_IND_BCD_M;

                    IF SQL%ROWCOUNT =0 THEN
                        SELECT SUM(USE_QTY)  INTO V_T_USE_QTY
                          FROM TB_INV010
                         WHERE WERKS = P_WERKS
                           AND MACH_CD = P_MACH_CD
                           AND IND_BCD = P_IND_BCD
                           AND IND_BCD_M = V_IND_BCD_M
                           AND USE_QTY > 0
                           AND USE_DIV = '1'
                           AND NVL(CNL_YN, 'N') = 'N';

                        --220825 KKY 자재투입이력 순번처리 수정
                        SELECT COUNT(*) INTO V_CNT
                          FROM TB_INV003
                         WHERE WERKS = P_WERKS
                           AND MACH_CD = P_MACH_CD
                           AND MATNR = V_MATNR_M
                           AND SEQNO = 1;

                        IF V_CNT > 0 THEN
                            UPDATE TB_INV003
                               SET SEQNO = SEQNO + 1
                             WHERE WERKS = P_WERKS
                               AND MACH_CD = P_MACH_CD
                               AND MATNR = V_MATNR_M;
                        END IF;

                        V_SEQNO_M := 1;
                        INSERT INTO TB_INV003(WERKS, MACH_CD, MATNR, IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                            LOT_NO, INP_DT, IN_QTY, USE_QTY, STCK_QTY,
                                            UNIT, ROLLCNT, WGT,
                                            CHG_FLG, STCK_KY, LOT_NUM, REGDATE, REGID)
                                    VALUES(P_WERKS, P_MACH_CD, V_MATNR_M, V_IND_BCD_M, V_SEQNO_M, V_WRK_ORDR_NO_M, V_WRK_ORDR_SEQNO_M,
                                            V_LOT_NO_M, V_INP_DT_M, V_T_USE_QTY, V_T_USE_QTY - V_USE_QTY_M, V_T_USE_QTY -(V_T_USE_QTY - V_USE_QTY_M),
                                            V_UNIT_M, V_ROLLCNT_M, V_USE_QTY_M,
                                            V_CHG_FLG_M, V_STCK_KY_M, V_LOT_NUM_M, V_DATE, V_SESS_USER_ID);
                    END IF;

                    UPDATE TB_INV010
                       SET CNL_YN = 'Y',
                           UPDDATE = SYSDATE,
                           UPDID = V_SESS_USER_ID
                     WHERE WERKS = P_WERKS
                       AND MACH_CD = P_MACH_CD
                       AND IND_BCD = P_IND_BCD
                       AND IND_BCD_M = V_IND_BCD_M
                       AND USE_DIV = '1'
                       AND MATNR_M = V_MATNR_M;
                END LOOP;

                CLOSE PROD_CUR;

                -- 4. 생산출고요청 테이블 데이터 삭제
                BEGIN
                    SELECT	DOC_NO INTO V_DOC_NO_DEL
                    FROM	TB_IFSWM005
                    WHERE	WERKS = P_WERKS
                        AND 	IND_BCD = P_IND_BCD
            --			AND 	IF_STATUS = 'N'
                        AND 	DLFL = 'C'
                        AND 	ROWNUM = 1;

                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            V_DOC_NO_DEL := 'N';
                END;

                SZP_MES_PLSQL_LOG('ifwms103 삭제를 위한 EBELN 값 V_DOC_NO_DEL : ' ||V_DOC_NO_DEL, 'CANC_SAP' );

                IF V_DOC_NO_DEL <> 'N'	THEN
                    DELETE	IFWMS103@KNRAWMSLINK
                    WHERE	EBELN = V_DOC_NO_DEL;
                END IF;

                -- 5. WMS 입고요청 데이터 삭제
                DELETE	TB_IFSWM005
                WHERE	WERKS = P_WERKS
                    AND 	IND_BCD = P_IND_BCD
                    AND 	IF_STATUS = 'N'
                    AND 	DLFL = 'C';

                /* 완제품 출고이력 테이블 */
                DELETE	TB_WRK015
                WHERE	WERKS = P_WERKS
                    AND 	IND_BCD = P_IND_BCD
                    AND 	DLFL = 'C'
                    AND 	REQ_STA = 'R';

                SZP_MES_PLSQL_LOG('--------------끝---------------', 'STEP4 SP_AUTO_CANC_SAP');
            END IF;

            P_DOC_NO_CANC_TRANS := V_DOC_NO_CANC_TRANS;
            P_DOC_NO_CANC_WRK := V_DOC_NO_CANC_WRK;
            RS_CODE_RB := 'S';
            RS_MSG_RB := '[롤백완료]';
        END;
    SZP_MES_PLSQL_LOG('--------------끝---------------', 'SP_AUTO_CANC_SAP');
    --예외처리(catch)
    EXCEPTION
        WHEN E_EXCEPTION_USER THEN
            SZP_MES_PLSQL_LOG('EXCEPTION E_EXCEPTION_USER 진입', 'SP_AUTO_CANC_SAP');
            -- 에러 내역 SET
            E_SQL_ERR_CD        := SQLCODE;
            E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

            ROLLBACK;
            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

            RS_CODE_RB := 'E';
            RS_MSG_RB  := SQLERRM;
            RETURN;
    --예외처리 종료
    END;
END SP_AUTO_CANC_SAP;
/
