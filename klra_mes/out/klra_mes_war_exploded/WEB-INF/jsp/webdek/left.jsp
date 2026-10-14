<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="project.common.bean.*,java.util.*"%>
<%
	String username = request.getSession().getAttribute(CommonConfig.SES_USER_NAME_KEY).toString();
	String compky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_COMPANY_KEY);
	List<DataMap> mlist = (List)request.getSession().getAttribute(CommonConfig.SES_USER_MENU_KEY);
	List<DataMap> flist = (List)request.getSession().getAttribute(CommonConfig.SES_USER_FMENU_KEY);
	
	String theme =(String)request.getSession().getAttribute(CommonConfig.SES_USER_THEME_KEY);
	
	String menuSearchId = request.getParameter("menuSearchId");
%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<title>index left</title>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/left_green.css"/>
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

	var windowH;//guick menu height 200px 포함
	$(".lnb_wrap").css("height", "calc(100vh - 100px)");
	$(window).resize(function() {
		windowH = $(window).height() - 150//guick menu height 200px 포함
		$(".lnb_wrap").css("height", "calc(100vh - 100px)");
		$(".guick_menu").css("height", "calc(100vh - 100px)")
	});

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
			
			if(!($("#tab2 .lnb_dep01>li").hasClass("dep01_focus"))){
	            $("#tab2 .lnb_dep01>li").addClass("dep01_focus");
	            $("#tab2 .lnb_dep01>li").children(".lnb_dep02").toggleClass("open");
	            $("#tab2 .lnb_dep01>li").children(".lnb_dep02").children("li").removeClass("dep02_focus").add("open");
			}
		});
		  
		$(".sys_menu").click(function() {
			$("#tab1").css("display","block");
			$("#tab2").css("display","none");
			$(this).removeClass("off").addClass("on");
			$(".my_menu").removeClass("on").addClass("off");
		});
		    
		
		$menuSearch = jQuery("#menuSearch");
		$dep01 = $("#tab1 .lnb_dep01 > li");
		$dep02 = $(".lnb_dep02 > li");
		$dep03 = $(".lnb_dep03 > li");
		//menuSearch("SAMPLE");
		
		$menuList.find("[AMNUID=root]").addClass("open");
		
		$dep01.on("click",function(e){
			if($dep02.children(".lnb_dep03").hasClass("open")){
				$(this).toggleClass("dep01_focus");
				$(this).children(".lnb_dep02").toggleClass("open");
				$(this).children(".lnb_dep02").children("li").toggleClass("open");
			}else{
				$(this).toggleClass("dep01_focus");
				$(this).children(".lnb_dep02").toggleClass("open");
				$(this).children(".lnb_dep02").children("li").removeClass("dep02_focus_on").toggleClass("open");
			}
		});
		
		$dep02.on("click",function(e){
			e.stopPropagation();
			
			if($(this).children(".lnb_dep03").length > 0){
				$(this).toggleClass("on");
				$(this).children(".lnb_dep03").toggleClass("open");
				$(this).children(".lnb_dep03").children("li").addClass("open");
				if($(this).hasClass("dep02_focus_off")){
					$(this).toggleClass("dep02_focus_on");
				}
			}
		});
		
		$dep03.on("click",function(e){
			e.stopPropagation();
		});
		
		
		
		/* $menuList.on("click",function(){
			if($dep02.hasClass("open")){
				
			}			$(this).children("ul").addClass("open");	
			$(this).children("ul").children("li").toggle(400);
		}); */
		
		
		
		/* $menuList.find("li > a").click(function() {
			var $tmpObj = $(this).parent();
			var tmpMenuId = $tmpObj.attr("MENUID");
			var tmpAmenuId = $tmpObj.attr("AMNUID");
			if($tmpObj.find(">ul").length == 0){
				return false;
			}
			if($tmpObj.find(">ul").hasClass("open")){
				$tmpObj.children(">ul>li").removeClass("dep01_focus");
				$tmpObj.find(">ul").removeClass("open");
				$tmpObj.find(">ul>li").removeClass("open");
			}else{
				$tmpObj.children(">ul>li").addClass("dep01_focus");
				$tmpObj.find(">ul").addClass("open"); //lnb_dep02
				$tmpObj.find(">ul>li").addClass("open"); //lnb_dep02 li
				$tmpObj.find(">ul>li>ul>li").css("background-color","#f5f5f7"); //lnb_dep03 li
			}			
		    return false;
		}); */
		
		<%
			if(menuSearchId != null){
		%>
			$("#menuSearch").val("<%=menuSearchId%>");
			menuSearch();
		<%
			}
		%>
		
		//배경적용
		var wh = $(window.top).height();
		var ww = $(window.top).width();

		var bgDiv = "<div class='bgDiv' style='height:"+wh+"px;width:"+ww+"px;position:absolute;top:-80px;left:0; z-index:-1;background:url(/common/theme/webdek/images/web_bg.png) repeat center center;background-size:cover;'></div>";

		$('body',top.frames["left"].document).append(bgDiv);
		$('.bgDiv',top.frames["left"].document).css({top:-80+"px", left:0 });
	});
	
	
	function goPage(obj, url){
		var $obj = $(obj).parent();
		var menuId = $obj.attr(configData.COMMON_MENU_ID_KEY);
		var title = $obj.text();
		changePage(obj, title, url, menuId);
		/*
		if($(obj).parent().hasClass("open")){
	        $(".lnb_dep01 > li").removeClass("open");
	    }else {
	        $(obj).parent().addClass("open").siblings().removeClass("open");
	    }
		*/
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
			//$menuList.find(".on").removeClass("on");
			//$obj.parents("li").addClass("on");
			if($lastActiveObj){
				$lastActiveObj.removeClass("on");
			}
			$obj.addClass("on");
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
		/*
		var $pObj = $obj.parent().parent().parent().siblings().find('span');
		if($pObj.length != 0){
			getTitle($pObj);
		}
		*/
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
			var param = new DataMap();
			param.put("MENUID", menuId);
			var json = netUtil.sendData({
				url : "/gcim/json/menuCheck.data",
				param : param
			});
			if(json && json.PMENUID){
				this.location.href = "/gcim/left.page?menuSearchId="+menuId;
				top.changeTopMenu(json.PMENUID);
			}
			$menuSearch.val("");
		}
	}
	
	function setMenuClick(menuId){
		//$menuList.find(".on").removeClass("on");
		var $menu = $menuList.find("li").filter("[MENUID="+menuId+"]").filter("[AMNUID!=FAVORITE]");
		var pmenuId = $menu.attr("AMNUID");
		$menu.find("> a").trigger("click");
	}
	
	function setPMenuClick(menuId){
		var $menu = $menuList.find("li").filter("[MENUID="+menuId+"]").filter("[AMNUID!=FAVORITE]");
		var pmenuId = $menu.attr("AMNUID");
		if(!$menu.hasClass("open") && !$menu.hasClass("dep01_focus")){
			$menu.find("> a").trigger("click");
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
	
	function logout(){
		location.href = "/common/json/logout.page";
	}
	
	
	//1112
	
	$(function () {	
		tab('#tabs',0);	
	});

	function tab(e, num){
	    var num = num || 0;
	    var menu = $(e).children();
	    var con = $(e+'_content').children();
	    var select = $(menu).eq(num);
	    var i = num;

	    select.addClass('on');
	    con.eq(num).show();

	    menu.click(function(){
	        if(select!==null){
	            select.removeClass("on");
	            con.eq(i).hide();
	        }

	        select = $(this);	
	        i = $(this).index();

	        select.addClass('on');
	        con.eq(i).show();
	    });
	}
	
	function reloadPage(){
		location.reload();
	}
	
	function addFmenu(menuId){
		var param = new DataMap();
		param.put("MENUID", menuId);
		var json = netUtil.sendData({
			url : "/gcim/json/menuData.data",
			param : param
		});
		if(json && json.data){
			var tmpHtml = '<li AMNUID="FAV" MENUID="'+json.data.MENUID+'">\n'
				+ '<a href="#none" onclick="goPage(this, \''+json.data.URI+'\')">\n'
				+ '['+json.data.MENUID+'] '+json.data.LBLTXL+'\n'
				+ '</a>\n'
				+ '</li>\n';
			$("#FMENULIST").append(tmpHtml);
			fmenuMap.put(menuId, true);
		}
	}
	
	function deleteFmenu(menuId){
		$("#FMENULIST").find("[MENUID="+menuId+"]").remove();
	}
	
	function menuOpenAll(btn){
		$(btn).toggleClass("slide")
		if($(btn).hasClass("slide")){
			$("#tab1 .lnb_dep01>li").addClass("dep01_focus");
			$("#tab1 .lnb_dep02").addClass("open");
			$("#tab1 .lnb_dep02>li").find("ul").parents(".lnb_dep02>li").addClass("open on");
			$("#tab1 .lnb_dep03").addClass("open");
		}else{
			$("#tab1 .lnb_dep01>li").removeClass("dep01_focus");
			$("#tab1 .lnb_dep02").removeClass("open");
			$("#tab1 .lnb_dep02>li").removeClass("open on");
			$("#tab1 .lnb_dep03").removeClass("open");
		}
	}
</script>
</head>
<body>
<!-- left_wrap -->
<div class="left_wrap">
		<!-- info my -->	
	<!-- // info my -->		
	<!-- // tab -->	
<div class="tab_wrap"> 
    <ul class="tabs">
	<!--  sys_menu_tab -->
        <li class="tab sys_menu on">
       	 <h1 class="btn_sysmenu">
			<a href="#tab1"><span>System Menu</span></a>	
		</h1>        	
	<!-- // sys_menu_tab -->
        </li>
        <!--  Quick menu -->	
        <li class="tab my_menu off">
	         <h1 class="btn_mymenu">
				<a href="#tab2"><span>My Menu</span></a>	
			</h1>
        </li>
	<!-- // Quick menu -->	   	
	<!-- Quick menu -->     
    </ul>

	<!-- // search -->
 <div class="tab_container">
    <fieldset>
		<legend>search</legend>
		<p class="search_box">
		<input type="text" class="serch_input serch_input_change" id="menuSearch" placeholder="메뉴코드를 입력해 주세요." onkeypress="commonUtil.enterKeyCheck(event,'menuSearch()')"/>
		<button type="button" class="btn btn_search btn_search_change" onclick="menuSearch()"><span>메뉴코드를 입력해 주세요.</span></button>
		<div class="sort_box sort_box_change">		
			<button type="button" class="btn_asc" onclick="menuOpenAll(this)"></button>
			<!-- <button type="button" class="btn_desc"></button> -->
		</div>
		</p>		
	</fieldset>
	
 <div id="tab1" class="tab_content">	
		<!-- lnb wrap -->
	<div class="lnb_wrap">
		<ul class="lnb_dep01" id="menuList" style="display:none;">
<%
	DataMap row;
	String url;
	String roodMenuId = "root";
	
if(mlist != null){
	for(int i=0;i<mlist.size();i++){
		row = (DataMap)mlist.get(i);
		
		url = row.getString("PGPATH");
		if(url.indexOf("jsp") != -1){
			url = url.substring(1);
			url = url.substring(0, url.length()-3)+"page";
		}else{
			url = "";
		}
		
		if(row.getString("URI").equals("")){
%>
		<li AMNUID="<%=row.getString("PMENUID")%>" MENUID="<%=row.getString("MENUID")%>">
			<a href="#none"><%=row.getString("MENUNAME")%></a>
		</li>
<%
		}else{
%>	
		<li AMNUID="<%=row.getString("PMENUID")%>" MENUID="<%=row.getString("MENUID")%>">
			<a href="#none" onclick="goPage(this, '<%=row.getString("URI")%>')" <% if ("PRG".equals(row.getString("PRGFLG"))){ %>class="prg" <%} %>>
				[<%=row.getString("MENUID")%>] <%=row.getString("MENUNAME")%>
			</a>
		</li>
<%
		}
	}
}
%>
		</ul>
	</div>
	<!-- // lnb wrap -->
 </div>
	
 <div id="tab2" class="tab_content" style="display:none;">
	<div class="guick_menu">
		<!-- <p class="guick_link">
			<span class="guick_tit">Quick menu</span>
			<button type="button" class="btn btn_guick_more" ><span>more</span></button>
		</p> -->
		<ul class="lnb_dep01" style="display: block;">
			<li class="open">
				<a href="#">Favorite</a>
				<ul class="lnb_dep02" id="FMENULIST">
					<!--li AMNUID="FAV" MENUID="MSTCOMP">
						<a href="#none" onclick="goPage(this, '/master/MSTCOMP.page')">
							Company Master
						</a>
					</li-->
<%
if(flist != null){
	for(int i=0;i<flist.size();i++){
		row = (DataMap)flist.get(i);
		
		url = row.getString("PGPATH");
		if(url.indexOf("jsp") != -1){
			url = url.substring(1);
			url = url.substring(0, url.length()-3)+"page";
		}else{
			url = "";
		}

%>
					<li AMNUID="FAV" MENUID="<%=row.getString("MENUID")%>">
						<a href="#none" onclick="goPage(this, '<%=row.getString("URI")%>')" <% if ("PRG".equals(row.getString("PRGFLG"))){ %>class="prg" <%} %>>
							[<%=row.getString("MENUID")%>] <%=row.getString("MENUNAME")%>
						</a>
					</li>
<%
	}
}
%>
				</ul>
			</li>
		</ul>
	</div>
 </div>
 
 </div>
 
 <%-- <div class="wrap_btn" >
 	<div class="alert">
 		<i class="label label-warning">3</i>
 		<button type="button" class="btn_alert"><span>alert</span></button>
 	</div>
 	<div class="set">
 	<button type="button" class=" btn_setting"><span>setting</span></button>
 	</div>
	<div class="info_my">
		<a href="#none" class="name_user"><%=username%></a>
		<button type="button" class="btn_logout" onClick="logout()"><span>logout</span></button>
	</div>
</div> --%>
</div>
</div>

<script type="text/javascript">
	var keyMap = new DataMap();
	var dep2keyList = new Array();
	var dep3keyList = new Array();
	var $menuList = $("#menuList");
	$menuList.find('[AMNUID=root]').attr('AMNUID','<%=roodMenuId%>');
	
	$menuList.find('[AMNUID=<%=roodMenuId%>]').each(function(index,findElement){
		var $obj = jQuery(findElement);
		var MENUID = $obj.attr("MENUID");
		var $groupList = $menuList.find("[AMNUID='"+MENUID+"']");
		if($groupList.length > 0){
			for(var j=0;j<$groupList.length;j++){
				dep2keyList.push($groupList.eq(j).attr("MENUID"));
			}
			$obj.append($groupList);
			$groupList.wrapAll("<ul class='lnb_dep02'>");
		}
	});
	
	for(var i=0;i<dep2keyList.length;i++){
		var MENUID = dep2keyList[i];
		var $groupList = $menuList.find("[AMNUID='"+MENUID+"']");
		if($groupList.length > 0){
			for(var j=0;j<$groupList.length;j++){
				dep3keyList.push($groupList.eq(j).attr("MENUID"));
			}
			$menuList.find("[MENUID='"+MENUID+"']").append($groupList);
			$groupList.wrapAll("<ul class='lnb_dep03'>");
		}
	}
	
	for(var i=0;i<dep3keyList.length;i++){
		var MENUID = dep3keyList[i];
		var $groupList = $menuList.find("[AMNUID='"+MENUID+"']");
		if($groupList.length > 0){
			$menuList.find("[MENUID='"+MENUID+"']").append($groupList);
			$groupList.wrapAll("<ul class='lnb_dep03'>");
		}
	}
	/*
	$menuList.find('[AMNUID]').each(function(i,findElement){
		var $obj = jQuery(findElement);
		var AMNUID = $obj.attr("AMNUID");		
		if(AMNUID != "root" && !keyMap.containsKey(AMNUID)){
			keyMap.put(AMNUID, AMNUID);
			var $groupList = $menuList.find("[AMNUID='"+AMNUID+"']");
			$menuList.find("[MENUID='"+AMNUID+"']").append($groupList);
			if(!dep2keyMap.containsKey(AMNUID)){
				$groupList.wrapAll("<ul class='lnb_dep02'>");
			}else if($obj.parents("UL").hasClass("lnb_dep02")){
				$groupList.wrapAll("<ul class='lnb_dep03'>");
			}else if($obj.parents("UL").hasClass("lnb_dep03")){
				$groupList.wrapAll("<ul class='lnb_dep04'>");
			}			
		}
	});
	*/
	$menuList.show();
	
	if($menuList.find('[AMNUID=<%=roodMenuId%>]').length == 1){
		$menuList.find('[AMNUID=<%=roodMenuId%>]').eq(0).addClass("open");
	}
	
	var fmenuMap = new DataMap();
<%
if(flist != null){
	for(int i=0;i<flist.size();i++){
		row = (DataMap)flist.get(i);
%>
	fmenuMap.put("<%=row.getString("MENUID")%>",true);
<%
	}
}
%>

	function checkFmenu(menuId){
		return fmenuMap.containsKey(menuId);
	}
</script>
<!-- // left_wrap -->
</body>
</html>