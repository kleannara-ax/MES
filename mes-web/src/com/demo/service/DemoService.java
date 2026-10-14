package com.demo.service;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.TreeMap;

import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.common.bean.CommonAction;
import com.common.bean.CommonConfig;
import com.common.bean.CommonLabel;
import com.common.bean.CommonMenu;
import com.common.bean.CommonSearch;
import com.common.bean.DataMap;
import com.common.bean.FileRepository;
import com.common.bean.TableColumn;
import com.common.bean.User;
import com.common.dao.CommonDAO;
import com.common.service.BaseService;
import com.common.service.CommonService;
import com.common.util.FileUtil;
import com.common.util.Util;

@Service("demoService")
public class DemoService extends BaseService {
	
	private static Logger log = Logger.getLogger(DemoService.class);
	
	@Autowired
	public CommonDAO commonDao;
	
	@Autowired
	public CommonService commonService;

	public List getList(DataMap map) throws SQLException {
		return commonDao.getList(map);
	}
	
	@Transactional
	public DataMap gridSave(DataMap map) throws SQLException {
		
		DataMap rsMap = new DataMap();
		
		List<DataMap> list = map.getList("list");
		
		int count = 0;
		DataMap row;
		
		for(int i=0;i<list.size();i++){			
			if(map.containsKey("param")){
				row = new DataMap(map.getMap("param").getMap("map"));
			}else{
				row = new DataMap();
			}				
			
			map.clonModule(row);
			row.append(list.get(i).getMap("map"));			
			//row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			//row.put(CommonConfig.MODULE_ATT_KEY, map.get(CommonConfig.MODULE_ATT_KEY));
			//row.put(CommonConfig.COMMAND_ATT_KEY, map.get(CommonConfig.COMMAND_ATT_KEY));
			String rowState = row.getString(CommonConfig.GRID_ROW_STATE_ATT);
			switch(rowState.charAt(0)){
				case 'C':
					commonDao.insert(row);
					break;
				case 'U':
					commonDao.update(row);
					break;
				case 'D':
					commonDao.delete(row);
					break;
			}
			count++;
		}
		
		rsMap.put("data", count);
		
		return rsMap;
	}
	
	@Transactional
	public DataMap saveDemoItem(HttpSession session, DataMap map) throws Exception {
		DataMap rsMap = new DataMap();
		List<DataMap> dataList = new ArrayList<DataMap>();
		
		List<DataMap> list = map.getList("list");
		int len = list.size();
		int count = 0;
		if(len > 0){
			DataMap row;
			for(int i = 0; i < len; i++){
				row = list.get(i).getMap("map");
				map.clonSessionData(row);
				dataList.add(row);
			}
			
			map.setModuleCommand("Demo", "DEMOITEM");
			count = (int) commonDao.batchInsert(session, map, dataList);
		}
		
		rsMap.put("CNT", count);
		
		return rsMap;
	}
	
	@Transactional
	public int saveFile(DataMap map) throws Exception {
		int count = 0;
		
		List<DataMap> list = map.getList("list");
		int listLen = list.size();
		
		if(listLen > 0){
			DataMap row;
			
			for(int i = 0; i < listLen; i++){
				row = list.get(i).getMap("map");
				
				row.setModuleCommand("Demo", "FWCMFL001_DEMO");
				
				String rowState = row.getString(CommonConfig.GRID_ROW_STATE_ATT);
				String uuid = row.getString("ATTACH");
				
				switch(rowState.charAt(0)){
				case 'C':
					commonDao.insert(row);
					break;
				case 'U':
					commonDao.update(row);
					break;
				case 'D':
					commonService.deleteAttachFile(uuid);
					commonDao.delete(row);
					break;
				}
				
				if(!"D".equals(rowState)){
					//FWCMFL0010 Table. UPTBYN 'Y' -> Update.
					commonService.updateAttachTbYn(uuid, "Y");
				}
				
				count++;
			}
		}
		return count;
	}
}