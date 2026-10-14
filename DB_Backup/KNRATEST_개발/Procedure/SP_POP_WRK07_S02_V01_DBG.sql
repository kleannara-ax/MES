--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK07_S02_V01_DBG
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK07_S02_V01_DBG" 
(
     P_WERKS        IN VARCHAR2
    ,P_PROC_CD      IN VARCHAR2
    ,P_MACH_CD      IN VARCHAR2
    ,P_IOTYPE       IN VARCHAR2
    ,P_MACHINE      IN VARCHAR2
    ,P_PRD_STR_DATE IN VARCHAR2     --YYYYMMDD
    ,P_PRD_END_DATE IN VARCHAR2     --YYYYMMDD
    ,P_PCODE        IN VARCHAR2     --지종
    ,P_WEIGHT       IN VARCHAR2     --평량
    ,P_MATNR        IN VARCHAR2     --자재코드
    ,P_WLEN         IN VARCHAR2     --가로
    ,P_VLEN         IN VARCHAR2     --세로
    ,P_LOT_NO       IN VARCHAR2     --LOT_NO
    ,P_ORDER_NO       IN VARCHAR2   --ORDER_NO
    ,P_USERID       IN VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK07
 * PROGRAM NAME  : PS 작업지시 목록조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 현재 설비의 작업지시 목록을 조회한다.
 *                 
 * AUTHOR NAME   : 김병무
 * CREATE DATE   : 2022/05/11
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/31    1.0.0   김병무         HL과 PS의 작업지시 조회를 분리함. (SP_POP_WRK07_S01=HL, SP_POP_WRK07_S02=PS)
 *==============================================================================
 *  관련 테이블
 * - [TB_SCH015] : (.R..) 제지 점보롤작업지시
 * - [TB_SCH016] : (.R..) 제지 밀롤작업지시
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 * - [TB_WRK002] : (.R..) PS 생산실적 이력
 * - [TB_INV003] : (.R..) 자재 투입 정보 (공정투입된 반제품)
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK07_S02';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리
    V_COLINFO VARCHAR2(1000);--컬럼설정1
    V_COLTYPE VARCHAR2(1000);--컬럼설정2
    V_WRK_CD VARCHAR2(8);--설비별 작업장코드

    V_WRK_ORDR_NO       TB_WRK011.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO    TB_WRK011.WRK_ORDR_SEQNO%TYPE;
    V_MATNR             TB_WRK011.MATNR%TYPE;
BEGIN
    --예외처리 시작(try)
    BEGIN

        --공정별 조회프로시저 변경
        IF P_PROC_CD = 'JA' THEN  -- 제지 점보롤 작업지시
            --grid 컬럼 정보 설정
            V_COLINFO := '선택@C^60|생산요청일@C^120|작업지시번호@C^200|순번@C^50|오더번호@C^130|지종@C^80|지종명@H|평량@R^80|계획권치수@R^120|계획량@H|단위@H|생산유형@C^100|이동호기@C^100|지시사항@H|상세보기@C^100|자재코드@H|자재명@H';
            V_COLTYPE := 'CHK@Button|PRD_REQ_DT@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|ORDER_NO@varchar|PCODE@varchar|PCODE_NM@varchar|BS_WGT@varchar|JROLLCNT@varchar|WRK_ORDR_QTY@varchar|UNIT@varchar|PRDTYPETXT@varchar|TO_MACHINE@varchar|ORDER_RMK@varchar|DBTN@Button|MATNR@varchar|MATNR_NM@varchar';

            --컬럼설정 반환 테이블 작성
            OPEN CUR_1 FOR
            SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

            --지시목록 조회
            OPEN CUR_2 FOR
            SELECT /*+ ORDERED */
                   '-' AS CHK
                 , TO_CHAR(TO_DATE(S015.PRD_REQ_DT,'YYYYMMDD'),'YYYY-MM-DD') AS PRD_REQ_DT       --생산지시일
                 , S015.WRK_ORDR_NO       AS WRK_ORDR_NO  --작업지시
                 , S015.WRK_ORDR_SEQNO    AS WRK_ORDR_SEQNO  --작업지시 순번
                 , S015.ORDER_NO           --오더번호
                 , M001.PCODE                                   AS PCODE        --지종
                 , M001.PCODE_NM                                AS PCODE_NM     --지종명
                 , TO_CHAR(M001.BS_WGT, 'fm999,999,999,990')    AS BS_WGT       --평량
                 , TO_CHAR(S015.JROLLCNT, 'fm999,999,999,990') AS JROLLCNT	    --점보롤 계획권치수
                 , S015.WRK_ORDR_QTY        --지시수량
                 , S015.UNIT                --단위
                 , S015.PRDTYPETXT          --생산유형
                 , s015.TO_MACHINE          --이동호기
                 , S015.ORDER_RMK        --작업지시사항
                 , '상세보기' AS DBTN    --상세보기
                 , S015.MATNR               --자재코드
                 , M001.MATNR_NM            --자재명
              FROM TB_SCH015 S015, --제지 점보롤작업지시
                   TB_MAS001 M001  --자재정보
             WHERE 1=1
               AND S015.WERKS = M001.WERKS
               AND S015.MATNR = M001.MATNR
               AND S015.WERKS = P_WERKS
               AND S015.PRD_REQ_DT >= P_PRD_STR_DATE
               AND S015.PRD_REQ_DT <= P_PRD_END_DATE
               AND NVL(S015.ORDER_NO,' ') LIKE P_ORDER_NO || '%'
               AND NVL(M001.PCODE,' ') LIKE P_PCODE || '%'
               AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE P_WEIGHT || '%'
               AND NVL(S015.MATNR,' ') LIKE P_MATNR || '%'
               AND S015.MACHINE = P_MACHINE
               --AND S015.COMP_YN = 'N'
               AND S015.COMP_YN IN ('N','I')
--               AND S015.DLFL = 'N'  --삭제지시자 X='삭제' , N=정상오더
               AND S015.USE_YN = 'Y'
               --AND S015.WRK_CD = V_WRK_CD
             ORDER BY S015.PRD_REQ_DT ASC, S015.WRK_SEQNO ASC,S015.WRK_ORDR_NO ASC, S015.WRK_ORDR_SEQNO ASC;

        ELSIF P_PROC_CD = 'MA' THEN     -- PS 투입정보(MA : 리와인더)
            --grid 컬럼 정보 설정
            V_COLINFO := '선택@C^60|투입일시@C^170|오더구분@H|오더번호@C^130|자재코드@C^200|계획권치수@R^120|투입권치수@R^120|지종@C^70|지종명@H|평량@R^70|지폭@R^90|지시사항@H|작업지시번호@C^200|순번@C^50|상세보기@C^100';
            V_COLTYPE := 'CHK@Button|INP_DT@varchar|ORDER_GB@varchar|ORDER_NO@varchar|MATNR@varchar|JROLLCNT@varchar|ROLLCNT@varchar|PCODE@varchar|PCODE_NM@varchar|BS_WGT@varchar|JWIDTH@varchar|ORDER_RMK@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|DBTN@Button';

            --컬럼설정 반환 테이블 작성
            OPEN CUR_1 FOR
            SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

            --투입정보
            OPEN CUR_2 FOR
            SELECT /*+ ORDERED */
                    '-' AS CHK
                   , TO_CHAR(W000.REGDATE, 'YYYY-MM-DD HH24:MI') AS INP_DT -- 투입일시
                   , ''   AS ORDER_GB    --오더구분    
                   , S015.ORDER_NO           --오더번호
                   , M001.MATNR              --점보롤 자재코드
                   , TO_CHAR(S015.JROLLCNT, 'fm999,999,999,990') AS JROLLCNT	--점보롤 계획권치수
                   , TO_CHAR(W000.ROLLCNT, 'fm999,999,999,990') AS ROLLCNT	    --점보롤 실적권치수
                   , S015.PCODE              --지종
                   , M001.PCODE_NM           --지종명                
                   , M001.BS_WGT             --평량
                   , TO_CHAR(S015.JWIDTH, 'fm999,999,999,990') AS JWIDTH	    --점보롤 지폭
                   , S015.ORDER_RMK       --작업지시사항
                   , S015.WRK_ORDR_NO        --점보롤 작업지시번호
                   , S015.WRK_ORDR_SEQNO     --점보롤 작업지시번호 순번
                   , '상세보기' AS DBTN    --상세보기
              FROM 
--                    (SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO, MATNR, MAX(REGDATE) AS REGDATE
--                      FROM TB_INV003
--                     WHERE WERKS = P_WERKS
--                        AND MACH_CD = P_MACH_CD
--                        AND NVL(LOT_NO,' ') LIKE P_LOT_NO || '%'
--                        AND INP_DT BETWEEN P_PRD_STR_DATE AND P_PRD_END_DATE
--                     GROUP BY WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO, MATNR
--                      ) I003,
                     (SELECT W002.WERKS, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO, I003.MATNR, I003.REGDATE,
                            SUM(W002.ROLLCNT) ROLLCNT, SUM(W002.WGT) WGT
                        FROM(
                            SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO, MATNR, MAX(REGDATE) AS REGDATE
                              FROM TB_INV003
                             WHERE WERKS = P_WERKS
                                AND MACH_CD = P_MACH_CD
                                AND INP_DT BETWEEN P_PRD_STR_DATE AND P_PRD_END_DATE
                                --AND TO_CHAR(REGDATE, 'YYYYMMDD') BETWEEN P_PRD_STR_DATE AND P_PRD_END_DATE
                             GROUP BY WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO, MATNR
                            ) I003,
                            TB_WRK002 W002
                         WHERE I003.WERKS = W002.WERKS(+)
                           AND I003.WRK_ORDR_NO = W002.WRK_ORDR_NO(+)
                           AND I003.WRK_ORDR_SEQNO = W002.WRK_ORDR_SEQNO(+)  
                           AND W002.RUN_STA IN ( '01' ,'09'  )                           -- 운전상태 01 : 정상생산, 09 : 비계획생산
                           AND NVL(W002.CNL_YN,'N') = 'N'
                        GROUP BY W002.WERKS, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO, I003.MATNR, I003.REGDATE  
                     ) W000,
                   TB_SCH015 S015,
                   TB_MAS001 M001
             WHERE W000.WERKS = S015.WERKS
               AND W000.WRK_ORDR_NO = S015.WRK_ORDR_NO
               AND W000.WRK_ORDR_SEQNO = S015.WRK_ORDR_SEQNO
               --AND I003.WERKS = W000.WERKS(+)
               --AND I003.WRK_ORDR_NO = W000.WRK_ORDR_NO(+)
               --AND I003.WRK_ORDR_SEQNO = W000.WRK_ORDR_SEQNO(+)
               AND W000.WERKS = M001.WERKS
               AND W000.MATNR = M001.MATNR
               AND NVL(W000.MATNR,' ') LIKE P_MATNR || '%'
               AND NVL(M001.PCODE,' ') LIKE P_PCODE || '%'
               AND NVL(S015.ORDER_NO,' ') LIKE P_ORDER_NO || '%'
               AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE P_WEIGHT || '%'
               AND S015.COMP_YN = 'Y'
--               AND S015.DLFL = 'N'  --삭제지시자 X='삭제' , N=정상오더
               AND S015.USE_YN = 'Y'

               /*AND ('Y')   IN  NVL(( SELECT  'Y'
                                    FROM TB_SCH016   SCH016
                                    WHERE S015.ORDER_NO  = SCH016.PRE_ORDER_NO
                                      AND S015.WERKS     = SCH016.WERKS
                                      AND NVL(SCH016.COMP_YN,'N')  IN ('N','I')
                               ),'Y')
               */                
               AND  1  <= ( SELECT  NVL(COUNT(*),1)
                                    FROM TB_SCH016   SCH016
                                    WHERE S015.ORDER_NO  = SCH016.PRE_ORDER_NO
                                      AND S015.WERKS     = SCH016.WERKS
                                      AND NVL(SCH016.COMP_YN,'N')  IN ('N','I')
                           )
               ORDER BY W000.REGDATE ASC, S015.WRK_SEQNO ASC, S015.WRK_SEQNO ASC,S015.WRK_ORDR_NO ASC, S015.WRK_ORDR_SEQNO ASC;

        ELSIF P_PROC_CD = 'CA' THEN     -- PS 투입정보(CA : 재단)
            --grid 컬럼 정보 설정
            V_COLINFO := '선택@C^60|투입일시@C^170|오더구분@C^80|오더번호@C^130|자재코드@C^200|계획권치수@R^120|투입권치수@R^120|지종@C^70|지종명@H|지폭@R^100|오더유형@C^80|지시사항@H|작업지시번호@C^200|순번@C^50|상세보기@C^100|LOT@H';
            V_COLTYPE := 'CHK@Button|INP_DT@varchar|ORDER_GB@varchar|ORDER_NO@varchar|MATNR@varchar|MROLLCNT@varchar|ROLLCNT@varchar|PCODE@varchar|PCODE_NM@varchar|MWIDTH@varchar|ORDER_DIV@varchar|ORDER_RMK@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|DBTN@Button|LOT_NO@varchar';

            --컬럼설정 반환 테이블 작성
            OPEN CUR_1 FOR
            SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

            --투입정보
            OPEN CUR_2 FOR
            SELECT  DISTINCT
                    CHK
                   ,INP_DT          -- 투입일시
                   ,ORDER_GB       --오더구분    
                   ,ORDER_NO        --오더번호
                   ,MATNR           --밀롤 자재코드
                   ,MROLLCNT	    --밀롤 계획권치수
                   ,ROLLCNT	        --밀롤 실적권치수
                   ,PCODE           --지종
                   ,PCODE_NM        --지종명                
                   ,MWIDTH	        --밀롤 지폭
                   ,ORDER_DIV       --오더유형
                   ,ORDER_RMK       --작업지시사항
                   ,WRK_ORDR_NO     --밀롤 작업지시번호
                   ,WRK_ORDR_SEQNO  --밀롤 작업지시번호 순번
                   ,DBTN            --상세보기
                   ,LOT_NO
            FROM
            (
                    SELECT /*+ ORDERED */
                           '-' AS CHK
                           , TO_CHAR(W000.REGDATE, 'YYYY-MM-DD HH24:MI')    					INP_DT 			-- 투입일시
                           , DECODE(NVL(W000.IN_MR_YN, 'N'), 'N', '정상', '수입')					ORDER_GB    	--오더구분    
	                       , S016.ORDER_NO														ORDER_NO    	--오더번호
	                       , W000.MATNR                                     					MATNR       	--밀롤 자재코드
	                       , TO_CHAR(S016.MROLLCNT, 'fm999,999,999,990')    					MROLLCNT		--밀롤 계획권치수
                           , TO_CHAR(W000.ROLLCNT, 'fm999,999,999,990')     					ROLLCNT	    	--밀롤 실적권치수
                           , S016.PCODE                                     					PCODE       	--지종
                           , M001.PCODE_NM                                  					PCODE_NM    	--지종명                
                           , TO_CHAR(S016.MWIDTH, 'fm999,999,999,990')      					MWIDTH	    	--밀롤 지폭
                           , S016.ORDER_DIV                                 					ORDER_DIV   	--오더유형
                           , S016.ORDER_RMK                                 					ORDER_RMK   	--작업지시사항
                           , W000.WRK_ORDR_NO                               					WRK_ORDR_NO   	--밀롤 작업지시번호
                           , W000.WRK_ORDR_SEQNO                            					WRK_ORDR_SEQNO	--밀롤 작업지시번호 순번
                           , '상세보기'                                       						DBTN    		--상세보기
                           , DECODE(NVL(W000.IN_MR_YN, 'N'), 'N', NULL, S016.ORDER_NO)			LOT_NO
                      FROM 
--                            (SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO, MATNR, MAX(REGDATE) AS REGDATE
--                              FROM TB_INV003
--                             WHERE WERKS = P_WERKS
--                                AND MACH_CD = P_MACH_CD
--                                AND NVL(LOT_NO,' ') LIKE P_LOT_NO || '%'
--                                AND INP_DT BETWEEN P_PRD_STR_DATE AND P_PRD_END_DATE
--                             GROUP BY WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO, MATNR   
--                              ) I003,
                             (SELECT I001.WERKS, I003.WRK_ORDR_NO, I003.WRK_ORDR_SEQNO, I001.MATNR, I001.LOT_NO, I001.IND_BCD,
                                    SUM(I001.ROLLCNT) ROLLCNT, SUM(I001.WGT) WGT, I001.IN_MR_YN, MAX(I003.REGDATE) AS REGDATE
                                FROM TB_INV003 I003, TB_INV001 I001 
                               WHERE I003.WERKS = I001.WERKS(+)
                                   --AND I003.WRK_ORDR_NO = I001.WRK_ORDR_NO(+)
                                   --AND I003.WRK_ORDR_SEQNO = I001.WRK_ORDR_SEQNO(+)  
                                 AND I003.IND_BCD = I001.IND_BCD(+)
                                 AND I003.WERKS = P_WERKS
                                 AND I003.MACH_CD = P_MACH_CD
                                 AND NVL(I003.LOT_NO,' ') LIKE P_LOT_NO || '%'
                                 AND TO_CHAR(I003.REGDATE, 'YYYYMMDD') BETWEEN P_PRD_STR_DATE AND P_PRD_END_DATE
        --                           AND I001.RUN_STA = '01'                              -- 운전상태 01 : 정상생산, 08 : 비계획생산
                                 AND NVL(I001.DLFL, 'N') = 'N'
                               GROUP BY I001.WERKS, I003.WRK_ORDR_NO, I003.WRK_ORDR_SEQNO, I001.MATNR, I001.LOT_NO, I001.IND_BCD, I001.IN_MR_YN
                             ) W000,
                           TB_SCH016 S016,
                           TB_SCH017 S017,
                           TB_MAS001 M001
                     WHERE W000.WERKS = S016.WERKS
                       AND W000.WRK_ORDR_NO = S016.WRK_ORDR_NO
                       AND W000.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO
                       --AND I003.WERKS = W000.WERKS(+)
                       --AND I003.WRK_ORDR_NO = W000.WRK_ORDR_NO(+)
                       --AND I003.WRK_ORDR_SEQNO = W000.WRK_ORDR_SEQNO(+)
                       AND W000.WERKS = M001.WERKS
                       AND W000.MATNR = M001.MATNR
                       AND NVL(M001.PCODE,' ') LIKE P_PCODE || '%'
                       AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE P_WEIGHT || '%'
                       AND S016.ORDER_NO = S017.PRE_ORDER_NO
                       AND S016.COMP_YN = 'Y'
--                       AND S016.DLFL = 'N'  --삭제지시자 X='삭제' , N=정상오더
                       AND S016.USE_YN = 'Y'
                       AND S017.COMP_YN IN ('N', 'I')
                       AND S017.USE_YN  = 'Y'
                       AND NVL(S016.ORDER_NO,' ') LIKE P_ORDER_NO || '%'
                       /*AND  1 >= ( SELECT  NVL(SUM(1), 0)
                                            FROM TB_SCH017   SCH017
                                            WHERE S016.WERKS     = SCH017.WERKS
                                              AND S016.ORDER_NO  = SCH017.PRE_ORDER_NO
                                              AND NVL(SCH017.COMP_YN,'N')  IN ('N','I')
                                      )
                       */
                       AND  1  <= ( SELECT  NVL(COUNT(*),1)
                                      FROM TB_SCH017   SCH017
                                     WHERE S016.WERKS = SCH017.WERKS
                                       AND S016.ORDER_NO = SCH017.PRE_ORDER_NO
                                       AND NVL(SCH017.COMP_YN,'N')  IN ('N','I')
                                        )
                --UNION ALL
                --    SELECT /*+ ORDERED */
                --            '-' AS CHK
                --           , TO_CHAR(W000.REGDATE, 'YYYY-MM-DD HH24:MI')    INP_DT          --투입일시
                --           , '수입'                                          ORDER_GB       --오더구분    
                --           , W000.LOT_NO                                    ORDER_NO        --오더번호
                --           , W000.MATNR                                     MATNR           --밀롤 자재코드
                --           , TO_CHAR(0, 'fm999,999,999,990')                MROLLCNT	    --밀롤 계획권치수
                --           , TO_CHAR(W000.ROLLCNT, 'fm999,999,999,990')     ROLLCNT	        --밀롤 실적권치수
                --           , M001.PCODE                                     PCODE           --지종
                --           , M001.PCODE_NM                                  PCODE_NM        --지종명    
                --           , TO_CHAR(M001.WLEN, 'fm999,999,999,990')        MWIDTH	        --밀롤 지폭
                --           , NULL                                           ORDER_DIV       --오더유형
                --           , NULL                                           ORDER_RMK       --작업지시사항
                --           , NULL                                           WRK_ORDR_NO     --밀롤 작업지시번호
                --           , NULL                                           WRK_ORDR_SEQNO  --밀롤 작업지시번호 순번
                --           , '상세보기'                                       DBTN            --상세보기
                --           , W000.LOT_NO                                    LOT_NO
                --      FROM 
--              --              (SELECT WERKS,  LOT_NO ,MATNR,MAX(REGDATE) AS REGDATE
--              --                FROM TB_INV003
--              --               WHERE WERKS = P_WERKS
--              --                  AND MACH_CD = P_MACH_CD
--              --                  --AND NVL(LOT_NO,' ') LIKE P_LOT_NO || '%'
--              --                  AND INP_DT BETWEEN P_PRD_STR_DATE AND P_PRD_END_DATE
--              --               GROUP BY WERKS,LOT_NO,MATNR
--              --                ) I003,
                --             (SELECT V001.WERKS, V001.LOT_NO, V001.MATNR, I003.REGDATE
                --                           ,SUM(V001.ROLLCNT)  ROLLCNT,
                --                           SUM(V001.WGT) WGT
                --                FROM(
                --                    SELECT WERKS, LOT_NO, MATNR, MAX(REGDATE) AS REGDATE
                --                      FROM TB_INV003
                --                     WHERE WERKS = P_WERKS
                --                        AND MACH_CD = P_MACH_CD
                --                        AND NVL(LOT_NO,' ') LIKE P_LOT_NO || '%'
                --                        AND INP_DT BETWEEN P_PRD_STR_DATE AND P_PRD_END_DATE
                --                        --AND TO_CHAR(REGDATE, 'YYYYMMDD') BETWEEN P_PRD_STR_DATE AND P_PRD_END_DATE
                --                     GROUP BY WERKS,LOT_NO,MATNR, REGDATE
                --                    ) I003,
                --                    TB_INV001 V001
                --                 WHERE I003.WERKS = V001.WERKS
                --                   AND I003.LOT_NO = V001.LOT_NO
                --                   AND I003.MATNR  = V001.MATNR
                --                   AND NVL(V001.IN_MR_YN,'N')   = 'Y'
                --                GROUP BY V001.WERKS, V001.LOT_NO, V001.MATNR, I003.REGDATE
                --             ) W000,
                --           TB_MAS001 M001
                --     WHERE  
                --       --I003.WERKS = W000.WERKS
                --       --AND I003.LOT_NO = W000.LOT_NO
                --       --AND I003.MATNR  = W000.MATNR
                --       W000.WERKS  = M001.WERKS
                --       AND W000.MATNR  = M001.MATNR
                --       AND NVL(M001.PCODE,' ') LIKE P_PCODE || '%'
                --       AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE P_WEIGHT || '%'
                --       --AND NVL(M001.ORDER_NO,' ') LIKE P_ORDER_NO || '%'
                --       --AND S016.COMP_YN = 'Y'
                --       --AND S016.USE_YN = 'Y'
                --       /*
                --       AND ('Y')  IN NVL(( SELECT  'Y'
                --                            FROM TB_SCH017   SCH017
                --                            WHERE I003.WERKS   = SCH017.WERKS
                --                              AND I003.LOT_NO  = SCH017.PRE_ORDER_NO
                --                              AND NVL(SCH017.COMP_YN,'N')  IN ('N','I')
                --                        ),'Y')  
                --       */
                --       AND  1  <= ( SELECT  NVL(COUNT(*),1)
                --                            FROM TB_SCH017   SCH017
                --                            WHERE W000.WERKS   = SCH017.WERKS
                --                              AND W000.LOT_NO  = SCH017.PRE_ORDER_NO
                --                              AND NVL(SCH017.COMP_YN,'N')  IN ('N','I')
                --                        )  
             )
             ORDER BY INP_DT ASC, /*WRK_SEQNO ASC,*/ WRK_ORDR_NO ASC, WRK_ORDR_SEQNO ASC;

        ELSIF P_PROC_CD = 'SA' THEN     -- PS 투입정보(SA : 슬리터)
            --grid 컬럼 정보 설정
            V_COLINFO := '선택@C^60|투입일시@C^170|오더구분@C^100|오더번호@C^130|LOT번호@C^130|자재코드@C^200|계획권치수@R^120|투입권치수@R^120|지종@C^70|지종명@H|지폭@H|지시사항@H|작업지시번호@C^200|순번@C^50|상세보기@C^100';
            V_COLTYPE := 'CHK@Button|INP_DT@varchar|ORDER_GB@varchar|ORDER_NO@varchar|LOT_NO@varchar|MATNR@varchar|MROLLCNT@varchar|ROLLCNT@varchar|PCODE@varchar|PCODE_NM@varchar|MWIDTH@varchar|ORDER_RMK@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|DBTN@Button';

            --컬럼설정 반환 테이블 작성
            OPEN CUR_1 FOR
            SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

            OPEN CUR_2 FOR
              SELECT
                        CHK
                      , INP_DT              --투입일시
                      , ORDER_GB           --오더구분    
                      , ORDER_NO            --오더번호
                      , LOT_NO              --LOT_NO
                      , MATNR               --밀롤 자재코드
                      , MROLLCNT	        --밀롤 계획권치수
                      , ROLLCNT	            --밀롤 실적권치수
                      , PCODE               --지종
                      , PCODE_NM            --지종명                
                      , MWIDTH	            --밀롤 지폭
                      , ORDER_RMK           --작업지시사항
                      , WRK_ORDR_NO         --밀롤 작업지시번호
                      , WRK_ORDR_SEQNO      --밀롤 작업지시번호 순번
                      , DBTN                --상세보기
                FROM 
                 (
                    /*******  정상          *************/  
                    SELECT /*+ ORDERED */
                            '-' AS CHK
                           , TO_CHAR(I003.REGDATE, 'YYYY-MM-DD HH24:MI') AS INP_DT -- 투입일시
                           , '정상'                                       ORDER_GB           --오더구분    
                           , S016.ORDER_NO                               ORDER_NO            --오더번호
                           , I003.LOT_NO                                 LOT_NO              --오더번호
                           , I003.MATNR                                  MATNR               --밀롤 자재코드
                           , TO_CHAR(S016.MROLLCNT, 'fm999,999,999,990') MROLLCNT	         --밀롤 계획권치수
                           , TO_CHAR(I003.ROLLCNT, 'fm999,999,999,990')  ROLLCNT	         --밀롤 실적권치수
                           , S016.PCODE                                  PCODE               --지종
                           , M001.PCODE_NM                               PCODE_NM            --지종명                
                           , TO_CHAR(S016.MWIDTH, 'fm999,999,999,990')   MWIDTH	             --밀롤 지폭
                           , S016.ORDER_RMK                              ORDER_RMK           --작업지시사항
                           , I003.WRK_ORDR_NO                            WRK_ORDR_NO         --밀롤 작업지시번호
                           , I003.WRK_ORDR_SEQNO                         WRK_ORDR_SEQNO      --밀롤 작업지시번호 순번
                           , '상세보기'                                    DBTN                --상세보기
                           , S016.WRK_SEQNO                              WRK_SEQNO 
                      FROM ( SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO, MATNR, LOT_NO,MAX(REGDATE) AS REGDATE
                                   , SUM(ROLLCNT) AS ROLLCNT, SUM(WGT) AS WGT
                               FROM TB_INV003
                              WHERE WERKS   = P_WERKS
                                AND MACH_CD = P_MACH_CD
                                AND NVL(LOT_NO,' ') LIKE '%' || P_LOT_NO || '%'
                                AND INP_DT  BETWEEN P_PRD_STR_DATE AND P_PRD_END_DATE
                              GROUP BY WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO, MATNR,LOT_NO   
                            ) I003,
                           TB_SCH016 S016,
                           TB_MAS001 M001
                     WHERE I003.WERKS = S016.WERKS(+)
                       AND I003.WRK_ORDR_NO = S016.WRK_ORDR_NO(+)
                       AND I003.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO(+)
                       AND I003.WERKS   = M001.WERKS(+)
                       AND I003.MATNR   = M001.MATNR(+)
                       AND NVL(M001.PCODE,' ') LIKE '%' || P_PCODE || '%'
                       AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_WEIGHT || '%'
                       AND S016.COMP_YN = 'Y'
--                       AND S016.DLFL = 'N'  --삭제지시자 X='삭제' , N=정상오더
                       AND S016.USE_YN  = 'Y'
                       AND S016.SLITER  = 'Y'
                       AND NVL(S016.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
                       /*
                       AND ('Y')   IN  NVL(( SELECT 'Y'
                                           FROM TB_SCH016  SCH016
                                          WHERE S016.WERKS    = SCH016.WERKS
                                            AND S016.ORDER_NO = SCH016.PRE_ORDER_NO
                                            AND NVL(SCH016.COMP_YN,'N') IN ('N','I')
                                            AND SCH016.SLITER  = 'X'
                                        ),'Y')
                       */
                       AND  1  <= ( SELECT  NVL(COUNT(*),1)
                                           FROM TB_SCH016  SCH016
                                          WHERE S016.WERKS    = SCH016.WERKS
                                            AND S016.ORDER_NO = SCH016.PRE_ORDER_NO
                                            AND NVL(SCH016.COMP_YN,'N') IN ('N','I')
                                            AND SCH016.SLITER  = 'X'
                                        )
                    UNION ALL
                    /*******  예외  *************/  
                    SELECT  /*+ ORDERED */
                             '-' AS CHK
                           , TO_CHAR(I000.REGDATE, 'YYYY-MM-DD HH24:MI')         AS INP_DT                                  -- 투입일시
                           , '예외'                                                  ORDER_GB                               --오더구분    
                           , S019.ORDER_NO                                          ORDER_NO                                --오더번호
                           , I000.LOT_NO                                            LOT_NO                                  --LOT_NO
                           , I000.MATNR                                             MATNR                                   --재단 자재코드
                           , TO_CHAR((S019.WRK_ORDR_QTY / (S019.BS_WGT/1000) / (S019.WLEN / 1000)) , 'fm999,999,999,990') 
                                                                                    MROLLCNT	                            --계획권치수
                           , TO_CHAR(NVL(I000.ROLLCNT,0), 'fm999,999,999,990')      ROLLCNT	                                --실적권치수
                           , I000.PCODE                                             PCODE                                   --지종
                           , I000.PCODE_NM                                          PCODE_NM                                --지종명                
                           , TO_CHAR(I000.WLEN, 'fm999,999,999,990')                MWIDTH	                                --지폭
                           , NULL                                                   ORDER_RMK                               --작업지시사항
                           , S019.WRK_ORDR_NO                                       WRK_ORDR_NO                             --작업지시번호
                           , S019.WRK_ORDR_SEQNO                                    WRK_ORDR_SEQNO                          --작업지시번호 순번
                           , '상세보기'                                              DBTN                                    --상세보기
                           , S019.WRK_SEQNO                                         WRK_SEQNO                               
                      FROM (SELECT I003.WERKS, I003.MATNR, I003.LOT_NO
                                 , MAX(I003.REGDATE) AS REGDATE
                                 , SUM(CASE WHEN M001.BS_WGT > 0 AND M001.WLEN > 0 THEN NVL(I003.WGT,0)/((M001.BS_WGT/1000) * (M001.WLEN/1000)) ELSE 0 END) AS ROLLCNT
                                 , SUM(I003.WGT) AS WGT 
                                 , MAX(M001.BS_WGT) AS BS_WGT
                                 , MAX(M001.PCODE) AS PCODE
                                 , MAX(M001.PCODE_NM) AS PCODE_NM
                                 , MAX(M001.WLEN) AS WLEN
                              FROM TB_INV003 I003
                                 , TB_MAS001 M001
                             WHERE I003.WERKS   = M001.WERKS(+)
                               AND I003.MATNR   = M001.MATNR(+)
                               AND I003.WERKS   = P_WERKS
                               AND NVL(I003.LOT_NO,' ') LIKE '%' || P_LOT_NO || '%'
                               AND I003.MACH_CD = P_MACH_CD
                               AND I003.INP_DT  BETWEEN P_PRD_STR_DATE AND P_PRD_END_DATE
                             GROUP BY I003.WERKS, I003.MATNR, I003.LOT_NO
                            ) I000,
                           TB_SCH020 S020,
                           TB_SCH019 S019
                     WHERE I000.WERKS  = S020.WERKS
                       AND I000.MATNR  = S020.MATNR
                       AND I000.LOT_NO = S020.LOT_NO
                       AND S020.WRK_ORDR_NO    = S019.WRK_ORDR_NO
                       AND S020.WRK_ORDR_SEQNO = S019.WRK_ORDR_SEQNO
                       AND NVL(I000.PCODE,' ') LIKE '%' || P_PCODE || '%'
                       AND TO_CHAR(NVL(I000.BS_WGT,0)) LIKE '%' || P_WEIGHT || '%' 
--                       AND S019.DLFL = 'N'  --삭제지시자 X='삭제' , N=정상오더
                       AND S019.USE_YN     = 'Y'
                       AND S019.ORDER_DIV  = 'ZP14'
                       AND NVL(S019.COMP_YN,'N') IN ('N','I')
                       AND NVL(S019.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
                 )
                 ORDER BY INP_DT ASC, WRK_SEQNO ASC,WRK_ORDR_NO ASC, WRK_ORDR_SEQNO ASC;

        ELSIF P_PROC_CD = 'CB' THEN     -- PS 투입정보(SA : 수재단)
            --grid 컬럼 정보 설정
            V_COLINFO := '선택@C^60|투입일시@C^170|오더구분@C^80|오더번호@C^130|LOT번호@C^130|자재코드@C^200|계획연수@R^100|투입연수@R^100|지종@C^70|지종명@H|평량@R^80|규격@C^120|오더유형@C^80|지시사항@H|작업지시번호@C^200|순번@C^50|상세보기@C^100';
            V_COLTYPE := 'CHK@Button|INP_DT@varchar|ORDER_GB@varchar|ORDER_NO@varchar|LOT_NO@varchar|MATNR@varchar|WRK_ORDR_QTY@varchar|PCNT@varchar|PCODE@varchar|PCODE_NM@varchar|BS_WGT@varchar|MATNR_SPEC@varchar|ORDER_DIV@varchar|ORDER_RMK@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|DBTN@Button';

            --컬럼설정 반환 테이블 작성
            OPEN CUR_1 FOR
            SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

            OPEN CUR_2 FOR
            SELECT 
                    CHK
                   ,INP_DT
                   ,ORDER_GB            --오더구분    
                   ,ORDER_NO             --오더번호
                   ,LOT_NO               --LOT번호
                   ,MATNR                --재단 자재코드
                   ,WRK_ORDR_QTY	     --재단 계획연수
                   ,PCNT	             --재단 실적연수
                   ,PCODE                --지종
                   ,PCODE_NM             --지종명   
                   ,BS_WGT               --평량
                   ,MATNR_SPEC           --규격
                   ,ORDER_DIV            --오더유형
                   ,ORDER_RMK            --작업지시사항
                   ,WRK_ORDR_NO          --재단 작업지시번호
                   ,WRK_ORDR_SEQNO       --재단 작업지시번호 순번
                   ,DBTN                 --상세보기
            FROM 
               (
                    /*******  정상          *************/
                    SELECT /*+ ORDERED */
                            '-' AS CHK
                           , TO_CHAR(I000.REGDATE, 'YYYY-MM-DD HH24:MI') AS INP_DT -- 투입일시
                           , '정상'            AS ORDER_GB      --오더구분    
                           , S017.ORDER_NO        ORDER_NO      --오더번호
                           , I000.LOT_NO           LOT_NO         --재단 LOT번호
                           , I000.MATNR           MATNR         --재단 자재코드
                           , RTRIM(TO_CHAR(S017.WRK_ORDR_QTY, 'fm999,999,999,990.999'), '.') AS WRK_ORDR_QTY   --재단 계획연수
                           , RTRIM(TO_CHAR(I000.PCNT, 'fm999,999,999,990.999'), '.') AS PCNT	               --재단 실적연수
                           , S017.PCODE           PCODE         --지종
                           , M001.PCODE_NM        PCODE_NM      --지종명                
                           , M001.BS_WGT    BS_WGT          --평량
                           , SUBSTR(M001.MATNR, 10, 4) || '*' || SUBSTR(M001.MATNR, 14, 4)   MATNR_SPEC     --규격
                           , S017.ORDER_DIV                                 ORDER_DIV       --오더유형
                           , S017.ORDER_RMK       ORDER_RMK     --작업지시사항
                           , I000.WRK_ORDR_NO_C     WRK_ORDR_NO   --재단 작업지시번호
                           , I000.WRK_ORDR_SEQNO_C  WRK_ORDR_SEQNO  --재단 작업지시번호 순번
                           , '상세보기'         AS DBTN            --상세보기
                           , S017.WRK_SEQNO       WRK_SEQNO
                      FROM (SELECT I003.WERKS
                                 , I003.WRK_ORDR_NO AS WRK_ORDR_NO_C
                                 , I003.WRK_ORDR_SEQNO AS WRK_ORDR_SEQNO_C
                                 , I003.MATNR
                                 , I003.LOT_NO
                                 , S0171.WRK_ORDR_NO
                                 , S0171.WRK_ORDR_SEQNO
                                 , MAX(I003.REGDATE) AS REGDATE
                                 , SUM(I003.PRE_IN_QTY)/500 AS PCNT
                                 , SUM(I003.WGT) AS WGT 
                              FROM TB_INV003 I003
                                 , TB_SCH017 S0171
                             WHERE I003.MACH_CD = P_MACH_CD
                               AND I003.LOT_NO   LIKE '%' || P_LOT_NO || '%'
                               AND I003.WERKS          = S0171.WERKS
                               AND I003.WRK_ORDR_NO    = S0171.DUMMY_WRK_ORDR_NO
                               AND I003.WRK_ORDR_SEQNO = S0171.DUMMY_WRK_ORDR_SEQNO
                               AND NVL(S0171.COMP_YN,'N') = 'N'
                               AND I003.WERKS   = P_WERKS
                               AND I003.INP_DT  BETWEEN P_PRD_STR_DATE AND P_PRD_END_DATE
                               AND P_MACH_CD  IN ('PCB02', 'PCB03')
                             GROUP BY I003.WERKS, I003.WRK_ORDR_NO, I003.WRK_ORDR_SEQNO, I003.MATNR,I003.LOT_NO, S0171.WRK_ORDR_NO, S0171.WRK_ORDR_SEQNO 
                           ) I000,
                           TB_SCH017 S017,
                           TB_MAS001 M001
                     WHERE I000.WERKS          = S017.WERKS
                       AND I000.WRK_ORDR_NO    = S017.WRK_ORDR_NO
                       AND I000.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO
                       AND I000.WERKS  = M001.WERKS(+)
                       AND I000.MATNR  = M001.MATNR(+)
--                       AND S017.DLFL = 'N'  --삭제지시자 X='삭제' , N=정상오더
                       AND S017.USE_YN = 'Y'
                       AND S017.COMP_YN IN ('N','I')
                       AND NVL(M001.PCODE,' ') LIKE '%' || P_PCODE || '%'
                       AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_WEIGHT || '%'
                       AND NVL(S017.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
                       AND TO_CHAR(NVL(S017.WLEN, 0)) LIKE '%' || P_WLEN || '%'
                       AND TO_CHAR(NVL(S017.VLEN, 0)) LIKE '%' || P_VLEN || '%'
                       AND SUBSTR(S017.WRK_ORDR_NO,1,4)  <> 'WOEX'
                  UNION ALL
                    /*******  예외 (투입자재에 대한 실적이 없음, BOM 정보 사용 )*************/  
                    SELECT /*+ ORDERED */
                            '-' AS CHK
                           , TO_CHAR(I000.REGDATE, 'YYYY-MM-DD HH24:MI') AS INP_DT -- 투입일시
                           , '예외'             AS ORDER_GB       --오더구분    
                           , S019.ORDER_NO         ORDER_NO       --오더번호
                           , I000.LOT_NO           LOT_NO   
                           , I000.MATNR            MATNR          --재단 자재코드
                           , RTRIM(TO_CHAR(S019.WRK_ORDR_QTY, 'fm999,999,999,990.999'), '.') AS WRK_ORDR_QTY  --계획연수
                           , RTRIM(TO_CHAR(I000.IN_QTY  /*PCNT*/, 'fm999,999,999,990.999'), '.') AS PCNT	              --실적연수
                           --, I000.WLEN             AS MWIDTH	       --재단 지폭
                           , I000.PCODE            PCODE           --지종
                           , I000.PCODE_NM         PCODE_NM        --지종명                
                           , M001.BS_WGT    BS_WGT          --평량
                           , SUBSTR(M001.MATNR, 10, 4) || '*' || SUBSTR(M001.MATNR, 14, 4)   MATNR_SPEC     --규격
                           , S019.ORDER_DIV     AS ORDER_DIV       --오더유형
                           , NULL               AS ORDER_RMK       --작업지시사항
                           , S019.WRK_ORDR_NO      WRK_ORDR_NO     --재단 작업지시번호
                           , S019.WRK_ORDR_SEQNO   WRK_ORDR_SEQNO  --재단 작업지시번호 순번
                           , '상세보기'          AS DBTN            --상세보기
                           , S019.WRK_SEQNO        WRK_SEQNO                               
                      FROM (   SELECT  I003.WERKS, I003.MATNR, I003.LOT_NO,M001.WLEN,SUM(I003.IN_QTY) IN_QTY
                                     , MAX(I003.REGDATE) AS REGDATE
                                     , SUM(CASE WHEN M001.BS_WGT > 0 AND M001.WLEN > 0  AND M001.VLEN > 0 THEN 
                                                NVL(I003.WGT,0)/(500 * (M001.BS_WGT/1000) * (M001.WLEN/1000) * (M001.VLEN/1000)) ELSE 0 END) AS PCNT
                                     , SUM(I003.WGT) AS WGT 
                                     , MAX(M001.BS_WGT) AS BS_WGT
                                     , MAX(M001.PCODE) AS PCODE
                                     , MAX(M001.PCODE_NM) AS PCODE_NM
                                  FROM TB_INV003 I003
                                     , TB_MAS001 M001
                                 WHERE I003.WERKS   = M001.WERKS(+)
                                   AND I003.MATNR   = M001.MATNR(+)
                                   AND I003.WERKS   = P_WERKS
                                   AND I003.MACH_CD = P_MACH_CD
                                   --AND P_MACH_CD  IN ('PCB01', 'PCB04')
                                   AND NVL(I003.LOT_NO,' ') LIKE '%' || P_LOT_NO || '%'
                                   AND I003.INP_DT  BETWEEN P_PRD_STR_DATE AND P_PRD_END_DATE
                                 GROUP BY I003.WERKS, I003.MATNR, I003.LOT_NO,M001.WLEN
                            ) I000,
                           TB_SCH020 S020,
                           TB_SCH019 S019,
                           TB_MAS001 M001
                     WHERE I000.WERKS  = S020.WERKS
                       AND I000.MATNR  = S020.MATNR
                       AND I000.LOT_NO = S020.LOT_NO
                       AND S020.WRK_ORDR_NO    = S019.WRK_ORDR_NO
                       AND S020.WRK_ORDR_SEQNO = S019.WRK_ORDR_SEQNO
                       AND I000.WERKS  = M001.WERKS(+)
                       AND I000.MATNR  = M001.MATNR(+)
                       AND NVL(I000.PCODE,' ') LIKE '%' || P_PCODE || '%'
                       AND TO_CHAR(NVL(I000.BS_WGT,0)) LIKE '%' || P_WEIGHT || '%'
--                       AND S019.DLFL = 'N'  --삭제지시자 X='삭제' , N=정상오더
                       AND S019.USE_YN    = 'Y'
                       AND S019.ORDER_DIV = 'ZP12'
                       AND S019.COMP_YN  IN ('N','I')
                       AND TO_CHAR(NVL(S019.WLEN, 0)) LIKE '%' || P_WLEN || '%'
                       AND TO_CHAR(NVL(S019.VLEN, 0)) LIKE '%' || P_VLEN || '%'
                       AND NVL(S019.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
                     --  AND P_MACH_CD  IN ('PCB01', 'PCB04')
                       AND ((P_MACH_CD  IN ('PCB01', 'PCB04') AND  S019.PACKTYPE = 'B'  ) OR
                             (P_MACH_CD  IN ('PCB02', 'PCB03') AND  S019.PACKTYPE = 'A'  ) )
                       AND SUBSTR(S020.WRK_ORDR_NO,1,4)  = 'WOEX'
                      --AND S020.ORDER_NO = ( SELECT ORDER_NO FROM TB_WRK011 WHERE WERKS = P_WERKS AND MACH_CD = P_MACH_CD )   
            )
            GROUP BY
                    CHK
                   ,INP_DT
                   ,ORDER_GB            
                   ,ORDER_NO  
                   ,LOT_NO  
                   ,MATNR               
                   ,WRK_ORDR_QTY
                   ,PCNT
                   ,PCODE               
                   ,PCODE_NM            
                   ,BS_WGT              
                   ,MATNR_SPEC          
                   ,ORDER_DIV       
                   ,ORDER_RMK        
                   ,WRK_ORDR_NO      
                   ,WRK_ORDR_SEQNO   
                   ,DBTN      
            ORDER BY INP_DT ASC, WRK_ORDR_NO ASC, WRK_ORDR_SEQNO ASC;

        ELSIF P_PROC_CD = 'PB' OR P_PROC_CD = 'PC' OR P_PROC_CD = 'PD' THEN     -- PS 투입정보(PB : 자동포장, PC : 수축포장, PD : 포장예외생산)
            --grid 컬럼 정보 설정
            V_COLINFO := '선택@C^60|투입일시@C^170|오더구분@C^100|오더번호@C^130|지종@C^70|지종명@H|평량@R^80|가로@R^80|세로@R^80|계획연수@R^100|계획중량@R^120|투입연수@R^100|투입중량@R^120|오더유형@C^80|작업지시번호@C^200|순번@C^50|상세보기@C^100|지시사항@H|자재코드@C^200';
            V_COLTYPE := 'CHK@Button|INP_DT@varchar|ORDER_GB@varchar|ORDER_NO@varchar|PCODE@varchar|PCODE_NM@varchar|BS_WGT@varchar|WLEN@varchar|VLEN@varchar|WRK_ORDR_QTY@varchar|TOT_WGT@varchar|PCNT@varchar|WGT@varchar|ORDER_DIV@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|DBTN@Button|ORDER_RMK@varchar|MATNR@varchar';

            --컬럼설정 반환 테이블 작성
            OPEN CUR_1 FOR
            SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

            OPEN CUR_2 FOR
            SELECT  
                    CHK
                   ,INP_DT          --투입일시
                   ,ORDER_GB        --오더구분
                   ,ORDER_NO         --오더번호
                   ,PCODE            --지종
                   ,PCODE_NM         --지종명
                   ,BS_WGT           --평량
                   ,WLEN             --가로길
                   ,VLEN             --세로길
                   ,WRK_ORDR_QTY     --재단 계획연수
                   ,TOT_WGT          --재단 계획중량
                   ,PCNT	         --재단 실적연수
                   ,WGT	             --재단 중량
                   ,ORDER_DIV       --오더유형
                   ,WRK_ORDR_NO      --재단 작업지시번호
                   ,WRK_ORDR_SEQNO   --재단 작업지시번호 순번
                   ,DBTN             --상세보기
                   ,ORDER_RMK        --작업지시사항
                   ,MATNR            --재단 자재코드
            FROM 
            (
                    /*******  정상          *************/  
                    SELECT   /*+ ORDERED */
                             DISTINCT
                             '-'                                                                  CHK
                           , TO_CHAR(W000.REGDATE, 'YYYY-MM-DD HH24:MI') AS INP_DT -- 투입일시
                           , '정상'                                                              ORDER_GB        --오더구분
                           , S017.ORDER_NO                                                      ORDER_NO         --오더번호
                           , W000.PCODE                                                         PCODE            --지종
                           , W000.PCODE_NM                                                      PCODE_NM         --지종명
                           , TO_CHAR(S017.BS_WGT, 'fm999,999,999,990')                          BS_WGT           --평량
                           , TO_CHAR(S017.WLEN, 'fm999,990')                                      WLEN             --가로길
                           , TO_CHAR(S017.VLEN, 'fm999,990')                                      VLEN             --세로길
                           , RTRIM(TO_CHAR(S017.WRK_ORDR_QTY, 'fm999,999,999,990.999'), '.')        WRK_ORDR_QTY     --재단 계획연수
                           , RTRIM(TO_CHAR(S017.TOT_WGT, 'fm999,999,999,990.999'), '.')             TOT_WGT          --재단 계획중량
                           , RTRIM(TO_CHAR(W000.PCNT, 'fm999,999,999,990.999'), '.')                PCNT	         --재단 실적연수
                           --, RTRIM(TO_CHAR(W000.STCK_QTY, 'fm999,999,999,990.999'), '.')                PCNT	         --재단 실적연수
                           , RTRIM(TO_CHAR(W000.WGT, 'fm999,999,999,990.999'), '.')                 WGT	             --재단 실적중량
                           , S017.ORDER_DIV                                 ORDER_DIV       --오더유형
                           , W000.WRK_ORDR_NO                                                   WRK_ORDR_NO      --재단 작업지시번호
                           , W000.WRK_ORDR_SEQNO                                                WRK_ORDR_SEQNO   --재단 작업지시번호 순번
                           , '상세보기'                                                           DBTN             --상세보기
                           , S017.ORDER_RMK                                                     ORDER_RMK        --작업지시사항
                           , W000.MATNR                                                         MATNR            --재단 자재코드
                           , S017.WRK_SEQNO                                                     WRK_SEQNO 
                      FROM  (SELECT W002.WERKS, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO,
                                    W002.MATNR,  I003.PCODE, I003.PCODE_NM,  /*W002.LOT_NO,*/ W002.WLEN, W002.VLEN
                                    ,SUM(I003.STCK_QTY) STCK_QTY
                                    ,SUM(W002.PCNT) PCNT, SUM(W002.WGT) WGT, MAX(I003.REGDATE) AS REGDATE
                                FROM(
                                    SELECT I003.WERKS, I003.WRK_ORDR_NO, I003.WRK_ORDR_SEQNO, M001.PCODE, M001.PCODE_NM
                                         , SUM(I003.STCK_QTY) STCK_QTY
                                         , MAX(I003.REGDATE)  REGDATE
                                      FROM TB_INV003 I003,
                                           TB_MAS001 M001
                                     WHERE I003.WERKS = M001.WERKS
                                        AND I003.MATNR = M001.MATNR
                                        AND I003.WERKS = P_WERKS
                                        AND I003.MACH_CD = P_MACH_CD
                                        AND NVL(I003.LOT_NO,' ') LIKE '%' || P_LOT_NO || '%'
                                        AND I003.INP_DT BETWEEN P_PRD_STR_DATE AND P_PRD_END_DATE
                                        --AND NVL(I001.IN_MR_YN,'N')   = 'N'
                                        AND M001.MATNR_DIV IN ('FERT', 'HALB')
                                        AND NVL(M001.PCODE,' ') LIKE '%' || P_PCODE || '%'
                                        AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_WEIGHT || '%'
                                     GROUP BY I003.WERKS, I003.WRK_ORDR_NO, I003.WRK_ORDR_SEQNO, M001.PCODE, M001.PCODE_NM
                                    ) I003,
                                    TB_WRK002 W002
                                 WHERE I003.WERKS = W002.WERKS(+)
                                   AND I003.WRK_ORDR_NO = W002.WRK_ORDR_NO(+)
                                   AND I003.WRK_ORDR_SEQNO = W002.WRK_ORDR_SEQNO(+) 
                                   AND NVL(W002.CNL_YN,'N')  = 'N'
                                GROUP BY W002.WERKS, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO,
                                    W002.MATNR,  I003.PCODE, I003.PCODE_NM,  /*W002.LOT_NO,*/ W002.WLEN, W002.VLEN
                             ) W000,
                           TB_SCH017 S017
                     WHERE W000.WERKS = S017.WERKS
                       AND W000.WRK_ORDR_NO = S017.WRK_ORDR_NO
                       AND W000.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO
                       --20221011 여한진 가로, 세로 길이 검색조건 추가
                       AND TO_CHAR(NVL(S017.WLEN, 0)) LIKE '%' || P_WLEN || '%'
                       AND TO_CHAR(NVL(S017.VLEN, 0)) LIKE '%' || P_VLEN || '%'
                       --AND S017.COMP_YN = 'Y'  
--                       AND NVL(S017.DLFL, 'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더
                       AND S017.USE_YN = 'Y'
                       AND W000.STCK_QTY > 0
                       AND NVL(S017.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
                UNION ALL
                    /*******  예외          *************/  
                      SELECT /*+ ORDERED */  
                             DISTINCT
                             '-' AS CHK
                           , TO_CHAR(I003.REGDATE, 'YYYY-MM-DD HH24:MI')             INP_DT          -- 투입일시
                           , '예외'   AS                                              ORDER_GB       --오더구분    
                           , S019.ORDER_NO                                           ORDER_NO        --오더번호
                           , S019.PCODE                                              PCODE           --지종
                           , M001.PCODE_NM                                           PCODE_NM        --지종명                
                          , TO_CHAR(S019.BS_WGT, 'fm999,999,999,990')                BS_WGT          --평량
                           , TO_CHAR(S019.WLEN, 'fm999,990')                           WLEN            --가로길
                           , TO_CHAR(S019.VLEN, 'fm999,990')                           VLEN            --세로길
                           , RTRIM(TO_CHAR(S019.WRK_ORDR_QTY, 'fm999,999,999,990.999'), '.')         WRK_ORDR_QTY    --재단 계획연수
                           , TO_CHAR((NVL(S019.WRK_ORDR_QTY, 0) * 500) * (M001.BS_WGT/1000) * (M001.WLEN/1000) * (M001.VLEN/1000), 'fm999,999,999,990')   TOT_WGT         --재단 계획중량
                          -- , RTRIM(TO_CHAR((NVL(S019.WRK_ORDR_QTY, 0) * 500) * (M001.BS_WGT/1000) * (M001.WLEN/1000) * (M001.VLEN/1000), 'fm999,999,999,990.999'), '.')             TOT_WGT          --재단 계획중량
                           , TO_CHAR(I003.IN_QTY, 'fm999,999,999,990')                              PCNT	         --재단 실적연수
                           , TO_CHAR(I003.WGT, 'fm999,999,999,990')              WGT	         --재단 실적중량
                           , S019.ORDER_DIV                                 ORDER_DIV       --오더유형
                           , I003.WRK_ORDR_NO                                        WRK_ORDR_NO     --재단 작업지시번호
                           , I003.WRK_ORDR_SEQNO                                     WRK_ORDR_SEQNO  --재단 작업지시번호 순번
                           , '상세보기'                                               DBTN            --상세보기
                           , S019.WRK_ORDR_REMARK                                    ORDER_RMK       --작업지시사항
                           , I003.MATNR                                              MATNR           --재단 자재코드
                           , S019.WRK_SEQNO                                          WRK_SEQNO 
                      FROM (SELECT WERKS, MACH_CD,WRK_ORDR_NO, WRK_ORDR_SEQNO, MATNR, LOT_NO ,SUM(IN_QTY) IN_QTY,IND_BCD,SUM(WGT) WGT,MAX(REGDATE) AS REGDATE
                              FROM TB_INV003
                             WHERE WERKS = P_WERKS
                                AND MACH_CD = P_MACH_CD
                                AND NVL(LOT_NO,' ') LIKE '%' || P_LOT_NO || '%'
                                AND INP_DT BETWEEN P_PRD_STR_DATE AND P_PRD_END_DATE
                                AND STCK_QTY > 0
                             GROUP BY WERKS, MACH_CD,WRK_ORDR_NO, WRK_ORDR_SEQNO, MATNR,LOT_NO,/*IN_QTY,*/IND_BCD /*, WGT    */
                              ) I003 , 
                           TB_SCH020 S020,
                           TB_SCH019 S019,
                           TB_MAS001 M001--,
                           --TB_WRK011 K011
                     WHERE I003.WERKS = S020.WERKS
                       AND I003.MATNR = S020.MATNR
                       AND I003.LOT_NO = S020.LOT_NO
                       AND S020.WRK_ORDR_NO = S019.WRK_ORDR_NO
                       AND S020.WRK_ORDR_SEQNO   = S019.WRK_ORDR_SEQNO
                       AND I003.WERKS = M001.WERKS
                       AND I003.MATNR = M001.MATNR
                       --AND I003.WERKS = K011.WERKS
                       --AND I003.MACH_CD = K011.MACH_CD
                       --AND I003.WRK_ORDR_NO = K011.WRK_ORDR_NO
                       --AND I003.WRK_ORDR_SEQNO = K011.WRK_ORDR_SEQNO
--                       AND S019.DLFL = 'N'  --삭제지시자 X='삭제' , N=정상오더
                       AND S019.USE_YN = 'Y'
                       AND NVL(M001.PCODE,' ') LIKE '%' || P_PCODE || '%'
                       AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_WEIGHT || '%'
                       --20221011 여한진 가로, 세로 길이 검색조건 추가
                       AND TO_CHAR(NVL(S019.WLEN, 0)) LIKE '%' || P_WLEN || '%'
                       AND TO_CHAR(NVL(S019.VLEN, 0)) LIKE '%' || P_VLEN || '%'
                       AND S019.ORDER_DIV        = 'ZP13'
                       AND S019.COMP_YN IN   ('N','I')
                       AND NVL(S019.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
                       --AND V001.STOR_LOC_CD = '2000'   
             ) 
             ORDER BY INP_DT ASC, WRK_ORDR_NO ASC, WRK_SEQNO ASC,WRK_ORDR_SEQNO ASC;

        ELSIF P_PROC_CD = 'ZA' THEN     -- PS 투입정보(ZA : 문재적재소)
            --grid 컬럼 정보 설정
            V_COLINFO := '선택@C^60|투입일시@C^170|오더구분@C^100|오더번호@C^130|지종@C^70|지종명@H|평량@R^80|가로@R^80|세로@R^80|계획연수@R^100|계획중량@R^120|투입연수@R^100|투입중량@R^120|오더유형@C^80|작업지시번호@C^200|순번@C^50|상세보기@C^100|지시사항@H|자재코드@C^200';
            V_COLTYPE := 'CHK@Button|INP_DT@varchar|ORDER_GB@varchar|ORDER_NO@varchar|PCODE@varchar|PCODE_NM@varchar|BS_WGT@varchar|WLEN@varchar|VLEN@varchar|WRK_ORDR_QTY@varchar|TOT_WGT@varchar|PCNT@varchar|WGT@varchar|ORDER_DIV@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|DBTN@Button|ORDER_RMK@varchar|MATNR@varchar';

            --컬럼설정 반환 테이블 작성
            OPEN CUR_1 FOR
            SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

            OPEN CUR_2 FOR
            SELECT  
                    CHK
                   ,INP_DT          --투입일시
                   ,ORDER_GB        --오더구분
                   ,ORDER_NO         --오더번호
                   ,PCODE            --지종
                   ,PCODE_NM         --지종명
                   ,BS_WGT           --평량
                   ,WLEN             --가로길
                   ,VLEN             --세로길
                   ,WRK_ORDR_QTY     --재단 계획연수
                   ,TOT_WGT          --재단 계획중량
                   ,PCNT	         --재단 실적연수
                   ,WGT	             --재단 중량
                   ,ORDER_DIV       --오더유형
                   ,WRK_ORDR_NO      --재단 작업지시번호
                   ,WRK_ORDR_SEQNO   --재단 작업지시번호 순번
                   ,DBTN             --상세보기
                   ,ORDER_RMK        --작업지시사항
                   ,MATNR            --재단 자재코드
            FROM 
            (
                    /*******  문제          *************/  
                    SELECT /*+ ORDERED */
                            '-'                                                                  CHK
                           , TO_CHAR(W000.REGDATE, 'YYYY-MM-DD HH24:MI') AS INP_DT -- 투입일시
                           , '문제'                                                              ORDER_GB        --오더구분
                           , S017.ORDER_NO                                                      ORDER_NO         --오더번호
                           , W000.PCODE                                                         PCODE            --지종
                           , W000.PCODE_NM                                                      PCODE_NM         --지종명
                           , TO_CHAR(S017.BS_WGT, 'fm999,999,999,990')                          BS_WGT           --평량
                           , TO_CHAR(S017.WLEN, 'fm999,990')                                      WLEN             --가로길
                           , TO_CHAR(S017.VLEN, 'fm999,990')                                      VLEN             --세로길
                           , RTRIM(TO_CHAR(S017.WRK_ORDR_QTY, 'fm999,999,999,990.999'), '.')    WRK_ORDR_QTY     --재단 계획연수
                           , RTRIM(TO_CHAR(S017.TOT_WGT, 'fm999,999,999,990.999'), '.')         TOT_WGT          --재단 계획중량
                           , RTRIM(TO_CHAR(W000.PCNT, 'fm999,999,999,990.999'), '.')            PCNT	         --재단 실적연수
                           , RTRIM(TO_CHAR(W000.WGT, 'fm999,999,999,990.999'), '.')             WGT	             --재단 실적중량
                           , S017.ORDER_DIV                                                     ORDER_DIV       --오더유형
                           , W000.WRK_ORDR_NO                                                   WRK_ORDR_NO      --재단 작업지시번호
                           , W000.WRK_ORDR_SEQNO                                                WRK_ORDR_SEQNO   --재단 작업지시번호 순번
                           , '상세보기'                                                           DBTN             --상세보기
                           , S017.ORDER_RMK                                                     ORDER_RMK        --작업지시사항
                           , W000.MATNR                                                         MATNR            --재단 자재코드
                           , S017.WRK_SEQNO                                                     WRK_SEQNO 
                      FROM  (SELECT W002.WERKS, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO,
                                    W002.MATNR,  I003.PCODE, I003.PCODE_NM,  W002.LOT_NO, W002.WLEN, W002.VLEN,
                                    SUM(W002.PCNT) PCNT, SUM(W002.WGT) WGT, MAX(I003.REGDATE) AS REGDATE
                                FROM(
                                    SELECT I003.WERKS, I003.WRK_ORDR_NO, I003.WRK_ORDR_SEQNO, M001.PCODE, M001.PCODE_NM, MAX(I003.REGDATE) AS REGDATE
                                      FROM TB_INV003 I003,
                                           TB_MAS001 M001
                                     WHERE I003.WERKS = M001.WERKS
                                        AND I003.MATNR = M001.MATNR
                                        AND I003.WERKS = P_WERKS
                                        AND I003.MACH_CD = P_MACH_CD
                                        AND NVL(I003.LOT_NO,' ') LIKE '%' || P_LOT_NO || '%'
                                        AND I003.INP_DT BETWEEN P_PRD_STR_DATE AND P_PRD_END_DATE
                                        --AND NVL(I001.IN_MR_YN,'N')   = 'N'
                                        AND M001.MATNR_DIV IN ('FERT', 'HALB')
                                        AND NVL(M001.PCODE,' ') LIKE '%' || P_PCODE || '%'
                                        AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_WEIGHT || '%'
                                     GROUP BY I003.WERKS, I003.WRK_ORDR_NO, I003.WRK_ORDR_SEQNO, M001.PCODE, M001.PCODE_NM
                                    ) I003,
                                    TB_WRK002 W002
                                 WHERE I003.WERKS = W002.WERKS(+)
                                   AND I003.WRK_ORDR_NO = W002.WRK_ORDR_NO(+)
                                   AND I003.WRK_ORDR_SEQNO = W002.WRK_ORDR_SEQNO(+)  
                                   AND NVL(W002.CNL_YN,'N')  = 'N'
                                GROUP BY W002.WERKS, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO,
                                    W002.MATNR,  I003.PCODE, I003.PCODE_NM,  W002.LOT_NO, W002.WLEN, W002.VLEN
                             ) W000,
                           TB_SCH017 S017
                     WHERE W000.WERKS = S017.WERKS
                       AND W000.WRK_ORDR_NO = S017.WRK_ORDR_NO
                       AND W000.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO
                       --20221011 여한진 가로, 세로 길이 검색조건 추가
                       AND TO_CHAR(NVL(S017.WLEN, 0)) LIKE '%' || P_WLEN || '%'
                       AND TO_CHAR(NVL(S017.VLEN, 0)) LIKE '%' || P_VLEN || '%'
                       --AND S017.COMP_YN = 'Y'
--                       AND S017.DLFL = 'N'  --삭제지시자 X='삭제' , N=정상오더
                       AND S017.USE_YN = 'Y'
                       AND NVL(S017.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
             ) 
             ORDER BY INP_DT ASC, WRK_ORDR_NO ASC, WRK_SEQNO ASC,WRK_ORDR_SEQNO ASC;
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
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END;

/
