package com.common.service;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.RequestMapping;

import com.common.bean.CommonConfig;
import com.common.bean.DataMap;
import com.common.dao.CommonDAO;
import com.common.util.ShaUtil;
import com.common.bean.DataMap;
import com.wms.service.OutboundService;

@Service
public class SystemService extends BaseService {
	private static Logger log = Logger.getLogger(SystemService.class);
	
	@Resource(name="properties")
	private Properties prop;
	
	@Autowired
	public CommonDAO commonDao;
	
	@Transactional
	public int saveUi01(DataMap map) throws SQLException {
		int count = 0;
		DataMap row;  
		
		List<DataMap> list = map.getList("list");
		log.debug("SystemService - saveUi01");
		for(int i = 0 ; i < list.size() ; i ++){
			row = list.get(i).getMap("map");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			
			String rowState = row.getString(CommonConfig.GRID_ROW_STATE_ATT);
			//log.debug(i + " - rowState : " + rowState);
			
			if(" ".equals(row.getString("UROLKY"))){
				log.debug(">>>>>>>>>>");
				row.setModuleCommand("System", "USSRA1");
				count += commonDao.delete(row);
			} else {
				row.setModuleCommand("System", "USSRA1");
				commonDao.delete(row);
			
				row.setModuleCommand("System", "USSRA1");
				commonDao.update(row);
			}
			
			row.setModuleCommand("System", "USER");
			switch(rowState.charAt(0)){
				case 'C':
					
					String resetPwd = prop.getProperty("password.reset");
					String shaNewPasswd = "";
					
					try {
						shaNewPasswd = ShaUtil.toSha256String(resetPwd);
						row.put("PASSWD",      shaNewPasswd);
						//log.debug("shaNewPasswd : " + shaNewPasswd);
					} catch (IOException e) {
						log.error("SystemService.resetPwd IO error : " + e.getMessage());
						e.printStackTrace();
					}
					
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
		
	
		return count;
	}
	
	@Transactional
	public int resetPwd(DataMap map) throws SQLException {
		int count = 0;
		DataMap row;  
		
		List<DataMap> list = map.getList("list");
		
		String resetPwd = prop.getProperty("password.reset");
		String shaNewPasswd = "";
		
		try {
			shaNewPasswd = ShaUtil.toSha256String(resetPwd);
			map.put("PASSWD",      shaNewPasswd);
			log.debug("shaNewPasswd : " + shaNewPasswd);
		} catch (IOException e) {
			log.error("SystemService.resetPwd IO error : " + e.getMessage());
			e.printStackTrace();
		}
		
		//log.debug("service resetPwd : " + resetPwd);
		if(list != null){
			for(int i = 0 ; i < list.size() ; i ++){
				row = list.get(i).getMap("map");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				String id = row.getString("USERID");
				row.put("USERID", id);
				row.put("PASSWD", shaNewPasswd);
				row.setModuleCommand("System", "RESET_PWD");
				commonDao.update(row);
				count++;
			}
		}
		
		return count;
	}

	@Transactional
	public int saveYhu01(DataMap map) throws SQLException {
		int count = 0;
		
		DataMap list = map.getMap("list").getMap("map");
		
		if(map.get("flag").equals("U")){
			list.setModuleCommand("System", "SHLPHU");
		}else{
			list.setModuleCommand("System", "SHLPHI");
		}
		count += commonDao.update(list);

		return count;
	}
	
/*	@Transactional
	public int saveYhi01(DataMap map) throws SQLException {
		int count = 0;
		
		DataMap list = map.getMap("list").getMap("map");
	
		
		count += commonDao.update(list);
		
		return count;
	}*/

	@Transactional
	public int saveUr01(DataMap map) throws SQLException {
		int count = 0;
		DataMap row;
		DataMap list = map.getMap("list").getMap("map");
		
		//List<DataMap> list = map.getList("list");
		//row = list.get(0).getMap("map");
			
		list.setModuleCommand("System", "UR01TOP");
		count += commonDao.update(list);
		
		return count;
	}

	@Transactional
	public int saveYs01(DataMap map) throws SQLException {
		int count = 0;
		if(map.get("flag").equals("U")){
			map.setModuleCommand("System", "JQMAPU");			
		}else{
			map.setModuleCommand("System", "SQLKEYCnt");
			DataMap cntMap = commonDao.getMap(map);
			if(cntMap != null){
				if(  cntMap.getInt("CNT") >0){
					return 0;
				}
			}
			map.setModuleCommand("System", "JQMAPI");	
		}
			
		count += commonDao.update(map);
		
		return count;
	}
	
	@Transactional
	public int delYs01(DataMap map) throws SQLException {
		int count=0;
		map.setModuleCommand("System", "JQMAP");
		count += commonDao.delete(map);
		return count;
	}
	
	@Transactional
	public int delYH01(DataMap map) throws SQLException {
		int count=0;
		map.setModuleCommand("System", "SHLPHAD");
		count += commonDao.delete(map);
		map.setModuleCommand("System", "SHLPIAD");
		count += commonDao.delete(map);
		return count;
	}

	@Transactional
	public int saveUR01UI(DataMap map) throws SQLException {
		int count = 0;
		DataMap row;
		DataMap list = map.getMap("list").getMap("map");
		
		List<DataMap> itemList = map.getList("itemList");	
		list.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		list.put(CommonConfig.SES_USER_LANGUAGE_KEY, map.get(CommonConfig.SES_USER_LANGUAGE_KEY));
		int headCnt = map.getInt("headCnt");
		
		//ROLDF테이블
		//headCnt 권한 = 0 없음, 권한 = 1 있음
		if(headCnt == 0){
			list.setModuleCommand("System", "UR01TOP");
			commonDao.insert(list);
			for(int i = 0; i < itemList.size(); i++) {
				row = itemList.get(i).getMap("map");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				row.put(CommonConfig.SES_USER_LANGUAGE_KEY, map.get(CommonConfig.SES_USER_LANGUAGE_KEY));
				if (row.get("GRowState").equals("U")) {
					count = 1;
					if(row.get("ACTVAT").equals("V")) {
						row.put("CREDOC", "V");
					}
				}
				if(!row.get("WAREKY").equals("")){
					row.setModuleCommand("System", "UR01WK");
					commonDao.insert(row);
				}else{
					row.setModuleCommand("System", "USSRA1");
					commonDao.delete(row);
				
					row.setModuleCommand("System", "USSRA1");
					commonDao.update(row);
				}
				
			}
		}else{
			list.setModuleCommand("System", "UR01TOP");
			commonDao.update(list);
			//ROLCT테이블
			for (int i = 0; i < itemList.size(); i++) {
				row = itemList.get(i).getMap("map");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				row.put(CommonConfig.SES_USER_LANGUAGE_KEY, map.get(CommonConfig.SES_USER_LANGUAGE_KEY));
				
				// 2020.04.01 임연지
				// 생성 업데이트 삭제 로직 변경
				// 활성화 체크 해제하면 삭제되게 수정
				if(row.get("GRowState").equals("C")) {
					count = 1;
					if(row.get("ACTVAT").equals("V")) {
						row.put("CREDOC", "V");
					}
					if(!row.get("WAREKY").equals("")){
						row.setModuleCommand("System", "UR01WK");
						commonDao.insert(row);
					}else{
						row.setModuleCommand("System", "USSRA1");
						commonDao.delete(row);
					
						row.setModuleCommand("System", "USSRA1");
						commonDao.update(row);
					}
					
				} else if (row.get("GRowState").equals("U")) {
					if(row.get("ACTVAT").equals("V")) {
						row.put("CREDOC", "V");
					} else {
						row.put("CREDOC", " ");
					}
					row.setModuleCommand("System", "UR01WK");
					count += commonDao.update(row);
				} else if(row.get("GRowState").equals("D")) {
					if(!row.get("WAREKY").equals("")){
						row.setModuleCommand("System", "UR01WK");
						count += commonDao.delete(row);
					}else{
						row.setModuleCommand("System", "USSRA1");
						count += commonDao.delete(row);
					}
				}
			}
		}
		
		return count;
	}

	@Transactional
	public int delUR01WK(DataMap map)  throws SQLException {
		int count = 0;
		map.setModuleCommand("System", "UR01BOTTOM");
		count += commonDao.delete(map);
		map.setModuleCommand("System", "UR01TOP");
		count += commonDao.delete(map);
		return count;
	}
	
	@Transactional
	public int saveLog(DataMap map)  throws SQLException {
		int count = 0;
		map.put("USERID", map.get(CommonConfig.SES_USER_ID_KEY));
		if(map.get("LGTYPE").equals("SEARCH")) {
			map.setModuleCommand("System", "PROGM_SEARCH_LOG");
		} else if(map.get("LGTYPE").equals("EXCEL")){
			map.setModuleCommand("System", "PROGM_EXCEL_DOWNLOAD_LOG");
		} else {
			throw new SQLException("Log type is not correct.");
		}
		commonDao.insert(map);
		count++;
		return count;
	}	
	
	@Transactional
	public int saveUm01(DataMap map) throws SQLException {
		int count = 0;
		List<DataMap> meList = map.getList("list");
		
		DataMap row = new DataMap();
		boolean mnudfInsert = false;
		
		row.put("MENUKY", map.getString("NEWMENUKY"));
		// 이미 등록된 메뉴(정의)인지 확인
		row.setModuleCommand("System", "MNUDFCNT");
		DataMap cnt = commonDao.getMap(row);
		if(cnt.getInt("CNT") == 0) {
			mnudfInsert = true;
		}

		
		
		for(int i = 0; i < meList.size(); i++) {
			DataMap curRow = meList.get(i).getMap("map");
			row.put("MENUKY", map.getString("NEWMENUKY"));
			row.put("MENUID", curRow.getString("MENUID"));
			row.put("INDMUK", curRow.getString("INDMUK"));
			row.put("SORTSQ", curRow.getString("SORTSQ"));
			row.put("PROGID", curRow.getString("PROGID"));
			row.put("MENULV", curRow.getString("MENULV"));
			row.put("AMNUID", curRow.getString("AMNUID"));
			row.put("LABLGR", curRow.getString("LABLGR"));
			row.put("LABLKY", curRow.getString("LABLKY"));
			row.put("INDBZL", curRow.getString("INDBZL"));
			row.put("INDARC", curRow.getString("INDARC"));
			
			row.setModuleCommand("System", "MENU");
			// 일반 탭 저장
			row.put("SHORTX", map.getString("SHORTX"));
			row.put("MENUKY", map.getString("NEWMENUKY"));
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			if(curRow.get("GRowState").equals("R")){
				continue;
			}else if(curRow.get("GRowState").equals("U")){
				commonDao.update(row);
			}else if(curRow.get("GRowState").equals("C")){
				if(mnudfInsert == true) {
					row.setModuleCommand("System", "MNUDF");
					commonDao.insert(row);
					
					row.setModuleCommand("System", "MENU");
				}
				commonDao.insert(row);
			}else{
				commonDao.delete(row);
			}
			count++;
		}
		count++;
		
		return count;
	}
}