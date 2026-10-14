--------------------------------------------------------
--  DDL for Procedure SP_POP_LAMI_PC_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_LAMI_PC_SAVE" 
(
    P_WRK_ORDR_NO         IN VARCHAR2
    ,P_WRK_ORDR_SEQNO     IN NUMBER
    ,P_WERKS              IN VARCHAR2
    ,P_ORDER_NO           IN VARCHAR2
    ,P_WRK_SEQNO          IN VARCHAR2
    ,P_WRK_ORDR_QTY       IN NUMBER
    ,P_ORDR_GEN_DT        IN VARCHAR2
    ,P_PRD_REQ_DT         IN VARCHAR2
    ,P_WRK_ORDR_RMK       IN VARCHAR2
    ,P_ORDER_DIV          IN VARCHAR2
    ,P_ORDER_DIV_NM       IN VARCHAR2
    ,P_MATNR              IN VARCHAR2
    ,P_ORDER_QTY          IN NUMBER
    ,P_UNIT               IN VARCHAR2
    ,P_WORK_ORDER         IN VARCHAR2
    ,P_TO_MACHINE         IN VARCHAR2
    ,P_MACHINE            IN VARCHAR2
    ,P_BOM_NO             IN VARCHAR2
    ,P_ATN_BOM_NO         IN VARCHAR2
    ,P_VBELN              IN VARCHAR2
    ,P_POSNR              IN VARCHAR2
    ,P_SPEC               IN NUMBER
    ,P_PUPOS              IN VARCHAR2
    ,P_PUPNM              IN VARCHAR2
    ,P_ORDER_RMK          IN VARCHAR2
    ,P_MACH_CD            IN VARCHAR2
    ,P_ORDER_SEQNO        IN VARCHAR2
    ,P_WORKCENTERCODE     IN VARCHAR2
    ,P_VLEN               IN NUMBER
    ,P_WLEN               IN NUMBER
    ,Lang       		  IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		  OUT VARCHAR2 
    ,RS_MSG      		  OUT VARCHAR2
--    ,CUR_1          OUT SYS_REFCURSOR
--    ,CUR_2          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : WRK073
 * PROGRAM NAME  : 인쇄/코팅
 * VERSION       : 1.0.0
 * DESCRIPTION   : 인쇄/코팅 작업지시 저장.
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
    --프로그램 ID : 점보롤 실적등록
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_LAMI_PC_SAVE';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    --parameter변수 처리
    V_PRFM_DT      			    VARCHAR2(10);
    V_REMAIN_QTY                NUMBER;
    V_WO_NO         VARCHAR2(50)    := '';      -- 작업지시번호 (작업지시BOM생성을 위해서..)  
    V_WO_SEQ        NUMBER          := 0;      --작업지시순번 (작업지시BOM생성을 위해서..)  
    V_WERKS         VARCHAR2(50)    := '';      -- 플랜트 (작업지시BOM생성을 위해서..) 
    V_BOM_CNT                NUMBER;
BEGIN

    BEGIN

      SP_GET_DOC_SEQ('LP1',P_ORDR_GEN_DT,V_WO_NO); 

        INSERT INTO TB_LAMI_PC
        (
            WRK_ORDR_NO
            ,WRK_ORDR_SEQNO
            ,WERKS
            ,ORDER_NO
            ,WRK_SEQNO
            ,WRK_ORDR_QTY
            ,ORDR_GEN_DT
            ,PRD_REQ_DT
            ,WRK_ORDR_RMK
            ,PRD_STR_DTM
            ,PRD_END_DTM
            ,PRFM_QTY
            ,COMP_YN
            ,USE_YN
            ,ORDER_DIV
            ,ORDER_DIV_NM
            ,MATNR
            ,ORDER_QTY
            ,UNIT
            ,WORK_ORDER
            ,TO_MACHINE
            ,MACHINE
            ,BOM_NO
            ,ATN_BOM_NO
            ,PRT_MATNR_UNIT
            ,PRT_MATNR_QTY
            ,RES_DT
            ,VBELN
            ,POSNR
            ,SPEC
            ,PUPOS
            ,PUPNM
            ,ORDER_RMK
            ,DLFL
            ,WRK_CD
            ,PRD_END_DT
            ,MACH_CD
            ,ORDER_SEQNO
            ,REGDATE
            ,REGID
            ,UPDDATE
            ,UPDID
            ,PRD_LAST_DATE
            ,SAPYN
            ,CYCLE_TIME
            ,WORKCENTERCODE
            ,SALCODE
            ,SALWEIGHT
            ,PPCODE
            ,HEIGHT
            ,EQUIL
            ,STD
            ,LOT_BUF
            ,IND_BCD
            ,KUNNR
            ,VLEN
            ,WLEN
            ,REMAIN_QTY
            ,PRFMMET_QTY
            ,SALMETER
            ,SAL_RMK
            ,DOC_NO
        )
        VALUES
        (
            V_WO_NO
            ,1
            ,P_WERKS
            ,P_ORDER_NO
            ,P_WRK_SEQNO
            ,P_WRK_ORDR_QTY
            ,P_ORDR_GEN_DT
            ,P_PRD_REQ_DT
            ,P_WRK_ORDR_RMK
            ,''
            ,''
            ,0
            ,'N'
            ,'Y'
            ,P_ORDER_DIV
            ,P_ORDER_DIV_NM
            ,P_MATNR
            ,P_ORDER_QTY
            ,P_UNIT
            ,P_WORK_ORDER
            ,P_TO_MACHINE
            ,P_MACHINE
            ,P_BOM_NO
            ,P_ATN_BOM_NO
            ,NULL
            ,0
            ,NULL
            ,P_VBELN
            ,P_POSNR
            ,P_SPEC
            ,P_PUPOS
            ,P_PUPNM
            ,P_ORDER_RMK
            ,'N'
            ,NULL
            ,NULL
            ,P_MACH_CD
            ,P_ORDER_SEQNO
            ,SYSDATE
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,'N'
            ,0
            ,P_WORKCENTERCODE
            ,NULL
            ,0
            ,NULL
            ,0
            ,0
            ,0
            ,NULL
            ,NULL
            ,NULL
            ,P_VLEN
            ,P_WLEN
            ,P_ORDER_QTY
            ,0
            ,0
            ,NULL
            ,NULL
        );

    SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, WERKS 
    INTO V_WO_NO,V_WO_SEQ,V_WERKS
    FROM TB_LAMI_PC
    WHERE ORDER_NO = P_ORDER_NO;
--    AND NVL(MAN_CUT_YN,'N') <> 'X';

    SELECT COUNT(ORDER_NO) INTO V_BOM_CNT 
    FROM TB_SCH020 
    WHERE WRK_ORDR_NO = V_WO_NO
    AND WRK_ORDR_SEQNO = V_WO_SEQ; 

    --작업지시BOM이 존재하지 않으면 생산BOM->작업지시BOM을 생성 한다.
    IF V_BOM_CNT = 0 THEN 
      INSERT INTO TB_SCH020 
      (      ORDER_NO                  		--오더번호        
            ,ORDER_ITM_NO                 --오더Item번호    
            ,MATNR                        --자품목자재       
            ,ORDER_BOM_QTY                --오더BOM 수량    
            ,UNIT                         --오더BOM 수량단위  
            ,LOT_NO                       --LOT NO      
            ,STOR_LOC_CD                  --저장위치        
            ,DLFL                         --삭제 지시자(불출요청)
            ,WERKS                        --플랜트         
            ,WRK_ORDR_NO                  --작업지시번호      
            ,WRK_ORDR_SEQNO               --작업지시번호 순번  

            ,REGDATE                       /*     등록일자                       */
            ,REGID                         /*     등록자                        */
            ,UPDDATE                       /*     수정일자                       */
            ,UPDID                         /*     수정자                        */                   
      )
      SELECT AUFNR				                 /*		오더번호					                */
            ,POSNR				                 /*		오더Item번호					            */
            ,MATNR				                 /*		자품목자재					                */
            ,BDMNG				                 /*		오더BOM 수량					            */
            ,MEINS				                 /*		오더BOM 수량단위					          */
            ,LOT_NO                        --LOT번호            
            ,LGORT                         /*   저장위치                          */
            ,case when XLOEK = 'X' then 'Y'
                  else 'N'                           
             end				                 /*		삭제여부					                */
            ,V_WERKS
            ,V_WO_NO
            ,1  

            ,sysdate
            ,'SP_LAMI_IFR024'
            ,null
            ,null
      FROM TB_SCH001          
      WHERE  AUFNR  =  P_ORDER_NO;       
    END IF;                          

        RS_CODE := 'S';
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
