
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK40_S01" (
	P_TYPE         IN   varchar2, -- LIST, SUB_LIST-A, SUB_LIST-B
	P_JSON_STR     IN   varchar2, --CLOB,
	P_SUCCESS      OUT  varchar2,
    P_ERR_MSG      OUT  VARCHAR2, 
	P_RS_LIST      OUT  SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK40_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 약품 사용현황 {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 약품 사용이력을 조회 {프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박성철{최초 작성자 명 기술}
 * CREATE DATE   : 2022/07/15 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   박성철         Initial Version 
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK40_S01';     -- PROCEDURE NAME


    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_OBJECT_T;
    V_OBJ            JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(10);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS			TB_INV005.WERKS%TYPE;		--플랜트
    V_MACHINE       TB_SCH008.MACHINE%TYPE;     --설비코드 

	V_MACH_CD       TB_INV005.MACH_CD%TYPE;     --설비코드
	V_MATNR_GRP_NM  TB_MAS001.MATNR_GRP_NM%TYPE;     --자재그룹
    V_INP_QTY       TB_INV005.INP_QTY%TYPE;
    V_CHG_QTY       TB_INV005.INP_QTY%TYPE;
    V_REM_QTY       TB_INV005.INP_QTY%TYPE;
    V_MATNR         TB_INV005.MATNR%TYPE;
    V_IND_BCD       TB_INV005.IND_BCD%TYPE;
    V_LOT_NO        TB_INV005.LOT_NO%TYPE;
    V_PDOC_NO       TB_INV005.PDOC_NO%TYPE;
    V_PROC_CD       TB_MAS012.PROC_CD%TYPE;
    V_STOR_LOC_CD   varchar2(20);
    V_DATE          DATE := SYSDATE;
    V_WERKS1			TB_INV005.WERKS%TYPE;		--플랜트
    
BEGIN
    OPEN P_RS_LIST FOR 

    SELECT NULL FROM DUAL WHERE ROWNUM = 0;

    V_DEBUG := 'N';
    V_RUN_SQL := 'Y';

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

    V_SESS_USER_ID       :=      V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=      V_JSON.get_string('SES_PLNTKY');

   /* 조건값 할당 */
   V_WERKS          	:=       V_JSON.get_string('WERKS');	    --플랜트
   V_MACHINE            :=       V_JSON.get_string('MACHINE');      --생산호기
   V_RANGE_SQL 		    :=       V_JSON.get_string('RANGE_SQL');   	--작업지시번호, 작업지시번호 순번
   V_PROC_CD            :=       V_JSON.get_string('PROC_CD');   	--공정코드
   V_MACH_CD 		    :=       V_JSON.get_string('MACH_CD');   	--설비코드
   V_MATNR_GRP_NM 		:=       V_JSON.get_string('MATNR_GRP_CD'); --자재그룹
   


   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/
        V_SQL := 'SELECT CASE WHEN A.SEQ = 1 THEN A.WERKS ELSE ''합계'' END      WERKS     		--플랜트
					     , CASE WHEN  A.SEQ = 1 THEN A.INP_DT   ELSE '''' END   INP_DT          --투입일자   
                         , CASE WHEN  A.SEQ = 1 THEN A.MACH_CD  ELSE '''' END   MACH_CD   		--설비코드
					     , CASE WHEN  A.SEQ = 1 THEN A.MACH_NM  ELSE '''' END   MACH_NM   		--설비명
                         , CASE WHEN  A.SEQ = 1 THEN A.MATNR    ELSE '''' END   MATNR           --자재코드	 
					     , CASE WHEN  A.SEQ = 1 THEN A.MATNR_NM ELSE '''' END   MATNR_NM        --자재명
                         , CASE WHEN  A.SEQ = 1 THEN A.PDOC_NO  ELSE '''' END   PDOC_NO         --문서번호(보이지 않음)
					     --, CASE WHEN  A.SEQ = 1 THEN A.LOT_NO   ELSE '''' END   LOT_NO          --LOT NO
                         --, CASE WHEN  A.SEQ = 1 THEN A.IND_BCD  ELSE '''' END   IND_BCD         --공급업체바코드 
					     , A.USE_QTY                 --투입량 
                         , ''''             USE_CHG_QTY         --사용량보정
					     , A.UNIT           UNIT            --단위 
					     , CASE WHEN  A.SEQ = 1 THEN A.MATNR_GRP_CD ELSE '''' END   MATNR_GRP_CD    --자재그룹코드(보이지 않음)
					     , CASE WHEN  A.SEQ = 1 THEN A.MATNR_GRP_NM ELSE '''' END   MATNR_GRP_NM    --자재그룹명(보이지 않음)
					     , CASE WHEN  A.SEQ = 1 THEN A.INP_NM	    ELSE '''' END   INP_NM--투입자명   
					     , CASE WHEN  A.SEQ = 1 THEN A.REGDATE      ELSE NULL END   REGDATE         --등록일시    
					     , CASE WHEN  A.SEQ = 1 THEN A.REGNM	    ELSE '''' END   REGNM --등록자명   
					     , CASE WHEN  A.SEQ = 1 THEN A.UPDDATE      ELSE NULL END   UPDDATE         --수정일시      
					     , CASE WHEN  A.SEQ = 1 THEN A.UPDNM	    ELSE ''''  END  UPDNM--수정자명          
                    FROM(
                    
                        SELECT 1 SEQ
                             ,  INV005.WERKS       	    WERKS     		--플랜트
                             , INV005.INP_DT            INP_DT          --투입일자   
                             , INV005.MACH_CD     	    MACH_CD   		--설비코드
                             , MAS012.MACH_NM     	    MACH_NM   		--설비명
                             , INV005.MATNR             MATNR           --자재코드	 
                             , MAS001.MATNR_NM          MATNR_NM        --자재명
                             , INV005.PDOC_NO           PDOC_NO         --문서번호(보이지 않음)
                             --, INV005.LOT_NO          LOT_NO          --LOT NO
                             --, INV005.IND_BCD         IND_BCD         --공급업체바코드 
                             , INV005.INP_QTY           USE_QTY         --투입량 
                             , MAS001.UNIT              UNIT            --단위 
                             , MAS001.MATNR_GRP_CD      MATNR_GRP_CD    --자재그룹코드(보이지 않음)
                             , MAS001.MATNR_GRP_NM      MATNR_GRP_NM    --자재그룹명(보이지 않음)
                             , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = INV005.REGID),INV005.REGID) INP_NM	        --투입자명   
                             , INV005.REGDATE           REGDATE         --등록일시    
                             , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = INV005.REGID),INV005.REGID) REGNM	        --등록자명   
                             , INV005.UPDDATE           UPDDATE         --수정일시      
                             , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = INV005.UPDID),INV005.UPDID) UPDNM	        --수정자명          
					     FROM TB_INV005 INV005  --약품 투입이력
                          LEFT JOIN TB_MAS012 MAS012  --설비 마스터
                            ON MAS012.MACH_CD = INV005.MACH_CD
                          LEFT JOIN TB_MAS001 MAS001  --플랜트별 제품/자재 마스터
                            ON MAS001.MATNR = INV005.MATNR
                           AND MAS001.WERKS = INV005.WERKS
                        WHERE 1=1 ';


        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND INV005.WERKS = ''' || V_WERKS || '''';				    --플랜트   
        END IF;

        IF  V_PROC_CD IS NOT NULL OR TRIM(V_PROC_CD) != '' THEN
            V_SQL := V_SQL || ' AND MAS012.PROC_CD = ''' || V_PROC_CD || '''';			    --설비코드
        END IF;

        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_SQL := V_SQL || V_RANGE_SQL ;			                       	               --투입일자(INV005.INP_DT) ,자제그룹(MAS001.MATNR_GRP_CD)
        END IF;
        
        V_SQL := V_SQL || ' UNION ALL
                            SELECT 2                    SEQ
                                 , INV005.WERKS       	WERKS     		--플랜트
                                 , INV005.INP_DT        INP_DT          --투입일자   
                                 , INV005.MACH_CD     	MACH_CD   		--설비코드
                                 , ''''   	            MACH_NM   		--설비명
                                 , INV005.MATNR         MATNR           --자재코드	 
                                 , ''''                 MATNR_NM        --자재명
                                 , ''''                 PDOC_NO         --문서번호(보이지 않음)
                                 --, INV005.LOT_NO      LOT_NO          --LOT NO
                                 --, INV005.IND_BCD     IND_BCD         --공급업체바코드 
                                 , SUM(INV005.INP_QTY)  USE_QTY         --투입량 
                                 , INV005.UNIT          UNIT            --단위 
                                 , ''''                 MATNR_GRP_CD    --자재그룹코드(보이지 않음)
                                 , ''''                 MATNR_GRP_NM    --자재그룹명(보이지 않음)
                                 , ''''                 INP_NM	        --투입자명   
                                 , NULL                 REGDATE         --등록일시    
                                 , ''''	                REGNM	        --등록자명   
                                 , NULL                 UPDDATE         --수정일시      
                                 , ''''	                UPDNM	        --수정자명
                              FROM TB_INV005 INV005
                              LEFT JOIN TB_MAS012 MAS012  --설비 마스터
                             ON MAS012.MACH_CD = INV005.MACH_CD
                             LEFT JOIN TB_MAS001 MAS001  --플랜트별 제품/자재 마스터
                             ON MAS001.MATNR = INV005.MATNR
                             AND MAS001.WERKS = INV005.WERKS
                             WHERE 1=1'; 
        
        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND INV005.WERKS = ''' || V_WERKS || '''';				    --플랜트   
        END IF;

        IF  V_PROC_CD IS NOT NULL OR TRIM(V_PROC_CD) != '' THEN
            V_SQL := V_SQL || ' AND MAS012.PROC_CD = ''' || V_PROC_CD || '''';			    --설비코드
        END IF;

        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_SQL := V_SQL || V_RANGE_SQL ;			                       	               --투입일자(INV005.INP_DT)
        END IF;
        
        V_SQL := V_SQL || ' GROUP BY INV005.WERKS, INV005.INP_DT, INV005.MACH_CD, INV005.MATNR, INV005.UNIT ';
        
        V_SQL := V_SQL || ' ) A
                          ORDER BY A.WERKS, A.MACH_CD, A.INP_DT, A.MATNR, A.UNIT , A.SEQ';  

       INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
--        COMMIT;
		OPEN P_RS_LIST FOR V_SQL;


    ELSIF P_TYPE = 'SAVE' THEN
    	V_ARR_LIST        := V_JSON.get_array('list');
        
        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ			:= TREAT (V_ARR_LIST.get (i) AS json_object_t);  
            V_OBJ			:= TREAT (V_OBJ.get ('map') AS json_object_t);   
            
            V_WERKS1	        := V_OBJ.get_string('WERKS');
            V_MACH_CD       := V_OBJ.get_string('MACH_CD');
            V_MATNR         := V_OBJ.get_string('MATNR');
            --V_IND_BCD       := V_OBJ.get_string('IND_BCD');
            --V_LOT_NO        := V_OBJ.get_string('LOT_NO');
            --V_STOR_LOC_CD   := V_OBJ.get_string('STOR_LOC_CD');
            V_PDOC_NO       := V_OBJ.get_string('PDOC_NO');
            V_INP_QTY       := V_OBJ.get_number('USE_QTY');
            V_CHG_QTY       := V_OBJ.get_number('USE_CHG_QTY');


            
            --IF V_WERKS <> '합계' THEN
                V_REM_QTY := V_INP_QTY - V_CHG_QTY;
                
              --  P_SUCCESS           := 'N';                   
              --  P_ERR_MSG           := 'V_STOR_LOC_CD ' ||V_WERKS1 ||' '|| V_MATNR||' '||V_STOR_LOC_CD;
              --  RETURN ;

                /*
                SELECT NVL(LGPRO, ' ') INTO V_STOR_LOC_CD
                  FROM TB_MAS001
                 WHERE WERKS = V_WERKS1
                   AND MATNR = V_MATNR;
               */

                UPDATE TB_INV005
                   SET INP_QTY = V_CHG_QTY,
                       UPDDATE = V_DATE,
                       UPDID = V_SESS_USER_ID
                 WHERE WERKS = V_WERKS1
                   AND MACH_CD = V_MACH_CD
                   AND PDOC_NO = V_PDOC_NO;
                   
                UPDATE TB_INV001
                   SET STCK_QTY = STCK_QTY + V_REM_QTY
                 WHERE WERKS = V_WERKS1
                   --AND STOR_LOC_CD = V_STOR_LOC_CD
                   --AND NVL(TRIM(IND_BCD), '*') = NVL(TRIM(V_IND_BCD), '*')
                   AND MATNR = V_MATNR;
                   --AND NVL(TRIM(LOT_NO), '*') = NVL(TRIM(V_LOT_NO), '*');
                
                IF SQL%ROWCOUNT = 0 THEN
                    P_SUCCESS := 'N';
                    P_ERR_MSG := V_MATNR || ' 자재의 개별바코드 및 LOT 번호를 확인해주세요';
                    ROLLBACK;
                    RETURN;
                END IF;
            --END IF;
        END LOOP;
    END IF;

    P_SUCCESS := 'Y';
    COMMIT;
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
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
