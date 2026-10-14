--------------------------------------------------------
--  DDL for Procedure SP_INV12_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_INV12_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
    P_MSG           OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_INV12_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 즉시입고(투입)취소 {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 즉시입고(투입)취소 를 관리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 유상호{최초 작성자 명 기술}
 * CREATE DATE   : 2023/01/15 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2023/01/15    1.0.0   유상호         Initial Version
 *==============================================================================
 *  관련 테이블
 *        - [V_WRK_ORDR] : (.R..) 작업지시 뷰
 * 		  - [TB_SCH020] : (.R..) 작업지시 BOM정보
 * 		  - [TB_MAS001] : (.R..) 자재마스터
 * 		  - [TB_MAS005] : (.R..) 자재 단위환산마스터
 * 		  - [TB_SCH019] : (.R..) 예외 작업지시
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_INV12_S01';     -- PROCEDURE NAME


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
    V_OBJ2			 JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);
    V_DEBUG          varchar2(1);
    
    -- 조건절 처리용 변수선언 영역
    V_WERKS			TB_INV007.WERKS%TYPE;		--플랜트
    V_MATNR	               TB_INV007.MATNR%TYPE;                      --자재코드
    V_SDATE                VARCHAR2(10);                              --시작일자
    V_EDATE                VARCHAR2(10);                              --종료일자
    V_CNL_GU               VARCHAR2(1);                               --취소구분
    V_WDOC_NO              TB_INV007.WDOC_NO%TYPE;
    V_WDOC_SEQNO           TB_INV007.WDOC_SEQNO%TYPE;
    V_CNL_YN_PRE           TB_INV007.CNL_YN%TYPE; 
    V_CNL_YN               TB_INV007.CNL_YN%TYPE;
    V_DATE                 DATE := SYSDATE;  
    WRK_ORDR_CUR			SYS_REFCURSOR;
BEGIN
   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'Y';
   V_RUN_SQL := 'Y';
   
   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=       V_JSON.get_string('SES_PLNTKY');

   /* 조건값 할당 */
   V_WERKS          	:=       V_JSON.get_string('WERKS');	    --플랜트
   V_SDATE              :=       V_JSON.get_string('SDATE');	    --시작일자
   V_EDATE              :=       V_JSON.get_string('EDATE');	    --종료일자
   V_MATNR              :=       V_JSON.get_string('MATNR');        --자재코드
   V_CNL_GU 		    :=       V_JSON.get_string('CNL_GU');   	--취소구분  N : 즉시입고  , R : 즉시입고(투입)취소 요청 , Y : 즉시입고(투입)취소
   V_WDOC_NO			:= 		 V_JSON.get_string('WDOC_NO');		--WMS 문서번호


	IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/
		V_SQL := 'SELECT I007.WDOC_NO,         --WMS 문서번호
                        I007.WDOC_SEQNO,     --WMS 문서번호순번
                        I007.WERKS,          --플랜트
                        I007.MATNR,          --자재코드
                        M001.MATNR_NM,       --자재명
                        I007.QTY,            --입고량
                        I007.UNIT,           --단위
                        I007.STOR_LOC_FR,    --FROM 저장위치
                        I007.STOR_LOC_TO,    --TO 저장위치
                        I007.PRDC_DT,        --생산일자
                        I007.RCVCDS_DT,      --입고일자
                        I007.DSTBT_DDLIN,    --유통기간
                        I007.IND_BCD,        --개별바코드
                        I007.LOT_NO,         --LOT NO
                        I007.STOK_KY,        --WMS 재고 KEY
                        I007.LOT_NUM,        --WMS LOT 속성
                        I007.REGDATE,          --등록일자
                        I007.CNL_YN,         --취소여부
                        CASE WHEN NVL(I007.CNL_YN,''N'') = ''N'' THEN ''입고'' 
                            WHEN NVL(I007.CNL_YN,''N'') = ''R'' THEN ''투입 취소 요청''
                            WHEN NVL(I007.CNL_YN,''N'') = ''Y'' THEN ''투입 취소 완료'' END CNL_YN_NM, -- 취소여부명
                        I007.CNL_DT,         --
                        I007.CNL_REGID,      --투입 취소 등록자
                        I007.CNL_REGDATE,    --투입 취소 요청 일시    
                        I007.CNL_UPDDATE     --투입 취소 일시
                    FROM TB_INV007 I007
						,TB_MAS001 M001
                   WHERE I007.WERKS = M001.WERKS(+)
                     AND I007.MATNR = M001.MATNR(+)
                     AND I007.WERKS = ''' || V_WERKS || '''  
                     AND I007.REQ_DIV = ''50''
                     AND I007.RCVCDS_DT BETWEEN ''' || V_SDATE || ''' AND ''' || V_EDATE || '''
                     ';
        
        IF  V_WDOC_NO IS NOT NULL OR TRIM(V_WDOC_NO) != '' THEN
            V_SQL := V_SQL || ' AND I007.WDOC_NO LIKE ''' || V_WDOC_NO || '%''';				   --WMS 문서번호
        END IF;            
                    
        IF  V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN
            V_SQL := V_SQL || ' AND I007.MATNR = ''' || V_MATNR || '''';				   --자재코드
        END IF;
       
        IF  V_CNL_GU IS NOT NULL OR TRIM(V_CNL_GU) != '' THEN
            V_SQL := V_SQL || ' AND I007.CNL_YN = ''' || V_CNL_GU || '''';				   --취소구분
        END IF;               
        V_SQL := V_SQL || ' ORDER BY I007.REGDATE';  

		OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SAVE' THEN          -- 즉시입고 취소(CNL_YN = 'N' 경우만 처리)
        V_ARR_LIST        := V_JSON.get_array('list');
        
        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ						:= TREAT (V_ARR_LIST.get (i) AS json_object_t);  
            V_OBJ						:= TREAT (V_OBJ.get ('map') AS json_object_t);   
            
            V_WERKS	            := V_OBJ.get_string('WERKS');                --플랜트
            V_WDOC_NO	        := V_OBJ.get_string('WDOC_NO');              --WMS 문서번호
            V_WDOC_SEQNO	    := V_OBJ.get_string('WDOC_SEQNO');           --WMS 문서번호 순번
            V_CNL_YN            := V_OBJ.get_string('CNL_YN');               --취소여부
            
            BEGIN
            SELECT CNL_YN INTO V_CNL_YN_PRE
              FROM TB_INV007
             WHERE WDOC_NO = V_WDOC_NO
               AND WDOC_SEQNO = V_WDOC_SEQNO;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_CNL_YN_PRE := '';
            END;
            IF NVL(V_CNL_YN_PRE, '') = '' THEN
                P_SUCCESS := 'N';
                P_MSG := V_WDOC_NO || ' 문서번호를 찾을수 없습니다.';
                ROLLBACK;
                RETURN;                
            END IF;
            
            IF NVL(V_CNL_YN_PRE, '') = 'Y' THEN
                P_SUCCESS := 'N';
                P_MSG := V_WDOC_NO || ' 문서번호는 이미 즉시입고(투입)취소된 문서번호입니다.';
                ROLLBACK;
                RETURN;                
            END IF;
            
            IF NVL(V_CNL_YN_PRE, '') = 'R' THEN
                P_SUCCESS := 'N';
                P_MSG := V_WDOC_NO || ' 문서번호는 이미 즉시입고(투입)취소 요청된 문서번호입니다.';
                ROLLBACK;
                RETURN;                
            END IF;
        END LOOP;
        
        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ						:= TREAT (V_ARR_LIST.get (i) AS json_object_t);  
            V_OBJ						:= TREAT (V_OBJ.get ('map') AS json_object_t);   

            V_WERKS	            := V_OBJ.get_string('WERKS');                --플랜트
            V_WDOC_NO	        := V_OBJ.get_string('WDOC_NO');              --WMS 문서번호
            V_WDOC_SEQNO	    := V_OBJ.get_string('WDOC_SEQNO');           --WMS 문서번호 순번
            V_CNL_YN            := V_OBJ.get_string('CNL_YN');               --취소여부
            
            UPDATE TB_INV007
               SET CNL_YN = 'R',
                   CNL_DT = TO_CHAR(V_DATE,'YYYYMMDD'),
                   CNL_REGDATE = V_DATE,
                   CNL_REGID = V_SESS_USER_ID
              WHERE WDOC_NO = V_WDOC_NO;
                --AND WDOC_SEQNO = V_WDOC_SEQNO;
               
        END LOOP;
    ELSIF P_TYPE = 'DELETE' THEN            --삭제(CNL_YN = 'R' 인경우 처리)
        V_ARR_LIST        := V_JSON.get_array('list');
        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ						:= TREAT (V_ARR_LIST.get (i) AS json_object_t);  
            V_OBJ						:= TREAT (V_OBJ.get ('map') AS json_object_t);   
            
            V_WERKS	            := V_OBJ.get_string('WERKS');                --플랜트
            V_WDOC_NO	        := V_OBJ.get_string('WDOC_NO');              --WMS 문서번호
            V_WDOC_SEQNO	    := V_OBJ.get_string('WDOC_SEQNO');           --WMS 문서번호 순번
            V_CNL_YN            := V_OBJ.get_string('CNL_YN');               --취소여부
            
            BEGIN
            SELECT CNL_YN INTO V_CNL_YN_PRE
              FROM TB_INV007
             WHERE WDOC_NO = V_WDOC_NO
               AND WDOC_SEQNO = V_WDOC_SEQNO;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_CNL_YN_PRE := '';
            END;
            IF NVL(V_CNL_YN_PRE, '') = '' THEN
                P_SUCCESS := 'N';
                P_MSG := V_WDOC_NO || ' 문서번호를 찾을수 없습니다.';
                ROLLBACK;
                RETURN;                
            END IF;
            
            IF NVL(V_CNL_YN_PRE, '') = 'N' THEN
                P_SUCCESS := 'N';
                P_MSG := V_WDOC_NO || ' 문서번호는 즉시입고(투입)취소 요청된 문서번호가 아닙니다.';
                ROLLBACK;
                RETURN;                
            END IF;
            
            IF NVL(V_CNL_YN_PRE, '') = 'Y' THEN
                P_SUCCESS := 'N';
                P_MSG := V_WDOC_NO || ' 문서번호는 이미 즉시입고(투입)취소된 문서번호입니다.';
                ROLLBACK;
                RETURN;                
            END IF;
            
        END LOOP;
        
        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ						:= TREAT (V_ARR_LIST.get (i) AS json_object_t);  
            V_OBJ						:= TREAT (V_OBJ.get ('map') AS json_object_t);   

            V_WERKS	            := V_OBJ.get_string('WERKS');                --플랜트
            V_WDOC_NO	        := V_OBJ.get_string('WDOC_NO');              --WMS 문서번호
            V_WDOC_SEQNO	    := V_OBJ.get_string('WDOC_SEQNO');           --WMS 문서번호 순번
            
            UPDATE TB_INV007
               SET CNL_YN = 'N',
                   CNL_DT = '',
                   CNL_REGDATE = V_DATE,
                   CNL_REGID = V_SESS_USER_ID
              WHERE WDOC_NO = V_WDOC_NO;
                --AND WDOC_SEQNO = V_WDOC_SEQNO;
               
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
--        E_SQL_ERR_CD            := SQLCODE;
--        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--        ROLLBACK;
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
--        RAISE;
END;

/
