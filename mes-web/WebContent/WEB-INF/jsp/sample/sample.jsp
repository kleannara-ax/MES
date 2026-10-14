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
			editable : true,
			pkcol : "WAREKY,ZONEKY",
			pkcheck : false,
			module : "WmsAdmin",
			command : "ZONMA",
			//validation : "WAREKY,AREAKY,ZONEKY",
			validationType : "C",
			colorType : true,
			//defaultRowStatus : configData.GRID_ROW_STATE_INSERT,
			//colGroupCols : "WAREKY,AREAKY",
			totalShow : true,
			firstRowFocusType : false
	    });
		
		//화면에서 정의 되지 않은 컬럼을 로직에 사용해야 하는 경우
		gridList.appendCols("gridList", ["AAA","BBB"]);
		//var cols = ["AAA","BBB"];
		//gridList.appendCols("gridList", cols);
		
		gridList.setGrid({
	    	id : "gridSubList",
			editable : true,
			pkcol : "WAREKY,ZONEKY",
			module : "WmsAdmin",
			command : "ZONMAP",
			validation : "WAREKY,AREAKY,ZONEKY",
			validationType : "C",
			pageCount : 15
	    });
		
		netUtil.setForm("excelUp");
		
		$("#CTest").datepicker({
		      showButtonPanel: true,
		      dateFormat: site.COMMON_DATE_TYPE_UI 
	    });
		
		$("#CTest").datepicker(
			$.datepicker.regional[ "ko" ]
	    );
	});
	
	function closeVariant(obj){
		var closeVar = $(obj).parent().parent().attr('id');
		$('#'+closeVar).hide();
	}
	
	function gridPageLinkEventBefore(gridId, linkPage){
		//commonUtil.debugMsg("gridPageLinkEventBefore : ", arguments);
		if(gridId == "gridSubList"){
			var param = inputList.setRangeParam("searchArea");
			param.put("ZONETY", "STOR");
			return param;
		}		
	}
	
	function searchList(){
		//uiList.setActive("Search", false);
		//var param = dataBind.paramData("searchArea");
		/*inputList.removeValidation("NAME01", "required");
		inputList.addValidation("CREDAT1", "required,MASTER_M0434");
		inputList.addValidation("TEST", "required,MASTER_M0434");
		inputList.removeValidation("CREDAT2", "required");*/
		if(validate.check("searchArea")){
			//var param = inputList.setRangeParam("searchArea");
			var param = inputList.setRangeDataParam("searchArea");
			//inputList.appendRangeParam(param, "AREAKY", "TEST");

			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
			
			gridList.pageList("gridSubList", 1);
		}
		uiList.setActive("Wcancle", true);
	}
	
	function saveData(){
		if(gridList.validationCheck("gridList", "all")){
			var param = dataBind.paramData("searchArea");
			var json = gridList.gridSave({
		    	id : "gridList",
		    	param : param
		    });
			
			//alert(json);
			if(json && json.data){
				searchList();
			}
		}		
	}
	
	function createData(){
		alert(createData);
	}
	
	function gridListEventRowAddBefore(gridId, rowNum, beforeData){
		var zonetyt = inputList.getComboData("ZONETY", "STOR");
		var areakyt = inputList.getComboData("WmsAdmin_AREAKYCOMBO", "MMM");
		
		var newData = dataBind.paramData("searchArea");
		newData.put("ZONETY", "STOR");
		newData.put("ZONETYT", zonetyt);
		newData.put("AREAKY", "MMM");
		newData.put("AREAKYT", areakyt);
		
		return newData;
	}
	
	function gridListEventRowAddAfter(gridId, rowNum){
		if(gridId == "gridList"){
			//commonUtil.debugMsg("gridListEventRowAddAfter : ", arguments);
		}
	}
	
	function gridListEventRowCheck(gridId, rowNum, checkType){
		//commonUtil.debugMsg("gridListEventRowCheck : ", arguments);
	}
	
	function gridListEventRowCheckAll(gridId, checkType){
		//commonUtil.debugMsg("gridListEventRowCheckAll : ", arguments);
	}
	
	function gridListEventRowRemove(gridId, rowNum){
		//commonUtil.debugMsg("gridListEventRowRemove : ", arguments);
		return true;
	}
	
	function gridListEventRowClick(gridId, rowNum, colName){
		//commonUtil.debugMsg("gridListEventRowClick : ", arguments);
	}
	
	function gridListEventRowDblclick(gridId, rowNum, colName, colValue){
		commonUtil.debugMsg("gridListEventRowDblclick : ", arguments);
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		//commonUtil.debugMsg("gridListEventColValueChange : ", arguments);
		if(gridId == "gridList"){
			//uiList.setActive("Save", true);
		}
	}
	
	function gridListEventRowFocus(gridId, rowNum){
		//commonUtil.debugMsg("gridListEventRowFocus : ", arguments);
	}
	
	function gridListEventInputColFocus(gridId, rowNum, colName){
		//commonUtil.debugMsg("gridListEventInputColFocus : ", arguments);
	}
	
	function gridListEventDataBindEnd(gridId, dataLength, excelLoadType){
		//commonUtil.debugMsg("gridListEventDataBindEnd : ", arguments);
	}
	
	function gridListEventDataViewEnd(gridId, dataLength){
		//commonUtil.debugMsg("gridListEventDataViewEnd : ", arguments);
		if(gridId == "gridList"){
			//uiList.setActive("Search", true);
		}
	}
	
	function validationEventMsg(valObjType, objId, objIndex, objName, objValue, ruleText){
		//commonUtil.debugMsg("validationEventMsg : ", arguments);
		if(valObjType == configData.VALIDATION_OBJECT_TYPE_GRID){
			if(objId == "gridList" && objName == "WAREKY,ZONEKY" && valType == configData.VALIDATION_DUPLICATION){
				var param = new Array();
				param.push(objValue);
				return commonUtil.getMsg("MASTER_M0017", param);
			}
		}
	}
	
	function searchHelpEventOpenBefore(searchCode, gridType, $inputObj){
		//commonUtil.debugMsg("searchHelpEventOpenBefore : ", arguments);
		/*
		if(searchCode == "SHAREMA"){
			return dataBind.paramData("searchArea");
		}else if(searchCode == "SHWAHMA"){
			var param = new DataMap();
			param.put("WAREKY", "PMS0");
			return param;
		}
		*/
	}
	
	function searchHelpEventCloseAfter(searchCode, multyType, selectData, rowData){
		//commonUtil.debugMsg("searchHelpEventCloseAfter : ", arguments);
	}
	
	function gridListEventColBtnClick(gridId, rowNum, colName){
		//commonUtil.debugMsg("gridListEventColBtnClick : ", arguments);
	}
	
	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}else if(btnName == "Omcopy"){
			test19();
		}else if(btnName == "Execute"){
			//test15();
			gridList.resetGrid("gridList")
		}else if(btnName == "Pencil"){
			test();
		}else if(btnName == "Expand"){
			test1();
		}else if(btnName == "Reflect"){
			test6();
		}else if(btnName == "Check"){
			test17();
		}else if(btnName == "Print"){
			//showClipSave();
			test18();
		}else if(btnName == "Load"){
			excelLoad();
		}
	}
	
	function gridExcelDownloadEventBefore(gridId){
		//commonUtil.debugMsg("gridExcelDownloadEventBefore : ", arguments);
		var param = inputList.setRangeParam("searchArea");
		param.put("url", "/sample/WmsAdmin/excel/ZONMA.data");//공통 처리가 아닌경우 사용
		return param;
	}
	
	function commonShortKeyEvent(keyCode, keyCodeChar){
		//commonUtil.debugMsg("commonShortKeyEvent : ", arguments);
		/*
		if(keyCode == configData.COMMON_KEY_EVENT_SEARCH_CODE){
			searchList();
		}else if(keyCode == configData.COMMON_KEY_EVENT_SAVE_CODE){
			saveData();
		}
		*/
	}
	
	function gridListColTextColorChange(gridId, rowNum, colName, colValue){
		if(gridId == "gridList"){
			if(colName == "SHORTX"){
				if(colValue.indexOf("A") != -1){
					return configData.GRID_COLOR_TEXT_RED_CLASS;
				}
			}
		}
	}
	
	function gridListColBgColorChange(gridId, rowNum, colName, colValue){
		if(gridId == "gridList"){
			if(colName == "ZONEKY"){
				if(colValue.indexOf("A") != -1){
					return configData.GRID_COLOR_BG_YELLOW_CLASS;
				}
			}
		}
	}
	
	function gridListRowTextColorChange(gridId, rowNum){
		if(gridId == "gridList"){
			if(rowNum == 9){
				return configData.GRID_COLOR_TEXT_RED_CLASS;
			}
		}
	}
	
	function gridListRowBgColorChange(gridId, rowNum){
		if(gridId == "gridList"){
			if(rowNum == 10){
				return configData.GRID_COLOR_BG_YELLOW_CLASS;
			}
		}
	}
	
	function comboEventDataBindeBefore(comboAtt, $comboObj){
		//commonUtil.debugMsg("comboEventDataBindeBefore : ", arguments);
	}
	
	function excelLoad(){
		netUtil.sendForm("excelUp");
	}
	
	function netUtilEventSetFormSuccess(formId, data){
		//commonUtil.debugMsg("netUtilEventSetFormSuccess : ", arguments);
		var list = commonUtil.getAjaxUploadFileList(data);
		if(list.length > 0){
			var param = new DataMap();
			param.put("UUID", list[0]);
			//param.put(configData.DATA_EXCEL_COLNAME_ROWNUM, "1");
			
			netUtil.send({
				bindType : "grid",
				bindId : "gridList",
				sendType : "excelLoad",
				url : "/common/load/excel/json/grid.data",
		    	param : param
			});
		}
	}
	
	function gridListEventColFormat(gridId, rowNum, colName){
		//commonUtil.debugMsg("gridListEventColFormat : ", arguments);
	}	
	
	function inputListEventRangeDataChange(rangeName, singleData, rangeData){
		//commonUtil.debugMsg("inputListEventRangeDataChange : ", arguments);
	}
	
	/*
	function zonekyCheck(valueTxt, $colObj){
		var rowNum = gridList.getColObjRowNum("gridList", $colObj);
		var rowCount = gridList.getGridDataCount("gridList");
		for(var i=0;i<rowCount;i++){
			if(i != rowNum){
				var zoneky = gridList.getColData("gridList", i, "ZONEKY");
				if(zoneky == valueTxt){
					return false;
				}
			}			
		}
		
		return true;
	}
	*/
	function test(readonlyType){
		//alert(inputList.getDataCount("NAME01"));
		gridList.setBtnActive("gridList", configData.GRID_BTN_DELETE, false);
	}
	
	function test1(readonlyType){
		//gridList.removeUnselect("gridList");
		gridList.setBtnActive("gridList", configData.GRID_BTN_DELETE, true);
	}
	function test2(){
		gridList.checkAll("gridList", true);
	}
	function test3(){
		var singleList = inputList.getRangeData("AREAKY", configData.INPUT_RANGE_TYPE_SINGLE);
		alert(singleList);
		var rangeList = inputList.getRangeData("AREAKY", configData.INPUT_RANGE_TYPE_RANGE);
		alert(rangeList);
	}
	
	function test4(){
		var json = netUtil.sendData({
			url : "/IF/list/json/TEST.data"
		});
		alert(json);
	}
	
	function test5(){
		var json = netUtil.sendData({
			url : "/common/IF/list/json/TEST.data"
		});
		alert(json);
	}
	
	function test6(){
		//inputList.resetRange();
		inputList.resetRange("NAME01");
	}
	
	function test7(){
		gridList.addSort("gridList", "SHORTX", true, true);
	}
	
	function test8(){
		gridList.setRowReadOnly("gridList", 0);
	}
	
	function test9(){
		var cols = new Array();
		cols.push("ZONETY");
		
		gridList.setRowReadOnly("gridList", 1, cols);
	}
	
	function test10(){
		gridList.setRowReadOnly("gridList", 0, false);
	}
	
	function test11(){
		alert(JSON.stringify(Browser));
	}
	
	function test12(){
	//	alert(gridList.getGridData("gridList"));
		var	pop = $('.tabListPop')
		, closer = pop.find('.closer');

		pop.stop(true, true).fadeIn(150);
		closer.on({
			click : function() { 
				pop.stop(true, true).fadeOut(150);
			}
		});
	}
	
	function test13(){
		gridList.setBtnView("gridList", configData.GRID_BTN_ADD, false);
	}
	
	function test14(){
		gridList.setBtnView("gridList", configData.GRID_BTN_ADD, true);
	}
	
	function test15(){
		gridList.setColFocus("gridList", 0, "SHORTX");
	}
	
	function test16(){
		gridList.setColGrouping("gridList", 0);
	}
	
	function test17(){
		gridList.headColBg("gridList", "WAREKY", "gridHeadColRed");
	}
	function test18(){
		var data = page.getUserInfo();
		alert(data.AREA);
	}
	function test19(){
		var param = dataBind.paramData("searchArea");
		var json = netUtil.sendData({
			url : "/common/api/json/restfulRequest.data",
			param : param
		});
		alert(JSON.stringify(json));
	}
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY"></button>
		<button CB="Save SAVE STD_SAVE"></button>
		<button CB="Execute EXECUTE BTN_EXECUTE" CS="E"></button>
		<button CB="Omcopy ADD BTN_ADD"></button>
		<button CB="Pencil PENCIL BTN_PENCIL">
			Pencil Copy
		</button>
		<button CB="Expand EXPAND BTN_EXPAND">
			Expand
		</button>
		<button CB="Reflect REFLECT BTN_REFLECT"></button>
		<button CB="Check CHECK BTN_CLOSE"></button>
		<button CB="Print PRINT BTN_PRINT"></button>
		<button CB="Send SEND BTN_ERPSEND"></button>
		<button CB="Work WORK STD_PICKYN"></button>
		<button CB="Speak SPEAK BTN_PUTAWAY"></button>
		<button CB="File FILE BTN_CRFILE"></button>
		<button CB="Copy COPY BTN_OMCOPY"></button>
		<button CB="Up UP BTN_UPBTTN"></button>
		<button CB="Down DOWN BTN_DONBTN"></button>
		<button CB="Insfld INSFLD BTN_INSFLD,2"></button>
		<button CB="Cart CART BTN_CART">
			자동적재
		</button>
		<button CB="Allocate ALLOCATE BTN_ALLOCATE"></button>
		<button CB="Note NOTE BTN_MNGLINK"></button>
		<button CB="Create CREATE BTN_CREATE"></button>
		<button CB="Recall RECALL BTN_GETVARIANT"></button>
		<button CB="Saveas SAVEAS BTN_SAVEVARIANT"></button>
		<button CB="Delete DELETE BTN_DELETE"></button>
		<button CB="Wcancle WCANCLE BTN_CANCLE false"></button>
	</div>
	<div class="util3">
		<button class="button type2" id="showPop" type="button"><img src="/common/images/ico_btn4.png" alt="List" /></button>
	</div>
</div>

<!-- searchPop -->
<div class="searchPop" id="searchArea">
	<button type="button" class="closer">X</button>
	<div class="searchInnerContainer">
		<p class="util">
			<button CB="Create CREATE BTN_CREATE"></button>
			<button CB="Search SEARCH BTN_DISPLAY"></button>
			<button CB="GetVariant GETVARIANT BTN_GETVARIANT"></button>
			<button CB="SaveVariant SAVEVARIANT BTN_SAVEVARIANT"></button>
			<form action="/common/grid/excel/fileUp/excel.data" enctype="multipart/form-data" method="post" id="excelUp">
				<input type="file" name="file1" />
				<input type="submit" value="upload"/>
			</form>
			<button CB="Erp EXECUTE ERP"></button>
		</p>
		<div class="searchInBox">
			<h2 class="tit" CL="STD_SELECTOPTIONS"></h2>
			<table class="table type1">
				<colgroup>
					<col width="100" />
					<col />
				</colgroup>
				<tbody>
					<tr>
						<th CL="STD_WAREKY">거점</th>
						<td>
							<input type="text" id="WAREKY" name="WAREKY" UIInput="S,SHAREMA" validate="required,MASTER_M0434" value="<%=wareky%>" IAname="WAREKY"/>
						</td>
					</tr>
					<tr>
						<th>Combo</th>
						<td>
							<select name="AREAKY" Combo="WmsAdmin,AREAKYCOMBO" class="normalInput">
								<option value="">선택</option>
							</select>
						</td>
					</tr>
					 <tr>
						<th>SIZE TEST</th>
						<td>
							<input type="text" name="TEST" value="<%=compky%>" style="width:300px"/>
						</td>
					</tr> 
					<tr>
						<th CL="STD_AREAKY">구역 *</th>
						<td>
							<input type="text" name="NAME01" UIInput="R,SHWAHMA" IAname="WAREKY"/>
						</td>
					</tr>
					<tr>
						<th CL="STD_CREADAT">설명</th>
						<td>
							<input type="text" name="CREDAT" UIInput="R" UIFormat="C Y"/>
						</td>
					</tr>
					<tr>
						<th CL="STD_CREADAT">거점</th>
						<td>
							<input type="text" name="LMODAT" UIFormat="C Y" class="normalInput"/>
						</td>
					</tr>
					<tr>
						<th CL="STD_CREADAT">설명</th>
						<td>
							<input type="text" name="CREDAT1" UIInput="R" />
						</td>
					</tr>
					<tr>
						<th>Calender Test</th>
						<td>
							<input type="text" id="CTest" name="CREDAT2" class="normalInput"/>
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
			<div class="bottomSect type1">
				<div class="tabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span CL='STD_SEARCH'>탭메뉴1</span></a></li>
						<li><a href="#tabs1-2"><span CL='STD_SEARCH'>탭메뉴2</span></a></li>
						<li><a href="#tabs1-3"><span CL='STD_SEARCH'>탭메뉴3</span></a></li>
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
											<col width="40" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="150" />											
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<th GBtnCheck="true"></th>
												<th GBtnCheck="CHECKDATA">Check</th>
												<th>TMPNUM</th>
												<th CL='STD_WAREKY'>설명</th>
												<th CL='STD_ZONEKY'>설명</th>
												<th CL='STD_ZONETY'>설명</th>
												<th CL='STD_SHORTX,3'>설명</th>
												<th CL='STD_AREAKY'>창고</th>
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
											<col width="40" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<td GCol="rowCheck"></td>
												<td GCol="check,CHECKDATA,radio"></td>
												<td GCol="text,TMPNUM" GF="N 10"></td>
												<td GCol="text,WAREKY,center"></td>
												<td GCol="input,ZONEKY,SHWAHMA"></td>
												<td GCol="select,ZONETY" validate="required,INV_M0054">
													<select CommonCombo="ZONETY">
														<option value="">선택</option>
													</select>
												</td>
												<td GCol="input,SHORTX,SHWAHMA" validate="required,MASTER_M0434" GF="S 10" IAname="WAREKY"></td>
												<td GCol="select,AREAKY,WAREKY">
													<select Combo="WmsAdmin,AREAKYCOMBO">
														<option value="">선택</option>
													</select>
												</td>
												<td GCol="input,CREDAT" validate="required" GF="C"></td>
												<td GCol="input,CRETIM" validate="required" GF="T"></td>
												<td GCol="text,CREUSR"></td>
												<td GCol="add,LMODAT" GF="D"></td>
												<td GCol="input,LMOTIM" GF="N 6,3"></td>
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
									
									<!-- button class="button type4" type="button" GBtnFind="true" title="Find"><img src="/common/images/grid_icon_03.png" /></button>
									<button class="button type4" type="button" GBtnSortReset="true" title="SortReset"><img src="/common/images/ico_btn5.png" /></button>
									<button class="button type4" type="button" GBtnAdd="true" title="AddROw"><img src="/common/images/grid_icon_04.png" /></button>
									<button class="button type4" type="button" GBtnDelete="true" title="DeleteRow"><img src="/common/images/grid_icon_02.png" /></button>
									<button class="button type4" type="button" GBtnLayout="true" title="Layout"><img src="/common/images/grid_icon_07.png" /></button>
									<button class="button type4" type="button" GBtnTotal="true" title="Total"><img src="/common/images/grid_icon_08.png" /></button>
									<button class="button type4" type="button" GBtnExcel="true" title="ExcelDownload"><img src="/common/images/ico_btn9.png" /></button-->
								</div>
								<div class="rightArea">
									<p class="record" GInfoArea="true">17 Record</p>
								</div>
							</div>
						</div>
					</div>
					<div id="tabs1-2">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
											<col width="40" />
											<col width="40" />
											<col width="40" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="150" />											
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<th GBtnCheck="true"></th>
												<th>Check</th>
												<th CL='STD_WAREKY'>설명</th>
												<th CL='STD_ZONEKY'>설명</th>
												<th CL='STD_ZONETY'>설명</th>
												<th CL='STD_SHORTX,3'>설명</th>
												<th CL='STD_AREAKY'>창고</th>
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
											<col width="40" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
										</colgroup>
										<tbody id="gridSubList">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<td GCol="rowCheck"></td>
												<td GCol="check,CHECKDATA,radio"></td>
												<td GCol="text,WAREKY,center"></td>
												<td GCol="input,ZONEKY,SHWAHMA" validate="duplication"></td>
												<td GCol="select,ZONETY">
													<select CommonCombo="ZONETY">
														<option value="">선택</option>
													</select>
												</td>
												<td GCol="input,SHORTX,SHWAHMA" validate="required,MASTER_M0434" GF="S 10"></td>
												<td GCol="select,AREAKY">
													<select Combo="WmsAdmin,AREAKYCOMBO">
														<option value="">선택</option>
													</select>
												</td>
												<td GCol="input,CREDAT" validate="required" GF="C"></td>
												<td GCol="input,CRETIM" validate="required" GF="T"></td>
												<td GCol="text,CREUSR"></td>
												<td GCol="text,LMODAT" GF="D"></td>
												<td GCol="input,LMOTIM" validate="maxlength(8)" GF="N 8"></td>
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
									<button type="button" GBtn="delete"></button>
									<button type="button" GBtn="layout"></button>
									<button type="button" GBtn="total"></button>
									<button type="button" GBtn="excel"></button>
									<!-- button class="button type4" type="button" GBtnFind="true" title="Find"><img src="/common/images/grid_icon_03.png" /></button>
									<button class="button type4" type="button" GBtnSortReset="true" title="SortReset"><img src="/common/images/ico_btn5.png" /></button>
									<button class="button type4" type="button" GBtnAdd="true" title="AddROw"><img src="/common/images/grid_icon_04.png" /></button>
									<button class="button type4" type="button" GBtnDelete="true" title="DeleteRow"><img src="/common/images/grid_icon_02.png" /></button>
									<button class="button type4" type="button" GBtnLayout="true" title="Layout"><img src="/common/images/grid_icon_07.png" /></button>
									<button class="button type4" type="button" GBtnTotal="true" title="Total"><img src="/common/images/grid_icon_08.png" /></button>
									<button class="button type4" type="button" GBtnExcel="true" title="ExcelDownload"><img src="/common/images/ico_btn9.png" /></button-->
								</div>
								
								<div class="rightArea">
									<p class="record" GInfoArea="true">17 Record</p>
								</div>
							</div>
						</div>
					</div>
					<div id="tabs1-3">
						<div class="section type1">
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