--------------------------------------------------------
--  DDL for Procedure SP_SCH02_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SCH02_S01" (
	P_TYPE           IN    varchar2, -- LIST
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_SCH02_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  :  생산오더 생리대  관리{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   :  생산오더 생리대  관리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박충식{최초 작성자 명 기술}
 * CREATE DATE   : 2022/04/25 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/04/25    1.0.0   박충식         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_SCH004] : (CRUD)생산오더 생리대 정보                                
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_SCH02_S01';     -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)      := 0;
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
    V_WERKS			TB_SCH005.WERKS%TYPE;		--플랜트
    V_MACHINE       TB_SCH006.MACHINE%TYPE;     --생산호기 
    V_MATNR			TB_SCH006.MATNR%TYPE;		--자재코드
    V_AUFNR         TB_SCH006.AUFNR%TYPE;		--오더번호

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
	V_MACHINE           :=       V_JSON.get_string('MACHINE');      --생산호기
	V_RANGE_SQL 		:=       V_JSON.get_string('RANGE_SQL');   	--자재코드, 생산요청일자

	V_MATNR 			:=       V_JSON.get_string('MATNR');   	    --자재코드
	V_AUFNR 			:=       V_JSON.get_string('AUFNR');   		--오더번호

 	V_SQL :=  ' SELECT	 SCH004.WERKS			AS WERKS			--플랜트
						,SCH004.SDATE			AS SDATE			--시작일자(생산요청일)
						,SCH004.AUFNR			AS AUFNR			--오더번호
						,SCH004.SEQ   		    AS SEQ				--작업순서
						,SCH004.AUART			AS AUART			--오더유형
						,FN_CD_VAL(''ORDER_DIV'',SCH004.AUART)	AS ORDER_DIV_NM		--오더유형 텍스트 
                        ,MAS001.BRAND_DESCR     AS BRAND_DESCR      --브랜드 
						,SCH004.MATNR			AS MATNR			--제품코드
						,SCH004.FQTY			AS FQTY				--생산지시량(오더량)
						,SCH004.MEINS			AS MEINS			--생산지시단위(오더단위)
						,CMCDV1.CDESC1			AS MEINS_NM			--오더BOM 수량단위(명)
						,SCH004.ARBPL			AS ARBPL			--Work Center
						,SCH004.AENAM			AS AENAM			--작업지시자
						,SCH004.PRCMC			AS MACHINE			--생산버전
						,SCH004.STLNR			AS BOM_NO			--BOM Num
						,SCH004.STLAL			AS ATN_BOM_NO		--대체Bom
						,SCH004.BMENG			AS BMENG			--모품목기준수량
						,SCH004.BMEIN			AS BMEIN			--모품목기준수량 단위
						,CMCDV2.CDESC1			AS UNIT_NM			--BOM수량단위(명)
						,SCH004.FTRMI			AS START_DATE		--릴리즈일자
						,SCH004.EDATE			AS END_DATE			--생산종료일
						,SCH004.DLFL			AS DLFL				--오더 삭제 지시자
						,MAS001.MATNR_NM        AS MATNR_NM			--자재명
						,SCH004.PRCMC       	AS MACHINE          --생산호기
						,SCH004.ORDER_RMK		AS RMK				--비고
                        ,SCH004.REGDATE         AS REGDATE          --등록일시    
                        ,NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = SCH004.REGID),'''')	        AS REGNM	        --등록자명   
                        ,SCH004.UPDDATE         AS UPDDATE          --수정일시      
                        ,NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = SCH004.UPDID),'''')	        AS UPDNM	        --수정자명
						,DECODE(SCH004.dlfl, ''X'', ''삭제'', ''정상'') 							  	 	AS DELETEGBN		--삭제구분          
				   FROM TB_SCH004 SCH004 
						,TB_MAS001 MAS001
                        ,TB_MAS012 MAS012
						, CMCDV CMCDV1
                        , CMCDV CMCDV2
				  WHERE SCH004.MATNR = MAS001.MATNR(+) 
                    AND SCH004.WERKS = MAS001.WERKS(+)
                    AND SCH004.ARBPL = MAS012.SAP_WRK_CD(+)
					AND (SCH004.MEINS = CMCDV1.CMCDVL(+) AND CMCDV1.CMCDKY = ''UNIT'')
                    AND (SCH004.BMEIN = CMCDV2.CMCDVL(+) AND CMCDV2.CMCDKY = ''UNIT'') ';

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND SCH004.WERKS = ''' || V_WERKS || '''';				   --플랜트   
        END IF;

        IF  V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '' THEN
            --V_SQL := V_SQL || ' AND SCH004.PRCMC = ''' || V_MACHINE || '''';			   --생산호기
            V_SQL := V_SQL || ' AND MAS012.MACHINE = ''' || V_MACHINE || '''';			   --생산호기
        END IF;

        IF  V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN
            V_SQL := V_SQL || ' AND SCH004.MATNR = ''' || V_MATNR || '''';			   	   --자재코드
        END IF;

        IF  V_AUFNR IS NOT NULL OR TRIM(V_AUFNR) != '' THEN
            V_SQL := V_SQL || ' AND SCH004.AUFNR = ''' || V_AUFNR || '''';			   	   --오더번호
        END IF;

        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_SQL := V_SQL || V_RANGE_SQL ;			                       	               --자재코드 ,생산요청일자  
        END IF;

	    V_SQL := V_SQL || ' ORDER BY SCH004.WERKS, SCH004.SDATE, SCH004.AUFNR, SCH004.SEQ';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

	  OPEN P_RS_LIST FOR V_SQL;              

    ELSIF P_TYPE = 'SUB_LIST' THEN  /* 하부 상세 조회 리스트*/

    	--INSERT INTO PROC_LOG(SQL_STR) VALUES ('SUB_LIST 2222'); 

    	V_AUFNR				:=       V_JSON.get_string('AUFNR');	    --오더번호

    	V_SQL2 :=  '  SELECT	 SCH001.AUFNR		AS AUFNR		--오더번호
							,SCH001.POSNR		AS POSNR		--오더Item번호
							,SCH001.MATNR		AS MATNR		--자품목자재
                            ,MAS001.MATNR_NM    AS MATNR_NM     --자재명     
							,SCH001.BDMNG		AS BDMNG		--오더BOM 수량
							,SCH001.MEINS		AS MEINS		--오더BOM 수량단위
							,CMCDV1.CDESC1		AS MEINS_NM		--오더BOM 수량단위(명)
							,SCH004.BMENG		AS BMENG		--BOM수량(기준정보)
							,SCH004.MEINS		AS BMEIN		--BOM수량단위(기준정보)
							,CMCDV2.CDESC1		AS UNIT_NM		--BOM수량단위(명)
							,SCH001.LGORT		AS LGORT		--저장위치
							,MAS003.STOR_LOC_NM AS STOR_LOC_NM	--저장위치(명)
							,SCH001.XLOEK		AS DELETEYN	    --삭제여부
							,SCH001.REGDATE		AS REGDATE		--등록일자
							,NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = SCH001.REGID),'''')		AS REGNM		--등록자ID
							,SCH001.UPDDATE		AS UPDDATE		--수정일시
							,NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = SCH001.UPDID),'''')		AS UPDNM		--수정자ID
					   FROM TB_SCH001 SCH001
                          , TB_SCH004 SCH004 
                          , TB_MAS001 MAS001
						  , TB_MAS003 MAS003
						  , CMCDV CMCDV1
                          , CMCDV CMCDV2
					  WHERE 1 = 1
                        AND SCH001.AUFNR = SCH004.AUFNR
                        AND SCH004.WERKS = MAS001.WERKS
                        AND SCH001.MATNR = MAS001.MATNR
                        AND SCH004.WERKS = MAS003.WERKS
						AND SCH001.LGORT = MAS003.STOR_LOC_CD
						AND (SCH001.MEINS = CMCDV1.CMCDVL(+) AND CMCDV1.CMCDKY = ''UNIT'')
                        AND (SCH004.MEINS = CMCDV2.CMCDVL(+) AND CMCDV2.CMCDKY = ''UNIT'')
                        '
                        ; 

        IF  V_AUFNR IS NOT NULL OR TRIM(V_AUFNR) != '' THEN							--제품코드
            V_SQL2 := V_SQL2 || 'AND SCH001.AUFNR = ''' || V_AUFNR || '''';        
        END IF;

		V_SQL2 := V_SQL2 || ' ORDER BY SCH001.AUFNR';

        IF (V_DEBUG = 'Y') THEN
	     	INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL2); 
        END IF;    

		OPEN P_RS_LIST FOR V_SQL2;

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
