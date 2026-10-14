<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.common.bean.DataMap,java.util.ArrayList,com.common.bean.CommonConfig"%>
<%
	ArrayList list = (ArrayList)request.getAttribute("WAHMACOMBO");
	ArrayList list1 = (ArrayList)request.getAttribute("LANGKY");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<title>WMS</title>
<link rel="stylesheet" type="text/css" href="/common/css/login_lgchem.css">
<script type="text/javascript" src="/common/js/jquery.js"></script>
<script type="text/javascript" src="/common/js/jquery-ui.js"></script>
<script type="text/javascript" src="/common/js/json2.js"></script>
<script type="text/javascript" src="/common/js/jquery.cookie.js"></script>
<script type="text/javascript" src="/common/js/dataMap.js"></script>
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
<script>
//로딩 열기
function loadingOpen() {

	var loader = $('<div class="contentLoading"></div>').appendTo('body');

	loader.stop().animate({
		top : '0px'
	}, 30, function() {
	});
}

// 로딩 닫기
function loadingClose() {

	var loader = $('.contentLoading');

	loader.stop().animate({
		top : '100%'
	}, 30, function() {
		loader.remove();
	});
}

$(document).ready(function(){
	inputList.setCombo();
	$("select[name=WAREKY]").val("WH01");
	$("select[name=LANGKY]").val("KO");
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
	var PASSWD = $.cookie("PASSWD");
	if(PASSWD){
		jQuery("#PASSWD").val(PASSWD);
	}
});

function login(){
	//this.location.href = "/common/main.page";
	if(validate.check("searchArea")){
		var param = dataBind.paramData("searchArea");
		var json = netUtil.sendData({
			url : "/common/json/login.data",
			param : param
		});
		
		if(json && json.data){
			if(json.data == "F"){
				commonUtil.msg("아이디 또는 비밀번호가 일치 하지 않습니다.");
			}else{
				for(var prop in param.map){
					$.cookie(prop, param.get(prop));
				}
				this.location.href = "/common/main.page";
			}
		}
	}	
}

function validationEventMsg(valObjType, objIndex, objId, objName, objValue, valType){
	//commonUtil.debugMsg("validationEventMsg : ", arguments);
	if(objName == "USERID"){
		return "사용자 ID를 입력하세요.";
	}else if(objName == "PASSWD"){
		return "사용자 Password를 입력하세요.";
	}else if(objName == "WAREKY"){
		return "거점을 선택하세요.";
	}else if(objName == "LANGKY"){
		return "사용언어를 선택하세요.";
	}
}
</script>
</head>
<body>
<object width="0" height="0" id="ezgen" classid="clsid:9C340C2D-97D9-40ae-8E3E-B1CE2C0EFF5A" codeBase="/common/include/ocx/hnwactivw_8_0_0_24.cab#version=8,0,0,24" style="left: 9px; top: 0px;"></object>
<div class="bg">
<div class="loginWrap">
	<center>
	<h1>Warehouse Management System</h1>
	<h2>Energy Solution</h2>
	</center>
	<br/><br/><br/>
	<div class="innerWrap" id="searchArea">
		<div class="input id"><input type="text" id="USERID" name="USERID" validate="required" value="DEV" /></div>
		<div class="input pw"><input type="text" id="PASSWD" name="PASSWD" validate="required" value="1" /></div>
		<!-- div class="changePassword"><a href="#">비밀번호 변경<img src="/common/images/login/ico_arrow.png" alt="" /></a></div-->
		<div class="selectWrap">
			<select id="WAREKY" name="WAREKY" validate="required" >
			<%
				DataMap row;
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
		<div class="btn login"><input type="submit" value="Login" onclick="login()" /></div>
	</div>
	<!-- div class="contact">
		<p class="copywrite">Copyright © 2016 [emFromtier] Co., Ltd ALL RIGHTS RESERVED.</p>
	</div -->
</div>
</div>
</body>
</html>