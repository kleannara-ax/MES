package com.common.util;

import java.util.Collection;
import java.util.Map;
import java.util.Set;

import org.apache.log4j.Logger;

public class StringMap implements Map {

	private static Logger log = Logger.getLogger(StringMap.class);
	
	private static final long serialVersionUID = 5960530275216572644L;
	
	private StringBuilder col = new StringBuilder();
	
	private StringBuilder row = new StringBuilder();
	
	private boolean start = true;
	
	private String pk;

	public int size() {
		// TODO Auto-generated method stub
		return 0;
	}

	public boolean isEmpty() {
		// TODO Auto-generated method stub
		return false;
	}

	public boolean containsKey(Object key) {
		// TODO Auto-generated method stub
		return false;
	}

	public boolean containsValue(Object value) {
		// TODO Auto-generated method stub
		return false;
	}

	public Object get(Object key) {
		// TODO Auto-generated method stub
		return null;
	}

	public Object put(Object key, Object value) {
		// TODO Auto-generated method stub
		this.col.append(key).append("↓");
		this.row.append(value).append("↓");
		if(start){
			start = false;
			pk = value.toString();
		}
		return null;
	}
	
	public String getCol(){
		return this.col.toString().substring(0,col.length()-1);
	}
	
	public String getRow(){
		return this.row.toString().substring(0,row.length()-1);
	}

	public Object remove(Object key) {
		// TODO Auto-generated method stub
		return null;
	}

	public void putAll(Map m) {
		// TODO Auto-generated method stub
		
	}

	public void clear() {
		// TODO Auto-generated method stub
		
	}

	public Set keySet() {
		// TODO Auto-generated method stub
		return null;
	}

	public Collection values() {
		// TODO Auto-generated method stub
		return null;
	}

	public Set entrySet() {
		// TODO Auto-generated method stub
		return null;
	}

	public String getPk() {
		return pk;
	}
}