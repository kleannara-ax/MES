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
	    	name : "gridList",
			editable : true,
			pkcol : "WAREKY,AREAKY",
			module : "WmsAdmin",
			command : "AREMA",
			bindArea : "tabs1-2" 
	    });
		//gridList.setReadOnly('gridList',true, ['NEGSTK','INDCDO','INDAES']);
	});
	
	function searchHelpEventOpenBefore(searchCode, gridType){
		//commonUtil.debugMsg("searchHelpEventOpenBefore : ", arguments);
		if(searchCode == "SHAREMA"){
			return dataBind.paramData("searchArea");
		}else if(searchCode == "SHWAHMA"){
			return dataBind.paramData("searchArea");
		}
	}
	function searchList(){
		//var param = dataBind.paramData("searchArea");
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			//alert(param);
			gridList.gridList({
				id : "gridList",
				param : param
			});
		}
	}
	
	function saveData(){
		if(gridList.validationCheck("gridList", "modify")){
			var param = dataBind.paramData("searchArea");
			var list = gridList.getModifyData("gridList", "A");
			
			if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
				return;
			}
			
			var param = new DataMap();
			param.put("list", list);
			
			var json = netUtil.send({
				url : "/wms/admin/json/saveMA01.data",
				param : param,
				returnParam : param,
				successFunction : "saveEnd",
				failFunction : "saveFail"
			});
			
			/* var json = gridList.gridSave({
				id : "gridList",
				param : param
			});
			
			if(json){
				if(json.data == 0){
					commonUtil.msgBox("MASTER_M0545");
					searchList();
				}
				if(json.data){
					searchList();
				}
			} */
		}
	}
	
	function saveEnd(json, param){
		
		if(json && json.data){
			if(json.data != "0"){
				alert(commonUtil.getMsg(configData.MSG_SYSTEM_SAVEOK));
			}else{
				alert(commonUtil.getMsg("COMMON_M0465")); // 저장 실패하였습니다.
			}
			searchList();
		}else{
			alert(commonUtil.getMsg("COMMON_M0465")); // 저장 실패하였습니다.
			searchList();
		}
	}
	
	function saveFail(a, b, c, param){ // a:request, b:status, c:error
		var resultText = a.responseText.trim();
		alert(commonUtil.getMsg("COMMON_M0465")); // 저장 실패하였습니다.
		searchList();
	}
	
 	function gridListEventRowAddBefore(gridId, rowNum){
		var areatyt = inputList.getComboData("AREATY", "STOR");
		var newData = new DataMap();
		newData.put("WAREKY",  "<%=wareky%>");
		//newData.put("AREAKY", "RECV");
		newData.put("AREATY", "STOR");
		newData.put("AREATYT", areatyt);
		
		return newData;
	}  
	
	function gridListEventRowRemove(gridId, rowNum){
		var rowAea = gridList.getColData("gridList", rowNum, "AREAKY");
		  if(gridId == "gridList"){
			var param = new DataMap();
			param.put("AREAKY", rowAea);
			//2020.04.14 
			param.put("WAREKY", "<%=wareky%>");
			var json = netUtil.sendData({
				module : "WmsAdmin",
				command : "AREMAval",
				sendType : "map",
				param : param
			});
			
			if(json && json.data){
				if(json.data["CNT"] >= 1){
					//alert("삭제 할 수 없습니다.");
					commonUtil.msgBox("VALID_M0017");//구역이 존재하는 영역을 삭제할 수 없습니다.
					return false;
				} else if (json.data["CNT"] == 0){
					return true;
				}
			}
		}  
	}
	
	function areakyCheck(valueTxt, $colObj){
		var rowNum = gridList.getColObjRowNum("gridList", $colObj);
		var rowCount = gridList.getGridDataCount("gridList");
		for(var i=0;i<rowCount;i++){
			if(i != rowNum){
				var areaky = gridList.getColData("gridList", i, "AREAKY");
				if(areaky == valueTxt){
					return false;
				}
			}			
		}
		return true;
	}
	
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}
	}
	
	//<동일한 영역있으면 필터링해주는 이벤트>
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){		
		if(gridId == "gridList" && colName == "AREAKY"){
			var param = new DataMap();
			param.put("WAREKY","<%=wareky%>");
			param.put("AREAKY",colValue);
			var json = netUtil.sendData({
				module : "WmsAdmin",
				command : "AREMAval",
				sendType : "map",
				param : param
			});
			
			if(json.data["CNT"] > 0) {
				commonUtil.msgBox("VALID_M0302", colValue);
				gridList.setColValue("gridList", rowNum, "AREAKY", " ");	
				return;
			}
		}	
	}
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY"></button>
		<button CB="Save SAVE STD_SAVE"></button>
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
				</colgroup>
				<tbody>
					<tr>
						<th CL="STD_WAREKY">거점</th>
						<td>
							<input type="text" name="WAREKY" value="<%=wareky%>" id="WAREKY" readonly="readonly" />
						</td>
					</tr>
					<tr>
						<th CL="STD_AREAKY">창고</th>
						<td>
							<input type="text" name="AREAKY" UIInput="R,SHAREMA" id="AREAKY"/>
							<!--<input type="text" name="AREAKY" UIInput="R,SHAREMA" id="AREAKY"/>-->
						</td>
					</tr>
					<tr>
						<th CL="STD_AREATY">Area Type</th>
							<td GCol="select,AREATY">
								<select CommonCombo="AREATY" name="AREATY">
									<option value="">All</option>
								</select>
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
			<button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button>
				<div class="tabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span CL='STD_LIST'>리스트</span></a></li>
						<li style="display:none"><a href="#tabs1-2"><span CL='STD_GENERAL'>일반</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
											<col width="40" />
											<col width="60" /> 
											<col width="50" /> 
											<col width="150" />
											<col width="120" /> 
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
											<!-- <col width="100" /> 
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" /> -->
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<th CL='STD_WAREKY'></th>
												<th CL='STD_AREAKY'></th>
												<th CL='STD_AREATY'></th>
												<th CL='STD_SHORTX'>설명</th>
												<th CL='STD_NEGSTK'></th>
												<th CL='STD_INDCDO'></th>
												<th CL='STD_INDAES'></th>
												<th CL='STD_CREDAT'></th>
												<th CL='STD_CRETIM'></th>
												<th CL='STD_CREUSR'></th>
												<th CL='STD_CUSRNM'></th>
												<th CL='STD_LMODAT'></th>
												<th CL='STD_LMOTIM'></th>
												<th CL='STD_LMOUSR'></th>
												<th CL='STD_LUSRNM'></th>
												
												<!-- <th CL='STD_INDSHW'></th>
												<th CL='STD_INDULT,2'></th>
												<th CL='STD_CREDAT'></th>
												<th CL='STD_CRETIM'></th>
												<th CL='STD_CREUSR'></th>
												<th CL='STD_CUSRNM'></th> -->
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="40" />
											<col width="60" /> 
											<col width="50" /> 
											<col width="150" />
											<col width="120" /> 
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
											<!-- <col width="100" /> 
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" /> -->
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<td GCol="text,WAREKY">거점</td>
											    <td GCol="input,AREAKY,SHAREMA" id="AREAKY" validate="required"></td>
												<td GCol="select,AREATY" validate="required,VALID_M0402">
													<select CommonCombo="AREATY" validate="required,VALID_M0402">
													</select>
												</td>
												<td GCol="input,SHORTX" GF="S 60">설명</td>
												<td GCol="check,NEGSTK">(-)허용</td>
												<td GCol="check,INDCDO">문서번호복사</td>
												<td GCol="check,INDAES">재고가산</td>
												<td GCol="text,CREDAT" GF="D">생성일자</td>
												<td GCol="text,CRETIM" GF="T">생성시간</td>
												<td GCol="text,CREUSR">생성자</td>
												<td GCol="text,CUSRNM">생성자명</td>
												<td GCol="text,LMODAT" GF="D">수정일자</td>
												<td GCol="text,LMOTIM" GF="T">수정시간</td>
												<td GCol="text,LMOUSR">수정자</td>
												<td GCol="text,LUSRNM">수정자명</td>
												<!-- <td GCol="check,INDSHW">재고리포트반영</td>
												<td GCol="check,INDULT">LOT별 재고반영</td>
												<td GCol="text,CREDAT">생성일자</td>
												<td GCol="text,CRETIM">생성시간</td>
												<td GCol="text,CREUSR">생성자</td>
												<td GCol="text,CUSRNM">생성자명</td> -->
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
									<!-- <button type="button" GBtn="total"></button> -->
									<button type="button" GBtn="excel"></button>
								</div>
								<div class="rightArea">
									<p class="record" GInfoArea="true"></p>
								</div>
							</div>
						</div>
					</div>
					
					<!-- <div id="tabs1-2">
							<div class="section type1" style="overflow-y:scroll;">
								<div class="controlBtns type2" GNBtn="gridList">
									<a href="#"><img src="/common/images/btn_first.png" alt="" /></a>
									<a href="#"><img src="/common/images/btn_prev.png" alt="" /></a>
									<a href="#"><img src="/common/images/btn_next.png" alt="" /></a>
									<a href="#"><img src="/common/images/btn_last.png" alt="" /></a>
								</div>
								<br/>
								<div class="searchInBox">
								<h2 class="tit" CL="STD_GENERAL">일반</h2>
									<table class="table type1">
										<colgroup>
											<col width="2%"/>
											<col width="26%"/>
											<col width="7%"/>
											<col width="25%"/>
											<col width="7%"/>
											<col width=""/>
										</colgroup>
										<tbody>
										<tr>
											<th CL='STD_WAREKY'>거점</th>
											<td colspan="3"><input type="text" name="WAREKY" readonly="readonly"/></td>
										</tr>
										<tr>
											<th CL='STD_AREAKY'>창고</th>
											<td colspan="3"><input type="text" name="AREAKY" readonly="readonly"/></td>
										</tr>
										<tr>
											<th CL='STD_AREATY'>창고유형</th>
											<td GCol="select,AREATY">
													<select CommonCombo="AREATY" name="AREATY" style="width: 170px"></select>
											</td>
										</tr>
										<tr>
											<th CL='STD_SHORTX'>설명</th>
											<td colspan="3"><input type="text" name="SHORTX"/></td>
										</tr>
										<tr>
											<th CL='STD_NEGSTK'>(-)허용</th> 
											<td colspan="3"><input type="checkbox" name="NEGSTK" value="V"/></td>
										</tr>
										<tr>
											<th CL='STD_INDCDO'>문서번호복사</th>
											<td colspan="3"><input type="checkbox" name="INDCDO" value="V"/></td>
										</tr>
										<tr>
											<th CL='STD_INDAES'>재고가산</th>
											<td colspan="3"><input type="checkbox" name="INDAES" value="V"/></td>
										</tr>
									</tbody>
									</table>
								</div>
							</div>
						</div> -->
										
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