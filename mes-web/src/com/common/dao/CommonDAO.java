package com.common.dao;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.servlet.http.HttpSession;
import javax.sql.DataSource;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.orm.ibatis.SqlMapClientCallback;
import org.springframework.orm.ibatis.SqlMapClientFactoryBean;
import org.springframework.orm.ibatis.SqlMapClientTemplate;
import org.springframework.stereotype.Repository;

import com.common.bean.CommonConfig;
import com.common.bean.DataMap;
import com.common.bean.DataRepository;
import com.common.bean.FileRepository;
import com.common.bean.SystemConfig;
import com.common.bean.TableColumn;
import com.common.handler.TextRowHandlerCallback;
import com.common.ibatis.SqlMapLoad;
import com.common.util.FileUtil;
import com.common.bean.DataMap;
import com.common.util.SqlUtil;
import com.common.util.StringMap;
import com.common.util.Util;
import com.ibatis.sqlmap.client.SqlMapClient;
import com.ibatis.sqlmap.client.SqlMapExecutor;

@Repository
public class CommonDAO extends BaseDAO {	
	private static Logger log = Logger.getLogger(CommonDAO.class);
	
	@Autowired
	@Qualifier("dataSource")
	DataSource dataSource;
	
	@Autowired
	private SystemConfig systemConfig;
	
	@Autowired	
	private FileRepository respository;
	
	@Autowired
	private DataRepository dataRespository;
	
	@Autowired
	private Util util;
	
	@Autowired
	@Qualifier("sqlMapClient")
	SqlMapClient sqlMapClient;
	
	@Autowired
	@Qualifier("sqlMapClientTemplate")
	SqlMapClientTemplate sqlMapClientTemplate;
	
	@Autowired
	@Qualifier("sqlMapClient")
	SqlMapClientFactoryBean sqlMapClientFactoryBean;
	
	public List getTableColumn(String table) throws SQLException{
		String sql = "SELECT * FROM "+table+" WHERE 1=0";
		
		return getSqlColumn(sql);
	}

	public List getSqlColumn(String sql) throws SQLException{		
		List list = new ArrayList();		
		
		Statement stmt = dataSource.getConnection().createStatement();
		ResultSet rs = stmt.executeQuery(sql);
		ResultSetMetaData rsmd= rs.getMetaData();
		
		int cnt = rsmd.getColumnCount();
		for(int i=1;i<=cnt;i++){
			TableColumn col = new TableColumn();
			col.setCatalogName(rsmd.getCatalogName(i));
			col.setClassName(rsmd.getColumnClassName(i));
			col.setDisplaySize(rsmd.getColumnDisplaySize(i));
			col.setLabel(rsmd.getColumnLabel(i).toUpperCase());
			col.setName(rsmd.getColumnName(i).toUpperCase());
			col.setType(rsmd.getColumnType(i));
			col.setTypeName(rsmd.getColumnTypeName(i));			
			list.add(col);
		}
		
		return list;
	}
	
	public int getCount(DataMap map) throws SQLException {
		return (Integer)sqlMapClientTemplate.queryForObject(map.getCountCommand(), map);
	}
	public int getCount(String sqlId, DataMap map) throws SQLException {
		String command = sqlId + CommonConfig.COMMAND_COUNT_TAIL;
		log.debug(command);
		return (Integer)sqlMapClientTemplate.queryForObject(command, map);
	}
	public List getPagingList(DataMap map) throws SQLException {
		return sqlMapClientTemplate.queryForList(map.getListCommand(), map, map.getSkipResults(), map.getMaxResults());
	}
	public List getList(DataMap map) throws SQLException {
		return sqlMapClientTemplate.queryForList(map.getListCommand(), map);
	}
	public List getList(String sqlId, Map map) throws SQLException {
		String command = sqlId + CommonConfig.COMMAND_LIST_TAIL;
		log.debug(command);
		return sqlMapClientTemplate.queryForList(command, map);
	}
	public DataMap getMap(DataMap map) throws SQLException {
		return (DataMap)sqlMapClientTemplate.queryForObject(map.getMapCommand(), map);
	}
	public DataMap getMap(String sqlId, DataMap map) throws SQLException {
		String command = sqlId + CommonConfig.COMMAND_MAP_TAIL;
		log.debug(command);
		return (DataMap)sqlMapClientTemplate.queryForObject(command, map);
	}
	public Object getObj(DataMap map) throws SQLException {
		return sqlMapClientTemplate.queryForObject(map.getObjectCommand(), map);
	}
	public Object getObj(String sqlId, DataMap map) throws SQLException {
		String command = sqlId + CommonConfig.COMMAND_OBJECT_TAIL;
		log.debug(command);
		return sqlMapClientTemplate.queryForObject(command, map);
	}
	public Object insert(DataMap map) throws SQLException {
		return sqlMapClientTemplate.insert(map.getInsertCommand(), map);
	}
	public Object insert(String sqlId, Map map) throws SQLException {
		String command = sqlId + CommonConfig.COMMAND_INSERT_TAIL;
		log.debug(command);
		return sqlMapClientTemplate.insert(command, map);
	}
	public int listInsert(DataMap map, List<DataMap> list) throws SQLException {
		int count = 0;
		DataMap row;
		
		for(int i=0;i<list.size();i++){			
			if(map.containsKey("param")){
				row = new DataMap(map.getMap("param").getMap("map"));
			}else{
				row = new DataMap();
			}
			map.clonModule(row);
			row.append(list.get(i).getMap("map"));			
			insert(row);
			count ++; 
		}
		
		return count;
	}
	@SuppressWarnings("deprecation")
	public Object batchInsert(final HttpSession session, final DataMap map, final List<DataMap> list) throws Exception {
		return sqlMapClientTemplate.execute(new SqlMapClientCallback<Integer>() {
			int dataCount = 0;
			int batchCount = 0;
			int totalCount = list.size();
			int queDataCount = 0;
			
			String btcSeq = map.getString("BTCSEQ");
			
			@Override
			public Integer doInSqlMapClient(SqlMapExecutor executor) throws SQLException {
				try {
					if(totalCount > 0){
						queDataCount = (int) Math.ceil(totalCount/10);
						if(queDataCount <= 0){
							queDataCount = 1;
						}else if(queDataCount > 1000){
							queDataCount = 1000;
						}
						
						executor.startBatch();
						
						DataMap row;
						
						for(int i = 0; i < totalCount; i++){
							if(map.containsKey("param")){
								row = new DataMap(map.getMap("param").getMap("map"));
							}else{
								row = new DataMap();
							}
							
							map.clonModule(row);
							row.append(list.get(i).getMap("map"));
							
							//insert(row);
							executor.insert(map.getInsertCommand(), row);
							
							dataCount++;
							
							session.setAttribute(btcSeq, dataCount);
							//System.out.println("dataCount:: "+btcSeq+" >>>>>>>>>>>>>>>>" + session.getAttribute(btcSeq));
							
							if((dataCount%queDataCount) == 0){
								executor.executeBatch();
								batchCount++;
							}
						}
						
						if((batchCount*queDataCount) < totalCount){
							executor.executeBatch();
						}
					}
				} catch (Exception e) {
					e.printStackTrace();
					throw new SQLException(e.getMessage());
				}
				return dataCount;
			}
			
		});
	}
	public int insertRsnum(DataMap map) throws SQLException {
		return sqlMapClientTemplate.update(map.getInsertCommand(), map);
	}
	public int update(DataMap map) throws SQLException {
		return sqlMapClientTemplate.update(map.getUpdateCommand(), map);
	}
	public int update(String sqlId, Map map) throws SQLException {
		String command = sqlId + CommonConfig.COMMAND_UPDATE_TAIL;
		log.debug(command);
		return sqlMapClientTemplate.update(command, map);
	}
	public int listUpdate(DataMap map, List<DataMap> list) throws SQLException {
		int count = 0;
		DataMap row;
		
		for(int i=0;i<list.size();i++){			
			if(map.containsKey("param")){
				row = new DataMap(map.getMap("param").getMap("map"));
			}else{
				row = new DataMap();
			}				
			map.clonModule(row);
			row.append(list.get(i).getMap("map"));			
			count += update(row);
		}
		
		return count;
	}
	public int delete(DataMap map) throws SQLException {
		return sqlMapClientTemplate.delete(map.getDeleteCommand(), map);
	}
	public int delete(String sqlId, Map map) throws SQLException {
		String command = sqlId + CommonConfig.COMMAND_DELETE_TAIL;
		log.debug(command);
		return sqlMapClientTemplate.delete(command, map);
	}
	public int listDelete(DataMap map, List<DataMap> list) throws SQLException {
		int count = 0;
		DataMap row;
		
		for(int i=0;i<list.size();i++){			
			if(map.containsKey("param")){
				row = new DataMap(map.getMap("param").getMap("map"));
			}else{
				row = new DataMap();
			}				
			map.clonModule(row);
			row.append(list.get(i).getMap("map"));			
			count += delete(row);
		}
		
		return count;
	}
	public Object insertExcel(DataMap param, DataMap map) throws SQLException {
		return sqlMapClientTemplate.insert(param.getInsertCommand(), map);
	}
	public Object getObject(DataMap map) throws SQLException {
		return sqlMapClientTemplate.queryForObject(map.getObjectCommand(), map);
	}

	public String listValidation(DataMap map, List<DataMap> list) throws SQLException {
		String result = "OK";
		String validationSql = "";		
		
		if( map.containsKey("key") ){
			String key = map.get("key").toString();
			
			validationSql = util.urlCreateValidationSql(map, key);
			map.put(CommonConfig.VALIDATION_SQL_KEY, validationSql);
						
			List<DataMap> vList = getValidation(map);
			
			DataMap rsMap = new DataMap();
			
			for(int j = 0; j < vList.size(); j++){
				rsMap = vList.get(j);
					
				if( !rsMap.getString("MSG").equals("OK") ){
					
					result = rsMap.getString("MSG");
					break;
				}
			}
		}
		return result;
	}
	public List getValidation(DataMap map) throws SQLException {
		return sqlMapClientTemplate.queryForList(map.getValidationCommand(), map);
	}
	
	public List getExcel(DataMap map) throws FileNotFoundException, IOException{
		map.put(CommonConfig.MODULE_ATT_KEY, CommonConfig.FILE_MODULE);
		map.put(CommonConfig.COMMAND_ATT_KEY, CommonConfig.FILE_TABLE_NAME);
		
		DataMap data = (DataMap)sqlMapClientTemplate.queryForObject(map.getMapCommand(), map);
		FileUtil fileUtil = new FileUtil();
		File file = fileUtil.getFile(data.getString("PATH"), data.getString("FNAME"));
		
		List list = null;
		int colNameRowNum = 0;
		if(map.containsKey(CommonConfig.DATA_EXCEL_COLNAME_ROWNUM_KEY)){
			colNameRowNum = map.getInt(CommonConfig.DATA_EXCEL_COLNAME_ROWNUM_KEY);
		}
		if(data.getString("MIME").equals("xls")){
			list = fileUtil.getXlsFile(file, colNameRowNum);
		}else if(data.getString("MIME").equals("xlsx")){
			list = fileUtil.getXlsxFile(file, colNameRowNum);
		}
		
		fileUtil.deleteFile(data.getString("PATH"), data.getString("FNAME"));
   
		return list;
	}
	
	public List getExcelCollist(DataMap map) throws FileNotFoundException, IOException{
		map.put(CommonConfig.MODULE_ATT_KEY, CommonConfig.FILE_MODULE);
		map.put(CommonConfig.COMMAND_ATT_KEY, CommonConfig.FILE_TABLE_NAME);
		
		DataMap data = (DataMap)sqlMapClientTemplate.queryForObject(map.getMapCommand(), map);
		FileUtil fileUtil = new FileUtil();
		File file = fileUtil.getFile(data.getString("PATH"), data.getString("FNAME"));
		
		List list = null;
		int colNameRowNum = 0;
		if(map.containsKey(CommonConfig.DATA_EXCEL_COLNAME_ROWNUM_KEY)){
			colNameRowNum = map.getInt(CommonConfig.DATA_EXCEL_COLNAME_ROWNUM_KEY);
		}
		if(data.getString("MIME").equals("xls")){
			list = fileUtil.getXlsFileCollist(file, colNameRowNum);
		}else if(data.getString("MIME").equals("xlsx")){
			list = fileUtil.getXlsxFileCollist(file, colNameRowNum);
		}
		
		return list;
	}
	
	public String getAsyncList(DataMap map) throws SQLException, InterruptedException {
		String listData = null;
		long start = System.currentTimeMillis();
		if(map.containsKey("DATA_KEY")){
			String key = map.getString("DATA_KEY");
			String state;
			while(!(state = dataRespository.getState(key)).equals("E")){
				Thread.sleep(10);
				if((System.currentTimeMillis()-start) > (1000*60*10)){
					state = "E";
					log.debug("getAsyncList "+key+" END Break");
					break;
				}
				//System.out.print(".");
			}
			log.debug("getAsyncList "+key+" END");
			String data = dataRespository.getDataString(key);
			dataRespository.removeData(key);
			listData = data;			
		}else{
			String key = UUID.randomUUID().toString();
			AsyncDAO asyncDAO =  new AsyncDAO();
			SqlUtil sqlUtil = new SqlUtil();
			String sql = sqlUtil.getListSqlString(sqlMapClientTemplate, map);
			asyncDAO.setAsyncDAO(dataRespository, dataSource, sql, map.getInt(CommonConfig.GRID_REQUEST_VIEW_COUNT), key);
			asyncDAO.start();
			String state;
			while((state = dataRespository.getState(key)).equals("C")){
				Thread.sleep(10);
				if((System.currentTimeMillis()-start) > (1000*60)){
					state = "E";
					log.debug("getAsyncList "+key+" START Break");
					break;
				}
			}
			log.debug("getAsyncList "+key+" START");
			String data;
			if(state.equals("S")){
				data = dataRespository.getStartDataString(key);
			}else{
				data = dataRespository.getDataString(key);
				key="END";
				dataRespository.removeData(key);
			}
			listData = key+" "+data;
		}
		
		return listData;
	}
	
	public String getListStringHandler(DataMap map) throws SQLException {
		TextRowHandlerCallback callback = new TextRowHandlerCallback();
		
		sqlMapClient.queryWithRowHandler(map.getListCommand(), map, callback);
		
		return callback.getStringList();
	}
	
	public String getListString(DataMap map) throws SQLException {
		SqlUtil sqlUtil = new SqlUtil();
		String sql = sqlUtil.getListSqlString(sqlMapClientTemplate, map);
		Integer fetchSize = null;
		if(map.containsKey("fetchSize")){
			fetchSize = (Integer)map.get("fetchSize");
		}
		String listData =  sqlUtil.getJdbcData(dataSource, sql, fetchSize);
		
		return listData;
	}
	
	public String getTextListHandler(DataMap map) throws SQLException {
		TextRowHandlerCallback callback = new TextRowHandlerCallback();
		
		sqlMapClient.queryWithRowHandler(map.getListCommand(), map, callback);
		
		String listData = callback.getStringList();
		
		if(listData.length() > 0){
			listData = "END "+listData;
		}

		return listData;
	}
	
	public String getTextList(DataMap map) throws SQLException {
		SqlUtil sqlUtil = new SqlUtil();
		String sql = sqlUtil.getListSqlString(sqlMapClientTemplate, map);
		Integer fetchSize = null;
		if(map.containsKey("fetchSize")){
			fetchSize = (Integer)map.get("fetchSize");
		}
		String listData =  "END "+sqlUtil.getJdbcData(dataSource, sql, fetchSize);
		
		return listData;
	}
	
	public String getTextListObj(DataMap map) throws SQLException {
		List list = sqlMapClientTemplate.queryForList(map.getListCommand(), map);
		String listData = "";

		if(list.size() > 0){
			StringBuilder sb = new StringBuilder();
			StringMap row = (StringMap)list.get(0);
			sb.append(row.getCol()).append("↑");;
			for(int i=0;i<list.size();i++){
				row = (StringMap)list.get(i);
				if(i != 0){
		        	sb.append("↑");
		        }
		        sb.append(row.getRow());
			}
			
			listData = sb.toString();
		}

		return listData;
	}
	
	public String getJdbcData(DataMap map) throws SQLException {
		SqlUtil sqlUtil = new SqlUtil();
		DataMap sqlData = sqlUtil.getListSql(sqlMapClientTemplate, map);
		Integer fetchSize = null;
		if(map.containsKey("fetchSize")){
			fetchSize = (Integer)map.get("fetchSize");
		}

		String listData = sqlUtil.getJdbcData(dataSource, sqlData.getString("sql"), fetchSize, sqlData.getList("param"));
		return listData;
	}
	
	public String getJdbcData(String sql) throws SQLException {
		SqlUtil sqlUtil = new SqlUtil();
		String listData = sqlUtil.getJdbcData(dataSource, sql, null);

		return listData;
	}
	
	public void loadSql(DataMap map) throws SQLException, IOException{
		String xml = SqlMapLoad.load(dataSource, systemConfig.getDbTypeCode(), map);
		FileUtil fileUtil = new FileUtil();
		fileUtil.writeStringFile(respository.getLang(), "sql.xml", xml);
	}
	
	public void reloadSql() throws Exception{
		sqlMapClientFactoryBean.reload();
	}
	
	public int executeUpdate(String sql) throws SQLException {
		Connection conn = null;
		PreparedStatement psmt = null;
		int count = 0;
		try{
			conn = dataSource.getConnection();
			psmt = conn.prepareStatement(sql);
			count = psmt.executeUpdate(sql);

		}catch(Exception e){
			//log.error("getJdbcData : ", e);
			throw new SQLException(e.getMessage());
		}finally{
			try {
				if(psmt != null){
					psmt.close();
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
			try {
				if(conn != null){
					conn.close();
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return count;
	}
	
	public void viewSqlXml(DataMap map) throws SQLException, IOException{
		StringBuilder sb = new StringBuilder();
		sb.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
		sb.append("<!DOCTYPE sqlMap PUBLIC \"-//ibatis.apache.org//DTD SQL MAP 2.0//EN\" \"http://ibatis.apache.org/dtd/sql-map-2.dtd\">\n");
		sb.append("<sqlMap>\n");
		sb.append("<typeAlias alias=\"DataMap\" type=\"com.common.bean.DataMap\" />\n");
		sb.append("<typeAlias alias=\"StringMap\" type=\"com.common.util.StringMap\" />\n");
		sb.append(map.getString("SQLSTA")).append("\n");
		sb.append("</sqlMap>");
		FileUtil fileUtil = new FileUtil();
		fileUtil.writeStringFile(respository.getLang(), "view.xml", sb.toString());
	}
}