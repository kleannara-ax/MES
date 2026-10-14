package com.wms.service;

import java.sql.SQLException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.common.bean.DataMap;
import com.common.dao.CommonDAO;
import com.wms.dao.IFDAO;

@Service
public class WmsService {

	@Autowired
	public CommonDAO commonDao;

	@Autowired
	public IFDAO ifDao;
	
	public String getDocSeq(String docType) throws SQLException{
		DataMap map = new DataMap("Common", "FN_DOCUSEQ");
		map.put("DOCUTY", docType);
		
		return (String)commonDao.getObj(map);
	}
	
	public String getNumSeq(String numObj) throws SQLException{
		DataMap map = new DataMap("Common", "FN_NROBJ");
		map.put("NUMOBJ", numObj);
		
		return (String)commonDao.getObj(map);
	}
	
	public int bzptnMerge() throws SQLException{
		int cnt =0;
		DataMap map = new DataMap();
		map.setModuleCommand("IF", "BZPTN_SELECT");
        List<DataMap> headList = ifDao.getList(map); 
        DataMap itemMap = new DataMap();
	        
        String docNum = "";
	    for(int i=0;i<headList.size();i++){

	    		itemMap = new DataMap(headList.get(i));
	    			
	    		itemMap.setModuleCommand("WmsAdmin", "BZPTNMERGE");
	    		commonDao.insert(itemMap);

	    }
	    

	    DataMap headMap = new DataMap();
	    for(int i=0;i<headList.size();i++){
	    	headMap = headList.get(i);
	    	headMap.setModuleCommand("IF", "BZPTN_IFFLG");
			cnt += ifDao.update(headMap);
	    }
	    return cnt;
	}
	
	@Transactional
	public int LocakyCheck(DataMap map) throws SQLException {	
		map.setModuleCommand("Wms", "LOCMA");
		
		DataMap locamap = (DataMap) commonDao.getMap(map);
		
		if(locamap == null) {
			return 0;
		} else {
			if(" ".equals(locamap.get("MIXSKU"))) {
				map.setModuleCommand("Wms", "MIXSKUA");
				
				DataMap mixskuaMap = commonDao.getMap(map);
				if(mixskuaMap.getInt("CNT") > 0) {
					return 2;
				}
			}
			if(" ".equals(locamap.get("MIXLOT"))) {
				map.setModuleCommand("Wms", "MIXLOT");
				
				DataMap mixlotMap = commonDao.getMap(map);
				if(mixlotMap.getInt("CNT") > 0) {
					return 3;
				}
			}
		}
		
		return 1;
	}
	
    public String getMessageParam(String langky , String mesgky , String[] paramArr ) throws SQLException{
		String message = "";
		try {
	    	DataMap map = new DataMap();
	    	String[] mesArr =  mesgky.split("_");
	    	map.put("LANGKY", langky);
	    	map.put("MESGGR", mesArr[0]);
	    	map.put("MESGKY", mesArr[1]);
	    	map.setModuleCommand("Wms", "GETMESSAGE");
			
			message = commonDao.getMap(map).getString("MESSAGE");
			if(paramArr != null){
				for(int i=0; i< paramArr.length;i++){
					String paramVal = paramArr[i];
					message = message.replaceAll("\\{"+i+"\\}", paramVal);
				}
			}
			
		} catch (Exception e) {
			// TODO Auto-generated catch block
			throw new SQLException("Message Error - Call you Administartor");
		}
    	return message;
    }	
}