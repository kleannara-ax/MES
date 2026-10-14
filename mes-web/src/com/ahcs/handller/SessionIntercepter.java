package com.ahcs.handller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import com.common.bean.CommonConfig;
import com.common.bean.DataMap;
import com.common.bean.UriInfo;
import com.common.service.CommonService;

public class SessionIntercepter extends HandlerInterceptorAdapter {
	private static Logger log = Logger.getLogger(SessionIntercepter.class);
	
	@Autowired
	private CommonService commonService;
 	
	@Override
	public boolean preHandle(HttpServletRequest request,
			HttpServletResponse response, Object handler) throws Exception {
		DataMap params = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		UriInfo uriInfo = (UriInfo)request.getAttribute(CommonConfig.REQUEST_URI_INFO_KEY);
		
		Object SES_USER_ID = request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY);
		String sesUserId = null;
		String sesWareky = null;
		String sesOwner = null;
		String sesCompky = null;
		String sesLang = null;
		String sesUserExpId = null;
		DataMap userInfo = null;
		if(SES_USER_ID == null || SES_USER_ID.toString().equals("")){
			//UriInfo uriInfo = new UriInfo(request.getRequestURL().toString(), request.getRequestURI());	
			if(uriInfo.getDataType().equals("xml")
					|| uriInfo.getUri().equals("/common/Common/list/json/COMCOMBO.data")
					|| uriInfo.getUri().equals("/common/Wms/list/json/WAHMACOMBO.data")
					|| uriInfo.getUri().indexOf("password") != -1 
					|| uriInfo.getUri().indexOf("login") != -1 
					|| uriInfo.getUri().indexOf("index") != -1){
				sesUserId = request.getRemoteAddr();
			}else{
				//throw new SessionEmptyException();
				sesUserId = request.getRemoteAddr();
			}
		}else{
			sesUserId = SES_USER_ID.toString();
			sesWareky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_WHAREHOUSE_KEY);
			sesOwner = (String)request.getSession().getAttribute(CommonConfig.SES_USER_OWNER_KEY);
			sesCompky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_COMPANY_KEY);
			sesLang = (String)request.getSession().getAttribute(CommonConfig.SES_USER_LANGUAGE_KEY);
			sesUserExpId = (String)request.getSession().getAttribute(CommonConfig.SES_USER_EMPL_ID_KEY);
			
			userInfo = (DataMap)request.getSession().getAttribute(CommonConfig.SES_USER_INFO_KEY);
			
			//UriInfo uriInfo = (UriInfo)request.getAttribute(CommonConfig.REQUEST_URI_INFO_KEY);
			/*
			if(uriInfo.getExt().equals("page")){
				User user = (User)request.getSession().getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
				if(user.getUsrlo().containsKey(uriInfo.getMenuId())){
					request.setAttribute(CommonConfig.SES_USER_LAYOUT_LIST_KEY, user.getUsrlo().getList(uriInfo.getMenuId()));
				}
				if(user.getUsrph().containsKey(uriInfo.getMenuId())){
					request.setAttribute(CommonConfig.SES_USER_SEARCHPARAM_LIST_KEY, user.getUsrph().getList(uriInfo.getMenuId()));
					request.setAttribute(CommonConfig.SES_USER_SEARCHPARAM_DEFAULT_KEY, user.getUsrpi().getList(uriInfo.getMenuId()));
				}
			}
			*/
		}
		
		log.info(CommonConfig.SES_USER_ID_KEY+" : "+sesUserId);
		
		params.put(CommonConfig.SES_USER_ID_KEY, sesUserId);
		params.put(CommonConfig.SES_USER_COMPANY_KEY, sesCompky);
		params.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, sesWareky);
		params.put(CommonConfig.SES_USER_OWNER_KEY, sesOwner);
		params.put(CommonConfig.SES_USER_LANGUAGE_KEY, sesLang);
		
		params.put(CommonConfig.SES_USER_INFO_KEY, userInfo);
		params.put(CommonConfig.SES_USER_IP_KEY, request.getRemoteAddr());
		
		if(sesUserExpId == null){
			sesUserExpId = "";
		}
		params.put(CommonConfig.SES_USER_EMPL_ID_KEY, sesUserExpId);
		
		params.put(CommonConfig.FORMAT_DATE_KEY, "YYYY/MM/DD");
		params.put(CommonConfig.FORMAT_TIME_KEY, "HH24:MI:SS");
		
		request.setAttribute(CommonConfig.PARAM_ATT_KEY, params);
		
		return super.preHandle(request, response, handler);
	}
}