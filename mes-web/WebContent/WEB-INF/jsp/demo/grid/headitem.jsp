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
		gridList.setGrid({
	    	id : "gridList",
			module : "Demo",
			command : "DEMOHEAD",
			itemGrid : "gridListItem",
			itemSearch : true
	    });
		gridList.setGrid({
	    	id : "gridListItem",
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
	
	function gridListEventItemGridSearch(gridId, rowNum, itemGridList){
		if(gridId == "gridList"){
			var rowData = gridList.getRowData(gridId, rowNum);
			var param = inputList.setRangeParam("searchArea");
			param.putAll(rowData);
			
			gridList.gridList({
		    	id : "gridListItem",
		    	param : param
		    });
		}
	}
	
	function saveData(){
		alert(gridList.getItemGridViewCheck("gridList"));
		return;
		if(gridList.validationCheck("gridList", "all")){
			var json = gridList.gridSave({
		    	id : "gridList"
		    });
		}
	}
	
	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}else if(btnName == "Test"){
			test();
		}else if(btnName == "Test1"){
			test1();
		}
	}
	
	function test(){
		//gridList.setHeadText("gridList", "SHORTX", "Test");
		gridList.setRowReadOnly("gridListItem", 1, true, ["ZONEKY","AREAKY"]);
	}
	
	function test1(){
		//gridList.setHeadText("gridList", "SHORTX", "Test");
		gridList.setRowReadOnly("gridListItem", 1, false);
	}
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY"></button>
		<button CB="Save SAVE STD_SAVE"></button>
		<button CB="Test WORK STD_TEST"></button>
		<button CB="Test1 WORK STD_TEST"></button>
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
				</colgroup>
				<tbody>
					<tr>
						<th CL="STD_WAREKY">거점</th>
						<td>
							<input type="text" name="WAREKY" UIInput="S,SHWAHMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_AREAKY">창고</th>
						<td>
							<input type="text" name="AREAKY" UIInput="R,SHAREMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_ZONEKY">Zone Code</th>
						<td>
							<input type="text" name="ZONEKY" UIInput="R,SHZONMA" />
						</td>
					</tr>
					<tr>
						<th>Multiple combo</th>
						<td>
							<select name="MULTICOMBO" Combo="WmsAdmin,AREAKYCOMBO" ComboType="MC,50">
						    </select>
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

			<div class="bottomSect top">
				<button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button>
				<div class="tabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span CL="STD_GENERAL"></span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
											<col width="40" />
											<col width="40" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />											
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<th GBtnCheck="true"></th>
												<th CL='STD_WAREKY'>거점</th>
												<th CL='STD_AREAKY'>창고</th>
												<th CL='STD_ZONEKY'>구역</th>
												<th CL='STD_ZONETY'>구역타입</th>
												<th CL='STD_SHORTX'>설명</th>
												<th CL='STD_CREDAT'>생성일자</th>
												<th CL='STD_CRETIM'>생성시간</th>
												<th CL='STD_CREUSR'>생성자</th>
												<th CL='STD_LMODAT'>수정일자</th>
												<th CL='STD_LMOTIM'>수정시간</th>
												<th CL='STD_LMOUSR'>수정자</th>
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="40" />
											<col width="40" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />											
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<td GCol="rowCheck"></td>
												<td GCol="text,WAREKY"></td>
												<td GCol="input,AREAKY,SHAREMA,true" GF="S 10" validate="required,MASTER_M0254"></td>
												<td GCol="input,ZONEKY,SHZONMA" validate="required" ></td>
												<td GCol="select,ZONETY" validate="required">
													<select CommonCombo="ZONETY">
														<option value=" "></option>
													</select>
												</td>
												<td GCol="input,SHORTX" GF="S 180"></td> 
												<td GCol="text,CREDAT"></td>
												<td GCol="text,CRETIM"></td>
												<td GCol="text,CREUSR"></td>
												<td GCol="text,LMODAT" GF="D"></td>
												<td GCol="text,LMOTIM" GF="T"></td>
												<td GCol="text,LMOUSR"></td>
											</tr>									
										</tbody>
									</table>
								</div>
							</div>
							<div class="tableUtil">
								<div class="leftArea">
									<button type="button" GBtn="find"></button>
									<button type="button" GBtn="sortReset"></button>
									<button type="button" GBtn="add"></button>
									<button type="button" GBtn="copy"></button>
									<button type="button" GBtn="delete"></button>
									<button type="button" GBtn="layout"></button>
									<button type="button" GBtn="total"></button>
									<button type="button" GBtn="excel"></button>
								</div>
								<div class="rightArea">
									<p class="record" GInfoArea="true"></p>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>

			<div class="bottomSect bottom">
				<button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button>
				<div class="tabs">
					<ul class="tab type2" id="commonMiddleArea">
						<li><a href="#tabs1-1"><span CL='STD_SEARCH'></span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
											<col width="40" />
											<col width="40" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="100" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'></th>
												<th GBtnCheck="true"></th>
												<th CL='STD_WAREKY'></th>
												<th CL='STD_AREAKY'></th>
												<th CL='STD_ZONEKY'></th>
												<th CL='STD_LOCAKY'></th>
												<th CL='STD_TKZONE'></th>
												<th CL='STD_LOCATY'></th>
												<th CL='STD_STATUS'></th>
												<th CL='STD_INDUPA'></th>
												<th CL='STD_INDUPK'></th>
												<th CL='STD_INDCPC'></th>
												<th CL='STD_MAXCPC'></th>
												<th CL='STD_WIDTHW'></th>
												<th CL='STD_HEIGHT'></th>
												<th CL='STD_MIXSKU'></th>
												<th CL='STD_MIXLOT'></th>
												<th CL='STD_CREDAT'></th>
												<th CL='STD_CRETIM'></th>
												<th CL='STD_CREUSR'></th>
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="40" />
											<col width="40" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="100" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
										</colgroup>
										<tbody id="gridListItem">
											<tr CGRow="true">
												<td GCol="rownum"></td>
												<td GCol="rowCheck"></td>
												<td GCol="text,WAREKY"></td>
												<td GCol="add,AREAKY"></td>
												<td GCol="input,ZONEKY,SHZONMA" GF="S 10"></td> 
												<td GCol="input,LOCAKY" validate="required,HHT_T0032" GF="S 20"></td>
												<td GCol="input,TKZONE,SHZONMA" GF="S 10"></td>
												<td GCol="select,LOCATY">
													<select CommonCombo="LOCATY">
													</select>
												</td>
												<td GCol="select,STATUS">
													<select CommonCombo="STATUS">
													</select>
												</td>
												<td GCol="check,INDUPA"></td>
												<td GCol="check,INDUPK"></td>
												<td GCol="check,INDCPC"></td>
												<td GCol="input,MAXCPC" GF="N 20,3"></td>
												<td GCol="input,WIDTHW" GF="N 20,3"></td>
												<td GCol="input,HEIGHT" GF="N 20,3"></td>
												<td GCol="check,MIXSKU"></td>
												<td GCol="check,MIXLOT"></td>
												<td GCol="input,CREDAT" GF="C"></td>
												<td GCol="text,CRETIM"></td>
												<td GCol="text,CREUSR"></td>
											</tr>									
										</tbody>
									</table>
								</div>
							</div>
							<div class="tableUtil">
								<div class="leftArea">
									<button type="button" GBtn="find"></button>
									<button type="button" GBtn="filter"></button>
									<button type="button" GBtn="sortReset"></button>
									<button type="button" GBtn="add"></button>
									<button type="button" GBtn="copy"></button>
									<button type="button" GBtn="delete"></button>
									<button type="button" GBtn="layout"></button>
									<button type="button" GBtn="total"></button>
									<button type="button" GBtn="subTotal"></button>
									<button type="button" GBtn="excel"></button>
									<button type="button" GBtn="excelUpload"></button>
									<button type="button" GBtn="colFix"></button>									
								</div>
								<div class="rightArea">
									<p class="record" GInfoArea="true">0 Record</p>
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