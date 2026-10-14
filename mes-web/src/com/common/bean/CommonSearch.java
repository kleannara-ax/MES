package com.common.bean;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLConnection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;

import com.common.dao.CommonDAO;
import com.common.util.FileUtil;
import com.common.bean.DataMap;

public class CommonSearch {

	private static Logger log = Logger.getLogger(CommonSearch.class);
	
	@Autowired
	public CommonDAO commonDao;
	
	@Autowired
	private FileRepository respository;
	
	private DataMap head = new DataMap();
	
	private DataMap item = new DataMap();
	
	public DataMap getHead() {
		return head;
	}
	
	public DataMap getHead(String key) throws SQLException {
		if(!head.containsKey(key)){
			DataMap map = new DataMap("Common", "SEARCHHEAD");
			map.put("SHLPKY", key);
			DataMap data = commonDao.getMap(map);
			this.setHead(data);
			map.setModuleCommand("Common", "SEARCHITEM");
			List dataList = commonDao.getList(map);
			this.setItem(key, dataList);
		}
		return head.getMap(key);
	}

	public void setHead(DataMap map) {
		this.head.put(map.getString("SHLPKY"), map.clone());
	}

	public DataMap getItem() {
		return item;
	}
	
	public List getItem(String key) {
		return item.getList(key);
	}

	public void setItem(DataMap item) {
		this.item = item;
	}
	
	public void setItem(List list) {
		for(int i=list.size()-1;i>=0;i--){
			DataMap row = (DataMap)list.get(i);
			if(this.item.containsKey(row.getString("HSHLPKY"))){
				this.item.getList(row.getString("HSHLPKY")).add(row);
			}else{
				List iList = new ArrayList();
				iList.add(row);
				this.item.put(row.getString("HSHLPKY"), iList);
			}
			list.remove(i);
		}
	}

	public void resetSearch(){
		this.head = new DataMap();
		this.item = new DataMap();
	}
	
	public void setItem(String shlpky, List itemList){
		this.item.put(shlpky, itemList);
	}
	
	public void searchFileCreate(UriInfo uriInfo) throws IOException{
		FileUtil fileUtil = new FileUtil();
		URL url;
		URLConnection conn;
		BufferedReader in = null;
		String urlStr = uriInfo.getUrl()+"/common/page/searchHelp.page?SHLPKY=";
		try{
			Iterator it = head.keySet().iterator();
			StringBuilder sb = new StringBuilder();
			String line;
			Object key;
			if(it.hasNext()){
				key = it.next();
				try{
				url = new URL(urlStr+key);
				conn = url.openConnection();
		    	in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
		    	while((line = in.readLine()) != null){
		    		sb.append(line).append("\n");
		    	}
		    	
		    	fileUtil.writeStringFile(respository.getSearch(), key+".jsp", sb.toString());
				}catch(Exception e){
					log.info("search help gen error : "+key);
				}
			}	
		}catch(Exception er){
			log.error("searchFileCreate", er);
		}finally{
			if(in != null){
				in.close();
			}
		}
	}

	@Override
	public String toString() {
		return "CommonSearch [head=" + head + ", item=" + item + "]";
	}
	
	
}