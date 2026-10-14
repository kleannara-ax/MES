package com.common.bean;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class User implements Serializable{

	private static final long serialVersionUID = 5467531524640951540L;
	
	private String userid;
	private String passwd;
	private String nmlast;
	private String nmfirs;
	private String addr01;
	private String addr02;
	private String addr03;
	private String addr04;
	private String addr05;
	private String city01;
	private String regn01;
	private String postcd;
	private String natnky;
	private String teln01;
	private String teln02;
	private String teln03;
	private String tlext1;
	private String faxtl1;
	private String faxtl2;
	private String pobox1;
	private String pobpc1;
	private String email1;
	private String email2;
	private String compky;
	private String depart;
	private String emplid;
	private String userg1;
	private String userg2;
	private String userg3;
	private String userg4;
	private String userg5;
	private String langky;
	private String datefm;
	private String datedl;
	private String decpfm;
	private String llogid;
	private String llogit;
	private String llogod;
	private String llogot;
	private String menuky;
	private String llogwh;
	private String timfmt;
	private String currfm;
	private String recntf;
	private String delmak;
	private String pgsize;
	private String ftsize;
	private String credat;
	private String cretim;
	private String creusr;
	private String lmodat;
	private String lmotim;
	private String lmousr;
	private String updchk;
	private String indbzl;
	private String indarc;
	private String fmdesc1;
	private String dldesc1;
	private String dldesc2;
	private String owner;
	private String wareky;
	private DataMap usrlo;
	private DataMap usrph;
	private DataMap usrpi;
	private DataMap userdata;
	private String userKey;
	private String pwtodat;
	private String pw90dat;
	private String pwfail;
	private String llogid90;
	
	public User(){
		this.userdata = new DataMap();
	}
	
	public String getUserid() {
		return userid;
	}
	public void setUserid(String userid) {
		this.userid = userid;
	}
	public String getPasswd() {
		return passwd;
	}
	public void setPasswd(String passwd) {
		this.passwd = passwd;
	}
	public String getNmlast() {
		return nmlast;
	}
	public void setNmlast(String nmlast) {
		this.nmlast = nmlast;
	}
	public String getNmfirs() {
		return nmfirs;
	}
	public void setNmfirs(String nmfirs) {
		this.nmfirs = nmfirs;
	}
	public String getAddr01() {
		return addr01;
	}
	public void setAddr01(String addr01) {
		this.addr01 = addr01;
	}
	public String getAddr02() {
		return addr02;
	}
	public void setAddr02(String addr02) {
		this.addr02 = addr02;
	}
	public String getAddr03() {
		return addr03;
	}
	public void setAddr03(String addr03) {
		this.addr03 = addr03;
	}
	public String getAddr04() {
		return addr04;
	}
	public void setAddr04(String addr04) {
		this.addr04 = addr04;
	}
	public String getAddr05() {
		return addr05;
	}
	public void setAddr05(String addr05) {
		this.addr05 = addr05;
	}
	public String getCity01() {
		return city01;
	}
	public void setCity01(String city01) {
		this.city01 = city01;
	}
	public String getRegn01() {
		return regn01;
	}
	public void setRegn01(String regn01) {
		this.regn01 = regn01;
	}
	public String getPostcd() {
		return postcd;
	}
	public void setPostcd(String postcd) {
		this.postcd = postcd;
	}
	public String getNatnky() {
		return natnky;
	}
	public void setNatnky(String natnky) {
		this.natnky = natnky;
	}
	public String getTeln01() {
		return teln01;
	}
	public void setTeln01(String teln01) {
		this.teln01 = teln01;
	}
	public String getTeln02() {
		return teln02;
	}
	public void setTeln02(String teln02) {
		this.teln02 = teln02;
	}
	public String getTeln03() {
		return teln03;
	}
	public void setTeln03(String teln03) {
		this.teln03 = teln03;
	}
	public String getTlext1() {
		return tlext1;
	}
	public void setTlext1(String tlext1) {
		this.tlext1 = tlext1;
	}
	public String getFaxtl1() {
		return faxtl1;
	}
	public void setFaxtl1(String faxtl1) {
		this.faxtl1 = faxtl1;
	}
	public String getFaxtl2() {
		return faxtl2;
	}
	public void setFaxtl2(String faxtl2) {
		this.faxtl2 = faxtl2;
	}
	public String getPobox1() {
		return pobox1;
	}
	public void setPobox1(String pobox1) {
		this.pobox1 = pobox1;
	}
	public String getPobpc1() {
		return pobpc1;
	}
	public void setPobpc1(String pobpc1) {
		this.pobpc1 = pobpc1;
	}
	public String getEmail1() {
		return email1;
	}
	public void setEmail1(String email1) {
		this.email1 = email1;
	}
	public String getEmail2() {
		return email2;
	}
	public void setEmail2(String email2) {
		this.email2 = email2;
	}
	public String getCompky() {
		return compky;
	}
	public void setCompky(String compky) {
		this.compky = compky;
	}
	public String getDepart() {
		return depart;
	}
	public void setDepart(String depart) {
		this.depart = depart;
	}
	public String getEmplid() {
		return emplid;
	}
	public void setEmplid(String emplid) {
		this.emplid = emplid;
	}
	public String getUserg1() {
		return userg1;
	}
	public void setUserg1(String userg1) {
		this.userg1 = userg1;
	}
	public String getUserg2() {
		return userg2;
	}
	public void setUserg2(String userg2) {
		this.userg2 = userg2;
	}
	public String getUserg3() {
		return userg3;
	}
	public void setUserg3(String userg3) {
		this.userg3 = userg3;
	}
	public String getUserg4() {
		return userg4;
	}
	public void setUserg4(String userg4) {
		this.userg4 = userg4;
	}
	public String getUserg5() {
		return userg5;
	}
	public void setUserg5(String userg5) {
		this.userg5 = userg5;
	}
	public String getLangky() {
		return langky;
	}
	public void setLangky(String langky) {
		this.langky = langky;
	}
	public String getDatefm() {
		return datefm;
	}
	public void setDatefm(String datefm) {
		this.datefm = datefm;
	}
	public String getDatedl() {
		return datedl;
	}
	public void setDatedl(String datedl) {
		this.datedl = datedl;
	}
	public String getDecpfm() {
		return decpfm;
	}
	public void setDecpfm(String decpfm) {
		this.decpfm = decpfm;
	}
	public String getLlogid() {
		return llogid;
	}
	public void setLlogid(String llogid) {
		this.llogid = llogid;
	}
	public String getLlogit() {
		return llogit;
	}
	public void setLlogit(String llogit) {
		this.llogit = llogit;
	}
	public String getLlogod() {
		return llogod;
	}
	public void setLlogod(String llogod) {
		this.llogod = llogod;
	}
	public String getLlogot() {
		return llogot;
	}
	public void setLlogot(String llogot) {
		this.llogot = llogot;
	}
	public String getMenuky() {
		return menuky;
	}
	public void setMenuky(String menuky) {
		this.menuky = menuky;
	}
	public String getLlogwh() {
		return llogwh;
	}
	public void setLlogwh(String llogwh) {
		this.llogwh = llogwh;
	}
	public String getTimfmt() {
		return timfmt;
	}
	public void setTimfmt(String timfmt) {
		this.timfmt = timfmt;
	}
	public String getCurrfm() {
		return currfm;
	}
	public void setCurrfm(String currfm) {
		this.currfm = currfm;
	}
	public String getRecntf() {
		return recntf;
	}
	public void setRecntf(String recntf) {
		this.recntf = recntf;
	}
	public String getDelmak() {
		return delmak;
	}
	public void setDelmak(String delmak) {
		this.delmak = delmak;
	}
	public String getPgsize() {
		return pgsize;
	}
	public void setPgsize(String pgsize) {
		this.pgsize = pgsize;
	}
	public String getFtsize() {
		return ftsize;
	}
	public void setFtsize(String ftsize) {
		this.ftsize = ftsize;
	}
	public String getCredat() {
		return credat;
	}
	public void setCredat(String credat) {
		this.credat = credat;
	}
	public String getCretim() {
		return cretim;
	}
	public void setCretim(String cretim) {
		this.cretim = cretim;
	}
	public String getCreusr() {
		return creusr;
	}
	public void setCreusr(String creusr) {
		this.creusr = creusr;
	}
	public String getLmodat() {
		return lmodat;
	}
	public void setLmodat(String lmodat) {
		this.lmodat = lmodat;
	}
	public String getLmotim() {
		return lmotim;
	}
	public void setLmotim(String lmotim) {
		this.lmotim = lmotim;
	}
	public String getLmousr() {
		return lmousr;
	}
	public void setLmousr(String lmousr) {
		this.lmousr = lmousr;
	}
	public String getUpdchk() {
		return updchk;
	}
	public void setUpdchk(String updchk) {
		this.updchk = updchk;
	}
	public String getIndbzl() {
		return indbzl;
	}
	public void setIndbzl(String indbzl) {
		this.indbzl = indbzl;
	}
	public String getIndarc() {
		return indarc;
	}
	public void setIndarc(String indarc) {
		this.indarc = indarc;
	}
	public String getFmdesc1() {
		return fmdesc1;
	}
	public void setFmdesc1(String fmdesc1) {
		this.fmdesc1 = fmdesc1;
	}
	public String getDldesc1() {
		return dldesc1;
	}
	public void setDldesc1(String dldesc1) {
		this.dldesc1 = dldesc1;
	}
	public String getDldesc2() {
		return dldesc2;
	}
	public void setDldesc2(String dldesc2) {
		this.dldesc2 = dldesc2;
	}
	public String getOwner() {
		return owner;
	}
	public void setOwner(String owner) {
		this.owner = owner;
	}
	public String getWareky() {
		return wareky;
	}
	public void setWareky(String wareky) {
		this.wareky = wareky;
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
	public void setUserdata(DataMap userdata) {
		this.userdata = userdata;
	}
	public void addUserData(String key, Object value){
		this.userdata.put(key, value);
	}
	public String getUserKey() {
		return userKey;
	}
	public void setUserKey(String userKey) {
		this.userKey = userKey;
	}
	public String getPwtodat() {
		return pwtodat;
	}

	public void setPwtodat(String pwtodat) {
		this.pwtodat = pwtodat;
	}

	public String getPw90dat() {
		return pw90dat;
	}

	public void setPw90dat(String pw90dat) {
		this.pw90dat = pw90dat;
	}

	public String getPwfail() {
		return pwfail;
	}

	public String getLlogid90() {
		return llogid90;
	}

	public void setLlogid90(String llogid90) {
		this.llogid90 = llogid90;
	}

	public void setPwfail(String pwfail) {
		this.pwfail = pwfail;
	}

	@Override
	public String toString() {
		return "User [userid=" + userid + ", passwd=" + passwd + ", nmlast=" + nmlast + ", nmfirs=" + nmfirs
				+ ", addr01=" + addr01 + ", addr02=" + addr02 + ", addr03=" + addr03 + ", addr04=" + addr04
				+ ", addr05=" + addr05 + ", city01=" + city01 + ", regn01=" + regn01 + ", postcd=" + postcd
				+ ", natnky=" + natnky + ", teln01=" + teln01 + ", teln02=" + teln02 + ", teln03=" + teln03
				+ ", tlext1=" + tlext1 + ", faxtl1=" + faxtl1 + ", faxtl2=" + faxtl2 + ", pobox1=" + pobox1
				+ ", pobpc1=" + pobpc1 + ", email1=" + email1 + ", email2=" + email2 + ", compky=" + compky
				+ ", depart=" + depart + ", emplid=" + emplid + ", userg1=" + userg1 + ", userg2=" + userg2
				+ ", userg3=" + userg3 + ", userg4=" + userg4 + ", userg5=" + userg5 + ", langky=" + langky
				+ ", datefm=" + datefm + ", datedl=" + datedl + ", decpfm=" + decpfm + ", llogid=" + llogid
				+ ", llogit=" + llogit + ", llogod=" + llogod + ", llogot=" + llogot + ", menuky=" + menuky
				+ ", llogwh=" + llogwh + ", timfmt=" + timfmt + ", currfm=" + currfm + ", recntf=" + recntf
				+ ", delmak=" + delmak + ", pgsize=" + pgsize + ", ftsize=" + ftsize + ", credat=" + credat
				+ ", cretim=" + cretim + ", creusr=" + creusr + ", lmodat=" + lmodat + ", lmotim=" + lmotim
				+ ", lmousr=" + lmousr + ", updchk=" + updchk + ", indbzl=" + indbzl + ", indarc=" + indarc
				+ ", fmdesc1=" + fmdesc1 + ", dldesc1=" + dldesc1 + ", dldesc2=" + dldesc2 + ", owner=" + owner
				+ ", wareky=" + wareky + ", usrlo=" + usrlo + ", usrph=" + usrph + ", usrpi=" + usrpi + ", userdata="
				+ userdata + ", userKey=" + userKey + ", pwtodat=" + pwtodat + ", pw90dat=" + pw90dat + ", pwfail="
				+ pwfail + ", llogid90=" + llogid90 + "]";
	}	
}