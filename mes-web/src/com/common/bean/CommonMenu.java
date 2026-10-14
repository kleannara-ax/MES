package com.common.bean;

import java.util.List;

import org.apache.log4j.Logger;

public class CommonMenu {
	
	private static Logger log = Logger.getLogger(CommonMenu.class);
	
	private DataMap menuGroup = new DataMap();
	private DataMap menuItem = new DataMap();

	public void resetMenu(){
		this.menuGroup = new DataMap();
		this.menuItem = new DataMap();
	}
	
	public void setGroup(DataMap map) {
		this.menuGroup.put(map.getString("MENUGID"), map.clone());
	}
	
	public void setItem(String gid, List list) {
		this.menuItem.put(gid, list);
	}
}