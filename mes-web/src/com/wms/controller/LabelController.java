package com.wms.controller;

import java.sql.SQLException;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.common.bean.CommonConfig;
import com.common.controller.BaseController;
import com.common.bean.DataMap;
import com.wms.service.LabelService;

@Controller
public class LabelController extends BaseController {
	
	private static Logger log = Logger.getLogger(LabelController.class);
	
	@Autowired
	private LabelService labelService;	
	
	@RequestMapping("/wms/labal/json/saveLB01.*")
	public String saveSK01(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = labelService.saveLB01(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
		
	}
	
	@RequestMapping("/wms/labal/json/saveLB01PalletIDSingle.*")
	public String saveLB01PalletIDSingle(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = labelService.saveLB01PalletIDSingle(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/labal/json/PT01PalletIDPrint.*")
	public String PT01PalletIDPrint(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = labelService.PT01PalletIDPrint(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/labal/LB01.*")
	public String LB01pop(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		model.put("param", map);
		
		return "/wms/label/LB01";
	}
}