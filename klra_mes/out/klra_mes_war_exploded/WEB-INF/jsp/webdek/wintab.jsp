<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="project.common.bean.CommonConfig"%>
<%
	String theme =(String)request.getSession().getAttribute(CommonConfig.SES_USER_THEME_KEY);

	String color =(String)request.getSession().getAttribute("COLOR");
%>
<!doctype html>
<html lang="ko">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta charset="utf-8">
<title></title>
<meta name="viewport" content="width=1150">
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/wintab.css"/>
<script type="text/javascript" src="/common/js/jquery.js"></script>
<script type="text/javascript" src="/common/js/dataMap.js"></script>
<script type="text/javascript" src="/common/js/configData.js"></script>
<script type="text/javascript" src="/common/js/commonUtil.js"></script>
<script type="text/javascript" src="/common/js/netUtil.js"></script>
<script type="text/javascript" src="/common/js/ui.js"></script>
<script type="text/javascript">
	var $multiList;
	var $tabObj;
	var $pathTitle;
	var $winTabLeft;
	var $winTabRight;
	
	var tabBtnView = false;
	var windTabWidth;
	var activeIndex;
	var activeMenuid;
	var $liList;
	var $addFbtn;
	var $deleteFbtn;
	$(document).ready(function(){
		
		$(document.body).show();
		
		$multiList = jQuery("#multiList");
		$tabObj = $multiList.find("li").clone();
		$multiList.find("li").remove();
		$pathTitle = $("#pathTitle");
		
		uiList.UICheck();
		
		$winTabLeft = $("#winTabLeft");
		$winTabRight = $("#winTabRight");
		$winTabLeft.hide();
		$winTabRight.hide();
		
		$addFbtn = $(".btn_fav_before");
		$deleteFbtn = $(".btn_fav_after");
		
		$addFbtn.hide();
		$deleteFbtn.hide();
	});
	$(window).resize(function(event){
		checkTabListSize();
	});
	function sizeToggle(self){
		window.top.sizeToggle();
	}
	/*
	function setPathTitle(pathTitle){
		return;
		if(pathTitle.length > 50){
			pathTitle = " ";
		}
		$pathTitle.text(pathTitle);
	}	
	*/
	function activeTab($tab){
		$multiList.find("li").removeClass("selected");
		$tab.addClass("selected");
		var menuId = $tab.attr("menuId");
		activeMenuid = menuId;
		window.top.changeWindow(menuId);
		viewFbtn();
		//var pathTitle = $tab.attr("pathTitle");
		//setPathTitle(pathTitle);		
	}
	function changeWindow(menuId){
		var $tab = $multiList.find("[menuId="+menuId+"]");
		if($tab.hasClass("selected")){
			
		}else{
			activeTab($tab);
		}
		checkTabListSize();
	}
	function closeWindow(menuId){
		var $tabs = $multiList.find("[menuId="+menuId+"]");
		$tabs.remove();
		var tmpActiveMenuId;
		if($tabs.hasClass("selected")){
			var $tabList = $multiList.find("[menuId]");
			if($tabList.length >= 1){
				var $tmpTab = $tabList.eq($tabList.length-1);
				activeTab($tmpTab);
				tmpActiveMenuId = $tmpTab.attr("menuId");
			}
		}else{
			tmpActiveMenuId = " ";
		}		
		window.top.closeWindow(menuId, tmpActiveMenuId);
		$("li[menuid="+menuId+"]",top.frames["left"].document).removeClass("on");
		
		checkTabListSize();
		
		if($(".tab_style01>li").length==0){
			$addFbtn.hide();
			$deleteFbtn.hide();
		}
	}
	
	function closeAll(){
		var tabList = $multiList.find("li");
		var menuId;
		for(var i=0;i<tabList.length;i++){
			menuId = tabList.eq(i).attr("menuId");
			closeWindow(menuId);
		}

		checkTabListSize();
		$addFbtn.hide();
		checkTabListSize();
	}
	function setPage(pathTitle, title, url, menuId){
		//setPathTitle(pathTitle);
		
		$multiList.find("li").removeClass("selected");
		var $tmpObj = $tabObj.clone();
		var $tmpText = $tmpObj.find("a").eq(0);
		if(title.indexOf("]") != -1){
			$tmpText.text(title.substring(title.indexOf("]")+2));
		}else{
			$tmpText.text(title);
		}
		
		$tmpText.attr("title", title.trim());
		
		$tmpObj.addClass("selected");
		$tmpObj.attr("menuId",menuId);
		//$tmpObj.attr("pathTitle",pathTitle);
		$tmpText.click(function(event){
			var $obj = $(event.target);
			var menuId = $obj.parents("[menuId]").attr("menuId");
			changeWindow(menuId);
		});
		var $btnList = $tmpObj.find("button");
		/*
		$btnList.eq(0).click(function(event){
			window.top.refreshPage();
		});
		
		$btnList.eq(1).click(function(event){
			alert("No files");
		});
		*/
		$btnList.eq(0).click(function(event){
			var $obj = $(event.target);
			var menuId = $obj.parents("[menuId]").attr("menuId");
			closeWindow(menuId);
		});		
		$multiList.append($tmpObj);
		
		activeMenuid = menuId;
		viewFbtn();
		checkTabListSize();
	}
	
	
	function checkTabListSize(){
		var tabWidth = commonUtil.getCssNum($multiList, "width");
		tabWidth -= 100;
		var windTabWidth = 0;
		var activeWidth = 0;
		$liList = $multiList.find("li");
		if($liList.length > 1){
			var $tmpObj;
			var tmpStr;
			for(var i=0;i<$liList.length;i++){
				$tmpObj = $liList.eq(i);
				if($tmpObj.hasClass("selected")){
					activeWidth = windTabWidth;
					activeIndex = i;
				}
				windTabWidth += commonUtil.getCssNum($tmpObj, "width");
			}
			windTabWidth -= ($liList.length-1)*7;
		}		
		if(windTabWidth > tabWidth){
			tabBtnView = true;
			showActiveTab();
		}else{
			tabBtnView = false;
		}
		if(tabBtnView){
			$winTabLeft.show();
			$winTabRight.show();
			$pathTitle.css("margin-right","7px");
		}else{
			$winTabLeft.hide();
			$winTabRight.hide();
			for(var i=0;i<$liList.length;i++){
				$liList.eq(i).show();
			}
			$pathTitle.css("margin-right","0px");
		}
	}
	
	function showActiveTab(){
		for(var i=0;i<activeIndex;i++){
			$liList.eq(i).hide();
		}
		for(var i=activeIndex;i<$liList.length;i++){
			$liList.eq(i).show();
		}
	}
	
	function tabLeft(){
		if(activeIndex > 0){
			activeIndex --;
			showActiveTab();
		}
	}
	
	function tabRight(){
		if(activeIndex < $liList.length-1){
			activeIndex ++;
			showActiveTab();
		}
	}
	
	function viewFbtn(){
		if(top.checkFmenu(activeMenuid)){
			$addFbtn.hide();
			$deleteFbtn.show();
		}else{
			$addFbtn.show();
			$deleteFbtn.hide();
		}
	}
	
	function addFmenu(){
		var param = new DataMap();
		param.put("MENUID", activeMenuid);
		param.put("SORTORDER", 10);
		var json = netUtil.sendData({
			url : "/common/json/addFmenu.data",
			param : param
		});
		if(json && json.data){
			$addFbtn.hide();
			$deleteFbtn.show();
			top.addFmenu(activeMenuid);
		}
	}
	
	function deleteFmenu(){
		var param = new DataMap();
		param.put("MENUID", activeMenuid);
		var json = netUtil.sendData({
			url : "/common/json/deleteFmenu.data",
			param : param
		});
		if(json && json.data){
			$addFbtn.show();
			$deleteFbtn.hide();
			top.deleteFmenu(activeMenuid);
		}
	}
	
	function loadingOpen() {
	}

	function loadingClose() {
	}
</script>
</head>
<body>
<!-- content top -->
<div class="content_top">
	<button type="button"  class="btn btn_bigger" onclick="sizeToggle(this)"><span>bigger</span></button>
	<div class="tab_style_wrap">
		<ul class="tab_style01" id="multiList">
			<li>
				<a href="#">defalut title</a>
				<!-- button type="button" class="btn btn_help"><span>help</span></button -->
				<button type="button" class="btn btn_tab_del"><span>tab deleted</span></button>
			</li>
		</ul>
	</div>
	<!-- // tab style 01 -->
	<div class="btn_top" id="pathTitle">
		<!-- btn 명은 변경해주 -->
		<button type="button" class="btn btn-1" id="winTabLeft" onClick="tabLeft()"><span>btn-1</span></button>
		<button type="button"  class="btn btn-2" id="winTabRight" onClick="tabRight()"><span>btn-2</span></button>
		<button type="button"  class="btn btn-3" onclick="window.top.refreshPage()"><span>btn-3</span></button>
		<button type="button"  class="btn btn-4" onClick="closeAll()"><span>btn-4</span></button>
		<button type="button"  class="btn btn_fav_before" onClick="addFmenu()"><span>btn-fav</span></button>
		<button type="button"  class="btn btn_fav_after" onClick="deleteFmenu()"><span>btn-fav</span></button>
		<!-- button type="button"  class="btn btn-5"><span>btn-5</span></button-->
		<!-- <button type="button" class="btn btn_extend" onclick="sizeToggle(this)"><span>left menu close</span></button> -->
		<!-- left menu open <button type="button" class="btn btn_left_o"><span>left menu open</span></button> -->
		<!-- <button type="button" class="btn btn_win_c" onClick="closeAll()"><span>widow close</span></button> -->
	</div>
</div>
<!-- // content top -->
</body>
</html>