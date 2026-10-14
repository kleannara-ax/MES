
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
 * PROGRAM ID    : SP_POP_WRK30_I09
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
 * 2023/02/28    1.0.1   김병무         등급변경취소 조건 Validation 추가
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

    -- 등급변경 취소 체크용    
    V_GRD_YN            TB_WRK002.GRD_YN%TYPE;
    V_YMCHK             TB_MAS011.YMCHK%TYPE;   --실적등록 가능 여부    
    V_STCK_QTY          TB_INV001.STCK_QTY%TYPE;
    V_STCK_STA          TB_INV001.STCK_STA%TYPE;
    V_STOR_LOC_CD       TB_INV001.STOR_LOC_CD%TYPE;
    
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
            RS_MSG := '등급변경 취소 가능한 월이 아닙니다.';
            ROLLBACK;
            RETURN;
        END IF;
    
        
        SELECT SAP_WRK_CD  INTO V_SAP_WRK_CD
          FROM TB_MAS012
         WHERE MACH_CD = P_MACH_CD; 
         
        -- 작업장코드 GRxx 로 변경, 
        V_SAP_WRK_CD := 'GR' || SUBSTR(V_SAP_WRK_CD || '03', 3, 2);
        
        IF V_WRK_TYPE = '1' THEN    --등급변경 취소
            -- 등급변경 취소 검사
            BEGIN
                SELECT NVL(GRD_YN, 'N')
                  INTO V_GRD_YN
                  FROM TB_WRK002
                 WHERE WERKS   = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IND_BCD = V_IND_BCD
                   AND NVL(CNL_YN,'N') = 'N';
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_GRD_YN := 'N';
            END;
    
            IF V_GRD_YN <> 'Y'  THEN
               RS_CODE      := 'E';
               RS_MSG       := '등급변경된 바코드가 아닙다.\n' || V_IND_BCD || ' 등급변경 취소 하십시오.';
               ROLLBACK;
               RETURN;
            END IF;

            BEGIN
            SELECT STOR_LOC_CD, STCK_QTY, STCK_STA
                INTO V_STOR_LOC_CD, V_STCK_QTY, V_STCK_STA
              FROM TB_INV001
             WHERE WERKS = P_WERKS
               AND IND_BCD = V_IND_BCD;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_STCK_QTY := 0;
            END;
            
            IF V_STCK_STA <> '00' THEN
                IF V_STCK_STA = '70' THEN
                    RS_MSG       := '출고 상태이므로 실적 취소를 할 수 없습니다';
                ELSIF V_STCK_STA = '80' THEN
                    RS_MSG       := '출고요청 상태이므로 실적 취소를 할 수 없습니다';
                ELSE
                    RS_MSG       := '재고상태가 ' || V_STCK_STA || ' 이므로 실적 취소를 할 수 없습니다';
                END IF;
                RS_CODE      := 'E';
                
                ROLLBACK;
                RETURN;
            END IF;

            IF V_STOR_LOC_CD <> '2600' THEN
                RS_CODE      := 'E';
                RS_MSG       := '재고위치가 ' || V_STOR_LOC_CD || ' 이므로 실적 취소를 할 수 없습니다';
                ROLLBACK;
                RETURN;
            END IF;
        
        
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
