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
		dataBind.dataNameBind(data, "searchArea");
		
		gridList.setGrid({
	    	id : "gridList",
			editable : false,
			module : "Mobile",
			command : "MGR01_FAIL_SEARCH2",
			gridMobileType : true
	    });
		
		searchList();	

	});
	
	function searchList(){
	//	if(validate.check("searchArea")){
			var param = new DataMap();
			var QCITEM = $("[name=QCITEM]").val();
			param.put("QCITEM",QCITEM);
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
	//	}
	}
	
	function selectCode(){
		var rowNum = gridList.getSelectIndex("gridList");
		var rowData = gridList.getRowData("gridList", rowNum);
		mobile.linkPopClose(rowData);
	}
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if( dataLength == 0 ){
			location.href="/mobile/MGR01_whyfail.page";
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
							<tr>
								<td>
								<input type="hidden" name="QCITEM" />
								</td>
							</tr>
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
									<col width="40px" />
							</colgroup>
							<tbody>
								<tr class="thead">
									<th CL='STD_NUMBER'>번호</th>
								    <th >선택</th>
									<th CL='STD_FAILIT'>불량항목코드</th>
									<th CL='STD_ITNAME'>불량항목명</th>
									<th CL='STD_QCITEM'>검사항목코드</th>
								</tr>
							</tbody>
						</table>
					
				</div>
				<div class="tableBody">
					<table>
						<colgroup>
								<col width="40px" />
								<col width="40px" />
								<col width="40px" />
								<col width="40px" />
								<col width="40px" />
							</colgroup>
							<tbody id="gridList">
								<tr CGRow="true">
									<td GCol="rownum"></td>
									<td GCol="rowCheck,radio"></td>
									<td GCol="text,FAILIT"></td>
									<td GCol="text,ITNAME"></td>
									<td GCol="text,QCITEM"></td>
								</tr>
							</tbody>
						</table>							
					</div>
				</div>
				<div class="bottom">
					<input type="button" value="선택" class="bottom_bt" onclick="selectCode()"/>
				</div>
		</div>	
	</div>		
</body>
