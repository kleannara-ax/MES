
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK86_IFR03" 
(
     P_SDOC_NO           IN VARCHAR2                     --문서번호
    ,P_SDOC_SEQNO        IN VARCHAR2                     --문서번호 순번
--    ,P_IND_BCD			 IN VARCHAR2
    ,P_USERID           IN VARCHAR2                     --USER ID
    ,RS_RFCFN           OUT VARCHAR2                    --실적 RFCFN값
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
    ,CUR_1              OUT SYS_REFCURSOR               --실적 리스트
    ,CUR_2              OUT SYS_REFCURSOR               --실적 데이터
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK86_IFR03  {호출 프로그램 ID 기술}
 * PROGRAM NAME  : HL 실적취소 롤백(실적 재등록) [I/F]
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : .{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 이성민{최초 작성자 명 기술}
 * CREATE DATE   : 2022/11/24 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/11/24    1.0.0   이성민         Initial Version 
 *==============================================================================
 *  관련 테이블
 *
 *=============================================================================*/

AS 
    --프로그램 ID : HL ROLLBACK 
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK86_IFR03';    -- PROCEDURE NAME
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
    V_SAP_WRK_CD        TB_MAS012.SAP_WRK_CD%TYPE;
    V_ROLLCNT           TB_WRK002.ROLLCNT%TYPE;
    V_STA               TB_WRK002.STA%TYPE;
    V_NAUFNR            TB_WRK002.NAUFNR%TYPE;
    V_SQL               VARCHAR2(4000);
    V_REGDATE           DATE := SYSDATE;
    V_IFS002_CHK        NUMBER(5);
    V_IFS011_CHK        NUMBER(5);
    V_IFS019_CHK        NUMBER(5);   
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
--                RS_MSG       := 'ROLLBACK[SP_POP_WRK86_IFR03] 문서번호가 조회되지 않습니다';
--                RETURN;
--            WHEN OTHERS THEN
--                RS_CODE      := 'E';
--                RS_MSG       := 'ROLLBACK[SP_POP_WRK86_IFR03] ERROR';
--                RETURN;
--    END;

    BEGIN
       		SELECT WERKS, MACH_CD, IND_BCD
      		INTO   V_WERKS, V_MACH_CD, V_IND_BCD
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



    -- TB_IFS002 전송실적 확인
    SELECT COUNT(*)
    INTO   V_IFS002_CHK
    FROM   TB_IFS002 
    WHERE  RUECK = V_SDOC_NO
      AND  RMZHL = V_SDOC_SEQNO;
    -- TB_IFS011 전송실적 확인
    SELECT COUNT(*)
    INTO   V_IFS011_CHK
    FROM   TB_IFS011 
    WHERE  RUECK = V_SDOC_NO
      AND  RMZHL = V_SDOC_SEQNO;
    -- TB_IFS019 전송실적 확인
    SELECT COUNT(*)
    INTO   V_IFS019_CHK
    FROM   TB_IFS019 
    WHERE  RUECK = V_SDOC_NO
      AND  RMZHL = V_SDOC_SEQNO;

	-- 확정문서 번호 중복 체크
    IF (V_IFS002_CHK + V_IFS011_CHK + V_IFS019_CHK) > 1 THEN 
        RS_CODE      := 'E';
        RS_MSG       := 'ROLLBACK[SP_POP_WRK86_IFR03] ERROR 확정문서 번호 중복';
        RETURN;
    END IF;
	-- 확정문서 번호 중복 체크
    IF (V_IFS002_CHK + V_IFS011_CHK + V_IFS019_CHK) = 0 THEN 
        RS_CODE      := 'E';
        RS_MSG       := 'ROLLBACK[SP_POP_WRK86_IFR03] ERROR 확정문서 번호 없음';
        RETURN;
    END IF;   


    -- 실적 재등록 P200
    IF V_IFS002_CHK > 0 THEN
    	V_IFID := 'MES_IF_124';
       	V_DOC_NO := FN_GET_MDOCNO('M','IF124');
       	V_DOC_SEQNO := 1;
        INSERT INTO TB_IFS002(AUFNR, LOTNO, PRDCD, WERKS, WORKCENTERCODE, MACHINE, HMACHINE, 
                              HLOTNO1, HMATNR1, HMEINS1, INPQT1,
                              HLOTNO2, HMATNR2, HMEINS2, INPQT2,
                              HLOTNO3, HMATNR3, HMEINS3, INPQT3,
                              PRDDT, PRODT, WORKGROUP, OPNAM,
                              PROQTY, MEINS, RUNTIME, 
                              SDATE, STIME, EDATE, ETIME, 
                              MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
		SELECT      	      AUFNR, LOTNO, PRDCD, WERKS, WORKCENTERCODE, MACHINE, HMACHINE, 
                              HLOTNO1, HMATNR1, HMEINS1, INPQT1,
                              HLOTNO2, HMATNR2, HMEINS2, INPQT2,
                              HLOTNO3, HMATNR3, HMEINS3, INPQT3,
                              PRDDT, PRODT, WORKGROUP, OPNAM,
                              PROQTY, MEINS, RUNTIME, 
                              SDATE, STIME, EDATE, ETIME, 
                              V_DOC_NO, V_DOC_SEQNO, MAKE_DATE, MAKER
		FROM  TB_IFS002
    	WHERE RUECK = V_SDOC_NO
      	AND   RMZHL = V_SDOC_SEQNO
    	;
    END IF;
    -- 실적 재등록 생리대, 기저귀 일반
    IF V_IFS011_CHK > 0 THEN
    	V_IFID := 'MES_IF_133';
       	V_DOC_NO := FN_GET_MDOCNO('M','IF133');
       	V_DOC_SEQNO := 1;
        INSERT INTO TB_IFS011(AUFNR, LOTNO, MATNR, WERKS, WORKCENTERCODE, MACHINE, 
        					  WORKGROUP, OPNAM, BUDAT, PROQTY, MEINS, CONF, RUNTIME,
                              SDATE, STIME, EDATE, ETIME, 
                              MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
        SELECT                AUFNR, LOTNO, MATNR, WERKS, WORKCENTERCODE, MACHINE, 
        					  WORKGROUP, OPNAM, BUDAT, PROQTY, MEINS, CONF, RUNTIME,
                              SDATE, STIME, EDATE, ETIME, 
                              V_DOC_NO, V_DOC_SEQNO, MAKE_DATE, MAKER     
		FROM  TB_IFS011
    	WHERE RUECK = V_SDOC_NO
      	AND   RMZHL = V_SDOC_SEQNO  
      	;
    END IF;
    -- 실적 재등록 생리대 예외생산  
    IF V_IFS019_CHK > 0 THEN
    	V_IFID := 'MES_IF_141';
       	V_DOC_NO := FN_GET_MDOCNO('M','IF141');
       	V_DOC_SEQNO := 1;
        INSERT INTO TB_IFS019(AUFNR, LOTNO, WERKS, BUDAT, MATNR, 
                              PROQTY, MEINS, CONF, RUNTIME, OPNAM, SDATE, STIME, EDATE, ETIME, 
                              MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
    	SELECT				  AUFNR, LOTNO, WERKS, BUDAT, MATNR, 
                              PROQTY, MEINS, CONF, RUNTIME, OPNAM, SDATE, STIME, EDATE, ETIME, 
                              V_DOC_NO, V_DOC_SEQNO, MAKE_DATE, MAKER
		FROM  TB_IFS019
    	WHERE RUECK = V_SDOC_NO
      	AND   RMZHL = V_SDOC_SEQNO                     
        ;
    END IF;   



    INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                          WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                          IND_BCD, LOT_NO, ORDER_NO,
                          REGDATE, REGID, REMARK )
		           SELECT V_DOC_NO, V_DOC_SEQNO, DOC_DIV,
                          WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                          V_IND_BCD, LOT_NO, ORDER_NO,
                          REGDATE, REGID, 'ROLLBACK 부분폐품'
                    FROM  TB_WRK021
    				WHERE SDOC_NO = V_SDOC_NO
      				AND   SDOC_SEQNO = V_SDOC_SEQNO  ;

	UPDATE TB_WRK001 
	   SET DOC_NO     = V_DOC_NO
	      ,DOC_SEQNO  = V_DOC_SEQNO
	      ,SDOC_NO    = V_SDOC_NO
	      ,SDOC_SEQNO = V_SDOC_SEQNO
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
