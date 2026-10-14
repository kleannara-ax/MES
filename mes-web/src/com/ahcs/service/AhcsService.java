package com.ahcs.service;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.TreeMap;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.common.bean.CommonAction;
import com.common.bean.CommonConfig;
import com.common.bean.CommonLabel;
import com.common.bean.CommonMenu;
import com.common.bean.CommonSearch;
import com.common.bean.DataMap;
import com.common.bean.FileRepository;
import com.common.bean.TableColumn;
import com.common.dao.CommonDAO;
import com.common.service.BaseService;
import com.common.service.CommonService;
import com.common.util.FileUtil;

@Service
public class AhcsService extends BaseService  {
	
	@Autowired
	private CommonService commonService;
	
	@Autowired
	public CommonDAO commonDao;
	
	@Autowired
	private FileRepository respository;
	
	@Autowired
	private CommonMenu commonMenu;
	
	@Autowired
	private CommonLabel commonLabel;
	
	@Autowired
	private CommonSearch commonSearch;
	
	@Autowired
	private CommonAction commonAction;
	
	public List getSqlDicList(String sql) throws SQLException {
		List<TableColumn> collist = commonDao.getSqlColumn(sql);
		List list = new ArrayList();
		DataMap col;
		DataMap data;
		for(int i=0;i<collist.size();i++){
			col = collist.get(i).getMap();
			col.setModuleCommand("Common", "DIC");
			data = commonDao.getMap(col);
			if(data == null){
				data = new DataMap();
				data.put("STATE", "N");
				data.put("DIC_ID", col.get("name"));
				data.put("DIC_NM", col.get("label"));
				data.put("LBL_ID", col.get("name"));
				data.put("LBL_CN", col.get("name"));
				data.put("DATA_TP_CD", col.get("typeName"));
				data.put("DATA_SIZE", col.get("displaySize"));
				data.put("DCPT_SIZE", "0");
				data.put("ALIGN_CD", "");
				data.put("OUTP_SIZE", col.get("displaySize"));
			}else{
				data.put("STATE", "R");
			}
			list.add(data);
		}
		
		return list;
	}
	
	public List getTableColObjList(String table) throws SQLException {
		return getSqlColObjList("SELECT * FROM "+table);
	}
	
	public List getSqlColObjList(String sql) throws SQLException {
		List<TableColumn> collist = commonDao.getSqlColumn(sql);
		List list = new ArrayList();
		DataMap col;
		DataMap data;
		for(int i=0;i<collist.size();i++){
			col = collist.get(i).getMap();
			col.setModuleCommand("AHCS", "COLDIC");
			data = commonDao.getMap(col);
			if(data == null){
				data = new DataMap();
				data.put("DIC_ID", col.get("name"));
				data.put("DIC_NM", col.get("label"));
				data.put("LBL_ID", col.get("name"));
				data.put("LBL_CN", col.get("name"));
				data.put("DATA_TP_CD", col.get("typeName"));
				data.put("DATA_SIZE", col.get("displaySize"));
				data.put("DCPT_SIZE", "0");
				data.put("ALIGN_CD", " ");
				data.put("OUTP_SIZE", col.get("displaySize"));
				data.put("REG_PS_ID", "");
				data.put("LREG_PS_ID", "");
			}
			data.put("SELECTOPTIONS", " ");
			data.put("SELECTORDER", (i+1)*10);
			data.put("GRID", "V");
			data.put("GRIDORDER", (i+1)*10);
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
		
		for(int i=0;i<list.size();i++){			
			data = list.get(i).getMap("map");
			map.clonModule(data);
			if(data.getString("REG_PS_ID").equals("")){
				if(commonDao.getCount("Common.DIC", data) == 0){
					commonDao.insert("Common.DIC", data);
				}
			}
			if(data.getString("LREG_PS_ID").equals("")){
				if(commonDao.getCount("Common.LABEL", data) == 0){
					data.put("LANG_CD", "KO");
					data.put("LBL_GRP_ID", "STD");
					commonDao.insert("Common.LABEL", data);
				}
			}
		}
		
		TreeMap searchMap = new TreeMap();
		TreeMap gridMap = new TreeMap();
		DataMap dataMap = new DataMap();

		for(int i=0;i<list.size();i++){			
			data = list.get(i).getMap("map");
			if(!data.getString("INQ_ATCL_CD").equals("")){
				searchMap.put(data.getInt("INQ_ATCL_SQNM"), data.getString("DIC_ID"));
			}
			gridMap.put(data.getInt("GRID_ATCL_SQNM"), data.getString("DIC_ID"));
			dataMap.put(data.getString("DIC_ID"), data);
		}
		
		StringBuilder search = new StringBuilder();
		
		Iterator<Integer> it = searchMap.keySet().iterator();
		int key;
		String tabs = "\t\t\t\t";
		String nLength;
		while(it.hasNext()){
			key = it.next();
			data = dataMap.getMap(searchMap.get(key));
			if(search.length() == 0){
				search.append("\r\n");
			}else{
				search.append(tabs).append("\r\n");
			}
			
			search.append(tabs).append("\t<dt CL='").append("STD_").append(data.getString("LBL_ID")).append("'></dt>\r\n");
			search.append(tabs).append("\t<dd>\r\n");
			if(data.getString("INQ_ATCL_CD").equals("SELECT")){
				if(data.getString("INQ_ATCL_CN").equals("")){
					search.append(tabs).append("\t\t<select name='").append(data.getString("DIC_ID")).append("'").append("'>\r\n");
				}else if(data.getString("INQ_ATCL_CN").indexOf(",") == -1){
					search.append(tabs).append("\t\t<select name='").append(data.getString("DIC_ID")).append("' CommonCombo='").append(data.getString("INQ_ATCL_CN")).append("'>\r\n");
				}else{
					search.append(tabs).append("\t\t<select name='").append(data.getString("DIC_ID")).append("' Combo='").append(data.getString("INQ_ATCL_CN")).append("'>\r\n");
				}
				search.append(tabs).append("\t\t</select>\r\n");
			}else if(data.getString("INQ_ATCL_CD").equals("CHECK")){
				search.append(tabs).append("\t\t<input type='checkbox' name='").append(data.getString("DIC_ID")).append("' value='Y' />\r\n");
			}else{
				search.append(tabs).append("\t\t<input type='text' name='").append(data.getString("DIC_ID")).append("' IAname='").append(data.getString("DIC_ID")).append("' ");
				if(data.getString("RNG_INQ_CD").equals("")){
					if(!data.getString("INQ_ATCL_CN").equals("")){
						search.append("' UIInput='S,").append(data.getString("INQ_ATCL_CN")).append("' ");
					}
				}else{
					if(data.getString("INQ_ATCL_CN").equals("")){
						search.append("' UIInput='").append(data.getString("RNG_INQ_CD")).append("' ");
					}else{
						search.append("' UIInput='").append(data.getString("RNG_INQ_CD")).append(",").append(data.getString("INQ_ATCL_CN")).append("' ");
					}
				}
				
				if(!data.getString("SRH_BAC_VAL").equals("")){
					search.append("' value='").append(data.getString("SRH_BAC_VAL")).append("' ");
				}
				if(data.getString("INQ_ATCL_CD").equals("NUMBER")){
					nLength = " " + data.getString("DATA_SIZE");
					if(data.getInt("DCPT_SIZE") > 0){
						nLength += ","+data.getString("DCPT_SIZE");
					}
					search.append(" UIFormat='N").append(nLength).append("'");
				}else if(data.getString("INQ_ATCL_CD").equals("DATE")){
					search.append(" UIFormat='C'");
				}else if(data.getString("INQ_ATCL_CD").equals("TIME")){
					search.append(" UIFormat='T'");
				}else if(data.getString("INQ_ATCL_CD").equals("STRING")){
					nLength = " " + data.getString("DATA_SIZE");
					search.append(" UIFormat='S").append(nLength).append("'");
				}
				
				search.append("/>\r\n");
			}
			/*
			if(data.getString("LABLKY").equals("SELECT")){
				search.append(tabs).append("\t\t<select name='").append(data.getString("DIC_ID")).append("' CommonCombo='").append(data.getString("SHLPKY")).append("' class='normalInput'>\r\n");
				search.append(tabs).append("\t\t</select>\r\n");
			}else{
				
				if(data.getString("OBJETY").equals("CHB")){
					search.append(tabs).append("\t\t<input type='checkbox' name='").append(data.getString("DDICKY")).append("' />\r\n");
				}else{
					search.append(tabs).append("\t\t<input type='text' name='").append(data.getString("DIC_ID")).append("' IAname='").append(data.getString("DIC_ID")).append("' ");
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
			*/
			search.append(tabs).append("\t</dd>\r\n");
			search.append(tabs).append("\r\n");
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
				if(!data.getString("INQ_ATCL_CD").equals("")){
					searchMap.put(data.getInt("INQ_ATCL_SQNM"), data.getString("DIC_ID"));
				}
				gridMap.put(data.getInt("GRID_ATCL_SQNM"), data.getString("DIC_ID"));
				dataMap.put(data.getString("DIC_ID"), data);
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
	
	public List getTableSearchObjList(String table) throws SQLException {
		return getSqlSearchObjList("SELECT * FROM "+table);
	}
	
	public List getSqlSearchObjList(String sql) throws SQLException {
		List<TableColumn> collist = commonDao.getSqlColumn(sql);
		List list = new ArrayList();
		DataMap col;
		DataMap data;
		for(int i=0;i<collist.size();i++){
			col = collist.get(i).getMap();
			col.setModuleCommand("AHCS", "COLDIC");
			data = commonDao.getMap(col);
			if(data == null){
				data = new DataMap();
				data.put("DIC_ID", col.get("name"));
				data.put("DIC_NM", col.get("name"));
				data.put("LBL_ID", col.get("name"));
				data.put("LBL_CN", col.get("name"));
				data.put("DATA_TP_CD", col.get("typeName"));
				data.put("DATA_SIZE", col.get("displaySize"));
				data.put("DCPT_SIZE", "0");
				if(col.get("typeName").equals("NUMBER")){
					data.put("ALIGN_CD", "RIGHT");
				}else{
					data.put("ALIGN_CD", "LEFT");
				}
				
				data.put("OUTP_SIZE", col.get("displaySize"));
				data.put("REG_PS_ID", "");
				data.put("LREG_PS_ID", "");
				data.put("GRID_ATCL_CD", "STRING");
			}else{
				data.put("DIC", col.get("name"));
				if(col.get("typeName").equals("NUMBER")){
					data.put("GRID_ATCL_CD", "NUMBER");
				}else{
					data.put("GRID_ATCL_CD", "STRING");
				}
			}
			data.put("INQ_ATCL_CD", "");
			data.put("SRH_BAC_VAL", "");
			data.put("RNG_INQ_CD", "");
			data.put("INQ_ATCL_CN", "");
			data.put("INQ_ATCL_SQNM", (i+1)*10);
			data.put("ENT_IMPS_YN", "");
			data.put("SRH_NSE_YN", "");
			data.put("GRID_ATCL_CN", "");
			data.put("GRID_ATCL_SQNM", (i+1)*10);
			data.put("RSLT_CLUM_YN", "Y");
			
			list.add(data);
		}
		
		return list;
	}
	
	public DataMap searchObjSave(DataMap map) throws SQLException, IOException {
		
		DataMap rsMap = new DataMap();
		
		DataMap head = map.getMap("head");
		
		map.clonSessionData(head);
		commonDao.insert("AHCS.MCVM03H", head);
		
		List<DataMap> list = map.getList("list");
	
		DataMap data;
		for(int i=0;i<list.size();i++){	
			data = list.get(i).getMap("map");
			map.clonSessionData(data);
			if(data.getString("REG_PS_ID").equals("")){
				if(commonDao.getCount("Common.DIC", data) == 0){
					commonDao.insert("Common.DIC", data);
				}
			}
			if(data.getString("LREG_PS_ID").equals("")){
				if(commonDao.getCount("Common.LABEL", data) == 0){
					data.put("LANG_CD", "KO");
					data.put("LBL_GRP_ID", "STD");
					commonDao.insert("Common.LABEL", data);
				}
			}
			commonDao.insert("AHCS.MCVM04H", data);
		}
		
		rsMap.put("MSG", "OK");
		
		return rsMap;
	}

	public DataMap getGridString(TreeMap gridMap, DataMap dataMap){
		StringBuilder cols = new StringBuilder();
		StringBuilder head = new StringBuilder();
		StringBuilder rows = new StringBuilder();
		
		Iterator<Integer> it = gridMap.keySet().iterator();
		int width;
		String tabs = "\t\t\t\t\t\t\t\t\t";
		cols.append("<col width='40' />\r\n");
		cols.append(tabs).append("<col width='40' />\r\n");
		
		head.append("<th CL='STD_NUMBER'></th>\r\n");
		head.append(tabs).append("\t<th GBtnCheck='true'></th>\r\n");
		
		rows.append("<td GCol='rownum'></td>\r\n");
		rows.append(tabs).append("\t<td GCol='rowCheck'></td>\r\n");
		
		DataMap data;
		int key;
		String nLength;
		while(it.hasNext()){
			key = it.next();
			data = dataMap.getMap(gridMap.get(key));
			width = data.getInt("OUTP_SIZE");
			if(width < 50){
				width = 50;
			}else if(width < 0){
				width = 150;
			}
			cols.append(tabs).append("<col width='").append(width).append("' />\r\n");
			
			head.append(tabs).append("\t<th CL='").append("STD_").append(data.getString("LBL_ID")).append("'>").append(data.getString("LBL_CN")).append("</th>\r\n");
			
			rows.append(tabs).append("\t<td GCol='");
			
			if(data.getString("INQ_ATCL_CD").equals("SELECT")){
				rows.append("select,").append(data.getString("DIC_ID")).append("'>\r\n");
				if(data.getString("INQ_ATCL_CN").equals("")){
					rows.append(tabs).append("\t<select>\r\n");
				}else if(data.getString("INQ_ATCL_CN").indexOf(",") == -1){
					rows.append(tabs).append("\t<select CommonCombo='").append(data.getString("INQ_ATCL_CN")).append("'>\r\n");
				}else{
					rows.append(tabs).append("\t<select Combo='").append(data.getString("INQ_ATCL_CN")).append("'>\r\n");
				}
				
				rows.append(tabs).append("\t</select>\r\n");
				rows.append(tabs).append("</td>\r\n");
			}else if(data.getString("INQ_ATCL_CD").equals("CHECK")){
				rows.append("check,").append(data.getString("DIC_ID"));
				
				rows.append("'></td>\r\n");
			}else{
				if(data.getString("INQ_ATCL_CN").equals("")){
					rows.append("input,").append(data.getString("DIC_ID")).append("'");
				}else{
					rows.append("input,").append(data.getString("DIC_ID")).append(",").append(data.getString("INQ_ATCL_CN")).append("'");
				}
				
				if(data.getString("INQ_ATCL_CD").equals("NUMBER")){
					nLength = " " + data.getString("DATA_SIZE");
					if(data.getInt("DCPT_SIZE") > 0){
						nLength += ","+data.getString("DCPT_SIZE");
					}
					rows.append(" GF='N").append(nLength).append("'");
				}else if(data.getString("INQ_ATCL_CD").equals("DATE")){
					rows.append(" GF='C'");
				}else if(data.getString("INQ_ATCL_CD").equals("TIME")){
					rows.append(" GF='T'");
				}else if(data.getString("INQ_ATCL_CD").equals("STRING")){
					nLength = " " + data.getString("DATA_SIZE");
					rows.append(" GF='S").append(nLength).append("'");
				}
				
				rows.append("></td>\r\n");
			}
		}
		
		DataMap rsMap = new DataMap();
		
		rsMap.put("COLS", cols.toString());
		
		rsMap.put("HEAD", head.toString());
		
		rsMap.put("ROWS", rows.toString());
		
		return rsMap;
	}
	
	public void loadLabel() throws SQLException, IOException{
		List list = commonService.getList("Common", "JLBLM_LANG");
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
					value = value.substring(value.indexOf(CommonConfig.DATA_COL_SEPARATOR)+1);
					sb.append("commonLabel.label.put(\"").append(key).append("\",\"").append(value).append("\");\r\n");
				}
				fileUtil.writeStringFile(respository.getLang(), "label-"+langKey+".js", sb.toString());
			}
		}		
	}
	
	public void loadMessage() throws SQLException, IOException{
		List list = commonService.getList("Common", "JMSGM_LANG");
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
					value = value.substring(value.indexOf(CommonConfig.DATA_COL_SEPARATOR)+1);
					sb.append("commonMessage.message.put(\"").append(key).append("\",\"").append(value).append("\");\r\n");
				}
				fileUtil.writeStringFile(respository.getLang(), "message-"+langKey+".js", sb.toString());
			}			
		}		
	}
	
	public void loadSearch() throws SQLException, IOException{
		List list = commonService.getList("Common", "SEARCHHEAD");
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
		List list = commonService.getList("Common", "MENUGROUP");
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
		List list = commonService.getList("Common", "ACTIONGROUP");
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
}
