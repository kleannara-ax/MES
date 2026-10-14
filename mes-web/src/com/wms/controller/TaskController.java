package com.wms.controller;

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
import com.common.bean.DataMap;
import com.wms.service.TaskService;

@Controller
public class TaskController extends BaseController {
	
	private static Logger log = Logger.getLogger(TaskController.class);
	
	@Autowired
	private TaskService taskService;	
	
	@RequestMapping("/wms/task/json/PT01MasterValidation.*")
	public String PT01MasterValidation(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		String result = taskService.PT01ValueCheck(map);
		model.put("data", result);
		return JSON_VIEW;
	}
	
	
	@RequestMapping("/wms/task/json/PT01StockValidation.*")
	public String PT01StockValidation(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		String result = taskService.PT01StockCheck(map);
		model.put("data", result);
		return JSON_VIEW;
	}
	
//	@RequestMapping("/wms/task/json/PT01LocacValidation.*")
//	public String PT01LocacValidation(HttpServletRequest request, Map model) throws SQLException{				
//		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
//		String result = taskService.PT01LocaacCheck(map);
//		model.put("data", result);
//		return JSON_VIEW;
//	}

	
	@RequestMapping("/wms/task/json/PTLocacValidation.*") 
	public String PTLocacValidation(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		String result = taskService.PTLocaacCheck(map);
		model.put("data", result);
		return JSON_VIEW;
	}	
//	@RequestMapping("/wms/task/json/validateSaveEnd.*")
//	public String validateSaveEnd(HttpServletRequest request, Map model) throws SQLException{				
//		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);	
//		String result = taskService.saveValueEndCheck(map);	
//		model.put("data", result);	
//		return JSON_VIEW;
//	}
		
	@RequestMapping("/wms/task/json/PT01StockSave.*")
	public String PT01StockSave(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = taskService.PT01StockSave(map);
		
		model.put("data", data);

		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/task/json/PT01SaveEnd.*")
	public String PT01SaveEnd(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		Object data = taskService.PT01SaveEnd(map);
		model.put("data", data);
		return JSON_VIEW;
	}

	
	@RequestMapping("/wms/task/json/PT02SaveEnd.*")
	public String PT02SaveEnd(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		Object data = taskService.PT02SaveEnd(map);
		model.put("data", data);
		return JSON_VIEW;
	}
	
	
	
//	@RequestMapping("/wms/outbound/json/PT02Save.*")
//	public String PT02Save(HttpServletRequest request, Map model) throws SQLException{				
//		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
//		
//		Object data = taskService.PT02Save(map);
//		
//		model.put("data", data);
//		
//		return JSON_VIEW;
//	}
	
//	@RequestMapping("/wms/outbound/json/PT02RowSave.*")
//	public String PT02RowSave(HttpServletRequest request, Map model) throws SQLException{				
//		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
//		
//		Object data = taskService.PT02RowSave(map);
//		
//		model.put("data", data);
//		
//		return JSON_VIEW;
//	}
//	
	
	@RequestMapping("/wms/task/json/PT02Delete.*")
	public String PT02Delete(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = taskService.PT02Delete(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	/**
	 * 피킹 완료
	 * @param request
	 * @param model
	 * @return
	 * @throws SQLException
	 */
	
	@RequestMapping("/wms/task/json/PkStockValidation.*")
	public String PkStockValidation(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		String result = taskService.DL06StockCheck(map);
		model.put("data", result);
		return JSON_VIEW;
	}
	
	
	@RequestMapping("/wms/task/json/DL06SaveEnd.*")
	public String DL06SaveEnd(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		Object data = taskService.DL06SaveEnd(map);
		model.put("data", data);
		return JSON_VIEW;
	}

	/**
	 * 재고 이동
	 * @param request
	 * @param model
	 * @return
	 * @throws SQLException
	 */
	@RequestMapping("/wms/task/json/MV01CreatTaskOrder.*")
	public String MV01CreatTaskOrder(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		DataMap data = taskService.createTaskOrder(map);
		
		model.putAll(data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/task/json/savePrtseq.*")
	public String savePrtseq(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = taskService.savePrtseq(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	//기타출고
	@RequestMapping("/wms/task/json/saveTK32.*")
	public String saveTK32(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = taskService.saveTK32(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	//작업오더리스트
	@RequestMapping("/wms/task/json/savePrtseqTK90.*")
	public String savePrtseqTK90(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = taskService.savePrtseqTK90(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/task/json/CompletePT02.*")
	public String CompletePT02(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = taskService.CompletePT02(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/task/json/DeletePT02.*")
	public String DeletePT02(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = taskService.DeletePT02(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/task/json/DeleteDL06.*")
	public String DeleteDL06(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = taskService.DeleteDL06(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/task/json/RecommendLocation.*")
	public String MV01RecommendLocation(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = taskService.RecommendLocation(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
}