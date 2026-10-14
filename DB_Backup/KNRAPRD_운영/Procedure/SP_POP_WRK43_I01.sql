--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK43_I01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK43_I01" 
(
    P_WERKS             IN VARCHAR2         --플랜트
    ,P_MACH_CD          IN VARCHAR2         --작업장코드(설비코드)
    ,P_DISPO_CD         IN VARCHAR2         --폐품코드
    ,P_UNIT             IN VARCHAR2         --실적단위
    ,P_WIDTH            IN NUMBER           --폐품지폭
    ,P_ROLLCNT          IN NUMBER           --폐품권치수
    ,P_DISPO_QTY        IN NUMBER           --폐품중량
    ,P_SPEED            IN NUMBER           --선속
    ,P_PRD_STR_DATE     IN VARCHAR2         --생산시작 일시(YYYYMMDDHH24MISS)
    ,P_PRD_END_DATE     IN VARCHAR2         --생산 종료 일시(YYYYMMDDHH24MISS)
    ,P_TM               IN VARCHAR2         --생산시간(분)
    ,P_PRFM_DT          IN VARCHAR2         --생산실적일자
    ,P_RMK              IN VARCHAR2         --비고
    ,P_USER_ID          IN VARCHAR2 --사용자ID
    ,P_USE_FUNC         OUT VARCHAR2
    ,P_PRFM_FUNC        OUT VARCHAR2 
    ,P_DISPO_FUNC       OUT VARCHAR2 
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
    ,CUR_3          OUT SYS_REFCURSOR
    ,CUR_4          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK36_I01
 * PROGRAM NAME  : 합지기 폐품실적 등록
 * VERSION       : 1.0.0
 * DESCRIPTION   : 
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/06/19
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/02    1.0.0   김병무         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK004] : (C...) 폐품실적
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK43_I01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리

    V_PRD_STR_DATE DATE := TO_DATE(P_PRD_STR_DATE, 'YYYYMMDDHH24MISS');
    V_PRD_END_DATE DATE := TO_DATE(P_PRD_END_DATE, 'YYYYMMDDHH24MISS');

    --내부 변수 등록
    V_WRK_ORDR_NO           TB_WRK011.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO        TB_WRK011.WRK_ORDR_SEQNO%TYPE;
    V_ORDER_NO              TB_WRK011.ORDER_NO%TYPE;
    V_ORDER_SEQNO           TB_SCH011.ORDER_NO%TYPE;
    V_LOT_NO                TB_WRK011.LOT_NO%TYPE;    
    V_MATNR                 TB_WRK011.MATNR%TYPE;    
    V_DOC_NO_PRFM           TB_WRK004.DOC_NO%TYPE;
    V_DOC_NO_DISPO          TB_WRK004.DOC_NO%TYPE;
    V_DOC_SEQNO             TB_WRK004.DOC_SEQNO%TYPE;
    V_DISPO_NM              TB_MAS023.DISPO_NM%TYPE;
    V_WRK_CLASS             TB_WRK002.WRK_CLASS%TYPE;
    V_WRK_SHIFT             TB_WRK002.WRK_SHIFT%TYPE;
    V_SDATE                 VARCHAR2(10);
    V_STIME                 VARCHAR2(8);
    V_EDATE                 VARCHAR2(10);
    V_ETIME                 VARCHAR2(8);
    V_DATE                  DATE := SYSDATE;
    V_MACHINE               TB_WRK004.MACHINE%TYPE;
    V_WRK_SEQ               TB_WRK002.WRK_SEQ%TYPE;
    V_PRD_DT                TB_WRK002.PRD_DT%TYPE;
    V_IND_BCD               VARCHAR2(20);
    V_UNIT                  TB_MAS001.UNIT%TYPE;
    V_SAP_WRK_CD            TB_MAS012.SAP_WRK_CD%TYPE;          --실적전송 시 SAP 작업장
    V_WTYPE_FLAG            NUMBER(5);
    V_DISPO_MATNR           TB_WRK004.MMATNR%TYPE;    
    V_DISPO_LOT             TB_WRK004.LOT_NO_M%TYPE;  
    V_DISPO_BCD             TB_WRK004.IND_BCD_M%TYPE;  
    V_RUN_TM                TB_WRK004.TM%TYPE;   --가동 시간
    V_ROLLCNT               TB_WRK004.ROLLCNT%TYPE;   --권치수(길이)
    V_WGT                   TB_WRK004.WGT%TYPE;   --중량
    V_DOC_USE               TB_IFS008.MDOCNO%TYPE; --자재소요량 등록문서
    V_ERR_LIST              VARCHAR2(4000); --수량 부족항목목록
    V_IF_ID_USE             VARCHAR2(20) := 'MES_IF_130'; --자재소요량
    V_IF_ID_PRFM            VARCHAR2(20) := 'MES_IF_123'; --MES IF ID 실적등록 합지기
    V_IF_ID_DISPO           VARCHAR2(20) := 'MES_IF_134'; --폐품등록
    V_SQL                   VARCHAR2(4000);
    V_PUPOS                 VARCHAR2(1); --용도
    V_DISPO900_CHK          NUMBER(5);
BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            --현재 작업지시정보 조회
            SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, MATNR, WRK_CLASS, WRK_SHIFT, LOT_NO
              INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, V_MATNR, V_WRK_CLASS, V_WRK_SHIFT, V_LOT_NO
              FROM TB_WRK011
             WHERE WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD;
            --작업 설비정보 조회
            SELECT SAP_WRK_CD, MACHINE
                INTO V_SAP_WRK_CD, V_MACHINE
              FROM TB_MAS012
             WHERE MACH_CD = P_MACH_CD;   
            --제품 단위정보 조회
            SELECT UNIT
                INTO V_UNIT
              FROM TB_MAS001
             WHERE WERKS = P_WERKS
               AND MATNR = V_MATNR; 
            --지시정보 조회
            SELECT ORDER_SEQNO, PUPOS
              INTO V_ORDER_SEQNO, V_PUPOS
              FROM TB_SCH011
             WHERE 1=1
               AND WRK_ORDR_NO = V_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
              
			-- DISPO_CD = 900(영업폐품)이고 오더별 1번만 등록될 수 있도록 밸리데이션 221124 이성민
	        SELECT COUNT(*)
	          INTO V_DISPO900_CHK
	          FROM TB_WRK004 
	        WHERE  WRK_ORDR_NO = V_WRK_ORDR_NO
	          AND  WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
	          AND  DISPO_CD       = '900'
	          AND  NVL(CNL_YN, 'N') = 'N' 
	        ;
	       
	        IF V_DISPO900_CHK > 0 AND P_DISPO_CD = '900' THEN 
	     	   RS_CODE := 'E';
	           RS_MSG  := '영업폐품은 작업지시별 1번만 등록 가능합니다';
	           RETURN;
	        END IF
	        ; 
	       
            V_WRK_SEQ := NVL(V_WRK_SEQ, 0) + 1;

            V_PRD_DT := TO_CHAR(V_DATE, 'YYYYMMDD');
            --I/F 문서번호
            V_DOC_NO_PRFM := FN_GET_MDOCNO('M','IF123');
            V_DOC_SEQNO := 1;

             --개별바코드
            SP_GET_BARCODE_SEQ('IND', P_WERKS, P_MACH_CD, V_MATNR, P_PRD_STR_DATE, V_IND_BCD);

            V_SDATE := TO_CHAR(TO_DATE(P_PRD_STR_DATE, 'YYYYMMDDHH24MISS'), 'YYYYMMDD');
            V_STIME := TO_CHAR(TO_DATE(P_PRD_STR_DATE, 'YYYYMMDDHH24MISS'), 'HH24MISS');
            V_EDATE := TO_CHAR(TO_DATE(P_PRD_END_DATE, 'YYYYMMDDHH24MISS'), 'YYYYMMDD');
            V_ETIME := TO_CHAR(TO_DATE(P_PRD_END_DATE, 'YYYYMMDDHH24MISS'), 'HH24MISS');

           	--폐품등록시 가동시간 0으로 처리
            --V_RUN_TM := (V_PRD_END_DATE-V_PRD_STR_DATE)*24*60;
            V_RUN_TM := 0;

            --투입자재정보 조회
            BEGIN
                SELECT MATNR_M, LOT_NO_M, IND_BCD
                  INTO V_DISPO_MATNR, V_DISPO_LOT, V_DISPO_BCD
                  FROM (SELECT MATNR_M, LOT_NO_M, MAX(IND_BCD_M) AS IND_BCD, MAX(I010.REGDATE) AS REGDATE
                          FROM TB_INV010 I010, TB_MAS001 M001
                         WHERE 1=1
                           AND I010.WERKS = M001.WERKS
                           AND I010.MATNR_M = M001.MATNR
                           AND I010.WERKS = P_WERKS
                           AND I010.MACH_CD = P_MACH_CD
                           AND I010.MATNR = V_MATNR
                           AND I010.WRK_ORDR_NO = V_WRK_ORDR_NO
                           AND I010.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                           AND I010.USE_DIV = '1'
                           AND M001.MATNR_DIV = 'HALB'
                           AND NVL(I010.CNL_YN,'N') = 'N'
                         GROUP BY MATNR_M, LOT_NO_M
                         ORDER BY REGDATE DESC)
                WHERE ROWNUM < 2;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                V_DISPO_MATNR := '';
                V_DISPO_LOT := '';
                V_DISPO_BCD := '';
            END;

            --와딩티슈 생산여부 확인
            SELECT COUNT(*) 
              INTO V_WTYPE_FLAG
              FROM CMCDV 
             WHERE 1=1
               AND CMCDKY = 'MATNR_CHG'
               AND CMCDVL = V_MATNR;
            --일반 합지품목 폐품시 실적정보 등록 
            IF V_WTYPE_FLAG = 0 THEN
            	--기본 합지기 과정 폐품 등록시 폐품 등록용 LOT NO 신규생성   
            	SP_CHK_LOT_NO(NVL(V_LOT_NO, ' '), P_WERKS, P_MACH_CD, V_MATNR, P_PRD_STR_DATE, V_LOT_NO);
          
                V_DISPO_MATNR := V_MATNR;
                V_DISPO_LOT := V_LOT_NO;
                V_DISPO_BCD := V_IND_BCD;
                --실적등록
                INSERT INTO TB_WRK001 (WERKS, MACH_CD, IND_BCD, LOT_NO, MATNR,
                                        ORDER_NO, ORDER_SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO, DOC_NO, DOC_SEQNO,
                                        PRFM_QTY, UNIT, WIDTH, ROLLCNT, WGT, PLT_QTY, BOX_QTY, BAG_QTY, EA_QTY, STA,
                                        PRFM_DT, PRD_DT, DSTBT_DDLIN, WRK_CLASS, WRK_SHIFT,
                                        PRD_STR_DATE, PRD_END_DATE,
                                        PRFM_GTHR_YN, REGDATE, REGID)
                               VALUES(P_WERKS, P_MACH_CD, V_IND_BCD, V_LOT_NO, V_MATNR,
                                        V_ORDER_NO, V_ORDER_SEQNO, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_DOC_NO_PRFM, 1,
                                        P_DISPO_QTY, V_UNIT, P_WIDTH, P_ROLLCNT, P_DISPO_QTY, 0, 0, 0, 0, '00',
                                        P_PRFM_DT, V_PRD_DT, '', V_WRK_CLASS, V_WRK_SHIFT,
                                        TO_DATE(P_PRD_STR_DATE, 'YYYYMMDDHH24MISS'),
                                        TO_DATE(P_PRD_END_DATE, 'YYYYMMDDHH24MISS'),
                                        'N', V_DATE, P_USER_ID);
                --인터테이스 테이블 등록
                INSERT INTO TB_IFS001(AUFNR, LOTNO, PRDCD, WERKS, WORKCENTERCODE, MACHINE,
                                        PRDDT, PRODT, WORKGROUP, LEADER, WORKER, PUPOS,
                                        PROQTY, SCRQTY, RUNTIME, SDATE, STIME, EDATE, ETIME, 
                                        SCPAP, SAIP,
                                        MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                                VALUES(V_ORDER_NO, V_LOT_NO, V_MATNR, P_WERKS, V_SAP_WRK_CD, V_MACHINE,
                                        P_PRFM_DT, V_PRD_DT, V_WRK_CLASS, P_USER_ID, P_USER_ID, V_PUPOS,
                                        P_DISPO_QTY, 0, V_RUN_TM/*P_TM*/, TO_CHAR(V_PRD_STR_DATE,'YYYYMMDD'), TO_CHAR(V_PRD_STR_DATE,'HH24MISS'), 
                                        TO_CHAR(V_PRD_END_DATE,'YYYYMMDD'), TO_CHAR(V_PRD_END_DATE,'HH24MISS'),
                                        'N', 'N',
                                        V_DOC_NO_PRFM, 1, V_DATE, P_USER_ID);
                --IF 전송이력(2:생산폐품)
                INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                                    WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                    IND_BCD, LOT_NO, ORDER_NO, CNL_YN,
                                    REGDATE, REGID)
                                VALUES(V_DOC_NO_PRFM, 1, 1,
                                    P_WERKS, P_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                    V_IND_BCD, V_LOT_NO, V_ORDER_NO, 'N',
                                    V_DATE, P_USER_ID);  

                --SAP FUNC ID 123
                SELECT RFCFN
                  INTO P_PRFM_FUNC
                  FROM TB_ITFMA
                 WHERE 1=1
                   AND IFID = V_IF_ID_PRFM;
                --인터페이스 파라미터
                OPEN CUR_1 FOR
                SELECT V_IF_ID_PRFM AS I_IF_ID
                     , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                FROM dual;
                --인터페이스 상세 파라미터
                V_SQL := FN_IF_QUERY(V_IF_ID_PRFM, V_DOC_NO_PRFM);
                IF V_SQL IS NOT NULL THEN
                	OPEN CUR_2 FOR V_SQL;
                END IF;
            ELSE
            	--와딩티슈 폐품 등록시 기존 실적의 LOT로 지정
            	BEGIN
		            SELECT MAX(LOT_NO)
		              INTO V_LOT_NO
		              FROM TB_WRK001
		             WHERE 1=1
		               AND WERKS = P_WERKS
		               AND MACH_CD = P_MACH_CD
		               AND WRK_ORDR_NO = V_WRK_ORDR_NO
		               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
	            EXCEPTION WHEN NO_DATA_FOUND THEN
	            	V_LOT_NO := '';
	            END;
	           	--현재 작업지시의 이력이 없는 경우 오류처리
	            IF V_LOT_NO IS NULL THEN
	            	ROLLBACK;
	                RS_CODE := 'E';
	                RS_MSG  := '실적을 등록하신후 폐품을 등록하여 주시기 바랍니다.';
	                RETURN;
	            END IF;
            END IF;

            --폐품 I/F 문서번호
            V_DOC_NO_DISPO := FN_GET_MDOCNO('M','IF134');
            V_DOC_SEQNO := 1;

--            IF V_DISPO_MATNR IS NULL THEN
--                V_ROLLCNT := 0;
--                V_WGT := 0;
--            ELSE 
--                V_ROLLCNT := FN_CHG_UNIT(V_MATNR, P_WERKS, P_UNIT, 'M', P_DISPO_QTY);
--                V_WGT := FN_CHG_UNIT(V_MATNR, P_WERKS, P_UNIT, 'KG', P_DISPO_QTY);
--            END IF;
            -- 폐품 등록
            INSERT INTO TB_WRK004 (WERKS, MACH_CD, IND_BCD, LOT_NO, MATNR, DISPO_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO
                                     , MMATNR, IND_BCD_M, LOT_NO_M, UNIT, ROLLCNT, DISPO_QTY, WGT, RUN_STA
                                     , PRD_STR_DATE, PRD_END_DATE, TM, PRFM_DT, WRK_CLASS, WRK_SHIFT
                                     , DOC_NO, DOC_SEQNO, REGDATE, REGID)
                               VALUES (P_WERKS, P_MACH_CD, V_IND_BCD, V_LOT_NO, V_MATNR, P_DISPO_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO
                                     , V_DISPO_MATNR, V_DISPO_BCD, V_DISPO_LOT, P_UNIT, P_ROLLCNT, P_DISPO_QTY, P_DISPO_QTY, '02'
                                     --, V_MATNR, V_IND_BCD, V_LOT_NO, P_UNIT, V_ROLLCNT, P_DISPO_QTY, V_WGT
                                     , V_PRD_STR_DATE, V_PRD_END_DATE, V_RUN_TM/*V_RUN_TM*/, TO_CHAR(V_PRD_END_DATE,'YYYYMMDD'), V_WRK_CLASS, V_WRK_SHIFT
                                     , V_DOC_NO_DISPO, V_DOC_SEQNO, V_DATE, P_USER_ID);     
            --소요량 등록
            --가용수량 확인
            SP_REG_LOT_LOG_S01 (P_WERKS, P_MACH_CD, V_MATNR, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, P_DISPO_QTY, 1, V_ERR_LIST);
            IF LENGTH(V_ERR_LIST) > 0 THEN
                ROLLBACK;
                RS_CODE := 'N';
                RS_MSG  := V_ERR_LIST;
                RETURN;
            END IF;
            --자재 소요량 SAP전송 문서번호 반환
            SP_REG_LOT_LOG_I01 (P_WERKS, P_MACH_CD, V_MATNR, V_LOT_NO, V_IND_BCD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, TO_CHAR(V_PRD_END_DATE,'YYYYMMDD'), P_DISPO_QTY, V_UNIT, 'N', 3, P_USER_ID, RS_CODE, RS_MSG);
            IF RS_CODE = 'E' THEN
                ROLLBACK;
                RS_CODE := 'E';
                RS_MSG  := RS_MSG;
                RETURN;
            END IF;

            --투입 사용량 존재시 RFC 처리진행
            IF V_DOC_USE IS NOT NULL THEN
                --SAP FUNC ID 130
                SELECT RFCFN
                  INTO P_USE_FUNC
                  FROM TB_ITFMA
                 WHERE 1=1
                   AND IFID = V_IF_ID_USE;
                --인터페이스 파라미터
                OPEN CUR_1 FOR
                SELECT V_IF_ID_USE AS I_IF_ID
                     , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                FROM dual;
                --인터페이스 상세 파라미터
                V_SQL := FN_IF_QUERY(V_IF_ID_USE, V_DOC_USE);
                IF V_SQL IS NOT NULL THEN
                	OPEN CUR_2 FOR V_SQL;
                END IF;
            END IF;

            SELECT DISPO_NM INTO V_DISPO_NM
              FROM TB_MAS023
             WHERE WERKS = P_WERKS
               AND DISPO_CD = P_DISPO_CD;

            V_SDATE := TO_CHAR(TO_DATE(P_PRD_STR_DATE, 'YYYYMMDDHH24MISS'), 'YYYYMMDD');
            V_STIME := TO_CHAR(TO_DATE(P_PRD_STR_DATE, 'YYYYMMDDHH24MISS'), 'HH24MISS');
            V_EDATE := TO_CHAR(TO_DATE(P_PRD_END_DATE, 'YYYYMMDDHH24MISS'), 'YYYYMMDD');
            V_ETIME := TO_CHAR(TO_DATE(P_PRD_END_DATE, 'YYYYMMDDHH24MISS'), 'HH24MISS');

           	--폐품 등록시 영업폐품 등록과정 추가 필요
            IF P_DISPO_CD = '900' THEN
            	INSERT INTO TB_IFS012( AUFNR, LOTNO, BUDAT, MATNR, SCRQTY, RSDQTY, SCRAPCODE,
	                                    SCRAPREASON, FAULT, SCRQTY_OP, SCRAPCODE_OP, SCRAPREASON_OP, LGORT, CHARG,
	                                    SDATE, STIME, EDATE, ETIME, MDOCNO, MDOCSEQ, ZRESULT, MAKE_DATE, MAKER,
	                                    RUNTIME, JSPEED, MRSCQTY, JREMARK, VBELN, POSNR, WORKCENTERCODE)
	                            VALUES( V_ORDER_NO, V_LOT_NO, TO_CHAR(TO_DATE(P_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), V_DISPO_MATNR, 0, P_DISPO_QTY, P_DISPO_CD,
	                                    V_DISPO_NM, 'N', 0, ' ', ' ', '2000', V_DISPO_LOT,
	                                    V_SDATE, V_STIME, V_EDATE, V_ETIME, V_DOC_NO_DISPO, V_DOC_SEQNO, 'N', V_DATE, P_USER_ID,
	                                    V_RUN_TM/*P_TM*/, P_SPEED, 0, P_RMK, '', '', V_SAP_WRK_CD);
			ELSE
				INSERT INTO TB_IFS012( AUFNR, LOTNO, BUDAT, MATNR, SCRQTY, RSDQTY, SCRAPCODE,
	                                    SCRAPREASON, FAULT, SCRQTY_OP, SCRAPCODE_OP, SCRAPREASON_OP, LGORT, CHARG,
	                                    SDATE, STIME, EDATE, ETIME, MDOCNO, MDOCSEQ, ZRESULT, MAKE_DATE, MAKER,
	                                    RUNTIME, JSPEED, MRSCQTY, JREMARK, VBELN, POSNR, WORKCENTERCODE)
	                            VALUES( V_ORDER_NO, V_LOT_NO, TO_CHAR(TO_DATE(P_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), V_DISPO_MATNR, P_DISPO_QTY, 0, P_DISPO_CD,
	                                    V_DISPO_NM, 'N', 0, ' ', ' ', '2000', V_DISPO_LOT,
	                                    V_SDATE, V_STIME, V_EDATE, V_ETIME, V_DOC_NO_DISPO, V_DOC_SEQNO, 'N', V_DATE, P_USER_ID,
	                                    V_RUN_TM/*P_TM*/, P_SPEED, 0, P_RMK, '', '', V_SAP_WRK_CD);
			END IF;
            --문서이력
            INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                IND_BCD, LOT_NO, ORDER_NO, CNL_YN, REGDATE, REGID)
                        VALUES(V_DOC_NO_DISPO, V_DOC_SEQNO, 2, P_WERKS, P_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                V_IND_BCD, V_LOT_NO, V_ORDER_NO, 'N', V_DATE, P_USER_ID);   

            --SAP FUNC ID 134
            SELECT RFCFN
              INTO P_DISPO_FUNC
              FROM TB_ITFMA
             WHERE 1=1
               AND IFID = V_IF_ID_DISPO;
            --인터페이스 파라미터
            OPEN CUR_3 FOR
            SELECT V_IF_ID_DISPO AS I_IF_ID
                 , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
            FROM dual;
            --인터페이스 상세 파라미터
            V_SQL := FN_IF_QUERY(V_IF_ID_DISPO, V_DOC_NO_DISPO);
            IF V_SQL IS NOT NULL THEN
            	OPEN CUR_4 FOR V_SQL;
            END IF;

            RS_CODE := 'S';

            --폐품을 위한 실적 미등록시 처리
            IF CUR_1%ISOPEN = FALSE THEN
                OPEN CUR_1 FOR SELECT 1 FROM dual;
            END IF;
            IF CUR_2%ISOPEN = FALSE THEN
                OPEN CUR_2 FOR SELECT 1 FROM dual;
            END IF;
        END;
        --ROLLBACK;
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
END SP_POP_WRK43_I01;

/
