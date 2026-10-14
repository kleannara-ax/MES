
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SCH05_S01" (
	P_TYPE           IN    varchar2, -- LIST
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_SCH05_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  :  생산오더 밀롤  관리{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   :  생산오더 밀롤  관리한다.{프로그램에 대한 상세한 내용 기술}
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
 *       - [TB_SCH007] : (.R..)생산오더 밀롤 정보                       
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_SCH05_S01';     -- PROCEDURE NAME

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
    V_WERKS			TB_SCH007.WERKS%TYPE;		--플랜트
    V_MACHINE       TB_SCH007.MACHINE%TYPE;     --생산호기 

    V_MATNR       	TB_SCH007.MMATNR%TYPE;      --자재코드
    V_COMP_YN       TB_SCH016.COMP_YN%TYPE;     --오더완료
    V_AUFNR			TB_SCH007.AUFNR%TYPE;		--오더번호
    V_PCODE			TB_SCH007.PCODE%TYPE;		--지종코드
    V_BS_WGT		TB_SCH007.WEIGHT%TYPE;		--평량

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
	V_MACHINE           :=       V_JSON.get_string('MACHINE');       --생산호기
	V_RANGE_SQL 		:=       V_JSON.get_string('RANGE_SQL');   	--자재코드, 생산요청일자

	V_MATNR 			:=       V_JSON.get_string('MATNR');   	    --자재코드
	V_COMP_YN 			:=       V_JSON.get_string('COMP_YN');   	--오더완료
    V_AUFNR				:=		V_JSON.get_string('AUFNR');			--오더번호		
    V_PCODE	        	:=		V_JSON.get_string('PCODE');			--지종코드
    V_BS_WGT          	:=		V_JSON.get_string('BS_WGT');		--평량

 	V_SQL :=  ' SELECT
		               SCH007.WERKS 			AS WERKS			--플랜트
		              ,SCH007.AUFNR 			AS AUFNR			--오더번호
		              ,SCH007.FRAUFNR		    AS JRPO				--점보롤 오더 번호
		              ,SCH007.ORDER_NUM		    AS ORDER_NUM		--생산지시No
		              ,SCH007.ORDER_SEQ		    AS ORDER_SEQ		--생산지시Seq
		              ,SCH007.BUDAT			    AS BUDAT			--생산요청일자
		              ,SCH007.MACHINETXT		AS PRDTYPETXT		--생산라인구분
		              ,SCH007.MACHINE		    AS MACHINE			--생산호기
		              ,SCH007.MMATNR			AS MATNR			--자재코드
		              ,SCH007.PCODE			    AS PCODE			--지종코드
		              ,SCH007.WEIGHT			AS BS_WGT			--평량
		              --,SCH007.MWIDTH			AS MWIDTH			--M/R지폭
		              ,CASE WHEN SCH007.SLITER = ''X'' THEN (SELECT MWIDTH FROM TB_SCH007 WHERE AUFNR = SCH007.FRAUFNR)
                           ELSE SCH007.MWIDTH
                           END                  AS MWIDTH			--M/R지폭
                      ,SCH007.MWIDTH_INPUT	    AS MWIDTH_INPUT		--M/R 지폭_INPUT
		              --,SCH007.MWIDTH_SLITER	    AS MWIDTH_SLITER	--슬리터 M/R지폭
		              , CASE WHEN SCH007.SLITER = ''X'' THEN SCH007.MWIDTH_SLITER
                            WHEN SCH007.SLITER = ''Y'' THEN (SELECT A.MWIDTH_SLITER FROM (SELECT MWIDTH_SLITER, DENSE_RANK() OVER(ORDER BY AUFNR) AS RANK FROM TB_SCH007 WHERE FRAUFNR = SCH007.AUFNR) A WHERE A.RANK = 1)
                            ELSE                            NULL
                        END                     AS MWIDTH_SLITER	--슬리터 M/R지폭
                      ,SCH007.MROLLCNT		    AS MROLLCNT			--M/R권치수(오더량)
                      ,''M''                    AS MUNIT          --권치수 단위
		              ,SCH007.MRCNT			    AS MRCNT			--폭수
		              ,SCH007.MBRGEW			AS MBRGEW			--M/R중량
		              ,SCH007.MGEWEI 			AS WUNIT				--중량단위
		              ,SCH007.JRCNT			    AS JRCNT			--J/R갯수     --> 삭제처리
		              ,SCH007.VBELN			    AS VBELN			--주문문서번호
		              ,SCH007.POSNR			    AS POSNR			--품목
		              ,SCH007.VDATU			    AS VDATU			--납품요청일
		              ,SCH007.REMARK			AS RMK				--비고
		              ,SCH007.SHEET			    AS SHEET			--판지구분자
		              ,SCH007.SLITER		    AS SLITER_SET		--슬리터구분자
		              ,SCH007.MRLDCK			AS MRLDCK			--밀롤창고적치여부
		              ,SCH007.CUTTER			AS CUTTER			--카터
		              ,DECODE(SCH016.COMP_YN, ''Y'', ''완료'', ''N'', ''대기중'', ''진행중'')	AS ORD_YN			--오더완료
		              ,SCH008.ZZATT1                                --팔레트당 연수
                      ,''R''                   AS RUNIT            --연수 단위           
                      ,SCH008.ZZATT2                                --속당매수
                      ,''EA''                   AS EAUNIT            --매수 단위           
                      ,SCH008.DOUBLEFLAG                            --쌍팔레트
                      ,DECODE(SCH007.SHEET, ''X'', SCH008.WLEN, SCH007.MWIDTH) AS WLEN   --가로길이
                      ,SCH008.VLEN                                  --세로길이  
		              ,(SELECT LAND1 FROM TB_MAS009 WHERE SCH007.KUNNR = CUST_CD AND CUST_DIV = ''C'')				AS LAND1            --국가키
		              ,SCH007.REGDATE			AS REGDATE          --등록일시
		              ,NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = SCH007.REGID),SCH007.REGID)			    AS REGNM            --등록자명
		              ,SCH007.UPDDATE			AS UPDDATE          --수정일시
		              ,NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = SCH007.UPDID),SCH007.UPDID)			    AS UPDNM            --수정자명
					  ,DECODE(SCH007.dlfl, ''X'', ''삭제'', ''정상'') 							  						AS DELETEGBN		--삭제구분
               FROM TB_SCH007	SCH007
				   , TB_SCH016	SCH016 
                   , TB_SCH008  SCH008
              WHERE 1 = 1
                AND SCH007.AUFNR	= SCH016.ORDER_NO(+)
                AND SCH007.AUFNR	= SCH008.FRAUFNR(+)
              ';

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND SCH007.WERKS = ''' || V_WERKS || '''';				   --플랜트   
        END IF;

        IF  V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '' THEN
            V_SQL := V_SQL || ' AND SCH007.MACHINE = ''' || V_MACHINE || '''';			   --생산호기
        END IF;

        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MATNR', 'SCH007.MMATNR');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'AUFNR', 'SCH007.AUFNR');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'PCODE', 'SCH007.PCODE');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'BS_WGT', 'SCH007.WEIGHT');

            V_SQL := V_SQL || V_RANGE_SQL ;			                       	               --자재코드 ,생산요청일자  
        END IF;

		--20230210 여한진 오더번호, 지종코드, 평량, 오더완료 검색조건 추가
       	IF V_COMP_YN IS NOT NULL OR TRIM(V_COMP_YN) != '' THEN                                 -- 오더완료
            V_SQL := V_SQL || ' AND SCH016.COMP_YN = ''' || V_COMP_YN || '''';
        END IF;

	    V_SQL := V_SQL || ' ORDER BY SCH007.WERKS, SCH007.BUDAT, SCH007.AUFNR ';

        V_DEBUG := 'Y';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
            COMMIT;
        END IF;
COMMIT;
	  OPEN P_RS_LIST FOR V_SQL;              

    ELSIF P_TYPE = 'SUB_LIST' THEN  /* 하부 상세 조회 리스트*/
         RETURN;	
    ELSIF P_TYPE = 'SAVE' THEN
          RETURN;								
    ELSIF P_TYPE = 'SUB_SAVE' THEN
          RETURN;
    END IF;

    P_SUCCESS := 'Y';

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
--        E_SQL_ERR_CD        := SQLCODE;
--        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--        ROLLBACK;
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
