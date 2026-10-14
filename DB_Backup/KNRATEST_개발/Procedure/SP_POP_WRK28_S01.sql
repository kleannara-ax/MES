--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK28_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK28_S01" 
(
    P_WERKS         IN VARCHAR2             -- 플랜트코드
    ,P_MACH_CD      IN VARCHAR2             -- 작업장코드
    ,RS_MACH_STA    OUT VARCHAR2    --가동상태(R :가동, S:비가동, N:대기중)
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
    ,CUR_3          OUT SYS_REFCURSOR
    ,CUR_4          OUT SYS_REFCURSOR
    ,CUR_5          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK28
 * PROGRAM NAME  : PS 슬리터 주 작업 화면
 * VERSION       : 1.0.1
 * DESCRIPTION   : 투입정보와 작업지시정보 조회
 *                 
 * AUTHOR NAME   : 김병무
 * CREATE DATE   : 2022/06/13
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
 * 2022/06/13    1.0.1   김병무         BaseCode : SP_POP_WRK28_S01 로 작업
  *==============================================================================
 *  관련 테이블
 * - [TB_SCH016] : (.R..) 밀롤/슬리터  작업지시
 * - [TB_WRK001] : (.R..) HL 생산실적 이력
 * - [TB_INV003] : (.R..) 자재투입 이력
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM         VARCHAR2(100) := 'SP_POP_WRK28_S01'; -- PROCEDURE NAME
    V_PLT_CD         VARCHAR2(2)   := '99';   --PLANTCODE TEST
    V_SESS_USER_ID   VARCHAR2(20)  := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리
    V_WRK_ORDR_NO           TB_WRK011.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO        TB_WRK011.WRK_ORDR_SEQNO%TYPE;
    V_ORDER_NO              TB_WRK011.ORDER_NO%TYPE;
    V_LOT_NO                TB_WRK011.LOT_NO%TYPE;
    V_MATNR                 TB_WRK011.MATNR%TYPE;
    V_MACH_STA              TB_WRK011.MACH_STA%TYPE;
    V_PRD_STR_DTM           TB_WRK011.PRD_STR_DTM%TYPE;
    V_IND_BCD               TB_INV003.IND_BCD%TYPE;

    V_COLINFO1      VARCHAR2(1000);  --컬럼설정1
    V_COLTYPE1      VARCHAR2(1000);  --컬럼설정1
    V_COLINFO2      VARCHAR2(1000);  --컬럼설정2
    V_COLTYPE2      VARCHAR2(1000);  --컬럼설정2
BEGIN
    BEGIN
        --투입정보(투입된 밀롤 정보)
        --예외 일 경우 WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO는 예외작업지시 정보 임 (투입작업지시 정보가 아님)
        BEGIN
            SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, MATNR, PRD_STR_DTM, MACH_STA, LOT_NO
              INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, V_MATNR, V_PRD_STR_DTM, V_MACH_STA, V_LOT_NO
              FROM TB_WRK011
             WHERE WERKS   = P_WERKS
               AND MACH_CD = P_MACH_CD;
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN 
                V_MACH_STA := 'N';
        END;
            
        RS_MACH_STA := V_MACH_STA;
        
        -- 밀롤 정보 구하기
        OPEN CUR_1 FOR   
        /* 슬리터 정상 */
        SELECT DISTINCT S016.WRK_ORDR_NO        --작업지지번호
               ,S016.WRK_ORDR_SEQNO             --작업지시순번
               ,S016.ORDER_NO                   --오더번호
               ,S016.PCODE                      --지종코드
               ,TO_CHAR(S016.BS_WGT, 'fm999,999,999,990') AS BS_WGT	 --밀롤 평량
               ,TO_CHAR(S016.MWIDTH, 'fm999,999,999,990') AS MWIDTH	 --밀롤 지폭
               ,S016.REMARK              --작업지시 비고
               ,S016.ORDER_RMK           --생산오더 비고
               ,I003.LOT_NO              --LOT NO(2개일수 있음)
               ,V_PRD_STR_DTM     AS PRD_STR_DTM        --생산시작일시(YYYYMMDDHH24MISS)
               ,V_MACH_STA        AS MACH_STA           --상태(R :가동, S:비가동, N:대기중)
          FROM TB_SCH016 S016,
               TB_INV003 I003 
         WHERE S016.WRK_ORDR_NO     = I003.WRK_ORDR_NO
           AND S016.WRK_ORDR_SEQNO  = I003.WRK_ORDR_SEQNO
           AND S016.WERKS           = I003.WERKS
           AND S016.WRK_ORDR_NO     = V_WRK_ORDR_NO
           AND S016.WRK_ORDR_SEQNO  = V_WRK_ORDR_SEQNO
           AND S016.WERKS           = P_WERKS
         UNION ALL
        /* 슬리터 예외   백업 : 2022-09-01 19:40 SP_POP_WRK28_S01_20 */
--        SELECT   NULL           AS WRK_ORDR_NO
--               , NULL           AS WRK_ORDR_SEQNO
--               , NULL           AS ORDER_NO
        SELECT   S020.WRK_ORDR_NO           AS WRK_ORDR_NO
               , S020.WRK_ORDR_SEQNO           AS WRK_ORDR_SEQNO
               , S020.ORDER_NO           AS ORDER_NO
               , I000.PCODE        PCODE            --지종
               , TO_CHAR(I000.BS_WGT, 'fm999,999,999,990') AS BS_WGT
               , TO_CHAR(I000.WLEN, 'fm999,999,999,990')   AS MWIDTH  --지폭
               , NULL           AS REMARK
               , NULL           AS ORDER_RMK
               , I000.LOT_NO       LOT_NO
               , V_PRD_STR_DTM  AS PRD_STR_DTM        --생산시작일시(YYYYMMDDHH24MISS)
               , V_MACH_STA     AS MACH_STA           --상태(R :가동, S:비가동, N:대기중)                   
          FROM (SELECT I003.WERKS, I003.MATNR, I003.LOT_NO, I003.WRK_ORDR_NO, I003.WRK_ORDR_SEQNO, M001.BS_WGT, M001.PCODE, M001.WLEN
                  FROM TB_INV003 I003
                     , TB_MAS001 M001
                 WHERE I003.WERKS   = M001.WERKS(+)
                   AND I003.MATNR   = M001.MATNR(+)
                   AND I003.WERKS   = P_WERKS
                   AND I003.MACH_CD = P_MACH_CD
                ) I000,
               TB_SCH020 S020
         WHERE I000.WERKS  = S020.WERKS
           --AND I000.MATNR  = S020.MATNR
           AND I000.LOT_NO = S020.LOT_NO
           AND I000.WRK_ORDR_NO = S020.WRK_ORDR_NO
           AND I000.WRK_ORDR_SEQNO = S020.WRK_ORDR_SEQNO
           AND I000.WRK_ORDR_NO    = V_WRK_ORDR_NO
           AND I000.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
           --AND S020.MATNR  = V_MATNR
           --AND S020.LOT_NO = V_LOT_NO
            ;

        --grid1 컬럼 정보 설정
        V_COLINFO1 := '밀롤바코드@C^230|투입권치수@C^160|오더번호@H|자재코드@H';
        V_COLTYPE1 := 'IND_BCD@varchar|ROLLCNT@varchar|ORDER_NO@varchar|MATNR@varchar';
        --컬럼설정 반환 테이블 작성
        OPEN CUR_2 FOR
        SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO1 || ',' || V_COLTYPE1, ',');

        --GRID1 데이터
        OPEN CUR_3 FOR
        -- 정상 TO_CHAR(I000.WLEN, 'fm999,999,999,990')
        SELECT IND_BCD   IND_BCD,               --밀롤 개별바코드
               TO_CHAR(ROLLCNT, 'fm999,999,999,990') AS ROLLCNT , --실적권치수
               V_ORDER_NO as ORDER_NO,          --오더번호
               MATNR     MATNR,                 --밀롤 자재코드
               LOT_NO    LOT_NO                 --밀롤LOTNO
          FROM TB_INV003
         WHERE WERKS          = P_WERKS
           AND MACH_CD        = P_MACH_CD
           AND WRK_ORDR_NO    = V_WRK_ORDR_NO
           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
           AND SUBSTR(V_WRK_ORDR_NO,1,4) <> 'WOEX'
           AND STCK_QTY       > 0
         UNION ALL
        -- 예외
        SELECT IND_BCD   IND_BCD,               --밀롤 개별바코드
               TO_CHAR(ROLLCNT, 'fm999,999,999,990') AS ROLLCNT ,  --실적권치수
               V_ORDER_NO as ORDER_NO,          --오더번호
               MATNR     MATNR,                 --밀롤 자재코드
               LOT_NO    LOT_NO                 --밀롤LOTNO
          FROM TB_INV003
         WHERE WERKS    = P_WERKS
           AND MACH_CD  = P_MACH_CD
           AND WRK_ORDR_NO    = V_WRK_ORDR_NO
           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
           AND SUBSTR(V_WRK_ORDR_NO,1,4) = 'WOEX'
--           AND LOT_NO   = V_LOT_NO
           AND STCK_QTY > 0 ;

        --grid2 컬럼 정보 설정
        V_COLINFO2 := '선택@C^40|구분@C^50|작업지시번호@C^200|순번@C^60|오더번호@C^100|지폭@C^80|실지폭@H|지폭순번@H|실적순서@H|계획권치수@C^90|실적권치수@C^90|폐품권치수@C^90|자재코드@C^200|보기@C^50|비고@L^100|작업시작일시@H|작업종료일시@H';
        V_COLTYPE2 := 'CHK@Button|GB@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|ORDER_NO@varchar|MWIDTH@varchar|R_WIDTH@varchar|WIDTH_NO@varchar|PRD_SEQ@varchar|MROLLCNT@varchar|PRD_MROLLCNT@varchar|DISPO_MROLLCNT@varchar|MATNR@varchar|DETAIL_BTN@Button|REMARK@varchar|PRD_STR_DATE@varchar|PRD_END_DATE@varchar';
        --컬럼설정 반환 테이블 작성
        OPEN CUR_4 FOR
        SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO2 || ',' || V_COLTYPE2, ',');

        --작업지시정보
        OPEN CUR_5 FOR
            SELECT
                   CHK             ,    --선택
                   GB              ,    --구분 
                   WRK_ORDR_NO     ,    --작업지시번호
                   WRK_ORDR_SEQNO  ,    --작업지시순번
                   ORDER_NO		   ,	 --오더번호
                   MWIDTH          ,	 --밀롤 지폭
                   R_WIDTH         ,    --실지폭
                   WIDTH_NO        ,    --지폭순번
                   PRD_SEQ         ,    --실적순서
                   MROLLCNT        ,	 --계획권치수
                   PRD_MROLLCNT    ,    --실적권치수
                   DISPO_MROLLCNT  ,    --실적권치수                  
                   MATNR           ,    --자재코드
                   DETAIL_BTN      ,    --상세정보
                   REMARK          ,    --비고
                   PRD_STR_DATE    ,
                   PRD_END_DATE    
            FROM
                (
                 /* 슬리터 정상 */
                 SELECT  'V'                                                CHK             ,    --선택
                         '계획'                                              GB              ,    --구분
                          S016.WRK_ORDR_NO                                  WRK_ORDR_NO     ,    --작업지시번호
                          S016.WRK_ORDR_SEQNO                               WRK_ORDR_SEQNO  ,    --작업지시순번
                          S016.ORDER_NO                                     ORDER_NO  		,	 --오더번호
                          TO_CHAR(S016.MWIDTH, 'fm999,999,999,990')         MWIDTH          ,	 --밀롤 지폭
                          ''                                                R_WIDTH         ,    --실지폭
                          ''                                                WIDTH_NO        ,    --지폭순번
                          ''                                                PRD_SEQ         ,    --실적순서
                          TO_CHAR(S016.MROLLCNT, 'fm999,999,999,990')       MROLLCNT        ,	 --계획권치수
                          TO_CHAR(W002.ROLLCNT, 'fm999,999,999,990')        PRD_MROLLCNT    ,    --실적권치수
                          TO_CHAR(W004.ROLLCNT, 'fm999,999,999,990')        DISPO_MROLLCNT  ,    --실적권치수                  
                          S016.MATNR                                        MATNR           ,    --자재코드
                          '버튼'                                             DETAIL_BTN      ,    --상세정보
                          S016.REMARK                                       REMARK          ,    --비고
                          TO_CHAR(W002.PRD_STR_DATE, 'YYYYMMDDHH24MISS')    PRD_STR_DATE    ,
                          TO_CHAR(W002.PRD_END_DATE, 'YYYYMMDDHH24MISS')    PRD_END_DATE    
                     FROM TB_SCH016 S016 
                           ,(SELECT W002.WERKS, W002.MACH_CD, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO
                                    , SUM(W002.ROLLCNT) ROLLCNT, MAX(PRD_STR_DATE) PRD_STR_DATE, MAX(PRD_END_DATE) PRD_END_DATE
                               FROM TB_WRK002 W002,
                                    TB_SCH016 S016
                              WHERE W002.WERKS = S016.WERKS(+)
                                AND W002.WRK_ORDR_NO = S016.WRK_ORDR_NO(+)
                                AND W002.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO(+)
                                AND W002.WERKS   = P_WERKS
                                AND W002.MACH_CD = P_MACH_CD
                                AND S016.PRE_ORDER_NO = V_ORDER_NO
                                AND S016.COMP_YN IN ('N', 'I')
                                AND NVL(W002.CNL_YN, 'N') = 'N'
                              GROUP BY W002.WERKS, W002.MACH_CD, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO) W002
                            
                           ,(SELECT W004.WERKS, W004.MACH_CD, W004.WRK_ORDR_NO, W004.WRK_ORDR_SEQNO
                                    , SUM(W004.ROLLCNT) ROLLCNT, MAX(PRD_STR_DATE) PRD_STR_DATE, MAX(PRD_END_DATE) PRD_END_DATE
                               FROM TB_WRK004 W004,
                                    TB_SCH016 S016
                              WHERE W004.WERKS = S016.WERKS(+)
                                AND W004.WRK_ORDR_NO = S016.WRK_ORDR_NO(+)
                                AND W004.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO(+)
                                AND W004.WERKS   = P_WERKS
                                AND W004.MACH_CD = P_MACH_CD
                                AND S016.PRE_ORDER_NO = V_ORDER_NO
                                AND S016.COMP_YN IN ( 'N', 'I')
                                AND NVL(W004.CNL_YN, 'N') = 'N'
                              GROUP BY W004.WERKS, W004.MACH_CD, W004.WRK_ORDR_NO, W004.WRK_ORDR_SEQNO) W004
                     WHERE 1=1
                       AND S016.WRK_ORDR_NO = W002.WRK_ORDR_NO(+)
                       AND S016.WRK_ORDR_SEQNO = W002.WRK_ORDR_SEQNO(+)
                       AND S016.WERKS = W002.WERKS(+)
                       AND S016.WRK_ORDR_NO = W004.WRK_ORDR_NO(+)
                       AND S016.WRK_ORDR_SEQNO = W004.WRK_ORDR_SEQNO(+)
                       AND S016.WERKS = W004.WERKS(+)
                       AND S016.WERKS = P_WERKS
                       AND S016.PRE_ORDER_NO = V_ORDER_NO
                       AND S016.COMP_YN IN ( 'N', 'I')
                   UNION ALL   
                  /* 슬리터 예외 */
                  SELECT  'V'                                               CHK             ,    --선택
                          '예외'                                             GB              ,    --구분
                          S019.WRK_ORDR_NO                                  WRK_ORDR_NO     ,    --작업지시번호
                          S019.WRK_ORDR_SEQNO                               WRK_ORDR_SEQNO  ,    --작업지시순번
                          S019.ORDER_NO                                     ORDER_NO        ,
                          NVL(TO_CHAR(S019.WLEN , 'fm999,999,999,990'), '0') MWIDTH          ,	 --밀롤 지폭
                          ''                                                R_WIDTH         ,    --실지폭
                          ''                                                WIDTH_NO        ,    --지폭순번
                          ''                                                PRD_SEQ         ,    --실적순서
                          NVL(TO_CHAR((S019.WRK_ORDR_QTY / (S019.BS_WGT/1000) / (S019.WLEN / 1000)) , 'fm999,999,999,990'), '0')       
                                                                            MROLLCNT        ,	 --계획권치수
                          TO_CHAR(NVL(W002.ROLLCNT,0), 'fm999,999,999,990') PRD_MROLLCNT    ,    --실적권치수
                          TO_CHAR(NVL(W004.ROLLCNT,0), 'fm999,999,999,990') DISPO_MROLLCNT  ,    --실적권치수                  
                          S019.MATNR                                        MATNR           ,    --자재코드
                          '버튼'                                             DETAIL_BTN      ,    --상세정보
                          NULL                                              REMARK          ,    --비고
                          TO_CHAR(W002.PRD_STR_DATE, 'YYYYMMDDHH24MISS')    PRD_STR_DATE    ,
                          TO_CHAR(W002.PRD_END_DATE, 'YYYYMMDDHH24MISS')    PRD_END_DATE
                     FROM TB_SCH019 S019 
                         ,(SELECT W002.WERKS, W002.MACH_CD, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO
                                   , SUM(W002.ROLLCNT) ROLLCNT, MAX(PRD_STR_DATE) PRD_STR_DATE, MAX(PRD_END_DATE) PRD_END_DATE
                             FROM TB_WRK002 W002,
                                  TB_SCH019 S019
                            WHERE W002.WERKS = S019.WERKS(+)
                              AND W002.WRK_ORDR_NO = S019.WRK_ORDR_NO(+)
                              AND W002.WRK_ORDR_SEQNO = S019.WRK_ORDR_SEQNO(+)
                              AND W002.WERKS   = P_WERKS
                              AND W002.MACH_CD = P_MACH_CD
                              AND S019.ORDER_NO = V_ORDER_NO
                              AND S019.COMP_YN IN ( 'N', 'I')
                              AND NVL(W002.CNL_YN,'N') = 'N'
                            GROUP BY W002.WERKS, W002.MACH_CD, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO) W002
                            
                         ,(SELECT W004.WERKS, W004.MACH_CD, W004.WRK_ORDR_NO, W004.WRK_ORDR_SEQNO
                                  , SUM(W004.ROLLCNT) ROLLCNT, MAX(PRD_STR_DATE) PRD_STR_DATE, MAX(PRD_END_DATE) PRD_END_DATE
                             FROM TB_WRK004 W004,
                                  TB_SCH019 S019
                            WHERE W004.WERKS = S019.WERKS(+)
                              AND W004.WRK_ORDR_NO = S019.WRK_ORDR_NO(+)
                              AND W004.WRK_ORDR_SEQNO = S019.WRK_ORDR_SEQNO(+)
                              AND W004.WERKS   = P_WERKS
                              AND W004.MACH_CD = P_MACH_CD
                              AND S019.ORDER_NO = V_ORDER_NO
                              AND S019.COMP_YN IN ( 'N', 'I')
                              AND NVL(W004.CNL_YN,'N') = 'N'
                            GROUP BY W004.WERKS, W004.MACH_CD, W004.WRK_ORDR_NO, W004.WRK_ORDR_SEQNO) W004                        
                     WHERE 1=1
                       AND S019.WRK_ORDR_NO    = W002.WRK_ORDR_NO(+)
                       AND S019.WRK_ORDR_SEQNO = W002.WRK_ORDR_SEQNO(+)
                       AND S019.WERKS          = W002.WERKS(+)
                       AND S019.WRK_ORDR_NO    = W004.WRK_ORDR_NO(+)
                       AND S019.WRK_ORDR_SEQNO = W004.WRK_ORDR_SEQNO(+)
                       AND S019.WERKS          = W004.WERKS(+)
                       AND S019.WERKS          = P_WERKS
                       AND S019.ORDER_NO       = V_ORDER_NO
                       AND S019.COMP_YN IN ( 'N', 'I')
            )
            ORDER BY ORDER_NO;
            
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
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
        --예외처리 종료
    END;
END;

/
