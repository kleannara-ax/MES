--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK20_IFR01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK20_IFR01" 
(
     P_DOC_NO           IN VARCHAR2                     --문서번호
    ,P_DOC_SEQNO        IN VARCHAR2                     --문서번호 순번
    ,P_USERID           IN VARCHAR2                     --USER ID
    ,RS_RFCFN           OUT VARCHAR2                    --실적 RFCFN값
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
    ,CUR_1              OUT SYS_REFCURSOR               --실적 리스트
    ,CUR_2              OUT SYS_REFCURSOR               --실적 데이터
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK20_IFR01  {호출 프로그램 ID 기술}
 * PROGRAM NAME  : HL 실적등록 롤백 [I/F]
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : HL 실적등록 롤백 [I/F]
 *                 
 * AUTHOR NAME   : 이성민{최초 작성자 명 기술}
 * CREATE DATE   : 2022/10/25 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/10/25    1.0.0   이성민         Initial Version 
 *==============================================================================
 *  관련 테이블
 *
 *=============================================================================*/

AS 
    --프로그램 ID : HL ROLLBACK 
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK20_IFR01';    -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99';                    --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := P_USERID;               --USERID

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_OBJECT_T;
    V_OBJ            JSON_OBJECT_T;

    --parameter변수 처리

    V_DOC_NO            TB_WRK021.DOC_NO%TYPE;   
    V_DOC_SEQNO         TB_WRK021.DOC_SEQNO%TYPE;
    V_WRK_ORDR_NO       TB_WRK021.WRK_ORDR_NO%TYPE;   
    V_WRK_ORDR_SEQNO    TB_WRK021.WRK_ORDR_SEQNO%TYPE;
    V_DOC_DIV           TB_WRK021.DOC_DIV%TYPE;
    V_WERKS             TB_WRK021.WERKS%TYPE;
    V_MACH_CD           TB_WRK021.MACH_CD%TYPE;
    V_IND_BCD           TB_WRK021.IND_BCD%TYPE;
    V_LOT_NO            TB_WRK021.LOT_NO%TYPE;
    V_ORDER_NO          TB_WRK021.ORDER_NO%TYPE;
    V_SDOC_NO           TB_WRK021.SDOC_NO%TYPE;
    V_SDOC_SEQNO        TB_WRK021.SDOC_SEQNO%TYPE;
    V_SAP_WRK_CD        TB_MAS012.SAP_WRK_CD%TYPE;
    V_ROLLCNT           TB_WRK002.ROLLCNT%TYPE;
    V_STA               TB_WRK002.STA%TYPE;
    V_NAUFNR            TB_WRK002.NAUFNR%TYPE;
    V_SQL               VARCHAR2(4000);
    V_REGDATE           DATE := SYSDATE;

BEGIN
  BEGIN

   OPEN CUR_1 FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   OPEN CUR_2 FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;






    -- ROLLBACK 문서번호 SELECT---------------------------------------------------------------------------------
    BEGIN
            SELECT   DOC_DIV,   WERKS,   MACH_CD,   IND_BCD,   LOT_NO,   ORDER_NO,   SDOC_NO,   SDOC_SEQNO
                    ,WRK_ORDR_NO    ,WRK_ORDR_SEQNO
            INTO   V_DOC_DIV, V_WERKS, V_MACH_CD, V_IND_BCD, V_LOT_NO, V_ORDER_NO, V_SDOC_NO, V_SDOC_SEQNO
                  ,V_WRK_ORDR_NO  ,V_WRK_ORDR_SEQNO
            FROM  TB_WRK021
            WHERE DOC_NO = P_DOC_NO
            AND   DOC_SEQNO = P_DOC_SEQNO;
    EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RS_CODE      := 'E';
                RS_MSG       := 'ROLLBACK[SP_POP_WRK20_IFR01] 문서번호가 조회되지 않습니다';
                RETURN;
            WHEN OTHERS THEN
                RS_CODE      := 'E';
                RS_MSG       := 'ROLLBACK[SP_POP_WRK20_IFR01] ERROR';
                RETURN;
    END;

    BEGIN
            SELECT   ROLLCNT
            INTO   V_ROLLCNT
            FROM  TB_WRK001
            WHERE WERKS   = V_WERKS
              AND MACH_CD = V_MACH_CD
              AND IND_BCD = V_IND_BCD;
    EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RS_CODE      := 'E';
                RS_MSG       := 'ROLLBACK[SP_POP_WRK20_IFR01] 실적이 조회되지 않습니다';
                RETURN;
            WHEN OTHERS THEN
                RS_CODE      := 'E';
                RS_MSG       := 'ROLLBACK[SP_POP_WRK20_IFR01] ERROR';
                RETURN;
    END;

    SELECT SAP_WRK_CD INTO V_SAP_WRK_CD
      FROM TB_MAS012
      WHERE MACH_CD = V_MACH_CD
      ;

     V_DOC_NO := FN_GET_MDOCNO('M','IF129');
     V_DOC_SEQNO := 1;

     INSERT INTO TB_IFS007           --생산오더별실적 취소
                          (RUECK                        --SAP 확정번호
                         , RMZHL                        --SAP 확정카운터
                         , MDOCNO                       --MES 문서번호
                         , MDOCSEQ                      --MES 문서순번
                         , MAKE_DATE                    --등록일자 
                         , MAKER                        --등록자
                         , WORKCENTERCODE               --작업장코드(MES PK)
                         , AUFNR                        --오더번호
                         , ROLLCNT                      --권치수
                         , MBLNR                        --MBLNR
                         , LOTNO
           )                       
     VALUES(               V_SDOC_NO                    --SAP 확정번호
                         , V_SDOC_SEQNO                 --SAP 확정카운터 
                         , V_DOC_NO                     --MES 문서번호
                         , V_DOC_SEQNO                  --MES 문서순번 
                         , SYSDATE                      --등록일자 
                         , P_USERID                     --등록자
                         , V_SAP_WRK_CD                 --작업장코드(MES PK)
                         , V_ORDER_NO                   --오더번호
                         , V_ROLLCNT                    --권치수
                         , V_SDOC_NO                    --MBLNR 
                         , V_LOT_NO                     --LOT_NO
     );      

     -- 개별바코드 전달
     --RS_IND_BCD := V_IND_BCD;
     --SAP FUNC ID
     SELECT RFCFN
     INTO RS_RFCFN
     FROM TB_ITFMA
     WHERE 1=1
     AND IFID = 'MES_IF_129';   --생산오더별 실적 취소 TXN
     --인터페이스 파라미터
     OPEN CUR_1 FOR
     SELECT 'MES_IF_129' AS I_IF_ID
          , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
     FROM dual;
     --인터페이스 상세 파라미터
     V_SQL := FN_IF_QUERY('MES_IF_129', V_DOC_NO);
     OPEN CUR_2 FOR V_SQL;








    IF CUR_1%ISOPEN = FALSE THEN
        OPEN CUR_1 FOR SELECT 1 FROM dual;
    END IF;

    IF CUR_2%ISOPEN = FALSE THEN
        OPEN CUR_2 FOR SELECT 1 FROM dual;
    END IF;


    RS_CODE := 'S';
    --COMMIT;    

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
