
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK29_S01_BAK_230208" 
(
     P_WERKS        IN VARCHAR2 
    ,P_MACH_CD      IN VARCHAR2 
    ,RS_MACH_STA    OUT VARCHAR2    --가동상태(R :가동, S:비가동, N:대기중)
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR       --투입정보
    ,CUR_2          OUT SYS_REFCURSOR       --투입개별바코드 정보 컬럼명
    ,CUR_3          OUT SYS_REFCURSOR       --투입개별바코드 정보
    ,CUR_4          OUT SYS_REFCURSOR       --
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK29
 * PROGRAM NAME  : PS 수재단 주 작업 화면
 * VERSION       : 1.0.1
 * DESCRIPTION   : 투입정보와 작업지시정보 조회
 *                 
 * AUTHOR NAME   : 유상호
 * CREATE DATE   : 2022/05/25
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/25    1.0.0   유상호         Initial Version
 * 2023/01/19    1.0.1   여한진         예외생산 오더중심으로 처리 하도록 수정
 *==============================================================================
 *  관련 테이블
 * - [] : (.R..) 
 * - [] : (.R..) 
 * - [] : (.R..) 
 * - [] : (.R..) 
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM          VARCHAR2(100) := 'SP_POP_WRK29_S01'; -- PROCEDURE NAME
    V_PLT_CD          VARCHAR2(2)   := '99';   --PLANTCODE TEST
    V_SESS_USER_ID    VARCHAR2(20)  := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리
    V_WRK_ORDR_NO     TB_WRK011.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO  TB_WRK011.WRK_ORDR_SEQNO%TYPE;
    V_ORDER_NO        TB_WRK011.ORDER_NO%TYPE;
    V_LOT_NO          TB_WRK011.LOT_NO%TYPE;
    V_MATNR           TB_WRK011.MATNR%TYPE;
    V_MACH_STA        TB_WRK011.MACH_STA%TYPE;
    V_PRD_STR_DTM     TB_WRK011.PRD_STR_DTM%TYPE;

    V_VMUL              NUMBER; -- 세로배수
    V_WMUL              NUMBER; -- 가로배수
    V_MUL               NUMBER; -- 가로,세로중 2배수가 있는겨우 투입연수 * 2로 계산

    V_COLINFO1        VARCHAR2(1000); --Grid 컬럼설정 (Title)
    V_COLTYPE1        VARCHAR2(1000); --Grid 컬럼설정 (Value)

BEGIN
    BEGIN
        --투입정보(투입된 재단 정보)
        BEGIN
            SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, MATNR, PRD_STR_DTM, MACH_STA, LOT_NO
              INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO , V_MATNR, V_PRD_STR_DTM, V_MACH_STA, V_LOT_NO
              FROM TB_WRK011   --작업장(설비)별 현재 진행현황
             WHERE WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD;
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN 
                V_MACH_STA := 'N';
        END;

        RS_MACH_STA := V_MACH_STA;

        OPEN CUR_1 FOR 
        /* 수재단 정상 */
        SELECT  I003.WRK_ORDR_NO          WRK_ORDR_NO
               ,I003.WRK_ORDR_SEQNO       WRK_ORDR_SEQNO
               ,I003.MATNR	              MATNR         --자재코드
               ,I003.LOT_NO               LOT_NO        --LOT NO
               ,W002.RMK	              RMK           --비고
               ,W002.VLEN                 VLEN          --세로
               ,W002.WLEN                 WLEN          --가로
               ,M001.BS_WGT               BS_WGT        --평량
               ,M001.PCODE                PCODE         --지종
               ,M001.PCODE_NM             PCODE_NM      --지종명
               ,V_PRD_STR_DTM          AS PRD_STR_DTM   --생산시작일시(YYYYMMDDHH24MISS)
               ,V_MACH_STA             AS MACH_STA      --상태(R :가동중, S:비가동중, N:대기중)
          FROM TB_INV003 I003,
               TB_WRK002 W002,
               TB_MAS001 M001
         WHERE I003.WERKS   = W002.WERKS
           AND I003.MATNR   = W002.MATNR
           AND I003.IND_BCD = W002.IND_BCD
           AND I003.WERKS   = M001.WERKS(+)
           AND I003.MATNR   = M001.MATNR(+)
           AND I003.WERKS   = P_WERKS
           AND I003.MACH_CD = P_MACH_CD
           AND I003.WRK_ORDR_NO = V_WRK_ORDR_NO
           AND I003.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
           AND ROWNUM = 1
        UNION ALL 
        /* 수재단 예외 */
--        SELECT  V_WRK_ORDR_NO       AS WRK_ORDR_NO       -- /* 예외일 때는 투입자재의 작업지시가 아님 */
--               ,V_WRK_ORDR_SEQNO    AS WRK_ORDR_SEQNO
          SELECT  I003.WRK_ORDR_NO                        
               ,I003.WRK_ORDR_SEQNO     
               ,I003.MATNR                               --자재코드
               ,I003.LOT_NO                              --LOT NO
               ,NULL	                                 --비고
               ,M001.VLEN                                --세로
               ,M001.WLEN                                --가로
               ,M001.BS_WGT                              --평량
               ,M001.PCODE                               --지종
               ,M001.PCODE_NM                            --지종명
               ,V_PRD_STR_DTM       AS PRD_STR_DTM       --생산시작일시(YYYYMMDDHH24MISS)
               ,V_MACH_STA          AS MACH_STA          --상태(R :가동중, S:비가동중, N:대기중)
          FROM TB_INV003 I003,
               TB_SCH020 S020,
               TB_MAS001 M001
--         WHERE I003.WERKS   = S020.WERKS
--           AND I003.MATNR   = S020.MATNR
--           AND I003.LOT_NO  = S020.LOT_NO
          WHERE I003.WRK_ORDR_NO = S020.WRK_ORDR_NO
           AND I003.WRK_ORDR_SEQNO = S020.WRK_ORDR_SEQNO
           AND I003.WERKS   = M001.WERKS(+)
           AND I003.MATNR   = M001.MATNR(+)
           AND I003.WERKS   = P_WERKS
           AND I003.MACH_CD = P_MACH_CD
           AND I003.MATNR   = V_MATNR
           --AND I003.LOT_NO  = V_LOT_NO
           AND I003.WRK_ORDR_NO = V_WRK_ORDR_NO
           AND I003.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
           AND S020.ORDER_NO = V_ORDER_NO 
           AND ROWNUM = 1 ;


        -- 공정투입시 TB_INV001 -> TB_INV003으로 저장시 
        -- IN_QTY, STCK_QTY가 장수(EA)로 등록되어 있음 
        UPDATE TB_INV003
           SET IN_QTY   = WGT ,
               STCK_QTY = WGT 
         WHERE WERKS          = P_WERKS
           AND MACH_CD        = P_MACH_CD
           AND WRK_ORDR_NO    = V_WRK_ORDR_NO
           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
           AND NVL(USE_QTY,0) = 0 ;

        BEGIN
            SELECT VMUL , WMUL
            INTO V_VMUL, V_WMUL
            FROM (
                    SELECT  TRUNC(W002.VLEN / S017.VLEN) VMUL,  TRUNC(W002.WLEN / S017.WLEN) WMUL
                      FROM TB_WRK002 W002,
                           TB_SCH017 S017
                     WHERE W002.WRK_ORDR_NO   = S017.WRK_ORDR_NO
                       AND W002.WRK_ORDR_SEQNO   = S017.WRK_ORDR_SEQNO
                       AND W002.WERKS   = P_WERKS
                       AND W002.WRK_ORDR_NO = V_WRK_ORDR_NO
                       AND W002.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                       AND NVL(W002.CNL_YN, 'N') = 'N'
                       AND ROWNUM = 1 
                   UNION ALL
                    SELECT  TRUNC(S001.VLEN / S019.VLEN) VMUL,  TRUNC(S001.WLEN / S019.WLEN) WMUL
                      FROM TB_SCH019 S019,
                           TB_MAS001 S001
                     WHERE S019.WERKS   = P_WERKS
                       AND S019.WRK_ORDR_NO    = V_WRK_ORDR_NO
                       AND S019.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                       AND S019.WERKS   = S001.WERKS
                       AND S001.MATNR    = V_MATNR
                       AND S019.USE_YN = 'Y'
                       AND ROWNUM = 1                    
           );
        EXCEPTION
            WHEN NO_DATA_FOUND THEN 
                V_VMUL := 1;
                V_WMUL := 1;
        END;


        V_MUL := 1;
        IF V_VMUL > 1 OR V_WMUL > 1 THEN
            V_MUL := 2;
        END IF;

        --grid1 컬럼 정보 설정
        V_COLINFO1 := '선택@C^40|투입바코드@C^130|투입연수@C^90|자재코드@H|LOT_NO@H|투입중량@H|사용연수@H|사용중량@H|폐품연수@H|폐품중량@H|가용연수@C^90|가용중량@H|구분@H';
        --V_COLINFO1 := '선택@C^40|재단바코드@C^170|투입연수@C^80|자재코드@H|LOT_NO@H|투입중량@H|사용연수@H|사용중량@H|폐품연수@C^80|폐품중량@C^80|구분@H';
        V_COLTYPE1 := 'CHK@Button|IND_BCD@varchar|IN_REAM@varchar|MATNR@varchar|LOT_NO@varchar|WGT@varchar|USE_QTY@varchar|USE_WGT@varchar|DISPO_QTY@varchar|DISWGT@varchar|AVA_REAM@varchar|AVA_WGT@varchar|GB@varchar';

        --컬럼설정 반환 테이블 작성
        OPEN CUR_2 FOR
        SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO1 || ',' || V_COLTYPE1, ',');

        --GRID1 데이터
       -- IF V_LOT_NO IS NULL THEN
            BEGIN
                OPEN CUR_3 FOR
                SELECT CHK      CHK,                --선택
                       IND_BCD,                     --투입자재바코드
                       --(SELECT PCNT FROM TB_WRK002 WHERE NVL(CNL_YN,'N') = 'N' AND WRK_ORDR_NO =  V_WRK_ORDR_NO AND IND_BCD = A.IND_BCD AND ROWNUM = 1)  IN_REAM,	                    --투입연수
                       (IN_REAM * V_MUL)    IN_REAM,
                       MATNR,                       --투입자재코드
                       LOT_NO,                      --투입자재LOT NO
                       WGT,                         --투입중량
                       SUM(NVL(USE_QTY, 0)) USE_QTY,        --사용연수
                       SUM(NVL(USE_WGT, 0)) USE_WGT,        --사용중량
                       SUM(NVL(DISPO_QTY, 0)) DISPO_QTY,    --폐품연수
                       SUM(NVL(DISWGT, 0)) DISWGT,          --폐품중량
                       (IN_REAM * V_MUL) - SUM(NVL(USE_QTY, 0)) - SUM(NVL(DISPO_QTY, 0)) AVA_REAM,     -- 가용연수
                       WGT - SUM(NVL(USE_WGT, 0)) - SUM(NVL(DISWGT, 0))     AVA_WGT,                    --가용중량
--                       (IN_REAM * V_MUL) - SUM(NVL(USE_QTY, 0)) - SUM(NVL(DISPO_QTY, 0)) AVA_REAM,     -- 가용연수
--                       WGT - SUM(NVL(USE_WGT, 0)) - SUM(NVL(DISWGT, 0))     AVA_WGT,                    --가용중량
                    --   NVL(USE_QTY, 0) USE_QTY,        --사용연수
                    --   NVL(USE_WGT, 0) USE_WGT,        --사용중량
                    --   NVL(DISPO_QTY, 0) DISPO_QTY,    --폐품연수
                    --   NVL(DISWGT, 0) DISWGT,          --폐품중량
                    --   (IN_REAM * V_MUL) - NVL(USE_QTY, 0) - NVL(DISPO_QTY, 0) AVA_REAM,     -- 가용연수
                    --   WGT - NVL(USE_WGT, 0) - NVL(DISWGT, 0)     AVA_WGT,                    --가용중량
                       GB                           --작업구분(정상 : A, 예외:B)
                FROM
                  (
                            SELECT 
                                   '-'              CHK                 --선택
                                   ,V003.IND_BCD    IND_BCD             --재단바코드
                                   ,(
                                       SELECT SUM(K002.PCNT)
                                       FROM TB_WRK002  K002
                                       WHERE K002.WERKS          = P_WERKS
                                         AND NVL(K002.CNL_YN, 'N') = 'N'
                                         AND K002.IND_BCD = V003.IND_BCD
                                    )               IN_REAM	            --투입연수                                                  
                                   ,V003.MATNR      MATNR               --재단반제품코드
                                   ,V003.LOT_NO     LOT_NO              --투입자재LOT NO
                                   , (
                                       SELECT SUM(K002.WGT)
                                       FROM TB_WRK002  K002
                                       WHERE K002.WERKS          = P_WERKS
                                         AND NVL(K002.CNL_YN, 'N') = 'N'
                                         AND K002.IND_BCD = V003.IND_BCD
                                     )              WGT                 --투입중량
                                   ,(  
                                       SELECT SUM(PCNT)
                                       FROM TB_INV010  V010
                                       WHERE V010.WERKS     = P_WERKS
                                         AND V010.IND_BCD_C = V003.IND_BCD
                                         AND NVL(V010.CNL_YN,'N') = 'N'
                                    )               USE_QTY             --사용연수
                                   ,(  
                                       SELECT SUM(USE_QTY)
                                       FROM TB_INV010  V010
                                       WHERE V010.WERKS     = P_WERKS
                                         AND V010.IND_BCD_C = V003.IND_BCD
                                         AND NVL(V010.CNL_YN,'N') = 'N'
                                    )               USE_WGT             --사용중량
                                   ,(
                                       SELECT SUM(K004.DISPO_QTY)
                                       FROM TB_WRK004  K004
                                       WHERE K004.WERKS          = P_WERKS
                                         AND NVL(K004.CNL_YN, 'N') = 'N'
                                         AND K004.IND_BCD_C = V003.IND_BCD
                                    )               DISPO_QTY           --폐품연수
                                   ,(
                                       SELECT SUM(K004.WGT)
                                       FROM TB_WRK004  K004
                                       WHERE K004.WERKS          = P_WERKS
                                         AND NVL(K004.CNL_YN, 'N') = 'N'
                                         AND K004.IND_BCD_C = V003.IND_BCD
                                    )               DISWGT              --폐품중량
                                   ,'A'             GB                  --작업구분(정상 : A, 예외:B)
                                FROM TB_INV003  V003
                                WHERE V003.WERKS          = P_WERKS
                                 AND  V003.WRK_ORDR_NO    = V_WRK_ORDR_NO
                                 AND V003.MACH_CD = P_MACH_CD
                                 AND SUBSTR(V_WRK_ORDR_NO,1,4) <> 'WOEX'
                    UNION ALL
                            SELECT DISTINCT 
                                   '-'      CHK,               --선택
                                   V003.IND_BCD,           --투입바코드
                                   V003.PRE_IN_QTY IN_REAM,            --투입연수
                                   V003.MATNR,             --투입자재코드
                                   V003.LOT_NO,            --투입자재LOT NO
                                   V003.WGT,               --투입중량
                                    (  
                                       SELECT SUM(PCNT)
                                       FROM TB_INV010  V010
                                       WHERE V010.WERKS     = P_WERKS
                                         AND V010.IND_BCD_C = V003.IND_BCD
                                         AND NVL(V010.CNL_YN,'N') = 'N'
                                    ),                                   
                                    (  
                                       SELECT SUM(WGT)  --SUM(USE_QTY)
                                       FROM TB_INV010  V010
                                       WHERE V010.WERKS     = P_WERKS
                                         AND V010.IND_BCD_C = V003.IND_BCD
                                         AND NVL(V010.CNL_YN,'N') = 'N'
                                    ),                                   
                                   0    AS DISPO_QTY,      --폐품연수(예외는 페품이 없음)
                                   0    AS DISWGT,         --폐품중량(예외는 페품이 없음)
                                   'B'  AS GB              --작업구분(정상 : A, 예외:B)
                              FROM TB_INV003 V003
--                                 , ( SELECT W002.WERKS, W002.PCNT, W002.WGT, W002.IND_BCD, V003.IND_BCD AS IND_BCD_M
--                                       FROM TB_INV003 V003
--                                          , TB_WRK002 W002
--                                          , TB_WRK008 W008
--                                      WHERE V003.WERKS    = W002.WERKS
--                                        AND V003.MACH_CD  = W002.MACH_CD
--                                        AND V003.WERKS    = W008.WERKS
--                                        AND V003.IND_BCD  = W008.IND_BCD_M
--                                        AND W002.IND_BCD  = W008.IND_BCD
--                                        AND NVL(W002.CNL_YN,'N') = 'N'
--                                        AND V003.WERKS   = P_WERKS
--                                        AND V003.MACH_CD = P_MACH_CD
--                                        AND V003.MATNR   = V_MATNR
-- --                                       AND V003.LOT_NO  = V_LOT_NO
--                                   ) W0022
--                             WHERE V003.WERKS   = W0022.WERKS(+)
--                               AND V003.IND_BCD = W0022.IND_BCD_M(+)
                             WHERE V003.WERKS   = P_WERKS
                               AND V003.MACH_CD = P_MACH_CD
                               --AND V003.MATNR   = V_MATNR
                               AND V003.WRK_ORDR_NO = V_WRK_ORDR_NO
                               AND V003.STCK_QTY > 0
                               --AND V003.LOT_NO  = V_LOT_NO
                               --AND V003.LOT_NO IN (SELECT LOT_NO FROM TB_SCH020 WHERE ORDER_NO = V_ORDER_NO)
                               AND SUBSTR(V_WRK_ORDR_NO,1,4) = 'WOEX'
                
                  ) A
                  GROUP BY
                       CHK,
                       IND_BCD,
                       IN_REAM,
                       MATNR,
                       LOT_NO,
                       WGT,
                       GB
                ORDER BY IND_BCD ;                      
/*                       ) A
                 WHERE 1 = 1
                 AND A.IN_REAM IS NOT NULL
                 AND A.GB = 'B'
                  ORDER BY IND_BCD */
              END;
         /* ELSE
              BEGIN
                OPEN CUR_3 FOR
                SELECT  CHK      CHK,               --선택
                       IND_BCD,                     --투입자재바코드
                       IN_REAM,	                    --투입연수
                       MATNR,                       --투입자재코드
                       LOT_NO,                      --투입자재LOT NO
                       WGT,                         --투입중량
                       SUM(USE_QTY) USE_QTY,                     --사용연수
                       SUM(USE_WGT) USE_WGT,                     --사용중량
                       SUM(DISPO_QTY) DISPO_QTY,                   --폐품연수
                       SUM(DISWGT) DISWGT,                      --폐품중량
                       GB                           --작업구분(정상 : A, 예외:B)
                FROM
                  (
                    SELECT '-'      CHK,               --선택
                           V003.IND_BCD               IND_BCD,     --재단바코드
                           W002.PCNT                  IN_REAM,	   --투입연수                                                  
                           V003.MATNR                 MATNR,       --재단반제품코드
                           V003.LOT_NO                LOT_NO,      --투입자재LOT NO
                           W002.WGT                   WGT,         --투입중량
                           I000.PCNT                  USE_QTY,     --사용연수
                           I000.WGT                   USE_WGT,     --사용중량
                           I000.DISPO_QTY             DISPO_QTY,   --폐품연수
                           I000.DISWGT                DISWGT,      --폐품중량
                           'A'                     AS GB           --작업구분(정상 : A, 예외:B)
                      FROM TB_INV003 V003
                         , TB_WRK002 W002
                         , TB_SCH017 H017 
                         , ( SELECT W002.WERKS,  V010.PCNT, 
                                   V010.USE_QTY WGT, 0 DISPO_QTY, 0 AS DISWGT, V010.IND_BCD_C IND_BCD
                               FROM TB_SCH017 S017,
                                    TB_WRK002 W002,
                                    TB_INV003 I003,
                                    TB_INV010 V010
                              WHERE S017.WRK_ORDR_NO    = W002.WRK_ORDR_NO
                                AND S017.WRK_ORDR_SEQNO = W002.WRK_ORDR_SEQNO
                                AND S017.WERKS          = W002.WERKS
                                AND W002.WERKS          = V010.WERKS
                                AND W002.IND_BCD        = V010.IND_BCD
        --                        AND V010.IND_BCD_C      = I003.IND_BCD
                                AND V010.IND_BCD_C      = I003.IND_BCD
                                AND NVL(W002.CNL_YN,'N') = 'N'
                                AND S017.WERKS          = P_WERKS
        --                        AND S017.PRE_ORDER_NO   = V_ORDER_NO
                                AND W002.WRK_ORDR_NO   = V_WRK_ORDR_NO
        --                        AND I003.MACH_CD        = P_MACH_CD
                       UNION ALL
                              SELECT W004.WERKS, 0, 0, W004.DISPO_QTY DISPO_QTY, W004.WGT AS DISWGT, I003.IND_BCD
                               FROM TB_SCH017 S017,
                                    TB_WRK004 W004,
                                    TB_INV003 I003
                              WHERE 
                                    S017.WRK_ORDR_NO    = W004.WRK_ORDR_NO
                                AND S017.WRK_ORDR_SEQNO = W004.WRK_ORDR_SEQNO
                                AND S017.WERKS          = W004.WERKS
                                AND S017.DUMMY_KEY      = I003.IND_BCD
                                AND NVL(W004.CNL_YN,'N') = 'N'
                                AND S017.WERKS          = P_WERKS
                                AND S017.PRE_ORDER_NO   = V_ORDER_NO
                                AND I003.MACH_CD        = P_MACH_CD

                           ) I000
                     WHERE V003.WERKS   = W002.WERKS(+)
                       AND V003.MATNR   = W002.MATNR(+)
                       AND V003.IND_BCD = W002.IND_BCD(+)
                       AND V003.WRK_ORDR_NO    = H017.WRK_ORDR_NO(+)
                       AND V003.WRK_ORDR_SEQNO = H017.WRK_ORDR_SEQNO(+)
                       AND V003.WERKS   = I000.WERKS (+)
                       AND V003.IND_BCD = I000.IND_BCD (+)
                       AND V003.WERKS          = P_WERKS
        --               AND V003.MACH_CD        = P_MACH_CD
                       AND H017.WRK_ORDR_NO    = V_WRK_ORDR_NO
                       AND H017.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                       AND H017.MAN_CUT_YN     = 'Y'
                       --AND V003.STCK_QTY       > 0
                    UNION ALL*/
                     /** 예외투입은 연수로 입력됨 **/
                  /*  SELECT --DISTINCT 
                           '-'      CHK,               --선택
                           V003.IND_BCD,           --투입바코드
                           V003.IN_QTY,            --투입연수
                           V003.MATNR,             --투입자재코드
                           V003.LOT_NO,            --투입자재LOT NO
                           V003.WGT,               --투입중량
                           W0022.PCNT AS USE_QTY,  --사용연수
                           W0022.WGT  AS USE_WGT,  --사용중량
                           0    AS DISPO_QTY,      --폐품연수(예외는 페품이 없음)
                           0    AS DISWGT,         --폐품중량(예외는 페품이 없음)
                           'B'  AS GB              --작업구분(정상 : A, 예외:B)
                      FROM TB_INV003 V003
                         , ( SELECT W002.WERKS, W002.PCNT, W002.WGT, W002.IND_BCD, V003.IND_BCD AS IND_BCD_M
                               FROM TB_INV003 V003
                                  , TB_WRK002 W002
                                  , TB_WRK008 W008
                              WHERE V003.WERKS    = W002.WERKS
                                AND V003.MACH_CD  = W002.MACH_CD
                                AND V003.WERKS    = W008.WERKS
                                AND V003.IND_BCD  = W008.IND_BCD_M
                                AND W002.IND_BCD  = W008.IND_BCD
                                AND NVL(W002.CNL_YN,'N') = 'N'
                                AND V003.WERKS   = P_WERKS
                                AND V003.MACH_CD = P_MACH_CD
                                AND V003.MATNR   = V_MATNR
                                AND V003.LOT_NO  = V_LOT_NO
                           ) W0022
                     WHERE V003.WERKS   = W0022.WERKS(+)
                       AND V003.IND_BCD = W0022.IND_BCD_M(+)
                       AND V003.WERKS   = P_WERKS
                       AND V003.MACH_CD = P_MACH_CD
                       AND V003.MATNR   = V_MATNR
                       AND V003.LOT_NO  = V_LOT_NO
                  )
                  GROUP BY
                       CHK,
                       IND_BCD,
                       IN_REAM,
                       MATNR,
                       LOT_NO,
                       WGT,
                       GB
                  ORDER BY IND_BCD ;
              END;
          END IF;*/
        --작업지시정보
        --수재단 작업지시는 재단 작업지시로 만들어기 때문에 재단폭수가 동일함, 
        --그리고 ORDER_NO 와 PRE_ORDER_NO가 동일함
        OPEN CUR_4 FOR
        SELECT SCH016.MWIDTH_INPUT   MWIDTH_INPUT,     --밀롤지폭
               SCH016.MRCNT          MRCNT,            --밀롤폭수
               SCH017.PKCNT          PKCNT             --재단폭수
          FROM TB_SCH017  SCH017, 
               TB_SCH016  SCH016
         WHERE SCH017.WERKS          = SCH016.WERKS
           AND SCH017.PRE_ORDER_NO   = SCH016.ORDER_NO
           AND SCH017.WERKS          = P_WERKS
           AND SCH017.WRK_ORDR_NO    = V_WRK_ORDR_NO
           AND SCH017.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
      --     AND SCH017.COMP_YN IN ('N', 'I')
           AND ROWNUM = 1 ;

        RS_CODE := 'S';
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
   --     RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE ;
        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END;
/
