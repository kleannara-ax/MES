package com.board.service;

import java.sql.SQLException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.board.bean.CommonBoard;
import com.common.bean.CommonConfig;
import com.common.dao.CommonDAO;
import com.common.bean.DataMap;

@Service
public class BoardService {

	@Autowired
	public CommonDAO commonDao;
	
	@Autowired
	private CommonBoard commonBoard;
	
	public void loadBoard() throws SQLException{
		DataMap map = new DataMap("Board", "BOARDMASTER");
		List list = commonDao.getList(map);
		
		commonBoard.setBoardList(list);
	}
	
	@Transactional
	public int boardContentInsert(DataMap map) throws SQLException {
		map.put(CommonConfig.MODULE_ATT_KEY, "Board");
		map.put(CommonConfig.COMMAND_ATT_KEY, "FWBDCM0010");
		
		List<String> list = map.getList(CommonConfig.FILELIST_KEY);
		
		map.put("UUID", list.get(0));
		
		int contentId = (Integer)commonDao.insert(map);
		
		map.put(CommonConfig.COMMAND_ATT_KEY, "FWBDCM0013");
		map.put("CONTENT_ID", contentId);
		
		for(int i=0;i<list.size();i++){
			map.put("UUID", list.get(i));
			map.put("PRIORITY", i);
			commonDao.insert(map);			
		}
		
		//map.put(CommonConfig.COMMAND_ATT_KEY, "FWBDCM0010P");
		//int rs = commonDao.update(map);
		
		return contentId;
	}
	
	@Transactional
	public int boardContentUpdate(DataMap map) throws SQLException {
		map.put(CommonConfig.MODULE_ATT_KEY, "Board");
		map.put(CommonConfig.COMMAND_ATT_KEY, "FWBDCM0010");
		
		List<String> list = map.getList(CommonConfig.FILELIST_KEY);
		
		map.put("UUID", list.get(0));
		
		int rs = commonDao.update(map);
		
		map.put(CommonConfig.COMMAND_ATT_KEY, "FWBDCM0013");
		
		if(!map.getString("fileDeleteList").equals("")){
			String[] deletefileList = map.getString("fileDeleteList").split(" ");
			for(int i=0;i<deletefileList.length;i++){
				map.put("UUID", deletefileList[i]);
				commonDao.delete(map);	
			}
		}
		
		
		for(int i=0;i<list.size();i++){
			map.put("UUID", list.get(i));
			map.put("PRIORITY", i);
			commonDao.insert(map);
		}
		
		int contentId = map.getInt("CONTENT_ID");
		
		return contentId;
	}
	
	@Transactional
	public int boardContentRewrite(DataMap map) throws SQLException {
		map.put(CommonConfig.MODULE_ATT_KEY, "Board");
		map.put(CommonConfig.COMMAND_ATT_KEY, "FWBDCM0010R");
		
		if(map.getString("STEP").equals("0")){
			map.put("STEP", "1");
		}
		commonDao.update(map);
		int contentId = (Integer)commonDao.insert(map);
		
		List<String> list = map.getList(CommonConfig.FILELIST_KEY);
		
		map.put(CommonConfig.COMMAND_ATT_KEY, "FWBDCM0013");
		map.put("CONTENT_ID", contentId);
		
		for(int i=0;i<list.size();i++){
			map.put("UUID", list.get(i));
			map.put("PRIORITY", i);
			commonDao.insert(map);			
		}
		
		return contentId;
	}
	
	@Transactional
	public int boardContentDelete(DataMap map) throws SQLException {
		map.put(CommonConfig.MODULE_ATT_KEY, "Board");
		map.put(CommonConfig.COMMAND_ATT_KEY, "FWBDCM0010");

		int rs = commonDao.delete(map);
		
		map.put(CommonConfig.COMMAND_ATT_KEY, "FWBDCM0013");
		
		rs += commonDao.delete(map);
		
		return rs;
	}
}