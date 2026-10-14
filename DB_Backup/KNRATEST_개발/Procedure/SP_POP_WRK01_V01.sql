--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK01_V01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK01_V01" 
(
    P_WERKS         IN VARCHAR2         --플랜트
    ,P_MACH_CD      IN VARCHAR2         --설비코드
    ,P_IND_BCD      IN VARCHAR2         --개별바코드
    ,P_STOR_LOC_CD  IN VARCHAR2         --저장위치
    ,P_USERID       IN VARCHAR2         --
    ,P_EXCEPTION    IN VARCHAR2         --
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK01
 * PROGRAM NAME  : 공정투입전 상태 체크
 * VERSION       : 1.0.0
 * DESCRIPTION   : 선택된 작업자 정보를 저장한다.
 *                 
 * AUTHOR NAME   : 우상우
 * CREATE DATE   : 2023/01/25
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2023/01/25    1.0.0   우상우         Initial Version 
 *==============================================================================
 *  관련 테이블
 * - [TB_INV003] : (C...) 자재투입 (TB_INV001에 있는 반제품을 투입)
 * - [TB_INV001] : (.RU.) 창고별 재고 관리
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM            VARCHAR2(100)  := 'SP_POP_WRK01_V01';
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
    
    V_STCK_STA          VARCHAR2(100);
    
BEGIN
    BEGIN
        V_STCK_STA := '';    

        SELECT STCK_STA INTO V_STCK_STA FROM TB_INV001
        WHERE WERKS = P_WERKS  AND IND_BCD = P_IND_BCD ;
        
        IF V_STCK_STA <> '00' THEN
               RS_CODE := 'E';
               RS_MSG := '이미 투입 완료 되어 투입 할 수 없습니다.('||P_IND_BCD||')' ;
               RETURN;
        END IF;
        
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
