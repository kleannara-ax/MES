--------------------------------------------------------
--  DDL for Procedure SP_TEST_01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_TEST_01" (
    p_json_str IN CLOB
) AS

    v_prg_nm       VARCHAR2(100) := 'SP_TEST_01';     -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수선언 영역
    e_exception_user EXCEPTION;
    e_sql_err_cd   NUMBER(5) := 0;
    e_sql_err_msg  VARCHAR2(4000);

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

    -- 세션값 처리용 변수선언 영역
    v_plt_cd       VARCHAR2(2);
    v_sess_user_id VARCHAR2(20);
    v_name         VARCHAR2(20);
    v_fld1         integer;
    v_fld2         VARCHAR2(100);
BEGIN
    v_debug := 'N';
    v_run_sql := 'Y';
    v_json := json_object_t.parse(p_json_str);
    --v_fld1       :=       V_JSON.get_string('empno');
    --v_fld2       :=       V_JSON.get_string('ename');

    V_ARR_LIST        := V_JSON.get_array('Influencers');

    FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
      V_OBJ               := TREAT (V_ARR_LIST.get (i) AS json_object_t);
      V_OBJ               := TREAT (V_OBJ.get ('map') AS json_object_t);

      --v_fld2           := V_OBJ.get_string('NAME');

      --dbms_output.put_line(v_fld2);
    END LOOP;

END;


/
