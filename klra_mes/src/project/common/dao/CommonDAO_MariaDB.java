package project.common.dao;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;

import org.apache.ibatis.session.SqlSession;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.EncryptedDocumentException;
import org.apache.poi.openxml4j.exceptions.InvalidFormatException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import project.common.bean.CommonConfig;
import project.common.bean.DataMap;
import project.common.util.FileUtil;
import project.common.util.SqlUtil;


@Repository
public class CommonDAO_MariaDB {	
	
	static final Logger log = LogManager.getLogger(CommonDAO_MariaDB.class.getName());
	
	//DataSource mariaDataSource;
	@Autowired
	@Qualifier("mariaDataSource")
	DataSource mariaDataSource;
	
	@Autowired
	@Qualifier("mariaSqlSession")
	private SqlSession sqlSession;

	public List getList(DataMap map) throws SQLException {
		map.setSqlType(true);
		return sqlSession.selectList(map.getListCommand(), (HashMap)map);
	}
	
	public List getList(String sqlId, DataMap map) throws SQLException {
		log.debug(map);
		map.setSqlType(true);
		String command = sqlId + CommonConfig.COMMAND_LIST_TAIL;
		log.debug(command);
		return sqlSession.selectList(command, (HashMap)map);
	}
	
	public DataMap getMap(DataMap map) throws SQLException {
		map.setSqlType(true);
		return (DataMap)sqlSession.selectOne(map.getMapCommand(), map);
	}
	
	public DataMap getMap(String sqlId, DataMap map) throws SQLException {
		map.setSqlType(true);
		String command = sqlId + CommonConfig.COMMAND_MAP_TAIL;
		log.debug(command);
		return (DataMap)sqlSession.selectOne(command, map);
	}
	
	public Object insert(DataMap map) throws SQLException {
		map.setSqlType(true);
		return sqlSession.insert(map.getInsertCommand(), map);
	}
	
	public Object insert(String sqlId, List list) throws SQLException {
		//map.setSqlType(true);
		String command = sqlId + CommonConfig.COMMAND_INSERT_TAIL;
		log.debug(command);
		return sqlSession.insert(command, list);
	}
	
	public Object insert(String sqlId, DataMap map) throws SQLException {
		map.setSqlType(true);
		String command = sqlId + CommonConfig.COMMAND_INSERT_TAIL;
		log.debug(command);
		return sqlSession.insert(command, map);
	}
	
	public int update(DataMap map) throws SQLException {
		map.setSqlType(true);
		return sqlSession.update(map.getUpdateCommand(), map);
	}
	
	public int update(String sqlId, DataMap map) throws SQLException {
		map.setSqlType(true);
		String command = sqlId + CommonConfig.COMMAND_UPDATE_TAIL;
		log.debug(command);
		return sqlSession.update(command, map);
	}
	
	public String getJdbcData(DataMap map) throws SQLException {
		//map.setSqlType(true);
		SqlUtil sqlUtil = new SqlUtil();
		//String sql = sqlUtil.getListSql(sqlMapClientTemplate, map);
		DataMap pdata = sqlUtil.getListSqlP(sqlSession, map);
		//String listData =  sqlUtil.getJdbcData(mariaDataSource, sql);
		if("PLANT".equals(map.getString("COMMPOPID"))) {
			if(pdata.get("sql")!=null){
				pdata.put("sql", pdata.get("sql")+" AND WAREKY = '" + map.get("SES_WAREKY") + "'");
			}
		}
		String listData =  sqlUtil.getJdbcDataP(mariaDataSource, pdata);
		
		return listData;
	}
	
	public String getJdbcData(String sql) throws SQLException {
		SqlUtil sqlUtil = new SqlUtil();
		String listData = sqlUtil.getJdbcData(mariaDataSource, sql);

		return listData;
	}


}