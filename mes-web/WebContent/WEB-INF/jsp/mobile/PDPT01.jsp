<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String BARCOD = request.getParameter("BARCOD");
	String TASKKY = request.getParameter("TASKKY");
	String FLAG = request.getParameter("FLAG");
	if(BARCOD == null){
		BARCOD = "";
	}
	if(TASKKY == null){
		TASKKY = "";
	}
	if(FLAG == null){
		FLAG = "";
	}
%>
<!doctype html>
<head>
<style type="text/css">
button {float: right; }
input:read-only {background-color: #e2e2e2;}
select:DISABLED {background-color: #e2e2e2;}
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
			module : "WmsMobilePutaway",
			command : "PDPT01",
			gridMobileType : true,
			emptyMsgType:false
		});
		
		if("<%=TASKKY%>" != "") {
			$("#TASKKY").val("<%=TASKKY%>");
			if("<%=FLAG%>" != "") {
				$("#FLAG").val("<%=FLAG%>");
			}
			var param = inputList.setRangeParam("searchArea");
			param.put("TASKKY", $("#TASKKY").val());
			param.put("WAREKY", "<%=wareky%>");
			searchList(param);
		}
		
		$("#TR1").hide();
		if($("#TASKKY").val().length == 0){
			$("#TASKKY").focus();
		} else {
			$("#TASKKY").select();
		}
	});

	function searchList(param){
		var json = netUtil.sendData({
			url : "/mobile/MobilePutaway/json/PDPT01SKUCNT.data",
			param : param
		});
		
		if(json && json.data["CNT"] > 0){
			gridList.gridList({
				id : "gridList",
				param : param
			});
			
			var js = netUtil.sendData({
				url : "/mobile/MobilePutaway/json/PDPT01CNT.data",
				param : param
			});
			var js2 = netUtil.sendData({
				url : "/mobile/MobilePutaway/json/PDPT01SUBCNT.data",
				param : param
			});
			
			$("#COMPCNT").val(Number(js.data["CNT"]));   //전체 건수
			$("#COMPCNT2").val(Number(js.data["CNT"])-Number(js2.data["CNT"]));   //현재까지 완료된 건수
			$("#QTCOMP_L7141").val(Number(js.data["QTTAOR"]));   //전체 수량
			$("#QTCOMP_L7141_2").val(Number(js.data["QTCOMP"]));   //현재까지 완료된 수량
			$("#UOMKEY2").val(js.data["UOMKEY"]);   //전체 수량단위
			$("#UOMKEY3").val(js.data["UOMKEY"]);   //현재까지 완료된 수량 단위
			
			if(js2.data["CNT"] == 1 && $("#FLAG").val() == ""){
				oneRowStart();
			}
			if($("#FLAG").val() != ""){
				$("#FLAG").val("");
			}
			if(js2.data["CNT"] == 0){
				resetGrid();
				commonUtil.msgBox("MOBILE_M0001");
			}
		} else {
			resetGrid();
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

	//아이템별 적치(PDPT01_POP) 시작버튼
	function start(){
		if(validate.check("searchArea")){
			if(gridList.getGridDataCount("gridList") > 0) {
				var gridCnt = gridList.getGridDataCount("gridList");
				if(gridCnt > 0){
					var param = new DataMap();
					param.put("TASKKY", $("#TASKKY").val());
					param.put("WAREKY", "<%=wareky%>")
					
					var json = netUtil.sendData({
						url : "/mobile/MobilePutaway/json/PDPT01.data",
						param : param
					});
					
					if(json && json.data) {
						var list = json.data;
						var paramStr = $("#TASKKY").attr("id")+"="+$("#TASKKY").val();
						location.href="/mobile/PDPT01_POP.page?"+paramStr;
					} 
				}
			} else {
				commonUtil.msgBox("COMMON_M0048");   //작업 대상이 선택되지 않았습니다.
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

	function showMain() {
		window.top.menuOpen();
	}

	//ROW가 1줄일 때 POP화면으로 넘어가기
	function oneRowStart(){
		if(validate.check("searchArea")){
			var param = new DataMap();
			param.put("TASKKY", $("#TASKKY").val());
			param.put("WAREKY", "<%=wareky%>")
			var json = netUtil.sendData({
				url : "/mobile/MobilePutaway/json/PDPT01.data",
				param : param
			});
			
			if(json && json.data) {
				//var list = json.data;
				var paramStr = $("#TASKKY").attr("id")+"="+$("#TASKKY").val();
				location.href="/mobile/PDPT01_POP.page?"+paramStr;
			}
		}
	}

	function resetGrid(){
		$("#COMPCNT").val("");
		$("#COMPCNT2").val("");
		$("#QTCOMP_L7141").val("");
		$("#QTCOMP_L7141_2").val("");
		$("#UOMKEY2").val("");
		$("#UOMKEY3").val("");
		gridList.resetGrid("gridList");
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
					<div style="display:none;"><input type="text" class="text" id="FLAG" name="FLAG"/>
					</div>
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
										<input type="text" class="text" name="TASKKY" id="TASKKY" style="text-align: center;" onfocus="fn_onfocus(this.id)" onkeydown="keyDownEvent(event)" validate="required"/>
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
						<table style="width:1000px;"> 
							<colgroup>
								<col width="20px" />
								<col width="35px" />
								<col width="80px" />
								<col width="50px" />
								<col width="100px" />
								<col width="60px" />
								<col width="55px" />
								<col width="55px" />
								<col width="35px" />
								<col width="55px" />
								<col width="55px" />
								<col width="55px" />
							</colgroup>
							<thead>
								<tr class="thead">
									<th CL='STD_NO'>순번</th>
									<th CL='STD_LOCAKY'>지번</th>
									<th CL='STD_TASKIT'>작업순번</th>
									<th CL='STD_SKUKEY'>품목코드</th>
									<th CL='STD_DESC01'>품명</th>
									<th CL='STD_BARCOD'>88바코드</th>
									<th CL='STD_QTTAOR'>작업수량</th>
									<th CL='STD_QTCOMP'>완료수량</th>
									<th CL='STD_UOMKEY'>단위</th>
									<th CL='STD_LOTA11'>제조일자</th>
									<th CL='STD_LOTA12'>입고일자</th>
									<th CL='STD_LOTA13'>유통기한</th>
								</tr>
							</thead>
						</table>
					</div>
					<div class="tableBody">
						<table style="width:1000px;">
							<colgroup>
								<col width="20px" />
								<col width="35px" />
								<col width="80px" />
								<col width="50px" />
								<col width="100px" />
								<col width="60px" />
								<col width="55px" />
								<col width="55px" />
								<col width="35px" />
								<col width="55px" />
								<col width="55px" />
								<col width="55px" />
							</colgroup>
							<tbody id="gridList">
								<tr CGRow="true">
									<td GCol="rownum">순번</td>
									<td GCol="text,LOCASR">지번</td>
									<td GCol="text,TASKIT">작업순번</td>
									<td GCol="text,SKUKEY">품목코드</td>
									<td GCol="text,DESC01">품명</td>
									<td GCol="text,EANCOD">88바코드</td>
									<td GCol="text,QTTAOR" class="gridColInputNumber">작업수량</td>
									<td GCol="text,QTYTOT" class="gridColInputNumber">완료수량</td>
									<td GCol="text,SUOMKY" style="text-align:center">단위</td>
									<td GCol="text,LOTA11" GF="D 8">제조일자</td>
									<td GCol="text,LOTA12" GF="D 8">입고일자</td>
									<td GCol="text,LOTA13" GF="D 8">유통기한</td>
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
						<td class=f_1 onclick ="showMain()" width="50%"><label CL='BTN_CLOSE'></label></td>
						<td class=f_1 onclick ="start()" width="50%"><label CL='BTN_IFSTAT'></label></td>
					</tr>
				</table>
			</div><!-- end footer_5 -->	
		</div>
	</div>
</body>