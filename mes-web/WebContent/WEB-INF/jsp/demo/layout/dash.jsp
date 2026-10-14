<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Input default</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){

	});
	
	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "dash1"){
			page.linkPopOpen("/theme/siwms/dash1.page");
		}else if(btnName == "dash2"){
			page.linkPopOpen("/theme/siwms/dash2.page");
		}
	}
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="dash1 SEARCH BTN_DASH1"></button>
		<button CB="dash2 SEARCH BTN_DASH2"></button>
	</div>
</div>
<%@ include file="/common/include/bottom.jsp" %>
</body>
</html>