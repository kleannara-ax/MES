
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK11_S01" (
	P_TYPE           IN    varchar2, -- LIST, SUB_LIST-A, SUB_LIST-B
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
    P_ERR_MSG       OUT    VARCHAR2,
    P_DOC_NO1       OUT    VARCHAR2,        --폐품취소
    P_DOC_NO2       OUT    VARCHAR2,        --실적취소
    P_DOC_NO3       OUT    VARCHAR2,        --실적등록
    P_DOC_NO4       OUT    VARCHAR2,        --폐품등록    
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK11_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 폐품등록 현황 (생리대, 기저귀) {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 폐품등록 현황 (생리대, 기저귀) 조회.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박성철{최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/23 {최초 작성일자 기술}
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

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK11_S01';     -- PROCEDURE NAME


    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
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
	V_DISPO_QTY 		        TB_WRK016.DISPO_QTY%TYPE;			--폐품수량

    V_DOC_NO_1                  TB_WRK016.DOC_NO%TYPE;
    V_DOC_SEQNO_1               TB_WRK016.DOC_SEQNO%TYPE;
    V_DOC_NO_2                  TB_WRK016.DOC_NO%TYPE;
    V_DOC_SEQNO_2               TB_WRK016.DOC_SEQNO%TYPE;
    V_DOC_NO_3                  TB_WRK016.DOC_NO%TYPE;
    V_DOC_SEQNO_3               TB_WRK016.DOC_SEQNO%TYPE;
    V_DOC_NO_4                  TB_WRK016.DOC_NO%TYPE;
    V_DOC_SEQNO_4               TB_WRK016.DOC_SEQNO%TYPE;
    
    V_MACHINE                   TB_MAS012.MACHINE%TYPE;
    V_SAP_WRK_CD                TB_MAS012.SAP_WRK_CD%TYPE;
    V_IND_BCD                   TB_WRK016.IND_BCD%TYPE;
    V_IND_BCD_M                 TB_WRK016.IND_BCD%TYPE;
    V_LOT_NO                    TB_WRK016.LOT_NO%TYPE;
    V_LOT_NO_M                  TB_WRK016.LOT_NO_M%TYPE;
    V_MATNR                     TB_WRK016.MATNR%TYPE;
    V_MATNR_M                   TB_WRK016.MATNR_M%TYPE;
    V_ORDER_NO                  TB_WRK016.ORDER_NO%TYPE;
    --V_PRFM_DT                   TB_WRK016.PRFM_DT%TYPE;
    V_PRFM_QTY                  TB_WRK016.PRFM_QTY%TYPE;
    --V_DISPO_QTY                 TB_WRK016.DISPO_QTY%TYPE;

    V_DOC_NO_PRE_1               TB_WRK016.DOC_NO%TYPE;        
    V_DOC_SEQNO_PRE_1            TB_WRK016.DOC_SEQNO%TYPE;        
    V_DOC_NO_PRE_2               TB_WRK001.DOC_NO%TYPE;        
    V_DOC_SEQNO_PRE_2            TB_WRK001.DOC_SEQNO%TYPE;  

    V_SDOC_NO_PRE_1               TB_WRK016.SDOC_NO%TYPE;        
    V_SDOC_SEQNO_PRE_1            TB_WRK016.SDOC_SEQNO%TYPE;        
    V_SDOC_NO_PRE_2               TB_WRK001.SDOC_NO%TYPE;        
    V_SDOC_SEQNO_PRE_2            TB_WRK001.SDOC_SEQNO%TYPE;        
    V_PAUFNR                     TB_WRK001.PAUFNR%TYPE;
    V_DATE                      DATE := SYSDATE;
    V_STOR_LOC_CD               TB_MAS001.LGPRO%TYPE;
    V_CNL_YN                    TB_WRK016.CNL_YN%TYPE;
    V_SDOC_NO_TEMP              TB_WRK016.SDOC_NO%TYPE;      
    V_DATA_EXIST                NUMBER;
BEGIN
    OPEN P_RS_LIST FOR 

    SELECT NULL FROM DUAL WHERE ROWNUM = 0;

    V_DEBUG := 'N';
    V_RUN_SQL := 'Y';

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

    V_SESS_USER_ID       :=      V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=      V_JSON.get_string('SES_PLNTKY');

    /* 조건값 할당 */
    V_RANGE_SQL         :=      V_JSON.get_string('RANGE_SQL');
    V_WERKS				:= 		V_JSON.get_string('WERKS');		        -- 플랜트
    --V_MACH_CD			:= 		V_JSON.get_string('MACH_CD');		    -- 설비
    V_MACHINE			:= 		V_JSON.get_string('MACHINE');		    -- 생산호기
    V_MATNR             := 		V_JSON.get_string('MATNR');		        -- 자재코드

    IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/
        V_SQL :=  ' SELECT WRK016.WERKS       AS WERKS              --플랜트     
                         , WRK016.PRFM_DT     AS PRFM_DT            --실적일자          
                         , WRK016.MACH_CD     AS MACH_CD            --설비코드          
                         , MAS012.MACH_NM     AS MACH_NM            --설비명 
 						 , MAS012.MACH_SHRT_NM AS MACH_SHRT_NM      --설비명(단축)
                         , WRK016.WRK_SHIFT   AS WRK_SHIFT          --작업조           
                         , WRK016.WRK_CLASS   AS WRK_CLSS_NM        --작업반           
                         , WRK016.WRK_ORDR_NO AS WRK_ORDR_NO        --작업지시번호          
                         , WRK016.WRK_ORDR_SEQNO AS WRK_ORDR_SEQNO  --작업지시순번  
                         , WRK016.MATNR       AS MATNR              --자재코드            
                         , MAS001.MATNR_NM    AS MATNR_NM           --자재명           
                         , WRK016.TOT_QTY     AS TOT_QTY            --총생산수량       
                         , CASE WHEN NVL(WRK016.CNL_YN, ''N'') = ''N'' THEN WRK016.PRFM_QTY
                                ELSE (SELECT SUM(EA_QTY) 
                                        FROM TB_WRK001 
                                       WHERE WERKS = WRK016.WERKS
                                         AND MACH_CD = WRK016.MACH_CD
                                         AND WRK_ORDR_NO = WRK016.WRK_ORDR_NO
                                         AND WRK_ORDR_SEQNO = WRK016.WRK_ORDR_SEQNO
                                         AND PRFM_GTHR_YN = ''Y''
                                         AND SDOC_NO IS NOT NULL 
                                         AND SDOC_NO <> ''E'' 
                                      GROUP BY WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO     
                                         ) END AS PRFM_QTY           --실적수량        
                         , CASE WHEN NVL(WRK016.CNL_YN, ''N'') = ''N'' THEN WRK016.DISPO_QTY
                                ELSE 0 END SCRAP_QTY          --폐품수량
--                                ELSE (SELECT CASE WHEN NVL(WRK016.TOT_QTY, 0) = 0 THEN 0 ELSE WRK016.TOT_QTY - SUM(PRFM_QTY) END
--                                        FROM TB_WRK001 
--                                       WHERE WERKS = WRK016.WERKS
--                                         AND MACH_CD = WRK016.MACH_CD
--                                         AND WRK_ORDR_NO = WRK016.WRK_ORDR_NO
--                                         AND WRK_ORDR_SEQNO = WRK016.WRK_ORDR_SEQNO
--                                      GROUP BY WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO
--                                ) END AS SCRAP_QTY          --폐품수량  
					     , WRKNM.USER_NM         AS WRKNM         --작업자      
                         , CASE WHEN NVL(WRK016.SDOC_NO, '' '') = '' '' 
                                        OR NVL(WRK016.SDOC_NO, '' '') = ''E'' OR NVL(WRK016.CNL_YN, ''N'') = ''Y'' THEN ''미전송''
                                ELSE ''전송완료'' END     AS SAP_YN        --SAP 전송상태
                      FROM TB_WRK016 WRK016       --폐품 등록정보
                     LEFT JOIN TB_MAS012 MAS012   --설비마스터
                       ON MAS012.MACH_CD = WRK016.MACH_CD         
                     LEFT JOIN TB_MAS001 MAS001   --자재마스터      
                       ON (WRK016.WERKS = MAS001.WERKS AND MAS001.MATNR = WRK016.MATNR)          
					 LEFT JOIN USRMA WRKNM        --유저마스터      
					   ON WRKNM.USERID = WRK016.REGID   
                    WHERE 1=1
                        AND WRK016.WERKS = ''' || V_WERKS || '''';     --패드 플랜트
--                         AND nvl(WRK016.CNL_YN, ''N'') = ''N''

            /*IF  V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN
                V_SQL := V_SQL || ' AND WRK016.MATNR = ''' || V_MATNR || '''';
            END IF;*/

            IF  V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '' THEN
                V_SQL := V_SQL || ' AND MAS012.MACHINE = ''' || V_MACHINE || '''';
            END IF;

        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
        	V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MATNR', 'WRK016.MATNR');	--자재코드
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;

        V_SQL := V_SQL || ' ORDER BY WRK016.WERKS, WRK016.MACH_CD, WRK016.PRFM_DT';
       V_DEBUG := 'Y';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR, SQL_PARAM1) VALUES (V_SQL, 'WRK11_S01');
        END IF;

		OPEN P_RS_LIST FOR V_SQL;
    ELSIF P_TYPE = 'SAVE' THEN

        V_ARR_LIST        := V_JSON.get_array('list');

        --실적등록
        V_DOC_NO_3 := FN_GET_MDOCNO('M','IF133');
        V_DOC_SEQNO_3 := 0;
        --폐품등록
        V_DOC_NO_4 := FN_GET_MDOCNO('M','IF134');
        V_DOC_SEQNO_4 := 0;


        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP

	        V_OBJ						:= TREAT (V_ARR_LIST.get (i) AS json_object_t);  
            V_OBJ						:= TREAT (V_OBJ.get ('map') AS json_object_t);

			V_WERKS 		            := V_OBJ.get_string('WERKS');			    --플랜트코드
			V_MACH_CD 		            := V_OBJ.get_string('MACH_CD');			    --작업장코드(설비코드)
			V_PRFM_DT 		            := V_OBJ.get_string('PRFM_DT');			    --실적일자
			V_WRK_ORDR_NO 		        := V_OBJ.get_string('WRK_ORDR_NO');			--작업지시번호
			V_WRK_ORDR_SEQNO 		    := V_OBJ.get_string('WRK_ORDR_SEQNO');		--작업지시 순번
			V_DISPO_QTY 		        := V_OBJ.get_string('SCRAP_QTY');			--폐품수량

			IF V_OBJ.get_string('GRowState') = 'U'   THEN

                SELECT SAP_WRK_CD
                    INTO V_SAP_WRK_CD
                  FROM TB_MAS012
                 WHERE MACH_CD = V_MACH_CD; 
                
                V_DATA_EXIST := 1;
                
                BEGIN
                -- 1=실적, 2=생산폐품, 3=영업폐품, 4=잔량폐품, 5=투입자재 소요량, 6=재고이전(위치), 7=재고이전(자재변경), 8=재고이전(재고실사), 9=LOT변경, 10=등급변경, 11=LOT병합, 12=LIFT출고, 20=오더완료
                SELECT NVL(CNL_YN, 'N'), SDOC_NO, IND_BCD INTO V_CNL_YN, V_SDOC_NO_TEMP, V_IND_BCD_M
                  FROM (
                        SELECT CNL_YN, SDOC_NO, IND_BCD
                          FROM TB_WRK021
                         WHERE WERKS = V_WERKS
                           AND MACH_CD = V_MACH_CD
                           AND DOC_DIV = '1'
                           AND WRK_ORDR_NO = V_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                        ORDER BY REGDATE DESC )
                 WHERE ROWNUM = 1 ;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_DATA_EXIST := 0; 
                END ;
                
                IF V_DATA_EXIST = 0 THEN
                    P_SUCCESS := 'N';
                    P_ERR_MSG := '폐품이력을 찾을 수 없습니다.';
                    RETURN;
                END IF;
                
                IF (V_CNL_YN = 'Y' AND NVL(V_SDOC_NO_TEMP, ' ') <> 'E') OR (V_CNL_YN = 'N' AND NVL(V_SDOC_NO_TEMP, ' ') = 'E') THEN
                    --실적이력
                    SELECT LOT_NO, ORDER_NO, DOC_NO, DOC_SEQNO, SDOC_NO, SDOC_SEQNO, PAUFNR
                        INTO V_LOT_NO, V_ORDER_NO, V_DOC_NO_PRE_2,V_DOC_SEQNO_PRE_2, V_SDOC_NO_PRE_2, V_SDOC_SEQNO_PRE_2, V_PAUFNR
                      FROM TB_WRK001
                     WHERE WERKS = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND IND_BCD = V_IND_BCD_M;
    
                    --실적등록
                    V_DOC_SEQNO_3 := V_DOC_SEQNO_3 + 1;
                    INSERT INTO TB_IFS011(AUFNR, LOTNO, WERKS, WORKCENTERCODE, BUDAT, MACHINE, MATNR, WORKGROUP,
                                        PROQTY, MEINS, RUNTIME, OPNAM, CONF, SDATE, STIME, EDATE, ETIME, 
                                        MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                    SELECT '', LOTNO, WERKS, WORKCENTERCODE, BUDAT, MACHINE, MATNR, WORKGROUP,
                                        V_DISPO_QTY, MEINS, RUNTIME, OPNAM, CONF, SDATE, STIME, EDATE, ETIME, 
                                        V_DOC_NO_3, TO_CHAR(V_DOC_SEQNO_3), V_DATE, V_SESS_USER_ID
                      FROM TB_IFS011
                     WHERE MDOCNO = V_DOC_NO_PRE_2 
                       AND MDOCSEQ = TO_CHAR(V_DOC_SEQNO_PRE_2);
    
                    UPDATE TB_WRK001
                       SET PRFM_QTY = V_DISPO_QTY,
                           DOC_NO = V_DOC_NO_3,
                           DOC_SEQNO = V_DOC_SEQNO_3,
                           UPDDATE = V_DATE,
                           UPDID = V_SESS_USER_ID
                     WHERE WERKS = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND IND_BCD = V_IND_BCD_M; 
                       
                    INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD,
                                        WRK_ORDR_NO, WRK_ORDR_SEQNO, IND_BCD, LOT_NO, ORDER_NO, CNL_YN, REGDATE, REGID)
                                  VALUES(V_DOC_NO_3, V_DOC_SEQNO_3, '1', V_WERKS, V_MACH_CD,
                                       V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_IND_BCD_M, V_LOT_NO, V_ORDER_NO, 'N',
                                       V_DATE, V_SESS_USER_ID);       
                   
                ELSE
                    P_SUCCESS := 'N';
                    P_ERR_MSG := '폐품취소를 진행해 주세요';
                    RETURN;
                END IF;
                
                V_DATA_EXIST := 1;
                
                BEGIN
                SELECT NVL(CNL_YN, 'N'), SDOC_NO INTO V_CNL_YN, V_SDOC_NO_TEMP
                  FROM (
                        SELECT CNL_YN, SDOC_NO
                          FROM TB_WRK021
                         WHERE WERKS = V_WERKS
                           AND MACH_CD = V_MACH_CD
                           AND DOC_DIV = '2'
                           AND WRK_ORDR_NO = V_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                        ORDER BY REGDATE DESC )
                 WHERE ROWNUM = 1 ;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_DATA_EXIST := 0; 
                END ;
                
                IF V_DATA_EXIST = 0 THEN
                    P_SUCCESS := 'N';
                    P_ERR_MSG := '폐품이력을 찾을 수 없습니다.';
                    RETURN;
                END IF;
                
                IF (V_CNL_YN = 'Y' AND NVL(V_SDOC_NO_TEMP, ' ') <> 'E') OR (V_CNL_YN = 'N' AND NVL(V_SDOC_NO_TEMP, ' ') = 'E') THEN
                    --폐품등록
                    --폐품취소 이력
                    SELECT IND_BCD_M, LOT_NO, LOT_NO_M,  MATNR, MATNR_M, ORDER_NO, PRFM_DT, PRFM_QTY, --DISPO_QTY, 
                            DOC_NO, DOC_SEQNO, SDOC_NO, SDOC_SEQNO
                        INTO V_IND_BCD_M, V_LOT_NO, V_LOT_NO_M,  V_MATNR, V_MATNR_M, V_ORDER_NO, V_PRFM_DT, V_PRFM_QTY, --V_DISPO_QTY,
                            V_DOC_NO_PRE_1, V_DOC_SEQNO_PRE_1, V_SDOC_NO_PRE_1, V_SDOC_SEQNO_PRE_1
                      FROM TB_WRK016
                     WHERE WERKS = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND WRK_ORDR_NO = V_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
                       
                       
                    V_DOC_SEQNO_4 := V_DOC_SEQNO_4 + 1;
                    INSERT INTO TB_IFS012(AUFNR, LOTNO, BUDAT, MATNR, SCRQTY, SCRAPCODE, SCRAPREASON,
                                            LGORT, CHARG, SDATE, STIME, EDATE, ETIME, 
                                            MDOCNO, MDOCSEQ, MAKE_DATE, MAKER, WORKCENTERCODE)
                    SELECT AUFNR, LOTNO, BUDAT, MATNR, V_DISPO_QTY, SCRAPCODE, SCRAPREASON,
                                            LGORT, CHARG, SDATE, STIME, EDATE, ETIME, 
                                            V_DOC_NO_4, TO_CHAR(V_DOC_SEQNO_4), V_DATE, V_SESS_USER_ID, WORKCENTERCODE
                      FROM TB_IFS012
                     WHERE MDOCNO = V_DOC_NO_PRE_1
                       AND MDOCSEQ = TO_CHAR(V_DOC_SEQNO_PRE_1);
    
                    UPDATE TB_WRK016     -- 폐품 등록정보
                       SET CNL_YN        = 'N'
                         , DISPO_QTY     = V_DISPO_QTY      --폐품수량
                         , DOC_NO        = V_DOC_NO_4
                         , DOC_SEQNO     = V_DOC_SEQNO_4
                         , UPDDATE	     = SYSDATE          --수정일시
                         , UPDID	     = V_SESS_USER_ID   --수정자ID
                    WHERE WERKS	         = V_WERKS          --플랜트코드
                      AND MACH_CD        = V_MACH_CD        --작업장코드(설비코드)
                      AND PRFM_DT        = V_PRFM_DT        --실적일자
                      AND WRK_ORDR_NO    = V_WRK_ORDR_NO    --작업지시번호
                      AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO --작업지시 순번
                    ;
                    
                    INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD,
                                        WRK_ORDR_NO, WRK_ORDR_SEQNO, IND_BCD, LOT_NO, ORDER_NO, CNL_YN, REGDATE, REGID)
                                  VALUES(V_DOC_NO_4, V_DOC_SEQNO_4, '2', V_WERKS, V_MACH_CD,
                                       V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_IND_BCD_M, V_LOT_NO, V_ORDER_NO, 'N',
                                       V_DATE, V_SESS_USER_ID);           
                ELSE
                    P_SUCCESS := 'N';
                    P_ERR_MSG := '폐품취소를 진행해 주세요';
                    RETURN;
                END IF;
			END IF;

        END LOOP;

        P_DOC_NO3 := V_DOC_NO_3;
        P_DOC_NO4 := V_DOC_NO_4;
    ELSIF P_TYPE = 'DELETE' THEN        --폐품취소
        V_ARR_LIST        := V_JSON.get_array('list');
        
        --폐품취소
        V_DOC_NO_1 := FN_GET_MDOCNO('M','IF145');
        V_DOC_SEQNO_1 := 0;
        --실적취소
        V_DOC_NO_2 := FN_GET_MDOCNO('M','IF129');
        V_DOC_SEQNO_2 := 0;
        
        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ						:= TREAT (V_ARR_LIST.get (i) AS json_object_t);  
            V_OBJ						:= TREAT (V_OBJ.get ('map') AS json_object_t);

			V_WERKS 		            := V_OBJ.get_string('WERKS');			    --플랜트코드
			V_MACH_CD 		            := V_OBJ.get_string('MACH_CD');			    --작업장코드(설비코드)
			V_PRFM_DT 		            := V_OBJ.get_string('PRFM_DT');			    --실적일자
			V_WRK_ORDR_NO 		        := V_OBJ.get_string('WRK_ORDR_NO');			--작업지시번호
			V_WRK_ORDR_SEQNO 		    := V_OBJ.get_string('WRK_ORDR_SEQNO');		--작업지시 순번
			V_DISPO_QTY 		        := V_OBJ.get_string('SCRAP_QTY');			--폐품수량
            
            SELECT SAP_WRK_CD
                INTO V_SAP_WRK_CD
              FROM TB_MAS012
             WHERE MACH_CD = V_MACH_CD; 
            
            V_DATA_EXIST := 1;
                
            BEGIN
            SELECT NVL(CNL_YN, 'N'), NVL(SDOC_NO, 'E') INTO V_CNL_YN, V_SDOC_NO_TEMP
              FROM (
                    SELECT CNL_YN, SDOC_NO
                      FROM TB_WRK021
                     WHERE WERKS = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND DOC_DIV = '2'
                       AND WRK_ORDR_NO = V_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                    ORDER BY REGDATE DESC )
             WHERE ROWNUM = 1 ;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_DATA_EXIST := 0; 
            END ;
            
            IF V_DATA_EXIST = 0 THEN
                P_SUCCESS := 'N';
                P_ERR_MSG := '폐품이력을 찾을 수 없습니다.';
                RETURN;
            END IF;
          
            IF (V_CNL_YN = 'N' AND V_SDOC_NO_TEMP <> 'E') OR (V_CNL_YN = 'Y' AND V_SDOC_NO_TEMP = 'E') THEN     
                 --폐품취소
                SELECT IND_BCD_M, LOT_NO, LOT_NO_M,  MATNR, MATNR_M, ORDER_NO, PRFM_DT, PRFM_QTY, DISPO_QTY, 
                        DOC_NO, DOC_SEQNO, SDOC_NO, SDOC_SEQNO
                    INTO V_IND_BCD_M, V_LOT_NO, V_LOT_NO_M,  V_MATNR, V_MATNR_M, V_ORDER_NO, V_PRFM_DT, V_PRFM_QTY, V_DISPO_QTY,
                        V_DOC_NO_PRE_1, V_DOC_SEQNO_PRE_1, V_SDOC_NO_PRE_1, V_SDOC_SEQNO_PRE_1
                  FROM TB_WRK016
                 WHERE WERKS = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND WRK_ORDR_NO = V_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
                   
                SELECT LGPRO  INTO V_STOR_LOC_CD
                  FROM TB_MAS001
                 WHERE WERKS = V_WERKS
                   AND MATNR = V_MATNR_M;
    
                V_DOC_SEQNO_1 := V_DOC_SEQNO_1 + 1;
                INSERT INTO TB_IFS022(WORKCENTERCODE, AUFNR, POSNR, BUDAT,
                                    MATNR, MENGE, WERKS, LGORT, CHARG, MDOCNO, MDOCSEQ,
                                    MBLNR, MJAHR, MAKE_DATE)
                            VALUES(V_SAP_WRK_CD, V_ORDER_NO, '10', V_PRFM_DT, 
                                    V_MATNR_M, V_DISPO_QTY, V_WERKS, V_STOR_LOC_CD, V_LOT_NO_M, V_DOC_NO_1, TO_CHAR(V_DOC_SEQNO_1),
                                    V_SDOC_NO_PRE_1, V_SDOC_SEQNO_PRE_1, V_DATE);
    
                UPDATE TB_WRK016
                   SET CNL_YN = 'Y'
                 WHERE WERKS = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND WRK_ORDR_NO = V_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;   
                   
                INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD,
                                        WRK_ORDR_NO, WRK_ORDR_SEQNO, IND_BCD, LOT_NO, ORDER_NO, CNL_YN, REGDATE, REGID)
                                  VALUES(V_DOC_NO_1, V_DOC_SEQNO_1, '2', V_WERKS, V_MACH_CD,
                                       V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_IND_BCD_M, V_LOT_NO, V_ORDER_NO, 'Y',
                                       V_DATE, V_SESS_USER_ID);           
            ELSE
                P_SUCCESS := 'N';
                P_ERR_MSG := '폐품등록를 진행해 주세요';
                RETURN;
            END IF;
            
            V_DATA_EXIST := 1;
                
            IF V_WERKS = 'P300'THEN
                BEGIN
                SELECT NVL(CNL_YN, 'N'), NVL(SDOC_NO, 'E') INTO V_CNL_YN, V_SDOC_NO_TEMP
                  FROM (
                        SELECT W001.CNL_YN, W001.SDOC_NO
                          FROM TB_WRK001 W001
                          INNER JOIN TB_SCH013 S013
                          ON W001.WRK_ORDR_NO = S013.WRK_ORDR_NO
                          AND W001.WRK_ORDR_SEQNO = S013.WRK_ORDR_SEQNO
                          AND W001.MATNR <> S013.MATNR
                         WHERE W001.WRK_ORDR_NO = V_WRK_ORDR_NO
                           AND W001.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                        ORDER BY W001.REGDATE DESC )  
                        
--                        SELECT CNL_YN, SDOC_NO
--                          FROM TB_WRK021
--                         WHERE WERKS = V_WERKS
--                           AND MACH_CD = V_MACH_CD
--                           AND DOC_DIV = '1'
--                           AND WRK_ORDR_NO = V_WRK_ORDR_NO
--                           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
--                        ORDER BY REGDATE DESC )
                 WHERE ROWNUM = 1 ;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_DATA_EXIST := 0; 
                END ;
            ELSE
                BEGIN
                SELECT NVL(CNL_YN, 'N'), NVL(SDOC_NO, 'E') INTO V_CNL_YN, V_SDOC_NO_TEMP
                  FROM (
                        SELECT W001.CNL_YN, W001.SDOC_NO
                          FROM TB_WRK001 W001
                          INNER JOIN TB_SCH014 S013
                          ON W001.WRK_ORDR_NO = S013.WRK_ORDR_NO
                          AND W001.WRK_ORDR_SEQNO = S013.WRK_ORDR_SEQNO
                          AND W001.MATNR <> S013.MATNR
                         WHERE W001.WRK_ORDR_NO = V_WRK_ORDR_NO
                           AND W001.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                        ORDER BY W001.REGDATE DESC )  
                 WHERE ROWNUM = 1 ;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_DATA_EXIST := 0; 
                END ;
            END IF;
            
            IF V_DATA_EXIST = 0 THEN
                P_SUCCESS := 'N';
                P_ERR_MSG := '폐품이력을 찾을 수 없습니다.';
                RETURN;
            END IF;
            
            IF (V_CNL_YN = 'N' AND V_SDOC_NO_TEMP <> 'E') OR (V_CNL_YN = 'Y' AND V_SDOC_NO_TEMP = 'E') THEN     
                --실적취소
                SELECT LOT_NO, ORDER_NO, DOC_NO, DOC_SEQNO, SDOC_NO, SDOC_SEQNO, PAUFNR
                    INTO V_LOT_NO, V_ORDER_NO, V_DOC_NO_PRE_2,V_DOC_SEQNO_PRE_2, V_SDOC_NO_PRE_2, V_SDOC_SEQNO_PRE_2, V_PAUFNR
                  FROM TB_WRK001
                 WHERE WERKS = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND IND_BCD = V_IND_BCD_M;
    
                V_DOC_SEQNO_2 := V_DOC_SEQNO_2 + 1;
                INSERT INTO TB_IFS007(RUECK, RMZHL, MDOCNO, MDOCSEQ,
                                    MAKE_DATE, MAKER, WORKCENTERCODE, AUFNR, MBLNR, LOTNO)
                            VALUES(V_SDOC_NO_PRE_2, V_SDOC_SEQNO_PRE_2, V_DOC_NO_2, TO_CHAR(V_DOC_SEQNO_2),
                                    V_DATE, V_SESS_USER_ID, V_SAP_WRK_CD, V_PAUFNR, V_SDOC_NO_PRE_2, V_LOT_NO_M); 
    
                UPDATE TB_WRK001
                   SET CNL_YN = 'Y',
                       PRFM_GTHR_YN = 'N'
                  WHERE WERKS = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND IND_BCD = V_IND_BCD_M
                   AND NVL(CNL_YN, 'N') = 'N';      
                
                INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD,
                                        WRK_ORDR_NO, WRK_ORDR_SEQNO, IND_BCD, LOT_NO, ORDER_NO, CNL_YN, REGDATE, REGID)
                                  VALUES(V_DOC_NO_2, V_DOC_SEQNO_2, '1', V_WERKS, V_MACH_CD,
                                       V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_IND_BCD_M, V_LOT_NO, V_ORDER_NO, 'Y',
                                       V_DATE, V_SESS_USER_ID);  
            ELSE
                P_SUCCESS := 'N';
                P_ERR_MSG := '폐품등록를 진행해 주세요';
                RETURN;
            END IF;
        END LOOP;
        
        P_DOC_NO1 := V_DOC_NO_1;
        P_DOC_NO2 := V_DOC_NO_2;

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
