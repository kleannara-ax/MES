
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK26_IFR03" 
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
 * PROGRAM ID    : SP_POP_WRK26_IFR03  {호출 프로그램 ID 기술}
 * PROGRAM NAME  : 재단 영업폐품등록 롤백 [I/F]
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 재단 영업폐품등록 롤백 [I/F]
 *                 
 * AUTHOR NAME   : 이성민{최초 작성자 명 기술}
 * CREATE DATE   : 2022/10/25 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
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
    --프로그램 ID : 점보롤 실적취소 
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK26_IFR03';    -- PROCEDURE NAME
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
    V_DISPO_QTY			TB_WRK022.DISPO_QTY%TYPE;
    V_DISPO_WGT			TB_WRK022.WGT%TYPE;
    V_ROLLCNT			TB_WRK022.ROLLCNT%TYPE;
    V_MATNR_M			TB_WRK022.MATNR_M%TYPE;
    V_PRFM_DT			TB_WRK022.PRFM_DT%TYPE;
    V_LOT_NO_M			TB_WRK022.LOT_NO_M%TYPE;
    V_PRE_ORDER_NO      TB_SCH016.PRE_ORDER_NO%TYPE;
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
                RS_MSG       := 'ROLLBACK[SP_POP_WRK26_IFR03] 문서번호가 조회되지 않습니다';
                ROLLBACK;
                RETURN;
            WHEN OTHERS THEN
                RS_CODE      := 'E';
                RS_MSG       := 'ROLLBACK[SP_POP_WRK26_IFR03] ERROR';
                ROLLBACK;
                RETURN;
    END;

    BEGIN
            SELECT DISPO_QTY,   		WGT,   ROLLCNT,MATNR_M,  PRFM_DT, LOT_NO_M
              INTO V_DISPO_QTY, V_DISPO_WGT, V_ROLLCNT,V_MATNR_M,V_PRFM_DT, V_LOT_NO_M
              FROM TB_WRK022 
             WHERE WERKS   = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD
               AND SDOC_NO = V_SDOC_NO
               AND SDOC_SEQNO = V_SDOC_SEQNO
               AND NVL(CNL_YN, 'N') = 'N'
               ;
    EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RS_CODE      := 'E';
                RS_MSG       := 'ROLLBACK[SP_POP_WRK26_IFR03] 실적이 조회되지 않습니다';
                ROLLBACK;
                RETURN;
            WHEN OTHERS THEN
                RS_CODE      := 'E';
                RS_MSG       := 'ROLLBACK[SP_POP_WRK26_IFR03] ERROR';
                ROLLBACK;
                RETURN;
    END;

    SELECT SAP_WRK_CD INTO V_SAP_WRK_CD
      FROM TB_MAS012
      WHERE MACH_CD = V_MACH_CD
      ;

      V_DOC_NO := FN_GET_MDOCNO('M','IF144');
      V_DOC_SEQNO := 1;

                    INSERT INTO TB_IFS022   --폐품취소
                             (
                                 WORKCENTERCODE	--작업장코드(MES PK)
                                ,AUFNR	        --오더번호
                                ,POSNR	        --오더Item번호
                                ,BUDAT	        --투입일자(전기일)
                                ,MATNR	        --자재번호(투입자재)
                                ,MENGE	        --투입량
                                ,WERKS	        --플랜트
                                ,LGORT	        --저장위치
                                ,CHARG	        --LOT번호
                                ,MDOCNO	        --MES 문서번호
                                ,MDOCSEQ	    --MES 문서순번
                                ,MBLNR	        --SAP 문서번호
                                ,MJAHR	        --SAP 문서번호(년도)
                                ,ZRESULT	    --SAP 결과값 Return( S:성공, E:오류 )
                                ,ZRESULT_DATE    --전송 시간
                                ,MAKE_DATE	    --등록일자
                                ,IF_MES_KEY	    --MES Inserface Key(MES->SAP 인 경우만)
                                ,ZMESSAGE	    --SAP결과 메시지
                             )                       
                     VALUES
                            (               
                                 V_SAP_WRK_CD	--작업장코드(MES PK)
                                ,V_ORDER_NO	    --오더번호
                                ,1	            --오더Item번호
                                ,V_PRFM_DT	    --투입일자(전기일)
                                ,V_MATNR_M	    --자재번호(투입자재)
                                ,V_DISPO_WGT	--투입량 (밀롤의 폐품은 중량)
                                ,V_WERKS	    --플랜트
                                ,'2000'	        --저장위치
                                ,V_LOT_NO_M	    --LOT번호
                                ,V_DOC_NO       --MES 문서번호
                                ,V_DOC_SEQNO    --MES 문서순번
                                ,V_SDOC_NO	    --SAP 문서번호
                                ,V_SDOC_SEQNO	--SAP 문서번호(년도)
                                ,'N'	        --SAP 결과값 Return( S:성공, E:오류 )
                                ,NULL           --전송 시간
                                ,SYSDATE	    --등록일자
                                ,NULL	        --MES Inserface Key(MES->SAP 인 경우만)
                                ,NULL	        --SAP결과 메시지
                             );                


     --문서이력
     -- 1=실적, 2=생산폐품, 3=영업폐품, 4=잔량폐품, 5=투입자재 소요량, 6=재고이전(위치), 7=재고이전(자재변경), 8=재고이전(재고실사)
     -- 9=LOT변경, 10=등급변경, 11=LOT병합, 12=LIFT출고, 20=오더완료
     INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                           IND_BCD, LOT_NO, ORDER_NO, CNL_YN, REGDATE, REGID, REMARK)
     		      VALUES(V_DOC_NO, V_DOC_SEQNO, V_DOC_DIV, V_WERKS, V_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                         V_IND_BCD, V_LOT_NO, V_ORDER_NO, 'N', V_REGDATE, P_USERID, 'ROLLBACK I/F 문서이력 SP_POP_WRK26_IFR03');    
     -- 개별바코드 전달
     --RS_IND_BCD := V_IND_BCD;
     --SAP FUNC ID
     SELECT RFCFN
     INTO RS_RFCFN
     FROM TB_ITFMA
     WHERE 1=1
       AND IFID = 'MES_IF_144';
     --인터페이스 파라미터
     OPEN CUR_1 FOR
     SELECT 'MES_IF_144' AS I_IF_ID
          , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
     FROM dual;
     --인터페이스 상세 파라미터
     V_SQL := FN_IF_QUERY('MES_IF_144', V_DOC_NO);
     OPEN CUR_2 FOR V_SQL;  


    IF CUR_1%ISOPEN = FALSE THEN
        OPEN CUR_1 FOR SELECT 1 FROM dual;
    END IF;

    IF CUR_2%ISOPEN = FALSE THEN
        OPEN CUR_2 FOR SELECT 1 FROM dual;
    END IF;


    RS_CODE := 'S';
    COMMIT;    

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
