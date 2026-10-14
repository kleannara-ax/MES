<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript" src="/common/js/ezgencontrol.js"></script>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/demo_layout.css">
<script type="text/javascript">
	//var delipotflag = false;

	$(document).ready(function(){	
		gridList.setGrid({
			id : "gridList",
			url:"/mes/Inv/INV01/json/datalist.data",
			bigdata : false,
	    	pkcol :"WERKS",
	    	colHoldType : true,
	    	colHold : "WERKS,WRK_ORDR_NO,WRK_ORDR_SEQNO",
	    	colorType : true,
	    	colGroupCols : "WRK_ORDR_NO",
	    	firstRowFocusType : false
		})
		
		gridList.setGrid({
			id : "gridListSub",
			url:"/mes/Inv/INV01/json/datalist.data",
			bigdata : false,
	    	pkcol :"WERKS",
	    	colHoldType : true,
	    	colHold : "WERKS,MATNR,MATNR_NM"
		})
		
		//$('#li_DELIPOT').hide();
	});
	
	// 전체 checkbox 선택
	const gridListEventRowCheckAll = (gridId, checkType) => {
		f(gridId)
	}
	
	// 행 개별 checkbox 선택
	const gridListEventRowCheck = (gridId, rowNum, checkType) => {
		f(gridId)
	}
	
	// 체크박스 선택에 따른 함수
	const f = (gridId) => {
		//if(delipotflag == false){
			if(gridId === "gridList"){
				const data = gridList.getSelectData("gridList")
				//var wrkordrno = new Array();	//작업지시
				//var procCd1 = 'JA';		//점보롤
				//var procCd2 = 'MA';		//밀롤
				//var procCd3 = 'CA';		//재단
				//var procCd4 = 'PA';		//포장
				
				for(var i = 0; i < data.length; i++){
					if(data[i].get("WRK_ORDR_QTY") == " "){
						alert("지시량이 없습니다.");
						return;
					}
					//if($('#WERKS').val().toUpperCase() == 'P100'){
					//	wrkordrno.push(data[i].get('WRK_ORDR_NO').substr(2,2));
					//}
				}
				
				//if(wrkordrno != ''){
				//	if(wrkordrno.indexOf(procCd1) >= 0 || wrkordrno.indexOf(procCd2) >= 0 || wrkordrno.indexOf(procCd3) >= 0 || wrkordrno.indexOf(procCd4) >= 0){
				//		$('#li_DELIPOT').hide();
				//	}else{
				//		$('#li_DELIPOT').show();
				//	}
				//}else{
				//	$('#li_DELIPOT').hide();
				//}
				
				if(data.length >= 1){
					let condi = "AND (SCH020.WERKS,SCH020.WRK_ORDR_NO,SCH020.WRK_ORDR_SEQNO) IN ("
					for(let i = 0; i < data.length; i++){
						condi += "(\'" + data[i].get("WERKS") + "\',\'" + data[i].get("WRK_ORDR_NO") + "\',\'" + data[i].get("WRK_ORDR_SEQNO") + "\'),"
					}
					condi = condi.slice(0, -1)
					condi += ")"
					
					const param = inputList.setRangeParam("searchArea");
					param.put("P_TYPE", "SUB_LIST");
					param.put("OUT_SQL", condi);
					
					gridList.gridList({
						id : "gridListSub",
						param : param
					});
				}else{
					gridList.resetGrid("gridListSub")
				}
			}
		//}
	}
	
	function searchHelpEventCloseAfter(searchCode, multyType, selectData, rowData){
		if(searchCode == "PLANT"){
			reloadCombo();
		}
	}
	
	function reloadCombo(){
		if($('#WERKS').val().toUpperCase() == 'P100'){
			$('#WERKS').val('');
			alert('HL(생활용품)이 작업하는 화면이며,\nPS(제지)는 완제품 불출요청(PS)화면에서 작업할 수 있습니다.');
			return;
		}
		$comboObj = $("#MACHINE");
		inputList.reloadCombo($comboObj, configData.INPUT_COMBO, "Produce,MACHINE");
	}

	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "Produce,MACHINE"){
			var param = new DataMap();
			
			param.put("WERKS", $("#WERKS").val().toUpperCase());
			param.put('PROC_CD', $('#PROC_CD').val().toUpperCase());
		}
		return param;
	}
	
	// 조회
	function searchList(){
		if(validate.check("searchArea")){
			if($('#WERKS').val().toUpperCase() == 'P100'){
				alert('HL(생활용품)이 작업하는 화면이며,\nPS(제지)는 완제품 불출요청(PS)화면에서 작업할 수 있습니다.');
				return;
			}
			
			var param = inputList.setRangeParam("searchArea");
			
			param.put("P_TYPE", "LIST");
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
			//$('#li_DELIPOT').hide();
		}
		gridList.resetGrid("gridListSub");
	}
	
	//20221019 여한진 화장지 같은 경우 생산호기가 합지랑 가공이 구분이 가지 않아서 공정코드로 구분하기 위해
	function procCdcheck(){
		if($('#WERKS').val().toUpperCase() == 'P200'){
			if ($('#PROC_CD').val() == '') {
				$('#PROC_CD').focus();
				return alert('공정코드를 선택 및 입력하세요.');	
			}
		} 
	}
	
	//function gridListRowColorChange(gridId, rowNum, rowData){
	//	if(gridId === "gridList" && rowData.get("DELIPOT").trim() != ""){
	//		return configData.GRID_COLOR_BG_ORANGE_CLASS;
	//	}
 	//}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId == "gridListSub"){
			if(colName == "REQ_QTY"){
				
				var matnr = gridList.getColData(gridId, rowNum, "MATNR");
				var param = new DataMap();
				
				param.put('PROC_DIV', 'HL');
				param.put("MATNR", matnr);
				
				var json = netUtil.sendData({
					module : "Inv",
					command : "UNITCONVERSION",
					sendType : "list",
					param : param
				});
				console.log('1111colValue = ', colValue);
				
				if(json.data.length > 0){
					for(var i = 0; i < json.data.length; i++){
						var unitConversion = colValue * (json.data[i].UMREN / json.data[i].UMREZ);
						
						if(json.data[i].UNIT == "PAL"){
							gridList.setColValue(gridId, rowNum, "PLT_QTY", unitConversion);
						}else if(json.data[i].UNIT == "BOX"){
							gridList.setColValue(gridId, rowNum, "BOX_QTY", unitConversion);
						}else if(json.data[i].UNIT == "M"){
							gridList.setColValue(gridId, rowNum, "M", unitConversion);
						}else if(json.data[i].UNIT == "KG"){
							gridList.setColValue(gridId, rowNum, "KG", unitConversion);
						}else if(json.data[i].UNIT == "RL"){
							gridList.setColValue(gridId, rowNum, "RL", unitConversion);
						}
					}
				}
			} else if (colName == "BOX_QTY") {
				
				var matnr = gridList.getColData(gridId, rowNum, "MATNR");
				var unit = gridList.getColData(gridId, rowNum, "UNIT");
				var unitQty;
				var param = new DataMap();
				
				param.put('PROC_DIV', 'HL');
				param.put("MATNR", matnr);
				
				var json = netUtil.sendData({
					module : "Inv",
					command : "UNITCONVERSION",
					sendType : "list",
					param : param
				});
				if(json.data.length > 0){
					console.log('unitQty = ', unitQty);
					for (var i = 0; i < json.data.length; i++) {
						if (json.data[i].UNIT == "BOX") {
							unitQty = json.data[i].UMREZ;
						}
					}
					console.log('unitQty After = ', unitQty);
					colValue = colValue * unitQty;
					console.log('colValue = ', colValue);
					for(var i = 0; i < json.data.length; i++){
						var unitConversion = colValue * (json.data[i].UMREN / json.data[i].UMREZ);
						console.log('json.data[i] = ', json.data[i]);
						console.log('unitConversion = ', unitConversion);
						console.log('json.data[i].UMREN = ', json.data[i].UMREN);
						console.log('json.data[i].UMREZ = ', json.data[i].UMREZ);
						
						if(json.data[i].UNIT == "PAL"){
							gridList.setColValue(gridId, rowNum, "PLT_QTY", unitConversion);
						}else if(json.data[i].UNIT == "BOX"){
							gridList.setColValue(gridId, rowNum, "BOX_QTY", unitConversion);
						}else if(json.data[i].UNIT == unit){
							gridList.setColValue(gridId, rowNum, "REQ_QTY", unitConversion);
						}else if(json.data[i].UNIT == "M"){
							gridList.setColValue(gridId, rowNum, "M", unitConversion);
						}else if(json.data[i].UNIT == "KG"){
							gridList.setColValue(gridId, rowNum, "KG", unitConversion);
						}else if(json.data[i].UNIT == "RL"){
							gridList.setColValue(gridId, rowNum, "RL", unitConversion);
						}
					}
				}
			}
		}
	}
	
	// 버튼을 클릭한 경우
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			var param = new DataMap();
	        param.put("PROGID", "<%= menuId%>");
	        param.put("LGTYPE", "SEARCH");
	        var json = netUtil.sendData({
	            url: "/mes/system/json/saveLog.data",
	            param : param
	        });
			
			searchList();
		}else if(btnName == "Save"){
			if(validate.check("searchArea")){
				saveData();	
			}
		}
	}
	
	//20230104 기존에 지정되어 있는 하역지점과 같은지 체크
	/* function delipotCheck(){
		
		var list = gridList.getSelectData('gridList');
		var datalist = gridList.getGridData('gridList');
		
		for(var i=0; i<list.length; i++){
			if(list[i].get('WERKS') == 'P100'){
				if(list[i].get('DELIPOT').trim() != ''){
					if($('#DELIPOT').val() != ''){
						if(list[i].get('DELIPOT').trim() != $('#DELIPOT option:checked').text().substr(3)){
							
							delipotflag = true;
							
							alert('선택한 항목 중 ' + (i + 1) +'번째의 ' + list[i].get('WRK_ORDR_NO') + ' 작업지시는 \n' + list[i].get('DELIPOT') + ' 하역지점이 지정되어 있으므로 다른 하역지점을 지정할 수 없습니다.');
							
							for(var j=0; j<datalist.length; j++){
								if(datalist[j].get('DELIPOT') != ''){
									if($('#DELIPOT option:checked').text().substr(3) != datalist[j].get('DELIPOT')){
										gridList.setRowCheck('gridList', j, false);
									}	
								}
							}
							document.getElementById('DELIPOT').selectedIndex = 0;
							list = gridList.getSelectData('gridList');
							
							if(list.length >= 1){
								let condi = "AND (SCH020.WERKS,SCH020.WRK_ORDR_NO,SCH020.WRK_ORDR_SEQNO) IN ("
								for(let i = 0; i < list.length; i++){
									condi += "(\'" + list[i].get("WERKS") + "\',\'" + list[i].get("WRK_ORDR_NO") + "\',\'" + list[i].get("WRK_ORDR_SEQNO") + "\'),"
								}
								condi = condi.slice(0, -1)
								condi += ")"
								
								const param = inputList.setRangeParam("searchArea");
								param.put("P_TYPE", "SUB_LIST");
								param.put("OUT_SQL", condi);
								
								gridList.gridList({
									id : "gridListSub",
									param : param
								});
							}else{
								searchList();
							}
						}
					}
				}
			}
		}
		delipotflag = false;
	} */
	
	// 저장(불출요청)
	function saveData(){
		var json = netUtil.sendData({
    		module : 'mes',
    		command : 'SYSTEMCHECK',
    		sendType : 'map'
    	});
    	
    	if(json.data.USE_YN == 'Y'){
    		alert('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.');
    		return;
    	}
    	
		const gridId = "gridListSub"
		// VALIDATION
		var list = gridList.getSelectData(gridId);
		if(list.length === 0){
			alert("선택된 자재정보가 없습니다.")
			return
		}
		
		for(var i = 0; i < list.length; i++){
			const index = parseInt(list[i].get("GRowNum"))
			/*
			// 예외생산이 아니고 저장위치가 반제품(2000)인 경우
			if(list[i].get("STOR_LOC_NM") == "반제품" && list[i].get("WRK_ORDR_NO").substr(2,2) !== "EX"){
				alert((index + 1)+"번째 반제품은 불출요청이 불가능합니다.")
				gridList.setRowFocus(gridId, index)
				return;
			}
			// 요청수량 : 0 VALIDATION
			if(list[i].get("REQ_QTY") == 0){
				alert((index + 1)+"번째 품목의 요청수량이 0입니다. \n요청수량을 입력하세요.")
				gridList.setRowFocus(gridId, index)
				return
			// MES저장위치(STOR_LOC_CD) == WMS저장위치(LGFSB)
			}else if(list[i].get("STOR_LOC_CD") == list[i].get("LGFSB")){
				alert((index + 1)+"번째 품목의 WMS저장위치와 MES저장위치가 동일합니다. \n 반제품인 경우에는 불출요청을 진행할 수 없습니다.")
				gridList.setRowFocus(gridId, index)
				return
			// WMS저장위치 존재 X
			}else if(list[i].get("LGFSB") == " "){
				alert((index + 1)+"번째 품목의 WMS저장위치가 존재하지 않습니다.")
				gridList.setRowFocus(gridId, index)
				return
			}
			*/
			
			// 유효성 검사
			// 2022-08-25(목요일) 안상현, 요청수량 0
			if(list[i].get("REQ_QTY") == 0){
				alert((index + 1)+"번째 품목의 요청수량이 0입니다. \n요청수량을 입력하세요.")
				gridList.setRowFocus(gridId, index)
				return
			}
			
			// 2022-08-25(목요일) 안상현, 완제품,상품만 불출 가능
			/* 
			if(list[i].get("MATNR_DIV") !== "FERT" && list[i].get("MATNR_DIV") !== "HAWA"){
				alert("불출요청은 완제품, 상품만 가능합니다. \n\n"+(index + 1)+"번째 자재는 불출요청이 불가능합니다.")
				gridList.setRowFocus(gridId, index)
				return;
			}
			*/
		}
		
		var head = gridList.getSelectData('gridList');
		
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		}
		
		if(gridList.validationCheck("gridListSub", "all")){
			var param = inputList.setRangeParam("searchArea");
			
			param.put("P_TYPE","SAVE");
			param.put('head', head);
			param.put("list", list);
			//param.put('DELIPOT', $('#DELIPOT').val());
			
			netUtil.send({
				url : "/mes/Inv/INV01/json/datalist.data",
				param : param,
				successFunction : 'saveSuccessCallBack'
			});
		}
	}
	
	function saveSuccessCallBack(json){
		if(json.P_SUCCESS == "N"){
			alert(json.MSG);
		}else{
			// 문서번호를 restful api를 활용하여 wms에 send
			//InterfaceSendDoc(json.data);
			//20220721 여한진 문서번호 변수 수정
			InterfaceSendDoc(json.DOC_NO);
			gridList.resetGrid("gridListSub")
			searchList();
		}
	}
	
	const InterfaceSendDoc = (DOC_NO) => {
		// 헤더(HEADER) 부분의 포커스 행의 플랜트코드 데이터3
		const werks = gridList.getColData("gridList", gridList.getFocusRowNum("gridList"), "WERKS")
		
		let ifid = "MES_IF_201"
		
		//const data = datas[0]
		
		var docno = DOC_NO.split(',');
		var message = '';
		
		//20220808 여한진 WMS에 불출요청 로직 수정
		for(i = 0; i < docno.length; i++){
			var json = netUtil.sendData({
				url : "/common/api/json/"+ifid+"/send.data",
				//param : "DOC_NO=" + data["DOC_NO"]
				param : "DOC_NO=" + docno[i]
			});
			
			if(json){
				if(json.result === "SUCCESS"){
					//alert("발송 성공");
				}else {
					//alert(json.result)
					message = '(WMS) ' + (i + 1) + '번째 불출요청했을 때의 오류는 ' + json.result + '\n' + message;
				}
			}
		}
		if(message == ''){
			alert("불출요청성공했습니다.");
		}else{
			alert(message);
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
					<input type="button" id="button-0-2" CB="Save SAVE BTN_PROVIDE" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" id="WERKS" name="WERKS" onkeyup="reloadCombo()" UIInput="S,PLANT" UIFormat="U" validate="required"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PRD_REQ_DT">생산요청일자</dt>
						<dd>
							<input type="text" class="input" name="PRD_REQ_DT" UIInput="B" UIFormat="C M1"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MACHINE">생산호기</dt>
						<dd>
							<select class="input" id="MACHINE" name="MACHINE" Combo="Produce,MACHINE" onclick='procCdcheck();'>
								<option value="">All</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<input type="text" name="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					
					<dl>
						<dt CL="STD_PROC_CD">공정코드</dt>
						<dd>
							<input type="text" class="input" id="PROC_CD" name="PROC_CD" UIInput="S,OP" UIFormat="U" onkeyup="reloadCombo()"/>
						</dd>
					</dl>
					
					<dl>
						<dt>지시구분</dt>
						<dd>
							<select class="input" name="INOUT_GU">
								<option value="">All</option>
								<option value="N">정규</option>
								<option value="E">예외</option>
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
					<li><a href="#tab1-1" CL="STD_LIST"><span>일반</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_b">
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="40" GCol="rowCheck"></td>
										<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="150" GCol="text,WRK_ORDR_NO" style="text-align: center;">작업지시번호</td>
										<td GH="100" GCol="text,WRK_SEQNO" GF="N 10">작업순서</td>
										<td GH="100" GCol="text,ORDER_NO">오더번호</td>
										<td GH="100" GCol="text,ORDER_SEQNO" GF="N 10">오더순번</td>
<!-- 									2022-08-17(수요일) 안상현, 작업지시번호 -> 작업순서로 수정	<td GH="100" GCol="text,WRK_ORDR_SEQNO" style="text-align:center;">지시순번</td> -->
										<td GH="100" GCol="text,WRK_ORDR_QTY" GF="N 10,3">지시량</td>
										<td GH="100" GCol="text,MACHINE" style="text-align:center;">생산호기</td>
										<td GH="100" GCol="text,PRD_REQ_DT" GF="C" style="text-align:center;">생산요청일</td>
										<td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH="320" GCol="text,MATNR_NM">자재명</td>
										<td GH="100" GCol="text,FQTY" GF="N 10,3">오더량</td>
										<td GH="100" GCol="text,UNIT">단위</td>
										<td GH="250" GCol="text,WRK_ORDR_REMARK">작업지시비고</td>
										<td GH="150" GCol="text,REGDATE">등록일시</td>
										<td GH="100" GCol="text,REGNM">등록자</td>
										<td GH="150" GCol="text,UPDDATE">수정일시</td>
										<td GH="100" GCol="text,UPDNM">수정자</td>					
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
			<div class="content_layout tabs bottom_layout">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span>일반</span></a></li>
					<!-- <dt></dt>
					<li id='li_DELIPOT' style='display:none;'>
						<dt CL='STD_DELIPOT' style='margin-top:2px;'>하역지점</dt>
						<dd style='margin-top:2px;' onclick='delipotCheck();'>
							<select class="input" id='DELIPOT' CommonCombo='DELIPOT'>
								<option value="">All</option>
							</select>
						</dd>
					</li> -->
					<li class="btn_zoom_wrap">
						<ul>
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-1" >
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridListSub">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="40" GCol="rowCheck"></td>
										<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="200" GCol="text,MATNR" style="text-align: center;">하위자재코드</td> 
										<td GH="300" GCol="text,MATNR_NM">자재명</td>
										<td GH="100" GCol="text,UNIT" style="text-align: center;">단위</td>
										<td GH="0" GCol="text,LGFSB" style="text-align: center;">외부저장위치코드(WMS저장위치)</td>
										<td GH="100" GCol="text,STOR_LOC_CD" style="text-align: center;">저장위치코드(MES저장위치)</td>
										<td GH="100" GCol="text,STOR_LOC_NM">저장위치명</td>
										<td GH="150" GCol="text,WMS_STCK_QTY" GF="N 10,3">WMS창고재고수량</td>
										<td GH="100" GCol="text,LOT_NO">WMS창고재고수량</td>
										<td GH="100" GCol="text,MES_STCK_QTY" GF="N 10,3">MES재고</td>
										<td GH="100" GCol="text,ORDER_BOM_QTY" GF="N 10,3">소요량</td>
										<td GH="100" GCol="input,REQ_QTY" GF="N 10,3">요청수량</td>
										<td GH="100" GCol="text,PLT_QTY" GF="N 10,3">PLT</td>
										<td GH="100" GCol="input,BOX_QTY" GF="N 10,3">BOX</td>
										<td GH="100" GCol="text,M" GF="N 10,3">M</td>
										<td GH="100" GCol="text,KG" GF="N 10,3">KG</td>
										<td GH="100" GCol="text,RL" GF="N 10,3">RL</td>
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
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>