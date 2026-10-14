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
	String ownrky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_OWNER_KEY);
	
	DataMap userInfo = (DataMap)request.getSession().getAttribute(CommonConfig.SES_USER_INFO_KEY);
	
	ArrayList usrloList = (ArrayList)request.getAttribute(CommonConfig.SES_USER_LAYOUT_LIST_KEY);
	ArrayList usrphList = (ArrayList)request.getAttribute(CommonConfig.SES_USER_SEARCHPARAM_LIST_KEY);
	ArrayList usrpiList = (ArrayList)request.getAttribute(CommonConfig.SES_USER_SEARCHPARAM_DEFAULT_KEY);
	
	String theme =(String)request.getSession().getAttribute(CommonConfig.SES_USER_THEME_KEY);
	
	String urolky = (String)request.getSession().getAttribute(CommonConfig.SES_UROLKY);	//ì¬ì©ì ê¶íí¤ 1.ì¡°í 2.ì¡°í+ì ì¥ 3.ALL
	
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
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/demo_layout.css">
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
		
		var $div = $("<div>");
		var bgDiv = $div.clone().addClass("bgDiv");//"<div class='bgDiv' style='height:"+wh+"px;width:"+ww+"px;position:fixed; z-index:-1;background-color: #e9ecf6;"></div>";
			bgDiv.css({"height" : wh, "width": ww, "position": "fixed", "z-index": -1, "background-color": "#e9ecf6;"});
			
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
	
	var vUrolky = '<%=urolky%>';		// 사용자 권한키 1.조회 2.조회+저장 3.ALL
	/* var vUrolky = 3; */
	
	if(vUrolky == 1){				// 1.조회 2.조회+저장 3.ALL
		// 서치버튼 
		$("#button-0-1").show();		// 조회
		$("#button-0-2").hide();		// 저장 
		$("#button-0-3").hide();		// 버튼1
		$("#button-0-4").hide();		// 버튼2
		$("#button-0-5").hide();		// 버튼3
		
		// 그리드1 버튼
 		$("#button-1-1").show();	//find        
		$("#button-1-2").hide();	//filter      	
		$("#button-1-3").show();	//sortReset   
		$("#button-1-4").hide();	//add         
		$("#button-1-5").hide();	//copy        
		$("#button-1-6").hide();	//delete      
		$("#button-1-7").show();	//total       
		$("#button-1-8").hide();	//subTotal    
		$("#button-1-9").show();	//layout      	
		$("#button-1-10").show();	//excel       
		$("#button-1-11").hide();	//excelUpload
		// 그리드2 버튼
 		$("#button-2-1").show();	//find        
		$("#button-2-2").hide();	//filter      	
		$("#button-2-3").show();	//sortReset   
		$("#button-2-4").hide();	//add         
		$("#button-2-5").hide();	//copy        
		$("#button-2-6").hide();	//delete      
		$("#button-2-7").show();	//total       
		$("#button-2-8").hide();	//subTotal    
		$("#button-2-9").show();	//layout      	
		$("#button-2-10").show();	//excel       
		$("#button-2-11").hide();	//excelUpload
		// 그리드3 버튼 
 		$("#button-3-1").show();	//find        
		$("#button-3-2").hide();	//filter      	
		$("#button-3-3").show();	//sortReset   
		$("#button-3-4").hide();	//add         
		$("#button-3-5").hide();	//copy        
		$("#button-3-6").hide();	//delete      
		$("#button-3-7").show();	//total       
		$("#button-3-8").hide();	//subTotal    
		$("#button-3-9").show();	//layout      	
		$("#button-3-10").show();	//excel       
		$("#button-3-11").hide();	//excelUpload
		// 그리드4 버튼
 		$("#button-4-1").show();	//find        
		$("#button-4-2").hide();	//filter      	
		$("#button-4-3").show();	//sortReset   
		$("#button-4-4").hide();	//add         
		$("#button-4-5").hide();	//copy        
		$("#button-4-6").hide();	//delete      
		$("#button-4-7").show();	//total       
		$("#button-4-8").hide();	//subTotal    
		$("#button-4-9").show();	//layout      	
		$("#button-4-10").show();	//excel       
		$("#button-4-11").hide();	//excelUpload

	}else if(vUrolky == 2){			// 1.조회 2.조회+저장 3.ALL
		$("#button-0-1").show();	// 조회
		$("#button-0-2").show();	// 저장 
		$("#button-0-3").hide();	// 버튼1
		$("#button-0-4").hide();	// 버튼2
		$("#button-0-5").hide();	// 버튼3		
		
		// 그리드1 버튼
 		$("#button-1-1").show();	//find        
		$("#button-1-2").show();	//filter      	
		$("#button-1-3").show();	//sortReset   
		$("#button-1-4").show();	//add         
		$("#button-1-5").show();	//copy        
		$("#button-1-6").show();	//delete      
		$("#button-1-7").show();	//total       
		$("#button-1-8").show();	//subTotal    
		$("#button-1-9").show();	//layout      	
		$("#button-1-10").show();	//excel       
		$("#button-1-11").hide();	//excelUpload
		// 그리드2 버튼
 		$("#button-2-1").show();	//find        
		$("#button-2-2").show();	//filter      	
		$("#button-2-3").show();	//sortReset   
		$("#button-2-4").show();	//add         
		$("#button-2-5").show();	//copy        
		$("#button-2-6").show();	//delete      
		$("#button-2-7").show();	//total       
		$("#button-2-8").show();	//subTotal    
		$("#button-2-9").show();	//layout      	
		$("#button-2-10").show();	//excel       
		$("#button-2-11").hide();	//excelUpload
		// 그리드3 버튼
 		$("#button-3-1").show();	//find        
		$("#button-3-2").show();	//filter      	
		$("#button-3-3").show();	//sortReset   
		$("#button-3-4").show();	//add         
		$("#button-3-5").show();	//copy        
		$("#button-3-6").show();	//delete      
		$("#button-3-7").show();	//total       
		$("#button-3-8").show();	//subTotal    
		$("#button-3-9").show();	//layout      	
		$("#button-3-10").show();	//excel       
		$("#button-3-11").hide();	//excelUpload 
		// 그리드4 버튼
 		$("#button-4-1").show();	//find        
		$("#button-4-2").show();	//filter      	
		$("#button-4-3").show();	//sortReset   
		$("#button-4-4").show();	//add         
		$("#button-4-5").show();	//copy        
		$("#button-4-6").show();	//delete      
		$("#button-4-7").show();	//total       
		$("#button-4-8").show();	//subTotal    
		$("#button-4-9").show();	//layout      	
		$("#button-4-10").show();	//excel       
		$("#button-4-11").hide();	//excelUpload 
	}else if(vUrolky == 3){			// 1.조회 2.조회+저장 3.ALL
		$("#button-0-1").show();	// 조회
		$("#button-0-2").show();	// 저장 
		$("#button-0-3").show();	// 버튼1
		$("#button-0-4").show();	// 버튼2
		$("#button-0-5").show();	// 버튼3		
		
		// 그리드1 버튼
 		$("#button-1-1").show();	//find        
		$("#button-1-2").show();	//filter      	
		$("#button-1-3").show();	//sortReset   
		$("#button-1-4").show();	//add         
		$("#button-1-5").show();	//copy        
		$("#button-1-6").show();	//delete      
		$("#button-1-7").show();	//total       
		$("#button-1-8").show();	//subTotal    
		$("#button-1-9").show();	//layout      	
		$("#button-1-10").show();	//excel       
		$("#button-1-11").hide();	//excelUpload
		// 그리드2 버튼
 		$("#button-2-1").show();	//find        
		$("#button-2-2").show();	//filter      	
		$("#button-2-3").show();	//sortReset   
		$("#button-2-4").show();	//add         
		$("#button-2-5").show();	//copy        
		$("#button-2-6").show();	//delete      
		$("#button-2-7").show();	//total       
		$("#button-2-8").show();	//subTotal    
		$("#button-2-9").show();	//layout      	
		$("#button-2-10").show();	//excel       
		$("#button-2-11").hide();	//excelUpload
		// 그리드3 버튼
 		$("#button-3-1").show();	//find        
		$("#button-3-2").show();	//filter      	
		$("#button-3-3").show();	//sortReset   
		$("#button-3-4").show();	//add         
		$("#button-3-5").show();	//copy        
		$("#button-3-6").show();	//delete      
		$("#button-3-7").show();	//total       
		$("#button-3-8").show();	//subTotal    
		$("#button-3-9").show();	//layout      	
		$("#button-3-10").show();	//excel       
		$("#button-3-11").hide();	//excelUpload 
		// 그리드4 버튼
 		$("#button-4-1").show();	//find        
		$("#button-4-2").show();	//filter      	
		$("#button-4-3").show();	//sortReset   
		$("#button-4-4").show();	//add         
		$("#button-4-5").show();	//copy        
		$("#button-4-6").show();	//delete      
		$("#button-4-7").show();	//total       
		$("#button-4-8").show();	//subTotal    
		$("#button-4-9").show();	//layout      	
		$("#button-4-10").show();	//excel       
		$("#button-4-11").hide();	//excelUpload 
	}
	
	if(Browser.chrome){
		site.isClipBoardOpen = false;
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