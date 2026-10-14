package project.mes.dao.work;

import java.sql.SQLException;
import java.util.List;

import javax.sql.DataSource;

import org.apache.ibatis.session.SqlSession;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Repository;

import project.common.bean.DataMap;
import project.mobile.dao.MobileDao;

@Repository
public class ProcResultDAO {
	private static Logger log = Logger.getLogger(MobileDao.class);
	
	@Autowired
	DataSource dataSource;
	
	@Autowired
	@Qualifier("sqlSession")
	private SqlSession sqlSession;
	
	//공정별 실적 조회
	public List<DataMap> selectProcResultList(DataMap map) throws SQLException {
		map.setSqlType(true);
		String procCd = map.getString("PROC_CD").toUpperCase();
		if (procCd == null || procCd.trim().isEmpty()) {
		    throw new IllegalArgumentException("PROC_CD 값이 비어 있습니다.");
		}
		String selectID = "selectProcResultList" + "_" + procCd;
		return sqlSession.selectList(selectID, map);
	}

}
