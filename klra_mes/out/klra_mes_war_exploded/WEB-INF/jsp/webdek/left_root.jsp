<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="project.common.bean.*,java.util.*"%>
<%
	String username = request.getSession().getAttribute(CommonConfig.SES_USER_NAME_KEY).toString();
	String compky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_COMPANY_KEY);
	String userid = request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY).toString();
	String menugid = (String)request.getSession().getAttribute(CommonConfig.SES_MENU_GROUP_KEY);
	String langky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_LANGUAGE_KEY);
	
	String theme =(String)request.getSession().getAttribute(CommonConfig.SES_USER_THEME_KEY);
	
	String menuSearchId = request.getParameter("menuSearchId");
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<title>index left</title>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/zTreeMenu.css"/>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/left_tree.css"/>
<script type="text/javascript" src="/common/js/jquery.js"></script>
<script type="text/javascript" src="/common/js/json2.js"></script>
<script type="text/javascript" src="/common/js/dataMap.js"></script>
<script type="text/javascript" src="/common/js/configData.js"></script>
<script type="text/javascript" src="/common/js/label.js"></script>
<script type="text/javascript" src="/common/lang/label-<%=langky%>.js?v=<%=System.currentTimeMillis()%>"></script>
<script type="text/javascript" src="/common/lang/message-<%=langky%>.js?v=<%=System.currentTimeMillis()%>"></script>
<script type="text/javascript" src="/common/js/commonUtil.js"></script>
<script type="text/javascript" src="/common/js/netUtil.js"></script>
<!-- <link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/zTreeStyle_menu.css"/> -->
<script type="text/javascript" src="/common/js/jquery.ztree.core.js"></script>
<script type="text/javascript" src="/common/js/jquery.ztree.exedit.js"></script>
<script type="text/javascript" src="/common/js/jquery.ztree.excheck.js"></script>
<script type="text/javascript" src="/common/js/tree.js"></script>
<script type="text/javascript">
	var windowH;//guick menu height 200px 포함
	$(".lnb_wrap").css("height", "calc(100vh - 100px)");
	$(window).resize(function() {
		windowH = $(window).height() - 150//guick menu height 200px 포함
		$(".lnb_wrap").css("height", "calc(100vh - 100px)");
		$(".guick_menu").css("height", "calc(100vh - 100px)")
	});
	
	var $menuSearch;
	var lastActiveMenuId;
	var openAllState = true;
	var $treeMenu;
	$(document).ready(function(){
		windowH = $(window).height() - 150;//guick menu height 200px 포함
		windowH = $(window).height() - 150;//guick menu height 200px 포함
		$(".lnb_wrap").css("height", "calc(100vh - 100px)");
		$(".guick_menu").css("height", "calc(100vh - 100px)")
		
		$(".my_menu").click(function() {
			$("#tab2").css("display","block");
			$("#tab1").css("display","none");
			$(this).removeClass("off").addClass("on");
			$(".sys_menu").removeClass("on").addClass("off");
		});
		  
		$(".sys_menu").click(function() {
			$("#tab1").css("display","block");
			$("#tab2").css("display","none");
			$(this).removeClass("off").addClass("on");
			$(".my_menu").removeClass("on").addClass("off");
		});
		
		$(".sort_box button").click(function(){
			$(".sort_box button").toggleClass("slide");
		});
		
		//배경적용
		var wh = $(window.top).height();
		var ww = $(window.top).width();

		var bgDiv = "<div class='bgDiv' style='height:"+wh+"px;width:"+ww+"px;position:absolute;top:-80px;left:0; z-index:-1;background:url(/common/theme/webdek/images/web_bg.png) repeat center center;background-size:cover;'></div>";

		$('body',top.frames["left"].document).append(bgDiv);
		$('.bgDiv',top.frames["left"].document).css({top:-80+"px", left:0 });
		
		treeList.setTree({
	    	id       : "treeList",
	    	module   : "Common",
			command  : "MENU_TREE",
			pkCol    : "MENUID",
		    pidCol   : "PMENUID",
		    nameCol  : "MENULABEL",
		    sortCol  : "SORTORDER",
		    editable : false,
		    isMove   : false,
		    isCheck  : false
	    });
		
		treeList.setTree({
	    	id       : "treeList1",
	    	module   : "Common",
			command  : "FMENU_TREE",
			pkCol    : "MENUID",
		    pidCol   : "PMENUID",
		    nameCol  : "MENULABEL",
		    sortCol  : "SORTORDER",
		    editable : false,
		    isMove   : false,
		    isCheck  : false
	    });
		
		$treeMenu = $("#treeList");
		//searchList();
		
		var param = new DataMap();
		var json = netUtil.sendData({
			url : "/common/json/rootSubMenu.data",
			param : param
		});
		
		if(json && json.data){
			param.put("COMPID","<%=compky%>");
			param.put("MENUGID","<%=menugid%>");
			param.put("PMENUID",json.SES_ROOT_SUB_MENU);
			treeList.treeList({
				id : "treeList",
		    	param : param
			});
		}
		
		searchListSub();
	});
	
	function searchList(pmenuid){
		var param = new DataMap();
		param.put("COMPID","<%=compky%>");
		param.put("MENUGID","<%=menugid%>");
		param.put("PMENUID",pmenuid);
		treeList.treeList({
			id : "treeList",
	    	param : param
		});
	}
	
	function searchListSub(){
		var param = new DataMap();
		param.put("COMPID","<%=compky%>");
		param.put("MENUGID","<%=menugid%>");

		treeList.treeList({
			id : "treeList1",
	    	param : param
		});
	}
	
	// 로딩 열기
	function loadingOpen() {

		var loader = $('<div class="contentLoading"></div>').appendTo('body');

		loader.stop().animate({
			top : '0px'
		}, 30, function() {
		});
	}

	// 로딩 닫기
	function loadingClose() {

		var loader = $('.contentLoading');

		loader.stop().animate({
			top : '100%'
		}, 30, function() {
			loader.remove();
		});
	}
	
	function menuOpenAll(){
		if(openAllState){
			openAllState = false;
			treeList.openNodeAll("treeList");	
		}else{			
			openAllState = true;
			treeList.closeNodeAll("treeList");
		}		
	}

	function changePage(rowData){	
		var url = rowData.get("URI");
		var menuId = rowData.get("MENUID");
		if(url.indexOf("?") == -1){
			url += "?"+configData.COMMON_MENU_ID_KEY+"="+menuId;
		}else{
			url += "&"+configData.COMMON_MENU_ID_KEY+"="+menuId;
		}
		
		var tmpType = window.top.changePage(rowData.get("MENUNAME"), rowData.get("MENULABEL"), url, menuId);

		lastActiveMenuId = menuId;
	}
	
	function menuSearch(){
		var $menuSearch = $("#menuSearch");
		var menuId = $menuSearch.val();
		treeList.linkPage("treeList", menuId);
	}
	
	function checkFmenu(menuId){
		return treeList.checkNode("treeList1", menuId);
	}
	
	function addFmenu(menuId){
		var node = treeList.getNode("treeList", menuId);
		
		treeList.addNode("treeList1", node);
	}
	
	function deleteFmenu(menuId){
		var node = treeList.getNode("treeList1", menuId);
		
		treeList.removeNode("treeList1", node);
	}
	
	function reloadPage(){
		this.location.reload();
	}
</script>
</head>
<body>
<div class="left_wrap">
	<div class="tab_wrap"> 
    	<ul class="tabs">
			<li class="tab sys_menu on">
				<h1 class="btn_sysmenu">
					<a href="#tab1"><span>System Menu</span></a>	
				</h1>
        	</li>
	        <li class="tab my_menu off">
		         <h1 class="btn_mymenu">
					<a href="#tab2"><span>My Menu</span></a>	
				</h1>
	        </li>
    	</ul>
 		<div class="tab_container">
		    <fieldset>
				<legend>search</legend>
				<p class="search_box">
					<input type="text" class="serch_input serch_input_change" id="menuSearch" placeholder="메뉴코드를 입력해 주세요." onkeypress="commonUtil.enterKeyCheck(event,'menuSearch()')"/>
					<button type="button" class="btn btn_search btn_search_change" onclick="menuSearch()"><span>메뉴코드를 입력해 주세요.</span></button>
					<div class="sort_box sort_box_change">
						<button type="button" class="btn_asc" onclick="menuOpenAll(this)"></button>
					</div>
				</p>		
			</fieldset>	
			<div id="tab1" class="tab_content">	
				<div class="lnb_wrap">
					<ul id="treeList" style="width:100%;height:100%;"></ul>
				</div>
			</div>	
			<div id="tab2" class="tab_content" style="display:none;">
				<div class="guick_menu">
					<ul id="treeList1" style="width:100%;height:100%;"></ul>
				</div>
	 		</div> 
		</div>
	</div>
</div>

<script type="text/javascript">
	var $menuList = $("#menuList");
	$menuList.show();
</script>
<!-- // left_wrap -->
</body>
</html>