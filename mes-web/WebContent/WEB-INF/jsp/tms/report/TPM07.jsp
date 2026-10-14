<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript">
	var searchCnt = 0;
	var dblIdx = -1;
	
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
	    	name : "gridList",
			editable : true,
			module : "WmsReport",
			command : "KP01",
	    });

		userInfoData = page.getUserInfo();
		dataBind.dataNameBind(userInfoData, "searchArea");
		
		var rdata = new DataMap();
		rdata.put(configData.INPUT_RANGE_OPERATOR, "E");
		rdata.put(configData.INPUT_RANGE_SINGLE_DATA, userInfoData.AREA);
		inputList.setRangeData("AREAKY", configData.INPUT_RANGE_TYPE_SINGLE, [rdata]);
	});
	
	function searchList() {
		var param = inputList.setRangeParam("searchArea");
		gridList.gridList({
			id : "gridList",
			param : param
		});
	}
	
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			searchList();
		}
	}
	
	function gridListEventRowDblclick(gridId, rowNum, colName){
		if(gridId == "gridList"){
			var rowData = gridList.getRowData(gridId, rowNum);
			dataBind.paramData("gridList", rowData);
			if(colName == "STKDIF"){
				page.linkPopOpen("/wms/report/KP01POP.page", rowData);
			} else if(colName == "NOTSHP"){
				page.linkPopOpen("/wms/report/KP01POP1.page", rowData);
			} else if(colName == "STKDAY"){
				page.linkPopOpen("/wms/report/KP01POP2.page", rowData);
			} else if(colName == "DMGCNT"){
				page.linkPopOpen("/wms/report/KP01POP3.page", rowData);
			} else if(colName == "STKBAD"){
				page.linkPopOpen("/wms/report/KP01POP4.page", rowData);
			}
		}
	}
	
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY">
		</button>
	</div>
	<div class="util2">
		<button class="button type2" id="showPop" type="button"><img src="/common/images/ico_btn4.png" alt="List" /></button>
	</div>
</div>

<!-- searchPop -->
<div class="searchPop" id="searchArea" style="overflow-y:scroll;">
	<button type="button" class="closer">X</button>
	<div class="searchInnerContainer">

		<p class="util">
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
						<th CL="STD_COMPKY">사업장</th>
						<td>
							<input type="text" name="COMPKY" value="100"  readonly="readonly" style="width:110px" />  <!-- UIInput="S,SHCOMMA"   -->
						</td>
					</tr>
					 <tr>
						<th CL="STD_DLVDAT">운송일자</th>
						<td>
							<input type="text" name="DLVDAT" UIInput="R" UIFormat="C Y" />
						</td>
					</tr>
					 <tr>
						<th CL="STD_VKBUR">영업팀</th>
						<td>
							<input type="text" name="VKBUR" UIInput="R,VKBUR" />
						</td>
					</tr>
					<tr>
						<th CL="STD_VKBUTX">제품군</th>
						<td>
							<input type="text" name="VKBUTX" UIInput="R,SHCMCDV" />
						</td>
					</tr>	
					<tr>
						<th CL="STD_SHPTKY">출하지점</th>
						<td>
							<input type="text" name="SHPTKY" UIInput="R,SHPTKY" />
						</td>
					</tr>
					<tr>
						<th CL="STD_VHCTYP">차량유형</th>
						<td>
							<input type="text" name="SFRGR" UIInput="R,SHCMCDV" />
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
						<li><a href="#tabs1-1"><span CL='STD_SEARCH'></span></a></li>
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
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<th CL='STD_WAREKY'></th>
												<th CL='STD_DOCDAT'></th>
												<th CL='STD_AREAKY'></th>
												<th CL='STD_SKUKEY'></th>
												<th CL='STD_LOTA02'></th>
												<th CL='STD_STKDIF'>재고오차율</th>
												<th CL='STD_NOTSHP'>미출고율</th>
												<th CL='STD_STKDAY'>재고보유일수</th>
												<th CL='STD_DMGCNT'>파손건수월</th>
												<th CL='STD_STKBAD'>악성재고건수</th>
												<th CL='STD_N00101'></th>
												<th CL='STD_N00102'></th>
												<th CL='STD_CREDAT'></th>
												<th CL='STD_CRETIM'></th>
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
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<td GCol="text,WAREKY"></td>
												<td GCol="text,DOCDAT"></td>
												<td GCol="text,AREAKY"></td>
												<td GCol="text,SKUKEY"></td>
												<td GCol="text,LOTA02"></td>
												<td GCol="text,STKDIF"></td>
												<td GCol="text,NOTSHP"></td>
												<td GCol="text,STKDAY"></td>
												<td GCol="text,DMGCNT"></td>
												<td GCol="text,STKBAD"></td>
												<td GCol="text,N00101"></td>
												<td GCol="text,N00102"></td>
												<td GCol="text,CREDAT"></td>
												<td GCol="text,CRETIM"></td>
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
		<!-- //contentContainer -->
	</div>
</div>
<!-- //content -->
<%@ include file="/common/include/bottom.jsp" %>
</body>
</html>