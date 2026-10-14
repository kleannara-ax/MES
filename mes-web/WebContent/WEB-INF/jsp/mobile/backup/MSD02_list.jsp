<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	String LOCAKY = request.getParameter("LOCAKY");
%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>Mobile WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script>	
	$(document).ready(function(){
		gridList.setGrid({
    		id : "gridList",
			editable : false,
			module : "Mobile",
			command : "MSD02",
			bindArea : "searchArea",
			gridMobileType : true
    	});
	
		searchList();		
	});

	function searchList(){
		if(validate.check("searchArea")){
			var param = new DataMap();
			param.put("LOCAKY", "<%=LOCAKY%>");
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
					
		}
	}
	
	function showScan() {
		location.href="/mobile/MSD02.page";
	}
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if( dataLength == 0 ){
			location.href="/mobile/MSD02.page";
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
							<th CL="STD_WAREKY">거점</th>&nbsp;&nbsp;
							<td>
								<input type="text" name="WAREKY" size="8px" readonly="readonly" />
								<input type="text" name="WARENM" size="13px" readonly="readonly" />
							</td>
						</tr>
						<tr>
							<th CL="STD_LOCAKY,3"></th>&nbsp;
							<td>
								<input type="text" name="LOCAKY" size="23px" readonly="readonly"/ >
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
							<col width="100px" />
							<col width="100px" />
							<col width="100px" />
							<col width="250px" />
							<col width="100px" />
							<col width="100px" />
							<col width="100px" />
							<col width="100px" />
							<col width="100px" />
							<col width="100px" />
							<col width="100px" />
							<col width="100px" />
							<col width="100px" />
						</colgroup>
						<thead>
							<tr class="thead">
								<th CL='STD_NO'></th>
								<th CL='STD_SKUKEY'></th>
								<th CL='STD_DESC01'></th>
								<th CL='STD_DESC02'></th>
								<th CL='STD_SKUG05'></th>
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
							<col width="100px" />
							<col width="100px" />
							<col width="100px" />
							<col width="250px" />
							<col width="100px" />
							<col width="100px" />
							<col width="100px" />
							<col width="100px" />
							<col width="100px" />
							<col width="100px" />
							<col width="100px" />
							<col width="100px" />
							<col width="100px" />
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rownum"></td>
								<td GCol="text,SKUKEY"></td>
								<td GCol="text,DESC01"></td>
								<td GCol="text,DESC02"></td>
								<td GCol="text,SKUG05"></td>
								<td GCol="text,QTSIWH" GF="N"></td>
								<td GCol="text,UOMKEY"></td>
								<td GCol="text,LOTA06"></td>
								<td GCol="text,LOTA12" GF="C"></td>
								<td GCol="text,LOTA11" GF="C"></td>
								<td GCol="text,LOTA13" GF="C"></td>
								<td GCol="text,LOTA10" ></td>
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