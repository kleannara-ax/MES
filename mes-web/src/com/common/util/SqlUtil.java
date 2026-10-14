package com.common.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

import org.apache.log4j.Logger;
import org.springframework.orm.ibatis.SqlMapClientTemplate;

import com.common.bean.CommonConfig;
import com.common.bean.DataMap;
import com.common.bean.TableColumn;
import com.ibatis.sqlmap.engine.impl.ExtendedSqlMapClient;
import com.ibatis.sqlmap.engine.mapping.parameter.ParameterMap;
import com.ibatis.sqlmap.engine.mapping.parameter.ParameterMapping;
import com.ibatis.sqlmap.engine.mapping.statement.MappedStatement;
import com.ibatis.sqlmap.engine.scope.SessionScope;
import com.ibatis.sqlmap.engine.scope.StatementScope;

public class SqlUtil {
	private static Logger log = Logger.getLogger(SqlUtil.class);
	
	public void setColumnData(DataMap map, Map model, List<TableColumn> list){
		StringBuilder select = new StringBuilder();
		select.append("SELECT ");
		
		StringBuilder insert = new StringBuilder();
		insert.append("INSERT INTO ").append(map.getString("table")).append(" (");
		
		StringBuilder insertBlank = new StringBuilder();
		
		StringBuilder update = new StringBuilder();
		update.append("UPDATE ").append(map.getString("table")).append(" SET ");
		
		StringBuilder delete = new StringBuilder();
		delete.append("DELETE FROM ").append(map.getString("table"));
		
		StringBuilder bean = new StringBuilder();
		StringBuilder rsmap = new StringBuilder();
		StringBuilder rsdatamap = new StringBuilder();
		
		String alias = map.getString("alias");
		if(!alias.equals("")){
			alias = alias+".";
		}
		
		for(int i=0;i<list.size();i++){
			TableColumn col = list.get(i);					
			if(i!=0){
				if(i%5 == 0){
					insert.append("\n");
				}
				select.append(",");
				insert.append(",");
				//update.append(",");
			}
			select.append("\n\t ").append(alias).append(col.getName());	
			insert.append(col.getName());
			
			update.append("\n<isNotEmpty property=\"").append(col.getName()).append("\"> \n");
			update.append("\n\t ").append(col.getName()).append(" = #").append(col.getName()).append("# ");
			if(i!=(list.size()-1)){
				update.append(",");
			}
			update.append("\n</isNotEmpty> \n");
		}
		select.append("\n FROM ").append(map.getString("table")).append(" ").append(map.getString("alias")).append("\n WHERE \n\t ");
		
		insert.append(") \n VALUES (");
		insertBlank.append(insert);
		
		update.append("\n WHERE \n\t ");
		
		delete.append("\n WHERE \n\t ");
		
		for(int i=0;i<list.size();i++){
			TableColumn col = list.get(i);
			
			if(i!=0){
				if(i%5 == 0){
					insert.append("\n");
					insertBlank.append("\n");
				}
				insert.append(",");
				insertBlank.append(",");
				select.append("\t AND ");
				update.append("\t AND ");
				delete.append("\t AND ");
			}
			select.append(alias).append(col.getName()).append(" = #").append(col.getName()).append("# \n");
			
			update.append(col.getName()).append(" = #").append(col.getName()).append("# \n");
			
			delete.append(col.getName()).append(" = #").append(col.getName()).append("# \n");	
			insert.append("#").append(col.getName()).append("#");
			if(col.getClassName().equals("java.math.BigDecimal")){
				insertBlank.append("'0'");
			}else{
				insertBlank.append("' '");
			}			
			
			String[] nameList = col.getLabel().toLowerCase().split("_");
			bean.append("\tprivate String ").append(nameList[0]);
			rsmap.append("\t\t<result property=\"").append(nameList[0]);
			rsdatamap.append("\t\t<result property=\"").append(col.getLabel());
			for(int j=1;j<nameList.length;j++){
				bean.append(nameList[j].substring(0,1).toUpperCase()).append(nameList[j].substring(1));
				rsmap.append(nameList[j].substring(0,1).toUpperCase()).append(nameList[j].substring(1));
			}
			bean.append(";\n");
			rsmap.append("\" column=\"").append(col.getLabel()).append("\"/>\n");
			rsdatamap.append("\" column=\"").append(col.getLabel()).append("\"/>\n");
		}
		insert.append(")");
		insertBlank.append(")");
		
		model.put("select", select.toString());
		model.put("insert", insert.toString());
		model.put("insertBlank", insertBlank.toString());
		model.put("update", update.toString());
		model.put("del", delete.toString());
		model.put("bean", bean.toString());
		model.put("rsmap", rsmap.toString());
		model.put("rsdatamap", rsdatamap.toString());
	}
	
	public String getListSqlString(SqlMapClientTemplate sqlMapClientTemplate, DataMap map) throws SQLException{
		return getListSql(sqlMapClientTemplate, map).getString("sql");
	}
	
	public DataMap getListSql(SqlMapClientTemplate sqlMapClientTemplate, DataMap map) throws SQLException{
		//return getSql(map.getListCommand(), map);
		DataMap sqlData = getExecutorQuery(sqlMapClientTemplate, map.getListCommand(), map);
		log.debug(sqlData.getString("log"));
		return sqlData;
	}
	
	private DataMap getExecutorQuery( SqlMapClientTemplate sqlMapClientTemplate, 
	        String statementId, Map parameters) throws SQLException{ 
	    SessionScope sessionScope = new SessionScope();
	    sessionScope.setSqlMapClient(sqlMapClientTemplate.getSqlMapClient()); 
	    StatementScope statementScope = new StatementScope(sessionScope); 

	    ExtendedSqlMapClient extendedSqlMapClient 
	            = (ExtendedSqlMapClient) sqlMapClientTemplate.getSqlMapClient(); 
	    MappedStatement mappedStatement 
	            = extendedSqlMapClient.getMappedStatement(statementId); 
	    mappedStatement.initRequest(statementScope); 
	    
	    Integer fetchSize = mappedStatement.getFetchSize();
	    if(fetchSize != null){
	    	parameters.put("fetchSize", fetchSize);
	    }
	    
	    ParameterMap parameterMap 
	            = mappedStatement.getSql().getParameterMap(statementScope, parameters); 

	    Object[] bindParameter 
	            = parameterMap.getParameterObjectValues(statementScope, parameters); 
	    ParameterMapping[] parameterMappinge = parameterMap.getParameterMappings(); 
	    String preparedStatement 
	            = mappedStatement.getSql().getSql(statementScope, parameters); 
	    String sqlLog = preparedStatement;

	    List paramList = new ArrayList();
	    for (int i = 0 ; i < bindParameter.length ; i ++) { 
	    	if(parameterMappinge[i].getPropertyName().indexOf(CommonConfig.RANGE_PRE_SQL_KEY) != -1){
	    		preparedStatement = preparedStatement.replaceFirst("[?]",bindParameter[i].toString());
	    		String tailStr = parameterMappinge[i].getPropertyName().substring(CommonConfig.RANGE_PRE_SQL_KEY.length());
	    		List rangeParamList = (List)parameters.get(CommonConfig.RANGE_PRE_PARAM_KEY+tailStr);
		    	paramList.addAll(rangeParamList);
		    	sqlLog = sqlLog.replaceFirst("[?]", parameters.get(CommonConfig.RANGE_SQL_KEY+tailStr).toString());
	    	}else{
	    		preparedStatement = preparedStatement.replaceFirst("[?]",CommonConfig.DATA_CELL_SEPARATOR);
		    	paramList.add(bindParameter[i].toString());
		    	sqlLog = sqlLog.replaceFirst("[?]", "'" + bindParameter[i].toString() + "'");
	    	}	    	
	    	
	    	/*
	        if (parameterMappinge[i].getJdbcType() == 0) { 
	            preparedStatement 
	                = preparedStatement.replaceFirst("[?]", "'" + 
	                      bindParameter[i].toString() + "'");	   	
	        } else { 
	            preparedStatement = preparedStatement.replaceFirst("[?]", 
	                bindParameter[i].toString()); 
	        }
	        */
	    }
	    DataMap sqlData = new DataMap();
	    sqlData.put("log", StringUtility.singleSpaceReturn(sqlLog));
	    sqlData.put("sql", StringUtility.singleSpaceReturn(preparedStatement).replaceAll(CommonConfig.DATA_CELL_SEPARATOR, "?"));
	    sqlData.put("param", paramList);
	    return sqlData;
	}
	
	public String getJdbcData(DataSource dataSource, String sql, Integer fetchSize) throws SQLException{
		return getJdbcData(dataSource, sql, fetchSize, new ArrayList());
	}
	public String getJdbcData(DataSource dataSource, String sql, Integer fetchSize, List list) throws SQLException{
		Connection conn = null;
		PreparedStatement psmt = null;
		ResultSet rs = null;
		StringBuilder sb = new StringBuilder();
		try{
			conn = dataSource.getConnection();
			psmt = conn.prepareStatement(sql);
			if(fetchSize != null){
				psmt.setFetchSize(fetchSize);
			}
			for(int i=0;i<list.size();i++){
				psmt.setObject(i+1, list.get(i));
			}
			rs = psmt.executeQuery();
			
			ResultSetMetaData rsmd = rs.getMetaData();
			
			for(int i=0;i<rsmd.getColumnCount();i++){
				sb.append(rsmd.getColumnName(i+1));
				if(i<rsmd.getColumnCount()-1){
					sb.append("↓");
				}
			}
			sb.append("↑");
			
			while(rs.next()){				
				for(int i=0;i<rsmd.getColumnCount();i++){
					Object obj = rs.getObject(i+1);
					//String value = rs.getString(i+1);
					String value;
					if(obj == null){
						value = " ";
					}else{
						value = obj.toString();
					}
					sb.append(value);
					if(i<rsmd.getColumnCount()-1){
						sb.append("↓");
					}
				}
				sb.append("↑");
			}
		}catch(SQLException e){
			e.printStackTrace();
			throw e;
		}finally{
			try {
				if(rs != null){
					rs.close();
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
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
		if(sb.length() > 0){
			return sb.substring(0,sb.length()-1);
		}else{
			return "";
		}
	}
	
	public void removeRangeKey(DataMap rangeMap, String key){
		if(rangeMap.containsKey(key+"_"+CommonConfig.RANGE_TYPE_SINGLE)){
			rangeMap.remove(key+"_"+CommonConfig.RANGE_TYPE_SINGLE);
		}
		if(rangeMap.containsKey(key+"_"+CommonConfig.RANGE_TYPE_RANGE)){
			rangeMap.remove(key+"_"+CommonConfig.RANGE_TYPE_RANGE);
		}
	}
	
	public void changeRangeKey(DataMap rangeMap, String origKey, String chnagKey){
		if(rangeMap.containsKey(origKey+"_"+CommonConfig.RANGE_TYPE_SINGLE)){
			rangeMap.put(chnagKey+"_"+CommonConfig.RANGE_TYPE_SINGLE, rangeMap.get(origKey+"_"+CommonConfig.RANGE_TYPE_SINGLE));
			rangeMap.remove(origKey+"_"+CommonConfig.RANGE_TYPE_SINGLE);
		}
		if(rangeMap.containsKey(origKey+"_"+CommonConfig.RANGE_TYPE_RANGE)){
			rangeMap.put(chnagKey+"_"+CommonConfig.RANGE_TYPE_RANGE, rangeMap.get(origKey+"_"+CommonConfig.RANGE_TYPE_RANGE));
			rangeMap.remove(origKey+"_"+CommonConfig.RANGE_TYPE_RANGE);
		}
	}
	
	public DataMap createRangeMap(DataMap rangeMap, List keyList){
		DataMap newRangeMap = new DataMap();
		for(int i=0;i<keyList.size();i++){
			if(rangeMap.containsKey(keyList.get(i)+"_"+CommonConfig.RANGE_TYPE_SINGLE)){
				newRangeMap.put(keyList.get(i)+"_"+CommonConfig.RANGE_TYPE_SINGLE, rangeMap.get(keyList.get(i)+"_"+CommonConfig.RANGE_TYPE_SINGLE));
			}
			if(rangeMap.containsKey(keyList.get(i)+"_"+CommonConfig.RANGE_TYPE_RANGE)){
				newRangeMap.put(keyList.get(i)+"_"+CommonConfig.RANGE_TYPE_RANGE, rangeMap.get(keyList.get(i)+"_"+CommonConfig.RANGE_TYPE_RANGE));
			}
		}
		return newRangeMap;
	}
	
	public String getRangeSql(DataMap rangeMap){
		if(rangeMap == null){
			return "";
		}
		Iterator it = rangeMap.keySet().iterator();
		StringBuilder sb = new StringBuilder();
		while(it.hasNext()){
			String key = it.next().toString();
			if(key.indexOf("_"+CommonConfig.RANGE_TYPE_SINGLE) != -1){
				List<DataMap> sList = rangeMap.getList(key);
				key = key.substring(0, key.indexOf("_"+CommonConfig.RANGE_TYPE_SINGLE));
				DataMap smap;
				if(sb.length() > 0){
					sb.append(" AND ( ");
				}else{
					sb.append(" ( ");
				}
				for(int i=0;i<sList.size();i++){
					smap = sList.get(i);
					if(i!=0){
						if(!smap.containsKey(CommonConfig.RNAGE_LOGICAL_OPERATOR_KEY)){
							smap.put(CommonConfig.RNAGE_LOGICAL_OPERATOR_KEY, "OR");
						}
						sb.append(" ").append(smap.getString(CommonConfig.RNAGE_LOGICAL_OPERATOR_KEY)).append(" ");
					}
					String fromVal = smap.getString(CommonConfig.RNAGE_SINGLE_DATA_KEY);
					fromVal = sqlFilter(fromVal);
					String operVal = smap.getString(CommonConfig.RNAGE_OPERATOR_KEY);
					if(fromVal.indexOf("%") != -1){
						sb.append(" ( ").append(key).append(" like '").append(fromVal).append("' ) ");
					}else{
						sb.append(" ( ").append(key).append(" ").append(operVal).append(" \u0027").append(fromVal).append("\u0027 ) ");
					}
				}
				sb.append(" ) ");
			}else if(key.indexOf("_"+CommonConfig.RANGE_TYPE_RANGE) != -1){
				List<DataMap> sList = rangeMap.getList(key);
				key = key.substring(0, key.indexOf("_"+CommonConfig.RANGE_TYPE_RANGE));
				DataMap smap;
				if(sb.length() > 0){
					sb.append(" AND ( ");
				}else{
					sb.append(" ( ");
				}
				for(int i=0;i<sList.size();i++){
					smap = sList.get(i);
					if(i!=0){
						sb.append(" OR ");
					}
					String fromVal = smap.getString(CommonConfig.RNAGE_FROM_KEY);
					fromVal = sqlFilter(fromVal);
					String toVal = smap.getString(CommonConfig.RNAGE_TO_KEY);
					toVal = sqlFilter(toVal);
					String operVal = smap.getString(CommonConfig.RNAGE_OPERATOR_KEY);
					if(operVal == "N"){
						sb.append(" ( ").append(key).append(" < '").append(fromVal).append("' OR ").append(key).append(" > '").append(toVal).append("' ) ");
					}else{
						sb.append(" ( ").append(key).append(" >= \u0027").append(fromVal).append("\u0027 AND ").append(key).append(" <= \u0027").append(toVal).append("\u0027 ) ");
					}
				}
				sb.append(" ) ");
			}
		}
		return sb.toString();
	}
	
	public void setRangeSql(DataMap params){
		if(params.containsKey(CommonConfig.RNAGE_DATA_PARAM_KEY)){
			DataMap operMap = new DataMap();
			operMap.put("E", "=");
			operMap.put("N", "!=");
			operMap.put("LT", "<");
			operMap.put("GT", ">");
			operMap.put("LE", "<=");
			operMap.put("GE", ">=");
			DataMap rParam = params.getMap(CommonConfig.RNAGE_DATA_PARAM_KEY).getMap("map");
			DataMap rangeData = new DataMap();
			Iterator it = rParam.keySet().iterator();
			StringBuilder sb = new StringBuilder();
			StringBuilder paramSb = new StringBuilder();
			List paramList = new ArrayList();
			String logical;
			while(it.hasNext()){
				String key = it.next().toString();
				String val = rParam.getString(key);
				if(key.indexOf("_"+CommonConfig.RANGE_TYPE_SINGLE) != -1){
					List sList = new ArrayList();
					key = key.substring(0, key.indexOf("_"+CommonConfig.RANGE_TYPE_SINGLE));
					String[] rows = val.split(CommonConfig.DATA_ROW_SEPARATOR);
					if(sb.length() > 0){
						sb.append(" AND ( ");
						paramSb.append(" AND ( ");
					}else{
						sb.append(" ( ");
						paramSb.append(" ( ");
					}						
					for(int i=0;i<rows.length;i++){		
						DataMap sMap = new DataMap();
						String[] cols = rows[i].split(CommonConfig.DATA_COL_SEPARATOR);
						if(cols[0].equals("")){
							cols[0] = "E";
						}
						if(cols.length == 2){
							logical = "OR";
						}else if(!cols[2].equals("OR") && !cols[2].equals("AND")){
							logical = "OR";
						}else{
							logical = cols[2];
						}
						if(i!=0){
							sb.append(" ").append(logical).append(" ");
							paramSb.append(" ").append(logical).append(" ");
						}
						String fromVal = cols[1];
						fromVal = sqlFilter(fromVal);
						String operVal = operMap.getString(cols[0]);
						
						sMap.put(CommonConfig.RNAGE_LOGICAL_OPERATOR_KEY, logical);
						sMap.put(CommonConfig.RNAGE_OPERATOR_KEY, operVal);
						sMap.put(CommonConfig.RNAGE_SINGLE_DATA_KEY, fromVal);
						sList.add(sMap);
						if(fromVal.indexOf("%") != -1){
							if(cols[0].equals("N")) {
								sb.append(" ( ").append(key).append(" not like '").append(fromVal).append("' ) ");
								paramSb.append(" ( ").append(key).append(" not like '%' || ? || '%' ) ");
								paramList.add(fromVal);
							}else{
								sb.append(" ( ").append(key).append(" like '").append(fromVal).append("' ) ");
								paramSb.append(" ( ").append(key).append(" like '%' || ? || '%' ) ");
								paramList.add(fromVal);
							}							
						}else{
							sb.append(" ( ").append(key).append(" ").append(operVal).append(" \u0027").append(fromVal).append("\u0027 ) ");
							paramSb.append(" ( ").append(key).append(" ").append(operVal).append(" ? ) ");
							paramList.add(fromVal);
						}
					}
					sb.append(" ) ");
					paramSb.append(" ) ");
					rangeData.put(key+"_"+CommonConfig.RANGE_TYPE_SINGLE, sList);
				}else if(key.indexOf("_"+CommonConfig.RANGE_TYPE_RANGE) != -1){
					List sList = new ArrayList();
					key = key.substring(0, key.indexOf("_"+CommonConfig.RANGE_TYPE_RANGE));
					String[] rows = val.split(CommonConfig.DATA_ROW_SEPARATOR);
					if(sb.length() > 0){
						sb.append(" AND ( ");
						paramSb.append(" AND ( ");
					}else{
						sb.append(" ( ");
						paramSb.append(" ( ");
					}
					for(int i=0;i<rows.length;i++){
						DataMap sMap = new DataMap();
						if(i!=0){
							sb.append(" OR ");
							paramSb.append(" OR ");
						}
						String[] cols = rows[i].split(CommonConfig.DATA_COL_SEPARATOR);
						if(cols[0].equals("")){
							cols[0] = "E";
						}
						String fromVal = cols[1];
						fromVal = sqlFilter(fromVal);
						String toVal = cols[2];
						toVal = sqlFilter(toVal);
						String operVal = cols[0];
						sMap.put(CommonConfig.RNAGE_OPERATOR_KEY, operVal);
						sMap.put(CommonConfig.RNAGE_FROM_KEY, fromVal);
						sMap.put(CommonConfig.RNAGE_TO_KEY, toVal);
						sList.add(sMap);
						if(operVal == "N"){
							sb.append(" ( ").append(key).append(" < '").append(fromVal).append("' OR ").append(key).append(" > '").append(toVal).append("' ) ");
							paramSb.append(" ( ").append(key).append(" < ? OR ").append(key).append(" > ? ) ");
							paramList.add(fromVal);
							paramList.add(toVal);
						}else{
							sb.append(" ( ").append(key).append(" >= \u0027").append(fromVal).append("\u0027 AND ").append(key).append(" <= \u0027").append(toVal).append("\u0027 ) ");
							paramSb.append(" ( ").append(key).append(" >= ? AND ").append(key).append(" <= ? ) ");
							paramList.add(fromVal);
							paramList.add(toVal);
						}
					}
					sb.append(" ) ");
					paramSb.append(" ) ");
					rangeData.put(key+"_"+CommonConfig.RANGE_TYPE_RANGE, sList);
				}
			}
			if(sb.length() > 0){
				if(params.containsKey(CommonConfig.RANGE_SQL_KEY)){
					params.put(CommonConfig.RANGE_SQL_KEY, params.get(CommonConfig.RANGE_SQL_KEY)+" AND ( "+sb.toString()+" ) ");
					params.put(CommonConfig.RANGE_PRE_SQL_KEY, params.get(CommonConfig.RANGE_PRE_SQL_KEY)+" AND ( "+paramSb.toString()+" ) ");
				}else{
					params.put(CommonConfig.RANGE_SQL_KEY, " AND ( "+sb.toString()+" ) ");
					params.put(CommonConfig.RANGE_PRE_SQL_KEY, " AND ( "+paramSb.toString()+" ) ");
				}
			}
			
			params.put(CommonConfig.RANGE_PRE_PARAM_KEY, paramList);			
			params.put(CommonConfig.RNAGE_DATA_MAP, rangeData);
			params.remove(CommonConfig.RNAGE_DATA_PARAM_KEY);
		}
	}
	
	public String sqlFilter(String value){
		if(value.indexOf("'") != -1){
			return value.replaceAll("'", "\"");
		}
		
		return value;
	}
}
