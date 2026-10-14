<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.common.bean.CommonConfig"%>
<%
	String theme =(String)request.getSession().getAttribute(CommonConfig.SES_USER_THEME_KEY);
%>
<!doctype html>
<html lang="ko">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta charset="utf-8">
<title></title>
<meta name="viewport" content="width=1150">
<link rel="stylesheet" type="text/css" href="/common<%=theme%>/css/common.css">
<link rel="stylesheet" type="text/css" href="/common/theme/hwls/css/wintab.css">
<link rel="stylesheet" type="text/css" href="/common<%=theme%>/css/theme.css">
<link rel="stylesheet" type="text/css" href="/common/theme/hwls/css/theme.css">
<script type="text/javascript" src="/common/js/jquery.js"></script>
<script type="text/javascript" src="/common/js/dataMap.js"></script>
<script type="text/javascript" src="/common/js/configData.js"></script>
<script type="text/javascript" src="/common/js/commonUtil.js"></script>
<script type="text/javascript" src="/common/js/ui.js"></script>
<script type="text/javascript">
	var $multiList;
	var $tabObj;
	var $pathTitle;
	$(document).ready(function(){
		$multiList = jQuery("#multiList");
		$tabObj = $multiList.find("li").clone();
		$multiList.find("li").remove();
		$pathTitle = $("#pathTitle");
		
		uiList.UICheck();
		
		$winTabLeft = $("#winTabLeft");
		$winTabRight = $("#winTabRight");
	});
	$(window).resize(function(event){
		checkTabListSize();
	});
	function sizeToggle(self){
		var self = $(self);
		var src = self.find("img").attr("src");
		var filename = src.substring(src.lastIndexOf("/")+1,src.lastIndexOf("."));
		filename!="ico_lnb_closer"?self.find("img").attr("src","/common<%=theme%>/images/ico_lnb_closer.png"):self.find("img").attr("src","/common<%=theme%>/images/ico_lnb_closel.png");
		console.log(filename)
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
		$multiList.find("li").removeClass("active");
		$tab.addClass("active");
		var menuId = $tab.attr("menuId");
		window.top.changeWindow(menuId);
		//var pathTitle = $tab.attr("pathTitle");
		//setPathTitle(pathTitle);		
	}
	function changeWindow(menuId){
		var $tab = $multiList.find("[menuId="+menuId+"]");
		if($tab.hasClass("active")){
			
		}else{
			activeTab($tab);
			/*
			$multiList.find("li").removeClass("active");
			$tabs.addClass("active");
			var pathTitle = $tabs.attr("pathTitle");
			window.top.changeWindow(menuId);
			$("#pathTitle").text(pathTitle);
			*/
		}
		checkTabListSize();
	}
	function closeWindow(menuId){
		var $tabs = $multiList.find("[menuId="+menuId+"]");
		$tabs.remove();
		var tmpActiveMenuId;
		if($tabs.hasClass("active")){
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
		
		checkTabListSize();
	}
	
	function closeAll(){
		var tabList = $multiList.find("li");
		var menuId;
		for(var i=0;i<tabList.length;i++){
			menuId = tabList.eq(i).attr("menuId");
			closeWindow(menuId);
		}
		
		checkTabListSize();
	}
	function setPage(pathTitle, title, url, menuId){
		//setPathTitle(pathTitle);
		
		$multiList.find("li").removeClass("active");
		var $tmpObj = $tabObj.clone();
		var $tmpSpan = $tmpObj.find("span").eq(0);
		$tmpSpan.text(title);
		$tmpObj.addClass("active");
		$tmpObj.attr("menuId",menuId);
		//$tmpObj.attr("pathTitle",pathTitle);
		$tmpSpan.click(function(event){
			var $obj = $(event.target);
			var menuId = $obj.parents("[menuId]").attr("menuId");
			changeWindow(menuId);
		});
		$tmpObj.find("img").click(function(event){
			var $obj = $(event.target);
			var menuId = $obj.parents("[menuId]").attr("menuId");
			closeWindow(menuId);
		});
		$multiList.append($tmpObj);
		
		checkTabListSize();
	}
	
	var tabBtnView = false;
	var $winTabLeft;
	var $winTabRight;
	var windTabWidth;
	var activeIndex;
	var $liList;
	function checkTabListSize(){
		var tabWidth = commonUtil.getCssNum($multiList, "width");
		var windTabWidth = 0;
		var activeWidth = 0;
		$liList = $multiList.find("li");
		if($liList.length > 1){
			var $tmpObj;
			var tmpStr;
			for(var i=0;i<$liList.length;i++){
				$tmpObj = $liList.eq(i);
				if($tmpObj.hasClass("active")){
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
</script>
</head>
<body class="content_header">
<button type="button" class="lnbCloser" onclick="sizeToggle(this)"><img src="/common/theme/hwls/images/ico_lnb_closer.png" alt="LNB Close" /></button>

<!-- 추가 -->
<button type="button" class="checkList"><img src="/common/theme/hwls/images/wintab/checkList.png" alt="checkList" /></button>
<button type="button" class="favorite"><img src="/common/theme/hwls/images/wintab/fav.png" alt="favorite" /></button>
<!-- 추가 끝 -->

<div class="tab type1" id="windowTabs">
	<div class="menu-info" id="pathTitle">
		<!--<div class="all_close" id="allClose">
			<img src="/common/theme/hwls/images/main/wintab_close_for_opentab.png" alt="close" onClick="closeAll()" />			
		</div>-->
		<!--<div class="tab_list" id="tabList">
			<img src="/common/theme/hwls/images/main/wintab_close_for_opentab.png" alt="left"  id="winTabLeft" onClick="tabLeft()" style="display:none" />
			<img src="/common/theme/hwls/images/main/wintab_close_for_closetab.png" alt="right" id="winTabRight" onClick="tabRight()" style="display:none;" />
		</div>-->
	</div>
	<ul id="multiList">
		<li><div class="tab_right"><span class="txt_wrap">Sample</span><img src="/common/theme/darkness/images/btn_null.png" alt="close" /></div></li>
	</ul>
</div>





</body>
</html>