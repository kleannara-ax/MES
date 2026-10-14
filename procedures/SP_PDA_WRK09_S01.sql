
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_PDA_WRK09_S01" 
(
    P_TYPE           IN     varchar2, -- LIST, SAVE
	P_JSON_STR       IN     CLOB,
	P_SUCCESS       OUT     varchar2,
    P_ERR_MSG       OUT     VARCHAR2,
    P_DOC_NO1       OUT     VARCHAR2,
	P_RS_LIST       OUT     SYS_REFCURSOR
)
AS 
/*==============================================================================
 * PROGRAM ID    : SP_PDA_WRK09_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : PS PDA 생산반품입고{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 불출한 자재를 반품 입고한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 여한진 {최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/24 {최초 작성일자 기술}
 * SYSTEM NAME   : PDA
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/24    1.0.0   여한진         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_INV001] : (.RU.) 재고 정보
 *       - [TB_INV007] : (.R..) 자재 불출/반납 이력
 *       - [TB_SCH018] : (.R..) 포장작업지시
 *       - [TB_MAS001] : (.R..) 자재관리
   *=============================================================================*/
    --프로그램 ID
    V_PRG_NM          VARCHAR2(100)  := 'SP_PDA_WRK09_S01';     -- PROCEDURE NAME

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
    V_WERKS            TB_INV001.WERKS%TYPE;        -- 플랜트코드
    V_IND_BCD          TB_INV001.IND_BCD%TYPE;      -- 개별바코드
    V_LOC_CD           TB_INV001.LOC_CD%TYPE;       -- 로케이션

    V_STOR_LOC_FR       TB_INV001.STOR_LOC_CD%TYPE;
    V_MATNR             TB_INV001.MATNR%TYPE;
    V_LOT_NO            TB_INV001.LOT_NO%TYPE;
    V_STCK_QTY          TB_INV001.STCK_QTY%TYPE;
    V_UNIT              TB_INV001.UNIT%TYPE;
    V_VBELN             TB_INV001.VBELN%TYPE;    
    V_POSNR             TB_INV001.POSNR%TYPE;
    V_DATE              DATE := SYSDATE;
    V_DOC_NO_1          TB_INV001.DOC_NO%TYPE;
    V_DOC_SEQNO_1       TB_INV001.DOC_SEQNO%TYPE;

    V_WERKS_FR          TB_WRK017.WERKS_FR%TYPE;
    V_WERKS_TO          TB_WRK017.WERKS_FR%TYPE;
    V_MATNR_FR          TB_WRK017.MATNR_FR%TYPE;
    V_MATNR_TO          TB_WRK017.MATNR_TO%TYPE;
    --V_STOR_LOC_FR       TB_WRK017.STOR_LOC_FR%TYP
    V_STOR_LOC_TO       TB_WRK017.STOR_LOC_TO%TYPE;
    V_LOT_NO_FR         TB_WRK017.CHARG_FR%TYPE;
    V_LOT_NO_TO         TB_WRK017.CHARG_TO%TYPE;
    V_MOVE_QTY          TB_WRK017.MOVE_QTY%TYPE;
    --V_UNIT              TB_WRK017.UNIT%TYPE;
    V_SDOC_NO           TB_WRK017.SDOC_NO%TYPE;
    V_SDOC_SEQNO        TB_WRK017.SDOC_SEQNO%TYPE;
    V_VBELN_FR          TB_WRK017.VBELN_FROM%TYPE;
    V_POSNR_FR          TB_WRK017.POSNR_FROM%TYPE;
    V_VBELN_TO          TB_WRK017.VBELN_TO%TYPE;
    V_POSNR_TO          TB_WRK017.POSNR_TO%TYPE;
    V_PRD_DT            VARCHAR2(10);
BEGIN
    OPEN P_RS_LIST FOR 
    SELECT NULL FROM DUAL WHERE ROWNUM = 0;    

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);
    V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=       V_JSON.get_string('SES_WAREKY');

    /* 조건값 할당 */
    V_RANGE_SQL          :=       V_JSON.get_string('RANGE_SQL');               

    V_WERKS             :=       V_JSON.get_string('WERKS');                    -- 플랜트코드
    V_IND_BCD           :=       V_JSON.get_string('IND_BCD');                  -- 개별바코드 

    IF P_TYPE = 'LIST' THEN 
        V_SQL :='SELECT DISTINCT
                        I001.IND_BCD,       -- 포장 바코드 
                        I001.LOT_NO,        -- 포장 LOT ID
                        M001.PCODE_NM,      -- 지종
                        M001.BS_WGT,        -- 평량
                        SUBSTR(W002.MATNR, 10, 4) || ''X'' || SUBSTR(W002.MATNR, 14, 4)  MATNR_SPEC,  --규격
                        CASE WHEN W002.PACKTYPE = ''A'' THEN TO_CHAR(NVL(W002.SCNT, 0)) || ''/'' || TO_CHAR(NVL(W002.MCNT, 0))
                            WHEN W002.PACKTYPE = ''B'' THEN TO_CHAR(NVL(W002.MCNT, 0)) END SMCNT,                 --속/매
                        I001.STCK_QTY                  PRFM_QTY,      --권치수/연수
                        I001.WGT,           -- 중량
                       FN_CD_VAL(''PACK_TYPE'', W002.PACKTYPE)  AS PACKTYPE,       -- 포장타입
                       (SELECT NVL(CUST_NM, '' '') FROM TB_MAS009 WHERE CUST_DIV = ''C'' AND CUST_CD = I001.KUNNR ) KUNNR,          -- 거래처
                       FN_CD_VAL(''STCK_STA'', I001.STCK_STA)   PRD_STA     -- 포장실적상태
                  FROM TB_INV001 I001,
                       TB_MAS001 M001,
                       TB_WRK002 W002
                 WHERE I001.WERKS = M001.WERKS(+)
                   AND I001.MATNR = M001.MATNR(+)
                   AND I001.WERKS = W002.WERKS(+)
                   AND I001.IND_BCD = W002.IND_BCD(+)
                   AND I001.WERKS = ''' || V_WERKS || ''' 
                   --AND I001.STOR_LOC_CD = ''3100''
                   --AND I001.STCK_STA = ''75''
                   AND I001.STCK_QTY > 0 ';

        V_SQL := V_SQL || ' AND I001.IND_BCD = ''' || V_IND_BCD || ''' ';

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
    ELSIF P_TYPE = 'SUB_LIST' THEN       -- 대기창고조회
        V_SQL := '  SELECT ''2600'' AS LOC_CD,
                           ''생산완료창고'' AS LOC_NM
                      FROM DUAL
                     UNION ALL   
                     SELECT LOC_CD,
                            LOC_NM
                       FROM TB_MAS028
                      WHERE WERKS = ''' || V_WERKS || '''
                        AND STOR_LOC_CD IN (''2000'')
                        AND USE_YN = ''Y''
                     ORDER BY LOC_CD';
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
    ELSIF P_TYPE = 'SAVE' THEN       -- 반품반입

        V_LOC_CD       :=      V_JSON.get_string('LOC_CD');      -- 로케이션

        BEGIN        
            SELECT STOR_LOC_CD, MATNR, LOT_NO, STCK_QTY, UNIT, VBELN, POSNR
                INTO V_STOR_LOC_FR, V_MATNR, V_LOT_NO, V_STCK_QTY, V_UNIT, V_VBELN, V_POSNR
              FROM TB_INV001
             WHERE WERKS = V_WERKS
               AND IND_BCD = V_IND_BCD;

            V_DOC_NO_1 := FN_GET_MDOCNO('M','IF131');
            V_DOC_SEQNO_1 := 1;

            INSERT INTO TB_WRK017(DOC_NO, DOC_SEQNO, MOVE_DIV, WERKS_FR, WERKS_TO, MATNR_FR, MATNR_TO,
                                    STOR_LOC_FR, STOR_LOC_TO, CHARG_FR, CHARG_TO, MOVE_QTY, UNIT, RMK, REGDATE, REGID, 
                                    IND_BCD, VBELN_FROM, POSNR_FROM, VBELN_TO, POSNR_TO)
                            VALUES( V_DOC_NO_1, V_DOC_SEQNO_1, '311', V_WERKS, V_WERKS, V_MATNR, V_MATNR,
                                   V_STOR_LOC_FR, '2000', V_LOT_NO, V_LOT_NO, V_STCK_QTY, V_UNIT, '', V_DATE, V_SESS_USER_ID, 
                                   V_IND_BCD, V_VBELN, TO_CHAR(V_POSNR), V_VBELN, TO_CHAR(V_POSNR));

            --재고이전
            INSERT INTO TB_IFS009(BWART, WERKS_FROM, WERKS_TO, MATNR_FROM, MATNR_TO, LGORT_FROM, LGORT_TO,
                                CHARG_FROM, CHARG_TO, AUFNR, MENGE, MEINS, FAULTY, MDOCNO, MDOCSEQ, MAKE_DATE, MAKER, LTCHG,
                                VBELN_FROM, POSNR_FROM, VBELN_TO, POSNR_TO)
                        VALUES('311', V_WERKS, V_WERKS, V_MATNR, V_MATNR, V_STOR_LOC_FR, '2000',
                                V_LOT_NO, V_LOT_NO, '', V_STCK_QTY, V_UNIT, '', V_DOC_NO_1, V_DOC_SEQNO_1, V_DATE, V_SESS_USER_ID, '',
                                V_VBELN, TO_CHAR(V_POSNR), V_VBELN, TO_CHAR(V_POSNR));


            UPDATE TB_INV001
               SET STOR_LOC_CD = CASE WHEN SUBSTR(V_LOC_CD, 1, 1) = 'L' THEN '2600' ELSE '2000' END,
                   LOC_CD = CASE WHEN SUBSTR(V_LOC_CD, 1, 1) = 'L' THEN '' ELSE V_LOC_CD END,
                   STCK_STA = '00',
                   UPDDATE = SYSDATE,
                   UPDID = V_SESS_USER_ID
             WHERE WERKS = V_WERKS
               AND STOR_LOC_CD = '3100'
               AND IND_BCD = V_IND_BCD;
               --AND STCK_STA = '75';

            P_DOC_NO1 := V_DOC_NO_1;    
        EXCEPTION           
        WHEN OTHERS THEN 
            P_SUCCESS           := 'N';
            E_SQL_ERR_CD        := SQLCODE;
            E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
            ROLLBACK;
            RETURN;           
        END;      

    ELSIF P_TYPE = 'DELETE' THEN        --반품반입취소

        SELECT WERKS_FR, WERKS_TO, MATNR_FR, MATNR_TO, STOR_LOC_FR, STOR_LOC_TO,
                CHARG_FR, CHARG_TO, MOVE_QTY, UNIT, SDOC_NO, SDOC_SEQNO,
                VBELN_FROM, POSNR_FROM, VBELN_TO, POSNR_TO
            INTO V_WERKS_FR, V_WERKS_TO, V_MATNR_FR, V_MATNR_TO, V_STOR_LOC_FR, V_STOR_LOC_TO,
                V_LOT_NO_FR, V_LOT_NO_TO, V_MOVE_QTY, V_UNIT, V_SDOC_NO, V_SDOC_SEQNO,
                V_VBELN_FR, V_POSNR_FR, V_VBELN_TO, V_POSNR_TO
          FROM TB_WRK017
         WHERE WERKS_TO = V_WERKS
           AND IND_BCD = V_IND_BCD
           AND ROWNUM = 1
        ORDER BY REGDATE DESC;

        V_DOC_NO_1 := FN_GET_MDOCNO('M','IF132');
        V_DOC_SEQNO_1 := 1;

        INSERT INTO TB_WRK017(DOC_NO, DOC_SEQNO, MOVE_DIV, WERKS_FR, WERKS_TO, MATNR_FR, MATNR_TO,
                            STOR_LOC_FR, STOR_LOC_TO, CHARG_FR, CHARG_TO, MOVE_QTY, UNIT, RMK, REGDATE, REGID, 
                            VBELN_FROM, POSNR_FROM, VBELN_TO, POSNR_TO)
                    VALUES( V_DOC_NO_1, V_DOC_SEQNO_1, '311', V_WERKS_TO, V_WERKS_FR, V_MATNR_TO, V_MATNR_FR,
                           V_STOR_LOC_TO, V_STOR_LOC_FR, V_LOT_NO_TO, V_LOT_NO_FR, V_MOVE_QTY, V_UNIT, '', V_DATE, V_SESS_USER_ID, 
                           V_VBELN_TO, TO_CHAR(V_POSNR_TO), V_VBELN_FR, TO_CHAR(V_POSNR_FR));

        V_PRD_DT := TO_CHAR(V_DATE, 'YYYYMMDD');                            
        INSERT INTO TB_IFS010( AUFNR, POSNR, BUDAT, MATNR, MENGE, WERKS, LGORT, CHARG,
                            WORKCENTERCODE, MDOCNO, MDOCSEQ, MBLNR, MJAHR, MAKE_DATE, MAKER)
                     VALUES('', '', V_PRD_DT, V_MATNR_TO, V_MOVE_QTY, V_WERKS_TO, V_STOR_LOC_TO, V_LOT_NO_TO,
                            '', V_DOC_NO_1, TO_CHAR(V_DOC_SEQNO_1), V_SDOC_NO, V_SDOC_SEQNO, V_DATE, V_SESS_USER_ID) ;

        UPDATE TB_INV001
               SET STOR_LOC_CD = '3100',
                   LOC_CD = '',
                   STCK_STA = '00',
                   --STCK_STA = '75',
                   UPDDATE = SYSDATE,
                   UPDID = V_SESS_USER_ID
             WHERE WERKS = V_WERKS
               AND STOR_LOC_CD = '2000'
               AND IND_BCD = V_IND_BCD
               AND STCK_QTY > 0;

        P_DOC_NO1 := V_DOC_NO_1;    
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
