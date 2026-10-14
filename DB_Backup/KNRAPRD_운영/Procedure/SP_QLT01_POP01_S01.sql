--------------------------------------------------------
--  DDL for Procedure SP_QLT01_POP01_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_QLT01_POP01_S01" (
	P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    CLOB,
    P_SDOC_NO       OUT    varchar2,
    P_DOC_SEQNO     OUT    varchar2,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : QLT01_POP01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 공정창고 조회{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 품질검사(수입검사)과정에서 발견된 부적합 원부자재에 대하여 
 *                 공정창고의 자재을 부적합 처리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 김성하{최초 작성자 명 기술}
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
 * yyyy/mm/dd    1.0.0   김성하         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [CMCDV]      : (.R..) 공통코드
 *       - [USRMA]      : (.R..) 사용자 정보               
 *       - [TB_MAS001]  : (.R..) 자재 마스트                              
 *       - [TB_MAS009]  : (.R..) 거래처 정보                                           
 *       - [TB_INV001]  : (.RU.) 공정창고 재고정보 
 *       - [TB_INV007]  : (.R..) WMS 불출/반납 이력정보 
 *       - [TB_IFS009]  : (C.U.) 품질검사(공정창고 부적합 결과)(MES -> SAP) 
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_QLT01_POP01_S01';     -- PROCEDURE NAME

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
    V_OBJ_HEAD       JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_MATNR_NM            TB_MAS001.MATNR_NM%TYPE; -- 자재명

    V_WERKS            TB_INV001.WERKS%TYPE; -- 플랜트코드
    V_MATNR            TB_INV001.MATNR%TYPE; -- 자재코드
    V_LOT_NO           TB_INV001.LOT_NO%TYPE;
    V_WRK_ORDR_NO      TB_INV001.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO   TB_INV001.WRK_ORDR_SEQNO%TYPE;
    V_UNIT             TB_INV001.UNIT%TYPE;    
    V_STCK_QTY         TB_INV001.STCK_QTY%TYPE;
    V_STCK_KY          TB_INV001.STCK_KY%TYPE;
    V_STOR_LOC_CD      TB_INV001.STOR_LOC_CD%TYPE;
    V_SUPY_CD          TB_INV001.SUPY_CD%TYPE;
    V_STCK_STA         TB_INV001.STCK_STA%TYPE;
    V_FNL_JDGM         TB_INV001.FNL_JDGM%TYPE;
    V_IND_BCD          TB_INV001.IND_BCD%TYPE;
    V_DOC_NO           TB_INV001.DOC_NO%TYPE;
    V_DOC_SEQNO        TB_INV001.DOC_SEQNO%TYPE;
    V_WDOC_NO          TB_INV001.WDOC_NO%TYPE;
    V_WDOC_SEQNO       TB_INV001.WDOC_SEQNO%TYPE;
    V_DLFL             TB_INV001.DLFL%TYPE;

    V_MSRM_DATE        TB_QLT024.MSRM_DATE%TYPE;
    V_PRC_SEQNO        TB_QLT024.PRC_SEQNO%TYPE;
    V_MSRM_DT          VARCHAR2(20) := '';


    V_DOC_NEW_NO       TB_INV001.DOC_NO%TYPE;
    V_DOC_NEW_SEQNO    TB_INV001.DOC_SEQNO%TYPE;

    V_PRD_DT           TB_INV001.PRD_DT%TYPE;
--  
--    V_CHKRST           TB_IFSWM001.CHKRST%TYPE; --검사진행상태(QR:품질검사완료, QF:상태변경완료)
--    V_QTYGOD           TB_IFSWM001.QTYGOD%TYPE; --정상수량
--    V_QTYBAD           TB_IFSWM001.QTYBAD%TYPE; --불량수량(시료량)
--    V_BADRSN           TB_IFSWM001.BADRSN%TYPE; --불량사유(???)

    V_LGORT_FROM       TB_IFS009.LGORT_FROM%TYPE;   --저장위치(From)
    V_LGORT_TO         TB_IFS009.LGORT_TO%TYPE;     --저장위치(To)

    --기타처리
    V_CREATE_FLG       CHAR(1)  := 'N';
    V_UPDATE_FLG       CHAR(1)  := 'N';
    V_Q020_CNT         NUMBER   := 0;
    V_Q021_CNT         NUMBER   := 0;
    V_CHG_ACC          NUMBER   := 0;
    V_SEQNO            VARCHAR2(20) := '1';

BEGIN
   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'N';
   V_RUN_SQL := 'Y';

   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=       V_JSON.get_string('SES_WAREKY');

   /* 조건값 할당 */
   V_RANGE_SQL          :=       V_JSON.get_string('RANGE_SQL'); -- 플랜트코드, 자재그룹, 자재코드

   V_WERKS              :=       V_JSON.get_string('WERKS');     -- 플랜트코드
   V_MATNR_NM              :=       V_JSON.get_string('MATNR_NM');     -- 자재명 
   V_MATNR              :=       V_JSON.get_string('MATNR');     -- 자재코드
   V_DOC_NO             :=       V_JSON.get_string('DOC_NO');    -- MES 전송 문서번호
   V_DOC_SEQNO          :=       V_JSON.get_number('DOC_SEQNO'); -- MES 전송 문서번호순번
   V_PRD_DT            :=       V_JSON.get_string('PRD_DT');    -- 제조일자


   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

      V_SQL := '  SELECT
                     I001.WERKS
                   , I001.STOR_LOC_CD  AS "STOR_LOC_CD" --저장위치코드
                   , M003.STOR_LOC_NM  AS "STOR_LOC_NM" --저장위치명
                   , I001.IND_BCD      AS "IND_BCD"     --개별바코드(공급업체 바코드)
                   , I001.MATNR        AS "MATNR"       --자재코드
                   , M001.MATNR_NM     AS "MATNR_NM"    --자재명
                   , I001.LOC_CD       AS "LOC_CD"      --로케이션코드(H)
                   , M028.LOC_NM       AS "LOC_NM"      --로케이션명
                   , I001.LOT_NO       AS "VND_LOT_NO"  --공급업체 로트번호
                   , I001.UNIT         AS "UNIT"        --단위(H)
                   ,(SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''UNIT''      AND CMCDVL = I001.UNIT) AS "UNIT_NM"                   
                   , I001.STCK_QTY    AS "STCK_QTY"     --재고수량
                   , I001.SUPY_CD     AS "SUPY_CD"      --공급업체코드(H)
                   ,(SELECT CUST_NM FROM TB_MAS009 WHERE CUST_DIV = ''V'' AND CUST_CD = I001.SUPY_CD) AS "SUPY_NM"
                   , I001.WDOC_NO     AS "WDOC_NO"      --WMS 출고 문서번호(H)
                   , I001.WDOC_SEQNO  AS "WDOC_SEQNO"   --WMS 출고 문서순번(H)
                   , I001.DLFL        AS "DLFL"         --WMS 출고 지시자(C:신규, D:삭제)(H)
                   , I001.STCK_STA    AS "STCK_STA"     --재고상태(H)(00정상  10보류 20합격 30불합격 05검사대기 50폐기) (H)
                   ,(SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''STCK_STA''  AND CMCDVL = I001.STCK_STA) AS "STCK_STA_NM"
                   , I001.FNL_JDGM    AS "FNL_JDGM"     --최종판정(H)
                   ,(SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''FNL_JDGM''  AND CMCDVL = I001.FNL_JDGM) AS "FNL_JDGM_NM"
                   , I001.MSRM_DATE   AS "MSRM_DATE"    --검사일자(H)
                   , I001.INSPR_ID    AS "INSPR_ID"     --검사자(H)
                   , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = I001.INSPR_ID),'''') AS "INSPR_NM"   
                   , I001.REGDATE     AS "REGDATE"
                   , I001.DOC_NO      AS "DOC_NO"       --MES 전송문서번호(H)
                   , I001.DOC_SEQNO   AS "DOC_SEQNO"    --MES 전송문서번호순번(H)
                 FROM TB_INV001 I001,
                      --TB_INV007 I007,
                      TB_MAS001 M001,
                      TB_MAS003 M003,
                      TB_MAS028 M028
                WHERE I001.WERKS       = M001.WERKS(+)
                  AND I001.MATNR       = M001.MATNR(+)
                  --AND I001.WDOC_NO     = I007.WDOC_NO(+)
                  --AND I001.WDOC_SEQNO  = I007.WDOC_SEQNO(+)
                  --AND I001.DLFL        = I007.DLFL(+)
                  AND I001.WERKS       = M003.WERKS(+)
                  AND I001.STOR_LOC_CD = M003.STOR_LOC_CD(+)
                  AND I001.WERKS       = M028.WERKS(+)
                  AND I001.STOR_LOC_CD = M028.STOR_LOC_CD(+)
                  AND I001.LOC_CD      = M028.LOC_CD(+)
                  AND I001.STOR_LOC_CD IN (''2000'', ''3100'')
                  --AND I001.DLFL        <> ''D''
                  AND I001.STCK_QTY > 0 ';

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN -- 플랜트
            V_SQL := V_SQL || ' AND I001.WERKS  = ''' || V_WERKS || '''';             
        END IF;

        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN -- 미 적용
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;                     

        IF  V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN -- 자재코드
            V_SQL := V_SQL || ' AND I001.MATNR = '''|| TRIM(V_MATNR) || '''';
        END IF;

        IF  V_PRD_DT IS NOT NULL OR TRIM(V_PRD_DT) != '' THEN -- 제조일자
            V_SQL := V_SQL || ' AND I001.PRD_DT = '''|| TRIM(V_PRD_DT) || '''';
        END IF;

		V_SQL := V_SQL || ' ORDER BY I001.REGDATE';

        BEGIN           
     		OPEN P_RS_LIST FOR V_SQL;

        EXCEPTION           
        WHEN OTHERS THEN 
            P_SUCCESS           := 'N';
            E_SQL_ERR_CD        := -20000;
            E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
            RETURN;           
        END;    


    ELSIF P_TYPE = 'SUB_LIST' THEN  /* 하단 상세 조회 리스트*/
          RETURN;

    ELSIF P_TYPE = 'SAVE' THEN
        V_ARR_HEAD           := TREAT(V_JSON.get ('head') AS json_object_t);
        V_ARR_LIST           := V_JSON.get_array('list');

        -- 상단의 입력된 맵에서 가져온다.
        V_FNL_JDGM           := V_JSON.get_string('FNL_JDGM');         /*최종판정*/   
        V_DOC_NEW_NO         := FN_GET_MDOCNO(V_PLT_CD, 'MES_IF_131'); /*SAP 전송 문서번호 생성*/

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP

                V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
                V_OBJ           := TREAT (V_OBJ.get ('map') AS json_object_t);

                V_WERKS         := V_OBJ.get_string('WERKS');
                V_STOR_LOC_CD      := V_OBJ.get_string('STOR_LOC_CD');
                V_LOT_NO        := V_OBJ.get_string('VND_LOT_NO');
                V_IND_BCD       := V_OBJ.get_string('IND_BCD');
                V_MATNR         := V_OBJ.get_string('MATNR');
                V_STCK_QTY      := V_OBJ.get_string('STCK_QTY');
                V_UNIT          := V_OBJ.get_string('UNIT');
                V_MSRM_DATE     := V_OBJ.get_date('MSRM_DATE');          /*측정일시*/
                V_DOC_NO        := V_OBJ.get_string('DOC_NO');           /*MES 문서번호*/
                V_DOC_SEQNO     := V_OBJ.get_number('DOC_SEQNO');        /*MES 문서순번*/
                V_WDOC_NO       := V_OBJ.get_string('WDOC_NO');            /*WMS 문서 참조번호*/
                V_WDOC_SEQNO    := V_OBJ.get_string('WDOC_SEQNO');            /*WMS 문서 참조 아이템*/
                V_DLFL          := V_OBJ.get_string('DLFL');             /*WMS 지시자*/

                V_MSRM_DT       := V_OBJ.get_string('MSRM_DATE');

                IF TRIM(V_DOC_NO) IS NULL OR TRIM(V_DOC_NO) = ' ' THEN             /*이미 등록된 문서번호가 없으면 신규 번호를 할당한다.*/
                   V_DOC_NO          := V_DOC_NEW_NO; 
                   V_DOC_SEQNO       := i + 1; 

                   IF i > 0 THEN
                       V_SEQNO           := V_SEQNO || ',' || V_DOC_SEQNO;
                    END IF;
                END IF;

                IF V_OBJ.get_string('GRowState') = 'C' THEN  --추가가 있나?
                      RETURN; 

--                ELSIF  V_OBJ.get_string('GRowState') = 'C' THEN
                ELSIF  V_OBJ.get_string('GRowState') = 'R' THEN  -- 수정되는 사항이 아닌 단순히 선택된 항목에 대한 처리이므로 'R'을 가지고 처리한다.

                       IF TRIM(V_MSRM_DT) IS NULL OR TRIM(V_MSRM_DT) = ' ' THEN
                           V_MSRM_DT         := TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI:SS'); 
                       END IF;

                       IF  V_FNL_JDGM = 'FAIL' THEN

                            -- 최종판정 결과가 부적합 이면 부적합 정보에...H
                            -- 공정창고 재고를 위치를 부적합창고로 이전 시킨다.(2010) 
                            BEGIN
                                UPDATE TB_INV001 I001
                                   SET I001.STOR_LOC_CD        = '2010'
                                     , STCK_STA                = '40'  -- 00:정상, 40: 부적합                               
                                     , I001.FNL_JDGM           =  V_FNL_JDGM 
                                     , MSRM_DATE               =  SYSDATE
                                     , INSPR_ID                =  V_SESS_USER_ID
                                     , UPDDATE                 =  SYSDATE
                                     , UPDID                   =  V_SESS_USER_ID                                 
                                 WHERE ( I001.WERKS         =  V_WERKS
                                   AND  I001.STOR_LOC_CD    =  V_STOR_LOC_CD
                                   AND  I001.IND_BCD        =  V_IND_BCD
                                   AND  I001.MATNR          =  V_MATNR );
                                EXCEPTION           
                                WHEN OTHERS THEN 
                                      P_SUCCESS           := 'N';
                                      E_SQL_ERR_CD        := -20000;
                                      E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
                                      ROLLBACK;

                                      SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                                      RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                                      RETURN;           
                            END; 

                            BEGIN
                                  MERGE
                                      INTO  TB_QLT024 Q024
                                     USING  DUAL
                                        ON  ( Q024.MSRM_DATE          =  TO_DATE(V_MSRM_DT,'YYYY-MM-DD HH24:MI:SS')
                                       AND    Q024.PRC_SEQNO          =  V_PRC_SEQNO )
                            WHEN MATCHED THEN
                                    UPDATE
                                        SET FNL_JDGM       =  V_FNL_JDGM
                                          , UCFMTY_AMT     =  V_STCK_QTY  
                                          , UPDDATE        =  SYSDATE
                                          , UPDID          =  V_SESS_USER_ID                   
                            WHEN NOT MATCHED THEN
                                    INSERT (
                                            MSRM_DATE,
                                            PRC_SEQNO,
                                            UCFMTY_AMT,
                                            FNL_JDGM, 
                                            LOT_NO,
                                            IND_BCD,                                            
                                            MATNR,
                                            WERKS,
                                            STOR_LOC_CD,
                                            REGDATE,
                                            REGID
                                    ) VALUES (
                                            TO_DATE(V_MSRM_DT,'YYYY-MM-DD HH24:MI:SS'),
                                            i + 1,
                                            V_STCK_QTY,
                                            V_FNL_JDGM, 
                                            V_LOT_NO,
                                            V_IND_BCD,                                            
                                            V_MATNR,
                                            V_WERKS,
                                            '2010',   --부적합 창고로 고정 
                                            SYSDATE,
                                            V_SESS_USER_ID
                                        ); 
                            EXCEPTION           
                            WHEN OTHERS THEN 
                                   P_SUCCESS           := 'N';
                                   E_SQL_ERR_CD        := -20000;
                                   E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
                                   ROLLBACK;

                                   SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                                   RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                                   RETURN;           
                            END;

                            --V_LGORT_FROM     := '2000';   --저장위치(From) 반제품 창고
                            V_LGORT_TO       := '2010';   --저장위치(To)   부적합 창고

                             -- 공정창고 재고에 대한 판정결과는 SAP로 전송 처리한다.
                             BEGIN
                                  MERGE
                                      INTO  TB_IFS009 S009
                                     USING  DUAL
                                        ON  ( MDOCNO    = V_DOC_NO
                                       AND    MDOCSEQ   = V_DOC_SEQNO )
                             WHEN MATCHED THEN
                                   UPDATE
                                       SET  ZRESULT      = NULL,
                                            ZMESSAGE     = NULL,
                                            ZRESULT_DATE = NULL, --SAP 전송이시
                                            MAKE_DATE    = NULL, --등록일시
                                            MAKER        = NULL  --등록자
                             WHEN NOT MATCHED THEN                
                                   INSERT (
                                            MDOCNO,      --MES 문서번호
                                            MDOCSEQ,     --MES 문서순번
                                            BWART,       --이동유형,(재고이전:311, 등급변경:309, 재고실사: )
                                            WERKS_FROM,  --플램트(T)
                                            WERKS_TO,    -- 플랜트(T)
                                            MATNR_FROM,   --자재번호(F)
                                            MATNR_TO,     --자재번호(T)
                                            LGORT_FROM,   --저장위치(F) -
                                            LGORT_TO,     --저장위치(T) - 부적합 창고로 재고이전(2010)
                                            CHARG_FROM,   --LOT NO(F)
                                            CHARG_TO,     --LOT NO(T)
                                            MENGE,        --이동량
                                            MEINS,        --이동단위
                                            FAULTY,       --부적합 지시자
                                            MBLNR,        --SAP 문서번호
                                            MJAHR,        --SAP 문서번호(년도)
                                            ZRESULT,      --결과값 Return( S:성공, E:오류 )
                                            ZMESSAGE,     -- SAP 전송 결과 메시지
                                            ZRESULT_DATE, --SAP 전송일시
                                            MAKE_DATE,    --등록일시
                                            MAKER         --등록자
                                   ) VALUES (
                                            V_DOC_NO,       --MES 문서번호
                                            V_DOC_SEQNO,    --MES 문서순번
                                            '311',          --이동유형,(재고이전:311, 등급변경:309, 재고실사: )
                                            V_WERKS,        --플램트(F)
                                            V_WERKS,        --플랜트(T)
                                            V_MATNR,        --자재번호(F)
                                            V_MATNR,        --자재번호(T)
                                            V_STOR_LOC_CD,   --저장위치(F) -
                                            V_LGORT_TO,     --저장위치(T) - 부적합 창고로 재고이전(2010)
                                            V_LOT_NO,       --LOT NO
                                            V_LOT_NO,       --LOT NO
                                            V_STCK_QTY,     --이동량
                                            V_UNIT,         --이동단위
                                            'Y',            --부적합 지시자('Y'고정)
                                            ' ',            --SAP 문서번호
                                            ' ',            --SAP 문서번호(년도)
                                            'N',            --결과값 Return( S:성공, E:오류 )
                                            ' ',            --SAP 전송 결과 메시지
                                            NULL,           --SAP 전송일시
                                            SYSDATE,        --등록일시
                                            V_SESS_USER_ID  --등록자
                                   );
                             EXCEPTION           
                             WHEN OTHERS THEN 
                                   P_SUCCESS           := 'N';
                                   E_SQL_ERR_CD        := -20000;
                                   E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
                                   ROLLBACK;

                                   SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                                   RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                                   RETURN;           
                             END;
                             P_SDOC_NO := V_DOC_NO;
                             P_DOC_SEQNO := V_SEQNO;
                       ELSE 

                            -- 공정창고 재고를 위치를 반제품 창고로 이전 시킨다.(2000) 
                            BEGIN
                                UPDATE TB_INV001 I001
                                   SET I001.STOR_LOC_CD        = '2000'
                                     , STCK_STA                = '00'  -- 00:정상, 40: 부적합                               
                                     , I001.FNL_JDGM           =  V_FNL_JDGM 
                                     , MSRM_DATE               =  SYSDATE
                                     , INSPR_ID                =  V_SESS_USER_ID
                                     , UPDDATE                 =  SYSDATE
                                     , UPDID                   =  V_SESS_USER_ID                                 
                                 WHERE ( I001.WERKS         =  V_WERKS
                                   AND  I001.STOR_LOC_CD    =  V_STOR_LOC_CD
                                   AND  I001.IND_BCD        =  V_IND_BCD
                                   AND  I001.MATNR          =  V_MATNR );
                                EXCEPTION           
                                WHEN OTHERS THEN 
                                      P_SUCCESS           := 'N';
                                      E_SQL_ERR_CD        := -20000;
                                      E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
                                      ROLLBACK;

                                      SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                                      RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                                      RETURN;           
                            END; 

                            -- 이전에 최종판정 결과가 부적합이었다면 합격이므로 삭제한다. 
                            BEGIN
                                  MERGE
                                      INTO  TB_QLT024 Q024
                                     USING  DUAL
                                        ON  ( Q024.MSRM_DATE          =  TO_DATE(V_MSRM_DT,'YYYY-MM-DD HH24:MI:SS')
                                       AND    Q024.PRC_SEQNO          =  V_PRC_SEQNO )
                            WHEN MATCHED THEN
                                    UPDATE
                                        SET UCFMTY_AMT     =  V_STCK_QTY 
                                          , FNL_JDGM       =  V_FNL_JDGM 
                                          , UPDDATE        =  SYSDATE
                                          , UPDID          =  V_SESS_USER_ID  
                                    DELETE   WHERE ( Q024.MSRM_DATE          =  TO_DATE(V_MSRM_DT,'YYYY-MM-DD HH24:MI:SS')
                                              AND    Q024.PRC_SEQNO          =  V_PRC_SEQNO );   
                            EXCEPTION           
                            WHEN OTHERS THEN 
                                   P_SUCCESS           := 'N';
                                   E_SQL_ERR_CD        := -20000;
                                   E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
                                   ROLLBACK;

                                   SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                                   RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                                   RETURN;           
                            END;                    
--
--                            V_LGORT_FROM     := '2010';   --저장위치(From) 반제품 창고
--                            V_LGORT_TO       := '2000';   --저장위치(To)   부적합 창고

                       END IF;


				ELSIF V_OBJ.get_string('GRowState') = 'D' THEN  -- 삭제가 있나?
                      RETURN;              

                END IF;

            END LOOP;

    ELSIF P_TYPE = 'SUB_SAVE' THEN
          RETURN;

    END IF;

    P_SUCCESS := 'Y';

    --COMMIT;

    EXCEPTION
    WHEN E_EXCEPTION_USER THEN

        -- 에러 내역 SET
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := -20000;
        E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        ROLLBACK;

    WHEN OTHERS THEN
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := -20000;
        E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END

;

/
