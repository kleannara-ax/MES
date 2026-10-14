package com.common.bean;

public class SystemConfig {
	private String asyncType = "F";
	private boolean isAsync = false;
	private String theme = "default";
	private String dbType = "oracle";
	private String sqlType = "oracle";
	
	public String getAsyncType() {
		return asyncType;
	}

	public void setAsyncType(String asyncType) {
		this.asyncType = asyncType;
		if(asyncType.equals("T")){
			isAsync = true;
		}
	}
	
	public boolean isAsync(){
		return isAsync;
	}

	public String getTheme() {
		if(theme.equals("default")){
			return "";
		}
		return theme;
	}
	
	public String getThemePath() {
		if(theme.equals("default")){
			return "";
		}
		return "/theme/"+this.theme;
	}

	public void setTheme(String theme) {
		if(theme.equals("") || theme.equals("default")){
			return;
		}
		this.theme = theme;
	}

	public String getDbTypeCode() {
		if(dbType.equals("oracle")){
			return "1";
		}else if(dbType.equals("mssql")){
			return "2";
		}
		return "0";
	}
	
	public String getDbType() {
		return dbType;
	}

	public void setDbType(String dbType) {
		this.dbType = dbType;
	}

	public String getSqlType() {
		return sqlType;
	}

	public void setSqlType(String sqlType) {
		this.sqlType = sqlType;
	}

	@Override
	public String toString() {
		return "SystemConfig [asyncType=" + asyncType + ", isAsync=" + isAsync
				+ ", theme=" + theme + ", dbType=" + dbType + ", sqlType="
				+ sqlType + "]";
	}
}