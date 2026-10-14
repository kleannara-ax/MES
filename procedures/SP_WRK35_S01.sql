
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK35_S01" (
	P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : WRK35{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 재단 대기창고 현황조회{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : {프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : {최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/14 {최초 작성일자 기술}
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
 *       - [TB_MAS009] : (.R..) 거래처정보
 * 		 - [TB_MAS028] : (.R..) 로케이션
 *       - [TB_INV001] : (.R..) 재고
*        - [TB_MAS001] : (.R..) 자재
 *	     - [TB_SCH017] : (.R..) 작업지시 재단                                
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK35_S01';     -- PROCEDURE NAME

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
    V_MACHINE		TB_INV001.MACHINE%TYPE;
    V_PCODE 		TB_MAS001.PCODE%TYPE;      

    V_BS_WGT        TB_MAS001.BS_WGT%TYPE;
    V_WLEN          TB_SCH017.WLEN%TYPE;
    V_VLEN          TB_SCH017.VLEN%TYPE;
    V_IND_BCD           TB_INV001.IND_BCD%TYPE;
    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역        

    --기타처리
    V_CREATE_FLG       CHAR(1)  := 'N';
    V_UPDATE_FLG       CHAR(1)  := 'N';    

BEGIN
    OPEN P_RS_LIST FOR 
    SELECT NULL FROM DUAL WHERE ROWNUM = 0;

    V_DEBUG := 'N';
    V_RUN_SQL := 'Y';

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

    V_SESS_USER_ID       :=     V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=     V_JSON.get_string('SES_WAREKY');

    /* 조건값 할당 */
    V_RANGE_SQL          :=     V_JSON.get_string('RANGE_SQL'); 	--지종, 평량, 가로, 세로

   	V_MACHINE		     :=	    V_JSON.get_string('MACHINE');			--호기
    V_PCODE              :=		V_JSON.get_string('PCODE');			--지종
    V_BS_WGT             :=     V_JSON.get_string('BS_WGT');               -- 평량
    V_WLEN               :=     V_JSON.get_string('WLEN');                 -- 가로길이
    V_VLEN               :=     V_JSON.get_string('VLEN');                 -- 세로길이
    V_IND_BCD            :=     V_JSON.get_string('IND_BCD');              -- 개별바코드/LOT NO

    IF P_TYPE = 'LIST' THEN /*좌측 조회 리스트*/

        V_SQL := ' SELECT *
                     FROM (
                            SELECT    I001.LOC_CD           LOC_CD
                                    , CASE WHEN NVL(I001.IN_MR_YN, ''N'') =  ''N''  THEN 
--                                        CASE WHEN SUBSTR(I001.MATNR, 2, 1) = ''2'' THEN ''<div style=''''color: red''''>''
--                                             ELSE ''<div style=''''color: blue''''>''
--                                        END     
                                        CASE WHEN NVL(I001.MR_WH_YN, ''N'') = ''Y'' THEN ''<div style=''''color: black; font-weight: bold''''>''
                                             WHEN SUBSTR(I001.MATNR, 2, 1) = ''2'' AND NVL(I001.MR_WH_YN, ''N'') = ''N'' THEN ''<div style=''''color: red''''>''
                                             WHEN SUBSTR(I001.MATNR, 2, 1) = ''2'' AND NVL(I001.MR_WH_YN, ''N'') = ''Y'' THEN ''<div style=''''color: red; font-weight: bold''''>''
                                             WHEN SUBSTR(I001.MATNR, 2, 1) = ''3'' AND NVL(I001.MR_WH_YN, ''N'') = ''N'' THEN ''<div style=''''color: blue''''>''
                                             WHEN SUBSTR(I001.MATNR, 2, 1) = ''3'' AND NVL(I001.MR_WH_YN, ''N'') = ''Y'' THEN ''<div style=''''color: blue; font-weight: bold''''>''
                                             ELSE ''<div style=''''color: black''''>''
                                            END     
                                        || TO_CHAR(WC001.IF_DATE,''MM/DD HH24:MI:SS'') || ''<br>'' || I001.IND_BCD || ''<br>'' ||
                                        CASE WHEN (SELECT COUNT(*)
                                                    FROM TB_SCH017 
												   WHERE PRE_ORDER_NO = I001.ORDER_NO 
													 AND USE_YN = ''Y'') >0 THEN
                                                        (SELECT SUBSTR(S017.MATNR, 3, 3) || ''/'' || SUBSTR(S017.MATNR, 6, 3) || ''<br>'' || SUBSTR(S017.MATNR, 10, 4) || ''*'' || SUBSTR(S017.MATNR, 14, 4) 
                                                           FROM TB_SCH017 S017
                                                          WHERE S017.PRE_ORDER_NO = I001.ORDER_NO 
                                                            AND S017.USE_YN = ''Y'' AND ROWNUM = 1)
                                            ELSE
                                                SUBSTR(I001.MATNR, 3, 3) || ''/'' || SUBSTR(I001.MATNR, 6, 3) || ''<br>'' || SUBSTR(I001.MATNR, 10, 4) || ''*'' || SUBSTR(I001.MATNR, 14, 4) 
                                            END
                                      ELSE
--                                          ''<div style=''''color: black''''>'' || TO_CHAR(WC001.IF_DATE,''MM/DD HH24:MI:SS'') || ''<br>'' || I001.IND_BCD || ''<br>'' ||
                                            CASE WHEN NVL(I001.MR_WH_YN, ''N'') = ''Y'' THEN ''<div style=''''color: black; font-weight: bold''''>''
                                             WHEN SUBSTR(I001.MATNR, 2, 1) = ''2'' AND NVL(I001.MR_WH_YN, ''N'') = ''N'' THEN ''<div style=''''color: red''''>''
                                             WHEN SUBSTR(I001.MATNR, 2, 1) = ''2'' AND NVL(I001.MR_WH_YN, ''N'') = ''Y'' THEN ''<div style=''''color: red; font-weight: bold''''>''
                                             WHEN SUBSTR(I001.MATNR, 2, 1) = ''3'' AND NVL(I001.MR_WH_YN, ''N'') = ''N'' THEN ''<div style=''''color: blue''''>''
                                             WHEN SUBSTR(I001.MATNR, 2, 1) = ''3'' AND NVL(I001.MR_WH_YN, ''N'') = ''Y'' THEN ''<div style=''''color: blue; font-weight: bold''''>''
                                             ELSE ''<div style=''''color: black''''>''
                                            END     
                                        || TO_CHAR(WC001.IF_DATE,''MM/DD HH24:MI:SS'') || ''<br>'' || I001.IND_BCD || ''<br>'' ||
                                          CASE WHEN (SELECT COUNT(*)
                                                       FROM TB_SCH017
                                                      WHERE PRE_ORDER_NO = I001.LOT_NO 
														AND USE_YN = ''Y'') >0 THEN
                                                            (SELECT SUBSTR(S017.MATNR, 3, 3) || ''/'' || SUBSTR(S017.MATNR, 6, 3) || ''<br>'' || SUBSTR(S017.MATNR, 10, 4) || ''*'' || SUBSTR(S017.MATNR, 14, 4) 
                                                            FROM TB_SCH017 S017
                                                           WHERE S017.PRE_ORDER_NO = I001.LOT_NO
                                                             AND S017.USE_YN = ''Y'')
                                              ELSE
                                                  SUBSTR(I001.MATNR, 3, 3) || ''/'' || SUBSTR(I001.MATNR, 6, 3) || ''<br>'' || SUBSTR(I001.MATNR, 10, 4) || ''*'' || SUBSTR(I001.MATNR, 14, 4) 
                                              END
                                      END || ''</div>'' LOC_INFO
                                    , ROW_NUMBER() OVER(PARTITION BY I001.LOC_CD ORDER BY WC001.IF_DATE) AS SEQ
                                    FROM TB_INV001 I001
                                        , TB_MAS001 M001
                                        , TB_MAS028 M028
                                        --, TB_SCH017 S017
                                        --, TB_IFRWC001 WC001
                                        ,(SELECT * FROM TB_IFRWC001
                                             WHERE IF_SEQ||BARCODE IN (SELECT TO_CHAR(MAX(IF_SEQ)) || BARCODE FROM TB_IFRWC001 WHERE IF_DATE >= SYSDATE - 365 GROUP BY BARCODE )
                                           )WC001
                                    WHERE I001.WERKS = ''P100''
                                    AND I001.LOC_CD = M028.LOC_CD(+)
                                    AND I001.WERKS = M001.WERKS
                                    AND I001.MATNR = M001.MATNR
                                    --AND I001.ORDER_NO = S017.PRE_ORDER_NO(+)
                                    AND I001.STOR_LOC_CD = ''2700''
                                    AND I001.LOC_CD = WC001.TO_LOC(+)
                                    AND I001.IND_BCD = WC001.BARCODE(+)
                                    AND I001.LOT_NO  = WC001.LOT_ID(+)                               
                                    --AND M028.USE_YN  = ''Y''
                                    --AND S017.USE_YN  = ''Y''
                                    AND NVL(I001.DLFL, ''N'') = ''N''
                                    AND STCK_QTY > 0
                                    AND STCK_STA = ''00''
                                    --AND WC001.IF_SEQ||BARCODE IN (SELECT MAX(IF_SEQ) || BARCODE FROM TB_IFRWC001  WHERE IF_DATE >= SYSDATE - 365 GROUP BY BARCODE )  
                                    ';

        /*IF  V_PCODE IS NOT NULL OR TRIM(V_PCODE) != '' THEN
            V_SQL := V_SQL || ' AND M001.PCODE = ''' || V_PCODE || '''';              --지종';
        END IF;

        IF  V_BS_WGT IS NOT NULL OR NVL(TRIM(V_BS_WGT), 0) > 0 THEN
            V_SQL := V_SQL || ' AND M001.BS_WGT = ' || V_BS_WGT || '';              --평량;
        END IF;

        IF  V_WLEN IS NOT NULL OR NVL(TRIM(V_WLEN), 0) > 0 THEN
            V_SQL := V_SQL || ' AND S017.WLEN = ' || V_WLEN || '';              --가로;
        END IF;

        IF  V_VLEN IS NOT NULL OR NVL(TRIM(V_VLEN), 0) > 0 THEN
            V_SQL := V_SQL || ' AND S017.VLEN = ' || V_VLEN || '';              --세로;
        END IF;*/

        IF  V_RANGE_SQL IS NOT NULL OR NVL(TRIM(V_RANGE_SQL), 0) > 0 THEN
            V_SQL := V_SQL || V_RANGE_SQL ;              --지종, 평량, 가로, 세로
        END IF;                           	
                                   
        V_SQL := V_SQL || '   ORDER BY I001.LOC_CD)';
        V_SQL := V_SQL || ' PIVOT (
                     MAX(LOC_INFO)
                     FOR LOC_CD IN (''MR01'' MR01, ''MR02'' MR02, ''MR03'' MR03, ''MR04'' MR04, ''MR05'' MR05, ''MR06'' MR06, ''MR07'' MR07, ''MR08'' MR08, ''MR09'' MR09, ''MR10'' MR10, 
                                    ''MR11'' MR11, ''MR12'' MR12, ''MR13'' MR13, ''MR14'' MR14, ''MR15'' MR15, ''MR16'' MR16, ''MR17'' MR17, ''MR18'' MR18, ''MR19'' MR19, ''MR20'' MR20,
                                    ''MR21'' MR21, ''MR22'' MR22, ''MR23'' MR23, ''MR24'' MR24, ''MR25'' MR25, ''MR26'' MR26, ''MR27'' MR27, ''MR28'' MR28, ''MR29'' MR29, ''MR30'' MR30, 
                                    ''MR31'' MR31, ''MR32'' MR32, ''MR33'' MR33, ''MR34'' MR34, ''MR35'' MR35, ''MR36'' MR36, ''MR37'' MR37, ''MR38'' MR38, ''MR39'' MR39, ''MR40'' MR40, 
                                    ''MR41'' MR41, ''MR42'' MR42, ''MR43'' MR43, ''MR44'' MR44, ''MR45'' MR45)
                   )
                   WHERE ROWNUM <= 300   --개수 제한 40개
                   ORDER BY SEQ ASC';

        INSERT INTO PROC_LOG(SQL_STR, SQL_PARAM1) VALUES (V_SQL, 'WRK35_S01');

        OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SUB_LIST' THEN  /* 우측 상세 조회 리스트*/
          RETURN;

    ELSIF P_TYPE = 'SAVE' THEN
          RETURN;            

    ELSIF P_TYPE = 'SUB_SAVE' THEN
          RETURN;

    END IF;

    P_SUCCESS := 'Y';

   -- COMMIT;

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
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
