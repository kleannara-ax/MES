package com.wms.service;

import java.sql.SQLException;
import java.util.List;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.common.bean.CommonConfig;
import com.common.bean.DataMap;
import com.common.dao.CommonDAO;
import com.common.util.DateUtil;

@Service
public class LabelService {

	private static Logger log = Logger.getLogger(LabelService.class);

	
	@Autowired
	public CommonDAO commonDao;
	
	@Transactional
	public DataMap saveLB01(DataMap map) throws SQLException {
		DataMap rsMap = new DataMap();
		int prtCnt = Integer.parseInt(map.getString("PRTCNT"));
		String barcod = "";
		StringBuilder sb = new StringBuilder();
		
		//인쇄수량 값 만큼 채번
		for(int i=0; i<prtCnt; i++){
			map.setModuleCommand("WmsLabel", "LB01PLT");
			barcod = (String)commonDao.getObject(map);
			
			map.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			map.put("BARCOD", barcod);
			map.put("QTDUOM", map.get("QTPUOM"));	//입수량
			map.put("QTDBOX", map.get("BOXQTY"));	//박스 수
			map.put("QTDREM", map.get("QTDREM"));	//잔량
			map.put("QTDPRT", map.get("TOTQTY"));	//총수량
			map.setModuleCommand("WmsLabel", "LB01");
			commonDao.insert(map);
			
			if(i != 0){
				sb.append(",");
			}
			sb.append("'").append(barcod).append("'");
		}
		
		rsMap.put("BARCOD", sb.toString());
		
		return rsMap;
	}
	
	@Transactional
	public DataMap saveLB01PalletIDSingle(DataMap map) throws SQLException {
		DataMap resultMap = new DataMap();
		
		String date = DateUtil.getShortDateString();
		String time = DateUtil.getShortTimeString();
		map.put("DATE", date);
		map.put("TIME", time);
		map.put("USERID", map.get(CommonConfig.SES_USER_ID_KEY));
		
		// 1. SEQ Get
		map.setModuleCommand("WmsLabel", "PRTSEQ");
		DataMap seqMap = commonDao.getMap(map);
		String prtseq = seqMap.getString("PRTSEQ");

		// 2. INSERT INTO PRTLG
		map.put("PRTSEQ", prtseq);
		
		String trnuid = map.getString("TRNUID","");
		if(trnuid == null || trnuid.trim().equals("")) {
			map.setModuleCommand("WmsLabel", "LB01_PALLET_ID_SINGLE_SEQ");
			DataMap trnuidMap = commonDao.getMap(map);
			map.put("TRNUID", trnuidMap.getString("TRNUID"));
		}
		
		map.setModuleCommand("WmsLabel", "LB01_PALLET_ID_SINGLE_PRTLG");
		commonDao.insert(map);
		
		// 3. Return SET
		resultMap.put("PRTSEQ", prtseq);
		
		return resultMap;
	}

	@Transactional
	public int PT01PalletIDPrint(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("head");
		int count = 0;
		
		DataMap row= new DataMap();
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			row.setModuleCommand("WmsLabel", "PT01_PALLET_ID_PRTLG"); //insert
			row.put("PRTSEQ", map.get("PRTSEQ"));
			
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			commonDao.insert(row);
			
			count ++;
		}
		return count;
	}


//	@Transactional
//	public String saveLB01(DataMap map) throws SQLException {
//		//DataMap param = new DataMap();
//		String result = "";
//			//row.append(list.get(i).getMap("map"));			
//			map.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
//			map.setModuleCommand("WmsLabel", "LB01");
//
//			commonDao.insert(map);
//			
//			DataMap temp = new DataMap();
//			
//			temp.setModuleCommand("WmsLabel", "LB01PRINT");
//				
//			List<DataMap> item = commonDao.getList(temp);
//			//log.debug("item : " + item);
//			result = item.get(0).getString("REFDKY");
//			
//			//log.debug("result : " + result);
//		return result;
//	}
}