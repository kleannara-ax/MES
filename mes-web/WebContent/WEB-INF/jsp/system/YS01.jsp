
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript">

	var flag = "U";
	$(document).ready(function(){
	
	});
	
	function searchList(){
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

	
	function creatList(){
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
				url : "/wms/system/json/YS01.data",
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
			url : "/wms/system/json/delYS01.data",
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
	<div class="util3">
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
			<button CB="Create CREATE BTN_CREATE"></button>
			<button CB="Search SEARCH BTN_DISPLAY"></button>
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
						<th CL="STD_SQLKEY">SQL 키</th>
						<td>
							<input type="text" name="SQLKEY"  UIInput="S,SHJQMAP" validate="required,MASTER_M0685" />
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
	<div class="innerContainer" id="content">

		<!-- contentContainer -->
		<div class="contentContainer">

			<div class="bottomSect type1">
				<div class="tabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span CL='STD_GENERAL'>일반</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="searchInBox">
								<table class="table type1">
									<colgroup>
										<col width="7%"/>
										<col width="93%"/>
									</colgroup>
									<tbody id="test1">
										<tr>
											<th CL="STD_SQLKEY">SQL 키</th>
											<td>
												<input type="text" name="SQLKEY" size="100" readonly="readonly"/>
											</td>
										</tr>
										<tr>
											<th CL='STD_DESC'>설명</th>
											<td>
												<input type="text" name="SQLDSC" size="100"/>
											</td>
										</tr>
										<!-- tr>
											<th CL='STD_SQLTYP'>SQL 타입</th>
											<td>
												<input type="radio" name="SQLTYP" value="1" />EJB QL
												<input type="radio" name="SQLTYP" value="I"  />Native SQL
											</td>
										</tr-->
										<tr>
											<th CL='STD_DBMSTY'>DBMS 유형</th>
											<td>
												<input type="radio" name="DBMSTY" value="1"/>Oracle
												<!-- <input type="radio" name="DBMSTY" value="2"/>SQL Server -->
											</td>
										</tr>
										<tr>
											<th CL='STD_SQLSTA'>SQL 문장</th>
										</tr>
										<tr>
											<th colspan="2"><textarea rows="30" cols="195" name="SQLSTA" validate="required"></textarea></th>
										</tr>
									</tbody>
								</table>
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