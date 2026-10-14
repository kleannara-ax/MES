--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK30_I05_20
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK30_I05_20" 
(
     P_WERKS            IN VARCHAR2             --플랜트코드
    ,P_JSON_STR         IN CLOB
    ,P_USERID           IN VARCHAR2
    ,RS_PRFM_RFCFN      OUT VARCHAR2            --병합실적 RFCFN값
    ,RS_PRFM_RFCFN_CN   OUT VARCHAR2            --실적취소 RFCFN값
    ,RS_PRFM_RFCFN_ZR   OUT VARCHAR2            --제로실적 RFCFN값
    ,RS_MER_IND_BCD     OUT VARCHAR2    
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
    ,CUR_1              OUT SYS_REFCURSOR        --실적등록(병합)
    ,CUR_2              OUT SYS_REFCURSOR
    ,CUR_3              OUT SYS_REFCURSOR        --실적취소
    ,CUR_4              OUT SYS_REFCURSOR 
    ,CUR_5              OUT SYS_REFCURSOR        --Zero 실적등록(병합취소용)  
    ,CUR_6              OUT SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK30_I05
 * PROGRAM NAME  : 라벨 병합 처리
 * VERSION       : 1.0.0
 * DESCRIPTION   : 
 *                 
 * AUTHOR NAME   : 김병무
 * CREATE DATE   : 2022/05/04
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/04    1.0.0   김병무         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK009] : (C...) LOT 병합
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM          VARCHAR2(100)  := 'SP_POP_WRK30_I05';     -- PROCEDURE NAME
    V_PLT_CD          VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID    VARCHAR2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_OBJ            JSON_OBJECT_T;

    V_MACH_CD	        TB_WRK002.RMK%TYPE;          --작업장코드(설비코드)
    V_MER_MACH_CD	    TB_WRK002.RMK%TYPE;          --작업장코드(설비코드) 병합
    V_IND_BCD	        TB_WRK002.RMK%TYPE;          --개별바코드
    V_LOT_NO            TB_WRK002.LOT_NO%TYPE;       --LOT_NO
    V_MER_LOT_NO        TB_WRK002.LOT_NO%TYPE;       --LOT_NO 병합
    V_LOT_NO_B          TB_WRK002.LOT_NO%TYPE;       --이전LOT_NO  
    V_MER_IND_BCD       TB_WRK002.MER_IND_BCD%TYPE;  --병합개별바코드
    V_MER_IND_BCD_ORG   TB_WRK002.MER_IND_BCD%TYPE;  --병합개별바코드
    V_VBELN             TB_WRK002.VBELN%TYPE;        --문서번호
    V_POSNR             TB_WRK002.POSNR%TYPE;        --문서번호(품목)
    V_VBELN_B           TB_WRK002.VBELN%TYPE;        --문서번호
    V_POSNR_B           TB_WRK002.POSNR%TYPE;        --문서번호(품목)
    V_MATNR             TB_WRK002.MATNR%TYPE;        --자재코드
    V_WRK_SEQ           TB_WRK002.WRK_SEQ%TYPE;	     --생산순번
    V_PRD_NO            TB_WRK002.PRD_NO%TYPE;		 --생산번호
    V_PRFM_DT           TB_WRK002.PRFM_DT%TYPE;		 --생산실적일
    V_MACHINE           TB_WRK002.MACHINE%TYPE;		 --생산호기
    V_WRK_ORDR_NO       TB_WRK002.WRK_ORDR_NO%TYPE;	 --MES 작업지시NO
    V_WRK_ORDR_SEQNO    TB_WRK002.WRK_ORDR_SEQNO%TYPE; --MES 작업지시 SEQ.
    V_ORDER_NO          TB_WRK002.ORDER_NO%TYPE;     --SAP ORDER NO
    V_ORDER_NO_B        TB_WRK002.ORDER_NO%TYPE;     --SAP ORDER NO
    V_DOC_NO            TB_WRK002.DOC_NO%TYPE;		 --DOC No (POP 생성)
    V_DOC_SEQNO         TB_WRK002.DOC_SEQNO%TYPE;	 --DOC SEQ. (POP 생성)
    V_MER_DOC_NO        TB_WRK002.DOC_NO%TYPE;		 --DOC No (병합 실적 생성)
    V_MER_DOC_SEQNO     TB_WRK002.DOC_SEQNO%TYPE;	 --DOC SEQ. (병합 실적 생성)
    V_DOC_NO_CN         TB_WRK002.DOC_NO%TYPE;		 --DOC No (생산취소용)
    V_DOC_SEQNO_CN      TB_WRK002.DOC_SEQNO%TYPE;	 --DOC SEQ. (생산취소용)
    V_ZR_DOC_NO         TB_WRK002.DOC_NO%TYPE;		 --DOC No (Zero실적용)
    V_ZR_DOC_SEQNO      TB_WRK002.DOC_SEQNO%TYPE;    --DOC SEQ. (Zero실적용)
    V_SDOC_NO           TB_WRK002.SDOC_NO%TYPE;	     --SDOC NO (SAP 확정문서번호)
    V_SDOC_SEQNO        TB_WRK002.SDOC_SEQNO%TYPE;	 --SDOC SEQ. (SAP 확정문서 SEQ.)
    V_PRFM_QTY          TB_WRK002.PRFM_QTY%TYPE;     --생산실적(EA)
    V_PCNT              TB_WRK002.PCNT%TYPE;	     --생산실적(연수)
    V_WGT               TB_WRK002.WGT%TYPE;	         --생산실적(중량)
    V_SUM_PRFM_QTY      TB_WRK002.PRFM_QTY%TYPE := 0;--생산실적SUM(EA)
    V_SUM_PCNT          TB_WRK002.PCNT%TYPE := 0;	 --생산실적SUM(연수)
    V_SUM_WGT           TB_WRK002.WGT%TYPE  := 0;	 --생산실적SUM(중량)
    V_YMCHK             TB_MAS011.YMCHK%TYPE;        --실적등록 가능 여부
    V_SAP_WRK_CD        TB_MAS012.SAP_WRK_CD%TYPE;   --SAP용 설비코드

    --내부 변수 등록
    V_SUM_IND_BCD       VARCHAR2(500) := '';
    V_MER_IND_BCD_RMK   VARCHAR2(500); 
    V_PRD_END_DTM       VARCHAR2(16); 
    V_DATE              DATE := SYSDATE;
    V_DOC_NO_PRFM       VARCHAR2(500) := '';
    V_DOC_NO_PRFM_CN    VARCHAR2(500) := '';
    V_DOC_NO_ZERO       VARCHAR2(500) := '';
    V_USER_NM           VARCHAR2(20);               --작업자명
    V_COMP_YN           VARCHAR2(1);                --작업완료여부
    V_SQL               VARCHAR2(4000);

BEGIN
    BEGIN   --시작(try)
        V_DOC_NO_PRFM     := '';
        V_DOC_NO_PRFM_CN  := '';

        V_MER_DOC_SEQNO := 0;
        V_DOC_SEQNO_CN := 0 ;
        V_ZR_DOC_SEQNO := 0;
        
        V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);
        V_ARR_LIST := V_JSON.get_array('list');
        
        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ := TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ := TREAT (V_OBJ.get ('map') AS json_object_t);
            V_IND_BCD := V_OBJ.get_string('IND_BCD');

            -- 실적에서 필요정보 가져오기
            SELECT LOT_NO, MACH_CD, MATNR, TO_CHAR(PRD_END_DATE, 'YYYYMMDDHH24MISS'), MER_IND_BCD, VBELN, POSNR
                  , PRFM_DT , MACHINE, PRFM_QTY, PCNT, WGT , DOC_NO, DOC_SEQNO
                  , WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, SDOC_NO, SDOC_SEQNO
              INTO V_LOT_NO, V_MACH_CD, V_MATNR, V_PRD_END_DTM, V_MER_IND_BCD, V_VBELN, V_POSNR
                  , V_PRFM_DT , V_MACHINE, V_PRFM_QTY, V_PCNT, V_WGT, V_DOC_NO, V_DOC_SEQNO
                  , V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, V_SDOC_NO, V_SDOC_SEQNO
              FROM TB_WRK002
             WHERE WERKS   = P_WERKS
               AND IND_BCD = V_IND_BCD
               AND ROWNUM  = 1 ;

            -- 문서번호 및 품목 확인
            IF V_VBELN IS NOT NULL AND V_POSNR IS NOT NULL THEN
                IF V_VBELN_B <> V_VBELN OR V_POSNR_B <> V_POSNR THEN
                    RS_CODE := 'E';
                    RS_MSG := '문서번호 및 품목번호가 다릅니다. 확인하십시오.';
                    ROLLBACK;
                    RETURN;
                END IF;
            END IF;

            -- 기 병합여부 확인
            IF V_MER_IND_BCD IS NOT NULL  THEN
                RS_CODE := 'E';
                RS_MSG := V_IND_BCD || ' 는 이미 병합된 개별바코드입니다.';
                ROLLBACK;
                RETURN;
            END IF;

            --라벨병합 가능 월 검사                
            BEGIN
                SELECT YMCHK INTO  V_YMCHK
                  FROM TB_MAS011
                 WHERE WERKS = P_WERKS
                   AND YMCHK = 'Y'
                   AND YYMM  = SUBSTR(V_PRFM_DT, 1, 6);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_YMCHK := 'N';
            END;

            IF V_YMCHK = 'N' THEN
                RS_CODE := 'E';
                RS_MSG := '라벨병합 가능한 월이 아닙니다.';
                ROLLBACK;
                RETURN;
            END IF;

            --Order완료 여부 확인
            SELECT COMP_YN
              INTO V_COMP_YN
              FROM TB_SCH017
             WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;

            IF V_COMP_YN = 'Y' THEN
                V_COMP_YN := 'X';
            ELSE
                V_COMP_YN := '';
            END IF;

            -- 값 누적
            V_SUM_PRFM_QTY := V_SUM_PRFM_QTY + V_PRFM_QTY;
            V_SUM_PCNT := V_SUM_PCNT + V_PCNT;
            V_SUM_WGT := V_SUM_WGT + V_WGT;

            IF i = 0 THEN
                V_SUM_IND_BCD := V_IND_BCD;
            ELSE
                V_SUM_IND_BCD := V_SUM_IND_BCD || ',' || V_IND_BCD;
            END IF;

            -- 선택된 첫 바코드의 생산실적 정보로 생산실적 추가 (개별바코드 생성 후 처리)
            -- 병합바코드 생성(첫번째만 생성 한다.)
            IF i = 0 THEN
                V_MER_MACH_CD := V_MACH_CD;
                V_MER_LOT_NO := V_LOT_NO;

                -- 병합 개별바코드 생성
                SP_GET_BARCODE_SEQ('IND', P_WERKS, V_MER_MACH_CD, V_MATNR, V_PRD_END_DTM, V_MER_IND_BCD_ORG);

                --생산순번(MAX + 1) 구하기
                BEGIN
                    SELECT MAX(WRK_SEQ) INTO V_WRK_SEQ
                      FROM TB_WRK002
                     WHERE WERKS   = P_WERKS
                       AND MACH_CD = V_MER_MACH_CD
                       AND PRFM_DT = V_PRFM_DT;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_WRK_SEQ := 0;
                END;

                V_WRK_SEQ := NVL(V_WRK_SEQ, 0) + 1;

                --생산번호 구하기
                V_PRD_NO := TO_CHAR(TO_DATE(V_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD')
                            || '-' || V_MACHINE
                            || '-' || TO_CHAR(V_WRK_SEQ);

                --문서번호
                V_MER_DOC_NO := FN_GET_MDOCNO('M', 'IF127');
                V_MER_DOC_SEQNO := V_MER_DOC_SEQNO + 1;
                
                V_DOC_NO_PRFM := V_DOC_NO_PRFM || V_MER_DOC_NO || ',' ;
                
                -- 실적등록 ( 첫번째 때 실적을 등록하고 나중에 병합실적을 업데이트 한다.)
                INSERT INTO TB_WRK002 (
                        WERKS,   MACH_CD,  IND_BCD,  LOT_NO,  MATNR,  ORDER_NO,  WRK_ORDR_NO,  WRK_ORDR_SEQNO,  PRD_NO,  UNIT,
                        PRFM_QTY,  PCNT,  WGT,  MER_YN,  GRD_YN,  PRD_STR_DATE,  PRD_END_DATE,  TM,  PRFM_DT,  PRD_DT,
                        DSTBT_DDLIN,  WRK_CLASS,  WRK_SHIFT,  MACHINE,  TO_MACHINE,  STA,  RUN_STA,  DOC_NO,  DOC_SEQNO,  PACKTYPE,
                        RMK,  REGDATE,  REGID,  VBELN,  POSNR,  KUNNR,  WRK_SEQ,  PRFM_GTHR_YN,  VLEN,  WLEN,  MER_IND_BCD,  MER_RMK,  MAN_CUT_YN 
                       ) 
                SELECT WERKS,   MACH_CD,  V_MER_IND_BCD_ORG,  LOT_NO,  MATNR,  ORDER_NO,  WRK_ORDR_NO,  WRK_ORDR_SEQNO,  V_PRD_NO,  UNIT,
                       0,  0,  0,  'Y',  GRD_YN,  PRD_STR_DATE,  PRD_END_DATE,  TM,  PRFM_DT,  PRD_DT,
                       DSTBT_DDLIN,  WRK_CLASS,  WRK_SHIFT,  MACHINE,  TO_MACHINE,  STA,  RUN_STA,  V_MER_DOC_NO,  V_MER_DOC_SEQNO,  PACKTYPE,
                       RMK,  V_DATE,  P_USERID,  VBELN,  POSNR,  KUNNR,  V_WRK_SEQ,  PRFM_GTHR_YN,  VLEN,  WLEN,  '',  RMK,  MAN_CUT_YN
                  FROM TB_WRK002
                 WHERE WERKS   = P_WERKS
                   AND IND_BCD = V_IND_BCD
                   AND ROWNUM  = 1 ;

                --작업자명 구하기
                BEGIN
                    SELECT NMLAST INTO V_USER_NM
                      FROM USRMA
                     WHERE USERID = P_USERID;

                     V_USER_NM := SUBSTRB(V_USER_NM, 1, 10);
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_USER_NM := '';
                    WHEN OTHERS THEN
                        V_USER_NM := '';
                END;

                --실적 I/F (수량은 마지막에 업데이트)
                INSERT INTO TB_IFS005 (
                             AUFNR,  CRLOT,  WERKS,  WORKCENTERCODE,  BUDAT,  MACHINE,  WORKGROUP,  PRDQTY,  MEINS,  CRUNTIME,
                             COPNAM,  CUTTER,  CONFM,  CONFC,  CSDATE,  CSTIME,  CEDATE,  CETIME,  MDOCNO,  MDOCSEQ,  MAKE_DATE,
                             MAKER,  MRLOT
                           ) 
                    SELECT AUFNR,  CRLOT,  WERKS,  WORKCENTERCODE,  BUDAT,  MACHINE,  WORKGROUP,  0,  MEINS,  CRUNTIME,
                           V_USER_NM,  CUTTER,  V_COMP_YN,  V_COMP_YN,  CSDATE,  CSTIME,  CEDATE,  CETIME,  V_MER_DOC_NO,  V_MER_DOC_SEQNO,  V_DATE,
                           P_USERID,  MRLOT
                      FROM TB_IFS005
                     WHERE MDOCNO  = V_DOC_NO
                       AND MDOCSEQ = V_DOC_SEQNO;

                --재고등록 (수량은 마지막에 업데이트)
                INSERT INTO TB_INV001 (
                            WERKS,  STOR_LOC_CD,  IND_BCD,  MATNR,  LOC_CD,  LOT_NO,  MACH_CD,  MACHINE,  WRK_ORDR_NO,  WRK_ORDR_SEQNO,
                            ORDER_NO,  PRD_NO,  IN_MR_YN,  PRD_DT,  UNIT,  STCK_QTY,  WGT,  STCK_STA,  DOC_NO,  DOC_SEQNO,
                            DLFL,  REGDATE,  REGID
                          ) 
                  SELECT WERKS,  STOR_LOC_CD,  V_MER_IND_BCD_ORG,  MATNR,  LOC_CD,  LOT_NO,  MACH_CD,  MACHINE,  WRK_ORDR_NO,  WRK_ORDR_SEQNO,
                         ORDER_NO,  PRD_NO,  IN_MR_YN,  PRD_DT,  UNIT,  0,  0,  '00',  V_MER_DOC_NO,  V_MER_DOC_SEQNO,
                         'N',  V_DATE,  P_USERID
                    FROM TB_INV001
                   WHERE WERKS       = P_WERKS
                     AND STOR_LOC_CD = '2000'
                     AND IND_BCD     = V_IND_BCD;

                --문서이력
                INSERT INTO TB_WRK021 (
                            DOC_NO,  DOC_SEQNO,  DOC_DIV,  WERKS,  MACH_CD,  WRK_ORDR_NO,  WRK_ORDR_SEQNO,
                            IND_BCD,  LOT_NO,  ORDER_NO,  CNL_YN,  REGDATE,  REGID
                           ) 
                  VALUES (
                           V_MER_DOC_NO,  V_MER_DOC_SEQNO,  1,  P_WERKS,  V_MER_MACH_CD,  V_WRK_ORDR_NO,  V_WRK_ORDR_SEQNO,
                           V_MER_IND_BCD_ORG,  V_MER_LOT_NO,  V_ORDER_NO,  'N',  V_DATE,  P_USERID
                         );

            END IF;  -- i = 0 END IF

            -- FOR 마지막에 관련 정보 업데이트
            IF i = V_ARR_LIST.get_size-1 THEN
                -- 실적업데이트
                UPDATE TB_WRK002
                   SET PRFM_QTY = V_SUM_PRFM_QTY,
                       PCNT = V_SUM_PCNT,
                       WGT = V_SUM_WGT,
                       RMK = '라벨병합 ' || V_SUM_IND_BCD
                 WHERE WERKS   = P_WERKS
                   AND MACH_CD = V_MER_MACH_CD
                   AND IND_BCD = V_MER_IND_BCD_ORG;

                --실적 I/F 업데이트
                UPDATE TB_IFS005
                   SET PRDQTY = V_SUM_PCNT
                 WHERE MDOCNO  = V_MER_DOC_NO
                   AND MDOCSEQ = V_MER_DOC_SEQNO;

                --재고 업데이트
                UPDATE TB_INV001
                   SET STCK_QTY = V_SUM_PRFM_QTY,
                       WGT = V_SUM_WGT
                 WHERE WERKS       = P_WERKS
                   AND STOR_LOC_CD = '2000'
                   AND IND_BCD     = V_MER_IND_BCD_ORG;
         
            END IF;
            -------------------------------------------------------------------------
            -- 병합에 사용된 모든 개별 바코드 처리

            --LOT 추적
            INSERT INTO TB_WRK008(
                        WERKS,  IND_BCD,  IND_BCD_M,  SEQNO,  LOT_NO,
                        MATNR,  LOT_NO_M,  MATNR_M,  UNIT,  PRFM_QTY,
                        USE_QTY,  WRK_ORDR_NO,  WRK_ORDR_SEQNO,  SUB_WRK_ORDR_NO, SUB_WRK_ORDR_SEQNO,
                        MACH_CD,  RMK,  REGDATE,  REGID
                       )
                SELECT WERKS,  V_MER_IND_BCD_ORG,  IND_BCD,  1,  V_MER_LOT_NO,
                       MATNR,  LOT_NO,  MATNR,  UNIT,  WGT,
                       WGT,  WRK_ORDR_NO,  WRK_ORDR_SEQNO, WRK_ORDR_NO,  WRK_ORDR_SEQNO,
                       V_MER_MACH_CD,  '병합',  V_DATE,  P_USERID
                  FROM TB_WRK002
                 WHERE WERKS   = P_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND IND_BCD = V_IND_BCD;

            -------------------------------------------------------------------------
            -- 선택된 개발바코드 생산실적 취소

            -- MES 문서번호 생성
            V_DOC_NO_CN := FN_GET_MDOCNO('M','IF129');
            V_DOC_SEQNO_CN := V_DOC_SEQNO_CN + 1;

            V_DOC_NO_PRFM_CN := V_DOC_NO_PRFM_CN || V_DOC_NO_CN || ',';

            -- 생산실적 취소 flag
            UPDATE TB_WRK002
               SET MER_YN  = 'Y',
                   MER_IND_BCD = V_MER_IND_BCD_ORG,
                   CNL_YN  = 'Y',
                   CNL_RMK = '라벨병합',                               
                   UPDDATE = V_DATE,
                   UPDID   = P_USERID
             WHERE WERKS   = P_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD;

            -- 재고삭제 (삭제를 하지 않고 STOCK_QTY를 0 )
            UPDATE TB_INV001
               SET MER_STOCK_QTY = V_PRFM_QTY,
                   STCK_QTY  = 0,
                   STCK_STA  = '10',            --투입 
                   UPDDATE   = V_DATE,
                   UPDID     = P_USERID
             WHERE WERKS       = P_WERKS
               AND STOR_LOC_CD = '2000'
               AND IND_BCD     = V_IND_BCD;

            -- LOT 추적
--            DELETE FROM TB_WRK008     --LOT 추적
--             WHERE WERKS   = P_WERKS
--               AND IND_BCD = V_IND_BCD;

            -- 문서이력 (CNL_YN = 'Y')
            UPDATE TB_WRK021
               SET CNL_YN = 'Y'
             WHERE DOC_NO    = V_DOC_NO
               AND DOC_SEQNO = V_DOC_SEQNO;

            ---------------------------------------------------------------------
            -- SAP용 설비코드를 구한다.
            SELECT SAP_WRK_CD 
              INTO V_SAP_WRK_CD
              FROM TB_MAS012
             WHERE MACH_CD = V_MACH_CD;

            -- 생산취소 SAP IF 등록 
            INSERT INTO TB_IFS007 (
                               RUECK,  RMZHL,  MDOCNO,  MDOCSEQ,  MAKE_DATE,
                               MAKER,  WORKCENTERCODE,  AUFNR,  ROLLCNT,  MBLNR,  LOTNO
                            )                       
                     VALUES (
                              V_SDOC_NO,  V_SDOC_SEQNO , V_DOC_NO_CN, V_DOC_SEQNO_CN, V_DATE,
                              P_USERID,  V_SAP_WRK_CD,  V_ORDER_NO,  0,  V_SDOC_NO,  V_LOT_NO
                            );
            -------------------------------------------------------------------------  
            -- 취소된 생산실적 중 Order 완료인 바코드는 실적 0으로 완료 실적을 보낸다.
            IF i > 0 THEN
                IF V_ORDER_NO_B <> V_ORDER_NO THEN
                    IF V_COMP_YN = 'X' THEN
                    
                        V_ZR_DOC_NO := FN_GET_MDOCNO('M', 'IF127');
                        V_ZR_DOC_SEQNO := V_ZR_DOC_SEQNO + 1;
                        
                        V_DOC_NO_ZERO := V_DOC_NO_ZERO || V_ZR_DOC_NO || ',' ;
                        
                        -- 0인실적, PRFM_GTHR_YN = 'N'을 만들어 SAP 전송
                        INSERT INTO TB_WRK002 (
                                    WERKS,   MACH_CD,  IND_BCD,  LOT_NO,  MATNR,  ORDER_NO,  WRK_ORDR_NO,  WRK_ORDR_SEQNO,  
                                    PRFM_QTY,  PCNT,  WGT,  MER_YN,  GRD_YN,  PRD_STR_DATE,  PRD_END_DATE,  TM,  PRFM_DT,  PRD_DT,
                                    DSTBT_DDLIN,  RUN_STA,  DOC_NO,  DOC_SEQNO,  RMK,  REGDATE,  REGID,  PRFM_GTHR_YN   
                                   ) 
                            SELECT WERKS,   MACH_CD,  'Z00000000000000',  LOT_NO,  MATNR,  ORDER_NO,  WRK_ORDR_NO,  WRK_ORDR_SEQNO, 
                                   0,  0,  0,  'N',  GRD_YN,  PRD_STR_DATE,  PRD_END_DATE,  TM,  PRFM_DT,  PRD_DT,
                                   DSTBT_DDLIN,  RUN_STA,  V_ZR_DOC_NO,  V_ZR_DOC_SEQNO,  '라벨병합취소용 실적',  V_DATE,  P_USERID,  'N'
                              FROM TB_WRK002
                             WHERE WERKS   = P_WERKS
                               AND MACH_CD = V_MACH_CD
                               AND IND_BCD = V_IND_BCD ;
                               
                        INSERT INTO TB_IFS005 (
                                     AUFNR,  CRLOT,  WERKS,  WORKCENTERCODE,  BUDAT,  MACHINE,  WORKGROUP,  PRDQTY,  MEINS,  CRUNTIME,
                                     COPNAM,  CUTTER,  CONFM,  CONFC,  CSDATE,  CSTIME,  CEDATE,  CETIME,  MDOCNO,  MDOCSEQ,  MAKE_DATE,
                                     MAKER,  MRLOT
                                   ) 
                            SELECT AUFNR,  CRLOT,  WERKS,  WORKCENTERCODE,  BUDAT,  MACHINE,  WORKGROUP,  0,  MEINS,  CRUNTIME,
                                   V_USER_NM,  CUTTER,  V_COMP_YN,  V_COMP_YN,  CSDATE,  CSTIME,  CEDATE,  CETIME,  V_ZR_DOC_NO,  V_ZR_DOC_SEQNO,  V_DATE,
                                   P_USERID,  MRLOT
                              FROM TB_IFS005
                             WHERE MDOCNO  = V_DOC_NO
                               AND MDOCSEQ = V_DOC_SEQNO;
                    END IF;
                END IF;
            END IF;
        
            V_LOT_NO_B := V_LOT_NO ;
            V_VBELN_B := V_VBELN;
            V_POSNR_B := V_POSNR;
            V_ORDER_NO_B := V_ORDER_NO;

        END LOOP;
        
        V_DOC_NO_PRFM    := SUBSTR(V_DOC_NO_PRFM, 1, LENGTH(V_DOC_NO_PRFM)-1);
        V_DOC_NO_PRFM_CN := SUBSTR(V_DOC_NO_PRFM_CN, 1, LENGTH(V_DOC_NO_PRFM_CN)-1);
        V_DOC_NO_ZERO := SUBSTR(V_DOC_NO_ZERO, 1, LENGTH(V_DOC_NO_ZERO)-1);

        IF LENGTH(V_DOC_NO_PRFM) > 0   THEN   
                -- SAP 전송을 위한 값 RETUEN
                 --SAP FUNC ID
                 SELECT RFCFN
                   INTO RS_PRFM_RFCFN
                   FROM TB_ITFMA
                  WHERE IFID = 'MES_IF_127';   --병합라벨 실적 전송용 

                 --인터페이스 파라미터
                 OPEN CUR_1 FOR
                 SELECT 'MES_IF_127' AS I_IF_ID
                      , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                   FROM dual;

                 --인터페이스 상세 파라미터
                 V_SQL := FN_IF_QUERY('MES_IF_127', V_DOC_NO_PRFM);
                 OPEN CUR_2 FOR V_SQL;
        END IF ;

        IF LENGTH(V_DOC_NO_PRFM_CN) > 0   THEN   
                --SAP FUNC ID
                SELECT RFCFN
                  INTO RS_PRFM_RFCFN_CN
                  FROM TB_ITFMA
                 WHERE IFID = 'MES_IF_129';   --취소라벨 실적 전송용

                --인터페이스 파라미터
                OPEN CUR_3 FOR
                SELECT 'MES_IF_129' AS I_IF_ID
                     , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                  FROM dual;

                --인터페이스 상세 파라미터
                V_SQL := FN_IF_QUERY('MES_IF_129', V_DOC_NO_PRFM_CN);
                OPEN CUR_4 FOR V_SQL;
         END IF ;
         
         IF LENGTH(V_DOC_NO_ZERO) > 0   THEN   
                -- SAP 전송을 위한 값 RETUEN
                 --SAP FUNC ID
                 SELECT RFCFN
                   INTO RS_PRFM_RFCFN_ZR
                   FROM TB_ITFMA
                  WHERE IFID = 'MES_IF_127';   --취소된 바코드의 완료Flag 전송용 실적 

                 --인터페이스 파라미터
                 OPEN CUR_5 FOR
                 SELECT 'MES_IF_127' AS I_IF_ID
                      , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                   FROM dual;

                 --인터페이스 상세 파라미터
                 V_SQL := FN_IF_QUERY('MES_IF_127', V_DOC_NO_ZERO);
                 OPEN CUR_6 FOR V_SQL;
        END IF ;
         
        --작업 정상 종료 코드 등록
--        SELECT LISTAGG(IND_BCD, ' , ') WITHIN GROUP (ORDER BY IND_BCD)
--        INTO V_MER_IND_BCD_RMK
--        FROM (SELECT IND_BCD 
--                FROM TB_WRK002
--               WHERE WERKS       = P_WERKS 
--                 AND MER_IND_BCD = V_MER_IND_BCD_ORG
--             );
--
--        UPDATE TB_WRK002  SET
--                 RMK = '[병합] ' || V_MER_IND_BCD_RMK || ' ' || RMK
--         WHERE WERKS   = P_WERKS
--           AND MER_IND_BCD = V_MER_IND_BCD_ORG;

        IF CUR_1%ISOPEN = FALSE THEN
            OPEN CUR_1 FOR SELECT 1 FROM dual;
        END IF;
        IF CUR_2%ISOPEN = FALSE THEN
            OPEN CUR_2 FOR SELECT 1 FROM dual;
        END IF;
        IF CUR_3%ISOPEN = FALSE THEN
            OPEN CUR_3 FOR SELECT 1 FROM dual;
        END IF;
        IF CUR_4%ISOPEN = FALSE THEN
            OPEN CUR_4 FOR SELECT 1 FROM dual;
        END IF;
        IF CUR_5%ISOPEN = FALSE THEN
            OPEN CUR_5 FOR SELECT 1 FROM dual;
        END IF;
        IF CUR_6%ISOPEN = FALSE THEN
            OPEN CUR_6 FOR SELECT 1 FROM dual;
        END IF;
   
        RS_MER_IND_BCD := V_MER_IND_BCD_ORG;
        RS_CODE := 'S';

        --COMMIT;
    EXCEPTION  --예외처리(catch)
        WHEN E_EXCEPTION_USER THEN
            -- 에러 내역 SET
            E_SQL_ERR_CD        := SQLCODE;
            E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);
            ROLLBACK;

            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
            RS_CODE := 'E';
            RS_MSG  := SQLERRM;
            RETURN;
        WHEN OTHERS THEN
            E_SQL_ERR_CD        := -20001;
            E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
            ROLLBACK;

            --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
            RS_CODE := 'E';
            RS_MSG  := SQLERRM;
            RETURN;
    END;
END SP_POP_WRK30_I05_20;

/
