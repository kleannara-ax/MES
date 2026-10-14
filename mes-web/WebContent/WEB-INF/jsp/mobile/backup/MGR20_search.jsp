<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>슈피겐코리아 모바일 WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<%
	String keyword = request.getParameter("keyword");
	System.out.println("전달받은 키워드: " + keyword);
%>
<script>
	
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			editable : false,
			module : "Mobile",
			command : "MGR20_search",
			bindArea : "searchArea",
			gridMobileType : true
	    });
	});
	
	function searchList(){
		if(validate.check("searchArea")){
			var param = dataBind.paramData("searchArea");
			param.put("keyword", $("#keyword").val());
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}
	
	function sendData(){
		var data = gridList.getSelectData("gridList");

		if (data.length == 0) {
			alert("선택된 데이터가 없습니다.");
			return;
		} else {
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
		<div class="tem4_content" id="searchArea">
				<div class="select_box">
					<table>
						<colgroup>
							<col  />
							<col width="100px" />
						</colgroup>
						<tbody>
							<tr>
								<td class="first">
									<select name="COLNAME" id="COLNAME">
										<option value="EANCOD">88코드</option>
										<option value="SKUKEY">LOT</option>
										<option value="DESC01">품명</option>
									</select>
								</td>
								<td rowspan="2">
									<a href="#"><input type="button" value="조회" class="bt" onclick="searchList()"/></a>
								</td>
							</tr>
							<tr>
								<td class="second">
									<input type="hidden" id="keyword" name="keyword" value="<%=keyword%>"/>
									<input type="text" class="text" name ="COLTEXT" validate="required" onkeypress="commonUtil.enterKeyCheck(event, 'searchList()')" onfocus="clearText(this)"/>
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
							<col width="100px" />
							<col width="100px"/>
							<col width="100px"/>
							<col width="100px"/>
							
						</colgroup>
						<thead>
							<tr class="thead">
								<th>번호</th>
								<th>선택</th>
								<th>품번</th>
								<th>88코드</th>
								<th>품명</th>
								<th>생성일자</th>
								<th>생성자</th>
								<th>수정일자</th>
								<th>수정자</th>

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
							<col width="100px" />
							<col width="100px"/>
							<col width="100px"/>
							<col width="100px"/>
							
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
<!-- 							<td GCol="text,RECVKY"></td>	 -->
								<td GCol="rownum"></td>
								<td GCol="rowCheck,radio"></td>
								<td GCol="text,SKUKEY"></td>
								<td GCol="text,EANCOD"></td>
								<td GCol="text,DESC01"></td>
								<td GCol="text,CREDAT"></td>
								<td GCol="text,CREUSR"></td>
								<td GCol="text,LMODAT"></td>
								<td GCol="text,LMOUSR"></td>
								
						</tbody>
					</table>
				</div>
				</div>
				
				<div class="bottom">
					<input type="button" value="선택" class="bottom_bt" onClick="sendData()"/>
				</div>
		</div>	
	</div>
</body>