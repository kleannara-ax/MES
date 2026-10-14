
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_INV06_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN VARCHAR2,--IN    CLOB,
	P_SUCCESS       OUT    varchar2,
    P_ERR_MSG       OUT     VARCHAR2,
    P_DOC_NO1       OUT     VARCHAR2,       --생산오더별 자재투입 취소 문서번호
    P_DOC_NO2       OUT     VARCHAR2,       --생산오더별 자재투입 실적 문서번호    
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_INV06_S01
 * PROGRAM NAME  : 일마감 확정
 * VERSION       : 1.0.0
 * DESCRIPTION   : 일마감 확정 를 관리한다.
 *                 
 * AUTHOR NAME   : 박충식
 * CREATE DATE   : 2022/05/27
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/02    1.0.0   박충식         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_WRK001] : (CRUD) 실적테이블(HL) 정보
 *        - [TB_WRK002] : (CRUD) 실적테이블(PS) 정보
 * *      
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_INV06_S01';     -- PROCEDURE NAME

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
    V_CLOSE          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(10);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS			TB_SCH008.WERKS%TYPE;		--플랜트
    V_SDATE                 VARCHAR2(10);
    V_EDATE                 VARCHAR2(10);
    V_MACH_CD	            TB_INV013.MACH_CD%TYPE;	                    
    V_MATNR		            TB_INV010.MATNR%TYPE;
    V_MATNR_M		        TB_INV010.MATNR_M%TYPE;
    V_DOC_NO                TB_INV010.DOC_NO%TYPE;
    V_DOC_SEQNO             TB_INV010.DOC_SEQNO%TYPE;
    V_SDOC_NO               TB_INV010.SDOC_NO%TYPE;
    V_SDOC_SEQNO            TB_INV010.SDOC_SEQNO%TYPE;
--    V_LOT_NO		        TB_INV013.LOT_NO%TYPE;
--    V_USE_QTY	            TB_INV013.USE_QTY%TYPE;
--    V_UNIT	                TB_INV013.UNIT%TYPE;
    V_PROC_CD               TB_MAS012.PROC_CD%TYPE;
    V_WRK_ORDR_NO   TB_INV010.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO   TB_INV010.WRK_ORDR_SEQNO%TYPE;
    V_ORDER_NO      VARCHAR2(10);
    V_PRFM_DT       TB_INV010.PRFM_DT%TYPE;
    V_LOT_NO        TB_INV010.LOT_NO%TYPE;    
    V_LOT_NO_M      TB_INV010.LOT_NO_M%TYPE;    
    V_IND_BCD       TB_INV010.IND_BCD%TYPE;    
    V_IND_BCD_M     TB_INV010.IND_BCD_M%TYPE;    
    V_USE_QTY       TB_INV010.USE_QTY%TYPE; 
    V_USE_CHG_QTY   TB_INV010.USE_QTY%TYPE; 
    V_USE_QTY_P     TB_INV010.USE_QTY%TYPE; 
    V_USE_QTY_C     TB_INV010.USE_QTY%TYPE; 
    V_STCK_QTY      TB_INV003.STCK_QTY%TYPE; 
    V_STCK_QTY_PRE  TB_INV003.STCK_QTY%TYPE; 
    V_REM_QTY       TB_INV003.STCK_QTY%TYPE; 
    V_CHG_QTY       TB_INV010.USE_QTY%TYPE;    
    V_UNIT          TB_INV010.UNIT%TYPE;
    V_CNT           NUMBER;
    V_DATE          DATE := SYSDATE; 
    PROD_CUR        SYS_REFCURSOR;		-- 커서 정의

    V_DOC_NO_1      VARCHAR2(20);
    V_DOC_SEQNO_1   NUMBER;
    V_DOC_NO_2      VARCHAR2(20);
    V_DOC_SEQNO_2   NUMBER;

    V_SAP_WRK_CD    TB_MAS012.SAP_WRK_CD%TYPE;
    V_STOR_LOC_CD   TB_INV001.STOR_LOC_CD%TYPE;
    V_M_SEQNO       TB_INV010.SEQNO%TYPE;
    V_IND_BCD_L     TB_INV010.IND_BCD%TYPE;

    V_MACHINE		VARCHAR2(10);

BEGIN
   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'N';
   V_RUN_SQL := 'Y';

   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=       V_JSON.get_string('SES_PLNTKY');

   /* 조건값 할당 */
   V_WERKS          	:=       V_JSON.get_string('WERKS');	    --플랜트
   --V_RANGE_SQL 		    :=       V_JSON.get_string('RANGE_SQL');   	--생산일자
   V_SDATE              :=       V_JSON.get_string('SDATE');		--시작일자
   V_EDATE              :=       V_JSON.get_string('EDATE');		--종료일자
   V_MATNR			    :=       V_JSON.get_string('MATNR');		--자재코드
   V_PROC_CD            :=       V_JSON.get_string('PROC_CD');		--공정코드
   V_CLOSE		    	:=       V_JSON.get_string('CLOSE');		--일마감(1),월마감(2)
   V_MACHINE			:=		 V_JSON.get_string('MACHINE');		--생산호기

    IF P_TYPE = 'LIST' THEN /*왼쪽 그리드 조회*/
        IF V_WERKS = 'P200' THEN
            DELETE 
              FROM TB_INV013_1
             WHERE WERKS = V_WERKS
               AND MACH_CD IN(SELECT MACH_CD
                                FROM TB_MAS012
                               WHERE PROC_CD = V_PROC_CD
                                 AND MACHINE LIKE '%' || V_MACHINE || '%');
        ELSE
            DELETE 
              FROM TB_INV013_1
             WHERE WERKS = V_WERKS
               AND MACH_CD IN(SELECT MACH_CD
                                FROM TB_MAS012
                               WHERE PROC_CD = V_PROC_CD);
        END IF;

--        IF V_WERKS <> 'P500' AND V_CLOSE <> '1' THEN   --일마감
--            P_SUCCESS := 'N';
--            E_SQL_ERR_MSG       := '월마감은 할수 없습니다, 일마감으로 진행해주세요';
--            RETURN;
--        END IF;

        IF V_CLOSE = '1' THEN   --일마감
            V_EDATE := V_SDATE;
        END IF;

--        IF NVL(V_MATNR, ' ' ) <> ' ' THEN
--            V_EDATE := FN_RECDATE(SYSDATE);
--        END IF;

        --폐품수량을 뺀 사용량 조회
        INSERT INTO TB_INV013_1(WERKS, MACH_CD, PRFM_DT, MATNR, ORDER_NO, LOT_NO,
                            USE_QTY, UNIT, REGDATE, REGID)
        SELECT I010.WERKS, 
                I010.MACH_CD, 
                I010.PRFM_DT, 
                I010.MATNR_M, 
                V000.ORDER_NO,
                CASE WHEN I010.LOT_NO_M IS NULL OR I010.LOT_NO_M = ' ' THEN '*' ELSE I010.LOT_NO_M END AS LOT_NO_M , 
                SUM(I010.USE_QTY) AS USE_QTY, 
                --I010.UNIT,
                CASE WHEN NVL(I010.UNIT, ' ') = ' ' THEN M001.UNIT ELSE I010.UNIT END UNIT,
                V_DATE,
                V_SESS_USER_ID
          FROM TB_INV010 I010,
               (SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO
                  FROM V_WRK_ORDR2
                 WHERE WERKS = V_WERKS
                   AND MACH_CD IN(SELECT MACH_CD
                                    FROM TB_MAS012
                                   WHERE PROC_CD = V_PROC_CD
                                     AND MACHINE LIKE '%' || V_MACHINE || '%')) V000,
                   TB_MAS001 M001
         WHERE I010.WERKS = V000.WERKS
           AND I010.WRK_ORDR_NO = V000.WRK_ORDR_NO
           AND I010.WRK_ORDR_SEQNO = V000.WRK_ORDR_SEQNO
           AND I010.WERKS = M001.WERKS(+)
           AND I010.MATNR_M = M001.MATNR(+)
           AND I010.WERKS = V_WERKS
           AND I010.MACH_CD IN(
                            SELECT MACH_CD
                              FROM TB_MAS012
                             WHERE PROC_CD = V_PROC_CD
                               AND MACHINE LIKE '%' || V_MACHINE || '%'
                            )  
             AND I010.MATNR_M LIKE '%' || V_MATNR || '%'
             AND I010.PRFM_DT BETWEEN V_SDATE AND V_EDATE
             AND M001.MATNR_DIV NOT IN ('ROH6', 'ROH7')
            AND NVL(I010.USE_DIV, '0') <> '3'
            AND NVL(I010.CNL_YN, 'N') = 'N'
        GROUP BY I010.WERKS, I010.MACH_CD, V000.ORDER_NO, I010.PRFM_DT, I010.MATNR_M, I010.LOT_NO_M, 
                CASE WHEN NVL(I010.UNIT, ' ') = ' ' THEN M001.UNIT ELSE I010.UNIT END; --I010.UNIT;

        --폐품 수량 포함한 사용량
        V_SQL := ' SELECT I010.WERKS, 
                        I010.MATNR_M, 
                        M001.MATNR_NM,
                        SUM(I010.USE_QTY) AS USE_QTY, 
                        CASE WHEN NVL(I010.UNIT, '' '') = '' '' THEN M001.UNIT ELSE I010.UNIT END UNIT
                      FROM TB_INV010 I010,
                           (SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO
                              FROM V_WRK_ORDR2
                             WHERE WERKS = ''' || V_WERKS || '''
                               AND MACH_CD IN(SELECT MACH_CD
                                                FROM TB_MAS012
                                               WHERE PROC_CD = ''' || V_PROC_CD || '''
                                                 AND MACHINE LIKE ''%' || V_MACHINE || '%'' )) V000,
                               TB_MAS001 M001
                     WHERE I010.WERKS = V000.WERKS
                       AND I010.WRK_ORDR_NO = V000.WRK_ORDR_NO
                       AND I010.WRK_ORDR_SEQNO = V000.WRK_ORDR_SEQNO
                       AND I010.WERKS = M001.WERKS(+)
                       AND I010.MATNR_M = M001.MATNR(+)
                       AND I010.WERKS = ''' || V_WERKS || '''
                       AND I010.MACH_CD IN(
                                        SELECT MACH_CD
                                          FROM TB_MAS012
                                         WHERE PROC_CD = ''' || V_PROC_CD || '''
                                           AND MACHINE LIKE ''%' || V_MACHINE || '%'')
                        AND I010.PRFM_DT BETWEEN ''' || V_SDATE || ''' AND ''' || V_EDATE || '''
                        AND NVL(I010.CNL_YN, ''N'') = ''N''
                        AND M001.MATNR_DIV NOT IN (''ROH6'', ''ROH7'')';

                    --GROUP BY I010.WERKS, I010.MATNR_M, M001.MATNR_NM, CASE WHEN NVL(I010.UNIT, '' '') = '' '' THEN M001.UNIT ELSE I010.UNIT END'; 

        IF (V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '') THEN                   
            V_SQL := V_SQL || ' AND I010.MATNR_M = ''' || V_MATNR || '''';		--자재코드
        END IF; 

        V_SQL := V_SQL || ' GROUP BY I010.WERKS, I010.MATNR_M, M001.MATNR_NM, CASE WHEN NVL(I010.UNIT, '' '') = '' '' THEN M001.UNIT ELSE I010.UNIT END'; 

        OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'LIST2' THEN  /*오른쪽 그리드 조회*/ 
        V_ARR_HEAD          := TREAT(V_JSON.get ('list') AS json_object_t);
        V_OBJ               := TREAT(V_ARR_HEAD.get ('map') AS json_object_t);

        --V_MACH_CD           :=  V_OBJ.get_string('MACH_CD');        
        --V_PRFM_DT           :=  V_OBJ.get_string('PRFM_DT');            
        V_MATNR_M           :=  V_OBJ.get_string('MATNR_M');          --투입자재코드
        --V_LOT_NO_M          :=  V_OBJ.get_string('LOT_NO');         --투입자재 LOT NO

        IF V_CLOSE = '1' THEN   --일마감
            V_EDATE := V_SDATE;
        END IF;
        V_SQL := 'SELECT B.WERKS, B.MACH_CD, B.MACH_NM, B.PRFM_DT, B.WRK_ORDR_NO, B.WRK_ORDR_SEQNO, B.ORDER_NO, 
                        B.MATNR, B.MATNR_NM, B.LOT_NO, B.MATNR_M, B.LOT_NO_M, B.IND_BCD_M, 
                        C.PRFM_QTY, B.STCK_QTY, B.USE_QTY, B.CHG_QTY AS USE_CHG_QTY, B.SCRAP_QTY, B.UNIT
                    FROM(
                         SELECT A.WERKS, A.MACH_CD, FN_GET_CODE_NM(''MACH_CD'',  A.WERKS, A.MACH_CD) AS MACH_NM,
                                     A.PRFM_DT, A.WRK_ORDR_NO, A.WRK_ORDR_SEQNO, A.ORDER_NO, 
                                     A.MATNR, FN_GET_CODE_NM(''MATNR'',  A.WERKS, A.MATNR) AS MATNR_NM,
                                     A.LOT_NO, A.MATNR_M, A.LOT_NO_M, A.IND_BCD_M, 
                                     (SELECT NVL(I001.STCK_QTY, 0) + NVL(I003.STCK_QTY, 0)
                                       FROM TB_INV001 I001,
                                            (SELECT WERKS, IND_BCD, SUM(STCK_QTY) AS STCK_QTY
                                               FROM TB_INV003
                                              WHERE WERKS = ''' || V_WERKS || '''
                                                AND MATNR = A.MATNR_M               --YSH
                                                AND IND_BCD = A.IND_BCD_M
                                              GROUP BY WERKS, IND_BCD
                                               ) I003
                                      WHERE I001.WERKS = I003.WERKS(+)
                                        AND I001.IND_BCD = I003.IND_BCD(+)
                                        AND I001.WERKS =  ''' || V_WERKS || '''
                                        AND I001.MATNR = A.MATNR_M              --YSH
                                        AND I001.IND_BCD = A.IND_BCD_M) AS STCK_QTY,
                                    (SUM(A.USE_QTY1) + SUM(A.USE_QTY2)) AS USE_QTY, 
                                    '''' AS CHG_QTY,
                                    SUM(A.DISPO_QTY) AS SCRAP_QTY, 
                                    A.UNIT
                        FROM( 
                             SELECT I010.WERKS, I010.MACH_CD, I010.PRFM_DT, I010.WRK_ORDR_NO, I010.WRK_ORDR_SEQNO, V000.ORDER_NO, 
                                       I010.MATNR, I010.LOT_NO, I010.IND_BCD, I010.MATNR_M, I010.LOT_NO_M, I010.IND_BCD_M, 
                                       CASE WHEN I010.USE_DIV = ''1'' THEN SUM(I010.USE_QTY) ELSE 0 END AS USE_QTY1,
                                       CASE WHEN I010.USE_DIV = ''2'' THEN SUM(I010.USE_QTY) ELSE 0 END AS USE_QTY2,
                                       CASE WHEN I010.USE_DIV = ''3'' THEN SUM(I010.USE_QTY) ELSE 0 END AS DISPO_QTY,
                                       I010.UNIT
                                  FROM TB_INV010 I010,
                                       (SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO
                                                  FROM V_WRK_ORDR2
                                                 WHERE WERKS = ''' || V_WERKS || '''
                                                   AND MACH_CD IN(SELECT MACH_CD
                                                                    FROM TB_MAS012
                                                                   WHERE PROC_CD = ''' || V_PROC_CD || '''
                                                                     AND MACHINE LIKE ''%' || V_MACHINE || '%'')) V000
                                 WHERE I010.WERKS = V000.WERKS
                                   AND I010.WRK_ORDR_NO = V000.WRK_ORDR_NO
                                   AND I010.WRK_ORDR_SEQNO = V000.WRK_ORDR_SEQNO
                                   AND I010.WERKS = ''' || V_WERKS || '''
                                   AND I010.MACH_CD IN (SELECT MACH_CD
                                                          FROM TB_MAS012
                                                         WHERE PROC_CD = ''' || V_PROC_CD || '''
                                                           AND MACHINE LIKE ''%' || V_MACHINE || '%'')
                                   AND I010.MATNR_M = ''' || V_MATNR_M || '''
                                   AND I010.PRFM_DT BETWEEN ''' || V_SDATE || ''' AND ''' || V_EDATE || '''
                                   AND NVL(I010.CNL_YN, ''N'') = ''N''
                                GROUP BY I010.WERKS, I010.MACH_CD, I010.PRFM_DT, I010.WRK_ORDR_NO, I010.WRK_ORDR_SEQNO, V000.ORDER_NO, 
                                       I010.MATNR, I010.LOT_NO, I010.IND_BCD, I010.MATNR_M, I010.LOT_NO_M, I010.IND_BCD_M, 
                                       I010.UNIT, I010.USE_DIV 
                                ) A
                           GROUP BY A.WERKS, A.WRK_ORDR_NO, A.WRK_ORDR_SEQNO, A.ORDER_NO, A.MACH_CD, A.PRFM_DT,  
                                   A.MATNR, A.LOT_NO, A.MATNR_M, A.LOT_NO_M, A.IND_BCD_M, A.UNIT
                        ) B,
                     (SELECT A.WRK_ORDR_NO, A.WRK_ORDR_SEQNO, TRUNC(A.PRFM_QTY / B.CNT) AS PRFM_QTY
                        FROM(
                              SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, SUM(EA_QTY) AS PRFM_QTY
                                FROM TB_WRK001
                               WHERE WERKS = ''' || V_WERKS || '''
                                 AND MACH_CD IN (SELECT MACH_CD
                                                   FROM TB_MAS012
                                                  WHERE PROC_CD = ''' || V_PROC_CD || '''
                                                    AND MACHINE LIKE ''%' || V_MACHINE || '%'')  
                                 AND PRFM_DT BETWEEN ''' || V_SDATE || ''' AND ''' || V_EDATE || '''
                                 AND NVL(CNL_YN, ''N'') = ''N''
                                 AND NVL(PRFM_GTHR_YN, ''N'') = ''Y''
                               GROUP BY WRK_ORDR_NO, WRK_ORDR_SEQNO) A, 
                             (SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, COUNT(DISTINCT(IND_BCD_M)) AS CNT
                                FROM TB_INV010
                               WHERE WERKS = ''' || V_WERKS || '''
                                 AND MACH_CD IN (SELECT MACH_CD
                                                   FROM TB_MAS012
                                                  WHERE PROC_CD = ''' || V_PROC_CD || '''
                                                    AND MACHINE LIKE ''%' || V_MACHINE || '%'')  
                                 AND PRFM_DT BETWEEN ''' || V_SDATE || ''' AND ''' || V_EDATE || '''
                                 AND MATNR_M = ''' || V_MATNR_M || '''      --YSH
                                 AND NVL(CNL_YN, ''N'') = ''N''
                               GROUP BY WRK_ORDR_NO, WRK_ORDR_SEQNO) B
                        WHERE A.WRK_ORDR_NO = B.WRK_ORDR_NO
                          AND A.WRK_ORDR_SEQNO = B.WRK_ORDR_SEQNO) C
                  WHERE B.WRK_ORDR_NO = C.WRK_ORDR_NO(+)
                    AND B.WRK_ORDR_SEQNO = C.WRK_ORDR_SEQNO(+) ';

        IF V_WERKS = 'P200' THEN
            V_SQL := V_SQL || '  AND (B.USE_QTY <> 0 OR B.SCRAP_QTY <> 0)';
--        ELSE   
--            V_SQL := V_SQL || '  AND (B.USE_QTY >= 0) ';
        END IF;

        V_SQL := V_SQL || ' ORDER BY B.WRK_ORDR_NO, B.MATNR_M, B.LOT_NO_M, B.IND_BCD_M' ;   

        V_DEBUG := 'Y';
        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR, SQL_PARAM1) VALUES (V_SQL, 'INV06');
        END IF;
        OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SAVE1' THEN  /*저장*/
        V_ARR_LIST              := V_JSON.get_array ('list');

         FOR i IN 0..V_ARR_LIST.get_size-1 LOOP

            V_OBJ           := TREAT(V_ARR_LIST.get (i) AS json_object_t); 
            V_OBJ           := TREAT(V_OBJ.get ('map') AS json_object_t);

            V_PRFM_DT               :=  V_OBJ.get_string('PRFM_DT');
            V_MACH_CD               :=  V_OBJ.get_string('MACH_CD');
            V_MATNR                 :=  V_OBJ.get_string('MATNR');
            V_IND_BCD               :=  V_OBJ.get_string('IND_BCD');        --빈값
            V_WRK_ORDR_NO           :=  V_OBJ.get_string('WRK_ORDR_NO');
            V_WRK_ORDR_SEQNO        :=  V_OBJ.get_string('WRK_ORDR_SEQNO');
            V_ORDER_NO              :=  V_OBJ.get_string('ORDER_NO');
            V_LOT_NO                :=  V_OBJ.get_string('LOT_NO');
            V_MATNR_M               :=  V_OBJ.get_string('MATNR_M');
            V_LOT_NO_M              :=  V_OBJ.get_string('LOT_NO_M');
            V_IND_BCD_M             :=  V_OBJ.get_string('IND_BCD_M');
            V_USE_QTY               :=  NVL(V_OBJ.get_string('USE_QTY'), 0);
            V_STCK_QTY              :=  TO_NUMBER(NVL(REPLACE(V_OBJ.get_string('STCK_QTY'), ' ', ''), 0));
            V_CHG_QTY               :=  NVL(REPLACE(V_OBJ.get_string('USE_CHG_QTY'), ' ', ''), 0);
            V_UNIT                  :=  V_OBJ.get_string('UNIT');

            IF NVL(V_CHG_QTY, 0) < 0 THEN
                P_ERR_MSG := '(-) 값은 입력할수 없습니다.';
                P_SUCCESS := 'N';
                ROLLBACK;
                RETURN; 
            END IF;

            BEGIN
                SELECT SUM(STCK_QTY) INTO V_STCK_QTY_PRE
                FROM (
                         -- INV001 부분
                         SELECT NVL(STCK_QTY, 0) AS STCK_QTY
                         FROM TB_INV001
                         WHERE 1 = 1
                           AND STCK_STA = '00'
                           AND WERKS = V_WERKS
                           AND MATNR = V_MATNR_M
                           AND IND_BCD = V_IND_BCD_M
                         UNION ALL
                         -- INV003 부분
                         SELECT NVL(SUM(STCK_QTY), 0) AS STCK_QTY
                         FROM TB_INV003
                         WHERE 1 = 1
                           AND WERKS = V_WERKS
                           AND MACH_CD = V_MACH_CD
                           AND MATNR = V_MATNR_M
                           AND IND_BCD = V_IND_BCD_M
                         GROUP BY WERKS, IND_BCD);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_STCK_QTY_PRE := 0;
            END;

            --사용량 보정값
            V_USE_CHG_QTY := NVL(V_CHG_QTY, 0) - NVL(V_USE_QTY, 0);

            IF NVL(V_STCK_QTY_PRE, 0) - V_USE_CHG_QTY < 0 THEN
                P_ERR_MSG := V_IND_BCD_M || ' 의 개별바코드의 재고수량 : ' || TO_CHAR(0 - (V_STCK_QTY_PRE - V_USE_CHG_QTY)) || ' ' || V_UNIT || ' 이 부족합니다.';
                P_SUCCESS := 'N';
                ROLLBACK;
                RETURN; 
            END IF;

            SELECT A.IND_BCD INTO V_IND_BCD_L
              FROM(
                    SELECT IND_BCD
                      FROM TB_INV010
                      WHERE WERKS = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND MATNR = V_MATNR
                       AND LOT_NO = V_LOT_NO
                       AND WRK_ORDR_NO = V_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                       AND IND_BCD_M = V_IND_BCD_M
                       AND MATNR_M = V_MATNR_M              --YSH
                       AND PRFM_DT = V_PRFM_DT
                     ORDER BY PRFM_DT DESC
                  ) A
             WHERE ROWNUM = 1;     

            BEGIN
            SELECT MAX(SEQNO) INTO V_M_SEQNO
              FROM TB_INV010
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND MATNR = V_MATNR
               AND IND_BCD = V_IND_BCD_L;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_M_SEQNO := 0;
            END;

            V_M_SEQNO := V_M_SEQNO + 1;

            INSERT INTO TB_INV010(WERKS, MACH_CD, MATNR, IND_BCD, SEQNO,
                            WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO, 
                            IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, PRFM_DT,
                            USE_QTY, UNIT, CHG_FLG, STCK_KY, LOT_NUM,
                            REGDATE, REGID, USE_DIV)
            SELECT A.WERKS, A.MACH_CD, A.MATNR, A.IND_BCD, V_M_SEQNO,
                A.WRK_ORDR_NO, A.WRK_ORDR_SEQNO, A.LOT_NO, 
                A.IND_BCD_M, A.LOT_NO_M, A.MATNR_M, A.INP_DT, A.PRFM_DT,
                V_USE_CHG_QTY, A.UNIT, A.CHG_FLG, A.STCK_KY, A.LOT_NUM,
                V_DATE, V_SESS_USER_ID, '2'
              FROM(
                    SELECT *
                      FROM TB_INV010
                      WHERE WERKS = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND MATNR = V_MATNR
                       AND LOT_NO = V_LOT_NO
                       AND IND_BCD = V_IND_BCD_L
                       AND IND_BCD_M = V_IND_BCD_M
                       AND MATNR_M = V_MATNR_M          --YSH
                       AND PRFM_DT = V_PRFM_DT
                     ORDER BY PRFM_DT DESC ) A
            WHERE ROWNUM = 1;        
            
            
--             UPDATE TB_INV003
--                SET USE_QTY = USE_QTY + V_USE_CHG_QTY,
--                    STCK_QTY = STCK_QTY - V_USE_CHG_QTY
--              WHERE WERKS = V_WERKS
--                AND MACH_CD = V_MACH_CD
--                AND MATNR = V_MATNR_M                --YSH
--                AND IND_BCD = V_IND_BCD_M;
--             IF SQL%ROWCOUNT = 0 THEN
--
--     --                UPDATE TB_INV001
--     --                   SET STCK_QTY = NVL(STCK_QTY, 0) - V_USE_CHG_QTY,
--     --                       STCK_STA = '00'
--     --                 WHERE WERKS = V_WERKS
--     --                   AND MATNR = V_MATNR_M            --YSH
--     --                   AND IND_BCD = V_IND_BCD_M;
-- --                IF V_USE_CHG_QTY < 0 THEN         --백우종님과 협의해서 원복함
--                     UPDATE TB_INV003
--                         SET SEQNO = SEQNO + 1
--                        WHERE WERKS = V_WERKS
--                          AND MACH_CD = V_MACH_CD
--                          AND MATNR = V_MATNR_M;
--
--                      INSERT INTO TB_INV003(WERKS, MACH_CD, MATNR, IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO
--                                         , LOT_NO, INP_DT, IN_QTY, USE_QTY, STCK_QTY, UNIT, REGDATE, REGID)
--                                   VALUES(V_WERKS, V_MACH_CD, V_MATNR_M, V_IND_BCD_M, 1, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO
--                                         , V_LOT_NO_M, TO_CHAR(V_DATE, 'YYYYMMDD'), 0 - V_USE_CHG_QTY, 0, 0 - V_USE_CHG_QTY, V_UNIT, V_DATE, V_SESS_USER_ID);
--
-- --                END IF;
--             END IF;

            DECLARE
                v_target_use NUMBER := V_USE_CHG_QTY;      -- 보정수량(양수면 차감 필요, 음수면 환원 필요)
                v_first_seqno NUMBER;
                v_after_qty  NUMBER := 0; -- 최종 재고 확인용
            BEGIN
                -- first_seqno 확인
                SELECT MIN(SEQNO) INTO v_first_seqno
                FROM TB_INV003
                WHERE 1=1
                  AND WERKS = V_WERKS
                  AND MACH_CD = V_MACH_CD
                  AND MATNR = V_MATNR_M
                  AND IND_BCD = V_IND_BCD_M;

                -- A. 사용량이 줄어든경우, 음수(-) : 재고 증가(+) 상황
                IF v_target_use < 0 THEN
                    IF v_first_seqno IS NOT NULL THEN
                        -- A_1. 첫 번째 행에 몰아서 업데이트 (음수를 빼서 결국 더해짐)
                        UPDATE TB_INV003
                        SET STCK_QTY = STCK_QTY - v_target_use,
                            USE_QTY  = USE_QTY  + v_target_use
                        WHERE 1=1
                            AND WERKS = V_WERKS
                            AND MACH_CD = V_MACH_CD
                            AND MATNR = V_MATNR_M
                            AND IND_BCD = V_IND_BCD_M
                            AND SEQNO = v_first_seqno;

                        SZP_MES_PLSQL_LOG('A_1. 재고환원: [SEQNO : '||v_first_seqno||' ]에 '|| ABS(v_target_use) ||' 만큼 환원 완료', 'INV06_S01');
                    ELSE
                        -- A_2. 데이터가 아예 없으면 새로 생성
                        INSERT INTO TB_INV003(WERKS, MACH_CD, MATNR, IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO
                                            , LOT_NO, INP_DT, IN_QTY, USE_QTY, STCK_QTY, UNIT, REGDATE, REGID)
                        VALUES(V_WERKS, V_MACH_CD, V_MATNR_M, V_IND_BCD_M, 1, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO
                                , V_LOT_NO_M, TO_CHAR(V_DATE, 'YYYYMMDD'), 0 - V_USE_CHG_QTY, 0, 0 - V_USE_CHG_QTY, V_UNIT, V_DATE, V_SESS_USER_ID);
                        SZP_MES_PLSQL_LOG('A_2*. 재고환원: 기존 데이터 없어 SEQNO : 1 로 신규 생성 ('|| ABS(v_target_use) ||')', 'INV06_S01');
                    END IF;
                -- B. 사용량이 양수(+) : 재고 차감(-) 상황 (FIFO)
                ELSIF v_target_use > 0 THEN
                    SZP_MES_PLSQL_LOG('B. 차감시작: 총 '|| v_target_use ||' 만큼 차감 시도 (대상 : ' || V_MACH_CD || ' / ' || V_MATNR_M || ' / ' || V_IND_BCD_M ||')', 'INV06_S01');

                    FOR rec IN (
                        SELECT * FROM TB_INV003
                        WHERE 1 = 1
                          AND WERKS = V_WERKS
                          AND MACH_CD = V_MACH_CD
                          AND MATNR = V_MATNR_M
                          AND IND_BCD = V_IND_BCD_M
                        ORDER BY SEQNO
                    ) LOOP
                        EXIT WHEN v_target_use <= 0;

                        IF rec.STCK_QTY > v_target_use THEN
                            -- B_1. 남은 재고가 더 많으면 : 필요한 만큼 깎고 종료
                            UPDATE TB_INV003
                            SET STCK_QTY = STCK_QTY - v_target_use,
                                USE_QTY  = USE_QTY  + v_target_use
                            WHERE 1=1
                              AND WERKS = V_WERKS
                              AND MACH_CD = V_MACH_CD
                              AND MATNR = V_MATNR_M
                              AND IND_BCD = V_IND_BCD_M
                              AND SEQNO = rec.SEQNO;

                            SZP_MES_PLSQL_LOG('B_1. 단계차감: [SEQNO : ' || rec.SEQNO || ' ]에서 '|| v_target_use ||' 차감(잔량발생)', 'INV06_S01');
                            v_target_use := 0;
                        ELSE
                            -- B_2. 재고가 딱 맞거나 부족하면 : 해당 행 삭제 후 다음 행으로
                            v_target_use := v_target_use - rec.STCK_QTY;

                            DELETE FROM TB_INV003
                            WHERE 1 = 1
                              AND WERKS = V_WERKS
                              AND MACH_CD = V_MACH_CD
                              AND MATNR = V_MATNR_M
                              AND IND_BCD = V_IND_BCD_M
                              AND SEQNO = rec.SEQNO;

                            SZP_MES_PLSQL_LOG('B_2*. 단계삭제: [SEQNO : ' || rec.SEQNO || ' ] 재고 '|| rec.STCK_QTY || ' 소진으로 삭제', 'INV06_S01');
                        END IF;
                    END LOOP;

                    -- B_3. INV003을 다 털었는데도 깎아야 할 수량(v_target_use)이 남았다면? INV001에서 남은 수량만큼 차감
                    IF v_target_use > 0 THEN
                        UPDATE TB_INV001
                        SET STCK_QTY = STCK_QTY - v_target_use
                        WHERE 1=1
                          AND WERKS = V_WERKS
                          AND MATNR = V_MATNR_M
                          AND IND_BCD = V_IND_BCD_M
                        RETURNING STCK_QTY INTO v_after_qty; -- 업데이트된 후의 값을 바로 변수에 담음

                        IF v_after_qty < 0 THEN
                            SZP_MES_PLSQL_LOG('B_3*. 경고 : INV001 부족분 차감 후 마이너스 재고 발생 (잔고: ' || v_after_qty || ')', 'INV06_S01');
                        ELSE
                            SZP_MES_PLSQL_LOG('B_3*. 성공 : INV003 소진으로 INV001에서 ' || v_target_use || '만큼 보충 차감 완료', 'INV06_S01');
                        END IF;

                        v_target_use := 0;
                    END IF;
                END IF;

                -- C. 최종 확인: INV003 단계에서 이미 다 깎였다면 v_target_use가 0일 것임
                IF v_target_use = 0 THEN
                    -- 이미 위에서 INV001 관련 로그를 찍었을 수도 있으므로,
                    -- 상황에 따라 '전체 프로세스 종료' 로그만 간단히 남김
                    SZP_MES_PLSQL_LOG('C. 재고 보정 프로세스 정상 종료', 'INV06_S01');
                ELSE
                    -- 이 경우는 데이터가 아예 없거나 루프를 돌지 못한 아주 예외적인 경우
                    SZP_MES_PLSQL_LOG('C. 오류 : 대상 데이터가 없어 ' || v_target_use || ' 만큼 차감하지 못했습니다.', 'INV06_S01');
                END IF;
            END;
            
            UPDATE TB_INV013_1
               SET USE_QTY = USE_QTY + V_USE_CHG_QTY --(V_USE_QTY - NVL(V_CHG_QTY, 0))
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND PRFM_DT = V_PRFM_DT
               AND MATNR = V_MATNR_M
               AND ORDER_NO = V_ORDER_NO
               AND LOT_NO = V_LOT_NO_M;
               --AND REGID = V_SESS_USER_ID;

            IF SQL%ROWCOUNT = 0 THEN
                INSERT INTO TB_INV013_1(WERKS, MACH_CD, PRFM_DT, MATNR, ORDER_NO,
                                    LOT_NO, USE_QTY, UNIT, REGDATE, REGID)
                         VALUES(V_WERKS, V_MACH_CD, V_PRFM_DT, V_MATNR_M, V_ORDER_NO,
                                V_LOT_NO_M, NVL(V_CHG_QTY, 0), V_UNIT, V_DATE, V_SESS_USER_ID);
            END IF;

         END LOOP;   

    ELSIF P_TYPE = 'SAVE2' THEN    /*마감(일/월) */
        IF V_CLOSE = '1' THEN
            V_EDATE := V_SDATE;
        END IF;

        --생산오더별 투입자재 취소문서번호
        V_DOC_NO_1 := FN_GET_MDOCNO('M','IF143');
        V_DOC_SEQNO_1 := 0;

        --생산오더별 투입자재 실적문서번호
        V_DOC_NO_2 := FN_GET_MDOCNO('M','IF130');
        V_DOC_SEQNO_2 := 0;

        OPEN PROD_CUR FOR
            SELECT CASE WHEN NVL(I013.WERKS, ' ') <> ' ' THEN I013.WERKS ELSE I013_1.WERKS END AS WERKS,
                   CASE WHEN NVL(I013.MACH_CD, ' ') <> ' ' THEN I013.MACH_CD ELSE I013_1.MACH_CD END AS MACH_CD,
                   CASE WHEN NVL(I013.PRFM_DT, ' ') <> ' ' THEN I013.PRFM_DT ELSE I013_1.PRFM_DT END AS PRFM_DT, 
                   CASE WHEN NVL(I013.MATNR, ' ') <> ' ' THEN I013.MATNR ELSE I013_1.MATNR END AS MATNR, 
                   CASE WHEN NVL(I013.ORDER_NO, ' ') <> ' ' THEN I013.ORDER_NO ELSE I013_1.ORDER_NO END AS ORDER_NO, 
                   CASE WHEN NVL(I013.LOT_NO, ' ') <> ' ' THEN I013.LOT_NO ELSE I013_1.LOT_NO END AS LOT_NO, 
                   I013.USE_QTY AS USE_QTY_P,
                   NVL(I013_1.USE_QTY, 0) AS USE_QTY_C,
                   CASE WHEN NVL(I013.UNIT, ' ') <> ' ' THEN I013.UNIT ELSE I013_1.UNIT END AS UNIT, 
                   I013.DOC_NO,
                   I013.DOC_SEQNO,
                   I013.SDOC_NO,
                   I013.SDOC_SEQNO
                   INTO 
                   V_WERKS, V_MACH_CD, V_PRFM_DT, V_MATNR_M, V_ORDER_NO, V_LOT_NO_M, V_USE_QTY_P, V_USE_QTY_C, V_UNIT, 
                   V_DOC_NO, V_DOC_SEQNO, V_SDOC_NO, V_SDOC_SEQNO 
              FROM (SELECT *
                      FROM TB_INV013
                     WHERE WERKS = V_WERKS
                       AND MACH_CD IN (SELECT MACH_CD
                                         FROM TB_MAS012
                                        WHERE PROC_CD = V_PROC_CD
                                          AND MACHINE LIKE '%' || V_MACHINE || '%') 
                       AND MATNR LIKE '%' || V_MATNR || '%'
                       AND PRFM_DT BETWEEN V_SDATE AND V_EDATE
                    ) I013
              FULL OUTER JOIN (SELECT *
                                 FROM TB_INV013_1 
                                WHERE WERKS = V_WERKS
                                  AND MACH_CD IN (SELECT MACH_CD
                                                    FROM TB_MAS012
                                                   WHERE PROC_CD = V_PROC_CD
                                                     AND MACHINE LIKE '%' || V_MACHINE || '%') 
                                  AND MATNR LIKE '%' || V_MATNR || '%'
                                  AND PRFM_DT BETWEEN V_SDATE AND V_EDATE
                                  --AND REGID = V_SESS_USER_ID
                               ) I013_1
              ON I013.WERKS = I013_1.WERKS
              AND I013.MACH_CD = I013_1.MACH_CD
              AND I013.PRFM_DT = I013_1.PRFM_DT
              AND I013.MATNR = I013_1.MATNR
              AND I013.ORDER_NO = I013_1.ORDER_NO
              AND I013.LOT_NO = I013_1.LOT_NO
            ORDER BY I013.WERKS, I013.PRFM_DT;   
        LOOP
        FETCH PROD_CUR INTO V_WERKS, V_MACH_CD, V_PRFM_DT, V_MATNR_M, V_ORDER_NO, V_LOT_NO_M, V_USE_QTY_P, V_USE_QTY_C, V_UNIT, 
                   V_DOC_NO, V_DOC_SEQNO, V_SDOC_NO, V_SDOC_SEQNO ;

        EXIT WHEN PROD_CUR %NOTFOUND;
            IF V_USE_QTY_C > 0 THEN
                IF NVL(V_LOT_NO_M, ' ') <> ' ' THEN
                    SELECT SAP_WRK_CD INTO V_SAP_WRK_CD
                      FROM TB_MAS012
                     WHERE MACH_CD = V_MACH_CD;

                    SELECT CASE WHEN MATNR_DIV = 'FERT' OR MATNR_DIV = 'HAWA' THEN '2000' ELSE LGPRO END 
                        INTO V_STOR_LOC_CD
                      FROM TB_MAS001
                     WHERE WERKS = V_WERKS
                       AND MATNR = V_MATNR_M;

                    --기존 수량과 같을 경우
                    IF NVL(V_USE_QTY_P, 0) = NVL(V_USE_QTY_C, 0) THEN
                        IF NVL(V_SDOC_NO, ' ')  = ' ' THEN
                            --SAP 문서번호가 없을 경우
                            --생산오더별 자재 투입실적 전송
                            IF NVL(V_USE_QTY_P, 0) > 0 THEN
--                                 SZP_MES_PLSQL_LOG('실적등록 예정', '');
                                V_DOC_SEQNO_2 := V_DOC_SEQNO_2 + 1;

                                INSERT INTO TB_IFS008(AUFNR, POSNR, BUDAT, MATNR, MENGE,
                                                    LGORT, CHARG, MDOCNO, MDOCSEQ, ZRESULT, MAKE_DATE, MAKER, 
                                                    WORKCENTERCODE, WERKS)
                                          VALUES( V_ORDER_NO, '10', V_PRFM_DT, V_MATNR_M, NVL(V_USE_QTY_P, 0),
                                                    V_STOR_LOC_CD, REPLACE(V_LOT_NO_M, '*', ''), V_DOC_NO_2, TO_CHAR(V_DOC_SEQNO_2), 'N', V_DATE, V_SESS_USER_ID,
                                                    V_SAP_WRK_CD, V_WERKS);

                                UPDATE TB_INV013
                                   SET USE_QTY = V_USE_QTY_P,
                                       DOC_NO = V_DOC_NO_2,
                                       DOC_SEQNO = V_DOC_SEQNO_2,
                                       SDOC_NO = '',
                                       SDOC_SEQNO = ''
                                 WHERE WERKS = V_WERKS
                                   AND MACH_CD = V_MACH_CD
                                   AND PRFM_DT = V_PRFM_DT
                                   AND MATNR = V_MATNR_M
                                   AND ORDER_NO = V_ORDER_NO
                                   AND LOT_NO = V_LOT_NO_M;
                            END IF;           
                        END IF;
                    ELSE        --기존 수량과 다를경우 
                        IF NVL(V_SDOC_NO, ' ')  <> ' ' AND NVL(V_SDOC_NO, ' ')  <> 'E' THEN
                            --SAP문서번호가 있을 경우
                            --생산오더별 자재 투입취소 전송
                            V_DOC_SEQNO_1 := V_DOC_SEQNO_1 + 1;
                            INSERT INTO TB_IFS014(AUFNR, POSNR, BUDAT, MATNR, MENGE, WERKS,
                                                LGORT, CHARG, WORKCENTERCODE, MDOCNO, MDOCSEQ, 
                                                MBLNR, MJAHR, ZRESULT, MAKE_DATE, MAKER)
                                       VALUES(V_ORDER_NO, '10', V_PRFM_DT, V_MATNR_M, NVL(V_USE_QTY_P, 0), V_WERKS,
                                                V_STOR_LOC_CD, REPLACE(V_LOT_NO_M, '*', ''), V_SAP_WRK_CD, V_DOC_NO_1, TO_CHAR(V_DOC_SEQNO_1),
                                                V_SDOC_NO, V_SDOC_SEQNO, 'N', V_DATE, V_SESS_USER_ID);

                            --생산오더별 자재 투입실적 전송
                            IF NVL(V_USE_QTY_C, 0) > 0 THEN
                                V_DOC_SEQNO_2 := V_DOC_SEQNO_2 + 1;  
                                INSERT INTO TB_IFS008(AUFNR, POSNR, BUDAT, MATNR, MENGE,
                                                    LGORT, CHARG, MDOCNO, MDOCSEQ, ZRESULT, MAKE_DATE, MAKER, 
                                                    WORKCENTERCODE, WERKS)
                                          VALUES( V_ORDER_NO, '10', V_PRFM_DT, V_MATNR_M, NVL(V_USE_QTY_C, 0),
                                                    V_STOR_LOC_CD, REPLACE(V_LOT_NO_M, '*', ''), V_DOC_NO_2, TO_CHAR(V_DOC_SEQNO_2), 'N', V_DATE, V_SESS_USER_ID,
                                                    V_SAP_WRK_CD, V_WERKS);

                                UPDATE TB_INV013
                                   SET USE_QTY = V_USE_QTY_C,
                                       DOC_NO = V_DOC_NO_2,
                                       DOC_SEQNO = V_DOC_SEQNO_2,
                                       SDOC_NO = '',
                                       SDOC_SEQNO = ''
                                 WHERE WERKS = V_WERKS
                                   AND MACH_CD = V_MACH_CD
                                   AND PRFM_DT = V_PRFM_DT
                                   AND MATNR = V_MATNR_M
                                   AND ORDER_NO = V_ORDER_NO
                                   AND LOT_NO = V_LOT_NO_M;
                            ELSE
                                DELETE
                                  FROM TB_INV013
                                 WHERE WERKS = V_WERKS
                                   AND MACH_CD = V_MACH_CD
                                   AND PRFM_DT = V_PRFM_DT
                                   AND MATNR = V_MATNR_M
                                   AND ORDER_NO = V_ORDER_NO
                                   AND LOT_NO = V_LOT_NO_M;
                            END IF;
                        ELSE    --문서번호가 없을 경우
                            IF NVL(V_USE_QTY_C, 0) > 0 THEN
                                V_DOC_SEQNO_2 := V_DOC_SEQNO_2 + 1;  
                                INSERT INTO TB_IFS008(AUFNR, POSNR, BUDAT, MATNR, MENGE,
                                                    LGORT, CHARG, MDOCNO, MDOCSEQ, ZRESULT, MAKE_DATE, MAKER, 
                                                    WORKCENTERCODE, WERKS)
                                          VALUES( V_ORDER_NO, '10', V_PRFM_DT, V_MATNR_M, NVL(V_USE_QTY_C, 0),
                                                    V_STOR_LOC_CD, REPLACE(V_LOT_NO_M, '*', ''), V_DOC_NO_2, TO_CHAR(V_DOC_SEQNO_2), 'N', V_DATE, V_SESS_USER_ID,
                                                    V_SAP_WRK_CD, V_WERKS);

                                DELETE
                                  FROM TB_INV013
                                 WHERE WERKS = V_WERKS
                                   AND MACH_CD = V_MACH_CD
                                   AND PRFM_DT = V_PRFM_DT
                                   AND MATNR = V_MATNR_M
                                   AND ORDER_NO = V_ORDER_NO
                                   AND LOT_NO = V_LOT_NO_M;

                                INSERT INTO TB_INV013(WERKS, MACH_CD, PRFM_DT, MATNR, 
                                                    ORDER_NO, LOT_NO, USE_QTY, UNIT, DOC_NO, DOC_SEQNO, REGDATE, REGID)
                                SELECT WERKS, MACH_CD, PRFM_DT, MATNR, 
                                                    ORDER_NO, LOT_NO, V_USE_QTY_C, UNIT, V_DOC_NO_2, V_DOC_SEQNO_2, REGDATE, REGID
                                  FROM TB_INV013_1
                                 WHERE WERKS = V_WERKS
                                   AND MACH_CD = V_MACH_CD
                                   AND PRFM_DT = V_PRFM_DT
                                   AND MATNR = V_MATNR_M
                                   AND ORDER_NO = V_ORDER_NO
                                   AND LOT_NO = V_LOT_NO_M;
                                   --AND REGID = V_SESS_USER_ID;
                              END IF; 
        --                    UPDATE TB_INV013
        --                       SET USE_QTY = V_USE_QTY_C,
        --                           DOC_NO = V_DOC_NO_2,
        --                           DOC_SEQNO = V_DOC_SEQNO_2,
        --                           SDOC_NO = '',
        --                           SDOC_SEQNO = ''
        --                     WHERE WERKS = V_WERKS
        --                       AND MACH_CD = V_MACH_CD
        --                       AND PRFM_DT = V_PRFM_DT
        --                       AND MATNR = V_MATNR_M
        --                       AND ORDER_NO = V_ORDER_NO
        --                       AND LOT_NO = V_LOT_NO_M;
                        END IF;
                    END IF;
                END IF;        
            END IF;
        END LOOP;

    END IF;
    --생산오더별 투입자재 취소 실적
    IF V_DOC_SEQNO_1 > 0 THEN
        P_DOC_NO1 := V_DOC_NO_1;
    END IF;

    --생산오더별 투입자재 실적
    IF V_DOC_SEQNO_2 > 0 THEN
        P_DOC_NO2 := V_DOC_NO_2;
    END IF;

    P_SUCCESS := 'Y';
    COMMIT;
--    EXCEPTION
--    WHEN E_EXCEPTION_USER THEN
--
--        -- 에러 내역 SET 	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := SQLCODE;
--        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);
--
--        ROLLBACK;
--        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
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
