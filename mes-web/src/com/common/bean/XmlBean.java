package com.common.bean;

import java.util.ArrayList;

import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.jdom.Element;

public class XmlBean {
	
	private List xmlTableList;
	
	public XmlBean(){
		xmlTableList = new ArrayList();
	}
	 
	public List getXmlTableList() {
		return xmlTableList;
	}

	public void setXmlTableList(List xmlTableList) {
		this.xmlTableList = xmlTableList;
	}

	public void addXmlTableList(XmlTableBean xmlTableBean){
		xmlTableList.add(xmlTableBean);
	}
	
	public void setXml(Element rootNode){
		List list = rootNode.getChildren("Table");		
		for (int i = 0; i < list.size(); i++) {			
		   Element node = (Element) list.get(i);
		   XmlTableBean xmlTableBean = new XmlTableBean(node.getAttributeValue("Name"));
		   List rsList = node.getChildren("rs");
		   for (int j = 0; j < rsList.size(); j++) {
			   Element rsNode = (Element) rsList.get(j);
			   List dataList = rsNode.getChildren();
			   //List dataList = rsNode.getChildren("item");
			   DataMap data = new DataMap();
			   for (int k = 0;k < dataList.size();k++) {
				   Element dataNode = (Element) dataList.get(k);
				   data.put(dataNode.getName(), dataNode.getText());
				   //data.put(dataNode.getAttribute("key"), dataNode.getText());
			   }
			   xmlTableBean.addRs(data);
		   }
		   addXmlTableList(xmlTableBean);
		}
	}

	public String getXmlString(){
		StringBuilder sb = new StringBuilder();
		//sb.append("<?xml version='1.0' encoding='UTF-8'?>\n");
		sb.append("\r\n\r\n<XML>");
		
		XmlTableBean table;
		List list;
		Map map;
		String key;
		for(int i=0;i<xmlTableList.size();i++){
			table = (XmlTableBean)xmlTableList.get(i);
			sb.append("<Table Name = \"").append(table.getName()).append("\">");
			list = table.getRs();
			for(int j=0;j<list.size();j++){
				map = (Map)list.get(j);
				Iterator it = map.keySet().iterator();
				sb.append("<rs>");
				while(it.hasNext()){
					key = it.next().toString();
					sb.append("<").append(key).append(">").append(map.get(key)).append("</").append(key).append(">");
				}
				sb.append("</rs>");
				
			}
			sb.append("</Table>");
		}
		sb.append("</XML>\r\n");
		//System.out.println(sb.toString());
		return sb.toString();
	}
	
	@Override
	public String toString() {
		return "XmlBean [xmlTableList=" + xmlTableList + "]";
	}
}