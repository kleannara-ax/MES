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
			editable : true,
			pkcol : "LANGKY,LABLGR,LABLKY",
			module : "System",
			command : "LABEL"
	    });
	});
	
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
		var modCnt = gridList.getModifyRowCount("gridList");
		
		if(modCnt == 0){
			commonUtil.msgBox("MASTER_M0545");
			return;
		}
		
		if(gridList.validationCheck("gridList", "modify")){
			var param = dataBind.paramData("searchArea");
			
			var json = gridList.gridSave({
		    	id : "gridList",
		    	param : param
		    });
			
			//alert(json);
			if(json && json.data){
				//loadLabel();
				searchList();
			}	
		}
	}
	
	function loadLabel(){
		
		netUtil.send({
			url : "/common/label/json/reload.data",
			failFunction : "",
			successFunction : "saveDataCallBack"
		});
		
	}
	
	function saveDataCallBack(json, returnParam){
		
	}
	
	function gridListEventRowAddBefore(gridId, rowNum){
		var param = inputList.setRangeParam("searchArea");
		var langky = param.get("LANGKY");
		
		var newData = new DataMap();
		newData.put("LANGKY", langky);
		
		return newData;
	}
	
	function lablkyCheck(valueTxt, $colObj){
		var rowNum = gridList.getColObjRowNum("gridList", $colObj);
		var rowCount = gridList.getGridDataCount("gridList");
		for(var i=0;i<rowCount;i++){
			if(i != rowNum){
				var lablky = gridList.getColData("gridList", i, "LABLKY");
				if(lablky == valueTxt){
					return false;
				}
			}			
		}
		
		return true;
	}
	
	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}else if(btnName == "Reload"){
			loadLabel();
		}
	}
	
	/* function searchHelpEventOpenBefore(searchCode, gridType){
		var param = new DataMap();
		if(searchCode == "SHLBLLK"){
			param.put("LANGKY", "");
		}else if(searchCode == "SHLBLGR"){
			
		}else if(searchCode == "SHLBLKY"){
			param.put("LANGKY", $("[name=LANGKY]").val());
		}
		return param;
	} */	
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY"></button>
		<button CB="Save SAVE STD_SAVE"></button>
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
						<th CL="STD_LANGKY">언어</th>
						<td>
							<input type="text" name="LANGKY" UIInput="S,SHLBLLK" value="<%=langky%>"  /> <!-- validate="required,SYSTEM_M0014"  -->
						</td>
					</tr>
					<tr>
						<th CL="STD_LABLGR">라벨 그룹</th>
						<td>
							<input type="text" name="LABLGR" UIInput="R,SHLBLGR" />
						</td>
					</tr>
					<tr>
						<th CL="STD_LABLKY">라벨 키</th>
						<td>
							<input type="text" name="LABLKY" UIInput="R,SHLBLKY" />
						</td>
					</tr>
					<tr>
						<th CL="STD_LBLTXS">라벨명(S)</th>
						<td>
							<input type="text" name="LBLTXS" UIInput="R" />
						</td>
					</tr>
					<tr>
						<th CL="STD_LBLTXM">라벨명(M)</th>
						<td>
							<input type="text" name="LBLTXM" UIInput="R" />
						</td>
					</tr>
					<tr>
						<th CL="STD_LBLTXL">라벨명(L)</th>
						<td>
							<input type="text" name="LBLTXL" UIInput="R" />
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
											<!-- <col width="40" /> -->
											<col width="40" /> 
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
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<!-- <th id="gridListCheckHead"></th> -->
												<th CL='STD_LANGKY'>언어</th>
												<th CL='STD_LABLGR'>라벨그룹</th>
												<th CL='STD_LABLKY'>라벨 키</th>
												<th CL='STD_LBLTXS'>라벨명(S)</th>
												<th CL='STD_LBLTXM'>라벨명(M)</th>
												<th CL='STD_LBLTXL'>라벨명(L)</th>
												<th CL='STD_CREDAT'>생성일자</th>
												<th CL='STD_CRETIM'>생성시간</th>
												<th CL='STD_CREUSR'>생성자</th>
												<th CL='STD_LMODAT'>수정일자</th>
												<th CL='STD_LMOTIM'>수정시간</th>
												<th CL='STD_LMOUSR'>수정자</th>
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<!-- <col width="40" /> -->
											<col width="40" />
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
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<!-- <td GCol="rowCheck" class="sBox active"></td> -->
												<td GCol="input,LANGKY" validate="required,SYSTEM_M0014" GF="S 3"></td>
												<td GCol="input,LABLGR,SHLBLGR" validate="required" GF="S 10"></td>
												<td GCol="input,LABLKY,SHLBLKY" validate="required" GF="S 20"></td>
												<td GCol="input,LBLTXS" GF="S 24"></td>
												<td GCol="input,LBLTXM" GF="S 45"></td>
												<td GCol="input,LBLTXL" GF="S 180"></td>
												<td GCol="text,CREDAT" GF="D"></td>
												<td GCol="text,CRETIM" GF="T"></td>
												<td GCol="text,CREUSR"></td>
												<td GCol="text,LMODAT" GF="D"></td>
												<td GCol="text,LMOTIM" GF="T"></td>
												<td GCol="text,LMOUSR"></td>
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
		<!-- //contentContainer -->
	</div>
</div>
<!-- //content -->
<%@ include file="/common/include/bottom.jsp" %>
</body>
</html>