package com.test;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.common.bean.DataMap;
import com.common.dao.CommonDAO;
import com.common.service.BaseService;
import com.common.util.PostRequest;
import com.wms.service.OutboundService;

@Service
public class InterfaceService extends BaseService {
	
	private static Logger log = Logger.getLogger(OutboundService.class);
	
	@Autowired
	public CommonDAO commonDao;

	// sample
	public void seller(DataMap map, Map model) throws SQLException {
		    
		    log.info(map);
		
			List<DataMap> list = map.getList("Detail");
			List<DataMap> dataList = new ArrayList();
			
			DataMap row;
			int count = 0;
			for (int i = 0; i < list.size(); i++) {
				row = list.get(i).getMap("map");
				
				row.setModuleCommand("IF", "Master/Seller");
				
				DataMap result = new DataMap();
				
				row.get("EfmIfSeq");
				String EfmIfSeq = (String) row.get("EfmIfSeq");
				
				result.put("EfmIfSeq", EfmIfSeq);
				try {
					commonDao.insert(row);
					result.put("ResultCode", "0");
					result.put("Message", "SUCCESS");

				} catch (Exception e) {
					if(!model.containsKey("RESULT")){
						model.put("ResultCode", "1");
						model.put("Message", "FAIL");
					}
					result.put("ResultCode", "1");
					result.put("Message", "FAIL");
					log.info(e.getMessage());
				}
				dataList.add(result);
				log.info(result);
			}
			
			model.put("Data", dataList);
			log.info(model);
		}

	
	
	
	//seller
	/*public void seller(DataMap map, Map model) throws SQLException {
		log.info(map);
		if(map.containsKey("Detail")){
			List<DataMap> list = map.getList("Detail");
			List<DataMap> dataList = new ArrayList();
			
			DataMap head = new DataMap();
			Iterator it = map.keySet().iterator();
			while(it.hasNext()){
				String key = it.next().toString();
				if(!key.equals("Detail")){
					head.put(key, map.get(key));
				}
			}
			DataMap row;
			int count = 0;
			
			for (int i = 0; i < list.size(); i++) {
				row = list.get(i);
				row.append(head);
				log.info(row);
				
				row.setModuleCommand("IF", "MASTER_SELLER");
				
				DataMap result = new DataMap();
				
				row.get("EfmIfSeq");
				String EfmIfSeq = (String) row.get("EfmIfSeq");
				
				result.put("EfmIfSeq", EfmIfSeq);
				try {
					commonDao.insert(row);
					result.put("ResultCode", "0");
					result.put("Message", "SUCCESS");

				} catch (Exception e) {
					if(!model.containsKey("RESULT")){
						model.put("ResultCode", "1");
						model.put("Message", "FAIL");
					}
					result.put("ResultCode", "1");
					result.put("Message", "FAIL");
					log.info(e.getMessage());
				}
				log.info(result);
				dataList.add(result);
			}
			if(!model.containsKey("RESULT")){
				model.put("ResultCode", "0");
				model.put("Message", "SUCCESS");
			}
			
			model.put("Data", dataList);
		}else{
			model.put("ResultCode", "1");
			model.put("Message", "FAIL");
		}
		log.info(model);
	}
*/
	// SEND
	public void asnSend(DataMap map) throws SQLException, JSONException {
		String targetUrl = "";
		
		PostRequest postRequest = new PostRequest();
		
		// header 조회
		DataMap head = commonDao.getMap("IF.MASTER_SELLER", map);
		
		JSONObject json = postRequest.getJSONObj(map);
		
		// detail 조회
		List<DataMap> list = commonDao.getList("IF.MASTER_SELLER", map);
		
		json.put("Detail", postRequest.getJSONArray(list));
		
		DataMap result = postRequest.jsonPost(targetUrl, json);
		
		List<DataMap> resultList = result.getList("Detail");
		DataMap row;
		
		// WMS UPDATE
		for (int i = 0; i < resultList.size(); i++) {
			row = resultList.get(i);
			commonDao.update("IF.MASTER_SELLER", row);
		}
	}
	
	
	
	// category
	
public void category(DataMap map , Map model) throws SQLException {
		
	List<DataMap> list = map.getList("Detail");
	List<DataMap> dataList = new ArrayList();
	
	DataMap row;
	int count = 0;

	for (int i = 0; i < list.size(); i++) {
		row = list.get(i).getMap("map");
		
		
		row.setModuleCommand("IF", "MASTER_CATEGORY");
		
		DataMap result = new DataMap();
		
		row.get("EfmIfSeq");
		String EfmIfSeq = (String) row.get("EfmIfSeq");
		
		result.put("EfmIfSeq", EfmIfSeq);
		try {
			commonDao.insert(row);
			result.put("ResultCode", "0");
			result.put("Message", "SUCCESS");

		} catch (Exception e) {
			if(!model.containsKey("RESULT")){
				model.put("ResultCode", "1");
				model.put("Message", "FAIL");
			}
			result.put("ResultCode", "1");
			result.put("Message", "FAIL");
			log.info(e.getMessage());
		}
		dataList.add(result);
	}
	if(!model.containsKey("RESULT")){
		model.put("ResultCode", "0");
		model.put("Message", "SUCCESS");
	}
	
	model.put("Data", dataList);
}
	
	
	
	
// skuinfo	
public void skuinfo(DataMap map, Map model) throws SQLException {
	
	List<DataMap> list = map.getList("Detail");
	List<DataMap> dataList = new ArrayList();
	
	DataMap row;
	int count = 0;

	for (int i = 0; i < list.size(); i++) {
		row = list.get(i).getMap("map");
		
		
		row.setModuleCommand("IF", "MASTER_SKUINFO");
		
		DataMap result = new DataMap();
		
		row.get("EfmIfSeq");
		String EfmIfSeq = (String) row.get("EfmIfSeq");
		
		result.put("EfmIfSeq", EfmIfSeq);
		try {
			commonDao.insert(row);
			result.put("ResultCode", "0");
			result.put("Message", "SUCCESS");

		} catch (Exception e) {
			if(!model.containsKey("RESULT")){
				model.put("ResultCode", "1");
				model.put("Message", "FAIL");
			}
			result.put("ResultCode", "1");
			result.put("Message", "FAIL");
			log.info(e.getMessage());
		}
		dataList.add(result);
	}
	if(!model.containsKey("RESULT")){
		model.put("ResultCode", "0");
		model.put("Message", "SUCCESS");
	}
	
	model.put("Data", dataList);
}


	
	
	
	
// bigdeal	
public void bigdeal(DataMap map, Map model) throws SQLException {
	
	List<DataMap> list = map.getList("Detail");
	List<DataMap> dataList = new ArrayList();
	
	DataMap row;
	int count = 0;

	for (int i = 0; i < list.size(); i++) {
		row = list.get(i).getMap("map");
		
		
		row.setModuleCommand("IF", "MASTER_BIGDEAL");
		
		DataMap result = new DataMap();
		
		row.get("EfmIfSeq");
		String EfmIfSeq = (String) row.get("EfmIfSeq");
		
		result.put("EfmIfSeq", EfmIfSeq);
		try {
			commonDao.insert(row);
			result.put("ResultCode", "0");
			result.put("Message", "SUCCESS");

		} catch (Exception e) {
			if(!model.containsKey("RESULT")){
				model.put("ResultCode", "1");
				model.put("Message", "FAIL");
			}
			result.put("ResultCode", "1");
			result.put("Message", "FAIL");
			log.info(e.getMessage());
		}
		dataList.add(result);
	}
	if(!model.containsKey("RESULT")){
		model.put("ResultCode", "0");
		model.put("Message", "SUCCESS");
	}
	
	model.put("Data", dataList);
}

	
	
//skuaddinfo	
public void skuaddinfo(DataMap map, Map model) throws SQLException {
	
	List<DataMap> list = map.getList("Detail");
	List<DataMap> dataList = new ArrayList();
	
	DataMap row;
	int count = 0;

	for (int i = 0; i < list.size(); i++) {
		row = list.get(i).getMap("map");
		
		
		row.setModuleCommand("IF", "MASTER_SKUADDINFO");
		
		DataMap result = new DataMap();
		
		row.get("EfmIfSeq");
		String EfmIfSeq = (String) row.get("EfmIfSeq");
		
		result.put("EfmIfSeq", EfmIfSeq);
		try {
			commonDao.insert(row);
			result.put("ResultCode", "0");
			result.put("Message", "SUCCESS");

		} catch (Exception e) {
			if(!model.containsKey("RESULT")){
				model.put("ResultCode", "1");
				model.put("Message", "FAIL");
			}
			result.put("ResultCode", "1");
			result.put("Message", "FAIL");
			log.info(e.getMessage());
		}
		dataList.add(result);
	}
	if(!model.containsKey("RESULT")){
		model.put("ResultCode", "0");
		model.put("Message", "SUCCESS");
	}
	
	model.put("Data", dataList);
}

	
	
//skustatus	
public void skustatus(DataMap map, Map model) throws SQLException {
	
	List<DataMap> list = map.getList("Detail");
	List<DataMap> dataList = new ArrayList();
	
	DataMap row;
	int count = 0;

	for (int i = 0; i < list.size(); i++) {
		row = list.get(i).getMap("map");
		
		
		row.setModuleCommand("IF", "MASTER_SKUSTATUS");
		
		DataMap result = new DataMap();
		
		row.get("EfmIfSeq");
		String EfmIfSeq = (String) row.get("EfmIfSeq");
		
		result.put("EfmIfSeq", EfmIfSeq);
		try {
			commonDao.insert(row);
			result.put("ResultCode", "0");
			result.put("Message", "SUCCESS");

		} catch (Exception e) {
			if(!model.containsKey("RESULT")){
				model.put("ResultCode", "1");
				model.put("Message", "FAIL");
			}
			result.put("ResultCode", "1");
			result.put("Message", "FAIL");
			log.info(e.getMessage());
		}
		dataList.add(result);
	}
	if(!model.containsKey("RESULT")){
		model.put("ResultCode", "0");
		model.put("Message", "SUCCESS");
	}
	
	model.put("Data", dataList);
}
// recevie asn
public void asn(DataMap map, Map model) throws SQLException {
	
	//List<DataMap> list2 = map.getList("Header");
	List<DataMap> list = map.getList("Detail");	
	List<DataMap> dataList = new ArrayList();
	List<DataMap> dataList2 = new ArrayList();
	
	DataMap row;
	int count = 0;

	for (int i = 0; i < list.size(); i++) {
		row = list.get(i).getMap("map");
		
		row.setModuleCommand("IF", "INBOUND_ASN");
		
		DataMap result = new DataMap();
		DataMap result2 = new DataMap();
		
		row.get("EfmIfSeq");
		row.get("OrderType");
		row.get("CarType");
		row.get("DeliveryCompCode");
		row.get("CarNumber");
		row.get("EfmMasterId");
		row.get("WarehouseNo");
		row.get("Status");
		row.get("IwScheduledDate");
		row.get("FromDistrCenterType");
		row.get("ToDistrCenterType");
		row.get("ToStorageType");
		
		row.get("SkuMatchingSeq");
		row.get("SkuId");
		row.get("EfmSkuStockCode");
		row.get("WmsSkuStockCode");
		row.get("LotIwDate");
		row.get("LotExpiryDate");
		row.get("LotEtc1");
		row.get("IwScheduledQty");
		row.get("BarcodeServiceYn");
		row.get("InvoiceNo");
		
		
		String EfmIfSeq = (String) row.get("EfmIfSeq");; //insert �썑 由ы꽩 蹂대궡�빞�븷 .
		String OrderType = (String) row.get("OrderType");;
		String CarType = (String) row.get("CarType");;
		String DeliveryCompCode = (String) row.get("DeliveryCompCode");;
		String CarNumber = (String) row.get("CarNumber");;
		String EfmMasterId = (String) row.get("EfmMasterId");;
		String Status = (String) row.get("WarehouseNo");;
		String IwScheduledDate = (String) row.get("IwScheduledDate");;
		String FromDistrCenterType = (String) row.get("FromDistrCenterType");;
		String ToDistrCenterType = (String) row.get("ToDistrCenterType");;
		String ToStorageType = (String) row.get("ToStorageType");;
		
		String SkuMatchingSeq = (String) row.get("SkuMatchingSeq");;
		String SkuId = (String) row.get("SkuId");;
		String EfmSkuStockCode = (String) row.get("EfmSkuStockCode");;
		String WmsSkuStockCode = (String) row.get("WmsSkuStockCode");;
		String LotIwDate = (String) row.get("LotIwDate");;
		String LotExpiryDate = (String) row.get("LotExpiryDate");;
		String LotEtc1 = (String) row.get("LotEtc1");;
		String IwScheduledQty = (String) row.get("IwScheduledQty");;
		String BarcodeServiceYn = (String) row.get("BarcodeServiceYn");;
		String InvoiceNo = (String) row.get("InvoiceNo");;
		
				
		result.put("EfmIfSeq", EfmIfSeq);
		result.put("OrderType", OrderType);
		result.put("CarType", CarType);
		result.put("DeliveryCompCode", DeliveryCompCode);
		result.put("CarNumber", CarNumber);
		result.put("EfmMasterId", EfmMasterId);
		result.put("Status", Status);
		result.put("IwScheduledDate", IwScheduledDate);
		result.put("FromDistrCenterType", FromDistrCenterType);
		result.put("ToDistrCenterType", ToDistrCenterType);
		result.put("ToStorageType", ToStorageType);
		
		result2.put("SkuMatchingSeq",	SkuMatchingSeq);
		result2.put("SkuId",	SkuId);
		result2.put("EfmSkuStockCode",	EfmSkuStockCode);
		result2.put("WmsSkuStockCode",	WmsSkuStockCode);
		result2.put("LotIwDate",	LotIwDate);
		result2.put("LotExpiryDate",	LotExpiryDate);
		result2.put("LotEtc1",	LotEtc1);
		result2.put("IwScheduledQty",	IwScheduledQty);
		result2.put("BarcodeServiceYn",	BarcodeServiceYn);
		result2.put("InvoiceNo",	InvoiceNo);
		
		try {
			commonDao.insert(row);
			
			result.put("Header", result);									
			result2.put("Detail", result2);			
			
		} catch (Exception e) {
			if(!model.containsKey("RESULT")){
				model.put("ResultCode", "1");
				model.put("Message", "FAIL");
			}
			result.put("ResultCode", "1");
			result.put("Message", "FAIL");
			
			result2.put("ResultCode", "1");
			result2.put("Message", "FAIL");
			log.info(e.getMessage());
		
		}	
		dataList.add(result);
		dataList2.add(result2);
	}
	

	
	if(!model.containsKey("RESULT")){
		model.put("ResultCode", "0");
		model.put("Message", "SUCCESS");
	}
	
	model.put("Header", dataList);
	model.put("Deatail", dataList2);
}



//
public Object returnAsn(DataMap map) throws SQLException {
	
	List<DataMap> list = map.getList("Detail");
	
	//map.setModuleCommand("IF", "Outbound/SellerHeader");
	//commonDao.insert(map);
	
	DataMap row;
	int count = 0;
	
	for(int i=0;i<list.size();i++){
		
		row = list.get(i).getMap("map");
		row.setModuleCommand("IF", "INBOUND_ORDERRETURN");
		
		try {
			commonDao.insert(row);
			map.put("RESULT", "SUCCESS");
			
		} catch (Exception e) {
			map.put("RESULT", "FAIL");

			log.info(e.getMessage());
		}
		
	}
	
	return map;
}		
	
	
	
}