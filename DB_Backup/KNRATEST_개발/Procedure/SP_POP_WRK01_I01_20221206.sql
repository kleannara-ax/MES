--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK01_I01_20221206
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK01_I01_20221206" 
(
    P_WERKS         IN VARCHAR2         --플랜트
    ,P_MACH_CD      IN VARCHAR2         --설비코드
    ,P_IND_BCD      IN VARCHAR2         --개별바코드
    ,P_STOR_LOC_CD  IN VARCHAR2         --저장위치
    ,P_USERID       IN VARCHAR2         --
    ,P_EXCEPTION    IN VARCHAR2         --
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK01
 * PROGRAM NAME  : 공정투입
 * VERSION       : 1.0.0
 * DESCRIPTION   : 선택된 작업자 정보를 저장한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/04/21
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/23    1.0.0   김병무         Initial Version 
 *==============================================================================
 *  관련 테이블
 * - [TB_INV003] : (C...) 자재투입 (TB_INV001에 있는 반제품을 투입)
 * - [TB_INV001] : (.RU.) 창고별 재고 관리
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM            VARCHAR2(100)  := 'SP_POP_WRK01_I01';
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
    
    V_IN_MR_YN          TB_INV001.IN_MR_YN%TYPE;
    V_WRK_ORDR_NO       TB_SCH016.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO    TB_SCH016.WRK_ORDR_SEQNO%TYPE;
    
BEGIN
    --예외처리 시작(try)
    BEGIN
        V_DMY := 0 ;
        BEGIN
            SELECT 1, MACH_CD
              INTO V_DMY , V_MACH_CD
              FROM TB_INV003
             WHERE WERKS    = P_WERKS 
               AND IND_BCD  = P_IND_BCD
               AND ROWNUM = 1
             ;  
        EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_DMY := 0 ;
        END;

        IF V_DMY > 0  THEN
                SELECT MACH_NM INTO V_MACH_NM
                          FROM TB_MAS012
                         WHERE MACH_CD = V_MACH_CD;        
        
                    RS_CODE := 'E';
                    RS_MSG := V_MACH_NM ||'에 투입된 개별바코드 입니다.\n투입 할수 없습니다.';
                    ROLLBACK;
                    RETURN;
        END IF ;
    
        IF P_STOR_LOC_CD = '2700' THEN      -- 재단
            SELECT NVL(IN_MR_YN, 'N')
                INTO V_IN_MR_YN
                FROM TB_INV001
             WHERE WERKS        = P_WERKS
               AND IND_BCD      = P_IND_BCD;
            
            IF V_IN_MR_YN = 'Y' THEN
                SELECT S016.WRK_ORDR_NO, S016.WRK_ORDR_SEQNO
                    INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO
                    FROM TB_INV001 I001
                      , TB_SCH016 S016
                    WHERE I001.LOT_NO = S016.ORDER_NO
                      AND I001.IND_BCD = P_IND_BCD
                      ;
            END IF;
            
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
                DECODE(V_IN_MR_YN, 'N', I001.WRK_ORDR_NO, V_WRK_ORDR_NO),
                DECODE(V_IN_MR_YN, 'N', I001.WRK_ORDR_SEQNO, V_WRK_ORDR_SEQNO),
                1,
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
             WHERE I001.WERKS        = P_WERKS
               AND I001.STOR_LOC_CD  = P_STOR_LOC_CD
               AND I001.IND_BCD      = P_IND_BCD;
        
            SELECT LOT_NO
                INTO V_LOT_NO
              FROM TB_INV001
             WHERE WERKS = P_WERKS
               AND IND_BCD = P_IND_BCD;
               
            SELECT WCS_WRK_CD INTO V_WCS_WRK_CD
              FROM TB_MAS012
             WHERE MACH_CD = P_MACH_CD;
             
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
                                    'I',
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
        ELSIF P_STOR_LOC_CD = 'L2600' OR  P_STOR_LOC_CD = 'L2500' THEN      -- 포장,적재소
            INSERT INTO TB_INV003( WERKS,
                                    MACH_CD,
                                    MATNR,
                                    IND_BCD,
                                    WRK_ORDR_NO,
                                    WRK_ORDR_SEQNO,
                                    SEQNO,
                                    INP_DT,     
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
                                    PRE_IN_QTY,
                                    EXCEPTION)
            SELECT I001.WERKS,
                P_MACH_CD,
                I001.MATNR,
                I001.IND_BCD,    /*P_IND_BCD,*/
                I001.WRK_ORDR_NO,
                I001.WRK_ORDR_SEQNO,
                1,
                TO_CHAR(V_DATE, 'YYYYMMDD'),    
                DECODE(I001.UNIT ,'R', I001.STCK_QTY, I001.STCK_QTY/500),
                0,
                DECODE(I001.UNIT ,'R', I001.STCK_QTY, I001.STCK_QTY/500),
                DECODE(I001.UNIT ,'R', 'R', 'R'),
                I001.ROLLCNT,
                I001.WGT,
                'N',
                I001.STCK_KY,
                I001.LOT_NUM,
                I001.LOT_NO,
                V_DATE,
                V_SESS_USER_ID,
                DECODE(I001.UNIT ,'R', I001.STCK_QTY, I001.STCK_QTY/500),
                P_EXCEPTION
              FROM TB_INV001 I001
             WHERE I001.WERKS        = P_WERKS
               AND I001.IND_BCD      = P_IND_BCD;
        ELSIF P_STOR_LOC_CD = 'L2400'  THEN      -- 수재단
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
                                    PRE_IN_QTY )
            SELECT I001.WERKS,
                P_MACH_CD,
                I001.MATNR,
                I001.IND_BCD  , --P_IND_BCD,
                I001.WRK_ORDR_NO,
                I001.WRK_ORDR_SEQNO,
                1,
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
             WHERE I001.WERKS        = P_WERKS
               --AND I001.STOR_LOC_CD  = P_STOR_LOC_CD           --
               AND I001.IND_BCD      = P_IND_BCD;        
        ELSE
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
                                    PRE_IN_QTY )
            SELECT I001.WERKS,
                P_MACH_CD,
                I001.MATNR,
                I001.IND_BCD  , --P_IND_BCD,
                I001.WRK_ORDR_NO,
                I001.WRK_ORDR_SEQNO,
                1,
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
             WHERE I001.WERKS        = P_WERKS
               --AND I001.STOR_LOC_CD  = P_STOR_LOC_CD           --
               AND I001.IND_BCD      = P_IND_BCD;
        END IF;

        --재고 수량 업데이트
        -- 문제재기 적재소 인경우 부적합처리여부(UCFMTY_FLG) 에 'Y' 처리함.
        IF P_STOR_LOC_CD = 'L2500' THEN
            UPDATE TB_INV001 I001
               SET I001.STCK_QTY = 0
                , I001.STCK_STA = '10'
                , I001.UCFMTY_FLG = 'Y'     -- 문제재기 적재소 인경우 부적합처리여부(UCFMTY_FLG) 에 'Y' 처리함.
                , I001.UPDDATE = V_DATE
                , I001.UPDID = V_SESS_USER_ID
             WHERE I001.WERKS = P_WERKS
               AND I001.IND_BCD = P_IND_BCD; 
        ELSE
            UPDATE TB_INV001 I001
               SET I001.STCK_QTY = 0
                , I001.STCK_STA = '10'
                , I001.UPDDATE = V_DATE
                , I001.UPDID = V_SESS_USER_ID
             WHERE I001.WERKS = P_WERKS
               AND I001.IND_BCD = P_IND_BCD; 
        END IF;      
        
        UPDATE TB_INV001
           SET STCK_QTY = 0
         WHERE IND_BCD = P_IND_BCD ;

        UPDATE TB_WRK002
           SET STA = '10'
         WHERE IND_BCD = P_IND_BCD ;
        
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
