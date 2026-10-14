package project.system.service;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import project.common.bean.CommonConfig;
import project.common.bean.DataMap;
import project.common.dao.CommonDAO;
import project.common.util.FileUtil;
import project.common.util.ShaUtil;

@Service("systemService")
public class SystemService{
	
	static final Logger log = LogManager.getLogger(SystemService.class.getName());
	
	@Autowired
	public CommonDAO commonDao;
	
	@Transactional
	public int saveMenu(DataMap map) throws Exception {
		//0.초기변수 설정
		int count = 0;
		String gMenuId = "";
		boolean dataValidate = true;
		
		List<DataMap> saveList = new ArrayList<DataMap>();
		List<DataMap> sortList = new ArrayList<DataMap>();
		List<String> beforeSortList = new ArrayList<String>();
		List<String> sortValidList = new ArrayList<String>();
		
		try {
			gMenuId = map.getString("MENUGROUPID");
			
			saveList = map.getList("saveList");
			sortList = map.getList("sortList");
			
			//1.메뉴 데이터 접합성 검증
			boolean isSortValid = (boolean) map.get("isSort");
			if(isSortValid){
				beforeSortList = map.getList("beforeSortList");
				
				int beforeSortListSize = beforeSortList.size();
				if(beforeSortListSize > 0){
					DataMap menuGroupMap = new DataMap();
					menuGroupMap.put("MENUGROUPID", gMenuId);
					menuGroupMap.setModuleCommand("System", "MSTMENUGL");
					
					List<DataMap> menuGroupList = commonDao.getList(menuGroupMap);
					menuGroupMap.clear();
					int menuGroupListSize = menuGroupList.size();
					if(menuGroupListSize == 0){
						throw new Exception("Data Empty.");
					}else if(beforeSortListSize != menuGroupListSize){
						throw new Exception("Data Changed.");
					}
					
					for(int i = 0; i < menuGroupListSize; i++){
						DataMap row = menuGroupList.get(i).getMap("map");
						
						StringBuilder sb = new StringBuilder();
						sb.append(row.getString("PMENUID"));
						sb.append(row.getString("MENUID"));
						sb.append(row.getString("SORTORDER"));
						
						sortValidList.add(sb.toString());
						row.clear();
					}
					menuGroupList.clear();
					for(int i = 0; i < beforeSortListSize; i++){
						String sortText = beforeSortList.get(i);
						if(sortValidList.indexOf(sortText) == -1){
							dataValidate = false;
						}
					}
				}
				
				if(!dataValidate){
					throw new Exception("데이터가 변경되었습니다.\n재조회 후 다시 진행해주세요.");
				}
			}
			//2.MSTMENU : 메뉴 데이터 저장
			int saveListSize = saveList.size();
			if(saveListSize > 0){
				for(int i = 0; i < saveListSize; i++){
					DataMap row = saveList.get(i).getMap("map");
					map.clonSessionData(row);
					
					row.setModuleCommand("System", "MSTMENU");
					int mstMenuCount = commonDao.getCount(row);
					
					String gRowStatus = row.getString(CommonConfig.GRID_ROW_STATE_ATT);
					switch (gRowStatus) {
					case "C":
						if(mstMenuCount == 0){
							row.setModuleCommand("System", "TREEMSTMENU");
							commonDao.insert(row);
							count++;
						}
						break;
					case "U":
						if(mstMenuCount == 0){
							throw new Exception(String.format("[ MSTMENU ] Row Data not found.\n■ MENUID : %s\n■ MENUNAME : %s",row.getString("MENUID"),row.getString("MENUNAME")));
						}
						row.setModuleCommand("System", "TREEMSTMENU");
						count += commonDao.update(row);
						break;
					default:
						break;
					}
					row.clear();
				}
			}
			
			//3.데이터 정렬
			int sortListSize = sortList.size();
			if(sortListSize > 0){
				for(int i = 0; i < sortListSize; i++){
					DataMap row = sortList.get(i).getMap("map");
					map.clonSessionData(row);
					row.put("MENUGROUPID", gMenuId);
					
					row.setModuleCommand("System", "MSTMENUGL");
					int mstGmenuCount = commonDao.getCount(row);
					
					String gRowStatus = row.getString(CommonConfig.GRID_ROW_STATE_ATT);
					switch (gRowStatus) {
					case "C":
						if(mstGmenuCount > 0){
							throw new Exception(String.format("[ MSTMENUGL ] Row Data duplicated.\n■ MENUID : %s\n■ MENUNAME : %s",row.getString("MENUID"),row.getString("MENUNAME")));
						}
						commonDao.insert(row);
						count++;
						break;
					case "U":
						if(mstGmenuCount == 0){
							throw new Exception(String.format("[ MSTMENUGL ] Row Data not found.\n■ MENUID : %s\n■ MENUNAME : %s",row.getString("MENUID"),row.getString("MENUNAME")));
						}
						count += commonDao.update(row);
						break;
					case "D":
						count += commonDao.delete(row);
					break;
					default:
						break;
					}
					row.clear();
				}
			}
		} catch (Exception e) {
			throw new Exception(e.getMessage());
		}
		saveList.clear();
		sortList.clear();
		beforeSortList.clear();
		sortValidList.clear();
		return count;
	}
	
	@Transactional
	public int saveCopyMenu(DataMap map) throws Exception {
		int count = 0;
		
		// 메뉴 그룹 ID
		String gMenuId = map.getString("MENUGROUPID");
		
		// 메뉴 그룹 이름
		String gMenuName = map.getString("MENUGNAME");
		List<DataMap> list = map.getList("list");
		int listSize = list.size();
		
		try{
			if("".equals(gMenuId)){
				throw new Exception("메뉴그룹ID는 필수 입력 입니다.");
			}
			
			DataMap menuGroupMap = new DataMap();
			map.clonSessionData(menuGroupMap);
			menuGroupMap.put("MENUGROUPID", gMenuId);
			menuGroupMap.put("MENUGNAME", gMenuName);
			menuGroupMap.put("MENUGLABEL", "");
			menuGroupMap.setModuleCommand("System", "MSTMENUG");
			
			int cnt = commonDao.getCount(menuGroupMap);
			if(cnt > 0){
				throw new Exception("이미 등록된 메뉴그룹ID 입니다.");
			}
			
			commonDao.insert(menuGroupMap);
			menuGroupMap.clear();
			
			if(listSize == 0){
				throw new Exception("선택된 데이터가 없습니다.");
			}
			
			for (int i = 0; i < listSize; i++) {
				DataMap row = list.get(i).getMap("map");
				map.clonSessionData(row);
				
				row.put("MENUGROUPID", gMenuId);
				row.put("SORTORDER", i);
				row.setModuleCommand("System", "MSTMENUGL");
				
				commonDao.insert(row);
				row.clear();
				count++;
			}
		} catch (Exception e) {
			throw new Exception(e.getMessage());
		}
		list.clear();
		return count;
	}
	
	@Transactional
	public int saveMenuFl(DataMap map) throws Exception {
		int count = 0;
		List<DataMap> list = new ArrayList<DataMap>();
		List<DataMap> delList = new ArrayList<DataMap>();
		try {
			delList = map.getList("delList");
			int delListSize = delList.size();
			if(delListSize > 0){
				for (int i = 0; i < delList.size(); i++) {
					DataMap row = delList.get(i).getMap("map");
					row.put("USERID", map.getString(CommonConfig.SES_USER_ID_KEY));
					row.setModuleCommand("System", "MSTMENUFL");
					
					count += commonDao.delete(row);
					row.clear();
				}
			}
			delList.clear();
			list = map.getList("list");
			int listSize = list.size();
			if(listSize > 0){
				for (int i = 0; i < list.size(); i++) {
					DataMap row = list.get(i).getMap("map");
					map.clonSessionData(row);
					row.put("USERID", map.getString(CommonConfig.SES_USER_ID_KEY));
					row.setModuleCommand("System", "MSTMENUFL");
					
					count += commonDao.update(row);
					row.clear();
				}
			}
		} catch (Exception e) {
			throw new Exception(e.getMessage());
		}
		list.clear();
		return count;
	}
	
	@Transactional
	public int saveLabel(DataMap map) throws Exception {
		int count  = 0;
		List<DataMap> list = new ArrayList<DataMap>();
		try {
			list = map.getList("list");
			
			int listSize = list.size();
			if(listSize > 0){
				for (int i = 0; i < listSize; i++) {
					DataMap row = list.get(i).getMap("map");
					map.clonSessionData(row);
					
					row.setModuleCommand("System", "SYSLABEL");
					
					String  gRowStatus = row.getString(CommonConfig.GRID_ROW_STATE_ATT);
					switch (gRowStatus) {
					case "C":
						int validationCount = commonDao.getCount(row);
						if(validationCount > 0){
							String dataColSeparator = " " + CommonConfig.DATA_COL_SEPARATOR + " ";
							
							StringBuilder sb = new StringBuilder();
							sb.append(row.getString("LABELGID")).append(dataColSeparator);
							sb.append(row.getString("LABELID")).append(dataColSeparator);
							sb.append(row.getString("LANGCODE"));
							
							String duplicateData = String.valueOf(sb);
							
							String messge = this.getSystemMessage("VALID", "duplication", map.getString(CommonConfig.SES_USER_LANGUAGE_KEY));
							if(messge != null){
								messge = messge.replace("{0}", duplicateData);
							}else{
								messge = duplicateData + " is Duplicated.";
							}
							throw new Exception(messge);
						}
						commonDao.insert(row);
						count++;
						break;
					case "U":
						count += commonDao.update(row);
						break;
					case "D":
						count += commonDao.delete(row);
						break;
					default:
						break;
					}
					row.clear();
				}
			}
			
		} catch (Exception e) {
			throw new Exception(e.getMessage());
		}
		list.clear();
		return count;
	}
	
	@Transactional
	public int saveMessage(DataMap map) throws Exception {
		int count  = 0;
		List<DataMap> list = new ArrayList<DataMap>();
		try {
			list = map.getList("list");
			
			int listSize = list.size();
			if(listSize > 0){
				for (int i = 0; i < listSize; i++) {
					DataMap row = list.get(i).getMap("map");
					map.clonSessionData(row);
					
					row.setModuleCommand("System", "SYSMESSAGE");
					
					String  gRowStatus = row.getString(CommonConfig.GRID_ROW_STATE_ATT);
					switch (gRowStatus) {
					case "C":
						int validationCount = commonDao.getCount(row);
						if(validationCount > 0){
							String dataColSeparator = " " + CommonConfig.DATA_COL_SEPARATOR + " ";
							
							StringBuilder sb = new StringBuilder();
							sb.append(row.getString("MESSAGEGID")).append(dataColSeparator);
							sb.append(row.getString("MESSAGEID")).append(dataColSeparator);
							sb.append(row.getString("LANGCODE"));
							
							String duplicateData = String.valueOf(sb);
							
							String messge = this.getSystemMessage("VALID", "duplication", map.getString(CommonConfig.SES_USER_LANGUAGE_KEY));
							if(messge != null){
								messge = messge.replace("{0}", duplicateData);
							}else{
								messge = duplicateData + " is Duplicated.";
							}
							throw new Exception(messge);
						}
						commonDao.insert(row);
						count++;
						break;
					case "U":
						count += commonDao.update(row);
						break;
					case "D":
						count += commonDao.delete(row);
						break;
					default:
						break;
					}
					row.clear();
				}
			}
			
		} catch (Exception e) {
			throw new Exception(e.getMessage());
		}
		list.clear();
		return count;
	}
	
	@Transactional
	public int saveMstMenu(DataMap map) throws Exception {
		int count  = 0;
		List<DataMap> list = new ArrayList<DataMap>();
		try {
			list = map.getList("list");
			
			int listSize = list.size();
			if(listSize > 0){
				for (int i = 0; i < listSize; i++) {
					DataMap row = list.get(i).getMap("map");
					map.clonSessionData(row);
					
					row.setModuleCommand("System", "MSTMENU");
					
					String  gRowStatus = row.getString(CommonConfig.GRID_ROW_STATE_ATT);
					switch (gRowStatus) {
					case "C":
						int validationCount = commonDao.getCount(row);
						if(validationCount > 0){
							String duplicateData = row.getString("MENUID");
							String messge = this.getSystemMessage("VALID", "duplication", map.getString(CommonConfig.SES_USER_LANGUAGE_KEY));
							if(messge != null){
								messge = messge.replace("{0}", duplicateData);
							}else{
								messge = duplicateData + " is Duplicated.";
							}
							throw new Exception(messge);
						}
						commonDao.insert(row);
						count++;
						break;
					case "U":
						count += commonDao.update(row);
						break;
					case "D":
						count += commonDao.delete(row);
						break;
					default:
						break;
					}
					row.clear();
				}
			}
			
		} catch (Exception e) {
			throw new Exception(e.getMessage());
		}
		list.clear();
		return count;
	}
	
	@Transactional
	public int saveMstMenuG(DataMap map) throws Exception {
		int count  = 0;
		List<DataMap> list = new ArrayList<DataMap>();
		try {
			list = map.getList("list");
			
			int listSize = list.size();
			if(listSize > 0){
				for (int i = 0; i < listSize; i++) {
					DataMap row = list.get(i).getMap("map");
					map.clonSessionData(row);
					
					row.setModuleCommand("System", "MSTMENUG");
					
					String  gRowStatus = row.getString(CommonConfig.GRID_ROW_STATE_ATT);
					switch (gRowStatus) {
					case "C":
						int validationCount = commonDao.getCount(row);
						if(validationCount > 0){
							String duplicateData = row.getString("MENUGROUPID");
							String messge = this.getSystemMessage("VALID", "duplication", map.getString(CommonConfig.SES_USER_LANGUAGE_KEY));
							if(messge != null){
								messge = messge.replace("{0}", duplicateData);
							}else{
								messge = duplicateData + " is Duplicated.";
							}
							throw new Exception(messge);
						}
						commonDao.insert(row);
						count++;
						break;
					case "U":
						count += commonDao.update(row);
						break;
					case "D":
						count += commonDao.delete(row);
						
						row.setModuleCommand("System", "MSTMENUGL_ALL");
						commonDao.delete(row);
						
						break;
					default:
						break;
					}
					row.clear();
				}
			}
			
		} catch (Exception e) {
			throw new Exception(e.getMessage());
		}
		list.clear();
		return count;
	}
	
	@Transactional
	public int saveCommonPop(DataMap map) throws Exception {
		int count = 0;
		List<DataMap> head = new ArrayList<DataMap>();
		List<DataMap> item = new ArrayList<DataMap>();
		try {
			head = map.getList("head");
			item = map.getList("item");
			
			int headSize = head.size();
			int itemSize = item.size();
			
			if(headSize == 0){
				String message = this.getSystemMessage("SYSTEM", "ROWSEMPTY", map.getString(CommonConfig.SES_USER_LANGUAGE_KEY));
				if(message == null){
					message = "Data Not Selected.";
				}
				
				throw new Exception(message);
			}
			
			for (int i = 0; i < headSize; i++) {
				DataMap headRow = head.get(i).getMap("map");
				map.clonSessionData(headRow);
				headRow.setModuleCommand("System", "SYSCOMMPOP");
				
				String commpopId = headRow.getString("COMMPOPID");
				String headGrowStatus = headRow.getString(CommonConfig.GRID_ROW_STATE_ATT);
				switch (headGrowStatus) {
				case "C":	
					int headRowValidationCount = commonDao.getCount(headRow);
					if(headRowValidationCount > 0){
						String duplicateData = commpopId;
						String messge = this.getSystemMessage("VALID", "duplication", map.getString(CommonConfig.SES_USER_LANGUAGE_KEY));
						if(messge != null){
							messge = messge.replace("{0}", duplicateData);
						}else{
							messge = duplicateData + " is Duplicated.";
						}
						throw new Exception(messge);
					}
					commonDao.insert(headRow);
					count++;
					break;
				case "U":
					count += commonDao.update(headRow);
					break;
				case "D":
					count += commonDao.delete(headRow);
					
					headRow.setModuleCommand("System", "SYSCPOPITEM");
					count += commonDao.delete(headRow);
					break;
				default:
					break;
				}
				headRow.clear();
				
				if( itemSize > 0 &&
					commpopId.equals(item.get(0).getMap("map").getString("COMMPOPID")) &&
					!"D".equals(headGrowStatus)  
				  ){
					for(int j = 0; j < itemSize; j++){
						DataMap itemRow = item.get(j).getMap("map");
						map.clonSessionData(itemRow);
						itemRow.setModuleCommand("System", "SYSCPOPITEM");
						
						String itemGrowStatus = itemRow.getString(CommonConfig.GRID_ROW_STATE_ATT);
						switch (itemGrowStatus) {
						case "C":	
							int itemRowValidationCount = commonDao.getCount(itemRow);
							if(itemRowValidationCount > 0){
								String dataColSeparator = " " + CommonConfig.DATA_COL_SEPARATOR + " ";
								
								StringBuilder sb = new StringBuilder();
								sb.append(itemRow.getString("COMMPOPID")).append(dataColSeparator);
								sb.append(itemRow.getString("CPOPITEMID"));
								
								String duplicateData = String.valueOf(sb);
								
								String messge = this.getSystemMessage("VALID", "duplication", map.getString(CommonConfig.SES_USER_LANGUAGE_KEY));
								if(messge != null){
									messge = messge.replace("{0}", duplicateData);
								}else{
									messge = duplicateData + " is Duplicated.";
								}
								throw new Exception(messge);
							}
							commonDao.insert(itemRow);
							count++;
							break;
						case "U":
							count += commonDao.update(itemRow);
							break;
						case "D":
							count += commonDao.delete(itemRow);
							break;
						default:
							break;
						}
						itemRow.clear();
					}
				}
			}
		} catch (Exception e) {
			throw new Exception(e.getMessage());
		}
		head.clear();
		item.clear();
		return count;
	}
	
	public String getSystemMessage(String messageGid, String messageId, String langCode) throws SQLException{
		String message = "";
		
		DataMap map = new DataMap();
		map.put("MESSAGEGID", messageGid);
		map.put("MESSAGEID", messageId);
		map.put("LANGCODE", langCode);
		map.setModuleCommand("System", "SYSMESSAGE");
		
		message = (String) commonDao.getObject(map);
		map.clear();
		return message;
	}
	/*
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
					
					Properties properties = new Properties();
					
					FileUtil fileUtil = new FileUtil();
					try{
						properties = fileUtil.loadProperties(this.getClass().getResource("/").getPath().replace("classes/", "") + "conf", "commonconfig.properties");
					}catch(Exception e1){
						e1.printStackTrace();
					}

					String resetPwd = properties.getProperty("password.reset");
					
					log.debug("resetPwd : " + resetPwd);
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
					if(row.get("DELMAK").equals("")) {
						row.put("DELMAK", " ");
					}
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
	*/
	@Transactional
	public int resetPwd(DataMap map) throws SQLException {
		int count = 0;
		DataMap row;  
		
		List<DataMap> list = map.getList("list");
		
		Properties properties = new Properties();
		
		FileUtil fileUtil = new FileUtil();
		try{
			properties = fileUtil.loadProperties(this.getClass().getResource("/").getPath().replace("classes/", "") + "conf", "commonconfig.properties");
		}catch(Exception e1){
			e1.printStackTrace();
		}

		String resetPwd = properties.getProperty("password.reset");
		
		//String resetPwd = prop.getProperty("password.reset");
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
		properties.clear();
		list.clear();
		return count;
	}
	
	@Transactional
	public int saveUR01UI(DataMap map) throws SQLException {
		int count = 0;
		DataMap row = null;
		DataMap list = map.getMap("list").getMap("map");
		
		List<DataMap> itemList = map.getList("itemList");	
		list.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		list.put(CommonConfig.SES_USER_LANGUAGE_KEY, map.get(CommonConfig.SES_USER_LANGUAGE_KEY));
		int headCnt = map.getInt("headCnt");
		int rolctCnt = 0;
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
						row.put("ACTVAT", " ");
					}
					row.setModuleCommand("System", "UR01WK");
					count += commonDao.update(row);
				} else if(row.get("GRowState").equals("D")) {
					if(!row.get("WAREKY").equals("")){
						row.setModuleCommand("System", "UR01WK");
						count += commonDao.delete(row);
						row.setModuleCommand("System", "UTOval");
						rolctCnt = commonDao.getCount(row);

						if(rolctCnt == 0) {
							row.setModuleCommand("System", "UR01TOP");
							count += commonDao.delete(row);
						}
					}else{
						row.setModuleCommand("System", "USSRA1");
						count += commonDao.delete(row);
					}
				}
			}
		}
		itemList.clear();
		list.clear();
		row.clear();
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
	public int saveMstMenuGdpt(DataMap map) throws Exception {
		int count  = -1;
		List<DataMap> list = new ArrayList<DataMap>();
		
		try {
			list = map.getList("list");
			
			int listSize = list.size();
			if (listSize <= 0) return count;
			
			String deptCd = map.getString("DEPT_CD");
			String saveCd = map.getString("saveCd");
			
//			DataMap rowFrst = list.get(0).getMap("map");
//			commonDao.delete(rowFrst);
			
			switch (saveCd) {
				case "C":
					for (int i = 0; i < listSize; i++) {
						DataMap row = list.get(i).getMap("map");
						row.setModuleCommand("System", "MSTMENUGDPT");
						row.put("DEPT_CD", deptCd);
						row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
						commonDao.insert(row);
						row.clear();
						count++;
					}
					break;
				case "D":
					for (int i = 0; i < listSize; i++) {
						DataMap row = list.get(i).getMap("map");
						row.setModuleCommand("System", "MSTMENUGDPT");
						row.put("DEPT_CD", deptCd);
						count += commonDao.delete(row);
						row.clear();
					}
					break;
				default:
					break;
			}
			
		} catch (Exception e) {
			throw new Exception(e.getMessage());
		}
		list.clear();
		return count;
	}
	
	
}