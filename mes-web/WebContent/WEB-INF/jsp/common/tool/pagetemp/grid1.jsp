<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid1</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			module : "#MODULE#",
			command : "#COMMAND#"
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
	
	function saveData(){
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
		}
	}
	
	function gridListEventRowAddBefore(gridId, rowNum, beforeData){
		//commonUtil.debugMsg("gridListEventRowAddBefore : ", arguments);
	}
	
	function gridListEventRowAddAfter(gridId, rowNum){
		//commonUtil.debugMsg("gridListEventRowAddAfter : ", arguments);
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
		//commonUtil.debugMsg("gridListEventRowDblclick : ", arguments);
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		//commonUtil.debugMsg("gridListEventColValueChange : ", arguments);
	}
	
	function gridListEventRowFocus(gridId, rowNum){
		//commonUtil.debugMsg("gridListEventRowFocus : ", arguments);
	}
	
	function gridListEventInputColFocus(gridId, rowNum, colName){
		//commonUtil.debugMsg("gridListEventInputColFocus : ", arguments);
	}
	
	function gridListEventDataBindEnd(gridId, dataLength){
		//commonUtil.debugMsg("gridListEventDataBindEnd : ", arguments);
	}
	
	function gridListEventDataViewEnd(gridId, dataLength){
		//commonUtil.debugMsg("gridListEventDataViewEnd : ", arguments);
	}
	
	function validationEventMsg(valObjType, objId, objIndex, objName, objValue, ruleText){
		//commonUtil.debugMsg("validationEventMsg : ", arguments);
	}
	
	function searchHelpEventOpenBefore(searchCode, gridType, $inputObj){
		//commonUtil.debugMsg("searchHelpEventOpenBefore : ", arguments);
	}
	
	function searchHelpEventCloseAfter(searchCode, multyType, selectData, rowData){
		//commonUtil.debugMsg("searchHelpEventCloseAfter : ", arguments);
	}
	
	function gridListEventColBtnClick(gridId, rowNum, colName){
		//commonUtil.debugMsg("gridListEventColBtnClick : ", arguments);
	}
	
	function gridExcelDownloadEventBefore(gridId){
		//commonUtil.debugMsg("gridExcelDownloadEventBefore : ", arguments);
	}
	
	function commonShortKeyEvent(keyCode, keyCodeChar){
		//commonUtil.debugMsg("commonShortKeyEvent : ", arguments);
	}
	
	function gridListColTextColorChange(gridId, rowNum, colName, colValue){
		//commonUtil.debugMsg("gridListColTextColorChange : ", arguments);
	}
	
	function gridListColBgColorChange(gridId, rowNum, colName, colValue){
		//commonUtil.debugMsg("gridListColBgColorChange : ", arguments);
	}
	
	function gridListRowTextColorChange(gridId, rowNum){
		//commonUtil.debugMsg("gridListRowTextColorChange : ", arguments);
	}
	
	function gridListRowBgColorChange(gridId, rowNum){
		//commonUtil.debugMsg("gridListRowBgColorChange : ", arguments);
	}
	
	function comboEventDataBindeBefore(comboAtt){
		//commonUtil.debugMsg("comboEventDataBindeBefore : ", arguments);
	}
	
	function netUtilEventSetFormSuccess(formId, data){
		//commonUtil.debugMsg("netUtilEventSetFormSuccess : ", arguments);
	}
	
	function gridListEventColFormat(gridId, rowNum, colName){
		//commonUtil.debugMsg("gridListEventColFormat : ", arguments);
	}	
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY"></button>
		<button CB="Save SAVE STD_SAVE"></button>
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
			<button CB="Search SEARCH BTN_DISPLAY"></button>
			<button CB="GetVariant GETVARIANT BTN_GETVARIANT"></button>
			<button CB="SaveVariant SAVEVARIANT BTN_SAVEVARIANT"></button>
		</p>
		<div class="searchInBox">
			<h2 class="tit" CL="STD_SELECTOPTIONS"></h2>
			<table class="table type1">
				<colgroup>
					<col width="100" />
					<col />
				</colgroup>
				<tbody>
					#SEARCH#
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
						<li><a href="#tabs1-1"><span CL='STD_SEARCH'></span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
											#COLS#
										</colgroup>
										<thead>
											<tr>
												#HEAD#
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											#COLS#
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												#ROWS#
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