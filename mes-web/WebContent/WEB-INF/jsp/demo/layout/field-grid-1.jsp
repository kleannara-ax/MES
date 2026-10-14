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
		setTopSize(1000);
	 	gridList.setGrid({
	    	id : "gridList",
			editable : true,
			pkcol : "SHLPKY,DBFILD",
			module : "System",
			command : "SHLPI",
			bindArea : "tabs1-2" 
	    }); 
	});
	
	function creatList(){
		flag = "I";
		
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			
			var json = netUtil.sendData({
				module : "System",
				command : "SHLPKYval",
				sendType : "map",
				param : param
			});
			
			if(json.data["CNT"] > 0) {
				commonUtil.msgBox("SYSTEM_M0035");
				return;
				
			}
			
			param.put("WIDTHW",0);
			param.put("HEIGHT",0);
			param.put("EXECTY",' ');
			param.put("SHORTX",' ');
			param.put("STARGO",' ');
			param.put("DWHERE",' ');
			
			dataBind.dataNameBind(param, "yh01top");
			gridList.resetGrid('gridList');
			
			uiList.setActive("Delete", false);
			searchOpen(false);
		}
	}
	
	function searchList(){
		flag = "U";
		//var param = dataBind.paramData("searchArea");
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");

			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
			
			netUtil.send({
				module : "System",
				command : "SHLPH",
				bindId : "yh01top",
				sendType : "map",
				bindType : "field",
				param : param
			}); 

			uiList.setActive("Delete", true);
		}
	}
	
	function saveData(){
		var gridCnt = gridList.getGridDataCount("gridList");
		var gridModifyCnt = gridList.getModifyRowCount('gridList');
		var indrvlCnt = 0 ;
		
		for(var i = 0 ; i < gridCnt ; i++){
			var indrvl = gridList.getColData("gridList", i, "INDRVL");
			var induls = gridList.getColData("gridList", i, "INDULS");
			
			if(indrvl == 'V'){
				indrvlCnt ++
			}
			
			if(indrvlCnt > 1){
				commonUtil.msgBox("SYSTEM_M0100");
				return;
			}
			if (indrvl == 'V' && induls != 'V'){
				commonUtil.msgBox("SYSTEM_M0101");
				return;
			}
		}
		
		if(gridCnt < 1){
			commonUtil.msgBox("SYSTEM_M0102");
			return;
		} 
		
		var list = dataBind.paramData("foldSect");
		
		if(gridModifyCnt >0 ){
			if(gridList.validationCheck("gridList", "modify")){
				var param = dataBind.paramData("searchArea");
				var json = gridList.gridSave({
			    	id : "gridList",
			    	param : param
			    });
				loadSearch();
			} 
		}else if(!confirm(commonUtil.getMsg(configData.MSG_MASTER_SAVE_CONFIRM))){
			return;
		}

		var param = new DataMap();
		
		param.put("list", list);
		param.put("flag", flag);
		var json = netUtil.sendData({
			url : "/wms/system/json/YHU01.data",
			param : param
		}); 
		
		if(json && json.data){
			if(gridModifyCnt < 1){
				commonUtil.msgBox("VALID_M0001");
			}
			searchList();
		}
	}
	
	function loadSearch(){
		var json = netUtil.sendData({
			url : "/common/search/json/reload.data"
		});
		if(json && json.data){
			
		}
	}
	
 	 function gridListEventColValueChange(gridId, rowNum, colName, colValue) {
 		 var induls=gridList.getColData(gridId, rowNum, "INDULS");
 		 var indrvl=gridList.getColData(gridId, rowNum, "INDRVL");
 		
		if(gridId == "gridList" && colName == "INDRVL" && indrvl=="V"){
			if(induls==" "){
				gridList.setColValue("gridList", rowNum, "INDRVL", " ");
			}
		}
		else if(gridId == "gridList" && colName == "INDRVL" && indrvl==" " && induls==" "){
			//alert("결과리스트필드가 아닙니다.");
			commonUtil.msgBox("SYSTEM_M0101");
			
		}else if (colName == "DDICKY") {
			if(colValue != ""){
				var param = inputList.setRangeParam("searchArea");
				
				param.put("DDICKY", colValue);
				
				var json = netUtil.sendData({
					module : "System",
					command : "DDICKYval",
					sendType : "map",
					param : param
				});
				
				if (json.data["CNT"] < 1) {
					commonUtil.msgBox("SYSTEM_M0124");
					
					gridList.setColValue("gridList", rowNum, "DDICKY", "");
					gridList.setFocus("gridList", "DDICKY");
				}
			}
		} 
	 } 
	 
	 
	function gridListEventRowAddBefore(gridId, rowNum){
		var param = inputList.setRangeParam("searchArea");
		var shlpky = param.get("SHLPKY");
		
		var newData = new DataMap();
		
		newData.put("SHLPKY", shlpky);

		return newData; 
	}
	

	function delData(){
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_DELETE_CONFIRM)){
			return;
		}
		var param = inputList.setRangeParam("searchArea");
		
		var json = netUtil.sendData({
			url : "/wms/system/json/delYH01.data",
			param : param
		});
	
		if (json && json.data) {
			commonUtil.msgBox("VALID_M0003");

			param.put("SHLPKY",' ')
			param.put("WIDTHW",0);
			param.put("HEIGHT",0);
			param.put("EXECTY",' ');
			param.put("SHORTX",' ');
			param.put("STARGO",' ');
			param.put("DWHERE",' ');
			
			dataBind.dataNameBind(param, "yh01top");
			gridList.resetGrid('gridList');
			
			searchOpen(true);
		}
	}
	
	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}else if(btnName == "Delete"){
			delData();
		}else if(btnName == "Create"){
			creatList();
		}else if(btnName == "Reload"){
			loadSearch();
		}
	}
</script>
</head>
<body>

<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY"></button>
		<button CB="Save SAVE STD_SAVE"></button>
		<button CB="Delete DELETE BTN_DELETE"></button>
		<button CB="Reload EXECUTE BTN_RELOAD"></button>
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
			<button CB="Create CREATE BTN_CREATE"></button>
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
					<col width="100" />
					<col />
				</colgroup>
				<tbody>
					<tr>
						<th CL="STD_SHLPKY,3">서치헬프</th>
						<td colspan="3">
							<input type="text" name="SHLPKY" UIInput="S,SHSHLPH" validate="required,SYSTEM_M0034"/>
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
						<table class="table type1" id="yh01top">
							<colgroup>
								<col />
								<col />
								<col />
								<col />
								<col />
								<col />
							</colgroup>
							<tbody>
								<tr>
									<th CL="STD_SHLPKY,3">서치헬프</th>
									<td>
										<input type="text" name="SHLPKY" readonly="readonly" />
									</td>
									<th CL="STD_EXECTY">실행타입</th>
									<td>
										<input type="checkbox" name="EXECTY" value="V"/>
									</td>
								</tr>
								<tr>
									<th CL="STD_STARGO">오브젝트검색</th>
									<td>
										<input type="text" name="STARGO" />
									</td>
								</tr>
								<tr>
									<th CL="STD_SHORTX">설명</th>
									<td>
										<input type="text" name="SHORTX" style="width: 500px"/>
									</td>
								</tr>
								<tr>
									<th CL="STD_DWHERE">설명</th>
									<td>
										<input type="text" name="DWHERE" style="width: 500px"/>
									</td>
								</tr>
								<tr>
									<th CL="STD_WIDTHW">가로</th>
									<td>
										<input type="text" name="WIDTHW" />
									</td>
									<th CL="STD_HEIGHT">높이</th>
									<td>
										<input type="text" name="HEIGHT" />
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				  </div>
				</div>
			</div>
			
			<!-- BOTTOM FieldSet -->
			<div class="bottomSect" style="top:200px;">
				<button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button>
				<div class="tabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span CL='STD_ITEM'>탭메뉴1</span></a></li>
						<li><a href="#tabs1-2"><span CL='STD_DETAIL'>탭메뉴1</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
											<col width="250" />
											<col width="120" />
											<col width="120" />
											<col width="90" />
											<col width="110" />
											<col width="90" />
											<col width="90"/>
											<col width="100" />
											<col width="120" />
											<col width="90" />
											<col width="150" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_SHLPKY,3'>번호</th>
												<th CL='STD_DBFILD'>DB 필드이름</th>
												<th CL='STD_DDICKY'>DB 필드 사전 키</th>
												<th CL='STD_INDUSO,2'>검색필드</th>
												<th CL='STD_POSSOS,2'>Pos.(Search)</th>
												<th CL='STD_INDNED,2'>입력불가</th>
												<th CL='STD_RQFLDS,2'>검색필수</th>
												<th CL='STD_INDULS,2'>결과 리스트</th>
												<th CL='STD_POSLIS,2'>Pos.(list)</th>
												<th CL='STD_INDRVL'>반환필드</th>
												<th CL='STD_DFVSOS,2'>기본값</th>
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="250" />
											<col width="120" />
											<col width="120" />
											<col width="90" />
											<col width="110" />
											<col width="90" />
											<col width="90"/>
											<col width="100" />
											<col width="120" />
											<col width="90" />
											<col width="150" />
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GCol="input,SHLPKY" GF="S 10" validate="required"></td>
												<td GCol="input,DBFILD" GF="S 20" validate="required"></td>
												<td GCol="input,DDICKY" GF="S 20"></td>
												<td GCol="check,INDUSO"></td>
												<td GCol="input,POSSOS" GF="S 3"></td>
												<td GCol="check,INDNED"></td>
												<td GCol="check,RQFLDS"></td>
												<td GCol="check,INDULS"></td>
												<td GCol="input,POSLIS" GF="S 3"></td>
												<td GCol="check,INDRVL"></td>
												<td GCol="input,DFVSOS" GF="S 60"></td>
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
									<p class="record"></p>
								</div>
							</div>
						</div>
					</div>
					<div id="tabs1-2">
						<div class="section type1">
							<div class="controlBtns type2"  GNBtn="gridList">
								<a href="#"><img src="/common/images/btn_first.png" alt="" /></a>
								<a href="#"><img src="/common/images/btn_prev.png" alt="" /></a>
								<a href="#"><img src="/common/images/btn_next.png" alt="" /></a>
								<a href="#"><img src="/common/images/btn_last.png" alt="" /></a>
							</div>
							<br/>
							<div class="searchInBox">
							<h2 class="tit" CL="STD_SELECTOPTIONS">검색조건</h2>
								<table class="table type1">
									<colgroup>
										<col />
										<col />
										<col />
										<col />
									</colgroup>
									<tbody>
										<tr>
											<th CL="STD_DBFILD">DB 필드 이용</th>
											<td>
												<input type="text" name="DBFILD" readonly="readonly"/>
											</td>
										</tr>
										<tr>
											<th CL="STD_INDUSO,2">서치옵션에서 사용하는 필드</th>
											<td>
												<label for="CHK_INDUSO"><input type="checkbox" name="INDUSO" id="CHK_INDUSO" value="V"/>choice</label>
											</td>
											<th CL="STD_INDULS,2">리스트에서 사용하는 필드</th>
											<td>
												<label for="CHK_INDULS"><input type="checkbox" name="INDULS" id="CHK_INDULS" value="V"/>choice</label>
											</td>
										</tr>
										<tr>
											<th CL="STD_POSSOS,2">position in search option screen</th>
											<td>
												<input type="text" name="POSSOS" />
											</td>
											<th CL="STD_POSLIS,2">position in list screen</th>
											<td>
												<input type="text" name="POSLIS" />
											</td>
										</tr>
										<tr>
											<th CL="STD_INDNED,2">서치옵션에서 수정 불가</th>
											<td>
												<label for="CHK_INDNED"><input type="checkbox" name="INDNED" id="CHK_INDNED" value="V"/>choice</label>
											</td>
											<th CL="STD_INDRVL">반환 필드</th>
											<td>
												<label for="CHK_INDRVL"><input type="checkbox" name="INDRVL" id="CHK_INDRVL" value="V"/>choice</label>
											</td>
										</tr>
										<tr>
											<th CL="STD_RQFLDS,2">서치옵션에서 수정 불가</th>
											<td>
												<label for="CHK_RQFLDS"><input type="checkbox" name="RQFLDS" id="CHK_RQFLDS" value="V" />choice</label>
											</td>
											<th CL="STD_DFVSOS,2">서치화면에서 기본 값</th>
											<td>
												<input type="text" name="DFVSOS" />
											</td>
										</tr>
									</tbody>
								</table>
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