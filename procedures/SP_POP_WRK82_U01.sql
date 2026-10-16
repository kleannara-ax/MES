
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK82_U01" 
(
    P_WERKS             IN VARCHAR2 --plantcode
    ,P_WRK_ORDR_NO      IN VARCHAR2 --작업지시번호
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2 --작업지시순번
    ,P_MACH_CD          IN VARCHAR2 --설비코드
    ,P_MATNR            IN VARCHAR2 --자재코드
    ,P_IND_BCD          IN VARCHAR2 --업체/개별바코드
	,P_STCK_QTY		    IN VARCHAR2 --실재고량
    ,P_USER_ID          IN VARCHAR2 --사용자ID
    ,P_TYPE             IN VARCHAR2 --작업구분
    ,P_INP_DT           IN VARCHAR2 --투입일자
    --,P_USE_FUNC         OUT VARCHAR2
    ,P_WDOC_NO          OUT VARCHAR2 --반납요청 문서번호
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
    ,CUR_1              OUT SYS_REFCURSOR
    ,CUR_2              OUT SYS_REFCURSOR
    ,CUR_3              OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK82_U01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 잔량처리
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 자재 잔량처리
 *                 
 * AUTHOR NAME   : 김병무{최초 작성자 명 기술}
 * CREATE DATE   : 2022/04/28 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/04/28    1.0.0   김병무         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_INV003] : (CRUD)자재투입 -자재관리 정보
 *=============================================================================*/

AS 
    --프로그램 ID
    V_PRG_NM			VARCHAR2(100)  := 'SP_POP_WRK82_U01';     -- PROCEDURE NAME
    V_PLT_CD			VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID		VARCHAR2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD		NUMBER(5) := 0;
    E_SQL_ERR_MSG		VARCHAR2(4000);
    --parameter변수 처리
    V_STCK_QTY			NUMBER(13,3) := TO_NUMBER(P_STCK_QTY);
    V_STCK_QTY_M		NUMBER(13,3); -- 전산재고
    --내부 변수 등록
    V_DATE				DATE := SYSDATE;
    V_TABLE				VARCHAR2(10);
    V_DOC_NO			VARCHAR2(20); --반납요청 문서번호
    V_DOC_SEQ			VARCHAR2(6);
    V_LOT_NO			VARCHAR2(10);
    V_UNIT				VARCHAR2(10);
    V_LOC_CD			VARCHAR2(4);
    V_LOC_NM			VARCHAR2(100);
    V_IF_LOC_CD			VARCHAR2(4); --WMS 저장위치
    V_STCK_TEMP			NUMBER(13,3);
    V_PRD_MATNR			VARCHAR2(20);
    V_PRD_BCD			VARCHAR2(20);
    V_PRD_LOT			VARCHAR2(10);
    V_PRD_SEQ			NUMBER;
    V_USE_CALC			NUMBER;
    V_IF_ID_USE			VARCHAR2(20); --자재소요량
    V_USE_DOC			VARCHAR2(30); --사용량 IF 문서번호
    V_INPUT_FLAG		VARCHAR2(1) := 'Y'; --투입 진행 여부
    V_SAP_WRK_CD		VARCHAR2(20); --SAP 작업장 코드
    V_MACHINE			VARCHAR2(10);
    V_STCK_KY			VARCHAR2(20);
    V_LOT_NUM			VARCHAR2(30);
    V_RCVCDS_DT         VARCHAR2(8); --입고일자
    V_DSTBT_DDLIN       VARCHAR2(14); --유통기한
    V_PRD_DT            VARCHAR2(10); --실적일자
    V_WDOC_NO           VARCHAR2(30); --자재출고문서번호
    V_WDOC_SEQNO        VARCHAR2(6); --자재출고문서번호
    V_SDOC_NO			VARCHAR2(10); --SAP확정문서
    V_SDOC_SEQNO		VARCHAR2(4); --SAP확정문서순번
    V_ORDER_NO			VARCHAR2(10); --생산오더번호
    V_MATNR_DIV         VARCHAR2(10);
    V_LOC_FLG			VARCHAR2(1);
    V_SQL 				VARCHAR2(4000);
    V_SEQ_INV999		NUMBER;
   
    V_DISTRIBUTE_YN         CMCDV.USE_YN%TYPE;     -- WMS 배포 확인
    V_CHK_QTY			NUMBER(13,3);
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
	    
        BEGIN
            --전산 재고 조회
            SELECT I003.STCK_QTY	--재고량
                INTO V_STCK_QTY_M
            FROM TB_INV003 I003 	--자재투입
            WHERE 1=1
                AND I003.MACH_CD = P_MACH_CD
                AND I003.WERKS = P_WERKS
                AND I003.MATNR = P_MATNR
                AND I003.WRK_ORDR_NO = P_WRK_ORDR_NO            -- 작업지시번호
                AND I003.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO      -- 작업지시순번
                AND I003.IND_BCD = P_IND_BCD;                   -- 업체/개별바코드

            --기존 투입이력 정보 조회
            BEGIN
                SELECT MATNR, LOT_NO, IND_BCD, SEQNO, SDOC_NO, SDOC_SEQNO
                    INTO V_PRD_MATNR, V_PRD_LOT, V_PRD_BCD, V_PRD_SEQ, V_SDOC_NO, V_SDOC_SEQNO
                FROM (SELECT MATNR, LOT_NO, IND_BCD, SEQNO + 1 AS SEQNO, SDOC_NO, SDOC_SEQNO
                      FROM TB_INV010
                      WHERE 1 = 1
                        AND ROWNUM >= 1
                        AND WERKS = P_WERKS
                        AND MACH_CD = P_MACH_CD
                        AND WRK_ORDR_NO = P_WRK_ORDR_NO
                        AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                        AND NVL(CNL_YN, 'N') = 'N'
                      ORDER BY IND_BCD DESC, SEQNO DESC)
                WHERE ROWNUM <= 1;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_INPUT_FLAG := 'N';
            END;

            -- 잔량처리시에 사용이력이 없으면 잔량을 태울 실적이 없으므로 잔량처리 못하게 RETURN
            IF P_TYPE = 'REMAIN' THEN
                IF V_INPUT_FLAG = 'N' THEN
                    RS_CODE := 'E';
	                RS_MSG := '해당 작업지시로 등록된 실적이 없으므로 잔량처리 불가합니다.';
                    RETURN;
                END IF;
            ELSIF P_TYPE = 'RETURN' THEN
                IF V_STCK_QTY_M != V_STCK_QTY and V_INPUT_FLAG = 'N' THEN
                    RS_CODE := 'E';
	                RS_MSG := '해당 작업지시로 등록된 실적이 없으므로 전체 재고만 반납 가능합니다.';
                    RETURN;
                end if;
            END IF;

	        --입고이력 조회
	        BEGIN
	        SELECT RCVCDS_DT, DSTBT_DDLIN, PRDC_DT, STOR_LOC_FR, STOR_LOC_TO
	          INTO V_RCVCDS_DT, V_DSTBT_DDLIN, V_PRD_DT, V_IF_LOC_CD, V_LOC_CD
	          FROM (SELECT RCVCDS_DT, DSTBT_DDLIN, PRDC_DT, STOR_LOC_FR, STOR_LOC_TO
			          FROM TB_INV007
			         WHERE 1=1
			           AND MATNR = P_MATNR
			           AND IND_BCD = P_IND_BCD
			           AND REQ_DIV IN ('10','40','50')
			         ORDER BY REGDATE DESC)
			 WHERE ROWNUM = 1;
	        EXCEPTION WHEN NO_DATA_FOUND THEN
	        	V_RCVCDS_DT := '';
	        	V_DSTBT_DDLIN := '';
	       		V_PRD_DT := '';
	      		V_IF_LOC_CD := '';
	     		V_LOC_CD := '';
	        END;
            --자재 마스터에 투입 저장위치 검색하여 사용필요
            -- LGFSB/외부입고저장위치
            -- LGPRO/투입저장위치
	        IF V_LOC_CD IS NULL THEN
	            SELECT LGPRO--, LGFSB
	              INTO V_LOC_CD--, V_IF_LOC_CD
	              FROM TB_MAS001
	             WHERE 1=1
	               AND WERKS = P_WERKS
	               AND MATNR = P_MATNR; 
            END IF;
            --설비정보 조회
            SELECT MACHINE, SAP_WRK_CD
              INTO V_MACHINE, V_SAP_WRK_CD
              FROM TB_MAS012
             WHERE 1=1
               AND MACH_CD = P_MACH_CD;
            --자재정보 조회
            SELECT LOT_NO, STCK_QTY, UNIT, STCK_KY, LOT_NUM
              INTO V_LOT_NO, V_STCK_TEMP, V_UNIT, V_STCK_KY, V_LOT_NUM
              FROM TB_INV003
             WHERE 1=1
               AND WERKS = P_WERKS
               --AND INP_DT = P_INP_DT
               AND MACH_CD = P_MACH_CD
               AND MATNR = P_MATNR
               AND IND_BCD = P_IND_BCD
               AND STCK_QTY <> 0
               AND ROWNUM = 1;

            IF P_WERKS = 'P200' AND (V_STCK_TEMP <> V_STCK_QTY)	THEN
--            IF (P_WERKS = 'P200' OR P_WERKS = 'P500') AND (V_STCK_TEMP <> V_STCK_QTY)	THEN
	            RS_CODE := 'E';
	            RS_MSG := '잔량처리 수량을 변경할 수 없습니다.';
	            RETURN;
            END IF;
            --잔량처리 -> inv001로 이동처리후 해당 row 삭제처리
            UPDATE TB_INV001
               SET STCK_QTY = STCK_QTY + V_STCK_QTY
                 , PLT_QTY = PLT_QTY + FN_CHG_UNIT(P_MATNR, P_WERKS, V_UNIT, 'PAL', V_STCK_QTY)
                 , BOX_QTY = BOX_QTY + FN_CHG_UNIT(P_MATNR, P_WERKS, V_UNIT, 'BOX', V_STCK_QTY)
                 , BAG_QTY = BAG_QTY + FN_CHG_UNIT(P_MATNR, P_WERKS, V_UNIT, 'BAG', V_STCK_QTY)
                 , EA_QTY = EA_QTY + FN_CHG_UNIT(P_MATNR, P_WERKS, V_UNIT, 'EA', V_STCK_QTY)
                 , ROLLCNT = ROLLCNT + FN_CHG_UNIT(P_MATNR, P_WERKS, V_UNIT, 'RL', V_STCK_QTY)
                 , WGT = WGT + FN_CHG_UNIT(P_MATNR, P_WERKS, V_UNIT, 'KG', V_STCK_QTY)
                 , STCK_STA = '00'
                 , WDOC_NO = V_WDOC_NO
                 , WDOC_SEQNO = V_WDOC_SEQNO
                 , UPDDATE = V_DATE
                 , UPDID = P_USER_ID
             WHERE 1=1
               AND WERKS = P_WERKS 
               AND MATNR = P_MATNR 
               AND STOR_LOC_CD = V_LOC_CD
               AND IND_BCD = P_IND_BCD;
            IF SQL%ROWCOUNT = 0 THEN
                INSERT INTO TB_INV001(WERKS, STOR_LOC_CD, IND_BCD, MATNR, LOT_NO, MACH_CD, MACHINE, UNIT,
                                        STCK_QTY, PLT_QTY, BOX_QTY, BAG_QTY, EA_QTY, ROLLCNT, WGT, STCK_STA, DLFL,
                                        REGDATE, REGID)
                                SELECT WERKS, V_LOC_CD, IND_BCD, MATNR, LOT_NO, P_MACH_CD, V_MACHINE, UNIT,
                                        V_STCK_QTY, 
                                        FN_CHG_UNIT(MATNR, WERKS, UNIT, 'PAL', V_STCK_QTY),
                                        FN_CHG_UNIT(MATNR, WERKS, UNIT, 'BOX', V_STCK_QTY),
                                        FN_CHG_UNIT(MATNR, WERKS, UNIT, 'BAG', V_STCK_QTY),
                                        FN_CHG_UNIT(MATNR, WERKS, UNIT, 'EA', V_STCK_QTY),
                                        FN_CHG_UNIT(MATNR, WERKS, UNIT, 'RL', V_STCK_QTY),
                                        FN_CHG_UNIT(MATNR, WERKS, UNIT, 'KG', V_STCK_QTY),
                                        '00', 'N', V_DATE, P_USER_ID
                                  FROM TB_INV003
                                 WHERE 1=1
                                   AND WERKS = P_WERKS
                                   AND MACH_CD = P_MACH_CD
                                   AND MATNR = P_MATNR
                                   AND IND_BCD = P_IND_BCD;
            END IF;

           -- TB_INV999  MaxSeq 확인
           SELECT	NVL(MAX(SEQNO), 0) + 1	INTO	V_SEQ_INV999
           FROM		TB_INV999
           WHERE	WERKS		= P_WERKS
           AND		MACH_CD		= P_MACH_CD
           AND		MATNR		= P_MATNR
           AND		IND_BCD		= P_IND_BCD
           AND		RTN_DT		= TO_CHAR(SYSDATE, 'yyyyMMdd');
           -- History 추가
           INSERT INTO TB_INV999	(WERKS, MACH_CD, MATNR, IND_BCD, RTN_DT, SEQNO,
           							STCK_QTY, RTN_QTY, LOT_NO, UNIT, REGDATE, REGID, ETC1)
           			VALUES 			(P_WERKS, P_MACH_CD, P_MATNR, P_IND_BCD, TO_CHAR(SYSDATE, 'yyyyMMdd'), V_SEQ_INV999,
           							V_STCK_TEMP, V_STCK_QTY, V_LOT_NO, V_UNIT, V_DATE, P_USER_ID, P_TYPE);

            SELECT STOR_LOC_NM 
              INTO V_LOC_NM
              FROM TB_MAS003
             WHERE 1=1
               AND WERKS = P_WERKS
               AND STOR_LOC_CD = V_LOC_CD;

            RS_MSG := V_LOC_NM || '(' || V_LOC_CD || ')';
--             --기존 투입이력 정보 조회
--             BEGIN
--             SELECT MATNR, LOT_NO, IND_BCD, SEQNO, SDOC_NO, SDOC_SEQNO
--               INTO V_PRD_MATNR, V_PRD_LOT, V_PRD_BCD, V_PRD_SEQ, V_SDOC_NO, V_SDOC_SEQNO
--               FROM (SELECT MATNR, LOT_NO, IND_BCD, SEQNO + 1 AS SEQNO, SDOC_NO, SDOC_SEQNO
--                       FROM TB_INV010
--                      WHERE 1=1
--                        AND ROWNUM >= 1
--                        AND WERKS = P_WERKS
--                        AND MACH_CD = P_MACH_CD
--                        AND WRK_ORDR_NO = P_WRK_ORDR_NO
--                        AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
--                        AND NVL(CNL_YN,'N') = 'N'
-- --                       AND MATNR_M = P_MATNR
-- --                       AND IND_BCD_M = P_IND_BCD
--                      ORDER BY IND_BCD DESC, SEQNO DESC)
--              WHERE ROWNUM <= 1;
--              EXCEPTION WHEN NO_DATA_FOUND THEN
--                 V_INPUT_FLAG := 'N';
--             END;

            IF V_INPUT_FLAG = 'Y' THEN
                --조정이력 추가
                V_USE_CALC := V_STCK_TEMP - V_STCK_QTY;
                dbms_output.put_line(V_STCK_QTY || '-' || V_STCK_TEMP);
                --수량이 동일한 경우 조정미등록
                IF V_USE_CALC != 0 THEN
                    INSERT INTO TB_INV010(WERKS, MACH_CD, MATNR, IND_BCD, SEQNO,
                                        WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO,
                                        IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, PRFM_DT, USE_QTY, UNIT,
                                        ROLLCNT, WGT, REGDATE, REGID, USE_DIV)
                                VALUES(P_WERKS, P_MACH_CD, V_PRD_MATNR, V_PRD_BCD, V_PRD_SEQ,
                                        P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO, V_PRD_LOT,
                                        P_IND_BCD, V_LOT_NO, P_MATNR, TO_CHAR(V_DATE,'YYYYMMDD'), FN_RECDATE(V_DATE), V_USE_CALC, V_UNIT,
                                        FN_CHG_UNIT(P_MATNR, P_WERKS, V_UNIT, 'RL', V_USE_CALC),
                                        FN_CHG_UNIT(P_MATNR, P_WERKS, V_UNIT, 'KG', V_USE_CALC),
                                        V_DATE, P_USER_ID, '2');
                END IF;
            END IF;
            --투입이력 삭제  
            DELETE TB_INV003
             WHERE 1=1
               AND WERKS = P_WERKS   
               AND WRK_ORDR_NO = P_WRK_ORDR_NO 
               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO 
               AND IND_BCD = P_IND_BCD;
               --AND INP_DT = P_INP_DT; 

            --반납 요청
            IF P_TYPE = 'RETURN' THEN
            	-- 자재출고이력 확인
            	IF V_RCVCDS_DT IS NULL THEN
            		ROLLBACK;
	                RS_CODE := 'E';
	                RS_MSG := '반납요청이 가능한 자재가 아닙니다.\n출고된 이력을 찾을 수 없습니다.';
	                RETURN;
            	END IF;
            	--불출요청 가능여부 검색
                SELECT MATNR_DIV, DECODE(NVL(LGPRO,'9999'),NVL(LGFSB,'9999'),'E','S')
                  INTO V_MATNR_DIV, V_LOC_FLG
                  FROM TB_MAS001
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MATNR = P_MATNR;
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

				-- 불출수량보다 반납수량이 많을 경우 반납요청 불가
--				BEGIN
--					SELECT	QTY	INTO	V_CHK_QTY
--					FROM	TB_INV007
--					WHERE	MATNR = P_MATNR
--					AND 	IND_BCD  = P_IND_BCD
--					AND		DLFL = 'A'
--					AND		ROWNUM = 1;
--				END;
--				IF V_STCK_QTY > V_CHK_QTY THEN
--                    ROLLBACK;
--                    RS_CODE := 'E';
--                    RS_MSG := '요청항목중 반납요청 수량이 불출수량보다 큰 항목이 존재합니다.\n목록을 확인후 반납을 요청하여 주시기 바랍니다.';
--                    RETURN;
--				END IF;

			--문서번호 작성
                V_DOC_NO := FN_GET_MDOCNO('M','IF400');
                V_DOC_SEQ := '1';
                P_WDOC_NO := V_DOC_NO;
 
                --불출요청 테이블에 추가
                INSERT INTO TB_INV002 (DOC_NO, DOC_SEQ, DLFL, REQ_DIV, WERKS, MATNR, QTY, UNIT, IF_STA, REGDATE, REGID)
                               VALUES (V_DOC_NO, V_DOC_SEQ, 'C', '20', P_WERKS, P_MATNR, V_STCK_QTY, V_UNIT, 'N', V_DATE, P_USER_ID); 
                
                --I/F 전송
                INSERT INTO TB_IFSWM004(DOC_NO, DOC_SEQNO, DLFL, WERKS, LOTA04,
                                            MATNR, QTY, UNIT, STOR_LOC_FROM, STOR_LOC_TO , STCK_STA,
                                            IND_BCD, LOT_NO, STOK_KY, LOT_NUM,
                                            RCVGDS_DT, DSTBT_DDLIN, PRDC_DT, RTN_DT, IF_GET_DATE)
                                    VALUES(V_DOC_NO, V_DOC_SEQ, 'C', P_WERKS, V_MACHINE,
                                            P_MATNR, V_STCK_QTY, V_UNIT, V_LOC_CD, V_IF_LOC_CD, '00', 
                                            P_IND_BCD, V_LOT_NO, V_STCK_KY, V_LOT_NUM,
                                            V_RCVCDS_DT, V_DSTBT_DDLIN, V_PRD_DT, TO_CHAR(V_DATE,'YYYYMMDD'), V_DATE);

				-- 반납요청인 경우 공정재고 테이블(TB_INV001)의 상태를 '00'이 아닌 '90'(반납요청) 으로 변경처리
				UPDATE	TB_INV001
					SET	STCK_STA = '90'
				WHERE	1=1
				AND WERKS = P_WERKS 
				AND MATNR = P_MATNR 
				AND STOR_LOC_CD = V_LOC_CD
				AND IND_BCD = P_IND_BCD;
            END IF;

            --자재 반납요청
            PKG_WRK055.LOG_IF('SP_POP_WRK82_U01', P_WERKS, 'MES_IF_400', V_DOC_NO, P_USER_ID);   -- WRK55 RFC 전송로그
            V_SQL := FN_IF_QUERY('MES_IF_400', V_DOC_NO);
            IF V_SQL IS NOT NULL THEN
            	OPEN CUR_1 FOR V_SQL;
            ELSE
            	OPEN CUR_1 FOR SELECT 1 FROM dual;
        	END IF;

            --작업 정상 종료 코드 등록
            RS_CODE := 'S';
            --P_WDOC_NO := V_DOC_NO;
        END;
    --예외처리(catch)
--    EXCEPTION
--    WHEN E_EXCEPTION_USER THEN
--        -- 에러 내역 SET
--        E_SQL_ERR_CD        := SQLCODE;
--        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);
--
--        ROLLBACK;
--        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--
--        RS_CODE := 'E';
--        RS_MSG  := SQLERRM;
--        RETURN;
--    WHEN OTHERS THEN
--        E_SQL_ERR_CD        := -20001;
--        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--        ROLLBACK;
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
--
--        RS_CODE := 'E';
--        RS_MSG  := SQLERRM;
--        RETURN;
    --예외처리 종료
    END;
END SP_POP_WRK82_U01;
/
