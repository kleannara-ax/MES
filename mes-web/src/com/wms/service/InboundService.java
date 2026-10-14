package com.wms.service;

import java.sql.SQLException;
import java.util.ArrayList;
//import java.util.Iterator;
import java.util.List;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.common.bean.CommonConfig;
import com.common.bean.DataMap;
import com.common.dao.CommonDAO;
import com.common.util.Util;
import com.common.bean.DataMap;

@Service
public class InboundService {

	private static Logger log = Logger.getLogger(InboundService.class);
	
	@Autowired
	private Util util;
	
	@Autowired
	public CommonDAO commonDao;
	
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
	
	@Transactional
	public DataMap saveAs01(DataMap map) throws SQLException {
		List<DataMap> head = map.getList("head");
		List<DataMap> selectList = new ArrayList<DataMap>();
		if( map.get("list") != null && !map.get("list").equals("")){
			selectList = map.getList("list");
		}
		String headSebeln = map.get("headSebeln").toString();
		
		int count = 0;
		int itemCount = 0;
		
		DataMap row;
		DataMap itemRow;
		
		List docNumList = new ArrayList();
		DataMap rsMap = new DataMap();
		
		for(int i = 0 ; i < head.size() ; i ++){
			if(head.get(i).getMap("map").getString("SEBELN").equals(headSebeln)){
				
				row = head.get(i).getMap("map");
				String docNum = wmsService.getDocSeq("051");
				docNumList.add(docNum);
				
				row.put("ASNDKY", docNum);
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				row.setModuleCommand("WmsInbound", "AS01T");	//INSERT INTO ASNDH
				
				commonDao.update(row);
								
				for(int k = 0 ; k < selectList.size() ; k ++){
					itemRow = selectList.get(k).getMap("map");
					itemRow.put("ASNDKY", docNum);
					itemRow.put("C00101", itemRow.getString("LOTA10")); 
					itemRow.setModuleCommand("WmsInbound", "AS01Sub2");		//INSERT INTO ASNDI
					itemCount += 10;
					String snum = String.valueOf(itemCount);
					String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
					
					itemRow.put("ASNDIT", inum);
					
					commonDao.update(itemRow);
				}
				itemCount = 0;
			}else{
				row = head.get(i).getMap("map");
				map.clonSessionData(row);
				
				String docNum = wmsService.getDocSeq("051");
				docNumList.add(docNum);
				
				row.put("ASNDKY", docNum);
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				row.setModuleCommand("WmsInbound", "AS01T");		//INSERT INTO ASNDH
				commonDao.update(row);

				row.setModuleCommand("WmsInbound", "AS01Sub");
				List<DataMap> list = commonDao.getList(row); 
				
				for(int j = 0 ; j < list.size() ; j ++){
					itemRow = list.get(j);
					itemCount += 10;
					String snum = String.valueOf(itemCount);
					String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;

					itemRow.put("ASNDKY", docNum);
					itemRow.put("ASNDIT", inum);
					itemRow.setModuleCommand("WmsInbound", "AS01Sub2");		//INSERT INTO ASNDI
					commonDao.update(itemRow);
					
				}
				itemCount = 0;
			}

			StringBuilder sb = new StringBuilder();
			for(int k = 0 ; k < docNumList.size() ; k ++){
				if(k != 0){
					sb.append(",");
				}
				sb.append("'").append(docNumList.get(k)).append("'");
			}
			rsMap.put("ASNDKY", sb.toString());
		}
		return rsMap;
	}
	
	@Transactional
	public int deleteAs02(DataMap map) throws SQLException {
		List<DataMap> head = map.getList("head");
		
		int count = 0;
		
		DataMap row;
		DataMap itRow = null;
		
		for(int i = 0 ; i < head.size() ; i ++){
				row = head.get(i).getMap("map");
				row.setModuleCommand("WmsInbound", "AS02Sub");
				List<DataMap> list = commonDao.getList(row); 
				for(int k =0; k < list.size(); k++){
					itRow = new DataMap(list.get(k));
					itRow.setModuleCommand("WmsInbound", "AS02Sub");
					itRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
					commonDao.delete(itRow);
				}
				
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				row.setModuleCommand("WmsInbound", "AS02");
				commonDao.delete(row);
				
			count++;
		}
		return count;
	
	}
	
	@Transactional
	public DataMap saveGr02(DataMap map) throws SQLException {
		List<DataMap> head = map.getList("head");
		List<DataMap> selectList = new ArrayList<DataMap>();
		if( map.get("list") != null && !map.get("list").equals("")){
			selectList = map.getList("list");
		}
		String headSebeln = map.get("headSebeln").toString();
		
		int count = 0;
		int itemCount = 0;
		
		DataMap row;
		DataMap itemRow;
		
		List docNumList = new ArrayList();
		DataMap rsMap = new DataMap();
		
		for(int i = 0 ; i < head.size() ; i ++){
			if(head.get(i).getMap("map").getString("SEBELN").equals(headSebeln)){
				
				row = head.get(i).getMap("map");
				String docNum = wmsService.getDocSeq("102");
				docNumList.add(docNum);
				
				row.put("RECVKY", docNum);
				row.setModuleCommand("WmsInbound", "RECDH");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				
				commonDao.update(row);
				
				for(int k = 0 ; k < selectList.size() ; k ++){
					itemRow = selectList.get(k).getMap("map");
					itemRow.put("RECVKY", docNum);
					itemRow.setModuleCommand("WmsInbound", "RECDI");
					itemRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
					itemRow.put("LOTA12",row.get("DOCDAT"));
					
					itemCount += 10;
					String snum = String.valueOf(itemCount);
					String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
					
					itemRow.put("RECVIT", inum);
					
					count += commonDao.update(itemRow);
				}
				itemCount = 0;
			}else{
				row = head.get(i).getMap("map");
				map.clonSessionData(row);
				
				String docNum = wmsService.getDocSeq("102");
				docNumList.add(docNum);
				
				row.put("RECVKY", docNum);
				row.setModuleCommand("WmsInbound", "RECDH");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				
				commonDao.update(row);

				row.setModuleCommand("WmsInbound", "GR02Sub");
				
				List<DataMap> list = commonDao.getList(row); 
				
				for(int j = 0 ; j < list.size() ; j ++){
					itemRow = list.get(j);
					itemRow.put("RECVKY", docNum);
					itemRow.setModuleCommand("WmsInbound", "RECDI");
					itemRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
					
					itemCount += 10;
					String snum = String.valueOf(itemCount);
					String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
					
					itemRow.put("RECVIT", inum);
					commonDao.update(itemRow);
				}
				itemCount = 0;
			}
			//102일때IFWMS203호출
			
			/*if("101".equals(row.getString("RCPTTY")) || "102".equals(row.getString("RCPTTY")) 
					|| "103".equals(row.getString("RCPTTY")) || "104".equals(row.getString("RCPTTY"))
					|| "105".equals(row.getString("RCPTTY"))){*/
			row.setModuleCommand("WmsInbound", "IFWMS203");
			commonDao.getMap(row);
			
			StringBuilder sb = new StringBuilder();
			for(int k = 0 ; k < docNumList.size() ; k ++){
				if(k != 0){
					sb.append(",");
				}
				sb.append("'").append(docNumList.get(k)).append("'");
			}
			rsMap.put("RECVKY", sb.toString());
		}
		return rsMap;
	}
	
	@Transactional
	public DataMap saveGr14(DataMap map) throws SQLException {
		List<DataMap> head = map.getList("head");
		List<DataMap> selectList = new ArrayList<DataMap>();
		if( map.get("list") != null && !map.get("list").equals("")){
			selectList = map.getList("list");
		}
		String headSebeln = map.get("headSebeln").toString();
		
		int count = 0;
		int itemCount = 0;
		
		DataMap row;
		DataMap itemRow;
		
		List docNumList = new ArrayList();
		DataMap rsMap = new DataMap();
		
		for(int i = 0 ; i < head.size() ; i ++){
			if(head.get(i).getMap("map").getString("SEBELN").equals(headSebeln)){
				
				row = head.get(i).getMap("map");
				String docNum = wmsService.getDocSeq("111");
				docNumList.add(docNum);
				
				row.put("RECVKY", docNum);
				row.setModuleCommand("WmsInbound", "RECDH");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				
				commonDao.update(row);
				
				for(int k = 0 ; k < selectList.size() ; k ++){
					itemRow = selectList.get(k).getMap("map");
					itemRow.put("RECVKY", docNum);
					itemRow.setModuleCommand("WmsInbound", "RECDI");
					itemRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
					
					itemCount += 10;
					String snum = String.valueOf(itemCount);
					String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
					
					itemRow.put("RECVIT", inum);
					
					count += commonDao.update(itemRow);
				}
				itemCount = 0;
			}else{
				row = head.get(i).getMap("map");
				map.clonSessionData(row);
				
				String docNum = wmsService.getDocSeq("111");
				docNumList.add(docNum);
				
				row.put("RECVKY", docNum);
				row.setModuleCommand("WmsInbound", "RECDH");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				
				commonDao.update(row);
				
				row.setModuleCommand("WmsInbound", "Gr14Sub");
				
				List<DataMap> list = commonDao.getList(row); 
				
				for(int j = 0 ; j < list.size() ; j ++){
					itemRow = list.get(j);
					itemRow.put("RECVKY", docNum);
					itemRow.setModuleCommand("WmsInbound", "RECDI");
					itemRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
					
					itemCount += 10;
					String snum = String.valueOf(itemCount);
					String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
					
					itemRow.put("RECVIT", inum);
					commonDao.update(itemRow);
				}
				itemCount = 0;
			}
			//102일때IFWMS203호출
			
			/*if("101".equals(row.getString("RCPTTY")) || "102".equals(row.getString("RCPTTY")) 
					|| "103".equals(row.getString("RCPTTY")) || "104".equals(row.getString("RCPTTY"))
					|| "105".equals(row.getString("RCPTTY"))){*/
			row.setModuleCommand("WmsInbound", "IFWMS301");
			commonDao.getMap(row);
			
			StringBuilder sb = new StringBuilder();
			for(int k = 0 ; k < docNumList.size() ; k ++){
				if(k != 0){
					sb.append(",");
				}
				sb.append("'").append(docNumList.get(k)).append("'");
			}
			rsMap.put("RECVKY", sb.toString());
		}
		return rsMap;
	}
	
	/*@Transactional
	public String saveGr01(DataMap map) throws Exception {
		
		DataMap head = map.getMap("head");
		List<DataMap> list = map.getList("list");
		
		// Validation
		StringBuffer sb = new StringBuffer();
		for(DataMap item : list){
			if(sb.length() > 0)
				sb.append(" UNION ALL\n ");
			
			sb.append(" SELECT '").append(head.get("SEBELN")).append("' AS SEBELN, ");
			sb.append("        '").append(item.getMap("map").get("SEBELP")).append("' AS SEBELP, ");
			sb.append("        '").append(head.get("DOCUTY")).append("' AS RCPTTY, ");
			sb.append("        '").append(head.get("WAREKY")).append("' AS WAREKY, ");
			sb.append("        '").append(head.get("OWNRKY")).append("' AS OWNRKY, ");
			sb.append("        '").append(head.get("DPTNKY")).append("' AS DPTNKY, ");
			sb.append("        '").append(item.getMap("map").get("LOCAKY")).append("' AS LOCAKY, ");
			sb.append("        '").append(item.getMap("map").get("SKUKEY")).append("' AS SKUKEY, ");
			sb.append("         ").append(item.getMap("map").get("QTYRCV")).append("  AS QTYRCV, ");
			sb.append("        '").append(item.getMap("map").get("UOMKEY")).append("' AS UOMKEY FROM DUAL ");
		}
		
		map.setModuleCommand("WmsInbound", "GOODS_RECEIPT"); // 쿼리키값 넣을것
		map.put("APPEND_QUERY", sb.toString());
		map.put("RCPTTY", head.get("DOCUTY"));
		List<DataMap> validList = commonDao.getValidation(map);
		if(validList.size() > 0){
			DataMap valid = validList.get(0);
			return valid.getString("RESULTMSG");
		}
		
		String docNum = wmsService.getDocSeq(head.getString("RCPTTY"));
		
		head.put("RECVKY", docNum);
		head.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		head.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
		head.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
		commonDao.insert("WmsInbound.GR01", head);
		
		DataMap row;
		
		int itemCount = 0;
		for(int i=0;i<list.size();i++){
			row  = list.get(i).getMap("map");
			
			itemCount += 10;
			String snum = String.valueOf(itemCount);
			String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
			
			row.put("RECVKY", docNum);
			row.put("RECVIT", inum);
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			row.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
			row.put("AREAKY", head.get("AREAKY"));
			row.put("ASNDAT", head.get("ASNDAT"));
			row.put("LOTA12", head.get("DOCDAT"));
			
			
			commonDao.insert("WmsInbound.GR01Sub", row);
		}
		head.put("DOCUKY", docNum);
		//commonDao.getMap("WmsInbound.GR_AIRWMS_DOCUMENT_PROCESS", head);
		//commonDao.getMap("WmsInbound.GR01PROCALL", head);
		
		return docNum;
	}*/
	
	/*@Transactional
	public DataMap saveGr00(DataMap map) throws Exception {
		List<DataMap> head = map.getList("head");
		List<DataMap> selectList = new ArrayList<DataMap>();
		String headSebeln = map.get("headSebeln").toString();
		
		DataMap rsMap2 = new DataMap();
		
		if( map.get("list") != null && !map.get("list").equals("")){
			int headRownum = Integer.parseInt(map.get("headRownum").toString());
			selectList = map.getList("list");
			
			// Validation
			StringBuffer sb = new StringBuffer();
			for(DataMap item : selectList){
				if(sb.length() > 0)
					sb.append(" UNION ALL\n ");
				
				sb.append(" SELECT '").append(head.get(headRownum).getMap("map").get("SEBELN")).append("' AS SEBELN, ");
				sb.append("        '").append(item.getMap("map").get("SEBELP")).append("' AS SEBELP, ");
				sb.append("        '").append(head.get(headRownum).getMap("map").get("RCPTTY")).append("' AS RCPTTY, ");
				sb.append("        '").append(head.get(headRownum).getMap("map").get("WAREKY")).append("' AS WAREKY, ");
				sb.append("        '").append(head.get(headRownum).getMap("map").get("OWNRKY")).append("' AS OWNRKY, ");
				sb.append("        '").append(head.get(headRownum).getMap("map").get("DPTNKY")).append("' AS DPTNKY, ");
				sb.append("        '").append(item.getMap("map").get("LOCAKY")).append("' AS LOCAKY, ");
				sb.append("        '").append(item.getMap("map").get("SKUKEY")).append("' AS SKUKEY, ");
				sb.append("         ").append(item.getMap("map").get("QTYRCV")).append("  AS QTYRCV, ");
				sb.append("        '").append(item.getMap("map").get("UOMKEY")).append("' AS UOMKEY FROM DUAL ");
			}
			
			map.setModuleCommand("WmsInbound", "GOODS_RECEIPT"); // 쿼리키값 넣을것
			map.put("APPEND_QUERY", sb.toString());
			map.put("RCPTTY", head.get(headRownum).getMap("map").get("RCPTTY"));
			List<DataMap> validList = commonDao.getValidation(map);
			if(validList.size() > 0){
				DataMap valid = validList.get(0);
				//rsMap.put("RECVKY", sb.toString());
				rsMap2.put("RESULTMSG",valid.toString());
				return rsMap2;
			}	
		}
			
		int count = 0;
		int itemCount = 0;
		
		DataMap row;
		DataMap itemRow;
		
		List docNumList = new ArrayList();
		DataMap rsMap = new DataMap();
		
		for(int i = 0 ; i < head.size() ; i ++){
			if(head.get(i).getMap("map").getString("SEBELN").equals(headSebeln)){
				
				row = head.get(i).getMap("map");
				String docNum = wmsService.getDocSeq("112");
				docNumList.add(docNum);
				
				row.put("RECVKY", docNum);
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				row.setModuleCommand("WmsInbound", "GR01");
				
				commonDao.insert(row);
								
				for(int k = 0 ; k < selectList.size() ; k ++){
					itemRow = selectList.get(k).getMap("map");
					itemRow.put("RECVKY", docNum);
					itemRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
					itemRow.setModuleCommand("WmsInbound", "GR01Sub");
					
					itemCount += 10;
					String snum = String.valueOf(itemCount);
					String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
					
					itemRow.put("RECVIT", inum);
					itemRow.put("AREAKY", head.get(i).getMap("map").getString("AREAKY"));
					itemRow.put("ASNDAT", head.get(i).getMap("map").getString("ASNDAT"));
	
					commonDao.insert(itemRow);
				}
				itemCount = 0;
			}else{
				row = head.get(i).getMap("map");
				map.clonSessionData(row);
				
				String docNum = wmsService.getDocSeq("112");
				docNumList.add(docNum);
				
				row.put("RECVKY", docNum);
				row.setModuleCommand("WmsInbound", "GR01");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				
				commonDao.insert(row);

				row.setModuleCommand("WmsInbound", "GR00Sub");
				
				List<DataMap> list = commonDao.getList(row); 
				
				for(int j = 0 ; j < list.size() ; j ++){
					itemRow = list.get(j);
					itemRow.put("RECVKY", docNum);
					itemRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
					itemRow.setModuleCommand("WmsInbound", "GR01Sub");
					
					itemCount += 10;
					String snum = String.valueOf(itemCount);
					String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
					
					itemRow.put("RECVIT", inum);
					itemRow.put("AREAKY", head.get(i).getMap("map").getString("AREAKY"));
					itemRow.put("ASNDAT", head.get(i).getMap("map").getString("ASNDAT"));
					commonDao.insert(itemRow);
				}
				itemCount = 0;
		}
		
		StringBuilder sb = new StringBuilder();
		for(int k = 0 ; k < docNumList.size() ; k ++){
			if(k != 0){
				sb.append(",");
			}
			sb.append("'").append(docNumList.get(k)).append("'");
		}
		rsMap.put("RECVKY", sb.toString());
		}
		return rsMap;
	}*/
	
	@Transactional
	public DataMap saveGr00(DataMap map) throws Exception {
		List<DataMap> head = map.getList("head");
		List<DataMap> itemList = map.getList("list");
		List<DataMap> selectList = new ArrayList<DataMap>();
		String headAsndky = map.get("headAsndky").toString();
		
		if(headAsndky.equals(itemList.get(0).getMap("map").getString("ASNDKY"))){
			selectList = itemList;
		} 
		
		int count = 0;
		int itemCount = 0;
		
		DataMap row;
		DataMap itemRow;
		
		List docNumList = new ArrayList();
		DataMap rsMap = new DataMap();
		
		
		for(int i = 0 ; i < head.size() ; i ++){
			if(head.get(i).getMap("map").getString("ASNDKY").equals(headAsndky)){
				
				//validation
				if(selectList.size() > 0){
					// Validation
					StringBuffer sb = new StringBuffer();
					for(DataMap item : selectList){
						if(sb.length() > 0) 
							sb.append(" UNION ALL\n ");
						
						sb.append(" SELECT '").append(head.get(i).getMap("map").get("SEBELN")).append("' AS SEBELN, ");
						sb.append("        '").append(item.getMap("map").get("SEBELP")).append("' AS SEBELP, ");
						sb.append("        '").append(head.get(i).getMap("map").get("DOCUTY")).append("' AS RCPTTY, ");
						sb.append("        '").append(head.get(i).getMap("map").get("WAREKY")).append("' AS WAREKY, ");
						sb.append("        '").append(head.get(i).getMap("map").get("OWNRKY")).append("' AS OWNRKY, ");
						sb.append("        '").append(head.get(i).getMap("map").get("DPTNKY")).append("' AS DPTNKY, ");
						sb.append("        '").append(item.getMap("map").get("LOCAKY")).append("' AS LOCAKY, ");
						sb.append("        '").append(item.getMap("map").get("SKUKEY")).append("' AS SKUKEY, ");
						sb.append("         ").append(item.getMap("map").get("QTYRCV")).append("  AS QTYRCV, ");
						sb.append("        '").append(item.getMap("map").get("UOMKEY")).append("' AS UOMKEY FROM DUAL ");
					}
					
					map.setModuleCommand("WmsInbound", "GOODS_RECEIPT"); // 쿼리키값 넣을것
					map.put("APPEND_QUERY", sb.toString());
					map.put("RCPTTY", head.get(i).getMap("map").get("DOCUTY"));
					List<DataMap> validList = commonDao.getValidation(map);
					if(validList.size() > 0){
						DataMap valid = validList.get(0);
						
						return valid;
					}
				}

				row = head.get(i).getMap("map");
				String docNum = wmsService.getDocSeq("112");
				docNumList.add(docNum);
				
				row.put("RECVKY", docNum);
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				row.setModuleCommand("WmsInbound", "GR01");
				
				commonDao.insert(row);
								
				for(int k = 0 ; k < selectList.size() ; k ++){
					itemRow = selectList.get(k).getMap("map");
					itemRow.put("RECVKY", docNum);
					itemRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
					itemRow.setModuleCommand("WmsInbound", "GR01Sub");
					
					itemCount += 10;
					String snum = String.valueOf(itemCount);
					String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
					
					itemRow.put("RECVIT", inum);
					itemRow.put("AREAKY", head.get(i).getMap("map").getString("AREAKY"));
					itemRow.put("ASNDAT", head.get(i).getMap("map").getString("ASNDAT"));
	
					commonDao.insert(itemRow);
				}
				itemCount = 0;
			}else{
				row = head.get(i).getMap("map");
				map.clonSessionData(row);
				
				String docNum = wmsService.getDocSeq("112");
				docNumList.add(docNum);
				
				row.put("RECVKY", docNum);
				row.setModuleCommand("WmsInbound", "GR01");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				
				commonDao.insert(row);

				row.setModuleCommand("WmsInbound", "GR00Sub");
				
				List<DataMap> list = commonDao.getList(row); 
				
				for(int j = 0 ; j < list.size() ; j ++){
					itemRow = list.get(j);
					itemRow.put("RECVKY", docNum);
					itemRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
					itemRow.setModuleCommand("WmsInbound", "GR01Sub");
					
					itemCount += 10;
					String snum = String.valueOf(itemCount);
					String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
					
					itemRow.put("RECVIT", inum);
					itemRow.put("AREAKY", head.get(i).getMap("map").getString("AREAKY"));
					itemRow.put("ASNDAT", head.get(i).getMap("map").getString("ASNDAT"));
					commonDao.insert(itemRow);
				}
				itemCount = 0;
		}
		
		StringBuilder sb = new StringBuilder();
		for(int k = 0 ; k < docNumList.size() ; k ++){
			if(k != 0){
				sb.append(",");
			}
			sb.append("'").append(docNumList.get(k)).append("'");
		}
		rsMap.put("RECVKY", sb.toString());
		}
		return rsMap;
	}
	
	@Transactional
	public DataMap saveGr01(DataMap map) throws Exception {
		List<DataMap> head = map.getList("head");
		List<DataMap> itemList = map.getList("list");
		List<DataMap> selectList = new ArrayList<DataMap>();
		String headSebeln = map.get("headSebeln").toString();
			
		int count = 0;
		int itemCount = 0;
		
		DataMap row;
		DataMap itemRow;
		
		List docNumList = new ArrayList();
		DataMap rsMap = new DataMap();
		
		for(int i = 0 ; i < head.size() ; i ++){
			if(head.get(i).getMap("map").getString("SEBELN").equals(headSebeln)){
				
				//validation
				if(headSebeln.equals(itemList.get(0).getMap("map").getString("SEBELN"))){
					selectList = itemList;
				} 
				
				if(selectList.size() > 0){
					// Validation
					StringBuffer sb = new StringBuffer();
					for(DataMap item : selectList){
						if(sb.length() > 0) 
							sb.append(" UNION ALL\n ");
						
						sb.append(" SELECT '").append(head.get(i).getMap("map").get("SEBELN")).append("' AS SEBELN, ");
						sb.append("        '").append(item.getMap("map").get("SEBELP")).append("' AS SEBELP, ");
						sb.append("        '").append(head.get(i).getMap("map").get("DOCUTY")).append("' AS RCPTTY, ");
						sb.append("        '").append(head.get(i).getMap("map").get("WAREKY")).append("' AS WAREKY, ");
						sb.append("        '").append(head.get(i).getMap("map").get("OWNRKY")).append("' AS OWNRKY, ");
						sb.append("        '").append(head.get(i).getMap("map").get("DPTNKY")).append("' AS DPTNKY, ");
						sb.append("        '").append(item.getMap("map").get("LOCAKY")).append("' AS LOCAKY, ");
						sb.append("        '").append(item.getMap("map").get("SKUKEY")).append("' AS SKUKEY, ");
						sb.append("         ").append(item.getMap("map").get("QTYRCV")).append("  AS QTYRCV, ");
						sb.append("        '").append(item.getMap("map").get("UOMKEY")).append("' AS UOMKEY FROM DUAL ");
					}
					
					map.setModuleCommand("WmsInbound", "GOODS_RECEIPT"); // 쿼리키값 넣을것
					map.put("APPEND_QUERY", sb.toString());
					map.put("RCPTTY", head.get(i).getMap("map").get("DOCUTY"));
					List<DataMap> validList = commonDao.getValidation(map);
					if(validList.size() > 0){
						DataMap valid = validList.get(0);
						
						return valid;
					}
				}// validation 끝

				row = head.get(i).getMap("map");
				String docNum = wmsService.getDocSeq("101");
//				String docNum = wmsService.getDocSeq("166");
				docNumList.add(docNum);
				
				row.put("RECVKY", docNum);
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				row.setModuleCommand("WmsInbound", "GR01");
				
				commonDao.insert(row);
								
				for(int k = 0 ; k < selectList.size() ; k ++){
					itemRow = selectList.get(k).getMap("map");
					itemRow.put("RECVKY", docNum);
					itemRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
					itemRow.setModuleCommand("WmsInbound", "GR01Sub");
					
					itemCount += 10;
					String snum = String.valueOf(itemCount);
					String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
					
					itemRow.put("RECVIT", inum);
					itemRow.put("AREAKY", head.get(i).getMap("map").getString("AREAKY"));
					itemRow.put("ASNDAT", head.get(i).getMap("map").getString("ASNDAT"));
	
					commonDao.insert(itemRow);
				}
				itemCount = 0;
			}else{
				row = head.get(i).getMap("map");
				map.clonSessionData(row);
				
				String docNum = wmsService.getDocSeq("102");
				docNumList.add(docNum);
				
				row.put("RECVKY", docNum);
				row.setModuleCommand("WmsInbound", "GR01");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				
				commonDao.insert(row);

				row.setModuleCommand("WmsInbound", "GR01Sub");
				
				List<DataMap> list = commonDao.getList(row); 
				
				for(int j = 0 ; j < list.size() ; j ++){
					itemRow = list.get(j);
					itemRow.put("RECVKY", docNum);
					itemRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
					itemRow.setModuleCommand("WmsInbound", "GR01Sub");
					
					itemCount += 10;
					String snum = String.valueOf(itemCount);
					String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
					
					itemRow.put("RECVIT", inum);
					itemRow.put("AREAKY", head.get(i).getMap("map").getString("AREAKY"));
					itemRow.put("ASNDAT", head.get(i).getMap("map").getString("ASNDAT"));
					commonDao.insert(itemRow);
				}
				itemCount = 0;
		}
		
		StringBuilder sb = new StringBuilder();
		for(int k = 0 ; k < docNumList.size() ; k ++){
			if(k != 0){
				sb.append(",");
			}
			sb.append("'").append(docNumList.get(k)).append("'");
		}
		rsMap.put("RECVKY", sb.toString());
		}
		return rsMap;
	}

	/*
	@Transactional
	public DataMap saveGr01(DataMap map) throws SQLException {
		List<DataMap> chkHeadList = map.getList("chkHeadList");
		List docNumList = new ArrayList();
		DataMap rsMap = new DataMap();
		
		DataMap row;
		for(int i = 0 ; i < chkHeadList.size() ; i ++){
			row = chkHeadList.get(i).getMap("map");
			row.setModuleCommand("WmsInbound", "GR01PRO");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			
			DataMap procSubMap;
			
			try {
				procSubMap = commonDao.getMap(row);
				docNumList.add(procSubMap.getString("V_ERRMSG"));
				StringBuilder sb = new StringBuilder();
				for(int k = 0 ; k < docNumList.size() ; k ++){
					if(k != 0){
						sb.append(",");
					}
					sb.append("'").append(docNumList.get(k)).append("'");
				}
				rsMap.put("RECVKY", sb.toString());
			} catch (Exception e) {
				e.printStackTrace();
				String errmsg = e.getMessage();
				rsMap.put("V_ERRNUM", 0);
				rsMap.put("V_ERRMSG", errmsg);
			}
		}
		return rsMap;
	}
	*/
	
	@Transactional
	public DataMap saveGr01_bak(DataMap map) throws SQLException {
		List<DataMap> head = map.getList("head");
		List<DataMap> selectList = new ArrayList<DataMap>();
		if( map.get("list") != null && !map.get("list").equals("")){
			selectList = map.getList("list");
		}
		String headAsndky = map.get("headAsndky").toString();
		
		int count = 0;
		int itemCount = 0;
		
		DataMap row;
		DataMap itemRow;
		
		List docNumList = new ArrayList();
		DataMap rsMap = new DataMap();
		
		for(int i = 0 ; i < head.size() ; i ++){
			if(head.get(i).getMap("map").getString("ASNDKY").equals(headAsndky)){
				
				row = head.get(i).getMap("map");
				String docNum = wmsService.getDocSeq("112");
				docNumList.add(docNum);
				
				row.put("RECVKY", docNum);
				row.setModuleCommand("WmsInbound", "RECDH");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				
				commonDao.update(row);
				
				for(int k = 0 ; k < selectList.size() ; k ++){
					itemRow = selectList.get(k).getMap("map");
					itemRow.put("RECVKY", row.get("RECVKY"));
					itemRow.setModuleCommand("WmsInbound", "RECDI");
					
					itemCount += 10;
					String snum = String.valueOf(itemCount);
					String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
					
					itemRow.put("RECVIT", inum);
					
					count += commonDao.update(itemRow);
				}
				itemCount = 0;
			}else{
				row = head.get(i).getMap("map");
				map.clonSessionData(row);
				
				String docNum = wmsService.getDocSeq("112");
				docNumList.add(docNum);
				
				row.put("RECVKY", docNum);
				row.setModuleCommand("WmsInbound", "RECDH");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				
				commonDao.update(row);

				row.setModuleCommand("WmsInbound", "GR01Sub");
				
				List<DataMap> list = commonDao.getList(row); 
				
				for(int j = 0 ; j < list.size() ; j ++){
					itemRow = list.get(j);
					itemRow.put("RECVKY", docNum);
					itemRow.setModuleCommand("WmsInbound", "RECDI");
					
					itemCount += 10;
					String snum = String.valueOf(itemCount);
					String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
					
					itemRow.put("RECVIT", inum);
					commonDao.update(itemRow);
				}
				itemCount = 0;
			}
			
			StringBuilder sb = new StringBuilder();
			for(int k = 0 ; k < docNumList.size() ; k ++){
				if(k != 0){
					sb.append(",");
				}
				sb.append("'").append(docNumList.get(k)).append("'");
			}
			rsMap.put("RECVKY", sb.toString());
		}
		return rsMap;
	}
	
	@Transactional
	public DataMap saveGr05(DataMap map) throws SQLException {
		List<DataMap> head = map.getList("head");
		List<DataMap> selectList = new ArrayList<DataMap>();
		if( map.get("list") != null && !map.get("list").equals("")){
			selectList = map.getList("list");
		}
		String headSebeln = map.get("headSebeln").toString();
		String rcptty = map.get("rcptty").toString();
		int count = 0;
		int itemCount = 0;
		
		DataMap row;
		DataMap itemRow;
		
		List docNumList = new ArrayList();
		DataMap rsMap = new DataMap();
		
		
		for(int i = 0 ; i < head.size() ; i ++){
			if(head.get(i).getMap("map").getString("SEBELN").equals(headSebeln)){
				
				row = head.get(i).getMap("map");
				String docNum = wmsService.getDocSeq(rcptty);
				docNumList.add(docNum);
				
				row.put("RECVKY", docNum);
				row.setModuleCommand("WmsInbound", "RECDH");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				
				commonDao.update(row);
				
				for(int k = 0 ; k < selectList.size() ; k ++){
					itemRow = selectList.get(k).getMap("map");
					itemRow.put("RECVKY", docNum);
					itemRow.setModuleCommand("WmsInbound", "RECDI");
					
					itemCount += 10;
					String snum = String.valueOf(itemCount);
					String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
					
					itemRow.put("RECVIT", inum);
					
					count += commonDao.update(itemRow);
				}
				itemCount = 0;
			}else{
				row = head.get(i).getMap("map");
				map.clonSessionData(row);
				
				String docNum = wmsService.getDocSeq(rcptty);
				docNumList.add(docNum);
				
				row.put("RECVKY", docNum);
				row.setModuleCommand("WmsInbound", "RECDH");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				
				commonDao.update(row);

				row.setModuleCommand("WmsInbound", "GR05Sub");
				
				List<DataMap> list = commonDao.getList(row); 
				
				for(int j = 0 ; j < list.size() ; j ++){
					itemRow = list.get(j);
					itemRow.put("RECVKY", docNum);
					itemRow.setModuleCommand("WmsInbound", "RECDI");
					
					itemCount += 10;
					String snum = String.valueOf(itemCount);
					String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
					
					itemRow.put("RECVIT", inum);
					commonDao.update(itemRow);
				}
				itemCount = 0;
			}
			
			StringBuilder sb = new StringBuilder();
			for(int k = 0 ; k < docNumList.size() ; k ++){
				if(k != 0){
					sb.append(",");
				}
				sb.append("'").append(docNumList.get(k)).append("'");
			}
			rsMap.put("RECVKY", sb.toString());
		}
		return rsMap;
	}
	
	@Transactional
	public DataMap saveGr06(DataMap map) throws SQLException {
		List<DataMap> head = map.getList("head");
		List<DataMap> selectList = new ArrayList<DataMap>();
		if( map.get("list") != null && !map.get("list").equals("")){
			selectList = map.getList("list");
		}
		String headShpoky = map.get("headShpoky").toString();
		
		int count = 0;
		int itemCount = 0;
		
		DataMap row;
		DataMap itemRow;
		
		List docNumList = new ArrayList();
		DataMap rsMap = new DataMap();
		
		for(int i = 0 ; i < head.size() ; i ++){
			if(head.get(i).getMap("map").getString("SHPOKY").equals(headShpoky)){
				
				row = head.get(i).getMap("map");
				String docNum = wmsService.getDocSeq("108");
				docNumList.add(docNum);
				
				row.put("RECVKY", docNum);
				row.setModuleCommand("WmsInbound", "RECDH");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				
				commonDao.update(row);
				
				for(int k = 0 ; k < selectList.size() ; k ++){
					itemRow = selectList.get(k).getMap("map");
					itemRow.put("RECVKY", docNum);
					itemRow.setModuleCommand("WmsInbound", "RECDI");
					
					itemCount += 10;
					String snum = String.valueOf(itemCount);
					String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
					
					itemRow.put("RECVIT", inum);
					
					count += commonDao.update(itemRow);
				}
				itemCount = 0;
			}else{
				row = head.get(i).getMap("map");
				map.clonSessionData(row);
				
				String docNum = wmsService.getDocSeq("108");
				docNumList.add(docNum);
				
				row.put("RECVKY", docNum);
				row.setModuleCommand("WmsInbound", "RECDH");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				
				commonDao.update(row);

				row.setModuleCommand("WmsInbound", "GR06Sub");
				
				List<DataMap> list = commonDao.getList(row); 
				
				for(int j = 0 ; j < list.size() ; j ++){
					itemRow = list.get(j);
					itemRow.put("RECVKY", docNum);
					itemRow.setModuleCommand("WmsInbound", "RECDI");
					
					itemCount += 10;
					String snum = String.valueOf(itemCount);
					String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
					
					itemRow.put("RECVIT", inum);
					commonDao.update(itemRow);
				}
				itemCount = 0;
			}
			
			StringBuilder sb = new StringBuilder();
			for(int k = 0 ; k < docNumList.size() ; k ++){
				if(k != 0){
					sb.append(",");
				}
				sb.append("'").append(docNumList.get(k)).append("'");
			}
			rsMap.put("RECVKY", sb.toString());
		}
		return rsMap;
	}
	
	/*@Transactional
	public DataMap saveGr15(DataMap map) throws SQLException {
		List<DataMap> head = map.getList("head");
		List<DataMap> selectList = new ArrayList<DataMap>();
		if( map.get("list") != null && !map.get("list").equals("")){
			selectList = map.getList("list");
		}
		String headShpoky = map.get("headShpoky").toString();
		
		int count = 0;
		int itemCount = 0;
		
		DataMap row;
		DataMap itemRow;
		
		List docNumList = new ArrayList();
		DataMap rsMap = new DataMap();
		
		for(int i = 0 ; i < head.size() ; i ++){
			if(head.get(i).getMap("map").getString("SHPOKY").equals(headShpoky)){
				
				row = head.get(i).getMap("map");
				String docNum = wmsService.getDocSeq("166");
				docNumList.add(docNum);
				
				row.put("RECVKY", docNum);
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				row.setModuleCommand("WmsInbound", "RECDH");
				
				commonDao.update(row);
				
				for(int k = 0 ; k < selectList.size() ; k ++){
					itemRow = selectList.get(k).getMap("map");
					itemRow.put("RECVKY", docNum);
					itemRow.setModuleCommand("WmsInbound", "RECDI");
					
					itemCount += 10;
					String snum = String.valueOf(itemCount);
					String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
					
					itemRow.put("RECVIT", inum);
					
					count += commonDao.update(itemRow);
				}
				itemCount = 0;
			}else{
				row = head.get(i).getMap("map");
				map.clonSessionData(row);
				
				String docNum = wmsService.getDocSeq("166");
				docNumList.add(docNum);
				
				row.setModuleCommand("WmsInbound", "RECDH");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				row.put("RECVKY", docNum);
				
				commonDao.update(row);

				row.setModuleCommand("WmsInbound", "GR15Sub");
				
				List<DataMap> list = commonDao.getList(row); 
				
				for(int j = 0 ; j < list.size() ; j ++){
					itemRow = list.get(j);
					itemRow.put("RECVKY", docNum);
					itemRow.setModuleCommand("WmsInbound", "RECDI");
					
					itemCount += 10;
					String snum = String.valueOf(itemCount);
					String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
					
					itemRow.put("RECVIT", inum);
					commonDao.update(itemRow);
				}
				itemCount = 0;
			}
			StringBuilder sb = new StringBuilder();
			for(int k = 0 ; k < docNumList.size() ; k ++){
				if(k != 0){
					sb.append(",");
				}
				sb.append("'").append(docNumList.get(k)).append("'");
			}
			rsMap.put("RECVKY", sb.toString());
		}
		return rsMap;
	}*/
	
	@Transactional
	public int deleteGr10(DataMap map) throws SQLException {
		List<DataMap> head = map.getList("head");
		
		int count = 0;
		
		DataMap row;
		DataMap itRow = null;
		
		for(int i = 0 ; i < head.size() ; i ++){
				row = head.get(i).getMap("map");
				row.setModuleCommand("WmsInbound", "GR10Sub");
				List<DataMap> list = commonDao.getList(row); 
				for(int k = 0; k < list.size(); k ++){
					itRow = new DataMap(list.get(k));
					itRow.setModuleCommand("WmsInbound", "GR10Sub");
					itRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
					commonDao.update(itRow);
				}
				
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				row.setModuleCommand("WmsInbound", "GR10");
				commonDao.update(row);
				
			count++;
		}
		return count;
	
	}


	public Object saveGr01pop2(DataMap map)  throws SQLException {
		List<DataMap> list = map.getList("list");
		DataMap row = list.get(0).getMap("map");
	
		
		String TMPNUM = map.getString("TMPNUM");
		String ASNDKY = map.getString("ASNDKY");
		String ASNDIT = map.getString("ASNDIT");
		String SKUKEY = map.getString("SKUKEY");
		//String desc01 = map.getString("DESC01");		
		
		row.setModuleCommand("WmsInbound", "RCFAIL");
		commonDao.delete(row);
		
		for(int i=0; i<list.size(); i++){
			row = list.get(i).getMap("map");
			row.put("ASNDKY", ASNDKY);
			row.put("ASNDIT", ASNDIT);
			row.put("CREUSR", map.get(CommonConfig.SES_USER_ID_KEY));
			row.put("LMOUSR", map.get(CommonConfig.SES_USER_ID_KEY));
			row.setModuleCommand("WmsInbound", "RCFAIL");
			String rowState = row.getString(CommonConfig.GRID_ROW_STATE_ATT);
			switch(rowState.charAt(0)){
				case 'C' :
				case 'R' :
				case 'U' :
					commonDao.insert(row);
					break;
				case 'D':
					commonDao.delete(row);
					break;
			}
		}
		
		DataMap returnMap = new DataMap();
		map.setModuleCommand("WmsInbound", "GR01POP2");
		List dataList = commonDao.getList(map);
		returnMap.put("data", dataList);
		
		return list;
	}
	
	public Object reflectGr01Item(DataMap map) throws SQLException {
		List<DataMap> selectList = new ArrayList<DataMap>();
		DataMap returnMap = new DataMap();
		String asndky =" ";
		
		if( map.get("list") != null && !map.get("list").equals("")){
			selectList = map.getList("list");
		}
		
		DataMap row;
		
		for(int i = 0 ; i < selectList.size() ; i++){
			row = selectList.get(i).getMap("map");
			if(row.get("LOCAKY").equals("")){
				row.put("LOCAKY"," ");
			}
			row.put("LMOUSR" ,map.get(CommonConfig.SES_USER_ID_KEY) );
			
			row.setModuleCommand("WmsInbound", "ASNDI");
			
			commonDao.update(row);
		}
		
		
		asndky = selectList.get(0).getMap("map").get("ASNDKY").toString();
		
		//map.setModuleCommand("WmsInbound", "GR01Sub");
		//map.put("ASNDKY", asndky);
		//List dataList = commonDao.getList(map);
		returnMap.put("ASNDKY", asndky);
		
		return returnMap;
		
	}


	
	@Transactional
	public String saveGr20(DataMap map) throws SQLException {
		DataMap head = map.getMap("head").getMap("map");
		List<DataMap> list = map.getList("list");
		int count = 0;
		
		String docNum = wmsService.getDocSeq((String)head.get("DOCUTY"));
		head.put("RECVKY", docNum);
		
		head.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		head.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
		head.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
		
		commonDao.update("WmsInbound.GR20RECDH", head);
		
		int itemCount = 0;
		DataMap row;
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			itemCount += 10;
			String snum = String.valueOf(itemCount);
			String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
			
			row.put("RECVKY", docNum);
			row.put("RECVIT", inum);
			row.put("LOTA12", head.get("DOCDAT"));
			row.put("DOCDAT", head.get("DOCDAT"));
			row.put("OWNRKY", head.get("OWNRKY"));
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			
			commonDao.insert("WmsInbound.GR20RECDI", row);
		}
		
		commonDao.getMap("WmsInbound.GR_AIRWMS_DOCUMENT_PROCESS", head);
		commonDao.getMap("WmsInbound.GR01PROCALL", head);
		
		return docNum;
	}
	
	@Transactional
	public String saveGr03(DataMap map) throws SQLException {
		DataMap head = map.getMap("head").getMap("map");
		List<DataMap> list = map.getList("list");
		int count = 0;
		
		String docNum = wmsService.getDocSeq("100");
		head.put("RECVKY", docNum);
		
		head.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		head.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
		head.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
		
		commonDao.update("WmsInbound.GR20RECDH", head);
		
		int itemCount = 0;
		DataMap row;
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			itemCount += 10;
			String snum = String.valueOf(itemCount);
			String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
			
			row.put("RECVKY", docNum);
			row.put("RECVIT", inum);
			row.put("AREAKY", head.get("AREAKY"));
			row.put("LOTA12", head.get("DOCDAT"));
			row.put("DOCDAT", head.get("DOCDAT"));
			
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			
			commonDao.insert("WmsInbound.GR03RECDI", row);
		}
		commonDao.getMap("WmsInbound.GR01PROCALL", head);
		
		return docNum;
	}
	
	@Transactional
	public int saveGr15(DataMap map) throws SQLException {
		DataMap head = map.getMap("head").getMap("map");
		List<DataMap> list = map.getList("list");
		int count = 0;
		
		head.setModuleCommand("WmsInbound", "GR15RECDH");
		head.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		head.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
		head.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
		
		count += commonDao.update(head);		
		
		/*head.setModuleCommand("WmsInbound", "GR15REFDKY");
		
		int refdky = (Integer)commonDao.getObject(head);*/
		
		int itemCount = 0;
		DataMap row;
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			row.put("WAREKY", head.getString("WAREKY"));
			row.put("RECVKY", head.get("RECVKY"));
			
			/*row.setModuleCommand("WmsInbound", "GR15BARCOD");
			
			row.put("REFDKY", refdky);
			
			String barcod = (String)commonDao.insert(row);
			
			row.put("LOTA03", barcod);*/
			
			itemCount += 10;
			String snum = String.valueOf(itemCount);
			String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
			
			row.put("RECVIT", inum);
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put("RECVKY", head.get("RECVKY"));
			
			row.setModuleCommand("WmsInbound", "GR15RECDI");
			
			commonDao.insert(row);
			
			count ++;
		}
		
		return count;
	}


	@Transactional
	public int SendSMS(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		DataMap row;
		int count = 0;
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.putAll(row);
			map.setModuleCommand("WmsInbound", "GR02SMS");
			commonDao.getMap(map);
			
			count ++;
		}
		return count;
	}
	
	@Transactional
	public int savePrtseq(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("head");
		int count = 0;
		
		DataMap row;
		for(int i=0;i<list.size();i++){
		    row = list.get(i).getMap("map");
			row.setModuleCommand("WmsInbound", "PRTLGRECV");		
			row.put("PRTSEQ", map.get("PRTSEQ"));	
			row.put("PRTTYP", map.get("PRTTYP"));
			
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			commonDao.insert(row);
			
			count ++;
		}
		
		return count;
	}
	

	@Transactional
	public int deleteGR09(DataMap map) throws SQLException {
		List<DataMap> head = map.getList("head");
		int count = 0;
		
		DataMap row = new DataMap();
		for(int i=0;i<head.size();i++){
			row = head.get(i).getMap("map");
			
			row.setModuleCommand("WmsInbound", "GR09DELETE");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			commonDao.update(row);
			
			row.setModuleCommand("WmsInbound", "GR09DELETEHEADER");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			commonDao.update(row);
			
			//P_AIRWMS_DOCUMENT_PROCESS 프로시져 호출
//			row.setModuleCommand("WmsInbound", "GR09DOCPROCALL");
//			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
//			commonDao.getMap(row);
//			
//			row.setModuleCommand("WmsInbound", "GR09PROCALL");
//			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
//			commonDao.getMap(row);
			count++;
		} 
		
		
		return count;
	}
	
	@Transactional
	public String validationGR09(DataMap map) throws SQLException {
		String result = "OK";
		List<DataMap> list = map.getList("list");
		
		String validationSql = "";
		String key = map.get("key").toString();
		if( map.containsKey("key") ){
			validationSql = util.urlCreateValidationSql(map, key);
			map.put(CommonConfig.VALIDATION_SQL_KEY, validationSql);
			map.setModuleCommand("WmsInbound", "GR09VAL");
						
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
	public List<DataMap> gr01HeadList(DataMap map) throws SQLException {
		map.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));

		map.setModuleCommand("WmsInbound", "GR01");
		List<DataMap> headList = commonDao.getList(map);

		return headList;

	}
	
	@Transactional
	public List<DataMap> gr01SubList(DataMap map) throws SQLException {
		map.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
       	
		map.setModuleCommand("WmsInbound", "GR01Sub");
		List<DataMap> itemList = commonDao.getList(map);
		
		//검수데이터
		/*if(itemList != null && (!itemList.isEmpty())) {
			for(int i=0; i<itemList.size(); i++) {
				DataMap itemMap = itemList.get(i);
				itemMap.setModuleCommand("WmsInbound", "GR01_RECDR");
				
				DataMap recdrMap = commonDao.getMap(itemMap);
				if(recdrMap != null && !recdrMap.isEmpty()) {
					Iterator<String> recdrKeys = recdrMap.keySet().iterator();
					while(recdrKeys.hasNext()) {
						String key = recdrKeys.next();
						itemMap.put(key, recdrMap.get(key));
					}
				}
			}
		}*/

		return itemList;

	}
	
	@Transactional
	public String getAsnPltBcd(DataMap map) throws SQLException {
		String result = "OK";
		List<DataMap> list = map.getList("list");
		
		String validationSql = "";
		String key = map.get("key").toString();
		if( map.containsKey("key") ){
			validationSql = util.urlCreateValidationSql(map, key);
			map.put(CommonConfig.VALIDATION_SQL_KEY, validationSql);
			map.setModuleCommand("WmsInbound", "GR09VAL");
						
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
	public String BARCDInsert(DataMap map) throws SQLException {
		List<DataMap> head = map.getList("head");
		List<DataMap> list = map.getList("list");
		DataMap row = new DataMap();
		DataMap itemrow = new DataMap();
		String result = "HHT_T0008";

		for(int h = 0 ; h < head.size() ; h ++){
			//해당 ASNDKY가 BARCD에 없으면 생성
			DataMap headrow = head.get(h).getMap("map");
			String HeadAsndky = headrow.getString("ASNDKY");

			row.put("ASNDKY", HeadAsndky);
			row.setModuleCommand("WmsInbound", "PltBcdChk");
			DataMap bcdChk = commonDao.getMap(row);

			if("0".equals(bcdChk.getString("CNT"))){
				
				row.setModuleCommand("WmsInbound", "ASNDIT");
				list = commonDao.getList(row);

				//ASNDIT만큼 for문 돌리기
				for(int i = 0; i < list.size(); i++) {
					row = list.get(i).getMap("map");

					String asndky = row.getString("ASNDKY");
					String asndit = row.getString("ASNDIT");
					//ASNDIT -> SKU -> 팔렛트 입수만큼 바코드 분할하는 쿼리
					row.setModuleCommand("WmsInbound", "PltCount");
					DataMap pltrow = commonDao.getMap(row);

					//분할된 팔렛트수만큼 for문 돌리기
					int itemCount = 0;	//ASNDIT별로 초기화
					int pltCnt = Integer.parseInt(pltrow.getString("PLTCNT"));
					for(int j = 0; j < pltCnt; j++){
						itemCount += 10;

						String snum = String.valueOf(itemCount);
						String inum = String.valueOf("0000").substring(0,(4-snum.length()))+snum;
						itemrow.put("BARCOD", asndky+asndit+inum);
						itemrow.put("WAREKY", pltrow.getString("WAREKY"));
						itemrow.put("SKUKEY", pltrow.getString("SKUKEY"));
						itemrow.put("DESC01", pltrow.getString("DESC01"));
						itemrow.put("QTDUOM", Integer.parseInt(pltrow.getString("QTPUOM")));	//SKU의 1팔렛트 입수량
						itemrow.put("QTDBOX", Integer.parseInt(pltrow.getString("PLTCNT")));	//PLT 수량
						itemrow.put("QTDREM", Integer.parseInt(pltrow.getString("QTYMOD")));	//잔량
						itemrow.put("QTDPRT", Integer.parseInt(pltrow.getString("QTYASN")));	//ASN 수량
						itemrow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));

						itemrow.setModuleCommand("WmsInbound", "BARCD");
						commonDao.insert(itemrow);
					}
				}
			}
		}
		return result;
	}
	
	
	
	@Transactional
	public int saveGR98EXCEL(DataMap map) throws SQLException, Exception {
		
		// 기초재고셋업 excel 업로드
		List<DataMap> excelList = map.getList("excelList");
		DataMap excelRow = new DataMap();
		
		String sqlMapNamespace = "WmsInbound";

		// 물류센터 전체 삭제
		excelRow = excelList.get(0).getMap("map");
		excelRow.setModuleCommand(sqlMapNamespace, "saveGR98EXCEL");
		commonDao.delete(excelRow);
		
		int count = 0;
		
		for(int i = 0; i < excelList.size(); i++) {
			excelRow = excelList.get(i).getMap("map");
//			System.out.println(excelRow);
			// INSERT PRCFLG = 'I'
			excelRow.setModuleCommand(sqlMapNamespace, "saveGR98EXCEL");
			commonDao.insert(excelRow);
			
			count ++;
		}
		// UPDATE PRCFLG = 'N'
//		commonDao.update(excelRow);
//		System.out.println("----------------------------------------");
//		// 제조일자, 유통기한 셋팅
//		chkExcel.setModuleCommand(sqlMapNamespace, "GR02UDILOTA1113");
//		commonDao.update(chkExcel);
//		
//		// 처리여부 ' ' 업데이트
//		chkExcel.setModuleCommand(sqlMapNamespace, "GR02UDICHK");
//		commonDao.update(chkExcel);
		
		return count;
	}
	
	
	@Transactional
	public int updateGR98EXCEL(DataMap map) throws SQLException, Exception {
		
		// 기초재고셋업 excel 업로드
		List<DataMap> excelList = map.getList("excelList");
		DataMap excelRow = new DataMap();
		
		String sqlMapNamespace = "WmsInbound";

		// 물류센터 전체 삭제
		excelRow = excelList.get(0).getMap("map");
		excelRow.setModuleCommand(sqlMapNamespace, "saveGR98EXCEL");
		
		int count = 0;

		// UPDATE PRCFLG = 'N'
		count = commonDao.update(excelRow);
		
		return count;
	}
	
	@Transactional
	public DataMap saveGR98(DataMap map) throws Exception {
		
		List<DataMap> head = map.getList("head");
		List<DataMap> itemList = new ArrayList<DataMap>();
		
		String sqlMapNamespace = "WmsInbound";
		
		int count = 0;
		String errMsg = "NONE";
		String recvky = "";
		
		for(int x=0; x < head.size(); x++) {
			DataMap headRow = head.get(x).getMap("map");
//			System.out.println("+++++++++++++++"+headRow);
//			if (1==1) { throw new RuntimeException("[ROLLBACK]\n" + headRow); }
			
			DataMap seq = new DataMap();
			seq.setModuleCommand(sqlMapNamespace, "FN_DOCUSEQ");
			seq.put("DOCUTY", headRow.getString("DOCUTY"));
			recvky = (String)commonDao.getObj(seq);
			
			headRow.setModuleCommand(sqlMapNamespace, "GR99");
			headRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			headRow.put("RECVKY", recvky);
			headRow.put("RCPTTY", headRow.getString("DOCUTY"));
			commonDao.insert(headRow);
//			System.out.println("++++++++headRow+++++++"+headRow);
			
			// tml_stk 조회
			itemList.clear();
			headRow.setModuleCommand(sqlMapNamespace, "GR98Sub");
			itemList = commonDao.getList(headRow);
			
			for(int i = 0; i < itemList.size(); i++) {
				DataMap row = itemList.get(i).getMap("map");
				
				DataMap inputData = new DataMap();
				DataMap input1113 = new DataMap();
				inputData.put("RECVKY", recvky);
				inputData.put("WAREKY", headRow.getString("WAREKY"));
				inputData.put("OWNRKY", headRow.getString("OWNRKY"));
				inputData.put("OAETYP", "E");
				inputData.put("SEBELN", " ");
				inputData.put("SEBELP", " ");
				inputData.put("ASNDKY", " ");
				inputData.put("ASNDIT", " ");
				inputData.put("LOCAKY", row.getString("LOCAKY"));
				inputData.put("TRNUID", " ");
				inputData.put("SKUKEY", row.getString("SKUKEY"));
				inputData.put("QTYRCV", row.get("QTYRCV"));    // 입고수량
				inputData.put("LOTA01", row.getString("LOTA01")); // 저장위치
				inputData.put("LOTA06", row.getString("LOTA06"));
				inputData.put("LOTA09", " ");
				inputData.put("LOTA10", " ");
				inputData.put("LOTA14", row.getString("LOTA14")); // 배치번호
				inputData.put("CHARG", row.getString("LOTA14")); // 배치번호
				
				inputData.put("VENDOR", " ");
				
				// 제조일자, 유통기한 산출 START
				if("V".equals(row.getString("ASKU01"))) {
					inputData.setModuleCommand(sqlMapNamespace, "GR_LOTA11_13_UDI");
					input1113 = commonDao.getMap(inputData);

					if(input1113 != null && input1113.size() > 0) {
						inputData.put("LOTA11", input1113.getString("LOTA11")); // 제조일자
						inputData.put("LOTA13", input1113.getString("LOTA13")); // 유통기한
					} else {
						inputData.put("LOTA11", row.getString("LOTA11")); // 제조일자
						inputData.put("LOTA13", row.getString("LOTA13")); // 유통기한
					}
				} else if("V".equals(row.getString("LOTL20"))) {
					inputData.setModuleCommand(sqlMapNamespace, "GR_LOTA11_13_BAT");
					input1113 = commonDao.getMap(inputData);

//					System.out.println("+++++++input1113++++++++"+input1113);
					if(input1113 != null && input1113.size() > 0) {
						inputData.put("LOTA11", input1113.getString("LOTA11")); // 제조일자
						inputData.put("LOTA13", input1113.getString("LOTA13")); // 유통기한
					} else {
						inputData.put("LOTA11", row.getString("LOTA11")); // 제조일자
						inputData.put("LOTA13", row.getString("LOTA13")); // 유통기한
					}
//					System.out.println("+++++++input1113++++++++"+input1113);
				} else {
					inputData.put("LOTA11", row.getString("LOTA11")); // 제조일자
					inputData.put("LOTA13", row.getString("LOTA13")); // 유통기한
				}
				// 제조일자, 유통기한 산출 END

				inputData.put("LOTA12", " ");
				inputData.put("RSNCOD", row.getString("RSNCOD"));
				inputData.put("RSNTXT", row.getString("RSNTXT"));
				inputData.put("USERID", map.get(CommonConfig.SES_USER_ID_KEY));
//				System.out.println("+++++++inputData++++++++"+inputData);

				inputData.setModuleCommand(sqlMapNamespace, "P_AIRWMS_RECEIPT");
//				commonDao.insert(inputData);
				errMsg = (String) commonDao.getObj(inputData);
				count++;
				
			}
			
			// 처리상태 Y셋팅

			headRow.setModuleCommand(sqlMapNamespace, "GR98");
			commonDao.update(headRow);
		}
		
//		// 식약처 신고관련 처리 TRCSC (SKUMA의 ASKU01 = 'V' 대상만 처리)
//		headRow.setModuleCommand(sqlMapNamespace, "saveGR02TRCSC");
//		commonDao.insert(headRow);
	
		// ROLLBACK
		if(!errMsg.equals("SUCCESS")){
			throw new RuntimeException("[ROLLBACK]\n" + errMsg);
		}
		
		DataMap rsMap = new DataMap();
		if(count > 0) {
			rsMap.put("RECVKY", recvky);
		}
		
		return rsMap;
	}
	
	
	
}