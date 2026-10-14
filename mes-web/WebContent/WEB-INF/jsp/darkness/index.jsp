<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.common.bean.DataMap,java.util.ArrayList,com.common.bean.CommonConfig"%>
<%@ page import="com.common.util.*"%>
<%
	ArrayList list = (ArrayList)request.getAttribute("WAHMACOMBO");
	ArrayList list1 = (ArrayList)request.getAttribute("LANGKY");
	ArrayList list2 = (ArrayList)request.getAttribute("MSG");
	
	DataMap row;
	
	Object SES_USER_ID = request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY);
	
	String sloId = (String)request.getAttribute("SLOID");
	String sloPw = (String)request.getAttribute("SLOPW");
	String sloWk = (String)request.getAttribute("SLOWK");
	String sloLk = (String)request.getAttribute("SLOLK");
	
	String theme = CommonConfig.SYSTEM_THEME_PATH;
	String sysTitle   = CommonConfig.SYSTEM_TITLE;
	String sysVersion = CommonConfig.SYSTEM_VERSION;
	
	
	RSA rsa = RSA.getEncKey();
	request.setAttribute("publicKeyModulus", rsa.getPublicKeyModulus());
	request.setAttribute("publicKeyExponent", rsa.getPublicKeyExponent());
	request.getSession().setAttribute("__rsaPrivateKey__", rsa.getPrivateKey());
	
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<title><%=sysTitle%> <%=sysVersion%></title>
<link rel="stylesheet" type="text/css" href="/common<%=theme%>/css/login.css">
<link rel="stylesheet" type="text/css" href="/common<%=theme%>/css/theme.css">
<script type="text/javascript" src="/common/js/jquery.js"></script>
<script type="text/javascript" src="/common/js/jquery-ui.js"></script>
<script type="text/javascript" src="/common/js/json2.js"></script>
<script type="text/javascript" src="/common/js/jquery.cookie.js"></script>
<script type="text/javascript" src="/common/js/dataMap.js"></script>
<script type="text/javascript" src="/common/js/site.js"></script>
<script type="text/javascript" src="/common/js/configData.js"></script>
<script type="text/javascript" src="/common/js/commonUtil.js"></script>
<script type="text/javascript" src="/common/js/dataBind.js"></script>
<script type="text/javascript" src="/common/js/input.js"></script>
<script type="text/javascript" src="/common/js/netUtil.js"></script>
<script type="text/javascript" src="/common/js/ui.js"></script>
<script type="text/javascript" src="/common/js/worker-ajax.js"></script>
<script type="text/javascript" src="/common/js/bigdata.js"></script>
<script type="text/javascript" src="/common/js/grid.js"></script>
<script type="text/javascript" src="/common/js/validateUtil.js"></script>
<script type="text/javascript" src="/common/js/page.js"></script>
<script type="text/javascript" src="/common/js/label.js"></script>
<script type="text/javascript" src="/mes/js/jsbn.js"></script>
<script type="text/javascript" src="/mes/js/rsa.js"></script>
<script type="text/javascript" src="/mes/js/prng4.js"></script>
<script type="text/javascript" src="/mes/js/rng.js"></script>
<script>
<%
for(int i=0;i<list2.size();i++){
	row = (DataMap)list2.get(i);
%>
commonMessage.message.put("<%=row.get("MESGKY")%>","<%=row.get("MESGTX")%>");
<%
}
%>

function getMsg(msgCode){
	msgCode = $langky.val()+"_"+msgCode;
	return commonMessage.message.get(msgCode);
}

function getLabel(){
	return "";
}

var $langky;

var $contentLoading;
//로딩 열기
function loadingOpen() {
	
	$contentLoading.show();
}

//로딩 닫기
function loadingClose() {
	
	$contentLoading.hide();
}

var topLabelFrame;

$(document).ready(function(){
// 	alert("darkness");
	$langky = jQuery("#LANGKY");
	
	topLabelFrame = window;
	
	$contentLoading = jQuery("#contentLoading");
	
	inputList.setCombo();
<%
	if(sloId != null && !sloId.equals("")){
		list = new ArrayList();
		DataMap data = new DataMap();
		data.put("VALUE_COL", sloWk);
		data.put("TEXT_COL", sloWk);
		list.add(data);
		list1 = new ArrayList();
		DataMap row1 = new DataMap();
		row1.put("VALUE_COL", sloLk);
		row1.put("TEXT_COL", sloLk);
		list1.add(row1);
%>
	jQuery("#USERID").val("<%=sloId%>");
	jQuery("#PASSWD").val("<%=sloPw%>");
	jQuery("#WAREKY").val("<%=sloWk%>");
	jQuery("#LANGKY").val("<%=sloLk%>");
	login();
<%
	}else if(SES_USER_ID != null && !SES_USER_ID.toString().equals("")){
%>
	this.location.href = "/common/main.page";
<%
	}else{
%>

	//checkEZPlatformApp();
	
	$("select[name=WAREKY]").val("WH01");
	$("select[name=LANGKY]").val("KR");
	var WAREKY = $.cookie("WAREKY");
	if(WAREKY){
		jQuery("#WAREKY").val(WAREKY);
	}
	var LANGKY = $.cookie("LANGKY");
	if(LANGKY){
		jQuery("#LANGKY").val(LANGKY);
	}
	var USERID = $.cookie("USERID");
	if(USERID){
		jQuery("#USERID").val(USERID);
	}
	/*
	var PASSWD = $.cookie("PASSWD");
	if(PASSWD){
		jQuery("#PASSWD").val(PASSWD);
	}
	*/
<%
	}
%>
	$("body").show();
});

function login(){
	//this.location.href = "/common/main.page";
	if(validate.check("searchArea")){
		
		var param = dataBind.paramData("searchArea");
		
		var rsaPublicKeyModulus = document.getElementById("rsaPublicKeyModulus").value;
		var rsaPublicKeyExponent = document.getElementById("rsaPublicKeyExponent").value;
		var encPassword = fnRsaEnc($('input[name=PASSWD]').val(), rsaPublicKeyModulus, rsaPublicKeyExponent);
		param.put("PASSWD", encPassword);
		
		var json = netUtil.send({
			url : "/common/json/login.data",
			param : param,
			returnParam : param,
			successFunction : "loginEnd"
		});
	}	
}

function loginEnd(json, param){
	
	if(json && json.data){
		
		//alert("json.data : " + json.data);
		
		var resultText = json.data.trim();
		
		if(resultText == "F"){
			//commonUtil.msg("아이디 또는 비밀번호가 일치 하지 않습니다.");  //LOGIN_M0001
			alert(getMsg("M0001"));
		}else if(json.data == "R"){
			//commonUtil.msg("해당 창고에 접속할 수 있는 권한이 없습니다..");  //LOGIN_M0002
			alert(getMsg("M0010"));
		}else if(resultText == "F_LOGIN_ID"){ // 사용자가 존재하지 않습니다.
			alert(getMsg("M0001"));
		}else if(resultText == "F_LOGIN_CNT_OVER"){ // 5회 이상 비밀번호가 틀려서, 사용자가 블락되었습니다. 관리자에게 문의하여 주세요.
			alert(getMsg("M0013"));
		}else if(resultText == "F_LOGIN_PW"){ // 비밀번호가 틀렸습니다.
			alert(getMsg("M0001"));
		}else if(resultText == "F_LOGIN_ROLE"){ // 해당 창고에 접속할 수 있는 권한이 없습니다.
			alert(getMsg("M0010"));
		}else if(resultText == "F_LOGIN_RSA"){ // RSA 암호화가 실패하였습니다. 관리자에게 문의하여 주세요.
			alert(getMsg("M0011"));
		}else if(resultText == "F_LOGIN_DEL"){ // 삭제된 사용자 입니다.
			alert(getMsg("M0012"));
		}else if(resultText == "F_LOGIN_PW_90_OVER"){ // 90일동안 비밀번호 변경이 되지않았습니다. 비밀번호를 변경해주세요.
			alert(getMsg("M0014"));
		}else if(resultText == "F_LOGIN_90_OVER"){ // 90일동안 시스템 용이력이 존재하지 않아, 사용자가 블락되었습니다. 관리자에게 문의하여 주세요.
			alert(getMsg("M0015"));
		}else{
			for(var prop in param.map){
				$.cookie(prop, param.get(prop),{
				     "expires" : 365
				});
			}
			//this.location.href = "/common/mainPop.page";
			this.location.href = "/common/main.page";
		}
	}
}

function validationEventMsg(valObjType, objIndex, objId, objName, objValue, valType){
	//commonUtil.debugMsg("validationEventMsg : ", arguments);
	if(objName == "USERID"){
		//return "사용자 ID를 입력하세요.";       //LOGIN_M0002
		return getMsg("M0002");
	}else if(objName == "PASSWD"){
		//return "사용자 Password를 입력하세요."; //LOGIN_M0003
		return getMsg("M0003");
	}else if(objName == "WAREKY"){
		//return "거점을 선택하세요.";			  //LOGIN_M0004
		return getMsg("M0004");
	}else if(objName == "LANGKY"){
		//return "사용 언어를 선택하세요.";		  //LOGIN_M0005
		return getMsg("M0005");
	}
}

function checkEZPlatformApp(){
	if(typeof window.localStorage == 'undefined') {
		//alert("로컬 스토리지를 지원하지 않습니다."); //LOGIN_M0006
		alert(getMsg("M0006"));
		return;
	}
	var version = window.localStorage.getItem('EZPlatformApp');
	if( version != "1.0.0.11" ){
		location.href = '/downloadPlatformApp.html';
	}
}

function linkEZ(){
	window.location.href = '/downloadPlatformApp.html';
}

function changePassword(){
	if(validate.check("searchArea")){
		var param = dataBind.paramData("searchArea");
		param.put("PASSWD","");
		page.linkPopOpen("/common/password.page", param);
	}	
}

function changePasswordNew(){
	if(validate.check("searchArea")){
		var param = new DataMap();		
	    var data = dataBind.paramData("searchArea");
	    param.put("LANGKY",data.get("LANGKY"));
	    param.put("WAREKY",data.get("WAREKY"));
	    param.put("USERID",data.get("USERID"));
    
    	page.linkPopOpen("/mes/index/indexPOP.page", param);
    
    	return;
	}
}

//password 변경 팝업
function changePassword(){
	if(validate.check("searchArea")){
		var param = dataBind.paramData("searchArea");
		var option = "height=530,width=650,resizable=yes";
		page.linkPopOpen("/mes/passwordPop.page", param, option);
	}	

}

function fnRsaEnc(value, rsaPublicKeyModulus, rsaPpublicKeyExponent) {
	var rsa = new RSAKey();
	rsa.setPublic(rsaPublicKeyModulus, rsaPpublicKeyExponent);
	var encValue = rsa.encrypt(value); 
	return encValue;

}


</script>
</head>
<body style="display:none">
	<div class="bg">
		<div class="loginWrap">
			<h1 class="logo"><img src="/common<%=theme%>/images/login/logo.png" alt="air-MES" /></h1>
			<div class="innerWrap" id="searchArea">
				<div class="input id">
					<input type="text" id="USERID" name="USERID" validate="required" />
					<input type="hidden" id="rsaPublicKeyModulus" value="${publicKeyModulus}">
					<input type="hidden" id="rsaPublicKeyExponent" value="${publicKeyExponent}">
				</div>
				<div class="input pw">
					<input type="password" id="PASSWD" name="PASSWD" validate="required" onkeypress="commonUtil.enterKeyCheck(event, 'login()')"/>
				</div>
				<!-- div class="changePassword"><a href="#">비밀번호 변경<img src="/common<%=theme%>/images/login/ico_arrow.png" alt="" /></a></div-->
				<div class="selectWrap">
					<select id="WAREKY" name="WAREKY" validate="required" >
					<%
						for(int i=0;i<list.size();i++){
							row = (DataMap)list.get(i);
					%>
						<option value='<%=row.get("VALUE_COL")%>'>[<%=row.get("VALUE_COL")%>]<%=row.get("TEXT_COL")%></option>
					<%
						}
					%>
					</select>
				</div>
				<div class="selectWrap">
					<select id="LANGKY" name="LANGKY" validate="required" >
					<%
						for(int i=0;i<list1.size();i++){
							row = (DataMap)list1.get(i);
					%>
						<option value='<%=row.get("VALUE_COL")%>'>[<%=row.get("VALUE_COL")%>]<%=row.get("TEXT_COL")%></option>
					<%
						}
					%>
					</select>
				</div>
				<div class="btn login">
					<input type="submit" value="Sign In" onclick="login()" /><br/>
					<!-- button style="margin-top: 8px; width: 108px" onclick="changePassword();">패스워드변경</button -->
				</div>
				<div class="selectWrap">
					<button onclick="linkEZ()">Report Tool [ver.8] Download</button>
					<button onclick="changePasswordNew()">Change password</button>
				</div>
			</div>
			<div class="contact">
				<p class="copywrite">Copyright © 2015 [Hankook Networks] Co., Ltd ALL RIGHTS RESERVED.</p>
			</div>
		</div>
	</div>
	<div class="contentLoading" id="contentLoading"></div>
</body>
</html>