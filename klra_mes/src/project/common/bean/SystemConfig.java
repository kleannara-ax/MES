package project.common.bean;

public class SystemConfig {
	private String theme = "webdek";
	private String dbType = "oracle";
	private String sqlType = "oracle";
	private String cmmonType = "webdek";

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

	public String getCmmonType() {
		return cmmonType;
	}

	public void setCmmonType(String cmmonType) {
		this.cmmonType = cmmonType;
	}
}