package project.mes.service;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import project.common.bean.CommonConfig;
import project.common.bean.DataMap;
import project.common.dao.CommonDAO;
import project.common.service.CommonService;

@Service
public class MesService {
	private static Logger log = Logger.getLogger(MesService.class);
	@Autowired public CommonDAO commonDao;

	@Autowired public IFServiceMapping ifServiceMapping;

	@Autowired private CommonService commonService;
    
    @Transactional
	public int saveLog(DataMap map)  throws SQLException {
		int count = 0;
		map.put("USERID", map.get(CommonConfig.SES_USER_ID_KEY));
		if(map.get("LGTYPE").equals("SEARCH")) {
			map.setModuleCommand("System", "PROGM_SEARCH_LOG");
		} else if(map.get("LGTYPE").equals("EXCEL")){
			map.setModuleCommand("System", "PROGM_EXCEL_DOWNLOAD_LOG");
		} else {
			throw new SQLException("Log type is not correct.");
		}
		commonDao.insert(map);
		count++;
		return count;
	}
	//로그
	public void insertIterfaceWmsLog(String JSONDATA, String IFID, String LOGONO)  throws SQLException {
		DataMap map = new DataMap();
		map.setModuleCommand("Erpif", "ITFRCVWMSLOG");
		map.put("JSONDATA",JSONDATA);
		map.put("IFID", IFID);
		map.put("LOGNO", LOGONO);
		commonDao.insert(map);
		map.clear();
	}

	// 로그이아디
	public void updateInterfaceWmsLog(String logseqno, String y) throws SQLException {
		DataMap map = new DataMap();
		map.setModuleCommand("Erpif", "ITFRCVWMSLOG");
		map.put("LOGNO", logseqno);
		map.put("SAVEYN", y);
		commonDao.update(map);
		map.clear();
	}
	public void updateInterfaceMasterTimeLog (String ifid, String type) throws SQLException {
		DataMap insFLG  = new DataMap();
		insFLG.setModuleCommand("Erpif", "IFMESTIME");
		insFLG.put("IFID", ifid);
		insFLG.put("TYPE", type);
		commonDao.update(insFLG);
		insFLG.clear();
	}

	public String insertInterfaceMesLog (String IFID,String COMSTAT) throws SQLException {
		return this.insertInterfaceMesLog(IFID, COMSTAT, "", "");
	}
	public String insertInterfaceMesLogRemark (String IFID,String COMSTAT,String remark) throws SQLException {
		return this.insertInterfaceMesLog(IFID, COMSTAT, "", remark);
	}
	public void updateInterfaceMasterLog (String ifid, String logseq) throws SQLException {
		DataMap insFLG  = new DataMap();
		insFLG.setModuleCommand("Erpif", "IFMESFLG");
		insFLG.put("IFID", ifid);
		insFLG.put("SEQNO", logseq);
		commonDao.update(insFLG);
		insFLG.clear();
	}

	public String insertInterfaceMesLog (String IFID,String COMSTAT, String ERRTXT) throws SQLException {
		return this.insertInterfaceMesLog(IFID, COMSTAT, ERRTXT, "");
	}

	public String insertInterfaceMesLog (String IFID,String COMSTAT, String ERRTXT,String REMARK) throws SQLException {
		DataMap insFLG  = new DataMap();
		insFLG.setModuleCommand("Erpif", "IFWMSLOG");
		setSeqGb(insFLG);
		insFLG.put("IFID", IFID);
		insFLG.put("COMSTAT", COMSTAT);
		insFLG.put("ERRTXT", ERRTXT);
		try {
			insFLG.put("REMARK", REMARK);
			// insFLG.put("REMARK", CommonUtil.getIp()+"-" + Thread.currentThread().getName()+"-"+Thread.currentThread().getId());
		}catch (Exception e) {
		}
		commonDao.insert(insFLG);
		String seqno = insFLG.getString("SEQNO");
		insFLG.clear();
		return seqno;
	}

	public int updateInterfaceMesLog (String logseq,String COMSTAT, String ERRTXT) throws SQLException {
		DataMap insFLG  = new DataMap();
		insFLG.setModuleCommand("Erpif", "IFWMSLOG");
		setSeqGb(insFLG);
		insFLG.put("COMSTAT", COMSTAT);
		insFLG.put("ERRTXT", ERRTXT);
		insFLG.put("SEQNO", logseq);
		int num = commonDao.update(insFLG);
		insFLG.clear();
		return num;
	}

	/*Sap 로그 이슈 추후 sap운영서버 있으면 그냥 리턴 */
	public String getLogno(String logno) {
		if (!CommonConfig.isRealServer()) {
			return "T"+logno.substring(1);
		}
		return logno;
	}
	/*Sap 로그 이슈 추후 sap운영서버 있으면 그냥 리턴 */
	private void setSeqGb(DataMap insFLG) {
		insFLG.put("SEQ_GB", "M");
		if (!CommonConfig.isRealServer()) {
			insFLG.put("SEQ_GB", "T");
		}
	}

	public void startIfMasterCountLog(String IFID,String logno) throws SQLException {
		DataMap insFLG  = new DataMap();
		insFLG.setModuleCommand("Erpif", "IFRUNLOG");
		insFLG.put("IFID", IFID);
		insFLG.put("LOGNO", logno);
		insFLG.put("STEP", "START");
		commonDao.insert(insFLG);
		insFLG.clear();
	}
	public void addIfMasterCountLogIFNoError(String logno,String error,String step,String pcnt) throws SQLException {
		DataMap insFLG  = new DataMap();
		insFLG.setModuleCommand("Erpif", "IFRUNLOG");
		insFLG.put("LOGNO", logno);
		insFLG.put("ERRTXT", error);
		insFLG.put("STEP", step);
		insFLG.put("PCNT", pcnt);
		commonDao.update(insFLG);
		insFLG.clear();
	}
	public void endIfMasterCountLogIFNoError(String logno) throws SQLException {
		DataMap insFLG  = new DataMap();
		insFLG.setModuleCommand("Erpif", "IFRUNLOG");
		insFLG.put("LOGNO", logno);
		insFLG.put("STEP", "END");
		commonDao.update(insFLG);
		insFLG.clear();
	}


	public void addIFMAlog(String ifid, String werks, String logseq) throws SQLException {
		DataMap pltMap = new DataMap();
		pltMap.put("IFID", ifid);
		pltMap.put("PLANT", werks);
		pltMap.put("LOGID", logseq);
		pltMap.setModuleCommand("Erpif", "IFMALOG");
		int upRs = commonDao.update(pltMap);
		if(upRs < 1) {
			commonDao.insert(pltMap);
		}
		pltMap.clear();
	}

	@Transactional
	public DataMap saveIF(DataMap map) throws SQLException{
		List<DataMap> list = map.getMapList("list");
		DataMap rsMap = new DataMap();
		rsMap.put("SUCCESS", "OK");
		DataMap row = new DataMap();
		for(int i = 0 ; i < list.size() ; i ++){
			row = list.get(i).getMap("map");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.setModuleCommand("Erpif", "IFSTAT");
			commonDao.update(row);
			row.clear();
		}
		list.clear();
		return rsMap;
	}

	@Transactional
	public void fieldSave(DataMap map) throws SQLException {
		String ifid = map.getString("ifid");
		List<DataMap> list = map.getList("list");
		for(DataMap info: list) {
			DataMap saveMap = info.getMap("map");
			saveMap.setModuleCommand("Erpif", "IFMAP");
			if(saveMap.get("SEQNO")!=null && !"".equals(saveMap.get("SEQNO"))){
				if(saveMap.getString("GRowState").equals("D")) {
					commonDao.delete(saveMap);
				}else {
					commonDao.update(saveMap);
				}
			}else {
				if(saveMap.getString("GRowState").equals("C")) {
					saveMap.put("IFID", ifid);
					commonDao.insert(saveMap);
				}
			}
			saveMap.clear();
		}
		list.clear();
	}

	public void updateInterfaceMesCount(String ifid, String logseqno, int size) throws SQLException {
		DataMap insFLG  = new DataMap();
		insFLG.setModuleCommand("Erpif", "IFMACOUNT");
		insFLG.put("IFID", ifid);
		insFLG.put("LOGNO", logseqno);
		insFLG.put("COUNT", size);
		commonDao.update(insFLG);

		if(ifServiceMapping.isPlantUseInParam(ifid)) {
			//  add
			insFLG.setModuleCommand("Erpif", "IFMACOUNTPLANT");
			commonDao.update(insFLG);
			//sum
			insFLG.setModuleCommand("Erpif", "IFMACOUNTPLANTSUM");
			int count = commonDao.getCount(insFLG);
			// sum update by ifid
			insFLG.setModuleCommand("Erpif", "IFMASUMCOUNT");
			insFLG.put("COUNT", count);
			commonDao.update(insFLG);
		}
		insFLG.clear();
	}

	public void log(String message) {
		if(!CommonConfig.isRealServer()) {
			log.error(message);
		}
	}

	public void updateMasterStatus(DataMap masterInfo, String status) throws SQLException {
		DataMap insFLG  = new DataMap();
		insFLG.setModuleCommand("Erpif", "IFMAS");
		insFLG.put("IFID", masterInfo.getString("IFID"));
		insFLG.put("FIN_CD", status);
		commonDao.update(insFLG);
		insFLG.clear();
	}

	public void initInterface() throws SQLException {
		try {
			if (!commonService.isAccessScheduleIp()) return;
			DataMap insFLG = new DataMap();
			insFLG.setModuleCommand("Erpif", "INITMES");
			commonDao.update(insFLG);
			insFLG.setModuleCommand("Erpif", "INITMESGRP");
			commonDao.update(insFLG);
			insFLG.clear();
		} catch (SQLException e) {
			log.error(e.getMessage());
		}
	}

	public String getPlantString(String werks) {
		String plant = (werks == null || "".equals(werks)) ? "":"플랜트:"+ werks +" ";
		return plant;
	}

	public void updateIFGroupRunEnd(DataMap map) throws SQLException {
		DataMap dataMap = new DataMap();
		dataMap.put("IF_GRP_CD", map.getString("GRP_CD"));
		dataMap.setModuleCommand("Erpif", "ITFMAENDGRP");
		dataMap.put("FIN_CD", "");
		DataMap all = commonDao.getMap(dataMap);
		dataMap.put("FIN_CD", "E");
		DataMap rtn = commonDao.getMap(dataMap);
		if(all.getInt("CNT") == rtn.getInt("CNT")) {
			dataMap.setModuleCommand("Erpif", "ITFMAGRP");
			dataMap.put("type", "E");
			commonDao.update(dataMap);
		}
		all.clear();
		rtn.clear();
		dataMap.clear();
	}

	public boolean notEmptyDocNo(String docNo) {
		return docNo!=null && !"".equals(docNo);
	}

	@Transactional
	public void saveIFTbl(DataMap map) throws SQLException {
		String ifid = map.getString("ifid");
		String logseqno= map.getString("logseqno");
		DataMap ifMap = ifServiceMapping.geIFMasterValue(ifid);
		String iftbl = ifMap.getString("IFTBL");
		
		ifMap.clear();
		map.put("IFTBL", iftbl);
		map.put("IF_MES_KEY", logseqno);
		map.setModuleCommand("Erpif", "LOGTBL");
		List<DataMap> list = map.getList("list");
		for(DataMap row: list) {
			DataMap keyMap =  row.getMap("map");
			keyMap.remove("GRowState");
			if(iftbl.startsWith("TB_IFS")){
				keyMap.remove("ZRESULT");
				keyMap.remove("ZRESULT_DATE");
				map.put("TYPE", "실적");
				map.put("MDOCNO", keyMap.getString("MDOCNO"));
				map.put("MDOCSEQ", keyMap.getString("MDOCSEQ"));
				map.put("AUFNR", keyMap.getString("AUFNR"));
			}
			if(iftbl.startsWith("TB_IFSWM")) {
				keyMap.remove("IF_STATUS");
				keyMap.remove("IF_GET_DATE");
				keyMap.remove("IF_SET_DATE");
				map.put("TYPE", "WMS");
				map.put("DOC_NO", keyMap.getString("DOC_NO"));
				map.put("DOC_SEQNO", keyMap.getString("DOC_SEQNO"));
			}
			for(Object key : keyMap.keySet()) {
				map.put("KEY", key);
				map.put("VAL", keyMap.getString(key).trim());
				commonDao.update(map);
			}
			keyMap.clear();
		}
		list.clear();
	}
	
	/** 재고실사지시 */
	@Transactional(rollbackFor = Exception.class)
	public String saveIP01(DataMap map) throws SQLException {
		DataMap head = map.getMap("head").getMap("map");
		List<DataMap> list = map.getList("list");
		
		String docuty = head.getString("DOCUTY");
		//String docnum = wmsService.getDocSeq(docuty);
		String docnum = head.getString("PHYIKY");
		
		// insert head
		map.clonSessionData(head);
		head.put("PHYIKY", docnum);
		head.setModuleCommand("Inv", "PHYDH");
		commonDao.insert(head);
		
		// insert item
		List<HashMap> mList = new ArrayList<>();
		int subSize = 100;
		for (int i = 0; i < list.size(); i++) {
			DataMap row = list.get(i).getMap("map");
			map.clonSessionData(row);
			
			row.put("PHYIKY", docnum);
			row.put("PHYIIT", String.format("%06d", (i + 1) * 10));
			
			
			mList.add(row);
			if (mList.size() == subSize || i == list.size() - 1) {
				commonDao.insert("PHYDI_MULTI", mList);
				mList.clear();
			}
		}
		return docnum;
	}
}