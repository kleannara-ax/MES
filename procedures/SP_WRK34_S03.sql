
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK34_S03" (
    P_TYPE          IN      VARCHAR2, -- LIST, SAVE
	P_SEND_PARAM    IN      VARCHAR2,
	P_SUCCESS       OUT     VARCHAR2,
    P_CODE          OUT     VARCHAR2 ,
    P_MSG           OUT     VARCHAR2 ,
	P_RS_LIST       OUT     SYS_REFCURSOR
)

/*==============================================================================
 * PROGRAM ID    : SP_WRK34_S03{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 예외생산 - 투입대기자재 조회/투입 Popup{호출 프로그램 명 기술}
 * VERSION       : 1.0.3{최종 버전 기술}
 * DESCRIPTION   : {프로그램에 대한 상세한 내용 기술}
 *                 예외생산(화장지,생리대,기저귀) > 투입대기자재 Button 선택 시 Popup
 * AUTHOR NAME   : 강지선{최초 작성자 명 기술}
 * CREATE DATE   : 2024/07/18 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2024/07/18    1.0.0   강지선         최초 작성
 * 2024/07/24    1.0.1   강지선         P_TYPE=SAVE 추가
 * 2024/08/05    1.0.2   강지선         LIST/SAVE Query & Process 수정
 * 2024/10/17	 1.0.3   강지선		  표시명 수정 - '투입' > '투입대기'
 *==============================================================================
 *  관련 테이블
 *       - [TB_INV001] : (.R..) 공정재고
*        - [TB_INV003] : (.R..) 자재투입(자재 현 투입상태)
*        - [TB_MAS001] : (.R..) 자재기준정보
 *	     - [TB_SCH020] : (.R..) 작업지시 BOM
 *=============================================================================*/

AS
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER        EXCEPTION;
    E_SQL_ERR_CD            NUMBER(5)           := 0;
    E_SQL_ERR_MSG           VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON                  JSON_OBJECT_T;
    V_ARR_LIST              JSON_ARRAY_T;
    V_OBJ                   JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL                   CLOB;
    V_RUN_SQL               VARCHAR2(1);
    V_RANGE_SQL             VARCHAR2(4000);
    V_DEBUG                 VARCHAR2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD                VARCHAR2(2);
    V_SESS_USER_ID          VARCHAR2(20);

    -- 조건절 처리 & 리스트(그리드) 값 변수선언 영역
    V_WERKS                 VARCHAR2(10);               -- 플랜트
    V_ORG_WRK_ORDR_NO       VARCHAR2(20);               -- 작업지시번호(부모창에서 선택한)
    V_ORG_WRK_ORDR_SEQNO    VARCHAR2(10);               -- 작업지시순번(부모창에서 선택한)
    V_MATNR                 VARCHAR2(20);               -- 자재코드
    V_MATNR_NM              VARCHAR2(1000);             -- 자재명
    V_STOR_LOC_NM           VARCHAR2(1000);             -- 저장위치명
    V_ORDER_BOM_QTY         NUMBER(16,3);               -- 오더BOM 수량
    V_UNIT                  VARCHAR2(10);               -- 단위
    V_IND_BCD               VARCHAR2(20);               -- 업체/개별 바코드
    V_LOT_NO                VARCHAR2(10);               --LOT_NO
    V_MACH_CD               VARCHAR2(10);               -- 설비코드 
    V_ORG_MACH_CD           VARCHAR2(10);               -- 설비코드(부모창에서 선택한) 
    V_SEQNO                 NUMBER;                     -- 순번
    V_WRK_ORDR_NO           VARCHAR2(20);               -- 작업지시번호(화면 표시용)
    V_WRK_ORDR_SEQNO        VARCHAR2(10);               -- 작업지시순번(화면 표시용)

    V_ORDER_NO              VARCHAR2(20);               -- 오더번호

    --기타처리
    V_CREATE_FLG            CHAR(1)  := 'N';
    V_UPDATE_FLG            CHAR(1)  := 'N';    

    V_STR_TEMP              VARCHAR2(4000);

    V_STCK_QTY              NUMBER(13,3);               -- 재고수량
    V_INP_QTY               NUMBER(13,3);               -- 투입수량

    V_STCK_QTY01            NUMBER(13,3);               -- TB_INV001 재고수량
    V_STCK_QTY03            NUMBER(13,3);               -- TB_INV003 재고수량

    V_NEW_SEQNO             NUMBER;                     -- NEW SEQNO

    V_ROLLCNT               NUMBER(23,3);               -- 권치수(점보롤, 밀롤, 합지기)
    V_WGT                   NUMBER(23,3);               -- 중량(재단,포장공정)

BEGIN
    DBMS_OUTPUT.PUT_LINE('## P_TYPE = ' || P_TYPE);
    DBMS_OUTPUT.PUT_LINE('## P_SEND_PARAM = ' || P_SEND_PARAM);

    V_STR_TEMP := REPLACE(P_SEND_PARAM, '#', '"');
    DBMS_OUTPUT.PUT_LINE('## V_STR_TEMP = ' || V_STR_TEMP);
	
    OPEN P_RS_LIST FOR 
    SELECT NULL FROM DUAL WHERE ROWNUM = 0;
   
    -- Init.
    V_DEBUG := 'Y';
    V_NEW_SEQNO := 1;
    V_JSON := JSON_OBJECT_T.parse(V_STR_TEMP);

    V_SESS_USER_ID          := V_JSON.get_string('SES_USER_ID');

    IF P_TYPE = 'LIST' THEN  /* 투입대기자재 POP UP 조회 리스트 */

        /* 조건값 할당 */
        V_WERKS             :=  V_JSON.get_string('P_WERKS');	        -- (부모창에서 선택한)플랜트
        V_MATNR             :=  V_JSON.get_string('P_MATNR');           -- (부모창에서 선택한)자재코드
        V_WRK_ORDR_NO       :=  V_JSON.get_string('P_WRK_ORDR_NO');     -- (부모창에서 선택한)작업지시번호
        V_WRK_ORDR_SEQNO    :=  V_JSON.get_string('P_WRK_ORDR_SEQNO');  -- (부모창에서 선택한)작업지시순번
        V_MACH_CD           :=  V_JSON.get_string('P_MACH_CD');         -- (부모창에서 선택한)설비코드

        V_SQL := 'WITH INPUT_HOLD AS (
            SELECT  
                SCH020.MATNR                MATNR              -- 자재
                , MAS001.MATNR_NM           MATNR_NM           -- 자재명
                , ''투입대기''                STOR_LOC_NM        -- 저장위치명
                , INV003.UNIT               UNIT               -- 단위
                , SCH020.WERKS              WERKS              -- 플랜트  
                , INV003.SEQNO 				SEQNO			   -- 순번
                , INV003.MACH_CD            MACH_CD            -- 설비코드
                , INV003.IND_BCD            IND_BCD            -- 개별바코드
                , INV003.IN_QTY             INP_QTY            -- 투입량
                , INV003.USE_QTY            USE_QTY            -- 사용량
                , INV003.STCK_QTY           STCK_QTY           -- 재고량
                , INV003.WRK_ORDR_NO        WRK_ORDR_NO        -- 작업지시번호
                , INV003.WRK_ORDR_SEQNO     WRK_ORDR_SEQNO     -- 작업지시순번  
            FROM TB_SCH020  SCH020      -- 작업지시 BOM
                , TB_MAS001  MAS001     -- 플랜트별 제품/자재 마스터
                , TB_INV003  INV003     -- 자재투입(자재 현 투입상태)
            WHERE SCH020.MATNR   = MAS001.MATNR 
                AND SCH020.MATNR = INV003.MATNR
                AND SCH020.WERKS = MAS001.WERKS
                AND SCH020.WERKS = INV003.WERKS 
                AND MAS001.MATNR_DIV IN (''FERT'', ''HAWA'')
                AND INV003.STCK_QTY > 0
				AND NVL(SCH020.DLFL, ''N'') = ''N''
        ';        
        V_SQL := V_SQL || '     AND SCH020.WERKS = ''' || V_WERKS || '''' ;                 -- 플랜트
        V_SQL := V_SQL || '     AND SCH020.WRK_ORDR_NO = ''' || V_WRK_ORDR_NO || '''';      -- 작업지시번호
        V_SQL := V_SQL || '     AND INV003.WRK_ORDR_NO <> ''' || V_WRK_ORDR_NO || '''';     -- 작업지시번호
        V_SQL := V_SQL || '     AND INV003.MACH_CD = ''' || V_MACH_CD || '''';              -- 설비코드
        V_SQL := V_SQL || ' UNION ALL ';
        V_SQL := V_SQL || ' 
            SELECT  
                SCH020.MATNR                MATNR             -- 자재
                , MAS001.MATNR_NM           MATNR_NM          -- 자재명
                , ''2000''              STOR_LOC_NM        -- 저장위치명(공정재고)
                , INV001.UNIT              UNIT               -- 단위
                , SCH020.WERKS             WERKS              -- 플랜트  
                , null                     SEQNO			  -- 순번
                , INV001.MACH_CD           MACH_CD            -- 설비코드
                , INV001.IND_BCD           IND_BCD            -- 개별바코드
                , null                     INP_QTY            -- 투입량
                , null                     USE_QTY            -- 사용량
                , INV001.STCK_QTY          STCK_QTY           -- 재고량
                , INV001.WRK_ORDR_NO       WRK_ORDR_NO        -- 작업지시번호
                , INV001.WRK_ORDR_SEQNO    WRK_ORDR_SEQNO     -- 작업지시순번
            FROM TB_SCH020  SCH020      -- 작업지시 BOM
                , TB_MAS001  MAS001     -- 플랜트별 제품/자재 마스터
                , TB_INV001  INV001     -- 공정재고
            WHERE SCH020.MATNR      = MAS001.MATNR 
                AND SCH020.WERKS    = MAS001.WERKS
                AND SCH020.MATNR    = INV001.MATNR
                AND SCH020.WERKS    = INV001.WERKS 
                AND INV001.STOR_LOC_CD  = ''2000''
                AND MAS001.MATNR_DIV IN (''FERT'', ''HAWA'')
                AND INV001.STCK_QTY > 0
                AND INV001.STCK_STA = ''00''
				AND NVL(SCH020.DLFL, ''N'') = ''N''
        ';

        V_SQL := V_SQL || ' AND SCH020.WRK_ORDR_NO = ''' || V_WRK_ORDR_NO || '''';     -- 작업지시번호
        V_SQL := V_SQL || ' AND INV001.WERKS = ''' || V_WERKS || '''';                  -- 플랜트        
        
        
        V_SQL := V_SQL || ' UNION ALL ';
        V_SQL := V_SQL || '
            SELECT  
                SCH020.MATNR                MATNR              -- 자재
                , MAS001.MATNR_NM           MATNR_NM           -- 자재명
                , ''투입''                STOR_LOC_NM        -- 저장위치명
                , INV003.UNIT               UNIT               -- 단위
                , SCH020.WERKS              WERKS              -- 플랜트  
                , INV003.SEQNO 				SEQNO			   -- 순번
                , INV003.MACH_CD            MACH_CD            -- 설비코드
                , INV003.IND_BCD            IND_BCD            -- 개별바코드
                , INV003.IN_QTY             INP_QTY            -- 투입량
                , INV003.USE_QTY            USE_QTY            -- 사용량
                , INV003.STCK_QTY           STCK_QTY           -- 재고량
                , INV003.WRK_ORDR_NO        WRK_ORDR_NO        -- 작업지시번호
                , INV003.WRK_ORDR_SEQNO     WRK_ORDR_SEQNO     -- 작업지시순번  
            FROM TB_SCH020  SCH020      -- 작업지시 BOM
                , TB_MAS001  MAS001     -- 플랜트별 제품/자재 마스터
                , TB_INV003  INV003     -- 자재투입(자재 현 투입상태)
            WHERE SCH020.MATNR   = MAS001.MATNR 
                AND SCH020.MATNR = INV003.MATNR
                AND SCH020.WERKS = MAS001.WERKS
                AND SCH020.WERKS = INV003.WERKS 
                AND MAS001.MATNR_DIV IN (''FERT'', ''HAWA'')
                AND INV003.STCK_QTY > 0
				AND NVL(SCH020.DLFL, ''N'') = ''N''
        ';        
        V_SQL := V_SQL || '     AND SCH020.WERKS = ''' || V_WERKS || '''' ;                 -- 플랜트
        V_SQL := V_SQL || '     AND SCH020.WRK_ORDR_NO = ''' || V_WRK_ORDR_NO || '''';      -- 작업지시번호
        V_SQL := V_SQL || '     AND INV003.WRK_ORDR_NO = ''' || V_WRK_ORDR_NO || '''';     -- 작업지시번호
        V_SQL := V_SQL || '     AND INV003.MACH_CD = ''' || V_MACH_CD || '''';              -- 설비코드
        
        
        V_SQL := V_SQL || ' ORDER BY STOR_LOC_NM, MATNR, SEQNO';
        V_SQL := V_SQL || ' ) ';
        V_SQL := V_SQL || ' SELECT ROWNUM AS SEQNO, INPUT_HOLD.* FROM INPUT_HOLD ';

DBMS_OUTPUT.PUT_LINE ('V_SQL = ' || V_SQL);
        V_DEBUG := 'Y';
        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

        OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SAVE' THEN  -- 공정투입
        V_ARR_LIST        := V_JSON.get_array('INSERT_LIST');

        V_ORG_WRK_ORDR_NO       :=  V_JSON.get_string('ORG_WRK_ORDR_NO');     -- (부모창에서 선택한)작업지시번호
        V_ORG_WRK_ORDR_SEQNO    :=  V_JSON.get_string('ORG_WRK_ORDR_SEQNO');  -- (부모창에서 선택한)작업지시순번
        V_ORG_MACH_CD           :=  V_JSON.get_string('ORG_MACH_CD');         -- (부모창에서 선택한)설비코드

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ						:= TREAT (V_ARR_LIST.get (i) AS json_object_t);  

            V_STOR_LOC_NM               := V_OBJ.get_string('STOR_LOC_NM');                             -- 저장위치명
            V_WERKS	                    := V_OBJ.get_string('WERKS');                                   -- 플랜트코드
            V_MACH_CD                   := V_OBJ.get_string('MACH_CD');                                 -- 설비코드
            V_MATNR                     := V_OBJ.get_string('MATNR');                                   -- 자재코드
            V_IND_BCD                   := V_OBJ.get_string('IND_BCD');                                 -- 업체/개별 바코드
            V_INP_QTY                   := TO_NUMBER(REPLACE(V_OBJ.get_string('INP_QTY'), ' ', ''));    -- 투입수량
            V_STCK_QTY                  := TO_NUMBER(V_OBJ.get_string('STCK_QTY'));                     -- 재고수량
            V_WRK_ORDR_NO               := V_OBJ.get_string('WRK_ORDR_NO');                             -- 작업지시번호
            V_WRK_ORDR_SEQNO            := V_OBJ.get_string('WRK_ORDR_SEQNO');                          -- 작업지시순번  
            V_UNIT                      := V_OBJ.get_string('UNIT');                                    -- 단위  
            V_LOT_NO                    := V_OBJ.get_string('LOT_NO');                                  -- LOT_NO

DBMS_OUTPUT.PUT_LINE('  ');
DBMS_OUTPUT.PUT_LINE('## V_ORG_WRK_ORDR_NO = ' || V_ORG_WRK_ORDR_NO);
DBMS_OUTPUT.PUT_LINE('## V_ORG_WRK_ORDR_SEQNO = ' || V_ORG_WRK_ORDR_SEQNO);
DBMS_OUTPUT.PUT_LINE('  ');
DBMS_OUTPUT.PUT_LINE('## V_WRK_ORDR_NO = ' || V_WRK_ORDR_NO);
DBMS_OUTPUT.PUT_LINE('## V_WRK_ORDR_SEQNO = ' || V_WRK_ORDR_SEQNO);
DBMS_OUTPUT.PUT_LINE('  ');

            -- STEP 1) 부모창에서 선택한 작업지시로 있으면 UPDATE, 없으면 INSERT, 팝업의 작업지시는 DELETE
            V_UPDATE_FLG := 'Y';
            V_CREATE_FLG := 'N';

            -- LOT_NO
            IF NVL(V_LOT_NO, ' ') = ' '	THEN
	            SELECT	LOT_NO INTO V_LOT_NO
	            FROM	TB_INV001
	            WHERE 	WERKS = V_WERKS
	            AND		IND_BCD = V_IND_BCD;
            END IF;
           
            -- #1. TB_INV003에서 STCK_QTY, MAX SEQNO 추출
            BEGIN
                SELECT NVL(STCK_QTY, 0)
                INTO V_STCK_QTY03
                FROM TB_INV003
                WHERE WRK_ORDR_NO   = V_ORG_WRK_ORDR_NO
                AND WRK_ORDR_SEQNO  = V_ORG_WRK_ORDR_SEQNO
                AND WERKS = V_WERKS
                AND MACH_CD = V_ORG_MACH_CD
                AND MATNR = V_MATNR
                AND IND_BCD = V_IND_BCD
                ;

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_STCK_QTY03 := 0;
            END
            ;

            SELECT NVL(MAX(SEQNO), 0) + 1
            INTO V_NEW_SEQNO
            FROM TB_INV003
            WHERE WRK_ORDR_NO   = V_ORG_WRK_ORDR_NO
            AND WRK_ORDR_SEQNO  = V_ORG_WRK_ORDR_SEQNO
            AND WERKS = V_WERKS
            AND MACH_CD = V_ORG_MACH_CD
--            AND MATNR = V_MATNR
--            AND IND_BCD = V_IND_BCD
            ;
            
            IF (V_NEW_SEQNO = 1) THEN
                V_UPDATE_FLG := 'N';
                V_CREATE_FLG := 'Y';
            END IF;
            
DBMS_OUTPUT.PUT_LINE('## V_STCK_QTY03 = ' || V_STCK_QTY03);
DBMS_OUTPUT.PUT_LINE('## V_NEW_SEQNO = ' || V_NEW_SEQNO);
DBMS_OUTPUT.PUT_LINE('## V_UPDATE_FLG = ' || V_UPDATE_FLG);
DBMS_OUTPUT.PUT_LINE('## V_CREATE_FLG = ' || V_CREATE_FLG);
DBMS_OUTPUT.PUT_LINE('  ');

            -- #2. TB_INV003에 존재하는 data row DELETE(팝업 작업지시 기준)
            DELETE FROM TB_INV003 
            WHERE WRK_ORDR_NO     = V_WRK_ORDR_NO
            AND WRK_ORDR_SEQNO    = V_WRK_ORDR_SEQNO
            -- 2024.11.13 백우종 추가
            AND WERKS = V_WERKS
            AND MACH_CD = V_ORG_MACH_CD
            AND MATNR = V_MATNR
            AND IND_BCD = V_IND_BCD
            ;

            -- #3.TB_INV003 INSERT
            IF V_CREATE_FLG = 'Y' THEN
                INSERT INTO TB_INV003     -- 자재투입 
                (
                    WERKS               -- 플랜트 코드
                    , MACH_CD           -- 설비코드
                    , MATNR             -- 자재코드
                    , IND_BCD           -- 업체/개별 바코드
                    , SEQNO             -- 순번
                    , WRK_ORDR_NO       -- 작업지시번호
                    , WRK_ORDR_SEQNO	-- 작업지시순번
                    , LOT_NO            -- LOT_NO
                    , INP_DT            -- 투입일자
                    , IN_QTY            -- 투입량
                    , USE_QTY           -- 사용량
                    , STCK_QTY          -- 재고량
                    , UNIT              -- 단위
                    , ROLLCNT           -- 권치수(점보롤, 밀롤, 합지기)
                    , WGT               -- 중량(재단,포장공정)
                    , CHG_FLG           -- 대체여부
                    , STCK_KY           -- WMS 지점코드
                    , LOT_NUM           -- WMS LOT 속성 KY
                    , REGDATE           -- 등록일시
                    , REGID             -- 등록자
                    , UPDDATE           -- 수정일시
                    , UPDID             -- 수정자           
                ) VALUES (
                    V_WERKS                                 -- 플랜트 코드
                    ,V_ORG_MACH_CD	                        -- 설비코드
                    ,V_MATNR	                            -- 자재코드
                    ,V_IND_BCD	                            -- 개별 바코드
                    ,V_NEW_SEQNO                            -- 순번
                    ,V_ORG_WRK_ORDR_NO	                    -- 작업지시번호
                    ,V_ORG_WRK_ORDR_SEQNO	                -- 작업지시순번
                    ,V_LOT_NO	                            -- LOT_NO
                    ,TO_CHAR(SYSDATE,'YYYYMMDD')	        -- 투입일자
                    ,V_STCK_QTY                             -- 투입량
                    ,0                                      -- 사용량
                    ,V_STCK_QTY                             -- 재고수량
                    ,V_UNIT                                 -- 단위
                    ,0                                      -- 권치수(점보롤, 밀롤, 합지기)
                    ,0                                      -- 중량(재단,포장공정)
                    ,NULL    	                            -- 대체여부
                    ,NULL	                                -- WMS 지점코드
                    ,NULL	                                -- WMS LOT 속성 KY
                    ,SYSDATE	                            -- 등록일시
                    ,V_SESS_USER_ID	                        -- 등록자
                    ,NULL	                                -- 수정일시
                    ,NULL	                                -- 수정자                      
                );
            ELSE
                -- #3.TB_INV003 UPDATE
                INSERT INTO TB_INV003     -- 자재투입 
                (
                    WERKS               -- 플랜트 코드
                    , MACH_CD           -- 설비코드
                    , MATNR             -- 자재코드
                    , IND_BCD           -- 업체/개별 바코드
                    , SEQNO             -- 순번
                    , WRK_ORDR_NO       -- 작업지시번호
                    , WRK_ORDR_SEQNO	-- 작업지시순번
                    , LOT_NO            -- LOT_NO
                    , INP_DT            -- 투입일자
                    , IN_QTY            -- 투입량
                    , USE_QTY           -- 사용량
                    , STCK_QTY          -- 재고량
                    , UNIT              -- 단위
                    , ROLLCNT           -- 권치수(점보롤, 밀롤, 합지기)
                    , WGT               -- 중량(재단,포장공정)
                    , CHG_FLG           -- 대체여부
                    , STCK_KY           -- WMS 지점코드
                    , LOT_NUM           -- WMS LOT 속성 KY
                    , REGDATE           -- 등록일시
                    , REGID             -- 등록자
                    , UPDDATE           -- 수정일시
                    , UPDID             -- 수정자           
                ) VALUES (
                    V_WERKS                                 -- 플랜트 코드
                    ,V_ORG_MACH_CD	                        -- 설비코드
                    ,V_MATNR	                            -- 자재코드
                    ,V_IND_BCD	                            -- 개별 바코드
                    ,V_NEW_SEQNO                            -- 순번
                    ,V_ORG_WRK_ORDR_NO	                    -- 작업지시번호
                    ,V_ORG_WRK_ORDR_SEQNO	                -- 작업지시순번
                    ,V_LOT_NO	                            -- LOT_NO
                    ,TO_CHAR(SYSDATE,'YYYYMMDD')	        -- 투입일자
                    ,V_STCK_QTY                             -- 투입량
                    ,0                                      -- 사용량
                    ,V_STCK_QTY                             -- 재고수량
                    ,V_UNIT                                 -- 단위
                    ,0                                      -- 권치수(점보롤, 밀롤, 합지기)
                    ,0                                      -- 중량(재단,포장공정)
                    ,NULL    	                            -- 대체여부
                    ,NULL	                                -- WMS 지점코드
                    ,NULL	                                -- WMS LOT 속성 KY
                    ,SYSDATE	                            -- 등록일시
                    ,V_SESS_USER_ID	                        -- 등록자
                    ,NULL	                                -- 수정일시
                    ,NULL	                                -- 수정자                      
                );
--                UPDATE TB_INV003
--                SET 
--                    STCK_QTY = V_STCK_QTY + V_STCK_QTY03
--                    , IN_QTY = V_STCK_QTY + V_STCK_QTY03
--                    , UPDDATE = SYSDATE
--                    , UPDID = V_SESS_USER_ID
--                WHERE WRK_ORDR_NO   = V_ORG_WRK_ORDR_NO
--                AND WRK_ORDR_SEQNO  = V_ORG_WRK_ORDR_SEQNO
--                -- 2024.11.13 백우종 추가
--                AND WERKS = V_WERKS
--                AND MACH_CD = V_ORG_MACH_CD
--                AND MATNR = V_MATNR
--                AND IND_BCD = V_IND_BCD
--                ;
            END IF;

            -- STEP 2) 성공일 경우 TB_INV001의 STCK_QTY, PLT_QTY, BOX_QTY, BAG_QTY, EA_QTY = 0 & STCK_STA = '10'
            --      >> WERKS, STOR_LOC_CD, IND_BCD, MATNR 기준
            UPDATE TB_INV001
            SET
                STCK_QTY = 0,
                PLT_QTY = 0,
                BOX_QTY = 0,
                BAG_QTY = 0,
                EA_QTY = 0, 
                STCK_STA = 10, 
                WRK_ORDR_NO = V_ORG_WRK_ORDR_NO,
                WRK_ORDR_SEQNO = V_ORG_WRK_ORDR_SEQNO
            WHERE WERKS = V_WERKS
            AND STOR_LOC_CD = '2000'
            AND IND_BCD = V_IND_BCD
            AND MATNR = V_MATNR
            ;

        END LOOP;

    END IF;

    P_SUCCESS := 'Y';
    P_CODE := 'S';

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
