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
					<tr>
						<th CL='STD_LOCAKY'></th>
						<td>
							<input type='text' name='LOCAKY' IAname='LOCAKY'  UIInput='S,SHLOCMA' />
						</td>
					</tr>
					<tr>
						<th CL='STD_LOCATY'></th>
						<td>
							<input type='text' name='LOCATY' IAname='LOCATY'  UIInput='S,SHLOCTYP' />
						</td>
					</tr>
					<tr>
						<th CL='STD_ZONEKY'></th>
						<td>
							<input type='text' name='ZONEKY' IAname='ZONEKY'  UIInput='R,SHZONMA' />
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
						<li><a href="#tabs1-1"><span CL='STD_SEARCH'></span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
											<col width='40' />
											<col width='40' />
											<col width='50' />
											<col width='120' />
											<col width='50' />
											<col width='200' />
											<col width='50' />
											<col width='100' />
											<col width='100' />
											<col width='180' />
											<col width='100' />
											<col width='100' />
											<col width='50' />
											<col width='50' />
											<col width='50' />
											<col width='100' />
											<col width='100' />
											<col width='50' />
											<col width='50' />
											<col width='180' />
											<col width='50' />
											<col width='50' />
											<col width='50' />
											<col width='50' />
											<col width='80' />
											<col width='60' />
											<col width='60' />
											<col width='60' />
											<col width='60' />
											<col width='50' />
											<col width='50' />
											<col width='50' />
											<col width='50' />
											<col width='50' />
											<col width='60' />
											<col width='50' />
											<col width='50' />
											<col width='50' />
											<col width='50' />
											<col width='100' />
											<col width='80' />
											<col width='100' />
											<col width='50' />
											<col width='100' />
											<col width='80' />
											<col width='100' />
											<col width='50' />
											<col width='50' />
											<col width='50' />
											<col width='50' />

										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'></th>
												<th GBtnCheck='true'></th>
												<th CL='STD_WAREKY'></th>
												<th CL='STD_LOCAKY'></th>
												<th CL='STD_LOCATY'></th>
												<th CL='STD_SHORTX'></th>
												<th CL='STD_TASKTY'></th>
												<th CL='STD_ZONEKY'></th>
												<th CL='STD_AREAKY'></th>
												<th CL='STD_LOCATYT'></th>
												<th CL='STD_TKZONE'></th>
												<th CL='STD_FACLTY'></th>
												<th CL='STD_ARLVLL'></th>
												<th CL='STD_INDCPC'></th>
												<th CL='STD_INDTUT'></th>
												<th CL='STD_IBROUT'></th>
												<th CL='STD_OBROUT'></th>
												<th CL='STD_RPROUT'></th>
												<th CL='STD_STATUS'></th>
												<th CL='STD_STATUST'></th>
												<th CL='STD_ABCANV'></th>
												<th CL='STD_LENGTH'></th>
												<th CL='STD_WIDTHW'></th>
												<th CL='STD_HEIGHT'></th>
												<th CL='STD_CUBICM'></th>
												<th CL='STD_MAXCPC'></th>
												<th CL='STD_MAXQTY'></th>
												<th CL='STD_MAXWGT'></th>
												<th CL='STD_MAXLDR'></th>
												<th CL='STD_MAXSEC'></th>
												<th CL='STD_MIXSKU'></th>
												<th CL='STD_MIXLOT'></th>
												<th CL='STD_RPNCAT'></th>
												<th CL='STD_INDQTC'></th>
												<th CL='STD_QTYCHK'></th>
												<th CL='STD_NEDSID'></th>
												<th CL='STD_INDUPA'></th>
												<th CL='STD_INDUPK'></th>
												<th CL='STD_AUTLOC'></th>
												<th CL='STD_CREDAT'></th>
												<th CL='STD_CRETIM'></th>
												<th CL='STD_CREUSR'></th>
												<th CL='STD_CUSRNM'></th>
												<th CL='STD_LMODAT'></th>
												<th CL='STD_LMOTIM'></th>
												<th CL='STD_LMOUSR'></th>
												<th CL='STD_LUSRNM'></th>
												<th CL='STD_INDBZL'></th>
												<th CL='STD_INDARC'></th>
												<th CL='STD_UPDCHK'></th>

											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width='40' />
											<col width='40' />
											<col width='50' />
											<col width='120' />
											<col width='50' />
											<col width='200' />
											<col width='50' />
											<col width='100' />
											<col width='100' />
											<col width='180' />
											<col width='100' />
											<col width='100' />
											<col width='50' />
											<col width='50' />
											<col width='50' />
											<col width='100' />
											<col width='100' />
											<col width='50' />
											<col width='50' />
											<col width='180' />
											<col width='50' />
											<col width='50' />
											<col width='50' />
											<col width='50' />
											<col width='80' />
											<col width='60' />
											<col width='60' />
											<col width='60' />
											<col width='60' />
											<col width='50' />
											<col width='50' />
											<col width='50' />
											<col width='50' />
											<col width='50' />
											<col width='60' />
											<col width='50' />
											<col width='50' />
											<col width='50' />
											<col width='50' />
											<col width='100' />
											<col width='80' />
											<col width='100' />
											<col width='50' />
											<col width='100' />
											<col width='80' />
											<col width='100' />
											<col width='50' />
											<col width='50' />
											<col width='50' />
											<col width='50' />

										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GCol='rownum'></td>
												<td GCol='rowCheck'></td>
												<td GCol='input,WAREKY,SHWAHMA'></td>
												<td GCol='input,LOCAKY,SHLOCMA'></td>
												<td GCol='input,LOCATY,SHLOCTYP'></td>
												<td GCol='text,SHORTX'></td>
												<td GCol='text,TASKTY'></td>
												<td GCol='input,ZONEKY,SHZONMA'></td>
												<td GCol='input,AREAKY,SHAREMA'></td>
												<td GCol='text,LOCATYT'></td>
												<td GCol='input,TKZONE,SHZONMA'></td>
												<td GCol='text,FACLTY'></td>
												<td GCol='text,ARLVLL'></td>
												<td GCol='check,INDCPC'></td>
												<td GCol='check,INDTUT'></td>
												<td GCol='text,IBROUT'></td>
												<td GCol='text,OBROUT'></td>
												<td GCol='text,RPROUT'></td>
												<td GCol='text,STATUS'></td>
												<td GCol='text,STATUST'></td>
												<td GCol='text,ABCANV'></td>
												<td GCol='text,LENGTH'></td>
												<td GCol='text,WIDTHW'></td>
												<td GCol='text,HEIGHT'></td>
												<td GCol='text,CUBICM'></td>
												<td GCol='text,MAXCPC'></td>
												<td GCol='text,MAXQTY'></td>
												<td GCol='text,MAXWGT'></td>
												<td GCol='text,MAXLDR'></td>
												<td GCol='text,MAXSEC'></td>
												<td GCol='check,MIXSKU'></td>
												<td GCol='check,MIXLOT'></td>
												<td GCol='text,RPNCAT'></td>
												<td GCol='check,INDQTC'></td>
												<td GCol='text,QTYCHK'></td>
												<td GCol='text,NEDSID'></td>
												<td GCol='text,INDUPA'></td>
												<td GCol='text,INDUPK'></td>
												<td GCol='text,AUTLOC'></td>
												<td GCol='text,CREDAT' GF='D'></td>
												<td GCol='text,CRETIM' GF='T'></td>
												<td GCol='text,CREUSR'></td>
												<td GCol='text,CUSRNM'></td>
												<td GCol='text,LMODAT' GF='D'></td>
												<td GCol='text,LMOTIM' GF='T'></td>
												<td GCol='text,LMOUSR'></td>
												<td GCol='text,LUSRNM'></td>
												<td GCol='text,INDBZL'></td>
												<td GCol='text,INDARC'></td>
												<td GCol='text,UPDCHK'></td>

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
