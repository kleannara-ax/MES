--------------------------------------------------------
--  DDL for Procedure SP_INV05_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_INV05_S01" (
	P_TYPE           IN    VARCHAR2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    VARCHAR2,
    P_ERR_MSG       OUT     VARCHAR2,
    P_DOC_NO1       OUT     VARCHAR2,       --자재투입량 취소 문서번호
    P_DOC_NO2       OUT     VARCHAR2,       --자재투입량 전송 문서번호
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_INV05_S01
 * PROGRAM NAME  : 약품 사용이력(마감)
 * VERSION       : 1.0.0
 * DESCRIPTION   : 약품 사용이력(마감) 를 관리한다.
 *                 
 * AUTHOR NAME   : 박충식
 * CREATE DATE   : 2022/05/26
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    DATE        VER       NAME          DESCRIPTION      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/26    1.0.0   박충식         INITIAL VERSION 
 * 2022/07/21    1.0.0   유상호         INITIAL VERSION 
 *==============================================================================
 *  관련 테이블
 *        - [TB_INV010] : (CRUD) 자재투입이력 정보
 * *      
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_INV05_S01';     -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

   -- V_RTN_CLOB       CLOB;
   -- V_RTN_CURSOR     SYS_REFCURSOR;
   -- V_ERROR          CLOB;

    -- JSON을 위한 변수선언 영역
--    V_JSON           JSON_OBJECT_T;
--    V_ARR_LIST       JSON_ARRAY_T;
--    V_ARR_HEAD       JSON_ARRAY_T;
--    V_OBJ            JSON_OBJECT_T;

    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_OBJECT_T;
    V_OBJ            JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        VARCHAR2(1);
    V_RANGE_SQL      VARCHAR2(4000);
    V_DEBUG          VARCHAR2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         VARCHAR2(10);
    V_SESS_USER_ID   VARCHAR2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS			TB_SCH008.WERKS%TYPE;		    --플랜트
    V_MACHINE       TB_SCH008.MACHINE%TYPE;         --생산호기
    V_SDATE 		TB_INV010.INP_DT%TYPE;   --시작투입일자
    V_EDATE 		TB_INV010.INP_DT%TYPE;   --종료투입일자

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역

    V_WRK_ORDR_NO	       TB_SCH017.WRK_ORDR_NO%TYPE;        --작업지시번호
    V_WRK_ORDR_SEQNO	   TB_SCH017.WRK_ORDR_SEQNO%TYPE;     --작업지시순번
    V_ORDER_NO	           TB_SCH017.ORDER_NO%TYPE;           --오더번호
    V_ORDR_QTY	           TB_SCH017.WRK_ORDR_QTY%TYPE;       --지시수량
    V_ORDR_GEN_DT	       TB_SCH017.ORDR_GEN_DT%TYPE;        --지시생성일자
    V_PRD_REQ_DATE	       TB_SCH017.PRD_REQ_DT%TYPE;         --생산요청일자
    V_WRK_ORDR_REMARK	   TB_SCH017.WRK_ORDR_RMK%TYPE;       --작업지시비고
    V_USE_YN	           TB_SCH017.USE_YN%TYPE;             --사용여부
	V_COMP_YN	           TB_SCH017.COMP_YN%TYPE;            --확정여부
    V_WRK_SEQNO            TB_SCH017.WRK_SEQNO%TYPE;          --작업순서        
    V_PROC_CD              TB_MAS012.PROC_CD%TYPE;
    V_MATNR	           	   TB_SCH017.MATNR%TYPE;              --자재코드

    V_DOC_NO_1             VARCHAR2(20);
    V_DOC_SEQNO_1          NUMBER;
    V_DOC_NO_2             VARCHAR2(20);
    V_DOC_SEQNO_2          NUMBER;
    V_MACH_CD	           TB_INV010.MACH_CD%TYPE;            --설비코드
    V_SEQNO                TB_INV010.SEQNO%TYPE;              --순번 
    V_IND_BCD	           TB_INV010.IND_BCD%TYPE;            --개별바코드
    V_LOT_NO               TB_INV010.LOT_NO%TYPE;             --LOT NO
    V_PDOC_NO              TB_INV005.PDOC_NO%TYPE;
    V_INP_QTY              TB_INV005.INP_QTY%TYPE;
    V_CHG_QTY              TB_INV005.INP_QTY%TYPE;
    V_REM_QTY              TB_INV005.INP_QTY%TYPE;
    V_USE_QTY              TB_INV005.INP_QTY%TYPE;
    V_STCK_QTY             TB_INV005.INP_QTY%TYPE;
    V_STOR_LOC_CD          TB_MAS001.LGPRO%TYPE;
    V_INP_DT               TB_INV005.INP_DT%TYPE; 
    V_UNIT                 TB_INV005.UNIT%TYPE; 
    V_CNT                  NUMBER; 
    V_DOC_NO              TB_INV012.SDOC_NO%TYPE;
    V_DOC_SEQNO           TB_INV012.SDOC_SEQNO%TYPE;
    V_IN_QTY              TB_INV012.IN_QTY%TYPE;  
    V_CLOSE_QTY           TB_INV012.STCK_QTY%TYPE;    
    V_CLOSE_DT            VARCHAR2(10);  
    V_DATE                DATE := SYSDATE; 
    PROD_CUR              SYS_REFCURSOR;		-- 커서 정의
BEGIN
   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'Y';
   V_RUN_SQL := 'Y';

   V_JSON := JSON_OBJECT_T.PARSE(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.GET_STRING('SES_USER_ID');
   V_PLT_CD             :=       V_JSON.GET_STRING('SES_PLNTKY');

   /* 조건값 할당 */
   V_WERKS          	:=       V_JSON.GET_STRING('WERKS');	    --플랜트
   --V_MACH_CD            :=       V_JSON.GET_STRING('MACH_CD');      --생산호기
   V_PROC_CD            :=       V_JSON.GET_STRING('PROC_CD');      --생산호기
   V_SDATE 		        :=       V_JSON.GET_STRING('SDATE');   	    --시작투입일자
   V_EDATE 		        :=       V_JSON.GET_STRING('EDATE');   	    --종료투입일자
   V_MATNR 		    	:=       V_JSON.GET_STRING('MATNR');   		--자재코드

    --20221017 여한진 약품은 바코드 사용하지 않고 자재로만 관리
    IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/
        V_SQL := ' SELECT I000.WERKS,          --플랜트      
                           I000.INP_DT,         --투입일자(전기일)
                           I000.MACH_CD,        --설비코드
                           I000.MATNR,          --자재코드
                           M001.MATNR_NM,       --자재명
                           --I000.LOT_NO,         --LOT NO
                           --I000.IND_BCD,        --개별바코드
                           I000.USE_QTY,        --사용량
                           I000.USE_CHG_QTY,    --사용량 보정    
                           I000.UNIT            --단위
                       FROM(    
                            SELECT I005.WERKS,
                                   I005.MACH_CD, 
                                   I005.INP_DT, 
                                   I005.MATNR, 
                                   --NVL(TRIM(I005.LOT_NO), ''*'') AS LOT_NO, 
                                   --I005.IND_BCD, 
                                   SUM(I005.INP_QTY) USE_QTY, 
                                   '''' AS USE_CHG_QTY,
                                   I005.UNIT   
                              FROM (SELECT WERKS, MACH_CD, INP_DT, MATNR, 
                                           --NVL(TRIM(LOT_NO), ''*'') AS LOT_NO,
                                           --IND_BCD, 
                                           INP_QTY, UNIT 
                                      FROM TB_INV005 
                                     WHERE WERKS = ''' || V_WERKS || '''
                                       AND MACH_CD IN(SELECT MACH_CD
                                                        FROM TB_MAS012
                                                       WHERE PROC_CD = ''' || V_PROC_CD || ''')                                                         
                                                         AND INP_DT BETWEEN ''' || V_SDATE || ''' AND ''' || V_EDATE || '''
                                       AND ( MATNR NOT LIKE ''' || '25%' || ''' AND MATNR NOT LIKE ''' || '26%' || ''' ) -- 라미네이팅 자재 제외
                                     ORDER BY REGDATE                    
                                    )I005

                            GROUP BY I005.WERKS, I005.MACH_CD, I005.INP_DT, I005.MATNR, I005.UNIT   
                            ) I000,
                          TB_MAS001 M001
                         WHERE I000.WERKS = M001.WERKS(+)
                           AND I000.MATNR = M001.MATNR(+)  
                    ORDER BY I000.WERKS, I000.INP_DT, I000.MACH_CD, I000.MATNR';

		OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SUB_LIST' THEN  /*하단 조회 리스트*/
        --SELECT 
        V_ARR_HEAD          := TREAT(V_JSON.get ('list') AS json_object_t);
        V_OBJ               := TREAT(V_ARR_HEAD.get ('map') AS json_object_t);

        V_MACH_CD           :=  V_OBJ.get_string('MACH_CD');        
        V_INP_DT            :=  V_OBJ.get_string('INP_DT');            
        V_MATNR             :=  V_OBJ.get_string('MATNR');          --투입자재코드
        V_LOT_NO            :=  V_OBJ.get_string('LOT_NO');         --투입자재 LOT NO

        --기말재고
        V_CLOSE_DT := TO_CHAR(TO_DATE(SUBSTR(V_SDATE, 1, 6) || '01', 'YYYY-MM-DD') - 1, 'YYYYMMDD');

        BEGIN
        SELECT STCK_QTY INTO V_CLOSE_QTY
          FROM TB_INV016
         WHERE WERKS = V_WERKS
           AND PRFM_DT = V_CLOSE_DT
           AND MATNR = V_MATNR;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_CLOSE_QTY := 0;
        END;

--        --입고량
--        BEGIN
--        SELECT SUM(QTY) INTO V_IN_QTY
--          FROM TB_INV007
--         WHERE WERKS = V_WERKS
--           AND DLFL <> 'D'
--           AND MATNR = V_MATNR 
--           AND REQ_DIV IN ('10', '40', '50');
--           --AND NVL(TRIM(LOT_NO), '*') = NVL(TRIM('V_LOT_NO'), '*');
--        EXCEPTION
--            WHEN NO_DATA_FOUND THEN
--                V_IN_QTY := 0;
--        END;
--        
--        V_AVAIL_QTY :=  V_CLOSE_QTY + V_IN_QTY ;

        V_SQL := ' SELECT M001.MATNR_GRP_CD,                    --자재그룹
                           M001.MATNR_GRP_NM,                       --자재그룹명
                           I012.MATNR,                              --자재코드
                           M001.MATNR_NM,                           --자재명
                           ' || V_CLOSE_QTY || ' + I012.IN_QTY  AS AVAIL_QTY,       --가용재고
                           I012.USE_QTY                         AS TOT_USE_QTY,         --총사용량
                           ' || V_CLOSE_QTY || ' + I012.IN_QTY -  I012.USE_QTY AS REST_QTY  --잔량
                      FROM(
                            SELECT WERKS, MATNR, SUM(IN_QTY) AS IN_QTY, SUM(USE_QTY) AS USE_QTY
                              FROM TB_INV012
                             WHERE WERKS = ''' || V_WERKS || '''
                               AND MATNR = ''' || V_MATNR || '''
                               AND PRFM_DT BETWEEN ''' || V_SDATE || ''' AND ''' || V_EDATE || ''' 
                            GROUP BY WERKS, MATNR    
                            )I012,
                           TB_MAS001 M001
                     WHERE I012.WERKS = M001.WERKS(+)
                       AND I012.MATNR = M001.MATNR(+) ';

        OPEN P_RS_LIST FOR V_SQL; 
    ELSIF P_TYPE = 'SAVE' THEN      --마감

        --생산오더별 투입자재 취소문서번호
        V_DOC_NO_1 := FN_GET_MDOCNO('M','IF143');
        V_DOC_SEQNO_1 := 0;

        --생산오더별 투입자재 실적문서번호
        V_DOC_NO_2 := FN_GET_MDOCNO('M','IF130');
        V_DOC_SEQNO_2 := 0;

        OPEN PROD_CUR FOR
            SELECT I000.WERKS,          --플랜트      
                   I000.INP_DT,         --투입일자(전기일)
                   --I000.MACH_CD,        --설비코드
                   I000.MATNR,          --자재코드
                   I000.LOT_NO,         --LOT NO
                   I000.INP_QTY,        --사용량
                   I000.UNIT            --단위
                   INTO 
                   V_WERKS,          --플랜트      
                   V_INP_DT,         --투입일자(전기일)
                   --V_MACH_CD,        --설비코드
                   V_MATNR,          --자재코드
                   V_LOT_NO,         --LOT NO
                   V_INP_QTY,        --사용량
--                   V_CHG_QTY,        --사용량 보정    
                   V_UNIT            --단위

               FROM(    
                    SELECT I005.WERKS,
                           --I005.MACH_CD, 
                           I005.INP_DT, 
                           I005.MATNR, 
                           I005.LOT_NO, 
                           SUM(I005.INP_QTY) INP_QTY, 
                           I005.UNIT   
                      FROM TB_INV005 I005
                     WHERE I005.WERKS =  V_WERKS 
                       AND I005.MACH_CD IN(SELECT MACH_CD
                                        FROM TB_MAS012
                                       WHERE PROC_CD = V_PROC_CD)
                       AND I005.INP_DT BETWEEN V_SDATE AND V_EDATE
                    --GROUP BY I005.WERKS, I005.MACH_CD, I005.INP_DT, I005.MATNR, I005.LOT_NO, I005.UNIT   
                    GROUP BY I005.WERKS, I005.INP_DT, I005.MATNR, I005.LOT_NO, I005.UNIT   
                    ) I000
            --ORDER BY I000.WERKS, I000.INP_DT, I000.MACH_CD, I000.MATNR, I000.LOT_NO;
            ORDER BY I000.WERKS, I000.INP_DT, I000.MATNR, I000.LOT_NO;
        LOOP
        --FETCH PROD_CUR INTO V_WERKS, V_INP_DT, V_MACH_CD, V_MATNR, V_LOT_NO, V_INP_QTY, V_UNIT;
        FETCH PROD_CUR INTO V_WERKS, V_INP_DT, V_MATNR, V_LOT_NO, V_INP_QTY, V_UNIT;
        EXIT WHEN PROD_CUR %NOTFOUND;    

            V_CNT := 1;
            BEGIN
            SELECT USE_QTY, DOC_NO, DOC_SEQNO
                INTO V_USE_QTY, V_DOC_NO, V_DOC_SEQNO
              FROM TB_INV012
             WHERE WERKS = V_WERKS
               --AND MACH_CD = V_MACH_CD
               AND PRFM_DT = V_INP_DT
               AND MATNR = V_MATNR
               AND NVL(TRIM(LOT_NO), '*') = NVL(TRIM(V_LOT_NO), '*');
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_CNT := 0;
                    V_DOC_NO := '';
                    V_DOC_SEQNO := '';
            END;

            SELECT LGPRO
                INTO V_STOR_LOC_CD
              FROM TB_MAS001
             WHERE WERKS = V_WERKS
               AND MATNR = V_MATNR;

            IF NVL(V_INP_QTY,0) > 0 THEN
                IF NVL(V_DOC_NO, ' ') = ' ' THEN   --투입자재 등록
                    V_DOC_SEQNO_2 := V_DOC_SEQNO_2 + 1;

                    INSERT INTO TB_IFS008(AUFNR, POSNR, BUDAT, MATNR, MENGE,
                                        LGORT, CHARG, MDOCNO, MDOCSEQ, ZRESULT, 
                                        MAKE_DATE, MAKER, WORKCENTERCODE, WERKS)
                              VALUES( '', '10', V_INP_DT, V_MATNR, NVL(V_INP_QTY, 0),
                                        V_STOR_LOC_CD, REPLACE(V_LOT_NO, '*', ''), V_DOC_NO_2, TO_CHAR(V_DOC_SEQNO_2), 'N', 
                                        V_DATE, V_SESS_USER_ID, '', V_WERKS);
                    IF V_CNT = 0 THEN
                        INSERT INTO TB_INV012(WERKS, MACH_CD, PRFM_DT, MATNR, LOT_NO,
                                                IN_QTY, USE_QTY, STCK_QTY, UNIT, DOC_NO, DOC_SEQNO, REGDATE, REGID)
                                        VALUES(V_WERKS, '1', V_INP_DT, V_MATNR, NVL(TRIM(V_LOT_NO), '*'),
                                                0, NVL(V_INP_QTY, 0), 0, V_UNIT, V_DOC_NO_2, V_DOC_SEQNO_2, V_DATE, V_SESS_USER_ID); 
                    END IF;

                ELSE        --투입자재 취소
                    IF NVL(V_USE_QTY, 0) > 0 AND NVL(V_INP_QTY, 0) <> NVL(V_USE_QTY, 0) THEN
                        V_DOC_SEQNO_1 := V_DOC_SEQNO_1 + 1;

                        INSERT INTO TB_IFS014(AUFNR, POSNR, BUDAT, MATNR, MENGE, WERKS,
                                            LGORT, CHARG, WORKCENTERCODE, MDOCNO, MDOCSEQ, 
                                            MBLNR, MJAHR, ZRESULT, MAKE_DATE, MAKER)
                                   VALUES('', '10', V_INP_DT, V_MATNR, NVL(V_USE_QTY, 0), V_WERKS,
                                            V_STOR_LOC_CD, REPLACE(V_LOT_NO, '*', ''), '', V_DOC_NO_1, TO_CHAR(V_DOC_SEQNO_1),
                                            '', '', 'N', V_DATE, V_SESS_USER_ID);

                        --투입자재 등록
                        V_DOC_SEQNO_2 := V_DOC_SEQNO_2 + 1;

                        INSERT INTO TB_IFS008(AUFNR, POSNR, BUDAT, MATNR, MENGE,
                                            LGORT, CHARG, MDOCNO, MDOCSEQ, ZRESULT, 
                                            MAKE_DATE, MAKER, WORKCENTERCODE, WERKS)
                                  VALUES( '', '10', V_INP_DT, V_MATNR, NVL(V_INP_QTY, 0),
                                            V_STOR_LOC_CD, REPLACE(V_LOT_NO, '*', ''), V_DOC_NO_2, TO_CHAR(V_DOC_SEQNO_2), 'N', 
                                            V_DATE, V_SESS_USER_ID, '', V_WERKS);
                        --입고수량
                        BEGIN
                        SELECT SUM(QTY) INTO V_IN_QTY
                          FROM TB_INV007
                         WHERE WERKS = V_WERKS
                           AND DLFL <> 'D'
                           AND MATNR = V_MATNR 
                           AND REQ_DIV IN ('10', '40', '50')
                           AND NVL(TRIM(LOT_NO), '*') = NVL(TRIM('V_LOT_NO'), '*');
                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                V_IN_QTY := 0;
                        END;

                        UPDATE TB_INV012
                           SET IN_QTY = NVL(V_IN_QTY, 0),
                               USE_QTY = NVL(V_INP_QTY, 0),
                               DOC_NO = V_DOC_NO_2,
                               DOC_SEQNO = V_DOC_SEQNO_2
                         WHERE WERKS = V_WERKS
                           --AND MACH_CD = V_MACH_CD
                           AND PRFM_DT = V_INP_DT
                           AND MATNR = V_MATNR
                           AND NVL(TRIM(LOT_NO), '*') = NVL(TRIM(V_LOT_NO), '*');  

                        --일일재고생성   
                        SELECT STCK_QTY INTO V_STCK_QTY
                          FROM TB_INV001
                         WHERE WERKS = V_WERKS
                           AND MATNR = V_MATNR;

                        SELECT COUNT(*) INTO V_CNT
                          FROM TB_INV016
                         WHERE WERKS = V_WERKS
                           AND PRFM_DT = V_INP_DT
                           AND MATNR = V_MATNR;
                           --AND LOT_NO = NVL(TRIM(V_LOT_NO), ' ');

                        IF V_CNT > 0 THEN
                            UPDATE TB_INV016
                               SET STCK_QTY = V_STCK_QTY,
                                   UPDDATE = V_DATE
                             WHERE WERKS = V_WERKS
                               AND PRFM_DT = V_INP_DT
                               AND MATNR = V_MATNR;
                              -- AND LOT_NO = NVL(TRIM(V_LOT_NO), ' ');
                        ELSE
                            INSERT INTO TB_INV016(WERKS, PRFM_DT, MATNR, LOT_NO, STCK_QTY, UNIT, REGDATE)
                                      VALUES(V_WERKS, V_INP_DT, V_MATNR, ' ', V_STCK_QTY, V_UNIT, V_DATE);
                        END IF;
                    END IF;           
                END IF;
            END IF;        
        END LOOP;


    ELSIF P_TYPE = 'SAVE1' THEN     --보정
        V_ARR_LIST              := V_JSON.get_array ('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ           := TREAT(V_ARR_LIST.get (i) AS json_object_t); 
            V_OBJ           := TREAT(V_OBJ.get ('map') AS json_object_t);

            V_WERKS			    :=       V_OBJ.get_string('WERKS');		      --플랜트
            V_INP_DT            :=       V_OBJ.get_string('INP_DT');		      --투입일자(전기일)
            V_MACH_CD           :=       V_OBJ.get_string('MACH_CD');		      --설비코드
            V_MATNR             :=       V_OBJ.get_string('MATNR');		      --자재코드
            --V_LOT_NO	        :=       V_OBJ.get_string('LOT_NO');            --LOT NO
            --V_IND_BCD         :=       V_OBJ.get_string('IND_BCD');		     --개별바코드
            V_INP_QTY	        :=       NVL(TRIM(V_OBJ.get_string('USE_QTY')), 0);            --사용량
            V_CHG_QTY	        :=       V_OBJ.get_string('USE_CHG_QTY');        --투입량보정
            V_UNIT              :=       V_OBJ.get_string('UNIT');            --단위

            V_REM_QTY := V_CHG_QTY - V_INP_QTY;
            V_DATE := V_DATE + 1/86400;
            V_PDOC_NO := 'P' || TO_CHAR(V_DATE, 'YYYYMMDDHH24MISS');

            INSERT INTO TB_INV005 (   --약품 투입이력
                                 WERKS	    --플랜트코드
                               , MACH_CD    --설비코드
                               , PDOC_NO
                               , INP_DT	    --투입일자
                               , INP_ID		--작업자ID
                               , WRK_SHIFT	--작업조 코드
                               , MATNR	    --자재코드
                               , IND_BCD	--공급업체바코드
                               , LOT_NO     --LOT_NO
                               , UNIT	    --단위
                               , INP_QTY	--투입량
                               , REGDATE	--등록일자
                               , REGID	    --등록자ID
                        ) VALUES (
                                 V_WERKS      	    --플랜트코드
                               , V_MACH_CD          --설비코드
                               , V_PDOC_NO
                               , V_INP_DT	        --투입일자(YYYY-MM-DD)
                               , V_SESS_USER_ID		--작업자ID
                               , ''		            --작업조 코드
                               , V_MATNR	        --자재코드
                               , ' '    	        --공급업체바코드
                               , NVL(TRIM(V_LOT_NO), '*')           --LOT_NO    
                               , V_UNIT	            --단위
                               , V_REM_QTY	        --투입량
                               , SYSDATE		    --등록일시
                               , V_SESS_USER_ID	    --등록자ID
                        ) ;

            SELECT LGPRO  INTO V_STOR_LOC_CD
              FROM TB_MAS001
             WHERE WERKS = V_WERKS
               AND MATNR = V_MATNR;

            UPDATE TB_INV001
               SET STCK_QTY = STCK_QTY + V_REM_QTY
             WHERE WERKS = V_WERKS
               AND STOR_LOC_CD = V_STOR_LOC_CD
               --AND NVL(IND_BCD, '*') = V_IND_BCD
               AND MATNR = V_MATNR;
               --AND NVL(TRIM(LOT_NO), '*') = NVL(TRIM(V_LOT_NO), '*');   

        END LOOP;
    END IF;

    IF V_DOC_SEQNO_1 > 0 THEN
        P_DOC_NO1 := V_DOC_NO_1;
    END IF;

    IF V_DOC_SEQNO_2 > 0 THEN
        P_DOC_NO2 := V_DOC_NO_2;
    END IF;
    P_SUCCESS := 'Y'; 
    COMMIT;

--    EXCEPTION
--    WHEN E_EXCEPTION_USER THEN
--
--        -- 에러 내역 SET
--        P_SUCCESS := 'N';
--        E_SQL_ERR_CD := SQLCODE;
--        E_SQL_ERR_MSG := SUBSTRB(SQLERRM, 1, 300);
--        ROLLBACK;
--        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--    WHEN OTHERS THEN
--        P_SUCCESS := 'N';
--        E_SQL_ERR_CD := SQLCODE;
--        E_SQL_ERR_MSG := 'EXCEPTION OTHER ERROR. ['
--                         || SUBSTR(SQLERRM, 1, 500)
--                         || ']';
--        ROLLBACK;
--        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
--        RAISE;
END;

/
