<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="project.common.bean.*,java.util.*"%>
<%
	String userid = request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY).toString();
	String username = request.getSession().getAttribute(CommonConfig.SES_USER_NAME_KEY).toString();
	String langky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_LANGUAGE_KEY);
	String compid = (String)request.getSession().getAttribute(CommonConfig.SES_USER_COMPANY_KEY);
    String deptid = (String)request.getSession().getAttribute(CommonConfig.SES_DEPT_ID_KEY);
    String wareky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_WHAREHOUSE_KEY);
    
    BaseUser user = (BaseUser)session.getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
	
	String theme =(String)request.getSession().getAttribute(CommonConfig.SES_USER_THEME_KEY);
	
	List<DataMap> mlist = (List)request.getSession().getAttribute(CommonConfig.SES_USER_ROOT_MENU_KEY);
	
	/*  2022-05-09(월요일)-안상현, 부서명(국문) 추가 */
	String dept_kr_nm = (String)request.getSession().getAttribute(CommonConfig.SES_DEPT_NM_KEY);
%>
<!doctype html>
<html lang="ko">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta charset="utf-8">
<title></title>
<meta name="viewport" content="width=1150">
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/top_green.css"/>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/top3.css"/>
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
<script type="text/javascript" src="/common<%=theme%>/js/theme.js"></script>
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

		$(document).on('input', '#IND_BCD', function(){
		    $(this).val($(this).val().replace(/[^A-Za-z0-9]/g, ''));
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
	if(!commonUtil.msgConfirm("MASTER_WAREKYCHANGE")){// 창고를 변경하는 경우 열려진 화면이 모두 닫힙니다.\n 변경 하시겠습니까?
		$("[name=WAREKY]").val(lastWareKey);
		return;
	}
	var param = dataBind.paramData("searchArea");
	lastWareKey = param.get("WAREKY");
	var json = netUtil.sendData({
		url : "/mes/common/json/changeWareky.data",
		param : param
	});
	
	if(json && json.data){
		
	}
	
	window.top.closeAll();
}

function logout(){
	window.top.location.href = "/mes/json/logout.page";
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
	<div class="content_top" >
		<div class="logos">
			<h1 class="GCLC">
				<a href="#none"><span></span></a>
			</h1>
		</div>
		<!-- ul class="topmenu_tab">
			<li class=""><a href="#tab1"><span>　</span></a></li>
			<li class=""><a href="#tab2"><span>기준정보</span></a></li>
			<li class=""><a href="#tab3"><span>운송관리</span></a></li>
			<li class=""><a href="#tab4"><span>Demo</span></a></li>
		</ul-->
		<div class="rightArea" id="searchArea">
			<div class="selection">
				<select Combo="Common,WAHMACOMBO" name="WAREKY" onChange="changeWareky()" >
					<!-- <option value="CP">[CP]청주공장</option>
					<option value="UP">[UP]음성공장</option> -->
				</select>
			</div>
		<ul class="header_right">
			<!-- li class="last_time">최종접속시간 : </li>
			<li class="last_time" id="lastTime"><%=user.getLogindate()%></li-->
			<li class="user_nm">&nbsp; &nbsp;
				<span>
					<%=dept_kr_nm%> / <%=username%>
				</span> 님
			</li>
			<!-- li class="alert"><a href="#">icon</a></li-->
			<!-- li class="setting" onClick="changePage('CM1107')"><a href="#">icon</a></li-->
			<!-- <li class="alram"><a href="#">icon</a></li>
			<li class="setting"><a href="#">icon</a></li> -->
			<li class="logout" onClick="logout()"><a href="#">icon</a></li>
		</ul>
		</div>
	</div>
</body>
</html>