<%@ page import="project.common.bean.*,project.common.util.*,java.util.*"%>
<%
	DataMap paramDataMap = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
	if(paramDataMap == null){
		paramDataMap = new DataMap(request);
	}
	String menuId = paramDataMap.getString(CommonConfig.MENU_ID_KEY);

	String userid = (String)request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY);
	String username = (String)request.getSession().getAttribute(CommonConfig.SES_USER_NAME_KEY);
	String wareky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_WHAREHOUSE_KEY);
	String warekynm = (String)request.getSession().getAttribute(CommonConfig.SES_USER_WHAREHOUSE_NM_KEY);
	String compky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_COMPANY_KEY);
	String deptid = (String)request.getSession().getAttribute(CommonConfig.SES_DEPT_ID_KEY);
	String menukey = (String)request.getSession().getAttribute(CommonConfig.SES_MENU_GROUP_KEY);
	String langky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_LANGUAGE_KEY);
	
	DataMap userInfo = (DataMap)request.getSession().getAttribute(CommonConfig.SES_USER_INFO_KEY);
	
	ArrayList usrloList = (ArrayList)request.getAttribute(CommonConfig.SES_USER_LAYOUT_LIST_KEY);
	ArrayList usrphList = (ArrayList)request.getAttribute(CommonConfig.SES_USER_SEARCHPARAM_LIST_KEY);
	ArrayList usrpiList = (ArrayList)request.getAttribute(CommonConfig.SES_USER_SEARCHPARAM_DEFAULT_KEY);
	
	String theme =(String)request.getSession().getAttribute(CommonConfig.SES_USER_THEME_KEY);
	
	String urolky = (String)request.getSession().getAttribute(CommonConfig.SES_UROLKY);	//사용자 권한키 1.조회 2.조회+저장 3.ALL
	
	Map headRow;
%>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<META HTTP-EQUIV="Expires" CONTENT="Mon, 06 Jan 1990 00:00:01 GMT">
<META HTTP-EQUIV="Expires" CONTENT="-1">
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Cache-Control" CONTENT="no-cache">
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/layout_green3.css"/>
<!-- link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/layout.css"/-->
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/content_ui3.css">
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/multiple-select.css">
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
<script type="text/javascript" src="/common/lang/message-<%=langky%>.js?v=<%=System.currentTimeMillis()%>"></script>
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

<script>
<%
	if(usrloList != null && usrloList.size() > 0){
		for(int i=0;i<usrloList.size();i++){
			headRow = (Map)usrloList.get(i);
%>
	gridList.gridLayOutMap.put('<%=headRow.get("COMPID")%> <%=headRow.get("LYOTID")%>','<%=headRow.get("LAYDAT")%>');
<%
		}
	}
%>

<%
	if(usrphList != null && usrphList.size() > 0){
		for(int i=0;i<usrphList.size();i++){
			headRow = (Map)usrphList.get(i);
%>
	
	inputList.addUserParamList('<%=headRow.get("PARMKY")%>','<%=headRow.get("SHORTX")%>');
<%
		}
	}
%>

<%
	if(usrpiList != null && usrpiList.size() > 0){
		for(int i=0;i<usrpiList.size();i++){
			headRow = (Map)usrpiList.get(i);
%>
	inputList.addUserParamMap('<%=headRow.get("CTRLID")%>','<%=headRow.get("CTRVAL")%>');
<%
	}
}
%>


$(document).ready(function(){
	if($("#topFrame",window.top.document).length >= 1){
		var wh = $(window.top).height();
		var ww = $(window.top).width();
		
		var bgDiv = "<div class='bgDiv' style='height:"+wh+"px;width:"+ww+"px;position:fixed; z-index:-1;background-color: #e9ecf6;"></div>";
		var ph = $(window).height();
		var pw = $(window).width();
		$('body').append(bgDiv);
		$(".bgDiv").css({top : -120 + "px", left : pw - ww + "px"});
	}else{
		<%
	if(compky != null){
		if(compky.equals("GCCL")){
		%>
		$("body").css({backgroundColor:"#d5ecec"});
		<%
			}else{
		%>
		$("body").css({backgroundColor:"#b0dfff"});
		<%
			}
	}
		%>
	}
});

$(window).resize(function(){
	if($(".bgDiv").length >= 1){
		var wh = $(window.top).height();
		var ww = $(window.top).width();
		var ph = $(window).height();
		var pw = $(window).width();
		$(".bgDiv").css({top : -120 + "px", left : pw - ww + "px", width: ww+"px", height:wh+"px"});
	}
});

</script>
<script type="text/javascript" src="/common<%=theme%>/js/head.js"></script>