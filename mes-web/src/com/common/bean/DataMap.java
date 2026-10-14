package com.common.bean;

import java.util.ArrayList;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;

import com.common.bean.DataMap;

public class DataMap extends HashMap{
	
	private static Logger log = Logger.getLogger(DataMap.class);

	private static final long serialVersionUID = 1L;

	public DataMap(){
		super();
	}
	
	public DataMap(Map map){
		super(map);
	}
	
	public DataMap(HttpServletRequest request){
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
	
	public DataMap(String module, String command){
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
		return super.get(key)==null?new String(""):super.get(key);
	}

	@Override
	public Object put(Object key, Object value) {
		// TODO Auto-generated method stub
		value = (value==null?new String(""):value);
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
	
	public DataMap getMap(Object key){
		if(key != null && key.equals("map") && !this.containsKey("map")){
			return this;
		}else{
			DataMap rmap = (DataMap)super.get(key);
			if(rmap.containsKey("map") && rmap.get("map") instanceof DataMap){
				rmap = rmap.getMap("map");
			}
			return rmap;
		}
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
	public void clonModule(DataMap map){
		map.put(CommonConfig.MODULE_ATT_KEY, this.getString(CommonConfig.MODULE_ATT_KEY));
		map.put(CommonConfig.COMMAND_ATT_KEY, this.getString(CommonConfig.COMMAND_ATT_KEY));
		map.put(CommonConfig.SES_USER_ID_KEY, this.get(CommonConfig.SES_USER_ID_KEY));
	}
	
	public void clonSessionData(DataMap map){
		map.put(CommonConfig.SES_USER_ID_KEY, this.getString(CommonConfig.SES_USER_ID_KEY));
		map.put(CommonConfig.SES_USER_COMPANY_KEY, this.getString(CommonConfig.SES_USER_COMPANY_KEY));
		map.put(CommonConfig.SES_USER_WHAREHOUSE_KEY, this.getString(CommonConfig.SES_USER_WHAREHOUSE_KEY));
		map.put(CommonConfig.SES_USER_OWNER_KEY, this.getString(CommonConfig.SES_USER_OWNER_KEY));
	}
	
	public void setCookies(HttpServletRequest request){
		Cookie[] cookies = request.getCookies();
		if(cookies != null){
			for(Cookie cookie : cookies){
				this.put(cookie.getName(), cookie.getValue());
			}
		}
	}
}