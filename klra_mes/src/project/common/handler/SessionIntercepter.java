package project.common.handler;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import project.common.bean.CommonConfig;
import project.common.bean.DataMap;
import project.common.bean.UriInfo;
import project.common.bean.BaseUser;
import project.common.exception.MobileSessionEmptyException;
import project.common.exception.SessionEmptyException;
import project.common.service.CommonService;
import project.mes.util.CommonUtil;
import project.mes.util.PropertiesUtil;

public class SessionIntercepter extends HandlerInterceptorAdapter {
	static final Logger log = LogManager.getLogger(SessionIntercepter.class.getName());

	@Autowired
	private CommonService commonService;

	@Resource
	private PropertiesUtil propertiesUtil;

	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
		DataMap params = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		UriInfo uriInfo = (UriInfo)request.getAttribute(CommonConfig.REQUEST_URI_INFO_KEY);
		
		DataMap urlMap = (DataMap)request.getSession().getAttribute(CommonConfig.SES_USER_URL_KEY);
		
		String userType = "";
		
		Object SES_USER_ID = request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY);
		String sesUserId = (SES_USER_ID == null?null:SES_USER_ID.toString());

		String memApplyCode = request.getSession().getAttribute(CommonConfig.MEMBERSHIP_APPLY_CODE) == null?
										null:request.getSession().getAttribute(CommonConfig.MEMBERSHIP_APPLY_CODE).toString();
		
		//2020.12.09 이범준
		String pdaModule = uriInfo.getUri()!=null&&!"".equals(uriInfo.getUri().trim())&&uriInfo.getUri().indexOf("/") > -1?uriInfo.getUri().split("/")[1]:"";
		boolean isPda = "pda".equals(pdaModule)?true:false;
		
		/*
		String sesUserId = null;
		if(commonUser != null){
			sesUserId = commonUser.getUserId(request.getSession());
		}
		*/
		
		String sesWareky = null;
		String sesWarenm = null;
		String sesCompky = null;
		String sesLang = null;
		String sesUserExpId = null;
		String sesSchema = request.getSession().getAttribute(CommonConfig.SES_SCHEMA) == null?"":request.getSession().getAttribute(CommonConfig.SES_SCHEMA).toString();
		DataMap userInfo = null;
		
		String newIpReq 		= null;		//새로운 IP		
		String oldIpReq 		= null;		//기존IP
		String ipReqGubun 		= null;		//ip true,false

		// 개발만
//		if(sesUserId == null) {
//			sesUserId = "hnw.shyou";
//			ssoGwService.ssoLogin(sesUserId, request,new ModelMap());
//		}
		if(sesUserId == null || sesUserId.equals("")){
			//UriInfo uriInfo = new UriInfo(request.getRequestURL().toString(), request.getRequestURI());	
			if(uriInfo.getDataType().equals("xml")
					|| uriInfo.getUri().equals("/common/Common/list/json/COMCOMBO.data")
					|| uriInfo.getUri().equals("/common/Common/list/json/PARTCOMBO.data")
					|| uriInfo.getUri().equals("/common/api/json/restfulResponse.data")
					|| uriInfo.getUri().equals("/common/image/fileUp/mobile.data")
					|| uriInfo.getUri().equals("/system/json/authMemberShip.data")
					|| uriInfo.getUri().equals("/system/json/selectOptionSetData.data")
					|| uriInfo.getUri().equals("/system/json/selectPriceData.data")
					|| uriInfo.getUri().equals("/common/json/idPsFind.data")
					|| uriInfo.getUri().indexOf("mb") != -1
					|| uriInfo.getUri().equals("/app/image/fileUp/json.data")
					|| uriInfo.getUri().indexOf("/api") != -1 
					|| uriInfo.getUri().indexOf("password") != -1
					|| uriInfo.getUri().indexOf("pop") != -1 
					|| uriInfo.getUri().indexOf("login") != -1
					// mobile
					|| uriInfo.getUri().indexOf("/mobile/index.page") != -1
					|| uriInfo.getUri().indexOf("/common/Mobile/list/json/STLMA.data") != -1
					|| uriInfo.getUri().indexOf("/mobile/json/login.data") != -1
					|| uriInfo.getUri().indexOf("/mobile/plant/list.data") != -1
					|| uriInfo.getUri().indexOf("/mobile/error") != -1
					|| uriInfo.getUri().indexOf("/mobile/saveDustInspectionResult") != -1
					// sso
					|| uriInfo.getUri().indexOf("/sso") != -1
					// rfc
					|| uriInfo.getUri().indexOf("/rfc") != -1
					//
					|| uriInfo.getUri().indexOf(".ndo") != -1		// sms발송 관련 to마감을 위해 web.xml내용 추가분
					|| uriInfo.getUri().indexOf("index") != -1){
				sesUserId = request.getRemoteAddr();
			}else{
				//sesUserId = request.getRemoteAddr();
				
				//2020.12.09 이범준
				if(isPda) {
					if(uriInfo.getUri().equals("/mobile/json/appDownList.data")
							|| uriInfo.getUri().equals("/mobile/icon/view.data")
							|| uriInfo.getUri().equals("/mobile/apk/fileDown/file.data")) {
						sesUserId = request.getRemoteAddr();
					}else {
						throw new MobileSessionEmptyException();
					}
				}else{
					if(memApplyCode == null){
						throw new SessionEmptyException();
					}
				}
			}
		//}else if(urlMap != null && !urlMap.containsKey(uriInfo.getUri()) && uriInfo.getExt().equals("page") && !uriInfo.getWorkType().equals("demo") && !uriInfo.getWorkType().equals("theme") && !uriInfo.getDataType().equals("aprove") && !uriInfo.getCommand().equals("searchHelp") && !uriInfo.getUris()[1].equals("aprove")){
		//	throw new Exception("page open exception");
		}else{			
			sesCompky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_COMPANY_KEY);
			sesWareky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_WHAREHOUSE_KEY);
			sesWarenm = (String)request.getSession().getAttribute(CommonConfig.SES_USER_WHAREHOUSE_NM_KEY);
			sesLang = (String)request.getSession().getAttribute(CommonConfig.SES_USER_LANGUAGE_KEY);			
			userInfo = (DataMap)request.getSession().getAttribute(CommonConfig.SES_USER_INFO_KEY);
			
			//UriInfo uriInfo = (UriInfo)request.getAttribute(CommonConfig.REQUEST_URI_INFO_KEY);
			if(uriInfo.getExt().equals("page")){
				BaseUser user = (BaseUser)request.getSession().getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
				if(user.getUsrlo().containsKey(uriInfo.getMenuId())){
					request.setAttribute(CommonConfig.SES_USER_LAYOUT_LIST_KEY, user.getUsrlo().getList(uriInfo.getMenuId()));
				}
				/*
				if(user.getUsrph().containsKey(uriInfo.getMenuId())){
					request.setAttribute(CommonConfig.SES_USER_SEARCHPARAM_LIST_KEY, user.getUsrph().getList(uriInfo.getMenuId()));
					request.setAttribute(CommonConfig.SES_USER_SEARCHPARAM_DEFAULT_KEY, user.getUsrpi().getList(uriInfo.getMenuId()));
				}
				*/
			}

			this.checkSessionDup(request, sesUserId);

		}
		

		log.info(CommonConfig.SES_USER_ID_KEY+" : "+sesUserId);
		
		params.put(CommonConfig.SES_USER_TYPE_KEY, userType);
		
		params.put(CommonConfig.SES_USER_ID_KEY, sesUserId);
		params.put(CommonConfig.SES_USER_COMPANY_KEY, sesCompky);
		params.put(CommonConfig.SES_USER_LANGUAGE_KEY, sesLang);		
		params.put(CommonConfig.SES_USER_INFO_KEY, userInfo);		
		params.put(CommonConfig.SES_USER_IP_KEY, 	newIpReq);					//ip		
		params.put(CommonConfig.SES_USER_IP_GUBUN, 	ipReqGubun);				//기존IP값이 있는지 체크 같으면 true 다르면 false		
		params.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, sesWareky);
		params.put(CommonConfig.SES_USER_WHAREHOUSE_NM_KEY, sesWarenm);

		params.put(CommonConfig.SES_USER_PLANT_KEY, request.getSession().getAttribute(CommonConfig.SES_USER_PLANT_KEY)); //플랜트
		params.put(CommonConfig.SES_PROC_CD, request.getSession().getAttribute(CommonConfig.SES_PROC_CD)); //공정
		params.put(CommonConfig.SES_MACH_CD, request.getSession().getAttribute(CommonConfig.SES_MACH_CD)); // 설비

		if(sesUserExpId == null){
			sesUserExpId = "";
		}
		
		params.put(CommonConfig.SES_USER_EMPL_ID_KEY, sesUserExpId);
		
		if("".equals(sesSchema)){
			if(!"WDSCM".equals(sesCompky) && sesCompky != null){
				sesSchema = sesCompky.toLowerCase();
			}else{
				sesSchema = "public";
			}
		}
		
		params.put(CommonConfig.SES_SCHEMA, sesSchema);
		
		request.setAttribute(CommonConfig.PARAM_ATT_KEY, params);
		
		return super.preHandle(request, response, handler);
	}

	// 중복로그인 체크
	private void checkSessionDup(HttpServletRequest req, String sessUserId) throws Exception {
		if(StringUtils.isEmpty(sessUserId)) return ;

		String newIpReq = CommonUtil.getIpAddr(req);                            //새로운 IP
		DataMap dupMap= new DataMap();
//		dupMap.put("CMCDKY", "SESS_DUP");
//		dupMap.put("CMCDVL", "DUP_YN");
//		dupMap.setModuleCommand("mes", "CDDTL");
//		DataMap resMap = commonService.getMap(dupMap);
//		if(resMap!=null && resMap.getString("CDESC1")  != null && !"Y".equals(resMap.getString("CDESC1"))){
		DataMap resMap = new DataMap();
		// if("Y".equals(CommonConfig.sessionDupUseyn)){
		if("Y".equals(propertiesUtil.getPropertyValue("sessionDupUseyn"))){
			dupMap.setModuleCommand("mes", "LOGINDUP");
			dupMap.put("sessUserId", sessUserId);
			resMap = commonService.getMap(dupMap);
			if(resMap ==null)	 return ;
			String oldIpReq = resMap.getString("IPREQ");
			if(!StringUtils.isEmpty(oldIpReq) && !newIpReq.equals(oldIpReq)) {
				req.getSession().invalidate();
				throw new Exception("Session Dup");
			//			throw new SessionEmptyException();
			}
		}

	}
}