package com.wms.controller;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import com.common.bean.CommonConfig;
import com.common.bean.DataMap;
import com.common.controller.BaseController;
import com.wms.service.WcsService;

@Controller
public class WcsController extends BaseController {
	
	private static Logger log = Logger.getLogger(WcsController.class);
	
	@Autowired
	private WcsService wcsService;	
	
	
	@RequestMapping("/wms/wcs/json/WS01Save.*")
	public String WS01Save(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		Object data = wcsService.WS01Save(map);
		model.put("data", data);
		return JSON_VIEW;
	}


	@RequestMapping("/wms/wcs/json/WS02Save.*")
	public String WS02Save(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		Object data = wcsService.WS02Save(map);
		model.put("data", data);
		return JSON_VIEW;
	}
	
	
	@RequestMapping("/wms/wcs/json/WCO1save.*")
	public String WCO1procall(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = wcsService.WCO1save(map);
		
		
			model.put("data", data);
			
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/wcs/json/WCO2save.*")
	public String WCO2procall(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = wcsService.WCO2save(map);
		
		
			model.put("data", data);
			
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/wcs/json/WCI1save.*")
	public String WCI1procall(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = wcsService.WCI1save(map);
		
			model.put("data", data);
			
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/wcs/json/WCM2Save.*")
	public String WCM2Save(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		Object data = wcsService.WCM2Save(map);
		model.put("data", data);
		return JSON_VIEW;
	}
}