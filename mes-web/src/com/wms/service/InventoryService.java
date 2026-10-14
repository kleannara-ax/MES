package com.wms.service;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.common.bean.CommonConfig;
import com.common.dao.CommonDAO;
import com.common.bean.DataMap;
import com.common.util.Util;

@Service
public class InventoryService {

	@Autowired
	public CommonDAO commonDao;
	
	@Autowired
	private Util util;
	
	@Transactional
	public int saveAdjd(DataMap map) throws SQLException {
		DataMap head = map.getMap("head").getMap("map");
		List<DataMap> list = map.getList("list");
		int count = 0;
		
		head.setModuleCommand("WmsInventory", "ADJDH");
		head.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		
		count += commonDao.update(head);		
		
		int qty;
		int itemCount = 0;
		DataMap row;
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.setModuleCommand("WmsInventory", "ADJDIOLD");
			
			itemCount += 10;
			String snum = String.valueOf(itemCount);
			String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
			
			row.put("SADJIT", inum);
			
			//qty = new BigDecimal((String)row.get("AQTADJU"));
			//row.put("QTADJU", qty);
			qty = row.getInt("AQTADJU");
			row.put("QTADJU", String.valueOf(qty*-1));
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put("SADJKY", head.get("SADJKY"));
			
			commonDao.insert(row);
			
			itemCount += 10;
			snum = String.valueOf(itemCount);
			inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
			
			row.setModuleCommand("WmsInventory", "ADJDI");
			row.put("SADJIT", inum);
			row.put("AQTADJU", String.valueOf(qty));
			row.put("STOKKY", " ");
			row.put("LOTNUM", " ");
			
			commonDao.insert(row);

			count ++;
		}

		/*head.put("DOCUKY", head.getString("SADJKY"));
		commonDao.getMap("WmsInbound.GR_AIRWMS_DOCUMENT_PROCESS", head);*/
		
		return count;
	}
	
	@Transactional
	public int saveAdjd03(DataMap map) throws SQLException {
		DataMap head = map.getMap("head").getMap("map");
		List<DataMap> list = map.getList("list");
		int count = 0;
		
		head.setModuleCommand("WmsInventory", "ADJDH");
		head.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		
		count += commonDao.update(head);		
		
		int qty;
		int itemCount = 0;
		DataMap row;
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.setModuleCommand("WmsInventory", "ADJDIOLD");
			
			itemCount += 10;
			String snum = String.valueOf(itemCount);
			String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
			
			row.put("SADJIT", inum);
			//qty = new BigDecimal((String)row.get("AQTADJU"));
			//row.put("QTADJU", qty);
			qty = row.getInt("AQTADJU");
			row.put("QTADJU", String.valueOf(qty*-1));
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put("SADJKY", head.get("SADJKY"));
			
			commonDao.insert(row);
			
			itemCount += 10;
			snum = String.valueOf(itemCount);
			inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
			
			row.setModuleCommand("WmsInventory", "ADJDI");
			row.put("SADJIT", inum);
			row.put("AQTADJU", String.valueOf(qty));
			row.put("STOKKY", " ");
			row.put("LOTNUM", " ");
			
			commonDao.insert(row);

			count ++;
		}
		
		head.put("DOCUKY", head.getString("SADJKY"));
//		commonDao.getMap("WmsInbound.GR_AIRWMS_DOCUMENT_PROCESS", head);
		
		return count;
	}
	
	@Transactional
	public int savePhyd(DataMap map) throws SQLException {
		DataMap head = map.getMap("head").getMap("map");
		List<DataMap> list = map.getList("list");
		int count = 0;
		
		head.setModuleCommand("WmsInventory", "PHYDH");
		head.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		
		count += commonDao.update(head);
		DataMap row;
		for(int i=0;i<list.size();i++){
		    row = list.get(i).getMap("map");
			row.setModuleCommand("WmsInventory", "PHYDI");
			
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put("PHYIKY", head.get("PHYIKY"));
			
			String snum = String.valueOf((i+1)*100);
			String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
			
			row.put("PHYIIT", inum);
			
			count += commonDao.update(row);
		}
		if("520".equals(head.getString("PHSCTY"))){
			head.put("DOCUKY", head.getString("PHYIKY"));
			commonDao.getMap("WmsInbound.GR_AIRWMS_DOCUMENT_PROCESS", head);
		}
		return count;
	}
	
	@Transactional
	public int savePhyd02(DataMap map) throws SQLException {

		DataMap head = map.getMap("head").getMap("map");
		List<DataMap> list = map.getList("list");
		int count = 0;
		
		head.setModuleCommand("WmsInventory", "PHYDHO");
		head.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		
		count += commonDao.update(head);
		DataMap row;
		
		String qtsphy = null;
		String qtsiwh = null;
		for(int i=0;i<list.size();i++){
		    row = list.get(i).getMap("map");
			row.setModuleCommand("WmsInventory", "IP02Sub");			
			
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			
			count += commonDao.update(row);
			
			String phyiit = row.getString("PHYIIT"); 
			
			row.setModuleCommand("WmsInventory", "IP02QTY");
			row.put("PHYIIT", phyiit);
			DataMap qtyMap = commonDao.getMap(row);
			qtsphy = qtyMap.get("QTSPHY").toString();  
			qtsiwh = qtyMap.get("QTSIWH").toString(); 
				
			
			row.put("PHYIIT", row.getString("PHYIIT").substring(0, 5)+"1");
			row.put("QTSPHY", row.getString("QTADJU"));
			
			row.setModuleCommand("WmsInventory", "IP02Sub");
			count += commonDao.delete(row);

			row.setModuleCommand("WmsInventory", "PHYDI2");
			row.put("QTSPHY", qtsphy);
			row.put("QTSIWH", qtsiwh);
			count += commonDao.update(row);
		}
		
		return count;
	}
	
	@Transactional
	public int savePrtseq(DataMap map) throws SQLException {
		DataMap head = map.getMap("head").getMap("map");
		List<DataMap> list = map.getList("head");
		int count = 0;
		
		DataMap row;
		for(int i=0;i<list.size();i++){
		    row = list.get(i).getMap("map");
			row.setModuleCommand("WmsInventory", "PRTLGPHY");		
			row.put("PRTSEQ", map.get("PRTSEQ"));	
			
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			commonDao.insert(row);
			
			count ++;
		}
		
		return count;
	}
	
	@Transactional
	public int confirmIP02(DataMap map) throws SQLException {
		List<DataMap> head = map.getList("head");
		int count = 0;
		
		DataMap row;
		for(int i=0;i<head.size();i++){
		    row = head.get(i).getMap("map");
			row.setModuleCommand("WmsInventory", "CONFIRM_IP02");		
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			
			commonDao.update(row);
			
			count ++;
		}
		
		return count;
	}
	
	@Transactional
	public String validationIP02(DataMap map) throws SQLException {
		String result = "OK";
		List<DataMap> list = map.getList("list");
		
		String validationSql = "";
		String key = map.get("key").toString();
		if( map.containsKey("key") ){
			validationSql = util.urlCreateValidationSql(map, key);
			map.put(CommonConfig.VALIDATION_SQL_KEY, validationSql);
			map.setModuleCommand("WmsInventory", "IP02");
						
			List<DataMap> vList = commonDao.getValidation(map);
			
			DataMap rsMap = new DataMap();
			
			for(int j = 0; j < vList.size(); j++){
				rsMap = vList.get(j);
				if( !rsMap.getString("MSG").equals(" ") || rsMap.getString("MSG") != null){
					result = rsMap.getString("MSG");
					break;
				}
			}
		}
		return result;
	}
	
	@Transactional
	public String areaSD02(DataMap map) throws SQLException {
		String result = "OK";
		List<DataMap> list = map.getList("list");
		
		String validationSql = "";
		String key = map.get("key").toString();
		if( map.containsKey("key") ){
			validationSql = util.urlCreateValidationSql(map, key);
			map.put(CommonConfig.VALIDATION_SQL_KEY, validationSql);
			map.setModuleCommand("WmsInventory", "IP02");
						
			List<DataMap> vList = commonDao.getValidation(map);
			
			DataMap rsMap = new DataMap();
			
			for(int j = 0; j < vList.size(); j++){
				rsMap = vList.get(j);
				if( !rsMap.getString("MSG").equals(" ") || rsMap.getString("MSG") != null){
					result = rsMap.getString("MSG");
					break;
				}
			}
		}
		return result;
	}
}