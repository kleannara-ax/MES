<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/head.jsp"%>
<script type="text/javascript">

	$(document).ready(function() { 
		gridList.setGrid({
			id : "gridList",
			editable : true,
			pkcol : "USERID",
			module : "System",
			command : "USER",
			bindArea : "tabs1-2",
			validation : "UROLKY,MENUKY"
		});
		
		gridList.setReadOnly("gridList", true, ["USERG5"]);
	}); 

	function searchList() {
		//var param = dataBind.paramData("searchArea");
	
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			//alert(param);
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
		$('.tabs').tabs("option","active",0);
	}

	function saveData() {
		if(gridList.validationCheck("gridList", "modify")){
			//var list = gridList.getModifyList("gridList");
			var list = gridList.getModifyData("gridList", "A");
			/*
			var param = dataBind.paramData("searchArea");
			var paramR = new DataMap();
			paramR.put("list", list);
			*/
			/*
			var json = gridList.gridSave({
			    id : "gridList",
			    param : param
			});
			   
			if(json && json.data){
				json = netUtil.sendData({
				url : "/wms/system/json/UI01.data",
					param : paramR
				});
				searchList();		
			}
			*/
			/*
			json = netUtil.sendData({
			url : "/wms/system/json/UI01.data",
				param : paramR,
				returnParam : paramR,
				successFunction : "saveEnd",
				failFunction : "saveFail"
			});
			*/
			var param = new DataMap();
			param.put("list", list);
			
			var json = netUtil.send({
				url : "/wms/system/json/UI01.data",
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
				//alert("비밀번호가 초기화 되었습니다.");
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
	
	
	function gridListEventRowAddAfter(gridId, rowNum){
		if(gridId == "gridList") {
			gridList.setColValue(gridId, rowNum, "NATNKY", "KR");
		}
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId=="gridList" && colName=="UROLKY"){
			if(colValue != ""){
				var param = new DataMap();
				param.put("UROLKY",colValue);
				var json = netUtil.sendData({
					module : "System",
					command : "UROval",
					sendType : "map",
					param : param
				});
				
			 if(json.data["CNT"] < 1){
					commonUtil.msgBox("SYSTEM_M0086", colValue);
					gridList.setColValue("gridList", rowNum, "UROLKY", "");
				}
			}
			
		}else if(gridId=="gridList" && colName=="USERID"){
			if(colValue != ""){
				var param = new DataMap();
				param.put("USERID",colValue);
				var json = netUtil.sendData({
					module : "System",
					command : "USERval",
					sendType : "map",
					param : param
				});
				if(json.data["CNT"]>0){
					commonUtil.msgBox("SYSTEM_M0055", colValue);
					gridList.setColValue("gridList", rowNum, "USERID", "");
				}
			}
		}
	}
	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			var param = new DataMap();
			param.put("PROGID", "<%=menuId%>");
			param.put("LGTYPE", "SEARCH");
			var json = netUtil.sendData({
				url : "/mes/system/json/saveLog.data",
				param : param
			});

			searchList();
		} else if (btnName == "Save") {
			saveData();
		} else if (btnName == "Pwreset") {
			pwReset();
		}
	}

	function checkPv(colValue, rowNum, colName) {
		var rowData = gridList.getRowData("gridList", rowNum);
		if (rowData.get("USERG1") == "PV" && $.trim(colValue) == "") {
			gridList.setColFocus("gridList", rowNum, colName);
			return false;
		}
		return true;
	}

	function pwReset() {
		//if(gridList.validationCheck("gridList", "select")){
		var chkList = gridList.getSelectRowNumList("gridList");

		if (chkList.length < 1) {
			alert("선택된 데이터가 없습니다.");
			return;
		} else {
			var chkGrid = gridList.getSelectData("gridList");
			var param = new DataMap();
			param.put("list", chkGrid);

			var json = netUtil.send({
				url : "/wms/system/json/initPwUI01.data",
				param : param,
				returnParam : param,
				successFunction : "pwResetEnd",
				failFunction : "pwResetFail"
			});

			//alert("비밀번호가 초기화 되었습니다.");
			//searchList();
		}
		//}
	}

	function pwResetEnd(json, param) {

		if (json && json.data) {
			if (json.data != "0") {
				alert("비밀번호가 초기화 되었습니다.");
			} else {
				alert(commonUtil.getMsg("COMMON_M0465")); // 저장 실패하였습니다.
			}
			searchList();
		} else {
			alert(commonUtil.getMsg("COMMON_M0465")); // 저장 실패하였습니다.
			searchList();
		}
	}

	function pwResetFail(a, b, c, param) { // a:request, b:status, c:error
		var resultText = a.responseText.trim();
		alert(commonUtil.getMsg("COMMON_M0465")); // 저장 실패하였습니다.
		searchList();
	}
</script>
</head>
<body>
	<div class="contentHeader">
		<div class="util">
			<button CB="Search SEARCH BTN_DISPLAY"></button>
			<button CB="Save SAVE STD_SAVE "></button>
			<!-- <button CB="Pwreset SAVE BTN_PWRESET"></button> -->
		</div>
	</div>
	<div class="util2">
		<button class="button type2" id="showPop" type="button">
			<img src="/common/images/ico_btn4.png" alt="List" />
		</button>
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
							<th CL="STD_USERID">사용자 ID</th>
							<td><input type="text" name="U.USERID" UIInput="R,SHUSRMA" /></td>
						</tr>
						<tr>
							<th CL="STD_NMLAST">이름</th>
							<td><input type="text" name="NMLAST" UIInput="R" /></td>
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
											</colgroup>
											<thead>
												<tr>
													<th CL='STD_NUMBER'>번호</th>
													<th CL='STD_PLANT'></th>
													<th CL='STD_USERID'></th>
													<th CL='STD_USERNAME'></th>
													<th CL='STD_DEPTCODE'></th>
													<th CL='STD_DEPTNAME'></th>
													<th CL='STD_WORKGROUP'></th>
													<th CL='STD_TELNO'></th>

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
											</colgroup>
											<tbody id="gridList">
												<tr CGRow="true">
													<td GCol="rownum">1</td>
													<td GCol="text,PLANT"></td>
													<td GCol="input,USERID,MATKT" id="USERID"
														validate="required"></td>
													<td GCol="input,USERNAME" GF="S 60"></td>
													<td GCol="input,DEPTCODE,MATKT" id="DEPTCODE"
														validate="required"></td>
													<td GCol="input,DEPTNAME" GF="S 60"></td>
													<td GCol="input,WORKGROUP" GF="S 60"></td>
													<td GCol="input,TELNO" GF="S 60"></td>

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