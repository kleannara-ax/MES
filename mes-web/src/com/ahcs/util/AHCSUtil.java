package com.ahcs.util;

import java.util.List;

import com.common.bean.DataMap;

public class AHCSUtil {
	public final static String SES_USER_MENULIST_KEY = "SES_USER_MENULIST";
	
	public String getMenuTag(List menuList){
		StringBuilder sb = new StringBuilder();
        DataMap menuRow;
        DataMap nextMenuRow;
        String h1;
      	String h2;
      	String uri;
      	String fnStr;
    	for(int i=0;i<menuList.size();i++){
    		menuRow = (DataMap)menuList.get(i);
    		if(i == (menuList.size() -1)){
    			nextMenuRow = (DataMap)menuList.get(i);
    		}else{
    			nextMenuRow = (DataMap)menuList.get(i+1);
    		}
    		
    		if(menuRow.getInt("LEVEL") == 1){
    			h1 = "<h2>";
    			h2 = "</h2>";
    		}else{
    			h1 = "";
    			h2 = "";
    		}
    		if(!menuRow.getString("URI_CN").equals("")){
    			//uri = menuRow.getString("URI_CN");
    			uri="#";
    			fnStr = " onClick=\"pageOpen(this,'"+menuRow.get("MU_ID")+"','"+menuRow.getString("URI_CN")+"')\"";
    		}else{
    			uri="#";
    			fnStr = "";
    		}
    		
    		if(nextMenuRow.getInt("LEVEL") > menuRow.getInt("LEVEL")){
    			sb.append("<li class='n1'>").append(h1).append("<a href='").append(uri).append("' menuId='").append(menuRow.get("MU_ID")).append("'").append(fnStr).append(">").append(menuRow.get("MU_NM")).append("</a>").append(h2).append("\r\n");
    			sb.append("<ul class='depth").append(nextMenuRow.getInt("LEVEL")).append("_ul'>\r\n");
    		}else if(nextMenuRow.getInt("LEVEL") < menuRow.getInt("LEVEL")){
    			sb.append("<li class='n1'>").append(h1).append("<a href='").append(uri).append("' menuId='").append(menuRow.get("MU_ID")).append("'").append(fnStr).append(">").append(menuRow.get("MU_NM")).append("</a>").append(h2).append("</li>\r\n");
    			for(int j=0;j<menuRow.getInt("LEVEL")-nextMenuRow.getInt("LEVEL");j++){
    				sb.append("</ul>\r\n</li>\r\n");
    			}
    		}else{
    			sb.append("<li class='n1'>").append(h1).append("<a href='").append(uri).append("' menuId='").append(menuRow.get("MU_ID")).append("'").append(fnStr).append(">").append(menuRow.get("MU_NM")).append("</a>").append(h2).append("</li>\r\n");
    		}
    		
    		if(i == (menuList.size() -1)){
    			for(int j=1;j<menuRow.getInt("LEVEL");j++){
    				sb.append("</ul>\r\n</li>\r\n");
    			}
    			
    		}
    	}
    	return sb.toString();
	}
}