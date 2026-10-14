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
import com.mobile.service.MobileOutboundPickingService;
import com.mobile.service.MobilePutawayService;

@Controller
public class MobileOutboundPickingController extends BaseController {
	
	static final Logger log = LogManager.getLogger(MobileOutboundPickingController.class.getName());

	@Autowired
	private CommonService commonService;
	
	@Autowired
	private CommonLabel commonLabel;	
	
	@Autowired
	private MobileOutboundPickingService mobileOutboundPickingService;
	
	@RequestMapping("/mobile/Mobile/json/PDPK01SKU.*")
	public String makeTaskNomal_PDMV04(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("WmsMobileOutboundPicking", "PDPK01SKU");
		
		Object data = commonService.getList(map);
				
		model.put("data", data);

		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/PDPK01SKUCNT.*")
	public String PDPK01SKUCNT(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("WmsMobileOutboundPicking", "PDPK01SKUCNT");
		
		Object data = commonService.getMap(map);
				
		model.put("data", data);

		return JSON_VIEW;
	}

	@RequestMapping("/mobile/Mobile/json/ConfirmPickingPDPK01.*")
	public String ConfirmPickingPDPK01(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
			
		Object data = mobileOutboundPickingService.ConfirmPickingPDPK01(map);
				
		model.put("data", data);

		return JSON_VIEW;
	} 
	
	@RequestMapping("/mobile/Mobile/json/PDPK01CNT.*")
	public String PDPK01CNT(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("WmsMobileOutboundPicking", "PDPK01CNT");
		Object data = commonService.getMap(map);
				
		model.put("data", data);

		return JSON_VIEW;
	} 
	
	@RequestMapping("/mobile/Mobile/json/PDPK01SUBCNT.*")
	public String PDPK01SUBCNT(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("WmsMobileOutboundPicking", "PDPK01SUBCNT");
		Object data = commonService.getMap(map);
				
		model.put("data", data);

		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/PDPK01ITEMLIST.*")
	public String GR01ITEMLIST(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("WmsMobileOutboundPicking", "PDPK01ALSTKY");
		
		Object data = commonService.getList(map);
				
		model.put("data", data);

		return JSON_VIEW;	
	}
	
	@RequestMapping("/mobile/Mobile/json/PDPK01UOM.*")
	public String PDPK01UOM(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("WmsMobileOutboundPicking", "PDPK01UOM");
		Object data = commonService.getMap(map);
				
		model.put("data", data);

		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/PDPK02SKU.*")
	public String PDPK02SKU(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("WmsMobileOutboundPicking", "PDPK02SKU");
		
		Object data = commonService.getList(map);
				
		model.put("data", data);

		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/PDPK02SKUCNT.*")
	public String PDPK02SKUCNT(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("WmsMobileOutboundPicking", "PDPK02SKUCNT");
		
		Object data = commonService.getMap(map);
				
		model.put("data", data);

		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/PDPK02CNT.*")
	public String PDPK02CNT(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("WmsMobileOutboundPicking", "PDPK02CNT");
		Object data = commonService.getMap(map);
				
		model.put("data", data);

		return JSON_VIEW;
	} 
	
	@RequestMapping("/mobile/Mobile/json/PDPK02SUBCNT.*")
	public String PDPK02SUBCNT(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("WmsMobileOutboundPicking", "PDPK02SUBCNT");
		Object data = commonService.getMap(map);
				
		model.put("data", data);

		return JSON_VIEW;
	}  
	
	@RequestMapping("/mobile/Mobile/json/PDPK02UOM.*")
	public String PDPK02UOM(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("WmsMobileOutboundPicking", "PDPK02UOM");
		Object data = commonService.getMap(map);
				
		model.put("data", data);

		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/ConfirmPickingPDPK02.*")
	public String ConfirmPickingPDPK02(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
			
		Object data = mobileOutboundPickingService.ConfirmPickingPDPK02(map);
				
		model.put("data", data);

		return JSON_VIEW;
	} 
	
	
	@RequestMapping("/mobile/Mobile/json/PDPKRM01SKUCNT.*")
	public String PDPKRM01SKUCNT(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("WmsMobileOutboundPicking", "PDPKRM01SKUCNT");
		
		Object data = commonService.getMap(map);
				
		model.put("data", data);

		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/PDPKRM01CNT.*")
	public String PDPKRM01CNT(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("WmsMobileOutboundPicking", "PDPKRM01CNT");
		Object data = commonService.getMap(map);
				
		model.put("data", data);

		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/PDPK01Save.*")
	public String PDPK01Save(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
			
		Object data = mobileOutboundPickingService.PDPK01Save(map);
				
		model.put("data", data);

		return JSON_VIEW;
	} 
	
	@RequestMapping("/mobile/Mobile/json/PDPKRM01SUBCNT.*")
	public String PDPKRM01SUBCNT(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("WmsMobileOutboundPicking", "PDPKRM01SUBCNT");
		Object data = commonService.getMap(map);
				
		model.put("data", data);

		return JSON_VIEW;
	} 
	
	@RequestMapping("/mobile/Mobile/json/PDPKRM01UOM.*")
	public String PDPKRM01UOM(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map.setModuleCommand("WmsMobileOutboundPicking", "PDPKRM01UOM");
		Object data = commonService.getMap(map);
				
		model.put("data", data);

		return JSON_VIEW;
	}
	
	@RequestMapping("/mobile/Mobile/json/ConfirmPickingPDPKRM01.*")
	public String ConfirmPickingPDPKRM01(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
			
		Object data = mobileOutboundPickingService.ConfirmPickingPDPKRM01(map);
				
		model.put("data", data);

		return JSON_VIEW;
	} 
	
	@RequestMapping("/mobile/Mobile/json/PDPKRM01SKU.*")
	public String PDPKRM01SKU(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("WmsMobileOutboundPicking", "PDPKRM01SKU");
		Object data = commonService.getList(map);
				
		model.put("data", data);

		return JSON_VIEW;
	} 
	
	@RequestMapping("/mobile/Mobile/json/PDPKRM01QTSWRK.*")
	public String PDPKRM01QTSWRKCNT(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		Object data = mobileOutboundPickingService.PDPKRM01QTSWRK(map);
		model.put("data", data);
		return JSON_VIEW;
	} 
	
	@RequestMapping("/mobile/Mobile/json/PDPKRM01QTSAVBCNT.*")
	public String PDPKRM01QTSAVBCNT(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		Object data = mobileOutboundPickingService.PDPKRM01QTSAVBCNT(map);
		model.put("data", data);
		return JSON_VIEW;
	} 
	
	@RequestMapping("/mobile/Mobile/json/PDPKRM01SHPINFO.*")
	public String PDPKRM01SHPINFO(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		Object data = mobileOutboundPickingService.PDPKRM01SHPINFO(map);
		model.put("data", data);
		return JSON_VIEW; 
	} 
	
	@RequestMapping("/mobile/Mobile/json/PDPKRM01QTUALOCNT.*")
	public String PDPKRM01QTUALOCNT(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		int qtualo = mobileOutboundPickingService.PDPKRM01QTUALOCNT(map);
		model.put("CNT", qtualo);
		return JSON_VIEW; 
	} 
	
	@RequestMapping("/mobile/Mobile/json/PickingInfoPDPKRM01.*")
	public String PickingInfoPDPKRM01(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		Object data = mobileOutboundPickingService.PickingInfoPDPKRM01(map);
		model.put("data", data);
		return JSON_VIEW; 
	}
	
	@RequestMapping("/mobile/Mobile/json/SavePDDL05.*")
	public String SavePDDL05(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		Object data = mobileOutboundPickingService.SavePDDL05(map);
		model.put("data", data);
		return JSON_VIEW;
	}
	
}
