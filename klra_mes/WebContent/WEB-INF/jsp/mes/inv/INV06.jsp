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
	var message = '';
	
	$(document).ready(function(){	
		gridList.setGrid({
			id : "gridList",
			url:"/mes/Inv/INV06/json/datalist.data",
			bigdata : false,
			colHoldType : true,
			colHold : 'MATNR_M'
		})
		
		 gridList.setGrid({
			id : "gridList2",
			url:"/mes/Inv/INV06/json/datalist.data",
			bigdata : false,
			colHoldType : true,
			colHold : 'WERKS, MACH_CD, MACH_NM, PRFM_DT'
		}) 
	});
	
	function searchHelpEventCloseAfter(searchCode, multyType, selectData, rowData){
		if(searchCode == "PLANT"){
			reloadCombo();
		}
	}
	
	function reloadCombo(){
		$comboObj = $("#MACHINE");
		inputList.reloadCombo($comboObj, configData.INPUT_COMBO, "Produce,MACHINE");
		
		$('#PROC_CD').val('');
	}

	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "Produce,MACHINE"){
			var param = new DataMap();
			
			param.put("WERKS", $("#WERKS").val().toUpperCase());
		}
		return param;
	}
	
	//20221024 여한진 화장지 같은 경우 생산호기가 합지랑 가공이 구분이 가지 않아서 공정코드로 구분
	function procCdcheck(){
		if($('#WERKS').val().toUpperCase() == 'P200'){
			if ($('#PROC_CD').val() == '') return alert('공정코드를 검색 및 입력하세요.');
			
			$("#MACHINE").find("option").map(function(){
				//20221023 여한진 화장기 합지 또는 가공에 따라서 
				const text = $(this).text()
				
				if($('#PROC_CD').val().toUpperCase() == 'AA'){
					// "합지 :" 문자열을 포함하지 않을 경우
					if(text.indexOf("합지") === -1){
						$(this).hide()
					}else{
						$(this).show()
					}
				}else if($('#PROC_CD').val().toUpperCase() == 'RA'){
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
			var range = inputList.setRangeParam("searchArea");
			
			if(range.get('WERKS') == 'P100'){
				alert('HL 생활용품팀이 관리하는 화면입니다.');
				return;
			}
			
			var param = new DataMap();
			
			param.put("P_TYPE", "LIST");
			param.put("WERKS", range.get('WERKS'));
			param.put("MATNR", range.get('MATNR'));
			param.put("PROC_CD", range.get('PROC_CD'));
			param.put("CLOSE", range.get('CLOSE'));
			param.put('MACHINE', range.get('MACHINE'));
			
			if(range.get('CLOSE') == '1'){
				param.put("SDATE", range.get('PRFM_DT'));
			}else{
				param.put('SDATE', range.get('PRFM_DT').slice(0, 6) + '01');
				param.put('EDATE', range.get('PRFM_DT').slice(0, 6) + '31');
			}
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
			gridList.resetGrid('gridList2');
			
			//TODO : 체크필요
// 			searchList3(); //아마 reload를 위해 추가한거 같은데 searchList3에 rowNum 이 안넘어가서 오류발생함 그래서 주석처리 
		}
	}
	
	const searchList3 = (rowNum) => {
		var list = gridList.getRowData("gridList", rowNum);
		var param = inputList.setRangeParam('searchArea');
		
		param.put("P_TYPE", "LIST2");
		param.put('list', list);
		
		if(param.get('CLOSE') == '1'){
			param.put("SDATE", param.get('PRFM_DT'));
		}else{
			param.put('SDATE', param.get('PRFM_DT').slice(0, 6) + '01');
			param.put('EDATE', param.get('PRFM_DT').slice(0, 6) + '31');
		}
		
		gridList.gridList({
			id : "gridList2",
			param : param
		});
	}
	
	const searchList2 = (rowNum) => {
		var list = gridList.getRowData("gridList", rowNum);
		var param = inputList.setRangeParam('searchArea');
		
		param.put("P_TYPE", "LIST2");
		param.put('list', list);
		
		if(param.get('CLOSE') == '1'){
			param.put("SDATE", param.get('PRFM_DT'));
		}else{
			param.put('SDATE', param.get('PRFM_DT').slice(0, 6) + '01');
			param.put('EDATE', param.get('PRFM_DT').slice(0, 6) + '31');
		}
		
		gridList.gridList({
			id : "gridList2",
			param : param
		});
	}
	
	const gridListEventRowDblclick = (gridId, rowNum) => {
		if(gridId === "gridList"){
			searchList2(rowNum);
		}
	}
	
	// 저장
	function saveData(){
		if(gridList.getModifyRowCount('gridList2') == 0){
			return;
		}
		
		var list = gridList.getModifyList("gridList2", 'A');
		
		for(var i = 0; i < list.length; i++){
			/* 
			if(list[i].get('CHG_QTY') == ''){
				alert('선택한 항목 중 ' + (i + 1) + '번째 투입조정량에 값이 입력이 되어있지 않습니다.');
				return;
			} 
			*/
			
			// 2023-01-16(월요일) 안상현, 사용보정량 수정
			if(list[i].get("USE_CHG_QTY") === ""){
				alert("선택한 항목 중" + (i + 1) + "번째 사용보정량 값이 입력이 되어있지 않습니다.")
				return
			}
		}
		
		var param = inputList.getRangeParam('searchArea');
		
		param.put("P_TYPE","SAVE1");
		param.put("list", list);
		
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		}
		
		netUtil.send({
			url : "/mes/Inv/INV06/json/datalist.data",
			param : param,
			successFunction : "saveSuccessCallBack"
		});
	}
	
	function saveSuccessCallBack(json){
		if(json.P_SUCCESS == 'Y'){
			commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
			searchList();
		}else{
			alert(json.ERR_MSG);
		}
	}
	
	// 마감
	function finish(){
		var json = netUtil.sendData({
    		module : 'mes',
    		command : 'SYSTEMCHECK',
    		sendType : 'map'
    	});
    	
    	if(json.data.USE_YN == 'Y'){
    		alert('시스템 점검 중입니다. 1 ~ 5분 동안 잠시만 기다려 주세요.');
    		return;
    	}
		
		if(gridList.getGridDataCount('gridList') == 0){
			alert('조회된 데이터가 없습니다.');
			return;
		}
		
		var range = inputList.setRangeParam("searchArea");
		
		var param = new DataMap();
		
		param.put("P_TYPE", "SAVE2");
		param.put("WERKS", range.get('WERKS'));
		param.put("MATNR", range.get('MATNR'));
		param.put("PROC_CD", range.get('PROC_CD'));
		param.put("CLOSE", range.get('CLOSE'));
		param.put('MACHINE', range.get('MACHINE'));
		
		if(range.get('CLOSE') == '1'){
			param.put("SDATE", range.get('PRFM_DT'));
		}else{
			param.put('SDATE', range.get('PRFM_DT').slice(0, 6) + '01');
			param.put('EDATE', range.get('PRFM_DT').slice(0, 6) + '31');
		}
		
		if(!commonUtil.msgConfirm("마감 처리하시겠습니까?")){
			return;
		}
		
		netUtil.send({
			url : "/mes/Inv/INV06/json/datalist.data",
			param : param,
			successFunction : "saveSuccessCallBack2"
		});
	}
	
	function saveSuccessCallBack2(json){
		if(json.P_SUCCESS == 'Y'){
			if(json.DOC_NO1 == '' && json.DOC_NO2 == '')	return alert('이미 마감 처리가 완료되었습니다. 재마감 처리 가능합니다.');
			if(json.DOC_NO1 != ''){
				var param = new DataMap();
				//SAP 자재투입량 취소
				param.put("IFID", "MES_IF_143");
	            param.put("DOC_NO", json.DOC_NO1);
	             
	            var json2 = netUtil.sendData({
	            	url : "/mes/erpif/json/sendIF.data",
	            	param : param
	            });
	            
	            if(json2.data == 'SUCCESS'){
	            //if('SUCCESS' == 'SUCCESS'){
	            	//SAP 자재투입량 실적
	            	interfaceRfcDocno(json.DOC_NO2);
	            }else{
	            	message = '(SAP 자재투입량 취소) ' + json2.data + '\n';
	            }
			}else{
				//SAP 자재투입량 실적
	        	interfaceRfcDocno(json.DOC_NO2);
			}
			
			if(message == ''){
				alert("마감 처리되었습니다.");
				searchList();
			}else{
				alert(message);
				message = '';
			}
		}else{
			alert(json.ERR_MSG);
		}
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
		}
	}
	
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}else if(btnName == "Finish"){
			finish();
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
					<input type="button" id='button-0-2' CB='Save SAVE BTN_SAVE'/>
					<input type="button" id="button-0-3" CB="Finish SAVE BTN_FINISH" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_WERKS">플랜트</dt>
						<dd>
							<input type="text" class="input"  name="WERKS" id="WERKS" UIInput="S,PLANT" UIFormat="U" validate='required' onkeyup="reloadCombo()"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PROC_CD">공정코드</dt>
						<dd>
							<input type="text" class="input"  name="PROC_CD" id="PROC_CD" UIInput="S,OP" UIFormat="U" validate='required'/>
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
						<dt CL="STD_PRFM_DT">실적일자</dt>
						<dd>
							<input type="text" class="input" id="PRFM_DT" name="PRFM_DT" UIFormat='C N'/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<input type="text" class="input"  name="MATNR" id="MATNR" UIInput="S,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt>구분</dt>
						<dd>
							<select class="input" id="CLOSE" name="CLOSE" CommonCombo="CLOSE">
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
			<div class="content-horizontal-wrap" >	
				<div class="content_layout tabs content_left" style="width: calc(40% - 10px);">
					<ul class="tab tab_style02">
						<li><a href="#tab1-1"><span>투입 자재 목록</span></a></li>
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
											<td GH="120" GCol="text,MATNR_M" style="text-align:center;"></td>	<!-- 자재코드 -->
											<td GH="240" GCol="text,MATNR_NM">투입자재명</td>							
											<td GH="100" GCol="text,USE_QTY" GF='N 13,3'></td>					<!-- 사용량-->		
											<td GH="80" GCol="text,UNIT" style="text-align:center;"></td>		<!-- 단위 -->
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
				<div class="content_layout tabs content_right" style="width: calc(60% - 10px);">
					<ul class="tab tab_style02">
						<li><a href="#tab1-1"><span>투입 자재 상세정보</span></a></li>
						<li class="btn_zoom_wrap">
							<ul>
								<!-- <li><button class="btn btn_smaller"><span>축소</span></button></li> -->
								<li><button class="btn btn_bigger"><span>확대</span></button></li>
							</ul>
						</li>
					</ul>
					<div class="table_box section" id="tab1-1">
						<div class="table_list01">
							<div class="scroll">
								<table class="table_c">
									<tbody id="gridList2">
										<tr CGRow="true">
											<td GH="40" GCol="rownum">1</td>
											<td GH="40" GCol="rowCheck"></td>
											<td GH='100' GCol='text,WERKS' style="text-align:center;">플랜트</td>
											<td GH="0" GCol="text,MACH_CD" style="text-align:center;"></td>			<!-- 설비코드 -->
											<td GH="140" GCol="text,MACH_NM" style="text-align:center;"></td>			<!-- 설비명 -->
											<td GH="100" GCol="text,PRFM_DT" GF='D' style="text-align:center;"></td>		<!-- 실적일자 -->	
											<td GH='130' Gcol='text,WRK_ORDR_NO' style="text-align:center;">작업지시번호</td>
											<td GH='80' Gcol='text,WRK_ORDR_SEQNO' style="text-align:center;">작업지시순번</td>
											<td GH='100' Gcol='text,ORDER_NO' style="text-align:center;">오더번호</td>
											<td GH="0" GCol="text,MATNR" style="text-align:center;"></td>			<!-- 자재 -->
											<td GH="240" GCol="text,MATNR_NM"></td>			<!-- 자재명 -->
											<td GH="100" GCol="text,LOT_NO" style="text-align:center;"></td>		<!-- LOT NO -->
											<td GH="140" GCol="text,MATNR_M" style="text-align:center;"></td>		<!-- 투입자재코드 -->
											<td GH='120' Gcol='text,IND_BCD_M' style="text-align:center;">개별바코드</td>
											<td GH="100" GCol="text,LOT_NO_M" style="text-align:center;"></td>		<!-- 투입자재 LOT NO -->
											<td GH="80" GCol="text,UNIT" style="text-align:center;"></td>			<!-- 단위 -->	
											<td GH='100' GCol='text,STCK_QTY' GF='N 13,3'></td>		<!-- 재고수량 --> 
											<td GH='100' GCol='text,PRFM_QTY' GF='N 13,3'></td>		<!-- 재고수량 --> 
											<td GH="100" GCol="text,USE_QTY" GF='N 13,3'></td>		<!-- 사용량-->		
											<td GH="100" GCol="input,USE_CHG_QTY" GF='N 10,3'></td>		<!-- 사용량 조정-->		
											<td GH='100' GCol='text,SCRAP_QTY' GF='N 13,3'>폐품량</td>
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
				</div>
			</div>
		</div>
	</div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>