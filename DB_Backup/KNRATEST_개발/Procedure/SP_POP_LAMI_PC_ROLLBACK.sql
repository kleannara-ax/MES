--------------------------------------------------------
--  DDL for Procedure SP_POP_LAMI_PC_ROLLBACK
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_LAMI_PC_ROLLBACK" 
(
    P_WERKS     		IN VARCHAR2 	                --플랜트
    ,P_MACH_CD   		IN VARCHAR2 	                --설비코드
    ,P_WRK_ORDR_NO      IN VARCHAR2                     --작업지시번호
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2                     --작업지시번호SEQ
    ,P_CLN_RMK          IN TB_LAMI_PC.SAL_RMK%TYPE                     --작업지시번호SEQ
    ,RS_PRFM_RFCFN      OUT VARCHAR2                    --실적 RFCFN값
    ,RS_DISPO_RFCFN     OUT VARCHAR2                    --폐품 RFCFN값    
    ,RS_INPUT_RFCFN     OUT VARCHAR2                    --투입량 RFCFN값        
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
    ,CUR_1              OUT SYS_REFCURSOR               --실적
    ,CUR_2              OUT SYS_REFCURSOR
    ,CUR_3              OUT SYS_REFCURSOR               --폐품
    ,CUR_4              OUT SYS_REFCURSOR
    ,CUR_5              OUT SYS_REFCURSOR               --투입량
    ,CUR_6              OUT SYS_REFCURSOR    
    
)
/*==============================================================================
 * PROGRAM ID    : WRK073
 * PROGRAM NAME  : 인쇄/코팅 ROLLBACK
 * VERSION       : 1.0.0
 * DESCRIPTION   : 인쇄/코팅 ROLLBACK을 하기 위한 SP.
 *                 
 * AUTHOR NAME   : 김수현
 * CREATE DATE   : 2022/11/17
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/10    1.0.0   김수현         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_LAMI_PC] : (.R..) 인쇄/코팅 작업지시
 *=============================================================================*/
AS 
    --프로그램 ID : 점보롤 작업시작
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_LAMI_PC_ROLLBACK';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리

    V_MATNR                     TB_WRK002.MATNR%TYPE;
    V_SAP_WRK_CD        TB_MAS012.SAP_WRK_CD%TYPE;
    V_CNT1                       NUMBER(13,0);
    V_CNT2                       NUMBER(13,0);
    V_CNT3                       NUMBER(13,0);
    V_ORDER_NO                  VARCHAR2(20);
    V_REGDATE                   DATE := SYSDATE;
    V_DOC_NO                    VARCHAR2(20);
    V_USE_YN                    CHAR(1);
    V_COMP_YN                   CHAR(1);
    V_REMAIN_QTY                NUMBER(13,0);
    V_IND_BCD                   VARCHAR2(20);
    V_LOT_NO                    VARCHAR2(20);
    V_REGID                    VARCHAR2(30);
    V_ORDER_QTY                 NUMBER(13,0);
    V_LOT_NO_M                 VARCHAR2(20);
    V_MATNR_M           TB_WRK004.MATNR%TYPE;        --자재코드
    V_INP_DT	        TB_INV003.INP_DT%TYPE;        --투입일자
    V_SDOC_NO           TB_WRK002.SDOC_NO%TYPE;
    V_SDOC_SEQNO        TB_WRK002.SDOC_SEQNO%TYPE;
    V_IND_BCD_M         TB_WRK002.IND_BCD%TYPE;       --자재개별바코드
    V_RUN_STA           VARCHAR2(5);
    V_EXPROD            VARCHAR2(5);
    V_STA               TB_WRK002.STA%TYPE;
    V_SALWEIGHT         NUMBER(13,0);
    V_SQL               VARCHAR2(4000);
    V_DOC_NO_INPUT      VARCHAR2(20);
    V_DOC_SEQNO_INPUT   NUMBER;
    V_DOC_SEQNO         NUMBER;
    V_PRFM_DT           VARCHAR2(5);
    V_CNL_YN           CHAR(1);
    V_DOC_NO_DISPO      VARCHAR2(20);
    V_DOC_SEQNO_DISPO   NUMBER;

BEGIN

    BEGIN

         SELECT MATNR, ORDER_NO, DOC_NO, NVL(USE_YN,'Y'), NVL(COMP_YN,'N'), REMAIN_QTY, IND_BCD, LOT_BUF, REGID
         , ORDER_QTY, SALWEIGHT,SUBSTR(PRD_STR_DTM,1,8), CNL_YN
         INTO V_MATNR, V_ORDER_NO, V_DOC_NO, V_USE_YN, V_COMP_YN, V_REMAIN_QTY, V_IND_BCD, V_LOT_NO, V_REGID
         , V_ORDER_QTY, V_SALWEIGHT, V_PRFM_DT, V_CNL_YN
         FROM TB_LAMI_PC
         WHERE WRK_ORDR_NO = P_WRK_ORDR_NO  
           AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;

        SELECT RUN_STA , STA
          INTO V_RUN_STA, V_STA
          FROM TB_WRK002
         WHERE WERKS   = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND IND_BCD = V_IND_BCD ;

        IF V_RUN_STA = '09'  THEN
            V_EXPROD := 'X' ;
        ELSE
            V_EXPROD := '' ;
        END IF ;

        IF V_USE_YN = 'N' AND V_COMP_YN = 'Y' AND V_REMAIN_QTY = 0 AND V_CNL_YN = 'N' THEN
            BEGIN

                    SELECT NVL(COUNT(*),0)
                    INTO V_CNT1
                    FROM TB_LAMI_RESULT
                    WHERE 1 = 1
                    AND WRK_ORDR_NO = P_WRK_ORDR_NO
                    AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                    AND WERKS = P_WERKS
                    ;

                    SELECT NVL(COUNT(*),0)
                    INTO V_CNT2
                    FROM TB_LAMI_PC_RESULT
                    WHERE 1 = 1
                    AND WRK_ORDR_NO = P_WRK_ORDR_NO
                    AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                    AND WERKS = P_WERKS
                    ;

                    SELECT LOT_NO    --LOT_NO
                         , MATNR     --자재코드
                         , INP_DT      --투입일자
                         , SDOC_NO     --SAP 문서번호 
                         , SDOC_SEQNO  --SAP 문서번호(년도)
                         , IND_BCD   --자재개별바코드                             
                      INTO V_LOT_NO_M 
                         , V_MATNR_M
                         , V_INP_DT
                         , V_SDOC_NO    --SAP 문서번호
                         , V_SDOC_SEQNO --SAP 문서번호(년도)
                         , V_IND_BCD_M  -- 자재개별바코드
                      FROM TB_INV010     --자재투입이력
                     WHERE WERKS   = P_WERKS
                       AND MACH_CD = P_MACH_CD
                       AND IND_BCD = V_IND_BCD 
                       AND NVL(CNL_YN,'N') = 'N'
                       ;

                    BEGIN
                        SELECT SAP_WRK_CD INTO V_SAP_WRK_CD
                          FROM TB_MAS012
                         WHERE MACH_CD = P_MACH_CD ;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            V_SAP_WRK_CD := '';
                        WHEN OTHERS THEN
                            V_SAP_WRK_CD := '';
                    END;
                IF V_STA = '00'  THEN   --재고상태 정상

                    DELETE FROM TB_WRK008 WHERE WERKS = P_WERKS AND MACH_CD = P_MACH_CD AND IND_BCD = V_IND_BCD; --LOT 추적(DELETE)

                    UPDATE  TB_INV010  SET CNL_YN = 'Y'    --자재투입이력
                     WHERE WERKS   = P_WERKS
                       AND MACH_CD = P_MACH_CD
                       AND IND_BCD = V_IND_BCD ;

--                    UPDATE  TB_WRK021  SET CNL_YN = 'Y'    --자재투입이력
--                     WHERE WERKS   = P_WERKS
--                       AND MACH_CD = P_MACH_CD
--                       AND IND_BCD = V_IND_BCD ;

                    UPDATE TB_WRK022   SET CNL_YN = 'Y'   
                    WHERE WERKS     = P_WERKS
                      AND MACH_CD   = P_MACH_CD
                      AND LOT_NO = V_LOT_NO
                      ;

                   UPDATE TB_INV001
                        SET STCK_QTY = 0,
                            DLFL = 'Y',
                            UPDDATE = SYSDATE,
                            UPDID   = V_REGID
                      WHERE WERKS = P_WERKS
                        AND MACH_CD = P_MACH_CD
                        AND IND_BCD = V_IND_BCD;

                    --COMMIT;
--                    IF V_SALWEIGHT > 0 THEN
--                        BEGIN
--                            V_DOC_NO_DISPO    := FN_GET_MDOCNO('M','IF144');  --폐품
--                            V_DOC_SEQNO_DISPO := V_DOC_SEQNO_DISPO + 1;
--                            
--                            INSERT INTO TB_IFS022     --폐품취소
--                                    (
--                                         WORKCENTERCODE	--작업장코드(MES PK)
--                                        ,AUFNR	        --오더번호
--                                        ,POSNR	        --오더Item번호
--                                        ,BUDAT	        --투입일자(전기일)
--                                        ,MATNR	        --자재번호(투입자재)
--                                        ,MENGE	        --투입량
--                                        ,WERKS	        --플랜트
--                                        ,LGORT	        --저장위치
--                                        ,CHARG	        --LOT번호
--                                        ,MDOCNO	        --MES 문서번호
--                                        ,MDOCSEQ	    --MES 문서순번
--                                        ,MBLNR	        --SAP 문서번호
--                                        ,MJAHR	        --SAP 문서번호(년도)
--                                        ,ZRESULT	    --SAP 결과값 Return( S:성공, E:오류 )
--                                        ,ZRESULT_DATE    --전송 시간
--                                        ,MAKE_DATE	    --등록일자
--                                        ,IF_MES_KEY	    --MES Inserface Key(MES->SAP 인 경우만)
--                                        ,ZMESSAGE	    --SAP결과 메시지
--                                    )                       
--                                 VALUES
--                                       (               
--                                             V_SAP_WRK_CD	--작업장코드(MES PK)
--                                            ,V_ORDER_NO	    --오더번호
--                                            ,1	            --오더Item번호
--                                            ,V_PRFM_DT	    --투입일자(전기일)
--                                            ,V_MATNR_M	    --자재번호(투입자재)
--                                            ,V_ORDER_QTY	--투입량 (밀롤의 폐품은 중량)
--                                            ,P_WERKS	    --플랜트
--                                            ,'2010'	        --저장위치
--                                            ,V_LOT_NO_M	    --LOT번호
--                                            ,V_DOC_NO_DISPO    --MES 문서번호
--                                            ,V_DOC_SEQNO_DISPO --MES 문서순번
--                                            ,V_SDOC_NO	    --SAP 문서번호
--                                            ,V_SDOC_SEQNO	--SAP 문서번호(년도)
--                                            ,'N'	        --SAP 결과값 Return( S:성공, E:오류 )
--                                            ,NULL           --전송 시간
--                                            ,SYSDATE	    --등록일자
--                                            ,NULL	        --MES Inserface Key(MES->SAP 인 경우만)
--                                            ,NULL	        --SAP결과 메시지
--                                        );
--                                SELECT RFCFN
--                                  INTO RS_DISPO_RFCFN
--                                  FROM TB_ITFMA
--                                 WHERE 1=1
--                                   AND IFID = 'MES_IF_144';   --생산오더별 실적 취소 TXN
--            
--                                --인터페이스 파라미터
--                                OPEN CUR_3 FOR
--                                SELECT 'MES_IF_144' AS I_IF_ID
--                                     , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
--                                  FROM dual;
--            
--                                --인터페이스 상세 파라미터
--                                V_SQL := FN_IF_QUERY('MES_IF_144', V_DOC_NO_DISPO);
--                                OPEN CUR_4 FOR V_SQL;
--                        END;
--                    END IF;

    --                IF V_SDOC_NO IS NOT NULL  THEN
--                    IF  V_SDOC_NO IS NOT NULL  AND V_SDOC_NO <> 'E'  THEN
--                        -- 문서번호 생성 (실적)
--                        V_DOC_NO    := FN_GET_MDOCNO('M','IF129');
--                        V_DOC_SEQNO := V_DOC_SEQNO + 1;
--
--                             --생산오더별실적 취소 I/F
--                        INSERT INTO TB_IFS007
--                               (
--                                   RUECK                        --SAP 확정번호
--                                 , RMZHL                        --SAP 확정카운터
--                                 , MDOCNO                       --MES 문서번호
--                                 , MDOCSEQ                      --MES 문서순번
--                                 , MAKE_DATE                    --등록일자 
--                                 , MAKER                        --등록자
--                                 , WORKCENTERCODE               --작업장코드(MES PK)
--                                 , AUFNR                        --오더번호
--                                 , ROLLCNT                      --권치수
--                                 , MBLNR                        --MBLNR
--                                 , LOTNO
--                                 , EXPROD 
--                               )                       
--                         VALUES
--                              (                
--                                   V_SDOC_NO                    --SAP 확정번호
--                                 , V_SDOC_SEQNO                 --SAP 확정카운터 
--                                 , V_DOC_NO                     --MES 문서번호
--                                 , V_DOC_SEQNO                  --MES 문서순번 
--                                 , SYSDATE                      --등록일자 
--                                 , V_REGID                     --등록자
--                                 , V_SAP_WRK_CD                 --작업장코드(MES PK)
--                                 , V_ORDER_NO                   --오더번호
--                                 , 0                            --권치수
--                                 , V_SDOC_NO                    --MBLNR   
--                                 , V_LOT_NO                     --LOT_NO
--                                 , V_EXPROD
--                              );
--
--                        --SAP FUNC ID
--                        SELECT RFCFN
--                          INTO RS_PRFM_RFCFN
--                          FROM TB_ITFMA
--                         WHERE 1=1
--                           AND IFID = 'MES_IF_129';   --생산오더별 실적 취소 TXN
--
--                        --인터페이스 파라미터
--                        OPEN CUR_1 FOR
--                        SELECT 'MES_IF_129' AS I_IF_ID
--                             , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
--                          FROM dual;
--
--                        --인터페이스 상세 파라미터
--                        V_SQL := FN_IF_QUERY('MES_IF_129', V_DOC_NO);
--                        OPEN CUR_2 FOR V_SQL;
--
--                    END IF ;

--                        IF V_LOT_NO_M  IS NOT NULL THEN
--                            --IF V_MAN_CUT_YN = 'N' AND V_SDOC_NO IS NOT NULL THEN
--                            IF V_SDOC_NO IS NOT NULL  AND V_SDOC_NO <> 'E'  THEN
--                                --문서번호 생성 (투입)
--                                V_DOC_NO_INPUT    := FN_GET_MDOCNO('M','IF143');  --투입
--                                V_DOC_SEQNO_INPUT := V_DOC_SEQNO_INPUT  + 1;
--
--                                --생산오더별 자재 투입량 취소 I/F
----                                INSERT INTO TB_IFS014
----                                    (
----                                        AUFNR	                --오더번호
----                                       ,POSNR	                --오더Item번호
----                                       ,BUDAT	                --투입일자(전기일)
----                                       ,MATNR	                --자재번호(투입자재)
----                                       ,MENGE	                --투입량
----                                       ,WERKS	                --플랜트
----                                       ,LGORT	                --저장위치
----                                       ,CHARG	                --LOT번호
----                                       ,WORKCENTERCODE	        --작업장코드(MES PK)
----                                       ,MDOCNO	                --MES 문서번호
----                                       ,MDOCSEQ	                --MES 문서순번
----                                       ,MBLNR	                --SAP 문서번호
----                                       ,MJAHR	                --SAP 문서번호(년도)
----                                       ,ZRESULT	                --SAP 결과값 Return( S:성공, E:오류 )
----                                       ,ZMESSAGE	            --SAP결과 메시지
----                                       ,ZRESULT_DATE	        --SAP 전송 시간
----                                       ,MAKE_DATE	            --등록일자
----                                       ,MAKER	                --등록자
----                                       ,IF_MES_KEY	            --MES Inserface Key(MES->SAP 인 경우만)
----                                    )
----                                VALUES
----                                   (
----                                        V_ORDER_NO	            --오더번호
----                                       ,1	                    --오더Item번호
----                                       ,V_INP_DT	            --투입일자(전기일)
----                                       ,V_MATNR_M	            --자재번호(투입자재)
----                                       ,V_ORDER_QTY  	                --투입량 (실적은 EA)
----                                       ,P_WERKS	                --플랜트
----                                       ,'2010'	        --저장위치
----                                       ,V_LOT_NO_M	            --LOT번호
----                                       ,V_SAP_WRK_CD	        --작업장코드(MES PK)
----                                       ,V_DOC_NO_INPUT	        --MES 문서번호
----                                       ,V_DOC_SEQNO_INPUT	    --MES 문서순번
----                                       ,V_SDOC_NO	            --SAP 문서번호
----                                       ,V_SDOC_SEQNO	        --SAP 문서번호(년도)
----                                       ,NULL	                --SAP 결과값 Return( S:성공, E:오류 )
----                                       ,NULL	                --SAP결과 메시지
----                                       ,NULL	                --SAP 전송 시간
----                                       ,SYSDATE	                --등록일자
----                                       ,V_REGID	            --등록자
----                                       ,NULL	                --MES Inserface Key(MES->SAP 인 경우만)
----                                    );
--
--                                --SAP FUNC ID
--                                SELECT RFCFN
--                                  INTO RS_INPUT_RFCFN
--                                  FROM TB_ITFMA
--                                 WHERE 1=1
--                                   AND IFID = 'MES_IF_143';   --생산오더별 실적 취소 TXN
--
--                                --인터페이스 파라미터
----                                OPEN CUR_5 FOR
----                                SELECT 'MES_IF_143' AS I_IF_ID
----                                     , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
----                                  FROM dual;
----
----                                --인터페이스 상세 파라미터
----                                V_SQL := FN_IF_QUERY('MES_IF_143', V_DOC_NO_INPUT);
----                                OPEN CUR_6 FOR V_SQL;
--
--                            END IF ;
--                        END IF;


                    UPDATE TB_LAMI_PC
                       SET LOT_BUF = ''
                          ,IND_BCD = ''
                          ,DOC_NO = ''
                          ,RES_DT = ''
                          ,PRFM_QTY = 0
            --			  ,PRFM_QTY = P_WGT(잔량 수량을 SAP에서 허용하지 않으면 이것을 사용한다)
                          ,CYCLE_TIME = 0
                          ,SAPYN = 'N'
                          ,SALCODE = ''
                          ,SALWEIGHT = 0
                          ,PPCODE = ''
                          ,HEIGHT = 0
                          ,EQUIL = 0
                          ,STD = 0
                          ,USE_YN = 'Y'
                          ,COMP_YN = 'I'
                          ,REMAIN_QTY = WRK_ORDR_QTY
                          ,PRD_END_DTM = ''
                          ,PRD_END_DT = ''
                          ,SALMETER = 0
                          ,PRFMMET_QTY = 0
                          ,CNL_YN = 'Y'
                     WHERE WRK_ORDR_NO = P_WRK_ORDR_NO  
                       AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                       AND WERKS = P_WERKS
                       AND NVL(USE_YN, 'N') = 'N'
                       AND NVL(COMP_YN, 'Y') = 'Y'
                       ;

                    IF V_CNT2 > 0 THEN
                        BEGIN
                            UPDATE TB_LAMI_PC_RESULT SET CNL_YN = 'Y', CNL_RMK = P_CLN_RMK, USE_YN = 'N'
                             WHERE WRK_ORDR_NO = P_WRK_ORDR_NO  
                               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                               AND WERKS = P_WERKS
                               AND ORDER_NO = V_ORDER_NO
                               --AND NVL(DLFL,'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더
--                               AND NVL(USE_YN, 'N') = 'N'
                               ;
                        END;
                    END IF;
                    
                    UPDATE TB_WRK002     --실적테이블(PS)
                       SET CNL_YN  = 'Y',
                           CNL_RMK = P_CLN_RMK,
                           UPDDATE = SYSDATE,
                           UPDID   = V_REGID
                     WHERE WERKS   = P_WERKS
                       AND MACH_CD = P_MACH_CD
                       AND IND_BCD = V_IND_BCD ;

            --		UPDATE TB_INV003                -- 자재투입량 폐품 2
            --		   SET IND_BCD = ' '
            --		 WHERE WERKS   = P_WERKS
            --		   AND MACH_CD = P_MACH_CD
            --		   AND WRK_ORDR_NO = P_WRK_ORDR_NO;

                        UPDATE TB_INV003                -- 자재투입량 폐품 2
                           SET STCK_QTY  = NVL(STCK_QTY, 0)  + (NVL(USE_QTY,0) + NVL(DISPO_QTY,0))
                               ,DISPO_QTY = 0
                               ,USE_QTY = 0
                         WHERE WERKS   = P_WERKS
                           AND MACH_CD = P_MACH_CD
                           AND WRK_ORDR_NO = P_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                           ;
                END IF;
            END;
        ELSE
            BEGIN
                ROLLBACK;

                RS_CODE := 'E';
                RS_MSG  := '실적완료가 되지않은 작업입니다. 그렇기에 작업취소를 할 수 없습니다. 실적완료 버튼을 누르고 실적완료를 하고 취소하시길 바랍니다.';
                RETURN;
            END;
        END IF;

        RS_CODE := 'S';
        COMMIT;      
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
        E_SQL_ERR_CD        := '-20000';  --SQLCODE;
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
