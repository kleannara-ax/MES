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
 	
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			editable : true,
			tree : "MENULV,LBLTXL,AMNUID,MENUID,SORTSQ",
			pkcol : "MENUKY,MENUID",
			module : "System",
			command : "MENU"
	    });
	});
	
	function searchList(){
		//var param = dataBind.paramData("searchArea");
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			menuky = param.get("MENUKY");
			
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
		}
	}
	
	function saveData(){
		/*
		//메뉴가 PRG일떄 프로그램 ID 입력 체크
		if(gridList.getModifyRowCount('gridList') >0){
			var list = gridList.getModifyList('gridList');
			for(var i=0; i <list.length;i++){
				var tmpRow = list[i];
				var indmuk = $.trim(tmpRow.get("INDMUK"));
				var progid = $.trim(tmpRow.get("PROGID"));
				
				if(indmuk == "PRG" && progid == ""){
					commonUtil.msgBox("SYSTEM_M0006");
					return;
				}
			}
		}*/
		var newTxt = $('#SHORTX').val();
		if(newTxt != oldTxt){
			flag = 1;
		}
		
		gridList.resetTreeSeq("gridList");
	
		if(flag == 1){
			var list = dataBind.paramData("foldSect");
			var param = new DataMap();
			
			param.put("list", list);
			
			var json = netUtil.sendData({
				url : "/wms/system/json/saveUM01.data",
				param : param
			});
		}			
		
		if(gridList.validationCheck("gridList", "modify")){
			var param = dataBind.paramData("searchArea");
			var json = gridList.gridSave({
		    	id : "gridList",
		    	param : param
		    });
			
			if(json && json.data){
				searchList();
			}	
		}
	}
	
	function gridListEventRowAddBefore(gridId, rowNum, beforeData){
		var param = inputList.setRangeParam("searchArea");
		
		beforeData.put("MENUKY", param.get("MENUKY"));
		
		return beforeData;
	}
	
	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}else if(btnName == "Execute"){
			test3();
		}
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId=="gridList" && colName=="AMNUID"){
			/*
			if(colValue != ""){
				if(gridList.getGridDataCount("gridList") > 0){
					
					var menuChk = gridList.getGridBox('gridList').duplicationCheck(rowNum, "MENUID", colValue);
					
					if(menuChk){
						commonUtil.msgBox("SYSTEM_M0071", colValue);
						gridList.setColValue("gridList", rowNum, "AMNUID", "");
					}else{
						var param = new DataMap();
						param.put("AMNUID", colValue);
						param.put("MENUKY", menuky);
						
						var json = netUtil.sendData({
							module : "System",
							command : "MNULV",
							sendType : "map",
							param : param
						});
						
						var mnulv = parseInt(json.data["MENULV"]);
						gridList.setColValue("gridList", rowNum, "MENULV", mnulv+1);
					}
				}
			}
			*/
		}else if(gridId=="gridList" && colName=="MENUID"){
			if(colValue != ""){
				if(gridList.getGridDataCount("gridList") > 0){
					
					var menuChk = gridList.getGridBox('gridList').duplicationCheck(rowNum, colName, colValue);
					
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
		}else if(gridId=="gridList" && colName=="LABLKY"){
			if(colValue != ""){
				var lablgr = gridList.getColData("gridList", rowNum, "LABLGR");
				var param = new DataMap();
				param.put("LABLKY",colValue);
				param.put("LABLGR",lablgr);
				
				var json = netUtil.sendData({
					module : "System",
					command : "UM01LABEL",
					sendType : "map",
					param : param
				});
				
				if(json && json.data){
					gridList.setColValue("gridList", rowNum, "LBLTXL", json.data["LBLTXL"]); 
				}else{
					gridList.setColValue("gridList", rowNum, "LABLKY", "");	
					gridList.setColValue("gridList", rowNum, "LBLTXL", "");	
				}
			}else{
				gridList.setColValue("gridList", rowNum, "LBLTXL", " ");	
			}
		}else if(gridId=="gridList" && colName=="PROGID"){
			if(colValue != ""){
				var param = new DataMap();
				param.put("PROGID",colValue);
				
				var json = netUtil.sendData({
					module : "System",
					command : "UM01PROG",
					sendType : "map",
					param : param
				});
				
				if(json && json.data){
					gridList.setColValue("gridList", rowNum, "PGPATH", json.data["PGPATH"]); 
				}else{
					gridList.setColValue("gridList", rowNum, "PROGID", "");
					gridList.setColValue("gridList", rowNum, "PGPATH", "");
				}
			}else{
				gridList.setColValue("gridList", rowNum, "PGPATH", " ");
			}
		}
	}

 	function searchHelpEventOpenBefore(searchCode, gridType){
 		
		if(searchCode == "SHMENLB"){
			var param = new DataMap();
			param.put("LABLGR", "MENU");
			param.put("LANGKY", "<%=langky%>");
			return param;
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
 	 			page.linkPopOpen("/wms/system/UM01FLDPOP.page", rowData);
 	 		}else{
 	 			page.linkPopOpen("/wms/system/UM01PRGPOP.page", rowData);		
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
			}	
 		}
	}
 	
	function gridListEventDataBindEnd(gridId, dataLength){
		if( gridId == "gridList" && dataLength > 0 ){
			oldTxt = $("#SHORTX").val();
		}
	}
</script>
</head>
<body>

<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY">
		</button>
		<button CB="Save SAVE STD_SAVE">
		</button>
<!-- 		<button CB="Copy COPY BTN_OMCOPY"> -->
<!-- 		</button> -->
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
										<input type="text" name="MENUKY" readonly="readonly"/>
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
			
			<!-- BOTTOM FieldSet -->
			<div class="bottomSect">
				<button type="button" class="button type2"><img src="/common/images/ico_full.png" alt="Full Size"></button>
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
												<th GBtnCheck="true"></th>
												<th CL="STD_MENUTX">메뉴명</th>
												<th CL="STD_MENUKY">설명</th>
												<th CL="STD_AMNUID">번호</th>
												<th CL="__MENU_MENUID">설명</th>
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
												<td GCol="rowCheck"></td>
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
									
									<button type="button" GBtn="folder" onclick="fnTreePopAdd('FLD')"><img src="/common/images/grid_icon_12.png" /></button>
									<button type="button" GBtn="prog"   onclick="fnTreePopAdd('PRG')"><img src="/common/images/grid_icon_15.png" /></button>
									
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