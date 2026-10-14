package com.common.util;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.List;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.web.context.WebApplicationContext;
import org.springframework.web.context.support.WebApplicationContextUtils;

import com.common.bean.CommonConfig;
import com.common.bean.DataMap; 

public class Util {
	private String sqlType;
	
	public String getSqlType() {
		return sqlType;
	}

	public void setSqlType(String sqlType) {
		this.sqlType = sqlType;
	}

	public String createValidationSql(DataMap map){
		List<DataMap> list = map.getList("list");
		
		DataMap row;
		
		StringBuilder validationSql = new StringBuilder();
		if(map.containsKey(CommonConfig.GRID_REQUEST_VALIDATION_KEY)){
			
			String[] valCols = map.getString(CommonConfig.GRID_REQUEST_VALIDATION_KEY).split(",");
			String valType = map.getString(CommonConfig.GRID_REQUEST_VALIDATION_TYPE);
			if(valType.equals("")){
				valType = "CU";
			}
			for(int i=0;i<list.size();i++){
				row = list.get(i).getMap("map");
				String rowState = row.getString(CommonConfig.GRID_ROW_STATE_ATT);
				if(rowState.charAt(0) ==  'D'){
					continue;
				}
				if(valType.indexOf(rowState.charAt(0)) == -1){
					continue;
				}
				if(validationSql.length() != 0){
					validationSql.append("UNION ALL \n");
				}
				validationSql.append("SELECT \n");
				for(int j=0;j<valCols.length;j++){
					if(j != 0){
						validationSql.append(" ,");
					}
					validationSql.append(" '").append(row.getString(valCols[j])).append("' AS ").append(valCols[j]);
					
					validationSql.append(" \n");
				}
				
				if( !"mssql".equals(sqlType) ){
					validationSql.append("FROM DUAL \n");
				}
			}
		}
		
		return validationSql.toString();
	}
	
	public String createValidationSql(DataMap map, String key){
		List<DataMap> list = map.getList("list");
		
		DataMap row;
		
		StringBuilder validationSql = new StringBuilder();
			
		String[] valCols = key.split(",");
		for(int i=0;i<list.size();i++){
			row = list.get(i).getMap("map");
			String rowState = row.getString(CommonConfig.GRID_ROW_STATE_ATT);
			if(rowState.length() > 0 && rowState.charAt(0) ==  'D'){
				continue;
			}
			if(validationSql.length() != 0){
				validationSql.append("UNION ALL \n");
			}
			validationSql.append("SELECT \n");
			for(int j=0;j<valCols.length;j++){
				if(j != 0){
					validationSql.append(" ,");
				}
				validationSql.append(" '").append(row.getString(valCols[j])).append("' AS ").append(valCols[j]);
				
				validationSql.append(" \n");
			}

			if( !"mssql".equals(sqlType) ){
				validationSql.append("FROM DUAL \n");	
			} 				
		}
		
		return validationSql.toString();
	}
	
	/**
	 * 화면에서 net.send로 넘어온다.
	 * @param map
	 * @param key
	 * @return
	 */
	public String urlCreateValidationSql(DataMap map, String key){
		List<DataMap> list = map.getList("list");
		DataMap row;
		StringBuilder validationSql = new StringBuilder();
		if(map.containsKey("key")){
			String[] valCols = map.getString("key").split(",");
			for(int i=0;i<list.size();i++){
				row = list.get(i).getMap("map");
				if(i != 0){
					validationSql.append("UNION ALL \n");
				}
				validationSql.append("SELECT \n");
				for(int j=0;j<valCols.length;j++){
					if(j != 0){
						validationSql.append(" ,");
					}
					validationSql.append(" '").append(row.getString(valCols[j])).append("' AS ").append(valCols[j]);
					
					validationSql.append(" \n");
				}
				
				if( !"mssql".equals(sqlType) ){
					validationSql.append("FROM DUAL \n");	
				}			
			}
		}
		
		return validationSql.toString();
	}
	
	/**
	 * 서비스 단에서 밸리데이션 쿼리생성. 
	 * HashMap 으로 받는다.
	 * @param map
	 * @param key
	 * @return
	 */
	public String itemCreateValidationSql(DataMap map, String key){
		List<DataMap> list = map.getList("list");
		HashMap row;
		StringBuilder validationSql = new StringBuilder();
		if(map.containsKey("key")){
			String[] valCols = map.getString("key").split(",");
			for(int i=0;i<list.size();i++){
				row = list.get(i);
				if(i != 0){
					validationSql.append("UNION ALL \n");
				}
				validationSql.append("SELECT \n");
				for(int j=0;j<valCols.length;j++){
					if(j != 0){
						validationSql.append(" ,");
					}
					validationSql.append(" '").append(row.get(valCols[j])).append("' AS ").append(valCols[j]);
					
					validationSql.append(" \n");
				}

				if( !"mssql".equals(sqlType) ){
					validationSql.append("FROM DUAL \n");
				} 			
			}
		}
		
		return validationSql.toString();
	}
	
	public Object executeBeanObject(HttpServletRequest request, String beanName, String funcName, Object param) throws NoSuchMethodException, SecurityException, IllegalAccessException, IllegalArgumentException, InvocationTargetException{
		
		//HttpSession 객체 가져오기
		 HttpSession session = request.getSession();
		 
		 //ServletContext 객체 가져오기
		 ServletContext conext = session.getServletContext();
		 
		 //Spring Context 가져오기
		 WebApplicationContext wContext = WebApplicationContextUtils.getWebApplicationContext(conext);
		 
		 //스프링 빈 가져오기 & casting
		 Object sBean = wContext.getBean(beanName);
		 
		 Method method = sBean.getClass().getMethod(funcName, new Class[]{DataMap.class});
		 
		 return method.invoke(sBean, new Object[]{param});
	}
}