<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.common.bean.CommonConfig,com.common.bean.DataMap,java.util.*"%>
<%
	List list = (List)request.getAttribute("list");
	String theme =(String)request.getSession().getAttribute(CommonConfig.SES_USER_THEME_KEY);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS Left</title>
<meta name="viewport" content="width=1150">
<link href="https://fonts.googleapis.com/css?family=Noto+Sans+KR|Open+Sans" rel="stylesheet">
<link rel="stylesheet" type="text/css" href="/common<%=theme%>/css/common.css">
<link rel="stylesheet" type="text/css" href="/common<%=theme%>/css/left.css">
<link rel="stylesheet" type="text/css" href="/common<%=theme%>/css/theme.css">
<script type="text/javascript" src="/common/js/jquery.js"></script>
<script type="text/javascript" src="/common/js/json2.js"></script>
<script type="text/javascript" src="/common/js/dataMap.js"></script>
<script type="text/javascript" src="/common/js/configData.js"></script>
<script type="text/javascript" src="/common/js/commonUtil.js"></script>
<script type="text/javascript" src="/common/js/netUtil.js"></script>
<script type="text/javascript">
	var $menuSearch;
	var menuMap = new DataMap();
	var $lastActiveObj;
	var lastActiveMenuId;

	$(document).ready(function(){
		$menuSearch = jQuery("#menuSearch");
		//menuSearch("SAMPLE");
		$("body").on('mousedown', function(e) { 
		   if( e.which == 2 ) {
		      e.preventDefault();
		      e.stopPropagation();
		      e.stopImmediatePropagation();
		      alert("mouse wheel click is not possible!");
		      return false;
		   }
		});
		$("body").on('click', function(e) { 
		   if( e.which == 2 ) {
		      e.preventDefault();
		      e.stopPropagation();
		      e.stopImmediatePropagation();
		      //alert("stop");
		      return false;
		   }
		});
	});
	
	function goPage(obj, url){
		var $obj = $(obj).parent();
		var menuId = $obj.attr(configData.COMMON_MENU_ID_KEY);
		var title = $obj.find("span").text();
		changePage(obj, title, url, menuId);
	}
	
	function changePage(obj, title, url, menuId){	
		var $obj = $(obj).parent();
		
		titleTxt = "";
		getTitle($obj);
		//alert(titleTxt);
		if(url.indexOf("?") == -1){
			url += "?"+configData.COMMON_MENU_ID_KEY+"="+menuId;
		}else{
			url += "&"+configData.COMMON_MENU_ID_KEY+"="+menuId;
		}
		
		var tmpType = window.top.changePage(titleTxt, title, url, menuId);
		if(tmpType){
			//$menuList.find(".active").removeClass("active");
			//$obj.parents("li").addClass("active");
			$obj.addClass("active");
			if($lastActiveObj){
				$lastActiveObj.removeClass("active");
			}
			$lastActiveObj = $obj;
		}
		
		lastActiveMenuId = menuId;
	}
	
	function changeFocus(menuId){
		var $menu = $menuList.find("li").filter("[MENUID="+menuId+"]").filter("[AMNUID!=FAVORITE]");
		$menu.addClass("active");
		if($lastActiveObj){
			$lastActiveObj.removeClass("active");
		}
		$lastActiveObj = $menu;
		parentOpen($menu);
	}
	
	function parentOpen($menu){
		var pmenuId = $menu.attr("AMNUID");
		$menu = $menuList.find("li").filter("[MENUID="+pmenuId+"]").filter("[AMNUID!=FAVORITE]");
		if(!$menu.hasClass("active")){
			$menu.find(">a").trigger("click");
			if(pmenuId != "root"){
				parentOpen($menu);
			}
		}
	}
	
	var titleTxt = "";
	function getTitle($obj){
		
		if(titleTxt){
			titleTxt = $obj.text() + " > " + titleTxt;
		}else{
			titleTxt = $obj.text();
		}		
		var $pObj = $obj.parent().parent().parent().siblings().find('span');
		if($pObj.length != 0){
			getTitle($pObj);
		}
	}
	
	function setLastActiveMenuId(tmpActiveMenuId){
		if(tmpActiveMenuId){
			lastActiveMenuId = tmpActiveMenuId;
		}
	}
	
	function menuSearch(menuId){
		if(!menuId){
			menuId = $menuSearch.val();
			menuId = menuId.toUpperCase();
			$menuSearch.val(menuId);
		}
		
		var $menu = $menuList.find("li").filter("[MENUID="+menuId+"]").filter("[AMNUID!=FAVORITE]");
		if($menu.length > 0 && lastActiveMenuId != menuId){
			setMenuClick(menuId);
		}else{
			$menuSearch.val("");
		}
	}
	
	function setMenuClick(menuId){
		var $menu = $menuList.find("li").filter("[MENUID="+menuId+"]").filter("[AMNUID!=FAVORITE]");
		var pmenuId = $menu.attr("AMNUID");
		$menu.find("> a").trigger("click");
		if(pmenuId != "root"){
			setMenuClick(pmenuId);
		}		
	}
	
	function fmenuInsert(){
		if(lastActiveMenuId){
			var fmenu = $menuList.find("[AMNUID=FAVORITE]").find("[MENUID="+lastActiveMenuId+"]");
			if(fmenu.length == 0){
				var param = new DataMap();
				param.put("MENUID",lastActiveMenuId);
				var json = netUtil.sendData({
					module : "Common",
					command : "FMENU",
					sendType : "insert",
					param : param
				});
				
				var $menu = $menuList.find("li").filter("[MENUID="+lastActiveMenuId+"]");
				var $fmenu = $menuList.find("[MENUID=FAVORITE]");
				var $tmpMenu = $($menu.clone().wrapAll("<div/>").parent().html());
				$tmpMenu.filter("li").attr("AMNUID", "FAVORITE").removeClass("active").addClass("favmnu");
				$tmpMenu.append("<button class='delFav' onClick=\"fmenuDelete('"+lastActiveMenuId+"', this)\"> - </button>");
				//$fmenu.find("> a").trigger("click");
				$fmenu.find("ul").append($tmpMenu);
			}else{
				//$menuList.find("[MENUID=FAVORITE]").find("> a").trigger("click");
			}
		}
	}
	
	function fmenuDelete(menuId, obj){
		var param = new DataMap();
		param.put("MENUID",menuId);
		var json = netUtil.sendData({
			module : "Common",
			command : "FMENU",
			sendType : "delete",
			param : param
		});
		
		jQuery(obj).parent().remove();
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
</script>
</head>
<body>
<!-- lnb --->
<div class="lnb">
	<div class="icons">
		<input type="text" id="menuSearch" class="search_bg" placeholder="검색어를 입력하세요" size="14" onkeypress="commonUtil.enterKeyCheck(event,'menuSearch()')"/>
		<div class="rightArea">
			<!-- button class="button type1 first" type="button"><img src="/common<%=theme%>/images/ico_left1.png" alt=""></button-->
			<!-- <button class="button type1" type="button" onclick="window.top.refreshPage()"><img src="/common<%=theme%>/images/ico_left3.png" alt=""></button>		
			<button class="button type1 second" type="button" onclick="fmenuInsert()"><img src="/common<%=theme%>/images/ico_left2.png" alt=""></button> -->
		</div>
	</div>
	<ul class="list" id="menuList" style="display:none;">
		
<%
	DataMap map;
	String url;
	String amnuid;
	String spanClass;
	for(int i=0;i<list.size();i++){
		map = (DataMap)list.get(i);
		url = map.getString("PGPATH");
		amnuid = map.getString("AMNUID");
		if(url.indexOf("jsp") != -1){
			url = url.substring(1);
			url = url.substring(0, url.length()-3)+"page";
		}else{
			url = "";
		}
%>
<%
		if(amnuid.equals("FAVORITE")){
			spanClass = "fmnuTxt";			
%>			
		<li class="favmnu" AMNUID="<%=map.getString("AMNUID")%>" MENUID="<%=map.getString("MENUID")%>">
<% 		
		}else{
			spanClass = "mnuTxt";			
%>
		<li AMNUID="<%=map.getString("AMNUID")%>" MENUID="<%=map.getString("MENUID")%>">
<% 
		}
%>

<%
		//if(map.getString("AMNUID").equals("root")){
		if(url.equals("")){
%>
			<a href="#">
<%
		}else{
%>
			<a href="#" menuId="<%=map.getString("MENUID")%>" onclick="goPage(this, '<%=url%>')">
<%
		}
%>
			
				<span class="<%=spanClass%>"><%=map.getString("LBLTXL")%></span>
			</a>
<%
		if(map.getString("AMNUID").equals("FAVORITE")){
%>
			<button class="delFav" onClick="fmenuDelete('<%=map.getString("MENUID")%>', this)"> - </button>
<%
		}
%>
		</li>
<%
	}
%>
<%@ include file="/common/include/toolMenu.jsp" %>
	</ul>
</div>
<!-- //lnb -->
<script type="text/javascript">
	var keyMap = new DataMap();
	var $menuList = $("#menuList");
	$menuList.hide();
	$menuList.find('[AMNUID]').each(function(i,findElement){
		var $obj = jQuery(findElement);
		var AMNUID = $obj.attr("AMNUID");
		if(AMNUID != "root" && !keyMap.containsKey(AMNUID)){
			keyMap.put(AMNUID, AMNUID);
			var $groupList = $menuList.find("[AMNUID='"+AMNUID+"']");
			$menuList.find("[MENUID='"+AMNUID+"']").append($groupList);
			$groupList.wrapAll("<ul>");
		}
	});
	$menuList.show();
</script>
<script>
(function() {

	$(function() {

		var lnbTrigger = $('.lnbCloser')
			, lnb = $('.lnb')
			, tab = $('.tab.type1')
			, contHeader = $('.contentHeader')
			, content = $('.content')
			, depth1Trigger = lnb.find('.list').children('li')
			, depth2List = depth1Trigger.children('ul')
			, depth2Trigger = depth2List.children('li')
			, depth3List = depth2Trigger.children('ul')
			, motionTime = 0.35
			, xDist = 190;


		depth1Trigger.each(function() {
			var _this = $(this)
				, thisTrigger = _this.children('a')
				, thisDepth2List = _this.children('ul');

			thisTrigger.on({
				click : function() {
					if ( thisDepth2List.is(':hidden') ) {
						//depth1Trigger.removeClass('active');
						_this.addClass('active');

						//depth2List.not(thisDepth2List).stop().slideUp(200);
						thisDepth2List.stop().slideDown(200);
					} else {
						_this.removeClass('active');
						thisDepth2List.stop(true, true).slideUp(200);
					}
				}
			});
		});

		depth2Trigger.each(function() {
			var _this = $(this)
				, thisTrigger = _this.children('a')
				, thisDepth3List = _this.children('ul');

			if ( thisDepth3List.length ) {
				_this.addClass('hasDepth')
			}

			thisTrigger.on({
				click : function() {
					if ( thisDepth3List.is(':hidden') ) {
						//depth2Trigger.removeClass('active');
						_this.addClass('active');

						//depth3List.not(thisDepth3List).stop().slideUp(200);
						thisDepth3List.stop().slideDown(200);
					} else {
						_this.removeClass('active');
						thisDepth3List.stop(true, true).slideUp(200);
					}
				}
			});
		});
	});
})();
</script>
</body>
</html>