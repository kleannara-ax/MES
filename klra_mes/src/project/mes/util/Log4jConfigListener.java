package project.mes.util;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

import org.apache.logging.log4j.core.config.Configurator;
import project.common.bean.CommonConfig;

public class Log4jConfigListener implements ServletContextListener
{
    @Override
    public void contextDestroyed(ServletContextEvent arg0)
    {
    }
    @Override
    public void contextInitialized(ServletContextEvent arg0)
    {
        String fileName = getContextParam(arg0);
        Configurator.initialize(getClass().getName(),null, "classpath:" + fileName);
    }
    @SuppressWarnings("unchecked")
    private String getContextParam(ServletContextEvent event) {
        String value = "log4j2.xml";
        if(CommonConfig.isRealServer()) {
            value = "log4j2-prod.xml";
        }
        return value;
    }
}