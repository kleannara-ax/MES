--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK41_U02
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK41_U02" 
(
    P_WERKS                 IN VARCHAR2
    ,P_MACH_CD              IN VARCHAR2 
    ,P_IOTYPE               IN VARCHAR2 
    ,P_USERID               IN VARCHAR2
    ,P_ORDER_NO             IN VARCHAR2 
    ,P_WRK_ORDR_NO          IN VARCHAR2 
    ,P_WRK_ORDR_SEQNO       IN VARCHAR2 
    ,P_PRD_STR_DATE         IN VARCHAR2
    ,P_PRD_END_DATE         IN VARCHAR2
    ,P_NEW_ORDER_NO         IN VARCHAR2
    ,P_NEW_WRK_ORDR_NO      IN VARCHAR2 
    ,P_NEW_WRK_ORDR_SEQNO   IN VARCHAR2 
    ,P_NEW_PRD_STR_DATE     IN VARCHAR2
    ,P_MATNR                IN VARCHAR2
    ,P_NEW_MATNR            IN VARCHAR2
    ,P_PROC_CD              IN VARCHAR2
    ,P_ORDER_DOC            OUT VARCHAR2 
    ,P_WRK_FUNC             OUT VARCHAR2
    ,Lang                   IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE                OUT VARCHAR2 
    ,RS_MSG                 OUT VARCHAR2
    ,CUR_1                  OUT SYS_REFCURSOR
    ,CUR_2                  OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK41
 * PROGRAM NAME  : HL 작업지시 완료
 * VERSION       : 1.0.0
 * DESCRIPTION   : 진행중인 작업지시를 완료한다.(이후 작업지시 없음)
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/10/23
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/04/28    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK011] : (C.U.) 작업장 현황
 * - [TB_WRK012] : (C.U.) 작업장 가동현황
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM         VARCHAR2(100)  := 'SP_POP_WRK41_U02';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := P_PROC_CD;
    V_SESS_USER_ID   varchar2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리
    V_WRK_ORDR_SEQNO        NUMBER(5,0) := TO_NUMBER(P_WRK_ORDR_SEQNO);
    V_PRD_STR_DATE          DATE := TO_DATE(P_PRD_STR_DATE, 'yyyy-MM-dd HH24:mi:ss');
    V_PRD_END_DATE          DATE := TO_DATE(P_PRD_END_DATE, 'yyyy-MM-dd HH24:mi:ss');
    V_NEW_WRK_ORDR_SEQNO    NUMBER(5,0) := TO_NUMBER(P_NEW_WRK_ORDR_SEQNO);
    V_NEW_PRD_STR_DATE      DATE := TO_DATE(P_NEW_PRD_STR_DATE, 'yyyy-MM-dd HH24:mi:ss');
    V_IOTYPE				VARCHAR2(10) := CASE WHEN P_WERKS = 'P500' THEN 'N' ELSE P_IOTYPE END;
    --내부 변수 등록
    V_DATE                  DATE := SYSDATE;
    V_WRK_CLASS             VARCHAR2(10); --작업반
    V_WRK_SHIFT             VARCHAR2(10); --작업조
    V_EMPLY_NO              VARCHAR2(10); --메인작업자
    V_WRKER_CNT             NUMBER(5,0); --작업인원수
    V_NOW_LOT               VARCHAR2(15); --이전 선택된 지시(기저귀)
    V_NOW_STA               VARCHAR2(10); --이전 지시 상태
    V_BEF_LOT               VARCHAR2(15); --이전 작업중 지시 상태
    V_HIND_BCD              VARCHAR2(20); --투입된 자재 바코드(합지)
    V_PRFM_DT               VARCHAR2(8); --실적일자
    V_PRD_DT                VARCHAR2(8); --생산일자
    V_SAP_WRK_CD            VARCHAR(20); --SAP작업장코드
    V_MACHINE               VARCHAR2(5); --생산호기
    V_HMACHINE              VARCHAR2(10); --합지생산호기
    V_HMATNR                VARCHAR(20); --합지품목
    V_HUNIT                 VARCHAR(10); --합지단위
    V_HLOTNO1               VARCHAR2(10); --합지LOT1
    V_INPQT1                VARCHAR2(10); --합지수량1
    V_HLOTNO2               VARCHAR2(10); --합지LOT2
    V_INPQT2                VARCHAR2(10); --합지수량2
    V_HLOTNO3               VARCHAR2(10); --합지LOT3
    V_INPQT3                VARCHAR2(10); --합지수량3
    V_RUNTIME               VARCHAR2(8); --가동시간(분)
    V_RUN_TM                NUMBER; --가동 시간
    V_ABN_TM                NUMBER; --비가동 시간
    V_UNIT                  VARCHAR2(10);
    V_DOC_NO                VARCHAR2(29); --실적등록 문서번호
    V_DOC_SEQ               VARCHAR2(6);
    V_COMP_CNT              NUMBER; --지시 생산 완료여부
    V_WRK_CNT               NUMBER; --설비별 상태변경이력 확인
    V_ORDR_END_DATE         DATE;--오더 완료 시간
    V_PUPOS                 VARCHAR2(1);
    V_PRE_WRK_ORDR_NO       VARCHAR2(20); 
    V_PRE_WRK_ORDR_SEQNO    NUMBER;
    V_OIF_ID VARCHAR2(20); --MES IF ID
    V_SQL_O VARCHAR2(4000);

BEGIN
    --예외처리 시작(try)
    BEGIN
        --투입된 작업자 정보 조회
        BEGIN
        SELECT WRK_SHIFT, EMPLY_NO, WRKER_CNT
          INTO V_WRK_SHIFT, V_EMPLY_NO, V_WRKER_CNT
          FROM TB_WRK013
         WHERE ROWNUM <= 1
           AND WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND IN_OUT = V_IOTYPE
           --AND END_DATE IS NULL
         ORDER BY STR_DATE DESC;
        EXCEPTION WHEN NO_DATA_FOUND THEN 
            RS_CODE := 'E';
            RS_MSG  := '작업자 현황을 확인하여 주시기 바랍니다.';
            RETURN;
        END;

        --상태에 따른 이전 문서 확인
        BEGIN
            SELECT CASE WHEN MACH_STA = 'N' THEN PRE_WRK_ORDR_NO ELSE WRK_ORDR_NO END,
                   CASE WHEN MACH_STA = 'N' THEN PRE_WRK_ORDR_SEQNO ELSE WRK_ORDR_SEQNO END
                   INTO V_PRE_WRK_ORDR_NO, V_PRE_WRK_ORDR_SEQNO
              FROM TB_WRK011
             WHERE MACH_CD = P_MACH_CD
               AND IN_OUT = V_IOTYPE;
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN NULL;
        END;

        --포장기 처리시 가공기 LOT확인
        BEGIN
            SELECT LOT_NO, MACH_STA
              INTO V_NOW_LOT, V_NOW_STA
              FROM TB_WRK011
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND WRK_ORDR_NO = P_NEW_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_NEW_WRK_ORDR_SEQNO
               AND IN_OUT != 'O';
        EXCEPTION WHEN NO_DATA_FOUND THEN 
            V_NOW_LOT := '';
            V_NOW_STA := '';
        END;
        --현재 작업장 정보 조회
        SELECT LOT_NO
          INTO V_BEF_LOT
          FROM TB_WRK011
         WHERE 1=1
           AND WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND IN_OUT = V_IOTYPE;
        --자재정보
        BEGIN
            SELECT UNIT
              INTO V_UNIT
              FROM TB_MAS001
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MATNR = P_MATNR;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            V_UNIT := '';
        END;
        --설비정보 조회
        SELECT MACHINE, SAP_WRK_CD
          INTO V_MACHINE, V_SAP_WRK_CD
          FROM TB_MAS012
         WHERE 1=1
           AND MACH_CD = P_MACH_CD;   
        --작업자 정보 조회
        BEGIN
            SELECT WRK_CLASS
              INTO V_WRK_CLASS
              FROM USRMA
             WHERE 1=1
               AND USERID = V_EMPLY_NO;
        EXCEPTION WHEN NO_DATA_FOUND THEN 
            RS_CODE := 'E';
            RS_MSG  := '작업자 정보를 확인하여 주시기 바랍니다.';
            RETURN;
        END;

        --가동시간
        V_RUN_TM := (V_PRD_END_DATE-V_PRD_STR_DATE)*24*60;
        --비가동 시간 합계
        SELECT NVL((SUM(END_DATE - STR_DATE)*24*60),0)
          INTO V_ABN_TM
          FROM TB_WRK003 --비가동 이력
         WHERE 1=1
           AND WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND IN_OUT != 'O'
           AND WRK_ORDR_NO = P_WRK_ORDR_NO
           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
           AND END_DATE IS NOT NULL;
        V_RUNTIME := CEIL(V_RUN_TM - V_ABN_TM);

        -- 작업장 현황관리 신규 지시 등록
        UPDATE TB_WRK011
           SET MATNR = ''--P_NEW_MATNR
             , WRK_ORDR_NO = ''--P_NEW_WRK_ORDR_NO
             , WRK_ORDR_SEQNO = ''--V_NEW_WRK_ORDR_SEQNO
             , PRE_WRK_ORDR_NO =  ''--V_PRE_WRK_ORDR_NO
             , PRE_WRK_ORDR_SEQNO = ''--V_PRE_WRK_ORDR_SEQNO --V_WRK_ORDR_SEQNO
             , PRD_STR_DTM = ''--TO_CHAR(V_NEW_PRD_STR_DATE,'YYYYMMDDHH24MISS')
             , ORDER_NO = ''--P_NEW_ORDER_NO
             , LOT_NO = ''--V_NOW_LOT
             , MACH_STA = ''--CASE WHEN P_WERKS = 'P500' THEN NVL(V_NOW_STA,'N') ELSE 'N' END 
             , UPDDATE = V_DATE
             , UPDID = P_USERID
         WHERE 1=1
           AND WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND IN_OUT = V_IOTYPE;
     
        --기존 작업장 가동현황 수정(시작/완료시간 변경 가능:완료되지 않은 가동현황수정)
        --기존 완료된 이력 조회
        SELECT COUNT(*)
          INTO V_WRK_CNT
          FROM TB_WRK012
         WHERE 1=1
           AND WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND STR_DATE = V_NEW_PRD_STR_DATE
           AND END_DATE IS NOT NULL;
        IF V_WRK_CNT > 0 THEN
            RS_CODE := 'E';
            RS_MSG  := '기존에 작업이 진행된 시간입니다.\n시작시간을 변경후 등록하여 주시기 바랍니다.';
            RETURN;
        END IF;
        --이전 가동 현황중 미완료 항목 완료처리
        UPDATE TB_WRK012
           SET END_DATE = V_PRD_END_DATE
             , UPDDATE = V_DATE
             , UPDID = P_USERID
         WHERE 1=1
           AND WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND IN_OUT = V_IOTYPE --LIKE CASE WHEN P_WERKS = 'P500' THEN '' ELSE P_IOTYPE END || '%'
           AND STR_DATE < V_NEW_PRD_STR_DATE
           AND END_DATE IS NULL;
        --신규 가동 현황 등록(대기중인 경우 가동현황 미등록)
        UPDATE TB_WRK012
           SET WRK_ORDR_NO = ''
             , WRK_ORDR_SEQNO = ''
             , ORDER_NO = ''
             , MATNR = ''
             , LINE_STA = 'N'
             , RMK = '생산종료'
             , UPDDATE = V_DATE
             , UPDID = P_USERID
         WHERE 1=1
           AND WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND STR_DATE = V_NEW_PRD_STR_DATE
           AND END_DATE IS NULL;
        IF SQL%ROWCOUNT = 0 THEN
            INSERT INTO TB_WRK012 (WERKS, MACH_CD, IN_OUT, STR_DATE, 
                                   WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, 
                                   MATNR, LINE_STA, 
                                   REGDATE, REGID, RMK)
                            VALUES(P_WERKS, P_MACH_CD, V_IOTYPE, V_PRD_END_DATE, 
                                   '','', '', 
                                   '', 'N', 
                                   V_DATE, P_USERID, '품목변경');   
        END IF;
        --투입된 작업자 정보 변경
        UPDATE TB_WRK013
           SET WRK_ORDR_NO = ''--P_NEW_WRK_ORDR_NO
             , WRK_ORDR_SEQNO = ''--V_NEW_WRK_ORDR_SEQNO
             , UPDDATE = V_DATE
             , UPDID = P_USERID
         WHERE 1=1
           AND WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND IN_OUT = V_IOTYPE 
           AND STR_DATE = V_NEW_PRD_STR_DATE
           AND END_DATE IS NULL;

        --이전 지시정보 변경
        IF P_WRK_ORDR_NO IS NOT NULL THEN
            --IF 전송시간 작성
            V_PRFM_DT := FN_RECDATE(V_PRD_END_DATE); --실적일자
            V_PRD_DT := TO_CHAR(V_DATE,'YYYYMMDD');--생산일자
            --마지막 완료실적과 완료시간이 중복되는 경우 에러 발생
            V_ORDR_END_DATE := V_PRD_END_DATE + (INTERVAL '1' SECOND);

            --청주의 경우 가공기의 작업시 상태 변경
            IF P_WERKS = 'P500' THEN
                --기저귀
                IF SUBSTR(P_MACH_CD,1,3) = 'BRC' THEN
                    -- 지시 완료처리           
                    UPDATE TB_SCH014
                       SET PRD_END_DTM = TO_CHAR(V_PRD_END_DATE,'YYYYMMDDHH24MISS')
                         , COMP_YN = DECODE(NVL(PRFM_QTY,0), 0, 'N', 'Y')
                         , UPDDATE = V_DATE
                         , UPDID = P_USERID
                     WHERE 1=1
                       AND WRK_ORDR_NO = V_PRE_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO = V_PRE_WRK_ORDR_SEQNO
                       AND COMP_YN != 'Y';
                    IF SQL%ROWCOUNT > 0 THEN   
                        --생산 완료여부 확인
                        SELECT COUNT(COMP_YN)
                          INTO V_COMP_CNT
                          FROM TB_WRK001
                         WHERE 1=1
                           AND WERKS = P_WERKS
                           AND MACH_CD = P_MACH_CD
                           AND WRK_ORDR_NO = P_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                           AND COMP_YN = 'Y';  
                        --생산 완료시 문서 전송
                        IF V_COMP_CNT > 0 THEN
                            V_DOC_NO := FN_GET_MDOCNO('M','IF133');
                            V_DOC_SEQ := '1';
                            V_OIF_ID := 'MES_IF_133';
                            P_ORDER_DOC := V_DOC_NO;
                            --오더 완료 SAP 전송 
                            INSERT INTO TB_IFS011(AUFNR, LOTNO, MATNR, WERKS, WORKCENTERCODE, MACHINE, 
                                                    WORKGROUP, OPNAM, CONF, RUNTIME, PROQTY, MEINS, BUDAT, 
                                                    SDATE, STIME, EDATE, ETIME, 
                                                    MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                                            VALUES(P_ORDER_NO, V_BEF_LOT, P_MATNR, P_WERKS, V_SAP_WRK_CD, V_MACHINE, 
                                                    V_WRK_CLASS, P_USERID, 'X', '0', 0, V_UNIT, V_PRFM_DT,--FN_DT_FORMAT(P_PRD_END_DATE,'YYYYMMDD'),
                                                    TO_CHAR(V_ORDR_END_DATE,'YYYYMMDD'), TO_CHAR(V_ORDR_END_DATE,'HH24MISS'), 
                                                    TO_CHAR(V_ORDR_END_DATE,'YYYYMMDD'), TO_CHAR(V_ORDR_END_DATE,'HH24MISS'),
                                                    V_DOC_NO, V_DOC_SEQ, V_DATE, P_USERID);
                            --IF 전송이력(20:오더완료)
                            INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                                                WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                                IND_BCD, LOT_NO, ORDER_NO, CNL_YN,
                                                REGDATE, REGID)
                                            VALUES(V_DOC_NO, TO_NUMBER(V_DOC_SEQ), 20,
                                                P_WERKS, P_MACH_CD, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                                ' ', V_BEF_LOT, P_ORDER_NO, 'N',
                                                V_DATE, P_USERID);
                            --SAP FUNC ID
                            SELECT RFCFN
                              INTO P_WRK_FUNC
                              FROM TB_ITFMA
                             WHERE 1=1
                               AND IFID = V_OIF_ID;
                            --인터페이스 파라미터
                            OPEN CUR_1 FOR
                            SELECT V_OIF_ID AS I_IF_ID
                                 , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                            FROM dual;
                            --인터페이스 상세 파라미터
                            V_SQL_O := FN_IF_QUERY(V_OIF_ID, V_DOC_NO);
                            IF V_SQL_O IS NOT NULL THEN
                            	OPEN CUR_2 FOR V_SQL_O;
                            END IF;
                        END IF;
                    END IF;
                END IF;
            ELSE
                --청주 작업의 경우 가공기에서만 완료처리 진행
                IF V_IOTYPE = 'I' THEN
                    --화장지
                    IF SUBSTR(P_MACH_CD,1,3) = 'TRA' THEN
                        UPDATE TB_SCH012
                           SET PRD_END_DTM = TO_CHAR(V_PRD_END_DATE,'YYYYMMDDHH24MISS')
                             , COMP_YN = DECODE(NVL(PRFM_QTY,0), 0, 'N', 'Y')
                             , UPDDATE = V_DATE
                             , UPDID = P_USERID
                         WHERE 1=1
                           AND WRK_ORDR_NO = V_PRE_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_PRE_WRK_ORDR_SEQNO
                           AND COMP_YN != 'Y';
                        IF SQL%ROWCOUNT > 0 THEN
                            --생산 완료여부 확인
                            SELECT COUNT(COMP_YN)
                              INTO V_COMP_CNT
                              FROM TB_WRK001
                             WHERE 1=1
                               AND WERKS = P_WERKS
                               AND MACH_CD = P_MACH_CD
                               AND WRK_ORDR_NO = P_WRK_ORDR_NO
                               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                               AND COMP_YN ='Y';
                            IF V_COMP_CNT > 0 THEN
                                --생산실적 문서번호
                                V_DOC_NO := FN_GET_MDOCNO('M','IF124');
                                V_DOC_SEQ := '1';
                                V_OIF_ID := 'MES_IF_124';
                                P_ORDER_DOC := V_DOC_NO;
                                --투입 합지 정보 조회
                                BEGIN
                                SELECT LOT1, NVL(QTY1,0), LOT2, NVL(QTY2,0), LOT3, NVL(QTY3,0), NVL(BCD3,NVL(BCD2,BCD1))
                                  INTO V_HLOTNO1, V_INPQT1, V_HLOTNO2, V_INPQT2, V_HLOTNO3, V_INPQT3, V_HIND_BCD
                                  FROM (SELECT FIRST_VALUE(LOT_NO_M) OVER() AS LOT1
                                            , FIRST_VALUE(USE_QTY) OVER() AS QTY1
                                            , FIRST_VALUE(IND_BCD) OVER() AS BCD1
                                            , LEAD(LOT_NO_M) OVER(ORDER BY SEQNO) AS LOT2
                                            , LEAD(USE_QTY) OVER(ORDER BY SEQNO) AS QTY2
                                            , LEAD(IND_BCD) OVER(ORDER BY SEQNO) AS BCD2
                                            , LEAD(LOT_NO_M,2) OVER(ORDER BY SEQNO) AS LOT3
                                            , LEAD(USE_QTY,2) OVER(ORDER BY SEQNO) AS QTY3
                                            , LEAD(IND_BCD,2) OVER(ORDER BY SEQNO) AS BCD3
                                         FROM (SELECT MIN(SEQNO) AS SEQNO, LOT_NO_M, MAX(IND_BCD_M) AS IND_BCD, SUM(USE_QTY) AS USE_QTY 
                                                 FROM TB_INV010 I010, TB_MAS001 M001
                                                WHERE 1=1
                                                  AND I010.WERKS = M001.WERKS
                                                  AND I010.MATNR_M = M001.MATNR
                                                  AND I010.WERKS = P_WERKS
                                                  AND I010.MACH_CD = P_MACH_CD
                                                  AND I010.MATNR = P_MATNR
                                                  AND I010.WRK_ORDR_NO = P_WRK_ORDR_NO
                                                  AND I010.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                                                  AND M001.MATNR_DIV = 'HALB'
                                                GROUP BY LOT_NO_M)
                                        ORDER BY SEQNO)
                                 WHERE ROWNUM = 1;
                                EXCEPTION WHEN NO_DATA_FOUND THEN
                                    V_HLOTNO1 := '';
                                    V_INPQT1 := 0;
                                    V_HLOTNO2 := '';
                                    V_INPQT2 := 0;
                                    V_HLOTNO3 := '';
                                    V_INPQT3 := 0;
                                    V_HIND_BCD := '';
                                    IF P_WERKS = 'P200' THEN
                                        RS_CODE := 'E';
                                        RS_MSG  := '투입된 합지정보를 찾을수 없습니다.\n합지투입 후 실적을 등록하여 주시기 바랍니다.';
                                        RETURN;
                                    END IF;
                                END;
                                --투입된 자재 생산호기 확인
                                BEGIN
                                    SELECT MACHINE, MATNR, UNIT
                                      INTO V_HMACHINE, V_HMATNR, V_HUNIT
                                      FROM TB_INV001
                                     WHERE 1=1
                                       AND ROWNUM < 2
                                       AND IND_BCD = V_HIND_BCD
                                     ORDER BY MACHINE;
                                EXCEPTION WHEN NO_DATA_FOUND THEN
                                    V_HMACHINE := '';
                                END;
                                --생산이 완료된 지시의 경우 IF 추가
                                INSERT INTO TB_IFS002(AUFNR, LOTNO, PRDCD, WERKS, WORKCENTERCODE, MACHINE, HMACHINE,
                                                    HLOTNO1, HMATNR1, HMEINS1, INPQT1,
                                                    HLOTNO2, HMATNR2, HMEINS2, INPQT2,
                                                    HLOTNO3, HMATNR3, HMEINS3, INPQT3,
                                                    WORKGROUP, OPNAM, CONF, RUNTIME, PROQTY, MEINS, PRDDT, PRODT,
                                                    SDATE, STIME, EDATE, ETIME, 
                                                    MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                                            VALUES(P_ORDER_NO, V_BEF_LOT, P_MATNR, P_WERKS, V_SAP_WRK_CD, V_MACHINE, V_HMACHINE,
                                                    V_HLOTNO1, V_HMATNR, V_HUNIT, V_INPQT1,
                                                    V_HLOTNO2, V_HMATNR, V_HUNIT, V_INPQT2,
                                                    V_HLOTNO3, V_HMATNR, V_HUNIT, V_INPQT3,
                                                    V_WRK_CLASS, P_USERID, 'X', '0', 0, V_UNIT, FN_DT_FORMAT(V_PRFM_DT,'YYYYMMDD'), FN_DT_FORMAT(V_PRD_DT,'YYYYMMDD'),
                                                    TO_CHAR(V_ORDR_END_DATE,'YYYYMMDD'), TO_CHAR(V_ORDR_END_DATE,'HH24MISS'), 
                                                    TO_CHAR(V_ORDR_END_DATE,'YYYYMMDD'), TO_CHAR(V_ORDR_END_DATE,'HH24MISS'),
                                                    V_DOC_NO, V_DOC_SEQ, V_DATE, P_USERID);
                                --IF 전송이력(20:오더완료)
                                INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                                                    WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                                    IND_BCD, LOT_NO, ORDER_NO, CNL_YN,
                                                    REGDATE, REGID)
                                                VALUES(V_DOC_NO, TO_NUMBER(V_DOC_SEQ), 20,
                                                    P_WERKS, P_MACH_CD, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                                    ' ', V_BEF_LOT, P_ORDER_NO, 'N',
                                                    V_DATE, P_USERID);
                                --SAP FUNC ID
                                SELECT RFCFN
                                  INTO P_WRK_FUNC
                                  FROM TB_ITFMA
                                 WHERE 1=1
                                   AND IFID = V_OIF_ID;
                                --인터페이스 파라미터
                                OPEN CUR_1 FOR
                                SELECT V_OIF_ID AS I_IF_ID
                                     , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                                FROM dual;
                                --인터페이스 상세 파라미터
                                V_SQL_O := FN_IF_QUERY(V_OIF_ID, V_DOC_NO);
                                IF V_SQL_O IS NOT NULL THEN
                                	OPEN CUR_2 FOR V_SQL_O;
                                END IF;
                            END IF;
                        END IF;
                    --생리대
                    ELSIF SUBSTR(P_MACH_CD,1,3) = 'SRB' THEN
                        UPDATE TB_SCH013
                           SET PRD_END_DTM = TO_CHAR(V_PRD_END_DATE,'YYYYMMDDHH24MISS')
                             , COMP_YN = DECODE(NVL(PRFM_QTY,0), 0, 'N', 'Y')
                             , UPDDATE = V_DATE
                             , UPDID = P_USERID
                         WHERE 1=1
                           AND WRK_ORDR_NO = V_PRE_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_PRE_WRK_ORDR_SEQNO
                           AND COMP_YN != 'Y';
                        IF SQL%ROWCOUNT > 0 THEN
                            --생산 완료여부 확인
                            SELECT COUNT(COMP_YN)
                              INTO V_COMP_CNT
                              FROM TB_WRK001
                             WHERE 1=1
                               AND WERKS = P_WERKS
                               AND MACH_CD = P_MACH_CD
                               AND WRK_ORDR_NO = P_WRK_ORDR_NO
                               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                               AND COMP_YN ='Y';
                            IF V_COMP_CNT > 0 THEN
                                --생산실적 문서번호
                                V_DOC_NO := FN_GET_MDOCNO('M','IF133');
                                V_DOC_SEQ := '1';
                                V_OIF_ID := 'MES_IF_133';
                                P_ORDER_DOC := V_DOC_NO;
                                --생산이 완료된 지시의 경우 IF 추가
                                INSERT INTO TB_IFS011(AUFNR, LOTNO, MATNR, WERKS, WORKCENTERCODE, MACHINE, 
                                                    WORKGROUP, OPNAM, CONF, RUNTIME, PROQTY, MEINS, BUDAT, 
                                                    SDATE, STIME, EDATE, ETIME, 
                                                    MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                                            VALUES(P_ORDER_NO, V_BEF_LOT, P_MATNR, P_WERKS, V_SAP_WRK_CD, V_MACHINE, 
                                                    V_WRK_CLASS, P_USERID, 'X', '0', 0, V_UNIT, V_PRFM_DT, --FN_DT_FORMAT(P_PRD_END_DATE,'YYYYMMDD'),
                                                    TO_CHAR(V_ORDR_END_DATE,'YYYYMMDD'), TO_CHAR(V_ORDR_END_DATE,'HH24MISS'), 
                                                    TO_CHAR(V_ORDR_END_DATE,'YYYYMMDD'), TO_CHAR(V_ORDR_END_DATE,'HH24MISS'),
                                                    V_DOC_NO, V_DOC_SEQ, V_DATE, P_USERID);
                                --IF 전송이력(20:오더완료)
                                INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                                                    WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                                    IND_BCD, LOT_NO, ORDER_NO, CNL_YN,
                                                    REGDATE, REGID)
                                                VALUES(V_DOC_NO, TO_NUMBER(V_DOC_SEQ), 20,
                                                    P_WERKS, P_MACH_CD, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                                    ' ', V_BEF_LOT, P_ORDER_NO, 'N',
                                                    V_DATE, P_USERID);
                                --SAP FUNC ID
                                SELECT RFCFN
                                  INTO P_WRK_FUNC
                                  FROM TB_ITFMA
                                 WHERE 1=1
                                   AND IFID = V_OIF_ID;
                                --인터페이스 파라미터
                                OPEN CUR_1 FOR
                                SELECT V_OIF_ID AS I_IF_ID
                                     , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                                FROM dual;
                                --인터페이스 상세 파라미터
                                V_SQL_O := FN_IF_QUERY(V_OIF_ID, V_DOC_NO);
                                IF V_SQL_O IS NOT NULL THEN
                                	OPEN CUR_2 FOR V_SQL_O;
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                ELSIF V_IOTYPE = 'N' THEN
                    --합지기
                    IF SUBSTR(P_MACH_CD,1,3) = 'TAA' THEN
                        UPDATE TB_SCH011
                           SET PRD_END_DTM = TO_CHAR(V_PRD_END_DATE,'YYYYMMDDHH24MISS')
                             , COMP_YN = DECODE(NVL(PRFM_QTY,0), 0, 'N', 'Y')
                             , UPDDATE = V_DATE
                             , UPDID = P_USERID
                         WHERE 1=1
                           AND WRK_ORDR_NO = V_PRE_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_PRE_WRK_ORDR_SEQNO
                           AND COMP_YN != 'Y';
                        --완료정보 등록시
                        IF SQL%ROWCOUNT > 0 THEN
                            --생산실적 문서번호
                            V_DOC_NO := FN_GET_MDOCNO('M','IF123');
                            V_DOC_SEQ := '1';
                            V_OIF_ID := 'MES_IF_123';
                            P_ORDER_DOC := V_DOC_NO;
                            --작업지시 추가정보
                            SELECT PUPOS
                              INTO V_PUPOS
                              FROM TB_SCH011
                             WHERE 1=1
                               AND WRK_ORDR_NO = P_WRK_ORDR_NO
                               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
                            --인터테이스 테이블 등록
                            INSERT INTO TB_IFS001(AUFNR, LOTNO, PRDCD, WERKS, WORKCENTERCODE, MACHINE,
                                                    PRDDT, PRODT, WORKGROUP, LEADER, WORKER, PUPOS,
                                                    RUNTIME, PROQTY, SDATE, STIME, EDATE, ETIME, 
                                                    SCPAP, SAIP, CONF, SCRQTY,
                                                    MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                                            VALUES(P_ORDER_NO, V_BEF_LOT, P_MATNR, P_WERKS, V_SAP_WRK_CD, V_MACHINE,
                                                    V_PRFM_DT, V_PRD_DT, V_WRK_CLASS, P_USERID, P_USERID, V_PUPOS, '0', 0,
                                                    TO_CHAR(V_ORDR_END_DATE,'YYYYMMDD'), TO_CHAR(V_ORDR_END_DATE,'HH24MISS'), 
                                                    TO_CHAR(V_ORDR_END_DATE,'YYYYMMDD'), TO_CHAR(V_ORDR_END_DATE,'HH24MISS'),
                                                    'N', 'N', 'X', 0,
                                                    V_DOC_NO, 1, V_DATE, P_USERID);
                            --IF 전송이력(20:오더완료)
                            INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                                                WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                                IND_BCD, LOT_NO, ORDER_NO, CNL_YN,
                                                REGDATE, REGID)
                                            VALUES(V_DOC_NO, TO_NUMBER(V_DOC_SEQ), 20,
                                                P_WERKS, P_MACH_CD, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                                ' ', V_BEF_LOT, P_ORDER_NO, 'N',
                                                V_DATE, P_USERID);
                            --SAP FUNC ID
                            SELECT RFCFN
                              INTO P_WRK_FUNC
                              FROM TB_ITFMA
                             WHERE 1=1
                               AND IFID = V_OIF_ID;
                            --인터페이스 파라미터
                            OPEN CUR_1 FOR
                            SELECT V_OIF_ID AS I_IF_ID
                                 , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                            FROM dual;
                            --인터페이스 상세 파라미터
                            V_SQL_O := FN_IF_QUERY(V_OIF_ID, V_DOC_NO);
                            IF V_SQL_O IS NOT NULL THEN
                            	OPEN CUR_2 FOR V_SQL_O;
                            END IF;
                        END IF;
                    ELSE
                        UPDATE TB_SCH019
                           SET PRD_END_DTM = TO_CHAR(V_PRD_END_DATE,'YYYYMMDDHH24MISS')
                             , COMP_YN = DECODE(NVL(COMP_QTY, 0), 0, 'N', 'Y')
                             , UPDDATE = V_DATE
                             , UPDID = P_USERID
                         WHERE 1=1
                           AND WRK_ORDR_NO = V_PRE_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_PRE_WRK_ORDR_SEQNO
                           AND COMP_YN != 'Y';
                        --완료정보 등록시
                        IF SQL%ROWCOUNT > 0 THEN
                            --생산실적 문서번호
                            V_DOC_NO := FN_GET_MDOCNO('M','IF139');
                            V_DOC_SEQ := '1';
                            V_OIF_ID := 'MES_IF_141';
                            P_ORDER_DOC := V_DOC_NO;
                            --인터테이스 테이블 등록
                            INSERT INTO TB_IFS019(AUFNR, LOTNO, WERKS, BUDAT, MATNR, 
                                                    PROQTY, MEINS, RUNTIME, OPNAM, CONF, SDATE, STIME, EDATE, ETIME, 
                                                    MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                                            VALUES(P_ORDER_NO, V_BEF_LOT, P_WERKS, V_PRFM_DT, P_MATNR, --TO_CHAR(V_DATE,'YYYYMMDD'), P_MATNR, 
                                                    0, V_UNIT, '0', P_USERID, 'X',
                                                    TO_CHAR(V_ORDR_END_DATE,'YYYYMMDD'), TO_CHAR(V_ORDR_END_DATE,'HH24MISS'), 
                                                    TO_CHAR(V_ORDR_END_DATE,'YYYYMMDD'), TO_CHAR(V_ORDR_END_DATE,'HH24MISS'),
                                                    V_DOC_NO, 1, V_DATE, P_USERID);                                                 
                            --IF 전송이력(20:오더완료)
                            INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                                                WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                                IND_BCD, LOT_NO, ORDER_NO, CNL_YN,
                                                REGDATE, REGID)
                                            VALUES(V_DOC_NO, TO_NUMBER(V_DOC_SEQ), 20,
                                                P_WERKS, P_MACH_CD, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                                ' ', V_BEF_LOT, P_ORDER_NO, 'N',
                                                V_DATE, P_USERID);
                            --SAP FUNC ID
                            SELECT RFCFN
                              INTO P_WRK_FUNC
                              FROM TB_ITFMA
                             WHERE 1=1
                               AND IFID = V_OIF_ID;
                            --인터페이스 파라미터
                            OPEN CUR_1 FOR
                            SELECT V_OIF_ID AS I_IF_ID
                                 , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                            FROM dual;
                            --인터페이스 상세 파라미터
                            V_SQL_O := FN_IF_QUERY(V_OIF_ID, V_DOC_NO);
                            IF V_SQL_O IS NOT NULL THEN
                            	OPEN CUR_2 FOR V_SQL_O;
                            END IF;
                        END IF;
                    END IF;
                END IF;
            END IF;
            --오더완료 인터페이스 미사용시 DATASET 위치 조정
            IF CUR_1%ISOPEN = FALSE THEN
                OPEN CUR_1 FOR SELECT 1 FROM dual;
            END IF;
            IF CUR_2%ISOPEN = FALSE THEN
                OPEN CUR_2 FOR SELECT 1 FROM dual;
            END IF;
        END IF;
        --작업 정상 종료 코드 등록
        RS_CODE := 'S';
        RS_MSG := '1';
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
END SP_POP_WRK41_U02;

/
