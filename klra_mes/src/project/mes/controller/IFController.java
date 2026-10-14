package project.mes.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import project.common.bean.CommonConfig;
import project.common.bean.DataMap;
import project.common.controller.BaseController;
import project.common.dao.CommonDAO;
import project.common.service.CommonService;
import project.common.task.InterfaceSchedule;
import project.mes.bean.DataMesMap;
import project.mes.service.IFService;
import project.mes.service.IFServiceMapping;
import project.mes.service.MesService;
import project.mes.util.CommonUtil;
import project.mes.util.PropertiesUtil;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class IFController extends BaseController {
    private static Logger log = Logger.getLogger(IFController.class);
    @Autowired
    private IFService service;
    @Autowired
    private IFServiceMapping ifServiceMapping;
    @Autowired
    private CommonDAO commonDao;
    @Autowired
    private CommonService commonService;
    @Autowired
    private MesService mesService;
    @Resource
    private PropertiesUtil propertiesUtil;

    @RequestMapping("/IF/list/json/{command}.*")
    public String list(HttpServletRequest request, @PathVariable String command, Map<String, Object> model) throws SQLException {
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
        map.setModuleCommand("IF", command);
        List<DataMap> list = commonDao.getList(map);
        map.clear();
        model.put("data", list);
        return JSON_VIEW;
    }

    @RequestMapping("/IF/map/json/{command}.*")
    public String map(HttpServletRequest request, @PathVariable String command, Map<String, Object> model) throws SQLException {
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
        map.setModuleCommand("Erpif", command);
        DataMap data = commonDao.getMap(map);
        if(!"".equals(data.getString("LOGSEQNO"))){
            data.put("LOGSEQNO",mesService.getLogno(data.getString("LOGSEQNO")));
        }
        model.put("data", data);
        map.clear();
        return JSON_VIEW;
    }

    @RequestMapping("/IF/insert/json/{command}.*")
    public String insert(HttpServletRequest request, @PathVariable String command, Map<String, Object> model) throws SQLException {
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
        map.setModuleCommand("IF", command);
        Object data = commonDao.insert(map);
        map.clear();
        model.put("data", data);
        return JSON_VIEW;
    }

    @RequestMapping("/IF/update/json/{command}.*")
    public String update(HttpServletRequest request, @PathVariable String command, Map<String, Object> model) throws SQLException {
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
        map.setModuleCommand("IF", command);
        int rs = commonDao.update(map);
        map.clear();
        model.put("data", rs);
        return JSON_VIEW;
    }

    @RequestMapping("/IF/delete/json/{command}.*")
    public String delete(HttpServletRequest request, @PathVariable String command, Map<String, Object> model) throws SQLException {
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
        map.setModuleCommand("IF", command);
        int rs = commonDao.delete(map);
        map.clear();
        model.put("data", rs);
        return JSON_VIEW;
    }

    // 송신시 화면 데잍터
    @RequestMapping("/ifsend/Erpif/procedure/json/data.data")
    public String ifSendList(HttpServletRequest request, Map model) throws SQLException, JsonProcessingException {
        DataMesMap map = CommonUtil.convertAll((DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY));
        String ifid = map.get("IFID").toString();
        System.out.println("map : " + map);
        DataMap ifMap = ifServiceMapping.geIFMasterValue(ifid);
        String callUrl = ifMap.getString("RFCFN");
        String procName = ifMap.getString("PROCNM");
        String ifTbl = ifMap.getString("IFTBL");
        String sysFr = ifMap.getString("SYSFR");
        String sysTo = ifMap.getString("SYSTO");
        String ifName = ifMap.getString("IFKNM");
        
        ifMap.clear();
        map.setModuleCommand("Erpif", procName);
        List<DataMap> list  = new ArrayList<>();
        if("MES".equals(sysFr) && "WCS".equals(sysTo)) {
            list  = commonDao.getList(map);
        }else {
            if ("MES".equals(sysFr) && "WMS".equals(sysTo)) {
                map.setModuleCommand("Erpif", "SP_IF_PUT_IFSWM00X");
                map.put("PROCNM", procName);
            }
            commonService.getMap(map);
            list = CommonUtil.processList(map, "P_RS_LIST");
        }
        map.clear();
        model.put("data", list);
        return JSON_VIEW;
    }

    //@RequestMapping("/mes/erpif/json/receiveIF.*")
    //public String receiveIF(HttpServletRequest request, Map<String, Object> model) throws SQLException {
    //    DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
    //    String data = null;
    //    DataMap logMap = new DataMap();
    //    String ifid = map.get("ifid").toString();
    //    String logseqno = mesService.insertInterfaceMesLog(ifid, "R");
    //    map.put("logseqno", logseqno);
    //    map.put("REMARK", "EXCEL");
    //    data = service.receive_IF(map);
    //    if (!data.equals("SUCCESS")) {
    //        logMap.put("COMSTAT", "E");
    //        logMap.put("ERRTXT", data);
    //        commonDao.update(logMap);
    //    }
    //    model.put("data", data);
    //    return JSON_VIEW;
    //}


    @Deprecated
    @RequestMapping("/api/erpif/json/sendIF.*")
    public String commonSendIF(HttpServletRequest request, Map<String, String> model) throws SQLException {
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
        String data = null;
        String logseq = mesService.insertInterfaceMesLog(map.getString("IFID"), "S");
        map.put("LOGSEQNO", logseq);
        String rest = map.getString("REST");
        String ifid = map.getString("ifid");
        String sysFr = map.getString("SYSFR");
        String sysTo= map.getString("SYSTO");
        if(org.apache.commons.lang3.StringUtils.isBlank(ifid) && map.getString("IFID")!=null) {
            ifid = map.getString("IFID");
        }
        mesService.startIfMasterCountLog(ifid,logseq);
       List<DataMap> list = map.getList("list"); // 가져와야함
       System.out.println(list);
       map.clear();
       //data = service.sendIF(map, list, true); // 바로 restfull
        mesService.endIfMasterCountLogIFNoError(logseq);
        model.put("data", data);
        return JSON_VIEW;
    }

    @RequestMapping("/mes/erpif/json/sendIF.*")
    public String sendIF(HttpServletRequest request, Map<String, String> model) throws SQLException {
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
        String data = null;
        String docNo = map.getString("DOC_NO");
        if(mesService.notEmptyDocNo(docNo)){
            map.put("DOC_NO", map.getString("DOC_NO"));
        }
        String ifid = map.getString("IFID");
        DataMap ifMap = ifServiceMapping.geIFMasterValue(ifid);
        String procName = ifMap.getString("PROCNM");
        String ifTbl= ifMap.getString("IFTBL");
        String sysFr = ifMap.getString("SYSFR");
        String sysTo = ifMap.getString("SYSTO");
        String ifName = ifMap.getString("IFKNM");
        
        ifMap.clear();
        
        if(org.apache.commons.lang3.StringUtils.isBlank(ifid) && map.getString("IFID")!=null) {
            ifid = map.getString("IFID");
        }
        
        if("MES".equals(sysFr) && "WCS".equals(sysTo)) {
        	String logseq = mesService.insertInterfaceMesLogRemark(map.getString("IFID"), "S",map.getString("PLOGSEQNO"));
        	
        	mesService.startIfMasterCountLog(ifid,logseq);
        	
            map.setModuleCommand("Erpif", procName);
            map.put("i_IF_MES_ID", ifid);
            map.put("i_IF_MES_KEY", logseq);
            commonDao.getMap(map);
            data = map.getString("o_msg_msg");
            if(map.getString("o_msg_code").equals("0")) {
                mesService.updateInterfaceMesLog(logseq,"S",map.getString("o_msg_msg"));
            }else {
                mesService.updateInterfaceMesLog(logseq,"E",map.getString("o_msg_msg"));
            }
            mesService.endIfMasterCountLogIFNoError(logseq);
        }else {
        	data = service.sendIF(map);
        }
        
        model.put("data", data);
        if(mesService.notEmptyDocNo(docNo)){
            //model.put("RESULT_"+docNo, map.getString("RESULT_"+docNo));
            model.put("RESULT_"+docNo+"_MSG", map.getString("RESULT_"+docNo+"_MSG"));
            for(Object key1: map.keySet()) {
                String key = key1.toString();
                String[] s1 = key.split("_");
                if(s1.length >= 3) model.put(key, map.getString(key));
            }
        }
        
        System.out.println("data : "+data);
        map.clear();
        
        return JSON_VIEW;
    }

    @RequestMapping("/mes/erpif/json/saveIF.*")
    public String saveIF(HttpServletRequest request, Map<String, Object> model) throws SQLException {
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
        Object rs = mesService.saveIF(map);
        model.put("data", rs);
        map.clear();
        return JSON_VIEW;
    }

     //사원 부서
    @RequestMapping("/hr/json/data.*")
    public String hrJsonCall(HttpServletRequest request, Map<String, Object> model) throws Exception {
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
        DataMap result = new DataMap();
        service.run_START(map);
        model.put("data", result);
        model.put("row_count", result.size());
        map.clear();
        return JSON_VIEW;
    }

    @RequestMapping("/rfc/json/rfcCall.*")
    public String rfcCall(HttpServletRequest request, Map<String, Object> model) throws Exception {
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
        DataMap result = new DataMap();
        String ifid = map.get("IFID").toString();
        if(map.getString("DOC_NO")!=null && !"".equals(map.getString("DOC_NO"))) {
            map.put("DOC_NO", map.getString("DOC_NO"));
        }
        // order 일떄 팔렌트 조회해서 하나씩 넘겨야 됨
        if (ifServiceMapping.isPlantUseInParam(ifid)) {
            map.setModuleCommand("mes", "PLANT");
            List<DataMap> plantList = commonService.getList(map);
            if (plantList != null) {
                for (DataMap pMap : plantList) {
                    if (!StringUtils.isEmpty(pMap.get("WERKS")) && !pMap.getString("WERKS").equals("P400")) {
                        map.put("WERKS", pMap.get("WERKS"));
                        try {
                            result = service.run_START(map);
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                    }
                }
            }
            plantList.clear();
        } else {
            try {
                result = service.run_START(map);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        model.put("data", result);
        model.put("row_count", result.size());
        map.clear();
        result.clear();
        return JSON_VIEW;
    }


    @RequestMapping(value = "/common/api/json/{ifid}/{comm}.data", method = RequestMethod.GET)
    public String recieveAndSendRESTFU_GET(@PathVariable String ifid, @PathVariable String comm, HttpServletRequest request, Map<String, Object> model) throws SQLException {
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
        model.put("data", map.get("list"));
        return JSON_VIEW;
    }

    @RequestMapping("/if/json/savetbl.data")
    public String ifSaveTableData(HttpServletRequest request, Map<String, Object> model) throws Exception {
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
        mesService.saveIFTbl(map);
        map.clear();
        model.put("OK","OK");
        return JSON_VIEW;
    }


    // @comm send 송신, receive 수신
    @RequestMapping(value = "/common/api/json/{ifid}/{comm}.data", method = RequestMethod.POST)
    public String recieveAndSendRESTFUL(@PathVariable String ifid, @PathVariable String comm, HttpServletRequest request, Map<String, Object> model) throws SQLException {
//		// RESTFUL 데이터 수신,송신
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
        Map<String, String> list = new HashMap<>();
        String data = null;
//         map.put("DOC_NO", "MXX2022053000001");
        String docNo = map.getString("DOC_NO");

        String logseqno = mesService.insertInterfaceMesLogRemark(ifid, "C",  map.getString("PLOGSEQNO"));
        map.put("IFID", ifid);
        map.put("LOGSEQNO", logseqno);

        try {
            mesService.updateInterfaceMasterLog(ifid, logseqno);
            data = service.receiveAndSendRESTFUL(request, map);
        } catch (Exception e) {
            data = e.getMessage();
            log.error(e.getMessage());
        }
        list.put("IFID", ifid);
        list.put("result", data); // 성공 : SUCCESS, 그외 오류내용

        model.putAll(list);

        if(mesService.notEmptyDocNo(docNo)) {
            model.put("RESULT_"+docNo, map.getString("RESULT_"+docNo));
            model.put("RESULT_"+docNo+"_MSG", map.getString("RESULT_"+docNo+"_MSG"));
        }
        map.clear();
        // 수신결과 리턴 (처리결과 전송)
        return JSON_VIEW;
    }

    @RequestMapping(value = "/sso/schedule/test.data", method = RequestMethod.POST)
    public void scheduleTest() {
        String ss = propertiesUtil.getPropertyValue("sysconfig.log");
        System.out.println(ss);
    }

    @RequestMapping(value = "/if/itf/field/json/save.data", method = RequestMethod.POST)
    public String saveField(HttpServletRequest request,Map model) throws SQLException {
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
        mesService.fieldSave(map);
        model.put("data", "SUCCESS");
        map.clear();
        return JSON_VIEW;
    }
}