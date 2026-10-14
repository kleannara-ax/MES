package project.mes.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import project.common.bean.CommonConfig;
import project.common.bean.DataMap;
import project.common.dao.CommonDAO;
import project.mes.dao.IFDAO;

import java.sql.SQLException;
import java.util.List;

@Service
public class WmsService {

	@Autowired
	public CommonDAO commonDao;

	@Autowired
	public IFDAO ifDao;
	
	public String getDocSeq(String docType) throws SQLException{
		DataMap map = new DataMap("Wms", "FN_DOCUSEQ");
		map.put("DOCUTY", docType);
		map = commonDao.getMap(map);
		return map.getString("DOCSEQ");
	}
	
	public String getNumSeq(String numObj) throws SQLException{
		DataMap map = new DataMap("Wms", "FN_NROBJ");
		map.put("NUMOBJ", numObj);
		map = commonDao.getMap(map);
		return map.getString("NUMSEQ");
	}
	
	public int bzptnMerge() throws SQLException{
		int cnt =0;
		DataMap map = new DataMap();
		map.setModuleCommand("IF", "BZPTN_SELECT");
        List<DataMap> headList = ifDao.getList(map); 
        map.clear();
        DataMap itemMap = new DataMap();
	        
        String docNum = "";
	    for(int i=0;i<headList.size();i++){

	    		itemMap = new DataMap(headList.get(i));
	    			
	    		itemMap.setModuleCommand("WmsAdmin", "BZPTNMERGE");
	    		commonDao.insert(itemMap);

	    }
	    itemMap.clear();

	    DataMap headMap = new DataMap();
	    for(int i=0;i<headList.size();i++){
	    	headMap = headList.get(i);
	    	headMap.setModuleCommand("IF", "BZPTN_IFFLG");
			cnt += ifDao.update(headMap);
	    }
	    headMap.clear();
	    headList.clear();
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
					mixskuaMap.clear();
					return 2;
				}
				mixskuaMap.clear();
			}
			if(" ".equals(locamap.get("MIXLOT"))) {
				map.setModuleCommand("Wms", "MIXLOT");
				
				DataMap mixlotMap = commonDao.getMap(map);
				if(mixlotMap.getInt("CNT") > 0) {
					mixlotMap.clear();
					return 3;
				}
				mixlotMap.clear();
			}
		}
		locamap.clear();
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
			map.clear();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			throw new SQLException("Message Error - Call you Administartor");
		}
    	return message;
    }	
    
    @Transactional
	public int saveLog(DataMap map)  throws SQLException {
		int count = 0;
		map.put("USERID", map.get(CommonConfig.SES_USER_ID_KEY));
		if(map.get("LGTYPE").equals("SEARCH")) {
			map.setModuleCommand("Wms", "PROGM_SEARCH_LOG");
		} else if(map.get("LGTYPE").equals("EXCEL")){
			map.setModuleCommand("System", "PROGM_EXCEL_DOWNLOAD_LOG");
		} else {
			throw new SQLException("Log type is not correct.");
		}
		commonDao.insert(map);
		count++;
		return count;
	}
}