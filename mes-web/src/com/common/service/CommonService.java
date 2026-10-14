package com.common.service;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Properties;
import java.util.TreeMap;

import javax.annotation.Resource;

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
import com.common.util.FileUtil;
import com.common.util.Util;

@Service("commonService")
public class CommonService extends BaseService {
	
	private static Logger log = Logger.getLogger(CommonService.class);
	
	@Autowired
	public CommonDAO commonDao;
	
	@Autowired
	private CommonLabel commonLabel;
	
	@Autowired
	private CommonSearch commonSearch;
	
	@Autowired
	private CommonMenu commonMenu;
	
	@Autowired
	private CommonAction commonAction;
	
	@Autowired
	private FileRepository respository;
	
	@Autowired
	private Util util;
	
	@Resource(name="properties")
	private Properties prop;

	private FileUtil fileUtil = new FileUtil();
	
	public int getCount(DataMap map) throws SQLException {
		return commonDao.getCount(map);
	}	
	public List getPagingList(DataMap map) throws SQLException {
		return commonDao.getPagingList(map);
	}
	public List getList(DataMap map) throws SQLException {
		return commonDao.getList(map);
	}
	public List getList(String module, String command) throws SQLException {
		DataMap map = new DataMap(module, command);
		return commonDao.getList(map);
	}
	public DataMap getMap(DataMap map) throws SQLException {
		return commonDao.getMap(map);
	}
	public Object getObj(DataMap map) throws SQLException {
		return commonDao.getObj(map);
	}
	public Object insert(DataMap map) throws SQLException {
		return commonDao.insert(map);
	}
	public int update(DataMap map) throws SQLException {
		return commonDao.update(map);
	}
	public int delete(DataMap map) throws SQLException {
		return commonDao.delete(map);
	}
	
	public List getExcel(DataMap map) throws FileNotFoundException, IOException {
		return commonDao.getExcel(map);
	}
	
	public List getExcelCollist(DataMap map) throws FileNotFoundException, IOException {
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
	public int insertExcel(DataMap map, List<DataMap> list) throws SQLException {
		int count = 0;
		
		for(int i=0;i<list.size();i++){
			commonDao.insertExcel(map, list.get(i));
			count++;
		}
		
		return count;
	}
		
	public List getColumnList(String table) throws SQLException {
		return commonDao.getTableColumn(table);
	}
	
	public List getSqlColumnList(String sql) throws SQLException {
		return commonDao.getSqlColumn(sql);
	}
	
	public String getSqlGridList(String sql) throws SQLException {
		return commonDao.getJdbcData(sql);
	}
	
	public List getSqlColObjList(String sql) throws SQLException {
		List<TableColumn> collist = commonDao.getSqlColumn(sql);
		List list = new ArrayList();
		DataMap col;
		DataMap data;
		for(int i=0;i<collist.size();i++){
			col = collist.get(i).getMap();
			col.setModuleCommand("Common", "DFDIC");
			data = commonDao.getMap(col);
			if(data == null){
				data = new DataMap();
				data.put("DDICKY", col.get("name"));
				data.put("DATFTY", " ");
				data.put("SHORTX", col.get("label"));
				data.put("DBFILD", col.get("name"));
				data.put("PDATTY", col.get("0"));
				data.put("OBJETY", "SFL");
				data.put("COLTY", "TEXT");
				data.put("DBLENG", col.get("displaySize"));
				data.put("DBDECP", "0");
				data.put("OUTLEN", col.get("displaySize"));
				data.put("SHLPKY", " ");
				data.put("FLDALN", "L");
				data.put("LABLGR", "STD");
				data.put("LABLKY", col.get("name"));
				data.put("LBTXTY", "L");
				data.put("LBLTXS", "");
				data.put("GLBTXTY", "L");
				data.put("GLBLTXS", col.get("name"));
				data.put("SELECTOPTIONS", " ");
				data.put("RANGE", " ");
				data.put("GRID", "V");
			}
			data.put("SELECTORDER", (i+1)*10);
			data.put("GRIDORDER", (i+1)*10);
			if(data.getString("OBJETY").equals("CHB")){
				data.put("COLTY", "CHECK");
			}
			if(!data.getString("SHLPKY").trim().equals("")){
				data.put("COLTY", "INPUT");
			}
			list.add(data);
		}
		
		return list;
	}
	
	public DataMap sqlColObjSave(DataMap map) throws SQLException, IOException {
		
		DataMap rsMap = new DataMap();
		
		List<DataMap> list = map.getList("list");
		
		FileUtil fileUtil = new FileUtil();
		String str;
		
		if(map.containsKey("list2")){
			str = fileUtil.getStringFile(respository.getPageTempPath(), "grid2.jsp");
		}else{
			str = fileUtil.getStringFile(respository.getPageTempPath(), "grid1.jsp");
		}
		
		
		str = str.replaceAll("#MODULE#", map.getString("MODULE"));
		str = str.replaceAll("#COMMAND#", map.getString("COMMAND"));
		
		DataMap data;
		TreeMap searchMap = new TreeMap();
		TreeMap gridMap = new TreeMap();
		DataMap dataMap = new DataMap();

		for(int i=0;i<list.size();i++){			
			data = list.get(i).getMap("map");
			if(data.getString("SELECTOPTIONS").equals("V")){
				searchMap.put(data.getInt("SELECTORDER"), data.getString("DDICKY"));
			}
			if(data.getString("GRID").equals("V")){
				gridMap.put(data.getInt("GRIDORDER"), data.getString("DDICKY"));
			}
			dataMap.put(data.getString("DDICKY"), data);
		}
		
		StringBuilder search = new StringBuilder();
		
		Iterator<Integer> it = searchMap.keySet().iterator();
		int key;
		String tabs = "\t\t\t\t\t";
		while(it.hasNext()){
			key = it.next();
			data = dataMap.getMap(searchMap.get(key));
			if(search.length() == 0){
				search.append("<tr>\r\n");
			}else{
				search.append(tabs).append("<tr>\r\n");
			}
			
			search.append(tabs).append("\t<th CL='").append(data.getString("LABLGR")).append("_").append(data.getString("LABLKY")).append("'></th>\r\n");
			search.append(tabs).append("\t<td>\r\n");
			if(data.getString("LABLKY").equals("SELECT")){
				search.append(tabs).append("\t\t<select name='").append(data.getString("DDICKY")).append("' CommonCombo='").append(data.getString("SHLPKY")).append("' class='normalInput'>\r\n");
				search.append(tabs).append("\t\t</select>\r\n");
			}else{
				if(data.getString("OBJETY").equals("CHB")){
					search.append(tabs).append("\t\t<input type='checkbox' name='").append(data.getString("DDICKY")).append("' />\r\n");
				}else{
					search.append(tabs).append("\t\t<input type='text' name='").append(data.getString("DDICKY")).append("' IAname='").append(data.getString("DDICKY")).append("' ");
					if(data.getString("OBJETY").equals("CAL")){
						search.append(" UIFormat='C' ");
					}else if(data.getString("OBJETY").equals("DAT")){
						search.append(" UIFormat='D' class='normalInput' ");
					}else if(data.getString("OBJETY").equals("TIM")){
						search.append(" UIFormat='T' class='normalInput' ");
					}else if(data.getString("OBJETY").equals("NFL")){
						search.append(" UIFormat='N ").append(data.getString("DBLENG"));
						if(data.getInt("DBDECP") > 0){
							search.append(",").append(data.getString("DBDECP"));
						}
						search.append("' class='normalInput' ");
					}else{
						if(data.getString("RANGE").equals("V")){
							search.append(" UIInput='R");
							if(!data.getString("SHLPKY").trim().equals("")){
								search.append(",").append(data.getString("SHLPKY"));
							}
							search.append("' ");
						}else{
							if(!data.getString("SHLPKY").trim().equals("")){
								search.append(" UIInput='S,").append(data.getString("SHLPKY")).append("' ");
							}
						}
					}
					
					search.append("/>\r\n");
				}
			}
			search.append(tabs).append("\t</td>\r\n");
			search.append(tabs).append("</tr>\r\n");
		}
		str = str.replaceAll("#SEARCH#", search.toString());
		rsMap.put("SEARCH", search.toString().replaceAll(tabs, ""));
		
		DataMap strMap = this.getGridString(gridMap, dataMap);
		
		str = str.replaceAll("#COLS#", strMap.getString("COLS"));
		rsMap.put("COLS", strMap.getString("COLS").replaceAll(tabs, ""));
		
		str = str.replaceAll("#HEAD#", strMap.getString("HEAD"));
		rsMap.put("HEAD", strMap.getString("HEAD").replaceAll(tabs, ""));
		
		str = str.replaceAll("#ROWS#", strMap.getString("ROWS"));
		rsMap.put("ROWS", strMap.getString("ROWS").replaceAll(tabs, ""));
		
		if(map.containsKey("list2")){
			str = str.replaceAll("#MODULE2#", map.getString("MODULE2"));
			str = str.replaceAll("#COMMAND2#", map.getString("COMMAND2"));
			
			list = map.getList("list2");
			searchMap = new TreeMap();
			gridMap = new TreeMap();
			dataMap = new DataMap();

			for(int i=0;i<list.size();i++){			
				data = list.get(i).getMap("map");
				if(data.getString("SELECTOPTIONS").equals("V")){
					searchMap.put(data.getInt("SELECTORDER"), data.getString("DDICKY"));
				}
				if(data.getString("GRID").equals("V")){
					gridMap.put(data.getInt("GRIDORDER"), data.getString("DDICKY"));
				}
				dataMap.put(data.getString("DDICKY"), data);
			}
			
			strMap = this.getGridString(gridMap, dataMap);
			
			str = str.replaceAll("#COLS2#", strMap.getString("COLS"));
			rsMap.put("COLS2", strMap.getString("COLS").replaceAll(tabs, ""));
			
			str = str.replaceAll("#HEAD2#", strMap.getString("HEAD"));
			rsMap.put("HEAD2", strMap.getString("HEAD").replaceAll(tabs, ""));
			
			str = str.replaceAll("#ROWS2#", strMap.getString("ROWS"));
			rsMap.put("ROWS2", strMap.getString("ROWS").replaceAll(tabs, ""));
		}
		
		fileUtil.writeStringFile(respository.getPageCreatePath(), "grid.jsp", str);
		
		rsMap.put("MSG", "OK");
		
		return rsMap;
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
		
		DataMap data;
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
		
		DataMap rsMap = new DataMap();
		
		rsMap.put("COLS", cols.toString());
		
		rsMap.put("HEAD", head.toString());
		
		rsMap.put("ROWS", rows.toString());
		
		return rsMap;
	}
	
	public String getListString(DataMap map) throws SQLException{
		return commonDao.getListString(map);
	}
	
	public String getAsyncList(DataMap map) throws SQLException, InterruptedException{
		return commonDao.getAsyncList(map);
	}
	
	public String getTextList(DataMap map) throws SQLException, InterruptedException{
		return commonDao.getTextList(map);
	}
	public String getTextListObj(DataMap map) throws SQLException {
		return commonDao.getTextListObj(map);
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
		List list = this.getList("Common", "JLBLM_LANG");
		DataMap requestMap = null;
		DataMap map;
		commonLabel.resetLabel();
		for(int i=0;i<list.size();i++){
			map = (DataMap)list.get(i);		
			requestMap = new DataMap(map);
			requestMap.setModuleCommand("Common", "JLBLM");
			requestMap.put("LABLGR", "MENU");
			List dataList = commonDao.getList(requestMap);
			commonLabel.setLabel(map.getString("LANGKY"), dataList);
		}
		
		FileUtil fileUtil = new FileUtil();
		List labelLangList = commonLabel.getLabelLang();
		DataMap label;
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
				fileUtil.writeStringFile(prop.getProperty("common.gokuPath"), "label-"+langKey+".js", sb.toString());
			}else{
				sb.append("new Object();");
			}
		}		
	}
	
	public void loadLabelMap() throws SQLException, IOException{
		List list = this.getList("Common", "JLBLM_LANG");
		DataMap requestMap = null;
		DataMap map;
		commonLabel.resetLabel();
		for(int i=0;i<list.size();i++){
			map = (DataMap)list.get(i);		
			requestMap = new DataMap(map);
			requestMap.setModuleCommand("Common", "JLBLM");
			List dataList = commonDao.getList(requestMap);
			commonLabel.setLabel(map.getString("LANGKY"), dataList);
		}
		
		FileUtil fileUtil = new FileUtil();
		List labelLangList = commonLabel.getLabelLang();
		DataMap label;
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
				fileUtil.writeStringFile(prop.getProperty("common.gokuPath"), "label-"+langKey+".js", sb.toString());
			}
		}		
	}
	
	public void loadMessageObj() throws SQLException, IOException{
		List list = this.getList("Common", "JMSGM_LANG");
		DataMap requestMap = null;
		DataMap map;
		commonLabel.resetMessage();
		for(int i=0;i<list.size();i++){
			map = (DataMap)list.get(i);
			requestMap = new DataMap(map);
			requestMap.setModuleCommand("Common", "JMSGM");
			List dataList = commonDao.getList(requestMap);
			commonLabel.setMessage(map.getString("LANGKY"), dataList);
		}
		
		FileUtil fileUtil = new FileUtil();
		List messageLangList = commonLabel.getMessageLang();
		DataMap message;
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
				fileUtil.writeStringFile(prop.getProperty("common.gokuPath"), "message-"+langKey+".js", sb.toString());
			}else{
				sb.append("new Object();");
			}		
		}		
	}
	
	public void loadMessage() throws SQLException, IOException{
		List list = this.getList("Common", "JMSGM_LANG");
		DataMap requestMap = null;
		DataMap map;
		commonLabel.resetMessage();
		for(int i=0;i<list.size();i++){
			map = (DataMap)list.get(i);
			requestMap = new DataMap(map);
			requestMap.setModuleCommand("Common", "JMSGM");
			List dataList = commonDao.getList(requestMap);
			commonLabel.setMessage(map.getString("LANGKY"), dataList);
		}
		
		FileUtil fileUtil = new FileUtil();
		List messageLangList = commonLabel.getMessageLang();
		DataMap message;
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
				fileUtil.writeStringFile(prop.getProperty("common.gokuPath"), "message-"+langKey+".js", sb.toString());
			}			
		}		
	}
	
	public void loadSearch() throws SQLException, IOException{
		List list = this.getList("Common", "SEARCHHEAD");
		DataMap map;
		commonSearch.resetSearch();
		for(int i=0;i<list.size();i++){
			map = (DataMap)list.get(i);
			commonSearch.setHead(map);
			map.setModuleCommand("Common", "SEARCHITEM");
			List dataList = commonDao.getList(map);
			commonSearch.setItem(map.getString("SHLPKY"), dataList);
		}
	}
	
	public void loadMenu() throws SQLException, IOException{
		List list = this.getList("Common", "MENUGROUP");
		DataMap map;
		commonMenu.resetMenu();
		for(int i=0;i<list.size();i++){
			map = (DataMap)list.get(i);
			commonMenu.setGroup(map);
			map.setModuleCommand("Common", "MENUITEM");
			List dataList = commonDao.getList(map);
			commonMenu.setItem(map.getString("MENUGID"), dataList);
		}
	}
	
	public void loadAction() throws SQLException, IOException{
		List list = this.getList("Common", "ACTIONGROUP");
		DataMap map;
		commonAction.resetAction();
		for(int i=0;i<list.size();i++){
			map = (DataMap)list.get(i);
			commonAction.setGroup(map);
			map.setModuleCommand("Common", "ACTIONITEM");
			List dataList = commonDao.getList(map);
			commonAction.setItem(map.getString("ACTIONGID"), dataList);
		}
	}
	
	public void loadSql() throws Exception{
		commonDao.reloadSql();
		commonDao.loadSql(null);
	}
	
	public void testSql(DataMap map) throws SQLException, IOException{
		commonDao.loadSql(map);
	}
	
	public void viewSqlXml(DataMap map) throws SQLException, IOException{
		commonDao.viewSqlXml(map);
	}
	
	@Transactional
	public List variantInsert(DataMap map) throws SQLException {
		
		List rsList = new ArrayList();
		
		DataMap saveVariant = map.getMap("saveVariant").getMap("map");
		
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
		DataMap row;
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
		return result;
	}
	
	@Transactional
	public void usrloinsert(DataMap map, User user) throws SQLException {
		map.setModuleCommand("Common", "USRLO");
		commonDao.insert(map);
		
		DataMap usrlo = user.getUsrlo();
		String progid = map.getString("PROGID");
		
		if(usrlo.containsKey(progid)){
			List list = usrlo.getList(progid);
			list.add(map);
		}else{
			List newData = new ArrayList();
			newData.add(map);
			usrlo.put(progid, newData);
		}
	}
	
	@Transactional
	public void usrloupdate(DataMap map, User user) throws SQLException {
		map.setModuleCommand("Common", "USRLO");
		commonDao.update(map);
		
		DataMap usrlo = user.getUsrlo();
		String progid = map.getString("PROGID");
		
		if(usrlo.containsKey(progid)){
			List list = usrlo.getList(progid);
			list.add(map);
		}else{
			List newData = new ArrayList();
			newData.add(map);
			usrlo.put(progid, newData);
		}
	}
	
	@Transactional
	public int updateAttachTbYn(String uuid,String value) throws SQLException {
		DataMap map = new DataMap();
		map.put("UUID", uuid);
		map.put("UPTBYN", value);
		map.setModuleCommand("Common", "FWCMFL0010_UPTBYN");
		
		int count = commonDao.update(map);
		
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
		
		try {
			fileUtil.deleteFile(path, name);
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		int count = commonDao.delete(map);
		
		return count;
	}
	
	@Transactional
	public void keepConnectionDatabase() throws SQLException {
		DataMap map = new DataMap();
		map.setModuleCommand("Common", "SIMPLE_DUAL_SELECTOR");
		
		DataMap resultMap = commonDao.getMap(map);
		resultMap = null;
	}
	
	@Transactional
	public Object logInsert(DataMap map) throws SQLException {
		return commonDao.insert(map);
	}
	
	// 패스워드 구성이 연속된 숫자나 영문으로 4개 이상인지 체크
	public boolean passwd_count(String passwd){
		int x = 0, count2 = 1, count3 = 1;
	
		for( x = 0 ; x < passwd.length() ; x++) {
			char temp_p = '\u0000';
			char temp_pass1 = '\u0000';
			char temp_c = '\u0000';
		
			temp_pass1 = passwd.charAt(x);// 입력받은 비밀번호의 char값
		
			if((x+1) == passwd.length()) {
				break;
			} else {
				temp_p = passwd.charAt(x+1);// 입력받은 비밀번호의 현재 index의 다음 index char값(index+1)
				temp_c = (char)(temp_pass1+1);// 입력받은 char값의 다음 char값 ( ex. a 다음은 b, 1 다음은 2...)
			}
		
			if(temp_c == temp_p) {// 입력받은 char값의 다음 index char값과 다음 char값을 비교
				count3 = count3 + 1;
			} else {
				count3 = 1;
			}
		
			if (count3 > 3) break;
		}
	
		if(count3 > 3) {
			return false;
		} else {
			return true;
		}	
	}
}