<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String ZONEKY = request.getParameter("ZONEKY");
	String TASWKY = request.getParameter("TASWKY");
	String BARCOD = request.getParameter("BARCOD");
	String TASKKY = request.getParameter("TASKKY");
	
	if(ZONEKY == null){
		ZONEKY = "";
	}
	if(TASWKY == null){
		TASWKY = "";
	}
	if(BARCOD == null){
		BARCOD = "";
	}
	if(TASKKY == null){
		TASKKY = "";
	}
%>
<!doctype html>
<head>
<style type="text/css">
button {float: right; }
input:read-only { 
    background-color: #e2e2e2;
}
select:DISABLED {
	background-color: #e2e2e2;
}
</style>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>Mobile WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script>
	var col = "";
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			editable : false,
			module : "WmsMobileOutboundPicking",
			command : "PDPK02",
			gridMobileType : true,
			emptyMsgType:false
	    });
		
		if("<%=TASKKY%>" != "") {
			$("#TASKKY").val("<%=TASKKY%>");
			var param = inputList.setRangeParam("searchArea");
			param.put("TASKKY", $("#TASKKY").val());
			param.put("WAREKY", "<%=wareky%>");
			searchList(param);
		}
		$("#TR0").show();
		$("#TR1").hide();
		if($("#TASKKY").val().length == 0){			
			$("#TASKKY").focus();
		} else {
			$("#TASKKY").select();
		}
	});
	
	function searchList(param){
		var json = netUtil.sendData({
			url : "/mobile/Mobile/json/PDPK02SKUCNT.data",
			param : param
		});
		
		if(json && json.data["CNT"] > 0){
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
			var js = netUtil.sendData({
				url : "/mobile/Mobile/json/PDPK02CNT.data",
				param : param
			});
			
			var js2 = netUtil.sendData({
				url : "/mobile/Mobile/json/PDPK02SUBCNT.data",
				param : param
			});
			
			var js3 = netUtil.sendData({
				url : "/mobile/Mobile/json/PDPK02UOM.data",
				param : param
			});
			
			$("#COMPCNT").val(Number(js.data["CNT"]));
			$("#COMPCNT2").val(Number(js.data["CNT"])-Number(js2.data["CNT"]));
			$("#QTCOMP_L7141").val(Number(js.data["QTTAOR"]));
			$("#QTCOMP_L7141_2").val(Number(js.data["QTCOMP"]));
			$("#UOMKEY2").val(js3.data["UOMKEY"]);
			$("#UOMKEY3").val(js3.data["UOMKEY"]);
		} else {
			$("#COMPCNT").val("");
			$("#COMPCNT2").val("");
			$("#QTCOMP_L7141").val("");
			$("#QTCOMP_L7141_2").val("");
			$("#UOMKEY2").val("");
			$("#UOMKEY3").val("");
			gridList.resetGrid("gridList");
			commonUtil.msgBox("MOBILE_M0001");
		}
		$("#TASKKY").select();
	}

	function keyDownEvent(event){
		if(event.keyCode == "13"){
			if(validate.check("searchArea")){
				var param = inputList.setRangeParam("searchArea");
				param.put("TASKKY", $("#TASKKY").val());
				param.put("WAREKY", "<%=wareky%>");
				searchList(param);
				
			}
		}
	}

	function linkPopCloseEvent(data){
		var VALUE_COL = data.get("VALUE_COL");
		var TEXT_COL = data.get("TEXT_COL");
		if(col=='TASKKY'){
			$("#TASKKY").val(VALUE_COL);
			$("#BARCOD").focus();
		}
	}
	
	function linkPopupOpen(colName){
		col = colName;
		if(colName == 'TASKKY'){
			var $obj = $("#ZONEKY");//분배장 코드(ZONEKY를 가지고 조회)
			var param = new DataMap();
			param.put("SEARCH_COL","작업장");    //조회조건명
			param.put("HEAD_COL1","배치번호");//헤더1 명칭
			param.put("HEAD_COL2","작업존");  //헤더2 명칭
			param.put("COMMAND","COMTASWKY");     //sqlMap ID
			param.put("SEARCH_VAL",$obj.val());  //조회조건 값
			
			mobile.linkPopOpen('/mobile/Common_search.page', param);
		}
	}
	
	function start(){
		if(validate.check("searchArea")){
			if(gridList.getGridDataCount("gridList") > 0) {				
				var gridCnt = gridList.getGridDataCount("gridList");
				if(gridCnt > 0){
					var param = new DataMap();
					param.put("TASKKY", $("#TASKKY").val());
					param.put("WAREKY", "<%=wareky%>")
					
					var json = netUtil.sendData({
						url : "/mobile/Mobile/json/PDPK02SKU.data",
						param : param
					});
					
					if(json && json.data) {
						var list = json.data;
						var paramStr = $("#TASKKY").attr("id")+"="+$("#TASKKY").val();
						location.href="/mobile/PDPK02_POP.page?"+paramStr;
					} else {
						
					}
				}else{
				}
			} else {
				commonUtil.msgBox("COMMON_M0048");
			}
		}
	}
	function gridListEventDataBindEnd(gridId, dataLength){
		if(dataLength > 0){
			PlaySound("s");
		}else{
			PlaySound("e");
		}
	}
	function setFocusNext(){
		$("#TASWKY").focus();
	}

	function canWorker(){
		var param = new DataMap();
		var list = gridList.getSelectData("gridList");
		
		if(list.length <1){
			commonUtil.msgBox("VALID_M0006");
			return;
		}

		param.put("list",list);
		param.put("EANCOD",$("#BARCOD").val());
		var json = netUtil.sendData({
			url:'/mobile/Mobile/json/cartonWorkChangePDSP60.data',
			param : param
		});
		if(json && json.data && json.data > 0){
			commonUtil.msgBox("MOBILE_M0029");
			searchList("");
		}else{
			commonUtil.msgBox("MOBILE_M0030");
		}
	}
	
	function showMain() {
		window.top.menuOpen();
	}
</script>
</head>
<body>
	<div class="main_wrap">
		<div class="tem4_content">
			<div class="select_box" id="bindArea">
				<div id="searchArea">				
					<table>
						<colgroup>
							<col width="120px" />
							<col />
							<col width="80px" />
							<col />
						</colgroup>
						<tbody>
							<tr>
								<th CL='STD_TASKKY'>작업지시번호</th>
								<td colspan="2">
									<input type="text" class="text" name="TASKKY" id="TASKKY" style="text-align: center;" onkeydown="keyDownEvent(event)" validate="required"/>
								</td>
							</tr>
							<tr id="TR1">
								<td colspan="4">
									<input type="text" class="text" id="FAIL_TEXT" style="color:white;text-align:center;background-color:red;font-size: 20px;font-weight: bold;"/>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<hr />
				<div class="tableWrap_search section" style="margin-bottom: 0px;">
					<div class="tableHeader">
						<table style="width: 900px"> 
							<colgroup>
								<col width="10px" />
<!-- 								<col width="30px" /> -->
								<col width="20px" />
								<col width="20px" />
								<!-- <col width="30px" /> -->
								<col width="20px" />
								<col width="20px" />
								<col width="30px" />
								<col width="20px" />
								<col width="20px" />
								<col width="20px" />
							</colgroup>
							<thead>
								<tr class="thead">
									<th CL='STD_NO'>순번</th>
									<th CL='STD_LOCAKY'>지번</th>
<!-- 									<th GBtnCheck="true"></th> -->
									<th CL='STD_RSTAIT'>상태</th>
									<!-- <th CL='STD_TASKIT'>아이템번호</th> -->
									<th CL='STD_SKUKEY'>품목코드</th>
									<th CL='STD_DESC01'>품명</th>
									<th CL='STD_TRNUSR'>바코드</th>
									<th CL='STD_QTTAOR'>작업수량</th>
									<th CL='STD_QTCOMP'>완료수량</th>
									<th CL='STD_UOMKEY'>단위</th>
								</tr>
							</thead>
						</table>				
					</div>
					<div class="tableBody">
						<table style="width: 900px">
							<colgroup>
								<col width="10px" />
<!-- 								<col width="30px" /> -->
								<col width="20px" />
								<col width="20px" />
								<!-- <col width="30px" /> -->
								<col width="20px" />
								<col width="20px" />
								<col width="30px" />
								<col width="20px" />
								<col width="20px" />
								<col width="20px" />
							</colgroup>
							<tbody id="gridList">
								<tr CGRow="true">
									<td GCol="rownum"></td>
									<td GCol="text,LOCAKY"></td>
<!-- 									<td GCol="rowCheck"></td> -->
									<td GCol="text,STATIT"></td>
									<!-- <td GCol="text,TASKIT"></td> -->
									<td GCol="text,SKUKEY"></td>
									<td GCol="text,DESC01"></td>
									<td GCol="text,TRNUSR"></td>
									<td GCol="text,QTTAOR" class="gridColInputNumber"></td>
									<td GCol="text,QTCOMP" class="gridColInputNumber"></td>
									<td GCol="text,UOMKEY" style="text-align:center"></td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
			</div>
			
			<div class="select_box">
				<table>
					<colgroup>
						<col width="100px"/>
						<col width="50px"/>
						<col width="50px"/>
						<col width="50px"/>
						<col width="50px"/>
						<col width="50px"/>
						<col width="50px"/>
					</colgroup>
					<tbody>
						<tr>
							<th  CL='STD_COMPCNT'>완료건수</th>
							<td CL='STD_ALL'>전체</td>
							<td>
								<input type="text" class="text gridColInputNumber" name="COMPCNT" id="COMPCNT" readonly/>
							</td>
							<td CL='STD_CNT'>count</td>
							<td CL='STD_INCLU'>중</td>
							<td>
								<input type="text" class="text gridColInputNumber" name="COMPCNT2" id="COMPCNT2" readonly/>
							</td>
							<td CL='STD_CNT'>count</td>
						</tr>
						<tr>
							<th CL='STD_QTCOMP_L7141'>완료수량</th>
							<td CL='STD_ALL'>전체</td>
							<td>
								<input type="text" class="text gridColInputNumber" name="QTCOMP_L7141" id="QTCOMP_L7141" readonly/>
							</td>
							<td>
								<input type="text" class="text" name="UOMKEY2" id="UOMKEY2" style="text-align:center" readonly/>
							</td>
							<td CL='STD_INCLU'>중</td>
							<td>
								<input type="text" class="text gridColInputNumber" name="QTCOMP_L7141_2" id="QTCOMP_L7141_2" readonly/>
							</td>
							<td>
								<input type="text" class="text" name="UOMKEY3" id="UOMKEY3" style="text-align:center" readonly/>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			
			<!-- end table_body -->
			<div class="footer_5">
				<table>
					<tr>
						<!-- <td class="f_1" onclick ="canWorker()" width="50%"><label CL='BTN_CANWORKER'></label></td> -->
						<td class=f_1 onclick ="showMain()" width="50%"><label CL='BTN_CLOSE'></label></td>
						<td class=f_1 onclick ="start()" width="50%"><label CL='BTN_IFSTAT'></label></td>
					</tr>
				</table>
			</div><!-- end footer_5 -->	
		</div>
	</div>
</body>