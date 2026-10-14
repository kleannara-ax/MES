--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK37_I01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK37_I01" 
(
     P_WERKS            IN VARCHAR2				    --플랜트  
    ,P_MACH_CD          IN VARCHAR2                 --설비코드 
    ,P_WRK_LIST         IN CLOB
    ,P_IND_BCD          IN VARCHAR2                 --등급변경전 개별바코드   
    ,P_MATNR            IN VARCHAR2                 --등급변경전 자재코드   
    ,P_LOT_NO           IN VARCHAR2                 --등급변경전 LOT NO
    ,P_WRK_ORDR_NO      IN VARCHAR2                 --등급변경전 작업지시번호
    ,P_WRK_ORDR_SEQNO   IN NUMBER                   --등급변경전 작업지시번호 순번
    ,P_WRK_CLASS        IN VARCHAR2                 --반
    ,P_WRK_SHIFT        IN VARCHAR2                 --작업조
    ,P_USERID           IN VARCHAR2                 --USER ID
    ,RS_GRD_RFCFN      OUT VARCHAR2                --등급변경 RFCFN값
    ,RS_DISPO_RFCFN     OUT VARCHAR2                --폐품 RFCFN값    
    ,RS_IND_BCD   		OUT VARCHAR2                --개별바코드 (개별 바코드 '|' 구분자 로 여러개 전달)
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
    ,CUR_1              OUT SYS_REFCURSOR              --등급변경
    ,CUR_2              OUT SYS_REFCURSOR              --등급변경
    ,CUR_3              OUT SYS_REFCURSOR              --폐품실적
    ,CUR_4              OUT SYS_REFCURSOR              --폐품실적
)
/*==============================================================================
 * PROGRAM ID    : WRK37{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 등급변경
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 등급변경
 *                 
 * AUTHOR NAME   : 유상호{최초 작성자 명 기술}
 * CREATE DATE   : 2022/08/21 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/08/21    1.0.0   유상호         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_WRK002] : (.RU.) 실적(PS) 
 *       - [TB_INV001] : (C.U.) 공정재고

 *=============================================================================*/

AS 
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK37_I01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_OBJ            JSON_OBJECT_T;

    --parameter변수 처리    
    V_SQL               VARCHAR2(4000);  
    V_DOC_NO_1_C        TB_WRK002.DOC_NO%TYPE;
    V_DOC_SEQNO_1_C     TB_WRK002.DOC_SEQNO%TYPE;
    V_DOC_NO_2_C        TB_WRK004.DOC_NO%TYPE;
    V_DOC_SEQNO_2_C     TB_WRK004.DOC_SEQNO%TYPE;
    
    V_DSTBT_DAYS        TB_MAS001.DSTBT_DDLIN%TYPE;
    V_BS_WGT_C          TB_MAS001.BS_WGT%TYPE;
    V_PACKTYPE_C        TB_WRK002.PACKTYPE%TYPE;
    V_VBELN             TB_WRK002.VBELN%TYPE;
    V_POSNR             TB_WRK002.POSNR%TYPE;
    
    V_CCNT              TB_IFS021.CCNT%TYPE;
    V_MATNR_C           TB_WRK010.MATNR%TYPE;
    V_PRFM_QTY_C        TB_WRK010.PCNT%TYPE;
    V_PRFM_DT_C         TB_WRK002.PRFM_DT%TYPE;
    V_PRD_DT_C          TB_WRK002.PRD_DT%TYPE;
    V_DSTBT_DDLIN       TB_WRK002.DSTBT_DDLIN%TYPE;
    V_WGT_C             TB_WRK010.WGT%TYPE;
    V_ZZATT1_C          TB_WRK010.ZZATT1%TYPE;      --속당매수
    V_SCNT_C            TB_WRK010.SCNT%TYPE;        --속수
    V_CHG_DT_C          TB_WRK010.CHG_DT%TYPE;      --등급변경일자
    V_CHG_DIV_C         TB_WRK010.CHG_DIV%TYPE;     --등급변경사유
    V_RMK_C             TB_WRK010.RMK%TYPE;         --비고
    V_PRD_DTM_C         VARCHAR2(20);
    V_LOT_NO_C          TB_WRK010.LOT_NO%TYPE;
    V_IND_BCD_C         TB_WRK010.IND_BCD%TYPE;
    V_UNIT_C            TB_MAS001.UNIT%TYPE;
    V_SAP_WRK_CD        TB_MAS012.SAP_WRK_CD%TYPE;
    V_WLEN_C            TB_WRK002.WLEN%TYPE;
    V_VLEN_C            TB_WRK002.VLEN%TYPE;
    V_WRK_SEQ_C         TB_WRK002.WRK_SEQ%TYPE;
    V_PRD_NO            TB_WRK002.PRD_NO%TYPE;
    
    V_STCK_QTY_CHG      TB_INV001.STCK_QTY%TYPE;
    V_STCK_WGT_CHG      TB_INV001.STCK_QTY%TYPE;
    V_STCK_PCNT_GHG     TB_INV001.STCK_QTY%TYPE;
    V_DISPO_QTY         TB_INV001.STCK_QTY%TYPE;
    V_DISPO_WGT         TB_INV001.WGT%TYPE;
    V_DATE              DATE := SYSDATE;


BEGIN
    BEGIN
        V_JSON := JSON_OBJECT_T.parse(P_WRK_LIST); -- 전체 데이터
        V_ARR_LIST := V_JSON.get_array('list');
        
        --V_LOOP_CNT := V_ARR_LIST.get_size -1 ;
        SELECT VBELN, POSNR
            INTO V_VBELN, V_POSNR
          FROM TB_WRK002
         WHERE WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND IND_BCD = P_IND_BCD;
        
        SELECT SAP_WRK_CD  INTO V_SAP_WRK_CD
          FROM TB_MAS012
         WHERE MACH_CD = P_MACH_CD; 
        
        -- 작업장코드 GRxx 로 변경, 
        V_SAP_WRK_CD := 'GR' || SUBSTR(V_SAP_WRK_CD || '03', 3, 2);
        
        --등급변경 문서번호
        V_DOC_NO_1_C := FN_GET_MDOCNO('M','IF142');
        V_DOC_SEQNO_1_C := 0;   
        V_STCK_QTY_CHG := 0;
        V_STCK_WGT_CHG := 0;
        V_STCK_PCNT_GHG := 0;

        --개별바코드        
        RS_IND_BCD   := '';    -- 개별 바코드 구분자 로 여러개 전달
        
        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ := TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ := TREAT (V_OBJ.get ('map') AS json_object_t);
            
            V_CCNT                := V_OBJ.get_string('CCNT');        --연수FROM
            V_MATNR_C             := V_OBJ.get_string('MATNR');           --등급변경할 자재코드
            V_PRFM_QTY_C          := V_OBJ.get_string('PRFM_QTY');        --연수
            V_WGT_C               := V_OBJ.get_string('WGT');             --중량
            V_ZZATT1_C            := V_OBJ.get_string('ZZATT1');          --속당매수
            V_SCNT_C              := V_OBJ.get_string('SCNT');            --속
            V_CHG_DT_C            := V_OBJ.get_string('CHG_DT');          --등급변경일자 'YYYYMMDD'
            V_CHG_DIV_C           := V_OBJ.get_string('CHG_DIV');         --등급변경사유((01: 규격변경, 02, 수입입고변경, 03: 잔량입고변경, 04:품질입고변경)
            V_DISPO_QTY           := V_OBJ.get_string('DISPO_QTY');       --파지연수
            V_DISPO_WGT           := V_OBJ.get_string('DISPO_WGT');       --파지중량
            V_RMK_C               := V_OBJ.get_string('RMK');             --비고
            
            SELECT UNIT, NVL(DSTBT_DDLIN, 0), BS_WGT
                INTO V_UNIT_C, V_DSTBT_DAYS, V_BS_WGT_C
              FROM TB_MAS001
             WHERE WERKS = P_WERKS
               AND MATNR = V_MATNR_C;
            
            --V_UNIT_C := 'EA';
            --V_PRFM_QTY_C := V_PRFM_QTY_C * 500;
            V_PRFM_DT_C := V_CHG_DT_C;
            V_PRD_DT_C := TO_CHAR(V_DATE, 'YYYYMMDD');
            V_PACKTYPE_C := SUBSTR(V_MATNR_C, -1);
            
            IF V_DSTBT_DAYS = 0 THEN
                V_DSTBT_DDLIN := NULL;
            ELSE
                V_DSTBT_DDLIN := TO_CHAR(TO_DATE(V_PRFM_DT_C,'YYYYMMDD') + V_DSTBT_DAYS,'YYYYMMDD');
            END IF;
            
            V_PRD_DTM_C := TO_CHAR(V_DATE, 'YYYY-MM-DD HH24:MI:SS');
            --F2A11220-08600590B
            V_WLEN_C := TO_NUMBER(SUBSTR(V_MATNR_C, 10, 4));
            V_VLEN_C := TO_NUMBER(SUBSTR(V_MATNR_C, 14, 4));
            
            BEGIN
            SELECT MAX(NVL(WRK_SEQ, 0)) INTO V_WRK_SEQ_C
              FROM TB_WRK002
             WHERE WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND PRFM_DT = V_PRFM_DT_C;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_WRK_SEQ_C := 0;
            END;
            V_WRK_SEQ_C := V_WRK_SEQ_C + 1;
            
            V_PRD_NO := TO_CHAR(TO_DATE(V_PRFM_DT_C, 'YYYYMMDD'), 'YYYY-MM-DD') || '-' || 'PM3' || '-' || TO_CHAR(V_WRK_SEQ_C);
            
            --개별바코드 생성
            SP_GET_BARCODE_SEQ('IND', P_WERKS, 'Q', V_MATNR_C, V_PRD_DTM_C, V_IND_BCD_C);
            RS_IND_BCD := RS_IND_BCD || V_IND_BCD_C || '|';    -- 개별 바코드 구분자 로 여러개 전달

            --LOT NO 생성
            SP_CHK_LOT_NO('', P_WERKS, P_MACH_CD, V_MATNR_C, V_PRD_DTM_C, V_LOT_NO_C);
            
            V_DOC_SEQNO_1_C := V_DOC_SEQNO_1_C + 1;
            
            --등급변경된 수량(연수기준)
            V_STCK_QTY_CHG := V_STCK_QTY_CHG + V_PRFM_QTY_C;
            V_STCK_WGT_CHG := V_STCK_WGT_CHG + V_WGT_C;
            V_STCK_PCNT_GHG := V_STCK_PCNT_GHG + V_PRFM_QTY_C;
            
            --실적등록
            INSERT INTO TB_WRK002(WERKS, MACH_CD, IND_BCD, LOT_NO, MATNR, PRD_NO,
                                UNIT, PRFM_QTY, PCNT, SCNT, MCNT, WGT, MER_YN, GRD_YN, 
                                PRD_STR_DATE, PRD_END_DATE, TM, PRFM_DT, PRD_DT, DSTBT_DDLIN,
                                WRK_CLASS, WRK_SHIFT, MACHINE, TO_MACHINE, STA,
                                DOC_NO, DOC_SEQNO, RMK, CNL_YN, REGDATE, REGID,
                                PACKTYPE, RUN_STA, WRK_SEQ, LOT_NO_BUF,
                                VLEN, WLEN, PRFM_GTHR_YN)
                        VALUES(P_WERKS, P_MACH_CD, V_IND_BCD_C, V_LOT_NO_C, V_MATNR_C, V_PRD_NO,
                                V_UNIT_C, V_PRFM_QTY_C, V_PRFM_QTY_C, V_SCNT_C, V_PRFM_QTY_C * 500, V_WGT_C, 'N', 'Y',
                                V_DATE, V_DATE, 0, V_PRFM_DT_C, V_PRD_DT_C, V_DSTBT_DDLIN,
                                P_WRK_CLASS, P_WRK_SHIFT, 'PM3', 'PM3', '00',
                                V_DOC_NO_1_C, V_DOC_SEQNO_1_C, V_RMK_C, 'N', V_DATE, P_USERID,
                                V_PACKTYPE_C, '01', V_WRK_SEQ_C, V_LOT_NO_C,
                                V_VLEN_C, V_WLEN_C, 'Y');

            --재고생성 및 차감
            INSERT INTO TB_INV001(WERKS, STOR_LOC_CD, IND_BCD, MATNR, LOC_CD, LOT_NO, MACH_CD, MACHINE, 
                                PRD_NO, IN_MR_YN, PRFM_DT, PRD_DT, UNIT, STCK_QTY, EA_QTY, WGT, STCK_STA,
                                DOC_NO, DOC_SEQNO, DLFL, REGDATE, REGID, RUN_STA, BS_WGT, CON_TYPE, PACK_TYPE)
                        VALUES(P_WERKS, '2600', V_IND_BCD_C, V_MATNR_C, 'L2800', V_LOT_NO_C, P_MACH_CD, 'PM3',
                                V_PRD_NO, 'N', V_PRFM_DT_C, V_PRD_DT_C, V_UNIT_C, V_PRFM_QTY_C, V_PRFM_QTY_C * 500, V_WGT_C, '00',
                                V_DOC_NO_1_C, V_DOC_SEQNO_1_C, 'N', V_DATE, P_USERID, '01', V_BS_WGT_C, '', V_PACKTYPE_C);
                                
            --등급변경 이력
            INSERT INTO TB_WRK010(WERKS, IND_BCD, WRK_TYPE, LOT_NO, MATNR, UNIT,
                                PCNT, ZZATT1, SCNT, WGT, CHG_DT, CHG_DIV,
                                IND_BCD_M, MATNR_M, LOT_NO_M, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                DOC_NO, DOC_SEQNO, RMK, REGDATE, REGID)
                        VALUES(P_WERKS, V_IND_BCD_C, '1', V_LOT_NO_C, V_MATNR_C, 'R',
                                V_PRFM_QTY_C, V_ZZATT1_C, V_SCNT_C, V_WGT_C, V_CHG_DT_C, V_CHG_DIV_C,
                                P_IND_BCD, P_MATNR, P_LOT_NO, P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO,
                                V_DOC_NO_1_C, V_DOC_SEQNO_1_C, V_RMK_C, V_DATE, P_USERID);
            --등급변경 IF
            INSERT INTO TB_IFS021(LOTNO_FROM, LOTNO_TO, BUDAT, 
                                CCNT, MATNR, CTCTN, PCNT, REMARK, 
                                MDOCNO, MDOCSEQ, ZRESULT, MAKE_DATE, MAKER)
                       VALUES(P_LOT_NO, V_LOT_NO_C, V_PRFM_DT_C,
                                V_CCNT, V_MATNR_C, V_PRFM_QTY_C, 0, V_RMK_C,
                                V_DOC_NO_1_C, TO_CHAR(V_DOC_SEQNO_1_C), 'N', V_DATE, P_USERID);

            --문서이력
            INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                                WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                IND_BCD, LOT_NO, ORDER_NO, CNL_YN, REGDATE, REGID)
                       VALUES(V_DOC_NO_1_C, V_DOC_SEQNO_1_C, 10, 
                                P_WERKS, P_MACH_CD, '', '',
                                V_IND_BCD_C, V_LOT_NO_C, '', 'N', V_DATE, P_USERID);
            
            --폐품등록(폐품코드 770)
            IF NVL(V_DISPO_QTY, 0) > 0 THEN
                V_STCK_QTY_CHG := V_STCK_QTY_CHG + NVL(V_DISPO_QTY, 0);
                V_STCK_WGT_CHG := V_STCK_WGT_CHG + V_DISPO_WGT;
                V_STCK_PCNT_GHG := V_STCK_PCNT_GHG + NVL(V_DISPO_QTY, 0);
                
                V_DOC_NO_2_C := FN_GET_MDOCNO('M','IF134');
                V_DOC_SEQNO_2_C := 1;   
        
                INSERT INTO TB_WRK004(WERKS, MACH_CD, IND_BCD, LOT_NO, MATNR,
                                    DISPO_CD, MMATNR, IND_BCD_M, LOT_NO_M, UNIT, DISPO_QTY, MACHINE, WGT,
                                    PRD_STR_DATE, PRD_END_DATE, TM, PRFM_DT, WRK_CLASS, WRK_SHIFT,
                                    RUN_STA, DOC_NO, DOC_SEQNO, REGDATE, REGID, GRD_YN)    
                           VALUES(P_WERKS, P_MACH_CD, V_IND_BCD_C, V_LOT_NO_C, V_MATNR_C,
                                    '770', P_MATNR, P_IND_BCD, P_LOT_NO, V_UNIT_C, NVL(V_DISPO_QTY, 0), 'PM3', V_DISPO_WGT,
                                    V_DATE, V_DATE, 0, V_PRFM_DT_C, P_WRK_CLASS, P_WRK_SHIFT,
                                    '02', V_DOC_NO_2_C, V_DOC_SEQNO_2_C, V_DATE, P_USERID, 'Y');
                --폐품 IF
                INSERT INTO TB_IFS012(AUFNR, LOTNO, BUDAT, MATNR, SCRQTY, SCRAPCODE, SCRAPREASON,
                                    LGORT, CHARG, RUNTIME,
                                    SDATE, STIME, EDATE, ETIME, 
                                    MDOCNO, MDOCSEQ, ZRESULT, MAKE_DATE, MAKER, 
                                    VBELN, POSNR, WORKCENTERCODE)
                           VALUES('', P_LOT_NO,  V_PRFM_DT_C, P_MATNR, NVL(V_DISPO_QTY, 0), '770' , '등급변경',
                                 '2600', P_LOT_NO, '0',
                                 TO_CHAR(TO_DATE(V_PRFM_DT_C, 'YYYY-MM-DD'),'YYYY-MM-DD'), TO_CHAR(V_DATE,'HH24:MI:SS'), 
                                 TO_CHAR(TO_DATE(V_PRFM_DT_C, 'YYYY-MM-DD'),'YYYY-MM-DD'), TO_CHAR(V_DATE,'HH24:MI:SS'),    
                                 V_DOC_NO_2_C, TO_CHAR(V_DOC_SEQNO_2_C), 'N', V_DATE, P_USERID,
                                 V_VBELN, TO_CHAR(V_POSNR), V_SAP_WRK_CD);
                
                --등급변경 이력
                INSERT INTO TB_WRK010(WERKS, IND_BCD, WRK_TYPE, LOT_NO, MATNR, UNIT,
                                PCNT, ZZATT1, SCNT, WGT, CHG_DT, CHG_DIV,
                                IND_BCD_M, MATNR_M, LOT_NO_M, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                DOC_NO, DOC_SEQNO, RMK, REGDATE, REGID)
                        VALUES(P_WERKS, V_IND_BCD_C, '2', V_LOT_NO_C, V_MATNR_C, 'R',
                                NVL(V_DISPO_QTY, 0), 0, 0,  NVL(V_DISPO_WGT, 0), V_CHG_DT_C, V_CHG_DIV_C,
                                P_IND_BCD, P_MATNR, P_LOT_NO, P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO,
                                V_DOC_NO_2_C, V_DOC_SEQNO_2_C, V_RMK_C, V_DATE, P_USERID);
                                
            END IF;
        END LOOP;
        
        --이전(등급변경할 자재)의 재고 및 실적수량 감소
--        UPDATE TB_INV001
--           SET STCK_QTY = V_STCK_QTY_CHG,
--               EA_QTY = V_STCK_QTY_CHG,
--               WGT = V_STCK_WGT_CHG,
--               STCK_STA = '25'
--         WHERE WERKS = P_WERKS
--           AND STOR_LOC_CD = '2600'
--           AND IND_BCD = P_IND_BCD;

        UPDATE TB_INV001
           SET STCK_QTY = STCK_QTY - V_STCK_QTY_CHG,
               EA_QTY = EA_QTY - (V_STCK_QTY_CHG * 500),
               WGT = WGT - V_STCK_WGT_CHG,
               STCK_STA = '25'
         WHERE WERKS = P_WERKS
           AND STOR_LOC_CD = '2600'
           AND IND_BCD = P_IND_BCD;

           
--        UPDATE TB_WRK002
--           SET PRFM_QTY = V_STCK_QTY_CHG,
--               PCNT = V_STCK_PCNT_GHG,
--               WGT = V_STCK_WGT_CHG,
--               PRFM_GTHR_YN = CASE WHEN V_STCK_QTY_CHG = 0 THEN 'N' ELSE 'Y' END
--         WHERE WERKS = P_WERKS
--           AND IND_BCD = P_IND_BCD; 
        UPDATE TB_WRK002
           SET PRFM_GTHR_YN = 'N'
         WHERE WERKS = P_WERKS
           AND IND_BCD = P_IND_BCD;         
    
    RS_IND_BCD := SUBSTR(RS_IND_BCD, 1, length(RS_IND_BCD)-1);
    
    IF LENGTH(V_DOC_SEQNO_1_C) > 0   THEN   --등급변경

         --SAP FUNC ID
         SELECT RFCFN
           INTO RS_GRD_RFCFN
           FROM TB_ITFMA
          WHERE 1=1
            AND IFID = 'MES_IF_142';   --등급변경

         --인터페이스 파라미터
         OPEN CUR_1 FOR
         SELECT 'MES_IF_142' AS I_IF_ID
              , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
           FROM dual;

         --인터페이스 상세 파라미터
         V_SQL := FN_IF_QUERY('MES_IF_142', V_DOC_NO_1_C);
         OPEN CUR_2 FOR V_SQL;

     END IF ;  
     IF LENGTH(V_DOC_SEQNO_2_C) > 0   THEN   --폐품

         --SAP FUNC ID
         SELECT RFCFN
           INTO RS_DISPO_RFCFN
           FROM TB_ITFMA
          WHERE 1=1
            AND IFID = 'MES_IF_134';   --등급변경

         --인터페이스 파라미터
         OPEN CUR_3 FOR
         SELECT 'MES_IF_134' AS I_IF_ID
              , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
           FROM dual;

         --인터페이스 상세 파라미터
         V_SQL := FN_IF_QUERY('MES_IF_134', V_DOC_NO_2_C);
         OPEN CUR_4 FOR V_SQL;

    END IF ; 
    
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
        
    RS_CODE := 'S';
    --COMMIT;

    --예외처리(catch)
    EXCEPTION
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
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END;

/
