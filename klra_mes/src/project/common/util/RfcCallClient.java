package project.common.util;

import com.sap.conn.jco.*;
import com.sap.conn.jco.ext.DestinationDataProvider;
import org.apache.commons.lang3.StringUtils;
import project.common.bean.CommonConfig;
import project.common.bean.DataMap;

import javax.xml.crypto.Data;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.*;

/**
 * basic examples for Java to ABAP communication  
 */
public class RfcCallClient
{
	
	static String ABAP_AS = "ABAP_AS_WITHOUT_POOL";
    static String ABAP_AS_POOLED = "ABAP_AS_WITH_POOL";
//	static String ABAP_AS_POOLED = "SAP_SERVER"; //sap 연결명(연결파일명으로 사용됨)
//	static String ABAP_AS_POOLED = "cvkcepvpap01p"; //sap 연결명(연결파일명으로 사용됨)
//	static String ABAP_AS_POOLED = "CEP";  //sap 연결명(연결파일명으로 사용됨)
    
    private void main(DataMap baseMap)
    {
        Properties connectProperties = new Properties();	// 연결프로퍼티 생성
        connectProperties.setProperty(DestinationDataProvider.JCO_ASHOST, baseMap.getString(DestinationDataProvider.JCO_ASHOST));	 // SAP 호스트 정보
        connectProperties.setProperty(DestinationDataProvider.JCO_SYSNR,  baseMap.getString(DestinationDataProvider.JCO_SYSNR));	 // 인스턴스번호
        connectProperties.setProperty(CommonConfig.SAP_JCO_SYSID,  		  baseMap.getString(CommonConfig.SAP_JCO_SYSID));
        connectProperties.setProperty(DestinationDataProvider.JCO_CLIENT, baseMap.getString(DestinationDataProvider.JCO_CLIENT));	 // SAP 클라이언트
        connectProperties.setProperty(DestinationDataProvider.JCO_USER,   baseMap.getString(DestinationDataProvider.JCO_USER));	 // SAP유저명
        connectProperties.setProperty(DestinationDataProvider.JCO_PASSWD, baseMap.getString(DestinationDataProvider.JCO_PASSWD));	 // SAP 패스워드
        connectProperties.setProperty(DestinationDataProvider.JCO_LANG,   baseMap.getString(DestinationDataProvider.JCO_LANG));  // 언어
        createDestinationDataFile(ABAP_AS_POOLED, connectProperties);        
    }
    
    //sap 연결파일 생성
    private void createDestinationDataFile(String destinationName, Properties connectProperties)
    {
        File destCfg = new File(destinationName+".jcoDestination");
        String sfileName = destCfg.getPath();
        try
        {
            //FileOutputStream fos = new FileOutputStream(destCfg, false);
        	OutputStream os = Files.newOutputStream(Paths.get(sfileName));
            connectProperties.store(os, "for tests only !");
            os.close();
        }
        catch (Exception e)
        {
            throw new RuntimeException("Unable to create the destination files", e);
        }
    }
    
    /**
     * map 형태로 넘어온 데이터를 처리한다. 결과값 table 형식
     * @param map
     * @return 
     * @throws JCoException
     */
    /*
     * 순서
     * 1. IF_NAME [function name 설정]
     * 2. paramlist 안에  [FLAG 값 셋팅]
     * 3. IF_RETBL 수신받을 값 [table name 설정]
     * 4. table list에 [SECNO 소분류 번호 설정]
     * 5. 결과값 returnList
     */
    @SuppressWarnings("finally")
	public List<DataMap> flagToTableInbound(DataMap basemap, DataMap map) throws JCoException
    {
    	main(basemap);
    	
    	List<DataMap> returnList = new ArrayList();
    	
    	JCoDestination destination = JCoDestinationManager.getDestination(ABAP_AS_POOLED);
    	
        // ... it always has a reference to a metadata repository
        JCoFunction function = destination.getRepository().getFunction(basemap.getString("IF_NAME"));
    
        if(function == null)
            throw new RuntimeException("FUNCTION not found in SAP.");
       // List<HashMap> list = new ArrayList();
	   // HashMap paramMap = new HashMap();
	    
        try
        {
	    	JCoParameterList paramlist = function.getImportParameterList();
	    	if(paramlist != null){
	    		Iterator keys = map.keySet().iterator();
	    		String key = "";
	    		while(keys.hasNext()){
	    			key = (String) keys.next();
	    			paramlist.setValue(key, map.get(key));
	    		}
	    	}
	    
            //execute, i.e. send the function to the ABAP system addressed 
            //by the specified destination, which then returns the function result.
            //All necessary conversions between Java and ABAP data types
            //are done automatically.
            function.execute(destination);
        }
        catch(AbapException e)
        {
        	return returnList;
        }
        
        try 
        {
	        JCoTable returnTable = function.getTableParameterList().getTable(basemap.getString("IF_RETBL"));
	        
	        int rfcRowNum = returnTable.getNumRows();
			for(int j = 0; j < rfcRowNum; j++){
				DataMap returnMap = new DataMap();
				returnTable.firstRow();
				JCoFieldIterator jrfit = returnTable.getFieldIterator();
				JCoField jField = null;
				while(jrfit.hasNextField()){
					jField = jrfit.nextField();
					returnMap.put(jField.getName(), jField.getValue());
				}
				
				returnMap.put("SECNO", j + 1); // 소분류 번호 설정
				returnList.add(j, returnMap);
				returnTable.deleteRow(0);
			}
        } 
        catch (Exception e) {
        	DataMap returnMap = new DataMap();
			e.printStackTrace();
			returnMap.put("ERRMSG", e.toString());
			returnList.add(0, returnMap);
		}
        finally
        {
        	return returnList;
		}
    }
    
    /**
     * list 데이터를 테이블에 담아 SAP에 송신한다. flagToTableInbound 메소드 결과에 대한 송신 및 
     * @param list
     * @param map
     * @param paramMap
     * @return
     * @throws JCoException
     */
    /*
     * 순서
     * 1. IF_NAME [function name 설정]
     * 2. paramlist 안에  [FLAG 값 셋팅]
     * 3. IF_RETBL 송신할 값 [table name 설정]
     * 4. table에 값 송신
     * 
     * ======= [S] 결과값 받지 않을 경우 =========
     * 5. REP_FLAG 값 S로 강제 설정
     * ======= [E] 결과값 받지 않을 경우 =========
     * 
     * ======= [S] 결과값 받을 경우 ============
     * 5. IF_RESTR 수신받을 값 [structure name 설정]
     * 6. REP_FLAG 값 에러유무 체크
     * 7-1. 에러시에 IF_RETBL 수신받을 값 [table name 설정]
     * 7-2. 정상시에 REP_FLAG 값 returnList에 설정
     * ======= [E] 결과값 받을 경우 ============
     * 
     * 8. 결과값 returnList
     */
    @SuppressWarnings("finally")
	public List<DataMap> flagToTableInboundResult(List<DataMap> list, DataMap map, DataMap paramMap) throws JCoException
    {
    	main(map);
    	
    	List<DataMap> returnList = new ArrayList();
		List<DataMap> returnList2 = new ArrayList();

    	JCoDestination destination = JCoDestinationManager.getDestination(ABAP_AS_POOLED);
    	
    	// ... it always has a reference to a metadata repository
        JCoFunction function = destination.getRepository().getFunction(map.getString("IF_NAME"));
    
        if(function == null)
            throw new RuntimeException("FUNCTION not found in SAP.");
       // List<HashMap> list = new ArrayList();
	   // HashMap paramMap = new HashMap();
	    
        try
        {
        	JCoParameterList param = function.getImportParameterList();
        	Iterator keys = paramMap.keySet().iterator();
	    	String key = "";
	    	while(keys.hasNext()){
				key = (String) keys.next();
				try {
					param.setValue(key, paramMap.get(key));
				}catch (Exception e) {
					//"JCO_ERROR_FIELD_NOT_FOUND"
					System.out.println(e.getMessage());
				}
			}
	    	
	    	JCoTable table = function.getTableParameterList().getTable(map.getString("IF_RETBL"));
	    	DataMap reqMap = new DataMap();
			for(int i = 0; i < list.size(); i++){
				table.appendRow();
				reqMap = list.get(i);
		        
		        Iterator listkeys = reqMap.keySet().iterator();
		    	String listkey = "";
		    	while(listkeys.hasNext()){
		    		listkey = (String) listkeys.next();
		    		table.setValue(listkey, reqMap.get(listkey));
				}
			}
	    	
	    	//execute, i.e. send the function to the ABAP system addressed 
            //by the specified destination, which then returns the function result.
            //All necessary conversions between Java and ABAP data types
            //are done automatically.
            function.execute(destination);
            reqMap.clear();
        }
        catch(AbapException e)
        {
        	return returnList;
        }
        try 
        {
            // ====================== 1. 결과값 받지 않을 경우 ======================
//            DataMap returnMapStr = new DataMap();
//            returnMapStr.put("REP_FLAG","S"); // 무조건 정상처리
//            returnList.add(returnMapStr);

			if("NO_RETURN".equals(map.getString("IF_RETBL2"))) {
				DataMap returnMapStr = new DataMap();
				returnMapStr.put("TYPE","S"); // 무조건 정상처리
				returnMapStr.put("MESSAGE","성공"); // 무조건 정상처리
				paramMap.put("RET_MAP",returnMapStr);
				return returnList;
			}

            // ====================== 2. 결과값 받을 경우 ======================
        	// 리턴받을 Structure 명 설정
        	JCoStructure returnStructure = function.getExportParameterList().getStructure(map.getString("IF_RESTR"));
        	
        	DataMap returnMapStr = new DataMap();
        	JCoFieldIterator jrfitStr = returnStructure.getFieldIterator();
        	JCoField jFieldStr = null;
        	while(jrfitStr.hasNextField()){
        		jFieldStr = jrfitStr.nextField();
        		returnMapStr.put(jFieldStr.getName(), jFieldStr.getValue());
			}
        	
        	// Structure REP_FLAG 컬럼의 값이 E 일때 상세 table 내역 조회
        	if (returnMapStr.getString("REP_FLAG").equals("E")){
        		
        		// 리턴받을 Table 명 설정
        		JCoTable returnTable = function.getTableParameterList().getTable(map.getString("IF_RETBL"));
    	        returnList.add(0, returnMapStr);
    			int rfcRowNum = returnTable.getNumRows();
    			for(int j = 0; j < rfcRowNum; j++){
    				DataMap returnMap = new DataMap();
    				returnTable.firstRow();
    				JCoFieldIterator jrfit = returnTable.getFieldIterator();
    				JCoField jField = null;
    				while(jrfit.hasNextField()){
    					jField = jrfit.nextField();
    					returnMap.put(jField.getName(), jField.getValue());
    				}

					paramMap.put("RET_ERR", returnMap);
    	
    				returnList.add(j + 1, returnMap);
    				returnTable.deleteRow(0);
    			}
        	} else {
        		// Structure REP_FLAG 컬럼의 값이 S 일때 리턴값 저장
        		// returnList.add(returnMapStr);
				paramMap.put("RET_MAP",returnMapStr);
        	}

//
			JCoTable returnTable2 = function.getTableParameterList().getTable(map.getString("IF_RETBL2"));
			System.out.println("*****2 : "+returnTable2);

			int rfcRowNum2 = returnTable2.getNumRows();
			for(int j2 = 0; j2 < rfcRowNum2; j2++){
				DataMap returnMap2 = new DataMap();
//				returnTable2.firstRow();
				JCoFieldIterator jrfit2 = returnTable2.getFieldIterator();
				JCoField jField2 = null;
				while(jrfit2.hasNextField()){
					jField2 = jrfit2.nextField();
					returnMap2.put(jField2.getName(), jField2.getValue());
				}

				returnMap2.put("SECNO", j2 + 1); // 소분류 번호 설정
				returnList2.add(j2, returnMap2);
//				returnTable2.deleteRow(0);
				returnTable2.nextRow();
			}
			paramMap.put(map.getString("IF_RETBL2"), returnList2 );

        } 
        catch (Exception e) {
			e.printStackTrace();
		}
        finally
        {
        	return returnList;
		}
    }

	/**
	 * map 형태로 넘어온 데이터를 처리한다. 결과값 table 형식
	 * @param map
	 * @return
	 * @throws JCoException
	 */
	/*
	 * 순서
	 * 1. IF_NAME [function name 설정]
	 * 2. paramlist 안에  [FLAG 값 셋팅]
	 * 3. IF_RETBL 수신받을 값 [table name 설정]
	 * 4. table list에 [SECNO 소분류 번호 설정]
	 * 5. 결과값 returnList
	 */
	@SuppressWarnings("finally")
	public DataMap flagToTableInboundMulti(DataMap basemap, DataMap map) throws JCoException
	{
		main(basemap);

		List<DataMap> returnList = new ArrayList();
		List<DataMap> returnList2 = new ArrayList();

		DataMap resultMap = new DataMap();

		JCoDestination destination = JCoDestinationManager.getDestination(ABAP_AS_POOLED);

		// ... it always has a reference to a metadata repository
		JCoFunction function = destination.getRepository().getFunction(basemap.getString("IF_NAME"));

		if(function == null)
			throw new RuntimeException("FUNCTION not found in SAP.");
		// List<HashMap> list = new ArrayList();
		// HashMap paramMap = new HashMap();

		try
		{
			JCoParameterList paramlist = function.getImportParameterList();
			if(paramlist != null){
				Iterator keys = map.keySet().iterator();
				String key = "";
				while(keys.hasNext()){
					key = (String) keys.next();
					paramlist.setValue(key, map.get(key));
				}
			}

			//execute, i.e. send the function to the ABAP system addressed
			//by the specified destination, which then returns the function result.
			//All necessary conversions between Java and ABAP data types
			//are done automatically.
			function.execute(destination);
		}
		catch(AbapException e)
		{
			return resultMap;
		}

		try
		{
			JCoTable returnTable = function.getTableParameterList().getTable(basemap.getString("IF_RETBL"));
			System.out.println("*****1 : "+returnTable);

			int rfcRowNum = returnTable.getNumRows();
			for(int j = 0; j < rfcRowNum; j++){
				DataMap returnMap = new DataMap();
//				returnTable.firstRow();
				JCoFieldIterator jrfit = returnTable.getFieldIterator();
				JCoField jField = null;
				while(jrfit.hasNextField()){
					jField = jrfit.nextField();
					returnMap.put(jField.getName(), jField.getValue());
				}

				returnMap.put("SECNO", j + 1); // 소분류 번호 설정
				returnList.add(j, returnMap);
//				returnTable.deleteRow(0);
				returnTable.nextRow();
			}
			resultMap.put(basemap.getString("IF_RETBL"),returnList);

			JCoTable returnTable2 = function.getTableParameterList().getTable(basemap.getString("IF_RETBL2"));
			System.out.println("*****2 : "+returnTable2);

			int rfcRowNum2 = returnTable2.getNumRows();
			for(int j2 = 0; j2 < rfcRowNum2; j2++){
				DataMap returnMap2 = new DataMap();
//				returnTable2.firstRow();
				JCoFieldIterator jrfit2 = returnTable2.getFieldIterator();
				JCoField jField2 = null;
				while(jrfit2.hasNextField()){
					jField2 = jrfit2.nextField();
					returnMap2.put(jField2.getName(), jField2.getValue());
				}

				returnMap2.put("SECNO", j2 + 1); // 소분류 번호 설정
				returnList2.add(j2, returnMap2);
//				returnTable2.deleteRow(0);
				returnTable2.nextRow();
			}
			resultMap.put(basemap.getString("IF_RETBL2"),returnList2);

		}
		catch (Exception e) {
			e.printStackTrace();
			resultMap.put("ERRMSG", e.toString());
		}
		finally
		{
			return resultMap;
		}
	}
    
    /**
     * list 데이터를 테이블에 담아 SAP에 송신한다. SAP에 확정 및 결과 송신
     * @param list
     * @param map
     * @param paramMap
     * @return
     * @throws JCoException
     */
    /*
     * 순서
     * 1. IF_NAME [function name 설정]
     * 2. IF_RETBL 송신할 값 [table name 설정]
     * 3. table에 값 송신
     * 
     * ======= [S] 결과값 받지 않을 경우 =========
     * 4. REP_FLAG 값 S로 강제 설정
     * ======= [E] 결과값 받지 않을 경우 =========
     * 
     * ======= [S] 결과값 받을 경우 ============
     * 4. IF_RESTR 수신받을 값 [structure name 설정]
     * 5. REP_FLAG 값 에러유무 체크
     * 6-1. 에러시에 IF_RETBL 수신받을 값 [table name 설정]
     * 6-2. 정상시에 REP_FLAG 값 returnList에 설정
     * ======= [E] 결과값 받을 경우 ============
     * 
     * 7. 결과값 returnList
     */
    @SuppressWarnings("finally")
	public List<DataMap> flagToTableOutbound(List<DataMap> list, DataMap map) throws JCoException
    {
    	main(map);
    	
    	List<DataMap> returnList = new ArrayList();
    	
    	JCoDestination destination = JCoDestinationManager.getDestination(ABAP_AS_POOLED);
    	
    	// ... it always has a reference to a metadata repository
        JCoFunction function = destination.getRepository().getFunction(map.getString("IF_NAME"));
    
        if(function == null)
            throw new RuntimeException("FUNCTION not found in SAP.");
       // List<HashMap> list = new ArrayList();
	   // HashMap paramMap = new HashMap();
	    
        try
        {
	    	JCoTable table = function.getTableParameterList().getTable(map.getString("IF_RETBL"));
	    	DataMap reqMap = new DataMap();
			for(int i = 0; i < list.size(); i++){
				table.appendRow();
				reqMap = list.get(i);
		        
		        Iterator listkeys = reqMap.keySet().iterator();
		    	String listkey = "";
		    	while(listkeys.hasNext()){
		    		listkey = (String) listkeys.next();
		    		table.setValue(listkey, reqMap.get(listkey));
				}
			}
	    	
	    	//execute, i.e. send the function to the ABAP system addressed 
            //by the specified destination, which then returns the function result.
            //All necessary conversions between Java and ABAP data types
            //are done automatically.
            function.execute(destination);
        }
        catch(AbapException e)
        {
        	return returnList;
        }
        
        try 
        {
        	/*
        	// =============== 1. 결과값 받지 않을 경우 ===============
            DataMap returnMapStr = new DataMap();
            returnMapStr.put("REP_FLAG","S"); // 무조건 정상처리
            returnList.add(returnMapStr);
        	*/
        	
        	// =============== 2. 결과값 받을 경우 ================
        	// 리턴받을 Structure 명 설정
        	JCoStructure returnStructure = function.getExportParameterList().getStructure(map.getString("IF_RESTR"));
        	
        	DataMap returnMapStr = new DataMap();
        	JCoFieldIterator jrfitStr = returnStructure.getFieldIterator();
        	JCoField jFieldStr = null;
        	while(jrfitStr.hasNextField()){
        		jFieldStr = jrfitStr.nextField();
        		returnMapStr.put(jFieldStr.getName(), jFieldStr.getValue());
			}
        	
        	// Structure REP_FLAG 컬럼의 값이 S가 아닐때 상세 table 내역 조회
        	if (!returnMapStr.getString("REP_FLAG").equals("S")){
        		
        		// 리턴받을 Table 명 설정
        		JCoTable returnTable = function.getTableParameterList().getTable(map.getString("IF_RETBL"));
    	        
    			int rfcRowNum = returnTable.getNumRows();
    			// Structure REP_FLAG 컬럼의 값이 E 일때 리턴값 첫줄에 저장
        		returnList.add(0, returnMapStr);
        		
    			for(int j = 0; j < rfcRowNum; j++){
    				DataMap returnMap = new DataMap();
    				returnTable.firstRow();
    				JCoFieldIterator jrfit = returnTable.getFieldIterator();
    				JCoField jField = null;
    				while(jrfit.hasNextField()){
    					jField = jrfit.nextField();
    					returnMap.put(jField.getName(), jField.getValue());
    				}
    	
    				returnList.add(j + 1, returnMap);
    				returnTable.deleteRow(0);
    			}
        	} else {
        		// Structure REP_FLAG 컬럼의 값이 S 일때 리턴값 저장
        		returnList.add(returnMapStr);
        	}
        } 
        catch (Exception e) {
			e.printStackTrace();
		}
        finally
        {
        	return returnList;
		}
        
    }
    
    /**
     * map 형태로 넘어온 데이터를 처리한다. 송수신 structure 형식
     * @param map
     * @return
     * @throws JCoException
     */
    /*
     * 순서
     * 1. IF_NAME [function name 설정]
     * 2. paramlist 안에  [FLAG 값 셋팅] 후 SAP 송신
     * 3. IF_RESTR 수신받을 값 [Structure name 설정]
     * 4. returnList에  Structure 값 셋팅
     * 5. 결과값 returnList
     */
    @SuppressWarnings("finally")
	public List<DataMap> flagToStructureInOutbound(DataMap basemap, DataMap map) throws JCoException
    {
    	main(basemap);
    	
    	List<DataMap> returnList = new ArrayList();
    	
    	JCoDestination destination = JCoDestinationManager.getDestination(ABAP_AS_POOLED);
    	
        // ... it always has a reference to a metadata repository
        JCoFunction function = destination.getRepository().getFunction(basemap.getString("IF_NAME"));
    
        if(function == null)
            throw new RuntimeException("FUNCTION not found in SAP.");
       // List<HashMap> list = new ArrayList();
	   // HashMap paramMap = new HashMap();
	    
        try
        {
        	// 요청 flag 값들 송신
	    	JCoParameterList paramlist = function.getImportParameterList();
        	Iterator keys = map.keySet().iterator();
	    	String key = "";
	    	while(keys.hasNext()){
				key = (String) keys.next();
				paramlist.setValue(key, map.get(key));
			}
	    
            //execute, i.e. send the function to the ABAP system addressed 
            //by the specified destination, which then returns the function result.
            //All necessary conversions between Java and ABAP data types
            //are done automatically.
            function.execute(destination);
        }
        catch(AbapException e)
        {
        	return returnList;
        }
        
        try 
        {
        	// 요청에 따른 리턴 Structure name 설정
	        JCoStructure returnStructure = function.getExportParameterList().getStructure(basemap.getString("IF_RESTR"));

	        DataMap returnMap = new DataMap();
			JCoFieldIterator jrfit = returnStructure.getFieldIterator();
			JCoField jField = null;
			while(jrfit.hasNextField()){
				jField = jrfit.nextField();
				returnMap.put(jField.getName(), jField.getValue());
			}
			// returnList 값에  Structure값들 셋팅 
			returnList.add(returnMap);
			returnStructure.clear();
        } 
        catch (Exception e) {
			e.printStackTrace();
		}
        finally
        {
        	return returnList;
		}
    }
    
    /**
     * list 로 넘어온 데이터를 테이블에 담아 처리한다.
     * @param list
     * @param map
     * @return
     * @throws JCoException
     */
    public List<DataMap> tableExecute(ArrayList<DataMap> list, DataMap map) throws JCoException
    {
    	main(map);
    	
    	List<DataMap> returnList = new ArrayList();
    	
    	JCoDestination destination = JCoDestinationManager.getDestination(ABAP_AS_POOLED);
    	
    	// ... it always has a reference to a metadata repository
        JCoFunction function = destination.getRepository().getFunction(map.getString("IF_NAME"));
    
        if(function == null)
            throw new RuntimeException("FUNCTION not found in SAP.");
       // List<HashMap> list = new ArrayList();
	   // HashMap paramMap = new HashMap();
	    
        try
        {
	    	JCoTable table = function.getTableParameterList().getTable(map.getString("IF_RETBL"));
	    	
	    	DataMap reqMap = new DataMap();
	    	for(int i = 0; i < list.size(); i++){
		        table.appendRow();
	        	//JCoParameterList paramlist = function.getImportParameterList();
		        reqMap = list.get(i);
		        
		        Iterator keys = reqMap.keySet().iterator();
		    	String key = "";
		    	while(keys.hasNext()){
					key = (String) keys.next();
					table.setValue(key, reqMap.get(key));
				}
	    	}
	    	
	    	//execute, i.e. send the function to the ABAP system addressed 
            //by the specified destination, which then returns the function result.
            //All necessary conversions between Java and ABAP data types
            //are done automatically.
            function.execute(destination);
        }
        catch(AbapException e)
        {
        	return returnList;
        }
        
        JCoTable returnTable = function.getTableParameterList().getTable(map.getString("IF_RETBL"));
        
		int rfcRowNum = returnTable.getNumRows();
		for(int j = 0; j < rfcRowNum; j++){
			DataMap returnMap = new DataMap();
			returnTable.firstRow();
			JCoFieldIterator jrfit = returnTable.getFieldIterator();
			JCoField jField = null;
			while(jrfit.hasNextField()){
				jField = jrfit.nextField();
				returnMap.put(jField.getName(), jField.getValue());
			}

			returnList.add(j, returnMap);
			returnTable.deleteRow(0);
		}
        
        return returnList;
    }
    
    
    
    /**
     * table / map 사용
     * @param baseMap
     * @param paramMap
     * @param paramList2
     * @return
     * @throws JCoException
     */
    public List<DataMap> dualListExecute(DataMap baseMap, DataMap paramMap, List<DataMap> paramList) throws JCoException
    {
    	main(baseMap);
    	
    	List<DataMap> returnList = new ArrayList();
    	JCoDestination destination = JCoDestinationManager.getDestination(ABAP_AS_POOLED);
    	
        // ... it always has a reference to a metadata repository
        JCoFunction function = destination.getRepository().getFunction(baseMap.getString("IF_NAME"));
    
        if(function == null)
            throw new RuntimeException("FUNCTION not found in SAP.");
       // List<HashMap> list = new ArrayList();
	   // HashMap paramMap = new HashMap();
	    
        try
        {
        	JCoParameterList param = function.getImportParameterList();
        	Iterator keys = paramMap.keySet().iterator();
	    	String key = "";
	    	while(keys.hasNext()){
				key = (String) keys.next();
				param.setValue(key, paramMap.get(key));
			}
	    	
	    	JCoTable table = function.getTableParameterList().getTable(baseMap.getString("IF_FRTBL"));
	    	DataMap reqMap = new DataMap();
			for(int i = 0; i < paramList.size(); i++){
				table.appendRow();
				reqMap = paramList.get(i);
		        
		        Iterator listkeys = reqMap.keySet().iterator();
		    	String listkey = "";
		    	while(listkeys.hasNext()){
		    		listkey = (String) listkeys.next();
		    		table.setValue(listkey, reqMap.get(listkey));
				}
			}
		
            //execute, i.e. send the function to the ABAP system addressed 
            //by the specified destination, which then returns the function result.
            //All necessary conversions between Java and ABAP data types
            //are done automatically.
            function.execute(destination);
        }
        catch(AbapException e)
        {
        	return returnList;
        }
       
        JCoTable returnTable = function.getTableParameterList().getTable(baseMap.getString("IF_RETBL"));
        
        int rfcRowNum = returnTable.getNumRows();
		for(int j = 0; j < rfcRowNum; j++){
			DataMap returnMap = new DataMap();
			returnTable.firstRow();
			JCoFieldIterator jrfit = returnTable.getFieldIterator();
			JCoField jField = null;
			while(jrfit.hasNextField()){
				jField = jrfit.nextField();
				returnMap.put(jField.getName(), jField.getValue());
			}

			returnList.add(j, returnMap);
			returnTable.deleteRow(0);
		}
		
        return returnList;
    }

	/**
	 * SAP호출 TABLE로 로 받지 않음
	 * @param map
	 * @return
	 * @throws JCoException
	 */
	@SuppressWarnings("finally")
	public DataMap flagToTableInboundRTN(DataMap basemap, DataMap map) throws JCoException
	{
		main(basemap);

		DataMap returnList = new DataMap();

		JCoDestination destination = JCoDestinationManager.getDestination(ABAP_AS_POOLED);

		JCoFunction function = destination.getRepository().getFunction(basemap.getString("IF_NAME"));

		if(function == null)
			throw new RuntimeException("FUNCTION not found in SAP.");

		try
		{
			JCoParameterList paramlist = function.getImportParameterList();
			if(paramlist != null){
				Iterator keys = map.keySet().iterator();
				String key = "";
				while(keys.hasNext()){
					key = (String) keys.next();
					paramlist.setValue(key, map.get(key));
				}
			}

			function.execute(destination);
		}
		catch(AbapException e)
		{
			return returnList;
		}

		try
		{
//	        JCoStructure returnStructure = function.getExportParameterList().getStructure("E_RETURN");

			JCoParameterList returnStructure = function.getExportParameterList();

			DataMap returnMapStr = new DataMap();
			JCoFieldIterator jrfitStr = returnStructure.getFieldIterator();
			JCoField jFieldStr = null;
			while(jrfitStr.hasNextField()){
				jFieldStr = jrfitStr.nextField();
				returnMapStr.put(jFieldStr.getName(), jFieldStr.getValue());
			}

			returnList = returnMapStr;
		}
		catch (Exception e) {
			// e.printStackTrace();
			returnList.put("ERRMSG", e.getMessage());
		}
		finally
		{
			return returnList;
		}
	}
    
    public List<DataMap> dummyMapExecute(DataMap map)
    {
    	List<DataMap> returnList = new ArrayList();
    	
		Iterator keys = map.keySet().iterator();
    	String key = "";
    	DataMap returnMap = new DataMap();
    	while(keys.hasNext()){
			key = (String) keys.next();
			returnMap.put(key, map.get(key));
			returnMap.put("CODE", "00");
			returnMap.put("MESSAGE", "Not Connected SAP");
			returnMap.put("MTSNR", "999999999X");
		}
    	returnList.add(0, returnMap);
    	
        return returnList;
    }
    
	public List<DataMap> dummayTableExecute(ArrayList<DataMap> list, DataMap map)
    {
    	List<DataMap> returnList = new ArrayList();
    	
    	DataMap rsMap = new DataMap();
    	for(int i = 0; i < list.size(); i++){
    		rsMap = list.get(i);
    		Iterator keys = rsMap.keySet().iterator();
        	String key = "";
        	DataMap returnMap = new DataMap();
	    	while(keys.hasNext()){
				key = (String) keys.next();
				returnMap.put(key, rsMap.get(key));
				returnMap.put("CODE", "00");
				returnMap.put("MESSAGE", "Not Connected SAP");
				returnMap.put("MTSNR", "999999999X");
			}
	    	returnList.add(i, returnMap);
    	}
    	
        return returnList;
    }
	
	public List<DataMap> dummyDualListExecute(DataMap baseMap, DataMap paramMap, List<DataMap> list)
    {
		List<DataMap> returnList = new ArrayList();
    	
    	DataMap rsMap = new DataMap();
    	for(int i = 0; i < list.size(); i++){
    		rsMap = list.get(i);
    		Iterator keys = rsMap.keySet().iterator();
        	String key = "";
        	DataMap returnMap = new DataMap();
	    	while(keys.hasNext()){
				key = (String) keys.next();
				returnMap.put(key, rsMap.get(key));
				returnMap.put("CODE", "00");
				returnMap.put("MESSAGE", "Not Connected SAP");
				returnMap.put("MTSNR", "999999999X");
			}
	    	returnList.add(i, returnMap);
    	}
    	return returnList;
    }
}
