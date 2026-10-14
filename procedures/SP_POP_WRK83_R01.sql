
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK83_R01" 
(
     P_DOC_NO           IN VARCHAR2                     --문서번호
    ,P_DOC_SEQNO        IN VARCHAR2                     --문서번호 순번
    ,P_USERID           IN VARCHAR2                     --USER ID
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK30_I03{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 예외생산등록 롤백
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 예외생산등록 롤백
 *                 
 * AUTHOR NAME   : 김병무{최초 작성자 명 기술}
 * CREATE DATE   : 2023/02/18 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2023/02/18    1.0.0   김병무         Initial Version 
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/
AS 
    --프로그램 ID : 재단 ROLLBACK 
    V_PRG_NM         VARCHAR2(100) := 'SP_POP_WRK83_R01';  -- PROCEDURE NAME
    V_PLT_CD         VARCHAR2(2)   := '99';     --PLANTCODE TEST
    V_SESS_USER_ID   VARCHAR2(20)  := P_USERID; --USERID

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    --parameter변수 처리
    V_IND_BCD           TB_WRK002.IND_BCD%TYPE;      --개별바코드
    V_ORDER_NO          TB_WRK002.ORDER_NO%TYPE;

    V_WERKS             TB_WRK021.WERKS%TYPE;
    V_MACH_CD           TB_WRK021.MACH_CD%TYPE;

BEGIN
  BEGIN

    -- ROLLBACK 문서번호 SELECT---------------------------------------------------------------------------------
    	BEGIN
            SELECT WERKS,   MACH_CD,   IND_BCD,   ORDER_NO
            INTO   V_WERKS, V_MACH_CD, V_IND_BCD, V_ORDER_NO
            FROM  TB_WRK021
            WHERE DOC_NO = P_DOC_NO
            AND   DOC_SEQNO = P_DOC_SEQNO;
    	EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RS_CODE      := 'E';
                RS_MSG       := 'ROLLBACK[SP_POP_WRK26_R01] 문서번호가 조회되지 않습니다';
                ROLLBACK;
                RETURN;
            WHEN OTHERS THEN
                RS_CODE      := 'E';
                RS_MSG       := 'ROLLBACK[SP_POP_WRK26_R01] ERROR';
                ROLLBACK;
                RETURN;
    	END;

        -- 실적 취소----------------------------------------------------------------------------

        -- 실적취소 수량이 있을 때
--        IF V_PRFM_QTY > 0  THEN              
                DELETE FROM TB_WRK008     --LOT 추적
                 WHERE WERKS   = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND IND_BCD = V_IND_BCD ;

                UPDATE TB_WRK002     --실적테이블(PS)
                   SET CNL_YN  = 'Y',
                       ROL_YN  = 'Y',
                       CNL_RMK = 'ROLLBACK '||P_DOC_NO|| ' '||TO_CHAR(P_DOC_SEQNO),
                       UPDDATE = SYSDATE,
                       UPDID   = P_USERID
                 WHERE WERKS   = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND IND_BCD = V_IND_BCD ;

                 UPDATE TB_INV001
                    SET STCK_QTY = 0,
                        DLFL = 'Y',
                        ROL_YN = 'Y',
                        UPDDATE = SYSDATE,
                        UPDID   = P_USERID
                  WHERE WERKS = V_WERKS
                    AND MACH_CD = V_MACH_CD
                    AND IND_BCD = V_IND_BCD;
--        END IF;
     -------------------------------------------------------------------------------------    

    RS_CODE := 'S';
    COMMIT;
    --예외처리(catch)
    EXCEPTION
    WHEN E_EXCEPTION_USER THEN

        -- 에러 내역 SET
        E_SQL_ERR_CD  := SQLCODE;
        E_SQL_ERR_MSG := SUBSTRB(SQLERRM,1,300);

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;

    WHEN OTHERS THEN

        E_SQL_ERR_CD  := SQLCODE;
        E_SQL_ERR_MSG := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

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
