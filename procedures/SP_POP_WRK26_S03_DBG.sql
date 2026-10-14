
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK26_S03_DBG" 
(
    P_WERKS     		IN VARCHAR2 	    --플랜트
    ,P_MACH_CD   		IN VARCHAR2 	    --설비코드
    ,P_IND_BCD          IN VARCHAR2 	    --개별바코드
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
    ,CUR_1       		OUT SYS_REFCURSOR
)
AS 
    --프로그램 ID - 재단인쇄용 조회
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK26_S03';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    --내부 변수 등록
    V_WERKS                 TB_WRK002.WERKS%TYPE;
    V_IND_BCD_MIN           TB_WRK002.IND_BCD%TYPE;
    V_MACH_NM               TB_MAS012.MACH_NM%TYPE;   -- 설비명

    V_WRK_TYPE              varchar2(2);

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리
    
    
BEGIN
    BEGIN

        SELECT MACH_NM INTO V_MACH_NM
            FROM TB_MAS012 
            WHERE MACH_CD = P_MACH_CD;

        BEGIN
            SELECT DECODE(SUBSTR(WRK_ORDR_NO,1,4), 'WOEX', 'X', 'Y')   -- 작업유형 : 'Y'는 정규생산, 'X'는 예외생산
                INTO V_WRK_TYPE
                FROM TB_WRK002
                WHERE WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IND_BCD  = P_IND_BCD;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            RS_CODE := 'E';
            RS_MSG := 'NO_DATA_FOUND';
            RETURN;            
        END;
        --작업유형 : 'Y'는 정규생산, 'X'는 예외생산
        IF V_WRK_TYPE = 'Y' THEN
            OPEN CUR_1 FOR
            SELECT V_WRK_TYPE                      WRK_TYPE            --작업유형
                , M001.PCODE_NM                    PCODE_NM            --지종
                , NVL(S017.BS_WGT, '0')             BS_WGT              --평량
                , CASE WHEN NVL(W002.MAN_CUT_YN, 'N') = 'N' THEN SUBSTR(W002.MATNR, 10, 4) || '*' || SUBSTR(W002.MATNR, 14, 4) 
                    ELSE (LTRIM(TO_CHAR(W002.WLEN, '0999'), ' ' ) || '*' || LTRIM(TO_CHAR(W002.VLEN, '0999'), ' '))  END      AS MATNR_SPEC  --규격
                --, NVL(W002.PRFM_QTY, '0')           PRFM_REAM           --실적연수
                --, SUBSTR(W002.MATNR, 10, 4) || '*' || SUBSTR(W002.MATNR, 14, 4)     MATNR_SPEC_MAS  --수재단이동인경우 원규격 표시위해 추가
                , NVL(W002.PCNT, '0')           PRFM_REAM           --실적연수
                , NVL(W002.WGT, '0')                PRFM_WGT            --실적중량
                , NVL(S017.PLT_PER_CNT, '0')        PLT_PER_CNT         --팔레트당 연수
                , NVL(S017.IN_PER_CNT, '0')         IN_PER_CNT          --속당매수 (속수=(팔레트당연수*500)/속당매수)
                , W002.WRK_SEQ                      WRK_SEQ             --생산순번
                , W002.WIDTH_NO                     WIDTH_NO            --지폭순서
                , W002.MAN_CUT_YN                   MAN_CUT_YN          --수재단이동여부
                , S015.MACHINE                      JR_MACHINE_NM       --점보롤호기
                , (SELECT MACH_CD
                    FROM TB_WRK002
                   WHERE WERKS = P_WERKS
                     AND IND_BCD = (SELECT A.IND_BCD_M
                                      FROM(SELECT IND_BCD_M
                                            FROM TB_INV010
                                           WHERE WERKS= P_WERKS
                                             AND MACH_CD = P_MACH_CD
                                             AND IND_BCD = P_IND_BCD
                                             AND NVL(CNL_YN,'N') = 'N'
                                          ORDER BY REGDATE DESC   
                                         ) A
                                     WHERE ROWNUM = 1)
                  )  AS MR_MACHINE_NM                   
                --, S016.MACHINE                      MR_MACHINE_NM       --밀롤호기
                --, S016.TO_MACHINE                   CT_MACHINE_NM       --재단호기
                , V_MACH_NM                         CT_MACHINE_NM       --재단설비명
--                , W002.PACKTYPE                     PACKTYPE            --포장타입
                , NVL(FN_CD_VAL('PACK_TYPE', S017.PACKTYPE), ' ')     PACKTYPE  --포장타입
                , M009.CUST_NM                      CUST_NM             --거래처명
                , M009.LAND1                        LAND_CD             --국가코드
                , NVL(FN_CD_VAL('NATNKY', M009.LAND1), ' ')  LAND_NM    --국가명
                , TO_CHAR(W002.REGDATE, 'YYYY-MM-DD HH24:MI') WRK_DATE  --생산일시
                , W002.WRK_CLASS                    WRK_CLASS           --반
                , USRMA.NMLAST                      WRK_NAME            --작업자
                , USRMA.USERID                      WRK_ID              --작업자 ID
                , W002.LOT_NO                       LOT_NO             --LOT NO 
                , S017.VBELN || LPAD(S017.POSNR, 6, '0')    SALES_ORDR_NO            --Sales Order No
                , S017.ORDER_RMK                            ORDER_RMK                     -- 생산오더 비고사항
                , W002.RUN_STA                                  -- 운전상태 01 : 정상, 09 : 여유생산(재단인경우)
                , W002.RMK                                      -- 비고사항
              FROM TB_WRK002 W002,
                   TB_MAS001 M001,
                   (SELECT CUST_CD, CUST_NM, LAND1 
                        FROM TB_MAS009
                        WHERE CUST_DIV = 'C') M009,
                   USRMA USRMA,
                   TB_SCH015 S015,
                   TB_SCH016 S016,
                   TB_SCH017 S017
             WHERE W002.WERKS = S017.WERKS(+)
               AND W002.WRK_ORDR_NO = S017.WRK_ORDR_NO(+)
               AND W002.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO(+)
               AND S017.PRE_ORDER_NO = S016.ORDER_NO(+)
               AND S016.PRE_ORDER_NO = S015.ORDER_NO(+)
               AND W002.WERKS = M001.WERKS(+)
               AND W002.MATNR = M001.MATNR(+)
               AND W002.KUNNR = M009.CUST_CD(+)
               AND W002.REGID = USRMA.USERID(+)
               --AND M009.CUST_DIV = 'C'      -- 거래처구분(C:거래처, v=공급처)
               --AND W002.KUNNR = M009.CUST_CD(+)
               AND W002.WERKS = P_WERKS
               AND W002.MACH_CD = P_MACH_CD
               AND W002.IND_BCD = P_IND_BCD;
        ELSE
            OPEN CUR_1 FOR
            SELECT V_WRK_TYPE                      WRK_TYPE            --작업유형
                , M001.PCODE_NM                    PCODE_NM            --지종
                , NVL(S019.BS_WGT, '0')             BS_WGT              --평량
                --, M001.MATNR_SPEC                   MATNR_SPEC          --규격
--                , SUBSTR(W002.MATNR, 10, 4) || '*' || SUBSTR(W002.MATNR, 14, 4) as MATNR_SPEC  --규격
                , CASE WHEN NVL(W002.MAN_CUT_YN, 'N') = 'N' THEN SUBSTR(W002.MATNR, 10, 4) || '*' || SUBSTR(W002.MATNR, 14, 4) 
                    ELSE (LTRIM(TO_CHAR(W002.WLEN, '0999'), ' ' ) || '*' || LTRIM(TO_CHAR(W002.VLEN, '0999'), ' '))  END      AS MATNR_SPEC  --규격
                --, NVL(W002.PRFM_QTY, '0')           PRFM_REAM           --실적연수
                --, SUBSTR(W002.MATNR, 10, 4) || '*' || SUBSTR(W002.MATNR, 14, 4)     MATNR_SPEC_MAS  --수재단이동인경우 원규격 표시위해 추가
                , NVL(W002.PCNT, '0')           PRFM_REAM           --실적연수
                , NVL(W002.WGT, '0')                PRFM_WGT            --실적중량
--                , NVL(S019.PLT_PER_CNT, '0')        PLT_PER_CNT         --팔레트당 연수
                , NVL(W002.PCNT, '0')               PLT_PER_CNT         --팔레트당 연수(실적연수)
                , NVL(S019.IN_PER_CNT, '0')         IN_PER_CNT          --속당매수 (속수=(팔레트당연수*500)/속당매수)
                , W002.WRK_SEQ                      WRK_SEQ             --생산순번
                , W002.WIDTH_NO                     WIDTH_NO            --지폭순서
                , W002.MAN_CUT_YN                   MAN_CUT_YN          --수재단이동여부
                , ''                            JR_MACHINE_NM       --점보롤호기
                , ''                            MR_MACHINE_NM                   
                --, S016.MACHINE                      MR_MACHINE_NM       --밀롤호기
                --, S016.TO_MACHINE                   CT_MACHINE_NM       --재단호기
                , V_MACH_NM                         CT_MACHINE_NM       --재단설비명
--                , W002.PACKTYPE                     PACKTYPE            --포장타입
                , NVL(FN_CD_VAL('PACK_TYPE', S019.PACKTYPE), ' ')     PACKTYPE  --포장타입
                , M009.CUST_NM                      CUST_NM             --거래처명
                , TO_CHAR(W002.REGDATE, 'YYYY-MM-DD HH24:MI') WRK_DATE  --생산일시
                , W002.WRK_CLASS                    WRK_CLASS           --반
                , USRMA.NMLAST                      WRK_NAME            --작업자
                , USRMA.USERID                      WRK_ID              --작업자 ID
                , W002.LOT_NO                       LOT_NO              --LOT NO
                , S019.VBELN || LPAD(S019.POSNR, 6, '0')    SALES_ORDR_NO            --Sales Order No
                , ''                            ORDER_RMK                     -- 생산오더 비고사항
                , W002.RUN_STA                                  -- 운전상태 01 : 정상, 09 : 여유생산(재단인경우)
                , W002.RMK                                      -- 비고사항
              FROM TB_WRK002 W002,
                   TB_MAS001 M001,
                   (SELECT CUST_CD,CUST_NM 
                        FROM TB_MAS009
                        WHERE CUST_DIV = 'C') M009,
                   USRMA USRMA,
                   TB_SCH019 S019
             WHERE W002.WERKS = S019.WERKS(+)
               AND W002.WRK_ORDR_NO = S019.WRK_ORDR_NO(+)
               AND W002.WRK_ORDR_SEQNO = S019.WRK_ORDR_SEQNO(+)
               AND W002.WERKS = M001.WERKS(+)
               AND W002.MATNR = M001.MATNR(+)
               AND W002.KUNNR = M009.CUST_CD(+)
               AND W002.REGID = USRMA.USERID(+)
               --AND M009.CUST_DIV = 'C'      -- 거래처구분(C:거래처, v=공급처)
               AND W002.KUNNR = M009.CUST_CD(+)
               AND W002.WERKS = P_WERKS
               AND W002.MACH_CD = P_MACH_CD
               AND W002.IND_BCD = P_IND_BCD;
        END IF;
        
        RS_CODE := 'S';

    --예외처리(catch)
    EXCEPTION
    WHEN E_EXCEPTION_USER THEN
        -- 에러 내역 SET
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    WHEN OTHERS THEN
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END;
/
