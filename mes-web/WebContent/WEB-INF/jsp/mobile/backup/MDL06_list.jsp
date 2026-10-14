<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	String SHPOKY = request.getParameter("SHPOKY");
	String TASKKY = request.getParameter("TASKKY");
	String DOORKY = request.getParameter("DOORKY");
	String DOTYPE = request.getParameter("DOTYPE");

	String txt = DOORKY.substring(0,1);
	if(txt.equals("O")){
		txt ="Picking By Shp.Doc.";
	}else if(txt.equals("S")){
		txt ="Picking By Sku";
	}else if(txt.equals("C")){
		txt ="Picking By Customer";
	}else if(DOTYPE.equals("1")){
		txt ="Picking By Request";
	}
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
			command : "MDL06",
			//bindArea : "searchArea",
			gridMobileType : true
	    });
		
		searchList();	
	});
	
	function searchList(){
		var param = new DataMap();
		param.put("DOORKY", "<%=DOORKY%>");
		param.put("DOTYPE", "<%=DOTYPE%>");
		
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
		
		$("input[name='DOORKY']").val("<%=DOORKY%>");
	}
	
	function showScan(){
		location.href="/mobile/MDL06.page";
	}
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if( dataLength == 0 ){
			location.href="/mobile/MDL06.page";
		}
 	}
	
	function savetData(){
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		}
		
		var list = gridList.getSelectData("gridList");
		if(list.length == 0){
			commonUtil.msgBox("VALID_M0006");
			return;
		}
		
		var doType = "<%= DOTYPE%>";
		var param = new DataMap();
		param.put("list", list);
		param.put("DOTYPE", doType);
		
		if(doType == 1){
			param.put("DOORKY", "<%=DOORKY%>");
		}
		
		var json = netUtil.sendData({
			url:"/mobile/Mobile/json/SaveMDL06.data",
			param : param
		});
		
		if(json && json.data){
			commonUtil.msgBox("MASTER_M0564");
			searchList();
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
								<th CL="STD_PKBARCODE">피킹바코드</th>
								<td>
									<input type="text" class="text" name="DOORKY" readonly="readonly"/>
								</td>
							</tr>
							<tr>
								<th CL="STD_PKTYPE">피킹유형</th>
								<td>
									<input type="text" class="text" name="PKTYPE" value="<%=txt%>" readonly="readonly"/>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
			<div class="tem4_content">	
				<div class="tableWrap_search section">
					<div class="tableHeader">
						<table style="width: 100%">
							<colgroup>
									<col width="40px" />
									<col width="40px" />
									<col width="80px" />
									<col width="80px" />
									<col width="80px" />
									<col width="200px" />
									<col width="80px"/>
									<col width="80px"/>
									<col width="80px" />
									<col width="80px" />
									<col width="80px"/>
									<col width="80px" />
									<col width="80px" />
							</colgroup>
							<thead>
								<tr class="thead">
									<th CL='STD_NO'></th>
									<th GBtnCheck="true"></th>
									<th CL='STD_AREAKY'>창고</th>
									<th CL='STD_LOCAKY,3'>로케이션</th>
									<th CL="STD_SKUKEY">품번</th>
									<th CL="STD_DESC01">품명</th>
									<th CL="STD_QTTAOR">지시수량</th>
									<th CL="STD_QTCOMP">피킹수량</th>
									<th CL="STD_UOMKEY">단위</th>
									<th CL="STD_TASKKY">작업오더번호</th>
									<th CL="STD_TASKIT">작업오더순번</th>
									<th CL="STD_SHPOKY">출고오더번호</th>
									<th CL="STD_SHPOIT">출고오더순번</th>
								</tr>
							</thead>
						</table>				
					</div>				
					<div class="tableBody">
						<table style="width: 100%">
							<colgroup>
								<col width="40px" />
								<col width="40px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="200px" />
								<col width="80px"/>
								<col width="80px"/>
								<col width="80px" />
								<col width="80px" />
								<col width="80px"/>
								<col width="80px" />
								<col width="80px" />
							</colgroup>
							<tbody id="gridList">
								<tr CGRow="true">
									<td GCol="rownum"></td>
									<td GCol="rowCheck"></td>
									<td GCol="text,AREAKY"></td>
									<td GCol="text,LOCASR"></td>					
									<td GCol="text,SKUKEY"></td>				
									<td GCol="text,DESC01"></td>					
									<td GCol="text,QTTAOR" GF="N"></td>
									<td GCol="input,QTCOMP" GF="N"></td>
									<td GCol="text,UOMKEY"></td>
									<td GCol="text,TASKKY"></td>
									<td GCol="text,TASKIT"></td>
									<td GCol="text,SHPOKY" ></td>
									<td GCol="text,SHPOIT" ></td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
			<div class="bottom">
				<input type="button" CL="STD_CDSCAN" class="bottom_bt2" onClick="showScan()"/>
				<input type="button" CL="STD_SAVE" class="bottom_bt2" onClick="savetData()"/>
			</div>
		</div>
	</div>
</body>