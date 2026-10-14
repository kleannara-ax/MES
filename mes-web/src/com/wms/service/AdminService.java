package com.wms.service;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Set;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.common.bean.CommonConfig;
import com.common.bean.DataMap;
import com.common.bean.SystemConfig;
import com.common.dao.CommonDAO;
import com.common.bean.DataMap;
import com.common.util.Util;
import com.mysql.jdbc.StringUtils;

@Service
public class AdminService {

	private static Logger log = Logger.getLogger(AdminService.class);

	@Autowired
	private Util util;
	
	@Autowired
	public CommonDAO commonDao;
	
	@Autowired
	private SystemConfig systemConfig;
	
	//private String sqlType = systemConfig.getSqlType();

	@Transactional
	public String validationSK01(DataMap map) throws SQLException {
		
		String result = "OK";
		List<DataMap> list = map.getList("list");
		
		String validationSql = "";
		String key = map.get("key").toString();
		if( map.containsKey("key") ){
			validationSql = util.urlCreateValidationSql(map, key);
			map.put(CommonConfig.VALIDATION_SQL_KEY, validationSql);
			map.setModuleCommand("WmsAdmin", "SKUMA");
						
			List<DataMap> vList = commonDao.getValidation(map);
			
			DataMap rsMap = new DataMap();
			
			for(int j = 0; j < vList.size(); j++){
				rsMap = vList.get(j);
					
				if( !rsMap.getString("MSG").equals("OK") ){
					
					result = rsMap.getString("MSG");
					break;
				}
			}
		}
	
		return result;
	}
	
	@Transactional
	public String validationSP01(DataMap map) throws SQLException {
		String result = "OK";
		List<DataMap> list = map.getList("list");
		
		System.out.println("list > " + list);
		
		String validationSql = "";
		String key = map.get("key").toString();
		if( map.containsKey("key") ){
			validationSql = util.urlCreateValidationSql(map, key);
			map.put(CommonConfig.VALIDATION_SQL_KEY, validationSql);
			map.setModuleCommand("WmsAdmin", "PAKMA");
						
			List<DataMap> vList = commonDao.getValidation(map);
			
			System.out.println("vList > " + vList);
			DataMap row = new DataMap();
			DataMap rsMap = new DataMap();
			String rowState = row.getString(CommonConfig.GRID_ROW_STATE_ATT);
			System.out.println("rowState > " + rowState);
			
			for(int j = 0; j < vList.size(); j++){
				rsMap = vList.get(j);
					
				if( !rsMap.getString("MSG").equals("OK") ){
					
					result = rsMap.getString("MSG");
					break;
				}
			}
		}
	
		return result;
	}
	
	/*@Transactional
	public int saveSM01(DataMap map) throws SQLException {
		List<DataMap> head = map.getList("head");
		List<DataMap> list = map.getList("list");
		
		DataMap headRow = new DataMap();
		DataMap row = new DataMap();
		String rowState = "";
		int count = 0;
		
		for(int i=0;i<head.size();i++){
			headRow = head.get(i).getMap("map");
			rowState = headRow.getString(CommonConfig.GRID_ROW_STATE_ATT);
			headRow.setModuleCommand("WmsAdmin", "MEASH");
			headRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			
			if( rowState.charAt(0)  == 'R' ){
				continue;
			}else if( rowState.charAt(0)  == 'C' ){
				commonDao.insert(headRow);
			}else if( rowState.charAt(0)  == 'U' ){
				commonDao.delete(headRow);
				commonDao.insert(headRow);
			}else if( rowState.charAt(0)  == 'D' ){
				commonDao.delete(headRow);
				row = head.get(i).getMap("map");
				row.setModuleCommand("WmsAdmin", "MEASHSubAll");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				commonDao.delete(row);
			}
			count++;
		}
		
		for(int j=0;j<list.size();j++){
			row = list.get(j).getMap("map");
			rowState = row.getString(CommonConfig.GRID_ROW_STATE_ATT);
			row.setModuleCommand("WmsAdmin", "MEASHSub");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			if( rowState.charAt(0)  == 'R' ){
				continue;
			}else if( rowState.charAt(0)  == 'C' ){
				commonDao.insert(row);
			}else if( rowState.charAt(0)  == 'U' ){
				commonDao.update(row);
			}else if( rowState.charAt(0)  == 'D' ){
				commonDao.delete(row);
			}
			count++;
		}
		return count;
	}
	*/
	@Transactional
	public String saveSM01(DataMap map) throws SQLException {
		List<DataMap> head = map.getList("head");
		List<DataMap> list = map.getList("list");

		DataMap headRow = new DataMap();
		DataMap row = new DataMap();

		String result = "HHT_T0008";

		for (int i = 0; i < head.size(); i++) {
			headRow = head.get(i).getMap("map");
			headRow.setModuleCommand("WmsAdmin", "MEASH");
			headRow.put(CommonConfig.SES_USER_ID_KEY,
					map.get(CommonConfig.SES_USER_ID_KEY));

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
				row.setModuleCommand("WmsAdmin", "MEASHSubAll");
				row.put(CommonConfig.SES_USER_ID_KEY,
						map.get(CommonConfig.SES_USER_ID_KEY));
				
				commonDao.delete(row);
			}
		}

		for (int j = 0; j < list.size(); j++) {
			row = list.get(j).getMap("map");
			row.setModuleCommand("WmsAdmin", "MEASHSub");
			row.put(CommonConfig.SES_USER_ID_KEY,
					map.get(CommonConfig.SES_USER_ID_KEY));
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
		return result;
	}

	@Transactional
	public String saveSM02(DataMap map) throws SQLException {
		String result = "OK";

		List<DataMap> list = map.getList("list");
		DataMap row = null;
		String table = "UOMMA";

		StringBuffer duplValid = new StringBuffer();
//		StringBuffer dataValid = new StringBuffer();
		for (int i = 0; i < list.size(); i++) {
			row = list.get(i).getMap("map");

			if (i > 0) {
				duplValid.append(" UNION ALL \n ");
			}

			duplValid.append("SELECT ");
			if (row.getString("GRowState", " ").equals("R")) {
				duplValid.append("0 AS STATUS");
			} else if (row.getString("GRowState", " ").equals("C")) {
				duplValid.append("1 AS STATUS");
			} else if (row.getString("GRowState", " ").equals("U")) {
				duplValid.append("0 AS STATUS");
			} else if (row.getString("GRowState", " ").equals("D")) {
				duplValid.append("-1 AS STATUS");
			}
			duplValid.append(", '").append(row.getString("UOMKEY")).append("' AS UOMKEY");
			duplValid.append(" FROM DUAL");

//			if(i > 0)
//				dataValid.append(" UNION ALL \n ");
//			
//			dataValid.append("SELECT ");
//			dataValid.append("'").append(row.get("GRowState")).append("' AS STATUS");
//			dataValid.append(", '").append(row.getString("UOMKEY")).append("' AS UOMKEY");
//			dataValid.append(" FROM DUAL");
		}

		map.setModuleCommand("WmsAdmin", table + "_DUPL_VALIDATION");
		map.put("VALIDATION_DUPL_SQL", duplValid.toString());

		String duplValidationResult = (String) commonDao.getObject(map);
		if (duplValidationResult != null && !duplValidationResult.trim().equals("")) {
			return duplValidationResult;
		}

//		map.setModuleCommand(sqlMapNamespace, table + "_DATA_VALIDATION");
//		map.put("VALIDATION_DATA_SQL", dataValid.toString());
//		
//		String dataValidationResult = (String)commonDao.getObject(map);
//		if(dataValidationResult != null && !dataValidationResult.trim().equals("")) {
//			return dataValidationResult;
//		}

		for (int i = 0; i < list.size(); i++) {
			row = list.get(i).getMap("map");
			row.setModuleCommand("WmsAdmin", table);
			map.clonSessionData(row);

			if (row.getString("GRowState", " ").equals("D")) {
				commonDao.delete(row);
			}
		}

		for (int i = 0; i < list.size(); i++) {
			row = list.get(i).getMap("map");
			row.setModuleCommand("WmsAdmin", table);
			map.clonSessionData(row);

			if (row.getString("GRowState", " ").equals("C")) {
				commonDao.insert(row);
			} else if (row.getString("GRowState", " ").equals("U")) {
				commonDao.update(row);
			}
		}

		return result;
	}
	
	@Transactional
	public int saveSP01(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		List<DataMap> head = map.getList("head");
		
		DataMap headRow = new DataMap();
		DataMap row = new DataMap();
		
		int count = 0;
		for(int i=0;i<list.size();i++){			
			row = list.get(i).getMap("map");			
			//row.append(list.get(i).getMap("map"));			
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.setModuleCommand("WmsAdmin", "PAKMA");
			
			String rowState = row.getString(CommonConfig.GRID_ROW_STATE_ATT);
			switch(rowState.charAt(0)){
				case 'C':
					commonDao.insert(row);
					break;
				case 'U':
					commonDao.update(row);
					break;
				case 'D':
					commonDao.delete(row);
					break;
			}
			count++;
		}
		
		for(int i=0;i<head.size();i++){			
			headRow = head.get(i).getMap("map");			
			//row.append(list.get(i).getMap("map"));			
			headRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			headRow.setModuleCommand("WmsAdmin", "PAKMAHEAD");
			
			String rowState = headRow.getString(CommonConfig.GRID_ROW_STATE_ATT);
			switch(rowState.charAt(0)){
				case 'D':
					commonDao.delete(headRow);
					break;
			}
			count++;
		}
		return count;
	}
	
	
	
	@Transactional
	public int saveSK01(DataMap map) throws SQLException {
		
		List<DataMap> head = map.getList("head");
		
		DataMap row;
		String rowState = "";
		int count = 0;
		
		for(int i = 0; i< head.size(); i++){
			
			row = head.get(i).getMap("map");
			rowState = row.getString(CommonConfig.GRID_ROW_STATE_ATT);
			
			log.debug("status::::::::::::::::::::::::"+row.getString("GRowState"));
			
			if( rowState.charAt(0)  == 'U' ){
				
				row.setModuleCommand("WmsAdmin", "SKUWC");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				commonDao.update(row);
				
				row.setModuleCommand("WmsAdmin", "SKUMA");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				commonDao.update(row);
				
			}else	if( rowState.charAt(0)  == 'C' ){	
				log.debug("::::::::::::::insert::::::::::::::::::::::");
				
				row.setModuleCommand("WmsAdmin", "SKUWC");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				commonDao.insert(row);
				
				row.setModuleCommand("WmsAdmin", "SKUMA");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				commonDao.insert(row);
				
			}else	if( rowState.charAt(0)  == 'R' ){	
				
			}else	if( rowState.charAt(0)  == 'D' ){
				row.setModuleCommand("WmsAdmin", "SKUWC");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				commonDao.delete(row);
				
				row.setModuleCommand("WmsAdmin", "SKUMA");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				commonDao.delete(row);
			}
			count++;
		}
		return count;
	}
	
	

	@Transactional
	public String saveCC01(DataMap map) throws SQLException {
		List<DataMap> head = map.getList("head");
		List<DataMap> list = map.getList("list");

		DataMap headRow = new DataMap();
		DataMap row = new DataMap();

		String result = "HHT_T0008";

		for (int i = 0; i < head.size(); i++) {
			headRow = head.get(i).getMap("map");
			headRow.setModuleCommand("WmsAdmin", "CC01");
			headRow.put(CommonConfig.SES_USER_ID_KEY,
					map.get(CommonConfig.SES_USER_ID_KEY));

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
				row.setModuleCommand("WmsAdmin", "CC01Sub");
				row.put(CommonConfig.SES_USER_ID_KEY,
						map.get(CommonConfig.SES_USER_ID_KEY));
				commonDao.delete(row);
			}
		}

		for (int j = 0; j < list.size(); j++) {
			row = list.get(j).getMap("map");
			row.setModuleCommand("WmsAdmin", "CC01Sub");
			row.put(CommonConfig.SES_USER_ID_KEY,
					map.get(CommonConfig.SES_USER_ID_KEY));
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
		return result;
	}

	@Transactional
	public String saveTA01(DataMap map) throws SQLException {
		List<DataMap> head = map.getList("head");
		List<DataMap> list = map.getList("list");

		DataMap headRow = new DataMap();
		DataMap row = new DataMap();

		String result = "HHT_T0008";

		for (int i = 0; i < head.size(); i++) {
			headRow = head.get(i).getMap("map");
			headRow.setModuleCommand("WmsAdmin", "TA01");
			headRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));

			if (headRow.getString("GRowState").equals("R")) {
				continue;
			} else if (headRow.getString("GRowState").equals("C")) {
				commonDao.insert(headRow);
			} else if (headRow.getString("GRowState").equals("U")) {
				commonDao.delete(headRow);
				commonDao.insert(headRow);
			} else {
				commonDao.delete(headRow);
				
				row = head.get(i).getMap("map");
				row.setModuleCommand("WmsAdmin", "TA01Sub");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				commonDao.delete(row);
			}
		}
		
		for (int j = 0; j < list.size(); j++) {
			row = list.get(j).getMap("map");
			row.setModuleCommand("WmsAdmin", "TA01Sub");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			if (row.get("STATUS").toString().equals("R") || row.getString("GRowState").equals("R")) {
				continue;
			} else if (row.get("STATUS").toString().equals("C") || row.getString("GRowState").equals("C")) {
				commonDao.insert(row);
			} else if (row.get("STATUS").toString().equals("U") || row.getString("GRowState").equals("U")) {
				commonDao.delete(row);
				commonDao.insert(row);
			} else {
				commonDao.delete(row);
			}
		}
		
		return result;
	}


	@Transactional
	public String saveTP01(DataMap map) throws SQLException {
		List<DataMap> head = map.getList("head");
		List<DataMap> list = map.getList("list");

		DataMap headRow = new DataMap();
		DataMap row = new DataMap();

		String result = "COMMON_M0007"; 

		for (int i = 0; i < head.size(); i++) {
			headRow = head.get(i).getMap("map");
			headRow.setModuleCommand("WmsAdmin", "TP01");
			headRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));

			if (headRow.get("GRowState").toString().equals("R")) {
				continue;
			} else if (headRow.get("GRowState").toString().equals("C")) {
				commonDao.insert(headRow);
			} else if (headRow.get("GRowState").toString().equals("U")) {
				commonDao.delete(headRow);
				commonDao.insert(headRow);
			} else {
				commonDao.delete(headRow);
				
				row = head.get(i).getMap("map");
				row.setModuleCommand("WmsAdmin", "TP01Sub");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				
				commonDao.delete(row);
			}
		}

		for (int j = 0; j < list.size(); j++) {
			row = list.get(j).getMap("map");
			row.setModuleCommand("WmsAdmin", "TP01Sub");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			if (row.get("GRowState").toString().equals("R")) {
				continue;
			} else if (row.get("GRowState").toString().equals("C")) {
				commonDao.insert(row);
			} else if (row.get("GRowState").toString().equals("U")) {
				commonDao.delete(row);
				commonDao.insert(row);
			} else {
				commonDao.delete(row);
			}
		}
		return result;
	}

	
	@Transactional
	public int saveNR01(DataMap map) throws SQLException {
		int count = 0;

		DataMap list = map.getMap("list").getMap("map");
		if(map.get("flag").equals("U")){
			list.setModuleCommand("WmsAdmin", "NR01UP");
		}else{
			list.setModuleCommand("WmsAdmin", "NR01I");
		}
		
		count += commonDao.update(list);

		return count;
	}
	
	@Transactional
	public String saveTF01(DataMap map) throws SQLException {
		String result = "OK";
		
		List<DataMap> list = map.getList("list");
		DataMap itemlistMap = map.getMap("itemlist");
		List<DataMap> itemlist = null;
		DataMap headRow = null, itemRow;
		String headTable = "RLRRH";
		String itemTable = "RLRRI";
		String headKey = null;
		
		Set<String> keySetForValid = itemlistMap.keySet();
		for(String key : keySetForValid) {
			itemlist = itemlistMap.getList(key);
			if(itemlist.size() == 0) {
				continue;
			}
			StringBuffer dataValid = new StringBuffer();
			for(int i=0; i<itemlist.size(); i++) {
				itemRow = itemlist.get(i).getMap("map");
				
				if(i > 0)
					dataValid.append(" UNION ALL \n ");
				
				dataValid.append("SELECT ");
				dataValid.append("'").append('C').append("' AS STATUS");
				dataValid.append(", '").append(itemRow.getString("WAREKY")).append("' AS WAREKY");
				dataValid.append(", '").append(itemRow.getString("LOTRKY")).append("' AS LOTRKY");
				dataValid.append(", '").append(itemRow.getString("DBFILD")).append("' AS DBFILD");
				dataValid.append(", '").append(itemRow.getString("RNGVMI")).append("' AS RNGVMI");
				dataValid.append(", '").append(itemRow.getString("RNGVOP")).append("' AS RNGVOP");
				dataValid.append(" FROM DUAL");
			}
			
			map.setModuleCommand("WmsAdmin", "RLRRI_DATA_VALIDATION");
			map.put("VALIDATION_DATA_SQL", dataValid.toString());
			
			String dataValidationResult = (String)commonDao.getObject(map);
			if(dataValidationResult != null && !dataValidationResult.trim().equals("")) {
				return dataValidationResult;
			}
		}
		
		for(int hIndex=0; hIndex<list.size(); hIndex++) {
			headRow = list.get(hIndex).getMap("map");
			
			headRow.setModuleCommand("WmsAdmin", "RLRRH_MERGE");
			map.clonSessionData(headRow);
			
			commonDao.update(headRow);
		}
		
		Set<String> keySet = itemlistMap.keySet();
		for(String key : keySet) {
			itemlist = itemlistMap.getList(key);
			
			if(itemlist != null && itemlist.size() >= 0) {
				itemRow = itemlist.get(0).getMap("map");
				itemRow.setModuleCommand("WmsAdmin", "RLRRI");
				map.clonSessionData(itemRow);
				// 현재 존재하는 item리스트 제거 
				// ITEMNO가 상황마다 달라져서 전체 삭제하고 넣으려고함
				commonDao.delete(itemRow); 
				
				int itemno = 0;
				for(int iIndex=0; iIndex<itemlist.size(); iIndex++) {
					itemRow = itemlist.get(iIndex).getMap("map");
					itemRow.setModuleCommand("WmsAdmin", "RLRRI");
					map.clonSessionData(itemRow);
					if(!itemRow.getString("GRowState"," ").equals("D")) {
						if(!itemRow.get("RNGVMI").equals(" ")){
							if(itemRow.get("DBFILD").equals("LOTA13") && itemRow.get("RNGVOP").equals("LT") && itemRow.get("RNGVMI").equals("0")) {
								continue;
							}
							itemRow.put("ITEMNO", String.format("%06d", itemno+1));
							itemRow.setModuleCommand("WmsAdmin", "RLRRI_MERGE");
							commonDao.update(itemRow);
							itemno++;
						}
					}
				}
			}
		}
		
		return result;
	}	
	
	@Transactional
	public int delTF01(DataMap map) throws SQLException {
		int count=0;
		DataMap head = map.getMap("head").getMap("map");
		head.setModuleCommand("WmsAdmin", "TF01I");
		count += commonDao.delete(head);
		head.setModuleCommand("WmsAdmin", "TF01SubI");
		count += commonDao.delete(head);
		return count;
	}
	
	@Transactional
	public int delNR01(DataMap map) throws SQLException {
		int count = 0;

		DataMap list = map.getMap("list").getMap("map");
		list.setModuleCommand("WmsAdmin", "NR01DEL");
		
		count += commonDao.delete(list);

		return count;
	}
	
	@Transactional
	public String saveTS01(DataMap map) throws SQLException {
		String result = "OK";
		
		List<DataMap> list = map.getList("list");
		DataMap itemlistMap = map.getMap("itemlist");
		List<DataMap> itemlist = null;
		DataMap headRow = null, itemRow;
		String headTable = "STSRH";
		String itemTable = "STSRI";
		String headKey = null;
		
		Set<String> keySetForValid = itemlistMap.keySet();
		for(String key : keySetForValid) {
			itemlist = itemlistMap.getList(key);
			if(itemlist.size() == 0) {
				continue;
			}
			StringBuffer dataValid = new StringBuffer();
			for(int i=0; i<itemlist.size(); i++) {
				itemRow = itemlist.get(i).getMap("map");
				
				if(i > 0)
					dataValid.append(" UNION ALL \n ");
				
				dataValid.append("SELECT ");
				dataValid.append("'").append(itemRow.getString("WAREKY")).append("' AS WAREKY");
				dataValid.append(", '").append(itemRow.getString("SSORKY")).append("' AS SSORKY");
				dataValid.append(", '").append(itemRow.getString("SORTSQ")).append("' AS SORTSQ");
				dataValid.append(" FROM DUAL");
			}
			
			map.setModuleCommand("WmsAdmin", itemTable + "_DATA_VALIDATION");
			map.put("VALIDATION_DATA_SQL", dataValid.toString());
			
			String dataValidationResult = (String)commonDao.getObject(map);
			if(dataValidationResult != null && !dataValidationResult.trim().equals("")) {
				return dataValidationResult;
			}
		}
		
		for(int hIndex=0; hIndex<list.size(); hIndex++) {
			headRow = list.get(hIndex).getMap("map");
			
			headRow.setModuleCommand("WmsAdmin", headTable + "_MERGE");
			map.clonSessionData(headRow);
			
			commonDao.update(headRow);
		}
		
		
		int a = 1;
		Set<String> keySet = itemlistMap.keySet();
		for(String key : keySet) {
			itemlist = itemlistMap.getList(key);
			
			if(itemlist != null && itemlist.size() >= 0) {
				for(int iIndex=0; iIndex<itemlist.size(); iIndex++) {
					itemRow = itemlist.get(iIndex).getMap("map");
					
					itemRow.setModuleCommand("WmsAdmin", itemTable);
					map.clonSessionData(itemRow);
					
					if(itemRow.getString("GRowState"," ").equals("D")) {
						commonDao.delete(itemRow);
					} else { 
						itemRow.setModuleCommand("WmsAdmin", itemTable + "_MERGE");
						commonDao.update(itemRow);
					}
				}
			}
		}
		
		return result;
	}
	
	@Transactional
	public int sendSynch(DataMap map) throws SQLException {
		//List<DataMap> list = map.getList("list");
		int count = 0;
		map.setModuleCommand("WmsAdmin", "sendSynch");
		commonDao.getMap(map);

		return count;
	}
	
	@Transactional
	public int sendSynch2(DataMap map) throws SQLException {
		//List<DataMap> list = map.getList("list");
		int count = 0;
		map.setModuleCommand("WmsAdmin", "sendSynch2");
		commonDao.getMap(map);

		return count;
	}
	
	@Transactional
	public String validationSA01(DataMap map) throws SQLException {
		String result = "OK";
		List<DataMap> list = map.getList("list");
		
		String validationSql = "";
		String key = map.get("key").toString();
		if( map.containsKey("key") ){
			validationSql = util.urlCreateValidationSql(map, key);
			map.put(CommonConfig.VALIDATION_SQL_KEY, validationSql);
			map.setModuleCommand("WmsAdmin", "SA01VAL");
						
			List<DataMap> vList = commonDao.getValidation(map);
			
			DataMap rsMap = new DataMap();
			
			for(int j = 0; j < vList.size(); j++){
				rsMap = vList.get(j);
				if( !rsMap.getString("MSG").equals("OK") ){
					result = rsMap.getString("MSG");
					break;
				}
			}
		}
		return result;
	}
	
	@Transactional
	public int saveSK03(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		int count = 0;
		
		DataMap row;
		String rowState = "";
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			rowState = row.getString(CommonConfig.GRID_ROW_STATE_ATT);
			
			if( rowState.charAt(0)  == 'U' ){
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
				row.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
				commonDao.update("WmsAdmin.SK03SKU", row);
			}else if( rowState.charAt(0)  == 'C' ){
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
				row.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
				commonDao.insert("WmsAdmin.SKUMA", row);
			}else if( rowState.charAt(0)  == 'D' ){
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
				row.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
				commonDao.delete("WmsAdmin.SKUMA", row);
			}
			
			count ++;
		}
		return count;
	}
	
	@Transactional
	public int updateIF01(DataMap map) throws SQLException {
		DataMap resultMap = new DataMap();
		int opt = map.getInt("num");
		String credat = map.getString("CREDAT").replace(".", "");
		
		int count = 0;
		
		map.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		map.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
		map.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
		map.setModuleCommand("Erpif", "IF01_0"+opt);
		map.put("CREDAT", credat);
		
		commonDao.update(map);
		count ++;
		
		return count;
	}
	
	@Transactional
	public int checkIF01(DataMap map) throws SQLException {
		DataMap resultMap = new DataMap();
		int opt = map.getInt("num");
		String credat = map.getString("CREDAT").replace(".", "");
		
		int count = 0;
		
		map.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		map.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
		map.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
		map.setModuleCommand("Erpif", "IF01CHK_0"+opt);
		map.put("CREDAT", credat);
		
		commonDao.update(map);
		count ++;
		
		return count;
	}
	

	@Transactional
	public String saveMr01(DataMap map) throws Exception {
		
		List<DataMap> list = map.getList("list");
		
		StringBuffer sb = new StringBuffer();
		for(DataMap item : list){
			if(sb.length() > 0)
				sb.append(" UNION ALL\n ");
			sb.append(" SELECT '").append(item.getMap("map").get("WAREKY")).append("' AS WAREKY, ");
			sb.append("        '").append(item.getMap("map").get("LSTOTY")).append("' AS LSTOTY, ");
			sb.append("        '").append(item.getMap("map").get("ZONEKY")).append("' AS ZONEKY, ");
			sb.append("        '").append(item.getMap("map").get("AREAKY")).append("' AS AREAKY FROM DUAL ");
		}	
		map.setModuleCommand("WmsAdmin", "STORY"); // 쿼리키값 넣을것
		map.put("APPEND_QUERY", sb.toString());
		List<DataMap> validList = commonDao.getValidation(map);
		if(validList.size() > 0){
			DataMap valid = validList.get(0);
			return valid.getString("RESULTMSG");
		}	
		return "OK";
	}
	
	@Transactional
	public int delTS01(DataMap map) throws SQLException {
		int count=0;
		DataMap head = map.getMap("head").getMap("map");
		
		head.setModuleCommand("WmsAdmin", "STSRHTOP");
		count += commonDao.delete(head);
		head.setModuleCommand("WmsAdmin", "STSRIDEL");
		count += commonDao.delete(head);
		return count;
		
	}

	@Transactional
	public int delTR01(DataMap map) throws SQLException {
		int count = 0;
		map.setModuleCommand("WmsAdmin", "ALCUS");
		count += commonDao.delete(map);
		
		return count;
	}

	public int saveMA01(DataMap map) throws SQLException {
		int count = 0;
		DataMap row;
		List<DataMap> list = map.getList("list");
		String rowState = "";
		
		for(int i=0; i<list.size(); i++){
			row = list.get(i).getMap("map");
			rowState = row.getString(CommonConfig.GRID_ROW_STATE_ATT);
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.setModuleCommand("WmsAdmin", "AREMA");
			
			if(rowState.charAt(0) == 'U'){
				commonDao.update(row);
			}else if(rowState.charAt(0) == 'C'){
				commonDao.insert(row);
			}else if(rowState.charAt(0) == 'D'){
				commonDao.delete(row);
			}
			count++;
		}
		
		return count;
	}

	public int saveMZ01(DataMap map) throws SQLException {
		int count = 0;
		DataMap row;
		List<DataMap> list = map.getList("list");
		String rowState = "";
		
		for(int i=0; i<list.size(); i++){
			row = list.get(i).getMap("map");
			rowState = row.getString(CommonConfig.GRID_ROW_STATE_ATT);
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.setModuleCommand("WmsAdmin", "ZONMA");
			
			if(rowState.charAt(0) == 'U'){
				commonDao.update(row);
			}else if(rowState.charAt(0) == 'C'){
				commonDao.insert(row);
			}else if(rowState.charAt(0) == 'D'){
				commonDao.delete(row);
			}
			count++;
		}
		
		return count;
	}
	
	@Transactional
	public int saveML01(DataMap map) throws SQLException {
		int count = 0;
		List<DataMap> list = map.getList("list");
		
		DataMap row;
		String rowState = "";
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			rowState = row.getString(CommonConfig.GRID_ROW_STATE_ATT);
			
			if( rowState.charAt(0)  == 'U' ){
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				row.put("WAREKY", map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
				row.put("OWNRKY", map.get(CommonConfig.SES_USER_OWNER_KEY));
				commonDao.update("WmsAdmin.SAVEML01", row);
			}
			count ++;
		}
		return count;
	}
	

	@Transactional
	public DataMap saveMB01(DataMap map) throws SQLException {
		List<DataMap> head = map.getList("head");
		List<DataMap> itemList = map.getList("list");
		DataMap row;
		String prcTyp; 
		for(int i = 0 ; i < itemList.size() ; i ++){
			row = itemList.get(i).getMap("map");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			prcTyp = itemList.get(i).getMap("map").getString("PRCTYP");
			if (prcTyp.equals("YN")){
				row.setModuleCommand("WmsAdmin", "AGNMB01");
				commonDao.insert(row);				
			}
			else if (prcTyp.equals("NY")){
				row.setModuleCommand("WmsAdmin", "DELMB01");
				commonDao.delete(row);
			}
		}
		DataMap rsMap = new DataMap();
		StringBuilder sb = new StringBuilder();
		for(int i = 0 ; i < head.size() ; i ++){
			if(sb.length() > 0) 
				sb.append(" UNION ALL\n ");
			sb.append(" SELECT '").append(head.get(i).getMap("map").get("WAREKY")).append("' AS WAREKY, ");
			sb.append("        '").append(head.get(i).getMap("map").get("BUILDG")).append("' AS BUILDG, ");
			sb.append("        '").append(head.get(i).getMap("map").get("STOREY")).append("' AS STOREY FROM DUAL ");
		}
		rsMap.put("APPEND_QUERY", sb.toString());
		return rsMap;
	}
	
	@Transactional
	public int DeleteMB01(DataMap map) throws SQLException {
		
		DataMap row;
		row = map.getMap("list");
		row.setModuleCommand("WmsAdmin", "DELMB01");
		row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		commonDao.delete(row);
		
		return 1;
	}
	
	@Transactional
	public String createTF01(DataMap map) throws SQLException {
		String result = "OK";
		
		DataMap insertMap = new DataMap();
		insertMap.put("WAREKY", map.getString("WAREKY"));
		insertMap.put("LOTRKY", map.getString("LOTRKY"));
		insertMap.put("SHORTX", map.getString("SHORTX"));
		map.clonSessionData(insertMap);
		
		insertMap.setModuleCommand("WmsAdmin", "TF01I");	//INSERT_RLRRH
		commonDao.update(insertMap);
		
		return result;
	}
	
	@Transactional
	public String deleteTF01(DataMap map) throws SQLException {
		String result = "OK";
		
		String wareky = map.getString("WAREKY");
		String lotrky = map.getString("LOTRKY");
		
		DataMap deleteMap = new DataMap();
		deleteMap.put("WAREKY", wareky);
		deleteMap.put("LOTRKY", lotrky);
		map.clonSessionData(deleteMap);
		
		deleteMap.setModuleCommand("WmsAdmin", "ALSTI_COUNT");
		DataMap validMap = commonDao.getMap(deleteMap);
		if(validMap != null) {
			String countStr = validMap.getString("COUNT");
			BigDecimal count = new BigDecimal(countStr);
			if(count.compareTo(BigDecimal.ZERO) > 0) {
				result = "할당필터링키 [" + wareky + " - " + lotrky + "]은/는 할당전략에서 사용중으로 삭제할 수 없습니다.";
				return result;
			}
		}
		
		
		deleteMap.setModuleCommand("WmsAdmin", "RLRRH_RLRRI_DEL");
		commonDao.delete(deleteMap);
		
		return result;
	}
	
	@Transactional
	public String createTS01(DataMap map) throws SQLException {
		String result = "OK";
		
		DataMap insertMap = new DataMap();
		insertMap.put("WAREKY", map.getString("WAREKY"));
		insertMap.put("SSORKY", map.getString("SSORKY"));
		insertMap.put("SHORTX", map.getString("SHORTX"));
		map.clonSessionData(insertMap);
		
		insertMap.setModuleCommand("WmsAdmin", "STSRH");
		commonDao.insert(insertMap);
		
		insertMap.put("WAREKY", map.getString(" "));
		insertMap.put("SSORKY", map.getString(" "));
		insertMap.setModuleCommand("WmsAdmin", "STSRI");
		List<DataMap> inputList = commonDao.getList(insertMap);
		
		for(DataMap item : inputList) {
			map.clonSessionData(item);
			item.setModuleCommand("WmsAdmin", "STSRI");
			item.put("WAREKY", map.getString("WAREKY"));
			item.put("SSORKY", map.getString("SSORKY"));
			commonDao.insert(item);
		}
		
		return result;
	}
	
	@Transactional
	public String deleteTS01(DataMap map) throws SQLException {
		String result = "OK";
		
		String wareky = map.getString("WAREKY");
		String ssorky = map.getString("SSORKY");
		
		DataMap deleteMap = new DataMap();
		deleteMap.put("WAREKY", wareky);
		deleteMap.put("SSORKY", ssorky);
		map.clonSessionData(deleteMap);
		
		deleteMap.setModuleCommand("WmsAdmin", "ALSTI_COUNT");
		DataMap validMap = commonDao.getMap(deleteMap);
		if(validMap != null) {
			String countStr = validMap.getString("COUNT");
			BigDecimal count = new BigDecimal(countStr);
			if(count.compareTo(BigDecimal.ZERO) > 0) {
				result = "할당정렬키 [" + wareky + " - " + ssorky + "]은/는 할당전략에서 사용중으로 삭제할 수 없습니다.";
				return result;
			}
		}
		
		
		deleteMap.setModuleCommand("WmsAdmin", "STSRH_STSRI_DEL");
		commonDao.delete(deleteMap);
		
		return result;
	}

	@Transactional
	public String createTS02(DataMap map) throws SQLException {
		String result = "OK";
		
		DataMap insertMap = new DataMap();
		insertMap.put("WAREKY", map.getString("WAREKY"));
		insertMap.put("SHSTKY", map.getString("SHSTKY"));
		insertMap.put("SHORTX", map.getString("SHORTX"));
		map.clonSessionData(insertMap);
		
		insertMap.setModuleCommand("WmsAdmin", "STORH");
		commonDao.insert(insertMap);
		
		insertMap.put("WAREKY", map.getString(" "));
		insertMap.put("SHSTKY", map.getString(" "));
		insertMap.setModuleCommand("WmsAdmin", "STORI");
		List<DataMap> inputList = commonDao.getList(insertMap);
		
		for(DataMap item : inputList) {
			map.clonSessionData(item);
			item.setModuleCommand("WmsAdmin", "STORI");
			item.put("WAREKY", map.getString("WAREKY"));
			item.put("SHSTKY", map.getString("SHSTKY"));
			commonDao.insert(item);
		}
		
		return result;
	}

	@Transactional
	public String deleteTS02(DataMap map) throws SQLException {
		String result = "OK";
		
		String wareky = map.getString("WAREKY");
		String shstky = map.getString("SHSTKY");
		
		DataMap deleteMap = new DataMap();
		deleteMap.put("WAREKY", wareky);
		deleteMap.put("SHSTKY", shstky);
		map.clonSessionData(deleteMap);
		
		
//		해당 정렬키가 사용중인지 여부는 추후에 개발 해야합니다.
		
//		deleteMap.setModuleCommand("WmsAdmin", "ALSTI2_COUNT");
//		DataMap validMap = commonDao.getMap(deleteMap);
//		if(validMap != null) {
//			String countStr = validMap.getString("COUNT");
//			BigDecimal count = new BigDecimal(countStr);
//			if(count.compareTo(BigDecimal.ZERO) > 0) {
//				result = "할당정렬키 [" + wareky + " - " + shstky + "]은/는 할당전략에서 사용중으로 삭제할 수 없습니다.";
//				return result;
//			}
//		}
		
		
		deleteMap.setModuleCommand("WmsAdmin", "STORH_STORI_DEL");
		commonDao.delete(deleteMap);
		
		return result;
	}
	

	@Transactional
	public String saveTS02(DataMap map) throws SQLException {
		String result = "OK";
		
		List<DataMap> list = map.getList("list");
		DataMap itemlistMap = map.getMap("itemlist");
		List<DataMap> itemlist = null;
		DataMap headRow = null, itemRow;
		String headTable = "STORH";
		String itemTable = "STORI";
		String headKey = null;
		
		Set<String> keySetForValid = itemlistMap.keySet();
		for(String key : keySetForValid) {
			itemlist = itemlistMap.getList(key);
			if(itemlist.size() == 0) {
				continue;
			}
			StringBuffer dataValid = new StringBuffer();
			for(int i=0; i<itemlist.size(); i++) {
				itemRow = itemlist.get(i).getMap("map");
				
				if(i > 0)
					dataValid.append(" UNION ALL \n ");
				
				dataValid.append("SELECT ");
				dataValid.append("'").append(itemRow.getString("WAREKY")).append("' AS WAREKY");
				dataValid.append(", '").append(itemRow.getString("SHSTKY")).append("' AS SHSTKY");
				dataValid.append(", '").append(itemRow.getString("SORTSQ")).append("' AS SORTSQ");
				dataValid.append(" FROM DUAL");
			}
			
			map.setModuleCommand("WmsAdmin", itemTable + "_DATA_VALIDATION");
			map.put("VALIDATION_DATA_SQL", dataValid.toString());
			
			String dataValidationResult = (String)commonDao.getObject(map);
			if(dataValidationResult != null && !dataValidationResult.trim().equals("")) {
				return dataValidationResult;
			}
		}
		
		for(int hIndex=0; hIndex<list.size(); hIndex++) {
			headRow = list.get(hIndex).getMap("map");
			
			headRow.setModuleCommand("WmsAdmin", headTable + "_MERGE");
			map.clonSessionData(headRow);
			
			commonDao.update(headRow);
		}
		
		
		int a = 1;
		Set<String> keySet = itemlistMap.keySet();
		for(String key : keySet) {
			itemlist = itemlistMap.getList(key);
			
			if(itemlist != null && itemlist.size() >= 0) {
				for(int iIndex=0; iIndex<itemlist.size(); iIndex++) {
					itemRow = itemlist.get(iIndex).getMap("map");
					
					itemRow.setModuleCommand("WmsAdmin", itemTable);
					map.clonSessionData(itemRow);
					
					if(itemRow.getString("GRowState"," ").equals("D")) {
						commonDao.delete(itemRow);
					} else { 
						itemRow.setModuleCommand("WmsAdmin", itemTable + "_MERGE");
						commonDao.update(itemRow);
					}
				}
			}
		}
		
		return result;
	}
	
	@Transactional
	public String saveTR02_Backup(DataMap map) throws SQLException {
		String result = "OK";
		
		List<DataMap> list = map.getList("list");
		DataMap row = null;
		
		/**
		StringBuffer duplValid = new StringBuffer();
		StringBuffer dataValid = new StringBuffer();
		for(int i=0; i<list.size(); i++) {
			row = list.get(i).getMap("map");
			
			if(i > 0)
				duplValid.append(" UNION ALL \n ");
			
			duplValid.append("SELECT ");
			if(row.getString("GRowState"," ").equals("R")) {
				duplValid.append("0 AS STATUS");
			} else if(row.getString("GRowState"," ").equals("C")) {
				duplValid.append("1 AS STATUS");
			} else if(row.getString("GRowState"," ").equals("U")) {
				duplValid.append("0 AS STATUS");
			} else if(row.getString("GRowState"," ").equals("D")) {
				duplValid.append("-1 AS STATUS");
			}
			duplValid.append(", '").append(row.getString("WAREKY")).append("' AS WAREKY");
			duplValid.append(", '").append(row.getString("PRIORT")).append("' AS PRIORT");
			duplValid.append(" FROM DUAL");
			
			
			
			if(i > 0)
				dataValid.append(" UNION ALL \n ");
			
			dataValid.append("SELECT ");
			dataValid.append("'").append(row.get("GRowState")).append("' AS STATUS");
			dataValid.append(", '").append(row.getString("WAREKY")).append("' AS WAREKY");
			dataValid.append(", '").append(row.getString("PRIORT")).append("' AS PRIORT");
			dataValid.append(", '").append(row.getString("OWNRKY", " ")).append("' AS OWNRKY");
			dataValid.append(", '").append(row.getString("ORDTYP", " ")).append("' AS ORDTYP");
			dataValid.append(", '").append(row.getString("PTNRKY", " ")).append("' AS PTNRKY");
			dataValid.append(" FROM DUAL");
			
		}
		
		map.setModuleCommand("WmsAdmin", "ORDPR_DUPL_VALIDATION");
		map.put("VALIDATION_DUPL_SQL", duplValid.toString());
		
		String duplValidationResult = (String)commonDao.getObject(map);
		if(duplValidationResult != null && !duplValidationResult.trim().equals("")) {
			return duplValidationResult;
		}
		
		map.setModuleCommand("WmsAdmin", "ORDPR_DATA_VALIDATION");
		map.put("VALIDATION_DATA_SQL", dataValid.toString());
		
		String dataValidationResult = (String)commonDao.getObject(map);
		if(dataValidationResult != null && !dataValidationResult.trim().equals("")) {
			return dataValidationResult;
		}
		**/
		
		
		for(int i=0; i<list.size(); i++) {
			row = list.get(i).getMap("map");
			row.setModuleCommand("WmsAdmin", "ORDPR");
			map.clonSessionData(row);
			
			if(row.getString("GRowState"," ").equals("D")) {
				commonDao.delete(row);
			}
		}
		
		for(int i=0; i<list.size(); i++) {
			row = list.get(i).getMap("map");
			row.setModuleCommand("WmsAdmin", "ORDPR");
			map.clonSessionData(row);
			
			if(row.getString("GRowState"," ").equals("C")) {
				commonDao.insert(row);
			} else if(row.getString("GRowState"," ").equals("U")) {
				commonDao.update(row);
			}
		}
		
		return result;
	}
	
	@Transactional
	public String saveTR02(DataMap map) throws SQLException {
		String result = "HHT_T0008";
		
		List<DataMap> head = map.getList("head");
		List<DataMap> list = map.getList("list");
		
		DataMap headRow = new DataMap();
		DataMap row = null;
		
		for (int i = 0; i < head.size(); i++) {
			headRow = head.get(i).getMap("map");

			headRow.setModuleCommand("WmsAdmin", "ORDPR");
			headRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			
			if(headRow.getString("GRowState"," ").equals("D")) {
				commonDao.delete(headRow);
			}else {
				headRow.setModuleCommand("WmsAdmin", "ORDPR");
				commonDao.update(headRow);
			}			
		}

		for(int i=0; i<list.size(); i++) {
			row = list.get(i).getMap("map");
				
			row.setModuleCommand("WmsAdmin", "ORDPR");
			map.clonSessionData(row);
			
			if(row.getString("GRowState"," ").equals("D")) {
				commonDao.delete(row);
			}else {
				row.setModuleCommand("WmsAdmin", "ORDPR_MERGE");
				commonDao.update(row);
			}
		}
		
		return result;
	}
	
	@Transactional
	public String saveRC01(DataMap map) throws SQLException {
		//기존 밸리데이션 체크 부분 수정
		String result = "OK";
		
		List<DataMap> list = map.getList("list");
		DataMap row = null;
		DataMap row2 = null;
		String table = "RSNCD";
		StringBuffer duplValid = new StringBuffer();
		
		for(int i=0; i<list.size(); i++) {
			row = list.get(i).getMap("map");
			
			if(i > 0)
				duplValid.append(" UNION ALL \n ");
			
			duplValid.append("SELECT ");
			if(row.getString("GRowState"," ").equals("R")) {
				duplValid.append("0 AS STATUS");
			} else if(row.getString("GRowState"," ").equals("C")) {
				duplValid.append("1 AS STATUS");
			} else if(row.getString("GRowState"," ").equals("U")) {
				duplValid.append("0 AS STATUS");
			} else if(row.getString("GRowState"," ").equals("D")) {
				duplValid.append("-1 AS STATUS");
			}
			duplValid.append(", '").append(row.getString("OWNRKY")).append("' AS OWNRKY");
			duplValid.append(", '").append(row.getString("DOCCAT")).append("' AS DOCCAT");
			duplValid.append(", '").append(row.getString("DOCUTY")).append("' AS DOCUTY");
			duplValid.append(", '").append(row.getString("RSNCOD")).append("' AS RSNCOD FROM DUAL");
			
			
		}
		
		map.setModuleCommand("WmsAdmin", table + "_DUPL_VALIDATION");
		map.put("VALIDATION_DUPL_SQL", duplValid.toString());
		DataMap ss = null;
		String duplValidationResult = "";
		//String duplValidationResult = (String)commonDao.getMap(map).get("VALIDATION_MSG");
		ss =  commonDao.getMap(map);
		if(ss != null){
			duplValidationResult = (String)ss.get("VALIDATION_MSG");
		}
		
		if(duplValidationResult != null && !duplValidationResult.trim().equals("")) {
			return duplValidationResult;
		}
		
		for(int i=0 ; i < list.size() ; i++){
			row2 = list.get(i).getMap("map");
			row2.setModuleCommand("WmsAdmin", "RC01");
			map.clonSessionData(row2);
			
			if(row2.getString("GRowState"," ").equals("U")){
				commonDao.update(row2);
			}else if(row2.getString("GRowState"," ").equals("C")){
				commonDao.insert(row2);
			}else if(row2.getString("GRowState"," ").equals("D")){
				commonDao.delete(row2);
			}
		}
		
		return result;
	}
	
	@Transactional
	public String saveDT01(DataMap map) throws SQLException {
		String result = "OK";
		
		DataMap itemRow;
		List<DataMap> list = map.getList("list");
		StringBuffer sb = new StringBuffer();
		DataMap row;
		
		for(DataMap item : list){
			if(item.getMap("map").get("GRowState").equals("D") || ((String) item.getMap("map").get("SYSLOC")).trim().equals("")){
				continue;
			}
			
				if(sb.length() > 0){
					sb.append(" UNION ALL\n ");
				}
				sb.append(" SELECT '").append(item.getMap("map").get("DOCCAT")).append("' AS DOCCAT, ");
				sb.append("        '").append(item.getMap("map").get("NUMOBJ")).append("' AS NUMOBJ, ");
				sb.append("        '").append(item.getMap("map").get("SYSLOC")).append("' AS SYSLOC, ");
				sb.append("        '").append(item.getMap("map").get("PRIORT")).append("' AS PRIORT, ");
				sb.append("        '").append(item.getMap("map").get("DOCGRP")).append("' AS DOCGRP FROM DUAL ");
			
		}
		
		map.setModuleCommand("WmsAdmin", "DT01");
		map.put("VALIDATION_SQL", sb.toString());
		if(!sb.toString().equals("")){
			List<DataMap> validList = commonDao.getValidation(map);
		
			if(validList.size() > 0){
				DataMap valid = validList.get(0);
				return valid.getString("MSG");
			}
		}
	
		for(int i=0 ; i < list.size() ; i++){
			itemRow = list.get(i).getMap("map");
			itemRow.setModuleCommand("WmsAdmin", "DT01");
			map.clonSessionData(itemRow);
			
			if(itemRow.getString("GRowState"," ").equals("U")){
				commonDao.update(itemRow);
			}else if(itemRow.getString("GRowState"," ").equals("C")){
				commonDao.insert(itemRow);
			}else if(itemRow.getString("GRowState"," ").equals("D")){
				commonDao.delete(itemRow);
			}
		}
		return result;
	}
	
	@Transactional
	public String saveMS01(DataMap map) throws SQLException {
		
		String result = "OK";
		String sqlMapNamespace = "WmsAdmin";
		String sqlType = systemConfig.getSqlType();
		
		List<DataMap> list = map.getList("list");
		DataMap row = null;
		String table = "STLMA";
		
		StringBuffer duplValid = new StringBuffer();
		StringBuffer dataValid = new StringBuffer();
		for(int i=0; i<list.size(); i++) {
			row = list.get(i).getMap("map");
			
			if(i > 0)
				duplValid.append(" UNION ALL \n ");
			
			duplValid.append("SELECT ");
			if(row.getString("GRowState"," ").equals("R")) {
				duplValid.append("0 AS STATUS");
			} else if(row.getString("GRowState"," ").equals("C")) {
				duplValid.append("1 AS STATUS");
			} else if(row.getString("GRowState"," ").equals("U")) {
				duplValid.append("0 AS STATUS");
			} else if(row.getString("GRowState"," ").equals("D")) {
				duplValid.append("-1 AS STATUS");
			}
			
			duplValid.append(", '").append(row.getString("OWNRKY")).append("' AS OWNRKY");
			duplValid.append(", '").append(row.getString("PLNTKY")).append("' AS PLNTKY");
			duplValid.append(", '").append(row.getString("STLKY")).append("' AS STLKY");
			duplValid.append(", '").append(row.getString("WAREKY")).append("' AS WAREKY");
			if( !"mssql".equals(sqlType) ){
				duplValid.append(" FROM DUAL");
			}
			
			if(i > 0)
				dataValid.append(" UNION ALL \n ");
			
			dataValid.append("SELECT ");
			dataValid.append("'").append(row.getString("GRowState")).append("' AS STATUS");
			dataValid.append(", '").append(row.getString("OWNRKY")).append("' AS OWNRKY");
			dataValid.append(", '").append(row.getString("PLNTKY")).append("' AS PLNTKY");
			dataValid.append(", '").append(row.getString("STLKY")).append("' AS STLKY");
			dataValid.append(", '").append(row.getString("WAREKY")).append("' AS WAREKY");
			if( !"mssql".equals(sqlType) ){
				dataValid.append(" FROM DUAL");
			}
		}
		
		map.setModuleCommand(sqlMapNamespace, table + "_DUPL_VALIDATION");
		map.put("VALIDATION_DUPL_SQL", duplValid.toString());
		
		String duplValidationResult = (String)commonDao.getObject(map);
		if(duplValidationResult != null && !duplValidationResult.trim().equals("")) {
			return duplValidationResult;
		}
		
		for(int i=0; i<list.size(); i++) {
			row = list.get(i).getMap("map");
			row.setModuleCommand(sqlMapNamespace, table);
			map.clonSessionData(row);
			
			if(row.getString("GRowState"," ").equals("D")) {
				commonDao.delete(row);
			}
		}
		
		for(int i=0; i<list.size(); i++) {
			row = list.get(i).getMap("map");
			row.setModuleCommand(sqlMapNamespace, table);
			map.clonSessionData(row);
			
			if(row.getString("GRowState"," ").equals("C")) {
				commonDao.insert(row);
			} else if(row.getString("GRowState"," ").equals("U")) {
				commonDao.update(row);
			}
		}
	
		return result;
	}
	
	@Transactional
	public String saveDT02(DataMap map) throws SQLException {
		
		String result = "OK";
		String sqlMapNamespace = "WmsAdmin";
		String sqlType = systemConfig.getSqlType();
		
		List<DataMap> list = map.getList("list");
		DataMap row = null;
		String table = "DOCPG";
		
		StringBuffer duplValid = new StringBuffer();
		StringBuffer dataValid = new StringBuffer();
		// validation 로직
		for(int i=0; i<list.size(); i++) {
			row = list.get(i).getMap("map");
			
			if(i > 0)
				duplValid.append(" UNION ALL \n ");
			
			duplValid.append("SELECT ");
			if(row.getString("GRowState"," ").equals("R")) {
				duplValid.append("0 AS STATUS");
			} else if(row.getString("GRowState"," ").equals("C")) {
				duplValid.append("1 AS STATUS");
			} else if(row.getString("GRowState"," ").equals("U")) {
				duplValid.append("0 AS STATUS");
			} else if(row.getString("GRowState"," ").equals("D")) {
				duplValid.append("-1 AS STATUS");
			}
			duplValid.append(", '").append(row.getString("PROGID").trim()).append("' AS PROGID");
			duplValid.append(", '").append(row.getString("DOCCAT").trim()).append("' AS DOCCAT");
			duplValid.append(", '").append(row.getString("DOCUTY").trim()).append("' AS DOCUTY");
			if( !"mssql".equals(sqlType) ){
				duplValid.append(" FROM DUAL");
			}
			
			
			if(i > 0)
				dataValid.append(" UNION ALL \n ");
			
			dataValid.append("SELECT ");
			dataValid.append("'").append(row.get("GRowState")).append("' AS STATUS");
			dataValid.append(", '").append(row.getString("PROGID").trim()).append("' AS PROGID");
			dataValid.append(", '").append(row.getString("DOCCAT").trim()).append("' AS DOCCAT");
			dataValid.append(", '").append(row.getString("DOCUTY").trim()).append("' AS DOCUTY");
			if( !"mssql".equals(sqlType) ){
				dataValid.append(" FROM DUAL");
			}
			
		}
		
		map.setModuleCommand(sqlMapNamespace, table + "_DUPL_VALIDATION");
		map.put("VALIDATION_DUPL_SQL", duplValid.toString());
		
		String duplValidationResult = (String)commonDao.getObject(map);
		if(duplValidationResult != null && !duplValidationResult.trim().equals("")) {
			return duplValidationResult;
		}
		
		// 저장 로직
		for(int i=0; i<list.size(); i++) {
			row = list.get(i).getMap("map");
			row.setModuleCommand(sqlMapNamespace, table);
			map.clonSessionData(row);
			
			if(row.getString("GRowState"," ").equals("D")) {
				commonDao.delete(row);
			}
		}
		
		for(int i=0; i<list.size(); i++) {
			row = list.get(i).getMap("map");
			row.setModuleCommand(sqlMapNamespace, table);
			map.clonSessionData(row);
			
			if(row.getString("GRowState"," ").equals("C")) {
				commonDao.insert(row);
			} else if(row.getString("GRowState"," ").equals("U")) {
				commonDao.update(row);
			}
		}
		
		return result;
	}
	
}