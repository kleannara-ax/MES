package project.common.dao;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.ArrayList;
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
public class CommonDAO {	
	
	static final Logger log = LogManager.getLogger(CommonDAO.class.getName());
	
	@Autowired
	@Qualifier("dataSource")
	DataSource dataSource;
	
	@Autowired
	@Qualifier("sqlSession")
	private SqlSession sqlSession;

	
	public int getCount(DataMap map) throws SQLException {
		map.setSqlType(true);
		return (Integer)sqlSession.selectOne(map.getCountCommand(), map);
	}
	public int getCount(String sqlId, DataMap map) throws SQLException {
		map.setSqlType(true);
		String command = sqlId + CommonConfig.COMMAND_COUNT_TAIL;
		return (Integer)sqlSession.selectOne(command, map);
	}
	public List getPagingList(DataMap map) throws SQLException {
		map.setSqlType(true);
		return sqlSession.selectList(map.getListCommand(), map);
	}
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
	public Object getObj(DataMap map) throws SQLException {
		map.setSqlType(true);
		return sqlSession.selectOne(map.getObjectCommand(), map);
	}
	public Object getObj(String sqlId, DataMap map) throws SQLException {
		map.setSqlType(true);
		String command = sqlId + CommonConfig.COMMAND_OBJECT_TAIL;
		log.debug(command);
		return sqlSession.selectOne(command, map);
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
	public int listInsert(DataMap map, List<DataMap> list) throws SQLException {
		map.setSqlType(true);
		int count = 0;
		DataMap row = null;
		
		for(int i=0;i<list.size();i++){			
			if(map.containsKey("param")){
				row = new DataMap(map.getMap("param"));
			}else{
				row = new DataMap();
			}
			map.clonModule(row);
			row.append(list.get(i).getMap("map"));			
			insert(row);
			count ++; 
		}
		row.clear();
		return count;
	}
	public int insertRsnum(DataMap map) throws SQLException {
		map.setSqlType(true);
		return sqlSession.update(map.getInsertCommand(), map);
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
	public int listUpdate(DataMap map, List<DataMap> list) throws SQLException {
		map.setSqlType(true);
		int count = 0;
		DataMap row = null;
		
		for(int i=0;i<list.size();i++){			
			if(map.containsKey("param")){
				row = new DataMap(map.getMap("param"));
			}else{
				row = new DataMap();
			}				
			map.clonModule(row);
			row.append(list.get(i).getMap("map"));			
			count += update(row);
		}
		row.clear();
		return count;
	}
	public int delete(DataMap map) throws SQLException {
		map.setSqlType(true);
		return sqlSession.delete(map.getDeleteCommand(), map);
	}
	public int delete(String sqlId, DataMap map) throws SQLException {
		map.setSqlType(true);
		String command = sqlId + CommonConfig.COMMAND_DELETE_TAIL;
		log.debug(command);
		return sqlSession.delete(command, map);
	}
	public int listDelete(DataMap map, List<DataMap> list) throws SQLException {
		map.setSqlType(true);
		int count = 0;
		DataMap row = null;
		
		for(int i=0;i<list.size();i++){			
			if(map.containsKey("param")){
				row = new DataMap(map.getMap("param"));
			}else{
				row = new DataMap();
			}				
			map.clonModule(row);
			row.append(list.get(i).getMap("map"));	
			count += delete(row);
		}
		row.clear();
		return count;
	}
	public Object insertExcel(DataMap param, DataMap map) throws SQLException {
		map.setSqlType(true);
		return sqlSession.insert(param.getInsertCommand(), map);
	}
	public Object getObject(DataMap map) throws SQLException {
		map.setSqlType(true);
		return sqlSession.selectOne(map.getObjectCommand(), map);
	}
	public List getValidation(DataMap map) throws SQLException {
		map.setSqlType(true);
		return sqlSession.selectList(map.getValidationCommand(), map);
	}
	
	public List getExcel(DataMap map) throws IOException, EncryptedDocumentException, InvalidFormatException{
		map.setSqlType(true);
		map.put(CommonConfig.MODULE_ATT_KEY, CommonConfig.FILE_MODULE);
		map.put(CommonConfig.COMMAND_ATT_KEY, CommonConfig.FILE_TABLE_NAME);
		
		DataMap data = (DataMap)sqlSession.selectOne(map.getMapCommand(), map);
		FileUtil fileUtil = new FileUtil();
		File file = fileUtil.getFile(data.getString("PATH"), data.getString("FNAME"));
		String filename = file.getPath();
		
		List list = null;
		// 프론트에서 넘겨받은 rowNUm 다시 변수에 담아서 ...
		int colNameRowNum = 0;
		if(map.containsKey(CommonConfig.DATA_EXCEL_COLNAME_ROWNUM_KEY)){
			colNameRowNum = map.getInt(CommonConfig.DATA_EXCEL_COLNAME_ROWNUM_KEY);
		}

		// menu ID
		String targetTab = map.getString("menuId");

		try {
			if(data.getString("MIME").equals("xls")){
				list = fileUtil.getXlsFile(filename, colNameRowNum, targetTab);
			}else if(data.getString("MIME").equals("xlsx")){
	//			list = fileUtil.getXlsxFile(filename, colNameRowNum);
				list = fileUtil.getXlsxFile(filename, map.getList("cols"), targetTab);
			}
			file.deleteOnExit();
			data.clear();

		} catch (Exception e) {
			System.out.println("❌ [getExcel] 엑셀 파싱 중 에러 발생: " + e.getMessage());
			e.printStackTrace();

			// 💡 에러 발생 시, 정상 데이터 리스트 대신 에러 정보를 담은 DataMap을 List에 심어서 반환합니다.
			DataMap errorMap = new DataMap();
			errorMap.put("isSuccess", "N");
			errorMap.put("ERROR_MSG", e.getMessage()); // getXlsxFile에서 던진 구체적인 메시지가 담김
			if (list == null) { list = new ArrayList(); }
			list.add(errorMap);
		}

		// 파일 제거 및 데이터 클리어 방어 코드 유지
		if (file != null && file.exists()) {
			file.deleteOnExit();
		}

		// data.clear()는 여기서 안전하게 단 한 번만 수행하도록 묶어줍니다.
		if (data != null) {
			data.clear();
		}
		//fileUtil.deleteFile(data.getString("PATH"), data.getString("FNAME"));

		return list;
	}
	
	public List getExcelCollist(DataMap map) throws IOException, EncryptedDocumentException, InvalidFormatException{
		map.setSqlType(true);
		map.put(CommonConfig.MODULE_ATT_KEY, CommonConfig.FILE_MODULE);
		map.put(CommonConfig.COMMAND_ATT_KEY, CommonConfig.FILE_TABLE_NAME);
		
		DataMap data = (DataMap)sqlSession.selectOne(map.getMapCommand(), map);
		FileUtil fileUtil = new FileUtil();
		File file = fileUtil.getFile(data.getString("PATH"), data.getString("FNAME"));
		String filename = file.getPath();
		
		List list = null;
		int colNameRowNum = 0;
		if(map.containsKey(CommonConfig.DATA_EXCEL_COLNAME_ROWNUM_KEY)){
			colNameRowNum = map.getInt(CommonConfig.DATA_EXCEL_COLNAME_ROWNUM_KEY);
		}
		if(data.getString("MIME").equals("xls")){
			list = fileUtil.getXlsFileCollist(filename, colNameRowNum);
		}else if(data.getString("MIME").equals("xlsx")){
			list = fileUtil.getXlsxFileCollist(filename, colNameRowNum);
		}
		
		file.deleteOnExit();
		data.clear();
		return list;
	}
		
	public String getListString(DataMap map) throws SQLException {
		//map.setSqlType(true);
		SqlUtil sqlUtil = new SqlUtil();
		//String sql = sqlUtil.getListSql(sqlMapClientTemplate, map);
		DataMap pdata = sqlUtil.getListSqlP(sqlSession, map);
		//String listData =  sqlUtil.getJdbcData(dataSource, sql);
		String listData =  sqlUtil.getJdbcDataP(dataSource, pdata);
		
		return listData;
	}

	
	public String getTextList(DataMap map) throws SQLException {
		//map.setSqlType(true);
		SqlUtil sqlUtil = new SqlUtil();
		//String sql = sqlUtil.getListSql(sqlMapClientTemplate, map);
		DataMap pdata = sqlUtil.getListSqlP(sqlSession, map);
		//String listData =  sqlUtil.getJdbcData(dataSource, sql);
		String listData =  "END "+sqlUtil.getJdbcDataP(dataSource, pdata);
		
		return listData;
	}
	
	public String getJdbcData(DataMap map) throws SQLException {
		//map.setSqlType(true);
		SqlUtil sqlUtil = new SqlUtil();
		//String sql = sqlUtil.getListSql(sqlMapClientTemplate, map);
		DataMap pdata = sqlUtil.getListSqlP(sqlSession, map);
		//String listData =  sqlUtil.getJdbcData(dataSource, sql);
		if("PLANT".equals(map.getString("COMMPOPID"))) {
			if(pdata.get("sql")!=null){
				pdata.put("sql", pdata.get("sql")+" AND WAREKY = '" + map.get("SES_WAREKY") + "'");
			}
		}
		String listData =  sqlUtil.getJdbcDataP(dataSource, pdata);
		
		return listData;
	}
	
	public String getJdbcData(String sql) throws SQLException {
		SqlUtil sqlUtil = new SqlUtil();
		String listData = sqlUtil.getJdbcData(dataSource, sql);

		return listData;
	}

	/*
	 * public void reloadSql() throws Exception{ //sqlMapClientFactoryBean.reload();
	 * }
	 */
	
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
	
	public String getDocNum(String docuty) throws SQLException {
		/*HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
		
		DataMap requestMap = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
		requestMap.put("DOCUTY", docuty);
		requestMap.setModuleCommand("Common", "DOCSEQ");*/
		DataMap requestMap = new DataMap();
		requestMap.put("DOCUTY", docuty);
		requestMap.setModuleCommand("Common", "DOCSEQ");
		
		return (String)this.getObject(requestMap);
	}
	
	// 2022-06-20(월요일) 안상현, report 위한 service
	public String getPrtSeq() throws SQLException {
		return sqlSession.selectOne("Common.getPrtSeq");
	}
	
	//설비 호기에 따라 AGV로직 NEW or OLD 사용유무(HL 가공호기에 한함)
	public String getAgvNewYn(String machCode) throws SQLException {
		return (String)sqlSession.selectOne("selectAgvNewYn", machCode);
	}
	
	//재고이동후 WMS테이블에 SAP자재문서 UPDATE
	public int updateSDocNo(DataMap map) throws SQLException {
		return (int)sqlSession.update("updateSDocNo", map);
	}
	
/*	@SuppressWarnings("deprecation")
	public Object batchInsert(HttpSession session, DataMap map, List<DataMap> list) throws Exception {
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
					throw new SQLException(e.getMessage());
				}
				return dataCount;
			}
			
		});
	}*/
}