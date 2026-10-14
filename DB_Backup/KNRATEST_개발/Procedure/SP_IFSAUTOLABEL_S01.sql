--------------------------------------------------------
--  DDL for Procedure SP_IFSAUTOLABEL_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IFSAUTOLABEL_S01" 
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
    
    V_IND_BCD       TB_WRK002.IND_BCD%TYPE;  
    V_IND_BCD_M     TB_WRK002.IND_BCD%TYPE;  
    V_CNL_YN        TB_WRK002.CNL_YN%TYPE;  
    V_SPEC          VARCHAR2(20);
    V_WRK_CLASS     TB_WRK002.WRK_CLASS%TYPE;
    V_SCNT          TB_WRK503.SCNT%TYPE;
    V_PCODE         TB_MAS001.PCODE%TYPE;
    V_BS_WGT        TB_MAS001.BS_WGT%TYPE;
    V_WGT           TB_WRK002.WGT%TYPE;
    V_CMCDVL        CMCDV.CMCDVL%TYPE;    
    V_PCNT          TB_SCH018.PCNT%TYPE;
    V_IN_PER_CNT    TB_SCH018.IN_PER_CNT%TYPE;
    V_INDEX_SEQ     NUMBER;
    V_PASS          VARCHAR2(10);
    V_DATE          DATE :=SYSDATE;
    PROD_CUR        SYS_REFCURSOR;		-- 커서 정의
BEGIN
 
    SELECT LINE INTO V_LINE_P
      FROM TB_MAS012
     WHERE MACH_CD = P_MACH_CD; 
    
    OPEN PROD_CUR FOR
        SELECT IND_BCD, PRFM_DT, CNL_YN
            INTO V_IND_BCD, V_PRFM_DT, V_CNL_YN
          FROM TB_WRK502
         WHERE WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND PROC_YN = 'N';
    LOOP
    FETCH PROD_CUR INTO V_IND_BCD, V_PRFM_DT, V_CNL_YN;
    EXIT WHEN PROD_CUR %NOTFOUND;
    
        IF NVL(V_CNL_YN, 'N') = 'N' THEN
            
            V_PASS := 'OK';
            
            BEGIN
            SELECT M001.BS_WGT,             --평량
                   M001.PCODE,              --지종
                   TO_CHAR(W002.WLEN) || 'X' || TO_CHAR(W002.VLEN)  AS SPEC,  --규격
                   W002.IN_PER_CNT,         --속당매수
                   ((W002.WLEN/1000) * (W002.VLEN/1000) * (M001.BS_WGT/1000)) * W002.IN_PER_CNT  AS WGT,     --중량
                   W002.SCNT                               --속수(팔레트당연수*500/속당매수)
                  INTO V_BS_WGT, V_PCODE, V_SPEC, V_IN_PER_CNT, V_WGT, V_SCNT
              FROM TB_WRK002 W002,
                   TB_MAS001 M001
             WHERE W002.WERKS = M001.WERKS(+)
               AND W002.MATNR = M001.MATNR(+)
               AND W002.WERKS = P_WERKS
               AND W002.MACH_CD = P_MACH_CD
               AND W002.IND_BCD = V_IND_BCD;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_PASS := 'NG';   
            END;
            
            IF V_PASS = 'OK' THEN
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
                
                V_YY := SUBSTR(V_PRFM_DT, 3, 2);
        
                IF TO_NUMBER(SUBSTR(V_PRFM_DT, 5, 2))>= 10 THEN
                    V_MM := CHR(TO_NUMBER(SUBSTR(V_PRFM_DT, 5, 2)) + 55);
                ELSE
                    V_MM := TO_CHAR(TO_NUMBER(SUBSTR(V_PRFM_DT, 5, 2)));
                END IF;
            
                SELECT IND_BCD_M  INTO V_IND_BCD_M
                  FROM(
                        SELECT I010.IND_BCD_M
                          FROM TB_INV010 I010,
                               TB_MAS001 M001
                         WHERE I010.WERKS = I010.WERKS
                           AND I010.MATNR_M = M001.MATNR
                           AND I010.WERKS = P_WERKS
                           AND I010.MACH_CD = P_MACH_CD
                           AND I010.IND_BCD = V_IND_BCD
                           AND M001.MATNR_DIV IN ('HAWA', 'FERT', 'HALB')
                        ORDER BY I010.REGDATE)
                 WHERE ROWNUM = 1;
             
                SELECT M012.LINE,
                       W002.WRK_CLASS
                   INTO V_LINE_C,
                      V_WRK_CLASS
                  FROM TB_WRK002 W002,
                       TB_MAS012 M012
                 WHERE W002.MACH_CD = M012.MACH_CD(+)
                   AND W002.WERKS = P_WERKS
                   AND W002.IND_BCD = V_IND_BCD_M;
                
                V_LOT_NO_P := TO_CHAR(V_LINE_P) || V_YY || V_MM || V_DD || 'P' || V_WRK_CLASS || TO_CHAR(V_LINE_C) || 'P';
                
                V_INDEX_SEQ := 0;
                BEGIN
                SELECT MAX(INDEX_SEQ) INTO V_INDEX_SEQ
                  FROM TB_WRK503
                 WHERE WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND PRFM_DT = V_PRFM_DT
                   ;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_INDEX_SEQ := 0;
                END;
            
                V_INDEX_SEQ := NVL(V_INDEX_SEQ, 0) + 1;   
                
                --오토라벨러 전송이력 등록
                INSERT INTO TB_WRK503(WERKS, MACH_CD, IND_BCD, LOT_NO, PRFM_DT, INDEX_SEQ,
                                    BS_WGT, PCODE, SPEC, IN_PER_CNT, WGT, FSC_TYPE, SCNT, CNL_YN, PROC_YN, REGDATE)
                              VALUES( P_WERKS, P_MACH_CD, V_IND_BCD, V_LOT_NO_P, V_PRFM_DT, V_INDEX_SEQ,
                                   V_BS_WGT, V_PCODE, V_SPEC, V_IN_PER_CNT, V_WGT, NVL(V_FSC, 'N'), V_SCNT, V_CNL_YN, 'N', V_DATE);
            END IF;
        ELSE
            UPDATE TB_WRK503
               SET CNL_YN = 'Y',
                   PROC_YN = 'N' 
              WHERE WERKS = P_WERKS
                AND MACH_CD = P_MACH_CD
                AND IND_BCD = V_IND_BCD;
        END IF;
        
        --처리여부 업데이트
        UPDATE TB_WRK502
           SET PROC_YN = 'Y',
               UPDDATE = V_DATE
         WHERE WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND IND_BCD = V_IND_BCD
           AND PRFM_DT = V_PRFM_DT;   

    END LOOP;
    COMMIT;
    
    OPEN P_RS_LIST FOR
    SELECT INDEX_SEQ,
           LOT_NO,
           BS_WGT,
           PCODE,
           SPEC,
           IN_PER_CNT,
           WGT,
           FSC_TYPE,
           SCNT  AS V_PCNT,
           CNL_YN,
           IND_BCD
      FROM TB_WRK503
     WHERE WERKS = P_WERKS 
       AND MACH_CD = P_MACH_CD
       AND PROC_YN = 'N'
    ORDER BY PRFM_DT, INDEX_SEQ;
    
    
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
