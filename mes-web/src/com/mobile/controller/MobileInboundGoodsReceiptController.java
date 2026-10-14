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
import com.mobile.service.MobileInboundGoodsReceiptService;
import com.mobile.service.MobileService;

@Controller
public class MobileInboundGoodsReceiptController extends BaseController {

	static final Logger log = LogManager.getLogger(MobileInboundGoodsReceiptController.class.getName());

	@Autowired
	private CommonService commonService;

	@Autowired
	private MobileService mobileService;

	@Autowired
	private MobileInboundGoodsReceiptService mobileInboundGoodsReceiptService;

	@RequestMapping("/mobile/mobileInboundGoodsReceipt/json/SavePDGR01.*")
	public String savePDGR01(HttpServletRequest request, Map model) throws Exception{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object data = mobileInboundGoodsReceiptService.savePDGR01(map);

		model.put("data", data);

		return JSON_VIEW;
	}

	@RequestMapping("/mobile/mobileInboundGoodsReceipt/json/SavePDGR01_POP.*")
	public String savePDGR01_POP(HttpServletRequest request, Map model) throws Exception{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object data = mobileInboundGoodsReceiptService.savePDGR01_POP(map);

		model.put("data", data);

		return JSON_VIEW;
	}

	@RequestMapping("/mobile/mobileInboundGoodsReceipt/json/SavePDGR02.*")
	public String savePDGR02(HttpServletRequest request, Map model) throws Exception{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = mobileInboundGoodsReceiptService.savePDGR02(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/mobileInboundGoodsReceipt/json/GR01ITEMLIST.*")
	public String GR01ITEMLIST(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("WmsMobileInboundGoodsReceipt", "GR01ITEMLIST");
		
		Object data = commonService.getList(map);
				
		model.put("data", data);

		return JSON_VIEW;	
	}
	
	@RequestMapping("/mobile/mobileInboundGoodsReceipt/json/GR02ITEMLIST.*")
	public String GR02ITEMLIST(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("WmsMobileInboundGoodsReceipt", "GR02ITEMLIST");
		
		Object data = commonService.getList(map);
				
		model.put("data", data);

		return JSON_VIEW;

	}
}