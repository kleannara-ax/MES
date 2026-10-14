<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>Moblie WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script>
	var skukey;
	var ownrky;
	
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			editable : false,
			module : "Mobile",
			command : "MOM01SEARCH",
			bindArea : "searchArea",
			gridMobileType : true
	    });
		
		var data = mobile.getLinkPopData();
		
		if(data != null) {
			skukey = data.get("INPUTSKU");
			ownrky = data.get("OWNRKY");
		}
		
		searchList();
	});
	
	function searchList(){
		var param = new DataMap();
		param.put("SKUKEY", skukey);
		param.put("OWNRKY", ownrky);
		
		gridList.gridList({
		   	id : "gridList",
		   	param : param
		});
	}
	
	function showScan() {
		mobile.linkPopClose();
		location.href="/mobile/MOM01.page";
	}
	
	function selectData(){
		var rowNum = gridList.getFocusRowNum("gridList");
		var rowData = gridList.getRowData("gridList", rowNum);
		mobile.linkPopClose(rowData);
	}
	
	function clearText(data){
		if(data!=null||data!=""){
	    	data.value="";
	    }      
	}
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if( dataLength == 0 ){
			mobile.linkPopClose();
			location.href="/mobile/MOM01.page";
		}
 	}
</script>
</head>
<body>
	<div class="main_wrap">
		<div class="tem4_content">
				<div class="tableWrap_search section">
				<div id="searchArea">
					<table style="width: 100%">
						<colgroup>
							<col width="40px" />
							<col width="100px" />
							<col width="180px" />
							<col width="80px" />
							<col width="100px"/>
							<col width="180px" />
						</colgroup>
						<thead>
							<tr>
								<th CL='STD_NUMBER'>번호</th>
								<th CL='STD_SKUKEY'></th>
								<th CL='STD_DESC01'></th>
								<th CL='STD_DESC02'></th>
								<th CL='STD_DESC04'></th>
								<th CL='STD_SKUG05'></th>
							</tr>
						</thead>
					</table>				
				</div>
				<div class="tableBody">
					<table style="width: 100%">
						<colgroup>
							<col width="40px" />
							<col width="100px" />
							<col width="180px" />
							<col width="80px" />
							<col width="100px"/>
							<col width="180px" />
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rownum"></td>
								<td GCol="text,SKUKEY"></td>
								<td GCol="text,DESC01"></td>
								<td GCol="text,DESC02"></td>
								<td GCol="text,DESC04"></td>
								<td GCol="text,SKUG05"></td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
			<div class="bottom">
				<input type="button" CL="STD_CDSCAN" class="bottom_bt2" onClick="showScan()"/>
				<input type="button" CL="STD_SELECT" class="bottom_bt2" onClick="selectData()"/>
			</div>
		</div>	
	</div>
</body>