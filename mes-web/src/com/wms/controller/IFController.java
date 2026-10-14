package com.wms.controller;

import java.sql.SQLException;
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
import com.common.bean.DataMap;
import com.wms.service.IFService;

@Controller
public class IFController extends BaseController {
	
	private static Logger log = Logger.getLogger(IFController.class);
	
	@Autowired
	private IFService service;	
	
	@RequestMapping("/IF/list/json/{command}.*")
	public String list(HttpServletRequest request, @PathVariable String command, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("IF", command);
		
		List list = service.getList(map);
		
		model.put("data", list);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/IF/map/json/{command}.*")
	public String map(HttpServletRequest request, @PathVariable String command, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("IF", command);
		
		Map data = service.getMap(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/IF/insert/json/{command}.*")
	public String insert(HttpServletRequest request, @PathVariable String command, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("IF", command);

		Object data = service.insert(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/IF/update/json/{command}.*")
	public String update(HttpServletRequest request, @PathVariable String command, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("IF", command);

		int rs = service.update(map);
		
		model.put("data", rs);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/IF/delete/json/{command}.*")
	public String delete(HttpServletRequest request, @PathVariable String command, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("IF", command);

		int rs = service.delete(map);
		
		model.put("data", rs);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/IF/{module}/excel/{command}.*")
	public String excel(HttpServletRequest request, @PathVariable String module, @PathVariable String command, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);

		String data = service.getListString(map);
		
		return excelView(map, model, data);
	}
}