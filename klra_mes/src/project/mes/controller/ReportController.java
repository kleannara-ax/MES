package project.mes.controller;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import project.common.bean.CommonConfig;
import project.common.bean.DataMap;
import project.common.controller.BaseController;
import project.common.dao.CommonDAO;
import project.mes.service.ReportService;

@Controller
public class ReportController extends BaseController {
	
	@Autowired
	private ReportService reportService;
	
	@Autowired
	public CommonDAO commonDao;
	
	@RequestMapping("/mes/report/json/savePrtseq_LocBcd.*")
	public String savePrtseq(HttpServletRequest request, Map model) throws Exception{
		
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		String data = reportService.savePrtseq_LocBcd(map);
		
		map.clear();
		model.put("data", data);
		
		return JSON_VIEW;
	}
	/*
	@RequestMapping("/wms/report/json/WSP02PopAsnList.*")
	public String WSP02PopAsnList(HttpServletRequest request, Map model) throws Exception{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.WSP02PopAsnList(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/report/json/savePrtseq_ALL.*")
	public String savePrtseq_ALL(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.savePrtseq_ALL(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/report/json/WIP01_Print.*")
	public String WIP01_Print(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.WIP01_Print(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/report/json/WIR21_Print.*")
	public String WIR21_Print(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.WIR21_Print(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/report/json/WIR21_HappyCall.*")
	public String WIR21_HappyCall(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.WIR21_HappyCall(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/report/json/WIR21rtn_Print.*")
	public String WIR21rtn_Print(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.WIR21rtn_Print(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/report/json/WDP01_Print.*")
	public String WDP01_Print(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.WDP01_Print(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/report/json/WDP02_Print.*")
	public String WDP02_Print(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.WDP02_Print(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/report/json/WOS13_Print.*")
	public String WOS13_Print(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.WOS13_Print(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/report/json/WTK03_Print.*")
	public String WTK03_Print(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.WTK03_Print(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/report/json/WOS11BarPrint.*")
	public String WOS11BarPrint(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.WOS11BarPrint(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/report/json/asnListPrint.*")
	public String asnListPrint(HttpSession session, HttpServletRequest request, Map model) throws Exception{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.asnListPrint(session,map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/report/json/taskListWPT02.*")
	public String taskListWPT02(HttpSession session, HttpServletRequest request, Map model) throws Exception{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.taskListWPT02(session,map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/report/json/taskListWPT03.*")
	public String taskListWPT03(HttpSession session, HttpServletRequest request, Map model) throws Exception{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.taskListWPT03(session,map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/report/json/WMV12_Print.*")
	public String WMV12_Print(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.WMV12_Print(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/report/json/WSJ04_Print.*")
	public String WSJ04_Print(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.WSJ04_Print(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/report/json/WMV11_Print.*")
	public String WMV11_Print(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.WMV11_Print(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/report/json/WPB01_Print.*")
	public String WPB01_Print(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.WPB01_Print(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/report/json/WPB32_Print.*")
	public String WPB32_Print(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.WPB32_Print(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/report/json/WPB31_Print.*")
	public String WPB31_Print(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.WPB31_Print(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/report/json/WIR21_RtnAsn.*")
	public String WIR21_RtnAsn(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.WIR21_RtnAsn(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/report/json/WOS14_Print.*")
	public String WOS14_Print(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.WOS14_Print(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/report/json/WOS14_IndivPrint.*")
	public String WOS14_IndivPrint(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.WOS14_IndivPrint(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/report/json/WSD31_Print.*")
	public String WSD31_Print(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.WSD31_Print(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/report/json/WOS21_PLTPrint.*")
	public String WOS21_PLTPrint(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.WOS21_PLTPrint(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/report/json/WOS24_Print.*")
	public String WOS24_Print(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.WOS24_Print(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/report/json/WDL01_PLTPrint.*")
	public String WDL01_PLTPrint(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.WDL01_PLTPrint(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/report/json/WSQ11_Print.*")
	public String WSQ11_Print(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = reportService.WSQ11_Print(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
    
    *//**
     * [MSK10,MSE10] 물품마스터 바코드 출력
     * [공통] 물품마스터 바코드 출력 
     * 물품마스터 바코드를  출력한다.
     * @param request
     * @param model
     * @return json
     * @throws Exception
     * @service MaterialService
     * @method saveMSK10
     *//*
    @RequestMapping("/wms/report/json/materialPrintBarcode.*")
    public String materialPrintBarcode(HttpSession session, HttpServletRequest request, Map model) throws Exception{                
        DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
        
        Object data = reportService.materialPrintBarcode(session,map);
        
        model.put("data", data);
        
        return JSON_VIEW;
    }
    */
}