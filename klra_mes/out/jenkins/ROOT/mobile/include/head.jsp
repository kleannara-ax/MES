<%@ page import="project.common.bean.DataMap,project.common.bean.CommonConfig,java.util.*"%>
<%
	DataMap paramDataMap = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

	if(paramDataMap == null){
		paramDataMap = new DataMap(request);
	}
	
	String langky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_LANGUAGE_KEY);
	String wareky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_WHAREHOUSE_KEY);
	String ownrky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_OWNER_KEY);
	String plntky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_PLANT_KEY);
	String menuky = (String)request.getSession().getAttribute("MENUKY");
	String menuId = paramDataMap.getString(CommonConfig.MENU_ID_KEY);
%>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<link rel="stylesheet" type="text/css" href="/mobile/css/mobile.css" />
<link rel="stylesheet" type="text/css" href="/common/css/jquery/jquery-ui.css" />
<script type="text/javascript" src="/common/js/jquery.js"></script>
<script type="text/javascript" src="/common/js/jquery-ui.js"></script>
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
<script type="text/javascript" src="/common/js/json2.js"></script>
<script type="text/javascript" src="/common/js/dataMap.js"></script>
<script type="text/javascript" src="/common/js/configData.js"></script>
<script type="text/javascript" src="/common/js/label.js"></script>
<script type="text/javascript" src="/common/lang/label-<%=langky%>.js"></script>
<script type="text/javascript" src="/common/lang/message-<%=langky%>.js"></script>
<script type="text/javascript" src="/common/js/site.js"></script>
<script type="text/javascript" src="/common/js/big.js"></script>
<script type="text/javascript" src="/common/js/commonUtil.js"></script>
<script type="text/javascript" src="/common/js/theme.js"></script>
<script type="text/javascript" src="/common/theme/webdek/js/theme.js"></script>
<script type="text/javascript" src="/common/js/dataBind.js"></script>
<script type="text/javascript" src="/common/js/input.js"></script>
<script type="text/javascript" src="/common/js/netUtil.js"></script>
<script type="text/javascript" src="/common/js/ui.js"></script>
<script type="text/javascript" src="/common/js/validateUtil.js"></script>
<script type="text/javascript" src="/common/js/bigdata.js"></script>
<script type="text/javascript" src="/common/js/grid.js"></script>
<script type="text/javascript" src="/mobile/js/mobile.js"></script>
<script type="text/javascript" src="/mobile/js/mobileHead.js"></script>
<script type="text/javascript" src="/mes/js/mes.js"></script>
<script type="text/javascript" src="/mes/js/sweetalert.js"></script>
<script>

configData.isMobile = true;

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

function PlaySound(soundObjectId) {
	var sound = null;
	if(soundObjectId == "s")
		sound = new Audio("/beepsound/beep_success.mp3");
	if(soundObjectId == "e")
		sound = new Audio("/beepsound/beep_error.mp3");
	if(soundObjectId == "v")
		sound = new Audio("/beepsound/beep_vas.mp3");
	if(sound){
		sound.play();
	}
}
</script>