<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	String requestUri = request.getRequestURI();
	requestUri = requestUri.substring("/WEB-INF/jsp".length(), requestUri.lastIndexOf("."))+".page";
	String boardType = request.getParameter("TYPE");
	boardType = (boardType == null ? "list": boardType);
	String boardId = request.getParameter("ID");
	String boardSql = (String)request.getAttribute("SQL_ID");
%>
<link rel="stylesheet" type="text/css" href="/board/css/board.css">
<script type="text/javascript" src="/board/js/board.js"></script>
<script type="text/javascript" src="/board/js/boardHead.js"></script>
<script type="text/javascript">
	boardList.setUri('<%=requestUri%>');
</script>