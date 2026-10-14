package project.common.controller;

import java.security.PrivateKey;
import java.security.SecureRandom;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.mail.internet.MimeMessage;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.mail.javamail.MimeMessagePreparator;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.RequestMapping;

import project.common.bean.CommonConfig;
import project.common.bean.CommonLabel;
import project.common.bean.DataMap;
import project.common.bean.SystemConfig;
import project.common.bean.BaseUser;
import project.common.service.CommonService;
import project.common.util.Keygen;
import project.common.util.RSA;
import project.common.util.ShaUtil;

@Controller
public class LoginController extends BaseController {

	static final Logger log = LogManager.getLogger(LoginController.class.getName());

	@Autowired
	private CommonService commonService;
	
	@Autowired
	private SystemConfig systemConfig;

	@RequestMapping("/common/json/login.*")
	public String login(HttpSession session, HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		logout(session, request, model);

		map.setModuleCommand(systemConfig.getCmmonType(), "USERCHECK");

		BaseUser user = (BaseUser)commonService.getObj(map);

		if (user != null) {

			if (!user.getPassword().equals(map.getString("PASSWD"))) {
				model.put("data", "F");

				return JSON_VIEW;
			}
			
			commonService.update(systemConfig.getCmmonType()+".LOGIN", map);
						
			map.setModuleCommand("Common", "SYSGRIDCOL");
			map.put(CommonConfig.SES_USER_ID_KEY, user.getUserid());
			List<DataMap> list = commonService.getList(map);
			DataMap usrlo = new DataMap();
			DataMap row = null;
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
					newData.clear();
				}
			}

			user.setUsrlo(usrlo);
			usrlo.clear();
			session.setAttribute(CommonConfig.SES_USER_OBJECT_KEY, user);
			session.setAttribute(CommonConfig.SES_USER_ID_KEY, user.getUserid());
			session.setAttribute(CommonConfig.SES_USER_NAME_KEY, user.getUsername());
			session.setAttribute(CommonConfig.SES_USER_COMPANY_KEY, user.getCompid());
			session.setAttribute(CommonConfig.SES_USER_LANGUAGE_KEY, map.getString("LANGKY"));
			session.setAttribute(CommonConfig.SES_USER_THEME_KEY, CommonConfig.SYSTEM_THEME_PATH);
			session.setAttribute(CommonConfig.SES_MENU_GROUP_KEY, user.getMenugid());
			
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
			
			map.clear();
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
			row.clear();
			list.clear();
			urlMap.put("/common/main.page", true);
			urlMap.put("/common/left.page", true);
			urlMap.put("/common/top.page", true);
			urlMap.put("/common/wintab.page", true);
			urlMap.put("/common/info.page", true);
			session.setAttribute(CommonConfig.SES_USER_URL_KEY, urlMap);

			model.put("data", "S");

			log.debug(user);
		} else {
			model.put("data", "N");
		}

		return JSON_VIEW;
	}
	
	@RequestMapping("/common/json/rootdata.*")
	public String rootdata(HttpSession session, HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		BaseUser user = (BaseUser)session.getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
		
		if(user != null){
			
			String langKey = (String)session.getAttribute(CommonConfig.SES_USER_LANGUAGE_KEY);
			map.put("LANGKY", langKey);
			
			map.put("MENUGID", user.getMenugid());
			map.put("ROOTGID", user.getRootgid());
			List<DataMap> rootList = commonService.getList("Common.COMP_ROOT", map);
			
			session.setAttribute(CommonConfig.SES_ROOT_COMP_LIST, rootList);
			
			if(rootList != null && rootList.size() > 0){
				DataMap rootMap = rootList.get(0);
				session.setAttribute(CommonConfig.SES_ROOT_COMPID, rootMap.getString("COMPVID"));
				
				map.put("ROOTGID", user.getRootgid());
				map.put("COMPVID", rootMap.getString("COMPVID"));
				rootMap.clear();
				
				List<DataMap> menuList = commonService.getList("Common.ROOTMENU", map);
				session.setAttribute(CommonConfig.SES_ROOT_COMP_MENULIST, menuList);
				
				if(menuList != null && menuList.size() > 0){
					DataMap menuMap = menuList.get(0);
					session.setAttribute(CommonConfig.SES_ROOT_MENUID, menuMap.getString("MENUID"));
					
					map.put("MENUID", menuMap.getString("MENUID"));
					List<DataMap> menuCompList = commonService.getList("Common.ROOTMENUCOMP", map);
					session.setAttribute(CommonConfig.SES_ROOT_MENU_COMPLIST, menuCompList);
					
					menuCompList.clear();
					map.put("PMENUID", menuMap.getString("MENUID"));				
					
					List<DataMap> subList = commonService.getList("Common.ROOT_SUB", map);
					
					map.clear();
					session.setAttribute(CommonConfig.SES_ROOT_SUB_MENULIST, subList);
					
					String subMenuId = "";
					if(subList != null && subList.size() > 0){
						DataMap subMenuMap = subList.get(0);
						subMenuId = subMenuMap.getString("MENUID");
						subMenuMap.clear();
					}
					session.setAttribute(CommonConfig.SES_ROOT_SUB_MENU, subMenuId);
										
					model.put(CommonConfig.SES_ROOT_MENUID, menuMap.getString("MENUID"));
					model.put(CommonConfig.SES_ROOT_COMP_MENULIST, menuList);
					model.put(CommonConfig.SES_ROOT_SUB_MENULIST, subList);
					model.put(CommonConfig.SES_ROOT_SUB_MENU, subMenuId);
					menuMap.clear();
					subList.clear();
				}else{
					session.removeAttribute(CommonConfig.SES_ROOT_MENUID);
					session.removeAttribute(CommonConfig.SES_ROOT_SUB_MENULIST);
					session.removeAttribute(CommonConfig.SES_ROOT_SUB_MENU);
				}
				menuList.clear();
				model.put("data","OK");
			}
			rootList.clear();
		}	

		return JSON_VIEW;
	}
	
	@RequestMapping("/common/json/rootCompChange.*")
	public String rootChange(HttpSession session, HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		BaseUser user = (BaseUser)session.getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
		
		if(user != null){
			String langKey = (String)session.getAttribute(CommonConfig.SES_USER_LANGUAGE_KEY);
			map.put("LANGKY", langKey);
			
			map.put("MENUGID", user.getMenugid());
			map.put("ROOTGID", user.getRootgid());
			
			session.setAttribute(CommonConfig.SES_ROOT_COMPID, map.getString("COMPVID"));
			
			map.put("ROOTGID", user.getRootgid());
			map.put("COMPVID", map.getString("COMPVID"));
			
			List<DataMap> menuList = commonService.getList("Common.ROOTMENU", map);
			session.setAttribute(CommonConfig.SES_ROOT_COMP_MENULIST, menuList);
			
			if(menuList != null && menuList.size() > 0){
				DataMap menuMap = menuList.get(0);
				session.setAttribute(CommonConfig.SES_ROOT_MENUID, menuMap.getString("MENUID"));
				
				map.put("MENUID", menuMap.getString("MENUID"));
				List<DataMap> menuCompList = commonService.getList("Common.ROOTMENUCOMP", map);
				session.setAttribute(CommonConfig.SES_ROOT_MENU_COMPLIST, menuCompList);
				
				map.put("PMENUID", menuMap.getString("MENUID"));				
				
				List<DataMap> subList = commonService.getList("Common.ROOT_SUB", map);
				session.setAttribute(CommonConfig.SES_ROOT_SUB_MENULIST, subList);
				
				String subMenuId = "";
				if(subList != null && subList.size() > 0){
					DataMap subMenuMap = subList.get(0);
					subMenuId = subMenuMap.getString("MENUID");
					subMenuMap.clear();
				}
				session.setAttribute(CommonConfig.SES_ROOT_SUB_MENU, subMenuId);
									
				model.put(CommonConfig.SES_ROOT_MENUID, menuMap.getString("MENUID"));
				model.put(CommonConfig.SES_ROOT_COMP_MENULIST, menuList);
				model.put(CommonConfig.SES_ROOT_SUB_MENULIST, subList);
				model.put(CommonConfig.SES_ROOT_SUB_MENU, subMenuId);
				menuCompList.clear();
			}else{
				session.removeAttribute(CommonConfig.SES_ROOT_MENUID);
				session.removeAttribute(CommonConfig.SES_ROOT_SUB_MENULIST);
				session.removeAttribute(CommonConfig.SES_ROOT_SUB_MENU);
			}
			map.clear();
			model.put("data","OK");
		}

		return JSON_VIEW;
	}
	
	@RequestMapping("/common/json/rootMenuChange.*")
	public String rootCompChange(HttpSession session, HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		BaseUser user = (BaseUser)session.getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
		
		if(user != null){
			String langKey = (String)session.getAttribute(CommonConfig.SES_USER_LANGUAGE_KEY);
			map.put("LANGKY", langKey);
			
			map.put("MENUGID", user.getMenugid());
			map.put("ROOTGID", user.getRootgid());
			
			String menuId = map.getString("MENUID");
			session.setAttribute(CommonConfig.SES_ROOT_MENUID, menuId);
			
			map.put("MENUID", menuId);
			List<DataMap> menuCompList = commonService.getList("Common.ROOTMENUCOMP", map);
			session.setAttribute(CommonConfig.SES_ROOT_MENU_COMPLIST, menuCompList);
			
			menuCompList.clear();
			map.put("PMENUID", menuId);				
			
			List<DataMap> subList = commonService.getList("Common.ROOT_SUB", map);
			session.setAttribute(CommonConfig.SES_ROOT_SUB_MENULIST, subList);
			
			String subMenuId = "";
			if(subList != null && subList.size() > 0){
				DataMap subMenuMap = subList.get(0);
				subMenuId = subMenuMap.getString("MENUID");
				subMenuMap.clear();
			}
			session.setAttribute(CommonConfig.SES_ROOT_SUB_MENU, subMenuId);
								
			model.put(CommonConfig.SES_ROOT_MENUID, menuId);
			model.put(CommonConfig.SES_ROOT_SUB_MENULIST, subList);
			model.put(CommonConfig.SES_ROOT_SUB_MENU, subMenuId);
			
			model.put("data","OK");
		}
		map.clear();
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/json/rootSubChange.*")
	public String rootSubChange(HttpSession session, HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		BaseUser user = (BaseUser)session.getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
		
		if(user != null){
			String langKey = (String)session.getAttribute(CommonConfig.SES_USER_LANGUAGE_KEY);
			map.put("LANGKY", langKey);
			
			map.put("MENUGID", user.getMenugid());
			map.put("ROOTGID", user.getRootgid());
			
			String subMenuId = map.getString("MENUID");
			session.setAttribute(CommonConfig.SES_ROOT_SUB_MENU, subMenuId);
			
			model.put(CommonConfig.SES_ROOT_SUB_MENU, subMenuId);
			
			model.put("data","OK");
		}
		map.clear();
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/json/rootDataList.*")
	public String rootDataList(HttpSession session, HttpServletRequest request, Map model) throws SQLException {
		//DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		BaseUser user = (BaseUser)session.getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
		
		if(user != null){
			List<DataMap> rootCompList = (List)session.getAttribute(CommonConfig.SES_ROOT_COMP_LIST);
			String compId = (String)session.getAttribute(CommonConfig.SES_ROOT_COMPID);
			List<DataMap> compMenuList = (List)session.getAttribute(CommonConfig.SES_ROOT_COMP_MENULIST);
			String rootMenuid = (String)session.getAttribute(CommonConfig.SES_ROOT_MENUID);
			List<DataMap> menuCompList = (List)session.getAttribute(CommonConfig.SES_ROOT_MENU_COMPLIST);			
			List<DataMap> subList = (List)session.getAttribute(CommonConfig.SES_ROOT_SUB_MENULIST);
			String subMenuId = (String)session.getAttribute(CommonConfig.SES_ROOT_SUB_MENU);
			
			model.put(CommonConfig.SES_ROOT_COMP_LIST, rootCompList);
			model.put(CommonConfig.SES_ROOT_COMPID, compId);
			model.put(CommonConfig.SES_ROOT_COMP_MENULIST, compMenuList);
			model.put(CommonConfig.SES_ROOT_MENUID, rootMenuid);
			model.put(CommonConfig.SES_ROOT_MENU_COMPLIST, menuCompList);			
			model.put(CommonConfig.SES_ROOT_SUB_MENULIST, subList);
			model.put(CommonConfig.SES_ROOT_SUB_MENU, subMenuId);
			
			model.put("data","OK");
		}	

		return JSON_VIEW;
	}
	
	@RequestMapping("/common/json/rootSubList.*")
	public String rootSubList(HttpSession session, HttpServletRequest request, Map model) throws SQLException {
		//DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		BaseUser user = (BaseUser)session.getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
		
		if(user != null){
			List<DataMap> subList = (List)session.getAttribute(CommonConfig.SES_ROOT_SUB_MENULIST);
			String subMenuId = (String)session.getAttribute(CommonConfig.SES_ROOT_SUB_MENU);
			
			model.put(CommonConfig.SES_ROOT_SUB_MENULIST, subList);
			model.put(CommonConfig.SES_ROOT_SUB_MENU, subMenuId);
			
			model.put("data","OK");
		}	

		return JSON_VIEW;
	}
	
	@RequestMapping("/common/json/rootSubMenu.*")
	public String rootSubMenu(HttpSession session, HttpServletRequest request, Map model) throws SQLException {
		//DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		BaseUser user = (BaseUser)session.getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
		
		if(user != null){
			String subMenuId = (String)session.getAttribute(CommonConfig.SES_ROOT_SUB_MENU);
			
			model.put(CommonConfig.SES_ROOT_SUB_MENU, subMenuId);
			
			model.put("data","OK");
		}	

		return JSON_VIEW;
	}
	
	@RequestMapping("/common/ROOT/list/json/MENU_LIST.*")
	public String ROOT_LIST(HttpSession session, HttpServletRequest request, Map model) throws SQLException{		
		//DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		BaseUser user = (BaseUser)session.getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
		
		if(user != null){
			List<DataMap> rootList = (List)session.getAttribute(CommonConfig.SES_ROOT_COMP_MENULIST);
			
			model.put("data", rootList);		
		}		
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/common/ROOT/list/json/COMP_LIST.*")
	public String COMP_LIST(HttpSession session, HttpServletRequest request, Map model) throws SQLException{		
		//DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		BaseUser user = (BaseUser)session.getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
		
		if(user != null){
			List<DataMap> compList = (List)session.getAttribute(CommonConfig.SES_ROOT_COMP_LIST);
			
			model.put("data", compList);
		}		
		
		return JSON_VIEW;
	}

	@RequestMapping("/common/json/password.*")
	public String password(HttpSession session, HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		String encPw =  map.getString("PASSWD");//암호화된 비밀번호를 받는다.
		String encPw_new =  map.getString("PASSWD1");//암호화된 비밀번호를 받는다.
		String decPw = null;
		String decPw_new = null;
		
		String password = "";
		String password_new = "";
		try {
			decPw = RSA.decryptRsa((PrivateKey) request.getSession().getAttribute("__rsaPrivateKey__"), encPw);
			decPw_new = RSA.decryptRsa((PrivateKey) request.getSession().getAttribute("__rsaPrivateKey__"), encPw_new);
			
		} catch (Exception e1) {
			log.error(e1.getMessage());
			model.put("data", "F_LOGIN_RSA");
			return JSON_VIEW;
		}//암호화된 비밀번호를 복호화한다.
		
		try {
			//사용자 입력값 암호화
			password = ShaUtil.toSha256String(decPw);
			password_new = ShaUtil.toSha256String(decPw_new);
			
		} catch(Exception e) {
			password = "";
		}
		
		//현재 비밀번호 내역 조회
		map.put("PASSWD", password);
		DataMap rs = commonService.getMap("Common.PASSWORD", map);
		
		if(rs != null){
			//이전 비빌번호가 같을 경우
			map.put("PASSWD1", password_new);
			DataMap chkBeforeUse = commonService.getMap("Common.CHKUSEPW", map);
			
			if(chkBeforeUse != null){
				int checkUseCount = Integer.parseInt(chkBeforeUse.getString("CNT"));
				log.debug("checkUseCount : " + checkUseCount);
				if(checkUseCount > 0){
					model.put("data", "F_PWD_BEFVAL");
					return JSON_VIEW;
				}
			}
			chkBeforeUse.clear();
			map.put("PASSWD1", password_new);
			map.setModuleCommand("Common", "INITPW");
			commonService.update(map);
			model.put("data", "S");
		}else{
			model.put("data", "F");
		}
		rs.clear();
		map.clear();
		return JSON_VIEW;
	}

	@RequestMapping("/common/json/logout.*")
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
		}
		map.clear();
		return "/index";
	}
	
	@RequestMapping("/common/left.*")
	public String leftMenu(HttpSession session, HttpServletRequest request, Map model) throws SQLException {

		List<DataMap> list = (List) session.getAttribute(CommonConfig.SES_USER_MENU_KEY);

		model.put("list", list);

		return "/common/left";
	}
	
	@RequestMapping("/common/json/addFmenu.*")
	public String addFmenu(HttpSession session, HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		commonService.insert("Common.MSTMENUFL", map);
		map.clear();
		model.put("data", true);

		return JSON_VIEW;
	}
	
	@RequestMapping("/common/json/deleteFmenu.*")
	public String deleteFmenu(HttpSession session, HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		commonService.delete("Common.MSTMENUFL", map);
		map.clear();
		model.put("data", true);

		return JSON_VIEW;
	}
	
	@RequestMapping("/common/json/idPsFind.*")
	@Transactional(rollbackFor = Exception.class)
	public String idPsFind(HttpSession session, HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		String find = map.getString("FIND");
		String send = map.getString("FIND_SEND");
		String passWord = null;
		DataMap row = new DataMap();
		DataMap psData = new DataMap();
		DataMap pMsgMap = new DataMap();
		DataMap logMap = new DataMap();
		
		map.setModuleCommand("Common", "USERINFO");
		
		List<DataMap> infoList =  commonService.getList(map);
		
		if(infoList.size() == 0){
			model.put("data", find+"_NOTHING");
		}else{
			
			for (int i = 0; i < infoList.size(); i++) {
				row = infoList.get(i).getMap("map");
//				String dd = Keygen.makeRandomPassword(5);
				//String gg = infoList.get(i). //.toString("USERID");
				
				if(send.equals("EMAIL")){
					DataMap emailMap = row;
					
					final MimeMessagePreparator preparator = new MimeMessagePreparator() {
						@Override
						public void prepare(MimeMessage mimeMessage) throws Exception {
							final MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true, "UTF-8");
							// TODO Auto-generated method stub
							String cnts = "<p style='font-family:'맑은 고딕'> [G-HUB 시스템]<br><br>";
							
							helper.setFrom("gclcbl@greencross.com");
							helper.setTo(emailMap.getString("USERG3"));
							
							if(find.equals("ID")){
								helper.setSubject("[G-HUB 시스템] 요청하신 아이디 안내입니다."); 
								cnts += "요청하신 아이디 안내입니다.<br><br>";
								cnts += "▶ 아이디 : "+ emailMap.getString("USERID") + "<br><br>";
								cnts += "비밀번호가 기억나지 않는 경우 비밀번호 찾기에서 임시비밀번호를 발급받아 로그인 하실 수 있습니다.<br><br>";
								cnts += "감사합니다.";
							}else if(find.equals("PS")){
								helper.setSubject("[G-HUB 시스템] 요청하신 비밀번호 안내입니다."); 
								String mailPassWord = Keygen.makeRandomPassword(5);
								emailMap.setModuleCommand("Common", "USER_PS");
								emailMap.put("PASSWORD", mailPassWord);
								commonService.update(emailMap);
								
								cnts += "요청하신 아이디/비밀번호 안내입니다. <br><br>";
								cnts += "▶  임시비밀번호 : "+ mailPassWord + "<br><br>";
								cnts += "임시비밀번호로 로그인 하신 후 새로운 비밀번호로 변경하여 사용하시기 바랍니다. <br><br>";
								cnts += "감사합니다.";
							}
							cnts += "</p>";
							helper.setText("content\ndata", cnts); 

							logMap.put("COMPID", emailMap.getString("COMPID"));
							logMap.put("SENDG_EMAIL", "gclcbl@greencross.com");
							logMap.put("RCV_EMAIL", emailMap.getString("USERG3"));
							logMap.put("TITLE", "[G-HUB 시스템]");
							logMap.put("CNTS", cnts);
							logMap.put("REG_ID", "SYSTEM");
						}
					};

					emailMap.clear();
					model.put("data", "S") ;
					
				}else if(send.equals("PNUM")){
					String cnts = "[G-HUB 시스템]\n요청하신 ";
					
					if(find.equals("ID")){
						pMsgMap.put("SUBJECT", "아이디찾기");
						cnts += "아이디 안내입니다.\n\n";
						cnts += "▶ 아이디 : "+ row.getString("USERID");
					}else if(find.equals("PS")){
						pMsgMap.put("SUBJECT", "비밀번호찾기");
						passWord = Keygen.makeRandomPassword(5);
						
						row.setModuleCommand("Common", "USER_PS");
						row.put("PASSWORD", passWord);
						commonService.update(row);
						
						cnts += "비밀번호 안내입니다.\n\n";
						cnts += "▶  임시비밀번호 : "+ passWord;
					}
					
					pMsgMap.put("TEXT", cnts);
					pMsgMap.put("DSTADDR", row.getString("TELNUM"));
					pMsgMap.setModuleCommand("Common", "ID_MSG_SEND");
					commonService.insert(pMsgMap);
					
					model.put("data", "S");
					
				}else if(send.equals("PS_SEARCH")){
					psData = infoList.get(i);
					model.put("data", "PS_SEARCH");
					model.put("dataMap", psData);
					
					break;
				}
			}
		}
		row.clear();
		pMsgMap.clear();
		logMap.clear();
		infoList.clear();
		map.clear();
		return JSON_VIEW;
	}
}