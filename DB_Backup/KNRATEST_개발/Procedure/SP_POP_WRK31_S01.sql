--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK31_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK31_S01" 
(
     P_WERKS        IN VARCHAR2             -- 플랜트 코드
    ,P_MACH_CD      IN VARCHAR2             -- 작업장코드(설비코드)
    ,P_PFROM_DT     IN VARCHAR2             -- 생산실적일자 (from)
    ,P_PTO_DT       IN VARCHAR2             -- 생산실적일자 (to)
    ,P_MATNR        IN VARCHAR2             -- 자재코드
    ,P_COLINFO      OUT VARCHAR2            -- grid 칼럼명
    ,P_COLTYPE      OUT VARCHAR2            -- grid 칼럼 데이터 타입
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2 
    ,CUR_1          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK31_S01
 * PROGRAM NAME  : 생산실적 이력 조회 (라벨병합)
 * VERSION       : 1.0.1
 * DESCRIPTION   : 생산실적 이력 조회 (라벨병합)
 *                 
 * AUTHOR NAME   : 김병무
 * CREATE DATE   : 2022/04/25
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/04/06    1.0.0   김병무         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK002] : (.R..) PS 생산실적 이력
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK30_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리
BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
        
            --grid 컬럼 정보 설정
            P_COLINFO := '선택@C^50|생산일시@C^190|판매문서@C^110|품목@C^70|자재코드@C^190|개별바코드@C^150|LOT_NO@C^130|재고상태@C^80|오더번호@H|순번@H|작업지시번호@H|순번@H|' ||
                         '단위@H|실적연수@R^100|실적중량(KG)@R^120|상세보기@C^100|운전@C^80|지종@H|지종명@H|평량@H|' ||
                         '생산시작일시@H|생산종료일시@H|가동시간(분)@H|실적일자@H|반@H|상태@H|비고@L^800|완료여부@H|병합@H';
            P_COLTYPE := 'CHK@Button|PRD_DTM@varchar|VBELN@varchar|POSNR@varchar|MATNR@varchar|IND_BCD@varchar|LOT_NO@varchar|STCK_STA_NM@varchar|ORDER_NO@varchar|ORDER_SEQNO@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|' ||
                         'UNIT@varchar|PRFM_QTY@varchar|WGT@varchar|DBTN@Button|RUN_STA_NM@varchar|PCODE@varchar|PCODE_NM@varchar|BS_WGT@varchar|' ||
                         'PRD_STR_DATE@varchar|PRD_END_DATE@varchar|TM@varchar|PRFM_DT@varchar|WRK_CLASS@varchar|STA@varchar|RMK@varchar|COMP_YN@varchar|MER_YN@varchar';
            --실적현황 조회
            OPEN CUR_1 FOR
            SELECT
                CHK              --체크버튼
               , PRD_DTM         --생산일시 (ORDER BY 용)
               , VBELN           --문서번호
               , POSNR           --문서번호 SEQ (품목)
               , MATNR           --자재코드
               , IND_BCD         --개별바코드
               , LOT_NO          --LOT_NO
               , STCK_STA_NM     --재고상태
               , ORDER_NO        --오더번호
               , ORDER_SEQNO     --오더번호 순번
               , WRK_ORDR_NO     --작업지시번호
               , WRK_ORDR_SEQNO  --작업지시 순번
               , UNIT            --실적단위
               , PRFM_QTY	     --실적연수
               , WGT	         --실적중량
               , DBTN            --상세보기 버튼
               , RUN_STA_NM      --운전상태
               , PCODE           --지종
               , PCODE_NM        --지종명
               , BS_WGT          --평량
               , PRD_STR_DATE    --생산시작 일시
               , PRD_END_DATE    --생산 종료 일시
               , TM              --생산시간(분)
               , PRFM_DT         --실적일자
               , WRK_CLASS       --반
               , STA             --상태
               , RMK             --비고
               , COMP_YN         --작업완료
               , MER_YN          --병합여부
            FROM
            (
                        SELECT 
                              '-'                               CHK             --체크버튼
                            , TO_CHAR(W002.REGDATE, 'YYYY-MM-DD HH24:MI:SS') AS PRD_DTM -- 생산일자
                            , W002.VBELN                        VBELN           --문서번호
                            , W002.POSNR                        POSNR           --문서번호 SEQ (품목)
                            , W002.MATNR                        MATNR           --자재코드
                            , W002.IND_BCD                      IND_BCD         --개별바코드
                            , W002.LOT_NO                       LOT_NO          --LOT_NO
                            , (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = 'STCK_STA' AND CMCDVL = I001.STCK_STA)   STCK_STA_NM    --재고상태
                            , W002.ORDER_NO                     ORDER_NO        --오더번호
                            , W002.ORDER_SEQNO                  ORDER_SEQNO     --오더번호 순번
                            , W002.WRK_ORDR_NO                  WRK_ORDR_NO     --작업지시번호
                            , W002.WRK_ORDR_SEQNO               WRK_ORDR_SEQNO  --작업지시 순번
                            , W002.UNIT                         UNIT            --실적단위          
                            , NVL(RTRIM(TO_CHAR(W002.PRFM_QTY/500, 'fm999,999,999,999,990.999'), '.'), '0')     PRFM_QTY	    --실적연수
                            , NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0')              WGT	            --실적중량
                            , '상세보기'                         DBTN            --상세보기 버튼
                            , (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = 'RUN_STA' AND CMCDVL = W002.RUN_STA)     RUN_STA_NM      --운전상태
                            , M001.PCODE                        PCODE           --지종
                            , M001.PCODE_NM                     PCODE_NM        --지종명
                            , TO_CHAR(M001.BS_WGT, 'fm999,999,999,990')              BS_WGT          --평량
                            , TO_CHAR(W002.PRD_STR_DATE,'YYYY-MM-DD HH24:MI:SS')     PRD_STR_DATE    --생산시작 일시
                            , TO_CHAR(W002.PRD_END_DATE,'YYYY-MM-DD HH24:MI:SS')     PRD_END_DATE    --생산 종료 일시
                            , TO_CHAR(W002.TM, 'fm999,999,999,990')                  TM              --생산시간(분)
                            , TO_CHAR(TO_DATE(W002.PRFM_DT,'YYYYMMDD'),'YYYY-MM-DD') PRFM_DT         --실적일자
                            , W002.WRK_CLASS                    WRK_CLASS       --반
                            , W002.STA                          STA             --상태
                            , W002.RMK                          RMK             --비고
                            , S017.COMP_YN                      COMP_YN         --작업지시완료여부
                            , W002.MER_YN                       MER_YN          --병합여부
                        FROM  TB_WRK002 W002    --PS실적
                            , TB_SCH017 S017    --작업지시
                            , TB_INV001 I001    --Location별 재고
                            , TB_MAS001 M001    --자재마스터
                        WHERE 1=1      
                        AND W002.WERKS          = M001.WERKS       
                        AND W002.MATNR          = M001.MATNR
                        AND W002.WERKS          = I001.WERKS
                        AND W002.MACH_CD        = I001.MACH_CD       
                        AND W002.IND_BCD        = I001.IND_BCD      
                        AND W002.WRK_ORDR_NO    = S017.WRK_ORDR_NO(+)
                        AND W002.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO(+)
                        AND W002.WERKS          = P_WERKS                       --플랜트코드
                        AND W002.MACH_CD        = P_MACH_CD                     --작업장코드(설비코드)
                        AND W002.PRFM_DT BETWEEN P_PFROM_DT AND P_PTO_DT        --실적기간
                        AND W002.MATNR          LIKE P_MATNR||'%'               --자재코드
                        AND W002.PRFM_GTHR_YN    = 'Y'                          --실적조회여부   
                        AND NVL(W002.CNL_YN,'N') = 'N'
                        AND W002.MAN_CUT_YN      = 'N'                          --수재단이 아닌거
                        AND NOT EXISTS ( SELECT 1                               --이후 공정에 투입되지 않은 바코드만 가능
                                           FROM TB_INV003
                                          WHERE W002.WERKS   = WERKS
                                            AND W002.MATNR   = MATNR
                                            AND W002.IND_BCD = IND_BCD )
                )
                ORDER BY PRD_DTM DESC, VBELN, POSNR, LOT_NO DESC, IND_BCD DESC, MATNR, PRFM_DT; 

            --작업 정상 종료 코드 등록
            RS_CODE := 'S';
        END;
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
END SP_POP_WRK31_S01;

/
