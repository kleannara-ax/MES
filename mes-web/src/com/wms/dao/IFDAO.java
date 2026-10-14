package com.wms.dao;

import java.sql.SQLException;
import java.util.List;

import javax.sql.DataSource;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.orm.ibatis.SqlMapClientTemplate;
import org.springframework.stereotype.Repository;

import com.common.bean.DataMap;
import com.common.dao.BaseDAO;
import com.common.dao.CommonDAO;
import com.common.bean.DataMap;
import com.common.util.SqlUtil;

@Repository
public class IFDAO  extends BaseDAO {	
	private static Logger log = Logger.getLogger(CommonDAO.class);
	
	@Autowired
	@Qualifier("IFSqlMapClientTemplate")
	SqlMapClientTemplate sqlMapClientTemplate;
	
	@Autowired
	@Qualifier("IFDataSource")
	DataSource dataSource;
	
	
	private SqlMapClientTemplate getSqlMapClient(){
		return sqlMapClientTemplate;
	}
	
	public List getList(DataMap map) throws SQLException {
		return getSqlMapClient().queryForList(map.getListCommand(), map);
	}
	public DataMap getMap(DataMap map) throws SQLException {
		return (DataMap)getSqlMapClient().queryForObject(map.getMapCommand(), map);
	}
	public Object getObj(DataMap map) throws SQLException {
		return getSqlMapClient().queryForObject(map.getObjectCommand(), map);
	}
	public Object insert(DataMap map) throws SQLException {
		return getSqlMapClient().insert(map.getInsertCommand(), map);
	}
	public int insertRsnum(DataMap map) throws SQLException {
		return getSqlMapClient().update(map.getInsertCommand(), map);
	}
	public int update(DataMap map) throws SQLException {
		return getSqlMapClient().update(map.getUpdateCommand(), map);
	}
	public int delete(DataMap map) throws SQLException {
		return getSqlMapClient().delete(map.getDeleteCommand(), map);
	}
	public String getListString(DataMap map) throws SQLException {
		SqlUtil sqlUtil = new SqlUtil();
		DataMap sqlData = sqlUtil.getListSql(sqlMapClientTemplate, map);
		Integer fetchSize = null;
		if(map.containsKey("fetchSize")){
			fetchSize = (Integer)map.get("fetchSize");
		}
		String listData = sqlUtil.getJdbcData(dataSource, sqlData.getString("sql"), fetchSize, sqlData.getList("param"));

		return listData;
	}
}