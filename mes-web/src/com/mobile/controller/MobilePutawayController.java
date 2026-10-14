package com.mobile.controller;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import com.common.bean.CommonConfig;
import com.common.bean.CommonLabel;
import com.common.bean.DataMap;
import com.common.bean.User;
import com.common.controller.BaseController;
import com.common.service.CommonService;
import com.mobile.service.MobilePutawayService;

@Controller
public class MobilePutawayController extends BaseController {
	
	static final Logger log = LogManager.getLogger(MobilePutawayController.class.getName());

	@Autowired
	private CommonService commonService;

	@Autowired
	private MobilePutawayService mobilePutawayService;
	
	@Autowired
	private CommonLabel commonLabel;	
	
	@RequestMapping("/mobile/MobilePutaway/json/makeTaskNomal_PDMV04.*")
	public String makeTaskNomal_PDMV04(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobilePutawayService.makeTaskNomal_PDMV04(map);
				
		model.put("data", data);

		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/MobilePutaway/json/PDPT01SKUCNT.*")
	public String PDPT01SKUCNT(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("WmsMobilePutaway", "PDPT01SKUCNT");
		
		Object data = commonService.getMap(map);
				
		model.put("data", data);

		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/MobilePutaway/json/PDPT01CNT.*")
	public String PDPT01CNT(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("WmsMobilePutaway", "PDPT01CNT");
		Object data = commonService.getMap(map);
				 
		model.put("data", data);

		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/MobilePutaway/json/PDPT01SUBCNT.*")
	public String PDPT01SUBCNT(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("WmsMobilePutaway", "PDPT01SUBCNT");
		Object data = commonService.getMap(map);
				
		model.put("data", data);

		return JSON_VIEW;
	}

	@RequestMapping("/mobile/MobilePutaway/json/PDPT01.*")
	public String PDPT01(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("WmsMobilePutaway", "PDPT01");
		
		Object data = commonService.getList(map);
				
		model.put("data", data);

		return JSON_VIEW;
	}

	@RequestMapping("/mobile/MobilePutaway/json/savePDPT01POP.*")
	public String savePDPT01POP(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
			
		Object data = mobilePutawayService.savePDPT01POP(map);
				
		model.put("data", data);

		return JSON_VIEW;
	} 
	
}