<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	String SKUKEY = request.getParameter("SKUKEY");
%>    
    
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>Moblie WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script>	
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			editable : false,
			module : "Mobile",
			command : "MSD01",
			gridMobileType : true,
			bindArea : "searchArea" 
	    });
		
		searchList();
	});
	
	function searchList(){
		var param = new DataMap();
		if("<%=SKUKEY%>"){
			param.put("SKUKEY", "<%=SKUKEY%>");
		}
		
		gridList.gridList({
		   	id : "gridList",
		   	param : param
		});
	}
	
	function showScan() {
		location.href="/mobile/MSD01.page";
	}
		
	function gridListEventDataBindEnd(gridId, dataLength){
		if( dataLength == 0 ){
			location.href="/mobile/MSD01.page";
		}
 	}
	
	function gridListEventRowDblclick(gridId, rowNum, colName, colValue){
		if(gridId == "gridList"){
			var rowData = gridList.getRowData(gridId, rowNum);
			
			var param = new DataMap();
			param.put("SKUKEY", rowData.get("SKUKEY"));
			
			var json = netUtil.sendData({
				module : "Mobile",
				command : "SKU_IMG_CNT",
				sendType : "map",
				param : param
			});
			
			dataBind.paramData("searchArea", rowData);
			
			if(json.data["CNT"] == 0){
				json = netUtil.sendData({
					module : "Mobile",
					command : "MIM01_SKUKEY",
					sendType : "map",
					param : param
				});
				
				if(json.data['CNT'] == 0){
					commonUtil.msgBox("MASTER_M1104"); //품번을 확인해주세요.
					return;
				} else {
					if(json.data['ASKL04'] == "S"){
						commonUtil.msgBox("MASTER_M1112", json.data['ASKL05']); // 메인품목코드가 아닙니다. [메인품목코드:{(0)}]
						return;
					}
				}
				
				// 이미지등록 팝업
				mobile.linkPopOpen("/mobile/MIM01_POP.page", rowData);
			} else {
				// 이미지목록 팝업
				mobile.linkPopOpen("/mobile/SKU_IMG_POP.page", rowData);
			}
		}
	}
	
</script>
</head>
<body>
	<div class="main_wrap">
		<div class="tem4_content">
			<div id="searchArea">
				<table class="table type1">
					<colgroup>
						<col width="100" />
						<col />
					</colgroup>
					<tbody>
						<tr>
							<th CL="STD_SKUKEY"></th>&nbsp;
							<td>
								<input type="text" name="SKUKEY" size="23px" readonly="readonly" />
							</td>
						</tr>
						<tr>
							<th CL="STD_DESC01"></th>
							<td>
								<input type="text" name="DESC01" size="23px" readonly="readonly"/ >
							</td>
						</tr>
						<tr>
							<th CL="STD_DESC02"></th>&nbsp;
							<td>
								<input type="text" name="DESC02" size="23px" readonly="readonly" />
							</td>
						</tr>
						<tr>
							<th CL="STD_SKUG05"></th>
							<td>
								<input type="text" name="SKUG05" size="23px" readonly="readonly"/ >
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="tableWrap_search section">
				<div class="tableHeader">
					<table style="width: 100%"> 
						<colgroup>
							<col width="40px" />
							<col width="80px" />
							<col width="150px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
						</colgroup>
						<thead>
							<tr class="thead">
								<th CL='STD_NO'></th>
								<th CL='STD_AREAKY'></th>
								<th CL='STD_AREANM'></th>
								<th CL='STD_LOCAKY'></th>
								<th CL='STD_QTSIWH'></th>
								<th CL='STD_UOMKEY'></th>
								<th CL='STD_LOTA06'></th>
								<th CL='STD_LOTA12'></th>
								<th CL='STD_LOTA11'></th>
								<th CL='STD_LOTA13'></th>
								<th CL='STD_LOTA10'></th>
								<!-- <th CL='STD_LOTA16'></th> -->
								<th CL='STD_LOTA17'></th>
								<th CL='STD_LOTA07'></th>
							</tr>
						</thead>
					</table>				
				</div>
				<div class="tableBody">
					<table style="width: 100%">
						<colgroup>
							<col width="40px" />
							<col width="80px" />
							<col width="150px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rownum"></td>
								<td GCol="text,AREAKY"></td>
								<td GCol="text,AREANM"></td>
								<td GCol="text,LOCAKY"></td>
								<td GCol="text,QTSIWH" GF="N"></td>
								<td GCol="text,UOMKEY"></td>
								<td GCol="text,LOTA06"></td>
								<td GCol="text,LOTA12" GF="C"></td>
								<td GCol="text,LOTA11" GF="C"></td>
								<td GCol="text,LOTA13" GF="C"></td>
								<td GCol="text,LOTA10"></td>
								<!-- <td GCol="text,LOTA16" GF="N"></td> -->
								<td GCol="text,LOTA17" GF="N"></td>
								<td GCol="text,LOTA07"></td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
			<div class="footer_5">
				<table>
					<tr>
						<td class=f_1 onclick="showScan()"><label CL="STD_CDSCAN"></label></td>
					</tr>
				</table>
			</div>
		</div>
	</div>
</body>