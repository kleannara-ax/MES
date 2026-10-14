--------------------------------------------------------
--  DDL for Procedure SP_SCH23_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SCH23_S01" (
	P_TYPE           IN    varchar2, -- LIST
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    :  SP_SCH23_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  :  생산오더 예외생산 조회(PS){호출 프로그램 명 기술}
 * VERSION       :  1.0.0{최종 버전 기술}
 * DESCRIPTION   :  PS 생산오더 예외생산을 관리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 안상현{최초 작성자 명 기술}
 * CREATE DATE   : 2022/07/27 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 *  2022-08-18   1.0.1      여한진         조회 시 오더유형 컬럼 추가
 *==============================================================================
 *  관련 테이블
 *       - [TB_SCH010] : (.R..)생산오더 예외생산                                
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_SCH23_S01';     -- PROCEDURE NAME

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
    V_SQL2           CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS			TB_SCH010.WERKS%TYPE;		--플랜트
    V_MATNR			TB_SCH010.MATNR%TYPE;		--자재코드
    V_AUFNR         TB_SCH010.AUFNR%TYPE;		--오더번호
    V_VBELN         TB_SCH010.VBELN%TYPE;		--오더번호

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역    

BEGIN
   	OPEN P_RS_LIST FOR 
   	SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   	V_DEBUG := 'N';
   	V_RUN_SQL := 'Y';
   	V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   	V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
	V_PLT_CD             :=       V_JSON.get_string('SES_PLNTKY');

	IF P_TYPE = 'LIST' THEN /*합지기 조회 리스트*/
	 /* 조건값 할당 */
	V_WERKS          	:=       V_JSON.get_string('WERKS');		--플랜트
	V_RANGE_SQL 		:=       V_JSON.get_string('RANGE_SQL');   	--자재코드, 생산요청일자

	V_MATNR 			:=       V_JSON.get_string('MATNR');   		--자재코드
	V_VBELN 			:=       V_JSON.get_string('VBELN');   		--자재코드

 	V_SQL :=  ' SELECT
                       S010.WERKS         AS WERKS     --플랜트
                     , S010.GSTRS         AS BUDAT     --생산요청일자     
                     , S010.AUFNR         AS AUFNR     --오더번호           
                     , 1                  AS SEQ       --순번        
                     , REGEXP_REPLACE(S010.AUARTXT, ''제지 | 오더 유형'', '''')       AS ORDER_DIV   --오더유형
                     , S010.MATNR         AS MATNR     --자재코드            
                     , M001.MATNR_NM      AS MATNR_NM  --자재명           
                     , S010.GAMNG         AS FQTY      --오더량           
                     , S010.GMEIN         AS UNIT      --단위
 					 , CMCDV.CDESC1       AS UNIT_NM   --단위명    
                     , S010.VBELN       AS VBELN        --판매문서번호          
                     , S010.WEIGHT        AS BS_WGT    --평량
                     , S010.WLEN          AS WLEN      --가로길이
                     , S010.VLEN          AS VLEN      --세로길이
                     , S010.REGDATE       AS REGDATE   --등록일시        
                     , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = S010.REGID),'''')         AS REGNM     --등록자           
                     , S010.UPDDATE       AS UPDDATE   --UPDDATE
                     , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = S010.UPDID),'''')	        AS UPDNM     --수정자
					 , DECODE(S010.dlfl, ''X'', ''삭제'', ''정상'') 							  	 	AS DELETEGBN -- 삭제구분           
                FROM TB_SCH010  S010 
					,TB_MAS001 M001
					,CMCDV CMCDV
               WHERE S010.MATNR = M001.MATNR(+) 
                 AND S010.WERKS = M001.WERKS(+)
				 AND S010.GMEIN = CMCDV.CMCDVL(+)
                 AND CMCDV.CMCDKY = ''UNIT''  ';

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND S010.WERKS = ''' || V_WERKS || '''';				   --플랜트   
        END IF;


        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_SQL := V_SQL || V_RANGE_SQL ;			                       	               --자재코드 ,생산요청일자  
        END IF;
        
        IF  V_VBELN IS NOT NULL OR TRIM(V_VBELN) != '' THEN
            V_SQL := V_SQL || ' AND S010.VBELN = ''' || V_VBELN || '''';			   --판매문서번호
        END IF;

	    V_SQL := V_SQL || ' ORDER BY S010.WERKS, S010.GSTRS, S010.AUFNR';    

	  OPEN P_RS_LIST FOR V_SQL;    

    ELSIF P_TYPE = 'SUB_LIST' THEN  /* 하부 상세 조회 리스트*/

    	V_AUFNR				:=       V_JSON.get_string('AUFNR');	    --오더번호

    	V_SQL2 :=  ' SELECT	 SCH001.AUFNR		AS AUFNR		--오더번호
							,SCH001.POSNR		AS POSNR		--오더Item번호
							,SCH001.MATNR		AS MATNR		--자품목자재
                            ,MAS001.MATNR_NM    AS MATNR_NM     --자재명     
							,SCH001.BDMNG		AS BDMNG		--오더BOM 수량
							,SCH001.MEINS		AS MEINS		--오더BOM 수량단위
							,CMCDV1.CDESC1		AS MEINS_NM		--오더BOM 수량단위(명)
							,SCH010.BMENG		AS BMENG		--BOM수량(기준정보)
							,SCH010.BMEIN		AS BMEIN		--BOM수량단위(기준정보)
							,CMCDV2.CDESC1		AS UNIT_NM		--BOM수량단위(명)
							,SCH001.LGORT		AS LGORT		--저장위치
							,MAS003.STOR_LOC_NM AS STOR_LOC_NM	--저장위치(명)
							,SCH001.XLOEK		AS DELETEYN	    --삭제여부
							,SCH001.REGDATE		AS REGDATE		--등록일자
							,NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = SCH001.REGID),'''')		AS REGNM		--등록자ID
							,SCH001.UPDDATE		AS UPDDATE		--수정일시
							,NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = SCH001.UPDID),'''')		AS UPDNM		--수정자ID
					   FROM TB_SCH001 SCH001
                          , TB_SCH010 SCH010 
                          , TB_MAS001 MAS001
						  , TB_MAS003 MAS003
						  , CMCDV CMCDV1
                          , CMCDV CMCDV2
					  WHERE 1 = 1
                        AND SCH001.AUFNR = SCH010.AUFNR
                        AND SCH010.WERKS = MAS001.WERKS
                        AND SCH001.MATNR = MAS001.MATNR
                        AND SCH010.WERKS = MAS003.WERKS
						AND SCH001.LGORT = MAS003.STOR_LOC_CD
						AND (SCH001.MEINS = CMCDV1.CMCDVL(+) AND CMCDV1.CMCDKY = ''UNIT'')
                        AND (SCH010.BMEIN = CMCDV2.CMCDVL(+) AND CMCDV2.CMCDKY = ''UNIT'')
                        '
                        ; 

        IF  V_AUFNR IS NOT NULL OR TRIM(V_AUFNR) != '' THEN							--제품코드
            V_SQL2 := V_SQL2 || 'AND SCH001.AUFNR = ''' || V_AUFNR || '''';        
        END IF;


		V_SQL2 := V_SQL2 || ' ORDER BY SCH001.AUFNR';


        BEGIN           
     		OPEN P_RS_LIST FOR V_SQL2;

        EXCEPTION           
        WHEN OTHERS THEN 
            P_SUCCESS           := 'N';
            E_SQL_ERR_CD        := -20000;
			E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
            RETURN;           
        END;    

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
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

END;

/
