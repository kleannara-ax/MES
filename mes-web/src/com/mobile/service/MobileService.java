package com.mobile.service;

import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.reflect.Array;
import java.net.URL;
import java.net.URLConnection;
import java.sql.Connection;
import java.sql.SQLException;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.stream.ImageInputStream;
import javax.imageio.stream.ImageOutputStream;
import javax.mail.Session;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.apache.poi.ss.usermodel.DataFormat;
import org.json.JSONObject;
import org.json.XML;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.orm.ibatis.SqlMapClientTemplate;
import org.springframework.orm.ibatis.support.BlobByteArrayTypeHandler;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import com.common.bean.CommonConfig;
import com.common.bean.DataMap;
import com.common.bean.FileRepository;
import com.common.dao.CommonDAO;
import com.common.util.FileUtil;
import com.ibatis.sqlmap.client.SqlMapSession;
import com.lowagie.text.pdf.codec.Base64;
import com.mysql.jdbc.Blob;
import com.wms.dao.IFDAO;
import com.wms.service.WmsService;

@Service
public class MobileService {

	@Autowired
	public CommonDAO commonDao;
	
	@Autowired
	public IFDAO ifDao;
	
	@Autowired
	public WmsService wmsService;
	
	@Autowired
	private FileRepository respository;
	
	public String getDocSeq(String docType) throws SQLException{
		DataMap map = new DataMap("Common", "DOCUSEQ");
		map.put("DOCUTY", docType);
		
		return (String)commonDao.insert(map);
	}
	
	public String getNumSeq(String numObj) throws SQLException{
		DataMap map = new DataMap("Common", "NROBJ");
		map.put("NUMOBJ", numObj);
		
		return (String)commonDao.insert(map);
	}

	@Transactional
	public int 	updateMIP02Sub(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		
		int count = 0;
		
		DataMap MIP02Sub_INSERT;

		for(int i=0;i<list.size();i++){
			MIP02Sub_INSERT = list.get(i).getMap("map");
			MIP02Sub_INSERT.setModuleCommand("Mobile", "MIP02Sub");				
			MIP02Sub_INSERT.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			MIP02Sub_INSERT.put("LOGSEQ", i+1); 
		
			commonDao.insert(MIP02Sub_INSERT);
			
			count++;
		}
		
		return count;
	}

	@Transactional
	public Object SaveMGR01_whyfail(DataMap map) throws SQLException{
		List<DataMap> list = map.getList("list");
		DataMap row = list.get(0).getMap("map");
		
		String ASNDKY = map.getString("ASNDKY");
		String ASNDIT = map.getString("ASNDIT");
		String SKUKEY = map.getString("SKUKEY");		
		String TMPNUM = row.getString("TMPNUM");
		map.clonSessionData(row);
		
		row.setModuleCommand("Mobile", "RCFAIL");
		commonDao.delete(row);
		
		for(int i=0; i<list.size(); i++){
			row = list.get(i).getMap("map");
			if(row.get("QCITEM").equals("")){
				break;
			}
			row.put("ASNDKY",ASNDKY);
			row.put("ASNDIT",ASNDIT);
			row.put("SKUKEY",SKUKEY);
			row.put("TMPNUM",TMPNUM);
			row.put("CREUSR", map.get(CommonConfig.SES_USER_ID_KEY));
			row.put("LMOUSR", map.get(CommonConfig.SES_USER_ID_KEY));
			row.setModuleCommand("Mobile", "RCFAIL");
			String rowState = row.getString(CommonConfig.GRID_ROW_STATE_ATT);
			switch(rowState.charAt(0)){
				case 'C' :
				case 'R' :
				case 'U' :
					commonDao.insert(row);
					break;
				case 'D':
					commonDao.delete(row);
					break;
			}
		}
		
		DataMap returnMap = new DataMap();
		map.setModuleCommand("Mobile", "EXIST_FAIL");
		List dataList = commonDao.getList(map);
		returnMap.put("data", dataList);
		
		return list;
		
	}

/*	public Object SaveMGR01(DataMap map) throws SQLException{
		DataMap returnMap = new DataMap();
		List<DataMap> list = map.getList("list");
		//String RECVKY = map.getString("RECVKY");
		String RECVKY = getDocSeq("112");
		int itemCount = 0;
		String ANSDKY =" ";
		DataMap row;
		
		for(int i = 0 ; i < list.size() ; i++){
			row = list.get(i).getMap("map");
			row.put("i", i+1 );
			row.put("RECVKY", RECVKY );
			map.clonSessionData(row);
			
			itemCount += 10;
			String snum = String.valueOf(itemCount);
			String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
			row.put("RECVIT", inum);
			
			row.setModuleCommand("Mobile", "MGR01_DETAIL");
			commonDao.insert(row);
		}
	   
		
		row = list.get(0).getMap("map");
		row.setModuleCommand("Mobile", "ASNDH");
		commonDao.update(row);
		
		returnMap.put("RECVKY", RECVKY);
		
		return returnMap;
		
	}*/
	
	@Transactional
	public String SaveMGR01(DataMap map) throws Exception {
		List<DataMap> list = map.getList("list");
		
		String wareky = map.get("WAREKY").toString();
		String doctxt = map.get("DOCTXT").toString();
		
		// VALIDATION - 이고입고일 경우
		if(list.get(0).getMap("map").getString("DOCUTY").equals("111")){
			int cnt = 0;
			
			DataMap item = list.get(0).getMap("map");
			// 상태체크
			item.put("WAREKY", wareky);
			item.put("OWNRKY", CommonConfig.SES_USER_OWNER_KEY);
			item.setModuleCommand("WmsInbound", "GR03VALID2");
			cnt = (Integer) commonDao.getObject(item);
			if(cnt == 0){
				return "OUT_M0175";
			}
			
			// VALIDATION
			item.setModuleCommand("WmsInbound", "GR03VALID");
			cnt = (Integer) commonDao.getObject(item);
			if(cnt == 0){
				return "IN_M0124";
			}
			
		// VALIDATION - 이고입고가 아닌 경우
		} else {
			// Validation
			StringBuffer sb = new StringBuffer();
			for(DataMap item : list){
				if(sb.length() > 0){
					sb.append(" UNION ALL\n ");
				}
				
				sb.append(" SELECT '").append(item.getMap("map").get("SEBELN")).append("' AS SEBELN, ");
				sb.append("        '").append(item.getMap("map").get("SEBELP")).append("' AS SEBELP, ");
				sb.append("        '").append(item.getMap("map").get("DOCUTY")).append("' AS RCPTTY, ");
				sb.append("        '").append(wareky).append("' AS WAREKY, ");
				sb.append("        '").append("IMV").append("' AS OWNRKY, ");
				sb.append("        '").append(item.getMap("map").get("DPTNKY")).append("' AS DPTNKY, ");
				sb.append("        '").append(item.getMap("map").get("LOCAKY")).append("' AS LOCAKY, ");
				sb.append("        '").append(item.getMap("map").get("SKUKEY")).append("' AS SKUKEY, ");
				sb.append("         ").append(item.getMap("map").get("QTYRCV")).append("  AS QTYRCV, ");
				sb.append("        '").append(item.getMap("map").get("UOMKEY")).append("' AS UOMKEY FROM DUAL ");
			}
			
			map.setModuleCommand("WmsInbound", "GOODS_RECEIPT"); // 쿼리키값 넣을것
			map.put("APPEND_QUERY", sb.toString());
			map.put("RCPTTY", list.get(0).getMap("map").get("DOCUTY"));
			List<DataMap> validList = commonDao.getValidation(map);
			if(validList.size() > 0){
				DataMap valid = validList.get(0);
				return valid.getString("RESULTMSG");
			}
		}
		
		String docNum = wmsService.getDocSeq("100");
		
		DataMap row;
		row  = list.get(0).getMap("map");
		row.put("RECVKY", docNum);
		row.put("RCPTTY", row.get("DOCUTY"));
		row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		row.put("OWNRKY", map.get(CommonConfig.SES_USER_OWNER_KEY));
		row.put("WAREKY", map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
		row.put("DOCTXT", doctxt);
		commonDao.insert("WmsInbound.GR01", row);
		
		
		int itemCount = 0;
		for(int i=0;i<list.size();i++){
			row  = list.get(i).getMap("map");
			
			itemCount += 10;
			String snum = String.valueOf(itemCount);
			String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
			
			row.put("RECVKY", docNum);
			row.put("RECVIT", inum);
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put("OWNRKY", map.get(CommonConfig.SES_USER_OWNER_KEY));
			row.put("WAREKY", map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
			row.put("LOTA12", row.get("DOCDAT"));
			row.put("MEASKY", ("IMV"+row.get("SKUKEY")));
			
			commonDao.insert("WmsInbound.GR01Sub", row);
			
			// 이고입고일 경우
			if(row.getString("DOCUTY").equals("111")){
				
				row.put("SMJAHR", "111");
				row.setModuleCommand("WmsInbound", "GR03SHPDI");
				
				commonDao.update(row);
			}
		}
		commonDao.getMap("WmsInbound.GR01PROCALL", row);
		
		return docNum;
	}
	
	@Transactional(rollbackFor=Exception.class)
	public int saveMMV01(DataMap map) throws SQLException, Exception {
		//DataMap rsMap = new DataMap();
		List<DataMap> chkList = map.getList("chkList");
		String TASKKY = getDocSeq("320");
		int itemCount = 0;	
		int mix = 0;

		DataMap row;

		for (int i = 0; i < chkList.size(); i++) {	//체크한 리스트
			DataMap chk = new DataMap();
			
			String locatg =  chkList.get(i).getMap("map").getString("LOCATG");
			String skukey =  chkList.get(i).getMap("map").getString("SKUKEY");
			
			chk.put("LOCAKY", locatg);
			chk.put("SKUKEY", skukey);
			
			chk.setModuleCommand("Mobile", "LOCMA");
			int cnt = (Integer) commonDao.getObject(chk);
			
			if(cnt > 0){	//지번이 존재
				chk.setModuleCommand("Mobile", "MIXCHECK");		
				DataMap mixMap = commonDao.getMap(chk); 
				
				//제품 상품혼적, lot혼적여부
				if(mixMap.getString("MIXSKU").equals(" ")){
					//상품혼적이 ' '
					//로케이션 상품이 count > 0 쓸수 없는지번
					chk.setModuleCommand("Mobile", "SKUMIXCHECK");		
					int skumix = (Integer) commonDao.getObject(chk);
					if(skumix >0){
						throw new Exception("상품 [ "+skukey+" ]의 지번 [ "+ locatg+" ]은 상품 혼적을 할 수 없습니다.");
					}
				}
		
				//lot혼적여부 ' '
				//같은 상품끼리도 lot 다를 수 있음.
				if(mixMap.getString("MIXLOT").equals(" ")){
					chk.setModuleCommand("Mobile", "LOTMIXCHECK");		
					int lotmix = (Integer) commonDao.getObject(chk);
					if(lotmix >0){
						throw new Exception("상품 [ "+skukey+" ]의 지번 [ "+ locatg+" ]은 LOT 혼적을 할 수 없습니다.");
					}
				}
			}else{
				throw new Exception("상품 [ "+skukey+" ]의 TO 지번 [ "+locatg+" ]이 존재하지 않습니다.");
			}
			row = chkList.get(i).getMap("map");
			row.put("i", i+1 ); 
			row.put("TASKKY", TASKKY );
			itemCount += 10;
			String snum = String.valueOf(itemCount);
			String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
			row.put("TASKIT", inum);	
			
			row.setModuleCommand("Mobile", "MMV01");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put("LOGSEQ", (i+1));
			
			commonDao.insert(row);
		}
		
		return mix;
	}

	@Transactional(rollbackFor=SQLException.class)
	public int saveMGR09(DataMap map) throws SQLException {
//		DataMap rsMap = new DataMap();
		List<DataMap> chkList = map.getList("chkList");
		String TASKKY = getDocSeq("310");		
		int itemCount = 0;	
		
		//List docNumList = new ArrayList();
		
		int count = 0;
		
		//int locatg = 1;
		
		DataMap row;
		
		for (int i = 0; i < chkList.size(); i++) {
			DataMap chk = new DataMap();
			
			String locatg = chkList.get(i).getMap("map").getString("LOCATG");
			String skukey = chkList.get(i).getMap("map").getString("SKUKEY");
			
			chk.put("LOCAKY", locatg);
			chk.put("SKUKEY", skukey);
			
			chk.setModuleCommand("Mobile", "LOCMA");
			int cnt = (Integer) commonDao.getObject(chk);
			
			if(cnt > 0){	//지번이 존재
				chk.setModuleCommand("Mobile", "MIXCHECK");		
				DataMap mixMap = commonDao.getMap(chk);
				
				//제품 상품혼적, lot혼적여부
				if(mixMap.getString("MIXSKU").equals(" ")){
					//상품혼적이 ' '
					//로케이션 상품이 count > 0 쓸수 없는지번
					chk.setModuleCommand("Mobile", "SKUMIXCHECK");		
					int skumix = (Integer) commonDao.getObject(chk);
					if(skumix >0){
						throw new SQLException("상품 [ "+skukey+" ]의 지번 [ "+ locatg+" ]은 상품 혼적을 할 수 없습니다.");
					}
				}
		
				//lot혼적여부 ' '
				//같은 상품끼리도 lot 다를 수 있음.
				if(mixMap.getString("MIXLOT").equals(" ")){
					chk.setModuleCommand("Mobile", "LOTMIXCHECK");		
					int lotmix = (Integer) commonDao.getObject(chk);
					if(lotmix >0){
						throw new SQLException("상품 [ "+skukey+" ]의 지번 [ "+ locatg+" ]은 LOT 혼적을 할 수 없습니다.");
					}
				}
			}else{
				throw new SQLException("상품 [ "+skukey+" ]의 TO 지번 [ "+locatg+" ]이 존재하지 않습니다.");
			}
			
			row = chkList.get(i).getMap("map");
			
			row.put("i", i+1 );
			row.put("TASKKY", TASKKY );
			itemCount += 10;
			String snum = String.valueOf(itemCount);
			String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
			row.put("TASKIT", inum);
			
			row.setModuleCommand("Mobile", "MGR09");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put("LOGSEQ", (i+1));
			
			commonDao.insert(row);
			
			//count++;
		}
		
//		return rsMap;
		return count;
	}
	
	@Transactional
	public int saveMDL07(DataMap map) throws SQLException {
		List<DataMap> chkList = map.getList("chkList");
		List<DataMap> itemList = null;
		int count = 0;
		DataMap row;
		DataMap itemRow;
		
		for (int i = 0; i < chkList.size(); i++) { 
			row = chkList.get(i).getMap("map");

			row.setModuleCommand("Mobile", "MDL07RE");

			itemList = commonDao.getList(row);
			
			for(int j=0; j<itemList.size();j++){
				itemRow = new DataMap(itemList.get(j));
				itemRow.setModuleCommand("Mobile", "MDL06");
				itemRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				itemRow.put("LOGSEQ", (1000*i)+(j));				
				commonDao.insert(itemRow);
				count++;	
			}
		}
		
		
		
		return count;
	}


	public Object SaveMGR06(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		String RECVKY = getDocSeq("108");
		int itemCount = 0;
		int count = 0;
		DataMap row;
		
		
		for (int i = 0; i < list.size(); i++) {
			row = list.get(i).getMap("map");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put("LOGSEQ", (i+1));
			row.put("RECVKY", RECVKY );
			map.clonSessionData(row);
			
			itemCount += 10;
			String snum = String.valueOf(itemCount);
			String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
		
			row.put("RECVIT", inum );

			row.setModuleCommand("Mobile", "MGR06DETAIL");
			commonDao.insert(row);
			
			count++;
		
			
		}
		DataMap rsMap = new DataMap();
		
		rsMap.put("RECVKY", RECVKY);
		
		return rsMap;
	}

	
	@Transactional(rollbackFor=SQLException.class)
	public int SaveMGR20(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
	//	List col = map.getList("col");
	//	System.out.println("@@@@@@" + col);
		
		String RECVKY = getDocSeq("108");
		int itemCount = 0;
		int count = 0;
		DataMap row;
		
		for (int i = 0; i < list.size(); i++) {
			DataMap chk = new DataMap();
			
			String locatg = list.get(i).getMap("map").getString("LOCAKY");
			String skukey = list.get(i).getMap("map").getString("SKUKEY");
			
			
			chk.put("LOCAKY", locatg);
			chk.put("SKUKEY", skukey);
			
			chk.setModuleCommand("Mobile", "LOCMA");
			int cnt = (Integer) commonDao.getObject(chk);
			
			if(cnt > 0){	//지번이 존재
				chk.setModuleCommand("Mobile", "MIXCHECK");		
				DataMap mixMap = commonDao.getMap(chk);
				
				//제품 상품혼적, lot혼적여부
				if(mixMap.getString("MIXSKU").equals(" ")){
					//상품혼적이 ' '
					//로케이션 상품이 count > 0 쓸수 없는지번
					chk.setModuleCommand("Mobile", "SKUMIXCHECK");		
					int skumix = (Integer) commonDao.getObject(chk);
					if(skumix >0){
						throw new SQLException("상품 [ "+skukey+" ]의 지번 [ "+ locatg+" ]은 상품 혼적을 할 수 없습니다.");
					}
				}
		
				//lot혼적여부 ' '
				//같은 상품끼리도 lot 다를 수 있음.
				if(mixMap.getString("MIXLOT").equals(" ")){
					chk.setModuleCommand("Mobile", "LOTMIXCHECK");		
					int lotmix = (Integer) commonDao.getObject(chk);
					if(lotmix >0){
						throw new SQLException("상품 [ "+skukey+" ]의 지번 [ "+ locatg+" ]은 LOT 혼적을 할 수 없습니다.");
					}
				}
			}else{
				throw new SQLException("상품 [ "+skukey+" ]의 TO 지번 [ "+locatg+" ]이 존재하지 않습니다.");
			}
			
			
			row = list.get(i).getMap("map");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put("LOGSEQ", (i+1));
			row.put("RECVKY", RECVKY );
			
			itemCount += 10;
			String snum = String.valueOf(itemCount);
			String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
		
			row.put("RECVIT", inum );

			row.setModuleCommand("Mobile", "MGR20DETAIL");
			commonDao.insert(row);
			
			count++;
		}
		System.out.println("count:" + count);
		
		return count;
	}
	
	/*@Transactional
	public int SaveMDL06(DataMap map) throws SQLException {
		List<DataMap> chkList = map.getList("chkList");
		int count =0;
		DataMap row;
		
		for (int i = 0; i < chkList.size(); i++) {
			row = chkList.get(i).getMap("map");
			row.setModuleCommand("Mobile", "MDL06");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put("LOGSEQ", (i+1));
			
			commonDao.insert(row);
			count++;
			
		}
		
		return count;
	}*/
	
	@Transactional
	public int SaveMDL06(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		String dotype = map.get("DOTYPE").toString();
		String doorky = map.get("DOORKY").toString();
		DataMap row;
		int count = 0;
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.putAll(row);
			
			if(dotype.equals("1")){
				// update
				row.setModuleCommand("Mobile", "MDL06");
				row.put("DOORKY", doorky);
				commonDao.update(row);
			}
			
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			commonDao.getMap("Mobile.MDL06PROCALL", row);
			count ++;
		}
		return count;
	}
	
	@Transactional
	public int SaveMTO07(DataMap map) throws SQLException {
		List<DataMap> chkList = map.getList("chkList");
		int count = 0;
		
		DataMap row;
		
		for (int i = 0; i < chkList.size(); i++) {
			row = chkList.get(i).getMap("map");
			row.setModuleCommand("Mobile", "MTO07");
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put("LOGSEQ", (i+1));
			
			commonDao.insert(row);
			count++;
		}
		
		return count;
	}
	
	@Transactional
	public int LocakyCheck(DataMap map) throws SQLException {	
		String locaky = map.getString("LOCAKY");
		
		int mix = 0;
		int flag = 0;
		
		map.setModuleCommand("Mobile", "LOCMA");
		int cnt = (Integer) commonDao.getObject(map);
		
		if(cnt > 0){	//지번이 존재
			map.setModuleCommand("Mobile", "MIXCHECK");		
			DataMap mixMap = commonDao.getMap(map);
			//재품 상품혼적, lot혼적여부
			if(mixMap.getString("MIXSKU").equals(" ")){
				//상품혼적이 ' '
				//로케이션 상품이 count > 0 쓸수 없는지번
				map.setModuleCommand("Mobile", "SKUMIXCHECK");		
				int skumix = (Integer) commonDao.getObject(map);
				if(skumix >0){
					mix =-1;
					flag = 1;
				}
			}
	
			//lot혼적여부 ' '
			// 상품끼리도 lot 
			if(mixMap.getString("MIXLOT").equals(" ")){
				map.setModuleCommand("Mobile", "LOTMIXCHECK");		
				int lotmix = (Integer) commonDao.getObject(map);
				if(lotmix >0){
					mix =-2;
					flag = 1;
				}
			}
			
			if(flag == 0){	//지번 존재, 혼적 여부 모두 체크 안되어있음.
				mix = 1;
			}
		
		}
		
		return mix;
		
	}
	

	public String validateMobileDailyCheck(DataMap map) throws SQLException {
		String result = "OK";
		List<DataMap> list = map.getList("chkList");
		DataMap row;
		for(int i=0; i<list.size(); i++){
			row = list.get(i).getMap("map");
			String PRODDT = row.get("PRODDT").toString();  //입고일자
			String PRCPTD = row.get("PRCPTD").toString();  //임가공작업지시일자
			
				/*Date proddt = DateFormat.getDateInstance().parse(PRODDT);
				Date prcptd = DateFormat.getDateInstance().parse(PRCPTD);
				
				if(proddt.before(prcptd)){
					return "IN_M0134";
				}*/
				
				if(PRODDT.compareTo(PRCPTD) < 0){
					return "IN_M0134";
				}
				
			
					
		}

		// 마감처리 여부 체크
		map.put("ISMAT", "0");
		map.setModuleCommand("IF", "CLOSEDATETODAY");
		DataMap closeMap = ifDao.getMap(map);
		if(closeMap != null && closeMap.containsKey("CLOSINGDATE") ){
			return "OUT_M0166";
		}
		
		return result;
	}

	@Transactional
	public Object SaveMGR06_whyfail(DataMap map) throws SQLException{
		List<DataMap> list = map.getList("list");
		DataMap row = list.get(0).getMap("map");
		
		String SEBELN = map.getString("SEBELN");
		String SEBELP = map.getString("SEBELP");
		String SKUKEY = map.getString("SKUKEY");		
		String TMPNUM = row.getString("TMPNUM");
		
		row.setModuleCommand("Mobile", "SHFAIL");
		commonDao.delete(row);
		
		for(int i=0; i<list.size(); i++){
			row = list.get(i).getMap("map");
			if(row.get("QCITEM").equals("")){
				break;
			}
			row.put("SEBELN",SEBELN);
			row.put("SEBELP",SEBELP);
			row.put("SKUKEY",SKUKEY);
			row.put("TMPNUM",TMPNUM);
			row.put("CREUSR", map.get(CommonConfig.SES_USER_ID_KEY));
			row.put("LMOUSR", map.get(CommonConfig.SES_USER_ID_KEY));
			row.setModuleCommand("Mobile", "SHFAIL");
			String rowState = row.getString(CommonConfig.GRID_ROW_STATE_ATT);
			switch(rowState.charAt(0)){
				case 'C' :
				case 'R' :
				case 'U' :
					commonDao.insert(row);
					break;
				case 'D':
					commonDao.delete(row);
					break;
			}
		}
		
		DataMap returnMap = new DataMap();
		map.setModuleCommand("Mobile", "EXIST_RTNFAIL");
		List dataList = commonDao.getList(map);
		returnMap.put("data", dataList);
		
		return list;
		
	}

	
	@Transactional
	public Object checkLota05(DataMap map) throws SQLException{
		String LOTA05 = map.getString("LOTA05");
		map.setModuleCommand("Mobile", "FINDSKUKEY");
		DataMap dataList = commonDao.getMap(map);
		
		/*char type = LOTA05.charAt(0);
		map.setModuleCommand("Mobile", "FINDQTY");
		map.put("TYPE", type);
		map.put("SKUKEY",dataList.getString("SKUKEY") );*/
		DataMap returnMap = new DataMap();
		returnMap.put("SKUKEY", dataList.getString("SKUKEY"));
		return returnMap;
	}

	@Transactional
	public Object usrname(DataMap map) throws SQLException {
		
		map.setModuleCommand("Mobile", "FINDUSRNAME");
		map.put("USRID", map.get(CommonConfig.SES_USER_ID_KEY));
		DataMap returnMap = commonDao.getMap(map);
		returnMap.put("WAREKY", map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
		
		return returnMap;
	}
	
	@Transactional
	public int SaveMDL20(DataMap map) throws SQLException {
		int count = 0;
		List<DataMap> list = map.getList("CHKLIST");
		String boxno = map.getString("BOXNO");
		String ptnrky = map.getString("PTNRKY");
		int boxqty = map.getInt("BOXQTY");
		
		DataMap row = null;
		if(boxqty > 1){
			
			for(int i = 0 ; i < boxqty ; i ++){		
				//map.clonSessionData(row);
				
				DataMap boxNoMap = new DataMap();
				map.setModuleCommand("Mobile", "BOXNUMSEQ");
				List dataList = commonDao.getList(map);
				String boxSeq = dataList.get(0).toString().substring(8,22);
				
				
				for(int j = 0 ; j < list.size() ; j ++){
					row = list.get(j).getMap("map");
					map.clonSessionData(row);
					row.put("PTNRKY", ptnrky);
					if(i == 0){
						row.put("BOXNO", boxno);
					}else{
						row.put("BOXNO", boxSeq);
					}
					row.setModuleCommand("Mobile", "MDL20");
					count += commonDao.update(row);		
					
				}
			}
		}else if(boxqty == 1){
			for(int i = 0 ; i < list.size() ; i++){
				row = list.get(i).getMap("map");		
				map.clonSessionData(row);
				row.put("BOXNO", boxno);
				row.put("PTNRKY", ptnrky);
				
				row.setModuleCommand("Mobile", "MDL20");
				count += commonDao.update(row);
			}
		}
			return count;
	}
	
	public int SaveRegino(DataMap map) throws SQLException {
		int count = 0;
		String regino = map.getString("REGINO");

		map.setModuleCommand("Mobile", "MDL30");
		count += commonDao.update(map);
		return count;
	}
	
	public int SaveRtnRegino(DataMap map) throws SQLException {
		int count = 0;
		URL 			url 		= null;
		URLConnection   connection  = null;         
		BufferedReader  br          = null;         
		StringBuffer    sb          = null;         
		JSONObject      jsonObj     = null; 
		String			regkey		= "d8154e25a43947ffc1464239932977";
		String			urlStr		= "http://biz.epost.go.kr/KpostPortal/openapi";
		String 			regino 		= map.getString("REGINO");
		String			result    = "";
		String			result2   = "";
		String			postReg[] = {"607623"};//우체국 송장 유형 변경시 추가 요망 송장번호 앞 6자리 슈피겐코리아 고유번호
		String          chkSndr   = "sendnm";
		String			chkCust   = "recevnm";
		//http://groovysunday.tistory.com/137 블로그 참조
		
		try 
		{             
			url = new URL( urlStr+"?regkey="+regkey+"&target=trace&query="+regino );                  
		} catch (Exception e) {             
				System.out.println("[ERROR] URL set Failed");             
				e.printStackTrace();             
				return 0;        
		}                   
		try {            
			connection = url.openConnection();      
		} catch (Exception e) {             
			System.out.println("[ERROR] Connection open Failed");             
			e.printStackTrace();             
			return 0;        
		} 
		
		  try {             
			  //BufferedReader에  받은 데이터를 넣어줌            
			  br = new BufferedReader(new InputStreamReader(connection.getInputStream(), "UTF-8"));                             
			  // BufferedReader 내 데이터 StringBuffer sb 에 저장            
			  sb = new StringBuffer();             
			  String buf = "";             
			  while ((buf = br.readLine()) != null) {                 
				  sb.append(buf);             
			  }                           
			  // XML 데이터를 JSONObject로 변환             
			  jsonObj = XML.toJSONObject(sb.toString());  
			  //System.out.println("------------------::"+regino.substring(0, 6));
			  for(int i=0;i<postReg.length;i++){
				  if(regino.substring(0, 6).equalsIgnoreCase(postReg[i])){
					  chkSndr   = "recevnm";
					  chkCust   = "sendnm";
				  }
			  }
			  
			  result  = jsonObj.getJSONObject("trace").getString(chkSndr); //고객명
			  result2 = jsonObj.getJSONObject("trace").getString(chkCust); //매출처
		  }catch (Exception e) {             
			  System.out.println("[ERROR] XML Data(From 우체국) get Data Failed");   
		       
		  }finally{             
			  if (br  != null){    
				  try{ 
					  br.close();    
				  } catch(Exception e) { 
					  e.printStackTrace(); 
			      }         
			  }
		  }
		map.put("SNDRNM", result);
		map.put("CUSTNM", result2);
		if(!result2.isEmpty()){
			//매출처명 누적정보 merge
			map.setModuleCommand("Mobile", "MDL40CUST");
			count += commonDao.update(map);
		}
		//송장정보 저장
		map.setModuleCommand("Mobile", "MDL40");
		count += commonDao.update(map);
		return count;
	}
	
	@Transactional
	public String SaveMGR02(DataMap map) throws Exception {
		List<DataMap> list = map.getList("list");
		String wareky = map.getString("WAREKY");
		// Validation
		StringBuffer sb = new StringBuffer();
		for(DataMap item : list){
			if(sb.length() > 0)
				sb.append(" UNION ALL\n ");
			
			sb.append(" SELECT '").append(item.getMap("map").get("SEBELN")).append("' AS SEBELN, ");
			sb.append("        '").append(item.getMap("map").get("SEBELP")).append("' AS SEBELP, ");
			sb.append("        '").append(item.getMap("map").get("DOCUTY")).append("' AS RCPTTY, ");
			sb.append("        '").append(wareky).append("' AS WAREKY, ");
			sb.append("        '").append("IMV").append("' AS OWNRKY, ");
			sb.append("        '").append(item.getMap("map").get("DPTNKY")).append("' AS DPTNKY, ");
			sb.append("        '").append(item.getMap("map").get("LOCAKY")).append("' AS LOCAKY, ");
			sb.append("        '").append(item.getMap("map").get("SKUKEY")).append("' AS SKUKEY, ");
			sb.append("         ").append(item.getMap("map").get("QTYRCV")).append("  AS QTYRCV, ");
			sb.append("        '").append(item.getMap("map").get("UOMKEY")).append("' AS UOMKEY FROM DUAL ");
		}
		
		map.setModuleCommand("WmsInbound", "GOODS_RECEIPT"); // 쿼리키값 넣을것
		map.put("APPEND_QUERY", sb.toString());
		map.put("RCPTTY", list.get(0).getMap("map").get("DOCUTY"));
		List<DataMap> validList = commonDao.getValidation(map);
		if(validList.size() > 0){
			DataMap valid = validList.get(0);
			return valid.getString("RESULTMSG");
		}
		
		String docNum = wmsService.getDocSeq("100");
		
		DataMap row;
		row  = list.get(0).getMap("map");
		row.put("RECVKY", docNum);
		row.put("RCPTTY", row.get("DOCUTY"));
		row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
		row.put("WAREKY", map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
		commonDao.insert("WmsInbound.GR01", row);
		
		
		int itemCount = 0;
		for(int i=0;i<list.size();i++){
			row  = list.get(i).getMap("map");
			
			itemCount += 10;
			String snum = String.valueOf(itemCount);
			String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
			
			row.put("RECVKY", docNum);
			row.put("RECVIT", inum);
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			row.put("WAREKY", map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
			row.put("RCPTTY", row.get("DOCUTY"));
			row.put("LOTA12", row.get("DOCDAT"));
			row.put("MEASKY", ("IMV"+row.get("SKUKEY")));
			
			commonDao.insert("WmsInbound.GR01Sub", row);
		}
		commonDao.getMap("WmsInbound.GR01PROCALL", row);
		
		return docNum;
	}
	
	@Transactional(rollbackFor=Exception.class)
	public String SaveMPT01(DataMap map) throws Exception {
		List<DataMap> list = map.getList("list");
		
		// Validation
		StringBuffer sb = new StringBuffer();
		for(DataMap item : list){
			if(sb.length() > 0)
				sb.append(" UNION ALL\n ");
			
			sb.append(" SELECT '").append(item.getMap("map").get("STOKKY")).append("' AS STOKKY FROM DUAL ");
		}
		
		map.setModuleCommand("Mobile", "STOKKY"); // 쿼리키값 넣을것
		map.put("APPEND_QUERY", sb.toString());
		List<DataMap> validList = commonDao.getValidation(map);
		if(validList.size() > 0){
			DataMap valid = validList.get(0);
			return valid.getString("RESULTMSG");
		}
		
		DataMap row;
		String docdat = map.get("DOCDAT").toString().replace(".", "");
		String locaky = map.get("LOCAKY").toString();
		
		for(int i=0;i<list.size();i++){
			row  = list.get(i).getMap("map");
			
			row.put("LOCAKY", locaky);
			row.put("DOCDAT", docdat);
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			row.put("WAREKY", map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
		
			commonDao.getMap("Mobile.PT01PROCALL", row);
		}
		
		return "OK";
	}
	
	@Transactional(rollbackFor=Exception.class)
	public String SaveMPT02(DataMap map) throws Exception {
		List<DataMap> list = map.getList("list");
		
		// Validation
		StringBuffer sb = new StringBuffer();
		for(DataMap item : list){
			if(sb.length() > 0)
				sb.append(" UNION ALL\n ");
				sb.append(" SELECT '").append(item.getMap("map").get("TASKKY")).append("' AS TASKKY, ");
				sb.append("        '").append(item.getMap("map").get("TASKIT")).append("' AS TASKIT FROM DUAL ");
		}
		
		map.setModuleCommand("Mobile", "TASKIT"); // 쿼리키값 넣을것
		map.put("APPEND_QUERY", sb.toString());
		List<DataMap> validList = commonDao.getValidation(map);
		if(validList.size() > 0){
			DataMap valid = validList.get(0);
			return valid.getString("RESULTMSG");
		}
		
		DataMap row;
		
		for(int i=0;i<list.size();i++){
			row  = list.get(i).getMap("map");
			
			if(!map.get("LOCAKY").equals("")){
				row.put("LOCAAC", map.get("LOCAKY"));
			}
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			row.put("WAREKY", map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
		
			commonDao.getMap("Mobile.PT02PROCALL", row);
		}
		
		return "OK";
	}
	
	@Transactional(rollbackFor=Exception.class)
	public int SaveMIP02(DataMap map) throws Exception {
		List<DataMap> list = map.getList("list");
		DataMap row;
		int count = 0;
		
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");

			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put(CommonConfig.SES_USER_OWNER_KEY, map.get(CommonConfig.SES_USER_OWNER_KEY));
			row.put("WAREKY", map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
		
			commonDao.update("Mobile.MIP02", row);
			count ++;
		}
		
		return count;
	}
	
	@Transactional
	public int SaveMDL08(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		String vehino = map.get("VEHINO").toString();
		DataMap row;
		int count = 0;
		String shpoky = "";
		String shpoky2 = shpoky;
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			map.putAll(row);
			
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put("VEHINO", vehino);
			commonDao.update("Mobile.DL08SHPDI", row);
			count ++;
		}
		
		for(int j=0;j<list.size();j ++){
			row = list.get(j).getMap("map");
			shpoky = row.getString("SHPOKY");
			if(!shpoky.equals(shpoky2)){
				shpoky2 = shpoky;
				commonDao.update("Mobile.DL08SHPDH", row);
				commonDao.getMap("Mobile.MDL08PROCALL", row);
			}
		}
		
		
		return count;
	}
	
	@Transactional
	public int SaveMIP04(DataMap map) throws SQLException {
		List<DataMap> list = map.getList("list");
		String dacdat = map.get("DOCDAT").toString().replace(".", "");
		String doctxt = map.get("DOCTXT").toString();
		String phyiky = map.get("PHYIKY").toString();
		
		int count = 0;
		
		DataMap row = new DataMap();
		row.setModuleCommand("WmsInventory", "PHYDH");
		row.put("PHYIKY", phyiky);
		row.put("DOCCAT", 500);
		row.put("PHSCTY", 515);
		row.put("DOCDAT", dacdat);
		row.put("DOCTXT", doctxt);
		row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
		row.put("WAREKY", map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
		
		count += commonDao.update(row);
		
		for(int i=0;i<list.size();i++){
		    row = list.get(i).getMap("map");
			row.setModuleCommand("WmsInventory", "PHYDI");
			
			row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			row.put("OWNRKY", map.get(CommonConfig.SES_USER_OWNER_KEY));
			row.put("PHYIKY", phyiky);
			
			String snum = String.valueOf((i+1)*100);
			String inum = String.valueOf("000000").substring(0,(6-snum.length()))+snum;
			
			row.put("PHYIIT", inum);
			
			count += commonDao.update(row);
		}
		
		return count;
	}

	@Transactional
	public String validateMobileShpokyCheck(DataMap map) throws SQLException {
		String result = "";
		String doorky = map.getString("DOORKY");
		
		if(!doorky.equals("")){
			map.setModuleCommand("Mobile", "MDL06_SHPOKY");
			DataMap rsMap = commonDao.getMap(map);
			result = rsMap.getString("VALCHK");
		}
		
		return result;
	}
	
	@Transactional
	public String saveMIM01(HttpServletRequest request, DataMap map) throws SQLException, IOException {
		String result = "SAVE";
		
		MultipartHttpServletRequest fileRequest = (MultipartHttpServletRequest) request;
		
		FileUtil fileUtil = new FileUtil();
		
		Iterator it = fileRequest.getFileNames();
		Map param   = fileRequest.getParameterMap();
		
		String[] skukey = (String[]) param.get("SKUKEY");
		
		int num = 0;
		DataMap fileParam;
		while(it.hasNext()){
			
			// file input name
			String inputName = it.next().toString();
			
			// 파일객체 생성
			MultipartFile file = fileRequest.getFile(inputName);
			if(file.isEmpty()) {
				continue;
			}
			
			fileParam = new DataMap();
			fileParam.put("SKUKEY", skukey[0]);
			
			String fileOrgName = file.getOriginalFilename();
			String exteName = fileOrgName.substring(fileOrgName.lastIndexOf(".") + 1).toLowerCase();
			String fileSize = String.valueOf(file.getSize());
	        
			/**
			 * 1. 첨부파일 서버에 저장 (원본 이미지 파일)
			 */
			// 파일경로 지정 => E:\wmsSource\ upload\F038\WMS\
			String filePath = respository.getRoot() + "upload/F038/WMS";
			
			// 파일 서버에 저장
	        file.transferTo(fileUtil.getFile(filePath, fileOrgName));
	        
	        /**
	         * 2. 첨부테이블ID 찾기
	         */
	        fileParam.put("P_CODE", skukey[0]);
	        fileParam.put("P_DIV",  "ITEM");
	        
	        // attach header id 얻기
	        fileParam.setModuleCommand("Mobile", "ATTACH_HEADER_ID");
	        String docAttachHId = (String) commonDao.getObject(fileParam);
	        
	        if(docAttachHId.equals("E")){
	        	throw new SQLException("ATTACH HEADER ID를 얻을 수 없습니다. 관리자에게 문의하시기 바랍니다.");
	        }
	        
	        // attach id 얻기
	        fileParam.setModuleCommand("Mobile", "ATTACH_ID");
	        String docAttachId = (String) commonDao.getObject(fileParam);
	        
	        if(docAttachId.equals("E")){
	        	throw new SQLException("ATTACH ID를 얻을 수 없습니다. 관리자에게 문의하시기 바랍니다.");
	        }
	        
	        // 메인품목이라면 서브품목코드 가져오기
	        fileParam.setModuleCommand("Mobile", "SUBSKUKEY");
			List<DataMap> subSkuList = commonDao.getList(fileParam);
	        
	        /**
	         * 3. 파일 생성 및 첨부테이블(S_DOC_ATTACH_HEADER, S_DOC_ATTACH)에 데이터 등록 
	         */
			// 경로 : E:\wmsSource\item_image\WMS\ + 년일6자리(ex:160825)
			Date today = new Date();
			SimpleDateFormat sdf = new SimpleDateFormat("yyMMdd");
			String docFilePath = respository.getRoot() + "item_image/WMS/" + sdf.format(today);
			
			// 디렉토리 생성
	        File dir = new File(docFilePath);
	        if(!dir.isDirectory()){
	        	dir.mkdirs();
	        }
			
	        // 파일명 : System.currentTimeMillis() + "_" + 순번(ex:0, 순차적증가) + "." + 확장자
	        String docFileName = String.valueOf(System.currentTimeMillis()) + "_" + String.valueOf(num) + "." + exteName;
	        num++;
	        
	        // 파일 서버에 저장
			File srcFile = new File(filePath, fileOrgName);
			File tarFile = new File(docFilePath, docFileName);
	        this.copyFile(srcFile, tarFile);
			
	        // S_DOC_ATTACH_HEADER INSERT
			fileParam.put("DOC_ATTACH_H_ID", docAttachHId);
			fileParam.put("DOC_ATTACH_ID",   docAttachId);
			fileParam.put("DOC_TYPE_CODE",   inputName);
			fileParam.setModuleCommand("Mobile", "DOC_ATTACH_HEADER");
			commonDao.insert(fileParam);
			
			// S_DOC_ATTACH INSERT
			fileParam.put("DOC_NAME",        "MITTG0100");
			fileParam.put("FILE_LOCATION",   docFilePath);
			fileParam.put("FILE_NAME",       fileOrgName);
			fileParam.put("FILE_EXTENSION",  exteName);
			fileParam.put("TRANS_FILE_NAME", docFileName);
			fileParam.put("FILE_SIZE_BYTES", fileSize);
			fileParam.setModuleCommand("Mobile", "DOC_ATTACH");
			commonDao.insert(fileParam);
	        
			/**
			 * 4. 업무테이블에 첨부파일 ID 등록
			 */
			try {
				DataMap procMap = new DataMap();
				procMap.put("PROC_NAME",       "PR_ATTACH_ID_UPDATE");
				procMap.put("ITEM_CODE",       skukey[0]);
				procMap.put("P_DIV",           "MITTG0100");
				procMap.put("P_DOC_ATTACH_ID", docAttachHId);
				procMap.setModuleCommand("Mobile", "PR_WMS_FILE_ATTCH_WRAP");
				commonDao.getMap(procMap);
				
				if(subSkuList.size() > 0){
					DataMap row;
					for(int k = 0; k < subSkuList.size(); k++){
						row = subSkuList.get(k).getMap("map");
						procMap = new DataMap();
						procMap.put("PROC_NAME",       "PR_ATTACH_ID_UPDATE");
						procMap.put("ITEM_CODE",       row.getString("SKUKEY"));
						procMap.put("P_DIV",           "MITTG0100");
						procMap.put("P_DOC_ATTACH_ID", docAttachHId);
						procMap.setModuleCommand("Mobile", "PR_WMS_FILE_ATTCH_WRAP");
						commonDao.getMap(procMap);
					}
				}
			} catch (Exception e) {
				throw new SQLException(e.getMessage());
			}
			
			/**
			 * 5. 이미지구분별로 리사이즈 파일 생성 및 이미지 테이블(MITTG0600)에 데이터 등록
			 */
			// 경로 : E:\wmsSource\item_image\WMS\ + 년일4자리(ex:201609)
			sdf = new SimpleDateFormat("yyyyMM");
			String fileSetPath = "item_image/WMS/" + sdf.format(today);
			String resizeFilePath = respository.getRoot() + fileSetPath;
			
			// 디렉토리 생성
	        dir = new File(resizeFilePath);
	        if(!dir.isDirectory()){
	        	dir.mkdirs();
	        }
			
	        String[] imgTypeArr   = {"T", "S", "B"};
	        int[] resizeSizeArr   = {80, 250, 400};
	        String docSeq         = "";
			String resizeFileName = "";
			String dbInfileName   = "";
			
			int saveCount = 1;
	        
	        // 메인 이미지
	        if(inputName.charAt(0) == 'M') {
	        	saveCount = 3;
	        	docSeq = "01";
	        	
	        // 서브 이미지
	        } else if(inputName.charAt(0) == 'S') {
	        	saveCount = 3;
	        	docSeq = "0" + inputName.charAt(1);
	        
	        // 상세 이미지
	        } else if(inputName.charAt(0) == 'D') {
	        	saveCount = 1;
	        	docSeq = "0" + inputName.charAt(1);
	        }
	        
	        for(int i = 0; i < saveCount; i++){
	        	DataMap resizeMap = new DataMap();
	        	
	        	String imgType = inputName.charAt(0) + imgTypeArr[i];
	        	if(inputName.charAt(0) == 'D') {
	        		imgType = inputName.charAt(0) + "";
	        	}
	        	
	        	resizeFileName = skukey[0] + "_" + imgType + "_" + docSeq + "." + exteName;
	        	dbInfileName = skukey[0] + "_" + imgType + "_" + docSeq;
	        	tarFile = new File(resizeFilePath, resizeFileName);
	        	
	        	if(inputName.charAt(0) == 'D') {
	        		this.copyFile(srcFile, tarFile);
	        	} else {
	        		this.resizeFile(srcFile, exteName, tarFile, resizeSizeArr[i], resizeSizeArr[i]);
	        	}
	        	
	        	resizeMap.put("SKUKEY",             skukey[0]);
	        	resizeMap.put("DOC_ATTACH_ID",      docAttachId);
	        	resizeMap.put("EXE_NAME",           exteName);
	        	resizeMap.put("IMG_FILE_TYPE_CODE", imgType);
	        	resizeMap.put("FILE_PATH",          fileSetPath);
	        	resizeMap.put("IMG_FILE_NAME",      dbInfileName);
	        	resizeMap.setModuleCommand("Mobile", "FILE_INSERT");
	        	commonDao.update(resizeMap);
	        }
	        
	        if(subSkuList.size() > 0){
				DataMap row;
				for(int k = 0; k < subSkuList.size(); k++){
					row = subSkuList.get(k).getMap("map");
					
					for(int i = 0; i < saveCount; i++){
			        	DataMap resizeMap = new DataMap();
			        	
			        	String imgType = inputName.charAt(0) + imgTypeArr[i];
			        	if(inputName.charAt(0) == 'D'){
			        		imgType = inputName.charAt(0) + "";
			        	}
			        	
			        	resizeFileName = row.getString("SKUKEY") + "_" + imgType + "_" + docSeq + "." + exteName;
			        	dbInfileName = row.getString("SKUKEY") + "_" + imgType + "_" + docSeq;
			        	tarFile = new File(resizeFilePath, resizeFileName);
			        	
			        	if(inputName.charAt(0) == 'D') {
			        		this.copyFile(srcFile, tarFile);
			        	} else {
			        		this.resizeFile(srcFile, exteName, tarFile, resizeSizeArr[i], resizeSizeArr[i]);
			        	}
			        	
			        	resizeMap.put("SKUKEY",             row.getString("SKUKEY"));
			        	resizeMap.put("DOC_ATTACH_ID",      docAttachId);
			        	resizeMap.put("EXE_NAME",           exteName);
			        	resizeMap.put("IMG_FILE_TYPE_CODE", imgType);
			        	resizeMap.put("FILE_PATH",          fileSetPath);
			        	resizeMap.put("IMG_FILE_NAME",      dbInfileName);
			        	resizeMap.setModuleCommand("Mobile", "FILE_INSERT");
			        	commonDao.update(resizeMap);
			        }
				}
	        }
	        
	        /**
	         * 6. SUB 품목에 첨부파일 KEY값 등록
	         */
	        try {
				DataMap procMap = new DataMap();
				procMap.put("PROC_NAME",       "PR_WMS_ITEM_IMG_ATTACH");
				procMap.put("ITEM_CODE",       skukey[0]);
				procMap.put("P_DIV",           "C");
				procMap.put("P_DOC_ATTACH_ID", "");
				procMap.setModuleCommand("Mobile", "PR_WMS_FILE_ATTCH_WRAP");
				commonDao.getMap(procMap);
				
				if(subSkuList.size() > 0){
					DataMap row;
					for(int k = 0; k < subSkuList.size(); k++){
						row = subSkuList.get(k).getMap("map");
						procMap = new DataMap();
						procMap.put("PROC_NAME",       "PR_WMS_ITEM_IMG_ATTACH");
						procMap.put("ITEM_CODE",       row.getString("SKUKEY"));
						procMap.put("P_DIV",           "C");
						procMap.put("P_DOC_ATTACH_ID", "");
						procMap.setModuleCommand("Mobile", "PR_WMS_FILE_ATTCH_WRAP");
						commonDao.getMap(procMap);
					}
				}
			} catch (Exception e) {
				throw new SQLException(e.getMessage());
			}
	        
	        /**
	         * 7. Image 등록유무 update
	         */
	        fileParam.put("FILE_TYPE", inputName.charAt(0));
			fileParam.put("CHECK", "V");
			fileParam.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			fileParam.setModuleCommand("Mobile", "MIM01SKUMA");
			commonDao.update(fileParam);
			
			if(subSkuList.size() > 0){
				DataMap row;
				for(int k = 0; k < subSkuList.size(); k++){
					row = subSkuList.get(k).getMap("map");
					row.put("FILE_TYPE", inputName.charAt(0));
					row.put("CHECK", "V");
					row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
					row.setModuleCommand("Mobile", "MIM01SKUMA");
					commonDao.update(row);
				}
			}
	        
		}
		
		return result;
	}
	
	/**
     * 원본 파일을 리사이징하여 변환할 파일에 저장한다.
     * @param srcFile
     * @param extension
     * @param tarFile
     * @param tarWidth
     * @param tarHeight
     */
    public void resizeFile(File srcFile, String extension, File tarFile, int tarWidth, int tarHeight) throws IOException {
        ImageInputStream  iis = null;
        ImageOutputStream ios = null;
        ImageReader ir = null;
        ImageWriter iw = null;
        try {
            iis = ImageIO.createImageInputStream(srcFile);
            ios = ImageIO.createImageOutputStream(tarFile);
            
            ir = ImageIO.getImageReadersByFormatName(extension).next();
            iw = ImageIO.getImageWritersByFormatName(extension).next();
            ir.setInput(iis);
            iw.setOutput(ios);

            ImageWriteParam iwp = iw.getDefaultWriteParam();
            
            
            // compression 미지원 포맷은 오류가 발생할 수 있다. (png, gif 등)
            try {
                iwp.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
                iwp.setCompressionQuality(1);
            } catch(Exception e) {}

            BufferedImage srcBi = ir.read(0);
            int srcWidth  = srcBi.getWidth();
            int srcHeight = srcBi.getHeight();
            double ratio = 0;
            
            // 긴 축을 기준으로 tarWidth와 tarHeight를 다시 구한다.
            if(srcWidth >= srcHeight) {
                ratio = (double)tarWidth / (double)srcWidth;
                tarHeight = (int)(srcHeight * ratio);  
            } else {
                ratio = (double)tarHeight / (double)srcHeight;
                tarWidth = (int)(srcWidth * ratio);  
            }
            
            BufferedImage tarBi = new BufferedImage(tarWidth, tarHeight, BufferedImage.TYPE_INT_RGB);
            Graphics2D g = tarBi.createGraphics();
            g.drawImage(srcBi, 0, 0, tarWidth, tarHeight, null);
            
            IIOImage tarImg = new IIOImage(tarBi, null, null);
            iw.write(null, tarImg, iwp);
        } catch(Exception e) {
            throw e;
        } finally {
            if(iis != null) { iis.close(); }
            if(ios != null) { ios.close(); }
            if(ir  != null) { ir.dispose(); }
            if(iw  != null) { iw.dispose(); }
        }
    }
    
    /**
     * 파일 복사
     * @param srcFile
     * @param tarFile
     * @throws IOException
     */
    public void copyFile(File srcFile, File tarFile) throws IOException {
    	FileInputStream fis = null;
    	FileOutputStream fos = null;
    	
    	try {
    		fis = new FileInputStream(srcFile);
			fos = new FileOutputStream(tarFile);
			
			int data = 0;
			while((data = fis.read()) != -1){
				fos.write(data);
			}
		} catch (Exception e) {
			throw e;
		} finally {
			if(fis != null) { fis.close(); }
			if(fos != null) { fos.close(); }
		}
    }
	

	@Transactional
	public String imgFIleDelete(DataMap map) throws FileNotFoundException, IOException, SQLException {
		String result = "";
		
		List<DataMap> list = map.getList("list");
		
		DataMap row;
		for(int i = 0; i < list.size(); i++){
			row = list.get(i).getMap("map");
			
			row.setModuleCommand("Mobile", "SUBSKUKEY");
			List<DataMap> subSkuList = commonDao.getList(row);
			
			// 파일 삭제
			FileUtil fileUtil = new FileUtil();
			fileUtil.deleteFile(row.getString("ORG_FILE_PATH"), row.getString("TRANS_FILE_NAME")); // 원본
			
			// 리사이즈 파일 삭제
			// 메인
			String filePath = respository.getRoot() + row.getString("FILE_PATH");
			
			// 메인
			if(row.getString("DOC_TYPE_CODE").charAt(0) == 'M'){
				fileUtil.deleteFile(filePath, row.getString("MB"));
				fileUtil.deleteFile(filePath, row.getString("MS"));
				fileUtil.deleteFile(filePath, row.getString("MT"));
			// 서브
			} else if(row.getString("DOC_TYPE_CODE").charAt(0) == 'S'){
				fileUtil.deleteFile(filePath, row.getString("SB"));
				fileUtil.deleteFile(filePath, row.getString("SS"));
				fileUtil.deleteFile(filePath, row.getString("ST"));
			// 상세
			} else if(row.getString("DOC_TYPE_CODE").charAt(0) == 'D'){
				fileUtil.deleteFile(filePath, row.getString("D"));
			}
			
			// 데이터 삭제
			map.put("DOC_ATTACH_ID", row.getString("DOC_ATTACH_ID"));
			map.setModuleCommand("Mobile", "MITTG0600");
			commonDao.delete(map);
			map.setModuleCommand("Mobile", "S_DOC_ATTACH");
			commonDao.delete(map);
			map.setModuleCommand("Mobile", "S_DOC_ATTACH_HEADER");
			commonDao.delete(map);
			
			// 품목정보 업데이트
			try {
				DataMap procMap = new DataMap();
				procMap.put("PROC_NAME",       "PR_WMS_ITEM_IMG_ATTACH");
				procMap.put("ITEM_CODE",       row.getString("ITEM_CODE"));
				procMap.put("P_DIV",           "D");
				procMap.put("P_DOC_ATTACH_ID", row.getString("DOC_ATTACH_ID"));
				procMap.setModuleCommand("Mobile", "PR_WMS_FILE_ATTCH_WRAP");
				commonDao.getMap(procMap);
				
				if(subSkuList.size() > 0){
					DataMap item;
					for(int k = 0; k < subSkuList.size(); k++){
						item = subSkuList.get(k).getMap("map");
						procMap = new DataMap();
						procMap.put("PROC_NAME",       "PR_WMS_ITEM_IMG_ATTACH");
						procMap.put("ITEM_CODE",       item.getString("SKUKEY"));
						procMap.put("P_DIV",           "C");
						procMap.put("P_DOC_ATTACH_ID", row.getString("DOC_ATTACH_ID"));
						procMap.setModuleCommand("Mobile", "PR_WMS_FILE_ATTCH_WRAP");
						commonDao.getMap(procMap);
					}
				}
			} catch (Exception e) {
				throw new SQLException(e.getMessage());
			}
			
			// Image 등록유무 update
			int count = 0;
			row.put("FILE_TYPE", row.getString("DOC_TYPE_CODE").charAt(0) + "");
			row.put("SKUKEY", row.getString("ITEM_CODE"));
			
			// 서브나 디테일 삭제일 경우
			if(row.getString("DOC_TYPE_CODE").charAt(0) != 'M'){
				row.setModuleCommand("Mobile", "SKU_IMG_CNT");
				DataMap cntMap = commonDao.getMap(row);
				count = Integer.parseInt(cntMap.getString("CNT"));
			}
			
			if(count == 0){
				row.put("CHECK", " ");
				row.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
				row.setModuleCommand("Mobile", "MIM01SKUMA");
				commonDao.update(row);
				
				if(subSkuList.size() > 0){
					DataMap itemRow;
					for(int k = 0; k < subSkuList.size(); k++){
						itemRow = subSkuList.get(k).getMap("map");
						itemRow.put("FILE_TYPE", row.getString("DOC_TYPE_CODE").charAt(0) + "");
						itemRow.put("CHECK", " ");
						itemRow.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
						itemRow.setModuleCommand("Mobile", "MIM01SKUMA");
						commonDao.update(row);
					}
				}
			}
		}
		
		result = "OK";
		
		return result;
	}
	
	@Transactional
	public String saveMIM02(HttpServletRequest request, DataMap map) throws SQLException, IOException {
		String result = "SAVE";
		
		MultipartHttpServletRequest fileRequest = (MultipartHttpServletRequest) request;
		
		FileUtil fileUtil = new FileUtil();
		
		Iterator it = fileRequest.getFileNames();
		Map param   = fileRequest.getParameterMap();
		
		String[] ebeln = (String[]) param.get("EBELN");
		
		int num = 0;
		DataMap fileParam;
		while(it.hasNext()){
			
			// file input name
			String inputName = it.next().toString();
			
			// 파일객체 생성
			MultipartFile file = fileRequest.getFile(inputName);
			if(file.isEmpty()) {
				continue;
			}
			
			fileParam = new DataMap();
			fileParam.put("EBELN", ebeln[0]);
			
			String fileOrgName = file.getOriginalFilename();
			String exteName = fileOrgName.substring(fileOrgName.lastIndexOf(".") + 1).toLowerCase();
			String fileSize = String.valueOf(file.getSize());
			
			/**
			 * 1. 첨부파일 서버에 저장 (원본 이미지 파일)
			 */
			// 파일경로 지정 => E:\wmsSource\ upload\F038\WMS\ + 년일6자리(ex:160825)
			Date today = new Date();
			SimpleDateFormat sdf = new SimpleDateFormat("yyMMdd");
			String filePath = respository.getRoot() + "upload/F038/WMS/" + sdf.format(today);
			
			// 디렉토리 생성
	        File dir = new File(filePath);
	        if(!dir.isDirectory()){
	        	dir.mkdirs();
	        }
	        
	        // 파일명 : System.currentTimeMillis() + "_" + 순번(ex:0, 순차적증가) + "." + 확장자
	        String fileName = String.valueOf(System.currentTimeMillis()) + "_" + String.valueOf(num) + "." + exteName;
	        num++;
	        
			// 파일 서버에 저장
	        file.transferTo(fileUtil.getFile(filePath, fileName));
	        
	        /**
	         * 2. 첨부테이블ID 찾기
	         */
	        fileParam.put("P_CODE", ebeln[0]);
	        fileParam.put("P_DIV",  "DN");
	        
	        // attach header id 얻기
	        fileParam.setModuleCommand("Mobile", "ATTACH_HEADER_ID");
	        String docAttachHId = (String) commonDao.getObject(fileParam);
	        
	        if(docAttachHId.equals("E")){
	        	throw new SQLException("ATTACH HEADER ID를 얻을 수 없습니다. 관리자에게 문의하시기 바랍니다.");
	        }
	        
	        // attach id 얻기
	        fileParam.setModuleCommand("Mobile", "ATTACH_ID");
	        String docAttachId = (String) commonDao.getObject(fileParam);
	        
	        if(docAttachId.equals("E")){
	        	throw new SQLException("ATTACH ID를 얻을 수 없습니다. 관리자에게 문의하시기 바랍니다.");
	        }
			
	        /**
	         * 3. 파일 생성 및 첨부테이블(S_DOC_ATTACH_HEADER, S_DOC_ATTACH)에 데이터 등록
	         */
	        // S_DOC_ATTACH_HEADER INSERT
			fileParam.put("DOC_ATTACH_H_ID", docAttachHId);
			fileParam.put("DOC_ATTACH_ID",   docAttachId);
			fileParam.put("DOC_TYPE_CODE",   "DN");
			fileParam.setModuleCommand("Mobile", "DOC_ATTACH_HEADER");
			commonDao.insert(fileParam);
			
			// S_DOC_ATTACH INSERT
			fileParam.put("DOC_NAME",        "TLOTG0200");
			fileParam.put("FILE_LOCATION",   filePath);
			fileParam.put("FILE_NAME",       fileOrgName);
			fileParam.put("FILE_EXTENSION",  exteName);
			fileParam.put("TRANS_FILE_NAME", fileName);
			fileParam.put("FILE_SIZE_BYTES", fileSize);
			fileParam.put("FILE_TYPE",       "DN");
			fileParam.setModuleCommand("Mobile", "DOC_ATTACH");
			commonDao.insert(fileParam);
	        
			try {
				/**
				 * 4. DN 등록 여부, 정산 상태 변경
				 */
				DataMap procMap = new DataMap();
				procMap.put("PROC_NAME",       "PR_TLOTG0200_V06_SAVE");
				procMap.put("ITEM_CODE",       ebeln[0]);
				procMap.put("P_DIV",           "");
				procMap.put("P_DOC_ATTACH_ID", docAttachHId);
				procMap.setModuleCommand("Mobile", "PR_WMS_FILE_ATTCH_WRAP");
				commonDao.getMap(procMap);
				
				/**
				 * 5. 업무테이블에 첨부파일 ID 등록
				 */
				procMap = new DataMap();
				procMap.put("PROC_NAME",       "PR_ATTACH_ID_UPDATE");
				procMap.put("ITEM_CODE",       ebeln[0]);
				procMap.put("P_DIV",           "TLOTG0200");
				procMap.put("P_DOC_ATTACH_ID", docAttachHId);
				procMap.setModuleCommand("Mobile", "PR_WMS_FILE_ATTCH_WRAP");
				commonDao.getMap(procMap);
			} catch (Exception e) {
				throw new SQLException(e.getMessage());
			}
		}
		
		return result;
	}
	
	@Transactional
	public String dnFileDelete(DataMap map) throws FileNotFoundException, IOException, SQLException {
		String result = "";
		
		List<DataMap> list = map.getList("list");
		
		DataMap row;
		for(int i = 0; i < list.size(); i++){
			row = list.get(i).getMap("map");
			
			// 파일 삭제
			FileUtil fileUtil = new FileUtil();
			fileUtil.deleteFile(row.getString("ORG_FILE_PATH"), row.getString("TRANS_FILE_NAME")); // 원본
			
			// 데이터 삭제
			map.put("DOC_ATTACH_ID", row.getString("DOC_ATTACH_ID"));
			map.setModuleCommand("Mobile", "S_DOC_ATTACH");
			commonDao.delete(map);
			map.setModuleCommand("Mobile", "S_DOC_ATTACH_HEADER");
			commonDao.delete(map);
			
			// 품목정보 업데이트
			try {
				DataMap procMap = new DataMap();
				procMap.put("PROC_NAME",       "PR_TLOTG0200_V05_SAVE");
				procMap.put("ITEM_CODE",       row.getString("DOC_ID"));
				procMap.put("P_DIV",           "");
				procMap.put("P_DOC_ATTACH_ID", row.getString("DOC_ATTACH_H_ID"));
				procMap.setModuleCommand("Mobile", "PR_WMS_FILE_ATTCH_WRAP");
				commonDao.getMap(procMap);
			} catch (Exception e) {
				throw new SQLException(e.getMessage());
			}
		}
		
		result = "OK";
		
		return result;
	}
	
	@Transactional
	public String saveWKSIGN(DataMap map) throws SQLException, IOException {
		String result = "";
		
		// 파일경로
		String filePath = respository.getRoot() + "upload/sign";
		
		String signStr = map.getString("SIGN");
		String[] signArr = signStr.split(",");
		
		String sign = signArr[1];
		
		// 파일명
		String fileName = map.get(CommonConfig.SES_USER_ID_KEY) + "_" + String.valueOf(System.currentTimeMillis()) + ".png";
		
		// 디렉토리 생성
        File dir = new File(filePath);
        if(!dir.isDirectory()){
        	dir.mkdirs();
        }
        
		// 파일 서버에 저장
        FileUtils.writeByteArrayToFile(new File(filePath, fileName), Base64.decode(sign));
        
		try {
			DataMap param = new DataMap();
			param.put("DOCCAT", map.getString("DOCCAT"));
			param.put("DOCUTY", map.getString("DOCUTY"));
			param.put("DOCUKY", map.getString("DOCUKY"));
			param.put("SIGNFL", fileName);
			param.put(CommonConfig.SES_USER_ID_KEY, map.get(CommonConfig.SES_USER_ID_KEY));
			param.setModuleCommand("Mobile", "WKSIGN");
			commonDao.insert(param);
		} catch (Exception e) {
			throw new SQLException(e.getMessage());
		}
		
		result = "OK";
		
		return result;
	}
}