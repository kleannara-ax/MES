--------------------------------------------------------
--  DDL for Procedure SP_INV10_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_INV10_S01" (
	P_TYPE           IN    varchar2, -- LIST, SUB_LIST
	P_JSON_STR       IN    CLOB ,
	P_SUCCESS       OUT    varchar2,
    P_ERR_MSG       OUT    varchar2,
    P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : INV10{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 자재사용이력{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 자재사용이력을 관리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 여한진{최초 작성자 명 기술}
 * CREATE DATE   : 2022/11/18 {최초 작성일자 기술}
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
 *      - [TB_INV010] : (.R..) 자재투입이력
 *      - [TB_MAS012] : (.R..) 설비 마스터
 *      - [TB_MAS001] : (.R..) 자재
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_INV10_S01';     -- PROCEDURE NAME

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
    V_DATE          DATE := SYSDATE;
    V_WERKS			TB_INV010.WERKS%TYPE;
    V_MACH_CD       TB_INV010.MACH_CD%TYPE;
    V_MATNR 		TB_INV010.MATNR%TYPE;
    V_IND_BCD       TB_INV010.IND_BCD%TYPE;

	-- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역
	V_PRFM_DT     		TB_INV010.PRFM_DT%TYPE;
	V_INP_DT			TB_INV010.INP_DT%TYPE;
	V_LOT_NO			TB_INV010.LOT_NO%TYPE;
	V_SEQNO				TB_INV010.SEQNO%TYPE;
	V_WRK_ORDR_NO		TB_INV010.WRK_ORDR_NO%TYPE;
	V_WRK_ORDR_SEQNO	TB_INV010.WRK_ORDR_SEQNO%TYPE;
	V_MATNR_M    		TB_INV010.MATNR_M%TYPE;
	V_IND_BCD_M   		TB_INV010.IND_BCD_M%TYPE;
	V_LOT_NO_M			TB_INV010.LOT_NO_M%TYPE;
	V_USE_QTY    		TB_INV010.USE_QTY%TYPE;	
    V_STCK_QTY1         TB_INV010.USE_QTY%TYPE;	
    V_STCK_QTY2         TB_INV010.USE_QTY%TYPE;	
    V_USE_CHG_QTY       TB_INV010.USE_QTY%TYPE;	
	V_UNIT   			TB_INV010.UNIT%TYPE;
    V_ORDER_NO          TB_INV001.ORDER_NO%TYPE;
    V_CHG_QTY           TB_INV010.USE_QTY%TYPE; 
    V_STCK_QTY_PRE      TB_INV001.STCK_QTY%TYPE;
    V_SEQNO1            TB_INV010.SEQNO%TYPE;    
    PROD_CUR            SYS_REFCURSOR;		-- 커서 정의
    PROD_CUR2           SYS_REFCURSOR;		-- 커서 정의
BEGIN

    OPEN P_RS_LIST FOR 
    SELECT NULL FROM DUAL WHERE ROWNUM = 0;

    V_DEBUG := 'N';
    V_RUN_SQL := 'Y';

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

    V_SESS_USER_ID       :=      V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=      V_JSON.get_string('SES_PLNTKY');

    /* 조건값 할당 */
    V_RANGE_SQL         :=      V_JSON.get_string('RANGE_SQL');	--실적일자, 자재코드
    V_WERKS		        :=      V_JSON.get_string('WERKS');     --플랜트
    V_MACH_CD           :=      V_JSON.get_string('MACH_CD');   --설비코드
    V_IND_BCD           :=      V_JSON.get_string('IND_BCD');   --개별바코드

    IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

        V_SQL := ' SELECT I010.WERKS,      		--플랜트
                          I010.PRFM_DT,     	--실적일자
					  	  I010.INP_DT,			--투입일자
                          I010.MACH_CD,    		--설비코드
                          M012.MACH_NM,    		--설비명
                          I010.MATNR,      		--자재코드
                          M001.MATNR_NM,   		--자재명
					      I010.LOT_NO,			--LOT번호
                          I010.IND_BCD,    		--개별 바코드
						  I010.SEQNO,			--순번
						  I001.ORDER_NO,		--오더번호
						  I010.WRK_ORDR_NO,		--작업지시번호
						  I010.WRK_ORDR_SEQNO,	--작업지시순번
                          I010.MATNR_M,    		--투입자재코드
                          M002.MATNR_NM    IN_MATNR_NM,    --투입자재명
                          I010.IND_BCD_M,   --투입개별 바코드
						  I010.LOT_NO_M,	--투입LOTNO
                          I010.USE_QTY,    --사용량
                          ''0'' AS USE_CHG_QTY,     --사용량보정
                          I010.UNIT,   		--단위
                          CASE WHEN I010.USE_DIV = ''1'' THEN ''정상'' WHEN  I010.USE_DIV = ''2'' THEN ''사용량 보정'' ELSE ''폐품''END USE_DIV_NM,   --자재사용량 보정  
                          I010.REGDATE,     --등록일시
                          (SELECT NMLAST FROM USRMA WHERE USERID = I010.REGID) REGNM,   --등록자
                          I010.UPDDATE,     --수정일시 
                          (SELECT NMLAST FROM USRMA WHERE USERID = I010.UPDID) UPDNM   --수정자 
                     FROM TB_INV010 I010,  --자재투입이력
						  TB_INV001 I001,	--공정재고
                          TB_MAS012 M012,  --설비 마스터
                          TB_MAS001 M001,  --자재
                          TB_MAS001 M002   --자재
                    WHERE I010.MACH_CD = M012.MACH_CD(+)
                      AND I010.WERKS = M001.WERKS(+)
                      AND I010.MATNR = M001.MATNR(+)
                      AND I010.WERKS = M002.WERKS(+)
                      AND I010.MATNR_M = M002.MATNR(+)
				 	  AND I010.IND_BCD = I001.IND_BCD(+) 
                      AND NVL(I010.CNL_YN, ''N'') = ''N'' ';

        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN  --투입일자, 자재코드
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MATNR', 'MATNR_M');
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;

        IF V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN     --플랜트
            V_SQL := V_SQL || ' AND I010.WERKS = ''' || V_WERKS || ''' ';        
        END IF;
        
        IF  V_IND_BCD IS NOT NULL OR TRIM(V_IND_BCD) != '' THEN
            V_SQL := V_SQL || ' AND I010.IND_BCD_M LIKE ''%' || V_IND_BCD || '%''';        
        END IF;
        
        IF  V_MACH_CD IS NOT NULL OR TRIM(V_MACH_CD) != '' THEN
            V_SQL := V_SQL || ' AND I010.MACH_CD LIKE ''%' || V_MACH_CD || '%''';        
        END IF;
        
       	V_SQL := V_SQL || ' ORDER BY I010.WERKS, I010.MACH_CD, I010.INP_DT, I010.REGDATE ';

		OPEN P_RS_LIST FOR V_SQL;
	
    ELSIF P_TYPE = 'SAVE' THEN      --저장(사용량보정)
        
        V_ARR_LIST              := V_JSON.get_array ('list');
        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ					:= TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ					:= TREAT (V_OBJ.get ('map') AS json_object_t);
            
            V_WERKS     			:= V_OBJ.get_string('WERKS');    				--플랜트
            V_MACH_CD    			:= V_OBJ.get_string('MACH_CD');   				--설비코드
            V_MATNR      			:= V_OBJ.get_string('MATNR');      				--자재코드
            V_LOT_NO				:= V_OBJ.get_string('LOT_NO');					--LOT번호
			V_IND_BCD    			:= V_OBJ.get_string('IND_BCD');    				--개별 바코드
			V_SEQNO					:= V_OBJ.get_string('SEQNO');					--순번
            V_WRK_ORDR_NO			:= V_OBJ.get_string('WRK_ORDR_NO');				--작업지시번호
			V_WRK_ORDR_SEQNO		:= V_OBJ.get_string('WRK_ORDR_SEQNO');			--작업지시순번
			V_ORDER_NO              := V_OBJ.get_string('ORDER_NO');			    --작업지시순번
            V_PRFM_DT               := V_OBJ.get_string('PRFM_DT');			        --실적일자
            V_MATNR_M    			:= V_OBJ.get_string('MATNR_M');    				--투입자재코드
			V_IND_BCD_M   			:= V_OBJ.get_string('IND_BCD_M');   			--투입개별 바코드
			V_LOT_NO_M				:= V_OBJ.get_string('LOT_NO_M');				--투입LOTNO
			V_USE_QTY    			:= V_OBJ.get_string('USE_QTY');    				--사용량
			V_CHG_QTY               := V_OBJ.get_string('USE_CHG_QTY');    			--사용량보정
            V_UNIT   				:= V_OBJ.get_string('UNIT');   					--단위
        
            BEGIN
            SELECT NVL(I001.STCK_QTY, 0) + NVL(I003.STCK_QTY, 0) 
                INTO V_STCK_QTY_PRE
              FROM TB_INV001 I001,
                   (SELECT WERKS, IND_BCD, NVL(SUM(STCK_QTY), 0) AS STCK_QTY
                      FROM TB_INV003
                     WHERE WERKS = V_WERKS
                       AND IND_BCD = V_IND_BCD_M
                    GROUP BY WERKS, IND_BCD
                   ) I003
              WHERE I001.WERKS = I003.WERKS(+)
                AND I001.IND_BCD = I003.IND_BCD(+)
                AND I001.WERKS =  V_WERKS
                AND I001.IND_BCD = V_IND_BCD_M;
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
            
            BEGIN
            SELECT MAX(SEQNO) INTO V_SEQNO
              FROM TB_INV010
             WHERE WERKS = V_WERKS
               AND IND_BCD = V_IND_BCD;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_SEQNO := 0;
            END;   
            
            V_SEQNO := V_SEQNO + 1;
                        
            INSERT INTO TB_INV010(WERKS, MACH_CD, MATNR, IND_BCD, SEQNO,
                            WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO, 
                            IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, PRFM_DT,
                            USE_QTY, UNIT, CHG_FLG, STCK_KY, LOT_NUM,
                            REGDATE, REGID, USE_DIV)
            SELECT A.WERKS, A.MACH_CD, A.MATNR, A.IND_BCD, V_SEQNO,
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
                       AND IND_BCD = V_IND_BCD
                       AND IND_BCD_M = V_IND_BCD_M
                       AND PRFM_DT = V_PRFM_DT
                     ORDER BY PRFM_DT DESC ) A
            WHERE ROWNUM = 1;        
            
            
            UPDATE TB_INV003
               SET USE_QTY = USE_QTY + V_USE_CHG_QTY,
                   STCK_QTY = STCK_QTY - V_USE_CHG_QTY
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD_M;
            
            IF SQL%ROWCOUNT = 0 THEN
                UPDATE TB_INV001
                   SET STCK_QTY = NVL(STCK_QTY, 0) - V_USE_CHG_QTY
                 WHERE WERKS = V_WERKS
                   AND IND_BCD = V_IND_BCD_M;
            END IF;   
            
        END LOOP;
        
    ELSIF P_TYPE = 'SAVE2' THEN     --엑셀업로드 저장
        
--        OPEN PROD_CUR FOR
--            SELECT WERKS, IND_BCD_M, UNIT, SUM(USE_QTY) 
--                INTO V_WERKS, V_IND_BCD_M, V_UNIT, V_USE_QTY 
--              FROM TB_INV010_TEMP
--             WHERE REGID = V_SESS_USER_ID
--            GROUP BY WERKS, IND_BCD_M, UNIT;
--        LOOP
--        FETCH PROD_CUR INTO V_WERKS, V_IND_BCD_M, V_UNIT, V_USE_QTY ;
--        EXIT WHEN PROD_CUR %NOTFOUND;  
--            
--            BEGIN
--            SELECT NVL(I001.STCK_QTY, 0) INTO V_STCK_QTY1
--              FROM TB_INV001 I001
--              WHERE I001.WERKS =  V_WERKS
--                AND I001.IND_BCD = V_IND_BCD_M;
--            EXCEPTION
--                WHEN NO_DATA_FOUND THEN
--                    V_STCK_QTY1 := 0;
--            END;
--            
--            BEGIN
--            SELECT NVL(I003.STCK_QTY, 0) INTO V_STCK_QTY2
--              FROM TB_INV003 I003
--              WHERE I003.WERKS =  V_WERKS
--                AND I003.IND_BCD = V_IND_BCD_M;
--            EXCEPTION
--                WHEN NO_DATA_FOUND THEN
--                    V_STCK_QTY2 := 0;
--            END;
--            
--            V_STCK_QTY_PRE := NVL(V_STCK_QTY1, 0) + NVL(V_STCK_QTY2, 0);
--            
--            IF NVL(V_STCK_QTY_PRE, 0) - NVL(V_USE_QTY, 0) < 0 THEN
--                P_ERR_MSG := V_IND_BCD_M || ' 의 개별바코드의 재고수량 : ' || TO_CHAR(0 - (V_STCK_QTY_PRE - V_USE_QTY)) || ' ' || V_UNIT || ' 이 부족합니다.';
--                P_SUCCESS := 'N';
--                ROLLBACK;
--                RETURN; 
--            END IF;
--            
--        END LOOP;
--        
        OPEN PROD_CUR2 FOR  
            SELECT WERKS, IND_BCD, LOT_NO, MATNR, MACH_CD, IND_BCD_M, LOT_NO_M, USE_QTY, NVL(SEQNO, 0)
                INTO V_WERKS, V_IND_BCD, V_LOT_NO, V_MATNR, V_MACH_CD, V_IND_BCD_M, V_LOT_NO_M, V_USE_QTY, V_SEQNO1
              FROM TB_INV010_TEMP
             WHERE REGID = V_SESS_USER_ID;
        LOOP
        FETCH PROD_CUR2 INTO V_WERKS, V_IND_BCD, V_LOT_NO, V_MATNR, V_MACH_CD, V_IND_BCD_M, V_LOT_NO_M, V_USE_QTY, V_SEQNO1;
        EXIT WHEN PROD_CUR2 %NOTFOUND; 
            
            BEGIN
            SELECT MAX(SEQNO) INTO V_SEQNO
              FROM TB_INV010
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND MATNR = V_MATNR
               AND IND_BCD = V_IND_BCD;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_SEQNO := 0;
            END;
            
            IF NVL(V_SEQNO1, 0) > 0 THEN
                V_SEQNO := V_SEQNO1;
            ELSE
                V_SEQNO := NVL(V_SEQNO, 0) + 1;
            END IF;
            
            INSERT INTO TB_INV010 (
    			WERKS, PRFM_DT, INP_DT, MACH_CD, MATNR, LOT_NO
			  , IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO
			  , MATNR_M, IND_BCD_M, LOT_NO_M, USE_QTY, UNIT, USE_DIV, REGDATE, REGID)
            SELECT tit.WERKS, tit.PRFM_DT, tit.INP_DT, tit.MACH_CD, tit.MATNR, tit.LOT_NO
    	 	  , tit.IND_BCD, V_SEQNO --tit.SEQNO + 300
              , tit.WRK_ORDR_NO, tit.WRK_ORDR_SEQNO
    	 	  , tit.MATNR_M, tit.IND_BCD_M, tit.LOT_NO_M, tit.USE_QTY, tit.UNIT, '1', SYSDATE, V_SESS_USER_ID
    	     FROM TB_INV010_TEMP tit 
    	    WHERE tit.WERKS = V_WERKS
              AND tit.MACH_CD = V_MACH_CD
              AND tit.IND_BCD = V_IND_BCD
              AND tit.LOT_NO = V_LOT_NO
              AND tit.IND_BCD_M = V_IND_BCD_M
              AND tit.LOT_NO_M = V_LOT_NO_M
              AND tit.REGID = V_SESS_USER_ID;
            
            
            UPDATE TB_INV003
               SET USE_QTY = CASE WHEN STCK_QTY - V_USE_QTY >= 0 THEN USE_QTY + V_USE_QTY ELSE USE_QTY END,
                   STCK_QTY = CASE WHEN STCK_QTY - V_USE_QTY >= 0 THEN STCK_QTY - V_USE_QTY ELSE 0 END
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD_M;
            
            IF SQL%ROWCOUNT = 0 THEN
                UPDATE TB_INV001
                   SET STCK_QTY = CASE WHEN NVL(STCK_QTY, 0) - V_USE_QTY >=0 THEN NVL(STCK_QTY, 0) - V_USE_QTY ELSE 0 END
                 WHERE WERKS = V_WERKS
                   AND IND_BCD = V_IND_BCD_M;
            END IF;   
            
            
        END LOOP;
        
--    	INSERT INTO TB_INV010 (
--    			WERKS, PRFM_DT, INP_DT, MACH_CD, MATNR, LOT_NO
--			  , IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO
--			  , MATNR_M, IND_BCD_M, LOT_NO_M, USE_QTY, UNIT, USE_DIV, REGDATE, REGID)
--    	 SELECT tit.WERKS, tit.PRFM_DT, tit.INP_DT, tit.MACH_CD, tit.MATNR, tit.LOT_NO
--    	 	  , tit.IND_BCD, CASE WHEN (SELECT MAX(SEQNO)  FROM TB_INV010 WHERE WERKS = tit.WERKS AND IND_BCD = tit.IND_BCD) > 0
--                                   THEN (SELECT MAX(A.SEQNO) FROM TB_INV010 A WHERE A.WERKS = tit.WERKS AND A.IND_BCD = tit.IND_BCD)
--                                   ELSE 1 END + ROW_NUMBER() OVER(ORDER BY PRFM_DT)
--              , tit.WRK_ORDR_NO, tit.WRK_ORDR_SEQNO
--    	 	  , tit.MATNR_M, tit.IND_BCD_M, tit.LOT_NO_M, tit.USE_QTY, tit.UNIT, '1', SYSDATE, V_SESS_USER_ID
--    	   FROM TB_INV010_TEMP tit 
--    	  WHERE tit. REGID = V_SESS_USER_ID;
    	
    	DELETE 
          FROM TB_INV010_TEMP tit
		 WHERE REGID = V_SESS_USER_ID;
		
	ELSIF P_TYPE = 'SAVE3' THEN     --엑셀업로드
        
        DELETE 
          FROM TB_INV010_TEMP tit
		 WHERE REGID = V_SESS_USER_ID;
         
    	V_ARR_LIST        := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP

            V_OBJ					:= TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ					:= TREAT (V_OBJ.get ('map') AS json_object_t);

			V_WERKS     			:= V_OBJ.get_string('WERKS');    				--플랜트
			V_PRFM_DT     			:= V_OBJ.get_string('PRFM_DT');     			--실적일자
			V_INP_DT				:= V_OBJ.get_string('INP_DT');					--투입일자
			V_MACH_CD    			:= V_OBJ.get_string('MACH_CD');   				--설비코드
			V_MATNR      			:= V_OBJ.get_string('MATNR');      				--자재코드
			V_LOT_NO				:= V_OBJ.get_string('LOT_NO');					--LOT번호
			V_IND_BCD    			:= V_OBJ.get_string('IND_BCD');    				--개별 바코드
			V_SEQNO					:= NVL(REPLACE(V_OBJ.get_string('SEQNO'), ' ', '') ,0);					--순번
			V_WRK_ORDR_NO			:= V_OBJ.get_string('WRK_ORDR_NO');				--작업지시번호
			V_WRK_ORDR_SEQNO		:= TO_NUMBER(V_OBJ.get_string('WRK_ORDR_SEQNO'));			--작업지시순번
			V_MATNR_M    			:= V_OBJ.get_string('MATNR_M');    				--투입자재코드
			V_IND_BCD_M   			:= REPLACE(V_OBJ.get_string('IND_BCD_M'), CHR(39), '');   			--투입개별 바코드
			V_LOT_NO_M				:= REPLACE(V_OBJ.get_string('LOT_NO_M'), CHR(39), '');				--투입LOTNO
			V_USE_QTY    			:= TO_NUMBER(REPLACE(V_OBJ.get_string('USE_QTY'), ',', ''));    				--사용량
			V_UNIT   				:= V_OBJ.get_string('UNIT');   					--단위

            IF V_OBJ.get_string('GRowState') = 'C' THEN
            	INSERT INTO TB_INV010_TEMP (WERKS, PRFM_DT, INP_DT, MACH_CD, MATNR, LOT_NO
            							  , IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO
										  ,	MATNR_M, IND_BCD_M, LOT_NO_M, USE_QTY, UNIT, REGDATE, REGID)
									VALUES (V_WERKS, V_PRFM_DT, V_INP_DT, V_MACH_CD, V_MATNR, V_LOT_NO
										  , V_IND_BCD, V_SEQNO, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO
										  , V_MATNR_M, V_IND_BCD_M, V_LOT_NO_M, V_USE_QTY, V_UNIT, SYSDATE, V_SESS_USER_ID
									  	   );
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
--
--        ROLLBACK;
--        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--
--    WHEN OTHERS THEN
--	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := -20990;
--        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

--        ROLLBACK;
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;

/
