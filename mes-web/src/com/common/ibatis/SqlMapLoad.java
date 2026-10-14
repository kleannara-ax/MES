package com.common.ibatis;

import java.io.IOException;
import java.io.Reader;
import java.sql.Clob;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import javax.sql.DataSource;

import org.apache.log4j.Logger;

public class SqlMapLoad {

	private static Logger log = Logger.getLogger(SqlMapLoad.class);
	
	public static String load(DataSource dataSource, String dbType) {
		return SqlMapLoad.load(dataSource, dbType, null);
	}

	public static String load(DataSource dataSource, String dbType, Map param) {
		if(param == null){
			param = new HashMap();
		}
		String query = "SELECT SQLKEY, SQLSTA FROM JQMAP WHERE SQLTYP='I' AND DBMSTY=?";
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		StringBuilder sb = new StringBuilder();
		sb.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
		sb.append("<!DOCTYPE sqlMap PUBLIC \"-//ibatis.apache.org//DTD SQL MAP 2.0//EN\" \"http://ibatis.apache.org/dtd/sql-map-2.dtd\">\n");
		sb.append("<sqlMap>\n");
		sb.append("<typeAlias alias=\"DataMap\" type=\"com.common.bean.DataMap\" />\n");
		sb.append("<typeAlias alias=\"StringMap\" type=\"com.common.util.StringMap\" />\n");
		try {
			con = dataSource.getConnection();
			pstmt = con.prepareStatement(query);
			pstmt.setString(1, dbType);
			rs = pstmt.executeQuery();
			while(rs.next()) {
				if(param.containsKey(rs.getString("SQLKEY"))){
					sb.append(param.get(rs.getString("SQLKEY"))).append("\n");
				}else{
					sb.append(rs.getString("SQLSTA")).append("\n");
				}				
			}
		} catch (SQLException e) {
			e.printStackTrace();
			throw new DataSourceMappingResourceException(" sql loading error", e);
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
		sb.append("</sqlMap>");
		System.out.println(sb);
		return sb.toString();
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
