
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_API_OMS" (
    P_TYPE          IN      VARCHAR2, -- LIST, DETAIL
	P_SEND_PARAM    IN      VARCHAR2,
	P_SUCCESS       OUT     VARCHAR2,
    P_CODE          OUT     VARCHAR2,
    P_MSG           OUT     VARCHAR2,
	P_RS_LIST       OUT     SYS_REFCURSOR
)

/*==============================================================================
 * PROGRAM ID    : SP_API_OMS{호출 프로그램 ID 기술}
 * PROGRAM NAME  : OMS 호출 API - 생산진행현황 목록/상세{호출 프로그램 명 기술}
 * VERSION       : 1.0.2{최종 버전 기술}
 * DESCRIPTION   : {프로그램에 대한 상세한 내용 기술}
 *                 예외생산(화장지,생리대,기저귀) > 투입대기자재 Button 선택 시 Popup
 * AUTHOR NAME   : 강지선{최초 작성자 명 기술}
 * CREATE DATE   : 2024/08/20 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2024/08/20    1.0.0   강지선         최초 작성
 * 2024/10/14    1.0.1   강지선         요청 사항 대응 - 조회조건 처리 보강, 조회조건 > 생산호기 추가
 * 2024/10/17    1.0.2   강지선         밀롤 작업지시 조회 처리 수정
 *                                          1. 지장(=VLEN) 입력 안 할 경우 밀롤 포함 조회되도록 요청
 *                                          2. 지장(=VLEN) > 0인 경우 밀롤 생산이 안나오도록 요청
 *                                          3. 지장(=VLEN) = 0인 경우 밀롤 생산만 나오도록 요청
 *==============================================================================
 *  관련 테이블
 *       - [TB_SCH016] : (.R..) 밀롤,슬리터 작업지시
*        - [TB_SCH017] : (.R..) 재단 작업지시
*        - [TB_SCH018] : (.R..) 포장 작업지시
         - [TB_MAS001] : (.R..) 자재기준정보
         - [TB_MAS009] : (.R..) 거래선(업체)마스터
 *=============================================================================*/

AS
    -- 오라클 에러 처리용
    E_EXCEPTION_USER        EXCEPTION;
    E_SQL_ERR_CD            NUMBER(5)           := 0;
    E_SQL_ERR_MSG           VARCHAR2(4000);

    -- JSON용
    V_JSON                  JSON_OBJECT_T;
    V_ARR_LIST              JSON_ARRAY_T;
    V_OBJ                   JSON_OBJECT_T;

    -- 처리용
    V_SQL                   CLOB;
    V_DEBUG                 VARCHAR2(1);
    V_MFLG                  VARCHAR(1);                 -- 밀롤 조회 여부(Y/N)

    -- 세션값 처리용
    V_PLT_CD                VARCHAR2(2);
    V_SESS_USER_ID          VARCHAR2(20);

    -- 조건절 처리용
    V_CUST_CD               VARCHAR2(10);               -- 거래처코드
    V_PRD_REQ_DT_FR         VARCHAR2(8);                -- 생산요청일 FROM  ex. YYYYMMDD
    V_PRD_REQ_DT_TO         VARCHAR2(8);                -- 생산요청일 TO    ex. YYYYMMDD	
    V_PCODE                 VARCHAR2(5);                -- 지종(제품카테고리)
    V_BS_WGT                NUMBER;                     -- 평량
    V_WLEN                  NUMBER;                     -- 지폭
    V_VLEN                  NUMBER;                     -- 지장
    V_TO_MACHINE            VARCHAR2(5);                -- 생산호기

    -- 기타 처리용
    V_CUR_SCH016            SYS_REFCURSOR;
    V_CUR_SCH017            SYS_REFCURSOR;
    V_CUR_SCH018            SYS_REFCURSOR;
    V_OVBELN                VARCHAR2(10);               -- 판매문서번호
    V_OPOSNR                NUMBER;                     -- 판매문서 항목번호
    V_PRE_ORDER_NO          VARCHAR2(12);               -- 이전 생산단계 오더 번호
    V_STR_TEMP              VARCHAR2(10000);            -- TEMP String
    V_WHERE_SCH016          VARCHAR2(10000);            -- TB_SCH016에 사용할 조건절
    V_WHERE_SCH017          VARCHAR2(10000);            -- TB_SCH017에 사용할 조건절
    V_IS_FIRST              BOOLEAN;                    -- 첫번째 확인 위한 Flag
    V_018COMP_YN			VARCHAR2(1);                -- 018 생산단계 완료여부
    V_017COMP_YN			VARCHAR2(1);                -- 017 생산단계 완료여부
    V_016COMP_YN			VARCHAR2(1);                -- 016 생산단계 완료여부
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('## P_TYPE = ' || P_TYPE);
    DBMS_OUTPUT.PUT_LINE('## P_SEND_PARAM = ' || P_SEND_PARAM);

    V_STR_TEMP := REPLACE(P_SEND_PARAM, '#', '"');
    DBMS_OUTPUT.PUT_LINE('## V_STR_TEMP = ' || V_STR_TEMP);
	
    OPEN P_RS_LIST FOR 
    SELECT NULL FROM DUAL WHERE ROWNUM = 0;
   
    -- Init.
    V_MFLG := 'Y';
    V_DEBUG := 'Y';
    V_JSON := JSON_OBJECT_T.parse(V_STR_TEMP);
    P_SUCCESS := 'N';
    P_CODE := 'E';
    P_MSG := '조회된 결과가 없습니다.';

    V_SESS_USER_ID          := V_JSON.get_string('SES_USER_ID');

    IF P_TYPE = 'LIST' THEN  /* 생산진행현황 리스트 */

        /* 조건값 할당 */
        V_CUST_CD           :=  V_JSON.get_string('CUST_CD');	      -- 거래처코드
        V_PRD_REQ_DT_FR     :=  V_JSON.get_string('PRD_REQ_DT_FR');   -- 생산요청일 FROM  ex. YYYYMMDD
        V_PRD_REQ_DT_TO     :=  V_JSON.get_string('PRD_REQ_DT_TO');   -- 생산요청일 TO  ex. YYYYMMDD
        V_PCODE             :=  V_JSON.get_string('PCODE');           -- 지종(제품카테고리)
        V_BS_WGT            :=  V_JSON.get_string('BS_WGT');          -- 평량
        V_WLEN              :=  V_JSON.get_string('WLEN');            -- 지폭
        V_VLEN              :=  V_JSON.get_string('VLEN');            -- 지장
        V_TO_MACHINE        :=  V_JSON.get_string('TO_MACHINE');      -- 생산호기

        DBMS_OUTPUT.PUT_LINE('## V_VLEN = ' || V_VLEN);
        
        -- 1. 지장(=VLEN) 입력 안 할 경우 밀롤 포함 조회되도록 요청 - V_MFLG := 'Y'
        IF V_VLEN IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('## V_VLEN IS NOT NULL = ' || V_VLEN);
            V_VLEN :=  TO_NUMBER(V_VLEN);
            DBMS_OUTPUT.PUT_LINE('## TO_NUMBER(V_VLEN) = ' || V_VLEN);
            -- 2. 지장(=VLEN) > 0 인 경우 밀롤 생산이 안나오도록 요청 - V_MFLG := 'N'
            IF V_VLEN > 0 THEN
                V_MFLG := 'N';

            -- 3. 지장(=VLEN) = 0인 경우 밀롤 생산 Only - V_MFLG := 'O'
            ELSIF V_VLEN = 0 THEN
                V_MFLG := 'O';
            END IF;
        END IF;
        DBMS_OUTPUT.PUT_LINE('## V_MFLG = ' || V_MFLG);

        -- STEP 1. GET PRE_ORDER_NO(이전 생산단계 주문번호) FROM TB_SCH018(포장)
        V_SQL := '
            SELECT DISTINCT PRE_ORDER_NO
            FROM TB_SCH018 
            WHERE NVL(DLFL, ''N'') = ''N''
        ';

		IF V_CUST_CD IS NOT NULL THEN
		    V_SQL := V_SQL || ' AND KUNNR = ''' || V_CUST_CD || ''' ';  -- 거래처코드
		END IF;
		
		IF V_PRD_REQ_DT_FR IS NOT NULL THEN
            IF V_PRD_REQ_DT_TO IS NOT NULL THEN
                V_SQL := V_SQL || ' AND PRD_REQ_DT BETWEEN ''' || V_PRD_REQ_DT_FR || ''' AND ''' || V_PRD_REQ_DT_TO || ''' ';  -- 생산요청일
            END IF;
		END IF;

		IF V_PCODE IS NOT NULL THEN
		    V_SQL := V_SQL || ' AND PCODE = ''' || V_PCODE || ''' ';  -- 지종(제품카테고리)
		END IF;
		
		IF V_BS_WGT IS NOT NULL THEN
		    V_SQL := V_SQL || ' AND BS_WGT = ''' || V_BS_WGT || ''' ';  -- 평량
		END IF;
		
		IF V_WLEN IS NOT NULL THEN
		    V_SQL := V_SQL || ' AND WLEN = ''' || V_WLEN || ''' ';  -- 지폭
		END IF;
		
		IF V_VLEN IS NOT NULL THEN
		    V_SQL := V_SQL || ' AND VLEN = ''' || V_VLEN || ''' ';  -- 지장
		END IF;

		IF V_TO_MACHINE IS NOT NULL THEN
		    V_SQL := V_SQL || ' AND TO_MACHINE = ''' || V_TO_MACHINE || ''' ';  -- 생산호기
		END IF;


		IF V_DEBUG = 'Y' THEN
		    INSERT INTO PROC_LOG(SQL_STR) VALUES ('(STEP 1.포장) ' || V_SQL);
		END IF;
		
        OPEN V_CUR_SCH018 FOR V_SQL;

        -- V_CUR_SCH018로 조건절 구성
        V_WHERE_SCH017 := ''; -- 초기화
        V_IS_FIRST := TRUE;    -- 첫 번째 행인지 확인하기 위한 플래그

        LOOP
            FETCH V_CUR_SCH018 INTO V_PRE_ORDER_NO;
            EXIT WHEN V_CUR_SCH018%NOTFOUND;  -- 더 이상 가져올 데이터가 없으면 루프 종료

            -- 첫 번째 행이 아니면 콤마 추가
            IF NOT V_IS_FIRST THEN
                V_WHERE_SCH017 := V_WHERE_SCH017 || ',';
            END IF;

            -- 현재 행 추가
            V_WHERE_SCH017 := V_WHERE_SCH017 || '''' || V_PRE_ORDER_NO || '''';

            -- 첫 번째 행 이후로는 플래그를 FALSE로 설정
            V_IS_FIRST := FALSE;

        END LOOP;
        CLOSE V_CUR_SCH018;

        -- STEP 2. GET PRE_ORDER_NO(이전 생산단계 주문번호) FROM TB_SCH017(재단)
        V_SQL := '';
        V_SQL := '
            SELECT DISTINCT PRE_ORDER_NO 
            FROM TB_SCH017 
            WHERE NVL(DLFL, ''N'') = ''N''
        ';

		IF V_CUST_CD IS NOT NULL THEN
		    V_SQL := V_SQL || ' AND KUNNR = ''' || V_CUST_CD || ''' ';  -- 거래처코드
		END IF;
		
		IF V_PRD_REQ_DT_FR IS NOT NULL THEN
            IF V_PRD_REQ_DT_TO IS NOT NULL THEN
                V_SQL := V_SQL || ' AND PRD_REQ_DT BETWEEN ''' || V_PRD_REQ_DT_FR || ''' AND ''' || V_PRD_REQ_DT_TO || ''' ';  -- 생산요청일
            END IF;
		END IF;

		IF V_PCODE IS NOT NULL THEN
		    V_SQL := V_SQL || ' AND PCODE = ''' || V_PCODE || ''' ';  -- 지종(제품카테고리)
		END IF;
		
		IF V_BS_WGT IS NOT NULL THEN
		    V_SQL := V_SQL || ' AND BS_WGT = ''' || V_BS_WGT || ''' ';  -- 평량
		END IF;
		
		IF V_WLEN IS NOT NULL THEN
		    V_SQL := V_SQL || ' AND WLEN = ''' || V_WLEN || ''' ';  -- 지폭
		END IF;
		
		IF V_VLEN IS NOT NULL THEN
		    V_SQL := V_SQL || ' AND VLEN = ''' || V_VLEN || ''' ';  -- 지장
		END IF;

		IF V_TO_MACHINE IS NOT NULL THEN
		    V_SQL := V_SQL || ' AND TO_MACHINE = ''' || V_TO_MACHINE || ''' ';  -- 생산호기
		END IF;
   
        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES ('(STEP 2.재단) ' || V_SQL);
        END IF;

        -- TB_SCH017용 커서 사용
        OPEN V_CUR_SCH017 FOR V_SQL;

        -- V_CUR_SCH017로 조건절 구성
        V_WHERE_SCH016 := ''; -- 초기화
        V_IS_FIRST := TRUE;    -- 첫 번째 행인지 확인하기 위한 플래그

        LOOP
            FETCH V_CUR_SCH017 INTO V_PRE_ORDER_NO;
            EXIT WHEN V_CUR_SCH017%NOTFOUND;  -- 더 이상 가져올 데이터가 없으면 루프 종료

            -- 첫 번째 행이 아니면 콤마 추가
            IF NOT V_IS_FIRST THEN
                V_WHERE_SCH016 := V_WHERE_SCH016 || ',';
            END IF;

            -- 현재 행 추가
            V_WHERE_SCH016 := V_WHERE_SCH016 || '''' || V_PRE_ORDER_NO || '''';

            -- 첫 번째 행 이후로는 플래그를 FALSE로 설정
            V_IS_FIRST := FALSE;

        END LOOP;
        CLOSE V_CUR_SCH017;

        -- STEP 3. GET FINAL LIST
        -- 밀롤 조회 여부에 따른 분기
        IF V_MFLG = 'O' THEN -- 밀롤 Only

            V_SQL := '';
            V_SQL := '
						SELECT 
							CASE 
								WHEN SUBSTR(SCH016.MATNR ,2,1) = ''2''
								THEN ''PM2''
								WHEN SUBSTR(SCH016.MATNR ,2,1) = ''3''
								THEN ''PM3''
								ELSE ''PM0''
							END TO_MACHINE,
							CASE 
								WHEN SUBSTR(SCH016.MATNR ,2,1) = ''2''
								THEN ''2호기''
								WHEN SUBSTR(SCH016.MATNR ,2,1) = ''3''
								THEN ''3호기''
								ELSE ''0호기''
							END TO_MACHINE_NM,
                            SCH016.MATNR, 
                            M001.MATNR_NM, 
							''밀롤'' AS PROC_NAME,
                            M009.CUST_CD,
                            M009.CUST_NM,
                            SCH016.COMP_YN AS PROC_STAT,
                            CASE 
                                WHEN SUBSTR(SCH016.WRK_ORDR_NO, 3, 2) = ''EX'' 
                                THEN ''예외'' 
                                ELSE ''일반'' 
                            END AS PROC_TYPE,
                            SCH016.PRD_REQ_DT, 
                            SCH016.ORDR_GEN_DT, 
                            NVL(SUM(SCH016.WRK_ORDR_QTY), 0) AS WRK_ORDR_QTY, 
                            SCH016.ORDER_DIV,
                            SCH016.ORDER_DIV_NM,
                            SCH016.OVBELN, 
                            SCH016.OPOSNR
                        FROM   
                            TB_SCH016 SCH016 
                            INNER JOIN TB_MAS001 M001 ON SCH016.WERKS = M001.WERKS AND SCH016.MATNR = M001.MATNR
                            INNER JOIN TB_MAS009 M009 ON SCH016.KUNNR = M009.CUST_CD AND M009.CUST_DIV = ''C''
                        WHERE   NVL(SCH016.DLFL, ''N'')     = ''N''
                        AND     SCH016.SHEET                <> ''X''   -- 판지 제외
						AND 	NVL(SCH016.SLITER,''N'') != ''Y''
                ';

                IF V_CUST_CD IS NOT NULL THEN
                    V_SQL := V_SQL || ' AND     SCH016.KUNNR        = ''' || V_CUST_CD || ''' ';
                END IF;
                IF V_PRD_REQ_DT_FR IS NOT NULL THEN
                    IF V_PRD_REQ_DT_TO IS NOT NULL THEN
                        V_SQL := V_SQL || ' AND     SCH016.PRD_REQ_DT BETWEEN ''' || V_PRD_REQ_DT_FR || ''' AND ''' || V_PRD_REQ_DT_TO || '''  ';
                    END IF;
                END IF;
                IF V_PCODE IS NOT NULL THEN
                    V_SQL := V_SQL || ' AND		SCH016.PCODE        = ''' || V_PCODE || ''' ';
                END IF;
                IF V_BS_WGT IS NOT NULL THEN
                    V_SQL := V_SQL || ' AND     SCH016.BS_WGT       = ''' || V_BS_WGT || ''' ';
                END IF;
                IF V_WLEN IS NOT NULL THEN
                    V_SQL := V_SQL || ' AND     SCH016.MWIDTH         = ''' || V_WLEN || ''' ';
                END IF;
                IF V_TO_MACHINE IS NOT NULL THEN
                    V_SQL := V_SQL || ' AND     SCH015.TO_MACHINE           = ''' || V_TO_MACHINE || ''' ';
                END IF;
                IF V_WHERE_SCH016 IS NOT NULL THEN
                    V_SQL := V_SQL || ' AND     SCH016.ORDER_NO NOT IN (' || V_WHERE_SCH016 || ') ';
                END IF;

                V_SQL := V_SQL || '
					GROUP BY 
                            SCH016.MATNR, 
                            M001.MATNR_NM,
                            M009.CUST_CD,
                            M009.CUST_NM,
                            SCH016.COMP_YN,
                            CASE 
                                WHEN SUBSTR(SCH016.WRK_ORDR_NO, 3, 2) = ''EX'' 
                                THEN ''예외'' 
                                ELSE ''일반'' 
                            END,
                            SCH016.PRD_REQ_DT, 
                            SCH016.ORDR_GEN_DT, 
                            SCH016.ORDER_DIV,
                            SCH016.ORDER_DIV_NM,
                            SCH016.OVBELN, 
                            SCH016.OPOSNR
                   ORDER BY SCH016.PRD_REQ_DT DESC
                ';
        ELSE

            V_SQL := '';
            V_SQL := '
                SELECT  
                    A.TO_MACHINE, 
                    A.TO_MACHINE_NM, 
                    A.MATNR, 
                    A.MATNR_NM, 
                    A.PROC_NAME, 
                    A.CUST_CD,
                    A.CUST_NM,
                    A.PROC_STAT, 
                    A.PROC_TYPE, 
                    A.PRD_REQ_DT,
                    A.ORDR_GEN_DT, 
                    A.WRK_ORDR_QTY, 
                    A.ORDER_DIV,
                    A.ORDER_DIV_NM,
                    A.OVBELN, 
                    A.OPOSNR
                FROM
                (
					SELECT 
						CASE 
							WHEN SUBSTR(SCH018.MATNR ,2,1) = ''2''
							THEN ''PM2''
							WHEN SUBSTR(SCH018.MATNR ,2,1) = ''3''
							THEN ''PM3''
							ELSE ''PM0''
						END TO_MACHINE,
						CASE 
							WHEN SUBSTR(SCH018.MATNR ,2,1) = ''2''
							THEN ''2호기''
							WHEN SUBSTR(SCH018.MATNR ,2,1) = ''3''
							THEN ''3호기''
							ELSE ''0호기''
						END TO_MACHINE_NM,
                        SCH018.MATNR, 
                        M001.MATNR_NM, 
                        ''포장'' AS PROC_NAME,
                        M009.CUST_CD,
                        M009.CUST_NM,
                        SCH018.COMP_YN AS PROC_STAT,
                        CASE 
                            WHEN SUBSTR(SCH018.WRK_ORDR_NO, 3, 2) = ''EX'' 
                            THEN ''예외'' 
                            ELSE ''일반'' 
                        END AS PROC_TYPE,
                        SCH018.PRD_REQ_DT, 
                        SCH018.ORDR_GEN_DT, 
                        SUM(NVL(SCH018.WRK_ORDR_QTY, 0)) AS WRK_ORDR_QTY, 
                        SCH018.ORDER_DIV,
                        SCH018.ORDER_DIV_NM,
                        SCH018.OVBELN, 
                        SCH018.OPOSNR
                    FROM 
                        TB_SCH018 SCH018 
                        INNER JOIN TB_MAS001 M001 ON SCH018.WERKS = M001.WERKS AND SCH018.MATNR = M001.MATNR
                        INNER JOIN TB_MAS009 M009 ON SCH018.KUNNR = M009.CUST_CD AND M009.CUST_DIV = ''C''
		            WHERE   NVL(SCH018.DLFL, ''N'') = ''N''
            ';

            IF V_CUST_CD IS NOT NULL THEN
                V_SQL := V_SQL || ' AND     SCH018.KUNNR        = ''' || V_CUST_CD || ''' ';
            END IF;
            IF V_PRD_REQ_DT_FR IS NOT NULL THEN
                IF V_PRD_REQ_DT_TO IS NOT NULL THEN
                    V_SQL := V_SQL || ' AND     SCH018.PRD_REQ_DT BETWEEN ''' || V_PRD_REQ_DT_FR || ''' AND ''' || V_PRD_REQ_DT_TO || '''  ';
                END IF;
            END IF;
            IF V_PCODE IS NOT NULL THEN
                V_SQL := V_SQL || ' AND		SCH018.PCODE        = ''' || V_PCODE || ''' ';
            END IF;
            IF V_BS_WGT IS NOT NULL THEN
                V_SQL := V_SQL || ' AND     SCH018.BS_WGT       = ''' || V_BS_WGT || ''' ';
            END IF;
            IF V_WLEN IS NOT NULL THEN
                V_SQL := V_SQL || ' AND     SCH018.WLEN         = ''' || V_WLEN || ''' ';
            END IF;
            IF V_VLEN IS NOT NULL THEN
                V_SQL := V_SQL || ' AND     SCH018.VLEN         = ''' || V_VLEN || ''' ';
            END IF;
            IF V_TO_MACHINE IS NOT NULL THEN
                V_SQL := V_SQL || ' AND     SCH018.TO_MACHINE   = ''' || V_TO_MACHINE || ''' ';
            END IF;

            V_SQL := V_SQL || '
					GROUP BY 
                        SCH018.MATNR, 
                        M001.MATNR_NM, 
                        M009.CUST_CD,
                        M009.CUST_NM,
                        SCH018.COMP_YN,
                        CASE 
                            WHEN SUBSTR(SCH018.WRK_ORDR_NO, 3, 2) = ''EX'' 
                            THEN ''예외'' 
                            ELSE ''일반'' 
                        END,
                        SCH018.PRD_REQ_DT, 
                        SCH018.ORDR_GEN_DT, 
                        SCH018.ORDER_DIV,
                        SCH018.ORDER_DIV_NM,
                        SCH018.OVBELN, 
                        SCH018.OPOSNR
			';

            IF V_MFLG = 'Y' THEN
                V_SQL := V_SQL || '

                    UNION ALL

						SELECT 
							CASE 
								WHEN SUBSTR(SCH016.MATNR ,2,1) = ''2''
								THEN ''PM2''
								WHEN SUBSTR(SCH016.MATNR ,2,1) = ''3''
								THEN ''PM3''
								ELSE ''PM0''
							END TO_MACHINE,
							CASE 
								WHEN SUBSTR(SCH016.MATNR ,2,1) = ''2''
								THEN ''2호기''
								WHEN SUBSTR(SCH016.MATNR ,2,1) = ''3''
								THEN ''3호기''
								ELSE ''0호기''
							END TO_MACHINE_NM,
                            SCH016.MATNR, 
                            M001.MATNR_NM, 
							''밀롤'' AS PROC_NAME,
                            M009.CUST_CD,
                            M009.CUST_NM,
                            SCH016.COMP_YN AS PROC_STAT,
                            CASE 
                                WHEN SUBSTR(SCH016.WRK_ORDR_NO, 3, 2) = ''EX'' 
                                THEN ''예외'' 
                                ELSE ''일반'' 
                            END AS PROC_TYPE,
                            SCH016.PRD_REQ_DT, 
                            SCH016.ORDR_GEN_DT, 
                            SUM(NVL(SCH016.WRK_ORDR_QTY, 0)) AS WRK_ORDR_QTY, 
                            SCH016.ORDER_DIV,
                            SCH016.ORDER_DIV_NM,
                            SCH016.OVBELN, 
                            SCH016.OPOSNR
                        FROM   
                            TB_SCH016 SCH016 
                            INNER JOIN TB_MAS001 M001 ON SCH016.WERKS = M001.WERKS AND SCH016.MATNR = M001.MATNR
                            INNER JOIN TB_MAS009 M009 ON SCH016.KUNNR = M009.CUST_CD AND M009.CUST_DIV = ''C''                  
                        WHERE   NVL(SCH016.DLFL, ''N'')     = ''N''
                        AND     SCH016.SHEET                <> ''X''   -- 판지 제외
						AND 	NVL(SCH016.SLITER,''N'') != ''Y''
                ';

                IF V_CUST_CD IS NOT NULL THEN
                    V_SQL := V_SQL || ' AND     SCH016.KUNNR        = ''' || V_CUST_CD || ''' ';
                END IF;
                IF V_PRD_REQ_DT_FR IS NOT NULL THEN
                    IF V_PRD_REQ_DT_TO IS NOT NULL THEN
                        V_SQL := V_SQL || ' AND     SCH016.PRD_REQ_DT BETWEEN ''' || V_PRD_REQ_DT_FR || ''' AND ''' || V_PRD_REQ_DT_TO || '''  ';
                    END IF;
                END IF;
                IF V_PCODE IS NOT NULL THEN
                    V_SQL := V_SQL || ' AND		SCH016.PCODE        = ''' || V_PCODE || ''' ';
                END IF;
                IF V_BS_WGT IS NOT NULL THEN
                    V_SQL := V_SQL || ' AND     SCH016.BS_WGT       = ''' || V_BS_WGT || ''' ';
                END IF;
                IF V_WLEN IS NOT NULL THEN
                    V_SQL := V_SQL || ' AND     SCH016.MWIDTH         = ''' || V_WLEN || ''' ';
                END IF;
                IF V_TO_MACHINE IS NOT NULL THEN
                    V_SQL := V_SQL || ' AND     SCH016.TO_MACHINE           = ''' || V_TO_MACHINE || ''' ';
                END IF;
                IF V_WHERE_SCH016 IS NOT NULL THEN
                    V_SQL := V_SQL || ' AND     SCH016.ORDER_NO NOT IN (' || V_WHERE_SCH016 || ') ';
                END IF;         
               V_SQL := V_SQL || '
						GROUP BY 
                            SCH016.MATNR, 
                            M001.MATNR_NM,
                            M009.CUST_CD,
                            M009.CUST_NM,
                            SCH016.COMP_YN,
                            CASE 
                                WHEN SUBSTR(SCH016.WRK_ORDR_NO, 3, 2) = ''EX'' 
                                THEN ''예외'' 
                                ELSE ''일반'' 
                            END,
                            SCH016.PRD_REQ_DT, 
                            SCH016.ORDR_GEN_DT, 
                            SCH016.ORDER_DIV,
                            SCH016.ORDER_DIV_NM,
                            SCH016.OVBELN, 
                            SCH016.OPOSNR
            ';
               
            END IF;
                    
            V_SQL := V_SQL || '
                    ) A
                ORDER BY A.PRD_REQ_DT DESC
            ';
        END IF;

        DBMS_OUTPUT.PUT_LINE('## V_SQL = ' || V_SQL);

		IF V_DEBUG = 'Y' THEN
		    INSERT INTO PROC_LOG(SQL_STR) VALUES ('(STEP 3.FINAL) ' || V_SQL);
		END IF;
		
        OPEN P_RS_LIST FOR V_SQL;

        P_MSG := '조회가 완료되었습니다.';
        
-----------------------------------------------------------------------------------------------------------------------------------------------------------------        
    ELSIF P_TYPE = 'DETAIL' THEN  /* 생산진행현황 상세 */

        -- Request Param. 
        V_OVBELN              :=  V_JSON.get_string('OVBELN');   -- 판매문서번호
        V_OPOSNR              :=  V_JSON.get_string('OPOSNR');   -- 판매문서 항목번호

        IF V_OPOSNR <> '' THEN
            V_OPOSNR :=  TO_NUMBER(V_OPOSNR);
        END IF;
       
		 -- STEP 1. GET PRE_ORDER_NO(이전 생산단계 주문번호) FROM TB_SCH018(포장)
        V_SQL := '
            SELECT DISTINCT USE_YN
            FROM TB_SCH018 
            WHERE NVL(DLFL, ''N'') = ''N''
            AND OVBELN = ''' || V_OVBELN || '''
            AND OPOSNR = ' || V_OPOSNR || '
        ';

		IF V_DEBUG = 'Y' THEN
		    INSERT INTO PROC_LOG(SQL_STR) VALUES ('(D > STEP 1.포장) ' || V_SQL);
		END IF;
		
        OPEN V_CUR_SCH018 FOR V_SQL;

        LOOP
            FETCH V_CUR_SCH018 INTO V_018COMP_YN;
            EXIT WHEN V_CUR_SCH018%NOTFOUND;  -- 더 이상 가져올 데이터가 없으면 루프 종료

        END LOOP;
        CLOSE V_CUR_SCH018;
        DBMS_OUTPUT.PUT_LINE('## V_018COMP_YN = ' || V_018COMP_YN);
       
        V_SQL := '';
        V_SQL := '
                -- 밀롤
				SELECT
                    SCH016.MATNR, 
                    M001.MATNR_NM,
					CASE WHEN SCH016.SLITER = ''X'' THEN ''슬리터''
                    	ELSE ''밀롤'' 
                    END AS PROC_NAME, 
                    SCH016.COMP_YN AS PROC_STAT,
                    CASE 
                        WHEN SUBSTR(SCH016.WRK_ORDR_NO, 3, 2) = ''EX'' 
                        THEN ''예외'' 
                        ELSE ''일반'' 
                    END AS PROC_TYPE,
                    SUM(SCH016.WRK_ORDR_QTY) AS WRK_ORDR_QTY,
                    SUM(W002.PRFM_QTY) AS PRFM_QTY,
                    MAX(W002.PRFM_UNIT) AS PRFM_UNIT,
                    SUM(IFSWM005.RCVGDS_QTY) AS RCVGDS_QTY,
                    MAX(IFSWM005.RCVGDS_UNIT) AS RCVGDS_UNIT,
                    SUM(W002.EX_PRFM_QTY) AS EX_PRFM_QTY,
                    MAX(W002.EX_PRFM_UNIT) AS EX_PRFM_UNIT,
                    SUM(IFSWM005.EX_RCVGDS_QTY) AS EX_RCVGDS_QTY,
                    MAX(IFSWM005.EX_RCVGDS_UNIT) AS EX_RCVGDS_UNIT,
                    MAX(SCH016.PRD_REQ_DT) AS PRD_REQ_DT,
                    MAX(W002.PRFM_DT) AS PRFM_DT,
                    MAX(IFSWM005.RCVGDS_DT) AS RCVGDS_DT,
                    MAX(W002.EX_PRFM_DT) AS EX_PRFM_DT,
                    MAX(IFSWM005.EX_RCVGDS_DT) AS EX_RCVGDS_DT
                FROM
                    TB_SCH016 SCH016
                    INNER JOIN TB_MAS001 M001 ON SCH016.WERKS = M001.WERKS AND SCH016.MATNR = M001.MATNR
                    LEFT JOIN (
						SELECT MATNR
							, WRK_ORDR_NO
							, WRK_ORDR_SEQNO
							, SUM(NVL(CASE WHEN SUBSTR(WRK_ORDR_NO, 3, 2) != ''EX'' 
									THEN PRFM_QTY
								ELSE
									0
								END,0)) AS PRFM_QTY
							, MAX(CASE WHEN SUBSTR(WRK_ORDR_NO, 3, 2) != ''EX'' 
									THEN UNIT
								ELSE
									''''
								END) AS PRFM_UNIT	
							, SUM(NVL(CASE WHEN SUBSTR(WRK_ORDR_NO, 3, 2) = ''EX'' 
									THEN PRFM_QTY
								ELSE
									0
								END,0)) EX_PRFM_QTY		
							, MAX(CASE WHEN SUBSTR(WRK_ORDR_NO, 3, 2) = ''EX'' 
									THEN UNIT
								ELSE
									''''
								END) EX_PRFM_UNIT
							, MAX(CASE WHEN SUBSTR(WRK_ORDR_NO, 3, 2) != ''EX'' 
									THEN PRFM_DT
								ELSE
									''''
								END) AS PRFM_DT	
							, MAX(CASE WHEN SUBSTR(WRK_ORDR_NO, 3, 2) = ''EX'' 
									THEN PRFM_DT
								ELSE
									''''
								END) EX_PRFM_DT	
						FROM TB_WRK002
						WHERE (MATNR, WRK_ORDR_NO, WRK_ORDR_SEQNO) IN (
								SELECT MATNR, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_SCH016 WHERE OVBELN = ''' || V_OVBELN || ''' AND OPOSNR = ' || V_OPOSNR || ' 
							)
						    AND NVL(CNL_YN, ''N'') = ''N''
						    GROUP BY MATNR
								, WRK_ORDR_NO
								, WRK_ORDR_SEQNO
					) W002 ON SCH016.MATNR = W002.MATNR
					    AND SCH016.WRK_ORDR_NO = W002.WRK_ORDR_NO
						AND SCH016.WRK_ORDR_SEQNO = W002.WRK_ORDR_SEQNO 
                    LEFT JOIN (
						SELECT A.ORDER_NO
							, SUM(NVL(CASE WHEN SUBSTR(B.WRK_ORDR_NO, 3, 2) != ''EX'' 
									THEN A.QTY
								ELSE
									0
								END,0)) AS RCVGDS_QTY
							, MAX(CASE WHEN SUBSTR(B.WRK_ORDR_NO, 3, 2) != ''EX'' 
									THEN A.UNIT
								ELSE
									''''
								END) AS RCVGDS_UNIT	
							, MAX(CASE WHEN SUBSTR(B.WRK_ORDR_NO, 3, 2) != ''EX'' 
									THEN A.RCVGDS_DT
								ELSE
									''''
								END) AS RCVGDS_DT	
							, SUM(NVL(CASE WHEN SUBSTR(B.WRK_ORDR_NO, 3, 2) = ''EX'' 
									THEN A.QTY
								ELSE
									0
								END,0)) EX_RCVGDS_QTY		
							, MAX(CASE WHEN SUBSTR(B.WRK_ORDR_NO, 3, 2) = ''EX'' 
									THEN A.UNIT
								ELSE
									''''
								END) EX_RCVGDS_UNIT
							, MAX(CASE WHEN SUBSTR(B.WRK_ORDR_NO, 3, 2) = ''EX'' 
									THEN A.RCVGDS_DT
								ELSE
									''''
								END) AS EX_RCVGDS_DT
							FROM TB_IFSWM005 A
							INNER JOIN TB_SCH016 B
								ON A.ORDER_NO = B.ORDER_NO 
								AND B.OVBELN = ''' || V_OVBELN || '''
								AND B.OPOSNR = ' || V_OPOSNR || '
							WHERE A.DLFL = ''C''
								AND A.IF_STATUS = ''S''
						GROUP BY A.ORDER_NO	
					) IFSWM005 ON SCH016.ORDER_NO = IFSWM005.ORDER_NO
                WHERE   SCH016.OVBELN = ''' || V_OVBELN || '''
                AND     SCH016.OPOSNR = ' || V_OPOSNR || '
				AND 	NVL(SCH016.SLITER, ''N'') != ''Y''
                GROUP BY 
                    SCH016.MATNR, 
                    M001.MATNR_NM, 
					CASE WHEN SCH016.SLITER = ''X'' THEN ''슬리터''
                    	ELSE ''밀롤'' 
                    END,
                    SCH016.COMP_YN,
                    CASE 
                        WHEN SUBSTR(SCH016.WRK_ORDR_NO, 3, 2) = ''EX'' 
                        THEN ''예외'' 
                        ELSE ''일반'' 
                    END
            -- 재단
			UNION ALL

			SELECT   
                SCH017.MATNR, 
                M001.MATNR_NM, 
                CASE WHEN SCH017.MAN_CUT_YN = ''X'' THEN ''수재단''
                	ELSE ''재단'' 
                END AS PROC_NAME,
                SCH017.COMP_YN AS PROC_STAT,
                CASE 
                    WHEN SUBSTR(SCH017.WRK_ORDR_NO, 3, 2) = ''EX'' 
                    THEN ''예외'' 
                    ELSE ''일반'' 
                END AS PROC_TYPE,
                SUM(SCH017.WRK_ORDR_QTY) AS WRK_ORDR_QTY,
                ROUND(SUM(W002.PRFM_QTY)/500,2) AS PRFM_QTY,
                ''R'' AS PRFM_UNIT,
                ROUND(SUM(IFSWM005.RCVGDS_QTY)/500,2) AS RCVGDS_QTY,
                ''R'' AS RCVGDS_UNIT,
                ROUND(SUM(W002.EX_PRFM_QTY)/500,2) AS EX_PRFM_QTY,
                ''R'' AS EX_PRFM_UNIT,
                ROUND(SUM(IFSWM005.EX_RCVGDS_QTY),2) AS EX_RCVGDS_QTY,
                ''R'' AS EX_RCVGDS_UNIT,
                MAX(SCH017.PRD_REQ_DT) AS PRD_REQ_DT,
                MAX(W002.PRFM_DT) AS PRFM_DT,
                MAX(IFSWM005.RCVGDS_DT) AS RCVGDS_DT,
                MAX(W002.EX_PRFM_DT) AS EX_PRFM_DT,
                MAX(IFSWM005.EX_RCVGDS_DT) AS EX_RCVGDS_DT
            FROM   
                TB_SCH017 SCH017 
                INNER JOIN TB_MAS001 M001 ON SCH017.WERKS = M001.WERKS AND SCH017.MATNR = M001.MATNR
                LEFT JOIN (
					SELECT MATNR
						, WRK_ORDR_NO
						, WRK_ORDR_SEQNO
						, SUM(NVL(CASE WHEN SUBSTR(WRK_ORDR_NO, 3, 2) != ''EX'' 
								THEN PRFM_QTY
							ELSE
								0
							END,0)) AS PRFM_QTY
						, SUM(NVL(CASE WHEN SUBSTR(WRK_ORDR_NO, 3, 2) = ''EX'' 
								THEN PRFM_QTY
							ELSE
								0
							END,0)) EX_PRFM_QTY
						, MAX(CASE WHEN SUBSTR(WRK_ORDR_NO, 3, 2) != ''EX'' 
								THEN PRFM_DT
							ELSE
								''''
							END) AS PRFM_DT	
						, MAX(CASE WHEN SUBSTR(WRK_ORDR_NO, 3, 2) = ''EX'' 
								THEN PRFM_DT
							ELSE
								''''
							END) EX_PRFM_DT	
					FROM TB_WRK002
					WHERE (MATNR, WRK_ORDR_NO, WRK_ORDR_SEQNO) IN (
							SELECT MATNR, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_SCH017 WHERE OVBELN = ''' || V_OVBELN || ''' AND OPOSNR = ' || V_OPOSNR || '
						)
					    AND NVL(CNL_YN, ''N'') = ''N''
					    GROUP BY MATNR
							, WRK_ORDR_NO
							, WRK_ORDR_SEQNO
				) W002 ON SCH017.MATNR = W002.MATNR
				    AND SCH017.WRK_ORDR_NO = W002.WRK_ORDR_NO
					AND SCH017.WRK_ORDR_SEQNO = W002.WRK_ORDR_SEQNO 
                LEFT JOIN (
					SELECT A.ORDER_NO
						, SUM(NVL(CASE WHEN SUBSTR(B.WRK_ORDR_NO, 3, 2) != ''EX'' 
								THEN A.QTY
							ELSE
								0
							END,0)) AS RCVGDS_QTY
						, MAX(CASE WHEN SUBSTR(B.WRK_ORDR_NO, 3, 2) != ''EX'' 
								THEN A.RCVGDS_DT
							ELSE
								''''
							END) AS RCVGDS_DT	
						, SUM(NVL(CASE WHEN SUBSTR(B.WRK_ORDR_NO, 3, 2) = ''EX'' 
								THEN A.QTY
							ELSE
								0
							END,0)) EX_RCVGDS_QTY		
						, MAX(CASE WHEN SUBSTR(B.WRK_ORDR_NO, 3, 2) = ''EX'' 
								THEN A.RCVGDS_DT
							ELSE
								''''
							END) AS EX_RCVGDS_DT
						FROM TB_IFSWM005 A
						INNER JOIN TB_SCH017 B
							ON A.ORDER_NO = B.ORDER_NO 
							AND B.OVBELN = ''' || V_OVBELN || '''
							AND B.OPOSNR = ' || V_OPOSNR || '
						WHERE A.DLFL = ''C''
							AND A.IF_STATUS = ''S''
					GROUP BY A.ORDER_NO	
				) IFSWM005 ON SCH017.ORDER_NO = IFSWM005.ORDER_NO
            WHERE   SCH017.OVBELN = ''' || V_OVBELN || '''
            AND     SCH017.OPOSNR = ' || V_OPOSNR || '
			AND     NVL(SCH017.MAN_CUT_YN, ''N'') != ''Y'' 
            GROUP BY 
                SCH017.MATNR, 
                M001.MATNR_NM, 
				CASE WHEN SCH017.MAN_CUT_YN = ''X'' THEN ''수재단''
                	ELSE ''재단'' 
                END,
                SCH017.COMP_YN,
                CASE 
                    WHEN SUBSTR(SCH017.WRK_ORDR_NO, 3, 2) = ''EX'' 
                    THEN ''예외'' 
                    ELSE ''일반'' 
                END

			UNION ALL

			-- 포장
			SELECT 
			    SCH018.MATNR, 
			    M001.MATNR_NM, 
			    ''포장'' AS PROC_NAME,
			    SCH018.COMP_YN AS PROC_STAT,
			    CASE 
			        WHEN SUBSTR(SCH018.WRK_ORDR_NO, 3, 2) = ''EX'' 
			        THEN ''예외'' 
			        ELSE ''일반'' 
			    END AS PROC_TYPE,
			    SUM(SCH018.WRK_ORDR_QTY) AS WRK_ORDR_QTY,
			    SUM(W002.PRFM_QTY) AS PRFM_QTY,
			    MAX(W002.PRFM_UNIT) AS PRFM_UNIT,
			    SUM(IFSWM005.RCVGDS_QTY) AS RCVGDS_QTY,
			    MAX(IFSWM005.RCVGDS_UNIT) AS RCVGDS_UNIT,
			    SUM(W002.EX_PRFM_QTY) AS EX_PRFM_QTY,
			    MAX(W002.EX_PRFM_UNIT) AS EX_PRFM_UNIT,
			    SUM(IFSWM005.EX_RCVGDS_QTY) AS EX_RCVGDS_QTY,
			    MAX(IFSWM005.EX_RCVGDS_UNIT) AS EX_RCVGDS_UNIT,
			    MAX(SCH018.PRD_REQ_DT) AS PRD_REQ_DT,
			    MAX(W002.PRFM_DT) AS PRFM_DT,
			    MAX(IFSWM005.RCVGDS_DT) AS RCVGDS_DT,
			    MAX(W002.EX_PRFM_DT) AS EX_PRFM_DT,
			    MAX(IFSWM005.EX_RCVGDS_DT) AS EX_RCVGDS_DT
			FROM TB_SCH018 SCH018 
			INNER JOIN TB_MAS001 M001 ON SCH018.WERKS = M001.WERKS AND SCH018.MATNR = M001.MATNR
			LEFT JOIN (
				SELECT MATNR
					, WRK_ORDR_NO
					, WRK_ORDR_SEQNO
					, SUM(NVL(CASE WHEN SUBSTR(WRK_ORDR_NO, 3, 2) != ''EX''
							THEN PRFM_QTY
						ELSE
							0
						END,0)) AS PRFM_QTY
					, MAX(CASE WHEN SUBSTR(WRK_ORDR_NO, 3, 2) != ''EX''
							THEN UNIT
						ELSE
							''''
						END) AS PRFM_UNIT	
					, SUM(NVL(CASE WHEN SUBSTR(WRK_ORDR_NO, 3, 2) = ''EX''
							THEN PRFM_QTY
						ELSE
							0
						END,0)) EX_PRFM_QTY		
					, MAX(CASE WHEN SUBSTR(WRK_ORDR_NO, 3, 2) = ''EX'' 
							THEN UNIT
						ELSE
							''''
						END) EX_PRFM_UNIT
					, MAX(CASE WHEN SUBSTR(WRK_ORDR_NO, 3, 2) != ''EX'' 
							THEN PRFM_DT
						ELSE
							''''
						END) AS PRFM_DT	
					, MAX(CASE WHEN SUBSTR(WRK_ORDR_NO, 3, 2) = ''EX'' 
							THEN PRFM_DT
						ELSE
							''''
						END) EX_PRFM_DT	
				FROM TB_WRK002
				WHERE (MATNR, WRK_ORDR_NO, WRK_ORDR_SEQNO) IN (
						SELECT MATNR, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_SCH018 WHERE OVBELN = ''' || V_OVBELN || ''' AND OPOSNR = ' || V_OPOSNR || '
					)
				    AND NVL(CNL_YN, ''N'') = ''N''
				    GROUP BY MATNR
						, WRK_ORDR_NO
						, WRK_ORDR_SEQNO
			) W002 ON SCH018.MATNR = W002.MATNR
			    AND SCH018.WRK_ORDR_NO = W002.WRK_ORDR_NO
				AND SCH018.WRK_ORDR_SEQNO = W002.WRK_ORDR_SEQNO 
			LEFT JOIN (
				SELECT A.ORDER_NO
					, SUM(NVL(CASE WHEN SUBSTR(B.WRK_ORDR_NO, 3, 2) != ''EX'' 
							THEN A.QTY
						ELSE
							0
						END,0)) AS RCVGDS_QTY
					, MAX(CASE WHEN SUBSTR(B.WRK_ORDR_NO, 3, 2) != ''EX'' 
							THEN A.UNIT
						ELSE
							''''
						END) AS RCVGDS_UNIT	
					, MAX(CASE WHEN SUBSTR(B.WRK_ORDR_NO, 3, 2) != ''EX'' 
							THEN A.RCVGDS_DT
						ELSE
							''''
						END) AS RCVGDS_DT	
					, SUM(NVL(CASE WHEN SUBSTR(B.WRK_ORDR_NO, 3, 2) = ''EX'' 
							THEN A.QTY
						ELSE
							0
						END,0)) EX_RCVGDS_QTY		
					, MAX(CASE WHEN SUBSTR(B.WRK_ORDR_NO, 3, 2) = ''EX'' 
							THEN A.UNIT
						ELSE
							''''
						END) EX_RCVGDS_UNIT
					, MAX(CASE WHEN SUBSTR(B.WRK_ORDR_NO, 3, 2) = ''EX'' 
							THEN A.RCVGDS_DT
						ELSE
							''''
						END) AS EX_RCVGDS_DT
					FROM TB_IFSWM005 A
					INNER JOIN TB_SCH018 B
						ON A.ORDER_NO = B.ORDER_NO 
						AND B.OVBELN = ''' || V_OVBELN || '''
						AND B.OPOSNR = ' || V_OPOSNR || '
					WHERE A.DLFL = ''C''
						AND A.IF_STATUS = ''S''
				GROUP BY A.ORDER_NO	
			) IFSWM005 ON SCH018.ORDER_NO = IFSWM005.ORDER_NO
			WHERE   SCH018.OVBELN = ''' || V_OVBELN || '''
			AND SCH018.OPOSNR = ' || V_OPOSNR || '
			GROUP BY
			    SCH018.MATNR, 
			    M001.MATNR_NM, 
			    SCH018.COMP_YN,
			    CASE 
			        WHEN SUBSTR(SCH018.WRK_ORDR_NO, 3, 2) = ''EX'' 
			        THEN ''예외'' 
			        ELSE ''일반'' 
			    END
			
			-- 입고실적
			UNION ALL
				
			SELECT 
			    WRK015.MATNR 
			    , M001.MATNR_NM
			    , ''입고처리'' AS PROC_NAME
				, ''Y'' AS PROC_STAT
			    , ''입고'' AS PROC_TYPE
				, 0 AS WRK_ORDR_QTY
			    , 0 AS PRFM_QTY
			    , '''' AS PRFM_UNIT
			    , SUM(WRK015.QTY) AS RCVGDS_QTY
			    , MAX(WRK015.UNIT) AS RCVGDS_UNIT
			    , 0 AS EX_PRFM_QTY
			    , '''' AS EX_PRFM_UNIT
			    , 0 AS EX_RCVGDS_QTY
			    , '''' AS EX_RCVGDS_UNIT
			    , '''' AS PRD_REQ_DT
			   	, '''' AS PRFM_DT
			    , MAX(WRK015.RCVGDS_DT) AS RCVGDS_DT
			    , '''' AS EX_PRFM_DT
			    , '''' AS EX_RCVGDS_DT
			FROM TB_WRK015 WRK015
			INNER JOIN TB_MAS001 M001 ON WRK015.WERKS = M001.WERKS AND WRK015.MATNR = M001.MATNR
		';		
	
		IF (V_018COMP_YN = 'Y') THEN
		
		V_SQL := V_SQL || '
			INNER JOIN (
				SELECT 
					WERKS
					, IND_BCD
					, LOT_NO
					, MATNR
					, MACHINE 
				FROM TB_WRK002 
				WHERE (MATNR, WRK_ORDR_NO, WRK_ORDR_SEQNO) IN (
						SELECT MATNR, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_SCH018 WHERE OVBELN = ''' || V_OVBELN || ''' AND OPOSNR = ' || V_OPOSNR || '
					)
			) WRK002 ON  WRK015.WERKS = WRK002.WERKS
				AND WRK015.IND_BCD = WRK002.IND_BCD
				AND WRK015.LOT_NO = WRK002.LOT_NO
				AND WRK015.MATNR = WRK002.MATNR
				AND WRK015.MACHINE = WRK002.MACHINE
		';
	
		ELSE
		
		V_SQL := V_SQL || '
			INNER JOIN (
				SELECT 
					WERKS
					, IND_BCD
					, LOT_NO
					, MATNR
					, MACHINE 
				FROM TB_WRK002 
				WHERE (MATNR, WRK_ORDR_NO, WRK_ORDR_SEQNO) IN (
						SELECT MATNR, WRK_ORDR_NO, WRK_ORDR_SEQNO FROM TB_SCH016 WHERE OVBELN = ''' || V_OVBELN || ''' AND OPOSNR = ' || V_OPOSNR || '
					)
			) WRK002 ON  WRK015.WERKS = WRK002.WERKS
				AND WRK015.IND_BCD = WRK002.IND_BCD
				AND WRK015.LOT_NO = WRK002.LOT_NO
				AND WRK015.MATNR = WRK002.MATNR
				AND WRK015.MACHINE = WRK002.MACHINE
		';
		
		END IF;

		V_SQL := V_SQL || '
			WHERE WRK015.REQ_STA = ''O''
			GROUP BY 
				WRK015.MATNR
				, M001.MATNR_NM
        ';
        DBMS_OUTPUT.PUT_LINE('## (전체공정) V_SQL = ' || V_SQL);
        OPEN P_RS_LIST FOR V_SQL;

        P_MSG := '조회가 완료되었습니다.';
        P_SUCCESS := 'Y';
        P_CODE := 'S';

        COMMIT;

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES ('(DETAIL) ' || V_SQL);
        END IF;

    END IF;

EXCEPTION
    WHEN OTHERS THEN
        -- 에러 발생시 롤백하고 에러 메시지 표시
        P_SUCCESS       := 'N';
       	P_MSG			:= SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002, 'An error occurred: ' || SQLERRM);
END;
/
