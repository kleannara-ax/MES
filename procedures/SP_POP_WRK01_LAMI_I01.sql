
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK01_LAMI_I01" SP_POP_WRK01_LAMI_I01
(
    P_WERKS             IN VARCHAR2         --플랜트
    ,P_MACH_CD          IN VARCHAR2         --설비코드
    ,P_IND_BCD      IN VARCHAR2         --개별바코드
    ,P_WRK_ORDR_NO      IN VARCHAR2         --개별바코드
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2         --저장위치
    ,P_USERID           IN VARCHAR2         --
    ,P_EXCEPTION        IN VARCHAR2         --
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : 슬리팅
 * PROGRAM NAME  : 공정투입
 * VERSION       : 1.0.0
 * DESCRIPTION   : 선택된 자재정보를 저장한다.
 *                 
 * AUTHOR NAME   : 김수현
 * CREATE DATE   : 2022/12/24
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/12/24    1.0.0   김수현         Initial Version 
 *==============================================================================
 *  관련 테이블
 * - [TB_INV003] : (C...) 자재투입 (TB_INV001에 있는 반제품을 투입)
 * - [TB_INV001] : (.RU.) 창고별 재고 관리
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM            VARCHAR2(100)  := 'SP_POP_WRK01_LAMI_I01';
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
    V_DMY               NUMBER(5) := 0;
    V_MACH_CD           TB_INV003.MACH_CD%TYPE;
    V_MACH_NM           TB_MAS012.MACH_NM%TYPE;

--    V_IN_MR_YN          TB_INV001.IN_MR_YN%TYPE;
    V_WRK_ORDR_NO       TB_INV001.WRK_ORDR_NO%TYPE;
--    V_WRK_ORDR_SEQNO    TB_SCH016.WRK_ORDR_SEQNO%TYPE;
    V_STCK_STA          VARCHAR2(100);
    V_CNT1              NUMBER(10);
    V_ORDER_QTY         TB_SCH020.ORDER_BOM_QTY%TYPE;
    V_INPUT_QTY         TB_SCH020.ORDER_BOM_QTY%TYPE;
	V_I003_MAXSEQ		NUMBER;
	V_MATNR				VARCHAR2(50);
BEGIN
    --예외처리 시작(try)
    BEGIN
	    SELECT	MATNR INTO V_MATNR
	    FROM	TB_INV001
	    WHERE	WERKS = P_WERKS
	    AND		IND_BCD = P_IND_BCD;

	    SELECT	NVL(MAX(SEQNO), 0) + 1 INTO V_I003_MAXSEQ
	    FROM	TB_INV003
	    WHERE	WERKS = P_WERKS
	    AND		MACH_CD = P_MACH_CD
	    AND		MATNR = V_MATNR;

	    -- 포장, 문제제품적재소 에서 공정 투입할때 체크 부분 추가
--        IF P_STOR_LOC_CD = 'L2600' OR P_STOR_LOC_CD = 'L2500' THEN
            V_STCK_STA := '';    
            SELECT COUNT(B.STCK_STA)
            INTO V_CNT1
            FROM TB_INV003 A
            INNER JOIN TB_INV001 B ON A.WERKS = B.WERKS AND A.MACH_CD = B.MACH_CD AND A.IND_BCD = B.IND_BCD
            WHERE 1 = 1
            AND A.WERKS = P_WERKS              
            AND A.IND_BCD = P_IND_BCD
            AND A.WRK_ORDR_NO = P_WRK_ORDR_NO 
            AND A.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO 
            ;
          
            IF V_CNT1 > 0 THEN
                 RS_CODE := 'E';
                 RS_MSG := '이미 투입된 번호 입니다.('||P_IND_BCD||')' ;
                 RETURN;
            END IF;
          
            IF V_CNT1 > 0 THEN
                SELECT B.STCK_STA 
                INTO V_STCK_STA 
                FROM TB_INV003 A
                INNER JOIN TB_INV001 B ON A.WERKS = B.WERKS AND A.MACH_CD = B.MACH_CD AND A.IND_BCD = B.IND_BCD
                WHERE 1 = 1
                AND A.WERKS = P_WERKS  
                AND A.WRK_ORDR_NO = P_WRK_ORDR_NO 
                AND A.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO 
                ;

                IF V_STCK_STA <> '00' THEN
                       RS_CODE := 'E';
                       RS_MSG := '이미 투입 완료 되어 투입 할 수 없습니다.('||P_IND_BCD||')' ;
                       RETURN;
                END IF;
            END IF;

                
            SELECT LOT_NO
                INTO V_LOT_NO
              FROM TB_INV001
             WHERE WERKS = P_WERKS
               AND IND_BCD = P_IND_BCD;

           -- BOM 투입지시량
--           SELECT
--            ORDER_BOM_QTY INTO V_ORDER_QTY
--           FROM TB_SCH020 A
--            WHERE A.WERKS = P_WERKS  
--            AND A.WRK_ORDR_NO = P_WRK_ORDR_NO 
--            AND A.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
--            AND A.LOT_NO = V_LOT_NO;
            
           -- 투입량 + 기투입량
           SELECT
            STCK_QTY + NVL(( SELECT SUM(A.IN_QTY)
                    FROM TB_INV003 A
                    INNER JOIN TB_INV001 B ON A.WERKS = B.WERKS AND A.MACH_CD = B.MACH_CD AND A.IND_BCD = B.IND_BCD
                    WHERE 1 = 1
                    AND A.WERKS = P_WERKS  
                    AND A.WRK_ORDR_NO = P_WRK_ORDR_NO 
                    AND A.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO ),0)            
            INTO V_INPUT_QTY
           FROM TB_INV001 A
            WHERE A.WERKS = P_WERKS  
            AND A.IND_BCD = P_IND_BCD;
            
--          IF  V_INPUT_QTY > V_ORDER_QTY THEN
--            RS_CODE := 'E';
--            RS_MSG := '투입지시량('||V_ORDER_QTY||') 보다 투입총량('||V_INPUT_QTY||')이 많습니다' ;
--            RETURN;
--          END IF;

        -- 정규생산인경우 체크
        V_WRK_ORDR_NO := ' ';
--        BEGIN        
--            SELECT WRK_ORDR_NO 
--                INTO V_WRK_ORDR_NO 
--                  FROM TB_INV001 I001
--                 WHERE I001.WERKS        = P_WERKS
--                   AND I001.STOR_LOC_CD  = P_STOR_LOC_CD
--                   AND I001.IND_BCD      = P_IND_BCD;
--        EXCEPTION
--            WHEN NO_DATA_FOUND THEN
--                V_WRK_ORDR_NO := ' ';
--        END;

        -- 정규생산인경우 체크
--        IF SUBSTR(V_WRK_ORDR_NO,1,4)  <> 'WOEX' THEN
--            V_DMY := 0 ;
--            BEGIN
--                SELECT 1, MACH_CD
--                  INTO V_DMY , V_MACH_CD
--                  FROM TB_INV003
--                 WHERE WERKS    = P_WERKS 
--                   AND IND_BCD  = P_IND_BCD
--                   AND ROWNUM = 1
--                 ;  
--            EXCEPTION
--                WHEN NO_DATA_FOUND THEN
--                    V_DMY := 0 ;
--            END;
--    
--            IF V_DMY > 0  THEN
--                SELECT MACH_NM INTO V_MACH_NM
--                          FROM TB_MAS012
--                         WHERE MACH_CD = V_MACH_CD;        
--        
--                    RS_CODE := 'E';
--                    RS_MSG := V_MACH_NM ||'에 투입된 개별바코드 입니다.\n투입 할수 없습니다.';
--                    ROLLBACK;
--                    RETURN;
--            END IF ;
--        END IF;

            INSERT INTO TB_INV003( WERKS,
                                    MACH_CD,
                                    MATNR,
                                    IND_BCD,
                                    WRK_ORDR_NO,
                                    WRK_ORDR_SEQNO,
                                    SEQNO,
                                    INP_DT,     -- 투입일자 추가 2022-06-03
                                    IN_QTY,
                                    USE_QTY,
                                    STCK_QTY,
                                    UNIT,
                                    ROLLCNT,
                                    WGT,
                                    CHG_FLG,
                                    STCK_KY,
                                    LOT_NUM,
                                    LOT_NO,
                                    REGDATE,
                                    REGID,
                                    PRE_IN_QTY)
            SELECT I001.WERKS,
                P_MACH_CD,
                I001.MATNR,
                I001.IND_BCD, --P_IND_BCD,
                P_WRK_ORDR_NO,
                P_WRK_ORDR_SEQNO,
                V_I003_MAXSEQ,
--                1,
                TO_CHAR(V_DATE, 'YYYYMMDD'),     -- 투입일자 추가 2022-06-03
                I001.STCK_QTY,
                0,
                I001.STCK_QTY,
                I001.UNIT,
                I001.ROLLCNT,
                I001.WGT,
                'N',
                I001.STCK_KY,
                I001.LOT_NUM,
                I001.LOT_NO,
                V_DATE,
                V_SESS_USER_ID,
                I001.STCK_QTY
              FROM TB_INV001 I001
             WHERE I001.WERKS = P_WERKS
             --  AND I001.MACH_CD = P_MACH_CD
               AND I001.IND_BCD = P_IND_BCD;

            SELECT LOT_NO
                INTO V_LOT_NO
              FROM TB_INV001
             WHERE WERKS = P_WERKS
               AND IND_BCD = P_IND_BCD;

            UPDATE TB_INV001 I001
               SET I001.STCK_QTY = 0
                , I001.STCK_STA = '10'
                , I001.UPDDATE = V_DATE
                , I001.UPDID = V_SESS_USER_ID
             WHERE I001.WERKS = P_WERKS
               AND I001.IND_BCD = P_IND_BCD; 

--        UPDATE TB_WRK002
--           SET STA = '10'
--         WHERE 1 = 1
--         AND WRK_ORDR_NO = WRK_ORDR_NO 
--         AND WRK_ORDR_SEQNO = WRK_ORDR_SEQNO
--         ;

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
    END;
END;
/
