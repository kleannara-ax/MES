package com.wms.service;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.common.bean.CommonConfig;
import com.common.bean.DataMap;
import com.common.dao.CommonDAO;
import com.common.bean.DataMap;
import com.common.util.StringUtility;
import com.common.util.Util;
import com.ibatis.sqlmap.client.SqlMapClient;
import com.ibatis.sqlmap.client.SqlMapSession;

@Service
public class TaskService {

	private static Logger log = Logger.getLogger(TaskService.class);
	
	@Autowired
	private Util util;
	
	@Autowired
	public CommonDAO commonDao;
	
	@Autowired
	@Qualifier("sqlMapClient")
	SqlMapClient sqlMapClient;
	
	@Autowired
	public WmsService wmsService;
	
	public static boolean isNull(String value) {
		return (value == null);
	}
	
	public static boolean isEmpty(String value) {
		return (isNull(value) || value.trim().length() == 0);
	}
	
	public static boolean isNotEmpty(String value) {
		return isEmpty(value) ? false : true;
	}
	/**
	 * 적치 완료
	 * @param request
	 * @param model
	 * @return
	 * @throws SQLException
	 */
	@Transactional
	public String PT01ValueCheck(DataMap map) throws SQLException {
		String result = "OK";
		List<DataMap> list = map.getList("list");
		
		DataMap row;
		String VALIDATION_SQL = "";
		int addCnt = 1;
		
		String validationSql = "";
		String key = map.get("key").toString();
		
		if(map.containsKey("key")){
			validationSql = util.urlCreateValidationSql(map, key);
			map.put(CommonConfig.VALIDATION_SQL_KEY, validationSql);
			map.setModuleCommand("WmsTask", "TASDI");
			List<DataMap> vList = commonDao.getValidation(map);
			
			DataMap rsMap = new DataMap(); 
			for(int i = 0; i < vList.size(); i++){
				rsMap = vList.get(i);
				
				// skuwc 검사
				if(isEmpty(rsMap.getString("SKUWC_SKUKEY"))){
					result = "MASTER_M0569 SKUKEY";										//*상품코드는 등록되지 않은 코드입니다.
					break;
				}
				
				// Putaway strategy key, Location 
				if(isEmpty(rsMap.getString("SKUWC_SKUKEY")) && isEmpty(rsMap.getString("LOCATG"))){
					result = "TASK_M0016 PASTKY";										//* 적치전략이 등록되지 않았습니다. 상품마스터를 확인해주세요.
					break;
				}
				
				// Target location검사
				if(isNotEmpty(rsMap.getString("LOCATG")) && isEmpty(rsMap.getString("LOCAKY"))){
					result = "TASK_M0011 LOCATG";										//*이동대상 로케이션이 유효하지 않습니다.
					break;
				}
				
				if(rsMap.getString("LOCATG").equals("SCRLOC") || rsMap.getString("LOCATG").equals("SETLOC") || rsMap.getString("LOCATG").equals("RTNLOC") || rsMap.getString("LOCATG").equals("RTSLOC")){
					result = "TASK_M0037 LOCATG";										//*폐기창, 세트창, 반품창, 반품해체창으로 이동할 수 없습니다.
					break;
				}
				
				// 자동창고 여부 검사
				if ("V".equals(rsMap.getString("AUTLOC"))) {
					result = "TASK_M0024 LOCATG";
					break;
				}
				
				// Putaway strategy key
				if(isNotEmpty(rsMap.getString("PASTKY")) && isEmpty(rsMap.getString("PASTH_PASTKY"))){
					result = "TASK_M0017 PASTKY";
					break;
				}
			}
		}
		
		return result;
	} 
	
	@Transactional
	public String PT01StockCheck(DataMap map) throws SQLException {
		String result = "OK";

		StringBuffer sb = new StringBuffer();		
//		DataMap mapData = (DataMap) ((DataMap) map.get("list")).get("map"); 
		DataMap mapData = map.getMap("list").getMap("map"); 
	
		Iterator<String> keySetIterator = mapData.keySet().iterator();
		while (keySetIterator.hasNext()) {	
		    String key = keySetIterator.next();			    
		    List lista =  (List) mapData.get(key);
		    	if(sb.length() > 0)
				sb.append(" UNION ALL\n ");
				sb.append(" SELECT '").append(lista.get(0)).append("' AS WAREKY, ");
				sb.append("        '").append(lista.get(1)).append("' AS LOTNUM, ");
				sb.append("        '").append(lista.get(2)).append("' AS LOCASR, ");
				sb.append("        '").append(lista.get(3)).append("' AS TRNUSR, ");
				sb.append("        '").append(lista.get(4)).append("' AS STOKKY, ");
				sb.append("        '").append(lista.get(5)).append("' AS QTTAOR FROM DUAL ");		    
		}
		
		map.setModuleCommand("WmsTask", "TASDI_STOCK"); // 쿼리키값 넣을것
		map.put("APPEND_QUERY", sb.toString());

		List<DataMap> validList = commonDao.getValidation(map);
		if(validList.size() > 0){
			DataMap valid = validList.get(0);
			return valid.getString("RESULTMSG");
		}
		return result;
	}
		
//	@Transactional
//	public String PT01LocaacCheck(DataMap map) throws SQLException {
//		String result = "OK";
//		int	   sqlLimit = 1000;
//		int	   sqlCount = 1;
//		int	   sqlTotCount = 1;
//		
//		DataMap head = map.getMap("head");
//		List<DataMap> list = map.getList("list");
//		
//		StringBuffer sb = new StringBuffer();
//
//		for(DataMap item : list){
//			if(sb.length() > 0)
//			sb.append(" UNION ALL\n ");
//			sb.append(" SELECT '").append(head.get("WAREKY")).append("' AS WAREKY, ");	
//			sb.append("        '").append(item.getMap("map").get("TASKIT")).append("' AS TASKIT, ");
//			sb.append("        '").append(item.getMap("map").get("LOCAAC")).append("' AS LOCAAC FROM DUAL ");
//			
//			
//			if ( sqlCount == sqlLimit || sqlTotCount == list.size() ){
//				map.setModuleCommand("WmsTask", "PT01CONF_MASTER");  
//				map.put("APPEND_QUERY", sb.toString());
//			
//				List<DataMap> validList = commonDao.getValidation(map);
//				if(validList.size() > 0){
//					DataMap valid = validList.get(0);
//					return valid.getString("RESULTMSG");
//				}
//				sqlCount = 0;
//				sb.setLength(0); ;
//			}
//			sqlCount++;
//			sqlTotCount++;
//		}	
//		return result;
//	}

	
	@Transactional
	public String PTLocaacCheck(DataMap map) throws SQLException {
		String result = "OK";
		int	   sqlLimit = 1000;
		int	   sqlCount = 1;
		int	   sqlTotCount = 1;
		
		List<DataMap> list = map.getList("list");
		
		StringBuffer sb = new StringBuffer(); 

		for(DataMap item : list){
			if(sb.length() > 0)
			sb.append(" UNION ALL\n ");
			sb.append(" SELECT '").append(map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY)).append("' AS WAREKY, ");	
			sb.append("        '").append(item.getMap("map").get("TASKIT")).append("' AS TASKIT, ");
			sb.append("        '").append(item.getMap("map").get("LOCAAC")).append("' AS LOCAAC FROM DUAL ");
			
			
			if ( sqlCount == sqlLimit || sqlTotCount == list.size() ){
				map.setModuleCommand("WmsTask", "PT01CONF_MASTER");  
				map.put("APPEND_QUERY", sb.toString());
			
				List<DataMap> validList = commonDao.getValidation(map);
				if(validList.size() > 0){
					DataMap valid = validList.get(0);
					return valid.getString("RESULTMSG");
				}
				sqlCount = 0;
				sb.setLength(0); ;
			}
			sqlCount++;
			sqlTotCount++;
		}	
		return result;
	}
	
	
//	@Transactional
//	public String saveValueEndCheck(DataMap map) throws SQLException {
//		String result = "OK";
//		
//		List<DataMap> list = map.getList("list");
//		DataMap row;
//		DataMap rsMap;
//		for(int i=0;i<list.size();i++){
//			row = list.get(i).getMap("map");
//			row.setModuleCommand("WmsTask", "SHPDHDRELIN");
//			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
//			rsMap = commonDao.getMap(map);
//			
//			if(rsMap.get("DRELIN").toString().equals("V")){
//				result = "TASK_M0034";
//			}
//		}
//		return result;
//	}

	@Transactional
	public String PT01StockSave(DataMap map) throws SQLException {
		DataMap head = map.getMap("head").getMap("map");
		List<DataMap> list = map.getList("list");
		String workType = map.getString("workType");
		
		int count = 1;
		int itemCount = 0;
		DataMap row;
		String snum;
		String inum;
		
//		Connection conn = sqlMapClient.getDataSource().getConnection();  
// 	    conn.setAutoCommit(false);
// 	    SqlMapSession session = sqlMapClient.openSession(conn);
		
//		try{
			head.setModuleCommand("WmsTask", "TASDH");
			head.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			
			commonDao.insert(head);
			
			for(int i=0;i<list.size();i++){
				row = list.get(i).getMap("map");
				row.setModuleCommand("WmsTask", "PT01_TASDI");
				row.put("TASKKY", head.get("TASKKY"));
				
				itemCount += 10;
				snum = String.valueOf(itemCount);
				inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
				
//				log.debug("::::::::::::::::::::::"+row.getString("QTSAVLB"));
				
				row.put("TASKIT", inum);
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				commonDao.insert(row);
				
				if (workType.equals("2")){
					row.put("STOKKY", "%");
				}
				
				//tasdr 프로시져에서 처리
//				row.setModuleCommand("WmsTask", "TASDR");
//				commonDao.insert(row);
				commonDao.getMap("WmsTask.DBMSPROC_SZP_INS_TASDR", row);				
			}
	 			// Procedure Version 보류 		
//			head.put("DOCUKY", head.getString("TASKKY"));
//			commonDao.getMap("WmsInbound.GR_AIRWMS_DOCUMENT_PROCESS", head);
			
//			conn.commit();
//		}catch(Exception e){
//			
//		}finally{
// 	        if(session != null){ session.close(); }
// 	        if(conn != null){ conn.close(); }      
//		}
		
		return (String)head.get("TASKKY");
	}
	
	@Transactional
	public int PT01SaveEnd(DataMap map) throws SQLException {
		DataMap head = map.getMap("head").getMap("map");
		List<DataMap> list = map.getList("list");
		String workType = map.getString("workType");

		int count = 1;
		int itemCount = 0;
		int qtcomp = 0;
		
		DataMap row;
		
		for(int i=0;i<list.size();i++){
			
			row = list.get(i).getMap("map");
			row.setModuleCommand("WmsTask", "TASDIDEL");
			commonDao.delete(row);
			qtcomp = Integer.parseInt(row.getString("QTCOMP"));
			
			if (qtcomp > 0) {
				row.put("STATIT","FPA");						//적치 컨펌시는  TG값에 AC 값을 넣음  (수량/지번/ID)
				row.put("QTTAOR", row.get("QTCOMP"));
				row.put("LOCATG", row.get("LOCAAC"));		
				row.put("TRNUTG", row.get("TRNUAC"));
				row.put("QTYUOM", row.get("QTCOMP"));
				row.put("SECTAC", row.get("SECTTG"));
				row.put("PAIDAC", row.get("PAIDTG"));
				row.put("ATRUTY", row.get("TTRUTY"));
				row.put("AMEAKY", row.get("TMEAKY"));
				row.put("AUOMKY", row.get("TUOMKY"));
				row.put("QTAPUM", row.get("QTTPUM"));
				row.put("ADUOKY", row.get("TDUOKY"));
				row.put("QTADUM", row.get("QTTDUM"));
				
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				row.setModuleCommand("WmsTask", "TASDIEND");
				commonDao.insert(row);

				if (workType.equals("2")){
					row.put("STOKKY", "%");
				}else{
					row.put("STOKKY", row.getString("SRCSKY"));	
				}
	 			//tasdr 프로시져에서 처리
//				row.setModuleCommand("WmsTask", "TASDREND");
//				commonDao.insert(row);
				commonDao.getMap("WmsTask.DBMSPROC_SZP_INS_TASDR", row);				
			}			
			count++;
		}
//		head.put("DOFLAG", " ");
//		commonDao.getMap("WmsInbound.GR_AIRWMS_DOCUMENT_PROCESS", head);
		
		return count;
	}
	
	@Transactional
	public int PT02SaveEnd(DataMap map) throws SQLException {
//		String workType = map.getString("workType");
		List<DataMap> headList = map.getList("head");
		List<DataMap> itemList = map.getList("list");
		List<DataMap> saveItemList = new ArrayList<DataMap>();
				
		DataMap HeadRowMap = new DataMap();
//		DataMap ItemCopyMap = new DataMap();

		String taskkyHead;
		String taskkyGrid = itemList.get(0).getMap("map").getString("TASKKY");
							
		int count = 1;
		int itemCount = 0;
		int qtcomp = 0;
		DataMap row;
		
		for(int k=0;k<headList.size();k++){
					
			HeadRowMap = headList.get(k).getMap("map");
			taskkyHead = HeadRowMap.getString("TASKKY");			
			saveItemList.clear();
			
			if (taskkyGrid.equals(taskkyHead)){
				saveItemList = map.getList("list");
//				for(int j=0;j<itemList.size();j++){
//					ItemCopyMap = new DataMap(itemList.get(j).getMap("map"));
//					saveItemList.add(ItemCopyMap);			
//				}
//				log.debug(taskkyHead+":::::: ["+ String.valueOf(saveItemList.size()) +"] getList 저장 로직 수행...  :::::"+taskkyGrid);				
			}else {
				HeadRowMap.setModuleCommand("WmsTask", "PT02_SAVE");
				saveItemList = commonDao.getList(HeadRowMap);
//				log.debug(taskkyHead+":::::: ["+ String.valueOf(saveItemList.size()) +"] commonDao 저장 로직 수행...  :::::"+taskkyGrid);
			}

			count = 1;
			itemCount = 0;
			qtcomp = 0;
	//		DataMap row;
		
			for(int i=0;i<saveItemList.size();i++){
				
				row = saveItemList.get(i).getMap("map");
				row.setModuleCommand("WmsTask", "TASDIDEL");
				commonDao.delete(row);
				qtcomp = Integer.parseInt(row.getString("QTCOMP"));
				
				if (qtcomp > 0) {
					row.put("STATIT","FPA");						//적치 컨펌시는  TG값에 AC 값을 넣음  (수량/지번/ID)
					row.put("QTTAOR", row.get("QTCOMP"));
					row.put("LOCATG", row.get("LOCAAC"));		
					row.put("TRNUTG", row.get("TRNUAC"));
					row.put("QTYUOM", row.get("QTCOMP"));
					row.put("SECTAC", row.get("SECTTG"));
					row.put("PAIDAC", row.get("PAIDTG"));
					row.put("ATRUTY", row.get("TTRUTY"));
					row.put("AMEAKY", row.get("TMEAKY"));
					row.put("AUOMKY", row.get("TUOMKY"));
					row.put("QTAPUM", row.get("QTTPUM"));
					row.put("ADUOKY", row.get("TDUOKY"));
					row.put("QTADUM", row.get("QTTDUM"));
					
					row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
					row.setModuleCommand("WmsTask", "TASDIEND");
					commonDao.insert(row);
	
//					if (workType.equals("2")){
					row.put("STOKKY", "%");
//					}else{
//						row.put("STOKKY", row.getString("SRCSKY"));	
//					}
		 			//tasdr 프로시져에서 처리
	//				row.setModuleCommand("WmsTask", "TASDREND");
	//				commonDao.insert(row);
					commonDao.getMap("WmsTask.DBMSPROC_SZP_INS_TASDR", row);				
				}			
				count++;
			}
//		head.put("DOFLAG", " ");
//		commonDao.getMap("WmsInbound.GR_AIRWMS_DOCUMENT_PROCESS", head);

		}		
		return count;
	}
	
	
	@Transactional
	public int PT02Delete(DataMap map) throws SQLException {
		List<DataMap> head = map.getList("head");
		
		int count = 0;
		for(int i=0;i<head.size();i++){
			DataMap row = head.get(i).getMap("map");
			row.setModuleCommand("WmsTask", "TASDI");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			commonDao.delete(row);
			
			row.setModuleCommand("WmsTask", "TASDH");
			commonDao.delete(row);
			
			count++;
		}
		
		return count;
	}	
	
//	@Transactional
//	public int PT02Save(DataMap map) throws SQLException {
//		List<DataMap> head = map.getList("head");
//		List<DataMap> list = map.getList("list");
//		
//		int headSize = head.size();
//		int listSize = list.size();
//		
//		DataMap HeadRow = new DataMap();
//		DataMap row = new DataMap();
//		int count = 0;
//		
//		if(listSize > 0){
//			for(int i=0;i<headSize;i++){
//				HeadRow = head.get(i).getMap("map");
//				HeadRow.setModuleCommand("WmsTask", "TASDHCOMP");
//				HeadRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
//				commonDao.update(HeadRow);
//				
//				count++;
//			}
//			
//			for(int j=0;j<listSize;j++){
//				row = list.get(j).getMap("map");
//				
//				int qtcomp = Integer.parseInt(row.getString("QTCOMP"));
//				
//				row.setModuleCommand("WmsTask", "STKKYPUTFIND");
//				DataMap dtMap = commonDao.getMap(row);
//				log.debug(dtMap);
//				
//				// 생성된 재고의 source stokky값을 넣어준다.
//				row.put("STOKKY", dtMap.getString("SRCSKY"));
//				row.put("LMODAT", dtMap.getString("LMODAT"));
//				row.put("LMOTIM", dtMap.getString("LMOTIM"));
//				row.put("LMOUSR", dtMap.getString("LMOUSR"));
//				
//				int qtspmo = Integer.parseInt(dtMap.getString("QTSPMO"));
//				
//				qtcomp = qtcomp - qtspmo;
//				row.put("QTSTKC", Integer.toString(qtspmo) );
//				row.put("QTSTKM", dtMap.getString("QTSTKM"));
//				int qttaor = Integer.parseInt(row.getString("QTTAOR"));
//				
//				log.debug(qttaor+"::::::<>:::::"+qtcomp);
//				if (qttaor == qtcomp) {
//					row.put("STATIT","FPC");
//				} else if (qttaor > qtcomp) {
//					row.put("STATIT","PPC");
//				} else if (qttaor < qtcomp) {
//					row.put("STATIT","OPC");
//				}
//				
//				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
//				row.setModuleCommand("WmsTask", "TASDI");
//				commonDao.insert(row);
//				
//				row.setModuleCommand("WmsTask", "TASDREND");
//				commonDao.insert(row);
//				
//				count++;
//			}
//			
//		}else{
//			for(int l=0;l<headSize;l++){
//				HeadRow = head.get(l).getMap("map");
//				HeadRow.setModuleCommand("WmsTask", "TASDHCOMP");
//				HeadRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
//				commonDao.update(HeadRow);
//				
//				count++;
//			}
//		}
//		
//		return count;
//	}
	
//	
//	@Transactional
//	public int PT02RowSave(DataMap map) throws SQLException {
//		DataMap head = map.getMap("head").getMap("map");
//		List<DataMap> list = map.getList("list");
//		
//		int count = 1;
//		int itemCount = 0;
//		DataMap row;
//		
//		head.setModuleCommand("WmsTask", "TASDHCOMP");
//		head.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
//		commonDao.update(head);
//		
//		for(int i=0;i<list.size();i++){
//			row = list.get(i).getMap("map");
//			
//			int qtcomp = Integer.parseInt(row.getString("QTCOMP"));
//			
//			row.setModuleCommand("WmsTask", "STKKYPUTFIND");
//			DataMap dtMap = commonDao.getMap(row);
//			log.debug(dtMap);
//			
//			row.setModuleCommand("WmsTask", "TASDIDEL");
//			commonDao.delete(row);
//			
//			// 생성된 재고의 source stokky값을 넣어준다.
//			row.put("STOKKY", dtMap.getString("SRCSKY"));
//			row.put("LMODAT", dtMap.getString("LMODAT"));
//			row.put("LMOTIM", dtMap.getString("LMOTIM"));
//			row.put("LMOUSR", dtMap.getString("LMOUSR"));
//			
//			int qtspmo = Integer.parseInt(dtMap.getString("QTSPMO"));
//			
//			qtcomp = qtcomp - qtspmo;
//			row.put("QTSTKC", Integer.toString(qtspmo) );
//			row.put("QTSTKM", dtMap.getString("QTSTKM"));
//			int qttaor = Integer.parseInt(row.getString("QTTAOR"));
//			
//			log.debug(qttaor+":::::::::::"+qtcomp);
//			if (qttaor == qtcomp) {
//				row.put("STATIT","FPC");
//			} else if (qttaor > qtcomp) {
//				row.put("STATIT","PPC");
//			} else if (qttaor < qtcomp) {
//				row.put("STATIT","OPC");
//			}
//			
//			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
//			row.setModuleCommand("WmsTask", "TASDI");
//			commonDao.insert(row);
//			
//			row.setModuleCommand("WmsTask", "TASDREND");
//			commonDao.insert(row);
//			
//			count++;
//		}
//		
//		return count;
//	}
	
	/**
	 * 피킹 완료
	 * @param request
	 * @param model
	 * @return
	 * @throws SQLException
	 */
	
	@Transactional
	public String DL06StockCheck(DataMap map) throws SQLException {
		String result = "OK";
		int	   sqlLimit = 1000;
		int	   sqlCount = 1;
		int	   sqlTotCount = 1;
		
		List<DataMap> list = map.getList("list");
		
		StringBuffer sb = new StringBuffer(); 

		for(DataMap item : list){
			if(sb.length() > 0)
			sb.append(" UNION ALL\n ");
			sb.append(" SELECT '").append(map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY)).append("' AS WAREKY, ");
			sb.append("        '").append(item.getMap("map").get("TASKKY")).append("' AS TASKKY, ");			
			sb.append("        '").append(item.getMap("map").get("TASKIT")).append("' AS TASKIT, ");
			sb.append("        '").append(item.getMap("map").get("QTSPUT")).append("' AS QTCOMP, ");
			sb.append("        '").append(item.getMap("map").get("SKUKEY")).append("' AS SKUKEY, ");
			sb.append("        '").append(item.getMap("map").get("LOTNUM")).append("' AS LOTNUM, ");
			sb.append("        '").append(item.getMap("map").get("LOCASR")).append("' AS LOCASR, ");			
			sb.append("        '").append(item.getMap("map").get("TRNUSR")).append("' AS TRNUSR FROM DUAL ");
						
			if ( sqlCount == sqlLimit || sqlTotCount == list.size() ){
				map.setModuleCommand("WmsTask", "DL06STOCKCHECK");  
				map.put("APPEND_QUERY", sb.toString());
			
				List<DataMap> validList = commonDao.getValidation(map);
				if(validList.size() > 0){
					DataMap valid = validList.get(0);
					return valid.getString("RESULTMSG");
				}
				sqlCount = 0;
				sb.setLength(0); ;
			}
			sqlCount++;
			sqlTotCount++;
		}	
		return result;
	}
	
	@Transactional
	public int DL06SaveEnd(DataMap map) throws SQLException {
		List<DataMap> headList = map.getList("head");
		List<DataMap> itemList = map.getList("list");
		List<DataMap> saveItemList = new ArrayList<DataMap>();
				
		DataMap HeadRowMap = new DataMap();

		String taskkyHead;
		String taskkyGrid = itemList.get(0).getMap("map").getString("TASKKY");

		int count = 1;
		int itemCount = 0;
		int qtcomp = 0;
		DataMap row;
		DataMap rowTot = new DataMap();
		
		for(int k=0;k<headList.size();k++){
				
			HeadRowMap = headList.get(k).getMap("map");
			taskkyHead = HeadRowMap.getString("TASKKY");
			saveItemList.clear();
			rowTot.put("TASKKY", taskkyHead);
			rowTot.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			
			if (taskkyGrid.equals(taskkyHead)){
				saveItemList = map.getList("list");
			}else {
				HeadRowMap.setModuleCommand("WmsTask", "DL06_SAVE");
				saveItemList = commonDao.getList(HeadRowMap);
			}
			
			/*  Tasdi 삭제 */
			for(int j=0; j<saveItemList.size();j++){
				row = saveItemList.get(j).getMap("map");
				row.setModuleCommand("WmsTask", "TASDIDEL");
				
				//피킹수량이 0일 경우 tasdi삭제
				if("0".equals(row.getString("QTSPUT"))){
					commonDao.delete(row);
				}else{
					commonDao.delete(row);
				}
			}
			
			/*  Tasdi 인써트 */
			count = 1;
			qtcomp = 0;
		
			for(int i=0;i<saveItemList.size();i++){
				row = saveItemList.get(i).getMap("map");
				
				if (taskkyGrid.equals(taskkyHead)){
					row.put("QTCOMP", row.getString("QTSPUT"));
				}else {
					row.put("QTCOMP", row.getString("QTCOMP"));
				}
				
				qtcomp = Integer.parseInt(row.getString("QTCOMP"));
				
				if (qtcomp > 0) {
					row.put("STATIT","FPC"); //적치 컨펌시는  TG값에 AC 값을 넣음  (수량/지번/ID)
					row.put("QTTAOR", row.get("QTCOMP"));
					row.put("LOCAAC", row.get("LOCATG"));
					row.put("TRNUAC", row.get("TRNUTG"));
					row.put("SECTAC", row.get("SECTTG"));
					row.put("PAIDAC", row.get("PAIDTG"));
					row.put("ATRUTY", row.get("TTRUTY"));
					row.put("AMEAKY", row.get("TMEAKY"));
					row.put("AUOMKY", row.get("TUOMKY"));
					row.put("QTAPUM", row.get("QTTPUM"));
					row.put("ADUOKY", row.get("TDUOKY"));
					row.put("QTADUM", row.get("QTTDUM"));
					
					row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
					row.setModuleCommand("WmsTask", "TASDIEND");
					commonDao.insert(row);

					/*  Tasdr 인써트 */
					row.put("STOKKY", "%");
					commonDao.getMap("WmsTask.DBMSPROC_SZP_INS_TASDR", row);
				}
				count++;
			}
			rowTot.setModuleCommand("WmsTask", "CALL_BATCH_PKTOT");
			commonDao.getMap(rowTot);
		}
		return count;
	}
	
	@Transactional
	public DataMap createTaskOrder(DataMap map) throws SQLException {
		DataMap head = map.getMap("head").getMap("map");
		List<DataMap> list = map.getList("list");	
//		StringBuffer sb = new StringBuffer();
//		for(DataMap item : list){
//			if(sb.length() > 0)
//				sb.append(" UNION ALL\n ");
//			
//			sb.append(" SELECT '").append(item.getMap("map").get("WAREKY")).append("' AS WAREKY, ");
//			sb.append("        '").append(item.getMap("map").get("SKUKEY")).append("' AS SKUKEY, ");
//			sb.append("        '").append(item.getMap("map").get("DESC01")).append("' AS DESC01, ");
//			sb.append("        '").append(item.getMap("map").get("LOCAKY")).append("' AS LOCAKY, ");
//			sb.append("        '").append(item.getMap("map").get("LOCATG")).append("' AS LOCATG FROM DUAL ");
//		}
//		
//		map.setModuleCommand("WmsTask", "MV01LOCATION"); // 쿼리키값 넣을것
//		map.put("APPEND_QUERY", sb.toString());
//		List<DataMap> validList = commonDao.getValidation(map);
//		if(validList.size() > 0){
//			DataMap valid = validList.get(0);
//			if(!valid.getString("MSG").equals("OK")){
//				return valid;
//			}
//		}
		
		DataMap rsMap = new DataMap();
		
		if(!map.containsKey("menuid")){
			
			String validationSql = util.createValidationSql(map, "WAREKY,LOCATG,LOCASR");
			if(validationSql.length() > 0){
				map.put(CommonConfig.VALIDATION_SQL_KEY, validationSql);
				map.setModuleCommand("WmsTask", "MV01");
				
				List<DataMap> vList = commonDao.getValidation(map);
				if(vList.size() > 0){
					rsMap = vList.get(0);
					if(!rsMap.getString("MSG").equals("OK")){
						return rsMap;
					}					
				}
			}			
		}
		
		String docnum  = wmsService.getDocSeq("320");
		
		head.setModuleCommand("WmsTask", "TASDH");
		head.put("TSPKEY", head.get("AREAKY"));
		head.put("TASKKY", docnum);
		head.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		commonDao.insert(head);
		
		int count = 1;
		int itemCount = 0;
		DataMap row;
		String snum = "";
		String inum = "";
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.put("TASKKY", docnum);
			row.setModuleCommand("WmsTask", "TASDIEND");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			
			itemCount += 10;
			snum = String.valueOf(itemCount);
			inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
			
			row.put("TASKIT", inum);
			// tasdr insert 파람 생성
			row.put("QTSTKM", row.getString("QTTAOR"));
			row.put("QTSTKC", 0);
			row.put("DROPID", "V");
			
			if(row.getString("CONFIRM").equals("V") || row.getString("CONFIRM").equals("1")){
				row.put("STATIT", "FPC");
				
				row.put("QTCOMP", row.getString("QTTAOR"));
				row.put("LOCAAC", row.getString("LOCATG"));
				row.put("SECTAC", row.getString("SECTTG"));
				row.put("PAIDAC", row.getString("PAIDTG"));
				row.put("TRNUAC", row.getString("TRNUTG"));
				row.put("ATRUTY", row.getString("TTRUTY"));
				row.put("AMEAKY", row.getString("TMEAKY"));
				row.put("AUOMKY", row.getString("TUOMKY"));
				row.put("QTAPUM", row.getString("QTTPUM"));
				row.put("ADUOKY", row.getString("TDUOKY"));
				row.put("QTSTKM", row.getString("QTTAOR"));
				row.put("QTSTKC", row.getString("QTTAOR"));  
			}
			
			commonDao.insert(row);
			
//			row.setModuleCommand("WmsTask", "TASDREND");
//			commonDao.insert(row);
			
			row.setModuleCommand("WmsOutbound", "TK32TASDR_PROCALL");
			commonDao.getMap(row);
			
			count++;
		}
		
		if("331".equals(head.getString("TASOTY")) ||
				"360".equals(head.getString("TASOTY")) ||
				"361".equals(head.getString("TASOTY")) ||
				"380".equals(head.getString("TASOTY")) ||
				"398".equals(head.getString("TASOTY")) ||
				"399".equals(head.getString("TASOTY"))){
			//head.setModuleCommand("WmsTask", "IFWMS301PROC");
			//commonDao.getMap(head);
		}else if("320".equals(head.getString("TASOTY"))){
			head.put("DOCUKY", head.getString("TASKKY"));
			head.put("DOFLAG", "Z");
			//commonDao.getMap("WmsInbound.GR_AIRWMS_DOCUMENT_PROCESS", head);
		}
		
		rsMap.put("data", docnum);
		
		return rsMap;
	}
	
	@Transactional
	public int savePrtseq(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("head");
		int count = 0;
		
		DataMap row;
		for(int i=0;i<list.size();i++){
		    row = list.get(i).getMap("map");
			row.setModuleCommand("WmsTask", "PRTLGPUTA");		
			row.put("PRTSEQ", map.get("PRTSEQ"));	
			
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			commonDao.insert(row);
			
			count ++;
		}
		
		return count;
	}
	
	@Transactional
	public DataMap saveTK32(DataMap map) throws SQLException {
		DataMap head = map.getMap("head").getMap("map");
		List<DataMap> list = map.getList("list");
		String seq = wmsService.getNumSeq("NR03");
		
		DataMap rsMap = new DataMap();
		
		String mnuid = map.getString("MNUID");
		if(mnuid.equals("TK31") || mnuid.equals("TK32") || mnuid.equals("TK33") || mnuid.equals("TK34")){
			head.put("TSPKEY", head.get("AREAKY")); //창간이동/기타출고/폐기출고/공급사 반품출고 일 경우 TSPKEY 컬럼에 From 창고 매핑 
			
			if(mnuid.equals("TK34")){
				head.put("PTNRTY", "VD");
			}
		}
		
		//새로운 taskky 번호 채번
		head.setModuleCommand("WmsTask", "TASDH");
		head.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		head.put("TASKKY", seq);
		head.put("WARETG", head.get("WAREKY"));
		
		commonDao.insert(head);
		
		int count = 1;
		int itemCount = 0;
		DataMap row;
		String snum;
		String inum;
		
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.setModuleCommand("WmsTask", "TASDI");
			row.put("TASKKY", seq);
			row.put("STATIT", "FPC");
			row.put("DROPID", "V");
			
			itemCount += 10;
			snum = String.valueOf(itemCount);
			inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
			
			row.put("TASKIT", inum);
			row.put("LOCASR", row.get("LOCAKY"));
			//row.put("QTCOMP", row.get("QTCOMP"));
			
			
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			commonDao.insert(row);
			
//			row.setModuleCommand("WmsTask", "TASDR");
//			row.put("QTSTKC", row.get("QTTAOR"));
//			commonDao.insert(row);
			row.setModuleCommand("WmsOutbound", "TK32TASDR_PROCALL");
			commonDao.getMap(row);
			
			count ++;
		}
		
		rsMap.put("TASKKY", seq);
		
		return rsMap;
	}
	
	@Transactional
	public int savePrtseqTK90(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("head");
		int count = 0;
		
		DataMap row;
		for(int i=0;i<list.size();i++){
		    row = list.get(i).getMap("map");
			row.setModuleCommand("WmsTask", "PRTLGTK90");		
			row.put("PRTSEQ", map.get("PRTSEQ"));	
			
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			commonDao.insert(row);
			
			count ++;
		}
		
		return count;
	}
	
	@Transactional
	public int CompletePT02(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		int count = 0;
		
		DataMap row;
		for(int i=0;i<list.size();i++){
		    row = list.get(i).getMap("map");
			
			row.setModuleCommand("WmsTask", "PT02PROCALL");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			commonDao.getMap(row);
			
			count ++;
		}
		return count;
	}
	
	
	@Transactional
	public int DeletePT02(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		int count = 0;
		
		DataMap row;
		for(int i=0;i<list.size();i++){
		    row = list.get(i).getMap("map");
			
			row.setModuleCommand("WmsTask", "TASDIDEL");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			commonDao.delete(row);
			
			count ++;
		}
		return count;
	}
	
	@Transactional
	public int DeleteDL06(DataMap map) throws SQLException {
		List<DataMap> selectList = new ArrayList<DataMap>();

		int headModifyIndex = -1;
		List<DataMap> itemList = null;
		if(map.containsKey("headModifyIndex")){
			headModifyIndex = map.getInt("headModifyIndex");
			itemList = map.getList("list");
		}

		List<DataMap> headList = map.getList("head");

		DataMap row;
		int count = 0;

		for(int i=0; i<headList.size(); i++){
			row = headList.get(i).getMap("map");
			
			if(headModifyIndex == i){
				for(int j=0; j<itemList.size();j++){
					if(itemList.get(j).getMap("map").getString("STATIT").equals("NEW")){
						row.append(itemList.get(j).getMap("map"));
						row.setModuleCommand("WmsTask", "TASDIDEL");
						row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
						commonDao.delete(row);
					}	
				}
			}else{
				row.setModuleCommand("WmsTask", "DL06");
				selectList = commonDao.getList(row);
				
				for(int j=0; j<selectList.size();j++){
					if(selectList.get(j).getString("STATIT").equals("NEW")){
						//삭제
						row.append(selectList.get(j).getMap("map"));
						row.setModuleCommand("WmsTask", "TASDIDEL");
						row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
						commonDao.delete(row);
					}	
				}
			}

			//TASDI ITEM 다 삭제되면 TASDH HEAD도 삭제 
			row.setModuleCommand("WmsTask", "TASDHDEL");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			commonDao.delete(row);
			count ++;
		}

		return count;
	}
	
	@Transactional
	public DataMap RecommendLocation(DataMap map) throws SQLException {
		
		List<DataMap> list = map.getList("list");
		DataMap row;
		DataMap rstMap = new DataMap();
		List<DataMap> retList = new ArrayList();
		
		String sqlMapNamespace = "WmsTask";
		
		try {
			
			for(int i=0;i<list.size();i++){
				row = list.get(i).getMap("map");

				row.put("PASTKY", map.get("PASTKY"));
				row.put("USERID", map.get(CommonConfig.SES_USER_ID_KEY));
				
				row.setModuleCommand(sqlMapNamespace, "PUTAWAY_LOCATION_PROC_CALL");
				commonDao.update(row);
				
				retList.add(row);
				
			}
		} catch (Exception e) {
			//e.printStackTrace();
			rstMap.put("MSG", "FAIL");
			return rstMap;
		}
		
		rstMap.put("list", retList);
		rstMap.put("MSG", "OK");
		
		return rstMap;
	}

}