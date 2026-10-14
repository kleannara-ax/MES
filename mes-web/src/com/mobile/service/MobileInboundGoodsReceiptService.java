package com.mobile.service;

import java.sql.SQLException;
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
public class MobileInboundGoodsReceiptService {

	@Autowired
	public CommonDAO commonDao;
	
	@Autowired
	public WmsService wmsService;
	
	@Autowired
	private Util util;
	
	
	@Transactional
	public String savePDGR01(DataMap map) throws Exception {
		// Validation
		StringBuffer sb = new StringBuffer();
		String rcptty = map.getString("ASNTTY");
		sb.append("SELECT  '").append(map.get("ASNTTY")).append("' AS RCPTTY, ");
		sb.append("        '").append(map.get("PTNRKY")).append("' AS PTNRKY, ");
		sb.append("        '").append(map.get("ASNINV")).append("' AS ASNDKY, ");
		sb.append("        '").append(map.get("LOCAKY")).append("' AS LOCAKY, ");
		sb.append("        '").append(map.get("SKUKEY")).append("' AS SKUKEY, ");
		sb.append("         ").append(map.get("QTYRCV")).append("  AS QTYRCV, ");
		sb.append("        '").append(map.get("RCVLMT")).append("' AS RCVLMT, ");
		sb.append("         ").append(map.get("LOTA12")).append("  AS LOTA12, ");
		sb.append("        '").append(map.get("LOTA13")).append("' AS LOTA13, ");
		sb.append("        '").append(map.get("VEHDAT")).append("' AS VEHDAT, ");
		sb.append("        '").append(map.get(CommonConfig.SES_USER_OWNER_KEY).toString()).append("'  AS OWNRKY, ");
		sb.append("        '").append(map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY)).append("'  AS WAREKY, ");
		sb.append("        '").append(map.get("UOMKEY")).append("' AS UOMKEY FROM DUAL ");
		
		map.put("VALIDATION_SQL", sb.toString());
		map.put("RCPTTY", map.get("ASNTTY"));
		map.put("LOCAKY", map.get("LOCAKY"));
		map.setModuleCommand("WmsMobileInboundGoodsReceipt", "PDGR01"); // 쿼리키값 넣을것
		List<DataMap> validList = commonDao.getValidation(map);
		if(validList.size() > 0){
			for(DataMap valid : validList){
				if(!valid.getString("MSG").equals("OK"))
					return valid.getString("MSG");
			}
		}
		
		String docNum = wmsService.getDocSeq(rcptty);
		
		map.put("RECVKY", docNum);
		map.put("ASNDKY", map.getString("ASNDKY"));
		map.put("OWNRKY", map.get(CommonConfig.SES_USER_OWNER_KEY));
		map.put("WAREKY", map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
		map.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		map.put("BARCOD", map.getString("SKUKEY"));
		
		commonDao.insert("WmsMobileInboundGoodsReceipt.PDGR01_H", map);
		commonDao.insert("WmsMobileInboundGoodsReceipt.PDGR01_I", map);
		
		return docNum;
	}
	
	@Transactional
	public String savePDGR01_POP(DataMap map) throws Exception {
		List<DataMap> list = map.getList("list");
		
		// Validation
		StringBuffer sb = new StringBuffer();
		for(DataMap item : list){
			if(sb.length() > 0)
				sb.append(" UNION ALL\n ");
			
			String rcptty = map.getString("ASNTTY");
			sb.append("SELECT  '").append(map.get("ASNTTY")).append("' AS RCPTTY, ");
			sb.append("        '").append(map.get("PTNRKY")).append("' AS PTNRKY, ");
	 		sb.append("        '").append(map.get("ASNINV")).append("' AS ASNDKY, ");
	 		sb.append("        '").append(map.get("ASNDIT")).append("' AS ASNDIT, ");
			sb.append("        '").append(item.getMap("map").get("LOCAKY")).append("' AS LOCAKY, ");
			sb.append("        '").append(map.get("SKUKEY")).append("' AS SKUKEY, ");
			sb.append("        '").append(map.get("EANCOD")).append("' AS EANCOD, ");
			sb.append("         ").append(item.getMap("map").get("QTYRCV")).append("  AS QTYRCV, ");
			sb.append("        '").append(item.getMap("map").get("RCVLMT")).append("' AS RCVLMT, ");
			sb.append("         ").append(item.getMap("map").get("LOTA12")).append("  AS LOTA12, ");
			sb.append("        '").append(item.getMap("map").get("LOTA13")).append("' AS LOTA13, ");
			sb.append("        '").append(map.get(CommonConfig.SES_USER_OWNER_KEY).toString()).append("'  AS OWNRKY, ");
			sb.append("        '").append(map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY)).append("'  AS WAREKY, ");
			sb.append("        '").append(map.get("UOMKEY")).append("' AS UOMKEY FROM DUAL ");
		}
		
		map.put("VALIDATION_SQL", sb.toString());
		
		String rcptty = map.getString("ASNTTY");
		
		map.put("RCPTTY", rcptty);
		map.setModuleCommand("WmsMobileInboundGoodsReceipt", "PDGR01"); // 쿼리키값 넣을것
		List<DataMap> validList = commonDao.getValidation(map);
		if(validList.size() > 0){
			for(DataMap valid : validList){
				if(!valid.getString("MSG").equals("OK"))
					return valid.getString("MSG");
			}
		}
		
		//수량 체크
		int qty = 0;
		for(DataMap item : list){
			qty += item.getMap("map").getInt("QTYRCV");
		}
		
		map.put("ASNDKY",map.get("ASNINV"));
		map.put("QTY", qty);
		map.setModuleCommand("WmsMobileInboundGoodsReceipt", "PDGR01_POP"); // 쿼리키값 넣을것
		
		validList = commonDao.getValidation(map);
		if(validList.size() > 0){
			for(DataMap valid : validList){
				if(!valid.getString("MSG").equals("OK"))
					return valid.getString("MSG");
			}
		}
		
		String docNum = wmsService.getDocSeq(rcptty);
		
		map.put("RECVKY", docNum);
		map.put("ASNDKY", map.getString("ASNINV"));
		map.put("ASNDIT", map.getString("ASNDIT"));
		map.put("OWNRKY", map.get(CommonConfig.SES_USER_OWNER_KEY));
		map.put("WAREKY", map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
		map.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));

		commonDao.insert("WmsMobileInboundGoodsReceipt.PDGR01_H", map);
		
		DataMap row;
		int itemCount = 0;
		
		for(int i=0 ; i<list.size() ; i++){
			row = list.get(i).getMap("map");
			if(row.get("GRowState").equals("U") || row.get("GRowState").equals("C")){
				
				itemCount += 10;
				String snum = String.valueOf(itemCount);
				String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
				
				row.put("RECVKY", docNum);
				row.put("RECVIT", inum);
				row.put("ASNDKY", map.getString("ASNINV"));
				row.put("SKUKEY", map.getString("SKUKEY"));
				row.put("BARCOD", row.getString("EANCOD"));
				row.put("OWNRKY", map.get(CommonConfig.SES_USER_OWNER_KEY));
				row.put("WAREKY", map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				
				commonDao.insert("WmsMobileInboundGoodsReceipt.PDGR01_POP_I", row);
			}
		}
		
		return docNum;
	}

	@Transactional
	public String savePDGR02(DataMap map) throws Exception {
		int itemCount = 0;
		
		// Validation
		StringBuffer sb = new StringBuffer();
		String rcptty = map.getString("RCPTTY");
		sb.append("SELECT  '").append(map.get("SEBELN")).append("' AS SEBELN, ");
		sb.append("        '").append(map.get("RCPTTY")).append("' AS RCPTTY, ");
		sb.append("        '").append(map.get("LOCAKY")).append("' AS LOCAKY, ");
		sb.append("        '").append(map.get("SKUKEY")).append("' AS SKUKEY, ");
		sb.append("        '").append(map.get("LOTA12")).append("' AS LOTA12, ");
		sb.append("        '").append(map.get("LOTA13")).append("' AS LOTA13, ");
		sb.append("         ").append(map.get("QTYRCV")).append("  AS QTYRCV, ");
		sb.append("        '").append(map.get(CommonConfig.SES_USER_OWNER_KEY).toString()).append("'  AS OWNRKY, ");
		sb.append("        '").append(map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY)).append("'  AS WAREKY, ");
		sb.append("        '").append(map.get("UOMKEY")).append("' AS UOMKEY FROM DUAL ");
		
		map.put("VALIDATION_SQL", sb.toString());
		map.put("RCPTTY", map.get("RCPTTY"));
		map.put("LOCAKY", map.get("LOCAKY"));
		map.setModuleCommand("WmsMobileInboundGoodsReceipt", "PDGR02");
		List<DataMap> validList = commonDao.getValidation(map);
		if(validList.size() > 0){
			for(DataMap valid : validList){
				if(!valid.getString("MSG").equals("OK"))
					return valid.getString("MSG");
			}
		}
		
		//RECDH/I INSERT
		String docNum = wmsService.getDocSeq(rcptty);
		map.put("RECVKY", docNum);
		map.put("SEBELN", map.getString("SEBELN"));
		map.put("SEBELP", map.getString("SEBELP"));
		map.put("OWNRKY", map.get(CommonConfig.SES_USER_OWNER_KEY));
		map.put("WAREKY", map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
		map.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		map.put("BARCOD", map.getString("SKUKEY"));
		
		commonDao.insert("WmsMobileInboundGoodsReceipt.PDGR02", map);
		commonDao.insert("WmsMobileInboundGoodsReceipt.PDGR02Sub", map);

		
		return docNum;
	}
}