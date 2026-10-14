<%
	if(SORTKEY.equals("00") && APRTYPE.equals("N")){
%>		
<button CB="Delete DELETE STD_DELETE"></button>
<%
	}else if(IAPRTYPE.equals("N") && LASTAPUSER.equals("0") && (APRTYPE.equals("N") || APRTYPE.equals("P"))) {
%>
<button CB="Aprove CHECK STD_APROVE"></button>
<button CB="Return EXPAND STD_RETURN"></button>
<%
	}
%>