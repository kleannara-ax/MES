
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK07_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK07_S01
 * PROGRAM NAME  : 재고실사 확정
 * VERSION       : 1.0.0
 * DESCRIPTION   : 재고실사 확정 를 관리한다.
 *                 
 * AUTHOR NAME   : 박충식
 * CREATE DATE   : 2022/05/23
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/23    1.0.0   박충식         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_INV008] : (CRUD) 재고실사 작업지시정보
 * *      
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK07_S01';     -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

   -- V_RTN_CLOB       CLOB;
   -- V_RTN_CURSOR     SYS_REFCURSOR;
   -- V_ERROR          CLOB;

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_ARRAY_T;
    V_OBJ            JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS			   TB_SCH008.WERKS%TYPE;		   --플랜트
    V_SDATE            TB_INV008.WRK_REQ_DT%TYPE;      --지시요청시작일자	      
    V_EDATE            TB_INV008.WRK_REQ_DT%TYPE;	   --지시요청종료일자

    --V_MACHINE       TB_SCH008.MACHINE%TYPE;     --생산호기

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역


	 V_WRK_ORDR_NO	    TB_INV008.WRK_ORDR_NO%TYPE;		--작업지시번호
	 V_ORDR_GEN_DT	    TB_INV008.ORDR_GEN_DT%TYPE;		--지시생성일자
	 V_REAL_INSP_DIV	TB_INV008.REAL_INSP_DIV%TYPE;	--실사구분        보정:1  정상:0 
	 V_REAL_INSP_RMK    TB_INV008.REAL_INSP_RMK%TYPE;	--실사사유
	 V_START_DT         TB_INV008.START_DT%TYPE;		--시작일자  
	 V_END_DT		    TB_INV008.END_DT%TYPE;			--완료일자  
	 V_WRK_ORDR_RMK	    TB_INV008.WRK_ORDR_RMK%TYPE;	--작업지시비고
     V_APVR_STA         TB_INV008.APVR_STA%TYPE;	    --결재상태  

     V_STOR_LOC_CD      TB_INV009.STOR_LOC_CD%TYPE;	    --저장위치
     V_MATNR            TB_INV009.MATNR%TYPE;	        --품목코드
     V_IND_BCD          TB_INV009.IND_BCD%TYPE;	        --개별바코드

BEGIN
   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'N';
   V_RUN_SQL := 'Y';

   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=       V_JSON.get_string('SES_PLNTKY');

   /* 조건값 할당 */
   V_WERKS          	:=       V_JSON.get_string('WERKS');	    --플랜트
   V_SDATE              :=       V_JSON.get_string('SDATE');        --지시요청시작일자	      
   V_EDATE              :=       V_JSON.get_string('EDATE');	    --지시요청종료일자
   V_WRK_ORDR_NO	    :=       V_JSON.get_string('WRK_ORDR_NO');	--작업지시번호

   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

 	V_SQL :=  ' SELECT   
                         INV008.WERKS 		        WERKS			    --플랜트코드
                        ,INV008.WRK_ORDR_NO	        WRK_ORDR_NO		    --작업지시번호
                        ,INV008.WRK_REQ_DT	        WRK_REQ_DT	        --지시요청일자  
                        ,DECODE(INV008.REAL_INSP_DIV, ''0'',''정상'',''보정'')	
                                                    REAL_INSP_DIV_NM	--실사구분명  
                        ,INV008.REAL_INSP_RMK    	REAL_INSP_RMK		--실사사유
                        ,INV008.START_DT            START_DT		    --시작일자  
                        ,INV008.END_DT		        END_DT			    --완료일자
                        ,INV008.STOR_LOC_CD		    STOR_LOC_CD         --저장위치
                        ,MAS003.STOR_LOC_NM         STOR_LOC_NM         --저장위치명                         
                        ,INV008.APVR_STA            APVR_STA            --결재상태 
                        ,FN_CMCDV (''APVR_STA'', INV008.APVR_STA) 
                                                    APVR_STA_NM         --결재상태명 
                        ,NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = INV008.APPRID),'''')              
                                                    APPRNM              --승인자명
                        ,INV008.APPR_DT             APPR_DT             --승인일자 
                        ,INV008.WRK_ORDR_RMK	    WRK_ORDR_RMK		--작업지시비고
                    FROM TB_INV008  INV008
                       , TB_MAS003  MAS003         --저장위치 마스터(공정창고내 저장위치 포함) 
                   WHERE INV008.WERKS       = MAS003.WERKS(+)
                     AND INV008.STOR_LOC_CD = MAS003.STOR_LOC_CD(+)
                    '
                 ;

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND INV008.WERKS = ''' || V_WERKS || '''';				   --플랜트   
        END IF;

        V_SQL := V_SQL || ' AND INV008.WRK_REQ_DT BETWEEN ''' || V_SDATE || ''' AND ''' || V_EDATE || '''';

        V_SQL := V_SQL || ' ORDER BY INV008.WERKS  , INV008.WRK_ORDR_NO ';  

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;
   ELSIF P_TYPE = 'SUB_LIST' THEN /*하단 조회 리스트*/

   V_WERKS          	:=       V_JSON.get_string('WERKS');	    --플랜트
   V_WRK_ORDR_NO	    :=       V_JSON.get_string('WRK_ORDR_NO');	--작업지시번호


 	V_SQL :=  ' SELECT INV009.STOR_LOC_CD		STOR_LOC_CD     --저장위치
                     , MAS003.STOR_LOC_NM       STOR_LOC_NM     --저장위치명 
                     , INV009.MATNR	            MATNR           --품목코드
                     , MAS001.MATNR_NM	        MATNR_NM        --품명
                     , INV009.IND_BCD	        IND_BCD         --개별바코드
                     , INV001.UNIT              UNIT            --단위
                     , FN_CMCDV (''UNIT'', INV001.UNIT) 
                                                UNIT_NM         --단위명
                     , INV009.STCK_QTY	        STCK_QTY        --재고수량
                     , INV009.REAL_INSP_QTY	    REAL_INSP_QTY   --실사수량
                     , INV009.DIFF_QTY	        DIFF_QTY        --차이수량
                     , INV009.REGDATE           REGDATE			--등록일시     
                     , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = INV009.REGID),INV009.REGID)	             
                                                REGNM			--등록자
                     , INV009.UPDDATE           UPDDATE			--수정일시
                     , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = INV009.UPDID),INV009.UPDID)				 
                                                UPDNM			--수정자
                  FROM TB_INV009  INV009         --공정재고실사정보
                     , TB_MAS003  MAS003         --저장위치 마스터(공정창고내 저장위치 포함) 
                     , TB_MAS001  MAS001         --플랜트별 제품/자재 마스터   
                     , TB_INV001  INV001         --창고별 재고현황
                 WHERE INV009.WERKS       = MAS003.WERKS(+)
                   AND INV009.STOR_LOC_CD = MAS003.STOR_LOC_CD(+)
                   AND INV009.WERKS       = MAS001.WERKS(+)
                   AND INV009.MATNR       = MAS001.MATNR(+)
                   AND INV009.WERKS       = INV001.WERKS(+)
                   AND INV009.STOR_LOC_CD = INV001.STOR_LOC_CD(+)
                   AND INV009.IND_BCD     = INV001.IND_BCD(+)
                   AND INV009.MATNR       = INV001.MATNR(+)
                    '
                 ;

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND INV009.WERKS = ''' || V_WERKS || '''';				   --플랜트   
        END IF;

        IF  V_WRK_ORDR_NO IS NOT NULL OR TRIM(V_WRK_ORDR_NO) != '' THEN
            V_SQL := V_SQL || ' AND INV009.WRK_ORDR_NO = ''' || V_WRK_ORDR_NO || '''';				   --작업지시번호   
        END IF;

        V_SQL := V_SQL || ' ORDER BY INV009.STOR_LOC_CD  , INV009.MATNR ';  

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;      

    ELSIF P_TYPE = 'SAVE' THEN  --저장 

      V_WERKS          	:=       V_JSON.get_string('WERKS');	    --플랜트
      V_WRK_ORDR_NO	    :=       V_JSON.get_string('WRK_ORDR_NO');	--작업지시번호

       SELECT APVR_STA	  --결재상태
         INTO V_APVR_STA
       FROM TB_INV008  
       WHERE WERKS       =  V_WERKS
         AND WRK_ORDR_NO =  V_WRK_ORDR_NO ;

       IF  V_APVR_STA IS NULL  OR  V_APVR_STA = '0'  THEN
          UPDATE TB_INV008    --재고실사 작업지시정보
             SET APVR_STA   = '1'                --0:미승인  1:결재요청  3:반려       2:승인  4:확정
               , UPDDATE	 = SYSDATE           --수정일시
               , UPDID	     = V_SESS_USER_ID    --수정자ID             
           WHERE WERKS       = V_WERKS
             AND WRK_ORDR_NO = V_WRK_ORDR_NO ;

       END IF;
    ELSIF P_TYPE = 'SAVE1' THEN  --결재 

       SELECT APVR_STA	  --결재상태
         INTO V_APVR_STA
       FROM TB_INV008  
       WHERE WERKS        =  V_WERKS
          AND WRK_ORDR_NO =  V_WRK_ORDR_NO ;

       IF  V_APVR_STA = '1'  OR V_APVR_STA = '3' THEN
          UPDATE TB_INV008    --재고실사 작업지시정보
             SET APVR_STA   = '2'                --0:미승인  1:결재요청  3:반려       2:승인  4:확정
               , APPR_DT	 = TO_CHAR(SYSDATE,'YYYYMMDD')  --승인일자
               , APPRID	     = V_SESS_USER_ID               --승인자             
           WHERE WERKS       = V_WERKS
             AND WRK_ORDR_NO = V_WRK_ORDR_NO ;

       END IF;

    ELSIF P_TYPE = 'SAVE2' THEN  --반려 

       SELECT APVR_STA	  --결재상태
         INTO V_APVR_STA
       FROM TB_INV008  
       WHERE WERKS        =  V_WERKS
          AND WRK_ORDR_NO =  V_WRK_ORDR_NO ;

       IF  V_APVR_STA = '2'  THEN
          UPDATE TB_INV008    --재고실사 작업지시정보
             SET APVR_STA   = '3'                --0:미승인  1:결재요청  3:반려       2:승인  4:확정
               , APPR_DT	 = NULL  --승인일자
               , APPRID	     = NULL               --승인자             
               , UPDDATE	 = SYSDATE           --수정일시
               , UPDID	     = V_SESS_USER_ID    --수정자ID             
           WHERE WERKS       = V_WERKS
             AND WRK_ORDR_NO = V_WRK_ORDR_NO ;

       END IF;

    ELSIF P_TYPE = 'SAVE3' THEN  --확정 

       SELECT APVR_STA	  --결재상태
         INTO V_APVR_STA
       FROM TB_INV008  
       WHERE WERKS        =  V_WERKS
          AND WRK_ORDR_NO =  V_WRK_ORDR_NO ;

       IF  V_APVR_STA = '2'  THEN
          UPDATE TB_INV008    --재고실사 작업지시정보
             SET APVR_STA   = '4'                --0:미승인  1:결재요청  3:반려       2:승인    4:확정
               , UPDDATE	 = SYSDATE           --수정일시
               , UPDID	     = V_SESS_USER_ID    --수정자ID             
           WHERE WERKS       = V_WERKS
             AND WRK_ORDR_NO = V_WRK_ORDR_NO ;
       END IF;
    ELSIF P_TYPE = 'SAVE4' THEN  --취소 

       SELECT APVR_STA	  --결재상태
         INTO V_APVR_STA
       FROM TB_INV008  
       WHERE WERKS        =  V_WERKS
          AND WRK_ORDR_NO =  V_WRK_ORDR_NO ;

       IF  V_APVR_STA = '4'  THEN
          UPDATE TB_INV008    --재고실사 작업지시정보
             SET APVR_STA   = '2'                --0:미승인  1:결재요청  3:반려       2:승인    4:확정
               , UPDDATE	 = SYSDATE           --수정일시
               , UPDID	     = V_SESS_USER_ID    --수정자ID             
           WHERE WERKS       = V_WERKS
             AND WRK_ORDR_NO = V_WRK_ORDR_NO ;

       END IF;
    END IF;

    P_SUCCESS := 'Y';

    EXCEPTION
    WHEN E_EXCEPTION_USER THEN

        -- 에러 내역 SET
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

    WHEN OTHERS THEN
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
