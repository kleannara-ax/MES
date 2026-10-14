<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	String SHPOKY = request.getParameter("SHPOKY");
	String TASKKY = request.getParameter("TASKKY");
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
			command : "MDL08",
			gridMobileType : true
	    });
		
		searchList();	
	});
	
	function searchList(){
		var param = new DataMap();
		param.put("SHPOKY", "<%=SHPOKY%>");
		
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
		
		$("input[name='SHPOKY']").val("<%=SHPOKY%>");
	}
	
	function showScan(){
		location.href="/mobile/MDL08.page";
	}
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if( dataLength == 0 ){
			location.href="/mobile/MDL08.page";
		}
 	}
	
	function savetData(){
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		}
		
		//var list = gridList.getSelectData("gridList");
		var list = gridList.getGridData("gridList");
		if(list.length == 0){
			commonUtil.msgBox("VALID_M0006");
			return;
		}
		
		//var param = new DataMap();
		var param = dataBind.paramData("searchArea");
		param.put("list", list);
		
		var json = netUtil.sendData({
			url:"/mobile/Mobile/json/SaveMDL08.data",
			param : param
		}); 
		
		if(json && json.data){
			commonUtil.msgBox("MASTER_M0564");
			searchList();
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
							<col width="100px" />
							<col />
							<col width="60px" />
						</colgroup>
						<tbody>
							<tr>
								<th CL="STD_SHIPORDNO"></th>
								<td>
									<input type="text" class="text" name="SHPOKY" readonly="readonly"/>
								</td>
							</tr>
							<tr>
								<th CL="STD_VEHINO"></th>
								<td>
									<select Combo="Mobile,VEHINO_COMBO" name="VEHINO" id="VEHINO">
									</select>
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
								<col width="80px" />
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
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
							</colgroup>
							<thead>
								<tr class="thead">
									<th CL='STD_NO'></th>
									<th CL='STD_LOTA07'></th>
									<th CL='STD_SHPOKY'></th>
									<th CL='STD_SHPOIT'></th>
									<th CL='STD_SKUKEY'></th>
									<th CL='STD_DESC01'></th>
									<th CL='STD_DESC02'></th>
									<th CL='STD_QTYORG'></th>
									<th CL='STD_QTSHPO'></th>
									<th CL='STD_QTALOC'></th>
									<th CL='STD_QTJCMP'></th>
									<th CL='STD_QTSHPD'></th>
									<th CL='STD_UOMKEY'></th>
									<th CL='STD_LOTA02'></th>
									<th CL='STD_DOCTXT'></th>
								</tr>
							</thead>
						</table>				
					</div>				
					<div class="tableBody">
						<table style="width: 100%">
							<colgroup>
								<col width="40px" />
								<col width="80px" />
								<col width="80px"/>
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
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
							</colgroup>
							<tbody id="gridList">
								<tr CGRow="true">
									<td GCol="rownum"></td>
									<td GCol="text,SEBELN"></td>
									<td GCol="text,SHPOKY"></td>
									<td GCol="text,SHPOIT"></td>
									<td GCol="text,SKUKEY"></td>
									<td GCol="text,DESC01"></td>
									<td GCol="text,DESC02"></td>
									<td GCol="text,QTYORG" GF="N 20,3"></td>
									<td GCol="text,QTSHPO" GF="N 20,3"></td>
									<td GCol="text,QTALOC" GF="N 20,3"></td>
									<td GCol="text,QTJCMP" GF="N 20,3"></td>
									<td GCol="text,QTSHPD" GF="N 20,3"></td>
									<td GCol="text,UOMKEY"></td>
									<td GCol="text,LOTA02"></td>
									<td GCol="input,NAME01"></td>
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