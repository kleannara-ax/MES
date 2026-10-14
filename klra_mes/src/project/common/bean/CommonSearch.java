package project.common.bean;

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

import project.common.bean.DataMap;
import project.common.dao.CommonDAO;
import project.common.util.FileUtil;

public class CommonSearch {

	private static Logger log = Logger.getLogger(CommonSearch.class);
	
	@Autowired
	public CommonDAO commonDao;
	
	@Autowired
	private FileRepository respository;
	
	private DataMap head = new DataMap();
	
	private DataMap item = new DataMap();
	
	private DataMap itemMap = new DataMap();
	
	public DataMap getHead() {
		return head;
	}
	
	public DataMap getHead(DataMap map) throws SQLException {
		String key = map.getString("COMMPOPID");
		if(!head.containsKey(key)){
			//map.put("COMMPOPID", key);
			DataMap data = commonDao.getMap("Common.SYSCOMMPOP",map);
			if(data == null){
				return null;
			}
			this.setHead(data);
			map.setModuleCommand("Common", "SYSCPOPITEM");
			List<DataMap> dataList = commonDao.getList("Common.SYSCPOPITEM", map);
			this.setItem(key, dataList);
			DataMap row;
			DataMap itemMap = new DataMap();
			for(int i=0;i<dataList.size();i++){
				row = dataList.get(i);
				itemMap.put(row.getString("CPOPITEMID"),row);
			}
			this.setItemMap(key, itemMap);
		}
		return head.getMap(key);
	}

	public void setHead(DataMap map) {
		this.head.put(map.getString("COMMPOPID"), map.clone());
	}

	public DataMap getItem() {
		return this.item;
	}
	
	public List getItem(String key) {
		return this.item.getList(key);
	}
	
	public DataMap getItemMap(String key) {
		return this.itemMap.getMap(key);
	}

	public void setItem(DataMap item) {
		this.item = item;
	}

	public void resetSearch(){
		this.head = new DataMap();
		this.item = new DataMap();
	}
	
	public void setItem(String shlpky, List itemList){
		this.item.put(shlpky, itemList);
	}
	
	public DataMap getItemMap() {
		return itemMap;
	}

	public void setItemMap(DataMap itemMap) {
		this.itemMap = itemMap;
	}
	
	public void setItemMap(String shlpky, DataMap itemMap) {
		this.itemMap.put(shlpky, itemMap);
	}

	public void searchFileCreate(UriInfo uriInfo) throws IOException{
		FileUtil fileUtil = new FileUtil();
		URL url;
		URLConnection conn;
		BufferedReader in = null;
		String urlStr = uriInfo.getUrl()+"/common/page/commonPop.page?COMMPOPID=";
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