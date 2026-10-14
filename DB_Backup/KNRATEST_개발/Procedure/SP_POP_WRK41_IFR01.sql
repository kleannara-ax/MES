--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK41_IFR01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK41_IFR01" SP_POP_WRK41_IFR01
(
     P_SDOC_NO           IN VARCHAR2                     --문서번호
    ,P_SDOC_SEQNO        IN VARCHAR2                     --문서번호 순번
    ,P_USERID           IN VARCHAR2                     --USER ID
    ,RS_RFCFN           OUT VARCHAR2                    --실적 RFCFN값
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
    ,CUR_1              OUT SYS_REFCURSOR               --실적 리스트
    ,CUR_2              OUT SYS_REFCURSOR               --실적 데이터
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK41_IFR01  {호출 프로그램 ID 기술}
 * PROGRAM NAME  : 라벨병합 실적취소 롤백(실적 재등록) [I/F]
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : .{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 이성민{최초 작성자 명 기술}
 * CREATE DATE   : 2022/12/12 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/12/12    1.0.0   이성민         Initial Version 
 *==============================================================================
 *  관련 테이블
 *
 *=============================================================================*/

AS 
    --프로그램 ID : HL ROLLBACK 
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK41_IFR01';    -- PROCEDURE NAME
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
    V_SDOC_NO           TB_WRK021.SDOC_NO%TYPE := P_SDOC_NO;
    V_SDOC_SEQNO        TB_WRK021.SDOC_SEQNO%TYPE := P_SDOC_SEQNO;
    V_USER_NM			VARCHAR2(30);
    V_SAP_WRK_CD        TB_MAS012.SAP_WRK_CD%TYPE;
    V_ROLLCNT           TB_WRK002.ROLLCNT%TYPE;
    V_STA               TB_WRK002.STA%TYPE;
    V_NAUFNR            TB_WRK002.NAUFNR%TYPE;
    V_COMP_YN			TB_IFS005.CONFM%TYPE;
    V_SQL               VARCHAR2(4000);
    V_REGDATE           DATE := SYSDATE;
    V_IFS005_CHK        NUMBER(5); 
    V_IFID				VARCHAR2(20);
    
BEGIN
  BEGIN

   OPEN CUR_1 FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   OPEN CUR_2 FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0; 

    -- ROLLBACK 문서번호 SELECT---------------------------------------------------------------------------------
--    BEGIN
--            SELECT   RUECK  ,   RMZHL
--            INTO   V_SDOC_NO, V_SDOC_SEQNO
--            FROM  TB_IFS007
--            WHERE MDOCNO = P_DOC_NO
--            AND   MDOCSEQ = P_DOC_SEQNO;
--    EXCEPTION
--            WHEN NO_DATA_FOUND THEN
--                RS_CODE      := 'E';
--                RS_MSG       := 'ROLLBACK[SP_POP_WRK41_IFR01] 문서번호가 조회되지 않습니다';
--                RETURN;
--            WHEN OTHERS THEN
--                RS_CODE      := 'E';
--                RS_MSG       := 'ROLLBACK[SP_POP_WRK41_IFR01] ERROR';
--                RETURN;
--    END;
  
    BEGIN
       		SELECT WERKS, MACH_CD, IND_BCD , WRK_ORDR_NO, WRK_ORDR_SEQNO
      		INTO   V_WERKS, V_MACH_CD, V_IND_BCD, V_WRK_ORDR_NO  ,V_WRK_ORDR_SEQNO
     		FROM   TB_WRK021
     		WHERE  SDOC_NO = V_SDOC_NO
     		AND    SDOC_SEQNO = V_SDOC_SEQNO  ;
    EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RS_CODE      := 'E';
                RS_MSG       := 'ROLLBACK[SP_POP_WRK86_IFR03] 확정문서번호가 조회되지 않습니다';
                RETURN;
            WHEN OTHERS THEN
                RS_CODE      := 'E';
                RS_MSG       := 'ROLLBACK[SP_POP_WRK86_IFR03] ERROR';
                RETURN;
    END;  
   
    -- TB_IFS005 전송실적 확인
--    SELECT COUNT(*)
--    INTO   V_IFS005_CHK
--    FROM   TB_IFS005 
--    WHERE  RUECK = V_SDOC_NO
--      AND  RMZHL = V_SDOC_SEQNO;
--
--	-- 확정문서 번호 중복 체크
--    IF V_IFS005_CHK > 1 THEN 
--        RS_CODE      := 'E';
--        RS_MSG       := 'ROLLBACK[SP_POP_WRK41_IFR01] ERROR 확정문서 번호 중복';
--        RETURN;
--    END IF;
    --작업자명 구하기
--    BEGIN
--    	SELECT NMLAST INTO V_USER_NM
--        FROM USRMA
--        WHERE USERID = P_USERID;
--                        
--        V_USER_NM := SUBSTRB(V_USER_NM, 1, 10);
--    EXCEPTION
--        WHEN NO_DATA_FOUND THEN
--        	V_USER_NM := '';
--        WHEN OTHERS THEN
--        	V_USER_NM := '';
--    END;   
   
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

    -- 실적 재등록 
    	V_IFID := 'MES_IF_127';
       	V_DOC_NO := FN_GET_MDOCNO('M','IF127');
       	V_DOC_SEQNO := 1;
	    --실적 I/F (수량은 마지막에 업데이트)
       INSERT INTO TB_IFS005 (AUFNR,  CRLOT,  WERKS,  WORKCENTERCODE,  BUDAT,  MACHINE,  WORKGROUP,  PRDQTY,  MEINS,  CRUNTIME,
                              COPNAM,  CUTTER,  CONFM,  CONFC,  CSDATE,  CSTIME,  CEDATE,  CETIME,  MDOCNO,  MDOCSEQ,  MAKE_DATE,
                              MAKER,  MRLOT
                               ) 
                       SELECT AUFNR,  CRLOT,  WERKS,  WORKCENTERCODE,  BUDAT,  MACHINE,  WORKGROUP,  PRDQTY,  MEINS,  CRUNTIME,
                              COPNAM,  CUTTER,  V_COMP_YN,  V_COMP_YN,  CSDATE,  CSTIME,  CEDATE,  CETIME,  V_DOC_NO,  V_DOC_SEQNO,  V_REGDATE,
                              P_USERID,  MRLOT
                         FROM TB_IFS005
                        WHERE RUECK  = V_SDOC_NO
                          AND RMZHL  = V_SDOC_SEQNO
      	;
      
        INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                              WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                              IND_BCD, LOT_NO, ORDER_NO,
                              REGDATE, REGID, REMARK )
		      SELECT          V_DOC_NO, V_DOC_SEQNO, DOC_DIV,
                              WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                              V_IND_BCD, LOT_NO, ORDER_NO,
                              REGDATE, REGID, 'ROLLBACK LOT 병합'
                FROM  TB_WRK021
    		   WHERE  SDOC_NO = V_SDOC_NO
      			 AND  SDOC_SEQNO = V_SDOC_SEQNO  ;
      			
			  UPDATE TB_WRK002 
	   	   		 SET DOC_NO     = V_DOC_NO
	          		,DOC_SEQNO  = V_DOC_SEQNO
	 	 	   WHERE WERKS = V_WERKS
	   	   		 AND MACH_CD = V_MACH_CD
	   	   		 AND IND_BCD = V_IND_BCD;
 
     
     -- 개별바코드 전달
     --RS_IND_BCD := V_IND_BCD;
     --SAP FUNC ID
     SELECT RFCFN
     INTO RS_RFCFN
     FROM TB_ITFMA
     WHERE 1=1
     AND IFID = V_IFID;   --생산오더별 실적 취소 TXN
     --인터페이스 파라미터
     OPEN CUR_1 FOR
     SELECT V_IFID AS I_IF_ID
          , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
     FROM dual;
     --인터페이스 상세 파라미터
     V_SQL := FN_IF_QUERY(V_IFID, V_DOC_NO);
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
