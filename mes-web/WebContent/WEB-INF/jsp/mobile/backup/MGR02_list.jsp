<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	request.setCharacterEncoding("UTF-8");
	String SEBELN = request.getParameter("SEBELN");
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
			command : "MGR02",
			bindArea : "searchArea",
			gridMobileType : true
	    });
		searchList();
	});
	
	function searchList(){
		var param = new DataMap();
		param.put("SEBELN", "<%=SEBELN%>");
		param.put("WAREKY", "<%=wareky%>");
		
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
		
		netUtil.send({
			module : "Mobile",
			command : "MGR02TOP",
			bindId : "MGR02TOP",
			sendType : "map",
			bindType : "field",
			param : param
		});
		showMain();
	}
	
	function showMain() {
		$("#detailInfo").hide();
		$("#main").show();
	}
	
	function savaData(){
		var param = new DataMap();
		var list = gridList.getGridData("gridList");
		param.put("list", list);
		param.put("WAREKY","<%=wareky%>");

		var json = netUtil.sendData({
			url:"/mobile/Mobile/json/SaveMGR02.data",
			param : param
		});
		
		if(json.data.length > 5 && json.data.length != 10){
			var msgList = json.data.split("†");
			var msgTxt = commonUtil.getMsg(msgList[0], (msgList.length > 1 ? msgList[1].split("/") : null));
			commonUtil.msg(msgTxt);
			return;
		} 
		
		if(json && json.data){
			commonUtil.msgBox("MASTER_M0564");
			
			searchList();
		}else{
			commonUtil.msgBox("VALID_M0002");
		}
			
	}
 
 	function clearText(data){
		if(data!=null||data!=""){
	    	data.value="";
	    }      
	}
	
 	function showPre(){
 		location.href="/mobile/MGR02.page";
 	}
</script>
</head>
<body>
	<div class="main_wrap" id="main">
	<div id="main_container">
		<div class="tem5_content">
			<div class="tableWrap_search section">
				<table class="util" id="MGR02TOP">
					<colgroup>
						<col width="100" />
					</colgroup>
					<tr >
						<th CL='STD_EBELN'></th>
						<td>
							<input type="text" name="SEBELN" readonly="readonly"/>
						</td>
					</tr>
					<tr>
						<th CL='STD_DOCTXT'></th>
						<td>
							<input type="text" name="DOCTXT" readonly="readonly"/>
						</td>
					</tr>
				</table>
				<div class="tableHeader">
					<table style="width: 100%">
						<colgroup>
								<col width="30px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px" />
								<col width="100px" />
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px" />
								<col width="100px"/>
								<col width="100px" />
								<col width="100px"/>
						</colgroup>
						<thead>
							<tr>
								<th CL='STD_NUMBER'>번호</th>
								<th CL='STD_RCVDAT'>입고예정일자</th> 
								<th CL='STD_LOTA12'>입고일자</th> 
								<th CL='STD_AREAKY'>입고창고</th>
								<th CL='STD_AREANM'>창고명</th>
								<th CL='STD_SKUKEY'>품번</th>
								<th CL='STD_DESC01'>품명</th>
								<th CL='STD_QTYRCV'>입고수량</th>
								<th CL='STD_UOMKEY'>단위</th>
								<th CL='STD_LOCAKY'>지번</th>
								<th CL='STD_LOTA11'>제조일자</th>
								<th CL='STD_LOTA13'>유통기한</th>
								<th CL='STD_LOTA10'>통화</th>
								<th CL='STD_LOTA16'>매입단가</th>
								<th CL='STD_LOTA17'>매출단가</th>
							</tr>
						</thead>
					</table>				
				</div>					
				<div class="tableBody">
					<table style="width: 100%">
						<colgroup>
								<col width="30px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px" />
								<col width="100px" />
								<col width="100px"/>
								<col width="100px" />
								<col width="100px"/>
								<col width="100px" />
								<col width="100px"/>
								<col width="100px" />
								<col width="100px"/>
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rownum">1</td>
								<td GCol="text,ASNDAT"></td>
								<td GCol="text,DOCDAT"></td>
								<td GCol="text,AREAKY"></td>
								<td GCol="text,AREANM"></td>
								<td GCol="text,SKUKEY"></td>
								<td GCol="text,DESC01"></td>					
								<td GCol="text,QTYRCV"></td>
								<td GCol="text,UOMKEY"></td>
								<td GCol="text,LOCAKY"></td>
								<td GCol="text,LOTA11"></td>
								<td GCol="text,LOTA13"></td>
								<td GCol="text,LOTA10"></td>
								<td GCol="text,LOTA16"></td>
								<td GCol="text,LOTA17"></td>
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
							<td class=f_1 onclick ="savaData()"><label CL='BTN_SAVE'></label></td>
						</tr>
					</table>
				</div><!-- end footer_5 -->	
			</div>
	</div>
	</div>
</body>