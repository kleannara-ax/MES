package project.mes.controller;

import java.security.PrivateKey;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import project.common.util.ShaUtil;

import project.common.util.RSA;

import project.common.bean.CommonConfig;
import project.common.bean.DataMap;
import project.common.bean.SystemConfig;
import project.common.controller.BaseController;
import project.common.airfw.User;
import project.common.service.CommonService;
import project.mes.service.SsoGwService;
import project.mes.util.CommonUtil;
import project.mes.util.PropertiesUtil;


@Controller
public class MesLoginController extends BaseController {

	static final Logger log = LogManager.getLogger(MesLoginController.class.getName());

	@Autowired
	private CommonService commonService;
	
	@Autowired
	private SystemConfig systemConfig;

	@Autowired
	private SsoGwService ssoGwService;

	@Resource
	private PropertiesUtil propertiesUtil;

	@RequestMapping("/mes/json/login.*")
	public String login(HttpSession session, HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		logout(session, request, model);

		map.setModuleCommand(systemConfig.getCmmonType(), "USERCHECK");

		String encPw = map.getString("PASSWD");
		String plntky = map.getString("PLNTKY");// 플랜트
		String decPw = null;
		String ipReqGubun = "";					//기존IP값이 있는지 체크 같으면 true 다르면 false

		try {
			decPw = RSA.decryptRsa((PrivateKey) request.getSession().getAttribute("__rsaPrivateKey__"), encPw);
			ipReqGubun = (String)request.getSession().getAttribute(CommonConfig.SES_USER_IP_GUBUN);					//기존IP값이 있는지 체크 같으면 true 다르면 false
		} catch (Exception e1) {
			log.error(e1.getMessage());
			e1.printStackTrace();
			model.put("data", "P");
			return JSON_VIEW;
		}

		String userId = map.getString("USERID");
		boolean isEpUser = false;

		if("Y".equals(propertiesUtil.getPropertyValue("ssoLoginUseyn"))) {
			isEpUser=ssoGwService.isSsoEpUser(userId,decPw);
		}

		String password = "";
		String ipreq = "";		//접속IP
		try {
			password = ShaUtil.toSha256String(decPw);
			ipreq = CommonUtil.getIpAddr(request);//InetAddress.getLocalHost().getHostAddress();	//접속IP
			map.put("IPREQ", ipreq);								//접속IP
		} catch (Exception e) {
			password = "";
		}
		map.put("PASSWD", password);

		User user = (User) commonService.getObj(map);

		if (user != null) {

			if (isEpUser == false && !user.getPassword().equals(map.getString("PASSWD"))) {
				model.put("data", "N");

				return JSON_VIEW;
			}

			commonService.update(systemConfig.getCmmonType()+".LOGIN", map);
						
			map.setModuleCommand("Common", "SYSGRIDCOL");
			map.put(CommonConfig.SES_USER_ID_KEY, user.getUserid());
			List<DataMap> list = commonService.getList(map);
			DataMap usrlo = new DataMap();
			DataMap row;
			//List data;
			String progid;
			for (int i = 0; i < list.size(); i++) {
				row = list.get(i);
				progid = row.getString("PROGID");
				if (usrlo.containsKey(progid)) {
					//data = usrlo.getList(progid);
					//data.add(row);
				} else {
					List newData = new ArrayList();
					newData.add(row);
					usrlo.put(progid, newData);
				}
			}

			user.setUsrlo(usrlo);
			
			session.setAttribute(CommonConfig.SES_MENU_GROUP_KEY, user.getMenugid());			
			session.setAttribute(CommonConfig.SES_USER_OBJECT_KEY, user);
			session.setAttribute(CommonConfig.SES_USER_ID_KEY, user.getUserid());
			session.setAttribute(CommonConfig.SES_USER_NAME_KEY, user.getUsername());
			session.setAttribute(CommonConfig.SES_USER_COMPANY_KEY, user.getCompid());
			session.setAttribute(CommonConfig.SES_USER_LANGUAGE_KEY, map.getString("LANGKY"));
			session.setAttribute(CommonConfig.SES_USER_THEME_KEY, CommonConfig.SYSTEM_THEME_PATH);
			session.setAttribute(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.getString("WAREKY"));
			session.setAttribute(CommonConfig.SES_USER_PLANT_KEY, plntky);
			session.setAttribute(CommonConfig.SES_UROLKY, user.getUrolky());			//사용자 권한키 1.조회 2.조회+저장 3.ALL
			session.setAttribute(CommonConfig.SES_USER_IP_KEY, user.getIpReq());		//기존 IP 가져오기

			// 2022-05-09(월요일)-안상현, 부서명(국문) 추가
			session.setAttribute(CommonConfig.SES_DEPT_NM_KEY, user.getDept_kr_nm());
			
			// 2022-07-15(목요일) 안상현, 작업반 추가
			session.setAttribute(CommonConfig.SES_WRK_CLASS, user.getWrk_class());
			
			String schema = "public";
			if(!"WDSCM".equals(user.getCompid())){
				schema = user.getCompid().toLowerCase();
			}
			session.setAttribute(CommonConfig.SES_SCHEMA, schema);
			
			// menu list
			map.put("LANGKY", map.getString("LANGKY"));
			map.put("USERID", user.getUserid());
			map.put("MENUGID", user.getMenugid());
			map.put("COMPID", user.getCompid());

			list = commonService.getList("Common.MENUTREE", map);

			session.setAttribute(CommonConfig.SES_USER_MENU_KEY, list);

			DataMap urlMap = new DataMap();
			String tmpUrl;
			for (int i = 0; i < list.size(); i++) {
				row = list.get(i);
				tmpUrl = row.getString("PGPATH");
				if (tmpUrl.trim().length() != 0) {
					if (tmpUrl.substring(0, 2).equals("./")) {
						tmpUrl = tmpUrl.substring(1);
					}
					if (tmpUrl.substring(tmpUrl.length() - 3).equals("jsp")) {
						tmpUrl = tmpUrl.substring(0, tmpUrl.length() - 3) + "page";
					}
					urlMap.put(tmpUrl, true);
				}
			}
			urlMap.put("/common/main.page", true);
			urlMap.put("/common/left.page", true);
			urlMap.put("/common/top.page", true);
			urlMap.put("/common/wintab.page", true);
			urlMap.put("/common/info.page", true);
			session.setAttribute(CommonConfig.SES_USER_URL_KEY, urlMap);
			model.put("data", "S");
			map.put("SES_USER_IP", request.getRemoteAddr());
			map.setModuleCommand("System", "LOGIN_LOG");
			
			int count = commonService.getCount(map);
			
			if(count == 0) {
				//20230215 여한진 로그인 이력이 없으면
				commonService.insert(map);
			}else {
				//20230215 여한진 로그인 이력이 있으면
				commonService.update(map);
			}

			log.debug(user);
		} else {
			model.put("data", "N");
		}

		return JSON_VIEW;
	}

	@RequestMapping("/mes/json/logout.*")
	public String logout(HttpSession session, HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		if(session.getAttribute(CommonConfig.SES_USER_ID_KEY) != null){
			String userid = session.getAttribute(CommonConfig.SES_USER_ID_KEY).toString();
			
			session.removeAttribute(CommonConfig.SES_USER_OBJECT_KEY);
			session.removeAttribute(CommonConfig.SES_USER_ID_KEY);
			session.removeAttribute(CommonConfig.SES_USER_NAME_KEY);
			session.removeAttribute(CommonConfig.SES_USER_COMPANY_KEY);
			session.removeAttribute(CommonConfig.SES_DEPT_ID_KEY);
			session.removeAttribute(CommonConfig.SES_USER_INFO_KEY);
			session.removeAttribute(CommonConfig.SES_USER_MENU_KEY);
			
			map.setModuleCommand(systemConfig.getCmmonType(), "LOGOUT");
			commonService.update(map);
			map.put("SES_USER_IP", request.getRemoteAddr());
			
			map.setModuleCommand("System", "LOGOUT_LOG");
			commonService.insert(map);
		}
		return "/index";
	}
}