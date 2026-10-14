<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String ZONEKY = request.getParameter("ZONEKY");
	String TASWKY = request.getParameter("TASWKY");
	String BARCOD = request.getParameter("BARCOD");
	String CHKCOD = request.getParameter("CHKCOD");
	String TASKKY = request.getParameter("TASKKY");
	String TASKIT = request.getParameter("TASKIT");
	String FROW = request.getParameter("FROW");
	String Flag = request.getParameter("Flag");
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
	var Flag;
	var data = new DataMap();
	var itemlist = [];
	var curIdx = 0;
	$(document).ready(function(){
		gridList.setGrid({
			id : "gridList",
			editable : true,
			module : "WmsMobileOutboundPicking",
			command : "PDPK01SKU",
			bindArea : "searchArea",
			gridMobileType : true
		});
		data.put("TASKKY", "<%=TASKKY%>");
		data.put("TASKIT", "<%=TASKIT%>");
		$("#main").show();
		$("#detailInfo").hide(); //list
		searchList();
		$("#LOCAKY2").focus();
		
		if($('#STATIT').val() == "FPC"){
			$("#LOCAKY2").attr("readonly", "readonly");
			$("#TOBARCOD").attr("readonly", "readonly");
			$("#QTCOMP").attr("readonly", "readonly");
		}
	});
	
	function searchList(){
		data.put("WAREKY", "<%=wareky%>");
		data.put("BARCOD", "<%=BARCOD%>");
		
		gridList.gridList({
			id : "gridList",
			param : data
		});
	}
	
	function searchTaskList(){
		data.put("WAREKY", "<%=wareky%>");
		data.put("BARCOD", "<%=BARCOD%>");
		
		var json = netUtil.sendData({
			module : "WmsMobileOutboundPicking",
			command : "PDPK01SKU_RE",
			param : data
		});
		itemlist = json.data;
	}
	
	//피킹완료
	function PkConfirm(){
		var pkList = [];
		data.put("WAREKY", "<%=wareky%>");
		data.put("BARCOD", "<%=BARCOD%>");
		
		var json2 = netUtil.sendData({
			module : "WmsMobileOutboundPicking",
			command : "PDPK01SKU",
			param : data
		});
		
		pkList = json2.data;
		var param = new DataMap();
		param.put("head", pkList);
		
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){ //저장하시겠습니까?
			return;
		}
		
		var json = netUtil.sendData({
			url : "/mobile/Mobile/json/PDPK01Save.data",
			param : param
		});
		
		if(json && json.data){
			searchList();
			commonUtil.msgBox("MASTER_M0564"); //저장 완료되었습니다.
			
			$("#LOCAKY2").attr("readonly", true);
			$("#TOBARCOD").attr("readonly", true);
			$("#QTCOMP").attr("readonly", true);
		}
	}
	
	//그리드 data binding 이후 발생 이벤트
	function gridListEventDataBindEnd(gridId, dataLength){
		if(gridId == "gridList" && dataLength > 0){
			gridList.setRowFocus("gridList", <%=FROW%>, true); //PDPK01에서 선택한 ROW위치로 FOCUS
			$("#QTCOMP").val($("#QTTAOR").val()); //피킹수량
		}
	}
	
	//하단 버튼 이벤트
	function skipLeft1(){
		if(curIdx == 0) {
			curIdx = itemlist.length-1;
		} else {
			curIdx--;
		}
		showItem(curIdx);
	}
	// > 버튼 이벤트
	function skipRight1(){
		searchTaskList();
		if(curIdx == itemlist.length-1) {
			curIdx = 0;
		} else {
			curIdx++;
		}
		showItem(curIdx);
	}
	
	//닫기 버튼 클릭시 기존 조회 정보를 가지고 이전 화면으로 이동 후 조회
	function screenClose(){
		var paramStr = "TASKKY=" + "<%=TASKKY%>" + "&Flag=N" + "&BARCOD=" + "<%=BARCOD%>";
		location.href="/mobile/PDPK01.page?"+paramStr;
	}
	
	function showMain(){
		mobile.linkPopClose();
	}
	
	function showItem(index){
		var data = itemlist[index];
		$("#TASKIT").val(data.TASKIT);
		$("#SKUKEY").val(data.SKUKEY);
		$("#DESC01").val(data.DESC01);
		$("#LOCAKY").val(data.LOCAKY);
		$("#EANCOD").val(data.EANCOD);
		$("#QTTAOR").val(data.QTTAOR);
		$("#UOMKEY").val(data.UOMKEY);
		$("#STATIT").val(data.STATIT);
		$("#STATITNM").val(data.STATITNM);
	}
	
	function focusCheck(objId){
		$("#"+objId).select();
	}
	
	function locaTask(){
		var locaky2 = $('#LOCAKY2').val();
		var skukey = $('#SKUKEY').val();
		var qtcomp = $('#QTCOMP').val();
		var itemlist = [];
		var valchk = 'N';
		if(locaky2 == ""){
			commonUtil.msgBox("MASTER_M0314");
			PlaySound('e');
			$("#LOCAKY2").focus();
			return;
		}
		if(locaky2 == 'CRTN' || locaky2 == 'RTSLOC' || locaky2 == 'SHPLOC'){
			commonUtil.msgBox("VALID_M0612");
			PlaySound('e');
			$("#LOCAKY2").focus();
			return;
		}
		
		var param = inputList.setRangeParam("searchArea");
		param.put("WAREKY", "<%=wareky%>");
		
		//1. 입력한 지번(LOCAKY2)에 대한 AREA, ZONE, 가용재고수량 SELECT
		var json = netUtil.sendData({
			module : "WmsMobileOutboundPicking",
			command : "PDPK01LOCCNT",
			sendType : "map",
			param : param
		});
		if(json && json.data){
			var useqty = json.data["USEQTY"];
			var locchk = json.data["LOCAKY"];
			var zonchk = json.data["ZONEKY"];
			var arechk = json.data["AREAKY"];
			
			//가용재고수량 체크
			if(useqty<qtcomp){
				PlaySound('e');
				$('#LOCAKY2').val("");
				$('#TOBARCOD').val("");
				commonUtil.msgBox("VALID_M0611");
				return;
			}else{
				//SHPOKY, SHPOIT로 할당전략 FILTERING RULE SELECT
				var json2 = netUtil.sendData({
					url : "/mobile/Mobile/json/PDPK01ITEMLIST.data",
					param : param
				});
				itemlist = json2.data;
				for(var i=0; i<itemlist.length; i++){
					var dbfildData = (json2.data[i]).DBFILD;	//전략이 AREA인지 ZONE인지 LOCATION인지 체크
					var rngvmiData = (json2.data[i]).RNGVMI;	//KEY값
					if(dbfildData == 'AREAKY'){
						if(arechk.trim() == rngvmiData.trim()){
							valchk = 'Y';
							$('#TOBARCOD').val("");
							$('#TOBARCOD').focus();
							break;
						}
					}else if(dbfildData == 'ZONEKY'){
						if(arechk != rngvmiData){
							valchk = 'Y';
							$('#TOBARCOD').val("");
							$('#TOBARCOD').focus();
							break;
						}
					}else if(dbfildData == 'LOCAKY'){
						if(!locchk.equals(rngvmiData)){
							valchk = 'Y';
							$('#TOBARCOD').val("");
							$('#TOBARCOD').focus();
							break;
						}
					}
				}
				if(valchk == 'N'){
					commonUtil.msgBox("SYSTEM_M0612");
				}
			}
		}else{
			PlaySound('e');
			$('#LOCAKY2').val("");
			$('#TOBARCOD').val("");
			commonUtil.msgBox("VALID_M0611");
			return;
		}
	}
	
	function clear(){
		$("#LOCAKY2").val("");
		$("#TOBARCOD").val("");
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId == "gridList" && colName == "QTCOMP"){
			var rowData = gridList.getRowData(gridId, rowNum);
			var qttaor = new Number(rowData.get("QTTAOR"));
			if(qttaor < colValue){
				commonUtil.msgBox("VALID_M0613");
				$('#QTCOMP').val(0);
				$('#QTCOMP').focus();
				return;
			} else if(colValue <= 0){
				commonUtil.msgBox("VALID_M0614");
				$('#QTCOMP').val(0);
				$('#QTCOMP').focus();
				return;
			}
		}
	}
</script>
</head>
<body>
	<div class="main_wrap" id="main"> 
		<div class="tem4_content">
			<div class="select_box" id="searchArea">
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
				<table class="info_table">
					<colgroup>
						<col width="120px" />
						<col />
						<col width="80px" />
					</colgroup>
					<tbody>
						<tr>
							<th CL='STD_TASKIT'>아이템번호</th>
							<td colspan="2">
								<input type="text" class="text" name="TASKIT" id="TASKIT" readonly/>
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
							</td>
						</tr>
						<tr>
							<th CL='STD_LOCAKY'>지번</th>
							<td colspan="2">
								<input type="text" class="text" name="LOCAKY" id="LOCAKY" readonly/>
							</td>
						</tr>
						<tr>
							<th CL='STD_BARCOD'>바코드</th>
							<td colspan="2">
								<input type="text" class="text" name="EANCOD" id="EANCOD" readonly/>
							</td>
						</tr>
						<tr>
							<th  CL='STD_QTYORG2'>예정</th>
							<td>
								<input type="text" class="text gridColInputNumber" name="QTTAOR" id="QTTAOR" readonly/>
							</td>
							<td>
								<input type="text" class="text" name="UOMKEY" id="UOMKEY" style="text-align:center" readonly/>
								<input type="hidden" name="SHPOKY" id="SHPOKY" />
								<input type="hidden" name="SHPOIT" id="SHPOIT" />
							</td>
						</tr>
						<tr>
							<th CL='STD_STATITNM'>상태</th>
							<td>
								<input type="text" class="text" name="STATITNM" id="STATITNM" readonly/>
							</td>
							<td>
								<input type="text" class="text" name="STATIT" id="STATIT" style="text-align:center" readonly/>
							</td>
						</tr>
					</tbody>
				</table>
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
								<input type="text" class="text" name="LOCAKY2" id="LOCAKY2" onfocus="focusCheck(this.id)" onkeypress="commonUtil.enterKeyCheck(event, 'locaTask()')" validate="required" />
							</td>
						</tr>
						<tr>
							<th CL='STD_PLTBCD'>바코드</th>
							<td colspan="2">
								<input type="text" class="text" name="TOBARCOD" id="TOBARCOD" onfocus="focusCheck(this.id)" validate="required"/>
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
			</div>
		</div>

		<div class="main_wrap" id="detailInfo">
			<div class="tem5_content"> 
				<div class="tableWrap_search section">
						<div class="tableHeader">
							<table style="width: 100%">
								<colgroup>
										<col width="30px" />
										<col width="100px" />
										<col width="100px" />
										<col width="100px" />
										<col width="100px" />
										<col width="100px" />
										<col width="100px" />
										<col width="100px" />
										<col width="100px" />
								</colgroup>
								<thead>
									<tr>
										<th CL='STD_NO'>No.</th>
										<th CL='STD_TASKKY'>작업지시번호</th>
										<th CL='STD_TASKIT'>작업지시순번</th>
										<th CL='STD_SKUKEY'>품목코드</th>
										<th CL='STD_DESC01'>품명</th>
										<th CL='STD_LOCAKY'>지번</th>
										<th CL='STD_PLTBCD'>바코드</th>
										<th CL='STD_QTTAOR'></th>
										<th CL='STD_QTCOMP'></th>
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
										<col width="100px" />
										<col width="100px" />
										<col width="100px" />
										<col width="100px" />
										<col width="100px" />
								</colgroup>
								<tbody id="gridList">
									<tr CGRow="true">
										<td GCol="rownum">1</td>
										<td GCol="text,TASKKY"></td>
										<td GCol="text,TASKIT"></td>
										<td GCol="text,SKUKEY"></td>
										<td GCol="text,DESC01"></td>
										<td GCol="text,LOCAKY"></td>
										<td GCol="text,EANCOD"></td>
										<td GCol="text,QTTAOR"></td>
										<td GCol="text,QTCOMP"></td>
									</tr>
								</tbody>
							</table>
						</div>
					</div> 
				</div>
			</div>
			<!-- end table_body -->
			<div class="footer_5">
				<table>
					<tr>
						<td class=f_1 onclick ="skipLeft1()" width="20%"><label CL='BTN_LEFT'></label></td>
						<td class=f_1 onclick ="screenClose()" width="30%"><label CL='BTN_CLOSE'></label></td>
						<td class=f_1 onclick ="PkConfirm()" width="30%"><label CL='STD_PICKIN'></label></td>
						<td class=f_1 onclick ="skipRight1()" width="20%"><label CL='BTN_RIGHT'></label></td>
					</tr>
				</table>
			</div><!-- end footer_5 -->	
		</div>
	</div>
</body>