
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SCH20_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_SCH20_S01
 * PROGRAM NAME  : 사업항목관리
 * VERSION       : 1.0.0
 * DESCRIPTION   : 사업항목관리 를 관리한다.
 *                 
 * AUTHOR NAME   : 박충식
 * CREATE DATE   : 2022/05/19
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/04/29    1.0.0   박충식         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_SCH011] : (CRUD) 작업지시 화장지초지 정보
 * *      
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_SCH20_S01';     -- PROCEDURE NAME

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
    V_WERKS			TB_MAS030.WERKS%TYPE;		--플랜트
    V_PLN_YR        TB_MAS030.PLN_YR%TYPE;      --계획년도 
    V_MACH_CD	    TB_MAS030.MACH_CD%TYPE;     --설비코드    

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역

    V_MGMT_ITEM_CD	 TB_MAS030.MGMT_ITEM_CD%TYPE;   --관리항목코드
    V_MGMT_ITEM_NM   TB_MAS030.MGMT_ITEM_NM%TYPE;   --관리항목명
    V_UNIT	         TB_MAS030.UNIT%TYPE;           --단위	
    V_MGMT_DEPT_ID	 TB_MAS030.MGMT_DEPT_ID%TYPE;   --관리부서
    V_CP_PLN_YR	 TB_MAS030.MACH_CD%TYPE;            --복사계획년도        
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
   V_PLN_YR             :=       V_JSON.get_string('PLN_YR');       --계획년도
   V_MACH_CD            :=       V_JSON.get_string('MACH_CD');      --설비코드

   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

 	V_SQL :=  ' SELECT  ';
    V_SQL := V_SQL || '''' || V_WERKS || '''   WERKS       --플랜트	     ';
    V_SQL := V_SQL || '
                    , MAS012.MACH_CD          MACH_CD     --설비코드
                    , MAS012.MACH_NM          MACH_NM     --설비명
                    , DECODE(MAS030.PLN_YR,NULL,''미등록'',''등록'')           
                                               REG_YN       --등록여부
                FROM TB_MAS012  MAS012   --설비 마스터
                   , TB_MAS030  MAS030   --설비별 목표 항목정보
                   , TB_MAS013  MAS013   --공정 마스터
               WHERE MAS012.MACH_CD   = MAS030.MACH_CD(+)
                 AND MAS012.PROC_CD   = MAS013.PROC_CD  
                 AND MAS030.USE_YN(+)    =''Y'' 
                '
                 ;

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND MAS013.WERKS(+) = ''' || V_WERKS || '''';				   --플랜트   
        END IF;

        IF  V_PLN_YR IS NOT NULL OR TRIM(V_PLN_YR) != '' THEN
            V_SQL := V_SQL || ' AND MAS030.PLN_YR(+) = ''' || V_PLN_YR || '''';			      --계획년도
        END IF;

       	IF  V_MACH_CD IS NOT NULL OR TRIM(V_MACH_CD) != '' THEN
            V_SQL := V_SQL || ' AND MAS012.MACH_CD(+) = ''' || V_MACH_CD || '''';			   	  --설비코드
        END IF;

        V_SQL := V_SQL || ' GROUP BY MAS012.MACH_CD ';  
        V_SQL := V_SQL || ' , MAS012.MACH_NM ';  
        V_SQL := V_SQL || ' , DECODE(MAS030.PLN_YR,NULL,''미등록'',''등록'')  ';  
        V_SQL := V_SQL || ' ORDER BY MAS012.MACH_CD      ';  

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;
    ELSIF P_TYPE = 'SUB_LIST' THEN /*하단 조회 리스트*/    

 	V_SQL :=  ' 
                SELECT MAS030.MGMT_ITEM_CD	    MGMT_ITEM_CD	  --관리항목코드	
                     , MAS030.MGMT_ITEM_NM	    MGMT_ITEM_NM	  --관리항목명	
                     , MAS030.UNIT	            UNIT	          --단위코드
                     , CMCDV.CDESC1	            UNIT_NM	          --단위명	
                     , MAS030.MGMT_DEPT_ID	    DEPT_CD	          --관리부서
                     , MAS018.DEPT_KR_NM        DEPT_NM           --관리부서명		
                  FROM TB_MAS030  MAS030           --설비별 목표 항목정보
                     , TB_MAS018  MAS018           --부서정보
					 , CMCDV CMCDV		 		   --공통코드(ITEM)
                 WHERE MAS030.MGMT_DEPT_ID =  MAS018.DEPT_CD   (+)
				 AND CMCDV.CMCDVL = MAS030.UNIT(+)  
                 AND CMCDV.CMCDKY = ''UNIT''
                    '
                ;

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND MAS030.WERKS = ''' || V_WERKS || '''';				   --플랜트   
        END IF;

        IF  V_PLN_YR IS NOT NULL OR TRIM(V_PLN_YR) != '' THEN
            V_SQL := V_SQL || ' AND MAS030.PLN_YR = ''' || V_PLN_YR || '''';			      --계획년도
        END IF;

       	IF  V_MACH_CD IS NOT NULL OR TRIM(V_MACH_CD) != '' THEN
            V_SQL := V_SQL || ' AND MAS030.MACH_CD = ''' || V_MACH_CD || '''';			   	  --설비코드
        END IF;

        V_SQL := V_SQL || ' ORDER BY MAS030.MGMT_ITEM_CD      ';  

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;


    ELSIF P_TYPE = 'SAVE' THEN

        V_ARR_LIST        := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ						:= TREAT (V_ARR_LIST.get (i) AS json_object_t);  
            V_OBJ						:= TREAT (V_OBJ.get ('map') AS json_object_t);   

            V_MGMT_ITEM_CD	            := V_OBJ.get_string('MGMT_ITEM_CD'); --관리항목코드
            V_MGMT_ITEM_NM              := V_OBJ.get_string('MGMT_ITEM_NM'); --관리항목명
            V_UNIT	                    := V_OBJ.get_string('UNIT');         --단위	
            V_MGMT_DEPT_ID	            := V_OBJ.get_string('DEPT_CD');      --관리부서

            IF V_OBJ.get_string('GRowState') = 'C'   THEN
                SELECT TO_CHAR(TO_NUMBER(NVL(MAX(MGMT_ITEM_CD), '0')) +1)
                  INTO V_MGMT_ITEM_CD
                  FROM TB_MAS030              --설비별 목표 항목정보
                 WHERE WERKS    = V_WERKS
                   AND PLN_YR   = V_PLN_YR
                   AND MACH_CD  = V_MACH_CD ;

                INSERT INTO TB_MAS030 (               --설비별 목표 항목정보
                         PLN_YR	        --계획년도
                        ,WERKS	        --플랜트
                        ,MACH_CD	    --설비 코드
                        ,MGMT_ITEM_CD	--관리항목코드
                        ,MGMT_ITEM_NM	--관리항목명
                        ,UNIT	        --단위
                        ,COMPKY	        --회사코드
                        ,MGMT_DEPT_ID	--관리부서
                        ,USE_YN	        --사용여부
                        ,REGDATE	    --등록일시
                        ,REGID	        --등록자ID
                        ,UPDDATE	    --수정일시
                        ,UPDID	        --수정자ID                     
                ) VALUES (
                         V_PLN_YR	    --계획년도
                        ,V_WERKS	    --플랜트
                        ,V_MACH_CD	    --설비 코드
                        ,V_MGMT_ITEM_CD	--관리항목코드
                        ,V_MGMT_ITEM_NM	--관리항목명
                        ,V_UNIT	        --단위
                        ,NULL	        --회사코드
                        ,V_MGMT_DEPT_ID	--관리부서
                        ,'Y'	        --사용여부
                        ,SYSDATE	    --등록일시
                        ,V_SESS_USER_ID	--등록자ID
                        ,NULL	        --수정일시
                        ,NULL	        --수정자ID                                     
                ) ; 

            ELSIF V_OBJ.get_string('GRowState') = 'U'  THEN
                    UPDATE TB_MAS030              --설비별 목표 항목정보 
                    SET   MGMT_ITEM_NM	    = V_MGMT_ITEM_NM   --관리항목명
                         ,UNIT	            = V_UNIT           --단위
                         ,MGMT_DEPT_ID		= V_MGMT_DEPT_ID   --부서코드
                         ,USE_YN	        = 'Y'              --사용여부
                         ,UPDDATE	        = SYSDATE          --수정일시
                         ,UPDID	            = V_SESS_USER_ID   --수정자ID

                    WHERE WERKS         = V_WERKS            --플랜트
                      AND PLN_YR        = V_PLN_YR           --계획년도
                      AND MACH_CD       = V_MACH_CD          --설비 코드 
                      AND MGMT_ITEM_CD	= V_MGMT_ITEM_CD     --관리항목코드
                      ;

            ELSIF V_OBJ.get_string('GRowState') = 'D'  THEN

               DELETE FROM TB_MAS030                --설비별 목표 항목정보
               WHERE WERKS         = V_WERKS            --플랜트
                 AND PLN_YR        = V_PLN_YR           --계획년도
                 AND MACH_CD       = V_MACH_CD          --설비 코드
                 AND MGMT_ITEM_CD  = V_MGMT_ITEM_CD     --관리항목코드
                ;

            END IF;

        END LOOP;
    ELSIF P_TYPE = 'COPY' THEN

        V_CP_PLN_YR            :=       V_JSON.get_string('PLN_YR');      --복사계획년도

        INSERT INTO TB_MAS030 (              --설비별 목표 항목정보
             PLN_YR	        --계획년도
            ,WERKS	        --플랜트
            ,MACH_CD	    --설비 코드
            ,MGMT_ITEM_CD	--관리항목코드
            ,MGMT_ITEM_NM	--관리항목명
            ,UNIT	        --단위
            ,COMPKY	        --회사코드
            ,MGMT_DEPT_ID	--관리부서
            ,USE_YN	        --사용여부
            ,REGDATE	    --등록일시
            ,REGID	        --등록자ID
            ,UPDDATE	    --수정일시
            ,UPDID	        --수정자ID        
        )
        SELECT 
             V_CP_PLN_YR	--계획년도
            ,WERKS	        --플랜트
            ,MACH_CD        --설비 코드
            ,MGMT_ITEM_CD	--관리항목코드
            ,MGMT_ITEM_NM	--관리항목명
            ,UNIT	        --단위
            ,COMPKY	        --회사코드
            ,MGMT_DEPT_ID	--관리부서
            ,USE_YN	        --사용여부
            ,SYSDATE	    --등록일시
            ,V_SESS_USER_ID --등록자ID
            ,NULL	        --수정일시
            ,NULL	        --수정자ID        
        FROM TB_MAS030              --설비별 목표 항목정보
       WHERE PLN_YR        = V_PLN_YR   --계획년도
       ;

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
