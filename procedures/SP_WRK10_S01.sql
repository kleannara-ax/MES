
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK10_S01" (
	P_TYPE           IN    varchar2, -- LIST, SUB_LIST-A, SUB_LIST-B
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
    P_ERR_MSG       OUT     VARCHAR2,
    P_DOC_NO1       OUT     VARCHAR2,
    P_DOC_NO2       OUT     VARCHAR2,
    P_DOC_NO3       OUT     VARCHAR2, -- 자재투입취소 IF143
    P_DOC_NO4       OUT     VARCHAR2, -- 자재투입등록 IF130
    P_CLOSE_YN      OUT     VARCHAR2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK10_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 폐품등록 현황 (화장지 가공기) {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 폐품등록 현황 (화장지 가공기) 조회.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박성철{최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/20 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   박성철         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_WRK016] : (RU) 폐품 등록정보
 *        - [TB_MAS012] : (.R..) 설비마스터
 *        - [TB_MAS001] : (.R..) 자재마스터                                     
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK10_S01';     -- PROCEDURE NAME


    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_LIST2      JSON_OBJECT_T;
    V_ARR_HEAD       JSON_ARRAY_T;
    V_OBJ            JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS					TB_WRK016.WERKS%TYPE;			    -- 플랜트코드
    V_PROC_CD				TB_MAS013.PROC_CD%TYPE;			    -- 공정코드

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역

	V_MACH_CD 		            TB_WRK016.MACH_CD%TYPE;			    --작업장코드(설비코드)
	V_PRFM_DT 		            TB_WRK016.PRFM_DT%TYPE;			    --실적일자
	V_WRK_ORDR_NO 		        TB_WRK016.WRK_ORDR_NO%TYPE;			--작업지시번호
	V_WRK_ORDR_SEQNO 		    TB_WRK016.WRK_ORDR_SEQNO%TYPE;		--작업지시 순번
	V_DISPO_WGT 		        TB_WRK016.DISPO_WGT%TYPE;			--폐품중량

    V_MACHINE                   TB_SCH012.MACHINE%TYPE;
    V_WRK_CLASS                 TB_WRK001.WRK_CLASS%TYPE;
    V_LOT_NO_M                  TB_WRK001.LOT_NO%TYPE;
    V_LOT_NO                    TB_WRK001.LOT_NO%TYPE;
    V_MATNR_M                   TB_WRK001.MATNR%TYPE;
    V_PRFM_QTY_M                TB_WRK001.PRFM_QTY%TYPE;
    V_UNIT                      TB_WRK001.UNIT%TYPE;
    V_USE_QTY_DAY                 TB_WRK001.PRFM_QTY%TYPE;
    V_COM_YN                    TB_WRK001.COMP_YN%TYPE;
    V_DISPO_QTY                 TB_WRK001.PRFM_QTY%TYPE;
    V_DISPO_WGT_PRE             TB_WRK016.DISPO_WGT%TYPE;
    V_IND_BCD                   TB_WRK001.IND_BCD%TYPE;
    V_MATNR                     TB_WRK001.MATNR%TYPE;
    V_ORDER_NO                  TB_WRK001.ORDER_NO%TYPE;
    V_DOC_NO_1                  TB_WRK001.DOC_NO%TYPE;
    V_DOC_SEQNO_1               TB_WRK001.DOC_SEQNO%TYPE;
    V_DOC_NO_2                  TB_WRK001.DOC_NO%TYPE;
    V_DOC_SEQNO_2               TB_WRK001.DOC_SEQNO%TYPE;
    V_DOC_NO_3       VARCHAR2(30);
    V_DOC_SEQNO_3    NUMBER;
    V_DOC_NO_4       VARCHAR2(30);
    V_DOC_SEQNO_4    NUMBER;
    V_USE_QTY_C      TB_INV013.USE_QTY%TYPE;       -- 폐품 변경 후 새 사용량
    V_INV013_EXISTS  VARCHAR2(1);                   -- TB_INV013 존재 여부

    V_DOC_NO_PRE                TB_WRK016.DOC_NO%TYPE;
    V_DOC_SEQNO_PRE             TB_WRK016.DOC_SEQNO%TYPE;
    V_SEQNO                     NUMBER;
    V_IND_BCD_M                 TB_WRK001.IND_BCD%TYPE;
    V_DOC_NO                    TB_WRK016.DOC_NO%TYPE;
    V_DOC_SEQNO                 TB_WRK016.DOC_SEQNO%TYPE;
    V_SDOC_NO                   TB_WRK016.SDOC_NO%TYPE;
    V_SDOC_SEQNO                TB_WRK016.SDOC_SEQNO%TYPE;

    V_SAP_WRK_CD                TB_MAS012.SAP_WRK_CD%TYPE;
    V_STOR_LOC_CD               TB_MAS001.LGPRO%TYPE;
    V_PRD_STR_DTM               TB_SCH012.PRD_STR_DTM%TYPE;
    V_PRD_END_DTM               TB_SCH012.PRD_END_DTM%TYPE;
    V_SDATE                     VARCHAR2(10);
    V_STIME                     VARCHAR2(10);
    V_EDATE                     VARCHAR2(10);
    V_ETIME                     VARCHAR2(10); 
    V_CHK                       NUMBER;
    V_M_SEQNO                   NUMBER;
    V_M_IND_BCD                 TB_INV010.IND_BCD%TYPE;
    V_M_IND_BCD_M               TB_INV010.IND_BCD%TYPE;
    V_M_STCK_QTY                TB_INV003.STCK_QTY%TYPE;

    V_M_POSITION                VARCHAR2(5);
    V_M_WGT                     TB_INV003.WGT%TYPE;
    V_M_ROLLCNT                 TB_INV003.ROLLCNT%TYPE;
    V_M_CHG_FLG                 TB_INV010.CHG_FLG%TYPE;
    V_M_INP_DT                  TB_INV010.INP_DT%TYPE;
    V_M_PRFM_DT                 TB_INV010.PRFM_DT%TYPE;
    V_M_STCK_KY                 TB_INV010.STCK_KY%TYPE;
    V_M_LOT_NUM                 TB_INV010.LOT_NUM%TYPE;
    V_INP_DT                    TB_INV010.INP_DT%TYPE;
    --V_PRFM_DT                 TB_INV010.PRFM_DT%TYPE;
    V_STCK_KY                   TB_INV010.STCK_KY%TYPE;
    V_LOT_NUM                   TB_INV010.LOT_NUM%TYPE;
    V_M_STCK_STA                TB_INV001.STCK_STA%TYPE;
    V_T_USE_QTY                 TB_INV001.STCK_QTY%TYPE;
    V_REST_QTY                  TB_INV010.USE_QTY%TYPE;
    V_REM_QTY                   TB_INV010.USE_QTY%TYPE;
    V_CHG_QTY                   TB_INV010.USE_QTY%TYPE;
    V_SCRAP_QTY                 TB_INV010.USE_QTY%TYPE;
    V_SEQNO_H                   NUMBER;
    V_DATE                      DATE := SYSDATE;
    V_FLG                       NUMBER;
    PROD_CUR            SYS_REFCURSOR;		-- 커서 정의
    PROD_CUR2            SYS_REFCURSOR;		-- 커서 정의
    V_ROLLBACK_DOC_NO_1		    VARCHAR2(30);
    V_ROLLBACK_DOC_NO_2		    VARCHAR2(20);

    /* 배치별 폐품 수량 분배용 */
    V_REMAIN_QTY       TB_INV010.USE_QTY%TYPE;
    V_ALLOC_QTY        TB_INV010.USE_QTY%TYPE;
    V_TOTAL_AVAIL_QTY  TB_INV010.USE_QTY%TYPE;
    /* 폐품 분배 시작 IND_BCD */
    V_START_IND_BCD    TB_INV010.IND_BCD%TYPE;
    V_RESTORE_REMAIN   TB_INV010.USE_QTY%TYPE;
    V_RESTORE_ALLOC    TB_INV010.USE_QTY%TYPE;
    V_RESTORE_AVAIL_QTY TB_INV010.USE_QTY%TYPE;
BEGIN
    OPEN P_RS_LIST FOR 

    SELECT NULL FROM DUAL WHERE ROWNUM = 0;

    V_DEBUG := 'Y';
    V_RUN_SQL := 'Y';

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

    V_SESS_USER_ID       :=      V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=      V_JSON.get_string('SES_PLNTKY');

    /* 조건값 할당 */
    V_RANGE_SQL         :=      V_JSON.get_string('RANGE_SQL');
    V_WERKS				:= 		V_JSON.get_string('WERKS');		        -- 플랜트
    V_PRFM_DT           := 		V_JSON.get_string('PRFM_DT');		    -- 실적일자
    V_MACHINE			:= 		V_JSON.get_string('MACHINE');		    -- 생산호기
    V_MATNR             := 		V_JSON.get_string('MATNR');		        -- 자재코드
    V_WRK_CLASS			:= 		V_JSON.get_string('WRK_CLASS');		    -- 반
    V_ROLLBACK_DOC_NO_1 :=		V_JSON.get_string('DOC_NO_1');		    -- 문서번호1
    V_ROLLBACK_DOC_NO_2 :=		V_JSON.get_string('DOC_NO_2');		    -- 문서번호2


    IF P_TYPE = 'LIST1' THEN /*계획정보 조회*/
        V_SQL := ' SELECT S012.WERKS,
                          S012.WRK_ORDR_NO,
                          S012.WRK_ORDR_SEQNO,
                          S012.ORDER_NO,
                          S012.MATNR,
                          M001.MATNR_NM,
                          S012.ORDER_QTY,
                          W001.PRFM_QTY,
                          S012.UNIT,
                          S012.PRD_REQ_DT,
                          S012.MACHINE,
                          CASE WHEN NVL(S012.COMP_YN, ''N'') = ''Y'' THEN ''생산완료''
                               WHEN NVL(S012.COMP_YN, ''N'') = ''N'' THEN ''''
                               WHEN NVL(S012.COMP_YN, ''N'') = ''I'' THEN ''생산중'' END AS COMP_YN,
                          S012.MACH_CD     
                    FROM TB_SCH012 S012,
                          (SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO, SUM(PRFM_QTY) AS PRFM_QTY
                             FROM TB_WRK001
                            WHERE WERKS = ''' || V_WERKS || '''
                              AND WRK_ORDR_NO IN (SELECT WRK_ORDR_NO
                                                    FROM TB_WRK001
                                                   WHERE WERKS = ''' || V_WERKS || '''
                                                     AND MACH_CD IN (SELECT MACH_CD
                                                                       FROM TB_MAS012
                                                                      WHERE PROC_CD = ''RA''';
        IF  V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '' THEN			   
            V_SQL := V_SQL || ' AND MACHINE = ''' || V_MACHINE || '''';   
        END IF;                                                                      

        V_SQL := V_SQL || '                                            )
                                                    AND PRFM_DT = ''' || V_PRFM_DT || '''';                                                                

       /* IF  V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN			  
            V_SQL := V_SQL || '                     AND MATNR = ''' || V_MATNR || '''';
        END IF;
        IF  V_WRK_CLASS IS NOT NULL OR TRIM(V_WRK_CLASS) != '' THEN			  
            V_SQL := V_SQL || '                     AND WRK_CLASS = ''' || V_WRK_CLASS || '''';
        END IF;  */
                                                   
        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;                                           

        V_SQL := V_SQL || '                        GROUP BY WRK_ORDR_NO)  
                           GROUP BY WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO) W001,   
                           TB_MAS001 M001
                     WHERE S012.WERKS = W001.WERKS
                       AND S012.WRK_ORDR_NO = W001.WRK_ORDR_NO
                       AND S012.WRK_ORDR_SEQNO = W001.WRK_ORDR_SEQNO
                       AND S012.WERKS = M001.WERKS(+)
                       AND S012.MATNR = M001.MATNR(+)';
        V_SQL := V_SQL || ' ORDER BY S012.PRD_REQ_DT';   

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;
    ELSIF P_TYPE = 'LIST2' THEN         --실적정보 조회
        V_ARR_LIST2        := TREAT (V_JSON.get ('head') AS json_object_t);
        V_OBJ			   := TREAT (V_ARR_LIST2.get ('map') AS json_object_t);

        V_WERKS 		            := V_OBJ.get_string('WERKS');			    --플랜트코드
        V_MACHINE 		            := V_OBJ.get_string('MACHINE');			    --생산호기
        V_MACH_CD                   := V_OBJ.get_string('MACH_CD');			    --생산설비
--        V_PRFM_DT 		            := V_OBJ.get_string('PRFM_DT');			    --실적일자
        V_WRK_ORDR_NO 		        := V_OBJ.get_string('WRK_ORDR_NO');			--작업지시번호
        V_WRK_ORDR_SEQNO 		    := V_OBJ.get_string('WRK_ORDR_SEQNO');		--작업지시 순번

        V_SQL := ' SELECT W001.WERKS, 
                        W001.MACH_CD,
                        W001.WRK_ORDR_NO, 
                        W001.WRK_ORDR_SEQNO, 
                        W001.ORDER_NO,
                        W001.MATNR,
                        M001.MATNR_NM,
                        W001.LOT_NO,
                        SUM(W001.PRFM_QTY)  AS PRFM_QTY,
                        W001.UNIT,
                        ROUND((MAX(W001.PRD_END_DATE) - MIN(W001.PRD_STR_DATE))*24*60,1) AS RUN_TIME
                    FROM TB_WRK001 W001,
                         TB_MAS001 M001
                   WHERE W001.WERKS = M001.WERKS(+)
                     AND W001.MATNR = M001.MATNR(+)
                     AND W001.WERKS = ''' || V_WERKS || '''
                     AND W001.MACH_CD = ''' || V_MACH_CD || '''
                     AND W001.WRK_ORDR_NO = ''' || V_WRK_ORDR_NO || '''
                     AND W001.WRK_ORDR_SEQNO = ''' || V_WRK_ORDR_SEQNO || '''
                  GROUP BY W001.WERKS, W001.MACH_CD,W001.WRK_ORDR_NO, W001.WRK_ORDR_SEQNO, 
                        W001.ORDER_NO, W001.MATNR, M001.MATNR_NM, W001.LOT_NO, W001.UNIT ';           

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;
    ELSIF P_TYPE = 'LIST3' THEN         --투입정보 조회
        V_ARR_LIST2        := TREAT (V_JSON.get ('head') AS json_object_t);
        V_OBJ			   := TREAT (V_ARR_LIST2.get ('map') AS json_object_t);

        V_WERKS 		            := V_OBJ.get_string('WERKS');			    --플랜트코드
        V_MACH_CD 		            := V_OBJ.get_string('MACH_CD');			    --생산설비
        V_PRFM_DT 		            := V_JSON.get_string('PRFM_DT');			    --실적일자
        V_WRK_ORDR_NO 		        := V_OBJ.get_string('WRK_ORDR_NO');			--작업지시번호
        V_WRK_ORDR_SEQNO 		    := V_OBJ.get_string('WRK_ORDR_SEQNO');		--작업지시 순번
        
        V_SQL := 'SELECT A.WERKS, A.WRK_ORDR_NO, A.WRK_ORDR_SEQNO, A.MACH_CD, A.PRFM_DT, A.MATNR_M, M001.MATNR_NM, A.LOT_NO_M, A.IND_BCD_M, 
                         M001.UNIT, A.PRFM_QTY,
                               (
                               SELECT NVL(SUM(U.USE_QTY), 0)
                                 FROM TB_INV010 U
                                WHERE U.WERKS = A.WERKS
                                  AND U.LOT_NO_M = A.LOT_NO_M
                                  AND NVL(U.CNL_YN, ''N'') = ''N''
                                  AND U.USE_DIV IN (''1'', ''2'')
                           ) AS USE_QTY_TOTAL_LOT_NO,
                        A.USE_QTY_DAY,
                         NVL((
                            SELECT SUM(I001.STCK_QTY)
                              FROM TB_INV001 I001
                             WHERE I001.WERKS    = A.WERKS
                               AND I001.MATNR    = A.MATNR_M
                               AND I001.IND_BCD  = A.IND_BCD_M
                               AND I001.LOT_NO   = A.LOT_NO_M
                               AND I001.STCK_STA = ''0''
                        ), 0)
                        +
                        NVL((
                            SELECT SUM(I003.STCK_QTY)
                              FROM TB_INV003 I003
                             WHERE I003.WERKS    = A.WERKS
                               AND I003.MACH_CD  = A.MACH_CD
                               AND I003.MATNR    = A.MATNR_M
                               AND I003.IND_BCD  = A.IND_BCD_M
                               AND I003.LOT_NO   = A.LOT_NO_M
                        ), 0) AS REST_QTY
                         ,A.SCRAP_QTY, '''' AS SCRAP_CHG_QTY
                    FROM(
                        SELECT I010.WERKS, I010.WRK_ORDR_NO, I010.WRK_ORDR_SEQNO, I010.MACH_CD, I010.PRFM_DT, I010.MATNR_M, I010.LOT_NO_M, I010.IND_BCD_M,
                            --SUM(I010.USE_QTY) AS USE_QTY,
                            CASE    WHEN I010.MATNR_M LIKE ''H000%'' THEN
                                        (SELECT NVL(RCV_WGT, 0)
                                        FROM    TB_INV001
                                        WHERE   WERKS = I010.WERKS
                                           AND MATNR = I010.MATNR_M
                                           AND IND_BCD = I010.IND_BCD_M
                                           AND LOT_NO = I010.LOT_NO_M)
                                    ELSE
                                        (SELECT NVL(SUM(PRFM_QTY), 0)
                                          FROM TB_WRK001
                                         WHERE WERKS = I010.WERKS
                                           AND MATNR = I010.MATNR_M
                                           AND IND_BCD = I010.IND_BCD_M
                                           AND LOT_NO = I010.LOT_NO_M
                                         GROUP BY WERKS, LOT_NO)
                            END AS PRFM_QTY,
--                            (SELECT NVL(SUM(PRFM_QTY), 0)
--                              FROM TB_WRK001
--                             WHERE WERKS = I010.WERKS
--                               AND MATNR = I010.MATNR_M
--                               AND IND_BCD = I010.IND_BCD_M
--                               AND LOT_NO = I010.LOT_NO_M
--                             GROUP BY WERKS, LOT_NO) AS PRFM_QTY,
                            (SELECT SUM(USE_QTY)
                               FROM TB_INV010
                              WHERE WERKS = I010.WERKS
                               AND MACH_CD = I010.MACH_CD
                               AND MATNR_M = I010.MATNR_M
                               AND LOT_NO_M = I010.LOT_NO_M
                               AND IND_BCD_M = I010.IND_BCD_M
                               AND PRFM_DT = I010.PRFM_DT
                               AND NVL(CNL_YN, ''N'') = ''N''
                               AND USE_DIV IN (''1'', ''2'')
                               GROUP BY WERKS, MACH_CD, LOT_NO_M, IND_BCD_M, MATNR_M) AS USE_QTY_DAY,
                            (SELECT SUM(USE_QTY)
                               FROM TB_INV010
                              WHERE WERKS = I010.WERKS
                               AND MACH_CD = I010.MACH_CD
                               AND MATNR_M = I010.MATNR_M
                               AND PRFM_DT = ''' || V_PRFM_DT || '''
                               AND WRK_ORDR_NO = I010.WRK_ORDR_NO
                               AND WRK_ORDR_SEQNO = I010.WRK_ORDR_SEQNO
                               AND IND_BCD_M = I010.IND_BCD_M
                               AND PRFM_DT = I010.PRFM_DT
                               AND NVL(CNL_YN, ''N'') = ''N''
                               AND USE_DIV = ''3'') AS SCRAP_QTY
                          FROM TB_INV010 I010
                         WHERE I010.WERKS = ''' || V_WERKS || '''
                           AND I010.MACH_CD = ''' || V_MACH_CD || '''
                           AND I010.PRFM_DT = ''' || V_PRFM_DT || '''
                           AND I010.WRK_ORDR_NO = ''' || V_WRK_ORDR_NO || '''
                           AND I010.WRK_ORDR_SEQNO = ''' || V_WRK_ORDR_SEQNO || '''
                           AND I010.USE_DIV IN (''1'', ''2'')
                           AND NVL(I010.CNL_YN, ''N'') = ''N''
                        GROUP BY I010.WERKS, I010.WRK_ORDR_NO, I010.WRK_ORDR_SEQNO, I010.MACH_CD, I010.PRFM_DT, I010.MATNR_M, I010.LOT_NO_M, I010.IND_BCD_M
                        ) A ,
                        TB_MAS001 M001
                  WHERE A.WERKS = M001.WERKS(+)
                    AND A.MATNR_M = M001.MATNR(+)
                  ORDER BY A.PRFM_DT, A.LOT_NO_M, A.IND_BCD_M'  ;

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
            COMMIT;
        END IF;

		OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SAVE' THEN          --저장

--        V_WERKS 		            := V_JSON.get_string('WERKS');			    --플랜트코드
--        V_PRFM_DT 		            := V_JSON.get_string('PRFM_DT');			    --실적일자
        V_ARR_LIST2                 := TREAT (V_JSON.get ('head') AS json_object_t);
        V_OBJ			            := TREAT (V_ARR_LIST2.get ('map') AS json_object_t);
--        V_MACHINE 		            := V_OBJ.get_string('MACHINE');			    --생산호기
--        V_WRK_ORDR_NO 		        := V_OBJ.get_string('WRK_ORDR_NO');			--작업지시번호
--        V_WRK_ORDR_SEQNO 		    := V_OBJ.get_string('WRK_ORDR_SEQNO');		--작업지시 순번

        V_DOC_NO_1 := FN_GET_MDOCNO('M','IF134');
        V_DOC_SEQNO_1 := 0;
        V_DOC_NO_2 := FN_GET_MDOCNO('M','IF144');
        V_DOC_SEQNO_2 := 0;
        V_DOC_NO_3 := FN_GET_MDOCNO('M', 'IF143');
        V_DOC_SEQNO_3 := 0;
        V_DOC_NO_4 := FN_GET_MDOCNO('M', 'IF130');
        V_DOC_SEQNO_4 := 0;
        
        V_ARR_LIST                  := V_JSON.get_array('list');

--      마감 판정 체크
        P_CLOSE_YN := 'N';

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP

	        V_OBJ						:= TREAT (V_ARR_LIST.get (i) AS json_object_t);  
            V_OBJ						:= TREAT (V_OBJ.get ('map') AS json_object_t);

			V_WERKS                     := V_OBJ.get_string('WERKS');		    --플랜트
            V_WRK_ORDR_NO               := V_OBJ.get_string('WRK_ORDR_NO');		--작업지시번호
            V_WRK_ORDR_SEQNO            := V_OBJ.get_string('WRK_ORDR_SEQNO');	--작업지시순번
            V_MACH_CD                   := V_OBJ.get_string('MACH_CD');	        --설비코드
            V_LOT_NO_M                  := V_OBJ.get_string('LOT_NO_M');		--합지LOT NO
            V_IND_BCD_M                 := V_OBJ.get_string('IND_BCD_M');		--합지 개별바코드
            V_MATNR_M                   := V_OBJ.get_string('MATNR_M');		    --합지자재코드
            V_PRFM_QTY_M                := NVL(V_OBJ.get_string('PRFM_QTY'), 0);--합지 LOT별 생산량
            V_UNIT                      := V_OBJ.get_string('UNIT');		    --단위
            V_USE_QTY_DAY                 := NVL(V_OBJ.get_string('USE_QTY_DAY'), 0);	-- 일일 사용량
            V_DISPO_QTY                 := NVL(TRIM(V_OBJ.get_string('SCRAP_QTY')), 0);		--폐품량
            V_CHG_QTY                   := NVL(V_OBJ.get_string('SCRAP_CHG_QTY'), 0);	--폐품보정 수정
            V_PRFM_DT 		            := V_OBJ.get_string('PRFM_DT');			--실적일자

            V_REST_QTY                  := NVL(V_OBJ.get_string('REST_QTY'), 0);
            V_RESTORE_REMAIN            := NVL(V_DISPO_QTY, 0);

            DBMS_OUTPUT.PUT_LINE('------------------------------------');
	        DBMS_OUTPUT.PUT_LINE('V_CHG_QTY: 사용량(TB_INV010.USE_QTY) // V_USE_QTY_DAY: 특정일 사용량(TB_WRK001.PRFM_QTY) // V_DISPO_QTY: 실적수량(TB_WRK001.PRFM_QTY)');
            DBMS_OUTPUT.PUT_LINE('SAVE V_CHG_QTY : ' || NVL(V_CHG_QTY, 0));
            DBMS_OUTPUT.PUT_LINE('SAVE V_USE_QTY_DAY : ' || NVL(V_USE_QTY_DAY, 0));
	        DBMS_OUTPUT.PUT_LINE('SAVE V_REST_QTY : ' || NVL(V_REST_QTY, 0));
            DBMS_OUTPUT.PUT_LINE('------------------------------------');

	        SZP_MES_PLSQL_LOG(NVL(V_CHG_QTY, 0), 'WRK10_S01 V_CHG_QTY');
	        SZP_MES_PLSQL_LOG(NVL(V_USE_QTY_DAY, 0), 'WRK10_S01 V_USE_QTY_DAY');
            -- 폐품량 > 사용량
	        IF NVL(V_CHG_QTY, 0)  > NVL(V_USE_QTY_DAY, 0) + NVL(V_DISPO_QTY, 0) THEN
                P_SUCCESS := 'N';
                P_ERR_MSG := '폐품량을 일일 사용량보다 많이 등록할 수 없습니다.';
                ROLLBACK;
                RETURN;
            END IF;


            -- 폐품량 미입력 처리
            -- 기존에 0이었으나 폐품량을 0으로 바꾸고 싶은 경우를 배제하여 -1로 처리
            IF NVL(V_DISPO_QTY, -1) = -1 AND  NVL(V_CHG_QTY, -1) = -1 THEN
                P_SUCCESS := 'N';
                P_ERR_MSG := '폐품량을 입력해주세요.';
                ROLLBACK;
                RETURN;
            END IF;
            -- 사용량 < 0
            IF  NVL(V_CHG_QTY, 0) < 0 THEN
                P_SUCCESS := 'N';
                P_ERR_MSG := '폐품량을 입력해주세요.';
                ROLLBACK;
                RETURN;
            END IF;

            SELECT A.MATNR, A.IND_BCD, A.LOT_NO,
                   A.UNIT, A.INP_DT, A.STCK_KY, A.LOT_NUM
                   INTO  
                   V_MATNR, V_IND_BCD, V_LOT_NO,
                   V_UNIT, V_INP_DT, V_STCK_KY, V_LOT_NUM
              FROM (
                    SELECT *
                      FROM TB_INV010
                     WHERE WERKS = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND WRK_ORDR_NO = V_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                       AND PRFM_DT = V_PRFM_DT
                       AND IND_BCD_M = V_IND_BCD_M
                       AND LOT_NO_M = V_LOT_NO_M
                       AND USE_DIV = '1'
                    ORDER BY REGDATE DESC) A
             WHERE ROWNUM = 1;

	        /*
             * 폐품 분배 시작 바코드 저장
             *
             * 이후 분배 LOOP 안에서 V_IND_BCD가 변경되므로
             * 최초 조회값을 별도 변수로 보관한다.
             */
            V_START_IND_BCD := V_IND_BCD;

            SZP_MES_PLSQL_LOG(
                V_START_IND_BCD,
                'WRK10 폐품분배 시작 IND_BCD'
            );

	        /*^ 제일 regdate desc 로 조회해서 rownum = 1 */

            BEGIN
                SELECT NVL(MAX(SEQNO), 0) INTO V_M_SEQNO
                  FROM TB_INV010
                 WHERE WERKS = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND IND_BCD = V_IND_BCD;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_M_SEQNO := 0;
                END;


                SELECT NVL(
               SUM(
                   CASE
                       WHEN NET_USE_QTY < 0
                       THEN 0 - NET_USE_QTY
                       ELSE 0
                   END
               ),
               0
           )
             INTO V_RESTORE_AVAIL_QTY
             FROM (
            SELECT MATNR,
                   IND_BCD,
                   SUM(USE_QTY) AS NET_USE_QTY
              FROM TB_INV010
             WHERE WERKS            = V_WERKS
               AND MACH_CD          = V_MACH_CD
               AND WRK_ORDR_NO      = V_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO   = V_WRK_ORDR_SEQNO
               AND IND_BCD_M        = V_IND_BCD_M
               AND LOT_NO_M         = V_LOT_NO_M
               AND MATNR_M          = V_MATNR_M
               AND PRFM_DT          = V_PRFM_DT
               AND USE_DIV          = '2'
               AND NVL(CNL_YN, 'N') = 'N'
             GROUP BY MATNR, IND_BCD
           );
	        IF NVL(V_RESTORE_AVAIL_QTY, 0) < NVL(V_DISPO_QTY, 0) THEN
                P_SUCCESS := 'N';
                P_ERR_MSG :=
                      '기존 폐품량만큼 사용량을 복구할 수 없습니다.'
                   || ' 기존 폐품량: ' || TO_CHAR(V_DISPO_QTY)
                   || ', 복구 가능량: ' || TO_CHAR(V_RESTORE_AVAIL_QTY);

                ROLLBACK;
                RETURN;
            END IF;

            --기존이력 삭제
	        SZP_MES_PLSQL_LOG(V_DISPO_QTY, 'V_DISPO_QTY wrk10_s01');
            /*=====================================================================
             * 기존 폐품이 있으면 바코드별 기존 배분을 전부 복구
             *=====================================================================*/
            IF NVL(V_DISPO_QTY, 0) <> 0 THEN
                /*
                 * 반드시 USE_DIV='3' 취소 UPDATE보다 먼저 실행해야 한다.
                 */
                FOR R_OLD_USE IN
                (
                    SELECT MATNR,
                           IND_BCD,
                           0 - SUM(USE_QTY) AS RESTORE_AVAIL_QTY
                      FROM TB_INV010
                     WHERE WERKS            = V_WERKS
                       AND MACH_CD          = V_MACH_CD
                       AND WRK_ORDR_NO      = V_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO   = V_WRK_ORDR_SEQNO
                       AND IND_BCD_M        = V_IND_BCD_M
                       AND LOT_NO_M         = V_LOT_NO_M
                       AND MATNR_M          = V_MATNR_M
                       AND PRFM_DT          = V_PRFM_DT
                       AND USE_DIV          = '2'
                       AND NVL(CNL_YN, 'N') = 'N'
                     GROUP BY MATNR, IND_BCD
                    HAVING SUM(USE_QTY) < 0
                     ORDER BY IND_BCD DESC
                )
                LOOP
                    EXIT WHEN V_RESTORE_REMAIN <= 0;

                    /*
                     * 화면의 기존 폐품량 중 남은 복구량과
                     * 해당 바코드의 복구 가능량 중 작은 값
                     */
                    V_RESTORE_ALLOC := LEAST(
                        V_RESTORE_REMAIN,
                        R_OLD_USE.RESTORE_AVAIL_QTY
                    );

                    /*
                     * 복구 INSERT에 필요한 바코드 원본 정보 조회
                     */
                    SELECT A.LOT_NO,
                           A.UNIT,
                           A.INP_DT,
                           A.STCK_KY,
                           A.LOT_NUM,
                           NVL(A.ROLLCNT, 0)
                      INTO V_LOT_NO,
                           V_UNIT,
                           V_INP_DT,
                           V_STCK_KY,
                           V_LOT_NUM,
                           V_M_ROLLCNT
                      FROM (
                            SELECT T.*
                              FROM TB_INV010 T
                             WHERE T.WERKS = V_WERKS
                               AND T.MACH_CD = V_MACH_CD
                               AND T.MATNR = R_OLD_USE.MATNR
                               AND T.IND_BCD = R_OLD_USE.IND_BCD
                               AND T.IND_BCD_M = V_IND_BCD_M
                               AND T.LOT_NO_M = V_LOT_NO_M
                               AND T.MATNR_M = V_MATNR_M
                             ORDER BY
                                   CASE
                                       WHEN T.USE_DIV = '1' THEN 0
                                       ELSE 1
                                   END,
                                   T.REGDATE DESC,
                                   T.SEQNO DESC
                           ) A
                     WHERE ROWNUM = 1;

                    /*
                     * 현재 바코드의 다음 SEQNO
                     */
                    SELECT NVL(MAX(SEQNO), 0) + 1
                      INTO V_M_SEQNO
                      FROM TB_INV010
                     WHERE WERKS = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND MATNR = R_OLD_USE.MATNR
                       AND IND_BCD = R_OLD_USE.IND_BCD;

                    /*
                     * 폐품으로 차감했던 사용량을 해당 IND_BCD에 양수 복구
                     */
                    INSERT INTO TB_INV010
                    (
                        WERKS,
                        MACH_CD,
                        MATNR,
                        IND_BCD,
                        SEQNO,
                        WRK_ORDR_NO,
                        WRK_ORDR_SEQNO,
                        LOT_NO,
                        IND_BCD_M,
                        LOT_NO_M,
                        MATNR_M,
                        INP_DT,
                        PRFM_DT,
                        USE_QTY,
                        UNIT,
                        ROLLCNT,
                        WGT,
                        CHG_FLG,
                        STCK_KY,
                        LOT_NUM,
                        REGDATE,
                        REGID,
                        USE_DIV,
                        CNL_YN
                    )
                    VALUES
                    (
                        V_WERKS,
                        V_MACH_CD,
                        R_OLD_USE.MATNR,
                        R_OLD_USE.IND_BCD,
                        V_M_SEQNO,
                        V_WRK_ORDR_NO,
                        V_WRK_ORDR_SEQNO,
                        V_LOT_NO,
                        V_IND_BCD_M,
                        V_LOT_NO_M,
                        V_MATNR_M,
                        V_INP_DT,
                        V_PRFM_DT,
                        V_RESTORE_ALLOC,
                        V_UNIT,
                        V_M_ROLLCNT,
                        V_RESTORE_ALLOC,
                        'N',
                        V_STCK_KY,
                        V_LOT_NUM,
                        V_DATE,
                        V_SESS_USER_ID,
                        '2',
                        'N'
                    );

                    V_RESTORE_REMAIN :=
                        V_RESTORE_REMAIN - V_RESTORE_ALLOC;

                    SZP_MES_PLSQL_LOG(
                          'IND_BCD=' || R_OLD_USE.IND_BCD
                       || ', AVAILABLE='
                       || TO_CHAR(R_OLD_USE.RESTORE_AVAIL_QTY)
                       || ', RESTORE='
                       || TO_CHAR(V_RESTORE_ALLOC)
                       || ', REMAIN='
                       || TO_CHAR(V_RESTORE_REMAIN),
                        'WRK10 기존 사용량 복구'
                    );
                END LOOP;

                IF V_RESTORE_REMAIN > 0 THEN
                    P_SUCCESS := 'N';
                    P_ERR_MSG :=
                          '기존 폐품량을 바코드별로 모두 복구하지 못했습니다.'
                       || ' 기존 폐품량: ' || TO_CHAR(V_DISPO_QTY)
                       || ', 미복구량: ' || TO_CHAR(V_RESTORE_REMAIN);

                    ROLLBACK;
                    RETURN;
                END IF;

                /*
                 * 바코드별 복구가 끝난 뒤 기존 폐품 이력을 취소
                 */
                UPDATE TB_INV010
                   SET CNL_YN = 'Y',
                       UPDDATE = V_DATE,
                       UPDID = V_SESS_USER_ID
                 WHERE WERKS            = V_WERKS
                   AND MACH_CD          = V_MACH_CD
                   AND WRK_ORDR_NO      = V_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO   = V_WRK_ORDR_SEQNO
                   AND IND_BCD_M        = V_IND_BCD_M
                   AND LOT_NO_M         = V_LOT_NO_M
                   AND MATNR_M          = V_MATNR_M
                   AND PRFM_DT          = V_PRFM_DT
                   AND USE_DIV          = '3'
                   AND NVL(CNL_YN, 'N') = 'N';

                SZP_MES_PLSQL_LOG(
                    SQL%ROWCOUNT,
                    'update 기존 TB_INV010 폐품 rowcount'
                );


                /* 기존 폐품 관리 이력 취소 */
                UPDATE TB_WRK016
                   SET CNL_YN = 'Y',
                       UPDDATE = V_DATE,
                       UPDID = V_SESS_USER_ID
                 WHERE WERKS          = V_WERKS
                   AND MACH_CD        = V_MACH_CD
                   AND WRK_ORDR_NO    = V_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                   AND LOT_NO_M       = V_LOT_NO_M
                   AND MATNR_M        = V_MATNR_M
                   AND IND_BCD_M      = V_IND_BCD_M
                   AND PRFM_DT        = V_PRFM_DT;

            END IF;
--             이 부분이 단일 개별바코드에 의한 값 처리
--             V_M_SEQNO := V_M_SEQNO + 1;
--             INSERT INTO TB_INV010(WERKS, MACH_CD, MATNR, IND_BCD, SEQNO,
--                                 WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO,
--                                 IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, PRFM_DT,
--                                 USE_QTY, UNIT, ROLLCNT, WGT, CHG_FLG,
--                                 STCK_KY, LOT_NUM, REGDATE, REGID, USE_DIV, CNL_YN)
--                         VALUES(V_WERKS, V_MACH_CD, V_MATNR, V_IND_BCD, V_M_SEQNO,
--                                V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_LOT_NO,
--                                V_IND_BCD_M, V_LOT_NO_M, V_MATNR_M, V_INP_DT, V_PRFM_DT,
--                                V_CHG_QTY, V_UNIT, V_M_ROLLCNT, V_CHG_QTY, 'N',
--                                V_STCK_KY, V_LOT_NUM, V_DATE, V_SESS_USER_ID, '3', 'N');
--
--             V_M_SEQNO := V_M_SEQNO + 1;
--             INSERT INTO TB_INV010(WERKS, MACH_CD, MATNR, IND_BCD, SEQNO,
--                                 WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO,
--                                 IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, PRFM_DT,
--                                 USE_QTY, UNIT, ROLLCNT, WGT, CHG_FLG,
--                                 STCK_KY, LOT_NUM, REGDATE, REGID, USE_DIV, CNL_YN)
--                         VALUES(V_WERKS, V_MACH_CD, V_MATNR, V_IND_BCD, V_M_SEQNO,
--                                V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_LOT_NO,
--                                V_IND_BCD_M, V_LOT_NO_M, V_MATNR_M, V_INP_DT, V_PRFM_DT,
--                                0 - V_CHG_QTY, V_UNIT, V_M_ROLLCNT, 0 - V_CHG_QTY, 'N',
--                                V_STCK_KY, V_LOT_NUM, V_DATE, V_SESS_USER_ID, '2', 'N');



                /*=========================================================================
                 * 2. 기존 폐품량 복구 후 배치 전체 사용 가능량 확인
                 *
                 * 실제 사용량:
                 *   활성 상태인 USE_DIV 1,2의 USE_QTY 합계
                 *
                 * 날짜는 사용하지 않고 LOT_NO_M을 기준으로 계산한다.
                 *=========================================================================*/

                SELECT NVL(SUM(USE_QTY), 0)
                  INTO V_TOTAL_AVAIL_QTY
                  FROM TB_INV010
                 WHERE WERKS = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND LOT_NO_M = V_LOT_NO_M
                   AND MATNR_M = V_MATNR_M
                   AND NVL(CNL_YN, 'N') = 'N'
                   AND USE_DIV IN ('1', '2');


                SZP_MES_PLSQL_LOG(
                      'LOT=' || V_LOT_NO_M
                   || ', AVAILABLE=' || TO_CHAR(V_TOTAL_AVAIL_QTY)
                   || ', SCRAP=' || TO_CHAR(V_CHG_QTY),
                    'WRK10 LOT 사용가능량'
                );


                /* 배치 전체 사용량보다 폐품량이 크면 중단 */
                IF NVL(V_CHG_QTY, 0) > NVL(V_TOTAL_AVAIL_QTY, 0) THEN

                    P_SUCCESS := 'N';
                    P_ERR_MSG :=
                          '폐품량이 LOT의 사용 가능량보다 많습니다.'
                       || ' 사용 가능량: ' || TO_CHAR(V_TOTAL_AVAIL_QTY)
                       || ', 폐품량: ' || TO_CHAR(V_CHG_QTY);

                    ROLLBACK;
                    RETURN;

                END IF;

            /*=========================================================================
             * 3. 신규 폐품량을 IND_BCD 내림차순으로 분배
             *
             * 기존에는 V_CHG_QTY 전체를 하나의 IND_BCD에 넣었지만,
             * 이제 각 IND_BCD의 실제 사용 가능량을 넘지 않도록 나눠 넣는다.
             *
             * 각 IND_BCD에 생성되는 행:
             *   USE_DIV='3', USE_QTY= 양수
             *   USE_DIV='2', USE_QTY= 음수
             *=========================================================================*/

            V_REMAIN_QTY := NVL(V_CHG_QTY, 0);

            FOR R_USE IN
            (
                SELECT IND_BCD,
                       MATNR,
                       SUM(USE_QTY) AS AVAIL_QTY
                  FROM TB_INV010
                 WHERE WERKS = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND LOT_NO_M = V_LOT_NO_M
                   AND MATNR_M = V_MATNR_M
                    /*
                     * 최초 조회된 IND_BCD부터 작은 번호 방향으로만 조회한다.
                     *
                     * 예:
                     * 시작값 R50012
                     * 처리값 R50012 → R50011 → R50010 ...
                     * R50013은 처리하지 않는다.
                     */
                   AND IND_BCD <= V_START_IND_BCD
                   AND NVL(CNL_YN, 'N') = 'N'
                   AND USE_DIV IN ('1', '2')
                 GROUP BY IND_BCD,
                          MATNR
                HAVING SUM(USE_QTY) > 0
                 ORDER BY IND_BCD DESC
            )
            LOOP
                EXIT WHEN V_REMAIN_QTY <= 0;


                /*
                 * 현재 IND_BCD에 배분할 폐품량
                 *
                 * 남은 폐품량과 현재 바코드 사용 가능량 중 작은 값
                 */
                V_ALLOC_QTY := LEAST(
                    V_REMAIN_QTY,
                    R_USE.AVAIL_QTY
                );


                /* 현재 IND_BCD의 원본 자재 정보를 가져온다. */
                SELECT A.MATNR,
                       A.IND_BCD,
                       A.LOT_NO,
                       A.UNIT,
                       A.INP_DT,
                       A.STCK_KY,
                       A.LOT_NUM,
                       NVL(A.ROLLCNT, 0)
                  INTO V_MATNR,
                       V_IND_BCD,
                       V_LOT_NO,
                       V_UNIT,
                       V_INP_DT,
                       V_STCK_KY,
                       V_LOT_NUM,
                       V_M_ROLLCNT
                  FROM
                       (
                           SELECT T.*
                             FROM TB_INV010 T
                            WHERE T.WERKS = V_WERKS
                              AND T.MACH_CD = V_MACH_CD
                              AND T.MATNR = R_USE.MATNR
                              AND T.IND_BCD = R_USE.IND_BCD
                              AND T.LOT_NO_M = V_LOT_NO_M
                              AND T.MATNR_M = V_MATNR_M
                              AND NVL(T.CNL_YN, 'N') = 'N'
                              AND T.USE_DIV IN ('1', '2')
                            ORDER BY
                                  CASE
                                      WHEN T.USE_DIV = '1' THEN 0
                                      ELSE 1
                                  END,
                                  T.REGDATE DESC,
                                  T.SEQNO DESC
                       ) A
                 WHERE ROWNUM = 1;


                /* 현재 IND_BCD의 다음 SEQNO 조회 */
                SELECT NVL(MAX(SEQNO), 0)
                  INTO V_M_SEQNO
                  FROM TB_INV010
                 WHERE WERKS = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND MATNR = V_MATNR
                   AND IND_BCD = V_IND_BCD;


                /*---------------------------------------------------------------------
                 * 기존 순서 유지
                 *
                 * USE_DIV='3': 폐품량 양수
                 *---------------------------------------------------------------------*/

                V_M_SEQNO := V_M_SEQNO + 1;

                INSERT INTO TB_INV010
                (
                    WERKS,
                    MACH_CD,
                    MATNR,
                    IND_BCD,
                    SEQNO,
                    WRK_ORDR_NO,
                    WRK_ORDR_SEQNO,
                    LOT_NO,
                    IND_BCD_M,
                    LOT_NO_M,
                    MATNR_M,
                    INP_DT,
                    PRFM_DT,
                    USE_QTY,
                    UNIT,
                    ROLLCNT,
                    WGT,
                    CHG_FLG,
                    STCK_KY,
                    LOT_NUM,
                    REGDATE,
                    REGID,
                    USE_DIV,
                    CNL_YN
                )
                VALUES
                (
                    V_WERKS,
                    V_MACH_CD,
                    V_MATNR,
                    V_IND_BCD,
                    V_M_SEQNO,
                    V_WRK_ORDR_NO,
                    V_WRK_ORDR_SEQNO,
                    V_LOT_NO,
                    V_IND_BCD_M,
                    V_LOT_NO_M,
                    V_MATNR_M,
                    V_INP_DT,
                    V_PRFM_DT,
                    V_ALLOC_QTY,
                    V_UNIT,
                    V_M_ROLLCNT,
                    V_ALLOC_QTY,
                    'N',
                    V_STCK_KY,
                    V_LOT_NUM,
                    V_DATE,
                    V_SESS_USER_ID,
                    '3',
                    'N'
                );


                /*---------------------------------------------------------------------
                 * USE_DIV='2': 실제 사용량 차감
                 *---------------------------------------------------------------------*/

                V_M_SEQNO := V_M_SEQNO + 1;

                INSERT INTO TB_INV010
                (
                    WERKS,
                    MACH_CD,
                    MATNR,
                    IND_BCD,
                    SEQNO,
                    WRK_ORDR_NO,
                    WRK_ORDR_SEQNO,
                    LOT_NO,
                    IND_BCD_M,
                    LOT_NO_M,
                    MATNR_M,
                    INP_DT,
                    PRFM_DT,
                    USE_QTY,
                    UNIT,
                    ROLLCNT,
                    WGT,
                    CHG_FLG,
                    STCK_KY,
                    LOT_NUM,
                    REGDATE,
                    REGID,
                    USE_DIV,
                    CNL_YN
                )
                VALUES
                (
                    V_WERKS,
                    V_MACH_CD,
                    V_MATNR,
                    V_IND_BCD,
                    V_M_SEQNO,
                    V_WRK_ORDR_NO,
                    V_WRK_ORDR_SEQNO,
                    V_LOT_NO,
                    V_IND_BCD_M,
                    V_LOT_NO_M,
                    V_MATNR_M,
                    V_INP_DT,
                    V_PRFM_DT,
                    0 - V_ALLOC_QTY,
                    V_UNIT,
                    V_M_ROLLCNT,
                    0 - V_ALLOC_QTY,
                    'N',
                    V_STCK_KY,
                    V_LOT_NUM,
                    V_DATE,
                    V_SESS_USER_ID,
                    '2',
                    'N'
                );


                SZP_MES_PLSQL_LOG(
                      'IND_BCD=' || V_IND_BCD
                   || ', AVAILABLE=' || TO_CHAR(R_USE.AVAIL_QTY)
                   || ', ALLOC=' || TO_CHAR(V_ALLOC_QTY)
                   || ', REMAIN='
                   || TO_CHAR(V_REMAIN_QTY - V_ALLOC_QTY),
                    'WRK10 폐품량 분배'
                );


                /* 아직 처리하지 못한 폐품량 */
                V_REMAIN_QTY := V_REMAIN_QTY - V_ALLOC_QTY;

            END LOOP;


	        /*=========================================================================
             * 4. 미배분 수량 검증
             *=========================================================================*/

            IF V_REMAIN_QTY > 0 THEN

                P_SUCCESS := 'N';
                P_ERR_MSG :=
                      '폐품량을 바코드별로 모두 배분하지 못했습니다.'
                   || ' 미배분 수량: ' || TO_CHAR(V_REMAIN_QTY);

                ROLLBACK;
                RETURN;

            END IF;

            --폐품이력
-- 	        'V_CHG_QTY: 사용량(TB_INV010.USE_QTY) // V_USE_QTY_DAY: 일일 사용량(TB_WRK001.PRFM_QTY) // V_DISPO_QTY: 실적수량(TB_WRK001.PRFM_QTY)'

            IF NVL(V_CHG_QTY, 0) > 0 THEN
                UPDATE TB_WRK016
                   SET DISPO_WGT = V_CHG_QTY,
                       CNL_YN = 'N'
                 WHERE WERKS = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND WRK_ORDR_NO = V_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                   AND LOT_NO_M = V_LOT_NO_M
                   AND MATNR_M = V_MATNR_M
                   AND IND_BCD_M = V_IND_BCD_M
                   AND PRFM_DT = V_PRFM_DT;
                
                IF SQL%ROWCOUNT =0 THEN
                    BEGIN
                    SELECT MAX(SEQNO) INTO V_SEQNO_H
                      FROM TB_WRK016
                     WHERE WERKS = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND WRK_ORDR_NO = V_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                       AND LOT_NO_M = V_LOT_NO_M
                       AND MATNR_M = V_MATNR_M;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            V_SEQNO_H := 0;
                    END ;
                    
                    V_SEQNO_H := NVL(V_SEQNO_H, 0) + 1;
                    
                    INSERT INTO TB_WRK016( WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO_M, MATNR_M, CNL_YN
                                        , IND_BCD_M, IND_BCD, LOT_NO, MATNR, ORDER_NO, PRFM_DT
                                        , DISPO_WGT, UNIT, REGDATE, REGID, DISPO_CD, DOC_NO, DOC_SEQNO, SEQNO)
                                    VALUES(V_WERKS, V_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_LOT_NO_M, V_MATNR_M, 'N'
                                        , V_IND_BCD_M, V_IND_BCD, V_LOT_NO, V_MATNR
                                        ,(SELECT ORDER_NO FROM TB_SCH012 WHERE WRK_ORDR_NO = V_WRK_ORDR_NO AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO)
                                        , V_PRFM_DT, V_CHG_QTY, V_UNIT, V_DATE, V_SESS_USER_ID, '101', '1', 1, V_SEQNO_H);
                END IF;
            END IF;


	        /* 폐품 변경에 따른 SAP 자재 사용량 취소(DOC3) 및 재등록(DOC4) */
-- 	        변화된 사용량 = 사용량 + 폐품량 - 폐품 보정량
--           800 200 0
-- 	        800 200 100 -> 900 100
--            사용량 + 기존 폐품량 - 폐품 보정량
-- 	        800 200 50 -> 950 50
-- 	        500 500 0 -> 500 500 600 -> 400 600
            V_USE_QTY_C := NVL(V_USE_QTY_DAY, 0)
                           + NVL(V_DISPO_QTY, 0)
                           - NVL(V_CHG_QTY, 0);

--             IF V_USE_QTY_DAY  < NVL(V_CHG_QTY, 0) THEN
--                 P_SUCCESS := 'N';
--                 P_ERR_MSG := '폐품 변경 후 사용량이 0보다 작아질 수 없습니다.';
--                 ROLLBACK;
--                 RETURN;
--             END IF;

            SELECT ORDER_NO
              INTO V_ORDER_NO
              FROM TB_SCH012
             WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;

            SELECT SAP_WRK_CD
              INTO V_SAP_WRK_CD
              FROM TB_MAS012
             WHERE MACH_CD = V_MACH_CD;

            SELECT CASE
                       WHEN MATNR_DIV IN ('FERT', 'HAWA') THEN '2000'
                       ELSE LGPRO
                   END
              INTO V_STOR_LOC_CD
              FROM TB_MAS001
             WHERE WERKS = V_WERKS
               AND MATNR = V_MATNR_M;


-- 	        INV013 원부자제 투입 이력에서 데이터 검색 플래그 처리
            V_INV013_EXISTS := 'N';

            V_DOC_NO := NULL;
            V_DOC_SEQNO := NULL;
            V_SDOC_NO := NULL;
            V_SDOC_SEQNO := NULL;

            BEGIN
                SELECT DOC_NO,
                       DOC_SEQNO,
                       SDOC_NO,
                       SDOC_SEQNO
                  INTO V_DOC_NO,
                       V_DOC_SEQNO,
                       V_SDOC_NO,
                       V_SDOC_SEQNO
                  FROM TB_INV013
                 WHERE WERKS = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND PRFM_DT = V_PRFM_DT
                   AND MATNR = V_MATNR_M
                   AND ORDER_NO = V_ORDER_NO
                   AND LOT_NO = V_LOT_NO_M;

                /* SELECT가 정상적으로 한 행을 찾은 경우에만 Y */
                V_INV013_EXISTS := 'Y';

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    NULL;
            END;

             SZP_MES_PLSQL_LOG(
                    'EXISTS=' || NVL(V_INV013_EXISTS, 'NULL')
                    || ', OLD=' || NVL(TO_CHAR(V_USE_QTY_DAY), 'NULL')
                    || ', NEW=' || NVL(TO_CHAR(V_USE_QTY_C), 'NULL')
                    || ', SDOC=' || NVL(V_SDOC_NO, 'NULL'),
                    'WRK10 DOC3 CHECK'
                );


            IF NVL(V_USE_QTY_DAY, 0) <> NVL(V_USE_QTY_C, 0) THEN


                /* SAP 확정문서가 있는 기존 사용량만 취소한다. */
                IF V_INV013_EXISTS = 'Y'
                   AND NVL(V_USE_QTY_DAY, 0) > 0
                   AND NVL(V_SDOC_NO, ' ') NOT IN (' ', 'E') 
                    THEN
                    P_CLOSE_YN := 'Y';

                    V_DOC_SEQNO_3 := V_DOC_SEQNO_3 + 1;

                    INSERT INTO TB_IFS014
                    (
                        AUFNR, POSNR, BUDAT, MATNR, MENGE, WERKS,
                        LGORT, CHARG, WORKCENTERCODE,
                        MDOCNO, MDOCSEQ, MBLNR, MJAHR,
                        ZRESULT, MAKE_DATE, MAKER
                    )
                    VALUES
                    (
                        V_ORDER_NO, '10', V_PRFM_DT, V_MATNR_M,
                        NVL(V_USE_QTY_DAY, 0), V_WERKS,
                        V_STOR_LOC_CD, REPLACE(V_LOT_NO_M, '*', ''), V_SAP_WRK_CD,
                        V_DOC_NO_3, TO_CHAR(V_DOC_SEQNO_3),
                        V_SDOC_NO, V_SDOC_SEQNO,
                        'N', V_DATE, V_SESS_USER_ID
                    );

                     /* 변경 후 사용량이 있으면 새 사용량 등록 자료를 만든다. */
                    IF NVL(V_USE_QTY_C, 0) > 0 THEN
                        V_DOC_SEQNO_4 := V_DOC_SEQNO_4 + 1;

                        INSERT INTO TB_IFS008
                        (
                            AUFNR, POSNR, BUDAT, MATNR, MENGE,
                            LGORT, CHARG, MDOCNO, MDOCSEQ,
                            ZRESULT, MAKE_DATE, MAKER,
                            WORKCENTERCODE, WERKS
                        )
                        VALUES
                        (
                            V_ORDER_NO, '10', V_PRFM_DT, V_MATNR_M, V_USE_QTY_C,
                            V_STOR_LOC_CD, REPLACE(V_LOT_NO_M, '*', ''),
                            V_DOC_NO_4, TO_CHAR(V_DOC_SEQNO_4),
                            'N', V_DATE, V_SESS_USER_ID,
                            V_SAP_WRK_CD, V_WERKS
                        );



                        /* 기존 TB_INV013 갱신 */
                        UPDATE TB_INV013
                           SET USE_QTY = V_USE_QTY_C,
                               UNIT = V_UNIT,
                               DOC_NO = V_DOC_NO_4,
                               DOC_SEQNO = V_DOC_SEQNO_4,
                               SDOC_NO = NULL,
                               SDOC_SEQNO = NULL
                         WHERE WERKS = V_WERKS
                           AND MACH_CD = V_MACH_CD
                           AND PRFM_DT = V_PRFM_DT
                           AND MATNR = V_MATNR_M
                           AND ORDER_NO = V_ORDER_NO
                           AND LOT_NO = V_LOT_NO_M;


                        /* 기존 자료가 없으면 신규 생성 */
                        IF SQL%ROWCOUNT = 0 THEN

                            INSERT INTO TB_INV013
                            (
                                WERKS,
                                MACH_CD,
                                PRFM_DT,
                                MATNR,
                                ORDER_NO,
                                LOT_NO,
                                USE_QTY,
                                UNIT,
                                DOC_NO,
                                DOC_SEQNO,
                                REGDATE,
                                REGID
                            )
                            VALUES
                            (
                                V_WERKS,
                                V_MACH_CD,
                                V_PRFM_DT,
                                V_MATNR_M,
                                V_ORDER_NO,
                                V_LOT_NO_M,
                                V_USE_QTY_C,
                                V_UNIT,
                                V_DOC_NO_4,
                                V_DOC_SEQNO_4,
                                V_DATE,
                                V_SESS_USER_ID
                            );
                        END IF;

                    ELSE
                        /*
                         * 변경 사용량이 0이면,
                         * DOC3 취소자료를 만든 후 TB_INV013 관리자료 제거
                         */
                        DELETE FROM TB_INV013
                         WHERE WERKS = V_WERKS
                           AND MACH_CD = V_MACH_CD
                           AND PRFM_DT = V_PRFM_DT
                           AND MATNR = V_MATNR_M
                           AND ORDER_NO = V_ORDER_NO
                           AND LOT_NO = V_LOT_NO_M;

                        P_CLOSE_YN := 'N';
                    END IF;
                END IF;


            END IF;

        END LOOP;
        
        --폐품 전송이력조회
        OPEN PROD_CUR FOR
            SELECT WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO, PRFM_DT, LOT_NO_M, MATNR_M, SUM(USE_QTY)
                   INTO 
                   V_WERKS, V_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_LOT_NO, V_PRFM_DT, V_LOT_NO_M, V_MATNR_M, V_USE_QTY_DAY
              FROM TB_INV010
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND WRK_ORDR_NO = V_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
               AND PRFM_DT = V_PRFM_DT
               AND USE_QTY > 0
               AND USE_DIV = '3'
               AND NVL(CNL_YN, 'N') = 'N'
            GROUP BY WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO, PRFM_DT, LOT_NO_M, MATNR_M;    
        LOOP
        FETCH PROD_CUR INTO V_WERKS, V_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_LOT_NO, V_PRFM_DT, V_LOT_NO_M, V_MATNR_M, 
                            V_USE_QTY_DAY;
        EXIT WHEN PROD_CUR %NOTFOUND; 
            
            SELECT SAP_WRK_CD INTO V_SAP_WRK_CD 
              FROM TB_MAS012
             WHERE MACH_CD = V_MACH_CD;
             
            V_FLG := 1;
             BEGIN
             SELECT DISPO_WGT, ORDER_NO, DOC_NO, DOC_SEQNO, SDOC_NO, SDOC_SEQNO
                    INTO 
                    V_DISPO_WGT_PRE, V_ORDER_NO, V_DOC_NO_PRE, V_DOC_SEQNO_PRE, V_SDOC_NO, V_SDOC_SEQNO
               FROM TB_WRK016_1
              WHERE WERKS = V_WERKS
                AND MACH_CD = V_MACH_CD
                AND WRK_ORDR_NO = V_WRK_ORDR_NO
                AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                AND LOT_NO = V_LOT_NO
                AND LOT_NO_M = V_LOT_NO_M
                AND MATNR_M = V_MATNR_M
                AND PRFM_DT = V_PRFM_DT
                AND NVL(CNL_YN, 'N') = 'N';
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_FLG := 0;
                    V_DISPO_WGT_PRE := 0;
             END;
             
            SELECT LGPRO INTO V_STOR_LOC_CD 
              FROM TB_MAS001
             WHERE WERKS = V_WERKS
               AND MATNR = V_MATNR_M;
            
            IF V_FLG > 0 THEN
                IF NVL(V_SDOC_NO, ' ') <> ' ' AND NVL(V_SDOC_NO, ' ') <> 'E' THEN   --전송이력이 있을 경우
                    --이전수량과 수정 수량이 다르면 폐품 취소
                    IF V_DISPO_WGT_PRE <> V_USE_QTY_DAY AND V_DISPO_WGT_PRE <> 0 THEN
                        V_DOC_SEQNO_2 := V_DOC_SEQNO_2 + 1;
                        
                        INSERT INTO TB_IFS022(WORKCENTERCODE, AUFNR, POSNR, BUDAT, MATNR,
                                MENGE, WERKS, LGORT, CHARG, 
                                MDOCNO, MDOCSEQ, MBLNR, MJAHR, ZRESULT, MAKE_DATE)
                          VALUES(V_SAP_WRK_CD, V_ORDER_NO, '10', V_PRFM_DT, V_MATNR_M,
                                V_DISPO_WGT_PRE, V_WERKS, V_STOR_LOC_CD, V_LOT_NO_M,
                                V_DOC_NO_2, TO_CHAR(V_DOC_SEQNO_2), V_SDOC_NO, V_SDOC_SEQNO, 'N', V_DATE);
                        
                        UPDATE TB_WRK016_1
                           SET CNL_YN = 'Y',
                               UPDDATE = V_DATE,
                               UPDID = V_SESS_USER_ID
                         WHERE WERKS = V_WERKS
                           AND MACH_CD = V_MACH_CD
                           AND WRK_ORDR_NO = V_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                           AND LOT_NO_M = V_LOT_NO_M
                           AND PRFM_DT = V_PRFM_DT;     
                   
                        UPDATE TB_WRK021
                           SET CNL_YN = 'Y'
                         WHERE DOC_NO = V_DOC_NO_PRE
                           AND DOC_SEQNO = V_DOC_SEQNO_PRE;
                    END IF;
                END IF;
            END IF;
            
            --사용량이 있으면 폐품등록
            IF NVL(V_USE_QTY_DAY, 0) > 0 AND (NVL(V_DISPO_WGT_PRE, 0) <> NVL(V_USE_QTY_DAY, 0)) AND NVL(V_USE_QTY_DAY, 0) <> 0 THEN
                
                SELECT ORDER_NO INTO V_ORDER_NO
                  FROM TB_SCH012
                 WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
                   
                V_DOC_SEQNO_1 := V_DOC_SEQNO_1 + 1;
                
                UPDATE TB_WRK016_1
                   SET DISPO_WGT = V_USE_QTY_DAY,
                       CNL_YN = 'N',
                       DOC_NO = V_DOC_NO_1,
                       DOC_SEQNO = V_DOC_SEQNO_1,
                       REGDATE = V_DATE,
                       REGID = V_SESS_USER_ID,
                       UPDDATE = V_DATE,
                       UPDID = V_SESS_USER_ID,
                       ORDER_NO = V_ORDER_NO
                 WHERE WERKS = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND WRK_ORDR_NO = V_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                   AND LOT_NO_M = V_LOT_NO_M
--                   AND DOC_NO = V_DOC_NO_PRE
--                   AND DOC_SEQNO = V_DOC_SEQNO_PRE
                   AND PRFM_DT = V_PRFM_DT;     
                 
                IF SQL%ROWCOUNT = 0 THEN
                     
                     INSERT INTO TB_WRK016_1(WERKS, PRFM_DT, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO, LOT_NO_M, MATNR_M, CNL_YN,
                                DISPO_WGT, UNIT,
                                DOC_NO, DOC_SEQNO, REGDATE, REGID, DISPO_CD, ORDER_NO)
                        VALUES( V_WERKS, V_PRFM_DT, V_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_LOT_NO, V_LOT_NO_M, V_MATNR_M, 'N',
                                V_USE_QTY_DAY, V_UNIT,
                                V_DOC_NO_1, V_DOC_SEQNO_1, V_DATE, V_SESS_USER_ID, '101', V_ORDER_NO);        
                END IF;
                
                INSERT INTO TB_IFS012(AUFNR, LOTNO, BUDAT, MATNR, SCRQTY, RSDQTY , SCRAPCODE, SCRAPREASON,
                                    LGORT, CHARG, SDATE, STIME, EDATE, ETIME, 
                                    MDOCNO, MDOCSEQ, ZRESULT, MAKE_DATE, MAKER, WORKCENTERCODE)
                            VALUES(V_ORDER_NO, V_LOT_NO, V_PRFM_DT, V_MATNR_M, V_USE_QTY_DAY, 0, '101', '합지폐품',
                                    V_STOR_LOC_CD, V_LOT_NO_M, V_SDATE, V_STIME, V_EDATE, V_ETIME, 
                                    V_DOC_NO_1, V_DOC_SEQNO_1, 'N', V_DATE, V_SESS_USER_ID, V_SAP_WRK_CD);        
            
                 INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD,
                                    WRK_ORDR_NO, WRK_ORDR_SEQNO, IND_BCD, LOT_NO, ORDER_NO, CNL_YN, REGDATE, REGID)
                              VALUES(V_DOC_NO_1, V_DOC_SEQNO_1, '2', V_WERKS, V_MACH_CD,
                                   V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_IND_BCD, V_LOT_NO, V_ORDER_NO, 'N',
                                   V_DATE, V_SESS_USER_ID);    
                 
            END IF;
        END LOOP;
        CLOSE PROD_CUR; 
                                       
        IF V_DOC_SEQNO_1 > 0 THEN
            P_DOC_NO1 := V_DOC_NO_1;
            PKG_WRK055.LOG_DOC('SP_WRK10_S01', V_WERKS, V_DOC_NO_1, V_SESS_USER_ID);   -- WRK55 RFC 전송로그
        END IF;
        
        IF V_DOC_SEQNO_2 > 0 THEN
            P_DOC_NO2 := V_DOC_NO_2;
            PKG_WRK055.LOG_DOC('SP_WRK10_S01', V_WERKS, V_DOC_NO_2, V_SESS_USER_ID);   -- WRK55 RFC 전송로그
        END IF;

        IF V_DOC_SEQNO_3 > 0 THEN
            P_DOC_NO3 := V_DOC_NO_3;
            PKG_WRK055.LOG_DOC('SP_WRK10_S01', V_WERKS, V_DOC_NO_3, V_SESS_USER_ID);   -- WRK55 RFC 전송로그
        END IF;

        IF V_DOC_SEQNO_4 > 0 THEN
            P_DOC_NO4 := V_DOC_NO_4;
            PKG_WRK055.LOG_DOC('SP_WRK10_S01', V_WERKS, V_DOC_NO_4, V_SESS_USER_ID);   -- WRK55 RFC 전송로그
        END IF;
        
    ELSIF P_TYPE = 'DELETE' THEN          --폐품 취소
        V_WERKS 		            := V_JSON.get_string('WERKS');			    --플랜트코드
        V_PRFM_DT 		            := V_JSON.get_string('PRFM_DT');			    --실적일자

        V_ARR_LIST2                 := TREAT (V_JSON.get ('head') AS json_object_t);
        V_OBJ			            := TREAT (V_ARR_LIST2.get ('map') AS json_object_t);

        V_MACHINE 		            := V_OBJ.get_string('MACHINE');			    --생산호기
        V_WRK_ORDR_NO 		        := V_OBJ.get_string('WRK_ORDR_NO');			--작업지시번호
        V_WRK_ORDR_SEQNO 		    := V_OBJ.get_string('WRK_ORDR_SEQNO');		--작업지시 순번

        V_DOC_NO_1 := FN_GET_MDOCNO('M','IF144');
        V_DOC_SEQNO_1 := 0;

        V_ARR_LIST                  := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ						:= TREAT (V_ARR_LIST.get (i) AS json_object_t);  
            V_OBJ						:= TREAT (V_OBJ.get ('map') AS json_object_t);

			V_LOT_NO_M                  := V_OBJ.get_string('LOT_NO_M');		--합지LOT NO
            V_MATNR_M                   := V_OBJ.get_string('MATNR_M');		    --합지자재코드
            V_PRFM_QTY_M                := V_OBJ.get_string('PRFM_QTY');		--합지 LOT별 생산량
            V_UNIT                      := V_OBJ.get_string('UNIT');		    --단위
            V_USE_QTY_DAY                 := V_OBJ.get_string('USE_QTY');		    --사용량
            V_DISPO_QTY                 := V_OBJ.get_string('SCRAP_QTY');		--폐품량
            V_COM_YN 		            := V_OBJ.get_string('COM_YN');			--생산완료여부

            V_DOC_SEQNO_1 := V_DOC_SEQNO_1 + 1;

            SELECT MACH_CD, SAP_WRK_CD INTO V_MACH_CD, V_SAP_WRK_CD 
              FROM TB_MAS012
             WHERE MACHINE LIKE SUBSTR(V_MACHINE, 1, 3) || '%'
               AND PROC_CD = 'RA';

            SELECT ORDER_NO, PRFM_DT, DISPO_WGT, DOC_NO, DOC_SEQNO, SDOC_NO, SDOC_SEQNO
                INTO V_ORDER_NO, V_PRFM_DT, V_DISPO_WGT, V_DOC_NO, V_DOC_SEQNO, V_SDOC_NO, V_SDOC_SEQNO
              FROM TB_WRK016
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND WRK_ORDR_NO = V_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
               AND LOT_NO_M = V_LOT_NO_M
               AND NVL(CNL_YN, 'N') = 'N';

            --재고 증가
            OPEN PROD_CUR FOR
                SELECT MATNR, IND_BCD, LOT_NO, MATNR_M, IND_BCD_M, INP_DT, USE_QTY, ROLLCNT, WGT, CHG_FLG, STCK_KY, LOT_NUM, PCNT
                    INTO V_MATNR, V_IND_BCD, V_LOT_NO, V_MATNR_M, V_M_IND_BCD_M, V_M_INP_DT, V_M_STCK_QTY, V_M_ROLLCNT, V_M_WGT, V_M_CHG_FLG, V_M_STCK_KY, V_M_LOT_NUM, V_REM_QTY
                  FROM TB_INV010
                 WHERE WERKS = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND WRK_ORDR_NO =  V_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO =  V_WRK_ORDR_SEQNO
                   AND LOT_NO_M = V_LOT_NO_M
                   AND USE_DIV = '3'
                   AND NVL(CNL_YN, 'N') = 'N';
            LOOP
            FETCH PROD_CUR INTO V_MATNR, V_IND_BCD, V_LOT_NO, V_MATNR_M, V_M_IND_BCD_M, V_M_INP_DT, V_M_STCK_QTY, V_M_ROLLCNT, V_M_WGT, V_M_CHG_FLG, V_M_STCK_KY, V_M_LOT_NUM, V_REM_QTY;
            EXIT WHEN PROD_CUR %NOTFOUND;   
                BEGIN
                SELECT MAX(SEQNO) INTO V_M_SEQNO
                  FROM TB_INV010
                 WHERE WERKS = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND MATNR = V_MATNR
                   AND IND_BCD = V_IND_BCD;
                  -- AND IND_BCD_M = V_M_IND_BCD_M;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_M_SEQNO := 0;
                END;

                IF V_M_STCK_QTY > 0 THEN
                    UPDATE TB_INV010
                       SET CNL_YN = 'Y',
                           UPDDATE = V_DATE,
                           UPDID = V_SESS_USER_ID
                     WHERE WERKS = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND MATNR = V_MATNR
                       AND IND_BCD = V_IND_BCD
                       AND IND_BCD_M = V_M_IND_BCD_M
                       AND USE_DIV = '3';

                    V_M_SEQNO := V_M_SEQNO + 1;
                    INSERT INTO TB_INV010(WERKS, MACH_CD, MATNR, IND_BCD, SEQNO,
                                        WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO,
                                        IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, PRFM_DT,
                                        USE_QTY, UNIT, ROLLCNT, WGT, CHG_FLG,
                                        STCK_KY, LOT_NUM, REGDATE, REGID, USE_DIV, CNL_YN)
                                VALUES(V_WERKS, V_MACH_CD, V_MATNR, V_IND_BCD, V_M_SEQNO,
                                       V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_LOT_NO,
                                       V_M_IND_BCD_M, V_LOT_NO_M, V_MATNR_M, V_M_INP_DT, V_M_INP_DT,
                                       V_M_STCK_QTY, V_UNIT, 0, V_M_STCK_QTY, 'N',
                                       V_M_STCK_KY, V_M_LOT_NUM, V_DATE, V_SESS_USER_ID, '2', 'N');
                END IF;

                IF V_REM_QTY > 0 THEN
                    V_M_SEQNO := V_M_SEQNO + 1;
                    INSERT INTO TB_INV010(WERKS, MACH_CD, MATNR, IND_BCD, SEQNO,
                                        WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO,
                                        IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, PRFM_DT,
                                        USE_QTY, UNIT, ROLLCNT, WGT, CHG_FLG,
                                        STCK_KY, LOT_NUM, REGDATE, REGID, USE_DIV, CNL_YN)
                                VALUES(V_WERKS, V_MACH_CD, V_MATNR, V_IND_BCD, V_M_SEQNO,
                                       V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_LOT_NO,
                                       V_M_IND_BCD_M, V_LOT_NO_M, V_MATNR_M, V_M_INP_DT, V_M_INP_DT,
                                       (0 - V_REM_QTY), V_UNIT, 0, (0 - V_REM_QTY), 'N',
                                       V_M_STCK_KY, V_M_LOT_NUM, V_DATE, V_SESS_USER_ID, '2', 'N');
                END IF;

                --재고생성
                SELECT STCK_STA INTO V_M_STCK_STA
                  FROM TB_INV001
                 WHERE WERKS = V_WERKS
                   AND IND_BCD = V_M_IND_BCD_M;

                IF V_M_STCK_STA = '00' THEN
                    UPDATE TB_INV001
                       SET STCK_QTY = V_M_STCK_QTY
                     WHERE WERKS = V_WERKS
                       AND IND_BCD = V_M_IND_BCD_M;   
                ELSE
                    UPDATE TB_INV003
                       SET USE_QTY = USE_QTY - V_M_STCK_QTY,
                           STCK_QTY = STCK_QTY +  V_M_STCK_QTY
                     WHERE WERKS = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND IND_BCD = V_M_IND_BCD_M;  

                    IF SQL%ROWCOUNT =0 THEN    
                        SELECT SUM(USE_QTY)  INTO V_T_USE_QTY
                          FROM TB_INV010
                         WHERE WERKS = V_WERKS
                           AND MACH_CD = V_MACH_CD
                           AND IND_BCD_M = V_M_IND_BCD_M
                           AND USE_QTY > 0
                           AND NVL(CNL_YN, 'N') = 'N';

                        BEGIN
                        SELECT NVL(MAX(SEQNO), 0)
					  	   INTO V_M_SEQNO
					  	   FROM TB_INV003
					 	  WHERE WERKS = V_WERKS
                       		AND MACH_CD = V_MACH_CD
                       		AND MATNR = V_MATNR_M;
                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                V_M_SEQNO := 0;
                        END ;
                        V_M_SEQNO := V_M_SEQNO + 1;

                        INSERT INTO TB_INV003(WERKS, MACH_CD, MATNR, IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                            LOT_NO, INP_DT, IN_QTY, USE_QTY, STCK_QTY, UNIT, ROLLCNT, WGT,
                                            CHG_FLG, STCK_KY, LOT_NUM, REGDATE, REGID)
                                    VALUES(V_WERKS, V_MACH_CD, V_MATNR_M, V_M_IND_BCD_M, V_M_SEQNO, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                            V_LOT_NO_M, V_M_INP_DT, V_T_USE_QTY, V_T_USE_QTY - V_M_STCK_QTY, V_T_USE_QTY -(V_T_USE_QTY - V_M_STCK_QTY),
                                            V_UNIT, V_M_ROLLCNT, V_M_STCK_QTY,
                                            V_M_CHG_FLG, V_M_STCK_KY, V_M_LOT_NUM, V_DATE, V_SESS_USER_ID);
                    END IF;

                END IF;

                --취소처리
                UPDATE TB_INV010
                   SET CNL_YN = 'Y',
                       UPDDATE = V_DATE,
                       UPDID = V_SESS_USER_ID
                 WHERE WERKS = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND WRK_ORDR_NO =  V_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO =  V_WRK_ORDR_SEQNO
                   AND LOT_NO_M = V_LOT_NO_M
                   AND USE_DIV = '3'
                   AND NVL(CNL_YN, 'N') = 'N';

            END LOOP;
            CLOSE PROD_CUR; 

            SELECT LGPRO INTO V_STOR_LOC_CD 
              FROM TB_MAS001
             WHERE WERKS = V_WERKS
               AND MATNR = V_MATNR_M;

            INSERT INTO TB_IFS022(WORKCENTERCODE, AUFNR, POSNR, BUDAT, MATNR,
                                MENGE, WERKS, LGORT, CHARG, 
                                MDOCNO, MDOCSEQ, MBLNR, MJAHR, ZRESULT, MAKE_DATE)
                          VALUES(V_SAP_WRK_CD, V_ORDER_NO, '10', V_PRFM_DT, V_MATNR_M,
                                V_DISPO_WGT, V_WERKS, V_STOR_LOC_CD, V_LOT_NO_M,
                                V_DOC_NO_1, TO_CHAR(V_DOC_SEQNO_1), V_SDOC_NO, V_SDOC_SEQNO, 'N', V_DATE);
            --폐품이력 취소
            UPDATE TB_WRK016
               SET CNL_YN = 'Y',
                   UPDDATE = V_DATE,
                   UPDID = V_SESS_USER_ID
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND WRK_ORDR_NO = V_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
               AND LOT_NO_M = V_LOT_NO_M
               AND NVL(CNL_YN, 'N') = 'N';

            --문서이력 취소
            UPDATE TB_WRK021
               SET CNL_YN = 'Y'
             WHERE DOC_NO = V_DOC_NO
               AND DOC_SEQNO = V_DOC_SEQNO;

        END LOOP;

        IF V_DOC_SEQNO_1 > 0 THEN
            P_DOC_NO1 := V_DOC_NO_1;
            PKG_WRK055.LOG_DOC('SP_WRK10_S01', V_WERKS, V_DOC_NO_1, V_SESS_USER_ID);   -- WRK55 RFC 전송로그
        END IF;
    ELSIF P_TYPE = 'ROLLBACK1' THEN         --폐품실적 취소 오류 시 롤백 (취소 롤백)
        V_ARR_LIST2                 := TREAT (V_JSON.get ('head') AS json_object_t);
        V_OBJ			            := TREAT (V_ARR_LIST2.get ('map') AS json_object_t);
        
        V_ARR_LIST                  := V_JSON.get_array('list');

        V_DOC_NO_1					:= V_JSON.get_string('DOC_NO_1');		    	-- 롤백을 위한 문서번호1
        V_DOC_SEQNO_1				:= TO_NUMBER(V_JSON.get_string('DOC_SEQ_1'));	-- 롤백을 위한 문서순번1
        V_DOC_NO_2					:= V_JSON.get_string('DOC_NO_1');				-- 롤백을 위한 문서번호2
        V_DOC_SEQNO_2				:= TO_NUMBER(V_JSON.get_string('DOC_SEQ_2'));	-- 롤백을 위한 문서순번2

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP

	        V_OBJ						:= TREAT (V_ARR_LIST.get (i) AS json_object_t);  
            V_OBJ						:= TREAT (V_OBJ.get ('map') AS json_object_t);

			V_WERKS                     := V_OBJ.get_string('WERKS');		    --플랜트
            V_WRK_ORDR_NO               := V_OBJ.get_string('WRK_ORDR_NO');		--작업지시번호
            V_WRK_ORDR_SEQNO            := V_OBJ.get_string('WRK_ORDR_SEQNO');	--작업지시순번
            V_MACH_CD                   := V_OBJ.get_string('MACH_CD');	        --설비코드
            V_LOT_NO_M                  := V_OBJ.get_string('LOT_NO_M');		--합지LOT NO
            V_IND_BCD_M                 := V_OBJ.get_string('IND_BCD_M');		--합지 개별바코드
            V_MATNR_M                   := V_OBJ.get_string('MATNR_M');		    --합지자재코드
            V_PRFM_QTY_M                := NVL(V_OBJ.get_string('PRFM_QTY'), 0);--합지 LOT별 생산량
            V_UNIT                      := V_OBJ.get_string('UNIT');		    --단위
            V_USE_QTY_DAY                 := NVL(V_OBJ.get_string('USE_QTY_DAY'), 0);	--사용량
            V_DISPO_QTY                 := NVL(TRIM(V_OBJ.get_string('SCRAP_QTY')), 0);		--폐품량
            V_CHG_QTY                   := NVL(V_OBJ.get_string('SCRAP_CHG_QTY'), 0);	--폐품보정 수정
            V_PRFM_DT 		            := V_OBJ.get_string('PRFM_DT');			--실적일자
            
            --기존이력 삭제 취소
            IF NVL(V_DISPO_QTY, 0) <> 0 THEN
				-- 변경 입력된 사용량 삭제 처리
				DELETE TB_INV010
				WHERE  WERKS	= V_WERKS
				AND MACH_CD = V_MACH_CD
				AND WRK_ORDR_NO = V_WRK_ORDR_NO
				AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
				AND IND_BCD_M = V_IND_BCD_M
				AND LOT_NO_M = V_LOT_NO_M
				AND PRFM_DT = V_PRFM_DT
				AND USE_DIV = '2'
				AND USE_QTY = V_DISPO_QTY
				AND NVL(CNL_YN, 'N') = 'N';

				-- 취소 Flag 원복
				UPDATE	TB_INV010
					SET	CNL_YN	= 'N',
						UPDDATE	= V_DATE,
						UPDID	= V_SESS_USER_ID
				WHERE 	WERKS	= V_WERKS
				AND MACH_CD = V_MACH_CD
				AND WRK_ORDR_NO = V_WRK_ORDR_NO
				AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
				AND IND_BCD_M = V_IND_BCD_M
				AND LOT_NO_M = V_LOT_NO_M
				AND PRFM_DT = V_PRFM_DT
				AND USE_DIV = '3'
				AND	NVL(CNL_YN, 'N') = 'Y';
			
				UPDATE TB_WRK016
				    SET CNL_YN = 'N',			-- 취소 Flag 원복
				       DISPO_WGT = V_CHG_QTY,		-- 변경된폐품수량을 원복
				       UPDDATE = V_DATE,
				       UPDID = V_SESS_USER_ID
				WHERE WERKS = V_WERKS
				AND MACH_CD = V_MACH_CD
				AND WRK_ORDR_NO = V_WRK_ORDR_NO
				AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
				AND LOT_NO_M = V_LOT_NO_M
				AND MATNR_M = V_MATNR_M
				AND IND_BCD_M = V_IND_BCD_M
				AND PRFM_DT = V_PRFM_DT   
				AND	NVL(CNL_YN, 'N') = 'Y';

			END IF;

			-- 새롭게 입력된 폐품 데이터 삭제
			DELETE	TB_INV010
			WHERE	WERKS = V_WERKS
			AND		MACH_CD = V_MACH_CD
			AND 	MATNR_M = V_MATNR_M
			AND 	WRK_ORDR_NO = V_WRK_ORDR_NO
			AND 	WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
			AND 	IND_BCD_M = V_IND_BCD_M
			AND 	PRFM_DT = V_PRFM_DT
			AND 	NVL(CNL_YN, 'N') = 'N'
			AND 	USE_DIV = '3'
			AND 	USE_QTY = V_CHG_QTY;

			-- 새롭게 입력된 사용량 데이터 삭제
			DELETE	TB_INV010
			WHERE	WERKS = V_WERKS
			AND		MACH_CD = V_MACH_CD
			AND 	MATNR_M = V_MATNR_M
			AND 	WRK_ORDR_NO = V_WRK_ORDR_NO
			AND 	WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
			AND 	IND_BCD_M = V_IND_BCD_M
			AND 	PRFM_DT = V_PRFM_DT
			AND 	NVL(CNL_YN, 'N') = 'N'
			AND 	USE_DIV = '2'
			AND 	USE_QTY = (0 - V_CHG_QTY);

			V_M_SEQNO := V_M_SEQNO + 1;
            INSERT INTO TB_INV010(WERKS, MACH_CD, MATNR, IND_BCD, SEQNO,
                                WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO,
                                IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, PRFM_DT,
                                USE_QTY, UNIT, ROLLCNT, WGT, CHG_FLG,
                                STCK_KY, LOT_NUM, REGDATE, REGID, USE_DIV, CNL_YN)
                        VALUES(V_WERKS, V_MACH_CD, V_MATNR, V_IND_BCD, V_M_SEQNO,
                               V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_LOT_NO,
                               V_IND_BCD_M, V_LOT_NO_M, V_MATNR_M, V_INP_DT, V_PRFM_DT,
                               V_CHG_QTY, V_UNIT, V_M_ROLLCNT, V_CHG_QTY, 'N',
                               V_STCK_KY, V_LOT_NUM, V_DATE, V_SESS_USER_ID, '3', 'N');
            
            V_M_SEQNO := V_M_SEQNO + 1;
            INSERT INTO TB_INV010(WERKS, MACH_CD, MATNR, IND_BCD, SEQNO,
                                WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO,
                                IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, PRFM_DT,
                                USE_QTY, UNIT, ROLLCNT, WGT, CHG_FLG,
                                STCK_KY, LOT_NUM, REGDATE, REGID, USE_DIV, CNL_YN)
                        VALUES(V_WERKS, V_MACH_CD, V_MATNR, V_IND_BCD, V_M_SEQNO,
                               V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_LOT_NO,
                               V_IND_BCD_M, V_LOT_NO_M, V_MATNR_M, V_INP_DT, V_PRFM_DT,
                               0 - V_CHG_QTY, V_UNIT, V_M_ROLLCNT, 0 - V_CHG_QTY, 'N',
                               V_STCK_KY, V_LOT_NUM, V_DATE, V_SESS_USER_ID, '2', 'N');
        END LOOP;
	ELSIF P_TYPE = 'ROLLBACK2' THEN
		-- 폐품실적 등록 오류 시 롤백 (취소, 등록 모두 롤백) ROLLBACK2를 호출 한 후 ROLLBACK1을 호출한다
		-- 폐품취소는 되돌릴 수 가 없음. 어떻게 살리는지?

        
        --폐품 전송이력조회
        OPEN PROD_CUR FOR
            SELECT WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO, PRFM_DT, LOT_NO_M, MATNR_M, SUM(USE_QTY)
                   INTO 
                   V_WERKS, V_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_LOT_NO, V_PRFM_DT, V_LOT_NO_M, V_MATNR_M, V_USE_QTY_DAY
              FROM TB_INV010
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND WRK_ORDR_NO = V_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
               AND PRFM_DT = V_PRFM_DT
               AND USE_QTY > 0
               AND USE_DIV = '3'
               AND NVL(CNL_YN, 'N') = 'N'
            GROUP BY WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO, PRFM_DT, LOT_NO_M, MATNR_M;

        LOOP
        FETCH PROD_CUR INTO V_WERKS, V_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_LOT_NO, V_PRFM_DT, V_LOT_NO_M, V_MATNR_M, V_USE_QTY_DAY;
        EXIT WHEN PROD_CUR %NOTFOUND; 
            
            SELECT SAP_WRK_CD INTO V_SAP_WRK_CD 
              FROM TB_MAS012
             WHERE MACH_CD = V_MACH_CD;
             
            V_FLG := 1;
             BEGIN
             SELECT DISPO_WGT, ORDER_NO, DOC_NO, DOC_SEQNO, SDOC_NO, SDOC_SEQNO
                    INTO 
                    V_DISPO_WGT_PRE, V_ORDER_NO, V_DOC_NO_PRE, V_DOC_SEQNO_PRE, V_SDOC_NO, V_SDOC_SEQNO
               FROM TB_WRK016_1
              WHERE WERKS = V_WERKS
                AND MACH_CD = V_MACH_CD
                AND WRK_ORDR_NO = V_WRK_ORDR_NO
                AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                AND LOT_NO = V_LOT_NO
                AND LOT_NO_M = V_LOT_NO_M
                AND MATNR_M = V_MATNR_M
                AND PRFM_DT = V_PRFM_DT
                AND NVL(CNL_YN, 'N') = 'N';
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_FLG := 0;
                    V_DISPO_WGT_PRE := 0;
             END;
             
            SELECT LGPRO INTO V_STOR_LOC_CD 
              FROM TB_MAS001
             WHERE WERKS = V_WERKS
               AND MATNR = V_MATNR_M;
            
            -- 폐품취소 전송 데이터 삭제
            DELETE	TB_IFS022
            WHERE	BUDAT = V_PRFM_DT
            AND		WERKS = V_WERKS
            AND		MBLNR = V_SDOC_NO
            AND		MJAHR = V_SDOC_SEQNO
            AND		MDOCNO = V_DOC_NO_PRE
            AND		MDOCSEQ = V_DOC_SEQNO_PRE;

            -- 폐품 테이블 UPDATE
            UPDATE	TB_WRK016_1
            SET		CNL_YN = 'N',
            		UPDDATE = V_DATE,
            		UPDID = V_SESS_USER_ID
            WHERE	WERKS = V_WERKS
            AND MACH_CD = V_MACH_CD
            AND WRK_ORDR_NO = V_WRK_ORDR_NO
            AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
            AND LOT_NO_M = V_LOT_NO_M
            AND PRFM_DT = V_PRFM_DT;

			-- 문서이력 테이블 UPDATE
            UPDATE 	TB_WRK021
            SET		CNL_YN = 'N'
            WHERE DOC_NO = V_DOC_NO_PRE
            AND	DOC_SEQNO = V_DOC_SEQNO_PRE;
        END LOOP;
        CLOSE PROD_CUR; 
    END IF;


    P_SUCCESS := 'Y';
    COMMIT;

--    EXCEPTION
--    WHEN E_EXCEPTION_USER THEN
--
--        -- 에러 내역 SET
--	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := SQLCODE;
--        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);
--
--        ROLLBACK;
--        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
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
