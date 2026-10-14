--------------------------------------------------------
--  DDL for Procedure SP_IF_PUT_IFSRTN_HL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_PUT_IFSRTN_HL" 
(
    P_IF_ID         IN VARCHAR2 
    ,P_IF_KEY       IN VARCHAR2 
    ,P_RFC_DATA     IN CLOB
    ,P_USERID       IN VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     OUT VARCHAR2 
    ,RS_MSG      OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : SP_IF_PUT_IFSRTN_HL
 * PROGRAM NAME  : SAP 실적 전송결과 등록
 * VERSION       : 1.0.1
 * DESCRIPTION   : HL 실적의 SAP전송결과를 등록한다.
 *                 
 * AUTHOR NAME   : 이성민
 * CREATE DATE   : 2022/06/30
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/11/22    1.0.0   이성민         Initial Version
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_IF_PUT_IFSRTN_HL';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리
    V_DATE DATE := SYSDATE;
    V_TABLE_ID VARCHAR2(20);
    V_PROC_CD VARCHAR2(20);
    V_ORDER_NO VARCHAR2(10);
    V_MDOC_NO VARCHAR2(30);
    V_MDOC_SEQ VARCHAR2(6);
    V_SDOC_NO VARCHAR2(30);
    V_SDOC_SEQ VARCHAR2(10);
    V_NAUFNR_NO VARCHAR2(10);       -- 비계획생산 오더번호
    V_SRESULT VARCHAR2(1);
    V_SMESSAGE VARCHAR2(1000);
    V_RESULT VARCHAR2(1);
    V_MESSAGE VARCHAR2(4000);
    V_SEQNO NUMBER;
    V_SQL VARCHAR(4000);
    --커서용 변수
    V_CHK VARCHAR(1);
    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_OBJ            JSON_OBJECT_T;
BEGIN
    --예외처리 시작(try)
    BEGIN
        --결과 초기설정
        V_RESULT := 'S'; --S:송신완료, E:에러
        V_MESSAGE := '';
        --조회 테이블 검색
        SELECT IFTBL
          INTO V_TABLE_ID
          FROM TB_ITFMA
         WHERE 1=1
           AND IFID = P_IF_ID;
        --JSON 데이터 수신
        V_JSON := JSON_OBJECT_T.parse(P_RFC_DATA); -- 전체 데이터
        V_PROC_CD := V_JSON.get_string('PROC_CD'); -- 프로시저명

        --대상데이터 일치여부 확인
        IF V_PROC_CD = P_IF_ID THEN
            --세부 데이터 목록 수신
            V_ARR_LIST := V_JSON.get_array('list');
            --각 항목별 처리
            V_SEQNO := 0;
            --SAP 결과 등록
            FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
                --행별 데이터 목록 조회
                V_OBJ := TREAT (V_ARR_LIST.get (i) AS json_object_t);
                V_OBJ := TREAT (V_OBJ.get ('map') AS json_object_t);
                --각 항목별 데이터 조회
                V_ORDER_NO := V_OBJ.get_string('AUFNR');
                V_MDOC_NO := V_OBJ.get_string('MDOCNO');
                V_MDOC_SEQ := V_OBJ.get_string('MDOCSEQ');
                V_SRESULT := V_OBJ.get_string('TYPE');
                V_SMESSAGE := REPLACE(V_OBJ.get_string('MESSAGE'), '''', '');

                --SAP 확정번호 조회
                IF (P_IF_ID = 'MES_IF_123') 
                    OR (P_IF_ID = 'MES_IF_125') 
                    OR (P_IF_ID = 'MES_IF_130')
                    OR (P_IF_ID = 'MES_IF_131')
                    OR (P_IF_ID = 'MES_IF_134')
                    OR (P_IF_ID = 'MES_IF_142') --등급변경 오더번호 없음
                    OR (P_IF_ID = 'MES_IF_143')
                    OR (P_IF_ID = 'MES_IF_144') THEN
                    V_SDOC_NO := V_OBJ.get_string('MBLNR');
                    V_SDOC_SEQ := V_OBJ.get_string('MJAHR');
                ELSE
                    V_SDOC_NO := V_OBJ.get_string('RUECK');     --기본값
                    V_SDOC_SEQ := V_OBJ.get_string('RMZHL');     --기본값
                END IF;

                IF (P_IF_ID = 'MES_IF_125') THEN
                    V_NAUFNR_NO := V_OBJ.get_string('NAUFNR');
                ELSIF (P_IF_ID = 'MES_IF_133') THEN
                    V_NAUFNR_NO := V_OBJ.get_string('PAUFNR');
                END IF;

                IF V_SRESULT = 'E' THEN
                    V_SDOC_NO := 'E';
                END IF;

                --결과 정보 저장
                V_SQL := 'UPDATE ' || V_TABLE_ID;
                IF (V_TABLE_ID = 'TB_IFS012') --폐품 등록
                    OR (V_TABLE_ID = 'TB_IFS008') --자재투입량
                    OR (V_TABLE_ID = 'TB_IFS009') --재고이동
                    -- OR (V_TABLE_ID = 'TB_IFS014')
                    OR (V_TABLE_ID = 'TB_IFS021') --등급변경 오더번호 없음
                    --OR (V_TABLE_ID = 'TB_IFS022') 
                    THEN
                    V_SQL := V_SQL || ' SET MBLNR = ''' || V_SDOC_NO || '''';
                    V_SQL := V_SQL || ' , MJAHR = ''' || V_SDOC_SEQ || '''';
                    V_SQL := V_SQL || ' , ZRESULT = ''' || V_SRESULT || '''';
                ELSIF (V_TABLE_ID = 'TB_IFS016') --비가동 취소
                	OR (V_TABLE_ID = 'TB_IFS007') --실적취소
                	OR (V_TABLE_ID = 'TB_IFS014') --투입량 취소
                	OR (V_TABLE_ID = 'TB_IFS010') --재고이동 취소
                	OR (V_TABLE_ID = 'TB_IFS020') --Lot변경 취소
                	OR (V_TABLE_ID = 'TB_IFS022') --폐품 취소
                	THEN 
                    V_SQL := V_SQL || ' SET ZRESULT = ''' || V_SRESULT || '''';
                ELSE
                    V_SQL := V_SQL || ' SET RUECK = ''' || V_SDOC_NO || '''';
                    V_SQL := V_SQL || ' , RMZHL = ''' || V_SDOC_SEQ || '''';
                    V_SQL := V_SQL || ' , ZRESULT = ''' || V_SRESULT || '''';
                END IF;

                IF (P_IF_ID = 'MES_IF_125')  THEN
                    V_SQL := V_SQL || ' , NAUFNR = ''' || V_NAUFNR_NO || '''';
                ELSIF (P_IF_ID = 'MES_IF_133')  THEN
                    V_SQL := V_SQL || ' , PAUFNR = ''' || V_NAUFNR_NO || '''';
                END IF;

                --V_SQL := V_SQL || ' , ZRESULT = ''' || V_SRESULT || '''';
                V_SQL := V_SQL || ' , ZMESSAGE = ''' || V_SMESSAGE || '''';
                V_SQL := V_SQL || ' , ZRESULT_DATE = SYSDATE';
                V_SQL := V_SQL || ' , IF_MES_KEY = ''' || P_IF_KEY || '''';

                IF (P_IF_ID = 'MES_IF_136') 
                    OR (P_IF_ID = 'MES_IF_133' AND V_NAUFNR_NO IS NOT NULL) --생리대 폐품 등록시 1P제품 오더로 반환됨
                    OR (P_IF_ID = 'MES_IF_134') --생리대 폐품 등록시 1P제품 오더로 반환됨
                    OR (P_IF_ID = 'MES_IF_142') --등급변경 오더번호 없음
                    OR (P_IF_ID = 'MES_IF_146') 
                    OR (P_IF_ID = 'MES_IF_125') THEN        -- 점보롤 비계획 생산의 경우 오더번호가 없어서 예외처리
                    V_SQL := V_SQL || ' WHERE 1=1';
                ELSE
                    V_SQL := V_SQL || ' WHERE AUFNR = ''' || V_ORDER_NO || '''';
                END IF;
                V_SQL := V_SQL || ' AND MDOCNO = ''' || V_MDOC_NO || '''';
                V_SQL := V_SQL || ' AND LPAD(MDOCSEQ,6,''0'') = ''' || V_MDOC_SEQ || '''';

                EXECUTE IMMEDIATE V_SQL;

                --성공건이 아닌 경우 LOG에 실패로 등록
                IF V_SRESULT != 'S' THEN
                    V_RESULT := 'E';
                    V_MESSAGE := V_MESSAGE || ',' || V_SMESSAGE;
                END IF;

                --문서 이력 정보 수정
                UPDATE TB_WRK021
                   SET SDOC_NO = V_SDOC_NO
                     , SDOC_SEQNO = V_SDOC_SEQ
                 WHERE 1=1
                   AND DOC_NO = V_MDOC_NO
                   AND DOC_SEQNO = V_MDOC_SEQ;

                V_SEQNO := V_SEQNO+1;
            END LOOP;

            --IF Log 등록
            INSERT INTO TB_ITFMESLOG (SEQNO, IFID, COMSTAT, ERRTXT, CREDAT, CRETIM, CDATE, CREUSR)
                                VALUES(P_IF_KEY, P_IF_ID, V_RESULT, V_MESSAGE, TO_CHAR(V_DATE, 'YYYYMMDD'), TO_CHAR(V_DATE, 'HH24MISS'), V_DATE, P_IF_ID);

            IF     (V_TABLE_ID = 'TB_IFS016') --비가동 취소
                OR (V_TABLE_ID = 'TB_IFS007') --실적취소
                OR (V_TABLE_ID = 'TB_IFS014') --투입량 취소
                OR (V_TABLE_ID = 'TB_IFS010') --재고이동 취소
                OR (V_TABLE_ID = 'TB_IFS020') --Lot변경 취소
                OR (V_TABLE_ID = 'TB_IFS022') --폐품 취소
            		THEN 
	            --작업 정상 종료 코드 등록, 단 취소 RFC 인경우는 COMMMIT 안함.
	            RS_CODE := 'S';
	            RS_MSG := V_SMESSAGE;
           	ELSE
    	        --작업 정상 종료 코드 등록
	            RS_CODE := 'S';
	            RS_MSG := V_SMESSAGE;
           	END IF;
        ELSE    
            RS_CODE := 'E';
            RS_MSG := 'PROCEDURE ERROR';
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
END SP_IF_PUT_IFSRTN_HL;

/
