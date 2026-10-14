--------------------------------------------------------
--  DDL for Procedure SP_SCH06_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SCH06_S01" (
	P_TYPE           IN    varchar2, -- LIST
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_SCH06_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 생산오더 재단 관리{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 생산오더 재단 관리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박충식{최초 작성자 명 기술}
 * CREATE DATE   : 2022/04/22 {최초 작성일자 기술}
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
 *       - [TB_SCH007] : (CRUD)생산오더 포장 정보                                
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_SCH06_S01';     -- PROCEDURE NAME

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
    V_WERKS			TB_SCH008.WERKS%TYPE;		--플랜트
    V_MACHINE       TB_SCH008.MACHINE%TYPE;     --생산호기 
    V_VBELN       TB_SCH008.VBELN%TYPE;     --판매문서번호 

    V_MATNR       	TB_SCH008.CMATNR%TYPE;      --자재코드
    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역    

BEGIN
   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'N';
   V_RUN_SQL := 'Y';
   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=       V_JSON.get_string('SES_PLNTKY');

   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/
      /* 조건값 할당 */
      V_WERKS          	:=       V_JSON.get_string('WERKS');		--플랜트
      V_MACHINE         :=       V_JSON.get_string('MACHINE');      --생산호기
      V_RANGE_SQL 		:=       V_JSON.get_string('RANGE_SQL');   	--자재코드, 생산요청일자
      V_VBELN         :=       V_JSON.get_string('VBELN');      --판매문서번호

--      dbms_output.put_line(V_RANGE_SQL);

      V_MATNR 			:=       V_JSON.get_string('MATNR');   	    --자재코드

      V_SQL :=  
       ' SELECT
               SCH008.WERKS        AS WERKS         --플랜트
             , SCH008.AUFNR        AS AUFNR         --오더번호
             , SCH008.FRAUFNR      AS MRPO          --밀롤 오더 번호
             , SCH008.BUDAT        AS BUDAT         --생산요청일자
             , SCH008.MACHINE      AS MACHINE       --생산호기
             , SCH008.CMATNR       AS MATNR        	--자재
             , MAS001.MATNR_NM     AS MATNR_NM      --자재명
             , SCH008.PCODE        AS PCODE         --지종코드
             , SCH008.WEIGHT       AS BS_WGT        --평량
             , SCH008.VBELN       AS VBELN        --판매문서번호
             , SCH008.WLEN         AS WLEN          --가로길이
             , SCH008.VLEN         AS VLEN          --세로길이
             , SCH008.CNT          AS CNT           --수량
             , SCH008.CGEWEW       AS TOT_WGT       --총중량
             , SCH008.CGEWEI       AS UNIT        	--단위
             , SCH008.ZZATT1       AS ZZATT1        --팔레트당연수
             , SCH008.ZZATT2       AS ZZATT2        --속당매수
             , SCH008.DOUBLEFLAG   AS DOUBLEFLAG    --쌍팔레트
             , SCH008.CUTTER       AS CUTTER        --카터
             , NULL /*(
                   SELECT  DECODE(MAS009.LAND1,''KOR'', ''내수''
                                              ,  NULL , ''내수'' 
                                                      , ''수출'' )
                     FROM  TB_SCH009  SCH009 , TB_MAS009  MAS009 
                     WHERE  SCH009.CTPO  = SCH008.AUFNR 
                       AND  SCH009.KUNNR = MAS009.CUST_CD
                       AND  ROWNUM =1 
                )*/                  AS LAND1         --내수/수출
              , (
                  SELECT  MAX(SCH009.PACKTYPE)
                    FROM  TB_SCH009  SCH009 
                   WHERE  SCH009.CTPO  = SCH008.AUFNR 
                 )                   AS PACKTYPE      --포장방법
              , (  SELECT   DECODE(MAX(SCH017.COMP_YN),''Y''  , ''완료''
                                                      ,         ''진행중'')
                     FROM   TB_SCH017  SCH017  
                    WHERE   SCH008.AUFNR = SCH017.ORDER_NO
                 )                   AS ORD_YN        --오더완료
              , SCH008.ORDER_RMK    AS RMK            --비고
              , SCH008.REGDATE      AS REGDATE        --등록일시
              , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = SCH008.REGID),'''')        AS REGNM         --등록자명
              , SCH008.UPDDATE      AS UPDDATE       --수정일시
              , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = SCH008.UPDID),'''')        AS UPDNM         --수정자명
			  , DECODE(SCH008.dlfl, ''X'', ''삭제'', ''정상'') 							  	  AS DELETEGBN	   --삭제구분
         FROM TB_SCH008    SCH008
            , TB_MAS001    MAS001 
        WHERE 1 = 1 
          AND SCH008.CMATNR      = MAS001.MATNR(+) 
          AND SCH008.WERKS       = MAS001.WERKS(+)
              ';

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND SCH008.WERKS = ''' || V_WERKS || '''';				   --플랜트   
        END IF;

        IF  V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '' THEN
            V_SQL := V_SQL || ' AND SCH008.MACHINE = ''' || V_MACHINE || '''';			   --생산호기
        END IF;

        IF  V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN
            V_SQL := V_SQL || ' AND SCH008.CMATNR = ''' || V_MATNR || '''';			   	   --자재코드
        END IF;

        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_SQL := V_SQL || V_RANGE_SQL ;			                       	               --자재코드 ,생산요청일자  
        END IF; 
        
        IF  V_VBELN IS NOT NULL OR TRIM(V_VBELN) != '' THEN
            V_SQL := V_SQL || ' AND SCH008.VBELN = ''' || V_VBELN || '''';			   --판매문서번호
        END IF;

	    V_SQL := V_SQL || ' ORDER BY SCH008.WERKS, SCH008.BUDAT, SCH008.AUFNR ';

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
