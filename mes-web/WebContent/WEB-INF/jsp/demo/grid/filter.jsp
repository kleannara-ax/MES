<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		setTopSize(150);
	 	gridList.setGrid({
	 		id : "gridList",
			module : "Demo",
			command : "DEMOITEM"
	    }); 
	});
	
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");

			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}	
	
	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Filter"){
			filterGrid();
		}else if(btnName == "FilterMap"){
			filterGridMap();
		}else if(btnName == "Reset"){
			filterReset();
		}
	}
	
	function filterGrid(){
		gridList.filterGridData("gridList", "LOCAKY", $("#filter").val());
	}
	
	function filterGridMap(){
		var tmpVal1 = $("#filter1").val();
		var tmpVal2 = $("#filter2").val();
		var dataMap = new DataMap();
		dataMap.put("LOCAKY",tmpVal1);
		dataMap.put("TKZONE",tmpVal2);
		gridList.filterGridDataMap("gridList", dataMap);
	}
	
	function filterReset(){
		gridList.filterGridClear("gridList");
		$("#filter").val("");
	}
</script>
</head>
<body>

<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY"></button>
		
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
						<th CL="STD_WAREKY"></th>
						<td>
							<input class="requiredInput" type="text" id="WAREKY" name="WAREKY" UIInput="S,SHAREMA" IAname="WAREKY"/>
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
			<div class="foldSect" id="foldSect">
				<div class="tabs">
				  <ul class="tab type2">
					<li><a href="#tabs-1"><span CL='STD_GENERAL'>탭메뉴1</span></a></li>
				  </ul>
				  <div id="tabs-1">
					<div class="section type1">
						<table class="table type1" id="yh01top">
							<colgroup>
								<col />
								<col />
							</colgroup>
							<tbody>
								<tr>
									<th CL="STD_LOCAKY"></th>
									<td>
										<input type="text" id="filter" onkeypress="commonUtil.enterKeyCheck(event, 'filterGrid()')"/>
										<button CB="Filter SEARCH BTN_FILTER"></button>
										<button CB="Reset EXECUTE BTN_RESET"></button>
									</td>
								</tr>
								<tr>
									<th CL="STD_FILTER"></th>
									<td>
										<input type="text" id="filter1" onkeypress="commonUtil.enterKeyCheck(event, 'filterGridMap()')"/>
										<input type="text" id="filter2" onkeypress="commonUtil.enterKeyCheck(event, 'filterGridMap()')"/>
										<button CB="FilterMap SEARCH BTN_FILTER"></button>
										<button CB="Reset EXECUTE BTN_RESET"></button>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				  </div>
				</div>
			</div>
			
			<!-- BOTTOM FieldSet -->
			<div class="bottomSect" style="top:150px;">
				<button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button>
				<div class="tabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span CL='STD_ITEM'>탭메뉴1</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableBody">
									<table>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GH="40" GCol="rownum">1</td>
												<td GH="40" GCol="rowCheck"></td>
												<td GH="80" GCol="text,WAREKY"></td>
												<!-- td GCol="text,AREAKY"></td-->
												<td GH="80" GCol="text,AREAKY"></td>
												<td GH="80" GCol="add,ZONEKY,SHZONMA" GF="U 10" validate="required"></td> 
												<td GH="80" GCol="input,LOCAKY" validate="required" GF="S 20" class="requiredInput"></td>
												<td GH="80" GCol="input,TKZONE,SHZONMA,true" GF="S 10"></td>
												<td GH="80" GCol="select,LOCATY" class="requiredInput">
													<select CommonCombo="LOCATY">
													</select>
												</td>
												<td GH="80" GCol="select,STATUS">
													<select CommonCombo="STATUS">
													</select>
												</td>
												<td GH="80" GCol="check,INDUPA" class="requiredInput"></td>
												<td GH="80" GCol="check,INDUPK"></td>
												<td GH="80" GCol="check,INDCPC"></td>
												<td GH="80" GCol="input,MAXCPC" GF="N 20,3"></td>
												<td GH="80" GCol="input,WIDTHW" GF="N 20,3"></td>
												<td GH="80" GCol="input,HEIGHT" GF="N 20,3"></td>
												<td GH="80" GCol="check,MIXSKU"></td>
												<td GH="80" GCol="check,MIXLOT"></td>
												<td GH="80" GCol="input,CREDAT" GF="C"></td>
												<td GH="80" GCol="text,CRETIM" GF="T"></td>
												<td GH="80" GCol="text,CREUSR"></td>
												<td GH="80" GCol="file,CUSRNM"></td>
											</tr>									
										</tbody>
									</table>
								</div>
							</div>							
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