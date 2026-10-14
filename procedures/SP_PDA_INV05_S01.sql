
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_PDA_INV05_S01" 
(
    P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
AS 
/*==============================================================================
 * PROGRAM ID    : SP_PDA_INV05_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : PDA 완제품 투입{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 완제품 투입{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 유상호{최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/04 {최초 작성일자 기술}
 * SYSTEM NAME   : PDA
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/04    1.0.0   유상호         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_MAS001] : (.R..) 자재 마스터                                
 *       - [TB_MAS015] : (CRUD) 검사항목별 기준정보 등록 마스트                              
 *       - [TB_MAS016] : (CRUD) 검사항목별 기준값 정보                                
 *=============================================================================*/
    --프로그램 ID
    V_PRG_NM          VARCHAR2(100)  := 'SP_PDA_INV05_S01';     -- PROCEDURE NAME

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
    V_MMATNR           TB_WRK011.MATNR%TYPE;        -- BOM하위자재코드
    V_INMATNR          TB_WRK011.MATNR%TYPE;        -- 투입하위자재코드
    V_MACH_CD          TB_WRK011.MACH_CD%TYPE;      -- 설비코드
    V_IND_BCD          TB_INV001.IND_BCD%TYPE;      -- 업체/개별바코드
    V_PROC_CD          TB_MAS012.PROC_CD%TYPE;      -- 공정코드
    V_WRK_CD           TB_MAS012.WRK_CD%TYPE;        -- 작업장코드
    V_WRK_ORDR_NO      TB_WRK011.WRK_ORDR_NO%TYPE;  -- 작업지시번호
    V_WRK_ORDR_SEQNO   TB_WRK011.WRK_ORDR_SEQNO%TYPE;  -- 작업지시번호 순번
    V_ORDER_NO         TB_WRK011.ORDER_NO%TYPE; 
    V_INPUT_QTY        TB_INV003.IN_QTY%TYPE;           --투입수량
    V_STCK_QTY         TB_INV003.STCK_QTY%TYPE;         --재고수량
    V_SDATE             VARCHAR2(10);
    V_EDATE             VARCHAR2(10);
    V_CHG_BOM           VARCHAR2(10);
    V_DATE              DATE := SYSDATE;
    --V_MAKTX            TB_MAS001.MAKTX%TYPE; -- 자재명

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
    V_PROC_CD            :=       V_JSON.get_string('SES_PROC_CD');                 -- 공정코드
    V_IND_BCD            :=       V_JSON.get_string('IND_BCD');                     -- 업체/개별바코드
    V_WRK_ORDR_NO        :=       V_JSON.get_string('WRK_ORDR_NO');                 -- 작업지시번호
    V_WRK_ORDR_SEQNO     :=       V_JSON.get_string('WRK_ORDR_SEQNO');              -- 작업지시번호 순번
    V_ORDER_NO           :=       V_JSON.get_string('ORDER_NO');                    -- 오더번호
    V_INPUT_QTY          :=       V_JSON.get_string('INPUT_QTY');        -- 투입수량

    IF P_TYPE = 'LIST' THEN /*업체/개별바코드 조회 리스트*/

        V_SQL := 'SELECT I001.MATNR,                     --자재코드
                       M001.MATNR_NM,                   --자재명
                       I001.IND_BCD,                    --개별바코드
                       I001.LOT_NO,                     --LOT NO
                       I001.STOR_LOC_CD,                --저장위치코드
                       I001.STCK_QTY,                    --재고수량
                       I001.UNIT,                       --단위
                       CASE WHEN I001.STCK_STA = ''00'' AND S000.MATNR = I001.MATNR THEN ''투입가능''
                            WHEN I001.STCK_STA = ''00'' AND NVL(S000.MATNR, '' '') <> I001.MATNR THEN ''투입불가(BOM)''
                            WHEN I001.STCK_STA = ''10''  THEN ''투입불가(투입중)''
                            WHEN I001.STCK_STA = ''20''  THEN ''투입불가(생산중)''
                            WHEN I001.STCK_STA = ''30''  THEN ''투입불가(불용재고)''
                            WHEN I001.STCK_STA = ''40''  THEN ''투입불가(보류재고)''
                            WHEN I001.STCK_STA = ''50''  THEN ''투입불가(폐기재고)'' END AS STCK_STA
                  FROM TB_INV001 I001,
                       TB_MAS001 M001,
                       (SELECT S011.MATNR
                          FROM TB_SCH011 S011,
                               TB_SCH001 S001
                         WHERE S011.ORDER_NO = S001.AUFNR(+)'; 

        V_SQL := V_SQL || ' AND S011.WRK_ORDR_NO = ''' || V_WRK_ORDR_NO || '''';                  
        V_SQL := V_SQL || ' AND S011.WRK_ORDR_SEQNO = ''' || V_WRK_ORDR_SEQNO || ''') S000';                  
        V_SQL := V_SQL || ' WHERE I001.WERKS = M001.WERKS(+)
                              AND I001.MATNR = M001.MATNR(+)
                              AND I001.MATNR = S000.MATNR(+)';
        V_SQL := V_SQL || ' AND I001.WERKS = ''' || V_WERKS|| '''';                  
        V_SQL := V_SQL || ' AND I001.IND_BCD = ''' || V_IND_BCD || '''';                  

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

    ELSIF P_TYPE = 'SUB_LIST1' THEN  /* 작업지시 조회(폼 LOAD 시, 작업지시 새로고침)*/
        V_SQL :='SELECT W011.WRK_ORDR_NO        --작업지시번호
                    , W011.WRK_ORDR_SEQNO       --작업지시번호 순번
                    , W011.ORDER_NO             --오더번호
                    , W011.MATNR                --자재코드
                    , M001.MATNR_NM                --자재명
                  FROM TB_WRK011 W011,
                       TB_MAS001 M001
                 WHERE W011.WERKS = M001.WERKS(+)
                   AND W011.MATNR = M001.MATNR(+)';

         IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN 
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;                     

        IF V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN          -- 플랜트
            V_SQL := V_SQL || ' AND W011.WERKS = ''' || V_WERKS || '''';
        END IF;

        IF V_MACH_CD IS NOT NULL OR TRIM(V_MACH_CD) != '' THEN      -- 설비코드
            V_SQL := V_SQL || ' AND W011.MACH_CD = ''' || V_MACH_CD || '''';
        END IF;    

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

    ELSIF P_TYPE = 'SUB_LIST2' THEN  /* 작업지시 조회(팝업)*/

        V_SDATE     := V_JSON.get_string('SDATE');
        V_EDATE     := V_JSON.get_string('EDATE');

        SELECT WRK_CD INTO V_WRK_CD
          FROM TB_MAS012
         WHERE MACH_CD = V_MACH_CD;

        V_SQL := 'SELECT S00.WRK_SEQNO         --작업순서
                    , S00.WRK_ORDR_NO           --작업지시번호
                    , S00.WRK_ORDR_SEQNO        --작업지시번호 순번 
                    , S00.ORDER_NO              --오더번호
                    , S00.MATNR                 --자재코드
                    , M001.MATNR_NM             --자재명
                    , S00.WRK_ORDR_QTY          --생산지시수량(계획수량)
                    , S00.UNIT';                --단위

        IF V_PROC_CD = 'AA' THEN                --화장지 합지기 공정
            V_SQL := V_SQL || ' FROM TB_SCH011 S00,';
        ELSIF V_PROC_CD = 'RA' THEN            --화장지 가공기 공정
            V_SQL := V_SQL || ' FROM TB_SCH012 S00,';
        ELSIF V_PROC_CD = 'RB' THEN            --생리대 가공기 공정
            V_SQL := V_SQL || ' FROM TB_SCH013 S00,';
        ELSIF V_PROC_CD = 'RC' THEN            --기저귀 가공기 공정
            V_SQL := V_SQL || ' FROM TB_SCH014 S00,';
        END IF;

        V_SQL := V_SQL || 'TB_MAS001 M001';            
        V_SQL := V_SQL || ' WHERE S00.WERKS = M001.WERKS(+)
                    AND S00.MATNR = M001.MATNR(+)
                    AND S00.WRK_CD = ''' || V_WRK_CD || '''';

        IF (V_SDATE IS NOT NULL OR TRIM(V_SDATE) != '') AND (V_EDATE IS NOT NULL OR TRIM(V_EDATE) !='') THEN                               
            V_SQL := V_SQL || ' AND S00.ORDR_GEN_DT BETWEEN ''' || V_SDATE || ''' AND ''' || V_EDATE || '''';
        END IF;

        V_SQL := V_SQL || ' ORDER BY S00.PRD_REQ_DT, S00.ORDER_SEQNO'; 

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
    ELSIF P_TYPE = 'SUB_LIST3' THEN  /* 자재투입이력 조회(팝업)*/
        V_SQL :='SELECT I003.MATNR,         --자재코드
                     M001.MATNR_NM,         --자재명
                     I003.IND_BCD,          --업체/개별바코드
                     I003.IN_QTY,           --투입수량
                     I003.USE_QTY,          --사용수량
                     I003.STCK_QTY,         --재고수량
                     I003.UNIT              --단위    
                  FROM TB_INV003 I003,
                       TB_MAS001 M001
                 WHERE I003.WERKS = M001.WERKS(+)
                   AND I003.MATNR = M001.MATNR(+)';
        V_SQL := V_SQL || ' AND I003.WERKS = ''' || V_WERKS || '''
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
    ELSIF P_TYPE = 'SUB_LIST4' THEN  /* BOM 정보 조회*/
        V_SQL :='SELECT S020.MATNR,             --하위자재코드
                        M001.MATNR_NM,          --하위자재명
                        S020.ORDER_BOM_QTY,     --오더BOM 수량     
                        S020.UNIT               --단위          
                   FROM TB_SCH020 S020,
                        TB_MAS001 M001
                  WHERE S020.WERKS = M001.WERKS(+)
                    AND S020.MATNR = M001.MATNR(+)
                    AND WRK_ORDR_NO =''' || V_WRK_ORDR_NO || '''
                    AND WRK_ORDR_SEQNO = ''' || V_WRK_ORDR_SEQNO || '''
                 ORDER BY S020.ORDER_ITM_NO';   
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
    ELSIF P_TYPE = 'SAVE' THEN      /* 자재투입*/
        V_MMATNR              :=       V_JSON.get_string('MMATNR');               -- BOM 하위자재코드
        V_INMATNR             :=       V_JSON.get_string('INMATNR');              -- 투입하위자재코드  

        V_CHG_BOM := 'N';

        IF NVL(V_MMATNR, ' ') <> ' '  THEN 
            V_CHG_BOM := 'Y';

            INSERT INTO TB_SCH020( WRK_ORDR_NO,
                                   WRK_ORDR_SEQNO,
                                   MATNR,
                                   ORDER_NO,
                                   ORDER_ITM_NO,
                                   ORDER_BOM_QTY,
                                   UNIT,
                                   STOR_LOC_CD,
                                   LOT_NO,
                                   CHGFL,
                                   EMPLY_NO,
                                   DLFL,
                                   REGDATE,
                                   REGID)

            SELECT WRK_ORDR_NO,
                   WRK_ORDR_SEQNO,
                   V_MMATNR,
                   ORDER_NO,
                   ORDER_ITM_NO,
                   ORDER_BOM_QTY,
                   UNIT,
                   STOR_LOC_CD,
                   LOT_NO,
                   'Y',
                   V_SESS_USER_ID,
                   DLFL,
                   V_DATE,
                   V_SESS_USER_ID
              FROM TB_SCH020
             WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
               AND MATNR = V_INMATNR;
        END IF;

        BEGIN
        INSERT INTO TB_INV003( WERKS,
                                MACH_CD,
                                MATNR,
                                IND_BCD,
                                WRK_ORDR_NO,
                                WRK_ORDR_SEQNO,
                                SEQNO,
                                INP_DT,     -- 투입일자 추가 2022-06-03
                                IN_QTY,
                                USE_QTY,
                                STCK_QTY,
                                UNIT,
                                CHG_FLG,
                                STCK_KY,
                                LOT_NUM,
                                REGDATE,
                                REGID)
        SELECT I001.WERKS,
            V_MACH_CD,
            I001.MATNR,
            V_IND_BCD,
            V_WRK_ORDR_NO,
            V_WRK_ORDR_SEQNO,
            1,
            TO_CHAR(V_DATE, 'YYYYMMDD'),     -- 투입일자 추가 2022-06-03
            V_INPUT_QTY,
            0,
            V_INPUT_QTY,
            I001.UNIT,
            V_CHG_BOM,
            I001.STCK_KY,
            I001.LOT_NUM,
            V_DATE,
            V_SESS_USER_ID
          FROM TB_INV001 I001
         WHERE I001.WERKS = V_WERKS
           AND I001.IND_BCD = V_IND_BCD;

        --재고 수량 업데이트
        UPDATE TB_INV001 I001
           SET I001.STCK_QTY = I001.STCK_QTY - V_INPUT_QTY
            , I001.STCK_STA = '10'
         WHERE I001.WERKS = V_WERKS
           AND I001.IND_BCD = V_IND_BCD; 

        EXCEPTION           
        WHEN OTHERS THEN 
            P_SUCCESS           := 'N';
            E_SQL_ERR_CD        := SQLCODE;
            E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
            RETURN;           
        END;     
    ELSIF P_TYPE = 'SUB_SAVE1' THEN  /* 자재투입취소*/
        V_ARR_LIST        := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ           := TREAT (V_OBJ.get ('map') AS json_object_t);

            V_MATNR         := V_OBJ.get_string('MATNR');
            V_IND_BCD       := V_OBJ.get_string('IND_BCD');
            V_STCK_QTY      := V_OBJ.get_string('STCK_QTY');

            UPDATE TB_INV001
               SET STCK_QTY = V_STCK_QTY
                , STCK_STA = '00'
                , UPDDATE = V_DATE
             WHERE WERKS = V_WERKS
               AND IND_BCD = V_IND_BCD
               AND MATNR = V_MATNR;

            DELETE
              FROM TB_INV003
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD
               AND MATNR = V_MATNR; 

        END LOOP;

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
