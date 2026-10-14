
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_AUTO_RCV_WRK_PRFM" 
(
    P_WERKS             IN VARCHAR2
    ,P_MACH_CD          IN VARCHAR2
    ,P_USERID           IN VARCHAR2
    ,P_ORDER_NO         IN VARCHAR2
    ,P_WRK_ORDR_NO      IN VARCHAR2
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2
    ,P_MATNR            IN VARCHAR2
    ,P_PRFM_QTY         IN VARCHAR2
    ,P_IND_BCD          IN VARCHAR2
    ,P_LOT_NO           IN VARCHAR2
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2
    ,RS_MSG             OUT VARCHAR2
    ,P_PRFM_FUNC		OUT	VARCHAR2
    ,P_USE_FUNC			OUT	VARCHAR2
    ,P_WDOC_NO			OUT	VARCHAR2
    ,P_MATNR_NM			OUT	VARCHAR2        /* 자재명 wcs 호출시 사용위함 */
    ,P_UNIT			    OUT	VARCHAR2        /* 자재명 wcs 호출시 사용위함 */
    ,P_CUR_1			OUT	SYS_REFCURSOR
)

/*==============================================================================
 * PROGRAM ID    : SP_AUTO_RCV_WRK_PRFM{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 오토라벨러 화장지 가공 실적 등록 {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 오토라벨러에서 실적정보를 수신하여 실적등록을 처리한다.{프로그램에 대한 상세한 내용 기술}
 *
 * AUTHOR NAME   : 백우종{최초 작성자 명 기술}
 * CREATE DATE   : {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   백우종         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_MAS001] : (.R..) 화장지 합지기 생산오더
 * - [TB_SCH012] : (.R..) 화장지 합지기 작업지시
 *=============================================================================*/

AS
    --프로그램 ID
    V_PRG_NM			VARCHAR2(100)  := 'SP_AUTO_RCV_WRK_PRFM';     -- PROCEDURE NAME
    V_PLT_CD			VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID		VARCHAR2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD		NUMBER(5) := 0;
    E_SQL_ERR_MSG		VARCHAR2(4000);
    --parameter변수 처리
    V_WRK_ORDR_SEQNO    NUMBER(5,0) := TO_NUMBER(P_WRK_ORDR_SEQNO);
    V_PRFM_QTY          NUMBER := TO_NUMBER(P_PRFM_QTY);
    --내부 변수 등록
    V_DATE              DATE := SYSDATE;
    V_MACH_STA          TB_WRK011.MACH_STA%TYPE; --설비상태 정보
    V_WRK_STA           VARCHAR2(1); --작업지시 상태정보
    V_MAT_STA			VARCHAR2(1); --생산버전 여부
    V_ENDFLG            VARCHAR2(1); --생산완료 여부
    V_BOMCNT            NUMBER;--사용자재목록
    V_YMCHK             TB_MAS011.YMCHK%TYPE;
    V_PRFM_DT           VARCHAR2(8) := REPLACE(FN_RECDATE(V_DATE),'-',''); --실적일자
    V_PRD_DT            VARCHAR(8) := TO_CHAR(V_DATE,'YYYYMMDD'); --등록일자
    V_ORDER_SEQNO       VARCHAR2(5);
    V_WRK_CLASS         VARCHAR2(10); --작업반
    V_WRK_SHIFT         VARCHAR2(10); --작업조
    V_LOT_TEMP          VARCHAR2(15); --LOT NO 조회
    V_UNIT              VARCHAR2(10); --실적단위
    V_CAP_RATE          NUMBER(13,3); --초과허용비율
    V_ORDR_QTY          NUMBER(13,3); --지시수량
    V_PRFM_SUM          NUMBER(13,3); --실적누적수량
    V_REG_QTY           NUMBER(13,1); --기준단위 실적수량(실적 등록수량)
    V_PLT_QTY           NUMBER(13,1); --PLT수량
    V_BOX_QTY           NUMBER(13,0); --BOX수량
    V_BAG_QTY           NUMBER(13,0); --BAG수량
    V_EA_QTY            NUMBER(13,0); --EA수량
    V_WGT               NUMBER(13,0); --KG중량
    V_ROLLCNT           NUMBER(13,0); --M길이
    V_MATNR_NM          VARCHAR2(1000); --자재명
    V_PART_DIV			VARCHAR2(10); --제품종류
    V_KAN_CD            VARCHAR2(18); --KAN코드
    V_MACH_NM           VARCHAR2(100); --설비명
    V_DSTBT_DDLIN       VARCHAR(10); --유통기간 일자
    V_DSTBT_DAYS        NUMBER(4); --유통기간
    V_MACHINE           VARCHAR2(5); --설비호기
    V_LOC_CD            VARCHAR2(4); --저장위치
    V_PRD_STR_DATE      DATE; --작업지시 시작시간
    V_WRK_STR_DATE      DATE; --실적 시작시간
    V_RUNTIME           NUMBER; --가동시간
    V_ERR_LIST          VARCHAR2(4000); --수량 부족항목목록
    V_IF_ID_USE         VARCHAR2(20) := 'MES_IF_130'; --자재소요량
    V_DOC_NO            VARCHAR2(29); --MES문서번호
    V_SQL               VARCHAR2(4000);

   	-- SAP, WMS I/F 요청 프로시져 호출 변수
    V_LIST				VARCHAR2(4000);	-- 입고요청 변수
    V_PRFM_FUNC			VARCHAR2(100);
    V_USE_FUNC			VARCHAR2(100);
    V_SDOC_NO			VARCHAR2(100);
    V_PROC_CD			VARCHAR2(10);
    RS_CODE_REQUEST		VARCHAR2(10);
    RS_MSG_REQUEST		VARCHAR2(1000);
    CUR_1				SYS_REFCURSOR;

BEGIN
	BEGIN
		BEGIN
        SZP_MES_PLSQL_LOG('-------------- START ---------------', V_PRG_NM);
        SZP_MES_PLSQL_LOG('입력 파라미터: WERKS='||P_WERKS||', MACH_CD='||P_MACH_CD||', USERID='||P_USERID
                          ||', WRK_ORDR_NO='||P_WRK_ORDR_NO||', SEQNO='||P_WRK_ORDR_SEQNO
                          ||', MATNR='||P_MATNR||', LOT='||P_LOT_NO, V_PRG_NM);

			-- 1. 지시정보 조회
			SELECT ORDER_SEQNO, USE_YN, ORDER_QTY
				INTO V_ORDER_SEQNO, V_WRK_STA, V_ORDR_QTY
			FROM TB_SCH012
			WHERE 1=1
			AND WRK_ORDR_NO = P_WRK_ORDR_NO
			AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;
            SZP_MES_PLSQL_LOG('지시정보 조회 완료: ORDER_SEQNO='||V_ORDER_SEQNO||', ORDER_QTY='||V_ORDR_QTY, V_PRG_NM);

			-- 2. 자재정보 조회
			SELECT MATNR_NM, KAN_NO, NVL(DSTBT_DDLIN,0), UNIT, LGPRO, PART_DIV
				INTO V_MATNR_NM, V_KAN_CD, V_DSTBT_DAYS, V_UNIT, V_LOC_CD, V_PART_DIV
			FROM TB_MAS001
			WHERE 1=1
			AND WERKS = P_WERKS
			AND MATNR = P_MATNR;

			-- 3. 설비 정보 조회
			SELECT MACH_NM, MACHINE
				INTO V_MACH_NM, V_MACHINE
			FROM TB_MAS012
			WHERE 1=1
			AND MACH_CD = P_MACH_CD;

			-- 4. 작업반,조 정보조회
			SELECT WRK_CLASS, WRK_SHIFT
				INTO V_WRK_CLASS, V_WRK_SHIFT
			FROM TB_WRK011
			WHERE 1=1
			AND WERKS = P_WERKS
			AND MACH_CD = P_MACH_CD
			AND IN_OUT = 'O';

			-- 5. 가공기조회
			SELECT TO_DATE(PRD_STR_DTM, 'YYYYMMDDHH24MISS'), MACH_STA
				INTO V_PRD_STR_DATE, V_MACH_STA
			FROM TB_WRK011
			WHERE 1=1
			AND WERKS = P_WERKS
			AND MACH_CD = P_MACH_CD
			AND IN_OUT != 'O';

			-- 6. 현재 실적수량 조회
			SELECT NVL(SUM(PRFM_QTY),0)
				INTO V_PRFM_SUM
			FROM TB_WRK001
			WHERE 1=1
			AND WERKS = P_WERKS
			AND WRK_ORDR_NO = P_WRK_ORDR_NO
			AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
			AND PRFM_GTHR_YN = 'Y';

			IF V_MACH_STA = 'S' THEN --설비 비가동시
            	RS_CODE := 'E3';
                RS_MSG := '가공기 설비가 비가동 중입니다.\n설비를 가동후 실적을 등록하여 주시기 바랍니다.';
                RETURN;
            END IF;

			-- 7. 생산오더 BOM 확인
			SELECT COUNT(*)
				INTO V_BOMCNT
			FROM TB_SCH020
			WHERE 1=1
                AND WERKS = P_WERKS
                AND WRK_ORDR_NO = P_WRK_ORDR_NO
                AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;

			IF V_BOMCNT = 0 THEN
				RS_CODE := 'E3';
				RS_MSG := '생산오더 BOM이 존재하지 않습니다.\n생산팀에 문의 해 주시기 바랍니다.';
				RETURN;
			END IF;

			-- 8. 저장위치여부 확인
			IF V_LOC_CD IS NULL THEN
				RS_CODE := 'E3';
				RS_MSG := '제품의 저장위치가 설정되지 않았습니다.\n생산팀에 문의 해 주시기 바랍니다.';
				RETURN;
			END IF;

			-- 9. 지시 가용여부 확인
			IF NVL(V_WRK_STA,'Y') = 'N' THEN
				RS_CODE := 'E3';
				RS_MSG := '삭제 처리된 작업지시입니다.\n생산팀에 문의 해 주시기 바랍니다.';
				RETURN;
			END IF;

			-- 10. 생산버전 확인
			BEGIN
				SELECT USE_YN INTO V_MAT_STA
				FROM TB_MAS007
				WHERE WERKS = P_WERKS
				AND PRCMC = V_MACHINE
				AND MATNR = P_MATNR;

				EXCEPTION	WHEN NO_DATA_FOUND THEN
					V_MAT_STA := 'N';
			END;

			IF V_MAT_STA = 'N' THEN
				RS_CODE := 'E3';
				RS_MSG := '제품의 생산버전이 존재하지 않습니다.\n생산팀에 문의 해 주시기 바랍니다.';
				ROLLBACK;
				RETURN;
			END IF;

			BEGIN
			SELECT YMCHK INTO  V_YMCHK
			FROM TB_MAS011
			WHERE WERKS = P_WERKS
			AND YYMM = SUBSTR(V_PRFM_DT, 0, 6)
			AND USE_YN = 'Y';

				EXCEPTION	WHEN NO_DATA_FOUND THEN
					V_YMCHK := 'N';
			END;

			IF V_YMCHK = 'N' THEN
				RS_CODE := 'E3';
				RS_MSG := '실적등록 가능한 월이 아닙니다.';
				ROLLBACK;
				RETURN;
			END IF;

			--실적 제한수량 확인
			V_REG_QTY := FN_CHG_UNIT(P_MATNR, P_WERKS, 'BOX', V_UNIT, V_PRFM_QTY);

			BEGIN
				SELECT USARG1
					INTO V_CAP_RATE
				FROM CMCDV
				WHERE 1=1
				AND CMCDKY = 'PRFMCAP'
				AND CMCDVL = 'RA'
				AND USE_YN = 'Y';

				EXCEPTION WHEN NO_DATA_FOUND THEN
					V_CAP_RATE := -1;
			END;

			IF V_CAP_RATE >= 0 THEN
				--제한수량 초과여부 확인
				V_ORDR_QTY := V_ORDR_QTY + V_ORDR_QTY * (V_CAP_RATE/100);
				V_PRFM_SUM := V_PRFM_SUM + V_REG_QTY;
				IF V_ORDR_QTY < V_PRFM_SUM THEN
					RS_CODE := 'E3';
					IF V_CAP_RATE = 0 THEN
						RS_MSG := '실적수량이 계획수량을 초과하여 등록이 불가능합니다.';
					ELSE
						RS_MSG := '계획대비 실적수량이 ' || V_CAP_RATE || '%이상 초과하여 등록이 불가능합니다.';
					END IF;
					RETURN;
				END IF;
			END IF;

            --품질관리용 테이블 등록
            UPDATE TB_WRK501
				SET LOT_NO = P_LOT_NO
                 , WRK_ORDR_NO = P_WRK_ORDR_NO
                 , WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                 , MATNR = P_MATNR
                 , UPDDATE = V_DATE
                 , UPDID = P_USERID
            WHERE 1=1
                AND WERKS = P_WERKS
                AND MACH_CD = P_MACH_CD;

			IF SQL%ROWCOUNT = 0 THEN
                INSERT INTO TB_WRK501 (LOT_NO, WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO, REGDATE, REGID, MATNR)
                                VALUES(P_LOT_NO, P_WERKS, P_MACH_CD, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_DATE, P_USERID, P_MATNR);
            END IF;

            --작업장 현황 LOT 정보 변경
            UPDATE TB_WRK011
				SET LOT_NO = P_LOT_NO
                 , UPDDATE = V_DATE
                 , UPDID = P_USERID
			WHERE 1=1
			AND WERKS = P_WERKS
			AND MACH_CD = P_MACH_CD;

            --작업시간 확인
            BEGIN
	            --등록된 마지막 실적 조회
	            SELECT NVL(MAX(REGDATE),V_PRD_STR_DATE) INTO V_WRK_STR_DATE
	            FROM TB_WRK001
	            WHERE 1=1
	            AND WERKS = P_WERKS
	            AND MACH_CD = P_MACH_CD
	            AND WRK_ORDR_NO = P_WRK_ORDR_NO
	            AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;

	            EXCEPTION WHEN NO_DATA_FOUND THEN
	                --이전 실적이  없는 경우 지시 시작시간 적용
	                V_WRK_STR_DATE := V_PRD_STR_DATE;
			END;

            --기준 단위 및 단위변환 등록
            V_PLT_QTY := FN_CHG_UNIT(P_MATNR, P_WERKS, 'BOX', 'PAL', V_PRFM_QTY);
            V_BOX_QTY := FN_CHG_UNIT(P_MATNR, P_WERKS, 'BOX', 'BOX', V_PRFM_QTY);
            V_BAG_QTY := FN_CHG_UNIT(P_MATNR, P_WERKS, 'BOX', 'BAG', V_PRFM_QTY);
            V_EA_QTY := FN_CHG_UNIT(P_MATNR, P_WERKS, 'BOX', 'EA', V_PRFM_QTY);
            V_WGT := FN_CHG_UNIT(P_MATNR, P_WERKS, 'BOX', 'KG', V_PRFM_QTY);
            V_ROLLCNT := FN_CHG_UNIT(P_MATNR, P_WERKS, 'BOX', 'M', V_PRFM_QTY);

            --가동시간 확인
            SELECT TRUNC((TO_DATE(TO_CHAR(V_DATE,'YYYY-MM-DD HH24:MI'), 'YYYY-MM-DD HH24:MI:SS') - TO_DATE(TO_CHAR(V_WRK_STR_DATE, 'YYYY-MM-DD HH24:MI'), 'YYYY-MM-DD HH24:MI:SS'))*1440)
				INTO V_RUNTIME
			FROM DUAL;
            --유통기간 확인
            IF V_DSTBT_DAYS = 0 THEN
                V_DSTBT_DDLIN := '';
            ELSE
                V_DSTBT_DDLIN := TO_CHAR(TO_DATE(V_PRFM_DT,'YYYYMMDD') + V_DSTBT_DAYS,'YYYYMMDD');
            END IF;
            --HL 생산실적 등록
            INSERT INTO TB_WRK001 (WERKS, MACH_CD, IND_BCD, LOT_NO, MATNR,
                                    ORDER_NO, ORDER_SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                    PRFM_QTY, UNIT, PLT_QTY, BOX_QTY, BAG_QTY, EA_QTY, WGT, ROLLCNT, TM, STA,
                                    PRFM_DT, PRD_DT, DSTBT_DDLIN, WRK_CLASS, WRK_SHIFT,
                                    PRD_STR_DATE, PRD_END_DATE,
                                    COMP_YN, CHK_PP_YN, REGDATE, REGID, PRFM_TYPE)
                           VALUES(P_WERKS, P_MACH_CD, P_IND_BCD, P_LOT_NO, P_MATNR,
                                    P_ORDER_NO, V_ORDER_SEQNO, P_WRK_ORDR_NO,P_WRK_ORDR_SEQNO,
                                    V_REG_QTY, V_UNIT, V_PLT_QTY, V_BOX_QTY, V_BAG_QTY, V_EA_QTY, V_WGT, V_ROLLCNT, V_RUNTIME, '00',
                                    V_PRFM_DT, V_PRD_DT, V_DSTBT_DDLIN, V_WRK_CLASS, V_WRK_SHIFT,
                                    V_WRK_STR_DATE, V_DATE,
                                    'N', 'N', V_DATE, P_USERID, 'AUTO');

            --실적수량 재고등록
            INSERT INTO TB_INV001 (WERKS, STOR_LOC_CD,
                                    MATNR, LOT_NO, IND_BCD, UNIT, MACH_CD, MACHINE,
                                    WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO,
                                    PRD_DT, PRFM_DT, STCK_QTY, PLT_QTY, BOX_QTY, BAG_QTY, EA_QTY, WGT, ROLLCNT, STCK_STA,
                                    DLFL, REGDATE, REGID)
                            VALUES(P_WERKS, V_LOC_CD,
                                    P_MATNR, P_LOT_NO, P_IND_BCD, V_UNIT, P_MACH_CD, V_MACHINE,
                                    P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO, P_ORDER_NO,
                                    V_PRFM_DT, V_PRFM_DT, V_REG_QTY, V_PLT_QTY, V_BOX_QTY, V_BAG_QTY, V_EA_QTY, V_WGT, V_ROLLCNT, '00',
                                    'N', V_DATE, P_USERID);

            --생산수량정보 작업지시에 저장(제품의 기준단위수량으로 저장)
            UPDATE TB_SCH012
				SET PRFM_QTY = NVL(PRFM_QTY,0) + NVL(V_REG_QTY,0)
                 , PRD_LAST_DATE = V_DATE
                 , PRD_END_DTM =  ''
                 , PRD_END_DT = ''
                 , UPDDATE = V_DATE
                 , UPDID = P_USERID
			WHERE 1=1
			AND WRK_ORDR_NO = P_WRK_ORDR_NO
			AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;

            --작업자 현황 정보추가
            UPDATE TB_WRK013
				SET PRFM_DT = V_PRFM_DT
			WHERE 1=1
			AND WERKS = P_WERKS
			AND MACH_CD = P_MACH_CD
			AND IN_OUT = 'O'
			AND END_DATE IS NULL;

			--가용수량 확인
            SP_REG_LOT_LOG_S01 (P_WERKS, P_MACH_CD, P_MATNR, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_REG_QTY, 1, V_ERR_LIST);

            IF LENGTH(V_ERR_LIST) > 0 THEN
                ROLLBACK;
                RS_CODE := 'E3';
                RS_MSG  := V_ERR_LIST;
                RETURN;
            END IF;

            --LOT추적정보 등록
            --자재 소요량 SAP전송 문서번호 반환
            SP_REG_LOT_LOG_I01 (P_WERKS, P_MACH_CD, P_MATNR, P_LOT_NO, P_IND_BCD, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_PRFM_DT, V_REG_QTY, V_UNIT, 'N', 1, P_USERID, RS_CODE, RS_MSG);

            IF RS_CODE = 'E' THEN
                ROLLBACK;
                RS_CODE := 'E3';
                RS_MSG  := RS_MSG;
                RETURN;
            END IF;


            -- SAP, WMS I/F Table Data Insert
            V_PROC_CD := 'POP_WRK20';
			V_LIST:= '{''PROC_CD'': ''' || V_PROC_CD || '''' || ', ''list'': [{''map'' : {''WERKS'': ''' || P_WERKS || '''' || ', ''MACH_CD'' : ''' || P_MACH_CD || '''' || ', ''PROC_CD'': ''' || V_PROC_CD || '''' || ', ''MATNR'' : ''' || P_MATNR || '''' || ', ''IND_BCD'' : ''' || P_IND_BCD || '''' || ', ''LOT_NO'' : ''' || P_LOT_NO || '''' || ', ''PRFM_QTY'' : ''' || V_REG_QTY || '''' || ', ''UNIT'' : ''' || V_UNIT || '''' || ', ''PRFM_DT'' : ''' || V_PRFM_DT || '''}}]}';

            SZP_MES_PLSQL_LOG('SAP/WMS I/F 호출 시작, V_LIST='||SUBSTR(V_LIST,1,1000), V_PRG_NM);
            SP_AUTO_RCV_STEP2 (P_WERKS, 'RA', V_LIST, P_USERID, 'KO', RS_CODE_REQUEST, RS_MSG_REQUEST, V_PRFM_FUNC, V_USE_FUNC, V_SDOC_NO, CUR_1);

           	RS_MSG := 'V_PRFM_FUNC : ' || V_PRFM_FUNC || ', V_USE_FUNC : ' || V_USE_FUNC || ', V_SDOC_NO : ' || V_SDOC_NO;
			IF RS_CODE_REQUEST <> 'S'	THEN
				RS_CODE := RS_CODE_REQUEST;
				RS_MSG := RS_MSG_REQUEST;
				SZP_MES_PLSQL_LOG('SAP/WMS I/F 실패: '||RS_MSG, V_PRG_NM);
				RAISE E_EXCEPTION_USER;
			END IF;
            --작업 정상 종료 코드 등록
		    P_PRFM_FUNC := V_PRFM_FUNC;
		    P_USE_FUNC	:= V_USE_FUNC;
		    P_WDOC_NO	:= V_SDOC_NO;
		    P_CUR_1		:= CUR_1;

			RS_CODE := RS_CODE_REQUEST;
			RS_MSG := RS_MSG_REQUEST;
			P_MATNR_NM := V_MATNR_NM;
			P_UNIT := V_UNIT;
		END;

        SZP_MES_PLSQL_LOG('정상 종료, DOC_NO='||P_WDOC_NO, V_PRG_NM);
        SZP_MES_PLSQL_LOG('-------------- END ---------------', V_PRG_NM);
	    --예외처리(catch)
	    EXCEPTION
	    WHEN E_EXCEPTION_USER THEN
			-- 에러 내역 SET
			E_SQL_ERR_CD        := SQLCODE;
			E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

            RS_CODE := 'E';
			RS_MSG := 'EXCEPTION 발생';

-- 			ROLLBACK;
			SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
            INSERT INTO PROC_LOG(SQL_STR, SQL_PARAM1) VALUES ('사용자 예외 발생: ' || E_SQL_ERR_MSG, V_PRG_NM);
			RETURN;
		WHEN OTHERS THEN
			E_SQL_ERR_CD        := SQLCODE;
			E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

			            RS_CODE := 'E';
			RS_MSG := 'EXCEPTION 발생';
-- 			ROLLBACK;
			INSERT INTO PROC_LOG(SQL_STR, SQL_PARAM1) VALUES ('시스템 예외 발생: ' || E_SQL_ERR_MSG, V_PRG_NM);
			RAISE_APPLICATION_ERROR(-20001, E_SQL_ERR_MSG);

			RETURN;
	    --예외처리 종료
	END;
END SP_AUTO_RCV_WRK_PRFM;
/
