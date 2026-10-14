
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."CALL_REST_FROM_PLSQL_WITH_PARAMS" 
(
p$call_url      in  varchar2, 
p$params        in  varchar2, 
p$response_text out varchar2
) aS
 
 l$request  utl_http.req;
 l$response utl_http.resp;
-- p$call_url varchar2(4000) := 'http://wmsdev.kleannara.com:82/common/api/json/WMS_IF_209/send.data'; --Change to suit yours
 l$buffer        varchar2(4000); 
-- p$response_text varchar2(4000);
-- p$params        varchar2(4000) := '{"companyname":"'||p$params||'"}'; -- Pass your parameter here  as JSON

 begin
 -- Setting up the request and response objects
  l$request := utl_http.begin_request(p$call_url, 'POST',' HTTP/1.1');
  utl_http.set_header(l$request, 'user-agent', 'mozilla/4.0'); 
  utl_http.set_header(l$request, 'Content-Type', 'application/json; charset=UTF-8'); 
  utl_http.set_header(l$request, 'Content-Length', length(p$params));
     -- Passing parameteres to GET call
  utl_http.write_text(l$request, p$params);
  -- Getting the response object
  l$response := utl_http.get_response(l$request);
  -- Reading the data from response object

  begin

    loop
        utl_http.read_line(l$response, l$buffer);  
        p$response_text := p$response_text || l$buffer;
    end loop;

    utl_http.end_response(l$response);

    exception
    when utl_http.end_of_body then

         utl_http.end_response(l$response);

  end;
  -- Print the l$response or do whatever you want to using Oracle SQL JSON functions

end;
/
