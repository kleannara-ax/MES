package com.common.bean;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import org.apache.poi.util.Beta;
import org.springframework.stereotype.Repository;

public class DataRepository {
	private Map<String, Long> startTimeMap;
	private Map<String, String> stateMap;
	private Map<String, StringBuilder> startDataMap;
    private Map<String, StringBuilder> dataMap;

	public DataRepository() {
		this.startTimeMap = new HashMap();
		this.stateMap = new HashMap();
		this.startDataMap = new HashMap();
		this.dataMap = new HashMap();
	}
	
	public void addData(String key){	
		long now = System.currentTimeMillis();
		this.startTimeMap.put(key, now);
		this.stateMap.put(key, "C");
		StringBuilder startSb = new StringBuilder();
		this.startDataMap.put(key, startSb);
		StringBuilder sb = new StringBuilder();
		this.dataMap.put(key, sb);
		
		Set set = this.startTimeMap.keySet();
		Iterator<String> it = this.startTimeMap.keySet().iterator();
		while(it.hasNext()){
			String tmpKey = it.next();
			long time = this.startTimeMap.get(tmpKey);
			if(now > (time*1000*60*20)){
				removeData(tmpKey);
			}
		}
	}
	
	public void removeData(String key){
		this.startTimeMap.remove(key);
		this.stateMap.remove(key);
		this.startDataMap.remove(key);
		this.dataMap.remove(key);
	}
	
	public void setState(String key, String state){
		this.stateMap.put(key, state);
	}
	
	public String getState(String key){
		if(this.stateMap.containsKey(key)){
			return this.stateMap.get(key).toString();
		}else{
			return "E";
		}
	}
	
	public String getStartDataString(String key){
		if(this.startDataMap.containsKey(key)){
			StringBuilder sb = this.startDataMap.get(key);
			return sb.substring(0,sb.length()-1);
		}else{
			return "";
		}
	}
	
	public String getDataString(String key){
		if(this.dataMap.containsKey(key)){
			StringBuilder sb = this.dataMap.get(key);
			return sb.substring(0,sb.length()-1);
		}else{
			return "";
		}
	}
	
	public StringBuilder getStartStringBuilder(String key){
		return this.startDataMap.get(key);
	}
	
	public StringBuilder getStringBuilder(String key){
		return this.dataMap.get(key);
	}

	@Override
	public String toString() {
		return "DataRepository [startTimeMap=" + startTimeMap + ", stateMap="
				+ stateMap + ", startDataMap=" + startDataMap + ", dataMap="
				+ dataMap + "]";
	}
}