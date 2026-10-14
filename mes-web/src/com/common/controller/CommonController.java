package com.common.controller;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.security.PrivateKey;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.UUID;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.common.bean.CommonConfig;
import com.common.bean.CommonLabel;
import com.common.bean.CommonSearch;
import com.common.bean.CommonUser;
import com.common.bean.DataMap;
import com.common.bean.FileRepository;
import com.common.bean.SystemConfig;
import com.common.bean.TableColumn;
import com.common.bean.User;
import com.common.service.CommonService;
import com.common.util.DateUtil;
import com.common.util.PostRequest;
import com.common.util.RSA;
import com.common.util.RfcCallFunction;
import com.common.util.ShaUtil;
import com.common.util.SqlUtil;
import com.common.util.Util;

@Controller
public class CommonController extends BaseController {
	
	private static Logger log = Logger.getLogger(CommonController.class);
	
	@Autowired
	private CommonService commonService;
	
	@Autowired
	private CommonLabel commonLabel;
	
	@Autowired
	private CommonSearch commonSearch;
	
	@Autowired
	private FileRepository respository;
	
	@Autowired
	private SystemConfig systemConfig;
	
	@Autowired
	private CommonUser commonUser;
	
	@Resource(name="properties")
	private Properties prop;
	
	@RequestMapping("/rfc/test.*")
	public String rfcTest(HttpServletRequest request, Map model) throws Exception {
		System.out.println("START RFC");
		
		List<DataMap> returnList = new ArrayList();
		List<DataMap> returnStructure = new ArrayList();
		DataMap itemMap = new DataMap();
		DataMap batma = new DataMap();
		RfcCallFunction sapConn = new RfcCallFunction();
		
		returnList = sapConn.RfcCallTable("Z_PP_MASTER_PCODE"	// function명
						                , "OT_LIST"       		// 호출 table명
						                , ""
						                , "D"					// 호출 flag값
						                , null);
		System.out.println("END RFC");
		model.put("data", returnList);
		model.put("row_count", returnList.size());
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/index.*")
	public String index(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("Wms", "WAHMACOMBO");
		
		List list = commonService.getList(map);
		
		model.put("WAHMACOMBO", list);
		
		map.setModuleCommand("Common", "COMCOMBO");
		map.put("CODE", "LANGKY");
		
		List list1 = commonService.getList(map);
		
		model.put("LANGKY", list1);
		
		map.setModuleCommand("Common", "LOGINMSG");
		List list2 = commonService.getList(map);
		
		model.put("MSG", list2);
		
		return "/"+systemConfig.getTheme()+"/index";
	}
	
	@RequestMapping("/common/{page}.*")
	public String page(@PathVariable String page){
		return "/common/"+page;
	}
	
	@RequestMapping("/common/{module}/{page}.*")
	public String mpage(@PathVariable String module, @PathVariable String page){
		
		return "/common/"+module+"/"+page;
	}
	
	@RequestMapping("/common/{module}/{sub}/{page}.*")
	public String spage(@PathVariable String module, @PathVariable String sub, @PathVariable String page){
		
		return "/common/"+module+"/"+sub+"/"+page;
	}
	
	@RequestMapping("/common/json/login.*")
	public String login(HttpSession session, HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("Common", "LOGIN");
		map.put("USERID", map.get("USERID").toString().toUpperCase());
		
		String encPw = map.getString("PASSWD");// 암호화된 비밀번호를 받는다.
		String decPw = null;
		
		//System.out.println("encPw : " + encPw);
		
		try {
			decPw = RSA.decryptRsa((PrivateKey) request.getSession().getAttribute("__rsaPrivateKey__"), encPw);
		} catch (Exception e1) {
			log.error(e1.getMessage());
			
			e1.printStackTrace();
			
			model.put("data", "F");
			return JSON_VIEW;
		} // 암호화된 비밀번호를 복호화한다.
		
		// 사용자 입력값 암호화
		String password = "";
		try {
			password = ShaUtil.toSha256String(decPw);
		} catch (Exception e) {
			password = "";
		}
		map.put("PASSWD", password);
		
		User user = (User)commonService.getObj(map);
		
		if(user != null){
			
			
			// 활성화된 경우에만 가능
			if(user.getDelmak().equals("V")) {
//				model.put("data", "F_LOGIN_DEL");
//				return JSON_VIEW;
				log.debug("F_LOGIN_DEL : " + user.getDelmak() );
				throw new SQLException("†F_LOGIN_DEL†");
			}
			
			// 패스워드 변경일이 90일을 초과한 경우
			String today = DateUtil.getShortDateString();
			if(today.compareTo(user.getPw90dat()) > 0) {
				log.debug("F_LOGIN_PW_90_OVER : " + user.getPw90dat() );
				model.put("data", "F_LOGIN_PW_90_OVER");
				return JSON_VIEW;
				//throw new SQLException("†F_LOGIN_PW_90_OVER†");
			}
						
			// 마지막 로그인 일자가 90일을 초과한 경우
			if(today.compareTo(user.getLlogid90()) > 0) {
				log.debug("F_LOGIN_90_OVER : " + user.getLlogid90() );
				model.put("data", "F_LOGIN_90_OVER");
				return JSON_VIEW;
				//throw new SQLException("†F_LOGIN_90_OVER†");
			}
			
			
			// 물류센터에 접속 권한이 없음
			map.setModuleCommand("Common", "ROLCT");
			map.put(CommonConfig.SES_USER_ID_KEY, user.getUserid());
			List<DataMap> rolctList = commonService.getList(map);
			if(rolctList.size() < 1){
				log.debug("F_LOGIN_ROLE : " + rolctList.size() );
				model.put("data", "F_LOGIN_ROLE");
			 	return JSON_VIEW;
				//throw new SQLException("†F_LOGIN_ROLE†");
			}
			
			map.setModuleCommand("Common", "LOGIN");
			commonService.update(map);
			
			map.setModuleCommand("Common", "USRLO");
			map.put(CommonConfig.SES_USER_ID_KEY, user.getUserid());
			List<DataMap> list = commonService.getList(map);
			DataMap usrlo = new DataMap();
			DataMap row;
			List data;
			String progid;
			for(int i=0;i<list.size();i++){
				row = list.get(i);
				progid = row.getString("PROGID");
				if(usrlo.containsKey(progid)){
					data = usrlo.getList(progid);
					data.add(row);
				}else{
					List newData = new ArrayList();
					newData.add(row);
					usrlo.put(progid, newData);
				}
			}
			
			user.setUsrlo(usrlo);
			
			map.setModuleCommand("Common", "USRPH");
			list = commonService.getList(map);
			DataMap usrph = new DataMap();
			DataMap usrphc = new DataMap();
			DataMap usrpi = new DataMap();
			String defchk;
			for(int i=0;i<list.size();i++){
				row = list.get(i);
				progid = row.getString("PROGID");
				if(usrph.containsKey(progid)){
					data = usrph.getList(progid);
					data.add(row);
				}else{
					List newData = new ArrayList();
					newData.add(row);
					usrph.put(progid, newData);
				}
				defchk =  row.getString("DEFCHK");
				if(defchk.equals("V") && !usrphc.containsKey(progid)){
					usrphc.put(progid, row.getString("PARMKY"));
					row.setModuleCommand("Common", "USRPI");
					List itemList = commonService.getList(row);
					usrpi.put(progid, itemList);
				}		
			}
			
			user.setUsrph(usrph);
			user.setUsrpi(usrpi);
			
			map.setModuleCommand("Wms", "USERINFO");
			
			DataMap userInfo = (DataMap)commonService.getMap(map);
			request.getSession().setAttribute(CommonConfig.SES_USER_INFO_KEY, userInfo);
			
			user.addUserData("userIndo", userInfo);
			
//			if(!commonUser.addUserIdMap(session, map.getString("USERID"), map.getString(CommonConfig.SES_USER_TYPE_KEY))){
//				commonUser.killSession(map.getString("USERID"), "");
//				commonUser.addUserIdMap(session, map.getString("USERID"), map.getString(CommonConfig.SES_USER_TYPE_KEY));
//			}
			
			commonUser.addSessionMap(session.getId(), user);
			
			request.getSession().setAttribute(CommonConfig.SES_USER_OBJECT_KEY, user);
			request.getSession().setAttribute(CommonConfig.SES_USER_ID_KEY, user.getUserid());
			request.getSession().setAttribute(CommonConfig.SES_USER_NAME_KEY, user.getNmlast());
			request.getSession().setAttribute(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.getString("WAREKY"));
			request.getSession().setAttribute(CommonConfig.SES_USER_OWNER_KEY, user.getOwner());
			request.getSession().setAttribute(CommonConfig.SES_USER_COMPANY_KEY, user.getCompky());
			request.getSession().setAttribute(CommonConfig.SES_USER_LANGUAGE_KEY, map.getString("LANGKY"));
			request.getSession().setAttribute(CommonConfig.SES_USER_EMPL_ID_KEY, user.getEmplid());
			request.getSession().setAttribute(CommonConfig.SES_USER_THEME_KEY, CommonConfig.SYSTEM_THEME_PATH);
			
			
			
			model.put("data", "S");
			
			/*
			map.setModuleCommand("Common", "ROLCT");
			
			List<DataMap> rolctList = commonService.getList(map);
			if(rolctList.size() < 1){
				model.put("data", "R");
			}
			*/
			
			map.setModuleCommand("System", "LOGIN_LOG");
			commonService.logInsert(map);
			
			log.debug(user);
		}else{
			model.put("data", "F");
		}	
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/param/loginPost.*")
	public String loginPost(HttpSession session, HttpServletRequest request, Map model, @RequestParam(value="USERID") String id, @RequestParam(value="PASSWD") String pwd) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.put("USERID", id);
		map.put("PASSWD", pwd);
		
		map.setModuleCommand("Common", "LOGIN");
		
		User user = (User)commonService.getObj(map);
		
		if(user != null){
			commonService.update(map);
			
			map.setModuleCommand("Common", "USRLO");
			map.put(CommonConfig.SES_USER_ID_KEY, user.getUserid());
			List<DataMap> list = commonService.getList(map);
			DataMap usrlo = new DataMap();
			DataMap row;
			List data;
			String progid;
			for(int i=0;i<list.size();i++){
				row = list.get(i);
				progid = row.getString("PROGID");
				if(usrlo.containsKey(progid)){
					data = usrlo.getList(progid);
					data.add(row);
				}else{
					List newData = new ArrayList();
					newData.add(row);
					usrlo.put(progid, newData);
				}
			}
			
			user.setUsrlo(usrlo);
			
			map.setModuleCommand("Common", "USRPH");
			list = commonService.getList(map);
			DataMap usrph = new DataMap();
			DataMap usrphc = new DataMap();
			DataMap usrpi = new DataMap();
			String defchk;
			for(int i=0;i<list.size();i++){
				row = list.get(i);
				progid = row.getString("PROGID");
				if(usrph.containsKey(progid)){
					data = usrph.getList(progid);
					data.add(row);
				}else{
					List newData = new ArrayList();
					newData.add(row);
					usrph.put(progid, newData);
				}
				defchk =  row.getString("DEFCHK");
				if(defchk.equals("V") && !usrphc.containsKey(progid)){
					usrphc.put(progid, row.getString("PARMKY"));
					row.setModuleCommand("Common", "USRPI");
					List itemList = commonService.getList(row);
					usrpi.put(progid, itemList);
				}		
			}
			
			user.setUsrph(usrph);
			user.setUsrpi(usrpi);
			
			map.setModuleCommand("Wms", "USERINFO");
			
			DataMap userInfo = (DataMap)commonService.getMap(map);
			request.getSession().setAttribute(CommonConfig.SES_USER_INFO_KEY, userInfo);
			
			user.addUserData("userIndo", userInfo);
			
			if(!commonUser.addUserIdMap(session, map.getString("USERID"), map.getString(CommonConfig.SES_USER_TYPE_KEY))){
				commonUser.killSession(map.getString("USERID"), "");
				commonUser.addUserIdMap(session, map.getString("USERID"), map.getString(CommonConfig.SES_USER_TYPE_KEY));
			}
			
			commonUser.addSessionMap(session.getId(), user);
			
			request.getSession().setAttribute(CommonConfig.SES_USER_OBJECT_KEY, user);
			request.getSession().setAttribute(CommonConfig.SES_USER_ID_KEY, user.getUserid());
			request.getSession().setAttribute(CommonConfig.SES_USER_NAME_KEY, user.getNmlast());
			request.getSession().setAttribute(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.getString("WAREKY"));
			request.getSession().setAttribute(CommonConfig.SES_USER_OWNER_KEY, user.getOwner());
			request.getSession().setAttribute(CommonConfig.SES_USER_COMPANY_KEY, user.getCompky());
			request.getSession().setAttribute(CommonConfig.SES_USER_LANGUAGE_KEY, map.getString("LANGKY"));
			request.getSession().setAttribute(CommonConfig.SES_USER_EMPL_ID_KEY, user.getEmplid());
			request.getSession().setAttribute(CommonConfig.SES_USER_THEME_KEY, CommonConfig.SYSTEM_THEME_PATH);
			
			
			
			model.put("data", "S");
			
			map.setModuleCommand("Common", "ROLCT");
			
			List<DataMap> rolctList = commonService.getList(map);
			if(rolctList.size() < 1){
				model.put("data", "R");
			}
			
			log.debug(user);
		}else{
			//model.put("data", "F");
			return "/common/index";
		}	
		
		return "/common/main";
	}
	
	@RequestMapping("/common/password.page")
	public String passwordPage(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		request.getSession().setAttribute(CommonConfig.SES_USER_LANGUAGE_KEY, map.getString("LANGKY"));
		request.getSession().setAttribute(CommonConfig.SES_USER_THEME_KEY, CommonConfig.SYSTEM_THEME);
		
		return "/wms/password";
	}
	
	@RequestMapping("/common/json/password.*")
	public String password(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("Common", "PASSWORD");
		
		DataMap rs = commonService.getMap(map);
		
		if(rs != null){
			commonService.update(map);
			
			model.put("data", "S");
		}else{
			model.put("data", "F");
		}
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/json/logout.*")
	public String logout(HttpSession session, HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		session.removeAttribute(CommonConfig.SES_USER_OBJECT_KEY);
		session.removeAttribute(CommonConfig.SES_USER_ID_KEY);
		session.removeAttribute(CommonConfig.SES_USER_NAME_KEY);
		session.removeAttribute(CommonConfig.SES_USER_WHAREHOUSE_KEY);
		session.removeAttribute(CommonConfig.SES_USER_OWNER_KEY);
		session.removeAttribute(CommonConfig.SES_USER_COMPANY_KEY);
		session.removeAttribute(CommonConfig.SES_USER_INFO_KEY);
		
		map.setModuleCommand("Common", "LOGOUT");
		commonService.update(map);
		
		map.setModuleCommand("System", "LOGOUT_LOG");
		commonService.logInsert(map);
		
		return "/sessionEmpty";
	}
	
	@RequestMapping("/common/json/SAVE_PROGM_LOG.*")
	public String SAVE_PROGM_LOG(HttpServletRequest request, Map model) throws Exception{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("System", "PROGM_LOG");
		commonService.logInsert(map);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/left.*")
	public String leftMenu(HttpSession session, HttpServletRequest request, Map model) throws SQLException{
		String langky = session.getAttribute(CommonConfig.SES_USER_LANGUAGE_KEY).toString();
		String userid = session.getAttribute(CommonConfig.SES_USER_ID_KEY).toString();
		
		DataMap map = new DataMap("Common", "MENUTREE");
		map.put("LANGKY", langky);
		map.put("USERID", userid);
		
		List<DataMap> list = commonService.getList(map);
		
		session.setAttribute(CommonConfig.SES_USER_MENU_KEY, list);
		
		DataMap urlMap = new DataMap();
		DataMap row;
		String tmpUrl;
		for(int i=0;i<list.size();i++){
			row = list.get(i);
			tmpUrl = row.getString("PGPATH");
			if(tmpUrl.trim().length() != 0){
				if(tmpUrl.substring(0, 2).equals("./")){
					tmpUrl = tmpUrl.substring(1);
				}
				if(tmpUrl.substring(tmpUrl.length()-3).equals("jsp")){
					tmpUrl = tmpUrl.substring(0,tmpUrl.length()-3)+"page";
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
		
		model.put("list", list);
		
		return "/common/left";
	}
	
	@RequestMapping("/common/Common/insert/json/USRLO1.*")
	public String usrloinsert1(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("Common", "USRLO");

		Object data = commonService.insert(map);
		
		User user = (User)request.getSession().getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
		DataMap usrlo = user.getUsrlo();
		String progid = map.getString("PROGID");
		if(usrlo.containsKey(progid)){
			List list = usrlo.getList(progid);
			list.add(map);
		}else{
			List newData = new ArrayList();
			newData.add(map);
			usrlo.put(progid, newData);
		}
				
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/Common/update/json/USRLO1.*")
	public String usrloupdate1(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("Common", "USRLO");

		int rs = commonService.update(map);
		
		User user = (User)request.getSession().getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
		DataMap usrlo = user.getUsrlo();
		String progid = map.getString("PROGID");
		if(usrlo.containsKey(progid)){
			List list = usrlo.getList(progid);
			list.add(map);
		}else{
			List newData = new ArrayList();
			newData.add(map);
			usrlo.put(progid, newData);
		}
		
		model.put("data", rs);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/Common/insert/json/USRLO.*")
	public String usrloinsert(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		User user = (User)request.getSession().getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
		
		commonService.usrloinsert(map, user);
		model.put("data", "OK");
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/Common/update/json/USRLO.*")
	public String usrloupdate(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		User user = (User)request.getSession().getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
		
		commonService.usrloupdate(map, user);
		model.put("data", "OK");
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/{module}/count/json/{command}.*")
	public String count(HttpServletRequest request, @PathVariable String module, @PathVariable String command, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);

		int count = commonService.getCount(map);
		
		model.put("data", count);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/{module}/paging/json/{command}.*")
	public String paging(HttpServletRequest request, @PathVariable String module, @PathVariable String command, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);
		
		List list = commonService.getPagingList(map);
		
		model.put("data", list);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/{module}/list/json/{command}.*")
	public String list(HttpServletRequest request, @PathVariable String module, @PathVariable String command, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);
		
		List list = commonService.getList(map);
		
		model.put("data", list);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/{module}/asynclist/{dataType}/{command}.*")
	public String asynclist(HttpServletRequest request, @PathVariable String module, @PathVariable String command, Map model) throws SQLException, InterruptedException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);

		String listData;
		
		if(systemConfig.isAsync()){
			listData = commonService.getAsyncList(map);
		}else{
			listData = commonService.getTextList(map);
			//listData = commonService.getJdbcData(map);
		}
		
		model.put("data", listData);
		
		return TEXT_VIEW;
	}

	@RequestMapping("/common/{module}/datalist/{dataType}/{command}/procedure.*")
	public String datalistProcedure(HttpServletRequest request, @PathVariable String module, @PathVariable String command, Map model) throws SQLException, InterruptedException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);

		String listData = commonService.getJdbcData(map);

		model.put("data", listData);

		return TEXT_VIEW;
	}
	
	@RequestMapping("/common/{module}/datalist/{dataType}/{command}.*")
	public String datalist(HttpServletRequest request, @PathVariable String module, @PathVariable String command, Map model) throws SQLException, InterruptedException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);
		
		String listData = commonService.getJdbcData(map);

		model.put("data", listData);
		
		return TEXT_VIEW;
	}
	
	@RequestMapping("/common/search/json/data.*")
	public String searchList(HttpServletRequest request, Map model) throws SQLException, InterruptedException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("COMMON", "SEARCH");
		
		searchSql(map);
		
		String listData = commonService.getJdbcData(map);

		model.put("data", listData);
		
		return TEXT_VIEW;
	}
	
	public void searchSql(DataMap map) throws SQLException{				
		map.setModuleCommand("Common", "SEARCHHEAD");
		
		StringBuilder sql = new StringBuilder();
		
		DataMap inputParam = map.getMap(CommonConfig.INPUT_SEARCH_PARAM_KET);
		Iterator it = inputParam.keySet().iterator();
		while(it.hasNext()){
			Object key = it.next();
			if(key != CommonConfig.RANGE_SQL_KEY && key != CommonConfig.WHARE_SQL){
 				sql.append(" AND ").append(key).append(" = '").append(inputParam.get(key)).append("' ");
			}
		}
		
		if(sql.length() > 0){
			if(map.containsKey(CommonConfig.RANGE_SQL_KEY)){
				sql.append(" ").append(map.get(CommonConfig.RANGE_SQL_KEY));
				map.put(CommonConfig.RANGE_SQL_KEY, sql.toString());
			}else{
				map.put(CommonConfig.RANGE_SQL_KEY, sql.toString());
			}			
		}
		
		DataMap head = commonService.getMap(map);
		
		map.setModuleCommand("Common", "SEARCHITEM");
		
		List<DataMap> itemList = commonService.getList(map);
		
		DataMap row;
		
		StringBuilder col = new StringBuilder();
		
		for(int i=0;i<itemList.size();i++){
			row = itemList.get(i);
			if(row.getString("INDULS").equals("V")){
				if(col.length() > 0){
					col.append(",");
				}
				col.append(row.getString("DBFILD"));
			}			
		}
		
		map.setModuleCommand("Common", "SEARCH");
		
		map.put("COL", col.toString());
		map.put("TABLE", head.getString("STARGO"));
	}
	
	@RequestMapping("/common/{module}/map/json/{command}.*")
	public String map(HttpServletRequest request, @PathVariable String module, @PathVariable String command, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);
		
		Map data = commonService.getMap(map);
		
		model.put("data", data);
		model.put("map", map);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/{module}/insert/json/{command}.*")
	public String insert(HttpServletRequest request, @PathVariable String module, @PathVariable String command, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);

		Object data = commonService.insert(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/{module}/update/json/{command}.*")
	public String update(HttpServletRequest request, @PathVariable String module, @PathVariable String command, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);

		int rs = commonService.update(map);
		
		model.put("data", rs);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/{module}/delete/json/{command}.*")
	public String delete(HttpServletRequest request, @PathVariable String module, @PathVariable String command, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);

		int rs = commonService.delete(map);
		
		model.put("data", rs);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/excelParam/json/save.*")
	public String excelParamSave(HttpSession session, HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		String key = UUID.randomUUID().toString();
		
		session.setAttribute(key, map);
		
		model.put("key", key);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/{module}/excel/{command}.*")
	public String excel(HttpServletRequest request, @PathVariable String module, @PathVariable String command, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);

		String data = commonService.getListString(map);
		
		return excelView(map, model, data);
	}
	
	@RequestMapping("/common/excel/temp.*")
	public String excelTemp(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		String data;
		if(map.containsKey("dataString")){
			data = map.getString("dataString");
		}else{
			data = "";
		}
		
		return excelView(map, model, data);
	}
	
	@RequestMapping("/common/{module}/{type}/fileUp/{command}.*")
	public String fileUp(HttpServletRequest request, @PathVariable String module, @PathVariable String type, @PathVariable String command, Map model) throws FileNotFoundException, IOException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);

		DataMap fileMap = map.getMap(CommonConfig.FILE_MAP_KEY);
		List list = fileMap.getList(CommonConfig.FILELIST_KEY);

		map.put("data", list);
		
		return "/common/fileAjaxUp";
	}
	
	@RequestMapping("/common/fileUp/file.*")
	public String fileUpDummy(HttpServletRequest request, Map model) throws FileNotFoundException, IOException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		DataMap fileMap = map.getMap(CommonConfig.FILE_MAP_KEY);
		List list = fileMap.getList(CommonConfig.FILELIST_KEY);
		map.put("data", list);
		
		return "/common/fileAjaxUp";
	}
	
	@RequestMapping("/common/fileGroupUp/file.*")
	public String fileUpGroup(HttpServletRequest request, Map model) throws FileNotFoundException, IOException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		DataMap fileMap = map.getMap(CommonConfig.FILE_MAP_KEY);
		String guuid = fileMap.getString(CommonConfig.FILEGROUP_KEY);
		List list = new ArrayList();
		list.add(guuid);
		
		map.put("data", list);
		
		return "/common/fileAjaxUp";
	}
	
	@RequestMapping("/common/image/fileUp/image.*")
	public String fileUpImageDummy(HttpServletRequest request, Map model) throws FileNotFoundException, IOException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		DataMap fileMap = map.getMap(CommonConfig.FILE_MAP_KEY);
		List list = fileMap.getList(CommonConfig.FILELIST_KEY);

		map.put("data", list);
		
		return "/common/fileAjaxUp";
	}
	
	@RequestMapping("/common/image/fileGroupUp/image.*")
	public String fileGroupUpImageDummy(HttpServletRequest request, Map model) throws FileNotFoundException, IOException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		DataMap fileMap = map.getMap(CommonConfig.FILE_MAP_KEY);
		String guuid = fileMap.getString(CommonConfig.FILEGROUP_KEY);
		List list = new ArrayList();
		list.add(guuid);

		map.put("data", list);
		
		return "/common/fileAjaxUp";
	}
	
	@RequestMapping("/common/fileDown/file.*")
	public String doDownload(HttpServletRequest request, Map model) throws Exception {
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		File file = null;
		if(map.getString("UUID").equals("CUBE_COL_NAME_UUID")){
			return null;
		}

		if(map.getString("UUID").equals("")){
			file = new File(respository.getPath(), "noImage");
			model.put("downloadFile", file);
			model.put("fileName", "");
		}else{
			DataMap data = commonService.getMap(map);
			file = commonService.getFile(data);
			if(!file.isFile()){
				file = new File(respository.getPath(), "noImage");
			}
			
			model.put("downloadFile", file);
			model.put("fileName", java.net.URLEncoder.encode(data.getString("NAME"), "UTF-8"));
		}
		return FILE_VIEW;
	}
	
	@RequestMapping("/common/load/excel/json/grid.*")
	public String excelGrid(HttpServletRequest request, Map model) throws FileNotFoundException, IOException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		List data = commonService.getExcel(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/sample/{module}/excel/{command}.*")
	public String excelM(HttpServletRequest request, @PathVariable String module, @PathVariable String command, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);

		List list = commonService.getList(map);
		
		return excelView(map, model, list);
	}
	
	@RequestMapping("/common/{module}/gridSave/json/{command}.*")
	public String gridSave(HttpServletRequest request, @PathVariable String module, @PathVariable String command, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);
		
		DataMap data = commonService.gridSave(map);
		
		model.putAll(data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/label/json/reload.*")
	public String loadLabel(HttpServletRequest request, Map model) throws SQLException, IOException{		

		commonService.loadLabel();
		
		model.put("data", "reload");

		return JSON_VIEW;
	}
	
	@RequestMapping("/common/message/json/reload.*")
	public String loadMessage(HttpServletRequest request, Map model) throws SQLException, IOException{		

		commonService.loadMessage();
		
		model.put("data", "reload");

		return JSON_VIEW;
	}
	
	@RequestMapping("/common/sql/json/reload.*")
	public String loadSql(HttpServletRequest request, Map model) throws Exception{		

		commonService.loadSql();
		
		model.put("data", "reload");

		return JSON_VIEW;
	}
	
	@RequestMapping("/common/sql/json/test.*")
	public String testSql(HttpServletRequest request, Map model) throws SQLException, IOException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		commonService.testSql(map);
		
		model.put("data", "reload");

		return JSON_VIEW;
	}
	
	@RequestMapping("/common/sql/json/viewSqlXml.*")
	public String viewSqlXml(HttpServletRequest request, Map model) throws SQLException, IOException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		commonService.viewSqlXml(map);
		
		model.put("data", "reload");

		return JSON_VIEW;
	}
	
	@RequestMapping("/common/search/json/reload.*")
	public String loadSearch(HttpServletRequest request, Map model) throws SQLException, IOException{		

		commonService.loadSearch();
		
		//UriInfo uriInfo = (UriInfo)request.getAttribute(CommonConfig.REQUEST_URI_INFO_KEY);
		
		//commonSearch.searchFileCreate(uriInfo);
		
		model.put("data", "reload");

		return JSON_VIEW;
	}
	
	@RequestMapping("/common/page/searchHelp.*")
	public String searchHelp(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("Common", "SEARCHHEAD");
		
		model.put("param", map);
		
		//Map head = commonService.getMap(map);
		
		Map head = commonSearch.getHead(map.getString("SHLPKY"));
		
		model.put("head", head);
		
		map.setModuleCommand("Common", "SEARCHITEM");
		
		//List itemList = commonService.getList(map);
		
		List itemList = commonSearch.getItem(map.getString("SHLPKY"));
		
		model.put("itemList", itemList);
		
		//String langky = request.getSession().getAttribute(CommonConfig.SES_USER_LANGUAGE_KEY).toString();
		
		//Map label = commonLabel.getLabel(langky);
		
		//model.put("label", label);
		
		return "/common/search";
	}
	
	@RequestMapping("/common/variant/json/insert.*")
	public String variantInsert(HttpSession session, HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		List list = commonService.variantInsert(map);
		
		User user = (User)session.getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
		map.put("USERID", map.getString(CommonConfig.SES_USER_ID_KEY));
		String progId = map.getString("PROGID");
		if(user.getUsrph().containsKey(progId)){
			if(map.containsKey("UCOUNT")){
				String parmky = map.getString("PARMKY");
				List tmpList = user.getUsrph().getList(progId);
				Map row;
				for(int i=0;i<tmpList.size();i++){
					row = (Map)tmpList.get(i);
					if(row.get("PARMKY").toString().equals(parmky)){
						tmpList.set(i, map);
						break;
					}
				}
			}else{
				user.getUsrph().getList(progId).add(map);
			}			
		}else{
			List tmpList = new ArrayList();
			tmpList.add(map);
			user.getUsrph().put(progId, tmpList);
		}
		
		if(map.getString("DEFCHK").equals("V")){
			user.getUsrpi().put(map.getString("PROGID"), list);
		}else{
			map.put("DEFCHK","V");
			map.setModuleCommand("Common", "USRPH");
			List tmpList = commonService.getList(map);
			if(tmpList.size() == 0){
				user.getUsrpi().remove(map.getString("PROGID"));
			}
		}
		
		model.put("data", list);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/variant/json/delete.*")
	public String variantDelete(HttpSession session, HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		DataMap data = commonService.variantDelete(map);
		
		User user = (User)session.getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
		String progId = map.getString("PROGID");
		String parmky = map.getString("PARMKY");
		List list = user.getUsrph().getList(progId);
		Map row;
		for(int i=0;i<list.size();i++){
			row = (Map)list.get(i);
			if(row.get("PARMKY").toString().equals(parmky)){
				list.remove(i);				
				break;
			}
		}			
		
		if(data.getString("DEFCHK").equals("V")){
			user.getUsrpi().remove(progId);
		}
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	/*
	@RequestMapping("/common/json/searchSql.*")
	public String searchSql(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("Common", "SEARCHHEAD");
		
		DataMap head = commonService.getMap(map);
		
		map.setModuleCommand("Common", "SEARCHITEM");
		
		List<DataMap> itemList = commonService.getList(map);
		
		DataMap row;
		
		StringBuilder col = new StringBuilder();
		
		for(int i=0;i<itemList.size();i++){
			row = itemList.get(i);
			if(row.getString("INDULS").equals("V")){
				if(col.length() > 0){
					col.append(",");
				}
				col.append(row.getString("DBFILD"));
			}			
		}
		
		map.setModuleCommand("Common", "SEARCH");
		
		map.put("COL", col.toString());
		map.put("TABLE", head.getString("STARGO"));
		
		List list = commonService.getList(map);
		
		model.put("data", list);
		
		return JSON_VIEW;
	}
	*/
	@RequestMapping("/common/json/COLUMN_LIST.*")
	public String COLUMN_LIST(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		List<TableColumn> list = commonService.getColumnList(map.getString("table"));
		
		SqlUtil sqlUtil = new SqlUtil();
		
		sqlUtil.setColumnData(map, model, list);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/json/SQL_COLUMN_LIST.*")
	public String SQL_COLUMN_LIST(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		List<TableColumn> list = commonService.getSqlColumnList(map.getString("sql"));
		
		SqlUtil sqlUtil = new SqlUtil();
		
		sqlUtil.setColumnData(map, model, list);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/json/SQL_COLOBJ_LIST.*")
	public String SQL_COLOBJ_LIST(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		List<TableColumn> list = commonService.getSqlColObjList(map.getString("sql"));
		
		model.put("data", list);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/json/SQL_COLOBJ_SAVE.*")
	public String SQL_COLOBJ_SAVE(HttpServletRequest request, Map model) throws SQLException, IOException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		DataMap result = commonService.sqlColObjSave(map);
		
		model.putAll(result);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/sample/{page}.*")
	public String samplePage(@PathVariable String page){
		return "/sample/"+page;
	}
	
	@RequestMapping("/common/userinfo.*")
	public String userInfo(HttpSession session, HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		
		Object obj = session.getAttribute(CommonConfig.SES_USER_INFO_KEY);
		DataMap data = null;
		
		if(obj != null){
			data = (DataMap)obj;
		}
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/api/json/restfulRequest.*")
	public String restfulRequest(HttpSession session, HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		PostRequest postRequest = new PostRequest();
		
		DataMap data = postRequest.jsonPost("http://127.0.0.1:8080/common/api/json/restfulResponse.data", map);
		
		model.putAll(data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/api/json/restfulResponse.*")
	public String restfulResponse(HttpSession session, HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("Common", "USRPH");
		map.put("SES_USER_ID", "DEV");
		List list = commonService.getList(map);
		map.put("detail", list);
		
		model.putAll(map);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/page/SQL_GRID_LIST.*")
	public String SQL_GRID_LIST(HttpSession session, HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		String data = commonService.getSqlGridList(map.getString("sql"));
		
		session.setAttribute("SQL_GRID_DATA_LIST", data);
		
		String[] cols = data.substring(0, data.indexOf("↑")).split("↓");
		
		request.setAttribute("cols", cols);
		request.setAttribute("sql", map.getString("sql"));
		
		return "/common/tool/sqlGrid";
	}
	
	@RequestMapping("/common/json/SQL_GRID_DATA_LIST.*")
	public String sqlGridDatalist(HttpSession session, HttpServletRequest request, Map model) throws SQLException, InterruptedException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		String listData = (String)session.getAttribute("SQL_GRID_DATA_LIST");

		model.put("data", listData);
		
		return TEXT_VIEW;
	}
	
	@RequestMapping("/common/sql/json/executeUpdate.*")
	public String executeUpdate(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		int result = commonService.executeUpdate(map.getString("sql"));
		
		model.put("result", result);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/grid/excel/fileUp/data.*")
	public String excelGridData(HttpSession session, HttpServletRequest request, Map model) throws FileNotFoundException, IOException, NoSuchMethodException, SecurityException, IllegalAccessException, IllegalArgumentException, InvocationTargetException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		List list = map.getList(CommonConfig.FILELIST_KEY);
		if(list.size() > 0){
			map.put("UUID", list.get(0));
			map.put(CommonConfig.DATA_EXCEL_COLNAME_ROWNUM_KEY, 1);
			List<String> colList = commonService.getExcelCollist(map);
			List<DataMap> dataList = commonService.getExcel(map);
			
			if(map.containsKey(CommonConfig.EXCEL_DATA_VALIDATION_BEANNAME)){
				map.put("list", dataList);
				Util util = new Util();
				Object result = util.executeBeanObject(request, map.getString(CommonConfig.EXCEL_DATA_VALIDATION_BEANNAME), map.getString(CommonConfig.EXCEL_DATA_VALIDATION_FUNCNAME), map);
				request.setAttribute("result", result);
			}
			
			/*
			if(dataList.size() > 0){
				DataMap row = dataList.get(0);
				String[] cols = new String[row.size()-2];
				Iterator it = row.keySet().iterator();
				int count = 0;
				for(int i=0;i<row.size();i++){
					String key = it.next().toString();
					if(key.equals(CommonConfig.EXCEL_DATA_VALIDATION_RESULT_CODE) || key.equals(CommonConfig.EXCEL_DATA_VALIDATION_RESULT_MSG)){
						continue;
					}
					cols[count] = key;
					count++;
				}
				request.setAttribute("cols", cols);
			}
			*/
			
			String[] cols = new String[colList.size()];
			for(int i=0;i<colList.size();i++){
				cols[i] = colList.get(i);
			}
			request.setAttribute("cols", cols);
			
			session.setAttribute("EXCEL_GRID_DATA_LIST", dataList);
		}
		
		return "/common/tool/excelGrid";
	}
	
	@RequestMapping("/common/json/EXCEL_GRID_DATA_LIST.*")
	public String excelGridDatalist(HttpSession session, HttpServletRequest request, Map model) throws SQLException, InterruptedException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		List listData = (List)session.getAttribute("EXCEL_GRID_DATA_LIST");

		model.put("data", listData);
		
		return JSON_VIEW;
	}
	
	/**
	 * @author 2019.06.28 이범준
	 * @param map
	 * @return json
	 * @throws Exception
	 * @method sessionSaveDataCount 
	 * PROCS_BTCSEQ_MAP sessionKey값 을 지속적으로 호출
	 */
	@RequestMapping("/common/session/json/sessionSaveDataCount.*")
	public String sessionSaveDataCount(HttpSession session, HttpServletRequest request, Map model) throws Exception{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		String sessionKey = map.getString("sessionKey");
		if(session.getAttribute(sessionKey) == null){
			session.setAttribute(sessionKey, 0);
		}
		
		Object obj = session.getAttribute(sessionKey);
		int data = 0;
		if(obj != null){
			data = (int)obj;
		}
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	/**
	 * @author 2019.06.28 이범준
	 * @param map
	 * @return json
	 * @throws SQLException
	 * @method procsUpdateDataCount 
	 * proc 테이블 사용시 
	 */
	@RequestMapping("/common/session/json/procsUpdateDataCount.*")
	public String procsUpdateDataCount(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("Common", "PROCS_UPD");
		int data = commonService.getCount(map);
		model.put("data", data);
		
		return JSON_VIEW;
	}
	/**
	 * @author 2019.06.28 이범준
	 * @param map
	 * @return json
	 * @throws Exception
	 * @method removeSessionSaveData 
	 * 생성된 저장 세션을 삭제
	 */
	@RequestMapping("/common/session/json/removeSessionSaveData.*")
	public String removeSessionSaveData(HttpSession session, HttpServletRequest request, Map model) throws Exception{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		String sessionKey = map.getString("sessionKey");
		
		session.removeAttribute(sessionKey);
		
		model.put("data", "S");
		
		return JSON_VIEW;
	}
}