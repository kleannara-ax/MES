<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/demo_layout.css">
<script type="text/javascript">
	var flag = 1;
	var machCd;
	var seqno;
	var message = '';
	var data;
	var chkppyn;	//생산확인여부
	var chkqcyn;	//품질확인여부
	
	$(document).ready(function(){
		gridList.setGrid({
			id : "gridList",	//화장지
	    	url : "/mes/Work/WRK05/json/datalist.data",
	    	bigdata : false
	    	//colHoldType : true,
	    	//colHold : "WERKS, MACH_CD, MACHINE, MACH_NM"
	    });
		
		gridList.setGrid({
			id : "gridList2",	//패드
	    	url : "/mes/Work/WRK05/json/datalist.data",
	    	bigdata : false
	    	//colHoldType : true,
	    	//colHold : "WERKS, MACH_CD, MACHINE, MACH_NM"
	    });
		
		gridList.setGrid({
			id : "gridList3",	//음성
	    	url : "/mes/Work/WRK05/json/datalist.data",
	    	bigdata : false
	    	//colHoldType : true,
	    	//colHold : "WERKS, MACH_CD, MACHINE, MACH_NM"
	    });
		
		$("#tab1-1").show();	//화장지
		$("#tab1-2").hide();	//패드
		$("#tab1-3").hide();	//음성
		
		$('#button-0-5').hide();	//실적등록
		$('#P200PROC').hide();
	});
	
	function searchHelpEventCloseAfter(searchCode, multyType, selectData, rowData){
		if(searchCode == "PLANT"){
			reloadCombo();
		}
	}
	
	function reloadCombo(){
		$comboObj = $("#MACHINE");
		inputList.reloadCombo($comboObj, configData.INPUT_COMBO, "Produce,MACHINE");
		
		if($('#WERKS').val().toUpperCase() == 'P200'){
			$('#P200PROC').show();
		}else{
			$('#P200PROC').hide();
		}
	}

	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "Produce,MACHINE"){
			var param = new DataMap();
			
			param.put("WERKS", $("#WERKS").val().toUpperCase());
		}
		return param;
	}
	
	//20221024 여한진 화장지 같은 경우 생산호기가 합지랑 가공이 구분이 가지 않아서 공정구분
	function procCdcheck(){
		if($('#WERKS').val().toUpperCase() == 'P200'){
			if ($('#PROC_DIV').val() == '') return alert('공정구분을 선택하세요.');
			
			$("#MACHINE").find("option").map(function(){
				//20221023 여한진 화장기 합지 또는 가공에 따라서 
				const text = $(this).text()
				
				if($('#PROC_DIV').val() == 'AA'){
					// "합지 :" 문자열을 포함하지 않을 경우
					if(text.indexOf("합지") === -1){
						$(this).hide()
					}else{
						$(this).show()
						if(text.indexOf("2호기") !== -1){
							$(this).text("[RT2]화장지 합지 2호기");
							$(this).val("RT2");
						}
					}
				}else if($('#PROC_DIV').val() == 'RA'){
					// "가공 :" 문자열을 포함하지 않을 경우
					if(text.indexOf("가공") === -1){
						$(this).hide()
					}else{
						$(this).show()
					}
				}else{
					// "예외생산 :" 문자열을 포함하지 않을 경우
					if(text.indexOf("예외생산") === -1){
						$(this).hide()
					}else{
						$(this).show()
					}
				}
			})	
		} 
	}
	
	function searchList(){
		if(validate.check("searchArea")){
			var werks = $("#WERKS").val().toUpperCase().trim();
			
			if(werks == 'P100')	return alert('PS제지는 PDA로 출고요청을 합니다.');
			
			var param = inputList.setRangeParam("searchArea");
	
			param.put("P_TYPE","LIST");
			
			var chkqcyn = param.get("CHK_QC_YN") ? undefined : "";
			var chkppyn = param.get("CHK_PP_YN") ? undefined : "";
			
			//화장지
			if(werks == "P200"){
				if(chkqcyn != ""){
					alert("화장지에서는 품질확인이 없습니다.");
					return;
				}
				
				gridList.resetGrid("gridList2");
				gridList.resetGrid("gridList3");
				
				$("#tab1-1").show();	//화장지
				$("#tab1-2").hide();	//패드
				$("#tab1-3").hide();	//음성
				$('#button-0-5').hide();	//실적등록
				
				gridList.gridList({
			    	id : "gridList",
			    	param : param
			    });
				
				flag = 1;
			} else if(werks == "P300"){
				//패드
				gridList.resetGrid("gridList");
				gridList.resetGrid("gridList3");
				
				$("#tab1-1").hide();	//화장지
				$("#tab1-2").show();	//패드
				$("#tab1-3").hide();	//음성
				$('#button-0-5').hide();	//실적등록
				
				gridList.gridList({
			    	id : "gridList2",
			    	param : param
			    });
				
				flag = 2;
			} else if(werks == "P500"){
				//음성
				if(chkppyn != ""){
					alert("기저귀에서는 생산확인이 없습니다.");
					return;
				}
				
				gridList.resetGrid("gridList");
				gridList.resetGrid("gridList2");
				
				$("#tab1-1").hide();	//화장지
				$("#tab1-2").hide();	//패드
				$("#tab1-3").show();	//음성
				$('#button-0-5').hide();	//실적등록
				
				gridList.gridList({
			    	id : "gridList3",
			    	param : param
			    });
				
				flag = 3;
			} else{
				alert("(PS)제지관리팀이 작업하는 화면이 아닙니다.");
				return;
			}
		}
	}
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if(gridId == "gridList"){
			var list = gridList.getGridData(gridId);
			
			for(var i=0; i<list.length; i++){
				if(list[i].get("MATNR").substr(-1) == "M"){
					gridList.setColValue(gridId, i,"CHK_PP_YN", "Y");
				}
				
				if(list[i].get("CHK_PP_YN") == "Y"){
					gridList.setRowReadOnly(gridId, i, true, ["CHK_PP_YN"]);
				}
			}
		} else if(gridId == "gridList2" || gridId == "gridList3"){
			var list = gridList.getGridData(gridId);
			
			for(var i=0; i<list.length; i++){
				if(list[i].get("CHK_QC_YN") == "Y"){
					gridList.setRowReadOnly(gridId, i, true, ["CHK_QC_YN"]);
				}
				if(list[i].get("MACH_CD").substr(0,3) == "SPF" || list[i].get("MACH_CD").substr(0,3) == "BPI"){
					if(list[i].get("CHK_PP_YN") == "Y"){
						gridList.setRowReadOnly(gridId, i, true, ["CHK_PP_YN"]);
					}else{
						gridList.setRowReadOnly(gridId, i, false, ["CHK_PP_YN"]);	
					}
				}else{
					gridList.setRowReadOnly(gridId, i, true, ["CHK_PP_YN"]);
				}
			}
		}
	}

	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		var werks = gridList.getColData(gridId, rowNum, 'WERKS');
		var sapyn = gridList.getColData(gridId, rowNum, 'SAP_YN');
		
		if(gridId == "gridList"){
			var rowData = gridList.getSelectData("gridList");
			
			for(var i = 0; i < rowData.length; i++){
				if(rowData[i].get("MACH_CD").substr(0,3) == "TAA"){
					if(rowData[i].get("MATNR").substr(-1) != "W" && rowData[i].get("MATNR").substr(-1) != "M"){
						alert("화장지 중 와딩티슈, 판매용 원단만 처리가능합니다.");
						gridList.setRowState(gridId, configData.GRID_ROW_STATE_READ, rowNum);
        				gridList.setRowCheck(gridId, rowNum, false); 
        				gridList.setColValue(gridId, rowNum,"CHK_PP_YN", "N");
        				return;
					}
				}
				/* if(i >= 1){
					if(rowData[i].get("MACH_CD").substr(0,3) != rowData[i-1].get("MACH_CD").substr(0,3)){
						alert("서로 다른 설비를 처리할 수 없습니다.");
						gridList.setRowState(gridId, configData.GRID_ROW_STATE_READ, rowNum);
        				gridList.setRowCheck(gridId, rowNum, false);
        				gridList.setColValue(gridId, rowNum,"CHK_PP_YN", "N");
					}
				} */
				machCd = rowData[i].get("MACH_CD").substr(0,3);
			}
			if(sapyn == '전송오류'){
				alert("SAP에 실적을 전송하는데 오류가 나서 합지기 생산현황 화면에서 다시 실적 재전송하시기 바랍니다.");
				gridList.setColValue(gridId, rowNum, "CHK_PP_YN", "N");
				return;
			}
		}
		if(gridId == "gridList2" || gridId == "gridList3"){
			if(flag == 2){
				var rowData = gridList.getSelectData("gridList2");
			}else{
				var rowData = gridList.getSelectData("gridList3");
			}
			
			for(var i = 0; i < rowData.length; i++){
				if(i >= 1){
	    			if(rowData[i].get("MACH_CD").substr(0,3) != rowData[i-1].get("MACH_CD").substr(0,3)){
	    				alert("예외생산과 일반생산을 같이 처리할 수 없습니다.");
	    				gridList.setRowState(gridId, configData.GRID_ROW_STATE_READ, rowNum);
        				gridList.setRowCheck(gridId, rowNum, false);
        				gridList.setColValue(gridId, rowNum,"CHK_QC_YN", "N");
        				return;
	    			}
				}
				machCd = rowData[i].get("MACH_CD").substr(0,3);
			}
			if(colName == 'CHK_QC_YN'){
				if(machCd != 'SPF' && machCd != 'BPI'){
					if(sapyn == '미전송'){
						alert("POP에서 SAP에 먼저 실적을 전송하시기 바랍니다.");
						gridList.setColValue(gridId, rowNum, "CHK_QC_YN", "N");
						return;
					}
				}else{
					if(sapyn == '미전송'){
						alert("SAP에 먼저 실적을 전송하시기 바랍니다.");
						gridList.setColValue(gridId, rowNum, "CHK_QC_YN", "N");
						return;
					}
				}
				if(sapyn == '전송오류'){
					alert("SAP에 실적을 전송하는데 오류가 나서 생산현황 화면에서 다시 실적 재전송하시기 바랍니다.");
					gridList.setColValue(gridId, rowNum, "CHK_QC_YN", "N");
					return;
				}
			}
			if(colName == 'CHK_PP_YN'){
				if(colValue == 'Y'){
					$("#button-0-5").show();
				}	
			}
		}
	}
	
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "CancleOrder"){
			RequestCancle();
		}else if(btnName == "InputOrder"){
			InputRequest();
		}else if(btnName == 'prfmSend'){
			prfmSend();
		}
	}
	//실적전송
	function prfmSend(){
		var json = netUtil.sendData({
    		module : 'mes',
    		command : 'SYSTEMCHECK',
    		sendType : 'map'
    	});
    	
    	if(json.data.USE_YN == 'Y'){
    		alert('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.');
    		return;
    	}
		//패드
		var rowData = gridList.getSelectData("gridList2");
 		
		if(rowData.length == 0){
			alert('선택된 항목이 없습니다.');
			return;
		}
 		
		for(var i = 0; i < rowData.length; i++){
			if(rowData[i].get("CHK_PP_YN") != "Y"){
				alert("생산확인이 필요합니다.");
				return;
			}
			if(rowData[i].get('CHK_QC_YN') == 'Y'){
				alert('품질확인은 생산 확인 후 처리하시기 바랍니다.');
				return;
			}
		}
		
		var param = new DataMap();
		
		param.put("P_TYPE", "SAVE");
		param.put("list", rowData);
		
		if(!commonUtil.msgConfirm("생산확인하시겠습니까?")){
			return;
		}	
		
		netUtil.send({
			url : "/mes/Work/WRK05/json/datalist.data",
			param : param,
			successFunction : "saveSuccessCallBack3"
		});
	}
	
	function saveSuccessCallBack3(json){
		if(json.P_SUCCESS == "Y"){
			InputRequest2(json);
		}else{
			alert(json.ERR_MSG);
		}
	}
	
	function InputRequest2(json){
		//생리대 예외생산
		var param = new DataMap();
		//화장지 가공
		/* if(machCd == "TRA"){
			param.put("IFID", "MES_IF_124");
		}else if(machCd == "SRB" || machCd == "BRC"){
			//생리대, 기저귀
    		param.put("IFID", "MES_IF_133");
    	}else if(machCd == "SPF" || machCd == "BPI"){
    		//생리대 예외생산, 기저귀 예외생산
    		param.put("IFID", "MES_IF_141");
    	} */
    	
    	var docno = json.DOC_NO2.split(',');
    	
    	for(var i = 0; i < docno.length; i++){
    		if(docno[i] != ''){
    			param.put("IFID", "MES_IF_141");
            	param.put("DOC_NO", docno[i]);
            	
           		var json2 = netUtil.sendData({
                   	url : "/mes/erpif/json/sendIF.data",
                   	param : param
                });
              		
           		if(json2){
           			if(json2.data == "SUCCESS"){
                    }else{
                   		message = '(SAP 생산실적) ' + (i + 1) + "번째 " + json2.data +'\n' + message;
                    }
           		}
    		}
    	}
   		if(message == ''){
    		alert("생산확인되었습니다.");
    	}else{
    		alert(message);
    		message = '';
    	}
   		searchList();
	}
	
	//입고요청
 	function InputRequest(){
 		var json = netUtil.sendData({
    		module : 'mes',
    		command : 'SYSTEMCHECK',
    		sendType : 'map'
    	});
    	
    	if(json.data.USE_YN == 'Y'){
    		alert('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.');
    		return;
    	}
		
 		if(flag == 1){
 			//화장지
 			var rowData = gridList.getSelectData("gridList");
 		} else if(flag == 2){
 			//패드
 			var rowData = gridList.getSelectData("gridList2");
 		} else {
 			//음성
 			var rowData = gridList.getSelectData("gridList3");
 		}
 		
 		if(rowData.length == 0){
 			alert('처리하려는 항목을 선택하세요.');
 			return;
 		}
 		
 		data = rowData;
 		
		for(var i = 0; i < rowData.length; i++){
			if(rowData[i].get("CHK_PP_YN") == "Y"){
				if(flag == 2){
					// 패드
					if(rowData[i].get("CHK_QC_YN") == "N"){
						alert("품질 확인이 완료되지 않았습니다.");
						return;
					}
					if(rowData[i].get('WMS_YN') == '요청')	return alert("이미 WMS에 요청이 되어 있는 상태입니다.");
				}
			}else if(rowData[i].get("CHK_PP_YN") == "N"){
				if(flag == 1 || flag == 2){
					alert("생산 확인이 완료되지 않았습니다.");
					return;
				}
			}else {
				if(flag != 3){
					alert("생산확인이 필요합니다.");
					return;
				}
			}
		}
		
		var param = new DataMap();
		
		param.put("P_TYPE", "SAVE");
   		param.put("list", data);
		
		if(!commonUtil.msgConfirm("입고요청하시겠습니까?")){
			return;
		}
		
		netUtil.send({
			url : "/mes/Work/WRK05_1/json/datalist.data",
			param : param,
			successFunction : "saveSuccessCallBack"
		});
	}
 	
	function saveSuccessCallBack(json){
		if(json){
			if(json.P_SUCCESS == "Y"){
   				//완제품 출고(WMS)
   				InterfaceSendDoc(json.DOC_NO1);
   			}else{
   				alert(json.ERR_MSG);
   			}
		}
	}
	
 	function InterfaceSendDoc(DOCNO){
		var ifid = "MES_IF_402";
		
		var docno = DOCNO.split(',');
		
		for(var i = 0; i < docno.length; i++){
			if(docno[i] != ''){
				var json = netUtil.sendData({
					url : "/common/api/json/"+ifid+"/send.data",
					param : 'DOC_NO=' + docno[i]
					//async : false
				});
				
				if(json){
					if(json.result == 'SUCCESS'){
						//alert("입고요청되었습니다.");
						//searchList();
					}else {
						message ='(WMS 완제품 출고 요청) ' + (i + 1) + '번째 ' + json.result + '\n' + message;
					}
				}	
			}
		}
		if(message == ''){
			alert("입고요청되었습니다.");
		}else{
			alert(message);
			message = '';
		}
		searchList();
	}
 	
 	// 요청취소
	function RequestCancle(){
		var json = netUtil.sendData({
    		module : 'mes',
    		command : 'SYSTEMCHECK',
    		sendType : 'map'
    	});
    	
    	if(json.data.USE_YN == 'Y'){
    		alert('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.');
    		return;
    	}
 		
		if(flag == 1){
 			//화장지
 			var rowData = gridList.getSelectData("gridList");
 		} else if(flag == 2){
 			//패드
 			var rowData = gridList.getSelectData("gridList2");
 		} else {
 			//음성
 			var rowData = gridList.getSelectData("gridList3");
 		}
		
		if(rowData.length == 0){
			alert("선택된 데이터가 없습니다.");
			return;	
		} 
		
		for(var i = 0; i < rowData.length; i++){
			if(rowData[i].get("CHK_PP_YN") == "Y"){
				if (flag == 2){
					// 패드
					if(rowData[i].get("CHK_QC_YN") == "N"){
						alert("품질 확인이 완료되지 않았습니다.");
						return;
					}else if(rowData[i].get("CHK_QC_YN").trim() == ""){
						alert("품질확인이 필요합니다.");
						return;
					}
				}
			}else if(rowData[i].get("CHK_PP_YN") == "N"){
				alert("생산 확인이 완료되지 않았습니다.");
				return;
			}else {
				if(flag != 3){
					alert("생산확인이 필요합니다.");
					return;
				}
			}	
		}
		
		if(!commonUtil.msgConfirm("입고요청을 취소하시겠습니까?")){
			return;
		}
		
		var param = new DataMap();
		
		param.put("P_TYPE", "DELETE");
		param.put("list", rowData);
		
		netUtil.send({
			url : "/mes/Work/WRK05_1/json/datalist.data",
			param : param,
			successFunction : "saveSuccessCallBack2"
		});
	}
	
	function saveSuccessCallBack2(json){
 		if(json){
 			if(json.P_SUCCESS == 'Y'){
 				//완제품 출고(WMS)
 				InterfaceSendDoc2(json.DOC_NO1)
 			}else{
 				alert(json.ERR_MSG);
 				//searchList();
 			}
 		}
 	}
	 
	
	function InterfaceSendDoc2(DOCNO){
		var ifid = "MES_IF_402";
		
		var docno = DOCNO.split(',');
		
		for(var i = 0; i < docno.length; i++){
			if(docno[i] != ''){
				var json = netUtil.sendData({
					url : "/common/api/json/"+ifid+"/send.data",
					param : 'DOC_NO=' + docno[i]
				});
				
				if(json){
					if(json.result == 'SUCCESS'){
						//alert("입고요청되었습니다.");
						//searchList();
					}else {
						message = '(WMS 완제품 출고 요청 취소) '+ message + (i + 1) + '번째 오류는 ' + json.result + '\n';
					}
				}
			}
		}
		if(message == ''){
			alert("입고요청 취소되었습니다.");
		}else{
			alert(message);
			message = '';
		}
		searchList();
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
					<input type='button' id='button-0-5' CB='prfmSend SAVE 실적전송'/>
					<input type="button" id="button-0-3" CB="InputOrder SAVE BTN_INPUTORDER" /> <!-- 입고요청 -->					
					<input type="button" id="button-0-4" CB="CancleOrder DELETE BTN_CANCLEORDER" /> <!-- 요청취소 -->
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" id="WERKS" name="WERKS" UIInput="S,PLANT" UIFormat="U" validate="required" onkeyup="reloadCombo()"/>
						</dd>
					</dl>
					<dl id='P200PROC'>
						<dt CL="STD_PROC_DIV">공정구분</dt>
						<dd>
							<select class="input" id="PROC_DIV" name='PROC_DIV' CommonCombo='P200PROC'>
								<option value=''>All</option>
							</select>
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
							<input type="text" class="input" name="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_CHK_PP_YN">생산확인</dt>
						<dd>
							<select class="input" name="CHK_PP_YN" CommonCombo="CHKPPYN">
								<option value="">All</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_CHK_QC_YN">품질확인</dt>
						<dd>
							<select class="input" name="CHK_QC_YN" CommonCombo="CHKPPYN">
								<option value="">All</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PRFM_DT">실적일자</dt>
						<dd>
							<input type="text" class="input" id="PRFM_DT" name="W001.PRFM_DT" UIInput="B" UIFormat="C M1"/>
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
					<li><a href="#tab1-1"><span>제품 입고대기창고 재고</span></a></li>
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
										<td GH="40" GCol="rownum">1</td>	
										<td GH="40" GCol="rowCheck"></td>
										<td GH="100" GCol="text,WERKS"  style="text-align:center;"></td>		<!-- 플랜트 -->
										<td GH="0" GCol="text,MACH_CD" style="text-align:center;">섧비코드</td>
										<td GH="100" GCol="text,MACHINE" style="text-align:center;">생산호기</td>
										<td GH="140" GCol="text,MACH_NM"></td>	
										<td GH="100" GCol="text,PRD_DT" style="text-align:center;" GF="D"></td>			<!-- 생산일자 -->
										<td GH="100" GCol="text,PRFM_DT" style="text-align:center;" GF="D"></td>		<!-- 실적일자 -->
										<td GH="140" GCol="text,MATNR" style="text-align:center;"></td>		<!-- 자재코드 -->
										<td GH="320" GCol="text,MATNR_NM"></td>		<!-- 자재명 -->		
										<td GH="120" GCol="text,IND_BCD"></td>		<!-- 개별바코드 -->	
										<td GH="100" Gcol="text,LOT_NO">LOT_NO</td>
										<td GH="100" GCol="text,UNIT" style="text-align:center;"></td>		<!-- 단위 -->	
										<td GH="100" GCol="text,PLT_QTY" GF="N 13,1"></td>		<!-- PLT -->										
										<td GH="100" GCol="text,BOX_QTY" GF="N 13"></td>		<!-- BOX -->										
										<td GH="100" GCol="text,BAG_QTY" GF="N 13"></td>		<!-- BAG -->
										<td GH="100" GCol="text,EA_QTY" GF="N 13"></td>		<!-- EA -->
										<td GH="100" GCol="text,WGT" GF="N 13,3"></td>		<!-- 중량 -->	
										<td GH="100" GCol="text,ROLLCNT" GF="N 6"></td>		<!-- 권치수 -->		
										<td GH="100" GCol="select,CHK_PP_YN">
											<select CommonCombo="CHKPPYN">          <!-- 생산확인여부 -->
												<option value=""> </option>
											</select>
										</td>
										<td GH="100" GCol="text,SAP_YN">SAP전송여부</td>	
										<td GH="100" GCol="text,WMS_YN">WMS전송여부</td>	
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
				<div class="table_box section" id="tab1-2">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridList2">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>	
										<td GH="40" GCol="rowCheck"></td>
										<td GH="100" GCol="text,WERKS"  style="text-align:center;"></td>		<!-- 플랜트 -->
										<td GH="0" GCol="text,MACH_CD" style="text-align:center;"></td>
										<td GH="100" GCol="text,MACHINE" style="text-align:center;">생산호기</td>
										<td GH="140" GCol="text,MACH_NM"></td>	
										<td GH="100" GCol="text,PRD_DT" style="text-align:center;" GF="D"></td>			<!-- 생산일자 -->
										<td GH="100" GCol="text,PRFM_DT" style="text-align:center;" GF="D"></td>		<!-- 실적일자 -->
										<td GH="140" GCol="text,MATNR" style="text-align:center;"></td>		<!-- 자재코드 -->
										<td GH="320" GCol="text,MATNR_NM"></td>		<!-- 자재명 -->		
										<td GH="120" GCol="text,IND_BCD"></td>		<!-- 개별바코드 -->	
										<td GH="100" Gcol="text,LOT_NO">LOT_NO</td>
										<td GH="100" GCol="text,UNIT" style="text-align:center;"></td>		<!-- 단위 -->	
										<td GH="100" GCol="text,PLT_QTY" GF="N 13,1"></td>		<!-- PLT -->										
										<td GH="100" GCol="text,BOX_QTY" GF="N 13"></td>		<!-- BOX -->										
										<td GH="100" GCol="text,BAG_QTY" GF="N 13"></td>		<!-- BAG -->
										<td GH="100" GCol="text,EA_QTY" GF="N 13"></td>		<!-- EA -->	
										<td GH="100" GCol="select,CHK_PP_YN">
											<select CommonCombo="CHKPPYN">          <!-- 생산확인여부 -->
												<option value=""> </option>
											</select>
										</td>
										<td GH="100" GCol="select,CHK_QC_YN">	
											<select CommonCombo="CHKPPYN">          <!-- 품질확인여부 -->
												<option value=""> </option>
											</select>
										</td>
										<td GH="100" GCol="text,SAP_YN">SAP전송여부</td>	
										<td GH="100" GCol="text,WMS_YN">WMS전송여부</td>	
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="2" />
						<jsp:param name="showAuthCd" value="1,2,3,7,9,10" />
					</jsp:include>
				</div>
				<div class="table_box section" id="tab1-3">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridList3">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>	
										<td GH="40" GCol="rowCheck"></td>
										<td GH="100" GCol="text,WERKS"  style="text-align:center;"></td>		<!-- 플랜트 -->
										<td GH="0" GCol="text,MACH_CD" style="text-align:center;"></td>
										<td GH="100" GCol="text,MACHINE" style="text-align:center;">생산호기</td>
										<td GH="140" GCol="text,MACH_NM"></td>	
										<td GH="100" GCol="text,PRD_DT" style="text-align:center;" GF="D"></td>			<!-- 생산일자 -->
										<td GH="100" GCol="text,PRFM_DT" style="text-align:center;" GF="D"></td>		<!-- 실적일자 -->
										<td GH="140" GCol="text,MATNR" style="text-align:center;"></td>		<!-- 자재코드 -->
										<td GH="320" GCol="text,MATNR_NM"></td>		<!-- 자재명 -->		
										<td GH="120" GCol="text,IND_BCD"></td>		<!-- 개별바코드 -->	
										<td GH="100" Gcol="text,LOT_NO">LOT_NO</td>
										<td GH="100" GCol="text,UNIT" style="text-align:center;"></td>		<!-- 단위 -->	
										<td GH="100" GCol="text,PLT_QTY" GF="N 13,1"></td>		<!-- PLT -->										
										<td GH="100" GCol="text,BOX_QTY" GF="N 13"></td>		<!-- BOX -->										
										<td GH="100" GCol="text,BAG_QTY" GF="N 13"></td>		<!-- BAG -->
										<td GH="100" GCol="text,EA_QTY" GF="N 13"></td>		<!-- EA -->	
										<td GH="100" GCol="select,CHK_QC_YN">	
											<select CommonCombo="CHKPPYN">          <!-- 품질확인여부 -->
												<option value=""> </option>
											</select>
										</td>
										<td GH="100" GCol="text,SAP_YN">SAP전송여부</td>	
										<td GH="100" GCol="text,WMS_YN">WMS전송여부</td>	
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="3" />
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