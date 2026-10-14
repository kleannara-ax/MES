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
import com.wms.service.OrderService;

@Controller
public class OrderController extends BaseController {
	
	private static Logger log = Logger.getLogger(OrderController.class);
	
	@Autowired
	private OrderService OrderService;	
	
	@RequestMapping("/wms/order/json/saveOM01.*")
	public String saveOM01(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = OrderService.saveOM01(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/order/json/saveIO01.*")
	public String saveIO01(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = OrderService.saveIO01(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/order/json/saveIO05.*")
	public String saveIO05(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = OrderService.saveIO05(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/order/json/saveOM05.*")
	public String saveOM05(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = OrderService.saveOM05(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/order/json/saveOM03.*")
	public String saveOM03(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = OrderService.saveOM03(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	

	@RequestMapping("/wms/order/json/savePrtseq.*")
	public String savePrtseq(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = OrderService.savePrtseq(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/order/json/validationIO05.*")
	public String validationIO05(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		System.out.println("controll start!!!");
		Object data = OrderService.validationIO05(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/order/json/validationIO02.*")
	public String validationIO02(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		DataMap data = OrderService.validationIO02(map);
		
		model.putAll(data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/order/json/saveIO02.*")
	public String saveIO02(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = OrderService.saveIO02(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	// [OM02] 출고오더 Excel 업로드
	@RequestMapping("/wms/order/json/validationOM02.*")
	public String validationOM02(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		DataMap data = OrderService.validationOM02(map);
		
		model.putAll(data);
		
		return JSON_VIEW;
	}

	@RequestMapping("/wms/order/json/saveOM02.*")
	public String saveOM02(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = OrderService.saveOM02(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}

	@RequestMapping("/wms/order/json/skuDesc.*")
	public String skuDescIO02(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		DataMap data = OrderService.skuDesc(map);
		
		model.put("data",data);
		
		return JSON_VIEW;
	}
}