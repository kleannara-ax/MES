<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.common.bean.DataMap,com.common.bean.CommonConfig"%>
<%
	String wareky = request.getSession().getAttribute(CommonConfig.SES_USER_WHAREHOUSE_KEY).toString();
	String userid = request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY).toString();
	String username = request.getSession().getAttribute(CommonConfig.SES_USER_NAME_KEY).toString();
	String compky = request.getSession().getAttribute(CommonConfig.SES_USER_COMPANY_KEY).toString();
%>
<!doctype html>
<html lang="ko">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta charset="utf-8">
<title></title>
<meta name="viewport" content="width=1150">
<link rel="stylesheet" type="text/css" href="/common/css/reset.css">
<link rel="stylesheet" type="text/css" href="/common/css/header.css">
<script type="text/javascript" src="/common/js/jquery.js"></script>
<script type="text/javascript" src="/common/js/jquery-ui.js"></script>
<script type="text/javascript" src="/common/js/json2.js"></script>
<script type="text/javascript" src="/common/js/dataMap.js"></script>
<script type="text/javascript" src="/common/js/configData.js"></script>
<script type="text/javascript" src="/common/js/commonUtil.js"></script>
<script type="text/javascript" src="/common/js/dataBind.js"></script>
<script type="text/javascript" src="/common/js/input.js"></script>
<script type="text/javascript" src="/common/js/netUtil.js"></script>
<script type="text/javascript" src="/common/js/validateUtil.js"></script>
<script type="text/javascript" src="/common/js/ui.js"></script>
<script>
(function() {

	$(function() {

		var gnb = $('.gnb')
			, trigger = gnb.find('.list').children('li')
			, list = trigger.children('ul');

		trigger.each(function() {
			var _this = $(this)
				, thisTrigger = _this.children('a')
				, thisList = _this.children('ul');

			thisTrigger.on({
				click : function() {
					list.hide();
					thisList.show();

					trigger.removeClass('active');
					_this.addClass('active');
				}
			});
		});
	});

})();
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
	$("select[name=WAREKY]").val("<%=wareky%>");
	
	uiList.UICheck();
	
	//logoEffect();
});

function changeWareky(){
	var param = dataBind.paramData("searchArea");
	var json = netUtil.sendData({
		url : "/wms/common/json/changeWareky.data",
		param : param
	});
	
	if(json && json.data){
		
	}
	
	window.top.closeAll();
}

function logout(){
	location.href = "/common/json/logout.page";
}

function changePage(menuId){	
	window.top.menuPage(menuId);
}

function logoEffectStart(){
	state = true;
	effectType = true;
	logoEffect();
}

function logoEffectStop(){
	state = false;
	effectType = false;
	logoEffect();
	$( "#effect" ).stop(true,true);
}

var state = true;
var effectType = true;
function logoEffect(){	
	if ( state ) {
		$( "#effect" ).animate({
		  backgroundColor: "#699bf8",
		  color: "#699bf8"
		}, 1000 );
	} else {
		$( "#effect" ).animate({
		  backgroundColor: "#2f313a",
		  color: "#2f313a"
		}, 1000 );
	}
	
	if(effectType){
		state = !state;
		setTimeout(logoEffect, 1000);
	}	
}
</script>
</head>
<body>
<!-- header -->
<div class="header">
	<div class="innerContainer">
		<span class="logo">
			<a href="#" onClick="window.top.reloadPage()">
				<img src="/common/images/logologo.png" alt="" />
			</a>
		</span>
		<div class="rightArea" id="searchArea">
			<div class="selection">
				<select Combo="Wms,WAHMACOMBO" name="WAREKY" onChange="changeWareky()" >
				</select>
			</div>
			<div class="util">
				<p class="user" ><%=username%></p>
				<button class="logOut" type="button" onClick="logout()">로그아웃</button>
				<!-- button class="setting" type="button"><a href="/common/demo/tool/sql.jsp" target="_TOP">설정</a></button-->
			</div>			
		</div>
	</div>
</div>
<!-- //header -->
</body>
</html>