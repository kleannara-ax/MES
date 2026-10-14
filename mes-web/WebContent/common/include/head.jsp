<%@ page import="com.common.bean.*,com.common.util.*,com.common.bean.CommonConfig,java.util.*"%>
<%
	DataMap paramDataMap = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
	if(paramDataMap == null){
		paramDataMap = new DataMap(request);
	}
	String menuId = paramDataMap.getString(CommonConfig.MENU_ID_KEY);

	String wareky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_WHAREHOUSE_KEY);
	String userid = (String)request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY);
	String username = (String)request.getSession().getAttribute(CommonConfig.SES_USER_NAME_KEY);
	String compky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_COMPANY_KEY);
	String langky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_LANGUAGE_KEY);
	String ownrky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_OWNER_KEY);
	
	DataMap userInfo = (DataMap)request.getSession().getAttribute(CommonConfig.SES_USER_INFO_KEY);
	
	ArrayList usrloList = (ArrayList)request.getAttribute(CommonConfig.SES_USER_LAYOUT_LIST_KEY);
	ArrayList usrphList = (ArrayList)request.getAttribute(CommonConfig.SES_USER_SEARCHPARAM_LIST_KEY);
	ArrayList usrpiList = (ArrayList)request.getAttribute(CommonConfig.SES_USER_SEARCHPARAM_DEFAULT_KEY);
	
	String theme =(String)request.getSession().getAttribute(CommonConfig.SES_USER_THEME_KEY);
%>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<link rel="stylesheet" type="text/css" href="/common<%=theme%>/css/common.css">
<link rel="stylesheet" type="text/css" href="/common<%=theme%>/css/content_body.css">
<link rel="stylesheet" type="text/css" href="/common<%=theme%>/css/content_ui.css">
<link rel="stylesheet" type="text/css" href="/common<%=theme%>/css/multiple-select.css">
<link rel="stylesheet" type="text/css" href="/common<%=theme%>/css/theme.css">
<script type="text/javascript" src="/common/js/jquery.js"></script>
<script type="text/javascript" src="/common/js/jquery-ui.js"></script>
<script type="text/javascript" src="/common/js/jquery-ui.custom.js"></script>
<%
	if(langky != null && (langky.equals("CN") || langky.equals("ZH"))){
%>
<script type="text/javascript" src="/common/js/datepicker/jquery.ui.datepicker-zh-CN.js"></script>
<%
	}else if(langky != null && langky.equals("EN")){
%>
<script type="text/javascript" src="/common/js/datepicker/jquery.ui.datepicker-en-GB.js"></script>
<%
	}else{
%>
<script type="text/javascript" src="/common/js/datepicker/jquery.ui.datepicker-ko.js"></script>
<%
	}
%>
<script type="text/javascript" src="/common/js/jquery.plugin.js"></script>
<script type="text/javascript" src="/common/js/jquery.form.js"></script>
<script type="text/javascript" src="/common/js/jquery.cookie.js"></script>
<script type="text/javascript" src="/common/js/jquery.mousewheel.js"></script>
<script type="text/javascript" src="/common/js/jquery.ui.monthpicker.js"></script>
<script type="text/javascript" src="/common/js/jquery.ui.timepicker.js"></script>
<script type="text/javascript" src="/common/js/multiple-select.js"></script>
<script type="text/javascript" src="/common/js/json2.js"></script>
<script type="text/javascript" src="/common/js/big.js"></script>
<script type="text/javascript" src="/common/js/dataMap.js"></script>
<script type="text/javascript" src="/common/js/configData.js"></script>
<script type="text/javascript" src="/common/js/label.js"></script>
<script type="text/javascript" src="/common/lang/label-<%=langky%>.js?v=<%=System.currentTimeMillis()%>"></script>
<script type="text/javascript" src="/common/lang/message-<%=langky%>.js"></script>
<script type="text/javascript" src="/common/js/site.js"></script>
<script type="text/javascript" src="/common/js/commonUtil.js"></script>
<script type="text/javascript" src="/common<%=theme%>/js/theme.js"></script>
<script type="text/javascript" src="/common/js/dataBind.js"></script>
<script type="text/javascript" src="/common/js/input.js"></script>
<script type="text/javascript" src="/common/js/netUtil.js"></script>
<script type="text/javascript" src="/common/js/ui.js"></script>
<script type="text/javascript" src="/common/js/worker-ajax.js"></script>
<script type="text/javascript" src="/common/js/bigdata.js"></script>
<script type="text/javascript" src="/common/js/dataRequest.js"></script>
<script type="text/javascript" src="/common/js/grid.js"></script>
<script type="text/javascript" src="/common/js/layoutSave.js"></script>
<script type="text/javascript" src="/common/js/validateUtil.js"></script>
<script type="text/javascript" src="/common/js/page.js"></script>
<script type="text/javascript" src="/mes/js/mes.js"></script>
<script>
<%
	if(usrloList != null && usrloList.size() > 0){
		Map row;
		for(int i=0;i<usrloList.size();i++){
			row = (Map)usrloList.get(i);
%>
	gridList.gridLayOutMap.put('<%=row.get("COMPID")%> <%=row.get("LYOTID")%>','<%=row.get("LAYDAT")%>');
<%
		}
	}
%>

<%
	if(usrphList != null && usrphList.size() > 0){
		Map row;
		for(int i=0;i<usrphList.size();i++){
			row = (Map)usrphList.get(i);
%>
	
	inputList.addUserParamList('<%=row.get("PARMKY")%>','<%=row.get("SHORTX")%>');
<%
		}
	}
%>

<%
	if(usrpiList != null && usrpiList.size() > 0){
		Map row;
		for(int i=0;i<usrpiList.size();i++){
			row = (Map)usrpiList.get(i);
%>
	inputList.addUserParamMap('<%=row.get("CTRLID")%>','<%=row.get("CTRVAL")%>');
<%
	}
}
%>

configData.MENU_ID = $.trim("<%=menuId%>")
</script>
<script type="text/javascript" src="/common/js/head.js"></script>

<script>

function removeDateSplitor(date){
	if(date.length > 8){
		while(1){
			if(date.indexOf("-") != -1){
				date = date.replace("-","");
			}else if(date.indexOf(".") != -1){
				date = date.replace(".","");
			}else if(date.indexOf("/") != -1){
				date = date.replace("/","");
			}else{
				break;
			}
		}
	}
	return date;
}

function getIntervalDate(date, interval){
	if(date.length > 8){
		while(1){
			if(date.indexOf("-") != -1){
				date = date.replace("-","");
			}else if(date.indexOf(".") != -1){
				date = date.replace(".","");
			}else if(date.indexOf("/") != -1){
				date = date.replace("/","");
			}else{
				break;
			}
		}
	}
	
	var y = date.substring(0,4);
	var m = date.substring(4,6);
	var d = date.substring(6,8);
	
	var today = new Date(y + "/" + m + "/" + d + " 00:00:00");
	today.setDate(today.getDate() + (Number)(interval));
	
	var year = today.getFullYear();
    var month = today.getMonth()+1;
    var date = today.getDate();
    
    if (month < 10) month = "0" + month;
    if (date < 10) date = "0" + date;
    year = year + "";
    month = month + "";
    date = date + "";
    
	var resultDate = year+month+date;
    return resultDate;
}
</script>