<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport"
	content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>슈피겐코리아 모바일 WMS</title>
<%@ include file="/mobile/include/head.jsp"%>
<script>
	$(document).ready(function() {
		gridList.setGrid({
			id : "gridList",
			editable : false,
			module : "Mobile",
			command : "MSD02_SEARCH",
			gridMobileType : true
		});

	});

	function searchList() {
		if (validate.check("searchArea")) {
			var param = dataBind.paramData("searchArea");

			gridList.gridList({
				id : "gridList",
				param : param
			});
		}
	}

	function sendData() {
		var data = gridList.getSelectData("gridList");

		if (data.length == 0) {
			commonUtil.msgBox("VALID_M0006");
			//alert("선택된 데이터가 없습니다.");
			return;
		}else {
			/* var LOCAKY = data[0].get("LOCAKY");
			opener.getData(LOCAKY);
	        window.close(); */
	        
			/* location.href = "/mobile/MSD02.page?LOCAKY=" + LOCAKY; */
			
			var rowNum = gridList.getFocusRowNum("gridList");
			var rowData = gridList.getRowData("gridList", rowNum);
			mobile.linkPopClose(rowData);
		}
	}
	
	function clearText(data){
		if(data!=null||data!=""){
	    	data.value="";
	    }      
	}
</script>
</head>
<body>
	<div class="main_wrap">
		<div class="tem4_content">
			<div class="select_box" >
				<table>
					<colgroup>
						<col />
						<col width="100px" />
					</colgroup>
					<tbody id="searchArea">
						<tr>
							<td class="first">
								<select name="COLNAME">
									<option value="LOCAKY">지번</option>
									<option value="SKUKEY">품번</option>
									<option value="DESC01">품명</option>
								</select>
							</td>
							<td rowspan="2">
								<a href="#"> 

									<input type="button" class="bt" value="조회" onclick='searchList()' />

								</a>
							</td>
						</tr>
						<tr>
							<td class="second">
								<input type="text" class="text" name="COLTEXT" validate="required" onkeypress="commonUtil.enterKeyCheck(event, 'searchList()')" onfocus="clearText(this)"/>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="tableWrap_search section">
				<div class="tableHeader">
					<table style="width: 100%">
						<colgroup>
							<col width="60px" />
							<col width="60px" />
							<col width="100px" />
							<col width="100px" />
							<col width="250px" />
							<col width="80px" />
							<col width="80px" />
						</colgroup>
						<thead>
							<tr class="thead">
								<th CL='STD_NUMBER'>번호</th>
								<th CL='STD_ROWCK'>번호</th>
								<th CL='STD_LOCAKY'>지번</th>
								<th CL='STD_SKUKEY'>품번</th>
								<th CL='STD_DESC01'>품명</th>
								<th CL='STD_AREAKY'>구역코드</th>
								<th CL='STD_ZONEKY'>센터코드</th>
							</tr>
						</thead>
					</table>
				</div>
				<div class="tableBody">
					<table style="width: 100%">
						<colgroup>
							<col width="60px" />
							<col width="60px" />
							<col width="100px" />
							<col width="100px" />
							<col width="250px" />
							<col width="80px" />
							<col width="80px" />
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rownum"></td>
								<td GCol="rowCheck,radio"></td>
								<td GCol="text,LOCAKY"></td>
								<td GCol="text,SKUKEY"></td>
								<td GCol="text,DESC01"></td>
								<td GCol="text,AREAKY"></td>
								<td GCol="text,ZONEKY"></td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>

			<div class="bottom">
				<input type="button" CL="STD_ROWCK" class="bottom_bt" onclick="sendData()"/>
			</div>
		</div>
	</div>
</body>