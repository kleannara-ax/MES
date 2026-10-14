<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<title>index left</title>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/left_green.css"/>
<script type="text/javascript" src="/common/js/jquery.js"></script>
<script type="text/javascript" src="/common/js/json2.js"></script>
<script type="text/javascript" src="/common/js/dataMap.js"></script>
<script type="text/javascript" src="/common/js/configData.js"></script>
<script type="text/javascript" src="/common/js/commonUtil.js"></script>
<script type="text/javascript" src="/common/js/netUtil.js"></script>
<%@ include file="/common/include/webdek/tree.jsp" %>
<script type="text/javascript">
$(document).ready(function(){
	treeList.setTree({
    	id       : "treeList",
    	module   : "Common",
		command  : "MENU_TREE",
		pkCol    : "MENUID",
	    pidCol   : "PMENUID",
	    nameCol  : "MENUNAME",
	    sortCol  : "SORTORDER",
	    editable : false,
	    isMove   : false,
	    isCheck  : false
    });

	searchList();
});

function searchList(){
	var param = new DataMap();
	param.put("COMPID","WDSCM");
	param.put("MENUGID","ALL");
	treeList.treeList({
		id : "treeList",
    	param : param
	});
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

</script>
</head>
<body>
<!-- left_wrap -->
<div class="content_wrap">
	<ul id="treeList" class="ztree" style="width:260px; overflow:auto;"></ul>
</div>
<!-- // left_wrap -->
</body>
</html>