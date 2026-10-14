--------------------------------------------------------
--  DDL for Procedure SP_INV06_S01_221119
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_INV06_S01_221119" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
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
    V_USE_QTY_P     TB_INV010.USE_QTY%TYPE; 
    V_USE_QTY_C     TB_INV010.USE_QTY%TYPE; 
    V_STCK_QTY      TB_INV003.STCK_QTY%TYPE; 
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
   --V_MACH_CD			:=       V_JSON.get_string('MACH_CD');		--설비코드
   V_CLOSE		    	:=       V_JSON.get_string('CLOSE');		--일마감(1),월마감(2)
   V_MACHINE			:=		 V_JSON.get_string('MACHINE');		--생산호기
   
    IF P_TYPE = 'LIST' THEN /*왼쪽 그리드 조회*/
        DELETE 
          FROM TB_INV013_1
         WHERE WERKS = V_WERKS
           AND MACH_CD IN(SELECT MACH_CD
                            FROM TB_MAS012
                           WHERE PROC_CD = V_PROC_CD);
        IF V_WERKS <> 'P500' AND V_CLOSE <> '1' THEN   --일마감
            P_SUCCESS := 'N';
            E_SQL_ERR_MSG       := '월마감은 할수 없습니다, 일마감으로 진행해주세요';
            RETURN;
        END IF;
        
        IF V_CLOSE = '1' THEN   --일마감
--            BEGIN
--            SELECT NVL(COUNT(*),0) INTO V_CNT
--              FROM V_WRK_ORDR
--             WHERE WERKS = V_WERKS
--               AND MACH_CD IN(SELECT MACH_CD
--                                FROM TB_MAS012
--                               WHERE PROC_CD = V_PROC_CD)
--               AND SUBSTR(PRD_END_DTM, 1, 8) = V_SDATE
--            GROUP BY WERKS;   
--            EXCEPTION
--                WHEN NO_DATA_FOUND THEN
--                    V_CNT := 0;
--            END;
            
            --IF NVL(V_CNT, 0) > 0 THEN
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
                          FROM V_WRK_ORDR
                         WHERE WERKS = V_WERKS
                           AND MACH_CD IN(SELECT MACH_CD
                                            FROM TB_MAS012
                                           WHERE PROC_CD = V_PROC_CD)
                           AND SUBSTR(PRD_END_DTM, 1, 8) = V_SDATE) V000,
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
                                    )  
                    AND M001.MATNR_DIV NOT IN ('ROH6', 'ROH7')
                    AND I010.MATNR_M LIKE '%' || V_MATNR || '%'
                    --AND I010.PRFM_DT =  V_SDATE
                    --AND I010.USE_QTY > 0
                    AND NVL(I010.USE_DIV, '0') <> '3'
                    AND NVL(I010.CNL_YN, 'N') = 'N'
                GROUP BY I010.WERKS, I010.MACH_CD, V000.ORDER_NO, I010.PRFM_DT, I010.MATNR_M, I010.LOT_NO_M, 
                        CASE WHEN NVL(I010.UNIT, ' ') = ' ' THEN M001.UNIT ELSE I010.UNIT END; --I010.UNIT
           -- END IF;
        ELSE
--            V_SDATE := '20220913';
--            V_EDATE := '20220916';

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
                      FROM V_WRK_ORDR
                     WHERE WERKS = V_WERKS
                       AND MACH_CD IN(SELECT MACH_CD
                                        FROM TB_MAS012
                                       WHERE PROC_CD = V_PROC_CD)
                       AND SUBSTR(PRD_END_DTM, 1, 8) BETWEEN  V_SDATE AND V_EDATE) V000,
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
                                )  
                 AND I010.MATNR_M LIKE '%' || V_MATNR || '%'
                 AND M001.MATNR_DIV NOT IN ('ROH6', 'ROH7')
                --AND I010.PRFM_DT BETWEEN  V_SDATE AND V_EDATE
                --AND I010.USE_QTY > 0
                AND NVL(I010.USE_DIV, '0') <> '3'
                AND NVL(I010.CNL_YN, 'N') <> 'Y'
            GROUP BY I010.WERKS, I010.MACH_CD, V000.ORDER_NO, I010.PRFM_DT, I010.MATNR_M, I010.LOT_NO_M, 
                    CASE WHEN NVL(I010.UNIT, ' ') = ' ' THEN M001.UNIT ELSE I010.UNIT END; --I010.UNIT;
            
        END IF;
        
        V_SQL := ' SELECT I013.WERKS,                         --플랜트
                          I013.MACH_CD,                       --설비코드
                          I013.ORDER_NO,                      --오더번호
                          I013.PRFM_DT,                       --실적일자
                          I013.MATNR,                         --투입자재코드    
                          M001.MATNR_NM,                      --투입자재명
                          I013.LOT_NO,                        --투입자재 LOT NO
                          SUM(I013.USE_QTY) AS USE_QTY,       --사용량
                          I013.UNIT                           --단위
                     FROM TB_INV013_1 I013,
                          TB_MAS001 M001
                    WHERE I013.WERKS = M001.WERKS(+)
                      AND I013.MATNR = M001.MATNR(+)
                      AND I013.WERKS = ''' || V_WERKS || '''';

        IF (V_PROC_CD IS NOT NULL OR TRIM(V_PROC_CD) != '') THEN                   
            V_SQL := V_SQL || ' AND I013.MACH_CD IN (SELECT MACH_CD
                                                       FROM TB_MAS012
                                                      WHERE PROC_CD = ''' || V_PROC_CD || '''
                                                     )  ';		--설비코드
        END IF;

        IF (V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '') THEN                   
            V_SQL := V_SQL || ' AND I013.MATNR = ''' || V_MATNR || '''';		--자재코드
        END IF;

       	IF  V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '' THEN         -- 생산호기
            IF V_WERKS = 'P200' THEN
                IF V_PROC_CD = 'AA' THEN
                    V_SQL := V_SQL || ' AND I013.MACH_CD = ''TAA' || LPAD(SUBSTR(V_MACHINE, -1), 2, '00') || '''';
                ELSIF V_PROC_CD = 'RA' THEN
                    V_SQL := V_SQL || ' AND I013.MACH_CD = ''TRA' || LPAD(SUBSTR(V_MACHINE, -1), 2, '00') || '''';
                ELSE
                    V_SQL := V_SQL || ' AND I013.MACH_CD = ''TPG01'' ';
                END IF;
            ELSIF V_WERKS = 'P300' THEN
            	IF V_MACHINE = 'SN5' THEN
                	V_SQL := V_SQL || ' AND I013.MACH_CD = ''SRB05'' ';
                ELSIF V_MACHINE = 'SN6' THEN
                	V_SQL := V_SQL || ' AND I013.MACH_CD = ''SRB06'' ';
                ELSE
                    V_SQL := V_SQL || ' AND I013.MACH_CD = ''SPF03'' ';
                END IF;
            ELSIF V_WERKS = 'P500' THEN
                IF V_MACHINE = 'BD5' THEN
                    V_SQL := V_SQL || ' AND I013.MACH_CD = ''BRC05'' ';
                ELSIF V_MACHINE = 'BD6' THEN
                    V_SQL := V_SQL || ' AND I013.MACH_CD = ''BRC06'' ';
                ELSE
                    V_SQL := V_SQL || ' AND I013.MACH_CD = ''BPI02'' ';
                END IF;
            END IF;
        END IF;
       
--        IF V_CLOSE = '1' THEN
--            V_SQL := V_SQL || ' AND I013.PRFM_DT = ''' || V_SDATE || '''';		--실적일자     
--        ELSE
--            V_SQL := V_SQL || ' AND I013.PRFM_DT BETWEEN ''' || V_SDATE || ''' AND ''' || V_EDATE || '''';		--실적일자     
--        END IF;
        V_SQL := V_SQL || ' GROUP BY I013.WERKS, I013.MACH_CD, I013.ORDER_NO, I013.PRFM_DT, I013.MATNR, M001.MATNR_NM, I013.LOT_NO, I013.UNIT';
        V_SQL := V_SQL || ' ORDER BY I013.WERKS, I013.MACH_CD, I013.ORDER_NO,I013.PRFM_DT, I013.MATNR';
    

        OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'LIST2' THEN  /*오른쪽 그리드 조회*/ 
        V_ARR_HEAD          := TREAT(V_JSON.get ('list') AS json_object_t);
        V_OBJ               := TREAT(V_ARR_HEAD.get ('map') AS json_object_t);
        
        V_MACH_CD           :=  V_OBJ.get_string('MACH_CD');        
        V_PRFM_DT           :=  V_OBJ.get_string('PRFM_DT');            
        V_MATNR_M           :=  V_OBJ.get_string('MATNR');          --투입자재코드
        V_LOT_NO_M          :=  V_OBJ.get_string('LOT_NO');         --투입자재 LOT NO
        
        
        V_SQL := ' SELECT I010.PRFM_DT,                 --실적일자
                        I010.MACH_CD,                   --설비코드
                        M012.MACH_NM,                   --설비명
                        I010.MATNR,                     --생산품 자재코드(보이지 않음)
                        '''' AS IND_BCD,                   --생산품 개별바코드(보이지 않음)
                        I010.WRK_ORDR_NO,               --생산품 작업지시번호(보이지 않음)
                        I010.WRK_ORDR_SEQNO,            --생산품 작업지시 순버(보이지 않음)
                        V000.ORDER_NO,                  --생산품 오더번호(보이지 않음)
                        '''' AS LOT_NO,                    --생산품 LOT NO(보이지 않음)
                        I010.MATNR_M,                   --투입자재 자재코드
                        M001.MATNR_NM,                  --투입자재명
                        NVL(I010.LOT_NO_M, ''*'') AS LOT_NO_M,                  --투입자재 LOT NO
                        I010.IND_BCD_M,                 --투입자재 개별바코드
                        '''' AS INP_DT,                    --투입일자(보이지 않음)
                        (SELECT NVL(I001.STCK_QTY, 0) + NVL(I003.STCK_QTY, 0)
                           FROM TB_INV001 I001,
                                (SELECT WERKS, IND_BCD, SUM(STCK_QTY) AS STCK_QTY
                                   FROM TB_INV003
                                  WHERE WERKS = ''' || V_WERKS || '''
                                    AND IND_BCD = I010.IND_BCD_M
                                  GROUP BY WERKS, IND_BCD
                                   ) I003
                          WHERE I001.WERKS = I003.WERKS(+)
                            AND I001.IND_BCD = I003.IND_BCD(+)
                            AND I001.WERKS =  ''' || V_WERKS || '''
                            AND I001.IND_BCD = I010.IND_BCD_M) AS STCK_QTY,
                        '''' AS STCK_QTY,
                        SUM(I010.USE_QTY) AS USE_QTY,                   --사용량
                        '''' AS CHG_QTY,                --사용량 조정
                        I010.UNIT                       --단위
                      FROM TB_INV010 I010
                      INNER JOIN V_WRK_ORDR V000 ON I010.WERKS = V000.WERKS 
                      AND I010.WRK_ORDR_NO = V000.WRK_ORDR_NO AND I010.WRK_ORDR_SEQNO = V000.WRK_ORDR_SEQNO
                      INNER JOIN TB_MAS012 M012 ON I010.MACH_CD = M012.MACH_CD
                      INNER JOIN TB_MAS001 M001 ON I010.WERKS = M001.WERKS AND I010.MATNR = M001.MATNR
                     WHERE 1 = 1 
                       AND I010.WERKS = ''' || V_WERKS || '''
                       AND I010.MACH_CD = ''' || V_MACH_CD || ''' 
                       AND I010.MATNR_M = ''' || V_MATNR_M  || '''
                       AND I010.PRFM_DT = ''' || V_PRFM_DT || '''
                       AND NVL(TRIM(I010.LOT_NO_M), ''*'') = ''' || V_LOT_NO_M || '''
                       --AND I010.USE_QTY > 0
                       AND NVL(I010.USE_DIV, ''0'') <> ''3''
                       AND NVL(I010.CNL_YN, ''N'') <> ''Y''
                    GROUP BY  I010.PRFM_DT, I010.MACH_CD, M012.MACH_NM, I010.MATNR,
                        I010.WRK_ORDR_NO, I010.WRK_ORDR_SEQNO, V000.ORDER_NO,
                        I010.MATNR_M, M001.MATNR_NM, NVL(I010.LOT_NO_M, ''*''),
                        I010.IND_BCD_M, I010.UNIT     
                   ORDER BY I010.WRK_ORDR_NO, I010.WRK_ORDR_SEQNO, I010.IND_BCD_M';     
        
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
            V_LOT_NO                :=  V_OBJ.get_string('V_LOT_NO');
            V_MATNR_M               :=  V_OBJ.get_string('MATNR_M');
            V_LOT_NO_M              :=  V_OBJ.get_string('LOT_NO_M');
            V_IND_BCD_M             :=  V_OBJ.get_string('IND_BCD_M');
            V_USE_QTY               :=  NVL(V_OBJ.get_string('USE_QTY'), 0);
            V_STCK_QTY              :=  NVL(V_OBJ.get_string('STCK_QTY'), 0);
            V_CHG_QTY               :=  NVL(V_OBJ.get_string('CHG_QTY'), 0);
            V_UNIT                  :=  V_OBJ.get_string('UNIT');
         
--            INSERT INTO TB_INV010(WERKS, MACH_CD, MATNR, IND_BCD, SEQNO,
--                            WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO, 
--                            IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, PRFM_DT,
--                            USE_QTY, UNIT, CHG_FLG, STCK_KY, LOT_NUM,
--                            REGDATE, REGID, USE_DIV)
--            SELECT WERKS, MACH_CD, MATNR, IND_BCD, SEQNO + 1,
--                WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO, 
--                IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, PRFM_DT,
--                V_USE_QTY - NVL(V_CHG_QTY, 0), UNIT, CHG_FLG, STCK_KY, LOT_NUM,
--                V_DATE, V_SESS_USER_ID, '2'
--              FROM  TB_INV010
--             WHERE WERKS = V_WERKS
--               AND MACH_CD = V_MACH_CD
--               AND MATNR = V_MATNR
--               AND IND_BCD = V_IND_BCD
--               AND IND_BCD_M = V_IND_BCD_M;
            V_REM_QTY := NVL(V_STCK_QTY, 0) - NVL(V_CHG_QTY, 0);
            
            SELECT A.IND_BCD INTO V_IND_BCD_L
              FROM(
                    SELECT IND_BCD
                      FROM TB_INV010
                      WHERE WERKS = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND MATNR = V_MATNR
                       AND WRK_ORDR_NO = V_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                       AND IND_BCD_M = V_IND_BCD_M
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
                V_REM_QTY, A.UNIT, A.CHG_FLG, A.STCK_KY, A.LOT_NUM,
                V_DATE, V_SESS_USER_ID, '2'
              FROM(
                    SELECT *
                      FROM TB_INV010
                      WHERE WERKS = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND MATNR = V_MATNR
                       AND IND_BCD = V_IND_BCD_L
                       AND IND_BCD_M = V_IND_BCD_M
                       AND PRFM_DT = V_PRFM_DT
                     ORDER BY PRFM_DT DESC ) A
            WHERE ROWNUM = 1;        
            
            UPDATE TB_INV003
               SET USE_QTY = USE_QTY + V_REM_QTY,
                   STCK_QTY = STCK_QTY - V_REM_QTY
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD_M;
            IF SQL%ROWCOUNT = 0 THEN
                UPDATE TB_INV001
                   SET STCK_QTY = STCK_QTY - V_REM_QTY
                 WHERE WERKS = V_WERKS
                   AND IND_BCD = V_IND_BCD_M;
            END IF;   

            UPDATE TB_INV013_1
               SET USE_QTY = USE_QTY + (V_USE_QTY - NVL(V_CHG_QTY, 0))
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND PRFM_DT = V_PRFM_DT
               AND MATNR = V_MATNR_M
               AND ORDER_NO = V_ORDER_NO
               AND LOT_NO = V_LOT_NO_M;
               
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
                   I013_1.USE_QTY AS USE_QTY_C,
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
                                        WHERE PROC_CD = V_PROC_CD) 
                       AND MATNR LIKE '%' || V_MATNR || '%'
                       AND PRFM_DT BETWEEN V_SDATE AND V_EDATE
                    ) I013
              FULL OUTER JOIN (SELECT *
                                 FROM TB_INV013_1 
                                WHERE WERKS = V_WERKS
                                  AND MACH_CD IN (SELECT MACH_CD
                                                    FROM TB_MAS012
                                                   WHERE PROC_CD = V_PROC_CD) 
                                  AND MATNR LIKE '%' || V_MATNR || '%'
                                  AND PRFM_DT BETWEEN V_SDATE AND V_EDATE 
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
