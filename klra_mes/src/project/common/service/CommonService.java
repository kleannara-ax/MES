package project.common.service;

import java.io.File;
import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.TreeMap;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.EncryptedDocumentException;
import org.apache.poi.openxml4j.exceptions.InvalidFormatException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javafx.scene.chart.PieChart.Data;
import project.common.bean.CommonConfig;
import project.common.bean.CommonLabel;
//import project.common.bean.CommonMenu;
import project.common.bean.CommonSearch;
import project.common.bean.DataMap;
import project.common.bean.FileRepository;
import project.common.bean.BaseUser;
import project.common.dao.CommonDAO;
import project.common.dao.CommonDAO_MariaDB;
import project.common.util.FileUtil;
import project.common.util.Util;
import project.mes.util.CommonUtil;

@Service("commonService")
public class CommonService {
	
	static final Logger log = LogManager.getLogger(CommonService.class.getName());
	
	@Autowired
	public CommonDAO commonDao;
	
	@Autowired
	public CommonDAO_MariaDB commonDao_MariaDB;
	
	@Autowired
	private CommonLabel commonLabel;
	
	@Autowired
	private CommonSearch commonSearch;
	
	//@Autowired
	//private CommonMenu commonMenu;
	
	@Autowired
	private FileRepository respository;
	
	@Autowired
	private Util util;

	private FileUtil fileUtil = new FileUtil();

	public int getCount(DataMap map) throws SQLException {
		return commonDao.getCount(map);
	}
	
	public int getCount(String sqlId, DataMap map) throws SQLException {
		return commonDao.getCount(sqlId, map);
	}
	
	public List getPagingList(DataMap map) throws SQLException {
		return commonDao.getPagingList(map);
	}
	public List getList(DataMap map) throws SQLException {
		return commonDao.getList(map);
	}
	
	public List getWcsList(DataMap map) throws SQLException {
		return commonDao_MariaDB.getList(map);
	}
	
	public List getList(String sqlId, DataMap map) throws SQLException {
		return commonDao.getList(sqlId, map);
	}
	public List getList(String module, String command) throws SQLException {
		DataMap map = new DataMap(module, command);
		return commonDao.getList(map);
	}
	public DataMap getMap(String sqlId, DataMap map) throws SQLException {
		return commonDao.getMap(sqlId, map);
	}
	public DataMap getMap(DataMap map) throws SQLException {
		return commonDao.getMap(map);
	}
	public Object getObj(DataMap map) throws SQLException {
		return commonDao.getObj(map);
	}
	public Object insert(String sqlId, DataMap map) throws SQLException {
		return commonDao.insert(sqlId, map);
	}
	public Object insert(DataMap map) throws SQLException {
		return commonDao.insert(map);
	}
	public int update(String sqlId, DataMap map) throws SQLException {
		return commonDao.update(sqlId, map);
	}
	public int update(DataMap map) throws SQLException {
		return commonDao.update(map);
	}
	public int delete(String sqlId, DataMap map) throws SQLException {
		return commonDao.delete(sqlId, map);
	}
	public int delete(DataMap map) throws SQLException {
		return commonDao.delete(map);
	}
	
	public List getExcel(DataMap map) throws IOException, EncryptedDocumentException, InvalidFormatException {
		return commonDao.getExcel(map);
	}
	
	public List getExcelCollist(DataMap map) throws IOException, EncryptedDocumentException, InvalidFormatException {
		return commonDao.getExcelCollist(map);
	}

	@Transactional
	public DataMap gridSave(DataMap map) throws SQLException {
		
		DataMap rsMap = new DataMap();
		
		List<DataMap> list = map.getList("list");
		
		int count = 0;
		DataMap row;
		
		if(map.containsKey(CommonConfig.GRID_REQUEST_VALIDATION_KEY)){
			String validationSql = util.createValidationSql(map);
			if(validationSql.length() > 0){
				map.put(CommonConfig.VALIDATION_SQL_KEY, validationSql);
				
				List<DataMap> vList = commonDao.getValidation(map);
				if(vList.size() > 0){
					rsMap = vList.get(0);
					if(!rsMap.getString("MSG").equals("OK")){
						return rsMap;
					}					
				}
			}			
		}
		
		for(int i=0;i<list.size();i++){			
			if(map.containsKey("param")){
				row = new DataMap(map.getMap("param"));
			}else{
				row = new DataMap();
			}				
			
			map.clonModule(row);
			map.clonSessionData(row);
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
		
		list.clear();
		rsMap.put("data", count);
		
		return rsMap;
	}
	
	@Transactional
	public int insertExcel(DataMap map, List<DataMap> list) throws SQLException {
		int count = 0;
		
		for(int i=0;i<list.size();i++){
			commonDao.insertExcel(map, list.get(i));
			count++;
		}
		
		return count;
	}
	
	public String getSqlGridList(String sql) throws SQLException {
		return commonDao.getJdbcData(sql);
	}
	
	public DataMap getGridString(TreeMap gridMap, DataMap dataMap){
		StringBuilder cols = new StringBuilder();
		StringBuilder head = new StringBuilder();
		StringBuilder rows = new StringBuilder();
		
		Iterator<Integer> it = gridMap.keySet().iterator();
		int width;
		String tabs = "\t\t\t\t\t\t\t\t\t\t\t";
		cols.append("<col width='40' />\r\n");
		cols.append(tabs).append("<col width='40' />\r\n");
		
		head.append("<th CL='STD_NUMBER'></th>\r\n");
		head.append(tabs).append("\t<th GBtnCheck='true'></th>\r\n");
		
		rows.append("<td GCol='rownum'></td>\r\n");
		rows.append(tabs).append("\t<td GCol='rowCheck'></td>\r\n");
		
		DataMap data = null;
		int key;
		while(it.hasNext()){
			key = it.next();
			data = dataMap.getMap(gridMap.get(key));
			width = data.getInt("OUTLEN");
			if(width < 50){
				width = 50;
			}else if(width < 0){
				width = 150;
			}
			cols.append(tabs).append("<col width='").append(width).append("' />\r\n");
			
			head.append(tabs).append("\t<th CL='").append(data.getString("LABLGR")).append("_").append(data.getString("LABLKY")).append("'></th>\r\n");
			
			rows.append(tabs).append("\t<td GCol='");
			
			if(data.getString("COLTY").equals("SELECT")){
				
			}else{
				if(data.getString("COLTY").equals("TEXT")){
					rows.append("text,").append(data.getString("DDICKY"));
				}else if(data.getString("COLTY").equals("CHECK")){
					rows.append("check,").append(data.getString("DDICKY"));
				}else if(data.getString("COLTY").equals("BTN")){
					rows.append("btn,").append(data.getString("DDICKY"));
				}else if(data.getString("COLTY").equals("HTML")){
					rows.append("html,").append(data.getString("DDICKY"));
				}else if(data.getString("COLTY").equals("INPUT")){
					rows.append("input,").append(data.getString("DDICKY"));
					if(!data.getString("SHLPKY").trim().equals("")){
						rows.append(",").append(data.getString("SHLPKY"));
					}
				}
				
				if(data.getString("OBJETY").equals("CAL")){
					rows.append("' GF='C");
				}else if(data.getString("OBJETY").equals("DAT")){
					rows.append("' GF='D");
				}else if(data.getString("OBJETY").equals("TIM")){
					rows.append("' GF='T");
				}else if(data.getString("OBJETY").equals("NFL")){
					rows.append("' GF='N ").append(data.getString("DBLENG"));
					if(data.getInt("DBDECP") > 0){
						rows.append(",").append(data.getString("DBDECP"));
					}
				}
				
				rows.append("'></td>\r\n");
			}
		}
		data.clear();
		DataMap rsMap = new DataMap();
		
		rsMap.put("COLS", cols.toString());
		
		rsMap.put("HEAD", head.toString());
		
		rsMap.put("ROWS", rows.toString());
		
		return rsMap;
	}
	
	public String getListString(DataMap map) throws SQLException{
		return commonDao.getListString(map);
	}

	public String getTextList(DataMap map) throws SQLException, InterruptedException{
		return commonDao.getTextList(map);
	}

	public String getJdbcData(DataMap map) throws SQLException {
		return commonDao.getJdbcData(map);
	}
	
	public int executeUpdate(String sql) throws SQLException {
		return commonDao.executeUpdate(sql);
	}
	
	public File getFile(DataMap map) throws IOException{
		return fileUtil.getFile(map.getString("PATH"), map.getString("FNAME"));
	}
	
	public void loadLabel() throws SQLException, IOException{
		List list = this.getList("Common", "SYSLABEL_LANGUAGE");
		DataMap requestMap = null;
		DataMap map = null;
		commonLabel.resetLabel();
		for(int i=0;i<list.size();i++){
			map = (DataMap)list.get(i);		
			requestMap = new DataMap(map);
			requestMap.setModuleCommand("Common", "SYSLABEL_JS");
			requestMap.put("LABLGR", "MENU");
			List dataList = commonDao.getList(requestMap);
			commonLabel.setLabel(map.getString("LANGCODE"), dataList);
			dataList.clear();
		}
		list.clear();
		requestMap.clear();
		map.clear();
		
		FileUtil fileUtil = new FileUtil();
		List labelLangList = commonLabel.getLabelLang();
		DataMap label = null;
		for(int i=0;i<labelLangList.size();i++){
			StringBuilder sb = new StringBuilder();
			sb.append("var labelObj = ");
			String langKey = labelLangList.get(i).toString();
			label = commonLabel.getLabel(langKey);
			if(label.size() >0){
				Iterator it = label.keySet().iterator();
				sb.append("{\r\n");
				int count = 0;
				while(it.hasNext()){
					String key = it.next().toString();
					while(key.indexOf(" ") != -1){
						key = key.replace(' ', '_');
					}
					String value = label.getString(key);
					while(value.indexOf("\n") != -1){
						value = value.replace('\n', ' ');
					}
					while(value.indexOf("\"") != -1){
						value = value.replace('\"', '\'');
					}
					if(count > 0){
						sb.append(",\r\n");
					}
					sb.append(key).append(" : \"").append(value).append("\"");
					count++;
				}
				sb.append("\r\n};");
				fileUtil.writeStringFile(respository.getLang(), "label-"+langKey+".js", sb.toString());
			}else{
				sb.append("new Object();");
			}
		}
		labelLangList.clear();
		label.clear();
	}
	
	public void loadLabelMap() throws SQLException, IOException{
		List list = this.getList("Common", "JLBLM_LANG");
		DataMap requestMap = null;
		DataMap map = null;
		commonLabel.resetLabel();
		for(int i=0;i<list.size();i++){
			map = (DataMap)list.get(i);		
			requestMap = new DataMap(map);
			requestMap.setModuleCommand("Common", "JLBLM");
			List dataList = commonDao.getList(requestMap);
			commonLabel.setLabel(map.getString("LANGKY"), dataList);
			dataList.clear();
		}
		list.clear();
		map.clear();
		requestMap.clear();
		
		FileUtil fileUtil = new FileUtil();
		List labelLangList = commonLabel.getLabelLang();
		DataMap label = null;
		for(int i=0;i<labelLangList.size();i++){
			StringBuilder sb = new StringBuilder();
			String langKey = labelLangList.get(i).toString();
			label = commonLabel.getLabel(langKey);
			if(label.size() >0){
				Iterator it = label.keySet().iterator();
				while(it.hasNext()){
					Object key = it.next();
					String value = label.getString(key);
					while(value.indexOf("\n") != -1){
						value = value.replace('\n', ' ');
					}
					while(value.indexOf("\"") != -1){
						value = value.replace('\"', '\'');
					}
					sb.append("commonLabel.label.put(\"").append(key).append("\",\"").append(value).append("\");\r\n");
				}
				fileUtil.writeStringFile(respository.getLang(), "label-"+langKey+".js", sb.toString());
			}
		}
		labelLangList.clear();
		label.clear();
	}
	
	public void loadMessageObj() throws SQLException, IOException{
		List list = this.getList("Common", "JMSGM_LANG");
		DataMap requestMap = null;
		DataMap map = null;
		commonLabel.resetMessage();
		for(int i=0;i<list.size();i++){
			map = (DataMap)list.get(i);
			requestMap = new DataMap(map);
			requestMap.setModuleCommand("Common", "JMSGM");
			List dataList = commonDao.getList(requestMap);
			commonLabel.setMessage(map.getString("LANGKY"), dataList);
			dataList.clear();
		}
		list.clear();
		map.clear();
		requestMap.clear();
		
		FileUtil fileUtil = new FileUtil();
		List messageLangList = commonLabel.getMessageLang();
		DataMap message = null;
		for(int i=0;i<messageLangList.size();i++){
			StringBuilder sb = new StringBuilder();
			sb.append("var messageObj = ");
			String langKey = messageLangList.get(i).toString();
			message = commonLabel.getMessage(langKey);
			if(message.size() > 0){
				Iterator it = message.keySet().iterator();
				sb.append("{\r\n");
				int count = 0;
				while(it.hasNext()){
					String key = it.next().toString();
					while(key.indexOf(" ") != -1){
						key = key.replace(' ', '_');
					}
					String value = message.getString(key);
					while(value.indexOf("\n") != -1){
						value = value.replace('\n', ' ');
					}
					while(value.indexOf("\"") != -1){
						value = value.replace('\"', '\'');
					}
					if(count > 0){
						sb.append(",\r\n");
					}
					sb.append(key).append(" : '").append(value).append("'");
					count++;
				}
				sb.append("\r\n};");
				fileUtil.writeStringFile(respository.getLang(), "message-"+langKey+".js", sb.toString());
			}else{
				sb.append("new Object();");
			}		
		}
		messageLangList.clear();
		message.clear();
	}
	
	public void loadMessage() throws SQLException, IOException{
		List list = this.getList("Common", "SYSMESSAGE_LANGUAGE");
		DataMap requestMap = null;
		DataMap map = null;
		commonLabel.resetMessage();
		for(int i=0;i<list.size();i++){
			map = (DataMap)list.get(i);
			requestMap = new DataMap(map);
			requestMap.setModuleCommand("Common", "SYSMESSAGE_JS");
			List dataList = commonDao.getList(requestMap);
			commonLabel.setMessage(map.getString("LANGCODE"), dataList);
			dataList.clear();
		}
		list.clear();
		requestMap.clear();
		map.clear();
		
		FileUtil fileUtil = new FileUtil();
		List messageLangList = commonLabel.getMessageLang();
		DataMap message = null;
		for(int i=0;i<messageLangList.size();i++){
			StringBuilder sb = new StringBuilder();
			String langKey = messageLangList.get(i).toString();
			message = commonLabel.getMessage(langKey);
			if(message.size() > 0){
				Iterator it = message.keySet().iterator();
				while(it.hasNext()){
					Object key = it.next();
					String value = message.getString(key);
					while(value.indexOf("\n") != -1){
						value = value.replace('\n', ' ');
					}
					while(value.indexOf("\"") != -1){
						value = value.replace('\"', '\'');
					}
					sb.append("commonMessage.message.put(\"").append(key).append("\",\"").append(value).append("\");\r\n");
				}
				fileUtil.writeStringFile(respository.getLang(), "message-"+langKey+".js", sb.toString());
			}			
		}
		messageLangList.clear();
		message.clear();
	}
	
	public void loadSearch() throws SQLException, IOException{
		List list = this.getList("Common", "SYSCOMMPOP");
		DataMap map;
		commonSearch.resetSearch();
		for(int i=0;i<list.size();i++){
			map = (DataMap)list.get(i);
			commonSearch.setHead(map);
			map.setModuleCommand("Common", "SYSCPOPITEM");
			List dataList = commonDao.getList(map);
			commonSearch.setItem(map.getString("COMMPOPID"), dataList);
			
			//2022.02.27 CommonSearch�쓽 itemMap 硫붾え由ъ뿉 �뙘�뾽 �븘�씠�뀥 �젙蹂� put
			DataMap row;
			DataMap itemMap = new DataMap();
			for(int j=0;j<dataList.size();j++){
				row = (DataMap) dataList.get(j);
				itemMap.put(row.getString("CPOPITEMID"),row);
			}
			commonSearch.setItemMap(map.getString("COMMPOPID"), itemMap);
		}
	}
	
	//public void loadMenu() throws SQLException, IOException{
	//	List list = this.getList("Common", "MENUGROUP");
	//	DataMap map;
	//	commonMenu.resetMenu();
	//	for(int i=0;i<list.size();i++){
	//		map = (DataMap)list.get(i);
	//		commonMenu.setGroup(map);
	//		map.setModuleCommand("Common", "MENUITEM");
	//		List dataList = commonDao.getList(map);
	//		commonMenu.setItem(map.getString("MENUGID"), dataList);
	//	}
	//}

	@Transactional
	public List variantInsert(DataMap map) throws SQLException {
		
		List rsList = new ArrayList();
		
		DataMap saveVariant = map.getMap("saveVariant");
		
		if(map.getString("DEFCHK").equals("V")){
			map.setModuleCommand("Common", "USRPHDEF");
			commonDao.update(map);
		}
		
		map.setModuleCommand("Common", "USRPH");
		if(map.containsKey("UCOUNT")){
			commonDao.update(map);
			map.setModuleCommand("Common", "USRPI");
			commonDao.delete(map);
		}else{
			commonDao.insert(map);
		}
		
		map.setModuleCommand("Common", "USRPI");
		Iterator it = saveVariant.keySet().iterator();
		int count = 0;
		while(it.hasNext()){
			count++;
			
			String key = it.next().toString();
			String value = saveVariant.getString(key);
			
			DataMap newMap = new DataMap(map);
			
			String snum = String.valueOf(count);
			String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
			newMap.put("ITEMNO", inum);
			
			newMap.put("CTRLID", key);
			newMap.put("CTRVAL", value);
			
			commonDao.insert(newMap);
			
			rsList.add(newMap);
		}
		saveVariant.clear();
		return rsList;
	}
	
	@Transactional
	public DataMap variantDelete(DataMap map) throws SQLException {
		map.setModuleCommand("Common", "USRPH");
		DataMap data = commonDao.getMap(map);
		
		commonDao.delete(map);
		
		map.setModuleCommand("Common", "USRPI");
		commonDao.delete(map);
		
		return data;
	}
	
	@Transactional
	public boolean excelDataValidation(DataMap map) throws SQLException {
		//log.info(map.getList("list").size());
		List<DataMap> list = map.getList("list");
		DataMap row = null;
		boolean result = true;
		for(int i=0;i<list.size();i++){
			row = list.get(i);
			if(i%2==0){
				row.put(CommonConfig.EXCEL_DATA_VALIDATION_RESULT_CODE, "S");
				row.put(CommonConfig.EXCEL_DATA_VALIDATION_RESULT_MSG, "SUCCESS");
			}else{
				row.put(CommonConfig.EXCEL_DATA_VALIDATION_RESULT_CODE, "E");
				row.put(CommonConfig.EXCEL_DATA_VALIDATION_RESULT_MSG, "ERROR");
				result = false;
			}
		}
		row.clear();
		list.clear();
		return result;
	}
	
	@Transactional
	public void usrloinsert(DataMap map, BaseUser user) throws SQLException {
		map.setModuleCommand("Common", "SYSGRIDCOL");
		commonDao.insert(map);
		
		//DataMap usrlo = user.getUsrlo();
		//String progid = map.getString("PROGID");
		
		/*
		 * if(usrlo.containsKey(progid)){ List list = usrlo.getList(progid);
		 * list.add(map); list.clear(); }else{ List newData = new ArrayList();
		 * newData.add(map); usrlo.put(progid, newData); newData.clear(); }
		 */
		//usrlo.clear();
	}
	
	@Transactional
	public void usrloupdate(DataMap map, BaseUser user) throws SQLException {
		map.setModuleCommand("Common", "SYSGRIDCOL");
		commonDao.update(map);
		
		/*
		 * DataMap usrlo = user.getUsrlo(); String progid = map.getString("PROGID");
		 * 
		 * if(usrlo.containsKey(progid)){ List list = usrlo.getList(progid);
		 * list.add(map); }else{ List newData = new ArrayList(); newData.add(map);
		 * usrlo.put(progid, newData); }
		 */
	}
	
	@Transactional
	public int updateAttachTbYn(String uuid,String value) throws SQLException {
		DataMap map = new DataMap();
		map.put("UUID", uuid);
		map.put("UPTBYN", value);
		map.setModuleCommand("Common", "FWCMFL0010_UPTBYN");
		
		int count = commonDao.update(map);
		map.clear();
		return count;
	}
	
	@Transactional
	public int deleteAttachFile(String uuid) throws SQLException {
		String path ="", name = "";
		
		DataMap map = new DataMap();
		map.put("UUID", uuid);
		map.setModuleCommand("Common", "FWCMFL0010");
		
		DataMap attachMap = commonDao.getMap(map);
		if(attachMap != null && !attachMap.isEmpty()){
			path = attachMap.getString("PATH");
			name = attachMap.getString("FNAME");
		}
		attachMap.clear();
		
		try {
			fileUtil.deleteFile(path, name);
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		int count = commonDao.delete(map);
		
		map.clear();
		return count;
	}
	
	// 2022-06-20(월요일) 안상현, report 위한 service
	@Transactional
	public String getPrtSeq() throws SQLException {
		
		return commonDao.getPrtSeq();
	}

	public boolean isAccessScheduleIp() {
		String ip = CommonUtil.getIp();
		try {
			if(CommonConfig.isDevServer()==false && CommonConfig.isRealServer() == false) return false;
//			if(CommonConfig.isRealServer()) {
//				try {
//					int port = tomcatUtil.getServerInstance().getPort();
//					if(port != 8005) {
//						return false;
//					}
//				}catch (Exception e) {
//
//				}
//			}
			DataMap ipMap = new DataMap();
			ipMap.setModuleCommand("Erpif", "IP");
			ipMap.put("IP", ip);
			DataMap rMap = commonDao.getMap(ipMap);
			int r = rMap.getInt("CNT");
			rMap.clear();
			ipMap.clear();
			return r > 0;
		}catch (SQLException e) {
			log.error(e.getMessage());
		}
		return false;
	}
	
	
	@Transactional
	public int saveITFMAGRP(DataMap map) throws Exception {
		int count  = 0;
		List<DataMap> list = new ArrayList<DataMap>();
		
		try {
			list = map.getList("list");
			
			int listSize = list.size();
			if (listSize <= 0) return count;
			
			for (int i = 0; i < listSize; i++) {
				DataMap row = list.get(i).getMap("map");
				String gRowState = row.getString(CommonConfig.GRID_ROW_STATE_ATT);
				row.setModuleCommand("Erpif", "ITFMAGRP_AT_DSP");
//				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				switch (gRowState) {
					case "C":
						commonDao.insert(row);
						break;
					case "U":
						count += commonDao.update(row);
						break;
//					case "D":
//						count += commonDao.delete(row);
//						break;
					default:
						break;
				}
				row.clear();
			}
			list.clear();
		} catch (Exception e) {
			throw new Exception(e.getMessage());
		}
		
		return count;
	}
	
	//설비 호기에 따라 AGV로직 NEW or OLD 사용유무(HL 가공호기에 한함)
	public String getAgvNewYN(String machCode) throws Exception {
		String agvNewYn = commonDao.getAgvNewYn(machCode);
		return agvNewYn;
	}
	
	//재고이동후 WMS테이블에 SAP자재문서 UPDATE
	public int updateSDocNo(DataMap map) throws Exception {
		int result = commonDao.updateSDocNo(map);
		return result;
	}
}