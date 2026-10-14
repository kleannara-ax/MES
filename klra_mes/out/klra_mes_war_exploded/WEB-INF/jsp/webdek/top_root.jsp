<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="project.common.bean.*,java.util.*"%>
<%
	String userid = request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY).toString();
	String username = request.getSession().getAttribute(CommonConfig.SES_USER_NAME_KEY).toString();
	String langky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_LANGUAGE_KEY);
	String compid = (String)request.getSession().getAttribute(CommonConfig.SES_USER_COMPANY_KEY);
    String deptid = (String)request.getSession().getAttribute(CommonConfig.SES_DEPT_ID_KEY);
	
    BaseUser user = (BaseUser)session.getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
	
	String theme =(String)request.getSession().getAttribute(CommonConfig.SES_USER_THEME_KEY);
	
	List<DataMap> mlist = (List)request.getSession().getAttribute(CommonConfig.SES_USER_ROOT_MENU_KEY);
%>
<!doctype html>
<html lang="ko">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta charset="utf-8">
<title></title>
<meta name="viewport" content="width=1150">
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/top_green.css"/>
<script type="text/javascript" src="/common/js/jquery.js"></script>
<script type="text/javascript" src="/common/js/jquery-ui.js"></script>
<script type="text/javascript" src="/common/js/json2.js"></script>
<script type="text/javascript" src="/common/js/dataMap.js"></script>
<script type="text/javascript" src="/common/js/configData.js"></script>
<script type="text/javascript" src="/common/js/label.js"></script>
<script type="text/javascript" src="/common/lang/label-<%=langky%>.js"></script>
<script type="text/javascript" src="/common/lang/message-<%=langky%>.js"></script>
<script type="text/javascript" src="/common/js/commonUtil.js"></script>
<script type="text/javascript" src="/common<%=theme%>/js/theme.js"></script>
<script type="text/javascript" src="/common/js/dataBind.js"></script>
<script type="text/javascript" src="/common/js/site.js"></script>
<script type="text/javascript" src="/common/js/input.js"></script>
<script type="text/javascript" src="/common/js/netUtil.js"></script>
<script type="text/javascript" src="/common/js/validateUtil.js"></script>
<script type="text/javascript" src="/common/js/ui.js"></script>

<script>
//로딩 열기
	function loadingOpen() {

	}
	
	// 로딩 닫기
	function loadingClose() {

	}
	
	function logout(){
		window.top.location.href = "/common/json/logout.page";
	}
	
	function logoEffectStart(){
	}
	
	function logoEffectStop(){

	}
	
	$(document).ready(function(){
		uiList.UICheck();
		inputList.setCombo();
		 
		var param = new DataMap();
		var json = netUtil.sendData({
			url : "/common/json/rootDataList.data",
			param : param
		});
		 
		if(json && json.data){
			var rootMenu = json.SES_ROOT_MENUID;
			$("#menuList").val(rootMenu);
			
			var rootComp = json.SES_ROOT_COMPID;
			$("#compList").val(rootComp);
			
			var subMenuList = json.SES_ROOT_SUB_MENULIST;
			var subMenu = json.SES_ROOT_SUB_MENU;
			var $subMenuList = $("#subMenuList");
			for(var i=0;i<subMenuList.length;i++){
				$subMenuList.append('<li onClick="changePage(this)" id="'+subMenuList[i]["MENUID"]+'" ><a href="#tab'+(i+1)+'"><span>'+subMenuList[i]["MENUNAME"]+'</span></a></li>');
			}

			$("#"+subMenu).addClass("on");
			//top.changeSubMenu(subMenu);
		}
	});
	
	var selectMenuId;
	function changePage(obj){
		var $obj = $(obj);
		$(".topmenu_tab li").removeClass("on");
		$obj.addClass("on");
		var tmpMenuId = $obj.attr("id");
		if(tmpMenuId != selectMenuId){
			selectMenuId = tmpMenuId;
		}
		
		var param = new DataMap();
		param.put("MENUID", selectMenuId);
		var json = netUtil.sendData({
			url : "/common/json/rootSubChange.data",
			param : param
		});
		 
		if(json && json.data){
			top.changeSubMenu(selectMenuId);
		}		
	}
	
	function getSelectId(){
		return selectMenuId;
	}	
	
	function changeComp(){
		var param = new DataMap();
		param.put("COMPVID", $("#compList").val());
		var json = netUtil.sendData({
			url : "/common/json/rootCompChange.data",
			param : param
		});
		 
		if(json && json.data){
			this.location.reload();
			top.reloadLeft();
			//top.reloadTop();
		}else{
			//alert("회사변경실퍠");
		}
	}
	
	function changeMenu(){
		var param = new DataMap();
		param.put("MENUID", $("#menuList").val());
		var json = netUtil.sendData({
			url : "/common/json/rootMenuChange.data",
			param : param
		});
		 
		if(json && json.data){
			this.location.reload();
			top.reloadLeft();
		}else{
			//alert("메뉴변경실퍠");
		}
	}
</script>
</head>
<body style="min-width:1100px">
	<div class="bgDiv"></div>
	<div class="content_top2" >
		<div class="combos">
			<h1>
				<select id="compList" name="compList" Combo="ROOT,COMP_LIST" onchange="changeComp()">
				</select>
				<select id="menuList" name="menuList" Combo="ROOT,MENU_LIST" onchange="changeMenu()">
				</select>				
			</h1>
		</div>
		<ul id="subMenuList" class="topmenu_tab">

		</ul>
		<ul class="header_right">
			<li class="user_nm"><span><%if(("").equals(deptid) || deptid == null) { %> <%} else{ %> <%=deptid %> <%} %><%=username%></span> 님</li>
			<li class="logout" onClick="logout()"><a href="#">icon</a></li>
		</ul>		
	</div>
</body>
</html>