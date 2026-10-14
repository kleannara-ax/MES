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
		setTopSize(500);
	 	gridList.setGrid({
	    	id : "gridList",
			module : "System",
			command : "SHLPI"
	    }); 
	});

	function searchList(){
		var param = dataBind.paramData("searchArea");
		//var param = inputList.setRangeParam("searchArea");
		param.put("SHLPKY", param.get("LINKKEY"));

		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
	}
	
	function saveData(){
		var gridCnt = gridList.getGridDataCount("gridList");		
		
		if(gridCnt < 1){
			commonUtil.msgBox("SYSTEM_SAVEEMPTY");
			return;
		} 

		var param = dataBind.paramData("searchArea");
		param.put("APKEY","DEMOAPROVE");
		
		var json = netUtil.sendData({
			url : "/aprove/insert/json/FWAPR.data",
			param : param
		}); 
		
		if(json && json.data){
			commonUtil.msgBox("SYSTEM_SAVEOK");
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
		<button CB="Search SEARCH BTN_DISPLAY"></button>
		<button CB="Save SAVE STD_APROVE"></button>
	</div>
</div>

<!-- content -->
<div class="content">
	<div class="innerContainer">

		<!-- contentContainer -->
		<div class="contentContainer">

			<!-- TOP FieldSet -->
			<div class="foldSect" id="searchArea">
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
									<th CL="STD_LINKKEY">서치헬프</th>
									<td>
										<input type="text" name="LINKKEY"  UIInput="S,SHSHLPH" validate="required"/>
									</td>
								</tr>
								<tr>
									<th CL="STD_REDESC">설명</th>
									<td>
										<input type="text" name="REDESC" style="width: 500px"/>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				  </div>
				</div>
			</div>
			
			<!-- BOTTOM FieldSet -->
			<div class="bottomSect" style="top:130px;">
				<button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button>
				<div class="tabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span CL='STD_LIST'>탭메뉴1</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableBody">
									<table>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GH="80" GCol="rownum">1</td>
												<td GH="80" GCol="text,SHLPKY" GF="S 10"></td>
												<td GH="80" GCol="text,DBFILD" GF="S 20"></td>
												<td GH="80" GCol="text,DDICKY" GF="S 20"></td>
												<td GH="80" GCol="text,INDUSO"></td>
												<td GH="80" GCol="text,POSSOS" GF="S 3"></td>
												<td GH="80" GCol="text,INDNED"></td>
												<td GH="80" GCol="text,RQFLDS"></td>
												<td GH="80" GCol="text,INDULS"></td>
												<td GH="80" GCol="text,POSLIS" GF="S 3"></td>
												<td GH="80" GCol="text,INDRVL"></td>
												<td GH="80" GCol="text,DFVSOS" GF="S 60"></td>
											</tr>
										</tbody>
									</table>
								</div>
							</div>
							<div class="tableUtil">
								<div class="leftArea">
									<button type="button" GBtn="find"></button>
									<button type="button" GBtn="sortReset"></button>
									<button type="button" GBtn="layout"></button>
									<button type="button" GBtn="excel"></button>
								</div>
								<div class="rightArea">
									<p class="record"></p>
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