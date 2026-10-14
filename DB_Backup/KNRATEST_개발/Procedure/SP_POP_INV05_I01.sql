--------------------------------------------------------
--  DDL for Procedure SP_POP_INV05_I01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_INV05_I01" SP_POP_INV05_I01
(
    P_WERKS         IN VARCHAR2 
    ,P_MACH_CD      IN VARCHAR2
    ,P_PROC_CD      IN VARCHAR2 
    ,P_WRK_LIST     IN CLOB
    ,P_USERID       IN VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_INV05
 * PROGRAM NAME  : 자재반납요청
 * VERSION       : 1.0.1
 * DESCRIPTION   : 선택된 자재의 반납요청을 등록한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/05/14
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/14    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_SCH002] : (.R..) 화장지 합지기 생산오더
 * - [TB_SCH011] : (.R..) 화장지 합지기 작업지시
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 * - [TB_WRK001] : (.R..) HL 생산실적 이력
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM            VARCHAR2(100)  := 'SP_POP_INV05_I01';     -- PROCEDURE NAME
    V_PLT_CD            VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID      VARCHAR2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD        NUMBER(5) := 0;
    E_SQL_ERR_MSG       VARCHAR2(4000);
    --내부변수 관리
    V_DATE              DATE := SYSDATE;
    V_PROC_CD           VARCHAR2(20);
    V_DOC_NO            VARCHAR2(20); --반납요청 문서번호
    V_DOC_SEQ           VARCHAR2(6);
    V_WDOC_NO           VARCHAR2(30); --자재출고문서번호
    V_WDOC_SEQNO        VARCHAR2(6); --자재출고문서번호
    V_MACHINE           VARCHAR2(10);
    V_RCVCDS_DT         VARCHAR2(8); --입고일자
    V_DSTBT_DDLIN       VARCHAR2(14); --유통기한
    V_DOC_LIST          VARCHAR2(4000);
    V_SQL               VARCHAR2(4000);
    V_TEMP_QTY          NUMBER(13,3); --기존 반납요청 수량
    --커서용 변수
    --V_WERKS VARCHAR(4);
    V_MATNR             VARCHAR2(20);
    V_STOR_LOC_CD       VARCHAR2(10);
    V_STOR_LOC_TO		VARCHAR2(10);
    V_IND_BCD           VARCHAR2(20);
    V_LOT_NO            VARCHAR2(20);
    V_PRD_DT            VARCHAR2(10);
    V_REQ_QTY           NUMBER(23,3);
    V_UNIT              VARCHAR2(10);
    V_MATNR_DIV         VARCHAR2(10);
    V_LOC_FLG			VARCHAR2(1);
    V_STOK_KY           VARCHAR2(20); --WMS STCKKY
    V_LOT_NUM           VARCHAR2(30); --WMS LOTNUM
    
    V_BS_WGT            TB_INV001.BS_WGT%TYPE;
    V_CON_TYPE          TB_INV001.CON_TYPE%TYPE;
    V_PACK_TYPE         TB_INV001.PACK_TYPE%TYPE;
    V_STCK_STA          TB_INV001.STCK_STA%TYPE;
    V_VBELN_POSNR       VARCHAR2(20);
    V_VBELN             TB_INV001.VBELN%TYPE; 
    V_POSNR              TB_INV001.POSNR%TYPE; 
    V_KUNNR             TB_INV001.KUNNR%TYPE; 
    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_OBJ            JSON_OBJECT_T;
   
    V_DISTRIBUTE_YN         CMCDV.USE_YN%TYPE;     -- WMS 배포 확인
BEGIN
    --예외처리 시작(try)
    BEGIN
	    -- WMS 배포중인경우 메뉴얼로 CMCDV의 USE_YN을 'Y'로 변경 함.
        SELECT USE_YN
          INTO V_DISTRIBUTE_YN
		  FROM CMCDV
 		 WHERE CMCDKY='SYSTEMCHECK';
         
        IF V_DISTRIBUTE_YN = 'Y' THEN
            RS_CODE := 'E';
            RS_MSG := '시스템 점검 중입니다. 1~5분 동안 잠시만 기다려 주세요.';
            RETURN;
        END IF;
	    
        --JSON 데이터 수신
        V_JSON := JSON_OBJECT_T.parse(P_WRK_LIST); -- 전체 데이터
        V_PROC_CD := V_JSON.get_string('PROC_CD'); -- 프로시저명

        --대상데이터 일치여부 확인
        IF V_PROC_CD = 'POP_INV05' THEN
--            --불출요청 문서번호 작성
--            V_DOC_NO := FN_GET_MDOCNO('M','IF400');
--            V_DOC_SEQ := '1';
            --세부 데이터 목록 수신
            V_ARR_LIST := V_JSON.get_array('list');
            --각 항목별 처리
            FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
                --행별 데이터 목록 조회
                V_OBJ := TREAT (V_ARR_LIST.get (i) AS json_object_t);
                V_OBJ := TREAT (V_OBJ.get ('map') AS json_object_t);
                --각 항목별 데이터 조회
                --V_WERKS := V_OBJ.get_string('WERKS');
                V_MATNR := V_OBJ.get_string('MATNR');
                V_IND_BCD := V_OBJ.get_string('IND_BCD');
                V_LOT_NO := V_OBJ.get_string('LOT_NO');
                V_STOR_LOC_CD := V_OBJ.get_string('STOR_LOC_CD');
                V_REQ_QTY := TO_NUMBER(REPLACE(V_OBJ.get_string('RTN_QTY'),',',''));
                V_UNIT := V_OBJ.get_string('UNIT');
                
                --불출요청 가능여부 검색
                SELECT MATNR_DIV, DECODE(NVL(LGPRO,'9999'),NVL(LGFSB,'9999'),'E','S'), LGFSB
                  INTO V_MATNR_DIV, V_LOC_FLG, V_STOR_LOC_TO
                  FROM TB_MAS001
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MATNR = V_MATNR;
                --반제품인경우 반납 불가능
                IF V_MATNR_DIV = 'HALB' THEN
                    ROLLBACK;
                    RS_CODE := 'E';
                    RS_MSG := '요청항목중 반납불가항목이 존재합니다.\n목록을 확인후 반납을 요청하여 주시기 바랍니다.';
                    RETURN;
                END IF;
				--이동위치가 동일한 경우 반납 불가능
                IF V_LOC_FLG = 'E' THEN
                    ROLLBACK;
                    RS_CODE := 'E';
                    RS_MSG := '요청항목중 반납불가항목이 존재합니다.\n목록을 확인후 반납을 요청하여 주시기 바랍니다.';
                    RETURN;
                END IF;
                
                --재고정보 조회
                SELECT STCK_KY, LOT_NUM, PRD_DT, MACHINE, WDOC_NO, WDOC_SEQNO, NVL(RET_REQ_QTY,0), CON_TYPE, PACK_TYPE, VBELN, POSNR, KUNNR, BS_WGT, STCK_STA
                  INTO V_STOK_KY, V_LOT_NUM, V_PRD_DT, V_MACHINE, V_WDOC_NO, V_WDOC_SEQNO, V_TEMP_QTY, V_CON_TYPE, V_PACK_TYPE, V_VBELN, V_POSNR, V_KUNNR, V_BS_WGT, V_STCK_STA
                  FROM TB_INV001
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND STOR_LOC_CD = V_STOR_LOC_CD
                   AND IND_BCD = V_IND_BCD
                   AND MATNR = V_MATNR;
	            IF V_TEMP_QTY > 0.0 THEN
	            	ROLLBACK;
                    RS_CODE := 'E';
                    RS_MSG := '요청항목중 반납이 진행중인 항목이 존재합니다.\n목록을 확인후 반납을 요청하여 주시기 바랍니다.';
                    RETURN;
	            END IF;
               
                BEGIN
                SELECT A.STOR_LOC_FR, A.RCVCDS_DT, A.DSTBT_DDLIN 
                      INTO V_STOR_LOC_TO, V_RCVCDS_DT, V_DSTBT_DDLIN
                  FROM (
                        SELECT STOR_LOC_FR , RCVCDS_DT, DSTBT_DDLIN
                          FROM TB_INV007
                         WHERE WERKS = P_WERKS
                           AND REQ_DIV IN ('10', '40', '50')
                           AND IND_BCD = V_IND_BCD 
                        ORDER BY REGDATE DESC) A
                 WHERE ROWNUM = 1;       
                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        RS_MSG := V_MATNR || ' 자재의 WMS 저장위치가 누락되었습니다.';
                        RS_CODE := 'E';
                        ROLLBACK;
                        RETURN;
                 END;
                 
                --불출요청 문서번호 작성
                V_DOC_NO := FN_GET_MDOCNO('M','IF400');
                V_DOC_SEQ := '1';
                IF V_DOC_LIST IS NULL THEN
                    V_DOC_LIST := V_DOC_NO;
                ELSE
                    V_DOC_LIST := V_DOC_LIST || ',' || V_DOC_NO;
                END IF;
                --불출요청 테이블에 추가
--                INSERT INTO TB_INV002 (DOC_NO, DOC_SEQ, DLFL, REQ_DIV, WERKS, MATNR, QTY, UNIT, IF_STA, REGDATE, REGID)
--                               VALUES (V_DOC_NO, V_DOC_SEQ, 'C', '20', P_WERKS, V_MATNR, V_REQ_QTY, V_UNIT, 'N', V_DATE, P_USERID); 
                
                INSERT INTO TB_INV002 (DOC_NO, DOC_SEQ, DLFL, REQ_DIV, 
                                WERKS, MATNR, QTY, UNIT, STOR_LOC_CD, STCK_STA, 
                                STCK_KY, LOT_NUM, IND_BCD, LOT_NO, OVBELN, OPOSNR, IF_STA, REGDATE, REGID)
                    VALUES (V_DOC_NO, V_DOC_SEQ, 'C', '20', 
                               P_WERKS, V_MATNR, V_REQ_QTY, V_UNIT, V_STOR_LOC_CD, V_STCK_STA, 
                               V_STOK_KY, V_LOT_NUM, V_IND_BCD, V_LOT_NO, SUBSTR('00000' || V_VBELN, -10), SUBSTR('00000' || TO_CHAR(V_POSNR), -6),
                               'N', V_DATE, P_USERID);                

                UPDATE TB_INV001      
                   SET RET_REQ_QTY = V_REQ_QTY
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MATNR = V_MATNR
                   AND LOT_NO = V_LOT_NO
                   AND IND_BCD = V_IND_BCD;
                --설비호기 조회
                IF V_MACHINE IS NULL THEN
                    SELECT MACHINE
                      INTO V_MACHINE
                      FROM TB_MAS012
                     WHERE 1=1
                       AND MACH_CD = P_MACH_CD;
                END IF;
                
--                --입고이력 조회
--                BEGIN
--                SELECT RCVCDS_DT, DSTBT_DDLIN--, STOR_LOC_FR
--                  INTO V_RCVCDS_DT, V_DSTBT_DDLIN--, V_STOR_LOC_TO
--                  FROM ( SELECT RCVCDS_DT, DSTBT_DDLIN 
--						   FROM TB_INV007
--                  		  WHERE 1=1
--                   			AND ROWNUM = 1
--                   			--반납요청시 입고문서번호 조회 불가능으로 인한 수정
--                   			AND MATNR = V_MATNR
--                   			AND LOT_NO = V_LOT_NO
--                   			AND IND_BCD = V_IND_BCD
----                   		AND WDOC_NO = V_WDOC_NO
----                   		AND WDOC_SEQNO = V_WDOC_SEQNO
--                   		  ORDER BY REGDATE DESC
--                   		)
--                 WHERE 1=1
--                   AND ROWNUM = 1
--                 ;
--                EXCEPTION
--                    WHEN NO_DATA_FOUND THEN
--                        V_RCVCDS_DT := '';
--                        V_DSTBT_DDLIN := '';
--                END;
                --I/F 전송
--                INSERT INTO TB_IFSWM004(DOC_NO, DOC_SEQNO, DLFL, WERKS, LOTA04,
--                                            MATNR, QTY, UNIT, STOR_LOC_FROM, STOR_LOC_TO, STCK_STA,
--                                            IND_BCD, LOT_NO, STOK_KY, LOT_NUM,
--                                            RCVGDS_DT, DSTBT_DDLIN, PRDC_DT, RTN_DT, IF_GET_DATE)
--                                    VALUES(V_DOC_NO, V_DOC_SEQ, 'C', P_WERKS, V_MACHINE,
--                                            V_MATNR, V_REQ_QTY, V_UNIT, V_STOR_LOC_CD, V_STOR_LOC_TO, '00', 
--                                            V_IND_BCD, V_LOT_NO, V_STOK_KY, V_LOT_NUM,
--                                            V_RCVCDS_DT, V_DSTBT_DDLIN, V_PRD_DT, TO_CHAR(V_DATE,'YYYYMMDD'), V_DATE);
                
                V_VBELN_POSNR := SUBSTR('00000' || V_VBELN, -10) || SUBSTR('00000' || TO_CHAR(V_POSNR), -6);
        
                --WMS로 자재/완제품 반납요청
                INSERT INTO TB_IFSWM004(DOC_NO, DOC_SEQNO, DLFL, WERKS,
                                        MATNR, QTY, UNIT, STOR_LOC_FROM, STOR_LOC_TO, LOTA03, STCK_STA,
                                        IND_BCD, LOT_NO, LOTA04, LOTA16, LOTA17, STOK_KY, LOT_NUM,
                                        PRDC_DT, RTN_DT, IF_GET_DATE)
                                VALUES(V_DOC_NO, V_DOC_SEQ, 'C', P_WERKS,
                                        V_MATNR, V_REQ_QTY, V_UNIT, V_STOR_LOC_CD, V_STOR_LOC_TO, V_PACK_TYPE, V_STCK_STA, 
                                        V_IND_BCD, V_LOT_NO, V_VBELN_POSNR,V_BS_WGT, V_CON_TYPE, V_STOK_KY, V_LOT_NUM,
                                        V_PRD_DT, TO_CHAR(V_DATE,'YYYYMMDD'), V_DATE);                            
            END LOOP;

            --자재 반납요청
            V_SQL := FN_IF_QUERY('MES_IF_400', V_DOC_LIST);
            IF V_SQL IS NOT NULL THEN
            	OPEN CUR_1 FOR V_SQL;
            END IF;

            --작업 정상 종료 코드 등록
            RS_CODE := 'S';
            RS_MSG := V_DOC_NO;
        ELSE    
            RS_CODE := 'E';
            RS_MSG := 'PROCEDURE ERROR';
        END IF;

        --작업 정상 종료 코드 등록
        RS_CODE := 'S';
    --예외처리(catch)
--    EXCEPTION
--    WHEN E_EXCEPTION_USER THEN
--        -- 에러 내역 SET
--        E_SQL_ERR_CD        := -20000;
--        E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--        ROLLBACK;
--        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--
--        RS_CODE := 'E';
--        RS_MSG  := SQLERRM;
--        RETURN;
--    WHEN OTHERS THEN
--        E_SQL_ERR_CD        := -20000;
--        E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--        ROLLBACK;
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
--
--        RS_CODE := 'E';
--        RS_MSG  := SQLERRM;
--        RETURN;
    --예외처리 종료
    END;
END ;

/
