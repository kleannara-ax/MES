--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK30_I09
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK30_I09" 
(
     P_WERKS     		IN VARCHAR2 	                --플랜트
    ,P_MACH_CD   		IN VARCHAR2 	                --설비코드
    ,P_IND_BCD          IN VARCHAR2			   	        --개별바코드 리스트
    ,P_CNL_RMK          IN VARCHAR2 	                --취소내용
    ,P_USERID           IN VARCHAR2                     --USER ID
    ,RS_GRD_RFCFN       OUT VARCHAR2                     --등급변경취소 RFCFN값
    ,RS_DISPO_RFCFN     OUT VARCHAR2                    --폐품취소 RFCFN값    
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
    ,CUR_1              OUT SYS_REFCURSOR               --등급변경 취소
    ,CUR_2              OUT SYS_REFCURSOR
    ,CUR_3              OUT SYS_REFCURSOR               --폐품 취소
    ,CUR_4              OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK30_I08{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 등급변경 취소 
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 등급변경 취소 
 *                 
 * AUTHOR NAME   : 유상호{최초 작성자 명 기술}
 * CREATE DATE   : 2022/08/21 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/08/21    1.0.0   유상호         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_WRK011] : (.RU.) 설비별 현재진행사항 
 *       - [TB_WRK012] : (C.U.) 설비별 현재진행사항 
 *       - [TB_SCH016] : (.R..) 밀롤,슬리터 작업지지서
 *=============================================================================*/

AS 
    --프로그램 ID : 재단 실적취소 
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK30_I08';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := P_USERID; --USERID

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
    V_WRK_ORDR_NO           TB_SCH015.WRK_ORDR_NO%TYPE;         
    V_WRK_ORDR_SEQNO        TB_SCH015.WRK_ORDR_SEQNO%TYPE;      


    V_ORDER_NO              TB_WRK002.ORDER_NO%TYPE;
    --V_PRE_ORDER_NO              TB_WRK002.ORDER_NO%TYPE;
    V_STA                   TB_WRK002.STA%TYPE;
    V_ROLLCNT	            TB_WRK002.ROLLCNT%TYPE;		    --권치수
    V_PRFM_QTY	            TB_WRK002.PRFM_QTY%TYPE;     --실적수량
    V_DISPO_QTY	            TB_WRK004.DISPO_QTY%TYPE;    --폐품수량
    V_DISPO_WGT             TB_WRK004.WGT%TYPE;          --폐품중량
    
    V_INP_DT	            TB_INV003.INP_DT%TYPE;        --투입일자
    V_STOR_LOC_CD           TB_INV001.STOR_LOC_CD%TYPE;
    V_SQL                   VARCHAR2(4000);
    
    V_TOT_QTY               NUMBER(13,3);
    V_DMY                   VARCHAR2(1);      
    
    V_IND_BCD_M         TB_WRK002.IND_BCD%TYPE;         -- 등급변경 전 개별바코드
    V_MATNR             TB_WRK010.MATNR%TYPE;        --자재코드
    V_IND_BCD           TB_WRK010.IND_BCD%TYPE;
    V_WRK_TYPE          TB_WRK010.WRK_TYPE%TYPE;
    V_LOT_NO            TB_WRK010.LOT_NO%TYPE;
    V_PCNT              TB_WRK010.PCNT%TYPE;
    V_WGT               TB_WRK010.WGT%TYPE;
    V_PRFM_DT           TB_WRK010.CHG_DT%TYPE;
    V_MATNR_M           TB_WRK010.MATNR_M%TYPE;
    V_LOT_NO_M          TB_WRK010.LOT_NO_M%TYPE;
    V_DOC_NO            TB_WRK010.DOC_NO%TYPE;
    V_DOC_SEQNO         TB_WRK010.DOC_SEQNO%TYPE;
    V_SDOC_NO           TB_WRK010.SDOC_NO%TYPE;
    V_SDOC_SEQNO        TB_WRK010.SDOC_SEQNO%TYPE;
    
    
    
    V_STCK_QTY_CHG      TB_INV001.STCK_QTY%TYPE;
    V_STCK_WGT_CHG      TB_INV001.STCK_QTY%TYPE;
    
    V_DOC_NO_1          TB_WRK002.DOC_NO%TYPE;
    V_DOC_SEQNO_1       TB_WRK002.DOC_SEQNO%TYPE;
    V_DOC_NO_2          TB_WRK002.DOC_NO%TYPE;
    V_DOC_SEQNO_2       TB_WRK002.DOC_SEQNO%TYPE;
    V_SAP_WRK_CD        TB_MAS012.SAP_WRK_CD%TYPE;
    V_DATE              DATE := SYSDATE;
    PROD_CUR            SYS_REFCURSOR;		            -- 커서 정의
BEGIN
  BEGIN
    SELECT IND_BCD_M INTO V_IND_BCD_M 
      FROM TB_WRK010
     WHERE WERKS = P_WERKS
       AND IND_BCD = P_IND_BCD
     GROUP BY IND_BCD_M;
    
    --TB_IFS014
    V_DOC_NO_1 := FN_GET_MDOCNO('M','IF143');  --등급변경 취소(생산오더별 자재투입량 취소)
    V_DOC_SEQNO_1 := 0;
    --TB_IFS022
    V_DOC_NO_2 := FN_GET_MDOCNO('M','IF144');  --폐품 취소
    V_DOC_SEQNO_2 := 0;
    
    V_STCK_QTY_CHG := 0;
    V_STCK_WGT_CHG := 0;
    
    OPEN PROD_CUR FOR
        SELECT IND_BCD, WRK_TYPE, LOT_NO, MATNR, PCNT, WGT, CHG_DT, 
               MATNR_M, LOT_NO_M, DOC_NO, DOC_SEQNO, SDOC_NO, SDOC_SEQNO
            INTO V_IND_BCD, V_WRK_TYPE, V_LOT_NO, V_MATNR, V_PCNT, V_WGT,V_PRFM_DT,
                 V_MATNR_M, V_LOT_NO_M, V_DOC_NO, V_DOC_SEQNO, V_SDOC_NO, V_SDOC_SEQNO
          FROM TB_WRK010
         WHERE WERKS = P_WERKS
           AND IND_BCD_M = V_IND_BCD_M
        ORDER BY IND_BCD, WRK_TYPE;   
    LOOP
    FETCH PROD_CUR INTO V_IND_BCD, V_WRK_TYPE, V_LOT_NO, V_MATNR, V_PCNT, V_WGT, V_PRFM_DT,
                        V_MATNR_M, V_LOT_NO_M, V_DOC_NO, V_DOC_SEQNO, V_SDOC_NO, V_SDOC_SEQNO;
    EXIT WHEN PROD_CUR %NOTFOUND;
        
        SELECT SAP_WRK_CD  INTO V_SAP_WRK_CD
          FROM TB_MAS012
         WHERE MACH_CD = P_MACH_CD; 
         
        -- 작업장코드 GRxx 로 변경, 
        V_SAP_WRK_CD := 'GR' || SUBSTR(V_SAP_WRK_CD || '03', 3, 2);
        
        IF V_WRK_TYPE = '1' THEN    --등급변경 취소
            V_STCK_QTY_CHG := V_STCK_QTY_CHG + V_PCNT;
            V_STCK_WGT_CHG := V_STCK_WGT_CHG + V_WGT;

            IF  V_SDOC_NO IS NOT NULL AND V_SDOC_NO <> 'E' THEN
                V_DOC_SEQNO_1 := V_DOC_SEQNO_1 +1 ;
                
                INSERT INTO TB_IFS014(AUFNR, POSNR, BUDAT, MATNR, MENGE,
                                        WERKS, LGORT, CHARG, WORKCENTERCODE, 
                                        MDOCNO, MDOCSEQ, MBLNR, MJAHR, 
                                        ZRESULT, MAKE_DATE, MAKER, GRCHK)
                               VALUES('', '10', V_PRFM_DT, V_MATNR, V_PCNT,
                                        P_WERKS, '2600', V_LOT_NO, V_SAP_WRK_CD,
                                        V_DOC_NO_1, TO_CHAR(V_DOC_SEQNO_1), V_SDOC_NO, V_SDOC_SEQNO, 
                                        'N', V_DATE, P_USERID, 'X');
            END IF;
            
            UPDATE TB_WRK002
               SET CNL_YN = 'Y',
                   CNL_RMK = P_CNL_RMK,
                   PRFM_GTHR_YN = 'N',
                   UPDDATE = V_DATE,
                   UPDID = P_USERID
             WHERE WERKS = P_WERKS
               AND IND_BCD = V_IND_BCD;
              
            UPDATE TB_INV001
       		   SET STCK_QTY = 0,
		           EA_QTY = 0,
		           WGT = V_WGT,
		           STCK_STA = '00',
		           UPDDATE = V_DATE,
		           UPDID = P_USERID,
		           DLFL = 'Y'
		     WHERE WERKS = P_WERKS
		       AND IND_BCD = V_IND_BCD;  
        ELSE                        --폐품 취소
            V_STCK_QTY_CHG := V_STCK_QTY_CHG + V_PCNT;
            V_STCK_WGT_CHG := V_STCK_WGT_CHG + V_WGT;
            
            IF  V_SDOC_NO IS NOT NULL AND V_SDOC_NO <> 'E' THEN
                V_DOC_SEQNO_2 := V_DOC_SEQNO_2 + 1;
                
                INSERT INTO TB_IFS022(WORKCENTERCODE, AUFNR, POSNR, BUDAT,
                                        MATNR, MENGE, WERKS, LGORT, CHARG,
                                        MDOCNO, MDOCSEQ, MBLNR, MJAHR, ZRESULT, MAKE_DATE)
                              VALUES(V_SAP_WRK_CD, '', '10', V_PRFM_DT,
                                    V_MATNR_M, V_PCNT, P_WERKS, '2600', V_LOT_NO_M,
                                    V_DOC_NO_2, TO_CHAR(V_DOC_SEQNO_2), V_SDOC_NO, V_SDOC_SEQNO, 'N', V_DATE);
            END IF;
            
            UPDATE TB_WRK004
               SET CNL_YN = 'Y',
                   CNL_RMK = P_CNL_RMK,
                   UPDDATE = V_DATE,
                   UPDID = P_USERID
             WHERE WERKS = P_WERKS
               AND IND_BCD = V_IND_BCD;
        END IF;
        
    END LOOP;
    CLOSE PROD_CUR;
    
    --등급변경 전 실적 생성
    SELECT PRFM_QTY, WGT
        INTO V_PRFM_QTY, V_WGT
      FROM TB_WRK002
     WHERE WERKS = P_WERKS
       AND IND_BCD = V_IND_BCD_M;      
    
    UPDATE TB_WRK002
       SET GRD_YN = 'N',
           CNL_YN = 'N',
           CNL_RMK = '',
           PRFM_GTHR_YN = 'Y',
           UPDDATE = V_DATE,
           UPDID = P_USERID
      WHERE WERKS = P_WERKS
        AND IND_BCD = V_IND_BCD_M;     
    
    UPDATE TB_INV001
       SET STCK_QTY = V_PRFM_QTY,
           EA_QTY = V_PRFM_QTY * 500,
           WGT = V_WGT,
           STCK_STA = '00',
           UPDDATE = V_DATE,
           UPDID = P_USERID,
           DLFL = 'N'
     WHERE WERKS = P_WERKS
       AND IND_BCD = V_IND_BCD_M;       

    -- 등급변경 개별 바코드 삭제
    DELETE FROM TB_WRK010
         WHERE WERKS = P_WERKS
           AND IND_BCD_M = V_IND_BCD_M;
        
--    IF LENGTH(V_DOC_SEQNO_1) > 0   THEN   --등급변경 취소
    IF V_DOC_SEQNO_1 > 0   THEN   --등급변경 취소

         --SAP FUNC ID
         SELECT RFCFN
           INTO RS_GRD_RFCFN
           FROM TB_ITFMA
          WHERE 1=1
            AND IFID = 'MES_IF_143';   --등급변경 취소

         --인터페이스 파라미터
         OPEN CUR_1 FOR
         SELECT 'MES_IF_143' AS I_IF_ID
              , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
           FROM dual;

         --인터페이스 상세 파라미터
         V_SQL := FN_IF_QUERY('MES_IF_143', V_DOC_NO_1);
         OPEN CUR_2 FOR V_SQL;

     END IF ;  

--     IF LENGTH(V_DOC_SEQNO_2) > 0   THEN   --폐품 취소
     IF V_DOC_SEQNO_2 > 0   THEN   --폐품 취소

         --SAP FUNC ID
         SELECT RFCFN
           INTO RS_DISPO_RFCFN
           FROM TB_ITFMA
          WHERE 1=1
            AND IFID = 'MES_IF_144';   --폐품 취소

         --인터페이스 파라미터
         OPEN CUR_3 FOR
         SELECT 'MES_IF_144' AS I_IF_ID
              , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
           FROM dual;

         --인터페이스 상세 파라미터
         V_SQL := FN_IF_QUERY('MES_IF_144', V_DOC_NO_2);
         OPEN CUR_4 FOR V_SQL;

    END IF ; 
    
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
    
--    FOR i IN 0..V_ARR_LIST.get_size-1 LOOP    
--        V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
--        V_OBJ           := TREAT (V_OBJ.get ('map') AS json_object_t);
--        V_IND_BCD       := V_OBJ.get_string('IND_BCD');
--
--
--        V_DOC_NO       := FN_GET_MDOCNO('M','IF129');  --실적
--        V_DOC_NO_INPUT := FN_GET_MDOCNO('M','IF143');  --투입
--        V_DOC_NO_DISPO := FN_GET_MDOCNO('M','IF144');  --폐품
--
--        V_DOC_SEQNO        := 0;
--        V_DOC_SEQNO_INPUT  := 0;
--        V_DOC_SEQNO_DISPO  := 0;
--
--        -- 실적 취소------------------------------------------------------------------------------------------
--        BEGIN
--                SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, STA, SDOC_NO, SDOC_SEQNO, PRFM_QTY, ROLLCNT, LOT_NO,WGT
--                  INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, V_STA, V_SDOC_NO, V_SDOC_SEQNO,
--                        V_PRFM_QTY, V_ROLLCNT, V_LOT_NO,V_WGT
--                  FROM TB_WRK002
--                 WHERE WERKS   = P_WERKS
--                   AND MACH_CD = P_MACH_CD
--                   AND IND_BCD = V_IND_BCD
--                   ;
--        EXCEPTION
--                WHEN NO_DATA_FOUND THEN
--                    V_ROLLCNT := 0;
--                    V_PRFM_QTY := 0;
--                WHEN OTHERS THEN
--                    V_ROLLCNT := 0;
--                    V_PRFM_QTY := 0;
--        END;
--
--        BEGIN
--                SELECT 'Y'
--                  INTO V_DMY
--                  FROM TB_INV010
--                 WHERE WERKS      = P_WERKS
--                   AND IND_BCD_M  = V_IND_BCD
--                   AND ROWNUM     = 1
--                   ;
--        EXCEPTION
--                WHEN NO_DATA_FOUND THEN
--                    V_DMY := 'N';
--                WHEN OTHERS THEN
--                    V_DMY := 'N';
--        END;        
--
--        IF V_DMY = 'Y'   THEN
--           RS_CODE      := 'E';
--           RS_MSG       := '후공정에 투입되어 실적취소를 할 수 없습니다.';
--           ROLLBACK;
--           RETURN;
--        END IF ;
--
--        BEGIN
--                SELECT ORDER_NO  
--                  INTO V_ORDER_NO 
--                  FROM TB_SCH018
--                 WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
--                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
--                   ;
--
--        EXCEPTION
--                WHEN NO_DATA_FOUND THEN
--                    V_ORDER_NO := '';
--                WHEN OTHERS THEN
--                    V_ORDER_NO := '';
--        END;
--
--        IF V_PRFM_QTY > 0 THEN
--
--                SELECT SAP_WRK_CD INTO V_SAP_WRK_CD
--                  FROM TB_MAS012
--                  WHERE MACH_CD = P_MACH_CD
--                  ;
--
--                IF V_STA = '00' THEN   --재고상태 정상
--
--                     V_DOC_NO := FN_GET_MDOCNO('M','IF129');
--                     V_DOC_SEQNO := V_DOC_SEQNO + 1;
--
--                     INSERT INTO TB_IFS007           --생산오더별실적 취소
--                     (
--                                           RUECK                        --SAP 확정번호
--                                         , RMZHL                        --SAP 확정카운터
--                                         , MDOCNO                       --MES 문서번호
--                                         , MDOCSEQ                      --MES 문서순번
--                                         , MAKE_DATE                    --등록일자 
--                                         , MAKER                        --등록자
--                                         , WORKCENTERCODE               --작업장코드(MES PK)
--                                         , AUFNR                        --오더번호
--                                         , ROLLCNT                      --권치수
--                                         , MBLNR                        --MBLNR
--                                         , LOTNO
--                     )                       
--                     VALUES
--                     (                     V_SDOC_NO                    --SAP 확정번호
--                                         , V_SDOC_SEQNO                 --SAP 확정카운터 
--                                         , V_DOC_NO                     --MES 문서번호
--                                         , V_DOC_SEQNO                  --MES 문서순번 
--                                         , SYSDATE                      --등록일자 
--                                         , P_USERID                     --등록자
--                                         , V_SAP_WRK_CD                 --작업장코드(MES PK)
--                                         , V_ORDER_NO                   --오더번호
--                                         , 0                            --권치수
--                                         , V_SDOC_NO                    --MBLNR   
--                                         , V_LOT_NO                     --LOT_NO
--                     );   
--
--                    --SAP FUNC ID
--                    SELECT RFCFN
--                      INTO RS_PRFM_RFCFN
--                      FROM TB_ITFMA
--                     WHERE 1=1
--                       AND IFID = 'MES_IF_129';   --생산오더별 실적 취소 TXN
--
--                    --인터페이스 파라미터
--                    OPEN CUR_1 FOR
--                    SELECT 'MES_IF_129' AS I_IF_ID
--                         , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
--                      FROM dual;
--
--                    --인터페이스 상세 파라미터
--                    V_SQL := FN_IF_QUERY('MES_IF_129', V_DOC_NO);
--                    OPEN CUR_2 FOR V_SQL;
--
--                   V_DOC_SEQNO_INPUT := 0 ;
--
--                   FOR INV010 IN (
--                                    SELECT LOT_NO_M    V_LOT_NO    --LOT_NO
--                                         , MATNR_M     V_MATNR     --자재코드
--                                         , INP_DT      V_INP_DT    --투입일자
--                                         , SDOC_NO     V_SDOC_NO    --SAP 문서번호 
--                                         , SDOC_SEQNO  V_SDOC_SEQNO --SAP 문서번호(년도)
--                                         , IND_BCD_M    V_IND_BCD_M  -- 자재개별바코드    
--                                         , USE_QTY     V_USE_QTY    
--                                         , WGT         V_WGT    
--                                      FROM TB_INV010     --자재투입이력   
--                                     WHERE WERKS   = P_WERKS
--                                       AND MACH_CD = P_MACH_CD
--                                       AND IND_BCD = V_IND_BCD
--                                  )
--                            LOOP
--                    BEGIN 
--                                    --로케이션 정보
--                                    SELECT LGPRO INTO V_STOR_LOC_CD
--                                      FROM TB_MAS001
--                                     WHERE WERKS = P_WERKS
--                                       AND MATNR = INV010.V_MATNR;
--
--                                EXCEPTION
--                                        WHEN NO_DATA_FOUND THEN
--                                            V_STOR_LOC_CD := '';
--                                        WHEN OTHERS THEN
--                                            V_STOR_LOC_CD := '';
--                                END;
--
--                                IF  NVL(V_STOR_LOC_CD, '') = '' THEN
--                                    RS_CODE := 'E';
--                                    RS_MSG := '저장위치 정보를 확인해주세요';
--                                    ROLLBACK;
--                                    RETURN;
--                                END IF;
--
--                                IF INV010.V_LOT_NO  IS NOT NULL THEN
--                                    V_DOC_SEQNO_INPUT  := V_DOC_SEQNO_INPUT  + 1;
--
--                                    INSERT INTO TB_IFS014           ----생산오더별 자재 투입량 취소
--                                    (
--                                            AUFNR	                --오더번호
--                                           ,POSNR	                --오더Item번호
--                                           ,BUDAT	                --투입일자(전기일)
--                                           ,MATNR	                --자재번호(투입자재)
--                                           ,MENGE	                --투입량
--                                           ,WERKS	                --플랜트
--                                           ,LGORT	                --저장위치
--                                           ,CHARG	                --LOT번호
--                                           ,WORKCENTERCODE	        --작업장코드(MES PK)
--                                           ,MDOCNO	                --MES 문서번호
--                                           ,MDOCSEQ	                --MES 문서순번
--                                           ,MBLNR	                --SAP 문서번호
--                                           ,MJAHR	                --SAP 문서번호(년도)
--                                           ,ZRESULT	                --SAP 결과값 Return( S:성공, E:오류 )
--                                           ,ZMESSAGE	            --SAP결과 메시지
--                                           ,ZRESULT_DATE	        --SAP 전송 시간
--                                           ,MAKE_DATE	            --등록일자
--                                           ,MAKER	                --등록자
--                                           ,IF_MES_KEY	            --MES Inserface Key(MES->SAP 인 경우만)
--                                           --,GRCHK
--                                    )
--                                    VALUES
--                                    (
--                                            V_ORDER_NO	            --오더번호
--                                           ,1	                    --오더Item번호
--                                           ,INV010.V_INP_DT	            --투입일자(전기일)
--                                           ,INV010.V_MATNR	                --자재번호(투입자재)
--                                           ,INV010.V_USE_QTY  /*V_PRFM_QTY*/	            --투입량 (실적은 EA)
--                                           ,P_WERKS	                --플랜트
--                                           ,V_STOR_LOC_CD	        --저장위치
--                                           ,INV010.V_LOT_NO	            --LOT번호
--                                           ,P_MACH_CD	            --작업장코드(MES PK)
--                                           ,V_DOC_NO_INPUT	            --MES 문서번호
--                                           ,V_DOC_SEQNO_INPUT	            --MES 문서순번
--                                           ,INV010.V_SDOC_NO	        --SAP 문서번호
--                                           ,INV010.V_SDOC_SEQNO	    --SAP 문서번호(년도)
--                                           ,NULL	                --SAP 결과값 Return( S:성공, E:오류 )
--                                           ,NULL	                --SAP결과 메시지
--                                           ,NULL	                --SAP 전송 시간
--                                           ,SYSDATE	                --등록일자
--                                           ,P_USERID	            --등록자
--                                           ,NULL	                --MES Inserface Key(MES->SAP 인 경우만)
--                                           --,''
--                                    );
--
--                                    UPDATE TB_INV003                         --자재투입
--                                       SET STCK_QTY = NVL(STCK_QTY, 0) + INV010.V_USE_QTY 
--                                         , USE_QTY  = NVL(USE_QTY, 0)  - INV010.V_USE_QTY 
--                                     WHERE WERKS = P_WERKS
--                                       AND MACH_CD = P_MACH_CD
--                                       AND IND_BCD = INV010.V_IND_BCD_M;
--
--                                END IF ;
--                            END LOOP ;
--
--                            DELETE FROM TB_INV010     --자재투입이력
--                            WHERE WERKS   = P_WERKS
--                              AND IND_BCD = V_IND_BCD
--                              AND MACH_CD = P_MACH_CD;
--
--                            --SAP FUNC ID
--                            SELECT RFCFN
--                              INTO RS_INPUT_RFCFN
--                              FROM TB_ITFMA
--                             WHERE 1=1
--                               AND IFID = 'MES_IF_143';   --생산오더별 실적 취소 TXN
--
--                            --인터페이스 파라미터
--                            OPEN CUR_5 FOR
--                            SELECT 'MES_IF_143' AS I_IF_ID
--                                 , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
--                              FROM dual;
--
--                            --인터페이스 상세 파라미터
--                            V_SQL := FN_IF_QUERY('MES_IF_143', V_DOC_NO_INPUT);
--                            OPEN CUR_6 FOR V_SQL;
--
--
--
--
--                    DELETE FROM TB_WRK008     --LOT 추적
--                      WHERE WERKS   = P_WERKS
--                      AND IND_BCD   = V_IND_BCD
--                     ;
--
--                    UPDATE TB_WRK002     --실적테이블(PS)
--                       SET CNL_YN = 'Y',
--                           CNL_RMK = P_CNL_RMK,                               
--                           UPDDATE = SYSDATE,
--                           UPDID   = P_USERID
--                    WHERE WERKS   = P_WERKS
--                      AND MACH_CD = P_MACH_CD
--                      AND IND_BCD = V_IND_BCD;
--
--                    DELETE FROM TB_INV001     --창고별 재고현황
--                    WHERE WERKS   = P_WERKS
--                      AND IND_BCD = V_IND_BCD
--                      AND MACH_CD = P_MACH_CD;
--
--
--                ELSIF V_STA = '10' THEN   --재고상태 투입
--                     RS_CODE      := 'E';
--                     RS_MSG       := '후공정에 투입되어 실적취소를 할 수 없습니다.';
--                     ROLLBACK;
--                     RETURN;
--                ELSIF V_STA = '20' THEN   --재고상태 생산실적
--                     RS_CODE      := 'E';
--                     RS_MSG       := '후공정에서 실적완료 되어 실적취소를 할 수 없습니다.';
--                     ROLLBACK;
--                     RETURN;
--                END IF;  
--
--        END IF;   
--
--        -- 폐품 취소------------------------------------------------------------------------------------------
--        BEGIN
--                SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, SDOC_NO, SDOC_SEQNO, DISPO_QTY, WGT, ROLLCNT, MMATNR, PRFM_DT, LOT_NO_M
--                  INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_SDOC_NO, V_SDOC_SEQNO, V_DISPO_QTY, V_DISPO_WGT, V_ROLLCNT,V_MATNR,V_PRFM_DT,V_LOT_NO
--                  FROM TB_WRK004
--                 WHERE WERKS   = P_WERKS
--                   AND MACH_CD = P_MACH_CD
--                   AND IND_BCD = V_IND_BCD
--                   ;
--        EXCEPTION
--                WHEN NO_DATA_FOUND THEN
--                    V_ROLLCNT := 0;
--                    V_DISPO_WGT := 0;
--                WHEN OTHERS THEN
--                    V_ROLLCNT := 0;
--                    V_DISPO_WGT := 0;
--        END;
--
--        BEGIN
--                SELECT ORDER_NO 
--                  INTO V_ORDER_NO 
--                  FROM TB_SCH018
--                 WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
--                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
--                   ;
--
--        EXCEPTION
--                WHEN NO_DATA_FOUND THEN
--                    V_ORDER_NO := '';
--                WHEN OTHERS THEN
--                    V_ORDER_NO := '';
--        END;
--
--        IF V_DISPO_WGT > 0 THEN   --폐품수량
--                SELECT SAP_WRK_CD INTO V_SAP_WRK_CD
--                  FROM TB_MAS012
--                  WHERE MACH_CD = P_MACH_CD;
--
--                     V_DOC_SEQNO_DISPO := V_DOC_SEQNO_DISPO + 1;
--
--                     INSERT INTO C           --폐품취소
--                     (
--                                             WORKCENTERCODE	--작업장코드(MES PK)
--                                            ,AUFNR	        --오더번호
--                                            ,POSNR	        --오더Item번호
--                                            ,BUDAT	        --투입일자(전기일)
--                                            ,MATNR	        --자재번호(투입자재)
--                                            ,MENGE	        --투입량
--                                            ,WERKS	        --플랜트
--                                            ,LGORT	        --저장위치
--                                            ,CHARG	        --LOT번호
--                                            ,MDOCNO	        --MES 문서번호
--                                            ,MDOCSEQ	    --MES 문서순번
--                                            ,MBLNR	        --SAP 문서번호
--                                            ,MJAHR	        --SAP 문서번호(년도)
--                                            ,ZRESULT	    --SAP 결과값 Return( S:성공, E:오류 )
--                                            ,ZRESULT_DATE    --전송 시간
--                                            ,MAKE_DATE	    --등록일자
--                                            ,IF_MES_KEY	    --MES Inserface Key(MES->SAP 인 경우만)
--                                            ,ZMESSAGE	    --SAP결과 메시지                                          
--                     )                       
--                     VALUES
--                     (               
--                                             V_SAP_WRK_CD	--작업장코드(MES PK)
--                                            ,V_ORDER_NO	    --오더번호
--                                            ,1	            --오더Item번호
--                                            ,V_PRFM_DT	    --투입일자(전기일)
--                                            ,V_MATNR	    --자재번호(투입자재)
--                                            ,V_DISPO_QTY	--투입량 (밀롤의 폐품은 중량)
--                                            ,P_WERKS	    --플랜트
--                                            ,'2000'	        --저장위치
--                                            ,V_LOT_NO	    --LOT번호
--                                            ,V_DOC_NO_DISPO    --MES 문서번호
--                                            ,V_DOC_SEQNO_DISPO --MES 문서순번
--                                            ,V_SDOC_NO	    --SAP 문서번호
--                                            ,V_SDOC_SEQNO	--SAP 문서번호(년도)
--                                            ,'N'	        --SAP 결과값 Return( S:성공, E:오류 )
--                                            ,NULL           --전송 시간
--                                            ,SYSDATE	    --등록일자
--                                            ,NULL	        --MES Inserface Key(MES->SAP 인 경우만)
--                                            ,NULL	        --SAP결과 메시지                                          
--                     );                  
--
--                     --SAP FUNC ID
--                     SELECT RFCFN
--                       INTO RS_DISPO_RFCFN
--                       FROM TB_ITFMA
--                      WHERE 1=1
--                        AND IFID = 'MES_IF_144';   --생산오더별 실적 취소 TXN
--
--                     --인터페이스 파라미터
--                     OPEN CUR_3 FOR
--                     SELECT 'MES_IF_144' AS I_IF_ID
--                          , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
--                       FROM dual;
--
--                     --인터페이스 상세 파라미터
--                     V_SQL := FN_IF_QUERY('MES_IF_144', V_DOC_NO_DISPO);
--                     OPEN CUR_4 FOR V_SQL;
--
--                     UPDATE TB_WRK004     --폐품테이블(PS)
--                        SET CNL_YN = 'Y',
--                            UPDDATE = SYSDATE,
--                            UPDID   = P_USERID
--                      WHERE WERKS   = P_WERKS
--                        AND MACH_CD = P_MACH_CD
--                        AND IND_BCD = V_IND_BCD;
--
--                    ------------------------------------------------------------
--                    UPDATE TB_INV003                         --자재투입
--                       SET STCK_QTY = NVL(STCK_QTY, 0)   + V_DISPO_QTY
--                         , USE_QTY   = NVL(USE_QTY, 0)   - V_DISPO_QTY
--                         , DISPO_QTY = NVL(DISPO_QTY, 0) - V_DISPO_QTY
--                     WHERE WERKS = P_WERKS
--                       AND MACH_CD = P_MACH_CD
--                       AND IND_BCD = V_IND_BCD_M;
--        END IF;            
--
--        V_TOT_QTY := 0 ;
--        SELECT
--               SUM(QTY)
--        INTO   V_TOT_QTY     
--        FROM 
--        (
--                        SELECT NVL(PRFM_QTY,0)   QTY
--                        FROM TB_WRK002 
--                         WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
--                           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
--                           AND NVL(CNL_YN, 'N') =  'N'
--                        UNION ALL
--                        SELECT NVL(DISPO_QTY,0)  QTY
--                        FROM TB_WRK004 
--                         WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
--                           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
--                           AND NVL(CNL_YN, 'N') =  'N'
--        ) ;
--
--        UPDATE TB_SCH018
--           SET COMP_YN      = 'N', PRFM_QTY = V_TOT_QTY
--        WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
--          AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
--
--    END LOOP;
--
--    IF CUR_1%ISOPEN = FALSE THEN
--        OPEN CUR_1 FOR SELECT 1 FROM dual;
--    END IF;
--
--    IF CUR_2%ISOPEN = FALSE THEN
--        OPEN CUR_2 FOR SELECT 1 FROM dual;
--    END IF;
--
--    IF CUR_3%ISOPEN = FALSE THEN
--        OPEN CUR_3 FOR SELECT 1 FROM dual;
--    END IF;
--
--    IF CUR_4%ISOPEN = FALSE THEN
--        OPEN CUR_4 FOR SELECT 1 FROM dual;
--    END IF;
--
--    IF CUR_5%ISOPEN = FALSE THEN
--        OPEN CUR_5 FOR SELECT 1 FROM dual;
--    END IF;
--
--    IF CUR_6%ISOPEN = FALSE THEN
--        OPEN CUR_6 FOR SELECT 1 FROM dual;
--    END IF;
--
--    IF CUR_7%ISOPEN = FALSE THEN
--        OPEN CUR_7 FOR SELECT 1 FROM dual;
--    END IF;
--
--    IF CUR_8%ISOPEN = FALSE THEN
--        OPEN CUR_8 FOR SELECT 1 FROM dual;
--    END IF;


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
