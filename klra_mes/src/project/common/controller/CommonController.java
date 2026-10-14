package project.common.controller;

import com.fasterxml.jackson.core.JsonProcessingException;

import org.apache.ibatis.javassist.expr.NewArray;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.EncryptedDocumentException;
import org.apache.poi.openxml4j.exceptions.InvalidFormatException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.interceptor.TransactionAspectSupport;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import project.common.bean.*;
import project.common.dao.CommonDAO;
import project.common.dao.CommonDAO_MariaDB;
import project.common.service.CommonService;
import project.common.util.PostRequest;
import project.common.util.Util;
import project.mes.bean.DataMesMap;
import project.mes.service.IFService;
import project.mes.service.IFServiceMapping;
import project.mes.service.MesService;
import project.mes.service.quality.QualityService;
import project.mes.util.CommonUtil;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.sql.SQLException;
import java.util.*;
import java.util.concurrent.TimeoutException;
import java.util.concurrent.atomic.AtomicReference;

@Controller
public class CommonController extends BaseController {

	static final Logger log = LogManager.getLogger(CommonController.class.getName());
	private boolean isTest = false;
	private static final int MAX_RETRIES = 5; //최대 요청 횟수 제한

	@Autowired
	private CommonService commonService;

	@Autowired
	private CommonSearch commonSearch;

	@Autowired
	private SystemConfig systemConfig;

	@Autowired
	private FileRepository respository;

	@Autowired
	private CommonUser commonUser;

	@Autowired
	private MesService mesService;
	@Autowired
	private IFService service;
	@Autowired
	private IFServiceMapping ifServiceMapping;
	@Autowired
	private CommonDAO commonDao;

	@Autowired
	private QualityService qualityService;

	/***
	 * MES 실적 취소 
	 */
	public Map<String, String> sendCanMesDataForRcv(DataMap map) throws Exception {
		boolean rtnbool = false;
        Map<String, String> model = new HashMap<String, String>();
        String data = null;
        String rtnDocNo_TRANS = null;
        String rtnDocNo_WRK = null;
		DataMap rsMap;
		Map<String, String> rtnDocNoMap = new HashMap<String, String>();

    	map.setModuleCommand("Work", "WRK00_2");//SP_AUTO_CANC_SAP

    	rsMap = commonService.getMap(map);
    	
    	if (map.getString("RS_CODE_RB").toString().equals("S"))
    	{
//    		rtnbool = true;
    		rtnDocNo_TRANS = map.getString("P_DOC_NO_CANC_TRANS");
    		rtnDocNo_WRK = map.getString("P_DOC_NO_CANC_WRK");

    		rtnDocNoMap.put("rtnDocNo_TRANS", rtnDocNo_TRANS);
    		rtnDocNoMap.put("rtnDocNo_WRK", rtnDocNo_WRK);
    	} else {
//    		rtnbool = false;
    	}

		return rtnDocNoMap;
	}
	
	/***
	 * 
	 */
	public String sendCanMesData(DataMap map) throws Exception {
		boolean rtnbool = false;
        Map<String, String> model = new HashMap<String, String>();
        String data = null;
        String rtnDocNo = null;
		DataMap rsMap;

    	map.setModuleCommand("Work", "WRK00_2");

    	rsMap = commonService.getMap(map);
    	
    	if (map.getString("RS_CODE").toString().equals("S"))
    	{
//    		rtnbool = true;
    		rtnDocNo = map.getString("P_DOC_NO");
    	} else {
//    		rtnbool = false;
    		rtnDocNo = "";
    	}

		return rtnDocNo;
	}
	
	/**
	 * SAP 실적전송 취소
	 */
	public Map<String, String> sendCanIFData(DataMap map, String docNo) throws Exception {
		boolean rtnbool = false;
        Map<String, String> model = new HashMap<String, String>();
        String data = null;
//		DataMap ifMap = ifServiceMapping.geIFMasterValue(ifid);
		DataMap ifMap = ifServiceMapping.geIFMasterValue(map.getString("IFID").toString());
        String procName = ifMap.getString("PROCNM");
        String ifTbl= ifMap.getString("IFTBL");
        String sysFr = ifMap.getString("SYSFR");
        String sysTo = ifMap.getString("SYSTO");
        String ifName = ifMap.getString("IFKNM");
        
        ifMap.clear();

    	data = service.sendIF(map);

        model.put("data", data);
        
        if (data.equals("SUCCESS")) {
        	model.put("RS_CODE", "S");
        	model.put("RS_MSG", "");
        } else {
        	model.put("RS_CODE", "E");
        	model.put("RS_MSG", data);
        }
        if(mesService.notEmptyDocNo(docNo)){
            model.put("RESULT_"+docNo+"_MSG", map.getString("RESULT_"+docNo+"_MSG"));
            for(Object key1: map.keySet()) {
                String key = key1.toString();
                String[] s1 = key.split("_");
                if(s1.length >= 3) model.put(key, map.getString(key));
            }
        }
        
        System.out.println("data : "+data);
        map.clear();

		return model;
	}
	
	/**
	 * SAP 실적전송 취소
	 */
	public boolean sendCanIFData_old(DataMap map, String docNo) throws Exception {
		boolean rtnbool = false;
        Map<String, String> model = new HashMap<String, String>();
        String data = null;
//		DataMap ifMap = ifServiceMapping.geIFMasterValue(ifid);
		DataMap ifMap = ifServiceMapping.geIFMasterValue(map.getString("IFID").toString());
        String procName = ifMap.getString("PROCNM");
        String ifTbl= ifMap.getString("IFTBL");
        String sysFr = ifMap.getString("SYSFR");
        String sysTo = ifMap.getString("SYSTO");
        String ifName = ifMap.getString("IFKNM");
        
        ifMap.clear();

    	data = service.sendIF(map);

        model.put("data", data);
        
        if (data.equals("SUCCESS")) {
        	model.put("RS_CODE", "S");
        	model.put("RS_MSG", "");
        } else {
        	model.put("RS_CODE", "E");
        	model.put("RS_MSG", data);
        }
        if(mesService.notEmptyDocNo(docNo)){
            model.put("RESULT_"+docNo+"_MSG", map.getString("RESULT_"+docNo+"_MSG"));
            for(Object key1: map.keySet()) {
                String key = key1.toString();
                String[] s1 = key.split("_");
                if(s1.length >= 3) model.put(key, map.getString(key));
            }
        }
        
        System.out.println("data : "+data);
        map.clear();

		return rtnbool;
	}
	/**
	 * SAP 실적 전송
	 * @throws IOException 
	 */

	public Map<String, String> sndIFData(HttpServletRequest request, String ifid, String docNo) throws Exception {
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
        Map<String, String> model = new HashMap<String, String>();
        String data = null;
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

        map.put("IFID", ifid);
        map.put("DOC_NO", docNo);
    	data = service.sendIF(map);

        model.put("data", data);
        
        if (data.equals("SUCCESS")) {
        	model.put("RS_CODE", "S");
        	model.put("RS_MSG", "");
        } else {
        	model.put("RS_CODE", "E");
        	model.put("RS_MSG", data);
        }
        if(mesService.notEmptyDocNo(docNo)){
            model.put("RESULT_"+docNo+"_MSG", map.getString("RESULT_"+docNo+"_MSG"));
            for(Object key1: map.keySet()) {
                String key = key1.toString();
                String[] s1 = key.split("_");
                if(s1.length >= 3) model.put(key, map.getString(key));
            }
        }
        
        //System.out.println("sndIFData data : " + data);
        map.clear();

        return model;
	}
	
	/**
	 * 실적 재 수신 API
	 */
	@Transactional(propagation = Propagation.NESTED, rollbackFor = {Exception.class})
	@RequestMapping("/common/api/resenddata.*")
	public String postReSendApi(HttpSession session, HttpServletRequest request, Map model) throws Exception {
		DataMap map = new DataMap();
		String paramData = request.getParameter("param");
		String RS_CODE = null, RS_MSG = null, P_PRFM_FUNC = null, P_WDOC_NO = null;
		String prfmFunc = null, ifId = null, ifMesKey = null, sDocNo = null, rtnString = null, wDocNo = null;
		HashMap rtnMap = new HashMap<String, String>();
		Map<String, String> responseMap = new HashMap();
		List<DataMap> responseListWms;
		List<DataMap> list, cur1;
		boolean rtnbool = false;
		String rtnDocNo = null;
		
		JSONObject jobj = new JSONObject(paramData);
		try {
			map.put("P_WERKS",  jobj.getString("P_WERKS"));
			map.put("P_MACH_CD",  jobj.getString("P_MACH_CD"));
			map.put("P_IND_BCD",  jobj.getString("P_IND_BCD"));
        	map.put("P_ERP_DOC_NO", P_PRFM_FUNC);
        	map.put("P_WMS_DOC_NO", P_WDOC_NO);
        	map.put("RS_CODE", RS_CODE);
        	map.put("RS_MSG", RS_MSG);

        	map.setModuleCommand("Work", "WRK00_3");

        	list = commonService.getList(map);
        	
        	if (map.getString("RS_CODE").toString().equals("S")) {
    			cur1 = CommonUtil.processList(map, "P_CUR_1");

    			rtnMap = cur1.get(0);
    			ifId = rtnMap.get("I_IF_ID").toString();
    			ifMesKey = rtnMap.get("I_IF_KEY").toString();
    			sDocNo = rtnMap.get("I_SDOC_NO").toString();
    			rtnString = rtnMap.get("I_PRFM_LIST").toString();
    			wDocNo = rtnMap.get("I_WDOC_NO").toString();
    			prfmFunc = rtnMap.get("I_PRFM_FUNC").toString();
    			
    			request.setAttribute("IFID", ifId);
    			request.setAttribute("DOC_NO", sDocNo);
    			
    			// SAP 실적 전송
    			responseMap = sndIFData(request, ifId, sDocNo);
    			
    			JSONObject jObj = new JSONObject(rtnString);
				map.clear();
    			String jsonStr = CommonUtil.mapToJson(map);

    			// SAP 실적 전송 성공 시 WMS 입고요청
    			if (responseMap.get("RS_CODE").toString().equals("S")) {
        			model.put("RS_CODE", responseMap.get("RS_CODE"));	// 
            		model.put("RS_MSG", responseMap.get("RS_MSG"));
    			} else {
        			model.put("RS_CODE", responseMap.get("RS_CODE"));	// MES 입력 실패 시 리턴코드를 E로 전송
            		model.put("RS_MSG", responseMap.get("RS_MSG"));

            		// SAP 전송 실패 시 MES Data Rollback 처리
            		if (!responseMap.get("RS_CODE").toString().equals("S")) {
            			map.clear();
            			map.put("P_WERKS", jobj.getString("P_WERKS"));
            			map.put("P_MACH_CD", jobj.getString("P_MACH_CD"));
            			map.put("P_IND_BCD", jobj.getString("P_IND_BCD"));
            			map.put("P_USERID", "AUTO");
            	        map.put("IFID", "MES_IF_129");
            	        map.put("DOC_NO", sDocNo);
            			map.put("RS_CODE", RS_CODE);
            			map.put("RS_MSG", RS_MSG);
            			
            			rtnDocNo = sendCanMesData(map);
            		}
    			
    			}
        	} else {
    			model.put("RS_CODE", map.get("RS_CODE"));	// MES 입력 실패 시 리턴코드를 E로 전송
        		model.put("RS_MSG", map.get("RS_MSG"));
        	}
		} catch(Exception ex) {
			if (!map.get("RS_CODE").toString().equals("S")) {
				model.put("RS_CODE", responseMap.get("RS_CODE"));	// MES 입력 실패 시 리턴코드를 E로 전송
	    		model.put("RS_MSG", responseMap.get("RS_MSG"));
			} else {
				model.put("RS_CODE", map.get("RS_CODE"));	// MES 입력 실패 시 리턴코드를 E로 전송
	    		model.put("RS_MSG", map.get("RS_MSG"));
			}
		}
		return JSON_VIEW;
	}

	/**
	 * HL 가공 오토라벨러 실적취소 API
	 * 
	 * @param request
	 * @param model
	 * @return
	 * @throws SQLException
	 * @throws JsonProcessingException
	 */
	@Transactional(propagation = Propagation.NESTED, rollbackFor = {Exception.class})
	@RequestMapping("/common/api/rcvdata/cancel.*")
	public String cancelRcvData(HttpSession session, HttpServletRequest request, Map model) throws Exception {
		log.debug("======== [AGV 취소 시작] ========");
		log.debug("======== [AGV 취소 시작] ========");
		log.debug("======== [AGV 취소 시작] ========");

		DataMap map = new DataMap();
		String paramData = request.getParameter("param");
		String ROLLBACK_TYPE = "";

		JSONObject paramJson = new JSONObject(paramData);
		log.debug("========    [AGV_NEW]    ========");

		try {
			ROLLBACK_TYPE = "DELETE_workMes_RB";
			map.put("ROLLBACK_TYPE", ROLLBACK_TYPE);

			// Step1. MES 실적 등록
			map.put("P_MACH_CD",		paramJson.getString("P_MACH_CD"));
			map.put("P_IND_BCD",		paramJson.getString("P_IND_BCD"));
			map.put("P_ERR_TYPE",		paramJson.getString("P_ERR_TYPE"));
			map.put("P_ERR_MSG",		paramJson.getString("P_ERR_MSG"));
			map.put("P_DEVICE_DT",		paramJson.getString("P_DEVICE_DT"));
			map.put("P_RMK",			paramJson.getString("P_RMK"));

			map.setModuleCommand("Work", "AUTO_ERR_LOG"); // SP_AUTO_RCV_WRK_PRFM

			commonService.getList(map);

			model.put("RS_CANCLE_CODE", "S");
			model.put("RS_CANCLE_MSG", "성공");
		} catch(Exception ex) {
			log.error("=========================================");
			log.error("[AGV 취소 실패] 오토라벨러 실적취소 처리 중 예외 발생");
			log.error("■ 에러 원인 : ", ex);
			log.error("=========================================");

			// 2. 외부 시스템 인터페이스용 실패 결과 세팅
			// (사내 연동 규격에 맞춰 RESULT_CD, RESULT_MSG 등의 Key 값을 맞춰주세요)
			model.put("RS_CANCLE_CODE", "E");
			model.put("RS_CANCLE_MSG", "MES 실적 취소 처리 실패 (" + ex.getMessage() + ")");
		}

		log.debug("======== [AGV 취소 종료] ========");
		log.debug("======== [AGV 취소 종료] ========");
		log.debug("======== [AGV 취소 종료] ========");

		return JSON_VIEW;
	}

	/**
	 * 실적수신 API
	 *
	 * @param request
	 * @param model
	 * @return
	 * @throws SQLException
	 * @throws JsonProcessingException
	 */
	@Transactional(propagation = Propagation.NESTED, rollbackFor = {Exception.class})
	@RequestMapping("/common/api/rcvdata.*")
	public String postRequestApi(HttpSession session, HttpServletRequest request, Map model) throws Exception {
		log.debug("======== [AGV 시작] ========");
		log.debug("======== [AGV 시작] ========");
		log.debug("======== [AGV 시작] ========");
		DataMap map = new DataMap();
		DataMap noMap = new DataMap();
		String paramData = request.getParameter("param");
		String RS_CODE = null, RS_MSG = null, P_PRFM_FUNC = null, P_USE_FUNC = null, P_WDOC_NO = null;
		String prfmFunc = null, ifId = null, ifMesKey = null, sDocNo = null, rtnString = null, wDocNo = null;
		List<DataMap> cur1, list;
		HashMap rtnMap = new HashMap<String, String>(); 
		HashMap rtnMap_txn = new HashMap<String, String>();
		Map<String, String> responseMap = new HashMap();
		Map<String, String> responseMapRB = new HashMap();
		List<DataMap> responseListWms;
		boolean rtnbool = false;
		String rtnDocNo = null;
		String wmsNoForRB = "";
		String transferDocNo = "";
		String userId = "";
		String matnrNm = "";
		String unit = "";
		String machCd = "";
		String ROLLBACK_TYPE = "";
		String RS_CODE_LOG = "";
		String RS_MSG_LOG = "";
		Map<String, String> rtnDocNoMap = new HashMap<>();

		JSONObject jObj = null;
    	JSONObject jobj = new JSONObject(paramData);
    	
    	//호기별 NEW/OLD 로직 사용여부
    	String agvNewYn = commonService.getAgvNewYN(jobj.getString("P_MACH_CD"));
    	
    	//NEW 로직 사용
    	if("Y".equals(agvNewYn)) {
    		System.out.println("NEW 로직 사용");
    		log.debug("========    [AGV_NEW]    ========");
    		log.debug("======== [MES 실적등록 시작] ========");
    		
    		try {
    			ROLLBACK_TYPE = "DELETE_workMes_RB";
    			map.put("ROLLBACK_TYPE", ROLLBACK_TYPE);
    			
				userId = jobj.getString("P_USERID");
				
				//test 부분 
				
				/*
				 * noMap.put("P_LOT_TEMP", jobj.getString("P_LOT_NO")); noMap.put("P_WERKS",
				 * jobj.getString("P_WERKS")); noMap.put("P_MACH_CD",
				 * jobj.getString("P_MACH_CD")); noMap.put("P_MATNR",
				 * jobj.getString("P_MATNR")); noMap.setModuleCommand("Work", "GET_NO"); // GET
				 * IND_BCD, LOT_NO commonService.getMap(noMap);
				 * 
				 * jobj.put("P_IND_BCD", noMap.getString("P_BARCODE_SEQ")); jobj.put("P_LOT_NO",
				 * noMap.getString("P_LOT_NO")); jobj.put("P_LOT_NO", "FR25803411");
				 * 
				 * 
				 * System.out.println("채번된 indbcd : " + jobj.getString("P_IND_BCD"));
				 * System.out.println("채번된 lotno : " + jobj.getString("P_LOT_NO"));
				 */
				 
				 //test 부분
    			 
            	// Step1. MES 실적 등록
            	map.put("P_WERKS",			jobj.getString("P_WERKS"));
            	map.put("P_MACH_CD",		jobj.getString("P_MACH_CD"));
            	map.put("P_USERID",			jobj.getString("P_USERID"));
            	map.put("P_ORDER_NO",		jobj.getString("P_ORDER_NO"));
            	map.put("P_WRK_ORDR_NO",	jobj.getString("P_WRK_ORDR_NO"));
            	map.put("P_WRK_ORDR_SEQNO",	jobj.getString("P_WRK_ORDR_SEQNO"));
            	map.put("P_MATNR",			jobj.getString("P_MATNR"));
            	map.put("P_PRFM_QTY",		jobj.getString("P_PRFM_QTY"));
            	map.put("P_IND_BCD",		jobj.getString("P_IND_BCD"));
            	map.put("P_LOT_NO",			jobj.getString("P_LOT_NO"));
            	map.put("Lang",				jobj.getString("Lang"));
            	map.put("RS_CODE",			RS_CODE);
            	map.put("RS_MSG",			RS_MSG);
            	map.put("P_PRFM_FUNC",		P_PRFM_FUNC);
            	map.put("P_USE_FUNC",		P_USE_FUNC);
            	map.put("P_WDOC_NO",		P_WDOC_NO);
            	
            	map.setModuleCommand("Work", "WRK00"); // SP_AUTO_RCV_WRK_PRFM             

            	list = commonService.getList(map);

            	matnrNm = map.getString("P_MATNR_NM");
            	unit = map.getString("P_UNIT");
            	machCd = map.getString("P_MACH_CD");
            	
            	
            	// Step1_1. MES 실적 등록 성공시 SAP 전송
            	if (map.getString("RS_CODE").toString().equals("S"))
            	{
            		log.debug("======== [MES 실적등록 성공] ========");
            		log.debug("======== [SAP 실적등록 시작] ========");
        			
        			ROLLBACK_TYPE = "DELETE_workSap_RB";
        			map.put("ROLLBACK_TYPE", ROLLBACK_TYPE);
        			
        			cur1 = CommonUtil.processList(map, "P_CUR_1");

        			prfmFunc	= map.get("P_PRFM_FUNC").toString();
        			rtnMap		= cur1.get(0);
        			ifId		= rtnMap.get("I_IF_ID").toString();
        			ifMesKey	= rtnMap.get("I_IF_KEY").toString(); //MES_IF_124
        			sDocNo		= rtnMap.get("I_SDOC_NO").toString(); //자재불출 문서번호 
        			rtnString	= rtnMap.get("I_PRFM_LIST").toString(); // WMS 생산출고요청 프로시저호출시 사용할? JSON 파라미터
        			wDocNo		= rtnMap.get("I_WDOC_NO").toString(); //WMS 입고요청 문서번호
        			
        			request.setAttribute("IFID", ifId); //MES_IF_124
        			request.setAttribute("DOC_NO", sDocNo); //자재불출 문서번호
        			
        			// Step2. SAP 실적 전송
        			responseMap = sndIFData(request, ifId, sDocNo); //자재불출 문서번호
        			
        			jObj = new JSONObject(rtnString);
    				//map.clear();
        			//String jsonStr = CommonUtil.mapToJson(map);

        			// Step2_1. SAP 실적 전송 성공시 WMS 입고요청 (MES출고요청 = WMS입고요청) & WMS 입고
        			//if (false)
    				if (responseMap.get("RS_CODE").toString().equals("S"))
        			{
    					log.debug("======== [SAP 실적등록 성공] ========");
    					log.debug("======== [WMS 입고요청&입고 시작] ========");
            			
        				// Step3. WMS 입고요청 (MES출고요청) & WMS 입고
            			ROLLBACK_TYPE = "DELETE_storeWms_RB";
            			map.put("ROLLBACK_TYPE", ROLLBACK_TYPE);

        				map.put("P_JSONSTR", rtnString.replaceAll("\"", "^"));
        				
        				map.put("P_MACH_CD", jobj.getString("P_MACH_CD"));
        				map.put("P_WRK_ORDR_NO", jobj.getString("P_WRK_ORDR_NO"));
        	        	map.put("P_WRK_ORDR_SEQNO", jobj.getString("P_WRK_ORDR_SEQNO"));
        	        	//map.put("P_PRFM_QTY", jobj.getString("P_PRFM_QTY"));
        	        	
        				map.put("Lang",			"KO");
        				map.put("P_WERKS",		jObj.getString("WERKS"));
        				map.put("P_MATNR",		jObj.getString("MATNR"));
        				map.put("P_IND_BCD",	jObj.getString("IND_BCD"));
        				map.put("P_DOC_NO",		jObj.getString("DOC_NO")); 		//WMS 입고요청 문서번호
        				map.put("P_DOC_SEQ",	jObj.getString("DOC_SEQNO"));	//WMS 입고요청 문서번호 SEQ
        				map.put("P_LOT_NO",		jObj.getString("LOT_NO"));
        				
        				//map.put("P_USERID", jObj.getString("EMPLY_NO"));
        	        	//map.put("P_ORDER_NO", jObj.getString("ORDER_NO"));
        				map.setModuleCommand("Work", "WRK00_1"); //SP_AUTO_RCV_STEP3
    					
    					responseListWms = commonService.getList(map);
        				
            			// Step3_1. WMS 입고요청 (MES출고요청) & WMS 입고 성공시 SAP재고이전
    					wmsNoForRB = map.get("P_DOC_NO_WMS").toString(); //wms 입고 취소(롤백)를 위한 return msg
    					transferDocNo = map.get("P_DOC_NO_TRANS").toString(); //재고이전 문서번호
    					log.debug("■ wmsNoForRB(WMS입고취소용) : {} ", wmsNoForRB);
    					log.debug("■ transferDocNo(재고이전문서번호) : {} ", transferDocNo);
    					
    					if (map.get("RS_CODE").toString().equals("S")) {
        					log.debug("======== [WMS 입고요청&입고 성공] ========");
        					log.debug("======== [SAP 재고이전 시작] ========");

    						// Step4. SAP 재고이전(이동유형 311)
                			ROLLBACK_TYPE = "DELETE_transferSap_RB";
                			map.put("ROLLBACK_TYPE", ROLLBACK_TYPE);
    						
    						ifId = "MES_IF_131";

    		    			request.setAttribute("IFID", ifId);
    		    			request.setAttribute("DOC_NO", transferDocNo); //재고이전 문서번호
    		    			responseMap = sndIFData(request, ifId, transferDocNo); //재고이전 문서번호

    						// Step4_1. SAP 재고이전 성공시 WCS API 호출
    		    			// 4호기, 5호기는 WCS 호출 제외 
    		    			// 3호기, 6호기만 WCS 호출
    						if(responseMap.get("RS_CODE").toString().equals("S")) {
    							log.debug("======== [SAP 재고이전 성공] ========");
    							ROLLBACK_TYPE = "DELETE_WCS_RB";
    							
    							//SAP 확정문서번호 WMS UPDATE
    							DataMap mapForWMS = new DataMap();
    							mapForWMS.put("MDOC_NO", transferDocNo);
    							mapForWMS.put("IND_BCD", jObj.getString("IND_BCD"));
    							
    							int updateResult = commonService.updateSDocNo(mapForWMS);
    							if(updateResult == 1) {
    								if(machCd.equals("TRA03") | machCd.equals("TRA06")) {
        								log.debug("======== [WCS 입고 시작] ========");
            							// Step5. WCS 프로시저 호출
                            			
                            			map.put("ROLLBACK_TYPE", ROLLBACK_TYPE);
            							
            							map.put("P_USER_ID",		userId);						//등록자
            							map.put("P_ORDER_NO",		transferDocNo + 'C');			//작업 요청번호 //mes 재고이전 문서번호 //C, CREATE D, DELETE
            							map.put("P_ORDER_TYPE",		"IN");							//작업구분 //IN 입고요청
            							map.put("P_PLANT_CD",		jobj.getString("P_WERKS"));		//작업장 코드
            							map.put("P_MATNR",			jobj.getString("P_MATNR"));		//자재코드
            							map.put("P_MATNR_NM",		matnrNm);						//자재명
            							map.put("P_LOT_NO",			jobj.getString("P_LOT_NO"));	//LOT번호
            							map.put("P_IND_BCD",		jobj.getString("P_IND_BCD"));	//개별바코드
            							map.put("P_UNIT",			unit);							//단위
            							map.put("P_QTY",			jObj.getString("QTY"));	//수량
            							map.put("P_MACH_CD",		jobj.getString("P_MACH_CD"));	//호기정보
            							
            		    				map.setModuleCommand("WCS", "WCS_STOCK_IN"); //mariadb
            		    				
            		    				commonService.getWcsList(map); //mariadb
            							
            							map.put("P_SUCCESS_CHK",		map.getString("P_RESULT"));		//성공유무
            							map.put("P_SUCCESS_CHK_MSG",	map.getString("P_RESULT_MSG"));	//RETURN 메세지
            							//catch 문에서도 insert가 되어야할듯 그래야 실패이력이남음 
            							map.setModuleCommand("Work", "WCS_HISTORY_SAVE");
            							
            							commonService.getMap(map); //wcs 호출 이력 저장
            		    				
            							// Step5_1. WCS API 요청 성공시 DELETE_WCS_RB
            							if(map.get("P_RESULT").toString().equals("S")) { 
            								log.debug("======== [WCS 입고 성공] ========");
            								
            								// 성공 return 
            			        			model.put("RS_CODE", map.get("P_RESULT"));
            			            		model.put("RS_MSG", map.get("RS_MSG"));
            							} else if(map.get("P_RESULT").toString().equals("F")){
            								//응답 오류 메세지에 따라 대응
            								//if(map.get("P_RESULT_MSG").toString().equals("")) {
            								//} else if (map.get("P_RESULT_MSG").toString().equals("")) {
            								//} else {
            								//}
            								
            								// Step5_2. WCS API 요청 실패시 REDIRECT
            								// 우리쪽 요청은 다끝났기때문에 우리걸 롤백할 필욘없고 WCS를 계속해서 요청하는게 맞다고 봄 
            								// REDIRECT 하기
            								String result = "";
            								map.setModuleCommand("WCS", "WCS_STOCK_IN");
            								
            								result = redirectWcsList(map, 0);
            								if(result.equals("S")) {
            									log.debug("======== [WCS 입고 성공] ========");
            								} else {
            									log.debug("======== [WCS 입고 실패] ========");
            									// Step5_2. WCS 입고 실패시 롤백
            				            		throw new Exception(responseMap.get("RS_MSG").toString());
            								}
            							} 
        							} else {
            							// 성공 return 
        			        			model.put("RS_CODE", responseMap.get("RS_CODE"));
        			            		model.put("RS_MSG", "실적등록 성공");
            						}
    							}
    						} else { 
    							// Step4_2. SAP 재고이전 실패시 롤백
    							throw new Exception(responseMap.get("RS_MSG").toString());
    						}
                		} else { 
                			// Step3_2. WMS 입고 실패시 롤백
                			throw new Exception(map.get("RS_MSG").toString());
    					}
        			} else { 
        				// Step2_2. SAP 실적전송 실패시 롤백
        				throw new Exception(responseMap.get("RS_MSG").toString());
        			}
            	} else {
            		// Step1_2. MES 실적 등록 & WMS 입고요청 (MES출고요청 = WMS입고요청) 실패시 리턴코드 E로 전송 (250206 확인필요)
            		//throw new Exception("ORA-00001");
            		throw new Exception(map.get("RS_MSG").toString());
            	}

            	log.debug("model :" + model);
            } catch(Exception ex) {	
    			/* RS_CODE
    			 * E		: MES 실적 등록 실패 - 개별바코드 존재
    			 * E1		: MES 실적 등록 실패				DELETE_workMes_RB
    			 * E2		: SAP 전송 실패(실적등록, 재고이전)		DELETE_workSap_RB / DELETE_transferSap_RB
    			 * E3		: WMS 입고 실패					DELETE_storeWms_RB
    			 * E4		: WCS 호출 실패					DELETE_WCS_RB
    			 * E_CANC	: 롤백 호츌 실패
    			 * E0		: 예상치 못한 오류
    			 * E_NETWORK: 네트워크 오류
    			 * */
            	log.debug("======== [AGV 실패] ========");
            	log.debug("======== [AGV_ROLLBACK 시작] ========");
            	log.debug("======== [AGV_ROLLBACK 시작] ========");
            	log.debug("======== [AGV_ROLLBACK 시작] ========");
            	log.debug("■ ROLLBACK_TYPE : {} ", ROLLBACK_TYPE);
            	
            	//System.out.println(ex.getMessage());
            	RS_CODE = map.getString("RS_CODE");
            	RS_MSG 	= map.getString("RS_MSG").toString();
    			if(RS_MSG.equals("")) {
    				RS_MSG = ex.getMessage();	
    			}
            	
            	//개별바코드존재시 별도 MSG 필요 
            	if (ex.getMessage() != null && ex.getMessage().contains("ORA-00001")) {
            		RS_CODE_LOG = "E";
            		RS_MSG_LOG = "[MES 실적등록 실패]" + jobj.getString("P_IND_BCD") + " 개별바코드 기 존재";
            		model.put("RS_CODE", "E");	// MES 입력 실패 시(개별바코드존재) 리턴코드를 E로 전송
            		model.put("RS_MSG", "수동으로 POP 에서 실적등록 바랍니다. [" + jobj.getString("P_IND_BCD") + "] 개별바코드 기 존재");
            		
    				log.debug("======== [AGV_ROLLBACK 성공] ========");
					log.debug("■ RS_CODE : {} ", RS_CODE_LOG);
					log.debug("■ RS_MSG : {} ", RS_MSG_LOG);
            	} else if(ROLLBACK_TYPE.equals("DELETE_WCS_RB")) {
            		// 가공3, 6호기
            		if(machCd.equals("TRA03") | machCd.equals("TRA06")) {
	            		//catch 문에서도 insert가 되어야할듯 그래야 실패이력이남음 
	            		map.put("P_SUCCESS_CHK", "E"); //성공유무
	            		if(map.getString("P_RESULT_MSG") != null) {
	            			map.put("P_SUCCESS_CHK_MSG", map.getString("P_RESULT_MSG")); //RETURN 메세지	
	            		}
	            		
	    				map.setModuleCommand("Work", "WCS_HISTORY_SAVE");
	    				commonService.getMap(map); //wcs 호출 이력 저장
	    				
	            		RS_CODE_LOG = "E4_2";
	            		RS_MSG_LOG = "[WCS 요청 오류]" + map.get("") + ex.getMessage();
	            		
	            		model.put("RS_CODE", "E4_1");	// wcs 호출 실패 시 리턴코드를 E4_1로 전송
	            		model.put("RS_MSG", "WCS 입고 실패, WCS 프로그램을 통해 개별바코드 수동입고처리 바랍니다.");
            		} else { // 가공3, 6호기 제외
	            		RS_CODE_LOG = "E4_1";
	            		RS_MSG_LOG = "[WCS 요청 전 오류 / SAP 확정문서 업데이트 오류]" + ex.getMessage();
	            		
	            		model.put("RS_CODE", "E4_2");	// wcs 호출 전 구역에서 오류발생 
	            		model.put("RS_MSG", "재고이동 SAP 확정문서 업데이트 오류발생, 확인필요");
            		}
            		
    				log.debug("======== [AGV_ROLLBACK 성공] ========");
					log.debug("■ RS_CODE : {} ", RS_CODE_LOG);
					log.debug("■ RS_MSG : {} ", RS_MSG_LOG);
            	} else if (ex instanceof java.net.SocketTimeoutException
    	                || ex instanceof java.net.ConnectException
    	                || ex instanceof java.net.UnknownHostException
    	                || ex instanceof java.net.SocketException) {
    	            // 네트워크 오류로 판단되는 예외들
            		RS_CODE_LOG = "E_NETWORK";
            		RS_MSG_LOG = "[네트워크 오류]" + RS_MSG;

					model.put("RS_CODE", "E_NETWORK");
					model.put("RS_MSG", "네트워크 오류: " + RS_MSG);
					
    				log.debug("======== [AGV_ROLLBACK 성공] ========");
					log.debug("■ RS_CODE : {} ", RS_CODE_LOG);
					log.debug("■ RS_MSG : {} ", RS_MSG_LOG);
            	} else {
    				// Step1. MES 실적 등록 취소 & WMS 입고요청 취소
    				// Step2. WMS 입고 취소
        			// Step3. SAP 재고이전 취소
        			// Step4. SAP 실적전송 취소
            		
            		if(ROLLBACK_TYPE.equals("DELETE_workMes_RB")) {
            			RS_CODE_LOG = "E1";
                		RS_MSG_LOG = "[MES 실적등록 실패]" + RS_MSG;
                		
                		
                		
            			if(RS_CODE.equals("E3")) { //투입자재 부족 SP_AUTO_RCV_WRK_PRFM 에서 RETURN 한 RS_CODE
            				model.put("RS_CODE", "E1_2");	// MES 입력실패 시 리턴코드를 E1로 전송
            				model.put("RS_MSG", "[자재투입량 부족]" + RS_MSG_LOG + " *해당 라벨 사용불가* 자재투입 후 재발행된 라벨 부착바랍니다.");	// MES 입력실패 시 리턴코드를 E1로 전송
            			} else {
            				model.put("RS_CODE", "E1");	// MES 입력실패 시 리턴코드를 E1로 전송
    						model.put("RS_MSG", RS_MSG_LOG + " 수동으로 POP 에서 실적등록 바랍니다.");	// MES 입력실패 시 리턴코드를 E1로 전송
            			}
            			
    					//log.debug("■ RS_CODE : E1");
    					//log.debug("■ RS_MSG : {} ", "[MES 실적등록 실패]" + RS_MSG);
					} else if(ROLLBACK_TYPE.equals("DELETE_workSap_RB") | ROLLBACK_TYPE.equals("DELETE_transferSap_RB") ){
            			RS_CODE_LOG = "E2";
                		RS_MSG_LOG = "[SAP 전송 실패 - " + ROLLBACK_TYPE + "]" + RS_MSG;
    					//log.debug("■ RS_CODE : E2");
    					//log.debug("■ RS_MSG : {} ", "[SAP 전송 실패 - " + ROLLBACK_TYPE + "]" + RS_MSG);
    					
						model.put("RS_CODE", "E2");// SAP 전송 실패 시 리턴코드를 E2 으로 전송
						model.put("RS_MSG", RS_MSG_LOG + " 수동으로 POP 에서 실적등록 바랍니다.");	// MES 입력실패 시 리턴코드를 E1로 전송
					} else if(ROLLBACK_TYPE.equals("DELETE_storeWms_RB")) {
            			RS_CODE_LOG = "E3";
                		RS_MSG_LOG = "[WMS 입고요청&입고 실패]" + RS_MSG;
    					//log.debug("■ RS_CODE : E3");
    					//log.debug("■ RS_MSG : {} ", "[WMS 입고요청&입고 실패]" + RS_MSG);
    					
						model.put("RS_CODE", "E3");// WMS 입고요청&입고 실패시 리턴코드를 E3 으로 전송
						model.put("RS_MSG", RS_MSG_LOG + " 수동으로 POP 에서 실적등록 바랍니다.");	// MES 입력실패 시 리턴코드를 E1로 전송
					}
            		
    				//map.clear();
    				map.put("ROLLBACK_TYPE", ROLLBACK_TYPE);
    				
    				map.put("P_WERKS",		jobj.getString("P_WERKS"));
    				map.put("P_MACH_CD",	jobj.getString("P_MACH_CD"));
    				map.put("P_IND_BCD",	jobj.getString("P_IND_BCD"));
    				map.put("P_USERID",		jobj.getString("P_USERID"));
    				map.put("P_TYPE",		"AUTO");
    				
    				if(ROLLBACK_TYPE.equals("DELETE_transferSap_RB") | ROLLBACK_TYPE.equals("DELETE_storeWms_RB")) {
    					map.put("P_WMS_CANC_KEY", wmsNoForRB); //WCS 입고 프로시저내에서 RETURN 받은 문서번호 넣어줘야함	
    					map.put("P_TRANS_CANC_KEY", transferDocNo); //WCS 입고 프로시저내에서 RETURN 받은 문서번호 넣어줘야함	
    				}
    				 
    				// Step1. MES 실적 등록 취소 & WMS 입고요청 취소
    				// Step2. WMS 입고 취소
    				log.debug("======== [ROLLBACK MES 실적등록취소 / WMS 입고요청&입고 취소 시작] ========");
    				rtnDocNoMap = sendCanMesDataForRcv(map); 
    				
    				if(map.getString("RS_CODE_RB").equals("S")) {
    					log.debug("======== [ROLLBACK MES 실적등록취소 / WMS 입고요청&입고취소 성공] ========");
    					log.debug("■ RS_CODE_RB : S");
    					log.debug("■ RS_MSG_RB : {} ", map.getString("RS_MSG_RB"));
    					//System.out.println("RS_MSG_RB : " + ROLLBACK_TYPE + " - " + map.getString("RS_MSG_RB"));
    					
    					// 실적전송취소 -> 재고이전 취소
    					if (rtnDocNoMap != null && rtnDocNoMap.size() != 0 && !rtnDocNoMap.get("rtnDocNo_WRK").equals("")) {
    						//Java에서 람다 표현식이나 익명 내부 클래스에서 외부 지역 변수(local variable)를 직접 수정할 수 없음.
    						//변경되는 변수를 사용하려면 AtomicReference 을 사용해야함  
    						AtomicReference<String> docNo_TRANS = new AtomicReference<>("");
    						AtomicReference<String> docNo_WRK = new AtomicReference<>("");
    	    				map.remove("P_DOC_NO"); //?
    	    				rtnDocNoMap.forEach((rtnDocnoKey, rtnDocnoValue)->{
    	    					System.out.println( rtnDocnoKey + " : " + rtnDocnoValue );
    	    					if(rtnDocnoKey.contains("TRANS")) {
    	    						docNo_TRANS.set(rtnDocnoValue);
    	    					} else if(rtnDocnoKey.contains("WRK")){
    	    						docNo_WRK.set(rtnDocnoValue);
    	    					}
    	    					map.put(rtnDocnoKey, rtnDocnoValue);
    	    				});
    	    				
    	    				//재고이전 취소는 할필요가 없지않나
    	    				//if(ROLLBACK_TYPE.equals("DELETE_WCS_RB")) {
    	        				// Step3. SAP 재고이전 취소 
    	        				//map.put("IFID", "MES_IF_132");
    	        				//System.out.println( map.get( "map.IFID : " + "IFID").toString());
    	        				//responseMapRB = sendCanIFData(map, docNo_TRANS.get()); //SAP 재고이전 취소
    	    				//}
    	    				
    	    				if(ROLLBACK_TYPE.equals("DELETE_transferSap_RB") | ROLLBACK_TYPE.equals("DELETE_storeWms_RB")) {
    	    					log.debug("======== [ROLLBACK SAP 실적등록 취소 시작] ========");
    	    					
    	    					// Step4. SAP 실적전송 취소
    	        				map.put("IFID", "MES_IF_129");
    	        				map.put("DOC_NO", docNo_WRK.get());
    	        				
    	    	    			responseMapRB = sendCanIFData(map, docNo_WRK.get()); //MES 실적전송 취소
    	    	    			
    	    	    			if(responseMapRB.get("RS_CODE").toString().equals("S")) {
        		    				log.debug("======== [ROLLBACK SAP 실적등록 취소 성공] ========");
        		    				log.debug("======== [AGV_ROLLBACK 성공] ========");
        	    					log.debug("■ RS_CODE : {} ", RS_CODE_LOG);
        	    					log.debug("■ RS_MSG : {} ", RS_MSG_LOG);
        		    				//System.out.println("RollBack Success!");
        		    			} else {
        		    				log.debug("======== [ROLLBACK SAP 실적등록 취소 실패] ========");
        	    					log.debug("■ RS_CODE : E_CANC - " + ROLLBACK_TYPE);
        	    					log.debug("■ RS_MSG : {} ", responseMapRB.get("RS_MSG").toString());
        	    					log.debug("======== [AGV_ROLLBACK 실패] ========");
        		    				//System.out.println("RollBack Fail!");
        		    			}
    	    				} else {
    		    				log.debug("======== [AGV_ROLLBACK 성공] ========");
    	    					log.debug("■ RS_CODE : {} ", RS_CODE_LOG);
    	    					log.debug("■ RS_MSG : {} ", RS_MSG_LOG);
    	    				}
    	    			} else {
		    				log.debug("======== [AGV_ROLLBACK 성공] ========");
	    					log.debug("■ RS_CODE : {} ", RS_CODE_LOG);
	    					log.debug("■ RS_MSG : {} ", RS_MSG_LOG);
	    				}
    				} else {
    					//롤백 프로시저호출 오류
    					log.debug("======== [ROLLBACK MES 실적등록취소 / WMS 입고요청&입고취소 실패] ========");
    					log.debug("■ ROLLBACKTYPE : {} ", ROLLBACK_TYPE);
    					log.debug("■ RS_CODE : E_CANC - " + RS_CODE_LOG);
    					log.debug("■ RS_MSG : [MES 실적등록취소 / WMS 입고요청&입고취소 실패]" + RS_MSG);
    					//System.out.println("RS_CODE_RB : " + ROLLBACK_TYPE + " - E_CANC");
    					//System.out.println("RS_MSG_RB : " + ROLLBACK_TYPE + " - " + map.getString("RS_MSG_RB").toString());
    					
    					//model.put("RS_CODE_RB", "E_CANC");// CANC_SAP 실패시 리턴코드를 E_CANC 으로 전송
    					//model.put("RS_MSG_RB", map.getString("RS_MSG_RB").toString());
    					
    					model.put("RS_CODE", "E_CANC");// CANC_SAP 실패시 리턴코드를 E_CANC 으로 전송
    					model.put("RS_MSG", "수동으로 POP 에서 실적등록 바랍니다. (시스템 담당자 문의필요)");
    					
    					log.debug("======== [AGV_ROLLBACK 실패] ========");
    				}
            	}
            	
				if(model.get("RS_CODE") != null & "".equals(model.get("RS_CODE").toString())) {
					model.put("RS_CODE", "E0");
				}
				
				if(model.get("RS_MSG") != null & "".equals(model.get("RS_MSG").toString()) & "".equals(RS_MSG)) {
					model.put("RS_MSG", "예상치못한 오류발생(시스템 담당자 문의필요");
				}

				//log.debug("■ RS_CODE : {} " + RS_CODE_LOG);
				//log.debug("■ RS_MSG : {} ", RS_MSG_LOG);
				log.debug("======== [AGV_ROLLBACK 끝] ========");
				log.debug("======== [AGV_ROLLBACK 끝] ========");
				log.debug("======== [AGV_ROLLBACK 끝] ========");
            }
    	} else if("N".equals(agvNewYn)){
		//OLD 로직 사용
    	//TB_MAS012 의 AGV_NEW_YN = 'N' 이어야함, 사용시 프로시저나 XML 수정필요 
    		System.out.println("OLD 로직 사용");
    		log.debug("========    [AGV_OLD]    ========");
    		
    		try {
            	// Step1. MES DB Insert

            	map.put("P_WERKS", jobj.getString("P_WERKS"));
            	map.put("P_MACH_CD", jobj.getString("P_MACH_CD"));
            	map.put("P_USERID", jobj.getString("P_USERID"));
            	map.put("P_ORDER_NO", jobj.getString("P_ORDER_NO"));
            	map.put("P_WRK_ORDR_NO", jobj.getString("P_WRK_ORDR_NO"));
            	map.put("P_WRK_ORDR_SEQNO", jobj.getString("P_WRK_ORDR_SEQNO"));
            	map.put("P_MATNR", jobj.getString("P_MATNR"));
            	map.put("P_PRFM_QTY", jobj.getString("P_PRFM_QTY"));
            	map.put("P_IND_BCD", jobj.getString("P_IND_BCD"));
            	map.put("P_LOT_NO", jobj.getString("P_LOT_NO"));
            	map.put("Lang", jobj.getString("Lang"));
            	map.put("RS_CODE", RS_CODE);
            	map.put("RS_MSG", RS_MSG);
            	map.put("P_PRFM_FUNC", P_PRFM_FUNC);
            	map.put("P_USE_FUNC", P_USE_FUNC);
            	map.put("P_WDOC_NO", P_WDOC_NO);

            	map.setModuleCommand("Work", "WRK00");

            	list = commonService.getList(map);
            	
            	if (map.getString("RS_CODE").toString().equals("S"))
            	{
        			cur1 = CommonUtil.processList(map, "P_CUR_1");

        			prfmFunc = map.get("P_PRFM_FUNC").toString();
        			rtnMap = cur1.get(0);
        			ifId = rtnMap.get("I_IF_ID").toString();
        			ifMesKey = rtnMap.get("I_IF_KEY").toString();
        			sDocNo = rtnMap.get("I_SDOC_NO").toString();
        			rtnString = rtnMap.get("I_PRFM_LIST").toString();
        			wDocNo = rtnMap.get("I_WDOC_NO").toString();
        			
        			request.setAttribute("IFID", ifId);
        			request.setAttribute("DOC_NO", sDocNo);
        			
        			// SAP 실적 전송
        			responseMap = sndIFData(request, ifId, sDocNo);
        			
        			jObj = new JSONObject(rtnString);
    				map.clear();
        			String jsonStr = CommonUtil.mapToJson(map);

        			// SAP 실적 전송 성공 시 WMS 입고요청
        			if (responseMap.get("RS_CODE").toString().equals("S"))
        			{
        				// TO-DO. WMS 데이터 전송 및 MES 상태 업데이트 진행
    					
    					map.put("P_JSONSTR", rtnString.replaceAll("\"", "^")); //
    					map.put("P_JSONSTR1", jsonStr);
    					map.put("P_WERKS", jobj.getString("P_WERKS"));
    					map.put("P_MATNR", jobj.getString("P_MATNR"));
    					map.put("P_IND_BCD", jobj.getString("P_IND_BCD"));
    					map.put("P_DOC_NO", wDocNo);
    					map.put("P_EMPLY_NO", jobj.getString("P_USERID"));
    					map.put("P_MACH_CD", jobj.getString("P_MACH_CD"));
    					map.put("RS_CODE",RS_CODE);
    					map.put("RS_MSG", RS_MSG);
    					map.setModuleCommand("Work", "WRK00_1");
    					
    					responseListWms = commonService.getList(map);

            			model.put("RS_CODE", map.get("RS_CODE"));
                		model.put("RS_MSG", map.get("RS_MSG"));
        				
                		// WMS 입고요청 실패 시 롤백
                		// Step 1. SAP 실적전송 취소
                		// Step 2. MES 데이터 삭제
                		if (!map.get("RS_CODE").toString().equals("S")) {
                			map.clear();
                			map.put("P_WERKS", jobj.getString("P_WERKS"));
                			map.put("P_MACH_CD", jobj.getString("P_MACH_CD"));
                			map.put("P_IND_BCD", jobj.getString("P_IND_BCD"));
                			map.put("P_USERID", jobj.getString("P_USERID"));
                	        map.put("IFID", "MES_IF_129");
                	        map.put("DOC_NO", sDocNo);
                			map.put("RS_CODE", RS_CODE);
                			map.put("RS_MSG", RS_MSG);
                			
//                			boolean rtnbool = sendCanMesData(map);
                			rtnDocNo = sendCanMesData(map);
                			
                			if (!rtnDocNo.contentEquals("")) {
                				map.remove("DOC_NO");
                				map.put("DOC_NO", rtnDocNo);
                				rtnbool = sendCanIFData_old(map, rtnDocNo);
                			}
                		}
        			} else	// SAP 실적전송 실패 시 MES Data 삭제
        			{
        				/// TO-DO. 롤백처리 (SAP 실적전송 취소)
//            			model.put("RS_CODE", responseMapWms.get("RS_CODE"));
//                		model.put("RS_MSG", responseMapWms.get("RS_MSG"));

//            			model.put("RS_CODE", responseMap.get("RS_CODE"));
            			model.put("RS_CODE", "E1");			// SAP 전송 실패 시 리턴코드를 E1으로 전송
                		model.put("RS_MSG", responseMap.get("RS_MSG"));

                		if (!responseMap.get("RS_CODE").toString().equals("S")) {
                			map.clear();
                			map.put("P_WERKS", jobj.getString("P_WERKS"));
                			map.put("P_MACH_CD", jobj.getString("P_MACH_CD"));
                			map.put("P_IND_BCD", jobj.getString("P_IND_BCD"));
                			map.put("P_USERID", jobj.getString("P_USERID"));
                	        map.put("IFID", "MES_IF_129");
                	        map.put("DOC_NO", sDocNo);
                			map.put("RS_CODE", RS_CODE);
                			map.put("RS_MSG", RS_MSG);
                			
                			rtnDocNo = sendCanMesData(map);
                		}
        			}
            	} else {
        			model.put("RS_CODE", map.getString("RS_CODE").toString().replace("N", "E"));	// MES 입력 실패 시 리턴코드를 E로 전송
            		if (map.get("RS_MSG").toString().contains("ORA-00001")) {
            			model.put("RS_MSG", jobj.getString("P_IND_BCD").toString() + " 개별바코드 기 존재");
            		} else {
            			model.put("RS_MSG", map.get("RS_MSG"));
            		}
            	}

            	log.debug("model :" + model);
            } catch(Exception ex) {
            	if (ex.getMessage().toString().contains("ORA-00001")) {
            		model.put("RS_CODE", "E");	// MES 입력 실패 시 리턴코드를 E로 전송
            		model.put("RS_MSG", jobj.getString("P_IND_BCD").toString() + " 개별바코드 기 존재");
            	} else {
            		map.put("P_WERKS", jobj.getString("P_WERKS"));
            		map.put("P_MACH_CD", jobj.getString("P_MACH_CD"));
            		map.put("P_IND_BCD", jobj.getString("P_IND_BCD"));
            		map.put("P_USERID", jobj.getString("P_USERID"));
            		map.put("IFID", "MES_IF_129");
            		map.put("DOC_NO", sDocNo);
            		map.put("RS_CODE", RS_CODE);
            		map.put("RS_MSG", RS_MSG);
            		
            		rtnDocNo = sendCanMesData(map);
            		
            		if (!rtnDocNo.contentEquals("")) {
            			map.remove("DOC_NO");
            			map.put("DOC_NO", rtnDocNo);
            			rtnbool = sendCanIFData_old(map, rtnDocNo);
            		}
            		model.put("RS_CODE", "E1");		// SAP 전송 실패 시 리턴코드를 E1으로 전송
            		model.put("RS_MSG", ex.getMessage());
            	}
            }
    	} else {
    		log.debug("======== [AGV 실패] ========");
    		log.debug("======== [AGV 실패] ========");
    		log.debug("======== [AGV 실패] ========");
    		log.debug("■ [설비정보 누락(AGV_NEW_YN 값 체크필요)");
    		model.put("RS_CODE", "E0");		// SAP 전송 실패 시 리턴코드를 E1으로 전송
    		model.put("RS_MSG", "설비정보를 확인하세요(시스템 담당자 문의필요)");
    	}
    	log.debug("======== [AGV 끝] ========");
    	log.debug("======== [AGV 끝] ========");
    	log.debug("======== [AGV 끝] ========");
		
		return JSON_VIEW;
	}
	
	//WCS redirect 
	public String redirectWcsList(DataMap map, int count) throws Exception {
		try {
			if (count >= MAX_RETRIES) {
		        return "최대 요청 횟수 초과";
		    }
			
			commonService.getWcsList(map);
			
			if (map.get("P_RESULT") != null && map.get("P_RESULT").toString().equals("S")) {
		        return "S";
		    }
		} catch (Exception e) {
			// TODO: handle Exception
			throw new Exception();
		}
	    return redirectWcsList(map, count + 1);
	}
	
	//SAP 별도 트랜잭션
	//SAP 데이터 저장 
	public Map<String, String> sapDataSave(DataMap dataMap) throws Exception {
		Map<String, String> result = new HashMap<String, String>();
		
		
		
		return result;
	}

	@RequestMapping("/common/index.*")
	public String index(HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		List list = commonService.getList(systemConfig.getCmmonType() + ".PARTCOMBO", map);

		model.put("PARTCOMBO", list);

		map.put("CODE", "LANGKY");

		List list1 = commonService.getList("Common.COMCOMBO", map);

		model.put("LANGKY", list1);

		List list2 = commonService.getList("Common.LOGINMSG", map);

		map.clear();
		model.put("MSG", list2);

		return "/" + systemConfig.getTheme() + "/index";
	}

	@RequestMapping("/common/{page}.*")
	public String page(@PathVariable String page) {
		return "/common/" + page;
	}

	@RequestMapping("/common/{module}/{page}.*")
	public String mpage(@PathVariable String module, @PathVariable String page) {

		return "/common/" + module + "/" + page;
	}

	@RequestMapping("/common/{module}/{sub}/{page}.*")
	public String spage(@PathVariable String module, @PathVariable String sub, @PathVariable String page) {

		return "/common/" + module + "/" + sub + "/" + page;
	}

	@RequestMapping("/common/Common/insert/json/USRLO1.*")
	public String usrloinsert1(HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("Common", "USRLO");

		Object data = commonService.insert(map);

		BaseUser user = (BaseUser) request.getSession().getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
		DataMap usrlo = user.getUsrlo();
		String progid = map.getString("PROGID");
		if (usrlo.containsKey(progid)) {
			List list = usrlo.getList(progid);
			list.add(map);
		} else {
			List newData = new ArrayList();
			newData.add(map);
			usrlo.put(progid, newData);
		}

		model.put("data", data);

		return JSON_VIEW;
	}

	@RequestMapping("/common/Common/update/json/USRLO1.*")
	public String usrloupdate1(HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("Common", "USRLO");

		int rs = commonService.update(map);

		BaseUser user = (BaseUser) request.getSession().getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
		DataMap usrlo = user.getUsrlo();
		String progid = map.getString("PROGID");
		if (usrlo.containsKey(progid)) {
			List list = usrlo.getList(progid);
			list.add(map);
		} else {
			List newData = new ArrayList();
			newData.add(map);
			usrlo.put(progid, newData);
		}

		model.put("data", rs);

		return JSON_VIEW;
	}

	@RequestMapping("/common/Common/insert/json/SYSGRIDCOL.*")
	public String usrloinsert(HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		BaseUser user = (BaseUser) request.getSession().getAttribute(CommonConfig.SES_USER_OBJECT_KEY);

		commonService.usrloinsert(map, user);
		model.put("data", "OK");

		return JSON_VIEW;
	}

	@RequestMapping("/common/Common/update/json/SYSGRIDCOL.*")
	public String usrloupdate(HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		BaseUser user = (BaseUser) request.getSession().getAttribute(CommonConfig.SES_USER_OBJECT_KEY);

		commonService.usrloupdate(map, user);
		model.put("data", "OK");

		return JSON_VIEW;
	}

	@RequestMapping("/common/{module}/count/json/{command}.*")
	public String count(HttpServletRequest request, @PathVariable String module, @PathVariable String command,
			Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);

		int count = commonService.getCount(map);

		map.clear();
		model.put("data", count);

		return JSON_VIEW;
	}

	@RequestMapping("/common/{module}/paging/json/{command}.*")
	public String paging(HttpServletRequest request, @PathVariable String module, @PathVariable String command,
			Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);

		List list = commonService.getPagingList(map);

		map.clear();
		model.put("data", list);

		return JSON_VIEW;
	}

	@RequestMapping("/common/{module}/list/json/{command}.*")
	public String list(HttpServletRequest request, @PathVariable String module, @PathVariable String command, Map model)
			throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);

		List list = commonService.getList(map);

		map.clear();
		model.put("data", list);

		return JSON_VIEW;
	}

	@RequestMapping("/common/{module}/datalist/{dataType}/{command}.*")
	public String datalist(HttpServletRequest request, @PathVariable String module, @PathVariable String command,
			Map model) throws SQLException, InterruptedException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);

		String listData = commonService.getJdbcData(map);

		map.clear();
		model.put("data", listData);

		return TEXT_VIEW;
	}

	@RequestMapping("/common/search/json/data.*")
	public String searchList(HttpServletRequest request, Map model) throws SQLException, InterruptedException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("COMMON", "SEARCH");

		searchSql(map);

		String listData = commonService.getJdbcData(map);

		map.clear();
		model.put("data", listData);

		return TEXT_VIEW;
	}

	public void searchSql(DataMap map) throws SQLException {
		StringBuilder sql = new StringBuilder();

		DataMap inputParam = map.getMap(CommonConfig.INPUT_SEARCH_PARAM_KET);
		DataMap itemMap = commonSearch.getItemMap(map.getString("COMMPOPID"));
		DataMap itemData;
		Iterator it = inputParam.keySet().iterator();
		while (it.hasNext()) {
			Object key = it.next();
			itemData = itemMap.getMap(key);
			if (itemData.getString("SEARCHTYPE").equals("LIKE")) {
				sql.append(" AND ").append(key).append(" LIKE '%").append(inputParam.get(key)).append("%' ");
			} else if (key != CommonConfig.RANGE_SQL_KEY && key != CommonConfig.WHARE_SQL) {
				sql.append(" AND ").append(key).append(" = '").append(inputParam.get(key)).append("' ");
			}
		}

		if (sql.length() > 0) {
			if (map.containsKey(CommonConfig.RANGE_SQL_KEY)) {
				sql.append(" ").append(map.get(CommonConfig.RANGE_SQL_KEY));
				map.put(CommonConfig.RANGE_SQL_KEY, sql.toString());
			} else {
				map.put(CommonConfig.RANGE_SQL_KEY, sql.toString());
			}
		}

		DataMap head = commonSearch.getHead(map);

		List<DataMap> itemList = commonSearch.getItem(map.getString("COMMPOPID"));

		DataMap row;

		StringBuilder col = new StringBuilder();

		for (int i = 0; i < itemList.size(); i++) {
			row = itemList.get(i);
			if (row.getInt("GWIDTH") > 0) {
				if (col.length() > 0) {
					col.append(",");
				}
				col.append(row.getString("CPOPITEMID"));
			}
		}
		map.setModuleCommand("Common", "SEARCH");

		map.put("COL", col.toString());
		map.put("TABLE", head.getString("VIEWTNAME"));
	}

	@RequestMapping("/common/{module}/map/json/{command}.*")
	public String map(HttpServletRequest request, @PathVariable String module, @PathVariable String command, Map model)
			throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);

		Map data = commonService.getMap(map);

		model.put("data", data);
		model.put("map", map);

		return JSON_VIEW;
	}

	@RequestMapping("/common/{module}/insert/json/{command}.*")
	public String insert(HttpServletRequest request, @PathVariable String module, @PathVariable String command,
			Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);

		Object data = commonService.insert(map);

		map.clear();
		model.put("data", data);

		return JSON_VIEW;
	}

	@RequestMapping("/common/{module}/update/json/{command}.*")
	public String update(HttpServletRequest request, @PathVariable String module, @PathVariable String command,
			Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);

		int rs = commonService.update(map);

		map.clear();
		model.put("data", rs);

		return JSON_VIEW;
	}

	@RequestMapping("/common/{module}/delete/json/{command}.*")
	public String delete(HttpServletRequest request, @PathVariable String module, @PathVariable String command,
			Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);

		int rs = commonService.delete(map);

		map.clear();
		model.put("data", rs);

		return JSON_VIEW;
	}

	@RequestMapping("/common/excelParam/json/save.*")
	public String excelParamSave(HttpSession session, HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		String key = UUID.randomUUID().toString();

		session.setAttribute(key, map);

		model.put("key", key);

		return JSON_VIEW;
	}

	@RequestMapping("/common/{module}/excel/{command}.*")
	public String excel(HttpServletRequest request, @PathVariable String module, @PathVariable String command,
			Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);

		String data = commonService.getListString(map);

		return excelView(map, model, data);
	}

	@RequestMapping("/common/excel/temp.*")
	public String excelTemp(HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		String data;
		if (map.containsKey("dataString")) {
			data = map.getString("dataString");
		} else {
			data = "";
		}

		return excelView(map, model, data);
	}

	@RequestMapping("/common/{module}/{type}/fileUp/{command}.*")
	public String fileUp(HttpServletRequest request, @PathVariable String module, @PathVariable String type,
			@PathVariable String command, Map model) throws FileNotFoundException, IOException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);

		DataMap fileMap = map.getMap(CommonConfig.FILE_MAP_KEY);
		List list = fileMap.getList(CommonConfig.FILELIST_KEY);

		map.put("data", list);
		fileMap.clear();

		return "/common/fileAjaxUp";
	}

	@RequestMapping("/common/fileUp/file.*")
	public String fileUpDummy(HttpServletRequest request, Map model) throws FileNotFoundException, IOException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		DataMap fileMap = map.getMap(CommonConfig.FILE_MAP_KEY);
		List list = fileMap.getList(CommonConfig.FILELIST_KEY);
		map.put("data", list);

		fileMap.clear();
		return "/common/fileAjaxUp";
	}

	@RequestMapping("/common/image/fileUp/mobile.*")
	public String fileUpMobile(HttpServletRequest request, Map model) throws FileNotFoundException, IOException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		DataMap fileMap = map.getMap(CommonConfig.FILE_MAP_KEY);
		List list = fileMap.getList(CommonConfig.FILELIST_KEY);
		DataMap rsMap = new DataMap();
		rsMap.put("UUID", list.get(0).toString());

		fileMap.clear();
		map.clear();

		model.put("data", rsMap);

		return JSON_VIEW;
	}

	@RequestMapping("/common/fileUp/mfile.*")
	public String mFileUpDummy(HttpServletRequest request, Map model) throws FileNotFoundException, IOException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		DataMap fileMap = map.getMap(CommonConfig.FILE_MAP_KEY);
		String guuid = fileMap.getString(CommonConfig.FILEGROUP_KEY);

		map.put("data", "[" + guuid + "]");
		fileMap.clear();

		return "/common/fileAjaxUp";
	}

	@RequestMapping("/common/fileGroupUp/file.*")
	public String fileUpGroup(HttpServletRequest request, Map model) throws FileNotFoundException, IOException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		DataMap fileMap = map.getMap(CommonConfig.FILE_MAP_KEY);
		String guuid = fileMap.getString(CommonConfig.FILEGROUP_KEY);
		List list = new ArrayList();
		list.add(guuid);

		map.put("data", list);

		fileMap.clear();
		return "/common/fileAjaxUp";
	}

	@RequestMapping("/common/image/fileUp/image.*")
	public String fileUpImageDummy(HttpServletRequest request, Map model) throws FileNotFoundException, IOException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		DataMap fileMap = map.getMap(CommonConfig.FILE_MAP_KEY);
		List list = fileMap.getList(CommonConfig.FILELIST_KEY);

		map.put("data", list);
		fileMap.clear();
		map.clear();

		return "/common/fileAjaxUp";
	}

	@RequestMapping("/common/image/fileGroupUp/image.*")
	public String fileGroupUpImageDummy(HttpServletRequest request, Map model)
			throws FileNotFoundException, IOException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		DataMap fileMap = map.getMap(CommonConfig.FILE_MAP_KEY);
		String guuid = fileMap.getString(CommonConfig.FILEGROUP_KEY);
		List list = new ArrayList();
		list.add(guuid);

		map.put("data", list);
		fileMap.clear();
		map.clear();

		return "/common/fileAjaxUp";
	}

	@RequestMapping("/common/fileDown/file.*")
	public String doDownload(HttpServletRequest request, Map model) throws Exception {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		File file = null;
		if (map.getString("UUID").equals("CUBE_COL_NAME_UUID")) {
			return null;
		}

		if (map.getString("UUID").equals("")) {
			file = new File(respository.getPath(), "noImage");
			model.put("downloadFile", file);
			model.put("fileName", "");
		} else {
			DataMap data = commonService.getMap(map);
			file = commonService.getFile(data);
			if (!file.isFile()) {
				file = new File(respository.getPath());
			}

			model.put("downloadFile", file);
			model.put("fileName", java.net.URLEncoder.encode(data.getString("NAME"), "UTF-8"));
		}
		map.clear();
		return FILE_VIEW;
	}

	@RequestMapping("/common/load/excel/json/grid.*")
	public String excelGrid(HttpServletRequest request, Map model)
            throws IOException, EncryptedDocumentException, InvalidFormatException, SQLException, RuntimeException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		// 이전 페이지(호출한 JSP)의 전체 URL을 가져옵니다.
		String referer = request.getHeader("Referer");
		String menuId = "";
		System.out.println("### 요청이 들어온 곳: " + referer);

		if (referer != null && referer.contains("menuId=")) {
			String[] parts = referer.split("menuId=");
			if (parts.length > 1) {
				menuId = parts[1];
				int ampIdx = menuId.indexOf("&");
				if (ampIdx > -1) {
					menuId = menuId.substring(0, ampIdx);
				}
			}
		}

		List data = commonService.getExcel(map);

//		if ("QLT05".equals(menuId)) {
//			data = qualityService.convertExcelData(data, map, "MATNR");
//		}

		model.put("data", data);
		map.clear();
		return JSON_VIEW;
	}

	@RequestMapping("/sample/{module}/excel/{command}.*")
	public String excelM(HttpServletRequest request, @PathVariable String module, @PathVariable String command,
			Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);

		List list = commonService.getList(map);

		return excelView(map, model, list);
	}

	@RequestMapping("/common/{module}/gridSave/json/{command}.*")
	public String gridSave(HttpServletRequest request, @PathVariable String module, @PathVariable String command,
			Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(module, command);

		DataMap data = commonService.gridSave(map);

		model.putAll(data);
		map.clear();

		return JSON_VIEW;
	}

	@RequestMapping("/common/label/json/reload.*")
	public String loadLabel(HttpServletRequest request, Map model) throws SQLException, IOException {

		commonService.loadLabel();

		model.put("data", "reload");

		return JSON_VIEW;
	}

	@RequestMapping("/common/message/json/reload.*")
	public String loadMessage(HttpServletRequest request, Map model) throws SQLException, IOException {

		commonService.loadMessage();

		model.put("data", "reload");

		return JSON_VIEW;
	}

	@RequestMapping("/common/search/json/reload.*")
	public String loadSearch(HttpServletRequest request, Map model) throws SQLException, IOException {

		commonService.loadSearch();

		// UriInfo uriInfo =
		// (UriInfo)request.getAttribute(CommonConfig.REQUEST_URI_INFO_KEY);

		// commonSearch.searchFileCreate(uriInfo);

		model.put("data", "reload");

		return JSON_VIEW;
	}

	@RequestMapping("/common/variant/json/insert.*")
	public String variantInsert(HttpSession session, HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		List list = commonService.variantInsert(map);

		BaseUser user = (BaseUser) session.getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
		map.put("USERID", map.getString(CommonConfig.SES_USER_ID_KEY));
		String progId = map.getString("PROGID");
		if (user.getUsrph().containsKey(progId)) {
			if (map.containsKey("UCOUNT")) {
				String parmky = map.getString("PARMKY");
				List tmpList = user.getUsrph().getList(progId);
				Map row = null;
				for (int i = 0; i < tmpList.size(); i++) {
					row = (Map) tmpList.get(i);
					if (row.get("PARMKY").toString().equals(parmky)) {
						tmpList.set(i, map);
						break;
					}
				}
				row.clear();
				tmpList.clear();
			} else {
				user.getUsrph().getList(progId).add(map);
			}
		} else {
			List tmpList = new ArrayList();
			tmpList.add(map);
			user.getUsrph().put(progId, tmpList);
			tmpList.clear();
		}

		if (map.getString("DEFCHK").equals("V")) {
			user.getUsrpi().put(map.getString("PROGID"), list);
		} else {
			map.put("DEFCHK", "V");
			map.setModuleCommand("Common", "USRPH");
			List tmpList = commonService.getList(map);
			if (tmpList.size() == 0) {
				user.getUsrpi().remove(map.getString("PROGID"));
			}
			tmpList.clear();
		}

		model.put("data", list);
		map.clear();

		return JSON_VIEW;
	}

	@RequestMapping("/common/variant/json/delete.*")
	public String variantDelete(HttpSession session, HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		DataMap data = commonService.variantDelete(map);

		BaseUser user = (BaseUser) session.getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
		String progId = map.getString("PROGID");
		String parmky = map.getString("PARMKY");
		List list = user.getUsrph().getList(progId);
		Map row = null;
		for (int i = 0; i < list.size(); i++) {
			row = (Map) list.get(i);
			if (row.get("PARMKY").toString().equals(parmky)) {
				list.remove(i);
				break;
			}
		}
		row.clear();
		list.clear();
		if (data.getString("DEFCHK").equals("V")) {
			user.getUsrpi().remove(progId);
		}

		model.put("data", data);
		map.clear();
		return JSON_VIEW;
	}

	@RequestMapping("/common/userinfo.*")
	public String userInfo(HttpSession session, HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		Object obj = session.getAttribute(CommonConfig.SES_USER_INFO_KEY);
		DataMap data = null;

		if (obj != null) {
			data = (DataMap) obj;
		}

		model.put("data", data);
		map.clear();
		return JSON_VIEW;
	}

	@RequestMapping("/common/api/json/restfulRequest.*")
	public String restfulRequest(HttpSession session, HttpServletRequest request, Map model)
			throws SQLException, TimeoutException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		PostRequest postRequest = new PostRequest();

		DataMap data = postRequest.jsonPost("http://127.0.0.1:8080/common/api/json/restfulResponse.data", map);

		model.putAll(data);
		map.clear();

		return JSON_VIEW;
	}

	@RequestMapping("/common/api/json/restfulResponse.*")
	public String restfulResponse(HttpSession session, HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		map.setModuleCommand("Common", "USRPH");
		map.put("SES_USER_ID", "DEV");
		List list = commonService.getList(map);
		map.put("detail", list);

		model.putAll(map);

		return JSON_VIEW;
	}

	@RequestMapping("/common/page/SQL_GRID_LIST.*")
	public String SQL_GRID_LIST(HttpSession session, HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		String data = commonService.getSqlGridList(map.getString("sql"));

		session.setAttribute("SQL_GRID_DATA_LIST", data);

		String[] cols = data.substring(0, data.indexOf("↑")).split("↓");

		request.setAttribute("cols", cols);
		request.setAttribute("sql", map.getString("sql"));
		map.clear();

		return "/common/tool/sqlGrid";
	}

	@RequestMapping("/common/json/SQL_GRID_DATA_LIST.*")
	public String sqlGridDatalist(HttpSession session, HttpServletRequest request, Map model)
			throws SQLException, InterruptedException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		String listData = (String) session.getAttribute("SQL_GRID_DATA_LIST");

		model.put("data", listData);
		map.clear();

		return TEXT_VIEW;
	}

	@RequestMapping("/common/sql/json/executeUpdate.*")
	public String executeUpdate(HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		int result = commonService.executeUpdate(map.getString("sql"));

		model.put("result", result);
		map.clear();
		return JSON_VIEW;
	}

	@RequestMapping("/common/grid/excel/fileUp/data.*")
	public String excelGridData(HttpSession session, HttpServletRequest request, Map model)
			throws IOException, NoSuchMethodException, SecurityException, IllegalAccessException,
			IllegalArgumentException, InvocationTargetException, EncryptedDocumentException, InvalidFormatException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		// 이전 페이지(호출한 JSP)의 전체 URL을 가져옵니다.
		String referer = request.getHeader("Referer");
		System.out.println("### 요청이 들어온 곳: " + referer);

		List list = map.getList(CommonConfig.FILELIST_KEY);
		if (list.size() > 0) {
			map.put("UUID", list.get(0));
			map.put(CommonConfig.DATA_EXCEL_COLNAME_ROWNUM_KEY, 1);
			List<String> colList = commonService.getExcelCollist(map);
			List<DataMap> dataList = commonService.getExcel(map);

			if (map.containsKey(CommonConfig.EXCEL_DATA_VALIDATION_BEANNAME)) {
				map.put("list", dataList);
				Util util = new Util();
				Object result = util.executeBeanObject(request,
						map.getString(CommonConfig.EXCEL_DATA_VALIDATION_BEANNAME),
						map.getString(CommonConfig.EXCEL_DATA_VALIDATION_FUNCNAME), map);
				request.setAttribute("result", result);
			}
			/*
		)	 * if(dataList.size() > 0){ DataMap row = dataList.get(0); String[] cols = new
			 * String[row.size()-2]; Iterator it = row.keySet().iterator(); int count = 0;
			 * for(int i=0;i<row.size();i++){ String key = it.next().toString();
			 * if(key.equals(CommonConfig.EXCEL_DATA_VALIDATION_RESULT_CODE) ||
			 * key.equals(CommonConfig.EXCEL_DATA_VALIDATION_RESULT_MSG)){ continue; }
			 * cols[count] = key; count++; } request.setAttribute("cols", cols); }
			 */

			String[] cols = new String[colList.size()];
			for (int i = 0; i < colList.size(); i++) {
				cols[i] = colList.get(i);
			}
			colList.clear();
			request.setAttribute("cols", cols);

			session.setAttribute("EXCEL_GRID_DATA_LIST", dataList);
		}
		list.clear();
		map.clear();

		return "/common/tool/excelGrid";
	}

	@RequestMapping("/common/json/EXCEL_GRID_DATA_LIST.*")
	public String excelGridDatalist(HttpSession session, HttpServletRequest request, Map model)
			throws SQLException, InterruptedException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		List listData = (List) session.getAttribute("EXCEL_GRID_DATA_LIST");

		model.put("data", listData);
		map.clear();

		return JSON_VIEW;
	}

	/**
	 * @author 2019.06.28 이범준
	 * @param map
	 * @return json
	 * @throws Exception
	 * @method sessionSaveDataCount PROCS_BTCSEQ_MAP sessionKey값 을 지속적으로 호출
	 */
	@RequestMapping("/common/session/json/sessionSaveDataCount.*")
	public String sessionSaveDataCount(HttpSession session, HttpServletRequest request, Map model) throws Exception {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		String sessionKey = map.getString("sessionKey");
		if (session.getAttribute(sessionKey) == null) {
			session.setAttribute(sessionKey, 0);
		}

		Object obj = session.getAttribute(sessionKey);
		int data = 0;
		if (obj != null) {
			data = (int) obj;
		}

		model.put("data", data);
		map.clear();

		return JSON_VIEW;
	}

	/**
	 * @author 2019.06.28 이범준
	 * @param map
	 * @return json
	 * @throws SQLException
	 * @method procsUpdateDataCount proc 테이블 사용시
	 */
	@RequestMapping("/common/session/json/procsUpdateDataCount.*")
	public String procsUpdateDataCount(HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand("Common", "PROCS_UPD");
		int data = commonService.getCount(map);
		model.put("data", data);
		map.clear();
		return JSON_VIEW;
	}

	/**
	 * @author 2019.06.28 이범준
	 * @param map
	 * @return json
	 * @throws Exception
	 * @method removeSessionSaveData 생성된 저장 세션을 삭제
	 */
	@RequestMapping("/common/session/json/removeSessionSaveData.*")
	public String removeSessionSaveData(HttpSession session, HttpServletRequest request, Map model) throws Exception {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		String sessionKey = map.getString("sessionKey");

		session.removeAttribute(sessionKey);

		model.put("data", "S");
		map.clear();
		return JSON_VIEW;
	}

	@RequestMapping("/common/page/commonPop.*")
	public String commonPop(HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		model.put("param", map);

		Map head = commonSearch.getHead(map);

		if (head == null) {
			head = new DataMap();
		}
		model.put("head", head);

		List itemList = commonSearch.getItem(map.getString("COMMPOPID"));

		if (itemList == null) {
			itemList = new ArrayList();
		}

		// DataMap row;
		// for (int i = 0; i < itemList.size(); i++) {
		// row = (DataMap) itemList.get(i);
		/*
		 * if(row.getString("SEARCHTYPE").equals("HIDDEN")){
		 * if(!row.getString("SDEFAULT").equals(" ")){
		 * if(row.getString("SDEFAULT").equals("SES_USER_COMPANY")){ dfValue = compky;
		 * }else{ dfValue = row.getString("SDEFAULT"); } dfValue =
		 * "value='"+dfValue+"'"; }else{ dfValue = "";
		 */
		// }

		model.put("itemList", itemList);
		return "/common/commonPop";
	}

	@RequestMapping("/common/common_ezprint.*")
	public String ezpage(HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		UriInfo uriInfo = (UriInfo) request.getAttribute(CommonConfig.REQUEST_URI_INFO_KEY);
		model.put("filename", map.get("filename"));
		model.put("andvalue", map.get("andvalue"));
		model.put("width", map.get("width"));
		model.put("height", map.get("height"));
		model.put("url", uriInfo.getUrl());
		return "/common/common_ezprint";
	}

	@RequestMapping("/common/Common/list/json/COMCOMBO.*")
	public String commonCombo(HttpServletRequest request, Map model) throws SQLException {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		map.setModuleCommand(systemConfig.getCmmonType(), "COMCOMBO");

		List list = commonService.getList(map);

		model.put("data", list);
		map.clear();
		return JSON_VIEW;
	}

	/**
	 * 프로시저 공통
	 * 
	 * @param request
	 * @param model
	 * @return
	 * @throws SQLException
	 * @throws JsonProcessingException
	 */
	@RequestMapping("/mes/{module}/{command}/json/datalist.data")
	public String proceduleMes(HttpServletRequest request, @PathVariable String module, @PathVariable String command,
			Map model) throws SQLException, JsonProcessingException {
		// CommonConfig.PARAM_ATT_KEY : ParamData

		DataMesMap map = CommonUtil.convertAll((DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY));
		log.debug("request.getAttribute(CommonConfig.PARAM_ATT_KEY) :"
				+ request.getAttribute(CommonConfig.PARAM_ATT_KEY));

		map.setModuleCommand(module, command);
		String jsonStr = CommonUtil.mapToJson(map);

		map.put("P_JSON_STR", jsonStr);
		map.put("P_IND_BCD_LIST", jsonStr);

		// test
		if (isTest && "QLT07".equals(command)) {
			map.setModuleCommand("mes", "TEST_QLT07");
			List<DataMap> list = commonService.getList(map);
			if (list == null || list.size() == 0) {
				model.put("data", "COMMON_M0447");
				return JSON_VIEW;
			}
			model.put("data", list);
		} else {
			commonService.getMap(map);

			model.put("ERR_MSG", map.get("P_ERR_MSG"));
			model.put("CODE", map.get("P_CODE"));
			model.put("MSG", map.get("P_MSG"));
			model.put("RS_CODE", map.get("RS_CODE"));
			model.put("P_SUCCESS", map.get("P_SUCCESS"));
			model.put("RS_MSG", map.get("RS_MSG"));
			model.put("P_RS_MSG", map.get("P_RS_MSG"));
			model.put("o_msg_CODE", map.get("o_msg_CODE"));
			model.put("o_msg_MSG", map.get("o_msg_MSG"));

			if (!CommonUtil.processSuccess(map) && !map.get("RS_CODE").equals("S")
					&& !map.get("o_msg_CODE").equals("0")) {
				model.put("data", "COMMON_M0447");
				return JSON_VIEW;
			}

			List<DataMap> list = CommonUtil.processList(map, "P_RS_LIST");
			List<DataMap> list2 = CommonUtil.processList(map, "P_RS_LIST_01");
			// List<DataMap> list3 = CommonUtil.processList(map, "P_RS_LIST_02");

			if ("WRK50".equals(command)) {
				model.put("data", list2);
			} else {
				model.put("data", list);
			}
			model.put("data2", list2);

			model.put("DOC_NO", map.get("P_DOC_NO"));
			model.put("DOC_NO1", map.get("P_DOC_NO1"));
			model.put("DOC_NO2", map.get("P_DOC_NO2"));
			model.put("DOC_NO3", map.get("P_DOC_NO3"));
			model.put("DOC_NO4", map.get("P_DOC_NO4"));
			model.put("DOC_NO4", map.get("P_DOC_NO4"));
			model.put("CLOSE_YN", map.get("P_CLOSE_YN"));
			model.put("WDOC_NO", map.get("P_WDOC_NO"));
			model.put("SDOC_NO", map.get("P_SDOC_NO"));

			// 2022-08-31(수요일) 안상현, 점보롤 실적 조회 -> 실적 취소를 위한 변수 추가
			model.put("RS_PRFM_I_IF_ID", map.get("RS_PRFM_I_IF_ID"));
			model.put("RS_PRFM_SQL", map.get("RS_PRFM_SQL"));
			model.put("RS_DISPO_I_IF_ID", map.get("RS_DISPO_I_IF_ID"));
			model.put("RS_DISPO_SQL", map.get("RS_DISPO_SQL"));
			map.clear();
		}
		return JSON_VIEW;
	}

	@RequestMapping("/mobile/{module}/{command}/json/datalist.data")
	public String proceduleMobile(HttpServletRequest request, @PathVariable String module, @PathVariable String command,
			Map model) throws SQLException, JsonProcessingException {
		DataMesMap map = CommonUtil.convertAll((DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY));
		map.setModuleCommand(module, command);
		String jsonStr = CommonUtil.mapToJson(map);
		map.put("P_JSON_STR", jsonStr);
		commonService.getMap(map);

		model.put("P_SUCCESS", map.get("P_SUCCESS"));
		model.put("ERR_MSG", map.get("P_ERR_MSG"));

		if (!CommonUtil.processSuccess(map)) {
			model.put("data", "COMMON_M0447");
			// 20220906 여한진 메세지 파라미터 추가
			model.put("RS_MSG", map.get("P_RS_MSG"));
			return JSON_VIEW;
		}
		List<DataMap> list = CommonUtil.processList(map, "P_RS_LIST");

		model.put("data", list);
		model.put("code", map.get("P_RS_CODE"));
		model.put("msg", map.get("P_RS_MSG"));
		model.put("DOC_NO", map.get("P_DOC_NO"));
		model.put("DOC_NO1", map.get("P_DOC_NO1"));
		model.put("DOC_NO2", map.get("P_DOC_NO2"));
		model.put("DOC_NO3", map.get("P_DOC_NO3"));
		model.put("CLOSE_YN", map.get("P_CLOSE_YN"));
		map.clear();
		return JSON_VIEW;
	}

	@RequestMapping("/common/json/saveITFMAGRP.data")
	public String saveMstMenuGdpt(HttpServletRequest request, Map model) throws Exception {
		DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

		int result = commonService.saveITFMAGRP(map);

		model.put("data", result);
		map.clear();

		return JSON_VIEW;
	}

}