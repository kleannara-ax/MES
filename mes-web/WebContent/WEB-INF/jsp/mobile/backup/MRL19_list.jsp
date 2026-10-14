<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	request.setCharacterEncoding("UTF-8");
	String EBELN = request.getParameter("EBELN");
%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>IMV Mobile WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script>
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			editable : false,
			module : "Mobile",
			command : "MRL19",
			gridMobileType : true
	    });
		
		gridList.setReadOnly("gridList", true, ['EXRECV','EXRECP','EXSHIP','ALLOCA','PICKED','SHIPED','EXSHEC','EXSHECP']);
		
		searchList();
	});
	
	function searchList(){
		var param = new DataMap();
		
		param.put("EBELN", "<%=EBELN%>");
		param.put("WAREKY", "<%=wareky%>");

		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
	}
	
	function scanEbeln(){
		var param = new DataMap();
		var ebeln = $('#EBELN').val();
		
		param.put("EBELN", ebeln);
		param.put("WAREKY", "<%=wareky%>");

		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
		
		$('#EBELN').val("");
	}
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if( gridId == "gridList" && dataLength < 1 ){
			location.href="/mobile/MRL19.page";
		}else{
			showMain();	
		}
	}
	
	function showMain() {
		$("#detailInfo").hide();
		$("#main").show();
	}
	
 	function clearText(data){
		if(data!=null||data!=""){
	    	data.value="";
	    }      
	}

 	function showPre(){
 		location.href="/mobile/MRL19.page";
 	}
 	
</script>
</head>
<body>
	<div class="main_wrap" id="main">
	<div id="main_container">
		<div class="tem5_content">
			<div class="tableWrap_search section">
				<table class="util" id="MPT02TOP">
					<colgroup>
						<col width="100" />
					</colgroup>
					<tr>
						<th CL='STD_EBELN'>&nbsp;&nbsp;&nbsp;</th> <!-- 선택바코드  -->
						<td>
							<input type="text" class="text" id="EBELN" onfocus="clearText(this)" onkeypress="commonUtil.enterKeyCheck(event, 'scanEbeln()')" style="height: 35px;"/>
						</td>
						<td rowspan="3">
							<input type="button" CL="STD_DISPLAY" class="bt" onclick="scanEbeln()"/> <!-- value="선택" -->
						</td>
					</tr>
				</table>
				<div class="tableHeader">
					<table style="width: 100%">
						<colgroup>
							<col width="40" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
						</colgroup>
						<thead>
							<tr>
								<th CL='STD_NUMBER'>번호</th>
								<th CL='STD_EBELN'>운송지시번호</th>
								<th CL='STD_EXRECV'>입고예정</th>
								<th CL='STD_EXRECP'>입고완료</th>
								<th CL='STD_EXSHIP'>출고예정</th>
								<th CL='STD_ALLOCA'>할당완료</th>
								<th CL='STD_PICKED'>피킹완료</th>
								<th CL='STD_SHIPED'>출고완료</th>
								<th CL='STD_EXSHEC'>SEHC 입고예정</th>
								<th CL='STD_EXSHECP'>SEHC 입고완료</th>
							</tr>
						</thead>
					</table>				
				</div>					
				<div class="tableBody">
					<table style="width: 100%">
						<colgroup>
							<col width="40" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rownum">1</td>
								<td GCol="text,EBELN"></td>
								<td GCol="check,EXRECV"></td>
								<td GCol="check,EXRECP"></td>
								<td GCol="check,EXSHIP"></td>
								<td GCol="check,ALLOCA"></td>
								<td GCol="check,PICKED"></td>
								<td GCol="check,SHIPED"></td>
								<td GCol="check,EXSHEC"></td>
								<td GCol="check,EXSHECP"></td>
							</tr>
						</tbody>
					</table>
				</div>
				</div>
				<!-- end table_body -->
				<div class="footer_5">
					<table>
						<tr>
							<td onclick="showPre()"><label CL='STD_CDSCAN'></label></td>
						</tr>
					</table>
				</div><!-- end footer_5 -->	
			</div>
	</div>
	</div>
</body>