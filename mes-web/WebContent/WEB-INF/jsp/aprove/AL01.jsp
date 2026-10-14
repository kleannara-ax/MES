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
			module : "Aprove",
			command : "FWAPLI0010"
	    }); 
	});

	function searchList(){
		var param = dataBind.paramData("searchArea");
		//var param = inputList.setRangeParam("searchArea");
		
		netUtil.send({
			module : "Aprove",
			command : "FWAPLM0010",
			bindId : "searchArea",
			sendType : "map",
			bindType : "field",
			param : param
		});

		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
	}
	
	function saveData(saveType){
		var gridCnt = gridList.getGridDataCount("gridList");		
		
		if(gridCnt < 1){
			commonUtil.msgBox("SYSTEM_SAVEEMPTY");
			return;
		} 

		var param = dataBind.paramData("searchArea");
		
		var tmpUrl;
		if(saveType == "I"){
			tmpUrl = "/aprove/insert/json/FWAPL.data";
		}else{
			tmpUrl = "/aprove/update/json/FWAPL.data"
		}
		
		var json = netUtil.sendData({
			url : tmpUrl,
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
			saveData("I");
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
									<th CL="STD_APKEY">승인키</th>
									<td>
										<input type="text" name="APKEY" validate="required"/>
									</td>
									<th CL="STD_APNAME">승인명</th>
									<td>
										<input type="text" name="APNAME" validate="required"/>
									</td>
								</tr>
								<tr>
									<th CL="STD_APDESC">승인설명</th>
									<td>
										<input type="text" name="APDESC" style="width: 300px"/>
									</td>
									<th CL="STD_APPATH">화면경로</th>
									<td>
										<input type="text" name="APPATH" style="width: 300px"/>
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
												<td GH="80" GCol="text,APKEY"></td>
												<td GH="80" GCol="input,APUSER"></td>
												<td GH="80" GCol="input,SORTKEY"></td>
												<td GH="80" GCol="input,ALDESC"></td>
											</tr>
										</tbody>
									</table>
								</div>
							</div>
							<div class="tableUtil">
								<div class="leftArea">
									<button type="button" GBtn="find"></button>
									<button type="button" GBtn="sortReset"></button>
									<button type="button" GBtn="add"></button>
									<button type="button" GBtn="delete"></button>
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