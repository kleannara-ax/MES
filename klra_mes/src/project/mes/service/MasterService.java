package project.mes.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import project.common.bean.CommonConfig;
import project.common.bean.DataMap;
import project.common.dao.CommonDAO;
import project.common.service.CommonService;
import project.mes.util.CommonUtil;
import project.mes.bean.DataMesMap;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@Service
public class MasterService {
    static final Logger log = LogManager.getLogger(MasterService.class.getName());
    @Autowired
    CommonDAO commonDao;

    @Autowired
    CommonService commonService;

    @Transactional
    public String saveCC01(DataMap map) throws SQLException {

        List<DataMap> head = map.getList("head");
        List<DataMap> list = map.getList("list");

        DataMap headRow = new DataMap();
        DataMap row = new DataMap();

        String result = "HHT_T0008";

        for (int i = 0; i < head.size(); i++) {
            headRow = head.get(i).getMap("map");
            headRow.setModuleCommand("mes", "CC01");
            headRow.put(CommonConfig.SES_USER_ID_KEY,  map.get(CommonConfig.SES_USER_ID_KEY));

            if (headRow.get("STATUS").toString().equals("R")) {
                continue;
            } else if (headRow.get("STATUS").toString().equals("C")) {
                commonDao.insert(headRow);
            } else if (headRow.get("STATUS").toString().equals("U")) {
                commonDao.delete(headRow);
                commonDao.insert(headRow);
            } else {
                commonDao.delete(headRow);
                row = head.get(i).getMap("map");
                row.setModuleCommand("mes", "CC01Sub");
                row.put(CommonConfig.SES_USER_ID_KEY,  map.get(CommonConfig.SES_USER_ID_KEY));
                commonDao.delete(row);
            }
            headRow.clear();
        }
        head.clear();
        
        for (int j = 0; j < list.size(); j++) {
            row = list.get(j).getMap("map");
            row.setModuleCommand("mes", "CC01Sub");
            row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
            if (row.get("STATUS").toString().equals("R")) {
                continue;
            } else if (row.get("STATUS").toString().equals("C")) {
                commonDao.insert(row);
            } else if (row.get("STATUS").toString().equals("U")) {
                commonDao.delete(row);
                commonDao.insert(row);
            } else {
                commonDao.delete(row);
            }
        }
        row.clear();
        list.clear();
        return result;
    }

    @Transactional
    public Object codeMasterAction(DataMap param) throws SQLException, JsonProcessingException {
        try {
            DataMesMap dataMesMap = CommonUtil.convert(param, "");
            CommonUtil.mapToJson(dataMesMap);
            dataMesMap.setModuleCommand("mes", "CODE_MASTER");
            String pJson = CommonUtil.mapToJson(dataMesMap);
            dataMesMap.put("P_JSON", pJson);
            dataMesMap.put("P_TYPE", "SAVE");
            commonService.getMap(dataMesMap);
            List<DataMap> list = new ArrayList<>();
            if (dataMesMap.containsKey("P_RS")) {
                list = dataMesMap.getList("P_RS");
            }
            dataMesMap.clear();
            return list;
        }catch (SQLException e) {
           log.error(e);
        }

        return "PROCESS_ERROR";
    }
}
