
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK86_D01_V01" 
(
    P_WERKS             IN VARCHAR2 
    ,P_WRK_ORDR_NO      IN VARCHAR2
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2
    ,P_MACH_CD          IN VARCHAR2
    ,P_IND_BCD          IN VARCHAR2
    ,P_USERID           IN VARCHAR2
    ,P_PRFM_CNL_FUNC    OUT VARCHAR2 
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
    ,CUR_1              OUT SYS_REFCURSOR
    ,CUR_2              OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK86
 * PROGRAM NAME  : 부분폐품 등록시 기존 실적 취소
 * VERSION       : 1.0.0
 * DESCRIPTION   : 생산실적 정보를 취소한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/08/07
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/08/07    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM            VARCHAR2(100)  := 'SP_POP_WRK86_D01_V01';     -- PROCEDURE NAME
    V_PLT_CD            VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID      VARCHAR2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD        NUMBER(5) := 0;
    E_SQL_ERR_MSG       VARCHAR2(4000);

    --내부변수 관리
    V_DATE              DATE := SYSDATE;
    V_SAP_WRK_CD        TB_MAS012.SAP_WRK_CD%TYPE;
    V_LOT_NO            TB_WRK001.LOT_NO%TYPE;
    V_ROLLCNT           TB_WRK001.ROLLCNT%TYPE;
    V_DOC_NO            TB_WRK021.DOC_NO%TYPE;
    V_DOC_SEQNO         TB_WRK021.DOC_SEQNO%TYPE;
    V_ORDER_NO          TB_WRK021.ORDER_NO%TYPE;
    V_SDOC_NO           TB_WRK021.SDOC_NO%TYPE;
    V_SDOC_SEQNO        TB_WRK021.SDOC_SEQNO%TYPE;
    V_SDOC_NO_1           TB_WRK021.SDOC_NO%TYPE;
    V_SDOC_SEQNO_1        TB_WRK021.SDOC_SEQNO%TYPE;   
    --취소처리
    PROD_CUR            SYS_REFCURSOR;		-- 커서 정의
    V_SEQNO_M           TB_INV003.SEQNO%TYPE;
    V_WRK_ORDR_NO_M     TB_INV003.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO_M  TB_INV003.WRK_ORDR_SEQNO%TYPE;
    V_IND_BCD_M         TB_INV003.IND_BCD%TYPE;
    V_LOT_NO_M          TB_INV003.LOT_NO%TYPE;
    V_MATNR_M           TB_INV003.MATNR%TYPE;
    V_INP_DT_M          TB_INV003.INP_DT%TYPE;
    V_USE_QTY_M         TB_INV003.USE_QTY%TYPE;
    V_UNIT_M            TB_INV003.UNIT%TYPE;
    V_ROLLCNT_M         TB_INV003.ROLLCNT%TYPE;
    V_WGT_M             TB_INV003.WGT%TYPE;    
    V_CHG_FLG_M         TB_INV003.CHG_FLG%TYPE;    
    V_STCK_KY_M         TB_INV003.STCK_KY%TYPE;
    V_LOT_NUM_M         TB_INV003.LOT_NUM%TYPE;
    V_CHK_PP_YN         TB_WRK001.CHK_PP_YN%TYPE; 
    V_CHK_QC_YN         TB_WRK001.CHK_QC_YN%TYPE;
    --인터페이스 문서정보
    V_IF_ID_PRFM_CNL    VARCHAR2(20) := 'MES_IF_129'; --MES IF ID 실적 취소
    V_DOC_PRFM_CNL      TB_WRK001.DOC_NO%TYPE; --실적취소
    V_DOC_PRFM_SEQNO    TB_WRK001.DOC_SEQNO%TYPE;
    V_SQL VARCHAR2(4000);

BEGIN
    --예외처리 시작(try)
    BEGIN

        SELECT SAP_WRK_CD INTO V_SAP_WRK_CD
          FROM TB_MAS012
         WHERE MACH_CD = P_MACH_CD;

        SELECT SDOC_NO, SDOC_SEQNO, LOT_NO, ROLLCNT
          INTO V_SDOC_NO, V_SDOC_SEQNO, V_LOT_NO, V_ROLLCNT
          FROM TB_WRK001
         WHERE WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND IND_BCD = P_IND_BCD;

        --내부실적 정보 취소
        --생산 실적 취소처리
        UPDATE TB_WRK001
           SET CNL_YN = 'Y'
             , CNL_RMK = '부분 폐품'
             , PRFM_GTHR_YN = 'N'
             , SDOC_NO = NULL
             , SDOC_SEQNO = NULL
             , UPDDATE = V_DATE
             , UPDID = P_USERID
         WHERE WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND IND_BCD = P_IND_BCD;

        --현재 재고 취소처리
        UPDATE TB_INV001
           SET DLFL = 'Y'
             , UPDDATE = V_DATE
             , UPDID = P_USERID
         WHERE WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND IND_BCD = P_IND_BCD;

        --LOT 추적 이력 삭제    
        DELETE TB_WRK008
         WHERE WERKS = P_WERKS
           AND IND_BCD = P_IND_BCD;

--        UPDATE TB_WRK021
--           SET CNL_YN = 'Y'
--         WHERE DOC_NO = V_DOC_NO
--           AND DOC_SEQNO = V_DOC_SEQNO;

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
               AND NVL(CNL_YN,'N') = 'N'
               ;
        LOOP
            FETCH PROD_CUR INTO  V_SEQNO_M, V_WRK_ORDR_NO_M, V_WRK_ORDR_SEQNO_M, V_IND_BCD_M, V_LOT_NO_M, V_MATNR_M, V_INP_DT_M, 
                            V_USE_QTY_M, V_UNIT_M, V_ROLLCNT_M, V_WGT_M, V_CHG_FLG_M, V_STCK_KY_M, V_LOT_NUM_M;

        EXIT WHEN PROD_CUR %NOTFOUND;    
            UPDATE TB_INV003
               SET USE_QTY = USE_QTY - V_USE_QTY_M,
                   STCK_QTY = STCK_QTY + V_USE_QTY_M,
                   WGT = WGT + V_USE_QTY_M,
                   UPDDATE = SYSDATE,
                   UPDID = P_USERID
             WHERE WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND IND_BCD = V_IND_BCD_M;

            IF SQL%ROWCOUNT = 0 THEN    
                INSERT INTO TB_INV003(WERKS, MACH_CD, MATNR, IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                        LOT_NO, INP_DT, IN_QTY, USE_QTY, STCK_QTY, UNIT, ROLLCNT, WGT,
                                        CHG_FLG, STCK_KY, LOT_NUM, REGDATE, REGID)
                                VALUES(P_WERKS, P_MACH_CD, V_MATNR_M, V_IND_BCD_M, V_SEQNO_M, V_WRK_ORDR_NO_M, V_WRK_ORDR_SEQNO_M,
                                        V_LOT_NO_M, V_INP_DT_M, V_USE_QTY_M, 0, V_USE_QTY_M, V_UNIT_M, V_ROLLCNT_M, V_USE_QTY_M,
                                        V_CHG_FLG_M, V_STCK_KY_M, V_LOT_NUM_M, V_DATE, V_SESS_USER_ID);
            END IF;

            UPDATE TB_INV010
               SET CNL_YN = 'Y',
                   UPDDATE = SYSDATE,
                   UPDID = P_USERID
             WHERE WERKS = P_WERKS 
               AND MACH_CD = P_MACH_CD
               AND IND_BCD = P_IND_BCD
               AND IND_BCD_M = V_IND_BCD_M
               AND MATNR_M = V_MATNR_M;   
        END LOOP;
        CLOSE PROD_CUR;

        --취소처리 SAP전송
        --전송이력 조회
        BEGIN
        SELECT DOC_NO, DOC_SEQNO, ORDER_NO, SDOC_NO, SDOC_SEQNO
          INTO V_DOC_NO, V_DOC_SEQNO, V_ORDER_NO, V_SDOC_NO_1, V_SDOC_SEQNO_1
          FROM TB_WRK021
         WHERE WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND WRK_ORDR_NO = P_WRK_ORDR_NO
           AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
           AND IND_BCD = P_IND_BCD
           AND DOC_DIV = 1
           AND CNL_YN = 'N';
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN
                --전송실적이 없는 경우 취소처리 종료
                RS_CODE := 'S';
                --RFC 미사용 항목에 대하여 기본값 등록
                IF CUR_1%ISOPEN = FALSE THEN
                    OPEN CUR_1 FOR SELECT 1 FROM dual;
                END IF;
                IF CUR_2%ISOPEN = FALSE THEN
                    OPEN CUR_2 FOR SELECT 1 FROM dual;
                END IF;
                RETURN;
            WHEN TOO_MANY_ROWS THEN
                RS_CODE := 'E';
                RS_MSG := '해당 작업지시에 중복된 개별바코드가 존재합니다.';
                RETURN;
        END;
        --SAP 확정문서번호 확인
        IF NVL(V_SDOC_NO, ' ') = ' ' THEN
            RS_CODE := 'N';
            RS_MSG := P_IND_BCD || ' 는 SAP 확정문서번호를 찾을수 없습니다.';
            ROLLBACK;
            RETURN;
        END IF;
        --전송이력 취소처리
        UPDATE TB_WRK021
           SET CNL_YN = 'Y'
         WHERE DOC_NO = V_DOC_NO
           AND DOC_SEQNO = V_DOC_SEQNO;
        --실적 취소 인터페이스 작성  
        V_DOC_PRFM_CNL := FN_GET_MDOCNO('M','IF129');
        V_DOC_PRFM_SEQNO := 1;
        INSERT INTO TB_IFS007(RUECK, RMZHL, MDOCNO, MDOCSEQ, MAKE_DATE, MAKER,
                                WORKCENTERCODE, AUFNR, ROLLCNT, MBLNR, LOTNO)
                        VALUES(V_SDOC_NO, V_SDOC_SEQNO, V_DOC_PRFM_CNL, TO_CHAR(V_DOC_PRFM_SEQNO), V_DATE, P_USERID,
                                V_SAP_WRK_CD, V_ORDER_NO, V_ROLLCNT, V_SDOC_NO, V_LOT_NO);
        --SAP FUNC ID
        SELECT RFCFN
          INTO P_PRFM_CNL_FUNC
          FROM TB_ITFMA
         WHERE 1=1
           AND IFID = V_IF_ID_PRFM_CNL;
        --인터페이스 파라미터
        OPEN CUR_1 FOR
        SELECT V_IF_ID_PRFM_CNL AS I_IF_ID
             , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
          FROM dual;
        --인터페이스 상세 파라미터
        V_SQL := FN_IF_QUERY(V_IF_ID_PRFM_CNL, V_DOC_PRFM_CNL);
        IF V_SQL IS NOT NULL THEN
        	OPEN CUR_2 FOR V_SQL;
        END IF;

        --RFC 미사용 항목에 대하여 기본값 등록
        IF CUR_1%ISOPEN = FALSE THEN
            OPEN CUR_1 FOR SELECT 1 FROM dual;
        END IF;
        IF CUR_2%ISOPEN = FALSE THEN
            OPEN CUR_2 FOR SELECT 1 FROM dual;
        END IF;

        --작업 정상 종료 코드 등록
        RS_CODE := 'S';
    --ROLLBACK;
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
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END SP_POP_WRK86_D01_V01;
/
