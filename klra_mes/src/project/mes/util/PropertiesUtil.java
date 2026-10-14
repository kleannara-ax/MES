package project.mes.util;

import org.springframework.stereotype.Component;
import project.common.bean.CommonConfig;
import project.common.util.FileUtil;

import java.util.Properties;


@Component
public class PropertiesUtil {
    private Properties properties = null;

    private  void fetchProperties() {
        FileUtil fileUtil = new FileUtil();
        try {
            if(CommonConfig.isRealServer()) {
                this.properties = fileUtil.loadProperties(this.getClass().getResource("/").getPath().replace("classes/", "") + "conf", "commonconfig-prod.properties");
            }else {
                this.properties = fileUtil.loadProperties(this.getClass().getResource("/").getPath().replace("classes/", "") + "conf", "commonconfig.properties");
            }
        } catch (Exception e) {
        }
    }

    public String getPropertyValue(String name) {
        if(properties == null) fetchProperties();
        if (properties != null) {
            String ss = properties.getProperty(name);
            if(ss != null) return ss.trim();
            return null;
        }

        return null;
    }

    public static void main(String[] args) {
        PropertiesUtil p = new PropertiesUtil();
        String ss = p.getPropertyValue("sysconfig.log");
        String ss1 = p.getPropertyValue("password.reset1");
        System.out.println(ss);
    }
}
