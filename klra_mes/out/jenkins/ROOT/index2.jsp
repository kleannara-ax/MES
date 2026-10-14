<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	String url = request.getRequestURL().toString();
	String serverName = request.getServerName().toString(); 
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<script type="text/javascript" src="/common/js/jquery.js"></script>
<script type="text/javascript" src="/common/js/commonUtil.js"></script>
<title>WEBDeK</title>
<script>
//this.location.href = "/index2.page";
</script>
</head>
<body>
<a href="/index.page" target="_blank">webdek</a><br/>
<a href="/index2.page" target="_blank">webdek2</a><br/>
<a href="/mobile/index.page" target="_blank">webdek2 mobile</a><br/>
<a href="/index_root.page" target="_blank">webdek_root</a><br/>
<a href="/common/html/newGrid.html" target="_blank">newGrid.html</a><br/>
<a href="/redeess/jsp/main.jsp" target="_blank">redeess</a><br/>
<a href="/index3.page" target="_blank">webdek3</a><br/>
</body>
</html>