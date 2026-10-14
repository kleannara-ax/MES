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
public class ReportController extends BaseController {
	
	private static Logger log = Logger.getLogger(ReportController.class);
	@Autowired
	private CommonService commonService;
	
	@RequestMapping("/wms/report/json/ebelnRL19.*")
	public String ebelnRL19(HttpServletRequest request, Map model) throws SQLException, InterruptedException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		SqlUtil sqlutil = new SqlUtil();
		List keyList= new ArrayList();
		
			map.setModuleCommand("WmsReport", "RL19");
			keyList.add("EBELN");
			DataMap rangeMap = map.getMap(CommonConfig.RNAGE_DATA_MAP);
			DataMap newRange = sqlutil.createRangeMap(rangeMap, keyList);
			sqlutil.changeRangeKey(newRange, "EBELN", "SEBELN");
			String rangeSql1 = sqlutil.getRangeSql(newRange);

			map.put("RANGE_SQL1", rangeSql1);
		
		sqlutil.changeRangeKey(newRange, "SEBELN", "LOTA07");
		String rangeSql2 = sqlutil.getRangeSql(newRange);
		
		map.put("RANGE_SQL2", rangeSql2);
		
		sqlutil.changeRangeKey(newRange, "LOTA07", "USRID3");
		String rangeSql3 = sqlutil.getRangeSql(newRange);
		
		map.put("RANGE_SQL3", rangeSql3);
		
		String listData = commonService.getJdbcData(map);

		model.put("data", listData);
		
		return TEXT_VIEW;
	}
}