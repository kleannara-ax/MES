--------------------------------------------------------
--  DDL for Procedure SP_PDA_WRK12_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_PDA_WRK12_S01" 
(
    P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    varchar2,
    P_SUCCESS       OUT    varchar2,
    P_ERR_MSG       OUT    VARCHAR2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
AS 
/*==============================================================================
 * PROGRAM ID    : PDA_WRK12{호출 프로그램 ID 기술}
 * PROGRAM NAME  : PDA 기초재고셋업실사{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 공정재고실사{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 유상호{최초 작성자 명 기술}
 * CREATE DATE   : 2022/08/30 {최초 작성일자 기술}
 * SYSTEM NAME   : PDA
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/08/30    1.0.0   유상호         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_MAS001] : (.R..) 자재 마스터                                
 *       - [TB_MAS015] : (CRUD) 검사항목별 기준정보 등록 마스트                              
 *       - [TB_MAS016] : (CRUD) 검사항목별 기준값 정보                                
 *=============================================================================*/
    --프로그램 ID
    V_PRG_NM          VARCHAR2(100)  := 'SP_PDA_WRK12_S01';     -- PROCEDURE NAME

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
    V_WERKS             TB_WRK011.WERKS%TYPE;        -- 플랜트코드
    V_IND_BCD           TB_INV001.IND_BCD%TYPE;      -- 업체/개별바코드
    V_WRK_ORDR_NO       TB_INV015.WRK_ORDR_NO%TYPE; 
    V_STOR_LOC_CD       TB_INV001.STOR_LOC_CD%TYPE;  -- 저장위치
    V_MATNR             TB_INV001.MATNR%TYPE;        -- 자재코드
    V_STOR_LOC_FLG      TB_INV015.STOR_LOC_FLG%TYPE; 
    V_MATNR_FLG         TB_INV015.MATNR_FLG%TYPE; 
    V_STCK_QTY          TB_INV001.STCK_QTY%TYPE;
    V_SIL_QTY           TB_INV001.STCK_QTY%TYPE;
    V_UNIT              TB_INV001.UNIT%TYPE;
    V_LOT_NO            TB_INV001.LOT_NO%TYPE;
    V_DATE              DATE := SYSDATE;
    V_CNT               NUMBER;
    PROD_CUR            SYS_REFCURSOR;		-- 커서 정의
BEGIN
    OPEN P_RS_LIST FOR 
    SELECT NULL FROM DUAL WHERE ROWNUM = 0;    

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);
    V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=       V_JSON.get_string('SES_WAREKY');

    /* 조건값 할당 */
    V_WERKS              :=       V_JSON.get_string('WERKS');            -- 플랜트코드
    V_WRK_ORDR_NO        :=       V_JSON.get_string('WRK_ORDR_NO');      -- 실사지시번호
    V_IND_BCD            :=       V_JSON.get_string('IND_BCD');          -- 업체/개별바코드
    V_LOT_NO             :=       V_JSON.get_string('LOT_NO');           -- LOT NO
    V_MATNR              :=       V_JSON.get_string('MATNR');            -- 자재코드
    V_STOR_LOC_CD        :=       V_JSON.get_string('STOR_LOC_CD');      -- 저장위치
    V_STCK_QTY           :=       V_JSON.get_string('STCK_QTY');         -- 재고수량
    V_SIL_QTY            :=       V_JSON.get_string('SIL_QTY');          -- 실사수량
    V_UNIT               :=       V_JSON.get_string('UNIT');             -- 단위
    
    IF P_TYPE = 'LIST' THEN /*업체/개별바코드 조회 리스트*/
           
        V_SQL := ' SELECT I001.MATNR,              --자재코드
                          M001.MATNR_NM,           --자재명
                          I001.IND_BCD,            --개별바코드
                          I001.STOR_LOC_CD,        --저장위치코드
                          M003.STOR_LOC_NM,        --저장위치명
                          I001.LOT_NO,             --LOT NO
                          TO_CHAR(I001.STCK_QTY, ''FM999,999,999,990.09'') AS STCK_QTY,  --재고수량
                          I001.UNIT,               --단위
                          I001.PRFM_DT,             --생산일자
                          TO_CHAR(I001.STCK_QTY, ''FM999,999,999,990.09'') AS SIL_QTY  --실사수량
                    FROM TB_INV001 I001,
                         TB_MAS001 M001,
                         TB_MAS003 M003
                   WHERE I001.WERKS = M001.WERKS(+)
                     AND I001.MATNR = M001.MATNR(+)
                     AND I001.WERKS = M003.WERKS(+)
                     AND I001.STOR_LOC_CD = M003.STOR_LOC_CD(+)
                     AND I001.WERKS = ''' || V_WERKS || '''
                     AND I001.IND_BCD = ''' || V_IND_BCD || ''''; 
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
    ELSIF P_TYPE = 'SAVE' THEN      /* 재고실사 등록*/ 
        
        V_CNT := 1;
        
        SELECT MAX(STOR_LOC_FLG), MAX(MATNR_FLG)
            INTO V_STOR_LOC_FLG, V_MATNR_FLG
          FROM TB_INV015
         WHERE WERKS = V_WERKS
           AND WRK_ORDR_NO = V_WRK_ORDR_NO;
           
        IF NVL(V_STOR_LOC_FLG, 'N') = 'N' THEN
            
            SELECT COUNT(*) INTO V_CNT
              FROM TB_INV015
             WHERE WERKS = V_WERKS
               AND WRK_ORDR_NO = V_WRK_ORDR_NO
               AND STOR_LOC_CD = V_STOR_LOC_CD;
               
            IF V_CNT = 0 THEN
                P_SUCCESS := 'N';
                P_ERR_MSG := V_STOR_LOC_CD || ' 저장위치는 재고실사 대상이 아닙니다.';
                RETURN;
            END IF;
               
        END IF;
        
        IF NVL(V_MATNR_FLG, 'N') = 'N' THEN
            SELECT COUNT(*) INTO V_CNT
              FROM TB_INV015
             WHERE WERKS = V_WERKS
               AND WRK_ORDR_NO = V_WRK_ORDR_NO
               AND MATNR = V_MATNR;
               
            IF V_CNT = 0 THEN
                P_SUCCESS := 'N';
                P_ERR_MSG := V_MATNR || ' 저장위치는 재고실사 대상이 아닙니다.';
                RETURN;
            END IF;
        END IF;
          
       INSERT INTO TB_INV009(WERKS, WRK_ORDR_NO, STOR_LOC_CD, LOT_NO, IND_BCD, MATNR,
                            STCK_QTY, REAL_QTY, REGDATE, REGID)
                    VALUES(V_WERKS, V_WRK_ORDR_NO, V_STOR_LOC_CD, V_LOT_NO, V_IND_BCD, V_MATNR,
                          NVL(V_STCK_QTY, 0), NVL(V_SIL_QTY, 0), 
                          V_DATE, V_SESS_USER_ID);
    END IF;

    P_SUCCESS := 'Y';

    COMMIT;

--    EXCEPTION
--    WHEN E_EXCEPTION_USER THEN
--
--        -- 에러 내역 SET
--	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := SQLCODE;
--        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);
--        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--
--        ROLLBACK;
--
--    WHEN OTHERS THEN
--	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := SQLCODE;
--        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--        ROLLBACK;
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        --RAISE;
END;

/
