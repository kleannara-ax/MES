package project.common.util;

import com.sap.conn.jco.JCoException;
import com.sap.conn.jco.ext.DestinationDataProvider;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import project.common.bean.CommonConfig;
import project.common.bean.DataMap;

import javax.servlet.http.HttpServlet;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

public class RfcCallFunction extends HttpServlet{
	static final Logger log = LogManager.getLogger(RfcCallFunction.class.getName());

	Properties prop;
	public String getProperty(String key){
		return prop.getProperty(key);
	}
	
	
	/**
	 * RFC CALL CONNECTION SETTING
	 * @return baseMap
	 */
	public DataMap RfcCallConnSet() {
		DataMap baseMap = new DataMap();
		FileUtil fileUtil = new FileUtil();
		try{
			if(CommonConfig.isRealServer()) {
				//log.info(">>>>>call sap load prod properties >>>>");
				prop = fileUtil.loadProperties(this.getClass().getResource("/").getPath().replace("classes/", "") + "conf", "sap-prod.properties");
			}else{
				//log.info(">>>>>call sap load dev properties >>>>");
				//인텔리
				//prop = fileUtil.loadProperties(this.getClass().getResource("/").getPath().replace("/classes/artifacts/klra_mes__web_exploded/WEB-INF/classes/", "/") + "conf", "sap.properties");
				//이클립스
				prop = fileUtil.loadProperties(this.getClass().getResource("/").getPath().replace("classes/", "") + "conf", "sap.properties");
			}
//			String filePath = this.getClass().getResource("/").getPath();
//			int idx = filePath.indexOf("/WebContent/WEB-INF");
//			String path = filePath.substring(0, idx)+"/WebContent/WEB-INF/conf";
//			prop = fileUtil.loadProperties(path ,"sap.properties");
		}catch(Exception e1){
			e1.printStackTrace();
		}
		baseMap.put(DestinationDataProvider.JCO_ASHOST, 	prop.getProperty("sap.jco.ASHOST")); // SAP 호스트 정보
		baseMap.put(DestinationDataProvider.JCO_SYSNR, 		prop.getProperty("sap.jco.SYSNUM")); // 인스턴스번호
		baseMap.put(CommonConfig.SAP_JCO_SYSID, 			prop.getProperty("sap.jco.SYSID")); // 인스턴스아이디
		baseMap.put(DestinationDataProvider.JCO_CLIENT, 	prop.getProperty("sap.jco.CLIENT")); // SAP 클라이언트
		baseMap.put(DestinationDataProvider.JCO_USER, 		prop.getProperty("sap.jco.USERID")); // SAP유저명
		baseMap.put(DestinationDataProvider.JCO_PASSWD, 	prop.getProperty("sap.jco.PASSWD")); // SAP 패스워드
		baseMap.put(DestinationDataProvider.JCO_LANG, 		prop.getProperty("sap.jco.LANGKY")); // 언어

		
		return baseMap;
	}


	/**
	 * RFC CALL INBOUND FUNCTION
	 * @param IF_NAME
	 * @param IF_RETBL
	 * @param I_FLAG
	 * @param list
	 * @return returnList
	 */
	public DataMap RfcCallTableMulti(String IF_NAME, String IF_RETBL, String IF_RETBL2, String IF_RESTR, DataMap map, List<DataMap> list) {

		RfcCallClient rfcCallClient = new RfcCallClient();
		DataMap returnList = new DataMap();
		DataMap baseMap = new DataMap();
//		DataMap map = new DataMap();

		baseMap = RfcCallConnSet(); 				// RFC CALL CONNECTION SET

		baseMap.put("IF_NAME", IF_NAME);			// FUNCTION NAME
		baseMap.put("IF_RETBL", IF_RETBL);		// TABLE NAME
		baseMap.put("IF_RETBL2", IF_RETBL2);		// TABLE NAME
		baseMap.put("IF_RESTR", IF_RESTR);		// STRUCTURE NAME


//		map.put("I_IF_NAM", id);				// ifid
//		map.put("I_IF_KEY", seq);				// seq

		try {
			if (list != null && list.size() > 0 ) {
			// 결과 송신
				// List<DataMap> resultList= rfcCallClient.flagToTableInboundResult(list, baseMap, map);
				rfcCallClient.flagToTableInboundResult(list, baseMap, map);
			} else {
			// 수신
				returnList = rfcCallClient.flagToTableInboundMulti(baseMap, map);
			}

		} catch (JCoException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return returnList;
	}


	/**
	 * RFC CALL INBOUND FUNCTION
	 * @param IF_NAME
	 * @param IF_RETBL
	 * @param I_FLAG
	 * @param list
	 * @return returnList
	 */
	public DataMap RfcCallTableSendAndReceiveList(String IF_NAME, String IF_RETBL, String IF_RETBL2, String IF_RESTR, DataMap map, List<DataMap> list) {

		RfcCallClient rfcCallClient = new RfcCallClient();
		DataMap returnList = new DataMap();
		DataMap baseMap = new DataMap();
//		DataMap map = new DataMap();

		baseMap = RfcCallConnSet(); 				// RFC CALL CONNECTION SET

		baseMap.put("IF_NAME", IF_NAME);			// FUNCTION NAME
		//if(!"Z_NES_MRLIFT_MOVE".equals(IF_NAME)) {
		baseMap.put("IF_RETBL", IF_RETBL);        // TABLE NAME
		baseMap.put("IF_RETBL2", IF_RETBL2);        // TABLE NAME
		//}
		baseMap.put("IF_RESTR", IF_RESTR);		// STRUCTURE NAME


//		map.put("I_IF_NAM", id);				// ifid
//		map.put("I_IF_KEY", seq);				// seq

		try {
			if (list != null && list.size() > 0 ) {
				// 결과 송신
				// List<DataMap> resultList= rfcCallClient.flagToTableInboundResult(list, baseMap, map);
				rfcCallClient.flagToTableInboundResult(list, baseMap, map);
			} else {
				// 수신
				returnList = rfcCallClient.flagToTableInboundMulti(baseMap, map);
			}
		} catch (JCoException e) {
			// TODO Auto-generated catch block
			DataMap d = new DataMap();
			d.put("TYPE", "E");
			d.put("MESSAGE", e.getMessage());
//			if(map.get("RET_MAP") == null) {
			map.put("RET_MAP", d);
//			}
			e.printStackTrace();
		}
		baseMap.clear();
		return returnList;
	}


	public DataMap RfcCallReturnSendOne(String IF_NAME, String IF_RESTR, DataMap map) {

			RfcCallClient rfcCallClient = new RfcCallClient();
			DataMap returnList = new DataMap();
			DataMap baseMap = new DataMap();
			baseMap = RfcCallConnSet(); 				// RFC CALL CONNECTION SET

			baseMap.put("IF_NAME", IF_NAME);			// FUNCTION NAME
			baseMap.put("IF_RESTR", IF_RESTR);		// STRUCTURE NAME

		try {
			// call and receive
			returnList = rfcCallClient.flagToTableInboundRTN(baseMap, map);
			// rfcCallClient.flagToTableInboundMulti(baseMap, map);

		} catch (JCoException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		baseMap.clear();
		return returnList;
	}

	/**
	 * RFC CALL INBOUND FUNCTION
	 * @param IF_NAME
	 * @param IF_RETBL
	 * @param I_FLAG
	 * @param list
	 * @return returnList
	 */
	public List<DataMap> RfcCallTable(String IF_NAME, String IF_RETBL, String IF_RESTR, DataMap map, List<DataMap> list) {

		RfcCallClient rfcCallClient = new RfcCallClient();
		List<DataMap> returnList = new ArrayList();
		DataMap baseMap = new DataMap();
//		DataMap map = new DataMap();

		baseMap = RfcCallConnSet(); 				// RFC CALL CONNECTION SET

		baseMap.put("IF_NAME", IF_NAME);			// FUNCTION NAME
		baseMap.put("IF_RETBL", IF_RETBL);		// TABLE NAME
		baseMap.put("IF_RESTR", IF_RESTR);		// STRUCTURE NAME


//		map.put("I_IF_NAM", id);				// ifid
//		map.put("I_IF_KEY", seq);				// seq

		try {
			if (list != null && list.size() > 0 ) {
				// 결과 송신
				returnList = rfcCallClient.flagToTableInboundResult(list, baseMap, map);
			} else {
				// 수신
				returnList = rfcCallClient.flagToTableInbound(baseMap, map);
			}

		} catch (JCoException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		baseMap.clear();
		return returnList;
	}
	
	/**
	 * RFC CALL INBOUND FUNCTION
	 * @param IF_NAME
	 * @param IF_RETBL
	 * @param I_FLAG
	 * @param list
	 * @return returnList
	 */
	public List<DataMap> RfcCallTable(String IF_NAME, String IF_RETBL, String IF_RESTR, String I_FLAG, List<DataMap> list) {

		RfcCallClient rfcCallClient = new RfcCallClient();
		List<DataMap> returnList = new ArrayList();
		DataMap baseMap = new DataMap();
		DataMap map = new DataMap();

		baseMap = RfcCallConnSet(); 				// RFC CALL CONNECTION SET

		baseMap.put("IF_NAME", IF_NAME);			// FUNCTION NAME
		baseMap.put("IF_RETBL", IF_RETBL);		// TABLE NAME
		baseMap.put("IF_RESTR", IF_RESTR);		// STRUCTURE NAME
		// map.put("I_FLAG", I_FLAG);				// D : 수신 , R : 송신

		try {
			if (list != null && list.size() > 0 ) {
				// 결과 송신
				returnList = rfcCallClient.flagToTableInboundResult(list, baseMap, map);
			} else {
				// 수신
				returnList = rfcCallClient.flagToTableInbound(baseMap, map);
			}

		} catch (JCoException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return returnList;
	}
	
	/**
	 * RFC CALL OUTBOUND FUNCTION
	 * @param IF_NAME
	 * @param IF_RETBL
	 * @param IF_RESTR
	 * @param list
	 * @return returnList
	 */
	public List<DataMap> RfcCallTableResult(String IF_NAME, String IF_RETBL, String IF_RESTR, List<DataMap> list) {
		
		RfcCallClient rfcCallClient = new RfcCallClient();
		List<DataMap> returnList = new ArrayList();
		DataMap baseMap = new DataMap();
		
		baseMap = RfcCallConnSet(); 				// RFC CALL CONNECTION SET          
		
		baseMap.put("IF_NAME", IF_NAME);			// FUNCTION NAME
		baseMap.put("IF_RETBL", IF_RETBL);		// TABLE NAME
		baseMap.put("IF_RESTR", IF_RESTR);		// STRUCTURE NAME
		
		try {
			if (list.size() > 0 ) {
				// 결과 송신
				returnList = rfcCallClient.flagToTableOutbound(list, baseMap);
			}
			
		} catch (JCoException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return returnList;
	}
	
	/**
	 * RFC CALL STRUCTURE FUNCTION
	 * @param IF_NAME
	 * @param IF_RESTR
	 * @param StrFlagMap
	 * @return returnList
	 */
	public List<DataMap> RfcCallStructure(String IF_NAME, String IF_RESTR, DataMap StrFlagMap) {
		
		RfcCallClient rfcCallClient = new RfcCallClient();
		List<DataMap> returnList = new ArrayList();
		DataMap baseMap = new DataMap();
		
		baseMap = RfcCallConnSet(); 				// RFC CALL CONNECTION SET 
		
		baseMap.put("IF_NAME", IF_NAME);			// FUNCTION NAME
		baseMap.put("IF_RESTR", IF_RESTR);		// STRUCTURE NAME
		
		try {
			returnList = rfcCallClient.flagToStructureInOutbound(baseMap, StrFlagMap);
		} catch (JCoException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return returnList;
	}
	
	
	/**
	 * RFC CALL INBOUND FUNCTION
	 * @param IF_NAME
	 * @param IF_RETBL
	 * @param I_FLAG
	 * @param list
	 * @return returnList
	 */
	public List<DataMap> ReRfcCallTable(String IF_NAME, String IF_RETBL, String IF_RESTR, String I_FLAG, String I_RESEND,  List<DataMap> list) {
		
		RfcCallClient rfcCallClient = new RfcCallClient();
		List<DataMap> returnList = new ArrayList();
		DataMap baseMap = new DataMap();
		DataMap map = new DataMap();
		
		baseMap = RfcCallConnSet(); 				// RFC CALL CONNECTION SET             
		
		baseMap.put("IF_NAME", IF_NAME);			// FUNCTION NAME
		baseMap.put("IF_RETBL", IF_RETBL);		// TABLE NAME
		baseMap.put("IF_RESTR", IF_RESTR);		// STRUCTURE NAME
		map.put("I_FLAG", I_FLAG);				// D : 수신 , R : 송신
		map.put("I_RESEND", I_RESEND);				// D : 수신 , R : 송신
		
		try {
			if (list.size() > 0 ) {
				// 결과 송신
				returnList = rfcCallClient.flagToTableInboundResult(list, baseMap, map);
			} else {
				// 수신
				returnList = rfcCallClient.flagToTableInbound(baseMap, map);
			}
			
		} catch (JCoException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return returnList;
	}	
	
	
	/**
	 * RFC CALL INBOUND FUNCTION
	 * @param IF_NAME
	 * @param IF_RETBL
	 * @param I_FLAG
	 * @param list
	 * @return returnList
	 */
	public List<DataMap> StockRfcCallTable(String IF_NAME, String IF_RETBL, String IF_RESTR, String IV_BUKRS, String IV_YYYYMM, String IV_DATE, List<DataMap> list) {
		
		RfcCallClient rfcCallClient = new RfcCallClient();
		List<DataMap> returnList = new ArrayList();
		DataMap baseMap = new DataMap();
		DataMap map = new DataMap();
		
		baseMap = RfcCallConnSet(); 				// RFC CALL CONNECTION SET             
		
		baseMap.put("IF_NAME", IF_NAME);			// FUNCTION NAME
		baseMap.put("IF_RETBL", IF_RETBL);		// TABLE NAME
		baseMap.put("IF_RESTR", IF_RESTR);		// STRUCTURE NAME
		map.put("IV_BUKRS", IV_BUKRS);				// D : 수신 , R : 송신
		map.put("IV_YYYYMM", IV_YYYYMM);				// D : 수신 , R : 송신
		map.put("IV_DATE", IV_DATE);				// D : 수신 , R : 송신
		
		try {
			if (list.size() > 0 ) {
				// 결과 송신
				returnList = rfcCallClient.flagToTableInboundResult(list, baseMap, map);
			} else {
				// 수신
				returnList = rfcCallClient.flagToTableInbound(baseMap, map);
			}
			
		} catch (JCoException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return returnList;
	}


	public List<DataMap> RfcCall(String IF_NAME, String IF_RETBL, String IF_RESTR, DataMap map, List<DataMap> list) {

		RfcCallClient rfcCallClient = new RfcCallClient();
		List<DataMap> returnList = new ArrayList();
		DataMap baseMap = new DataMap();
//		DataMap map = new DataMap();

		baseMap = RfcCallConnSet(); 				// RFC CALL CONNECTION SET

		baseMap.put("IF_NAME", IF_NAME);			// FUNCTION NAME
		baseMap.put("IF_RETBL", IF_RETBL);		// TABLE NAME
		baseMap.put("IF_RESTR", IF_RESTR);		// STRUCTURE NAME
//		map.put("I_IF_NAM", id);				// ifid
//		map.put("I_IF_KEY", seq);				// seq

		try {
			if (list != null && list.size() > 0 ) {
				// 결과 송신
				returnList = rfcCallClient.flagToTableInboundResult(list, baseMap, map);
			} else {
				// 수신
				returnList = rfcCallClient.flagToTableInbound(baseMap, map);
			}

		} catch (JCoException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return returnList;
	}
	
}
