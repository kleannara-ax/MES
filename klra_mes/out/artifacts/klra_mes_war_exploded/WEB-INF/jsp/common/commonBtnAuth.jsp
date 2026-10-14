<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	String auth =  (String)request.getParameter("authCd");
	Object showAuthCd = request.getParameter("showAuthCd");
%>
<%if(showAuthCd==null || "".equals(showAuthCd)){%>
<div class="btn_lit tableUtil">
	<button type='button' id="button-<%=auth%>-1" GBtn="find"></button>
	<button type="button" id="button-<%=auth%>-2" GBtn="filter"></button>
	<button type='button' id="button-<%=auth%>-3" GBtn="sortReset"></button>
	<button type='button' id="button-<%=auth%>-4" GBtn="add"></button>
	<button type='button' id="button-<%=auth%>-5" GBtn="copy"></button>
	<button type='button' id="button-<%=auth%>-6" GBtn="delete"></button>
	<button type='button' id="button-<%=auth%>-7" GBtn="total"></button>
	<button type="button" id="button-<%=auth%>-8" GBtn="subTotal"></button>
	<button type='button' id="button-<%=auth%>-9" GBtn="layout"></button>
	<button type='button' id="button-<%=auth%>-10" GBtn="excel"></button>
	<button type='button' id="button-<%=auth%>-11" GBtn="excelUpload"></button>
	<span class='txt_total' >총 건수 : <span GInfoArea='true'>4</span></span>
</div>
<%}else {
	String splitCd[] = showAuthCd.toString().split(",");
	auth = "";
%>
<div class="btn_lit tableUtil">
	<%for(String ac: splitCd) {%>
	<%if("1".equals(ac)){%><button type='button' id="button-<%=auth%>-1" GBtn="find"></button><%}%>
	<%if("2".equals(ac)){%><button type="button" id="button-<%=auth%>-2" GBtn="filter"></button><%}%>
	<%if("3".equals(ac)){%><button type='button' id="button-<%=auth%>-3" GBtn="sortReset"></button><%}%>
	<%if("4".equals(ac)){%><button type='button' id="button-<%=auth%>-4" GBtn="add"></button><%}%>
	<%if("5".equals(ac)){%><button type='button' id="button-<%=auth%>-5" GBtn="copy"></button><%}%>
	<%if("6".equals(ac)){%><button type='button' id="button-<%=auth%>-6" GBtn="delete"></button><%}%>
	<%if("7".equals(ac)){%><button type='button' id="button-<%=auth%>-7" GBtn="total"></button><%}%>
	<%if("8".equals(ac)){%><button type="button" id="button-<%=auth%>-8" GBtn="subTotal"></button><%}%>
	<%if("9".equals(ac)){%><button type='button' id="button-<%=auth%>-9" GBtn="layout"></button><%}%>
	<%if("10".equals(ac)){%><button type='button' id="button-<%=auth%>-10" GBtn="excel"></button><%}%>
	<%if("11".equals(ac)){%><button type='button' id="button-<%=auth%>-11" GBtn="excelUpload"></button><%}%>
	<%}%>
	<span class='txt_total' >총 건수 : <span GInfoArea='true'>4</span></span>
</div>
<%}%>