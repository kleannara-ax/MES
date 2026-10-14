<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.common.bean.*,com.common.util.*,com.common.bean.CommonConfig,java.util.*"%>
<%
	String userid = (String)request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY);
	DataMap data = (DataMap)request.getAttribute("data");
	String boardId = request.getParameter("ID");
	String boardSql = (String)request.getAttribute("SQL_ID");
%>
<script type="text/javascript" src="/crosseditor/js/namo_scripteditor.js"></script>
<script type="text/javascript">
	$(document).ready(function(){
		boardList.setContentId('<%=boardId%>', '<%=data.getString("CONTENT_ID")%>');
		uiList.setActive("List", true);
		uiList.setActive("Search", false);
		uiList.setActive("Write", false);
		uiList.setActive("Save", false);
		<%
		if(data.getString("CREUSR").equals(userid)){
		%>
		uiList.setActive("Edit", true);
		uiList.setActive("Delete", true);
		<%
		}else{
		%>
		uiList.setActive("Edit", false);
		uiList.setActive("Delete", false);
		<%
		}
		%>		
		uiList.setActive("Rewrite", true);
	});
</script>