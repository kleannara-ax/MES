--------------------------------------------------------
--  DDL for Procedure SP_PDA_WRK11_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_PDA_WRK11_S01" 
(
    P_TYPE           IN     varchar2, -- LIST, SAVE(실적등록), SAVE1(실적취소)
	P_JSON_STR       IN     CLOB,
    P_CNL_RMK        IN     VARCHAR2,
	P_SUCCESS       OUT     varchar2,
    P_ERR_MSG       OUT     VARCHAR2,
    P_DOC_NO1       OUT     VARCHAR2,           --포장실적 SAP 전송 문서
    P_DOC_NO2       OUT     VARCHAR2,           --투입자재 전송문서
    P_DOC_NO3       OUT     VARCHAR2,           --WMS 완제품 입고요청 전송 문서
    P_RS_LIST       OUT     SYS_REFCURSOR
)
AS 
/*==============================================================================
 * PROGRAM ID    : SP_PDA_WRK11_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : PS 포장 실적(WMS 완제품입고요청){호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : PS 포장실적 등록 및 WMS로 완제품 입고요청
 *                 
 * AUTHOR NAME   : 유상호 {최초 작성자 명 기술}
 * CREATE DATE   : 2022/06/22 {최초 작성일자 기술}
 * SYSTEM NAME   : PDA
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/06/22    1.0.0   유상호         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_INV008] : (.R..) 재고실사 작업지시정보                                
 *       - [TB_MAS003] : (.R..) 저장위치 마스터                            
   *=============================================================================*/
    --프로그램 ID
    V_PRG_NM          VARCHAR2(100)  := 'SP_PDA_WRK11_S01';     -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_OBJECT_T;
    V_OBJ            JSON_OBJECT_T;
    V_OBJ2           JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS            TB_WRK002.WERKS%TYPE;            --플랜트코드
    V_IND_BCD	       TB_WRK002.IND_BCD%TYPE;          --개별바코드
    V_PROC_CD          TB_MAS012.PROC_CD%TYPE;          --공정코드 
    V_MACH_CD          TB_WRK002.MACH_CD%TYPE;          --설비코드
    V_STOR_LOC_CD      TB_INV001.STOR_LOC_CD%TYPE;    --저장위치

    V_MATNR	           TB_INV001.MATNR%TYPE;            --품목코드	
------------------------------------------------------------------
    V_WRK_ORDR_NO       TB_WRK002.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO    TB_WRK002.WRK_ORDR_SEQNO%TYPE;
    V_PRFM_DT           TB_WRK002.PRFM_DT%TYPE;
    V_PRD_DT            TB_WRK002.PRD_DT%TYPE;
    V_MACHINE           TB_WRK002.MACHINE%TYPE;
    V_WRK_CLASS         TB_WRK002.WRK_CLASS%TYPE;
    V_PRFM_QTY          TB_WRK002.PRFM_QTY%TYPE;
    V_UNIT              TB_WRK002.UNIT%TYPE;
    V_PRD_STR_DATE      TB_WRK002.PRD_STR_DATE%TYPE;
    V_PRD_END_DATE      TB_WRK002.PRD_END_DATE%TYPE;
    V_REGID             TB_WRK002.REGID%TYPE;
    V_LOT_NO	        TB_WRK002.LOT_NO%TYPE;           --LOT번호
    V_ORDER_NO	        TB_WRK002.ORDER_NO%TYPE;         --LOT번호
    V_WRK_TM            TB_WRK002.TM%TYPE;
    V_DOC_NO_1            TB_WRK002.DOC_NO%TYPE;
    V_DOC_SEQNO_1         TB_WRK002.DOC_SEQNO%TYPE;
    V_DOC_NO_2            TB_WRK002.DOC_NO%TYPE;
    V_DOC_SEQNO_2         TB_WRK002.DOC_SEQNO%TYPE;
    V_DOC_NO_3            TB_WRK002.DOC_NO%TYPE;
    V_DOC_SEQNO_3         TB_WRK002.DOC_SEQNO%TYPE;
    V_SAP_WRK_CD        TB_MAS012.SAP_WRK_CD%TYPE;
    V_USER_NM           VARCHAR2(20); 
    V_USER_NM_EN        VARCHAR2(20);
    V_SDATE             VARCHAR2(8);
    V_EDATE             VARCHAR2(8);
    V_STIME             VARCHAR2(6);
    V_ETIME             VARCHAR2(6);
    V_LOT_NO_C1         TB_WRK002.LOT_NO%TYPE;
    V_LOT_NO_C2         TB_WRK002.LOT_NO%TYPE;
    V_LOT_NO_C3         TB_WRK002.LOT_NO%TYPE;
    V_LOT_NO_C4         TB_WRK002.LOT_NO%TYPE;
    V_LOT_NO_C5         TB_WRK002.LOT_NO%TYPE;
    V_DATE              DATE :=SYSDATE;
    V_MDOCNO            TB_IFS009.MDOCNO%TYPE;           --MES 문서번호
    PROD_CUR            SYS_REFCURSOR;		-- 커서 정의
    V_SEQ               NUMBER;
    --V_LOT_NO_M          VARCHAR2(10);           --재단 LOT NO

    V_SEQNO_M            	TB_INV003.SEQNO%TYPE;
    V_WRK_ORDR_NO_M      	TB_INV003.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO_M   	TB_INV003.WRK_ORDR_SEQNO%TYPE;
    V_IND_BCD_M          	TB_INV003.IND_BCD%TYPE;
    V_LOT_NO_M           	TB_INV003.LOT_NO%TYPE;
    V_MATNR_M            	TB_INV003.MATNR%TYPE;
    V_INP_DT_M           	TB_INV003.INP_DT%TYPE;
    V_USE_QTY_M          	TB_INV003.USE_QTY%TYPE;
    V_UNIT_M             	TB_INV003.UNIT%TYPE;
    V_ROLLCNT_M          	TB_INV003.ROLLCNT%TYPE;
    V_WGT_M              	TB_INV003.WGT%TYPE;    
    V_CHG_FLG_M          	TB_INV003.CHG_FLG%TYPE;    
    V_STCK_KY_M          	TB_INV003.STCK_KY%TYPE;
    V_LOT_NUM_M          	TB_INV003.LOT_NUM%TYPE;

    V_VBELN             TB_WRK002.VBELN%TYPE; 
    V_POSNR             TB_WRK002.POSNR%TYPE; 
    V_KUNNR             TB_WRK002.KUNNR%TYPE; 
    V_PACK_TYPE         TB_WRK002.PACKTYPE%TYPE; 
    V_VLEN              TB_WRK002.VLEN%TYPE; 
    V_WLEN              TB_WRK002.WLEN%TYPE; 
    V_DSTBT_DDLIN       TB_WRK002.DSTBT_DDLIN%TYPE; 
    V_CORE              TB_WRK002.CORE%TYPE; 
    V_POSNR_N           VARCHAR2(10);
    V_STOCK_NO          VARCHAR2(20);
    V_NTN_CD            VARCHAR2(20);
    V_RCVGDS_DT         VARCHAR2(10);
    V_SAUART            TB_SCH018.OAUART_DIV%TYPE;
    V_ORDER_SEQNO       TB_WRK002.ORDER_SEQNO%TYPE;
    V_PCODE             TB_SCH018.PCODE%TYPE;
    V_BS_WGT            TB_SCH018.BS_WGT%TYPE;
    V_OAUART_DIV        TB_SCH018.OAUART_DIV%TYPE;     
    V_CON_TYPE          TB_SCH018.CON_TYPE%TYPE;     
    V_STCK_STA          TB_INV001.STCK_STA%TYPE;
    V_STA               TB_INV001.STCK_STA%TYPE;
    V_WGT               TB_INV001.WGT%TYPE;
    V_DOC_NO_C          TB_WRK021.DOC_NO%TYPE;
    V_DOC_SEQNO_C       TB_WRK021.DOC_SEQNO%TYPE;
    V_DOC_DIV_C         TB_WRK021.DOC_DIV%TYPE;
    V_IND_BCD_C         TB_WRK021.IND_BCD%TYPE;
    V_ORDER_NO_C        TB_WRK002.ORDER_NO%TYPE;
    V_SDOC_NO_C         TB_WRK021.SDOC_NO%TYPE;
    V_SDOC_SEQNO_C      TB_WRK021.SDOC_SEQNO%TYPE;

    V_SDOC_NO           TB_INV001.SDOC_NO%TYPE;
    V_SDOC_SEQNO           TB_INV001.SDOC_SEQNO%TYPE;
    V_WDOC_NO           TB_INV001.WDOC_NO%TYPE;
    V_WDOC_SEQNO           TB_INV001.WDOC_SEQNO%TYPE;
    V_INSERT            VARCHAR2(1);
    V_LINE              TB_MAS012.LINE%TYPE;
    V_DLFL              VARCHAR2(1);
    V_VGBEL             TB_WRK015.VGBEL%TYPE;
    V_ROLLCNT           TB_WRK002.ROLLCNT%TYPE;
    BEGIN
    OPEN P_RS_LIST FOR 
    SELECT NULL FROM DUAL WHERE ROWNUM = 0;    

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);
    V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=       V_JSON.get_string('SES_WAREKY');

    /* 조건값 할당 */
    V_RANGE_SQL          :=       V_JSON.get_string('RANGE_SQL');                   -- 

    V_WERKS              :=       V_JSON.get_string('WERKS');                   -- 플랜트코드
    V_MACH_CD            :=       V_JSON.get_string('MACH_CD');                 -- 설비코드
    V_PROC_CD            :=       V_JSON.get_string('PROC_CD');                 -- 공정코드
    V_IND_BCD            :=       V_JSON.get_string('IND_BCD');                 -- 개별바코드  

    IF P_TYPE = 'LIST' THEN 

        V_SQL := ' SELECT  CASE WHEN I001.LOC_CD = ''L2300'' THEN ''ROLL 원지제품'' ELSE ''SHEET 판지 제품'' END PROD_TYPE,  --제품타입
                        W002.IND_BCD,               --포장바코드
                        W002.LOT_NO,                --포장 LOT NO
                        M001.PCODE_NM,              --지종명
                        M001.BS_WGT,                --평량
                        SUBSTR(W002.MATNR, 10, 4) || '' * '' || SUBSTR(W002.MATNR, 14, 4)  MATNR_SPEC,                         --규격
                        CASE WHEN W002.PACKTYPE = ''A'' THEN TO_CHAR(NVL(W002.SCNT, 0)) || ''/'' || TO_CHAR(NVL(W002.MCNT, 0))
                            WHEN W002.PACKTYPE = ''B'' THEN TO_CHAR(NVL(W002.MCNT, 0)) END SMCNT,                 --속/매
                        TO_CHAR(I001.STCK_QTY, ''FM999,999,990'') AS PRFM_QTY,      --권치수/연수
                        TO_CHAR(W002.WGT, ''FM999,999,990'')   AS WGT,                --중량
                        FN_CD_VAL(''PACK_TYPE'', W002.PACKTYPE)  AS PACKTYPE,  --포장타입
                        M009.CUST_NM   AS KUNNR,
                        --W002.KUNNR,              --거래처코드
                        FN_CD_VAL(''STCK_STA'', I001.STCK_STA)          STCK_STA,  --포장실적 상태
                        W002.MACH_CD
                  FROM TB_INV001 I001,
                       TB_WRK002 W002,
                       TB_MAS009 M009,
                       TB_MAS001 M001
                 WHERE I001.WERKS = W002.WERKS
                   AND I001.IND_BCD = W002.IND_BCD 
                   AND I001.WERKS = M001.WERKS(+)
                   AND I001.MATNR = M001.MATNR(+)
                   AND W002.KUNNR = M009.CUST_CD(+)';

        V_SQL := V_SQL || ' AND I001.WERKS = ''' || V_WERKS || '''';  
        V_SQL := V_SQL || ' AND I001.IND_BCD = ''' || V_IND_BCD || '''';            --개별바코드 
        V_SQL := V_SQL || ' AND I001.STCK_QTY > 0
                            AND M009.CUST_DIV = ''C''';            

        INSERT INTO PROC_LOG(CTIME, SQL_PARAM1)
            VALUES(V_DATE, V_SQL);
        BEGIN           
     		OPEN P_RS_LIST FOR V_SQL;

        EXCEPTION           
        WHEN OTHERS THEN 
            P_SUCCESS           := 'N';
            E_SQL_ERR_CD        := SQLCODE;
            E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
            RETURN;           
        END;  
    ELSIF P_TYPE = 'SAVE' THEN      --실적등록 + WMS입고요청
        BEGIN
            
            SELECT W002.MACH_CD, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO, W002.ORDER_NO, W002.ORDER_SEQNO, W002.LOT_NO, W002.MATNR,
                    W002.CORE, W002.PRFM_DT, W002.PRD_DT, W002.MACHINE, W002.DSTBT_DDLIN,
                    W002.WRK_CLASS, I001.STCK_QTY, I001.UNIT, I001.ROLLCNT, W002.PRD_STR_DATE, W002.REGID,
                    W002.VBELN, W002.POSNR, W002.KUNNR, W002.PACKTYPE, W002.VLEN, W002.WLEN,
                    I001.UNIT, I001.WGT, I001.STCK_STA, I001.SDOC_NO, I001.SDOC_SEQNO, I001.WDOC_NO, I001.WDOC_SEQNO
                INTO V_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, V_ORDER_SEQNO, V_LOT_NO, V_MATNR,
                    V_CORE, V_PRFM_DT, V_PRD_DT, V_MACHINE, V_DSTBT_DDLIN,
                    V_WRK_CLASS, V_PRFM_QTY, V_UNIT, V_ROLLCNT, V_PRD_STR_DATE, V_REGID,
                    V_VBELN, V_POSNR, V_KUNNR, V_PACK_TYPE, V_VLEN, V_WLEN,
                    V_UNIT, V_WGT, V_STCK_STA, V_SDOC_NO, V_SDOC_SEQNO, V_WDOC_NO, V_WDOC_SEQNO
              FROM TB_INV001 I001,
                   TB_WRK002 W002
             WHERE I001.WERKS = W002.WERKS(+)
               AND I001.IND_BCD = W002.IND_BCD(+)
               AND I001.WERKS = V_WERKS
               AND I001.IND_BCD = V_IND_BCD
               AND I001.STOR_LOC_CD = '2000';
            
            IF NVL(V_SDOC_NO, ' ') <> ' ' AND NVL(V_SDOC_NO, ' ') <> 'E' AND NVL(V_WDOC_NO, ' ') <> ' ' AND NVL(V_WDOC_NO, ' ') <> 'E' THEN
                P_SUCCESS := 'N';
                P_ERR_MSG := V_MATNR || ' 는 이미 실적 등록된 제품입니다.';
                ROLLBACK;                
                RETURN;
            END IF;
            
            IF V_STCK_STA = '80' THEN
                P_SUCCESS := 'N';
                P_ERR_MSG := V_MATNR || ' 는 이미 물류창고로 입고 요청한 제품입니다.';
                ROLLBACK;                
                RETURN;
            END IF;

            V_DOC_SEQNO_1 := 0;
            V_DOC_SEQNO_2 := 0;
            V_DOC_SEQNO_3 := 0;

            SELECT SAP_WRK_CD, LINE, PROC_CD INTO V_SAP_WRK_CD, V_LINE, V_PROC_CD
              FROM TB_MAS012
             WHERE MACH_CD = V_MACH_CD;

            --투입이력조회
            V_SEQ := 0;
            V_LOT_NO_C1 := '';
            V_LOT_NO_C2 := '';
            V_LOT_NO_C3 := '';
            V_LOT_NO_C4 := '';
            V_LOT_NO_C5 := '';

            OPEN PROD_CUR FOR
                --투입된 재단 LOT NO 조회
                SELECT I010.SEQNO, I010.LOT_NO_M, MATNR_M, INP_DT, USE_QTY, DOC_NO, DOC_SEQNO, SDOC_NO, SDOC_SEQNO
                    INTO V_SEQNO_M, V_LOT_NO_M, V_MATNR_M, V_INP_DT_M, V_USE_QTY_M, V_DOC_NO_C, V_DOC_SEQNO_C, V_SDOC_NO_C, V_SDOC_SEQNO_C 
                  FROM TB_INV010 I010,
                       TB_MAS001 M001
                 WHERE I010.WERKS = M001.WERKS
                   AND I010.MATNR_M = M001.MATNR
                   AND I010.WERKS = V_WERKS
                   AND I010.MACH_CD = V_MACH_CD
                   AND I010.IND_BCD = V_IND_BCD
                   AND NVL(I010.CNL_YN, 'N') = 'N'
                   AND M001.MATNR_DIV IN ('FERT', 'HALB')
                 ORDER BY I010.SEQNO;   

            LOOP
            FETCH PROD_CUR INTO V_SEQNO_M, V_LOT_NO_M, V_MATNR_M, V_INP_DT_M, V_USE_QTY_M, V_DOC_NO_C, V_DOC_SEQNO_C, V_SDOC_NO_C, V_SDOC_SEQNO_C;  
            EXIT WHEN PROD_CUR %NOTFOUND;
                V_SEQ := V_SEQ + 1;

                IF V_SEQ = 1 THEN
                    V_LOT_NO_C1 :=  V_LOT_NO_M;
                ELSIF V_SEQ = 2 THEN
                    V_LOT_NO_C2 :=  V_LOT_NO_M;
                ELSIF V_SEQ = 3 THEN
                    V_LOT_NO_C3 :=  V_LOT_NO_M;
                ELSIF V_SEQ = 4 THEN
                    V_LOT_NO_C4 :=  V_LOT_NO_M;
                ELSIF V_SEQ = 5 THEN
                    V_LOT_NO_C5 :=  V_LOT_NO_M;
                END IF;


--                IF NVL(V_DOC_NO_2, ' ') = ' ' THEN
--                    V_DOC_NO_2 := FN_GET_MDOCNO('M','IF130');
--                END IF;        
--                V_DOC_SEQNO_2 := V_DOC_SEQNO_2 + 1;
--                V_INSERT := 'N';
--
--                IF V_INSERT = 'Y' THEN
--                    UPDATE TB_INV010
--                       SET DOC_NO = V_DOC_NO_2,
--                           DOC_SEQNO = V_DOC_SEQNO_2
--                     WHERE WERKS = V_WERKS
--                       AND MACH_CD = V_MACH_CD
--                       AND MATNR = V_MATNR
--                       AND IND_BCD = V_IND_BCD
--                       AND SEQNO = V_SEQNO_M;
--                    --자재투입 I/F
--                    INSERT INTO TB_IFS008(AUFNR, POSNR, BUDAT, MATNR, MENGE, LGORT, CHARG,
--                                        MDOCNO, MDOCSEQ, ZRESULT, MAKE_DATE, MAKER, WORKCENTERCODE, WERKS)
--                              VALUES(V_ORDER_NO, '', V_INP_DT_M, V_MATNR_M, V_USE_QTY_M, '2000', V_LOT_NO_M,
--                                   V_DOC_NO_2, TO_CHAR(V_DOC_SEQNO_2), 'N', V_DATE, V_SESS_USER_ID, V_SAP_WRK_CD, V_WERKS); 
--
--                    --문서이력
--                    INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
--                                        IND_BCD, LOT_NO, ORDER_NO, CNL_YN, REGDATE, REGID)
--                                VALUES(V_DOC_NO_2, V_DOC_SEQNO_2, 5, V_WERKS, V_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
--                                        V_IND_BCD, V_LOT_NO, V_ORDER_NO, 'N', V_DATE, V_SESS_USER_ID);                      
--                ELSE
--                    UPDATE TB_IFS008
--                       SET ZRESULT = 'N',
--                           MBLNR = '',
--                           MJAHR = ''
--                     WHERE MDOCNO = V_DOC_NO_2
--                       AND MDOCSEQ = TO_CHAR(V_DOC_SEQNO_C);
--                END IF;

            END LOOP;
            CLOSE PROD_CUR;

            V_PRD_END_DATE := V_DATE;

            V_SDATE := TO_CHAR(V_PRD_STR_DATE, 'YYYYMMDD');
            V_STIME := TO_CHAR(V_PRD_STR_DATE, 'HH24MISS');   
            V_EDATE := TO_CHAR(V_DATE, 'YYYYMMDD');
            V_ETIME := TO_CHAR(V_DATE, 'HH24MISS');

            V_WRK_TM := ROUND((V_PRD_END_DATE - V_PRD_STR_DATE) *24 * 60);

            V_DOC_NO_1 := FN_GET_MDOCNO('M','IF128');
            V_DOC_SEQNO_1 := V_DOC_SEQNO_1 + 1;
            --포장실적
            IF V_PROC_CD = 'MA' OR V_PROC_CD = 'SA' THEN     --원지포장
                V_PRFM_DT := FN_RECDATE(V_DATE);
                
                INSERT INTO TB_IFS004(AUFNR, MRLOT, WERKS, WORKCENTERCODE, BUDAT, MACHINE, WORKGROUP, MROLLCNT,
                                    RBRGEW, CORESIZE, REWINDER, MRUNTIME,
                                    CONFM, CONFJ, MSDATE, MSTIME, MEDATE, METIME, 
                                    MDOCNO, MDOCSEQ, ZRESULT, MAKE_DATE, MAKER)
                             VALUES(V_ORDER_NO, V_LOT_NO, V_WERKS, V_SAP_WRK_CD, V_PRFM_DT, V_MACHINE, V_WRK_CLASS, V_ROLLCNT,
                                    V_WGT, V_CORE, TO_CHAR(V_LINE), V_WRK_TM,
                                    '', '', V_SDATE, V_STIME, V_EDATE, V_ETIME,
                                    V_DOC_NO_1, V_DOC_SEQNO_1, 'N', V_DATE, V_SESS_USER_ID);
                                    
            ELSE
                INSERT INTO TB_IFS006( AUFNR,              --오더번호
                                        PKLOT,              --포장 LOT NO
                                        WERKS,              --플랜트
                                        WORKCENTERCODE,     --SAP 작업장코드
                                        BUDAT,              --생산일자
                                        MACHINE,            --생산호기
                                        WORKGROUP,          --반
                                        PCNT,               --포장실적
                                        MEINS,              --생산단위
                                        PRUNTIME,           --가동시간
                                        POPNAM,             --작업자
                                        PACKLOC,            --포장설비
                                        CONF,               --마지막생산여부
                                        PSDATE,             --작업시작일자
                                        PSTIME,             --작업시작일시
                                        PEDATE,             --작업종료일자
                                        PETIME,             --작업종료일시    
                                        MDOCNO,             --MES 문서번호
                                        MDOCSEQ,            --MES 문서번호순번
                                        MAKE_DATE,          --등록일시        
                                        MAKER,              --등록자
                                        CUTLOT,             --재단LOT NO1
                                        CUTLOT2,            --재단LOT NO2
                                        CUTLOT3,            --재단LOT NO3
                                        CUTLOT4,            --재단LOT NO4
                                        CUTLOT5             --재단LOT NO5
                                    )
                           VALUES( V_ORDER_NO,
                                   V_LOT_NO,
                                   V_WERKS,
                                   V_SAP_WRK_CD,
                                   V_PRFM_DT,
                                   V_MACHINE,
                                   V_WRK_CLASS,
                                   V_PRFM_QTY,
                                   V_UNIT,
                                   V_WRK_TM,
                                   SUBSTRB(V_USER_NM, 1, 12),      --V_USER_NM                  --작업자
                                   TO_CHAR(V_LINE),
                                   '',
                                   V_SDATE,
                                   V_STIME,
                                   V_EDATE,
                                   V_ETIME,
                                   V_DOC_NO_1,
                                   V_DOC_SEQNO_1,
                                   V_DATE,
                                   V_SESS_USER_ID,
                                   V_LOT_NO_C1,
                                   V_LOT_NO_C2,
                                   V_LOT_NO_C3,
                                   V_LOT_NO_C4,
                                   V_LOT_NO_C5);
            END IF;
            --SAP I/F 문서번호 업데이트
            UPDATE TB_WRK002
               SET DOC_NO = V_DOC_NO_1,
                   DOC_SEQNO = V_DOC_SEQNO_1
             WHERE WERKS = V_WERKS
               AND IND_BCD = V_IND_BCD;

            --문서이력
            INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                IND_BCD, LOT_NO, ORDER_NO, CNL_YN, REGDATE, REGID)
                        VALUES(V_DOC_NO_1, V_DOC_SEQNO_1, 1, V_WERKS, V_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                V_IND_BCD, V_LOT_NO, V_ORDER_NO, 'N', V_DATE, V_SESS_USER_ID);                                    


            --WMS 완제품 입고요청
            V_DOC_NO_3 := FN_GET_MDOCNO('M','IF402');
            V_DOC_SEQNO_3 := V_DOC_SEQNO_3 + 1;

            SELECT NMLAST, EMAIL1 
                INTO V_USER_NM, V_USER_NM_EN 
              FROM USRMA
             WHERE USERID = V_REGID;

           BEGIN 
           SELECT LAND1 INTO V_NTN_CD
             FROM TB_MAS009
            WHERE CUST_CD = V_KUNNR
              AND CUST_DIV = 'C';
           EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_NTN_CD := '';
           END;

            --자재코드 5번째 자리 2 = 수출, 그외 = 내수
            V_USER_NM_EN := SUBSTR(V_USER_NM_EN, 1, INSTR(V_USER_NM_EN , '@') -1 ) ;

            IF SUBSTR(V_MATNR, 5, 1) = '2' THEN
                V_USER_NM := V_USER_NM_EN;
            END IF;

            V_POSNR_N := SUBSTR('000000' || TO_CHAR(V_POSNR), -6);
            V_STOCK_NO := V_VBELN || V_POSNR_N;
            V_RCVGDS_DT := TO_CHAR(V_DATE, 'YYYYMMDD');

            SELECT PCODE, BS_WGT, OAUART_DIV, CON_TYPE 
                INTO V_PCODE, V_BS_WGT, V_OAUART_DIV, V_CON_TYPE
              FROM(
                    SELECT PCODE, BS_WGT, OAUART_DIV, CON_TYPE 
                      FROM TB_SCH018
                     WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                    UNION ALL
                    SELECT PCODE, BS_WGT, OAUART_DIV, 0 AS CON_TYPE 
                      FROM TB_SCH016
                     WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                    );

            INSERT INTO TB_WRK015( DOC_NO, DOC_SEQNO, DLFL,			
                                    WERKS, MATNR, QTY, UNIT, STOR_LOC_FR, STOR_LOC_TO,
                                    WGT, IND_BCD, LOT_NO, MACHINE, ORDER_NO, ORDER_SEQNO,				
                                    WRK_ORDR_NO, WRK_ORDR_SEQNO, PCODE, BS_WGT, WLEN, VLEN,
                                    CON_TYPE, PACKTYPE, VBELN, POSNR, SAUART, KUNNR, CORE,
                                    EMPLY_NO, EMPLY_NM, NTN_CD,
                                    PRD_DT, RCVGDS_DT, PRFM_DT, DSTBT_DDLIN,
                                    REQ_STA, REGDATE, REGID) 
                           VALUES(V_DOC_NO_3, V_DOC_SEQNO_3, 'C',
                                    V_WERKS, V_MATNR, V_PRFM_DT, V_UNIT, '3100', '3000',
                                    NVL(V_WGT, 0), V_IND_BCD, V_LOT_NO, V_MACHINE, V_ORDER_NO, '000000',	
                                    V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_PCODE, V_BS_WGT, V_WLEN, V_VLEN,
                                    V_CON_TYPE, V_PACK_TYPE, V_VBELN, V_POSNR_N, V_SAUART, V_KUNNR, V_CORE,
                                    V_REGID, V_USER_NM, V_NTN_CD,
                                    V_PRD_DT, V_PRFM_DT, V_PRFM_DT, V_DSTBT_DDLIN,
                                    'R', V_DATE, V_SESS_USER_ID);

            --I/F테이블에 등록
            INSERT INTO TB_IFSWM005( DOC_NO, DOC_SEQNO, DLFL,
                                    WERKS, MATNR, QTY, UNIT, STOR_LOC_FROM, STOR_LOC_TO,
                                    IND_BCD, LOT_NO, MACHINE, ORDER_NO, ORDER_SEQNO,
                                    PCODE,          --지종
                                    WEIGHT,          --평량
                                    WLEN,
                                    VLEN,
                                    CON_TYPE,
                                    PACK_TYPE,
                                    OVBELN,         --판매문서번호
                                    OPOSNR,         --판매문서 항목번호
                                    SAUART,         --판매문서유형
                                    KUNNR,          --판매처
                                    CORE,           --지관
                                    EMPLY_NO,
                                    EMPLY_NM,
                                    NTN_CD,         --국가코드
                                    PRDC_DT,        --제조일자 
                                    RCVGDS_DT,      --입고일자
                                    DSTBT_DDLIN,    --유통기간
                                    STCK_NO,       --특별재고번호(판매문서번호 + 판매문서 항목번호)
                                    IF_GET_DATE,
                                    REQ_DT          
                                    )
                       VALUES( V_DOC_NO_3, V_DOC_SEQNO_3, 'C',
                                V_WERKS, V_MATNR, V_PRFM_QTY, V_UNIT, '3100', '3000',
                                V_IND_BCD, V_LOT_NO, V_MACHINE, V_ORDER_NO, TO_CHAR(V_ORDER_SEQNO),
                                V_PCODE,
                                V_BS_WGT,
                                V_WLEN,
                                V_VLEN,
                                V_CON_TYPE,
                                V_PACK_TYPE,
                                V_VBELN,         --판매문서번호
                                V_POSNR_N,         --판매문서 항목번호
                                V_SAUART,         --판매문서유형
                                V_KUNNR,          --판매처
                                V_CORE,           --지관
                                V_REGID,
                                V_USER_NM,
                                V_NTN_CD,         --국가코드
                                V_PRFM_DT,        --제조일자 
                                V_RCVGDS_DT,      --입고일자
                                V_DSTBT_DDLIN,    --유통기간
                                V_STOCK_NO,       --특별재고번호(판매문서번호 + 판매문서 항목번호)
                                V_DATE,
                                V_RCVGDS_DT
                                );

        UPDATE TB_INV001
           SET STOR_LOC_CD = '3100',
               STCK_STA = '80',
               DOC_NO = V_DOC_NO_1,
               DOC_SEQNO = V_DOC_SEQNO_1,
               UPDDATE = V_DATE,
               UPDID = V_SESS_USER_ID
         WHERE WERKS = V_WERKS
           AND STOR_LOC_CD = '2000'
           AND IND_BCD = V_IND_BCD;

        IF V_DOC_SEQNO_1 > 0 THEN
            P_DOC_NO1 := V_DOC_NO_1;
        END IF;

        IF V_DOC_SEQNO_2 > 0 THEN
            P_DOC_NO2 := V_DOC_NO_2;
        END IF;

        IF V_DOC_SEQNO_3 > 0 THEN
            P_DOC_NO3 := V_DOC_NO_3;
        END IF;

--        EXCEPTION           
--        WHEN OTHERS THEN 
--            P_SUCCESS           := 'N';
--            E_SQL_ERR_CD        := SQLCODE;
--            E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--            ROLLBACK;
--            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
--            RETURN;           
        END;  
     ELSIF P_TYPE = 'SAVE1' THEN        --실적취소
        V_WERKS              :=        V_JSON.get_string('WERKS');          --플랜트코드        
        V_STOR_LOC_CD         :=       V_JSON.get_string('STOR_LOC_CD');    --저장위치
        V_IND_BCD             :=       V_JSON.get_string('IND_BCD');        --개별바코드 
        V_MATNR	              :=       V_JSON.get_string('MATNR');          --품목코드	
        V_LOT_NO	          :=       V_JSON.get_string('LOT_NO');         --LOT번호
        V_UNIT                :=       V_JSON.get_string('UNIT');           --이동단위

        SELECT W002.MACH_CD, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO, W002.ORDER_NO, W002.ORDER_SEQNO, W002.LOT_NO, W002.MATNR,
                    W002.SDOC_NO, W002.SDOC_SEQNO, I001.WDOC_NO, I001.WDOC_SEQNO, 
                    --W002.CORE, W002.PRFM_DT, W002.PRD_DT, W002.MACHINE, W002.DSTBT_DDLIN,
                    --W002.WRK_CLASS, I001.STCK_QTY, I001.UNIT, W002.PRD_STR_DATE, W002.REGID,
                    --W002.VBELN, W002.POSNR, W002.KUNNR, W002.PACKTYPE, W002.VLEN, W002.WLEN,
                    I001.STCK_QTY, I001.UNIT, I001.WGT, I001.STCK_STA
                INTO V_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, V_ORDER_SEQNO, V_LOT_NO, V_MATNR,
                    V_SDOC_NO, V_SDOC_SEQNO, V_WDOC_NO, V_WDOC_SEQNO,
--                    V_CORE, V_PRFM_DT, V_PRD_DT, V_MACHINE, V_DSTBT_DDLIN,
--                    V_WRK_CLASS, V_PRFM_QTY, V_UNIT, V_PRD_STR_DATE, V_REGID,
--                    V_VBELN, V_POSNR, V_KUNNR, V_PACK_TYPE, V_VLEN, V_WLEN,
                    V_PRFM_QTY, V_UNIT, V_WGT, V_STCK_STA
              FROM TB_WRK002 W002,
                   TB_INV001 I001
             WHERE W002.WERKS = I001.WERKS(+)
               AND W002.IND_BCD = I001.IND_BCD(+)
               AND W002.WERKS = V_WERKS
               AND W002.IND_BCD = V_IND_BCD;

        IF V_STCK_STA = '70' OR (NVL(V_WDOC_NO, ' ') <> ' ' AND  NVL(V_WDOC_NO, ' ') <> 'E') THEN
            P_SUCCESS := 'N';
            P_ERR_MSG := V_MATNR || ' 는 이미 출고되어 실적취소를 할 수 없습니다.';
            ROLLBACK;
            RETURN;
        END IF;

        IF NVL(V_SDOC_NO, ' ') = ' ' OR  NVL(V_SDOC_NO, ' ') = 'E' THEN
            P_SUCCESS := 'N';
            P_ERR_MSG := V_MATNR || ' 는 실적등록되지 않아 실적취소를 할 수 없습니다.';
            ROLLBACK;
            RETURN;
        END IF;

        --실적취소
        V_DOC_NO_1 := FN_GET_MDOCNO('M','IF129');
        V_DOC_SEQNO_1 := 0;

        --자재투입취소
        V_DOC_NO_2 := FN_GET_MDOCNO('M','IF143');
        V_DOC_SEQNO_2 := 0;

        --완제품 입고취소
        V_DOC_NO_3 := FN_GET_MDOCNO('M','IF402');
        V_DOC_SEQNO_3 := 0;

        SELECT SAP_WRK_CD INTO V_SAP_WRK_CD
          FROM TB_MAS012
         WHERE MACH_CD = V_MACH_CD;

        --실적취소
        OPEN PROD_CUR FOR
            SELECT DOC_NO, DOC_SEQNO, DOC_DIV, IND_BCD, ORDER_NO, SDOC_NO, SDOC_SEQNO
                    FROM TB_WRK021
                   WHERE WERKS = V_WERKS
                     AND MACH_CD = V_MACH_CD
                     AND WRK_ORDR_NO = V_WRK_ORDR_NO
                     AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                     AND IND_BCD = V_IND_BCD
                     AND NVL(CNL_YN, 'N') = 'N'
               ORDER BY DOC_DIV;
        LOOP
        FETCH PROD_CUR INTO V_DOC_NO_C, V_DOC_SEQNO_C, V_DOC_DIV_C, V_IND_BCD_C, V_ORDER_NO_C, V_SDOC_NO_C, V_SDOC_SEQNO_C;

        EXIT WHEN PROD_CUR %NOTFOUND;    
            IF NVL(V_SDOC_NO_C, ' ') = ' ' THEN
                P_SUCCESS           := 'N';
                P_ERR_MSG := V_MATNR || ' 는 SAP 확정문서번호를 찾을수 없습니다.';
                ROLLBACK;
                RETURN;
            END IF;

            UPDATE TB_WRK021
               SET CNL_YN = 'Y'
             WHERE DOC_NO = V_DOC_NO_C
               AND DOC_SEQNO = V_DOC_SEQNO_C;

            IF V_DOC_DIV_C = 1 THEN       --실적
                V_DOC_SEQNO_1 := V_DOC_SEQNO_1 + 1;
                INSERT INTO TB_IFS007(RUECK, RMZHL, MDOCNO, MDOCSEQ, MAKE_DATE, MAKER,
                                        WORKCENTERCODE, AUFNR, ROLLCNT, MBLNR, LOTNO)
                           VALUES(V_SDOC_NO_C, V_SDOC_SEQNO_C, V_DOC_NO_1, TO_CHAR(V_DOC_SEQNO_1), V_DATE, V_SESS_USER_ID,
                                V_SAP_WRK_CD, V_ORDER_NO, V_PRFM_QTY, V_SDOC_NO_C, V_LOT_NO);

                UPDATE TB_WRK002
                   SET CNL_YN = 'Y',
                    CNL_RMK = P_CNL_RMK,
                    PRFM_GTHR_YN = 'N'
                 WHERE WERKS = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND IND_BCD = V_IND_BCD_C;

                 UPDATE TB_INV001
                    SET STCK_QTY = 0,
                        DLFL = 'Y'
                  WHERE WERKS = V_WERKS
                    AND MACH_CD = V_MACH_CD
                    AND IND_BCD = V_IND_BCD_C;      
            END IF;   

            IF V_DOC_DIV_C = 5 THEN       --투입자재
                SELECT SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO, IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, 
                    USE_QTY, UNIT, ROLLCNT, WGT, CHG_FLG, STCK_KY, LOT_NUM
                    INTO
                    V_SEQNO_M, V_WRK_ORDR_NO_M, V_WRK_ORDR_SEQNO_M, V_IND_BCD_M, V_LOT_NO_M, V_MATNR_M, V_INP_DT_M, 
                    V_USE_QTY_M, V_UNIT_M, V_ROLLCNT_M, V_WGT_M, V_CHG_FLG_M, V_STCK_KY_M, V_LOT_NUM_M
                  FROM TB_INV010
                 WHERE WERKS = V_WERKS 
                   AND MACH_CD = V_MACH_CD
                   AND IND_BCD = V_IND_BCD_C
                   AND DOC_NO = V_DOC_NO_C
                   AND DOC_SEQNO = V_DOC_SEQNO_C;

                UPDATE TB_INV003
                  SET USE_QTY = USE_QTY - V_USE_QTY_M,
                      STCK_QTY = STCK_QTY + V_USE_QTY_M,
                      WGT = WGT + V_USE_QTY_M
                 WHERE WERKS = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND IND_BCD = V_IND_BCD_M;

                UPDATE TB_INV010
                   SET CNL_YN = 'Y'
                 WHERE WERKS = V_WERKS 
                   AND MACH_CD = V_MACH_CD
                   AND IND_BCD = V_IND_BCD_C
                   AND DOC_NO = V_DOC_NO_C
                   AND DOC_SEQNO = V_DOC_SEQNO_C;

                IF SQL%ROWCOUNT =0 THEN    
                    INSERT INTO TB_INV003(WERKS, MACH_CD, MATNR, IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                        LOT_NO, INP_DT, IN_QTY, USE_QTY, STCK_QTY, UNIT, ROLLCNT, WGT,
                                        CHG_FLG, STCK_KY, LOT_NUM, REGDATE, REGID)
                                VALUES(V_WERKS, V_MACH_CD, V_MATNR_M, V_IND_BCD_M, V_SEQNO_M, V_WRK_ORDR_NO_M, V_WRK_ORDR_SEQNO_M,
                                        V_LOT_NO_M, V_INP_DT_M, V_USE_QTY_M, 0, V_USE_QTY_M, V_UNIT_M, V_ROLLCNT_M, V_USE_QTY_M,
                                        V_CHG_FLG_M, V_STCK_KY_M, V_LOT_NUM_M, V_DATE, V_SESS_USER_ID);
                END IF;

                V_DOC_SEQNO_2 := V_DOC_SEQNO_2 + 1;

                INSERT INTO TB_IFS014(AUFNR, POSNR, BUDAT, MATNR, MENGE, WERKS,
                                        LGORT, CHARG, WORKCENTERCODE, MDOCNO, MDOCSEQ,
                                        MBLNR, MJAHR, MAKE_DATE, MAKER)
                SELECT AUFNR, POSNR, BUDAT, MATNR, MENGE, WERKS,
                      LGORT, CHARG, WORKCENTERCODE, V_DOC_NO_2, TO_CHAR(V_DOC_SEQNO_2),
                      MBLNR, MJAHR, V_DATE, V_SESS_USER_ID
                  FROM TB_IFS008
                 WHERE MDOCNO = V_DOC_NO_C
                   AND MDOCSEQ = TO_CHAR(V_DOC_SEQNO_C);

            END IF;
        END LOOP;
        CLOSE PROD_CUR;  

        --입고요청 취소
        BEGIN
            SELECT DOC_NO, DOC_SEQNO, DLFL, VGBEL
                   INTO
                   V_DOC_NO_C, V_DOC_SEQNO_C, V_DLFL, V_VGBEL
              FROM TB_WRK015
             WHERE WERKS = V_WERKS
               AND IND_BCD = V_IND_BCD
    --           AND NVL(VGBEL, ' ') <> ' '
               AND DLFL = 'C'
               AND ROWNUM = 1
            ORDER BY REGDATE DESC;   
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
            V_DOC_NO_C := '';
       END; 

       IF NVL(V_DLFL, ' ') = 'C' THEN
            V_DOC_NO_3 := V_DOC_NO_C;
            V_DOC_SEQNO_3 := V_DOC_SEQNO_3 + 1;

            INSERT INTO TB_IFSWM005( DOC_NO, DOC_SEQNO, DLFL,
                                    WERKS, MATNR, QTY, UNIT, STOR_LOC_FROM, STOR_LOC_TO,
                                    IND_BCD, LOT_NO, MACHINE, ORDER_NO, ORDER_SEQNO, 
                                    PCODE, WEIGHT, WLEN, VLEN, CON_TYPE, PACK_TYPE, OVBELN, OPOSNR, SAUART, KUNNR,
                                    CORE, EMPLY_NO, EMPLY_NM, NTN_CD, PRDC_DT, RCVGDS_DT, DSTBT_DDLIN, STCK_NO,
                                    IF_STATUS, IF_GET_DATE)    
            SELECT DOC_NO, DOC_SEQNO, 'D',
                WERKS, MATNR, QTY, UNIT, STOR_LOC_FROM, STOR_LOC_TO,
                IND_BCD, LOT_NO, MACHINE, ORDER_NO, ORDER_SEQNO, 
                PCODE, WEIGHT, WLEN, VLEN, CON_TYPE, PACK_TYPE, OVBELN, OPOSNR, SAUART, KUNNR,
                CORE, EMPLY_NO, EMPLY_NM, NTN_CD, PRDC_DT, RCVGDS_DT, DSTBT_DDLIN, STCK_NO,
                'N', V_DATE
              FROM TB_IFSWM005     
             WHERE DOC_NO = V_DOC_NO_C
               AND DOC_SEQNO = V_DOC_SEQNO_C
               AND DLFL = 'C';

            UPDATE TB_WRK015
               SET DLFL = 'D',
                   UPDDATE = V_DATE,
                   UPDID = V_SESS_USER_ID
             WHERE DOC_NO = V_DOC_NO_C
               AND DOC_SEQNO = V_DOC_SEQNO_C;   
       END IF;         
--        INSERT INTO TB_IFSWM005( DOC_NO, DOC_SEQNO, DLFL,
--                                 WERKS, MATNR, QTY, UNIT, STOR_LOC_FROM, STOR_LOC_TO, IND_BCD,
--                                 LOT_NO, MACHINE, ORDER_NO, ORDER_SEQNO, PRDC_DT, RCVGDS_DT, DSTBT_DDLIN,
--                                 IF_GET_DATE)
--        SELECT DOC_NO, DOC_SEQNO, 'D',
--               WERKS, MATNR, QTY, UNIT, STOR_LOC_FROM, STOR_LOC_TO, IND_BCD,
--               LOT_NO, MACHINE, ORDER_NO, ORDER_SEQNO, PRDC_DT, RCVGDS_DT, DSTBT_DDLIN,
--               V_DATE
--          FROM TB_IFSWM005
--         WHERE DOC_NO = V_DOC_NO_C
--           AND DOC_SEQNO = V_DOC_SEQNO_C
--           AND DLFL = 'C'
--           AND ROWNUM = 1
--        ORDER BY IF_GET_DATE DESC;


        --실적취소
        IF V_DOC_SEQNO_1 > 0 THEN
            P_DOC_NO1 := V_DOC_NO_1;
        END IF;

        --투입자재 취소
        IF V_DOC_SEQNO_2 > 0 THEN
            P_DOC_NO2 := V_DOC_NO_2;
        END IF;

        --WMS 입고요청 취소
        IF V_DOC_SEQNO_3 > 0 THEN
            P_DOC_NO3 := V_DOC_NO_3;
        END IF;
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
--        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--
--        ROLLBACK;
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
