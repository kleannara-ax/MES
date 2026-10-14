<%@ page import="project.common.task.InterfaceSchedule" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
		 pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<style type="text/css">
 .content_wrap{background: none;}
 #tabs1-1{height: calc(100% - 90px);}
 .search_sub{height: 30px;}
 .content_layout .search_sub dl{padding:0 0 10px;}
 .content_layout .search_sub dd{margin-left:unset;text-align:unset;}
</style>
<script type="text/javascript">
var curRow = "";
	$(document).ready(function(){
		gridList.setGrid({
			id : "gridList1",
			editable : true,
			module : "Erpif",
			command : "ITFMA",
			colHoldType: true,
			colHold : "IFID,IFKNM,SYSFR,SYSTO",
			sortType: true,
		});

		// 검색조건 - 인터페이스 ID
		var $selIFID = $('select[name="IFID"]');
		inputList.setMultiComboSelectAll($("IFID"),true);
		$selIFID.multipleSelect('checkAll');
		// 검색조건 - IF테이블
		var $selIFTBL = $('select[name="IFTBL"]');
		inputList.setMultiComboSelectAll($("IFTBL"),true);
		$selIFTBL.multipleSelect('checkAll');
		// 검색조건 - 송신시스템
		var $selSYSFR = $('select[name="SYSFR"]');
		inputList.setMultiComboSelectAll($("SYSFR"),true);
		$selSYSFR.multipleSelect('checkAll');
		// 검색조건 - 수신시스템
		var $selSYSTO = $('select[name="SYSTO"]');
		inputList.setMultiComboSelectAll($("SYSTO"),true);
		$selSYSTO.multipleSelect('checkAll');

		$('[ms-drop="IFID"]').css("width","400px");
		// 조회
		searchList();
		
		$('#btn_unProcess').hide();
	});
	
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			// 조회
			searchList();
		} else if(btnName == "Detail") {
			// 상세조회
			if(gridList.getGridDataCount("gridList1") > 0) {
				var rowData = gridList.getRowData("gridList1", gridList.getFocusRowNum("gridList1"));
				// page.linkPopOpen("/mes/erpif/IF00POPD.page", rowData); // 2022-04-27 강현주 부장님이 요청
				rowData.put("SEQNO", rowData.get("LASTLOG"))
				console.log(rowData)
				page.linkPopOpen("/mes/erpif/IF01POPD.page", rowData);
			} else {
				commonUtil.msgBox("VALID_M0005"); // 조회된 데이터가 없습니다.
			}
		} else if(btnName == "Excel") {
			// 엑셀업로드
			if(gridList.getGridDataCount("gridList1") > 0) {
				var rowData = gridList.getRowData("gridList1", gridList.getFocusRowNum("gridList1"));
				if(rowData.get("SYSTO") == "WMS") {
					page.linkPopOpen("/mes/erpif/IF00POP.page", rowData);
				} else {
					commonUtil.msgBox("ITF_M0028"); // 수신시스템이 WMS인 경우만 엑셀업로드 할 수 있습니다.
				}
				
			} else {
				commonUtil.msgBox("VALID_M0005"); // 조회된 데이터가 없습니다.
			}
		} else if(btnName == "Receive") {
			// 데이터수신
			if(gridList.getGridDataCount("gridList1") > 0) {
				var rowData = gridList.getRowData("gridList1", gridList.getFocusRowNum("gridList1"));
				if(rowData.get("SYSFR") == "SAP" || rowData.get("SYSFR") == "HR" || rowData.get("SYSFR") == "WCS") {
	 				page.linkPopOpen("/mes/erpif/IF00POPR.page", rowData);
				} else {
					commonUtil.msgBox("ITF_M0026"); // 송신시스템이 SAP인 경우만 수신요청 할 수 있습니다.
				}
			} else {
				commonUtil.msgBox("VALID_M0005"); // 조회된 데이터가 없습니다.
			}
		} else if(btnName == "Send") {
			// 실적전송
			if(gridList.getGridDataCount("gridList1") > 0) {
				var rowData = gridList.getRowData("gridList1", gridList.getFocusRowNum("gridList1"));
				if(rowData.get("SYSFR") == "MES") {
					page.linkPopOpen("/mes/erpif/IF00POPS.page", rowData);
				} else {
					commonUtil.msgBox("ITF_M0034"); // 송신시스템이 WMS인 경우만 데이터송신 할 수 있습니다.
				}
				
			} else {
				commonUtil.msgBox("VALID_M0005"); // 조회된 데이터가 없습니다.
			}
		} else if(btnName == "Save") {
			// 저장
			save();
		} else if(btnName == 'FIELD') {
			var rowData = gridList.getRowData("gridList1", gridList.getFocusRowNum("gridList1"));
			page.linkPopOpen("/mes/erpif/IF00MAP.page", rowData);
		}else if(btnName == 'UnProcess'){
			//미처리건 전송
			UnProcess();
		}
	}
	
	function searchList(){
		if(validate.check("searchArea")){
			var ifid = $('#IFID').val();
			var iftbl = $('#IFTBL').val();
			var param = inputList.setRangeDataParam("searchArea");
			if(inputList.getMultiComboValue($("#IFID")).length == $('#IFID > option').length) {param.get("RANGE_DATA_PARAM").remove("IFID_Single")};
			if(inputList.getMultiComboValue($("#IFTBL")).length == $('#IFTBL > option').length) {param.get("RANGE_DATA_PARAM").remove("IFTBL_Single")};
			if(inputList.getMultiComboValue($("#SYSFR")).length == $('#SYSFR > option').length) {param.get("RANGE_DATA_PARAM").remove("SYSFR_Single")};
			if(inputList.getMultiComboValue($("#SYSTO")).length == $('#SYSTO > option').length) {param.get("RANGE_DATA_PARAM").remove("SYSTO_Single")};
			gridList.gridList({
				id : "gridList1",
				param : param
			});
		}
		
		$("#tab1").trigger('click'); 
		$('#btn_unProcess').hide();
	}
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if(gridId == "gridList1"){
			var list = gridList.getGridData(gridId);
			for(var i=0; i < list.length; i++) {
				var ifid = list[i].get("IFID");
				var ifstat = list[i].get("IFSTAT");
				var sysfr = list[i].get("SYSFR");
				var systo = list[i].get("SYSTO");
				if(ifstat == "REAL") {
				}
				if(sysfr == "SAP") {
					gridList.setRowReadOnly(gridId, i, false, ["RFCP2"]);
					} else {
					gridList.setRowReadOnly(gridId, i, true, ["RFCP2"]);
				}
				// if(sysfr == "SAP" || systo == "SAP") {
				// 	gridList.setRowReadOnly(gridId, i, false, ["PLANTYN"]);
				// }else {
				// 	gridList.setRowReadOnly(gridId, i, true, ["PLANTYN"]);
				// }
				gridList.setRowReadOnly(gridId, i, true, ["PLANTYN"]);
				gridList.setRowReadOnly(gridId, i, true, ["PROCNM"]);
				gridList.setRowReadOnly(gridId, i, true, ["RFCFN"]);
				gridList.setRowReadOnly(gridId, i, true, ["RFCTBL"]);
				gridList.setRowReadOnly(gridId, i, true, ["RFCP1"]);
				gridList.setRowReadOnly(gridId, i, true, ["PLANTYN"]);
				gridList.setRowReadOnly(gridId, i, true, ["COMTYP"]);
				gridList.setRowReadOnly(gridId, i, true, ["POLLTY"]);
				gridList.setRowReadOnly(gridId, i, true, ["POLLTM"]);
				gridList.setRowReadOnly(gridId, i, true, ["GRP_CD"]);
				if((sysfr=='WMS' && systo == 'MES') || (sysfr=="MES" && systo == 'WMS')) {
					gridList.setRowReadOnly(gridId, i, false, ["RFCFN"]);
					gridList.setRowReadOnly(gridId, i, true, ["POLLTM"]);
					gridList.setRowReadOnly(gridId, i, true, ["IFSTAT"]);
					gridList.setRowReadOnly(gridId, i, true, ["POLLTY"]);
					gridList.setRowReadOnly(gridId, i, true, ["PRORTY"]);
					if(sysfr=='WMS' && systo == 'MES' ) {
						gridList.setRowReadOnly(gridId, i, true, ["RFCFN"]);
					}
				}
				if((sysfr == 'SAP' && systo == 'MES') || (sysfr == 'MES' && systo == 'SAP')) {
					gridList.setRowReadOnly(gridId, i, false, ["GRP_CD"]);
				}
				if(ifid == 'MES_IF_114'
					|| ifid == 'MES_IF_115'
					|| ifid == 'MES_IF_116'
					|| ifid == 'MES_IF_117'
					|| ifid == 'MES_IF_118'
					|| ifid == 'MES_IF_119'
					|| ifid == 'MES_IF_120'
					|| ifid == 'MES_IF_121'
					|| ifid == 'MES_IF_122'
					|| ifid == 'MES_IF_113'
					|| ifid == 'MES_IF_103'
	                || ifid == 'MES_IF_971'					
	                || ifid == 'MES_IF_973'
				) {
					gridList.setRowReadOnly(gridId, i, true, ["RFCP2"]);
				}

			}
			
			// 기존 위치 포커스
			if(curRow == "") {
				gridListEventRowClick(gridId, 0);
			} else {
				var ifid = gridList.getColData(gridId, curRow, "IFID");
				var len = gridList.getGridData(gridId).length;
	
				gridList.setColFocus(gridId, len-1, "IFID");
				
				for(var i=0; i < len; i++) {
					if(ifid == gridList.getColData(gridId, i, "IFID")) {
						setTimeout(function(){
							gridList.setColFocus(gridId, i, "IFID");
// 							gridList.setRowFocus(gridId, i);
						}, 1);
						return;
					}
				}
			}
		}
	}
	
	function gridListEventRowCheck(gridId, rowNum, checkType){
		if(gridId == 'gridList1'){
			if(checkType == true){
				var ncnt = gridList.getColData(gridId, rowNum, 'NCNT');	//미처리건수
				var ifstat = gridList.getColData(gridId, rowNum,  'IFSTAT')	//스케줄 여부
				var grpcd = gridList.getColData(gridId, rowNum, 'GRP_CD');
				var finNm = gridList.getColData(gridId, rowNum, 'FIN_NM');	//처리상태
				
				if((Number(ncnt) != 0 && ifstat == 'Y') && (grpcd == 'B' || grpcd == 'A')){
					if(finNm == '종료'){
						$('#btn_unProcess').show();
					}else{
						gridList.setRowCheck(gridId, rowNum, true);
						return alert('스케줄이 실행 중이면 처리할 수 없습니다.');	
					}
				}else{
					$('#btn_unProcess').hide();
				}
			}else{
				$('#btn_unProcess').hide();
			}	
		}
	}
	
	function save(){
		var list = gridList.getSelectData("gridList1");
		if(list.length == 0) {
			commonUtil.msgBox("VALID_M0006"); // 선택된 데이터가 없습니다.
			return;
		}
		var chkPOLLTY;
		var chkPOLLTM;
		var chkPRORTY;
		for(var i=0; i < list.length; i++) {
			chkPOLLTY = list[i].get("POLLTY");
			if(list[i].get("IFSTAT") != "REAL" && chkPOLLTY.trim() == "") {
				commonUtil.msgBox("OUT_M0020", ["실행주기"]); // {0} 은(는) 필수 입력사항입니다.
				return;
			}

			chkPOLLTM = list[i].get("POLLTM");
			if(list[i].get("IFSTAT") != "REAL" && chkPOLLTM.trim() == "") {
				commonUtil.msgBox("OUT_M0020", ["실행시간"]); // {0} 은(는) 필수 입력사항입니다.
				return;
			}
			if(list[i].get("IFSTAT") != "REAL" && chkPOLLTM.trim() <= 0) {
				setTimeout(function(){
				gridList.setColFocus("gridList1", i, "POLLTM");
				}, 1);
				commonUtil.msgBox("VALID_gt", ["0"]); // {0}보다 큰 값이어야 합니다.
				return;
			}

			chkPRORTY = list[i].get("PRORTY");
			if(chkPRORTY.trim() == "") {
				commonUtil.msgBox("OUT_M0020", ["우선순위"]); // {0} 은(는) 필수 입력사항입니다.
				return;
			}
		}
		
		var param = new DataMap();
		param.put("list", list);
		
		var json = netUtil.sendData({
			url : "/mes/erpif/json/saveIF.data",
			param : param
		});
		
		if(json && json.data) {
			commonUtil.msgBox("VALID_M0001"); // 저장이 성공하였습니다.

			searchList();
		}
	}
	//미처리건수 처리
	function UnProcess(){
		var list = gridList.getSelectData('gridList1');
		
		if(list.length > 1){	
			return alert('하나의 인터페이스 항목만을 처리할 수 있습니다.');
		}
		
		page.linkPopOpen("/mes/erpif/IF00_POP01.page", list);
	}
	
	function comboEventDataBindeBefore(comboAtt){
	}
	
	function gridListEventRowDblclick(gridId, rowNum){
		if(gridId == "gridList1"){
			commonBtnClick("Detail");
		}
	}
	
	function gridListEventRowClick(gridId, rowNum){
		if(gridId == "gridList1"){
			// 재조회시 포커스처리
			curRow = rowNum;
			
			// 체크사항 START (완료후 지울것)
			if(gridList.getGridData("gridList1")[rowNum].get("IFID") == "WMS_IF_223") {
				alert("[협의후 진행] 인터페이스 상세항목중 MES에서 LOT정보 보내줄수 있는지 확인 필요");
			}
			if(gridList.getGridData("gridList1")[rowNum].get("IFID") == "WMS_IF_323") {
				alert("[삭제예정] WMS_IF_317 생산투입불출실적정보 통합");
			}
			// // 데이터수신 버튼제어
			if(gridList.getGridData("gridList1")[rowNum].get("SYSFR") == "SAP" || gridList.getGridData("gridList1")[rowNum].get("SYSFR") == "HR" || gridList.getGridData("gridList1")[rowNum].get("SYSFR") == "WCS") {
				$('#btn_receive').css('visibility','visible');
				$('#btn_receive').css('visibility','visible');
			} else {
				$('#btn_receive').css('visibility','hidden');
				$('#btn_receive').css('visibility','hidden');
			}
			//
			// // 데이터송신 버튼제어
			if(gridList.getGridData("gridList1")[rowNum].get("SYSFR") == "MES" && gridList.getGridData("gridList1")[rowNum].get("IFSTAT") != 'REAL') {
				$('#btn_send').css('visibility','visible');
				$('#btn_send').css('visibility','visible');
			} else {
				$('#btn_send').css('visibility','hidden');
				$('#btn_send').css('visibility','hidden');
			}
			// 필드매핑
			if(gridList.getGridData("gridList1")[rowNum].get('IFID') =='WCS_IF_860' ||(gridList.getGridData("gridList1")[rowNum].get("SYSFR") == "MES" && gridList.getGridData("gridList1")[rowNum].get("SYSTO") == "WMS") ||
					(gridList.getGridData("gridList1")[rowNum].get("SYSFR") == "MES" && gridList.getGridData("gridList1")[rowNum].get("SYSTO") == "SAP")) {
				$('#btn_ifs').css('visibility','visible');
				$('#btn_ifs').css('visibility','visible');
			} else {
				$('#btn_ifs').css('visibility','hidden');
				$('#btn_ifs').css('visibility','hidden');
			}
		}
	}
</script>
</head>
<body>
<%@ include file="/common/include/webdek/layout.jsp" %>
<!-- content -->
<div class="content_wrap">
	<div class="content_inner">
		<%@ include file="/common/include/webdek/title.jsp" %>
		<div class="content_serch" id="searchArea">
			<div class="btn_wrap">
				<div class="fl_l"></div>
				<div class="fl_r">
					<input type="button" CB="Search SEARCH BTN_DISPLAY" />
					<input type="button" CB="Detail SEARCH BTN_DISDTL" />
					<input type="button" CB="FIELD APPLY 인터페이스필드" id="btn_ifs"/>
					<input type="button" CB="Receive APPLY 데이터수신" id="btn_receive"/>
					<input type="button" CB="Send APPLY 데이터전송" id="btn_send"/>
					<input type="button" CB="UnProcess APPLY 미처리건처리" id="btn_unProcess"/>
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_IFID">인터페이스ID</dt>
						<dd>
							<select Combo="Erpif,IFCOMBO" style="width:200px;" class="input" name="IFID" id="IFID" ComboType="MS" validate="required(STD_IFID)"></select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_IFTBL">IF테이블</dt>
						<dd>
							<select Combo="Erpif,IFTBLCOMBO" ComboCodeView="false" style="width:200px;" class="input" name="IFTBL" id="IFTBL" ComboType="MS"></select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_SYSFR">송신시스템</dt>
						<dd>
							<select Combo="Erpif,IFSYSFR" ComboCodeView="false" style="width:200px;" class="input" name="SYSFR" id="SYSFR" ComboType="MS"></select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_SYSTO">수신시스템</dt>
						<dd>
							<select Combo="Erpif,IFSYSTO" ComboCodeView="false" style="width:200px;" class="input" name="SYSTO" id="SYSTO" ComboType="MS"></select>
						</dd>
					</dl>
					<dl>
						<dt CL="그룹구분">그룹구분</dt>
						<dd>
							<select Combo="Erpif,IFGRPCD" ComboCodeView="true" style="width:200px;" class="input" name="A.GRP_CD" id="A.GRP_CD" ComboType="MS"></select>
						</dd>
					</dl>
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
		<div class="search_next_wrap">
			<div class="content_layout tabs">
				<ul class="tab tab_style02">
					<li><a href="#tabs1-1" CL='STD_LIST'><span>리스트</span></a></li> 
				</ul>
				<div class="search_sub">
					<dl>
						<dd>
							<input type="button" CB="Save SAVE STD_SAVE" />
						</dd>
					</dl>
				</div>
				<div class="table_box section" id="tabs1-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridList1">
									<tr CGRow="true">
										<td GH="40" GCol="rownum"></td>
										<td GH="40" GCol="rowCheck"></td>
										<td GH="100 STD_IFID" GCol="text,IFID">인터페이스ID</td>
										<td GH="300 STD_IFKNM" GCol="text,IFKNM">인터페이스한글명</td>
										<td GH="60 STD_SYSFR" GCol="text,SYSFR">송신시스템</td>
										<td GH="60 STD_SYSTO" GCol="text,SYSTO">수신시스템</td>
										<td GH="110 그룹" GCol="select,GRP_CD">
											<select Combo="Erpif,IFGRPCD">
												<option value=" "></option>
											</select>
										</td>
										<td GH="50 처리상태" GCol="text,FIN_NM"></td>
										<td GH="130 처리시작시간" GCol="text,STARTDATE" GF="DTS">최근처리시간</td>
										<td GH="130 처리종료시간" GCol="text,LASTDATE" GF="DTS">최근처리시간</td>
										<td GH="130 미처리수" GCol="text,NCNT" GF="N 25">미처리수</td>
										<td GH="100 STD_IFTBL" GCol="text,IFTBL">인터페이스 테이블</td>
										<td GH="110 플랜트사용여부" GCol="select,PLANTYN">
											<select CommonCombo="USEYN">
												<option value=" "></option>
											</select>
										</td>
										<td GH="110 스케쥴사용여부" GCol="select,IFSTAT">
											<select CommonCombo="IFSTAT">
												<option value=" "></option>
											</select>
										</td>
										<td GH="80 오더구분" GCol="text,BWART" style="text-align: center"></td>
<%--										<td GH="110 ITF_POLLTY" GCol="select,POLLTY">--%>
<%--											<select CommonCombo="POLLTY" validate="required">--%>
<%--												<option value=" "></option>--%>
<%--											</select>--%>
<%--										</td>--%>
<%--										<td GH="80 ITF_POLLTM" GCol="input,POLLTM" validate="required" GF="NS 4">실행시간</td>--%>
										<td GH="80 통신유형" GCol="select,COMTYP">
											<select CommonCombo="COMTYP" validate="required" ComboCodeView="false">
												<option value=" "></option>
											</select>
										</td>
										<td GH="140 프로시저이름" GCol="input,PROCNM">프로시저이름</td>
										<td GH="80 STD_PRORTY" GCol="input,PRORTY" validate="required" GF="N 4">우선순위</td>
										<td GH="370 ITF_RFCFN" GCol="input,RFCFN">SAP RFC FUNCTION</td>
										<td GH="140 ITF_RFCTBL" GCol="input,RFCTBL">SAP RFC TABLE</td>
 										<td GH="100 ITF_RFCP1" GCol="input,RFCP1">SAP RFC P1</td>
										<td GH="110 ITF_IFRCVRANGE" GCol="select,RFCP2">
											<select CommonCombo="IFRCVRANGE">
												<option value=" "></option>
											</select>
										</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<div class="btn_lit tableUtil">
						<button type='button' GBtn="find"></button>
						<button type='button' GBtn="sortReset"></button>
						<button type='button' GBtn="excel"></button>
						<span class='txt_total' >총 건수 : <span GInfoArea='true'>0</span></span>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>