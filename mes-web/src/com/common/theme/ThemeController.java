package com.common.theme;

import java.sql.SQLException;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import com.common.bean.CommonConfig;
import com.common.bean.DataMap;
import com.common.controller.BaseController;
import com.common.service.CommonService;

@Controller
public class ThemeController extends BaseController {
	
	private static Logger log = Logger.getLogger(ThemeController.class);
	
	@RequestMapping("/theme/siwms/{page}.*")
	public String page(@PathVariable String page){
		return "/siwms/"+page;
	}
	
	@RequestMapping("/theme/siwms/{module}/{page}.*")
	public String mpage(@PathVariable String module, @PathVariable String page){
		
		return "/siwms/"+module+"/"+page;
	}
}