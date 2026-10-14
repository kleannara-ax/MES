<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.common.bean.*,com.common.util.*,com.common.bean.CommonConfig,java.util.*"%>
<%
	String username = request.getSession().getAttribute(CommonConfig.SES_USER_NAME_KEY).toString();
    User user = (User)request.getSession().getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
    String menuky = user.getMenuky();
    String userid = user.getUserid();
    
    //if(!"DRIVER".equals(menuky)) {
        menuky = "MASTER";
    //}
    //MENUKY
%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>창고관리 시스템</title>
<link rel="stylesheet" type="text/css" href="/mobile/css/wmsMobile.css" />
<script type="text/javascript" src="/common/js/jquery.js"></script>
<script type="text/javascript" src="/common/js/json2.js"></script>
<script type="text/javascript" src="/common/js/dataMap.js"></script>
<script type="text/javascript" src="/common/js/configData.js"></script>
<script type="text/javascript" src="/common/js/commonUtil.js"></script>
<script type="text/javascript" src="/common/js/netUtil.js"></script>
<script type="text/javascript" src="/common/js/jquery.cookie.js"></script>
<script type="text/javascript" src="/common/js/input.js"></script>
<script type="text/javascript" src="/common/js/ui.js"></script>
<script type="text/javascript" src="/mobile/js/topMenu.js"></script>
<script type="text/javascript">	
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
		
	});

	function menuOpen(){
		window.top.menuOpen();
	}
	
	function openPage(menuId){
		window.top.openPage(menuId);
	}
	
	function logout(){
		top.logout();
	}
</script>
</head>
<body>
	<div class="main_wrap">
		<div class="main_header">
			<ul>
				<li class="t01" onClick="menuOpen()"><img src="/mobile/img/ico/menu.png" width="22"  ><p>메뉴</p></li>
				<li class="tit">DEMO WMS 창고관리( <%=userid%> )</li>
				<li class="t02"><!-- img src="/mobile/img/ico/mail.png" width="18"  ><p>공지</p--></li>
			</ul>
		</div>
		<div class="user_wrap" id="user_wrap"  >
			<div class="user" ><span class="team"><button onclick="logout()">logout</button></span><%=username%> 님</div>
<%
   if("DEV".equals(menuky) || "MASTER".equals(menuky)) {
%>			
			<div class="box open">
				<table class="tdOpen">
					<colgroup>
						<col />
						<col width="10%"  />
					</colgroup>
					<tr>
						<td>입하관리</td>
						<td><img src="/mobile/img/ico/arr_1.png"/></td>
					</tr>
				</table>
				<ul class="menu" >
					<li onClick="openPage('GR03')"><img src="/mobile/img/ico/bu_dot.png">구매입하</li>
                    <li onClick="openPage('GR04')"><img src="/mobile/img/ico/bu_dot.png">창간이동입하</li>
                    <li onClick="openPage('PT02')"><img src="/mobile/img/ico/bu_dot.png">적치</li>
				</ul>
			</div>
<%
    }

   if("DRIVER".equals(menuky) || "PICKING".equals(menuky) || "DEV".equals(menuky) || "MASTER".equals(menuky)) {
%>
            <div class="box open">
                <table class="tdOpen">
                    <colgroup>
                        <col />
                        <col width="10%" />
                    </colgroup>
                    <tr>
                        <td>출하관리</td>
                        <td><img src="/mobile/img/ico/arr_1.png"/></td>
                    </tr>
                </table>
                <ul class="menu">
<% 
   if("PICKING".equals(menuky) || "DEV".equals(menuky) || "MASTER".equals(menuky)) {
%>                
                    <li onClick="openPage('DL32')"><img src="/mobile/img/ico/bu_dot.png">개별피킹</li>
                    <li onClick="openPage('DL34')"><img src="/mobile/img/ico/bu_dot.png">개별피킹패킹</li>
                    <li onClick="openPage('DL36')"><img src="/mobile/img/ico/bu_dot.png">오더피킹</li>
<% 
   }
%>         
<% 
   if("DEV".equals(menuky) || "MASTER".equals(menuky)) {
%>             
                    <li onClick="openPage('DL52')"><img src="/mobile/img/ico/bu_dot.png">분류완료</li>
                           
<% 
   }
   if("DRIVER".equals(menuky) || "DEV".equals(menuky) || "MASTER".equals(menuky)) {
%> 
                    
                    <li onClick="openPage('DL62')"><img src="/mobile/img/ico/bu_dot.png">상차</li>
                    <li onClick="openPage('DL65')"><img src="/mobile/img/ico/bu_dot.png">센터간이동상차</li>                  
                    <li onClick="openPage('DL73')"><img src="/mobile/img/ico/bu_dot.png">TC입출고</li>
                    <li onClick="openPage('DL65')"><img src="/mobile/img/ico/bu_dot.png">택배상차</li>
<%
   }
%>  
                </ul>
            </div>
<%
   }
   
    if("DEV".equals(menuky) || "MASTER".equals(menuky)) {
%>            
            <div class="box open">
                <table class="tdOpen">
                    <colgroup>
                        <col />
                        <col width="10%" />
                    </colgroup>
                    <tr>
                        <td>재고관리</td>
                        <td><img src="/mobile/img/ico/arr_1.png"/></td>
                    </tr>
                </table>
                <ul class="menu">
                    <li onClick="openPage('SK03')"><img src="/mobile/img/ico/bu_dot.png">상품조회</li>
                    <li onClick="openPage('MV03')"><img src="/mobile/img/ico/bu_dot.png">재고이동</li>
                    <li onClick="openPage('SJ05')"><img src="/mobile/img/ico/bu_dot.png">반품입하</li>
                    <li onClick="openPage('IP02')"><img src="/mobile/img/ico/bu_dot.png">재고실사입력</li> 
                </ul>
            </div>
<%
    }
%>            
		</div>
	</div>		
</body>