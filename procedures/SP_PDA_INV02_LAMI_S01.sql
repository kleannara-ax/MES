
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_PDA_INV02_LAMI_S01" 
(
    P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    varchar2,
	P_RS_CODE       OUT    varchar2,
    P_RS_MSG        OUT    varchar2,
    P_DOC_NO        OUT    varchar2,
    P_DOC_SEQNO     OUT    NUMBER,
    P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
    as
    /*==============================================================================
 * PROGRAM ID    : PDA_INV02_LAMI{호출 프로그램 ID 기술}
 * PROGRAM NAME  : PDA 자재투입(라미네이팅){호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 자재 투입관리(라미네이팅){프로그램에 대한 상세한 내용 기술}
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
 * 2022/07/27    1.0.1   여한진         작업지시 조회 (팝업) 삭제 오더는 안 보이도록 수정
 * 2022/07/27    1.0.1   여한진         바코드 스캔 시 단종아닌 것만 조회되도록 수정
 * 2022/08/03    1.0.2   여한진         투입자재정보목록 조회수정(해당 작업지시에 자재가 투입됬는지 확인여부판단)
 *==============================================================================
 *  관련 테이블
 *       - [TB_MAS001] : (.R..) 자재 마스터                                
 *       - [TB_MAS015] : (CRUD) 검사항목별 기준정보 등록 마스트                              
 *       - [TB_MAS016] : (CRUD) 검사항목별 기준값 정보                                
 *=============================================================================*/
    --프로그램 ID
    V_PRG_NM          VARCHAR2(100)  := 'SP_PDA_INV02_LAMI_S01';     -- PROCEDURE NAME

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
    V_MATNR_M            TB_WRK011.MATNR%TYPE;        -- 투입자재코드
    V_MMATNR           TB_WRK011.MATNR%TYPE;        -- BOM하위자재코드
    V_INMATNR          TB_WRK011.MATNR%TYPE;        -- 투입하위자재코드
    V_MACH_CD          TB_WRK011.MACH_CD%TYPE;      -- 설비코드
    V_IND_BCD          TB_INV001.IND_BCD%TYPE;      -- 업체/개별바코드
    V_IND_BCD_M        TB_INV001.IND_BCD%TYPE;      -- 업체/개별바코드
    V_IND_BCD_L        TB_INV001.IND_BCD%TYPE;      -- 업체/개별바코드     
    V_PROC_CD          TB_MAS012.PROC_CD%TYPE;      -- 공정코드
    V_WRK_CD           TB_MAS012.WRK_CD%TYPE;        -- 작업장코드
    V_WRK_ORDR_NO      TB_WRK011.WRK_ORDR_NO%TYPE;  -- 작업지시번호
    V_WRK_ORDR_SEQNO   TB_WRK011.WRK_ORDR_SEQNO%TYPE;  -- 작업지시번호 순번
    V_ORDER_NO         TB_WRK011.ORDER_NO%TYPE; 
    V_INPUT_QTY        TB_INV003.IN_QTY%TYPE;           --투입수량
    V_STCK_QTY         TB_INV003.STCK_QTY%TYPE;         --재고수량
    V_LOT_NO           TB_INV001.LOT_NO%TYPE;           --LOT NO
    V_LOT_NO_M           TB_INV001.LOT_NO%TYPE;           --LOT NO
    V_SDATE             VARCHAR2(10);
    V_EDATE             VARCHAR2(10);
    V_CHG_BOM           VARCHAR2(10);
    V_CONTIN_FLG         VARCHAR2(20);
    V_DATE              DATE := SYSDATE;
    V_SEQNO             NUMBER;
    V_DOC_NO            VARCHAR2(20);
    V_DOC_SEQNO         NUMBER;
    V_SAP_WRK_CD        TB_MAS012.SAP_WRK_CD%TYPE;
    V_ORDER_ITM_NO      TB_SCH020.ORDER_ITM_NO%TYPE;
    V_PRFM_DT           VARCHAR2(10);
    V_PRD_DT            VARCHAR2(10);
    V_STOR_LOC_CD_M     VARCHAR2(10);
    V_UNIT              VARCHAR2(10);
    V_CHG_FLG           VARCHAR2(10);
    V_STCK_KY           TB_INV001.STCK_KY%TYPE;
    V_LOT_NUM           TB_INV001.LOT_NUM%TYPE;
    V_USE_QTY           TB_INV010.USE_QTY%TYPE;
    --V_MAKTX            TB_MAS001.MAKTX%TYPE; -- 자재명
    V_MATNR_DIV         TB_MAS001.MATNR_DIV%TYPE;

    V_ROW_COUNT         NUMBER;
    V_SEARCH_FL         VARCHAR2(1);
    V_STOR_LOC_CD       VARCHAR2(10);
    V_CNT               NUMBER;
    V_UNIT_M            TB_INV001.UNIT%TYPE;
    V_LOTA06            VARCHAR2(10);
	V_I_ORDER_ITM_NO	TB_SCH020.ORDER_ITM_NO%TYPE;

    PROD_CUR            SYS_REFCURSOR;		-- 커서 정의
    V_CNT_QTSIQT		NUMBER(10);
    V_STCK_STA			TB_INV001.STCK_STA%TYPE;
    V_IN_MATNR			VARCHAR2(20);

    V_PDOC_NO             TB_INV005.PDOC_NO%TYPE;
    V_INP_DT              VARCHAR2(10);
    V_INP_START_DT        VARCHAR2(10);
    V_INP_END_DT          VARCHAR2(10);

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
    V_MATNR              :=       V_JSON.get_string('MATNR');                       -- 투입자재코드
    V_WRK_ORDR_NO        :=       V_JSON.get_string('WRK_ORDR_NO');                 -- 생산품에 대한 작업지시번호
    V_WRK_ORDR_SEQNO     :=       V_JSON.get_string('WRK_ORDR_SEQNO');              -- 생산품에 대한 작업지시번호 순번
    V_ORDER_NO           :=       V_JSON.get_string('ORDER_NO');                    -- 생산품에 대한 오더번호
    V_INPUT_QTY          :=       REPLACE(V_JSON.get_string('INPUT_QTY'),',');      -- 투입수량
    V_STCK_KY            :=       V_JSON.get_string('STCK_KEY');                    -- WMS 재고키
    V_LOT_NUM            :=       V_JSON.get_string('LOT_NUM');                     -- WMS 로트번호
    V_UNIT               :=       V_JSON.get_string('UNIT');                        -- 단위
    V_LOT_NO             :=       V_JSON.get_string('LOT_NO');                      -- LOT NO
    V_CONTIN_FLG         :=       V_JSON.get_string('CONTIN_FLG');                  -- 연속투입여부 
	V_MMATNR             :=       V_JSON.get_string('MMATNR');               		-- 강제투입일 경우 'Y'
	V_USE_QTY            :=       REPLACE(V_JSON.get_string('USE_QTY'), ',');   	-- 투입하위자재의 소요량 
    V_INP_DT             :=       V_JSON.get_string('INP_DT');   	                -- 투입일자 
    V_INP_START_DT       :=       V_JSON.get_string('START_DT');   	                -- 투입이력조회 시작날짜 
    V_INP_END_DT         :=       V_JSON.get_string('END_DT');   	                -- 투입이력조회 종료날짜

    V_DOC_NO :='';
    V_DOC_SEQNO := 0;
    V_SEARCH_FL := 'Y';

    IF P_TYPE = 'LIST' THEN /*업체/개별바코드 조회 리스트*/
--		BEGIN
--	    	SELECT	MATNR INTO V_IN_MATNR
--	    	FROM	TB_INV001
--	    	WHERE 	IND_BCD = V_IND_BCD;
--        EXCEPTION 
--            WHEN NO_DATA_FOUND THEN
--				SELECT MEASKY INTO V_IN_MATNR FROM WHTRH@KNRAWMSLINK
--				WHERE LOTA14 = V_IND_BCD;
--		END;

        P_RS_CODE := 'S';

        IF V_SEARCH_FL = 'Y' THEN
            V_SQL := 'SELECT 
                           --''          AS STCK_KEY,         --WMS 
                           --''          AS LOT_NUM,          --WMS
                           I001.MATNR,                     --자재코드
                           M001.MATNR_NM,                   --자재명
                           I001.IND_BCD,                    --개별바코드
                           I001.LOT_NO,                     --LOT NO
                           I001.STOR_LOC_CD,                --저장위치코드
                           TO_CHAR(I001.STCK_QTY, ''FM999,999,999,990.099'') STCK_QTY,                   --재고수량
                           I001.UNIT,                       --단위
                           CASE WHEN I001.STCK_STA = ''00'' THEN ''투입가능''

                            END AS STCK_STA
                      FROM TB_INV001 I001,
                           TB_MAS001 M001';

            V_SQL := V_SQL || ' WHERE I001.WERKS = M001.WERKS(+)
                                  AND I001.MATNR = M001.MATNR(+)';
            V_SQL := V_SQL || ' AND I001.WERKS = ''' || V_WERKS|| '''';                  
            V_SQL := V_SQL || ' AND I001.IND_BCD = ''' || V_IND_BCD || '''';                  
--            재고가 없어도 일단 화면에 자재정보띄워주고 투입시에 ALERT 창 처리
--            V_SQL := V_SQL || ' AND I001.STCK_QTY > 0';
            V_SQL := V_SQL || ' AND M001.MATNR_STA IS NULL ';
        END IF;
        INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        BEGIN           
     		OPEN P_RS_LIST FOR V_SQL;

        /*EXCEPTION           
        WHEN OTHERS THEN 
            P_SUCCESS           := 'N';
            E_SQL_ERR_CD        := SQLCODE;
            E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
            RETURN;
            */           
        END;                                
    ELSIF P_TYPE = 'SUB_LIST3' THEN  /* 자재투입이력 조회(팝업)*/

        V_SQL :='SELECT I005.MATNR,         --자재코드
                     M001.MATNR_NM,         --자재명
                     I005.IND_BCD,          --업체/개별바코드
                     TO_CHAR(TO_DATE((I005.INP_DT), ''YYYY-MM-DD''), ''YYYY-MM-DD'') AS INP_DT,           --투입일자
                     I005.INP_QTY,          --투입수량
                     I005.UNIT              --단위
                  FROM TB_INV005 I005,
                       TB_MAS001 M001
                 WHERE I005.WERKS = M001.WERKS(+)
                   AND I005.MATNR = M001.MATNR(+)';
        V_SQL := V_SQL || ' AND I005.WERKS = ''' || V_WERKS || '''
                            AND I005.MACH_CD = ''' || V_MACH_CD || ''' 
                            AND TO_DATE(I005.INP_DT) BETWEEN TO_DATE(''' || V_INP_START_DT || ''') AND TO_DATE(''' || V_INP_END_DT || ''') 
                            order by INP_DT, MATNR, IND_BCD';

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
        V_INMATNR             :=       V_JSON.get_string('INMATNR');              -- 투입하위자재코드  
        V_CHG_BOM := 'N';
        V_PDOC_NO := 'P' || TO_CHAR(V_DATE, 'YYYYMMDDHH24MISS');

		SELECT	NVL(STCK_STA, '00') INTO V_STCK_STA
		FROM		TB_INV001
		WHERE 	WERKS = V_WERKS
		AND 		IND_BCD = V_IND_BCD;

		IF V_STCK_STA = '90'	THEN
		   	P_SUCCESS := 'N';
		    P_RS_CODE := 'E';
		    P_RS_MSG  := V_IND_BCD || ' 개별바코드는 현재 반납 요청 상태이므로 투입이 불가능 합니다.';
		   	ROLLBACK;
		    RETURN;
		END IF;

        BEGIN
            -- 투입자재가 투입하려는 날짜에 존재하면 UPDATE, 존재하지 않으면 INSERT         
            SELECT COUNT(*) INTO  V_CNT
              FROM TB_INV005
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD
               AND INP_DT = REPLACE(V_INP_DT, '-', '');

            IF V_CNT = 0 THEN   
                INSERT INTO TB_INV005(WERKS,
                                      MACH_CD,
                                      PDOC_NO,
                                      INP_DT,
                                      INP_ID,
                                      WRK_SHIFT,
                                      MATNR,
                                      IND_BCD,
                                      LOT_NO,
                                      UNIT,
                                      INP_QTY,
                                      REGDATE,
                                      REGID)
                SELECT I001.WERKS,
                       V_MACH_CD,
                       V_PDOC_NO, --PDOC_NO 
                       REPLACE(V_INP_DT, '-', ''),
                       V_SESS_USER_ID,
                       'A',
                       I001.MATNR,
                       V_IND_BCD,
                       '*',
                       I001.UNIT,
                       TO_NUMBER(V_INPUT_QTY) END,
                       SYSDATE,
                       V_SESS_USER_ID
                  FROM TB_INV001 I001
                 WHERE I001.WERKS = V_WERKS
                   AND I001.IND_BCD = V_IND_BCD
                   AND I001.STCK_QTY > 0;
            ELSE
                UPDATE TB_INV005
                   SET INP_QTY = INP_QTY + TO_NUMBER(V_INPUT_QTY)
                    , UPDDATE = SYSDATE
                    , UPDID = V_SESS_USER_ID
                 WHERE WERKS = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND IND_BCD = V_IND_BCD;  
            END IF;

            --재고 수량 업데이트(STCK_STA 상태update 필요없음)
            UPDATE TB_INV001 I001
               SET I001.STCK_QTY = CASE WHEN I001.STCK_QTY <=0 THEN 0 ELSE I001.STCK_QTY - TO_NUMBER(V_INPUT_QTY) END
--                     , I001.STCK_STA = '10'  
                 , I001.UPDDATE = SYSDATE
                 , I001.UPDID = V_SESS_USER_ID
             WHERE I001.WERKS = V_WERKS
               AND I001.IND_BCD = V_IND_BCD; 
        END;     
    ELSIF P_TYPE = 'SUB_SAVE1' THEN  /* 자재투입취소*/
        V_ARR_LIST        := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ           := TREAT (V_OBJ.get ('map') AS json_object_t);

            V_MATNR         := V_OBJ.get_string('MATNR');
            V_IND_BCD       := V_OBJ.get_string('IND_BCD');
            V_STCK_QTY      := REPLACE(V_OBJ.get_string('INP_QTY'), ',');

            UPDATE TB_INV001
               SET STCK_QTY = STCK_QTY + TO_NUMBER(V_STCK_QTY)
--                , STCK_STA = '00'
                , UPDDATE = V_DATE
             WHERE WERKS = V_WERKS
               AND IND_BCD = V_IND_BCD
               AND MATNR = V_MATNR;

            DELETE
              FROM TB_INV005
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD
               AND MATNR = V_MATNR; 

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
--        RAISE;
END;
/
