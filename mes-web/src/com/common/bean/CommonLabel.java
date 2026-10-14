package com.common.bean;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.apache.log4j.Logger;

import com.common.util.StringMap;

public class CommonLabel {
	
	private static Logger log = Logger.getLogger(CommonLabel.class);
	
	private DataMap langLabel = new DataMap();
	private DataMap langMessage = new DataMap();

	public void resetLabel(){
		this.langLabel.clear();
	}
	
	public List  getLabelLang(){
		List list = new ArrayList();
		Iterator it = langLabel.keySet().iterator();
		while(it.hasNext()){
			Object key = it.next();
			list.add(key);
		}
		return list;
	}
	
	public List  getMessageLang(){
		List list = new ArrayList();
		Iterator it = langMessage.keySet().iterator();
		while(it.hasNext()){
			Object key = it.next();
			list.add(key);
		}
		return list;
	}
	
	public void setLabel(String lang, List<StringMap> list){
		DataMap map = new DataMap();
		for(int i=0;i<list.size();i++){
			StringMap row = list.get(i);
			map.put(row.getPk(), row.getRow());
		}
		langLabel.put(lang, map);
	}	
	public int getLagelSize(){
		int size = 0;
		Iterator it = langLabel.keySet().iterator();
		while(it.hasNext()){
			Object key = it.next();
			size += langLabel.getMap(key.toString()).size();
			log.debug(key + " : "+langLabel.getMap(key.toString()).size());
		}
		return size;
	}
	public DataMap getLabel(String lang){
		return langLabel.getMap(lang);
	}
	
	public void resetMessage(){
		this.langMessage.clear();
	}
	
	public void setMessage(String lang, List<StringMap> list){
		DataMap map = new DataMap();
		for(int i=0;i<list.size();i++){
			StringMap row = list.get(i);
			map.put(row.getPk(), row.getRow());
		}
		langMessage.put(lang, map);
	}
	public int getMessageSize(){
		int size = 0;
		Iterator it = langMessage.keySet().iterator();
		while(it.hasNext()){
			Object key = it.next();
			size += langMessage.getMap(key.toString()).size();
			log.debug(key + " : "+langMessage.getMap(key.toString()).size());
		}
		return size;
	}
	public DataMap getMessage(String lang){
		return langMessage.getMap(lang);
	}
}