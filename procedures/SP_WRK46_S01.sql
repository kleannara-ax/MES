
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK46_S01" (
	P_TYPE           IN    varchar2, -- LIST
	P_JSON_STR       IN    CLOB ,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : WRK46{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 설비별 진행현황{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 설비별 진행현황을 조회한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 여한진{최초 작성자 명 기술}
 * CREATE DATE   : 2022/06/12 {최초 작성일자 기술}
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
 *      - [TB_WRK011] : (.R..) 설비별 현재진행현황
 *      - [TB_MAS012] : (.R..) 설비 마스터
 *      - [TB_MAS013] : (.R..) 공정 마스터
 *      - [TB_MAS001] : (.R..) 자재
 *      - [V_WRK_ORDR : (.R..) 작업지시 VIEW
 *      - [TB_WRK002] : (.R..) PS 실적
 *      - [TB_WRK003] : (.R..) 비가동 실적
 *      - [TB_MAS020] : (.R..) 비가동 항목
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK46_S01';     -- PROCEDURE NAME

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
    V_WERKS			TB_WRK011.WERKS%TYPE;
    V_MACH_CD       TB_WRK011.MACH_CD%TYPE;
    V_PROC_CD		TB_MAS012.PROC_CD%TYPE;

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역

BEGIN

   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'N';
   V_RUN_SQL := 'Y';

   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=      V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=      V_JSON.get_string('SES_PLNTKY');

   /* 조건값 할당 */
   V_RANGE_SQL          :=      V_JSON.get_string('RANGE_SQL');
   V_WERKS		        :=      V_JSON.get_string('WERKS');     --플랜트

   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

        V_SQL := ' SELECT A.WERKS,			--플랜트
						  A.MACH_CD,		--설비코드
						  A.MACH_NM,		--설비명
						  A.PROC_CD,		--공정코드
						  A.PROC_NM,		--공정명
                          A.PROC_DISP_SEQ,
                          A.MACH_DISP_SEQ,
						  DECODE(A.WERKS, ''P100'', C.PRD_REQ_DT, B.PRD_REQ_DT)	PRD_REQ_DT,		--생산요청일자
						  DECODE(A.WERKS, ''P100'', C.ORDER_NO, B.ORDER_NO)		ORDER_NO,		--오더번호
						  DECODE(A.WERKS, ''P100'', C.WRK_ORDR_NO || ''-'' ||LPAD(C.WRK_ORDR_SEQNO, 2, ''0''), B.WRK_ORDR_NO  || ''-'' ||LPAD(B.WRK_ORDR_SEQNO, 2, ''0''))	WRK_ORDR_NO,	--작업지시번호
						  DECODE(A.WERKS, ''P100'', C.LOT_NO, B.LOT_NO) LOT_NO, -- LOT NO
                          DECODE(A.WERKS, ''P100'', C.MATNR, B.MATNR)   MATNR,	--자재코드
						  DECODE(A.WERKS, ''P100'', C.MATNR_NM, B.MATNR_NM) MATNR_NM,	--자재명
						  DECODE(A.WERKS, ''P100'', C.UNIT, B.UNIT)	UNIT,	--단위
						  D.ORDR_QTY AS WRK_ORDR_QTY,	--지시수량
						  D.PRFM_QTY,	--실적수량
						  DECODE(A.WERKS, ''P100'', C.PRD_STR_DTM, B.PRD_STR_DTM) PRD_STR_DTM,		--생산시작시간
						  ROUND((SYSDATE - TO_DATE(DECODE(A.WERKS, ''P100'', C.PRD_STR_DTM, B.PRD_STR_DTM), ''YYYY-MM-DD HH24:MI:SS'')) * 24 * 60, 0) LAPSE_TM,			--경과시간
                          DECODE(A.WERKS, ''P100'', C.WRK_CLASS, B.WRK_CLASS)   WRK_CLASS,  --작업반
                          DECODE(A.WERKS, ''P100'', C.WRK_SHIFT, B.WRK_SHIFT)   WRK_SHIFT,  --작업조
                          DECODE(A.WERKS, ''P100'', C.EMPLY_NM, B.EMPLY_NM)     EMPLY_NM,   --작업자
                          A.ABN_CD 																AS ABN_CD,      --비가동항목코드
                          A.ABN_NM 																AS ABN_NM,      --비가동항목명
                          A.ABN_DTM 															AS ABN_DTM,		--비가동 시작시간
                          ROUND(((SYSDATE - A.ABN_DTM) * 24 * 60), 0) 	AS ABN_DUDATE, 	--비가동 경과시간
                          A.USARG1 																AS USARG1,		--컬럼 배경 색상
						  A.USARG2 																AS USARG2		--컬럼 텍스트 색상
				     FROM (SELECT M13.WERKS, 
					  			  M12.MACH_CD, 
					  			  W11.WRK_ORDR_NO,
					  			  W11.IN_OUT,
					  			  DECODE(W11.IN_OUT, ''O'', M12.MACH_NM || '' 포장'', M12.MACH_NM)    MACH_NM,
					  			  M12.PROC_CD, 
					  			  M13.PROC_NM,
                                  M13.DISP_SEQ AS PROC_DISP_SEQ,
                                  M12.DISP_SEQ AS MACH_DISP_SEQ,
								  W11.ABN_CD,
					  			  M20.ABN_NM,
					  			  W11.ABN_DTM,
								  (SELECT USARG1 FROM CMCDV WHERE CMCDVL = M20.RUN_STA AND CMCDKY = ''RUN_STA'') AS USARG1,
								  (SELECT USARG2 FROM CMCDV WHERE CMCDVL = M20.RUN_STA AND CMCDKY = ''RUN_STA'') AS USARG2	
					  			  --CMCDV.USARG1,
					  			  --CMCDV.USARG2
					   	    FROM TB_MAS012 M12,	 --설비 마스터
                                 TB_WRK011 W11,	 --설비별 현재진행현황
						         TB_MAS013 M13,	 --공정 마스터
								 TB_MAS020 M20  --비가동 항목정보
						         --CMCDV CMCDV 	 --공통코드(ITEM)
					  	   WHERE M12.MACH_CD = W11.MACH_CD(+)
						     AND M12.PROC_CD = M13.PROC_CD(+)
                             AND M13.WERKS = M20.WERKS(+)
							 AND W11.ABN_CD = M20.ABN_CD(+)
						     --AND M20.RUN_STA = CMCDV.CMCDVL(+)
						     --AND CMCDV.CMCDKY = ''RUN_STA''

--                             AND M12.PRFM_GTHR_YN = ''Y'' 
						  ) A,
						  (SELECT W11.WERKS,
                                  W11.MACH_CD,
                                  W11.WRK_ORDR_NO,
                                  W11.WRK_ORDR_SEQNO,
                                  --DECODE(W11.MACH_STA, ''N'', W11.PRE_WRK_ORDR_NO, W11.WRK_ORDR_NO) WRK_ORDR_NO,
                                  --DECODE(W11.MACH_STA, ''N'', W11.PRE_WRK_ORDR_SEQNO, W11.WRK_ORDR_SEQNO)   WRK_ORDR_SEQNO,
                                  W11.IN_OUT,
                                  --DECODE(W11.MACH_STA, ''N'', '''', W11.LOT_NO)   LOT_NO,
                                  W11.LOT_NO,
                                  W11.MATNR,
					  			  M01.MATNR_NM,
                                  W11.WRK_CLASS,
                                  W11.WRK_SHIFT,
                                  (SELECT NMLAST FROM USRMA WHERE USERID = W11.EMPLY_NO)    EMPLY_NM,
								  V.PRD_REQ_DT,
								  --DECODE(W11.MACH_STA, ''N'', V2.ORDER_NO, V.ORDER_NO)  ORDER_NO,
                                  V.ORDER_NO,
								  FN_CD_VAL(''UNIT'', V.UNIT)   UNIT,
								  V.PRD_STR_DTM
						    FROM TB_WRK011 W11,	--설비별 현재진행현황
                                 TB_MAS001 M01,	--자재
						   		 V_WRK_ORDR	V,	--작업지시 VIEW
                                 V_WRK_ORDR	V2	--이전작업지시 VIEW
						   WHERE W11.WERKS = M01.WERKS(+)
						     AND W11.MATNR = M01.MATNR(+)
                             AND W11.WRK_ORDR_NO = V.WRK_ORDR_NO(+)
                             AND W11.WRK_ORDR_SEQNO = V.WRK_ORDR_SEQNO(+)
                             AND W11.PRE_WRK_ORDR_NO = V2.WRK_ORDR_NO(+)
                             AND W11.PRE_WRK_ORDR_SEQNO = V2.WRK_ORDR_SEQNO(+)
						     AND V.TABLE_NM IN (''SCH011'', ''SCH012'', ''SCH013'', ''SCH014'', ''SCH019'')
						 ) B,	--HL
						 (SELECT W11.WERKS,
                                 W11.MACH_CD,
                                 W11.WRK_ORDR_NO,
                                 W11.WRK_ORDR_SEQNO,
                                 --DECODE(W11.MACH_STA, ''N'', W11.PRE_WRK_ORDR_NO, W11.WRK_ORDR_NO) WRK_ORDR_NO,
                                 --DECODE(W11.MACH_STA, ''N'', W11.PRE_WRK_ORDR_SEQNO, W11.WRK_ORDR_SEQNO)   WRK_ORDR_SEQNO,
                                 W11.IN_OUT,
                                 --DECODE(W11.MACH_STA, ''N'', '''', W11.LOT_NO)   LOT_NO,
                                 W11.LOT_NO,
                                 W11.MATNR,
					  			 M01.MATNR_NM,
                                 W11.WRK_CLASS,
                                 W11.WRK_SHIFT,
                                 (SELECT NMLAST FROM USRMA WHERE USERID = W11.EMPLY_NO)    EMPLY_NM,
								 V.PRD_REQ_DT,
								 DECODE(V.TABLE_NM, ''SCH015'', V.ORDER_NO, V.PRE_ORDER_NO)     ORDER_NO,
								 FN_CD_VAL(''UNIT'', V.UNIT)   UNIT,
								 V.PRD_STR_DTM
                                 --DECODE(W11.MACH_STA, ''N'', DECODE(V.TABLE_NM, ''SCH015'', V.ORDER_NO, V.PRE_ORDER_NO))     ORDER_NO,
								 --DECODE(W11.MACH_STA, ''N'', FN_CD_VAL(''UNIT'', V.UNIT))   UNIT,
								 --DECODE(W11.MACH_STA, ''N'', V.PRD_STR_DTM)  PRD_STR_DTM
						    FROM TB_WRK011 W11,	--설비별 현재진행현황
                                 TB_MAS001 M01,	--자재
						   		 V_WRK_ORDR V	--작업지시 VIEW
						   WHERE W11.WERKS = M01.WERKS(+)
						     AND W11.MATNR = M01.MATNR(+)
                             AND W11.WRK_ORDR_NO = V.WRK_ORDR_NO(+)
                             AND W11.WRK_ORDR_SEQNO = V.WRK_ORDR_SEQNO(+)
                             AND V.TABLE_NM IN (''SCH015'', ''SCH016'', ''SCH017'', ''SCH018'', ''SCH019'')
						 ) C,	--PS
                         (SELECT W11.WERKS,
                                 W11.MACH_CD,
                                 W11.IN_OUT,
                                 W11.WRK_ORDR_NO,
                                 W11.WRK_ORDR_SEQNO,
                                 SUM(V.ORDR_QTY)    ORDR_QTY,
                                 SUM(DECODE(W11.WERKS, ''P100'', W2.PRFM_QTY, V.PRFM_QTY))    PRFM_QTY
                            FROM TB_WRK011 W11, --설비별 현재진행현황
                                 V_WRK_ORDR V,  --작업지시 VIEW
                                 TB_WRK002 W2   --실적(PS)
                           WHERE W11.WRK_ORDR_NO = V.WRK_ORDR_NO(+)
                             AND W11.WRK_ORDR_SEQNO = V.WRK_ORDR_SEQNO(+)
                             AND W11.WERKS = W2.WERKS(+)
                             AND W11.MACH_CD = W2.MACH_CD(+)
                             --AND W11.IN_OUT = ''N''
                           GROUP BY W11.WERKS, W11.MACH_CD, W11.IN_OUT, W11.WRK_ORDR_NO, W11.WRK_ORDR_SEQNO
                         ) D

				   WHERE A.WERKS = B.WERKS(+)
                     AND A.WERKS = C.WERKS(+)
                     AND A.MACH_CD = B.MACH_CD(+)
                     AND A.MACH_CD = C.MACH_CD(+)
                     AND A.IN_OUT = B.IN_OUT(+)
                     AND A.IN_OUT = C.IN_OUT(+)
                     AND A.WERKS = D.WERKS(+)
                     AND A.MACH_CD = D.MACH_CD(+)
                     AND A.IN_OUT = D.IN_OUT(+)' ;

        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN     --플랜트
            V_SQL := V_SQL || ' AND A.WERKS = ''' || V_WERKS || '''';        
        END IF;

       	V_SQL := V_SQL || ' ORDER BY A.WERKS, A.PROC_DISP_SEQ, A.MACH_DISP_SEQ, PRD_REQ_DT';

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
