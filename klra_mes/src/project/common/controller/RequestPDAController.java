package project.common.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
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
import project.common.service.CommonService;
import project.common.util.PostRequest;
import project.common.util.Util;
import project.mes.bean.DataMesMap;
import project.mes.service.IFService;
import project.mes.service.IFServiceMapping;
import project.mes.service.MesService;
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

@Controller
public class RequestPDAController extends BaseController {

	static final Logger log = LogManager.getLogger(RequestPDAController.class.getName());
	private boolean isTest = false;

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

	/**
	 * 생산출고요청
	 * 
	 * @param request
	 * @param model
	 * @return
	 * @throws SQLException
	 * @throws JsonProcessingException
	 */
	@RequestMapping("/common/api/requestLAMI.*")
	public String postRequestWMSApiLami(HttpSession session, HttpServletRequest request, Map model) throws Exception {
		DataMap map = new DataMap();
		DataMap wmsMap = new DataMap();
		DataMap rtnMap = new DataMap();
		DataMap rtnWmsMap = new DataMap();
		Map<String, String> responseMap = new HashMap();		// SAP 재고이전 결과 리턴 HashMap
		String paramData = request.getParameter("param");
		String RS_CODE = null, RS_MSG = null, ifId = null, docNo = null, indBcd = null, jsonStr = null, pType = null;
		List<DataMap> list;
		DataMap map1 = CommonUtil.convertAll((DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY));

		Map<String, String> myMap = new HashMap<String, String>();
		myMap = map1.getMap("map");
        try {
        	// Step1. MES DB Insert
    		indBcd = myMap.get("IND_BCD");
    		jsonStr = map1.get("map").toString();
    		pType = myMap.get("P_TYPE");
    		jsonStr = "{\"WERKS\":\"" + myMap.get("WERKS") + "\",\"IND_BCD\":\"" + indBcd + "\"}";
        	jsonStr = jsonStr.replace("\"", "^");
    		
    		map.put("P_TYPE", pType);
    		map.put("P_JSON_STR", jsonStr);
    		map.put("P_IND_BCD", indBcd);

        	map.setModuleCommand("Mobile", "PDA_WRK06_LAMI");

//        	list = commonService.getList(map);
        	rtnMap = commonService.getMap(map);
        	
        	if (map.getString("P_SUCCESS").toString().equals("S")) {
        		// Step2. SAP 재고이전 IF
        		// P_DOC_NO1이 값이 없는 경우는 SAP 재고이전을 하지 않고 바로 WMS 생산요청으로
        		
        		ifId = "MES_IF_131";
        		docNo = map.getString("P_DOC_NO1");
    			
        		if (docNo.equals("")) {				// 밀롤, 슬리터인 경우 SAP 재고이전을 하지 않고 WMS 출고요청 진행
    				wmsMap.put("P_TYPE", "SAVE2");
    				wmsMap.put("P_JSON_STR", jsonStr);

    				wmsMap.setModuleCommand("Mobile", "PDA_WRK06_IF");

    				rtnWmsMap = commonService.getMap(wmsMap);
    	        	
    	        	if (wmsMap.getString("P_SUCCESS").toString().contentEquals("S")) {
            			model.put("RS_CODE", wmsMap.getString("P_SUCCESS").toString());	// 
                		model.put("RS_MSG", wmsMap.getString("P_ERR_MSG").toString());
    	        	} else {
    	        		// TO-DO : Rollback Process WMS 생산출고요청 실패 -> SAP 재고이전 취소, MES DB Rollback
	    				wmsMap.put("P_TYPE", "DELETE3");
	    				wmsMap.put("P_JSON_STR", jsonStr);

	    				wmsMap.setModuleCommand("Mobile", "PDA_WRK06_IF");

	    				rtnWmsMap = commonService.getMap(wmsMap);
	    				
	    				if (wmsMap.getString("P_SUCCESS").toString().contentEquals("S")) {
	            			model.put("RS_CODE", "E");	// 
	                		model.put("RS_MSG", "출고요청 실패로 인한 롤백처리 완료");
	    				} else {
	            			model.put("RS_CODE", wmsMap.get("P_SUCCESS"));	// 
	                		model.put("RS_MSG", wmsMap.get("P_ERR_MSG"));
	    				}
    	        	}
        		} else {							// 포장인 경우 SAP 재고이전, WMS 출고요청 진행
        			request.setAttribute("IFID", ifId);
        			request.setAttribute("DOC_NO", docNo);

        			responseMap = sndIFData(request, ifId, docNo);
        			
        			// SAP I/F 성공 시 WMS 요청 및 MES DB Update
        			if (responseMap.get("RS_CODE").toString().equals("S")) {
        	        	// Step1. MES DB Insert
//        				wmsMap.put("P_WERKS", jobj.getString("WERKS"));
        				wmsMap.put("P_TYPE", "SAVE2");
        				wmsMap.put("P_JSON_STR", jsonStr);

        				wmsMap.setModuleCommand("Mobile", "PDA_WRK06_IF");

        				rtnWmsMap = commonService.getMap(wmsMap);
        	        	
        	        	if (wmsMap.getString("P_SUCCESS").toString().contentEquals("S")) {
                			model.put("RS_CODE", wmsMap.getString("P_SUCCESS").toString());	// 
                    		model.put("RS_MSG", wmsMap.getString("P_ERR_MSG").toString());
        	        	} else {
        	        		// TO-DO : Rollback Process WMS 생산출고요청 실패 -> SAP 재고이전 취소, MES DB Rollback
            				wmsMap.put("P_TYPE", "DELETE1");
            				wmsMap.put("P_JSON_STR", jsonStr);

            				wmsMap.setModuleCommand("Mobile", "PDA_WRK06_IF");

            				rtnWmsMap = commonService.getMap(wmsMap);
            				
            				if (wmsMap.getString("P_SUCCESS").toString().contentEquals("S")) {
            	        		ifId = "MES_IF_132";
            	        		docNo = map.getString("P_DOC_NO1");
            	    			
            	    			request.setAttribute("IFID", ifId);
            	    			request.setAttribute("DOC_NO", docNo);

            	    			responseMap = sndIFData(request, ifId, docNo);		// 재고이전 취소
            	    			
            	    			if (responseMap.get("RS_CODE").toString().contentEquals("S")) {
            	    				wmsMap.put("P_TYPE", "DELETE3");
            	    				wmsMap.put("P_JSON_STR", jsonStr);

            	    				wmsMap.setModuleCommand("Mobile", "PDA_WRK06_IF");

            	    				rtnWmsMap = commonService.getMap(wmsMap);
            	    				
            	    				if (wmsMap.getString("P_SUCCESS").toString().contentEquals("S")) {
            	            			model.put("RS_CODE", "E");	// 
            	                		model.put("RS_MSG", "출고요청 실패로 인한 롤백처리 완료");
            	    				} else {
            	            			model.put("RS_CODE", wmsMap.get("P_SUCCESS"));	// 
            	                		model.put("RS_MSG", wmsMap.get("P_ERR_MSG"));
            	    				}
            	    			}
            					
            				} else {
            					
            				}
                			model.put("RS_CODE", wmsMap.getString("P_SUCCESS").toString());	// 
                    		model.put("RS_MSG", wmsMap.getString("P_ERR_MSG").toString());
        	        	}
        				
        			} else {
                		// TO-DO : Rollback Process SAP 재고이전 실패 -> MES DB Rollback
                		// 1. SAP 재고이전 취소
                		// MES DB Rollback
        				wmsMap.put("P_TYPE", "DELETE3");
        				wmsMap.put("P_JSON_STR", jsonStr);

        				wmsMap.setModuleCommand("Mobile", "PDA_WRK06_IF");

        				rtnWmsMap = commonService.getMap(wmsMap);
        				
        				if (wmsMap.getString("P_SUCCESS").toString().contentEquals("S")) {
                			model.put("RS_CODE", "E");	// 
                    		model.put("RS_MSG", "출고요청 실패로 인한 롤백처리 완료");
        				} else {
                			model.put("RS_CODE", wmsMap.get("P_SUCCESS"));	// 
                    		model.put("RS_MSG", wmsMap.get("P_ERR_MSG"));
        				}
        			}
        		}
        	} else {
        		// TO-DO : Rollback Process
        		// MES DB저장 실패이므로 아무처리하지 않음. 메세지 표시
    			model.put("RS_CODE", map.getString("P_SUCCESS").toString());	// 
        		model.put("RS_MSG", map.getString("P_ERR_MSG").toString());
        	}
        } catch(Exception ex) {
        	// TO-DO : Rollback Process
    		// TO-DO : Rollback Process WMS 생산출고요청 실패 -> SAP 재고이전 취소, MES DB Rollback
			wmsMap.put("P_TYPE", "DELETE1");
			wmsMap.put("P_JSON_STR", jsonStr);

			wmsMap.setModuleCommand("Mobile", "PDA_WRK06_IF");

			rtnWmsMap = commonService.getMap(wmsMap);
			
			if (wmsMap.getString("P_SUCCESS").toString().contentEquals("S")) {
        		ifId = "MES_IF_132";
        		docNo = wmsMap.getString("P_DOC_NO1");
    			
    			request.setAttribute("IFID", ifId);
    			request.setAttribute("DOC_NO", docNo);

    			responseMap = sndIFData(request, ifId, docNo);		// 재고이전 취소
    			
    			if (responseMap.get("RS_CODE").toString().contentEquals("S")) {
    				wmsMap.put("P_TYPE", "DELETE3");
    				wmsMap.put("P_JSON_STR", jsonStr);

    				wmsMap.setModuleCommand("Mobile", "PDA_WRK06_IF");

    				rtnWmsMap = commonService.getMap(wmsMap);
    				
    				if (wmsMap.getString("P_SUCCESS").toString().contentEquals("S")) {
            			model.put("RS_CODE", "E");	// 
                		model.put("RS_MSG", "출고요청 실패로 인한 롤백처리 완료");
    				} else {
            			model.put("RS_CODE", wmsMap.get("P_SUCCESS"));	// 
                		model.put("RS_MSG", wmsMap.get("P_ERR_MSG"));
    				}
    			}
				
			} else {
				
			}
        }
		return JSON_VIEW;
	}

	/**
	 * 생산출고요청
	 * 
	 * @param request
	 * @param model
	 * @return
	 * @throws SQLException
	 * @throws JsonProcessingException
	 */
	@RequestMapping("/common/api/requestIF.*")
	public String postRequestWMSApi(HttpSession session, HttpServletRequest request, Map model) throws Exception {
		DataMap map = new DataMap();
		DataMap wmsMap = new DataMap();
		DataMap rtnMap = new DataMap();
		DataMap rtnWmsMap = new DataMap();
		Map<String, String> responseMap = new HashMap();		// SAP 재고이전 결과 리턴 HashMap
		String paramData = request.getParameter("param");
		String RS_CODE = null, RS_MSG = null, ifId = null, docNo = null, indBcd = null, jsonStr = null, pType = null;
		List<DataMap> list;
		DataMap map1 = CommonUtil.convertAll((DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY));

//    	JSONObject jobj = new JSONObject(paramData);
//		indBcd = map1.get(0).get;
		Map<String, String> myMap = new HashMap<String, String>();
		myMap = map1.getMap("map");
        try {
        	// Step1. MES DB Insert
    		indBcd = myMap.get("IND_BCD");
    		jsonStr = map1.get("map").toString();
    		pType = myMap.get("P_TYPE");
    		jsonStr = "{\"WERKS\":\"" + myMap.get("WERKS") + "\",\"IND_BCD\":\"" + indBcd + "\"}";
        	jsonStr = jsonStr.replace("\"", "^");
    		
    		map.put("P_TYPE", pType);
    		map.put("P_JSON_STR", jsonStr);
    		map.put("P_IND_BCD", indBcd);
//        	indBcd = jobj.get("IND_BCD");
//        	jsonStr = jobj.getString("P_JSON_STR");
//        	map.put("P_TYPE", jobj.getString("P_TYPE"));
//        	map.put("P_JSON_STR", jsonStr);
//        	map.put("P_IND_BCD", indBcd);

        	map.setModuleCommand("Mobile", "PDA_WRK06_IF");

//        	list = commonService.getList(map);
        	rtnMap = commonService.getMap(map);
        	
        	if (map.getString("P_SUCCESS").toString().equals("S")) {
        		// Step2. SAP 재고이전 IF
        		// P_DOC_NO1이 값이 없는 경우는 SAP 재고이전을 하지 않고 바로 WMS 생산요청으로
        		
        		ifId = "MES_IF_131";
        		docNo = map.getString("P_DOC_NO1");
    			
        		if (docNo.equals("")) {				// 밀롤, 슬리터인 경우 SAP 재고이전을 하지 않고 WMS 출고요청 진행
    				wmsMap.put("P_TYPE", "SAVE2");
    				wmsMap.put("P_JSON_STR", jsonStr);

    				wmsMap.setModuleCommand("Mobile", "PDA_WRK06_IF");

    				rtnWmsMap = commonService.getMap(wmsMap);
    	        	
    	        	if (wmsMap.getString("P_SUCCESS").toString().contentEquals("S")) {
            			model.put("RS_CODE", wmsMap.getString("P_SUCCESS").toString());	// 
                		model.put("RS_MSG", wmsMap.getString("P_ERR_MSG").toString());
    	        	} else {
    	        		// TO-DO : Rollback Process WMS 생산출고요청 실패 -> SAP 재고이전 취소, MES DB Rollback
	    				wmsMap.put("P_TYPE", "DELETE3");
	    				wmsMap.put("P_JSON_STR", jsonStr);

	    				wmsMap.setModuleCommand("Mobile", "PDA_WRK06_IF");

	    				rtnWmsMap = commonService.getMap(wmsMap);
	    				
	    				if (wmsMap.getString("P_SUCCESS").toString().contentEquals("S")) {
	            			model.put("RS_CODE", "E");	// 
	                		model.put("RS_MSG", "출고요청 실패로 인한 롤백처리 완료");
	    				} else {
	            			model.put("RS_CODE", wmsMap.get("P_SUCCESS"));	// 
	                		model.put("RS_MSG", wmsMap.get("P_ERR_MSG"));
	    				}
    	        	}
        		} else {							// 포장인 경우 SAP 재고이전, WMS 출고요청 진행
        			request.setAttribute("IFID", ifId);
        			request.setAttribute("DOC_NO", docNo);

        			responseMap = sndIFData(request, ifId, docNo);
        			
        			// SAP I/F 성공 시 WMS 요청 및 MES DB Update
        			if (responseMap.get("RS_CODE").toString().equals("S")) {
        	        	// Step1. MES DB Insert
//        				wmsMap.put("P_WERKS", jobj.getString("WERKS"));
        				wmsMap.put("P_TYPE", "SAVE2");
        				wmsMap.put("P_JSON_STR", jsonStr);

        				wmsMap.setModuleCommand("Mobile", "PDA_WRK06_IF");

        				rtnWmsMap = commonService.getMap(wmsMap);
        	        	
        	        	if (wmsMap.getString("P_SUCCESS").toString().contentEquals("S")) {
                			model.put("RS_CODE", wmsMap.getString("P_SUCCESS").toString());	// 
                    		model.put("RS_MSG", wmsMap.getString("P_ERR_MSG").toString());
        	        	} else {
        	        		// TO-DO : Rollback Process WMS 생산출고요청 실패 -> SAP 재고이전 취소, MES DB Rollback
            				wmsMap.put("P_TYPE", "DELETE1");
            				wmsMap.put("P_JSON_STR", jsonStr);

            				wmsMap.setModuleCommand("Mobile", "PDA_WRK06_IF");

            				rtnWmsMap = commonService.getMap(wmsMap);
            				
            				if (wmsMap.getString("P_SUCCESS").toString().contentEquals("S")) {
            	        		ifId = "MES_IF_132";
            	        		docNo = map.getString("P_DOC_NO1");
            	    			
            	    			request.setAttribute("IFID", ifId);
            	    			request.setAttribute("DOC_NO", docNo);

            	    			responseMap = sndIFData(request, ifId, docNo);		// 재고이전 취소
            	    			
            	    			if (responseMap.get("RS_CODE").toString().contentEquals("S")) {
            	    				wmsMap.put("P_TYPE", "DELETE3");
            	    				wmsMap.put("P_JSON_STR", jsonStr);

            	    				wmsMap.setModuleCommand("Mobile", "PDA_WRK06_IF");

            	    				rtnWmsMap = commonService.getMap(wmsMap);
            	    				
            	    				if (wmsMap.getString("P_SUCCESS").toString().contentEquals("S")) {
            	            			model.put("RS_CODE", "E");	// 
            	                		model.put("RS_MSG", "출고요청 실패로 인한 롤백처리 완료");
            	    				} else {
            	            			model.put("RS_CODE", wmsMap.get("P_SUCCESS"));	// 
            	                		model.put("RS_MSG", wmsMap.get("P_ERR_MSG"));
            	    				}
            	    			}
            					
            				} else {
            					
            				}
                			model.put("RS_CODE", wmsMap.getString("P_SUCCESS").toString());	// 
                    		model.put("RS_MSG", wmsMap.getString("P_ERR_MSG").toString());
        	        	}
        				
        			} else {
                		// TO-DO : Rollback Process SAP 재고이전 실패 -> MES DB Rollback
                		// 1. SAP 재고이전 취소
                		// MES DB Rollback
        				wmsMap.put("P_TYPE", "DELETE3");
        				wmsMap.put("P_JSON_STR", jsonStr);

        				wmsMap.setModuleCommand("Mobile", "PDA_WRK06_IF");

        				rtnWmsMap = commonService.getMap(wmsMap);
        				
        				if (wmsMap.getString("P_SUCCESS").toString().contentEquals("S")) {
                			model.put("RS_CODE", "E");	// 
                    		model.put("RS_MSG", "출고요청 실패로 인한 롤백처리 완료");
        				} else {
                			model.put("RS_CODE", wmsMap.get("P_SUCCESS"));	// 
                    		model.put("RS_MSG", wmsMap.get("P_ERR_MSG"));
        				}
        			}
        		}
        	} else {
        		// TO-DO : Rollback Process
        		// MES DB저장 실패이므로 아무처리하지 않음. 메세지 표시
    			model.put("RS_CODE", map.getString("P_SUCCESS").toString());	// 
        		model.put("RS_MSG", map.getString("P_ERR_MSG").toString());
        	}
        } catch(Exception ex) {
        	// TO-DO : Rollback Process
    		// TO-DO : Rollback Process WMS 생산출고요청 실패 -> SAP 재고이전 취소, MES DB Rollback
			wmsMap.put("P_TYPE", "DELETE1");
			wmsMap.put("P_JSON_STR", jsonStr);

			wmsMap.setModuleCommand("Mobile", "PDA_WRK06_IF");

			rtnWmsMap = commonService.getMap(wmsMap);
			
			if (wmsMap.getString("P_SUCCESS").toString().contentEquals("S")) {
        		ifId = "MES_IF_132";
        		docNo = wmsMap.getString("P_DOC_NO1");
    			
    			request.setAttribute("IFID", ifId);
    			request.setAttribute("DOC_NO", docNo);

    			responseMap = sndIFData(request, ifId, docNo);		// 재고이전 취소
    			
    			if (responseMap.get("RS_CODE").toString().contentEquals("S")) {
    				wmsMap.put("P_TYPE", "DELETE3");
    				wmsMap.put("P_JSON_STR", jsonStr);

    				wmsMap.setModuleCommand("Mobile", "PDA_WRK06_IF");

    				rtnWmsMap = commonService.getMap(wmsMap);
    				
    				if (wmsMap.getString("P_SUCCESS").toString().contentEquals("S")) {
            			model.put("RS_CODE", "E");	// 
                		model.put("RS_MSG", "출고요청 실패로 인한 롤백처리 완료");
    				} else {
            			model.put("RS_CODE", wmsMap.get("P_SUCCESS"));	// 
                		model.put("RS_MSG", wmsMap.get("P_ERR_MSG"));
    				}
    			}
				
			} else {
				
			}
        }
		return JSON_VIEW;
	}

	/**
	 * SAP 재고이전처리
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
        
        System.out.println("data : "+data);
        map.clear();

        return model;
	}

}