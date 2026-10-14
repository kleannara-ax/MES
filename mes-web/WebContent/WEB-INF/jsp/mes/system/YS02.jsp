<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript">
	
	$(document).ready(function(){
		setTopSize(440);
		
		gridList.setGrid({
			id : "gridList",
			module : "System",
			command : "YS02"
		});
		
		searchOpen(false); // 프로그램 동작시 서치화면을 보여줌
// 		searchOpen(true);  // 프로그램 동작시 메인화면을 보여줌
	});
	
	function commonBtnClick(btnName) {
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if (btnName == "Search") {
			searchList();
		} else if (btnName == "Save") {
			saveData();
		} else if (btnName == "Delete") {
			delData();
		} else if (btnName == "Create") {
			creatList();
		} else if (btnName == "Reload") {
			loadSql();
		} else if (btnName == "Test") {
			testSql();
		} else if (btnName == "View") {
			viewSqlXml();
		}
	}
	
	function searchList() {
		flag = "U";
		//var param = dataBind.paramData("searchArea");
		if (validate.check("searchArea")) {
			var param = inputList.setRangeParam("searchArea");
	
			var json = netUtil.sendData({
				module : "System",
				command : "YS01",
				sendType : "map",
				param : param
			});
	
			if (json && json.data) {
				dataBind.dataNameBind(json.data, "content");
				uiList.setActive("Delete", true);
				searchOpen(false);
			}else{
				commonUtil.msgBox(configData.MSG_MASTER_ROWEMPTY);
			}
		}
	}
	
	
	function creatList() {
		flag = "I";
		if (validate.check("searchArea")) {
			var param = inputList.setRangeParam("searchArea");
			var sqlkey = param.get("SQLKEY");
			
			var json = netUtil.sendData({
				module : "System",
				command : "SQLKEYCnt",
				sendType : "map",
				param : param
			});
			
			if (json.data["CNT"] > 0) {
				alert(commonUtil.getMsg("MASTER_M0025", sqlkey));
				return;
			}
			
			var param = new DataMap();
			param.put("SQLKEY", sqlkey);
			param.put("SQLTYP", 'I');
			param.put("DBMSTY", 1);
			param.put("SQLSTA", "");
			param.put("SQLDSC", "");
			
			dataBind.dataNameBind(param, "content");
			
			uiList.setActive("Delete", false);
			searchOpen(false);
		}
	}
	
	function saveData() {
		if (validate.check("content")) {
			if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
				return;
			}
			
			var param = dataBind.paramData("content");
			
			if(param.get("SQLSTA").indexOf(param.get("SQLKEY")) == -1){
				alert("sql key 가 sql 문장에 존재하지 않습니다.");
			}
			
			param.put("SQLTYP","I");
			param.put("flag", flag);
			var sqlkey = param.get("SQLKEY");
			
			var json = netUtil.sendData({
				url : "/mes/system/json/YS01.data",
				param : param
			});
			
			if (json && json.data) {
				commonUtil.msgBox("HHT_T0008");
				searchList();
			}else{
				alert(commonUtil.getMsg("MASTER_M0025", sqlkey));
				searchOpen(true);
			}
		}
	}
	function delData(){
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_DELETE_CONFIRM)){
			return;
		}
		var param = dataBind.paramData("content");
		
		var json = netUtil.sendData({
			url : "/mes/system/json/delYS01.data",
			param : param
		});
		
		if (json && json.data) {
			commonUtil.msgBox("VALID_M0003");
			searchOpen(true);
		}
	}
	
	function loadSql(){
		var json = netUtil.sendData({
			url : "/common/sql/json/reload.data"
		});
		if(json && json.data){
		}
	}
	
	function testSql(){
		if (validate.check("content")) {
			var param = dataBind.paramData("content");
			
			var sqlParam = new DataMap();
			sqlParam.put(param.get("SQLKEY"), param.get("SQLSTA"));
			
			var json = netUtil.sendData({
				url : "/common/sql/json/test.data",
				param : sqlParam
			});
			if(json && json.data){
				
			}
		}
	}
	
	function viewSqlXml(){
		if (validate.check("content")) {
			var param = dataBind.paramData("content");
			var json = netUtil.sendData({
				url : "/common/sql/json/viewSqlXml.data",
				param : param
			});
			if(json && json.data){
				commonUtil.popupOpen("/common/lang/view.xml", "500", "500");
			}
		}
	}
	
	function checkBoxLabelClick(id){
		var isCheck = $("input:checkbox[id='" + id + "']").prop("checked");
		if(!isCheck)
			$("input:checkbox[id='" + id + "']").prop("checked", true);
		else
			$("input:checkbox[id='" + id + "']").prop("checked", false);
	}
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="View EXECUTE BTN_PREVIEW"></button>
		<button CB="Save SAVE STD_SAVE"></button>
		<button CB="Delete DELETE BTN_DELETE"></button>
		<button CB="Reload EXECUTE BTN_RELOAD"></button>
		<button CB="Test EXECUTE BTN_TEST"></button>
	</div>
<!-- 	<div class="util3"> -->
<!-- 		<button class="button type2" id="showPop" type="button"> -->
<!-- 			<img src="/common/images/ico_btn4.png" alt="List" /> -->
<!-- 		</button> -->
<!-- 	</div> -->
</div>

<!-- searchPop -->
<div class="searchPop" id="searchArea">
	<button type="button" class="closer">X</button>
	<div class="searchInnerContainer">
<!-- 		<p class="util"> -->
<!-- 			<button CB="Create CREATE BTN_CREATE"></button> -->
<!-- 			<button CB="Search SEARCH BTN_DISPLAY"></button> -->
<!-- 		</p> -->
<!-- 		<div class="searchInBox"> -->
<!-- 			<h2 class="tit" CL="STD_SELECTOPTIONS">검색조건</h2> -->
<!-- 			<table class="table type1"> -->
<!-- 				<colgroup> -->
<!-- 					<col width="100" /> -->
<!-- 					<col /> -->
<!-- 				</colgroup> -->
<!-- 				<tbody> -->
<!-- 					<tr> -->
<!-- 						<th CL="STD_SQLKEY">SQL 키</th> -->
<!-- 						<td> -->
<!-- 							<input type="text" name="SQLKEY"  UIInput="S,SHJQMAP" validate="required,MASTER_M0685" /> -->
<!-- 						</td> -->
<!-- 					</tr> -->
<!-- 				</tbody> -->
<!-- 			</table> -->
<!-- 		</div> -->
	</div>
</div>
<!-- //searchPop -->

<!-- content -->
<div class="content">
	<div class="innerContainer" id="content">
		
		<!-- contentContainer -->
		<div class="contentContainer">
			
			<div class="bottomSect top">
				<div class="tabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span CL='STD_GENERAL'>일반</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="searchInBox">
								<h2 class="tit">데이터 싱크 DB 정보</h2>
								<table class="table type1">
									<colgroup>
										<col width="10%"/>
										<col width="40%"/>
										<col width="10%"/>
										<col width="40%"/>
									</colgroup>
									<tbody id="DBINFO">
										<tr>
											<th style="font-Weight:bold; color:red;">DB_1</th>
											<td>
												<input type="text" name="DB1_TARGER" size="30"/>
											</td>
											<th style="font-Weight:bold; color:blue;">DB_2</th>
											<td>
												<input type="text" name="DB2_TARGER" size="30"/>
											</td>
										</tr>
										<tr>
											<th>IP</th>
											<td>
												<input type="text" name="DB1_IP" size="30" readonly="readonly"/>
											</td>
											<th>IP</th>
											<td>
												<input type="text" name="DB2_IP" size="30" readonly="readonly"/>
											</td>
										</tr>
										<tr>
											<th>PORT</th>
											<td>
												<input type="text" name="DB1_PORT" size="30" readonly="readonly"/>
											</td>
											<th>PORT</th>
											<td>
												<input type="text" name="DB2_PORT" size="30" readonly="readonly"/>
											</td>
										</tr>
										<tr>
											<th>Service Name (SID)</th>
											<td>
												<input type="text" name="DB1_SID" size="30" readonly="readonly"/>
											</td>
											<th>Service Name (SID)</th>
											<td>
												<input type="text" name="DB2_SID" size="30" readonly="readonly"/>
											</td>
										</tr>
										<tr>
											<th>ID</th>
											<td>
												<input type="text" name="DB1_ID" size="30"/>
											</td>
											<th>ID</th>
											<td>
												<input type="text" name="DB2_ID" size="30"/>
											</td>
										</tr>
										<tr>
											<th>PW</th>
											<td>
												<input type="text" name="DB1_PW" size="30"/>
											</td>
											<th>PW</th>
											<td>
												<input type="text" name="DB2_PW" size="30"/>
											</td>
										</tr>
										<tr>
											<th>DB 연결 테스트</th>
											<td>
												<input type="button" name="DB1_CONN_TEST" value="테스트"/>
												<input type="text" name="DB1_CONN_TEST_RESULT" size="30" readonly="readonly"/>
											</td>
											<th>DB 연결 테스트</th>
											<td>
												<input type="button" name="DB2_CONN_TEST" value="테스트"/>
												<input type="text" name="DB2_CONN_TEST_RESULT" size="30" readonly="readonly"/>
											</td>
										</tr>
									</tbody>
								</table>
								
								<br><br><br>
								
								<h2 class="tit">데이터 싱크 DB 정보</h2>
								<table class="table type1">
									<colgroup>
										<col width="10%"/>
										<col width="90%"/>
									</colgroup>
									<tbody id="DBINFO">
										<tr>
											<th>싱크 데이터 대상 테이블</th>
											<td>
												<input type="text" name="DB1" size="30"/>
											</td>
										</tr>
										<tr>
											<th>조회유형</th>
											<td colspan="3">
												<input type="checkbox" id="dataType1" name="STAT01" value="V" checked="checked"/>
												<label onClick="checkBoxLabelClick('dataType1');">DB_1 신규데이터</label>
												&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
												<input type="checkbox" id="dataType2" name="STAT02" value="V" checked="checked"/>
												<label onClick="checkBoxLabelClick('dataType2');">DB_2 신규데이터</label>
												&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
												<input type="checkbox" id="dataType3" name="STAT03" value="V" checked="checked"/>
												<label onClick="checkBoxLabelClick('dataType3');">차이 데이터</label>
<!-- 												<input type="radio" name="DBMSTY" value="1"/>DB_1 신규데이터 -->
<!-- 												<input type="radio" name="DBMSTY" value="2"/>DB_2 신규데이터 -->
<!-- 												<input type="radio" name="DBMSTY" value="3"/>차이 데이터 -->
											</td>
										</tr>
									</tbody>
								</table>
							</div>
						</div>
					</div>
				</div>
			</div>
			
			<div class="bottomSect bottom" style="">
				<div class="tabs">
					<ul class="tab type2" id="commonMiddleArea">
						<li><a href="#tabs2-1"><span>데이터 비교 결과</span></a></li>
					</ul>
					<div id="tabs2-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableBody">
									<table>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GH="40 STD_NUMBER"  GCol="rownum">1</td>
												<td GH="40" GCol="rowCheck"></td>
												
												
												
												<td GH="100 STD_SVBELN" GCol="text,SKUKEY"></td>
												<td GH="100 STD_SVBELN" GCol="input,QTYRCV" GF="N 20" validate="required max(GRID_COL_QTYRCV1_*),IN_M0078"></td>
												<td GH="100 STD_SVBELN" GCol="select,LOTA06">
													<select CommonCombo="LOTA06">
													</select>
												</td>
												
												
												
												<td GH="100 STD_CREDAT" GCol="text,CREDAT"  GF="D"></td>
												<td GH="100 STD_CRETIM" GCol="text,CRETIM"  GF="T"></td>
												<td GH="100 STD_CREUSR" GCol="text,CREUSR"></td>
												<td GH="100 STD_CUSRNM" GCol="text,CUSRNM"></td>
												<td GH="100 STD_LMODAT" GCol="text,LMODAT"  GF="D"></td>
												<td GH="100 STD_LMOTIM" GCol="text,LMOTIM"  GF="T"></td>
												<td GH="100 STD_LMOUSR" GCol="text,LMOUSR"></td>
												<td GH="100 STD_LUSRNM" GCol="text,LUSRNM"></td>
											</tr>
										</tbody>
									</table>
								</div>
							</div>
							<div class="tableUtil">
								<div class="leftArea">
									<button type="button" GBtn="find"></button>
									<button type="button" GBtn="sortReset"></button>
<!-- 									<button type="button" GBtn="copy"></button> -->
<!-- 									<button type="button" GBtn="add"></button> -->
<!-- 									<button type="button" GBtn="delete"></button> -->
<!-- 									<button type="button" GBtn="layout"></button> -->
<!-- 									<button type="button" GBtn="total"></button> -->
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
			
		<!-- //contentContainer -->
		</div>
		
	</div>
</div>
<!-- //content -->
<%@ include file="/common/include/bottom.jsp"%>
</body>
</html>