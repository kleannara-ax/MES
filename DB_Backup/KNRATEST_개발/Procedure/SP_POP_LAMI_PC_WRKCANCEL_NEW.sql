--------------------------------------------------------
--  DDL for Procedure SP_POP_LAMI_PC_WRKCANCEL_NEW
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_LAMI_PC_WRKCANCEL_NEW" 
(
    P_WERKS     		IN VARCHAR2 	                --플랜트
    ,P_MACH_CD   		IN VARCHAR2 	                --설비코드
    ,P_WRK_ORDR_NO      IN VARCHAR2                     --작업지시번호
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2                     --작업지시번호SEQ
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
    
)
/*==============================================================================
 * PROGRAM ID    : WRK073
 * PROGRAM NAME  : 슬리팅 ROLLBACK
 * VERSION       : 1.0.0
 * DESCRIPTION   : 슬리팅 ROLLBACK을 하기 위한 SP.
 *                 
 * AUTHOR NAME   : 김수현
 * CREATE DATE   : 2022/11/17
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/10    1.0.0   김수현         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_LAMI_PC] : (.R..) 인쇄/코팅 작업지시
 *=============================================================================*/
AS 
    --프로그램 ID : 점보롤 작업시작
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_LAMI_PC_WRKCANCEL';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리

    V_MATNR                     TB_WRK002.MATNR%TYPE;
    V_SAP_WRK_CD        TB_MAS012.SAP_WRK_CD%TYPE;
    V_CNT1                       NUMBER(13,0);
    V_CNT2                       NUMBER(13,0);
    V_CNT3                       NUMBER(13,0);
    V_ORDER_NO                  VARCHAR2(20);
    V_REGDATE                   DATE := SYSDATE;
    V_DOC_NO                    VARCHAR2(20);
    V_USE_YN                    CHAR(1);
    V_COMP_YN                   CHAR(1);
    V_REMAIN_QTY                NUMBER(13,0);
    V_IND_BCD                   VARCHAR2(20);
    V_LOT_NO                    VARCHAR2(20);
    V_REGID                    VARCHAR2(30);
    V_ORDER_QTY                 NUMBER(13,0);
    V_LOT_NO_M                 VARCHAR2(20);
    V_MATNR_M           TB_WRK004.MATNR%TYPE;        --자재코드
    V_INP_DT	        TB_INV003.INP_DT%TYPE;        --투입일자
    V_SDOC_NO           TB_WRK002.SDOC_NO%TYPE;
    V_SDOC_SEQNO        TB_WRK002.SDOC_SEQNO%TYPE;
    V_IND_BCD_M         TB_WRK002.IND_BCD%TYPE;       --자재개별바코드
    V_RUN_STA           VARCHAR2(5);
    V_EXPROD            VARCHAR2(5);
    V_STA               TB_WRK002.STA%TYPE;
    V_SALWEIGHT         NUMBER(13,0);
    V_SQL               VARCHAR2(4000);
    V_DOC_NO_INPUT      VARCHAR2(20);
    V_DOC_SEQNO_INPUT   NUMBER;
    V_DOC_SEQNO         NUMBER;
    V_PRFM_DT           VARCHAR2(8);
    V_PRD_STR_DTM       VARCHAR2(20);

BEGIN

    BEGIN

         SELECT MATNR, ORDER_NO, DOC_NO, NVL(USE_YN,'Y'), NVL(COMP_YN,'N'), REMAIN_QTY, IND_BCD, LOT_BUF, REGID, ORDER_QTY
         , SALWEIGHT,SUBSTR(PRD_STR_DTM,1,8), PRD_STR_DTM
         INTO V_MATNR, V_ORDER_NO, V_DOC_NO, V_USE_YN, V_COMP_YN, V_REMAIN_QTY, V_IND_BCD, V_LOT_NO, V_REGID, V_ORDER_QTY
         , V_SALWEIGHT, V_PRFM_DT, V_PRD_STR_DTM
         FROM TB_LAMI_PC
         WHERE WRK_ORDR_NO = P_WRK_ORDR_NO  
           AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;

        SELECT NVL(COUNT(*),0)
        INTO V_CNT1
        FROM TB_LAMI_RESULT
        WHERE 1 = 1
        AND WRK_ORDR_NO = P_WRK_ORDR_NO
        AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
        AND WERKS = P_WERKS
        ;

        SELECT NVL(COUNT(*),0)
        INTO V_CNT2
        FROM TB_LAMI_PC_RESULT
        WHERE 1 = 1
        AND WRK_ORDR_NO = P_WRK_ORDR_NO
        AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
        AND WERKS = P_WERKS
        ;

        IF V_USE_YN = 'N' AND V_COMP_YN = 'Y' AND V_REMAIN_QTY = 0 THEN
            BEGIN
                    DELETE FROM TB_WRK008 WHERE WERKS = P_WERKS AND MACH_CD = P_MACH_CD AND IND_BCD = V_IND_BCD; --LOT 추적(DELETE)
                    DELETE FROM TB_INV010 WHERE WRK_ORDR_NO = P_WRK_ORDR_NO AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO AND WERKS = P_WERKS; --자재투입이력(DELETE)
                    DELETE FROM TB_WRK021 WHERE WRK_ORDR_NO = P_WRK_ORDR_NO AND LOT_NO = V_LOT_NO AND ORDER_NO = V_ORDER_NO;
                    DELETE FROM TB_WRK022 WHERE WRK_ORDR_NO = P_WRK_ORDR_NO AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO AND WERKS = P_WERKS;--영업잔량폐품실적(DELETE)
                    DELETE FROM TB_INV001 WHERE WRK_ORDR_NO = P_WRK_ORDR_NO AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO AND WERKS = P_WERKS;--(UPDATE)
--                    DELETE FROM TB_IFS008 WHERE AUFNR = V_ORDER_NO AND CHARG = V_LOT_NO;
                    DELETE FROM TB_IFS012 WHERE AUFNR = V_ORDER_NO AND LOTNO = V_LOT_NO;
                    DELETE FROM TB_LAMI_PC_IFS001 WHERE AUFNR = V_ORDER_NO AND LOTNO = V_LOT_NO;

--            		UPDATE TB_LAMI_PC
--            		   SET COMP_YN = 'I', USE_YN = 'Y'
--            		 WHERE WRK_ORDR_NO = P_WRK_ORDR_NO  
--            		   AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
--                       AND WERKS = P_WERKS
--                       ;

                    UPDATE TB_WRK011
                        SET PRE_WRK_ORDR_NO = P_WRK_ORDR_NO,
                            PRE_WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO,
                            MATNR = V_MATNR,
                            WRK_ORDR_NO = P_WRK_ORDR_NO, 
                            WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO,
                            ORDER_NO = V_ORDER_NO,
                            LOT_NO = V_LOT_NO,
                            PRD_STR_DTM = V_PRD_STR_DTM,
                            MACH_STA = 'R',
                            RUN_STA = '01'
                    WHERE MACH_CD = P_MACH_CD; 

                    UPDATE TB_LAMI_PC
                       SET DOC_NO = ''
                          ,RES_DT = ''
                          ,PRFM_QTY = 0
            --			  ,PRFM_QTY = P_WGT(잔량 수량을 SAP에서 허용하지 않으면 이것을 사용한다)
                          ,CYCLE_TIME = 0
                          ,SAPYN = 'N'
                          ,SALCODE = ''
                          ,SALWEIGHT = 0
                          ,PPCODE = ''
                          ,HEIGHT = 0
                          ,EQUIL = 0
                          ,STD = 0
                          ,USE_YN = 'Y'
                          ,COMP_YN = 'I'
                          ,REMAIN_QTY = WRK_ORDR_QTY
                          ,PRD_END_DTM = ''
                          ,PRD_END_DT = ''
                          ,SALMETER = 0
                          ,PRFMMET_QTY = 0
                     WHERE WRK_ORDR_NO = P_WRK_ORDR_NO  
                       AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                       AND WERKS = P_WERKS
                       AND NVL(USE_YN, 'N') = 'N'
                       AND NVL(COMP_YN, 'Y') = 'Y'
                       ;

                    IF V_CNT2 > 0 THEN
                        BEGIN
                            DELETE FROM TB_LAMI_PC_RESULT
                             WHERE WRK_ORDR_NO = P_WRK_ORDR_NO  
                               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                               AND WERKS = P_WERKS
                               AND ORDER_NO = V_ORDER_NO
                               --AND NVL(DLFL,'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더
--                               AND NVL(USE_YN, 'N') = 'N'
                               ;
                        END;
                    END IF;

                    IF V_CNT1 > 0 THEN
                        BEGIN
--                            UPDATE TB_LAMI_PC_RESULT SET CNL_YN = 'Y', CNL_RMK = P_CLN_RMK
                            DELETE FROM TB_LAMI_RESULT 
                             WHERE WRK_ORDR_NO = P_WRK_ORDR_NO  
                               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                               AND WERKS = P_WERKS
                               AND MACH_CD = P_MACH_CD
                               AND IND_BCD = V_IND_BCD
--                               AND NVL(CNL_YN,'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더
                               ;

                            INSERT INTO TB_LAMI_RESULT
                            SELECT 
                            A.WERKS
                            ,A.MACH_CD
                            ,A.IND_BCD
                            ,A.LOT_NO
                            ,A.MATNR
                            ,A.ORDER_NO
                            ,A.ORDER_SEQNO
                            ,A.WRK_ORDR_NO
                            ,A.WRK_ORDR_SEQNO
                            ,A.PRD_NO
                            ,A.UNIT
                            ,A.PRFM_QTY
                            ,A.PCNT
                            ,A.SCNT
                            ,A.MCNT
                            ,A.WIDTH
                            ,A.ROLLCNT
                            ,A.WGT
                            ,A.RSPEED
                            ,A.CORE
                            ,A.WIDTH_NO
                            ,A.MRLDCK
                            ,A.CUTTER
                            ,A.MER_YN
                            ,A.GRD_YN
                            ,A.PRD_STR_DATE
                            ,A.PRD_END_DATE
                            ,A.TM
                            ,A.PRFM_DT
                            ,A.PRD_DT
                            ,A.DSTBT_DDLIN
                            ,A.WRK_CLASS
                            ,A.WRK_SHIFT
                            ,A.MACHINE
                            ,A.TO_MACHINE
                            ,A.STA
                            ,A.DOC_NO
                            ,A.DOC_SEQNO
                            ,A.SDOC_NO
                            ,A.SDOC_SEQNO
                            ,A.RMK
                            ,A.CNL_YN
                            ,'SAP I/F 전송 실패'
                            ,A.REGDATE
                            ,A.REGID
                            ,A.UPDDATE
                            ,A.UPDID
                            ,A.VBELN
                            ,A.POSNR
                            ,A.KUNNR
                            ,A.PACKTYPE
                            ,A.RUN_STA
                            ,A.WRK_SEQ
                            ,A.PRD_SEQ
                            ,A.LOT_NO_BUF
                            ,A.VLEN
                            ,A.WLEN
                            ,A.PRFM_GTHR_YN
                            ,A.NAUFNR
                            ,A.LOT_NO_PRE
                            ,A.LOT_CHG_YN
                            ,A.RMD_QTY
                            ,A.MER_IND_BCD
                            ,A.MER_RMK
                            ,A.IN_PER_CNT
                            ,A.MAN_CUT_YN
                            ,A.LOT_NO_M1
                            ,A.LOT_NO_M2
                            ,A.LOT_NO_M3
                            ,A.LOT_NO_M4
                            ,A.LOT_NO_M5
                            ,A.USE_REAM_M1
                            ,A.USE_REAM_M2
                            ,A.USE_REAM_M3
                            ,A.USE_REAM_M4
                            ,A.USE_REAM_M5
                            ,A.PACK_LABEL_TYPE
                            ,A.JRCOM_YN
                            ,A.MRCOM_YN
                            ,'X'
                            ,A.CACOM_YN
                            FROM TB_WRK002 A
                             WHERE A.WRK_ORDR_NO = P_WRK_ORDR_NO  
                               AND A.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                               AND A.WERKS = P_WERKS
                               AND A.MACH_CD = P_MACH_CD;

    --                    DELETE FROM TB_WRK002 WHERE WRK_ORDR_NO = P_WRK_ORDR_NO AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO AND WERKS = P_WERKS; --실적(DELETE)

--                                UPDATE TB_WRK002     --실적테이블(PS)
--                                   SET CNL_YN  = 'Y',
--                                       CNL_RMK = P_CLN_RMK,
--                                       UPDDATE = SYSDATE,
--                                       UPDID   = V_REGID
--                                 WHERE WERKS   = P_WERKS
--                                   AND MACH_CD = P_MACH_CD
--                                   AND IND_BCD = V_IND_BCD ;

                       END;
                    ELSIF V_CNT1 = 0 THEN
                        BEGIN

            --             DELETE FROM TB_LAMI_RESULT
            --             WHERE WRK_ORDR_NO = P_WRK_ORDR_NO  
            --               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
            --               AND WERKS = P_WERKS;

                            INSERT INTO TB_LAMI_RESULT
                            SELECT 
                            A.WERKS
                            ,A.MACH_CD
                            ,A.IND_BCD
                            ,A.LOT_NO
                            ,A.MATNR
                            ,A.ORDER_NO
                            ,A.ORDER_SEQNO
                            ,A.WRK_ORDR_NO
                            ,A.WRK_ORDR_SEQNO
                            ,A.PRD_NO
                            ,A.UNIT
                            ,A.PRFM_QTY
                            ,A.PCNT
                            ,A.SCNT
                            ,A.MCNT
                            ,A.WIDTH
                            ,A.ROLLCNT
                            ,A.WGT
                            ,A.RSPEED
                            ,A.CORE
                            ,A.WIDTH_NO
                            ,A.MRLDCK
                            ,A.CUTTER
                            ,A.MER_YN
                            ,A.GRD_YN
                            ,A.PRD_STR_DATE
                            ,A.PRD_END_DATE
                            ,A.TM
                            ,A.PRFM_DT
                            ,A.PRD_DT
                            ,A.DSTBT_DDLIN
                            ,A.WRK_CLASS
                            ,A.WRK_SHIFT
                            ,A.MACHINE
                            ,A.TO_MACHINE
                            ,A.STA
                            ,A.DOC_NO
                            ,A.DOC_SEQNO
                            ,A.SDOC_NO
                            ,A.SDOC_SEQNO
                            ,A.RMK
                            ,A.CNL_YN
                            ,'SAP I/F 전송 실패'
                            ,A.REGDATE
                            ,A.REGID
                            ,A.UPDDATE
                            ,A.UPDID
                            ,A.VBELN
                            ,A.POSNR
                            ,A.KUNNR
                            ,A.PACKTYPE
                            ,A.RUN_STA
                            ,A.WRK_SEQ
                            ,A.PRD_SEQ
                            ,A.LOT_NO_BUF
                            ,A.VLEN
                            ,A.WLEN
                            ,A.PRFM_GTHR_YN
                            ,A.NAUFNR
                            ,A.LOT_NO_PRE
                            ,A.LOT_CHG_YN
                            ,A.RMD_QTY
                            ,A.MER_IND_BCD
                            ,A.MER_RMK
                            ,A.IN_PER_CNT
                            ,A.MAN_CUT_YN
                            ,A.LOT_NO_M1
                            ,A.LOT_NO_M2
                            ,A.LOT_NO_M3
                            ,A.LOT_NO_M4
                            ,A.LOT_NO_M5
                            ,A.USE_REAM_M1
                            ,A.USE_REAM_M2
                            ,A.USE_REAM_M3
                            ,A.USE_REAM_M4
                            ,A.USE_REAM_M5
                            ,A.PACK_LABEL_TYPE
                            ,A.JRCOM_YN
                            ,A.MRCOM_YN
                            ,'X'
                            ,A.CACOM_YN
                            FROM TB_WRK002 A
                             WHERE A.WRK_ORDR_NO = P_WRK_ORDR_NO  
                               AND A.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                               AND A.WERKS = P_WERKS;

    --                        DELETE FROM TB_WRK002 WHERE WRK_ORDR_NO = P_WRK_ORDR_NO AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO AND WERKS = P_WERKS; --실적(DELETE)

--                                UPDATE TB_WRK002     --실적테이블(PS)
--                                   SET CNL_YN  = 'Y',
--                                       CNL_RMK = P_CLN_RMK,
--                                       UPDDATE = SYSDATE,
--                                       UPDID   = V_REGID
--                                 WHERE WERKS   = P_WERKS
--                                   AND MACH_CD = P_MACH_CD
--                                   AND IND_BCD = V_IND_BCD ;

                        END;
                    END IF;

                    DELETE FROM TB_WRK002 WHERE ORDER_NO = V_ORDER_NO AND WRK_ORDR_NO = P_WRK_ORDR_NO AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;

                    UPDATE TB_INV003                -- 자재투입량 폐품 2
                       SET DISPO_QTY = 0,
                           USE_QTY   = 0,
                           STCK_QTY  = NVL(STCK_QTY, 0)  + (NVL(USE_QTY,0) + NVL(DISPO_QTY,0))
                     WHERE WERKS   = P_WERKS
                       AND MACH_CD = P_MACH_CD
                       AND WRK_ORDR_NO = P_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                       ;
                 COMMIT;
            END;
        ELSE
            BEGIN
                ROLLBACK;

                RS_CODE := 'E';
                RS_MSG  := '실적완료가 되지않은 작업입니다. 그렇기에 작업취소를 할 수 없습니다. 실적완료 버튼을 누르고 실적완료를 하고 취소하시길 바랍니다.';
                RETURN;
            END;
        END IF;

        RS_CODE := 'S';
        RS_MSG  := '실적완료를 ROLLBACK 했습니다.';
        COMMIT;      
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
        E_SQL_ERR_CD        := '-20000';  --SQLCODE;
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
