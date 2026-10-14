--------------------------------------------------------
--  DDL for Procedure SP_IFSAUTOLABEL_S01_20220921
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IFSAUTOLABEL_S01_20220921" 
(
  P_WERKS        IN VARCHAR2        --플랜트코드
, P_MACH_CD      IN VARCHAR2        --설비코드
, P_SUCCESS     OUT VARCHAR2 
, P_ERR_MSG     OUT VARCHAR2 
, P_RS_LIST   OUT SYS_REFCURSOR
) 
/*==============================================================================
 * PROGRAM ID    : SP_IFSINKJET_S01
 * PROGRAM NAME  : 
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 오토라벨러 LOT 정보 전송(PS) 
 *                 
 * AUTHOR NAME   : 유상호{최초 작성자 명 기술}
 * CREATE DATE   : 2022/08/04 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: 
 * SUB PROCEDURE : 
 * SUB PACKAGES  : 
 * OLD PROGRAM ID: 
 * REVERSION HISTORY
  구분  플랜트  설비코드  설비명
 제지	P100	PPB04	자동포장 4호기
                PPB04	자동포장 5호기
                PPB04	자동포장 6호기

 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/08/04    1.0.0   유상호         Initial Version 
 *=============================================================================*/
AS
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    
    V_PRFM_DT       VARCHAR2(10);
    V_LOT_NO_P      VARCHAR2(15);       --속포장 LOT NO(15자리 중 10자리 채번)            
    V_LINE_P        TB_MAS012.LINE%TYPE;
    V_LINE_C        TB_MAS012.LINE%TYPE;
    V_YY            VARCHAR2(2);
    V_MM            VARCHAR2(2);
    V_DD            VARCHAR2(2);
    V_FSC           VARCHAR2(1);
    V_ORDER_NO_C    TB_SCH018.ORDER_NO%TYPE;
    V_LOT_NO_C      TB_WRK002.LOT_NO%TYPE;
    V_WRK_ORDR_NO_C     TB_WRK002.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO_C  TB_WRK002.WRK_ORDR_SEQNO%TYPE;
    V_WRK_CLASS     TB_WRK002.WRK_CLASS%TYPE;
    V_PCODE         TB_MAS001.PCODE%TYPE;
    V_CMCDVL        CMCDV.CMCDVL%TYPE;    
    V_PCNT          TB_SCH018.PCNT%TYPE;
    V_IN_PER_CNT    TB_SCH018.IN_PER_CNT%TYPE;
    V_DATE          DATE :=SYSDATE;
    
BEGIN
 
    SELECT LINE INTO V_LINE_P
      FROM TB_MAS012
     WHERE MACH_CD = P_MACH_CD; 
    
    BEGIN  
    SELECT CMCDVL INTO V_CMCDVL
      FROM CMCDV
     WHERE CMCDKY = 'FSC_PCODE'
       AND CMCDVL = V_PCODE ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            V_CMCDVL := '';
    END ;
    IF NVL(V_CMCDVL, ' ') <> ' ' THEN
        V_FSC := 'Y';
    ELSE
        V_FSC := 'N';
    END IF;   
       
    V_PRFM_DT := FN_RECDATE(V_DATE);
    
    V_YY := SUBSTR(V_PRFM_DT, 3, 2);
    
    IF TO_NUMBER(SUBSTR(V_PRFM_DT, 5, 2))>= 10 THEN
        V_MM := CHR(TO_NUMBER(SUBSTR(V_PRFM_DT, 5, 2)) + 55);
    ELSE
        V_MM := TO_CHAR(TO_NUMBER(SUBSTR(V_PRFM_DT, 5, 2)));
    END IF;
    
    V_DD := SUBSTR(V_PRFM_DT, -2);
    
    --V_LOT_NO_P := TO_CHAR(V_LINE_P) || V_YY || V_MM || V_DD || 'P' || V_WRK_CLASS || TO_CHAR(V_LINE_C) || 'P';
    
    
    OPEN P_RS_LIST FOR
    
    SELECT ROWNUM                 AS INDEX_SEQ,
           TO_CHAR(V_LINE_P) || V_YY || V_MM || V_DD || 'P' ||
           NVL(W002.WRK_CLASS, '0') || 
           CASE WHEN NVL(W002.MACH_CD, ' ') = ' ' THEN '0' ELSE (SELECT TO_CHAR(LINE) FROM TB_MAS012 WHERE MACH_CD = W002.MACH_CD) END ||
           'P'  AS LOT_NO,
           S009.WEIGHT                                      AS BS_WGT,                          --평량
           S009.PCODE,                                                                          --지종
           TO_CHAR(S009.WLEN) || 'X' || TO_CHAR(S009.VLEN)  AS SPEC,                            --규격(가로*세로)
           S009.ZZATT2                                      AS IN_PER_CNT,                      --속당매수
           ((S009.WLEN/1000) * (S009.VLEN/1000) * (S009.WEIGHT/1000)) * S009.ZZATT2  AS WGT,     --중량
           V_FSC                                            AS FSC_TYPE,
           (S009.ZZATT1 *500) / S009.ZZATT2                 AS V_PCNT,                             --속수(팔레트당연수*500/속당매수)
           'N'                                              AS CNL_YN           --취소여부
      FROM(
            SELECT WERKS, MATNR, IND_BCD, LOT_NO, WRK_ORDR_NO, WRK_ORDR_SEQNO
              FROM(
                    SELECT *
                      FROM TB_INV003
                     WHERE WERKS = P_WERKS
                       AND MACH_CD = P_MACH_CD
                       AND STCK_QTY > 0
                     ORDER BY REGDATE DESC 
                   ) 
             WHERE ROWNUM BETWEEN 1 AND 2 
            )I003,
            TB_SCH017 S017,     --재단 작업지시
            TB_SCH009 S009,     --포장 생산오더
            TB_WRK002 W002
     WHERE I003.WERKS = S017.WERKS(+)        
       AND I003.WRK_ORDR_NO = S017.WRK_ORDR_NO(+)
       AND I003.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO(+)
       AND S017.ORDER_NO = S009.FRAUFNR
       AND I003.IND_BCD = W002.IND_BCD(+);
    
--    SELECT V_LOT_NO_P AS LOT_NO,      
--           BS_WGT,      --평량
--           PCODE,       --지종
--           TO_CHAR(WLEN) || 'X' || TO_CHAR(VLEN) AS SPEC,  --규격(가로*세로)
--           IN_PER_CNT,                              --속당매수                       
--           ((WLEN/1000) * (VLEN/1000) * (BS_WGT/1000)) * IN_PER_CNT AS WGT,   --중량
--           V_FSC AS FSC_TYPE,
--           V_IN_PER_CNT,                    --속당매수
--           V_PCNT                           --속수
--      FROM TB_SCH018
--     WHERE WERKS = P_WERKS
--       AND PRE_ORDER_NO = V_ORDER_NO_C;
    
EXCEPTION
    WHEN OTHERS THEN
        P_SUCCESS  := 'N';
        E_SQL_ERR_CD        := -20000;
		E_SQL_ERR_MSG       := SQLCODE || ': V_PLT_CD OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
        P_ERR_MSG := E_SQL_ERR_MSG;
        --SP_PROC_ERROR('', V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
        P_ERR_MSG := 'SP_IFSINKJET_S01 : INSERT >>' || CHR(13) || CHR(10) || 'ERRCode : ' || TO_CHAR(SQLCODE);
        RAISE_APPLICATION_ERROR(-20938,SQLERRM);
        RETURN;
END;

/
