package com.aprove.controller;

import java.sql.SQLException;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import com.aprove.service.AproveService;
import com.common.bean.CommonConfig;
import com.common.bean.DataMap;
import com.common.controller.BaseController;
import com.common.dao.CommonDAO;

@Controller
public class AproveController extends BaseController {
	
	private static Logger log = Logger.getLogger(AproveController.class);
	
	@Autowired
	public CommonDAO commonDao;
	
	@Autowired
	public AproveService aproveService;

	@RequestMapping("/aprove/{page}.*")
	public String page(@PathVariable String page){
		return "/aprove/"+page;
	}
	
	@RequestMapping("/aprove/{module}/{page}.*")
	public String mpage(@PathVariable String module, @PathVariable String page){
		
		return "/aprove/"+module+"/"+page;
	}
	
	@RequestMapping("/aprove/{module}/{sub}/{page}.*")
	public String spage(@PathVariable String module, @PathVariable String sub, @PathVariable String page){
		
		return "/aprove/"+module+"/"+sub+"/"+page;
	}
	
	@RequestMapping("/aprove/insert/json/FWAPL.*")
	public String FWAPLInsert(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		commonDao.insert("Aprove.FWAPRM0010", map);
		commonDao.insert("Aprove.FWAPRI0010", map);
		
		model.put("data", "OK");
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/aprove/update/json/FWAPL.*")
	public String FWAPLUpdate(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		commonDao.update("Aprove.FWAPRM0010", map);
		commonDao.update("Aprove.FWAPRI0010", map);
		
		model.put("data", "OK");
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/aprove/insert/json/FWAPR.*")
	public String FWAPRInsert(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object APRKEY = commonDao.insert("Aprove.FWAPRM0010", map);
		map.put("APRKEY", APRKEY);
		commonDao.insert("Aprove.FWAPRI0010", map);
		
		model.put("data", APRKEY);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/aprove/view/page/FWAPR.*")
	public String FWAPRView(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		map = commonDao.getMap("Aprove.FWAPRM0010", map);
		
		model.putAll(map);
		
		return map.getString("APPATH");
	}
	
	@RequestMapping("/aprove/update/json/FWAPI.*")
	public String FWAPIUpdate(HttpServletRequest request, Map model) throws SQLException{		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		int count = aproveService.updateFWAPI(map);
		
		model.put("data", count);
		
		return JSON_VIEW;
	}
}