--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK29_S03
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK29_S03" 
(
     P_WERKS            IN VARCHAR2 
    ,P_MACH_CD          IN VARCHAR2 
    ,P_WRK_ORDR_NO      IN VARCHAR2             
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2             
    ,P_IN_PCNT          IN VARCHAR2             -- 투입연수
    ,P_IN_WGT           IN VARCHAR2             -- 투입중량
    ,P_PCNT             IN VARCHAR2             --실적연수
    ,P_WGT              IN VARCHAR2             --실적중량
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK29
 * PROGRAM NAME  : PS 수재단 완료 처리하여 실적 등록시 남은 연수가 있는지 검사
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
 * 2022/05/25    1.0.0   박충식         Initial Version
 * 2022/12/06    1.0.1   김병무         예외생산 계획연수 와 실적연수 검사 추가
  *==============================================================================
 *  관련 테이블
 * - [TB_SCH016] : (.R..) 제지 수재단 작업지시
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 * - [TB_WRK001] : (.R..) 설비별 현재 진행현황
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK29_S03';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리

    V_IN_PCNT         NUMBER;
    V_PCNT            NUMBER;
    V_WRK_ORDR_QTY    NUMBER;   --계획 연수

    
    V_COLINFO VARCHAR2(1000);--컬럼설정1
    V_COLTYPE VARCHAR2(1000);--컬럼설정1

BEGIN
    BEGIN
    
        IF SUBSTR(P_WRK_ORDR_NO,1,4)  <> 'WOEX' THEN

            SELECT  SUM(A), SUM(B)
            INTO V_IN_PCNT  -- 재단투입 연수
                ,V_PCNT     -- 완료 연수
            FROM
            (
                SELECT CASE WHEN TRUNC(K002.VLEN/H017.VLEN) > 1  OR  TRUNC(K002.WLEN/H017.WLEN) > 1 THEN K002.PCNT * 2
                              ELSE                                                                       K002.PCNT
                        END  A
                       ,NVL(( SELECT  SUM(PCNT)
                              FROM (
                              SELECT NVL(PCNT,0)  PCNT
                                     FROM TB_WRK002 K0021
                                    WHERE K0021.WRK_ORDR_NO        = XH017.WRK_ORDR_NO
                                      AND K0021.WRK_ORDR_SEQNO     = XH017.WRK_ORDR_SEQNO
                                      AND K0021.WERKS              = XH017.WERKS
                                      AND NVL(K0021.CNL_YN , 'N')  = 'N'
                                   UNION ALL   
                                   SELECT NVL(DISPO_QTY,0)  PCNT
                                     FROM TB_WRK004 K004
                                    WHERE K004.WRK_ORDR_NO        = XH017.WRK_ORDR_NO
                                      AND K004.WRK_ORDR_SEQNO     = XH017.WRK_ORDR_SEQNO
                                      AND K004.WERKS              = XH017.WERKS
                                      AND NVL(K004.CNL_YN , 'N')  = 'N'                           
                           )           
                          ),0) B
                  FROM TB_SCH017 H017, TB_SCH017 XH017, TB_WRK002 K002
                 WHERE  H017.WRK_ORDR_NO    = P_WRK_ORDR_NO
                   AND  H017.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                   AND  H017.WERKS          = XH017.WERKS
                   AND  H017.ORDER_NO       = XH017.PRE_ORDER_NO
                   AND  XH017.DUMMY_KEY     = K002.IND_BCD
                   AND  XH017.WERKS         = K002.WERKS
                   AND  NVL(CNL_YN , 'N')   = 'N'
            )    
            ;
            
            V_PCNT := V_PCNT + TO_NUMBER(P_PCNT) ;
               
            IF V_IN_PCNT > TO_NUMBER(P_IN_PCNT)    THEN
               RS_CODE      := 'E';
               RS_MSG       := '재단 이동연수보다 수재단 투입량이 적습니다.\n'||'재단 이동연수 : '|| TO_CHAR(V_IN_PCNT)||'\n수재단 투입연수 : '|| TO_CHAR(P_IN_PCNT);
               RETURN;
            END IF;
    
            IF  V_IN_PCNT > V_PCNT   THEN
               RS_CODE      := 'E';
               RS_MSG       := '실적을 등록후 에도 남는 투입연수가 있습니다.\n'||'이동연수 : '||TO_CHAR(V_IN_PCNT)||'\n사용연수 : '||TO_CHAR(V_PCNT);
               RETURN;
            END IF;
        ELSE
            -- 계획연수...
            SELECT WRK_ORDR_QTY
              INTO V_WRK_ORDR_QTY  -- 계획 연수
            FROM TB_SCH019
            WHERE WRK_ORDR_NO = P_WRK_ORDR_NO
              AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
              ;
        
            BEGIN
                SELECT SUM(PCNT)
                  INTO V_PCNT
                FROM TB_INV010 
                WHERE WRK_ORDR_NO = P_WRK_ORDR_NO
                  AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                  AND NVL(CNL_YN , 'N') = 'N'
                  ;
              EXCEPTION 
                WHEN NO_DATA_FOUND THEN
                    V_PCNT := 0;
                WHEN OTHERS THEN
                    V_PCNT := 0;
            END;

            V_PCNT := V_PCNT + TO_NUMBER(P_PCNT) ;
            
            IF V_WRK_ORDR_QTY > V_PCNT THEN
               RS_CODE      := 'E';
               RS_MSG       := '실적을 등록후 에도 남는 계획연수가 있습니다.\n'||'계획연수 : '||TO_CHAR(V_WRK_ORDR_QTY)||'\n사용연수 : '||TO_CHAR(V_PCNT);
               RETURN;
            END IF;
        END IF;
        
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
