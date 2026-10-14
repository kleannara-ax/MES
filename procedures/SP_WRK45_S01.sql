
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK45_S01" (
	P_TYPE           IN     varchar2, -- LIST, SAVE, SUB_SAVE
	P_JSON_STR       IN     CLOB ,
    P_DOC_NO        OUT     VARCHAR2,
    P_SUCCESS       OUT     varchar2,
    P_ERR_MSG       OUT     VARCHAR2,
	P_RS_LIST       OUT     SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : WRK45{호출 프로그램 ID 기술}
 * PROGRAM NAME  : LIFT출고{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : LIFT출고 및 이력을 관리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 여한진{최초 작성자 명 기술}
 * CREATE DATE   : 2022/06/09 {최초 작성일자 기술}
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
 *      - [TB_WRK018] : (.RU.) LIFT출고
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK45_S01';     -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);


   -- V_RTN_CLOB       CLOB;
   -- V_RTN_CURSOR     SYS_REFCURSOR;
   -- V_ERROR          CLOB;


    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_OBJECT_T;
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
    V_BARCODE_NO	TB_WRK018.BARCODE_NO%TYPE;
    V_LOT_NO        TB_WRK018.LOT_NO%TYPE;

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역
    V_RCVGDS_DT			TB_WRK018.RCVGDS_DT%TYPE;
    V_LIFT_DT			TB_WRK018.LIFT_DT%TYPE;
    V_IND_BCD			TB_WRK018.IND_BCD%TYPE;
    V_MATNR				TB_WRK018.MATNR%TYPE;
    V_SUPY_CD			TB_WRK018.SUPY_CD%TYPE;
    V_ZFBLNO			TB_WRK018.ZFBLNO%TYPE;
    V_CON_NO			TB_WRK018.CON_NO%TYPE;
    V_ROLL_NO			TB_WRK018.ROLL_NO%TYPE;
    V_PCODE				TB_WRK018.PCODE%TYPE;
    V_MWIDTH			TB_WRK018.MWIDTH%TYPE;
    V_ROLLCNT			TB_WRK018.ROLLCNT%TYPE;
    V_NET_WGT			TB_WRK018.NET_WGT%TYPE;
    V_WGT_MUL			TB_WRK018.WGT_MUL%TYPE;
    V_CORE				TB_WRK018.CORE%TYPE;
    V_UNIT				TB_WRK018.UNIT%TYPE;
    V_PCODE_SUPPY		TB_WRK018.PCODE_SUPPY%TYPE;	
    V_BS_WGT			TB_WRK018.BS_WGT%TYPE;
    V_TB_WGT			TB_WRK018.TB_WGT%TYPE;
    V_RB_WGT			TB_WRK018.RB_WGT%TYPE;
    V_UNIT_L			TB_WRK018.UNIT_L%TYPE;
    V_STO_DOC_NO		TB_WRK018.STO_DOC_NO%TYPE;
    V_WRK_STA			TB_WRK018.WRK_STA%TYPE;
    V_CNL_RMK			TB_WRK018.CNL_RMK%TYPE;
    V_RMK_1				TB_WRK018.RMK_1%TYPE;
    V_RMK_2				TB_WRK018.RMK_2%TYPE;
    V_RMK_3				TB_WRK018.RMK_3%TYPE;
    V_RMK_4				TB_WRK018.RMK_4%TYPE;
    V_RMK_5				TB_WRK018.RMK_5%TYPE;
    V_WRK_CLASS			TB_WRK018.WRK_CLASS%TYPE;
    V_WRK_SHIFT			TB_WRK018.WRK_SHIFT%TYPE;
    V_DOC_NO			TB_WRK018.DOC_NO%TYPE;
    V_DOC_SEQNO			TB_WRK018.DOC_SEQNO%TYPE;
    V_WDOC_NO			TB_WRK018.DOC_NO%TYPE;
    V_WDOC_SEQNO			TB_WRK018.DOC_SEQNO%TYPE;
    V_SDOC_NO			TB_WRK018.SDOC_NO%TYPE;
    V_SDOC_SEQNO		TB_WRK018.SDOC_SEQNO%TYPE;
    V_DATE              DATE := SYSDATE;
    V_WERKS             VARCHAR2(10) := 'P100';
    V_WRK_SEQ           NUMBER;
    V_PROD_DT           VARCHAR2(10);
    V_PCODE_NM          TB_MAS001.PCODE_NM%TYPE;
    V_SIZE              VARCHAR2(20);
    V_USER_NM           USRMA.NMLAST%TYPE;
    V_SUPY_VND_BCD      TB_WRK018.SUPY_VND_BCD%TYPE;
    V_STOR_LOC_CD       TB_INV001.STOR_LOC_CD%TYPE;
    V_IND_BCD_PRE       TB_WRK018.IND_BCD%TYPE;
    V_LOT_NO_PRE        TB_WRK018.LOT_NO%TYPE;
    V_REPROD_YN         VARCHAR2(1);
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
   V_RCVGDS_DT          :=      V_JSON.get_string('RCVGDS_DT');     --전기일      
   V_BARCODE_NO         :=      V_JSON.get_string('BARCODE_NO');    --바코드
    P_ERR_MSG           :='';

   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

        V_SQL := ' SELECT W018.BARCODE_NO, --업체바코드
                          W018.RCVGDS_DT,  --입고일자
                          W018.LIFT_DT,    --출고일자
                          W018.IND_BCD     BCD,        --개별바코드
                          W018.LOT_NO,     --LOT_NO
                          W018.MATNR,      --자재코드
                          M001.MATNR_NM,   --자재명
                          W018.SUPY_CD,    --공급업체코드
                          M009.CUST_NM     SUPY_NM,     --공급업체명
                          W018.ZFBLNO,     --B/L 관리번호
                          W018.CON_NO,     --컨테이너No
                          W018.ROLL_NO,    --ROLL ID
                          W018.PCODE,      --지종코드
                          M001.PCODE_NM,   --지종명
                          W018.MWIDTH,     --M/R 지폭
                          W018.ROLLCNT     MROLLCNT,    --M/R 권치수
                          W018.NET_WGT,    --Net 중량
                          W018.WGT_MUL,    --중량배수
                          W018.CORE,       --지관
                          W018.UNIT,       --중량단위
                          W018.PCODE_SUPPY,--고객 지종
                          W018.BS_WGT,     --평량
                          W018.RB_WGT      MBRGEW,     --M/R중량
                          W018.UNIT_L,     --길이단위
                          W018.STO_DOC_NO, --STO 문서번호
                          W018.WRK_STA,    --작업상태
                          W018.CNL_RMK,    --취소사유
                          W018.RMK_1,      --비고
                          W018.RMK_2,      --비고
                          W018.RMK_3,      --비고
                          W018.RMK_4,      --비고
                          W018.RMK_5,      --비고
                          W018.WRK_CLASS,  --작업반
                          W018.WRK_SHIFT,  --작업조
                          W018.DOC_NO,     --MES 문서번호
                          W018.DOC_SEQNO,  --MES 문서번호 순번
                          W018.CDOC_NO,     --MES 취소문서번호
                          W018.CDOC_SEQNO,  --MES 취소문서번호 순번
                          W018.SDOC_NO,    --SAP 확정문서번호
                          W018.SDOC_SEQNO, --SAP 확정문서 순번
                          W018.REGDATE,    --등록일시
                          (SELECT NMLAST FROM USRMA WHERE USERID = W018.REGID) REGNM,   --등록자
                          W018.UPDDATE,    --수정일시
                          (SELECT NMLAST FROM USRMA WHERE USERID = W018.UPDID) UPDNM    --수정자
                     FROM TB_WRK018 W018,    --LIFT출고이력
                          TB_MAS001 M001,    --자재
                          TB_MAS009 M009     --거래처
                    WHERE W018.MATNR = M001.MATNR(+)
                      AND W018.SUPY_CD = M009.CUST_CD(+)  
                      AND NVL(W018.WRK_STA, ''N'') <> ''D'' ';

        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;

        /*IF  V_RCVGDS_DT IS NOT NULL OR TRIM(V_RCVGDS_DT) != '' THEN     --전기일(입고일자)
            V_SQL := V_SQL || ' AND W018.RCVGDS_DT = ''' || V_RCVGDS_DT || '''';        
        END IF;

        IF  V_BARCODE_NO IS NOT NULL OR TRIM(V_BARCODE_NO) != '' THEN         --바코드
            V_SQL := V_SQL || ' AND W018.BARCODE_NO LIKE ''%' || V_BARCODE_NO || '%''';        
        END IF;*/

		V_SQL := V_SQL || ' AND M009.CUST_DIV = ''V'' ';
        V_SQL := V_SQL || ' ORDER BY W018.REGDATE ';

		OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SUB_LIST' THEN  /* 하부 상세 조회 리스트*/

        RETURN;							

    ELSIF P_TYPE = 'SAVE' THEN      --출고

        --V_ARR_HEAD          := TREAT(V_JSON.get ('head') AS json_object_t);
        V_ARR_LIST          := TREAT(V_JSON.get ('list') AS json_object_t);

        --FOR i IN 0..V_ARR_LIST.get_size-1 LOOP

            --V_OBJ               := TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ               := TREAT (V_ARR_LIST.get ('map') AS json_object_t);
            V_BARCODE_NO        :=	V_OBJ.get_string('BARCODE_NO');
            V_RCVGDS_DT			:=	V_OBJ.get_string('RCVGDS_DT');
            V_LIFT_DT			:=	V_OBJ.get_string('LIFT_DT');
            V_IND_BCD			:=	V_OBJ.get_string('BCD');
            V_LOT_NO			:=	V_OBJ.get_string('LOT_NO');
            V_MATNR				:=	V_OBJ.get_string('MATNR');
            V_SUPY_CD			:=	V_OBJ.get_string('SUPY_CD');
            V_ZFBLNO			:=	V_OBJ.get_string('ZFBLNO');
            V_CON_NO			:=	V_OBJ.get_string('CON_NO');
            V_ROLL_NO			:=	V_OBJ.get_string('ROLL_NO');
            V_PCODE				:=	V_OBJ.get_string('PCODE');
            V_MWIDTH			:=	V_OBJ.get_string('MWIDTH');
            V_ROLLCNT			:=	V_OBJ.get_string('MROLLCNT');
            V_NET_WGT			:=	V_OBJ.get_string('NET_WGT');
            V_WGT_MUL			:=	V_OBJ.get_string('WGT_MUL');
            V_CORE				:=	V_OBJ.get_string('CORE');
            V_UNIT				:=	V_OBJ.get_string('UNIT');
            V_PCODE_SUPPY		:=	V_OBJ.get_string('PCODE_SUPPY');	
            V_BS_WGT			:=	V_OBJ.get_string('BS_WGT');
            --V_TB_WGT			:=	V_OBJ.get_string('TB_WGT');
            V_RB_WGT			:=	V_OBJ.get_string('MBRGEW');
            V_UNIT_L			:=	V_OBJ.get_string('UNIT_L');
            V_STO_DOC_NO		:=	V_OBJ.get_string('STO_DOC_NO');
            V_WRK_STA			:=	V_OBJ.get_string('WRK_STA');
            V_CNL_RMK			:=	V_OBJ.get_string('CNL_RMK');
            V_RMK_1				:=	V_OBJ.get_string('RMK_1');
            V_RMK_2				:=	V_OBJ.get_string('RMK_2');
            V_RMK_3				:=	V_OBJ.get_string('RMK_3');
            V_RMK_4				:=	V_OBJ.get_string('RMK_4');
            V_RMK_5				:=	V_OBJ.get_string('RMK_5');
            V_WRK_CLASS			:=	V_OBJ.get_string('WRK_CLASS');
            V_WRK_SHIFT			:=	V_OBJ.get_string('WRK_SHIFT');
            V_DOC_NO			:=	V_OBJ.get_string('DOC_NO');
            V_DOC_SEQNO			:=	V_OBJ.get_string('DOC_SEQNO');
            V_SDOC_NO			:=	V_OBJ.get_string('SDOC_NO');
            V_SDOC_SEQNO		:=	V_OBJ.get_string('SDOC_SEQNO');

            IF V_OBJ.get_string('GRowState') = 'R' THEN
--                --취소이력이 있는지 확인
--                SELECT IND_BCD_PRE, LOT_NO_PRE  INTO V_IND_BCD_PRE, V_LOT_NO_PRE
--                  FROM TB_WRK018
--                 WHERE BARCODE_NO = V_BARCODE_NO; 
--                
--                IF NVL(V_IND_BCD_PRE, ' ') = ' ' THEN
--                    V_REPROD_YN := 'N';
--                ELSE
--                    V_REPROD_YN := 'Y';
--                END IF;

            --개별바코드
               V_LIFT_DT := FN_RECDATE(V_DATE);
               SP_GET_BARCODE_SEQ('IND', 'P100', 'M', V_MATNR, V_LIFT_DT, V_IND_BCD);
               --LOT NO
               SP_GET_BARCODE_SEQ('LOT', 'P100', 'M', V_MATNR, V_LIFT_DT, V_LOT_NO);

               BEGIN
                   SELECT MAX(NVL(WRK_SEQ, 0)) INTO V_WRK_SEQ
                     FROM TB_WRK018
                    WHERE LIFT_DT = V_LIFT_DT;
               EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_WRK_SEQ := 0;
               END;

               SELECT NMLAST, WRK_CLASS INTO V_USER_NM , V_WRK_CLASS
                 FROM USRMA
                WHERE USERID =  V_SESS_USER_ID;

               SELECT PCODE_NM INTO V_PCODE_NM
                 FROM TB_MAS001
                WHERE WERKS = V_WERKS
                  AND MATNR = V_MATNR;

               V_SIZE := SUBSTR(V_MATNR, 10, 4) || '*' || SUBSTR(V_MATNR, 14, 4);

               V_WRK_SEQ := V_WRK_SEQ + 1; 
               V_PROD_DT := TO_CHAR(V_DATE, 'YYYYMMDD');

               V_DOC_NO := FN_GET_MDOCNO('M','IF145');
               V_DOC_SEQNO := 1;

               P_DOC_NO := V_DOC_NO;

               --SAP I/F
               INSERT INTO TB_IFS023(GUBUN,         --구분(C: 생성, D: 취소)    
                                    BARCO,          --업체바코드
                                    MRLOT,          --밀롤 LOT NO
                                    BUDAT,          --LIFT 출고일
                                    ZFCONNO,        --컨테이너 NO
                                    ZFBLNO,         --B/L 관리번호
                                    I_EBELN,        --STO 구매문서번호
                                    MATNR,          --자재코드
                                    ROLLN,          --ROLL NO    
                                    CPCOD,          --업체지종
                                    ROLLC,          --M/R권치수
                                    CORESIZE,       --지관
                                    REMARK,         --비고
                                    MDOCNO,        
                                    MDOCSEQ,
                                    ZRESULT,
                                    MAKE_DATE,
                                    MAKER)
                        VALUES('C',
                                V_BARCODE_NO,
                                V_LOT_NO,
--                                TO_CHAR(TO_DATE(V_LIFT_DT, 'YYYY-MM-DD')),
                                V_LIFT_DT,
                                V_CON_NO,
                                V_ZFBLNO,
                                V_STO_DOC_NO,
                                V_MATNR,
                                V_ROLL_NO,
                                V_PCODE_SUPPY,
                                V_ROLLCNT,
                                V_CORE,
                                '',
                                V_DOC_NO,
                                V_DOC_SEQNO,
                                'N',
                                V_DATE,
                                V_SESS_USER_ID);

               UPDATE TB_INV001
                  SET IND_BCD = V_IND_BCD,
                      LOT_NO = V_LOT_NO,
                      STOR_LOC_CD = '2000',
                      IN_MR_YN = 'Y'
                WHERE WERKS = V_WERKS
                  AND STOR_LOC_CD = '2400'
                  AND IND_BCD = V_BARCODE_NO
                  AND MATNR = V_MATNR;

               UPDATE TB_WRK018
                  SET LIFT_DT = V_LIFT_DT,				
                       IND_BCD	= V_IND_BCD,			
                       LOT_NO	= V_LOT_NO,		
                       WRK_SEQ = V_WRK_SEQ,
                       WRK_CLASS = V_WRK_CLASS,
                       CNL_RMK = '',
                       DOC_NO = V_DOC_NO,
                       DOC_SEQNO = V_DOC_SEQNO,
                       SDOC_NO = '',
                       SDOC_SEQNO = '',
                       UPDDATE  = SYSDATE,
                       UPDID    = V_SESS_USER_ID
                 WHERE BARCODE_NO = V_BARCODE_NO;

            END IF;

        --END LOOP;

    ELSIF P_TYPE = 'SUB_SAVE' THEN  --출고취소
        V_ARR_LIST          := TREAT(V_JSON.get ('list') AS json_object_t);

        --FOR i IN 0..V_ARR_LIST.get_size-1 LOOP

            --V_OBJ               := TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ               := TREAT (V_ARR_LIST.get ('map') AS json_object_t);

            V_BARCODE_NO        :=	V_OBJ.get_string('BARCODE_NO');
            V_RCVGDS_DT			:=	V_OBJ.get_string('RCVGDS_DT');
            V_LIFT_DT			:=	V_OBJ.get_string('LIFT_DT');
            V_IND_BCD			:=	V_OBJ.get_string('BCD');
            V_LOT_NO			:=	V_OBJ.get_string('LOT_NO');
            V_MATNR				:=	V_OBJ.get_string('MATNR');
            V_SUPY_CD			:=	V_OBJ.get_string('SUPY_CD');
            V_ZFBLNO			:=	V_OBJ.get_string('ZFBLNO');
            V_CON_NO			:=	V_OBJ.get_string('CON_NO');
            V_ROLL_NO			:=	V_OBJ.get_string('ROLL_NO');
            V_PCODE				:=	V_OBJ.get_string('PCODE');
            V_MWIDTH			:=	V_OBJ.get_string('MWIDTH');
            V_ROLLCNT			:=	V_OBJ.get_string('ROLLCNT');
            V_NET_WGT			:=	V_OBJ.get_string('NET_WGT');
            V_WGT_MUL			:=	V_OBJ.get_string('WGT_MUL');
            V_CORE				:=	V_OBJ.get_string('CORE');
            V_UNIT				:=	V_OBJ.get_string('UNIT');
            V_PCODE_SUPPY		:=	V_OBJ.get_string('PCODE_SUPPY');	
            V_BS_WGT			:=	V_OBJ.get_string('BS_WGT');
            V_TB_WGT			:=	V_OBJ.get_string('TB_WGT');
            V_RB_WGT			:=	V_OBJ.get_string('RB_WGT');
            V_UNIT_L			:=	V_OBJ.get_string('UNIT_L');
            V_STO_DOC_NO		:=	V_OBJ.get_string('STO_DOC_NO');
            V_WRK_STA			:=	V_OBJ.get_string('WRK_STA');
            V_CNL_RMK			:=	V_OBJ.get_string('CNL_RMK');
            V_RMK_1				:=	V_OBJ.get_string('RMK_1');
            V_RMK_2				:=	V_OBJ.get_string('RMK_2');
            V_RMK_3				:=	V_OBJ.get_string('RMK_3');
            V_RMK_4				:=	V_OBJ.get_string('RMK_4');
            V_RMK_5				:=	V_OBJ.get_string('RMK_5');
            V_WRK_CLASS			:=	V_OBJ.get_string('WRK_CLASS');
            V_WRK_SHIFT			:=	V_OBJ.get_string('WRK_SHIFT');
            V_DOC_NO			:=	V_OBJ.get_string('DOC_NO');
            V_DOC_SEQNO			:=	V_OBJ.get_string('DOC_SEQNO');
            V_SDOC_NO			:=	V_OBJ.get_string('SDOC_NO');
            V_SDOC_SEQNO		:=	V_OBJ.get_string('SDOC_SEQNO');

            SELECT STOR_LOC_CD  INTO V_STOR_LOC_CD
              FROM TB_INV001
             WHERE IND_BCD = V_IND_BCD ;

            IF V_STOR_LOC_CD = '2500' THEN
                P_ERR_MSG := '밀롤창고에 입고되어 출고취소를 할수 없습니다.';
                P_SUCCESS := 'N';
                ROLLBACK;
                RETURN;
            END IF;

            V_DOC_NO := FN_GET_MDOCNO('M','IF145');
            V_DOC_SEQNO := 1;

            P_DOC_NO := V_DOC_NO;

           --SAP I/F
           INSERT INTO TB_IFS023(GUBUN,         --구분(C: 생성, D: 취소)    
                                BARCO,          --업체바코드
                                MRLOT,          --밀롤 LOT NO
                                BUDAT,          --LIFT 출고일
                                ZFCONNO,        --컨테이너 NO
                                ZFBLNO,         --B/L 관리번호
                                I_EBELN,        --STO 구매문서번호
                                MATNR,          --자재코드
                                ROLLN,          --ROLL NO    
                                CPCOD,          --업체지종
                                ROLLC,          --M/R권치수
                                CORESIZE,       --지관
                                REMARK,         --비고
                                MDOCNO,        
                                MDOCSEQ,
                                ZRESULT,
                                MAKE_DATE,
                                MAKER)
                    VALUES('D',
                            V_BARCODE_NO,
                            V_LOT_NO,
--                                TO_CHAR(TO_DATE(V_LIFT_DT, 'YYYY-MM-DD')),
                            V_LIFT_DT,
                            V_CON_NO,
                            V_ZFBLNO,
                            V_STO_DOC_NO,
                            V_MATNR,
                            V_ROLL_NO,
                            V_PCODE_SUPPY,
                            V_ROLLCNT,
                            V_CORE,
                            '',
                            V_DOC_NO,
                            V_DOC_SEQNO,
                            'N',
                            V_DATE,
                            V_SESS_USER_ID);

        SELECT SUPY_VND_BCD INTO V_SUPY_VND_BCD
          FROM TB_WRK018
         WHERE BARCODE_NO = V_BARCODE_NO;

        UPDATE TB_INV001
          SET IND_BCD = V_BARCODE_NO,
              LOT_NO = V_BARCODE_NO,
              STOR_LOC_CD = '2400'
        WHERE WERKS = V_WERKS
          AND STOR_LOC_CD = '2000'
          AND IND_BCD = V_IND_BCD
          AND MATNR = V_MATNR;

       UPDATE TB_WRK018
          SET LIFT_DT = '',				
               IND_BCD	= '',			
               LOT_NO	= '',		
               WRK_SEQ = 0,
               DOC_NO = '',
               DOC_SEQNO = '',
               CDOC_NO = V_DOC_NO,
               CDOC_SEQNO = V_DOC_SEQNO,
               SDOC_NO = '',
               SDOC_SEQNO = '',
               IND_BCD_PRE = V_IND_BCD,
               LOT_NO_PRE = V_LOT_NO,
               UPDDATE  = SYSDATE,
               UPDID    = V_SESS_USER_ID
         WHERE BARCODE_NO = V_BARCODE_NO;                                    
        --END LOOP;
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
--        E_SQL_ERR_CD        := -20990;
--        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--        ROLLBACK;
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
