--------------------------------------------------------
--  DDL for Procedure SP_SCH18_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SCH18_S01" (
    p_type     IN VARCHAR2, -- LIST, SAVE
    p_json_str IN CLOB,
    p_success  OUT VARCHAR2,
    p_rs_list  OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_SCH18_S01
 * PROGRAM NAME  : 계획대비 실적현황
 * VERSION       : 1.0.0
 * DESCRIPTION   : 계획대비 실적현황 을 조회한다.
 *                 
 * AUTHOR NAME   : 박충식
 * CREATE DATE   : 2022/05/18
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/18    1.0.0   박충식         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_SCH015] : (CRUD) 점보롤 작업지시 정보
 * *      
 *=============================================================================*/ AS

    v_prg_nm       VARCHAR2(100) := 'SP_SCH18_S01';     -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수선언 영역
    e_exception_user EXCEPTION;
    e_sql_err_cd   NUMBER(5) := 0;
    e_sql_err_msg  VARCHAR2(4000);

   -- V_RTN_CLOB       CLOB;
   -- V_RTN_CURSOR     SYS_REFCURSOR;
   -- V_ERROR          CLOB;

    -- JSON을 위한 변수선언 영역
    v_json         json_object_t;
    v_arr_list     json_array_t;
    v_arr_head     json_array_t;
    v_obj          json_object_t;

    -- 세션값 처리용 변수선언 영역
    v_sql          CLOB;
    v_run_sql      VARCHAR2(1);
    v_range_sql    VARCHAR2(4000);
    v_debug        VARCHAR2(1);
    v_out_sql      VARCHAR2(4000);

    -- 세션값 처리용 변수선언 영역
    v_plt_cd       VARCHAR2(2);
    v_sess_user_id VARCHAR2(20);

    -- 조건절 처리용 변수선언 영역
    v_werks        tb_sch008.werks%TYPE;		--플랜트
    v_machine      tb_sch008.machine%TYPE;     --생산호기
    v_proc_cd      VARCHAR2(20);               --공정코드
    v_prd_str_dt   VARCHAR2(14);                --생산시작일    
    v_prd_end_dt   VARCHAR2(14);                --생산완료일    
    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역
    v_vbeln        VARCHAR2(14);

BEGIN
    OPEN p_rs_list FOR SELECT
                           NULL
                       FROM
                           dual
                       WHERE
                           ROWNUM = 0;

    v_debug := 'N';
    v_run_sql := 'N';
    v_json := json_object_t.parse(p_json_str);
    v_sess_user_id := v_json.get_string('SES_USER_ID');
    v_plt_cd := v_json.get_string('SES_PLNTKY');

   /* 조건값 할당 */
    v_werks := v_json.get_string('WERKS');	    --플랜트
    v_machine := v_json.get_string('MACHINE');      --생산호기
    v_range_sql := v_json.get_string('RANGE_SQL');   	--자재코드, 생산요청일자, 지시생성일자

    v_proc_cd := v_json.get_string('PROC_CD');		--공정코드
    v_out_sql := v_json.get_string('OUT_SQL');      --생산일자 

    v_vbeln := v_json.get_string('VBELN');        --판매문서 

    SELECT
        substr(v_out_sql, 1,(instr(v_out_sql, ',', 1) - 1))
        || '000000',
        substr(v_out_sql,(instr(v_out_sql, ',', 1) + 1))
        || '235959'
    INTO
        v_prd_str_dt,
        v_prd_end_dt
    FROM
        dual;

    IF p_type = 'LIST' THEN /*상단 조회 리스트*/
        --20220923 여한진 HL 쪽 실적 조회 쿼리 추가
        IF V_WERKS = 'P100' THEN
            v_sql := '  SELECT WRK_ORDR.WERKS                  WERKS                    --플랜트코드
                             , MAS002.PLANTNM                  PLANTNM                  --플랜트명   
                             , MAS013.PROC_CD                  PROC_CD                  --공정코드     
                             , MAS013.PROC_NM                  PROC_NM                  --공정명    
                             , MAS012.MACH_CD                  MACH_CD                  --설비코드       
                             , MAS012.MACH_NM                  MACH_NM                  --설비명  
                             , DECODE(SUBSTR(WRK_ORDR.WRK_ORDR_NO,1,4), ''WOEX'', ''예외생산'', WRK002.MACHINE)   MACHINE                    --생산호기
                             , WRK_ORDR.WRK_ORDR_NO            WRK_ORDR_NO              --작업지시번호  
                             , WRK_ORDR.WRK_ORDR_SEQNO         WRK_ORDR_SEQNO           --작업지시순번  
                             , WRK_ORDR.MATNR                  MATNR                    --품목코드        
                             , WRK_ORDR.MATNR_NM               MATNR_NM                 --품목코드명    
                             , SUBSTR(WRK_ORDR.MATNR, 10, 4) || ''*'' || SUBSTR(WRK_ORDR.MATNR, 14, 4)   SPEC1                    --규격            
                             , WRK002.VBELN                     VBELN                                
                             , WRK_ORDR.UNIT                   PLN_UNIT                 --계획단위           
                             , WRK_ORDR.ORDR_QTY            WRK_ORDR_QTY             --계획량        
                             , WRK002.UNIT                     PRFM_UNIT                --실적단위           
                             , SUM(NVL(WRK002.PRFM_QTY, 0))       PRFM_QTY                 --실적량       
                             , (SUM(NVL(FN_CHG_UNIT(WRK_ORDR.MATNR, WRK_ORDR.WERKS, WRK002.UNIT, WRK_ORDR.UNIT, WRK002.PRFM_QTY), 1)) / WRK_ORDR.ORDR_QTY) * 100        ACH_RATE                --달성율    
                          FROM V_WRK_ORDR  WRK_ORDR  --작업지시뷰
                             , TB_MAS012   MAS012    --설비 마스터
                             , TB_MAS013   MAS013    --공정 마스터
                             , TB_MAS002   MAS002  	 --플랜트 마스터	
                             , TB_WRK002   WRK002    --PS실적
                             , TB_MAS001   MAS001
                         WHERE WRK_ORDR.WERKS   = MAS002.WERKS(+)
                           AND WRK_ORDR.WRK_ORDR_NO =   WRK002.WRK_ORDR_NO (+)
                           AND WRK_ORDR.WRK_ORDR_SEQNO =  WRK002.WRK_ORDR_SEQNO(+)
                           AND NVL(WRK002.CNL_YN, ''N'') = ''N''
                           AND WRK002.WRK_ORDR_NO IS NOT NULL
                           AND WRK002.MACH_CD = MAS012.MACH_CD(+)
                           AND MAS012.PROC_CD   = MAS013.PROC_CD(+)	  
                           AND WRK_ORDR.WERKS   = MAS001.WERKS(+)
                           AND WRK_ORDR.MATNR   = MAS001.MATNR(+) ';
        ELSE                   
            v_sql := '  SELECT WRK_ORDR.WERKS                  WERKS                    --플랜트코드
                             , MAS002.PLANTNM                  PLANTNM                  --플랜트명   
                             , MAS013.PROC_CD                  PROC_CD                  --공정코드     
                             , MAS013.PROC_NM                  PROC_NM                  --공정명    
                             , MAS012.MACH_CD                  MACH_CD                  --설비코드       
                             , MAS012.MACH_NM                  MACH_NM                  --설비명  
                             , MAS012.MACHINE                  MACHINE                    --생산호기
                             , WRK_ORDR.WRK_ORDR_NO            WRK_ORDR_NO              --작업지시번호  
                             , WRK_ORDR.WRK_ORDR_SEQNO         WRK_ORDR_SEQNO           --작업지시순번  
                             , WRK_ORDR.MATNR                  MATNR                    --품목코드        
                             , WRK_ORDR.MATNR_NM               MATNR_NM                 --품목코드명    
                             , MAS001.MATNR_SPEC               SPEC1                    --규격            
                             , ''''                            VBELN                                
                             , WRK_ORDR.UNIT                   PLN_UNIT                 --계획단위           
                             , WRK_ORDR.ORDR_QTY                WRK_ORDR_QTY             --계획량        
                             , WRK001.UNIT                     PRFM_UNIT                --실적단위           
                             , SUM(NVL(WRK001.PRFM_QTY,0))       PRFM_QTY                 --실적량       
                             , (SUM(NVL(WRK001.PRFM_QTY, 0))/WRK_ORDR.ORDR_QTY) * 100    ACH_RATE                --달성율    
                          FROM V_WRK_ORDR  WRK_ORDR  --작업지시뷰
                             , TB_MAS012   MAS012    --설비 마스터
                             , TB_MAS013   MAS013    --공정 마스터
                             , TB_MAS002   MAS002  	 --플랜트 마스터
                             , TB_WRK001   WRK001    --HL실적
                             , TB_MAS001   MAS001
                         WHERE WRK_ORDR.WERKS   = MAS002.WERKS(+)
                           AND WRK_ORDR.WRK_ORDR_NO = WRK001.WRK_ORDR_NO(+)
                           AND WRK_ORDR.WRK_ORDR_SEQNO = WRK001.WRK_ORDR_SEQNO(+)
                           AND NVL(WRK001.CNL_YN, ''N'') = ''N''
                           AND WRK001.WRK_ORDR_NO IS NOT NULL
                           AND WRK001.MACH_CD = MAS012.MACH_CD(+)
                           AND MAS012.PROC_CD   = MAS013.PROC_CD(+)	  
                           AND WRK_ORDR.WERKS   = MAS001.WERKS(+)
                           AND WRK_ORDR.MATNR   = MAS001.MATNR(+) ';
        END IF;       
        
        IF v_werks IS NOT NULL OR trim(v_werks) != '' THEN
            v_sql := v_sql
                     || ' AND WRK_ORDR.WERKS = '''
                     || v_werks
                     || '''';				   --플랜트   
        END IF;

        IF v_machine IS NOT NULL OR trim(v_machine) != '' THEN
            v_sql := v_sql
                     || ' AND WRK_ORDR.MACHINE = '''
                     || v_machine
                     || '''';			   --생산호기
        END IF;

        IF v_proc_cd IS NOT NULL OR trim(v_proc_cd) != '' THEN
            v_sql := v_sql
                     || ' AND MAS012.PROC_CD = '''
                     || v_proc_cd
                     || '''';			   --공정코드
        END IF;
    
        IF v_vbeln IS NOT NULL OR trim(v_vbeln) != '' THEN
            v_sql := v_sql
                     || ' AND WRK002.VBELN = '''
                     || v_vbeln
                     || '''';			  
        END IF;

        IF v_out_sql IS NOT NULL OR trim(v_out_sql) != '' THEN
            v_sql := v_sql
                     || ' AND (    (WRK_ORDR.PRD_STR_DTM BETWEEN '''
                     || v_prd_str_dt
                     || '''  AND '''
                     || v_prd_end_dt
                     || '''  ) ';			   --생산일
            v_sql := v_sql
                     || '      OR (WRK_ORDR.PRD_END_DTM BETWEEN '''
                     || v_prd_str_dt
                     || '''  AND '''
                     || v_prd_end_dt
                     || '''  )) ';			   --생산일
        END IF;
        IF V_WERKS = 'P100' THEN
            v_sql := v_sql || ' GROUP BY WRK_ORDR.WERKS, MAS002.PLANTNM, MAS013.PROC_CD, MAS013.PROC_NM, MAS012.MACH_CD, MAS012.MACH_NM, WRK002.MACHINE, WRK_ORDR.WRK_ORDR_NO, WRK_ORDR.WRK_ORDR_SEQNO         
                            , WRK_ORDR.MATNR, WRK_ORDR.MATNR_NM, TO_CHAR(MAS001.WLEN)||'' * ''||TO_CHAR(MAS001.VLEN), WRK_ORDR.UNIT, WRK_ORDR.ORDR_QTY, WRK002.UNIT, MAS001.MATNR_SPEC, WRK002.VBELN ';
        ELSE
            v_sql := v_sql || ' GROUP BY WRK_ORDR.WERKS, MAS002.PLANTNM, MAS013.PROC_CD, MAS013.PROC_NM, MAS012.MACH_CD, MAS012.MACH_NM, MAS012.MACHINE, WRK_ORDR.WRK_ORDR_NO, WRK_ORDR.WRK_ORDR_SEQNO         
                            , WRK_ORDR.MATNR, WRK_ORDR.MATNR_NM, MAS001.MATNR_SPEC, WRK_ORDR.UNIT, WRK_ORDR.ORDR_QTY, WRK001.UNIT ';
        END IF;                    

        v_sql := v_sql || ' ORDER BY WRK_ORDR.WRK_ORDR_NO ,WRK_ORDR.WRK_ORDR_SEQNO ';
        IF ( v_debug = 'Y' ) THEN
            INSERT INTO proc_log ( sql_str ) VALUES ( v_sql );

        END IF;

        OPEN p_rs_list FOR v_sql;

    ELSIF p_type = 'SAVE' THEN
        RETURN;
    END IF;

    p_success := 'Y';
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
        raise_application_error(e_sql_err_cd, e_sql_err_msg);
END;

/
