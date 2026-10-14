package com.ahcs.controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import com.ahcs.bean.User;
import com.ahcs.service.AhcsService;
import com.ahcs.util.AHCSUtil;
import com.common.bean.CommonConfig;
import com.common.bean.DataMap;
import com.common.bean.TableColumn;
import com.common.controller.BaseController;
import com.common.service.CommonService;
import com.common.util.StringUtility;

@Controller
public class AhcsController extends BaseController {
	
	private static Logger log = Logger.getLogger(AhcsController.class);
	
	@Autowired
	private CommonService commonService;
	
	@Autowired
	private AhcsService ahcsService;
	
	@RequestMapping("/ahcs/index.*")
	public String index(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		return "/ahcs/index";
	}
	
	@RequestMapping("/ahcs/{page}.*")
	public String page(@PathVariable String page){
		return "/ahcs/"+page;
	}
	
	@RequestMapping("/ahcs/{module}/{page}.*")
	public String mpage(@PathVariable String module, @PathVariable String page) throws SQLException{
		
		return "/ahcs/"+module+"/"+page;
	}
	
	@RequestMapping("/ahcs/{module}/{sub}/{page}.*")
	public String spage(@PathVariable String module, @PathVariable String sub, @PathVariable String page) throws SQLException{
		
		return "/ahcs/"+module+"/"+sub+"/"+page;
	}
	
	@RequestMapping("/ahcs/json/login.*")
	public String login(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("AHCS", "LOGIN");
		
		User user = (User)commonService.getObj(map);
		
		if(user != null){
			map.setModuleCommand("AHCS", "MENUTREE");
			List<DataMap> menuList = commonService.getList(map);
			user.setMenuList(menuList);
			AHCSUtil sutil = new AHCSUtil();
			String menuTag = sutil.getMenuTag(menuList);
			
			map.setModuleCommand("AHCS", "MCOM05H");
			List<DataMap> deptList = commonService.getList(map);
			user.setDeptList(deptList);
			
			map.setModuleCommand("Common", "USRLO");
			map.put(CommonConfig.SES_USER_ID_KEY, user.getUserId());
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
			/*
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
			*/
			request.getSession().setAttribute(CommonConfig.SES_USER_OBJECT_KEY, user);
			request.getSession().setAttribute(CommonConfig.SES_USER_ID_KEY, user.getUserId());
			request.getSession().setAttribute(CommonConfig.SES_USER_NAME_KEY, user.getUserNm());
			request.getSession().setAttribute(CommonConfig.SES_USER_COMPANY_KEY, user.getCpId());
			request.getSession().setAttribute(CommonConfig.SES_USER_LANGUAGE_KEY, "KO");
			request.getSession().setAttribute(AHCSUtil.SES_USER_MENULIST_KEY, menuTag);
			
			model.put("data", "S");
			
			log.debug(user);
		}else{
			model.put("data", "F");
		}	
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/ahcs/json/logout.*")
	public String logout(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		request.getSession().removeAttribute(CommonConfig.SES_USER_OBJECT_KEY);
		request.getSession().removeAttribute(CommonConfig.SES_USER_ID_KEY);
		request.getSession().removeAttribute(CommonConfig.SES_USER_NAME_KEY);
		request.getSession().removeAttribute(CommonConfig.SES_USER_WHAREHOUSE_KEY);
		request.getSession().removeAttribute(CommonConfig.SES_USER_OWNER_KEY);
		request.getSession().removeAttribute(CommonConfig.SES_USER_COMPANY_KEY);
		request.getSession().removeAttribute(CommonConfig.SES_USER_INFO_KEY);
		
		//map.setModuleCommand("Common", "LOGOUT");
		//commonService.update(map);
		
		return "/sessionEmpty";
	}
	
	@RequestMapping("/ahcs/json/SQL_COLDIC_LIST.*")
	public String SQL_COLDIC_LIST(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		List list = ahcsService.getSqlDicList(map.getString("sql"));
		
		model.put("data", list);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/ahcs/json/SQL_COLDIC_SAVE.*")
	public String SQL_COLDIC_SAVE(HttpServletRequest request, Map model) throws SQLException, IOException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		DataMap result = ahcsService.sqlColObjSave(map);
		
		model.putAll(result);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/ahcs/json/TABLE_COLOBJ_LIST.*")
	public String TABLE_COLOBJ_LIST(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		List list = ahcsService.getTableSearchObjList(map.getString("INQ_TAB_NM"));
		
		model.put("data", list);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/ahcs/json/SEARCH_COLOBJ_SAVE.*")
	public String SEARCH_COLOBJ_SAVE(HttpServletRequest request, Map model) throws SQLException, IOException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		DataMap result = ahcsService.searchObjSave(map);
		
		model.putAll(result);
		
		return JSON_VIEW;
	}
	

	@RequestMapping("/ahcs/json/SQL_COLOBJ_LIST.*")
	public String SQL_COLOBJ_LIST(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		List list = ahcsService.getSqlSearchObjList(map.getString("sql"));
		
		model.put("data", list);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/ahcs/json/SQL_COLOBJ_SAVE.*")
	public String SQL_COLOBJ_SAVE(HttpServletRequest request, Map model) throws SQLException, IOException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		DataMap result = ahcsService.sqlColObjSave(map);
		
		model.putAll(result);
		
		return JSON_VIEW;
	}
}