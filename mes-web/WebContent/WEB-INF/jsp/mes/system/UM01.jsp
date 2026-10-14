<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript">
 	var menuky;
 	var oldTxt;
 	var flag = 0;
 	var searchType = 0;
 	/* var searchType = 1;      // 2016.10.17   메뉴수정일 경우 : 1 / 메뉴복사일 경우 : 2 */
 	var menukyInput = false; // 2016.10.17   메뉴 복사일 경우, 메뉴키입력 플래그
 	
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			editable : true,
			tree : "MENULV,LBLTXL,AMNUID,MENUID,SORTSQ",
			pkcol : "MENUKY,MENUID",
			module : "System",
			command : "MENU"
	    });
		
		/* $("#MENUKY2").blur(function(){
			if(searchType == 2 && !menukyInput){
				var menuky = $.trim($(this).val());
				if(!setMenuky(menuky)){
					return;
				}
			}
		}); */
	});
	
	function commonBtnClick(btnName){
		if(btnName == "Search" || btnName == "SearchG"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}else if(btnName == "Copy"){
			copyList();
		}else if(btnName == "Create"){
			createList();
		}
	}
	
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			
			/* menuky = param.get("MENUKY"); */
			
			gridList.resetGrid("gridList");
			searchType = 1;
			
		/* 	$("#foldSect").show();
			$("#foldSect2").hide();
			gridList.resetGrid("gridList");
			gridList.setReadOnly("gridList", false); */
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
			
			netUtil.send({
				module : "System",
				command : "MENUTOP",
				bindId : "menutop",
				sendType : "map",
				bindType : "field",
				param : param
			});
			
			uiList.setActive("Copy", false);
			uiList.setActive("SearchG", true); // 2016.10.17 복사일 경우 조회버튼 안보이도록 추가
		}
	}
	
	function copyList(){     //메뉴복사 버튼
		var list = gridList.getGridData("gridList");
		if(list.length > 0){
			if(!commonUtil.msgConfirm("메뉴 복사를 하시면 기존 작성한 데이터는 사라집니다.\n그래도 작업을 진행하시겠습니까?")){
				return;
			}
		}
		
		
		$("#COPYMENUKY").next().click();
		//$("#MENUTEXT").val("");
		
		/* if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			
			searchType = 2;
			
			$("#foldSect").hide();
			$("#foldSect2").show();
			gridList.resetGrid("gridList");
			gridList.setReadOnly("gridList", false);
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
			
			uiList.setActive("SearchG", false); // 2016.10.17 복사일 경우 조회버튼 안보이도록 추가
		}
	
		$("#COPYMENUKY").next().click();
		$("#MENUTEXT").val(""); */
		
	}
	
	function saveData(){
		//메뉴가 PRG일때 프로그램 ID 입력 체크
		if(gridList.getModifyRowCount('gridList') >0){
			var list = gridList.getModifyList('gridList');
			for(var i=0; i <list.length;i++){
				var tmpRow = list[i];
				var indmuk = $.trim(tmpRow.get("INDMUK"));
				var progid = $.trim(tmpRow.get("PROGID"));
				
				if(indmuk == "PRG" && progid == ""){
					commonUtil.msgBox("SYSTEM_M0006");   //프로그램ID를 입력하지 않았습니다.
					return;
				}
			}
		}
		if(gridList.validationCheck("gridList", "modify")){
			var param = dataBind.paramData("searchArea");
			
			var json;
			/*
			if(searchType == 1) { // 조회일 경우
				commonUtil.msgBox("시펄"); 
				json = gridList.gridSave({
			    	id : "gridList",
			    	param : param
			    });
			} else if(searchType == 2){ // 생성일 경우*/
				var list = gridList.getModifyData("gridList");
				if(list.length == 0){
					commonUtil.msgBox("IN_M0042");   //데이터가 존재하지 않습니다.
					return;
				}
				
				if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
					return;
				}
			
				param.put("menuTop", dataBind.paramData("menutop"));
				param.put("NEWMENUKY", $("[name=MENUKY]").val());
				param.put("SHORTX", $("[name=SHORTX]").val());
				param.put("list", list);
				
				json = netUtil.sendData({
					url : "/mes/system/json/UM01.data",
					param : param
				});
			//}

			if(json && json.data) {
				alert("저장되었습니다.");
				searchList();
			} else {
				alert("저장을 실패하였습니다.");
			}
			
		}
	}
	
	function gridListEventRowAddBefore(gridId, rowNum){
		var param = inputList.setRangeParam("searchArea");
		var MENUKY = param.get("MENUKY");
		var newData = new DataMap();
		newData.put("MENUKY", MENUKY);
		if(searchType == 2){
			if(gridList.getGridDataCount("gridList") == 0) {
				newData.put("AMNUID", "root");
				newData.put("MENULV", "1");
			}
			newData.put("LABLGR", "MENU");
		}
		
		return newData;
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId == "gridList"){
			if(colName == "AMNUID"){
				if(colValue != ""){
					var menulv = gridList.getColData(gridId, rowNum, "MENULV");
					
					if(((gridList.getGridDataCount("gridList") > 0 && searchType == 1)
					|| (gridList.getGridDataCount("gridList") > 1 && searchType == 2)) && Number(menulv) > 1){
						var menuChk = gridList.getGridBox('gridList').duplicationCheck(rowNum, "MENUID", colValue);
						
						if(menuChk){
							commonUtil.msgBox("SYSTEM_M0071", colValue);
							gridList.setColValue("gridList", rowNum, "AMNUID", "");
							gridList.setColFocus(gridId, rowNum, colName);
						}
					}
				}
			} else if(colName == "MENUID"){
				if(colValue != ""){
					if(gridList.getGridDataCount("gridList") > 0){
						var menuChk = gridList.getGridBox("gridList").duplicationCheck(rowNum, colName, colValue);
						
						if(!menuChk){
							commonUtil.msgBox("SYSTEM_M0070", colValue);
							gridList.setColValue("gridList", rowNum, "MENUID", "");
						}else{
							/*
							var param = new DataMap();
							param.put("MENUID",colValue );
							param.put("MENUKY", "DEV");
							
							var json = netUtil.sendData({
								module : "System",
								command : "UM01MENU",
								sendType : "map",
								param : param
							});
							
							if(json && json.data){
								gridList.setColValue("gridList", rowNum, "PROGID", json.data["PROGID"]); 
								gridList.setColValue("gridList", rowNum, "LABLKY", json.data["LABLKY"]); 
							} 
							*/
							gridList.setColValue("gridList", rowNum, "PROGID", colValue); 
							gridList.setColValue("gridList", rowNum, "LABLKY", colValue); 
						}
					}
				}
			} else if(colName == "LABLKY"){
				if(colValue != ""){
					var lablgr = gridList.getColData(gridId, rowNum, "LABLGR");
					
					var param = new DataMap();
					param.put("LABLKY", colValue);
					param.put("LABLGR", lablgr);
					
					var json = netUtil.sendData({
						module : "System",
						command : "UM01LABEL",
						sendType : "map",
						param : param
					});
					
					if(json && json.data){
						gridList.setColValue(gridId, rowNum, "LBLTXL", json.data["LBLTXL"]); 
					}else{
						gridList.setColValue(gridId, rowNum, "LABLKY", "");	
						gridList.setColValue(gridId, rowNum, "LBLTXL", "");	
					}
				}else{
					gridList.setColValue(gridId, rowNum, "LBLTXL", " ");	
				}
			} else if(colName == "PROGID"){
				if(colValue != ""){
					var param = new DataMap();
					param.put("PROGID", colValue);
					
					var json = netUtil.sendData({
						module : "System",
						command : "UM01PROG",
						sendType : "map",
						param : param
					});
					
					if(json && json.data){
						gridList.setColValue(gridId, rowNum, "PGPATH", json.data["PGPATH"]); 
					}else{
						gridList.setColValue(gridId, rowNum, "PROGID", "");
						gridList.setColValue(gridId, rowNum, "PGPATH", "");
					}
				}else{
					gridList.setColValue(gridId, rowNum, "PGPATH", " ");
				}
			}
		}
	}

 	function searchHelpEventOpenBefore(searchCode, gridType, $inputObj){
 		if(searchCode == "SHMENLB"){
			var param = new DataMap();
			param.put("LABLGR", "MENU");
			param.put("LANGKY", "<%=langky%>");
			return param;
		}else if(searchCode == "SHMNUDF"){
			if($inputObj.name == "MENUKY"){
				return dataBind.paramData("searchArea");
			} else if($inputObj.name == "COPYMENUKY"){
				var param = new DataMap();
				param.put("MENUKY", "");
				return param;
			}
			
		}
	}
 	
 	function fnTreePopAdd(type){
 		var rowNum = gridList.getFocusRowNum("gridList");
 		if(rowNum < 0) return;
 		
 		var rowData = new DataMap();
 		var indmuk = gridList.getColData("gridList", rowNum, "INDMUK");
 		
 		var menuid;
 		if($.trim(indmuk) == "FLD"){
 	 		menuid = gridList.getColData("gridList", rowNum, "MENUID");
 		}else{
 	 		menuid = gridList.getColData("gridList", rowNum, "AMNUID");
 		}
		rowData.put("AMNUID",menuid);
		
 		if(menuid && $.trim(menuid) != ""){
 	 		if(type == "FLD"){
 	 			page.linkPopOpen("/mes/system/UM01FLDPOP.page", rowData);
 	 		}else{
 	 			page.linkPopOpen("/mes/system/UM01PRGPOP.page", rowData);		
 	 		}
 		}else{
 			commonUtil.msgBox("MASTER_M0038");
 		} 
 	}
	
	function linkPopCloseEvent(data){
		var colValue = data.get("MENUID");
 		if(colValue && $.trim(colValue) != ""){
 			var menuChk = gridList.getGridBox('gridList').duplicationCheck("", "MENUID", colValue);
			
			if(!menuChk){
				commonUtil.msgBox("SYSTEM_M0070", colValue);
				gridList.setColValue("gridList", rowNum, "MENUID", "");
			}else{
				gridList.addNewRow("gridList");
		 		var rowNum = gridList.getFocusRowNum("gridList");
		 		if(rowNum < 0) return;
		
				gridList.setColValue("gridList", rowNum, "MENUID", colValue);
				gridList.setColValue("gridList", rowNum, "INDMUK", data.get("TYPE"));
			}	
 		}
	}
 	
	function gridListEventDataBindEnd(gridId, dataLength){
		if( gridId == "gridList" && dataLength > 0 ){
			oldTxt = $("#SHORTX").val();
		}
	}
	
	 // 2016.10.17   메뉴복사 추가
	/*function setMenuky(menukyVal){
		if(menukyVal == ""){
			commonUtil.msgBox("SYSTEM_M0089");
			menukyInput = false;
			$("#MENUKY2").val("").focus();
			return false;
		} else if(menukyVal != ""){
			var param = new DataMap();
			param.put("MENUKY", menukyVal);
			
			var json = netUtil.sendData({
				module : "System",
				command : "MNUDFCNT",
				sendType : "map",
				param : param
			});
			
			if(json && json.data){
				if(json.data["CNT"] > 0){
					commonUtil.msgBox("MASTER_M0051", menukyVal); // 메뉴 {0}는 이미 존재합니다. 다른 메뉴를 입력해 주세요.
					menukyInput = false;
					$("#MENUKY2").val("").focus();
					return false;
				} else {
					menuky = menukyVal;
					menukyInput = true;
					dataBind.dataNameBind(param, "searchArea");
					return true;
				}
			}
		}
	} */
	
	function createList(){        //생성버튼
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			
			var json = netUtil.sendData({
				module : "System",
				command : "MENUTOP",
				sendType : "map",
				param : param
			});
			
			if(json && json.data){
				commonUtil.msgBox("SYSTEM_M0070");    //이미 존재하는 메뉴 키 입니다.
				return;
			}
			
			gridList.resetGrid("gridList");
			
			searchType = 2;
			
			/* gridList.gridList({
		    	id : "gridList",
		    	//command : "MENUR",
		    	param : param
		    }); */
			
			netUtil.send({
				module : "System",
				command : "MENUR",
				bindId : "menutop",
				sendType : "map",
				bindType : "field",
				param : param
			});
			
			$("#SHORTX").val("");
			uiList.setActive("Copy", true);
			uiList.setActive("SearchG", true);
		    searchOpen(false);
		}
	}
	
	function searchHelpEventCloseAfter(searchCode, multyType, selectData, rowData){
 		if(searchCode == "SHMNUDF"){
 			if(searchType == 2){
 				getCopyList(selectData);
 			}
 		}
 	}
	
	function getCopyList(menuky){
		var param = new DataMap();
		param.put("MENUKY", menuky);
		
		gridList.resetGrid("gridList");
		
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
	}
	
</script>
</head>
<body>

<div class="contentHeader">
	<div class="util">
		<button CB="SearchG SEARCH BTN_DISPLAY"></button>
		<button CB="Save SAVE STD_SAVE"></button>
		<button CB="Copy COPY BTN_OMCOPY"></button>
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
			<button CB="Create CREATE BTN_CREATE"></button>
			<!-- <button CB="GetVariant GETVARIANT BTN_GETVARIANT"></button>
			<button CB="SaveVariant SAVEVARIANT BTN_SAVEVARIANT"></button> -->
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
						<td colspan="1">
							<input type="text" id="MENUTEXT" name="MENUKY" UIInput="S,SHMNUDF" validate="required,MASTER_M0434" />
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
						<table class="table type1" id="menutop">
							<colgroup>
								<col />
								<col />
								<col />
								<col />
							</colgroup>
							<tbody>
								<tr>
									<th CL="STD_MENUKY">메뉴키</th>
									<td>
										<input type="text" name="MENUKY" readOnly="readonly" validate="required" />
										<input type="hidden" name="COPYMENUKY" id="COPYMENUKY" UIInput="S,SHMNUDF" />
									</td>
								</tr>
								<tr>
									<th CL="STD_SHORTX">설명</th>
									<td><input type="text" name="SHORTX" id="SHORTX" /></td>
								</tr>
							</tbody>
						</table>
					</div>
				  </div>
				</div>
			</div>
			
			<!-- TOP FieldSet -->
	   <!-- <div class="foldSect" id="foldSect2">
				<div class="tabs">
				  <ul class="tab type2">
					<li><a href="#tabs-1"><span CL='STD_GENERAL'></span></a></li>
				  </ul>
				  <div id="tabs-1">
					<div class="section type1">
						<table class="table type1">
							<colgroup>
								<col />
								<col />
								<col />
								<col />
							</colgroup>
							<tbody>
								<tr>
									<th CL="STD_MENUKY">신규메뉴키</th>
									<td>
										<input type="text" name="MENUKY" readonly="readonly"/> id="MENUKY2" validate="required" 
										<input type="hidden" name="COPYMENUKY" id="COPYMENUKY" UIInput="S,SHMNUDF" />
									</td>
								</tr>
								<tr>
									<th CL="STD_SHORTX">설명</th>
									<td><input type="text" name="SHORTX" id="SHORTX2" /></td>
								</tr>
							</tbody>
						</table>
					</div>
				  </div>
				</div>
			</div> -->
			
			<!-- BOTTOM FieldSet -->
			<div class="bottomSect">
				<div class="tabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span CL='STD_MENU'>탭메뉴1</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
											<col width="40" />
											<col width="300" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
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
												<th CL="STD_NUMBER">번호</th>
												<th CL="STD_MENUTX">메뉴명</th>
												<th CL="STD_MENUKY">설명</th>
												<th CL="STD_AMNUID">번호</th>
												<th CL="STD_MENUID">설명</th>
												<th CL="STD_LBLTXL">설명</th>
												<th CL="STD_PGPATH">설명</th>
												<th CL="STD_INDMUK">창고</th>
												<th CL="STD_SORTSQ">생성일자</th>
												<th CL="STD_PROGID">생성시간</th>
												<th CL="STD_MENULV">생성자</th>
												<th CL="STD_LABLGR">수정일자</th>
												<th CL="STD_LABLKY">수정시간</th>
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="40" />
											<col width="300" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
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
												<td GCol="tree"></td>
												<td GCol="text,MENUKY" validate="required" ></td>
												<td GCol="input,AMNUID" validate="required" ></td>
												<td GCol="input,MENUID,SHMENLB" validate="required" ></td>
												<td GCol="text,LBLTXL"></td>
												<td GCol="text,PGPATH"></td>
												<td GCol="input,INDMUK" validate="required"></td>
												<td GCol="input,SORTSQ" validate="required" ></td>
												<td GCol="input,PROGID,SHPROGM"></td>
												<td GCol="text,MENULV"></td>
												<td GCol="text,LABLGR"></td>
												<td GCol="input,LABLKY" validate="required" ></td>
											</tr>
										</tbody>
									</table>
								</div>

							</div>
							<div class="tableUtil">
								<div class="leftArea">
									<button type="button" GBtn="find"></button>
									<button type="button" GBtn="up"></button>
									<button type="button" GBtn="down"></button>
									
									<!-- <button type="button" GBtn="folder" onclick="fnTreePopAdd('FLD')"><img src="/common/images/grid_icon_12.png" /></button>
									<button type="button" GBtn="prog"   onclick="fnTreePopAdd('PRG')"><img src="/common/images/grid_icon_15.png" /></button> -->
									
									<button type="button" GBtn="add"></button>
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
		</div>
		<!-- //contentContainer -->

	</div>
</div>
<!-- //content -->
		<%@ include file="/common/include/bottom.jsp" %>
</body>
</html>