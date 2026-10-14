package project.mes.controller;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import com.fasterxml.jackson.core.JsonProcessingException;

import project.common.bean.CommonConfig;
import project.common.bean.DataMap;
import project.common.controller.BaseController;
import project.common.dao.CommonDAO;
import project.common.service.CommonService;
import project.mes.bean.DataMesMap;
import project.mes.service.IFService;
import project.mes.service.IFServiceMapping;
import project.mes.service.MesService;
import project.mes.util.CommonUtil;
import project.mes.util.PropertiesUtil;

public class AutoLabellerController extends BaseController {
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

	/**
	 * 프로시저 공통
	 * 
	 * @param request
	 * @param model
	 * @return
	 * @throws SQLException
	 * @throws JsonProcessingException
	 */
	@RequestMapping("/mes/{module}/{command}/json/rcvdata.ifdata")
	public String proceduleMes(HttpServletRequest request, @PathVariable String module, @PathVariable String command, Map model) throws SQLException, JsonProcessingException {
		// CommonConfig.PARAM_ATT_KEY : ParamData


		return "{112121212}";
	}

    @RequestMapping("/mes/autoif/json/sendIF.*")
    public String sendIF(HttpServletRequest request, Map<String, String> model) throws SQLException {
    	// 오토라벨러 실적 수신 프로세스
    	// Step 1. MES DB 데이터 저장
    	// Step 2. WMS 생산출고 요청
    	// Step 3. SAP RFC 호출

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

}
