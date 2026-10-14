<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.common.bean.DataMap,java.util.ArrayList,com.common.bean.CommonConfig"%>
<%
	ArrayList list = (ArrayList)request.getAttribute("WAHMACOMBO");
	ArrayList list1 = (ArrayList)request.getAttribute("LANGKY");
	ArrayList list2 = (ArrayList)request.getAttribute("MSG");
	
	DataMap row;
%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>Mobile WMS</title>
<link rel="stylesheet" type="text/css" href="/mobile/css/mobile.css" />
<script type="text/javascript" src="/common/js/jquery.js"></script>
<script type="text/javascript" src="/common/js/json2.js"></script>
<script type="text/javascript" src="/common/js/jquery.cookie.js"></script>
<script type="text/javascript" src="/common/js/dataMap.js"></script>
<script type="text/javascript" src="/common/js/configData.js"></script>
<script type="text/javascript" src="/common/js/commonUtil.js"></script>
<script type="text/javascript" src="/common/js/dataBind.js"></script>
<script type="text/javascript" src="/common/js/input.js"></script>
<script type="text/javascript" src="/common/js/netUtil.js"></script>
<script type="text/javascript" src="/common/js/ui.js"></script>
<script type="text/javascript" src="/common/js/validateUtil.js"></script>
<script>
var msgMap = new DataMap();
<%
for(int i=0;i<list2.size();i++){
	row = (DataMap)list2.get(i);
%>
msgMap.put("<%=row.get("MESGKY")%>","<%=row.get("MESGTX")%>");
<%
}
%>

var $langky;

function getMsg(msgCode){
	msgCode = $langky.val()+"_"+msgCode;
	return msgMap.get(msgCode);
}

function getLabel(){
	return "";
}

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
	$langky = jQuery("#LANGKY");
	
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
	var PASSWD = $.cookie("PASSWD");
	if(PASSWD){
		jQuery("#PASSWD").val(PASSWD);
	}
	
	changeWh();	
	viewInfo();
});

function viewInfo(){
	var tmpMsg1 = getMsg("M0008");
	var tmpMsg2 = getMsg("M0009");
	$("#LOGINMSG1").text(tmpMsg1);
	$("#LOGINMSG2").text(tmpMsg2);
	var tmpVal = $("#LANGKY option:selected").text();
	jQuery("#LANGKY_TX").text(tmpVal);
}

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
				commonUtil.msg("LOGIN_M0001");
			}else{
				for(var prop in param.map){
					$.cookie(prop, param.get(prop),{expires:7});
				}
				this.location.href = "/mobile/main.data";
			}
		}
	}	
}

function changeWh(){
	var tmpVal = $("#WAREKY option:selected").text();
	jQuery("#WAREKY_TX").text(tmpVal);
}
</script>
</head>
<body>
	<div class="login_wrap">
		<div class="main_header">
			<ul>
				<li class="login_tit">WMS System</li>
			</ul>
			<h1>Login</h1>	
			<div class="login_area" id="searchArea">
				<div class="login_box">
					<input type="text" class="id" id="USERID" name="USERID" placeholder="ID"/>
					<input type="password" class="pw" id="PASSWD"  name="PASSWD" placeholder="PASSWORD" />
				</div>
						<%
							row = (DataMap)list.get(0);
						%>
				<div class="select" style="padding:15px 0 0 0;height:35px;"><a id="WAREKY_TX">[<%=row.get("VALUE_COL")%>]<%=row.get("TEXT_COL")%></a>
					<select id="WAREKY" name="WAREKY" validate="required" onChange="changeWh()">
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
						<%
							row = (DataMap)list1.get(0);
						%>
				<div class="select" style="padding:15px 0 0 0;height:35px;"><a id="LANGKY_TX">[<%=row.get("VALUE_COL")%>]<%=row.get("TEXT_COL")%></a>
					<select id="LANGKY" name="LANGKY" validate="required" onChange="viewInfo()" style="width:100%">
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
			</div>
			<div class="login_btn">
				<ul class="btn1" onClick="login()">
					<li class="img"><img src="/mobile/img/ico_login.png" /></li>
					<li class="btn_txt">LOGIN</li>
				</ul>
			</div>
			<div>
				<ul class="login_txt">
					<li id="LOGINMSG1"></li>
					<li class="two" id="LOGINMSG2"></li>
				</ul>		
			</div>
		</div>		
	</div>
</body>