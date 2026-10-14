--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK01_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK01_S01" 
(
    P_WERKS         IN VARCHAR2     -- 플래트 코드
    ,P_LOC_CD       IN VARCHAR2     -- 로케이션 코드
    ,P_MACHINE      IN VARCHAR2     -- 설비호기 (PM2, PM3)
    ,P_MACH_CD      IN VARCHAR2     -- 설비코드
    ,P_STR_DATE     IN VARCHAR2     -- 조회 시작일 
    ,P_END_DATE     IN VARCHAR2     -- 조회 종료일
    ,P_ORDER_NO     IN VARCHAR2             
    ,P_IND_BCD      IN VARCHAR2  
    ,P_PCODE        IN VARCHAR2
    ,P_BS_WGT       IN VARCHAR2 
    ,P_WLEN         IN VARCHAR2
    ,P_VLEN         IN VARCHAR2
    ,P_COLINFO      OUT VARCHAR2    -- grid 칼럼명
    ,P_COLTYPE      OUT VARCHAR2    -- grid 칼럼 데이터 타입
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK01
 * PROGRAM NAME  : 공정투입
 *                 
 * AUTHOR NAME   : 김병무
 * CREATE DATE   : 2022/05/20
 * SYSTEM NAME   : POP
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/20    1.0.0   김병무         Initial Version(재작업)
 * 2022/05/31    1.0.1   김병무         재단 조회 추가
 * 2022/06/13    1.0.2   김병무         슬리터 조회 추가
 *==============================================================================
 *  관련 테이블
 * - [TB_SCH015] : (.R..) 작업지시 점보롤
 * - [TB_SCH016] : (.R..) 작업지시 밀롤, 슬리터
 * - [TB_SCH017] : (.R..) 작업지시 재단
 * - [TB_SCH018] : (.R..) 작업지시 포장
 * - [TB_INV001] : (.R..) 창고별 재고 관리
 * - [TB_WRK002] : (.R..) PS 실적
 * - [TB_MAS001] : (.R..) 플랜트별 제품/자재 마스터
 * - [TB_MAS028] : (.R..) 로케이션 관리
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK01_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리
    V_PROC_CD         VARCHAR2(2);    
    V_PACKTYPE        VARCHAR2(10);    

BEGIN
    --예외처리 시작(try)
    BEGIN
        --공정별 조회프로시저 변경
        --PS 밀롤 대기로케이션에 있는 점보롤 조회
        -- L2100 리와인더 
        -- L2200 슬리터
        -- L2300 원지포장
        -- L2400 수재단
        -- L2500 문제제품적재소
        -- L2600 포장
        -- 2500 밀롤창고 (SAP용)
        -- 2700 재단대기창고 (SAP용)
        
        SELECT PROC_CD
        INTO   V_PROC_CD    
        FROM TB_MAS012
        WHERE MACH_CD = P_MACH_CD
        ;

        IF  V_PROC_CD = 'PB'THEN
           V_PACKTYPE  := 'A' ;
        ELSIF  V_PROC_CD = 'PC' OR V_PROC_CD = 'PD' THEN
           V_PACKTYPE  := 'B' ;
        END IF;
        
        IF P_LOC_CD = 'L2100' THEN      -- 리와인더 로케이션
            --grid 컬럼 정보 설정
            --P_COLINFO := '선택@C^60|생산요청일@C^120|개별바코드@C^200|지종@C^100|평량@C^100|규격@C^150|계획 권치수@C^150|실적 권치수@C^150|상세보기@C^100|작업지시사항@C^200|비고@C^200';
            --P_COLTYPE := 'CHK@Button|PRD_REQ_DT@varchar|IND_BCD@varchar|PCODE@varchar|BS_WGT@varchar|MATNR_SPEC@varchar|JROLLCNT@varchar|ROLLCNT@varchar|DBTN@Button|ORDER_RMK@varchar|RMK@varchar';
            P_COLINFO := '선택@C^50|생산일시@C^170|오더번호@C^120|개별바코드@C^190|지종@C^90|평량@R^100|지폭@R^100|계획 권치수@R^150|투입 권치수@R^150|상세보기@C^100|작업지시사항@L^200|비고@L^200|작업지시번호@H|작업지시순번@H';
            P_COLTYPE := 'CHK@Button|PRD_DT@varchar|ORDER_NO@varchar|IND_BCD@varchar|PCODE@varchar|BS_WGT@varchar|JWIDTH@varchar|JROLLCNT@varchar|ROLLCNT@varchar|DBTN@Button|ORDER_RMK@varchar|RMK@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar';

            --지시목록 조회
            OPEN CUR_1 FOR
            SELECT '-' AS CHK
                ,TO_CHAR(W002.REGDATE, 'YYYY-MM-DD HH24:MI') AS PRD_DT -- 생산일자
                --TO_CHAR(TO_DATE(S015.PRD_REQ_DT,'YYYYMMDD'),'YYYY-MM-DD') AS PRD_REQ_DT       --생산지시일
                ,S015.ORDER_NO --I001.ORDER_NO
                ,I001.IND_BCD
                ,M001.PCODE               --지종
                ,M001.BS_WGT              --평량
                --,M001.MATNR_SPEC          --규격
                ,NVL(RTRIM(TO_CHAR(S015.JWIDTH, 'fm999,999,999,999,990.999'), '.'), '0')     JWIDTH
                ,NVL(TO_CHAR(S015.JROLLCNT, 'fm999,999,999,990'), '0') AS JROLLCNT	    --계획권치수
                ,NVL(TO_CHAR(W002.ROLLCNT, 'fm999,999,999,990'), '0') AS ROLLCNT	    --실적권치수
                ,'상세보기' AS DBTN    --상세보기
                ,S015.ORDER_RMK        --작업지시사항
                ,W002.RMK                 --비고
                ,S015.WRK_ORDR_NO       --작업지시번호
                ,S015.WRK_ORDR_SEQNO    --작업지시순번
            FROM  TB_INV001 I001    --창고별 재고 관리
                 ,TB_WRK002 W002    --제지 실적
                 ,TB_SCH015 S015    --작업지시 점보롤
                 ,TB_MAS001 M001    --플랜트별 제품/자재 마스터
            WHERE 1=1
                AND I001.WERKS = M001.WERKS
                AND I001.MATNR = M001.MATNR
                AND I001.WERKS = S015.WERKS
                AND I001.IND_BCD = W002.IND_BCD(+)
                AND I001.WRK_ORDR_NO = W002.WRK_ORDR_NO(+)
                AND I001.WRK_ORDR_SEQNO = W002.WRK_ORDR_SEQNO(+)
                --AND I001.ORDER_NO = S015.ORDER_NO
                AND I001.WRK_ORDR_NO = S015.WRK_ORDR_NO
                AND I001.WRK_ORDR_SEQNO = S015.WRK_ORDR_SEQNO
                --AND S015.PRD_REQ_DT >= P_STR_DATE
                --AND S015.PRD_REQ_DT <= P_END_DATE
                AND I001.STCK_QTY > 0               -- 공정투입하면 재고수량을 0으로 변경
                AND S015.COMP_YN = 'Y'
                AND I001.WERKS = P_WERKS
                AND I001.LOC_CD = P_LOC_CD
                AND W002.STA = '00'
                AND NVL(W002.IND_BCD,' ') LIKE '%' || P_IND_BCD || '%'
                AND NVL(W002.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
                AND NVL(M001.PCODE   ,' ') LIKE '%' || P_PCODE || '%'
                AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_BS_WGT || '%'
                AND TO_CHAR(NVL(M001.WLEN,0)) LIKE '%' || P_WLEN || '%'
                AND TO_CHAR(NVL(M001.VLEN,0)) LIKE '%' || P_VLEN || '%'
                AND NVL(S015.TO_MACHINE,'') = P_MACHINE
            ORDER BY I001.PRD_DT ASC, I001.IND_BCD ASC;
        -- 재단 'CA' OR 'CB' OR 'SA'
        ELSIF P_LOC_CD = '2700' THEN   -- 재단
            --grid 컬럼 정보 설정
            P_COLINFO := '선택@C^50|생산일시@C^170|오더번호@C^120|개별바코드@C^140|구분@C^80|지종@C^90|평량@R^100|지폭@R^100|계획 권치수@R^150|투입 권치수@R^150|상세보기@C^100|작업지시사항@L^200|비고@L^200|작업지시번호@H|작업지시순번@H';
            P_COLTYPE := 'CHK@Button|PRD_DT@varchar|ORDER_NO@varchar|IND_BCD@varchar|GU@varchar|PCODE@varchar|BS_WGT@varchar|MWIDTH@varchar|MROLLCNT@varchar|ROLLCNT@varchar|DBTN@Button|ORDER_RMK@varchar|RMK@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar';

            --지시목록 조회
            OPEN CUR_1 FOR
            SELECT
                    '-' AS CHK
                   ,PRD_DT              -- 생산일자
                   ,ORDER_NO
                   ,IND_BCD
                   ,GU
                   ,PCODE               --지종
                   ,BS_WGT              --평량
                   ,MWIDTH	            --밀롤지폭
                   ,MROLLCNT	        --계획권치수
                   ,ROLLCNT	            --실적권치수
                   ,DBTN                --상세보기
                   ,ORDER_RMK           --작업지시사항
                   ,RMK                 --비고
                   ,WRK_ORDR_NO         --작업지시번호
                   ,WRK_ORDR_SEQNO      --작업지시순번
            FROM
            (
                    /*******  정상          *************/  
                    SELECT TO_CHAR(W002.REGDATE, 'YYYY-MM-DD HH24:MI')                  PRD_DT              -- 생산일자
                        ,I001.ORDER_NO
                        ,I001.IND_BCD                                                   IND_BCD
                        ,'정상'                                                           GU                                             
                        ,M001.PCODE                                                     PCODE               --지종
                        ,M001.                                                          BS_WGT              --평량
                        ,NVL(TO_CHAR(S016.MWIDTH, 'fm999,999,999,990'), '0')            MWIDTH	            --밀롤지폭
                        ,NVL(TO_CHAR(S016.MROLLCNT, 'fm999,999,999,990'), '0')          MROLLCNT	        --계획권치수
                        ,NVL(TO_CHAR(W002.ROLLCNT, 'fm999,999,999,990'), '0')           ROLLCNT	            --실적권치수
                        ,'상세보기'                                                       DBTN                --상세보기
                        ,S016.ORDER_RMK                                                 ORDER_RMK           --작업지시사항
                        ,W002.RMK                                                       RMK                 --비고
                        ,S016.WRK_ORDR_NO                                               WRK_ORDR_NO         --작업지시번호
                        ,S016.WRK_ORDR_SEQNO                                            WRK_ORDR_SEQNO      --작업지시순번
                    FROM  TB_INV001 I001    --창고별 재고 관리
                         ,TB_WRK002 W002    --제지 실적
                         ,TB_SCH016 S016    --작업지시 밀롤
                         ,TB_MAS001 M001    --플랜트별 제품/자재 마스터
                         ,TB_MAS028 M028    --로케이션 관리
                    WHERE 1=1
                        AND I001.WERKS = M001.WERKS
                        AND I001.MATNR = M001.MATNR
                        AND I001.WERKS = S016.WERKS
                        AND I001.IND_BCD = W002.IND_BCD(+)
                        AND I001.WRK_ORDR_NO = W002.WRK_ORDR_NO(+)
                        AND I001.WRK_ORDR_SEQNO = W002.WRK_ORDR_SEQNO(+)
                        AND I001.ORDER_NO = S016.ORDER_NO
                        AND I001.WRK_ORDR_NO = S016.WRK_ORDR_NO
                        AND I001.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO
                        AND M028.LOC_CD = I001.LOC_CD(+)
                        AND I001.STCK_QTY > 0               -- 공정투입하면 재고수량을 0으로 변경 됨
                        AND S016.COMP_YN = 'Y'
                        AND NVL(I001.IN_MR_YN,'N')   = 'N'
                        AND I001.WERKS = P_WERKS
                        AND M028.MACH_CD = P_MACH_CD
                        AND NVL(W002.IND_BCD,' ') LIKE '%' || P_IND_BCD || '%'
                        AND NVL(W002.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
                        AND NVL(M001.PCODE   ,' ') LIKE '%' || P_PCODE || '%'
                        AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_BS_WGT || '%'
                        AND TO_CHAR(NVL(M001.WLEN,0)) LIKE '%' || P_WLEN || '%'
                        AND TO_CHAR(NVL(M001.VLEN,0)) LIKE '%' || P_VLEN || '%'
                 UNION  ALL
                    /*******  수입밀롤          *************/                   
                    SELECT TO_CHAR(I001.REGDATE, 'YYYY-MM-DD HH24:MI')                  PRD_DT              -- 생산일자
                        ,I001.ORDER_NO
                        ,I001.IND_BCD                                                   IND_BCD
                        ,'수입'                                                          GU                                             
                        ,M001.PCODE                                                     PCODE               --지종
                        ,M001.BS_WGT                                                    BS_WGT              --평량
                        ,NVL(TO_CHAR(M001.WLEN, 'fm999,999,999,990'), '0')              MWIDTH	            --밀롤지폭 작업지시
                        ,NVL(TO_CHAR(0, 'fm999,999,999,990'), '0')                      MROLLCNT	        --계획권치수   작업지시
                        ,NVL(TO_CHAR(I001.ROLLCNT, 'fm999,999,999,990'), '0')           ROLLCNT	            --실적권치수 
                        ,'상세보기'                                                       DBTN                --상세보기
                        ,S017.WRK_ORDR_RMK                                              ORDER_RMK           --작업지시사항
                        ,NULL                                                           RMK                 --비고
                        ,I001.WRK_ORDR_NO                                               WRK_ORDR_NO         --작업지시번호
                        ,I001.WRK_ORDR_SEQNO                                            WRK_ORDR_SEQNO      --작업지시순번
                    FROM  TB_INV001 I001    --창고별 재고 관리
                         ,TB_WRK002 W002    --제지 실적
                         ,TB_SCH017 S017    --작업지시 밀롤
                         ,TB_SCH020 S020    --
                         ,TB_MAS001 M001    --플랜트별 제품/자재 마스터
                         ,TB_MAS028 M028    --로케이션 관리
                    WHERE 1=1
                        AND I001.WERKS = M001.WERKS
                        AND I001.MATNR = M001.MATNR
                        AND I001.IND_BCD = W002.IND_BCD(+)
                        AND I001.WRK_ORDR_NO = W002.WRK_ORDR_NO(+)
                        AND I001.WRK_ORDR_SEQNO = W002.WRK_ORDR_SEQNO(+)
                        AND I001.WERKS = S017.WERKS
                        AND I001.LOT_NO = S017.PRE_ORDER_NO
                        AND S017.WRK_ORDR_NO = S020.WRK_ORDR_NO
                        AND S017.WRK_ORDR_SEQNO = S020.WRK_ORDR_SEQNO
                        AND I001.MATNR  = S020.MATNR
                        AND M028.LOC_CD = I001.LOC_CD(+)
                        AND NVL(I001.IN_MR_YN,'N')   = 'Y'
                        AND I001.STCK_QTY > 0               -- 공정투입하면 재고수량을 0으로 변경 됨
                        AND I001.WERKS = P_WERKS
                        AND M028.MACH_CD = P_MACH_CD
                        AND NVL(W002.IND_BCD,' ') LIKE '%' || P_IND_BCD || '%'
                        AND NVL(W002.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
                        AND NVL(M001.PCODE   ,' ') LIKE '%' || P_PCODE || '%'
                        AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_BS_WGT || '%'
                        AND TO_CHAR(NVL(M001.WLEN,0)) LIKE '%' || P_WLEN || '%'
                        AND TO_CHAR(NVL(M001.VLEN,0)) LIKE '%' || P_VLEN || '%'
                        --AND I001.LOC_CD = P_LOC_CD
            )            
            ORDER BY PRD_DT ASC, IND_BCD ASC;
        -- 'CB'=수재단
        ELSIF P_LOC_CD = 'L2400' THEN
            --grid 컬럼 정보 설정
            P_COLINFO := '선택@C^50|생산일시@C^170|구분@C^80|오더번호@C^140|개별바코드@C^180|지종@C^90|평량@R^100|규격@C^150|계획 연수@R^120|투입 연수@R^120|상세보기@C^100|작업지시사항@L^200|비고@L^200|작업지시번호@C^200|작업지시순번@H';
            --P_COLINFO := '생산일자@C^170|개별바코드@C^190|개별바코드@C^190|지종@C^90|평량@R^100|규격@C^150|계획 연수@R^150|실적 연수@R^150|상세보기@C^100|작업지시사항@C^200|비고@C^200|작업지시번호@H|작업지시순번@H';
            P_COLTYPE := 'CHK@Button|PRD_DT@varchar|GU@varchar|ORDER_NO@varchar|IND_BCD@varchar|PCODE@varchar|BS_WGT@varchar|MATNR_SPEC@varchar|MROLLCNT@varchar|ROLLCNT@varchar|DBTN@Button|ORDER_RMK@varchar|RMK@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar';

            --지시목록 조회
            OPEN CUR_1 FOR
            SELECT
                         '-' AS CHK
                        ,PRD_DT -- 생산일자
                        ,GU     --구분
                        ,ORDER_NO
                        ,IND_BCD
                        ,PCODE          --지종
                        ,BS_WGT          --평량
                        ,MATNR_SPEC     --규격
                        ,MROLLCNT	    --계획권치수                
                        ,ROLLCNT	        --실적권치수
                        ,DBTN    --상세보기
                        ,ORDER_RMK     --작업지시사항
                        ,RMK        --비고
                        ,WRK_ORDR_NO     --작업지시번호
                        ,WRK_ORDR_SEQNO  --작업지시순번            
            FROM 
            (
                    /*******  정상          *************/  
                    SELECT 
                         TO_CHAR(W002.REGDATE, 'YYYY-MM-DD HH24:MI') AS PRD_DT -- 생산일자
                        ,'정상'         GU            --구분
                        ,S017.ORDER_NO  ORDER_NO 
                        ,I001.IND_BCD   IND_BCD
                        ,M001.PCODE     PCODE          --지종
                        ,M001.BS_WGT    BS_WGT          --평량
                        ,SUBSTR(M001.MATNR, 10, 4) || '*' || SUBSTR(M001.MATNR, 14, 4)   MATNR_SPEC     --규격
                        ,NVL(TO_CHAR(S017.WRK_ORDR_QTY, 'fm999,999,999,990.099'), '0') AS MROLLCNT	    --계획권치수                
                        --,NVL(TO_CHAR(S017.MROLLCNT, 'fm999,999,999,999'), '0') AS MROLLCNT	    --계획권치수
                        ,NVL(TO_CHAR(W002.PCNT, 'fm999,999,999,990.099'), '0') AS ROLLCNT	        --실적권치수
                        ,'상세보기' AS DBTN    --상세보기
                        ,S017.ORDER_RMK   ORDER_RMK     --작업지시사항
                        ,W002.RMK         RMK        --비고
                        ,S017.WRK_ORDR_NO  WRK_ORDR_NO     --작업지시번호
                        ,S017.WRK_ORDR_SEQNO  WRK_ORDR_SEQNO  --작업지시순번
                    FROM  TB_INV001 I001    --창고별 재고 관리
                         ,TB_WRK002 W002    --제지 실적
                         ,TB_SCH017 S017    --작업지시 재단
                         ,TB_MAS001 M001    --플랜트별 제품/자재 마스터
                    WHERE 1=1
                        AND I001.WERKS = M001.WERKS
                        AND I001.MATNR = M001.MATNR
                        AND I001.WERKS = S017.WERKS
                        AND I001.IND_BCD = W002.IND_BCD(+)
                        AND I001.WRK_ORDR_NO = W002.WRK_ORDR_NO(+)
                        AND I001.WRK_ORDR_SEQNO = W002.WRK_ORDR_SEQNO(+)
                        --AND I001.ORDER_NO = S017.ORDER_NO
                        AND I001.WRK_ORDR_NO = S017.WRK_ORDR_NO
                        AND I001.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO
                        AND S017.MAN_CUT_YN  ='Y'
                        --AND S017.COMP_YN = 'Y'
                        AND P_MACH_CD  IN ('PCB02', 'PCB03')
                        AND I001.STCK_QTY > 0               -- 공정투입하면 재고수량을 0으로 변경
                        AND I001.WERKS = P_WERKS
                        AND I001.LOC_CD = P_LOC_CD
                        AND NVL(W002.IND_BCD,' ') LIKE '%' || P_IND_BCD || '%'
                        AND NVL(W002.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
                        AND NVL(M001.PCODE   ,' ') LIKE '%' || P_PCODE || '%'
                        AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_BS_WGT || '%'
                        AND TO_CHAR(NVL(M001.WLEN,0)) LIKE '%' || P_WLEN || '%'
                        AND TO_CHAR(NVL(M001.VLEN,0)) LIKE '%' || P_VLEN || '%'
             UNION ALL
                /*******  예외          *************/  
                SELECT     DISTINCT
                                 TO_CHAR(NVL(INV001.UPDDATE, INV001.REGDATE), 'YYYY-MM-DD HH24:MI') AS PRD_DT -- 예외생산은 생산일자 대신 자재 불출일자로 표시, UPDDATE가 NULL 이면 REGDATE 사용(WMS 재고조정시 INV001생성됨)
--                                 TO_CHAR(INV001.UPDDATE, 'YYYY-MM-DD HH24:MI') AS PRD_DT -- 예외생산은 생산일자 대신 자재 불츌일자로 표시
                                ,'예외'         GU            --구분
                                ,SCH019.ORDER_NO  ORDER_NO 
                                ,INV001.IND_BCD
                                ,/*SCH019*/ MAS001.PCODE               --지종
                                ,MAS001.BS_WGT              --평량
                                ,SUBSTR(SCH020.MATNR, 10, 4) || '*' || SUBSTR(SCH020.MATNR, 14, 4)   MATNR_SPEC     --규격
                                ,NVL(TO_CHAR(SCH019.WRK_ORDR_QTY, 'fm999,999,999,990.099'), '0') AS MROLLCNT	    --계획권치수                
                                ,NVL(TO_CHAR(/*WRK002.PCNT*/ INV001.STCK_QTY, 'fm999,999,999,990.099'), '0') AS ROLLCNT	        --실적권치수
                                ,'상세보기' AS DBTN    --상세보기
                                ,SCH019.WRK_ORDR_REMARK       --작업지시사항
                                ,WRK002.RMK                  --비고
                                ,INV001.WRK_ORDR_NO       --작업지시번호
                                ,INV001.WRK_ORDR_SEQNO    --작업지시순번
                 FROM TB_SCH019   SCH019 
                    , TB_SCH020   SCH020   
                    , TB_INV001 INV001
                    , TB_MAS001 MAS001    --플랜트별 제품/자재 마스터    
                    , TB_WRK002 WRK002    --제지 실적
                WHERE 1=1
                  AND SCH019.WERKS            =  SCH020.WERKS 
                  AND SCH019.WRK_ORDR_NO      =  SCH020.WRK_ORDR_NO 
                  AND SCH019.WRK_ORDR_SEQNO   =  SCH020.WRK_ORDR_SEQNO 
                  AND SCH020.LOT_NO           =  INV001.LOT_NO 
                  AND SCH019.ORDER_DIV        = 'ZP12'
                  AND SCH020.WERKS            =  INV001.WERKS
                  AND SCH020.MATNR            =  INV001.MATNR
                  AND SCH019.ORDER_NO = INV001.ORDER_NO
                  AND INV001.WERKS = MAS001.WERKS
                  AND INV001.MATNR = MAS001.MATNR
                  AND INV001.IND_BCD        = WRK002.IND_BCD(+)
                  AND INV001.WRK_ORDR_NO    = WRK002.WRK_ORDR_NO(+)
                  AND INV001.WRK_ORDR_SEQNO = WRK002.WRK_ORDR_SEQNO(+)
                  AND INV001.STCK_QTY > 0               -- 공정투입하면 재고수량을 0으로 변경
                  AND INV001.WERKS =  P_WERKS
                  AND ((P_MACH_CD  IN ('PCB01', 'PCB02', 'PCB03', 'PCB04') AND  SCH019.PACKTYPE = 'B'  ) OR       -- 포장타입이 SF이면 1,2,3,4수재단에서 처리 
                       (P_MACH_CD  IN ('PCB02', 'PCB03') AND SCH019.PACKTYPE = 'A'  ) )        -- 포장타입이 속포장 2,3수재단기에서 처리
                  AND SCH020.LOT_NO = INV001.LOT_NO
                  AND INV001.STOR_LOC_CD = '2000'
                  AND NVL(INV001.IND_BCD,' ')  LIKE '%' || P_IND_BCD || '%'
                  AND NVL(SCH019.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
                  AND NVL(MAS001.PCODE   ,' ') LIKE '%' || P_PCODE || '%'
                  AND TO_CHAR(NVL(MAS001.BS_WGT,0)) LIKE '%' || P_BS_WGT || '%'
                  AND TO_CHAR(NVL(MAS001.WLEN,0)) LIKE '%' || P_WLEN || '%'
                  AND TO_CHAR(NVL(MAS001.VLEN,0)) LIKE '%' || P_VLEN || '%'
                  AND NVL(SCH019.USE_YN,'Y') = 'Y'
            )    
            ORDER BY PRD_DT ASC, IND_BCD ASC;            
        -- 'SA'=슬리터
        ELSIF P_LOC_CD = 'L2200' THEN
            --grid 컬럼 정보 설정
            P_COLINFO := '선택@C^50|생산일시@C^170|구분@C^80|오더번호@C^140|개별바코드@C^190|지종@C^90|평량@R^100|지폭@R^100|계획 권치수@R^150|투입 권치수@R^150|상세보기@C^100|작업지시사항@L^200|비고@L^200|작업지시번호@H|작업지시순번@H';
            P_COLTYPE := 'CHK@Button|PRD_DT@varchar|GU@varchar|ORDER_NO@varchar|IND_BCD@varchar|PCODE@varchar|BS_WGT@varchar|MWIDTH@varchar|MROLLCNT@varchar|ROLLCNT@varchar|DBTN@Button|ORDER_RMK@varchar|RMK@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar';

            --지시목록 조회
            OPEN CUR_1 FOR
            SELECT
                         '-' AS CHK
                        ,PRD_DT          --생산일자
                        ,GU              --구분
                        ,ORDER_NO        --오더번호
                        ,IND_BCD         --개별바코드
                        ,PCODE           --지종
                        ,BS_WGT          --평량
                        ,MWIDTH	         --밀롤지폭
                        ,MROLLCNT	     --계획권치수
                        ,ROLLCNT	     --실적권치수
                        ,DBTN            --상세보기
                        ,ORDER_RMK       --작업지시사항
                        ,RMK             --비고
                        ,WRK_ORDR_NO     --작업지시번호
                        ,WRK_ORDR_SEQNO  --작업지시순번
            FROM 
            (
                        /*******  정상          *************/  
                        SELECT TO_CHAR(W002.REGDATE, 'YYYY-MM-DD HH24:MI')                  PRD_DT          -- 생산일자
                            ,'정상'                                                          GU              --구분
                            ,S016.ORDER_NO                                                  ORDER_NO 
                            ,I001.IND_BCD                                                   IND_BCD
                            ,M001.PCODE                                                     PCODE           --지종
                            ,M001.BS_WGT                                                    BS_WGT          --평량
                            ,NVL(TO_CHAR(S016.MWIDTH, 'fm999,999,999,990'), '0')            MWIDTH	        --밀롤지폭
                            ,NVL(TO_CHAR(S016.MROLLCNT, 'fm999,999,999,990'), '0')          MROLLCNT	    --계획권치수
                            ,NVL(TO_CHAR(W002.ROLLCNT, 'fm999,999,999,990'), '0')           ROLLCNT	        --실적권치수
                            ,'상세보기'                                                      DBTN            --상세보기
                            ,S016.ORDER_RMK                                                 ORDER_RMK       --작업지시사항
                            ,W002.RMK                                                       RMK             --비고
                            ,S016.WRK_ORDR_NO                                               WRK_ORDR_NO     --작업지시번호
                            ,S016.WRK_ORDR_SEQNO                                            WRK_ORDR_SEQNO  --작업지시순번
                        FROM  TB_INV001 I001    --창고별 재고 관리
                             ,TB_WRK002 W002    --제지 실적
                             ,TB_SCH016 S016    --작업지시 밀롤
                             ,TB_MAS001 M001    --플랜트별 제품/자재 마스터
                        WHERE 1=1
                            AND I001.WERKS = M001.WERKS
                            AND I001.MATNR = M001.MATNR
                            AND I001.WERKS = S016.WERKS
                            AND I001.IND_BCD = W002.IND_BCD(+)
                            AND I001.WRK_ORDR_NO = W002.WRK_ORDR_NO(+)
                            AND I001.WRK_ORDR_SEQNO = W002.WRK_ORDR_SEQNO(+)
                            AND I001.ORDER_NO = S016.ORDER_NO
                            AND I001.WRK_ORDR_NO = S016.WRK_ORDR_NO
                            AND I001.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO
                            AND S016.COMP_YN = 'Y'
                            --AND S015.PRD_REQ_DT >= P_STR_DATE
                            --AND S015.PRD_REQ_DT <= P_END_DATE
                            AND I001.STCK_QTY > 0               -- 공정투입하면 재고수량을 0으로 변경
                            AND I001.WERKS = P_WERKS
                            AND I001.LOC_CD = P_LOC_CD
                            --AND S016.TO_MACHINE = P_MACHINE
                            AND NVL(W002.IND_BCD,' ') LIKE '%' || P_IND_BCD || '%'
                            AND NVL(W002.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
                            AND NVL(M001.PCODE   ,' ') LIKE '%' || P_PCODE || '%'
                            AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_BS_WGT || '%'
                            AND TO_CHAR(NVL(M001.WLEN,0)) LIKE '%' || P_WLEN || '%'
                            AND TO_CHAR(NVL(M001.VLEN,0)) LIKE '%' || P_VLEN || '%'
                      UNION ALL
                         /*******  예외          *************/  
                         SELECT     
                                 TO_CHAR(NVL(INV001.UPDDATE, INV001.REGDATE), 'YYYY-MM-DD HH24:MI') AS PRD_DT -- 예외생산은 생산일자 대신 자재 불츌일자로 표시, UPDDATE가 NULL 이면 REGDATE 사용(WMS 재고조정시 INV001생성됨)
--                                 TO_CHAR(INV001.UPDDATE, 'YYYY-MM-DD HH24:MI') AS PRD_DT -- 예외생산은 생산일자 대신 자재 불츌일자로 표시
                                ,'예외'                          GU         --구분
                                ,SCH019.ORDER_NO                ORDER_NO 
                                ,INV001.IND_BCD                 IND_BCD     --개별바코드
                                ,SCH019.PCODE                   PCODE       --지종
                                ,M001.BS_WGT                    BS_WGT      --평량
                                ,NVL(TO_CHAR(M001.WLEN , 'fm999,999,999,999'), '0') AS MWIDTH	    -- 지폭
                                ,NVL(TO_CHAR((SCH019.WRK_ORDR_QTY / (SCH019.BS_WGT/1000) / (SCH019.WLEN / 1000)) , 'fm999,999,999,999'), '0') AS MROLLCNT	    --계획권치수
                                ,NVL(TO_CHAR((INV001.STCK_QTY / (M001.BS_WGT/1000) / (M001.WLEN / 1000)) , 'fm999,999,999,999'), '0') AS ROLLCNT	            --실적권치수
                                ,'상세보기' AS DBTN    --상세보기
                                ,SCH019.WRK_ORDR_REMARK        --작업지시사항
                                ,NULL                 --비고
                                ,SCH019.WRK_ORDR_NO       --작업지시번호
                                ,SCH019.WRK_ORDR_SEQNO    --작업지시순번
                             FROM TB_SCH019   SCH019 
                                , TB_SCH020   SCH020   
                                , TB_INV001 INV001
                                , TB_MAS001 M001    --플랜트별 제품/자재 마스터
                            WHERE 1=1
                              AND SCH019.WERKS            = SCH020.WERKS 
                              AND SCH019.WRK_ORDR_NO      =  SCH020.WRK_ORDR_NO 
                              AND SCH019.WRK_ORDR_SEQNO   =  SCH020.WRK_ORDR_SEQNO 
                              AND SCH020.LOT_NO           =  INV001.LOT_NO 
                              AND SCH019.ORDER_DIV        = 'ZP14'
                              AND SCH020.WERKS            =  INV001.WERKS
                              AND SCH020.MATNR            =  INV001.MATNR
                              AND SCH019.ORDER_NO		  =  INV001.ORDER_NO
                              AND INV001.WERKS = M001.WERKS
                              AND INV001.MATNR = M001.MATNR
                              AND INV001.STCK_QTY > 0               -- 공정투입하면 재고수량을 0으로 변경
                              AND INV001.WERKS =  P_WERKS
                              AND SCH020.LOT_NO = INV001.LOT_NO
                              AND NVL(INV001.IND_BCD,' ') LIKE '%' || P_IND_BCD || '%'
                              AND NVL(SCH019.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
                              AND NVL(M001.PCODE   ,' ') LIKE '%' || P_PCODE || '%'
                              AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_BS_WGT || '%'
                              AND TO_CHAR(NVL(M001.WLEN,0)) LIKE '%' || P_WLEN || '%'
                              AND TO_CHAR(NVL(M001.VLEN,0)) LIKE '%' || P_VLEN || '%'
            )                
            ORDER BY PRD_DT ASC, IND_BCD ASC;            
        -- 포장대기창고     = 'PB'=자동포장, 'PC'=수축포장, 'PD'=수동포장 
        ELSIF P_LOC_CD = 'L2600' THEN
            --grid 컬럼 정보 설정
            P_COLINFO := '선택@C^50|생산일시@C^170|구분@C^80|오더번호@C^140|판매오더@C^180|개별바코드@C^140|지종@C^75|평량@R^75|규격@C^120|계획연수@R^100|투입연수@R^100|포장타입@C^100|상세보기@C^100|작업지시사항@L^400|비고@L^400|작업지시번호@H|작업지시순번@H';
            P_COLTYPE := 'CHK@Button|PRD_DT@varchar|GU@varchar|ORDER_NO@varchar|SALES_ORDR_NO@varchar|IND_BCD@varchar|PCODE@varchar|BS_WGT@varchar|MATNR_SPEC@varchar|WRK_ORDR_QTY@varchar|PRFM_QTY@varchar|PACK_TYPE_NM@varchar|DBTN@Button|ORDER_RMK@varchar|RMK@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar';

            --지시목록 조회
            OPEN CUR_1 FOR
            SELECT
                    '-' AS CHK
                   ,PRD_DT         -- 생산일자
                   ,GU     --구분
                   ,ORDER_NO
                   ,SALES_ORDR_NO    --세일즈오더번호
                   ,IND_BCD                    
                   ,PCODE           --지종
                   ,BS_WGT         --평량
                   ,MATNR_SPEC     --규격
                   ,WRK_ORDR_QTY	--생산지시연수
                   ,PRFM_QTY	    --실적연수
                   ,PACK_TYPE_NM       --포장타입명
                   ,DBTN           --상세보기
                   ,ORDER_RMK       --작업지시사항
                   ,RMK             --비고
                   ,WRK_ORDR_NO     --작업지시번호
                   ,WRK_ORDR_SEQNO  --작업지시순번
            FROM
            (
                    /*******  포장 정상          *************/  
                    SELECT TO_CHAR(W002.REGDATE, 'YYYY-MM-DD HH24:MI')                                      PRD_DT         -- 생산일자
                        ,'정상'         GU            --구분
                        ,S017.ORDER_NO  ORDER_NO 
                        ,S017.VBELN || LPAD(S017.POSNR, 6, '0')    SALES_ORDR_NO            --Sales Order No
                        ,I001.IND_BCD                                                                       IND_BCD                    
                        ,M001.PCODE                                                                         PCODE           --지종
                        ,M001.BS_WGT                                                                        BS_WGT         --평량
                        ,SUBSTR(M001.MATNR, 10, 4) || '*' || SUBSTR(M001.MATNR, 14, 4)                      MATNR_SPEC     --규격
                        ,NVL(RTRIM(TO_CHAR(S017.WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0')      WRK_ORDR_QTY	--생산지시연수
                        ,NVL(RTRIM(TO_CHAR(W002.PRFM_QTY / 500, 'fm999,999,999,999,990.999'), '.'), '0')          PRFM_QTY	    --실적연수
                        ,FN_CD_VAL('PACK_TYPE', S017.PACKTYPE)                                              PACK_TYPE_NM   --포장타입
                        ,'상세보기'                                                                           DBTN           --상세보기
                        ,S017.ORDER_RMK                                                                     ORDER_RMK       --작업지시사항
                        ,W002.RMK                                                                           RMK             --비고
                        ,S017.WRK_ORDR_NO                                                                   WRK_ORDR_NO     --작업지시번호
                        ,S017.WRK_ORDR_SEQNO                                                                WRK_ORDR_SEQNO  --작업지시순번
                    FROM  TB_INV001 I001    --창고별 재고 관리
                         ,TB_WRK002 W002    --제지 실적
                         ,TB_SCH017 S017    --작업지시 재단
                         ,TB_MAS001 M001    --플랜트별 제품/자재 마스터
                    WHERE 1=1
                        AND I001.WERKS = M001.WERKS
                        AND I001.MATNR = M001.MATNR
                        AND I001.WERKS = S017.WERKS
                        AND I001.IND_BCD = W002.IND_BCD(+)
                        AND I001.WRK_ORDR_NO = W002.WRK_ORDR_NO(+)
                        AND I001.WRK_ORDR_SEQNO = W002.WRK_ORDR_SEQNO(+)
                        AND I001.ORDER_NO = S017.ORDER_NO
                        AND I001.WRK_ORDR_NO = S017.WRK_ORDR_NO
                        AND I001.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO
                        AND I001.STCK_QTY > 0               -- 공정투입하면 재고수량을 0으로 변경
                        --AND S017.COMP_YN = 'Y'
                        AND S017.PACKTYPE  = V_PACKTYPE
                        AND I001.WERKS = P_WERKS
                        AND I001.LOC_CD = P_LOC_CD
                        AND I001.STOR_LOC_CD = '2000'
                        AND I001.STCK_STA = '00'
                        AND SUBSTR(P_MACH_CD,1,3)  IN ( 'PPB','PPC')  --
                        AND NVL(W002.IND_BCD,' ') LIKE '%' || P_IND_BCD || '%'
                        AND NVL(W002.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
                        AND NVL(M001.PCODE   ,' ') LIKE '%' || P_PCODE || '%'
                        AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_BS_WGT || '%'
                        AND TO_CHAR(NVL(M001.WLEN,0)) LIKE '%' || P_WLEN || '%'
                        AND TO_CHAR(NVL(M001.VLEN,0)) LIKE '%' || P_VLEN || '%'
                    UNION ALL
                        /*******  포장 예외          *************/  
                        SELECT     
                                 TO_CHAR(NVL(INV001.UPDDATE, INV001.REGDATE), 'YYYY-MM-DD HH24:MI') AS PRD_DT -- 예외생산은 생산일자 대신 자재 불츌일자로 표시, UPDDATE가 NULL 이면 REGDATE 사용(WMS 재고조정시 INV001생성됨)
--                                 TO_CHAR(INV001.UPDDATE, 'YYYY-MM-DD HH24:MI') AS PRD_DT -- 예외생산은 생산일자 대신 자재 불츌일자로 표시
                                ,'예외'         GU            --구분
                                ,SCH019.ORDER_NO  ORDER_NO 
                                ,SCH019.VBELN || LPAD(SCH019.POSNR, 6, '0')                  SALES_ORDR_NO            --Sales Order No
                                ,INV001.IND_BCD
                                ,SCH019.PCODE               --지종
                                ,M001.BS_WGT              --평량
                                ,SUBSTR(SCH020.MATNR, 10, 4) || '*' || SUBSTR(SCH020.MATNR, 14, 4)   MATNR_SPEC     --규격
--                                        ,NVL(RTRIM(TO_CHAR((SCH019.WRK_ORDR_QTY / (SCH019.BS_WGT/1000) / (SCH019.WLEN / 1000)), 'fm999,999,999,999,990.999'), '.'), '0')          MROLLCNT	    --계획연수
                                ,NVL(RTRIM(TO_CHAR(SCH019.WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0')          MROLLCNT	    --계획연수
                                ,NVL(RTRIM(TO_CHAR(INV001.STCK_QTY, 'fm999,999,999,999,990.999'), '.'), '0')          ROLLCNT 	    --실적연수
                                --,FN_CD_VAL('PACK_TYPE', SCH019.PACKTYPE)                               PACK_TYPE_NM   --포장타입
                                ,FN_CD_VAL('PACK_TYPE', SUBSTR(SCH019.MATNR, -1))                    PACK_TYPE_NM   --포장타입
                                ,'상세보기' AS DBTN    --상세보기
                                ,SCH019.WRK_ORDR_REMARK        --작업지시사항
                                ,NULL                      --비고
                                ,SCH019.WRK_ORDR_NO       --작업지시번호
                                ,SCH019.WRK_ORDR_SEQNO    --작업지시순번
                             FROM TB_SCH019     SCH019 
                                , TB_SCH020     SCH020   
                                , TB_INV001     INV001
                                , TB_MAS001     M001    --플랜트별 제품/자재 마스터
                            WHERE 1=1
                              AND SCH019.WERKS            = SCH020.WERKS 
                              AND SCH019.WRK_ORDR_NO      =  SCH020.WRK_ORDR_NO 
                              AND SCH019.WRK_ORDR_SEQNO   =  SCH020.WRK_ORDR_SEQNO 
                              AND SCH020.LOT_NO           =  INV001.LOT_NO 
                              AND SCH019.ORDER_DIV        = 'ZP13'
                              AND SCH020.WERKS            =  INV001.WERKS
                              AND SCH020.MATNR            =  INV001.MATNR
                              AND SCH019.ORDER_NO		  =  INV001.ORDER_NO
                              AND INV001.WERKS = M001.WERKS
                              AND INV001.MATNR = M001.MATNR
                              AND INV001.STCK_QTY > 0               -- 공정투입하면 재고수량을 0으로 변경
                              --AND SCH019.PACKTYPE  = V_PACKTYPE       -- 포장타입 확인
                              AND SUBSTR(SCH019.MATNR, -1) = V_PACKTYPE -- 예외생산 오더에 포장 타입이 내려오지 않아서, 자재코드의 마지막 문자열을 확인하여 포장타입 확인
                              --AND (CASE WHEN SCH019.PACKTYPE IS NULL THEN SUBSTR(SCH019.MATNR, -1) ELSE SCH019.PACKTYPE END) = V_PACKTYPE
                              AND INV001.WERKS =  P_WERKS
                              AND INV001.STOR_LOC_CD = '2000'
                              AND INV001.STCK_STA = '00'
                              --AND SUBSTR(P_MACH_CD,1,3)  IN ('PPD', 'PPB')  -- 예외생산 SF포장은 예외생산 포장 1호기(PPD), 자동포장은 2층 자동포장기(PPB) 에서 처리함.
                              AND SUBSTR(P_MACH_CD,1,3)  IN ('PPB', 'PPC', 'PPD')  -- 예외생산 SF포장은 예외생산 포장 1호기(PPD), 자동포장은 2층 자동포장기(PPB) 에서 처리함. 230131 - 예외생산 SF포장은 SF 3호기에서 사용하기로 하여 SF 포장 추가.
                              AND NVL(INV001.IND_BCD,' ') LIKE '%' || P_IND_BCD || '%'
                              AND NVL(SCH019.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
                              AND NVL(M001.PCODE   ,' ') LIKE '%' || P_PCODE || '%'
                              AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_BS_WGT || '%'
                              AND TO_CHAR(NVL(M001.WLEN,0)) LIKE '%' || P_WLEN || '%'
                              AND TO_CHAR(NVL(M001.VLEN,0)) LIKE '%' || P_VLEN || '%'
            )
            ORDER BY PRD_DT, IND_BCD;
        --문재적재소
        ELSIF P_LOC_CD = 'L2500' THEN     
            --grid 컬럼 정보 설정
            P_COLINFO := '선택@C^50|생산일시@C^170|오더번호@C^140|판매오더@C^180|개별바코드@C^140|지종@C^90|평량@R^90|규격@C^120|계획연수@R^100|투입연수@R^100|부적합연수@R^100|포장타입@C^100|상세보기@C^100|작업지시사항@L^400|비고@L^400|작업지시번호@H|작업지시순번@H';
            P_COLTYPE := 'CHK@Button|PRD_DT@varchar|ORDER_NO@varchar|SALES_ORDR_NO@varchar|IND_BCD@varchar|PCODE@varchar|BS_WGT@varchar|MATNR_SPEC@varchar|WRK_ORDR_QTY@varchar|PRFM_QTY@varchar|UCFMTY_AMT@varchar|PACK_TYPE_NM@varchar|DBTN@Button|ORDER_RMK@varchar|RMK@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar';

            --지시목록 조회
            OPEN CUR_1 FOR
            SELECT
                    '-' AS CHK
                   ,PRD_DT         -- 생산일자
                   ,ORDER_NO
                   ,SALES_ORDR_NO    --세일즈오더번호
                   ,IND_BCD                    
                   ,PCODE           --지종
                   ,BS_WGT         --평량
                   ,MATNR_SPEC     --규격
                   ,WRK_ORDR_QTY    --계획연수
                   ,PRFM_QTY 	    --실적연수
                   ,UCFMTY_AMT 	    --부적합연수
                   ,PACK_TYPE_NM       --포장타입명
                   ,DBTN           --상세보기
                   ,ORDER_RMK       --작업지시사항
                   ,RMK             --비고
                   ,WRK_ORDR_NO     --작업지시번호
                   ,WRK_ORDR_SEQNO  --작업지시순번
            FROM
            (
                    /*******  문재적재소          *************/
                    SELECT TO_CHAR(W002.REGDATE, 'YYYY-MM-DD HH24:MI')                                      PRD_DT         -- 생산일자
                        ,S017.ORDER_NO                                                                      ORDER_NO 
                        ,S017.VBELN || LPAD(S017.POSNR, 6, '0')    SALES_ORDR_NO            --Sales Order No
                        ,I001.IND_BCD                                                                       IND_BCD
                        ,M001.PCODE                                                                         PCODE           --지종
                        ,M001.BS_WGT                                                                        BS_WGT         --평량
                        ,SUBSTR(M001.MATNR, 10, 4) || '*' || SUBSTR(M001.MATNR, 14, 4)                      MATNR_SPEC     --규격
                        ,NVL(RTRIM(TO_CHAR(S017.WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0')      WRK_ORDR_QTY     	--계획연수
                        ,NVL(RTRIM(TO_CHAR(W002.PRFM_QTY/500, 'fm999,999,999,999,990.999'), '.'), '0')      PRFM_QTY 	    --실적연수
                        ,NVL(RTRIM(TO_CHAR(I001.UCFMTY_AMT/500, 'fm999,999,999,999,990.999'), '.'), '0')    UCFMTY_AMT 	    --부적합연수
                        ,FN_CD_VAL('PACK_TYPE', S017.PACKTYPE)                                              PACK_TYPE_NM   --포장타입
                        ,'상세보기'                                                                           DBTN           --상세보기
                        ,S017.ORDER_RMK                                                                     ORDER_RMK       --작업지시사항
                        ,W002.RMK                                                                           RMK             --비고
                        ,S017.WRK_ORDR_NO                                                                   WRK_ORDR_NO     --작업지시번호
                        ,S017.WRK_ORDR_SEQNO                                                                WRK_ORDR_SEQNO  --작업지시순번
                    FROM  TB_INV001 I001    --창고별 재고 관리
                         ,TB_WRK002 W002    --제지 실적
                         ,TB_SCH017 S017    --작업지시 재단
                         ,TB_MAS001 M001    --플랜트별 제품/자재 마스터
                    WHERE 1=1
                      AND I001.WERKS = M001.WERKS
                      AND I001.MATNR = M001.MATNR
                      AND I001.WERKS = S017.WERKS
                      AND I001.IND_BCD = W002.IND_BCD(+)
                      AND I001.WRK_ORDR_NO = W002.WRK_ORDR_NO(+)
                      AND I001.WRK_ORDR_SEQNO = W002.WRK_ORDR_SEQNO(+)
                      AND I001.ORDER_NO = S017.ORDER_NO
                      AND I001.WRK_ORDR_NO = S017.WRK_ORDR_NO
                      AND I001.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO
                      AND I001.STCK_QTY > 0               -- 공정투입하면 재고수량을 0으로 변경
                      --AND S017.COMP_YN   = 'Y'
                      AND I001.WERKS = P_WERKS
                      AND I001.LOC_CD = P_LOC_CD
            )
            ORDER BY PRD_DT ASC, IND_BCD ASC;

        END IF;
        --작업 정상 종료 코드 등록
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
