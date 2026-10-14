package project.mes.util;

import org.springframework.beans.factory.config.PropertyPlaceholderConfigurer;

import java.util.Properties;
import java.io.IOException;
import java.io.InputStream;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.core.io.Resource;
import org.springframework.util.DefaultPropertiesPersister;
import org.springframework.util.PropertiesPersister;
import project.common.bean.CommonConfig;

public class DynamicPropertyPlaceholderConfigurer extends PropertyPlaceholderConfigurer {

    protected final Log log = LogFactory.getLog(getClass());
    protected Properties[] localProperties;
    protected boolean localOverride = false;
    private Resource[] locations;
    private PropertiesPersister propertiesPersister = new DefaultPropertiesPersister();

    public void setLocations(Resource[] locations) {
        this.locations = locations;
    }

    public void setLocalOverride(boolean localOverride) {
        this.localOverride = localOverride;
    }

    protected void loadProperties(Properties props) throws IOException {
        if (locations != null) {
            for (Resource location : this.locations) {
                InputStream is = null;
                try {
                    String filename = location.getFilename();
                    if (CommonConfig.isRealServer() == false && filename.equals("commonconfig.properties")) {
                        //log.info(">>>>>> load dev properties >>>>>>");
                        is = location.getInputStream();
                        this.propertiesPersister.load(props, is);
                    }
                    if (CommonConfig.isRealServer() == true && filename.equals("commonconfig-prod.properties")) {
                        //log.info(">>>>>> load prod properties >>>>>>");
                        is = location.getInputStream();
                        this.propertiesPersister.load(props, is);
                    }
                } catch (IOException ex) {
                    ex.printStackTrace();
                    throw ex;
                } finally {
                    if (is != null) {
                        is.close();
                    }
                }
            }
        }
    }
}
