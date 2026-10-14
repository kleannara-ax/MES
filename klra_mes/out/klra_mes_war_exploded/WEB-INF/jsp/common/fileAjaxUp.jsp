<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="project.common.bean.DataMap,project.common.bean.CommonConfig"%>
<%
	DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
%>
<%=map.getString("data")%>