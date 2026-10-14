
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK01_LAMI_I02" SP_POP_WRK01_LAMI_I02
(
    P_WERKS             IN VARCHAR2         --플랜트
    ,P_MACH_CD          IN VARCHAR2         --설비코드
    ,P_IND_BCD      IN VARCHAR2         --개별바코드
    ,P_WRK_ORDR_NO      IN VARCHAR2         --개별바코드
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2         --저장위치
    ,P_USERID           IN VARCHAR2         --
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : 슬리팅
 * PROGRAM NAME  : 공정투입취소
 * VERSION       : 1.0.0
 * DESCRIPTION   : 선택된 자재정보를 투입 취소한다.
 *                 
 * AUTHOR NAME   : 김수현
 * CREATE DATE   : 2022/12/24
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/12/24    1.0.0   김수현         Initial Version 
 *==============================================================================
 *  관련 테이블
 * - [TB_INV003] : (C...) 자재투입 (TB_INV001에 있는 반제품을 투입)
 * - [TB_INV001] : (.RU.) 창고별 재고 관리
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM            VARCHAR2(100)  := 'SP_POP_WRK01_LAMI_I02';
    V_PLT_CD            VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID      VARCHAR2(20) := P_USERID;
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER    EXCEPTION;
    E_SQL_ERR_CD        NUMBER(5) := 0;
    E_SQL_ERR_MSG       VARCHAR2(4000);

    --파리미터 처리
    --내부변수 처리
    V_DOC_NO            TB_IFSWC007.DOC_NO%TYPE;
    V_DOC_SEQNO         TB_IFSWC007.DOC_NOSEQ%TYPE;
    V_LOT_NO            TB_INV001.LOT_NO%TYPE;
    V_WCS_WRK_CD        TB_MAS012.WCS_WRK_CD%TYPE;
    V_DATE              DATE := SYSDATE;
    V_DMY               NUMBER(5) := 0;
    V_MACH_CD           TB_INV003.MACH_CD%TYPE;
    V_MACH_NM           TB_MAS012.MACH_NM%TYPE;

--    V_IN_MR_YN          TB_INV001.IN_MR_YN%TYPE;
    V_WRK_ORDR_NO       TB_INV001.WRK_ORDR_NO%TYPE;
--    V_WRK_ORDR_SEQNO    TB_SCH016.WRK_ORDR_SEQNO%TYPE;
    V_STCK_STA          VARCHAR2(100);
    V_STOCK_QTY         NUMBER(10);
    V_CNT1              NUMBER(10);

BEGIN
    --예외처리 시작(try)
    BEGIN

          SELECT COUNT(P_WRK_ORDR_NO)
          INTO V_CNT1
          FROM TB_INV003
          WHERE 1 = 1
          AND WRK_ORDR_NO = P_WRK_ORDR_NO
          AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
          AND IND_BCD = P_IND_BCD
          AND WERKS = P_WERKS
          --AND MACH_CD = P_MACH_CD
          ;

          IF V_CNT1 = 0 THEN
               RS_CODE := 'E';
               RS_MSG := '투입 취소 할수 있는 작업이 아닙니다.('||P_IND_BCD||')' ;
               RETURN;
          END IF;

          SELECT STCK_QTY
          INTO V_STOCK_QTY
          FROM TB_INV003
          WHERE 1 = 1
          AND WRK_ORDR_NO = P_WRK_ORDR_NO
          AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
          AND IND_BCD = P_IND_BCD
          AND WERKS = P_WERKS
          --AND MACH_CD = P_MACH_CD
          ;

          UPDATE TB_INV001 SET 
           STCK_STA = '00'
          ,STCK_QTY = V_STOCK_QTY
          ,UPDDATE = V_DATE
          ,UPDID = V_SESS_USER_ID
          WHERE 1 = 1
          AND IND_BCD = P_IND_BCD
          AND WERKS = P_WERKS
          --AND MACH_CD = P_MACH_CD
          ;

          DELETE FROM TB_INV003
          WHERE 1 = 1
          AND WRK_ORDR_NO = P_WRK_ORDR_NO
          AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
          AND IND_BCD = P_IND_BCD
          AND WERKS = P_WERKS
          --AND MACH_CD = P_MACH_CD
          ;

        --작업 정상 종료 코드 등록
        RS_CODE := 'S';
        COMMIT;

    --예외처리(catch)
    EXCEPTION
    WHEN dup_val_on_index THEN
         RS_CODE := 'E';
         RS_MSG  := SQLERRM;
         RETURN;
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
        RAISE;
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
        --예외처리 종료
    END;
END;
/
