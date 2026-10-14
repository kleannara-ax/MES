<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	Exception ex = (Exception)request.getAttribute("exceptionMsg");
	StackTraceElement[] erList = ex.getStackTrace();
	String msg = "Exception message \n\r" + ex.getMessage()+"\n\r";
	for(int i=0;i<erList.length;i++){
		msg += erList[i].toString()+"\n\r";
	}
%>
<%=msg%>