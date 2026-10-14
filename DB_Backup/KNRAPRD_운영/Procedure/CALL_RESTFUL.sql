--------------------------------------------------------
--  DDL for Procedure CALL_RESTFUL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."CALL_RESTFUL" 
(
  P_IFID    IN  VARCHAR2,
  P_URL     IN  VARCHAR2,
  P_DOC_NO  IN  VARCHAR2, 
  P_RTN_MSG OUT VARCHAR2
)
IS
  req     UTL_HTTP.REQ;
  resp    UTL_HTTP.RESP;
  content VARCHAR2(4000);
  buffer  VARCHAR2(4000);

  res_text VARCHAR2(4000);
  V_SQL            CLOB; 

  -- 세션값 처리용 변수선언 영역
  V_PLT_CD         varchar2(2);
  V_SESS_USER_ID   varchar2(20);
  V_DOC_NO         varchar2(30);

  V_IF_GET_DATE    DATE;
  V_IF_SET_DATE    DATE;
  V_IF_ERR_MESS    VARCHAR2(1000);
  V_IF_MES_KEY     VARCHAR2(30);

BEGIN

--  DBMS_OUTPUT.ENABLE; 

  V_IF_GET_DATE := SYSDATE;

  req := UTL_HTTP.BEGIN_REQUEST (
    url    => 'http://wmsdev.kleannara.com:82/common/api/json/WMS_IF_209/send.data',
--    url    => 'https://wmsdev.kleannara.com:446/common/api/json/WMS_IF_209/send.data',
    method => 'POST'
  );

  V_DOC_NO := 'CPMES_IF_90122061714392328';

  content := ''
    || 'DOC_NO=' || v_doc_no || '' -- remember to escape special characters
    || '';

--  UTL_HTTP.SET_HEADER( req, 'content-type', 'application/json; charset=UTF-8' ); 
  UTL_HTTP.SET_HEADER( req, 'content-type', 'application/html; charset=UTF-8' ); 
  UTL_HTTP.SET_HEADER( req, 'us-agent', 'mozilia/4.0' ); 
  UTL_HTTP.SET_HEADER( req, 'Content-Length', length(content) );


  --TB_ITFFLDMAP

  UTL_HTTP.WRITE_TEXT( r => req, data => content );

  --UTL_HTTP.set_authentication(req, p_username, 'Klean@9290');

  resp := UTL_HTTP.GET_RESPONSE(req);

  dbms_output.put_line('Response Status Code: '||resp.status_code);

  dbms_output.put_line('Response Reason: '||resp.reason_phrase);

  dbms_output.put_line('Response Version: '||resp.http_version);

  dbms_output.put_line('---Header Count Starts---');

  BEGIN

    LOOP
      UTL_HTTP.READ_LINE( resp, res_text, TRUE );

    END LOOP;

  dbms_output.put_line('Response Message: ' || res_text);

    UTL_HTTP.END_RESPONSE(resp);

    --?응답 파일 contents 읽어옴 
--   if resp = '' then
--    sp_if_put_ifwm001()
--   end if;
--   

--            V_IF_SET_DATE := SYSDATE;
  --          V_IF_ERR_MESS := res_text;
            SP_PROC_ERROR('CP', 'V_PRG_NM', 02, res_text, 'V_SESS_USER_ID');
--    
  EXCEPTION
--??  WHEN OTHERS THEN
    WHEN UTL_HTTP.END_OF_BODY THEN

         UTL_HTTP.END_RESPONSE(resp);

         P_RTN_MSG := 'ERROR CODE: ' || TO_CHAR(resp.status_code) || ', '|| res_text;
         SP_PROC_ERROR('CP', 'V_PRG_NM', resp.status_code, res_text, 'V_SESS_USER_ID'); 


     --   RAISE_APPLICATION_ERROR (?-20100,????'IF_APPROVAL_PROC CALL ERROR'??|| CHR(10) || SQLERRM);???????? 
      --  DBMS_OUTPUT.PUT_LINE('HTTP_TEST ERROR MSG : ' || SQLERRM); 
    END; 
END;

/
