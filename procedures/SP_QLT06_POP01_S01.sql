
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_QLT06_POP01_S01" (
	P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    CLOB,
    P_DOC_NO        OUT    varchar2, 
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : QLT06_POP01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 공정창고 조회{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 품질검사(순회 외관 및 완제품 검사)과정에서 발견된 완제품의 하위 원부자재에 대하여 
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

    V_PRG_NM          VARCHAR2(100)  := 'SP_QLT06_POP01_S01';     -- PROCEDURE NAME

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
    V_STOR_LOC_CD      TB_INV001.STOR_LOC_CD%TYPE;
--    V_SUPY_CD          TB_INV001.SUPY_CD%TYPE;
--    V_STCK_STA         TB_INV001.STCK_STA%TYPE;
    V_FNL_JDGM         TB_INV001.FNL_JDGM%TYPE;
    V_IND_FNL_JDGM     TB_INV001.FNL_JDGM%TYPE;
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

--    V_DOC_NO           TB_IFSWM001.DOC_NO%TYPE; --MES 문서번호
--    V_DOC_SEQNO        TB_IFSWM001.DOC_SEQNO%TYPE; --MES 문서순번
    V_ORDER_NO         TB_IFSWM001.ORDER_NO%TYPE; --오더번호
    V_ORDER_SEQNO      TB_IFSWM001.ORDER_SEQNO%TYPE; --오더순번
    V_SUPY_CD          TB_IFSWM001.SUPY_CD%TYPE; --공급처
    V_RCVGDS_QTY       TB_IFSWM001.QTY%TYPE; --입고수량
--    V_UNIT             TB_IFSWM001.UNIT%TYPE; --단위
    V_VGBEL            TB_IFSWM001.VGBEL%TYPE;   --문서번호
    V_VGPOS            TB_IFSWM001.VGPOS%TYPE;      --문서아이템
    V_STOK_KY          TB_IFSWM001.STOK_KY%TYPE; --재고키
    V_LOT_NUM          TB_IFSWM001.LOT_NUM%TYPE;    --???
    V_STCK_STA         TB_IFSWM001.STCK_STA%TYPE;
    V_NTN_CD           TB_IFSWM001.NTN_CD%TYPE;
    V_CRSPD_CD         TB_IFSWM001.CRSPD_CD%TYPE; --공급업체코드
    V_PRDC_DT          TB_IFSWM001.PRDC_DT%TYPE;
    V_RCVGDS_DT        TB_IFSWM001.RCVGDS_DT%TYPE;
    V_DSTBT_DDLIN      TB_IFSWM001.DSTBT_DDLIN%TYPE;
    V_CHKRST           TB_IFSWM001.CHKRST%TYPE;
    V_QTYGOD           TB_IFSWM001.QTYGOD%TYPE;
    V_QTYBAD           TB_IFSWM001.QTYBAD%TYPE;
    V_BADRSN           TB_IFSWM001.BADRSN%TYPE;
    V_BADRSNNM         TB_IFSWM001.BADRSNNM%TYPE;

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
   V_MATNR_NM           :=       V_JSON.get_string('MATNR_NM');     -- 자재명 
   V_MATNR              :=       V_JSON.get_string('MATNR');     -- 자재코드
   V_DOC_NO             :=       V_JSON.get_string('DOC_NO');    -- MES 전송 문서번호
   V_DOC_SEQNO          :=       V_JSON.get_number('DOC_SEQNO'); -- MES 전송 문서번호순번
   V_PRD_DT             :=       V_JSON.get_string('PRD_DT');    -- 제조일자


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
                   , I007.WDOC_NO     AS "WDOC_NO"      --WMS 출고 문서번호(H)
                   , I007.WDOC_SEQNO  AS "WDOC_SEQNO"   --WMS 출고 문서순번(H)
                   , I007.DLFL        AS "DLFL"         --WMS 출고 지시자(C:신규, D:삭제)(H)
                   , I007.SUPY_CD     AS "SUPY_CD"
                   , I007.LOT_NUM     AS "LOT_NUM"
                   , I007.QTY         AS "RCVGDS_QTY"
                   , I001.VBELN       AS "VGBELN"
                   , I001.POSNR       AS "POSNR"
                   , I007.STOK_KY     AS "STOR_KY"
                   , I007.NTN_CD      AS "NTN_CD"
                   , I007.CRSPD_CD    AS "CRSPD_CD"
                   , I007.PRDC_DT     AS "PRDC_DT"
                   , I007.RCVCDS_DT   AS "RCVGDS_DT"
                   , I007.DSTBT_DDLIN AS "DSTBT_DDLIN"
                 FROM TB_INV001 I001,
                      TB_INV007 I007,
                      TB_MAS001 M001,
                      TB_MAS003 M003,
                      TB_MAS028 M028
                WHERE I001.WERKS       = M001.WERKS(+)
                  AND I001.MATNR       = M001.MATNR(+)
                  AND I001.WDOC_NO     = I007.WDOC_NO(+)
                  AND I001.WDOC_SEQNO  = I007.WDOC_SEQNO(+)
                  AND I001.WERKS       = M003.WERKS(+)
                  AND I001.STOR_LOC_CD = M003.STOR_LOC_CD(+)
                  AND I001.WERKS       = M028.WERKS(+)
                  AND I001.STOR_LOC_CD = M028.STOR_LOC_CD(+)
                  AND I001.LOC_CD      = M028.LOC_CD(+)
                  AND (I007.DLFL        <> ''D'' OR I007.DLFL   IS NULL)
                  AND M001.MATNR_DIV  NOT IN (''FERT'',''HALB'', ''HAWA'' )
                  AND I001.STCK_QTY > 0 ';

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN -- 플랜트
            V_SQL := V_SQL || ' AND I001.WERKS  = ''' || V_WERKS || '''';             
        END IF;

        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN -- 미 적용
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;                     

        IF  V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN -- 자재코드
            V_SQL := V_SQL || ' AND I001.MATNR IN (SELECT SUB_MATNR FROM TB_MAS008 WHERE WERKS ='''|| TRIM(V_WERKS) || ''' AND MATNR = '''|| TRIM(V_MATNR) || ''') ';
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
        V_FNL_JDGM           := V_JSON.get_string('FNL_JDGM');         /*상단 최종판정*/   
        V_DOC_NEW_NO         := FN_GET_MDOCNO(V_PLT_CD, 'MES_IF_901'); /*WMS 전송 문서번호 생성*/
        P_DOC_NO             := '';

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP

                V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
                V_OBJ           := TREAT (V_OBJ.get ('map') AS json_object_t);

                V_WERKS         := V_OBJ.get_string('WERKS');
                V_STOR_LOC_CD   := V_OBJ.get_string('STOR_LOC_CD');
                V_LOT_NO        := V_OBJ.get_string('VND_LOT_NO');
                V_IND_BCD       := V_OBJ.get_string('IND_BCD');
                V_MATNR         := V_OBJ.get_string('MATNR');
                V_STCK_QTY      := V_OBJ.get_string('STCK_QTY');
                V_UNIT          := V_OBJ.get_string('UNIT');
                V_IND_FNL_JDGM  := V_OBJ.get_string('FNL_JDGM');         /*선택된 개별 판정결과*/

                V_MSRM_DATE     := V_OBJ.get_date('MSRM_DATE');          /*측정일시*/
                V_DOC_NO        := V_OBJ.get_string('DOC_NO');           /*MES 문서번호*/
                V_DOC_SEQNO     := V_OBJ.get_number('DOC_SEQNO');        /*MES 문서순번*/
                V_WDOC_NO       := V_OBJ.get_string('WDOC_NO');          /*WMS 문서 참조번호*/
                V_WDOC_SEQNO    := V_OBJ.get_string('WDOC_SEQNO');       /*WMS 문서 참조 아이템*/
                V_DLFL          := V_OBJ.get_string('DLFL');             /*WMS 지시자*/

                V_SUPY_CD       := V_OBJ.get_string('SUPY_CD');          /*WMS 공급업체*/
                V_RCVGDS_QTY    := V_OBJ.get_number('RCVGDS_QTY');       /*WMS 입고량*/
                V_LOT_NUM       := V_OBJ.get_string('LOT_NUM');          /*WMS LOT NUM*/ 
                V_VGBEL         := V_OBJ.get_string('VBELN');            /*WMS 판매문서*/
                V_VGPOS         := V_OBJ.get_string('POSNR');            /*WMS 판매문서 아이템*/
                V_STOK_KY       := V_OBJ.get_string('STOK_KY');          /*WMS 저장키*/
                V_NTN_CD        := V_OBJ.get_string('NTN_CD');           /*WMS 국가코드*/
                V_CRSPD_CD      := V_OBJ.get_string('CRSPD_CD');         /*WMS 거래처코드*/ 
                V_PRDC_DT       := V_OBJ.get_string('PRDC_DT');          /*WMS 제조일자*/
                V_RCVGDS_DT     := V_OBJ.get_string('RCVGDS_DT');        /*WMS 입고일자*/
                V_DSTBT_DDLIN   := V_OBJ.get_string('DSTBT_DDLIN');      /*WMS 유통기한*/

                V_MSRM_DT       := V_OBJ.get_string('MSRM_DATE');

                IF TRIM(V_DOC_NO) IS NULL OR TRIM(V_DOC_NO) = ' ' THEN   /*이미 등록된 문서번호가 없으면 신규 번호를 할당한다.*/
                   V_DOC_NO          := V_DOC_NEW_NO; 

                END IF;

                IF V_OBJ.get_string('GRowState') = 'C' THEN  --추가가 있나?
                      RETURN; 

--                ELSIF  V_OBJ.get_string('GRowState') = 'C' THEN
                ELSIF  V_OBJ.get_string('GRowState') = 'R' THEN  -- 수정되는 사항이 아닌 단순히 선택된 항목에 대한 처리이므로 'R'을 가지고 처리한다.

                       IF TRIM(V_MSRM_DT) IS NULL OR TRIM(V_MSRM_DT) = ' ' THEN
                           V_MSRM_DT         := TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI:SS'); 
                       END IF;

                       IF  V_FNL_JDGM = 'FAIL' THEN
                           IF  V_IND_FNL_JDGM <> 'FAIL' THEN  -- 판정하기 않았거나,합격이었다면 부적합으로... 
                                -- 최종판정 결과가 부적합 이면 부적합 정보에...
                                -- 공정창고 재고를 위치를 부적합창고로 이전 시킨다.(2010) 
                                BEGIN
                                    UPDATE TB_INV001 I001
                                       SET I001.STOR_LOC_CD        = '2010'
                                         , I001.STCK_STA           = '40'  -- 00:정상, 40: 부적합
                     --                    , I001.STCK_QTY           =  0
                                         , I001.UCFMTY_AMT         =  V_STCK_QTY
                                         , I001.UCFMTY_FLG         = 'Y'
                                         , I001.FNL_JDGM           =  V_FNL_JDGM 
                                         , I001.MSRM_DATE          =  SYSDATE
                                         , I001.INSPR_ID           =  V_SESS_USER_ID
                                         , I001.UPDDATE            =  SYSDATE
                                         , I001.UPDID              =  V_SESS_USER_ID               
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

                                -- 적합, 부적합 모두 판정결과를 WMS로 전송처리 진행
                                BEGIN
                                      MERGE
                                          INTO  TB_IFSWM001 WM001
                                         USING  DUAL
                                            ON  ( DOC_NO      = V_DOC_NO
                                           AND    DOC_SEQNO   = V_DOC_SEQNO )
                                WHEN MATCHED THEN
                                         UPDATE
                                            SET IF_STATUS     = NULL,    --WMS 결과값 리턴(S,성공, E:오류)
                                                IF_GET_DATE   = SYSDATE, --MES 등록일시
                                                IF_SET_DATE   = NULL,    --WMS 전송일시
                                                IF_ERR_MESS   = NULL     --WMS 결과 메시지
                                WHEN NOT MATCHED THEN                 
                                        INSERT  (
                                                DOC_NO,      --MES 문서번호
                                                DOC_SEQNO,   --MES 문서순번
                                                ORDER_NO,    --오더번호
                                                ORDER_SEQNO, --오더순번
                                                SUPY_CD,     --공급자
                                                MATNR,       --품목코드
                                                QTY,         --입고수량
                                                UNIT,        --입고단위
                                                VGBEL,       --참조번호(WMS문서번호)
                                                VGPOS,       --참조번호 아이템(WMS 문서아이템 번호
                                                STOK_KY,     --STOCK_KEY
                                                LOT_NUM,     --WMS LOT 속성코드
                                                STOR_LOC,    --저장위치(WMS 저장위치)
                                                WERKS,       --플랜트
                                                STCK_STA,    --재고상태(00정상 30불용 05품질 50폐기 10보류)
                                                NTN_CD,      --국가코드
                                                CRSPD_CD,    --거래처코드
                                                PRDC_DT,     --제조일자
                                                RCVGDS_DT,   --입고일자
                                                DSTBT_DDLIN, --유통기한
                                                IND_BCD,     --개별바코드(공급업체바코드)
                                                LOT_NO,      --업체LOT NO/SAP 배치번호)
                                                CHKRST,      --검사진행상태
                                                QTYGOD,      --정상수량
                                                QTYBAD,      --불량수량
                                                BADRSN,      --불량사유
                                                BADRSNNM,    --불량사유명칭
                                                IF_STATUS,   --WMS 결과값 리턴(S,성공, E:오류)
                                                IF_GET_DATE, --MES 등록일시
                                                IF_SET_DATE, --WMS 전송일시
                                                IF_ERR_MESS  --WMS 결과 메시지
                                        ) VALUES (
                                                V_DOC_NO,
                                                i + 1,
                                                V_ORDER_NO,
                                                V_ORDER_SEQNO,
                                                V_SUPY_CD,
                                                V_MATNR,
                                                V_RCVGDS_QTY,
                                                V_UNIT,
                                                V_VGBEL,
                                                V_VGPOS,
                                                V_STOK_KY,
                                                V_LOT_NUM,
                                                '2010',
                                                V_WERKS,
                                                V_STCK_STA,
                                                V_NTN_CD,
                                                V_CRSPD_CD,
                                                V_PRDC_DT,
                                                V_RCVGDS_DT,
                                                V_DSTBT_DDLIN,
                                                V_IND_BCD,
                                                V_LOT_NO,
                                                'QR',
                                                NVL(V_STCK_QTY,0),
                                                V_STCK_QTY,
                                                '98',
                                                '순회검사 원부자재 부적합',
                                                'N',
                                                SYSDATE,
                                                NULL,
                                                NULL
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
                           END IF;

                       ELSE 
                           --최종 판정이 합격이면...
                           IF  V_IND_FNL_JDGM <> 'PASS' THEN -- 과거에 부적합이거나 판정하지 않았다면..
                               -- 과거에 부적합이었다면 다시 정상으로 환원...
                               -- 공정창고 재고를 위치를 반제품 창고로 이전 시킨다.(2000) 
                               BEGIN
                                    UPDATE TB_INV001 I001
                                       SET I001.STOR_LOC_CD        = '2000'
                                         , STCK_STA                = '00'  -- 00:정상, 40: 부적합                               
                     --                    , I001.STCK_QTY           =  V_STCK_QTY
                                         , I001.UCFMTY_AMT         =  0
                                         , I001.UCFMTY_FLG         = 'N'
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

                                -- 적합, 부적합 모두 판정결과를 WMS로 전송처리 진행
                                BEGIN
                                      MERGE
                                          INTO  TB_IFSWM001 WM001
                                         USING  DUAL
                                            ON  ( DOC_NO      = V_DOC_NO
                                           AND    DOC_SEQNO   = V_DOC_SEQNO )
                                WHEN MATCHED THEN
                                         UPDATE
                                            SET IF_STATUS     = NULL,    --WMS 결과값 리턴(S,성공, E:오류)
                                                IF_GET_DATE   = SYSDATE, --MES 등록일시
                                                IF_SET_DATE   = NULL,    --WMS 전송일시
                                                IF_ERR_MESS   = NULL     --WMS 결과 메시지
                                WHEN NOT MATCHED THEN                 
                                        INSERT  (
                                                DOC_NO,      --MES 문서번호
                                                DOC_SEQNO,   --MES 문서순번
                                                ORDER_NO,    --오더번호
                                                ORDER_SEQNO, --오더순번
                                                SUPY_CD,     --공급자
                                                MATNR,       --품목코드
                                                QTY,         --입고수량
                                                UNIT,        --입고단위
                                                VGBEL,       --참조번호(WMS문서번호)
                                                VGPOS,       --참조번호 아이템(WMS 문서아이템 번호
                                                STOK_KY,     --STOCK_KEY
                                                LOT_NUM,     --WMS LOT 속성코드
                                                STOR_LOC,    --저장위치(WMS 저장위치)
                                                WERKS,       --플랜트
                                                STCK_STA,    --재고상태(00정상 30불용 05품질 50폐기 10보류)
                                                NTN_CD,      --국가코드
                                                CRSPD_CD,    --거래처코드
                                                PRDC_DT,     --제조일자
                                                RCVGDS_DT,   --입고일자
                                                DSTBT_DDLIN, --유통기한
                                                IND_BCD,     --개별바코드(공급업체바코드)
                                                LOT_NO,      --업체LOT NO/SAP 배치번호)
                                                CHKRST,      --검사진행상태
                                                QTYGOD,      --정상수량
                                                QTYBAD,      --불량수량
                                                BADRSN,      --불량사유
                                                BADRSNNM,    --불량사유명칭
                                                IF_STATUS,   --WMS 결과값 리턴(S,성공, E:오류)
                                                IF_GET_DATE, --MES 등록일시
                                                IF_SET_DATE, --WMS 전송일시
                                                IF_ERR_MESS  --WMS 결과 메시지
                                        ) VALUES (
                                                V_DOC_NO,
                                                i + 1,
                                                V_ORDER_NO,
                                                V_ORDER_SEQNO,
                                                V_SUPY_CD,
                                                V_MATNR,
                                                V_RCVGDS_QTY,
                                                V_UNIT,
                                                V_VGBEL,
                                                V_VGPOS,
                                                V_STOK_KY,
                                                V_LOT_NUM,
                                                '2000',
                                                V_WERKS,
                                                V_STCK_STA,
                                                V_NTN_CD,
                                                V_CRSPD_CD,
                                                V_PRDC_DT,
                                                V_RCVGDS_DT,
                                                V_DSTBT_DDLIN,
                                                V_IND_BCD,
                                                V_LOT_NO,
                                                'QR',
                                                NVL(V_STCK_QTY,0),
                                                V_STCK_QTY,
                                                '98',
                                                '순회검사 원부자재 적합',
                                                'N',
                                                SYSDATE,
                                                NULL,
                                                NULL
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

                           END IF;

                       END IF;

                       P_DOC_NO := V_DOC_NO;

				ELSIF V_OBJ.get_string('GRowState') = 'D' THEN  -- 삭제가 있나?
                      RETURN;              

                END IF;

            END LOOP;

    ELSIF P_TYPE = 'SUB_SAVE' THEN
          RETURN;

    END IF;

    P_SUCCESS := 'Y';

    COMMIT;

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
