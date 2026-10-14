--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK30_V01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK30_V01" 
(
     P_WERKS     		IN VARCHAR2 	                --플랜트
    ,P_MACH_CD   		IN VARCHAR2 	                --설비코드
    ,P_IND_BCD_LIST     IN CLOB			   	            --개별바코드 리스트
    ,P_CNL_RMK          IN VARCHAR2 	                --취소내용
    ,P_USERID           IN VARCHAR2                     --USER ID
    ,RS_PRFM_RFCFN      OUT VARCHAR2                    --실적 RFCFN값
    ,RS_DISPO_RFCFN     OUT VARCHAR2                    --폐품 RFCFN값    
    ,RS_INPUT_RFCFN     OUT VARCHAR2                    --투입량 RFCFN값    
    ,RS_SDISPO_RFCFN    OUT VARCHAR2                    --잔량 폐품 RFCFN값    
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK30_V01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 포장실적취소 전 Validation
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : .{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 우상우{최초 작성자 명 기술}
 * CREATE DATE   : 2023/01/16 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2023/01/16    1.0.0   우상우         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_WRK011] : (.RU.) 설비별 현재진행사항 
 *       - [TB_WRK012] : (C.U.) 설비별 현재진행사항 
 *       - [TB_SCH016] : (.R..) 밀롤,슬리터 작업지지서
 *=============================================================================*/

AS 
    --프로그램 ID : 재단 실적취소 
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK30_V01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := P_USERID; --USERID

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_OBJECT_T;
    V_OBJ            JSON_OBJECT_T;

    --parameter변수 처리
    V_IND_BCD           TB_WRK002.IND_BCD%TYPE;      -- 개별바코드

    V_WRK_ORDR_NO           TB_SCH015.WRK_ORDR_NO%TYPE;         
    V_WRK_ORDR_SEQNO        TB_SCH015.WRK_ORDR_SEQNO%TYPE;      


    V_ORDER_NO              TB_WRK002.ORDER_NO%TYPE;
    --V_PRE_ORDER_NO              TB_WRK002.ORDER_NO%TYPE;
    V_STA                   TB_WRK002.STA%TYPE;
    V_SDOC_NO               TB_WRK002.SDOC_NO%TYPE;
    V_SDOC_SEQNO            TB_WRK002.SDOC_SEQNO%TYPE;
    V_SAP_WRK_CD            TB_MAS012.SAP_WRK_CD%TYPE;
    V_ROLLCNT	            TB_WRK002.ROLLCNT%TYPE;		    --권치수
    V_DOC_NO                VARCHAR2(20);
    V_DOC_SEQNO             NUMBER;
    V_DOC_NO_INPUT          VARCHAR2(20);
    V_DOC_NO_INPUTSUM          VARCHAR2(500);
    V_DOC_SEQNO_INPUT       NUMBER;
    V_DOC_NO_DISPO          VARCHAR2(20);
    V_DOC_NO_DISPO_S1          VARCHAR2(20);
    V_DOC_NO_DISPO_S2          VARCHAR2(20);
    V_DOC_SEQNO_DISPO       NUMBER;

    V_PRFM_QTY	            TB_WRK002.PRFM_QTY%TYPE;     --실적수량
    V_DISPO_QTY	            TB_WRK004.DISPO_QTY%TYPE;    --폐품수량
    V_DISPO_WGT             TB_WRK004.WGT%TYPE;          --폐품중량
    V_MATNR                 TB_WRK004.MATNR%TYPE;        --자재코드
    V_PRFM_DT               VARCHAR2(20);   
    V_LOT_NO                VARCHAR2(20);   
    V_INP_DT	            TB_INV003.INP_DT%TYPE;        --투입일자
    V_STOR_LOC_CD           TB_INV001.STOR_LOC_CD%TYPE;
    V_SQL                   VARCHAR2(4000);
    V_IND_BCD_M             TB_WRK002.IND_BCD%TYPE;      -- 자재개별바코드
    V_TOT_QTY               NUMBER(13,3);
    V_WGT                   NUMBER(13,3); 
    V_DMY                   VARCHAR2(1);          
    V_GRD_YN                VARCHAR2(5);          
    V_YMCHK                     TB_MAS011.YMCHK%TYPE;   --실적등록 가능 여부    
    V_STCK_QTY              TB_INV001.STCK_QTY%TYPE;
    V_STCK_STA              TB_INV001.STCK_STA%TYPE;
    V_WRK002_CNT             NUMBER;
    V_WRK004_CNT             NUMBER;
BEGIN
  BEGIN

    V_JSON := JSON_OBJECT_T.parse(P_IND_BCD_LIST);
    V_ARR_LIST        := V_JSON.get_array('list');    
    
    V_WRK002_CNT := 0;
    V_WRK004_CNT := 0;
    
    FOR i IN 0..V_ARR_LIST.get_size-1 LOOP    
        V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
        V_OBJ           := TREAT (V_OBJ.get ('map') AS json_object_t);
        V_IND_BCD       := V_OBJ.get_string('IND_BCD');

        V_DOC_SEQNO        := 0;
        V_DOC_SEQNO_INPUT  := 0;
        V_DOC_SEQNO_DISPO  := 0;
        
        SELECT COUNT(WRK_ORDR_NO) INTO V_WRK002_CNT FROM TB_WRK002
        WHERE WERKS = P_WERKS AND MACH_CD = P_MACH_CD AND IND_BCD = V_IND_BCD AND CNL_YN = 'Y' ;
        
        SELECT COUNT(WRK_ORDR_NO) INTO V_WRK004_CNT FROM TB_WRK004
        WHERE WERKS = P_WERKS AND MACH_CD = P_MACH_CD AND IND_BCD = V_IND_BCD AND CNL_YN = 'Y' ;
        
        IF V_WRK002_CNT > 0 THEN
               RS_CODE := 'E';
               RS_MSG := '이미 실적 취소 완료 되었습니다.('||P_WERKS||','||P_MACH_CD||','||V_IND_BCD||')' ;
               RETURN;
        END IF;
        
        IF V_WRK004_CNT > 0 THEN
               RS_CODE := 'E';
               RS_MSG := '이미 폐품 취소 완료 되었습니다.('||P_WERKS||','||P_MACH_CD||','||V_IND_BCD||')' ;
               RETURN;
        END IF;
        
        -- 실적 취소------------------------------------------------------------------------------------------
        /*BEGIN
                SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, STA, SDOC_NO, SDOC_SEQNO, PRFM_QTY, ROLLCNT, LOT_NO,WGT,PRFM_DT,GRD_YN
                  INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, V_STA, V_SDOC_NO, V_SDOC_SEQNO,
                        V_PRFM_QTY, V_ROLLCNT, V_LOT_NO,V_WGT,V_PRFM_DT,V_GRD_YN
                  FROM TB_WRK002
                 WHERE WERKS   = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IND_BCD = V_IND_BCD
                   AND NVL(CNL_YN,'N') = 'N'
                   ;
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_ROLLCNT := 0;
                    V_PRFM_QTY := 0;
                WHEN OTHERS THEN
                    V_ROLLCNT := 0;
                    V_PRFM_QTY := 0;
        END;*/

        /*UPDATE TB_WRK002     --실적테이블(PS)
           SET CNL_YN = 'Y',
               CNL_RMK = P_CNL_RMK,                               
               UPDDATE = SYSDATE,
               UPDID   = P_USERID
        WHERE WERKS   = P_WERKS
          AND MACH_CD = P_MACH_CD
          AND IND_BCD = V_IND_BCD
          AND NVL(CNL_YN,'N') = 'N';*/

                   
        -- 폐품 취소------------------------------------------------------------------------------------------
        /*BEGIN
                SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, SDOC_NO, SDOC_SEQNO, DISPO_QTY, WGT, ROLLCNT, MMATNR, PRFM_DT, LOT_NO_M,IND_BCD_M,GRD_YN
                  INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_SDOC_NO, V_SDOC_SEQNO, V_DISPO_QTY, V_DISPO_WGT, V_ROLLCNT,V_MATNR,V_PRFM_DT,V_LOT_NO,V_IND_BCD_M,V_GRD_YN
                  FROM TB_WRK004
                 WHERE WERKS   = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IND_BCD = V_IND_BCD
                   AND NVL(CNL_YN,'N') = 'N'
                   ;
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_ROLLCNT := 0;
                    V_DISPO_WGT := 0;
                WHEN OTHERS THEN
                    V_ROLLCNT := 0;
                    V_DISPO_WGT := 0;
        END;*/

    
        /* UPDATE TB_WRK004     --폐품테이블(PS)
            SET CNL_YN = 'Y',
                UPDDATE = SYSDATE,
                UPDID   = P_USERID
          WHERE WERKS   = P_WERKS
            AND MACH_CD = P_MACH_CD
            AND IND_BCD = V_IND_BCD
            AND NVL(CNL_YN,'N') = 'N';*/
            
    END LOOP;

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
