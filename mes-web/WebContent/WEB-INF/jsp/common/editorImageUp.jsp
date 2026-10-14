<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.common.bean.DataMap,com.common.bean.CommonConfig"%>
<%
	DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

	String url = "";
	
	url += request.getParameter("callback")+"?callback_func="+request.getParameter("callback_func");
	
	String fileName = (String)map.get("FNAME");
	fileName = new String(fileName.getBytes("UTF-8"), "8859_1");
	
	url += "&bNewLine=true";
	url += "&sFileName="+fileName;
	
	url += "&sFileURL="+(String)map.get("RPATH")+"/"+fileName;

	response.sendRedirect(url);
%>