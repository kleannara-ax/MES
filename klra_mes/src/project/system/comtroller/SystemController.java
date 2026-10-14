package project.system.comtroller;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import project.common.bean.CommonConfig;
import project.common.bean.DataMap;
import project.common.controller.BaseController;
import project.system.service.SystemService;

@Controller
public class SystemController extends BaseController {
	
	static final Logger log = LogManager.getLogger(SystemController.class.getName());
	
	@Autowired
	private SystemService systemService;
	
	@RequestMapping("/system/{page}.*")
	public String page(@PathVariable String page){
		return "/system/"+page;
	}
	
	@RequestMapping("/system/{module}/{page}.*")
	public String mpage(@PathVariable String module, @PathVariable String page){
		
		return "/system/"+module+"/"+page;
	}
	
	@RequestMapping("/system/{module}/{sub}/{page}.*")
	public String spage(@PathVariable String module, @PathVariable String sub, @PathVariable String page){
		
		return "/system/"+module+"/"+sub+"/"+page;
	}
	
	@RequestMapping("/system/json/saveMenu.data")
	public String saveMenu(HttpServletRequest request, Map model) throws Exception{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		int result = systemService.saveMenu(map);
		map.clear();
		model.put("data", result);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/system/json/saveCopyMenu.data")
	public String saveCopyMenu(HttpServletRequest request, Map model) throws Exception{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		int result = systemService.saveCopyMenu(map);
		map.clear();
		model.put("data", result);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/system/json/saveMenuFl.data")
	public String saveMenuFl(HttpServletRequest request, Map model) throws Exception{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		int result = systemService.saveMenuFl(map);
		map.clear();
		model.put("data", result);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/system/json/saveLabel.data")
	public String saveLabel(HttpServletRequest request, Map model) throws Exception{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		int result = systemService.saveLabel(map);
		map.clear();
		model.put("data", result);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/system/json/saveMessage.data")
	public String saveMessage(HttpServletRequest request, Map model) throws Exception{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		int result = systemService.saveMessage(map);
		map.clear();
		model.put("data", result);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/system/json/saveMstMenu.data")
	public String saveMstMenu(HttpServletRequest request, Map model) throws Exception{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		int result = systemService.saveMstMenu(map);
		map.clear();
		model.put("data", result);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/system/json/saveMstMenuG.data")
	public String saveMstMenuG(HttpServletRequest request, Map model) throws Exception{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		int result = systemService.saveMstMenuG(map);
		map.clear();
		model.put("data", result);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/system/json/saveCommonPop.data")
	public String saveCommonPop(HttpServletRequest request, Map model) throws Exception{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		int result = systemService.saveCommonPop(map);
		map.clear();
		model.put("data", result);
		
		return JSON_VIEW;
	}
	/*
	@RequestMapping("/mes/system/json/UI01.*")
	public String saveUi01(HttpServletRequest request, Map model) throws Exception{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = systemService.saveUi01(map);
		map.clear();
		model.put("data", data);
		
		return JSON_VIEW;
	}
	*/
	@RequestMapping("/mes/system/json/initPwUI01.*")
	public String resetPWD(HttpServletRequest request, Map model) throws Exception{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = systemService.resetPwd(map);
		map.clear();
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mes/system/json/saveUR01UI.*")
	public String saveUR01UI(HttpServletRequest request, Map model) throws Exception{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = systemService.saveUR01UI(map);
		map.clear();
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mes/system/json/delUR01WK.*")
	public String delUR01WK(HttpServletRequest request, Map model) throws Exception{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = systemService.delUR01WK(map);
		map.clear();
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/system/json/saveMstMenuGdpt.data")
	public String saveMstMenuGdpt(HttpServletRequest request, Map model) throws Exception{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		int result = systemService.saveMstMenuGdpt(map);
		map.clear();
		model.put("data", result);
		
		return JSON_VIEW;
	}
}