<%@ page language="java" contentType="text/html; charset=UTF-8" 
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>TMS</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript">
	var dblIdx = 0;
	
	$(document).ready(function(){
		setTopSize(250);
		gridList.setGrid({
	    	id : "gridList",
			editable : true,
			pkcol : "WAREKY",
			module : "TmsAdmin",
			command : "WAHMA" //, itemGrid : "gridListItem"
	    });
	    
		gridList.setGrid({
	    	id : "gridListSub",
			editable : true,
			pkcol : "WAREKY,SHPTKY",
			module : "TmsAdmin",
			command : "PLTMD",
			emptyMsgType:false
	    });

	});
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if(gridId == "gridList" && dataLength > 0){
			searchSubList(0);
		}
	}	
	
	function searchList(){ 
		var wareky='<%=wareky%>';
		if(validate.check("searchArea")){ 
			var param = inputList.setRangeParam("searchArea"); 
			if(typeof(param.get("WAREKY")) == 'undefined' && wareky != ''){
				param.put("WAREKY",wareky);
			} 
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}
	 
	function searchSubList(headRowNum){
		var rowVal = gridList.getColData("gridList", headRowNum, "WAREKY");
	  //alert(rowVal);
		
		var param = inputList.setRangeParam("searchArea");
		param.put("WAREKY", rowVal);
		
		gridList.gridList({
			id : "gridListSub",
			param : param
		});

		lastFocusNum = rowNum;//headRowNum
		dblIdx = rowNum;//headRowNum
	}
	var lastFocusNum = -1;
	
	/**/
	function gridListEventItemGridSearch(gridId, rowNum, itemGridList){
		if(gridId == "gridList"){
			
			
			var param = gridList.getRowData(gridId, rowNum);
			
			gridList.gridList({
		    	id : "gridListSub",
		    	param : param
		    });
			gridListEventRowDblclick(gridId, rowNum);
		}
	}
	/**/
	 
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
	 
 	//function gridListEventRowAddBefore(gridId, rowNum){ 
	//	var newData = new DataMap();
	//	newData.put("COMPKY",  "<%=compky%>");
	//	newData.put("WAREKY", "<%=wareky%>");  
	//	return newData;
	//} 


	function gridListEventRowAddBefore(gridId, rowNum) {
		//var wareky_s = document.getElementById("wareky_s");
		//wareky_s = val.set("2000");
		alert("ddd"+wareky_s);
		if(gridId == "gridList"){
			var headCnt = gridList.getModifyRowCount("gridList");
			var listCnt = gridList.getModifyRowCount("gridListSub");
			if(listCnt > 0 || headCnt > 0){
				//alert("변경된 row를 저장 후 행추가 하십시요.");
				//commonUtil.msgBox("MASTER_M0686");
				return false;
			}else{
				var newData = new DataMap();
				newData.put("STATUS", "C");
				newData.put("COMPKY",  "<%=compky%>");
				return newData;
			}
		}else if(gridId == "gridListSub"){
			if(dblIdx == -1){
				var headNum = gridList.getGridDataCount("gridList") -1;
				
				if(gridList.getColData("gridList", headNum, "STATUS") == ""){
					//alert(commonUtil.getMsg("MASTER_M0577"));
					//commonUtil.msgBox("MASTER_M0577");
					return false;
				}
	
				if(gridList.getColData("gridList", headNum, "STATUS") == "C"){
					var wareky = gridList.getColData("gridList", headNum, "WAREKY");

					if(wareky != ""){
						var newData = new DataMap();
						newData.put("WAREKY",wareky);
					
						return newData;
					}else{
						//alert(commonUtil.getMsg("MASTER_M0128"));
						commonUtil.msgBox("MASTER_M0128");
						return false;
					}
				}else{
					//alert(commonUtil.getMsg("TASK_M0003"));
					commonUtil.msgBox("TASK_M0003");
					return false;
				}
			}else{
				
				var wareky = gridList.getColData("gridList", dblIdx, "WAREKY");
	
				var newData = new DataMap();
				newData.put("WAREKY",wareky);
				
				return newData;
			}
		}
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId == "gridList" && colName == "WAREKY"){
			if(colValue != ""){
				var wareky = gridList.getColData("gridList", rowNum, "WAREKY");
				
				var param = new DataMap();
				param.put("WAREKY",colValue);
				
				var json = netUtil.sendData({
					module : "TmsAdmin",
					command : "MW01WAREKYval",
					sendType : "map",
					param : param
				});
				
				if(json.data["CNT"] >= 1) {
					gridList.setColValue("gridList", rowNum, "WAREKY", ""); 
			      //commonUtil.msgBox("MASTER_M0129",colValue);
					commonUtil.msgBox("COMMON_M0006",colValue);
					return false;
				}
			}
			if(gridList.getGridDataCount("gridListSub") > 0){
				var listCnt = gridList.getGridDataCount("gridList");
				if(listCnt != 0){
					for(var i = 0; i < listCnt; i++){
						gridList.setColValue("gridListSub", i, "WAREKY", colValue);
					}
				}
			}
		}else if(gridId == "gridListSub" && colName == "SHPTKY"){
			if(colValue != ""){
				var wareky = gridList.getColData("gridListSub", rowNum, "WAREKY");
				
				var param = new DataMap();
				param.put("WAREKY",wareky);
				param.put("SHPTKY",colValue);
				
				var json = netUtil.sendData({
					module : "TmsAdmin",
					command : "MW01SHPTKYval",
					sendType : "map",
					param : param
				});
				
				if(json.data["CNT"] >= 1) {
					gridList.setColValue("gridListSub", rowNum, "SHPTKY", "");
					//alert(commonUtil.getMsg("MASTER_M0318"));
					//commonUtil.msgBox("MASTER_M0318");
					commonUtil.msgBox("COMMON_M0006"); 
					return false;
				}
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
				url : "/wms/admin/json/saveMW01.data",
				param : param
			}); 

			/**
			gridList.setGrid({
		    	id : "gridList",
				editable : true,
				pkcol : "WAREKY",
				module : "TmsAdmin",
				command : "saveMW01" //, itemGrid : "gridListItem"
		    });
			
			var json = gridList.gridSave({
		    	id : "gridList",
				module : "TmsAdmin",
		    	command:"saveMW01",
		    	param : param
		    });
			**/
			//alert(commonUtil.getMsg(json.data));
			if(json){
				if(json.data){
					gridList.resetGrid("gridListSub");
					searchList();
				}
			}
		}
	}

	function searchHelpEventOpenBefore(searchCode, gridType){
		if(searchCode == "SHCOMMA"){
			return dataBind.paramData("searchArea");
		}else if(searchCode == "SHWAHMA"){
			return dataBind.paramData("searchArea");
		} //SHPTKY
	}
	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}
	}	

	function gridExcelDownloadEventBefore(gridId){
		if(gridId == "gridListSub"){
			var param = inputList.setRangeParam("searchArea"); 
			var rowVal = gridList.getColData("gridList", gridList.getSelectIndex("gridList"), "WAREKY"); 
			param.put("WAREKY", rowVal);
			param.put(configData.DATA_EXCEL_REQUEST_FILE_NAME, "");
			return param; 
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
						<th CL="STD_COMPKY">Company Code</th>
						<td>
							<input type="text" name="COMPKY" value="<%=compky%>"  readonly="readonly" style="width:110px" />  <!-- UIInput="S,SHCOMMA"   -->
						</td>
					</tr>
					<tr>
						<th CL="STD_WAREKY">Center Code</th>
						<td>
							<input type="text" name="WAREKY" id="WAREKY" value='<%=wareky%>' UIInput="R,SHWAHMA" />			
						</td>
					</tr>
					<tr>
						<th CL="STD_SHPTKY">출하지점</th>
						<td>
							<input type="text" name="B.SHPTKY" UIInput="R,SHPTKY"/>								
						</td>
					</tr>
				    <tr>
				    	<th CL="STD_DELMAK">삭제</th>
						<td>
							<input type="checkbox" name="DELMAK" value="V"/>
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
						<li><a href="#tabs1-1"><span CL='STD_GENERAL'>탭메뉴1</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
											<col width="40" /> 
											<col width="100" /> 
											<col width="100" /> 
											<col width="100" /> 
											<col width="150" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="150" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<th CL='STD_COMPKY'>회사</th>
												<th CL='STD_WAREKY'>거점</th>
												<th CL='STD_WANAME'>거점명</th>
												<th CL='STD_ADDR'>주소</th>
												<th CL='STD_NATNKY'>국가</th>
												<th CL='STD_VATREG'>사업자등록번호</th>
												<th CL='STD_FAXTL1'>팩스번호</th>
												<th CL='STD_TELN01'>전화번호</th>
												<th CL='STD_WADM01'>이메일</th>
												<th CL='STD_WADN01'>관리자명</th>
												<th CL='STD_SHPLAT'>위도</th>
												<th CL='STD_SHPLON'>경도</th>
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="40" /> 
											<col width="100" /> 
											<col width="100" /> 
											<col width="100" /> 
											<col width="150" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="150" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<td GCol="text,COMPKY" GF="S 10">회사</td>
												<td GCol="input,WAREKY,SHWAHMA" id="WAREKY" validate="required" GF="S 10">거점</td>
												<td GCol="input,NAME01" GF="S 180">거점명</td>
												<td GCol="input,ADDR01" GF="S 180">주소</td>
												<td GCol="select,NATNKY">
													<select CommonCombo="NATNKY"></select>
												</td>
												<td GCol="input,VATREG" GF="S 20">사업자등록번호</td>
												<td GCol="input,FAXTL1" GF="S 20">팩스번호</td>
												<td GCol="input,TELN01" validate="tel(GRID_COL_TELN01_*)" GF="S 20">전화번호</td>
												<td GCol="input,WADM01" validate="email(GRID_COL_WADM01_*)" GF="S 60">e-Mail</td>
												<td GCol="input,WADN01" GF="S 60">관리자명</td>	
												<td GCol="input,SHPLAT" GF="S 60">위도</td>	
												<td GCol="input,SHPLON" GF="S 60">경도</td>												
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
						<li><a href="#tabs1-1"><span CL='STD_SEARCH'>탭메뉴1</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
											<col width="40" /> 
											<col width="100" />
											<col width="150" />
											<col width="100" />
											<col width="100" />
											<col width="200" />
											<col width="100" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<th CL='STD_SHPTKY'>출하지점</th>
												<th CL='STD_SHPTKY_NAME01'>출하지점명</th>
												<th CL='STD_FAXTL1'>팩스번호</th>
												<th CL='STD_TELN01'>전화번호</th>
												<th CL='STD_WADM01'>이메일</th>
												<th CL='STD_WADN01'>관리자명</th> 
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="40" /> 
											<col width="100" /> 
											<col width="150" /> 
											<col width="100" /> 
											<col width="100" />
											<col width="200" />
											<col width="100" />
										</colgroup>
										<tbody id="gridListSub">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<td GCol="input,SHPTKY" id="SHPTKY" validate="required" GF="S 10" >출하지점</td>
												<td GCol="input,NAME01" GF="S 180">출하지점명</td>
												<td GCol="input,FAXTL1" validate="tel(GRID_COL_TELN01_*)" GF="S 20">팩스번호</td>
												<td GCol="input,TELN01" validate="tel(GRID_COL_TELN01_*)" GF="S 20">전화번호</td>
												<td GCol="input,PLDM01" validate="email(GRID_COL_WADM01_*)" GF="S 60">e-Mail</td>
												<td GCol="input,PLDN01" GF="S 60">관리자명</td> 												
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
		</div>
		<!-- //contentContainer -->
	</div>
</div>
<!-- //content -->
<%@ include file="/common/include/bottom.jsp" %> 
</body>
</html>