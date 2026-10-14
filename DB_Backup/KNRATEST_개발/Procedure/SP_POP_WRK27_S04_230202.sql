--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK27_S04_230202
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK27_S04_230202" 
(
     P_WERKS        IN  VARCHAR2
    ,P_ALL_SEARCH   IN VARCHAR2                 --Y:전체  N     N     
    ,P_MACH_CD      IN  VARCHAR2 
    ,P_WRK_LIST     IN  CLOB
    ,Lang           IN  VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK27
 * PROGRAM NAME  : PS 포장 주 작업 화면
 * VERSION       : 1.0.1
 * DESCRIPTION   : 투입정보와 작업지시정보 조회
 *
 * AUTHOR NAME   : 박충식
 * CREATE DATE   : 2022/07/28
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
 * 2022/01/09    1.0.2   김병무         자동포장도 SF포장과 동일하게 판매문서/품목으로 묶어서 실적등록 가능하게 수정
  *==============================================================================
 *  관련 테이블
 * - [] : (.R..) 
 * - [] : (.R..) 
 * - [] : (.R..) 
 * - [] : (.R..) 
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK27_S04';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리

    V_JSON              JSON_OBJECT_T;
    V_ARR_LIST          JSON_ARRAY_T;
    V_OBJ               JSON_OBJECT_T;

    V_SQL                   CLOB;
    V_WRK_ORDR_NO           TB_WRK011.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO        TB_WRK011.WRK_ORDR_SEQNO%TYPE;
    V_MATNR                 TB_WRK011.MATNR%TYPE;
    V_COLINFO1 VARCHAR2(1000);--컬럼설정1
    V_COLTYPE1 VARCHAR2(1000);--컬럼설정1
    V_ORDR_SQL              VARCHAR2(2000);
    V_NUM                   NUMBER(5) := 0; 
    V_PROC_CD                 VARCHAR(2);
    V_VISIBLE                 VARCHAR(1);

BEGIN
    BEGIN

            SELECT PROC_CD
            INTO   V_PROC_CD
            FROM TB_MAS012
            WHERE MACH_CD = P_MACH_CD;

            IF V_PROC_CD  = 'ZA'  THEN
               V_VISIBLE := '1';
            ELSE
               V_VISIBLE := '0';
            END IF ;

            --grid1 컬럼 정보 설정
            IF  V_VISIBLE = '1'  THEN
                V_COLINFO1 := '선택@C^40|재단개별바코드@C^170|재단 LOT 번호@C^150|실적연수@C^80|사용연수@C^80|폐품연수@C^80|가용연수@C^80|부적합연수@C^90|실적중량@H|사용중량@H|폐품중량@H|가용중량@H|오더번호@H|자재코드@H|작업지시번호@H|작업지시순번@H|포장작업지시번호@H|포장작업지시순번@H';
            ELSE
                V_COLINFO1 := '선택@C^40|재단개별바코드@C^180|재단 LOT 번호@C^170|실적연수@C^90|사용연수@C^90|폐품연수@C^90|가용연수@C^90|부적합연수@H|실적중량@H|사용중량@H|폐품중량@H|가용중량@H|오더번호@H|자재코드@H|작업지시번호@H|작업지시순번@H|포장작업지시번호@H|포장작업지시순번@H';
            END IF ;

            V_COLTYPE1 := 'CHK@Button|IND_BCD@varchar|LOT_NO@varchar|IN_QTY@varchar|USE_QTY@varchar|DISPO_QTY@varchar|ABLE_QTY@varchar|UCFMTY_AMT@varchar|IN_WGT@varchar|USE_WGT@varchar|DISPO_WGT@varchar|ABLE_WGT@varchar|ORDER_NO@varchar|MATNR@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|PC_WRK_ORDR_NO@varchar|PC_WRK_ORDR_SEQNO@varchar';
            --컬럼설정 반환 테이블 작성
            OPEN CUR_1 FOR
            SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO1 || ',' || V_COLTYPE1, ',');

            --GRID1 데이터
            OPEN CUR_2 FOR 
            SELECT NULL FROM DUAL WHERE ROWNUM = 0;

            V_JSON := JSON_OBJECT_T.parse(P_WRK_LIST);
            V_ARR_LIST := V_JSON.GET_ARRAY('list');
            V_ORDR_SQL := '';

            V_NUM := V_ARR_LIST.GET_SIZE ;
            IF V_NUM > 0  THEN
                    FOR I IN 0..V_ARR_LIST.GET_SIZE - 1 LOOP
                               V_OBJ := TREAT(V_ARR_LIST.GET(I) AS JSON_OBJECT_T);
                               V_OBJ := TREAT(V_OBJ.GET('map') AS JSON_OBJECT_T);

                               V_WRK_ORDR_NO    := V_OBJ.GET_STRING('WO_NO');          
                               V_WRK_ORDR_SEQNO := TO_NUMBER(V_OBJ.GET_STRING('WO_SEQ'));       

                               V_ORDR_SQL := V_ORDR_SQL || 
                                             '  ( ''' || V_WRK_ORDR_NO || ''''||' ,'|| TO_CHAR(V_WRK_ORDR_SEQNO) ||' ),';


                    END LOOP;
                    V_ORDR_SQL := SUBSTR(V_ORDR_SQL,1, length(V_ORDR_SQL)-1) ;
                    IF P_ALL_SEARCH  ='Y'  THEN
                            V_SQL :=  '        
                                        SELECT 
                                               ''-''                                                                    CHK             --선택번튼
                                               ,V003.IND_BCD                                                            IND_BCD         --재단 바코드
                                               ,V003.LOT_NO                                                             LOT_NO          --재단 LOT_NO   
                                               ,NVL(V003.IN_QTY,0)      IN_QTY          --투입량
                                               ,NVL(V003.USE_QTY,0)      USE_QTY         --사용량               
                                               ,NVL(V003.DISPO_QTY,0)    DISPO_QTY       --폐품량                                                                                                       
                                               ,NVL(V003.IN_QTY,0) - NVL(V003.USE_QTY,0)  ABLE_QTY         --가용량
                                               ,NVL(V001.UCFMTY_AMT, 0) / 500                                           UCFMTY_AMT       --부적합연수     
                                               ,0                       IN_WGT          --투입중량      POP에서 계산하여 0으로 전달
                                               ,0                       USE_WGT         --사용중량      POP에서 계산하여 0으로 전달
                                               ,0                       DISPO_WGT       --폐품중량      POP에서 계산하여 0으로 전달
                                               ,0                       ABLE_WGT        --가용중량      POP에서 계산하여 0으로 전달
                                               ,V001.ORDER_NO                                                           ORDER_NO        --오더번호
                                               ,V003.MATNR                                                              MATNR           --자재코드
                                               ,V003.WRK_ORDR_NO                                                        WRK_ORDR_NO 
                                               ,V003.WRK_ORDR_SEQNO                                                     WRK_ORDR_SEQNO
                                               ,H018.WRK_ORDR_NO                                                        PC_WRK_ORDR_NO 
                                               ,H018.WRK_ORDR_SEQNO                                                     PC_WRK_ORDR_SEQNO
                                          FROM TB_INV003 V003
                                             , TB_INV001 V001
                                             , TB_SCH009 H009
                                             , TB_SCH018 H018
                                         WHERE V003.WERKS    = V001.WERKS(+)
                                           AND V003.IND_BCD  = V001.IND_BCD(+)
                                           AND V001.WERKS    = H009.WERKS(+)
                                           AND V001.ORDER_NO = H009.FRAUFNR (+)
                                           AND H009.WERKS    = H018.WERKS(+)
                                           AND H009.AUFNR    = H018.ORDER_NO(+)
                                           AND V003.STCK_QTY > 0
                                           AND H009.DLFL  = ''N''
                                           AND H018.USE_YN =''Y''
                                           AND NVL(V003.IN_QTY,0) - NVL(V003.USE_QTY,0)  > 0
                                     ' 
                                     ;

                                     V_SQL := V_SQL || ' AND V003.WERKS = ''' || P_WERKS || '''';				   --플랜트   
                                     V_SQL := V_SQL || ' AND V003.MACH_CD LIKE ''' || SUBSTR(P_MACH_CD, 1, 3) || '%''';				   --설비코드
                                     V_SQL := V_SQL || ' AND ( V003.WRK_ORDR_NO,V003.WRK_ORDR_SEQNO ) IN ( ' || V_ORDR_SQL || ' ) ' ;  
                                     V_SQL := V_SQL || ' ORDER BY   V003.LOT_NO DESC , V003.IND_BCD ASC ' ;  
                    ELSE
                            V_SQL :=  '        
                                        SELECT 
                                               ''-''                                                                    CHK             --선택번튼
                                               ,V003.IND_BCD                                                            IND_BCD         --재단 바코드
                                               ,V003.LOT_NO                                                             LOT_NO          --재단 LOT_NO   
                                               ,NVL(V003.IN_QTY,0)     IN_QTY          --투입량
                                               ,NVL(V003.USE_QTY,0)      USE_QTY         --사용량               
                                               ,NVL(V003.DISPO_QTY,0)    DISPO_QTY       --폐품량                                                                                                       
                                               ,NVL(V003.IN_QTY,0) - NVL(V003.USE_QTY,0)      ABLE_QTY         --가용량
                                               ,NVL(V001.UCFMTY_AMT, 0) / 500                                           UCFMTY_AMT       --부적합연수                                                                                                                   
                                               ,0                       IN_WGT          --투입중량      POP에서 계산하여 0으로 전달
                                               ,0                       USE_WGT         --사용중량      POP에서 계산하여 0으로 전달
                                               ,0                       DISPO_WGT       --폐품중량      POP에서 계산하여 0으로 전달
                                               ,0                       ABLE_WGT        --가용중량      POP에서 계산하여 0으로 전달
                                               ,V001.ORDER_NO                                                           ORDER_NO        --오더번호
                                               ,V003.MATNR                                                              MATNR           --자재코드
                                               ,V003.WRK_ORDR_NO                                                        WRK_ORDR_NO 
                                               ,V003.WRK_ORDR_SEQNO                                                     WRK_ORDR_SEQNO
                                               ,H018.WRK_ORDR_NO                                                        PC_WRK_ORDR_NO 
                                               ,H018.WRK_ORDR_SEQNO                                                     PC_WRK_ORDR_SEQNO
                                          FROM TB_INV003 V003
                                             , TB_INV001 V001
                                             , TB_SCH009 H009
                                             , TB_SCH018 H018
                                         WHERE V003.WERKS    = V001.WERKS(+)
                                           AND V003.IND_BCD  = V001.IND_BCD(+)
                                           AND V001.WERKS    = H009.WERKS(+)
                                           AND V001.ORDER_NO = H009.FRAUFNR (+)
                                           AND H009.WERKS    = H018.WERKS(+)
                                           AND H009.AUFNR    = H018.ORDER_NO(+)
                                           AND V003.STCK_QTY > 0
                                           AND H018.USE_YN =''Y''
                                           AND H009.DLFL  = ''N''
                                           AND NVL(V003.IN_QTY,0) - NVL(V003.USE_QTY,0)  > 0
                                     ' 
                                     ;

                                     V_SQL := V_SQL || ' AND V003.WERKS = ''' || P_WERKS || '''';				   --플랜트   
                                     V_SQL := V_SQL || ' AND V003.MACH_CD = ''' || P_MACH_CD || '''';				   --설비코드
                                     V_SQL := V_SQL || ' AND ( V003.WRK_ORDR_NO,V003.WRK_ORDR_SEQNO ) IN ( ' || V_ORDR_SQL || ' ) ' ;  
                                     V_SQL := V_SQL || ' ORDER BY   V003.LOT_NO DESC , V003.IND_BCD ASC ' ;  
                    END IF;

                    INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);

                    OPEN CUR_2 FOR V_SQL;
             END IF ;

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
