package project.mes.service;

import java.util.List;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import project.common.bean.DataMap;
import project.common.dao.CommonDAO;
import project.common.service.CommonService;

@Service
public class ReportService {

	private static Logger log = Logger.getLogger(ReportService.class);
	
	@Autowired
	public CommonDAO commonDao;
	
	@Autowired
	public CommonService commonService;
	
	@Transactional
	// 로그 저장
	public String savePrtseq_LocBcd(DataMap map) throws Exception {
		List<DataMap> list = map.getList("list");
		String prtSeq = null;
		DataMap data = map;
		
		try{
			prtSeq =  commonService.getPrtSeq();
			
			for(int i = 0; i < list.size(); i++){
				data.setModuleCommand("Report", "PRTLOG");
				data.put("PRTSEQ", prtSeq);
				data.put("VALUE01", list.get(i).getMap("map").getString("IND_BCD")); // 개별바코드
				
				commonDao.insert(data);
			}
		} catch(Exception e){
			/*
			String language = map.getString("SES_LANGUAGE");
			String messageCode = "IN_M9036";
			String logMsg =  ComU.getLastMsg(e.getMessage());
			String[] errorMsg =  new String[]{"[" + logMsg + "]"};
			
			log.error(logMsg);
			throw new Exception(wmsService.getMessageParam(language, messageCode, errorMsg));
			*/
		}
		data.clear();
		list.clear();
		return prtSeq;
	}
	/*
	@Transactional
	public DataMap WSP02PopAsnList(DataMap map) throws Exception {
		List<DataMap> head = map.getList("head");
		String prtSeq = "";
		DataMap row;
		int count = 0;
		DataMap rsMap = new DataMap();
		
		//print report 시퀀스 채번
		try{
			prtSeq = wmsService.getDocSeq("NR_PRTSEQ");
			
			for(int i=0;i<head.size();i++){
				row = head.get(i).getMap("map");
				map.clonSessionData(row);
				row.setModuleCommand("WmsReport", "PRTLG");
				
				row.put("PRTSEQ", prtSeq);
				row.put("PRTNUM", i+1);
				row.put("PRTTYP", map.getString("PRTTYP"));
				row.put("FLPATH", map.getString("FLPATH"));
				row.put("EZFILE", map.getString("EZFILE"));
				row.put("PROGID", map.getString("PROGID"));
				row.put("WAREKY", map.getString("WAREKY"));
				row.put("OWNRKY", map.getString("OWNRKY"));
				row.put("LANGKY", map.getString("LANGKY"));
				row.put("PRTL01", row.getString("ASNDKY"));
				row.put("PRTL02", row.getString("ASNDIT"));
				commonDao.insert(row);
				count++;
			}
			
			rsMap.put("PRTSEQ", prtSeq);
			
		} catch(Exception e) {
			String language = map.getString("SES_LANGUAGE");
			String messageCode = "IN_M9036";
			String logMsg =  ComU.getLastMsg(e.getMessage());
			String[] errorMsg =  new String[]{"[" + logMsg + "]"};
			
			log.error(logMsg);
			throw new Exception(wmsService.getMessageParam(language, messageCode, errorMsg));
		}
		rsMap.put("FLPATH", map.getString("FLPATH"));
		rsMap.put("EZFILE", map.getString("EZFILE"));
		rsMap.put("CNT", count);
		
		return rsMap;
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = Exception.class)
	public DataMap savePrtseq_ALL(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		String prtSeq = "";
		DataMap row;
		DataMap result = new DataMap();
		int count = 0;
		//print report 시퀀스 채번
		prtSeq = wmsService.getDocSeq("NR_PRTSEQ");
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.clonSessionData(row);
			row.setModuleCommand("WmsReport", "PRTLG");
			row.put("PRTSEQ", prtSeq);
			row.put("PRTNUM", i+1);
			row.put("PRTTYP", map.get("PRTTYP"));
			row.put("FLPATH", map.get("FLPATH"));
			row.put("EZFILE", map.get("EZFILE"));
			row.put("PROGID", map.get("PROGID"));
			row.put("WAREKY", map.get("WAREKY"));
			row.put("OWNRKY", map.get("OWNRKY"));
			row.put("LANGKY", map.get("LANGKY"));
			row.put("PRTL01", row.getString("PHYIKY"));
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			commonDao.insert(row);
			count++;
		}
		result.put("PRTSEQ",prtSeq);
		result.put("CNT", count);
		
		return result;
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = Exception.class)
	public DataMap WIR21_Print(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		String prtSeq = "";
		DataMap row;
		DataMap result = new DataMap();
		int count = 0;
		
		//print report 시퀀스 채번
		prtSeq = wmsService.getDocSeq("NR_PRTSEQ");
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.clonSessionData(row);
			
			if(!row.getString("PGRC01").equals("Y") && !row.getString("PURCTY").equals("132")) {
				row.setModuleCommand("WmsReport", "PRTLG");
				row.put("PRTSEQ", prtSeq);
				row.put("PRTNUM", i+1);
				row.put("PRTTYP", map.get("PRTTYP"));
				row.put("FLPATH", map.get("FLPATH"));
				row.put("EZFILE", map.get("EZFILE"));
				row.put("PROGID", map.get("PROGID"));
				row.put("WAREKY", map.get("WAREKY"));
				row.put("OWNRKY", map.get("OWNRKY"));
				row.put("LANGKY", map.get("LANGKY"));
				row.put("PRTL01", row.getString("PURCKY"));
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
				commonDao.insert(row);
			}
			count++;
		}
		result.put("PRTSEQ",prtSeq);
		result.put("CNT", count);
		
		return result;
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = Exception.class)
	public DataMap WIR21_HappyCall(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		String prtSeq = "";
		DataMap row;
		DataMap result = new DataMap();
		int count = 0;
		
		//print report 시퀀스 채번
		prtSeq = wmsService.getDocSeq("NR_PRTSEQ");
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.clonSessionData(row);
			
			if(row.getString("PGRC01").equals("Y") && !row.getString("PURCTY").equals("132")) {
				row.setModuleCommand("WmsReport", "PRTLG");
				row.put("PRTSEQ", prtSeq);
				row.put("PRTNUM", i+1);
				row.put("PRTTYP", map.get("PRTTYP"));
				row.put("FLPATH", map.get("FLPATH"));
				row.put("EZFILE", map.get("EZFILE"));
				row.put("PROGID", map.get("PROGID"));
				row.put("WAREKY", map.get("WAREKY"));
				row.put("OWNRKY", map.get("OWNRKY"));
				row.put("LANGKY", map.get("LANGKY"));
				row.put("PRTL01", row.getString("PURCKY"));
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
				commonDao.insert(row);
			}
			count++;
		}
		result.put("PRTSEQ",prtSeq);
		result.put("CNT", count);
		
		return result;
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = Exception.class)
	public DataMap WIR21rtn_Print(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		String prtSeq = "";
		DataMap row;
		DataMap result = new DataMap();
		int count = 0;
		//print report 시퀀스 채번
		prtSeq = wmsService.getDocSeq("NR_PRTSEQ");
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.clonSessionData(row);
			
			if(row.getString("INDNRC").equals("V")) {
				row.setModuleCommand("WmsReport", "PRTLG");
				row.put("PRTSEQ", prtSeq);
				row.put("PRTNUM", i+1);
				row.put("PRTTYP", map.get("PRTTYP"));
				row.put("FLPATH", map.get("FLPATH"));
				row.put("EZFILE", map.get("EZFILE"));
				row.put("PROGID", map.get("PROGID"));
				row.put("WAREKY", map.get("WAREKY"));
				row.put("OWNRKY", map.get("OWNRKY"));
				row.put("LANGKY", map.get("LANGKY"));
				row.put("PRTL01", row.getString("PURCKY"));
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
				commonDao.insert(row);
			}
			count++;
		}
		result.put("PRTSEQ",prtSeq);
		result.put("CNT", count);
		
		return result;
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = Exception.class)
	public DataMap WOS13_Print(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		String prtSeq = "";
		DataMap row;
		DataMap result = new DataMap();
		int count = 0;
		//print report 시퀀스 채번
		prtSeq = wmsService.getDocSeq("NR_PRTSEQ");
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.clonSessionData(row);
			row.setModuleCommand("WmsReport", "PRTLG");
			row.put("PRTSEQ", prtSeq);
			row.put("PRTNUM", i+1);
			row.put("PRTTYP", map.get("PRTTYP"));
			row.put("FLPATH", map.get("FLPATH"));
			row.put("EZFILE", map.get("EZFILE"));
			row.put("PROGID", map.get("PROGID"));
			row.put("WAREKY", map.get("WAREKY"));
			row.put("OWNRKY", map.get("OWNRKY"));
			row.put("LANGKY", map.get("LANGKY"));
			row.put("PRTL01", row.getString("WAREKY"));
			row.put("PRTL02", row.getString("RQSHPD"));
			row.put("PRTL03", row.getString("BTMP01"));
			row.put("PRTL04", row.getString("STKNUM"));
			row.put("PRTL05", row.getString("ASKU01"));
			row.put("QTYP01", map.get("BTMP07"));
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			commonDao.insert(row);
			count++;
		}
		result.put("PRTSEQ",prtSeq);
		result.put("CNT", count);
		
		return result;
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = Exception.class)
	public DataMap WDP01_Print(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		String prtSeq = "";
		DataMap row;
		DataMap result = new DataMap();
		DataMap itemRow = new DataMap();
		List<DataMap> dataList = null;
		int count = 0;
		//print report 시퀀스 채번
		int printCnt = 0;
		prtSeq = wmsService.getDocSeq("NR_PRTSEQ");
		Set<String> dataSet = new HashSet<String>();
		
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.clonSessionData(row);
			row.setModuleCommand("WmsOutbound", "WDP01SHPOKY");
			row.put("OWNRKY", map.get("OWNRKY"));
			dataList = commonDao.getList(row);
			for(int k = 0; k < dataList.size(); k++){
				itemRow = dataList.get(k).getMap("map");
				dataSet.add(itemRow.getString("SHPOKY"));
			}
		}
		
		Iterator<String> itr = dataSet.iterator();
		while(itr.hasNext()){
			itemRow = new DataMap();
			itemRow.put("PRTL01", itr.next());
			printCnt++;
			itemRow.setModuleCommand("WmsReport", "PRTLG");
			itemRow.put("PRTSEQ", prtSeq);
			itemRow.put("PRTNUM", printCnt);
			itemRow.put("PRTTYP", map.get("PRTTYP"));
			itemRow.put("FLPATH", map.get("FLPATH"));
			itemRow.put("EZFILE", map.get("EZFILE"));
			itemRow.put("PROGID", map.get("PROGID"));
			itemRow.put("WAREKY", map.get("WAREKY"));
			itemRow.put("LANGKY", map.get("LANGKY"));
			itemRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			itemRow.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			commonDao.insert(itemRow);
			count++;
		}
		
		result.put("PRTSEQ",prtSeq);
		result.put("CNT", count);
		
		return result;
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = Exception.class)
	public DataMap WDP02_Print(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		String prtSeq = "";
		DataMap row;
		DataMap result = new DataMap();
		DataMap itemRow = new DataMap();
		List<DataMap> dataList = null;
		int count = 0;
		//print report 시퀀스 채번
		int printCnt = 0;
		prtSeq = wmsService.getDocSeq("NR_PRTSEQ");
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.clonSessionData(row);
			row.setModuleCommand("WmsOutbound", "WDP02SHPOKY");
			row.put("OWNRKY", map.get("OWNRKY"));
			dataList = commonDao.getList(row);
			for(int k = 0; k < dataList.size(); k++){
				itemRow = dataList.get(k).getMap("map");

				itemRow.put("PRTL01", itemRow.get("SHPOKY"));
				printCnt++;
				itemRow.setModuleCommand("WmsReport", "PRTLG");
				itemRow.put("PRTSEQ", prtSeq);
				itemRow.put("PRTNUM", printCnt);
				itemRow.put("PRTTYP", map.get("PRTTYP"));
				itemRow.put("FLPATH", map.get("FLPATH"));
				itemRow.put("EZFILE", map.get("EZFILE"));
				itemRow.put("PROGID", map.get("PROGID"));
				itemRow.put("WAREKY", map.get("WAREKY"));
				itemRow.put("LANGKY", map.get("LANGKY"));
				itemRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				itemRow.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
				commonDao.insert(itemRow);
				count++;
			}
		}
		result.put("PRTSEQ",prtSeq);
		result.put("CNT", count);
		
		return result;
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = Exception.class)
	public DataMap WIP01_Print(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		String prtSeq = "";
		DataMap row  = new DataMap();
		DataMap result = new DataMap();
		int count = 0;
		prtSeq = wmsService.getDocSeq("NR_PRTSEQ");
		row.setModuleCommand("WmsReport", "PRTLG");
		row.put("PRTSEQ", prtSeq);
		row.put("PRTNUM", 1);
		row.put("PHYIKY", map.get("PHYIKY"));
		row.put("PRTTYP", map.get("PRTTYP"));
		row.put("FLPATH", map.get("FLPATH"));
		row.put("EZFILE", map.get("EZFILE"));
		row.put("PROGID", map.get("PROGID"));
		row.put("WAREKY", map.get("WAREKY"));
		row.put("OWNRKY", map.get("OWNRKY"));
		row.put("LANGKY", map.get("LANGKY"));
		row.put("PRTL01", map.get("PHYIKY"));
		row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
		commonDao.insert(row);
		count++;
		result.put("PRTSEQ",prtSeq);
		result.put("CNT", count);
		
		return result;
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = Exception.class)
	public DataMap WTK03_Print(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		String prtSeq = "";
		DataMap row;
		DataMap result = new DataMap();
		int count = 0;
		//print report 시퀀스 채번
		prtSeq = wmsService.getDocSeq("NR_PRTSEQ");
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.clonSessionData(row);
			row.setModuleCommand("WmsReport", "PRTLG");
			row.put("PRTSEQ", prtSeq);
			row.put("PRTNUM", i+1);
			row.put("PRTTYP", map.get("PRTTYP"));
			row.put("FLPATH", map.get("FLPATH"));
			row.put("EZFILE", map.get("EZFILE"));
			row.put("PROGID", map.get("PROGID"));
			row.put("WAREKY", map.get("WAREKY"));
			row.put("OWNRKY", map.get("OWNRKY"));
			row.put("LANGKY", map.get("LANGKY"));
			row.put("PRTL01", row.getString("SHPOKY"));
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			commonDao.insert(row);
			count++;
		}
		result.put("PRTSEQ",prtSeq);
		result.put("CNT", count);
		
		return result;
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = Exception.class)
	public DataMap WOS11BarPrint(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		String prtSeq = "";
		DataMap row;
		DataMap result = new DataMap();
		int count = 0;
		//print report 시퀀스 채번
		prtSeq = wmsService.getDocSeq("NR_PRTSEQ");
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.clonSessionData(row);
			row.setModuleCommand("WmsReport", "PRTLG");
			row.put("PRTSEQ", prtSeq);
			row.put("PRTNUM", i+1);
			row.put("PRTTYP", map.get("PRTTYP"));
			row.put("FLPATH", map.get("FLPATH"));
			row.put("EZFILE", map.get("EZFILE"));
			row.put("PROGID", map.get("PROGID"));
			row.put("WAREKY", map.get("WAREKY"));
			row.put("OWNRKY", map.get("OWNRKY"));
			row.put("LANGKY", map.get("LANGKY"));
			row.put("PRTL01", row.getString("WAREKY"));
			row.put("PRTL02", row.getString("RQSHPD"));
			row.put("PRTL03", row.getString("BTMP01"));
			row.put("PRTL04", row.getString("STKNUM"));
			row.put("QTYP01", map.get("BTMP07"));
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			commonDao.insert(row);
			count++;
		}
		result.put("PRTSEQ",prtSeq);
		result.put("CNT", count);
		
		return result;
	}
	
	@Transactional
	public DataMap asnListPrint(HttpSession session, DataMap map) throws Exception {
		DataMap rsMap = new DataMap();
		
		List<DataMap> dataList = new ArrayList<DataMap>();
		List<DataMap> list = map.getList("list");
		int len = list.size();
		DataMap row;
		int count = 0;
		
		if(len > 0){
			String prtseq = map.getString("PRTSEQ");
			//String prtseq = wmsService.getDocSeq("NR_PRTSEQ");
			for(int i = 0; i < len; i++){
				row = list.get(i).getMap("map");
				DataMap dataMap = new DataMap();
				map.clonSessionData(dataMap);
				
				dataMap.put("PRTSEQ", prtseq);
				dataMap.put("PRTNUM", i+1);
				dataMap.put("QTYPRT", 1);
				dataMap.put("PRTTYP", map.getString("PRTTYP"));
				dataMap.put("EZFILE", map.getString("EZFILE"));
				dataMap.put("FLPATH", map.getString("FLPATH"));
				dataMap.put("PROGID", map.getString("PROGID"));
				dataMap.put("PRTL01", row.getString("PURCKY"));
				
				dataList.add(dataMap);
			}
			map.setModuleCommand("WmsReport", "PRTLG");
			
			try {
//				count = (int) commonDao.batchInsert(session, map, dataList);
			}catch(Exception e ) {
				String errMsg = ComU.getLastMsg(e.getMessage());
				log.error(errMsg);
				throw new SQLException(wmsService.getMessageParam(map.getString("SES_LANGUAGE"), "IN_M9036", new String[]{"[" + errMsg + "]"}));
			}
			
			rsMap.put("PRTSEQ", prtseq);
		}
		
		rsMap.put("FLPATH", map.getString("FLPATH"));
		rsMap.put("EZFILE", map.getString("EZFILE"));
		rsMap.put("CNT", count);
		
		return rsMap;
	}
	
	@Transactional
	public DataMap taskListWPT02(HttpSession session, DataMap map) throws Exception {
	    DataMap rsMap = new DataMap();
	    
	    List<DataMap> dataList = new ArrayList<DataMap>();
	    List<DataMap> list = map.getList("list");
	    int len = list.size();
	    DataMap row;
	    int count = 0;
	    
	    if(len > 0){
	    	String prtseq = map.getString("PRTSEQ");
	    	//String prtseq = wmsService.getDocSeq("NR_PRTSEQ");
	        for(int i = 0; i < len; i++){
	            row = list.get(i).getMap("map");
	            DataMap dataMap = new DataMap();
	            map.clonSessionData(dataMap);
	            
	            dataMap.put("PRTSEQ", prtseq);
	            dataMap.put("PRTNUM", i+1);
	            dataMap.put("QTYPRT", 1);
	            dataMap.put("PRTTYP", map.getString("PRTTYP"));
	            dataMap.put("EZFILE", map.getString("EZFILE"));
	            dataMap.put("FLPATH", map.getString("FLPATH"));
	            dataMap.put("PROGID", map.getString("PROGID"));
	            dataMap.put("PRTL01", row.getString("TASKKY"));
	            
	            dataList.add(dataMap);
	        }
	        map.setModuleCommand("WmsReport", "PRTLG");
	        try {
//	            count = (int) commonDao.batchInsert(session, map, dataList);
	        }catch(Exception e ) {
				String errMsg = ComU.getLastMsg(e.getMessage());
				log.error(errMsg);
				throw new SQLException(wmsService.getMessageParam(map.getString("SES_LANGUAGE"), "IN_M9036", new String[]{"[" + errMsg + "]"}));
	        }
	        
	        rsMap.put("PRTSEQ", prtseq);
	    }
	
	    rsMap.put("FLPATH", map.getString("FLPATH"));
	    rsMap.put("EZFILE", map.getString("EZFILE"));
	    rsMap.put("CNT", count);
	    
	    return rsMap;
	}
	
	@Transactional
	public DataMap taskListWPT03(HttpSession session, DataMap map) throws Exception {
		List<DataMap> list = map.getList("list");
		String prtSeq = "";
		DataMap row;
		DataMap result = new DataMap();
		int count = 0;
		//print report 시퀀스 채번
		prtSeq = wmsService.getDocSeq("NR_PRTSEQ");
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.clonSessionData(row);
			row.setModuleCommand("WmsReport", "PRTLG");
			row.put("PRTSEQ", prtSeq);
			row.put("PRTNUM", i+1);
			row.put("PRTTYP", map.get("PRTTYP"));
			row.put("FLPATH", map.get("FLPATH"));
			row.put("EZFILE", map.get("EZFILE"));
			row.put("PROGID", map.get("PROGID"));
			row.put("WAREKY", map.get("WAREKY"));
			row.put("OWNRKY", map.get("OWNRKY"));
			row.put("LANGKY", map.get("LANGKY"));
			row.put("PRTL01", row.getString("TASKKY"));
			row.put("PRTL02", row.getString("TASKIT"));
			row.put("PRTL03", row.getString("TRNUAC"));
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			commonDao.insert(row);
			count++;
		}
		result.put("PRTSEQ",prtSeq);
		result.put("CNT", count);
		
		return result;
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = Exception.class)
	public DataMap WMV11_Print(DataMap map) throws SQLException {
		String prtSeq = "";
		DataMap row = new DataMap();
		DataMap result = new DataMap();
		int count = 0;
		//print report 시퀀스 채번
		prtSeq = wmsService.getDocSeq("NR_PRTSEQ");
		row.setModuleCommand("WmsReport", "PRTLG");
		row.put("PRTSEQ", prtSeq);
		row.put("PRTNUM", 1);
		row.put("PRTTYP", map.get("PRTTYP"));
		row.put("FLPATH", map.get("FLPATH"));
		row.put("EZFILE", map.get("EZFILE"));
		row.put("PROGID", map.get("PROGID"));
		row.put("WAREKY", map.get("WAREKY"));
		row.put("OWNRKY", map.get("OWNRKY"));
		row.put("LANGKY", map.get("LANGKY"));
		row.put("PRTL01", map.get("TASKKY"));
		row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
		commonDao.insert(row);
		count++;
		result.put("PRTSEQ",prtSeq);
		result.put("CNT", count);
		
		return result;
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = Exception.class)
	public DataMap WMV12_Print(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		String prtSeq = "";
		DataMap row;
		DataMap result = new DataMap();
		int count = 0;
		//print report 시퀀스 채번
		prtSeq = wmsService.getDocSeq("NR_PRTSEQ");
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.clonSessionData(row);
			row.setModuleCommand("WmsReport", "PRTLG");
			row.put("PRTSEQ", prtSeq);
			row.put("PRTNUM", i+1);
			row.put("PRTTYP", map.get("PRTTYP"));
			row.put("FLPATH", map.get("FLPATH"));
			row.put("EZFILE", map.get("EZFILE"));
			row.put("PROGID", map.get("PROGID"));
			row.put("WAREKY", map.get("WAREKY"));
			row.put("OWNRKY", map.get("OWNRKY"));
			row.put("LANGKY", map.get("LANGKY"));
			row.put("PRTL01", row.getString("TASKKY"));
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			commonDao.insert(row);
			count++;
		}
		result.put("PRTSEQ",prtSeq);
		result.put("CNT", count);
		
		return result;
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = Exception.class)
	public DataMap WSJ04_Print(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		String prtSeq = "";
		DataMap row;
		DataMap result = new DataMap();
		int count = 0;
		
		//print report 시퀀스 채번
		prtSeq = wmsService.getDocSeq("NR_PRTSEQ");
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.clonSessionData(row);
			
			if(row.getString("ADJUTY").equals("413")) {
				row.setModuleCommand("WmsReport", "PRTLG");
				row.put("PRTSEQ", prtSeq);
				row.put("PRTNUM", i+1);
				row.put("PRTTYP", map.get("PRTTYP"));
				row.put("FLPATH", map.get("FLPATH"));
				row.put("EZFILE", map.get("EZFILE"));
				row.put("PROGID", map.get("PROGID"));
				row.put("WAREKY", map.get("WAREKY"));
				row.put("OWNRKY", map.get("OWNRKY"));
				row.put("LANGKY", map.get("LANGKY"));
				row.put("PRTL01", row.getString("SADJKY"));
				row.put("PRTL02", row.getString("SADJIT"));
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
				commonDao.insert(row);
			}
			count++;
		}
		result.put("PRTSEQ",prtSeq);
		result.put("CNT", count);
		
		return result;
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = Exception.class)
	public DataMap WPB32_Print(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		String prtSeq = "";
		DataMap row;
		DataMap result = new DataMap();
		int count = 0;
		//print report 시퀀스 채번
		prtSeq = wmsService.getDocSeq("NR_PRTSEQ");
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.clonSessionData(row);
			row.setModuleCommand("WmsReport", "PRTLG");
			row.put("PRTSEQ", prtSeq);
			row.put("PRTNUM", i+1);
			row.put("PRTTYP", map.get("PRTTYP"));
			row.put("FLPATH", map.get("FLPATH"));
			row.put("EZFILE", map.get("EZFILE"));
			row.put("PROGID", map.get("PROGID"));
			row.put("WAREKY", map.get("WAREKY"));
			row.put("OWNRKY", map.get("OWNRKY"));
			row.put("LANGKY", map.get("LANGKY"));
			row.put("PRTL01", row.getString("WAREKY"));
			row.put("PRTL02", row.getString("GRPSEQ"));
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			commonDao.insert(row);
			count++;
		}
		result.put("PRTSEQ",prtSeq);
		result.put("CNT", count);
		
		return result;
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = Exception.class)
	public DataMap WPB31_Print(DataMap map) throws SQLException {
		String prtSeq = "";
		DataMap row = new DataMap();
		DataMap result = new DataMap();
		int count = 0;
		//print report 시퀀스 채번
		prtSeq = wmsService.getDocSeq("NR_PRTSEQ");
		map.clonSessionData(row);
		row.setModuleCommand("WmsReport", "PRTLG");
		row.put("PRTSEQ", prtSeq);
		row.put("PRTNUM", 1);
		row.put("PRTTYP", map.get("PRTTYP"));
		row.put("FLPATH", map.get("FLPATH"));
		row.put("EZFILE", map.get("EZFILE"));
		row.put("PROGID", map.get("PROGID"));
		row.put("WAREKY", map.get("WAREKY"));
		row.put("OWNRKY", map.get("OWNRKY"));
		row.put("LANGKY", map.get("LANGKY"));
		row.put("PRTL01", map.get("WAREKY"));
		row.put("PRTL02", map.get("GRPSEQ"));
		row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
		commonDao.insert(row);
		count++;
		result.put("PRTSEQ",prtSeq);
		result.put("CNT", count);
		
		return result;
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = Exception.class)
	public DataMap WIR21_RtnAsn(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		String prtSeq = "";
		DataMap row;
		DataMap result = new DataMap();
		int count = 0;
		//print report 시퀀스 채번
		prtSeq = wmsService.getDocSeq("NR_PRTSEQ");
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.clonSessionData(row);
			row.setModuleCommand("WmsReport", "PRTLG");
			row.put("PRTSEQ", prtSeq);
			row.put("PRTNUM", i+1);
			row.put("PRTTYP", map.get("PRTTYP"));
			row.put("FLPATH", map.get("FLPATH"));
			row.put("EZFILE", map.get("EZFILE"));
			row.put("PROGID", map.get("PROGID"));
			row.put("WAREKY", map.get("WAREKY"));
			row.put("OWNRKY", map.get("OWNRKY"));
			row.put("LANGKY", map.get("LANGKY"));
			row.put("PRTL01", row.getString("PURCKY"));
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			commonDao.insert(row);
			count++;
		}
		result.put("PRTSEQ",prtSeq);
		result.put("CNT", count);
		
		return result;
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = Exception.class)
	public DataMap WPB01_Print(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		String prtSeq = "";
		DataMap row;
		DataMap result = new DataMap();
		DataMap itemRow = new DataMap();
		List<DataMap> dataList = null;
		int count = 0;
		//print report 시퀀스 채번
		int printCnt = 0;
		prtSeq = wmsService.getDocSeq("NR_PRTSEQ");
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.clonSessionData(row);
			row.setModuleCommand("WmsLogisticsTool", "WPB01LTLSEQ");
			row.put("OWNRKY", map.get("OWNRKY"));
			if(row.getString("DOCUTY").equals("611")) {
				dataList = commonDao.getList(row);
				for(int k = 0; k < dataList.size(); k++){
					itemRow = dataList.get(k).getMap("map");
					
					itemRow.put("PRTL01", itemRow.get("LTLSEQ"));
					printCnt++;
					itemRow.setModuleCommand("WmsReport", "PRTLG");
					itemRow.put("PRTSEQ", prtSeq);
					itemRow.put("PRTNUM", printCnt);
					itemRow.put("PRTTYP", map.get("PRTTYP"));
					itemRow.put("FLPATH", map.get("FLPATH"));
					itemRow.put("EZFILE", map.get("EZFILE"));
					itemRow.put("PROGID", map.get("PROGID"));
					itemRow.put("WAREKY", map.get("WAREKY"));
					itemRow.put("LANGKY", map.get("LANGKY"));
					itemRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
					itemRow.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
					commonDao.insert(itemRow);
					count++;
				}
			}
		}
		result.put("PRTSEQ",prtSeq);
		result.put("CNT", count);
		
		return result;
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = Exception.class)
	public DataMap WOS12_Print(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		String prtSeq = "";
		DataMap row;
		DataMap result = new DataMap();
		int count = 0;
		int i = 0;
		//print report 시퀀스 채번
		prtSeq = wmsService.getDocSeq("NR_PRTSEQ");
		list = map.getList("list");
		for(DataMap data : list) {
			row = data.getMap("map");
			map.clonSessionData(row);
			row.setModuleCommand("WmsReport", "PRTLG");
			row.put("PRTSEQ", prtSeq);
			row.put("PRTNUM", i+1);
			row.put("PRTTYP", map.get("PRTTYP"));
			row.put("FLPATH", map.get("FLPATH"));
			row.put("EZFILE", map.get("EZFILE"));
			row.put("PROGID", map.get("PROGID"));
			row.put("WAREKY", map.get("WAREKY"));
			row.put("OWNRKY", map.get("OWNRKY"));
			row.put("LANGKY", map.get("LANGKY"));
			row.put("PRTL01", row.getString("SHPOKY"));
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			if(map.get("PCKTYP").equals("TPK")) {
				commonDao.insert(row);
			}
			count++;
		}
		result.put("PRTSEQ",prtSeq);
		result.put("CNT", count);
		
		return result;
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = Exception.class)
	public DataMap WOS14_Print(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		String prtSeq = "";
		DataMap row;
		DataMap result = new DataMap();
		DataMap itemRow = new DataMap();
		List<DataMap> dataList = null;
		int count = 0;
		//print report 시퀀스 채번
		int printCnt = 0;
		prtSeq = wmsService.getDocSeq("NR_PRTSEQ");
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.clonSessionData(row);
			row.setModuleCommand("WmsOutbound", "WOS14SHPOKY");
			row.put("OWNRKY", map.get("OWNRKY"));
			dataList = commonDao.getList(row);
			for(int k = 0; k < dataList.size(); k++){
				itemRow = dataList.get(k).getMap("map");

				itemRow.put("PRTL01", itemRow.get("SHPOKY"));
				printCnt++;
				itemRow.setModuleCommand("WmsReport", "PRTLG");
				itemRow.put("PRTSEQ", prtSeq);
				itemRow.put("PRTNUM", printCnt);
				itemRow.put("PRTTYP", map.get("PRTTYP"));
				itemRow.put("FLPATH", map.get("FLPATH"));
				itemRow.put("EZFILE", map.get("EZFILE"));
				itemRow.put("PROGID", map.get("PROGID"));
				itemRow.put("WAREKY", map.get("WAREKY"));
				itemRow.put("LANGKY", map.get("LANGKY"));
				itemRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				itemRow.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
				commonDao.insert(itemRow);
				count++;
			}
		}
		result.put("PRTSEQ",prtSeq);
		result.put("CNT", count);
		
		return result;
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = Exception.class)
	public DataMap WOS14_IndivPrint(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		String prtSeq = "";
		DataMap row;
		DataMap result = new DataMap();
		int count = 0;
		int i = 0;
		//print report 시퀀스 채번
		prtSeq = wmsService.getDocSeq("NR_PRTSEQ");
		for(DataMap data : list) {
			row = data.getMap("map");
			map.clonSessionData(row);
			row.setModuleCommand("WmsReport", "PRTLG");
			row.put("PRTSEQ", prtSeq);
			row.put("PRTNUM", i+1);
			row.put("PRTTYP", map.get("PRTTYP"));
			row.put("FLPATH", map.get("FLPATH"));
			row.put("EZFILE", map.get("EZFILE"));
			row.put("PROGID", map.get("PROGID"));
			row.put("WAREKY", map.get("WAREKY"));
			row.put("OWNRKY", map.get("OWNRKY"));
			row.put("LANGKY", map.get("LANGKY"));
			row.put("PRTL01", row.getString("SHPOKY"));
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			if(row.getString("PCKTYP").equals("CPK")) {
				commonDao.insert(row);
			}
			count++;
		}
		result.put("PRTSEQ",prtSeq);
		result.put("CNT", count);
		
		return result;
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = Exception.class)
	public DataMap WSD31_Print(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		String prtSeq = "";
		DataMap row;
		DataMap result = new DataMap();
		int count = 0;
		//print report 시퀀스 채번
		prtSeq = wmsService.getDocSeq("NR_PRTSEQ");
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.clonSessionData(row);
			row.setModuleCommand("WmsReport", "PRTLG");
			row.put("PRTSEQ", prtSeq);
			row.put("PRTNUM", i+1);
			row.put("PRTTYP", map.get("PRTTYP"));
			row.put("FLPATH", map.get("FLPATH"));
			row.put("EZFILE", map.get("EZFILE"));
			row.put("PROGID", map.get("PROGID"));
			row.put("WAREKY", map.get("WAREKY"));
			row.put("OWNRKY", map.get("OWNRKY"));
			row.put("LANGKY", map.get("LANGKY"));
			row.put("PRTL01", row.getString("TRNUID"));
			row.put("PRTL02", row.getString("WAREKY"));
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			commonDao.insert(row);
			count++;
		}
		result.put("PRTSEQ",prtSeq);
		result.put("CNT", count);
		
		return result;
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = Exception.class)
	public DataMap WOS21_PLTPrint(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		String prtSeq = "";
		DataMap row;
		DataMap result = new DataMap();
		int count = 0;
		//print report 시퀀스 채번
		prtSeq = wmsService.getDocSeq("NR_PRTSEQ");
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.clonSessionData(row);
			row.setModuleCommand("WmsReport", "PRTLG");
			row.put("PRTSEQ", prtSeq);
			row.put("PRTNUM", i+1);
			row.put("PRTTYP", map.get("PRTTYP"));
			row.put("FLPATH", map.get("FLPATH"));
			row.put("EZFILE", map.get("EZFILE"));
			row.put("PROGID", map.get("PROGID"));
			row.put("WAREKY", map.get("WAREKY"));
			row.put("OWNRKY", map.get("OWNRKY"));
			row.put("LANGKY", map.get("LANGKY"));
			row.put("PRTL01", row.getString("WAREKY"));
			row.put("PRTL02", row.getString("RQSHPD"));
			row.put("PRTL03", row.getString("BTMP01"));
			row.put("PRTL04", row.getString("BARCOD"));
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			commonDao.insert(row);
			count++;
		}
		result.put("PRTSEQ",prtSeq);
		result.put("CNT", count);
		
		return result;
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = Exception.class)
	public DataMap WOS24_Print(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		String prtSeq = "";
		DataMap row;
		DataMap result = new DataMap();
		int count = 0;
		
		//print report 시퀀스 채번
		prtSeq = wmsService.getDocSeq("NR_PRTSEQ");
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.clonSessionData(row);
			
			if(row.getInt("QTSHCC")>0) {
				row.setModuleCommand("WmsReport", "PRTLG");
				row.put("PRTSEQ", prtSeq);
				row.put("PRTNUM", i+1);
				row.put("PRTTYP", map.get("PRTTYP"));
				row.put("FLPATH", map.get("FLPATH"));
				row.put("EZFILE", map.get("EZFILE"));
				row.put("PROGID", map.get("PROGID"));
				row.put("WAREKY", map.get("WAREKY"));
				row.put("OWNRKY", map.get("OWNRKY"));
				row.put("LANGKY", map.get("LANGKY"));
				row.put("PRTL01", row.getString("SHPOKY"));
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
				commonDao.insert(row);
			}
			count++;
		}
		result.put("PRTSEQ",prtSeq);
		result.put("CNT", count);
		
		return result;
	}
	
	
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = Exception.class)
	public DataMap WDL01_PLTPrint(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		String prtSeq = "";
		DataMap row;
		DataMap result = new DataMap();
		int count = 0;
		//print report 시퀀스 채번
		prtSeq = wmsService.getDocSeq("NR_PRTSEQ");
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.clonSessionData(row);
			row.setModuleCommand("WmsReport", "PRTLG");
			row.put("PRTSEQ", prtSeq);
			row.put("PRTNUM", i+1);
			row.put("PRTTYP", map.get("PRTTYP"));
			row.put("FLPATH", map.get("FLPATH"));
			row.put("EZFILE", map.get("EZFILE"));
			row.put("PROGID", map.get("PROGID"));
			row.put("WAREKY", map.get("WAREKY"));
			row.put("OWNRKY", map.get("OWNRKY"));
			row.put("LANGKY", map.get("LANGKY"));
			row.put("PRTL01", map.get("WAREKY"));
			row.put("PRTL02", map.get("RQSHPD"));
			row.put("PRTL03", row.getString("BTMP01"));
			row.put("PRTL04", row.getString("BARCOD"));
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			commonDao.insert(row);
			count++;
		}
		result.put("PRTSEQ",prtSeq);
		result.put("CNT", count);
		
		return result;
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = Exception.class)
	public DataMap WSQ11_Print(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		String prtSeq = "";
		DataMap row;
		DataMap result = new DataMap();
		int count = 0;
		//print report 시퀀스 채번
		prtSeq = wmsService.getDocSeq("NR_PRTSEQ");
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.clonSessionData(row);
			row.setModuleCommand("WmsReport", "PRTLG");
			row.put("PRTSEQ", prtSeq);
			row.put("PRTNUM", i+1);
			row.put("PRTTYP", map.get("PRTTYP"));
			row.put("FLPATH", map.get("FLPATH"));
			row.put("EZFILE", map.get("EZFILE"));
			row.put("PROGID", map.get("PROGID"));
			row.put("WAREKY", map.get("WAREKY"));
			row.put("OWNRKY", map.get("OWNRKY"));
			row.put("LANGKY", map.get("LANGKY"));
			row.put("PRTL01", row.getString("ISPSEQ"));
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			commonDao.insert(row);
			count++;
		}
		result.put("PRTSEQ",prtSeq);
		result.put("CNT", count);
		
		return result;
	}
	
	*//**
	 * [MSK10,MSE10] 물품마스터 바코드 출력
	 * [공통] 물품마스터 바코드 출력 
	 * 물품마스터 바코드를  출력한다.
	 * @param map
	 * @return DataMap
	 * @throws Exception
	 * @controller MaterialController
	 * @method materialPrintBarcode 
	 *//*
	@Transactional
	public DataMap materialPrintBarcode(HttpSession session, DataMap map) throws Exception {
		DataMap rsMap = new DataMap();
		
		List<DataMap> dataList = new ArrayList<DataMap>();
		List<DataMap> list = map.getList("list");
		int len = list.size();
		DataMap row;
		int count = 0;
		
		if(len > 0){
			String prtseq = map.getString("PRTSEQ");
			for(int i = 0; i < len; i++){
				row = list.get(i).getMap("map");
				map.clonSessionData(row);
				row.setModuleCommand("WmsReport", "PRTLG");
				
				row.put("PRTSEQ", prtseq);
				row.put("PRTNUM", i+1);
				row.put("QTYPRT", 1);
				row.put("PRTTYP", map.getString("PRTTYP"));
				row.put("EZFILE", map.getString("EZFILE"));
				row.put("FLPATH", map.getString("FLPATH"));
				row.put("PROGID", map.getString("PROGID"));
				row.put("SKUKEY", row.getString("SKUKEY"));
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
				
				dataList.add(row);
			}
			map.setModuleCommand("WmsReport", "PRTLG");
			try {
//				count = (int) commonDao.batchInsert(session, map, dataList);
			}catch(Exception e ) {
				String errMsg = ComU.getLastMsg(e.getMessage());
				log.error(errMsg);
				throw new SQLException(wmsService.getMessageParam(map.getString("SES_LANGUAGE"), "IN_M9036", new String[]{"[" + errMsg + "]"}));
			}
			
			rsMap.put("PRTSEQ", prtseq);
			
		}
		
		rsMap.put("FLPATH", map.getString("FLPATH"));
		rsMap.put("EZFILE", map.getString("EZFILE"));
		rsMap.put("CNT", count);
		
		return rsMap;
	}
	*/
}