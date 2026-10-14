<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>TMS</title>
<%@ include file="/common/include/head.jsp"%>
<script type="text/javascript">
	var dblIdx = 0;
	$(document).ready(function() {
		setTopSize(300);
		gridList.setGrid({
			id : "gridList",
			editable : true,
			pkcol : "PKGKY,UNMIX",
			module : "TmsAdmin",
			command : "PKGTH",
			bindArea : "tabs1-2" 
		});
		
		gridList.setGrid({
	    	id : "gridListSub",
	    	name : "gridListSub",
			editable : true,
			pkcol : "PKGKY,UNMIX",
			module : "TmsAdmin",
			command : "PKGTI"
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

	function gridListEventDataBindEnd(gridId, dataLength){
		if(gridId == "gridList" && dataLength > 0){
			searchSubList(0);
		}
	}
		 
	function searchSubList(headRowNum){
		
		var rowVal = gridList.getColData("gridList", headRowNum, "PKGKY");
		
		var param = inputList.setRangeParam("searchArea");
		param.put("PKGKY", rowVal);
		
		gridList.gridList({
			id : "gridListSub",
			param : param
		});

		lastFocusNum = rowNum;
		dblIdx = rowNum;
	}
	
	var lastFocusNum = -1;
	
	function gridListEventItemGridSearch(gridId, rowNum, itemGridList){
		if(gridId == "gridList"){
			gridListEventRowDblclick(gridId, rowNum);
		}
	}

	 
	function gridListEventRowDblclick(gridId, rowNum){
		if(gridId == "gridList"){
			if(gridList.getColData("gridList", rowNum, "STATUS") == "C"){
				return false;
			}
			dblIdx = rowNum;
			
			searchSubList(rowNum);
		}
	}

	//그리드 위에 클릭시 아이템 리셋
	function gridListEventRowFocus(gridId, rowNum){
		if(gridId == "gridList"){
			var modRowCnt = gridList.getModifyRowCount("gridListSub");
			if(modRowCnt == 0){
				if(dblIdx != rowNum){
					gridList.resetGrid("gridListSub");
					dblIdx = -1;
				}
			//저장
			}else{
				if(commonUtil.msgConfirm("COMMON_M0462")){
				//if(confirm("값이 변화된 데이터가 있습니다. 이동하시겠습니까?")){
					gridList.resetGrid("gridListSub");
				}else{
					gridListEventRowFocus("gridList", dblIdx);
					return;
				}
			}
		}
	}
	 

	function gridListEventRowAddBefore(gridId, rowNum) {
		var newData = new DataMap();
		
		    newData.put("LODDIR1", false);
			newData.put("LODDIR2", false);
			newData.put("LODDIR3", false);
			newData.put("LODDIR4", false);
			newData.put("LODDIR5", false);
			newData.put("LODDIR6", false);
			newData.put("WHDMAR", "0");
			newData.put("HIGMAR", "0");
			newData.put("LNGMAR", "0");
		      
		   return newData;
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue, $inputObj){
		if(gridId == "gridList" && colName == "PKGKY"){
			if(colValue != ""){
				var param = new DataMap();
				param.put("PKGKY",colValue);
				var json = netUtil.sendData({
					module : "TmsAdmin",
					command : "PKGKYval",
					sendType : "map",
					param : param
				});
				if(json.data["CNT"] < 1) {
					var param = new DataMap();
					param.put("PKGKY",colValue);
					var json = netUtil.sendData({
						module : "TmsAdmin",
						command : "PKGKYnm",
						sendType : "map",
						param : param
					});
					if(json && json.data){
						gridList.setColValue("gridList", rowNum, "DESC01", json.data["DESC01"]); 
					} 
					checkValidationType = true;
				} else if (json.data["CNT"] > 0) {
					commonUtil.msgBox("TMS_T0010", colValue);
					gridList.setColValue("gridList", rowNum, "PKGKY", "");
					gridList.setColValue("gridList", rowNum, "DESC01", ""); 					
					checkValidationType = false;
				}			
			}else if(colValue==""){
				gridList.setColValue("gridList", rowNum, "DESC01", " ");
				checkValidationType = true;
			}
		}
		
	}
	 
	function saveData(){
		if(gridList.getModifyRowCount("gridList") == 0 && gridList.getModifyRowCount("gridListSub") == 0 ){
			//alert(commonUtil.getMsg("MASTER_M0545"));
			commonUtil.msgBox("MASTER_M0545");
			return;
		}
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		}
		if(gridList.validationCheck("gridList", "modify") && gridList.validationCheck("gridListSub", "modify")){
			
			var headNum = gridList.getGridDataCount("gridList") -1;
			
			/**
		    if(gridList.getRowStatus("gridList",headNum) == "C" && gridList.getGridDataCount("gridListSub") == 0){
						//alert(commonUtil.getMsg("OUT_M0045"));
				commonUtil.msgBox("OUT_M0045");//처리하기위한 데이터가 존재하지 않습니다.
				return;
			}**/
			
			var headCnt = gridList.getGridDataCount("gridList");
			for(var i = 0; i < headCnt; i++){
		    	gridList.setColValue("gridList", i, "STATUS", gridList.getRowStatus("gridList", i));
		    }
			var head = gridList.getGridData("gridList");
			
			var listCnt = gridList.getGridDataCount("gridListSub");
		    for(var i = 0; i < listCnt; i++){
		    	gridList.setColValue("gridListSub", i, "STATUS", gridList.getRowStatus("gridListSub", i));
		    }
			
			var list = gridList.getGridData("gridListSub");
			
			var param = new DataMap();
			
			param.put("head", head);
			param.put("list", list);
	
			//alert(param);
			var json = netUtil.sendData({
				url : "/tms/mst/json/saveMP01.data",
				param : param
			});
			
			//alert(commonUtil.getMsg(json.data));
			if(json){
				if(json.data){
					gridList.resetGrid("gridListSub");
					searchList();
				}
			}
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
</script>
</head>
<body>
	<div class="contentHeader">
		<div class="util">
			<button CB="Search SEARCH BTN_DISPLAY">
			</button>
			<button CB="Save SAVE STD_SAVE">
			</button>
		</div>
		<div class="util2">
			<button class="button type2" id="showPop" type="button">
				<img src="/common/images/ico_btn4.png" alt="List" />
			</button>
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
							<th CL="STD_COMPKY">회사</th>
							<td>
								<input type="text" name="COMPKY" value="<%=compky%>"  readonly="readonly" style="width:110px" />  <!-- UIInput="S,SHCOMMA"   -->
							</td>
						</tr>
						<tr>
							<th CL="STD_PKGKY">포장유형</th>
							<td><input type="text" name="PKGKY" UIInput="S,PKGKY" />
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
						<li><a href="#tabs1-1"><span CL='STD_SEARCH'>탭메뉴1</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
									  	    <col width="50" />
											<col width="100" />
											<col width="120" />
											<col width="90" />
											<col width="90" />
											<col width="90" />
											<col width="90" />
											<col width="90" />	
											<col width="90" />
											<col width="90" />	
											<col width="90" />	
											<col width="90" />	
										</colgroup>
										<thead>
											<tr>
											    <th CL='STD_NUMBER'></th>
												<th CL='STD_PKGKY'>포장유형</th>
												<th CL='STD_DESC05'></th>
												<th CL='STD_LODDIR1'>적재방향1</th>
												<th CL='STD_LODDIR2'>적재방향2</th>
												<th CL='STD_LODDIR3'>적재방향3</th>
												<th CL='STD_LODDIR4'>적재방향4</th>
												<th CL='STD_LODDIR5'>적재방향5</th>
												<th CL='STD_LODDIR6'>적재방향6</th>
												<th CL='STD_WHDMAR'>여유치(폭)</th>
												<th CL='STD_HIGMAR'>여유치(높이)</th>
												<th CL='STD_LNGMAR'>여유치(길이)</th>										
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
									  	    <col width="50" />
											<col width="100" />
											<col width="120" />
											<col width="90" />
											<col width="90" />
											<col width="90" />
											<col width="90" />
											<col width="90" />	
											<col width="90" />
											<col width="90" />	
											<col width="90" />	
											<col width="90" />											
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
											    <td GCol="rownum">1</td>
												<td GCol="input,PKGKY,PKGKY" GF="S 10"></td>
												<td GCol="text,DESC01"></td>							
												<td GCol="check,LODDIR1">적재방향1</td>
												<td GCol="check,LODDIR2">적재방향2</td>
												<td GCol="check,LODDIR3">적재방향3</td>
												<td GCol="check,LODDIR4">적재방향4</td>
												<td GCol="check,LODDIR5">적재방향5</td>
												<td GCol="check,LODDIR6">적재방향6</td>
												<td GCol="input,WHDMAR">여유치(폭)</td>
												<td GCol="input,HIGMAR">여유치(높이)</td>
												<td GCol="input,LNGMAR">여유치(길이)</td>																								
											</tr>									
										</tbody>
									</table>
								</div>

							</div>
							<div class="tableUtil">
								<div class="leftArea">	
									<button type="button" GBtn="find"></button>
									<button type="button" GBtn="sortReset"></button>
									<button type="button" GBtn="copy"></button>
									<button type="button" GBtn="add"></button>
									<button type="button" GBtn="delete"></button>									
									<button type="button" GBtn="layout"></button>									
									<button type="button" GBtn="excel"></button>
								</div>
								<div class="rightArea"><p class="record" GInfoArea="true"></p>
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
						<li><a href="#tabs1-2" CL="STD_ITEM"><span>아이템</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
											<col width="50" />
											<col width="100" />
								<!-- 			<col width="120" /> -->
											<col width="120" />
										</colgroup>
										<thead>
											<tr>
											    <th CL='STD_NUMBER'></th>
												<th CL='STD_PKGKY'></th>
<!-- 												<th CL='STD_DESC05'></th> -->
												<th CL='STD_UNMIX'>혼적불가 포장유형명</th>
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="50" />
											<col width="100" />
											<!-- <col width="120" /> -->
											<col width="120" />
										</colgroup>
										<tbody id="gridListSub">
											<tr CGRow="true">
											    <td GCol="rownum">1</td>
												<td GCol="input,PKGKY,PKGKY" validate="required" ></td>
												<!-- <td GCol="text,DESC01">	</td> -->
												<td GCol="input,UNMIX,PKGKY" validate="required" ></td>											
											</tr>									
										</tbody>
									</table>
								</div>

							</div>
							<div class="tableUtil">
								<div class="leftArea">			
									<button type="button" GBtn="find"></button>
									<button type="button" GBtn="sortReset"></button>
									<button type="button" GBtn="copy"></button>
									<button type="button" GBtn="add"></button>
									<button type="button" GBtn="delete"></button>
									<button type="button" GBtn="layout"></button>									
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