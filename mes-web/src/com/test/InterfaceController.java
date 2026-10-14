package com.test;

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
import com.common.service.CommonService;

@Controller
public class InterfaceController extends BaseController {
	
	private static Logger log = Logger.getLogger(InterfaceController.class);
	
	@Autowired
	private CommonService commonService;
	
	@Autowired
	private InterfaceService interfaceService;
	
	@RequestMapping("/master/json/seller.*")
	public String insertSeller(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		interfaceService.seller(map, model);
		log.info(model);
		return JSON_VIEW;
	}
	
	
	@RequestMapping("/master/json/category.*")
	public String insertCategory(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		interfaceService.category(map, model);
		
		log.info(model);
		
		return JSON_VIEW;
	}
	
	
	
	@RequestMapping("/master/json/skuinfo.*")
	public String insertSukinfo(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		interfaceService.skuinfo(map, model);
	
		log.info(model);

		return JSON_VIEW;
	}
	
	
	
	@RequestMapping("/master/json/bigdeal.*")
	public String insertBigdeal(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		interfaceService.bigdeal(map, model);

		log.info(model);
		
		return JSON_VIEW;
	}
	
	
	
	@RequestMapping("/master/json/skuaddinfo.*")
	public String insertSkuaddinfo(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		interfaceService.skuaddinfo(map, model);
		
		
		log.info(model);
		
		return JSON_VIEW;
	}
	
	
	@RequestMapping("/master/json/skustatus.*")
	public String insertSkustatus(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		interfaceService.skustatus(map, model);
		
		log.info(model);
		
		return JSON_VIEW;
	}
	
	
// recevie asn	
	@RequestMapping("/inbound/json/asn.*")
	public String insertAsn(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		interfaceService.asn(map, model);
		
		
		log.info(model);

		
		return JSON_VIEW;
	}

		
	
	// returnasn
		@RequestMapping("/inbound/json/returnasn.*")
		public String insertReturnAsn(HttpServletRequest request, Map model) throws SQLException{		
			DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

			Object data = interfaceService.returnAsn(map);
			
			
			log.info(map.get("RESULT"));
			
			model.put("data", data);
			
			return JSON_VIEW;
		}
}