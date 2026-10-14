
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK41_D02" 
(
    P_WERKS                 IN VARCHAR2
    ,P_MACH_CD              IN VARCHAR2 
    ,P_USERID               IN VARCHAR2
    ,P_ORDER_NO             IN VARCHAR2 
    ,P_WRK_ORDR_NO          IN VARCHAR2 
    ,P_WRK_ORDR_SEQNO       IN VARCHAR2 
    ,P_DISPO_FUNC           OUT VARCHAR2
    ,P_PRFM_FUNC            OUT VARCHAR2
    ,Lang                   IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE                OUT VARCHAR2 
    ,RS_MSG                 OUT VARCHAR2
    ,CUR_1                  OUT SYS_REFCURSOR
    ,CUR_2                  OUT SYS_REFCURSOR
    ,CUR_3                  OUT SYS_REFCURSOR
    ,CUR_4                  OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK41
 * PROGRAM NAME  : HL 폐품등록(기존 폐품실적 취소)
 * VERSION       : 1.0.0
 * DESCRIPTION   : 진행중인 작업지시를 변경시 폐품정보 등록이전 기존 폐품정보 취소처리
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/09/14
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/09/14    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM         VARCHAR2(100)  := 'SP_POP_WRK41_D02';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '41';
    V_SESS_USER_ID   varchar2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리
    V_WRK_ORDR_SEQNO        NUMBER(5,0) := TO_NUMBER(P_WRK_ORDR_SEQNO);
    --내부 변수 등록
    V_DATE                  DATE := SYSDATE;
    V_DOC_DISPO_CNL			TB_WRK016.DOC_NO%TYPE;		--폐품취소문서번호
    V_DOC_SEQ_DISPO			TB_WRK016.DOC_SEQNO%TYPE;	--폐품취소문서순번
    V_DOC_PRFM_CNL			TB_WRK016.DOC_NO%TYPE;		--실적취소문서번호
    V_DOC_SEQ_PRFM			TB_WRK016.DOC_SEQNO%TYPE;	--실적취소문서순번
	V_SAP_WRK_CD			TB_MAS012.SAP_WRK_CD%TYPE;	--SAP작업장 코드
	V_STOR_LOC_CD           TB_MAS001.LGPRO%TYPE;		--저장위치
	V_IND_BCD				TB_WRK016.IND_BCD%TYPE;		--품목개별바코드
    V_IND_BCD_M				TB_WRK016.IND_BCD%TYPE;		--반제품개별바코드
    V_LOT_NO				TB_WRK016.LOT_NO%TYPE;		--품목LOT
    V_LOT_NO_M				TB_WRK016.LOT_NO_M%TYPE;	--반제품LOT
    V_MATNR					TB_WRK016.MATNR%TYPE;		--자재코드
    V_MATNR_M				TB_WRK016.MATNR_M%TYPE;		--반제품 자재코드
    V_PRFM_DT 		        TB_WRK016.PRFM_DT%TYPE;		--실적일자
    V_PRFM_QTY              TB_WRK016.PRFM_QTY%TYPE;	--실적수량
    V_DISPO_QTY 		    TB_WRK016.DISPO_QTY%TYPE;	--폐품수량
    V_DOC_NO_PRE_1			TB_WRK016.DOC_NO%TYPE;   	--기존 폐품 문서번호     
    V_DOC_SEQNO_PRE_1		TB_WRK016.DOC_SEQNO%TYPE;	--기존 폐품 문서순번
    V_SDOC_NO_PRE_1			TB_WRK016.SDOC_NO%TYPE;     --기존 폐품 SAP문서번호   
    V_SDOC_SEQNO_PRE_1		TB_WRK016.SDOC_SEQNO%TYPE;  --가존 폐품 SAP문서순번
    V_DOC_NO_PRE_2			TB_WRK001.DOC_NO%TYPE;      --기존 실적 문서번호
    V_DOC_SEQNO_PRE_2		TB_WRK001.DOC_SEQNO%TYPE;   --기존 실적 문서순번
	V_SDOC_NO_PRE_2			TB_WRK001.SDOC_NO%TYPE;     --기존 실적 SAP문서번호   
    V_SDOC_SEQNO_PRE_2		TB_WRK001.SDOC_SEQNO%TYPE;  --가존 실적 SAP문서순번
    V_PAUFNR                TB_WRK001.PAUFNR%TYPE;		--반제품 실적 오더번호
    V_DIF_ID				VARCHAR2(20) := 'MES_IF_144'; --폐품 취소 IF
    V_PIF_ID				VARCHAR2(20) := 'MES_IF_129'; --실적 취소 IF
    V_SQL_D					VARCHAR2(4000);				--페품취소 상세정보
    V_SQL_P					VARCHAR2(4000);				--실적취소 상세정보

BEGIN
    --예외처리 시작(try)
    BEGIN
		--폐품정보 조회
		BEGIN
			SELECT IND_BCD_M, LOT_NO, LOT_NO_M,  MATNR, MATNR_M, PRFM_DT, PRFM_QTY, DISPO_QTY, 
                    DOC_NO, DOC_SEQNO, SDOC_NO, SDOC_SEQNO
			  INTO V_IND_BCD_M, V_LOT_NO, V_LOT_NO_M,  V_MATNR, V_MATNR_M, V_PRFM_DT, V_PRFM_QTY, V_DISPO_QTY,
                    V_DOC_NO_PRE_1, V_DOC_SEQNO_PRE_1, V_SDOC_NO_PRE_1, V_SDOC_SEQNO_PRE_1
              FROM TB_WRK016
             WHERE WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
		EXCEPTION WHEN NO_DATA_FOUND THEN
			RS_CODE := 'N';
			RS_MSG := '폐품이력이 존재하지 않습니다.';
			RETURN;
		END;
	
		--문서번호 생성
        --폐품취소
        V_DOC_DISPO_CNL := FN_GET_MDOCNO('M','IF145');
        V_DOC_SEQ_DISPO := 0;
        --실적취소
        V_DOC_PRFM_CNL := FN_GET_MDOCNO('M','IF129');
        V_DOC_SEQ_PRFM := 0;
       
        --SAP 작업장코드 조회
		SELECT SAP_WRK_CD
		  INTO V_SAP_WRK_CD
		  FROM TB_MAS012
		 WHERE MACH_CD = P_MACH_CD;
		--자재 위치정보 조회
        SELECT LGPRO  INTO V_STOR_LOC_CD
          FROM TB_MAS001
         WHERE WERKS = P_WERKS
           AND MATNR = V_MATNR_M;

        --폐품 취소 등록
         V_DOC_SEQ_DISPO := V_DOC_SEQ_DISPO + 1;
         INSERT INTO TB_IFS022(WORKCENTERCODE, AUFNR, POSNR, BUDAT,
                                MATNR, MENGE, WERKS, LGORT, CHARG, MDOCNO, MDOCSEQ,
                                MBLNR, MJAHR, MAKE_DATE)
                        VALUES(V_SAP_WRK_CD, P_ORDER_NO, '10', V_PRFM_DT, 
                                V_MATNR_M, V_DISPO_QTY, P_WERKS, V_STOR_LOC_CD, V_LOT_NO_M, V_DOC_DISPO_CNL, TO_CHAR(V_DOC_SEQ_DISPO),
                                V_SDOC_NO_PRE_1, V_SDOC_SEQNO_PRE_1, V_DATE);
		 --폐품 이력 수정
         UPDATE TB_WRK016
            SET CNL_YN = 'Y'
          WHERE WERKS = P_WERKS
            AND MACH_CD = P_MACH_CD
            AND WRK_ORDR_NO = P_WRK_ORDR_NO
            AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;  
            
         --실적 정보 조회
         SELECT DOC_NO, DOC_SEQNO, SDOC_NO, SDOC_SEQNO, PAUFNR
           INTO V_DOC_NO_PRE_2, V_DOC_SEQNO_PRE_2, V_SDOC_NO_PRE_2, V_SDOC_SEQNO_PRE_2, V_PAUFNR
           FROM TB_WRK001
          WHERE WERKS = P_WERKS
            AND MACH_CD = P_MACH_CD
            AND IND_BCD = V_IND_BCD_M;

         --실적 취소 등록
         V_DOC_SEQ_PRFM := V_DOC_SEQ_PRFM + 1;
--         INSERT INTO TB_IFS007(RUECK, RMZHL, MDOCNO, MDOCSEQ,
--                                MAKE_DATE, MAKER, WORKCENTERCODE, AUFNR, MBLNR, LOTNO)
--                        VALUES(V_SDOC_NO_PRE_2, V_SDOC_SEQNO_PRE_2, V_DOC_PRFM_CNL, TO_CHAR(V_DOC_SEQ_PRFM),
--                                V_DATE, P_USERID, V_SAP_WRK_CD, V_PAUFNR, V_SDOC_NO_PRE_2, V_LOT_NO_M); 
		--실적 이력 수정
        UPDATE TB_WRK001
           SET CNL_YN = 'Y',
               PRFM_GTHR_YN = 'N'
         WHERE WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND IND_BCD = V_IND_BCD_M
           AND NVL(CNL_YN, 'N') = 'N';    
          
        --RFC 전송데이터 작성
		--폐품 취소
		SELECT RFCFN
		  INTO P_DISPO_FUNC
		  FROM TB_ITFMA
		 WHERE 1=1
		   AND IFID = V_DIF_ID;
		--인터페이스 파라미터
		OPEN CUR_1 FOR
		SELECT V_DIF_ID AS I_IF_ID
			 , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
		  FROM dual;
		--인터페이스 상세 파라미터
		V_SQL_D := FN_IF_QUERY(V_DIF_ID, V_DOC_DISPO_CNL);
		IF V_SQL_D IS NOT NULL THEN
			OPEN CUR_2 FOR V_SQL_D;
		END IF;
	
		--실적 취소
		SELECT RFCFN
		  INTO P_PRFM_FUNC
		  FROM TB_ITFMA
		 WHERE 1=1
		   AND IFID = V_PIF_ID;
		--인터페이스 파라미터
		OPEN CUR_3 FOR
		SELECT V_PIF_ID AS I_IF_ID
			 , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
		  FROM dual;
		--인터페이스 상세 파라미터
		V_SQL_P := FN_IF_QUERY(V_PIF_ID, V_DOC_PRFM_CNL);
		IF V_SQL_P IS NOT NULL THEN
			OPEN CUR_4 FOR V_SQL_P;
		END IF;
       
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
        E_SQL_ERR_CD        := -20001;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END SP_POP_WRK41_D02;
/
