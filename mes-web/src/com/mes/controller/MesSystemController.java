package com.mes.controller;

import java.sql.SQLException;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import com.common.bean.CommonConfig;
import com.common.bean.DataMap;
import com.common.controller.BaseController;
import com.common.service.SystemService;

@Controller
public class MesSystemController extends BaseController {
	
	private static Logger log = Logger.getLogger(MesSystemController.class);
	
	@Autowired
	private SystemService systemservice;
	
	@RequestMapping("/mes/system/json/UI01.*")
	public String saveUi01(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = systemservice.saveUi01(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mes/master/json/BM01.*")
	public String saveBM01(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = systemservice.saveUi01(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mes/system/json/initPwUI01.*")
	public String resetPWD(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = systemservice.resetPwd(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mes/system/json/YHU01.*")
	public String saveYhu01(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = systemservice.saveYhu01(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
/*	
	@RequestMapping("/mes/system/json/YHI01.*")
	public String saveYhi01(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = systemservice.saveYhi01(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}*/
	
	@RequestMapping("/mes/system/json/UR01.*")
	public String saveUr01(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = systemservice.saveUr01(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mes/system/json/YS01.*")
	public String saveYs01(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = systemservice.saveYs01(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mes/system/json/delYS01.*")
	public String delYs01(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = systemservice.delYs01(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mes/system/json/delYH01.*")
	public String delYH01(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = systemservice.delYH01(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mes/system/json/saveUR01UI.*")
	public String saveUR01UI(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = systemservice.saveUR01UI(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mes/system/json/delUR01WK.*")
	public String delUR01WK(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = systemservice.delUR01WK(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mes/system/json/saveLog.*")
	public String saveRT09CS(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = systemservice.saveLog(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}	
	
	@RequestMapping("/mes/system/json/UM01.*")
	public String saveUM01(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = systemservice.saveUm01(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
}