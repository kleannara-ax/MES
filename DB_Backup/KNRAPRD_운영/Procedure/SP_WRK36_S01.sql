--------------------------------------------------------
--  DDL for Procedure SP_WRK36_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK36_S01" (
	P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    CLOB ,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : WRK36{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 포장대기조회{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 포장대기 자재 목록을 관리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 여한진{최초 작성자 명 기술}
 * CREATE DATE   : 2022/06/06 {최초 작성일자 기술}
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
 *       - [TB_WRK002] : (.R..) 실적테이블(PS)
 *       - [TB_SCH017] : (.R..) 작업지시 재단
 *	  	 - [TB_SCH018] : (.R..) 작업지시 포장        
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK36_S01';     -- PROCEDURE NAME

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
    V_MACHINE       TB_WRK002.MACHINE%TYPE;
	V_BS_WGT		TB_SCH017.BS_WGT%TYPE;
	V_WLEN			TB_WRK002.WLEN%TYPE;
	V_VLEN			TB_WRK002.VLEN%TYPE;
	V_STA			TB_WRK002.STA%TYPE;	

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역

BEGIN

   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'Y';
   V_RUN_SQL := 'Y';

   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=       V_JSON.get_string('SES_PLNTKY');

	/* 조건값 할당 */
   	V_RANGE_SQL         :=      V_JSON.get_string('RANGE_SQL');		--재단일, 지종
   	V_MACHINE   		:=		V_JSON.get_string('MACHINE');		--호기
	V_BS_WGT	        :=      V_JSON.get_string('BS_WGT');		--평량
	V_WLEN		        :=      V_JSON.get_string('WLEN');			--가로
	V_VLEN		        :=      V_JSON.get_string('VLEN');			--세로
	V_STA		        :=      V_JSON.get_string('STA');        	--상태

   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

        V_SQL := ' SELECT
				   		  W002.LOT_NO,					--재단
				          W002.IND_BCD,					--재단바코드
				          FN_LOT_TRK(W002.IND_BCD, 2)          MR_LOT_NO,
				          FN_LOT_TRK(W002.IND_BCD, 3)          JR_LOT_NO,
				          W002.MATNR,		--자재
				          FN_CD_VAL(''PACK_TYPE'', S009.PACKTYPE) PACKTYPE,          --포장방식
				          S017.PCODE,       			--지종
				          S017.BS_WGT,      			--평량
				          W002.PRFM_QTY		PCNT,		--연수
                          W002.UNIT,                    --단위     
				          W002.WGT,						--중량
                          S017.WLEN,                    --가로
                          S017.VLEN,                    --세로
				          S017.PLT_PER_CNT,				--파렛트연수
				          W002.VBELN,					--판매문서
				          W002.POSNR,					--판매문서순번
				          S017.KUNNRT,            		--거래처명
				          S017.ROUTE,             		--항차
				          W002.RMK,						--비고
				          FN_CD_VAL(''STCK_STA'', W002.STA)	STA		--상태
				    FROM TB_WRK002 W002,	--실적(PS)
                         TB_INV001 I001,
				         TB_SCH017 S017,	--작업지시 재단
				         TB_SCH009 S009
                         --TB_SCH018 S018		--작업지시 포장
				   WHERE  W002.WERKS     = I001.WERKS(+)
                     AND  W002.IND_BCD   = I001.IND_BCD(+)
                     AND  W002.MATNR     = I001.MATNR(+)
                     AND W002.WRK_ORDR_NO = S017.WRK_ORDR_NO(+)
				     AND W002.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO(+)
				     AND W002.ORDER_NO = S009.FRAUFNR(+)
                     --AND S018.ORDER_NO = S009.AUFNR(+)
				     AND W002.WERKS = ''P100''
                     AND I001.STOR_LOC_CD = ''2000''
                     AND I001.LOC_CD IN (''L2400'', ''L2500'', ''L2600'')
                     AND I001.STCK_QTY > 0
				     AND W002.MACH_CD IN (SELECT MACH_CD FROM TB_MAS012 WHERE PROC_CD = ''CA'') ';

		IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN 
			V_SQL := V_SQL || V_RANGE_SQL;
		END IF;

		IF V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '' THEN 
			V_SQL := V_SQL || ' AND W002.MACHINE =''' || V_MACHINE || '''' ;
		END IF;

		IF V_BS_WGT IS NOT NULL OR TRIM(V_BS_WGT) != '' THEN 
			V_SQL := V_SQL || ' AND S017.BS_WGT LIKE ''%' || V_BS_WGT || '%''' ;
		END IF;

		IF V_WLEN IS NOT NULL OR TRIM(V_WLEN) != '' THEN 
			V_SQL := V_SQL || ' AND S017.WLEN LIKE ''%' || V_WLEN || '%''' ;
		END IF;

		IF V_VLEN IS NOT NULL OR TRIM(V_VLEN) != '' THEN 
			V_SQL := V_SQL || ' AND S017.VLEN LIKE ''%' || V_VLEN || '%''' ;
		END IF;

		IF V_STA IS NOT NULL OR TRIM(V_STA) != '' THEN 
			V_SQL := V_SQL || ' AND W002.STA = ''' || V_STA || '''' ;
		END IF;  

		V_SQL := V_SQL || ' ORDER BY W002.REGDATE ';

        V_DEBUG := 'Y';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
            COMMIT;
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
        E_SQL_ERR_CD        := -20990;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;

/
