<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.common.bean.DataMap,com.common.bean.CommonConfig"%>
<%
	DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
%>
<%=map.getString("data")%>