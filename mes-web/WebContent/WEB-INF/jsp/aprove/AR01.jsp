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
		setTopSize(1000);
	 	gridList.setGrid({
	    	id : "gridList",
			module : "Aprove",
			command : "FWAPRM0010"
	    }); 
	});

	function searchList(){
		var param = dataBind.paramData("searchArea");
		//var param = inputList.setRangeParam("searchArea");

		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
	}
	
	function saveData(){
		var gridCnt = gridList.getSelectData("gridList", true);
				
		if(gridCnt < 1){
			commonUtil.msgBox("SYSTEM_SAVEEMPTY");
			return;
		} 
		var param = new DataMap();
		
		var json = netUtil.sendData({
			url : "/wms/system/json/YHU01.data",
			param : param
		}); 
		
		if(json && json.data){
			commonUtil.msgBox("SYSTEM_SAVEOK");
			searchList();
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
	
	function gridListEventRowDblclick(gridId, rowNum, colName, colValue){
		//commonUtil.debugMsg("gridListEventRowDblclick : ", arguments);
		var data = gridList.getRowData(gridId, rowNum);
		var option = "height=1000,width=1000,resizable=yes";
		page.linkPopOpen("/aprove/view/page/FWAPR.page?APRKEY="+data.get("APRKEY"), data);	
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
						<table class="table type1" >
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
									<th CL="STD_APRTYPE">승인상태</th>
									<td>
										<input type="text" name="APRTYPE"/>
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
												<td GH="80" GCol="text,APRKEY"></td>
												<td GH="80" GCol="text,APKEY"></td>
												<td GH="80" GCol="text,REDESC"></td>
												<td GH="80" GCol="text,CREDAT"></td>
												<td GH="80" GCol="text,CREUSR"></td>
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