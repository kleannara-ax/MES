--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK30_I04_20221109
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK30_I04_20221109" 
(
     P_WERKS     		IN VARCHAR2 	                --플랜트
    ,P_MACH_CD   		IN VARCHAR2 	                --설비코드
    ,P_IND_BCD_LIST     IN CLOB			   	            --개별바코드 리스트
    ,P_CNL_RMK          IN VARCHAR2 	                --취소내용
    ,P_USERID           IN VARCHAR2                     --USER ID
    ,RS_PRFM_RFCFN      OUT VARCHAR2                    --실적 RFCFN값
    ,RS_DISPO_RFCFN     OUT VARCHAR2                    --폐품 RFCFN값    
    ,RS_INPUT_RFCFN     OUT VARCHAR2                    --투입량 RFCFN값   
    ,RS_SDISPO_RFCFN    OUT VARCHAR2                    --영업+잔량 폐품 RFCFN값    
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
    ,CUR_1              OUT SYS_REFCURSOR               --실적
    ,CUR_2              OUT SYS_REFCURSOR
    ,CUR_3              OUT SYS_REFCURSOR               --폐품
    ,CUR_4              OUT SYS_REFCURSOR
    ,CUR_5              OUT SYS_REFCURSOR               --투입량
    ,CUR_6              OUT SYS_REFCURSOR
    ,CUR_7              OUT SYS_REFCURSOR               --잔량
    ,CUR_8              OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK30_I03{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 슬리터실적취소 
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : .{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박충식{최초 작성자 명 기술}
 * CREATE DATE   : 2022/07/13 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/06/20    1.0.0   박충식         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_WRK011] : (.RU.) 설비별 현재진행사항 
 *       - [TB_WRK012] : (C.U.) 설비별 현재진행사항 
 *       - [TB_SCH016] : (.R..) 밀롤,슬리터 작업지지서
 *=============================================================================*/

AS 
    --프로그램 ID : 슬리터 실적등록
    V_PRG_NM         VARCHAR2(100) := 'SP_POP_WRK30_I04'; -- PROCEDURE NAME
    V_PLT_CD         VARCHAR2(2)   := '99';      --PLANTCODE TEST
    V_SESS_USER_ID   VARCHAR2(20)  := P_USERID;  --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_OBJECT_T;
    V_OBJ            JSON_OBJECT_T;
    --parameter변수 처리
    V_WERKS                 TB_WRK002.WERKS%TYPE;        --플랜트코드    
    V_MACH_CD               TB_WRK002.MACH_CD%TYPE;      --설비코드  
    V_IND_BCD               TB_WRK002.IND_BCD%TYPE;      --개별바코드
    V_ORDER_NO              TB_WRK002.ORDER_NO%TYPE;
    V_STA                   TB_WRK002.STA%TYPE;
    V_SDOC_NO               TB_WRK002.SDOC_NO%TYPE;
    V_SDOC_SEQNO            TB_WRK002.SDOC_SEQNO%TYPE;
    V_SAP_WRK_CD            TB_MAS012.SAP_WRK_CD%TYPE;
    V_ROLLCNT	            TB_WRK002.ROLLCNT%TYPE;		 --권치수
    V_PRFM_QTY	            TB_WRK002.PRFM_QTY%TYPE;     --실적수량
    V_DISPO_QTY	            TB_WRK002.PRFM_QTY%TYPE;     --폐품수량
    V_IND_BCD_M             TB_WRK002.IND_BCD%TYPE;      --자재개별바코드
    V_PRE_ORDER_NO          TB_WRK002.ORDER_NO%TYPE;
    V_MRLDCK                TB_WRK002.MRLDCK%TYPE;       --밀롤창고적치여부
    V_STOR_LOC_CD           TB_INV001.STOR_LOC_CD%TYPE;
    V_INP_DT	            TB_INV003.INP_DT%TYPE;       --투입일자
    V_MATNR                 TB_WRK004.MATNR%TYPE;        --자재코드
    V_MATNR_M               TB_WRK004.MATNR%TYPE;        --자재코드
    V_LOT_NO_M              TB_WRK004.LOT_NO_M%TYPE;
    V_DISPO_WGT             TB_WRK004.WGT%TYPE;          --폐품중량
    V_YMCHK                 TB_MAS011.YMCHK%TYPE;        --실적등록 가능 여부
    V_WRK_ORDR_NO           TB_SCH015.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO        TB_SCH015.WRK_ORDR_SEQNO%TYPE;
    V_WRK_ORDR_NO1          TB_SCH015.WRK_ORDR_NO%TYPE;         
    V_WRK_ORDR_SEQNO1       TB_SCH015.WRK_ORDR_SEQNO%TYPE;     
    V_WRK_ORDR_NO2          TB_SCH015.WRK_ORDR_NO%TYPE;         
    V_WRK_ORDR_SEQNO2       TB_SCH015.WRK_ORDR_SEQNO%TYPE;     
    V_SHEET                 TB_SCH016.SHEET%TYPE;         --판지구분
    V_SLITER                TB_SCH016.SLITER%TYPE;        --SLITER 구분

    V_DOC_NO                VARCHAR2(20);
    V_DATE                  DATE := SYSDATE;
    V_DOC_SEQNO             NUMBER;
    V_PRFM_DT               VARCHAR2(20);   
    V_LOT_NO                VARCHAR2(20);   
    V_DOC_NO_DISPO_S1       VARCHAR2(20);
    V_DOC_NO_DISPO_S2       VARCHAR2(20);
    V_DOC_SEQNO_DISPO       NUMBER;
    V_TOT_QTY               NUMBER(13,3);
    V_DMY                   VARCHAR2(5);
    V_SQL                   VARCHAR2(4000);

BEGIN
  BEGIN

    V_JSON := JSON_OBJECT_T.parse(P_IND_BCD_LIST);
    V_ARR_LIST := V_JSON.get_array('list'); 

    FOR i IN 0..V_ARR_LIST.get_size-1 LOOP    
        V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
        V_OBJ           := TREAT (V_OBJ.get ('map') AS json_object_t);
        V_IND_BCD       := V_OBJ.get_string('IND_BCD');

        -- 실적 취소------------------------------------------------------------
        BEGIN
                SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, STA, SDOC_NO, SDOC_SEQNO, PRFM_QTY, ROLLCNT, LOT_NO, MRLDCK,PRFM_DT
                  INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, V_STA, V_SDOC_NO, V_SDOC_SEQNO,
                       V_PRFM_QTY, V_ROLLCNT, V_LOT_NO, V_MRLDCK,V_PRFM_DT
                  FROM TB_WRK002
                 WHERE WERKS   = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IND_BCD = V_IND_BCD
                   --AND NVL(CNL_YN,'N') = 'N'
                   ;
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_ROLLCNT := 0;
                WHEN OTHERS THEN
                    V_ROLLCNT := 0;
        END;

        BEGIN
                SELECT STCK_STA
                  INTO V_DMY
                  FROM TB_INV001
                 WHERE WERKS   = P_WERKS
                   AND IND_BCD = V_IND_BCD
                   AND ROWNUM  = 1
                   ;
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_DMY := 'N';
                WHEN OTHERS THEN
                    V_DMY := 'N';
        END;        

        IF V_DMY = '10'   THEN
           RS_CODE := 'E';
           RS_MSG  := '후공정에 투입되어 실적취소를 할 수 없습니다.';
           ROLLBACK;
           RETURN;
        END IF ;

        BEGIN
            SELECT STOR_LOC_CD INTO V_STOR_LOC_CD
              FROM TB_INV001
             WHERE WERKS   = P_WERKS
               AND IND_BCD = V_IND_BCD;

            IF NVL(V_MRLDCK, 'N') = 'Y' AND NVL(V_STOR_LOC_CD, ' ') = '2500' THEN
                RS_CODE := 'E';
                RS_MSG  := '밀롤창고에 입고되어 실적취소를 할수 없습니다.';
                ROLLBACK;
                RETURN;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                    V_STOR_LOC_CD := '';
            WHEN OTHERS THEN
                V_STOR_LOC_CD := '';
        END;

        BEGIN
                SELECT ORDER_NO, SHEET, SLITER
                  INTO V_ORDER_NO, V_SHEET, V_SLITER
                  FROM TB_SCH016
                 WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                   AND NVL(USE_YN,'Y') = 'Y' 
                   ;
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_ORDER_NO := '';
                WHEN OTHERS THEN
                    V_ORDER_NO := '';
        END;

        IF V_ROLLCNT > 0 THEN

                IF V_SDOC_NO IS NULL  THEN
                   RS_CODE      := 'E';
                   RS_MSG       := 'SAP 인터페이스 실패한 실적 입니다.';
                   ROLLBACK;
                   RETURN;
                END IF ;

                UPDATE TB_SCH016
                   SET COMP_YN = 'N'
                 WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                   AND NVL(USE_YN,'Y') = 'Y' 
                   ;

                --실적등록 가능 월 검사                
                BEGIN
                    SELECT  YMCHK INTO  V_YMCHK
                      FROM TB_MAS011
                     WHERE WERKS = P_WERKS
                       AND YMCHK = 'Y'
                       AND YYMM  = SUBSTR(V_PRFM_DT, 1, 6);
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_YMCHK := 'N';
                END;

                IF V_YMCHK = 'N' THEN
                    RS_CODE := 'E';
                    RS_MSG := '실적등록 가능한 월이 아닙니다.';
                    ROLLBACK;
                    RETURN;
                END IF;

                SELECT SAP_WRK_CD INTO V_SAP_WRK_CD
                  FROM TB_MAS012
                  WHERE MACH_CD = P_MACH_CD
                  ;

                IF V_STA = '00' THEN   --재고상태 정상
                    IF  V_SDOC_NO IS NOT NULL  THEN
                             V_DOC_NO := FN_GET_MDOCNO('M','IF129');
                             V_DOC_SEQNO := 1;

                             INSERT INTO TB_IFS007           --생산오더별실적 취소
                             (
                                                   RUECK                        --SAP 확정번호
                                                 , RMZHL                        --SAP 확정카운터
                                                 , MDOCNO                       --MES 문서번호
                                                 , MDOCSEQ                      --MES 문서순번
                                                 , MAKE_DATE                    --등록일자 
                                                 , MAKER                        --등록자
                                                 , WORKCENTERCODE               --작업장코드(MES PK)
                                                 , AUFNR                        --오더번호
                                                 , ROLLCNT                      --권치수
                                                 , MBLNR                        --MBLNR
                                                 , LOTNO
                             )                       
                             VALUES
                             (                     V_SDOC_NO                    --SAP 확정번호
                                                 , V_SDOC_SEQNO                 --SAP 확정카운터 
                                                 , V_DOC_NO                     --MES 문서번호
                                                 , V_DOC_SEQNO                  --MES 문서순번 
                                                 , SYSDATE                      --등록일자 
                                                 , P_USERID                     --등록자
                                                 , V_SAP_WRK_CD                 --작업장코드(MES PK)
                                                 , V_ORDER_NO                   --오더번호
                                                 , V_ROLLCNT                    --권치수
                                                 , V_SDOC_NO                    --MBLNR   
                                                 , V_LOT_NO                     --LOT_NO
                             );   

                            --SAP FUNC ID
                            SELECT RFCFN
                              INTO RS_PRFM_RFCFN
                              FROM TB_ITFMA
                             WHERE 1=1
                               AND IFID = 'MES_IF_129';   --생산오더별 실적 취소 TXN

                            --인터페이스 파라미터
                            OPEN CUR_1 FOR
                            SELECT 'MES_IF_129' AS I_IF_ID
                                 , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                              FROM dual;

                            --인터페이스 상세 파라미터
                            V_SQL := FN_IF_QUERY('MES_IF_129', V_DOC_NO);
                            OPEN CUR_2 FOR V_SQL;
                    END IF ;

                    BEGIN
                        SELECT LOT_NO_M    --LOT_NO
                             , MATNR_M     --자재코드
                             , INP_DT    --투입일자
                             , SDOC_NO    --SAP 문서번호 
                             , SDOC_SEQNO --SAP 문서번호(년도)
                             , IND_BCD_M
                          INTO V_LOT_NO 
                             , V_MATNR
                             , V_INP_DT
                             , V_SDOC_NO    --SAP 문서번호
                             , V_SDOC_SEQNO --SAP 문서번호(년도)
                             , V_IND_BCD_M
                          FROM TB_INV010     --자재투입이력   
                          --FROM TB_INV003     --자재투입
                         WHERE WERKS   = P_WERKS
                           AND MACH_CD = P_MACH_CD
                           AND IND_BCD = V_IND_BCD
                           AND NVL(CNL_YN,'N') = 'N'
                        ;
                    EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                V_LOT_NO := '';
                            WHEN OTHERS THEN
                                V_LOT_NO := '';
                    END;

                    BEGIN 
                        --로케이션 정보
                        SELECT LGPRO INTO V_STOR_LOC_CD
                          FROM TB_MAS001
                         WHERE WERKS = P_WERKS
                           AND MATNR = V_MATNR;

                    EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                V_STOR_LOC_CD := '';
                            WHEN OTHERS THEN
                                V_STOR_LOC_CD := '';
                    END;

                    IF  NVL(V_STOR_LOC_CD, '') = '' THEN
                        RS_CODE := 'E';
                        RS_MSG := '저장위치 정보를 확인해주세요';
                        ROLLBACK;
                        RETURN;
                    END IF;

                    IF V_SDOC_NO IS NULL  THEN
                       RS_CODE      := 'E';
                       RS_MSG       := 'SAP 인터페이스 실패한 실적 입니다.';
                       ROLLBACK;
                       RETURN;
                    END IF ;

                    IF  V_SDOC_NO IS NOT NULL  THEN
                            V_DOC_NO := FN_GET_MDOCNO('M','IF143');
                            V_DOC_SEQNO := 1;

                            INSERT INTO TB_IFS014           ----생산오더별 자재 투입량 취소
                            (
                                    AUFNR	                --오더번호
                                   ,POSNR	                --오더Item번호
                                   ,BUDAT	                --투입일자(전기일)
                                   ,MATNR	                --자재번호(투입자재)
                                   ,MENGE	                --투입량
                                   ,WERKS	                --플랜트
                                   ,LGORT	                --저장위치
                                   ,CHARG	                --LOT번호
                                   ,WORKCENTERCODE	        --작업장코드(MES PK)
                                   ,MDOCNO	                --MES 문서번호
                                   ,MDOCSEQ	                --MES 문서순번
                                   ,MBLNR	                --SAP 문서번호
                                   ,MJAHR	                --SAP 문서번호(년도)
                                   ,ZRESULT	                --SAP 결과값 Return( S:성공, E:오류 )
                                   ,ZMESSAGE	            --SAP결과 메시지
                                   ,ZRESULT_DATE	        --SAP 전송 시간
                                   ,MAKE_DATE	            --등록일자
                                   ,MAKER	                --등록자
                                   ,IF_MES_KEY	            --MES Inserface Key(MES->SAP 인 경우만)
                            )
                            VALUES
                            (
                                    V_ORDER_NO	            --오더번호
                                   ,1	                    --오더Item번호
                                   ,V_INP_DT	            --투입일자(전기일)
                                   ,V_MATNR	                --자재번호(투입자재)
                                   ,V_PRFM_QTY	            --투입량
                                   ,P_WERKS	                --플랜트
                                   ,V_STOR_LOC_CD	        --저장위치
                                   ,V_LOT_NO	            --LOT번호
                                   ,V_SAP_WRK_CD            --작업장코드(MES PK)
                                   ,V_DOC_NO	            --MES 문서번호
                                   ,V_DOC_SEQNO	            --MES 문서순번
                                   ,V_SDOC_NO	            --SAP 문서번호
                                   ,V_SDOC_SEQNO	        --SAP 문서번호(년도)
                                   ,NULL	                --SAP 결과값 Return( S:성공, E:오류 )
                                   ,NULL	                --SAP결과 메시지
                                   ,NULL	                --SAP 전송 시간
                                   ,SYSDATE	                --등록일자
                                   ,P_USERID	            --등록자
                                   ,NULL	                --MES Inserface Key(MES->SAP 인 경우만)
                            );

                            --SAP FUNC ID
                            SELECT RFCFN
                              INTO RS_INPUT_RFCFN
                              FROM TB_ITFMA
                             WHERE 1=1
                               AND IFID = 'MES_IF_143';   --생산오더별 실적 취소 TXN

                            --인터페이스 파라미터
                            OPEN CUR_5 FOR
                            SELECT 'MES_IF_143' AS I_IF_ID
                                 , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                              FROM dual;

                            --인터페이스 상세 파라미터
                            V_SQL := FN_IF_QUERY('MES_IF_143', V_DOC_NO);
                            OPEN CUR_6 FOR V_SQL;
                    END IF ;

                    UPDATE TB_WRK002     --실적테이블(PS)
                       SET CNL_YN = 'Y',
                           CNL_RMK = P_CNL_RMK,    
                           --ROLLCNT = ROLLCNT - V_ROLLCNT ,
                           UPDDATE = SYSDATE,
                           UPDID   = P_USERID
                    WHERE WERKS   = P_WERKS
                      AND MACH_CD = P_MACH_CD
                      AND IND_BCD = V_IND_BCD
                      --AND NVL(CNL_YN,'N') = 'N'
                      ;
/*
                    DELETE FROM TB_INV001     --창고별 재고현황
                    WHERE WERKS   = P_WERKS
                      AND IND_BCD = V_IND_BCD
                      AND MACH_CD = P_MACH_CD;
*/

                   UPDATE TB_INV001
                        SET STCK_QTY = 0,
                            DLFL = 'Y',
                            UPDDATE = SYSDATE,
                            UPDID   = P_USERID
                      WHERE WERKS = P_WERKS
                        AND MACH_CD = P_MACH_CD
                        AND IND_BCD = V_IND_BCD;

                    --DELETE FROM TB_INV003     --자재투입
                    --WHERE WERKS   = P_WERKS
                    --  AND IND_BCD = V_IND_BCD_M
                    --  AND MACH_CD = P_MACH_CD;

                UPDATE TB_INV003
                   SET STCK_QTY = NVL(STCK_QTY, 0) + V_PRFM_QTY
                     , USE_QTY  = NVL(USE_QTY, 0) - V_PRFM_QTY
                 WHERE WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IND_BCD = V_IND_BCD_M;

--                    DELETE FROM TB_INV010     --자재투입이력
--                    WHERE WERKS   = P_WERKS
--                      AND IND_BCD = V_IND_BCD
--                      AND MACH_CD = P_MACH_CD;
--
--                    DELETE FROM TB_WRK008     --LOT 추적
--                      WHERE WERKS   = P_WERKS
--                      AND IND_BCD   = V_IND_BCD
--                     ;

                 --   DELETE FROM TB_WRK022     --LOT변경취소
                 --    WHERE WERKS   = P_WERKS
                 --      AND MACH_CD = P_MACH_CD
                 --      AND IND_BCD = V_IND_BCD
                 --       ;

                ELSIF V_STA = '10' THEN   --재고상태 투입
                     RS_CODE      := 'E';
                     RS_MSG       := '후공정에 투입되어 실적취소를 할 수 없습니다.';
                     ROLLBACK;
                     RETURN;
                ELSIF V_STA = '20' THEN   --재고상태 생산실적
                     RS_CODE      := 'E';
                     RS_MSG       := '후공정에서 실적완료 되어 실적취소를 할 수 없습니다.';
                     ROLLBACK;
                     RETURN;
                END IF;  
                /*
                --WCS 삭제 정보(밀롤 창고
                IF V_MRLDCK = 'Y' THEN

                    V_DOC_NO := FN_GET_MDOCNO('M','IF406');
                    V_DOC_SEQNO := 1;

                    INSERT INTO TB_IFSWC005(DOC_NO,
                                            DOC_NOSEQ,
                                            IND_BCD,
                                            LOT_NO,
                                            DISCARD_CODE,
                                            DISCARD_RMK,
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
                                            REMARK10)
                                   VALUES( V_DOC_NO,
                                            V_DOC_SEQNO,
                                            V_IND_BCD,
                                            V_LOT_NO,
                                            '',
                                            P_CNL_RMK,
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
                                            '');

                END IF;  */             
        END IF;   -- IF V_ROLLCNT > 0 END => 실적취소 처리 END

        -- 폐품 취소------------------------------------------------------------------------------------------
        BEGIN
                SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, SDOC_NO, SDOC_SEQNO, DISPO_QTY, ROLLCNT
                     , MMATNR, PRFM_DT, LOT_NO_M, IND_BCD_M
                  INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_SDOC_NO, V_SDOC_SEQNO, V_DISPO_QTY, V_ROLLCNT
                     , V_MATNR_M, V_PRFM_DT, V_LOT_NO_M, V_IND_BCD_M
                  FROM TB_WRK004
                 WHERE WERKS   = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IND_BCD = V_IND_BCD
                   --AND NVL(CNL_YN,'N') = 'N'
                   ;
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_ROLLCNT := 0;
                WHEN OTHERS THEN
                    V_ROLLCNT := 0;
        END;

        BEGIN
                SELECT ORDER_NO, SHEET, SLITER
                  INTO V_ORDER_NO, V_SHEET, V_SLITER
                  FROM TB_SCH016
                 WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                   AND NVL(USE_YN,'Y') = 'Y' 
                   ;
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_ORDER_NO := '';
                WHEN OTHERS THEN
                    V_ORDER_NO := '';
        END;

        IF V_ROLLCNT > 0 THEN   --폐품수량

                IF V_SDOC_NO IS NULL  THEN
                   RS_CODE      := 'E';
                   RS_MSG       := 'SAP 인터페이스 실패한 실적 입니다.';
                   ROLLBACK;
                   RETURN;
                END IF ;

                --실적등록 가능 월 검사                
                BEGIN
                    SELECT YMCHK INTO  V_YMCHK
                      FROM TB_MAS011
                     WHERE WERKS = P_WERKS
                       AND YMCHK = 'Y'
                       AND YYMM  = SUBSTR(V_PRFM_DT, 1, 6);
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_YMCHK := 'N';
                END;

                IF V_YMCHK = 'N' THEN
                    RS_CODE := 'E';
                    RS_MSG := '실적등록 가능한 월이 아닙니다.';
                    ROLLBACK;
                    RETURN;
                END IF;

-- 실적 취소시에만 작업지시 업데이트 처리함.
--                UPDATE TB_SCH016
--                   SET COMP_YN = 'N'
--                 WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
--                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
--                   AND NVL(USE_YN,'Y') = 'Y' ;
                   
                UPDATE TB_INV003
                   SET STCK_QTY  = NVL(STCK_QTY, 0)  + V_DISPO_QTY
                     , USE_QTY   = NVL(USE_QTY, 0)   - V_DISPO_QTY
                     , DISPO_QTY = NVL(DISPO_QTY, 0) - V_DISPO_QTY
                     , UPDDATE   = SYSDATE
                     , UPDID     = P_USERID
                 WHERE WERKS   = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IND_BCD = V_IND_BCD_M;

                SELECT SAP_WRK_CD INTO V_SAP_WRK_CD
                  FROM TB_MAS012
                  WHERE MACH_CD = P_MACH_CD;

                    IF  V_SDOC_NO IS NOT NULL  THEN
                             V_DOC_NO := FN_GET_MDOCNO('M','IF144');
                             V_DOC_SEQNO := 1;

                             INSERT INTO TB_IFS022           --폐품취소
                             (
                                                     WORKCENTERCODE	--작업장코드(MES PK)
                                                    ,AUFNR	        --오더번호
                                                    ,POSNR	        --오더Item번호
                                                    ,BUDAT	        --투입일자(전기일)
                                                    ,MATNR	        --자재번호(투입자재)
                                                    ,MENGE	        --투입량
                                                    ,WERKS	        --플랜트
                                                    ,LGORT	        --저장위치
                                                    ,CHARG	        --LOT번호
                                                    ,MDOCNO	        --MES 문서번호
                                                    ,MDOCSEQ	    --MES 문서순번
                                                    ,MBLNR	        --SAP 문서번호
                                                    ,MJAHR	        --SAP 문서번호(년도)
                                                    ,ZRESULT	    --SAP 결과값 Return( S:성공, E:오류 )
                                                    ,ZRESULT_DATE    --전송 시간
                                                    ,MAKE_DATE	    --등록일자
                                                    ,IF_MES_KEY	    --MES Inserface Key(MES->SAP 인 경우만)
                                                    ,ZMESSAGE	    --SAP결과 메시지                                          
                             )                       
                             VALUES
                             (               
                                                     V_SAP_WRK_CD	--작업장코드(MES PK)
                                                    ,V_ORDER_NO	    --오더번호
                                                    ,1	            --오더Item번호
                                                    ,V_PRFM_DT	    --투입일자(전기일)
                                                    ,V_MATNR_M	    --자재번호(투입자재)
                                                    ,V_DISPO_QTY	--투입량
                                                    ,P_WERKS	    --플랜트
                                                    ,'2000'	        --저장위치
                                                    ,V_LOT_NO_M	    --LOT번호
                                                    ,V_DOC_NO	    --MES 문서번호
                                                    ,V_DOC_SEQNO	--MES 문서순번
                                                    ,V_SDOC_NO	    --SAP 문서번호
                                                    ,V_SDOC_SEQNO	--SAP 문서번호(년도)
                                                    ,'N'	        --SAP 결과값 Return( S:성공, E:오류 )
                                                    ,NULL           --전송 시간
                                                    ,SYSDATE	    --등록일자
                                                    ,NULL	        --MES Inserface Key(MES->SAP 인 경우만)
                                                    ,NULL	        --SAP결과 메시지                                          
                             );                  

                             --SAP FUNC ID
                             SELECT RFCFN
                               INTO RS_DISPO_RFCFN
                               FROM TB_ITFMA
                              WHERE 1=1
                                AND IFID = 'MES_IF_144';   --생산오더별 실적 취소 TXN

                             --인터페이스 파라미터
                             OPEN CUR_3 FOR
                             SELECT 'MES_IF_144' AS I_IF_ID
                                  , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                               FROM dual;

                             --인터페이스 상세 파라미터
                             V_SQL := FN_IF_QUERY('MES_IF_144', V_DOC_NO);
                             OPEN CUR_4 FOR V_SQL;
                     END IF ;

                     UPDATE TB_WRK004     --폐품테이블(PS)
                        SET CNL_YN = 'Y',
                            UPDDATE = SYSDATE,
                            UPDID   = P_USERID
                      WHERE WERKS   = P_WERKS
                        AND MACH_CD = P_MACH_CD
                        AND IND_BCD = V_IND_BCD
                        --AND NVL(CNL_YN,'N') = 'N'
                        ;

        END IF;

        -- 잔량 취소------------------------------------------------------------------------------------------       
         BEGIN
                SELECT H016.PRE_ORDER_NO, K002.WRK_ORDR_NO, K002.WRK_ORDR_SEQNO, K002.PRFM_DT
                  INTO V_PRE_ORDER_NO, V_WRK_ORDR_NO1, V_WRK_ORDR_SEQNO1, V_PRFM_DT
                  FROM TB_WRK002  K002
                     , TB_SCH016  H016
                 WHERE K002.WRK_ORDR_NO    = H016.WRK_ORDR_NO
                   AND K002.WRK_ORDR_SEQNO = H016.WRK_ORDR_SEQNO
                   AND K002.WERKS   = P_WERKS
                   AND K002.IND_BCD = V_IND_BCD
                   --AND NVL(K002.CNL_YN,'N') = 'N'
                   AND NVL(H016.USE_YN,'Y') = 'Y' 
                   AND ROWNUM = 1
                   ;
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_PRE_ORDER_NO := ' ';
                WHEN OTHERS THEN
                    V_PRE_ORDER_NO := ' ';
        END;

        BEGIN
                SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO,SDOC_NO, SDOC_SEQNO, DISPO_QTY, WGT, ROLLCNT, MATNR_M, PRFM_DT, LOT_NO_M,ORDER_NO, IND_BCD_M
                  INTO V_WRK_ORDR_NO2, V_WRK_ORDR_SEQNO2, V_SDOC_NO, V_SDOC_SEQNO, V_DISPO_QTY, V_DISPO_WGT, V_ROLLCNT,V_MATNR,V_PRFM_DT,V_LOT_NO,V_ORDER_NO, V_IND_BCD_M
                  FROM TB_WRK022 
                 WHERE WERKS          = P_WERKS
                   AND MACH_CD        = P_MACH_CD
                   AND PRE_ORDER_NO   = V_PRE_ORDER_NO
                   AND DISPO_CD= '910'
                   AND NVL(CNL_YN,'N') = 'N'
                   ;
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_ROLLCNT := 0;
                    V_DISPO_WGT := 0;
                WHEN OTHERS THEN
                    V_ROLLCNT := 0;
                    V_DISPO_WGT := 0;
        END;

        IF V_DISPO_WGT > 0 THEN   --폐품수량

                IF V_SDOC_NO IS NULL  THEN
                   RS_CODE      := 'E';
                   RS_MSG       := 'SAP 인터페이스 실패한 실적 입니다.';
                   ROLLBACK;
                   RETURN;
                END IF ;


                --실적등록 가능 월 검사                
                BEGIN
                    SELECT  YMCHK INTO  V_YMCHK
                      FROM TB_MAS011
                     WHERE WERKS = P_WERKS
                       AND YMCHK = 'Y'
                       AND YYMM  = SUBSTR(V_PRFM_DT, 1, 6);
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_YMCHK := 'N';
                END;

                IF V_YMCHK = 'N' THEN
                    RS_CODE := 'E';
                    RS_MSG := '실적등록 가능한 월이 아닙니다.';
                    ROLLBACK;
                    RETURN;
                END IF;

                SELECT SAP_WRK_CD INTO V_SAP_WRK_CD
                  FROM TB_MAS012
                  WHERE MACH_CD = P_MACH_CD
                  ;
                    IF  V_SDOC_NO IS NOT NULL  THEN
                             V_DOC_NO_DISPO_S2 := FN_GET_MDOCNO('M','IF144');
                             V_DOC_SEQNO_DISPO := NVL(V_DOC_SEQNO_DISPO, 0) + 1;

                             INSERT INTO TB_IFS022           --폐품취소
                             (
                                                     WORKCENTERCODE	--작업장코드(MES PK)
                                                    ,AUFNR	        --오더번호
                                                    ,POSNR	        --오더Item번호
                                                    ,BUDAT	        --투입일자(전기일)
                                                    ,MATNR	        --자재번호(투입자재)
                                                    ,MENGE	        --투입량
                                                    ,WERKS	        --플랜트
                                                    ,LGORT	        --저장위치
                                                    ,CHARG	        --LOT번호
                                                    ,MDOCNO	        --MES 문서번호
                                                    ,MDOCSEQ	    --MES 문서순번
                                                    ,MBLNR	        --SAP 문서번호
                                                    ,MJAHR	        --SAP 문서번호(년도)
                                                    ,ZRESULT	    --SAP 결과값 Return( S:성공, E:오류 )
                                                    ,ZRESULT_DATE    --전송 시간
                                                    ,MAKE_DATE	    --등록일자
                                                    ,IF_MES_KEY	    --MES Inserface Key(MES->SAP 인 경우만)
                                                    ,ZMESSAGE	    --SAP결과 메시지                                          
                             )                       
                             VALUES
                             (               
                                                     V_SAP_WRK_CD	--작업장코드(MES PK)
                                                    ,V_ORDER_NO	    --오더번호
                                                    ,1	            --오더Item번호
                                                    ,V_PRFM_DT	    --투입일자(전기일)
                                                    ,V_MATNR	    --자재번호(투입자재)
                                                    ,V_DISPO_WGT	--투입량 (밀롤의 폐품은 중량)
                                                    ,P_WERKS	    --플랜트
                                                    ,'2000'	        --저장위치
                                                    ,V_LOT_NO	    --LOT번호
                                                    ,V_DOC_NO_DISPO_S2 --MES 문서번호
                                                    ,V_DOC_SEQNO_DISPO --MES 문서순번
                                                    ,V_SDOC_NO	    --SAP 문서번호
                                                    ,V_SDOC_SEQNO	--SAP 문서번호(년도)
                                                    ,'N'	        --SAP 결과값 Return( S:성공, E:오류 )
                                                    ,NULL           --전송 시간
                                                    ,SYSDATE	    --등록일자
                                                    ,NULL	        --MES Inserface Key(MES->SAP 인 경우만)
                                                    ,NULL	        --SAP결과 메시지
                             );                  

                            /*
                            UPDATE TB_INV003
                               SET STCK_QTY = NVL(STCK_QTY, 0)   + V_DISPO_WGT
                                 , USE_QTY   = NVL(USE_QTY, 0)   - V_DISPO_WGT
                                 , DISPO_QTY = NVL(DISPO_QTY, 0) - V_DISPO_WGT
                             WHERE WERKS = P_WERKS
                               AND MACH_CD = P_MACH_CD
                               AND IND_BCD = V_IND_BCD_M;
                            */
                             --SAP FUNC ID
                             SELECT RFCFN
                               INTO RS_SDISPO_RFCFN
                               FROM TB_ITFMA
                              WHERE 1=1
                                AND IFID = 'MES_IF_144';   --생산오더별 실적 취소 TXN

                             --인터페이스 파라미터
                             OPEN CUR_7 FOR
                             SELECT 'MES_IF_144' AS I_IF_ID
                                  , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                               FROM dual;

                            IF V_DOC_NO_DISPO_S1 IS NULL THEN
                               V_DOC_NO_DISPO_S1 := '' ;
                            ELSE
                               V_DOC_NO_DISPO_S1 := V_DOC_NO_DISPO_S1||',' ;
                            END IF;

                             --인터페이스 상세 파라미터
                             V_SQL := FN_IF_QUERY('MES_IF_144', /*V_DOC_NO_DISPO_S1||*/ V_DOC_NO_DISPO_S2);
                             OPEN CUR_8 FOR V_SQL;
                     END IF ;

                   /*  DELETE FROM TB_WRK022     
                     WHERE WERKS   = P_WERKS
                       AND WRK_ORDR_NO      = V_WRK_ORDR_NO2
                       AND WRK_ORDR_SEQNO   = V_WRK_ORDR_SEQNO2
                       AND DISPO_CD         = '910'
                        ;*/

                     UPDATE TB_WRK022     SET CNL_YN = 'Y'
                     WHERE WERKS   = P_WERKS
                       AND WRK_ORDR_NO      = V_WRK_ORDR_NO2
                       AND WRK_ORDR_SEQNO   = V_WRK_ORDR_SEQNO2
                       AND DISPO_CD         = '910'
                       AND NVL(CNL_YN,'N') = 'N'
                       ;
        END IF;

        V_TOT_QTY := 0 ;

        SELECT SUM(QTY)
          INTO V_TOT_QTY     
        FROM 
            (
                        SELECT NVL(PRFM_QTY,0)   QTY
                        FROM TB_WRK002 
                         WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                           AND NVL(CNL_YN, 'N') =  'N'
                        UNION ALL
                        SELECT NVL(DISPO_QTY,0)  QTY
                        FROM TB_WRK004 
                         WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                           AND NVL(CNL_YN, 'N') =  'N'
              ) ;

     /*   DELETE FROM TB_INV010     --자재투입이력
        WHERE WERKS   = P_WERKS
          AND IND_BCD = V_IND_BCD
          AND MACH_CD = P_MACH_CD;
*/

        UPDATE TB_INV010  SET CNL_YN = 'Y'   --자재투입이력
        WHERE WERKS   = P_WERKS
          AND IND_BCD = V_IND_BCD
          AND MACH_CD = P_MACH_CD;




        DELETE FROM TB_WRK008     --LOT 추적
          WHERE WERKS   = P_WERKS
          AND IND_BCD   = V_IND_BCD
         ;

--        UPDATE TB_SCH016
--           SET COMP_YN  = 'N'
--             , PRFM_QTY = V_TOT_QTY
--        WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
--          AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;

        UPDATE TB_SCH016
           SET PRFM_QTY = V_TOT_QTY
        WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
          AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;

    END LOOP;

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

    IF CUR_6%ISOPEN = FALSE THEN
        OPEN CUR_6 FOR SELECT 1 FROM dual;
    END IF;

    IF CUR_7%ISOPEN = FALSE THEN
        OPEN CUR_7 FOR SELECT 1 FROM dual;
    END IF;

    IF CUR_8%ISOPEN = FALSE THEN
        OPEN CUR_8 FOR SELECT 1 FROM dual;
    END IF;


    RS_CODE := 'S';
    --COMMIT;    

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
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END;

/
