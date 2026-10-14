package com.mobile.service;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.common.bean.CommonConfig;
import com.common.bean.DataMap;
import com.common.dao.CommonDAO;
import com.common.util.Util;
import com.wms.service.WmsService;

@Service
public class MobilePutawayService {

	@Autowired
	public CommonDAO commonDao;
	
	@Autowired
	public WmsService wmsService;
	
	@Autowired
	private Util util;
	
	@Transactional
	public DataMap makeTaskCheckNomal(DataMap map) throws SQLException {
		DataMap rsMap = new DataMap();
		String validationSql = util.createValidationSql(map, "WAREKY,OWNRKY,SKUKEY,TASOTY,LOCATG,LOCASR,LOTA13,AVAILABLEQTY,QTTAOR");
		if(validationSql.length() > 0){
			map.put(CommonConfig.VALIDATION_SQL_KEY, validationSql);
			map.setModuleCommand("WmsMobilePutaway", "MV01");
			
			List<DataMap> vList = commonDao.getValidation(map);
			if(vList.size() > 0){
				rsMap = vList.get(0);
				if(!rsMap.getString("MSG").equals("OK")){
					return rsMap;
				}					
			}
		}		
		
		return rsMap;
	}
	
	@Transactional
	public DataMap makeTaskNomal_PDMV04(DataMap map) throws SQLException {
		
		DataMap result = makeTaskCheckNomal(map);
		
		if(!result.getString("MSG").equals("OK")){
			return result;
		}
		
		List<DataMap> dataList = map.getList("DATA");
		List typeArray = map.getList("TYPE");
		List<DataMap> workList = new ArrayList<DataMap>();
		
		DataMap copy = new DataMap();
		
		for(int k=0;k<typeArray.size();k++){
			int QTTAOR_SUM = 0;
			workList = new ArrayList<DataMap>();
			for(int i = 0 ; i < dataList.size() ; i ++){
				DataMap tempList = dataList.get(i).getMap("map");
				if(tempList.getString("TASOTY").equalsIgnoreCase(""+typeArray.get(k))){
					QTTAOR_SUM += tempList.getInt("QTTAOR");
					copy = new DataMap(dataList.get(i).getMap("map"));
					workList.add(copy);
				}
			}
			String docNum = wmsService.getDocSeq(""+typeArray.get(k));
			//result.add(docNum);
			map.setModuleCommand("WmsMobilePutaway", "PDMV01HEAD");
			map.put("TASOTY", typeArray.get(k));
			List<DataMap> head = commonDao.getList(map);
			
			DataMap row = head.get(0).getMap("map");
			row.setModuleCommand("WmsMobilePutaway", "TASDH_PDMV01");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			row.put("QTTAOR", QTTAOR_SUM);
			row.put("TASKKY", docNum);
			row.put("TASOTY", typeArray.get(k));
			commonDao.insert(row);
			DataMap itemRow;
			int rowIndex = 0;
			for(int i = 0 ; i < workList.size() ; i ++){
				itemRow = workList.get(i).getMap("map");
				int allQty = itemRow.getInt("QTTAOR");
				itemRow.put("DOCUTY",typeArray.get(k));
				itemRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				itemRow.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
				itemRow.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
				
				itemRow.setModuleCommand("WmsMobilePutaway", "PDMV01BODY");
				List<DataMap> list = commonDao.getList(itemRow);
				for(int j=0;j<list.size();j++){
					if(allQty - list.get(j).getInt("QTTAOR") >= 0){
						rowIndex += 10;
						row = list.get(j).getMap("map");
						row.put("DROPID", "V");
						row.put("TASKKY", docNum);
						row.put("TASKIT", rowIndex);
						if(typeArray.get(k).equals("310") || typeArray.get(k).equals("311")){
							row.put("TASKTY", "PT");
						}else{
							row.put("TASKTY", "MV");
						}
						row.put("STATIT", "FPC");
						row.put("QTTAOR", row.getString("AVAILABLEQTY"));
						row.put("QTCOMP", row.getString("AVAILABLEQTY"));
						row.put("LOCATG", map.getString("LOCATG"));
						row.put("LOCAAC", map.getString("LOCATG"));
						row.put("SECTAC", row.getString("SECTTG"));
						row.put("PAIDAC", row.getString("PAIDTG"));
						row.put("TRNUTG", map.getString("TRNUTG"));
						row.put("TRNUAC", map.getString("TRNUTG"));
						row.put("ATRUTY", row.getString("TTRUTY"));
						row.put("AMEAKY", row.getString("TMEAKY"));
						row.put("AUOMKY", row.getString("TUOMKY"));
						row.put("QTAPUM", row.getString("QTTPUM"));
						row.put("ADUOKY", row.getString("TDUOKY"));
						row.put("QTADUM", row.getString("QTTDUM"));
						row.put("QTSTKM", row.getString("AVAILABLEQTY"));
						row.put("QTSTKC", row.getString("AVAILABLEQTY"));
						row.setModuleCommand("WmsMobilePutaway", "TASDIEND_PDMV01");
						row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
						row.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
						row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
						commonDao.insert(row);
						
						row.setModuleCommand("WmsMobilePutaway", "TASDREND_PDMV01");
						row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
						row.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
						row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
						commonDao.insert(row);
						
						allQty = allQty - list.get(j).getInt("QTTAOR");
					}else if(allQty > 0){
						rowIndex += 10;
						row = list.get(j).getMap("map");
						row.put("DROPID", "V");
						row.put("TASKKY", docNum);
						row.put("TASKIT", rowIndex);
						if(typeArray.get(k).equals("310") || typeArray.get(k).equals("311")){
							row.put("TASKTY", "PT");
						}else{
							row.put("TASKTY", "MV");
						}
						
						row.put("STATIT", "FPC");
						row.put("QTTAOR", allQty);
						row.put("QTCOMP", allQty);
						row.put("LOCATG", map.getString("LOCATG"));
						row.put("LOCAAC", map.getString("LOCATG"));
						row.put("SECTAC", row.getString("SECTTG"));
						row.put("PAIDAC", row.getString("PAIDTG"));
						row.put("TRNUTG", map.getString("TRNUTG"));
						row.put("TRNUAC", map.getString("TRNUTG"));
						row.put("ATRUTY", row.getString("TTRUTY"));
						row.put("AMEAKY", row.getString("TMEAKY"));
						row.put("AUOMKY", row.getString("TUOMKY"));
						row.put("QTAPUM", row.getString("QTTPUM"));
						row.put("ADUOKY", row.getString("TDUOKY"));
						row.put("QTADUM", row.getString("QTTDUM"));
						row.put("QTSTKM", allQty);
						row.put("QTSTKC", allQty);
						row.setModuleCommand("WmsMobilePutaway", "TASDIEND_PDMV01");
						row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
						row.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
						row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
						commonDao.insert(row);
						
						row.setModuleCommand("WmsMobilePutaway", "TASDREND_PDMV01");
						row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
						row.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
						row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
						commonDao.insert(row);
						allQty = 0;
					}
				}
				itemRow = new DataMap();
				itemRow.put("DOCCAT", "300");
				itemRow.put("DOCUKY", docNum);
				itemRow.put("DOFLAG", "Z");
				itemRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				
				commonDao.getMap("WmsMobilePutaway.PDMV03_AIRWMS_DOCUMENT_PROCESS", itemRow);
			}
		}
		
		return result; 
	}
	
	@Transactional
	public DataMap savePDPT01POP(DataMap map) throws SQLException {
		DataMap taskkyMap = map.getMap("list");
		DataMap headRow = new DataMap();
		DataMap row = new DataMap();
		String taskky = taskkyMap.getString("TASKKY");
		String taskit = taskkyMap.getString("TASKIT");
		String curtask = taskky+taskit;
		
		headRow.put("WAREKY", map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
		headRow.put("TASKKY", curtask);
		headRow.setModuleCommand("WmsMobilePutaway", "PDPT01");
		List<DataMap> ItemList = commonDao.getList(headRow);
		
		for(int i=0; i<ItemList.size(); i++){
			
			row = ItemList.get(i).getMap("map");
			row.setModuleCommand("WmsTask", "TASDIDEL");
			commonDao.delete(row);
			int taskqtcomp = Integer.parseInt(row.getString("QTCOMP"));
			int taskqtytot = Integer.parseInt(row.getString("QTYTOT"));
			int curqtcomp = Integer.parseInt(taskkyMap.getString("QTCOMP"));
			
			if (taskqtcomp > 0) {
				row.put("STATIT","FPA");
				row.put("QTTAOR", curqtcomp);
				row.put("QTCOMP", taskqtytot+curqtcomp);
				row.put("LOCATG", taskkyMap.getString("LOCAAC").replace(" ",""));	//적치 컨펌시는  TG값에 AC 값을 넣음 
				row.put("TRNUTG", taskkyMap.getString("TRNUAC").replace(" ",""));	//적치 컨펌시는  TG값에 AC 값을 넣음 
				row.put("LOCAAC", taskkyMap.getString("LOCAAC").replace(" ",""));	//적치 컨펌시는  TG값에 AC 값을 넣음 
				row.put("TRNUAC", taskkyMap.getString("TRNUAC").replace(" ",""));	//적치 컨펌시는  TG값에 AC 값을 넣음 
				row.put("PTLT11", taskkyMap.getString("LOTA11").replace(".",""));
				row.put("PTLT12", taskkyMap.getString("LOTA12").replace(".",""));
				row.put("QTYUOM", curqtcomp);
				row.put("SECTAC", row.get("SECTTG"));
				row.put("PAIDAC", row.get("PAIDTG"));
				row.put("ATRUTY", row.get("TTRUTY"));
				row.put("AMEAKY", row.get("TMEAKY"));
				row.put("AUOMKY", row.get("TUOMKY"));
				row.put("QTAPUM", row.get("QTTPUM"));
				row.put("ADUOKY", row.get("TDUOKY"));
				row.put("QTADUM", row.get("QTTDUM"));
				row.put("PTLT15", "PDA");
				
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				row.setModuleCommand("WmsTask", "TASDIEND");
				commonDao.insert(row);

				row.put("STOKKY", "%");

				commonDao.getMap("WmsTask.DBMSPROC_SZP_INS_TASDR", row);
			}
		}
		DataMap tasdirow = commonDao.getMap("WmsMobilePutaway.TASDINEW", row);

		return tasdirow;
	}
}