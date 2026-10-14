--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK27_S01_V02_BAK
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK27_S01_V02_BAK" 
(
     P_WERKS         IN VARCHAR2 
    ,P_MACH_CD      IN VARCHAR2 
    ,RS_MACH_STA    OUT VARCHAR2    --가동상태(R :가동, S:비가동, N:대기중)
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
    ,CUR_3          OUT SYS_REFCURSOR
    ,CUR_4          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK27
 * PROGRAM NAME  : PS 포장 주 작업 화면
 * VERSION       : 1.0.1
 * DESCRIPTION   : 투입정보와 작업지시정보 조회
 *                 
 * AUTHOR NAME   : 박충식
 * CREATE DATE   : 2022/06/23
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/06/23    1.0.0   박충식         Initial Version
  *==============================================================================
 *  관련 테이블
 * - [] : (.R..) 
 * - [] : (.R..) 
 * - [] : (.R..) 
 * - [] : (.R..) 
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK27_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리

    V_WRK_ORDR_NO           TB_WRK011.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO        TB_WRK011.WRK_ORDR_SEQNO%TYPE;
    V_MATNR                 TB_WRK011.MATNR%TYPE;
    V_MACH_STA              TB_WRK011.MACH_STA%TYPE;
    V_PRD_STR_DTM           TB_WRK011.PRD_STR_DTM%TYPE;
    V_IND_BCD               TB_INV003.IND_BCD%TYPE;
    V_MWIDTH                TB_SCH016.MWIDTH%TYPE;
    V_COLINFO1 VARCHAR2(1000);--컬럼설정1
    V_COLTYPE1 VARCHAR2(1000);--컬럼설정1
--    V_WRK_CD VARCHAR2(8);--설비별 작업장코드

    V_ORDER_NO              TB_SCH017.ORDER_NO%TYPE;    --판매오더  
    V_ORDER_NO_P              TB_SCH017.ORDER_NO%TYPE;    --판매오더  
    V_LOT_NO              TB_SCH020.LOT_NO%TYPE;    --  
    V_BS_WGT                TB_MAS001.BS_WGT%TYPE;      --평량  
    V_MATNR_SPEC            TB_MAS001.MATNR_SPEC%TYPE;  --규격     

    V_WRK_ORDR_NO_P           TB_WRK011.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO_P        TB_WRK011.WRK_ORDR_SEQNO%TYPE;
    V_PROC_CD                 VARCHAR(2);
    V_VISIBLE                 VARCHAR(1);

BEGIN
    BEGIN
        --투입정보(투입된 재단 정보)
        SELECT WRK_ORDR_NO       --작업지시번호
             , WRK_ORDR_SEQNO    --작업지시 순번
             , ORDER_NO          --오더번호    
             , MATNR             --자재코드
             , PRD_STR_DTM       --작업시작일시
             , MACH_STA          --상태(R :가동, S:비가동)
             , LOT_NO
          INTO V_WRK_ORDR_NO      --작업지시번호
             , V_WRK_ORDR_SEQNO   --작업지시 순번
             , V_ORDER_NO         --오더번호     
             , V_MATNR            --자재코드
             , V_PRD_STR_DTM      --작업시작일시
             , V_MACH_STA         ----상태(R :가동, S:비가동)
             , V_LOT_NO
          FROM TB_WRK011   --작업장(설비)별 현재 진행현황
         WHERE WERKS   = P_WERKS     --플랜트
           AND MACH_CD = P_MACH_CD
           AND ROWNUM = 1 ;  --작업장코드(설비코드)

        --2022.10.26 한동규 추가
        RS_MACH_STA := V_MACH_STA;

        OPEN CUR_1 FOR   
        SELECT SCH017.ORDER_NO                           ORDER_NO           --오더번호
             , SCH017.VBELN                              VBELN          --판매문서  
             , SCH017.POSNR                              POSNR              --판매문서 항목번호
             , MAS001.BS_WGT                             BS_WGT             --규격
             , MAS001.MATNR_SPEC                         MATNR_SPEC         --평량
             , SCH017.WLEN                               WLEN               --가로길이
             , SCH017.VLEN                               VLEN               --세로길이
             , SCH017.WRK_ORDR_NO                        WRK_ORDR_NO        --작업지시번호
             , SCH017.WRK_ORDR_SEQNO                     WRK_ORDR_SEQNO     --작업지시순번    
          FROM TB_SCH017  SCH017  --작업지시 재단
             , TB_MAS001  MAS001  --플랜트별 제품/자재 마스터
         WHERE SCH017.WRK_ORDR_NO    = V_WRK_ORDR_NO
--           AND SCH017.WRK_ORDR_SEQNO  = V_WRK_ORDR_SEQNO
           AND SCH017.WERKS   = MAS001.WERKS
           AND SCH017.MATNR   = MAS001.MATNR
           AND SCH017.WERKS           = P_WERKS
           AND SCH017.ORDER_NO        = V_ORDER_NO 
           AND SCH017.USE_YN ='Y'
       UNION ALL    
        SELECT SCH019.ORDER_NO                           ORDER_NO           --오더번호
             , SCH019.VBELN                              VBELN          --판매문서  
             , SCH019.POSNR                              POSNR              --판매문서 항목번호
             , MAS001.BS_WGT                             BS_WGT             --규격
             , MAS001.MATNR_SPEC                         MATNR_SPEC         --평량
             , SCH019.WLEN                               WLEN               --가로길이
             , SCH019.VLEN                               VLEN               --세로길이
             , SCH019.WRK_ORDR_NO                        WRK_ORDR_NO        --작업지시번호
             , SCH019.WRK_ORDR_SEQNO                     WRK_ORDR_SEQNO     --작업지시순번    
          FROM TB_SCH019  SCH019  --작업지시 재단
             , TB_MAS001  MAS001  --플랜트별 제품/자재 마스터
         WHERE /*SCH019.WRK_ORDR_NO    = V_WRK_ORDR_NO
           AND SCH019.WRK_ORDR_SEQNO  = V_WRK_ORDR_SEQNO
           AND*/ SCH019.WERKS   = MAS001.WERKS
           AND SCH019.MATNR   = MAS001.MATNR
           AND SCH019.WERKS           = P_WERKS
           AND SCH019.ORDER_NO        = V_ORDER_NO 
           AND SCH019.USE_YN ='Y'
           ;        

        SELECT PROC_CD
        INTO   V_PROC_CD
        FROM TB_MAS012
        WHERE MACH_CD = P_MACH_CD
        AND ROWNUM = 1;

        IF V_PROC_CD  = 'ZA'  THEN
           V_VISIBLE := '1';  -- 문제제품적재소
        ELSE
           V_VISIBLE := '0';
        END IF ;
        IF  V_VISIBLE = '1'  THEN
            V_COLINFO1 := '선택@C^40|재단개별바코드@C^170|재단 LOT 번호@C^150|투입연수@C^80|사용연수@C^80|폐품연수@C^80|가용연수@C^80|부적합연수@C^90|실적중량@H|사용중량@H|폐품중량@H|가용중량@H|오더번호@H|자재코드@H|작업지시번호@H|작업지시순번@H|포장작업지시번호@H|포장작업지시순번@H';
        ELSE
            V_COLINFO1 := '선택@C^40|재단개별바코드@C^180|재단 LOT 번호@C^170|투입연수@C^90|사용연수@C^90|폐품연수@C^90|가용연수@C^90|부적합연수@H|실적중량@H|사용중량@H|폐품중량@H|가용중량@H|오더번호@H|자재코드@H|작업지시번호@H|작업지시순번@H|포장작업지시번호@H|포장작업지시순번@H';
        END IF ;
        --grid1 컬럼 정보 설정
        --V_COLINFO1 := '선택@C^40|재단개별바코드@C^170|재단 LOT 번호@C^140|실적연수@C^80|사용연수@C^80|폐품연수@C^80|가용연수@C^80|부적합연수@C^90|실적중량@H|사용중량@H|폐품중량@H|가용중량@H|오더번호@H|자재코드@H|작업지시번호@H|작업지시순번@H|포장작업지시번호@H|포장작업지시순번@H';
        --V_COLINFO1 := '선택@C^40|재단개별바코드@C^180|재단 LOT 번호@C^170|실적연수@C^90|사용연수@C^90|폐품연수@C^90|가용연수@C^90|부적합연수@C^90|실적중량@H|사용중량@H|폐품중량@H|가용중량@H|오더번호@H|자재코드@H|작업지시번호@H|작업지시순번@H|포장작업지시번호@H|포장작업지시순번@H';
        V_COLTYPE1 := 'CHK@Button|IND_BCD@varchar|LOT_NO@varchar|IN_QTY@varchar|USE_QTY@varchar|DISPO_QTY@varchar|ABLE_QTY@varchar|UCFMTY_AMT@varchar|IN_WGT@varchar|USE_WGT@varchar|DISPO_WGT@varchar|ABLE_WGT@varchar|ORDER_NO@varchar|MATNR@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|PC_WRK_ORDR_NO@varchar|PC_WRK_ORDR_SEQNO@varchar';
        --컬럼설정 반환 테이블 작성
        OPEN CUR_2 FOR
        SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO1 || ',' || V_COLTYPE1, ',');

       /* 
        BEGIN
            SELECT AUFNR 
              INTO V_ORDER_NO_P --포장오더번호
            FROM TB_SCH009        --포장 이전
            WHERE WERKS   = P_WERKS
              AND FRAUFNR = V_ORDER_NO 
              AND DLFL  = 'N'
              AND ROWNUM =1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 V_ORDER_NO_P := '' ;
        END ;
      */

        BEGIN
            SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO
              INTO V_WRK_ORDR_NO_P, V_WRK_ORDR_SEQNO_P,V_ORDER_NO_P
            FROM TB_SCH018        --포장 이전
            WHERE WERKS   = P_WERKS
              AND ORDER_NO IN (
                                SELECT AUFNR 
                                  FROM TB_SCH009        --포장 이전
                                 WHERE WERKS   = P_WERKS
                                   AND FRAUFNR = V_ORDER_NO 
                                   AND DLFL  = 'N'
                              )
                              -- V_ORDER_NO_P 
              AND USE_YN ='Y'
              AND ROWNUM = 1 
              ;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 V_WRK_ORDR_NO_P  := '' ;
                 V_WRK_ORDR_SEQNO_P := 0 ;
        END ;

        IF  SUBSTR(P_MACH_CD,1,3) <> 'PPB'  THEN    --자동포장이 아니면
                --GRID1 데이터
                OPEN CUR_3 FOR
                SELECT    
                              CHK               --선택번튼
                             ,IND_BCD           --재단 바코드
                             ,LOT_NO            --재단 LOT_NO   
                             ,IN_QTY            --투입량
                             ,USE_QTY           --사용량               
                             ,DISPO_QTY         --폐품량                                                                                                       
                             ,ABLE_QTY          --가용량
                             ,UCFMTY_AMT        --부적합중량             
                             ,IN_WGT            --투입중량
                             ,USE_WGT           --사용중량               
                             ,DISPO_WGT         --폐품중량                                                                                                       
                             ,ABLE_WGT          --가용중량
                             ,ORDER_NO          --오더번호
                             ,MATNR             --재단 자재코드
                             ,WRK_ORDR_NO       --재단작업지시번호
                             ,WRK_ORDR_SEQNO    --재단작업지시순번
                             ,PC_WRK_ORDR_NO    --포장작업지시번호
                             ,PC_WRK_ORDR_SEQNO --포장작업지시순번 
                FROM 
                (
                            SELECT DISTINCT
                                    '-'                                                                                      CHK             --선택번튼
                                   ,I003.IND_BCD                                                                            IND_BCD         --재단 바코드
                                   ,I003.LOT_NO                                                                             LOT_NO          --재단 LOT_NO   
                                   ,ROUND(FN_CHG_UNIT (  I003.MATNR, P_WERKS, I003.UNIT, 'R', NVL(I003.IN_QTY,0)) ,3)       IN_QTY          --투입량
                                   ,ROUND(FN_CHG_UNIT (  I003.MATNR, P_WERKS, I003.UNIT, 'R', NVL(I003.USE_QTY,0)),3)       USE_QTY         --사용량               
                                   ,ROUND(FN_CHG_UNIT (  I003.MATNR, P_WERKS, I003.UNIT, 'R', NVL(I003.DISPO_QTY,0)),3)     DISPO_QTY       --폐품량                                                                                                       
                                   ,ROUND(FN_CHG_UNIT (  I003.MATNR, P_WERKS, I003.UNIT, 'R', NVL(I003.IN_QTY,0) - NVL(I003.USE_QTY,0)) , 3)
                                                                                                                            ABLE_QTY        --가용량
                                   ,ROUND(FN_CHG_UNIT (  I003.MATNR, P_WERKS, I003.UNIT, 'KG', NVL(I003.IN_QTY,0)) , 3)       IN_WGT          --투입중량
                                   ,ROUND(FN_CHG_UNIT (  I003.MATNR, P_WERKS, I003.UNIT, 'KG', NVL(I003.USE_QTY,0)) , 3)      USE_WGT         --사용중량               
                                   ,ROUND(FN_CHG_UNIT (  I003.MATNR, P_WERKS, I003.UNIT, 'KG', NVL(I003.DISPO_QTY,0)) , 3)    DISPO_WGT       --폐품중량                                                                                                       
                                   ,ROUND(FN_CHG_UNIT (  I003.MATNR, P_WERKS, I003.UNIT, 'KG', NVL(I003.IN_QTY,0) - NVL(I003.USE_QTY,0)) , 3) ABLE_WGT        --가용중량
                                   ,NVL(I001.UCFMTY_AMT,0) /500                                                             UCFMTY_AMT      --부적합중량                                                                                                                                                                                                
                                   ,V_ORDER_NO                                                                              ORDER_NO        --오더번호
                                   ,I003.MATNR                                                                              MATNR           --재단 자재코드
                                   ,I003.WRK_ORDR_NO                                                                        WRK_ORDR_NO     --재단작업지시번호
                                   ,I003.WRK_ORDR_SEQNO                                                                     WRK_ORDR_SEQNO  --재단작업지시순번
                                   ,V_WRK_ORDR_NO_P                                                                            PC_WRK_ORDR_NO  --포장작업지시번호
                                   ,V_WRK_ORDR_SEQNO_P                                                                             PC_WRK_ORDR_SEQNO --포장작업지시순번 
                              FROM TB_INV003 I003
                                 , TB_INV001 I001
                                 --, TB_SCH018 S018
                             WHERE 1=1
                               AND I003.WERKS            = I001.WERKS(+)
                               AND I003.IND_BCD          = I001.IND_BCD(+)
                               AND I003.WERKS            = P_WERKS
                               AND I003.MACH_CD          = P_MACH_CD
                               AND I003.WRK_ORDR_NO      = V_WRK_ORDR_NO
                               AND I003.WRK_ORDR_SEQNO   = V_WRK_ORDR_SEQNO
                               AND I003.STCK_QTY         > 0
                               AND ROUND(FN_CHG_UNIT (  I003.MATNR, P_WERKS, I003.UNIT, 'R', NVL(I003.IN_QTY,0) - NVL(I003.USE_QTY,0) ), 3) > 0
                               AND V_WRK_ORDR_NO_P is not null
                            /*UNION ALL
                            SELECT DISTINCT
                                    '-'                                                                                      CHK             --선택번튼
                                   ,I003.IND_BCD                                                                            IND_BCD         --재단 바코드
                                   ,I003.LOT_NO                                                                             LOT_NO          --재단 LOT_NO   
                                   ,NVL(I003.IN_QTY,0)        IN_QTY          --투입량
                                   ,NVL(I003.USE_QTY,0)       USE_QTY         --사용량               
                                   ,NVL(I003.DISPO_QTY,0)     DISPO_QTY       --폐품량                                                                                                       
                                   ,NVL(I003.IN_QTY,0) - NVL(I003.USE_QTY,0) 
                                                                                                                            ABLE_QTY        --가용량
                                   ,FN_CHG_UNIT (  I003.MATNR, P_WERKS, 'R', 'KG', NVL(I003.IN_QTY,0))                      IN_WGT          --투입중량
                                   ,FN_CHG_UNIT (  I003.MATNR, P_WERKS, 'R', 'KG', NVL(I003.USE_QTY,0))                     USE_WGT         --사용중량               
                                   ,FN_CHG_UNIT (  I003.MATNR, P_WERKS, 'R', 'KG', NVL(I003.DISPO_QTY,0))                  DISPO_WGT       --폐품중량                                                                                                       
                                   ,FN_CHG_UNIT (  I003.MATNR, P_WERKS, 'R', 'KG', NVL(I003.IN_QTY,0) - NVL(I003.USE_QTY,0))  ABLE_WGT      --가용중량
                                   ,NULL                                                                  UCFMTY_AMT      --부적합중량                                                                                                                                                                                                                   
                                   ,V_ORDER_NO                                                                              ORDER_NO        --오더번호
                                   ,I003.MATNR                                                                              MATNR           --재단 자재코드
                                   ,I003.WRK_ORDR_NO                                                                        WRK_ORDR_NO     --재단작업지시번호
                                   ,I003.WRK_ORDR_SEQNO                                                                     WRK_ORDR_SEQNO  --재단작업지시순번
                                   ,NULL                                                                         PC_WRK_ORDR_NO  --포장작업지시번호
                                   ,NULL                                                                      PC_WRK_ORDR_SEQNO --포장작업지시순번 
                              FROM TB_INV003 I003
                                 --, TB_INV001 I001
                                 , TB_SCH020 S020
                                 , TB_SCH019 S019
                             WHERE 1=1
                               --AND I003.WERKS            = I001.WERKS(+)
                               --AND I003.IND_BCD          = I001.IND_BCD(+)
                               AND I003.WERKS            = S020.WERKS
                               AND I003.LOT_NO           = S020.LOT_NO
                               AND S020.WRK_ORDR_NO      = S019.WRK_ORDR_NO
                               AND S020.WRK_ORDR_SEQNO   = S019.WRK_ORDR_SEQNO
                               AND I003.WERKS            = P_WERKS
                               AND I003.MACH_CD          = P_MACH_CD
                               AND I003.LOT_NO           = V_LOT_NO
                               AND NVL(I003.IN_QTY,0) - NVL(I003.USE_QTY,0)  > 0  
                               --AND S019.WRK_ORDR_NO IS NULL                       
                               */
                         )
                ORDER BY IND_BCD
                ;
        ELSE   --자동포장
                OPEN CUR_3 FOR
                SELECT    
                              CHK               --선택번튼
                             ,IND_BCD           --재단 바코드
                             ,LOT_NO            --재단 LOT_NO   
                             ,IN_QTY            --투입량
                             ,USE_QTY           --사용량               
                             ,DISPO_QTY         --폐품량                                                                                                       
                             ,ABLE_QTY          --가용량
                             ,UCFMTY_AMT        --부적합중량             
                             ,IN_WGT            --투입중량
                             ,USE_WGT           --사용중량               
                             ,DISPO_WGT         --폐품중량                                                                                                       
                             ,ABLE_WGT          --가용중량
                             ,ORDER_NO          --오더번호
                             ,MATNR             --재단 자재코드
                             ,WRK_ORDR_NO       --재단작업지시번호
                             ,WRK_ORDR_SEQNO    --재단작업지시순번
                             ,PC_WRK_ORDR_NO    --포장작업지시번호
                             ,PC_WRK_ORDR_SEQNO --포장작업지시순번 
                FROM 
                (
                            SELECT DISTINCT
                                    '-'                                                                                      CHK             --선택번튼
                                   ,I003.IND_BCD                                                                            IND_BCD         --재단 바코드
                                   ,I003.LOT_NO                                                                             LOT_NO          --재단 LOT_NO   
                                   ,ROUND(FN_CHG_UNIT (  I003.MATNR, P_WERKS, I003.UNIT, 'R', NVL(I003.IN_QTY,0)) ,3)       IN_QTY          --투입량
                                   ,ROUND(FN_CHG_UNIT (  I003.MATNR, P_WERKS, I003.UNIT, 'R', NVL(I003.USE_QTY,0)),3)       USE_QTY         --사용량               
                                   ,ROUND(FN_CHG_UNIT (  I003.MATNR, P_WERKS, I003.UNIT, 'R', NVL(I003.DISPO_QTY,0)),3)     DISPO_QTY       --폐품량                                                                                                       
                                   ,ROUND(FN_CHG_UNIT (  I003.MATNR, P_WERKS, I003.UNIT, 'R', NVL(I003.IN_QTY,0) - NVL(I003.USE_QTY,0)) , 3)
                                                                                                                            ABLE_QTY        --가용량
                                   ,ROUND(FN_CHG_UNIT (  I003.MATNR, P_WERKS, I003.UNIT, 'KG', NVL(I003.IN_QTY,0)) , 3)       IN_WGT          --투입중량
                                   ,ROUND(FN_CHG_UNIT (  I003.MATNR, P_WERKS, I003.UNIT, 'KG', NVL(I003.USE_QTY,0)) , 3)      USE_WGT         --사용중량               
                                   ,ROUND(FN_CHG_UNIT (  I003.MATNR, P_WERKS, I003.UNIT, 'KG', NVL(I003.DISPO_QTY,0)) , 3)    DISPO_WGT       --폐품중량                                                                                                       
                                   ,ROUND(FN_CHG_UNIT (  I003.MATNR, P_WERKS, I003.UNIT, 'KG', NVL(I003.IN_QTY,0) - NVL(I003.USE_QTY,0)) , 3) ABLE_WGT        --가용중량
                                   ,NVL(I001.UCFMTY_AMT,0) /500                                                             UCFMTY_AMT      --부적합중량                                                                                                                                                                                                
                                   ,V_ORDER_NO                                                                              ORDER_NO        --오더번호
                                   ,I003.MATNR                                                                              MATNR           --재단 자재코드
                                   ,I003.WRK_ORDR_NO                                                                        WRK_ORDR_NO     --재단작업지시번호
                                   ,I003.WRK_ORDR_SEQNO                                                                     WRK_ORDR_SEQNO  --재단작업지시순번
                                   ,V_WRK_ORDR_NO_P                                                                            PC_WRK_ORDR_NO  --포장작업지시번호
                                   ,V_WRK_ORDR_SEQNO_P                                                                             PC_WRK_ORDR_SEQNO --포장작업지시순번 
                              FROM TB_INV003 I003
                                 , TB_INV001 I001
                                 --, TB_SCH018 S018
                             WHERE 1=1
                               AND I003.WERKS            = I001.WERKS(+)
                               AND I003.IND_BCD          = I001.IND_BCD(+)
                               AND I003.WERKS            = P_WERKS
                               AND I003.MACH_CD          = P_MACH_CD
                               --AND I003.WRK_ORDR_NO      = V_WRK_ORDR_NO
                               --AND I003.WRK_ORDR_SEQNO   = V_WRK_ORDR_SEQNO
                               AND I003.MATNR           = V_MATNR
                               AND I003.STCK_QTY         > 0
                               AND ROUND(FN_CHG_UNIT (  I003.MATNR, P_WERKS, I003.UNIT, 'R', NVL(I003.IN_QTY,0) - NVL(I003.USE_QTY,0) ), 3) > 0
                               AND V_WRK_ORDR_NO_P is not null
                            /*
                            UNION ALL
                            SELECT DISTINCT
                                    '-'                                                                                      CHK             --선택번튼
                                   ,I003.IND_BCD                                                                            IND_BCD         --재단 바코드
                                   ,I003.LOT_NO                                                                             LOT_NO          --재단 LOT_NO   
                                   ,NVL(I003.IN_QTY,0)        IN_QTY          --투입량
                                   ,NVL(I003.USE_QTY,0)       USE_QTY         --사용량               
                                   ,NVL(I003.DISPO_QTY,0)     DISPO_QTY       --폐품량                                                                                                       
                                   ,NVL(I003.IN_QTY,0) - NVL(I003.USE_QTY,0) 
                                                                                                                            ABLE_QTY        --가용량
                                   ,FN_CHG_UNIT (  I003.MATNR, P_WERKS, 'R', 'KG', NVL(I003.IN_QTY,0))                      IN_WGT          --투입중량
                                   ,FN_CHG_UNIT (  I003.MATNR, P_WERKS, 'R', 'KG', NVL(I003.USE_QTY,0))                     USE_WGT         --사용중량               
                                   ,FN_CHG_UNIT (  I003.MATNR, P_WERKS, 'R', 'KG', NVL(I003.DISPO_QTY,0))                  DISPO_WGT       --폐품중량                                                                                                       
                                   ,FN_CHG_UNIT (  I003.MATNR, P_WERKS, 'R', 'KG', NVL(I003.IN_QTY,0) - NVL(I003.USE_QTY,0))  ABLE_WGT      --가용중량
                                   ,NULL                                                                UCFMTY_AMT      --부적합중량                                                                                                                                                                                                                   
                                   ,V_ORDER_NO                                                                              ORDER_NO        --오더번호
                                   ,I003.MATNR                                                                              MATNR           --재단 자재코드
                                   ,I003.WRK_ORDR_NO                                                                        WRK_ORDR_NO     --재단작업지시번호
                                   ,I003.WRK_ORDR_SEQNO                                                                     WRK_ORDR_SEQNO  --재단작업지시순번
                                   ,NULL                                                                         PC_WRK_ORDR_NO  --포장작업지시번호
                                   ,NULL                                                                      PC_WRK_ORDR_SEQNO --포장작업지시순번 
                              FROM TB_INV003 I003
                                 --, TB_INV001 I001
                                 , TB_SCH020 S020
                                 , TB_SCH019 S019
                             WHERE 1=1
                               --AND I003.WERKS            = I001.WERKS(+)
                               --AND I003.IND_BCD          = I001.IND_BCD(+)
                               AND I003.WERKS            = S020.WERKS
                               AND I003.LOT_NO           = S020.LOT_NO
                               AND S020.WRK_ORDR_NO      = S019.WRK_ORDR_NO
                               AND S020.WRK_ORDR_SEQNO   = S019.WRK_ORDR_SEQNO
                               AND I003.WERKS            = P_WERKS
                               AND I003.MACH_CD          = P_MACH_CD
                               AND I003.LOT_NO           = V_LOT_NO
                               --AND I003.MATNR           = V_MATNR
                               AND NVL(I003.IN_QTY,0) - NVL(I003.USE_QTY,0)  > 0  
                               --AND S019.WRK_ORDR_NO IS NULL                       
                               */
                         )
                ORDER BY IND_BCD
                ;

        END IF;

        --작업지시정보
        OPEN CUR_4 FOR
        SELECT '계획'                                    GB              --구분
             , S018.PCODE                               PCODE           --지종   
             , S001.PCODE_NM                            PCODE_NM        --지종명 
             , S018.IN_PER_CNT                          IN_PER_CNT      --속당매수
             , S018.SCNT                                SCNT            --속	
             , S018.MCNT                                MCNT            --매수
             , S018.MATNR                               MATNR           --자재번호
             , S018.WRK_ORDR_QTY                        WRK_ORDR_QTY    --계획정보R
             , S018.TOT_WGT                             TOT_WGT         --계획정보Kg
             , S018.PLT_PER_CNT                         PLT_PER_CNT     --팔레트당연수
             , S018.PRD_REQ_DT                          PRD_REQ_DT      --생산요청일자
             , FN_CD_VAL('PACK_TYPE', S018.PACKTYPE)    PACKTYPE_NM     --포장타입
             , S018.WRK_ORDR_NO                         WRK_ORDR_NO     --작업지시번호
             , S018.WRK_ORDR_SEQNO                      WRK_ORDR_SEQNO  --작업지시순번
             , (
                   SELECT  SUM(WRK002.PRFM_QTY)  PRFM_QTY
                   FROM TB_WRK002 WRK002
                   WHERE S018.WERKS = WRK002.WERKS
                     AND S018.WRK_ORDR_NO = WRK002.WRK_ORDR_NO
                     AND S018.WRK_ORDR_SEQNO = WRK002.WRK_ORDR_SEQNO
                     AND NVL(WRK002.CNL_YN,'N')  = 'N'
                )                                       PRD_QTY     --생산연수        
              , (
                   SELECT  SUM(WRK002.WGT)  PRD_WGT_QTY
                   FROM TB_WRK002 WRK002
                   WHERE S018.WERKS = WRK002.WERKS
                     AND S018.WRK_ORDR_NO = WRK002.WRK_ORDR_NO
                     AND S018.WRK_ORDR_SEQNO = WRK002.WRK_ORDR_SEQNO
                     AND NVL(WRK002.CNL_YN,'N')  = 'N'
                )                                       PRD_WGT_QTY    --생산중량                         
             , (
                   SELECT  SUM(WRK002.DISPO_QTY)  DISPO_QTY
                   FROM TB_WRK004 WRK002
                   WHERE S018.WERKS = WRK002.WERKS
                     AND S018.WRK_ORDR_NO = WRK002.WRK_ORDR_NO
                     AND S018.WRK_ORDR_SEQNO = WRK002.WRK_ORDR_SEQNO
                     AND NVL(WRK002.CNL_YN,'N')  = 'N'
                )                                       DISPO_QTY     --폐품연수
             , (
                   SELECT  SUM(WRK002.WGT)  DISPO_WGT_QTY
                   FROM TB_WRK004 WRK002
                   WHERE S018.WERKS = WRK002.WERKS
                     AND S018.WRK_ORDR_NO = WRK002.WRK_ORDR_NO
                     AND S018.WRK_ORDR_SEQNO = WRK002.WRK_ORDR_SEQNO
                     AND NVL(WRK002.CNL_YN,'N')  = 'N'
                )                                       DISPO_WGT_QTY   --폐품중량
          FROM TB_SCH018 S018   --포장
             , TB_MAS001 S001   --플랜트별 제품/자재 마스터 
         WHERE S018.WERKS = P_WERKS
           AND S018.MATNR  = S001.MATNR(+) 
           AND S018.WERKS  = S001.WERKS(+)
           AND S018.ORDER_NO IN (    SELECT AUFNR FROM TB_SCH009        --포장 이전
                                    WHERE FRAUFNR = V_ORDER_NO
                                      AND DLFL  = 'N'
                                    --AND   ROWNUM = 1
                                )
           AND S018.COMP_YN IN ('N', 'I')
           AND S018.USE_YN = 'Y'
       /*  UNION ALL
        SELECT '예외'                                    GB              --구분
             , S019.PCODE                               PCODE           --지종   
             , S001.PCODE_NM                            PCODE_NM        --지종명 
             , S019.IN_PER_CNT                          IN_PER_CNT      --속당매수
             , S019.SCNT                                SCNT            --속	
             , S019.MCNT                                MCNT            --매수
             , S019.MATNR                               MATNR           --자재번호
             , S019.WRK_ORDR_QTY                        WRK_ORDR_QTY    --계획정보R
             , FN_CHG_UNIT (  S019.MATNR, S019.WERKS, S019.UNIT, 'KG', NVL(S019.WRK_ORDR_QTY,0))
                                                        TOT_WGT         --Kg
             , S019.PLT_PER_CNT                         PLT_PER_CNT     --팔레트당연수
             , S019.PRD_REQ_DT                          PRD_REQ_DT      --생산요청일자
             , FN_CD_VAL('PACK_TYPE', S019.PACKTYPE)    PACKTYPE_NM     --포장타입
             , S019.WRK_ORDR_NO                         WRK_ORDR_NO     --작업지시번호
             , S019.WRK_ORDR_SEQNO                      WRK_ORDR_SEQNO  --작업지시순번
             , (
                   SELECT  SUM(WRK002.PRFM_QTY)  PRFM_QTY
                   FROM TB_WRK002 WRK002
                   WHERE S019.WERKS = WRK002.WERKS
                     AND S019.WRK_ORDR_NO = WRK002.WRK_ORDR_NO
                     AND S019.WRK_ORDR_SEQNO = WRK002.WRK_ORDR_SEQNO
                     AND NVL(WRK002.CNL_YN,'N')  = 'N'
                )                                       PRD_QTY
             , (
                   SELECT  SUM(WRK002.DISPO_QTY)  DISPO_QTY
                   FROM TB_WRK004 WRK002
                   WHERE S019.WERKS = WRK002.WERKS
                     AND S019.WRK_ORDR_NO = WRK002.WRK_ORDR_NO
                     AND S019.WRK_ORDR_SEQNO = WRK002.WRK_ORDR_SEQNO
                     AND NVL(WRK002.CNL_YN,'N')  = 'N'
                )                                       DISPO_QTY
          FROM TB_SCH019 S019   --예외포장
             , TB_MAS001 S001   --플랜트별 제품/자재 마스터 
         WHERE S019.WERKS = P_WERKS
           AND S019.MATNR  = S001.MATNR(+) 
           AND S019.WERKS  = S001.WERKS(+)
           AND S019.ORDER_NO = V_ORDER_NO
           AND S019.COMP_YN IN ('N', 'I')
           AND S019.USE_YN = 'Y'*/
           ;

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
