<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.common.bean.DataMap,java.util.*,com.common.bean.CommonConfig"%>
<%
	//DataMap label = (DataMap)request.getAttribute("label");
	//DataMap message = (DataMap)request.getAttribute("message");
	String langky = request.getSession().getAttribute(CommonConfig.SES_USER_LANGUAGE_KEY).toString();
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
<script type="text/javascript" src="/common/js/dataMap.js"></script>
<script type="text/javascript" src="/common/js/configData.js"></script>
<script type="text/javascript" src="/common/js/commonUtil.js"></script>
<script type="text/javascript" src="/common/js/netUtil.js"></script>
<script type="text/javascript">
function logout(){
	location.href = "/mobile/json/logout.page";
}
</script>
<script type="text/javascript">
	var menuOpenState = false;
	var $mainFrame;
	var $topFrame;
	var $bodyFrame;
	$(document).ready(function(){
		$mainFrame = $("#mainFrame");
		$topFrame = $("#topFrame");
		$bodyFrame = $("#bodyFrame");
		
		menuOpen();
	});
	function menuOpen(){
		if(menuOpenState){
			$mainFrame.attr("rows","47px,*");
			menuOpenState = false;
		}else{
			$mainFrame.attr("rows","*,0px");
			menuOpenState = true;
		}
	}
	function openPage(menuId){
		var url = "/mobile/"+menuId+".page";
		$bodyFrame.attr("src",url);
		menuOpen();
	}
	function menuHeightReturn(){
		var topH = $topFrame.height();
		return topH;
	}
</script>
</head>
<frameset id="mainFrame" name="topFrame" rows="47px,*" noresize framespacing='0' frameborder='no' border='0' >
    <frame id="topFrame" name="header" src="/mobile/top.data" noresize framespacing='0' frameborder='no' border='0' scrolling="no">
    <frame id="bodyFrame" name="main" src="/mobile/info.page" noresize framespacing='0' frameborder='no' border='0' >
</frameset>