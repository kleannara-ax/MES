package com.common.controller;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class SystemController extends BaseController {
	
	private static Logger log = Logger.getLogger(SystemController.class);

	@RequestMapping("/system/{page}.*")
	public String page(@PathVariable String page){
		return "/system/"+page;
	}
	
	@RequestMapping("/system/{module}/{page}.*")
	public String mpage(@PathVariable String module, @PathVariable String page){
		
		return "/system/"+module+"/"+page;
	}
	
	@RequestMapping("/system/{module}/{sub}/{page}.*")
	public String spage(@PathVariable String module, @PathVariable String sub, @PathVariable String page){
		
		return "/system/"+module+"/"+sub+"/"+page;
	}
}