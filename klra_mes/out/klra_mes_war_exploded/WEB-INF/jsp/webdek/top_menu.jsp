<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="project.common.bean.*,java.util.*"%>
<%
	String userid = request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY).toString();
	String username = request.getSession().getAttribute(CommonConfig.SES_USER_NAME_KEY).toString();
	String langky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_LANGUAGE_KEY);
	String compid = (String)request.getSession().getAttribute(CommonConfig.SES_USER_COMPANY_KEY);
    String deptid = (String)request.getSession().getAttribute(CommonConfig.SES_DEPT_ID_KEY);
	
	BaseUser user = (BaseUser)session.getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
	
	String theme =(String)request.getSession().getAttribute(CommonConfig.SES_USER_THEME_KEY);
	
	List<DataMap> mlist = (List)request.getSession().getAttribute(CommonConfig.SES_USER_ROOT_MENU_KEY);
%>
<!doctype html>
<html lang="ko">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta charset="utf-8">
<title></title>
<meta name="viewport" content="width=1150">
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/top_green.css"/>
<script type="text/javascript" src="/common/js/jquery.js"></script>
<script type="text/javascript" src="/common/js/jquery-ui.js"></script>
<script type="text/javascript" src="/common/js/json2.js"></script>
<script type="text/javascript" src="/common/js/dataMap.js"></script>
<script type="text/javascript" src="/common/js/configData.js"></script>
<script type="text/javascript" src="/common/js/label.js"></script>
<script type="text/javascript" src="/common/lang/label-<%=langky%>.js"></script>
<script type="text/javascript" src="/common/lang/message-<%=langky%>.js"></script>
<script type="text/javascript" src="/common/js/commonUtil.js"></script>
<script type="text/javascript" src="/common/js/dataBind.js"></script>
<script type="text/javascript" src="/common/js/site.js"></script>
<script type="text/javascript" src="/common/js/input.js"></script>
<script type="text/javascript" src="/common/js/netUtil.js"></script>
<script type="text/javascript" src="/common/js/validateUtil.js"></script>
<script type="text/javascript" src="/common/js/ui.js"></script>

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
	$('.tab').tabs();
			
	inputList.setCombo();
	
	uiList.UICheck();
	
	//logoEffect();
});


function logout(){
	window.top.location.href = "/common/json/logout.page";
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
		  backgroundColor: "#ffffff",
		  color: "#ffffff"
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

var lastWareKey;
$(document).ready(function(){
	uiList.UICheck();
	lastWareKey = $("[name=WAREKY]").val();
	
	var lastTime = $("#lastTime").text();
	lastTime = uiList.getDataFormat([configData.INPUT_FORMAT_DATETIMESECOND], lastTime, true);
	$("#lastTime").text(lastTime);
});

$(document).ready(function() {
    $(".topmenu_tab li").click(function(){
      var i = $(this).index();
      $(".topmenu_tab li").removeClass("on");
      $(this).addClass("on");
    });
  });
</script>
</head>
<body style="min-width:1100px">
	<div class="content_top2" >
		<div class="combos">
			<h1>
				<select><option>선택</option><option>공</option></select>
				<select><option>선택</option><option>궁</option></select>
			</h1>
		</div>
		<ul class="topmenu_tab">
				<li><a href="#tab1"><span>시스템설정</span></a></li>
				<li><a href="#tab2"><span>코드관리</span></a></li>
				<li><a href="#tab3"><span>메뉴관리</span></a></li>
				<li><a href="#tab4"><span>사용자관리</span></a></li>
				<li><a href="#tab5"><span>매출분석</span></a></li>
				<li><a href="#tab6"><span>매장현황</span></a></li>
			</ul>
			
			<!-- <div id="tab1-1">텝1</div>
			<div id="tab1-2">텝1</div> -->
		<ul class="header_right">
			<!-- li class="last_time">최종접속시간 : </li>
			<li class="last_time" id="lastTime"><%=user.getLogindate()%></li-->
			<li class="user_nm"><span><%if(("").equals(deptid) || deptid == null) { %> <%} else{ %> <%=deptid %> <%} %><%=username%></span> 님</li>
			<!-- li class="alert"><a href="#">icon</a></li-->
			<!-- li class="setting" onClick="changePage('CM1107')"><a href="#">icon</a></li-->
			<li class="logout" onClick="logout()"><a href="#">icon</a></li>
		</ul>
		
	</div>
</body>
</html>