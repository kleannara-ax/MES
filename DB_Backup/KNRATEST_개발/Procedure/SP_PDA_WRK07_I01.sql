--------------------------------------------------------
--  DDL for Procedure SP_PDA_WRK07_I01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_PDA_WRK07_I01" 
(
    P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
AS 
/*==============================================================================
 * PROGRAM ID    : SP_PDA_WRK07_I01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : PDA 공정재고실사 등록{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : PDA 공정재고실사 등록{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박충식 {최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/17 {최초 작성일자 기술}
 * SYSTEM NAME   : PDA
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/17    1.0.0   박충식         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_INV008] : (.R..) 재고실사 작업지시정보                                
 *       - [TB_MAS003] : (.R..) 저장위치 마스터                            
   *=============================================================================*/
    --프로그램 ID
    V_PRG_NM          VARCHAR2(100)  := 'SP_PDA_WRK07_I01';     -- PROCEDURE NAME

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

    V_WRK_ORDR_NO	    TB_INV009.WRK_ORDR_NO%TYPE;    --작업지시번호
    V_MATNR	            TB_INV009.MATNR%TYPE;          --품목코드	
    V_STCK_QTY	        TB_INV009.STCK_QTY%TYPE;       --재고수량	
    V_REAL_INSP_QTY	    TB_INV009.REAL_INSP_QTY%TYPE;  --실사수량	

BEGIN
    OPEN P_RS_LIST FOR 
    SELECT NULL FROM DUAL WHERE ROWNUM = 0;    

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);
    V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=       V_JSON.get_string('SES_WAREKY');

    /* 조건값 할당 */
    V_RANGE_SQL          :=       V_JSON.get_string('RANGE_SQL');                   -- 

    V_WERKS              :=       V_JSON.get_string('WERKS');                       -- 플랜트코드
    V_IND_BCD            :=       V_JSON.get_string('IND_BCD');                     -- 개별바코드  
    V_STOR_LOC_CD        :=       V_JSON.get_string('STOR_LOC_CD');                 -- 저장위치  


    IF P_TYPE = 'LIST' THEN 

        V_SQL := ' SELECT INV001.IND_BCD	          IND_BCD           --개별바코드
                        , INV001.STOR_LOC_CD          STOR_LOC_CD       --저장위치   
                        , INV001.LOT_NO	              LOT_NO	        --LOT NO
                        , INV001.MATNR	              MATNR	            --제품코드    
                        , MAS001.MATNR_NM	          MATNR_NM	        --품명
                        , INV001.PRD_DT		          PRD_DT	        --생산일자
                        , MAS001.MATNR_SPEC		      MATNR_SPEC        --규격
                        , INV001.UNIT			      UNIT		        --단위
                        , INV001.STCK_QTY			  STCK_QTY		    --재고수량
                    FROM TB_INV001 INV001, TB_MAS001  MAS001    
                   WHERE 1=1
                     AND INV001.MATNR = MAS001.MATNR
                     AND INV001.WERKS = MAS001.WERKS	
           ' ;

        V_SQL := V_SQL || ' AND INV001.WERKS = ''' || V_WERKS || '''';                --플랜트코드          
        V_SQL := V_SQL || ' AND INV001.IND_BCD = ''' || V_IND_BCD || '''';            --개별바코드 
        V_SQL := V_SQL || ' AND INV001.STOR_LOC_CD = ''' || V_STOR_LOC_CD || '''';    --저장위치 

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
    ELSIF P_TYPE = 'SAVE' THEN

        V_WERKS               :=       V_JSON.get_string('WERKS');          --플랜트코드        
        V_WRK_ORDR_NO	      :=       V_JSON.get_string('WRK_ORDR_NO');    --작업지시번호
        V_STOR_LOC_CD         :=       V_JSON.get_string('STOR_LOC_CD');    --저장위치
        V_IND_BCD             :=       V_JSON.get_string('IND_BCD');        --개별바코드 
        V_MATNR	              :=       V_JSON.get_string('MATNR');          --품목코드	
        V_STCK_QTY	          :=       V_JSON.get_string('STCK_QTY');       --재고수량	
        V_REAL_INSP_QTY	      :=       V_JSON.get_string('REAL_INSP_QTY');  --실사수량	

        DELETE FROM TB_INV009    -- 공정재고실사정보
        WHERE WERKS       = V_WERKS
          AND WRK_ORDR_NO = V_WRK_ORDR_NO
          AND STOR_LOC_CD = V_STOR_LOC_CD
          AND IND_BCD     = V_IND_BCD
          AND MATNR       = V_MATNR ;

        INSERT INTO   TB_INV009  (  -- 공정재고실사정보 
                 WERKS	                    --플랜트코드
                ,WRK_ORDR_NO	            --작업지시번호
                ,STOR_LOC_CD                --저장위치
                ,IND_BCD                    --개별바코드
                ,MATNR	                    --품목코드
                ,STCK_QTY	                --재고수량
                ,REAL_INSP_QTY	            --실사수량
                ,DIFF_QTY	                --차이수량
                ,REGDATE	                --등록일시
                ,REGID	                    --등록자ID
                ,UPDDATE	                --수정일시
                ,UPDID	                    --수정자ID
        ) VALUES (
                 V_WERKS	                --플랜트코드
                ,V_WRK_ORDR_NO	            --작업지시번호
                ,V_STOR_LOC_CD              --저장위치
                ,V_IND_BCD                  --개별바코드
                ,V_MATNR	                --품목코드
                ,V_STCK_QTY	                --재고수량
                ,V_REAL_INSP_QTY	        --실사수량
                ,ABS(NVL(V_STCK_QTY,0)-NVL(V_REAL_INSP_QTY,0))	--차이수량
                ,SYSDATE	                --등록일시
                ,V_SESS_USER_ID	            --등록자ID
                ,NULL	                    --수정일시
                ,NULL	                    --수정자ID                
        );

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
