package project.common.handler;

import java.io.BufferedReader;
import java.io.UnsupportedEncodingException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import project.common.bean.CommonConfig;
import project.common.bean.DataMap;
import project.common.bean.UriInfo;
import project.common.service.CommonService;
import project.common.util.SqlUtil;

public class CommonIntercepter extends HandlerInterceptorAdapter{
	
	static final Logger log = LogManager.getLogger(CommonIntercepter.class.getName());
	
	private DataMap operMap;
	
	@Autowired
	private CommonService commonService;
	
	public CommonIntercepter(){
		super();
		this.operMap = new DataMap();
		this.operMap.put("E", "=");
		this.operMap.put("N", "!=");
		this.operMap.put("LT", "<");
		this.operMap.put("GT", ">");
		this.operMap.put("LE", "<=");
		this.operMap.put("GE", ">=");
	}
	
	
	// 컨트롤러를 호출하기전에 실행
	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
		// TODO Auto-generated method stub	
		DataMap params = null;		
		
		UriInfo uriInfo = new UriInfo(request.getRequestURL().toString(), request.getRequestURI());

		String json = null;
		
		if(uriInfo.getDataType().equals("json")){
			try {
				// readJSONStringFromRequestBody : request로 받은 JSON객체를 STRING으로 치환
				json = readJSONStringFromRequestBody(request);
				if(json != null && !json.equals("")){
					JSONObject jsonObject = new JSONObject(json);	    
					params = getMap(jsonObject);
				}
			}catch(Exception e) {
		        e.printStackTrace();
			}finally{
				if(params == null){
					params = new DataMap();
				}
			}
			
			SqlUtil sqlUtil = new SqlUtil();
			sqlUtil.setRangeSql(params);
		}else if(uriInfo.getDataType().equals("excel")){
			params = new DataMap(request);
			String key = params.getString(CommonConfig.DATA_EXCEL_REQUEST_KEY);
			params = (DataMap)request.getSession().getAttribute(key);
		}else{
			params = new DataMap(request);
			if(uriInfo.getExt().equals("page")){
				uriInfo.setParam(params);
			}
			if(!params.containsKey(CommonConfig.MENU_ID_KEY)){
				params.put(CommonConfig.MENU_ID_KEY, uriInfo.getCommand());
			}
		}
		// CommonConfig.PARAM_ATT_KEY : ParamData
		// JSON 데이터를 Request 객체에 ParamData 이름으로 저장 
		request.setAttribute(CommonConfig.PARAM_ATT_KEY, params);
		
		uriInfo.setParams(params.toString());
		
		request.setAttribute(CommonConfig.REQUEST_URI_INFO_KEY, uriInfo);
		
		//writeLog(request, uriInfo, json);
		return super.preHandle(request, response, handler);
	}
	
	public String readJSONStringFromRequestBody(HttpServletRequest request) {
		StringBuffer json = new StringBuffer();
		String line = null;
		try {
			BufferedReader reader = request.getReader();
			while ((line = reader.readLine()) != null) {
				json.append(line);
			}
		} catch (Exception e) {
			log.error("Error reading JSON string", e);
		}
		return json.toString();
	}
	
	public DataMap getMap(JSONObject json) {
		DataMap paramMap = new DataMap();
		Iterator it = json.keys();
		while (it.hasNext()) {
			String key = (String) it.next();
			if (json.isNull(key)) {
				continue;
			}
			try {
				Object obj = json.get(key);
				if(obj instanceof JSONObject){
					JSONObject jObject = (JSONObject)obj;
					paramMap.put(key, getMap(jObject));
				}else if(obj instanceof ArrayList){
					paramMap.put(key, obj);
				}else if(obj instanceof JSONArray){
					JSONArray array = (JSONArray)obj;
					List list = new ArrayList();
					Object tmpObj;
					for(int i=0;i<array.length();i++){
						tmpObj = array.get(i);
						if(tmpObj instanceof JSONObject){
							list.add(getMap(array.getJSONObject(i)));
						}else{
							list.add(tmpObj);
						}						
					}
					
					paramMap.put(key, list);
				}else{
					paramMap.put(key, obj);
				}
			} catch (Exception e) {
				log.error("Error mapping JSON map", e);
			}
		}
		return paramMap;
	}
	
	private void writeLog(HttpServletRequest request, UriInfo uriInfo, String jsonStr) throws UnsupportedEncodingException, SQLException{
		DataMap param = new DataMap();
		param.put("IP", getClientIP(request));
		param.put("URITYPE", uriInfo.getExt());
		param.put("URL", request.getRequestURL().toString());
		param.put("URI", uriInfo.getUri());
		String pStr = request.getRequestURL().toString();
		if(pStr.indexOf("?") != -1){
			param.put("PARAM", pStr.substring(pStr.indexOf("?")+1));
		}
		
		if(uriInfo.getDataType().equals("json")){
			if(jsonStr != null && jsonStr.getBytes("UTF-8").length > 4000){
				//jsonStr = jsonStr.substring(0, 1300);
				jsonStr = new String(jsonStr.getBytes("UTF-8"), 0, 3990);
			}
			if(jsonStr != null && !jsonStr.equals("") && jsonStr.length() > 1300){
				jsonStr = jsonStr.substring(0, 1300);
			}
			param.put("DATA", jsonStr);
		}
		
		Object SES_USER_ID = request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY);
		if(SES_USER_ID != null){
			param.put("SES_USER_ID", SES_USER_ID);
		}
		
		commonService.insert("Common.SYSLOG", param);
	}
	
	private String getClientIP(HttpServletRequest request) {
	    String ip = request.getHeader("X-Forwarded-For");
	    log.info("> X-FORWARDED-FOR : " + ip);

	    if (ip == null) {
	        ip = request.getHeader("Proxy-Client-IP");
	        log.info("> Proxy-Client-IP : " + ip);
	    }
	    if (ip == null) {
	        ip = request.getHeader("WL-Proxy-Client-IP");
	        log.info(">  WL-Proxy-Client-IP : " + ip);
	    }
	    if (ip == null) {
	        ip = request.getHeader("HTTP_CLIENT_IP");
	        log.info("> HTTP_CLIENT_IP : " + ip);
	    }
	    if (ip == null) {
	        ip = request.getHeader("HTTP_X_FORWARDED_FOR");
	        log.info("> HTTP_X_FORWARDED_FOR : " + ip);
	    }
	    if (ip == null) {
	        ip = request.getRemoteAddr();
	        log.info("> getRemoteAddr : "+ip);
	    }
	    log.info("> Result : IP Address : "+ip);

	    return ip;
	}
	
	@Override
	public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {
		// TODO Auto-generated method stub
		super.postHandle(request, response, handler, modelAndView);
	}

	@Override
	public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
		// TODO Auto-generated method stub
		super.afterCompletion(request, response, handler, ex);
	}
}