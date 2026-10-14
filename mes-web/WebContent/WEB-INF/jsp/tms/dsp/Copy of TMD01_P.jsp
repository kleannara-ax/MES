<%@ page language="java" contentType="text/html; charset=UTF-8" 
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript"> 
	var lastFocusNum = -1;
	var dblIdx = 0;
	var __SIMKEY = '';
	var tab_1_1_grid__DELORD = '';
	var tab_2_1_grid__DELORD = '';
	
	var sWidth = window.screen.availWidth;
	var sHeight = window.screen.availHeight;

	function forceFullScreen() {  
		self.window.resizeTo(sWidth,sHeight);
		self.window.moveTo(0,0); 
	}
	 
	$(document).ready(function(){
		forceFullScreen();
		
	  //setTopSize(250);
		gridList.setGrid({
	    	id : "tab_1_1_grid",
			editable : false,
			pkcol : "SIMKEY,DELORD,DELITN", 
			module : "TmsAdmin",
			command : "DNTAK_GROUP"
	    });
	    
		gridList.setGrid({
	    	id : "tab_1_2_grid",
			editable : false,
			pkcol : "SIMKEY,DELORD,DELITN", 
			module : "TmsAdmin",
			command : "DNTAK_DN_ITEM",
			emptyMsgType:false
	    });
	     
		gridList.setGrid({
	    	id : "tab_2_1_grid",
			editable : true,
			pkcol : "SIMKEY,DELORD,DELITN", 
			module : "TmsAdmin",
			command : "DNTAK_GROUP"
	    });
	    
		gridList.setGrid({
	    	id : "tab_2_2_grid",
			editable : true,
			pkcol : "SIMKEY,DELORD,DELITN", 
			module : "TmsAdmin",
			command : "DNTAK_DN_ITEM",
			emptyMsgType:false
	    });

		userInfoData = page.getUserInfo();
		dataBind.dataNameBind(userInfoData, "searchArea");
	});
	
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
	
			gridList.gridList({
		    	id : "tab_1_1_grid",
		    	param : param
		    });

			gridList.gridList({
		    	id : "tab_2_1_grid",
		    	param : param
		    });
		}
	}
	 
	function searchTab_1_2_List(){
		var param = inputList.setRangeParam("searchArea");
		param.put("SIMKEY", __SIMKEY);
		param.put("DELORD", tab_1_1_grid__DELORD);
		 
		gridList.gridList({
			id : "tab_1_2_grid",
			param : param
		});
	}

	function searchTab_2_2_List(){
		var param = inputList.setRangeParam("searchArea");
		param.put("SIMKEY", __SIMKEY);
		param.put("DELORD", tab_2_1_grid__DELORD);
		 
		gridList.gridList({
			id : "tab_2_2_grid",
			param : param
		}); 
	} 
	 
	function gridListEventItemGridSearch(gridId, rowNum, itemGridList){
		if(gridId == "tab_1_1_grid"){ 
			gridListEventRowDblclick(gridId, rowNum);
		}
	}

	function gridListEventRowClick(gridId, rowNum, colName){ 
		gridListEventRowDblclick(gridId, rowNum);
	}
		 
	function gridListEventRowDblclick(gridId, rowNum){
		var rowVal;
		if(gridId == "tab_1_1_grid"){
			if(gridList.getColData("tab_1_1_grid", rowNum, "STATUS") == "C"){
				return false;
			}

			rowVal = gridList.getColData("tab_1_1_grid", rowNum, "DELORD");
			tab_1_1_grid__DELORD=rowVal;
			
			searchTab_1_2_List();
		}

		if(gridId == "tab_2_1_grid"){
			if(gridList.getColData("tab_2_1_grid", rowNum, "STATUS") == "C"){
				return false;
			}
			rowVal = gridList.getColData("tab_1_1_grid", rowNum, "DELORD");
			tab_2_1_grid__DELORD=rowVal;
			
			searchTab_2_2_List();
		}
	}

	//그리드 위에 클릭시 아이템 리셋
	function gridListEventRowFocus(gridId, rowNum){
		if(gridId == "tab_1_1_grid"){
			var modRowCnt = gridList.getModifyRowCount("tab_1_2_grid");
			if(modRowCnt == 0){
				if(dblIdx != rowNum){
					gridList.resetGrid("tab_1_2_grid");
					dblIdx = -1;
				}
			//저장
			}else{
				if(commonUtil.msgConfirm("COMMON_M0462")){
				//if(confirm("값이 변화된 데이터가 있습니다. 이동하시겠습니까?")){
					gridList.resetGrid("tab_1_2_grid");
				}else{
					gridListEventRowFocus("tab_1_1_grid", dblIdx);
					return;
				}
			}
		}
	}
	 
	function gridListEventRowAddBefore(gridId, rowNum) {
		if(gridId == "tab_1_1_grid"){
			var headCnt = gridList.getModifyRowCount("tab_1_1_grid");
			var listCnt = gridList.getModifyRowCount("tab_1_2_grid");
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
		}else if(gridId == "tab_1_2_grid"){
			if(dblIdx == -1){
				var headNum = gridList.getGridDataCount("tab_1_1_grid") -1;
				
				if(gridList.getColData("tab_1_1_grid", headNum, "STATUS") == ""){
					//alert(commonUtil.getMsg("MASTER_M0577"));
					//commonUtil.msgBox("MASTER_M0577");
					return false;
				}
	
				if(gridList.getColData("tab_1_1_grid", headNum, "STATUS") == "C"){
					var wareky = gridList.getColData("tab_1_1_grid", headNum, "WAREKY");

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
				
				var wareky = gridList.getColData("tab_1_1_grid", dblIdx, "WAREKY");
	
				var newData = new DataMap();
				newData.put("WAREKY",wareky);
				
				return newData;
			}
		}
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId == "tab_1_1_grid" && colName == "WAREKY"){
			if(colValue != ""){
				var wareky = gridList.getColData("tab_1_1_grid", rowNum, "WAREKY");
				
				var param = new DataMap();
				param.put("WAREKY",colValue);
				
				var json = netUtil.sendData({
					module : "TmsAdmin",
					command : "MW01WAREKYval",
					sendType : "map",
					param : param
				});
				
				if(json.data["CNT"] >= 1) {
					gridList.setColValue("tab_1_1_grid", rowNum, "WAREKY", ""); 
			      //commonUtil.msgBox("MASTER_M0129",colValue);
					commonUtil.msgBox("COMMON_M0006",colValue);
					return false;
				}
			}
			if(gridList.getGridDataCount("tab_1_2_grid") > 0){
				var listCnt = gridList.getGridDataCount("tab_1_1_grid");
				if(listCnt != 0){
					for(var i = 0; i < listCnt; i++){
						gridList.setColValue("tab_1_2_grid", i, "WAREKY", colValue);
					}
				}
			}
		}else if(gridId == "tab_1_2_grid" && colName == "SHPTKY"){
			if(colValue != ""){
				var wareky = gridList.getColData("tab_1_2_grid", rowNum, "WAREKY");
				
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
					gridList.setColValue("tab_1_2_grid", rowNum, "SHPTKY", "");
					//alert(commonUtil.getMsg("MASTER_M0318"));
					//commonUtil.msgBox("MASTER_M0318");
					commonUtil.msgBox("COMMON_M0006"); 
					return false;
				}
			}
		}
	}
	  
	function saveData(){
		if(gridList.getModifyRowCount("tab_1_1_grid") == 0 && gridList.getModifyRowCount("tab_1_2_grid") == 0 ){
			//alert(commonUtil.getMsg("MASTER_M0545"));
			commonUtil.msgBox("MASTER_M0545");
			return;
		}
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		}
		if(gridList.validationCheck("tab_1_1_grid", "modify") && gridList.validationCheck("tab_1_2_grid", "modify")){
			
			var headNum = gridList.getGridDataCount("tab_1_1_grid") -1;
			
			/**
		    if(gridList.getRowStatus("tab_1_1_grid",headNum) == "C" && gridList.getGridDataCount("tab_1_2_grid") == 0){
						//alert(commonUtil.getMsg("OUT_M0045"));
				commonUtil.msgBox("OUT_M0045");//처리하기위한 데이터가 존재하지 않습니다.
				return;
			}**/
			
			var headCnt = gridList.getGridDataCount("tab_1_1_grid");
			for(var i = 0; i < headCnt; i++){
		    	gridList.setColValue("tab_1_1_grid", i, "STATUS", gridList.getRowStatus("tab_1_1_grid", i));
		    }
			var head = gridList.getGridData("tab_1_1_grid");
			
			var listCnt = gridList.getGridDataCount("tab_1_2_grid");
		    for(var i = 0; i < listCnt; i++){
		    	gridList.setColValue("tab_1_2_grid", i, "STATUS", gridList.getRowStatus("tab_1_2_grid", i));
		    }
			
			var list = gridList.getGridData("tab_1_2_grid");
			
			var param = new DataMap();
			
			param.put("head", head);
			param.put("list", list);
	
			//alert(param);
			var json = netUtil.sendData({
				url : "/tms/admin/dsp/saveMW01.data",
				param : param
			});
			
			//alert(commonUtil.getMsg(json.data));
			if(json){
				if(json.data){
					gridList.resetGrid("tab_1_2_grid");
					searchList();
				}
			}
		}
	}
	

	function searchHelpEventOpenBefore(searchCode, gridType){
		if(searchCode == "SHAREMA"){
			return dataBind.paramData("searchArea");
		}else if(searchCode == "SHWAHMA"){
			return dataBind.paramData("searchArea");
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
		<button CB="Save SAVE STD_SAVESPLIT">
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
						<th CL="STD_WAREKY">거점</th>
						<td>
							<input type="text" name="WAREKY" UIInput="R,SHWAHMA" value="<%=wareky%>" readonly="readonly"/>
						</td>
					</tr> 
					<tr>
						<th >시뮬레이션ID</th>
						<td>
							<input type="text" name="SIMKEY" UIInput="R,SHZONMA" />
						</td>
					</tr>
					<tr> 
						<th CL="STD_CREDAT">생성일자</th>
						<td>
							<input type="text" name="CREDAT" UIInput="R,SHZONMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_CREUSR">생성자</th>
						<td>
							<input type="text" name="CREUSR" UIInput="R,SHZONMA" />
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
		
		
			<div class="bottomSect"  style="top:3px; height: 153px">
				<!-- button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button-->
				<div class="tabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span >원주문(Delivery Note)</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2" style="height: 130px;">
								<div class="tableHeader">
									<table>
													<colgroup>
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
															<th >시뮬레이션ID</th>
															<th >시뮬레이션명</th>
															<th >Delivery Note</th>
															<th >도착지코드</th>
															<th >도착지명</th>
															<th >도착지유형</th>
															<th >배송유형</th>
															<th >배송요청일</th>
															<th >단위1(EA)</th>
															<th >단위2(KG)</th>
															<th >단위3(M2)</th>
															<th >단위4(M3)</th>
															<th >긴급도</th>
															<th >집배송구분</th>
															<th >생성일자</th>
															<th >생성시간</th>
															<th >생성자</th>
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
														<col width="100" />
														<col width="100" />
														<col width="100" />
													</colgroup>
													<tbody id="tab_1_1_grid">
														<tr CGRow="true">
															<td GCol="rownum">1</td>
															<td GCol="text,SIMKEY" >시뮬레이션ID</td>  
															<td GCol="text,SHORTX" >시뮬레이션명</td>  
															<td GCol="text,DELORD" >Delivery Note</td> 
															<td GCol="text,SIMKEY" >도착지코드?</td>    
															<td GCol="text,SIMKEY" >도착지명?</td>      
															<td GCol="text,SIMKEY" >도착지유형?</td>    
															<td GCol="text,VSART" >배송유형?</td>      
															<td GCol="text,VDATU" >배송요청일</td>    
															<td GCol="text,LFIMG" >단위1<br/>(EA)</td>
															<td GCol="text,BRGEW" >단위2<br/>(KG)</td>
															<td GCol="text,NTGEW" >단위3<br/>(M2)</td>
															<td GCol="text,SIMKEY" >단위4<br/>(M3)</td>
															<td GCol="text,URGNT" >긴급도</td>        
															<td GCol="text,SIMKEY" >집배송구분?</td>    
															<td GCol="text,CREDAT" >생성일자</td>      
															<td GCol="text,CRETIM" >생성시간</td>      
															<td GCol="text,CREUSR" >생성자</td>												
														</tr>									
													</tbody>
									</table>
								</div>
							</div>
							<!-- div class="tableUtil">
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
							</div -->
						</div>
					</div>					
			        </div>
		        </div> 
		        
		        
			<div class="bottomSect" style="top: 159px; height:153px;">
				<!-- button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button-->
				<div class="tabs">
					<ul class="tab type2" >
						<li><a href="#tabs1-2"><span >원주문(Item)</span></a></li>
					</ul>
					<div id="tabs1-2">
						<div class="section type1">
							<div class="table type2" style="height: 130px;">
								<div class="tableHeader">
									<table>
														<colgroup>
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
														</colgroup>
														<thead>
															<tr>
																<th CL='STD_NUMBER'>번호</th>
																<th >Delivery Note</th>
																<th >Delivery Item</th>
																<th >Sales Order</th>
																<th >S/O Item</th>
																<th >Material</th>
																<th >설명</th>
																<th >단위1(EA)</th>
																<th >단위2(KG)</th>
																<th >단위3(M2)</th>
																<th >단위4(M3)</th>
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
															<col width="100" />
															<col width="100" />
															<col width="100" />
															<col width="100" />
															<col width="100" />
															<col width="100" />
															<col width="100" />
														</colgroup>
														<tbody id="tab_1_2_grid">
															<tr CGRow="true">
																<td GCol="rownum">1</td>
																<td GCol="text,ITEM_DELORD" >Delivery Note</td>
																<td GCol="text,ITEM_DELITN" >Delivery Item</td>
																<td GCol="text,ITEM_SALORD" >Sales Order</td>
																<td GCol="text,ITEM_SALITN" >S/O Item</td>
																<td GCol="text,ITEM_MTLCDE" >Material</td>
																<td GCol="text,ITEM_MTLTXT" >설명</td>
																<td GCol="text,ITEM_LFIMG" >단위1<br/>(EA)</td>
																<td GCol="text,ITEM_BRGEW" >단위2<br/>(KG)</td>
																<td GCol="text,ITEM_NTGEW" >단위3<br/>(M2)</td>
																<td GCol="text,ITEM_SIMKEY" >단위4<br/>(M3)</td>											
															</tr>									
														</tbody>
									</table>
								</div>
							</div>
							<!-- div class="tableUtil">
								<div class="leftArea">		
									<button type="button" GBtn="find" ></button>
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
							</div -->
						</div>
					</div>					
			        </div>
		        </div>
		        
		        
		        
			<div class="bottomSect" style="top: 313px; height:194px;">
				<!-- button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button-->
				<div class="tabs">
					<ul class="tab type2" id="commonMiddleArea">
						<li><a href="#tabs2-1"><span >분활(Delivery Note)</span></a></li>
					</ul>
					<div id="tabs2-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
													<colgroup>
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
															<th >시뮬레이션ID</th>
															<th >시뮬레이션명</th>
															<th >Delivery Note</th>
															<th >도착지코드</th>
															<th >도착지명</th>
															<th >도착지유형</th>
															<th >배송유형</th>
															<th >배송요청일</th>
															<th >단위1<br/>(EA)</th>
															<th >단위2<br/>(KG)</th>
															<th >단위3<br/>(M2)</th>
															<th >단위4<br/>(M3)</th>
															<th >긴급도</th>
															<th >집배송구분</th>
															<th >생성일자</th>
															<th >생성시간</th>
															<th >생성자</th>
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
														<col width="100" />
														<col width="100" />
														<col width="100" />
													</colgroup>
													<tbody id="tab_2_1_grid">
														<tr CGRow="true">
															<td GCol="rownum">1</td>
															<td GCol="text,SIMKEY" >시뮬레이션ID</td>  
															<td GCol="text,SHORTX" >시뮬레이션명</td>  
															<td GCol="text,DELORD" >Delivery Note</td> 
															<td GCol="text,SIMKEY" >도착지코드?</td>    
															<td GCol="text,SIMKEY" >도착지명?</td>      
															<td GCol="text,SIMKEY" >도착지유형?</td>    
															<td GCol="text,VSART" >배송유형?</td>      
															<td GCol="text,VDATU" >배송요청일</td>    
															<td GCol="text,LFIMG" >단위1<br/>(EA)</td>
															<td GCol="text,BRGEW" >단위2<br/>(KG)</td>
															<td GCol="text,NTGEW" >단위3<br/>(M2)</td>
															<td GCol="text,SIMKEY" >단위4<br/>(M3)</td>
															<td GCol="text,URGNT" >긴급도</td>        
															<td GCol="text,SIMKEY" >집배송구분?</td>    
															<td GCol="text,CREDAT" >생성일자</td>      
															<td GCol="text,CRETIM" >생성시간</td>      
															<td GCol="text,CREUSR" >생성자</td>												
														</tr>									
													</tbody>
									</table>
								</div>
							</div>
							<div class="tableUtil">
								<!-- div class="leftArea">		
									<button type="button" GBtn="find"></button>
									<button type="button" GBtn="sortReset"></button>
									<button type="button" GBtn="add"></button>
									<button type="button" GBtn="copy"></button>
									<button type="button" GBtn="delete"></button>
									<button type="button" GBtn="layout"></button>
									<button type="button" GBtn="total"></button>
									<button type="button" GBtn="excel"></button>
									<button title="찾기" class="button type4" type="button" gbtn="find" jquery111106820461616173443="520"><img src="/common/images/grid_icon_03.png"></button>
								</div-->
								<DIV class=leftArea> 
									<BUTTON title=찾기 class="button type4" type=button jQuery1111007289437903999113="520" GBtn="find">
									</BUTTON>
									<BUTTON title=정렬초기화 class="button type4" type=button jQuery1111007289437903999113="522" GBtn="sortReset">
									</BUTTON>
									<BUTTON title=행추가 class="button type4" type=button jQuery1111007289437903999113="524" GBtn="add">
									</BUTTON>
									<BUTTON title=행복사 class="button type4" type=button jQuery1111007289437903999113="526" GBtn="copy">
									</BUTTON>
									<BUTTON title=행삭제 class="button type4" type=button jQuery1111007289437903999113="528" GBtn="delete">
									</BUTTON>
									<BUTTON title=레이아웃설정 class="button type4" type=button jQuery1111007289437903999113="530" GBtn="layout">
									</BUTTON>
									<BUTTON title=합계보기 class="button type4" type=button jQuery1111007289437903999113="532" GBtn="total">
									</BUTTON>
									<BUTTON title=엑셀다운로드 class="button type4" type=button jQuery1111007289437903999113="534" GBtn="excel">
									</BUTTON> 
								</DIV>
								<div class="rightArea">
									<p class="record" GInfoArea="true"></p>
								</div>
							</div>
						</div>
					</div>					
			        </div>
		        </div> 
		        
		        
			<div class="bottomSect " style="top: 510px; height: 214px;">
				<!-- button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button-->
				<div class="tabs">
					<ul class="tab type2" id="commonMiddleArea">
						<li><a href="#tabs2-2"><span >분활(Item)</span></a></li>
					</ul>
					<div id="tabs2-2">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
														<colgroup>
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
														</colgroup>
														<thead>
															<tr>
																<th CL='STD_NUMBER'>번호</th>
																<th >Delivery Note</th>
																<th >Delivery Item</th>
																<th >Sales Order</th>
																<th >S/O Item</th>
																<th >Material</th>
																<th >설명</th>
																<th >단위1<br/>(EA)</th>
																<th >단위2<br/>(KG)</th>
																<th >단위3<br/>(M2)</th>
																<th >단위4<br/>(M3)</th>
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
															<col width="100" />
															<col width="100" />
															<col width="100" />
															<col width="100" />
															<col width="100" />
															<col width="100" />
															<col width="100" />
														</colgroup>
														<tbody id="tab_2_2_grid">
															<tr CGRow="true">
																<td GCol="rownum">1</td>
																<td GCol="text,ITEM_DELORD" >Delivery Note</td>
																<td GCol="text,ITEM_DELITN" >Delivery Item</td>
																<td GCol="text,ITEM_SALORD" >Sales Order</td>
																<td GCol="text,ITEM_SALITN" >S/O Item</td>
																<td GCol="text,ITEM_MTLCDE" >Material</td>
																<td GCol="text,ITEM_MTLTXT" >설명</td>
																<td GCol="text,ITEM_LFIMG" >단위1<br/>(EA)</td>
																<td GCol="text,ITEM_BRGEW" >단위2<br/>(KG)</td>
																<td GCol="text,ITEM_NTGEW" >단위3<br/>(M2)</td>
																<td GCol="text,ITEM_SIMKEY" >단위4<br/>(M3)</td>											
															</tr>									
														</tbody>
									</table>
								</div>
							</div>
							<div class="tableUtil">
								<!-- div class="leftArea">		
									<button type="button" GBtn="find"></button>
									<button type="button" GBtn="sortReset"></button>
									<button type="button" GBtn="add"></button>
									<button type="button" GBtn="copy"></button>
									<button type="button" GBtn="delete"></button>
									<button type="button" GBtn="layout"></button>
									<button type="button" GBtn="total"></button>
									<button type="button" GBtn="excel"></button>
								</div-->
								<DIV class=leftArea> 
									<BUTTON title=찾기 class="button type4" type=button jQuery1111007289437903999113="621" GBtn="find">
									</BUTTON>
									<BUTTON title=정렬초기화 class="button type4" type=button jQuery1111007289437903999113="623" GBtn="sortReset">
									</BUTTON>
									<BUTTON title=행추가 class="button type4" type=button jQuery1111007289437903999113="625" GBtn="add">
									</BUTTON>
									<BUTTON title=행복사 class="button type4" type=button jQuery1111007289437903999113="627" GBtn="copy">
									</BUTTON>
									<BUTTON title=행삭제 class="button type4" type=button jQuery1111007289437903999113="629" GBtn="delete">
									</BUTTON>
									<BUTTON title=레이아웃설정 class="button type4" type=button jQuery1111007289437903999113="631" GBtn="layout">
									</BUTTON>
									<BUTTON title=합계보기 class="button type4" type=button jQuery1111007289437903999113="633" GBtn="total">
									</BUTTON>
									<BUTTON title=엑셀다운로드 class="button type4" type=button jQuery1111007289437903999113="635" GBtn="excel">
									</BUTTON> 
								</DIV>
								<div class="rightArea">
									<p class="record" GInfoArea="true"></p>
								</div>
							</div>
						</div>
					</div>					
			        </div>
		        </div-->
		        
		        
		</div>
		<!-- //contentContainer -->
	</div>
</div>
<!-- //content -->
<%@ include file="/common/include/bottom.jsp" %>
</body>
</html>