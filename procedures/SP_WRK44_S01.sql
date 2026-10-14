
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK44_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : WRK44
 * PROGRAM NAME  : 포장대기창고 현황 조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 포장대기창고 현황 조회
 *                 
 * AUTHOR NAME   : 강현주
 * CREATE DATE   : 2022/07/21
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/07/21    1.0.0   강현주         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_INV001] 	: ( R  ) 공정재고 테이블 
 *        - [TB_WRK002] 	: ( R  ) 생산실적(PS) 테이블 
 *        - [TB_MAS001] 	: ( R  ) 자재마스타 테이블
 *=============================================================================*/


AS
	V_PRG_NM          	VARCHAR2(100) 	:= 'SP_WRK44_S01';     -- PROCEDURE NAME

	-- 오라클 에러 처리용 변수선언 영역
  E_EXCEPTION_USER  	EXCEPTION;
  E_SQL_ERR_CD      	NUMBER(5) 		:= 0;
  E_SQL_ERR_MSG		    VARCHAR2(4000);

  -- JSON을 위한 변수선언 영역
    V_JSON				      JSON_OBJECT_T;
    V_ARR_LIST       	  JSON_ARRAY_T;
	V_OBJ            	  JSON_OBJECT_T;

	-- 세션값 처리용 변수선언 영역
    V_SESS_USER_ID   	  varchar2(20);
    V_PLT_CD         	  varchar2(2);
    V_DEBUG          	  varchar2(1);

	-- 조건절 처리용 변수선언 영역	
	V_SQL				        CLOB;
		
	V_WERKS        		  TB_WRK002.WERKS%TYPE;					                            --플랜트코드
	V_RANGE_SQL      	  varchar2(4000);						                                --실적일자

	V_PCODE	 		        TB_MAS001.PCODE%TYPE;			                                --지종
	V_BS_WGT	 		    TB_INV001.BS_WGT%TYPE;			                              --평량
	V_WLEN	 		        TB_WRK002.WLEN%TYPE;			                                --가로길이
	V_VLEN	 		        TB_WRK002.VLEN%TYPE;			                                --세로길이
	V_IND_BCD               TB_WRK002.IND_BCD%TYPE;			                              --개별바코드
    V_PACK_PROC             VARCHAR2(20);

BEGIN
	OPEN P_RS_LIST FOR 

	SELECT NULL FROM DUAL WHERE ROWNUM = 0;

	V_JSON 			:= JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID	:= V_JSON.get_string('SES_USER_ID');
 	V_PLT_CD		:= V_JSON.get_string('SES_PLNTKY');

    V_RANGE_SQL     := V_JSON.get_string('RANGE_SQL');                              --지종	
    V_PACK_PROC     := V_JSON.get_string('PACK_PROC');

	IF P_TYPE = 'LIST' THEN
		V_SQL :='SELECT FN_CD_VAL(''PACK_PROC'',STCK.PACK_PROC ) AS PACK_PROC
                    , STCK.MATNR
                    , STCK.MATNR_NM
                    , STCK.PCODE
                    , STCK.SPEC
                    , STCK.BS_WGT
                    , STCK.DOMESTIC
                    , STCK.LOT_NO
                    , STCK.IND_BCD
                    , STCK.ROLLCNT
                    , STCK.ROLLUNIT
                    , STCK.PCNT
                    , STCK.RUNIT
                    , STCK.WGT
                    , STCK.WUNIT
                    , STCK.KUNNR
                    , STCK.KUNNRT
                    , STCK.LAND1
                    , STCK.LAND1_NM
                  FROM(
                        SELECT DECODE(TO_NUMBER(SUBSTR(A.MATNR, 14, 4)), 0, ''R'', DECODE(ORDR.PACKTYPE, NULL, ''B'', ORDR.PACKTYPE))  AS PACK_PROC    --구분
                            , A.MATNR                                       --자재코드
                            , M001.MATNR_NM                                 --자재명
                            , M001.PCODE                                    --지종
                            , TO_CHAR(TO_NUMBER(SUBSTR(A.MATNR, 10, 4))) || ''*'' || DECODE(TO_NUMBER(SUBSTR(A.MATNR, 14, 4)), 0, ''0000'', TO_CHAR(TO_NUMBER(SUBSTR(A.MATNR, 14, 4)))) AS SPEC --규격
                            , M001.BS_WGT                       --평량
                            , DECODE(SUBSTR(A.MATNR, 5, 1), ''2'', ''수출'', ''내수'')   AS DOMESTIC
                            , A.LOT_NO                                      --LOT번호
                            , A.IND_BCD                                     --개별바코드
                            , A.ROLLCNT                                     --권치수
                            , ''M''                             AS ROLLUNIT --권치수단위
                            , A.RQTY                            AS PCNT     --연수
                            , ''R''                             AS RUNIT    --연수단위
                            , A.WGT                                         --중량
                            , ''KG''                            AS WUNIT    --중량단위
                            , ORDR.KUNNR                                    --판매처코드
                            , M009.CUST_NM                      AS KUNNRT   --판매처명
                            , M009.LAND1                                    --국가키    
                            , FN_CD_VAL(''NTN_CD'', M009.LAND1) AS LAND1_NM   --국가명
                          FROM( SELECT I001.WERKS, I001.MATNR, I001.LOT_NO, I001.IND_BCD, I001.WRK_ORDR_NO, I001.WRK_ORDR_SEQNO, 0 AS ROLLCNT, (I001.STCK_QTY /500 + NVL(I003.STCK_QTY, 0)) AS RQTY
                                    , (DECODE(NVL(I001.STCK_QTY, 0), 0,NVL(I001.WGT, 0)) + NVL(I003.WGT, 0)) AS WGT
                                  FROM TB_INV001 I001
                                  FULL OUTER JOIN (SELECT WERKS, MATNR, LOT_NO, IND_BCD, SUM(NVL(STCK_QTY, 0)) AS STCK_QTY
                                                       , SUM(DECODE(NVL(STCK_QTY, 0), 0, 0, (TO_NUMBER(SUBSTR(MATNR, 10, 4)) / 1000 *  TO_NUMBER(SUBSTR(MATNR, 14, 4)) / 1000 *  TO_NUMBER(SUBSTR(MATNR, 6, 3)) /100 * (STCK_QTY * 500)))) AS WGT   
                                                     FROM TB_INV003
                                                    WHERE WERKS = ''P100''
                                                      AND MACH_CD IN (SELECT MACH_CD FROM TB_MAS012 WHERE PROC_CD IN (''PC'', ''PB'', ''ZA''))
                                                   GROUP BY WERKS, MATNR, LOT_NO, IND_BCD) I003   
                                  ON I001.WERKS = I003.WERKS
                                  AND I001.IND_BCD = I003.IND_BCD
                                 WHERE I001.WERKS = ''P100''
                                   AND I001.STOR_LOC_CD = ''2000''
                                   AND I001.LOC_CD = ''L2600''
                                   AND NVL(I001.DLFL, ''N'') = ''N''
                                UNION ALL
                                SELECT I001.WERKS, I001.MATNR, I001.LOT_NO, I001.IND_BCD, I001.WRK_ORDR_NO, I001.WRK_ORDR_SEQNO, ROLLCNT, NULL AS RQTY, I001.STCK_QTY AS WGT
                                  FROM TB_INV001 I001    
                                 WHERE I001.WERKS = ''P100''
                                   AND I001.STOR_LOC_CD = ''2000''
                                   AND I001.LOC_CD = ''L2300''
                                   AND I001.STCK_QTY > 0
                                   AND NVL(I001.DLFL, ''N'') = ''N''
                               ) A
                          LEFT JOIN (SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, KUNNR, ''R'' AS PACKTYPE
                                       FROM TB_SCH016 
                                     UNION ALL 
                                     SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, KUNNR, PACKTYPE
                                       FROM TB_SCH017 )ORDR 
                          ON A.WRK_ORDR_NO = ORDR.WRK_ORDR_NO
                          AND A.WRK_ORDR_SEQNO = ORDR.WRK_ORDR_SEQNO
                          INNER JOIN TB_MAS001 M001
                          ON A.WERKS = M001.WERKS
                          AND A.MATNR = M001.MATNR
                          LEFT JOIN TB_MAS009 M009
                          ON ORDR.KUNNR = M009.CUST_CD
                          AND M009.CUST_DIV = ''C''
                         WHERE 1=1
                           AND A.ROLLCNT + A.RQTY > 0
                       ) STCK   
                 WHERE 1=1 ';
       
        IF (V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '') THEN               --지종
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'PACK_PROC', 'STCK.PACK_PROC');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'PCODE', 'STCK.PCODE');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'BS_WGT', 'STCK.BS_WGT');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'WLEN', 'TO_CHAR(TO_NUMBER(SUBSTR(STCK.MATNR, 10, 4)))');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'VLEN', 'TO_CHAR(TO_NUMBER(SUBSTR(STCK.MATNR, 14, 4)))');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'IND_BCD', 'STCK.IND_BCD');
            
            V_SQL := V_SQL || V_RANGE_SQL; 
        END IF;   
      
        V_SQL := V_SQL || ' ORDER BY STCK.PACK_PROC, STCK.MATNR, STCK.LOT_NO'; 

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG (SQL_STR) VALUES (V_SQL);
            COMMIT;
        END IF;

		OPEN P_RS_LIST FOR V_SQL;

	END IF;

	P_SUCCESS := 'Y';

	EXCEPTION
    WHEN E_EXCEPTION_USER THEN

    -- 에러 내역 SET
    P_SUCCESS           := 'N';
    E_SQL_ERR_CD        := SQLCODE;
		E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

		ROLLBACK;
		SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

	WHEN OTHERS THEN
		P_SUCCESS			:= 'N';
    E_SQL_ERR_CD        := SQLCODE;
		E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

		ROLLBACK;
		RAISE_APPLICATION_ERROR(-20000, E_SQL_ERR_MSG);
END;
/
