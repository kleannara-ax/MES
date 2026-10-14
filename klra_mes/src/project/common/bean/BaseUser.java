package project.common.bean;

import java.io.Serializable;

public class BaseUser implements Serializable {

	private static final long serialVersionUID = 5467531524640951540L;

	private String userid;
	private String password;
	private String username;
	private String compid;
	private String usertype;
	private String menugid;
	private String deptid;
	private String gradeid;
	private String sortorder;
	private String logindate;
	private String logoutdate;
	private String userKey;
	private String rootgid;
	private DataMap usrlo;
	private DataMap usrph;
	private DataMap usrpi;
	private DataMap userdata;

	public BaseUser() {
		this.userdata = new DataMap();
	}

	public String getUserid() {
		return userid;
	}

	public void setUserid(String userid) {
		this.userid = userid;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public String getCompid() {
		return compid;
	}

	public void setCompid(String compid) {
		this.compid = compid;
	}

	public String getUsertype() {
		return usertype;
	}

	public void setUsertype(String usertype) {
		this.usertype = usertype;
	}

	public String getMenugid() {
		return menugid;
	}

	public void setMenugid(String menugid) {
		this.menugid = menugid;
	}

	public String getDeptid() {
		return deptid;
	}

	public void setDeptid(String deptid) {
		this.deptid = deptid;
	}

	public String getGradeid() {
		return gradeid;
	}

	public void setGradeid(String gradeid) {
		this.gradeid = gradeid;
	}

	public String getSortorder() {
		return sortorder;
	}

	public void setSortorder(String sortorder) {
		this.sortorder = sortorder;
	}

	public String getLogindate() {
		return logindate;
	}

	public void setLogindate(String logindate) {
		this.logindate = logindate;
	}

	public String getLogoutdate() {
		return logoutdate;
	}

	public void setLogoutdate(String logoutdate) {
		this.logoutdate = logoutdate;
	}

	public String getUserKey() {
		return userKey;
	}

	public void setUserKey(String userKey) {
		this.userKey = userKey;
	}
	
	public String getRootgid() {
		return rootgid;
	}

	public void setRootgid(String rootgid) {
		this.rootgid = rootgid;
	}

	public DataMap getUsrlo() {
		return usrlo;
	}

	public void setUsrlo(DataMap usrlo) {
		this.usrlo = usrlo;
	}

	public DataMap getUsrph() {
		return usrph;
	}

	public void setUsrph(DataMap usrph) {
		this.usrph = usrph;
	}

	public DataMap getUsrpi() {
		return usrpi;
	}

	public void setUsrpi(DataMap usrpi) {
		this.usrpi = usrpi;
	}

	public DataMap getUserdata() {
		return userdata;
	}

	public Object getUserdata(String key) {
		return userdata.get(key);
	}

	public void setUserdata(DataMap userdata) {
		this.userdata = userdata;
	}

	public void addUserData(String key, Object value) {
		this.userdata.put(key, value);
	}

	@Override
	public String toString() {
		return "BaseUser [userid=" + userid + ", password=" + password + ", username=" + username + ", compid=" + compid
				+ ", usertype=" + usertype + ", menugid=" + menugid + ", deptid=" + deptid + ", gradeid=" + gradeid
				+ ", sortorder=" + sortorder + ", logindate=" + logindate + ", logoutdate=" + logoutdate + ", userKey="
				+ userKey + ", rootgid=" + rootgid + ", usrlo=" + usrlo + ", usrph=" + usrph + ", usrpi=" + usrpi
				+ ", userdata=" + userdata + "]";
	}
}