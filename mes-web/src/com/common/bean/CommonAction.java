package com.common.bean;

import java.util.List;

import org.apache.log4j.Logger;

public class CommonAction {
	
	private static Logger log = Logger.getLogger(CommonAction.class);
	
	private DataMap actionGroup = new DataMap();
	private DataMap actionItem = new DataMap();

	public void resetAction(){
		this.actionGroup = new DataMap();
		this.actionItem = new DataMap();
	}
	
	public void setGroup(DataMap map) {
		this.actionGroup.put(map.getString("ACTIONGID"), map.clone());
	}
	
	public void setItem(String gid, List list) {
		this.actionItem.put(gid, list);
	}
}