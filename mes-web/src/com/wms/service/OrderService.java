package com.wms.service;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.log4j.Logger;
import org.apache.poi.util.StringUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import com.common.bean.CommonConfig;
import com.common.bean.DataMap;
import com.common.dao.CommonDAO;
import com.common.util.StringUtility;
import com.common.util.Util;

@Service
public class OrderService {

	private static Logger log = Logger.getLogger(OrderService.class);

	@Autowired
	private Util util;
	
	@Autowired
	public CommonDAO commonDao;
	
	@Autowired
	public WmsService wmsService;
	
/*	@Transactional
	public int saveOM01(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		int count = 0;
		
		map.setModuleCommand("WmsOrder", "SEQSHPRQK");
		
		Object shprqk = commonDao.getObject(map);
	    map.put("SHPRQK", shprqk);
		
		int itemCount = 0;
		DataMap row;
		String shprqk = map.get("SHPRQK").toString();
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.setModuleCommand("WmsOrder", "OM01");
			
			itemCount += 10;
			String snum = String.valueOf(itemCount);
			String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
			
			row.put("SHPRQK", shprqk);
			row.put("SHPRQI", inum);
			row.put("WAREKY", map.get("WAREKY"));
			row.put("OWNRKY", map.get("OWNRKY"));
			row.put("RQSHPD", map.get("RQSHPD"));
			row.put("SHPMTY", map.get("SHPMTY"));
			row.put("PTRCVR", map.get("PTRCVR"));
			row.put("AREAKY", map.get("AREAKY"));
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			
			commonDao.insert(row);
			
			count ++;
		}
		map.setModuleCommand("WmsOrder", "OM01PROCALL");
		commonDao.getMap(map);
		
		return count;
	}*/
	
	@Transactional
	public String saveOM01(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		int count = 0;
		int itemCount = 0;
		DataMap row;
		DataMap row_next;
		

		String num_VBELN = "WMS" + wmsService.getNumSeq("NR-VBELN").substring(3);
		
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.setModuleCommand("WmsOrder", "OM01");
			
			itemCount += 10;
			String snum = String.valueOf(itemCount);
			String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;

			row.put("MANDT", "110" );
			row.put("SEQNO", wmsService.getNumSeq("NR-IF113"));
			row.put("VBELN", num_VBELN );
			row.put("POSNR", inum);
			row.put("BWART", map.get("SHPMTY"));
			row.put("WAREKY", map.get("WAREKY"));
			row.put("OWNRKY", map.get("OWNRKY"));
			row.put("RQSHPD", map.get("RQSHPD"));
			row.put("SHPMTY", map.get("SHPMTY"));
			row.put("PTRCVR", map.get("PTRCVR"));
			row.put("AREAKY", map.get("AREAKY"));
			row.put("STATUS", "A" );
			row.put("IFFLG", "N" );
			row.put("WADAT", map.get("RQSHPD"));
			row.put("PTNRKY", map.get("PTRCVR"));
			row.put("MEINS", row.get("UOMKEY") );
			row.put("DOCTXT", map.get("DOCTXT"));
			
			
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			
			commonDao.insert(row);
			
			count ++;
		}
		//map.setModuleCommand("WmsOrder", "OM01PROCALL");
		//commonDao.getMap(map);
		
		
		// 2017.05.23 ADD
		String num_VBELN_next = "WMS" + wmsService.getNumSeq("NR-VBELN").substring(3);
		row_next=  new DataMap();
		row_next.setModuleCommand("WmsOrder", "OM01_NEXT");
		
		
		row_next.put("VBELN", num_VBELN );
		row_next.put("VBELN_N", num_VBELN_next );
		row_next.put("WAREKY", list.get(0).getMap("map").get("WAREKY") );
		
		
		commonDao.insert(row_next);
		
		
		return num_VBELN;
	}
	
/*	@Transactional
	public int saveIO01(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		int count = 0;
		int itemCount = 0;
		DataMap row;
	
		String rcvrqk = map.get("RCVRQK").toString();
		
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.setModuleCommand("WmsOrder", "IO01");
			
			itemCount += 10;
			String snum = String.valueOf(itemCount);
			String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
			
			row.put("RCVRQK", rcvrqk);
			row.put("RCVRQI", inum);
			row.put("WAREKY", map.get("WAREKY"));
			row.put("OWNRKY", map.get("OWNRKY"));
			row.put("RCPTTY", map.get("RCPTTY"));
			row.put("ASNDAT", map.get("ASNDAT"));
			row.put("DPTNKY", map.get("DPTNKY"));
//			row.put("AREAKY", map.get("AREAKY"));
			row.putString("DOCTXT", map.get("DOCTXT"), " ");
			row.putString("RQSHPD", map.get("RQSHPD"), " ");
			row.putString("PTRCVR", map.get("PTRCVR"), " ");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			
			commonDao.insert(row);
			
			count ++;
		}
		map.setModuleCommand("WmsOrder", "IO01PROCALL");
		commonDao.getMap(map);
		
		return count;
	}*/
	
	
	@Transactional
	public String saveIO01(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		int count = 0;
		int itemCount = 0;
		DataMap row;
		
		//입고오더번호 채번
		String num_EBELN = "WMS" + wmsService.getNumSeq("NR-EBELN").substring(3);
		
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.setModuleCommand("WmsOrder", "IO01");
			
			itemCount += 10;
			String snum = String.valueOf(itemCount);
			String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
			
			row.put("MANDT", "110" );
			row.put("SEQNO", wmsService.getNumSeq("NR-IF113"));
			row.put("EBELN", num_EBELN );
			row.put("EBELP", inum );
			row.put("BWART", map.get("RCPTTY"));
			row.put("DPTNKY", map.get("DPTNKY"));
			row.put("DOCTXT", map.get("DOCTXT"));
			row.put("STATUS", "A" );
			row.put("IFFLG", "N" );
			row.put("ASNDAT", map.get("ASNDAT"));
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put("OWNRKY", map.get("OWNRKY"));
			row.put("WAREKY", map.get("WAREKY"));
			
			commonDao.insert(row);
			
			count ++;
		}
		//map.setModuleCommand("WmsOrder", "IO01PROCALL");
		//commonDao.getMap(map);
		
		return num_EBELN;
	}
	
	@Transactional
	public int saveIO05(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("head");
		int count = 0;
		DataMap row;
		
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			//row.setModuleCommand("WmsOrder", "IO05DELSPCALL");
			row.setModuleCommand("WmsOrder", "IO05");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			//commonDao.getMap(row);
			commonDao.delete(row);
			
			count ++;
		}
		
		return count;
	}
	
	@Transactional
	public String saveOM05(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("head");
		
		// Validation
//		StringBuffer sb = new StringBuffer();
//		for(DataMap item : list){
//			if(sb.length() > 0)
//			sb.append(" UNION ALL\n ");
//			sb.append(" SELECT '").append(item.getMap("map").get("SHPRQK")).append("' AS SHPRQK, ");
//			sb.append("        '").append(item.getMap("map").get("SHPOKY")).append("' AS SHPOKY FROM DUAL ");
//		}
//		
//		map.setModuleCommand("WmsOrder", "OM05VAL"); // 쿼리키값 넣을것
//		map.put("APPEND_QUERY", sb.toString());
//		List<DataMap> validList = commonDao.getValidation(map);
//		if(validList.size() > 0){
//			DataMap valid = validList.get(0);
//			return valid.getString("RESULTMSG");
//		}
//		
		int count = 0;
		DataMap row;
		
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			//row.setModuleCommand("WmsOrder", "OM05DELSPCALL");
			row.setModuleCommand("WmsOrder", "OM05");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			//commonDao.getMap(row);
			commonDao.delete(row);
			
			count ++;
		}
		if(count > 0 ){
			return "OK";
		}else{
			return "FAIL";
		}
	}
	
	@Transactional
	public int saveOM03(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		DataMap seq = new DataMap("WmsOrder", "SEQRPLSTK");
		DataMap seqMap = commonDao.getMap(seq);
		DataMap row;
		int count = 0;

		for(int i=0;i<list.size();i++){
			
			row = list.get(i).getMap("map");
			row.setModuleCommand("WmsOrder", "OM03");
			row.put("RPLSTK", seqMap.get("PRTSEQ").toString());
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			commonDao.insert(row);
			
			count ++;
		}
		
		map.setModuleCommand("WmsOrder", "OM03SPCALL");
		map.put("RPLSTK", seqMap.get("PRTSEQ").toString());
		commonDao.getMap(map);

		return count;
	}
	
	@Transactional
	public int savePrtseq(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("head");
		int count = 0;
		
		DataMap row;
		for(int i=0;i<list.size();i++){
		    row = list.get(i).getMap("map");
			row.setModuleCommand("WmsOrder", "PRTLG");		
			row.put("PRTSEQ", map.get("PRTSEQ").toString());	
			
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			commonDao.insert(row);
			
			count ++;
		}
		
		return count;
	}
	
	@Transactional
	public String validationIO05(DataMap map) throws SQLException {
		String result = "OK";
		List<DataMap> list = map.getList("list");
		
		String validationSql = "";
		String key = map.get("key").toString();
		if( map.containsKey("key") ){
			validationSql = util.urlCreateValidationSql(map, key);
			map.put(CommonConfig.VALIDATION_SQL_KEY, validationSql);
			map.setModuleCommand("WmsOrder", "IO05VAL");
						
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
	public DataMap validationIO02(DataMap map) throws SQLException {
		DataMap rsMap = new DataMap();
		List<DataMap> list = map.getList("list");
		
		map.setModuleCommand("WmsOrder", "IO02");
		
		if(map.containsKey(CommonConfig.GRID_REQUEST_VALIDATION_KEY)){
			String validationSql = util.createValidationSql(map);
			if(validationSql.length() > 0){
				map.put(CommonConfig.VALIDATION_SQL_KEY, validationSql);
				log.debug(map);
				List<DataMap> vList = commonDao.getValidation(map);
				rsMap.put("data", vList);
			}
		}
		
		return rsMap;
	}
	
	@Transactional
	public DataMap validationOM02(DataMap map) throws SQLException {
		DataMap rsMap = new DataMap();
		List<DataMap> list = map.getList("list");
		
		map.setModuleCommand("WmsOrder", "OM02");
		
		if(map.containsKey(CommonConfig.GRID_REQUEST_VALIDATION_KEY)){
			String validationSql = util.createValidationSql(map);
			if(validationSql.length() > 0){
				map.put(CommonConfig.VALIDATION_SQL_KEY, validationSql);
				log.debug(map);
				List<DataMap> vList = commonDao.getValidation(map);
				rsMap.put("data", vList);
			}
		}
		return rsMap;
	}
	
	/*@Transactional
	public int saveIO02(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		
		List<List<DataMap>> devidedList = devidingList(list);
		for(List<DataMap> head : devidedList){
			
			log.debug("1111111111111");
			map.setModuleCommand("WmsOrder", "SEQRCVRQK");
			Object rcvrqk = commonDao.getObject(map);
			rcvrqk = StringUtility.leftPad(rcvrqk+"", "0", 10);
			
			int itemCount = 0;
			for(DataMap item : head){
				log.debug("2222222222222222");
				item = item.getMap("map");
				item.setModuleCommand("WmsOrder", "IO02");
				
				itemCount += 10;
				String snum = String.valueOf(itemCount);
				String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
				
				item.put("RCVRQK", rcvrqk);
				item.put("RCVRQI", inum);
				item.put("OWNRKY", map.get("OWNRKY"));
				item.put("RCPTTY", map.get("RCPTTY"));
				item.put("WAREKY", map.get("WAREKY"));
				item.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				item.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
				log.debug("33333333333333333333");
				commonDao.insert(item);
			}
			log.debug("444444444444444444444444");
			map.put("RCVRQK", rcvrqk);
			map.setModuleCommand("WmsOrder", "IO01PROCALL");
			commonDao.getMap(map);
			log.debug("444444444444444444444444");
			//map.put("RCVRQK", rcvrqk);
			//map.setModuleCommand("WmsOrder", "IO01PROCALL");
			//commonDao.getMap(map);
		}
		log.debug("55555555555555555");
		return 0;
	}*/
	
	private List<List<DataMap>> devidingList(List<DataMap> list) throws SQLException {
		Map<String,List> headListMap = new HashMap<String,List>();
		String key = null;
		String asndat, vendor, rqshpd, ptrcvr, areaky, doctxt = null;
		List<DataMap> tempList = null;
		for(DataMap row : list){
			row = row.getMap("map");
			asndat = row.getString("ASNDAT");
			vendor = row.getString("VENDOR");
			rqshpd = row.getString("RQSHPD");
			ptrcvr = row.getString("PTRCVR");
			areaky = row.getString("AREAKY");
			doctxt = row.getString("DOCTXT");

			key = asndat + vendor + rqshpd + ptrcvr + areaky + doctxt;
			
			if(headListMap.containsKey(key)){
				tempList = headListMap.get(key);
			}else{
				tempList = new ArrayList<DataMap>();
			}
			tempList.add(row);
			headListMap.put(key, tempList);
		}
		
		List<List<DataMap>> devidedList = new ArrayList<List<DataMap>>();
		Set<String> keySet = headListMap.keySet();
		for(String headKey : keySet){
			devidedList.add(headListMap.get(headKey));
		}
		
		return devidedList;
	}
	
	@Transactional
	public String saveIO02(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		int count = 0;
		int itemCount = 0;
		DataMap row;
		
		//입고오더번호 채번
		String num_EBELN = "WMS" + wmsService.getNumSeq("NR-EBELN").substring(3);
		
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.setModuleCommand("WmsOrder", "IO02");
			
			itemCount += 10;
			String snum = String.valueOf(itemCount);
			String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
			
			row.put("MANDT", "110" );
			row.put("SEQNO", wmsService.getNumSeq("NR-IF113"));
			row.put("EBELN", num_EBELN );
			row.put("EBELP", inum );
			row.put("BWART", map.get("RCPTTY"));
			row.put("LIFNR", map.get("VENDOR"));
			//row.put("DOCTXT", map.get("DOCTXT"));
			row.put("STATUS", "A" );
			row.put("IFFLG", "N" );
			//row.put("ASNDAT", map.get("ASNDAT"));
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put("OWNRKY", map.get("OWNRKY"));
			row.put("WAREKY", map.get("WAREKY"));
			
			commonDao.insert(row);
			
			count ++;
		}
		//map.setModuleCommand("WmsOrder", "IO01PROCALL");
		//commonDao.getMap(map);
		 
		return num_EBELN;
	}
	
	public String saveOM02(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		int count = 0;
		int itemCount = 0;
		DataMap row;
		DataMap row_next;
		

		String num_VBELN = "WMS" + wmsService.getNumSeq("NR-VBELN").substring(3);
		
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.setModuleCommand("WmsOrder", "OM02");
			
			itemCount += 10;
			String snum = String.valueOf(itemCount);
			String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
			
			row.put("MANDT", "110" );
			row.put("SEQNO", wmsService.getNumSeq("NR-IF113"));
			row.put("VBELN", num_VBELN );
			row.put("POSNR", inum);
			row.put("BWART", map.get("SHPMTY"));
			row.put("WAREKY", map.get("WAREKY"));
			row.put("OWNRKY", map.get("OWNRKY"));
			row.put("SHPMTY", map.get("SHPMTY"));
			row.put("PTRCVR", map.get("PTRCVR"));
			row.put("AREAKY", map.get("AREAKY"));
			row.put("STATUS", "A" );
			row.put("IFFLG", "N" );
			row.put("WADAT", row.get("RQSHPD"));
			row.put("PTNRKY", map.get("PTRCVR"));
			row.put("MEINS", row.get("UOMKEY") );
			row.put("C00103", map.get("DOCTXT"));
			row.put("LFIMG", row.get("QTYSHP"));
			
			
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			
			commonDao.insert(row);
			
			count ++;
		}
		//map.setModuleCommand("WmsOrder", "OM01PROCALL");
		//commonDao.getMap(map);
		
		
		// 2017.05.23 ADD
//		String num_VBELN_next = "WMS" + wmsService.getNumSeq("NR-VBELN").substring(3);
//		row_next=  new DataMap();
//		row_next.setModuleCommand("WmsOrder", "OM02_NEXT");
//		
//		
//		row_next.put("VBELN", num_VBELN );
//		row_next.put("VBELN_N", num_VBELN_next );
//		row_next.put("WAREKY", list.get(0).getMap("map").get("WAREKY") );
//		
//		
//		commonDao.insert(row_next);
		
		
		return num_VBELN;
	} 
	
	@Transactional
	public DataMap skuDesc(DataMap map) throws SQLException {
		DataMap rsMap = new DataMap();
		
		map.setModuleCommand("WmsOrder", "IO02_SKUDESC");
		map.put("SKUKEY", map.get("SKUKEY"));
		map.put("OWNRKY", map.get("OWNRKY"));
		
		rsMap = commonDao.getMap(map);
		return rsMap;
	}
	
}