--------------------------------------------------------
--  DDL for Procedure SP_IF_PUT_REIFS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_PUT_REIFS" 
(
    P_IF_TYPE       IN VARCHAR2 
    ,P_MACH_CD		IN VARCHAR2
    ,P_IND_BCD		IN VARCHAR2
    ,P_PRFM_FUNC    OUT VARCHAR2
    ,P_WDOC_NO      OUT VARCHAR2 
    ,P_USERID       IN VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE		OUT VARCHAR2 
    ,RS_MSG			OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
    ,CUR_3          OUT SYS_REFCURSOR
    ,CUR_4          OUT SYS_REFCURSOR
    ,CUR_5          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_IF_PUT_REIFS
 * PROGRAM NAME  : SAP 전송결과 재발송
 * VERSION       : 1.0.1
 * DESCRIPTION   : 선택된 실적의 재발송 정보를 등록 및 반환한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/09/02
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/06/30    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM			VARCHAR2(100)  := 'SP_IF_PUT_IFSRTN';     -- PROCEDURE NAME
    V_PLT_CD			VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID		VARCHAR2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER	EXCEPTION;
    E_SQL_ERR_CD		NUMBER(5) := 0;
    E_SQL_ERR_MSG		VARCHAR2(4000);
    --내부변수 관리
    V_DATE				DATE := SYSDATE;
	V_PROC_CD			VARCHAR2(2); --공정코드
	V_IF_ID             VARCHAR2(20); --MES IF ID
	V_DOC_PRFM          VARCHAR2(20); --실적등록 문서번호
    V_DOC_ORDR          VARCHAR2(20); --오더완료 문서번호
    V_DOC_WMS           VARCHAR2(20); --입고요청 문서번호
    V_RESULT			VARCHAR2(1); --처리결과
    V_MESSAGE			VARCHAR2(4000); --결과메세지
    V_SQL				VARCHAR(4000);

BEGIN
    --예외처리 시작(try)
    BEGIN
	    --결과 초기설정
        RS_CODE := 'S';
        RS_MSG := '';
       
        --실적 재발송
        IF P_IF_TYPE = 'P' THEN
        	--공정코드 조회
        	SELECT PROC_CD
        	  INTO V_PROC_CD
        	  FROM TB_MAS012
        	 WHERE 1=1
        	   AND MACH_CD = P_MACH_CD;
        	  
        	--재발송 실적 조회
        	BEGIN
	        	SELECT DOC_NO
	        	  INTO V_DOC_PRFM
	        	  FROM TB_WRK021
	        	 WHERE 1=1
	        	   AND IND_BCD = P_IND_BCD
	        	   AND DOC_DIV = '1'
	        	   AND NVL(SDOC_NO,'E') = 'E';
        	EXCEPTION WHEN NO_DATA_FOUND THEN
        		RS_CODE := 'E';
	        	RS_MSG := '해당실적은 재발송 대상이 아닙니다.';
	        	RETURN;
        	END;
        	--재발송 실적완료 조회
        	BEGIN
	        	SELECT DOC_NO
	        	  INTO V_DOC_ORDR
	        	  FROM TB_WRK021
	        	 WHERE 1=1
	        	   AND IND_BCD = P_IND_BCD
	        	   AND DOC_DIV = '20'
	        	   AND NVL(SDOC_NO,'E') = 'E';
        	EXCEPTION WHEN NO_DATA_FOUND THEN
				V_DOC_ORDR := '';
        	END;
        	  
        	--화장지 합지기
        	IF V_PROC_CD = 'AA' THEN
        		V_IF_ID := 'MES_IF_123';
        	--화장지 가공기
        	ELSIF V_PROC_CD = 'RA' THEN
        		V_IF_ID := 'MES_IF_124';
        	--생리대/기저귀
        	ELSIF V_PROC_CD = 'RB' OR V_PROC_CD = 'RC' THEN
        		V_IF_ID := 'MES_IF_133';
        	--예외생산
        	ELSE
        		V_IF_ID := 'MES_IF_141';
        	END IF;
        	IF V_DOC_PRFM IS NOT NULL THEN
				--실적 등록
				SELECT RFCFN
				  INTO P_PRFM_FUNC
				  FROM TB_ITFMA
				 WHERE 1=1
				   AND IFID = V_IF_ID;
				--인터페이스 파라미터
				OPEN CUR_1 FOR
				SELECT V_IF_ID AS I_IF_ID
					 , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
				  FROM dual;
				--인터페이스 상세 파라미터
				V_SQL := FN_IF_QUERY(V_IF_ID, V_DOC_PRFM);
				IF V_SQL IS NOT NULL THEN
					OPEN CUR_2 FOR V_SQL;
				END IF;
				IF V_PROC_CD = 'RA' THEN
					SELECT DOC_NO
					  INTO V_DOC_WMS
					  FROM TB_IFSWM005
					 WHERE 1=1
					   AND IND_BCD = P_IND_BCD;
					 --완제품 입고요청
		             V_SQL := FN_IF_QUERY('MES_IF_402', V_DOC_WMS);
		             IF V_SQL IS NOT NULL THEN
		             	OPEN CUR_5 FOR V_SQL;
		             END IF;
				END IF;
			END IF;
			--오더 완료 등록
			IF V_DOC_ORDR IS NOT NULL THEN
				--실적 등록
				SELECT RFCFN
				  INTO P_PRFM_FUNC
				  FROM TB_ITFMA
				 WHERE 1=1
				   AND IFID = V_IF_ID;
				--인터페이스 파라미터
				OPEN CUR_3 FOR
				SELECT V_IF_ID AS I_IF_ID
					 , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
				  FROM dual;
				--인터페이스 상세 파라미터
				V_SQL := FN_IF_QUERY(V_IF_ID, V_DOC_PRFM);
				IF V_SQL IS NOT NULL THEN
					OPEN CUR_4 FOR V_SQL;
				END IF;
			END IF;
        --입고요청 재발송
        ELSIF P_IF_TYPE = 'W' THEN
        	SELECT DOC_NO
			  INTO V_DOC_WMS
			  FROM TB_IFSWM005
			 WHERE 1=1
			   AND IND_BCD = P_IND_BCD
			   AND IF_STATUS = 'N' --202212 WSW
			   ;
			--완제품 입고요청
			P_WDOC_NO := V_DOC_WMS;
		    V_SQL := FN_IF_QUERY('MES_IF_402', V_DOC_WMS);
		    IF V_SQL IS NOT NULL THEN
		    	OPEN CUR_5 FOR V_SQL;
		    END IF;
        
        END IF;
       
       --RFC 미사용 항목에 대하여 기본값 등록
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
END SP_IF_PUT_REIFS;

/
