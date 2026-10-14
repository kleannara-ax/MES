--------------------------------------------------------
--  DDL for Procedure POP_STR001_S1
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."POP_STR001_S1" 
(
    p_IPADDRESS  IN VARCHAR2 
    ,Lang        IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     OUT VARCHAR2 
    ,RS_MSG      OUT VARCHAR2
    ,CUR_1       OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_STR001_S1{호출 프로그램 ID 기술}
 * PROGRAM NAME  : IP별 설비별로 조회 {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : IP별 설비별로 조회하여 프로그램을 실행한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 김기연{최초 작성자 명 기술}
 * CREATE DATE   : {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   김기연         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_MAS029] : (.R..) POP IP 할당 관리
 *        - [TB_MAS012] : (.R..) 설비마스터                         
 *=============================================================================*/

AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'POP_STR001_S1';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리
    V_IPADDRESS   VARCHAR2(30) := p_IPADDRESS;
    --내부 변수 처리
    V_WERKS      VARCHAR(10); --플랜트
    V_MACH_CD      VARCHAR(10); --설비코드
    V_WRK_POT      VARCHAR(10); --가공/포장
    V_PROC_CD      VARCHAR(10); --공정코드
    V_STR_FRM      VARCHAR(30); --시작화면

BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            --IP별 설비정보 조회
            BEGIN
            SELECT M029.WERKS
                 , M029.MACH_CD
                 , M029.WRK_POT
                 , M012.PROC_CD
                 INTO V_WERKS, V_MACH_CD, V_WRK_POT, V_PROC_CD
              FROM TB_MAS029 M029
                 , TB_MAS012 M012
             WHERE 1=1
               AND M029.MACH_CD = M012.MACH_CD(+)
               AND M029.IP_ADDRESS = V_IPADDRESS
               AND USE_YN = 'Y';
            EXCEPTION
                WHEN NO_DATA_FOUND THEN V_PROC_CD := 'ERR';
                WHEN TOO_MANY_ROWS THEN V_PROC_CD := 'ERR';
            END;

            --화장지 합지기   
            IF V_PROC_CD = 'AA' THEN
            	IF V_IPADDRESS = '192.1.117.65'	THEN		-- 2023.01.18 백우종 임시 추가
		            V_STR_FRM := 'SmartDas.POP_WRK51';
--		            V_STR_FRM := 'SmartDas.POP_WRK08';
            	ELSE
		            V_STR_FRM := 'SmartDas.POP_WRK08';
            	END IF;
            --화장지 가공기
            ELSIF V_PROC_CD = 'RA' AND V_WRK_POT = 'I' THEN
            V_STR_FRM := 'SmartDas.POP_WRK09';
            --화장지 포장기
            ELSIF V_PROC_CD = 'RA' AND V_WRK_POT = 'O' THEN
            V_STR_FRM := 'SmartDas.POP_WRK21';
            --화장지 예외생산   
            ELSIF V_PROC_CD = 'PG' THEN
            V_STR_FRM := 'SmartDas.POP_WRK44';
            --생리대 가공기
            ELSIF V_PROC_CD = 'RB' AND V_WRK_POT = 'I' THEN
            V_STR_FRM := 'SmartDas.POP_WRK10';
            --생리대 포장기
            ELSIF V_PROC_CD = 'RB' AND V_WRK_POT = 'O' THEN
            V_STR_FRM := 'SmartDas.POP_WRK22';
            --기저귀 가공기
            ELSIF V_PROC_CD = 'RC' AND V_WRK_POT = 'I' THEN
            V_STR_FRM := 'SmartDas.POP_WRK11';
            --기저귀 포장기
            ELSIF V_PROC_CD = 'RC' AND V_WRK_POT = 'O' THEN
            V_STR_FRM := 'SmartDas.POP_WRK23';
            --생리대 예외생산   
            ELSIF V_PROC_CD = 'PF' THEN
            V_STR_FRM := 'SmartDas.POP_WRK44';
            --생리대 예외생산   
            ELSIF V_PROC_CD = 'PE' THEN
            V_STR_FRM := 'SmartDas.POP_WRK44';
            --점보롤
            ELSIF V_PROC_CD = 'JA' THEN
            V_STR_FRM := 'SmartDas.POP_WRK24';
            --리와인더
            ELSIF V_PROC_CD = 'MA' THEN
            V_STR_FRM := 'SmartDas.POP_WRK25';
            --재단
            ELSIF V_PROC_CD = 'CA' THEN
            V_STR_FRM := 'SmartDas.POP_WRK26';
            --포장
            ELSIF /*V_PROC_CD = 'PA' OR*/ V_PROC_CD = 'PB' OR V_PROC_CD = 'PC' OR V_PROC_CD = 'PD' OR V_PROC_CD = 'ZA' THEN
            V_STR_FRM := 'SmartDas.POP_WRK27';
            --슬리터
            ELSIF V_PROC_CD = 'SA' THEN
            V_STR_FRM := 'SmartDas.POP_WRK28';
            --수재단
            ELSIF V_PROC_CD = 'CB' THEN
            V_STR_FRM := 'SmartDas.POP_WRK29';
            ELSIF V_PROC_CD = 'LP1' THEN
            V_STR_FRM := 'SmartDas.POP_WRK_LAMI_PC_001';
            ELSIF V_PROC_CD = 'LS1' THEN
            V_STR_FRM := 'SmartDas.POP_WRK_LAMI_SL_002';
            ELSE
            V_STR_FRM := 'SmartDas.DA0000';
            END IF;
            --결과 테이블 반환용 변수
            OPEN CUR_1 FOR
            --시작화면 조회(IP별 설정)
            SELECT V_STR_FRM AS STARTFORM
                 , V_MACH_CD AS MACH_CD
                 , V_PROC_CD AS PROC_CD
              FROM DUAL;
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
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END ;

/
