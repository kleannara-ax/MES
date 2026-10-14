package com.wms.controller;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import com.common.bean.CommonConfig;
import com.common.bean.DataMap;
import com.common.bean.XmlBean;
import com.common.bean.XmlTableBean;
import com.common.controller.BaseController;
import com.common.service.CommonService;
import com.common.bean.DataMap;

@Controller
public class WmsPdaController extends BaseController {
	
	private static Logger log = Logger.getLogger(WmsPdaController.class);

	@Autowired
	private CommonService commonService;	

	@RequestMapping("/wmsPda/common/xml/login.*")
	public String login(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		XmlBean xmlBean = (XmlBean)map.get("xml");		
		
		if(xmlBean.getXmlTableList().size() == 0){
			model.put("data", xmlBean.getXmlString());
			return TEXT_VIEW;
		}
		
		DataMap requestMap = null;
		if(xmlBean.getXmlTableList().size() > 0){
			XmlTableBean bean = (XmlTableBean)xmlBean.getXmlTableList().get(0);
			requestMap = new DataMap(bean.getRs().get(0));
		}
		
		requestMap.setModuleCommand("WmsPda", "LOGIN");
		
		DataMap data = commonService.getMap(requestMap);		
		
		XmlBean rsBean = new XmlBean();
		
		if(requestMap.getString("PASSWD").equals(data.getString("PASSWD"))){
			requestMap.append(data);
			
			rsBean.addXmlTableList(new XmlTableBean("S", "Succeed."));
				
			requestMap.setModuleCommand("WmsPda", "AREMA");
			List list  = commonService.getList(requestMap);
			rsBean.addXmlTableList(new XmlTableBean("AREMA", list));
			
			requestMap.setModuleCommand("WmsPda", "LOCMA");
			list  = commonService.getList(requestMap);
			rsBean.addXmlTableList(new XmlTableBean("LOCMA", list));
			
			requestMap.setModuleCommand("WmsPda", "UPDATE");
			list  = commonService.getList(requestMap);
			rsBean.addXmlTableList(new XmlTableBean("UPDATE",list));
			
			requestMap.setModuleCommand("WmsPda", "GETDATE");
			list  = commonService.getList(requestMap);
			rsBean.addXmlTableList(new XmlTableBean("SYSDATE", list));
			
			requestMap.setModuleCommand("WmsPda", "HHTMG");
			list  = commonService.getList(requestMap);
			rsBean.addXmlTableList(new XmlTableBean("HHTMG", list));
			
			requestMap.setModuleCommand("WmsPda", "JLBLM");
			list  = commonService.getList(requestMap);
			rsBean.addXmlTableList(new XmlTableBean("JLBLM", list));
			
			requestMap.setModuleCommand("WmsPda", "JMSGM");
			list  = commonService.getList(requestMap);
			rsBean.addXmlTableList(new XmlTableBean("JMSGM", list));
			
			requestMap.setModuleCommand("WmsPda", "DOCTM");
			list  = commonService.getList(requestMap);
			rsBean.addXmlTableList(new XmlTableBean("DOCTM", list));
			
			requestMap.setModuleCommand("WmsPda", "RSNCD");
			list  = commonService.getList(requestMap);
			rsBean.addXmlTableList(new XmlTableBean("RSNCD", list));
			
			requestMap.setModuleCommand("WmsPda", "CMCDV");
			list  = commonService.getList(requestMap);
			rsBean.addXmlTableList(new XmlTableBean("CMCDV", list));
			
			requestMap.setModuleCommand("WmsPda", "WAHMA");
			list  = commonService.getList(requestMap);
			rsBean.addXmlTableList(new XmlTableBean("WAHMA", list));
			
			requestMap.setModuleCommand("WmsPda", "LOGIN");
			data  = commonService.getMap(requestMap);
			rsBean.addXmlTableList(new XmlTableBean("USERMA", data));
		}			
		
		model.put("data", rsBean.getXmlString());
		return TEXT_VIEW;
	}
	
	@RequestMapping("/wmsPda/common/xml/request.*")
	public String common(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		XmlBean xmlBean = (XmlBean)map.get("xml");
		if(xmlBean.getXmlTableList().size() == 0){
			model.put("data", xmlBean.getXmlString());
			return TEXT_VIEW;
		}
		
		XmlTableBean tableBean = (XmlTableBean)xmlBean.getXmlTableList().get(0);
		
		List<DataMap> list = tableBean.getRs();
		if(list.size() == 0){
			model.put("data", xmlBean.getXmlString());
			return TEXT_VIEW;
		}
		
		DataMap param = new DataMap(list.get(0));
		
		String checkid = param.getString("CHCKID");
		
		String type = checkid.substring(checkid.lastIndexOf("_")+1);
		checkid = checkid.substring(0, checkid.lastIndexOf("_"));
		
		DataMap requestMap = null;
		if(xmlBean.getXmlTableList().size() > 1){
			XmlTableBean bean = (XmlTableBean)xmlBean.getXmlTableList().get(1);
			requestMap = new DataMap(bean.getRs().get(0));
		}
		
		requestMap.setModuleCommand("WmsPda", checkid);
		XmlBean rsBean = new XmlBean();
		String resultStr = null;
		if(type.indexOf("LIST") != -1){
			list = commonService.getList(requestMap);
			
			rsBean.addXmlTableList(new XmlTableBean("DATA", list));	
			rsBean.addXmlTableList(new XmlTableBean("S", "Succeed."));
		}else if(type.indexOf("MAP") != -1){
			DataMap data = commonService.getMap(requestMap);
			
			rsBean.addXmlTableList(new XmlTableBean("DATA", data));
			rsBean.addXmlTableList(new XmlTableBean("S", "Succeed."));
		}else if(type.indexOf("INSERT") != -1){
			commonService.insert(requestMap);
			
			rsBean.addXmlTableList(new XmlTableBean("S", "Succeed."));
		}else if(type.indexOf("UPDATE") != -1){
			commonService.update(requestMap);
			
			rsBean.addXmlTableList(new XmlTableBean("S", "Succeed."));
		}else if(type.indexOf("DELETE") != -1){
			commonService.delete(requestMap);
			
			rsBean.addXmlTableList(new XmlTableBean("S", "Succeed."));
		}
		
		resultStr = rsBean.getXmlString();
		
		model.put("data", resultStr);
		
		return TEXT_VIEW;
	}
	
	@RequestMapping("/wmsPda/common/xml/requestTest.*")
	public String commonTest(HttpServletRequest request, Map model) throws SQLException{
		DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		
		XmlBean xmlBean = new XmlBean();
		
		XmlTableBean xmlTableBean = new XmlTableBean();
		xmlTableBean.setName("Test");
		DataMap data = new DataMap();
		data.put("test", "111");
		xmlTableBean.addRs(data);
		xmlBean.addXmlTableList(xmlTableBean);
		
		model.put("data", xmlBean.getXmlString());
		return TEXT_VIEW;
	}
}