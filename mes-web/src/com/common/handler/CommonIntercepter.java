package com.common.handler;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.input.SAXBuilder;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import com.common.bean.CommonConfig;
import com.common.bean.DataMap;
import com.common.bean.UriInfo;
import com.common.bean.XmlBean;
import com.common.util.SqlUtil;

public class CommonIntercepter extends HandlerInterceptorAdapter{
	
	private static Logger log = Logger.getLogger(CommonIntercepter.class);
	
	private DataMap operMap;
	
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
	 
	@Override
	public boolean preHandle(HttpServletRequest request,
			HttpServletResponse response, Object handler) throws Exception {
		// TODO Auto-generated method stub	
		DataMap params = null;		
		
		UriInfo uriInfo = new UriInfo(request.getRequestURL().toString(), request.getRequestURI());

		if(uriInfo.getDataType().equals("json")){
			try {
				String json = readJSONStringFromRequestBody(request);
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
			/*
			StringUtility sUtil = new StringUtility();
			params = new DataMap(request);
			DataMap paramMap = new DataMap(sUtil.getStringToMap(params.getString(CommonConfig.DATA_EXCEL_REQUEST_KEY)));
			params.putAll(paramMap);
			*/
			params = new DataMap(request);
			String key = params.getString(CommonConfig.DATA_EXCEL_REQUEST_KEY);
			params = (DataMap)request.getSession().getAttribute(key);
			//SqlUtil sqlUtil = new SqlUtil();
			//sqlUtil.setRangeSql(params);
			/*
			String json = request.getParameter(CommonConfig.DATA_EXCEL_REQUEST_KEY);
			try {
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
			*/
		}else if(uriInfo.getDataType().equals("xml")){
			params = new DataMap(request);
			XmlBean xmlBean = getXmlFromString(params.getString("xml"));
			params.put("xml", xmlBean);
		/*}else if(uriInfo.getDataType().equals("excel")){
			String paramData = request.getParameter(CommonConfig.DATA_EXCEL_REQUEST_KEY);
			String labelData = request.getParameter(CommonConfig.DATA_EXCEL_LABEL_KEY);
			String labelOrderData = request.getParameter(CommonConfig.DATA_EXCEL_LABEL_ORDER_KEY);
			JSONObject jsonObject = new JSONObject(paramData);
			params = getMap(jsonObject);
			jsonObject = new JSONObject(labelData);
			DataMap labelMap = getMap(jsonObject);
			jsonObject = new JSONObject(labelOrderData);
			DataMap labelOrderMap = getMap(jsonObject);
			String[] labelList = new String[labelOrderMap.size()];
			Iterator it = labelOrderMap.keySet().iterator();
			while(it.hasNext()){
				Object key = it.next();
				Object value = labelOrderMap.get(key);
				labelList[Integer.parseInt(key.toString())] = value.toString();
			}
		
			params.put(CommonConfig.DATA_EXCEL_LABEL_KEY, labelMap);
			params.put(CommonConfig.DATA_EXCEL_LABEL_ORDER_KEY, labelList);*/
		}else{
			params = new DataMap(request);
			if(uriInfo.getExt().equals("page")){
				uriInfo.setParam(params);
			}
			if(!params.containsKey(CommonConfig.MENU_ID_KEY)){
				params.put(CommonConfig.MENU_ID_KEY, uriInfo.getCommand());
			}
		}
		
		//params.put(CommonConfig.CUBE_REQUEST_URL, request.getRequestURL());
		//params.put(CommonConfig.CUBE_REQUEST_URI, request.getRequestURI());
	
		request.setAttribute(CommonConfig.PARAM_ATT_KEY, params);
		
		uriInfo.setParams(params.toString());
		
		request.setAttribute(CommonConfig.REQUEST_URI_INFO_KEY, uriInfo);
		
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

	public XmlBean getXmlFromString(String xml) throws JDOMException, IOException {
		log.debug(xml);

		XmlBean xmlBean = new XmlBean();
		Element rootNode = null;
		if(xml.length() > 0){
			SAXBuilder builder = new SAXBuilder();
			StringReader sb = new StringReader(xml);
			Document document = (Document) builder.build(sb);
			rootNode = document.getRootElement();
			
			xmlBean.setXml(rootNode);
			
			/*
			List list = rootNode.getChildren("staff");

			for (int i = 0; i < list.size(); i++) {

			   Element node = (Element) list.get(i);

			   System.out.println("First Name : " + node.getChildText("firstname"));
			   System.out.println("Last Name : " + node.getChildText("lastname"));
			   System.out.println("Nick Name : " + node.getChildText("nickname"));
			   System.out.println("Salary : " + node.getChildText("salary"));

			}
			*/
		}
		
		return xmlBean;
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
	
	@Override
	public void postHandle(HttpServletRequest request,
			HttpServletResponse response, Object handler,
			ModelAndView modelAndView) throws Exception {
		// TODO Auto-generated method stub
		super.postHandle(request, response, handler, modelAndView);
	}

	@Override
	public void afterCompletion(HttpServletRequest request,
			HttpServletResponse response, Object handler, Exception ex)
			throws Exception {
		// TODO Auto-generated method stub
		/*
		if(ex != null && ex instanceof SQLException){			
			String error = "{ERROR:'"+ex.getMessage().substring(0,ex.getMessage().indexOf("\n"))+"'}";
			response.getWriter().write(error.toCharArray());
			ex = null;
		}
		*/
		super.afterCompletion(request, response, handler, ex);
	}
}