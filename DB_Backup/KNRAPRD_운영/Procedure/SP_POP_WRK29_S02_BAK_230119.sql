--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK29_S02_BAK_230119
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK29_S02_BAK_230119" 
(
     P_WERKS        IN VARCHAR2 
    ,P_MACH_CD      IN VARCHAR2 
    ,P_IND_BCD_M    IN VARCHAR2             
    --,P_ORDER_NO     IN VARCHAR2             
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
    ,CUR_3          OUT SYS_REFCURSOR    
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK29
 * PROGRAM NAME  : PS 수재단 주 작업 화면
 * VERSION       : 1.0.1
 * DESCRIPTION   : 그리드 클릭했을 때 상세정보 조회
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
  *==============================================================================
 *  관련 테이블
 * - [TB_SCH016] : (.R..) 제지 수재단 작업지시
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 * - [TB_WRK001] : (.R..) 설비별 현재 진행현황
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK29_S02';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
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
    V_PRD_STR_DTM           TB_WRK011.PRD_STR_DTM%TYPE;
    V_IND_BCD               TB_INV003.IND_BCD%TYPE;
    V_IN_QTY               TB_INV003.IN_QTY%TYPE;

    V_COLINFO VARCHAR2(1000);--컬럼설정1
    V_COLTYPE VARCHAR2(1000);--컬럼설정1

BEGIN
    BEGIN

        BEGIN 
            SELECT ORDER_NO
            INTO V_ORDER_NO
            FROM 
            (
                SELECT  SCH017.ORDER_NO   ORDER_NO, NULL LOT_NO
                 FROM  TB_WRK002 W002 
                    ,  TB_SCH017 SCH017
                 WHERE W002.WRK_ORDR_NO     = SCH017.WRK_ORDR_NO
                   AND W002.WRK_ORDR_SEQNO  = SCH017.WRK_ORDR_SEQNO
                   AND W002.WERKS           = P_WERKS
                   AND W002.IND_BCD         = P_IND_BCD_M 
             )      
             ;  
         EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     V_ORDER_NO := NULL ;      
         END ;

        BEGIN 
            SELECT LOT_NO, IN_QTY 
            INTO   V_LOT_NO, V_IN_QTY 
            FROM 
            (
               SELECT  W002.LOT_NO LOT_NO, V003.PRE_IN_QTY/500  IN_QTY
                 FROM  TB_INV001 W002 , TB_INV003 V003
                 WHERE W002.WERKS           = P_WERKS
                   AND W002.IND_BCD         = P_IND_BCD_M                 
                   AND W002.WERKS           = V003.WERKS
                   AND W002.IND_BCD         = V003.IND_BCD
             )      
             ;  
         EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     V_LOT_NO := NULL ;      
         END ;


         IF V_ORDER_NO IS NULL THEN
            SELECT  V001.ORDER_NO
               INTO V_ORDER_NO
             FROM  TB_INV001 V001
             WHERE V001.WERKS           = P_WERKS
               AND V001.IND_BCD         = P_IND_BCD_M 
               AND ROWNUM =1 
             ;  

         END IF;


        --재단 작업지시번호 순번  -> 실적량  폐품량 실적연수량  폐품연수량 
        OPEN CUR_1 FOR
        SELECT  DISTINCT 
                W002.LOT_NO                                                 LOT_NO        --수재단바코드 
               ,W002.MACHINE                                           MACHINE       --생산호기  
               ,P_MACH_CD                                                   MACH_CD       --생산설비
               ,(SELECT MAS012.MACH_NM  
                   FROM TB_MAS012 MAS012 
                  WHERE W002.MACH_CD = MAS012.MACH_CD
                 )                                                          MACH_NM       --생산설비
               ,W002.MATNR	                                                MATNR         --자재코드
               ,W002.RMK	                                                RMK           --비고     
               ,W002.PCNT	                                                PCNT          --연수
               ,/*( SELECT SUM(IN_QTY)
                  FROM TB_INV003 INV003
                  WHERE W002.WERKS           = INV003.WERKS           
                    AND W002.WRK_ORDR_NO     = INV003.WRK_ORDR_NO
                )*/ W002.WGT	                                                WGT           --중량
               ,W002.TO_MACHINE	                                            TO_MACHINE    --이동호기
               ,NULL                                                PCODE         --지종
               ,NULL                                                PCODE_NM      --지종명               
               ,NULL                                               BS_WGT        --평량
               ,VLEN                                                 VLEN          --세로
               ,WLEN                                                 WLEN          --가로
               ,NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = W002.REGID),'')     REGNAME       --등록자   
               ,W002.ORDER_NO                                               ORDER_NO    
         FROM  TB_WRK002 W002 
         WHERE  W002.WERKS           = P_WERKS
           AND  W002.IND_BCD         = P_IND_BCD_M     
           AND NVL(W002.CNL_YN,'N')  = 'N' 
        UNION ALL   
        SELECT  DISTINCT 
                W002.LOT_NO                                                 LOT_NO        --수재단바코드 
               ,W002.MACHINE                                           MACHINE       --생산호기  
               ,P_MACH_CD                                                   MACH_CD       --생산설비
               ,(SELECT MAS012.MACH_NM  
                   FROM TB_MAS012 MAS012 
                  WHERE W002.MACH_CD = MAS012.MACH_CD
                 )                                                          MACH_NM       --생산설비
               ,W002.MATNR	                                                MATNR         --자재코드
               ,NULL	                                                    RMK           --비고     
               ,W002.STCK_QTY	                                            PCNT          --연수
               ,W002.WGT	                                                WGT           --중량
               ,NULL	                                            TO_MACHINE    --이동호기
               ,(SELECT MAS001.PCODE 
                 FROM TB_MAS001 MAS001 
                 WHERE MAS001.MATNR = W002.MATNR AND MAS001.WERKS =  W002.WERKS)        PCODE         --지종
               ,(SELECT MAS001.PCODE_NM 
                 FROM TB_MAS001 MAS001 
                 WHERE MAS001.MATNR = W002.MATNR AND MAS001.WERKS =  W002.WERKS)        PCODE_NM      --지종명               
               ,W002.BS_WGT                                               BS_WGT        --평량
               ,(SELECT MAS001.VLEN 
                 FROM TB_MAS001 MAS001 
                 WHERE MAS001.MATNR = W002.MATNR AND MAS001.WERKS =  W002.WERKS)    VLEN          --세로
               ,(SELECT MAS001.WLEN 
                 FROM TB_MAS001 MAS001 
                 WHERE MAS001.MATNR = W002.MATNR AND MAS001.WERKS =  W002.WERKS)   WLEN          --가로
               ,NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = W002.REGID),'')     REGNAME       --등록자   
               ,W002.ORDER_NO                                               ORDER_NO    
         FROM  TB_INV001 W002 
         WHERE W002.WERKS           = P_WERKS
           AND W002.IND_BCD         = P_IND_BCD_M 
           --AND NVL(W002.CNL_YN,'N') = 'N' 
           ;

        V_COLINFO := '선택@C^40|구분@C^50|작업지시번호@C^170|순번@C^60|자재번호@C^200|평량@C^80|가로@C^80|세로@C^80|계획연수@C^80|팔레트당연수@C^100|실적연수@C^80|폐품연수@C^80|실적일자@C^80|내수@C^50|포장타입@C^80|보기@C^50|판매처@C^100|지종명@C200|비고@L^100|작업시작일시@H|작업종료일시@H';
        V_COLTYPE := 'CHK@Button|GB@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|MATNR@varchar|BS_WGT@varchar|WLEN@varchar|VLEN@varchar|WRK_ORDR_QTY@varchar|PLT_PER_CNT@varchar|PCNT@varchar|DISPO_QTY@varchar|PRFM_DT@varchar|DOMESTIC@varchar|PACKTYPE@varchar|DETAIL_BTN@Button|KUNNRT@varchar|PCODE_NM@varchar|REMARK@varchar|PRD_STR_DATE@varchar|PRD_END_DATE@varchar';

        OPEN CUR_2 FOR
        SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO || ',' || V_COLTYPE, ',');

        --작업지시정보
        OPEN CUR_3 FOR
            SELECT DISTINCT
                 'V'                                                  CHK,                --선택
                 '계획'                                                GB,                 --구분
                  S017.WRK_ORDR_NO                                      WRK_ORDR_NO,        --작업지시번호
                  S017.WRK_ORDR_SEQNO                                   WRK_ORDR_SEQNO,     --작업지시순번
                  S017.MATNR                                            MATNR,              --자재번호
                  NVL(RTRIM(TO_CHAR(S017.BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')   BS_WGT,	--평량
                  NVL(RTRIM(TO_CHAR(S017.WLEN, 'fm999,999,999,999,990.999'), '.'), '0')   WLEN,     --가로
                  NVL(RTRIM(TO_CHAR(S017.VLEN, 'fm999,999,999,999,990.999'), '.'), '0')   VLEN,     --가로
                  NVL(RTRIM(TO_CHAR(S017.WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0')   WRK_ORDR_QTY,     --계획연수
                  --NVL(RTRIM(TO_CHAR(V_IN_QTY, 'fm999,999,999,999,990.999'), '.'), '0')   WRK_ORDR_QTY,     --투입연수
                  NVL(RTRIM(TO_CHAR(S017.PLT_PER_CNT, 'fm999,999,999,999,990.999'), '.'), '0')   PLT_PER_CNT,     --팔레트당연수
                  NVL(RTRIM(TO_CHAR(SUM(W002.PCNT), 'fm999,999,999,999,990.999'), '.'), '0')   PCNT,     --실적연수
                  NVL(RTRIM(TO_CHAR(SUM(W004.DISPO_QTY), 'fm999,999,999,999,990.999'), '.'), '0')   DISPO_QTY,     --폐품연수
                  W002.PRFM_DT                                           PRFM_DT,           --실적일자 
                  CASE WHEN NVL(MAS001.DOMESTIC,'Y')= 'Y'  THEN  '내수'
                       ELSE                                      '외자' 
                  END                                                    DOMESTIC,          --내수구분
                  FN_CMCDV ('PACK_TYPE', S017.PACKTYPE) 	             PACKTYPE,          --포장타입
                  '버튼'                                                  DETAIL_BTN,        --상세정보
                  S017.KUNNRT                                             KUNNRT,            --판매처명   
                  MAS001.PCODE_NM                                         PCODE_NM,      --지종명                                 
                  S017.WRK_ORDR_RMK                                       REMARK,           --비고
                  TO_CHAR(W002.PRD_STR_DATE, 'YYYYMMDDHH24MISS')          PRD_STR_DATE,
                  TO_CHAR(W002.PRD_END_DATE, 'YYYYMMDDHH24MISS')          PRD_END_DATE
                  FROM TB_SCH017 S017 
                     , TB_MAS001 MAS001 
                 --    , TB_WRK002 K002
                       ,(SELECT W002.WERKS, W002.MACH_CD, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO
                                , SUM(W002.PCNT) PCNT
                                , MAX(PRD_STR_DATE) PRD_STR_DATE
                                , MAX(PRD_END_DATE) PRD_END_DATE
                                , MAX(PRFM_DT)      PRFM_DT
                           FROM TB_WRK002 W002,
                                TB_SCH017 S017
                         WHERE W002.WERKS = S017.WERKS
                           AND W002.WRK_ORDR_NO = S017.WRK_ORDR_NO
                           AND W002.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO
                           AND S017.WERKS = P_WERKS
                           AND S017.PRE_ORDER_NO = V_ORDER_NO
                           --AND COMP_YN IN ( 'N', 'I')
                           AND S017.MAN_CUT_YN = 'X'
                           AND NVL(CNL_YN,'N')    = 'N'
                        GROUP BY W002.WERKS, W002.MACH_CD, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO) W002
                       ,(SELECT W004.WERKS, W004.MACH_CD, W004.WRK_ORDR_NO, W004.WRK_ORDR_SEQNO
                                , SUM(W004.DISPO_QTY) DISPO_QTY
                           FROM TB_WRK004 W004,
                                TB_SCH017 S017
                         WHERE W004.WERKS = S017.WERKS
                           AND W004.WRK_ORDR_NO = S017.WRK_ORDR_NO
                           AND W004.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO
                           AND S017.WERKS = P_WERKS
                           AND S017.PRE_ORDER_NO = V_ORDER_NO
                           --AND COMP_YN IN ( 'N', 'I')
                           AND MAN_CUT_YN = 'X'
                           AND NVL(CNL_YN,'N')    = 'N'
                        GROUP BY W004.WERKS, W004.MACH_CD, W004.WRK_ORDR_NO, W004.WRK_ORDR_SEQNO) W004                        
             WHERE 1=1
               AND S017.WERKS = W002.WERKS(+)
               AND S017.WRK_ORDR_NO = W002.WRK_ORDR_NO(+)
               AND S017.WRK_ORDR_SEQNO = W002.WRK_ORDR_SEQNO(+)
               AND S017.WERKS = W004.WERKS(+)
               AND S017.WRK_ORDR_NO = W004.WRK_ORDR_NO(+)
               AND S017.WRK_ORDR_SEQNO = W004.WRK_ORDR_SEQNO(+)
               AND S017.WERKS   = MAS001.WERKS
               AND S017.MATNR   = MAS001.MATNR
               AND S017.WERKS           = P_WERKS       
               AND S017.PRE_ORDER_NO    = V_ORDER_NO  
               AND S017.DUMMY_KEY  = P_IND_BCD_M
               --AND COMP_YN IN ( 'N', 'I')
               AND MAN_CUT_YN = 'X'
               --AND (W002.PCNT > 0 OR W004.DISPO_QTY > 0)

               GROUP BY
                   S017.WRK_ORDR_NO     
                  ,S017.WRK_ORDR_SEQNO  
                  ,S017.MATNR           
                  ,NVL(RTRIM(TO_CHAR(S017.BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                  ,NVL(RTRIM(TO_CHAR(S017.WLEN, 'fm999,999,999,999,990.999'), '.'), '0')  
                  ,NVL(RTRIM(TO_CHAR(S017.VLEN, 'fm999,999,999,999,990.999'), '.'), '0')  
                  ,NVL(RTRIM(TO_CHAR(S017.WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0')        --계획연수
                  ,NVL(RTRIM(TO_CHAR(S017.PLT_PER_CNT, 'fm999,999,999,999,990.999'), '.'), '0')
                  ,W002.PRFM_DT                          
                  ,NVL(MAS001.DOMESTIC,'Y')
                  ,FN_CMCDV ('PACK_TYPE', S017.PACKTYPE)
                  ,S017.KUNNRT    
                  ,MAS001.PCODE_NM 
                  ,S017.WRK_ORDR_RMK
                  ,TO_CHAR(W002.PRD_STR_DATE, 'YYYYMMDDHH24MISS')  
                  ,TO_CHAR(W002.PRD_END_DATE, 'YYYYMMDDHH24MISS')  
           UNION ALL
            SELECT DISTINCT
                 'V'                                                  CHK,                --선택
                 '예외'                                                GB,                 --구분
                  S019.WRK_ORDR_NO                                      WRK_ORDR_NO,        --작업지시번호
                  S019.WRK_ORDR_SEQNO                                   WRK_ORDR_SEQNO,     --작업지시순번
                  S019.MATNR                                            MATNR,              --자재번호
                  NVL(RTRIM(TO_CHAR(S019.BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')   BS_WGT,	--평량
                  NVL(RTRIM(TO_CHAR(S019.WLEN, 'fm999,999,999,999,990.999'), '.'), '0')   WLEN,     --가로
                  NVL(RTRIM(TO_CHAR(S019.VLEN, 'fm999,999,999,999,990.999'), '.'), '0')   VLEN,     --가로
                  NVL(RTRIM(TO_CHAR(S019.WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0')   WRK_ORDR_QTY,     --계획연수
                  NVL(RTRIM(TO_CHAR(S019.PLT_PER_CNT, 'fm999,999,999,999,990.999'), '.'), '0')   PLT_PER_CNT,     --팔레트당연수
                  --TO_CHAR(S019.PLT_PER_CNT, 'fm999,999,999,990.099')       PLT_PER_CNT,        --팔레트당연수
                  --TO_CHAR(S017.PCNT, 'fm999,999,999,990')               PCNT,               -- 계획연수
                  TO_CHAR(W002.PCNT, 'fm999,999,999,990.099')               PCNT,               -- 실적연수
                  TO_CHAR(W004.DISPO_QTY, 'fm999,999,999,990.099')           DISPO_QTY,         -- 폐품연수
                  W002.PRFM_DT                                           PRFM_DT,           --실적일자 
                  CASE WHEN NVL(MAS001.DOMESTIC,'Y')= 'Y'  THEN  '내수'
                       ELSE                                      '외자' 
                  END                                                    DOMESTIC,          --내수구분
                  FN_CMCDV ('PACK_TYPE', S019.PACKTYPE) 	             PACKTYPE,          --포장타입
                  '버튼'                                                  DETAIL_BTN,        --상세정보
--                  S019.PCODE                                              PCODE,  --지종
                  S019.KUNNRT                                             KUNNRT,            --판매처명   
                  MAS001.PCODE_NM                                         PCODE_NM,      --지종명               
                  S019.WRK_ORDR_REMARK                                    REMARK,           --비고
                  TO_CHAR(W002.PRD_STR_DATE, 'YYYYMMDDHH24MISS')          PRD_STR_DATE,
                  TO_CHAR(W002.PRD_END_DATE, 'YYYYMMDDHH24MISS')          PRD_END_DATE
                  FROM TB_SCH019 S019 ,TB_SCH020 S020 , TB_MAS001 MAS001 , TB_WRK011  K011
                       ,(SELECT W002.WERKS, W002.MACH_CD, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO
                                , SUM(W002.PCNT) PCNT
                                , MAX(PRD_STR_DATE) PRD_STR_DATE
                                , MAX(PRD_END_DATE) PRD_END_DATE
                                , MAX(PRFM_DT)      PRFM_DT
                           FROM TB_WRK002 W002,
                                TB_SCH019 S019
                         WHERE W002.WERKS = S019.WERKS(+)
                           AND W002.WRK_ORDR_NO = S019.WRK_ORDR_NO(+)
                           AND W002.WRK_ORDR_SEQNO = S019.WRK_ORDR_SEQNO(+)
                           AND S019.WERKS = P_WERKS
                           --AND S019.ORDER_NO = V_ORDER_NO
                           AND NVL(COMP_YN,'N') IN ( 'N', 'I')
                           AND NVL(CNL_YN,'N')    = 'N'
                        GROUP BY W002.WERKS, W002.MACH_CD, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO) W002
                       ,(SELECT W004.WERKS, W004.MACH_CD, W004.WRK_ORDR_NO, W004.WRK_ORDR_SEQNO
                                , SUM(W004.DISPO_QTY) DISPO_QTY
                           FROM TB_WRK004 W004,
                                TB_SCH019 S019
                         WHERE W004.WERKS = S019.WERKS(+)
                           AND W004.WRK_ORDR_NO = S019.WRK_ORDR_NO(+)
                           AND W004.WRK_ORDR_SEQNO = S019.WRK_ORDR_SEQNO(+)
                           AND S019.WERKS = P_WERKS
                           --AND S019.ORDER_NO = V_ORDER_NO
                           AND NVL(COMP_YN,'N') IN ( 'N', 'I')
                           AND NVL(CNL_YN,'N')    = 'N'
                        GROUP BY W004.WERKS, W004.MACH_CD, W004.WRK_ORDR_NO, W004.WRK_ORDR_SEQNO) W004                        
             WHERE 1=1
               AND S019.WERKS = W002.WERKS(+)
               AND S019.WRK_ORDR_NO = W002.WRK_ORDR_NO(+)
               AND S019.WRK_ORDR_SEQNO = W002.WRK_ORDR_SEQNO(+)
               AND S019.WERKS = W004.WERKS(+)
               AND S019.WRK_ORDR_NO = W004.WRK_ORDR_NO(+)
               AND S019.WRK_ORDR_SEQNO = W004.WRK_ORDR_SEQNO(+)
               AND S019.WERKS   = MAS001.WERKS(+)
               AND S019.MATNR   = MAS001.MATNR(+)
               AND S019.WRK_ORDR_NO = S020.WRK_ORDR_NO
               AND S019.WRK_ORDR_SEQNO = S020.WRK_ORDR_SEQNO
               AND S020.WERKS           = K011.WERKS 
               AND S020.ORDER_NO        = K011.ORDER_NO 
               AND S020.LOT_NO          = K011.LOT_NO 
               AND K011.WERKS           = P_WERKS       
               AND K011.MACH_CD         = P_MACH_CD       
               AND S020.LOT_NO          = V_LOT_NO  
               --AND S020.LOT_NO          = V_LOT_NO   
               AND NVL(S019.COMP_YN,'N') IN ( 'N', 'I')
               --AND S019.ORDER_DIV IN (select CMCDVL from CMCDV WHERE USARG2 = 'Y' ) 
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
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;
        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END;

/
