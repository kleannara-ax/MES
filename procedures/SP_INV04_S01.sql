
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_INV04_S01" (
	P_TYPE           IN    varchar2, -- LIST, SUB_LIST
	P_JSON_STR       IN    CLOB ,
	P_SUCCESS       OUT    varchar2,
	P_ERR_MSG       OUT    VARCHAR2, 
    P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : INV04{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 투입자재 이력조회{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 투입자재 이력을 관리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 여한진{최초 작성자 명 기술}
 * CREATE DATE   : 2022/06/13 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   여한진         Initial Version 
 *==============================================================================
 *  관련 테이블
 *      - [TB_INV003] : (.R..) 자재투입
 *      - [TB_INV010] : (.R..) 자재투입이력
 *      - [TB_MAS012] : (.R..) 설비 마스터
 *      - [TB_MAS001] : (.R..) 자재
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_INV04_S01';     -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);


   -- V_RTN_CLOB       CLOB;
   -- V_RTN_CURSOR     SYS_REFCURSOR;
   -- V_ERROR          CLOB;


    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_OBJECT_T;
    V_OBJ            JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(4);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS			TB_INV003.WERKS%TYPE;
    V_MACH_CD       TB_INV003.MACH_CD%TYPE;
    V_MATNR 		TB_INV003.MATNR%TYPE;
    V_IND_BCD       TB_INV003.IND_BCD%TYPE;
    V_IND_BCD_U     TB_INV003.IND_BCD%TYPE;

    V_SDATE         VARCHAR2(8);
    V_EDATE         VARCHAR2(8);
    V_SEQNO         TB_INV003.SEQNO%TYPE;

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역
    V_ADJST_REST_QTY    TB_INV003.STCK_QTY%TYPE;
    V_STCK_QTY          TB_INV003.STCK_QTY%TYPE; 
    V_DIF_QTY           TB_INV003.STCK_QTY%TYPE; 
    V_DATE              DATE := SYSDATE;
BEGIN

    OPEN P_RS_LIST FOR 
    SELECT NULL FROM DUAL WHERE ROWNUM = 0;

    V_DEBUG := 'N';
    V_RUN_SQL := 'Y';

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

    V_SESS_USER_ID       :=      V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=      V_JSON.get_string('SES_PLNTKY');

    /* 조건값 할당 */
    V_RANGE_SQL         :=      V_JSON.get_string('RANGE_SQL');
    V_WERKS		        :=      V_JSON.get_string('WERKS');     --플랜트
    V_MACH_CD           :=      V_JSON.get_string('MACH_CD');   --설비코드
    V_MATNR             :=      V_JSON.get_string('MATNR');     --자재코드
    V_IND_BCD             :=      V_JSON.get_string('IND_BCD');     --자재코드
    V_SDATE             :=      V_JSON.get_string('SDATE');
    V_EDATE             :=      V_JSON.get_string('EDATE');

    IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

        V_SQL := ' SELECT I000.WERKS,      --플랜트
                          I000.MACH_CD,    --설비코드
                          M012.MACH_NM,    --설비명
                          I000.MATNR,      --자재코드
                          M001.MATNR_NM,   --자재명
                          I000.IND_BCD,    --개별 바코드
                          I000.SEQNO,      --순번
                          I000.INP_DT,     --투입일자
                          I000.IN_QTY   INP_QTY,       --투입량
                          ''''     ADJST_REST_QTY,     --잔량조정량
                          I000.STCK_QTY    REST_QTY,   --잔량
                          FN_CD_VAL(''UNIT'', I000.UNIT) UNIT,   --단위
                          I000.REGDATE,     --등록일시
                          (SELECT NMLAST FROM USRMA WHERE USERID = I000.REGID) REGNM,   --등록자
                          I000.UPDDATE,     --수정일시 
                          (SELECT NMLAST FROM USRMA WHERE USERID = I000.UPDID) UPDNM    --수정자 
                     FROM TB_INV003 I000,  --자재투입
                          TB_MAS012 M012,  --설비 마스터
                          TB_MAS001 M001   --자재
                    WHERE I000.MACH_CD = M012.MACH_CD(+)
                      AND I000.WERKS = M001.WERKS(+)
                      AND I000.MATNR = M001.MATNR(+)
					  AND I000.STCK_QTY > 0 ' ;

        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN  
        	--V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'WERKS', 'I000.WERKS');				--플랜트
        	V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MACH_CD', 'I000.MACH_CD');	--설비코드
        	V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MATNR', 'I000.MATNR');				--자재코드
        	V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'IND_BCD', 'I000.IND_BCD');		--개별 바코드
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;

        IF V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN     --플랜트
            V_SQL := V_SQL || ' AND I000.WERKS = ''' || V_WERKS || ''' ';        
        END IF;
        
        /*IF  V_IND_BCD IS NOT NULL OR TRIM(V_IND_BCD) != '' THEN
            V_SQL := V_SQL || ' AND I000.IND_BCD LIKE ''%' || V_IND_BCD || '%''';        
        END IF;
        
        IF  V_MACH_CD IS NOT NULL OR TRIM(V_MACH_CD) != '' THEN
            V_SQL := V_SQL || ' AND I000.MACH_CD LIKE ''%' || V_MACH_CD || '%''';        
        END IF;*/
        
       	V_SQL := V_SQL || ' ORDER BY I000.WERKS, I000.MACH_CD, I000.INP_DT, I000.REGDATE ';

		OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SUB_LIST' THEN  /* 하부 상세 조회 리스트*/
        V_ARR_HEAD      := TREAT(V_JSON.get ('list') AS json_object_t);
        V_OBJ           := TREAT(V_ARR_HEAD.get ('map') AS json_object_t);

        V_WERKS             :=  V_OBJ.get_string('WERKS');
        V_MACH_CD           :=  V_OBJ.get_string('MACH_CD');
        V_MATNR             :=  V_OBJ.get_string('MATNR');          --투입자재코드
        V_IND_BCD             :=  V_OBJ.get_string('IND_BCD');      --투입자재 개별바코드
        --V_INP_DT             :=  V_OBJ.get_string('INP_DT');        --투입일자

        V_SQL := ' SELECT I000.WERKS,      --플랜트
                          I000.PRFM_DT     INP_DT,     --투입일자
                          (SELECT NMLAST FROM USRMA WHERE USERID = I000.REGID) INP_NM,   --투입자
                          I000.MACH_CD,    --설비코드
                          M012.MACH_NM,    --설비명
                          I000.MATNR,      --자재코드
                          M001.MATNR_NM,   --자재명
                          I000.IND_BCD,    --개별 바코드
                          I000.MATNR_M     IN_MATNR,       --투입자재코드
                          M002.MATNR_NM    IN_MATNR_NM,    --투입자재명
                          I000.IND_BCD_M   INP_IND_BCD,    --개별 바코드
                          I000.SEQNO,      --순번
                          I000.USE_QTY,    --사용량
                          FN_CD_VAL(''UNIT'', I000.UNIT) UNIT,   --단위
                          I000.USE_DIV,     --구분(그리드에 보이지 않아도됨)
                          CASE WHEN I000.USE_DIV = ''1'' THEN '''' ELSE ''사용량 보정'' END USE_DIV_NM,   --자재사용량 보정  
                          I000.REGDATE,     --등록일시
                          (SELECT NMLAST FROM USRMA WHERE USERID = I000.REGID) REGNM,   --등록자
                          I000.UPDDATE,     --수정일시 
                          (SELECT NMLAST FROM USRMA WHERE USERID = I000.UPDID) UPDNM   --수정자 
                     FROM TB_INV010 I000,  --자재투입이력
                          TB_MAS012 M012,  --설비 마스터
                          TB_MAS001 M001,  --자재
                          TB_MAS001 M002   --자재
                    WHERE I000.MACH_CD = M012.MACH_CD(+)
                      AND I000.WERKS = M001.WERKS(+)
                      AND I000.MATNR = M001.MATNR(+)
                      AND I000.WERKS = M002.WERKS(+)
                      AND I000.MATNR_M = M002.MATNR(+) ';

--        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN  --설비(작업장)코드, 투입일자, 자재코드
--            V_SQL := V_SQL || V_RANGE_SQL;
--        END IF;

        IF V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN     --플랜트
            V_SQL := V_SQL || ' AND I000.WERKS = ''' || V_WERKS || '''';        
        END IF;

        IF V_MACH_CD IS NOT NULL OR TRIM(V_MACH_CD) != '' THEN     --설비코드
            V_SQL := V_SQL || ' AND I000.MACH_CD = ''' || V_MACH_CD || '''';        
        END IF;

        IF V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN     --투입자재코드
            V_SQL := V_SQL || ' AND I000.MATNR_M = ''' || V_MATNR || '''';        
        END IF;

        IF V_IND_BCD IS NOT NULL OR TRIM(V_IND_BCD) != '' THEN     --투입자재코드
            V_SQL := V_SQL || ' AND I000.IND_BCD_M = ''' || V_IND_BCD || '''';        
        END IF;


        V_SQL := V_SQL || '  AND NVL(I000.CNL_YN, ''N'') = ''N''
                          ORDER BY I000.INP_DT, I000.WERKS, I000.MACH_CD, I000.REGDATE ';

        OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SAVE' THEN    --잔량조정  

        V_ARR_LIST      := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP

            V_OBJ           := TREAT(V_ARR_LIST.get (i) AS json_object_t); 
            V_OBJ           := TREAT(V_OBJ.get ('map') AS json_object_t);

            V_WERKS             :=  V_OBJ.get_string('WERKS');
            V_MACH_CD           :=  V_OBJ.get_string('MACH_CD');
            V_MATNR             :=  V_OBJ.get_string('MATNR');          --투입자재코드
            V_IND_BCD           :=  V_OBJ.get_string('IND_BCD');        --투입자재 바코드
            --V_SEQNO             :=  V_OBJ.get_string('SEQNO');
            V_ADJST_REST_QTY    :=  V_OBJ.get_number('ADJST_REST_QTY');     --잔량조정량
            V_STCK_QTY          :=  V_OBJ.get_number('REST_QTY');       --잔량

            IF V_OBJ.get_string('GRowState') = 'U' THEN
                --IF NVL(V_ADJST_REST_QTY, 0) <> 0 THEN
                   DBMS_OUTPUT.PUT_LINE ('V_WERKS : ' || V_WERKS);
                   DBMS_OUTPUT.PUT_LINE ('V_MACH_CD : ' || V_MACH_CD);
                   DBMS_OUTPUT.PUT_LINE ('V_IND_BCD : ' || V_IND_BCD);
                   DBMS_OUTPUT.PUT_LINE ('V_MATNR : ' || V_MATNR);
                   DBMS_OUTPUT.PUT_LINE ('=====================================================================');
                    BEGIN
                       SELECT IND_BCD INTO V_IND_BCD_U
                         FROM TB_INV010
                         WHERE WERKS   = V_WERKS
                           AND MACH_CD = V_MACH_CD
                           AND IND_BCD_M = V_IND_BCD
                           AND MATNR_M   = V_MATNR
                           AND ROWNUM = 1
                        ORDER BY REGDATE DESC;
                   EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            V_IND_BCD_U := ' ';
                   END;
                   DBMS_OUTPUT.PUT_LINE ('V_IND_BCD_U11 : ' || V_IND_BCD_U);

                   IF NVL(V_IND_BCD_U, ' ') = ' ' THEN
                        P_SUCCESS := 'N';
                        P_ERR_MSG := '투입이력이 있는 자재만 잔량을 조정할 수 있습니다.';
                        ROLLBACK;
                        RETURN;
                   END IF;
                    --V_STCK_QTY > V_ADJST_REST_QTY = +값
                    --V_STCK_QTY < V_ADJST_REST_QTY = -값
                    V_DIF_QTY := V_STCK_QTY - V_ADJST_REST_QTY;  

                    UPDATE TB_INV003
                       SET STCK_QTY = V_ADJST_REST_QTY,
                           USE_QTY = USE_QTY + V_DIF_QTY,
                           UPDDATE = SYSDATE,
                           UPDID   = V_SESS_USER_ID
                     WHERE WERKS   = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND MATNR   = V_MATNR
                       AND IND_BCD = V_IND_BCD;

                   SELECT MAX(SEQNO) INTO V_SEQNO
                     FROM TB_INV010
                    WHERE WERKS = V_WERKS
                      AND MACH_CD = V_MACH_CD
                      AND IND_BCD = V_IND_BCD_U;

                    V_SEQNO := V_SEQNO + 1;
                   
                   DBMS_OUTPUT.PUT_LINE ('V_WERKS : ' || V_WERKS);
                   DBMS_OUTPUT.PUT_LINE ('V_MACH_CD : ' || V_MACH_CD);
                   DBMS_OUTPUT.PUT_LINE ('V_IND_BCD_U : ' || V_IND_BCD_U);
                   DBMS_OUTPUT.PUT_LINE ('V_IND_BCD : ' || V_IND_BCD);
                   DBMS_OUTPUT.PUT_LINE ('V_MATNR : ' || V_MATNR);
                   DBMS_OUTPUT.PUT_LINE ('V_SEQNO : ' || TO_CHAR(V_SEQNO));

                    INSERT INTO TB_INV010(WERKS, MACH_CD, MATNR, IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO, 
                                            LOT_NO, IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, PRFM_DT, USE_QTY, UNIT,
                                            CHG_FLG, STCK_KY, LOT_NUM, REGDATE, REGID, USE_DIV, CNL_YN, CNL_RMK)
                                SELECT WERKS, MACH_CD, MATNR, IND_BCD, V_SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO, 
                                        LOT_NO, IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, PRFM_DT, V_DIF_QTY, UNIT,
                                        CHG_FLG, STCK_KY, LOT_NUM, V_DATE, V_SESS_USER_ID, '2', 'N', ''
                                  FROM TB_INV010
                                 WHERE WERKS   = V_WERKS
                                   AND MACH_CD = V_MACH_CD
                                   AND IND_BCD_M = V_IND_BCD
                                   AND MATNR_M   = V_MATNR
                                   AND ROWNUM = 1
                                ORDER BY REGDATE DESC;   
                --END IF;
            END IF;

        END LOOP;

    ELSIF P_TYPE = 'SUB_SAVE' THEN  

        RETURN;

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
--
--        ROLLBACK;
--        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--
--    WHEN OTHERS THEN
--	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := -20990;
--        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--        ROLLBACK;
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
