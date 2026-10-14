package project.mes.bean;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import project.common.bean.CommonConfig;
import project.common.bean.DataMap;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import java.util.*;

public class DataMesMap extends DataMap {

	static final Logger log = LogManager.getLogger(DataMesMap.class.getName());

	private static final long serialVersionUID = 1L;

	private boolean sqlType;
	private boolean tagCheckType;

	public DataMesMap(){
		super();
		sqlType= false;
		tagCheckType= false;
	}

	public DataMesMap(Map map){
		super(map);
	}

	public DataMesMap(HttpServletRequest request){
		Enumeration<String> enumstr = request.getParameterNames();

		while(enumstr.hasMoreElements()) {
			String key = (String)enumstr.nextElement();

			String[] value = request.getParameterValues(key);

			if(value.length == 1){
			    this.put(key, request.getParameter(key));
			}else if (value.length > 1) {
				List list = new ArrayList();

				for (int i = 0; i < value.length; i++) {
					list.add(value[i]);
				}
				this.put(key, list);
			}
		}
	}

	public DataMesMap(String module, String command){
		this.put(CommonConfig.MODULE_ATT_KEY, module);
		this.put(CommonConfig.COMMAND_ATT_KEY, command);
	}
	
	public void setModuleCommand(String module, String command){
		this.put(CommonConfig.MODULE_ATT_KEY, module);
		this.put(CommonConfig.COMMAND_ATT_KEY, command);
	}
	
	public void setGridRowClone(Map map){
		this.put(CommonConfig.GRID_ROW_DATA_CLONE_KEY, map);
	}
	
	public void append(Map map){
		Iterator it = map.keySet().iterator();
		while(it.hasNext()){
			Object key = it.next();
			this.put(key, map.get(key.toString()));
		}
	}	
	
	@Override
	public Object get(Object key) {
		// TODO Auto-generated method stub
		if(this.sqlType && !key.equals("RANGE_SQL")) {
			if(super.get(key) != null) {
				String str = super.get(key).toString();
				str = sqlFilter(str);
				if(this.tagCheckType && str.length() > 0) {
					str = str.replace("<", "&lt;");
					str = str.replace(">", "&gt;");
				}
				return str;
			}else {
				return "";
			}
		}else {
			return super.get(key)==null?"":super.get(key);
		}
	}

	@Override
	public Object put(Object key, Object value) {
		
		value = (value==null?new String(""):value);
		
		if(key.toString().equals("P_RS_LIST")) {
			List<DataMap> list = (List<DataMap>) value;
			for(DataMap map : list) {
				Iterator<String> keys = map.keySet().iterator();
				while (keys.hasNext()) {
				    String k = keys.next();
				    String str = map.get(k).toString();
				    
				    if(str != null && str.matches("[+-]?\\d*(\\.\\d+)?") && !str.equals("")) {
				    	if(str.substring(0,1).equals(".")) {
				    		map.put(k, str.replace(".", "0."));
				    	}else {
				    		map.put(k, str.replace("-.", "-0."));
				    	}
				    }
				} 
			}
			value = (Object) list;
		}
		
		return super.put(key, value);
	}
	
	public Object put(Object key, Object value, Object defaultValue) {
		// TODO Auto-generated method stub
		value = (value==null?defaultValue:value);
		return super.put(key, value);
	}
	
	public Object putString(Object key, Object value, Object defaultValue) {
		// TODO Auto-generated method stub
		value = (value==null || value.equals("") ? defaultValue:value);
		return super.put(key, value);
	}

	public String getString(Object key){
		return getString(key, "");
	}
	
	public String getString(Object key, String defaultString){
		Object value = this.get(key);
		if(value != null && !value.equals("")){
			return value.toString();
		}else{
			if(defaultString == null){
				defaultString = "";
			}
			return defaultString;
		}
	}
	
	public int getInt(Object key){
		try {
			return Integer.parseInt(this.get(key).toString());
		} catch (Exception e) {
			return 0;
		}
	}
	
	public DataMesMap getMap(Object key){
		if(key != null && key.equals("map") && !this.containsKey("map")){
			return this;
		}else{
			DataMesMap rmap = (DataMesMap)super.get(key);
			if(rmap.containsKey("map") && rmap.get("map") instanceof DataMesMap){
				rmap = rmap.getMap("map");
			}
			return rmap;
		}
	}
	
	public List<DataMap> getMapList(Object key){
		return (List)super.get(key);
	}
	
	public List getList(Object key){
		return (List)super.get(key);
	}

	public boolean isEmpty(String key){
		return this.getString(key).equals("");
	}
	
	public int getSkipResults(){
		if(this.containsKey(CommonConfig.DATA_EXCEL_REQUEST_KEY)){
			return 0;
		}
		try {			
			return (this.getInt(CommonConfig.LIST_PAGE_SELECT_NUM_KEY)-1)*this.getInt(CommonConfig.LIST_PAGE_COUNT_NUM_KEY);
		} catch (Exception e) {
			return 0;
		}
	}
	
	public int getMaxResults(){
		if(this.containsKey(CommonConfig.DATA_EXCEL_REQUEST_KEY)){
			return Integer.MAX_VALUE;
		}
		try {
			return this.getInt(CommonConfig.LIST_PAGE_COUNT_NUM_KEY);
		} catch (Exception e) {
			return 0;
		}
	}
	
	public String[] getMulti(Object key){
		return getMulti(key, true);
	}
	
	public String[] getMulti(Object key, boolean putType){		
		String mValue = this.getString(key);
		mValue = mValue.replaceAll("\'", "");
		String[] list = mValue.split(",");
		if(putType){
			for(int i=0;i<list.length;i++){
				this.put(key.toString()+"_"+i, list[i]);
			}
		}
		
		return list;
	}
	
	public String getCommand(){
		return getCommand(this.getString(CommonConfig.MODULE_ATT_KEY));
	}
	public String getListCommand(){
		return getListCommand(this.getString(CommonConfig.MODULE_ATT_KEY));
	}
	public String getCountCommand(){
		return getCountCommand(this.getString(CommonConfig.MODULE_ATT_KEY));
	}
	public String getMapCommand(){
		return getMapCommand(this.getString(CommonConfig.MODULE_ATT_KEY));
	}
	public String getObjectCommand(){
		return getObjectCommand(this.getString(CommonConfig.MODULE_ATT_KEY));
	}
	public String getInsertCommand(){
		return getInsertCommand(this.getString(CommonConfig.MODULE_ATT_KEY));
	}
	public String getUpdateCommand(){
		return getUpdateCommand(this.getString(CommonConfig.MODULE_ATT_KEY));
	}
	public String getDeleteCommand(){
		return getDeleteCommand(this.getString(CommonConfig.MODULE_ATT_KEY));
	}
	public String getValidationCommand(){
		return getValidationCommand(this.getString(CommonConfig.MODULE_ATT_KEY));
	}
	
	public String getCommand(String sqlNamespace){
		String command = sqlNamespace+"."+this.getString(CommonConfig.COMMAND_ATT_KEY);
		log.debug(command);
		return command;
	}
	public String getListCommand(String sqlNamespace){
		String command = sqlNamespace+"."+this.getString(CommonConfig.COMMAND_ATT_KEY)+CommonConfig.COMMAND_LIST_TAIL;
		log.debug(command);
		return command;
	}
	public String getCountCommand(String sqlNamespace){
		String command = sqlNamespace+"."+this.getString(CommonConfig.COMMAND_ATT_KEY)+CommonConfig.COMMAND_COUNT_TAIL;
		log.debug(command);
		return command;
	}
	public String getMapCommand(String sqlNamespace){
		String command = sqlNamespace+"."+this.getString(CommonConfig.COMMAND_ATT_KEY)+CommonConfig.COMMAND_MAP_TAIL;
		log.debug(command);
		return command;
	}
	public String getObjectCommand(String sqlNamespace){
		String command = sqlNamespace+"."+this.getString(CommonConfig.COMMAND_ATT_KEY)+CommonConfig.COMMAND_OBJECT_TAIL;
		log.debug(command);
		return command;
	}
	public String getInsertCommand(String sqlNamespace){
		String command = sqlNamespace+"."+this.getString(CommonConfig.COMMAND_ATT_KEY)+CommonConfig.COMMAND_INSERT_TAIL;
		log.debug(command);
		return command;
	}
	public String getUpdateCommand(String sqlNamespace){
		String command = sqlNamespace+"."+this.getString(CommonConfig.COMMAND_ATT_KEY)+CommonConfig.COMMAND_UPDATE_TAIL;
		log.debug(command);
		return command;
	}
	public String getDeleteCommand(String sqlNamespace){
		String command = sqlNamespace+"."+this.getString(CommonConfig.COMMAND_ATT_KEY)+CommonConfig.COMMAND_DELETE_TAIL;
		log.debug(command);
		return command;
	}
	public String getValidationCommand(String sqlNamespace){
		String command = sqlNamespace+"."+this.getString(CommonConfig.COMMAND_ATT_KEY)+CommonConfig.COMMAND_VALIDATION_TAIL;
		log.debug(command);
		return command;
	}
	public void clonModule(DataMesMap map){
		map.put(CommonConfig.MODULE_ATT_KEY, this.getString(CommonConfig.MODULE_ATT_KEY));
		map.put(CommonConfig.COMMAND_ATT_KEY, this.getString(CommonConfig.COMMAND_ATT_KEY));
		map.put(CommonConfig.SES_USER_ID_KEY, this.get(CommonConfig.SES_USER_ID_KEY));
	}
	
	public void clonSessionData(DataMesMap map){
		map.put(CommonConfig.SES_USER_ID_KEY, this.getString(CommonConfig.SES_USER_ID_KEY));
		map.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, this.getString(CommonConfig.SES_USER_WHAREHOUSE_KEY));
		map.put(CommonConfig.SES_USER_WHAREHOUSE_NM_KEY, this.getString(CommonConfig.SES_USER_WHAREHOUSE_NM_KEY));
		map.put(CommonConfig.SES_USER_PLANT_KEY, this.getString(CommonConfig.SES_USER_PLANT_KEY));
		map.put(CommonConfig.SES_USER_COMPANY_KEY, this.getString(CommonConfig.SES_USER_COMPANY_KEY));
		map.put(CommonConfig.SES_DEPT_ID_KEY, this.getString(CommonConfig.SES_DEPT_ID_KEY));
		map.put(CommonConfig.SES_USER_EMPL_ID_KEY, this.getString(CommonConfig.SES_USER_EMPL_ID_KEY));
		map.put(CommonConfig.SES_SCHEMA, this.getString(CommonConfig.SES_SCHEMA));
	}
	
	public void setCookies(HttpServletRequest request){
		Cookie[] cookies = request.getCookies();
		if(cookies != null){
			for(Cookie cookie : cookies){
				this.put(cookie.getName(), cookie.getValue());
			}
		}
	}
	
	public boolean isSqlType() {
		return sqlType;
	}

	public void setSqlType(boolean sqlType) {
		this.sqlType = sqlType;
	}

	public boolean isTagCheckType() {
		return tagCheckType;
	}

	public void setTagCheckType(boolean tagCheckType) {
		this.tagCheckType = tagCheckType;
	}
	
	public String sqlFilter(String str){
		if (str.length() > 0) {
		    str = str.replace("\\", "");
//		    str = str.replace("'", "\"");
		    //str = str.replace("\0", "\\0");
		    //str = str.replace("\n", "");
		    //str = str.replace("\r", "");
//		    str = str.replace("\"", "");
//		    str = str.replace("<", "&lt;");
//		    str = str.replace(">", "&gt;");
		    //str = str.replace("\\x1a", "\\Z");				    
		}

		return str;
	}
}