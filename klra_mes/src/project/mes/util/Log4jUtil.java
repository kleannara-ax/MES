package project.mes.util;

import org.apache.logging.log4j.core.config.Configurator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import project.common.bean.CommonConfig;

// 2.
@Component
public class Log4jUtil {
    @Autowired
    private TomcatUtil tomcatUtil;

    public void loadLog4j2Config() {
        try {
            String logConfigurationFile =  "classpath:log4j2.xml";
//            if(CommonConfig.isRealServer()) {
//                logConfigurationFile =  "classpath:log4j2-prod.xml";
//            }
            if(CommonConfig.isRealServer() || CommonConfig.isDevServer()) {
                int port = tomcatUtil.getServerInstance().getPort();
                logConfigurationFile =  "classpath:log4j2-prod.xml";
                if(port != 8005) {
//                    value = "log4j2-prod-2.xml";
                    logConfigurationFile =  "classpath:log4j2-prod-2.xml";
                }
            }
//            File file = ResourceUtils.getFile(logConfigurationFile);
//            InputStream inputStream = new FileInputStream(file);
//            ConfigurationSource source = new ConfigurationSource(inputStream);
//            Configurator.initialize(null, source);
            Configurator.initialize(Log4jUtil.class.getName(),null, logConfigurationFile);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
