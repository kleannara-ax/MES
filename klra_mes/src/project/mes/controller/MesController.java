package project.mes.controller;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import com.fasterxml.jackson.core.JsonProcessingException;

import project.common.airfw.User;
import project.common.bean.CommonConfig;
import project.common.bean.DataMap;
import project.common.controller.BaseController;
import project.common.service.CommonService;
import project.mes.bean.DataMesMap;
import project.mes.service.MesService;
import project.mes.util.CommonUtil;

@Controller
public class MesController extends BaseController {
	
	private static Logger log = Logger.getLogger(MesController.class);
	
	@Autowired
	private CommonService commonService;
	
	@Autowired
	private MesService mesService;
	
	@RequestMapping("/mes/index/{page}.*")
	public String index(HttpServletRequest request, Map model, @PathVariable String page) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("mes", "WAHMACOMBO");
		
		List list = commonService.getList(map);
		
		model.put("WAHMACOMBO", list);
		
		map.setModuleCommand("Common", "COMCOMBO");
		map.put("CODE", "LANGKY");
		
		List list1 = commonService.getList(map);
		
		model.put("LANGKY", list1);
		
		map.setModuleCommand("Common", "LOGINMSG");
		List list2 = commonService.getList(map);
		
		map.clear();
		model.put("MSG", list2);
		
		return "/mes/"+page;
	}
	
	@RequestMapping("/mes/common/json/leftMenu.*")
	public String leftMenu(HttpServletRequest request, Map model) throws SQLException{
		String langky = request.getSession().getAttribute(CommonConfig.SES_USER_LANGUAGE_KEY).toString();
		String userid = request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY).toString();
		
		DataMap map = new DataMap("Common", "MENUTREE");
		map.put("LANGKY", langky);
		map.put("USERID", userid);
		
		List<DataMap> list = commonService.getList(map);
		
		map.clear();
		model.put("list", list);
		
		return "/mes/left";
	}
	
	@RequestMapping("/mes/{page}.*")
	public String page(HttpServletRequest request, Map model, @PathVariable String page) throws SQLException{
		if(page.equals("index")) {
			DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
			map.setModuleCommand("mes", "WAHMACOMBO");
			
			List list = commonService.getList(map);
			
			model.put("WAHMACOMBO", list);
			
			map.put("CODE", "LANGKY");
			
			List list1 = commonService.getList("airfw.COMCOMBO", map);
			
			map.clear();
			model.put("LANGKY", list1);
		}
		return "/mes/"+page;
	}
	
	@RequestMapping("/index.*")
	public String indexPage(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("mes", "WAHMACOMBO");
		
		List list = commonService.getList(map);
		
		model.put("WAHMACOMBO", list);
		
		map.put("CODE", "LANGKY");
		
		List list1 = commonService.getList("airfw.COMCOMBO", map);
		
		model.put("LANGKY", list1);
		
		List list2 = commonService.getList("airfw.LOGINMSG", map);
		
		map.clear();
		model.put("MSG", list2);
		return "/mes/index";
	}
	
	@RequestMapping("/mes/{module}/{page}.*")
	public String mpage(@PathVariable String module, @PathVariable String page){
		
		return "/mes/"+module+"/"+page;
	}
	@RequestMapping("/mes/system/json/saveLog.*")
	public String saveRT09CS(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mesService.saveLog(map);
		
		map.clear();
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mes/common/json/combo.*")
	public String combo(HttpServletRequest request, Map model) throws SQLException, JsonProcessingException{
		DataMesMap map = CommonUtil.convertAll((DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY));
		map.setModuleCommand("mes", "SELECTCOMBO");
		
		commonService.getMap(map);
		
		List<DataMap> list=CommonUtil.processList(map, "P_LIST");
		
		map.clear();
		model.put("data", list);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mes/common/json/changeWareky.*")
	public String login(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("mes", "OWNER");
		
		DataMap data = (DataMap)commonService.getMap(map);
		
		if(data.containsKey("OWNER")){
			User user = (User)request.getSession().getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
			user.setOwner(data.getString("OWNER"));
			request.getSession().setAttribute(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.getString("WAREKY"));
			request.getSession().setAttribute(CommonConfig.SES_USER_OWNER_KEY, user.getOwner());
			
			model.put("data", "S");
		}else{
			model.put("data", "F");
		}
		data.clear();
		map.clear();
		return JSON_VIEW;
	}
	
	/** 재고실사지시 */
	@RequestMapping("/mes/Inv/json/saveIP01.*")
	public String saveIP01(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		Object data = mesService.saveIP01(map);
		model.put("data", data);
		return JSON_VIEW;
	}
}