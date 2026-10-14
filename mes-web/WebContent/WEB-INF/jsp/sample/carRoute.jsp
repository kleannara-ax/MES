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
			pkcol : "SHPTOP",
			module : "Geocoding",
			command : "CARROUTE"
	    });
		searchList()
	});

	function searchList(){
		var param = inputList.setRangeParam("searchArea");
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
	}
	
 	function saveData(){
        var param = inputList.setRangeParam("searchArea")
        var listCnt = gridList.getGridDataCount("gridList") 		
 		alert("carRoute saveData");
 		 		
		var json = netUtil.sendData({
			id : "gridList",
			url : "/geocoding/input/json/carRouteNew.data",
			sendType : "map",
			param : param
			
		});

			searchList();	
	}

 	function saveData1(){
        var param = inputList.setRangeParam("searchArea")
        var listCnt = gridList.getGridDataCount("gridList") 		
 		alert("XY");
 		 		
		var json = netUtil.sendData({
			id : "gridList",
			url : "/geocoding/input/json/procedure.data",
			sendType : "map",
			param : param
			
		});

			searchList();	
	}
 	

	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}else if(btnName == "Save1"){
			saveData1();
		}
	}
	
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY">
		</button>
		<button CB="Save SAVE API">
		</button>
		<button CB="Save1 SAVE1 XY">
		</button>	
	</div>
</div>


<!-- content -->
<div class="content">
	<div class="innerContainer">

		<!-- contentContainer -->
		<div class="contentContainer">

			<div class="bottomSect type1">
				<div class="tabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span>탭메뉴1</span></a></li>
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
										</colgroup>
										<thead>
											<tr>
											    <th CL='STD_NUMBER'>번호</th>
												<th>출발지</th>
												<th>도착지</th>
												<th>이동거리</th>
												<th>이동시간</th>
												<th>METHOD</th>
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
										</colgroup>
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
											    <td GCol="rownum">1</td>
												<td GCol="text,SHPTOP" ></td>
												<td GCol="text,TSHPTO"></td>
												<td GCol="text,DISTANCE"></td>
												<td GCol="text,TRVTIME"></td>
												<td GCol="text,METHOD"></td>      
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
		</div>
		<!-- //contentContainer -->
	</div>
</div>
<!-- //content -->
<%@ include file="/common/include/bottom.jsp" %>
</body>
</html>