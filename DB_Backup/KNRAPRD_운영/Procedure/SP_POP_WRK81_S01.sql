--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK81_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK81_S01" 
(
    P_WERKS             IN VARCHAR2 --plantcode
    ,P_OPCODE           IN VARCHAR2 --공정정보
    ,P_WRK_ORDR_NO      IN VARCHAR2 --작업지시번호
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2 --작업지시순번
    ,P_IND_BCD          IN VARCHAR2 --개별바코드
    ,P_INFO_01          OUT VARCHAR2 -- 상세정보 1
    ,P_INFO_02          OUT VARCHAR2 -- 상세정보 2
    ,P_INFO_03          OUT VARCHAR2 -- 상세정보 3
    ,P_STATUS           OUT VARCHAR2 -- 투입가능 상태 확인
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK81_S01
 * PROGRAM NAME  : 재단 바코드 상세정보
 * VERSION       : 1.0.0
 * DESCRIPTION   : 재단 대기창고화면에서 공정투입을 위한 정보 전달
 *                 
 * AUTHOR NAME   : 김병무
 * CREATE DATE   : 2022/08/26
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/08/26    1.0.0   김병무         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_MAS001] : (.R..) 플랜트별 제품/자재 마스터
 *=============================================================================*/
AS 
    --프로그램 ID
    --재단 대기창고화면에서 공정투입을 위한 정보 전달
    V_PRG_NM         VARCHAR2(100)  := 'SP_POP_WRK81_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리

    --내부 변수 등록
    V_OPCODE    VARCHAR2(10) := P_OPCODE;
    V_RMK		TB_WRK002.RMK%TYPE;					--비고

    V_IN_MR_YN      VARCHAR2(1);
    v_STCK_QTY      TB_INV001.STCK_QTY%TYPE;		--재고확인
    V_STCK_STA      TB_INV001.STCK_STA%TYPE;		--재고상태
    V_STATUS        VARCHAR2(100);

BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
--			dbms_output.put_line(V_OPCODE);
            P_INFO_01   := ''; -- 상세정보 1
            P_INFO_02   := ''; -- 상세정보 2
            P_INFO_03   := ''; -- 상세정보 3
            P_STATUS    := ''; -- 투입가능 상태 확인

            --재단
            IF V_OPCODE = 'CA' /*OR V_OPCODE = 'CB'*/ THEN           --재단, 수재단
                SELECT  NVL(IN_MR_YN, 'N'), STCK_QTY, STCK_STA
                    INTO  V_IN_MR_YN, V_STCK_QTY, V_STCK_STA
                    FROM TB_INV001 
                    WHERE WERKS=P_WERKS
                      AND STOR_LOC_CD = '2700'
                      AND IND_BCD = P_IND_BCD;

                IF V_STCK_QTY > 0 AND V_STCK_STA = '00' THEN
                    V_STATUS := '(투입가능)';
                ELSE
                --공통코드관리에서 STCK_STA 코드 설명값을 표시....
                    BEGIN
                        SELECT '(' || CDESC1 || ')'
                            INTO V_STATUS
                            FROM CMCDV 
                            WHERE CMCDKY = 'STCK_STA' 
                              AND CMCDVL = V_STCK_STA;
                    EXCEPTION 
                          WHEN NO_DATA_FOUND THEN
                            V_STATUS := '';
                    END;
                END IF;

                IF V_IN_MR_YN = 'N' THEN
                    BEGIN
                        SELECT INFO_01, INFO_02, INFO_03, STATUS
                        INTO P_INFO_01, P_INFO_02, P_INFO_03, P_STATUS
                        FROM (
                            SELECT '밀롤오더번호^' || W002.ORDER_NO
                                || '|밀롤 LOT번호^' || W002.LOT_NO
                                || '|자재번호^' || M001.MATNR
                                || '|지종명^' || M001.PCODE_NM
                                || '|생산지시서 일자^' || TO_CHAR(TO_DATE(S016.PRD_REQ_DT, 'YYYY-MM-DD'), 'YYYY-MM-DD')
                                || '|생산일자^' || TO_CHAR(W002.REGDATE, 'YYYY-MM-DD HH24:MI:SS')
                                || '|작업자^' || USRMA.NMLAST
                                || '|리와인더 규격^' || TO_CHAR(S016.MWIDTH) || CASE WHEN NVL(W002.WIDTH, '0') <> '0' THEN '(' || TO_CHAR(W002.WIDTH) || ')' ELSE  '(' || TO_CHAR(S016.MWIDTH) || ')' END  
                                INFO_01
                                ,
                                   '실적권치수(M)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END  --실적권치수
                                || '|실적중량(Kg)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END       --실적중량
                                || '|규격^' || SUBSTR(S017.MATNR, 10, 4) || '*' || SUBSTR(S017.MATNR, 14, 4)
                                || '|거래처^' || S017.KUNNRT
                                || '|판매오더번호^' || S017.VBELN || '-' || S017.POSNR    --Sales Order No
                                INFO_02
                                ,
                                    '포장 타입^' || FN_CD_VAL('PACK_TYPE', S017.PACKTYPE)
                                || '|속당매수^' || S017.IN_PER_CNT
                                || '|항차^' || S017.ROUTE
                                || '|재단폭수^' || S017.PKCNT 
                                || '|평량^' || S017.BS_WGT
                                || '|밀롤지시사항^' || S016.ORDER_RMK
                                || '|재단지시사항^' || S017.ORDER_RMK
                                || '|밀롤비고^' || W002.RMK
--                                || '|폭수^' || S017.PKCNT
--                                || '|매수^' || PKCNT
                                INFO_03
                                ,
                                '투입여부 : ' || V_STATUS
                                STATUS
                            FROM TB_WRK002 W002    --PS실적
                               , TB_SCH016 S016     --밀롤 작업지시
                               , TB_SCH017 S017     --재단 작업지시
                               , TB_MAS001 M001     --자재코드 마스터
                               , USRMA USRMA
                            WHERE 1=1
                               AND W002.WERKS = S016.WERKS
                               AND W002.WRK_ORDR_NO = S016.WRK_ORDR_NO
                               AND W002.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO
                               AND S016.WERKS = S017.WERKS
                               AND S016.ORDER_NO = S017.PRE_ORDER_NO
                               AND W002.WERKS = M001.WERKS(+)
                               AND W002.MATNR = M001.MATNR(+)
                               AND W002.REGID = USRMA.USERID(+)
                               AND W002.WERKS = P_WERKS
                               AND W002.IND_BCD = P_IND_BCD
                               AND W002.WRK_ORDR_NO = P_WRK_ORDR_NO
                               AND W002.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                               AND NVL(W002.CNL_YN,'N') = 'N'
                               AND S017.USE_YN = 'Y'
                      );
                    EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                              RS_CODE := 'E';
                              RS_MSG := '작업지시 정보를 찾지 못했습니다.';
                              RETURN;
                    END;
                ELSE 
                    BEGIN
                        SELECT INFO_01, INFO_02, INFO_03, STATUS
                        INTO P_INFO_01, P_INFO_02, P_INFO_03, P_STATUS
                          FROM(
                        SELECT '밀롤오더번호^' || I001.ORDER_NO
                            || '|밀롤 LOT번호^' || I001.LOT_NO
                            || '|자재번호^' || I001.MATNR
                            || '|지종명^' || M001.PCODE_NM
                            || '|생산일자^' || TO_CHAR(TO_DATE(I001.PRFM_DT, 'YYYY-MM-DD'), 'YYYY-MM-DD')
                            || '|작업자^' || USRMA.NMLAST
                            INFO_01
                            ,
                               '실적권치수(M)^' ||  NVL(RTRIM(TO_CHAR(I001.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')   --실적권치수
                            || '|실적중량(Kg)^' || NVL(RTRIM(TO_CHAR(I001.WGT, 'fm999,999,999,999,990.999'), '.'), '0')        --실적중량
                            || '|규격^' || SUBSTR(S017.MATNR, 10, 4) || '*' || SUBSTR(S017.MATNR, 14, 4)
                            || '|거래처^' || S017.KUNNRT 
                            || '|판매오더번호^' || S017.VBELN || '-' || S017.POSNR    --Sales Order No
                            INFO_02
                            ,
                                '|포장 타입^' || FN_CD_VAL('PACK_TYPE', S017.PACKTYPE)
                            || '|속당매수^' || S017.IN_PER_CNT
                            || '|항차^' || S017.ROUTE
                            || '|재단폭수^' || S017.PKCNT 
                            || '|평량^' || S017.BS_WGT
                            || '|재단지시사항^' || S017.ORDER_RMK
                            INFO_03
                            ,
                            '투입여부 : ' || V_STATUS
                            STATUS
                        FROM TB_INV001 I001    --PS실적
                           , TB_SCH017 S017     --재단 작업지시
                           , TB_MAS001 M001     --자재코드 마스터
                           , USRMA USRMA
                        WHERE 1=1
                           AND I001.WERKS = S017.WERKS
                           AND I001.LOT_NO = S017.PRE_ORDER_NO
                           AND I001.WERKS = M001.WERKS(+)
                           AND I001.MATNR = M001.MATNR(+)
                           AND I001.REGID = USRMA.USERID(+)
                           AND I001.WERKS = P_WERKS
                           AND I001.IND_BCD = P_IND_BCD
                           AND S017.USE_YN = 'Y'


--                        SELECT INFO_01, INFO_02, INFO_03, STATUS
--                        INTO P_INFO_01, P_INFO_02, P_INFO_03, P_STATUS
--                        FROM (
--                        SELECT '밀롤 LOT번호^' || I001.LOT_NO
--                            || '|자재번호^' || M001.MATNR
--                            || '|지종명^' || M001.PCODE_NM
--                            --|| '|생산일자^' || TO_CHAR(W002.REGDATE, 'YYYY-MM-DD HH24:MI:SS')
--                            --|| '|작업자^' || USRMA.NMLAST
--                            INFO_01
--                            ,
----                               '실적권치수(M)^' || NVL(RTRIM(TO_CHAR(I001.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')  --실적권치수
--                            '|실적중량(Kg)^' || NVL(RTRIM(TO_CHAR(I001.STCK_QTY, 'fm999,999,999,999,990.999'), '.'), '0')       --실적중량
--                            INFO_02
--                            ,
--                               '규격^' || SUBSTR(M001.MATNR, 10, 4) || '*' || SUBSTR(M001.MATNR, 14, 4)
--                            || '|거래처^' || S016.KUNNRT 
--                            INFO_03
--                            ,
--                            '투입여부 : ' || V_STATUS
--                            STATUS
--                        FROM TB_INV001 I001    --재고
--                           , TB_SCH016 S016     --밀롤 작업지시
--                           , TB_MAS001 M001     --자재코드 마스터
----                           , USRMA USRMA
--                        WHERE 1=1
--                           AND I001.WERKS = M001.WERKS(+)
--                           AND I001.MATNR = M001.MATNR(+)
----                           AND W002.REGID = USRMA.USERID(+)
--                           AND I001.WERKS = P_WERKS
--                           AND I001.IND_BCD = P_IND_BCD
--                           AND S016.WRK_ORDR_NO = P_WRK_ORDR_NO
--                           AND S016.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
--                           --AND NVL(W002.CNL_YN,'N') = 'N'  
                      );
                    EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                              RS_CODE := 'E';
                              RS_MSG := '작업지시 정보를 찾지 못했습니다.';
                              RETURN;
                    END;
                END IF;
            ELSE
--                dbms_output.put_line('자동포장, 수축포장, 수작업 포장 선택');
				SELECT '', '', '', '투입정보 없음'
                    INTO P_INFO_01, P_INFO_02, P_INFO_03, P_STATUS
                FROM DUAL;
            END IF;

            --작업 정상 종료 코드 등록
            RS_CODE := 'S';
        END;
    --예외처리(catch)
    EXCEPTION
    WHEN E_EXCEPTION_USER THEN
        -- 에러 내역 SET
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    WHEN OTHERS THEN
        E_SQL_ERR_CD        := -20001;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END;

/
