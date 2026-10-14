
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_PDA_INV04_S01" 
(
    P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
AS 
/*==============================================================================
 * PROGRAM ID    : SP_PDA_INV04_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : PDA 약품 포장자재 투입{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 약품 포장자재{프로그램에 대한 상세한 내용 기술}
 *
 * AUTHOR NAME   : 박충식{최초 작성자 명 기술}
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
    V_PRG_NM          VARCHAR2(100)  := 'SP_PDA_INV04_S01';     -- PROCEDURE NAME

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
    
    V_MACH_CD          TB_WRK011.MACH_CD%TYPE;      -- 설비코드
    V_IND_BCD          TB_INV001.IND_BCD%TYPE;      -- 업체/개별바코드
    
    V_INPUT_QTY        TB_INV003.IN_QTY%TYPE;           --투입수량
    V_STCK_QTY         TB_INV003.STCK_QTY%TYPE;         --재고수량
    V_INP_DATE          VARCHAR2(10);

    V_WRK_METH           TB_INV005.WRK_SHIFT%TYPE;                -- 작업조
    V_LOT_NO             TB_INV005.LOT_NO%TYPE;                   -- LOT_NO
    V_UNIT               TB_INV005.UNIT%TYPE;                    -- 단위
    
    V_PDOC_NO           TB_INV005.PDOC_NO%TYPE;    
    V_DATE              DATE :=SYSDATE;

BEGIN
    OPEN P_RS_LIST FOR 
    SELECT NULL FROM DUAL WHERE ROWNUM = 0;    

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);
    V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=       V_JSON.get_string('SES_WAREKY');

    /* 조건값 할당 */
    V_WERKS              :=       V_JSON.get_string('WERKS');                       -- 플랜트코드
    V_MACH_CD            :=       V_JSON.get_string('MACH_CD');                     -- 설비코드
    V_IND_BCD            :=       V_JSON.get_string('IND_BCD');                     -- 업체/개별바코드
    V_INPUT_QTY          :=       V_JSON.get_number('INPUT_QTY'); -- 투입수량
    V_INP_DATE           :=       V_JSON.get_string('INP_DATE');                    -- 투입일자
    V_WRK_METH           :=       V_JSON.get_string('WRK_METH');                    -- 작업조
    V_MATNR              :=       V_JSON.get_string('MATNR');                       -- 자재코드
    V_LOT_NO             :=       V_JSON.get_string('LOT_NO');                      -- LOT_NO
    V_UNIT               :=       V_JSON.get_string('UNIT');                        -- 단위

    IF P_TYPE = 'LIST' THEN /*업체/개별바코드 조회 리스트*/

        V_SQL := ' SELECT I001.MATNR                    MATNR            --자재코드
                        ,M001.MATNR_NM                   MATNR_NM        --자재명
                        ,I001.IND_BCD                    IND_BCD         --개별바코드
                        ,I001.LOT_NO                     LOT_NO          --LOT NO
                        ,I001.STOR_LOC_CD                STOR_LOC_CD     --저장위치코드
                        ,TO_CHAR(I001.STCK_QTY, ''FM999,999,999,999'')   STCK_QTY       --재고수량
                        ,I001.UNIT                        UNIT           --단위 
                        ,FN_RECDATE(SYSDATE)    AS INP_DATE              --사용일자   
                  FROM TB_INV001 I001,
                       TB_MAS001 M001 ';

        V_SQL := V_SQL || ' WHERE I001.WERKS = M001.WERKS
                              AND I001.MATNR = M001.MATNR ';
        V_SQL := V_SQL || ' AND I001.WERKS = ''' || V_WERKS|| '''';                  
        V_SQL := V_SQL || ' AND I001.IND_BCD = ''' || V_IND_BCD || ''' ';
        V_SQL := V_SQL || ' AND I001.STCK_QTY > 0 ';
        V_SQL := V_SQL || ' AND M001.MATNR_DIV = ''ROH6'' ';

        BEGIN           
     		OPEN P_RS_LIST FOR V_SQL;

        EXCEPTION           
        WHEN OTHERS THEN 
            P_SUCCESS           := 'N';
            E_SQL_ERR_CD        := SQLCODE;
            E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
            --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
            RAISE;
            RETURN;           
        END;        

    ELSIF P_TYPE = 'SUB_LIST' THEN  /* 작업조 선택*/
        V_SQL :='SELECT MAS027.WRK_METH                           WRK_METH    --작업조   
                    , FN_CD_VAL(''WRKMETH'', MAS027.WRK_METH)   WRK_METH_NM --작업조명   
                    , MAS027.STR_TM                             STR_TM      --시작시간    
                    , MAS027.END_TM                             END_TM      --종료시간
                  FROM TB_MAS027 MAS027
                 WHERE 1=1 ';

        IF V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN          -- 플랜트
            V_SQL := V_SQL || ' AND MAS027.WERKS = ''' || V_WERKS || '''';
        END IF;

        IF V_MACH_CD IS NOT NULL OR TRIM(V_MACH_CD) != '' THEN      -- 설비코드
            V_SQL := V_SQL || ' AND MAS027.MACH_CD = ''' || V_MACH_CD || '''';
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

    
    ELSIF P_TYPE = 'SUB_LIST3' THEN  /* 자재투입이력 조회 */
        V_SQL :='SELECT I005.WERKS                     --플랜트(보이지 않음)
                      , I005.MACH_CD                   --설비코드(보이지 않음) 
                      , I005.PDOC_NO                   --문서번호 (보이지 않음)
                      , I005.REGDATE                   --투입일시 
                      , I005.MATNR     MATNR           --자재코드
                      ,  M001.MATNR_NM  MATNR_NM        --자재명
                      ,  TO_CHAR(I005.INP_QTY, ''FM999,999,999,999'')  AS INP_QTY         --사용수량
                      ,  TO_CHAR(I001.STCK_QTY, ''FM999,999,999,999'')  AS STCK_QTY        --재고수량
                      ,  I005.UNIT      UNIT            --단위 
                      ,  I005.IND_BCD   IND_BCD         --업체/개별바코드
                      ,  I005.LOT_NO	LOT_NO          --LOT NO
                      ,  WRK_SHIFT	    WRK_SHIFT       --작업조(보이지않음)
                  FROM TB_INV005 I005,
                       TB_INV001 I001,
                       TB_MAS001 M001
                 WHERE I005.WERKS = I001.WERKS(+)
                   AND I005.IND_BCD = I001.IND_BCD(+)
                   AND I005.WERKS = M001.WERKS(+)
                   AND I005.MATNR = M001.MATNR(+)';
        
        V_SQL := V_SQL || ' AND I005.WERKS = ''' || V_WERKS || '''
                            AND I005.MACH_CD = ''' || V_MACH_CD || '''
                            AND I005.INP_DT = '''  || V_INP_DATE || '''
                            AND I005.WRK_SHIFT = '''  || V_WRK_METH || '''';

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
        
        V_PDOC_NO := 'P' || TO_CHAR(V_DATE, 'YYYYMMDDHH24MISS');
        
        INSERT INTO TB_INV005 (  
                         WERKS	            --플랜트
                        ,MACH_CD	        --설비코드
                        ,PDOC_NO
                        ,INP_DT	            --투입일자(YYYYMMDD)
                        ,INP_ID	            --투입자ID
                        ,WRK_SHIFT	        --작업조
                        ,MATNR	            --자재코드
                        ,IND_BCD	        --업체/개별바코드
                        ,LOT_NO	            --LOT NO
                        ,UNIT	            --단위
                        ,INP_QTY	        --투입량
                        ,REGDATE	        --등록일시
                        ,REGID	            --등록자ID
                        ,UPDDATE	        --수정일시
                        ,UPDID	            --수정자ID
              )
             VALUES 
             (
                          V_WERKS	            --플랜트
                        , V_MACH_CD	            --설비코드
                        , V_PDOC_NO
                        , V_INP_DATE	        --투입일자(YYYYMMDD)
                        , V_SESS_USER_ID	    --투입자ID
                        , V_WRK_METH	        --작업조
                        , V_MATNR	            --자재코드
                        , V_IND_BCD	            --업체/개별바코드
                        , NVL(TRIM(V_LOT_NO), '*')	            --LOT NO
                        , V_UNIT	            --단위
                        , V_INPUT_QTY	        --투입량
                        , SYSDATE	            --등록일시
                        , V_SESS_USER_ID	    --등록자ID
                        , NULL	                --수정일시
                        , NULL	                --수정자ID             
             )
             ;
      

      BEGIN
        --재고 수량 업데이트
        UPDATE TB_INV001 I001
           SET I001.STCK_QTY = I001.STCK_QTY - V_INPUT_QTY
            , I001.STCK_STA = '00'
         WHERE I001.WERKS   = V_WERKS
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

            V_WERKS              :=       V_OBJ.get_string('WERKS');                       -- 플랜트코드
            V_MACH_CD            :=       V_OBJ.get_string('MACH_CD');                     -- 설비코드
            V_PDOC_NO            :=       V_OBJ.get_string('PDOC_NO');                     -- 문서번호
            V_IND_BCD            :=       V_OBJ.get_string('IND_BCD');                     -- 업체/개별바코드
            V_INPUT_QTY          :=       REPLACE(V_OBJ.get_string('INP_QTY'),',');        -- 투입수량
            --V_INP_DATE           :=       V_OBJ.get_string('INP_DT');                    -- 투입일자
            --V_WRK_METH           :=       V_OBJ.get_string('WRK_SHIFT');                 -- 작업조
            V_MATNR              :=       V_OBJ.get_string('MATNR');                       -- 자재코드
            V_LOT_NO             :=       V_OBJ.get_string('LOT_NO');                      -- LOT_NO

            UPDATE TB_INV001
               SET STCK_QTY = STCK_QTY + TO_NUMBER(V_INPUT_QTY)
                , STCK_STA = '00'
                , UPDDATE = V_DATE
                , UPDID	  = V_SESS_USER_ID 
             WHERE WERKS = V_WERKS
               AND IND_BCD = V_IND_BCD
               AND MATNR = V_MATNR
               ;

           DELETE FROM  TB_INV005
            WHERE WERKS	     =  V_WERKS         --플랜트
              AND MACH_CD	 =  V_MACH_CD       --설비코드
              AND PDOC_NO    =  V_PDOC_NO        --문서번호
             ;

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
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE ;
END;
/
