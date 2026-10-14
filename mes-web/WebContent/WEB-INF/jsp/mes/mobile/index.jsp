<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.common.bean.DataMap,java.util.ArrayList,com.common.bean.CommonConfig"%>
<%
    ArrayList list = (ArrayList)request.getAttribute("WAHMACOMBO");
	//ArrayList list = (ArrayList)request.getAttribute("WAHMACOMBO");
%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>창고관리 시스템</title>
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
	/*
	$("select[name=WAREKY]").val("WCD1");
	$("select[name=LANGKY]").val("KO");
	var WAREKY = $.cookie("WAREKY");
	if(WAREKY){
		jQuery("#WAREKY").val(WAREKY);
	}
	var LANGKY = $.cookie("LANGKY");
	if(LANGKY){
		jQuery("#LANGKY").val(LANGKY);
	}
	*/
	var USERID = $.cookie("USERID");
	if(USERID){
		jQuery("#USERID").val(USERID);
	}
	//var PASSWD = $.cookie("PASSWD");
	//if(PASSWD){
	//	jQuery("#PASSWD").val(PASSWD);
	//}
	
	if($.isApp){
		$.callApp('40', {'callbackFn' : 'getDeviceInfo'});
	}
});

var deviceToken;
var platformType;
function getDeviceInfo(data){
	// DEVICE_TOKEN	 : 장비 push 토큰
	// PLATFORM_TYPE : 장비유형 (안드로이드:A, IOS:I)
	var obj = eval("("+data+")");
	deviceToken = obj["DEVICE_TOKEN"];
	platformType = obj["PLATFORM_TYPE"];
}

function login(){
	//this.location.href = "/common/main.page";
	if(validate.check("searchArea")){
		var param = dataBind.paramData("searchArea");
		param.put("LANGKY", "KO");
		param.put("WAREKY", $("#WAREKY").val());
		var json = netUtil.sendData({
			url : "/common/json/login.data",
			param : param
		});
		
		if(json && json.data){
			if(json.data == "F"){
				commonUtil.msg("아이디 또는 비밀번호가 일치 하지 않습니다.");
			}else{
				for(var prop in param.map){
					$.cookie(prop, param.get(prop),{expires:7});
				}
				this.location.href = "/wms/mobile/main.page?deviceToken="+deviceToken+"&platformType="+platformType;
			}
		}
	}	
}
</script>
</head>
<body>
	<div class="login_wrap">
		<div class="main_header">
			<ul>
					<li class="login_tit">더파머스 창고관리</li>
			</ul>
            <h1>Login</h1>	
			<div class="login_area" id="searchArea">
				<div class="login_box">
					<input type="text" class="id" id="USERID" name="USERID" placeholder="아이디"/>
					<input type="password" class="pw" id="PASSWD"  name="PASSWD" placeholder="비밀번호" />
				</div>
			</div>  
			 
            <div style="text-align: center;">
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
            </br> 
            <div class="login_btn">
                <ul class="btn3" onClick="login()">
                        <li class="img"><img src="/mobile/img/ico_login.png" /></li>
                        <li class="btn_txt">로그인</li>
                </ul>
            </div>
			
			<div>
				<ul class="login_txt">
					<li>PC통합관리 시스템과 동일한 아이디/비밀번호로 로그인 하시기 바랍니다.</li>
					<li class="two">아이디/비밀번호 확인은 PC통합관리 시스템에서 확인 하시기 바랍니다.</li>
				</ul>		
			</div>
		</div>		
	</div>
</body>