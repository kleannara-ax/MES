package com.common.ibatis;

import java.io.IOException;
import java.io.Reader;
import java.sql.Clob;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import javax.sql.DataSource;

import org.apache.log4j.Logger;

public class DataSourceMappingResources {

	private DataSource dataSource; 
	
	private String url;
	
	private String tableName;
	
	private String dbName;
	
	private List<DataSourceMappingResource> resources;
	
	private String query = "SELECT NASPCE, DBNAME, SQLXML, CREDAT, UPDDAT, CREUSR, UPDUSR "
			                      + "FROM SQLMA "
			                    + "WHERE DBNAME = ?";
	
	private static Logger log = Logger.getLogger(DataSourceMappingResources.class);
	
	public DataSourceMappingResources(DataSource dataSource, String url) {
		this.dataSource = dataSource;
		this.url = url;
		init();
		load();
	} 
	
	private void init() {
		try {
			String tmp = url.substring(url.indexOf(":") + 1);
			String[] tokens = tmp.split("/");
			tableName = tokens[0];
			dbName = tokens[1];
			
			if (log.isInfoEnabled())
				log.info ("Parse tableName=" + tableName + ", dbName=" + dbName);
			
		} catch (Exception e) {
			throw new IllegalArgumentException("Invalid dataSourceMappingResource: " + url);
		}
	}
	
	private void load() {
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String namespace = null;
		try {
			con = dataSource.getConnection();
			pstmt = con.prepareStatement(query);
			pstmt.setString(1, dbName);
			rs = pstmt.executeQuery();
			List<DataSourceMappingResource> tmp = new ArrayList<DataSourceMappingResource>();
			while(rs.next()) {
				namespace = rs.getString("NASPCE");
				tmp.add(new DataSourceMappingResource(
						  readClob(rs.getClob("SQLXML"))
						, rs.getLong("UPDDAT")
						, namespace));
			}
			if (log.isInfoEnabled())
				log.info("### resources=" + tmp);
			this.resources = tmp; 
		} catch (SQLException e) {
			e.printStackTrace();
			throw new DataSourceMappingResourceException(namespace + " sql loading error", e);
		} catch (IOException e) {
			e.printStackTrace();
			throw new DataSourceMappingResourceException(namespace + " sql loading error", e);
		} finally {
			try {
				if (rs != null)
					rs.close();
				if (pstmt != null)
					pstmt.close();
				if (con != null)
					con.close();
			} catch (SQLException e) {
			}
		}
	}
	
	public List<DataSourceMappingResource> getResources() {
		return this.resources;
	}
	
	private String readClob(Clob clob) throws SQLException, IOException {
	    StringBuilder sb = new StringBuilder((int) clob.length());
	    Reader r = clob.getCharacterStream();
	    char[] cbuf = new char[2048];
	    int n;
	    while ((n = r.read(cbuf, 0, cbuf.length)) != -1) {
	        sb.append(cbuf, 0, n);
	    }
	    return sb.toString();
	}
}
