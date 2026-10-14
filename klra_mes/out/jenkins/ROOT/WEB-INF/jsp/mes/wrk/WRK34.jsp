<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>MES</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript">
	var machCd;
	
	$(document).ready(function(){
		gridList.setGrid({
			id : "gridList",
			url:"/mes/Work/WRK34/json/datalist.data",
			bigdata : false
		})
		
		gridList.setGrid({
			id : "gridList2",
			url:"/mes/Work/WRK34/json/datalist.data",
			bigdata : false,
			emptyMsgType : false
		})
		
		gridList.setGrid({
			id : "gridList3",
			url:"/mes/Work/WRK34/json/datalist.data",
			bigdata : false,
			emptyMsgType : false
		})
	});
	
	// 작업지시정보 더블 클릭, id="gridList"의 선택된 row
	let row = 0
		
	// 조회
	function searchList() {
		if (validate.check("searchArea")) {
			/* var range = inputList.setRangeParam("searchArea");
			var range_data_param = range.get("RANGE_DATA_PARAM");
			var prfm_dt = range_data_param.get("PRD_REQ_DT_Range");
			var date = prfm_dt.split('↓');
			var SDate = date[1];
			var EDate = date[2]; */
			
			var param = inputList.setRangeParam("searchArea");
			
			param.put("P_TYPE", "LIST");
			/* param.put("SDATE", SDate);
			param.put("EDATE", EDate);
			param.put("WERKS",$("#WERKS").val().toUpperCase());
			param.put("PROC_GRP_CD",$("#PROC_GRP_CD").val()); */
	
			gridList.gridList({
				id : "gridList",
				param : param
			});
			
			// 투입자재 정보 RESET
//			gridList.resetGrid("gridList2")
			
			// 투입자재 상세정보 RESET
//			gridList.resetGrid("gridList3") 
		}
	}
	
	// 투입자재 정보 리스트
	const searchList2 = (rowNum) => {
		// id="gridList"의 작업지시번호
		const WRK_ORDR_NO = gridList.getColData("gridList", rowNum, "WRK_ORDR_NO");
		
		// id="gridList"의 작업지시순번
		const WRK_ORDR_SEQNO = gridList.getColData("gridList", rowNum, "WRK_ORDR_SEQNO");
		
		var param = inputList.setRangeParam("searchArea");
		param.put("P_TYPE", "SUB_LIST1");
		param.put("WRK_ORDR_NO", WRK_ORDR_NO);
		param.put("WRK_ORDR_SEQNO", WRK_ORDR_SEQNO);

		gridList.gridList({
			id : "gridList2",
			param : param
		});
	}
	
	// 투입자재 상세정보 리스트
	const searchList3 = (rowNum) => {
			   
		// id="gridList"의 작업지시번호
		const WRK_ORDR_NO = gridList.getColData("gridList", rowNum, "WRK_ORDR_NO");
		
		// id="gridList"의 작업지시순번
		const WRK_ORDR_SEQNO = gridList.getColData("gridList", rowNum, "WRK_ORDR_SEQNO");
		
		var param = inputList.setRangeParam("searchArea");
		param.put("P_TYPE", "SUB_LIST2");
		param.put("WRK_ORDR_NO", WRK_ORDR_NO);
		param.put("WRK_ORDR_SEQNO", WRK_ORDR_SEQNO);
		
		gridList.gridList({
			id : "gridList3",
			param : param
		});
	}
	
	// 그리드 행 더블 클릭
	const gridListEventRowDblclick = (gridId, rowNum) => {

		if(gridId === "gridList"){
			row = rowNum
			
			searchList2(rowNum)
			searchList3(rowNum);

			// Double Click 처리 후 Check Box CHECK - 2024/10/17 김지은 선임님 요청, 강지선 작업
			console.log("## gridListEventRowDblclick() > rowNum = ", rowNum);
			gridList.setRowCheck(gridId, rowNum, true);

		}
	}
	
	// 투입대기자재 목록 조회 - 2024/07/12 강지선
	function openWaitList(){
		var data = gridList.getSelectData("gridList");
		console.log("## openWaitList() > data = ", data);

		if (data.length < 1) {
			alert("작업지시를 선택해 주세요.");
		} else if (data.length > 1) {
			alert("하나의 항목만 선택해 주세요.") 
		} else {
			// 선택한 작업지시 상태 확인
			// console.log("## data[0].get('COMP_YN_NM') = ", data[0].get("COMP_YN_NM"));
			if (data[0].get("COMP_YN") != "Y") {
				page.linkPopOpen("/mes/wrk/WRK34_POP02.page", data, "left=100,top=100,height=800,width=1800")
			} else {
				alert("이미 완료된 작업지시입니다.") 
			}

		}
	}

	// 공정투입
	function saveData() {
		console.log("## saveData() > START ##");

		// id="gridList"의 작업지시상태가 완료인 경우 공정 투입 X
		const COMP_YN_NM = gridList.getColData("gridList", row, "COMP_YN_NM");
		
		if(COMP_YN_NM == "완료"){
			alert("이미 완료된 항목입니다.")
			return;
		}
		
		let data = gridList.getSelectData("gridList2")

		if(data.length < 1) alert("투입자재 정보를 선택하시기 바랍니다.")
		else if(data.length > 1) alert("하나의 항목만 선택하시기 바랍니다.")
   		else{
   			// 투입 자재 추가
   			if(data[0].get("GRowState") === "C"){
   				
   				const index = data[0].get("GRowNum")
   				// VALIDATION
   				// 자재코드
   				if(gridList.getColData("gridList2", index, "MATNR") == ""){
   					alert("자재코드를 선택하세요.")
   					gridList.setColFocus("gridList2", index, "MATNR")
   					return
   				}
   				
   				data[0].put("WERKS",gridList.getColData("gridList", row, "WERKS"))
   				data[0].put("MATNR",gridList.getColData("gridList2", index, "MATNR"))
   				data[0].put("MACH_CD",gridList.getColData("gridList", row, "MACH_CD"))
   				data[0].put("WRK_ORDR_NO",gridList.getColData("gridList", row, "WRK_ORDR_NO"))
   				data[0].put("WRK_ORDR_SEQNO",gridList.getColData("gridList", row, "WRK_ORDR_SEQNO"))
   			}
   			
   			// 공정투입 팝업
			page.linkPopOpen("/mes/wrk/WRK34_POP01.page", data, "height=800,width=1350")
   		}

		   console.log("## saveData() > END ##");
	}
	
	// 공정투입 후 실행
	function linkPopCloseEvent(data){
		searchList2(row)
		searchList3(row);
	}
	
	// 실적등록
	function reg(){
		var json = netUtil.sendData({
    		module : 'mes',
    		command : 'SYSTEMCHECK',
    		sendType : 'map'
    	});
    	
    	if(json.data.USE_YN == 'Y'){
    		alert('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.');
    		return;
    	}
		
		if(gridList.validationCheck("gridList", "all")){
			var list = gridList.getSelectData("gridList");
			if(list.length === 0){
				alert("선택된 행이 없습니다.")
				return
				//20220830 여한진 여러 개의 지시를 선택할 수 있도록 되어 있어서 validate 추가
			}else if(list.length > 1){
				alert('하나의 지시만 선택가능합니다.');
				return;
			}
						
			machcd = list[0].get("MACH_CD").substr(0,3);
			
			if(confirm("실적등록하시겠습니까?")){
				var list1 = gridList.getSelectData("gridList3");
				var param = new DataMap();
				
				param.put("P_TYPE", "SUB_SAVE");
				param.put("list", list);
				param.put("list1", list1);
				
				netUtil.send({
			    	url : "/mes/Work/WRK34/json/datalist.data",
			    	param : param,
			    	successFunction : "saveSuccessCallBack"
			    });
			}
		}
	}

	//20220804 여한진 SAP에 생산실적 송신
	function saveSuccessCallBack(json){
		if(json.CODE == 'E'){
			alert(json.MSG);
		}else {
			if(machcd != "SPF"){
				var param = new DataMap();
				
				var docno = json.DOC_NO.split(',');
				var message = '';
				
				for(var i = 0; i < docno.length; i++){
					param.put("IFID", "MES_IF_141");
			    	param.put("DOC_NO", docno[i]);	//SAP문서번호
			    	
		    		var json2 = netUtil.sendData({
			        	url : "/mes/erpif/json/sendIF.data",
			        	param : param
			        });
		    		
		    		if(json2.data == 'SUCCESS'){
			    	}else{
			    		message = '(SAP 생산실적) ' + (i + 1) + '번째 오류는 ' + json2.data + '\n';
			    	}
				}
				if(message == ''){
					alert("실적등록되었습니다.");
				}else{
					alert(message);
				}
			}else{
				alert("실적등록되었습니다.");
			}
			searchList();
		}
	}
	
	// 설비선택
	function selectmachine(){
		if(gridList.validationCheck("gridList", "all")){
			
			var list = gridList.getSelectData("gridList");
			if(list.length === 0){
				alert("선택된 항목이 없습니다.")
				return
			}
			
			for(var i = 0; i < list.length; i++){
				if(list[i].get("COMP_YN") == "I"){
					alert("작업진행중인 설비를 변경할 수 없습니다.")
					return;
				}else if(list[i].get("COMP_YN") == "N"){

					if(confirm("설비를 선택하시겠습니까?")){
						var param = new DataMap();
						
						param.put("P_TYPE", "SAVE4");
						param.put("list", list);
						//20220720 여한진 RFC 호출
						netUtil.send({
					    	url : "/mes/Work/WRK34/json/datalist.data",
					    	param : param,
					    	successFunction : "savesuccessCallBack3"
					    });
					}
				}
			}
		}
	}
	
	// 설비 선택 후 실행
	function savesuccessCallBack3(json){
		if(json){
			if(json.data){
				if(json.CODE == 'E'){
					alert(json.MSG);
					return;
				}else if(json.CODE == 'S'){
					alert("선택 완료");
					searchList();
				}
			}
		}
	} 
	
	// grid 조회 시 data 적용이 완료된 후
	function gridListEventDataBindEnd(gridId, dataLength){
		if(gridId === "gridList"){
			var list = gridList.getGridData(gridId);
			for(var i=0; i < list.length; i++) {
				if(list[i].get("COMP_YN") == "Y"){ // 작업지시상태(N : 대기, I : 진행중, Y : 완료)
					gridList.setRowReadOnly(gridId, i, true, ["MACH_CD","PRFM_QTY","PRD_STR_DT","PRD_STR_TM","PRD_END_DT","PRD_END_TM"]); // 작업순서,지시량,작업지시비고,사용여부 수정 안되게
				}
			}
		}else if(gridId === "gridList3"){
			const data = gridList.getRowData("gridList", row)
			if(data.get("COMP_YN") == "Y"){ // 작업지시상태(N : 대기, I : 진행중, Y : 완료)
				const list = gridList.getGridData(gridId);
				for(let i = 0; i < list.length; i++){
					gridList.setRowReadOnly(gridId, i, true, ["INP_QTY"]); // 작업순서,지시량,작업지시비고,사용여부 수정 안되게
				}
			}
		}
	}
	
	// 버튼 클릭
	function commonBtnClick(btnName){
		// 조회
		if (btnName == "Search") {
			searchList();
		// 공정투입
		} else if (btnName == "Save") {
			saveData();
		// 실적등록
		} else if (btnName == "Reg") {
			reg();
		// 설비선택
		} else if(btnName == "Select") {
			selectmachine();
		// 투입취소
		} else if(btnName == "PROCCANCEL") {
			proccancel();
		// 투입대기자재목록
		} else if(btnName == "openPop") {
			openWaitList();
		}
	}
	
	//공정투입취소
	const proccancel = () => {
		const COMP_YN_NM = gridList.getColData("gridList", row, "COMP_YN_NM");
		
		//20220830 여한진 투입된 자재들에 대해 다시 공정창고로 가기 위해  
		/* if(COMP_YN_NM == "완료"){
			alert("이미 완료된 항목입니다.")
			return;
		} */
		
		if(gridList.validationCheck("gridList", "all")){
			var list1 = gridList.getSelectData("gridList3");
			if(list1.length === 0){
				alert("선택된 항목이 없습니다.")
				return
			}
			
			if(confirm("투입취소하시겠습니까?")){
				var list = gridList.getSelectData("gridList");
				var list1 = gridList.getSelectData("gridList3");
				var param = new DataMap();
				
				param.put("P_TYPE", "SAVE3");
				param.put("list", list);
				param.put("list1", list1);
				//20220720 여한진 RFC 호출
				netUtil.send({
			    	url : "/mes/Work/WRK34/json/datalist.data",
			    	param : param,
			    	successFunction : "savesuccessCallBack2"
			    });
			}
		}
	}
	
	// 공정 취소 후 실행
	function savesuccessCallBack2(json){
		if(json){
			if(json.data){
				if(json.CODE == 'E'){
					alert(json.MSG);
				}else{
					alert("투입 취소 완료");
					searchList2(row);
					searchList3(row);
				}
			}
		}
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId == "gridList"){
			if(colName == "PRD_STR_TM" || colName == "PRD_END_TM"){
				if(colValue.length >= 5){
					gridList.setColValue(gridId, rowNum, colName, "");
					
					alert("시간 형식으로 입력하세요. ");
				} else if(colValue.length == 2){
					gridList.setColValue(gridId, rowNum, colName, colValue + "00");
				}
				if(Number(colValue.substr(0,2)) > 23){
					gridList.setColValue(gridId, rowNum, colName, "");
					alert("올바른 시간 형식이 아닙니다. ");
				} else if(Number(colValue.substr(2,4)) > 59){
					gridList.setColValue(gridId, rowNum, colName, "");
					alert("올바른 시간 형식이 아닙니다. ");
				}
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
				<div class="fl_l">
				</div>
				<div class="fl_r">
					<input type="button" id="button-0-1" CB="Search SEARCH BTN_SEARCH" />
					<input type="button" id="button-0-5" CB="Select SAVE BTN_SELECTMACHINE" />
					<input type="button" id="button-0-4" CB="Reg SAVE BTN_REGPRFM" />
					<input type="button" id="button-0-3" CB="PROCCANCEL CANCEL BTN_PROCCANCEL" />
					<input type="button" id="button-0-2" CB="Save SAVE BTN_PROCINPUT" style="display: none" />
					<input type="button" id="button-0-6" CB="openPop SEARCH BTN_WAIT_MATERIAL" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" name="WERKS" id="WERKS" UIInput="S,PLANT" UIFormat="U" validate="required"/>
						</dd>
					</dl>
					<dl>
						<dt>생산지시일자</dt>
						<dd>
                        	<input type="text" name="PRD_REQ_DT" id="PRD_REQ_DT" UIInput="B" UIFORMAT="C M1"/>
                        </dd>
					</dl>
					<dl>
						<dt>공정그룹</dt>
						<dd>
							<select class="input" name="PROC_GRP_CD" id="PROC_GRP_CD" CommonCombo="PROCGRP">
								<option value="">ALL</option>
							</select>
						</dd>
					</dl>
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
        <div class="search_next_wrap">
			<div class="content_layout tabs top_layout">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span>작업지시정보</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH="40" GCol="rowCheck"></td>
										<td GH="80" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="140" GCol="text,WRK_ORDR_NO" style="text-align:center;">작업지시번호</td>
										<td GH="60" GCol="text,WRK_ORDR_SEQNO" style="text-align:center;">작업지시순번</td>
										<td GH="100" GCol="text,PRD_REQ_DT" GF='D' style="text-align:center;">생산요청일자</td>
										<td GH="60" GCol="text,UNIT" style="text-align:center;">단위</td>
										<td GH="100" GCol="text,WRK_ORDR_QTY" GF="N 13,3">생산지시량</td>
										<td GH="100" GCol="text,COMP_YN_NM" style="text-align:center;">처리완료명</td>
										<td GH="140" GCol="input,MACH_CD,MACH" style="text-align:center;">설비코드</td>
										<td GH="100" GCol="text,MACH_NM">설비명</td>
										<td GH="60" GCol="text,PRFM_UNIT" style="text-align:center;">실적단위</td>
										<td GH="100" GCol="input,PRFM_QTY" GF="N 13,3">실적수량</td>
										<td GH="100" GCol="input,PRD_STR_DT" GF="C" style="text-align:center;">시작일자</td>
										<td GH="100" GCol="input,PRD_STR_TM" GF="T">시작시간</td>
										<td GH="100" GCol="input,PRD_END_DT" GF="C" style="text-align:center;" >종료일자</td>
										<td GH="100" GCol="input,PRD_END_TM" GF="T">종료시간</td>
										<td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH="180" GCol="text,MATNR_NM">자재명</td>
										<td GH="100" GCol="text,ORDER_NO">오더번호</td>
										<td GH="80" GCol="text,ORDER_DIV" style="text-align:center;">오더유형</td>
										<td GH="180" GCol="text,ORDER_DIV_NM">오더유형명</td>
										<td GH="100" GCol="text,COMP_YN" style="text-align:center;">처리완료</td>
										<td GH="100" GCol="text,ORDER_QTY" GF="N 13,3">오더량</td>
										<td GH="100" GCol="text,SCNT" GF="N 13,3">속수</td>
										<td GH="100" GCol="text,TOT_WGT" GF="N 13,3">총중량</td> 
										<td GH="100" GCol="text,PLT_PRFM_QTY" GF="N 13,1">PLT실적수량</td>
										<td GH="100" GCol="text,BOX_PRFM_QTY" GF="N 13">BOX실적수량</td>
										<td GH="100" GCol="text,BAG_PRFM_QTY" GF="N 13">BAG실적수량</td>
										<td GH="100" GCol="text,EA_PRFM_QTY" GF="N 13">EA실적수량</td>
										<td GH="100" GCol="text,R_PRFM_QTY" GF="N 13,3">R실적수량</td>
										<td GH="100" GCol="text,KG_PRFM_QTY" GF="N 13,3">KG실적수량</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="1" />
						<jsp:param name="showAuthCd" value="1,2,3,7,9,10" />
					</jsp:include>	
				</div>
			</div>
			<div class="content-horizontal-wrap bottom_layout">
				<div class="content_layout tabs" style="float: left; width: calc(45% - 10px);">
					<ul class="tab tab_style02">
						<li><a href="#tab1-2"><span>투입자재 정보</span></a></li>
						<li class="btn_zoom_wrap">
							<ul>
								<li><button class="btn btn_bigger"><span>확대</span></button></li>
							</ul>
						</li>
					</ul>
					<div class="table_box section" id="tab1-2">
						<div class="table_list01">
							<div class="scroll">
								<table class="table_c">
									<tbody id="gridList2">
										<tr CGRow="true">
											<td GH="40" GCol="rowCheck"></td>
											<td GH="140" GCol="add,MATNR,MATKY" style="text-align:center;">자재</td>
											<td GH="280" GCol="text,MATNR_NM">자재명</td>
											<td GH="60" GCol="text,UNIT" style="text-align:center;">단위</td>
											<td GH="100" GCol="text,INP_QTY" GF='N 13,3' style="text-align:center;">투입수량</td>
											<td GH="0" GCol="text,WRK_ORDR_NO" style="text-align:center;">작업지시번호</td>
											<td GH="0" GCol="text,WRK_ORDR_SEQNO" style="text-align:center;">작업지시순번</td>
											<td GH="0" GCol="text,MACH_CD" style="text-align:center;">설비코드</td>
										</tr>
									</tbody>
								</table>
							</div>
						</div>
						<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
							<jsp:param name="authCd" value="1" />
							<jsp:param name="showAuthCd" value="1,2,3,7,9,10" />
						</jsp:include>	
					</div>
				</div>
				<div class="content_layout tabs" style="float: right; width: calc(55% - 10px);">
					<ul class="tab tab_style02">
						<li><a href="#tab1-3"><span>투입자재 상세정보</span></a></li>
						<li class="btn_zoom_wrap">
							<ul>
								<li><button class="btn btn_bigger"><span>확대</span></button></li>
							</ul>
						</li>
					</ul>
					<div class="table_box section" id="tab1-3">
						<div class="table_list01">
							<div class="scroll">
								<table class="table_c">
									<tbody id="gridList3">
										<tr CGRow="true">
											<td GH="40" GCol="rowCheck"></td>
											<td GH="140" GCol="text,MATNR" style="text-align:center;">자재</td>
											<td GH="280" GCol="text,MATNR_NM">자재명</td>
											<td GH="140" GCol="text,IND_BCD" style="text-align:center;">개별바코드</td>
											<td GH="0" GCol="text,INP_QTY_TOT" GF='N 13,3'>투입수량합계</td>
											<td GH="100" GCol="text,INP_QTY" GF='N 13,3'>투입수량</td>
											<td GH="100" GCol="text,STCK_QTY" GF='N 13,3' >재고수량</td>
											<td GH="60" GCol="text,UNIT" style="text-align:center;">단위</td>
											<td GH="0" GCol="text,STOR_LOC_CD" style="text-align:center;">저장위치</td>
											<td GH="0" GCol="text,STOR_LOC_NM">저장위치명</td>
											<td GH="0" GCol="text,WRK_ORDR_NO" style="text-align:center;">작업지시번호</td>
											<td GH="0" GCol="text,WRK_ORDR_SEQNO" style="text-align:center;">작업지시순번</td>
											<td GH="0" GCol="text,MACH_CD" style="text-align:center;">설비코드</td>
											<td GH="0" GCol="text,WERKS" style="text-align:center;">PLANT</td>
										</tr>
									</tbody>
								</table>
							</div>
						</div>
						<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
							<jsp:param name="authCd" value="1" />
							<jsp:param name="showAuthCd" value="1,2,3,7,9,10" />
						</jsp:include>	
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