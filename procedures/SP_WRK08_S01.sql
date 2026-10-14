
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK08_S01" (
    p_type     IN VARCHAR2, -- LIST, SAVE
    p_json_str IN CLOB,
    p_success  OUT VARCHAR2,
    P_ERR_MSG  OUT VARCHAR2,
    P_DOC_NO   OUT VARCHAR2,
    p_rs_list  OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK08_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 완제품  부적합 폐기	 {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 자재/완제품 불출요청 를 관리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박충식{최초 작성자 명 기술}
 * CREATE DATE   : 2022/06/16 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/06/16    1.0.0   박충식         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_SCH013] : (CRUD) 작업지시 패드 정보
 * *      
 *=============================================================================*/ AS

    v_prg_nm          VARCHAR2(100) := 'SP_WRK08_S01';     -- PROCEDURE NAME


    -- 오라클 에러 처리용 변수선언 영역
    e_exception_user EXCEPTION;
    e_sql_err_cd      NUMBER(5) := 0;
    e_sql_err_msg     VARCHAR2(4000);

   -- V_RTN_CLOB       CLOB;
   -- V_RTN_CURSOR     SYS_REFCURSOR;
   -- V_ERROR          CLOB;

    -- JSON을 위한 변수선언 영역
    v_json            json_object_t;
    v_arr_list        json_array_t;
    v_arr_head        json_array_t;
    v_obj             json_object_t;

    -- 세션값 처리용 변수선언 영역
    v_sql             VARCHAR2(4000);  /*CLOB;*/
    v_run_sql         VARCHAR2(1);
    v_range_sql       VARCHAR2(4000);

   -- 2022-05-10(화요일)-안상현, 하위 쿼리 조건 추가
    v_out_sql         CLOB;
    v_doc_sql         VARCHAR2(1000);
    v_debug           VARCHAR2(1);

    -- 세션값 처리용 변수선언 영역
    v_plt_cd          VARCHAR2(2);
    v_sess_user_id    VARCHAR2(20);

    -- 조건절 처리용 변수선언 영역
    v_werks           tb_inv001.werks%TYPE;		--플랜트
    v_apvr_sta        tb_inv001.apvr_sta%TYPE;         --결재상태         

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역
    v_stor_loc_cd     tb_inv001.stor_loc_cd%TYPE;           --저장위치
    v_ind_bcd         tb_inv001.order_no%TYPE;	            --개별바코드
    v_matnr           tb_inv001.matnr%TYPE;                 --자재코드

    v_LOT_NO          tb_inv001.LOT_NO%TYPE;                --LOT NO
    v_PRFM_DT	      tb_inv001.PRFM_DT%TYPE;               --실적일자 

    V_DISPO_DT          VARCHAR2(10);
    V_DISPO_QTY         TB_INV001.DISPO_QTY%TYPE;
    V_UNIT              VARCHAR2(10);
    V_MDOCNO            VARCHAR2(30);    
    V_DOC_ID            TB_INV001.DOC_ID%TYPE;
	V_BUDAT				TB_IFS009.BUDAT%TYPE;
BEGIN
    OPEN p_rs_list FOR SELECT   NULL     FROM dual   WHERE     ROWNUM = 0;

    v_debug := 'N';
    v_run_sql := 'Y';
    v_json := json_object_t.parse(p_json_str);
    v_sess_user_id := v_json.get_string('SES_USER_ID');
    v_plt_cd := v_json.get_string('SES_PLNTKY');

   /* 조건값 할당 */
    v_werks := v_json.get_string('WERKS');	         --플랜트
    v_apvr_sta := v_json.get_string('APVR_STA');     --결재상태         
    v_matnr    := v_json.get_string('MATNR');        --자재코드
    v_LOT_NO   := v_json.get_string('LOT_NO');       --LOT NO
    v_PRFM_DT  := v_json.get_string('PRFM_DT');	     --실적일자 
    V_DOC_ID   := v_json.get_string('DOC_ID');	     --결재ID
	V_RANGE_SQL         := V_JSON.get_string('RANGE_SQL');

    IF p_type = 'LIST' THEN /*상단 조회 리스트*/

        v_sql := '
                    SELECT 
                            INV001.WERKS                                WERKS                   --플랜트코드
                           ,INV001.STOR_LOC_CD                          STOR_LOC_CD             --저장위치
                           ,MAS003.STOR_LOC_NM                          STOR_LOC_NM             --저장위치명
                           ,INV001.MATNR                                MATNR                   --자재코드
                           ,MAS001.MATNR_NM                             MATNR_NM                --자재명
                           ,INV001.LOT_NO                               LOT_NO                  --LOT NO
                           ,INV001.IND_BCD                              IND_BCD                 --개별바코드
                           ,INV001.PRFM_DT	                            PRFM_DT                 --실적일자 
                           ,INV001.STCK_STA                             STCK_STA                --재고상태 
                           ,FN_CMCDV (''STCK_STA'', INV001.STCK_STA)    STCK_STA_NM             --재고상태명 
                           ,INV001.UNIT                                 UNIT                    --단위
                           ,FN_CMCDV (''UNIT'', INV001.UNIT)            UNIT_NM                 --단위명 
                           ,DECODE(NVL(INV001.STCK_QTY, ''0''), ''0'', INV001.DISPO_QTY, INV001.STCK_QTY)        DISPO_QTY               --폐기수량
                           ,NVL(INV001.APVR_STA, ''0'')                 APVR_STA                --결재상태
                           ,FN_CMCDV (''APVR_STA'', NVL(INV001.APVR_STA, ''0''))   
                                                                        APVR_STA_NM             --결재상태명 
                           ,NVL(INV001.STCK_STA, ''00'')                STCK_STA                --재고상태
                           ,FN_CMCDV (''STCK_STA'', NVL(INV001.STCK_STA, ''00''))   
                                                                        STCK_STA_NM             --재고상태명 
                           ,NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = INV001.CFRM_ID),INV001.CFRM_ID)
                                                                        CFRM_ID	                --승인자  
                           ,INV001.CFRM_DATE	                        CFRM_DATE	            --승인일시
                           ,INV001.DOC_ID	                            DOC_ID	                --결재ID
                      FROM TB_INV001   INV001     --창고별 재고현황
                         , TB_MAS001   MAS001     --플랜트별 제품/자재 마스터
                         , TB_MAS003   MAS003     --저장위치 마스터(공정창고내 저장위치 포함)
                     WHERE INV001.WERKS = MAS001.WERKS (+)
                       AND INV001.MATNR = MAS001.MATNR (+)
                       AND INV001.WERKS =   MAS003.WERKS(+)
                       AND INV001.STOR_LOC_CD = MAS003.STOR_LOC_CD(+)
                       AND INV001.STOR_LOC_CD = ''2020''
                       --AND INV001.STCK_STA  IN (''30'', ''40'', ''50'')  
              ';
        IF v_werks IS NOT NULL OR trim(v_werks) != '' THEN
            v_sql := v_sql
                     || ' AND INV001.WERKS = '''
                     || v_werks
                     || '''';				   --플랜트   
        END IF;

        IF v_apvr_sta IS NOT NULL OR trim(v_apvr_sta) != '' THEN
            v_sql := v_sql
                     || ' AND NVL(INV001.APVR_STA, ''0'') = '''
                     || v_apvr_sta
                     || '''';				   --결재상태   
        END IF;

        /*IF v_matnr IS NOT NULL OR trim(v_matnr) != '' THEN
            v_sql := v_sql
                     || ' AND INV001.matnr = '''|| v_matnr|| '''';				   --자재코드   
        END IF;

        IF v_LOT_NO IS NOT NULL OR trim(v_LOT_NO) != '' THEN
            v_sql := v_sql
                     || '  AND  INV001.LOT_NO = '''
                     || v_LOT_NO
                     || '''';				   --LOT NO   
        END IF;

        IF v_PRFM_DT IS NOT NULL OR trim(v_PRFM_DT) != '' THEN
            v_sql := v_sql|| '  AND  INV001.PRFM_DT = '''|| v_PRFM_DT ||'''';				   --실적일자   
        END IF;*/
       
       IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
        	--V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'WERKS', 'INV001.WERKS');	--플랜트
        	V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MATNR', 'INV001.MATNR');	--자재코드
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;
       
        --20220927 여한진 화장지 합지, 점보롤은 폐기처리할 수 있기 때문에 반제품도 폐기할 수 있게 조건 추가 
        v_sql := v_sql || '  AND  MAS001.MATNR_DIV IN(''HALB'', ''FERT'') ';				   --유형  반제품/완제품 


        v_sql := v_sql || ' ORDER BY INV001.WERKS , INV001.STOR_LOC_CD, INV001.MATNR';
        IF ( v_debug = 'Y' ) THEN
            INSERT INTO proc_log ( sql_str ) VALUES ( v_sql );

        END IF;

        OPEN p_rs_list FOR v_sql;
    ELSIF p_type = 'LIST2' THEN /*결재리스트*/
         V_SQL := 'SELECT A.MATNR,
                        M001.MATNR_NM,
                        A.DISPO_QTY,
                        A.MACHINE,
                        A.DISPO_CAUSE,
                        A.RMK
                    FROM(
                          SELECT I001.WERKS, 
                                I001.MATNR,
                                SUM(FN_CHG_UNIT(I001.MATNR, I001.WERKS, I001.UNIT, ''BAG'',  NVL(I001.STCK_QTY, 0))) AS DISPO_QTY,
                                M012.MACHINE,
                                ''''     AS DISPO_CAUSE,
                                ''''     AS RMK
                          FROM TB_INV001 I001,
                               TB_MAS012 M012
                         WHERE I001.MACH_CD = M012.MACH_CD(+)
                           AND I001.DOC_ID = ''' || V_DOC_ID || '''
                         GROUP BY I001.WERKS, I001.MATNR, M012.MACHINE
                         ) A,
                        TB_MAS001 M001
                   WHERE A.WERKS = M001.WERKS(+)
                     AND A.MATNR = M001.MATNR(+)
                 ORDER BY A.MATNR';  

         OPEN P_RS_LIST FOR V_SQL;   

    ELSIF p_type = 'SAVE' THEN  --결재
        v_arr_list := v_json.get_array('list');

        FOR i IN 0..v_arr_list.get_size - 1 LOOP
            v_obj := TREAT(v_arr_list.get(i) AS json_object_t);
            v_obj := TREAT(v_obj.get('map') AS json_object_t);

            v_werks         := v_obj.get_string('WERKS');               --플랜트
            v_stor_loc_cd   := v_obj.get_string('STOR_LOC_CD');         --저장위치
            v_ind_bcd       := v_obj.get_string('IND_BCD');	            --개별바코드
            v_matnr         := v_obj.get_string('MATNR');               --자재코드

            SELECT  NVL(APVR_STA, '0')     --결재상태   
              INTO  v_apvr_sta
            FROM TB_INV001         --창고별 재고현황
            WHERE WERKS           = v_werks
              AND STOR_LOC_CD     = v_stor_loc_cd
              AND IND_BCD         = v_ind_bcd
              AND MATNR           = v_matnr
            --  AND STCK_STA        = '03'     --재고상태  30(불합격) 
              ;


           IF  v_apvr_sta IN ('0','1','3') THEN  -- 작성중  , 결재요청 , 결재반려 

               UPDATE TB_INV001             --창고별 재고현황
                  SET  APVR_STA  = '1'                  --결재상태:결재완료   
                      ,CFRM_ID	 = v_sess_user_id       --승인자      
                      ,CFRM_DATE = SYSDATE	            --승인일시   
                WHERE WERKS           = v_werks
                  AND STOR_LOC_CD     = v_stor_loc_cd
                  AND IND_BCD         = v_ind_bcd
                  AND MATNR           = v_matnr
                  ;

           END IF;   

        END LOOP;
    ELSIF p_type = 'SAVE1' THEN  --반려
        v_arr_list := v_json.get_array('list');

        FOR i IN 0..v_arr_list.get_size - 1 LOOP
            v_obj := TREAT(v_arr_list.get(i) AS json_object_t);
            v_obj := TREAT(v_obj.get('map') AS json_object_t);

            v_werks         := v_obj.get_string('WERKS');               --플랜트
            v_stor_loc_cd   := v_obj.get_string('STOR_LOC_CD');         --저장위치
            v_ind_bcd       := v_obj.get_string('IND_BCD');	            --개별바코드
            v_matnr         := v_obj.get_string('MATNR');               --자재코드

            SELECT  NVL(APVR_STA, '0')     --결재상태   
              INTO  v_apvr_sta
            FROM TB_INV001         --창고별 재고현황
            WHERE WERKS           = v_werks
              AND STOR_LOC_CD     = v_stor_loc_cd
              AND IND_BCD         = v_ind_bcd
              AND MATNR           = v_matnr
            --  AND STCK_STA        = '03'     --재고상태  30(불합격) 
              ;


           IF  v_apvr_sta IN ('0','1','2','3') THEN  -- 작성중  , 결재요청 , 결재반려 

               UPDATE TB_INV001             --창고별 재고현황
                  SET  APVR_STA  = '3'                  --결재상태:결재반려   
                      ,CFRM_ID	 = v_sess_user_id       --승인자      
                      ,CFRM_DATE = SYSDATE	            --승인일시   
                WHERE WERKS           = v_werks
                  AND STOR_LOC_CD     = v_stor_loc_cd
                  AND IND_BCD         = v_ind_bcd
                  AND MATNR           = v_matnr
                  ;
            END IF;   
       END LOOP;             
    ELSIF p_type = 'SAVE2' THEN  --폐기
        v_arr_list := v_json.get_array('list');

        FOR i IN 0..v_arr_list.get_size - 1 LOOP
            v_obj := TREAT(v_arr_list.get(i) AS json_object_t);
            v_obj := TREAT(v_obj.get('map') AS json_object_t);

            v_werks         := v_obj.get_string('WERKS');              --플랜트
            v_stor_loc_cd   := v_obj.get_string('STOR_LOC_CD');        --저장위치
            v_ind_bcd       := v_obj.get_string('IND_BCD');	           --개별바코드
            v_matnr         := v_obj.get_string('MATNR');              --자재코드
            V_LOT_NO        := v_obj.get_string('LOT_NO');             --LOT NO
            V_DISPO_QTY      := v_obj.get_string('DISPO_QTY');         --폐기수량
            V_UNIT          := v_obj.get_string('UNIT');               --단위

            SELECT  NVL(APVR_STA, '0')     --결재상태   
              INTO  v_apvr_sta
            FROM TB_INV001         --창고별 재고현황
            WHERE WERKS           = v_werks
              AND STOR_LOC_CD     = v_stor_loc_cd
              AND IND_BCD         = v_ind_bcd
              AND MATNR           = v_matnr
            --  AND STCK_STA        = '03'     --재고상태  30(불합격) 
              ;

           IF  v_apvr_sta IN ('2') THEN  -- 작성중  , 결재요청 , 결재반려 

                SELECT FN_GET_MDOCNO(V_WERKS, 'IF131')  INTO V_MDOCNO  FROM DUAL ;   --MES 문서번호

                UPDATE TB_INV001     --창고별 재고현황
                   SET STCK_QTY = 0                   --재고수량 감소
                     , DISPO_DT = V_DISPO_DT                        --폐기일자
                     , DISPO_QTY = V_DISPO_QTY              --폐기 수량
                     , STCK_STA = '50'                     -- 폐기재고 상태
                     , APVR_STA	= '4'                       --결재상태 확정
                     , DLFL = 'Y'
                     , UPDDATE	= SYSDATE                   --수정일시
                     , UPDID	= V_SESS_USER_ID            --수정자ID
                 WHERE WERKS               = V_WERKS          --플랜트코드        
                   AND STOR_LOC_CD         = V_STOR_LOC_CD    --저장위치
                   AND IND_BCD             = V_IND_BCD        --개별바코드 
                   AND MATNR	           = V_MATNR;          --품목코드	
				
                --20230203 여한진 전기일자 추가
                V_BUDAT	:= FN_RECDATE(SYSDATE);
                   
                INSERT INTO TB_IFS009     --재고 이전 TXN(이동유형:551) 
                             (
                                     BWART	            --이동유형,(재고이전:311, 등급변경:309, 재고실사: )
                                    ,WERKS_FROM	        --플랜트(From)
                                    ,WERKS_TO	        --플랜트(To)
                                    ,MATNR_FROM	        --자재번호(From),등급변경시, 재고이전(From,To 동일)
                                    ,MATNR_TO	        --자재번호(To),등급변경시, 재고이전(From,To 동일)
                                    ,LGORT_FROM	        --저장위치(From), 재고이전시, 등급변경(From,To 동일)
                                    ,LGORT_TO	        --저장위치(To), 재고이전시, 등급변경(From,To 동일)
                                    ,CHARG_FROM	        --LOT번호(From)
                                    ,CHARG_TO	        --LOT번호(To)
                                    ,MENGE	            --이동량
                                    ,MEINS	            --이동단위
                                    ,FAULTY	            --부적합 지시자
                                    ,MDOCNO	            --MES 문서번호
                                    ,MDOCSEQ	        --MES 문서순번
                                    ,MBLNR	            --SAP 문서번호
                                    ,MJAHR	            --SAP 문서번호(년도)
                                    ,BUDAT				--전기일자
                                    ,ZRESULT	        --SAP 결과값 Return( S:성공, E:오류 )
                                    ,ZMESSAGE	        --SAP결과 메시지
                                    ,ZRESULT_DATE	    --SAP 전송 시간
                                    ,IF_MES_KEY         --MES Inserface Key(MES->SAP 인 경우만)
                                    ,MAKE_DATE	        --등록일자
                                    ,MAKER	            --등록자         
                             ) VALUES (
                                     '551'	            --이동유형,(재고이전:311, 등급변경:309, 재고실사: )
                                    ,V_WERKS	        --플랜트(From)
                                    ,V_WERKS	        --플랜트(To)
                                    ,V_MATNR	        --자재번호(From),등급변경시, 재고이전(From,To 동일)
                                    ,V_MATNR	        --자재번호(To),등급변경시, 재고이전(From,To 동일)
                                    ,V_STOR_LOC_CD      --저장위치(From), 재고이전시, 등급변경(From,To 동일)
                                    ,V_STOR_LOC_CD      --저장위치(To), 재고이전시, 등급변경(From,To 동일)
                                    ,V_LOT_NO	        --LOT번호(From)
                                    ,V_LOT_NO	        --LOT번호(To)
                                    ,V_DISPO_QTY	    --이동량
                                    ,V_UNIT	            --이동단위
                                     ,''	                --부적합 지시자
                                    ,V_MDOCNO	        --MES 문서번호
                                    ,1 	                --MES 문서순번
                                    ,NULL	            --SAP 문서번호
                                    ,NULL	            --SAP 문서번호(년도)
                                    ,V_BUDAT			--전기일자
                                    ,'N'	            --SAP 결과값 Return( S:성공, E:오류 )
                                    ,NULL	            --SAP결과 메시지
                                    ,NULL	            --SAP 전송 시간
                                    ,NULL               --MES Inserface Key(MES->SAP 인 경우만)                
                                    ,SYSDATE	        --등록일자
                                    ,V_SESS_USER_ID	    --등록자         
                             );
                    P_DOC_NO := V_MDOCNO;
           END IF;   

        END LOOP;        
    END IF;

    p_success := 'Y';
    COMMIT;

EXCEPTION
    WHEN e_exception_user THEN

        -- 에러 내역 SET
        p_success := 'N';
        e_sql_err_cd := sqlcode;
        e_sql_err_msg := substrb(sqlerrm, 1, 300);
        ROLLBACK;
        sp_proc_error(v_plt_cd, v_prg_nm, e_sql_err_cd, e_sql_err_msg, v_sess_user_id);
    WHEN OTHERS THEN
        p_success := 'N';
        e_sql_err_cd := sqlcode;
        e_sql_err_msg := 'EXCEPTION OTHER ERROR. ['
                         || substr(sqlerrm, 1, 500)
                         || ']';
        ROLLBACK;
        --raise_application_error(e_sql_err_cd, e_sql_err_msg);
        raise;
END;
/
