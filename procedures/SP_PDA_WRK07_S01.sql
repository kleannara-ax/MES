
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_PDA_WRK07_S01" 
(
    P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
AS 
/*==============================================================================
 * PROGRAM ID    : SP_PDA_WRK07_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : PDA 재고실사지시 목록{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 재고실사지시 목록{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박충식 {최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/17 {최초 작성일자 기술}
 * SYSTEM NAME   : PDA
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/17    1.0.0   박충식         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_INV008] : (.R..) 재고실사 작업지시정보                                
 *       - [TB_MAS003] : (.R..) 저장위치 마스터                            
   *=============================================================================*/
    --프로그램 ID
    V_PRG_NM          VARCHAR2(100)  := 'SP_PDA_WRK07_S01';     -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_OBJECT_T;
    V_OBJ            JSON_OBJECT_T;
    V_OBJ2           JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS            TB_INV008.WERKS%TYPE;        -- 플랜트코드
    V_FR_WRK_REQ_DT    TB_INV008.WRK_REQ_DT%TYPE;   -- 시작실사예정일  
    V_TO_WRK_REQ_DT    TB_INV008.WRK_REQ_DT%TYPE;   -- 종료실사예정일  
    V_STOR_LOC_CD		TB_MAS003.STOR_LOC_CD%TYPE;	--저장위치

BEGIN
    OPEN P_RS_LIST FOR 
    SELECT NULL FROM DUAL WHERE ROWNUM = 0;    

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);
    V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=       V_JSON.get_string('SES_WAREKY');

    /* 조건값 할당 */
    V_RANGE_SQL          :=       V_JSON.get_string('RANGE_SQL');                   -- 작업지시 조회 시 일자

    V_WERKS              :=       V_JSON.get_string('WERKS');                       -- 플랜트코드
    V_FR_WRK_REQ_DT      :=       V_JSON.get_string('FR_WRK_REQ_DT');               -- 시작실사예정일  
    V_TO_WRK_REQ_DT      :=       V_JSON.get_string('TO_WRK_REQ_DT');               -- 종료실사예정일  

    IF P_TYPE = 'LIST' THEN 

        V_SQL := ' SELECT I008.WERKS,          --플랜트코드  
                          I008.WRK_ORDR_NO,    --작업지시번호
                          I008.WRK_REQ_DT,     --실사예정일
                          I008.WRK_ORDR_RMK    --비고
                     FROM TB_INV008  I008
                     WHERE 1=1';

        V_SQL := V_SQL || ' AND I008.WERKS = ''' || V_WERKS || '''';                  
        V_SQL := V_SQL || ' AND I008.WRK_REQ_DT BETWEEN ''' || V_FR_WRK_REQ_DT || ''' AND ''' || V_TO_WRK_REQ_DT || '''';                  
        V_SQL := V_SQL || ' ORDER BY I008.WRK_REQ_DT, I008.WRK_ORDR_NO ';

        BEGIN           
     		OPEN P_RS_LIST FOR V_SQL;

        EXCEPTION           
        WHEN OTHERS THEN 
            P_SUCCESS           := 'N';
            E_SQL_ERR_CD        := SQLCODE;
            E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
            RETURN;           
        END;
    ELSIF P_TYPE = 'LIST2' THEN --저장위치
		V_SQL := ' SELECT STOR_LOC_CD
                        , STOR_LOC_NM
                     FROM TB_MAS003 --저장위치
                    WHERE WERKS = ''' || V_WERKS || '''
                    ORDER BY STOR_LOC_CD ';
        OPEN P_RS_LIST FOR V_SQL;
        
    ELSIF P_TYPE = 'LIST3' THEN --로케이션
        V_STOR_LOC_CD       :=      V_JSON.get_string('STOR_LOC_CD');
        
		V_SQL := ' SELECT LOC_CD
                        , LOC_NM
                     FROM TB_MAS028 --로케이션
                    WHERE WERKS = ''' || V_WERKS || '''
                      AND STOR_LOC_CD = ''' || V_STOR_LOC_CD || '''
                    ORDER BY LOC_CD ';
                    
        OPEN P_RS_LIST FOR V_SQL;   
    END IF;

    P_SUCCESS := 'Y';

    COMMIT;

    EXCEPTION
    WHEN E_EXCEPTION_USER THEN

        -- 에러 내역 SET
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        ROLLBACK;

    WHEN OTHERS THEN
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
