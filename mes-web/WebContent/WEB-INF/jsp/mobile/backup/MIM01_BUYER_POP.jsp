<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>SKU Image List</title>
<%@ include file="/mobile/include/head.jsp" %>
<script>	
	window.resizeTo('450','643');
	
	$(document).ready(function(){
		gridList.setGrid({
			id : "gridList",
			editable : false,
			module : "Mobile",
			command : "MIM01_BUYER",
			gridMobileType : true
	    });
		
		var data = mobile.getLinkPopData();
	    dataBind.dataNameBind(data, "searchArea");
	    
		searchList();
	});
	
	function searchList(){
		var param = inputList.setRangeParam("searchArea");
		
		gridList.resetGrid("gridList");
		
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
	}
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if(gridId == "gridList"){
			if(dataLength == 1){
				popClose();
			}
		}
	}
	
	function gridListEventRowDblclick(gridId, rowNum){
		var rowData = gridList.getRowData(gridId, rowNum);
		mobile.linkPopClose(rowData);
	}
	
 	function popClose(){
 		var rowData = gridList.getRowData("gridList", 0);
		mobile.linkPopClose(rowData);
 	}
</script>
</head>
<body>
	<div id="searchArea">
		<input type="hidden" name="SKUKEY" />
		<input type="hidden" name="OWNRKY" />
	</div>
	<div class="main_wrap" id="main">
		<div id="main_container">
			<div class="tem5_content">
				<div class="tableWrap_search section" style="overflow:auto;">
					<div class="tableHeader">
						<table style="width:100%">
							<colgroup>
								<col width="30px" />
								<col width="100px" />
								<col width="100px" />
								<col width="200px" />
							</colgroup>
							<thead>
								<tr>
									<th CL='STD_NUMBER'></th>
									<th CL='STD_MATNR,3'></th>
									<th CL='STD_SearchCode,3'></th>
									<th CL='STD_DESC01'></th>
								</tr>
							</thead>
						</table>				
					</div>					
					<div class="tableBody" style="height:290px;">
						<table style="width:100%;">
							<colgroup>
								<col width="30px" />
								<col width="100px" />
								<col width="100px" />
								<col width="200px" />
							</colgroup>
							<tbody id="gridList">
								<tr CGRow="true">
									<td GCol="rownum">1</td>
									<td GCol="text,MATNR"></td>
									<td GCol="text,SKUKEY"></td>
									<td GCol="text,DESC01"></td>
								</tr>
							</tbody>
						</table>
					</div>
					<!-- end table_body -->
					<div class="footer_5">
						<table>
							<tr>
								<td onclick="popClose()"><label CL="BTN_CLOSE"></label></td>
							</tr>
						</table>
					</div><!-- end footer_5 -->
				</div>
			</div>
		</div>
	</div>
</body>