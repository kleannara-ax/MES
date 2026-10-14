--------------------------------------------------------
--  DDL for Procedure SP_INV02_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_INV02_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
    P_MSG           OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_INV02_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 조약실(약품투입) {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 약품 자재투입 를 관리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박충식{최초 작성자 명 기술}
 * CREATE DATE   : 2022/04/27 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/04/27    1.0.0   박충식         Initial Version 
 * 2022/06/30    1.0.0   박충식         
 *==============================================================================
 *  관련 테이블
 *        - [TB_SCH013] : (CRUD) 작업지시 패드 정보
 * *      
 *=============================================================================*/

AS
    V_PRG_NM          VARCHAR2(100)  := 'SP_INV02_S01';     -- PROCEDURE NAME

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

   -- 2022-05-10(화요일)-안상현, 하위 쿼리 조건 추가
    V_OUT_SQL      	 varchar2(4000);

    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS			TB_INV005.WERKS%TYPE;		--플랜트
    V_MACHINE       TB_SCH008.MACHINE%TYPE;     --설비코드 

	V_MACH_CD       TB_INV005.MACH_CD%TYPE;     --설비코드
	V_MATNR_GRP_CD  TB_MAS001.MATNR_GRP_CD%TYPE;     --자재그룹코드
	V_MATNR_GRP_NM  TB_MAS001.MATNR_GRP_NM%TYPE;     --자재그룹
    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역

   V_MATNR	            TB_INV005.MATNR%TYPE;               --자재코드
   V_INP_DT             TB_INV005.INP_DT%TYPE;              --투입일자   
   V_WRK_SHIFT          TB_INV005.WRK_SHIFT%TYPE;           --작업조 코드   
   V_IND_BCD	        TB_INV005.IND_BCD%TYPE;             --공급업체바코드 
   V_UNIT	            TB_INV005.UNIT%TYPE;                --단위 
   V_INP_QTY            TB_INV005.INP_QTY%TYPE;             --투입량             
   V_STCK_QTY           TB_INV005.INP_QTY%TYPE;             --재고수량  

   V_STOR_LOC_CD        TB_INV001.STOR_LOC_CD%TYPE;         --저장위치
   V_LOT_NO             TB_INV001.LOT_NO%TYPE;              --LOT_NO
   V_MACH_CD_BF         TB_INV005.MACH_CD%TYPE;             --구설비코드   
   V_MATNR_BF	        TB_INV005.MATNR%TYPE;               --구자재코드
   V_IND_BCD_BF	        TB_INV005.IND_BCD%TYPE;             --구공급업체바코드    
   V_INP_QTY_BF         TB_INV005.INP_QTY%TYPE;             --구투입량                
   V_INP_DT_BF          TB_INV005.INP_DT%TYPE;              --구투입일자                        
   V_PDOC_NO            TB_INV005.PDOC_NO%TYPE;
   V_DUMMY              varchar2(1);  
   V_DATE               DATE := SYSDATE;
BEGIN
   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'Y';
   V_RUN_SQL := 'Y';

   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
   --V_PLT_CD             :=       V_JSON.get_string('SES_PLNTKY');

   /* 조건값 할당 */
   V_WERKS          	:=       V_JSON.get_string('WERKS');	    --플랜트
   V_MACH_CD 		    :=       V_JSON.get_string('MACH_CD');   	--설비코드
   V_INP_DT 		    :=       V_JSON.get_string('INP_DT');   	--투입일자
   V_WRK_SHIFT 		    :=       V_JSON.get_string('WRK_SHIFT');   	--작업조 코드
   V_MATNR_GRP_CD 		:=       V_JSON.get_string('MATNR_GRP_CD'); --자재그룹코드
   V_MATNR_GRP_NM 		:=       V_JSON.get_string('MATNR_GRP_CD'); --자재그룹

   -- 2022-05-10(화요일)-안상현, 하위 쿼리 조건 추가
    --20221017 여한진 약품은 바코드 사용하지 않고 자재로만 관리
   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/
    V_SQL := ' SELECT
                   MAS001.WERKS       	    WERKS     		--플랜트
                 , MAS001.MATNR_GRP_CD      MATNR_GRP_CD    --자재그룹코드(보이지 않음)
                 , MAS001.MATNR_GRP_NM      MATNR_GRP_NM    --자재그룹명(보이지 않음)
                 , MAS001.MATNR             MATNR           --자재코드	 
                 , MAS001.MATNR_NM          MATNR_NM        --자재명
                 , MAS001.LGPRO	            STOR_LOC_CD     --저장위치(보이지 않음)
                 , MAS003.STOR_LOC_NM	    STOR_LOC_NM     --저장위치명(보이지 않음)
                 --, INV001.LOT_NO	        LOT_NO          --LOT NO 
                 --, INV001.IND_BCD	        IND_BCD         --개별바코드
                 , INV001.STCK_QTY	        STCK_QTY        --현재재고
                 , 0                        INP_QTY         --투입량 
                 , MAS001.UNIT              UNIT            --단위
              FROM  TB_MAS001 MAS001  --플랜트별 제품/자재 마스터
                  , TB_INV001 INV001  --창고별 재고현황
                  , TB_MAS003 MAS003    --저장위치 마스터(공정창고내 저장위치 포함)
             WHERE 1=1 
               AND MAS001.MATNR         = INV001.MATNR(+)
               AND MAS001.WERKS         = INV001.WERKS(+)
               AND MAS001.WERKS         = MAS003.WERKS(+)
               AND MAS001.LGPRO    = MAS003.STOR_LOC_CD(+)
               AND MAS001.MATNR_STA IS NULL';


        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND MAS001.WERKS = ''' || V_WERKS || '''';				   --플랜트   
        END IF;

        IF  V_MATNR_GRP_CD IS NOT NULL OR TRIM(V_MATNR_GRP_CD) != '' THEN
            V_SQL := V_SQL || ' AND MAS001.MATNR_GRP_CD = ''' || V_MATNR_GRP_CD || '''';			   --자재그룹코드
        END IF;

        V_SQL := V_SQL || '  ORDER BY  INV001.WERKS , MAS001.MATNR';  

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SUB_LIST' THEN  /* 하부 상세 조회 리스트*/
 	V_SQL :=  ' SELECT 
                        INV001.WERKS	    WERKS        --플랜트코드
                     ,  INV001.STOR_LOC_CD	STOR_LOC_CD  --저장위치
                     ,  MAS003.STOR_LOC_NM	STOR_LOC_NM  --저장위치명
                     ,  INV001.IND_BCD	    IND_BCD      --개별바코드
                     ,  INV001.MATNR	    MATNR        --자재코드
                     ,  MAS001.MATNR_NM	    MATNR_NM     --자재명
                     ,  MAS001.MATNR_GRP_CD MATNR_GRP_CD --자재그룹코드
                     ,  MAS001.MATNR_GRP_NM MATNR_GRP_NM --자재그룹명
                     ,  STCK_QTY	        STCK_QTY     --현재고 수량
                     , INV001.REGDATE       REGDATE      --등록일시    
                     , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = INV001.REGID),INV001.REGID)	        AS REGNM	        --등록자명   
                     , INV001.UPDDATE       UPDDATE      --수정일시      
                     , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = INV001.UPDID),INV001.UPDID)	        AS UPDNM	        --수정자명          
                  FROM TB_INV001  INV001    --창고별 재고현황
                     , TB_MAS001  MAS001    --플랜트별 제품/자재 마스터
                     , TB_MAS003  MAS003    --저장위치 마스터(공정창고내 저장위치 포함)
                  WHERE 1=1
                    AND INV001.WERKS        = MAS001.WERKS(+)
                    AND INV001.MATNR        = MAS001.MATNR(+) 
                    AND INV001.WERKS        = MAS003.WERKS(+)
                    AND INV001.STOR_LOC_CD  = MAS003.STOR_LOC_CD(+)
                    AND MAS001.MATNR_GRP_CD LIKE ''21%'' ';

                IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
                    V_SQL := V_SQL || ' AND INV001.WERKS = ''' || V_WERKS || '''';				   --플랜트   
                END IF;

                IF  V_MATNR_GRP_NM IS NOT NULL OR TRIM(V_MATNR_GRP_NM) != '' THEN
                    V_SQL := V_SQL || ' AND MAS001.MATNR_GRP_CD = ''' || V_MATNR_GRP_NM || '''';   --자재그룹코드
                END IF;


        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SAVE' THEN
        V_ARR_LIST        := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ						:= TREAT (V_ARR_LIST.get (i) AS json_object_t);  
            V_OBJ						:= TREAT (V_OBJ.get ('map') AS json_object_t);   

            V_MATNR	         := V_OBJ.get_string('MATNR');                --자재코드
	        V_INP_QTY        := V_OBJ.get_string('INP_QTY');              --투입량             
            V_STOR_LOC_CD    := V_OBJ.get_string('STOR_LOC_CD');          --저장위치
            --20221017 여한진 약품은 바코드 사용하지 않고 자재로만 관리
            --V_IND_BCD        := V_OBJ.get_string('IND_BCD');              --개별바코드                     
            --V_LOT_NO         := V_OBJ.get_string('LOT_NO');               --LOT NO  
            V_UNIT           := V_OBJ.get_string('UNIT');                 --UNIT

            IF V_OBJ.get_string('GRowState')    = 'C'  OR V_OBJ.get_string('GRowState') = 'U' THEN
                -- 투입일자를  확인하세요.'
                IF V_INP_DT IS NULL THEN   
                         P_SUCCESS   := 'N';
                         P_MSG       := '투입일자를  확인하세요.'||V_INP_DT||'aaa';
                         ROLLBACK;
                         RETURN;
                END IF;  

                IF NVL(V_INP_QTY,0 ) <= 0 THEN   
                         P_SUCCESS   := 'N';
                         P_MSG       := '투입량을 확인 하세요.';
                         ROLLBACK;
                         RETURN;
                END IF;  

                -- 자재코드 NULL  '자재코드를 확인 하세요'
                IF V_MATNR IS NULL THEN   
                         P_SUCCESS   := 'N';
                         P_MSG       := '자재코드를 확인 하세요.';
                         ROLLBACK;
                         RETURN;
                END IF;              

                -- 설비코드 NULL  '설비코드를 확인 하세요'
                IF V_MACH_CD IS NULL THEN   
                         P_SUCCESS   := 'N';
                         P_MSG       := '설비코드를 확인 하세요.';
                         ROLLBACK;
                         RETURN;
                END IF;              

                -- 공급업체바코드  '공급업체바코드를 확인 하세요' 
--                IF V_IND_BCD IS NULL OR V_IND_BCD = ' ' THEN   
--                         P_SUCCESS   := 'N';
--                         P_MSG       := '공급업체바코드를 확인 하세요.';
--                         ROLLBACK;
--                         RETURN;
--                END IF;              

                -- 창고별 재고   확인 하세요.
                V_STCK_QTY := 0 ;
                SELECT  NVL(SUM(NVL(STCK_QTY,0)), 0)
                  INTO  V_STCK_QTY
                  FROM  TB_INV001
                 WHERE WERKS	= V_WERKS
                   AND IND_BCD	= V_IND_BCD
                   AND MATNR	= V_MATNR
                ;
--                --임시주석
--               IF V_STCK_QTY < V_INP_QTY THEN   
--                         P_SUCCESS   := 'N';
--                         P_MSG       := '창고 재고를 확인 하세요.';
--                         ROLLBACK;
--                         RETURN;
--                END IF; 
                V_DATE := V_DATE + 1/86400;
                V_PDOC_NO := 'P' || TO_CHAR(V_DATE, 'YYYYMMDDHH24MISS');

                BEGIN    -- 신규데이터
                        INSERT INTO TB_INV005 (   --약품 투입이력
                                 WERKS	    --플랜트코드
                               , MACH_CD    --설비코드
                               , PDOC_NO
                               , INP_DT	    --투입일자
                               , INP_ID		--작업자ID
                               , WRK_SHIFT	--작업조 코드
                               , MATNR	    --자재코드
                               , IND_BCD	--공급업체바코드
                               , LOT_NO     --LOT_NO
                               , UNIT	    --단위
                               , INP_QTY	--투입량
                               , REGDATE	--등록일자
                               , REGID	    --등록자ID
                               , UPDDATE    --수정일자
                               , UPDID	    --수정자ID
                        ) VALUES (
                                 V_WERKS      	    --플랜트코드
                               , V_MACH_CD          --설비코드
                               , V_PDOC_NO
                               , V_INP_DT	        --투입일자(YYYY-MM-DD)
                               , V_SESS_USER_ID		--작업자ID
                               , V_WRK_SHIFT		--작업조 코드
                               , V_MATNR	        --자재코드
                               , ' '    	        --공급업체바코드
                               , NVL(TRIM(V_LOT_NO), '*')           --LOT_NO    
                               , V_UNIT	            --단위
                               , V_INP_QTY	        --투입량
                               , SYSDATE		    --등록일시
                               , V_SESS_USER_ID	    --등록자ID
                               , NULL		        --수정일시
                               , NULL	            --수정자ID
                        ) ;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            V_DUMMY := '1';
                        WHEN DUP_VAL_ON_INDEX THEN    
                        	UPDATE 
                           		TB_INV005 
                          	SET  --약품 투입이력
                            	UNIT	    = V_UNIT      				--단위
                            , 	INP_QTY    	= INP_QTY + V_INP_QTY      	--투입량
                            , 	UPDDATE		= SYSDATE        			--수정일자
                            , 	UPDID	    = V_SESS_USER_ID 			--수정자ID
                           	WHERE 1=1
                           	AND WERKS	  	= V_WERKS      		--플랜트코드
                            AND MACH_CD 	= V_MACH_CD    		--설비코드
                            AND PDOC_NO	  	= V_PDOC_NO     		--투입일자(YYYY-MM-DD)
--                            AND INP_ID		= V_SESS_USER_ID	--작업자ID
--                            AND WRK_SHIFT	= V_WRK_SHIFT		--작업조 코드
--                            AND MATNR	  	= V_MATNR      		--자재코드
--                            AND IND_BCD		= V_IND_BCD    			--공급업체바코드
--                            AND LOT_NO     	= V_LOT_NO     		--LOT_NO   
                             ;

                        WHEN OTHERS THEN
                            V_DUMMY := '1';
                END;

                UPDATE TB_INV001 SET
                       STCK_QTY = STCK_QTY - V_INP_QTY 
                WHERE WERKS	            = V_WERKS           --플랜트코드
                  AND STOR_LOC_CD	    = V_STOR_LOC_CD     --저장위치
                  --AND NVL(TRIM(IND_BCD),'*')     = NVL(TRIM(V_IND_BCD), '*')   --개별바코드
                  AND MATNR	            = V_MATNR           --제품코드       
                ;

            END IF;
        END LOOP;

    END IF;

    P_SUCCESS := 'Y';
    COMMIT ;
--    EXCEPTION
--    WHEN E_EXCEPTION_USER THEN
--
--        -- 에러 내역 SET
--	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := SQLCODE;
--        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);
--
--        ROLLBACK;
--        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--
--    WHEN OTHERS THEN
--	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := SQLCODE;
--        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--        ROLLBACK;
--        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
--        RAISE ;
END;

/
