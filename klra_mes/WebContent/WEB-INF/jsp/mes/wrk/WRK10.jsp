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
	var headlist;
	var prfmdt;
	var rownum;
	var message = '';
	/* MES 저장 및 SAP RFC 처리 중 여부 */
	var sapProcessing = false;

	/**
	 * TODO: 260904
	 * Writer: djseo
	 * SAP 처리 도중 새로고침, 뒤로가기, 탭 닫기 시
	 * Chrome 기본 페이지 이탈 경고창 표시
	 */
	window.addEventListener("beforeunload", function(e) {

		if (!sapProcessing) {
			return;
		}

		e.preventDefault();
		e.returnValue = "";
	});

	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
	    	url : "/mes/Work/WRK10/json/datalist.data",
	    	bigdata : false
	    });
		gridList.setGrid({
	    	id : "gridList2",
	    	url : "/mes/Work/WRK10/json/datalist.data",
	    	bigdata : false
	    });
		gridList.setGrid({
	    	id : "gridList3",
	    	url : "/mes/Work/WRK10/json/datalist.data",
	    	bigdata : false
	    });
		
		$("#WERKS").val('P200');
		
		$("#MACHINE").find("option").map(function(){
			//20221023 여한진 화장기 합지 또는 가공에 따라서 
			const text = $(this).text()
			
			// "가공 :" 문자열을 포함하지 않을 경우
			if(text.indexOf("가공") === -1 && text.indexOf("All") === -1){
				$(this).remove()
			}
		})	
	});

	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "Produce,MACHINE"){
			var param = new DataMap();
			
			param.put("WERKS", 'P200');
		}
		return param;
	}
	
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			
			param.put("P_TYPE","LIST1");
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
			
			prfmdt = param.get("PRFM_DT");
			
			gridList.resetGrid('gridList2');
			gridList.resetGrid('gridList3');
		}
	}
	
	function searchSubList(headRowNum){
		var head = gridList.getRowData("gridList", headRowNum);
		
		var param = new DataMap();	
			
		param.put("P_TYPE", "LIST2");
		param.put("head", head);
		
		gridList.gridList({
			id : "gridList2",
			param : param
		});
		
		param.put("P_TYPE", "LIST3");
		param.put('PRFM_DT', prfmdt);
		
		gridList.gridList({
			id : "gridList3",
			param : param
		});
		
		headlist = head;
		rownum = headRowNum;
    }
	//투입 자재 이력
	/* function searchSubList2(rowNum){
		var lotnoM = gridList.getColData('gridList3', rowNum, 'LOT_NO_M');	//투입LOTNO
		var machCd = gridList.getColData('gridList', rownum, 'MACH_CD');	//설비코드
		var wrkordrno = gridList.getColData('gridList', rownum, 'WRK_ORDR_NO');	//작업지시번호
		var wrkordrseqno = gridList.getColData('gridList', rownum, 'WRK_ORDR_SEQNO');	//작업지시순번
		
		var param = new DataMap();
		
		param.put('MACH_CD', machCd);
		param.put('LOT_NO_M', lotnoM);
		param.put('WRK_ORDR_NO', wrkordrno);
		param.put('WRK_ORDR_SEQNO',wrkordrseqno);
		//투입 자재 바코드별로 폐품처리하기 위한 팝업 호출
		page.linkPopOpen("/mes/wrk/WRK10_POP01.page", param, "height=1000,width=1000")
	} */
	
	function gridListEventRowDblclick(gridId, rowNum){
		if(gridId == "gridList"){
			searchSubList(rowNum);
		}else if(gridId == "gridList3"){
			searchSubList2(rowNum);
		}
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId == "gridList3"){
			//폐품수량
			if(colName == "SCRAP_CHG_QTY"){
				var useqty = gridList.getColData(gridId, rowNum, "USE_QTY");	//사용량
				var scrapqty = gridList.getColData(gridId, rowNum, "SCRAP_QTY");	//폐품수량

				if(Number(useqty) < Number(scrapqty)){
					gridList.setColValue(gridId, rowNum, "SCRAP_CHG_QTY", 0.000);
					gridList.setRowCheck(gridId, rowNum, false);
					gridList.setRowState(gridId, configData.GRID_ROW_STATE_READ, rowNum);
					gridList.reloadAll(gridId);
					alert('사용량이 폐품수량보다 많을 경우 폐품등록을 할 수 있습니다.');
					
				}
			}
		}
	}
	
	/* function gridListEventDataBindEnd(gridId, dataLength){
		if(gridId == 'gridList3'){
			var list = gridList.getGridData(gridId);
			
			for(var i = 0; i < dataLength; i++){
				if(list[i].get('COM_YN') == 'Y'){
					gridList.setRowReadOnly(gridId, i, true, ['COM_YN']);
				}
			}
		}
	} */
	//팝업 결과 호춣
	function linkPopCloseEvent(param){
		searchSubList(rownum);
	}
	
	function saveData() {

		/**
		 * TODO: 260904
		 * Writer: djseo
		 * 처리 중 저장 버튼을 다시 누르는 것을 방지한다.
		 **/
		if (sapProcessing) {
			alert(
					"현재 MES 저장 및 SAP 연동을 처리하고 있습니다.\n"
					+ "완료될 때까지 잠시 기다려주세요."
			);
			return;
		}

		var json = netUtil.sendData({
    		module : 'mes',
    		command : 'SYSTEMCHECK',
    		sendType : 'map'
    	});
    	
    	if(json.data.USE_YN == 'Y'){
    		alert('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.');
    		return;
    	}
		
		if (gridList.validationCheck("gridList3", "all")) {
			var list = gridList.getSelectData("gridList3")
			
			if(list.length == 0){
				alert('선택한 항목이 없습니다.');
				return;
			}
			
			/* for(var i = 0; i < list.length; i++){
				if(list[i].get('COM_YN') == 'N'){
					alert('선택한 항목 중 ' + (i + 1) + '번째 생산확인 완료로 처리하시기 바랍니다');
					return;
				}
			} */
			
			var param = new DataMap();
			
			param.put("P_TYPE","SAVE");
			param.put("head", headlist);
			param.put("list", list);
	
			// if (!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			// 	return;
			// }
			if (!confirm(
					"\n저장 후 SAP 연동 처리로\n시간이 오래 걸릴 수 있습니다.\n\n"
					+ "페이지에 응답 없다고 메시지가 나와도\n"
					+ "반드시 대기 버튼을 눌러주세요\n\n"

					+ "진행하시겠습니까?"
			)) {
				return;
			}

			/**
			 * TODO: 260721
			 * Writer: djseo
			 * 여기서부터 MES 저장 및 SAP RFC 처리가 모두 끝날 때까지
			 * 페이지 이탈 경고를 활성화한다.
			 **/
			sapProcessing = true;

			netUtil.send({
				url : "/mes/Work/WRK10/json/datalist.data",
				param : param,
				successFunction : "saveSuccessCallBack",
				failFunction : "saveFailCallBack"
			});
		}
	}

	function toNumber(value){
		var numberValue = Number(
				String(value || 0).replace(/,/g, "")
		);

		return isNaN(numberValue) ? 0 : numberValue;
	}


	function interfaceRfcDocno(DOC_NO){
		if(DOC_NO != ''){
			var param = new DataMap();

			param.put("IFID", "MES_IF_130");
			param.put("DOC_NO", DOC_NO);

			var json = netUtil.sendData({
				url : "/mes/erpif/json/sendIF.data",
				param : param
			});

			if(json.data != 'SUCCESS'){
				message = message + '(SAP 자재투입량) ' + json.data;
			}
			// 테스트용
			else{
				message = message + '(SAP 자재투입량) ' + json.data;
			}
		}
	}


	/**
	 * TODO: 260904
	 * Writer: djseo
	 * MES 저장 요청 자체가 HTTP 오류로 실패한 경우
	 **/
	function saveFailCallBack(a, b, c) {

		sapProcessing = false;

		alert(
				"MES 저장 요청 중 통신 오류가 발생했습니다.\n"
				+ "이 메시지를 확인하실 시에 즉시 MES 담당자에게\n"
				+"아래의 정보와 함께 전달해주세요.\n\n"
				+"※ 실적일자, 투입자재 LOT번호, 폐품보정량 입력값"

		);
	}

	/**
	 * TODO: 260904 마감시 RFC 실행
	 * Writer: djseo
	 * 사용량 취소 -> 사용량 등록 -> 폐품 취소 -> 폐품 등록
	 * 이래야 SAP 수량 부족 문제가 발생하지 않는다
	 **/
	function saveSuccessCallBack(json){
		try {
			if (json.P_SUCCESS == 'Y') {
				if (json.CLOSE_YN == 'Y') {
					if (json.DOC_NO3 != '') {
						var param = new DataMap();
						//SAP 자재투입량 취소
						param.put("IFID", "MES_IF_143");
						param.put("DOC_NO", json.DOC_NO3);
						var json2 = netUtil.sendData({
							url: "/mes/erpif/json/sendIF.data",
							param: param
						});

						if (json2.data == 'SUCCESS') {
							//if('SUCCESS' == 'SUCCESS'){
							//SAP 자재투입량 실적
							interfaceRfcDocno(json.DOC_NO4);
						} else {
							message = '(SAP 자재투입량 취소) ' + json2.data + '\n';
						}
					}
					// rfcDispo(json.DOC_NO1);

					if (json.DOC_NO2 != '') {
						// SAP에 폐품취소 송신
						param = new DataMap();
						param.put("IFID", "MES_IF_144");
						param.put("DOC_NO", json.DOC_NO2);

						var json2 = netUtil.sendData({
							url: "/mes/erpif/json/sendIF.data",
							param: param
						});

						if (json2 && json2.data == 'SUCCESS') {
							// 폐품취소 성공 후 SAP에 폐품등록 송신
							rfcDispo(json.DOC_NO1);

						} else {
							var sapError = json2 && json2.data
									? json2.data
									: 'SAP 통신 오류';

							var continueYn = confirm(
									'SAP 폐품취소 처리에 실패했습니다.\n\n'
									+ '오류 내용: ' + sapError + '\n\n'
									+ 'SAP에 폐품 등록을 진행하시겠습니까?'
							);

							if (continueYn) {
								// 사용자가 확인을 선택한 경우에만 폐품등록
								rfcDispo(json.DOC_NO1);
							}
						}
					} else {
						// 취소 문서가 없으면 바로 폐품등록
						rfcDispo(json.DOC_NO1);
					}
				} else {
					/*
                     * 마감되지 않은 경우
                     * 기존 WRK10 폐품 SAP 연동 로직을 그대로 수행
                     */

					var param = new DataMap();

					if (json.DOC_NO2 != '') {
						//SAP에 폐품취소 송신
						param.put("IFID", "MES_IF_144");
						param.put("DOC_NO", json.DOC_NO2);

						var json2 = netUtil.sendData({
							url: "/mes/erpif/json/sendIF.data",
							param: param
						});

						if (json2.data == 'SUCCESS') {
							//SAP에 폐품등록 송신
							rfcDispo(json.DOC_NO1);
						} else {
							alert('(SAP 폐품취소) ' + json2.data);
						}
					} else {
						//SAP에 폐품등록 송신
						rfcDispo(json.DOC_NO1);
					}

				}

				searchList();
			}
		}
		catch (e) {
			/*
             * 예외를 다시 throw하지 않아야
             * netUtil.send()가 로딩 종료 코드를 실행할 수 있다.
             */
			alert(
					'SAP 연계 처리 중 오류가 발생했습니다.\n'
					+ (e.message || e)
			);

		}
		finally {
			/*
             * 기존 RFC가 sendData() 동기 방식이므로
             * 이 위치는 내부의 모든 RFC 함수가 반환된 뒤 실행된다.
             */
			sapProcessing = false;
		}
	}

	//SAP 폐품등록 
	function rfcDispo(DOC_NO){
		//SAP에 폐품등록 송신
		var param = new DataMap();
		
		param.put("IFID", "MES_IF_134");
        param.put("DOC_NO", DOC_NO);
        
        var json2 = netUtil.sendData({
        	url : "/mes/erpif/json/sendIF.data",
        	param : param
        });
		
        if(json2.data == 'SUCCESS'){
        	commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
        }else{
        	alert('(SAP 폐품등록) ' + json2.data);
        }
	}
	
	//폐품취소
	function dispoCancle(){
		var json = netUtil.sendData({
    		module : 'mes',
    		command : 'SYSTEMCHECK',
    		sendType : 'map'
    	});
    	
    	if(json.data.USE_YN == 'Y'){
    		alert('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.');
    		return;
    	}
		
		var list = gridList.getSelectData("gridList3");
		
		if(list.length == 0){
			alert('폐품 취소할 항목을 선택하세요.');
			return;
		}
		
		for(var i = 0; i < list.length; i++){
			if(list[i].get('COM_YN') == 'N'){
				alert('선택한 항목 중 '(i + 1) + '번재 항목은 폐품등록하지 않은 항목입니다.');
				return;
			}
		}
		
		var param = new DataMap();
		
		param.put("P_TYPE", "DELETE");
		param.put("head", headlist);
		param.put("list", list);
		param.put("WERKS", $("#WERKS").val().toUpperCase());
		param.put("PRFM_DT", prfmdt);

		if (!commonUtil.msgConfirm('폐품취소하시겠습니까?')){
			return;
		}
		
		netUtil.send({
			url : "/mes/Work/WRK10/json/datalist.data",
			param : param,
			successFunction : "saveSuccessCallBack2"
		});
	}
	
	function saveSuccessCallBack2(json){
		if(json.P_SUCCESS == 'Y'){
			var param = new DataMap();
			
			//SAP에 폐품취소 송신
    		param.put("IFID", "MES_IF_144");
            param.put("DOC_NO", json.DOC_NO1);
            
            var json2 = netUtil.sendData({
            	url : "/mes/erpif/json/sendIF.data",
            	param : param
            });
			
            if(json2.data == 'SUCCESS'){
            	commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
            }else{
            	alert('(SAP 폐품취소) ' + json2.data);
            }
        	searchList();
		}else{
			alert(json.ERR_MSG);
		}
	}
	
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
			saveData();
		}else{
			dispoCancle();
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
					<input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE" />
					<!-- <input type='button' id='button-0-3' CB='CancleDispo DELETE 폐품취소'/> -->
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
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<input type="text" class="input" name="MATNR" id="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PRFM_DT">실적일자</dt>
						<dd>
							<input type="text" class="input" name="PRFM_DT" UIFormat="C N" validate="required"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MACHINE">생산호기</dt>
						<dd>
							<select class="input" id='MACHINE' name="MACHINE" Combo="Produce,MACHINE">
								<option value="">All</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_WRK_CLASS">반</dt>
						<dd>
							<input type="text" class="input" name="WRK_CLASS" UIInput="SR" UIFormat="U"/>
						</dd>
					</dl>
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
        <div class="search_next_wrap">
			<div class="content_layout tabs content_H_3set" style="height: 250px;">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span>계획</span></a></li>
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
										<td GH="40" GCol="rownum"></td>	
										<!-- <td GH="40" GCol="rowCheck"></td> -->
										<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="130" GCol="text,WRK_ORDR_NO"></td>		<!-- 작업지시번호 -->
										<td GH="80" GCol="text,WRK_ORDR_SEQNO" style="text-align:center;"></td>		<!-- 작업지시순번 -->
										<td GH="100" GCol="text,ORDER_NO">오더번호</td>
										<td GH="100" GCol="text,MACHINE" style="text-align:center;"></td>			<!-- 생산호기 -->
										<td GH="0" GCol="text,MACH_CD" style="text-align:center;">설비코드</td>
										<td GH="140" GCol="text,MATNR" style="text-align:center;"></td>				<!-- 자재코드 -->
										<td GH="320" GCol="text,MATNR_NM"></td>			<!-- 자재명 -->
										<td GH="100" GCol="text,ORDER_QTY" GF="N 10"></td>		<!-- 계획생산량 -->
										<td GH="100" GCol="text,PRFM_QTY" GF="N 10"></td>		<!-- 실적수량 -->
										<td GH="100" GCol="text,UNIT" style="text-align:center;"></td>				<!-- 단위 -->
										<td GH="100" GCol="text,PRD_REQ_DT" GF='D' style="text-align:center;"></td>			<!-- 생산요청일 -->
										<td GH="100" GCol="text,COMP_YN" style="text-align:center;"></td>			<!-- 오더완료 -->
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
			<div class="content_layout tabs content_H_3set" style="height: 187px;">
				<ul class="tab tab_style02">
					<li><a href="#tab2-1"><span>실적</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab2-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_b">
								<tbody id="gridList2">
									<tr CGRow="true">
										<td GH="40" GCol="rownum"></td>
										<td GH="0" GCol="text,WERKS">플랜트</td>
										<td GH="100" GCol="text,MACH_CD" style="text-align:center;">설비코드</td>	
										<td GH="0" GCol="text,WRK_ORDR_NO"></td>		<!-- 작업지시번호 -->
										<td GH="0" GCol="text,WRK_ORDR_SEQNO" style="text-align:center;"></td>		<!-- 작업지시순번 -->
										<td GH="0" GCol="text,ORDER_NO">오더번호</td>
										<td GH="140" GCol="text,MATNR" style="text-align:center;"></td>				<!-- 자재코드 -->
										<td GH="320" GCol="text,MATNR_NM"></td>			<!-- 자재명 -->
										<td GH="100" GCol="text,LOT_NO">LOT NO</td>
										<td GH="100" GCol="text,PRFM_QTY" GF="N 10"></td>		<!-- 실적수량 -->
										<td GH="100" GCol="text,UNIT" style="text-align:center;"></td>				<!-- 단위 -->
										<td GH="100" GCol="text,RUN_TIME"></td>			<!-- 작업시간(분) -->
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
			<div class="content_layout tabs content_H_3set" style="height: 260px;">
				<ul class="tab tab_style02">
					<li><a href="#tab3-1"><span>투입</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab3-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridList3">
									<tr CGRow="true">
										<td GH="40" GCol="rownum"></td>	
										<td GH="40" GCol="rowCheck"></td>
										<td GH='100' GCol='text,PRFM_DT' GF='D'>일자</td>
										<td GH="120" GCol="text,LOT_NO_M">합지LOT NO</td>
										<td GH='120' GCol='text,IND_BCD_M'>개별바코드</td>
										<td GH="140" GCol="text,MATNR_M" style="text-align:center;"></td>			<!-- 자재코드 -->
										<td GH="320" GCol="text,MATNR_NM"></td>										<!-- 자재명 -->
										<td GH="100" GCol="text,UNIT" style="text-align:center;"></td>				<!-- 단위 -->
										<td GH="100" GCol="text,PRFM_QTY" GF="N 10,3"></td>		<!-- 중량 -->
										<td GH="100" GCol="text,USE_QTY_TOTAL_LOT_NO" GF="N 5,3"></td>
										<td GH="100" GCol="text,USE_QTY_DAY" GF="N 5,3">일일 사용량</td>		<!-- 사용량 -->
										<td GH="100" GCol="text,REST_QTY" GF="N 5,3"></td>		<!-- 잔량 -->
										<td GH="100" GCol="text,SCRAP_QTY" GF="N 10,3"></td>	<!-- 폐품수량 -->
										<td GH="100" GCol="input,SCRAP_CHG_QTY" GF="N 10,0"></td>		<!-- 보정수량 -->
										<!-- <td GH="100" GCol="select,COM_YN" style="text-align:center;">
											<select style="text-align:center;">
												<option value="N">미완료</option>
												<option value="Y">완료</option>
											</select>
										</td>			생산완료 -->
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
