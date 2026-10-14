package com.common.controller;

import java.util.Properties;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.context.event.ContextRefreshedEvent;

import com.common.bean.CommonConfig;
import com.common.bean.CommonLabel;
import com.common.bean.CommonSearch;
import com.common.bean.FileRepository;
import com.common.bean.SystemConfig;
import com.common.service.CommonService;

public class CommonLoad implements ApplicationListener {

	private static Logger log = Logger.getLogger(CommonLoad.class);
	
	@Autowired
	private CommonService commonService;
	
	@Autowired
	private CommonLabel commonLabel;
	
	@Autowired
	private CommonSearch commonSearch;
	
	@Autowired
	private SystemConfig systemConfig;
	
	@Autowired
	private FileRepository respository;
	
	@Resource(name="properties")
	private Properties prop;	
	
	public void onApplicationEvent(ApplicationEvent event){
		if(event instanceof ContextRefreshedEvent){
			try {
				if(respository.getRoot() == null){
					String path = this.getClass().getClassLoader().getResource("/path.properties").getPath();
					path = path.substring(1, path.indexOf("WEB-INF"));
					log.info("path : "+path);
					respository.setRoot(path);
				}
				commonService.loadLabel();
				commonService.loadMessage();
				commonService.loadSearch();
				CommonConfig.SYSTEM_THEME = systemConfig.getTheme();
				CommonConfig.SYSTEM_THEME_PATH = systemConfig.getThemePath();
				
				String sysTitle   = prop.getProperty("system.sysTitle");
				String sysVersion = prop.getProperty("system.sysVersion");
				
				if(sysTitle != null && !"".equals(sysTitle)){
					CommonConfig.SYSTEM_TITLE = sysTitle;
				}else {
					CommonConfig.SYSTEM_TITLE = "WMS";
				}
				if(sysVersion != null && !"".equals(sysVersion)){
					CommonConfig.SYSTEM_VERSION = sysVersion;
				}else {
					CommonConfig.SYSTEM_VERSION = "1.0";
				}
			} catch (Exception e) {
				// TODO Auto-generated catch block
				log.error("onApplicationEvent", e);
			}
			log.debug("Label size : "+commonLabel.getLagelSize());
			log.debug("Message size : "+commonLabel.getMessageSize());
			log.debug("systemConfig : " + systemConfig);
		}
	}
}