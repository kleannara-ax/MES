<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>납품문서관리 팝업</title>
<%@ include file="/common/include/popHead.jsp" %>
<script type="text/javascript">

	window.resizeTo('430','470');
	
	$(document).ready(function(){
		gridList.setGrid({
			id : "gridList",
			editable : true,
			module : "TmsAdmin",
			command : "SIMULID"
	    });
		var data = page.getLinkPopData();
		dataBind.dataNameBind(data, "searchArea");
		searchList();
	});
	
	function searchList(){
		var param = inputList.setRangeParam("searchArea");
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    }); 
	}
	
	function saveData(){
 		var param = dataBind.paramData("searchArea");
		var list = gridList.getGridData("gridList");

		param.put("list", list); 
		
		var json = netUtil.sendData({
			url : "/tms/ord/json/saveSIMUL.data",
			param : param
		});
		
		var json = netUtil.sendData({
			url : "/tms/ord/json/saveDNTAK.data",
			param : param
		}); 		
		
		
		if(json && json.data){
			commonUtil.msgBox("HHT_T0008");
			searchList();
		}

		this.close();
	}	
	
	function commonBtnClick(btnName){
		if(btnName == "Save"){
			saveData();
		}else if(btnName == "Check"){
			fn_closing();
		}
	}
	
	function fn_closing(){
		this.close();		
	}
	
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="Save SAVE STD_SAVE">
		</button>
		<button CB="Check CHECK BTN_CLOSE">
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
						<li><a href="#tabs"><span CL="STD_LIST">리스트</span></a></li>
					</ul>
					<div id="tabs">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
											<col width="40" />
											<col width="100" />
											<col width="250" />
										</colgroup>
										<thead>
											<tr>
												<th CL="STD_NUMBER"></th>
												<th>시뮬레이션 ID</th>
												<th>시뮬레이션명</th>
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="40" />
											<col width="100" />
											<col width="250" />
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GCol="rownum"></td>
												<td GCol="text,SIMKEY">시뮬레이션ID</td>
												<td GCol="input,SHORTX">시뮬레이션명</td>
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
</div>
<!-- //content -->
<%@ include file="/common/include/bottom.jsp" %>
</body>
</html>