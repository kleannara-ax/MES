package project.mes.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import project.common.bean.CommonConfig;
import project.common.bean.DataMap;
import project.common.dao.CommonDAO;
import project.common.util.PostRequest;
import project.common.util.RfcCallFunction;
import project.mes.util.CommonUtil;

import javax.servlet.http.HttpServletRequest;
import java.sql.SQLException;
import java.util.*;
import java.util.concurrent.TimeoutException;
import java.util.stream.Collectors;

@Service
public class IFService {
	private static Logger log = Logger.getLogger(IFService.class);
	private static int PER_CNT = 1000;

	@Autowired
	public IFServiceMapping ifServiceMapping;

	@Autowired
	public CommonDAO commonDao;

	@Autowired
	private MesService mesService;

	// @Transactional(propagation = Propagation.NOT_SUPPORTED)
	public DataMap run_START(DataMap map) throws SQLException {
		RfcCallFunction sapConn = new RfcCallFunction();
		List<DataMap> returnList = new ArrayList<DataMap>();
		String ifid = map.get("IFID").toString(); // 인터페이스 아이디
		String werks = map.getString("WERKS"); // 플랜트코드
		String rfcfn = map.get("RFCFN").toString(); // SAP RFC FUNCTION
		String rfctbl = map.get("RFCTBL").toString(); // SAP RFC TABLE
		String rfcp1 = map.get("RFCP1").toString(); // SAP RFC STRUCTURE NAME
		String rfcp2 = map.get("RFCP2").toString(); // 데이터수신범위
		String sysFr = map.getString("SYSFR"); // 송신
		String sysTo = map.getString("SYSTO"); // 수신
		String storlocCd = String.valueOf(map.get("STOR_LOC_CD")); // 저장위치, 배치인 경우 존재하지 않는다.
		String lotno = String.valueOf(map.get("LOT_NO")); // LOT 번호, 배치인 경우 존재하지 않는다.
		String matnr = String.valueOf(map.get("MATNR")); // 자재코드, 배치인 경우 존재하지 않는다.
		String wkdt = String.valueOf(map.get("WKDT")); // 마감년월, 배치인 경우 존재하지 않는다.
		String logseq = "";
		DataMap rsMap = new DataMap();
		rsMap.put("ifid", ifid);
		rsMap.put("rfcfn", rfcfn);
		rsMap.put("rfctbl", rfctbl);
		rsMap.put("rfcp1", rfcp1);
		rsMap.put("rfcp2", rfcp2);
		rsMap.put("WERKS", werks);
		String errMsg = "SUCCESS";

		String plant = mesService.getPlantString(werks); // 플랜트가 존재하지 않을 시 "", 존재 시 플랜트 : 값

		try {
			mesService.updateInterfaceMasterTimeLog(ifid, "S");
			logseq = mesService.insertInterfaceMesLog(ifid, "C", plant, map.getString("PLOGSEQNO")); // logseq : 개발서버의 경우 T, 운영서버는 M
			map.put("LOGSEQNO", logseq);
			mesService.updateInterfaceMasterLog(ifid, logseq); // log
			mesService.startIfMasterCountLog(ifid, logseq);

			if (ifServiceMapping.isPlantUseInParam(ifid)) {
				mesService.addIFMAlog(ifid, werks, logseq);
			}

			DataMap pMap = new DataMap();
			if ("HR".equals(sysFr) && "MES".equals(sysTo)) {
				map.setModuleCommand("Erpif", rfcfn);
				map.put("i_IF_MES_ID", ifid);
				map.put("i_IF_MES_KEY", logseq);
				commonDao.getMap(map);
				if (map.getString("o_msg_code").equals("0")) {
					mesService.updateInterfaceMesLog(logseq, "R", map.getString("o_msg_msg"));
				} else {
					mesService.updateInterfaceMesLog(logseq, "E", map.getString("o_msg_msg"));
				}

			} else if ("WCS".equals(sysFr) && "MES".equals(sysTo)) {
				errMsg = this.send_IFWCS2SAP(map);
				if ("EMPTY".equals(errMsg)) {
					mesService.updateInterfaceMesLog(logseq, "S", "송신 0개");
				} else if (!errMsg.equals("SUCCESS")) {
					mesService.updateInterfaceMesLog(logseq, "E", "송신 처리중 에러 : " + "\n" + errMsg);
				} else {
					mesService.updateInterfaceMesLog(logseq, "S", "송신 완료");
				}
			} else if ("MES".equals(sysFr) && "WCS".equals(sysTo)) {
				map.setModuleCommand("Erpif", rfcfn);
				map.put("i_IF_MES_ID", ifid);
				map.put("i_IF_MES_KEY", logseq);
				commonDao.getMap(map);
				if (map.getString("o_msg_code").equals("0")) {
					mesService.updateInterfaceMesLog(logseq, "S", map.getString("o_msg_msg"));
				} else {
					mesService.updateInterfaceMesLog(logseq, "E", map.getString("o_msg_msg"));
				}
			} else if ("MES".equals(sysFr) && "SAP".equals(sysTo)) { // 실적 요청후 수신
				sendIF(map);
			// 배치일 경우 여기를 실행
			} else if ("SAP".equals(sysFr) && "MES".equals(sysTo)) { // 수신
				pMap.put("I_IF_ID", ifid); // 인터페이스 아이디
				pMap.put("I_IF_KEY", logseq); // logseq : 개발서버의 경우 T, 운영서버는 M

				if (ifid.equals("MES_IF_907")) { // 존재하지 않는다
					pMap.put("I_WERKS", werks);
					pMap.put("I_LOTNO", lotno);
					pMap.put("I_MATNR", matnr);
					pMap.put("I_LGORT", storlocCd);
				} else {
					pMap.put("I_GUBUN", rfcp2); // 데이터수신범위 
					// pMap : I_IF_ID(인터페이스 아이디), I_IF_KEY(logseq : 개발서버의 경우 T, 운영서버는 M), I_GUBUN(데이터 수신범위)만 들어있는 MAP
					// ifid : 인터페이스 아이디
					// rfcp2 : 데이터수신범위
					// werks : 플랜트 코드
					ifServiceMapping.setCallSapParam(pMap, ifid, rfcp2, werks);
				}

				if ("Z_MES_PROD_ORDER".equals(rfcfn)) { // 오더 BOM
					DataMap ifMap = ifServiceMapping.geIFMasterValue(ifid);
					String orderGb = ifMap.getString("BWART");
					ifMap.clear();
					pMap.put("I_OPTYPE", orderGb);
				}
			} else {

			}

			if ("SAP".equals(sysFr) && "MES".equals(sysTo)) { // 수신
				log.debug("[RFC 호출전] " + ifid + " : " + rfcfn + "," + rfctbl + "," + rfcp1 + "," + rfcp2);
				returnList = sapConn.RfcCallTable(rfcfn, rfctbl, rfcp1, pMap, null);
				log.debug("[RFC 호출후] returnList:" + returnList.size());
				mesService.addIfMasterCountLogIFNoError(logseq, "", "RFC통신완료", returnList.size() + "");
				mesService.updateInterfaceMesCount(ifid, logseq, returnList != null ? returnList.size() : 0);
				
				if (returnList.size() > 0) {
					log.debug("[수신데이터] returnList:" + returnList);
					rsMap.put("data", returnList);
					rsMap.put("row_count", returnList.size());
					rsMap.put("logseqno", logseq);
					rsMap.put("WKDT", wkdt); // 마감년월

					errMsg = receive_IF(rsMap, rfcfn, rfctbl, rfcp1, pMap); // 이관
					if (errMsg.equals("SUCCESS")) {
//						mesService.updateInterfaceMesLog(logseq,"R",""); //수신성공
						mesService.endIfMasterCountLogIFNoError(logseq);
						// endSapReceiveOrderList(sapConn, rfcfn, rfctbl, rfcp1, pMap);
					}

				} else {
					log.debug("[수신결과] " + ifid + " : 없음");
				}
			} else {
				//
			}
			mesService.endIfMasterCountLogIFNoError(logseq);
			pMap.clear();
		} catch (Exception e) {
			log.debug("[통신에러] " + ifid + " : " + e);
			// 통신에러 로그처리
			String message = e.getMessage();
			if (e.getMessage().length() > 1200) {
				message = e.getMessage().substring(0, 1200);
			}
			mesService.addIfMasterCountLogIFNoError(logseq, message, "통신에러", returnList.size() + "");
			mesService.updateInterfaceMesLog(logseq, "E", "에러 :  " + message);
		} finally {
			if ("BATCH".equals(map.getString("FR"))) {
				synchronized (this) {
					mesService.updateMasterStatus(map, "E");
					mesService.updateIFGroupRunEnd(map);
				}
			}
			returnList.clear();
		}

		return rsMap;
	}

	// 오더쪽은 R로 보내서 다시 내려받지 않는다.
	// private void endSapReceiveOrderList(RfcCallFunction sapConn, String rfcfn,
	// String rfctbl, String rfcp1, DataMap pMap) {
	// try {
	// pMap.put("I_GUBUN", "R");
	// sapConn.RfcCallTable(rfcfn, rfctbl, rfcp1, pMap, null);
	// }catch (Exception e) {
	//
	// }
	// }

	// @Transactional(propagation = Propagation.NOT_SUPPORTED)
	public String receiveAndSendRESTFUL(HttpServletRequest request, DataMap map) throws SQLException {
		String ifid = map.getString("IFID");
		String logseqno = map.getString("LOGSEQNO");
		String data = null;
		String x1 = "";

		DataMap ifMap = ifServiceMapping.geIFMasterValue(ifid);
		String sysFr = ifMap.getString("SYSFR");
		String sysTo = ifMap.getString("SYSTO");
		String ifName = ifMap.getString("IFKNM");
		ifMap.clear();
		try {
			if (sysFr.equals("WMS") && sysTo.equals("MES") && request != null) {
				x1 = request.getReader().lines().collect(Collectors.toList()).toString();
				//20230308 여한진 WMS전송데이터 로그 필요 없으므로 주석처리
				/*if ("WMS".equals(sysFr) && "MES".equals(sysTo) && x1 != null && !StringUtils.isBlank(x1)) {
					mesService.insertIterfaceWmsLog(x1, ifid, logseqno);
				}*/

			}

			DataMap paramMap = new DataMap();
			List<DataMap> rsList = new ArrayList();
			ObjectMapper mapper = new ObjectMapper();

			if (sysFr.equals("WMS") && sysTo.equals("MES")) {
				List<Map<String, String>> parseList = mapper.readValue(x1, List.class);
				List<Map<String, String>> parseDtList = new ArrayList();

				DataMap rsMap = new DataMap();
				for (Map p1Map : parseList) {
					parseDtList = (List<Map<String, String>>) p1Map.get("list");
					rsList.clear();
					for (Map p2Map : parseDtList) {
						rsMap = new DataMap();
						rsMap.putAll(p2Map);
						rsList.add(rsMap);
					}
				}
				parseList.clear();
				parseDtList.clear();
			}

			paramMap.put("data", rsList);
			paramMap.put("IFID", ifid);
			paramMap.put("LOGSEQNO", logseqno);

			if ("WMS".equals(sysFr) && "MES".equals(sysTo)) {
				data = receive_SAVERESTFUL(paramMap); // 저장
				if (!"SUCCESS".equals(data))
					return data;
				data = receive_RESTFUL(paramMap); // 이관
				if (!"SUCCESS".equals(data))
					return data;
			}

			if ("MES".equals(sysFr) && "WMS".equals(sysTo)) {
				paramMap.put("PLOGSEQNO", map.getString("PLOGSEQNO"));
				paramMap.put("DOC_NO", map.get("DOC_NO"));
				data = send_RESTFUL(paramMap);
				String docNo = map.getString("DOC_NO");
				if (mesService.notEmptyDocNo(docNo)) {
					map.put("RESULT_" + docNo, paramMap.getString("RESULT_" + docNo));
					map.put("RESULT_" + docNo + "_MSG", paramMap.getString("RESULT_" + docNo + "_MSG"));
				}
			}
		} catch (Exception e) {
			log.debug(e);
			data = "FAIL : " + sysFr + "=>" + sysTo + "  [" + ifid + "] " + ifName + " : " + e.getMessage();
		}
		return data;
	}

	// @Transactional
	public String send_RESTFUL(DataMap map) throws SQLException {
		String errMsg = "";
		String ifid = map.get("IFID").toString();
		DataMap ifMap = ifServiceMapping.geIFMasterValue(ifid);
		String callUrl = ifMap.getString("RFCFN");
		String procName = ifMap.getString("PROCNM");
		String ifTbl = ifMap.getString("IFTBL");
		String ifstat = ifMap.getString("IFSTAT");
		ifMap.clear();
		
		String logseqno = map.get("LOGSEQNO").toString();
		String plogseqno = map.getString("PLOGSEQNO");

		String docNo = map.getString("DOC_NO");
		DataMap procMap = new DataMap();
		procMap.put("P_TYPE", "LIST");
		procMap.put("DOC_NO", docNo);
		procMap.put("PROCNM", procName);
		List<DataMap> sendList = new ArrayList<>();
		// WMS 실시간
		if (ifstat.equals("REAL")) {
			if (StringUtils.isNotBlank(plogseqno)) {
				procMap.put("IFTBL", ifTbl);
				procMap.put("ERRWMS", "E"); // wms
				procMap.put("PLOGSEQNO", plogseqno);
				procMap.setModuleCommand("Erpif", "IFTLOGTBL");
				sendList = commonDao.getList(procMap);
			} else {
				procMap.setModuleCommand("Erpif", "MES_IF_XXX");
				procMap.put("TBL", ifTbl);
				sendList = commonDao.getList(procMap);
			}
		} else {
			procMap.setModuleCommand("Erpif", "SP_IF_PUT_IFSWM00X");
			commonDao.getMap(procMap);
			if (!"Y".equals(procMap.get("P_SUCCESS"))) {
				// errMsg = procMap.get("o_msg_msg").toString();
				errMsg = procName + " 프로시저 호출 실패";
				mesService.updateInterfaceMesLog(logseqno, "E", errMsg);
				return errMsg;
			}
			sendList = CommonUtil.processList(procMap, "P_RS_LIST");
		}
		procMap.clear();
		mesService.updateInterfaceMesCount(ifid, logseqno, sendList.size());

		if (sendList == null || sendList.size() == 0) {
			errMsg = "전송할 데이터가 없습니다. " + ifid;
			if (mesService.notEmptyDocNo(docNo)) {
				map.put("RESULT_" + docNo, "EMPTY");
			}
			return errMsg;
		}

		//if (plogseqno.equals("")) {
		//	for (DataMap row : sendList) {
		//		// 방어로직
		//		row.put("TBL", ifTbl);
		//		boolean willSend = this.checkSendInsert1(row);
		//		if (willSend == false) {
		//			errMsg = "전송중복에러 발생. " + ifid;
		//			return errMsg;
		//		}
		//	}
		//}

		PostRequest postRequest = new PostRequest();
		JSONArray jarr = new JSONArray();
		JSONObject jobj = new JSONObject();
		JSONObject jsend = new JSONObject();

		ifServiceMapping.mapingField(ifid, sendList, jarr);
		jsend.put("list", jarr);

		DataMap rd = null;
		try {
			rd = postRequest.jsonPost(callUrl, jsend.toJSONString());
		} catch (TimeoutException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		log.debug(sendList);
		//20230308 여한진 WMS전송데이터 로그 필요 없으므로 주석처리
		//mesService.insertIterfaceWmsLog(jsend.toJSONString(), ifid, logseqno);
		String status = "";
		// log저장
		if (rd.get("result").equals("SUCCESS")) {
			if (mesService.notEmptyDocNo(docNo))
				map.put("RESULT_" + docNo, "S");
			status = "S";
			errMsg = "SUCCESS";
			mesService.updateInterfaceMesLog(logseqno, "S", "송신 " + sendList.size() + "개");
			//20230308 여한진 WMS전송데이터 로그 필요 없으므로 주석처리
			//mesService.updateInterfaceWmsLog(logseqno, "S");
//				mesService.updateInterfaceMesCount(ifid, logseqno, sendList.size());
		} else {
			status = "E";
			errMsg = rd.getString("result");
			if (mesService.notEmptyDocNo(docNo)) {
				map.put("RESULT_" + docNo, "E");
				map.put("RESULT_" + docNo + "_MSG", errMsg);
			}
			//20230308 여한진 WMS전송데이터 로그 필요 없으므로 주석처리
			//mesService.updateInterfaceWmsLog(logseqno, "E");
			mesService.updateInterfaceMesLog(logseqno, "E", "송신 " + sendList.size() + "개 " + errMsg);
//				mesService.updateInterfaceMesCount(ifid, logseqno, sendList.size());
		}
		rd.clear();

		for (HashMap li1 : sendList) {
			DataMap li = new DataMap();
			li.putAll(li1);
			li.setModuleCommand("Erpif", "SP_IF_PUT_IFSWM00X");
			li.put("P_TYPE", "SAVE");
			li.put("P_DOCNO", li.getString("DOC_NO"));
			li.put("P_DOCSEQ", li.getString("DOC_SEQNO"));
			li.put("PROCNM", procName);
			li.put("P_IF_STATUS", status); // S,E
			li.put("P_IF_ERR_MESS", errMsg);
			li.put("P_IF_MES_KEY", logseqno);
			commonDao.getMap(li);
			li.clear();
		}
		sendList.clear();
		
		return errMsg;
	}

	private boolean checkSendInsert1(DataMap row) {
		try {
			if (row.get("TBL") == null)
				return true;
			row.setModuleCommand("Erpif", "updateTableLog1");
			int s = commonDao.update(row);
			return s > 0;
		} catch (Exception e) {
			return true;
		}
	}

	// @Transactional(propagation=Propagation.REQUIRES_NEW)
	public String receive_SAVERESTFUL(DataMap map) throws SQLException {
		String errMsg = "SUCCESS";
		String ifid = map.get("IFID").toString();
		DataMap ifMap = ifServiceMapping.geIFMasterValue(ifid);
		String logseqno = map.get("LOGSEQNO").toString();
		String ifTbl = ifMap.getString("IFTBL");
		String sysFr = ifMap.getString("SYSFR");
		String sysTo = ifMap.getString("SYSTO");
		String ifName = ifMap.getString("IFKNM");
		
		ifMap.clear();
		List<DataMap> listx = null;
		try {
			listx = map.getList("data");
			Map<String, Object> jod = new DataMap();
			//
			List<DataMap> mlist = new ArrayList<DataMap>();
			for (int i = 0; i < listx.size(); i++) {
				DataMap row = new DataMap();
				jod = listx.get(i).getMap("map");
				row.putAll(jod);
				row.put("IF_MES_ID", ifid);
				row.put("IF_MES_KEY", logseqno);
				mlist.add(row);

				if (((i + 1) % PER_CNT) == 0) {
					commonDao.insert(ifTbl + "_MULTI", mlist);
					mlist.clear();
					row.clear();
				}
			}

			if (mlist.size() > 0) {
				commonDao.insert(ifTbl + "_MULTI", mlist);
				mlist.clear();
			}
			//20230308 여한진 WMS전송데이터 로그 필요 없으므로 주석처리
			//mesService.updateInterfaceWmsLog(logseqno, "Y");
			jod.clear();
		} catch (Exception e) {
			log.debug(e);
			errMsg = "FAIL : " + sysFr + "=>" + sysTo + "  [" + ifid + "] " + ifName + " : " + e.getMessage();
			if (errMsg.length() > 1000) {
				errMsg = (listx != null ? "수신 " + listx.size() + "개 -" : "") + errMsg.substring(0, 1000);
			}
			mesService.updateInterfaceMesLog(logseqno, "E", errMsg);
			mesService.updateInterfaceMesCount(ifid, logseqno, listx != null ? listx.size() : null);
		}
		return errMsg;
	}

	// @Transactional(propagation=Propagation.REQUIRES_NEW)
	public String receive_RESTFUL(DataMap map) throws SQLException {
		String errMsg = "SUCCESS";
		String ifid = map.get("IFID").toString();
		DataMap ifMap = ifServiceMapping.geIFMasterValue(ifid);
		String logseqno = map.get("LOGSEQNO").toString();
		String procName = ifMap.getString("PROCNM");
		
		ifMap.clear();
		List<DataMap> listx = map.getList("data");

		if (listx != null && listx.size() > 0) {
			DataMap procMap = new DataMap();
			procMap.put("i_IF_MES_ID", ifid);
			procMap.put("i_IF_MES_KEY", logseqno);
			procMap.put("PROCNM", procName);
			procMap.setModuleCommand("Erpif", "SP_IF_GET_IFRWM00X");
			commonDao.getMap(procMap);
			if (!"0".equals(procMap.get("o_msg_code").toString())) {
				errMsg = procMap.get("o_msg_msg").toString();
				mesService.updateInterfaceMesLog(logseqno, "E", errMsg);
			} else {
				mesService.updateInterfaceMesLog(logseqno, "R", "수신 " + listx.size() + "개");
			}
			mesService.updateInterfaceMesCount(ifid, logseqno, listx.size());
			procMap.clear();
		} else if (listx.size() == 0) {
			mesService.updateInterfaceMesLog(logseqno, "R", "수신 0개");
			mesService.updateInterfaceMesCount(ifid, logseqno, 0);
		}
		listx.clear();
		return errMsg;
	}

	// @Transactional(propagation = Propagation.NOT_SUPPORTED)
	public String receive_IF(DataMap map, String rfcfn, String rfctbl, String rfcp1, DataMap pMap) throws SQLException {
		String errMsg = "SUCCESS";

		List<DataMap> list = map.getList("data");
		String ifid = map.get("ifid").toString();
		String logseqno = map.get("logseqno").toString();
		String procName = ifServiceMapping.geIFMasterValue(ifid, "PROCNM");
		String werks = map.getString("WERKS");
		String wkdt = String.valueOf(map.get("WKDT"));
		RfcCallFunction sapConn = new RfcCallFunction();

		mesService.updateInterfaceMasterLog(ifid, logseqno);

		errMsg = saveToTempdata(map, list, ifid, logseqno, wkdt);
//		if(ifid.equals("MES_IF_101"))  mesService.insertInterfaceMesLog(ifid,"R", "MES_IF_101",logseqno+"TEMP 저장후");
		mesService.updateInterfaceMesCount(ifid, logseqno, list.size());
//		log.error(errMsg);

		if (!errMsg.equals("SUCCESS")) {
			if (!ifid.equals("MES_IF_907"))
				mesService.addIfMasterCountLogIFNoError(logseqno, errMsg, "프로시저 로직 에러", "");
			mesService.updateInterfaceMesLog(logseqno, "E", errMsg);
		} else {
			if (ifid.equals("MES_IF_907")) {
				mesService.updateInterfaceMesLog(logseqno, "C", "SAP재고테이블 저장완료 수신 " + list.size() + "개");

				sapConn.RfcCallTable(rfcfn, rfctbl, rfcp1, pMap, null);
			} else {
				pMap.put("I_GUBUN", "R");

				sapConn.RfcCallTable(rfcfn, rfctbl, rfcp1, pMap, null);

				mesService.addIfMasterCountLogIFNoError(logseqno, "", "프로시저 로직 성공 ", "");
				errMsg = callProcSendData(errMsg, ifid, logseqno, procName, list.size(), werks);
			}
		}
		list.clear();
		return errMsg;
	}

	private String callProcSendData(String errMsg, String ifid, String logseqno, String procName, int savedCount, String werks) throws SQLException {
		DataMap procMap = new DataMap();
		procMap.put("i_IF_MES_ID", ifid);
		procMap.put("i_IF_MES_KEY", logseqno);
		procMap.setModuleCommand("Erpif", procName); // 기준정보
		commonDao.getMap(procMap);
		String plant = mesService.getPlantString(werks);
		// if(ifid.equals("MES_IF_101")) mesService.insertInterfaceMesLog(ifid,"R",
		// "MES_IF_101",logseqno+" PROC 실행후");
		// log.debug("------------------------------" + procMap.get("result"));
		if (!procMap.get("o_msg_code").toString().equals("0")) {
			errMsg = procMap.get("o_msg_msg").toString();
			mesService.updateInterfaceMesLog(logseqno, "E", plant + "템프저장후-" + errMsg);
		} else {
			mesService.updateInterfaceMesLog(logseqno, "R", plant + "수신 " + savedCount + "개");
		}
		procMap.clear();
		return errMsg;
	}

	// @Transactional(propagation=Propagation.REQUIRES_NEW)
	private String saveToTempdata(DataMap map, List<DataMap> list, String ifid, String logseqno, String wkdt) throws SQLException {
		String errMsg = "";
		String msg = "";
		try {
			List<HashMap> mlist1 = new ArrayList<HashMap>();
			HashMap row = new HashMap();

			for (int i = 0; i < list.size(); i++) {
				row = list.get(i).getMap("map");
				row.put("IFID", ifid);
				row.put("LOGSEQNO", logseqno);
				row.put("IF_MES_KEY", logseqno);
				row.put("IF_MES_ID", ifid);
				row.put("WKDT", wkdt);
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				mlist1.add(row);

				if (!ifid.equals("MES_IF_907")) {
					if (((i + 1) % PER_CNT) == 0) {
						commonDao.insert(ifid + "_MULTI", mlist1);
						mlist1.clear();
						row.clear();
					}
				} else {
				commonDao.insert(ifid + "_MULTI", mlist1);
				mlist1.clear();
				row.clear();
					/*else {
						// SAP 재고 확인 인터페이스
						if (!row.get("WERKS").equals("") && !row.get("LGORT").equals("") && !row.get("MATNR").equals("")) {
							commonDao.insert(ifid + "_MULTI", mlist1);
							mlist1.clear();
							row.clear();
						} else {
							if (row.get("WERKS").equals("")) {
								if (errMsg.contains("WERKS"))
									msg = "WERKS의 값이 NULL 입니다.\t";
							}
							if (row.get("LGORT").equals("")) {
								if (errMsg.contains("LGORT"))
									msg = "LGORT의 값이 NULL 입니다.\t";
							}
							if (row.get("MATNR").equals("")) {
								if (errMsg.contains("MATNR"))
									msg = "MATNR의 값이 NULL 입니다.\t";
							}
							//if (row.get("CHARG").equals("")) {
							//	if (errMsg.contains("CHARG"))
							//		msg = "CHARG의 값이 NULL 입니다.\t";
							//}
	
							errMsg = errMsg + msg;
							mlist1.clear();
							row.clear();
							continue;
						}
					}*/
				}
			}

			if (msg.equals("")) {
				errMsg = "SUCCESS";
			}

			if (mlist1.size() > 0) {
				insertTableToPlant(map, ifid, mlist1);
				mlist1.clear();
				row.clear();
			}
			
			mesService.addIfMasterCountLogIFNoError(logseqno, "", "템프테이블 저장성공", "");
		} catch (Exception e) {
			errMsg = e.getMessage();
			if (errMsg.length() > 1000) {
				errMsg = errMsg.substring(0, 1000);
			}
			mesService.addIfMasterCountLogIFNoError(logseqno, errMsg, "템프테이블 저장실패", "");
		}

		return errMsg;
	}

	private void insertTableToPlant(DataMap map, String ifid, List<HashMap> mlist1) throws SQLException {
		if (ifid.equals("MES_IF_113")) {
			map.setModuleCommand("mes", "PLANT");
			List<DataMap> plantList = commonDao.getList(map);
			for (DataMap m : plantList) {
				for (HashMap m1 : mlist1) {
					m1.put("WERKS", m.getString("WERKS"));
				}
				commonDao.insert(ifid + "_MULTI", mlist1);
			}
			plantList.clear();
		} else {
			commonDao.insert(ifid + "_MULTI", mlist1);
		}
	}

	// @Transactional
	public String sendIF(DataMap map) throws SQLException {
		String ifid = map.getString("ifid");
		if (StringUtils.isBlank(ifid) && map.getString("IFID") != null) {
			ifid = map.getString("IFID");
		}
		map.put("ifid", ifid);

		String data = send_IFMES(map);
		return data;
	}

	// @Transactional(propagation = Propagation.NOT_SUPPORTED)
	public String send_IFWCS2SAP(DataMap map) throws SQLException {
		String errMsg = "SUCCESS";
		String ifid = map.getString("IFID");
		DataMap ifMap = ifServiceMapping.geIFMasterValue(ifid);
		String procName = ifMap.getString("PROCNM");
		String logseqno = map.getString("LOGSEQNO");
		String rfcfn = ifMap.getString("RFCFN");
		String rfctbl = ifMap.getString("RFCTBL");
		String rfcp1 = ifMap.getString("RFCP1");
		String rfcp2 = ifMap.getString("RFCP2");

		ifMap.clear();
		
		DataMap row = new DataMap();
		row.put("P_TYPE", "LIST");
		row.setModuleCommand("Erpif", procName);
		commonDao.getMap(row);
		List<DataMap> list = CommonUtil.processList(row, "P_RS_LIST");

		if (list == null || list.size() == 0) {
			return "EMPTY";
		}

		JSONObject jsend = new JSONObject();
		List<DataMap> newList = ifServiceMapping.setSapSendField(ifid, list);

		if (newList.size() == 0) {
			return "EMPTY";
		}

		//DataMap rd = new DataMap();
		// log.debug("\n send : " + jsend);
		List<DataMap> sendlist = new ArrayList();
		RfcCallFunction sapConn = new RfcCallFunction();

		// log.debug("\n------------------\n" +
		// ifServiceMapping.getMapFromJsonObject(jsend));
		DataMap xx = new DataMap();
		xx.put("list", ifServiceMapping.getMapFromJsonObject(jsend).get("list"));
		sendlist.add(xx);

		// log.debug("\nRFC SEND (" + rfcfn + "," + rfctbl + "," + rfcp1 + "," + rfcp2 +
		// ") --------------\n" + sendlist.toString());
		log.debug(
				"\nRFC SEND (" + rfcfn + "," + rfctbl + "," + rfcp1 + "," + rfcp2 + ") -------------- sendList start ");
		DataMap pMap = new DataMap();
		pMap.put("I_IF_ID", ifid);
		try {
			for (int i = 0; i < newList.size(); i++) {
				DataMap dataMap = list.get(i);

				if (procName.equals("SP_IF_GET_IFRWC001")) {
					DataMap wcsmap = new DataMap(); // sap에 전송하지 않고 내부적으로 처리

					String fromstk = dataMap.getString("FROM_STK");
					String tostk = dataMap.getString("TO_STK");

					if (fromstk.equals(tostk) || fromstk.equals("*")) {
						wcsmap.put("P_TYPE", "SAVE");
						wcsmap.put("P_IF_SEQ", dataMap.get("IF_SEQ"));
						wcsmap.put("P_MBLNR", null); // sap 문서번호
						wcsmap.put("P_MJAHR", null); // sap 년도
						wcsmap.put("P_ZRESULT", "S");
						wcsmap.put("P_IF_MES_KEY", logseqno);
						wcsmap.put("P_ZMESSAGE", "MES 내부 처리 완료");
						wcsmap.setModuleCommand("Erpif", procName);
						commonDao.getMap(wcsmap);
						wcsmap.clear();
						continue;
					}
				}
				List<DataMap> sList = new ArrayList<>();
				DataMap sendMap = newList.get(i);
				sList.add(sendMap);
				xx.setModuleCommand("Erpif", "IFWMSLOGSEQNO");
				DataMap keyMap = commonDao.getMap(xx);
				pMap.put("I_IF_KEY", mesService.getLogno(keyMap.getString("LOGSEQNO")));
				//20230203 여한진 WCS 밀롤 이동 시 전기일자 추가
				pMap.put("I_DATE", dataMap.get("IF_DATE"));
				keyMap.clear();
				sapConn.RfcCallTableSendAndReceiveList(rfcfn, rfctbl, "ET_DATA", rfcp1, pMap, sList);
				sList.clear();
				DataMap retMsg = (DataMap) pMap.get("RET_MAP");

				if ("S".equals(retMsg.get("TYPE"))) {
					List<DataMap> retList = (List<DataMap>) pMap.get("ET_DATA");
					if (retList != null && retList.size() > 0) {
						for (DataMap insMap : retList) {
							row.put("P_TYPE", "SAVE");
							row.put("P_IF_SEQ", dataMap.get("IF_SEQ"));
							row.put("P_MBLNR", insMap.getString("MBLNR"));
							row.put("P_MJAHR", insMap.getString("MJAHR"));
							row.put("P_ZRESULT", insMap.getString("TYPE"));
							row.put("P_IF_MES_KEY", logseqno);
							row.put("P_ZMESSAGE", insMap.getString("MESSAGE"));
							commonDao.getMap(row);
						}
					}
					// log update
					mesService.addIfMasterCountLogIFNoError(logseqno, "", "RFC-WCS밀롤재고이동-수신성공", retList.size() + "");
					retList.clear();
				} else {
					String messge = retMsg.getString("MESSAGE");
					row.put("P_TYPE", "SAVE");
					row.put("P_IF_SEQ", dataMap.getString("IF_SEQ"));
					row.put("P_MBLNR", sendMap.getString("MBLNR"));
					row.put("P_MJAHR", sendMap.getString("MJAHR"));
					row.put("P_ZRESULT", retMsg.getString("TYPE"));
					row.put("P_IF_MES_KEY", logseqno);
					row.put("P_ZMESSAGE", messge);
					commonDao.getMap(row);
					errMsg = "ERROR: " + messge;
					mesService.addIfMasterCountLogIFNoError(logseqno, errMsg, "RFC WCS 에러메세지 반환", "");
					//rd.put("result", "ERROR");
					log.debug("[수신테이터오류] " + ifid + " : ");
				}
				retMsg.clear();
				sendMap.clear();
				dataMap.clear();
			}
		} catch (Exception e) {
			errMsg = "ERROR: " + e.getMessage();
			mesService.addIfMasterCountLogIFNoError(logseqno, errMsg, "실적통신실패", "");
			log.debug("[송신반환에러] " + ifid + " : " + e);
		}
		pMap.clear();
		sendlist.clear();
		xx.clear();
		newList.clear();
		list.clear();
		row.clear();
		return errMsg;
	}

	// @Transactional(propagation = Propagation.NOT_SUPPORTED )
	public String send_IFMES(DataMap map) throws SQLException {
		// 2023-02-02 안상현 실적 취소 테스트를 위한 주석
		// String errMsg = "SUCCESS";
		String errMsg = "ERROR";
		String ifid = map.getString("ifid");
		DataMap ifMap = ifServiceMapping.geIFMasterValue(ifid);
		String procName = ifMap.getString("PROCNM");
		String ifTbl = ifMap.getString("IFTBL");
		String sysFr = ifMap.getString("SYSFR");
		String sysTo = ifMap.getString("SYSTO");
		String plogseqno = map.getString("PLOGSEQNO");
		String rfcfn = ifMap.getString("RFCFN");
		String rfctbl = ifMap.getString("RFCTBL");
		String rfcp1 = ifMap.getString("RFCP1");
		String rfcp2 = ifMap.getString("RFCP2");
		String logseqno = null;

		ifMap.clear();
		
		DataMap row = new DataMap();
		List<DataMap> list = null;
		if (StringUtils.isNotBlank(plogseqno)) {
			row.put("IFTBL", ifTbl);
			row.put("ERRSAP", "E"); // sap
			row.put("PLOGSEQNO", plogseqno);
			row.setModuleCommand("Erpif", "IFTLOGTBL");
			list = commonDao.getList(row);
		} else {
			row.put("P_TYPE", "LIST");
			// 2023-01-16(월요일) 안상현, 일마감 중복 데이터 전송 수정
			row.put("P_MDOCNO", map.getString("DOC_NO"));
			row.setModuleCommand("Erpif", procName);
			commonDao.getMap(row);
			list = CommonUtil.processList(row, "P_RS_LIST");
		}
		row.setModuleCommand("Erpif", procName);
		String docNo = map.getString("DOC_NO");

		if (list == null || list.size() == 0) {
			errMsg = "전송할 데이터가 없습니다. " + ifid;
			// if(mesService.notEmptyDocNo(docNo)) map.put("RESULT_"+docNo, "EMPTY");
			return errMsg;
		}

		JSONObject jsend = new JSONObject();
		List<DataMap> newList = ifServiceMapping.setSapSendField(ifid, list);
		
		if (newList.size() == 0) {
			errMsg = "전송할 데이터가 없습니다. " + ifid;
			// if(mesService.notEmptyDocNo(docNo)) map.put("RESULT_"+docNo, "EMPTY");
			return errMsg;
		}

		boolean isInList = checkDocNoInList(map, errMsg, ifid, docNo, newList);
		if (!isInList)
			return errMsg;

		DataMap rd = new DataMap();
		// log.debug("\n send : " + jsend);

		//List<DataMap> sendlist = new ArrayList();
		RfcCallFunction sapConn = new RfcCallFunction();

		// log.debug("\n------------------\n"+ifServiceMapping.getMapFromJsonObject(jsend));
		//DataMap xx = new DataMap();
		//xx.put("list", ifServiceMapping.getMapFromJsonObject(jsend).get("list"));
		//sendlist.add(xx);

		log.debug("\nRFC SEND (" + rfcfn + "," + rfctbl + "," + rfcp1 + "," + rfcp2 + ") -------------- send start1");

		DataMap pMap = new DataMap();
		pMap.put("I_IF_ID", ifid);
		// pMap.put("I_IF_KEY", logseqno);

		// 상품 밀롤 LIFT 생산출고 SAP쪽에서 구조를 다르게 써서 분리필요
		if ("MES_IF_145".equals(ifid)) {
			for (DataMap m : newList) {
				logseqno = mesService.insertInterfaceMesLogRemark(map.getString("IFID"), "S", map.getString("PLOGSEQNO"));

				String mdocNo = m.getString("I_IF_KEY");
//				String mdocNo= m.getString("MDOCNO");
				String mdocseq = m.getString("MDOCSEQ");
				if (mesService.notEmptyDocNo(docNo)) {
					if (!mdocNo.equals(docNo))
						continue;
				}
				m.remove("MDOCSEQ");

				// 방어로직2
//				Map<String,Object> checkParam = new HashMap<>();
//				checkParam.put("TBL", "TB_IFS023");
//				checkParam.put("MDOCNO", m.get("MDOCNO"));
//				checkParam.put("MDOCSEQ", mdocseq);
//				boolean willSend = this.checkSendInsert(checkParam);
//				if(willSend == false) continue;

				DataMap result = sapConn.RfcCallReturnSendOne(rfcfn, rfcp1, m);
				// log.debug("\n result : " + rd.get("result"));
				String type = result.getString("E_RTNCD");
				String rtnMsg = result.getString("E_RTNMSG");
				String mblrn = result.getString("E_MBLRN");
				String mjahr = result.getString("E_MJAHR");

				result.clear();
				
				mesService.startIfMasterCountLog(ifid, logseqno);

				row.put("P_TYPE", "SAVE");
				row.put("P_MDOCNO", mdocNo);
				row.put("P_MDOCSEQ", mdocseq);
				row.put("P_MBLNR", mblrn);
				row.put("P_MJAHR", mjahr);
				row.put("P_ZRESULT", type);
				row.put("P_ZMESSAGE", rtnMsg);
				row.put("P_IF_MES_KEY", logseqno);
				commonDao.getMap(row);
				// if(mesService.notEmptyDocNo(docNo)) map.put("RESULT_"+docNo, type);
				if (type.equals("E")) {
					errMsg = "\n ERROR" + m.getString("I_IF_KEY") + ":" + rtnMsg;
					if (mesService.notEmptyDocNo(docNo)) {
						// map.put("RESULT_"+docNo, "E");
						map.put("RESULT_" + docNo + "_MSG", rtnMsg);
					}
				}
				if (!row.getString("P_ZRESULT").equals("S")) {
					mesService.updateInterfaceMesLog(logseqno, "E", errMsg);
				} else {
					mesService.updateInterfaceMesLog(logseqno, "S", "송신 1개");
				}
			}
		} else {
			// 2023-01-18(수요일) 안상현, 일마감 모니터링을 위한 로그 추가
			log.debug("newList : "+ newList);
			Map<String, List> groupByListMap = ifServiceMapping.groupByList(newList);
			int num = 0;
			
			// 2023-01-18(수요일) 안상현, 일마감 모니터링을 위한 로그 추가
			log.debug("groupByListMap : "+ groupByListMap);
			for (String key : groupByListMap.keySet()) {
				if (key != null && !"".equals(key) && mesService.notEmptyDocNo(docNo) && !key.equals(docNo)) {
					num = num + 1;
					continue;
				}
				try {
					Thread.sleep(1000);
					List<DataMap> groupList = groupByListMap.get(key);

					//if (plogseqno.equals("")) {
					//	// 방어로직1
					//	if (groupList != null) {
					//		for (DataMap li : groupList) {
					//			DataMap checkParam = new DataMap();
					//			checkParam.put("TBL", ifTbl);
					//			checkParam.put("MDOCNO", li.get("MDOCNO"));
					//			checkParam.put("MDOCSEQ", li.get("MDOCSEQ"));
					//			boolean willSend = this.checkSendInsert(checkParam);
					//			if (willSend == false) {
					//				errMsg = "전송중복에러 발생. " + ifid;
					//				return errMsg;
					//			}
					//		}
					//	}
					//}
					
					log.debug("groupList : "+ groupList);
					
					String errMsgSub = "SUCCESS";
					logseqno = mesService.insertInterfaceMesLogRemark(map.getString("IFID"), "S", map.getString("PLOGSEQNO"));

					mesService.startIfMasterCountLog(ifid, logseqno);
					String keyS = key;
					if (!(key != null && !"".equals(key)))	keyS = logseqno;
					//20230203 여한진 재고이전 시 전기일자 추가
					if(ifid.equals("MES_IF_131")) {
						pMap.put("I_DATE", list.get(num).getString("BUDAT"));
					}
					errMsgSub = sendSubList(ifTbl, keyS, ifid, sysFr, sysTo, logseqno, row, groupList, rd, rfcfn, rfctbl, rfcp1, sapConn, pMap, map);
					// if(mesService.notEmptyDocNo(docNo)) map.put("RESULT_"+docNo, "S");
					if (!errMsgSub.equals("")) { // ERROR
						if (mesService.notEmptyDocNo(docNo)) {
							// map.put("RESULT_" + docNo, "E");
							map.put("RESULT_" + docNo + "_MSG", errMsgSub);
						}
						// 2023-02-02 안상현 실적 취소 테스트를 위한 주석
						errMsg += "\n" + key + ":" + errMsgSub;
						mesService.updateInterfaceMesLog(logseqno, "E", "송신 처리중 에러 : " + "\n" + errMsgSub);
					} else { // SUCCESS
						mesService.updateInterfaceMesLog(logseqno, "S", "송신 1개");
					}
					mesService.updateInterfaceMasterLog(ifid, logseqno);
					mesService.endIfMasterCountLogIFNoError(logseqno);
					
					groupList.clear();
					num = num + 1;
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			// log.debug("\n result : " + rd.get("result"));
			// if(!errMsg.equals("SUCCESS")) {
			// mesService.updateInterfaceMesLog(logseqno,"E","송신 처리중 에러 : "+ "\n"+
			// errMsgSub);
			// }else {
			// mesService.updateInterfaceMesLog(logseqno,"S","송신 "+newList.size()+"개");
			// }
			groupByListMap.clear();
		}
		list.clear();
		pMap.clear();
		rd.clear();
		newList.clear();
		row.clear();
		
		// 2023-02-02 안상현 실적 취소 테스트를 위한 주석
		if(errMsg.equals("ERROR")) errMsg = "SUCCESS";
		return errMsg;
	}

	private boolean checkSendInsert(DataMap row) {
		try {
			if (row.get("TBL") == null)
				return true;
			row.setModuleCommand("Erpif", "updateTableLog");
			int s = commonDao.update(row);
			return s > 0;
		} catch (Exception e) {
			return true;
		}
	}

	private boolean checkDocNoInList(DataMap map, String errMsg, String ifid, String docNo, List<DataMap> newList) {
		if (mesService.notEmptyDocNo(docNo)) {
			// long msize = newList.stream().filter(a ->
			// StringUtils.isNotBlank(a.getString("MDOCNO"))).count();
			// if(msize >0) {
			long size = newList.stream().filter(a -> a.getString("MDOCNO").equals(docNo)).count();
			if ("MES_IF_145".equals(ifid))
				size = newList.stream().filter(a -> a.getString("I_IF_KEY").equals(docNo)).count();
			if (size == 0) {
				// map.put("RESULT_" + docNo, "EMPTY");
				return false;
			}
			// }
		}
		return true;
	}

	private String sendSubList(String ifTbl, String mDocNo, String ifid, String sysFr, String sysTo, String logseqno, DataMap row, List<DataMap> newList, DataMap rd, String rfcfn, 
			String rfctbl, String rfcp1, RfcCallFunction sapConn, DataMap pMap, DataMap map) throws SQLException {
		String errMsg = "";
		try {
			String retbl2 = "ET_DATA";
			if ("MES_IF_138".equals(ifid))
				retbl2 = "NO_RETURN";
			// pMap.put("I_IF_KEY", mDocNo); //2022.08.11 fqj 한진씨 요청
			pMap.put("I_IF_KEY", logseqno);
			sapConn.RfcCallTableSendAndReceiveList(rfcfn, rfctbl, retbl2, rfcp1, pMap, newList);
			pMap.put("I_IF_KEY", logseqno);
			DataMap retMsg = (DataMap) pMap.get("RET_MAP");
			List<DataMap> retList = new ArrayList<>();
			if ("S".equals(retMsg.get("TYPE"))) {
				Object etobj = pMap.get("ET_DATA");
				if (etobj == null || "".equals(etobj)) {
					retList = row.getList("P_RS_LIST");
				} else {
					retList = (List<DataMap>) etobj;
				}
				if ("MES".equals(sysFr) && "SAP".equals(sysTo)) {
					if (retList != null && retList.size() > 0) {
						for (DataMap insMap : retList) {
							row.put("P_TYPE", "SAVE");
							row.put("P_AUFNR", insMap.get("AUFNR"));
							row.put("P_MDOCNO", insMap.get("MDOCNO"));
							row.put("P_MDOCSEQ", CommonUtil.getBigDecimallToInt(insMap.getString("MDOCSEQ")));
							row.put("P_RUECK", insMap.get("RUECK"));
							row.put("P_RMZHL", insMap.get("RMZHL"));
							if (ifid.equals("MES_IF_123")) { // 합지
								row.put("P_RUECK", insMap.get("MBLNR"));
								row.put("P_RMZHL", insMap.get("MJAHR"));
							}
							if (ifid.equals("MES_IF_125")) { // 정보롤
								row.put("P_RUECK", insMap.get("MBLNR"));
								row.put("P_RMZHL", insMap.get("MJAHR"));
							}
							row.put("P_NAUFNR", insMap.get("NAUFNR"));
							row.put("P_IF_MES_KEY", logseqno);
							row.put("P_ZRESULT", insMap.get("TYPE"));
							row.put("P_ZMESSAGE", insMap.get("MESSAGE"));
							if (!"S".equals(insMap.getString("TYPE"))) {
								// 2023-02-02 안상현 실적 취소 테스트를 위한 주석
								// errMsg = errMsg + "\n" + insMap.getString("MDOCSEQ") + ":" + insMap.getString("MESSAGE");
								errMsg += insMap.getString("MDOCSEQ") + ":" + insMap.getString("MESSAGE");
							}
							row.put("P_MBLNR", insMap.get("MBLNR"));
							row.put("P_PAUFNR", insMap.get("PAUFNR"));
							row.put("P_MJAHR", insMap.get("MJAHR"));
							row.put("P_RSNCODE", insMap.get("RSNCODE")); // MES_IF_137
							row.put("P_STSCODE", insMap.get("STSCODE")); // MES_IF_137
							row.put("P_WERKS", insMap.get("WERKS")); // MES_IF_137
							if (ifid.equals("MES_IF_137") || ifid.equals("MES_IF_138")) {
								row.put("P_ZRESULT", "S");
								row.put("P_ZMESSAGE", retMsg.get("MESSAGE"));
								row.put("P_IF_IFR_NO", insMap.get("IF_IFR_NO"));
							}
							if (StringUtils.isNotBlank(insMap.getString("MDOCNO"))
									&& StringUtils.isNotBlank(insMap.getString("MDOCSEQ"))) {
								// map.put("RESULT_" + insMap.getString("MDOCNO")+
								// "_"+CommonUtil.getBigDecimallToInt(insMap.getString("MDOCSEQ")),
								// insMap.getString("TYPE"));
								map.put("RESULT_" + insMap.getString("MDOCNO") + "_" + CommonUtil.getBigDecimallToInt(insMap.getString("MDOCSEQ")) + "_MSG", insMap.getString("MESSAGE"));
							}
							commonDao.getMap(row);
						}
					}
				}
				mesService.addIfMasterCountLogIFNoError(logseqno, "", "RFC실적통신수신성공", retList.size() + "");
				retList.clear();
			} else {
				String messge = retMsg.getString("MESSAGE");
				ifServiceMapping.updateSapErrorCallBackMessage(ifTbl, mDocNo, messge, logseqno); // 콜백 메세지를 넣기
				rd.put("result", "ERROR");
				errMsg = "ERROR: " + messge;
				mesService.addIfMasterCountLogIFNoError(logseqno, errMsg, "RFC실적통신수신 에러메세지 반환", "");
				rd.put("result", "ERROR");
				log.debug("[수신테이터오류] " + ifid + " : ");
			}
		} catch (Exception e) {
			errMsg = "ERROR: " + e.getMessage();
			mesService.addIfMasterCountLogIFNoError(logseqno, errMsg, "실적통신실패", "");
			log.debug("[송신반환에러] " + ifid + " : " + e);
		}
		return errMsg;
	}
}