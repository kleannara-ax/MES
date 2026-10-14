--------------------------------------------------------
--  DDL for Procedure SP_PDA_INV03_I01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_PDA_INV03_I01" 
(
    P_TYPE           IN     varchar2, -- LIST, SAVE(적합), SAVE1(부적합)
	P_JSON_STR       IN     CLOB,
    P_DOC_NO        OUT     VARCHAR2,
	P_SUCCESS       OUT     varchar2,
	P_ERR_MSG       OUT     VARCHAR2,
    P_RS_LIST       OUT     SYS_REFCURSOR
)
AS 
/*==============================================================================
 * PROGRAM ID    : SP_PDA_INV03_I01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 자재/완제품 반납요청{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 자재/완제품 반납요청{프로그램에 대한 상세한 내용 기술}
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
 * 2022/07/18    1.1.0   유상호         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_INV008] : (.R..) 재고실사 작업지시정보                                
 *       - [TB_MAS003] : (.R..) 저장위치 마스터                            
   *=============================================================================*/
    --프로그램 ID
    V_PRG_NM          VARCHAR2(100)  := 'SP_PDA_INV03_I01';     -- PROCEDURE NAME

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
    V_STOR_LOC_CD      TB_INV001.STOR_LOC_CD%TYPE;    --저장위치
    V_STOR_LOC_CD_TO   TB_INV001.STOR_LOC_CD%TYPE;    --저장위치

    V_LOT_NO	       TB_INV001.LOT_NO%TYPE;        --LOT번호
    V_STCK_QTY	       TB_INV001.STCK_QTY%TYPE;      --재고수량   
    V_UNIT             varchar2(20);          --이동단위
    V_MATNR	           TB_INV001.MATNR%TYPE;          --품목코드	
    
    V_DOC_NO            VARCHAR2(4000);           --MES 문서번호
    V_DOC_SEQNO         TB_INV002.DOC_SEQ%TYPE;         --MES 문서번호 
    V_DOC_NO_PRE        TB_INV002.DOC_NO%TYPE;         --MES 문서번호 
    V_DOC_SEQNO_PRE     TB_INV002.DOC_SEQ%TYPE;         --MES 문서번호 
    V_STCK_KY           TB_INV001.STCK_KY%TYPE;
    V_LOT_NUM           TB_INV001.LOT_NUM%TYPE;
    V_BS_WGT            TB_INV001.BS_WGT%TYPE;
    V_CON_TYPE          TB_INV001.CON_TYPE%TYPE;
    V_PACK_TYPE         TB_INV001.PACK_TYPE%TYPE;
    V_PRD_DT            TB_INV001.PRD_DT%TYPE;
    V_REQ_DT            TB_INV001.PRD_DT%TYPE;
    V_STCK_STA          TB_INV001.STCK_STA%TYPE;
    V_VBELN_POSNR       VARCHAR2(20);
    V_VBELN             TB_INV001.VBELN%TYPE; 
    V_POSNR              TB_INV001.POSNR%TYPE; 
    V_KUNNR             TB_INV001.KUNNR%TYPE; 
    
    V_IF_STA            TB_INV002.IF_STA%TYPE;
    V_DLFL              TB_INV002.DLFL%TYPE;
    V_DATE              DATE := SYSDATE;
BEGIN
    OPEN P_RS_LIST FOR 
    SELECT NULL FROM DUAL WHERE ROWNUM = 0;    

   V_DEBUG := 'Y';
   V_RUN_SQL := 'Y';


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
                        , TO_CHAR(INV001.STCK_QTY, ''FM999,999,999,990.099'')	    STCK_QTY	--재고수량
                        , INV001.UNIT	        UNIT        --단위
                        , FN_CD_VAL(''STCK_STA'', INV001.STCK_STA)    STCK_STA_NM   --추가      
                        , INV001.STCK_STA                   --재고상태          --추가
                        , INV001.STCK_KY                    --WMS 재고 KEY     --추가   
                        , INV001.LOT_NUM                    --WMS 재고속성KEY   --추가
						, MAS001.MATNR_DIV		MATNR_DIV	
                     FROM TB_INV001 INV001    --창고별 재고현황
                        , TB_MAS001 MAS001    --플랜트별 제품/자재 마스터
                        , TB_MAS003 MAS003    --저장위치 마스터(공정창고내 저장위치 포함)
                    WHERE INV001.MATNR       = MAS001.MATNR(+) 
                      AND INV001.WERKS       = MAS001.WERKS(+)          
                      AND INV001.WERKS       = MAS003.WERKS(+)
                      AND INV001.STOR_LOC_CD = MAS003.STOR_LOC_CD(+)
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
    ELSIF P_TYPE = 'LIST2' THEN     --반납요청이력
        V_WERKS               :=       V_JSON.get_string('WERKS');          --플랜트코드
        V_REQ_DT              :=       V_JSON.get_string('REQ_DT');           --일자
        V_IF_STA              :=       V_JSON.get_string('IF_STA');           --전송상태(요청상태)
    
        V_SQL := ' SELECT I002.DOC_NO,
                          I002.DOC_SEQ,
                          I002.MATNR,
                          M001.MATNR_NM,
                          TO_CHAR(I002.QTY, ''FM999,999,999,990.09'') AS QTY,
                          I002.UNIT,
                          I002.IF_STA
                     FROM TB_INV002 I002,
                          TB_MAS001 M001
                    WHERE I002.WERKS = M001.WERKS(+)
                      AND I002.MATNR = M001.MATNR(+)
                      AND I002.DLFL = ''C''
                      AND I002.WERKS = ''' || V_WERKS || '''
                      AND TO_CHAR(I002.REGDATE, ''YYYYMMDD'') = ''' || V_REQ_DT || '''
                      AND I002.IF_STA = ''' || V_IF_STA || '''
                   ORDER BY I002.REGDATE ';   
        
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
                     
    ELSIF P_TYPE = 'SAVE' THEN      --반품요청

        V_WERKS               :=       V_JSON.get_string('WERKS');          --플랜트코드        
        V_STOR_LOC_CD         :=       V_JSON.get_string('STOR_LOC_CD');    --저장위치
        V_IND_BCD             :=       V_JSON.get_string('IND_BCD');        --개별바코드 
        V_MATNR	              :=       V_JSON.get_string('MATNR');          --품목코드	
        V_STCK_QTY            :=       REPLACE(V_JSON.get_string('STCK_QTY'), ',');       --재고수량	
        V_UNIT	              :=       V_JSON.get_string('UNIT');           --단위
        V_STCK_STA            :=       V_JSON.get_string('STCK_STA');       --재고상태            추가
        V_LOT_NO              :=       V_JSON.get_string('LOT_NO');         --LOT번호
        V_STCK_KY             :=       V_JSON.get_string('STCK_KY');        --WMS 재고 KEY        추가
        V_LOT_NUM             :=       V_JSON.get_string('LOT_NUM');        --WMS 재고속성KEY     추가
        
        IF  NVL(V_STCK_QTY, 0) <=0 THEN
            P_SUCCESS := 'N';
            P_ERR_MSG := V_MATNR || ' 자재는 재고수량이 0 으로 반납 할 수 없습니다.';
            ROLLBACK;
            RETURN;
        END IF;
        
        IF  NVL(V_STCK_KY, ' ') = ' ' THEN
            P_SUCCESS := 'N';
            P_ERR_MSG := V_MATNR || ' 자재는 WMS에서 불출된 자재가 아니어서 반납 할 수 없습니다.';
            ROLLBACK;
            RETURN;
        END IF;
        
        BEGIN
        SELECT A.DLFL, A.IF_STA
            INTO V_DLFL, V_IF_STA
          FROM(
                SELECT *
                  FROM TB_INV002
                 WHERE REQ_DIV = '20'
                   AND WERKS = V_WERKS
                   AND MATNR = V_MATNR
                   AND IND_BCD = V_IND_BCD
                ORDER BY REGDATE DESC) A
         WHERE ROWNUM = 1;        
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_DLFL := 'D';
                V_IF_STA := 'N';
        END;
        
        IF NVL(V_DLFL, ' ') = 'C' AND NVL(V_IF_STA, ' ') = 'N'THEN
            P_SUCCESS := 'N';
            P_ERR_MSG := V_MATNR || ' 자재는 이미 반납요청한 자재입니다.';
            ROLLBACK;
            RETURN;
        END IF;
        
        SELECT PRD_DT, BS_WGT, CON_TYPE, PACK_TYPE, VBELN, POSNR, KUNNR
            INTO V_PRD_DT, V_BS_WGT, V_CON_TYPE, V_PACK_TYPE, V_VBELN, V_POSNR, V_KUNNR
          FROM TB_INV001
         WHERE WERKS = V_WERKS
           AND STOR_LOC_CD = V_STOR_LOC_CD
           AND IND_BCD = V_IND_BCD;
           
        --자재/완제품반납요청 MES 문서번호
        SELECT FN_GET_MDOCNO('M', 'IF400')  INTO V_DOC_NO  FROM DUAL ;   
        V_DOC_SEQNO := '1';
        
        
        BEGIN
        SELECT A.STOR_LOC_FR INTO V_STOR_LOC_CD_TO
          FROM (
                SELECT STOR_LOC_FR 
                  FROM TB_INV007
                 WHERE WERKS = V_WERKS
                   AND REQ_DIV IN ('10', '40', '50')
                   AND IND_BCD = V_IND_BCD 
                ORDER BY REGDATE DESC) A
         WHERE ROWNUM = 1;       
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
                P_ERR_MSG := V_MATNR || ' 자재의 WMS 저장위치가 누락되었습니다.';
                P_SUCCESS := 'N';
                ROLLBACK;
                RETURN;
         END;
         
        --자재/완제품 반납요청 이력
        INSERT INTO TB_INV002 (DOC_NO, DOC_SEQ, DLFL, REQ_DIV, 
                                WERKS, MATNR, QTY, UNIT, STOR_LOC_CD, STCK_STA, 
                                STCK_KY, LOT_NUM, IND_BCD, LOT_NO, OVBELN, OPOSNR, IF_STA, REGDATE, REGID)
                    VALUES (V_DOC_NO, V_DOC_SEQNO, 'C', '20', 
                               V_WERKS, V_MATNR, V_STCK_QTY, V_UNIT, V_STOR_LOC_CD, '00', 
                               V_STCK_KY, V_LOT_NUM, V_IND_BCD, V_LOT_NO, SUBSTR('00000' || V_VBELN, -10), SUBSTR('00000' || TO_CHAR(V_POSNR), -6),
                               'N', V_DATE, V_SESS_USER_ID); 
        
        V_VBELN_POSNR := SUBSTR('00000' || V_VBELN, -10) || SUBSTR('00000' || TO_CHAR(V_POSNR), -6);
        
        --WMS로 자재/완제품 반납요청
        INSERT INTO TB_IFSWM004(DOC_NO, DOC_SEQNO, DLFL, WERKS,
                                MATNR, QTY, UNIT, STOR_LOC_FROM, STOR_LOC_TO, LOTA03, STCK_STA,
                                IND_BCD, LOT_NO, LOTA04, LOTA16, LOTA17, STOK_KY, LOT_NUM,
                                PRDC_DT, RTN_DT, IF_GET_DATE)
                        VALUES(V_DOC_NO, V_DOC_SEQNO, 'C', V_WERKS,
                                V_MATNR, V_STCK_QTY, V_UNIT, V_STOR_LOC_CD, V_STOR_LOC_CD_TO, V_PACK_TYPE, '00', 
                                V_IND_BCD, V_LOT_NO, V_VBELN_POSNR,V_BS_WGT, V_CON_TYPE, V_STCK_KY, V_LOT_NUM,
                                V_PRD_DT, CASE WHEN V_SESS_USER_ID = 'hnw.shyou' THEN '20221103' ELSE TO_CHAR(V_DATE,'YYYYMMDD') END, V_DATE);

        UPDATE TB_INV001
           SET RET_REQ_QTY = V_STCK_QTY,
               STCK_STA = '00'
         WHERE WERKS = V_WERKS
           AND IND_BCD = V_IND_BCD;
           
     ELSIF P_TYPE = 'SAVE1' THEN            --반납취소
        V_WERKS               :=       V_JSON.get_string('WERKS');          --플랜트코드        
        
        V_ARR_LIST                  := V_JSON.get_array('list');
        
        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ				  := TREAT (V_ARR_LIST.get (i) AS json_object_t);  
            V_OBJ				  := TREAT (V_OBJ.get ('map') AS json_object_t);
            
            V_DOC_NO_PRE          := V_OBJ.get_string('DOC_NO');		        --반납요청 문서번호
            V_DOC_SEQNO_PRE       := V_OBJ.get_string('DOC_SEQ');		--반납요청 문서순번
            V_IF_STA              := V_OBJ.get_string('IF_STA');		--반납여부
            
            IF NVL(V_IF_STA, ' ') = 'N' THEN
                IF NVL(V_DOC_NO, ' ') = ' ' THEN
                    V_DOC_NO := V_DOC_NO_PRE;
                ELSE
                    V_DOC_NO := V_DOC_NO || ',' || V_DOC_NO_PRE;
                END IF;
                
                --자재/완제품 반납요청 이력
                UPDATE TB_INV002
                   SET DLFL = 'D',
                       IF_STA = 'Y'
                 WHERE DOC_NO = V_DOC_NO_PRE
                   AND DOC_SEQ = V_DOC_SEQNO_PRE
                   AND DLFL = 'C';  
                   
                --WMS로 자재/완제품 반납요청
                INSERT INTO TB_IFSWM004(DOC_NO, DOC_SEQNO, DLFL, WERKS,
                                        MATNR, QTY, UNIT, STOR_LOC_FROM, LOTA03, STCK_STA,
                                        IND_BCD, LOT_NO, LOTA16, LOTA17, STOK_KY, LOT_NUM,
                                        PRDC_DT, RTN_DT, IF_GET_DATE)
                SELECT DOC_NO, DOC_SEQNO, 'D', WERKS,
                        MATNR, QTY, UNIT, STOR_LOC_FROM, LOTA03, STCK_STA,
                        IND_BCD, LOT_NO, LOTA16, LOTA17, STOK_KY, LOT_NUM,
                        PRDC_DT, TO_CHAR(V_DATE,'YYYYMMDD'), V_DATE
                  FROM TB_IFSWM004
                 WHERE DOC_NO = V_DOC_NO_PRE
                   AND DOC_SEQNO = V_DOC_SEQNO_PRE
                   AND DLFL = 'C';      
            END IF;
        END LOOP;
    END IF;
    
    P_DOC_NO := V_DOC_NO;
    P_SUCCESS := 'Y';

    COMMIT;

    /*EXCEPTION
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
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);*/
END;

/
