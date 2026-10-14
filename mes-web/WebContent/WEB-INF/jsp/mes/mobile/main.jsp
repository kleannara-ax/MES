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
<title>창고관리 시스템</title>
<link rel="stylesheet" type="text/css" href="/mobile/css/mobile.css" />
<script type="text/javascript" src="/common/js/jquery.js"></script>
<script type="text/javascript" src="/common/js/json2.js"></script>
<script type="text/javascript" src="/common/js/dataMap.js"></script>
<script type="text/javascript" src="/common/js/configData.js"></script>
<script type="text/javascript" src="/common/js/commonUtil.js"></script>
<script type="text/javascript" src="/common/js/netUtil.js"></script>
<script type="text/javascript">
var labelFrame = true;
var msgFrame = true;

CommonLabel = function() {
	this.labelHistory = new Array();
	this.label = new DataMap();
};

CommonLabel.prototype = {
	getLabel : function(key, type) {
		if(this.label.containsKey(key)){
			var ltxt = this.label.get(key);
			this.labelHistory.push(key+" "+ltxt.split(configData.DATA_COL_SEPARATOR)[type]);
			return ltxt.split(configData.DATA_COL_SEPARATOR)[type];
		}else{
			return key;
		}
	},
	resetHistory : function(){
		this.labelHistory = new Array();
	},
	showHistory : function() {
		var data = this.labelHistory.join("\n");
		if (window.clipboardData) { // Internet Explorer
	        window.clipboardData.setData("Text", data);
	    } else {  
	    	var temp = prompt("Ctrl+C를 눌러 클립보드로 복사하세요", data);
	    }
	},
	toString : function() {
		return "CommonLabel";
	}
};

var commonLabel = new CommonLabel();

CommonMessage = function() {
	this.message = new DataMap();
};

CommonMessage.prototype = {
	getMessage : function(key) {
		var mtxt = this.message.get(key);
		if(mtxt){
			commonLabel.labelHistory.push(key+" "+mtxt.split(configData.DATA_COL_SEPARATOR)[1]);
			return mtxt.split(configData.DATA_COL_SEPARATOR)[1];
		}else{
			return key;
		}
	},
	toString : function() {
		return "CommonMessage";
	}
};

var commonMessage = new CommonMessage();

function getLabel(key, type){
	if(!type){
		type = 1;
	}
	return commonLabel.getLabel(key, type);
}

function getMessage(key){
	return commonMessage.getMessage(key);
}
</script>
<script type="text/javascript" src="/common/lang/label-<%=langky%>.js"></script>
<script type="text/javascript" src="/common/lang/message-<%=langky%>.js"></script>
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
		var urlDir = "mobile";
		if(menuId.indexOf("GR") >= 0) {
			urlDir = "inbound";
        }else if(menuId.indexOf("DL") >= 0) {
        	urlDir = "outbound";
        }else if(menuId.indexOf("PT") >= 0) {
            urlDir = "task";
        }else if(menuId.indexOf("SK") >= 0) {
            urlDir = "admin";
        }else if(menuId.indexOf("IP") >= 0 || menuId.indexOf("MV") >= 0 || menuId.indexOf("SJ") >= 0) {
        	urlDir = "inventory";
        }
		var url = "/wms/"+urlDir+"/"+menuId+".page";
				
		$bodyFrame.attr("src",url);
		menuOpen();
		activeMenuId = menuId;
	}
	
	var activeMenuId;
	function getMenuId(){
		return activeMenuId;
	} 
	
	function logout(){
        location.href = "/wms/mobile/index.page";
	}
</script>
</head>
<frameset id="mainFrame" name="topFrame" rows="47px,*" noresize framespacing='0' frameborder='no' border='0' >
    <frame id="topFrame" name="header" src="/wms/mobile/top.data" noresize framespacing='0' frameborder='no' border='0' scrolling="no">
    <frame id="bodyFrame" name="main" id="main" noresize framespacing='0' frameborder='no' border='0' >
</frameset>