--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK30_I06_20
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK30_I06_20" 
(
     P_WERKS            IN VARCHAR2 --플랜트코드
    ,P_JSON_STR         IN CLOB
    ,P_USERID           IN VARCHAR2
    ,RS_PRFM_RFCFN_CN   OUT VARCHAR2            --병합실적 취소 RFCFN값
    ,RS_PRFM_RFCFN      OUT VARCHAR2            --병합전 실적 재등록 RFCFN값
    ,RS_PRFM_RFCFN_ZR   OUT VARCHAR2            --제로실적 취소용 RFCFN값
    ,RS_MER_IND_BCD     OUT VARCHAR2
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
    ,CUR_1              OUT SYS_REFCURSOR        --실적취소(병합)
    ,CUR_2              OUT SYS_REFCURSOR
    ,CUR_3              OUT SYS_REFCURSOR        --실적취소1  
    ,CUR_4              OUT SYS_REFCURSOR 
    ,CUR_5              OUT SYS_REFCURSOR        --실적취소1  
    ,CUR_6              OUT SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK30_I06
 * PROGRAM NAME  : 라벨 병합 취소처리
 * VERSION       : 1.0.0
 * DESCRIPTION   : 
 *                 
 * AUTHOR NAME   : 김병무
 * CREATE DATE   : 2022/07/19
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/04    1.0.0   김병무         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK009] : (C...) LOT 병합
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM         VARCHAR2(100) := 'SP_POP_WRK30_I06'; -- PROCEDURE NAME
    V_PLT_CD         VARCHAR2(2)   := '99';         --PLANTCODE TEST
    V_SESS_USER_ID   VARCHAR2(20)  := P_USERID;     --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_OBJ            JSON_OBJECT_T;

    V_DOC_NO            TB_WRK002.DOC_NO%TYPE;		 --DOC No (POP 생성)
    V_DOC_SEQNO         TB_WRK002.DOC_SEQNO%TYPE;	 --DOC SEQ. (POP 생성)
    V_DOC_NO_CN         TB_WRK002.DOC_NO%TYPE;		 --DOC No (생산취소용)
    V_DOC_SEQNO_CN      TB_WRK002.DOC_SEQNO%TYPE;	 --DOC SEQ. (생산취소용)
    V_ZR_DOC_NO         TB_WRK002.DOC_NO%TYPE;		 --DOC No (Zero실적용)
    V_ZR_DOC_SEQNO      TB_WRK002.DOC_SEQNO%TYPE;    --DOC SEQ. (Zero실적용)
    V_NEW_DOC_NO        TB_WRK002.DOC_NO%TYPE;		 --DOC No (POP 생성)
    V_NEW_DOC_SEQNO     TB_WRK002.DOC_SEQNO%TYPE;	 --DOC SEQ. (POP 생성)
    V_SDOC_NO           TB_WRK002.SDOC_NO%TYPE;	     --SDOC NO (SAP 확정문서번호)
    V_SDOC_SEQNO        TB_WRK002.SDOC_SEQNO%TYPE;	 --SDOC SEQ. (SAP 확정문서 SEQ.)
    V_PRFM_DT           TB_WRK002.PRFM_DT%TYPE;		 --생산실적일
    V_LOT_NO            TB_WRK002.LOT_NO%TYPE;       --LOT_NO
    V_MACH_CD	        TB_WRK002.MACH_CD%TYPE;      --작업장코드(설비코드)
    V_ORDER_NO          TB_WRK002.ORDER_NO%TYPE;     --SAP ORDER NO
    V_ORDER_NO_B        TB_WRK002.ORDER_NO%TYPE;     --SAP ORDER NO
    V_ORDER_NO_C        TB_WRK002.ORDER_NO%TYPE;     --SAP ORDER NO
    V_PRFM_QTY          TB_WRK002.PRFM_QTY%TYPE;     --생산실적(EA)
    V_IND_BCD	        TB_WRK002.IND_BCD%TYPE;      --개별바코드
    V_MER_IND_BCD       TB_WRK002.MER_IND_BCD%TYPE;  --개별바코드
    V_WRK_ORDR_NO       TB_WRK002.WRK_ORDR_NO%TYPE;	 --MES 작업지시NO
    V_WRK_ORDR_SEQNO    TB_WRK002.WRK_ORDR_SEQNO%TYPE; --MES 작업지시 SEQ.
    V_YMCHK             TB_MAS011.YMCHK%TYPE;        --실적등록 가능 여부
    V_SAP_WRK_CD        TB_MAS012.SAP_WRK_CD%TYPE;   --SAP용 설비코드

    --내부 변수 등록
    V_ROWCNT            NUMBER;
    V_DATE              DATE := SYSDATE;
    V_DOC_NO_PRFM_NEW   VARCHAR2(500) := '';
    V_DOC_NO_PRFM_CN    VARCHAR2(500) := '';
    V_DOC_NO_ZERO       VARCHAR2(500) := '';
    V_COMP_YN           VARCHAR2(1);                --작업완료여부
    V_MAXSNUM           NUMBER;
    V_SNUM              NUMBER;
    V_SQL               VARCHAR2(4000);

BEGIN
    BEGIN 
        V_DOC_NO_PRFM_NEW   := '';
        V_DOC_NO_PRFM_CN    := '';

        V_NEW_DOC_SEQNO := 0;
        V_DOC_SEQNO_CN := 0;
        V_ZR_DOC_SEQNO := 0;
        
        V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);
        V_ARR_LIST := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ     := TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ     := TREAT (V_OBJ.get ('map') AS json_object_t);
            
            V_MER_IND_BCD := V_OBJ.get_string('IND_BCD');

            -- 병합바코드 실적 정보 구하기
            SELECT LOT_NO,  MACH_CD,  PRFM_DT,  PRFM_QTY,  DOC_NO,  DOC_SEQNO
                  , ORDER_NO,  SDOC_NO,  SDOC_SEQNO
              INTO V_LOT_NO,  V_MACH_CD,  V_PRFM_DT,  V_PRFM_QTY,  V_DOC_NO,  V_DOC_SEQNO
                  , V_ORDER_NO,  V_SDOC_NO,  V_SDOC_SEQNO
              FROM TB_WRK002
             WHERE WERKS   = P_WERKS
               AND IND_BCD = V_MER_IND_BCD
               AND ROWNUM  = 1;

            --라벨병합취소 가능 월 검사                
            BEGIN
                SELECT YMCHK INTO  V_YMCHK
                  FROM TB_MAS011
                 WHERE WERKS = P_WERKS
                   AND YMCHK = 'Y'
                   AND YYMM  = SUBSTR(V_PRFM_DT, 1, 6);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_YMCHK := 'N';
            END;

            IF V_YMCHK = 'N' THEN
                RS_CODE := 'E';
                RS_MSG := '라벨병합 가능한 월이 아닙니다.';
                ROLLBACK;
                RETURN;
            END IF;
            --------------------------------------------------------------------
            -- 병합바코드 실적 취소
            -- MES 문서번호 생성
            V_DOC_NO_CN := FN_GET_MDOCNO('M','IF129');
            V_DOC_SEQNO_CN := V_DOC_SEQNO_CN + 1;

            V_DOC_NO_PRFM_CN := V_DOC_NO_PRFM_CN || V_DOC_NO_CN || ',' ;

            -- 1. 생산실적 취소 flag
            UPDATE TB_WRK002
               SET MER_YN  = 'N',
                   MER_IND_BCD = '',
                   CNL_YN  = 'Y',
                   CNL_RMK = '병합취소',
                   UPDDATE = V_DATE,
                   UPDID   = P_USERID
             WHERE WERKS   = P_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_MER_IND_BCD;

            -- 2. 재고삭제
            DELETE FROM TB_INV001
             WHERE WERKS       = P_WERKS
               AND STOR_LOC_CD = '2000'
               AND IND_BCD     = V_MER_IND_BCD;

            -- 3. LOT 추적
            DELETE FROM TB_WRK008     --LOT 추적
             WHERE WERKS   = P_WERKS
               AND IND_BCD = V_MER_IND_BCD;

            -- 4. 문서이력 (CNL_YN = 'Y')
            UPDATE TB_WRK021
               SET CNL_YN = 'Y'
             WHERE DOC_NO    = V_DOC_NO
               AND DOC_SEQNO = V_DOC_SEQNO;

            ---------------------------------------------------------------------
            -- SAP용 설비코드를 구한다.
            SELECT SAP_WRK_CD 
              INTO V_SAP_WRK_CD
              FROM TB_MAS012
             WHERE MACH_CD = V_MACH_CD;

            -- 5. 생산취소 SAP IF 등록 
            INSERT INTO TB_IFS007 (
                               RUECK,  RMZHL,  MDOCNO,  MDOCSEQ,  MAKE_DATE,
                               MAKER,  WORKCENTERCODE,  AUFNR,  ROLLCNT,  MBLNR,  LOTNO
                            )                       
                     VALUES (
                              V_SDOC_NO,  V_SDOC_SEQNO , V_DOC_NO_CN, V_DOC_SEQNO_CN, V_DATE,
                              P_USERID,  V_SAP_WRK_CD,  V_ORDER_NO,  0,  V_SDOC_NO,  V_LOT_NO
                            );

            ----------------------------------------------------------------------------------
            -- 실적등록 ( 병합으로 취소된 개별 바코드 실적 재 등록 (최대 5개)
            
            -- 실적에서 병합에 사용된 개별바코드를 모두 구함
            INSERT INTO TB_WRK002_TMP (IND_BCD, SNUM, ORDER_NO, ROWNUM1)
            SELECT IND_BCD, SNUM, ORDER_NO, ROWNUM
              FROM (
                    SELECT IND_BCD, ORDER_NO, ROW_NUMBER() OVER (PARTITION BY ORDER_NO  ORDER BY ORDER_NO) AS SNUM
                      FROM TB_WRK002
                     WHERE WERKS       = P_WERKS
                       AND MER_IND_BCD = V_MER_IND_BCD 
                    ) TAB ;

            SELECT COUNT(1) INTO V_ROWCNT
              FROM TB_WRK002_TMP;

            IF V_ROWCNT <= 0 THEN
                RS_CODE := 'E';
                RS_MSG := '병합취소를 위한 개별바코드가 없습니다.';
                ROLLBACK;
                RETURN;
            END IF;
            
            V_ORDER_NO_B := V_ORDER_NO;
            
            -- 병합에 사용된 바코드 수 만큼 실적 재등록
            FOR j IN 0..V_ROWCNT-1 LOOP
                SELECT W002.IND_BCD,  MACH_CD,  PRFM_DT, DOC_NO,  DOC_SEQNO, 
                       WRK_ORDR_NO,  WRK_ORDR_SEQNO,  W002.ORDER_NO,  WTEMP.SNUM
                  INTO V_IND_BCD,  V_MACH_CD,  V_PRFM_DT, V_DOC_NO,  V_DOC_SEQNO,
                       V_WRK_ORDR_NO,  V_WRK_ORDR_SEQNO,  V_ORDER_NO_C, V_SNUM
                  FROM TB_WRK002 W002 ,
                       TB_WRK002_TMP WTEMP
                 WHERE W002.WERKS    = P_WERKS
                   AND W002.IND_BCD  = WTEMP.IND_BCD
                   AND WTEMP.ROWNUM1 = j + 1;

                --실적 재 등록 가능 월 검사                
                BEGIN
                    SELECT YMCHK INTO  V_YMCHK
                      FROM TB_MAS011
                     WHERE WERKS = P_WERKS
                       AND YMCHK = 'Y'
                       AND YYMM  = SUBSTR(V_PRFM_DT, 1, 6);
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_YMCHK := 'N';
                END;

                IF V_YMCHK = 'N' THEN
                    RS_CODE := 'E';
                    RS_MSG := '라벨병합취소로 실적 재등록 가능한 월이 아닙니다.';
                    ROLLBACK;
                    RETURN;
                END IF;
                
                --문서번호 생성
                V_NEW_DOC_NO := FN_GET_MDOCNO('M', 'IF126');
                V_NEW_DOC_SEQNO := V_NEW_DOC_SEQNO + 1;

                V_DOC_NO_PRFM_NEW := V_DOC_NO_PRFM_NEW || V_NEW_DOC_NO || ',' ;

                -- 생산실적 복구
                UPDATE TB_WRK002
                   SET MER_YN  = 'N',
                       MER_IND_BCD = '',
                       CNL_YN  = 'N',
                       CNL_RMK = '',
                       DOC_NO  = V_NEW_DOC_NO,
                       DOC_SEQNO = V_NEW_DOC_SEQNO,
                       UPDDATE = V_DATE,
                       UPDID   = P_USERID
                 WHERE WERKS   = P_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND IND_BCD = V_IND_BCD;

                -- 재고복구
                UPDATE TB_INV001
                   SET STCK_QTY  = MER_STOCK_QTY,
                       MER_STOCK_QTY = 0,
                       STCK_STA  = '00',  
                       DOC_NO    = V_NEW_DOC_NO,
                       DOC_SEQNO = V_NEW_DOC_SEQNO,
                       UPDDATE   = V_DATE,
                       UPDID     = P_USERID
                 WHERE WERKS       = P_WERKS
                   AND STOR_LOC_CD = '2000'
                   AND IND_BCD     = V_IND_BCD;

                -- 문서이력 복구
                INSERT INTO TB_WRK021 (
                            DOC_NO,  DOC_SEQNO,  DOC_DIV,  WERKS,  MACH_CD,  WRK_ORDR_NO,  WRK_ORDR_SEQNO,
                            IND_BCD,  LOT_NO,  ORDER_NO,  CNL_YN,  REGDATE,  REGID
                           ) 
                 SELECT V_NEW_DOC_NO,  V_NEW_DOC_SEQNO,  DOC_DIV,  WERKS,  MACH_CD,  WRK_ORDR_NO,  WRK_ORDR_SEQNO,
                        IND_BCD,  LOT_NO,  ORDER_NO,  'N',  V_DATE,  P_USERID
                   FROM TB_WRK021
                  WHERE DOC_NO    = V_DOC_NO
                    AND DOC_SEQNO = V_DOC_SEQNO;
                
                SELECT NVL(MAX(SNUM),0) INTO V_MAXSNUM
                  FROM TB_WRK002_TMP
                 WHERE ORDER_NO = V_ORDER_NO_C;

                --Order완료 여부 확인
                SELECT COMP_YN
                  INTO V_COMP_YN
                  FROM TB_SCH017
                 WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;

                IF V_COMP_YN = 'Y' THEN
                    V_COMP_YN := 'X';
                ELSE
                    V_COMP_YN := '';
                END IF;

                -- V_COMP_YN = 'X' 일 경우 생산취소 (0인거) 먼저 보내야함
                IF V_ORDER_NO_B <> V_ORDER_NO_C THEN
                    IF V_COMP_YN = 'X' THEN
                    
                        V_ZR_DOC_NO := FN_GET_MDOCNO('M', 'IF127');
                        V_ZR_DOC_SEQNO := V_ZR_DOC_SEQNO + 1;
                        
                        V_DOC_NO_ZERO := V_DOC_NO_ZERO || V_ZR_DOC_NO || ',' ;

                        -- Zero실적은 Order별 1개만 있는 것을 원칙으로 한다. 그렇지 않을 경우 찾지를 못할 수 있음
                        -- Zero 실적취소를 먼저 전송한다. (완료Flag 해제를 위해..)                        
                        INSERT INTO TB_IFS007 (
                                           RUECK,  RMZHL,  MDOCNO,  MDOCSEQ,  MAKE_DATE,
                                           MAKER,  WORKCENTERCODE,  AUFNR,  ROLLCNT,  MBLNR,  LOTNO
                                        )
                                 SELECT SDOC_NO,  SDOC_SEQNO,  V_ZR_DOC_NO,  V_ZR_DOC_SEQNO,  V_DATE,
                                        P_USERID,  V_SAP_WRK_CD,  ORDER_NO,  0,  SDOC_NO,  LOT_NO
                                   FROM TB_WRK002
                                  WHERE WERKS    = P_WERKS
                                    AND IND_BCD  = 'Z00000000000000'
                                    AND ORDER_NO = V_ORDER_NO_C
                                    AND ROWNUM   = 1;
                           
                        --Zero실적 삭제
                        DELETE FROM TB_WRK002
                         WHERE WERKS    = P_WERKS
                           AND IND_BCD  = 'Z00000000000000'
                           AND ORDER_NO = V_ORDER_NO_C;
                           
                    END IF;
                END IF;

                -- 같은 Order가 2개 이상일 때 마지막 order만 완료로 전송
                IF V_MAXSNUM > V_SNUM THEN
                    V_COMP_YN := '';
                END IF;
                
                --실적 I/F 
                INSERT INTO TB_IFS005 (
                             AUFNR,  CRLOT,  WERKS,  WORKCENTERCODE,  BUDAT,  MACHINE,  WORKGROUP,  PRDQTY,  MEINS,  CRUNTIME,
                             COPNAM,  CUTTER,  CONFM,  CONFC,  CSDATE,  CSTIME,  CEDATE,  CETIME,  MDOCNO,  MDOCSEQ,  MAKE_DATE,
                             MAKER,  MRLOT
                           )
                    SELECT AUFNR,  CRLOT,  WERKS,  WORKCENTERCODE,  BUDAT,  MACHINE,  WORKGROUP,  PRDQTY,  MEINS,  CRUNTIME,
                           COPNAM,  CUTTER,  V_COMP_YN,  V_COMP_YN,  CSDATE,  CSTIME,  CEDATE,  CETIME,  V_NEW_DOC_NO,  V_NEW_DOC_SEQNO,  V_DATE,
                           P_USERID,  MRLOT
                      FROM TB_IFS005
                     WHERE MDOCNO  = V_DOC_NO
                       AND MDOCSEQ = V_DOC_SEQNO;


                IF j = 0 THEN
                    RS_MER_IND_BCD := V_IND_BCD;    -- 개별 바코드 구분자 로 여러개 전달
                ELSE
                    RS_MER_IND_BCD := RS_MER_IND_BCD  || '|' || V_IND_BCD;    -- 개별 바코드 구분자 로 여러개 전달
                END IF;
                
                V_ORDER_NO_B := V_ORDER_NO_C;
                
            END LOOP;
        END LOOP;

        V_DOC_NO_PRFM_CN  := SUBSTR(V_DOC_NO_PRFM_CN, 1, LENGTH(V_DOC_NO_PRFM_CN)-1);
        V_DOC_NO_PRFM_NEW := SUBSTR(V_DOC_NO_PRFM_NEW, 1, LENGTH(V_DOC_NO_PRFM_NEW)-1);
        V_DOC_NO_ZERO := SUBSTR(V_DOC_NO_ZERO, 1, LENGTH(V_DOC_NO_ZERO)-1);

        IF LENGTH(V_DOC_NO_PRFM_CN) > 0  THEN 
            --6. SAP FUNC ID
            SELECT RFCFN
              INTO RS_PRFM_RFCFN_CN
              FROM TB_ITFMA
             WHERE IFID = 'MES_IF_129';   -- 실적 취소 TXN

            --7. 인터페이스 파라미터
            OPEN CUR_1 FOR
            SELECT 'MES_IF_129' AS I_IF_ID
                 , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
              FROM dual;

            --8. 인터페이스 상세 파라미터
            V_SQL := FN_IF_QUERY('MES_IF_129', V_DOC_NO_PRFM_CN);
            OPEN CUR_2 FOR V_SQL;
            
        END IF;

        IF LENGTH(V_DOC_NO_PRFM_NEW) > 0  THEN   
                -- SAP 전송을 위한 값 RETUEN
                 --SAP FUNC ID
                 SELECT RFCFN
                   INTO RS_PRFM_RFCFN
                   FROM TB_ITFMA
                  WHERE IFID = 'MES_IF_127';   --생산오더별 재단 실적 

                 --인터페이스 파라미터
                 OPEN CUR_3 FOR
                 SELECT 'MES_IF_127' AS I_IF_ID
                      , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                   FROM dual;

                 --인터페이스 상세 파라미터
                 V_SQL := FN_IF_QUERY('MES_IF_127', V_DOC_NO_PRFM_NEW);
                 OPEN CUR_4 FOR V_SQL;
        END IF;
        
        IF LENGTH(V_DOC_NO_ZERO) > 0   THEN   
                -- SAP 전송을 위한 값 RETUEN
                 --SAP FUNC ID
                 SELECT RFCFN
                   INTO RS_PRFM_RFCFN_ZR
                   FROM TB_ITFMA
                  WHERE IFID = 'MES_IF_129';   --Zero실적 취소 전송용 

                 --인터페이스 파라미터
                 OPEN CUR_5 FOR
                 SELECT 'MES_IF_129' AS I_IF_ID
                      , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                   FROM dual;

                 --인터페이스 상세 파라미터
                 V_SQL := FN_IF_QUERY('MES_IF_129', V_DOC_NO_ZERO);
                 OPEN CUR_6 FOR V_SQL;
        END IF ;

        --작업 정상 종료 코드 등록
        IF CUR_1%ISOPEN = FALSE THEN
            OPEN CUR_1 FOR SELECT 1 FROM dual;
        END IF;
        IF CUR_2%ISOPEN = FALSE THEN
            OPEN CUR_2 FOR SELECT 1 FROM dual;
        END IF;
        IF CUR_3%ISOPEN = FALSE THEN
            OPEN CUR_3 FOR SELECT 1 FROM dual;
        END IF;
        IF CUR_4%ISOPEN = FALSE THEN
            OPEN CUR_4 FOR SELECT 1 FROM dual;
        END IF;
        IF CUR_5%ISOPEN = FALSE THEN
            OPEN CUR_5 FOR SELECT 1 FROM dual;
        END IF;
        IF CUR_6%ISOPEN = FALSE THEN
            OPEN CUR_6 FOR SELECT 1 FROM dual;
        END IF;

        RS_CODE := 'S';
    -- COMMIT;
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
            E_SQL_ERR_CD        := -20001;
            E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

            ROLLBACK;
            --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
            RAISE;
            
            RS_CODE := 'E';
            RS_MSG  := SQLERRM;
            RETURN;
    END;
END SP_POP_WRK30_I06_20;

/
