
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP00_S04" 
(
    P_PROC_CD    IN VARCHAR2 
    ,P_COLINFO    OUT VARCHAR2
    ,P_COLTYPE    OUT VARCHAR2
    ,Lang       IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     OUT VARCHAR2 
    ,RS_MSG      OUT VARCHAR2
    ,CUR_1       OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_POP00_S04{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 설비명 조회
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 설비명 조회.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 김병무{최초 작성자 명 기술}
 * CREATE DATE   : 2022/04/28 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/03    1.0.0   김병무         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_MAS012] : 설비마스터
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP00_S04';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리

BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            P_COLINFO := '항목코드@H|설비명@C^350';
            P_COLTYPE := 'ItemCode@varchar|Display@varchar';
            --결과 테이블 반환용 변수
            OPEN CUR_1 FOR
            --설비명 조회
            SELECT M012.MACH_CD AS ItemCode
                 , M012.MACH_NM AS Display
            FROM TB_MAS012 M012
            WHERE 1=1
              AND M012.PROC_CD = P_PROC_CD;

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
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END SP_POP00_S04;
/
