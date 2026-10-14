<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.common.bean.*,com.common.util.*,com.common.bean.CommonConfig,java.util.*"%>
<%
	DataMap data = (DataMap)request.getAttribute("data");
	String boardId = request.getParameter("ID");
	String boardSql = (String)request.getAttribute("SQL_ID");
%>
<script type="text/javascript">
	$(document).ready(function(){
		uiList.setActive("List", false);
		uiList.setActive("Search", true);
		uiList.setActive("Write", true);
		uiList.setActive("Save", false);
		uiList.setActive("Edit", false);
		uiList.setActive("Delete", false);
		uiList.setActive("Rewrite", false);
	});
</script>