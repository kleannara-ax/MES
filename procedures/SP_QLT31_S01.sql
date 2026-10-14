
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_QLT31_S01" (
    P_TYPE          IN      VARCHAR2, -- LIST
	P_SEND_PARAM    IN      VARCHAR2,
	P_SUCCESS       OUT     VARCHAR2,
    P_CODE          OUT     VARCHAR2,
    P_MSG           OUT     VARCHAR2,
	P_RS_LIST       OUT     SYS_REFCURSOR
)

/*==============================================================================
 * PROGRAM ID    : SP_QLT31_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 선별일지 목록 조회 - 생산진행현황 목록/상세{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : {프로그램에 대한 상세한 내용 기술}
 *                 선별일지 목록 조회
 * AUTHOR NAME   : 강지선{최초 작성자 명 기술}
 * CREATE DATE   : 2024/09/09 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2024/09/09    1.0.0   강지선         최초 작성
 *==============================================================================
 *  관련 테이블
 *       - [TB_QLT030] : (.R..) 선별일지 자재코드별 Master
 *       - [TB_QLT031] : (.R..) 선별일지 Parent Table
 *       - [TB_QLT032] : (.R..) 선별일지 Detail Table
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

    -- 세션값 처리용
    V_SQL                   CLOB;
    V_DEBUG                 VARCHAR2(1);

    -- 세션값 처리용
    V_PLT_CD                VARCHAR2(2);
    V_SESS_USER_ID          VARCHAR2(20);

    -- 조건절 처리용
    V_SCH_MATNR             VARCHAR2(18);               -- 자재코드
    V_SCH_SDATE             VARCHAR2(8);                -- 선별일지 검사일 FROM  ex. YYYYMMDD
    V_SCH_EDATE             VARCHAR2(8);                -- 선별일지 검사일 TO  ex. YYYYMMDD
    V_SCH_INSPR_NM          VARCHAR2(100);              -- 검사자 이름
    V_SCH_INSPR_TM          VARCHAR2(8);                -- 검사시간대 ex. 07001500 / 07001900 / 15002300 / 19000700
    V_SCH_MACH_CD           VARCHAR2(10);               -- 설비코드(TRA02~TRA06)
    V_SCH_PART_DIV          VARCHAR2(5);                -- 품목(KT/RT)

    V_SEL_MATNR             VARCHAR2(18);               -- 자재코드
    V_SEL_MACH_CD           VARCHAR2(10);               -- 설비코드(TRA02~TRA06)
    V_SEL_PART_DIV          VARCHAR2(5);                -- 품목(KT/RT)
    V_CLSF_LARGE            VARCHAR2(100);              -- 대분류

    -- 기타 처리용
    V_STR_TEMP              VARCHAR2(500);
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('## P_TYPE = ' || P_TYPE);
    DBMS_OUTPUT.PUT_LINE('## P_SEND_PARAM = ' || P_SEND_PARAM);

    V_STR_TEMP := REPLACE(P_SEND_PARAM, '#', '"');
    DBMS_OUTPUT.PUT_LINE('## V_STR_TEMP = ' || V_STR_TEMP);
	
    OPEN P_RS_LIST FOR 
    SELECT NULL FROM DUAL WHERE ROWNUM = 0;
   
    -- Init.
    V_DEBUG := 'Y';
    V_JSON := JSON_OBJECT_T.parse(V_STR_TEMP);
    P_SUCCESS := 'N';
    P_CODE := 'E';
    P_MSG := '조회된 결과가 없습니다.';

    V_SESS_USER_ID          := V_JSON.get_string('SES_USER_ID');

    IF P_TYPE = 'LIST' THEN  /* [WEB]MES > 품질관리 > HL 순회/완제품검사 > 선별일지 */

        /* 조건값 할당 */
        V_SCH_MATNR     :=  V_JSON.get_string('SCH_MATNR');         -- 자재코드
        V_SCH_SDATE     :=  V_JSON.get_string('SCH_SDATE');         -- 선별일지 검사일 FROM  ex. YYYYMMDD
        V_SCH_EDATE     :=  V_JSON.get_string('SCH_EDATE');         -- 선별일지 검사일 TO  ex. YYYYMMDD
        V_SCH_INSPR_NM  :=  V_JSON.get_string('SCH_INSPR_ID');    -- 검사자 이름
        V_SCH_INSPR_TM  :=  V_JSON.get_string('SCH_INSPR_TM');      -- 검사시간대
        V_SCH_MACH_CD   :=  V_JSON.get_string('SCH_MACH_CD');       -- 설비호기
        V_SCH_PART_DIV  :=  V_JSON.get_string('SCH_PART_DIV');      -- 품목(KT/RT)
        
        V_SQL := '
            SELECT 
                a.SEQ, 					
                a.INSPR_DT, 			 			
                SUBSTR(a.INSPR_TM, 0, 2) || '':'' || SUBSTR(a.INSPR_TM, 3, 2) || ''~'' || SUBSTR(a.INSPR_TM, 5, 2) || '':'' || SUBSTR(a.INSPR_TM, 7, 2) AS INSPR_TM,
                CASE 
                    WHEN a.INSTD_CFG = ''Y'' THEN a.INSPR_NM || '' (대근)''
                    ELSE INSPR_NM
                END AS INSPR_NM,
                a.INSTD_CFG,
                a.MATNR, 
                b.MATNR_NM,
                b.BS_WGT,
                b.CLSF_STCNT,
                b.CLSF_MCNT,
                b.CLSF_CTCNT,
                b.CLSF_ROLL_CNT,
                a.MACH_CD, 				
                a.PART_DIV,
                a.CREATEUSER,				
                a.CREATEDATE as CLSF_INPUTDT,				
                a.UPDATEUSER,			
                a.UPDATEDATE as CLSF_MODDT,			
                a.RMK1 AS A_RMK1,		
                a.RMK2 AS A_RMK2,						
                a.RMK3 AS A_RMK3,
                c.P_SEQ,
                c.CLSF_LARGE,  
                c.CLSF_SMALL,
                c.CLSF_RST_VAL,
                c.RMK1 AS B_RMK1,
                c.RMK2 AS B_RMK2,
                c.RMK3 AS B_RMK3
            FROM TB_QLT031 a, TB_QLT030 b, TB_QLT032 c
            WHERE a.MATNR = b.MATNR
            AND a.SEQ = c.P_SEQ            
        ';

		IF V_SCH_MATNR IS NOT NULL THEN
		    V_SQL := V_SQL || ' AND a.MATNR = ''' || V_SCH_MATNR || ''' ';              -- 자재코드
		END IF;
		
		IF V_SCH_INSPR_NM IS NOT NULL THEN
		    V_SQL := V_SQL || ' AND a.INSPR_NM LIKE ''%' || V_SCH_INSPR_NM || '%'' ';   -- 검사자 이름
		END IF;

		IF V_SCH_PART_DIV IS NOT NULL THEN
		    V_SQL := V_SQL || ' AND b.PART_DIV = ''' || V_SCH_PART_DIV || ''' ';        -- 품목(KT/RT)
		END IF;

		IF V_SCH_MACH_CD IS NOT NULL THEN
            IF V_SCH_MACH_CD = 'TRA04' OR V_SCH_MACH_CD = 'TRA05' THEN
                V_SQL := V_SQL || ' AND b.MACH_CD IN (''TRA04'',  ''TRA05'') ';         -- 대근(4호기, 5호기)
            ELSE 
                V_SQL := V_SQL || ' AND b.MACH_CD = ''' || V_SCH_MACH_CD || ''' ';      -- 설비호기
            END IF;
		END IF;

		IF V_SCH_INSPR_TM IS NOT NULL THEN
		    V_SQL := V_SQL || ' AND a.INSPR_TM = ''' || V_SCH_INSPR_TM || ''' ';          -- 검사시간대
		END IF;
        
		IF V_SCH_SDATE IS NOT NULL THEN
            IF V_SCH_EDATE IS NOT NULL THEN
                V_SQL := V_SQL || ' AND a.INSPR_DT BETWEEN ''' || V_SCH_SDATE || ''' AND ''' || V_SCH_EDATE || ''' ';  -- 검사일
            END IF;
		END IF;

		IF V_SCH_MACH_CD IS NOT NULL THEN
            IF V_SCH_MACH_CD = 'TRA04' OR V_SCH_MACH_CD = 'TRA05' THEN
                V_SQL := V_SQL || ' AND a.MACH_CD IN (''TRA04'',  ''TRA05'') ';         -- 대근(4호기, 5호기)
            ELSE 
                V_SQL := V_SQL || ' AND a.MACH_CD = ''' || V_SCH_MACH_CD || ''' ';      -- 설비호기
            END IF;
		END IF;

		IF V_SCH_PART_DIV IS NOT NULL THEN
		    V_SQL := V_SQL || ' AND a.PART_DIV = ''' || V_SCH_PART_DIV || ''' ';        -- 품목(KT/RT)
		END IF;

		IF V_CLSF_LARGE IS NOT NULL THEN
		    V_SQL := V_SQL || ' AND c.CLSF_LARGE = ''' || V_CLSF_LARGE || ''' ';        -- 대분류
		END IF;

		IF V_DEBUG = 'Y' THEN
		    INSERT INTO PROC_LOG(SQL_STR) VALUES ('[SP_QLT31_S01] > ' || V_SQL);
		END IF;
		
        OPEN P_RS_LIST FOR V_SQL;

    END IF;

    P_SUCCESS := 'Y';
    P_CODE := 'S';
    P_MSG := '조회가 완료되었습니다.';

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        -- 에러 발생시 롤백하고 에러 메시지 표시
        P_SUCCESS       := 'N';
       	P_MSG			:= SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002, 'An error occurred: ' || SQLERRM);
END;
/
