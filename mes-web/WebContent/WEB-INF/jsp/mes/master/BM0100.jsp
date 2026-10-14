<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/head.jsp"%>
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
	    	name : "gridList",
			editable : true,
			pkcol : "PLANT,MATCODE",
			module : "WmsAdmin",
			command : "BM01",
			bindArea : "tabs1-2" 
	    });
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
			//검색조건을 pram에 추가
			var param = dataBind.paramData("searchArea");
			//그리드의 수정사항(추가)을 list에 저장
			var list = gridList.getModifyData("gridList", "A");
			
			//저장확인 메세지 -> 저장하시겠습니까?
			if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
				return;
			}
			
			var param = new DataMap();
			param.put("list", list);
			
			var json = netUtil.send({
				url : "/mes/master/json/saveBM01.data",
				param : param,
				returnParam : param,
				successFunction : "saveEnd",
				failFunction : "saveFail"
			});
			
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
		// var areatyt = inputList.getComboData("AREATY", "STOR");
		var newData = new DataMap();
		<%--newData.put("WAREKY",  "<%=wareky%>");--%>
		<%--//newData.put("AREAKY", "RECV");--%>
		<%--newData.put("AREATY", "STOR");--%>
		<%--newData.put("AREATYT", areatyt);--%>
		
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

			if (json && json.data) {
				if (json.data["CNT"] >= 1) {
					commonUtil.msgBox("VALID_M0017");//구역이 존재하는 영역을 삭제할 수 없습니다.
					return false;
				} else if (json.data["CNT"] == 0) {
					return true;
				}
			}
		}
	}

	//미사용여부 확인 에러 발생시 주석해제 22.02.18
	/* function areakyCheck(valueTxt, $colObj){
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
	} */

	function commonBtnClick(btnName) {
		if (btnName == "Search") {
			searchList();
		} else if (btnName == "Save") {
			saveData();
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
				<!-- <button CB="GetVariant GETVARIANT BTN_GETVARIANT"></button> -->
				<!-- <button CB="SaveVariant SAVEVARIANT BTN_SAVEVARIANT"></button> -->
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
							<th CL="STD_PLANT">플랜트</th>
							<td><input type="text" name="PLANT" value="100" id="PLANT"
								readonly="readonly" /></td>
						</tr>
						<tr>
							<th CL="STD_ITEMCODE">품목코드</th>
							<td><input type="text" name="ITEMCODE" UIInput="R,MATKY"
								id="ITEMCODE" /></td>
						</tr>
						<tr>
							<th CL="STD_ITEMNAME">품목명</th>
							<td><input type="text" name="ITEMNAME" id="ITEMNAME" /></td>
						</tr>
						<!-- 	<tr>
						<th CL="STD_AREAKY">품목유형</th>
						<td>
							<input type="text" name="AREAKY" UIInput="R,SHAREMA" id="AREAKY"/>
						</td>
					</tr> -->
						<tr>
							<th CL="STD_ITEMTYPE">품목유형</th>
							<td GCol="select,AREATY"><select CommonCombo="MATTYPE"
								name="MATTYPE">
									<option value="">All</option>
							</select></td>
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
							<li><a href="#tabs1-2"><span CL='STD_DETAIL'>탭메뉴2</span></a></li>
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
													<th CL='STD_MANDT'></th>
													<th CL='STD_PLANT'></th>
													<th CL='STD_MATCODE'></th>
													<th CL='STD_MATNAME'></th>
													<th CL='STD_MATFULLNAME'></th>
													<th CL='STD_MATSPEC'></th>
													<th CL='STD_BUNIT'></th>
													<th CL='STD_PTYPE'></th>
													<th CL='STD_MATTYPE'></th>

													<th CL='STD_MATGROUP'></th>
													<th CL='STD_GWT'></th>
													<th CL='STD_NWT'></th>
													<th CL='STD_WUNIT'></th>
													<th CL='STD_LOWCODE'></th>
													<th CL='STD_GMATGROUP'></th>
													<th CL='STD_EXMFLAG'></th>
													<th CL='STD_EXLFLAG'></th>
													<th CL='STD_IMPORTFLAG'></th>
													<th CL='STD_INVENTORYFLAG'></th>

													<th CL='STD_LOTFLAG'></th>
													<th CL='STD_EXPORTFLAG'></th>
													<th CL='STD_WIDTH'></th>
													<th CL='STD_LENGTH'></th>
													<th CL='STD_MATWHCODE'></th>
													<th CL='STD_OPWHCODE'></th>

													<th CL='STD_CREDAT'></th>
													<th CL='STD_CRETIM'></th>
													<th CL='STD_CREUSR'></th>
													<th CL='STD_CUSRNM'></th>
													<th CL='STD_LMODAT'></th>
													<th CL='STD_LMOTIM'></th>
													<th CL='STD_LMOUSR'></th>
													<th CL='STD_LUSRNM'></th>
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
											<tbody id="gridList">
												<tr CGRow="true">
													<td GCol="rownum">1</td>
													<td GCol="text,MANDT"></td>
													<td GCol="text,PLANT"></td>
													<td GCol="input,MATCODE,MATKT" id="MATCODE"
														validate="required"></td>
													<td GCol="input,MATNAME" GF="S 60"></td>
													<td GCol="input,MATFULLNAME" GF="S 60"></td>
													<td GCol="input,MATSPEC" GF="S 60"></td>
													<td GCol="input,BUNIT" GF="S 60"></td>
													<td GCol="input,PTYPE" GF="S 60"></td>
													<td GCol="input,MATTYPE" GF="S 60"></td>

													<td GCol="input,MATGROUP" GF="S 60"></td>
													<td GCol="input,GWT" GF="S 60"></td>
													<td GCol="input,NWT" GF="S 60"></td>
													<td GCol="input,WUNIT" GF="S 60"></td>
													<td GCol="input,LOWCODE" GF="S 60"></td>
													<td GCol="input,GMATGROUP" GF="S 60"></td>
													<td GCol="input,EXMFLAG" GF="S 60"></td>
													<td GCol="input,EXLFLAG" GF="S 60"></td>
													<td GCol="input,IMPORTFLAG" GF="S 60"></td>
													<td GCol="input,INVENTORYFLAG" GF="S 60"></td>

													<td GCol="input,LOTFLAG" GF="S 60"></td>
													<td GCol="input,EXPORTFLAG" GF="S 60"></td>
													<td GCol="input,WIDTH" GF="S 60"></td>
													<td GCol="input,LENGTH" GF="S 60"></td>
													<td GCol="input,MATWHCODE" GF="S 60"></td>
													<td GCol="input,OPWHCODE" GF="S 60"></td>

													<td GCol="text,CREDAT" GF="D"></td>
													<td GCol="text,CRETIM" GF="T"></td>
													<td GCol="text,CREUSR"></td>
													<td GCol="text,CUSRNM"></td>
													<td GCol="text,LMODAT" GF="D"></td>
													<td GCol="text,LMOTIM" GF="T"></td>
													<td GCol="text,LMOUSR"></td>
													<td GCol="text,LUSRNM"></td>
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
	<%@ include file="/common/include/bottom.jsp"%>
</body>
</html>