package com.wms.controller;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import com.common.bean.CommonConfig;
import com.common.controller.BaseController;
import com.common.service.CommonService;
import com.common.util.SqlUtil;
import com.common.bean.DataMap;
import com.wms.service.InboundService;

@Controller
public class InboundController extends BaseController {
	
	private static Logger log = Logger.getLogger(InboundController.class);
	
	@Autowired
	private InboundService inboundService;	
	
	@Autowired
	private CommonService commonService;
	
	@RequestMapping("/wms/inbound/json/SaveAS01.*")
	public String saveAs01(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = inboundService.saveAs01(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	
	@RequestMapping("/wms/inbound/json/AS02Delete.*")
	public String deleteAs02(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = inboundService.deleteAs02(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/inbound/json/SaveGR02.*")
	public String saveGr02(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = inboundService.saveGr02(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	@RequestMapping("/wms/inbound/json/SaveGR14.*")
	public String saveGr14(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = inboundService.saveGr14(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/inbound/json/SaveGR01.*")
	public String saveGr01(HttpServletRequest request, Map model) throws Exception{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = inboundService.saveGr01(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/inbound/json/SaveGR00.*")
	public String SaveGR00(HttpServletRequest request, Map model) throws Exception{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = inboundService.saveGr00(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/inbound/json/ReflectGR01Item.*")
	public String reflectGr01Item(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = inboundService.reflectGr01Item(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/inbound/json/SaveGR01POP2.*")
	public String saveGr01pop2(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = inboundService.saveGr01pop2(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/inbound/json/SaveGR05.*")
	public String saveGr05(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = inboundService.saveGr05(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/inbound/json/SaveGR06.*")
	public String saveGr06(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = inboundService.saveGr06(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	/*@RequestMapping("/wms/inbound/json/SaveGR15.*")
	public String saveGr15(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = inboundService.saveGr15(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}*/
	
	@RequestMapping("/wms/inbound/json/GR10Delete.*")
	public String deleteGr10(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = inboundService.deleteGr10(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/inbound/json/saveGr20.*")
	public String saveGr20(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = inboundService.saveGr20(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/inbound/json/saveGr03.*")
	public String saveGr03(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = inboundService.saveGr03(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/inbound/json/saveGr15.*")
	public String saveGr15(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = inboundService.saveGr15(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/inbound/json/SendSMS.*")
	public String SendSMS(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = inboundService.SendSMS(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/inbound/json/savePrtseq.*")
	public String savePrtseq(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = inboundService.savePrtseq(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/inbound/json/deleteGR09.*")
	public String deleteGR09(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = inboundService.deleteGR09(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/inbound/json/validationGR09.*")
	public String validationGR09(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		//System.out.println("controll start!!!");
		Object data = inboundService.validationGR09(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	
		@RequestMapping("/wms/inbound/json/ebelnGR02.*")
		public String ebelnGR02(HttpServletRequest request, Map model) throws SQLException, InterruptedException{		
			DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
			SqlUtil sqlutil = new SqlUtil();
			List keyList= new ArrayList();
			
				map.setModuleCommand("WmsInbound", "GR02");
				keyList.add("PO.EBELN");
				DataMap rangeMap = map.getMap(CommonConfig.RNAGE_DATA_MAP);
				DataMap newRange = sqlutil.createRangeMap(rangeMap, keyList);
				sqlutil.changeRangeKey(newRange, "PO.EBELN", "PO.USRID3");
				String rangeSql1 = sqlutil.getRangeSql(newRange);

				map.put("RANGE_SQL1", rangeSql1);
			
			String listData = commonService.getJdbcData(map);

			model.put("data", listData);
			
			return TEXT_VIEW;
		}
		
		@RequestMapping("/wms/inbound/json/ebelnGR09.*")
		public String ebelnGR09(HttpServletRequest request, Map model) throws SQLException, InterruptedException{		
			DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
			SqlUtil sqlutil = new SqlUtil();
			List keyList= new ArrayList();
			
				map.setModuleCommand("WmsInbound", "GR09");
				keyList.add("RI.SEBELN");
				DataMap rangeMap = map.getMap(CommonConfig.RNAGE_DATA_MAP);
				DataMap newRange = sqlutil.createRangeMap(rangeMap, keyList);
				sqlutil.changeRangeKey(newRange, "RI.SEBELN", "LOTA07");
				String rangeSql1 = sqlutil.getRangeSql(newRange);

				map.put("RANGE_SQL1", rangeSql1);
			
			String listData = commonService.getJdbcData(map);

			model.put("data", listData);
			
			return TEXT_VIEW;
		}
		
		@RequestMapping("/wms/inbound/json/gr01HeadList.*")
		public String gr01HeadList(HttpServletRequest request, Map model) throws SQLException{
			DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
			
			log.debug("############### InboundController gr01HeadList START ###################");
			log.debug(map);
			log.debug("############### InboundController gr01HeadList END ###################");

			
			Object data = inboundService.gr01HeadList(map);

			model.put("data", data);
			model.put("MSG", "OK");

			return JSON_VIEW;
		}
		
		@RequestMapping("/wms/inbound/json/gr01SubList.*")
		public String gr01SubList(HttpServletRequest request, Map model) throws SQLException{
			DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
			
			log.debug("############### InboundController gr01HeadList START ###################");
			log.debug(map);
			log.debug("############### InboundController gr01HeadList END ###################");

			
			Object data = inboundService.gr01SubList(map);

			model.put("data", data);
			model.put("MSG", "OK");

			return JSON_VIEW;
		}
		
		@RequestMapping("/wms/inbound/json/BARCDInsert.*")
		public String BARCDInsert(HttpServletRequest request, Map model) throws SQLException{				
			DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
			
			Object data = inboundService.BARCDInsert(map);
			
			model.put("data", data);
			
			return JSON_VIEW;
		}
		
		
		
		@RequestMapping("/wms/inbound/json/saveGR98EXCEL.*")
		public String saveGR98EXCEL(HttpServletRequest request, Map model) throws Exception{
			DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
			Object data = inboundService.saveGR98EXCEL(map);
			model.put("data", data);
			return JSON_VIEW;
		}
		
		@RequestMapping("/wms/inbound/json/updateGR98EXCEL.*")
		public String updateGR98EXCEL(HttpServletRequest request, Map model) throws Exception{
			DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
			Object data = inboundService.updateGR98EXCEL(map);
			model.put("data", data);
			return JSON_VIEW;
		}
		
		@RequestMapping("/wms/inbound/json/saveGR98.*")
		public String saveGR98(HttpServletRequest request, Map model) throws Exception{
			DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
			Object data = inboundService.saveGR98(map);
			model.put("data", data);
			return JSON_VIEW;
		}
		
}
