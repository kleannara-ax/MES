package com.common.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;

import javax.sql.DataSource;

import org.apache.log4j.Logger;

import com.common.bean.DataRepository;

public class AsyncDAO  extends Thread {
	
	private static Logger log = Logger.getLogger(AsyncDAO.class);
	
	private DataRepository dataRespository;
	private DataSource dataSource;
	private int count;
	public StringBuilder startsb;
	public StringBuilder sb;
	public String error;
	private String sql;
	private int viewCount;
	private String key;
	
	public AsyncDAO(){
		this.count = 0;
	}
	
	public void setAsyncDAO(DataRepository dataRespository, DataSource dataSource, String sql, int viewCount, String key){
		this.dataRespository = dataRespository;
		dataRespository.addData(key);
		startsb = dataRespository.getStartStringBuilder(key);
		sb = dataRespository.getStringBuilder(key);
		this.dataSource = dataSource;
		this.sql = sql;
		this.viewCount = viewCount;
		this.key = key;
	}

	@Override
	public void run() {
		Connection conn = null;
		PreparedStatement psmt = null;
		ResultSet rs = null;
		
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
					String value = rs.getString(i+1);
					if(value == null){
						value = " ";
					}
					sb.append(value);
					if(i<rsmd.getColumnCount()-1){
						sb.append("↓");
					}
				}
				sb.append("↑");
				
				count++;
				if(count%1000 == 0){
					System.out.println(count);
				}
				
				if(count == this.viewCount){
					startsb.append(sb.toString());
					//session.setAttribute(key, "S"+this.startsb.substring(0,this.startsb.length()-1));
					dataRespository.setState(key, "S");
					log.debug("AsyncDAO start end "+this.key+" : "+count);
				}
			}
			//session.setAttribute(key, "E"+this.sb.substring(0,this.sb.length()-1));
			dataRespository.setState(key, "E");
			log.debug("AsyncDAO count "+this.key+" : "+count);
		}catch(Exception e){
			//session.setAttribute(key, "E");
			dataRespository.setState(key, "E");
			log.error("AsyncDAO : ", e);
		}finally{
			try {
				if(rs != null){
					rs.close();
				}
			} catch (SQLException e) {
				e.printStackTrace();
			}
			try {
				psmt.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			
			log.debug("AsyncDAO end "+this.key+" : "+count);
			/*
			if(session.getAttribute(key) == null){
				session.setAttribute(key, "E");
			}
			*/
			dataRespository.setState(key, "E");
			
			this.interrupt();
		}
	}
}