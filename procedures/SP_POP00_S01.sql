
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP00_S01" 
(
    p_IPADDRESS  IN VARCHAR2 
    ,Lang        IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     OUT VARCHAR2 
    ,RS_MSG      OUT VARCHAR2
    ,CUR_1       OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : program.cs
 * PROGRAM NAME  : 초기화면 조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 프로그램 실행시 출력화면을 조회한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/04/28
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/04/28    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_MAS012] : (.R..) 설비 기준 정보
 * - [TB_MAS029] : (.R..) 작업장 기준 정보
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP00_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리
    V_IPADDRESS   VARCHAR2(30) := p_IPADDRESS;
    --내부 변수 처리
    V_WERKS         VARCHAR2(10); --플랜트
    V_MACH_CD       VARCHAR2(10); --설비코드
    V_MACH_NM       VARCHAR2(100); --설비코드
    V_WRK_CD        VARCHAR2(10); --작업장코드
    V_WRK_POT       VARCHAR2(10); --가공/포장
    V_PROC_CD       VARCHAR2(10); --공정코드
    V_MACHINE       VARCHAR2(20); --설비호기
    V_EMPLY_NO      VARCHAR2(10); --작업자번호
    V_NMLAST        VARCHAR2(60); --작업자이름
    V_WRK_CLASS     VARCHAR2(10); --작업반(1반, 2반...)
    V_WRK_SHIFT     VARCHAR2(10); --작업조(오전,오후...)
    V_WRK_INFO      VARCHAR2(30); --작업자정보
    V_STR_FRM       VARCHAR2(30); --시작화면

BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            --IP별 설비정보 조회(이후 WRK011에서 조회하도록 변경예정)
            BEGIN
            SELECT M029.WERKS
                 , M029.MACH_CD
                 , M012.MACH_NM
                 , M029.WRK_POT
                 , M012.PROC_CD
                 , M012.WRK_CD
                 , M012.MACHINE
                 , W011.EMPLY_NO
                 , USRMA.NMLAST
                 , W011.WRK_CLASS
                 , W011.WRK_SHIFT
                 , C001.CDESC1 || '-' || W011.WRK_CLASS || '반'
                 INTO V_WERKS
                    , V_MACH_CD
                    , V_MACH_NM
                    , V_WRK_POT
                    , V_PROC_CD
                    , V_WRK_CD
                    , V_MACHINE     --설비호기
                    , V_EMPLY_NO
                    , V_NMLAST
                    , V_WRK_CLASS
                    , V_WRK_SHIFT
                    , V_WRK_INFO
              FROM TB_MAS029 M029
                 , TB_MAS012 M012
                 , TB_MAS027 M027
                 , TB_WRK011 W011
                 , (SELECT CMCDKY, CMCDVL, CDESC1 FROM CMCDV WHERE CMCDKY = 'WRKMETH') C001
                 , USRMA USRMA
             WHERE 1=1
               AND M029.MACH_CD = M012.MACH_CD(+)
               AND M029.MACH_CD = W011.MACH_CD(+)
--               AND M029.WRK_POT = W011.IN_OUT(+)
               AND CASE WHEN M029.WERKS = 'P500' THEN 'N'
                        ELSE M029.WRK_POT END = W011.IN_OUT(+)
               AND W011.MACH_CD = M027.MACH_CD(+)
               AND W011.WRK_SHIFT = M027.WRK_METH(+)
               AND M027.WRK_METH = C001.CMCDVL(+)
               AND W011.EMPLY_NO = USRMA.USERID(+)
               AND M029.IP_ADDRESS = V_IPADDRESS
               AND M029.USE_YN = 'Y';
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN 
                    V_PROC_CD := 'ERR';
                WHEN TOO_MANY_ROWS THEN
                    V_PROC_CD := 'ERR';
            END;

            --화장지 합지기   
            IF V_PROC_CD = 'AA' THEN
            V_STR_FRM := 'SmartDas.POP_WRK08';
            --화장지 가공기
            ELSIF V_PROC_CD = 'RA' AND V_WRK_POT = 'I' THEN
            V_STR_FRM := 'SmartDas.POP_WRK09';
            --화장지 포장기
            ELSIF V_PROC_CD = 'RA' AND V_WRK_POT = 'O' THEN
            V_STR_FRM := 'SmartDas.POP_WRK21';
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
            ELSIF V_PROC_CD = 'PA' OR V_PROC_CD = 'PB' OR V_PROC_CD = 'PC' OR V_PROC_CD = 'PD' THEN
            V_STR_FRM := 'SmartDas.POP_WRK27';
            --슬리터
            ELSIF V_PROC_CD = 'SA' THEN
            V_STR_FRM := 'SmartDas.POP_WRK28';
            --수재단
            ELSIF V_PROC_CD = 'CB' THEN
            V_STR_FRM := 'SmartDas.POP_WRK29';
            --실적모니터링
            ELSIF V_PROC_CD = 'WM' THEN --Work Monitoring
            V_STR_FRM := 'SmartDas.POP_WRK_MONITOR';
            ELSE
            V_STR_FRM := 'SmartDas.DA0000';
            END IF;
            --결과 테이블 반환용 변수
            OPEN CUR_1 FOR
            --시작화면 조회(IP별 설정)
            SELECT V_WERKS   AS WERKS
                 , V_MACH_CD AS MACH_CD
                 , V_MACH_NM AS MACH_NM
                 , V_WRK_POT AS WRK_POT
                 , V_PROC_CD AS PROC_CD
                 , V_WRK_CD AS WRK_CD
                 , V_MACHINE AS MACHINE    --설비호기
                 , V_EMPLY_NO AS EMPLY_NO
                 , V_NMLAST AS NMLAST
                 , V_WRK_CLASS AS WRK_CLASS
                 , V_WRK_SHIFT AS WRK_SHIFT
                 , V_WRK_INFO AS WRK_INFO
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
END SP_POP00_S01;
/
