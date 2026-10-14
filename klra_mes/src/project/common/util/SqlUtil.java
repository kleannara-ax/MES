package project.common.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

import org.apache.ibatis.mapping.ParameterMapping;
import org.apache.ibatis.session.SqlSession;

import project.common.bean.CommonConfig;
import project.common.bean.DataMap;
import project.common.bean.TableColumn;

public class SqlUtil {
	
	private DataMap operMap;
	public SqlUtil(){
		operMap = new DataMap();
		operMap.put("", "=");
		operMap.put("E", "=");
		operMap.put("N", "!=");
		operMap.put("LT", "<");
		operMap.put("GT", ">");
		operMap.put("LE", "<=");
		operMap.put("GE", ">=");
	}
	
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
			select.append("\n\t").append(alias).append(col.getName());	
			insert.append(col.getName());
			
			//update.append("\n<isNotEmpty property=\"").append(col.getName()).append("\"> \n");
			update.append("\n\t").append(col.getName()).append(" = #").append(col.getName()).append("# ");
			if(i!=(list.size()-1)){
				update.append(",");
			}
			//update.append("\n</isNotEmpty> \n");
		}
		select.append("\nFROM ").append(map.getString("table")).append(" ").append(map.getString("alias")).append("\n WHERE \n\t ");
		
		insert.append(") \nVALUES (");
		insertBlank.append(insert);
		
		update.append("\nWHERE \n\t ");
		
		delete.append("\nWHERE \n\t ");
		
		for(int i=0;i<list.size();i++){
			TableColumn col = list.get(i);
			
			if(i!=0){
				if(i%5 == 0){
					insert.append("\n");
					insertBlank.append("\n");
				}
				insert.append(",");
				insertBlank.append(",");
				select.append("\tAND ");
				update.append("\tAND ");
				delete.append("\tAND ");
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
			rsmap.append("\"column=\"").append(col.getLabel()).append("\"/>\n");
			rsdatamap.append("\"column=\"").append(col.getLabel()).append("\"/>\n");
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
	
	public String getJdbcData(DataSource dataSource, String sql) throws SQLException{
		Connection conn = null;
		PreparedStatement psmt = null;
		ResultSet rs = null;
		StringBuilder sb = new StringBuilder();
		try{
			conn = dataSource.getConnection();
			psmt = conn.prepareStatement(sql);
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
						//value = " ";
						value = CommonConfig.DATA_COL_EMPTY_VALUE;
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
	
	public String getJdbcDataP(DataSource dataSource, DataMap pdata) throws SQLException{
		Connection conn = null;
		PreparedStatement psmt = null;
		ResultSet rs = null;
		StringBuilder sb = new StringBuilder();
		try{
			conn = dataSource.getConnection();
			psmt = conn.prepareStatement(pdata.getString("sql"));
			List paramValueList = (List)pdata.get("paramValueList");
			Object param;
			for(int i=0;i<paramValueList.size();i++){
				param = paramValueList.get(i);
				psmt.setString(i+1, param.toString());
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
						//value = " ";
						value = CommonConfig.DATA_COL_EMPTY_VALUE;
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
	
	public DataMap setRangeParamSql(String key, DataMap rParam){
		DataMap rangeData = new DataMap();
		StringBuilder sb = new StringBuilder(10000);
		StringBuilder paramSb = new StringBuilder(10000);
		List paramList = new ArrayList();
		key = rangeData.sqlFilter(key);
		String val = rParam.getString(key);
		if(key.indexOf("_"+CommonConfig.RANGE_TYPE_SINGLE) != -1){
			List sList = new ArrayList();
			key = key.substring(0, key.indexOf("_"+CommonConfig.RANGE_TYPE_SINGLE));
			String[] rows = val.split(CommonConfig.DATA_ROW_SEPARATOR);
			
			sb.append(" ( ");
			paramSb.append(" ( ");
			
			for(int i=0;i<rows.length;i++){		
				DataMap sMap = new DataMap();
				String[] cols = rows[i].split(CommonConfig.DATA_COL_SEPARATOR);
				if(cols.length != 3){
					continue;
				}
				if(i!=0){
					sb.append(' ').append(cols[2]).append(' ');
					paramSb.append(' ').append(cols[2]).append(' ');
				}
				String fromVal = cols[1];
				fromVal = rangeData.sqlFilter(fromVal);
				String operVal = operMap.getString(cols[0]);
				if(!cols[2].equals("OR") && !cols[2].equals("AND")){
					cols[2] = "OR";
				}
				sMap.put(CommonConfig.RNAGE_LOGICAL_OPERATOR_KEY, cols[2]);
				sMap.put(CommonConfig.RNAGE_OPERATOR_KEY, operVal);
				sMap.put(CommonConfig.RNAGE_SINGLE_DATA_KEY, fromVal);
				sList.add(sMap);
				if(fromVal.substring(fromVal.length()-1).equals("%")){
					if(cols[0].equals("N")) {
						sb.append(" ( ").append(key).append(" not like '").append(fromVal).append("' ) ");
						paramSb.append(" ( ").append(key).append(" not like '%' || ").append(CommonConfig.DATA_CELL_SEPARATOR).append(" || '%' ) ");
						paramList.add(fromVal.substring(0, fromVal.length()-1));
					}else{
						sb.append(" ( ").append(key).append(" like '").append(fromVal).append("' ) ");
						paramSb.append(" ( ").append(key).append(" like '%' || ").append(CommonConfig.DATA_CELL_SEPARATOR).append(" || '%' ) ");
						paramList.add(fromVal.substring(0, fromVal.length()-1));
					}							
				}else{
					sb.append(" ( ").append(key).append(' ').append(operVal).append(" \u0027").append(fromVal).append("\u0027 ) ");
					paramSb.append(" ( ").append(key).append(' ').append(operVal).append(' ').append(CommonConfig.DATA_CELL_SEPARATOR).append(" ) ");
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
			
			sb.append(" ( ");
			paramSb.append(" ( ");
			
			for(int i=0;i<rows.length;i++){
				DataMap sMap = new DataMap();
				if(i!=0){
					sb.append(" OR ");
					paramSb.append(" OR ");
				}
				String[] cols = rows[i].split(CommonConfig.DATA_COL_SEPARATOR);
				if(cols.length != 3){
					continue;
				}
				String fromVal = cols[1];
				fromVal = rangeData.sqlFilter(fromVal);
				String toVal = cols[2];
				toVal = rangeData.sqlFilter(toVal);
				String operVal = cols[0];
				sMap.put(CommonConfig.RNAGE_OPERATOR_KEY, operVal);
				sMap.put(CommonConfig.RNAGE_FROM_KEY, fromVal);
				sMap.put(CommonConfig.RNAGE_TO_KEY, toVal);
				sList.add(sMap);
				if(operVal.equals("N")){
					sb.append(" ( ").append(key).append(" < '").append(fromVal).append("' OR ").append(key).append(" > '").append(toVal).append("' ) ");
					paramSb.append(" ( ").append(key).append(" < ").append(CommonConfig.DATA_CELL_SEPARATOR).append(" OR ").append(key).append(" > ").append(CommonConfig.DATA_CELL_SEPARATOR).append(" ) ");
					paramList.add(fromVal);
					paramList.add(toVal);
				}else{
					sb.append(" ( ").append(key).append(" >= \u0027").append(fromVal).append("\u0027 AND ").append(key).append(" <= \u0027").append(toVal).append("\u0027 ) ");
					paramSb.append(" ( ").append(key).append(" >= ").append(CommonConfig.DATA_CELL_SEPARATOR).append(" AND ").append(key).append(" <= ").append(CommonConfig.DATA_CELL_SEPARATOR).append(" ) ");
					paramList.add(fromVal);
					paramList.add(toVal);
				}
			}
			sb.append(" ) ");
			paramSb.append(" ) ");
			rangeData.put(key+"_"+CommonConfig.RANGE_TYPE_RANGE, sList);
		}
		
		DataMap params = new DataMap();
		
		if(sb.length() > 0){
			//params.put(CommonConfig.RANGE_SQL_KEY, " AND ( "+sb.toString()+" ) ");
			//params.put(CommonConfig.RANGE_PRE_SQL_KEY, " AND ( "+paramSb.toString()+" ) ");
			params.put(CommonConfig.RANGE_SQL_KEY, " ( "+sb.toString()+" ) ");
			params.put(CommonConfig.RANGE_PRE_SQL_KEY, " ( "+paramSb.toString()+" ) ");
		}
		
		params.put(CommonConfig.RANGE_PRE_PARAM_KEY, paramList);
		params.put(CommonConfig.RNAGE_DATA_MAP, rangeData);
		
		return params;
	}

	public void setRangeSql(DataMap params){
		if(params.containsKey(CommonConfig.INPUT_PARAM_GROUP)){			
			//DataMap rangeGroupData = new DataMap();
			DataMap rangeParamData = new DataMap();
			if(params.containsKey(CommonConfig.RNAGE_DATA_PARAM_KEY)){
				//params.setSqlType(true);
				DataMap rParam = params.getMap(CommonConfig.RNAGE_DATA_PARAM_KEY);
				Iterator it = rParam.keySet().iterator();
				rParam.setSqlType(true);
				DataMap paramRange;				
				StringBuilder sb = new StringBuilder(10000);
				StringBuilder paramSb = new StringBuilder(10000);
				DataMap rangeData = new DataMap();
				List paramList = new ArrayList();
				while(it.hasNext()){
					String key = it.next().toString();
					paramRange = setRangeParamSql(key, rParam);
					
					if(paramRange.containsKey(CommonConfig.RANGE_SQL_KEY)){
						if(sb.length() > 0){
							sb.append(" AND ");
							paramSb.append(" AND ");
						}
						sb.append(paramRange.getString(CommonConfig.RANGE_SQL_KEY));
						paramSb.append(paramRange.getString(CommonConfig.RANGE_PRE_SQL_KEY));
						paramList.addAll(paramRange.getList(CommonConfig.RANGE_PRE_PARAM_KEY));
						rangeData.putAll(paramRange.getMap(CommonConfig.RNAGE_DATA_MAP));
						
						rangeParamData.put(key, paramRange);
					}
			
				}
				if(sb.length() > 0){
					params.put(CommonConfig.RANGE_SQL_KEY, " AND ( "+sb.toString()+" ) ");
					params.put(CommonConfig.RANGE_PRE_SQL_KEY, " AND ( "+paramSb.toString()+" ) ");
				}
				
				params.put(CommonConfig.RANGE_PRE_PARAM_KEY, paramList);
				params.put(CommonConfig.RNAGE_DATA_MAP, rangeData);
				params.remove(CommonConfig.RNAGE_DATA_PARAM_KEY);
				
				DataMap pGroup = params.getMap(CommonConfig.INPUT_PARAM_GROUP);
				it = pGroup.keySet().iterator();
				List<String> pGroupParamList;
				String keyName;
				while(it.hasNext()){
					String key = it.next().toString();
					pGroupParamList = pGroup.getList(key);
					sb = new StringBuilder(10000);
					paramSb = new StringBuilder(10000);
					rangeData = new DataMap();
					paramList = new ArrayList();
					for(int i=0;i<pGroupParamList.size();i++){
						keyName = pGroupParamList.get(i)+"_"+CommonConfig.RANGE_TYPE_SINGLE;
						if(rangeParamData.containsKey(keyName)){
							paramRange = (DataMap)rangeParamData.get(keyName);
							if(sb.length() > 0){
								sb.append(" AND ");
								paramSb.append(" AND ");
							}
							sb.append(paramRange.getString(CommonConfig.RANGE_SQL_KEY));
							paramSb.append(paramRange.getString(CommonConfig.RANGE_PRE_SQL_KEY));
							paramList.addAll(paramRange.getList(CommonConfig.RANGE_PRE_PARAM_KEY));
							rangeData.putAll(paramRange.getMap(CommonConfig.RNAGE_DATA_MAP));
						}
						keyName = pGroupParamList.get(i)+"_"+CommonConfig.RANGE_TYPE_RANGE;
						if(rangeParamData.containsKey(keyName)){
							paramRange = (DataMap)rangeParamData.get(keyName);
							if(sb.length() > 0){
								sb.append(" AND ");
								paramSb.append(" AND ");
							}
							sb.append(paramRange.getString(CommonConfig.RANGE_SQL_KEY));
							paramSb.append(paramRange.getString(CommonConfig.RANGE_PRE_SQL_KEY));
							paramList.addAll(paramRange.getList(CommonConfig.RANGE_PRE_PARAM_KEY));
							rangeData.putAll(paramRange.getMap(CommonConfig.RNAGE_DATA_MAP));
						}
					}
					
					if(sb.length() > 0){
						params.put(CommonConfig.RANGE_SQL_KEY+"_"+key, " AND ( "+sb.toString()+" ) ");
						params.put(CommonConfig.RANGE_PRE_SQL_KEY+"_"+key, " AND ( "+paramSb.toString()+" ) ");
						params.put(CommonConfig.RANGE_PRE_PARAM_KEY+"_"+key, paramList);
					}					
				}
			}
		}else{
			setRangeSqlStd(params);
		}	
	}
	
	public void setRangeSqlStd(DataMap params){
		if(params.containsKey(CommonConfig.RNAGE_DATA_PARAM_KEY)){
			//params.setSqlType(true);
			DataMap rParam = params.getMap(CommonConfig.RNAGE_DATA_PARAM_KEY);
			rParam.setSqlType(true);
			DataMap rangeData = new DataMap();
			Iterator it = rParam.keySet().iterator();
			StringBuilder sb = new StringBuilder(10000);
			StringBuilder paramSb = new StringBuilder(10000);
			List paramList = new ArrayList();
			while(it.hasNext()){
				String key = it.next().toString();
				key = rangeData.sqlFilter(key);
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
						if(cols.length < 2){
							continue;
						}else if(cols.length == 2){
							rows[i] = rows[i] + "OR";
							cols = rows[i].split(CommonConfig.DATA_COL_SEPARATOR);
						}
						
						if(i!=0){
							sb.append(' ').append(cols[2]).append(' ');
							paramSb.append(' ').append(cols[2]).append(' ');
						}
						String fromVal = cols[1];
						fromVal = rangeData.sqlFilter(fromVal);
						String operVal = operMap.getString(cols[0]);
						if(!cols[2].equals("OR") && !cols[2].equals("AND")){
							cols[2] = "OR";
						}
						sMap.put(CommonConfig.RNAGE_LOGICAL_OPERATOR_KEY, cols[2]);
						sMap.put(CommonConfig.RNAGE_OPERATOR_KEY, operVal);
						sMap.put(CommonConfig.RNAGE_SINGLE_DATA_KEY, fromVal);
						sList.add(sMap);
						if(fromVal.substring(fromVal.length()-1).equals("%")){
							if(cols[0].equals("N")) {
								sb.append(" ( ").append(key).append(" not like '").append(fromVal).append("' ) ");
								paramSb.append(" ( ").append(key).append(" not like '%' || ").append(CommonConfig.DATA_CELL_SEPARATOR).append(" || '%' ) ");
								paramList.add(fromVal.substring(0, fromVal.length()-1));
							}else{
								sb.append(" ( ").append(key).append(" like '").append(fromVal).append("' ) ");
								paramSb.append(" ( ").append(key).append(" like '%' || ").append(CommonConfig.DATA_CELL_SEPARATOR).append(" || '%' ) ");
								paramList.add(fromVal.substring(0, fromVal.length()-1));
							}							
						}else{
							sb.append(" ( ").append(key).append(' ').append(operVal).append(" \u0027").append(fromVal).append("\u0027 ) ");
							paramSb.append(" ( ").append(key).append(' ').append(operVal).append(' ').append(CommonConfig.DATA_CELL_SEPARATOR).append(" ) ");
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
						if(cols.length != 3){
							continue;
						}
						
						if(cols[0].equals("")){
							cols[0] = "E";
						}
						String fromVal = cols[1];
						fromVal = rangeData.sqlFilter(fromVal);
						String toVal = cols[2];
						toVal = rangeData.sqlFilter(toVal);
						String operVal = cols[0];
						sMap.put(CommonConfig.RNAGE_OPERATOR_KEY, operVal);
						sMap.put(CommonConfig.RNAGE_FROM_KEY, fromVal);
						sMap.put(CommonConfig.RNAGE_TO_KEY, toVal);
						sList.add(sMap);
						if(operVal.equals("N")){
							sb.append(" ( ").append(key).append(" < '").append(fromVal).append("' OR ").append(key).append(" > '").append(toVal).append("' ) ");
							paramSb.append(" ( ").append(key).append(" < ").append(CommonConfig.DATA_CELL_SEPARATOR).append(" OR ").append(key).append(" > ").append(CommonConfig.DATA_CELL_SEPARATOR).append(" ) ");
							paramList.add(fromVal);
							paramList.add(toVal);
						}else{
							sb.append(" ( ").append(key).append(" >= \u0027").append(fromVal).append("\u0027 AND ").append(key).append(" <= \u0027").append(toVal).append("\u0027 ) ");
							paramSb.append(" ( ").append(key).append(" >= ").append(CommonConfig.DATA_CELL_SEPARATOR).append(" AND ").append(key).append(" <= ").append(CommonConfig.DATA_CELL_SEPARATOR).append(" ) ");
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
				params.put(CommonConfig.RANGE_SQL_KEY, " AND ( "+sb.toString()+" ) ");
				params.put(CommonConfig.RANGE_PRE_SQL_KEY, " AND ( "+paramSb.toString()+" ) ");
			}
			
			params.put(CommonConfig.RANGE_PRE_PARAM_KEY, paramList);
			params.put(CommonConfig.RNAGE_DATA_MAP, rangeData);
			params.remove(CommonConfig.RNAGE_DATA_PARAM_KEY);
		}
	}
	
	public void setRangeSqlOld(DataMap params){
		if(params.containsKey(CommonConfig.RNAGE_DATA_PARAM_KEY)){
			DataMap operMap = new DataMap();
			operMap.put("E", "=");
			operMap.put("N", "!=");
			operMap.put("LT", "<");
			operMap.put("GT", ">");
			operMap.put("LE", "<=");
			operMap.put("GE", ">=");
			DataMap rParam = params.getMap(CommonConfig.RNAGE_DATA_PARAM_KEY);
			DataMap rangeData = new DataMap();
			Iterator it = rParam.keySet().iterator();
			StringBuilder sb = new StringBuilder();
			while(it.hasNext()){
				String key = it.next().toString();
				String val = rParam.getString(key);
				if(key.indexOf("_"+CommonConfig.RANGE_TYPE_SINGLE) != -1){
					List sList = new ArrayList();
					key = key.substring(0, key.indexOf("_"+CommonConfig.RANGE_TYPE_SINGLE));
					String[] rows = val.split(CommonConfig.DATA_ROW_SEPARATOR);
					if(sb.length() > 0){
						sb.append(" AND ( ");
					}else{
						sb.append(" ( ");
					}						
					for(int i=0;i<rows.length;i++){		
						DataMap sMap = new DataMap();
						String[] cols = rows[i].split(CommonConfig.DATA_COL_SEPARATOR);
						if(i!=0){
							sb.append(" ").append(cols[2]).append(" ");
						}
						String fromVal = cols[1];
						fromVal = sqlFilter(fromVal);
						String operVal = operMap.getString(cols[0]);
						if(!cols[2].equals("OR") && !cols[2].equals("AND")){
							cols[2] = "OR";
						}
						sMap.put(CommonConfig.RNAGE_LOGICAL_OPERATOR_KEY, cols[2]);
						sMap.put(CommonConfig.RNAGE_OPERATOR_KEY, operVal);
						sMap.put(CommonConfig.RNAGE_SINGLE_DATA_KEY, fromVal);
						sList.add(sMap);
						if(fromVal.indexOf("%") != -1){
							sb.append(" ( ").append(key).append(" like '").append(fromVal).append("' ) ");
						}else{
							sb.append(" ( ").append(key).append(" ").append(operVal).append(" \u0027").append(fromVal).append("\u0027 ) ");
						}
					}
					sb.append(" ) ");
					rangeData.put(key+"_"+CommonConfig.RANGE_TYPE_SINGLE, sList);
				}else if(key.indexOf("_"+CommonConfig.RANGE_TYPE_RANGE) != -1){
					List sList = new ArrayList();
					key = key.substring(0, key.indexOf("_"+CommonConfig.RANGE_TYPE_RANGE));
					String[] rows = val.split(CommonConfig.DATA_ROW_SEPARATOR);
					if(sb.length() > 0){
						sb.append(" AND ( ");
					}else{
						sb.append(" ( ");
					}
					for(int i=0;i<rows.length;i++){
						DataMap sMap = new DataMap();
						if(i!=0){
							sb.append(" OR ");
						}
						String[] cols = rows[i].split(CommonConfig.DATA_COL_SEPARATOR);
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
						}else{
							sb.append(" ( ").append(key).append(" >= \u0027").append(fromVal).append("\u0027 AND ").append(key).append(" <= \u0027").append(toVal).append("\u0027 ) ");
						}
					}
					sb.append(" ) ");
					rangeData.put(key+"_"+CommonConfig.RANGE_TYPE_RANGE, sList);
				}
			}
			if(sb.length() > 0){
				if(params.containsKey(CommonConfig.RANGE_SQL_KEY)){
					params.put(CommonConfig.RANGE_SQL_KEY, params.get(CommonConfig.RANGE_SQL_KEY)+" AND ( "+sb.toString()+" ) ");
				}else{
					params.put(CommonConfig.RANGE_SQL_KEY, " AND ( "+sb.toString()+" ) ");
				}
			}
			
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
	
	public DataMap getListSqlP(SqlSession sqlSession, DataMap map) throws SQLException{
		//return getSql(map.getListCommand(), map);
		DataMap sql = getExecutorQueryP(sqlSession, map.getListCommand(), map);
		//log.debug(sql);
		return sql;
	}
	
	private DataMap getExecutorQueryP(SqlSession sqlSession, String statementId, DataMap parameters) throws SQLException{ 
		
		//parameters.setSqlType(true);
		//parameters.put("RANGE_SQL", "RANGE_SQL");
		String sql = sqlSession.getConfiguration().getMappedStatement(statementId).getBoundSql(parameters).getSql();
		String sqlLog = sql;
		List<ParameterMapping> paramMapping = sqlSession.getConfiguration().getMappedStatement(statementId).getBoundSql(parameters).getParameterMappings();
		List paramValueList = new ArrayList();
		
		ParameterMapping mapping;
		String paramKey;
		String paramValue;
		String paramTail;
		List rangeParamList;
		for(int i=0;i<paramMapping.size();i++){
			mapping = paramMapping.get(i);
			paramKey = mapping.getProperty();
			if(paramKey.indexOf(CommonConfig.RANGE_PRE_SQL_KEY) != -1 || paramKey.indexOf(CommonConfig.RANGE_SQL_KEY) != -1){
				parameters.setSqlType(false);
			}else{
				parameters.setSqlType(true);
			}
			paramValue = parameters.getString(paramKey);
			/*
			paramValueList.add(paramValue);
			sqlLog = sqlLog.replaceFirst("[?]", "'" + paramValue + "'");
			*/
			if(paramKey.equals(CommonConfig.RANGE_PRE_SQL_KEY)){
				sql = sql.replaceFirst("[?]", paramValue);
	    		//String tailStr = parameterMappinge[i].getPropertyName().substring(CommonConfig.RANGE_PRE_SQL_KEY.length());
	    		rangeParamList = parameters.getList(CommonConfig.RANGE_PRE_PARAM_KEY);
	    		paramValueList.addAll(rangeParamList);
		    	sqlLog = sqlLog.replaceFirst("[?]", parameters.get(CommonConfig.RANGE_SQL_KEY).toString());
			}else if(paramKey.indexOf(CommonConfig.RANGE_PRE_SQL_KEY) != -1){
				paramTail = paramKey.substring(CommonConfig.RANGE_PRE_SQL_KEY.length());
				
				sql = sql.replaceFirst("[?]", paramValue);
				rangeParamList = parameters.getList(CommonConfig.RANGE_PRE_PARAM_KEY+paramTail);
				paramValueList.addAll(rangeParamList);
		    	sqlLog = sqlLog.replaceFirst("[?]", parameters.get(CommonConfig.RANGE_SQL_KEY+paramTail).toString());
	    	}else{
	    		sql = sql.replaceFirst("[?]",CommonConfig.DATA_CELL_SEPARATOR);
	    		paramValueList.add(paramValue);
		    	sqlLog = sqlLog.replaceFirst("[?]", "'" + paramValue + "'");
	    	}
		}
		DataMap pdata= new DataMap();
	    
		sql = sql.replaceAll(CommonConfig.DATA_CELL_SEPARATOR, "?");
		pdata.put("sql", sql);
	    pdata.put("paramValueList", paramValueList);
	    pdata.put("sqlLog", sqlLog);
	    return pdata;
	}
}
