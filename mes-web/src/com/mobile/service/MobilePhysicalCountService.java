package com.mobile.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.common.bean.CommonConfig;
import com.common.bean.DataMap;
import com.common.dao.CommonDAO;
import com.wms.service.WmsService;

@Service
public class MobilePhysicalCountService {

	@Autowired
	public CommonDAO commonDao;
	
	@Autowired
	public WmsService wmsService;
	
	@Transactional(rollbackFor=Exception.class)
	public int savePDMV47(DataMap map) throws Exception {
		DataMap head = map.getMap("head");
		DataMap row;
		int count = 0;
		
		head.setModuleCommand("WmsMobileInventoryPhysicalCount", "PDMV47");
		head.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
	    head.put("SES_WAREKY", map.getString("SES_WAREKY"));
	    head.put("SES_OWNER", map.getString("SES_OWNER"));
	    head.put("PDARDO", map.get("PDARDO"));
	    
	    List<DataMap> list = commonDao.getList(head);
		int qtypda = map.getInt("QTYPDA");
		int qtsiwh;
		
		if(list.size() == 1){
			row = list.get(0);
			
			row.put("QTYPDA", qtypda);
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			row.put("WAREKY", map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
		
			commonDao.update("WmsMobileInventoryPhysicalCount.PDMV47", row);
			count ++;
			
		}else{
			for(int i=0;i<list.size();i++){
				row = list.get(i);
				
				qtsiwh = row.getInt("QTSIWH");
				
				if(qtypda >= 0 && qtypda > qtsiwh && list.size() - 1 != i){
					row.put("QTYPDA", qtsiwh);
					
					qtypda = qtypda - qtsiwh;
				}else if(qtypda >= 0 && qtypda == qtsiwh && list.size() - 1 != i){
					row.put("QTYPDA", qtsiwh);
					
					qtypda = qtypda - qtsiwh;
				}else if(qtypda >= 0 && qtypda < qtsiwh && list.size() - 1 != i){
					row.put("QTYPDA", qtypda);
					
					qtypda = qtypda - qtsiwh;
				}else if(qtypda < 0 && list.size() - 1 != i){
					row.put("QTYPDA", 0);
				}else if(list.size() - 1 == i){
					row.put("QTYPDA", qtypda);
				}
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
				row.put("WAREKY", map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
				
				commonDao.update("WmsMobileInventoryPhysicalCount.PDMV47", row);
				count ++;
			}
		}
		
		return count;
	}
}