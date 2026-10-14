
package com.mobile.controller;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import com.common.bean.CommonConfig;
import com.common.bean.CommonLabel;
import com.common.bean.DataMap;
import com.common.bean.FileRepository;
import com.common.bean.User;
import com.common.controller.BaseController;
import com.common.service.CommonService;
import com.mobile.service.MobileService;

@Controller
public class MobileController extends BaseController {
	
	private static Logger log = Logger.getLogger(MobileController.class);

	@Autowired
	private CommonService commonService;

	@Autowired
	private MobileService mobileService;
	
	@Autowired
	private CommonLabel commonLabel;
	
	@Autowired
	private FileRepository respository;
	
	@RequestMapping("/mobile/{page}.*")
	public String page(@PathVariable String page){
		return "/mobile/"+page;
	}
	
	@RequestMapping("/mobile/{module}/{page}.*")
	public String mpage(@PathVariable String module, @PathVariable String page) throws SQLException{
		return "/mobile/"+module+"/"+page;
	}
	
	@RequestMapping("/mobile/index.*")
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
		
		return "/mobile/index";
	}
	
	@RequestMapping("/mobile/json/login.*")
	public String login(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("Common", "LOGIN");

		User user = (User)commonService.getObj(map);
		
		if(user != null){
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
			
			map.setModuleCommand("Common", "USRPHC");
			list = commonService.getList(map);
			DataMap usrph = new DataMap();
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
			}
			
			user.setUsrph(usrph);
			
			request.getSession().setAttribute(CommonConfig.SES_USER_OBJECT_KEY, user);
			request.getSession().setAttribute(CommonConfig.SES_USER_ID_KEY, user.getUserid());
			request.getSession().setAttribute(CommonConfig.SES_USER_NAME_KEY, user.getNmlast());
			request.getSession().setAttribute(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.getString("WAREKY"));
			request.getSession().setAttribute(CommonConfig.SES_USER_OWNER_KEY, user.getOwner());
			request.getSession().setAttribute(CommonConfig.SES_USER_COMPANY_KEY, user.getCompky());
			request.getSession().setAttribute(CommonConfig.SES_USER_LANGUAGE_KEY, map.getString("LANGKY"));
			
			model.put("data", "S");
			
			log.debug(user);
		}else{
			model.put("data", "F");
		}	
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/main.*")
	public String main(HttpServletRequest request, Map model) throws SQLException{
		
		String langky = request.getSession().getAttribute(CommonConfig.SES_USER_LANGUAGE_KEY).toString();
		
		//model.put("label", commonLabel.getLabel(langky));
		//model.put("message", commonLabel.getMessage(langky));
		
		return "/mobile/main";
	}

	@RequestMapping("/mobile/Mobile/json/updateMIP02Sub.*")
	public String updateMIP02Sub(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		
		Object data = mobileService.updateMIP02Sub(map);
				
		model.put("data", data);

		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/SaveMMV01.*")
	public String SaveMMV01(HttpServletRequest request, Map model) throws SQLException, Exception{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.saveMMV01(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}

	
	@RequestMapping("/mobile/Mobile/json/SaveMGR01_whyfail.*")
	public String SaveMGR01_whyfail(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.SaveMGR01_whyfail(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/SaveMGR01.*")
	public String SaveMGR01(HttpServletRequest request, Map model) throws Exception{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.SaveMGR01(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/SaveMGR06.*")
	public String SaveMGR06(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.SaveMGR06(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/SaveMGR06_whyfail.*")
	public String SaveMGR06_whyfail(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.SaveMGR06_whyfail(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/SaveMGR09.*")
	public String saveMgr09(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.saveMGR09(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/SaveMDL07.*")
	public String saveMdl07(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.saveMDL07(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/SaveMGR20.*")
	public String SaveMGR20(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		Object data = mobileService.SaveMGR20(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/SaveMDL06.*")
	public String SaveMDL06(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.SaveMDL06(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/SaveMTO07.*")
	public String SaveMTO07(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.SaveMTO07(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/LocakyCheck.*")
	public String LocakyCheck(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.LocakyCheck(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	
	@RequestMapping("/mobile/Mobile/json/validateMobileDailyCheck.*")
	public String validateMobileDailyCheck(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.validateMobileDailyCheck(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/checkLota05.*")
	public String checkLota05(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.checkLota05(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/usrname.*")
	public String usrname(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.usrname(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}

	@RequestMapping("/mobile/json/logout.*")
	public String logout(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		request.getSession().removeAttribute(CommonConfig.SES_USER_OBJECT_KEY);
		request.getSession().removeAttribute(CommonConfig.SES_USER_ID_KEY);
		request.getSession().removeAttribute(CommonConfig.SES_USER_NAME_KEY);
		request.getSession().removeAttribute(CommonConfig.SES_USER_WHAREHOUSE_KEY);
		request.getSession().removeAttribute(CommonConfig.SES_USER_OWNER_KEY);
		request.getSession().removeAttribute(CommonConfig.SES_USER_COMPANY_KEY);
		
		return "/mobile/index";
	}
	
	@RequestMapping("/mobile/Mobile/json/SaveMDL20.*")
	public String SaveMDL20(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.SaveMDL20(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/SaveRegino.*")
	public String SaveRegino(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.SaveRegino(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/SaveRtnRegino.*")
	public String SaveRtnRegino(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.SaveRtnRegino(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/SaveMGR02.*")
	public String SaveMGR02(HttpServletRequest request, Map model) throws Exception{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.SaveMGR02(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/SaveMPT01.*")
	public String SaveMPT01(HttpServletRequest request, Map model) throws Exception{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.SaveMPT01(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/SaveMPT02.*")
	public String SaveMPT02(HttpServletRequest request, Map model) throws Exception{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.SaveMPT02(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/SaveMIP02.*")
	public String SaveMIP02(HttpServletRequest request, Map model) throws Exception{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.SaveMIP02(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/SaveMDL08.*")
	public String SaveMDL08(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.SaveMDL08(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/SaveMIP04.*")
	public String SaveMIP04(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.SaveMIP04(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/validateMobileShpokyCheck.*")
	public String validateMobileShpokyCheck(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.validateMobileShpokyCheck(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("mobile/Mobile/json/saveMIM01.*")
	public String saveMIM01(HttpServletRequest request, Map model) throws SQLException, IOException {
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.saveMIM01(request, map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/imgFileDelete.*")
	public String imgFileDelete(HttpServletRequest request, Map model) throws FileNotFoundException, IOException, SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.imgFIleDelete(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("mobile/Mobile/json/saveMIM02.*")
	public String saveMIM02(HttpServletRequest request, Map model) throws SQLException, IOException {
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.saveMIM02(request, map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/dnFileDelete.*")
	public String dnFileDelete(HttpServletRequest request, Map model) throws FileNotFoundException, IOException, SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.dnFileDelete(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/saveWKSIGN.*")
	public String saveWKSIGN(HttpServletRequest request, Map model) throws SQLException, IOException {
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileService.saveWKSIGN(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
}