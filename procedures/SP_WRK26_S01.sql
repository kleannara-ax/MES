
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK26_S01" 
(
    P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
    P_ERR_MSG       OUT    VARCHAR2,
	P_DOC_NO1        OUT    VARCHAR2,
    P_RS_LIST       OUT    SYS_REFCURSOR
)
AS 
/*==============================================================================
 * PROGRAM ID    : WRK26{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 점보롤 실적조회{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술} 
 * DESCRIPTION   : 점보롤 실적조회{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 유상호{최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/24 {최초 작성일자 기술}
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
    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK26_S01';     -- PROCEDURE NAME

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
    V_WERKS             TB_WRK002.WERKS%TYPE;        -- 플랜트코드
    V_SDATE             VARCHAR2(10);
    V_EDATE             VARCHAR2(10);
    V_MACHINE           VARCHAR2(5);
    V_RUN_STA           TB_WRK002.RUN_STA%TYPE;    
    V_PRD_DT            TB_WRK002.PRD_DT%TYPE;    
    V_PRFM_DT           TB_WRK002.PRFM_DT%TYPE;
    V_NAUFNR            TB_WRK002.ORDER_NO%TYPE;                --비계획생산오더번호
    V_WRK_ORDR_NO       TB_SCH015.WRK_ORDR_NO%TYPE;         
    V_WRK_ORDR_SEQNO    TB_SCH015.WRK_ORDR_SEQNO%TYPE;      
    V_WRK_ORDR_NO_NEW       TB_SCH015.WRK_ORDR_NO%TYPE;         --비계획생산오더에 대한 신규 작업지시번호
    V_WRK_ORDR_SEQNO_NEW    TB_SCH015.WRK_ORDR_SEQNO%TYPE;      --비계획생산오더에 대한 작업지시번호 순번
    V_WRK_ORDR_NO_FR       TB_SCH015.WRK_ORDR_NO%TYPE;         --변경전 작업지시 번호
    V_WRK_ORDR_SEQNO_FR    TB_SCH015.WRK_ORDR_SEQNO%TYPE;      --변경전 작업지시 순번
    V_ORDER_NO_NEW          TB_SCH015.ORDER_NO%TYPE;            --비계획생산오더에 대한 신규 오더번호
    V_LOT_NO_BUF            TB_SCH015.LOT_NO_BUF%TYPE;          --비계획생산오더에 대한 LOT NO
--    V_DOC_NO                VARCHAR2(20);
--    V_DOC_SEQNO             NUMBER;
    V_DOC_NO_1                TB_WRK002.DOC_NO%TYPE;
    V_DOC_SEQNO_1             NUMBER;
    V_DOC_NO_FR                VARCHAR2(20);
    V_DOC_SEQNO_FR             NUMBER;
    V_ORDER_NO              TB_WRK002.ORDER_NO%TYPE;
    V_MACH_CD               TB_WRK002.MACH_CD%TYPE;
    V_IND_BCD               TB_WRK002.IND_BCD%TYPE;
    V_MATNR                 TB_WRK002.MATNR%TYPE;
    V_MATNR_NEW             TB_WRK002.MATNR%TYPE;
    V_LOT_NO                TB_WRK002.LOT_NO%TYPE;
    V_LOT_NO_NEW            TB_WRK002.LOT_NO%TYPE;
    V_CHARG_FR              TB_WRK002.LOT_NO%TYPE;
    V_CHARG_TO              TB_WRK002.LOT_NO%TYPE;
    V_UNIT                  TB_WRK002.UNIT%TYPE;
    V_LOT_CHG_YN            TB_WRK002.LOT_CHG_YN%TYPE;
    V_PRD_STR_DT            VARCHAR2(20);
    V_MOVE_DIV              VARCHAR2(10);
    V_WERKS_FR              TB_WRK002.WERKS%TYPE;
    V_WERKS_TO              TB_WRK002.WERKS%TYPE;
    V_MATNR_FR              TB_WRK002.MATNR%TYPE;
    V_MATNR_TO              TB_WRK002.MATNR%TYPE;
    V_STOR_LOC_FR           TB_INV001.STOR_LOC_CD%TYPE;
    V_STOR_LOC_TO           TB_INV001.STOR_LOC_CD%TYPE;
    V_PRFM_QTY              TB_WRK002.PRFM_QTY%TYPE;
    V_DOC_DIV               NUMBER;
    V_STA                   TB_WRK002.STA%TYPE;
    V_CNL_YN                TB_WRK002.CNL_YN%TYPE;
    V_PRFM_ROLLCNT          VARCHAR2(20);
    V_PRFM_WGT              VARCHAR2(20);
    V_DISPO_ROLLCNT         VARCHAR2(20);
    V_DISPO_WGT             VARCHAR2(20);
    V_DISPO_CD              VARCHAR2(20);
    V_SDOC_NO               TB_WRK002.SDOC_NO%TYPE;
    V_SDOC_SEQNO            TB_WRK002.SDOC_SEQNO%TYPE;
    V_SAP_WRK_CD            TB_MAS012.SAP_WRK_CD%TYPE;
    V_DATE                  DATE := SYSDATE;
    V_BUDAT					TB_IFS009.BUDAT%TYPE;
BEGIN
    OPEN P_RS_LIST FOR 
    SELECT NULL FROM DUAL WHERE ROWNUM = 0;

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);
    V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=       V_JSON.get_string('SES_WAREKY');

    /* 조건값 할당 */
    V_RANGE_SQL          :=       V_JSON.get_string('RANGE_SQL');                   -- 작업지시 조회 시 일자

    V_WERKS             :=  'P100';
    V_MACHINE           :=       V_JSON.get_string('MACHINE');                  -- 호기
    V_SDATE             :=       V_JSON.get_string('SDATE');                    -- 생산실적일(시작)
    V_EDATE             :=       V_JSON.get_string('EDATE');                    -- 생산실적일(종료)
    V_RUN_STA           :=       V_JSON.get_string('RUN_STA');                  -- 운전상태(01: 정상, 09: 비계획생산
    V_CNL_YN			:=		 V_JSON.get_string('CNL_YN');					--취소여부
--    V_MACH_CD           :=       V_JSON.get_string('MACH_CD');                     -- 설비코드

    V_MATNR             :=       V_JSON.get_string('MATNR');                       -- 자재코드
    V_ORDER_NO			:=		V_JSON.get_string('ORDER_NO');					--오더번호
--    V_CHK_PP_YN         :=       V_JSON.get_string('CHK_PP_YN');                   -- 생산확인여부(Y/N)
--    V_CHK_QC_YN         :=       V_JSON.get_string('CHK_QC_YN');                   -- 품질확인여부(Y/N)

    IF P_TYPE = 'LIST' THEN /*업체/개별바코드 조회 리스트*/
        V_SQL := ' SELECT DISTINCT
                         W000.WERKS                       WERKS                       --플랜트
                        ,W000.WRK_ORDR_NO                 WRK_ORDR_NO                 --작업지시번호                    
                        ,W000.WRK_ORDR_SEQNO              WRK_ORDR_SEQNO              --작업지시순번
                        ,W000.MACHINE                     MACHINE                     --생산호기 
                        ,M000.PROC_NM                     PROC_NM                     --공정명
                        ,M000.MACH_CD                     MACH_CD                     --설비코드
                        ,M000.MACH_NM                     MACH_NM                     --설비명 
                        ,W000.PRD_STR_DATE                PRD_STR_DATE                --시작시간 
                        ,W000.PRD_END_DATE                PRD_END_DATE                --종료시간
						,W000.TM						  TM						  --생산시간(분)
                        ,W000.WRK_CLASS                   WRK_CLASS                   --작업반
                        --S015.PCODE,
                        ,M001.PCODE_NM                    PCODE_NM                    --기종명
                        ,M001.BS_WGT                      BS_WGT                      --평량
                        ,S015.PRDTYPETXT                  PRDTYPETXT                  --생산라인구분명 
                        ,W000.RSPEED                      RSPEED                      --선속
                        ,W000.LOT_NO                      LOT_NO                        --LOT NO 
                        ,W000.IND_BCD                   IND_BCD                       --개별바코드
                        --,W000.RUN_STA                   RUN_STA                       --운전상태                        
                        ,FN_CD_VAL(''RUNSTA'', W000.RUN_STA  )                   RUN_STA                       --운전상태
                        ,W000.PRFM_ROLLCNT              PRFM_ROLLCNT                  --실적권치수  
                        ,''M''                          AS PRROLLUNIT                 --실적권치수 단위 -추가                  
                        ,W000.PRFM_WGT                  PRFM_WGT                      --실적중량
                        ,''KG''                          AS PRWUNIT                   --실적중량 단위 -추가                  
                        ,W000.DISPO_ROLLCNT             DISPO_ROLLCNT                 --폐품권치수
                        ,''M''                          AS DIROLLUNIT                 --폐품권치수 단위 -추가                  
                        ,W000.DISPO_WGT                 DISPO_WGT                     --폐품중량
                        ,''KG''                          AS DIWUNIT                   --폐품중량 단위 -추가                  
                        ,W000.DISPO_CD                  DISPO_CD                      --폐품코드
                        ,W000.PRFM_DT                   PRFM_DT                       --실적일자  
                        ,W000.PRD_DATE                  PRD_DATE                      --생산일시
                        ,W000.NAUFNR                                                                                    --비계획생산오더번호
                        ,W000.LOT_CHG_YN
                        ,W000.REGNM                     REGNM                         --등록자명
                        --,S015.ORDER_RMK                 ORDER_RMK                     --오더비고(비고사항)
                        ,W000.RMK                         ORDER_RMK
                        ,CASE WHEN W000.RUN_STA = ''09'' THEN (SELECT ORDER_NO
                                                                 FROM TB_SCH015
                                                                WHERE NAUFNR = W000.NAUFNR AND USE_YN = ''Y'')  
                              ELSE S015.ORDER_NO END    ORDER_NO                      --오더번호                                  
                        --,S015.ORDER_NO                  ORDER_NO                      --오더번호
						,S015.COMP_YN					COMP_YN							--작업지시완료여부
                        ,W000.CNL_YN                    CNL_YN                        --취소여부
                        ,W000.MATNR                    MATNR                         --자재코드
                        ,M001.MATNR_NM                  MATNR_NM                      --자재명
                        ,W000.SDOC_NO                    SDOC_NO
                        ,W000.SDOC_SEQNO                 SDOC_SEQNO
                        ,W000.CNL_RMK                 CNL_RMK
                        
                 FROM(
                        SELECT  W002.WRK_ORDR_NO                    WRK_ORDR_NO,        --작업지시번호
                                W002.WRK_ORDR_SEQNO                 WRK_ORDR_SEQNO,     --작업지시번호
                                W002.MATNR                          MATNR,              --자재코드
                                W002.MACHINE                        MACHINE,            --생산호기
                                W002.MACH_CD                        MACH_CD,            --설비코드
                                W002.PRD_STR_DATE                   PRD_STR_DATE,       --시작시간
                                W002.PRD_END_DATE                   PRD_END_DATE,       --종료시간
								W002.TM								TM,					--생산시간(분)
                                W002.WRK_CLASS  WRK_CLASS,          --작업반
                                W002.RSPEED                         RSPEED,             --선속
                                W002.LOT_NO                         LOT_NO,             --LOT NO
                                W002.IND_BCD                        IND_BCD,            --개별바코드
                                --W002.RUN_STA                        RUN_STA,            --운전상태
                                CASE WHEN NVL(W002.PRFM_GTHR_YN, ''N'') = ''Y'' THEN W002.RUN_STA ELSE W004.RUN_STA END RUN_STA,
                                --W002.ROLLCNT                        PRFM_ROLLCNT,       --실적권치수
                                --W002.WGT                            PRFM_WGT,           --실적중량
                                CASE WHEN NVL(W002.PRFM_GTHR_YN, ''N'') = ''Y'' THEN W002.ROLLCNT ELSE 0 END PRFM_ROLLCNT,           --실적권치수
                                CASE WHEN NVL(W002.PRFM_GTHR_YN, ''N'') = ''Y'' THEN W002.WGT ELSE 0 END PRFM_WGT,           --실적중량
                                W004.ROLLCNT                        DISPO_ROLLCNT,      --폐품권치수
                                W004.WGT                            DISPO_WGT,          --폐품중량
                                W004.DISPO_CD                       DISPO_CD,           --폐품코드
                                W002.NAUFNR                         NAUFNR,             --비계획생산오더번호
                                W002.LOT_CHG_YN                     LOT_CHG_YN,         --LOT 변경여부
                                W002.PRFM_DT                        PRFM_DT,            --실적일자
                                W002.REGDATE                        PRD_DATE,           --생산일시
                                (SELECT NMLAST FROM USRMA WHERE USERID = W002.REGID)	REGNM,              --등록자
                                W002.WERKS                          WERKS,
                                NVL(W002.CNL_YN, ''N'')             CNL_YN,             --취소여부
                                W002.SDOC_NO                        SDOC_NO,
                                W002.SDOC_SEQNO                     SDOC_SEQNO,
                                W002.CNL_RMK                        CNL_RMK,
                                W002.RMK                            
                           FROM 
                               (SELECT * 
                                  FROM TB_WRK002
        						) W002
                               FULL OUTER JOIN   
                               (SELECT *
                                  FROM TB_WRK004
								) W004
                                ON W002.WERKS = W004.WERKS
                                AND W002.LOT_NO = W004.LOT_NO
                                AND W002.MACH_CD = W004.MACH_CD
                                AND W002.IND_BCD = W004.IND_BCD
                                
                          UNION ALL
                        SELECT  WRK_ORDR_NO                    WRK_ORDR_NO        --작업지시번호
                                ,WRK_ORDR_SEQNO                 WRK_ORDR_SEQNO     --작업지시번호
                                ,MATNR                          MATNR              --자재코드
                                ,MACHINE                        MACHINE            --생산호기
                                ,MACH_CD                        MACH_CD            --설비코드
                                ,PRD_STR_DATE                   PRD_STR_DATE       --시작시간
                                ,PRD_END_DATE                   PRD_END_DATE       --종료시간
								,TM								TM   			   --생산시간(분)
                                ,WRK_CLASS  					WRK_CLASS          --작업반
                                ,RSPEED                         RSPEED             --선속
                                ,LOT_NO                         LOT_NO             --LOT NO
                                ,IND_BCD                        IND_BCD            --개별바코드
                                ,''폐품''                        RUN_STA            --운전상태
                                ,NULL                   		PRFM_ROLLCNT       --실적권치수
                                ,NULL                           PRFM_WGT           --실적중량
                                ,ROLLCNT                        DISPO_ROLLCNT      --폐품권치수
                                ,WGT                            DISPO_WGT          --폐품중량
                                ,DISPO_CD                       DISPO_CD           --폐품코드
                                ,NULL                         	NAUFNR             --비계획생산오더번호
                                ,NULL                     		LOT_CHG_YN         --LOT 변경여부
                                ,PRFM_DT                        PRFM_DT            --실적일자
                                ,REGDATE                        PRD_DATE           --생산일시
                                ,(SELECT NMLAST FROM USRMA WHERE USERID = REGID)	REGNM              --등록자
                                ,WERKS                          WERKS
                                ,NVL(CNL_YN, ''N'')             CNL_YN             --취소여부
                                ,SDOC_NO                        SDOC_NO
                                ,SDOC_SEQNO                     SDOC_SEQNO
                                ,CNL_RMK                        CNL_RMK
                                ,RMK                            
                           FROM TB_WRK004   WRK004
                           WHERE  NOT EXISTS (
                                 SELECT ''X'' FROM TB_WRK002 WRK002
                                 WHERE WRK002.IND_BCD  = WRK004.IND_BCD
                                   AND WRK002.WERKS    = WRK004.WERKS
                               )    
                             --AND NVL(CNL_YN ,''N'') =  ''N'' 
                     ) W000,
                     TB_SCH015 S015,
                     (SELECT M012.MACH_CD, M012.MACH_NM, M013.PROC_NM, M012.MACHINE
                        FROM TB_MAS012 M012,
                                    TB_MAS013 M013
                              WHERE M012.PROC_CD = M013.PROC_CD(+)
                                AND M012.PROC_CD = ''JA''

        			  ) M000 , TB_MAS001 M001
                    WHERE W000.WRK_ORDR_NO = S015.WRK_ORDR_NO(+)
                      AND W000.WRK_ORDR_SEQNO = S015.WRK_ORDR_SEQNO(+)
                      AND W000.WERKS = M001.WERKS(+)
                      AND W000.MATNR = M001.MATNR(+)
                      AND W000.MACH_CD = M000.MACH_CD
                      ';

		IF V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND W000.WERKS = ''' || V_WERKS || '''';
        END IF;

        IF V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '' THEN
            V_SQL := V_SQL || ' AND W000.MACHINE = ''' || V_MACHINE || '''';
        END IF;

        IF V_RUN_STA IS NOT NULL OR TRIM(V_RUN_STA) != '' THEN
            V_SQL := V_SQL || ' AND W000.RUN_STA = ''' || V_RUN_STA || '''';
        END IF;
        --20221121 여한진 검색조건 취소여부 추가
        IF V_CNL_YN IS NOT NULL OR TRIM(V_CNL_YN) != '' THEN
            V_SQL := V_SQL || ' AND NVL(W000.CNL_YN, ''N'') = ''' || V_CNL_YN || '''';
        END IF;
        
        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'ORDER_NO', 'S015.ORDER_NO');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'PRFM_DT', 'W000.PRFM_DT');
            
            V_SQL := V_SQL || V_RANGE_SQL ;			                       	               --자재코드(WRK_ORDR.MATNR) ,생산요청일자(WRK_ORDR.PRD_REQ_DT)
        END IF; 

        V_SQL := V_SQL || ' ORDER BY W000.MACHINE, W000.PRD_STR_DATE';  
		V_DEBUG := 'Y';
        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR, SQL_PARAM1) VALUES (V_SQL, 'SP_WRK26_S01');
        END IF;           

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

    ELSIF P_TYPE = 'SAVE' THEN  /*오더변경(LOT변경)*/
        V_ARR_LIST        := V_JSON.get_array('list');

        V_DOC_NO_1 := FN_GET_MDOCNO('M','IF131');
        V_DOC_SEQNO_1 := 0;

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ           := TREAT (V_OBJ.get ('map') AS json_object_t);

            V_WERKS         := V_OBJ.get_string('WERKS');
            V_MACH_CD       := V_OBJ.get_string('MACH_CD');
            --V_MACH_NM       := V_OBJ.get_string('MACH_NM');
            V_IND_BCD       := V_OBJ.get_string('IND_BCD');
            --V_MATNR         := V_OBJ.get_string('MATNR');

--            V_DOC_NO := FN_GET_MDOCNO('M','IF125');
--            V_DOC_SEQNO := V_DOC_SEQNO + 1;
            V_DOC_SEQNO_1 := V_DOC_SEQNO_1 + 1;

            SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, MATNR, RUN_STA, PRD_DT, PRFM_DT, NAUFNR, LOT_NO, 
                    TO_CHAR(PRD_STR_DATE, 'YYYY-MM-DD HH24:MI:SS'), PRFM_QTY, LOT_CHG_YN
                INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,V_MATNR, V_RUN_STA, V_PRD_DT, V_PRFM_DT, V_NAUFNR, V_LOT_NO, 
                    V_PRD_STR_DT, V_PRFM_QTY, V_LOT_CHG_YN
              FROM TB_WRK002
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD;

            IF V_RUN_STA = '09' AND NVL(V_LOT_CHG_YN, 'N') = 'N' THEN
                BEGIN
                    SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, MATNR, UNIT, LOT_NO_BUF
                        INTO V_WRK_ORDR_NO_NEW, V_WRK_ORDR_SEQNO_NEW, V_ORDER_NO_NEW, V_MATNR_NEW, V_UNIT, V_LOT_NO_BUF
                      FROM TB_SCH015
                     WHERE NAUFNR =  V_NAUFNR
                       AND USE_YN = 'Y';
                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        P_SUCCESS       := 'N';
                        P_ERR_MSG       := '원본LOT NO: ' || V_LOT_NO || ' 의 정보를 ERP에서 찾을 수 없습니다. 다시 조회하십시오.';
                        ROLLBACK;
                        RETURN;
                 END;

                 SP_GET_BARCODE_SEQ('LOT', V_WERKS, V_MACH_CD, V_MATNR_NEW, V_PRD_STR_DT, V_LOT_NO_NEW);

                 UPDATE TB_WRK002
                    SET WRK_ORDR_NO = V_WRK_ORDR_NO_NEW,
                        WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO_NEW,
                        ORDER_NO = V_ORDER_NO_NEW,
                        MATNR = V_MATNR_NEW, 
                        LOT_NO = V_LOT_NO_NEW,
                        LOT_NO_PRE = V_LOT_NO,
                        LOT_CHG_YN = 'Y',
                        STA = '00'
                        --RUN_STA = '01'
                  WHERE WERKS = V_WERKS
                    AND MACH_CD = V_MACH_CD
                    AND IND_BCD = V_IND_BCD;

                 UPDATE TB_INV001
                    SET WRK_ORDR_NO = V_WRK_ORDR_NO_NEW,
                        WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO_NEW,
                        ORDER_NO = V_ORDER_NO_NEW,
                        MATNR = V_MATNR_NEW,
                        LOT_NO = V_LOT_NO_NEW,
                        STCK_STA = '00'
                  WHERE WERKS = V_WERKS
                    AND MACH_CD = V_MACH_CD
                    AND IND_BCD = V_IND_BCD;     

--                 V_DOC_NO := FN_GET_MDOCNO('M','IF131');
--                 V_DOC_SEQNO := 1;    

                 V_WERKS_FR := V_WERKS;
                 V_WERKS_TO := V_WERKS;
                 V_STOR_LOC_FR := '2000';
                 V_STOR_LOC_TO := '2000';
                 V_CHARG_FR := V_LOT_NO;
                 V_CHARG_TO := V_LOT_NO_NEW;

                 IF V_MATNR = V_MATNR_NEW THEN 
                    V_MOVE_DIV := '311';
                    V_MATNR_FR := V_MATNR;
                    V_MATNR_TO := V_MATNR_NEW;
                 ELSE
                    V_MOVE_DIV := '309';
                    V_MATNR_FR := V_MATNR;
                    V_MATNR_TO := V_MATNR_NEW;
                 END IF;
				 
                 V_BUDAT	:= FN_RECDATE(V_DATE);
                 
                 --재고이전 이력
                 INSERT INTO TB_WRK017(DOC_NO, DOC_SEQNO, MOVE_DIV, WERKS_FR, WERKS_TO,
                                    MATNR_FR, MATNR_TO, STOR_LOC_FR, STOR_LOC_TO,
                                    CHARG_FR, CHARG_TO, MOVE_QTY, UNIT, AUFNR,
                                    WRK_ORDR_NO_FR, WRK_ORDR_SEQNO_FR, WRK_ORDR_NO_TO, WRK_ORDR_SEQNO_TO,
                                    UCFMTY_YN, RMK, REGDATE, REGID, BUDAT)
                        VALUES(V_DOC_NO_1, V_DOC_SEQNO_1, V_MOVE_DIV, V_WERKS_FR, V_WERKS_TO,      
                                V_MATNR_FR, V_MATNR_TO, V_STOR_LOC_FR, V_STOR_LOC_TO,
                                V_CHARG_FR, V_CHARG_TO, V_PRFM_QTY, V_UNIT, V_ORDER_NO_NEW,
                                V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_WRK_ORDR_NO_NEW, V_WRK_ORDR_SEQNO_NEW,
                                'N', '', V_DATE, V_SESS_USER_ID, V_BUDAT);
                --SAP 재고이전  I/F
                 INSERT INTO TB_IFS009(BWART, WERKS_FROM, WERKS_TO, MATNR_FROM, MATNR_TO,
                                    LGORT_FROM, LGORT_TO, CHARG_FROM, CHARG_TO,
                                    AUFNR, MENGE, MEINS, FAULTY,
                                    MDOCNO, MDOCSEQ, MAKE_DATE, MAKER, LTCHG, BUDAT)
                        VALUES(V_MOVE_DIV, V_WERKS_FR, V_WERKS_TO, V_MATNR_FR, V_MATNR_TO,
                                V_STOR_LOC_FR, V_STOR_LOC_TO, V_CHARG_FR, V_CHARG_TO,
                                V_ORDER_NO_NEW, V_PRFM_QTY, V_UNIT, 'N',
                                V_DOC_NO_1, V_DOC_SEQNO_1, V_DATE, V_SESS_USER_ID, 'X', V_BUDAT);

                --문서이력
                IF V_MOVE_DIV = '311' THEN
                    V_DOC_DIV := 6;
                ELSE
                    V_DOC_DIV := 7;
                END IF;

                INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                            IND_BCD, LOT_NO, ORDER_NO, CNL_YN, REGDATE, REGID)
                    VALUES(V_DOC_NO_1, V_DOC_SEQNO_1, V_DOC_DIV, V_WERKS, V_MACH_CD, V_WRK_ORDR_NO_NEW, V_WRK_ORDR_SEQNO_NEW,
                            V_IND_BCD, V_LOT_NO_NEW, V_ORDER_NO_NEW, 'N', V_DATE, V_SESS_USER_ID);   
                
                UPDATE   TB_SCH015 SET COMP_YN = 'Y'
                WHERE  WRK_ORDR_NO      = V_WRK_ORDR_NO_NEW
                  AND  WRK_ORDR_SEQNO   = V_WRK_ORDR_SEQNO_NEW
                  ;
                
            ELSE
                IF V_LOT_CHG_YN = 'Y' THEN
                    P_ERR_MSG       := '이미 LOT 변경처리된 LOT NO 입니다.';
                ELSE
                    P_ERR_MSG       := '비계획 생산실적이 아닙니다.';
                END IF;

                P_SUCCESS           := 'N';
                ROLLBACK;
                RETURN;
            END IF;
        END LOOP;

        IF V_DOC_SEQNO_1 > 0 THEN
            P_DOC_NO1 := V_DOC_NO_1;
        END IF;
    ELSIF P_TYPE = 'SAVE2' THEN  /* 오더변경(LOT변경) 취소*/
        V_ARR_LIST        := V_JSON.get_array('list');

        V_DOC_NO_1 := FN_GET_MDOCNO('M','IF142');
        V_DOC_SEQNO_1 := 0;

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ           := TREAT (V_OBJ.get ('map') AS json_object_t);

            V_WERKS         := V_OBJ.get_string('WERKS');
            V_MACH_CD       := V_OBJ.get_string('MACH_CD');
            V_IND_BCD       := V_OBJ.get_string('IND_BCD');

            V_DOC_SEQNO_1 := V_DOC_SEQNO_1 + 1;

            SELECT IND_BCD, WRK_ORDR_NO, WRK_ORDR_SEQNO, MATNR, STA, RUN_STA, NAUFNR, LOT_NO, 
                    LOT_CHG_YN
                INTO V_IND_BCD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_MATNR, V_STA, V_RUN_STA, V_NAUFNR, V_LOT_NO, 
                    V_LOT_CHG_YN
              FROM TB_WRK002
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD;

            --LOT 변경 여부
            IF V_RUN_STA = '09' AND NVL(V_LOT_CHG_YN, 'N') = 'N' THEN
                P_SUCCESS       := 'N';
                P_ERR_MSG       := 'LOT 변경을 해주세요';
                ROLLBACK;
                RETURN;
            END IF;

            IF V_STA = '10' THEN
                P_SUCCESS       := 'N';
                P_ERR_MSG       := '후공정에 투입되어 LOT변경 취소를 할수 없습니다.';
                ROLLBACK;
                RETURN;
            END IF;

            IF V_RUN_STA = '09' AND NVL(V_LOT_CHG_YN, 'N') = 'Y' THEN
                SELECT DOC_NO, DOC_SEQNO INTO V_DOC_NO_FR, V_DOC_SEQNO_FR
                  FROM TB_WRK021
                 WHERE WERKS = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND DOC_DIV IN (6, 7)
                   AND WRK_ORDR_NO = V_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                   AND IND_BCD = V_IND_BCD
                   AND NVL(CNL_YN, 'N') = 'N';  

                SELECT MATNR_FR, STOR_LOC_FR, CHARG_FR, AUFNR, WRK_ORDR_NO_FR, WRK_ORDR_SEQNO_FR  
                    INTO V_MATNR_FR, V_STOR_LOC_FR, V_CHARG_FR, V_ORDER_NO, V_WRK_ORDR_NO_FR, V_WRK_ORDR_SEQNO_FR  
                  FROM TB_WRK017
                 WHERE DOC_NO = V_DOC_NO_FR
                   AND DOC_SEQNO = V_DOC_SEQNO_FR;

                --실적 이력 변경
                UPDATE TB_WRK002
                   SET LOT_NO = V_CHARG_FR,
                       MATNR = V_MATNR_FR,
                       ORDER_NO = '',
                       WRK_ORDR_NO = V_WRK_ORDR_NO_FR,
                       WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO_FR, 
                       LOT_CHG_YN = 'N',
                       STA = '60'
                 WHERE WERKS = V_WERKS
                   AND IND_BCD = V_IND_BCD;

                UPDATE TB_INV001
                   SET STOR_LOC_CD = V_STOR_LOC_FR,
                       LOT_NO = V_CHARG_FR,
                       MATNR = V_MATNR_FR,
                       ORDER_NO = '',
                       WRK_ORDR_NO = V_WRK_ORDR_NO_FR,
                       WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO_FR,
                       STCK_STA = '60'
                 WHERE WERKS = V_WERKS
                   AND IND_BCD = V_IND_BCD;     

                UPDATE TB_WRK021
                   SET CNL_YN = 'Y',
                       UPDDATE = V_DATE,
                       UPDID = V_SESS_USER_ID
                 WHERE DOC_NO = V_DOC_NO_FR
                   AND DOC_SEQNO = V_DOC_SEQNO_FR;

--                V_DOC_NO := FN_GET_MDOCNO('M','IF142');
--                V_DOC_SEQNO := 1;    
                --LOT변경 취소 이력
                INSERT INTO TB_WRK023(DOC_NO, DOC_SEQNO, ORDER_NO, REGDATE, REGID)
                            VALUES(V_DOC_NO_1, V_DOC_SEQNO_1, V_NAUFNR, V_DATE, V_SESS_USER_ID);


                --SAP LOT변경 취소 I/F            
                INSERT INTO TB_IFS020(AUFNR, MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)     
                            VALUES(V_NAUFNR, V_DOC_NO_1, V_DOC_SEQNO_1, V_DATE, V_SESS_USER_ID);   

            END IF;
        END LOOP;    

        IF V_DOC_SEQNO_1 > 0 THEN
            P_DOC_NO1 := V_DOC_NO_1;
        END IF;
    ELSIF P_TYPE = 'DELETE' THEN  /* 실적취소*/
        V_ARR_LIST        := V_JSON.get_array('list');

        V_DOC_NO_1 := FN_GET_MDOCNO('M','IF129');
        V_DOC_SEQNO_1 := 0;

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ           := TREAT (V_OBJ.get ('map') AS json_object_t);

            V_WERKS         := V_OBJ.get_string('WERKS');
            V_MACH_CD       := V_OBJ.get_string('MACH_CD');
            V_IND_BCD       := V_OBJ.get_string('IND_BCD');

            V_PRFM_ROLLCNT      := V_OBJ.get_string('PRFM_ROLLCNT');
            V_PRFM_WGT          := V_OBJ.get_string('PRFM_WGT');
            V_DISPO_ROLLCNT     := V_OBJ.get_string('DISPO_ROLLCNT');
            V_DISPO_WGT         := V_OBJ.get_string('DISPO_WGT');
            V_DISPO_CD          := V_OBJ.get_string('DISPO_CD');

            IF TO_NUMBER(NVL(V_PRFM_ROLLCNT, 0))> 0 THEN

                V_DOC_SEQNO_1 := V_DOC_SEQNO_1 + 1;

                SELECT W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO, W002.ORDER_NO, I001.STCK_STA, W002.SDOC_NO, W002.SDOC_SEQNO, W002.NAUFNR
                  INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, V_STA, V_SDOC_NO, V_SDOC_SEQNO, V_NAUFNR
                  FROM TB_WRK002 W002, TB_INV001 I001
                 WHERE W002.WERKS = I001.WERKS(+)
                   AND W002.IND_BCD = I001.IND_BCD(+)
                   AND W002.WERKS = V_WERKS
                   AND W002.MACH_CD = V_MACH_CD
                   AND W002.IND_BCD = V_IND_BCD;

                SELECT SAP_WRK_CD INTO V_SAP_WRK_CD
                  FROM TB_MAS012
                 WHERE MACH_CD = V_MACH_CD;

                IF V_STA = '00' OR V_STA = '60' THEN
                    IF V_STA = '60' THEN
                        V_ORDER_NO := V_NAUFNR;
                    END IF;
                    
                    INSERT INTO TB_IFS007(RUECK, RMZHL, MDOCNO, MDOCSEQ,
                                        MAKE_DATE, MAKER, WORKCENTERCODE, AUFNR, ROLLCNT, MBLNR)
                                 VALUES(V_SDOC_NO, V_SDOC_SEQNO, V_DOC_NO_1, V_DOC_SEQNO_1,
                                        V_DATE, V_SESS_USER_ID, V_SAP_WRK_CD, V_ORDER_NO, TO_NUMBER(V_PRFM_ROLLCNT), V_SDOC_NO);
                    UPDATE TB_WRK002
                       SET CNL_YN = 'Y',
                           UPDDATE = V_DATE,
                           UPDID = V_SESS_USER_ID
                     WHERE WERKS = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND IND_BCD = V_IND_BCD;

                    DELETE
                      FROM TB_INV001
                     WHERE WERKS = V_WERKS
                       AND IND_BCD = V_IND_BCD
                       AND MACH_CD = V_MACH_CD;
                ELSIF V_STA = '10' THEN 
                    P_SUCCESS       := 'N';
                    P_ERR_MSG       := '후공정에 투입되어 실적취소를 할 수 없습니다.';
                    ROLLBACK;
                    RETURN;
                ELSIF V_STA = '20' THEN 
                    P_SUCCESS       := 'N';
                    P_ERR_MSG       := '후공정에서 실적완료 되어 실적취소를 할 수 없습니다.';
                    ROLLBACK;
                    RETURN;
                END IF;   
            END IF;

        END LOOP;    

        IF V_DOC_SEQNO_1 > 0 THEN
            P_DOC_NO1 := V_DOC_NO_1;
        END IF;

    END IF;

    P_SUCCESS := 'Y';
    COMMIT;

    EXCEPTION
    WHEN E_EXCEPTION_USER THEN

        -- 에러 내역 SET
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        ROLLBACK;

    WHEN OTHERS THEN
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE; 
END;
/
