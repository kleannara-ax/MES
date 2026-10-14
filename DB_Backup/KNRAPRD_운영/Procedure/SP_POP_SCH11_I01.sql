--------------------------------------------------------
--  DDL for Procedure SP_POP_SCH11_I01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_SCH11_I01" 
(
     P_WERKS            IN VARCHAR2       -- 플랜트코드            
    ,P_ORDR_GEN_DT      IN VARCHAR2       -- 지시생성일자           
    ,P_WRK_ORDR_QTY     IN NUMERIC        -- 생산지시량            
    ,P_PRD_REQ_DT       IN VARCHAR2       -- 생산요청일자          
    ,P_MACHINE          IN VARCHAR2       -- 생산호기                
    ,P_MATNR            IN VARCHAR2       -- 자재코드            
    ,P_BOM_NO           IN VARCHAR2       -- BOM Num 
    ,P_UNIT             IN VARCHAR2       -- 단위
    ,P_PCODE            IN VARCHAR2       -- 지종코드            
    ,P_BS_WGT           IN NUMERIC        -- 평량
    ,P_JRCNT            IN NUMERIC        -- J/R 권치수
    ,P_JWIDTH           IN NUMERIC        -- J/R 지폭
    ,P_JROLLCNT         IN NUMERIC        -- J/R 권치수
    ,P_WRK_ORDR_RMK     IN VARCHAR2       -- 작업지시비고
    ,P_USERID           IN VARCHAR2       -- 등록자ID
    ,RS_CODE            OUT VARCHAR2      -- 'S' :정상 'E' :에러
    ,RS_MSG             OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_SCH11_I01
 * PROGRAM NAME  : 점보롤 비계획생산 추가 등록
 * VERSION       : 1.0.0
 * DESCRIPTION   : 점보롤 비계획생산을 등록한다.
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
 * - [TB_SCH015] : (C...) 작업지시 점보롤
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM         VARCHAR2(100)  := 'SP_POP_SCH11_I01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    --parameter변수 처리
    V_WRK_ORDR_NO     VARCHAR2(8)  ;      -- 작업지시번호           


BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            --작업지시순번 채번
            SP_GET_DOC_SEQ('WOF',P_ORDR_GEN_DT,V_WRK_ORDR_NO); 

            --점보롤비계획생산 등록

            INSERT INTO TB_SCH015 (
                     WRK_ORDR_NO	        --작업지시번호
                    ,WRK_ORDR_SEQNO	        --작업지시순번
                    ,WERKS	                --플랜트코드
                    ,ORDER_NO	            --오더번호
                    ,WRK_SEQNO	            --작업순서
                    ,WRK_ORDR_QTY	        --생산지시량
                    ,ORDR_GEN_DT	        --지시생성일자
                    ,PRD_REQ_DT	            --생산요청일자
                    ,WRK_ORDR_RMK	        --작업지시비고
                    ,PRD_STR_DTM	        --생산시작일시
                    ,PRD_END_DTM	        --생산완료일시
                    ,PRFM_QTY	            --실적수량
                    ,COMP_YN	            --완료여부
                    ,USE_YN	                --사용여부(Y/N)
                    ,PRT_MATNR_UNIT	        --모품목기준수량 단위
                    ,PRT_MATNR_QTY	        --모품목기준수량
                    ,DLFL	                --오더 삭제 지시자
                    ,MATNR	                --자재 코드
                    ,MACHINE	            --FROM 생산호기
                    ,MACHINE_NM	            --FROM 생산 호기명
                    ,ATN_BOM_NO	            --대체Bom
                    ,BOM_NO	                --BOM Num
                    ,UNIT                   --단위 
                    ,TO_MACHINE	            --TO 생산호기
                    ,TO_MACHINE_NM	        --TO 생산 호기명
                    ,BS_WGT	                --평량
                    ,PCODE	                --지종
                    ,NAUFNR	                --오더 변경 번호
                    ,PRDTYPE	            --생산라인구분
                    ,PRDTYPETXT	            --생산라인구분명
                    ,SHEET	                --판지구분자
                    ,WORK_ORDER	            --작업지시자
                    ,TOT_WGT	            --총중량
                    ,JRCNT	                --J/R 개수
                    ,JROLLCNT	            --J/R 권치수
                    ,JWIDTH	                --J/R 지폭
                    ,WRK_ORDR_DIV	        --작업지시구분
                    ,REGDATE	            --등록일시
                    ,REGID	                --등록자ID
                    ,UPDDATE	            --수정일시
                    ,UPDID	                --수정자ID
            )
            VALUES
            (
                     V_WRK_ORDR_NO	            --작업지시번호
                    ,1	                        --작업지시순번
                    ,P_WERKS	                --플랜트코드
                    ,NULL	                    --오더번호
                    ,'1'	                    --작업순서
                    ,P_WRK_ORDR_QTY	            --생산지시량
                    ,P_ORDR_GEN_DT	            --지시생성일자
                    ,P_PRD_REQ_DT	            --생산요청일자
                    ,P_WRK_ORDR_RMK	            --작업지시비고
                    ,NULL	                    --생산시작일시
                    ,NULL	                    --생산완료일시
                    ,NULL	                    --실적수량
                    ,'N'	                    --완료여부
                    ,'Y'	                    --사용여부(Y/N)
                    ,NULL	                    --모품목기준수량 단위
                    ,NULL	                    --모품목기준수량
                    ,NULL	                    --오더 삭제 지시자
                    ,P_MATNR	                --자재 코드
                    ,P_MACHINE	                --FROM 생산호기
                    ,NULL	                    --FROM 생산 호기명
                    ,NULL	                    --대체Bom
                    ,P_BOM_NO	                --BOM Num
                    ,P_UNIT                     --단위                     
                    ,NULL	                    --TO 생산호기
                    ,NULL	                    --TO 생산 호기명
                    ,P_BS_WGT	                --평량
                    ,P_PCODE	                --지종
                    ,NULL	                    --오더 변경 번호
                    ,NULL	                    --생산라인구분
                    ,NULL	                    --생산라인구분명
                    ,NULL	                    --판지구분자
                    ,NULL	                    --작업지시자
                    ,NULL	                   --총중량
                    ,P_JRCNT	                --J/R 개수
                    ,P_JROLLCNT    	            --J/R 권치수
                    ,P_JWIDTH	                --J/R 지폭
                    ,'1'	                    --작업지시구분   (정상지시 : 0    비계획생산지시 : 1)
                    ,SYSDATE	                --등록일시
                    ,V_SESS_USER_ID	            --등록자ID
                    ,NULL	                    --수정일시
                    ,NULL	                    --수정자ID
             );

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

END SP_POP_SCH11_I01;


/
