package com.wms.service;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.text.CharacterIterator;
import java.text.SimpleDateFormat;
import java.text.StringCharacterIterator;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.ParsedSql;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.interceptor.TransactionAspectSupport;

import com.common.bean.CommonConfig;
import com.common.bean.DataMap;
import com.common.bean.SystemConfig;
import com.common.dao.CommonDAO;
import com.common.bean.DataMap;
import com.common.util.StringUtility;
import com.common.util.Util;
import com.common.util.SqlUtil;
import com.ibatis.sqlmap.client.SqlMapClient;
import com.ibatis.sqlmap.client.SqlMapSession;
import com.wms.controller.WmsController;
import com.common.bean.SystemConfig;

@Service
public class OutboundService {

	private static Logger log = Logger.getLogger(OutboundService.class);
	
	@Autowired
	private Util util;
	
	@Autowired
	public CommonDAO commonDao;
	
	@Autowired
	public WmsService wmsService;
	
	@Autowired
	@Qualifier("sqlMapClient")
	SqlMapClient sqlMapClient;
	
	
	public static boolean isNull(String value) {
		return (value == null);
	}
	
	public static boolean isEmpty(String value) {
		return (isNull(value) || value.trim().length() == 0);
	}
	
	public static boolean isNotEmpty(String value) {
		return isEmpty(value) ? false : true;
	}
	
	public static String leftPad(String stringToPad, String padder, int size) {
		StringBuffer strb;
		StringCharacterIterator sci;

		if (padder.length() == 0)
			return stringToPad;

		if (isNull(stringToPad)) {
			char[] t = new char[size];
			for (int i = 0; i < t.length; i++)
				t[i] = padder.charAt(0);

			stringToPad = String.valueOf(t);
		}

		strb = new StringBuffer(size);
		sci = new StringCharacterIterator(padder);

		while (strb.length() < (size - stringToPad.length()))
			for (char ch = sci.first(); ch != CharacterIterator.DONE; ch = sci.next())
				if (strb.length() < size - stringToPad.length())
					strb.insert(strb.length(), String.valueOf(ch));
		return strb.append(stringToPad).toString();
	}
	
	@Transactional
	public DataMap saveGr01(DataMap map) throws SQLException {
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
					itemRow.put("RECVKY", docNum);
					itemRow.setModuleCommand("WmsInbound", "RECDI");

					itemCount += 10;
					String snum = String.valueOf(itemCount);
					String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;

					itemRow.put("RECVIT", inum);

					count += commonDao.update(itemRow);
				}

			}else{
				row = head.get(i).getMap("map");
				String docNum = wmsService.getDocSeq("051");
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
				row.setModuleCommand("WmsInbound", "GR15");
				
				commonDao.update(row);
				
				for(int k = 0 ; k < selectList.size() ; k ++){
					itemRow = selectList.get(k).getMap("map");
					itemRow.put("RECVKY", docNum);
					itemRow.setModuleCommand("WmsInbound", "GR15Sub");
					
					itemCount += 10;
					String snum = String.valueOf(itemCount);
					String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
					
					itemRow.put("RECVIT", inum);
					
					count += commonDao.update(itemRow);
				}
			}else{
				row = head.get(i).getMap("map");
				
				String docNum = wmsService.getDocSeq("051");
				docNumList.add(docNum);
				
				row.setModuleCommand("WmsInbound", "GR15");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				row.put("RECVKY", docNum);
				
				commonDao.update(row);
				
				row.setModuleCommand("WmsInbound", "GR15Sub");
				
				List<DataMap> list = commonDao.getList(row); 
				
				for(int j = 0 ; j < list.size() ; j ++){
					itemRow = list.get(j);
					itemRow.put("RECVKY", docNum);
					itemRow.setModuleCommand("WmsInbound", "GR15Sub");
					
					itemCount += 10;
					String snum = String.valueOf(itemCount);
					String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
					
					itemRow.put("RECVIT", inum);
					commonDao.update(itemRow);
					
				}
				
			}
			
			StringBuilder sb = new StringBuilder();
			for(int k = 0 ; k < docNumList.size() ; k ++){
				if(k != 0){
					sb.append(",");
				}
				sb.append("'").append(docNumList.get(k)).append("'");
			}
			map.setModuleCommand("WmsInbound", "GR15R");
			map.put("RECVKY", sb.toString());
			rsMap.put("RECVKY", sb.toString());
			//return count;
		}
		return rsMap;
	}
	
	@Transactional
	public String saveDL01ValueCheck(DataMap map) throws SQLException {
		String result = "OK";
		try{
			List<DataMap> list = map.getList("list");
			DataMap head = map.getMap("head").getMap("map");
			
			DataMap row;
			String VALIDATION_SQL = "";
			
			String validationSql = "";
			String key = map.get("key").toString();
			
			if(map.containsKey("key")){
				validationSql = util.urlCreateValidationSql(map, key);
				map.put(CommonConfig.VALIDATION_SQL_KEY, validationSql);
				map.put("WAREKY", head.getString("WAREKY"));
				map.setModuleCommand("WmsOutbound", "SHPDH");
				
				List<DataMap> vList = commonDao.getValidation(map);
				log.debug(":::::::::::"+vList.size());
				if(vList.size() > 0){
					result = "OUT_M0140 VBELN";
				}
			}
		}catch(Exception e){
			log.debug("validataion error = "+e);
		}
		log.debug(":::::::::::::::::::::"+result);
		return result;
	}
	
	@Transactional
	public int saveDl01(DataMap map) throws SQLException {
		DataMap head = map.getMap("head").getMap("map");
		List<DataMap> list = map.getList("list");
		
		if(head.getString("SHPMTY").toString().equals("266")){
			head.put("PTRCVR", head.getString("DPTNKY"));
		}
		
		// ownrky 조회
		head.setModuleCommand("WmsOutbound", "OWNRKY");
		String ownrky = (String) commonDao.getObject(head);
			
		head.put("OWNRKY", ownrky);
		head.put("STATDO", "NEW");
		head.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		head.setModuleCommand("WmsOutbound", "SHPDH");
		
		//merge 문
		commonDao.insert(head);
		
		int count = 0;
		DataMap row = new DataMap();
		int itemCount = 0;
		String snum;
		String inum;
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.put("OWNRKY", ownrky);
			row.setModuleCommand("WmsOutbound", "SHPDI");
			row.put("PROGID", "DL01");
			row.put("WAREKY", head.get("WAREKY"));
			row.put("SHPOKY", head.get("SHPOKY"));
			row.put("STATIT", "NEW");
			
			itemCount += 10;
			snum = String.valueOf(itemCount);
			inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
			row.put("SHPOIT", inum);
			
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			
			// merge 문
			commonDao.insert(row);
			
			if(!row.getString("SHPMTY").toString().equals("299")){
				row.setModuleCommand("WmsOutbound", "IF113N00101");
				commonDao.update(row);
			}
			count++;
		}
		
		if(head.getString("SHPMTY").toString().equals("299")){
			head.setModuleCommand("WmsOutbound", "IF113STKNUM");
			commonDao.update(head);
		}
		
		if(!head.getString("DRELIN").toString().equals("V")){
			head.put("DRELIN", "V");
			head.setModuleCommand("WmsOutbound", "SHPDH");
			commonDao.update(head);
			
			if(head.getString("SHPMTY").toString().equals("299")){
				head.setModuleCommand("WmsOutbound", "IF113PROC");
				DataMap procMap = commonDao.getMap(head);
			}
			
			/*head.setModuleCommand("WmsOutbound", "IF313PROC");
			DataMap procSubMap = commonDao.getMap(head);*/
		}
		return count;
	}
	
	public String itemValueCheck(DataMap map) throws SQLException {
		String result = "OK";
		List<DataMap> list = map.getList("list");
		DataMap head = map.getMap("head");
		
		DataMap row;
		String VALIDATION_SQL = "";
		
		String validationSql = "";
		String key = map.get("key").toString();
		if(map.containsKey("key")){
			validationSql = util.itemCreateValidationSql(map, key);
			map.put(CommonConfig.VALIDATION_SQL_KEY, validationSql);
			map.put("WAREKY", head.getString("WAREKY"));
			map.setModuleCommand("WmsOutbound", "SHPDH");
		
			List<DataMap> vList = commonDao.getValidation(map);
			log.debug("size:::::::::::::"+vList.size());
			if(vList.size() > 0){
				result = "OUT_M0140 VBELN";
			}
		}
		log.debug("result:::::::::::::"+result);
		return result;
	}
	
	@Transactional
	public int saveDL01AllChkeck(DataMap map) throws SQLException, Exception {
		List<DataMap> head = map.getList("head");
		
		int count = 0;
		DataMap row = new DataMap();
		DataMap itemRow;
		DataMap validationMap = new DataMap();
		String validationResult = "";
		int validationCount = 0;
		for(int i=0;i<head.size();i++){
			row = head.get(i).getMap("map");
			
			// ownrky 조회
			row.setModuleCommand("WmsOutbound", "OWNRKY");
			String ownrky = (String) commonDao.getObject(row);
			
			if(row.getString("SHPMTY").equals("266")){
				row.put("PTRCVR", row.getString("DPTNKY"));
			}
			
			row.put("OWNRKY", ownrky);
			row.put("STATDO", "NEW");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.setModuleCommand("WmsOutbound", "SHPDH");
			
			//merge 문
			commonDao.insert(row);
			count++;
			
			row.setModuleCommand("WmsOutbound", "DL01");
			List<DataMap> itemList =commonDao.getList(row);
			
			int itemCount = 0;
			String snum;
			String inum;
			// item table validation
			for(int j = 0; j < itemList.size(); j++){
				itemRow = new DataMap(itemList.get(j));
				validationMap.put("head", row);
				validationMap.put("list", itemList);
				validationMap.put("key", "SMANDT,SVBELN,SPOSNR,SKUKEY,QTSHPO");
				validationResult = itemValueCheck(validationMap);
				
				if(!validationResult.equals("OK")){
					validationCount++;
					break;
				}else{
					itemRow.put("OWNRKY", ownrky);
					itemRow.setModuleCommand("WmsOutbound", "SHPDI");
					itemRow.put("PROGID", row.getString("PROGID"));
					itemRow.put("WAREKY", row.getString("WAREKY"));
					itemRow.put("SHPOKY", row.getString("SHPOKY"));
					itemRow.put("STATIT", "NEW");
					
					itemCount += 10;
					snum = String.valueOf(itemCount);
					inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
					itemRow.put("SHPOIT", inum);
					
					itemRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
					
					try{
						
						itemRow.put("QTSORG", itemRow.getString("QTSORG"));
						itemRow.put("QTSHPO", itemRow.getString("QTSHPO"));
						itemRow.put("QTYREF", itemRow.getString("QTYREF"));
						itemRow.put("QTUALO", itemRow.getString("QTUALO"));
						itemRow.put("QTAPPO", itemRow.getString("QTAPPO"));
						itemRow.put("QTALOC", itemRow.getString("QTALOC"));
						itemRow.put("QTJCMP", itemRow.getString("QTJCMP"));
						itemRow.put("QTSHPD", itemRow.getString("QTSHPD"));
						itemRow.put("QTSHPC", itemRow.getString("QTSHPC"));
						itemRow.put("QTYUOM", itemRow.getString("QTYUOM"));
						itemRow.put("QTPUOM", itemRow.getString("QTPUOM"));
						itemRow.put("QTDUOM", itemRow.getString("QTDUOM"));
						itemRow.put("GRSWGT", itemRow.getString("GRSWGT"));
						itemRow.put("NETWGT", itemRow.getString("NETWGT"));
						itemRow.put("LENGTH", itemRow.getString("LENGTH"));
						itemRow.put("WIDTHW", itemRow.getString("WIDTHW"));
						itemRow.put("HEIGHT", itemRow.getString("HEIGHT"));
						itemRow.put("CUBICM", itemRow.getString("CUBICM"));
						itemRow.put("CAPACT", itemRow.getString("CAPACT"));
						itemRow.put("LOTA16", itemRow.getString("LOTA16"));
						itemRow.put("LOTA17", itemRow.getString("LOTA17"));
						itemRow.put("LOTA18", itemRow.getString("LOTA18"));
						itemRow.put("LOTA19", itemRow.getString("LOTA19"));
						itemRow.put("LOTA20", itemRow.getString("LOTA20"));
						itemRow.put("AWMSNO", itemRow.getString("AWMSNO"));
						itemRow.put("WGTUNT", itemRow.getString("WGTUNT"));
						
						commonDao.insert(itemRow);
					}catch(Exception e){
						log.debug("error::::::::::::::::::"+e);
					}
					
					log.debug("SHPMTY:::::::::::::::::::::"+row.getString("SHPMTY"));
					if(!row.getString("SHPMTY").toString().equals("299")){
						itemRow.setModuleCommand("WmsOutbound", "IF113N00101");
						commonDao.update(itemRow);
					}
				}
			}
			
			// 헤더 정보 저장.
			if(validationResult.equals("OK")){
				if(row.getString("SHPMTY").toString().equals("299")){
					row.setModuleCommand("WmsOutbound", "IF113STKNUM");
					commonDao.update(row);
				}
				
				if(!row.getString("DRELIN").toString().equals("V")){
					row.put("DRELIN", "V");
					row.setModuleCommand("WmsOutbound", "SHPDH");
					commonDao.update(row);
				}
			}
		}
		
		if(validationCount > 0){
			count = 0;
			throw new Exception();
		}
		
		return count;
	}
	
	@Transactional(rollbackFor=Exception.class)
	public int DL01IndexSelectCheckSave(DataMap map) throws SQLException, Exception {
		List<DataMap> head = map.getList("head");
		DataMap focusHead = map.getMap("focusHead").getMap("map");
		List<DataMap> list = map.getList("list");
		String rowHeadIdx = map.get("rowHeadIdx").toString();
		String selRowidx = map.get("arrSelRowIdx").toString();
		
		
		/**
		 * 선택된 헤드 정보와 아이탬 정보 저장
		 */
		if(focusHead.getString("SHPMTY").toString().equals("266")){
			focusHead.put("PTRCVR", focusHead.getString("DPTNKY"));
		}
		
		// ownrky 조회
		focusHead.setModuleCommand("WmsOutbound", "OWNRKY");
		String ownrky = (String) commonDao.getObject(focusHead);
		
		focusHead.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		focusHead.put("OWNRKY", ownrky);
		focusHead.put("STATDO", "NEW");
		focusHead.setModuleCommand("WmsOutbound", "SHPDH");
		
		//merge 문
		commonDao.insert(focusHead);
		
		int count = 0;
		DataMap row = new DataMap();
		int itemCount = 0;
		String snum;
		String inum;
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.put("OWNRKY", ownrky);
			row.setModuleCommand("WmsOutbound", "SHPDI");
			row.put("PROGID", "DL01");
			row.put("WAREKY", focusHead.get("WAREKY"));
			row.put("SHPOKY", focusHead.get("SHPOKY"));
			row.put("STATIT", "NEW");
			
			itemCount += 10;
			snum = String.valueOf(itemCount);
			inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
			row.put("SHPOIT", inum);
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			
			// merge 문
			commonDao.insert(row);
			
			if(!row.getString("SHPMTY").toString().equals("299")){
				row.setModuleCommand("WmsOutbound", "IF113N00101");
				commonDao.update(row);
			}
			count++;
		}
		
		if(focusHead.getString("SHPMTY").toString().equals("299")){
			focusHead.setModuleCommand("WmsOutbound", "IF113STKNUM");
			commonDao.update(focusHead);
		}
		
		if(!focusHead.getString("DRELIN").toString().equals("V")){
			focusHead.put("DRELIN", "V");
			focusHead.setModuleCommand("WmsOutbound", "SHPDH");
			commonDao.update(focusHead);
		}
		
		/**
		 * 체크된 헤드 정보 저장.(아이탬 정보 일괄 처리)
		 */
		String[] arrIdx = selRowidx.split(",");
		DataMap itemRow;
		DataMap validationMap = new DataMap();
		String validationResult = "";
		int validationCount = 0;
		
		for(int i=0;i<arrIdx.length;i++){
			// 체크된 row의 index와 선택된 row index가 동일함.
			if(!arrIdx[i].equals(rowHeadIdx)){
				row = head.get(i).getMap("map");
				if(row.getString("SHPMTY").equals("266")){
					row.put("PTRCVR", row.getString("DPTNKY"));
				}
				
				try{
					row.put("OWNRKY", ownrky);
					row.put("STATDO", "NEW");
					row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
					row.setModuleCommand("WmsOutbound", "SHPDH");
		
					//merge 문
					commonDao.insert(row);
				}catch(Exception e){
					log.debug("error:::::::::::::::::::::"+e);
				}
				count++;
				row.setModuleCommand("WmsOutbound", "DL01");
				List<DataMap> itemList =commonDao.getList(row);
				
				itemCount = 0;
				// item table validation
				for(int j = 0; j < itemList.size(); j++){
					itemRow = new DataMap(itemList.get(j));
					validationMap.put("head", row);
					validationMap.put("list", itemList);
					validationMap.put("key", "SMANDT,SVBELN,SPOSNR,SKUKEY,QTSHPO");
					validationResult = itemValueCheck(validationMap);
					
					if(!validationResult.equals("OK")){
						validationCount++;
						break;
					}else{
						itemRow.put("OWNRKY", ownrky);
						itemRow.setModuleCommand("WmsOutbound", "SHPDI");
						itemRow.put("PROGID", row.getString("PROGID"));
						itemRow.put("WAREKY", row.getString("WAREKY"));
						itemRow.put("SHPOKY", row.getString("SHPOKY"));
						itemRow.put("STATIT", "NEW");
						
						itemCount += 10;
						snum = String.valueOf(itemCount);
						inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
						itemRow.put("SHPOIT", inum);
						
						itemRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
						
						// merge 문
						try{
							
							itemRow.put("QTSORG", itemRow.getString("QTSORG"));
							itemRow.put("QTSHPO", itemRow.getString("QTSHPO"));
							itemRow.put("QTYREF", itemRow.getString("QTYREF"));
							itemRow.put("QTUALO", itemRow.getString("QTUALO"));
							itemRow.put("QTAPPO", itemRow.getString("QTAPPO"));
							itemRow.put("QTALOC", itemRow.getString("QTALOC"));
							itemRow.put("QTJCMP", itemRow.getString("QTJCMP"));
							itemRow.put("QTSHPD", itemRow.getString("QTSHPD"));
							itemRow.put("QTSHPC", itemRow.getString("QTSHPC"));
							itemRow.put("QTYUOM", itemRow.getString("QTYUOM"));
							itemRow.put("QTPUOM", itemRow.getString("QTPUOM"));
							itemRow.put("QTDUOM", itemRow.getString("QTDUOM"));
							itemRow.put("GRSWGT", itemRow.getString("GRSWGT"));
							itemRow.put("NETWGT", itemRow.getString("NETWGT"));
							itemRow.put("LENGTH", itemRow.getString("LENGTH"));
							itemRow.put("WIDTHW", itemRow.getString("WIDTHW"));
							itemRow.put("HEIGHT", itemRow.getString("HEIGHT"));
							itemRow.put("CUBICM", itemRow.getString("CUBICM"));
							itemRow.put("CAPACT", itemRow.getString("CAPACT"));
							itemRow.put("LOTA16", itemRow.getString("LOTA16"));
							itemRow.put("LOTA17", itemRow.getString("LOTA17"));
							itemRow.put("LOTA18", itemRow.getString("LOTA18"));
							itemRow.put("LOTA19", itemRow.getString("LOTA19"));
							itemRow.put("LOTA20", itemRow.getString("LOTA20"));
							itemRow.put("AWMSNO", itemRow.getString("AWMSNO"));
							itemRow.put("WGTUNT", itemRow.getString("WGTUNT"));
							
							commonDao.insert(itemRow);
						}catch(Exception e){
							log.debug("error::::::::::::::::::"+e);
						}
						
						log.debug("SHPMTY:::::::::::::::::::::"+row.getString("SHPMTY"));
						if(!row.getString("SHPMTY").toString().equals("299")){
							itemRow.setModuleCommand("WmsOutbound", "IF113N00101");
							commonDao.update(itemRow);
						}
					}
				}
				count++;
				// 헤더 정보 저장.
				if(validationResult.equals("OK")){
					if(row.getString("SHPMTY").toString().equals("299")){
						row.setModuleCommand("WmsOutbound", "IF113STKNUM");
						commonDao.update(row);
					}
					
					if(!row.getString("DRELIN").toString().equals("V")){
						row.put("DRELIN", "V");
						row.setModuleCommand("WmsOutbound", "SHPDH");
						commonDao.update(row);
					}
				}
			}
		}
		
		if(validationCount > 0){
			count = 0;
			throw new Exception();
		}
		
		return count;
	}
	
	@Transactional
	public int assignmentDl01(DataMap map) throws SQLException {
		DataMap head = map.getMap("head").getMap("map");
		List<DataMap> list = map.getList("list");
		
		if(head.getString("SHPMTY").toString().equals("266")){
			head.put("PTRCVR", head.getString("DPTNKY"));
		}
		
		// ownrky 조회
		head.setModuleCommand("WmsOutbound", "OWNRKY");
		String ownrky = (String) commonDao.getObject(head);
			
		head.put("OWNRKY", ownrky);
		head.put("STATDO", "NEW");
		head.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		head.setModuleCommand("WmsOutbound", "SHPDH");
		
		//merge 문
		commonDao.insert(head);
		
		int count = 0;
		DataMap row = new DataMap();
		int itemCount = 0;
		String snum;
		String inum;
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.put("OWNRKY", ownrky);
			row.setModuleCommand("WmsOutbound", "SHPDI");
			row.put("PROGID", "DL01");
			row.put("WAREKY", head.get("WAREKY"));
			row.put("SHPOKY", head.get("SHPOKY"));
			row.put("STATIT", "NEW");
			
			itemCount += 10;
			snum = String.valueOf(itemCount);
			inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
			row.put("SHPOIT", inum);
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			
			try{
				commonDao.insert(row);
			}catch(Exception e){
				log.debug("error :::" + e);
			}
			if(!row.getString("SHPMTY").toString().equals("299")){
				row.setModuleCommand("WmsOutbound", "IF113N00101");
				commonDao.update(row);
			}
			count++;
		}
		
		if(head.getString("SHPMTY").toString().equals("299")){
			head.setModuleCommand("WmsOutbound", "IF113STKNUM");
			commonDao.update(head);
		}
		
		if(!head.getString("DRELIN").toString().equals("V")){
			head.put("DRELIN", "V");
			head.setModuleCommand("WmsOutbound", "SHPDH");
			commonDao.update(head);
			
			if(head.getString("SHPMTY").toString().equals("299")){
				head.setModuleCommand("WmsOutbound", "IF113PROC");
				DataMap procMap = commonDao.getMap(head);
			}
			
			/*head.setModuleCommand("WmsOutbound", "IF313PROC");
			DataMap procSubMap = commonDao.getMap(head);*/
		}
		
		try{
			head.setModuleCommand("WmsOutbound", "BATCHALLOCATION");
			DataMap procSubMap = commonDao.getMap(head);
		}catch(Exception e){
			log.debug("proc error :::"+e);
		}
		
		return count;
	}
	
	@Transactional
	public int assignmentAllDl01(DataMap map) throws SQLException, Exception {
		List<DataMap> head = map.getList("head");
		
		int count = 0;
		DataMap row = new DataMap();
		DataMap itemRow;
		DataMap validationMap = new DataMap();
		String validationResult = "";
		int validationCount = 0;
		DataMap procMap;
		for(int i=0;i<head.size();i++){
			row = head.get(i).getMap("map");
			
			// ownrky 조회
			row.setModuleCommand("WmsOutbound", "OWNRKY");
			String ownrky = (String) commonDao.getObject(row);
			
			if(row.getString("SHPMTY").equals("266")){
				row.put("PTRCVR", row.getString("DPTNKY"));
			}
			
			row.put("OWNRKY", ownrky);
			row.put("STATDO", "NEW");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.setModuleCommand("WmsOutbound", "SHPDH");
			
			commonDao.insert(row);
			count++;
			
			row.setModuleCommand("WmsOutbound", "DL01");
			List<DataMap> itemList =commonDao.getList(row);
			
			int itemCount = 0;
			String snum;
			String inum;
			// item table validation
			for(int j = 0; j < itemList.size(); j++){
				itemRow = new DataMap(itemList.get(j));
				validationMap.put("head", row);
				validationMap.put("list", itemList);
				validationMap.put("key", "SMANDT,SVBELN,SPOSNR,SKUKEY,QTSHPO");
				validationResult = itemValueCheck(validationMap);
				
				if(!validationResult.equals("OK")){
					validationCount++;
					break;
				}else{
					itemRow.put("OWNRKY", ownrky);
					itemRow.setModuleCommand("WmsOutbound", "SHPDI");
					itemRow.put("PROGID", row.getString("PROGID"));
					itemRow.put("WAREKY", row.getString("WAREKY"));
					itemRow.put("SHPOKY", row.getString("SHPOKY"));
					itemRow.put("STATIT", "NEW");
					
					itemCount += 10;
					snum = String.valueOf(itemCount);
					inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
					itemRow.put("SHPOIT", inum);
					itemRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
					
					try{
						itemRow.put("QTSORG", itemRow.getString("QTSORG"));
						itemRow.put("QTSHPO", itemRow.getString("QTSHPO"));
						itemRow.put("QTYREF", itemRow.getString("QTYREF"));
						itemRow.put("QTUALO", itemRow.getString("QTUALO"));
						itemRow.put("QTAPPO", itemRow.getString("QTAPPO"));
						itemRow.put("QTALOC", itemRow.getString("QTALOC"));
						itemRow.put("QTJCMP", itemRow.getString("QTJCMP"));
						itemRow.put("QTSHPD", itemRow.getString("QTSHPD"));
						itemRow.put("QTSHPC", itemRow.getString("QTSHPC"));
						itemRow.put("QTYUOM", itemRow.getString("QTYUOM"));
						itemRow.put("QTPUOM", itemRow.getString("QTPUOM"));
						itemRow.put("QTDUOM", itemRow.getString("QTDUOM"));
						itemRow.put("GRSWGT", itemRow.getString("GRSWGT"));
						itemRow.put("NETWGT", itemRow.getString("NETWGT"));
						itemRow.put("LENGTH", itemRow.getString("LENGTH"));
						itemRow.put("WIDTHW", itemRow.getString("WIDTHW"));
						itemRow.put("HEIGHT", itemRow.getString("HEIGHT"));
						itemRow.put("CUBICM", itemRow.getString("CUBICM"));
						itemRow.put("CAPACT", itemRow.getString("CAPACT"));
						itemRow.put("LOTA16", itemRow.getString("LOTA16"));
						itemRow.put("LOTA17", itemRow.getString("LOTA17"));
						itemRow.put("LOTA18", itemRow.getString("LOTA18"));
						itemRow.put("LOTA19", itemRow.getString("LOTA19"));
						itemRow.put("LOTA20", itemRow.getString("LOTA20"));
						itemRow.put("AWMSNO", itemRow.getString("AWMSNO"));
						itemRow.put("WGTUNT", itemRow.getString("WGTUNT"));
						
						commonDao.insert(itemRow);
					}catch(Exception e){
						log.debug("error::::::::::::::::::"+e);
					}
					
					if(!row.getString("SHPMTY").toString().equals("299")){
						itemRow.setModuleCommand("WmsOutbound", "IF113N00101");
						commonDao.update(itemRow);
					}
				}
			}
			
			// 헤더 정보 저장.
			if(validationResult.equals("OK")){
				if(row.getString("SHPMTY").toString().equals("299")){
					row.setModuleCommand("WmsOutbound", "IF113STKNUM");
					commonDao.update(row);
				}
				
				if(!row.getString("DRELIN").toString().equals("V")){
					row.put("DRELIN", "V");
					row.setModuleCommand("WmsOutbound", "SHPDH");
					commonDao.update(row);
				}
				
				row.setModuleCommand("WmsOutbound", "BATCHALLOCATION");
				procMap = commonDao.getMap(row);
			}
		}
		
		if(validationCount > 0){
			count = 0;
			throw new Exception();
		}
		
		return count;
	}
	
	@Transactional
	public int DL01IndexSelectCheckAssignment(DataMap map) throws SQLException, Exception {
		List<DataMap> head = map.getList("head");
		DataMap focusHead = map.getMap("focusHead").getMap("map");
		List<DataMap> list = map.getList("list");
		String rowHeadIdx = map.get("rowHeadIdx").toString();
		String selRowidx = map.get("arrSelRowIdx").toString();
		
		/**
		 * 선택된 헤드 정보와 아이탬 정보 저장
		 */
		if(focusHead.getString("SHPMTY").toString().equals("266")){
			focusHead.put("PTRCVR", focusHead.getString("DPTNKY"));
		}
		
		// ownrky 조회
		focusHead.setModuleCommand("WmsOutbound", "OWNRKY");
		String ownrky = (String) commonDao.getObject(focusHead);
			
		focusHead.put("OWNRKY", ownrky);
		focusHead.put("STATDO", "NEW");
		focusHead.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		focusHead.setModuleCommand("WmsOutbound", "SHPDH");
		
		commonDao.insert(focusHead);
		
		int count = 0;
		DataMap row = new DataMap();
		int itemCount = 0;
		String snum;
		String inum;
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.put("OWNRKY", ownrky);
			row.setModuleCommand("WmsOutbound", "SHPDI");
			row.put("PROGID", "DL01");
			row.put("WAREKY", focusHead.get("WAREKY"));
			row.put("SHPOKY", focusHead.get("SHPOKY"));
			row.put("STATIT", "NEW");
			
			itemCount += 10;
			snum = String.valueOf(itemCount);
			inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
			row.put("SHPOIT", inum);
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			
			commonDao.insert(row);
			
			if(!row.getString("SHPMTY").toString().equals("299")){
				row.setModuleCommand("WmsOutbound", "IF113N00101");
				commonDao.update(row);
			}
			count++;
		}
		
		if(focusHead.getString("SHPMTY").toString().equals("299")){
			focusHead.setModuleCommand("WmsOutbound", "IF113STKNUM");
			commonDao.update(focusHead);
		}
		
		if(!focusHead.getString("DRELIN").toString().equals("V")){
			focusHead.put("DRELIN", "V");
			focusHead.setModuleCommand("WmsOutbound", "SHPDH");
			commonDao.update(focusHead);
		}
		
		row.setModuleCommand("WmsOutbound", "BATCHALLOCATION");
		DataMap procSubMap = commonDao.getMap(row);
		
		/**
		 * 체크된 헤드 정보 저장.(아이탬 정보 일괄 처리)
		 */
		String[] arrIdx = selRowidx.split(",");
		DataMap itemRow;
		DataMap validationMap = new DataMap();
		String validationResult = "";
		int validationCount = 0;
		
		for(int i=0;i<arrIdx.length;i++){
			// 체크된 row의 index와 선택된 row index가 동일함.
			if(!arrIdx[i].equals(rowHeadIdx)){
				row = head.get(i).getMap("map");
				if(row.getString("SHPMTY").equals("266")){
					row.put("PTRCVR", row.getString("DPTNKY"));
				}
				
				try{
					row.put("OWNRKY", ownrky);
					row.put("STATDO", "NEW");
					row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
					row.setModuleCommand("WmsOutbound", "SHPDH");
		
					commonDao.insert(row);
				}catch(Exception e){
					log.debug("error:::::::::::::::::::::"+e);
				}
				count++;
	
				row.setModuleCommand("WmsOutbound", "DL01");
				List<DataMap> itemList =commonDao.getList(row);
	
				itemCount = 0;
				// item table validation
				for(int j = 0; j < itemList.size(); j++){
					itemRow = new DataMap(itemList.get(j));
					validationMap.put("head", row);
					validationMap.put("list", itemList);
					validationMap.put("key", "SMANDT,SVBELN,SPOSNR,SKUKEY,QTSHPO");
					validationResult = itemValueCheck(validationMap);
					
					if(!validationResult.equals("OK")){
						validationCount++;
						break;
					}else{
						itemRow.put("OWNRKY", ownrky);
						itemRow.setModuleCommand("WmsOutbound", "SHPDI");
						itemRow.put("PROGID", row.getString("PROGID"));
						itemRow.put("WAREKY", row.getString("WAREKY"));
						itemRow.put("SHPOKY", row.getString("SHPOKY"));
						itemRow.put("STATIT", "NEW");
						
						itemCount += 10;
						snum = String.valueOf(itemCount);
						inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
						itemRow.put("SHPOIT", inum);
						itemRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		
						try{
							itemRow.put("QTSORG", itemRow.getString("QTSORG"));
							itemRow.put("QTSHPO", itemRow.getString("QTSHPO"));
							itemRow.put("QTYREF", itemRow.getString("QTYREF"));
							itemRow.put("QTUALO", itemRow.getString("QTUALO"));
							itemRow.put("QTAPPO", itemRow.getString("QTAPPO"));
							itemRow.put("QTALOC", itemRow.getString("QTALOC"));
							itemRow.put("QTJCMP", itemRow.getString("QTJCMP"));
							itemRow.put("QTSHPD", itemRow.getString("QTSHPD"));
							itemRow.put("QTSHPC", itemRow.getString("QTSHPC"));
							itemRow.put("QTYUOM", itemRow.getString("QTYUOM"));
							itemRow.put("QTPUOM", itemRow.getString("QTPUOM"));
							itemRow.put("QTDUOM", itemRow.getString("QTDUOM"));
							itemRow.put("GRSWGT", itemRow.getString("GRSWGT"));
							itemRow.put("NETWGT", itemRow.getString("NETWGT"));
							itemRow.put("LENGTH", itemRow.getString("LENGTH"));
							itemRow.put("WIDTHW", itemRow.getString("WIDTHW"));
							itemRow.put("HEIGHT", itemRow.getString("HEIGHT"));
							itemRow.put("CUBICM", itemRow.getString("CUBICM"));
							itemRow.put("CAPACT", itemRow.getString("CAPACT"));
							itemRow.put("LOTA16", itemRow.getString("LOTA16"));
							itemRow.put("LOTA17", itemRow.getString("LOTA17"));
							itemRow.put("LOTA18", itemRow.getString("LOTA18"));
							itemRow.put("LOTA19", itemRow.getString("LOTA19"));
							itemRow.put("LOTA20", itemRow.getString("LOTA20"));
							itemRow.put("AWMSNO", itemRow.getString("AWMSNO"));
							itemRow.put("WGTUNT", itemRow.getString("WGTUNT"));
						
							commonDao.insert(itemRow);
						}catch(Exception e){
							log.debug("error::::::::::::::::::"+e);
						}
						
						if(!row.getString("SHPMTY").toString().equals("299")){
							itemRow.setModuleCommand("WmsOutbound", "IF113N00101");
							commonDao.update(itemRow);
						}
					}
				}
				count++;
				// 헤더 정보 저장.
				if(validationResult.equals("OK")){
					if(row.getString("SHPMTY").toString().equals("299")){
						row.setModuleCommand("WmsOutbound", "IF113STKNUM");
						commonDao.update(row);
					}
					
					if(!row.getString("DRELIN").toString().equals("V")){
						row.put("DRELIN", "V");
						row.setModuleCommand("WmsOutbound", "SHPDH");
						commonDao.update(row);
					}
					
					row.setModuleCommand("WmsOutbound", "BATCHALLOCATION");
					procSubMap = commonDao.getMap(row);
				}
			}
		}
		
		if(validationCount > 0){
			count = 0;
			throw new Exception();
		}
		
		return count;
	}
	
	@Transactional
	public int DL01OrderDelete(DataMap map) throws SQLException {
		List<DataMap> head = map.getList("head");
		
		int count = 0;
		DataMap row;
		for(int i=0;i<head.size();i++){
			row = head.get(i).getMap("map");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.setModuleCommand("WmsOutbound", "BATCHALLOCATION");
			DataMap procSubMap = commonDao.getMap(row);
			count++;
		}
		
		return count;
	}
	
	@Transactional
	public List DL01Barcode(DataMap map) throws SQLException {
		Map head = map.getMap("head").getMap("map");
		List<DataMap> list = map.getList("list");
		List dataList = new ArrayList();
		
		map.setModuleCommand("WmsOutbound", "BARCODREFDKY");
		DataMap row;
		
		int refdky = -1;
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			
			if(row.getInt("QTSHPO") > 0){
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				
				int count = row.getInt("QTSHPO");
				
				if(count > 0){
					if(refdky == -1){
						refdky = (Integer)commonDao.getObject(map);
					}
					row.setModuleCommand("WmsOutbound", "BARCOD");
					row.put("REFDKY",refdky);
					row.put("WAREKY",head.get("WAREKY"));
					
					if(row.getString("BATMNG").equals("V")){
						for(int j=0;j<count;j++){
							row.put("QTSHPO", "1");
							commonDao.insert(row);
						}
					}else{
						commonDao.insert(row);
					}
					
					row.setModuleCommand("WmsOutbound", "BARCD");
					
					List tmpList = commonDao.getList(row);
					
					dataList.addAll(tmpList);
				}
			}
		}
		
		return dataList;
	}
	
	@Transactional
	public int DL04Assignment(DataMap map) throws SQLException {
		List<DataMap> head = map.getList("head");
		List<DataMap> list = map.getList("list");
		
		int count = 0;
		DataMap row;
		DataMap procMap;
		for(int i=0;i<head.size();i++){
			row = head.get(i).getMap("map");
			row.setModuleCommand("WmsOutbound", "BATCHALLOCATION");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			
			procMap = commonDao.getMap(row);
			
			count++;
		}
		
		return count;
	}
	
	@Transactional
	public int DL04Delete(DataMap map) throws SQLException {
		List<DataMap> head = map.getList("head");
		
		int count = 0;
		DataMap row = new DataMap();
		for(int i=0;i<head.size();i++){
			row = head.get(i).getMap("map");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.setModuleCommand("WmsOutbound", "ALLOCATIONCANCLE");
			commonDao.update(row);
			
			row.setModuleCommand("WmsOutbound", "ALLOCATIONCANCLE");
			commonDao.update(row);
			/*
			row.setModuleCommand("WmsOutbound", "IF313PROC");
			DataMap procSubMap = commonDao.getMap(row);
			
			if(row.getString("SHPMTY").equals("299")){
				row.setModuleCommand("WmsOutbound", "PDELSHPREF");
				DataMap delShpMap = commonDao.getMap(row);
			}
			*/
			row.setModuleCommand("WmsOutbound", "REMOVETASKKY");
			String taskky = (String) commonDao.getObject(row);
			if(taskky != null && !taskky.equals("")){
				row.setModuleCommand("WmsOutbound", "REMOVETASDI");
				row.put("TASKKY", taskky);
				commonDao.delete(row);
				
				row.setModuleCommand("WmsOutbound", "REMOVETASDH");
				commonDao.delete(row);
			}
			
			if(row.getString("SHPMTY").equals("299")){
				
			}else{
				row.setModuleCommand("WmsOutbound", "TKNUMQNTSUB");
				commonDao.update(row);
			}
			
			row.setModuleCommand("WmsOutbound", "SHPDI");
			commonDao.delete(row);
			
			row.setModuleCommand("WmsOutbound", "SHPDH");
			commonDao.delete(row);
			
			count++;
		}
		
		return count;
	}
	
	@Transactional
	public int DL04orderDelete(DataMap map) throws SQLException {
		List<DataMap> head = map.getList("head");
		
		int count = 0;
		DataMap row = new DataMap();
		for(int i=0;i<head.size();i++){
			row = head.get(i).getMap("map");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));

			row.setModuleCommand("WmsOutbound", "REMOVETASKKY");
			String taskky = (String) commonDao.getObject(row);
			if(taskky != null && !taskky.equals("")){
				row.setModuleCommand("WmsOutbound", "REMOVETASDI");
				row.put("TASKKY", taskky);
				commonDao.delete(row);
				
				row.setModuleCommand("WmsOutbound", "REMOVETASDH");
				commonDao.delete(row);
			}
			
			count++;
		}
		
		return count;
	}

	@Transactional
	public int DL04POPSave(DataMap map) throws SQLException {
		
		List<DataMap> list = map.getList("list");
		
		
//	   자바 map 뽑아내기 연습중... by Joseph.Shim  16/11/18		
//		DataMap test = map.getMap("SES_USER_INFO_ID");
//		String tset1 = test.getString("DEPART");
//		String tset2 = map.getMap("SES_USER_INFO_ID").getString("DEPART");
//		String tQty =  list.get(0).getMap("map").getString("QTSALO");
//		
//	    List<ArrayList> arrList = map.getList("SDH_ARRAY");
//	    Object aa = arrList.get(0); 
//		log.debug("*******************"+ tset1);
		
		
		String TASOTY = "210";
		String DOCCAT = "300";
		String STATDO = "NEW";
		
		SimpleDateFormat fmDate = new SimpleDateFormat("yyyyMMdd", Locale.KOREA);
		String date = fmDate.format(new Date());
		SimpleDateFormat fmTime = new SimpleDateFormat("HHmmss", Locale.KOREA);
		String time = fmTime.format(new Date());
		
		String wareky = map.getString("SES_WAREKY");
		String shpoky = map.getString("SHPOKY");
		String shpoit = map.getString("SHPOIT");
		
		
		int count = 1;
		map.put("WAREKY", wareky);
		// 1. SHPDH, SHPDI, TASDI 정보 조회
		map.setModuleCommand("WmsOutbound", "SEARCHSHPDH");
		DataMap shpdhMap = commonDao.getMap(map);
		map.setModuleCommand("WmsOutbound", "SEARCHSHPDI");
		DataMap shpdiMap = commonDao.getMap(map);
		String svbeln = shpdiMap.getString("SVBELN");
		String sposnr = shpdiMap.getString("SPOSNR");
		String stknum = shpdiMap.getString("STKNUM");
		String stpnum = shpdiMap.getString("STPNUM");   
		String ssornu = shpdiMap.getString("SSORNU");
		String ssorit = shpdiMap.getString("SSORIT");
		
		map.setModuleCommand("WmsOutbound", "SEARCHTASDIALL");
		List<DataMap> tasdiList = commonDao.getList(map);
		// 2. 기존의 TASDI ITEM NUMBER MAX 값 조회 
		map.setModuleCommand("WmsOutbound", "SEARCHMAXTASDH");
		List<DataMap> tasdhList = commonDao.getList(map);
			
		DataMap dbData;
		DataMap gridData = new DataMap();
		String webKey = null;
		String dbKey = null;
		int taskit = Integer.parseInt(tasdhList.get(0).getString("TASKIT"));
		
		// 3. tasdi 에서 수정된 item number만 삭제
		for(int i = 0; i<tasdiList.size(); i++){
			dbData = tasdiList.get(i).getMap("map");
			dbKey = dbData.getString("TASKKY") + dbData.getString("TASKIT");
			int dbQTY = Integer.parseInt(dbData.getString("QTTAOR"));
			
			for(int j=0; j<list.size(); j++) {
				gridData = list.get(j).getMap("map");
				webKey = gridData.getString("TASKKY") + gridData.getString("TASKIT");
				int webQTY = Integer.parseInt(gridData.getString("QTSALO")); // 이 수량이 수정해서 입력한수량 QTSALO
				
				if(dbKey.equals(webKey) && (dbQTY != webQTY)){
					map.put("TASKKY", dbData.getString("TASKKY"));
					map.put("TASKIT", dbData.getString("TASKIT"));
					map.setModuleCommand("WmsOutbound", "DL04POPREMOVE");
					commonDao.delete(map);
					break;
				}
			}
		}
			
		// 4. 재고 SELECT하여 Task Order Item/Reference 생성
		DataMap rowData = new DataMap();
		BigDecimal qty, qttaor, qtsiwh = null;
		
		for(DataMap row : list){
			rowData = (DataMap)row.get("map");
			qty = new BigDecimal((String)rowData.get("QTSALO")); // 이 수량이 수정해서 입력한수량 QTSALO
			
			// 4-1 수량이<0 통과
			if(qty.compareTo(BigDecimal.ZERO) <= 0) {
				continue;
			}

			boolean insFlag = false;
			String selectTaskit = "";
			String selectLocation = "";
			// 4-2 TASKKY 있을 때
			for(int i=0; i<tasdiList.size(); i++){
				String dbKey2 = tasdiList.get(i).getMap("map").getString("TASKKY") + tasdiList.get(i).getMap("map").getString("TASKIT");
				String webKey2 =  rowData.getString("TASKKY") + rowData.getString("TASKIT");
				// (1) taskky 있고, 수량 변화 있음
				if(dbKey2.equals(webKey2)){ 
					selectTaskit = tasdiList.get(i).getMap("map").getString("TASKIT");
					selectLocation = tasdiList.get(i).getMap("map").getString("LOCASR");
					if(rowData.getInt("QTSALO") != tasdiList.get(i).getMap("map").getInt("QTTAOR")){
						insFlag = true;
						break;	
					}
				}else if("".equals(webKey2.trim()) && rowData.getInt("QTSALO") > 0 ){//taskky 없고, 수량 변화 있음
					insFlag = true;
					break;
				}
			}
			
			if(insFlag){
				// 재고 셀렉트
				map.setModuleCommand("WmsOutbound", "MANUALALLOCATE_AVAILABLE_STOCK");
				map.put("OWNRKY", rowData.get("OWNRKY"));
				map.put("WAREKY", rowData.get("WAREKY"));
				map.put("AREAKY", rowData.get("AREAKY"));
				map.put("LOCAKY", rowData.get("LOCAKY"));
				map.put("SKUKEY", rowData.get("SKUKEY"));
				map.put("TRNUID", rowData.get("TRNUID"));
				map.put("PACKID", rowData.get("PACKID"));
				map.put("LOTNUM", rowData.get("LOTNUM"));
				map.put("SHPMTY", shpdhMap.get("SHPMTY"));
				List<DataMap> stockMapList = commonDao.getList(map);
				
//				for(DataMap stock : stockMapList){
					if(qty.compareTo(BigDecimal.ZERO) <= 0)
						break;
		
					map.put("TASKKY", tasdhList.get(0).getString("TASKKY"));
					if(rowData.get("LOCAKY").equals(selectLocation)) {
						map.put("TASKIT", leftPad(selectTaskit+"", "0", 6));
					} else {					
						taskit += 10;
						map.put("TASKIT", leftPad(taskit+"", "0", 6));
					}
					map.put("TASKTY", "PK");
					map.put("RSNCOD", "MANU");
					map.put("STATIT", "NEW");
					
//					map.put("QTTAOR", qttaor);
					map.put("QTTAOR", qty);
					
					map.put("QTCOMP", BigDecimal.ZERO);
					map.put("OWNRKY", stockMapList.get(0).get("OWNRKY"));
					map.put("SKUKEY", stockMapList.get(0).get("SKUKEY"));
					map.put("LOTNUM", stockMapList.get(0).get("LOTNUM"));
					map.put("ACTCDT", "000000");
					map.put("ACTCTI", "000000");
//					map.put("QTYUOM", qttaor);
					map.put("QTYUOM", qty);
					map.put("TKFLKY", " ");
					map.put("STEPNO", " ");
					map.put("LSTTFL", " ");
					
					map.put("LOCASR", stockMapList.get(0).get("LOCAKY"));
					map.put("SECTSR", stockMapList.get(0).get("SECTID"));
					map.put("PAIDSR", stockMapList.get(0).get("PACKID"));
					map.put("TRNUSR", stockMapList.get(0).get("TRNUID"));
					map.put("STRUTY", stockMapList.get(0).get("TRUNTY"));
					map.put("SMEAKY", stockMapList.get(0).get("MEASKY"));
					map.put("SUOMKY", stockMapList.get(0).get("UOMKEY"));
					map.put("QTSPUM", stockMapList.get(0).get("QTPUOM"));
					map.put("SDUOKY", stockMapList.get(0).get("DUOMKY"));
					map.put("QTSDUM", stockMapList.get(0).get("QTDUOM"));
					
					map.put("LOCATG", stockMapList.get(0).get("LOCATG"));
					map.put("SECTTG", stockMapList.get(0).get("SECTID"));
					map.put("PAIDTG", stockMapList.get(0).get("PACKID"));
					map.put("TRNUTG", stockMapList.get(0).get("TRNUID"));
					map.put("TTRUTY", stockMapList.get(0).get("TRUNTY"));
					map.put("TMEAKY", stockMapList.get(0).get("MEASKY"));
					map.put("TUOMKY", stockMapList.get(0).get("UOMKEY"));
					map.put("QTTPUM", stockMapList.get(0).get("QTPUOM"));
					map.put("TDUOKY", stockMapList.get(0).get("DUOMKY"));
					map.put("QTTDUM", stockMapList.get(0).get("QTDUOM"));
					
					map.put("LOCAAC", " ");
					map.put("SECTAC", stockMapList.get(0).get(" "));
					map.put("PAIDAC", stockMapList.get(0).get(" "));
					map.put("TRNUAC", stockMapList.get(0).get(" "));
					map.put("ATRUTY", stockMapList.get(0).get(" "));
					map.put("AMEAKY", stockMapList.get(0).get(" "));
					map.put("AUOMKY", stockMapList.get(0).get(" "));
					map.put("QTAPUM", stockMapList.get(0).get("1"));
					map.put("ADUOKY", stockMapList.get(0).get(" "));
					map.put("QTADUM", stockMapList.get(0).get("1"));
					map.put("REFDKY", shpoky);
					map.put("REFDIT", shpoit);
					map.put("REFCAT", "200");
					map.put("REFDAT", date);
					map.put("PURCKY", stockMapList.get(0).get("PURCKY"));
					map.put("PURCIT", stockMapList.get(0).get("PURCIT"));
					map.put("ASNDKY", stockMapList.get(0).get("ASNDKY"));
					map.put("ASNDIT", stockMapList.get(0).get("ASNDIT"));
					map.put("RECVKY", stockMapList.get(0).get("RECVKY"));
					map.put("RECVIT", stockMapList.get(0).get("RECVIT"));
					map.put("SHPOKY", shpoky);
					map.put("SHPOIT", shpoit);
					map.put("GRPOKY", " ");
					map.put("GRPOIT", " ");
					map.put("SADJKY", stockMapList.get(0).get("SADJKY"));
					map.put("SADJIT", stockMapList.get(0).get("SADJIT"));
					map.put("SDIFKY", " ");
					map.put("SDIFIT", " ");
					map.put("PHYIKY", stockMapList.get(0).get("PHYIKY"));
					map.put("PHYIIT", stockMapList.get(0).get("PHYIIT"));
					map.put("DROPID", " ");
					map.put("DESC01", stockMapList.get(0).get("DESC01"));
					map.put("DESC02", stockMapList.get(0).get("DESC02"));
					map.put("ASKU01", stockMapList.get(0).get("ASKU01"));
					map.put("ASKU02", stockMapList.get(0).get("ASKU02"));
					map.put("ASKU03", stockMapList.get(0).get("ASKU03"));
					map.put("ASKU04", stockMapList.get(0).get("ASKU04"));
					map.put("ASKU05", stockMapList.get(0).get("ASKU05"));
					map.put("EANCOD", stockMapList.get(0).get("EANCOD"));
					map.put("GTINCD", stockMapList.get(0).get("GTINCD"));
					map.put("SKUG01", stockMapList.get(0).get("SKUG01"));
					map.put("SKUG02", stockMapList.get(0).get("SKUG02"));
					map.put("SKUG03", stockMapList.get(0).get("SKUG03"));
					map.put("SKUG04", stockMapList.get(0).get("SKUG04"));
					map.put("SKUG05", stockMapList.get(0).get("SKUG05"));
					map.put("GRSWGT", stockMapList.get(0).get("GRSWGT"));
					map.put("NETWGT", stockMapList.get(0).get("NETWGT"));
					map.put("WGTUNT", stockMapList.get(0).get("WGTUNT"));
					map.put("LENGTH", stockMapList.get(0).get("LENGTH"));
					map.put("WIDTHW", stockMapList.get(0).get("WIDTHW"));
					map.put("HEIGHT", stockMapList.get(0).get("HEIGHT"));
					map.put("CUBICM", stockMapList.get(0).get("CUBICM"));
					map.put("CAPACT", stockMapList.get(0).get("CAPACT"));
					map.put("WORKID", " ");
					map.put("WORKNM", " ");
					map.put("HHTTID", " ");
					map.put("AREAKY", stockMapList.get(0).get("AREAKY"));
					map.put("LOTA01", stockMapList.get(0).get("LOTA01"));
					map.put("LOTA02", stockMapList.get(0).get("LOTA02"));
					map.put("LOTA03", stockMapList.get(0).get("LOTA03"));
					map.put("LOTA04", stockMapList.get(0).get("LOTA04"));
					map.put("LOTA05", stockMapList.get(0).get("LOTA05"));
					map.put("LOTA06", stockMapList.get(0).get("LOTA06"));
					map.put("LOTA07", stockMapList.get(0).get("LOTA07"));
					map.put("LOTA08", stockMapList.get(0).get("LOTA08"));
					map.put("LOTA09", stockMapList.get(0).get("LOTA09"));
					map.put("LOTA10", stockMapList.get(0).get("LOTA10"));
					map.put("LOTA11", stockMapList.get(0).get("LOTA11"));
					map.put("LOTA12", stockMapList.get(0).get("LOTA12"));
					map.put("LOTA13", stockMapList.get(0).get("LOTA13"));
					map.put("LOTA14", stockMapList.get(0).get("LOTA14"));
					map.put("LOTA15", stockMapList.get(0).get("LOTA15"));
					map.put("LOTA16", stockMapList.get(0).get("LOTA16"));
					map.put("LOTA17", stockMapList.get(0).get("LOTA17"));
					map.put("LOTA18", stockMapList.get(0).get("LOTA18"));
					map.put("LOTA19", stockMapList.get(0).get("LOTA19"));
					map.put("LOTA20", stockMapList.get(0).get("LOTA20"));
					map.put("AWMSNO", " ");
					map.put("AWMSTS", " ");
					map.put("SMANDT", stockMapList.get(0).get("SMANDT"));
					map.put("SEBELN", stockMapList.get(0).get("SEBELN"));
					map.put("SEBELP", stockMapList.get(0).get("SEBELP"));
					map.put("SZMBLNO",stockMapList.get(0).get("SZMBLNO"));
					map.put("SZMIPNO",stockMapList.get(0).get("SZMIPNO"));
					map.put("STRAID", stockMapList.get(0).get("STRAID"));
					map.put("SVBELN", svbeln);
					map.put("SPOSNR", sposnr);
					map.put("STKNUM", stknum);
					map.put("STPNUM", stpnum);
					map.put("SWERKS", stockMapList.get(0).get("SWERKS"));
					map.put("SLGORT", stockMapList.get(0).get("SLGORT"));
					map.put("SDATBG", stockMapList.get(0).get("SDATBG"));
					map.put("STDLNR", stockMapList.get(0).get("STDLNR"));
					map.put("SSORNU", ssornu);
					map.put("SSORIT", ssorit);
					map.put("SMBLNR", stockMapList.get(0).get("SMBLNR"));
					map.put("SZEILE", stockMapList.get(0).get("SZEILE"));
					map.put("SMJAHR", stockMapList.get(0).get("SMJAHR"));
					map.put("SXBLNR", stockMapList.get(0).get("SXBLNR"));
					map.put("SAPSTS", stockMapList.get(0).get("SAPSTS"));
					map.put("DOORKY", " ");
					map.put("PTLT01", stockMapList.get(0).get("LOTA01"));
					map.put("PTLT02", stockMapList.get(0).get("LOTA02"));
					map.put("PTLT03", stockMapList.get(0).get("LOTA03"));
					map.put("PTLT04", stockMapList.get(0).get("LOTA04"));
					map.put("PTLT05", stockMapList.get(0).get("LOTA05"));
					map.put("PTLT06", stockMapList.get(0).get("LOTA06"));
					map.put("PTLT07", stockMapList.get(0).get("LOTA07"));
					map.put("PTLT08", stockMapList.get(0).get("LOTA08"));
					map.put("PTLT09", stockMapList.get(0).get("LOTA09"));
					map.put("PTLT10", stockMapList.get(0).get("LOTA10"));
					map.put("PTLT11", stockMapList.get(0).get("LOTA11"));
					map.put("PTLT12", stockMapList.get(0).get("LOTA12"));
					map.put("PTLT13", stockMapList.get(0).get("LOTA13"));
					map.put("PTLT14", stockMapList.get(0).get("LOTA14"));
					map.put("PTLT15", stockMapList.get(0).get("LOTA15"));
					map.put("PTLT16", stockMapList.get(0).get("LOTA16"));
					map.put("PTLT17", stockMapList.get(0).get("LOTA17"));
					map.put("PTLT18", stockMapList.get(0).get("LOTA18"));
					map.put("PTLT19", stockMapList.get(0).get("LOTA19"));
					map.put("PTLT20", stockMapList.get(0).get("LOTA20"));
					map.put("PASTKY", " ");
					map.put("ALSTKY", " ");
					map.put("SBKTXT", " ");
					map.put("TASRSN", " ");
					map.put("CREDAT", date);
					map.put("CRETIM", time);
					map.put("CREUSR", CommonConfig.SES_USER_ID_KEY);
					map.put("LMODAT", date);
					map.put("LMOTIM", time);
					map.put("LMOUSR", CommonConfig.SES_USER_ID_KEY);
					map.put("INDBZL", " ");
					map.put("INDARC", " ");
					map.put("UPDCHK", "0");
					
//					map.put("TASKKY", tasdhList.get(0).getString("TASKKY"));
//					map.put("TASKIT", leftPad(taskit+"", "0", 6));
//					map.put("TASKIR", "0001");
//					map.put("STOKKY", stock.get("STOKKY"));
//					map.put("QTSTKM", qttaor);
//					map.put("QTSTKC", BigDecimal.ZERO);
//					map.put("CREDAT", date);
//					map.put("CRETIM", time);
//					map.put("CREUSR", CommonConfig.SES_USER_ID_KEY);
//					map.put("LMODAT", date);
//					map.put("LMOTIM", time);
//					map.put("LMOUSR", CommonConfig.SES_USER_ID_KEY);
//					map.put("INDBZL", " ");
//					map.put("INDARC", " ");
//					map.put("UPDCHK", "0");
//					
					map.setModuleCommand("WmsOutbound", "TASDI");
					commonDao.insert(map);
					
					map.setModuleCommand("WmsOutbound", "TASDR_PROCALL");
					commonDao.getMap(map);

//				} //재고넣기 for문				
//				if(qty.compareTo(BigDecimal.ZERO) > 0){
//					throw new SQLException("재고가 부족하여 할당할 수 없습니다.");
//				}
			}//if(insflag)문	
		} //isnert for문
		
		return count;
	}
	
	@Transactional
	public int TM04Delete(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("head");
		
		int count = 0;
		DataMap row = new DataMap();
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			
			row.setModuleCommand("WmsOutbound", "TM04IFWMS");
			commonDao.delete(row);
			
			count++;
		}
		
		return count;
	}
	
	@Transactional
	public String validatePikingSave(DataMap map) throws SQLException {
		String result = "OK";
		
		int headModifyIndex = -1;
		List<DataMap> itemList = null;
		if(map.containsKey("headModifyIndex")){
			headModifyIndex = map.getInt("headModifyIndex");
			itemList = map.getList("list");
		}
		
		List<DataMap> headList = map.getList("headList");
		
		DataMap row;
		DataMap rsMap;

		List<DataMap> paramItemList = new ArrayList<DataMap>();
		DataMap copy = new DataMap();
		DataMap paramItemMap = new DataMap();
		DataMap paramLocMap = new DataMap();
		
		
		for(int i=0;i<headList.size();i++){			
			if(map.containsKey("param")){
				row = new DataMap(map.getMap("param").getMap("map"));
			}else{
				row = new DataMap();
			}				
			
			map.clonSessionData(row);
			row.append(headList.get(i).getMap("map"));
			paramItemList = new ArrayList<DataMap>();
			
			if(headModifyIndex == i){	
				for(int j=0;j<itemList.size();j++){
					copy = new DataMap(itemList.get(j).getMap("map"));
					paramItemList.add(copy);
				}
			}else{
				row.setModuleCommand("WmsTask", "TASDI");
				row.put("QTY_COPY", "Y");
				List<DataMap> tasdiList = commonDao.getList(row);
				for(int j = 0; j < tasdiList.size(); j++){
					copy = new DataMap(tasdiList.get(j));
					paramItemList.add(copy);
				}
			}
			
			// 2012.10.27 by GOKU - 오더컨펌이 되지 않은 Shipment의 피킹 완료는 할 수 없다.
			/*
			if("210".equals(row.getString("TASOTY"))    ||  "208".equals(row.getString("TASOTY")) ){
				row.setModuleCommand("WmsTask", "SHPDHDRELIN");
				rsMap = commonDao.getMap(row);
				
				if(!rsMap.get("DRELIN").toString().equals("V")){
					result = "TASK_M0034 "+ row.getString("TASKKY");
					return result;
				}
			}
			*/
			
			for(int j = 0; j < paramItemList.size(); j++){
				paramItemMap = paramItemList.get(j);
				map.clonSessionData(paramItemMap);
				
				// 이미 confirm 되었는지 검사
				if (!"00000000".equals(paramItemMap.getString("ACTCDT")) && !"".equals(paramItemMap.getString("ACTCDT"))) {
					result = "TASK_M0009 "+ row.getString("TASKKY");
					return result;
				}
				
				// 출발지번이 자동창고면 에러
				if ("V".equals(paramItemMap.getString("AUTLOC"))) {
					result = "TASK_M0018 "+ row.getString("LOCAAC");
					return result;
				}
				
				//Location 검사LocationPK locPK = new LocationPK();
				paramLocMap = new DataMap();
				paramLocMap.put("WAREKY",  "330".equals(row.getString("330"))  ? row.getString("WARETG") : paramItemMap.getString("WAREKY"));
				paramLocMap.put("LOCAKY", paramItemMap.getString("LOCAAC"));
				paramLocMap.setModuleCommand("WmsAdmin", "LOCMA");
	
				rsMap = commonDao.getMap(paramLocMap);
				
				if (rsMap == null) {
					result = "MASTER_M0507 "+ row.getString("LOCAAC");
					return result;
				}
				
				// 도착지번이 자동창고면 에러
				if ("V".equals(rsMap.getString("AUTLOC"))) {
					result = "TASK_M0024 "+ row.getString("LOCAAC");
					return result;
				}
				
				if("310".equals(row.getString("TASOTY")) && ( "SETLOC".equals(paramItemMap.getString("LOCACC")) || "RTNLOC".equals(paramItemMap.getString("LOCACC"))  ||  "SCRLOC".equals(paramItemMap.getString("LOCACC")))){
					result = "TASK_M0035 "+ row.getString("LOCAAC");
					return result;
				}
				
			}
			
		}
		
		return result;
	}
	
	@Transactional
	public String DL06StockValidation(DataMap map) throws SQLException {
		String result = "OK";
		
		StringBuffer sb = new StringBuffer();	
		List<DataMap> itemList = map.getList("list");
		DataMap rowInfo = map.getMap("headData");
	
		for(DataMap item : itemList){
		    	if(sb.length() > 0)
				sb.append(" UNION ALL\n ");
		    	
				sb.append(" SELECT '").append(item.getMap("map").get("WAREKY")).append("' AS WAREKY, ");
				sb.append("        '").append(item.getMap("map").get("LOTNUM")).append("' AS LOTNUM, ");
				sb.append("        '").append(item.getMap("map").get("LOCAKY")).append("' AS LOCAKY, ");
				sb.append("        '").append(item.getMap("map").get("TRNUID")).append("' AS TRNUID, ");
				sb.append("        '").append(item.getMap("map").get("PACKID")).append("' AS PACKID, ");
				sb.append("        '").append(rowInfo.get("TASKKY")).append("' AS TASKKY, ");
				sb.append("        '").append(rowInfo.get("TASKIT")).append("' AS TASKIT, ");
				sb.append("        '").append(item.getMap("map").get("QTSPUT")).append("' AS QTTAOR FROM DUAL ");
		}
		
		map.setModuleCommand("WmsOutbound", "DL06_STOCK"); // 쿼리키값 넣을것
		map.put("APPEND_QUERY", sb.toString());
		
		List<DataMap> validList = commonDao.getValidation(map);
		if(validList.size() > 0){
			DataMap valid = validList.get(0);
			return valid.getString("RESULTMSG");
		}
		
		//[2021.07.08] Modify junghyojin - 수정된 행 할당전략키에 해당하는지 체크하여 메세지 처리
		DataMap row = new DataMap();
		String rowState = "";
		StringBuffer sbupd = new StringBuffer();	
		for(int j=0;j<itemList.size();j++){
			row = itemList.get(j).getMap("map");
			rowState = row.getString(CommonConfig.GRID_ROW_STATE_ATT);
			if( rowState.charAt(0)  == 'U' && row.getMap("map").getInt("QTSPUT") > 0){ //수량 변화 있음
				if(sbupd.length() > 0)
				sbupd.append(" UNION ALL\n ");
				
				sbupd.append(" SELECT '").append(row.getMap("map").get("WAREKY")).append("' AS WAREKY, ");
				sbupd.append("        '").append(row.getMap("map").get("LOTNUM")).append("' AS LOTNUM, ");
				sbupd.append("        '").append(row.getMap("map").get("LOCAKY")).append("' AS LOCAKY, ");
				sbupd.append("        '").append(row.getMap("map").get("TRNUID")).append("' AS TRNUID, ");
				sbupd.append("        '").append(row.getMap("map").get("PACKID")).append("' AS PACKID, ");
				sbupd.append("        '").append(rowInfo.get("ALSTKY")).append("' AS ALSTKY FROM DUAL ");	
			}
		}
		
		map.setModuleCommand("WmsOutbound", "DL06_ALSTKY"); 
		map.put("APPEND_QUERY", sbupd.toString());
		List<DataMap> validAlstkyList = commonDao.getValidation(map);
		
		if(validAlstkyList.size() > 0){
			DataMap valid = validAlstkyList.get(0);
			return valid.getString("RESULTMSG");
		}
		return result;
	}
	
	
	/*@Transactional
	public int DL06PikingSave(DataMap map) throws SQLException {
		int headModifyIndex = -1;
		List<DataMap> itemList = null;
		if(map.containsKey("headModifyIndex")){
			headModifyIndex = map.getInt("headModifyIndex");
			itemList = map.getList("list");
		}
		
		List<DataMap> headList = map.getList("headList");
		
		DataMap row;
		int count = 0;

		List<DataMap> paramItemList = new ArrayList<DataMap>();
		DataMap paramItemMap = new DataMap();
		DataMap paramTasdrMap = new DataMap();
		DataMap copy = new DataMap();
		
		for(int i=0;i<headList.size();i++){			
			if(map.containsKey("param")){
				row = new DataMap(map.getMap("param").getMap("map"));
			}else{
				row = new DataMap();
			}				
			
			map.clonSessionData(row);
			row.append(headList.get(i).getMap("map"));
			paramItemList = new ArrayList<DataMap>();
			
			if(headModifyIndex == i){	
				for(int j=0;j<itemList.size();j++){
					copy = new DataMap(itemList.get(j).getMap("map"));
					paramItemList.add(copy);
				}
			}else{
				row.setModuleCommand("WmsTask", "TASDI");
				row.put("QTY_COPY", "Y");
				List<DataMap> tasdiList = commonDao.getList(row);			
				for(int j = 0; j < tasdiList.size(); j++){
					copy = new DataMap(tasdiList.get(j));
					paramItemList.add(copy);
				}
			}


			//insert
			for(int j = 0; j < paramItemList.size(); j++){
				paramItemMap = paramItemList.get(j);

				//remove
				paramItemMap.setModuleCommand("WmsTask", "TASDIDEL");
				commonDao.delete(paramItemMap);
				
				
				paramItemMap.setModuleCommand("WmsTask", "TASDIEND");
				paramItemMap.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));

				// "FPC" 작업수량 = 작업완료수량  
				// "PPC" 작업수량 > 작업완료수량
				// "OPC" 작업수량 < 작업완료수량 
				int STAUES = Integer.parseInt(paramItemMap.getString("QTTAOR") )- Integer.parseInt(paramItemMap.getString("QTCOMP"));
				if (STAUES == 0) {
					paramItemMap.put("STATIT","FPC");
				} else if (STAUES == 1) {
					paramItemMap.put("STATIT","PPC");
				} else if (STAUES == -1) {
					paramItemMap.put("STATIT","OPC");
				}
				commonDao.insert(paramItemMap);
				


				paramItemMap.put("ERRNUM",0);
				paramItemMap.put("ERRMSG", "");
				paramItemMap.setModuleCommand("WmsOutbound", "SZPINSTASDR");		
				commonDao.update(paramItemMap);
				
			}
			count++;
		}
		
		return count;	
	}*/
	
	@Transactional
	public DataMap DL06POPQTUALOCNT(DataMap map) throws SQLException {
		DataMap data = map.getMap("data");
		data.setModuleCommand("WmsOutbound", "DL06POP_QTUALOCNT");
		DataMap rsMap = commonDao.getMap(data);

		return rsMap;
	}
	
	@Transactional
	public DataMap DL06POPQTSWRKCNT(DataMap map) throws SQLException {
		DataMap data = new DataMap();
		data.put("TASKKY", map.get("TASKKY"));
		data.setModuleCommand("WmsOutbound", "DL06POP_QTSWRKCNT");
		List<DataMap> list = commonDao.getList(data);
		DataMap rsMap = new DataMap();
		rsMap.put("list", list);
		
		return rsMap;
	}
	
	@Transactional
	public int DL06POPSave(DataMap map) throws SQLException {
		
		List<DataMap> list = map.getList("list");
	
		String TASOTY = "210";
		String DOCCAT = "300";
		String STATDO = "NEW";
		
		SimpleDateFormat fmDate = new SimpleDateFormat("yyyyMMdd", Locale.KOREA);
		String date = fmDate.format(new Date());
		SimpleDateFormat fmTime = new SimpleDateFormat("HHmmss", Locale.KOREA);
		String time = fmTime.format(new Date());
		
		String wareky = map.getString("SES_WAREKY");
		String shpoky = map.getString("SHPOKY");
		String shpoit = map.getString("SHPOIT");
		
		int count = 1;
		map.put("WAREKY", wareky);
		map.put("SHPOKY", shpoky);
		map.put("SHPOIT", shpoit);
		// 1. SHPDH, SHPDI, TASDI 정보 조회
		map.setModuleCommand("WmsOutbound", "SEARCHSHPDH");
		DataMap shpdhMap = commonDao.getMap(map);
		map.setModuleCommand("WmsOutbound", "SEARCHSHPDI");
		DataMap shpdiMap = commonDao.getMap(map);
		String svbeln = shpdiMap.getString("SVBELN");
		String sposnr = shpdiMap.getString("SPOSNR");
		String stknum = shpdiMap.getString("STKNUM");
		String stpnum = shpdiMap.getString("STPNUM");
		String ssornu = shpdiMap.getString("SSORNU");
		String ssorit = shpdiMap.getString("SSORIT");
		
		map.setModuleCommand("WmsOutbound", "SEARCHTASDIALL");
		List<DataMap> tasdiList = commonDao.getList(map);
		// 2. 기존의 TASDI ITEM NUMBER MAX 값 조회 
		map.setModuleCommand("WmsOutbound", "SEARCHMAXTASDH");
		List<DataMap> tasdhList = commonDao.getList(map);
			
		DataMap dbData;
		DataMap gridData = new DataMap();
		String webKey = null;
		String dbKey = null;
		int taskit = Integer.parseInt(tasdhList.get(0).getString("TASKIT"));
		
		// 3. tasdi 에서 수정된 item number만 삭제
		for(int i = 0; i<tasdiList.size(); i++){
			dbData = tasdiList.get(i).getMap("map");
			//dbKey = dbData.getString("TASKKY") + dbData.getString("TASKIT");
			dbKey = dbData.getString("TASKKY") + dbData.getString("TASKIT") + dbData.getString("LOTNUM")+dbData.getString("LOCASR");
			int dbQTY = Integer.parseInt(dbData.getString("QTTAOR"));
			
			for(int j=0; j<list.size(); j++) {
				gridData = list.get(j).getMap("map");
				//webKey = gridData.getString("TASKKY") + gridData.getString("TASKIT");
				webKey = gridData.getString("TASKKY") + gridData.getString("TASKIT") + gridData.getString("LOTNUM")+gridData.getString("LOCAKY");
				int webQTY = Integer.parseInt(gridData.getString("QTSPUT"));
				
				if(dbKey.equals(webKey) && (dbQTY != webQTY)){
					map.put("TASKKY", dbData.getString("TASKKY"));
					map.put("TASKIT", dbData.getString("TASKIT"));
					map.setModuleCommand("WmsOutbound", "DL06POPREMOVE");
					commonDao.delete(map);
					break;
				}
			}
		}
			
		// 4. 재고 SELECT하여 Task Order Item/Reference 생성
		DataMap rowData = new DataMap();
		BigDecimal qty, qttaor, qtsiwh = null;
		
		for(DataMap row : list){
			rowData = (DataMap)row.get("map");
			qty = new BigDecimal((String)rowData.get("QTSPUT"));
			
			// 4-1 수량이<0 통과
			if(qty.compareTo(BigDecimal.ZERO) <= 0)
				continue;

			boolean insFlag = false;
			String selectTaskit = "";
			String selectLocation = "";
			String selectLotnum = "";
			// 4-2 TASKKY 있을 때
			for(int i=0; i<tasdiList.size(); i++){
				String dbKey2 = tasdiList.get(i).getMap("map").getString("TASKKY") + tasdiList.get(i).getMap("map").getString("TASKIT");
				String webKey2 =  rowData.getString("TASKKY") + rowData.getString("TASKIT");
				// (1) taskky 있고, 수량 변화 있음
				if(dbKey2.equals(webKey2)){ 
					selectTaskit = tasdiList.get(i).getMap("map").getString("TASKIT");
					selectLocation = tasdiList.get(i).getMap("map").getString("LOCASR");
					selectLotnum = tasdiList.get(i).getMap("map").getString("LOTNUM");
					// 다른로케이션에서 수량도 달라진경우 + 같은 로케이션에서 수량이 달라진경우
					if(rowData.getInt("QTSPUT") != tasdiList.get(i).getMap("map").getInt("QTTAOR")){
						insFlag = true;
						break;	
					}
					// 수량같은데 그 수량 통째로 다른로케이션에 들어간경우
					if(!rowData.getString("LOCAKY").equals(tasdiList.get(i).getMap("map").getString("LOCASR"))) {
						insFlag = true;
						break;	
					}
					
					// 수량은 통째로 같은 로케이션 다른 롯트넘버
					if(rowData.getString("LOCAKY").equals(tasdiList.get(i).getMap("map").getString("LOCASR")) && 
							!rowData.getString("LOTNUM").equals(tasdiList.get(i).getMap("map").getString("LOTNUM"))) {
						insFlag = true;
						break;	
					}
				}else if("".equals(webKey2.trim()) && rowData.getInt("QTSPUT") > 0 ){//taskky 없고, 수량 변화 있음
					insFlag = true;
					break;
				}
			}
			
			if(insFlag){
				// 재고 셀렉트
				map.setModuleCommand("WmsOutbound", "MANUALALLOCATE_AVAILABLE_STOCK");
				map.put("OWNRKY", rowData.get("OWNRKY"));
				map.put("WAREKY", rowData.get("WAREKY"));
				map.put("AREAKY", rowData.get("AREAKY"));
				map.put("LOCAKY", rowData.get("LOCAKY"));
				map.put("SKUKEY", rowData.get("SKUKEY"));
				map.put("TRNUID", rowData.get("TRNUID"));
				map.put("PACKID", rowData.get("PACKID"));
				map.put("LOTNUM", rowData.get("LOTNUM"));
				map.put("SHPMTY", shpdhMap.get("SHPMTY"));
				List<DataMap> stockMapList = commonDao.getList(map);
				
				if(qty.compareTo(BigDecimal.ZERO) <= 0) {
					break;
				}
				
				map.put("TASKKY", tasdhList.get(0).getString("TASKKY"));
				if(rowData.get("LOCAKY").equals(selectLocation) && rowData.get("LOTNUM").equals(selectLotnum)) {
					map.put("TASKIT", leftPad(selectTaskit+"", "0", 6));
				} else {					
					taskit += 10;
					map.put("TASKIT", leftPad(taskit+"", "0", 6));
				}
				map.put("TASKTY", "PK");
				map.put("RSNCOD", "MANU");
				map.put("STATIT", "NEW");
				map.put("QTTAOR", qty);
				map.put("QTCOMP", BigDecimal.ZERO);
				map.put("OWNRKY", stockMapList.get(0).get("OWNRKY"));
				map.put("SKUKEY", stockMapList.get(0).get("SKUKEY"));
				map.put("LOTNUM", stockMapList.get(0).get("LOTNUM"));
				map.put("ACTCDT", "000000");
				map.put("ACTCTI", "000000");
				map.put("QTYUOM", qty);
				map.put("TKFLKY", " ");
				map.put("STEPNO", " ");
				map.put("LSTTFL", " ");
				
				map.put("LOCASR", stockMapList.get(0).get("LOCAKY"));
				map.put("SECTSR", stockMapList.get(0).get("SECTID"));
				map.put("PAIDSR", stockMapList.get(0).get("PACKID"));
				map.put("TRNUSR", stockMapList.get(0).get("TRNUID"));
				map.put("STRUTY", stockMapList.get(0).get("TRUNTY"));
				map.put("SMEAKY", stockMapList.get(0).get("MEASKY"));
				map.put("SUOMKY", stockMapList.get(0).get("UOMKEY"));
				map.put("QTSPUM", stockMapList.get(0).get("QTPUOM"));
				map.put("SDUOKY", stockMapList.get(0).get("DUOMKY"));
				map.put("QTSDUM", stockMapList.get(0).get("QTDUOM"));
				
				map.put("LOCATG", stockMapList.get(0).get("LOCATG"));
				map.put("SECTTG", stockMapList.get(0).get("SECTID"));
				map.put("PAIDTG", stockMapList.get(0).get("PACKID"));
				map.put("TRNUTG", stockMapList.get(0).get("TRNUID"));
				map.put("TTRUTY", stockMapList.get(0).get("TRUNTY"));
				map.put("TMEAKY", stockMapList.get(0).get("MEASKY"));
				map.put("TUOMKY", stockMapList.get(0).get("UOMKEY"));
				map.put("QTTPUM", stockMapList.get(0).get("QTPUOM"));
				map.put("TDUOKY", stockMapList.get(0).get("DUOMKY"));
				map.put("QTTDUM", stockMapList.get(0).get("QTDUOM"));
				
				map.put("LOCAAC", " ");
				map.put("SECTAC", stockMapList.get(0).get(" "));
				map.put("PAIDAC", stockMapList.get(0).get(" "));
				map.put("TRNUAC", stockMapList.get(0).get(" "));
				map.put("ATRUTY", stockMapList.get(0).get(" "));
				map.put("AMEAKY", stockMapList.get(0).get(" "));
				map.put("AUOMKY", stockMapList.get(0).get(" "));
				map.put("QTAPUM", stockMapList.get(0).get("1"));
				map.put("ADUOKY", stockMapList.get(0).get(" "));
				map.put("QTADUM", stockMapList.get(0).get("1"));
				map.put("REFDKY", shpoky);
				map.put("REFDIT", shpoit);
				map.put("REFCAT", "200");
				map.put("REFDAT", date);
				map.put("PURCKY", stockMapList.get(0).get("PURCKY"));
				map.put("PURCIT", stockMapList.get(0).get("PURCIT"));
				map.put("ASNDKY", stockMapList.get(0).get("ASNDKY"));
				map.put("ASNDIT", stockMapList.get(0).get("ASNDIT"));
				map.put("RECVKY", stockMapList.get(0).get("RECVKY"));
				map.put("RECVIT", stockMapList.get(0).get("RECVIT"));
				map.put("SHPOKY", shpoky);
				map.put("SHPOIT", shpoit);
				map.put("GRPOKY", " ");
				map.put("GRPOIT", " ");
				map.put("SADJKY", stockMapList.get(0).get("SADJKY"));
				map.put("SADJIT", stockMapList.get(0).get("SADJIT"));
				map.put("SDIFKY", " ");
				map.put("SDIFIT", " ");
				map.put("PHYIKY", stockMapList.get(0).get("PHYIKY"));
				map.put("PHYIIT", stockMapList.get(0).get("PHYIIT"));
				map.put("DROPID", " ");
				map.put("DESC01", stockMapList.get(0).get("DESC01"));
				map.put("DESC02", stockMapList.get(0).get("DESC02"));
				map.put("ASKU01", stockMapList.get(0).get("ASKU01"));
				map.put("ASKU02", stockMapList.get(0).get("ASKU02"));
				map.put("ASKU03", stockMapList.get(0).get("ASKU03"));
				map.put("ASKU04", stockMapList.get(0).get("ASKU04"));
				map.put("ASKU05", stockMapList.get(0).get("ASKU05"));
				map.put("EANCOD", stockMapList.get(0).get("EANCOD"));
				map.put("GTINCD", stockMapList.get(0).get("GTINCD"));
				map.put("SKUG01", stockMapList.get(0).get("SKUG01"));
				map.put("SKUG02", stockMapList.get(0).get("SKUG02"));
				map.put("SKUG03", stockMapList.get(0).get("SKUG03"));
				map.put("SKUG04", stockMapList.get(0).get("SKUG04"));
				map.put("SKUG05", stockMapList.get(0).get("SKUG05"));
				map.put("GRSWGT", stockMapList.get(0).get("GRSWGT"));
				map.put("NETWGT", stockMapList.get(0).get("NETWGT"));
				map.put("WGTUNT", stockMapList.get(0).get("WGTUNT"));
				map.put("LENGTH", stockMapList.get(0).get("LENGTH"));
				map.put("WIDTHW", stockMapList.get(0).get("WIDTHW"));
				map.put("HEIGHT", stockMapList.get(0).get("HEIGHT"));
				map.put("CUBICM", stockMapList.get(0).get("CUBICM"));
				map.put("CAPACT", stockMapList.get(0).get("CAPACT"));
				map.put("WORKID", " ");
				map.put("WORKNM", " ");
				map.put("HHTTID", " ");
				map.put("AREAKY", stockMapList.get(0).get("AREAKY"));
				map.put("LOTA01", stockMapList.get(0).get("LOTA01"));
				map.put("LOTA02", stockMapList.get(0).get("LOTA02"));
				map.put("LOTA03", stockMapList.get(0).get("LOTA03"));
				map.put("LOTA04", stockMapList.get(0).get("LOTA04"));
				map.put("LOTA05", stockMapList.get(0).get("LOTA05"));
				map.put("LOTA06", stockMapList.get(0).get("LOTA06"));
				map.put("LOTA07", stockMapList.get(0).get("LOTA07"));
				map.put("LOTA08", stockMapList.get(0).get("LOTA08"));
				map.put("LOTA09", stockMapList.get(0).get("LOTA09"));
				map.put("LOTA10", stockMapList.get(0).get("LOTA10"));
				map.put("LOTA11", stockMapList.get(0).get("LOTA11"));
				map.put("LOTA12", stockMapList.get(0).get("LOTA12"));
				map.put("LOTA13", stockMapList.get(0).get("LOTA13"));
				map.put("LOTA14", stockMapList.get(0).get("LOTA14"));
				map.put("LOTA15", stockMapList.get(0).get("LOTA15"));
				map.put("LOTA16", stockMapList.get(0).get("LOTA16"));
				map.put("LOTA17", stockMapList.get(0).get("LOTA17"));
				map.put("LOTA18", stockMapList.get(0).get("LOTA18"));
				map.put("LOTA19", stockMapList.get(0).get("LOTA19"));
				map.put("LOTA20", stockMapList.get(0).get("LOTA20"));
				map.put("AWMSNO", " ");
				map.put("AWMSTS", " ");
				map.put("SMANDT", stockMapList.get(0).get("SMANDT"));
				map.put("SEBELN", stockMapList.get(0).get("SEBELN"));
				map.put("SEBELP", stockMapList.get(0).get("SEBELP"));
				map.put("SZMBLNO",stockMapList.get(0).get("SZMBLNO"));
				map.put("SZMIPNO",stockMapList.get(0).get("SZMIPNO"));
				map.put("STRAID", stockMapList.get(0).get("STRAID"));
				map.put("SVBELN", svbeln);
				map.put("SPOSNR", sposnr);
				map.put("STKNUM", stknum);
				map.put("STPNUM", stpnum);
				map.put("SWERKS", stockMapList.get(0).get("SWERKS"));
				map.put("SLGORT", stockMapList.get(0).get("SLGORT"));
				map.put("SDATBG", stockMapList.get(0).get("SDATBG"));
				map.put("STDLNR", stockMapList.get(0).get("STDLNR"));
				map.put("SSORNU", ssornu);
				map.put("SSORIT", ssorit);
				map.put("SMBLNR", stockMapList.get(0).get("SMBLNR"));
				map.put("SZEILE", stockMapList.get(0).get("SZEILE"));
				map.put("SMJAHR", stockMapList.get(0).get("SMJAHR"));
				map.put("SXBLNR", stockMapList.get(0).get("SXBLNR"));
				map.put("SAPSTS", stockMapList.get(0).get("SAPSTS"));
				map.put("DOORKY", " ");
				map.put("PTLT01", stockMapList.get(0).get("LOTA01"));
				map.put("PTLT02", stockMapList.get(0).get("LOTA02"));
				map.put("PTLT03", stockMapList.get(0).get("LOTA03"));
				map.put("PTLT04", stockMapList.get(0).get("LOTA04"));
				map.put("PTLT05", stockMapList.get(0).get("LOTA05"));
				map.put("PTLT06", stockMapList.get(0).get("LOTA06"));
				map.put("PTLT07", stockMapList.get(0).get("LOTA07"));
				map.put("PTLT08", stockMapList.get(0).get("LOTA08"));
				map.put("PTLT09", stockMapList.get(0).get("LOTA09"));
				map.put("PTLT10", stockMapList.get(0).get("LOTA10"));
				map.put("PTLT11", stockMapList.get(0).get("LOTA11"));
				map.put("PTLT12", stockMapList.get(0).get("LOTA12"));
				map.put("PTLT13", stockMapList.get(0).get("LOTA13"));
				map.put("PTLT14", stockMapList.get(0).get("LOTA14"));
				map.put("PTLT15", stockMapList.get(0).get("LOTA15"));
				map.put("PTLT16", stockMapList.get(0).get("LOTA16"));
				map.put("PTLT17", stockMapList.get(0).get("LOTA17"));
				map.put("PTLT18", stockMapList.get(0).get("LOTA18"));
				map.put("PTLT19", stockMapList.get(0).get("LOTA19"));
				map.put("PTLT20", stockMapList.get(0).get("LOTA20"));
				map.put("PASTKY", " ");
				map.put("ALSTKY", " ");
				map.put("SBKTXT", " ");
				map.put("TASRSN", " ");
				map.put("CREDAT", date);
				map.put("CRETIM", time);
				map.put("CREUSR", CommonConfig.SES_USER_ID_KEY);
				map.put("LMODAT", date);
				map.put("LMOTIM", time);
				map.put("LMOUSR", CommonConfig.SES_USER_ID_KEY);
				map.put("INDBZL", " ");
				map.put("INDARC", " ");
				map.put("UPDCHK", "0");
				map.setModuleCommand("WmsOutbound", "TASDI");
				commonDao.insert(map);
				
				map.setModuleCommand("WmsOutbound", "TASDR_PROCALL");
				commonDao.getMap(map);
			}//if(insflag)문	
		} //isnert for문
		
		return count;
	}
	
	@Transactional
	public int DL06PikingSave(DataMap map) throws SQLException {
		int headModifyIndex = -1;
		List<DataMap> itemList = null;
		if(map.containsKey("headModifyIndex")){
			headModifyIndex = map.getInt("headModifyIndex");
			itemList = map.getList("list");
		}
		
		List<DataMap> headList = map.getList("headList");
		
		if(headList == null || headList.size() == 0) {
			throw new SQLException("선택된 행이 없습니다.");
		}
		
		DataMap row;
		int count = 0;
		
		List<DataMap> paramItemList = new ArrayList<DataMap>();
		DataMap paramItemMap = new DataMap();
		DataMap paramTasdrMap = new DataMap();
		DataMap copy = new DataMap();
		
		for(int i=0;i<headList.size();i++){
			if(map.containsKey("param")){
				row = new DataMap(map.getMap("param").getMap("map"));
			}else{
				row = new DataMap();
			}
			
			map.clonSessionData(row);
			row.append(headList.get(i).getMap("map"));
			paramItemList = new ArrayList<DataMap>();
			
			if(headModifyIndex == i){	
				log.debug("DL06PikingSave headModifyIndex::"+headModifyIndex);
				log.debug("DL06PikingSave itemList size::"+itemList.size());
				for(int j=0;j<itemList.size();j++){
					copy = new DataMap(itemList.get(j).getMap("map"));
					paramItemList.add(copy);
				}
			}else{
				DataMap condRow = new DataMap();
				log.debug("DL06PikingSave condRow SHPOKY::"+row.getString("SHPOKY"));
				condRow.setModuleCommand("WmsOutbound", "MDL16");
				condRow.put("STATIT", "1");
				condRow.put("SHPOKY", row.getString("SHPOKY"));
				condRow.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
				log.debug("DL06PikingSave condRow SES_WAREKY::"+map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
				
				List<DataMap> tasdiList = commonDao.getList(condRow);
				for(int j = 0; j < tasdiList.size(); j++){
					copy = new DataMap(tasdiList.get(j));
					paramItemList.add(copy);
				}
			}


			//insert
			for(int j = 0; j < paramItemList.size(); j++){
				paramItemMap = paramItemList.get(j);
				paramItemMap.setModuleCommand("WmsTask", "DL06_SAVE");
				DataMap dtMap = commonDao.getMap(paramItemMap);
				
				//remove
				paramItemMap.setModuleCommand("WmsTask", "TASDIDEL");
				commonDao.delete(paramItemMap);
				
				
				paramItemMap.setModuleCommand("WmsTask", "TASDIEND");
				paramItemMap.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				
				// "FPC" 작업수량 = 작업완료수량  
				// "PPC" 작업수량 > 작업완료수량
				// "OPC" 작업수량 < 작업완료수량 
			   /*
				* 2016.2.21 junghyojin 작업수량 정수형 처리를 위하여 주석 후 double으로 변경 처리함. 
				* int STAUES = Integer.parseInt(paramItemMap.getString("QTTAOR") )- Integer.parseInt(paramItemMap.getString("QTCOMP"));
				* if (STAUES == 0) {
				* 	paramItemMap.put("STATIT","FPC");
				* } else if (STAUES == 1) {
				* 	paramItemMap.put("STATIT","PPC");
				* } else if (STAUES == -1) {
				*	paramItemMap.put("STATIT","OPC");
				* }
				*/
				BigDecimal p_qttaor = new BigDecimal(paramItemMap.getString("QTTAOR"));
				BigDecimal p_qtcomp = new BigDecimal(paramItemMap.getString("QTCOMP"));
				
				BigDecimal p_STAUES = p_qttaor.subtract(p_qtcomp);
				
				log.debug(":::::::::::DL06PikingSave.p_STAUES::::::"+p_STAUES.signum());
				if (0 == p_STAUES.signum() ){
					paramItemMap.put("STATIT","FPC");
				} else if (1 == p_STAUES.signum() ) {
					paramItemMap.put("STATIT","PPC");
				} else if (-1 == p_STAUES.signum() ) {
					paramItemMap.put("STATIT","OPC");
				}
				
				commonDao.insert(paramItemMap);
				paramTasdrMap = new DataMap();
				
				paramTasdrMap.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				paramTasdrMap.put("STOKKY", dtMap.getString("SRCSKY"));
				paramTasdrMap.put("LMODAT", paramItemMap.getString("LMODAT"));
				paramTasdrMap.put("LMOTIM", paramItemMap.getString("LMOTIM"));
				paramTasdrMap.put("LMOUSR", paramItemMap.getString("LMOUSR"));
				paramTasdrMap.put("TASKKY", dtMap.getString("TASKKY"));
				paramTasdrMap.put("TASKIT", dtMap.getString("TASKIT"));
				paramTasdrMap.put("QTSTKC", paramItemMap.getString("QTCOMP"));
				paramTasdrMap.put("QTSTKM", dtMap.getString("QTSTKM"));

				paramTasdrMap.setModuleCommand("WmsTask", "TASDREND");
				commonDao.insert(paramTasdrMap);
			}
			count++;
		}
		
		return count;	
	}
	
	@Transactional
	public int DeleteTM07(DataMap map) throws SQLException {
		
		List<DataMap> head = map.getList("head");
		
		int count = 0;
		DataMap row = new DataMap();
	
		for( int i = 0 ; i < head.size() ; i++ ){
			row = head.get(i).getMap("map");
			
			row.setModuleCommand("WmsOutbound", "TM07");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			commonDao.delete(row);
			
			count++;
			
		}
		return count;
	}
	
	@Transactional
	public DataMap SaveTM03(DataMap map) throws SQLException {
		List<DataMap> headTemp = map.getList("head"); 
		DataMap head = headTemp.get(0).getMap("map");
		List<DataMap> list = map.getList("list");
		
		int itemCount=0;
		int count = 0;
		DataMap row = new DataMap();
		DataMap item = new DataMap();
		
		// Added by Yun
		String num_VBELN = "WMS" + wmsService.getNumSeq("NR-VBELN").substring(3);
		// Added by Yun
		
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.setModuleCommand("WmsOutbound", "TM05");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			
			row.put("MANDT", "110" );
			row.put("SEQNO", wmsService.getNumSeq("NR-IF113"));
//			row.put("VBELN", head.getString("VBELN") );
			row.put("VBELN", num_VBELN );
			itemCount += 1;
			String snum = String.valueOf(itemCount);
			row.put( "POSNR", snum );

			row.put("BWART", head.getString("BWART") );
			row.put("STATUS", "A" );
			row.put("IFFLG", "N" );
			row.put("WADAT", head.getString("ZEKKO_AEDAT"));
			row.put("PTNRKY", head.getString("PTNRKY"));
			row.put("MEINS", row.get("UOMKEY") );
			row.put("WAREKY", head.getString("WAREKY") );
			
			commonDao.update(row);

/*			
			DataMap vbelnMap = new DataMap("WmsOutbound", "SETVBELN");
			vbelnMap.put("BWART", head.getString("BWART"));
			String vbelnext =(String)commonDao.getMap(vbelnMap).getString("VBELN");
			
			item.put("VBELN", row.getString("VBELN"));
			item.put("POSNR", row.getString("POSNR"));
			item.put("VBELNEXT", vbelnext);
			item.put("VWAREKY", head.getString("WAREKY"));
			item.put("VSEQNO", wmsService.getNumSeq("NR-IF113"));
 */
		}
//		item.setModuleCommand("WmsOutbound", "TM05G");
//		commonDao.update(item);


		DataMap rsMap = new DataMap();
		StringBuilder sb = new StringBuilder();
		
		map.setModuleCommand("WmsOutbound", "TM05H");
//		map.put("VBELN", head.getString("VBELN") );
		map.put("VBELN", num_VBELN );
		
		List dataList = commonDao.getList(map);
		
		rsMap.put("data", dataList);
		
		return rsMap;
	}

	@Transactional
	public DataMap SaveTM05(DataMap map) throws SQLException {
		List<DataMap> headTemp = map.getList("head"); 
		DataMap head = headTemp.get(0).getMap("map");
		List<DataMap> list = map.getList("list");
		
		int itemCount=0;
		int count = 0;
		DataMap row = new DataMap();
		DataMap item = new DataMap();
		
		// Added by Yun
		String num_VBELN = "WMS" + wmsService.getNumSeq("NR-VBELN").substring(3);
		// Added by Yun
		
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.setModuleCommand("WmsOutbound", "TM05");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			
			row.put("MANDT", "110" );
			row.put("SEQNO", wmsService.getNumSeq("NR-IF113"));
//			row.put("VBELN", head.getString("VBELN") );
			row.put("VBELN", num_VBELN);
			itemCount += 1;
			String snum = String.valueOf(itemCount);
			row.put( "POSNR", snum );
			
			row.put("BWART", head.getString("BWART") );
			
			row.put("STATUS", "A" );
			row.put("IFFLG", "N" );
			row.put("WADAT", head.getString("ZEKKO_AEDAT"));
			row.put("PTNRKY", head.getString("PTNRKY"));
			row.put("MEINS", row.get("UOMKEY") );
			row.put("WAREKY", head.getString("WAREKY") );
			
			commonDao.update(row);

			// blocked by Yun
/*
			String vseqno = wmsService.getNumSeq("NR-IF113");
			
			DataMap vbelnMap = new DataMap("WmsOutbound", "SETVBELN");
			vbelnMap.put("BWART", head.getString("BWART"));
			String vbelnext =(String)commonDao.getMap(vbelnMap).getString("VBELN");
			
			item.put("VBELN", row.getString("VBELN"));
			item.put("POSNR", row.getString("POSNR"));
			item.put("VBELNEXT", vbelnext);
			item.put("VWAREKY", head.getString("WAREKY"));
			item.put("VSEQNO", vseqno);
 */
			// blocked by Yun
		}
//		item.setModuleCommand("WmsOutbound", "TM05G");
//		commonDao.update(item);


		DataMap rsMap = new DataMap();
		StringBuilder sb = new StringBuilder();
		
		map.setModuleCommand("WmsOutbound", "TM05H");
//		map.put("VBELN", head.getString("VBELN") );
		map.put("VBELN", num_VBELN );
		
		List dataList = commonDao.getList(map);
		
		rsMap.put("data", dataList);
		
		return rsMap;
	}

	@Transactional
	public DataMap SaveTM06(DataMap map) throws SQLException {
		List<DataMap> headTemp = map.getList("head"); 
		DataMap head = headTemp.get(0).getMap("map");
		List<DataMap> list = map.getList("list");
		
		map.put("WAREKY", head.get("WAREKY"));

		int count = 0;
		int itemCount=0;
		DataMap row = new DataMap();
		
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			row.setModuleCommand("WmsOutbound", "TM06");
			row.put("MANDT", "110" );
			
			row.put("SEQNO", wmsService.getNumSeq("NR-IF113"));
			row.put("EBELN", head.getString("EBELN") );
			
			itemCount += 1;
			String snum = String.valueOf(itemCount);
			row.put( "EBELP", snum );
			row.put("LIFNR", head.getString("PTNRKY") );
			row.put("BWART", head.getString("BWART") );
			
			row.put("STATUS", "A" );
			row.put("IFFLG", "N" );
			row.put("WAREKY", head.getString("WAREKY") );
			row.put("DEPTID1", head.getString("PTNRKY") );
			
			commonDao.insert(row);
					
			count++;
		}

		DataMap rsMap = new DataMap();
		StringBuilder sb = new StringBuilder();
		
		map.setModuleCommand("WmsOutbound", "TM06H");
		map.put("EBELN", head.getString("EBELN") );
		
		List dataList = commonDao.getList(map);
		
		rsMap.put("data", dataList);
		
		return rsMap;
	}
	
	@Transactional
	public DataMap saveShpd(DataMap map) throws SQLException {
		
		int headModifyIndex = -1;
		List<DataMap> itemList = null;
		if(map.containsKey("headModifyIndex")){
			headModifyIndex = map.getInt("headModifyIndex");
			itemList = map.getList("list");
		}
		
		DataMap rsMap = new DataMap();
		
		List<DataMap> headList = map.getList("headList");
		
		DataMap row;
		
		List docNumList = new ArrayList();
		
		for(int i=0;i<headList.size();i++){
			if(map.containsKey("param")){
				row = new DataMap(map.getMap("param").getMap("map"));
			}else{
				row = new DataMap();
			}				
			
			map.clonSessionData(row);
			row.append(headList.get(i).getMap("map"));
			
			String docNum;
			int itemCount = 0;
			
			if("".equals(row.getString("SHPOKY").trim())){
				docNum = wmsService.getDocSeq(row.getString("DOCUTY"));
				row.put("SHPOKY", docNum);
				row.setModuleCommand("WmsOutbound", "SHPDH");
				commonDao.insert(row);
				if(headModifyIndex == i){				
					row.setModuleCommand("WmsOutbound", "SHPDI");
					for(int j=0;j<itemList.size();j++){
						row.append(itemList.get(j).getMap("map"));
						
						itemCount += 10;
						String snum = String.valueOf(itemCount);
						String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
						row.put("SHPOKY", docNum);
						row.put("SHPOIT", inum);
						commonDao.insert(row);
					}
				}else{
					row.setModuleCommand("WmsOutbound", "SHPDIALL");
					commonDao.insert(row);			
				}
			}else{
				docNum = row.getString("SHPOKY");
				row.setModuleCommand("WmsOutbound", "SHPDHORG");
				commonDao.update(row);
				
				if(headModifyIndex == i){				
					row.setModuleCommand("WmsOutbound", "SHPDIORG");
					for(int j=0;j<itemList.size();j++){
						row.append(itemList.get(j).getMap("map"));
						commonDao.update(row);
					}
				}
			}
			docNumList.add(docNum);
			
			if(row.getString("SHPMTY").toString().equals("299")){
				row.setModuleCommand("WmsOutbound", "IF113STKNUM");
				commonDao.update(row);
			}
			
			if(!row.getString("DRELIN").toString().equals("V")){
				row.put("DRELIN", "V");
				row.setModuleCommand("WmsOutbound", "SHPDH");
				commonDao.update(row);
				
				if(row.getString("SHPMTY").toString().equals("299")){
					row.setModuleCommand("WmsOutbound", "IF113PROC");
					commonDao.getMap(row);
				}
			}
			
			if(map.containsKey("batch")){
				row.setModuleCommand("WmsOutbound", "BATCHALLOCATION");
				
				commonDao.getMap(row);
			}
		}
		
		StringBuilder sb = new StringBuilder();
		for(int i=0;i<docNumList.size();i++){
			if(i != 0){
				sb.append(",");
			}
			sb.append("'").append(docNumList.get(i)).append("'");
		}
		
		map.setModuleCommand("WmsOutbound", "DL04HEAD");
		map.put("SHPOKY", sb.toString());
		
		List dataList = commonDao.getList(map);
		
		rsMap.put("data", dataList);
		
		return rsMap;
	}
	
	@Transactional
	public DataMap deleteOrder(DataMap map) throws SQLException {
		int headModifyIndex = -1;
		List<DataMap> itemList = null;
		if(map.containsKey("headModifyIndex")){
			headModifyIndex = map.getInt("headModifyIndex");
			itemList = map.getList("list");
		}
		
		DataMap rsMap = new DataMap();
		
		List<DataMap> headList = map.getList("headList");
		
		DataMap row;
		
		for(int i=0;i<headList.size();i++){
			if(map.containsKey("param")){
				row = new DataMap(map.getMap("param").getMap("map"));
			}else{
				row = new DataMap();
			}
			
			map.clonSessionData(row);
			row.append(headList.get(i).getMap("map"));
			row.setModuleCommand("WmsOutbound", "IFWMS113");
			
			if(headModifyIndex == i){
				for(int j=0;j<itemList.size();j++){
					row.append(itemList.get(j).getMap("map"));
					commonDao.update(row);
				}
			}else{
				commonDao.update(row);
			}
		}
		
		return rsMap;
	}
	
	@Transactional
	public DataMap dl04Procall(DataMap map) throws SQLException {
		int headModifyIndex = -1;
		List<DataMap> itemList = null;
		if(map.containsKey("headModifyIndex")){
			headModifyIndex = map.getInt("headModifyIndex");
			itemList = map.getList("list");
		}
		
		DataMap rsMap = new DataMap();
		
		List<DataMap> headList = map.getList("headList");
		
		DataMap row = new DataMap();
		
		List docNumList = new ArrayList();
		
		for(int i=0;i<headList.size();i++){
			if(map.containsKey("param")){
				row = new DataMap(map.getMap("param").getMap("map"));
			}else{
				row = new DataMap();
			}				
			map.clonSessionData(row);
			row.append(headList.get(i).getMap("map"));
			docNumList.add(headList.get(i).getMap("map").get("SHPOKY"));
			
			
			if(row.getString("SHPMTY").toString().equals("299")){
				row.setModuleCommand("WmsOutbound", "IF113STKNUM");
				commonDao.update(row);
			}
			
			if(!row.getString("DRELIN").toString().equals("V")){
				row.put("DRELIN", "V");
				row.setModuleCommand("WmsOutbound", "SHPDH");
				commonDao.update(row);
				
				if(row.getString("SHPMTY").toString().equals("299")){
					row.setModuleCommand("WmsOutbound", "IF113PROC");
					commonDao.getMap(row);
				}
			}
			
			if(map.containsKey("batch")){
				row.setModuleCommand("WmsOutbound", "BATCHALLOCATION");
				
				commonDao.getMap(row);
			}
			
		}
		
		StringBuilder sb = new StringBuilder();
		for(int i=0;i<docNumList.size();i++){
			if(i != 0){
				sb.append(",");
			}
			sb.append("'").append(docNumList.get(i)).append("'");
		}
		
		map.setModuleCommand("WmsOutbound", "DL04HEAD");
		map.put("SHPOKY", sb.toString());
		
		List dataList = commonDao.getList(map);
		
		rsMap.put("data", dataList);
		
		return rsMap;
	}
	
	@Transactional
	public String validateSendEcms(DataMap map) throws Exception {
		String result = "OK";
		
		int headModifyIndex = -1;
		List<DataMap> itemList = null;
		if(map.containsKey("headModifyIndex")){
			headModifyIndex = map.getInt("headModifyIndex");
			itemList = map.getList("list");
		}
		
		List<DataMap> headList = map.getList("headList");
		
		DataMap row;
		DataMap copy = new DataMap();
		List<DataMap> paramItemList = new ArrayList<DataMap>();
		
		for(int i=0;i<headList.size();i++){
			if(map.containsKey("param")){
				row = new DataMap(map.getMap("param").getMap("map"));
			}else{
				row = new DataMap();
			}
			
			map.clonSessionData(row);
			row.append(headList.get(i).getMap("map"));
			
			paramItemList = new ArrayList<DataMap>();
			if(headModifyIndex == i){	
				for(int j=0;j<itemList.size();j++){
					copy = new DataMap(itemList.get(j).getMap("map"));
					paramItemList.add(copy);
				}
			}else{
				row.setModuleCommand("WmsOutbound", "DL08Sub");
				List<DataMap> dl08subList = commonDao.getList(row);
				for(int j = 0; j < dl08subList.size(); j++){
					copy = new DataMap(dl08subList.get(j));
					paramItemList.add(copy);
				}
			}

			//Validation check
			// (PPC, FPC) && (출하완료수량 <= 피킹수량) && (출하완료수량 <= 지시수량) Validation
	 		StringBuffer sb = new StringBuffer();
	 		
			for(int j=0;j<paramItemList.size();j++){
				copy = paramItemList.get(j);
				if(sb.length() > 0){
					sb.append(" UNION ALL ");
				}
				
				sb.append("SELECT '").append(copy.getString("SHPOKY")).append("' AS SHPOKY, ");
				sb.append("'").append(copy.getString("SHPOIT")).append("' AS SHPOIT, ");
				sb.append("'").append(copy.getString("QTSHPD")).append("' AS QTSHPD ");
				sb.append(" FROM DUAL ");
			}
			
			if(sb.length() > 0){
				row.put("APPENDQUERY", sb.toString());
				row.setModuleCommand("WmsOutbound", "VALIDDL08");
				List<DataMap> valiList = commonDao.getList(row);
				
				for(int k=0; k< valiList.size(); k++){
					DataMap dtMap = valiList.get(k);
					
					if( !"OK".equals(dtMap.getString("RESULTMSG"))){
						result = dtMap.getString("RESULTMSG");
						return result;
					}
					
				}
			}
			
			// 1. 완료처리하지 않은  TASK 정보가 있는지 확인.
			row.setModuleCommand("WmsOutbound", "CNTTASK");
			row.put("SHPOIT",copy.getString("SHPOIT") );
			int count =  commonDao.getMap(row).getInt("CNT");
			if(count > 0){
				result = "OUT_M0174"+" "+row.getString("SHPOKY")+"/"+row.getString("SHPOIT");
				return result;
			}
		}
		
		return result;
	}
	
	@Transactional
	public DataMap sendEcms(DataMap map) throws SQLException {
		DataMap rsMap = new DataMap();
		Connection conn = sqlMapClient.getDataSource().getConnection();
		conn.setAutoCommit(false);
		SqlMapSession session = sqlMapClient.openSession(conn);
		
		try{
			int headModifyIndex = -1;
			List<DataMap> itemList = null;
			if(map.containsKey("headModifyIndex")){
				headModifyIndex = map.getInt("headModifyIndex");
				itemList = map.getList("list");
			}
			
			List<DataMap> headList = map.getList("headList");
			
			DataMap row;
			
			List docNumList = new ArrayList();
			List<DataMap> paramItemList = new ArrayList<DataMap>();
			DataMap copy = new DataMap();
			DataMap itemMap = new DataMap();
			String headINDCHK = "";
			
			for(int i=0;i<headList.size();i++){
				if(map.containsKey("param")){
					row = new DataMap(map.getMap("param").getMap("map"));
				}else{
					row = new DataMap();
				}				
				
				map.clonSessionData(row);
				row.append(headList.get(i).getMap("map"));
				docNumList.add(headList.get(i).getMap("map").get("SHPOKY"));
				
				paramItemList = new ArrayList<DataMap>();
				if(headModifyIndex == i){	
					for(int j=0;j<itemList.size();j++){
						copy = new DataMap(itemList.get(j).getMap("map"));
						paramItemList.add(copy);
					}
				}else{
					row.setModuleCommand("WmsOutbound", "DL08Sub");
					List<DataMap> dl08subList = commonDao.getList(row);
					for(int j = 0; j < dl08subList.size(); j++){
						copy = new DataMap(dl08subList.get(j));
						paramItemList.add(copy);
					}
				}
				
				for(int j=0;j<paramItemList.size();j++){
					itemMap = paramItemList.get(j);
					map.clonSessionData(itemMap);
					
					itemMap.setModuleCommand("WmsOutbound", "DL08SHPDI");
					commonDao.update(itemMap);
					
					//해당 Gropky에 대한 list	
					if( itemMap.getString("REFDKY") != null && !itemMap.getString("REFDKY").equals("")){
						itemMap.put("SHPOKY", itemMap.get("REFDKY"));
						itemMap.put("SHPOIT", itemMap.get("REFDIT"));
						commonDao.update("WmsOutbound.DL08SHPDI", itemMap);	
					}
				}
				
				row.setModuleCommand("WmsOutbound", "DL08SHPDH");
				commonDao.update(row);
				
				// 5. 전송 프로시저 호출
	//			row.put("DOCUKY", row.get("SHPOKY"));
	//			row.put("DOFLAG", "Z");
	//			row.setModuleCommand("WmsOutbound", "CALL_AIRWMS_DOCUMENT_PROCESS");
	//			commonDao.getMap(row);
				
				// 6. 그룹오더인지 체크하여 원출고문서 출하완료 처리
				row.setModuleCommand("WmsOutbound", "CNTGRPDOC");
				int countCHK =  commonDao.getMap(row).getInt("CNT");
				if(countCHK > 0){
					commonDao.getMap("WmsOutbound.CALL_BATCH_COMP_TOT", row);
				}
			}
			
			conn.commit();
		}catch(Exception e){
			conn.rollback();
			log.debug(e.getMessage());
			throw new SQLException(e.getMessage());
		}finally{
			if(session != null){ session.close(); }
			if(conn != null){ conn.close(); }      
		}
		rsMap.put("ERRNUM", 0);
		rsMap.put("MSG", "OK");
	
		return rsMap;
	}
	
	@Transactional
	public int savePrtseq(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("head");
		int count = 0;
		
		DataMap row;
		for(int i=0;i<list.size();i++){
		    row = list.get(i).getMap("map");
			row.setModuleCommand("WmsOutbound", "PRTLG");
			row.put("PRTSEQ", map.get("PRTSEQ"));
			
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			commonDao.insert(row);
			
			count ++;
		}
		
		return count;
	}
	
	@Transactional
	public int savePrtseq2(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("head");
		int count = 0;
		
		DataMap row;
		for(int i=0;i<list.size();i++){
		    row = list.get(i).getMap("map");
			row.setModuleCommand("WmsOutbound", "PRTLGPICK");
			row.put("PRTSEQ", map.get("PRTSEQ"));
			
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			commonDao.insert(row);
			
			count ++;
		}
		
		return count;
	}
	
//	@Transactional
//	public int saveDL04(DataMap map) throws SQLException {
//		List<DataMap> list = map.getList("head");
//		int count = 0;
//		
//		DataMap row;
//		for(int i=0;i<list.size();i++){
//			row = list.get(i).getMap("map");
//			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
//			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
//			row.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
//			
//			commonDao.update("WmsOutbound.DL04", row);
//			count ++;
//		}
//		return count;
//	}
	
	@Transactional
	public DataMap saveDL04(DataMap map) throws SQLException {
		DataMap rsMap = new DataMap();
		List<DataMap> headList = map.getList("head");
		List<DataMap> itemList = null;
		List<DataMap> selectList = new ArrayList<DataMap>();
		
		int headModifyIndex = -1;
		if(map.containsKey("headModifyIndex")){
			headModifyIndex = map.getInt("headModifyIndex");
			itemList = map.getList("itemList");
		}
		
		DataMap row;
		List docNumList = new ArrayList();
		
		for(int i=0;i<headList.size();i++){
			if(map.containsKey("param")){
				row = new DataMap(map.getMap("param").getMap("map"));
			}else{
				row = new DataMap();
			}				
			
			map.clonSessionData(row);
			row.append(headList.get(i).getMap("map"));
			
			String docNum;
			int itemCount = 0;
			
			//1. 출고문서번호가 생성되지 않음, [INSERT]
			if("".equals(row.getString("SHPOKY").trim())){
				docNum = wmsService.getDocSeq(row.getString("DOCUTY"));
				row.put("SHPOKY", docNum);
				//1.1 head insert
				row.setModuleCommand("WmsOutbound", "SHPDH");
				commonDao.insert(row);
				//1.2 item insert
				if(headModifyIndex == i){	//아이템그리드에 선택되었을 때 			
					row.setModuleCommand("WmsOutbound", "SHPDI");
					for(int j=0;j<itemList.size();j++){
						row.append(itemList.get(j).getMap("map"));
						
						itemCount += 10;
						String snum = String.valueOf(itemCount);
						String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
						row.put("SHPOKY", docNum);
						row.put("SHPOIT", inum);
						commonDao.insert(row);
					}
				}else{ //선택되지 않았을때
					row.setModuleCommand("WmsOutbound", "DL04Sub");
					selectList = commonDao.getList(row);	
					for(int j=0;j<selectList.size();j++){
						row.append(selectList.get(j).getMap("map"));
						row.setModuleCommand("WmsOutbound", "SHPDI");
						
						itemCount += 10;
						String snum = String.valueOf(itemCount);
						String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
						row.put("SHPOKY", docNum);
						row.put("SHPOIT", inum);
						commonDao.insert(row);
					}
				}	
			}else{ //2. 출고문서번호가 생성됨, [UPDATE]
				docNum = row.getString("SHPOKY");
				row.setModuleCommand("WmsOutbound", "SHPDHORG");
				commonDao.update(row);
								
				row.setModuleCommand("WmsOutbound", "SHPDIORG");
				for(int j=0;j<itemList.size();j++){
					row.append(itemList.get(j).getMap("map"));
					commonDao.update(row);
				}
			}
			docNumList.add(docNum);
		}
		
		StringBuilder sb = new StringBuilder();
		for(int i=0;i<docNumList.size();i++){
			if(i != 0){
				sb.append(",");
			}
			sb.append("'").append(docNumList.get(i)).append("'");
		}
		
		rsMap.put("SHPOKY", sb.toString());

		return rsMap;
	}
	
	@Transactional
	public int saveDL04Sub(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		int count = 0;
		
		DataMap row;
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			row.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
			
			commonDao.update("WmsOutbound.DL04Sub", row);
			count ++;
		}
		return count;
	}
	
	@Transactional
	public DataMap AssignDL04(DataMap map) throws SQLException{
		List<DataMap> head = map.getList("head");
		List<DataMap> itemList = null;
		//List<DataMap> itemList = map.getList("list");		//210915 item별 할당 -> head(shpoky)별 할당으로 변경하므로 주석처리
		List<DataMap> selectList = new ArrayList<DataMap>();
		int count = 0;
		String HeadGridSvbeln = map.get("HeadGridSvbeln").toString();
		String HeadGridShpoky = map.get("HeadGridShpoky").toString();
		
		int headModifyIndex = -1;
		if(map.containsKey("headModifyIndex")){
			headModifyIndex = map.getInt("headModifyIndex");
			itemList = map.getList("list");
		}
		
		DataMap row = new DataMap();
		String docNum;
		int itemCount1 = 0;
		int itemCount2 = 0;
		StringBuilder sb = new StringBuilder();
		
		for(int i=0;i<head.size();i++){
			row = head.get(i).getMap("map");
			//1. 출고문서번호가 없을 때 저장 후, 할당
			if("".equals(row.getString("SHPOKY").trim())){
				docNum = wmsService.getDocSeq(row.getString("DOCUTY"));
				row.put("SHPOKY", docNum);
				row.setModuleCommand("WmsOutbound", "SHPDH");
				commonDao.insert(row);
				
				if(headModifyIndex == i){
					row.setModuleCommand("WmsOutbound", "SHPDI");
					for(int j=0;j<itemList.size();j++){
						row.append(itemList.get(j).getMap("map"));
						
						itemCount1 += 10;
						String snum = String.valueOf(itemCount1);
						String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
						row.put("LOTA10", row.getString("LOTA10"));
						row.put("SHPOKY", docNum);
						row.put("SHPOIT", inum);
						commonDao.insert(row);
						
						//210915 item별 할당 -> head(shpoky)별 할당으로 변경하므로 주석처리
						//할당(item별)
						//row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
						//commonDao.getMap("WmsOutbound.ALLOC_ITEM_PROCALL", row);
					}
				}else{ 
					row.setModuleCommand("WmsOutbound", "DL04Sub");
					selectList = commonDao.getList(row);	
					for(int j=0;j<selectList.size();j++){
						row.append(selectList.get(j).getMap("map"));
						
						row.setModuleCommand("WmsOutbound", "SHPDI");
						
						itemCount2 += 10;
						String snum = String.valueOf(itemCount2);
						String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
						
						row.put("SHPOKY", docNum);
						row.put("SHPOIT", inum);
						commonDao.insert(row);
					}
					
					//210915 item별 할당 -> head(shpoky)별 할당으로 변경하므로 주석처리
					//할당(item별)
					//row.put("SHPOIT", "%");
					//row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
					//commonDao.getMap("WmsOutbound.ALLOC_ITEM_PROCALL", row);
				}
				
			}
			//210915 item별 할당 -> head(shpoky)별 할당으로 변경하므로 주석처리
			/*else{	//2. 출고문서번호가 있을 때 할당
				if(head.get(i).getMap("map").getString("SVBELN").equals(HeadGridSvbeln)){
				//if(headModifyIndex == i){
					for(int j=0;j<itemList.size();j++){
						if(!" ".equals(HeadGridShpoky)){
							row.append(itemList.get(j).getMap("map"));
						}
						
						row.put("SHPOIT", row.getString("SHPOIT"));
						row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
						commonDao.getMap("WmsOutbound.ALLOC_ITEM_PROCALL", row);
					}
				}else{
					List<DataMap> list = commonDao.getList("WmsOutbound.DL04Sub", row);
					
					row.put("SHPOKY", list.get(0).getMap("map").getString("SHPOKY"));
					row.put("SHPOIT", "%");
					row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
					commonDao.getMap("WmsOutbound.ALLOC_ITEM_PROCALL", row);
				}
			}*/
			
			//2. 출고문서번호가 있을 때 바로 할당
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			commonDao.getMap("WmsOutbound.ALLOC_PROCALL", row);
			
			//count ++;
			if(i != 0){
				sb.append(",");
			}
			sb.append("'").append(row.getString("SHPOKY")).append("'");
		}
		
		DataMap rsMap = new DataMap();
		rsMap.put("SHPOKY", sb.toString());
		
		return rsMap;
	}
	
	@Transactional
	public DataMap UnallocateDL04(DataMap map) throws SQLException {
		List<DataMap> head = map.getList("head");
		List<DataMap> itemList = map.getList("list");
		List<DataMap> selectList = new ArrayList<DataMap>();
		List shpokyList = new ArrayList();
		DataMap rsMap = new DataMap();
		DataMap row;
		int count = 0;
		String HeadGridShpoky = map.get("HeadGridShpoky").toString();
		
		for(int i=0;i<head.size();i++){
			String shpokyNum = head.get(i).getMap("map").getString("SHPOKY");
			shpokyList.add(shpokyNum);
			
			//210915 item별 할당 -> head(shpoky)별 할당으로 변경하므로 주석처리
			/*if(head.get(i).getMap("map").getString("SHPOKY").equals(HeadGridShpoky)){
				if(HeadGridShpoky.equals(itemList.get(0).getMap("map").getString("SHPOKY"))){
					selectList = itemList;
				}
				
				for(int j=0;j<selectList.size();j++){
					row = selectList.get(j).getMap("map");
					String ItemStatit1 = row.getString("STATIT");
					map.clonSessionData(row);

					if("FAL".equals(ItemStatit1) || "PAL".equals(ItemStatit1)){
						commonDao.delete("WmsOutbound.DL04REMOVE1", row); //아이템별로 취소
						rsMap.put("ERRMSG", "OK");
						count++;
					}else{
						rsMap.put("ERRMSG", "Can not aloocated(Item)");
					}
				}
			}else{*/
				row = head.get(i).getMap("map");
				String ItemStatit2 = row.getString("STATIT");
				map.clonSessionData(row);
				
				if("FAL".equals(ItemStatit2) || "PAL".equals(ItemStatit2)){
					commonDao.delete("WmsOutbound.DL04REMOVE2", row); //헤더 취소
					rsMap.put("ERRMSG", "OK");
					count ++;
				}else{
					rsMap.put("ERRMSG", "Can not aloocated(Head)");
				}
			//}
			
			StringBuilder sb = new StringBuilder();
			for(int k = 0 ; k < shpokyList.size() ; k ++){
				if(k != 0){
					sb.append(",");
				}
				sb.append("'").append(shpokyList.get(k)).append("'");
			}
			
			rsMap.put("SHPOKY", sb.toString());
		}
		
		return rsMap;
	}
	
	@Transactional
	public int CompleteDL04(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("head");
		int count = 0;
		
		DataMap row;
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			row.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
			
			commonDao.getMap("WmsOutbound.SHPDPROCALL", row);
			count ++;
		}
		return count;
	}
	
	@Transactional
	public String DL09CancelShipment(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("head");
		
		// Validation
		StringBuffer sb = new StringBuffer();
		for(DataMap head : list){
			if(sb.length() > 0)
				sb.append(" UNION ALL\n ");
			
			sb.append(" SELECT '").append(head.getMap("map").get("SHPOKY")).append("' AS SHPOKY FROM DUAL ");
		}
		
		map.setModuleCommand("WmsOutbound", "SHIPPING_CANCEL"); // 쿼리키값 넣을것
		map.put("APPEND_QUERY", sb.toString());
		List<DataMap> validList = commonDao.getValidation(map);
		if(validList.size() > 0){
			DataMap valid = validList.get(0);
			return valid.getString("RESULTMSG");
		}
		
		DataMap row;
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			row.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
			row.put("DOCUKY", row.get("SHPOKY"));
			row.put("DOFLAG", "C");
			//commonDao.getMap("WmsOutbound.CALL_SHIPPING_CANCEL_PROC", row);
			commonDao.getMap("WmsOutbound.CALL_AIRWMS_DOCUMENT_PROCESS", row);
		}
		
		return "OK";
	}
	
	@Transactional
	public int CompleteDL06(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("head");
		int count = 0;
		DataMap row;
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.putAll(row);
			commonDao.getMap("WmsOutbound.DL06PROCALL", row);
			count++;
		}
		return count;
	}
	
	@Transactional
	public int CompleteDL16(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		
		SimpleDateFormat fmDate = new SimpleDateFormat("yyyyMMdd", Locale.KOREA);
		String date = fmDate.format(new Date());
		SimpleDateFormat fmTime = new SimpleDateFormat("HHmmss", Locale.KOREA);
		String time = fmTime.format(new Date());
		
		int count = 0;
		DataMap row;
		DataMap searchtasdi = new DataMap();
		DataMap searchtasdr = new DataMap();
		DataMap data;
		for(int i=0;i<list.size();i++){
		  // 1. TASDI/R SELECT///////////////////////////
			row = list.get(i).getMap("map");
			map.put("TASKKY", row.get("TASKKY"));
			map.put("TASKIT", row.get("TASKIT"));
			  
			map.setModuleCommand("WmsOutbound", "SEARCHTASDI");
			searchtasdi = commonDao.getMap(map);
			  
			map.setModuleCommand("WmsOutbound", "SEARCHTASDR");
			searchtasdr = commonDao.getMap(map);
			  
			//2. 재고찾기//////////////////////////////////////
			searchtasdr.setModuleCommand("WmsOutbound", "STKKYFIND");
			data = commonDao.getMap(searchtasdr);
			  
			//3. TASDI DELETE////////////////////////////////
			searchtasdi.setModuleCommand("WmsOutbound", "TASDIDEL");
			commonDao.delete(searchtasdi);
			
			//4.TASDI/R INSERT////////////////////////////////
			searchtasdi.put("LOCAAC", searchtasdi.get("LOCATG"));
			searchtasdi.put("ACTCDT", date);
			searchtasdi.put("ACTCTI", time);
			searchtasdi.put("QTCOMP", row.get("QTCOMP"));
			searchtasdi.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			searchtasdi.setModuleCommand("WmsOutbound", "TASDIEND");
			commonDao.insert(searchtasdi);
			
			searchtasdr.put("QTSTKC", row.get("QTCOMP"));
			searchtasdr.put("STOKKY", data.get("SRCSKY"));
			searchtasdr.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			searchtasdr.setModuleCommand("WmsOutbound", "TASDREND");
			commonDao.insert(searchtasdr);
			
			count++;
		}
		return count;
	}
	
	@Transactional
	public String PickingCancelDL07(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("head");
		
		SimpleDateFormat fmDate = new SimpleDateFormat("yyyyMMdd", Locale.KOREA);
		String date = fmDate.format(new Date());
		SimpleDateFormat fmTime = new SimpleDateFormat("HHmmss", Locale.KOREA);
		String time = fmTime.format(new Date());
		
		// Validation
		StringBuffer sb = new StringBuffer();
		for(DataMap item : list){
			if(sb.length() > 0)
				sb.append(" UNION ALL\n ");
			
			sb.append(" SELECT '").append(item.getMap("map").get("TASKKY")).append("' AS TASKKY, ");
			sb.append("        '").append(item.getMap("map").get("TASKIT")).append("' AS TASKIT FROM DUAL ");
		}
		
		map.setModuleCommand("WmsOutbound", "PICKING_CANCEL"); // 쿼리키값 넣을것
		map.put("APPEND_QUERY", sb.toString());
		List<DataMap> validList = commonDao.getValidation(map);
		if(validList.size() > 0){
			DataMap valid = validList.get(0);
			return valid.getString("RESULTMSG");
		}
		
		DataMap row;
		DataMap itRow;
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			row.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
			
			commonDao.getMap("WmsOutbound.CALL_PICKING_CANCEL_PROC_DL07", row);
		}
		
		return "OK";
	}
	
	@Transactional
	public String PickingCancelDL17(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		
		SimpleDateFormat fmDate = new SimpleDateFormat("yyyyMMdd", Locale.KOREA);
		String date = fmDate.format(new Date());
		SimpleDateFormat fmTime = new SimpleDateFormat("HHmmss", Locale.KOREA);
		String time = fmTime.format(new Date());
		
		// Validation
		StringBuffer sb = new StringBuffer();
		for(DataMap item : list){
			if(sb.length() > 0)
				sb.append(" UNION ALL\n ");
			
			sb.append(" SELECT '").append(item.getMap("map").get("TASKKY")).append("' AS TASKKY, ");
			sb.append("        '").append(item.getMap("map").get("TASKIT")).append("' AS TASKIT FROM DUAL ");
		}
		
		map.setModuleCommand("WmsOutbound", "PICKING_CANCEL_ITEM"); // 쿼리키값 넣을것
		map.put("APPEND_QUERY", sb.toString());
		List<DataMap> validList = commonDao.getValidation(map);
		if(validList.size() > 0){
			DataMap valid = validList.get(0);
			return valid.getString("RESULTMSG");
		}
		
		DataMap row;
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			row.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
			
			commonDao.getMap("WmsOutbound.CALL_PICKING_CANCEL_PROC", row);
		}
		
		return "OK";
	}
	
	@Transactional
	public Object savePrtseqDL04(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("head");
		int count = 0;
		String opt;
		
		map.setModuleCommand("WmsOutbound", "SEQSTKNUM");
		Object stknum = commonDao.getObject(map);
		map.setModuleCommand("WmsOutbound", "SEQPRTSEQ");
		Object prtseq = commonDao.getObject(map);
		map.put("STKNUM", stknum);
		map.put("PRTSEQ", prtseq);
		DataMap row;
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.setModuleCommand("WmsOutbound", "DL04HEAD");
			row.put("STKNUM", stknum);
			row.put("PRTSEQ", prtseq);
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			commonDao.update(row);
			
			count ++;
		}
		opt = map.getString("opt");
		if(opt.equals("INDUPK")){
			map.put("PRTTYP", 1);
		}else if(opt.equals ("INDUPA")){
			map.put("PRTTYP", 2);
		}else if(opt.equals ("INDUPB")){
			map.put("PRTTYP", 3);
		}
		
		map.setModuleCommand("WmsOutbound", "DL06PROC");
		commonDao.getMap(map);
		
		return prtseq;
	}
	
	@Transactional
	public int DeleteDL04(DataMap map) throws SQLException {
		List<DataMap> headList = map.getList("head");
		
		DataMap row;
		int count = 0;
		
		for(int i=0; i<headList.size(); i++){
			row = headList.get(i).getMap("map");
			
			//SHPDH SHPDI TASDR TASDI TASDH 도 삭제
			row.setModuleCommand("WmsOutbound", "SHPDI");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			commonDao.delete(row);
			
			row.setModuleCommand("WmsOutbound", "SHPDH");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			commonDao.delete(row);
			count ++;
		}
		
		return count;
	}
	
	@Transactional
	public int savePrtseqPT01(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("head");
		int count = 0;
		
		DataMap row;
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.setModuleCommand("WmsOutbound", "PRTLGPT01");
			row.put("PRTSEQ", map.get("PRTSEQ"));
			
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			commonDao.insert(row);
			
			count ++;
		}
		return count;
	}
	
	@Transactional
	public int savePrtseqDL09(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("head");
		int count = 0;
		
		DataMap row;
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.setModuleCommand("WmsOutbound", "PRTLGSHIP");
			row.put("PRTSEQ", map.get("PRTSEQ"));	
			
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			commonDao.insert(row);
			
			count ++;
		}
		
		return count;
	}
	
	@Transactional
	public String closingDL04(DataMap map) throws SQLException {
		List<DataMap> headList = map.getList("head");
		
		// Validation
		StringBuffer sb = new StringBuffer();
		for(DataMap head : headList){
			if(sb.length() > 0)
				sb.append(" UNION ALL\n ");
			
			sb.append(" SELECT '").append(head.getMap("map").get("SHPOKY")).append("' AS SHPOKY FROM DUAL ");
		}
		
		map.setModuleCommand("WmsOutbound", "CLOSING_SHIPMENT"); // 쿼리키값 넣을것
		map.put("APPEND_QUERY", sb.toString());
		List<DataMap> validList = commonDao.getValidation(map);
		if(validList.size() > 0){
			DataMap valid = validList.get(0);
			return valid.getString("RESULTMSG");
		}
		
		int itemCount = 0;
		for(DataMap head : headList){
			head.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			head.put("SHPOKY", head.getMap("map").get("SHPOKY"));
			
			commonDao.update("WmsOutbound.ClosingShipment", head);
		}
		return "OK";
	}

	@Transactional
	public String DL04StockValidation(DataMap map) throws SQLException {
		String result = "OK";
		
		StringBuffer sb = new StringBuffer();	
		List<DataMap> itemList = map.getList("list");
		DataMap rowInfo = map.getMap("headData");
		
		for(DataMap item : itemList){
			if(sb.length() > 0)
				sb.append(" UNION ALL\n ");
			
				sb.append(" SELECT '").append(item.getMap("map").get("WAREKY")).append("' AS WAREKY, ");
				sb.append("        '").append(item.getMap("map").get("LOTNUM")).append("' AS LOTNUM, ");
				sb.append("        '").append(item.getMap("map").get("LOCAKY")).append("' AS LOCAKY, ");
				sb.append("        '").append(item.getMap("map").get("TRNUID")).append("' AS TRNUID, ");
				sb.append("        '").append(item.getMap("map").get("PACKID")).append("' AS PACKID, ");
				sb.append("        '").append(item.getMap("map").get("TASKKY")).append("' AS TASKKY, ");
				sb.append("        '").append(item.getMap("map").get("TASKIT")).append("' AS TASKIT, ");
				sb.append("        '").append(item.getMap("map").get("QTSALO")).append("' AS QTTAOR FROM DUAL ");
		}

		map.setModuleCommand("WmsOutbound", "DL04_STOCK"); // 쿼리키값 넣을것
		map.put("APPEND_QUERY", sb.toString());

		List<DataMap> validList = commonDao.getValidation(map);
		if(validList.size() > 0){
			DataMap valid = validList.get(0);
			return valid.getString("RESULTMSG");
		}
		
		log.debug("DL04StockValidation ALSTKY ::"+rowInfo.get("ALSTKY"));
		
		//[2021.07.20] Modify junghyojin - 수정된 행 할당전략키에 해당하는지 체크하여 메세지 처리
		DataMap row = new DataMap();
		String rowState = "";
		StringBuffer sbupd = new StringBuffer();	
		for(int j=0;j<itemList.size();j++){
			row = itemList.get(j).getMap("map");
			rowState = row.getString(CommonConfig.GRID_ROW_STATE_ATT);
			log.debug("DL04StockValidation QTSALO ::"+row.getMap("map").getInt("QTSALO"));
			if( rowState.charAt(0)  == 'U' && row.getMap("map").getInt("QTSALO") > 0){ //수량 변화 있음
				if(sbupd.length() > 0)
				sbupd.append(" UNION ALL\n ");
				
				sbupd.append(" SELECT '").append(row.getMap("map").get("WAREKY")).append("' AS WAREKY, ");
				sbupd.append("        '").append(row.getMap("map").get("LOTNUM")).append("' AS LOTNUM, ");
				sbupd.append("        '").append(row.getMap("map").get("LOCAKY")).append("' AS LOCAKY, ");
				sbupd.append("        '").append(row.getMap("map").get("TRNUID")).append("' AS TRNUID, ");
				sbupd.append("        '").append(row.getMap("map").get("PACKID")).append("' AS PACKID, ");
				sbupd.append("        '").append(rowInfo.get("ALSTKY")).append("' AS ALSTKY FROM DUAL ");
			}
		}
		
		map.setModuleCommand("WmsOutbound", "DL06_ALSTKY"); 
		map.put("APPEND_QUERY", sbupd.toString());
		List<DataMap> validAlstkyList = commonDao.getValidation(map);
		
		if(validAlstkyList.size() > 0){
			DataMap valid = validAlstkyList.get(0);
			return valid.getString("RESULTMSG");
		}
		return result;
	}
	
	@Transactional
	public List<DataMap> dl06Head(DataMap map) throws SQLException {
		map.setModuleCommand("Mobile", "MDL06HEAD");
		List<DataMap> list = commonDao.getList(map);
		
		return list;
		
	}
	
	@Transactional
	public List<DataMap> fullPkChk(DataMap map) throws SQLException {
		List<DataMap> rtnList = new ArrayList<DataMap>();
		List<DataMap> headList = map.getList("headList");
		DataMap headRow = new DataMap();
		
		String sqlStr = "";
		for(int i=0; i<headList.size(); i++){
			headRow = headList.get(i).getMap("map");
			
			if(i==0){
				sqlStr += "'"+headRow.getString("SHPOKY")+"'";
			}else{
				sqlStr += ",'"+headRow.getString("SHPOKY")+"'";
			}
		}
		
		map.setModuleCommand("WmsOutbound", "FULLPK_CHK");
		map.put("SHPOPYS",sqlStr);
		rtnList = commonDao.getList(map);
		
		return rtnList;
	}
	
	@Transactional(propagation = Propagation.NESTED, rollbackFor={SQLException.class})
	public DataMap MDL16PikingSave(DataMap map) throws SQLException {
			int headModifyIndex = -1;
			List<DataMap> itemList = null;
			List docNumList = new ArrayList();
			
			
			if(map.containsKey("headModifyIndex")){
				headModifyIndex = map.getInt("headModifyIndex");
				//itemList = map.getList("list");
			}
			
			List<DataMap> headList = map.getList("headList");
			List<DataMap> dataList = null;
			List<DataMap> dataList2 = null;
			DataMap row,chkMap;
			int count = 0;
			StringBuffer chkSb = new StringBuffer();
			
			List<DataMap> paramItemList = new ArrayList<DataMap>();
			DataMap paramItemMap = new DataMap();
			DataMap paramTasdrMap = new DataMap();
			DataMap copy = new DataMap();
			Map sortMap = new HashMap();
			DataMap statdoMap = new DataMap();
			
			try {
				String shpmty = map.getString("SHPMTY");
				
				//if((shpmty.equals("211") || shpmty.equals("214"))){
					for(int i=0; i<headList.size(); i++){
						row = headList.get(i).getMap("map");
					}
				//}
				
				for(int i=0;i<headList.size();i++){
					if(map.containsKey("param")){
						row = new DataMap(map.getMap("param").getMap("map"));
					}else{
						row = new DataMap();
					}
					
					map.clonSessionData(row);
					row.append(headList.get(i).getMap("map"));
					paramItemList = new ArrayList<DataMap>();
					
					//피킹완료 직전 한번더 상태체크 해당 문서가 피킹완료 상태이면 거른다
					row.setModuleCommand("WmsOutbound", "SHPDHSTATDO");
					statdoMap = commonDao.getMap(row);
					
					if(statdoMap != null && "FPK".equals(statdoMap.getString("STATDO"))
						|| statdoMap != null && "FPC".equals(statdoMap.getString("STATDO"))	){
						
						TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
						throw new SQLException(row.getString("SHPOKY") + "는 이미  피킹완료 되었습니다.");
					}else if(statdoMap != null && "CAN".equals(statdoMap.getString("STATDO"))	){
						
						TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
						throw new SQLException(row.getString("SHPOKY") + "는 이미  취소 되었습니다.");
					}
					
//					if(headModifyIndex == i){	
//						for(int j=0;j<itemList.size();j++){
//							copy = new DataMap(itemList.get(j).getMap("map"));
//							paramItemList.add(copy);
//						}
//					}else{
						row.setModuleCommand("WmsTask", "MDL16TASDI");
						row.put("QTY_COPY", "Y");
						List<DataMap> tasdiList = commonDao.getList(row);
						for(int j = 0; j < tasdiList.size(); j++){
							copy = new DataMap(tasdiList.get(j));
							paramItemList.add(copy);
						}
//					}
					//insert
					for(int j = 0; j < paramItemList.size(); j++){
						paramItemMap = paramItemList.get(j);
						
						//remove
						paramItemMap.setModuleCommand("WmsTask", "TASDIDEL");
						commonDao.delete(paramItemMap);
						
						
						paramItemMap.setModuleCommand("WmsTask", "TASDIEND");
						paramItemMap.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
						
						// "FPC" 작업수량 = 작업완료수량  
						// "PPC" 작업수량 > 작업완료수량
						// "OPC" 작업수량 < 작업완료수량 
						int STAUES = Integer.parseInt(paramItemMap.getString("QTTAOR") )- Integer.parseInt(paramItemMap.getString("QTCOMP"));
						if (STAUES == 0) {
							paramItemMap.put("STATIT","FPC");
						} else if (STAUES == 1) {
							paramItemMap.put("STATIT","PPC");
						} else if (STAUES == -1) {
							paramItemMap.put("STATIT","OPC");
						}
						commonDao.insert(paramItemMap);
						
						paramItemMap.put("ERRNUM",0);
						paramItemMap.put("ERRMSG", "");
						paramItemMap.setModuleCommand("WmsOutbound", "SZPINSTASDR");
						commonDao.update(paramItemMap);
						
						/*paramItemMap.setModuleCommand("WmsOutbound", "CHKPK");
						chkMap = commonDao.getMap(paramItemMap);
						
						if(chkMap.getInt("CNT")>0){
							sortMap.put(chkMap.getString("SHPOKY"),chkMap.getString("SHPOKY") +" | 품번 : "+ chkMap.getString("SKUKEY"));
						}*/
					}
					docNumList.add(row.getString("TASKKY"));
					count++;
				}
			}catch (Exception e) {
				log.debug(e.getMessage());
				throw new SQLException(e.getMessage());
				//e.printStackTrace();
				//String msg = e.getMessage();
				//String errmsg =	msg.substring(msg.indexOf("SQLException:"),msg.indexOf('*'));
				//returnMap.put("ERRMSG", errmsg);
				
			}
			
			//오름차순 정렬
			TreeMap<String, String> treeMap = new TreeMap<String, String>( sortMap );
			Iterator<String> treeMapIter = treeMap.keySet().iterator();
			while( treeMapIter.hasNext()) {
				chkSb.append(treeMap.get( treeMapIter.next() )).append(" ");
			}
		
			//할당전략 안맞을때
			if(chkSb.toString().length()>2){
				TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
			    throw new SQLException(chkSb.toString() + "는 할당전략에 맞는 재고가 없습니다.");
			}

			StringBuilder sb = new StringBuilder();
			for(int i=0;i<docNumList.size();i++){
				if(i != 0){
					sb.append(",");
				}
				sb.append("'").append(docNumList.get(i)).append("'");
			}
			
			map.setModuleCommand("WmsOutbound", "DL06HEADSAVE");
			map.put("TASKKYS", sb.toString());
			
			DataMap rtnMap = new DataMap();
			rtnMap.put("data", commonDao.getList(map));
			
			return rtnMap;	
	}
	 
	@Transactional
	public List<DataMap> dl06HeadNew(DataMap map) throws SQLException {
			map.setModuleCommand("WmsOutbound", "MDL16");
			List<DataMap> list = commonDao.getList(map);
			
			return list;
			
	}
	
	//[DL05] 출고 검수 저장(SHPDI 검품수량 UPDATE)
	@Transactional
	public DataMap saveDL05(DataMap map) throws SQLException {
		List<DataMap> head = map.getList("head");
		List<DataMap> itemList = map.getList("list");
		List<DataMap> selectList = new ArrayList<DataMap>();
		String HeadGridShpoky = map.get("HeadGridShpoky").toString();
		
		DataMap row;
		DataMap itemRow;
		List shpokyList = new ArrayList();
		DataMap validMap = new DataMap();
		DataMap rsMap = new DataMap();
		
		int count = 0;
		int validationCount = 0;
		
		for(int i = 0 ; i < head.size() ; i ++){
			String shpokyNum = head.get(i).getMap("map").getString("SHPOKY");
			shpokyList.add(shpokyNum);
			
			//여러개 head를 체크했을 경우
			//화면에 보여지는 item의 shpoky는 화면에 입력한 검수수량으로 update
			if(head.get(i).getMap("map").getString("SHPOKY").equals(HeadGridShpoky)){
				//validation
				if(HeadGridShpoky.equals(itemList.get(0).getMap("map").getString("SHPOKY"))){
					selectList = itemList;
				}
				
				for(int j=0;j<selectList.size();j++){
					itemRow = selectList.get(j).getMap("map");
					
					String itemStrQtaloc = itemRow.getString("QTALOC");
					String itemStrQtjcmp = itemRow.getString("QTJCMP");
					int itemStrQtshpc = Integer.parseInt(itemRow.getString("QTSHPC"));
					int itemStrDbqtshpc = Integer.parseInt(itemRow.getString("DBQTSHPC"));

					//validation
					itemRow.put("WAREKY", head.get(i).getMap("map").getString("WAREKY"));
					validMap = commonDao.getMap("WmsOutbound.DL05Validation1", itemRow);
					
					String validMsg = validMap.getString("MSG");
					if("OK".equals(validMsg)){
						//할당수량=피킹수량이 같아야만 검수 가능
						//할당수량이 피킹수량보다 더 클 경우 피킹중인걸로 판단됨
						if( !("0".equals(itemStrQtaloc)) ){
							if( !("0".equals(itemStrQtjcmp)) ){
								itemRow.put("QTSHPC", itemStrQtshpc+itemStrDbqtshpc);
								itemRow.put(CommonConfig.SES_USER_ID_KEY,	map.get(CommonConfig.SES_USER_ID_KEY));
		
								commonDao.update("WmsOutbound.DL05Sub", itemRow);
								rsMap.put("MSG", validMsg);
							}
						}
					}else{
						rsMap.put("MSG", validMsg);
						validationCount++;
						break;
					}
					count++;
				}
				
			}else{//화면에 보여지지 않는 shpoky는 db의 피킹완료수량으로 검수수량에 update
				row = head.get(i).getMap("map");
				
				//validation
				validMap = commonDao.getMap("WmsOutbound.DL05Validation2", row);
				
				String validMsg = validMap.getString("MSG");
				if("OK".equals(validMsg)){
					//SHPDI SELECT
					List<DataMap> list = commonDao.getList("WmsOutbound.DL05Sub", row);
					
					for(int j = 0 ; j < list.size() ; j ++){
						itemRow = list.get(j);
						
						String itemStrQtaloc = itemRow.getString("QTALOC");
						int itemQtaloc = Integer.parseInt(itemRow.getString("QTALOC"));
						int itemQtjcmp = Integer.parseInt(itemRow.getString("QTJCMP"));
						
						//할당수량=피킹수량이 같아야만 검수 가능
						//할당수량이 피킹수량보다 더 클 경우 피킹중인걸로 판단됨
						if(itemQtaloc == itemQtjcmp){
							if( !("0".equals(itemStrQtaloc)) ){
								itemRow.put("QTSHPC", itemQtjcmp);
								itemRow.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
								itemRow.put(CommonConfig.SES_USER_ID_KEY, 		  map.get(CommonConfig.SES_USER_ID_KEY));
								
								commonDao.update("WmsOutbound.DL05Sub", itemRow);
								rsMap.put("MSG", validMsg);
							}
						}
					}
				}else{
					rsMap.put("MSG", validMsg);
					validationCount++;
					break;
				}
				count++;
			}
			
			StringBuilder sb = new StringBuilder();
			for(int k = 0 ; k < shpokyList.size() ; k ++){
				if(k != 0){
					sb.append(",");
				}
				sb.append("'").append(shpokyList.get(k)).append("'");
			}
			rsMap.put("SHPOKY", sb.toString());
		}
		
		return rsMap;
	}		
		
	/**
	 * WDL00 : 삭제
	 */
	@Transactional
	public int waveDelete(DataMap map) throws SQLException {
			List<DataMap> head = map.getList("head");
			List<DataMap> selectList =  new ArrayList<DataMap>();
			int count = 0;
			
			DataMap row;
			DataMap itemRow;
			for(int i=0;i<head.size();i++){
				row = head.get(i).getMap("map");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
				row.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
				
				commonDao.delete("WmsOutbound.SHPDI", row);
				commonDao.delete("WmsOutbound.SHPDH", row);
				
				//원 출고문서 조회
				row.setModuleCommand("WmsOutbound", "WAVECANCEL_SHPOKY");
				selectList = commonDao.getList(row);
				for(int j=0;j<selectList.size();j++){
					itemRow = selectList.get(j).getMap("map");
						
//					commonDao.delete("WmsOutbound.SHPDI", itemRow);
//					commonDao.delete("WmsOutbound.SHPDH", itemRow);	
					itemRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
					commonDao.update("WmsOutbound.WAVECANCEL_SHPDI", itemRow);
					
					itemRow.put("PGRC01", " ");
					itemRow.put("STATDO", "NEW");
					itemRow.put("DOCTXT", " ");
					itemRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
					commonDao.update("WmsOutbound.WDL00_SHPDH", itemRow);
				}
				count ++;
			}
			return count;
	}

	/**
	 * WDL04 : 그룹오더할당(상품)
	 */	 
	@Transactional
	public DataMap totalAssignWDL04(DataMap map) throws SQLException{
		List<DataMap> head = map.getList("head");
		List<DataMap> item = map.getList("item");
		
		DataMap row = new DataMap();
		DataMap itemrow = new DataMap();
		StringBuilder sb = new StringBuilder();
		
		for(int i=0; i<head.size(); i++){
			row = head.get(i).getMap("map");
			map.clonSessionData(row);
			
			// 1. 그룹오더인지 체크
			row.setModuleCommand("WmsOutbound", "CNTGRPDOC");
			int count =  commonDao.getMap(row).getInt("CNT");
			if(count > 0){
				//2021.09.09 통합작업번호 --> ITEM별 할당처리로 변경
				//2. 통합작업번호로 할당처리
				//commonDao.getMap("WmsOutbound.ALLOC_TOTSHIP_PROCALL", row);
				//commonDao.getMap("WmsOutbound.ALLOC_TOTSUB_PROCALL", row);
			//}
				
				//2.ITEM별 할당처리
				for(int j=0; j<item.size(); j++){
					itemrow = item.get(j).getMap("map");
					map.clonSessionData(itemrow);
					
					if(row.getString("SHPOKY").equals(itemrow.getString("SHPOKY"))){
						commonDao.getMap("WmsOutbound.ALLOC_ITEM_PROCALL", itemrow);
					}else{
						row.put("SHPOIT", "%");
						commonDao.getMap("WmsOutbound.ALLOC_ITEM_PROCALL", row);
					}
				}
			}
			if(i != 0){
				sb.append(",");
			}
			sb.append("'").append(row.getString("SHPOKY")).append("'");
		}
		DataMap rsMap = new DataMap();
		rsMap.put("SHPOKY", sb.toString());
		return rsMap;
	}
	
	@Transactional
	public String SaveWDL05(DataMap map) throws SQLException {
		String result = "OK";
		
		List<DataMap> list = map.getList("list");
		List<DataMap> Tablist = new ArrayList<DataMap>();
		
		DataMap row;
		DataMap Tabrow;
		
		//DataMap Tablist;
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.clonSessionData(row);
			
			row.put("STATIT", "FCK"); //검수완료처리
			commonDao.update("WmsOutbound.WDL05", row);
			
			//해당 Gropky에 대한 list
//			Tablist = commonDao.getList("WmsOutbound.WDL05Tab", row);
//			if(Tablist.size() > 1){
//				for(int j=0; j<Tablist.size(); j++){
//					Tabrow = Tablist.get(j).getMap("map");
//					map.clonSessionData(Tabrow);
//					
//					int qtshpc = parseInt(row.get("QTSHPC"));
//					int qtjcmp = parseInt(Tabrow.get("QTJCMP"));
//					int divide = parseInt(qtshpc/qtjcmp);
//					
//					if(!("0".equals(divide))) {
//						Tabrow.put("QTSHPC", qtjcmp);
//					}else {
//						Tabrow.put("QTSHPC", qtshpc%qtjcmp);
//					}
//					qtshpc = qtshpc - qtjcmp;
//					row.put("STATIT", "FCK"); //검수완료처리
//					commonDao.update("WmsOutbound.WDL05", Tabrow);
//				}
//			}
		}
		return result;
	}
	
	private int parseInt(Object object) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Transactional
	public String CheckCancel(DataMap map) throws SQLException {
		String result = "OK";
		//List<DataMap> head = map.getList("head");
		//List<DataMap> list = map.getList("item");		
		try{

			
			int headModifyIndex = -1;
			List<DataMap> itemList = null;
			if(map.containsKey("headModifyIndex")){
				headModifyIndex = map.getInt("headModifyIndex");
				itemList = map.getList("item");
			}
			
			List<DataMap> headList = map.getList("head");
			
			DataMap row;
			
			List docNumList = new ArrayList();
			List<DataMap> paramItemList = new ArrayList<DataMap>();
			DataMap copy = new DataMap();
			DataMap itemMap = new DataMap();
			
			for(int i=0;i<headList.size();i++){
				if(map.containsKey("param")){
					row = new DataMap(map.getMap("param").getMap("map"));
				}else{
					row = new DataMap();
				}				
				
				map.clonSessionData(row);
				row.append(headList.get(i).getMap("map"));
				docNumList.add(headList.get(i).getMap("map").get("SHPOKY"));
				
				paramItemList = new ArrayList<DataMap>();
				if(headModifyIndex == i){	
					for(int j=0;j<itemList.size();j++){
						copy = new DataMap(itemList.get(j).getMap("map"));
						paramItemList.add(copy);
					}
				}else{
					row.setModuleCommand("WmsOutbound", "DL08Sub");
					List<DataMap> dl08subList = commonDao.getList(row);
					for(int j = 0; j < dl08subList.size(); j++){
						copy = new DataMap(dl08subList.get(j));
						paramItemList.add(copy);
					}
				}
				
				String statit = "";
				for(int j=0;j<paramItemList.size();j++){
					itemMap = paramItemList.get(j);
					map.clonSessionData(itemMap);
					
					statit = itemMap.getString("STATIT");														
					// 1. 출하문서번호 검수수량 취소 업데이트
					if("PCK".equals(statit) || "FCK".equals(statit)){
						itemMap.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
						commonDao.update("WmsOutbound.WDL05Cancel", itemMap);						
						
						// 2. 그룹오더인지 체크하여 원출고문서 출하완료 처리
						itemMap.setModuleCommand("WmsOutbound", "CNTGRPDOC");
						int countCHK =  commonDao.getMap(itemMap).getInt("CNT");
						if(countCHK > 0){
							// 2-1. 원출고문서 검수취소완료 처리							
							itemMap.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));						
							commonDao.update("WmsOutbound.WDL05GroupCancel", itemMap);							
						}else {
							// 2-2. 그룹오더 출하문서번호 검수수량 취소 업데이트		
							if( itemMap.getString("REFDKY") != null && !itemMap.getString("REFDKY").equals("")){
								itemMap.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
								itemMap.put("SHPOKY", itemMap.getString("REFDKY"));
								itemMap.put("SHPOIT", itemMap.getString("REFDIT"));							
								commonDao.update("WmsOutbound.WDL05Cancel", itemMap);			
							}							
						}
					}					
				}				
			}
		}catch(Exception e){
			log.debug("CheckCancel validataion error = "+e);
		}
		log.debug(":::::::::::::::::::::"+result);		

		return result;
	}
	
	@Transactional
	public String validateInsepectSave(DataMap map) throws SQLException {
		String result = "OK";
		
		int headModifyIndex = -1;
		List<DataMap> itemList = null;
		if(map.containsKey("headModifyIndex")){
			headModifyIndex = map.getInt("headModifyIndex");
			itemList = map.getList("list");
		}
		
		List<DataMap> headList = map.getList("head");
		
		DataMap row;
		DataMap rsMap;

		List<DataMap> paramItemList = new ArrayList<DataMap>();
		DataMap copy = new DataMap();
		DataMap paramItemMap = new DataMap();
		DataMap paramLocMap = new DataMap();
		
		
		for(int i=0;i<headList.size();i++){			
			if(map.containsKey("param")){
				row = new DataMap(map.getMap("param").getMap("map"));
			}else{
				row = new DataMap();
			}				
			
			map.clonSessionData(row);
			row.append(headList.get(i).getMap("map"));
			paramItemList = new ArrayList<DataMap>();
			
			if(headModifyIndex == i){	
				for(int j=0;j<itemList.size();j++){
					copy = new DataMap(itemList.get(j).getMap("map"));
					paramItemList.add(copy);
				}
			}else{
				row.setModuleCommand("WmsOutbound", "WDL05Sub");
				List<DataMap> tasdiList = commonDao.getList(row);
				for(int j = 0; j < tasdiList.size(); j++){
					copy = new DataMap(tasdiList.get(j));
					copy.put("QTSHPC", tasdiList.get(j).getString("QTJCMP"));
					paramItemList.add(copy);
				}
			}
			
			StringBuffer sb = new StringBuffer();
			
			for(int j = 0; j < paramItemList.size(); j++){
				paramItemMap = paramItemList.get(j);
				map.clonSessionData(paramItemMap);
				
		    	if(sb.length() > 0)
				sb.append(" UNION ALL\n ");
		    	
				sb.append(" SELECT '").append(paramItemMap.get("WAREKY")).append("' AS WAREKY, ");
				sb.append("        '").append(paramItemMap.get("SHPOKY")).append("' AS SHPOKY, ");
				sb.append("        '").append(paramItemMap.get("SHPOIT")).append("' AS SHPOIT, ");
				sb.append("        '").append(paramItemMap.get("QTSHPC")).append("' AS QTSHPC FROM DUAL ");				
				
			}
			
			map.setModuleCommand("WmsOutbound", "WDL05");
			map.put("APPEND_QUERY", sb.toString());
			

			List<DataMap> validList = commonDao.getValidation(map);
			if(validList.size() > 0){
				DataMap valid = validList.get(0);
				return valid.getString("RESULTMSG");
			}			
		}

		return result;
	}	
	
	@Transactional
	public DataMap saveInspectWDL05(DataMap map) throws SQLException {
		int headModifyIndex = -1;
		List<DataMap> itemList = null;
		if(map.containsKey("headModifyIndex")){
			headModifyIndex = map.getInt("headModifyIndex");
			itemList = map.getList("list");
		}
		
		List<DataMap> headList = map.getList("head");
		
		DataMap row;
		DataMap rsMap = new DataMap();

		List<DataMap> paramItemList = new ArrayList<DataMap>();
		DataMap copy = new DataMap();
		DataMap paramItemMap = new DataMap();
		DataMap paramLocMap = new DataMap();

		List docNumList = new ArrayList();
		String docNum;		
		for(int i=0;i<headList.size();i++){			
			if(map.containsKey("param")){
				row = new DataMap(map.getMap("param").getMap("map"));
			}else{
				row = new DataMap();
			}	
			
			map.clonSessionData(row);
			row.append(headList.get(i).getMap("map"));
			paramItemList = new ArrayList<DataMap>();
			
			docNum = row.getString("SHPOKY");
			
			if(headModifyIndex == i){					
				log.debug("saveInspectWDL05 if");	
				for(int j=0;j<itemList.size();j++){
					copy = new DataMap(itemList.get(j).getMap("map"));
					paramItemList.add(copy);
				}
			}else{
				log.debug("saveInspectWDL05 else");	
				row.setModuleCommand("WmsOutbound", "WDL05Sub");
				List<DataMap> tasdiList = commonDao.getList(row);
				for(int j = 0; j < tasdiList.size(); j++){
					copy = new DataMap(tasdiList.get(j));
					copy.put("QTSHPC", tasdiList.get(j).getString("QTJCMP"));
					paramItemList.add(copy);
				}
			}
			docNumList.add(docNum);
			
			for(int j = 0; j < paramItemList.size(); j++){
				paramItemMap = paramItemList.get(j);
				map.clonSessionData(paramItemMap);
				
				// PPC, FPC일 경우에만 검수되도록
				if ("PPC".equals(paramItemMap.getString("STATIT")) || "FPC".equals(paramItemMap.getString("STATIT"))) {
					// 검수수량 업데이트
					paramItemMap.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));				
					paramItemMap.setModuleCommand("WmsOutbound", "DL05Sub");		
					commonDao.update(paramItemMap);	
					
					// 총괄SUB검수 호출
					paramItemMap.setModuleCommand("WmsOutbound", "CALL_BATCH_INSPECT_TOT");
					commonDao.getMap(paramItemMap);					
				}						
			}
		}
		
		StringBuilder sb = new StringBuilder();
		for(int i=0;i<docNumList.size();i++){
			if(i != 0){
				sb.append(",");
			}
			sb.append("'").append(docNumList.get(i)).append("'");
		}
		
		log.debug("saveInspectWDL05 SHPOKY:" + sb.toString());								
		rsMap.put("SHPOKY", sb.toString());

		return rsMap;
	}	
	
	@Transactional
	public String saveInspectItemWDL05(DataMap map) throws SQLException {
		String result = "OK";
		
		List<DataMap> list = map.getList("list");		
		DataMap row;
		
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.clonSessionData(row);
			
			commonDao.update("WmsOutbound.WDL05Tab", row);
			
			//해당 Gropky에 대한 list			
			commonDao.update("WmsOutbound.WDL05", row);			

		}
		return result;
	}
	
	//[DL55] 출고 검수 Scan 저장(SHPDI 검품수량 UPDATE)
	@Transactional
	public DataMap saveDL55(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		DataMap itemRow;
		DataMap validMap;
		DataMap GroupMap;
		DataMap SumQtshpcMap;
		DataMap rsMap = new DataMap();
		
		int count = 0;
		int validationCount = 0;
		String progid = map.getString("PROGID");
		
		for(int j=0;j<list.size();j++){
			itemRow = list.get(j).getMap("map");
			
			//validation
			itemRow.put("WAREKY", map.getString("WAREKY"));
			validMap = commonDao.getMap("WmsOutbound.DL55Validation", itemRow);
			
			String validMsg = validMap.getString("MSG");
			if("OK".equals(validMsg)){
				String itemStrQtaloc = itemRow.getString("QTALOC");
				String itemStrQtjcmp = itemRow.getString("QTJCMP");
				int itemQtaloc = Integer.parseInt(itemRow.getString("QTALOC"));
				int itemQtjcmp = Integer.parseInt(itemRow.getString("QTJCMP"));
				int itemQtshpc = Integer.parseInt(itemRow.getString("QTSHPC"));
				int itemDBQtshpc = Integer.parseInt(itemRow.getString("DBQTSHPC"));

				//할당수량이 0이면 안되고, 피킹수량이 0이면 검수 진행 불가능
				if( !("0".equals(itemStrQtaloc)) ){
					if( !("0".equals(itemStrQtjcmp)) ){
						//그룹오더 키값 가져오기 위한 SELECT
						itemRow.put("WAREKY", map.getString("WAREKY"));
						itemRow.put("QTSHPC", itemQtshpc+itemDBQtshpc);
						itemRow.put(CommonConfig.SES_USER_ID_KEY,	map.get(CommonConfig.SES_USER_ID_KEY));

						commonDao.update("WmsOutbound.DL05Sub", itemRow);	//기존 오더 UPDATE

						//그룹오더 검수수량 UPDATE
						if(progid.equals("WDL55")){
							GroupMap = commonDao.getMap("WmsOutbound.WDL55GroupKey", itemRow);	//출고번호로 그룹오더번호 가져오는 SELECT
							
							GroupMap.put("WAREKY", map.getString("WAREKY"));
							SumQtshpcMap = commonDao.getMap("WmsOutbound.WDL55GroupQtshpc", GroupMap);	//그룹오더 SELECT

							int GroupItemDBQtshpc = Integer.parseInt(SumQtshpcMap.getString("QTSHPC"));

							GroupMap.put("GRQTSHPC", itemQtshpc+GroupItemDBQtshpc);
							GroupMap.put(CommonConfig.SES_USER_ID_KEY,	map.get(CommonConfig.SES_USER_ID_KEY));

							GroupMap.put("GSHPOKY", GroupMap.getString("REFDKY"));
							GroupMap.put("GSHPOIT", GroupMap.getString("REFDIT"));
							commonDao.update("WmsOutbound.WDL55GroupSub", GroupMap);	//그룹 오더 UPDATE
						}

						rsMap.put("MSG", validMsg);
					}
				}
			}else{
				rsMap.put("MSG", validMsg);
				validationCount++;
				break;
			}
			count++;
		}
				
		return rsMap;
	}
	
	@Transactional
	public DataMap DL05CheckCancel(DataMap map) throws SQLException {
		List<DataMap> head = map.getList("head");
		List<DataMap> selectList = new ArrayList<DataMap>();
		DataMap rsMap = new DataMap();
		
		try{
			List docNumList = new ArrayList();
			DataMap row;
			DataMap itemRow;

			for(int i=0;i<head.size();i++){
				docNumList.add(head.get(i).getMap("map").get("SHPOKY"));
				
				row = head.get(i).getMap("map");
				
				//SHPDI SELECT
				List<DataMap> list = commonDao.getList("WmsOutbound.DL08Sub", row);
				
				for(int j = 0 ; j < list.size() ; j ++){
					itemRow = list.get(j);
					
					String statit = itemRow.getString("STATIT");														
					// 1. 출하문서번호 검수수량 취소 업데이트
					if("PCK".equals(statit) || "FCK".equals(statit)){
						itemRow.put("WAREKY", map.getString("WAREKY"));
						itemRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
						commonDao.update("WmsOutbound.DL05Cancel", itemRow);
						
						commonDao.update("WmsOutbound.DL05CancelStatdo", itemRow);
					}
				}
				
				StringBuilder sb = new StringBuilder();
				for(int k = 0 ; k < docNumList.size() ; k ++){
					if(k != 0){
						sb.append(",");
					}
					sb.append("'").append(docNumList.get(k)).append("'");
				}
				rsMap.put("SHPOKY", sb.toString());
			}
		}catch(Exception e){
			log.debug("CheckCancel validataion error = "+e);
		}
		log.debug("DL05CheckCancel::::::::::::::::::::: "+rsMap);		
		
		return rsMap;
	}
	
	@Transactional
	public DataMap waveCreate(DataMap map) throws SQLException{
		
		List<DataMap> head = map.getList("head");
		List<DataMap> itemList = map.getList("list");
		List<DataMap> selectList = new ArrayList<DataMap>();
		int count = 0;
		String HeadGridSvbeln = map.get("HeadGridSvbeln").toString();
		String HeadGridShpoky = map.get("HeadGridShpoky").toString();
		String SelectDocgrp   = map.get("GSHTYP").toString();  //그룹출고유형		
		
		int headModifyIndex = -1;
		if(map.containsKey("headModifyIndex")){
			headModifyIndex = map.getInt("headModifyIndex");
		}
		
		DataMap row = new DataMap();
		String docNum;
		int itemCount = 0;
		
		String progress01 = wmsService.getNumSeq("NR07");

	    log.debug("waveCreate processID:::::::::::::::::::::"+progress01+"/docgrp:::::"+SelectDocgrp);
		for(int i=0;i<head.size();i++){
			row = head.get(i).getMap("map");
			//1-1. 출고문서번호가 없을 때 저장 후, 할당
			if("".equals(row.getString("SHPOKY").trim())){
				docNum = wmsService.getDocSeq(row.getString("DOCUTY"));
				row.put("SHPOKY", docNum);
				row.put("PGRC01", progress01);
				row.put("STATDO", "REF"); //2021.08.25 JHJ 원출하문서상태를 REF로 한다.
				row.setModuleCommand("WmsOutbound", "SHPDH");
				commonDao.insert(row);
				
				if(headModifyIndex == i){
					row.setModuleCommand("WmsOutbound", "SHPDI");
					for(int j=0;j<itemList.size();j++){
						row.append(itemList.get(j).getMap("map"));
						
						itemCount += 10;
						String snum = String.valueOf(itemCount);
						String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
						row.put("SHPOKY", docNum);
						row.put("SHPOIT", inum);
						row.put("STATIT", "REF"); //2021.08.25 JHJ 원출하문서상태를 REF로 한다.
						commonDao.insert(row);
					}
				}else{ 
					row.setModuleCommand("WmsOutbound", "DL04Sub");
					selectList = commonDao.getList(row);	
					for(int j=0;j<selectList.size();j++){
						row.append(selectList.get(j).getMap("map"));
						
						row.setModuleCommand("WmsOutbound", "SHPDI");
						
						itemCount += 10;
						String snum = String.valueOf(itemCount);
						String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
						
						row.put("SHPOKY", docNum);
						row.put("SHPOIT", inum);
						row.put("STATIT", "REF"); //2021.08.25 JHJ 원출하문서상태를 REF로 한다.						
						commonDao.insert(row);
					}
				}
			//1-2. 출고문서번호가 있을 때 업데이트
			}else {
				row.put("PGRC01", progress01);
				row.put("STATDO", "REF"); //2021.08.25 JHJ 원출하문서상태를 REF로 한다.											
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				
				row.setModuleCommand("WmsOutbound", "WDL00_SHPDH");						
				commonDao.update(row);					
			}			
		}
		
		//2. 그룹오더 출고문서 생성 호출
		row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		row.put("PGRC01", progress01);
		row.put("SHPMTY", SelectDocgrp);
		commonDao.getMap("WmsOutbound.TOTALSHIPMENT_PROCALL", row);		
		
		DataMap rsMap = new DataMap();
		rsMap.put("PGRC01", progress01);
		
		return rsMap;
	}	
	
}