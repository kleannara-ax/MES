<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="project.common.bean.CommonConfig"%>
<%
	String userid = (String)request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY);
	String plant = (String)request.getSession().getAttribute(CommonConfig.SES_USER_PLANT_KEY);
	String procCd = (String)request.getSession().getAttribute(CommonConfig.SES_PROC_CD);
	String machCd = (String)request.getSession().getAttribute(CommonConfig.SES_MACH_CD);
%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>Mobile MES</title>
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
<script type="text/javascript" src="/common/theme/webdek/js/theme.js"></script>
<script type="text/javascript" src="/mobile/js/topMenu.js"></script>
<script type="text/javascript" src="/mobile/js/mobileReq.js"></script>

<script type="text/javascript">	
	var num = 0;
	//로딩 열기
	function loadingOpen() {
		//alert(num);
		if(num ==1){
			loadMenuList();
		}
		num = num + 1;
		
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
		
		<!--$('#title').text("Mobile MES");-->
		var param = new DataMap();
		
		var json = netUtil.sendData({
			url : "/mobile/Mobile/json/usrname.data",
			param : param
		});
		
		if(json && json.data){
			//$("#USRID").text(json.data["NMLAST"] + "   [ " + json.data["WAREKY"] + " ]");
			$("#USRID").text(json.data["NMLAST"]);
		}
		getPlantNm()
		getInv()

	});

	function getPlantNm() {
		var plant ='<%=plant%>'
		console.log('plant',plant)
		var json = reqPlantList();
		console.log('====',json)
		if(json && json.plantList) {
			var list = json.plantList
			for(var i=0;i<list.length;i++) {
				if(list[i]['WERKS'] == plant) {
					$("#plantText").text(list[i]['PLANTNM']);
				}
			}
		}

	}

	function getInv() {
		var json = netUtil.sendData({
			url : "/mobile/Mobile/json/gelInvNm.data",
		});
		console.log('===>',json);
		if(json){
			if(!json['procCd'] || !json['machCd']){
				$("#pdaInv01").click();
			}else {
				$("#gz1").text("/"+json['procNm']);
				$("#gz2").text("/"+json['machNm']);
			}
		}else {
			$("#pdaInv01").click();
		}
	}

	function menuOpen(){
		window.top.menuOpen();
	}

	function reflash(menuId){
		var url = "/mobile/"+menuId+".page";
		window.top.$bodyFrame.attr("src",url);
	}
	function openPage(menuId,name){
		<!--$('#title').text(name);-->
		$("#title1").empty();
		$('#title1').append('<a style="color:white" href="javascript:reflash(\''+menuId+'\')">['+menuId+']</a>');

		var procCd = '<%=procCd%>';
		var machCd = '<%=machCd%>';
		console.log('procCd',procCd)
		console.log('machCd',machCd)

		if(menuId != 'PDA_INV01') {
			if( procCd == '' || procCd == 'null' || machCd == '' || machCd == 'null') {
				$('#title').text('설비호기 선택');
				alert('설비호기 먼저 선택하세요.')
				menuId = 'PDA_INV01';
				PlaySound('e');
			}
		}

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
		netUtil.sendData({
			url:"/mobile/json/logout.page"
		});
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
		console.log('## menuID_json = ', menuID_json);

		param = new DataMap();
		param.put("COMPID","KN");
		param.put("MENUGROUPID","MBL");
		param.put("RANGE_DATA_PARAM",{"map":{},});
		param.put("menuId","MSTMENUGL");

		var menuList = netUtil.sendData({
			module   : "System",
			command  : "MSTTREEMENU",
			param : param
		});

		var menuList = menuList.data;
		console.log('## menuList = ', menuList)
		var menuList2 = menuList;
		var menuList3 = menuList;

		var str = "";
		for(var i=0;i<menuList.length;i++){
			str = "";
			if(menuList[i]['DELETEYN'] != 'Y' && menuList[i]['LEVEL'] == "1") {
				var m1 = menuList[i]['MENUID'];
				var backgroundColor = '';
				if(m1 == 'PDA_INV01') {
					backgroundColor = 'background-color: #4A4A4A';
				}
				str = '<div class="box open" style="'+backgroundColor+'">'
						+'<table class="tdOpen">'
						+	'<colgroup>'
						+		'<col />'
						+		'<col width="10%"  />'
						+	'</colgroup>';
							if(m1 == 'PDA_INV01') {
								/* str+=	'<tr style="background-color: #4A4A4A">';
								str+=	'<td colspan="2" onClick="openPage(\'' + menuList[i]["MENUID"] + '\',\''+menuList[i]["MENUNAME"]+'\')">'+menuList[i]['MENUNAME']+'</td>' */
							}else {
								str+='<tr>';
								str+=	'<td>'+menuList[i]['MENUNAME']+'</td>'
										+		'<td><img src="/mobile/img/ico/arr_1.png"/></td>'
							}
						str+=	'</tr>'
						+'</table>'
						+'<ul class="menu">';
						var m2 = menuList[i]['MENUID'];
						if(m1 == 'PDA_INV01') {
							str+=	'<li id="pdaInv01" onClick="openPage(\'' + menuList[i]["MENUID"] + '\',\''+menuList[i]["MENUNAME"]+'\')"><img src="/mobile/img/ico/bu_dot.png"><span>' + menuList[i]['MENUNAME'] + '</span></li>'
						}
						for(var k=0;k<menuList3.length;k++) {
							if(menuList3[k]['DELETEYN'] != 'Y' && m2 == menuList3[k]['PMENUID'] && menuList3[k]['LEVEL'] == '2') {
								str = str + '<li onClick="openPage(\'' + menuList3[k]["MENUID"] + '\',\''+menuList3[k]["MENUNAME"]+'\')"><img src="/mobile/img/ico/bu_dot.png"><span>' + menuList3[k]['MENUNAME'] + '</span></li>';
						}
				}
				str = str
						+	'</ul>'
						+'</div>';
				$("#user_wrap").append(str);
			}
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
				<li class="t01" onClick="menuOpen()"><img src="/mobile/img/ico/top_icon_menu.png" width="22"><p CL="STD_MENUID"></p></li>
				<li class="tit" id="title"><img src="/mobile/img/logo.png" /></li>
				<!-- <li class="t02" id="title1"></li> -->
				<!-- <li class="t02"><img src="/mobile/img/ico/mail.png" width="18"  ><p>공지</p></li> -->
			</ul>
		</div>
		<div class="user" style="height:18px;background-color: #4da2d9"> <!--#2a3883-->
			<span style="padding-left:0px;float:left;" id="plantText"></span>
			<span id="gz1"></span>
			<span id="gz2"></span>
			<span style="float:right">
				<span  id="USRID" ></span>
			</span>
		</div>
		<div class="user_wrap" id="user_wrap">
			<div class="user" style="height:15px;"> <!--#2a3883-->
				<span style="float:right">
					<span class="team">
					<button onclick="logout()"><img src="/mobile/img/ico/top_icon_logout.png" width="22">로그아웃</button></span>
				</span>
			</div>
				<div style="clear: both"></div>
		   </div>
	</div>		
</body>