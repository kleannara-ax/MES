<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.common.bean.CommonConfig"%>
<%
	String userid = (String)request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY);
%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>Mobile WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<link rel="stylesheet" type="text/css" href="/mobile/css/mobile.css" />
<script type="text/javascript" src="/common/js/jquery.js"></script>
<script type="text/javascript" src="/common/js/json2.js"></script>
<script type="text/javascript" src="/common/js/dataMap.js"></script>
<script type="text/javascript" src="/common/js/configData.js"></script>
<script type="text/javascript" src="/common/js/label.js"></script>
<script type="text/javascript" src="/common/lang/label-<%=langky%>.js"></script>
<script type="text/javascript" src="/common/lang/message-<%=langky%>.js"></script>
<script type="text/javascript" src="/common/js/commonUtil.js"></script>
<script type="text/javascript" src="/common/js/netUtil.js"></script>
<script type="text/javascript" src="/common/js/jquery.cookie.js"></script>
<script type="text/javascript" src="/common/js/input.js"></script>
<script type="text/javascript" src="/common/js/ui.js"></script>
<script type="text/javascript" src="/mobile/js/topMenu.js"></script>

<script type="text/javascript">	

	//로딩 열기
	function loadingOpen() {
		loadMenuList();
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
		uiList.UICheck();
		
		$('#title').text("Mobile WMS");
		var param = new DataMap();
		
		var json = netUtil.sendData({
			url : "/mobile/Mobile/json/usrname.data",
			param : param
		});
		
		if(json && json.data){
			$("#USRID").val(json.data["NMLAST"] + "   [ " + json.data["WAREKY"] + " ]");
		} 
	});


	function menuOpen(){
		$('#title').text("Mobile WMS");
		window.top.menuOpen();
	}
	
	function openPage(menuId){
		window.top.openPage(menuId);

// 		if(menuId.length > 7){
// 			menuId = menuId.substr(0,6);
// 		}
// 		var menuLabel = "MENU_"+menuId;
// 		var labelTxt = uiList.getLabel(menuLabel);
		
// 		$('#title').text(labelTxt);
	}
	
	function logout(){
		//top.logout();
		location.href="/mobile/index.page";
	}
	
	function loadMenuList(){
		var param = new DataMap();
		param.put("USERID", "<%=userid%>");
		
		var menuID_json = netUtil.sendData({
			module : "Mobile",
			command : "GETMENUID",
			sendType : "map",
			param : param
		});
		
		param.put("MENUKY",menuID_json.data["MENUKY"]);
		param.put("LANGKY","<%=langky%>");
		var menuList_json = netUtil.sendData({
			module : "Mobile",
			command : "GETMENULIST",
			sendType : "list",
			param : param
		});
		var str = "";
		for(var i=0;i<menuList_json.data.length;i++){
			str = "";
			
			str = '<div class="box open">'
					+'<table class="tdOpen">'
					+	'<colgroup>'
					+		'<col />'
					+		'<col width="10%"  />'
					+	'</colgroup>'
					+	'<tr>'
					+		'<td>'+menuList_json.data[i]["LBLTXS"]+'</td>'
					+		'<td><img src="/mobile/img/ico/arr_1.png"/></td>' 
					+	'</tr>'
					+'</table>'
					+'<ul class="menu" >';
			param.put("AMNUID",menuList_json.data[i]["MENUID"]);
			var menuDetail_json = netUtil.sendData({
				module : "Mobile",
				command : "GETMENUDETAIL",
				sendType : "list",
				param : param
			});		
			for(var j=0;j<menuDetail_json.data.length;j++){
				str = str + '<li onClick="openPage(\''+menuDetail_json.data[j]["PGPATH"]+'\')"><img src="/mobile/img/ico/bu_dot.png"><span>'+menuDetail_json.data[j]["LBLTXS"]+'</span></li>';
			}
			str = str 
			    +	'</ul>'
			    +'</div>';
			$("#user_wrap").append(str);
		}
		$('#user_wrap table.tdOpen').on('click', function(){
			var element = $(this).parent('div');
			
			if (element.hasClass('open')) {
				element.removeClass('open');
				element.find('li').removeClass('open');
				element.find('ul').slideUp();
				element.find('img').attr('src','/mobile/img/ico/arr_2.png');
			}else {
				element.addClass('open');
				element.children('ul').slideDown();
				element.siblings('li').children('ul').slideUp();
				element.siblings('li').removeClass('open');
				element.siblings('li').find('li').removeClass('open');
				element.siblings('li').find('ul').slideUp();
				element.find('img').attr('src','/mobile/img/ico/arr_1.png');	
			}
		});
	}
</script>
</head>
<body>
	<div class="main_wrap">
		<div class="main_header">
			<ul>
				<li class="t01" onClick="menuOpen()"><img src="/mobile/img/ico/menu.png" width="22"><p CL="STD_MENUID"></p></li>
				<li class="tit" id="title"></li>
				<!-- <li class="t02"><img src="/mobile/img/ico/mail.png" width="18"  ><p>공지</p></li> -->
			</ul>
		</div>
		<div class="user_wrap" id="user_wrap">
			<div class="user"><span class="team"><button onclick="logout()">logout</button></span><input class="name" type="text" id="USRID" readonly="readonly" /></div>
			
		</div>
	</div>		
</body>