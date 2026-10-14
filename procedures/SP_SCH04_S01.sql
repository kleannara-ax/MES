
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SCH04_S01" (
	P_TYPE           IN    varchar2, -- LIST
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_SCH04_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 생산오더 점보롤 관리{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 생산오더 점보롤 관리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박충식{최초 작성자 명 기술}
 * CREATE DATE   : 2022/04/19 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/04/19    1.0.0   박충식         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_SCH005] : (CRUD)생산오더 점보롤 정보                                
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_SCH04_S01';     -- PROCEDURE NAME

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
    V_WERKS			TB_SCH006.WERKS%TYPE;		--플랜트
    V_MACHINE       TB_SCH006.MACHINE%TYPE;     --생산호기

    V_MATNR       	TB_SCH006.MATNR%TYPE;      --자재코드	
    V_DLFL       	TB_SCH006.DLFL%TYPE;       --삭제구분	
    V_COMP_YN       TB_SCH015.COMP_YN%TYPE;       --오더완료
    V_AUFNR			TB_SCH006.AUFNR%TYPE;		--오더번호
    V_PCODE			TB_SCH006.PCODE%TYPE;		--지종코드
    V_BS_WGT		TB_SCH006.WEIGHT%TYPE;		--평량			

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역    

BEGIN
   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   --V_DEBUG   := 'Y';
   V_RUN_SQL := 'Y';
   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=       V_JSON.get_string('SES_PLNTKY');

   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/
      /* 조건값 할당 */
      V_WERKS          	:=       V_JSON.get_string('WERKS');		--플랜트
      V_MACHINE         :=       V_JSON.get_string('MACHINE');      --생산호기
      V_RANGE_SQL 		:=       V_JSON.get_string('RANGE_SQL');   	--자재코드, 생산요청일자

      V_MATNR 			:=       V_JSON.get_string('MATNR');   	    --자재코드
      V_DLFL 			:=       V_JSON.get_string('DLFL');   	    --삭제구분
      V_COMP_YN 		:=       V_JSON.get_string('COMP_YN');   	    --삭제구분
      V_AUFNR			:=		V_JSON.get_string('AUFNR');			--오더번호		
      V_PCODE	        :=		V_JSON.get_string('PCODE');			--지종코드
      V_BS_WGT          :=		V_JSON.get_string('BS_WGT');		--평량
--      dbms_output.put_line(V_RANGE_SQL);

      V_SQL :=  
       'SELECT	 
            SCH006.WERKS      AS      WERKS             -- 플랜트
          , SCH006.AUFNR      AS      AUFNR             -- 오더번호  
          , SCH006.BUDAT      AS      BUDAT             -- 생산요청일자  
          , SCH006.TOMACHINE  AS      MVERID_1          -- 이동호기  
          , SCH006.MACHINE    AS      MACHINE         	-- 생산호기   
          , SCH006.MATNR      AS      MATNR             -- 자재코드  
          , MAS001.MATNR_NM   AS      MATNR_NM          -- 자재명            
          , SCH006.PCODE      AS      PCODE             -- 지종   
          , MAS001.PCODE_NM   AS      PCODE_NM          -- 지종명  
          , SCH006.WEIGHT     AS      BS_WGT            -- 평량     
          --, SCH006.JWIDTH     AS      JWIDTH            -- J/R지폭
          , SCH006.JROLLCNT   AS      JROLLCNT          -- J/R권치수(M)
          , ''M''                 AS MUNIT               --권치수 단위
          , SCH006.JBRGEW     AS      TOT_WGT           -- 총중량(Kg)
          , ''KG''                 AS WUNIT               --중량 단위
          , SCH006.JRCNT      AS      JRCNT             -- J/R갯수
          , SCH006.SHEET      AS      SHEET             -- 판지구분자
          , (
                   SELECT   DECODE(MIN(SCH015.COMP_YN),''Y''  , ''완료'',''I''  , ''진행중''
                                                      ,         ''대기'')
                     FROM   TB_SCH015  SCH015
                    WHERE   SCH006.AUFNR = SCH015.ORDER_NO
            )               AS      ORD_YN               -- 오더완료 
          , SCH006.ORDER_RMK  AS      RMK            	-- 비고
          , SCH006.REGDATE    AS      REGDATE           -- 등록일시
          , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = SCH006.REGID),'''')	  AS      REGNM	            -- 등록자명
          , SCH006.UPDDATE    AS      UPDDATE           -- 수정일시
          , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = SCH006.UPDID),'''')	  AS      UPDNM	            -- 수정자명
		  , DECODE(SCH006.DLFL, ''X'', ''삭제'', ''정상'') 							  AS      DLFL			-- 삭제구분
        FROM TB_SCH006  SCH006 
           , TB_MAS001  MAS001 
           , TB_SCH015  SCH015
       WHERE 1 = 1 
         AND SCH006.MATNR = MAS001.MATNR(+)
         AND SCH006.WERKS = MAS001.WERKS(+)
         AND SCH006.AUFNR = SCH015.ORDER_NO(+)
              ';

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND SCH006.WERKS = ''' || V_WERKS || '''';				   --플랜트   
        END IF;

        IF  V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '' THEN
            V_SQL := V_SQL || ' AND SCH006.MACHINE = ''' || V_MACHINE || '''';			   --생산호기
        END IF;

        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MATNR', 'SCH006.MATNR');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'AUFNR', 'SCH006.AUFNR');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'PCODE', 'SCH006.PCODE');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'BUDAT', 'SCH006.BUDAT');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'BS_WGT', 'SCH006.WEIGHT');

            V_SQL := V_SQL || V_RANGE_SQL ;			                       	               --자재코드 ,생산요청일자  
        END IF;

        IF V_DLFL IS NOT NULL OR TRIM(V_DLFL) != '' THEN                                    -- 삭제구분
            V_SQL := V_SQL || ' AND SCH006.DLFL = ''' || V_DLFL || '''';
        END IF;

        IF V_COMP_YN IS NOT NULL OR TRIM(V_COMP_YN) != '' THEN                                    -- 오더완료
            V_SQL := V_SQL || ' AND SCH015.COMP_YN = ''' || V_COMP_YN || '''';
        END IF;

	    V_SQL := V_SQL || ' ORDER BY SCH006.WERKS, SCH006.BUDAT, SCH006.AUFNR';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

	  OPEN P_RS_LIST FOR V_SQL;              

    ELSIF P_TYPE = 'SUB_LIST' THEN  /* 하부 상세 조회 리스트*/
          RETURN;								
    ELSIF P_TYPE = 'SAVE' THEN
          RETURN;								
    ELSIF P_TYPE = 'SUB_SAVE' THEN
          RETURN;
    END IF;

    P_SUCCESS := 'Y';

    EXCEPTION
    WHEN E_EXCEPTION_USER THEN

        -- 에러 내역 SET
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

    WHEN OTHERS THEN
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
