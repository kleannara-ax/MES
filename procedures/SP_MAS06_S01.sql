
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_MAS06_S01" (
	P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : MAS06{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 부서정보{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : NextHR에서의 부서정보를 조회한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 김성하{최초 작성자 명 기술}
 * CREATE DATE   : 2022/04/05 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   김성하         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_MAS018] : (.R..) 부서정보                                
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_MAS06_S01';     -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_ARRAY_T;
    V_OBJ            JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_DEPT_KR_NM        TB_MAS018.DEPT_KR_NM%TYPE;      

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역        
    V_COMPKY            TB_MAS018.COMPKY%TYPE;
    V_DEPT_CD            TB_MAS018.DEPT_CD%TYPE;
    V_DEPT_EN_NM      TB_MAS018.DEPT_EN_NM%TYPE;      
    V_UP_DEPT_CD         TB_MAS018.UP_DEPT_CD%TYPE;   
    V_DISP_SEQ          TB_MAS018.DISP_SEQ%TYPE;  
    V_SYNC_SEQNO        TB_MAS018.SYNC_SEQNO%TYPE;    
    V_USE_YN            TB_MAS018.USE_YN%TYPE; 

    --기타처리
    V_CREATE_FLG       CHAR(1)  := 'N';
    V_UPDATE_FLG       CHAR(1)  := 'N';    

BEGIN
   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'N';
   V_RUN_SQL := 'Y';

   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=       V_JSON.get_string('SES_WAREKY');

   /* 조건값 할당 */
   V_RANGE_SQL          :=       V_JSON.get_string('RANGE_SQL');	-- 

   V_COMPKY             :=       V_JSON.get_string('COMPKY');           -- 회사코드
   V_DEPT_CD             :=       V_JSON.get_string('DEPT_CD');		-- 부서코드 
   --V_DEPT_KR_NM         :=       V_JSON.get_string('DEPT_KR_NM');   -- 부서명(국문)
   V_DEPT_EN_NM       :=       V_JSON.get_string('DEPT_EN_NM');     -- 부서명(영문)
   V_UP_DEPT_CD          :=       V_JSON.get_string('UP_DEPT_CD');	-- 상위부서코드
   V_DISP_SEQ           :=       V_JSON.get_number('DISP_SEQ');         -- 표시순서
   V_SYNC_SEQNO         :=       V_JSON.get_number('SYNC_SEQNO');       -- SSO 동기화 차수
   V_USE_YN             :=       V_JSON.get_string('USE_YN');           -- 사용여부


   IF P_TYPE = 'LIST' THEN /*좌측 조회 리스트*/


        V_SQL :=  ' SELECT M018.COMPKY          AS "COMPKY"
                         , OWNR.NAME01          AS "COMPKY_NM"
                         , M018.DEPT_CD         AS "DEPT_CD"
                         , M018.DEPT_KR_NM      AS "DEPT_KR_NM"
                         , M018.DEPT_EN_NM      AS "DEPT_EN_NM"
                         , M018.UP_DEPT_CD      AS "UP_DEPT_CD"
                         ,(SELECT DEPT_KR_NM FROM TB_MAS018 WHERE DEPT_CD = M018.UP_DEPT_CD AND COMPKY = M018.COMPKY) AS "UP_DEPT_KR_NM"
                         ,(SELECT DEPT_EN_NM FROM TB_MAS018 WHERE DEPT_CD = M018.UP_DEPT_CD AND COMPKY = M018.COMPKY) AS "UP_DEPT_EN_NM"
                         , M018.DISP_SEQ        AS "DISP_SEQ"
                         , M018.SYNC_SEQNO      AS "SYNC_SEQNO"
                         , M018.USE_YN          AS "USE_YN"
                         , REGDATE              AS "REGDATE"
                         , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = M018.REGID),'' '') AS "REGNM"
                         , UPDDATE              AS "UPDDATE"
                         , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = M018.UPDID),'' '') AS "UPDNM"
                    FROM  TB_MAS018 M018, OWNER OWNR
                    WHERE M018.COMPKY = OWNR.COMPKY(+) 
                      AND OWNR.OWNRKY = ''KN''
                      AND M018.USE_YN = ''Y''';

        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
        	V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'DEPT_KR_NM', 'M018.DEPT_KR_NM');	--부서명
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;


        /*IF  V_DEPT_KR_NM IS NOT NULL OR TRIM(V_DEPT_KR_NM) != '' THEN -- 부서명
            V_SQL := V_SQL || ' AND M018.DEPT_KR_NM  LIKE ''%' || V_DEPT_KR_NM || '%''';             
        END IF;*/

		V_SQL := V_SQL || ' ORDER BY M018.COMPKY';

        --V_DEBUG := 'Y';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
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





    ELSIF P_TYPE = 'DBCLCK_LIST' THEN  /* 좌그리드 더블클릭시 우그리드에 하위 레벨1 리스트 조회*/

        V_SQL :=  ' SELECT 
					       A.COMPKY
					     , OWNR.NAME01    AS "COMPKY_NM"
					     , A.DEPT_CD
					     , A.DEPT_EN_NM
					     , A.DEPT_KR_NM
					     --, A.DEPT_KR_NMS
					     , A.UP_DEPT_CD
					     , (SELECT DEPT_KR_NM FROM TB_MAS018 WHERE DEPT_CD = A.UP_DEPT_CD AND COMPKY = A.COMPKY) AS "UP_DEPT_KR_NM"
					     , (SELECT DEPT_EN_NM FROM TB_MAS018 WHERE DEPT_CD = A.UP_DEPT_CD AND COMPKY = A.COMPKY) AS "UP_DEPT_EN_NM"
					     , A.DISP_SEQ
					     , A.SYNC_SEQNO      AS "SYNC_SEQNO"
					     , A.USE_YN          AS "USE_YN"
					     , REGDATE           AS "REGDATE"
					     , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = A.REGID),'' '') AS "REGNM"
					     , UPDDATE              AS "UPDDATE"
					     , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = A.UPDID),'' '') AS "UPDNM"
					     , A.LVL
					  FROM (
							SELECT LEVEL AS LVL
							     , DEPT_CD -- PK-부서코드
							     , COMPKY  -- PK-회사키
							     , UP_DEPT_CD
							     , DEPT_KR_NM
							     , DEPT_EN_NM
					            --, LPAD('' '', 3 * (LEVEL-1)) || DEPT_KR_NM AS DEPT_KR_NMS
							    -- , LPAD(''    '', 2*(LEVEL-1)) || DEPT_KR_NM AS DEPT_KR_NMS
					            , DISP_SEQ
					            , SYNC_SEQNO
					            , USE_YN
					            , REGDATE
					            , REGID
					            , UPDDATE
					            , UPDID
							  FROM TB_MAS018 MAS018  --부서정보
							 WHERE 1=1
							   AND COMPKY = ''KN''
							   AND USE_YN = ''Y''
							 START WITH UP_DEPT_CD = REPLACE_PART
							 CONNECT BY PRIOR DEPT_CD = UP_DEPT_CD
							 ORDER SIBLINGS BY DEPT_CD
					  ) A
					  LEFT JOIN OWNER OWNR
					    ON OWNR.COMPKY = A.COMPKY
					 WHERE 1=1
					   AND A.LVL = 1
                     ORDER BY A.COMPKY ';

		V_SQL := REGEXP_REPLACE(V_SQL, 'REPLACE_PART', '''' || V_DEPT_CD || '''');


--		V_DEBUG := 'Y';
--
--        IF (V_DEBUG = 'Y') THEN
--            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
--        END IF;


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



    ELSIF P_TYPE = 'SAVE' THEN

    	V_ARR_LIST        := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP

                V_OBJ					:= TREAT (V_ARR_LIST.get (i) AS json_object_t);
                V_OBJ					:= TREAT (V_OBJ.get ('map') AS json_object_t);

		V_COMPKY				:= V_OBJ.get_string('COMPKY');			-- 회사코드     
		V_DEPT_CD				:= V_OBJ.get_string('DEPT_CD');			-- 부서코드      
		V_DEPT_KR_NM				:= V_OBJ.get_string('DEPT_KR_NM');		-- 부셔영(국문) 
		V_DEPT_EN_NM				:= V_OBJ.get_string('DEPT_EN_NM');		-- 부서명(영문) 
		V_UP_DEPT_CD				:= V_OBJ.get_string('UP_DEPT_CD');		-- 상위부서코드 
		V_DISP_SEQ				:= TO_NUMBER(TRIM(V_OBJ.get_string('DISP_SEQ')));		-- 표시순서     
		V_SYNC_SEQNO				:= TO_NUMBER(TRIM(V_OBJ.get_string('SYNC_SEQNO')));		-- 동기화차수   
		V_USE_YN				:= V_OBJ.get_string('USE_YN');			-- 사용여부(사용Y, 미사용N)

                IF V_OBJ.get_string('GRowState') = 'C' THEN
                    IF (V_RUN_SQL = 'Y') THEN

                     INSERT INTO TB_MAS018 (
						 COMPKY					-- 회사코드     
						,DEPT_CD				-- 부서코드      
						,DEPT_KR_NM				-- 부셔영(국문) 
						,DEPT_EN_NM				-- 부서명(영문) 
						,UP_DEPT_CD				-- 상위부서코드 
						,DISP_SEQ				-- 표시순서     
						,SYNC_SEQNO				-- 동기화차수   
						,USE_YN					-- 사용여부(사용Y, 미사용N)
						,REGDATE				-- 등록일시
						,REGID					-- 등록자ID
						,UPDDATE				-- 수정일시
						,UPDID					-- 수정자ID      
					) VALUES (
						V_COMPKY				-- 회사코드     
						,V_DEPT_CD				-- 부서코드      
						,V_DEPT_KR_NM				-- 부셔영(국문) 
						,V_DEPT_EN_NM				-- 부서명(영문) 
						,V_UP_DEPT_CD				-- 상위부서코드 
						,V_DISP_SEQ				-- 표시순서     
						,V_SYNC_SEQNO				-- 동기화차수   
						,V_USE_YN				-- 사용여부(사용Y, 미사용N)
						,SYSDATE 
						,V_SESS_USER_ID
						,SYSDATE
						,V_SESS_USER_ID
					); 

                    END IF;

		ELSIF V_OBJ.get_string('GRowState') = 'U' THEN

            UPDATE TB_MAS018
				SET  COMPKY				= V_COMPKY		-- 회사코드          
					,DEPT_KR_NM			= V_DEPT_KR_NM	-- 부셔영(국문) 
					,DEPT_EN_NM			= V_DEPT_EN_NM	-- 부서명(영문) 
					,UP_DEPT_CD			= V_UP_DEPT_CD		-- 상위부서코드 
					,DISP_SEQ			= V_DISP_SEQ		-- 표시순서     
					,SYNC_SEQNO			= V_SYNC_SEQNO		-- 동기화차수   
					,USE_YN				= V_USE_YN		-- 사용여부(사용Y, 미사용N)
					,UPDDATE			= SYSDATE		-- 수정일
					,UPDID				= V_SESS_USER_ID	-- 수정자             
        	WHERE DEPT_CD 						= V_DEPT_CD;  		-- 부서코드          	

		ELSIF V_OBJ.get_string('GRowState') = 'D' THEN
			DELETE FROM TB_MAS018 WHERE DEPT_CD = V_DEPT_CD;
		END IF;

    END LOOP;    

    ELSIF P_TYPE = 'SUB_SAVE' THEN
          RETURN;

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
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
