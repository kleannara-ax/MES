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
public class MobileOutboundPickingService {

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
	public int PDPK01Save(DataMap map) throws SQLException {
		List<DataMap> headList = map.getList("head");
		List<DataMap> saveItemList = new ArrayList<DataMap>();
				
		DataMap HeadRowMap = new DataMap();
		String taskkyHead;
		String taskkyGrid = headList.get(0).getMap("map").getString("TASKKY");
		int count = 1;
		int qtcomp = 0;
		DataMap row;
		DataMap rowTot = new DataMap();
		
		for(int k=0;k<headList.size();k++){
					
			HeadRowMap = headList.get(k).getMap("map");
			taskkyHead = HeadRowMap.getString("TASKKY");
			saveItemList.clear();
			rowTot.put("TASKKY", taskkyHead);
			rowTot.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			
			HeadRowMap.setModuleCommand("WmsMobileOutboundPicking", "PDPK01_SAVE");
			saveItemList = commonDao.getList(HeadRowMap);
			
						/*  Tasdi 삭제 */
			for(int j=0;j<saveItemList.size();j++){
				row = saveItemList.get(j).getMap("map");
				row.setModuleCommand("WmsTask", "TASDIDEL");
				commonDao.delete(row);
			}
				
				    	/*  Tasdi 인써트 */
			count = 1;
			qtcomp = 0;
		
			for(int i=0;i<saveItemList.size();i++){
				
				row = saveItemList.get(i).getMap("map");
				row.put("QTCOMP", row.getString("QTCOMP"));
				qtcomp = Integer.parseInt(row.getString("QTCOMP"));
				
				if (qtcomp > 0) {
					row.put("STATIT","FPC");
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
	public int ConfirmPickingPDPK01(DataMap map) throws SQLException {
		int count = 0;
		DataMap row = map.getMap("list");
		if(row.getInt("QTCOMP") > 0){
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.setModuleCommand("WmsMobileOutboundPicking", "PDPK01");
			commonDao.getMap(row);
			count ++;
		}
		return count;
	}

	@Transactional
	public int ConfirmPickingPDPK02(DataMap map) throws SQLException {
		int count = 0;
		DataMap row = map.getMap("list");
		if(row.getInt("QTCOMP") > 0){
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.setModuleCommand("WmsMobileOutboundPicking", "PDPK02");
			commonDao.getMap(row);
			count ++;
		}
		return count;
	}
	
	@Transactional
	public int ConfirmPickingPDPKRM01(DataMap map) throws SQLException {
		int count = 0;
		int qtcomp = 0;
		
		DataMap data = map.getMap("data");
		
		// TASDI delete
		DataMap row = map.getMap("data");
		row.setModuleCommand("WmsMobileOutboundPicking", "TASDIDEL");
		commonDao.delete(row);
		
		// TASDI insert
		count = 1;
		qtcomp = 0;
		
		row.put("QTCOMP", row.getString("QTTAOR"));
		
		qtcomp = Integer.parseInt(row.getString("QTCOMP"));
		
		if(qtcomp > 0) {
			row.put("STATIT","FPC");
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
			row.setModuleCommand("WmsMobileOutboundPicking", "TASDIEND");
			commonDao.insert(row);
			
			// TASDR insert
			row.put("STOKKY", "%");
			commonDao.getMap("WmsMobileOutboundPicking.DBMSPROC_SZP_INS_TASDR", row);
		}
		
		return count;
	}
	
	@Transactional
	public DataMap PDPKRM01QTSWRK(DataMap map) throws SQLException {
		map.setModuleCommand("WmsMobileOutboundPicking", "PDPKRM01_QTSWRK");
		DataMap row = commonDao.getMap(map);
		DataMap rsMap = new DataMap();
		rsMap.put("CNT", row.get("CNT"));
		rsMap.put("QTSIWH", row.get("QTSIWH"));
		return rsMap;
	}
	
	@Transactional
	public DataMap PDPKRM01QTSAVBCNT(DataMap map) throws SQLException {
		map.setModuleCommand("WmsMobileOutboundPicking", "PDPKRM01_QTSAVB");
		DataMap rsMap = commonDao.getMap(map);
		return rsMap;
	}
	
	@Transactional
	public DataMap PDPKRM01SHPINFO(DataMap map) throws SQLException {
		map.setModuleCommand("WmsMobileOutboundPicking", "PDPKRM01_SHPINFO");
		DataMap row = commonDao.getMap(map);
		
		DataMap rsMap = new DataMap();
		rsMap.put("SHPOKY", row.get("SHPOKY"));
		rsMap.put("SHPOIT", row.get("SHPOIT"));
		
		return rsMap;
	} 
	
	@Transactional
	public int PDPKRM01QTUALOCNT(DataMap map) throws SQLException {
		map.setModuleCommand("WmsMobileOutboundPicking", "PDPKRM01_QTUALOCNT");
		DataMap rsMap = commonDao.getMap(map);
		int result = Integer.parseInt(rsMap.get("QTUALO").toString());
		return result;
	} 
	
	@Transactional
	public DataMap PickingInfoPDPKRM01(DataMap map) throws SQLException {
		map.setModuleCommand("WmsMobileOutboundPicking", "PickingInfoPDPKRM01");
		DataMap rsMap = commonDao.getMap(map);
		return rsMap;
	}
	
	@Transactional
	public String SavePDDL05(DataMap map) throws SQLException {
		String result = "OK";
		
		List<DataMap> list = map.getList("head");
		
		DataMap row;
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.clonSessionData(row);
			
			// PPC, FPC일 경우에만 검수되도록
			if ("PPC".equals(row.getString("STATIT")) || "FPC".equals(row.getString("STATIT"))) {			
				row.put("STATIT", "FCK"); //검수완료처리
				commonDao.update("WmsMobileOutboundPicking.PDDL05", row);
				
				// 그룹오더인지 체크하여 원출고문서 출하완료 처리
				row.setModuleCommand("WmsOutbound", "CNTGRPDOC");
				int countCHK =  commonDao.getMap(row).getInt("CNT");
				if(countCHK > 0){				
					// 총괄SUB검수 호출
					row.setModuleCommand("WmsOutbound", "CALL_BATCH_INSPECT_TOT");
					commonDao.getMap(row);	
				}else {			
					if( row.getString("ESHPKY") != null && !row.getString("ESHPKY").equals("")){					
						//해당 Gropky에 대한 list			
						commonDao.update("WmsOutbound.WDL05", row);	
					}
				}
			}
		}
		return result;
	}
}