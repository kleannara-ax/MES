--------------------------------------------------------
--  DDL for Procedure SP_INV07_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_INV07_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
    P_ERR_MSG       OUT     VARCHAR2,
    P_DOC_NO1       OUT     VARCHAR2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_INV08_S01
 * PROGRAM NAME  : 약품 불출 요청
 * VERSION       : 1.0.0
 * DESCRIPTION   : 약품불출요청을 함
 *                 
 * AUTHOR NAME   : 유상호
 * CREATE DATE   : 2022/08/14
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/08/14    1.0.0   유상호         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_WRK001] : (CRUD) 실적테이블(HL) 정보
 *        - [TB_WRK002] : (CRUD) 실적테이블(PS) 정보
 * *      
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_INV08_S01';     -- PROCEDURE NAME

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
    V_WERKS			    TB_SCH008.WERKS%TYPE;		--플랜트
    V_MATNR	           	TB_INV001.MATNR%TYPE;              --자재코드
    V_MATNR_GRP_CD      TB_MAS001.MATNR_GRP_CD%TYPE;   
    V_REQ_QTY           TB_INV001.STCK_QTY%TYPE;            --요청량
    V_DOC_NO            TB_INV001.DOC_NO%TYPE;
    V_DOC_SEQNO         TB_INV001.DOC_SEQNO%TYPE; 
    V_DOC_NO_1          TB_INV001.DOC_NO%TYPE;
    V_DOC_SEQNO_1       TB_INV001.DOC_SEQNO%TYPE;
    V_LGPRO             TB_MAS001.LGPRO%TYPE;
    V_UNIT              TB_MAS001.UNIT%TYPE;
    V_DATE              DATE := SYSDATE;

BEGIN
   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'N';
   V_RUN_SQL := 'Y';

   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=       V_JSON.get_string('SES_PLNTKY');

   /* 조건값 할당 */
    V_WERKS          	:=       V_JSON.get_string('WERKS');	    --플랜트
    V_RANGE_SQL 		:=       V_JSON.get_string('RANGE_SQL');   	--생산일자
    V_MATNR_GRP_CD      :=       V_JSON.get_string('MATNR_GRP_CD'); --자재그룹

    IF P_TYPE = 'LIST' THEN /*자재그룹 리스트*/
        V_SQL := ' SELECT M001.WERKS,               --플랜트
                           M001.MATNR,              --자재코드
                           M001.MATNR_NM,           --자재명
                           M001.MATNR_GRP_CD,       --자재그룹코드(보이지 않아도됨)
                           M001.MATNR_GRP_NM,       --자재그룹명
                           (SELECT  SUM(A.USEQTY)
                              FROM V_WMS_STKKY@KNRAWMSLINK A
                             WHERE A.LOTA02  = M001.WERKS
                               AND A.SKUkey  = M001.MATNR
                           )         AS WMS_STCK_QTY,   --WMS 재고수량
                           M001.LGPRO   STOR_LOC_CD,    --저장위치코드(보이지 않아도됨)
                           M003.STOR_LOC_NM,        --저장위치명
                           NVL(I001.STCK_QTY, 0) STCK_QTY,  --재고수량
                           ''''   AS REQ_QTY,         --요청수량
                           M001.UNIT                --단위
                      FROM TB_MAS001 M001,
                           (SELECT WERKS, MATNR, STOR_LOC_CD, SUM(STCK_QTY) STCK_QTY
                              FROM TB_INV001
                             WHERE WERKS = ''' || V_WERKS || '''
                               AND STCK_STA = ''00''
                             GROUP BY WERKS, MATNR, STOR_LOC_CD ) I001,
                           TB_MAS003 M003
                     WHERE M001.WERKS = I001.WERKS(+)
                       AND M001.MATNR = I001.MATNR(+)
                       AND M001.LGPRO = I001.STOR_LOC_CD(+)
                       AND M001.WERKS = M003.WERKS(+)
                       AND M001.LGPRO = M003.STOR_LOC_CD(+)
                       AND M001.WERKS = ''' || V_WERKS || '''
                       AND M001.MATNR_GRP_CD = ''' || V_MATNR_GRP_CD || '''';
                      -- AND M001.DL_YN <> 'X'              --삭제여부
                      -- AND M001.KZAUS <> ''               --단종여부

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;
    ELSIF P_TYPE = 'SUB_LIST' THEN   
        RETURN;    
    ELSIF P_TYPE = 'SAVE' THEN  /*불출요청 */

        V_ARR_LIST        := V_JSON.get_array('list');
        
        --자재불출요청문서
        V_DOC_NO_1 := FN_GET_MDOCNO('M', 'IF201');
        V_DOC_SEQNO_1 := 1;
        
        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ                   := TREAT (V_ARR_LIST.get (i) AS json_object_t);  
            V_OBJ					:= TREAT (V_OBJ.get ('map') AS json_object_t);   

            V_WERKS	                := V_OBJ.get_string('WERKS');           --플랜트
            V_MATNR	                := V_OBJ.get_string('MATNR');           --자재코드
            V_LGPRO                 := V_OBJ.get_string('STOR_LOC_CD');     --저장위치코드
            V_REQ_QTY               := V_OBJ.get_string('REQ_QTY');         --요청 수량
            V_UNIT                  := V_OBJ.get_string('UNIT');            --단위
            
            IF NVL(P_DOC_NO1, ' ') = ' ' THEN
                P_DOC_NO1 := V_DOC_NO_1 ;
            ELSE
                P_DOC_NO1 := P_DOC_NO1 || ',' || V_DOC_NO_1 ;
            END IF;

            INSERT INTO TB_INV002(DOC_NO ,DOC_SEQ ,DLFL ,REQ_DIV,
                                WERKS ,MATNR ,QTY ,UNIT ,STOR_LOC_CD ,STOR_LOC_TO,
                                STCK_STA, IF_STA, REGDATE, REGID)
                     VALUES(V_DOC_NO_1, TO_CHAR(V_DOC_SEQNO_1), 'C', '10',
                            V_WERKS, V_MATNR, V_REQ_QTY, V_UNIT, '', V_LGPRO,
                            '00', 'N', V_DATE, V_SESS_USER_ID);

            INSERT INTO TB_IFSWM002(DOC_NO, DOC_SEQNO, DLFL, WERKS, MATNR, QTY, UNIT,
                                    STOR_LOC, ORDER_NO, ORDER_SEQNO, STCK_STA,
                                    IF_STATUS, IF_GET_DATE, REQ_DTM, REQ_EXE_DT)
                     VALUES(V_DOC_NO_1, TO_CHAR(V_DOC_SEQNO_1), 'C', V_WERKS, V_MATNR, V_REQ_QTY, V_UNIT,
                            V_LGPRO, '', '', '00', 
                            'N', V_DATE, TO_CHAR(V_DATE, 'YYYYMMDDHH24MISS'), TO_CHAR(V_DATE,'YYYYMMDD'));
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
--        E_SQL_ERR_CD        := SQLCODE;
--        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--        ROLLBACK;
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;

/
