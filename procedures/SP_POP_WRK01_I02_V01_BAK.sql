
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK01_I02_V01_BAK" 
(
    P_WERKS         IN VARCHAR2         --플랜트
--    ,P_PROC_CD      IN VARCHAR2         --공정코드 (JA, MA, CA, PB_PC ...)
    ,P_MACH_CD      IN VARCHAR2         --설비코드
    ,P_IND_BCD      IN VARCHAR2         --개별바코드
    ,P_STOR_LOC_CD  IN VARCHAR2         --저장위치
    ,P_USERID       IN VARCHAR2         --
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK01_I02
 * PROGRAM NAME  : 공정투입취소
 * VERSION       : 1.0.0
 * DESCRIPTION   : 선택된 작업자 정보를 저장한다.
 *                 
 * AUTHOR NAME   : 박충식
 * CREATE DATE   : 2022/07/12
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/23    1.0.0   박충식         Initial Version 
 * - 2022.10.25           한동규         밀롤만 사용, 공정투입취소할경우 작업지시 초기화
 *==============================================================================
 *  관련 테이블
 * - [TB_INV003] : (C...) 자재투입 (TB_INV001에 있는 반제품을 투입)
 * - [TB_INV001] : (.RU.) 창고별 재고 관리
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM            VARCHAR2(100)  := 'SP_POP_WRK01_I02';
    V_PLT_CD            VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID      VARCHAR2(20) := P_USERID;
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER    EXCEPTION;
    E_SQL_ERR_CD        NUMBER(5) := 0;
    E_SQL_ERR_MSG       VARCHAR2(4000);

    --파리미터 처리
    --내부변수 처리
    V_DOC_NO            TB_IFSWC007.DOC_NO%TYPE;
    V_DOC_SEQNO         TB_IFSWC007.DOC_NOSEQ%TYPE;
    V_LOT_NO            TB_INV001.LOT_NO%TYPE;
    V_WCS_WRK_CD        TB_MAS012.WCS_WRK_CD%TYPE;
    V_DATE              DATE := SYSDATE;
    V_IN_QTY            TB_INV003.IN_QTY%TYPE;     --투입수량
    V_MACH_CNT          NUMBER(5); -- 가동상태 
    V_CHK_PERF             VARCHAR2(1) ;
BEGIN
    --예외처리 시작(try)
    V_CHK_PERF := '0';

    BEGIN   
    --2022.10.20 한동규 추가 대기중 설비상태 체크 대기중일때 공정투입 취소하면 WRK011 초기화
    SELECT COUNT(W011.MACH_STA) INTO V_MACH_CNT
      FROM TB_INV003 I003
         , TB_WRK011 W011
     WHERE 1=1
       AND W011.WERKS       = I003.WERKS
       AND W011.MACH_CD     = I003.MACH_CD
       AND W011.WRK_ORDR_NO = I003.WRK_ORDR_NO
       AND W011.WRK_ORDR_SEQNO = I003.WRK_ORDR_SEQNO
       AND W011.MACH_STA    = 'N'
       AND I003.WERKS       = P_WERKS
       AND I003.MACH_CD     = P_MACH_CD
       AND I003.IND_BCD     = P_IND_BCD;
    END;

    IF V_MACH_CNT = '1' THEN
             UPDATE TB_WRK011
				SET PRE_WRK_ORDR_NO = '',
					PRE_WRK_ORDR_SEQNO = '',
					MATNR = '',
					WRK_ORDR_NO = '', 
					WRK_ORDR_SEQNO = '',
					ORDER_NO = '',
					LOT_NO = '',
					PRD_STR_DTM = ''
					--RUN_STA = V_RUN_STA
			 WHERE WERKS = P_WERKS
			   AND MACH_CD = P_MACH_CD;
    END IF;    


    -- WRK011(작업장(설비)별 현재 진행현황)에 선택된 개별바코드 인지 확인
    SELECT COUNT(W011.WRK_ORDR_NO)
      INTO V_CHK_PERF
      FROM TB_INV003 I003
         , TB_WRK011 W011
     WHERE 1=1
       AND W011.WERKS       = I003.WERKS
       AND W011.MACH_CD     = I003.MACH_CD
       AND W011.WRK_ORDR_NO = I003.WRK_ORDR_NO
       AND W011.WRK_ORDR_SEQNO = I003.WRK_ORDR_SEQNO
       AND I003.WERKS       = P_WERKS
       AND I003.MACH_CD     = P_MACH_CD
       AND I003.IND_BCD     = P_IND_BCD;

    IF V_CHK_PERF = '1' THEN
            RS_CODE      := 'E';
            RS_MSG       := '작업지시를 선택하였습니다.\n\n투입취소를 할수 없습니다.';
            --RS_MSG       := '작업지시가 가동중입니다.\n\n투입취소를 할수 없습니다.';
            ROLLBACK;
            RETURN;
    END IF;



    V_CHK_PERF := '0' ;
    -- 투입이력이 있는지 확인
    BEGIN
        SELECT '1'
          INTO V_CHK_PERF  
          FROM TB_INV010  INV010    --자재투입이력		
         WHERE WERKS        =  P_WERKS
           AND IND_BCD_M    =  P_IND_BCD
           --AND SDOC_NO      IS NOT NULL
           AND NVL(CNL_YN,'N') = 'N'
           AND ROWNUM = 1
         ;  
    EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_CHK_PERF := '0';
                WHEN OTHERS THEN
                    V_CHK_PERF := '0';
    END;


    IF V_CHK_PERF = '1'  THEN
            RS_CODE      := 'E';
            RS_MSG       := '실적 입고되어 투입취소를 할수 없습니다.';
            ROLLBACK;
            RETURN;
    END IF;

    V_IN_QTY := 0 ;

    BEGIN
        SELECT /*IN_QTY*/  PRE_IN_QTY
          INTO V_IN_QTY  
          FROM TB_INV003  INV010    --투입자재사용(실적발생시)		
         WHERE WERKS      =  P_WERKS
           AND IND_BCD    =  P_IND_BCD
         ;  
    EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_IN_QTY := 0;
                WHEN OTHERS THEN
                    V_IN_QTY := 0;
    END;

    IF  V_IN_QTY = 0 THEN
           RS_CODE      := 'E';
            RS_MSG       := '투입 수량이 없습니다.';
            ROLLBACK;
            RETURN;

    END IF ;

    --TB_INV003 자재투입 삭제
    DELETE TB_INV003  
    WHERE WERKS      =  P_WERKS
      AND IND_BCD    =  P_IND_BCD
         ;  

    --TB_INV010  삭제
    /*DELETE TB_INV010  
     WHERE WERKS        =  P_WERKS
       AND IND_BCD_M    =  P_IND_BCD
         ;  */
         
    UPDATE TB_INV010   SET CNL_YN = 'Y'
     WHERE WERKS        =  P_WERKS
       AND IND_BCD_M    =  P_IND_BCD
         ;  

         

    --TB_INV001  UPDATE 
    -- 문제재기 적재소 인경우 부적합처리여부(UCFMTY_FLG) 에 'N' 처리함.
    IF P_STOR_LOC_CD = 'L2500'  THEN
        UPDATE TB_INV001 I001
           SET I001.STCK_QTY = V_IN_QTY * 500
            , I001.STCK_STA = '40'
            , I001.UCFMTY_FLG = 'N'     -- 문제재기 적재소 인경우 부적합처리여부(UCFMTY_FLG) 에 'N' 처리함.
            , I001.UPDDATE = V_DATE
            , I001.UPDID   = V_SESS_USER_ID
         WHERE I001.WERKS = P_WERKS
           AND I001.IND_BCD = P_IND_BCD; 
    --포장
    ELSIF P_STOR_LOC_CD = 'L2600'  THEN
        UPDATE TB_INV001 I001
           SET I001.STCK_QTY =  DECODE(I001.UNIT, 'R',V_IN_QTY,   V_IN_QTY * 500)
            , I001.STCK_STA = '00'
            , I001.UPDDATE = V_DATE
            , I001.UPDID   = V_SESS_USER_ID
         WHERE I001.WERKS = P_WERKS
           AND I001.IND_BCD = P_IND_BCD; 

    ELSE
        UPDATE TB_INV001 I001
           SET I001.STCK_QTY = V_IN_QTY 
            , I001.STCK_STA = '00'
            , I001.UPDDATE = V_DATE
            , I001.UPDID   = V_SESS_USER_ID
         WHERE I001.WERKS = P_WERKS
           AND I001.IND_BCD = P_IND_BCD; 
    END IF;

    IF P_STOR_LOC_CD = '2700' THEN
        SELECT WCS_WRK_CD INTO V_WCS_WRK_CD
          FROM TB_MAS012
         WHERE MACH_CD = P_MACH_CD;

        SELECT LOT_NO INTO V_LOT_NO
          FROM TB_INV001
         WHERE WERKS = P_WERKS
           AND IND_BCD = P_IND_BCD;

        V_DOC_NO := FN_GET_MDOCNO('M','IF207');
        V_DOC_SEQNO := 1;

        INSERT INTO TB_IFSWC007(DOC_NO,
                                DOC_NOSEQ,
                                IND_BCD,
                                LOT_NO,
                                CT_LOT_NO,
                                WERKS,
                                MCHN_NO,
                                PRCS_NO,
                                FCLT_CD,
                                WORK_DT,
                                STA,
                                REGDATE,
                                REGID,
                                REMARK1,
                                REMARK2,
                                REMARK3,
                                REMARK4,
                                REMARK5,
                                REMARK6,
                                REMARK7,
                                REMARK8,
                                REMARK9,
                                REMARK10,
                                IF_STATUS,
                                IF_GET_DATE)
                       VALUES( V_DOC_NO,
                                V_DOC_SEQNO,
                                P_IND_BCD,
                                V_LOT_NO,
                                ' ',
                                P_WERKS,
                                'PM3',
                                'C',
                                V_WCS_WRK_CD,
                                TO_CHAR(V_DATE, 'YYYYMMDD'),             --투입일자
                                'R',
                                V_DATE,
                                V_SESS_USER_ID,
                                '',
                                '',
                                '',
                                '',
                                '',
                                '',
                                '',
                                '',
                                '',
                                '',
                                'N',
                                V_DATE);
        END IF;

        UPDATE TB_WRK002
           SET STA = '00'
         WHERE IND_BCD = P_IND_BCD;

        --작업 정상 종료 코드 등록
        RS_CODE := 'S';
        COMMIT;

    --예외처리(catch)
    EXCEPTION
    WHEN dup_val_on_index THEN
         RS_CODE := 'E';
         RS_MSG  := SQLERRM;
         RETURN;
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
        RAISE;
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    --END;
END;
/
