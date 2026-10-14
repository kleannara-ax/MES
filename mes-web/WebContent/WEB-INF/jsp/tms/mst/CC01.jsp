<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript">
	var dblIdx = 0;
	
	$(document).ready(function(){
		setTopSize(250);
		gridList.setGrid({
	    	id : "gridList",
			editable : true,
			pkcol : "CMCDKY",
			module : "WmsAdmin",
			command : "CC01",
			bindArea : "tabs1-2"
	    });
		
		gridList.setGrid({
	    	id : "gridListSub",
			editable : true,
			pkcol : "CMCDKY,CMCDVL",
			module : "WmsAdmin",
			command : "CC01Sub"
	    });
	});

	function searchList(){
		var param = inputList.setRangeParam("searchArea");
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
	}
	
	function searchSubList(headRowNum){
		var rowVal = gridList.getColData("gridList", headRowNum, "CMCDKY");
		var param = inputList.setRangeParam("searchArea");
		param.put("CMCDKY", rowVal);
		
		gridList.gridList({
			id : "gridListSub",
			param : param
		});

		lastFocusNum = rowNum;
		dblIdx = rowNum;
	}
	
	var lastFocusNum = -1;
	function gridListEventDataBindEnd(gridId, dataLength){
		if(gridId == "gridList" && dataLength > 0){
			searchSubList(0);
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
		if(gridId == "gridList"){
			var headCnt = gridList.getModifyRowCount("gridList");
			var listCnt = gridList.getModifyRowCount("gridListSub");
			if(listCnt > 0 || headCnt > 0){
				//alert("변경된 row를 저장 후 행추가 하십시요.");
				commonUtil.msgBox("MASTER_M0686");
				return false;
			}else{
				var newData = new DataMap();
				newData.put("STATUS", "C");

				return newData;
			}
		}else if(gridId == "gridListSub"){
			if(dblIdx == -1){
				var headNum = gridList.getGridDataCount("gridList") -1;
				
				if(gridList.getColData("gridList", headNum, "STATUS") == ""){
					//alert(commonUtil.getMsg("MASTER_M0577"));
					commonUtil.msgBox("MASTER_M0577");
					return false;
				}
	
				if(gridList.getColData("gridList", headNum, "STATUS") == "C"){
					var cmcdky = gridList.getColData("gridList", headNum, "CMCDKY");

					if(cmcdky != ""){
						var newData = new DataMap();
						newData.put("CMCDKY",cmcdky);
					
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
				
				var cmcdky = gridList.getColData("gridList", dblIdx, "CMCDKY");
	
				var newData = new DataMap();
				newData.put("CMCDKY",cmcdky);
				
				return newData;
			}
		}
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId == "gridList" && colName == "CMCDKY"){
			if(colValue != ""){
				var cmcdky = gridList.getColData("gridList", rowNum, "CMCDKY");
				
				var param = new DataMap();
				param.put("CMCDKY",colValue);
				
				var json = netUtil.sendData({
					module : "WmsAdmin",
					command : "CC01CMCDKYval",
					sendType : "map",
					param : param
				});
				
				if(json.data["CNT"] >= 1) {
					gridList.setColValue("gridList", rowNum, "CMCDKY", "");
					//alert(commonUtil.getMsg("MASTER_M0129",colValue));
					commonUtil.msgBox("MASTER_M0129",colValue);
					return false;
				}
			}
			if(gridList.getGridDataCount("gridListSub") > 0){
				var listCnt = gridList.getGridDataCount("gridList");
				if(listCnt != 0){
					for(var i = 0; i < listCnt; i++){
						gridList.setColValue("gridListSub", i, "CMCDKY", colValue);
					}
				}
			}
		}else if(gridId == "gridListSub" && colName == "CMCDVL"){
			if(colValue != ""){
				var cmcdky = gridList.getColData("gridListSub", rowNum, "CMCDKY");
				
				var param = new DataMap();
				param.put("CMCDKY",cmcdky);
				param.put("CMCDVL",colValue);
				
				var json = netUtil.sendData({
					module : "WmsAdmin",
					command : "CC01CMCDVLval",
					sendType : "map",
					param : param
				});
				
				if(json.data["CNT"] >= 1) {
					gridList.setColValue("gridListSub", rowNum, "CMCDVL", "");
					//alert(commonUtil.getMsg("MASTER_M0318"));
					commonUtil.msgBox("MASTER_M0318");
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
			
			if(gridList.getRowStatus("gridList",headNum) == "C" && gridList.getGridDataCount("gridListSub") == 0){
				//alert(commonUtil.getMsg("OUT_M0045"));
				commonUtil.msgBox("OUT_M0045");
				return;
			}
			
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
				url : "/wms/admin/json/saveCC01.data",
				param : param
			});
			
			alert(commonUtil.getMsg(json.data));
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
		}else if(btnName == "Execute"){
			test3();
		}
	}
	
	function gridExcelDownloadEventBefore(gridId){
		if(gridId == "gridListSub"){
			var param = inputList.setRangeParam("searchArea"); 
			var rowVal = gridList.getColData("gridList", gridList.getSelectIndex("gridList"), "CMCDKY"); 
			param.put("CMCDKY", rowVal);
			param.put(configData.DATA_EXCEL_REQUEST_FILE_NAME, "리스트");
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
						<th CL="STD_CMCDKY">공통 코드 키</th>
						<td colspan="3">
							<input type="text" name="CV.CMCDKY" UIInput="R" />
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
						<li><a href="#tabs1-1"><span>일반</span></a></li>
						<li><a href="#tabs1-2"><span>상세</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
											<col width="40" />
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
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<th CL='STD_CMCDKY'></th> <!-- 공통 코드 키 -->    
												<th CL='STD_SHORTX'></th> <!-- 설명 -->         
												<th CL='STD_DBFILD'></th> <!-- DB 필드 이름 -->   
												<th CL='STD_USARL1,2'></th> <!-- UA Lbl.1 -->   
												<th CL='STD_USARL2,2'></th> <!-- UA Lbl.2 -->   
												<th CL='STD_USARL3,2'></th> <!-- UA Lbl.3 -->   
												<th CL='STD_USARL4,2'></th> <!-- UA Lbl.4 -->   
												<th CL='STD_USARL5,2'></th> <!-- UA Lbl.5 -->   
												<th CL='STD_SYONLY'></th> <!-- 시스템에서만사용 -->   
												<th CL='STD_CREDAT'></th> <!-- 생성일자 -->       
												<th CL='STD_CRETIM'></th> <!-- 생성시간 -->       
												<th CL='STD_CREUSR'></th> <!-- 생성자 -->
												<th CL='STD_LMODAT'></th> <!-- 수정일자 -->       
												<th CL='STD_LMOTIM'></th> <!-- 수정시간 -->       
												<th CL='STD_LMOUSR'></th> <!-- 수정자 -->
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="40" />
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
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<td GCol="input,CMCDKY" validate="required,MASTER_M0023" GF="S 10"></td> <!-- 공통 코드 키 -->    
												<td GCol="input,SHORTX" GF="S 180"></td> <!-- 설명 -->         
												<td GCol="input,DBFILD" GF="S 10"></td> <!-- DB 필드 이름 -->   
												<td GCol="input,USARL1" GF="S 30"></td> <!-- UA Lbl.1 -->   
												<td GCol="input,USARL2" GF="S 30"></td> <!-- UA Lbl.1 -->   
												<td GCol="input,USARL3" GF="S 30"></td> <!-- UA Lbl.1 -->   
												<td GCol="input,USARL4" GF="S 30"></td> <!-- UA Lbl.1 -->   
												<td GCol="input,USARL5" GF="S 30"></td> <!-- UA Lbl.1 -->   
												<td GCol="check,SYONLY"></td> <!-- 시스템에서만사용 -->   
												<td GCol="text,CREDAT"></td> <!-- 생성일자 -->       
												<td GCol="text,CRETIM"></td> <!-- 생성시간 -->       
												<td GCol="text,CREUSR"></td> <!-- 생성자 -->
												<td GCol="text,LMODAT"></td> <!-- 수정일자 -->       
												<td GCol="text,LMOTIM"></td> <!-- 수정시간 -->       
												<td GCol="text,LMOUSR"></td> <!-- 수정자 -->        
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
									<button type="button" GBtn="total"></button>
									<button type="button" GBtn="excel"></button>
								</div>
								<div class="rightArea">
									<p class="record" GInfoArea="true"></p>
								</div>
							</div>
						</div>
					</div>
					<div id="tabs1-2">
						<div class="section type1">
							<div class="searchInBox">
							
							<h2 class="tit type1">헤더</h2>
								<table class="table type1">
									<colgroup>
										<col width="100" />
										<col />
										<col width="100" />
										<col />
									</colgroup>
									<tbody>
										<tr>
											<th CL="STD_CMCDKY">공통 코드 키</th>
											<td >
												<input type="text" name="CMCDKY" readonly="readonly"/>
											</td>
											<th CL="STD_DBFILD">DB 필드 이름</th>
											<td >
												<input type="text" name="DBFILD" />
											</td>
										</tr>
										<tr>									
											<th CL="STD_USARL1,2">사용자인수1라벨</th>
											<td>
												<input type="text" name="USARL1" />
											</td>
											<th CL="STD_USARL2,2">사용자인수2라벨</th>
											<td>
												<input type="text" name="USARL2" />
											</td>
										</tr>
										<tr>											
											<th CL="STD_USARL3,2">사용자인수3라벨</th>
											<td >
												<input type="text" name="USARL3" />
											</td>
											<th CL="STD_USARL4,2">사용자인수4라벨</th>
											<td >
												<input type="text" name="USARL4" />
											</td>
										</tr>
										<tr>											
											<th CL="STD_USARL5,2">사용자인수5라벨</th>
											<td >
												<input type="text" name="USARL5" />
											</td>
											<th CL="STD_SYONLY">시스템에서만 사용</th> <!-- 체크버튼 -->
											<td >
												<input type="checkbox" id="SYONLY" name="SYONLY" value="V"/>
											</td>
										</tr>
										<tr>											
											<th CL="STD_SHORTX">설명</th>
											<td colspan="2">
												<input type="text" name="SHORTX" />
											</td>
										</tr>
									</tbody>
								</table>
							</div>
						</div>
					</div>
				</div>
			</div>

			<div class="bottomSect bottom">
				<button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button>
				<div class="tabs">
					<ul class="tab type2" id="commonMiddleArea">
						<li><a href="#tabs1-1"><span>아이템</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
											<col width="40" />
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
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<th CL='STD_CMCDKY'></th> <!-- 공통 코드 키 -->
												<th CL='STD_CMCDVL,2'></th> <!-- 유형코드 -->
												<th CL='STD_CDESC1'></th> <!-- 코드 설명 -->
												<th CL='STD_CDESC2'></th> <!-- 코드 설명2 -->
												<th CL='STD_USARG1,2'></th> <!-- UA. 1 -->
												<th CL='STD_USARG2,2'></th> <!-- UA. 2 -->
												<th CL='STD_USARG3,2'></th> <!-- UA. 3 -->
												<th CL='STD_USARG4,2'></th> <!-- UA. 4 -->
												<th CL='STD_USARG5,2'></th> <!-- UA. 5 -->
												<th CL='STD_CREDAT'></th> <!-- 생성일자 -->
												<th CL='STD_CRETIM'></th> <!-- 생성시간 -->
												<th CL='STD_CREUSR'></th> <!-- 생성자 명 -->
												<th CL='STD_LMODAT'></th> <!-- 수정일자 -->
												<th CL='STD_LMOTIM'></th> <!-- 수정시간 -->
												<th CL='STD_LMOUSR'></th> <!-- 수정자 -->
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="40" />
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
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
										</colgroup>
										<tbody id="gridListSub">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<td GCol="text,CMCDKY"></td> <!-- 공통 코드 키 -->  
												<td GCol="input,CMCDVL" validate="required" GF="S 10"></td> <!-- 유형코드 --> 
												<td GCol="input,CDESC1" GF="S 180"></td> <!-- 코드 설명 -->
												<td GCol="input,CDESC2" GF="S 180"></td> <!-- 코드 설명2 -->
												<td GCol="input,USARG1" GF="S 40"></td> <!-- UA. 1 -->
												<td GCol="input,USARG2" GF="S 10"></td> <!-- UA. 2 -->
												<td GCol="input,USARG3" GF="S 10"></td> <!-- UA. 3 -->
												<td GCol="input,USARG4" GF="S 10"></td> <!-- UA. 4 -->
												<td GCol="input,USARG5" GF="S 10"></td> <!-- UA. 5 -->   
												<td GCol="text,CREDAT"></td> <!-- 생성일자 --> 
												<td GCol="text,CRETIM"></td> <!-- 생성시간 --> 
												<td GCol="text,CREUSR"></td> <!-- 생성자 -->
												<td GCol="text,LMODAT"></td> <!-- 수정일자 --> 
												<td GCol="text,LMOTIM"></td> <!-- 수정시간 --> 
												<td GCol="text,LMOUSR"></td> <!-- 수정자 -->
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