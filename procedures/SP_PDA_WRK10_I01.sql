
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_PDA_WRK10_I01" 
(
    P_TYPE           IN    varchar2, -- LIST, SAVE(적합), SAVE1(부적합)
	P_JSON_STR       IN    CLOB,
    P_SUCCESS       OUT    varchar2,
	P_ERR_MSG       OUT    VARCHAR2,
    P_DOC_NO        OUT    varchar2,        --SAP 재고이전 문서
    P_RS_LIST       OUT    SYS_REFCURSOR
)
AS 
/*==============================================================================
 * PROGRAM ID    : SP_PDA_WRK10_I01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 공정재고상태변경  등록{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 공정재고상태변경  등록{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박충식 {최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/18 {최초 작성일자 기술}
 * SYSTEM NAME   : PDA
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/18    1.0.0   박충식         Initial Version 
 * 2022/07/24    1.0.0   유상호         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_INV008] : (.R..) 재고실사 작업지시정보                                
 *       - [TB_MAS003] : (.R..) 저장위치 마스터                            
   *=============================================================================*/
    --프로그램 ID
    V_PRG_NM          VARCHAR2(100)  := 'SP_PDA_WRK10_I01';     -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_OBJECT_T;
    V_OBJ            JSON_OBJECT_T;
    V_OBJ2           JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS            TB_INV001.WERKS%TYPE;          --플랜트코드
    V_IND_BCD	       TB_INV001.IND_BCD%TYPE;        --개별바코드
    V_STOR_LOC_CD_FR   TB_INV001.STOR_LOC_CD%TYPE;    --저장위치
    V_STOR_LOC_CD_TO   TB_INV001.STOR_LOC_CD%TYPE;    --저장위치
    V_LOT_NO	       TB_INV001.LOT_NO%TYPE;        --LOT번호
    V_STCK_QTY	       TB_INV001.STCK_QTY%TYPE;      --재고수량   
    V_UNIT             TB_INV001.UNIT%TYPE;          --이동단위
    V_MATNR	           TB_INV001.MATNR%TYPE;          --품목코드	
    V_MACH_CD          TB_INV001.MACH_CD%TYPE;          --설비코드
    V_MDOCNO           TB_IFS009.MDOCNO%TYPE;         --MES 문서번호
    V_STCK_STA         TB_INV001.STCK_STA%TYPE;         --재고상태 

BEGIN
    OPEN P_RS_LIST FOR 
    SELECT NULL FROM DUAL WHERE ROWNUM = 0;    

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);
    V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=       V_JSON.get_string('SES_WAREKY');

    /* 조건값 할당 */
    V_RANGE_SQL          :=       V_JSON.get_string('RANGE_SQL');                   -- 

    --V_WERKS              :=       V_JSON.get_string('WERKS');                       -- 플랜트코드
    V_IND_BCD            :=       V_JSON.get_string('IND_BCD');                     -- 개별바코드  
    --V_STOR_LOC_CD        :=       V_JSON.get_string('STOR_LOC_CD');                 -- 저장위치  


    IF P_TYPE = 'LIST' THEN 

        V_SQL := ' SELECT INV001.WERKS	        WERKS	    --플랜트코드
                        , INV001.IND_BCD	    IND_BCD	    --개별바코드
                        , INV001.STOR_LOC_CD    STOR_LOC_CD --저장위치	
                        , MAS003.STOR_LOC_NM    STOR_LOC_NM --저장위치명
                        , INV001.MATNR	        MATNR	    --자재코드
                        , MAS001.MATNR_NM       MATNR_NM    --자재명    
                        , INV001.LOT_NO	        LOT_NO	    --LOT NO
                        , INV001.STCK_QTY	    STCK_QTY	--재고수량
                        , INV001.UNIT	        UNIT        --단위
                        , INV001.SUPY_CD	    SUPY_CD     --공급업체코드
                        , MAS009.CUST_NM        CUST_NM     --공급업체명   
                        , INV001.STCK_STA              STCK_STA    --재고상태
                        , FN_CD_VAL(''STCK_STA'', INV001.STCK_STA) STCK_STA_NM --재고상태명    
                     FROM TB_INV001 INV001    --창고별 재고현황
                        , TB_MAS009 MAS009    --거래처(고객사/공급사) 마스터
                        , TB_MAS001 MAS001    --플랜트별 제품/자재 마스터
                        , TB_MAS003 MAS003    --저장위치 마스터(공정창고내 저장위치 포함)
                    WHERE INV001.SUPY_CD     = MAS009.CUST_CD(+)
                      AND MAS009.CUST_DIV(+) = ''V'' 
                      AND INV001.MATNR       = MAS001.MATNR(+) 
                      AND INV001.WERKS       = MAS001.WERKS(+)          
                      AND INV001.WERKS       = MAS003.WERKS(+)
                      AND INV001.STOR_LOC_CD = MAS003.STOR_LOC_CD(+)
                     -- AND INV001.STCK_STA    = ''30''     --STCK_STA  : 00 (정상)  30(불합격)	
                     --AND INV001.STCK_QTY    > 0
           ' ;

        V_SQL := V_SQL || ' AND INV001.IND_BCD = ''' || V_IND_BCD || '''';            --개별바코드 

        BEGIN           
     		OPEN P_RS_LIST FOR V_SQL;

        EXCEPTION           
        WHEN OTHERS THEN 
            P_SUCCESS           := 'N';
            E_SQL_ERR_CD        := SQLCODE;
            E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
            RETURN;           
        END;  
    ELSIF P_TYPE = 'SAVE' THEN      --적합처리

        V_WERKS               :=       V_JSON.get_string('WERKS');          --플랜트코드  
        V_MACH_CD             :=        V_JSON.get_string('MACH_CD');          --설비코드 
        V_STOR_LOC_CD_FR      :=       V_JSON.get_string('STOR_LOC_CD');    --저장위치
        V_IND_BCD             :=       V_JSON.get_string('IND_BCD');        --개별바코드 
        V_MATNR	              :=       V_JSON.get_string('MATNR');          --품목코드	
        V_LOT_NO	          :=       V_JSON.get_string('LOT_NO');         --LOT번호
        V_STCK_QTY	          :=       V_JSON.get_string('STCK_QTY');       --재고수량   
        V_UNIT                :=       V_JSON.get_string('UNIT');           --이동단위
        V_STCK_STA            :=       V_JSON.get_string('STCK_STA');       --재고상태

        IF V_STCK_STA = '00' THEN
            P_SUCCESS           := 'N';
            P_ERR_MSG := '재고상태가 정상재고이기 때문에 적합처리를 할 수 없습니다.';
            ROLLBACK;
            RETURN;
        END IF;

        --SELECT FN_GET_MDOCNO(V_WERKS, 'IF131')  INTO V_MDOCNO  FROM DUAL ;   --MES 문서번호

        SELECT LGPRO  INTO V_STOR_LOC_CD_TO
           FROM TB_MAS001
          WHERE WERKS = V_WERKS
            AND MATNR = V_MATNR;

        UPDATE TB_INV001                            --창고별 재고현황
           SET STCK_STA =  '00'                     --STCK_STA  : 00 (정상)  30(불합격)
             , STOR_LOC_CD = V_STOR_LOC_CD_TO          --저장위치 변경
             , UPDDATE	= SYSDATE                   --수정일시
             , UPDID	= V_SESS_USER_ID            --수정자ID
         WHERE WERKS               = V_WERKS          --플랜트코드        
           AND STOR_LOC_CD         = V_STOR_LOC_CD_FR    --저장위치
           AND IND_BCD             = V_IND_BCD        --개별바코드 
           AND MATNR	           = V_MATNR;          --품목코드	

         UPDATE TB_WRK001
            SET PRFM_GTHR_YN = 'Y',
                STA = '00'
          WHERE WERKS = V_WERKS
            AND MACH_CD = V_MACH_CD
            AND IND_BCD = V_IND_BCD;

--         INSERT INTO TB_IFS009     --재고 이전 TXN(이동유형:311) 
--         (
--                 BWART	            --이동유형,(재고이전:311, 등급변경:309, 재고실사: )
--                ,WERKS_FROM	        --플랜트(From)
--                ,WERKS_TO	        --플랜트(To)
--                ,MATNR_FROM	        --자재번호(From),등급변경시, 재고이전(From,To 동일)
--                ,MATNR_TO	        --자재번호(To),등급변경시, 재고이전(From,To 동일)
--                ,LGORT_FROM	        --저장위치(From), 재고이전시, 등급변경(From,To 동일)
--                ,LGORT_TO	        --저장위치(To), 재고이전시, 등급변경(From,To 동일)
--                ,CHARG_FROM	        --LOT번호(From)
--                ,CHARG_TO	        --LOT번호(To)
--                ,MENGE	            --이동량
--                ,MEINS	            --이동단위
--                ,FAULTY	            --부적합 지시자
--                ,MDOCNO	            --MES 문서번호
--                ,MDOCSEQ	        --MES 문서순번
--                ,MBLNR	            --SAP 문서번호
--                ,MJAHR	            --SAP 문서번호(년도)
--                ,ZRESULT	        --SAP 결과값 Return( S:성공, E:오류 )
--                ,ZMESSAGE	        --SAP결과 메시지
--                ,ZRESULT_DATE	    --SAP 전송 시간
--                ,IF_MES_KEY         --MES Inserface Key(MES->SAP 인 경우만)
--                ,MAKE_DATE	        --등록일자
--                ,MAKER	            --등록자         
--         ) VALUES (
--                 '311'	            --이동유형,(재고이전:311, 등급변경:309, 재고실사: )
--                ,V_WERKS	        --플랜트(From)
--                ,V_WERKS	        --플랜트(To)
--                ,V_MATNR	        --자재번호(From),등급변경시, 재고이전(From,To 동일)
--                ,V_MATNR	        --자재번호(To),등급변경시, 재고이전(From,To 동일)
--                ,'2020'	            --저장위치(From), 재고이전시, 등급변경(From,To 동일)
--                ,V_STOR_LOC_CD_TO	    --저장위치(To), 재고이전시, 등급변경(From,To 동일)
--                ,V_LOT_NO	        --LOT번호(From)
--                ,V_LOT_NO	        --LOT번호(To)
--                ,V_STCK_QTY	        --이동량
--                ,V_UNIT	            --이동단위
--                ,''	                --부적합 지시자
--                ,V_MDOCNO	        --MES 문서번호
--                ,1 	                --MES 문서순번
--                ,NULL	            --SAP 문서번호
--                ,NULL	            --SAP 문서번호(년도)
--                ,'N'	            --SAP 결과값 Return( S:성공, E:오류 )
--                ,NULL	            --SAP결과 메시지
--                ,NULL	            --SAP 전송 시간
--                ,NULL               --MES Inserface Key(MES->SAP 인 경우만)                
--                ,SYSDATE	        --등록일자
--                ,V_SESS_USER_ID	    --등록자         
--         );
--         P_DOC_NO := V_MDOCNO;
     ELSIF P_TYPE = 'SAVE1' THEN        --부적합 처리
        V_WERKS              :=        V_JSON.get_string('WERKS');          --플랜트코드
        V_MACH_CD             :=        V_JSON.get_string('MACH_CD');          --설비코드  
        V_STOR_LOC_CD_FR         :=       V_JSON.get_string('STOR_LOC_CD');    --저장위치
        V_IND_BCD             :=       V_JSON.get_string('IND_BCD');        --개별바코드 
        V_MATNR	              :=       V_JSON.get_string('MATNR');          --품목코드	
        V_LOT_NO	          :=       V_JSON.get_string('LOT_NO');         --LOT번호
        V_STCK_QTY	          :=       V_JSON.get_string('STCK_QTY');       --재고수량   
        V_UNIT                :=       V_JSON.get_string('UNIT');           --이동단위
        V_STCK_STA            :=       V_JSON.get_string('STCK_STA');       --재고상태

        IF V_STCK_STA = '40' THEN
            P_SUCCESS           := 'N';
            P_ERR_MSG := '재고상태가 불용재고이기 때문에 부적합처리를 할 수 없습니다.';
            ROLLBACK;
            RETURN;
        END IF;

        --SELECT FN_GET_MDOCNO(V_WERKS, 'IF131')  INTO V_MDOCNO  FROM DUAL ;   --MES 문서번호

        UPDATE TB_INV001     --창고별 재고현황
           SET STCK_STA =  '40'                    --STCK_STA  : 00 (정상)  30(불합격)
             , STOR_LOC_CD = '2020'
             , UPDDATE	= SYSDATE                  --수정일시
             , UPDID	= V_SESS_USER_ID           --수정자ID
          WHERE
               WERKS               = V_WERKS          --플랜트코드        
           AND STOR_LOC_CD         = V_STOR_LOC_CD_FR    --저장위치
           AND IND_BCD             = V_IND_BCD        --개별바코드 
           AND MATNR	           = V_MATNR          --품목코드	
         ;
         UPDATE TB_WRK001
            SET PRFM_GTHR_YN = 'N',
                STA = '40'
          WHERE WERKS = V_WERKS
            AND MACH_CD = V_MACH_CD
            AND IND_BCD = V_IND_BCD;

--         INSERT INTO TB_IFS009     --재고 이전 TXN(이동유형:311) 
--         (
--                 BWART	            --이동유형,(재고이전:311, 등급변경:309, 재고실사: )
--                ,WERKS_FROM	        --플랜트(From)
--                ,WERKS_TO	        --플랜트(To)
--                ,MATNR_FROM	        --자재번호(From),등급변경시, 재고이전(From,To 동일)
--                ,MATNR_TO	        --자재번호(To),등급변경시, 재고이전(From,To 동일)
--                ,LGORT_FROM	        --저장위치(From), 재고이전시, 등급변경(From,To 동일)
--                ,LGORT_TO	        --저장위치(To), 재고이전시, 등급변경(From,To 동일)
--                ,CHARG_FROM	        --LOT번호(From)
--                ,CHARG_TO	        --LOT번호(To)
--                ,MENGE	            --이동량
--                ,MEINS	            --이동단위
--                ,FAULTY	            --부적합 지시자
--                ,MDOCNO	            --MES 문서번호
--                ,MDOCSEQ	        --MES 문서순번
--                ,MBLNR	            --SAP 문서번호
--                ,MJAHR	            --SAP 문서번호(년도)
--                ,ZRESULT	        --SAP 결과값 Return( S:성공, E:오류 )
--                ,ZMESSAGE	        --SAP결과 메시지
--                ,ZRESULT_DATE	    --SAP 전송 시간
--                ,IF_MES_KEY         --MES Inserface Key(MES->SAP 인 경우만)
--                ,MAKE_DATE	        --등록일자
--                ,MAKER	            --등록자         
--         ) VALUES (
--                 '311'	            --이동유형,(재고이전:311, 등급변경:309, 재고실사: )
--                ,V_WERKS	        --플랜트(From)
--                ,V_WERKS	        --플랜트(To)
--                ,V_MATNR	        --자재번호(From),등급변경시, 재고이전(From,To 동일)
--                ,V_MATNR	        --자재번호(To),등급변경시, 재고이전(From,To 동일)
--                ,V_STOR_LOC_CD_FR	    --저장위치(From), 재고이전시, 등급변경(From,To 동일)
--                ,'2020'	            --저장위치(To), 재고이전시, 등급변경(From,To 동일)
--                ,V_LOT_NO	        --LOT번호(From)
--                ,V_LOT_NO	        --LOT번호(To)
--                ,V_STCK_QTY	        --이동량
--                ,V_UNIT	            --이동단위
--                ,'X'	            --부적합 지시자
--                ,V_MDOCNO	        --MES 문서번호
--                ,1 	                --MES 문서순번
--                ,NULL	            --SAP 문서번호
--                ,NULL	            --SAP 문서번호(년도)
--                ,'N'	            --SAP 결과값 Return( S:성공, E:오류 )
--                ,NULL	            --SAP결과 메시지
--                ,NULL	            --SAP 전송 시간
--                ,NULL               --MES Inserface Key(MES->SAP 인 경우만)                
--                ,SYSDATE	        --등록일자
--                ,V_SESS_USER_ID	    --등록자         
--         );
--        P_DOC_NO := V_MDOCNO;
    END IF;

    P_SUCCESS := 'Y';
    COMMIT;

    EXCEPTION
    WHEN E_EXCEPTION_USER THEN

        -- 에러 내역 SET
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        ROLLBACK;

    WHEN OTHERS THEN
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
