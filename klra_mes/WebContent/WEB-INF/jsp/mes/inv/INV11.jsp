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
	var allchk = false;
	
	$(document).ready(function(){	
		gridList.setGrid({
			id : "gridList",
			url:"/mes/Inv/INV11/json/datalist.data",
			bigdata : false,
	    	pkcol :"WERKS",
	    	colHoldType : true,
	    	colHold : "WERKS,WRK_ORDR_NO,WRK_ORDR_SEQNO",
	    	colorType : true,
	    	colGroupCols : 'WRK_ORDR_NO,ORDER_NO',
	    	firstRowFocusType : false
		})
		
		gridList.setGrid({
			id : "gridListSub",
			url:"/mes/Inv/INV11/json/datalist.data",
			bigdata : false,
	    	pkcol :"WERKS",
	    	colHoldType : true,
	    	colHold : "WERKS, ORDER_NO, MATNR, MATNR_NM",
	    	colGroupCols : 'ORDER_NO',
	    	firstRowFocusType : false
		})
		
		$('#li_DELIPOT').hide();
		$('#WERKS').val('P100');
		document.getElementById('INOUT_GU').selectedIndex = 2;
	});
	
	// 전체 checkbox 선택
	const gridListEventRowCheckAll = (gridId, checkType) => {
		allchk = true;
		f(gridId, allchk)
	}
	
	// 행 개별 checkbox 선택
	const gridListEventRowCheck = (gridId, rowNum, checkType) => {
		allchk = false;
		f(gridId, allchk)
	}
	
	// 체크박스 선택에 따른 함수
	const f = (gridId, allchk) => {
		if(gridId === "gridList"){
			const data = gridList.getSelectData(gridId)
			var list = gridList.getGridData(gridId);
			var wrkordrno = new Array();	//예외작업지시구분
			var orderno = new Array();	//오더번호
			var procCd1 = 'JA';		//점보롤
			var procCd2 = 'MA';		//밀롤
			var procCd3 = 'CA';		//재단
			var procCd4 = 'PA';		//포장
			
			for(var i = 0; i < data.length; i++){
				if(data[i].get("WRK_ORDR_QTY") == " "){
					alert("지시량이 없습니다.");
					return;
				}
				wrkordrno.push(data[i].get('WRK_ORDR_NO').substr(2,2));
				orderno.push(data[i].get('ORDER_NO'));
			}
			
			if(wrkordrno != ''){
				if(wrkordrno.indexOf(procCd1) >= 0 || wrkordrno.indexOf(procCd2) >= 0 || wrkordrno.indexOf(procCd3) >= 0 || wrkordrno.indexOf(procCd4) >= 0){
					$('#li_DELIPOT').hide();
				}else{
					$('#li_DELIPOT').show();
				}
			}else{
				$('#li_DELIPOT').hide();
			}
			
			gridList.resetGridReadOnly(gridId);
			gridList.reloadAll();
			
			if(data.length >= 1){
				let condi = "AND (SCH020.ORDER_NO) IN ("
				for(let i = 0; i < orderno.length; i++){
					condi += "(\'" + orderno[i] + "\'),"
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
				gridList.resetGridReadOnly(gridId);
				//gridList.reloadAll('gridListSub');
				gridList.resetGrid("gridListSub");
			}
			
			if(allchk == false){
				for(var i = 0; i < orderno.length; i++){
					for(var j = 0; j < list.length; j++){
						if(list[j].get('ORDER_NO') == orderno[i]){
							if(gridList.getSelectType(gridId, j) != true){
								gridList.setRowReadOnly(gridId, j, true);
							}
						}
					}
				}
			}
		}/* else{	//gridId = 'gridListSub'
			const data = gridList.getGridData(gridId);
			for(var i=0; i<data.length; i++){
				if(gridList.getSelectType(gridId, i) != true){
					if(data[i].get('REQ_QTY').trim() != ''){
						gridList.setColValue(gridId, i, 'REQ_QTY', '');
						gridList.setRowState(gridId, configData.GRID_ROW_STATE_READ, i);
						gridList.reloadAll(gridId);
					}
				}
			}
		} */
	}

	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "Produce,MACHINE"){
			var param = new DataMap();
			
			param.put("WERKS", 'P100');
		}
		return param;
	}
	
	// 조회
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			
			param.put("P_TYPE", "LIST");
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
			
			$('#li_DELIPOT').hide();
			document.getElementById('DELIPOT').selectedIndex = 0;
		}
		gridList.resetGrid("gridListSub");
	}
	
	function gridListRowColorChange(gridId, rowNum, rowData){
		if(gridId === "gridList" && rowData.get("DELIPOT").trim() != ""){
			return configData.GRID_COLOR_BG_GRAY_CLASS;
		}
 	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId == "gridListSub"){
			if(colName == "REQ_QTY"){
				var matnr = gridList.getColData(gridId, rowNum, "MATNR");
				var unit = gridList.getColData(gridId, rowNum, 'UNIT')
				var param = new DataMap();
				
				param.put('PROC_DIV', 'PS');
				param.put("MATNR", matnr);
				
				var json = netUtil.sendData({
					module : "Inv",
					command : "UNITCONVERSION",
					sendType : "list",
					param : param
				});
				
				if(json.data.length > 0){
					for(var i = 0; i < json.data.length; i++){
						var unitConversion = (colValue * 500) * (json.data[i].BS_WGT / 1000) * (json.data[i].WLEN / 1000) * (json.data[i].VLEN / 1000);

						if(unit == "R"){
							gridList.setColValue(gridId, rowNum, "KG", unitConversion);
						}else{
							gridList.setColValue(gridId, rowNum, "KG", colValue);
						}
					}
				}
			}
		}
	}
	
	/* function gridListEventDataBindEnd(gridId, dataLength){
		if(gridId == 'gridListSub'){
			var list = gridList.getGridData('gridListSub');
			
			for(var i=0; i<dataLength; i++){
				if(Number(list[i].get('WMS_STCK_QTY')) > 0){
					var qty = Number(list[i].get('ORDER_BOM_QTY')) - Number(list[i].get('MES_STCK_QTY'));
					
					if(qty > 0){
						gridList.setRowCheck(gridId, i, true);
						gridList.setColValue(gridId, i, 'REQ_QTY', qty);
					}
				}
			}
		}
	} */
	
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
	function delipotCheck(){
		var list = gridList.getSelectData('gridList');
		var datalist = gridList.getGridData('gridList');
		
		for(var i=0; i<list.length; i++){
			if(list[i].get('WERKS') == 'P100'){
				if(list[i].get('DELIPOT').trim() != ''){
					if($('#DELIPOT').val() != ''){
						if(list[i].get('DELIPOT').trim() != $('#DELIPOT option:checked').text().substr(3)){							
							alert('선택한 항목 중 ' + (i + 1) +'번째의 ' + list[i].get('WRK_ORDR_NO') + ' 작업지시는 \n' + list[i].get('DELIPOT') + ' 하역지점이 지정되어 있으므로 다른 하역지점을 지정할 수 없습니다.');
							
							for(var j=0; j<datalist.length; j++){
								if(datalist[j].get('DELIPOT') != ''){
									if(datalist[j].get('WRK_ORDR_NO') == list[i].get('WRK_ORDR_NO')){
										if($('#DELIPOT option:checked').text().substr(3) != datalist[j].get('DELIPOT')){
											gridList.setRowCheck('gridList', j, false);
										}	
									}
								}
							}
							document.getElementById('DELIPOT').selectedIndex = 0;
						}
					}
				}
			}
		}
	}
	
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
    	
		if($('#DELIPOT').val() == '')	return alert('하역지점을 선택하세요.');
    	
		const gridId = "gridListSub"
		
		// VALIDATION
		var list = gridList.getSelectData(gridId);
		if(list.length === 0){
			alert("선택된 자재정보가 없습니다.")
			return
		}
		
		for(var i = 0; i < list.length; i++){
			const index = parseInt(list[i].get("GRowNum"))
			
			// 유효성 검사
			// 2022-08-25(목요일) 안상현, 요청수량 0
			if(list[i].get("REQ_QTY") == 0){
				alert((index + 1)+"번째 품목의 요청수량이 0입니다. \n요청수량을 입력하세요.")
				gridList.setRowFocus(gridId, index)
				return
			}
		}
		
		var head = gridList.getSelectData('gridList');
		
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		}
		
		if(gridList.validationCheck("gridListSub", "all")){
			var param = inputList.setRangeParam("searchArea");
			
			param.put("P_TYPE", "SAVE");
			param.put('head', head);
			param.put("list", list);
			param.put('DELIPOT', $('#DELIPOT').val());
			
			netUtil.send({
				url : "/mes/Inv/INV11/json/datalist.data",
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
		
		const anList = gridList.getSelectData("gridListSub")
		
		//20220808 여한진 WMS에 불출요청 로직 수정
		for(i = 0; i < docno.length; i++){
			var json = netUtil.sendData({
				url : "/common/api/json/"+ifid+"/send.data",
				param : "DOC_NO=" + docno[i]
			});
			
			if(json.result === "SUCCESS"){
				// 2023-02-21(화요일) 안상현, 불출요청 롤백 로직 수정
				const obj = new DataMap()
				obj.put("P_TYPE", "COMPLETE")
				obj.put("head", gridList.getSelectData("gridList")) // HEAD GRID 데이터
				obj.put("DELIPOT", $("#DELIPOT").val()) // 하역지점
				obj.put("DOC_NO", docno[i]) // MES문서번호
				obj.put("WERKS", gridList.getColData("gridListSub", anList[i].get("GRowNum"), "WERKS")) // 플랜트
				obj.put("LOT_NO", gridList.getColData("gridListSub", anList[i].get("GRowNum"), "LOT_NO")) // LOT번호
				
				netUtil.send({
					url : "/mes/Inv/INV11_RB/json/datalist.data",
					param : obj
				});
				
			}else {
				message = '(WMS) ' + (i + 1) + '번째 불출요청했을 때의 오류는 ' + json.result + '\n' + message;
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
							<input type="text" class="input" id="WERKS" name="WERKS" readonly="readonly"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PRD_REQ_DT">생산요청일자</dt>
						<dd>
							<input type="text" class="input" name="PRD_REQ_DT" UIInput="B" UIFormat="C M1"/>
						</dd>
					</dl>
					<!-- 20230214 여한진 예외일 경우 생산호기가 없으므로 주석처리 -->
					<!-- <dl>
						<dt CL="STD_MACHINE">생산호기</dt>
						<dd>
							<select class="input" id="MACHINE" name="MACHINE" Combo="Produce,MACHINE">
								<option value="">All</option>
							</select>
						</dd>
					</dl> -->
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<input type="text" name="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					
					<dl>
						<dt CL="STD_PROC_CD">공정코드</dt>
						<dd>
							<input type="text" class="input" id="PROC_CD" name="PROC_CD" UIInput="SR,OP" UIFormat="U"/>
						</dd>
					</dl>
					
					<dl>
						<dt>지시구분</dt>
						<dd>
							<select class="input" id='INOUT_GU' name="INOUT_GU" readonly='readonly'>
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
			<div class="content_layout tabs top_layout" style='height:53%;'>
				<ul class="tab tab_style02">
					<li><a href="#tab1-1" CL="STD_GRD_INV11_1"><span>리스트</span></a></li>
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
										<td GH="100" GCol="text,WRK_SEQNO" style="text-align: center;">작업순서</td>
										<td GH="100" GCol="text,ORDER_NO" style="text-align: center;">오더번호</td>
										<td GH="100" GCol="text,ORDER_SEQNO" style="text-align: center;">오더순번</td>
<!-- 									2022-08-17(수요일) 안상현, 작업지시번호 -> 작업순서로 수정	<td GH="100" GCol="text,WRK_ORDR_SEQNO" style="text-align:center;">지시순번</td> -->
										<td GH="100" GCol="text,WRK_ORDR_QTY" GF="N 10,3">지시량</td>
										<td GH='120' GCol='text,ORDER_DIV' style="text-align: center;">오더유형</td>
										<!-- <td GH="100" GCol="text,MACHINE" style="text-align:center;">생산호기</td> -->
										<td GH="100" GCol="text,PRD_REQ_DT" GF="C" style="text-align:center;">생산요청일</td>
										<td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH="320" GCol="text,MATNR_NM" style="text-align: center;">자재명</td>
										<!-- 20221222 여한진 하위 컬럼 3개 추가 -->
										<td GH='100' GCol='text,PRE_CHG_SPEC' style="text-align: center;">변경 전 규격</td>
										<td GH='100' GCol='text,AFTER_CHG_SPEC' style="text-align: center;">변경 후 규격</td>
										<td GH='100' GCol='text,DELIPOT' style="text-align: center;">하역지점</td>
										
										<td GH="100" GCol="text,FQTY" GF="N 10,3">오더량</td>
										<td GH="100" GCol="text,UNIT" style="text-align: center;">단위</td>
										<td GH="250" GCol="text,WRK_ORDR_REMARK">작업지시비고</td>
										<td GH="150" GCol="text,REGDATE" style="text-align: center;">등록일시</td>
										<td GH="100" GCol="text,REGNM" style="text-align: center;">등록자</td>
										<td GH="150" GCol="text,UPDDATE" style="text-align: center;">수정일시</td>
										<td GH="100" GCol="text,UPDNM" style="text-align: center;">수정자</td>					
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
			<div class="content_layout tabs bottom_layout" style='height:45%;'>
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span CL="STD_GRD_INV11_2">일반</span></a></li>
					<dt></dt>
					<li id='li_DELIPOT' style='display:none;'>
						<dt CL='STD_DELIPOT' style='margin-top:2px;'>하역지점</dt>
						<dd style='margin-top:2px;' onclick='delipotCheck();'>
							<select class="input" id='DELIPOT' CommonCombo='DELIPOT'>
								<option value="">All</option>
							</select>
						</dd>
					</li>
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
										<td GH="0" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="100" GCol="text,ORDER_NO" style="text-align: center;">오더번호</td>
										<td GH="140" GCol="text,MATNR" style="text-align: center;">하위자재코드</td> 
										<td GH="320" GCol="text,MATNR_NM" style="text-align: center;">자재명</td>
										<td GH="80" GCol="text,UNIT" style="text-align: center;">단위</td>
										<td GH="0" GCol="text,LGFSB" style="text-align: center;">외부저장위치코드(WMS저장위치)</td>
										<td GH="100" GCol="text,STOR_LOC_CD" style="text-align: center;">저장위치코드(MES저장위치)</td>
										<td GH="100" GCol="text,STOR_LOC_NM" style="text-align: center;">저장위치명</td>
										<td GH="120" GCol="text,WMS_STCK_QTY" GF="N 10,3">WMS창고재고수량</td>
										<td GH="100" GCol="text,LOT_NO"  style="text-align: center;">LOT번호</td>
										<td GH="100" GCol="text,MES_STCK_QTY" GF="N 10,3">MES재고</td>
										<td GH="100" GCol="text,ORDER_BOM_QTY" GF="N 10,3">소요량</td>
										<td GH="100" GCol="input,REQ_QTY" GF="N 10,3">요청수량</td>
										<!-- <td GH="100" GCol="text,M" GF="N 10,3">M</td> -->
										<td GH="100" GCol="text,KG" GF="N 10,3" style="text-align: center;">KG</td>
										<!-- --<td GH="100" GCol="text,RL" GF="N 10,3">RL</td> -->
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