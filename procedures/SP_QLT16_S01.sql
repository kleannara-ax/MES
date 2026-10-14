
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_QLT16_S01" (
	P_TYPE           IN    varchar2, -- LIST,  SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
    P_DOC_NO        OUT    VARCHAR2,    --SAP 재고이전
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : QLT16{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 품질 재검사{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 품질 부적합 대상을 재검사(화장지 합지롤)에 의한 판정결과를 변경한다. 
 *                 SAP로 재고상태 변경내역을 송신한다. 
 *                  
 * AUTHOR NAME   : 김성하{최초 작성자 명 기술}
 * CREATE DATE   : 2022/04/29 {최초 작성일자 기술}
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
 *       - [TB_MAS018]  : (.R..) 부서정보
 *       - [TB_MAS028]  : (.R..) 공정대기 창고 위치정보
 *       - [TB_QLT020]  : (.R..) 품질검사 결과 마스터
 *       - [TB_QLT024]  : (.RU.) 부적합 발생이력
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_QLT16_S01';     -- PROCEDURE NAME

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
    V_WERKS            TB_QLT024.WERKS%TYPE; -- 플랜트코드
    V_REG_YN           VARCHAR2(1);          -- 등록여부


    V_UNIT             TB_MAS001.UNIT%TYPE;

    V_DOC_NO          TB_QLT020.DOC_NO%TYPE;       --SAP 재고이전
    V_DOC_SEQNO       TB_QLT020.DOC_SEQNO%TYPE;
    
    V_MATNR            TB_QLT024.MATNR%TYPE; -- 자재코드

    V_INSP_ITEM_GRP_CD TB_QLT024.INSP_ITEM_GRP_CD%TYPE;
    V_PRC_MTD          TB_QLT024.PRC_MTD%TYPE;
   
    --2022-09-28(수요일) 안상현, 품질팀 요청사항으로 인하여, 품질 재검사에 품질처리방법 추가
    V_PRC_QC_MTD      TB_QLT024.PRC_QC_MTD%TYPE; --품질처리방법
   
    V_COMPKY           TB_QLT024.COMPKY%TYPE;
    V_DEPT_CD          TB_QLT024.DEPT_CD%TYPE;
    V_RMK              TB_QLT024.RMK%TYPE;
--    V_RMK              VARCHAR2(1000);
    V_FNL_JDGM         TB_QLT024.FNL_JDGM%TYPE;
    V_MSRM_DATE        TB_QLT024.MSRM_DATE%TYPE;
    V_PRC_SEQNO        TB_QLT024.PRC_SEQNO%TYPE;
    V_LOT_NO           TB_QLT024.LOT_NO%TYPE;
    V_IND_BCD          TB_QLT024.IND_BCD%TYPE;
    V_STOR_LOC_CD      TB_QLT024.STOR_LOC_CD%TYPE;    
    V_UCFMTY_AMT       TB_QLT024.UCFMTY_AMT%TYPE;
    
    V_LGORT_FROM       TB_IFS009.LGORT_FROM%TYPE;   --저장위치(From)
    V_LGORT_TO         TB_IFS009.LGORT_TO%TYPE;     --저장위치(To)

    V_MATNR_DIV         TB_MAS001.MATNR_DIV%TYPE;
    V_MACH_CD           TB_INV001.MACH_CD%TYPE;
    V_BARCODE           TB_INV001.IND_BCD%TYPE;
    V_WRK_ORDR_NO       TB_INV001.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO    TB_INV001.WRK_ORDR_SEQNO%TYPE;
    V_APVR_STA			TB_INV001.APVR_STA%TYPE;
    V_DISPO_IND_BCD		TB_INV001.IND_BCD%TYPE;		--폐기 개별바코드
    V_ORDER_NO			TB_INV001.ORDER_NO%TYPE;
    V_DISPO_QTY			TB_INV001.STCK_QTY%TYPE;
    V_VBELN				TB_INV001.VBELN%TYPE;
    V_POSNR				TB_INV001.POSNR%TYPE;
    
    V_DOC_NO_PRE        TB_WRK021.DOC_NO%TYPE;
    V_DOC_SEQNO_PRE     TB_WRK021.DOC_SEQNO%TYPE;
    V_SDOC_NO_PRE       TB_WRK021.SDOC_NO%TYPE;
    V_SDOC_SEQNO_PRE    TB_WRK021.SDOC_SEQNO%TYPE;
    V_SAP_WRK_CD        TB_MAS012.SAP_WRK_CD%TYPE;
    
    V_MEDIAT_AMT       NUMBER(9,2)  := 0;
    V_MSRM_DT          VARCHAR2(20) := '';
    V_SDATE            VARCHAR2(30);
    V_EDATE            VARCHAR2(30);

    --기타처리
    V_CREATE_FLG       CHAR(1)  := 'N';
    V_UPDATE_FLG       CHAR(1)  := 'N';

    V_CNT              NUMBER;
BEGIN
   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG   := 'N';
   V_RUN_SQL := 'Y';

   V_JSON    := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=       V_JSON.get_string('SES_WAREKY');

   /* 조건값 할당 */
   V_RANGE_SQL          :=       V_JSON.get_string('RANGE_SQL'); -- 플랜트코드, 자재그룹, 자재코드
   V_WERKS              :=       V_JSON.get_string('WERKS');     -- 플랜트코드
   V_SDATE              :=       V_JSON.get_string('SDATE');     -- 측정일시(시작)
   V_EDATE              :=       V_JSON.get_string('EDATE');     -- 측정일시(끝)
   V_REG_YN             :=       V_JSON.get_string('INSP_YN');    -- 검사여부

   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

      V_SQL := 'SELECT  Q024.WERKS          AS "WERKS",       -- 플랜트
                        Q024.MSRM_DATE      AS "MSRM_DATE",   -- 판정일자 
                        Q024.PRC_SEQNO      AS "PRC_SEQNO",   -- 처리순번(H)
                        Q024.MATNR          AS "MATNR",       -- 자재코드
                        M001.MATNR_NM       AS "MATNR_NM",    -- 자재명
                        Q024.LOT_NO         AS "LOT_NO",
                        Q024.IND_BCD        AS "IND_BCD",
                        M001.LGPRO          AS "STOR_LOC_CD",          
                        Q024.INSP_ITEM_GRP_CD AS "INSP_ITEM_GRP_CD",
                        M001.UNIT           AS "UNIT",                               -- 단위(H)
                        M001.MATNR_DIV      AS "MATNR_DIV",                          --자재구분(FERT, HALB,...)
                       (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''UNIT''  AND CMCDVL = M001.UNIT) AS "UNIT_NM",
                        I001.STCK_QTY       AS "STCK_QTY",
                        Q024.UCFMTY_AMT                           AS "UCFMTY_AMT",   -- 부적합수량
                        DECODE(NVL(Q024.UPDDATE, ''''), '''', Q024.UCFMTY_AMT, '''')    AS "MEDIAT_AMT",   -- 부적합수량을 조정할 수 있도록 동일한 값으로 배치 
                        NVL(Q024.VND_LOT_NO, Q020.VND_LOT_NO)     AS "VND_LOT_NO",   -- 공급업체LOT번호
                        NVL(Q024.SUPY_VND_BCD, Q020.SUPY_VND_BCD) AS "SUPY_VND_BCD", -- 공급업체바코드
                        Q024.DEPT_CD,                                                -- 부서코드(서치팝업) 
                        Q024.FNL_JDGM,
                       (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''FNL_JDGM''  AND CMCDVL = Q024.FNL_JDGM) AS "FNL_JDGM_NM",
						Q024.PRC_QC_MTD 						  AS PRC_QC_MTD, 	 -- 품질처리방법        
                        Q024.PRC_MTD                              AS "PRC_MTD",      -- 콤보박스(선택)    --처리방법
                        FN_CD_VAL(''PRC_MTD'', Q024.PRC_MTD)      AS "PRC_MTD_NM",   -- 처리방법(명)
                        Q024.RMK                                  AS "RMK",          -- 비고
                        I001.MACH_CD            AS "MACH_CD", 
                        I001.WRK_ORDR_NO        AS "WRK_ORDR_NO", 
                        I001.WRK_ORDR_SEQNO     AS "WRK_ORDR_SEQNO",
                        I001.ORDER_NO           AS "ORDER_NO",
                        I001.VBELN              AS "VBELN", 
                        I001.POSNR              AS "POSNR",
                        Q024.REGDATE AS "REGDATE",
                        NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = Q024.REGID),'''') AS "REGNM",
                        Q024.UPDDATE AS "UPDDATE",
                        NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = Q024.UPDID),'''') AS "UPDNM"
                FROM  TB_QLT024 Q024,
                      TB_QLT020 Q020,
                      TB_MAS018 M018,
                      TB_MAS001 M001,
                      TB_INV001 I001
                WHERE Q024.COMPKY     = M018.COMPKY(+)
                  AND Q024.DEPT_CD    = M018.DEPT_CD(+)
                  AND Q024.MATNR      = M001.MATNR(+)
                  AND Q024.WERKS      = M001.WERKS(+)
                  AND Q024.MSRM_DATE  = Q020.MSRM_DATE(+)
                  AND Q024.PRC_SEQNO  = Q020.PRC_SEQNO(+)
                  AND Q024.WERKS      = I001.WERKS(+)
                  AND Q024.IND_BCD    = I001.IND_BCD(+)
                  AND Q024.MATNR      = I001.MATNR(+)
                  AND Q024.PRC_MTD IS NOT NULL 
                  AND Q024.UCFMTY_AMT > 0 '; -- 부적합 창고에 모인넘들만 가지고 와서 재검사 진행

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN -- 플랜트
            V_SQL := V_SQL || ' AND Q024.WERKS  = ''' || V_WERKS || '''';             
        END IF;
        
        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN 
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MATNR',  'Q024.MATNR');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MSRM_DATE', 'TO_CHAR(Q024.MSRM_DATE, ''YYYYMMDD'')' );
            
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;
     
--        IF  ( V_SDATE IS NOT NULL OR TRIM(V_SDATE) != '' ) AND (V_EDATE IS NOT NULL OR TRIM(V_EDATE) != '')THEN -- 검사일자
--            V_SQL := V_SQL || ' AND Q024.MSRM_DATE >= TO_DATE(''' || V_SDATE || ''',''YYYY-MM-DD HH24:MI:SS'') AND Q024.MSRM_DATE < TO_DATE(''' || V_EDATE || ''',''YYYY-MM-DD HH24:MI:SS'') + 1';  
--        END IF;
 
--        IF  V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN -- 자재코드
--            V_SQL := V_SQL || ' AND REGEXP_LIKE(Q024.MATNR, ''' || V_MATNR || ''') ';
--        END IF; 
 
        IF  V_REG_YN IS NOT NULL OR TRIM(V_REG_YN) != '' THEN -- 검사여부
            V_SQL := V_SQL || ' AND DECODE(Q024.FNL_JDGM, NULL, ''N'', ''Y'') = '''|| TRIM(V_REG_YN) || '''';
        END IF;

		V_SQL := V_SQL || ' ORDER BY Q024.MSRM_DATE';
 
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

        V_DOC_NO            := FN_GET_MDOCNO('M', 'IF131');    --SAP 재고이전
        
        -- 상단의 입력된 맵에서 가져온다.
        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP

                V_OBJ               := TREAT (V_ARR_LIST.get (i) AS json_object_t);
                V_OBJ               := TREAT (V_OBJ.get ('map') AS json_object_t);

                V_WERKS             := V_OBJ.get_string('WERKS');            /*플랜트*/                
                V_MATNR             := V_OBJ.get_string('MATNR');            /*자재코드*/                
                V_MSRM_DATE         := V_OBJ.get_date('MSRM_DATE');          /*측정일시*/                
                V_MSRM_DT           := V_OBJ.get_string('MSRM_DATE');
                V_PRC_SEQNO         := V_OBJ.get_number('PRC_SEQNO');
                V_PRC_MTD           := V_OBJ.get_string('PRC_MTD'); 
                V_STOR_LOC_CD       := V_OBJ.get_string('STOR_LOC_CD');            /*단위*/   
                V_FNL_JDGM          := V_OBJ.get_string('FNL_JDGM');        /*최종판정*/   
                V_LOT_NO            := V_OBJ.get_string('LOT_NO');          /*LOT NO*/ 
                V_IND_BCD           := V_OBJ.get_string('IND_BCD');         /*개별바코드*/   
                V_UNIT              := V_OBJ.get_string('UNIT');            /*단위*/   
                V_MATNR_DIV         := V_OBJ.get_string('MATNR_DIV');       /*자재구분*/
                V_UCFMTY_AMT        := V_OBJ.get_number('UCFMTY_AMT');      /*부적합량*/   
                V_MEDIAT_AMT        := V_OBJ.get_number('MEDIAT_AMT');      /*조정량(다시 합격 시킬량*/
                V_COMPKY            := V_OBJ.get_string('COMPKY');
                V_DEPT_CD           := V_OBJ.get_string('DEPT_CD');
                V_RMK               := V_OBJ.get_string('RMK');
                V_INSP_ITEM_GRP_CD  := V_OBJ.get_string('INSP_ITEM_GRP_CD');
                V_MACH_CD           := V_OBJ.get_string('MACH_CD');
                V_WRK_ORDR_NO       := V_OBJ.get_string('WRK_ORDR_NO');
                V_WRK_ORDR_SEQNO    := V_OBJ.get_string('WRK_ORDR_SEQNO');
                V_ORDER_NO          := V_OBJ.get_string('ORDER_NO');
                V_VBELN             := V_OBJ.get_string('VBELN');
                V_POSNR             := V_OBJ.get_number('POSNR');
               
                --2022-09-28(수요일) 안상현, 품질팀 요청사항으로 인하여, 품질 재검사에 품질처리방법 추가
                V_PRC_QC_MTD		:= V_OBJ.get_string('PRC_QC_MTD');		--품질처리방법

--                IF TRIM(V_DOC_NO) IS NULL OR TRIM(V_DOC_NO) = ' ' THEN             /*이미 등록된 문서번호가 없으면 신규 번호를 할당한다.*/
--                   V_DOC_NO          := V_DOC_NEW_NO;
--                END IF;

                IF V_OBJ.get_string('GRowState') = 'C' THEN  --추가가 있나?
                      RETURN; 

                ELSIF  (V_OBJ.get_string('GRowState') = 'U' OR V_OBJ.get_string('GRowState') = 'R') THEN

                       IF NVL(V_MEDIAT_AMT,0) = NVL(V_UCFMTY_AMT,0)  THEN  -- 부적합량 전체를 합격으로 처리하면 이전 창고로 복귀... 
                           IF  V_MATNR_DIV = 'FERT' THEN
                               V_LGORT_TO   := '3100';   --제품 입고전 창고
                           ELSIF V_MATNR_DIV = 'HALB' THEN
                               V_LGORT_TO   := '2000';   --반제품 창고            
                           ELSE
                               V_LGORT_TO   := '1200';   --자재공용 
                           END IF;
                       ELSE
                           V_LGORT_TO  := '2020';          -- 합격량이 부적합 량보다 적으면 그 차이를 불용창고로...
                       END IF;
                       
--                       IF  V_FNL_JDGM = 'PASS' THEN   -- 부적합을 적합으로 변경시키면...
                               -- 공정창고 재고를 위치를 이전 시킨다.(2010) 
                       V_DISPO_QTY := V_UCFMTY_AMT - V_MEDIAT_AMT;		-- 부적합량 - 조정량
                      
                       IF  NVL(V_MEDIAT_AMT,0) >= 0 THEN  -- 부적합 처리랄 양이 있다면...
                           IF V_WERKS = 'P100' OR V_WERKS = 'P200' THEN
                              IF V_MATNR_DIV = 'HALB' THEN
                                 IF V_UNIT <> 'EA' THEN
                                     BEGIN
                                        --20220917 여한진 합지와 점보롤은 부적합량을 불용창고로 옮기고, 부적합량 만큼 재고가 깎이고, 실적량도 깎음 
                                        IF V_LGORT_TO = '2020' THEN
                                            V_DOC_SEQNO := i + 1;
                                            --개별바코드 채번
                                            SP_GET_BARCODE_SEQ('IND', V_WERKS, V_MACH_CD, V_MATNR, V_MSRM_DT, V_BARCODE);
                                            
                                            INSERT INTO TB_INV001
                                                   (WERKS, STOR_LOC_CD, IND_BCD, MATNR, LOT_NO, MACH_CD, MACHINE, WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, IN_MR_YN,
                                                    PRFM_DT, PRD_DT, UNIT, STCK_QTY, ROLLCNT, WGT, STCK_STA, DLFL, APVR_STA, PRE_IND_BCD, REGDATE, REGID)
                                            SELECT WERKS, V_LGORT_TO, V_BARCODE, V_MATNR, V_LOT_NO, V_MACH_CD, MACHINE, WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, IN_MR_YN,
                                                   PRFM_DT, PRD_DT, V_UNIT, V_DISPO_QTY, ROLLCNT, V_DISPO_QTY, '30', 'N', '0', V_IND_BCD, SYSDATE, V_SESS_USER_ID  
                                              FROM TB_INV001
                                             WHERE WERKS        = V_WERKS
                                               AND STOR_LOC_CD  = V_STOR_LOC_CD
                                               AND MATNR        = V_MATNR
                                               AND IND_BCD      = V_IND_BCD;
                                            --재고이전 이력  
                                            INSERT INTO TB_WRK017(DOC_NO, DOC_SEQNO, MOVE_DIV, WERKS_FR, WERKS_TO, MATNR_FR, MATNR_TO, STOR_LOC_FR, STOR_LOC_TO, CHARG_FR, CHARG_TO, MOVE_QTY, UNIT,
                                                                AUFNR, WRK_ORDR_NO_FR, WRK_ORDR_SEQNO_FR, WRK_ORDR_NO_TO, WRK_ORDR_SEQNO_TO, UCFMTY_YN, RMK, REGDATE, REGID, IND_BCD, 
                                                                VBELN_FROM, POSNR_FROM, VBELN_TO, POSNR_TO)
                                                        VALUES(V_DOC_NO, V_DOC_SEQNO, '311', V_WERKS, V_WERKS, V_MATNR, V_MATNR, V_STOR_LOC_CD, V_LGORT_TO, V_LOT_NO, V_LOT_NO, V_DISPO_QTY, V_UNIT,
                                                                '', V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, 'Y', '', SYSDATE, V_SESS_USER_ID, V_BARCODE, 
                                                               V_VBELN, V_POSNR, V_VBELN, V_POSNR);
                                            --재고이전
                                            INSERT INTO TB_IFS009(BWART, WERKS_FROM, WERKS_TO, MATNR_FROM, MATNR_TO, LGORT_FROM, LGORT_TO, CHARG_FROM, CHARG_TO, AUFNR, MENGE, MEINS, FAULTY,
                                                                MDOCNO, MDOCSEQ, ZRESULT, MAKE_DATE, MAKER, LTCHG, VBELN_FROM, POSNR_FROM, VBELN_TO, POSNR_TO)
                                                        VALUES('311', V_WERKS, V_WERKS, V_MATNR, V_MATNR, V_STOR_LOC_CD, V_LGORT_TO, V_LOT_NO, V_LOT_NO, '', V_DISPO_QTY, V_UNIT, 'Y',
                                                                V_DOC_NO, V_DOC_SEQNO, 'N', SYSDATE, V_SESS_USER_ID, '', V_VBELN, V_POSNR , V_VBELN, V_POSNR);
                                            --인터페이스 문서 이력                    
                                            INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO, 
                                                                IND_BCD, LOT_NO, ORDER_NO, CNL_YN, REGDATE, REGID)
                                                        VALUES(V_DOC_NO, V_DOC_SEQNO, '6', V_WERKS, V_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, 
                                                                V_BARCODE, V_LOT_NO, V_ORDER_NO, 'N', SYSDATE, V_SESS_USER_ID);
                                                                
                                            UPDATE TB_INV001 I001
                                               SET 
                                           --        I001.STOR_LOC_CD        =  V_LGORT_TO
                                                   I001.STCK_STA           = '00'  -- 00:정상, 40: 부적합
                                                 , I001.STCK_QTY           =  I001.STCK_QTY - V_DISPO_QTY  -- 합격량이 있으면 마지막 입력된 조정량(합격)을 재고에서 뺀다.
                                                 , I001.WGT                =  I001.WGT - V_DISPO_QTY   -- 합격량이 있으면 마지막 입력된 조정량(합격)을 재고에서 뺀다.
                                                 , I001.UCFMTY_AMT         =  V_DISPO_QTY   -- 합격량이 있으면 마지막 입력된 조정량(합격)을 재고에 합한다.
                                                 --, I001.UCFMTY_FLG         =  'Y'
                                                 , I001.FNL_JDGM           =  V_FNL_JDGM  
                                                 , I001.INSPR_ID           =  V_SESS_USER_ID
                                                 , I001.UPDDATE            =  SYSDATE
                                                 , I001.UPDID              =  V_SESS_USER_ID                                 
                                              WHERE ( I001.WERKS              =  V_WERKS
                                               AND  I001.STOR_LOC_CD          =  V_STOR_LOC_CD  -- 부적합 창고에 있던 넘을 찾아서 이전 위치로 변경
                                               AND  I001.IND_BCD              =  V_IND_BCD
                                               AND  I001.MATNR                =  V_MATNR );
                                               
                                            UPDATE TB_WRK001 W001
                                               SET W001.WGT         = W001.WGT - V_DISPO_QTY
                                                 , W001.PRFM_QTY    = W001.PRFM_QTY - V_DISPO_QTY
                                                 , W001.UPDDATE     = SYSDATE
                                                 , W001.UPDID       = V_SESS_USER_ID 
                                             WHERE W001.WERKS       = V_WERKS
                                               AND W001.IND_BCD     = V_IND_BCD;  
                                        END IF;
                                           
--                                        EXCEPTION           
--                                        WHEN OTHERS THEN 
--                                              P_SUCCESS           := 'N';
--                                              E_SQL_ERR_CD        := -20000;
--                                              E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--                                              ROLLBACK;
--            
--                                              SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--                                              RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
--                                              RETURN;
                                     END;
                                 ELSE
                                     -- P100, P200, 반제품, 단위가 EA 이면
                                     BEGIN
                                        UPDATE TB_INV001 I001
                                           SET 
                                       --        I001.STOR_LOC_CD        =  V_LGORT_TO
                                       --      , I001.STCK_STA           = '00'  -- 00:정상, 40: 부적합
--                                               I001.STCK_QTY           =  FN_CHG_UNIT(V_MATNR, V_WERKS, V_UNIT, 'EA', I001.STCK_QTY + V_MEDIAT_AMT) -- 합격량이 있으면 마지막 입력된 조정량(합격)을 재고에 합한다.
--                                                 , I001.WGT                =  FN_CHG_UNIT(V_MATNR, V_WERKS, V_UNIT, 'KG', I001.STCK_QTY + V_MEDIAT_AMT)
--                                      --           , I001.BOX_QTY            =  FN_CHG_UNIT(V_MATNR, V_WERKS, V_UNIT, 'R', I001.STCK_QTY + V_MEDIAT_AMT)
                                               I001.UCFMTY_AMT         =  FN_CHG_UNIT(V_MATNR, V_WERKS, V_UNIT, 'EA', V_DISPO_QTY)
                   --                          , I001.UCFMTY_FLG         =  'Y'  
                                             , I001.FNL_JDGM           =  V_FNL_JDGM  
                                             , I001.INSPR_ID           =  V_SESS_USER_ID
                                             , I001.UPDDATE            =  SYSDATE
                                             , I001.UPDID              =  V_SESS_USER_ID                                 
                                         WHERE ( I001.WERKS               =  V_WERKS
                                           AND  I001.STOR_LOC_CD          =  V_STOR_LOC_CD  -- 부적합 창고에 있던 넘을 찾아서 이전 위치로 변경
                                           AND  I001.IND_BCD              =  V_IND_BCD
                                           AND  I001.MATNR                =  V_MATNR );
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
                                 
                              ELSE  -- P100, P200, 완제품이면
                                BEGIN
                                    UPDATE TB_INV001 I001
                                       SET 
                              --             I001.STOR_LOC_CD        =  V_LGORT_TO
                              --           , I001.STCK_STA           = '00'  -- 00:정상, 40: 부적합
--                                           I001.STCK_QTY           =  I001.STCK_QTY + V_MEDIAT_AMT -- 합격량이 있으면 마지막 입력된 조정량(합격)을 재고에 합한다.
--                                             , I001.PLT_QTY            =  FN_CHG_UNIT(V_MATNR, V_WERKS, V_UNIT, 'PAL', I001.STCK_QTY + V_MEDIAT_AMT)
--                                             , I001.BOX_QTY            =  FN_CHG_UNIT(V_MATNR, V_WERKS, V_UNIT, 'BOX', I001.STCK_QTY + V_MEDIAT_AMT)
--                                             , I001.BAG_QTY            =  FN_CHG_UNIT(V_MATNR, V_WERKS, V_UNIT, 'BAG', I001.STCK_QTY + V_MEDIAT_AMT)
--                                             , I001.EA_QTY             =  FN_CHG_UNIT(V_MATNR, V_WERKS, V_UNIT, 'EA', I001.STCK_QTY + V_MEDIAT_AMT)
--                                             , I001.WGT                =  FN_CHG_UNIT(V_MATNR, V_WERKS, V_UNIT, 'KG', I001.STCK_QTY + V_MEDIAT_AMT)
                                           I001.UCFMTY_AMT         =  V_DISPO_QTY   -- 부적합 - 조정량
                     --                    , I001.UCFMTY_FLG         =  'Y'  
                                         , I001.FNL_JDGM           =  V_FNL_JDGM  
                                         , I001.INSPR_ID           =  V_SESS_USER_ID
                                         , I001.UPDDATE            =  SYSDATE
                                         , I001.UPDID              =  V_SESS_USER_ID                                 
                                     WHERE ( I001.WERKS               =  V_WERKS
                                       AND  I001.STOR_LOC_CD          =  V_STOR_LOC_CD  -- 부적합 창고에 있던 넘을 찾아서 이전 위치로 변경
                                       AND  I001.IND_BCD              =  V_IND_BCD
                                       AND  I001.MATNR                =  V_MATNR );
                                    
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
                           
                           IF V_WERKS = 'P300' OR V_WERKS = 'P500' THEN
                               BEGIN   
                                    UPDATE TB_INV001 I001
                                       SET 
                                --           I001.STOR_LOC_CD        =  V_LGORT_TO
                                --         , I001.STCK_STA           = '00'  -- 00:정상, 40: 부적합
--                                           I001.STCK_QTY           =  I001.STCK_QTY + V_MEDIAT_AMT -- 합격량이 있으면 마지막 입력된 조정량(합격)을 재고에 합한다.
--                                             , I001.PLT_QTY            =  FN_CHG_UNIT(V_MATNR, V_WERKS, V_UNIT, 'PAL', I001.STCK_QTY + V_MEDIAT_AMT)
--                                             , I001.BOX_QTY            =  FN_CHG_UNIT(V_MATNR, V_WERKS, V_UNIT, 'BOX', I001.STCK_QTY + V_MEDIAT_AMT)
--                                             , I001.BAG_QTY            =  FN_CHG_UNIT(V_MATNR, V_WERKS, V_UNIT, 'BAG', I001.STCK_QTY + V_MEDIAT_AMT)
--                                             , I001.EA_QTY             =  FN_CHG_UNIT(V_MATNR, V_WERKS, V_UNIT, 'EA', I001.STCK_QTY + V_MEDIAT_AMT)
--                                             , I001.WGT                =  FN_CHG_UNIT(V_MATNR, V_WERKS, V_UNIT, 'KG', I001.STCK_QTY + V_MEDIAT_AMT)
                                           I001.UCFMTY_AMT         =  V_DISPO_QTY   --부적합 - 조정량
--                                         , I001.UCFMTY_FLG         =  'Y'  
                                         , I001.FNL_JDGM           =  V_FNL_JDGM  
                                         , I001.INSPR_ID           =  V_SESS_USER_ID
                                         , I001.UPDDATE            =  SYSDATE
                                         , I001.UPDID              =  V_SESS_USER_ID                                 
                                     WHERE ( I001.WERKS               =  V_WERKS
                                       AND  I001.STOR_LOC_CD          =  V_STOR_LOC_CD  -- 부적합 창고에 있던 넘을 찾아서 이전 위치로 변경
                                       AND  I001.IND_BCD              =  V_IND_BCD
                                       AND  I001.MATNR                =  V_MATNR );
                                    
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
 
                       BEGIN    
                          UPDATE TB_QLT024 Q024  
                             SET UCFMTY_AMT     =  V_DISPO_QTY   -- 부적합량 = 부적합량 - 합격량
                               , FNL_JDGM       =  V_FNL_JDGM
                               , RMK            =  RMK || ','|| V_RMK
--                             , STOR_LOC_CD    =  '2020'  -- 불용 창고로 이동
                               , UPDDATE        =  SYSDATE
                               , UPDID          =  V_SESS_USER_ID
                               -- 2022-09-28(수요일) 안상현, 품질팀 요청사항으로 인하여, 품질 재검사에 품질처리방법 추가
                               , PRC_QC_MTD		=  V_PRC_QC_MTD --품질처리방법
                         WHERE ( Q024.INSP_ITEM_GRP_CD   =  V_INSP_ITEM_GRP_CD
                           AND   Q024.MATNR              =  V_MATNR
                           AND   Q024.WERKS              =  V_WERKS
                           AND   Q024.MSRM_DATE          =  TO_DATE(V_MSRM_DT,'YYYY-MM-DD HH24:MI:SS')
                           AND   Q024.PRC_SEQNO          =  V_PRC_SEQNO ) ;
                        
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
--                 END IF;   
--
--                        -- 품질 재검사 판정결과는 SAP로 전송 처리한다.
--                        BEGIN
--                              MERGE
--                                  INTO  TB_IFS009 S009
--                                 USING  DUAL
--                                    ON  ( MDOCNO    = V_DOC_NO
--                                   AND    MDOCSEQ   = V_DOC_SEQNO )
--                        WHEN MATCHED THEN
--                               UPDATE
--                                   SET  ZRESULT      = NULL,
--                                        ZMESSAGE     = NULL,
--                                        ZRESULT_DATE = NULL, --SAP 전송이시
--                                        MAKE_DATE    = NULL, --등록일시
--                                        MAKER        = NULL  --등록자
--                        WHEN NOT MATCHED THEN                 
--                               INSERT (
--                                        MDOCNO,       --MES 문서번호
--                                        MDOCSEQ,      --MES 문서순번
--                                        BWART,        --이동유형,(재고이전:311, 등급변경:309, 재고실사: )
--                                        WERKS_FROM,   --플램트(T)
--                                        WERKS_TO,     -- 플랜트(T)
--                                        MATNR_FROM,   --자재번호(F)
--                                        MATNR_TO,     --자재번호(T)
--                                        LGORT_FROM,   --저장위치(F) -
--                                        LGORT_TO,     --저장위치(T) - 부적합 창고로 재고이전(2010)
--                                        CHARG_FROM,   --LOT NO
--                                        CHARG_TO,     --LOT NO
--                                        AUFNR,        --변경된비계획오더번호
--                                        MENGE,        --이동량
--                                        MEINS,        --이동단위
--                                        FAULTY,       --부적합 지시자
--                                        MBLNR,        --SAP 문서번호
--                                        MJAHR,        --SAP 문서번호(년도)
--                                        ZRESULT,      --결과값 Return( S:성공, E:오류 )
--                                        ZMESSAGE,     -- SAP 전송 결과 메시지
--                                        ZRESULT_DATE, --SAP 전송일시
--                                        MAKE_DATE,    --등록일시
--                                        MAKER         --등록자
--                               ) VALUES (
--                                        V_DOC_NO,       --MES 문서번호
--                                        V_DOC_SEQNO,    --MES 문서순번
--                                        '311',          --이동유형,(재고이전:311, 등급변경:309, 재고실사: )
--                                        V_WERKS,        --플램트(F)
--                                        V_WERKS,        --플랜트(T)
--                                        V_MATNR,        --자재번호(F)
--                                        V_MATNR,        --자재번호(T)
--                                        '2010',         --저장위치(F) 반제품 창고
--                                        V_LGORT_TO,     --저장위치(T) -- 3100, 2000번으로 이동
--                                        V_LOT_NO,       --LOT NO
--                                        V_LOT_NO,       --LOT NO
--                                        ' ',            --변경된 비계획 오더번호 
--                                        NVL(V_MEDIAT_AMT,0),      --이동량(조정된 합격량)
--                                        V_UNIT,         --이동단위
--                                        'Y',            --부적합 지시자('Y'고정)
--                                        ' ',            --SAP 문서번호
--                                        ' ',            --SAP 문서번호(년도)
--                                        'N',            --결과값 Return( S:성공, E:오류 )
--                                        ' ',            --SAP 전송 결과 메시지
--                                        NULL,           --SAP 전송일시
--                                        SYSDATE,        --등록일시
--                                        V_SESS_USER_ID  --등록자
--                               );
--                        EXCEPTION           
--                        WHEN OTHERS THEN 
--                               P_SUCCESS           := 'N';
--                               E_SQL_ERR_CD        := -20000;
--							   E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--                               ROLLBACK;
--            
--                               SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--                               RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
--                               RETURN;           
--                        END;
--            
--                        P_DOC_NO := V_DOC_NO;    
                
				ELSIF V_OBJ.get_string('GRowState') = 'D' THEN  -- 삭제가 있나?
                      RETURN;              

                END IF;

            END LOOP;
	
    IF V_DOC_SEQNO > 0 THEN
    	P_DOC_NO := V_DOC_NO;
    END IF;
           
    ELSIF P_TYPE = 'SUB_SAVE' THEN
          RETURN;

    END IF;

    P_SUCCESS := 'Y';

    COMMIT;

--    EXCEPTION
--    WHEN E_EXCEPTION_USER THEN
--
--        -- 에러 내역 SET
--	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := -20000;
--		E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--
--        ROLLBACK;
--
--    WHEN OTHERS THEN
--	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := -20000;
--		E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--
--        ROLLBACK;
--        RAISE; --_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END

;
/
