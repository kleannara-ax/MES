
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SCH21_S01" (
	P_TYPE           IN    varchar2, -- TOP ,LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_SCH21_S01
 * PROGRAM NAME  : 사업목표관리
 * VERSION       : 1.0.0
 * DESCRIPTION   : 사업목표관리 를 관리한다.
 *                 
 * AUTHOR NAME   : 박충식
 * CREATE DATE   : 2022/05/20
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/20    1.0.0   박충식         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_SCH011] : (CRUD) 설비별 목표 설정정보
 * *      
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_SCH21_S01';     -- PROCEDURE NAME

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
    V_WERKS			TB_MAS031.WERKS%TYPE;		--플랜트
    V_PLN_YR        TB_MAS031.PLN_YR%TYPE;      --계획년도 
    V_MACH_CD	    TB_MAS031.MACH_CD%TYPE;     --설비코드    

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역

    V_MGMT_ITEM_CD	 TB_MAS031.MGMT_ITEM_CD%TYPE;   --관리항목코드
    V_PLN_MM	     TB_MAS031.PLN_MM%TYPE;          --계획월
    V_BUSI_PLN_AMT	 TB_MAS031.BUSI_PLN_AMT%TYPE;    --사업계획량
    V_EXCTN_PLN_AMT	 TB_MAS031.EXCTN_PLN_AMT%TYPE;   --실행계획량    
BEGIN
   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'Y';
   V_RUN_SQL := 'Y';

   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=       V_JSON.get_string('SES_PLNTKY');

   /* 조건값 할당 */
   V_WERKS          	:=       V_JSON.get_string('WERKS');	    --플랜트
   V_PLN_YR             :=       V_JSON.get_string('PLN_YR');       --계획년도
   V_MACH_CD            :=       V_JSON.get_string('MACH_CD');      --설비코드
   V_PLN_MM             :=       V_JSON.get_string('PLN_MM');       --계획월

   IF P_TYPE = 'TOP' THEN /* 상단 리스트*/
 	V_SQL :=  ' SELECT      M012.MACH_CD                MACH_CD         --설비코드
                          , M012.MACH_NM                MACH_NM         --설비명
                          , M012.MACH_SHRT_NM           MACH_SHRT_NM    --설비명(단축)
                          , M012.PROC_CD                PROC_CD         --공정코드
                          , M013.WERKS                  WERKS           --플랜트코드  
                          , M013.PROC_NM                PROC_NM         --공정명
                          , M013.PROC_GRP_CD            PROC_GRP_CD     --공정그룹코드
                          , M013.PROC_GRP_NM            PROC_GRP_NM     --공정그룹명
                          , M013.PLANTNM                PLANTNM         --플랜트명
                          , M013.BUSICD                 BUSICD          --사업부코드
                          , M013.BUSINM                 BUSINM          --사업부명
                          , M013.PROD_GRP_CD            PROD_GRP_CD     --제품군코드
                          , M013.PROD_GRP_NM            PROD_GRP_NM     --제품군명
                          , M012.LINE                   LINE            --라인/호기
                          , M012.IFMC                   IFMC            --인터폴더 호기
                          , M012.INST_DT                INST_DT         --도입년월
                          , M012.ASST_NO                ASST_NO         --자산번호
                          , M012.PRD_UNIT               PRD_UNIT        --생산단위
                          , M012.DISPO_DT               DISPO_DT        --폐기일자
                          , M012.SAP_WRK_CD             SAP_WRK_CD      --SAP작업장코드
                          , M012.SAP_WRK_NM             SAP_WRK_NM      --SAP작업장켱
                          , M012.SAP_COST_CD            SAP_COST_CD     --SAP코스트센터
                          , M012.WCS_WRK_CD             WCS_WRK_CD      --WCS설비코드
                          , M012.WCS_WRK_NM             WCS_WRK_NM      --WCS설비코드명
                          , M012.PRFM_GTHR_YN           PRFM_GTHR_YN    --실적수집여부
                          , M012.ABN_STD_TM             ABN_STD_TM      --비가동 기준시간(분)
                          , M012.CYCLE_TM               CYCLE_TM        --사이클타임(초)
                          , M012.WRK_CD                 WRK_CD          --SAP작업장코드(지시)
                          , M012.MACHINE                MACHINE         --설비호기
                          , M012.REGDATE                REGDATE         --등록일시
                          , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = M012.REGID),M012.REGID)  
                                                        REGNM           --등록자
                          , M012.UPDDATE                UPDDATE         --수정일시
                          , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = M012.UPDID),M012.UPDID) 
                                                        UPDNM           --수정자
                      FROM TB_MAS012 M012,
                           (
                            SELECT  M013.PROC_CD          AS "PROC_CD",     
                                    M013.PROC_NM          AS "PROC_NM",
                                    M013.PROC_GRP_CD      AS "PROC_GRP_CD",
                                    CMDV_A.CDESC1         AS "PROC_GRP_NM",
                                    M013.WERKS            AS "WERKS",
                                    M002.PLANTNM          AS "PLANTNM",
                                    M013.PROD_GRP_CD      AS "PROD_GRP_CD",
                                    CMDV_B.CDESC1         AS "PROD_GRP_NM",
                                    M002.BUSICD           AS "BUSICD",
                                    CMDV_C.CDESC1         AS "BUSINM"
                             FROM  TB_MAS013 M013,  
                                   TB_MAS002 M002, 
                                   (SELECT CMCDVL, CDESC1 FROM CMCDV WHERE CMCDKY = ''PROCGRP'') CMDV_A, 
                                   (SELECT CMCDVL, CDESC1 FROM CMCDV WHERE CMCDKY = ''PRODGRP'') CMDV_B, 
                                   (SELECT CMCDVL, CDESC1 FROM CMCDV WHERE CMCDKY = ''BUSICD'')  CMDV_C  
                            WHERE  M013.PROC_GRP_CD = CMDV_A.CMCDVL(+)
                              AND  M013.WERKS       = M002.WERKS(+)
                              AND  M013.PROD_GRP_CD = CMDV_B.CMCDVL(+)
                              AND  M002.BUSICD      = CMDV_C.CMCDVL(+)                           
                           ) M013,
                           (SELECT DISTINCT PLN_YR, WERKS, MACH_CD  FROM TB_MAS030 WHERE PLN_YR = ''' || V_PLN_YR || ''' AND WERKS = ''' || V_WERKS || ''') M030
                     WHERE M012.PROC_CD  = M013.PROC_CD(+)
                       AND M012.MACH_CD  = M030.MACH_CD 
                       AND M013.WERKS    = M030.WERKS
              '
              ;

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND M013.WERKS = ''' || V_WERKS || '''';				   --플랜트   
        END IF;

     --   IF  V_PLN_YR IS NOT NULL OR TRIM(V_PLN_YR) != '' THEN
     --       V_SQL := V_SQL || ' AND MAS031.PLN_YR(+) = ''' || V_PLN_YR || '''';			      --계획년도
     --   END IF;

       	IF  V_MACH_CD IS NOT NULL OR TRIM(V_MACH_CD) != '' THEN
            V_SQL := V_SQL || ' AND M012.MACH_CD = ''' || V_MACH_CD || '''';			  --설비코드
        END IF;

        --V_SQL := V_SQL || ' GROUP BY CMCDV.CMCDVL ';  
        V_SQL := V_SQL || ' ORDER BY M012.MACH_CD      ';  

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;

   ELSIF P_TYPE = 'LIST' THEN /*좌측 조회 리스트*/

 	V_SQL :=  ' SELECT CMCDV.CMCDVL  PLN_MM   ' ;         --월
    V_SQL := V_SQL ||', ''' || V_MACH_CD ||  '''  MACH_CD ';	    --설비코드   

    --' AND MAS031.PLN_YR(+) = ''' || V_PLN_YR || ''''
    V_SQL := V_SQL ||' , CASE WHEN COUNT(*)> 1 THEN ''등록'' ELSE ''미등록'' END 
                                     REG_YN            --등록여부
                  FROM CMCDV        CMCDV              --공통코드
                     , TB_MAS031    MAS031             --설비별 목표 설정정보
                 WHERE 1=1
                   AND CMCDV.CMCDKY         = ''PLN_MM''           
                   AND CMCDV.CMCDVL         = MAS031.PLN_MM(+)
              '
              ;

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND MAS031.WERKS(+) = ''' || V_WERKS || '''';				   --플랜트   
        END IF;

        IF  V_PLN_YR IS NOT NULL OR TRIM(V_PLN_YR) != '' THEN
            V_SQL := V_SQL || ' AND MAS031.PLN_YR(+) = ''' || V_PLN_YR || '''';			      --계획년도
        END IF;

       	IF  V_MACH_CD IS NOT NULL OR TRIM(V_MACH_CD) != '' THEN
            V_SQL := V_SQL || ' AND MAS031.MACH_CD(+) = ''' || V_MACH_CD || '''';			  --설비코드
        END IF;

        V_SQL := V_SQL || ' GROUP BY CMCDV.CMCDVL  ';  
        V_SQL := V_SQL ||' , ''' || V_MACH_CD ||'''  ';
        V_SQL := V_SQL || ' ORDER BY CMCDV.CMCDVL      ';  

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;
    ELSIF P_TYPE = 'SUB_LIST' THEN /*우측 조회 리스트*/    

 	V_SQL :=  ' 
                 SELECT MAS030.MGMT_ITEM_CD         MGMT_ITEM_CD   --관리항목코드
                      , MAS030.MGMT_ITEM_NM         MGMT_ITEM_NM   --관리항목명
                      , MAS030.UNIT                 UNIT           --단위코드
					  , CMCDV.CDESC1	            UNIT_NM	       --단위명
                      , (
                            SELECT MAS018.DEPT_KR_NM
                              FROM TB_MAS018  MAS018           
                             WHERE MAS030.MGMT_DEPT_ID =  MAS018.DEPT_CD
                               AND ROWNUM =1
                        )                           DEPT_NM         --관리부서명
                      , NVL(MAS031.BUSI_PLN_AMT,0)  BUSI_PLN_AMT    --사업계획량        
                      , NVL(MAS031.EXCTN_PLN_AMT,0) EXCTN_PLN_AMT   --실행계획량
                   FROM TB_MAS030    MAS030             --설비별 목표 항목정보
                      , TB_MAS031    MAS031             --설비별 목표 설정정보
					  , CMCDV CMCDV		 		   		--공통코드(ITEM)
                  WHERE 1=1
                    AND MAS030.PLN_YR	    = MAS031.PLN_YR(+)          
                    AND MAS030.WERKS	    = MAS031.WERKS(+)       
                    AND MAS030.MACH_CD	    = MAS031.MACH_CD(+)         
                    AND MAS030.MGMT_ITEM_CD = MAS031.MGMT_ITEM_CD(+)
					AND CMCDV.CMCDVL = MAS030.UNIT(+)
					AND CMCDV.CMCDKY = ''UNIT''	';

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND MAS030.WERKS = ''' || V_WERKS || '''';				   --플랜트   
        END IF;

        IF  V_PLN_YR IS NOT NULL OR TRIM(V_PLN_YR) != '' THEN
            V_SQL := V_SQL || ' AND MAS030.PLN_YR = ''' || V_PLN_YR || '''';			      --계획년도
        END IF;

       	IF  V_MACH_CD IS NOT NULL OR TRIM(V_MACH_CD) != '' THEN
            V_SQL := V_SQL || ' AND MAS030.MACH_CD = ''' || V_MACH_CD || '''';			   	  --설비코드
        END IF;

       	IF  V_PLN_MM IS NOT NULL OR TRIM(V_PLN_MM) != '' THEN
            V_SQL := V_SQL || ' AND MAS031.PLN_MM(+) = ''' || V_PLN_MM || '''';			   	  --계획월
        END IF;

        V_SQL := V_SQL || ' ORDER BY MAS030.MGMT_ITEM_CD      ';  

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;


    ELSIF P_TYPE = 'SAVE' THEN  --저장

        V_ARR_LIST        := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ						:= TREAT (V_ARR_LIST.get (i) AS json_object_t);  
            V_OBJ						:= TREAT (V_OBJ.get ('map') AS json_object_t);   

            V_MGMT_ITEM_CD	            := V_OBJ.get_string('MGMT_ITEM_CD');    --관리항목코드
            V_BUSI_PLN_AMT	            := V_OBJ.get_string('BUSI_PLN_AMT');    --사업계획량
            V_EXCTN_PLN_AMT	            := V_OBJ.get_string('EXCTN_PLN_AMT');   --실행계획량    

            BEGIN
                        INSERT INTO TB_MAS031 (               --설비별 목표 설정정보
                             PLN_YR	        --계획년도
                            ,WERKS	        --플랜트
                            ,MACH_CD	    --설비 코드
                            ,MGMT_ITEM_CD	--관리항목코드
                            ,PLN_MM	        --계획월
                            ,BUSI_PLN_AMT	--사업계획량
                            ,EXCTN_PLN_AMT	--실행계획량
                            ,REGDATE	    --등록일시
                            ,REGID	        --등록자ID
                            ,UPDDATE	    --수정일시
                            ,UPDID	        --수정자ID
                        ) VALUES (
                             V_PLN_YR	        --계획년도
                            ,V_WERKS	        --플랜트
                            ,V_MACH_CD	        --설비 코드
                            ,V_MGMT_ITEM_CD	    --관리항목코드
                            ,V_PLN_MM	        --계획월
                            ,V_BUSI_PLN_AMT	    --사업계획량
                            ,V_EXCTN_PLN_AMT	--실행계획량
                            ,SYSDATE	        --등록일시
                            ,V_SESS_USER_ID	    --등록자ID
                            ,NULL	            --수정일시
                            ,NULL	            --수정자ID                
                        ) ; 
             EXCEPTION
                                    WHEN DUP_VAL_ON_INDEX THEN
                                        UPDATE TB_MAS031              --설비별 목표 설정정보
                                        SET   BUSI_PLN_AMT	    = V_BUSI_PLN_AMT   --사업계획량
                                             ,EXCTN_PLN_AMT	    = V_EXCTN_PLN_AMT  --실행계획량
                                             ,UPDDATE	        = SYSDATE          --수정일시
                                             ,UPDID	            = V_SESS_USER_ID   --수정자ID
                                        WHERE WERKS             = V_WERKS          --플랜트
                                          AND PLN_YR            = V_PLN_YR         --계획년도
                                          AND MACH_CD           = V_MACH_CD        --설비 코드 
                                          AND MGMT_ITEM_CD	    = V_MGMT_ITEM_CD   --관리항목코드
                                          AND PLN_MM            = V_PLN_MM         --계획월 
                                          ;                                
              END;        


        END LOOP;
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
