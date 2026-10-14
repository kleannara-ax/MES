package com.wms.controller;

import java.sql.SQLException;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.common.bean.CommonConfig;
import com.common.controller.BaseController;
import com.common.bean.DataMap;
import com.wms.service.AdminService;

@Controller
public class AdminController extends BaseController {

	private static Logger log = Logger.getLogger(AdminController.class);

	@Autowired
	private AdminService adminService;

	@RequestMapping("/wms/admin/json/saveSM01.*")
	public String saveSM01(HttpServletRequest request,
			@RequestParam(value = "areama", required = false) String areama,
			Map model) throws SQLException {
		DataMap map = (DataMap) request
				.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object data = adminService.saveSM01(map);

		model.put("data", data);

		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/admin/json/saveSM02.*")
	public String saveSM02(HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		Object data = adminService.saveSM02(map);
		model.put("data", data);
		return JSON_VIEW;
	}

	@RequestMapping("/wms/admin/json/saveSP01.*")
	public String saveSP01(HttpServletRequest request,
			@RequestParam(value = "areama", required = false) String areama,
			Map model) throws SQLException {
		DataMap map = (DataMap) request
				.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object data = adminService.saveSP01(map);

		model.put("data", data);

		return JSON_VIEW;
	}

	@RequestMapping("/wms/admin/json/validationSK01.*")
	public String validationSK01(HttpServletRequest request, Map model)
			throws SQLException {
		DataMap map = (DataMap) request
				.getAttribute(CommonConfig.PARAM_ATT_KEY);
		System.out.println("controll start!!!");
		Object data = adminService.validationSK01(map);

		model.put("data", data);

		return JSON_VIEW;

	}

	@RequestMapping("/wms/admin/json/validationSP01.*")
	public String validationSP01(HttpServletRequest request, Map model)
			throws SQLException {
		DataMap map = (DataMap) request
				.getAttribute(CommonConfig.PARAM_ATT_KEY);
		System.out.println("controll start!!!");
		Object data = adminService.validationSP01(map);

		model.put("data", data);

		return JSON_VIEW;

	}

	@RequestMapping("/wms/admin/json/saveSK01.*")
	public String saveSK01(HttpServletRequest request, Map model)
			throws SQLException {
		DataMap map = (DataMap) request
				.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object data = adminService.saveSK01(map);

		model.put("data", data);

		return JSON_VIEW;

	}

	/**
	 * 고객오더/창간 오더 정보 저장
	 * 
	 * @param request
	 * @param model
	 * @return
	 * @throws SQLException
	 */
	@RequestMapping("/wms/admin/json/saveCC01.*")
	public String saveCC01(HttpServletRequest request, Map model)
			throws SQLException {
		DataMap map = (DataMap) request
				.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object data = adminService.saveCC01(map);

		model.put("data", data);

		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/admin/json/saveRC01.*")
	public String saveRC01(HttpServletRequest request, Map model)
			throws SQLException {
		DataMap map = (DataMap) request
				.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object data = adminService.saveRC01(map);

		model.put("data", data);

		return JSON_VIEW;
	}

	@RequestMapping("/wms/admin/json/saveTA01.*")
	public String saveTA01(HttpServletRequest request, Map model)
			throws SQLException {
		DataMap map = (DataMap) request
				.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object data = adminService.saveTA01(map);

		model.put("data", data);

		return JSON_VIEW;
	}

	@RequestMapping("/wms/admin/json/saveTP01.*")
	public String saveTP01(HttpServletRequest request, Map model)
			throws SQLException {
		DataMap map = (DataMap) request
				.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object data = adminService.saveTP01(map);

		model.put("data", data);

		return JSON_VIEW;
	}

	@RequestMapping("/wms/admin/json/NR01.*")
	public String saveNR01(HttpServletRequest request, Map model)
			throws SQLException {
		DataMap map = (DataMap) request
				.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object data = adminService.saveNR01(map);

		model.put("data", data);

		return JSON_VIEW;
	}

	@RequestMapping("/wms/admin/json/TF01.*")
	public String saveTF01(HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object data = adminService.saveTF01(map);
		model.put("data", data);

		return JSON_VIEW;
	}

	@RequestMapping("/wms/admin/json/delTF01.*")
	public String delTF01(HttpServletRequest request, Map model)
			throws SQLException {
		DataMap map = (DataMap) request
				.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object data = adminService.delTF01(map);

		model.put("data", data);

		return JSON_VIEW;
	}

	@RequestMapping("/wms/admin/json/saveTS01.*")
	public String saveTS01(HttpServletRequest request, Map model)
			throws SQLException {
		DataMap map = (DataMap) request
				.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object data = adminService.saveTS01(map);

		model.put("data", data);

		return JSON_VIEW;
	}

	@RequestMapping("/wms/admin/json/sendSynch.*")
	public String sendSynch(HttpServletRequest request, Map model)
			throws SQLException {
		DataMap map = (DataMap) request
				.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object data = adminService.sendSynch(map);

		model.put("data", data);

		return JSON_VIEW;
	}

	@RequestMapping("/wms/admin/json/sendSynch2.*")
	public String sendSynch2(HttpServletRequest request, Map model)
			throws SQLException {
		DataMap map = (DataMap) request
				.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object data = adminService.sendSynch2(map);

		model.put("data", data);

		return JSON_VIEW;
	}

	@RequestMapping("/wms/admin/json/validationSA01.*")
	public String validationSA01(HttpServletRequest request, Map model)
			throws SQLException {
		DataMap map = (DataMap) request
				.getAttribute(CommonConfig.PARAM_ATT_KEY);
		System.out.println("controll start!!!");
		Object data = adminService.validationSA01(map);

		model.put("data", data);

		return JSON_VIEW;
	}

	@RequestMapping("/wms/admin/json/saveSK03.*")
	public String saveSK03(HttpServletRequest request, Map model)
			throws SQLException {
		DataMap map = (DataMap) request
				.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object data = adminService.saveSK03(map);

		model.put("data", data);

		return JSON_VIEW;

	}

	@RequestMapping("/wms/admin/json/updateIF01.*")
	public String updateIF01(HttpServletRequest request, Map model)
			throws SQLException {
		DataMap map = (DataMap) request
				.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object data = adminService.updateIF01(map);
		model.put("data", data);

		return JSON_VIEW;

	}

	@RequestMapping("/wms/admin/json/checkIF01.*")
	public String checkIF01(HttpServletRequest request, Map model)
			throws SQLException {
		DataMap map = (DataMap) request
				.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object data = adminService.checkIF01(map);

		model.put("data", data);

		return JSON_VIEW;

	}

	@RequestMapping("/wms/admin/json/SaveMR01.*")
	public String saveGr01(HttpServletRequest request, Map model)
			throws Exception {
		DataMap map = (DataMap) request
				.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object data = adminService.saveMr01(map);

		model.put("data", data);

		return JSON_VIEW;
	}

	@RequestMapping("/wms/admin/json/delTS01.*")
	public String delTS01(HttpServletRequest request, Map model)
			throws SQLException {
		DataMap map = (DataMap) request
				.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object data = adminService.delTS01(map);

		model.put("data", data);

		return JSON_VIEW;
	}

	@RequestMapping("/wms/admin/json/delTR01.*")
	public String delTR01(HttpServletRequest request, Map model)
			throws SQLException {
		DataMap map = (DataMap) request
				.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object data = adminService.delTR01(map);

		model.put("data", data);

		return JSON_VIEW;
	}

	@RequestMapping("/wms/admin/json/saveMA01.*")
	public String delMA01(HttpServletRequest request, Map model)
			throws SQLException {
		DataMap map = (DataMap) request
				.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object data = adminService.saveMA01(map);

		model.put("data", data);

		return JSON_VIEW;
	}

	@RequestMapping("/wms/admin/json/saveMZ01.*")
	public String delMZ01(HttpServletRequest request, Map model)
			throws SQLException {
		DataMap map = (DataMap) request
				.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object data = adminService.saveMZ01(map);

		model.put("data", data);

		return JSON_VIEW;
	}

	@RequestMapping("/wms/admin/json/saveML01.*")
	public String saveML01(HttpServletRequest request, Map model)
			throws SQLException {
		DataMap map = (DataMap) request
				.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object data = adminService.saveML01(map);

		model.put("data", data);

		return JSON_VIEW;
	}

	@RequestMapping("/wms/admin/json/saveMB01.*")
	public String saveMB01(HttpServletRequest request, Map model)
			throws SQLException {
		DataMap map = (DataMap) request
				.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object data = adminService.saveMB01(map);

		model.put("data", data);

		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/admin/json/DeleteMB01.*")
	public String DeleteMB01(HttpServletRequest request, Map model) throws SQLException{				
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = adminService.DeleteMB01(map);
		
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/admin/json/createTF01.*")
	public String createTF01(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = adminService.createTF01(map);
		model.put("data", data);
		
		return JSON_VIEW;
	}

	@RequestMapping("/wms/admin/json/deleteTF01.*")
	public String deleteTF01(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = adminService.deleteTF01(map);
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/admin/json/createTS01.*")
	public String createTS01(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = adminService.createTS01(map);
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/admin/json/deleteTS01.*")
	public String deleteTS01(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = adminService.deleteTS01(map);
		model.put("data", data);
		
		return JSON_VIEW;
	}

	@RequestMapping("/wms/admin/json/createTS02.*")
	public String createTS02(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = adminService.createTS02(map);
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/admin/json/deleteTS02.*")
	public String deleteTS02(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = adminService.deleteTS02(map);
		model.put("data", data);
		
		return JSON_VIEW;
	}

	@RequestMapping("/wms/admin/json/saveTS02.*")
	public String saveTS02(HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object data = adminService.saveTS02(map);
		model.put("data", data);

		return JSON_VIEW;
	}

	@RequestMapping("/wms/admin/json/saveTR02.*")
	public String saveTR02(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = adminService.saveTR02(map);
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/admin/json/saveDT01.*")
	public String saveDT01(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = adminService.saveDT01(map);
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/admin/json/saveMS01.*")
	public String saveMS01(HttpServletRequest request, Map model) throws SQLException{
		
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = adminService.saveMS01(map);
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
	@RequestMapping("/wms/admin/json/saveDT02.*")
	public String saveDT02(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		Object data = adminService.saveDT02(map);
		model.put("data", data);
		
		return JSON_VIEW;
	}
	
}