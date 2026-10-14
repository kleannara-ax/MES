<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.common.bean.DataMap,java.util.*"%>
<%
	List<DataMap> list = (List)request.getAttribute("list");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS Left</title>
<meta name="viewport" content="width=1150">
<link rel="stylesheet" type="text/css" href="/common/css/reset.css">
<link rel="stylesheet" type="text/css" href="/common/css/lnb.css">
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
	});
	
	function changePage(obj, title, url, menuId){	
		
		var $obj = $(obj).parent();
		
		titleTxt = "";
		getTitle($obj);
		//alert(titleTxt);
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
	
	function menuSearch(menuId){
		if(!menuId){
			menuId = $menuSearch.val();
			menuId = menuId.toUpperCase();
			$menuSearch.val(menuId);
		}
		
		var $menu = $menuList.find("li").filter("[MENUID="+menuId+"]").filter("[AMNUID!=FAVORITE]");
		if($menu && lastActiveMenuId != menuId){
			//var tmpTxt = $menu.attr("MENUTXT");
			//var tmpUrl = $menu.attr("MENUURL");
			//var tmpMenuid = $menu.attr("MENUID");
			//changePage($menu.find("a"), tmpTxt, tmpUrl, tmpMenuid);
						
			setMenuClick(menuId);
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
				$tmpMenu.filter("li").attr("AMNUID", "FAVORITE");
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
<div class="lnb_top_space"></div>
<div class="lnb">
	<div class="icons">
		<span class="bg_searchbox1"></span><input type="text" id="menuSearch" size="14" onkeypress="commonUtil.enterKeyCheck(event,'menuSearch()')"/><span class="bg_searchbox2"><img src="/common/images/ico_find2.png" alt=""/></span>
		<div class="rightArea">
			<!-- button class="button type1 first" type="button"><img src="/common/images/ico_left1.png" alt=""></button-->
			<button class="button type1" type="button" onclick="window.top.refreshPage()"><img src="/common/theme/darkness/images/ico_left22.png" alt=""></button>		
			<button class="button type1 second" type="button" onclick="fmenuInsert()"><img src="window.top.refreshPage()"><img src="/common/theme/darkness/images/ico_left33.png" alt=""></button> 
		</div>
	</div>
	<ul class="list" id="menuList" style="display:none;">
		
<%
	DataMap map;
	String url;
	String amnuid;
	String spanClass;
	for(int i=0;i<list.size();i++){
		map = list.get(i);
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
		<li class="favmnu" MENUTXT="<%=map.getString("LBLTXL")%>" MENUURL="<%=url%>" AMNUID="<%=map.getString("AMNUID")%>" MENUID="<%=map.getString("MENUID")%>">
<% 		
		}else{
			spanClass = "mnuTxt";			
%>
		<li MENUTXT="<%=map.getString("LBLTXL")%>" MENUURL="<%=url%>" AMNUID="<%=map.getString("AMNUID")%>" MENUID="<%=map.getString("MENUID")%>">
<% 
		}
%>

<%
		//if(map.getString("AMNUID").equals("root")){menuSearch
		if(url.equals("")){
%>
			<a href="#">
<%
		}else{
%>
			<a href="#" menuId="<%=map.getString("MENUID")%>" onclick="changePage(this, '<%=map.getString("LBLTXL")%>', '<%=url%>', '<%=map.getString("MENUID")%>')">
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
		<li MENUTXT="TOOL" MENUURL="" AMNUID="root" MENUID="TOOL">
			<a href="#"><span class="mnuTxt">TOOL</span></a>
		</li>
		<li MENUTXT="SAMPLE" MENUURL="/wms/sample/sample.page" AMNUID="TOOL" MENUID="SAMPLE">
			<a href="#" menuId="SAMPLE" onclick="changePage(this, 'SAMPLE', '/wms/sample/sample.page', 'SAMPLE')">
				<span class="mnuTxt">SAMPLE</span>
			</a>
		</li>
		<li MENUTXT="SAMPLE1" MENUURL="/wms/sample/sample1.page" AMNUID="TOOL" MENUID="SAMPLE1">
			<a href="#" menuId="SAMPLE1" onclick="changePage(this, 'SAMPLE1', '/wms/sample/sample1.page', 'SAMPLE1')">
				<span class="mnuTxt">SAMPLE1</span>
			</a>
		</li>
		<li MENUTXT="TABLE" MENUURL="/common/tool/table.page" AMNUID="TOOL" MENUID="TABLE">
			<a href="#" menuId="TABLE" onclick="changePage(this, 'TABLE', '/common/tool/table.page', 'TABLE')">
				<span class="mnuTxt">TABLE</span>
			</a>
		</li>
		<li MENUTXT="SQL" MENUURL="/common/tool/sql.page" AMNUID="TOOL" MENUID="SQL">
			<a href="#" menuId="SQL" onclick="changePage(this, 'SQL', '/common/tool/sql.page', 'SQL')">
				<span class="mnuTxt">SQL</span>
			</a>
		</li>
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
						depth1Trigger.removeClass('active');
						_this.addClass('active');

						depth2List.not(thisDepth2List).stop().slideUp(200);
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
						depth2Trigger.removeClass('active');
						_this.addClass('active');

						depth3List.not(thisDepth3List).stop().slideUp(200);
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