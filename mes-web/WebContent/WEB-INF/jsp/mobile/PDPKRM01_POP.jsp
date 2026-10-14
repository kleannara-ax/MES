<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String ZONEKY = request.getParameter("ZONEKY");
	String TASWKY = request.getParameter("TASWKY");
	String BARCOD = request.getParameter("BARCOD");
	String CHKCOD = request.getParameter("CHKCOD");
	String TASKKY = request.getParameter("TASKKY");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>Mobile WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<style type="text/css">
button {float: right; }
input:read-only { 
    background-color: #e2e2e2;
}
select:DISABLED {
	background-color: #e2e2e2;
}
</style>
<script>
	var gridCommand = ""; //이전 조회 화면에서 조회 형태에 따라 쿼리를 변경해 주기 위한 변수
	var leftChk     = ""; // < 버튼 쿼리 분기 체크용
	var rightChk    = ""; // > 버튼 쿼리 분기 체크용
	var stayChk     = ""; // <> 이동후 조회 내역 존재하지 않을경우 stay 조회
	var completeChk = true; //완료시 종료를 위해 체크
	var itemlist = [];
	var curIdx = 0;
	
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			editable : false,
			module : "WmsMobileOutboundPicking",
			command : "PDPKRM01SKU",
			gridMobileType : true,
			emptyMsgType:false
	    });
		$("#FAIL").hide();
		$("#SUCCESS").hide();
		searchList();
		
	});
	
	function allHide(){
		$("#QTSAVB").parent().parent('tr').removeClass("showrow");
		$("#QTSAVB").parent().parent().find('th').removeClass("showrow");
		$("#QTSAVB").parent().parent().find('td').removeClass("showrow");
		$("#QTSAVB").parent().parent('tr').addClass("hiderow");
		$("#QTSAVB").parent().parent().find('th').addClass("hiderow");
		$("#QTSAVB").parent().parent().find('td').addClass("hiderow");
	}
	
	function showQtt(){
		$("#QTSAVB").parent().parent('tr').removeClass("hiderow");
		$("#QTSAVB").parent().parent().find('th').removeClass("hiderow");
		$("#QTSAVB").parent('td').removeClass("hiderow");
		$("#QTSAVB").parent('td').addClass("showrow");
		$("#UOMKEY5").parent('td').removeClass("hiderow");
		$("#UOMKEY5").parent('td').addClass("showrow");
		$("#QTUALO").parent('td').removeClass("hiderow");
		$("#QTUALO").parent('td').addClass("showrow");
		$("#UOMKEY6").parent('td').removeClass("hiderow");
		$("#UOMKEY6").parent('td').addClass("showrow");
	}
	
	function showInputloc(){
		$("#QTSAVB").parent().parent('tr').removeClass("hiderow");
		$("#inputLOC").parent('td').removeClass("hiderow");
		$("#inputLOC").parent('td').addClass("showrow");
	}

	function showInputPTID(){
		$("#QTSAVB").parent().parent('tr').removeClass("hiderow");
		$("#inputPTID").parent('td').removeClass("hiderow");
		$("#inputPTID").parent('td').addClass("showrow");
	}
	
	function showInputNoSku(){
		$("#QTSAVB").parent().parent('tr').removeClass("hiderow");
		$("#inputNOSKU").parent('td').removeClass("hiderow");
		$("#inputNOSKU").parent('td').addClass("showrow");
	}
	
	
	function keyDownEvent($this, event){
		if(event.keyCode == "13"){
			if($this.id == "LOCAKY2"){
				if($("#LOCAKY2").val() == "") {
					PlaySound("e");
					allHide();
					showInputloc();
					$("#LOCAKY2").focus();
				} else {
					allHide();
					$("#TRNUAC").focus()
				}
			}
			
			if($this.id == "TRNUAC") {
				if($("#TRNUAC").val() == "") {
					PlaySound("e");
					allHide();
					showInputPTID();
					$("#TRNUAC").focus();
				} else if($("#LOCAKY2").val() == ""){
					PlaySound("e");
					allHide();
					showInputloc();
					$("#LOCAKY2").focus();
				} else {
					allHide();
					
					// 재고 확인로직
					var param = inputList.setRangeParam("searchArea");
					var clkRowSkukey = param.get("SKUKEY");	
					var chkRowKey = param.get("LOTNUM") 
									+ param.get("LOCAKY2") 
									+  param.get("TRNUAC");
					var inputValue = param.get("QTTAOR");
					
					param.put("WAREKY", "<%=wareky%>");
					
					// 피킹정보에 입력한 지번+실P/T ID 를 가지고 체크할거랑 같은 LOTNUM의 가용 수량을 찾는다
					var json = netUtil.sendData({
						url: "/mobile/Mobile/json/PDPKRM01QTSWRK.data",
						param: param
					});
					
					if(json.data["CNT"] > 0) {
						// LOCAKY 와 LOCAKY2가 같다면 이 지번에서 현재 선택한 TASKKY+TASKIT에 재고가 할당되어있는것이므로 가용수량에 더해준다.
						if($("#LOCAKY").val() == $("#LOCAKY2").val()){
							$("#QTSAVB").val((Number)(json.data["QTSIWH"]) + (Number)(inputValue));
						} else {
							$("#QTSAVB").val((Number)(json.data["QTSIWH"]));
						}
						
						// 출하문서번호와 출하문서 순번을 조회한다.
						var json = netUtil.sendData({
							url: "/mobile/Mobile/json/PDPKRM01SHPINFO.data",
							param: param
						});
						
						if(json && json.data) {
							
							// 조회한 출하문서 정보를 가지고 미할당수량을 구한다
							var shpoky = json.data["SHPOKY"];
							var shpoit = json.data["SHPOIT"];
							
							param.put("SHPOKY", shpoky);
							param.put("SHPOIT", shpoit);
							
							var js = netUtil.sendData({
								url: "/mobile/Mobile/json/PDPKRM01QTUALOCNT.data",
								param: param
							});
							
							if(js){
								var qtualo = js.CNT;
								
								// 입력가능 수량에 미할당수량을 더한 후 출력한다.
								$("#QTUALO").val((Number)(qtualo) + (Number)(inputValue));
								
								allHide();
								showQtt();
								$("#QTCOMP").focus();
							}
						}
					} 
					
					if(json.data["CNT"] == 0) {
						$("#QTUALO").val(0);
						showInputNoSku();
					}
					
				}
			} 

			if($this.id == "QTCOMP") {
				
				// 값이 무언가라도 다 들어와있을때
				if($("#LOCAKY2").val() != "" && $("#TRNUAC").val() != ""){
					// 피킹정보의 피킹수량이 입력가능 수량보다 작은지, 가용재고량보다 작은지 확인한다.
					// 만족하지 않으면 alert 띄우기
					if((Number)($("#QTUALO").val()) < (Number)($("#QTCOMP").val())){ 
						commonUtil.msgBox("OUT_M0132");
						return;
					}
					
					if((Number)($("#QTSAVB").val()) < (Number)($("#QTCOMP").val())){
						commonUtil.msgBox("IN_M0079", $("#SKUKEY").val());
						return;
					}
					
					// 만족하면 다음 step진행 - 피킹 완료를 진행한다.
					// 진행전에 입력정보랑 할당정보확인해서 같으면 바로 피킹진행
					if($("#LOCAKY").val() == $("#LOCAKY2").val() && $("#TRNUSR").val() == $("#TRNUAC").val()){
						distConfirm();
					} else {
						// 다르면 TASK 정보 delete - insert 후 피킹 진행
						changeTaskInfo();
						distConfirm();
					}
				}
				
				if($("#LOCAKY2").val() == "") {
					PlaySound("e");
					allHide();
					showInputPTID();
					$("#LOCAKY2").focus();
				}
				
				if($("#LOCAKY2").val() != "" && $("#TRNUAC").val() == "") {
					PlaySound("e");
					allHide();
					showInputloc();
					$("#TRNUAC").focus();
				}
			}
		}	
	}
	
		function searchList(){
		var param = new DataMap();
		param.put("TASKKY", "<%=TASKKY%>");
		param.put("WAREKY", "<%=wareky%>");

		var json = netUtil.sendData({
			url : "/mobile/Mobile/json/PDPKRM01SKU.data",
			param : param
		});
		
		if(json && json.data) {
			itemlist = json.data;
			var totalCnt = 0;
			var totalQtt = 0;
			var totalPage = itemlist.length;
			var curCnt = 0;
			var curQtt = 0;
			$("#PAGE").val(totalPage);
			for(var i = 0; i < itemlist.length; i++){
				if(itemlist[i].STATIT == "NEW") {
					totalCnt += 1;
				} else {
					totalCnt += 1;
					curCnt += 1;
				}
				totalQtt += Number(itemlist[i].QTTAOR);
				curQtt += Number(itemlist[i].QTCOMP);
			}
			$("#COMPCNT").val(totalCnt);
			$("#COMPCNT2").val(curCnt);
			$("#QTCOMP_L7141").val(totalQtt);
			$("#QTCOMP_L7141_2").val(curQtt);
			
			if(curCnt == totalCnt) {
				commonUtil.msgBox("MOBILE_M0006");
				screenClose();
			} else {
				showMainItem(itemlist);
			}
			
		} else {
			
		}
		
	}
	
	function showMainItem(itemlist){
		for(var i = 0; i < itemlist.length; i++){
			var data = itemlist[i];
			curIdx = i;
			if(data.STATIT == "NEW"){
				$("#TASKKY").val(data.TASKKY);
				$("#TASKIT").val(data.TASKIT);
				$("#LOCAKY").val(data.LOCAKY);
				$("#TRNUSR").val(data.TRNUSR);
				$("#PTLT12").val(data.PTLT12);
				$("#PTLT11").val(data.PTLT11);
				$("#SKUKEY").val(data.SKUKEY);
				$("#LOTNUM").val(data.LOTNUM);
				$("#DESC01").val(data.DESC01);
				$("#QTTAOR").val(data.QTTAOR);
				$("#UOMKEY").val(data.UOMKEY);
				$("#QTCOMP").val(data.QTTAOR);
				$("#UOMKEY2").val(data.UOMKEY2);
				$("#UOMKEY3").val(data.UOMKEY2);
				$("#UOMKEY4").val(data.UOMKEY2);
				$("#UOMKEY5").val(data.UOMKEY2);
				$("#UOMKEY6").val(data.UOMKEY2);
				$("#LOCAKY2").val("");
				$("#TRNUAC").val("");
				$("#LOCAKY2").focus();
				$("#PAGE2").val(curIdx+1);
				if(curIdx == 0){
					$(".footer_5 table td").eq(0).css("cursor", "not-allowed");
					$(".footer_5 table td label").eq(0).css("cursor", "not-allowed");
				} 
				if(curIdx == itemlist.length-1){
					$(".footer_5 table td").eq(3).css("cursor", "not-allowed");
					$(".footer_5 table td label").eq(3).css("cursor", "not-allowed");
				}
				return;
			}
		}
		
		
		commonUtil.msgBox("OUT_M0045");
		screenClose();
	}
	
	function showItem(index){
		if(index == 0){
			$(".footer_5 table td").eq(0).css("cursor", "not-allowed");
			$(".footer_5 table td label").eq(0).css("cursor", "not-allowed");
		} 
		
		if(index == itemlist.length-1){
			$(".footer_5 table td").eq(3).css("cursor", "not-allowed");
			$(".footer_5 table td label").eq(3).css("cursor", "not-allowed");
		} 
		
		if(index != 0) {
			$(".footer_5 table td").eq(0).css("cursor", "pointer");
			$(".footer_5 table td label").eq(0).css("cursor", "default");
		}
		
		if(index != itemlist.length-1){
			$(".footer_5 table td").eq(3).css("cursor", "pointer");
			$(".footer_5 table td label").eq(3).css("cursor", "default");
		}
		
		$("#LOCAKY2").val("");
		$("#TRNUAC").val("");
		$("#PAGE2").val(curIdx+1);
		var data = itemlist[index];
		$("#TASKKY").val(data.TASKKY);
		$("#TASKIT").val(data.TASKIT);
		$("#LOCAKY").val(data.LOCAKY);
		$("#TRNUSR").val(data.TRNUSR);
		$("#PTLT12").val(data.PTLT12);
		$("#PTLT11").val(data.PTLT11);
		$("#SKUKEY").val(data.SKUKEY);
		$("#LOTNUM").val(data.LOTNUM);
		$("#DESC01").val(data.DESC01);
		$("#QTTAOR").val(data.QTTAOR);
		$("#UOMKEY").val(data.UOMKEY);
		if(data.STATIT == "NEW") {			
			$("#QTCOMP").val(data.QTTAOR);
		} else {			
			$("#QTCOMP").val(data.QTCOMP);
		}
		$("#UOMKEY2").val(data.UOMKEY2);
		$("#UOMKEY5").val(data.UOMKEY2);
		$("#UOMKEY6").val(data.UOMKEY2);
		if(data.STATIT == "NEW"){
			$("#LOCAKY2").attr("readonly", false);
			$("#TRNUAC").attr("readonly", false);
			$("#QTCOMP").attr("readonly", false);
			if($("#LOCAKY2").val().length == 0){			
				$("#LOCAKY2").focus();
			} else {
				$("#LOCAKY2").select();
			}
		} else {
			$("#LOCAKY2").attr("readonly", true);
			$("#TRNUAC").attr("readonly", true);
			$("#QTCOMP").attr("readonly", true);
			$("#LOCAKY2").val($("#LOCAKY").val());
			$("#TRNUAC").val($("#TRNUSR").val());
		}
	}

	
	//그리드 data binding 이후 발생 이벤트
	function gridListEventDataBindEnd(gridId, dataCount){
		if(gridId == "gridList"){
			//그리드 카운팅 후 마지막 카운팅일 경우 닫기 이벤트
			if(dataCount == 0 && completeChk){
				PlaySound("e");
				screenClose();
			}else if(dataCount == 0){
				PlaySound("e");
				stayChk = "V";
				leftChk = "";
				rightChk= "";
				searchList();
			}else{
				PlaySound("s");
				stayChk="";
				leftChk = "";
				rightChk= "";
			}
			setData(0);//hidden 그리드 Row=0 데이터 세팅
			$("#FAIL").hide();
			$("#SUCCESS").hide();
		}
	}
	
	//hidden 그리드 작업 변경 시 화면에 데이터 세팅
	function setData(rowNum){
		var rowData = gridList.getRowData("gridList",rowNum);
		var startJson = changeWorkingUser(rowNum,"Y");//동시성제어
		if(startJson && startJson.data){
			$("#ORTNNO").val(rowData.get("ORTNNO"));
			$("#TRNUSR").val(rowData.get("TRNUSR"));
			$("#SKUKEY").val(rowData.get("SKUKEY"));
			$("#DESC01").val(rowData.get("DESC01"));
			$("#QTYORG").val(rowData.get("QTYORG"));
			$("#QTPUOM").val(rowData.get("QTPUOM"));
			$("#SCAN_INPUT").focus();
			$("#SCAN_INPUT").select();
		}
		
	}
	
	//닫기 버튼 클릭시 기존 조회 정보를 가지고 이전 화면으로 이동 후 조회
	function screenClose(){
		var paramStr = "TASKKY="+<%=TASKKY%>+"&CLSSTT=Y";
		location.href="/mobile/PDPKRM01.page?"+paramStr;
	}
	
	function changeTaskInfo(){
		
	}
	
	//분배 확정
	function distConfirm(){
		if($("#LOCAKY2").val() == "" || $("#TRNUSR").val() == ""){
			return;
		}
			
		if($("#QTCOMP").val() == 0) {
			commonUtil.msgBox("MOBILE_M0005");
			$("#QTCOMP").select();
			return;
		}
		
		var param = new DataMap();
		param.put("TASKKY", $("#TASKKY").val());
		param.put("TASKIT", $("#TASKIT").val());
		
		// TASKKY와 TASKIT로 정보를 조회해서 모든 데이터를 가져온다.
		var json = netUtil.sendData({
			url: "/mobile/Mobile/json/PickingInfoPDPKRM01.data",
			param : param
		});
		
		if(json) {
			// 내가 입력한 값이랑 다르면 QTTAOR을 수정한다.
			if($("#QTTAOR").val() != $("#QTCOMP").val()){
				json.data["QTTAOR"] = $("#QTCOMP").val();
			}
			
			param.put("data", json.data);
			
			var js = netUtil.sendData({
				url:"/mobile/Mobile/json/ConfirmPickingPDPKRM01.data",
				param : param
			});
			
			if(js && js.data) {
				commonUtil.msgBox("OUT_M0152");
				setTimeout(function(){
					allHide();
				}, 1);
				searchList();
			}
		}
	}
	
	//하단 버튼 이벤트
	function skipLeft(){
		if(curIdx > 0){
			curIdx--;
			showItem(curIdx);
		}
	}
	
	// > 버튼 이벤트
	function skipRight(){
		if(curIdx < itemlist.length-1){
			curIdx++;
			showItem(curIdx);
		}
	}
	
	function resetPopup(){
		$("#message0").remove();
		$("#message1").remove();
		$("#message2").remove();
		$("#searchArea").show();
		rightChk = "V";
		changeWorkingUser(0,"");
		searchList();
	}
	
</script>
</head>
<body>
	<div class="main_wrap" id="searchArea">
		<div class="tem4_content">
			<div class="select_box" id="bindArea">
				<table>
					<colgroup>
						<col width="180px" />
						<col />
						<col width="80px" />
						<col />
					</colgroup>
					<tbody>
						<tr>
							<th CL='STD_WORKLIST' style="font-size:20px" class="popuptable">할당정보</th>
							<td colspan="2" id="WORKLIST"></td>
						</tr>
					</tbody>
				</table>
				<table>
					<colgroup>
						<col width="120px" />
						<col />
						<col width="120px" />
						<col />
					</colgroup>
					<tbody>
						<tr>
							<th CL='STD_TASKKY' class="popuptable">작업오더번호</th>
							<td colspan="3">
								<input type="text" class="text" name="TASKKY" id="TASKKY" readonly/>
							</td>
						</tr>
						<tr>
							<th CL='STD_TASKIT' class="popuptable">작업오더아이템</th>
							<td colspan="3">
								<input type="text" class="text" name="TASKIT" id="TASKIT" readonly/>
							</td>
						</tr>
						<tr>
							<th CL='STD_LOCAKY' class="popuptable">지번</th>
							<td colspan="3">
								<input type="text" class="text" name="LOCAKY" id="LOCAKY" readonly/>
							</td>
						</tr>
						<tr>
							<th CL='STD_TRNUSR' class="popuptable">P/T ID</th>
							<td colspan="3">
								<input type="text" class="text" name="TRNUSR" id="TRNUSR" readonly/>
							</td>
						</tr>
						<tr>
							<th CL='STD_SKUKEY' class="popuptable">품번</th>
							<td colspan="3">
								<input type="text" class="text" name="SKUKEY" id="SKUKEY" readonly/>
							</td>
						</tr>
						<tr>
							<th  CL='STD_DESC01' class="popuptable">품명</th>
							<td colspan="3">
								<input type="text" class="text" name="DESC01" id="DESC01" readonly/>
								<!-- <textarea name="DESC01" id="DESC01" cols="40" row="2" style="width:100%; margin-right:3px;height:40px;border:solid 1px #d5d5d5;" disabled readonly>
								</textarea> -->
							</td>
						</tr>
						<tr>
							<th  CL='STD_QTYORG2' class="popuptable">예정</th>
							<td colspan="2">
								<input type="text" class="text gridColInputNumber" name="QTTAOR" id="QTTAOR" readonly/>
							</td>
							<td>
								<input type="text" class="text" name="UOMKEY" id="UOMKEY" style="text-align:center" readonly/>
							</td>
						</tr>
						<tr>
							<th CL='STD_PTLT12' class="popuptable">입고일자</th>
							<td>
								<input type="text" class="text" name="PTLT12" id="PTLT12" readonly/>
							</td>
							<th CL='STD_PTLT11' class="popuptable">제조일자</th>
							<td>
								<input type="text" class="text" name="PTLT11" id="PTLT11" readonly/>
							</td>
						</tr>
						<tr class="hiderow">
							<td colspan="2">
								<input type="text" name="LOTNUM" id="LOTNUM"/>
							</td>
						</tr>
<!-- 						<tr>
							<td id="FAIL" colspan="4">
								<input type="text" class="text" value="Scan Error" style="color:white;text-align:center;background-color:red;font-size: 20px;font-weight: bold;"/>
							</td>
							<td id="SUCCESS" colspan="4">
								<input type="text" class="text" value="Scan Success" style="color:white;text-align:center;background-color:blue;font-size: 20px;font-weight: bold;"/>
							</td>
						</tr> -->
					</tbody>
				</table>
				<hr />
				<table>
					<colgroup>
						<col width="120px" />
						<col />
						<col width="120px" />
						<col />
					</colgroup>
					<tbody>
						<tr>
							<th CL='STD_PICKINFO' style="font-size:20px" class="popuptable">피킹정보</th>
							<td colspan="3" id="PICKINFO"></td>
						</tr>
					</tbody>
				</table>
				<table>
					<colgroup>
						<col width="120px" />
						<col width="80px"/>
						<col width="50px" />
						<col width="110px" />
						<col width="80px"/>
						<col width="50px"/>
					</colgroup>
					<tbody>
						<tr>
							<th CL='STD_LOCAKY' class="popuptable">지번</th>
							<td colspan="5">
								<input type="text" class="text" name="LOCAKY2" id="LOCAKY2" validate="required" onkeydown="keyDownEvent(this,event)"/>
							</td>
						</tr>
						<tr>
							<th CL='STD_TRNUAC' class="popuptable">P/T ID</th>
							<td colspan="5">
								<input type="text" class="text" name="TRNUAC" id="TRNUAC" validate="required" onkeydown="keyDownEvent(this,event)"/>
							</td>
						</tr>
						<tr class="hiderow">
							<th CL='STD_QTSIWHAVB' class="popuptable hiderow">가용재고량</th>
							<td class="hiderow">
								<input type="text" class="text gridColInputNumber" name="QTSAVB" id="QTSAVB" readonly/>
							</td>
							<td class="hiderow">
								<input type="text" class="text" name="UOMKEY5" id="UOMKEY5" style="text-align:center" readonly/>
							</td>
							<th CL='STD_QTSAVB' class="popuptable hiderow">입력가능수량</th>
							<td class="hiderow">
								<input type="text" class="text" name="QTUALO" id="QTUALO" style="text-align:center" readonly/>
							</td>
							<td class="hiderow" style="padding-right: 10px;">
								<input type="text" class="text" name="UOMKEY6" id="UOMKEY6" style="text-align:center;" readonly/>
							</td>
							<td colspan="6" class="hiderow">
								<input type="text" class="fontred" id="inputLOC" value="Please input Location" readonly/>
							</td>
							<td colspan="6" class="hiderow">
								<input type="text" class="fontred" id="inputPTID" value="Please input P/T ID" readonly/>
							</td>
							<td colspan="6" class="hiderow">
								<input type="text" class="fontred" id="inputNOSKU" value="Location doesn't have SKU" readonly/>
							</td>
						</tr>
						<tr>
							<th  CL='STD_QTJCMP' class="popuptable">피킹수량</th>
							<td colspan="4">
								<input type="text" class="text gridColInputNumber" name="QTCOMP" id="QTCOMP" validate="required" onkeydown="keyDownEvent(this,event)"/>
							</td>
							<td>
								<input type="text" class="text" name="UOMKEY2" id="UOMKEY2" style="text-align:center" readonly/>
							</td>
						</tr>
					</tbody>
				</table>
				<hr />
				<table>
					<colgroup>
						<col width="120px"/>
						<col width="50px"/>
						<col width="100px"/>
						<col width="50px"/>
						<col width="50px"/>
						<col width="100px"/>
						<col width="50px"/>
					</colgroup>
					<tbody>
						<tr>
							<th  CL='STD_COMPCNT'>완료건수</th>
							<td>
								Total
							</td>
							<td>
								<input type="text" class="text gridColInputNumber" name="COMPCNT" id="COMPCNT" readonly/>
							</td>
							<td>
								CNT
							</td>
							<td>
								CMP
							</td>
							<td>
								<input type="text" class="text gridColInputNumber" name="COMPCNT2" id="COMPCNT2" readonly/>
							</td>
							<td>
								CNT
							</td>
						</tr>
						<tr>
							<th CL='STD_QTCOMP_L7141'>완료수량</th>
							<td>
								Total
							</td>
							<td>
								<input type="text" class="text gridColInputNumber" name="QTCOMP_L7141" id="QTCOMP_L7141" readonly/>
							</td>
							<td>
								<input type="text" class="text" name="UOMKEY3" id="UOMKEY3" style="text-align:center" readonly/>
							</td>
							<td>
								CMP
							</td>
							<td>
								<input type="text" class="text gridColInputNumber" name="QTCOMP_L7141_2" id="QTCOMP_L7141_2" readonly/>
							</td>
							<td>
								<input type="text" class="text" name="UOMKEY4" id="UOMKEY4" style="text-align:center" readonly/>
							</td>
						</tr>
						<tr>
							<th  CL='STD_PAGE'>페이지</th>
							<td>
								Total
							</td>
							<td>
								<input type="text" class="text gridColInputNumber" name="PAGE" id="PAGE" readonly/>
							</td>
							<td>
								PAGE
							</td>
							<td>
								CMP
							</td>
							<td>
								<input type="text" class="text gridColInputNumber" name="PAGE2" id="PAGE2" readonly/>
							</td>
							<td>
								PAGE
							</td>
						</tr>
					</tbody>
				</table>
				<hr />
				<!-- hidden table -->
				<div class="tableWrap_search section" style="display:none;" > <!-- style="display:none;" -->
					<div class="tableHeader">
						<table style="width: 100%"> 
							<colgroup>
								<col width="40px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
							</colgroup>
							<thead>
								<tr class="thead">
									<th CL='STD_NO'>순번</th>
									<th>ORTNNO</th>
									<th>TRNUSR</th>
									<th>SKUKEY</th>
									<th>DESC01</th>
									<th>QTYORG</th>
									<th>QTPUOM</th>
									<th>SHPOKY</th>
									<th>SHPOIT</th>
									<th>REFDKY</th>
									<th>REFDIT</th>
								</tr>
							</thead>
						</table>				
					</div>
					<div class="tableBody">
						<table style="width: 100%">
							<colgroup>
								<col width="40px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
								<col width="80px" />
							</colgroup>
							<tbody id="gridList">
								<tr CGRow="true">
									<td GCol="rownum"></td>
									<td GCol="text,ORTNNO"></td>
									<td GCol="text,TRNUSR"></td>
									<td GCol="text,SKUKEY"></td>
									<td GCol="text,DESC01"></td>
									<td GCol="text,QTYORG"></td>
									<td GCol="text,QTPUOM"></td>
									<td GCol="text,SHPOKY"></td>
									<td GCol="text,SHPOIT"></td>
									<td GCol="text,REFDKY"></td>
									<td GCol="text,REFDIT"></td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
			</div>
			<!-- end table_body -->
			<div class="footer_5">
				<table>
					<tr>
						<td class=f_1 onclick ="skipLeft()" width="20%"><label CL='BTN_LEFT'></label></td>
						<td class=f_1 onclick ="screenClose()" width="30%"><label CL='BTN_CLOSE'></label></td>
						<td class=f_1 onclick ="distConfirm()" width="30%"><label CL='STD_PICKIN'></label></td>
						<td class=f_1 onclick ="skipRight()" width="20%"><label CL='BTN_RIGHT'></label></td>
					</tr>
				</table>
			</div><!-- end footer_5 -->	
		</div>
	</div>
</body>