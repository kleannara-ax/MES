package com.common.bean;

public class BaseUser {
	private DataMap usrlo;
	private DataMap usrph;
	private DataMap usrpi;
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
	@Override
	public String toString() {
		return "BaseUser [usrlo=" + usrlo + ", usrph=" + usrph + ", usrpi=" + usrpi + "]";
	}		
}