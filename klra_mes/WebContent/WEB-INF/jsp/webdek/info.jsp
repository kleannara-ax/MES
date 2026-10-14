<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="project.common.bean.CommonConfig"%>
<%
	String theme =(String)request.getSession().getAttribute(CommonConfig.SES_USER_THEME_KEY);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
</head>
<body>
<%-- <img src="/common<%=theme%>/images/data.png" width="800px"/> --%>
</body>
</html>