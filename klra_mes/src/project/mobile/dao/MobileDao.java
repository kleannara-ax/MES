package project.mobile.dao;

import java.sql.SQLException;
import java.util.List;

import javax.sql.DataSource;
import javax.xml.crypto.Data;

import org.apache.ibatis.session.SqlSession;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Repository;

import project.common.bean.DataMap;
import project.mobile.dao.*;

@Repository
public class MobileDao {
	private static Logger log = Logger.getLogger(MobileDao.class);
	
	@Autowired
	DataSource dataSource;
	
	@Autowired
	@Qualifier("sqlSession")
	private SqlSession sqlSession;
	
	//개별바코드별 10초내 중복요청 체크
	public int duplicationCheck(DataMap map) throws SQLException {
		map.setSqlType(true);
		return sqlSession.selectOne("duplicationCehck", map);
	}

	//지분검사 실적 조회
	public List<DataMap> selectJumboResultForInspection(DataMap map) throws Exception {
		map.setSqlType(true);
		return sqlSession.selectList("selectJumboResultForInspection", map);
	}

	//검사내역 헤더 저장
	public int updateInspectionHeader(DataMap map) throws Exception {
		map.setSqlType(true);
		return sqlSession.insert("updateInspectionHeader", map);
	}

	//지분검사 실적 저장
	public int insertDustInspectionResult(DataMap map) throws Exception {
		map.setSqlType(true);
		return sqlSession.insert("insertDustInspectionResult", map);
	}

	//지분검사 실적 저장
	public DataMap getInspectionKeyInfo(DataMap map) throws Exception {
		map.setSqlType(true);
		return sqlSession.selectOne("getInspectionKeyInfo", map);
	}

	//지분검사 실적 저장
	public int updateDustInspectionResult(DataMap map) throws Exception {
		map.setSqlType(true);
		return sqlSession.update("updateDustInspectionResult", map);
	}

	//지분검사 검사시간 update
	public int updateDetailMsrmDate(DataMap map) throws Exception {
		map.setSqlType(true);
		return sqlSession.update("updateDetailMsrmDate", map);
	}

	//지분검사 검사시간 update
	public int updateInvMsrmDate(DataMap map) throws Exception {
		map.setSqlType(true);
		return sqlSession.update("updateInvMsrmDate", map);
	}

	//지분검사 검사시간 update
	public int updateDefectMsrmDate(DataMap map) throws Exception {
		map.setSqlType(true);
		return sqlSession.update("updateDefectMsrmDate", map);
	}

}
