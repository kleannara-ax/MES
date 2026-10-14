package project.mes.controller.work;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import project.common.bean.CommonConfig;
import project.common.bean.DataMap;
import project.common.controller.BaseController;
import project.common.service.CommonService;
import project.mes.controller.MesController;
import project.mes.service.MesService;
import project.mes.service.work.ProcResultService;

@Controller
public class ProcResultController extends BaseController{
	
	private static Logger log = Logger.getLogger(MesController.class);
	
	@Autowired
	private ProcResultService procResultService;

	//공정별 실적 조회
	@RequestMapping("/mes/Work/WRK52_procResult/json/procResultList.data")
	public String GetProcResultList(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		List<DataMap> list = procResultService.findProcResultList(map);
		
		map.clear();
		model.put("data", list);
		
		return JSON_VIEW;
	}
}
