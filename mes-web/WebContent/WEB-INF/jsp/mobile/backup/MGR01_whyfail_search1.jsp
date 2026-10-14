<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	String KINDQC = (String)request.getParameter("KINDQC");
	String SKUKEY = (String)request.getParameter("SKUKEY");
%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>슈피겐코리아 모바일 WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script>
	$(document).ready(function(){
		var data = mobile.getLinkPopData(); 
		<%-- var data = new DataMap();
		data.put("KINDQC","<%=KINDQC%>");
		data.put("SKUKEY","<%=SKUKEY%>"); --%>
		
		dataBind.dataNameBind(data, "searchArea");
		
		gridList.setGrid({
	    	id : "gridList",
			editable : false,
			module : "Mobile",
			command : "MGR01_FAIL_SEARCH1",
			gridMobileType : true
	    });
	
		searchList();

	});
	
	function searchList(){
		var param = new DataMap();
		var SKUKEY = $("[name=SKUKEY]").val();
		param.put("SKUKEY",SKUKEY);
		gridList.gridList({
		   	id : "gridList",
		   	param : param
		});
	}
	
	/* function gridListEventRowDblclick(gridId, rowNum, colName){
		if( gridId == "gridList"){ 
			var rowData = gridList.getRowData(gridId, rowNum);
			var qcitem = rowData.get("QCITEM");
			opener.parent.getData(qcitem);
			window.close();
			//location.href ="MGR01_whyfail.page?QCITEM="+qcitem;
			//	param.put("QCITEM", qcitem);
		} 
	} */
	
	function selectCode(){
		var rowNum = gridList.getSelectIndex("gridList");
		var rowData = gridList.getRowData("gridList", rowNum);
		mobile.linkPopClose(rowData);
		/* var qcitem = rowData.get("QCITEM");
		//opener.parent.getData(qcitem);
		//window.close();
		location.href ="MGR01_whyfail.page?QCITEM="+qcitem; */
	}
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if( dataLength == 0 ){
			/* location.href="/mobile/MGR01_whyfail.page"; */
			var rowData = new DataMap();
			rowData.put("data","NULL");
		
			mobile.linkPopClose(rowData); 
		}
 	}
	
</script>	
</head>
<body>
	<div class="main_wrap">
		<div class="tem5_content">
				<div class="search_box">
					<table>
						<colgroup>
							<col />
							<col width="100px"  />
						</colgroup>
						<tbody id="searchArea">
						<input type="hidden" name="SKUKEY" />
							<!-- <tr>
								<td class="second">
									<input type="text" id="SKUKEY" name="SKUKEY"  class="text" validate="required"/>
								</td>
								<td>
									<input type="button" value="조회" class="bt" onclick="searchList()"/>
								</td>
							</tr> -->
						</tbody>
					</table>
				</div>
				
				<div class="info_box">
					<div class="tableHeader">
						<table>
							<colgroup>
									<col width="40px" />
									<col width="40px" />
									<col width="40px" />
									<col width="40px" />
							</colgroup>
								<thead>
									<tr>
										<th CL='STD_NUMBER'>번호</th>
								        <th >선택</th>
										<th CL='STD_QCITEM'>검사항목코드</th>
										<th CL='STD_ITMENAME'>검사항목명</th>
									</tr>
								</thead>
						</table>
					</div>
					
					<div class="tableBody">
					<form>
						<table>
							<colgroup>
									<col width="40px" />
									<col width="40px" />
									<col width="40px" />
									<col width="40px" />
							</colgroup>
							<tbody id="gridList">
								<tr CGRow="true" >
									<td GCol="rownum"></td>
									<td GCol="rowCheck,radio"></td>
									<td GCol="text,QCITEM"></td>
									<td GCol="text,ITMENAME"></td>
								</tr>	
							</tbody>
						</table>
					</form>			
					</div>
				</div>
				<div class="bottom">
					<input type="button" value="선택" class="bottom_bt" onclick="selectCode()"/>
				</div>
		</div>	
	</div>	
</body>
