package com.common.handler;

import org.apache.log4j.Logger;

import com.common.util.StringMap;
import com.ibatis.sqlmap.client.event.RowHandler;

public class TextRowHandlerCallback implements RowHandler{
	private static Logger log = Logger.getLogger(TextRowHandlerCallback.class);
	
	private StringBuilder sb;
	
    public TextRowHandlerCallback() {
		super();
		this.sb = new StringBuilder();
	}

	public void handleRow(Object obj) {
        StringMap map = (StringMap) obj;
        if(sb.length() == 0){
        	sb.append(map.getCol()).append("↑");
        }
        sb.append(map.getRow()).append("↑");
    }	
	
	public String getStringList(){
		if(sb.length() > 0){
			return sb.substring(0,sb.length()-1);
		}else{
			return "";
		}	
	}
}