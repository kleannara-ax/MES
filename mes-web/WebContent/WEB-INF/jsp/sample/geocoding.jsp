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
			command : "GEOCODING"
	    });
		searchList()
	});

	function searchList(){
		var param = inputList.setRangeParam("searchArea");
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
		if(json && json.data){
			searchList();
		}			
		
		
		
	}
	
 	function saveData(){
        var param = inputList.setRangeParam("searchArea")
/*   
        var listCnt = gridList.getGridDataCount("gridList")
        var addr = "";
        var mandt = "";
        var wareky = "";
        var shptop = "";

        //var param = gridList.getColData("gridList", 0, "ADDR01");
        
       
        for (var i = 0; i < listCnt; i++) {
        	addr += gridList.getColData("gridList", i, "ADDR01")+",";
        	mandt += gridList.getColData("gridList", i, "MANDT")+",";
        	wareky += gridList.getColData("gridList", i, "WAREKY")+",";
        	shptop += gridList.getColData("gridList", i, "SHPTOP")+",";
        	
        }
             
        param.put("addr", addr);
        param.put("mandt", mandt);
        param.put("wareky", wareky);
        param.put("shptop", shptop);
        */  
        
		var json = netUtil.sendData({
			id : "gridList",
			url : "/geocoding/input/json/inquiryGeo.data",
			sendType : "map"		
		});

			searchList();	
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
		<button CB="Search SEARCH BTN_DISPLAY">
		</button>
		<button CB="Save SAVE STD_SAVE">
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
											<col width="60" /> 
											<col width="60" /> 
											<col width="60" />
											<col width="250" /> 
											<col width="100" /> 
											<col width="100" />											
										</colgroup>
										<thead>
											<tr>
												<th>key1</th>
												<th>key2</th>
												<th>key3</th>
												<th>addr1</th>
												<th>X</th>
												<th>Y</th>
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="60" /> 
											<col width="60" /> 
											<col width="60" />
											<col width="250" /> 
											<col width="100" /> 
											<col width="100" />											
										</colgroup>
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GCol="text,MANDT" ></td>
												<td GCol="text,WAREKY"></td>
												<td GCol="text,SHPTOP"></td>
												<td GCol="text,ADDR01"></td>
												<td GCol="text,SHPLAT"></td>
												<td GCol="text,SHPLON"></td>       
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