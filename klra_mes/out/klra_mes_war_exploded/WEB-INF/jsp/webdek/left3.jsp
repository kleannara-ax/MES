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
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/zTreeMenu3.css"/>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/left_tree.css"/>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/left_tree3.css"/>
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
		windowH = $(window).height() - 150 //guick menu height 200px 포함
		$(".lnb_wrap").css("height", "calc(100vh - 100px)");
		$(".guick_menu").css("height", "calc(100vh - 100px)")
	});
	
	var $menuSearch;
	var lastActiveMenuId;
	var openAllState = true;
	var $treeMenu;
	$(document).ready(function(){
		windowH = $(window).height() - 150; //guick menu height 200px 포함
		windowH = $(window).height() - 150; //guick menu height 200px 포함
		$(".lnb_wrap").css("height", "calc(100vh - 100px)");
		$(".guick_menu").css("height", "calc(100vh - 100px)")
		
		$(".my_menu").click(function() {
			$("#tab2").css("display","block");
			$("#tab1").css("display","none");
			$(this).removeClass("off").addClass("on");
			$(".sys_menu").removeClass("on").addClass("off");
			$("#menuBtnBox").hide();
			$("#sortBtnBox").show();
		});
		  
		$(".sys_menu").click(function() {
			$("#tab1").css("display","block");
			$("#tab2").css("display","none");
			$(this).removeClass("off").addClass("on");
			$(".my_menu").removeClass("on").addClass("off");
			$("#menuBtnBox").show();
			$("#sortBtnBox").hide();
		});
		
		$(".sort_box button").click(function(){
			$(".sort_box button").toggleClass("slide");
		});
		$(".sort_box_fl button").click(function(){
			$(this).toggleClass("complete");
		});
		
		//배경적용
		var wh = $(window.top).height();
		var ww = $(window.top).width();

		var bgDiv = "<div class='bgDiv' style='height:"+wh+"px;width:"+ww+"px;position:absolute;top:-80px;left:0; z-index:-1;background:url(/common/theme/webdek/images/web_bg.png) repeat center center;background-size:cover;'></div>";

		// top : 최상위 window : main3.jsp
		$('body',top.frames["left"].document).append(bgDiv);
		$('.bgDiv',top.frames["left"].document).css({top:-80+"px", left:0 });
		
		// 위에까지는 메뉴코드 검색까지의 구성
// 		setTreeList_left3('MENU_TREE');
		
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
		
		searchList();
	});
	
	
	function setTreeList_left3(cmd) {
		treeList.setTree({
	    	id       : "treeList",
	    	module   : "Common",
			command  : cmd,
// 			command  : "MENU_TREE",
			pkCol    : "MENUID",
		    pidCol   : "PMENUID",
		    nameCol  : "MENULABEL",
		    sortCol  : "SORTORDER",
		    editable : false,
		    isMove   : false,
		    isCheck  : false
	    });
	}
	
	
	
	function searchList(kyWrd) {
		
		var param = new DataMap();
		param.put("COMPID","<%=compky%>");
		param.put("MENUGID","<%=menugid%>");
		param.put("USERID", "<%=userid%>");
		
		
		if (kyWrd) {
			
			setTreeList_left3('MENU_TREE_SRCH');
			param.put("KEYWORD", kyWrd);
			var treeData =  '';
			
			treeList.treeAndCallBack({
				id : "treeList", param : param
			}, function(opts) {
		    	
// 				setTimeout(function() {
					treeData = opts.data;				
					for (var i in treeData.data) {
						var row = treeData.data[i];
						var slctr = '#treeList_'+(parseInt(i)+1);
						// console.log('slctr = '+slctr );
						if (row.DSP_YN == 'Y' && row.IS_FLDR == 'Y') {
// 							if (isOdd(row.LVL)) $(slctr +'_switch').click();
// 							else $(slctr +'_a').click();
// 							if (isOdd(row.LVL)) $(slctr +'_a').click();
// 							else $(slctr +'_switch').click();
// 							$(slctr +'_switch').click();
// 							console.log('row.MENULABEL = '+row.MENULABEL);
// 							console.log('slctr = '+slctr );
							$(slctr +'_a').click();
						}
						if (row.SUB_MENUID) $(slctr +'_span').css("color", "#00FF00");
// 						if (row.SUB_MENUID) $(slctr +'_span').css("color", "#f00");
	// 					$('#treeList_61_switch, #treeList_68_switch').click();
	// 					$('#treeList_69_a').click();
					}
	// 				if (kyWrd) menuOpenCloseIconChg_left3('open');
	// 				else menuOpenCloseIconChg_left3('close');
// 				}, 700);
		    	
			});
			
		} else {
			setTreeList_left3('MENU_TREE');
			treeList.treeList({
				id : "treeList", param : param
			});
		}
		
		treeList.treeList({
			id : "treeList1", param : param
		});
		
// 		setTimeout(function() {
// 			if (kyWrd) menuOpenCloseIconChg_left3('open');
// 			else menuOpenCloseIconChg_left3('close');
// 		}, 800);
		
	}
	
	
	
	
	
// 	function isZeroOrEven(num) {
// 		return (num == 0 or num % 2 == 0)? true : false;
// 	}
	function isOdd(num) {
		return (num % 2 == 0)? false : true;
	}
	
	
	
	
	function menuOpenCloseIconChg_left3(flg) {
		if (flg == 'open') {
// 			openAllState = false;
// 			treeList.openNodeAll("treeList");
			$('.btn_asc').removeClass('slide');
		} else if (flg == 'close') {
// 			openAllState = true;
			$('.btn_asc').addClass('slide');
		} 
	}
// 	function menuOpenCloseAndIconChg_left3(flg) {
// 		if (flg == 'open') {
// 			openAllState = false;
// 			treeList.openNodeAll("treeList");
// 			$('.btn_asc').removeClass('slide');
// 		} else if (flg == 'close') {
// 			openAllState = true;
// 			$('.btn_asc').addClass('slide');
// 		} 
// 	}
	
	
	
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
			$('.btn_asc').addClass('slide');
		}else{			
			openAllState = true;
			treeList.closeNodeAll("treeList");
			$('.btn_asc').removeClass('slide');
		}
	}

	// 메뉴(화면) 클릭 시 실행
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
	
	
	
	
	function menuSearch() {
// 		alert($('#menuSearch').val());
		searchList($('#menuSearch').val() );
	}
	
	
	
	
// 	function menuSearch(menuId){
// 		if(menuId != undefined && menuId != null && $.trim(menuId) != ""){
// 			treeList.linkPage("treeList", menuId);
// 		}else{
// 			var $menuSearch = $("#menuSearch");
// 			var menuId = $menuSearch.val();
// 			treeList.linkPage("treeList", menuId);
// 		}
// 	}
	
	function checkFmenu(menuId){
		return treeList.checkNode("treeList1", menuId);
	}
	
	function addFmenu(menuId){
		var node = treeList.getNode("treeList", menuId);
		var treeBox = treeList.treeMap.get("treeList"); 
		var dataMap = treeBox.dataMap;
		var tId = node[treeBox.tIdKey];
		
		var data = dataMap.get(tId); 
		
		treeList.addNode("treeList1", node, data);
	}
	
	function deleteFmenu(menuId){
		var node = treeList.getNode("treeList1", menuId);
		
		treeList.removeNode("treeList1", node);
	}
	
	function setLastActiveMenuId(tmpActiveMenuId){
		if(tmpActiveMenuId){
			lastActiveMenuId = tmpActiveMenuId;
		}
	}
	
	function treeGridDropAfterEvent(treeId, treeNodes, targetNode, moveType, isCopy){
		if(treeId == "treeList1"){
			var list = treeList.getModifyData(treeId);
			
			var param = new DataMap();
			param.put("list", list);
		}
	}
	
	function menuSortEvent(obj){
		var treeBox = treeList.treeMap.get("treeList1");
		var treeObj = treeBox.treeObj;
		
		var $element = $(obj);
		if($element.hasClass("complete")){
			treeObj.setting["edit"]["enable"] = false;
			treeObj.setting["edit"]["showRemoveBtn"] = false;
			treeObj.setting["edit"]["drag"]["isMove"] = false;
			treeObj.setting["edit"]["drag"]["inner"] = true;
			treeObj.selectNode([]);
			menuSort();
		}else{
			treeObj.setting["edit"]["enable"] = true;
			treeObj.setting["edit"]["showRemoveBtn"] = true;
			treeObj.setting["edit"]["drag"]["isMove"] = true;
			treeObj.setting["edit"]["drag"]["inner"] = false;
		}
	}
	
	function menuSort(){
		var modifyList = treeList.getModifyData("treeList1");
		if(modifyList.length > 0){
			var list = treeList.getAllNodes("treeList1");
			var delList = modifyList.filter(function(data){
				return data.get(configData.GRID_ROW_STATE_ATT) == configData.GRID_ROW_STATE_DELETE;
			});
			
			var param = new DataMap();
			param.put("list", list);
			param.put("delList", delList);
			
			var json = netUtil.sendData({
				url : "/system/json/saveMenuFl.data",
				param : param
			});
		}
	}
	
	function menuFlMaxSort(){
		var sort = 0;
		var sortList = treeList.getSortList("treeList1");
		if(sortList.length > 0){
			var sortDesc = sortList.sort(function(n1,n2){
				return n2 - n1;
			});
			
			sort = sortDesc[0];
		}
		return sort;
	}
	
</script>
</head>
<body>
<div class="left_wrap">
	<div class="tab_wrap"> 
    	<ul class="tabs">
			<li class="tab sys_menu on">
				<h1 class="btn_sysmenu">
					<a href="#tab1"><span>시스템메뉴</span></a>	
				</h1>
        	</li>
	        <li class="tab my_menu off">
		         <h1 class="btn_mymenu">
					<a href="#tab2"><span>마이메뉴</span></a>	
				</h1>
	        </li>
    	</ul>
 		<div class="tab_container">
		    <fieldset>
				<legend>search</legend>
				<p class="search_box">
					<input type="text" class="serch_input serch_input_change" id="menuSearch" placeholder="메뉴명을 입력하세요." onkeypress="commonUtil.enterKeyCheck(event,'menuSearch()')"/>
					<button type="button" class="btn btn_search btn_search_change" onclick="menuSearch()"><span>"메뉴명을 입력하세요."</span></button>
					<div class="sort_box sort_box_change" id="menuBtnBox">
						<button type="button" class="btn_asc slide" onclick="menuOpenAll(this)"></button> <!-- 메뉴코드 검색 옆에 버튼 -->
					</div>
					<div class="sort_box_fl" id="sortBtnBox">
						<button type="button" class="btn_sort" onclick="menuSortEvent(this);"></button> <!-- 메뉴코드 검색 옆에 버튼 -->
					</div>
				</p>		
			</fieldset>	
			<!-- 시스템 메뉴 -->
			<div id="tab1" class="tab_content">	
				<div class="lnb_wrap">
					<ul id="treeList" style="width:100%;height:100%;"></ul>
				</div>
			</div>	
			
			<!-- 마이 메뉴 -->
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