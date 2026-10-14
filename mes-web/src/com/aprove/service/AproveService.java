package com.aprove.service;

import java.sql.SQLException;
import java.util.List;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.common.bean.DataMap;
import com.common.dao.CommonDAO;
import com.common.service.BaseService;

@Service
public class AproveService extends BaseService {
	
	private static Logger log = Logger.getLogger(AproveService.class);
	
	@Autowired
	public CommonDAO commonDao;

	@Transactional
	public int updateFWAPI(DataMap map) throws SQLException {		
		int count;
		if(map.getString("APRTYPE").equals("D")){
			count= commonDao.delete("Aprove.FWAPRM0010", map);
		}else{
			count = commonDao.update("Aprove.FWAPRI0010TYPE", map);
			if(map.getString("APRTYPE").equals("A")){
				int cnt = commonDao.getCount("Aprove.FWAPRI0010TYPE", map);
				if(cnt == 0){
					map.put("APRTYPE", "A");
				}else{
					map.put("APRTYPE", "P");
				}
			}else{
				map.put("APRTYPE", "R");
			}
			count+= commonDao.update("Aprove.FWAPRM0010TYPE", map);
		}
		
		return count;
	}
}