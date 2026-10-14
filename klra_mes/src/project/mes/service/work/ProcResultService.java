package project.mes.service.work;

import java.sql.SQLException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import project.common.bean.DataMap;
import project.mes.dao.work.ProcResultDAO;


@Service
public class ProcResultService {
	
	@Autowired
	private ProcResultDAO procResultDAO;

	//공정별 실적 조회
	public List<DataMap> findProcResultList(DataMap dataMap) throws SQLException{
		List<DataMap> list = procResultDAO.selectProcResultList(dataMap);
		
		return list;
	}
}
