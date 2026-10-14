package com.ahcs.bean;

import java.util.List;

import com.common.bean.BaseUser;

public class User extends BaseUser {
	private String userId;
	private String pwNo;
	private String userNm;
	private String cpId;
	private String cpNm;
	private String deptId;
	private String deptNm;
	private String jposId;
	private String jposNm;
	private String dutyId;
	private String dutyNm;
	private List deptList;
	private List menuList;
	private List authList;
	public String getUserId() {
		return userId;
	}
	public void setUserId(String userId) {
		this.userId = userId;
	}
	public String getPwNo() {
		return pwNo;
	}
	public void setPwNo(String pwNo) {
		this.pwNo = pwNo;
	}
	public String getUserNm() {
		return userNm;
	}
	public void setUserNm(String userNm) {
		this.userNm = userNm;
	}
	public String getCpId() {
		return cpId;
	}
	public void setCpId(String cpId) {
		this.cpId = cpId;
	}
	public String getCpNm() {
		return cpNm;
	}
	public void setCpNm(String cpNm) {
		this.cpNm = cpNm;
	}
	public String getDeptId() {
		return deptId;
	}
	public void setDeptId(String deptId) {
		this.deptId = deptId;
	}
	public String getDeptNm() {
		return deptNm;
	}
	public void setDeptNm(String deptNm) {
		this.deptNm = deptNm;
	}
	public String getJposId() {
		return jposId;
	}
	public void setJposId(String jposId) {
		this.jposId = jposId;
	}
	public String getJposNm() {
		return jposNm;
	}
	public void setJposNm(String jposNm) {
		this.jposNm = jposNm;
	}
	public String getDutyId() {
		return dutyId;
	}
	public void setDutyId(String dutyId) {
		this.dutyId = dutyId;
	}
	public String getDutyNm() {
		return dutyNm;
	}
	public void setDutyNm(String dutyNm) {
		this.dutyNm = dutyNm;
	}
	public List getDeptList() {
		return deptList;
	}
	public void setDeptList(List deptList) {
		this.deptList = deptList;
	}
	public List getMenuList() {
		return menuList;
	}
	public void setMenuList(List menuList) {
		this.menuList = menuList;
	}
	public List getAuthList() {
		return authList;
	}
	public void setAuthList(List authList) {
		this.authList = authList;
	}
	@Override
	public String toString() {
		return "User [userId=" + userId + ", pwNo=" + pwNo + ", userNm=" + userNm + ", cpId=" + cpId + ", cpNm=" + cpNm
				+ ", deptId=" + deptId + ", deptNm=" + deptNm + ", jposId=" + jposId + ", jposNm=" + jposNm
				+ ", dutyId=" + dutyId + ", dutyNm=" + dutyNm + ", deptList=" + deptList + ", menuList=" + menuList
				+ ", authList=" + authList + ", getUsrlo()=" + getUsrlo() + ", getUsrph()=" + getUsrph()
				+ ", getUsrpi()=" + getUsrpi() + ", toString()=" + super.toString() + ", getClass()=" + getClass()
				+ ", hashCode()=" + hashCode() + "]";
	}
}