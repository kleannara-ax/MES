<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String ZONEKY = request.getParameter("ZONEKY");
	String TASWKY = request.getParameter("TASWKY");
	String BARCOD = request.getParameter("BARCOD");
	String TASKKY = request.getParameter("TASKKY");
	String TASKIT = request.getParameter("TASKIT");
	String Flag = request.getParameter("Flag");
	
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
	if(TASKIT == null){
		TASKIT = "";
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
	var Flag;

	$(document).ready(function(){
		gridList.setGrid({
			id : "gridList",
			editable : false,
			module : "WmsMobileOutboundPicking",
			command : "PDPK01",
			gridMobileType : true,
			emptyMsgType:false
		});

		$("#TR0").show();
		$("#TR1").hide();
		
		if("<%=TASKKY%>" != "") {
			$("#TASKKY").val("<%=TASKKY%>");
			
			var param = inputList.setRangeParam("searchArea");
			param.put("TASKKY", $("#TASKKY").val());
			param.put("WAREKY", "<%=wareky%>");
			
			/*Flag: N:이전 버튼 클릭 시
			        Y:입고완료 후          */
			Flag = '<%=Flag%>';
			if(Flag == 'N'){
				Databind();
			}
		}
		$("#TASKKY").focus();
	});
	
	/*PDPK01_POP에서 이전 버튼 눌렀을 경우*/
	function Databind(){
		var param = new DataMap();
		param.put("TASKKY","<%=TASKKY%>");
		param.put("BARCOD","<%=BARCOD%>");
		param.put("WAREKY","<%=wareky%>");
		
		$('#TASKKY').val("<%=TASKKY%>");
		$('#BARCOD').val("<%=BARCOD%>");
		
		gridList.gridList({
			id : "gridList",
			param : param
		});
		
		$('#BARCOD').select();
		$('#BARCOD').focus();
		ConfirmData(param);
	}
	
	function searchList(param){
		var json = netUtil.sendData({
			url : "/mobile/Mobile/json/PDPK01SKUCNT.data",
			param : param
		});
		
		if(json && json.data["CNT"] > 1){
			gridList.gridList({
				id : "gridList",
				param : param
			});
		}else if(json.data["CNT"] == 1){ //데이터가 한개있을 경우 바로 피킹화면으로 이동
			start();
		}else{
			clear();
		}
		ConfirmData(param);
	}

	//하단에 완료건수,수량 데이터 들어가는 부분
	function ConfirmData(param){
		var js = netUtil.sendData({
			url : "/mobile/Mobile/json/PDPK01CNT.data",
			param : param
		});
		
		var js2 = netUtil.sendData({
			url : "/mobile/Mobile/json/PDPK01SUBCNT.data", //완료건수, 수량
			param : param
		});
		
		var js3 = netUtil.sendData({
			url : "/mobile/Mobile/json/PDPK01UOM.data", //단위
			param : param
		});
		
		$("#TASKKY").val(param.get("TASKKY"));
		$("#COMPCNT").val(Number(js.data["CNT"]));
		$("#COMPCNT2").val(Number(js.data["CNT"])-Number(js2.data["CNT"]));
		$("#QTCOMP_L7141").val(Number(js.data["QTTAOR"]));
		$("#QTCOMP_L7141_2").val(Number(js.data["QTCOMP"]));
		$("#UOMKEY2").val(js3.data["UOMKEY"]);
		$("#UOMKEY3").val(js3.data["UOMKEY"]);
		
		PlaySound('s');
		$('#BARCOD').focus();
	}
	
	//작업지시번호 scan
	function scanTask(){
		var taskky = $("#TASKKY").val();
		var param = new DataMap();
		param.put("WAREKY", "<%=wareky%>");
		param.put("TASKKY", taskky);
		
		if(taskky == null || taskky == ""){
			$('#TASKKY').focus();
			PlaySound('e');
			alert("작업지시번호를 입력하세요.");
			//commonUtil.msgBox("MOBILE_M0009");	//바코드를 스캔하세요.
		
		}else{
			var json = netUtil.sendData({
				url : "/mobile/Mobile/json/PDPK01SUBCNT.data",
				param : param
			});
			
			if(json.data["CNT"] == 0){
				PlaySound('e');
				$('#TASKKY').val("");
				$('#BARCOD').val("");
				$('#TASKKY').focus();
				commonUtil.msgBox("MOBILE_M0001");	//작업지시번호가 존재하지 않습니다.
				clear();
				return;
			}else{
				$('#BARCOD').val("");
				$('#BARCOD').focus();
			}
			searchList(param);
		}
	}
	
	//바코드 스캔
	function scanBarcod(){
		var taskky = $("#TASKKY").val();
		var barcod = $("#BARCOD").val();
		
		if(barcod == null || barcod == ""){
			$('#BARCOD').focus();
			PlaySound('e');
			commonUtil.msgBox("MOBILE_M0009");	//바코드를 스캔하세요.
			return;
			
		}else if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			param.put("TASKKY", $("#TASKKY").val());
			param.put("BARCOD", $("#BARCOD").val());
			param.put("WAREKY", "<%=wareky%>");
			
			//바코드만 입력했을 경우,맨위에 있는 작업지시번호 Insert
			var json = netUtil.sendData({
				module : "WmsMobileOutboundPicking",
				command : "PDPK01",
				param : param
			});
			
			if(json.data.length > 0){
				var newtaskky = json.data[0].TASKKY; //맨위에 있는 작업지시번호
				param.put("TASKKY",newtaskky);
				
				$("#TASKKY").val(newtaskky);
				searchList(param);
			
			}else if(json.data.length == 0){
				PlaySound('e');
				alert("존재하지않는 바코드입니다.");
				clear();
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
	
	//시작버튼
	function start(){
		/*작업지시번번호또는 바코드를 입력하지 않고 시작버튼을 눌렀을 경우*/
		var taskky = $('#TASKKY').val().trim();
		var taskit = gridList.getColData("gridList", gridList.getFocusRowNum("gridList"), "TASKIT").trim();
		var barcod = $('#BARCOD').val().trim();
		if(taskky == "" && barcod == ""){
			PlaySound('e');
			alert("작업지시번호 또는 바코드를 입력하세요.");
			return;
		}else{
			var fRow = gridList.getFocusRowNum("gridList");
			var row = gridList.getRowData("gridList", fRow);
			var rowCnt = gridList.getGridDataCount("gridList");
			
			var paramStr = "TASKKY="+ $("#TASKKY").val() + "&TASKIT="+ taskit + "&BARCOD="+ $("#BARCOD").val();
			location.href="/mobile/PDPK01_POP.page?"+ paramStr+"&FROW="+fRow;
		}
	}
	
	function clear(){
		$("#COMPCNT").val("");
		$("#COMPCNT2").val("");
		$("#QTCOMP_L7141").val("");
		$("#QTCOMP_L7141_2").val("");
		$("#UOMKEY2").val("");
		$("#UOMKEY3").val("");
		gridList.resetGrid("gridList");
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

/* 	function canWorker(){
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
	} */
	
	//메뉴화면으로 이동
	function showMain(){
		window.top.menuOpen();
	}
	
	function fn_onfocus(objId){
		$("#"+objId).select();
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
									<input type="text" class="text" name="TASKKY" id="TASKKY" style="text-align: center;" onfocus="fn_onfocus(this.id)" onkeypress="commonUtil.enterKeyCheck(event, 'scanTask()')" />
								</td>
							</tr>
							<tr id="TR1">
								<td colspan="4">
									<input type="text" class="text" id="FAIL_TEXT" style="color:white;text-align:center;background-color:red;font-size: 20px;font-weight: bold;"/>
								</td>
							</tr>
							<tr>
								<th CL='STD_BARCOD'>바코드</th>
								<td colspan="2">
									<input type="text" class="text" name="BARCOD" id="BARCOD" style="text-align: center;" onfocus="fn_onfocus(this.id)" onkeypress="commonUtil.enterKeyCheck(event, 'scanBarcod()')" />
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
								<col width="30px"/>
								<col width="30px"/>
								<col width="20px"/>
								<col width="30px"/>
								<col width="20px"/>
								<col width="40px"/>
								<col width="30px"/>
								<col width="20px"/>
								<col width="20px"/>
								<col width="20px"/>
							</colgroup>
							<thead>
								<tr class="thead">
									<th CL='STD_NO'>순번</th>
									<th CL='STD_TASKKY'>작업지시번호</th>
									<th CL='STD_TASKIT'>아이템번호</th>
									<th CL='STD_LOCAKY'>지번</th>
									<th CL='STD_RSTAIT'>상태</th>
									<th CL='STD_SKUKEY'>품목코드</th>
									<th CL='STD_DESC01'>품명</th>
									<th CL='STD_BARCOD'>바코드</th>
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
								<col width="30px" />
								<col width="30px" />
								<col width="20px" />
								<col width="30px" />
								<col width="20px" />
								<col width="40px" />
								<col width="30px" />
								<col width="20px" />
								<col width="20px" />
								<col width="20px" />
							</colgroup>
							<tbody id="gridList">
								<tr CGRow="true">
									<td GCol="rownum"></td>
									<td GCol="text,TASKKY"></td>
									<td GCol="text,TASKIT"></td>
									<td GCol="text,LOCAKY"></td>
									<td GCol="text,STATIT"></td>
									<td GCol="text,SKUKEY"></td>
									<td GCol="text,DESC01"></td>
									<td GCol="text,EANCOD"></td>
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