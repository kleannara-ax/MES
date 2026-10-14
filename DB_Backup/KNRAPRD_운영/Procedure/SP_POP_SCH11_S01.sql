--------------------------------------------------------
--  DDL for Procedure SP_POP_SCH11_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_SCH11_S01" 
(
     P_WERKS     IN VARCHAR2      -- 플랜트코드            
    ,P_MATNR     IN VARCHAR2      -- 자재코드  
    ,RS_CODE     OUT VARCHAR2 
    ,RS_MSG      OUT VARCHAR2
    ,CUR_1       OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_SCH11_S01
 * PROGRAM NAME  : BOM 팝업 선택
 * VERSION       : 1.0.0
 * DESCRIPTION   : BOM 팝업 목록을 조회한다.
 *                 
 * AUTHOR NAME   : 박충식
 * CREATE DATE   : 2022/05/12
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/12    1.0.0   박충식         Initial Version 
 *==============================================================================
 *  관련 테이블
 * - [TB_MAS008] : (.R..) BOM 마스터
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_SCH11_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    --parameter변수 처리
    --V_PROCCD   VARCHAR2(10) := P_PROCCD;

BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN

            --결과 테이블 반환용 변수
            OPEN CUR_1 FOR
            --BOM 목록 조회
            SELECT 
                    MAS008.BOM_NO		        BOM_NO          --BOM Num
                  , MAS008.ATN_BOM_NO           ATN_BOM_NO      --대체bom
                  , MAS008.SUB_MATNR	        SUB_MATNR       --자품목자재  
                  , MAS008.SUB_MATNR_QTY	    SUB_MATNR_QTY   --수량			
                  , MAS008.SUB_MATNR_UNIT	    SUB_MATNR_UNIT  --수량단위
                  , MAS008.AUSCH		        AUSCH           --스크랩			
                  , MAS008.ITSOB		        ITSOB           --특별유형			
            FROM TB_MAS008 MAS008
            WHERE 1=1
              AND MAS008.WERKS	= P_WERKS 
              AND MAS008.MATNR	= P_MATNR	
              --AND MAS008.USE_YN	= 'Y'
              --AND MAS008.DL_YN  = 'N'		
            ;
            --작업 정상 종료 코드 등록
            RS_CODE := 'S';

        END; 
    --예외처리(catch)
    EXCEPTION
    WHEN E_EXCEPTION_USER THEN
        -- 에러 내역 SET
        E_SQL_ERR_CD        := -20000;
        E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    WHEN OTHERS THEN
        E_SQL_ERR_CD        := -20000;
        E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END SP_POP_SCH11_S01;


/
