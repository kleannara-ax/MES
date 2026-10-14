<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<link rel="stylesheet" type="text/css" href="/common/theme/hwls/css/default.css">
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		var now = new Date();
		var fileName = uiList.dateFormat(now, "yyyymmdd");
		gridList.setGrid({
	    	id : "gridList",
			module : "Demo",
			command : "DEMOITEM",
			excelCsvType : true,
			excelTextDelimiter : " ",
			excelLabelView : false,
			excelFileName : fileName
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
		/*
		var json = netUtil.sendData({
			url : "/common/json/SQL_COLUMN_LIST.data"
		});
		return;
		*/
		//var list = gridList.getRowData("gridList", 0);
		//alert(list);
	/*
		var data = new DataMap();
		data.put("WAREKY","data1");
		
		gridList.appendList("gridList", [data,data,data]);
		return;
	*/
		if(gridList.validationCheck("gridList", "all")){
			var json = gridList.gridSave({
		    	id : "gridList",
		    	modifyType : 'A'
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
	
	function gridListEventDataBindEnd(gridId, dataLength, excelLoadType){
		//commonUtil.debugMsg("gridListEventDataBindEnd : ", arguments);
	}
	
	function gridListEventDataSortViewEnd(gridId){
		//commonUtil.debugMsg("gridListEventDataSortViewEnd : ", arguments);
	}
	function gridListEventDataViewEnd(gridId, dataLength){
		//commonUtil.debugMsg("gridListEventDataViewEnd : ", arguments);
		if(gridId == "gridList"){
			gridList.setReadOnly("gridList", true, ["LOCATY","STATUS","INDUPK"]);
			gridList.setRowReadOnly("gridList", 2, true);
			gridList.setRowReadOnly("gridList", 3, true, ["TKZONE"]);
		}
	}
	
	function gridListEventDataViewSetEnd(gridId){
		//commonUtil.debugMsg("gridListEventDataSortViewEnd : ", arguments);
		//alert($("#gridList").find("[gcolname=TKZONE]").eq(0).html());
	}
	
	function gridListRowBgColorChange(gridId, rowNum){
		if(gridId == "gridList"){
			if(gridList.getRowState(gridId, rowNum) == configData.GRID_ROW_STATE_UPDATE){
				return configData.GRID_COLOR_BG_YELLOW_CLASS;
			}
		}
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		//commonUtil.debugMsg("gridListEventColValueChange : ", arguments);
		if(gridId == "gridList"){
			//gridList.checkGridColor(gridId, rowNum);
			if(colName == "MAXCPC"){
				//gridList.setColValue(gridId, rowNum, colName, "0", false);
			}
		}
	}
	
	function gridListEventRowDblclick(gridId, rowNum, colName, colValue){
		commonUtil.debugMsg("gridListEventRowDblclick : ", arguments);
	}
	
	function test(){
		//gridList.setRowFocus("gridList", 90, true);
		//gridList.setColFocus("gridList", 90, "LOCAKY");
		//var list = gridList.getGridAvailData("gridList");
		//alert(list);
		//gridList.setRowReadOnly("gridList", 1, true);
		//gridList.setReadOnly("gridList", true, ["LOCATY"]);
		//gridList.setRowReadOnly("gridList", 2, true, ["TKZONE"]);
		
		gridList.setReadOnly("gridList", true, ["LOCATY","STATUS","INDUPK"]);
		gridList.setRowReadOnly("gridList", 2, true);
		gridList.setRowReadOnly("gridList", 3, true, ["TKZONE"]);		
		//gridList.setRowReadOnly("gridList", 4, true, ["TKZONE"]);
		//gridList.setRowReadOnly("gridList", 5, true, ["TKZONE"]);
		//gridList.setRowReadOnly("gridList", 6, true, ["TKZONE"]);
		//gridList.setRowReadOnly("gridList", 7, true, ["TKZONE"]);
		//gridList.setRowReadOnly("gridList", 8);
		
	}
	
	function test1(){
		//gridList.dataCheckAll("gridList", "INDUPA", true);
		//gridList.setColValue("gridList", 0, "INDUPA", "V");
		//gridList.setColValue("gridList", 0, "MAXCPC", 1000999.123);
		gridList.setRowReadOnly("gridList", 0, true, ["LOCAKY"]);
		gridList.setRowReadOnly("gridList", 0, true, ["TKZONE"]);
	}
	
	function test2(){
		var json = netUtil.sendData({
			url : "/common/json/sqlReload.data"
		});
	}
	
	function test3(){
		//gridList.setColValue("gridList", 0, "LOCATY", "90");
		var tmpList = gridList.getSelectRowNumList("gridList");
		alert(tmpList);
	}
	
	function getAreakyHtml(gridId, rowNum, colName, colValue){
		var txt = "";
		if(arguments){
			for(var i=0;i<arguments.length;i++){
				txt += " / "+arguments[i];
			}
		}	
		return "getAreakyHtml : "+txt;
	}
	
	function gridListRowBgColorChange(gridId, rowNum){
		if(gridId == "gridList"){
			if(rowNum == 10){
				return configData.GRID_COLOR_BG_YELLOW_CLASS;
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
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		//commonUtil.debugMsg("gridListEventColValueChange : ", arguments);
		if(gridId == "gridList"){
			//uiList.setActive("Save", true);
			if(colName == "CREDAT"){
				gridList.setColValue(gridId, rowNum, "CUSRNM", "TTT");
			}
		}
	}
	
	function gridListEventRowAddAfter(gridId, rowNum){
		if(gridId == "gridList"){
			//gridList.setRowReadOnly(gridId, rowNum, true);
		}
	}
	
	function gridListEventRowCopyAfter(gridId, rowNum){
		if(gridId == "gridList"){
			gridList.setRowReadOnly(gridId, rowNum, true);
		}
	}
</script>
</head>
<body>

<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY"></button>
		<button CB="Save SAVE STD_SAVE" class="saveBgColor"></button>
		<!--<button CB="Execute EXECUTE BTN_EXECUTE" CS="E"></button>-->
		<!--<button CB="Omcopy ADD 추가"></button>-->
		<!--<button CB="Pencil PENCIL 수정">
			Pencil Copy
		</button>-->
		<!--<button CB="Expand EXPAND 확장">
			Expand
		</button>-->
		<!--<button CB="Reflect REFLECT BTN_REFLECT"></button>-->
		<button CB="Check CHECK 확정"></button><!--BTN_CLOSE-->
		<!--<button CB="Print PRINT BTN_PRINT"></button>-->
		<!--<button CB="Send SEND ERP전송"></button>-->
		<!--<button CB="Work WORK STD_PICKYN"></button>-->
		<!--<button CB="Speak SPEAK BTN_PUTAWAY"></button>-->
		<!--<button CB="File FILE BTN_CRFILE"></button>-->
		<!--<button CB="Copy COPY BTN_OMCOPY"></button>-->
		<!--<button CB="Up UP BTN_UPBTTN"></button>-->
		<!--<button CB="Down DOWN BTN_DONBTN"></button>-->
		<!--<button CB="Insfld INSFLD BTN_INSFLD,2"></button>-->
		<button CB="Cart CART 재고실사지시서">
			자동적재
		</button>
		<!--<button CB="Allocate ALLOCATE BTN_ALLOCATE"></button>-->
		<!--<button CB="Note NOTE BTN_MNGLINK"></button>-->
		<!--<button CB="Create CREATE BTN_CREATE"></button>-->
		<button CB="Recall RECALL 실사차이리스트"></button><!--BTN_GETVARIENT-->
		<!--<button CB="Saveas SAVEAS BTN_SAVEVARIANT"></button>-->
		<!--<button CB="Delete DELETE BTN_DELETE"></button>-->
		<button CB="Wcancle WCANCLE BTN_CANCLE false"></button>
	</div>
	<div class="util3">
		<button class="button type2" id="showPop" type="button"><img src="/common/theme/hwls/images/content/ico_btn4.png" alt="List" /></button>
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
			<div class="bottomSect type1">
				<div class="tabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span CL='STD_SEARCH'>탭메뉴1</span></a></li>
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
												<td GH="80" GCol="fn,AREAKY,getAreakyHtml"></td>
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
												<td GH="80" GCol="input,MAXCPC" GF="N 5"></td>
												<td GH="80" GCol="input,WIDTHW" GF="N 7,3"></td>
												<td GH="80" GCol="input,HEIGHT" GF="N 20,3"></td>
												<td GH="80" GCol="check,MIXSKU"></td>
												<td GH="80" GCol="check,MIXLOT"></td>
												<td GH="80" GCol="input,CREDAT" GF="C"></td>
												<td GH="80" GCol="text,CRETIM" GF="T"></td>
												<td GH="80" GCol="btn,CREUSR" GB="Test EXECUTE GRID_COL_CREUSR_*"></td>
												<td GH="80" GCol="btn,CUSRNM" GB="Test EXECUTE GRID_COL_GC_VIEW_LOCAKY_*"></td>
											</tr>									
										</tbody>
									</table>
								</div>
							</div>							
							<!-- div class="tableUtil">
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
							</div-->
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