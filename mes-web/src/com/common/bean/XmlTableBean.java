package com.common.bean;

import java.util.ArrayList;
import java.util.List;

public class XmlTableBean {

	private String name;

	private List<DataMap> rs;
	
	public XmlTableBean(){
		super();
		rs = new ArrayList();
	}
	
	public XmlTableBean(String name){
		this.name = name;
		rs = new ArrayList();
	}
	
	public XmlTableBean(String name, DataMap map){
		this.name = name;
		this.rs = new ArrayList();
		this.rs.add(map);
	}
	
	public XmlTableBean(String name, List<DataMap> rs){
		this.name = name;
		this.rs = rs;
	}
	
	public XmlTableBean(String ERRTYP, String ERRTXT){
		this.name = "RESULT";
		DataMap data = new DataMap();
		data.put("ERRTYP", ERRTYP);
		data.put("ERRTXT", ERRTXT);
		this.rs = new ArrayList();
		this.rs.add(data);
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public List<DataMap> getRs() {
		return rs;
	}

	public void setRs(List<DataMap> rs) {
		this.rs = rs;
	}
	
	public void addRs(DataMap data) {
		this.rs.add(data);
	}
	
	@Override
	public String toString() {
		return "XmlTableBean [name=" + name + ", rs=" + rs + "]";
	}	
}