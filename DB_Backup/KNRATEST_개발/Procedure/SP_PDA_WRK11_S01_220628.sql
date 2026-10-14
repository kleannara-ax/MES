--------------------------------------------------------
--  DDL for Procedure SP_PDA_WRK11_S01_220628
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_PDA_WRK11_S01_220628" 
(
    P_TYPE           IN    varchar2, -- LIST, SAVE(실적등록), SAVE1(실적취소)
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
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
    V_DOC_NO            TB_WRK002.DOC_NO%TYPE;
    V_DOC_SEQNO         TB_WRK002.DOC_SEQNO%TYPE;
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
    V_LOT_NO_M          VARCHAR2(10);           --재단 LOT NO

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
                        SUBSTR(W002.MATNR, 10, 4) || ''X'' || SUBSTR(W002.MATNR, 14, 4)  MATNR_SPEC,                         --규격
                        CASE WHEN W002.PACKTYPE = ''A'' THEN TO_CHAR(NVL(W002.SCNT, 0)) || ''/'' || TO_CHAR(NVL(W002.MCNT, 0))
                            WHEN W002.PACKTYPE = ''B'' THEN TO_CHAR(NVL(W002.MCNT, 0)) END SMCNT,                 --속/매
                        CASE WHEN I001.LOC_CD = ''L2300'' THEN W002.ROLLCNT ELSE W002.PRFM_QTY END PRFM_QTY,      --권치수/연수
                        W002.WGT,                --중량
                        W002.FN_CD_VAL(''PACK_TYPE'', W002.PACKTYPE)  AS PACKTYPE,  --포장타입
                        W002.KUNNR,              --거래처코드
                        CASE WHEN STCK_STA = ''00'' THEN ''생산출고 가능''
                            WHEN STCK_STA = ''70'' THEN ''생산출고 완료'' END STCK_STA  --포장실적 상태
                  FROM TB_INV001 I001,
                       TB_WRK002 W002,
                       TB_MAS009 M009
                 WHERE I001.WERKS = W002.WERKS
                   AND I001.IND_BCD = W002.IND_BCD 
                   AND W002.KUNNR = M009.CUST_CD(+)';

        V_SQL := V_SQL || ' AND I001.WERKS = ''' || V_IND_BCD || '''';  

        V_SQL := V_SQL || ' AND I001.STOR_LOC_CD = ''2000''
                            AND I001.LOC_CD IN (''L2300'', ''L2800'')';  

        V_SQL := V_SQL || ' AND INV001.IND_BCD = ''' || V_IND_BCD || '''';            --개별바코드 

        V_SQL := V_SQL || ' AND I001.STCK_STA = ''00''
                            AND I001.STCK_QTY > 0' ;

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
    ELSIF P_TYPE = 'SAVE' THEN
        BEGIN
            SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, ORDER_SEQNO, LOT_NO, CORE, PRFM_DT, MACHINE, DSTBT_DDLIN,
                    WRK_CLASS, PRFM_QTY, UNIT, PRD_STR_DATE, REGID,
                    VBELN, POSNR, KUNNR, PACKTYPE, VLEN, WLEN
                INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, V_ORDER_SEQNO, V_LOT_NO, V_CORE, V_PRFM_DT, V_MACHINE, V_DSTBT_DDLIN,
                    V_WRK_CLASS, V_PRFM_QTY, V_UNIT, V_PRD_STR_DATE, V_REGID,
                    V_VBELN, V_POSNR, V_KUNNR, V_PACK_TYPE, V_VLEN, V_WLEN
              FROM TB_WRK002
             WHERE WERKS = V_WERKS
               AND IND_BCD = V_IND_BCD;

            SELECT SAP_WRK_CD INTO V_SAP_WRK_CD
              FROM TB_MAS012
             WHERE MACH_CD = V_MACH_CD;

            SELECT NMLAST, EMAIL1 
                INTO V_USER_NM, V_USER_NM_EN 
              FROM USRMA
             WHERE USERID = V_REGID;

           SELECT LAND1 INTO V_NTN_CD
             FROM TB_MAS009
            WHERE CUST_CD = V_KUNNR; 

            --투입이력조회
            V_SEQ := 0;
            V_LOT_NO_C1 := '';
            V_LOT_NO_C2 := '';
            V_LOT_NO_C3 := '';
            V_LOT_NO_C4 := '';
            V_LOT_NO_C5 := '';

            OPEN PROD_CUR FOR
                --투입된 재단 LOT NO 조회
                SELECT I010.LOT_NO_M INTO V_LOT_NO_M
                  FROM TB_INV010 I010,
                       TB_MAS001 M001
                 WHERE I010.WERKS = M001.WERKS
                   AND I010.MATNR_M = M001.MATNR
                   AND I010.WERKS = V_WERKS
                   AND I010.MACH_CD = V_MACH_CD
                   AND I010.IND_BCD = V_IND_BCD
                   AND M001.MATNR_DIV IN ('FERT', 'HALB');

            LOOP
            FETCH PROD_CUR INTO V_LOT_NO_M;
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
            END LOOP;
            CLOSE PROD_CUR;

            --자재코드 5번째 자리 2 = 수출, 그외 = 내수
            V_USER_NM_EN := SUBSTR(V_USER_NM_EN, 1, INSTR(V_USER_NM_EN , '@') -1 ) ;

            V_PRD_END_DATE := V_DATE;

            V_SDATE := TO_CHAR(V_PRD_STR_DATE, 'YYYYMMDD');
            V_STIME := TO_CHAR(V_PRD_STR_DATE, 'HH24MISS');   
            V_EDATE := TO_CHAR(V_DATE, 'YYYYMMDD');
            V_ETIME := TO_CHAR(V_DATE, 'HH24MISS');

            V_WRK_TM := ROUND((V_PRD_END_DATE - V_PRD_STR_DATE) *24 * 60);

            V_DOC_NO := FN_GET_MDOCNO('M','IF128');
            V_DOC_SEQNO := 1;
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
                               '',
                               '',
                               V_SDATE,
                               V_STIME,
                               V_EDATE,
                               V_ETIME,
                               V_DOC_NO,
                               V_DOC_SEQNO,
                               V_DATE,
                               V_SESS_USER_ID,
                               V_LOT_NO_C1,
                               V_LOT_NO_C2,
                               V_LOT_NO_C3,
                               V_LOT_NO_C4,
                               V_LOT_NO_C5);

            --SAP I/F 문서번호 업데이트
            UPDATE TB_WRK002
               SET DOC_NO = V_DOC_NO,
                   DOC_SEQNO = V_DOC_SEQNO
             WHERE WERKS = V_WERKS
               AND IND_BCD = V_IND_BCD;

            --문서이력
            INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                IND_BCD, LOT_NO, ORDER_NO, CNL_YN, REGDATE, REGID)
                        VALUES(V_DOC_NO, V_DOC_SEQNO, 1, V_WERKS, V_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                V_IND_BCD, V_LOT_NO, V_ORDER_NO, 'N', V_DATE, V_SESS_USER_ID);                                    


            --WMS 완제품 입고요청
            V_DOC_NO := FN_GET_MDOCNO('M','IF402');
            V_DOC_SEQNO := 1;

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
                       VALUES( V_DOC_NO, V_DOC_SEQNO, 'C',
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

        EXCEPTION           
        WHEN OTHERS THEN 
            P_SUCCESS           := 'N';
            E_SQL_ERR_CD        := SQLCODE;
            E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

            ROLLBACK;
            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
            RETURN;           
        END;  
     ELSIF P_TYPE = 'SAVE1' THEN
        V_WERKS              :=        V_JSON.get_string('WERKS');          --플랜트코드        
        V_STOR_LOC_CD         :=       V_JSON.get_string('STOR_LOC_CD');    --저장위치
        V_IND_BCD             :=       V_JSON.get_string('IND_BCD');        --개별바코드 
        V_MATNR	              :=       V_JSON.get_string('MATNR');          --품목코드	
        V_LOT_NO	          :=       V_JSON.get_string('LOT_NO');         --LOT번호

        V_UNIT                :=       V_JSON.get_string('UNIT');           --이동단위


    END IF;

    P_SUCCESS := 'Y';

    COMMIT;

    EXCEPTION
    WHEN E_EXCEPTION_USER THEN

        -- 에러 내역 SET
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        ROLLBACK;

    WHEN OTHERS THEN
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;

/
