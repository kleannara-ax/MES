package com.wms.service;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.common.bean.CommonConfig;
import com.common.bean.DataMap;
import com.common.dao.CommonDAO;
import com.common.bean.DataMap;
import com.common.util.Util;

@Service
public class WcsService {

	private static Logger log = Logger.getLogger(WcsService.class);

	@Autowired
	private Util util;
	
	@Autowired
	public CommonDAO commonDao;

	@Transactional
	public int WS01Save(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		int count = 1;
		DataMap row = null;

		String infuse = null;
		String inruse = null;
		String otfuse = null;
		String otruse = null;
		
				
		for(int i=0;i<list.size();i++){			
			row = list.get(i).getMap("map");
			if(row.getString("IOFR").equals("IF")){	
				infuse =  row.getString("STC01") + row.getString("STC02")+row.getString("STC03") + row.getString("STC04")+row.getString("STC05") 
						+ row.getString("STC06") + row.getString("STC07")+row.getString("STC08") + row.getString("STC09")+row.getString("STC10")
						+ row.getString("STC11") + row.getString("STC12")+row.getString("STC13") + row.getString("STC14")+row.getString("STC15")
						+ row.getString("STC16") + row.getString("STC17")+row.getString("STC18") + row.getString("STC19")+row.getString("STC20");
			}
			if(row.getString("IOFR").equals("IR")){	
				inruse =  row.getString("STC01") + row.getString("STC02")+row.getString("STC03") + row.getString("STC04")+row.getString("STC05") 
						+ row.getString("STC06") + row.getString("STC07")+row.getString("STC08") + row.getString("STC09")+row.getString("STC10")
						+ row.getString("STC11") + row.getString("STC12")+row.getString("STC13") + row.getString("STC14")+row.getString("STC15")
						+ row.getString("STC16") + row.getString("STC17")+row.getString("STC18") + row.getString("STC19")+row.getString("STC20");
			}
			if(row.getString("IOFR").equals("OF")){	
				otfuse =  row.getString("STC01") + row.getString("STC02")+row.getString("STC03") + row.getString("STC04")+row.getString("STC05") 
						+ row.getString("STC06") + row.getString("STC07")+row.getString("STC08") + row.getString("STC09")+row.getString("STC10")
						+ row.getString("STC11") + row.getString("STC12")+row.getString("STC13") + row.getString("STC14")+row.getString("STC15")
						+ row.getString("STC16") + row.getString("STC17")+row.getString("STC18") + row.getString("STC19")+row.getString("STC20");
			}
			if(row.getString("IOFR").equals("OR")){	
				otruse =  row.getString("STC01") + row.getString("STC02")+row.getString("STC03") + row.getString("STC04")+row.getString("STC05") 
						+ row.getString("STC06") + row.getString("STC07")+row.getString("STC08") + row.getString("STC09")+row.getString("STC10")
						+ row.getString("STC11") + row.getString("STC12")+row.getString("STC13") + row.getString("STC14")+row.getString("STC15")
						+ row.getString("STC16") + row.getString("STC17")+row.getString("STC18") + row.getString("STC19")+row.getString("STC20");
			}	
		}	

		infuse = infuse.replace('V', 'Y');
		infuse = infuse.replace(' ', 'N');
		inruse = inruse.replace('V', 'Y');
		inruse = inruse.replace(' ', 'N');
		otfuse = otfuse.replace('V', 'Y');
		otfuse = otfuse.replace(' ', 'N');
		otruse = otruse.replace('V', 'Y');
		otruse = otruse.replace(' ', 'N');
		log.debug("::::::::::::::::::::::"+otruse);
		
		
		row.put("WAREKY", row.get("WAREKY"));
		row.put("AREAKY", row.get("AREAKY"));		
		row.put("INFUSE", infuse);
		row.put("INRUSE", inruse);
		row.put("OTFUSE", otfuse);
		row.put("OTRUSE", otruse);
		
		row.put("DEF_02", map.getString("def_02"));
		row.put("DEF_03", map.getString("def_03"));
		
		log.debug("::::::::DEF_02::::::::::::::"+map.getString("def_02"));
		
		row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		row.setModuleCommand("WmsWcs", "KT000");
		commonDao.update(row);

		return count;
	}
	
	@Transactional
	public int WS02Save(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		int count = 1;
		DataMap row = null;

		String use_01= "";	
		String stn_use = "";
		String stn_max_plt = "";
		String stn_cur_plt = "";
		String def_01 = "";
		String cnt_01 = "";
		
		
		for(int i=0;i<list.size();i++){		
			row = list.get(i).getMap("map");
			if (row.getString("USE_01").equals("V")) {
				use_01 = "Y";
			}else{
				use_01 = "N";
			};
			stn_use = stn_use + use_01;
			
			def_01 = row.getString("DEF_01");
			if (def_01.length() == 1){
				stn_max_plt = stn_max_plt + "0" + def_01;
			}else {
				stn_max_plt = stn_max_plt + def_01;
			}
							
			cnt_01 = row.getString("CNT_01");
			if (cnt_01.length() == 1){
				stn_cur_plt = stn_cur_plt + "0" + cnt_01;
			} else {
				stn_cur_plt = stn_cur_plt + cnt_01;
			}			
			
			row.put("WAREKY", row.getString("WAREKY"));
			row.put("AREAKY", row.getString("AREAKY"));		
			row.put("STNSEQ", row.getString("STNSEQ"));		
			row.put("USE_01", use_01);		
			row.put("DEF_01", def_01);		
			row.put("CNT_01", cnt_01);		
						
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.setModuleCommand("WmsWcs", "KTDEF");
			commonDao.update(row);			
			count++;
		}	
		
		log.debug("::::::::::stn_cur_plt::::::::::::"+stn_cur_plt);
		
		row.put("STN_USE", stn_use);		
		row.put("STN_MAX_PLT", stn_max_plt);		
		row.put("STN_CUR_PLT", stn_cur_plt);	
		row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		row.setModuleCommand("WmsWcs", "KT000_WS02");
		commonDao.update(row);			
		count++;
		return count;
	}
	
	public DataMap WCO1save(DataMap map) throws SQLException {
		List rsList = new ArrayList();
		List<DataMap> list = map.getList("list");
		DataMap row = null;
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.setModuleCommand("WmsWcs", "WCO01proc");
			
			commonDao.getMap(row);
			if(row.getString("O_SUCCSS").equals("E")){
				return row;
			}
		}
		return row;
	}
	
	public DataMap WCO2save(DataMap map) throws SQLException {
		List rsList = new ArrayList();
		List<DataMap> list = map.getList("list");
		DataMap row = null;
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.setModuleCommand("WmsWcs", "WCO02proc");
			
			commonDao.getMap(row);
			if(row.getString("O_SUCCSS").equals("E")){
				return row;
			}
		}
		return row;
	}
	
	public DataMap WCI1save(DataMap map) throws SQLException {
		List rsList = new ArrayList();
		List<DataMap> list = map.getList("list");
		DataMap row = null;
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.setModuleCommand("WmsWcs", "WCI1proc");
			
			commonDao.getMap(row);
			if(row.getString("O_SUCCSS").equals("E")){
				return row;
			}
		}
		return row;
	}
	
	@Transactional
	public int WCM2Save(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		int count = 1;
		DataMap row = null;

		String infuse="";
		String otfuse="";
		
		log.debug("ListSize : "+list.size());
		log.debug("DataMap1 : "+row);
		for(int i=0;i<list.size();i++){			
			row = list.get(i).getMap("map");
			infuse +=  row.getString("INFUSE");
			otfuse +=  row.getString("OTFUSE");
		}
		log.debug("DataMap2 : "+row);

		infuse = infuse.replace('V', 'Y');
		infuse = infuse.replace(' ', 'N');

		otfuse = otfuse.replace('V', 'Y');
		otfuse = otfuse.replace(' ', 'N');
		
		row.put("WAREKY", row.get("WAREKY"));
		row.put("AREAKY", row.get("AREAKY"));		
		row.put("INFUSE", infuse);
		row.put("OTFUSE", otfuse);
		
		row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		row.setModuleCommand("WmsWcs", "WCM2");
		commonDao.update(row);

		return count;
	}
}