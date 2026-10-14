package com.wms.controller;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import com.common.bean.CommonConfig;
import com.common.controller.BaseController;
import com.common.service.CommonService;
import com.common.util.SqlUtil;
import com.common.bean.DataMap;
import com.wms.service.InventoryService;

@Controller
public class InventoryController extends BaseController {
	
	private static Logger log = Logger.getLogger(InventoryController.class);
	
	@Autowired
	private InventoryService inventoryService;	
	
	@Autowired
	private CommonService commonService;
	
		
	@RequestMapping("/wms/inventory/json/saveAdjd.*")
	public String saveAdjd(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = inventoryService.saveAdjd(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/inventory/json/saveAdjd03.*")
	public String saveAdjd03(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = inventoryService.saveAdjd03(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/inventory/json/savePhyd.*")
	public String savePhyd(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = inventoryService.savePhyd(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/inventory/json/savePhyd02.*")
	public String savePhyd02(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = inventoryService.savePhyd02(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/inventory/json/savePrtseq.*")
	public String savePrtseq(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = inventoryService.savePrtseq(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}

	@RequestMapping("/wms/inventory/json/confirmIP02.*")
	public String confirmIP02(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = inventoryService.confirmIP02(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/inventory/json/validationIP02.*")
	public String validationIP02(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = inventoryService.validationIP02(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/inventory/json/areaSD02.*")
	public String datalist(HttpServletRequest request, Map model) throws SQLException, InterruptedException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		String opt = map.getString("OPT");
		
		SqlUtil sqlutil = new SqlUtil();
		List keyList= new ArrayList();
		
		if(opt.equals("")){ //sd02
			map.setModuleCommand("WmsInventory", "STKKY");
			keyList.add("AREAKY");
			DataMap rangeMap = map.getMap(CommonConfig.RNAGE_DATA_MAP);
			DataMap newRange = sqlutil.createRangeMap(rangeMap, keyList);
			sqlutil.changeRangeKey(newRange, "AREAKY", "SLGORT");
			String rangeSql1 = sqlutil.getRangeSql(newRange);

			map.put("RANGE_SQL1", rangeSql1);
		}else{
			map.setModuleCommand("WmsInventory", "SD01TAB"+opt);
			keyList.add("S.AREAKY");
			DataMap rangeMap = map.getMap(CommonConfig.RNAGE_DATA_MAP);
			DataMap newRange = sqlutil.createRangeMap(rangeMap, keyList);
			sqlutil.changeRangeKey(newRange, "S.AREAKY", "S.SLGORT");
			String rangeSql1 = sqlutil.getRangeSql(newRange);

			map.put("RANGE_SQL1", rangeSql1);
		}
		
		
		String listData = commonService.getJdbcData(map);

		model.put("data", listData);
		
		return TEXT_VIEW;
	}
	
	@RequestMapping("/wms/inventory/json/areaSD03.*")
	public String areaSD03(HttpServletRequest request, Map model) throws SQLException, InterruptedException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		String opt = map.getString("OPT");
		
		SqlUtil sqlutil = new SqlUtil();
		List keyList= new ArrayList();
		
		map.setModuleCommand("WmsInventory", "SD03TAB"+opt);
		keyList.add("S.AREAKY");
		DataMap rangeMap = map.getMap(CommonConfig.RNAGE_DATA_MAP);
		DataMap newRange = sqlutil.createRangeMap(rangeMap, keyList);
		sqlutil.changeRangeKey(newRange, "S.AREAKY", "S.SLGORT");
		String rangeSql1 = sqlutil.getRangeSql(newRange);

		map.put("RANGE_SQL1", rangeSql1);
		
		sqlutil.changeRangeKey(newRange, "S.SLGORT", "S.LGORT");
		String rangeSql2 = sqlutil.getRangeSql(newRange);
		
		map.put("RANGE_SQL2", rangeSql2);
		
		String listData = commonService.getJdbcData(map);

		model.put("data", listData);
		
		return TEXT_VIEW;
	}
	
	@RequestMapping("/wms/inventory/json/areaSD05.*")
	public String areaSD05(HttpServletRequest request, Map model) throws SQLException, InterruptedException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		String opt = map.getString("OPT");
		
		SqlUtil sqlutil = new SqlUtil();
		List keyList= new ArrayList();
	
		map.setModuleCommand("WmsInventory", "SD05");
		keyList.add("AREAKY");
		DataMap rangeMap = map.getMap(CommonConfig.RNAGE_DATA_MAP);
		DataMap newRange = sqlutil.createRangeMap(rangeMap, keyList);
		sqlutil.changeRangeKey(newRange, "AREAKY", "SLGORT");
		String rangeSql1 = sqlutil.getRangeSql(newRange);

		map.put("RANGE_SQL1", rangeSql1);
		
		String listData = commonService.getJdbcData(map);

		model.put("data", listData);
		
		return TEXT_VIEW;
	}
}