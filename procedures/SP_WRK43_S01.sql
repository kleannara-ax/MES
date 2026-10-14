
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK43_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK43_S01
 * PROGRAM NAME  : 재고실사 조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 재고실사 조회
 *                 
 * AUTHOR NAME   : 강현주
 * CREATE DATE   : 2022/07/21
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/07/21    1.0.0   강현주         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_INV009] 	: ( R  ) 공정재고실사 테이블 
 *        - [TB_INV008] 	: ( R  ) 공정재고실사 테이블
 *        - [TB_WRK002] 	: ( R  ) 생산실적(PS) 테이블 
 *        - [TB_MAS001] 	: ( R  ) 자재마스타 테이블
 *        - [TB_MAS012] 	: ( R  ) 설비 마스터 테이블

 *=============================================================================*/


AS
	V_PRG_NM          	VARCHAR2(100) 	:= 'SP_WRK43_S01';     -- PROCEDURE NAME

	-- 오라클 에러 처리용 변수선언 영역
   E_EXCEPTION_USER  	EXCEPTION;
   E_SQL_ERR_CD      	NUMBER(5) 		:= 0;
   E_SQL_ERR_MSG		    VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON				      JSON_OBJECT_T;
    V_ARR_LIST       	  JSON_ARRAY_T;
    V_OBJ            	  JSON_OBJECT_T;

	-- 세션값 처리용 변수선언 영역
    V_SESS_USER_ID   	  varchar2(20);
    V_PLT_CD         	  varchar2(10);
    V_DEBUG          	  varchar2(1);

	-- 조건절 처리용 변수선언 영역	
	V_SQL				    CLOB;
	V_SDATE                 VARCHAR2(10);
    V_EDATE                 VARCHAR2(10);
	V_RANGE_SQL      	    varchar2(4000);						--실적일자

    V_WERKS        		    TB_INV009.WERKS%TYPE;				--플랜트코드	
    V_WRK_ORDR_NO           TB_INV009.WRK_ORDR_NO%TYPE;			--작업지시번호
    V_IND_BCD               TB_INV009.IND_BCD%TYPE;			    --개별바코드
    V_STOR_LOC_CD           TB_INV009.STOR_LOC_CD%TYPE;			--저장위치
    V_MATNR                 TB_INV009.MATNR%TYPE;			    --자재코드
    V_CHG_QTY               TB_INV009.STCK_QTY%TYPE;			--실사보정수량
    V_MATNR_FLG             VARCHAR2(10);
    V_STOR_LOC_FLG          VARCHAR2(10);
    V_LOT_NO                TB_INV009.LOT_NO%TYPE;
    V_STCK_QTY              TB_INV009.STCK_QTY%TYPE;
    V_REAL_QTY              TB_INV009.REAL_QTY%TYPE;
    V_CHG_STCK_QTY          TB_INV009.CHG_STCK_QTY%TYPE;
    V_CHG_UNIT_FLG          TB_INV009.CHG_UNIT_FLG%TYPE;
    V_CHG_UNIT_QTY          TB_INV009.CHG_UNIT_QTY%TYPE;
    V_CHG_UNIT              TB_INV009.CHG_UNIT%TYPE;
    V_DATE                  DATE := SYSDATE;
    PROD_CUR        SYS_REFCURSOR;		-- 커서 정의
    
    V_LOC_CD                VARCHAR2(10);
BEGIN
	OPEN P_RS_LIST FOR 

	SELECT NULL FROM DUAL WHERE ROWNUM = 0;
	V_JSON 				:= JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID	:= V_JSON.get_string('SES_USER_ID');
	V_PLT_CD			:= V_JSON.get_string('SES_PLNTKY');

	V_WERKS				:= V_JSON.get_string('WERKS');			      --플랜트코드	
	V_SDATE             := V_JSON.get_string('SDATE');			      --시작일자
    V_EDATE             := V_JSON.get_string('EDATE');			      --종료일자
    V_RANGE_SQL         := V_JSON.get_string('RANGE_SQL');	          --지시일자
	V_WRK_ORDR_NO		:= V_JSON.get_string('WRK_ORDR_NO');	      --실사작업지시번호


	IF P_TYPE = 'LIST' THEN
--        V_DEBUG := 'Y';

        V_SQL := 'SELECT I009.WERKS,
                           I009.WRK_ORDR_NO,
                           I009.STOR_LOC_CD,
                           M003.STOR_LOC_NM,    --저장위치명
                           I009.LOC_CD,
                           M028.LOC_NM,
                           FN_CD_VAL(''STCK_STA'', I001.STCK_STA) AS STCK_STA,
                           NVL(TRIM(I009.LOT_NO), ''*'')       AS LOT_NO,
                           NVL(TRIM(I009.IND_BCD), ''*'')      AS IND_BCD,
                           I009.MATNR,
                           M001.MATNR_NM,
                           I001.UNIT,                            --단위추가
                           I009.STCK_QTY,
                           I009.REAL_QTY AS REAL_INSP_QTY,
                           NVL(I009.STCK_QTY, 0) - NVL(I009.REAL_QTY, 0)  AS DIFF_QTY, 
                           ''''  AS CHG_STCK_QTY,
                           NVL(I009.CHG_UNIT_FLG, ''N'')  AS CHG_UNIT_FLG,
                           NVL(I009.CHG_UNIT_QTY, '''')  AS CHG_UNIT_QTY,
                           NVL(I009.CHG_UNIT, '''') AS CHG_UNIT
                      FROM TB_INV009 I009
                           INNER JOIN TB_INV001 I001
                           ON I009.WERKS = I001.WERKS
                           AND I009.IND_BCD = I001.IND_BCD
                           INNER JOIN TB_MAS003 M003
                           ON I009.WERKS = M003.WERKS
                           AND I009.STOR_LOC_CD = M003.STOR_LOC_CD
                           LEFT JOIN TB_MAS028 M028
                           ON I009.WERKS = M028.WERKS
                           AND I009.STOR_LOC_CD = M028.STOR_LOC_CD
                           AND I009.LOC_CD = M028.LOC_CD
                           INNER JOIN TB_MAS001 M001
                           ON I009.WERKS = M001.WERKS
                           AND I009.MATNR = M001.MATNR
                     WHERE 1=1
					   --AND I009.WERKS = ''' || V_WERKS || '''
                       --AND I009.WRK_ORDR_NO = ''' || V_WRK_ORDR_NO || '''
						';
		IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
			V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'WERKS', 'I009.WERKS');	--플랜트
			V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'WRK_ORDR_NO', 'I009.WRK_ORDR_NO');	--작업지시번호
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;
        /*
        SELECT MAX(MATNR_FLG), MAX(STOR_LOC_FLG)
            INTO V_MATNR_FLG, V_STOR_LOC_FLG
          FROM TB_INV015
         WHERE WRK_ORDR_NO = V_WRK_ORDR_NO;

         V_SQL := ' SELECT A.WERKS,             --플랜트
                           A.WRK_ORDR_NO,       --실사지시번호
                           A.STOR_LOC_CD,       --저장위치
                           M003.STOR_LOC_NM,    --저장위치명
                           A.LOC_CD,
                           M028.LOC_NM,
                           A.LOT_NO,            --LOT NO
                           A.IND_BCD,           --개별바코드
                           A.MATNR,             --자재코드
                           M001.MATNR_NM,       --자재명
                           A.STCK_QTY,          --재고수량
                           A.REAL_INSP_QTY,          --실사수량
                           A.STCK_QTY - NVL(A.REAL_INSP_QTY, 0)  AS DIFF_QTY,      --차이수량 
                           ''''  AS CHG_STCK_QTY,
                           A.CHG_UNIT_FLG,      --대체단위 여부
                           A.CHG_UNIT_QTY,      --대체단위 수량
                           A.CHG_UNIT           --대체단위
                      FROM(
                            SELECT I001.WERKS,
                                   I001.WRK_ORDR_NO,
                                   CASE WHEN NVL(I009.STOR_LOC_CD, '' '') <> '' ''  THEN NVL(I009.STOR_LOC_CD, '' '') ELSE I001.STOR_LOC_CD END   AS STOR_LOC_CD,
                                   CASE WHEN NVL(I009.LOC_CD, '' '') <> '' ''  THEN NVL(I009.LOC_CD, '' '') ELSE I001.LOC_CD END   AS LOC_CD,
                                   CASE WHEN NVL(I001.LOT_NO, '' '') <> '' ''  THEN NVL(I001.LOT_NO, '' '') ELSE I009.STOR_LOC_CD END             AS LOT_NO,
                                   CASE WHEN NVL(I001.IND_BCD, '' '') <> '' ''  THEN NVL(I001.IND_BCD, '' '') ELSE I009.IND_BCD END               AS IND_BCD,
                                   CASE WHEN NVL(I001.MATNR, '' '') <> '' ''  THEN NVL(I001.MATNR, '' '') ELSE I009.MATNR END                     AS MATNR,
                                   CASE WHEN NVL(I001.STCK_QTY, ''0'') <> ''0''  THEN NVL(I001.STCK_QTY, ''0'') ELSE I009.STCK_QTY END            AS STCK_QTY,
                                   CASE WHEN NVL(I001.REAL_QTY, ''0'') <> ''0''  THEN NVL(I001.REAL_QTY, ''0'') ELSE I009.REAL_QTY END            AS REAL_INSP_QTY,
                                   NVL(I009.CHG_UNIT_FLG, ''N'')      AS CHG_UNIT_FLG,
                                   NVL(I009.CHG_UNIT_QTY, ''0'')      AS CHG_UNIT_QTY,
                                   NVL(I009.CHG_UNIT, '''')           AS CHG_UNIT
                              FROM (SELECT WERKS,
                                         ''' || V_WRK_ORDR_NO || '''    AS WRK_ORDR_NO,
                                         STOR_LOC_CD,
                                         LOC_CD,
                                         NVL(TRIM(LOT_NO),''*'')        AS LOT_NO,
                                         NVL(TRIM(IND_BCD), ''*'')      AS IND_BCD,
                                         MATNR,
                                         STCK_QTY,
                                         0      AS REAL_QTY,
                                         ''N''    AS CHG_UNIT_FLG,
                                         ''''      AS CHG_UNIT_QTY,
                                         ''''     AS CHG_UNIT
                                    FROM TB_INV001
                                   WHERE WERKS = ''' || V_WERKS || '''';

        IF NVL(V_STOR_LOC_FLG, 'N') = 'N' THEN
            V_SQL := V_SQL || ' AND STOR_LOC_CD IN (SELECT STOR_LOC_CD
                                                      FROM TB_INV015
                                                     WHERE WRK_ORDR_NO = ''' || V_WRK_ORDR_NO || '''
                                                       AND TO_CHAR(REGDATE, ''YYYYMMDD'') BETWEEN ''' || V_SDATE || ''' AND ''' || V_EDATE || '''
                                                       AND TRIM(STOR_LOC_CD) IS NOT NULL)'; 

            V_SQL := V_SQL || ' AND LOC_CD IN (SELECT LOC_CD
                                                      FROM TB_INV015
                                                     WHERE WRK_ORDR_NO = ''' || V_WRK_ORDR_NO || '''
                                                       AND TO_CHAR(REGDATE, ''YYYYMMDD'') BETWEEN ''' || V_SDATE || ''' AND ''' || V_EDATE || '''
                                                       AND TRIM(LOC_CD) IS NOT NULL)'; 
        END IF;

        IF NVL(V_MATNR_FLG, 'N') = 'N' THEN
            V_SQL := V_SQL || ' AND MATNR IN (SELECT MATNR
                                                FROM TB_INV015
                                               WHERE WRK_ORDR_NO = ''' || V_WRK_ORDR_NO || '''
                                                 AND TO_CHAR(REGDATE, ''YYYYMMDD'') BETWEEN ''' || V_SDATE || ''' AND ''' || V_EDATE || '''
                                                 AND TRIM(MATNR) IS NOT NULL)'; 
        END IF;                                   
        V_SQL := V_SQL || '     AND STCK_QTY > 0) I001';
        V_SQL := V_SQL || '   FULL OUTER JOIN
                                   (SELECT WERKS,
                                           WRK_ORDR_NO,
                                           STOR_LOC_CD,
                                           LOC_CD,
                                           NVL(TRIM(LOT_NO), ''*'')       AS LOT_NO,
                                           NVL(TRIM(IND_BCD), ''*'')      AS IND_BCD,
                                           MATNR,
                                           STCK_QTY,
                                           REAL_QTY,
                                           NVL(CHG_UNIT_FLG, ''N'')  AS CHG_UNIT_FLG,
                                           NVL(CHG_UNIT_QTY, '''')  AS CHG_UNIT_QTY,
                                           NVL(CHG_UNIT, '''') AS CHG_UNIT
                                      FROM TB_INV009
                                     WHERE WERKS = ''' || V_WERKS || '''
                                       AND WRK_ORDR_NO = ''' || V_WRK_ORDR_NO || '''
                                       AND TO_CHAR(REGDATE, ''YYYYMMDD'') BETWEEN ''' || V_SDATE || ''' AND ''' || V_EDATE || ''') I009
                                     ON  I001.WERKS = I009.WERKS
                                     AND I001.WRK_ORDR_NO = I009.WRK_ORDR_NO
                                     AND I001.STOR_LOC_CD = I009.STOR_LOC_CD
                                     AND I001.LOT_NO = I009.LOT_NO
                                     AND I001.IND_BCD = I009.IND_BCD
                              ) A,
                              TB_MAS001 M001,
                              TB_MAS003 M003,
                              TB_MAS028 M028
                       WHERE A.WERKS = M001.WERKS(+)
                         AND A.MATNR = M001.MATNR(+)
                         AND A.WERKS = M003.WERKS(+)
                         AND A.STOR_LOC_CD = M003.STOR_LOC_CD(+)
                         AND A.WERKS = M028.WERKS(+)
                         AND A.STOR_LOC_CD = M028.STOR_LOC_CD(+)
                         AND A.LOC_CD = M028.LOC_CD(+)';       
         */
        V_DEBUG := 'Y';
        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG (SQL_STR) VALUES (V_SQL);
            COMMIT;
        END IF;

        OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SAVE' THEN          --저장
        V_ARR_LIST                  := V_JSON.get_array('list');
        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP

	        V_OBJ				:= TREAT (V_ARR_LIST.get (i) AS json_object_t);  
            V_OBJ				:= TREAT (V_OBJ.get ('map') AS json_object_t);

            V_WERKS             := V_OBJ.get_string('WERKS');		    --플랜트
            V_WRK_ORDR_NO       := V_OBJ.get_string('WRK_ORDR_NO');		--실사작업지시번호
            V_STOR_LOC_CD       := V_OBJ.get_string('STOR_LOC_CD');		--저장위치
            V_LOT_NO            := V_OBJ.get_string('LOT_NO');		    --LOT_NO
            V_IND_BCD           := V_OBJ.get_string('IND_BCD');		    --개별바코드
            V_MATNR             := V_OBJ.get_string('MATNR');		    --자재코드
            V_STCK_QTY          := V_OBJ.get_string('STCK_QTY');		--재고수량
            V_REAL_QTY          := V_OBJ.get_string('REAL_INSP_QTY');		--실사수량
            V_CHG_STCK_QTY      := V_OBJ.get_string('CHG_STCK_QTY');	--실사보정수량
            V_CHG_UNIT_FLG      := V_OBJ.get_string('CHG_UNIT_FLG');    --대체단위 여부
            V_CHG_UNIT_QTY      := V_OBJ.get_string('CHG_UNIT_QTY');    --대체단위 수량
            V_CHG_UNIT          := V_OBJ.get_string('CHG_UNIT');        --대체단위

            UPDATE TB_INV009
               SET CHG_STCK_QTY = NVL(V_CHG_STCK_QTY, 0),
                   CHG_UNIT_FLG = NVL(V_CHG_UNIT_FLG, 'N'),
                   CHG_UNIT_QTY = NVL(V_CHG_UNIT_QTY, 0),
                   CHG_UNIT = NVL(V_CHG_UNIT, 'N'),
                   UPDDATE = V_DATE,
                   UPDID = V_SESS_USER_ID
             WHERE WERKS = V_WERKS  
               AND WRK_ORDR_NO = V_WRK_ORDR_NO
               AND STOR_LOC_CD = V_STOR_LOC_CD
               AND IND_BCD = V_IND_BCD;

       END LOOP;
	ELSIF P_TYPE = 'SAVE2' THEN         --확정
        OPEN PROD_CUR FOR
            SELECT STOR_LOC_FLG, STOR_LOC_CD, LOC_CD, MATNR_FLG, MATNR
                INTO V_STOR_LOC_FLG, V_STOR_LOC_CD, V_LOC_CD, V_MATNR_FLG, V_MATNR
              FROM TB_INV015
             WHERE WERKS = V_WERKS
               AND WRK_ORDR_NO = V_WRK_ORDR_NO;
        LOOP
        FETCH PROD_CUR INTO V_STOR_LOC_FLG, V_STOR_LOC_CD, V_LOC_CD, V_MATNR_FLG, V_MATNR;
        EXIT WHEN PROD_CUR %NOTFOUND; 
        
            IF V_STOR_LOC_FLG = 'N' THEN
                UPDATE TB_INV001
                   SET STCK_QTY = 0,
                       OLD_QTY = STCK_QTY,
                       UPDDATE = V_DATE,
                       UPDID = 'MES'
                  WHERE WERKS = V_WERKS
                    AND STOR_LOC_CD = V_STOR_LOC_CD
                    AND LOC_CD = V_LOC_CD;
            ELSE
                UPDATE TB_INV001
                   SET STCK_QTY = 0,
                       OLD_QTY = STCK_QTY,
                       UPDDATE = V_DATE,
                       UPDID = 'MES'
                  WHERE WERKS = V_WERKS
                    AND STOR_LOC_CD = V_STOR_LOC_CD;
            END IF;
            
--            UPDATE TB
        END LOOP;
        
        UPDATE TB_INV001 I001
           SET (I001.STOR_LOC_CD, I001.LOC_CD, I001.STCK_QTY, I001.WGT, I001.STCK_STA)
              =(SELECT I009.STOR_LOC_CD, I009.LOC_CD, CASE WHEN I001.UNIT = 'EA' THEN I009.REAL_QTY * 500 ELSE I009.REAL_QTY END, 
                    CASE WHEN I001.UNIT = 'EA' OR  I001.UNIT = 'R' THEN (TO_NUMBER(SUBSTR(I009.MATNR, 10, 4)) /1000) * (TO_NUMBER(SUBSTR(I009.MATNR, 14, 4)) /1000) * (TO_NUMBER(SUBSTR(I009.MATNR, 6, 3)) /1000) * (I009.REAL_QTY * 500)
                         ELSE I009.REAL_QTY 
                    END, '00'
                 FROM TB_INV009 I009
                WHERE I001.WERKS = I009.WERKS
                  AND I001.IND_BCD = I009.IND_BCD
                  AND I009.WERKS = V_WERKS
                  AND I009.WRK_ORDR_NO = V_WRK_ORDR_NO)
          WHERE I001.WERKS = V_WERKS
            AND I001.IND_BCD IN (SELECT IND_BCD
                                   FROM TB_INV009
                                  WHERE WERKS = V_WERKS
                                    AND WRK_ORDR_NO = V_WRK_ORDR_NO)
            AND I001.STCK_STA <> '10';                        
            
        RETURN;
    ELSIF P_TYPE = 'SAVE3' THEN         --결재
        RETURN;
    ELSIF P_TYPE = 'DELETE' THEN        --취소
        RETURN;
    END IF;

	P_SUCCESS := 'Y';
    COMMIT;
--	EXCEPTION
--    WHEN E_EXCEPTION_USER THEN
--
--    -- 에러 내역 SET
--    P_SUCCESS           := 'N';
--    E_SQL_ERR_CD        := SQLCODE;
--		E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);
--
--		ROLLBACK;
--		SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--
--	WHEN OTHERS THEN
--		P_SUCCESS			:= 'N';
--    E_SQL_ERR_CD        := SQLCODE;
--		E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--		ROLLBACK;
--		RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
