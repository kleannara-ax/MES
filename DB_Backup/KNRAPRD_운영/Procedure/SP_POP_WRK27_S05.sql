--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK27_S05
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK27_S05" 
(
    P_WERKS     		IN VARCHAR2 	    --플랜트
    ,P_MACH_CD   		IN VARCHAR2 	    --설비코드
    ,P_IND_BCD          IN VARCHAR2 	    --개별바코드
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
    ,CUR_1       		OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : WRK27{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 포장 인쇄용 조회
 * VERSION       : 1.0.1{최종 버전 기술}
 * DESCRIPTION   : 포장 인쇄용 조회
 *                 
 * AUTHOR NAME   : 유상호{최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/12 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   유상호         Initial Version 
 *==============================================================================
 *  관련 테이블
 * - [TB_SCH018] : (.R..) PS 포장 작업지시
 * - [TB_SCH019] : (.R..) PS 포장 작업지시(예외생산)
 * - [TB_WRK002] : (.R..) PS 생산실적 이력
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 * - [USRMA]     : (.R..) 사용자 정보
 *=============================================================================*/
AS 
    --프로그램 ID - 포장인쇄용 조회
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK27_S05';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    --내부 변수 등록
    --V_WERKS                 TB_WRK002.WERKS%TYPE;
    --V_MACH_NM               TB_MAS012.MACH_NM%TYPE;   -- 설비명
    V_IND_BCD_M             TB_INV010.IND_BCD_M%TYPE;
    
    V_WRK_TYPE              varchar2(2);
    V_GRD_YN                TB_WRK002.GRD_YN%TYPE;
    
    V_IN_PER_CNT            TB_WRK010.ZZATT1%TYPE;      --등급변경 속당매수
    V_SCNT                  TB_WRK010.SCNT%TYPE;        --등급변경 속수
    V_IND_BCD_P             TB_WRK010.IND_BCD_M%TYPE;   --등급변경 포장바코드
    
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리
BEGIN
    BEGIN
        --재단 바코드 찾기
        BEGIN
            SELECT IND_BCD_M INTO V_IND_BCD_M 
              FROM (SELECT I010.*
                    FROM TB_INV010 I010
                       , TB_MAS001 M001
                        WHERE 1=1
                          AND M001.WERKS = I010.WERKS
                          AND M001.MATNR = I010.MATNR_M
                          AND M001.MATNR_DIV IN ('HALB', 'FERT', 'HAWA')
                          AND I010.WERKS = P_WERKS
                          AND I010.MACH_CD = P_MACH_CD
                          AND I010.IND_BCD = P_IND_BCD
                          AND NVL(I010.CNL_YN,'N') = 'N'
                    ORDER BY I010.SEQNO)
            WHERE ROWNUM = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_IND_BCD_M := '';
        END ;            
        
        BEGIN
            SELECT DECODE(SUBSTR(WRK_ORDR_NO,1,4), 'WOEX', 'X', 'Y'), NVL(GRD_YN, 'N')   -- 작업유형 : 'Y'는 정규생산, 'X'는 예외생산
                INTO V_WRK_TYPE, V_GRD_YN
                FROM TB_WRK002
                WHERE WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IND_BCD  = P_IND_BCD;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            RS_CODE := 'E';
            RS_MSG := 'NO_DATA_FOUND';
            RETURN;
        END;
        
        --등급변경 여부
        IF  V_GRD_YN = 'Y' THEN
--            PCNT    연수
--            ZZATTI  100                       // 속당매수
--            SCNT    (PCNT* 500 / ZZATTI)      // 매수
--            IND_BCD_M                         // 포장바코드
--            SELECT ZZATT1, DECODE(SCNT, NULL, ( PCNT * 500 / ZZATT1), SCNT), IND_BCD_M
            SELECT ZZATT1, ( PCNT * 500 / ZZATT1), IND_BCD_M
                INTO V_IN_PER_CNT, V_SCNT, V_IND_BCD_P
                FROM TB_WRK010 
                WHERE WERKS = P_WERKS
                  AND IND_BCD = P_IND_BCD
                  AND WRK_TYPE = 1 ;
        END IF;
                
        --작업유형 : 'Y'는 정규생산, 'X'는 예외생산
        IF V_WRK_TYPE = 'Y' THEN
            OPEN CUR_1 FOR
            SELECT M001.PCODE_NM                    PCODE_NM            --지종명
                , NVL(M001.BS_WGT, '0')             BS_WGT              --평량
                , M001.MATNR                        MATNR               --포장 자재코드
                , M001.WLEN || 'x' || M001.VLEN  AS MATNR_SPEC  --규격
                , NVL(W002.PRFM_QTY, '0')           PRFM_REAM           --실적연수
                --, NVL(W002.PCNT, '0')           PRFM_REAM           --실적연수
                , NVL(W002.WGT, '0')                PRFM_WGT            --실적중량
--                , NVL(S018.PLT_PER_CNT, '0')        PLT_PER_CNT         --팔레트당 연수
                , DECODE(V_GRD_YN, 'Y', V_IN_PER_CNT, NVL(W002.IN_PER_CNT, '0'))         IN_PER_CNT          --속당매수 (속수=(팔레트당연수*500)/속당매수)
                , DECODE(V_GRD_YN, 'Y', V_SCNT, NVL(W002.SCNT, '0'))               SCNT                --속수 (속수=(팔레트당연수*500)/속당매수)
                --, S018.KUNNRT                       CUST_NM             --거래처명
                , ''                                CUST_NM             --거래처명 (포장반 요청으로 거래처명 출력 안하도록 함)
                , '(' || S018.MACHINE || ')'        MACHINE_NM          --생산호기
                , DECODE(V_GRD_YN, 'Y', V_IND_BCD_P, V_IND_BCD_M)      IND_BCD_M           --재단바코드 (등급변경시는 포장바코드)
                , USRMA.NMLAST                      WRK_NAME            --작업자
--                , USRMA.USERID                      WRK_ID              --작업자 ID
                , USRMA.EMPLID                      WRK_ID              -- BMKIM 230119 : 작업자 ID 에 사원번호(고유번호) 표시
                --, W002.PACK_LABEL_TYPE              LABEL_TYPE          --포장라벨형식 (사용안함)
                , W002.LOT_NO                       LOT_NO              --LOT NO
                , LPAD(S018.ORDER_NO, 12, '0')      ORDER_NO            --오더번호
                , S018.VBELN || LPAD(S018.POSNR, 6, '0')    SALES_ORDR_NO            --Sales Order No

              FROM TB_WRK002 W002,
                   TB_MAS001 M001,
                   USRMA USRMA,
                   TB_SCH018 S018
             WHERE W002.WERKS = S018.WERKS(+)
               AND W002.WRK_ORDR_NO = S018.WRK_ORDR_NO(+)
               AND W002.WRK_ORDR_SEQNO = S018.WRK_ORDR_SEQNO(+)
               AND W002.WERKS = M001.WERKS(+)
               AND W002.MATNR = M001.MATNR(+)
               AND W002.REGID = USRMA.USERID(+)
               AND W002.WERKS = P_WERKS
               AND W002.MACH_CD = P_MACH_CD
               AND W002.IND_BCD = P_IND_BCD;
        ELSE
            OPEN CUR_1 FOR
            SELECT M001.PCODE_NM                    PCODE_NM            --지종명
                , NVL(M001.BS_WGT, '0')             BS_WGT              --평량
                , M001.MATNR                        MATNR               --포장 자재코드
                , M001.WLEN || 'x' || M001.VLEN  AS MATNR_SPEC  --규격
                , NVL(W002.PRFM_QTY, '0')           PRFM_REAM           --실적연수
                --, NVL(W002.PCNT, '0')           PRFM_REAM           --실적연수
                , NVL(W002.WGT, '0')                PRFM_WGT            --실적중량
--                , NVL(S018.PLT_PER_CNT, '0')        PLT_PER_CNT         --팔레트당 연수
                , DECODE(V_GRD_YN, 'Y', V_IN_PER_CNT, NVL(W002.IN_PER_CNT, '0'))         IN_PER_CNT          --속당매수 (속수=(팔레트당연수*500)/속당매수)
                , DECODE(V_GRD_YN, 'Y', V_SCNT, NVL(W002.SCNT, '0'))               SCNT                --속수 (속수=(팔레트당연수*500)/속당매수)
                --, S019.KUNNRT                       CUST_NM             --거래처명
                , ''                                CUST_NM             --거래처명 (포장반 요청으로 거래처명 출력 안하도록 함)
                --, '(' || S019.MACHINE || ')'        MACHINE_NM          --생산호기
                , ''                                MACHINE_NM          --생산호기
                , DECODE(V_GRD_YN, 'Y', V_IND_BCD_P, V_IND_BCD_M)      IND_BCD_M           --재단바코드 (등급변경시는 포장바코드)
                , USRMA.NMLAST                      WRK_NAME            --작업자
--                , USRMA.USERID                      WRK_ID              --작업자 ID
                , USRMA.EMPLID                      WRK_ID              -- BMKIM 230119 : 작업자 ID 에 사원번호(고유번호) 표시
                --, W002.PACK_LABEL_TYPE              LABEL_TYPE          --포장라벨형식 (사용안함)
                , W002.LOT_NO                       LOT_NO              --LOT NO
                , LPAD(S019.ORDER_NO, 12, '0')      ORDER_NO            --오더번호
                , S019.VBELN || LPAD(S019.POSNR, 6, '0')    SALES_ORDR_NO            --Sales Order No

              FROM TB_WRK002 W002,
                   TB_MAS001 M001,
                   USRMA USRMA,
                   TB_SCH019 S019
             WHERE W002.WERKS = S019.WERKS(+)
               AND W002.WRK_ORDR_NO = S019.WRK_ORDR_NO(+)
               AND W002.WRK_ORDR_SEQNO = S019.WRK_ORDR_SEQNO(+)
               AND W002.WERKS = M001.WERKS(+)
               AND W002.MATNR = M001.MATNR(+)
               AND W002.REGID = USRMA.USERID(+)
               AND W002.WERKS = P_WERKS
               AND W002.MACH_CD = P_MACH_CD
               AND W002.IND_BCD = P_IND_BCD;        
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
