<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String ZONEKY = request.getParameter("ZONEKY");
	String TASWKY = request.getParameter("TASWKY");
	String TRNUSR = request.getParameter("TRNUSR");
	String CHKCOD = request.getParameter("CHKCOD");
	String TASKKY = request.getParameter("TASKKY");
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
			command : "PDPK02SKU",
			gridMobileType : true,
			emptyMsgType:false
	    });
		$("#FAIL").hide();
		$("#SUCCESS").hide();
		searchList();
		
		$("#LOCAKY2").keypress(function(event){
			if(event.keyCode == "13") {				
				if($("#TRNUAC").val().length == 0) {
					$("#TRNUAC").focus();
				} else {
					$("#TRNUAC").select();
				}
			}
		});
		
		$("#TRNUAC").keypress(function(event){
			if(event.keyCode == "13"){				
				if($("#QTCOMP").val().length == 0) {
					$("#QTCOMP").focus();
				} else {
					$("#QTCOMP").select();
				}
			}
		});
		
		$("#QTCOMP").keypress(function(event){
			if(event.keyCode == "13") {
				distConfirm();
			}
		});
	});
	
	
	function searchList(){
		var param = new DataMap();
		param.put("TASKKY", "<%=TASKKY%>");
		param.put("WAREKY", "<%=wareky%>");

		var json = netUtil.sendData({
			url : "/mobile/Mobile/json/PDPK02SKU.data",
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
				$("#LOCAKY").val(data.LOCAKY);
				$("#TRNUSR").val(data.TRNUSR);
				$("#SKUKEY").val(data.SKUKEY);
				$("#DESC01").val(data.DESC01);
				$("#QTTAOR").val(data.QTTAOR);
				$("#UOMKEY").val(data.UOMKEY);
				$("#QTCOMP").val(data.QTTAOR);
				$("#UOMKEY2").val(data.UOMKEY2);
				$("#UOMKEY3").val(data.UOMKEY2);
				$("#UOMKEY4").val(data.UOMKEY2);
				$("#LOCAKY2").val("");
				$("#TRNUAC").val("");
				$("#LOCAKY2").focus();
				$("#PAGE2").val(curIdx+1);
				return;
			}
		}
		
		commonUtil.msgBox("OUT_M0045");
		screenClose();
	}
	
	function showItem(index){
		$("#LOCAKY2").val("");
		$("#TRNUAC").val("");
		$("#PAGE2").val(curIdx+1);
		var data = itemlist[index];
		$("#LOCAKY").val(data.LOCAKY);
		$("#TRNUSR").val(data.TRNUSR);
		$("#SKUKEY").val(data.SKUKEY);
		$("#DESC01").val(data.DESC01);
		$("#QTTAOR").val(data.QTTAOR);
		$("#UOMKEY").val(data.UOMKEY);
		if(data.STATIT == "NEW") {			
			$("#QTCOMP").val(data.QTTAOR);
		} else {			
			$("#QTCOMP").val(data.QTCOMP);
		}
		$("#UOMKEY2").val(data.UOMKEY2);
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
	
	function changeWorkingUser(rowNum,chkFlag){
		var rowData = gridList.getRowData("gridList",rowNum);
		var param = new DataMap();
		param.put("BARCOD",$("#BARCOD").val());
		param.put("list",rowData);
		param.put("USECHK",chkFlag);//use check용 파라미터( 사용:'Y' / 미사용:'')
		var startJson = netUtil.sendData({
			url:"/mobile/Mobile/json/cartonWorkChange.data",
			param : param
		});
		return startJson;
	}
	
	//scan data validation
	function checkValue(inputScan){
		if(inputScan != ""){
			if($("#ORTNNO").val() == inputScan){
				$("#FAIL").hide();
				$("#SUCCESS").show();
				distConfirm();
			}else{
				$("#FAIL").show();
				$("#SUCCESS").hide();
				$("#SCAN_INPUT").focus();
				$("#SCAN_INPUT").select();
			}
		}else{
			$("#FAIL").hide();
			$("#SUCCESS").hide();
		}
	}
	
	//하단 버튼 이벤트
	function skipLeft(){
		if(curIdx == 0) {
			curIdx = itemlist.length-1;
		} else {
			curIdx--;
		}
		showItem(curIdx);
	}
	
	//닫기 버튼 클릭시 기존 조회 정보를 가지고 이전 화면으로 이동 후 조회
	function screenClose(){
		var paramStr = "TASKKY="+<%=TASKKY%>;
		location.href="/mobile/PDPK02.page?"+paramStr;
	}
	
	//분배 확정
	function distConfirm(){
		if($("#LOCAKY2").attr("readonly") == "readonly"){
			commonUtil.msgBox("OUT_M0045");
			return;
		} else {
			if(validate.check("searchArea")){
				if($("#LOCAKY").val() != $("#LOCAKY2").val() ){
					if($("#LOCAKY").val() != $("#LOCAKY2").val()){
						commonUtil.msgBox("MOBILE_M0002");
						$("#LOCAKY2").select();
					}
					return;
				}
			
				if(Number($("#QTCOMP").val()) > ($("#QTTAOR").val())) {
					commonUtil.msgBox("MOBILE_M0004");
					$("#QTCOMP").select();
					return;
				}
				
				if(Number($("#QTCOMP").val()) == 0) {
					commonUtil.msgBox("MOBILE_M0005");
					$("#QTCOMP").select();
					return;
				}
				
				var list = itemlist[curIdx];
				list.QTCOMP = Number($("#QTCOMP").val());
				list.TRNUAC = $("#TRNUAC").val();
				var param = new DataMap();
				param.put("list",list);
				
				var json = netUtil.sendData({
					url:"/mobile/Mobile/json/ConfirmPickingPDPK02.data",
					param : param
				});
				
				if(json && json.data) {
					commonUtil.msgBox("OUT_M0152");
					searchList();
				}
				
				/* 
				//확정 이후 shipment 상태값 확인
				var chkparam = new DataMap();
				chkparam.put("SHPOKY",list.get("SHPOKY"));
				var chkjson = netUtil.sendData({
					module : "WmsMobileOutbound",
					command : "PDSP60FSH_CHECK",
					sendType : "map",
					param : chkparam
				});
				completeChk = true;// 완료 체크
				//FPC (피킹완료)일경우 카톤 작업(1상자) 완료
				if(chkjson.data["STATDO"] =="FPC"){
					//alert(list.get("ORTNNO")+" 카톤완료");
					//commonUtil.msgBox("MOBILE_M0014",list.get("ORTNNO"));
					popupLayout(list.get("ORTNNO"),"");
				}else{
					searchList();
				} */
			}
		}
	}
	
	// > 버튼 이벤트
	function skipRight(){
		if(curIdx == itemlist.length-1) {
			curIdx = 0;
		} else {
			curIdx++;
		}
		showItem(curIdx);
	}
	
	function popupLayout(text1,text2){
		$("#searchArea").hide();
		$('body').append($('<div/>', {
	        id: 'message0',
	        text: '알림 POPUP',
	        style: 'width:100%;text-align:center; background:#4A4A4A; border-left:none; border-right:none; color:#cfcfcf; border-bottom:1px solid #424242;'
	    }));
		$('body').append($('<div/>', {
	        id: 'message1',
	        text: '분배가 완료 되었습니다.',
	        style: 'width:100%; margin-right:3px;height:40px;border:solid 0px #d5d5d5;text-align:center;background-color:#d5d5d5;'
	    }));
		$('body').append($('<div/>', {
	        id: 'message2',
	        text: '카톤 박스 : '+text1,
	        style: 'width:100%; margin-right:3px;height:40px;border:solid 0px #d5d5d5;text-align:center;background-color:#d5d5d5;'
	    }));
		
		$("#message0").click(function (){
			resetPopup();
		});
		$("#message1").click(function (){
			resetPopup();
		});
		$("#message2").click(function (){
			resetPopup();
		});
	
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
							<th CL='STD_WORKLIST' style="font-size:20px">할당정보</th>
							<td colspan="2" id="WORKLIST"></td>
						</tr>
					</tbody>
				</table>
				<table>
					<colgroup>
						<col width="120px" />
						<col />
						<col width="80px" />
						<col />
					</colgroup>
					<tbody>
						<tr>
							<th CL='STD_LOCAKY'>지번</th>
							<td colspan="2">
								<input type="text" class="text" name="LOCAKY" id="LOCAKY" readonly/>
							</td>
						</tr>
						<tr>
							<th CL='STD_TRNUSR'>바코드</th>
							<td colspan="2">
								<input type="text" class="text" name="TRNUSR" id="TRNUSR" readonly/>
							</td>
						</tr>
						<tr>
							<th CL='STD_SKUKEY'>품번</th>
							<td colspan="2">
								<input type="text" class="text" name="SKUKEY" id="SKUKEY" readonly/>
							</td>
						</tr>
						<tr>
							<th  CL='STD_DESC01'>품명</th>
							<td colspan="4">
								<input type="text" class="text" name="DESC01" id="DESC01" readonly/>
								<!-- <textarea name="DESC01" id="DESC01" cols="40" row="2" style="width:100%; margin-right:3px;height:40px;border:solid 1px #d5d5d5;" disabled readonly>
								</textarea> -->
							</td>
						</tr>
						<tr>
							<th  CL='STD_QTYORG2'>예정</th>
							<td>
								<input type="text" class="text gridColInputNumber" name="QTTAOR" id="QTTAOR" readonly/>
							</td>
							<td>
								<input type="text" class="text" name="UOMKEY" id="UOMKEY" style="text-align:center" readonly/>
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
						<col width="180px" />
						<col />
						<col width="80px" />
						<col />
					</colgroup>
					<tbody>
						<tr>
							<th CL='STD_PICKINFO' style="font-size:20px">피킹정보</th>
							<td colspan="2" id="PICKINFO"></td>
						</tr>
					</tbody>
				</table>
				<table>
					<colgroup>
						<col width="120px" />
						<col />
						<col width="80px" />
						<col />
					</colgroup>
					<tbody>
						<tr>
							<th CL='STD_LOCAKY'>지번</th>
							<td colspan="2">
								<input type="text" class="text" name="LOCAKY2" id="LOCAKY2" validate="required"/>
							</td>
						</tr>
						<tr>
							<th CL='STD_TRNUAC'>실 PT ID</th>
							<td colspan="2">
								<input type="text" class="text" name="TRNUAC" id="TRNUAC" validate="required"/>
							</td>
						</tr>
						<tr>
							<th  CL='STD_QTJCMP'>피킹수량</th>
							<td>
								<input type="text" class="text gridColInputNumber" name="QTCOMP" id="QTCOMP" validate="required"/>
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
									<th>TRNUAC</th>
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
									<td GCol="text,TRNUAC"></td>
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