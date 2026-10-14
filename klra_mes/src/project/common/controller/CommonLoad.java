package project.common.controller;

import javax.annotation.PostConstruct;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;

import project.common.bean.CommonConfig;
import project.common.bean.CommonLabel;
import project.common.bean.FileRepository;
import project.common.bean.SystemConfig;
import project.common.service.CommonService;
import project.mes.service.MesService;
import project.mes.util.Log4jUtil;

public class CommonLoad {

	static final Logger log = LogManager.getLogger(CommonLoad.class.getName());
	@Autowired
	private CommonService commonService;
	
	@Autowired
	private CommonLabel commonLabel;
	
	@Autowired
	private SystemConfig systemConfig;
	
	@Autowired
	private FileRepository respository;

	@Autowired
	private MesService mesService;

	@Autowired
	private Log4jUtil log4jUtil;

	@PostConstruct
    private void init() {
		try {
			log4jUtil.loadLog4j2Config();
			String path = respository.getRoot();
			if(path == null){
				path = this.getClass().getClassLoader().getResource("/path.properties").getPath();
				path = path.substring(0, path.indexOf("WEB-INF"));
				
				log.info("path : "+path);
				respository.setRoot(path);
			}
			commonService.loadLabel();					
			commonService.loadMessage();	
			//commonService.loadSearch();
			CommonConfig.SYSTEM_THEME = systemConfig.getTheme();
			CommonConfig.SYSTEM_THEME_PATH = systemConfig.getThemePath();
			mesService.initInterface(); // 2022-06-27 by fqj
		} catch (Exception e) {
			// TODO Auto-generated catch block
			log.error("onApplicationEvent", e);
		}
		log.debug("Label size : "+commonLabel.getLagelSize());
		log.debug("Message size : "+commonLabel.getMessageSize());
		log.debug("systemConfig : " + systemConfig);
    }
}