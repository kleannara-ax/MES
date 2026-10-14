
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK42_S01" (
	P_TYPE           IN    varchar2, -- LIST
	P_JSON_STR       IN    CLOB ,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : WRK42{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 바코드/LOT 이력 조회{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 바코드 및 LOTNO를 기준으로 실적 조회한다.{프로그램에 대한 상세한 내용 기술}
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
 *      - [TB_WRK002] : (.R..) PS 실적
 *      - [TB_WRK004] : (.R..) 폐품 실적
 *      - [TB_MAS012] : (.R..) 설비
 *      - [TB_MAS013] : (.R..) 공정
 *      - [TB_INV001] : (.R..) 공정재고
 *      - [TB_INV010] : (.R..) 자재투입이력
 *      - [TB_IFS003] : (.R..) 생산오더별 실적(점보롤)
 *      - [TB_IFS004] : (.R..) 생산오더별 실적(밀롤)
 *      - [TB_IFS005] : (.R..) 생산오더별 실적(재단)
 *      - [TB_IFS006] : (.R..) 생산오더별 실적(포장)
 *      - [TB_WRK001] : (.R..) HL 실적
 *      - [TB_IFS001] : (.R..) 생산오더별 실적(초지, 합지)
 *      - [TB_IFS002] : (.R..) 생산오더별 실적(가공, 패드)
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK42_S01';     -- PROCEDURE NAME

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
    V_WERKS         TB_WRK002.WERKS%TYPE;
    V_IND_BCD       TB_WRK002.IND_BCD%TYPE;
    V_LOT_NO        TB_WRK002.LOT_NO%TYPE;

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역
BEGIN

   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'N';
   V_RUN_SQL := 'Y';

   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=       V_JSON.get_string('SES_PLNTKY');

   /* 조건값 할당 */
   V_RANGE_SQL          :=       V_JSON.get_string('RANGE_SQL');
   V_WERKS              :=       V_JSON.get_string('WERKS');    --플랜트
   V_IND_BCD            :=       V_JSON.get_string('IND_BCD');  -- 바코드
   V_LOT_NO             :=       V_JSON.get_string('LOT_NO');   -- LOT_NO

   IF P_TYPE = 'LIST1' THEN /*PS 조회 리스트*/

        V_SQL := ' SELECT W002.WERKS,
                          W002.IND_BCD                     BARCOD,         --BARCODE
                          W002.LOT_NO                      LOT_NO,         --LOT_NO
                          M013.PROC_NM || '' 공정 실적''    RCDTXT,         --이력 내역
                          W002.IND_BCD                     PRFM_BCD,       --실적바코드
                          W002.PRD_END_DATE                WRK_DATE,       --작업일시
                          (SELECT NMLAST FROM USRMA WHERE USERID = W002.REGID) WRKNM,   --작업자
                          W002.WRK_CLASS                   WRK_CLASS,      --반
                          I001.STOR_LOC_CD                 STOR_LOC_CD,    --저장위치
                          M012.MACH_NM                     MACH_NM,        --설비명
                          (SELECT DISTINCT
                                  M012.MACH_NM
                             FROM TB_WRK002 W002,
                                  TB_INV010 I010,  --자재투입이력
                                  TB_MAS012 M012
                            WHERE W002.IND_BCD = I010.IND_BCD_M
                              AND I010.MACH_CD = M012.MACH_CD(+)
                              --AND W002.IND_BCD LIKE ''%' || V_IND_BCD || '%''
							 ';
                             
					IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
						V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'IND_BCD', 'W002.IND_BCD');	--개별바코드
                        V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'LOT_NO', 'W002.LOT_NO');	--개별바코드
			           	V_SQL := V_SQL || V_RANGE_SQL;
			        END IF;
       
                  V_SQL := V_SQL || ')  INP_MACH_NM, --투입설비명
                          DECODE(W002.UNIT, ''KG'', W002.ROLLCNT, 0)                 PRFM_ROLLCNT,       --실적권치수
                          ''M''                        AS ROLLUNIT,          --궈치수단위 추가 
                          DECODE(W002.UNIT, ''EA'', W002.PRFM_QTY /500, ''R'', W002.PRFM_QTY, 0) PRFM_PCNT,          --실적연수
                          ''R''                        AS RUNIT,             --연수단위 추가 
                          DECODE(W002.UNIT, ''EA'', W002.PRFM_QTY, ''R'', W002.PRFM_QTY * 500, 0) PRFM_MCNT,          --실적매수
                          ''EA''                       AS EAUNIT,             --매수단위 추가 
                          W002.WGT                     PRFM_WGT,           --실적중량
                          ''KG''                       AS WUNIT,             --중량단위 추가 
                          W004.ROLLCNT                 PRFM_DISPO_ROLLCNT, --실적폐품M
                          ''M''                        AS DISPO_ROLLUNIT,          --폐품궈치수단위 추가 
                          W004.DISPO_QTY               PRFM_DISPO_PCNT,    --실적폐품연수
                          ''R''                        AS DISPO_RUNIT,             --폐품연수단위 추가 
                          W004.WGT                     PRFM_DISPO_WGT,     --실적폐품Kg
                          ''KG''                       AS DISPO_WUNIT,             --폐품중량단위 추가 
                          W002.TM                      TM,                 --생산시간(분)
                          FN_CD_VAL(''STCK_STA'', W002.STA) BCD_STA,       --바코드상태
                          W002.SDOC_NO                 ERP_SDOC_NO,        --ERP확정번호
                          W002.SDOC_SEQNO              ERP_SDOC_SEQNO,     --ERP 확정 SEQ
                          DECODE(W002.PRFM_DT, NULL, ''N'', '' '', ''N'', ''Y'')    END_YN,     --자기완료
                          DECODE(W002.SDOC_NO, NULL, ''N'', '' '', ''N'', ''Y'')    UP_END_YN,  --상위완료
                          DECODE(W002.ORDER_NO, I006.AUFNR, I006.ZMESSAGE
                                              , I005.AUFNR, I005.ZMESSAGE
                                              , I004.AUFNR, I004.ZMESSAGE
                                              , I003.AUFNR, I003.ZMESSAGE) ERP_PRD_ERR_MSG     --ERP PP(생산) 에러 메세지
                     FROM TB_WRK002 W002,  --PS실적
                          TB_MAS012 M012,  --설비
                          TB_MAS013 M013,  --공정
                          TB_INV001 I001,  --공정재고
                          TB_WRK004 W004,  --폐품실적
                          TB_IFS003 I003,  --생산오더별 실적(점보롤)
                          TB_IFS004 I004,  --생산오더별 실적(밀롤)
                          TB_IFS005 I005,  --생산오더별 실적(재단)
                          TB_IFS006 I006   --생산오더별 실적(포장)
                    WHERE W002.MACH_CD = M012.MACH_CD(+)
                      AND M012.PROC_CD = M013.PROC_CD(+)
                      AND W002.IND_BCD = I001.IND_BCD(+)
                      AND W002.MACH_CD = W004.MACH_CD(+)
                      AND W002.IND_BCD = W004.IND_BCD(+)
                      AND W002.ORDER_NO = I003.AUFNR(+)
                      AND W002.DOC_NO = I003.MDOCNO(+)
                      AND W002.ORDER_NO = I004.AUFNR(+)
                      AND W002.DOC_NO = I004.MDOCNO(+)
                      AND W002.ORDER_NO = I005.AUFNR(+)
                      AND W002.DOC_NO = I005.MDOCNO(+)
                      AND W002.ORDER_NO = I006.AUFNR(+)
                      AND W002.DOC_NO = I006.MDOCNO(+) 
                      AND NVL(W002.CNL_YN, ''N'') = ''N''' ;

        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
           V_SQL := V_SQL || V_RANGE_SQL;
        END IF;

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND W002.WERKS = ''' || V_WERKS || ''' ';        
        END IF;

        /*IF  V_IND_BCD IS NOT NULL OR TRIM(V_IND_BCD) != '' THEN
            V_SQL := V_SQL || ' AND W002.IND_BCD LIKE ''%' || V_IND_BCD || '%''';        
        END IF;

        IF  V_LOT_NO IS NOT NULL OR TRIM(V_LOT_NO) != '' THEN
            V_SQL := V_SQL || ' AND W002.LOT_NO LIKE ''%' || V_LOT_NO || '%''';        
        END IF;*/

		V_SQL := V_SQL || ' ORDER BY W002.PRFM_DT ';
        
--         V_DEBUG := 'Y';
--         IF (V_DEBUG = 'Y') THEN
--            INSERT INTO PROC_LOG (SQL_STR) VALUES (V_SQL);
--            COMMIT;
--        END IF;
        
        INSERT INTO PROC_LOG (SQL_STR, SQL_PARAM1) VALUES (V_SQL, 'wjbaek231227');

        OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'LIST2' THEN --HL 실적

        V_SQL := 'SELECT  W001.WERKS,
                          W001.IND_BCD                     BARCOD,         --BARCODE
                          W001.LOT_NO                      LOT_NO,         --LOT_NO
                          M013.PROC_NM || '' 공정 실적''    RCDTXT,         --이력 내역
                          W001.IND_BCD                     PRFM_BCD,       --실적바코드
                          W001.PRD_END_DATE                WRK_DATE,       --작업일시
                          (SELECT NMLAST FROM USRMA WHERE USERID = W001.REGID) WRKNM,   --작업자
                          W001.WRK_CLASS                   WRK_CLASS,      --반
                          I001.STOR_LOC_CD                 STOR_LOC_CD,    --저장위치
                          M012.MACH_NM                     MACH_NM,        --설비명
                          W001.ROLLCNT                 PRFM_ROLLCNT,       --실적권치수
                          ''M''                         AS ROLLUNIT,         --권치수단위 추가
                          W001.WGT                     PRFM_WGT,           --실적중량
                          ''KG''                         AS WUNIT,         --중량단위 추가
                          W001.PLT_QTY,     --PLT수량
                          W001.BOX_QTY,     --BOX수량
                          W001.BAG_QTY,     --BAG수량
                          W001.EA_QTY,      --EA수량
                          W001.TM                      TM,                 --생산시간(분)
                          FN_CD_VAL(''STCK_STA'', W001.STA) BCD_STA,       --바코드상태
                          W001.SDOC_NO                 ERP_SDOC_NO,        --ERP확정번호
                          W001.SDOC_SEQNO              ERP_SDOC_SEQNO,     --ERP 확정 SEQ
                          DECODE(W001.PRFM_DT, NULL, ''N'', '' '', ''N'', ''Y'')    END_YN,     --자기완료
                          DECODE(W001.SDOC_NO, NULL, ''N'', '' '', ''N'', ''Y'')    UP_END_YN,  --상위완료
                          DECODE(W001.ORDER_NO, IF002.AUFNR, IF002.ZMESSAGE
                                              , IF001.AUFNR, IF001.ZMESSAGE) ERP_PRD_ERR_MSG     --ERP PP(생산) 에러 메세지
                     FROM TB_WRK001 W001,  --HL실적
                          TB_MAS012 M012,  --설비
                          TB_MAS013 M013,  --공정
                          TB_INV001 I001,  --공정재고
                          TB_IFS001 IF001,  --생산오더별 실적(초지, 합지)
                          TB_IFS002 IF002   --생산오더별 실적(화장기가공, 패드)
                    WHERE W001.MACH_CD = M012.MACH_CD(+)
                      AND M012.PROC_CD = M013.PROC_CD(+)
                      AND W001.IND_BCD = I001.IND_BCD(+)
                      AND W001.ORDER_NO = IF001.AUFNR(+)
                      AND W001.DOC_NO = IF001.MDOCNO(+)
                      AND W001.ORDER_NO = IF002.AUFNR(+)
                      AND W001.DOC_NO = IF002.MDOCNO(+) 
                      AND NVL(W001.CNL_YN, ''N'') = ''N''' ;

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND W001.WERKS = ''' || V_WERKS || ''' ';        
        END IF;
        
        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
           V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'IND_BCD', 'W001.IND_BCD');
           V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'LOT_NO', 'W001.LOT_NO');
           V_SQL := V_SQL || V_RANGE_SQL;
        END IF;

--        IF  V_IND_BCD IS NOT NULL OR TRIM(V_IND_BCD) != '' THEN
--            V_SQL := V_SQL || ' AND W001.IND_BCD LIKE ''%' || V_IND_BCD || '%''';        
--        END IF;
--
--        IF  V_LOT_NO IS NOT NULL OR TRIM(V_LOT_NO) != '' THEN
--            V_SQL := V_SQL || ' AND W001.LOT_NO LIKE ''%' || V_LOT_NO || '%''';        
--        END IF;

		V_SQL := V_SQL || ' ORDER BY W001.PRFM_DT ';

--        V_DEBUG := 'Y';
--         IF (V_DEBUG = 'Y') THEN
--            INSERT INTO PROC_LOG (SQL_STR) VALUES (V_SQL);
--            COMMIT;
--        END IF;
        
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
