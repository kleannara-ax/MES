
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_PUT_IFRESEND" 
(
    P_DOC_DIV       IN VARCHAR2 
    ,P_MACH_CD		IN VARCHAR2
    ,P_IND_BCD		IN VARCHAR2
    ,P_SAP_FUNC    OUT VARCHAR2
    ,P_USERID       IN VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE		OUT VARCHAR2 
    ,RS_MSG			OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_IF_PUT_REIFS
 * PROGRAM NAME  : SAP 전송결과 재발송
 * VERSION       : 1.0.1
 * DESCRIPTION   : 선택된 실적의 재발송 정보를 등록 및 반환한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/09/18
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/09/18    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM			VARCHAR2(100)  := 'SP_IF_PUT_IFRESEND';     -- PROCEDURE NAME
    V_PLT_CD			VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID		VARCHAR2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER	EXCEPTION;
    E_SQL_ERR_CD		NUMBER(5) := 0;
    E_SQL_ERR_MSG		VARCHAR2(4000);
    --내부변수 관리
    V_DATE				DATE := SYSDATE;
    V_DOC_DIV			NUMBER := TO_NUMBER(P_DOC_DIV);
	V_PROC_CD			VARCHAR2(2); --공정코드
	V_IF_ID             VARCHAR2(20); --MES IF ID
	V_DOC_NO          VARCHAR2(20); --문서번호
    V_SQL				VARCHAR(4000);

BEGIN
    --예외처리 시작(try)
    BEGIN
	    --결과 초기설정
        RS_CODE := 'S';
        RS_MSG := '';
       
        --공정코드 조회
		SELECT PROC_CD
          INTO V_PROC_CD
          FROM TB_MAS012
         WHERE 1=1
           AND MACH_CD = P_MACH_CD;
        --재발송 실적 조회
        BEGIN
	        SELECT DOC_NO
	          INTO V_DOC_NO
	          FROM TB_WRK021_ALL
	         WHERE 1=1
	           AND IND_BCD = P_IND_BCD
	           AND DOC_DIV = V_DOC_DIV
	           AND NVL(SDOC_NO,'E') = 'E';
        EXCEPTION WHEN NO_DATA_FOUND THEN
        	RS_CODE := 'E';
	        RS_MSG := '해당실적은 재발송 대상이 아닙니다.';
	        RETURN;
        END;
        	  
        --IF ID 설정
        IF V_DOC_DIV = 1 OR V_DOC_DIV = 20 THEN
        	--화장지 합지기
        	IF V_PROC_CD = 'AA' THEN
        		V_IF_ID := 'MES_IF_123';
        	--화장지 가공기
        	ELSIF V_PROC_CD = 'RA' THEN
        		V_IF_ID := 'MES_IF_124';
        	--생리대/기저귀
        	ELSIF V_PROC_CD = 'RB' OR V_PROC_CD = 'RC' THEN
        		V_IF_ID := 'MES_IF_133';
        	--재단기
        	ELSIF V_PROC_CD = 'CA' THEN
        		V_IF_ID := 'MES_IF_127';
        	--포장기
        	ELSIF V_PROC_CD = 'PA' OR V_PROC_CD = 'PB' OR V_PROC_CD = 'PC' THEN
        		V_IF_ID := 'MES_IF_128';
        	--예외생산
        	ELSE
        		V_IF_ID := 'MES_IF_141';
        	END IF;
		ELSIF V_DOC_DIV = 2 THEN
			--생산폐품
			V_IF_ID := 'MES_IF_134';
		ELSIF V_DOC_DIV = 6 OR V_DOC_DIV = 7 OR V_DOC_DIV = 8 THEN
			--재고이전
			V_IF_ID := 'MES_IF_131';
        END IF;
       
       --재전송 데이터
       IF V_DOC_NO IS NOT NULL AND V_IF_ID IS NOT NULL THEN
       		SELECT RFCFN
			  INTO P_SAP_FUNC
			  FROM TB_ITFMA
			 WHERE 1=1
			   AND IFID = V_IF_ID;
			--인터페이스 파라미터
			OPEN CUR_1 FOR
			SELECT V_IF_ID AS I_IF_ID
				 , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
			  FROM dual;
			--인터페이스 상세 파라미터
			V_SQL := FN_IF_QUERY(V_IF_ID, V_DOC_NO);
			IF V_SQL IS NOT NULL THEN
				OPEN CUR_2 FOR V_SQL;
			END IF;
		END IF;
       
       --RFC 미사용 항목에 대하여 기본값 등록
        IF CUR_1%ISOPEN = FALSE THEN
            OPEN CUR_1 FOR SELECT 1 FROM dual;
        END IF;
        IF CUR_2%ISOPEN = FALSE THEN
            OPEN CUR_2 FOR SELECT 1 FROM dual;
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
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END SP_IF_PUT_IFRESEND;
/
