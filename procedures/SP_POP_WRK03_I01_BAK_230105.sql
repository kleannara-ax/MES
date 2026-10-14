
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK03_I01_BAK_230105" 
(
    P_WERKS             IN VARCHAR2
    ,P_MACH_CD          IN VARCHAR2
    ,P_IOTYPE           IN VARCHAR2
    ,P_USERID           IN VARCHAR2 
    ,P_ORDER_NO         IN VARCHAR2
    ,P_WRK_ORDR_NO      IN VARCHAR2
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2
    ,P_MATNR            IN VARCHAR2
    ,P_LOT_NO           IN VARCHAR2
    ,P_PRD_STR_DATE     IN VARCHAR2
    ,P_PRD_END_DATE     IN VARCHAR2
    ,P_ABN_CD           IN VARCHAR2
    ,P_RMK              IN VARCHAR2
    ,P_ABN_FUNC         OUT VARCHAR2 
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK03
 * PROGRAM NAME  : 비가동 등록
 * VERSION       : 1.0.0
 * DESCRIPTION   : 작성된 비가동 이력을 저장한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/05/03
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/03    1.0.0   김기연         Initial Version 
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK003] : (C.U.) 비가동 실적
 * - [TB_WRK011] : (..U.) 작업장 현황
 * - [TB_WRK012] : (..U.) 작업장 가동현황
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM			VARCHAR2(100)  := 'SP_POP_WRK03_I01';     -- PROCEDURE NAME
    V_PLT_CD			VARCHAR2(2) := 'AA'; --PLANTCODE TEST
    V_SESS_USER_ID		VARCHAR2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER	EXCEPTION;
    E_SQL_ERR_CD		NUMBER(5) := 0;
    E_SQL_ERR_MSG		VARCHAR2(4000);
    --파라미터 처리
    V_WRK_ORDR_SEQ_NO	NUMBER := TO_NUMBER(P_WRK_ORDR_SEQNO);
    V_PRD_STR_DATE		DATE := TO_DATE(P_PRD_STR_DATE, 'YYYY-MM-DD HH24:MI:SS');
    V_PRD_END_DATE		DATE := TO_DATE(P_PRD_END_DATE, 'YYYY-MM-DD HH24:MI:SS');
    V_IOTYPE			VARCHAR2(10) := CASE WHEN P_WERKS = 'P500' THEN 'N' ELSE P_IOTYPE END;
    --내부 변수 등록
    V_PROC_CD			TB_MAS012.PROC_CD%TYPE;
    
    V_DATE				DATE := SYSDATE;
    V_REC_DATE			VARCHAR2(10) := FN_RECDATE(V_DATE);
   V_PRFM_DATE			VARCHAR2(10) := FN_RECDATE(V_PRD_STR_DATE);
    V_BEF_STR_DATE		DATE; --이전 가동이력 시작시간
    V_DOC_NO			VARCHAR2(29); --MES문서번호
    V_DOC_SEQNO			NUMBER;
    V_WRK_CLASS			VARCHAR2(10);
    V_WRK_SHIFT			VARCHAR2(10);
    V_ABN_TM			NUMBER;
    V_ABN_NM			VARCHAR2(30);
    V_STR_DATE			DATE;
    V_END_DATE			DATE;
    V_RUN_STA			VARCHAR2(10);
    V_RUN_STA_NM		VARCHAR2(30);
    V_MACHINE			VARCHAR2(4);
    V_ORDR_STA			VARCHAR(1); --지시상태
    V_RTN_STA			VARCHAR(1); --복구시 상태
    V_IFMC				VARCHAR2(1);
    V_SAP_WRK_CD		VARCHAR2(20);
    V_TIME_CHK_2		NUMBER := 0;   
    V_TIME_CHK			NUMBER;
    V_IF_ID				VARCHAR2(20) := 'MES_IF_136'; --비가동 등록
    V_SQL				VARCHAR2(4000);
    V_DMY               VARCHAR2(1); 
BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
	        --시간입력시 분단위로 입력되며 시작시간을 01초로 지정
	        IF SUBSTR(P_PRD_STR_DATE,-2) = '00' THEN
	        	V_PRD_STR_DATE := V_PRD_STR_DATE + (INTERVAL '1' SECOND);
	        END IF;
	        
            IF V_PRD_END_DATE IS NOT NULL THEN
                --문서번호 생성
                V_DOC_NO := FN_GET_MDOCNO('M','IF136');
                V_DOC_SEQNO := 1;
                --비가동 시간 계산
                V_ABN_TM := CEIL((V_PRD_END_DATE - V_PRD_STR_DATE) * 24 * 60);
            ELSE
                V_DOC_NO := ' ';
                V_ABN_TM := 0;
            END IF;
            
           BEGIN
	           SELECT PROC_CD 
	             INTO V_PROC_CD
	             FROM TB_MAS012
	            WHERE MACH_CD = P_MACH_CD;
           EXCEPTION WHEN NO_DATA_FOUND THEN
           		RS_CODE := 'E';
		        RS_MSG  := '해당 설비의 공정이 지정되지 않았습니다.\n기준정보를 확인하여 주시기 바랍니다.';
		        RETURN;
           END;
            
            IF P_WRK_ORDR_NO IS NULL THEN
                V_ORDR_STA := 'N'; --COMP_YN => N : 대기, I : 진행, Y : 완료
            ELSE
                --지시정보
                IF P_WERKS = 'P100' THEN
                    --제지 지시별 상태 조회
                    IF V_PROC_CD = 'JA' THEN --점보롤
                        SELECT COMP_YN 
                          INTO V_ORDR_STA 
                          FROM TB_SCH015
                         WHERE 1=1
                           AND WRK_ORDR_NO = P_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                           --AND USE_YN = 'Y'
                           ;
                           
                    ELSIF V_PROC_CD = 'MA' THEN --밀롤
                        SELECT MAX(COMP_YN)
                          INTO V_ORDR_STA 
                          FROM TB_SCH016
                         WHERE 1=1
                           AND PRE_ORDER_NO = P_ORDER_NO
                           AND COMP_YN <> 'Y'
                           AND COMP_YN IS NOT NULL
                           --AND USE_YN = 'Y'
                           ;
                        -- 모두 'Y'인경우 예외처리 추가
    --                ELSIF V_PROC_CD = 'SA' THEN --슬리터
                    ELSIF V_PROC_CD = 'CA' THEN --재단
                        SELECT COMP_YN
                          INTO V_ORDR_STA 
                          FROM TB_SCH017
                         WHERE 1=1
                           AND PRE_ORDER_NO = P_ORDER_NO
                           AND USE_YN = 'Y'
                           ;
    --                ELSIF V_PROC_CD = 'CB' THEN --수재단
                    ELSIF V_PROC_CD = 'PB' OR  V_PROC_CD = 'PC'  OR  V_PROC_CD = 'ZA' THEN --자동포장, 수축포장, 문제재기 적재소
                    	BEGIN
                        SELECT COMP_YN
                          INTO V_ORDR_STA 
                          FROM TB_SCH018
                         WHERE 1=1
                           AND ORDER_NO = P_ORDER_NO
                           --AND USE_YN = 'Y'
                           ;     
                        EXCEPTION WHEN NO_DATA_FOUND THEN
                        	V_ORDR_STA := 'N';
                        END;
                    END IF;                
                ELSIF P_WERKS = 'P200' THEN
                    IF V_PROC_CD = 'AA' THEN --화장지 합지기
                        SELECT COMP_YN 
                          INTO V_ORDR_STA 
                          FROM TB_SCH011
                         WHERE 1=1
                           AND WRK_ORDR_NO = P_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;
                    ELSIF V_PROC_CD = 'RA' THEN --화장지 가공기
                        SELECT COMP_YN 
                          INTO V_ORDR_STA 
                          FROM TB_SCH012
                         WHERE 1=1
                           AND WRK_ORDR_NO = P_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;
                    ELSE
                        V_ORDR_STA := '';
                    END IF;
                ELSIF P_WERKS = 'P300' THEN
                    IF V_PROC_CD = 'RB' THEN --생리대 가공기
                        SELECT COMP_YN 
                          INTO V_ORDR_STA 
                          FROM TB_SCH013
                         WHERE 1=1
                           AND WRK_ORDR_NO = P_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;  
                    ELSE --생리대 예외생산
                        SELECT COMP_YN 
                          INTO V_ORDR_STA 
                          FROM TB_SCH019
                         WHERE 1=1
                           AND WRK_ORDR_NO = P_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                           --AND USE_YN = 'Y'
                           ;
                    END IF;
                ELSIF P_WERKS = 'P500' THEN --기저귀 가공기
                    SELECT COMP_YN 
                      INTO V_ORDR_STA 
                      FROM TB_SCH014
                     WHERE 1=1
                       AND WRK_ORDR_NO = P_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;  
                ELSE  --Default
                    V_ORDR_STA := 'I';
                END IF;
            END IF;
            
            V_RTN_STA := CASE WHEN V_ORDR_STA = 'I' THEN 'R' ELSE 'N' END;

            --설비정보
            SELECT MACHINE, SAP_WRK_CD, IFMC
              INTO V_MACHINE, V_SAP_WRK_CD, V_IFMC
              FROM TB_MAS012
             WHERE 1=1
               AND MACH_CD = P_MACH_CD;
            --비가동 정보
            SELECT ABN_NM, RUN_STA
              INTO V_ABN_NM, V_RUN_STA
              FROM TB_MAS020
             WHERE 1=1
               AND WERKS = P_WERKS
               AND ABN_CD = P_ABN_CD;
            --운전상태 명칭 조회
            SELECT CDESC1
              INTO V_RUN_STA_NM
              FROM CMCDV
             WHERE 1=1
               AND CMCDKY = 'RUNSTA'
               AND CMCDVL = V_RUN_STA;
            --현재 작업자 정보
            BEGIN
            SELECT WRK_CLASS, WRK_SHIFT
              INTO V_WRK_CLASS, V_WRK_SHIFT
              FROM TB_WRK011
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND IN_OUT = V_IOTYPE;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                V_WRK_CLASS := '';
                V_WRK_SHIFT := '';
                dbms_output.put_line('작업장정보 확인');
                --RETURN;
            END;

            -- 비가동 중복여부 확인
            SELECT COUNT(STR_DATE), MIN(STR_DATE), MAX(END_DATE)
              INTO V_TIME_CHK, V_STR_DATE, V_END_DATE
              FROM TB_WRK003
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               --AND IN_OUT = P_IOTYPE
               AND CNL_YN = 'N'
               AND V_PRD_STR_DATE BETWEEN STR_DATE AND END_DATE;
            --시작시간이 범위에 포함되는 경우
            IF V_TIME_CHK > 0 THEN
                RS_CODE := 'E';
                RS_MSG  := '비가동 시작시간이 이미 비가동 상태입니다.\n아래의 기간 이후로 변경하여 주시기 바랍니다.\n';
                RS_MSG  := RS_MSG || TO_CHAR(V_STR_DATE,'YYYY-MM-DD HH24:MI') || ' ~ ';
                RS_MSG  := RS_MSG || TO_CHAR(V_END_DATE,'YYYY-MM-DD HH24:MI');
                dbms_output.put_line('start time');
                RETURN;
            --완료시간이 입력된 경우 추가확인
            ELSIF LENGTH(P_PRD_END_DATE) > 0 THEN
                SELECT COUNT(STR_DATE), MIN(STR_DATE), MAX(END_DATE)
                  INTO V_TIME_CHK, V_STR_DATE, V_END_DATE
                  FROM TB_WRK003
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   --AND IN_OUT = P_IOTYPE
                   AND CNL_YN = 'N'
                   AND V_PRD_END_DATE BETWEEN STR_DATE AND END_DATE;
                IF V_TIME_CHK > 0 THEN
                    RS_CODE := 'E';
                    RS_MSG  := '비가동 완료시간이 이미 비가동 상태입니다.\n아래의 기간 이전으로 변경하여 주시기 바랍니다.\n';
                    RS_MSG  := RS_MSG || TO_CHAR(V_STR_DATE,'YYYY-MM-DD HH24:MI') || ' ~ ';
                    RS_MSG  := RS_MSG || TO_CHAR(V_END_DATE,'YYYY-MM-DD HH24:MI');
                    dbms_output.put_line('end time');
                    RETURN;
                END IF;
            END IF;
            --실적과의 중복여부 확인
--            V_TIME_CHK := 0; --초기화
--            IF P_WERKS = 'P100' THEN
--	            SELECT COUNT(PRD_STR_DATE), MIN(PRD_STR_DATE), MAX(PRD_END_DATE)
--	              INTO V_TIME_CHK, V_STR_DATE, V_END_DATE
--	              FROM TB_WRK002
--	             WHERE 1=1
--	               AND WERKS = P_WERKS
--	               AND MACH_CD = P_MACH_CD
--	               AND NVL(CNL_YN,'N') = 'N'
--	               AND V_PRD_STR_DATE BETWEEN PRD_STR_DATE AND PRD_END_DATE;
--            ELSE
--            	SELECT COUNT(PRD_STR_DATE), MIN(PRD_STR_DATE), MAX(PRD_END_DATE)
--	              INTO V_TIME_CHK, V_STR_DATE, V_END_DATE
--	              FROM TB_WRK001
--	             WHERE 1=1
--	               AND WERKS = P_WERKS
--	               AND MACH_CD = P_MACH_CD
--	               AND NVL(CNL_YN,'N') = 'N'
--	               AND V_PRD_STR_DATE BETWEEN PRD_STR_DATE AND PRD_END_DATE;
--            END IF;
            --시작시간이 범위에 포함되는 경우
--            IF V_TIME_CHK > 0 THEN
--                RS_CODE := 'E';
--                RS_MSG  := '입력된 비가동 범위에 실적이 포함된 상태입니다.\n아래의 기간 이후로 변경하여 주시기 바랍니다.\n';
--                RS_MSG  := RS_MSG || TO_CHAR(V_STR_DATE,'YYYY-MM-DD HH24:MI') || ' ~ ';
--                RS_MSG  := RS_MSG || TO_CHAR(V_END_DATE,'YYYY-MM-DD HH24:MI');
--                dbms_output.put_line('start time');
--                RETURN;
--            --완료시간이 입력된 경우 추가확인
--            ELSIF LENGTH(P_PRD_END_DATE) > 0 THEN
--                IF P_WERKS = 'P100' THEN
--		            SELECT COUNT(PRD_STR_DATE), MIN(PRD_STR_DATE), MAX(PRD_END_DATE)
--		              INTO V_TIME_CHK, V_STR_DATE, V_END_DATE
--		              FROM TB_WRK002
--		             WHERE 1=1
--		               AND WERKS = P_WERKS
--		               AND MACH_CD = P_MACH_CD
--		               AND NVL(CNL_YN,'N') = 'N'
--		               AND V_PRD_END_DATE BETWEEN PRD_STR_DATE AND PRD_END_DATE;
--	            ELSE
--	            	SELECT COUNT(PRD_STR_DATE), MIN(PRD_STR_DATE), MAX(PRD_END_DATE)
--		              INTO V_TIME_CHK, V_STR_DATE, V_END_DATE
--		              FROM TB_WRK001
--		             WHERE 1=1
--		               AND WERKS = P_WERKS
--		               AND MACH_CD = P_MACH_CD
--		               AND NVL(CNL_YN,'N') = 'N'
--		               AND V_PRD_END_DATE BETWEEN PRD_STR_DATE AND PRD_END_DATE;
--	            END IF;
--                IF V_TIME_CHK > 0 THEN
--                    RS_CODE := 'E';
--                    RS_MSG  := '입력된 비가동 범위에 실적이 포함된 상태입니다.\n아래의 기간 이전으로 변경하여 주시기 바랍니다.\n';
--                    RS_MSG  := RS_MSG || TO_CHAR(V_STR_DATE,'YYYY-MM-DD HH24:MI') || ' ~ ';
--                    RS_MSG  := RS_MSG || TO_CHAR(V_END_DATE,'YYYY-MM-DD HH24:MI');
--                    dbms_output.put_line('end time');
--                    RETURN;
--                END IF;
--            END IF;

            --YSH 2022.11.21
            --점보롤은 시작일시을 기준으로 실적일자 판단
            --그외 공정은 종료일시를 기준으로  실적일자 판단
            --V_PRFM_DATE			VARCHAR2(10) := FN_RECDATE(V_PRD_END_DATE);
            IF P_WERKS = 'P100' AND V_PROC_CD = 'JA' THEN 
                V_PRFM_DATE := FN_RECDATE(V_PRD_STR_DATE);
            ELSE
                V_PRFM_DATE := FN_RECDATE(V_PRD_STR_DATE);
            END IF;
            
            -- 비가동 이력 수정
            UPDATE TB_WRK003
               SET END_DATE = V_PRD_END_DATE
                 , ABN_TM = ROUND((V_PRD_END_DATE - STR_DATE) * 24 * 60) --시간차이 분단위 계산
                 , RUN_STA = V_RUN_STA
                 , ABN_CD = P_ABN_CD
                 , ABN_DT = V_PRFM_DATE --TO_CHAR(V_PRD_END_DATE,'YYYYMMDD')
                 , RMK = P_RMK
                 , CNL_YN = 'N'
                 , DOC_NO = V_DOC_NO
                 , DOC_SEQNO = V_DOC_SEQNO
                 , UPDDATE = V_DATE
                 , UPDID = P_USERID
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND IN_OUT = P_IOTYPE
               AND STR_DATE = V_PRD_STR_DATE;
            -- 신규 비가동 이력 등록
            IF SQL%ROWCOUNT = 0 THEN
                --비가동 이력 등록
                INSERT INTO TB_WRK003 (WERKS, MACH_CD, IN_OUT, STR_DATE, END_DATE, RUN_STA, ABN_CD, ABN_TM, ABN_DT,
                                        WRK_CLASS, WRK_SHIFT, WRK_ORDR_NO, WRK_ORDR_SEQNO, RMK, DOC_NO, DOC_SEQNO,
                                        CNL_YN, REGDATE, REGID)
                            VALUES(P_WERKS, P_MACH_CD, P_IOTYPE, V_PRD_STR_DATE, V_PRD_END_DATE, V_RUN_STA, P_ABN_CD, V_ABN_TM, 
                                        V_PRFM_DATE, --TO_CHAR(NVL(V_PRD_END_DATE, V_PRD_STR_DATE),'YYYYMMDD'),
                                        V_WRK_CLASS, V_WRK_SHIFT, P_WRK_ORDR_NO, V_WRK_ORDR_SEQ_NO, P_RMK, V_DOC_NO, V_DOC_SEQNO,
                                        'N', V_DATE, P_USERID);
                --작업장 현황 상태 변경(비가동 등록시 정지)
                UPDATE TB_WRK011
                   SET MACH_STA = CASE WHEN V_PRD_END_DATE IS NULL 
                                       THEN 'S' ELSE V_RTN_STA END  
                     , ABN_DTM = CASE WHEN V_PRD_END_DATE IS NULL 
                                       THEN V_PRD_STR_DATE ELSE NULL END 
                     , ABN_CD = CASE WHEN V_PRD_END_DATE IS NULL 
                                       THEN P_ABN_CD ELSE NULL END 
                     , UPDDATE = V_DATE
                     , UPDID = P_USERID
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD;
                   --AND IN_OUT = V_IOTYPE;
                --이전 작업 시작 시간 조회
                BEGIN
                SELECT MAX(STR_DATE) INTO V_BEF_STR_DATE 
                  FROM TB_WRK012
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IN_OUT = V_IOTYPE
                   AND END_DATE IS NULL;
                EXCEPTION WHEN NO_DATA_FOUND THEN
                    V_BEF_STR_DATE := V_PRD_STR_DATE;
                END;
                --기존 작업장 가동 현황 변경(가동중 이력 완료처리)
                UPDATE TB_WRK012
                   SET END_DATE = V_PRD_STR_DATE
                     , UPDDATE = V_DATE
                     , UPDID = P_USERID
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IN_OUT = V_IOTYPE
                   AND STR_DATE = V_BEF_STR_DATE;
               -- IF SQL%ROWCOUNT = 0 THEN        --YSH 20221203
                    --신규 작업장 가동 현황 등록(비가동 이력 추가)
                    BEGIN
                    INSERT INTO TB_WRK012 (WERKS, MACH_CD, IN_OUT, STR_DATE, END_DATE,
                                            WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, --ORDER_SEQNO,
                                            MATNR, LINE_STA, BEF_LINE_STA, ABN_CD, RMK,
                                            REGDATE, REGID)
                                    VALUES(P_WERKS, P_MACH_CD, V_IOTYPE, V_PRD_STR_DATE, V_PRD_END_DATE,
                                            P_WRK_ORDR_NO, V_WRK_ORDR_SEQ_NO, P_ORDER_NO,
                                            P_MATNR, 'S', 'R', P_ABN_CD, P_RMK,
                                            V_DATE, P_USERID);
                    EXCEPTION
                        WHEN OTHERS THEN
                             V_PRD_STR_DATE := V_PRD_STR_DATE + (INTERVAL '2' SECOND);
                             INSERT INTO TB_WRK012 (WERKS, MACH_CD, IN_OUT, STR_DATE, END_DATE,
                                            WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, --ORDER_SEQNO,
                                            MATNR, LINE_STA, BEF_LINE_STA, ABN_CD, RMK,
                                            REGDATE, REGID)
                                    VALUES(P_WERKS, P_MACH_CD, V_IOTYPE, V_PRD_STR_DATE, V_PRD_END_DATE,
                                            P_WRK_ORDR_NO, V_WRK_ORDR_SEQ_NO, P_ORDER_NO,
                                            P_MATNR, 'S', 'R', P_ABN_CD, P_RMK,
                                            V_DATE, P_USERID);
                    END;
                --END IF;                        
--                완료시간이 null이 아닌 경우 비가동 등록후 가동이력 추가등록
--                IF V_PRD_END_DATE IS NOT NULL THEN
--                    BEGIN
--                        INSERT INTO TB_WRK012 (WERKS, MACH_CD, IN_OUT, STR_DATE,
--                                            WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO,
--                                            MATNR, LINE_STA, BEF_LINE_STA,
--                                            REGDATE, REGID)
--                                    VALUES(P_WERKS, P_MACH_CD, V_IOTYPE, V_PRD_END_DATE,
--                                            P_WRK_ORDR_NO, V_WRK_ORDR_SEQ_NO, P_ORDER_NO,
--                                            P_MATNR, 'R', 'S',
--                                            V_DATE, P_USERID);
--                    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
--                        V_DMY := '1';
--                END;
--                                        
--                END IF;
            -- 비가동 종료시 작업장 현황 수정
            ELSE
                IF V_PRD_END_DATE IS NULL THEN
                    RS_CODE := 'E';
                    RS_MSG  := '비가동 완료시간을 확인하여 주시기 바랍니다.';
                    RETURN;
                ELSE
                    -- 작업장 현황 가동처리(Run)
                    UPDATE TB_WRK011
                       SET MACH_STA = V_RTN_STA
                         , RMK = V_ORDR_STA
                         , ABN_DTM = NULL
                         , ABN_CD= NULL
                         , UPDDATE = V_DATE
                         , UPDID = P_USERID
                     WHERE 1=1
                       AND WERKS = P_WERKS
                       AND MACH_CD = P_MACH_CD;
                       --AND IN_OUT = V_IOTYPE;
                    --작업장 가동현황 수정
                    UPDATE TB_WRK012
                       SET END_DATE = V_PRD_END_DATE
                         , UPDDATE = V_DATE
                         , UPDID = P_USERID
                     WHERE 1=1
                       AND WERKS = P_WERKS
                       AND MACH_CD = P_MACH_CD
                       AND IN_OUT = V_IOTYPE
                       AND STR_DATE = V_PRD_STR_DATE;
--                    신규 가동 현황 등록(가동중 이력 추가)
--                    INSERT INTO TB_WRK012 (WERKS, MACH_CD, IN_OUT, STR_DATE,
--                                            WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO,
--                                            MATNR, LINE_STA, BEF_LINE_STA,
--                                            REGDATE, REGID)
--                                    VALUES(P_WERKS, P_MACH_CD, V_IOTYPE, V_PRD_END_DATE,
--                                            P_WRK_ORDR_NO, V_WRK_ORDR_SEQ_NO, P_ORDER_NO,
--                                            P_MATNR, V_RTN_STA, 'S',
--                                            V_DATE, P_USERID);
                END IF;
            END IF;

            --비가동 완료 등록시 I/F 전송
            IF V_PRD_END_DATE IS NOT NULL THEN
            	--HL이거나 점보롤인경우만 IF전송
            	IF P_WERKS != 'P100' OR V_PROC_CD = 'JA' THEN
	                --작업자 그룹조회
	                BEGIN
	                SELECT WRK_CLASS INTO V_WRK_CLASS
	                  FROM USRMA
	                 WHERE 1=1
	                   AND USERID = P_USERID;
	                EXCEPTION WHEN NO_DATA_FOUND THEN
	                    V_WRK_CLASS := '';
	                END; 
	                --비가동 I/F 전송
	                --YSH 20221209
                    --BUDAT = 생산일자
                    --PRODT = 실적일자(전기일자)로 변경
                    INSERT INTO TB_IFS013 (WERKS, BUDAT, PRODT, MACHINE, IFMC,
	                                        STATM, ENDTM, RUNTIME,
	                                        STSCODE, STSTEXT, RSNCODE, RSNTEXT, MDOCNO, MDOCSEQ,
	                                        MAKE_DATE, MAKER, WORKGROUP, ARBPL,
                                            REMARK)
	                                VALUES(P_WERKS, TO_CHAR(V_PRD_END_DATE,'YYYYMMDD'), V_PRFM_DATE, V_MACHINE, V_IFMC,
	                                        TO_CHAR(V_PRD_STR_DATE,'HH24MISS'), TO_CHAR(V_PRD_END_DATE,'HH24MISS'), V_ABN_TM,
	                                        V_RUN_STA, V_RUN_STA_NM, P_ABN_CD, V_ABN_NM, V_DOC_NO, 1,
	                                        V_DATE, P_USERID, V_WRK_CLASS, V_SAP_WRK_CD,
                                            SUBSTRB(P_RMK, 1, 100));
	
	                --SAP FUNC ID
	                SELECT RFCFN
	                  INTO P_ABN_FUNC
	                  FROM TB_ITFMA
	                 WHERE 1=1
	                   AND IFID = V_IF_ID;
	                --인터페이스 파라미터
	                OPEN CUR_1 FOR
	                SELECT V_IF_ID AS I_IF_ID
	                     , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
	                FROM dual;
	                --인터페이스 상세 파라미터
	                V_SQL := FN_IF_QUERY(V_IF_ID, V_DOC_NO);
	                IF V_SQL IS NOT NULL THEN
	                	OPEN CUR_2 FOR V_SQL;
	                END IF;
                    
                    
                END IF;
            END IF;
            --작업 정상 종료 코드 등록
            RS_CODE := 'S';
        END;
    --예외처리(catch)
--    EXCEPTION
--    WHEN E_EXCEPTION_USER THEN
--        -- 에러 내역 SET
--        E_SQL_ERR_CD        := SQLCODE;
--        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);
--
--        ROLLBACK;
--        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--
--        RS_CODE := 'E';
--        RS_MSG  := SQLERRM;
--        RETURN;
--    WHEN OTHERS THEN
--        E_SQL_ERR_CD        := -20001;
--        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--        ROLLBACK;
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
--
--        RS_CODE := 'E';
--        RS_MSG  := SQLERRM;
--        RETURN;
    --예외처리 종료
    END;
END;
/
