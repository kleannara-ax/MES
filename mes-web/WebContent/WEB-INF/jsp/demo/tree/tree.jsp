<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/head.jsp" %>
<%@ include file="/common/include/tree.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		treeList.setTree({
	    	id : "treeList",
			module : "Demo",
			command : "MENUTREE",
			pkCol : "MENUID",
			pidCol : "AMNUID",
			nameCol : "LBLTXL",
			sortCol : "SORTSQ",
			bindArea : "treeDetail",
			cols : ["NODEKEY", "ID", "PID", "SORTSQ", "PROGID", "LABLGR", "LABLKY", "LBLTXL"],
			validation : {
				"PID" : "required",
				"SORTSQ" : "required",
				"LABLGR" : "required",
				"LABLKY" : "required",
				"LBLTXL" : "required"
			}
	    });
	});
	
	function searchList(){
		var param = inputList.setRangeParam("searchArea");
		treeList.treeList({
	    	id : "treeList",
	    	param : param
	    });
	}
	
	function saveData(){
		//var list = treeList.getData("treeList");
		var list = treeList.getModifyData("treeList");
		alert(list);
	}
	
	function addData(){
		treeList.addNewRow("treeList");
	}
	
	function removeData(){
		treeList.removeRow("treeList");
	}
	
	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}else if(btnName == "Add"){
			addData();
		}else if(btnName == "Remove"){
			removeData();
		}
	}
	
	function treeListEventDataBindEnd(treeId, dataCount){
		//commonUtil.debugMsg("treeListEventDataBindEnd : ", arguments);
		if(dataCount > 0){
			var rowData = treeList.getRowData("treeList", 0);
			alert(rowData);
		}
	}
</script>
</head>
<body>

<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY"></button>
		<button CB="Save SAVE STD_SAVE"></button>
		<button CB="Add ADD STD_ADD"></button>
		<button CB="Remove REMOVE STD_REMOVE"></button>
	</div>
	<div class="util2">
		<button class="button type2" id="showPop" type="button"><img src="/common/images/ico_btn4.png" alt="List" /></button>
	</div>
</div>

<!-- searchPop -->
<div class="searchPop" id="searchArea">

	<button type="button" class="closer">X</button>

	<div class="searchInnerContainer">
		<p class="util">
			<button CB="Search SEARCH BTN_DISPLAY"></button>
			<button CB="GetVariant GETVARIANT BTN_GETVARIANT"></button>
			<button CB="SaveVariant SAVEVARIANT BTN_SAVEVARIANT"></button>
		</p>

		<div class="searchInBox">
			<h2 class="tit" CL="STD_SELECTOPTIONS">검색조건</h2>
			<table class="table type1">
				<colgroup>
					<col width="100" />
					<col />
					<col width="100" />
					<col />
				</colgroup>
				<tbody>
					<tr>
						<th CL="STD_MENUKY">메뉴키</th>
						<td colspan="3">
							<input type="text" name="MENUKY" UIInput="S,SHMNUDF" validate="required,MASTER_M0434" />
						</td>
					</tr>
				</tbody>
			</table>
		</div>
	</div>

</div>
<!-- //searchPop -->

<!-- content -->
<div class="content">
	<div class="innerContainer">

		<!-- contentContainer -->
		<div class="contentContainer">

			<!-- TOP FieldSet -->
			<div class="foldSect">
				<div class="tabs">
				  <ul class="tab type2">
					<li><a href="#tabs-1"><span CL='STD_GENERAL'>탭메뉴1</span></a></li>
				  </ul>
				  <div id="tabs-1">
					<div class="section type1" id="treeDetail">
						<table class="table type1">
							<colgroup>
								<col />
								<col />
								<col />
								<col />
							</colgroup>
							<tbody>
								<tr>
									<th CL="STD_MENUID">메뉴아이디</th>
									<td>
										<input type="text" name="NODEKEY" readonly="readonly"/>
									</td>
								</tr>
								<tr>
									<th CL="STD_SHORTX">설명</th>
									<td>
										<input type="text" name="LBLTXL" />
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				  </div>
				</div>
			</div>
			
			<!-- BOTTOM FieldSet -->
			<div class="bottomSect">
				<button type="button" class="button type2"><img src="/common/images/ico_full.png" alt="Full Size"></button>
				<div class="tabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span CL='STD_MENU'>탭메뉴1</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<ul id="treeList"></ul>
						</div>						
					</div>
				</div>
			</div>
		</div>
		<!-- //contentContainer -->

	</div>
</div>
<!-- //content -->
		<%@ include file="/common/include/bottom.jsp" %>
</body>
</html>