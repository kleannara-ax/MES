--------------------------------------------------------
--  DDL for Procedure SP_PDA_INV07_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_PDA_INV07_S01" 
(
    P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
AS 
/*==============================================================================
 * PROGRAM ID    : SP_PDA_INV07_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : PDA 일마감 - 자재보정
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 설비에 투입된 자재의 잔량을 보정한다.
 *                 
 * AUTHOR NAME   : 유상호{최초 작성자 명 기술}
 * CREATE DATE   : 2022/08/06 {최초 작성일자 기술}
 * SYSTEM NAME   : PDA
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/08/06    1.0.0   유상호         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_MAS001] : (.R..) 자재 마스터                                
 *       - [TB_MAS015] : (CRUD) 검사항목별 기준정보 등록 마스트                              
 *       - [TB_MAS016] : (CRUD) 검사항목별 기준값 정보                                
 *=============================================================================*/
    --프로그램 ID
    V_PRG_NM          VARCHAR2(100)  := 'SP_PDA_INV07_S01';     -- PROCEDURE NAME

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
    V_WERKS            TB_WRK011.WERKS%TYPE;        -- 플랜트코드
    V_MATNR            TB_WRK011.MATNR%TYPE;        -- 자재코드
    V_MACH_CD          TB_WRK011.MACH_CD%TYPE;      -- 설비코드
    V_IND_BCD          TB_INV001.IND_BCD%TYPE;      -- 업체/개별바코드
    V_CHG_QTY          TB_INV003.IN_QTY%TYPE;       --보정수량
    V_STCK_QTY         TB_INV003.STCK_QTY%TYPE;     --재고수량
    V_USE_QTY          TB_INV003.STCK_QTY%TYPE;     --사용량(재고수량 - 보정수량)
    V_UNIT             TB_INV003.UNIT%TYPE;         --단위
    V_INP_DT           TB_INV003.INP_DT%TYPE;         --단위 
    V_STCK_KY           TB_INV003.STCK_KY%TYPE;         --WMS 속성키
    V_LOT_NUM           TB_INV003.LOT_NUM%TYPE;         --WMS LOT속성키
    V_PRFM_DT           TB_INV010.PRFM_DT%TYPE;         --WMS LOT속성키
    V_LOT_NO            TB_INV010.LOT_NO_M%TYPE;        --투입자재 LOT NO        
    V_WRK_ORDR_NO       TB_INV003.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO    TB_INV003.WRK_ORDR_SEQNO%TYPE;
    V_IND_BCD_PRE       TB_INV010.IND_BCD%TYPE;
    V_SEQNO             TB_INV010.SEQNO%TYPE;
    V_DATE              DATE := SYSDATE;

BEGIN
    OPEN P_RS_LIST FOR 
    SELECT NULL FROM DUAL WHERE ROWNUM = 0;    

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);
    V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=       V_JSON.get_string('SES_WAREKY');

    /* 조건값 할당 */
    V_RANGE_SQL          :=       V_JSON.get_string('RANGE_SQL');                   -- 작업지시 조회 시 일자

    V_WERKS              :=       V_JSON.get_string('WERKS');                       -- 플랜트코드
    V_MACH_CD            :=       V_JSON.get_string('MACH_CD');                     -- 설비코드
    V_PRFM_DT            :=       V_JSON.get_string('PRFM_DT');                     -- 실적일자

    IF P_TYPE = 'LIST' THEN /* 투입된 자재 리스트 조회*/

        V_SQL := ' SELECT I003.MATNR,       --자재코드
                        M001.MATNR_NM,      --자재명
                        I003.IND_BCD,       --개별바코드(보이지 않아도됨)
                        I003.LOT_NO,        --LOT NO
                        I003.STCK_QTY,      --잔량
                        I003.UNIT,          --단위
                        ''''    AS CHG_QTY,  --보정수량
                        I003.WRK_ORDR_NO,    --작업지시번호(보이지 않아도됨)   
                        I003.WRK_ORDR_SEQNO, --작업지시순번(보이지 않아도됨)   
                        I003.STCK_KY,        --WMS 속성 키(보이지 않아도됨)   
                        I003.LOT_NUM         --WMS LOT속성키(보이지 않아도됨)   
                      FROM TB_INV003 I003,
                           TB_MAS001 M001
                     WHERE I003.WERKS = M001.WERKS(+)
                       AND I003.MATNR = M001.MATNR(+) 
                       AND I003.WERKS = ''' || V_WERKS || '''
                       AND I003.MACH_CD = ''' || V_MACH_CD || '''';
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
    ELSIF P_TYPE = 'LIST2' THEN      /*실적일자 조회*/    
        V_SQL := ' SELECT FN_RECDATE(SYSDATE) AS DT FROM DUAL';

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

    ELSIF P_TYPE = 'SAVE' THEN      /*등록 - 자재잔량 보정*/
        V_ARR_LIST        := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ           := TREAT (V_OBJ.get ('map') AS json_object_t);

            V_MATNR             := V_OBJ.get_string('MATNR');
            V_IND_BCD           := V_OBJ.get_string('IND_BCD');
            V_LOT_NO            := V_OBJ.get_string('LOT_NO');      
            V_STCK_QTY          := V_OBJ.get_string('STCK_QTY');
            V_UNIT              := V_OBJ.get_string('UNIT');
            V_CHG_QTY           := V_OBJ.get_string('CHG_QTY');
            V_WRK_ORDR_NO       := V_OBJ.get_string('WRK_ORDR_NO');
            V_WRK_ORDR_SEQNO    := V_OBJ.get_string('WRK_ORDR_SEQNO');

            IF NVL(V_CHG_QTY, 0) > 0 THEN
                V_USE_QTY := NVL(V_STCK_QTY, 0) - NVL(V_CHG_QTY, 0);

                V_INP_DT := TO_CHAR(V_DATE, 'YYYYMMDD');
                
                SELECT  A.IND_BCD INTO V_IND_BCD_PRE
                  FROM(
                        SELECT IND_BCD
                          FROM TB_INV010
                         WHERE WERKS = V_WERKS
                           AND MACH_CD = V_MACH_CD
                           AND MATNR_M = V_MATNR
                           AND WRK_ORDR_NO = V_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO 
                         ORDER BY REGDATE DESC ) A
                   WHERE ROWNUM = 1;
                   
                 BEGIN
                 SELECT MAX(NVL(SEQNO, 0)) INTO V_SEQNO
                   FROM TB_INV010
                 WHERE WERKS = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   --AND MATNR_M = V_MATNR
                   AND WRK_ORDR_NO = V_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                   AND IND_BCD = V_IND_BCD_PRE;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_SEQNO := 0;
                END ;
                V_SEQNO := V_SEQNO + 1;
                
                INSERT INTO TB_INV010( WERKS, MACH_CD, MATNR, IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                       LOT_NO, IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, PRFM_DT, USE_QTY, UNIT,
                                       STCK_KY, LOT_NUM, REGDATE, REGID, USE_DIV, CNL_YN)

                SELECT WERKS, MACH_CD, MATNR, IND_BCD, V_SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                       LOT_NO, V_IND_BCD, V_LOT_NO, V_MATNR, V_INP_DT, V_PRFM_DT, V_USE_QTY, V_UNIT,
                       V_STCK_KY, V_LOT_NUM, V_DATE, V_SESS_USER_ID, '2', 'N'
                  FROM TB_INV010
                 WHERE WERKS = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND MATNR_M = V_MATNR
                   AND WRK_ORDR_NO = V_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                   AND IND_BCD = V_IND_BCD_PRE;
                

                UPDATE TB_INV003
                   SET USE_QTY = USE_QTY + V_USE_QTY,
                       STCK_QTY = STCK_QTY - V_USE_QTY,
                       UPDDATE = V_DATE,
                       UPDID = V_SESS_USER_ID
                 WHERE WERKS = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND IND_BCD = V_IND_BCD;

            END IF;
        END LOOP;    
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
END;

/
