
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK05_S01_BACKUP_20240709" SP_WRK05_S01_BACKUP_20240709
(
    P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
    P_ERR_MSG       OUT    VARCHAR2,
    P_DOC_NO1       OUT    varchar2,        --SAP 실적 전송 문서
    P_DOC_NO2       OUT    varchar2,        --SAP 예외실적 전송 문서
	P_RS_LIST       OUT    SYS_REFCURSOR
)
AS 
/*==============================================================================
 * PROGRAM ID    : WRK05{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 완제품 입고요청{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : WMS로 완제품 입고요청{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 유상호{최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/13 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/13    1.0.0   유상호         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_MAS001] : (.R..) 자재 마스터                                
 *       - [TB_MAS015] : (CRUD) 검사항목별 기준정보 등록 마스트                              
 *       - [TB_MAS016] : (CRUD) 검사항목별 기준값 정보                                
 *=============================================================================*/
    --프로그램 ID
    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK05_S01';     -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_OBJECT_T;
    V_OBJ            JSON_OBJECT_T;
    V_OBJ2           JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS             TB_INV001.WERKS%TYPE;        -- 플랜트코드
    V_MACH_CD           TB_INV001.MACH_CD%TYPE;      -- 설비코드
    V_MATNR             TB_INV001.MATNR%TYPE;        -- 자재코드
    V_CHK_PP_YN         TB_WRK001.CHK_PP_YN%TYPE;        -- 생산확인여부
    V_CHK_QC_YN         TB_WRK001.CHK_QC_YN%TYPE;        -- 품질확인여부
    V_DOC_NO            VARCHAR2(4000);
    V_DOC_PRFM          VARCHAR2(30); --SAP 실적전송 문서 
    V_DOC_SEQNO           NUMBER;
    V_IND_BCD           TB_INV001.IND_BCD%TYPE;      -- 업체/개별바코드
    V_PROC_CD           TB_MAS012.PROC_CD%TYPE;      -- 공정코드
    V_WRK_CD            TB_MAS012.WRK_CD%TYPE;        -- 작업장코드
    V_WRK_ORDR_NO       TB_WRK011.WRK_ORDR_NO%TYPE;  -- 작업지시번호
    V_WRK_ORDR_SEQNO    TB_WRK011.WRK_ORDR_SEQNO%TYPE;  -- 작업지시번호 순번
    V_ORDER_NO          TB_WRK011.ORDER_NO%TYPE; 

    V_QTY               TB_WRK001.WGT%TYPE;     
    V_UNIT              TB_WRK001.UNIT%TYPE; 
    V_STOR_LOC_FR       VARCHAR2(20); 
    V_STOR_LOC_TO       VARCHAR2(20); 
    V_PLT_QTY           TB_WRK001.PLT_QTY%TYPE;       
    V_BOX_QTY           TB_WRK001.BOX_QTY%TYPE;     
    V_BAG_QTY           TB_WRK001.BAG_QTY%TYPE;     
    V_EA_QTY            TB_WRK001.EA_QTY%TYPE;     
    V_WGT               TB_WRK001.WGT%TYPE;     
    V_LOT_NO            TB_WRK001.LOT_NO%TYPE;     
    V_MACH_NM           VARCHAR2(50);
    V_ORDER_SEQNO	    VARCHAR2(10);
    V_PRD_DT            TB_WRK001.PRD_DT%TYPE;              --생산일자
    V_RCVGDS_DT         VARCHAR2(10);                       --입고일자
    V_PRFM_DT           TB_WRK001.PRFM_DT%TYPE;             --실적일자
    V_DSTBT_DDLIN       VARCHAR2(10);                       --유통기간
    V_REQ_STA           VARCHAR2(10);                       --요청상태
    V_DATE              DATE := SYSDATE;
    --V_MACHINE           VARCHAR2(5);

    V_PRFM_STR_DTM VARCHAR(20); --실적 시작일자
    V_PRFM_END_DTM VARCHAR(20); --실적 완료일자
    V_PRFM_STR_DATE DATE; --실적 시작일자
    V_PRFM_END_DATE DATE; --실적 완료일자
    V_RUNTIME NUMBER; --가동시간
    V_ABNTIME NUMBER; --비가동시간
    V_WRK_CLASS     VARCHAR2(10); --작업조
    V_WRK_COMP_YN   VARCHAR2(1); --완료실적 여부
    V_ORDR_COMP_YN  VARCHAR2(1);
    V_SAP_COMP_YN   VARCHAR2(1);
    V_SAP_WRK_CD    VARCHAR2(20); --SAP 작업장 코드

    V_DOC_NO_1          TB_WRK001.DOC_NO%TYPE;
    V_DOC_NO_2          TB_WRK001.DOC_NO%TYPE;
    V_DOC_SEQNO_1       TB_WRK001.DOC_SEQNO%TYPE;
    V_DOC_SEQNO_2       TB_WRK001.DOC_SEQNO%TYPE;
    V_ABN_TM            TB_WRK003.ABN_TM%TYPE;
    V_LOT_NO_M          TB_WRK001.LOT_NO%TYPE; 
    V_MATNR_M           TB_WRK001.MATNR%TYPE; 
    V_SDOC_NO           TB_WRK001.SDOC_NO%TYPE;
    V_USE_QTY           TB_INV010.USE_QTY%TYPE;    
    V_IND_BCD_M         TB_INV010.IND_BCD_M%TYPE;
    V_ORDER_ITM_NO      VARCHAR2(10);
    V_STOR_LOC_CD_M     VARCHAR2(10);
    V_PROC_DIV          VARCHAR2(10);

    V_MACHINE           TB_MAS012.MACHINE%TYPE;
    PROD_CUR            SYS_REFCURSOR;		-- 커서 정의
BEGIN
    OPEN P_RS_LIST FOR 
    SELECT NULL FROM DUAL WHERE ROWNUM = 0;

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);
    V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=       V_JSON.get_string('SES_WAREKY');

    /* 조건값 할당 */
    V_RANGE_SQL          :=       V_JSON.get_string('RANGE_SQL');                   -- 작업지시 조회 시 일자
    V_WERKS              :=       V_JSON.get_string('WERKS');                       -- 플랜트코드
    --V_MACH_CD            :=       V_JSON.get_string('MACH_CD');                     -- 설비코드
    V_MACHINE            :=       V_JSON.get_string('MACHINE');                     -- 설비코드
    V_MATNR              :=       V_JSON.get_string('MATNR');                       -- 자재코드
    V_CHK_PP_YN          :=       V_JSON.get_string('CHK_PP_YN');                   -- 생산확인여부(Y/N)
    V_CHK_QC_YN          :=       V_JSON.get_string('CHK_QC_YN');                   -- 품질확인여부(Y/N)
    V_PROC_DIV          :=      V_JSON.get_string('PROC_DIV');                      --공정구분

    IF P_TYPE = 'LIST' THEN /*업체/개별바코드 조회 리스트*/

        IF V_WERKS = 'P200' THEN
            V_SQL := 'SELECT W001.WERKS,
                             W001.MACH_CD,
                             M012.MACHINE,
                             M012.MACH_NM,
                             W001.PRD_DT,                         --생산일자
                             W001.PRFM_DT,                        --실적일자
                             W001.MATNR,                          --자재코드
                             M001.MATNR_NM,                        --자재명
                             W001.IND_BCD,                        --개별바코드
                             W001.LOT_NO,                        --LOT NO
                             W001.UNIT,                            --단위  
                             W001.PLT_QTY,
                             W001.BOX_QTY,
                             W001.BAG_QTY,
                             W001.EA_QTY,
                             W001.WGT,                          --중량
                             W001.ROLLCNT,                      --권치수
							 CASE WHEN (SUBSTR(W001.MATNR, -1) = ''W'' OR SUBSTR(W001.MATNR, -1) = ''M'') THEN ''Y''
								  ELSE NVL(W001.CHK_PP_YN, ''N'')  END AS CHK_PP_YN,                      --생산확인여부
--                             NVL(W001.CHK_PP_YN, ''N'')  AS CHK_PP_YN,                      --생산확인여부
                             NVL(W001.CHK_QC_YN, ''N'')  AS CHK_QC_YN,                       --품질확인여부
                             CASE WHEN NVL(W001.SDOC_NO, '' '') <> '' '' AND NVL(W001.SDOC_NO, '' '') <> ''E'' THEN ''전송완료''
                                  WHEN NVL(W001.SDOC_NO, '' '') = ''E'' THEN ''전송오류''
                                  WHEN NVL(W001.SDOC_NO, '' '') = '' ''  THEN ''미전송'' END                   AS SAP_YN,

                             CASE WHEN NVL(I001.WDOC_NO, '' '') <> '' '' AND NVL(I001.WDOC_NO, '' '') <> ''E'' THEN ''전송완료''
                                  WHEN NVL(I001.WDOC_NO, '' '') = ''E'' THEN ''전송오류''
                                  WHEN NVL(I001.WDOC_NO, '' '') = '' '' AND I001.STCK_STA = ''80'' THEN ''요청'' 
                                  WHEN NVL(I001.WDOC_NO, '' '') = '' '' AND I001.STCK_STA = ''00'' THEN ''미전송'' END AS WMS_YN 
--                                  ELSE ''미전송'' END AS WMS_YN
                        FROM TB_WRK001 W001,
                             TB_MAS001 M001,
                             TB_MAS012 M012,
                             TB_INV001 I001
                     WHERE W001.WERKS = M001.WERKS(+) 
                       AND W001.MATNR = M001.MATNR(+)
                       AND W001.MACH_CD = M012.MACH_CD
                       AND W001.WERKS = I001.WERKS
                       AND W001.IND_BCD = I001.IND_BCD
                       AND W001.WERKS = ''' || V_WERKS ||''' ';
        ELSE
            V_SQL := 'SELECT W001.WERKS,
                             W001.MACH_CD,
                             M012.MACHINE,
                             M012.MACH_NM,
                             W001.PRD_DT,                         --생산일자
                             W001.PRFM_DT,                        --실적일자
                             W001.MATNR,                          --자재코드
                             M001.MATNR_NM,                        --자재명
                             W001.IND_BCD,                        --개별바코드
                             W001.LOT_NO,                        --LOT NO
                             W001.UNIT,                            --단위  
                             W001.PLT_QTY,
                             W001.BOX_QTY,
                             W001.BAG_QTY,
                             W001.EA_QTY,
                             NVL(W001.CHK_PP_YN, ''N'')  AS CHK_PP_YN,                      --생산확인여부
                             NVL(W001.CHK_QC_YN, ''N'')  AS CHK_QC_YN,                       --품질확인여부
                             CASE WHEN NVL(W001.SDOC_NO, '' '') <> '' '' AND NVL(W001.SDOC_NO, '' '') <> ''E'' THEN ''전송완료''
                                  WHEN NVL(W001.SDOC_NO, '' '') = ''E'' THEN ''전송오류''
                                  WHEN NVL(W001.SDOC_NO, '' '') = '' ''  THEN ''미전송'' END                   AS SAP_YN,
                             CASE WHEN NVL(I001.WDOC_NO, '' '') <> '' '' AND NVL(I001.WDOC_NO, '' '') <> ''E'' THEN ''전송완료''
                                  WHEN NVL(I001.WDOC_NO, '' '') = ''E'' THEN ''전송오류''
                                  WHEN NVL(I001.WDOC_NO, '' '') = '' '' AND I001.STCK_STA = ''80'' THEN ''요청'' 
                                  ELSE ''미전송'' END AS WMS_YN
                    FROM TB_WRK001 W001,
                             TB_MAS001 M001,
                             TB_MAS012 M012,
                             TB_INV001 I001
                     WHERE W001.WERKS = M001.WERKS(+) 
                       AND W001.MATNR = M001.MATNR(+)
                       AND W001.MACH_CD = M012.MACH_CD
                       AND W001.WERKS = I001.WERKS
                       AND W001.IND_BCD = I001.IND_BCD
                       AND W001.WERKS = ''' || V_WERKS ||''' ';
        END IF;

        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN 
        	V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MATNR', 'W001.MATNR');	--자재코드
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;            

--        IF  V_MACH_CD IS NOT NULL OR TRIM(V_MACH_CD) != '' THEN         -- 설비코드
--            V_SQL := V_SQL || ' AND W001.MACH_CD = ''' || V_MACH_CD || '''';
--        END IF;

        IF  V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '' THEN         -- 생산호기
            IF V_WERKS = 'P200' THEN
                IF V_PROC_DIV = 'AA' THEN
                    V_SQL := V_SQL || ' AND W001.MACH_CD = ''TAA' || LPAD(SUBSTR(V_MACHINE, -1), 2, '00') || '''';
                ELSIF V_PROC_DIV = 'RA' THEN
                    V_SQL := V_SQL || ' AND W001.MACH_CD = ''TRA' || LPAD(SUBSTR(V_MACHINE, -1), 2, '00') || '''';
                ELSE
                    V_SQL := V_SQL || ' AND M012.MACHINE = ''' || V_MACHINE || '''';
                END IF;
            ELSE
                V_SQL := V_SQL || ' AND M012.MACHINE = ''' || V_MACHINE || '''';
            END IF;
        END IF;

        IF  V_CHK_PP_YN IS NOT NULL OR TRIM(V_CHK_PP_YN) != '' THEN -- 생산확인여부
            V_SQL := V_SQL || ' AND DECODE(NVL(W001.CHK_PP_YN,''N''),''N'',''N'',''Y'') = ''' || V_CHK_PP_YN || '''';
        END IF;

        IF  V_CHK_QC_YN IS NOT NULL OR TRIM(V_CHK_QC_YN) != '' THEN -- 품질확인여부
            V_SQL := V_SQL || ' AND DECODE(NVL(W001.CHK_QC_YN,''N''),''N'',''N'',''Y'') = ''' || V_CHK_QC_YN || '''';
        END IF;       

--       V_SQL := V_SQL || ' ORDER BY W001.MACH_CD, W001.REGDATE ';
        IF V_WERKS = 'P200' THEN
            IF V_PROC_DIV = 'AA' THEN
                V_SQL := V_SQL || ' AND (SUBSTR(W001.MATNR, -1) = ''W'' OR SUBSTR(W001.MATNR, -1) = ''M'') ';
            ELSE
                V_SQL := V_SQL || ' AND I001.STOR_LOC_CD = ''3100'' ';
            END IF;
        ELSE 
            V_SQL := V_SQL || ' AND I001.STOR_LOC_CD = ''3100'' ';
        END IF;
       V_SQL := V_SQL || ' AND NVL(W001.CNL_YN, ''N'') = ''N''
                           AND I001.STCK_STA IN (''00'', ''80'')   
						   AND I001.STCK_QTY > 0                        
                           ORDER BY W001.MACH_CD, W001.REGDATE ';

       INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);     
        BEGIN           
     		OPEN P_RS_LIST FOR V_SQL;

        EXCEPTION           
        WHEN OTHERS THEN 
            P_SUCCESS           := 'N';
            E_SQL_ERR_CD        := SQLCODE;
            E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
            RETURN;           
        END;   

    ELSIF P_TYPE = 'SUB_LIST1' THEN  /* */
       RETURN;

    ELSIF P_TYPE = 'SUB_LIST2' THEN  /* */
        RETURN;           

    ELSIF P_TYPE = 'SAVE' THEN  /* 입고요청*/

        --SAP 실적 전송 문서번호
        V_DOC_SEQNO_1 := 0;
        V_DOC_SEQNO_2 := 1;
--        --SAP 투입자재 전송 문서번호
--        V_DOC_NO_2 := FN_GET_MDOCNO('M','IF130');
--        V_DOC_SEQNO_2 := 0;

        V_ARR_LIST        := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ           := TREAT (V_OBJ.get ('map') AS json_object_t);

            V_WERKS         := V_OBJ.get_string('WERKS');
            V_MACH_CD       := V_OBJ.get_string('MACH_CD');
            V_MACH_NM       := V_OBJ.get_string('MACH_NM');
            V_IND_BCD       := V_OBJ.get_string('IND_BCD');
            V_LOT_NO        := V_OBJ.get_string('LOT_NO');      --추가
            V_MATNR         := V_OBJ.get_string('MATNR');
            V_CHK_PP_YN     := V_OBJ.get_string('CHK_PP_YN');
            V_CHK_QC_YN     := V_OBJ.get_string('CHK_QC_YN');

--            IF NVL(V_CHK_PP_YN, 'N') = 'Y' THEN
--                P_SUCCESS := 'Y';
--                ROLLBACK;
--                RETURN;
--            END IF;

            IF V_WERKS = 'P300' AND  SUBSTR(V_MACH_CD,1,3) = 'SPF' THEN     --생리대 예외생산
                V_DOC_NO_2 := FN_GET_MDOCNO('M','IF139');

                IF NVL(V_DOC_NO, ' ') = ' ' THEN
                    V_DOC_NO := V_DOC_NO_2;
                ELSE
                    V_DOC_NO := V_DOC_NO || ',' || V_DOC_NO_2;
                END IF;

--            IF V_WERKS = 'P300' OR V_WERKS = 'P500' OR (V_WERKS = 'P200' AND (SUBSTR(V_MACH_CD, 2,2) = 'PG' OR SUBSTR(V_MACH_CD, 2,2) = 'RA')) THEN
--                IF NVL(V_DOC_NO_1, ' ') = ' ' THEN
--                    IF SUBSTR(V_MACH_CD,1,3) = 'SRB' OR SUBSTR(V_MACH_CD,1,3) = 'BRC'  THEN     --생리대/기저귀 가공기 실적
--                        V_DOC_NO_1 := FN_GET_MDOCNO('M','IF133');
--                        V_DOC_SEQNO_1 := V_DOC_SEQNO_1 + 1;
----                    ELSIF SUBSTR(V_MACH_CD,1,3) = 'TRA'  THEN                                   --화장지실적
----                        V_DOC_NO_1 := FN_GET_MDOCNO('M','IF133');
--                    ELSIF SUBSTR(V_MACH_CD,1,3) = 'SPE' OR SUBSTR(V_MACH_CD,1,3) = 'BPI' OR SUBSTR(V_MACH_CD,1,3) = 'TPG'  THEN     --생리대/기저귀/화장지 예외생산 실적
--                        V_DOC_NO_2 := FN_GET_MDOCNO('M','IF139');
--                        V_DOC_SEQNO_2 := V_DOC_SEQNO_2 + 1;
--                    END IF;
--                ELSE
--                    IF SUBSTR(V_MACH_CD,1,3) = 'SRB' OR SUBSTR(V_MACH_CD,1,3) = 'BRC'  THEN     --생리대/기저귀 가공기 실적
--                        V_DOC_SEQNO_1 := V_DOC_SEQNO_1 + 1;    
--                    ELSIF SUBSTR(V_MACH_CD,1,3) = 'SPE' OR SUBSTR(V_MACH_CD,1,3) = 'BPI' OR SUBSTR(V_MACH_CD,1,3) = 'TPG'  THEN     --생리대/기저귀/화장지 예외생산 실적
--                        V_DOC_SEQNO_2 := V_DOC_SEQNO_2 + 1;
--                    END IF;
--                END IF;

                SELECT  CASE WHEN W001.UNIT = 'PLT' THEN PLT_QTY
                            WHEN W001.UNIT = 'BOX' THEN BOX_QTY
                            WHEN W001.UNIT = 'BAG' THEN BAG_QTY
                            WHEN W001.UNIT = 'EA' THEN EA_QTY END QTY, 
                        W001.UNIT , W001.WGT,		
                        W001.IND_BCD, W001.LOT_NO, W001.ORDER_NO, W001.ORDER_SEQNO,		
                        W001.WRK_ORDR_NO, W001.WRK_ORDR_SEQNO, 
                        W001.COMP_YN, W001.PRD_STR_DATE, W001.PRD_END_DATE,
                        W001.PRD_DT, W001.PRFM_DT, W001.DSTBT_DDLIN, W001.WRK_CLASS, 
                        M012.SAP_WRK_CD, M012.MACHINE, W001.SDOC_NO
                        INTO
                        V_QTY, 
                        V_UNIT, V_WGT, V_IND_BCD, V_LOT_NO, V_ORDER_NO, V_ORDER_SEQNO,		
                        V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, 
                        V_WRK_COMP_YN, V_PRFM_STR_DATE, V_PRFM_END_DATE,
                        V_PRD_DT, V_PRFM_DT, V_DSTBT_DDLIN, V_WRK_CLASS,
                        V_SAP_WRK_CD, V_MACHINE, V_SDOC_NO
                  FROM TB_WRK001 W001,
                       TB_MAS012 M012
                 WHERE W001.MACH_CD = M012.MACH_CD(+)
                   AND W001.WERKS = V_WERKS
                   AND W001.MACH_CD = V_MACH_CD
                   AND W001.IND_BCD = V_IND_BCD;   

                IF NVL(V_SDOC_NO, 'E') != 'E' THEN
                    P_SUCCESS := 'N';
                    P_ERR_MSG := 'SAP에 이미 실적을 전송했습니다.';
                    ROLLBACK;
                    RETURN;
                END IF;

                --지시정보 조회
                IF V_WERKS = 'P300' THEN --생리대
                    IF SUBSTR(V_MACH_CD,1,3) = 'SRB' THEN
                        SELECT PRD_STR_DTM, PRD_END_DTM, COMP_YN
                          INTO V_PRFM_STR_DTM, V_PRFM_END_DTM, V_ORDR_COMP_YN
                          FROM TB_SCH013
                         WHERE 1=1
                           AND WERKS = V_WERKS
                           AND WRK_ORDR_NO = V_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
                    ELSE
                        SELECT PRD_STR_DTM, PRD_END_DTM, COMP_YN
                          INTO V_PRFM_STR_DTM, V_PRFM_END_DTM, V_ORDR_COMP_YN
                          FROM TB_SCH019
                         WHERE 1=1
                           AND WERKS = V_WERKS
                           AND WRK_ORDR_NO = V_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
                    END IF;
                ELSIF V_WERKS = 'P500' THEN --기저귀
                    IF SUBSTR(V_MACH_CD,1,3) = 'BRC' THEN
                        SELECT PRD_STR_DTM, PRD_END_DTM, COMP_YN
                          INTO V_PRFM_STR_DTM, V_PRFM_END_DTM, V_ORDR_COMP_YN
                          FROM TB_SCH014
                         WHERE 1=1
                           AND WERKS = V_WERKS
                           AND WRK_ORDR_NO = V_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
                    ELSE
                        SELECT PRD_STR_DTM, PRD_END_DTM, COMP_YN
                          INTO V_PRFM_STR_DTM, V_PRFM_END_DTM, V_ORDR_COMP_YN
                          FROM TB_SCH019
                         WHERE 1=1
                           AND WERKS = V_WERKS
                           AND WRK_ORDR_NO = V_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
                    END IF;       
                ELSIF V_WERKS = 'P200' THEN --화장지
                    SELECT PRD_STR_DTM, PRD_END_DTM, COMP_YN
                      INTO V_PRFM_STR_DTM, V_PRFM_END_DTM, V_ORDR_COMP_YN
                      FROM TB_SCH019
                     WHERE 1=1
                       AND WERKS = V_WERKS
                       AND WRK_ORDR_NO = V_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
                END IF;

                V_SAP_COMP_YN := '';
                IF NVL(V_WRK_COMP_YN, 'N') = 'Y' AND NVL(V_ORDR_COMP_YN, 'N') = 'Y' THEN
                    V_SAP_COMP_YN := 'X';
                END IF;

                --가동시간
                V_RUNTIME := V_PRFM_END_DATE - V_PRFM_STR_DATE;
                --분단위로 변환
                V_RUNTIME := CEIL(V_RUNTIME * 24 * 60);
                V_RUNTIME := CASE WHEN V_RUNTIME = 0 THEN 1 ELSE V_RUNTIME END;

                --비가동시간 조회
                BEGIN
                SELECT SUM(ABN_TM)  INTO V_ABN_TM
                  FROM TB_WRK003
                 WHERE WERKS = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND IN_OUT <> 'O'
                   AND STR_DATE >= V_PRFM_END_DATE
                   AND END_DATE <= V_PRFM_STR_DATE
                GROUP BY WERKS, MACH_CD;   
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_ABN_TM := 0;
                END;
                V_RUNTIME := V_RUNTIME - V_ABN_TM;

                --인터페이스 전송
                IF SUBSTR(V_MACH_CD,1,3) = 'SRB' OR SUBSTR(V_MACH_CD,1,3) = 'BRC'  THEN     --T생리대/기저귀 가공기 실적
                    INSERT INTO TB_IFS011(AUFNR, LOTNO, MATNR, WERKS, WORKCENTERCODE, MACHINE, 
                                          WORKGROUP, OPNAM, BUDAT, PROQTY, MEINS, RUNTIME,
                                          CONF, SDATE, STIME, EDATE, ETIME, 
                                          MDOCNO, MDOCSEQ, ZRESULT, MAKE_DATE, MAKER)
                               VALUES(V_ORDER_NO, V_LOT_NO, V_MATNR, V_WERKS, V_SAP_WRK_CD, V_MACHINE, 
                                        V_WRK_CLASS, V_SESS_USER_ID, FN_DT_FORMAT(V_PRFM_DT,'YYYY-MM-DD'), V_QTY, V_UNIT, V_RUNTIME, 
                                        V_SAP_COMP_YN, TO_CHAR(V_PRFM_STR_DATE,'YYYY-MM-DD'), TO_CHAR(V_PRFM_STR_DATE,'HH24:MI:SS'), 
                                        TO_CHAR(V_PRFM_END_DATE,'YYYY-MM-DD'), TO_CHAR(V_PRFM_END_DATE,'HH24:MI:SS'),
                                        V_DOC_NO_1, TO_CHAR(V_DOC_SEQNO_1), 'N', V_DATE, V_SESS_USER_ID);

                ELSIF SUBSTR(V_MACH_CD,1,3) = 'SPF' OR SUBSTR(V_MACH_CD,1,3) = 'BPI' OR SUBSTR(V_MACH_CD,1,3) = 'TPG'  THEN     --생리대/기저귀/화장지 예외생산 실적
                    INSERT INTO TB_IFS019(AUFNR, LOTNO, WERKS, BUDAT, MATNR, 
                                        PROQTY, MEINS, RUNTIME, OPNAM, SDATE, STIME, EDATE, ETIME, 
                                        CONF, MDOCNO, MDOCSEQ, ZRESULT, MAKE_DATE, MAKER)
                                VALUES(V_ORDER_NO, V_LOT_NO, V_WERKS, TO_CHAR(V_DATE,'YYYYMMDD'), V_MATNR, 
                                        V_QTY, V_UNIT, V_RUNTIME, V_SESS_USER_ID,
                                        TO_CHAR(V_PRFM_STR_DATE,'YYYYMMDD'), TO_CHAR(V_PRFM_STR_DATE,'HH24MISS'), 
                                        TO_CHAR(V_PRFM_END_DATE,'YYYYMMDD'), TO_CHAR(V_PRFM_END_DATE,'HH24MISS'),
                                        V_SAP_COMP_YN, V_DOC_NO_2, TO_CHAR(V_DOC_SEQNO_2), 'N', V_DATE, V_SESS_USER_ID);  
                END IF;

                --문서이력 
                INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                                      WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                      IND_BCD, LOT_NO, ORDER_NO, CNL_YN,
                                      REGDATE, REGID)
                           VALUES(V_DOC_NO_2, V_DOC_SEQNO_2, 1,
                                    V_WERKS, V_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                    V_IND_BCD, V_LOT_NO, V_ORDER_NO, 'N',
                                    V_DATE, V_SESS_USER_ID);  
               UPDATE TB_WRK001
                  SET DOC_NO = V_DOC_NO_2,
                      DOC_SEQNO = V_DOC_SEQNO_2,
                      CHK_PP_YN = V_CHK_PP_YN,
                      --CHK_QC_YN = 'Y',
                      --CHK_QC_DATE = V_DATE,
                      --CHK_QC_ID = V_SESS_USER_ID,
                      UPDDATE = V_DATE,
                      UPDID = V_SESS_USER_ID
                WHERE WERKS = V_WERKS
                  AND MACH_CD = V_MACH_CD
                  AND IND_BCD = V_IND_BCD;

               --재고테이블 IF문서번호 업데이트                                
               UPDATE TB_INV001
                  SET DOC_NO = V_DOC_NO_2,
                      DOC_SEQNO = V_DOC_SEQNO_2,
                      CHK_PP_YN = V_CHK_PP_YN,
                      UPDDATE = SYSDATE,
                      UPDID = V_SESS_USER_ID
                WHERE WERKS = V_WERKS
                  AND STOR_LOC_CD = '3100'
                  AND IND_BCD = V_IND_BCD; 
           ELSE
               UPDATE TB_WRK001
                  SET CHK_PP_YN = 'Y',
                      CHK_PP_DATE = V_DATE,
                      CHK_PP_ID = V_SESS_USER_ID,
                      UPDDATE = V_DATE,
                      UPDID = V_SESS_USER_ID
                WHERE WERKS = V_WERKS
                  AND MACH_CD = V_MACH_CD
                  AND IND_BCD = V_IND_BCD;

               --재고테이블 IF문서번호 업데이트                                
               UPDATE TB_INV001
                  SET CHK_PP_YN = V_CHK_PP_YN,
                      CHK_QC_YN = V_CHK_QC_YN,
                      UPDDATE = SYSDATE,
                      UPDID = V_SESS_USER_ID
                WHERE WERKS = V_WERKS
                  AND STOR_LOC_CD = '2000'
                  AND IND_BCD = V_IND_BCD;     
           END IF;

--           --투입자재 이력 조회    
--            OPEN PROD_CUR FOR
--                SELECT IND_BCD_M, LOT_NO_M, MATNR_M, USE_QTY, UNIT
--                 FROM TB_INV010
--                WHERE WERKS = V_WERKS
--                  AND MACH_CD = V_MACH_CD
--                  AND IND_BCD = V_IND_BCD;
--            LOOP
--            FETCH PROD_CUR INTO V_IND_BCD_M, V_LOT_NO_M, V_MATNR_M, V_USE_QTY, V_UNIT;
--            
--            EXIT WHEN PROD_CUR %NOTFOUND;    
--                V_DOC_SEQNO_2 := V_DOC_SEQNO_2 + 1;
--                
--                BEGIN                    
--                    SELECT ORDER_ITM_NO INTO V_ORDER_ITM_NO
--                      FROM TB_SCH020
--                     WHERE WERKS = V_WERKS
--                       AND WRK_ORDR_NO = V_WRK_ORDR_NO
--                       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
--                       AND MATNR = V_MATNR_M;
--                EXCEPTION WHEN NO_DATA_FOUND THEN
--                    --RS_CODE := 'E';
--                    --RS_MSG  := 'BOM 정보가 없습니다.';
--                   --RETURN; 
--                    V_ORDER_ITM_NO := '';
--                END;
--                
--                BEGIN
--                    SELECT STOR_LOC_CD INTO V_STOR_LOC_CD_M
--                      FROM TB_INV001
--                     WHERE WERKS = V_WERKS
--                       AND IND_BCD = V_IND_BCD_M;
--                EXCEPTION 
--                WHEN NO_DATA_FOUND THEN
--                    V_STOR_LOC_CD_M := '';
--                END;
--            
--                --투입자재 실적 전송
--                INSERT INTO TB_IFS008(AUFNR, POSNR, BUDAT, MATNR, MENGE, LGORT, CHARG,
--                                        MDOCNO, MDOCSEQ, MAKE_DATE, MAKER, WORKCENTERCODE, WERKS)
--                                VALUES( V_ORDER_NO, V_ORDER_ITM_NO, V_PRFM_DT, V_MATNR_M, V_USE_QTY, V_STOR_LOC_CD_M, V_LOT_NO_M,
--                                        V_DOC_NO_2, V_DOC_SEQNO_2, V_DATE, V_SESS_USER_ID, V_SAP_WRK_CD, V_WERKS);
--                
--                --문서이력
--                INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD,
--                                    WRK_ORDR_NO, WRK_ORDR_SEQNO, IND_BCD, LOT_NO, ORDER_NO,
--                                    CNL_YN, REGDATE, REGID)
--                            VALUES(V_DOC_NO_2, V_DOC_SEQNO_2, 3, V_WERKS, V_MACH_CD,
--                                    V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_IND_BCD, V_LOT_NO, V_ORDER_NO,
--                                    'N', V_DATE, V_SESS_USER_ID);                         
--            END LOOP;
--            CLOSE PROD_CUR; 

        END LOOP;

    ELSIF P_TYPE = 'DELETE' THEN  /* 입고요청취소*/
--        V_ARR_LIST        := V_JSON.get_array('list');
--    
--        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
--            V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
--            V_OBJ           := TREAT (V_OBJ.get ('map') AS json_object_t);
--
--            V_WERKS         := V_OBJ.get_string('WERKS');
--            V_MACH_CD       := V_OBJ.get_string('MACH_CD');
--            V_MACH_NM       := V_OBJ.get_string('MACH_NM');
--            V_IND_BCD       := V_OBJ.get_string('IND_BCD');
--            V_MATNR         := V_OBJ.get_string('MATNR');
--            V_CHK_PP_YN     := V_OBJ.get_string('CHK_PP_YN');
--            V_CHK_QC_YN     := V_OBJ.get_string('CHK_QC_YN');
--            
--            SELECT I001.DOC_NO, 
--                   I001.DOC_SEQNO
--                   INTO
--                   V_DOC_NO,
--                   V_DOC_SEQNO
--              FROM TB_INV001 I001
--             WHERE I001.WERKS = V_WERKS
--               --AND I001.MACH_CD = V_MACH_CD
--               AND I001.IND_BCD = V_IND_BCD;
--               
--            UPDATE TB_WRK015
--               SET DLFL = 'Y',
--                   UPDDATE = V_DATE,
--                   UPDID = V_SESS_USER_ID
--             WHERE WERKS = V_WERKS
--               --AND MACH_CD = V_MACH_CD
--               AND IND_BCD = V_IND_BCD; 
--               
--            INSERT INTO TB_IFSWM005( DOC_NO, DOC_SEQNO, DLFL,
--                                     WERKS, MATNR, QTY, UNIT, STOR_LOC_FROM, STOR_LOC_TO, IND_BCD,
--                                     LOT_NO, MACHINE, ORDER_NO, ORDER_SEQNO, PRDC_DT, RCVGDS_DT, DSTBT_DDLIN,
--                                     IF_GET_DATE)
--            SELECT DOC_NO, DOC_SEQNO, 'D',
--                   WERKS, MATNR, QTY, UNIT, STOR_LOC_FROM, STOR_LOC_TO, IND_BCD,
--                   LOT_NO, MACHINE, ORDER_NO, ORDER_SEQNO, PRDC_DT, RCVGDS_DT, DSTBT_DDLIN,
--                   V_DATE
--              FROM TB_IFSWM005
--             WHERE DOC_NO = V_DOC_NO
--               AND DOC_SEQNO = V_DOC_SEQNO
--               AND DLFL = 'N';
--               
--            UPDATE TB_INV001
--               SET DOC_NO = '',
--                   DOC_SEQNO = 0,
--                   CHK_PP_YN = DECODE(V_WERKS, 'P200', '', V_CHK_PP_YN),
--                   CHK_QC_YN = '',
--                   UPDDATE = SYSDATE,
--                   UPDID = V_SESS_USER_ID
--             WHERE WERKS = V_WERKS
--               AND STOR_LOC_CD = '3100'
--               --AND MACH_CD = V_MACH_CD
--               AND IND_BCD = V_IND_BCD;    
--        END LOOP;    
        RETURN;
    END IF;

    IF V_DOC_SEQNO_1 > 0 THEN
        P_DOC_NO1 := V_DOC_NO_1;
    END IF;

    IF V_DOC_SEQNO_2 > 0 THEN
        P_DOC_NO2 := V_DOC_NO;
    END IF;

--    IF V_DOC_SEQNO_2 > 0 THEN
--        P_DOC_NO2 := V_DOC_NO_2;
--    END IF;

    P_SUCCESS := 'Y';

    COMMIT;

--    EXCEPTION
--    WHEN E_EXCEPTION_USER THEN
--
--        -- 에러 내역 SET
--	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := SQLCODE;
--        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);
--        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--
--        ROLLBACK;
--
--    WHEN OTHERS THEN
--	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := SQLCODE;
--        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--        ROLLBACK;
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
