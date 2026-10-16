<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>MES</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/demo_layout.css">
<script type="text/javascript">
	$(document).ready(function(){		
		gridList.setGrid({
	    	id : "gridList",
	    	url : "/mes/Inv/INV10/json/datalist.data",
	    	bigdata : false,
	    	colHoldType : true,
	    	colHold : "WERKS, MACH_CD, MACH_NM, MATNR, MATNR_NM"
	    });
		// INV10은 공통 엑셀 업로드 후처리 대신 화면 전용 검증 후 그리드에 반영한다.
		gridList.gridExcelUploadSuccess = inv10GridExcelUploadSuccess;

		getDeptNm();
	});

	// 엑셀 업로드 결과를 서버에서 읽은 뒤, 검증이 끝난 경우에만 그리드에 반영한다.
	function inv10GridExcelUploadSuccess(data){
		var gridId = gridList.excelUpGridId;
		var list = commonUtil.getAjaxUploadFileList(data);
		var cols = gridList.gridMap.map[gridId].viewCols;
		if(!list || list.length == 0){
			return;
		}

		var param = new DataMap();
		param.put("UUID", list[0]);
		param.put("cols", cols);
		commonUtil.setMenuId(param);
		commonUtil.displayLoading(true);
		jQuery.ajax({
			type : "post",
			url : "/common/load/excel/json/grid.data",
			data : param.jsonString(),
			dataType : "json",
			error : function(a, b, c){
				commonUtil.msgBox("ERROR_EXCELLOAD");
				commonUtil.displayLoading(false);
			},
			success : function(json){
				if(!inv10ValidateExcelRows(json.data)){
					commonUtil.displayLoading(false);
					return;
				}

				var dataCount = gridList.viewJsonData(gridId, json, configData.GRID_ROW_STATE_INSERT);
				gridList.gridEventDataBindEnd(gridId, true);
				if(commonUtil.checkFn("gridListEventDataViewEnd")){
					gridListEventDataViewEnd(gridId, dataCount);
				}
				hideExcelUpload();
				commonUtil.displayLoading(false);
			}
		});
	}

	// 같은 엑셀 파일 안의 투입자재 개별바코드 중복 및 날짜 유효성 검사
	// - 날짜 오류: 업로드 중단
	// - 개별바코드 중복: 중복 대상 전체를 안내하고 확인 시 계속 진행, 취소 시 중단
	function inv10ValidateExcelRows(dataList){
		if(!dataList || dataList.length == 0){
			return true;
		}

		var barcodeRowMap = {};   // 바코드별 행 번호 목록
		var barcodeOrder = [];    // 바코드 최초 등장 순서
		var invalidDateList = [];

		for(var i = 0; i < dataList.length; i++){
			var barcode = dataList[i].IND_BCD_M;
			barcode = barcode == null ? "" : String(barcode).replace(/^\s+|\s+$/g, "");
			if(barcode != ""){
				if(!barcodeRowMap.hasOwnProperty(barcode)){
					barcodeRowMap[barcode] = [];
					barcodeOrder.push(barcode);
				}
				barcodeRowMap[barcode].push(i + 1);
			}

			var inpDt = dataList[i].INP_DT;
			var prfmDt = dataList[i].PRFM_DT;
			if(!inv10IsValidDate(inpDt)){
				invalidDateList.push((barcode || (i + 1 + "행")) + " - 투입일자: " + inpDt);
			}
			if(!inv10IsValidDate(prfmDt)){
				invalidDateList.push((barcode || (i + 1 + "행")) + " - 실적일자: " + prfmDt);
			}
		}

		// 날짜 오류는 계속 진행할 수 없으므로 먼저 검사하여 중단한다.
		if(invalidDateList.length > 0){
			alert("엑셀 파일의 투입일자 또는 실적일자가 올바르지 않습니다.\n\n"
					+ invalidDateList.join("\n")
					+ "\n\nYYYYMMDD 형식의 실제 날짜로 수정한 후 다시 업로드해 주세요.");
			return false;
		}

		// 중복 개별바코드 전체 목록 (바코드 / 건수 / 해당 행)
		var duplicateList = [];
		var duplicateRowCount = 0;
		for(var j = 0; j < barcodeOrder.length; j++){
			var rows = barcodeRowMap[barcodeOrder[j]];
			if(rows.length > 1){
				duplicateRowCount += rows.length;
				duplicateList.push((duplicateList.length + 1) + ". " + barcodeOrder[j]
						+ " (" + rows.length + "건 - " + rows.join(", ") + "행)");
			}
		}

		if(duplicateList.length > 0){
			return confirm("엑셀 파일 내 중복된 투입자재 개별바코드가 있습니다.\n"
					+ "(중복 바코드 " + duplicateList.length + "개 / 해당 행 " + duplicateRowCount + "건)\n\n"
					+ duplicateList.join("\n")
					+ "\n\n계속 진행하시겠습니까?\n[확인] 계속 진행 / [취소] 업로드 중단");
		}

		return true;
	}

	function inv10IsValidDate(value){
		var dateText = value == null ? "" : String(value).replace(/^\s+|\s+$/g, "");
		if(!/^\d{8}$/.test(dateText)){
			return false;
		}
		var year = parseInt(dateText.substring(0, 4), 10);
		var month = parseInt(dateText.substring(4, 6), 10);
		var day = parseInt(dateText.substring(6, 8), 10);
		var date = new Date(year, month - 1, day);
		return year > 0
				&& date.getFullYear() == year
				&& date.getMonth() == month - 1
				&& date.getDate() == day;
	}

	function getDeptNm()
	{
		var param = new DataMap();
		
		param.put("P_TYPE", "SELECT");
		
		netUtil.send({
			url : "/mes/Inv/INV10/json/datalist.data",
			param : param,
			successFunction : "savesuccessCallBackDeptNm"
		});
	}

	function savesuccessCallBackDeptNm(json){
		var depart;
		if(json){
			if(json.P_SUCCESS == 'Y'){
				depart = json.data[0]["DEPART"];
				if (depart == 'D2013071' || depart == 'D2013072' || depart == 'D2013076' || depart == 'D2013079' || depart == 'D2013082') {
					$("#button-0-2").hide();
					$("#button-0-3").hide();
				} else {
					$("#button-0-2").show();
					$("#button-0-3").show();
				}
			}
		}
	}
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");

			param.put("P_TYPE", "LIST");
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}
	// 연도 경고 후 동일한 엑셀 데이터를 다시 전송하기 위해 보관한다.
	var excelUploadList = null;

	//엑셀업로드
	function excelUpload(){
		if(gridList.getModifyRowCount("gridList") == 0){
			commonUtil.msgBox("SYSTEM_SAVEEMPTY");
			return;
		}
		
		if(gridList.validationCheck("gridList", "all")){
			var list = gridList.getModifyList("gridList", "A");
			
			for(var i = 0; i < list.length; i++){
				if(gridList.getRowState('gridList', i) != 'C'){
					alert('사용량을 보정하였을 경우에는 저장 버튼을 클릭하세요.')
					return;
				}
			}
			
			if(!commonUtil.msgConfirm("엑셀 업로드하시겠습니까?")){
				return;
			}	
			
			excelUploadList = list;
			sendExcelUpload("N");
		}
	}

	function sendExcelUpload(yearConfirmed){
		var param = new DataMap();

		param.put("P_TYPE", "SAVE3");
		param.put("P_YEAR_CONFIRMED", yearConfirmed);
		param.put("list", excelUploadList);

		netUtil.send({
			url : "/mes/Inv/INV10/json/datalist.data",
			param : param,
			successFunction : "savesuccessCallBack"
		});
	}
	
	function savesuccessCallBack(json){
		if(json){
			if(json.P_SUCCESS == 'Y'){
				var param = new DataMap();
				
				param.put('P_TYPE', 'SAVE2')
				
				netUtil.send({
					url : "/mes/Inv/INV10/json/datalist.data",
					param : param,
					successFunction : "savesuccessCallBack2"
				});
			} else if(json.P_SUCCESS == 'C'){
				// 월/일은 유효하지만 올해가 아닌 날짜가 포함된 경우 사용자 확인 후 재요청한다.
				if(confirm(json.ERR_MSG)){
					sendExcelUpload("Y");
				}
			} else {
				alert(json.ERR_MSG || "엑셀 업로드 검증 중 오류가 발생했습니다.");
				return;
			}
		}
	}
	
	function savesuccessCallBack2(json){
		if(json.P_SUCCESS == 'Y'){
			commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
		}else{
			alert(json.ERR_MSG);
		}
		searchList();
	}
	
	function saveData(){
		if(gridList.getModifyRowCount("gridList") == 0){
			commonUtil.msgBox("SYSTEM_SAVEEMPTY");
			return;
		}
		
		if(gridList.validationCheck("gridList", "all")){
			var list = gridList.getModifyList("gridList", "A");
			
			for(var i = 0; i < list.length; i++){
				if(gridList.getRowState('gridList', i) == 'C'){
					alert('Excel 업로드한 경우에는 업로드 버튼을 클릭하세요.')
					return;
				}
			}
			
			if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
				return;
			}	
			
			var param = new DataMap();
			
			param.put("P_TYPE", "SAVE");
			param.put("list", list);
			
			netUtil.send({
				url : "/mes/Inv/INV10/json/datalist.data",
				param : param,
				successFunction : "savesuccessCallBack3"
			});
		}
	}
	
	function savesuccessCallBack3(json){
		if(json.P_SUCCESS == 'Y'){
			commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
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
		} else if(btnName == "Save"){
		 	saveData();
		} else if(btnName == "Upload"){
		 	excelUpload();
		}
	}
	
	const barcode = () => {
		var url = "/mes/wrk/WRK23_POP01.page";
		page.linkPopOpen(url, "", "height=600,width=850");
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
					<input type="button" id="button-0-3" CB="Upload EXCEL_UP BTN_UPLOAD" />					
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" id="WERKS" name="WERKS" UIInput="S,PLANT" UIFormat="U" validate="required"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PRFM_DT">실적일자</dt>
						<dd>
							<input type="text" name="PRFM_DT" UIInput="B" UIFormat="C M1"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MACH_CD">설비코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 설비코드 RANGE 검색 추가 -->
							<input type="text" id="MACH_CD" name="MACH_CD" UIInput="SR,MACH" UIFormat="U" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR_M">자재코드</dt>
						<dd>
							<input type="text" name="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					
					<dl>
						<dt>투입개별바코드</dt>
						<dd>
							<input type="text" class="input" name="IND_BCD" UIInput="SR,INDBCD" UIFormat="U"/>
						</dd>
					</dl>
						
<!-- 					<dl>
						<dt CL="STD_IND_BCD">개별바코드</dt>
						<dd>
							<input type="text" class="input" name="IND_BCD" UIFormat='S 15'/>
							<button type="button" class="btn btn_search" onclick="barcode()">
								<span>search</span>
							</button>
						</dd>
					</dl> -->
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
        <div class="search_next_wrap">
			<div class="content_layout tabs">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span>투입자재사용이력</span></a></li>
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
										<td GH='40' GCol='rowCheck'></td>	
										<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="100" GCol="text,MACH_CD" style="text-align:center;">설비코드</td>			
										<td GH="160" GCol="text,MACH_NM">설비명</td>			
										<td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>									
										<td GH="320" GCol="text,MATNR_NM">자재명</td>
										<td GH="120" GCol="text,IND_BCD" style="text-align:center;">개별바코드</td>
										<td GH='80' GCol='text,SEQNO' GF='N 10'>순번</td>
										<td GH='100' GCol='text,ORDER_NO' style="text-align:center;">오더번호</td>
										<td GH='130' GCol='text,WRK_ORDR_NO' style="text-align:center;">작업지시번호</td>
										<td GH='80' GCol='text,WRK_ORDR_SEQNO' style="text-align:center;">작업지시순번</td>
										<td GH='100' GCol='text,LOT_NO' style="text-align:center;">LOT번호</td>										
										<td GH="120" GCol="text,IND_BCD_M" style="text-align:center;">투입 개별바코드</td>
										<td GH='100' GCol='text,LOT_NO_M' style="text-align:center;">투입 LOT번호</td>
										<td GH="140" GCol="text,MATNR_M" style="text-align:center;">투입자재코드</td>
										<td GH="320" GCol="text,IN_MATNR_NM">투입자재명</td>
										<td GH="100" GCol="text,INP_DT" GF="D" style="text-align:center;">투입일자</td>	
										<td GH="100" GCol="text,PRFM_DT" GF="D" style="text-align:center;">실적일자</td>
										<td GH="100" GCol="text,USE_QTY" GF="N 13,3">사용량</td>
										<td GH="100" GCol="input,USE_CHG_QTY" GF="N 13,3">사용량보정</td>
										<td GH="100" GCol="text,USE_DIV_NM">자재사용량 보정</td>	
										<td GH="100" GCol="text,UNIT" style="text-align:center;">단위</td>
										<td GH="140" GCol="text,REGDATE" style="text-align:center;"></td> 									
										<td GH="100" GCol="text,REGNM"></td> 			
										<td GH="140" GCol="text,UPDDATE" style="text-align:center;"></td> 	
										<td GH="100" GCol="text,UPDNM"></td> 
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param value="1" name="authCd"/>
						<jsp:param value="1,2,3,7,9,10,11" name="showAuthCd"/>
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
