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
	$(document).ready(function(){
		gridList.setGrid({
			id : "gridList",
	    	url : "/mes/Produce/SCH11/json/datalist.data",
	    	bigdata : false,
	    	colHoldType : true,
	    	colHold : "PRD_REQ_DT,WRK_ORDR_NO,WRK_ORDR_SEQNO,MATNR",
	    	selectRowDeleteType : true,
	    	colorType : true
	    });
		$("#WERKS").val('P100');
	});

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

			param.put("P_TYPE","LIST");
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}
	 
	// 저장
	function saveData(){
		if(gridList.getModifyRowCount("gridList") == 0 ){
			commonUtil.msgBox("MASTER_M0545");
			return;
		}
		
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		}
		
		if(gridList.validationCheck("gridList", "data")){
			var list = gridList.getGridData("gridList");
	
			var param = new DataMap();
			
			param.put("P_TYPE","SAVE");
			param.put("list", list);
	
			var json = netUtil.sendData({
				url : "/mes/Produce/SCH11/json/datalist.data",
				param : param
			});
			
			if(json){
				if(json.data){
					searchList();
				}
			}
		}
	}
	
	// 버튼(조회, 저장 등) 클릭
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
		}
	}
	
	// 복사
	function gridListEventRowCopyAfter(gridId, rowNum, sourceData) {
		const data = gridList.getRowData(gridId, rowNum)
		if(data.get("WRK_ORDR_DIV") === "계획"){ 
			gridList.setRowReadOnly(gridId, rowNum, true, ["WERKS","MATNR","ORDR_GEN_DT","PRD_REQ_DT","MACHINE","BOM_NO","UNIT","PCODE","BS_WGT","JRCNT","JWIDTH","JROLLCNT","TOT_WGT"])
		}
		
		if(data.get("COMP_YN") != "N"){ 
			gridList.setRowReadOnly(gridId, rowNum, true, ["WRK_SEQNO","WRK_ORDR_QTY","WRK_ORDR_REMARK","USE_YN"])
			if(data.get("WRK_ORDR_DIV") === "비계획"){ 
				gridList.setRowReadOnly(gridId, rowNum, true, ["WERKS","MATNR","ORDR_GEN_DT","PRD_REQ_DT","MACHINE","BOM_NO","UNIT","PCODE","BS_WGT","JRCNT","JWIDTH","JROLLCNT","TOT_WGT"])	
			}
		}
	}
	
	// 조회 완료된 후
	function gridListEventDataBindEnd(gridId, dataLength){
		var list = gridList.getGridData(gridId);
		for(var i=0; i < list.length; i++) {
			// 지시구분(계획 : 0, 비계획 : 1)
			if(list[i].get("WRK_ORDR_DIV") === "계획"){ 
				gridList.setRowReadOnly(gridId, i, true, ["WERKS","MATNR","ORDR_GEN_DT","PRD_REQ_DT","MACHINE","BOM_NO","UNIT","PCODE","BS_WGT","JRCNT","JWIDTH","JROLLCNT","TOT_WGT"])	
			}
			
			// 완료여부(N : 대기, I : 작업중, Y : 완료)
			if(list[i].get("COMP_YN") != "N"){ 
				gridList.setRowReadOnly(gridId, i, true, ["WRK_SEQNO","WRK_ORDR_QTY","WRK_ORDR_REMARK","USE_YN"]) // 지시량,작업지시비고,사용여부 수정 안되게
				if(list[i].get("WRK_ORDR_DIV") === "비계획"){ 
					gridList.setRowReadOnly(gridId, i, true, ["WERKS","MATNR","ORDR_GEN_DT","PRD_REQ_DT","MACHINE","BOM_NO","UNIT","PCODE","BS_WGT","JRCNT","JWIDTH","JROLLCNT","TOT_WGT"])	
				}
			}
			
			if(list[i].get("USE_YN") != "Y"){ // 사용여부(N : 미사용, Y : 사용)
				gridList.setRowReadOnly(gridId, i, true, ["WERKS","MATNR","ORDR_GEN_DT","PRD_REQ_DT","WRK_SEQNO","WRK_ORDR_QTY","WRK_ORDR_REMARK","MACHINE","BOM_NO","UNIT","PCODE","BS_WGT","JRCNT","JWIDTH","JROLLCNT","TOT_WGT"])
			}
		}
	}
	
	// 삭제 
	function gridListEventRowRemove(gridId, rowNum){
		if(gridId === "gridList"){
			const data = gridList.getRowData(gridId, rowNum)
			if(data.get("USE_YN") != "N"){
				alert("사용여부가 \'미사용\'가 아닌 행이 존재합니다.")
				return false
			}
			
			if(data.get("COMP_YN") != "N"){
				alert("작업지시 상태가 \'대기\'가 아닌 행이 존재합니다.")
				return false
			}
		}
	}
	
	// 2022-10-18(일요일) 안상현, 사용여부가 "미사용"인 경우 오렌지로 라인 표시
 	function gridListRowColorChange(gridId, rowNum, rowData){
		if(gridId === "gridList" && rowData.get("USE_YN") === "N"){
			return configData.GRID_COLOR_BG_ORANGE_CLASS;
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
					<!-- <input type="button" id="button-0-3" CB="NoPlanProd ADD BTN_NOPLANPROD" /> 비계획생산 -->
					<input type="button" id="button-0-1" CB="Search SEARCH BTN_SEARCH" />
					<input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE" />
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
                        	<input type="text" name="PRD_REQ_DT" UIInput="B" UIFORMAT="C M1"/>
                        </dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<input type="text" id="MATNR" name="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MACHINE">생산호기</dt>
						<dd>
							<select class="input" name="MACHINE" Combo="Produce,MACHINE">
								<option value="">All</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_ORDR_GEN_DT">작업지시일자</dt>
                        <dd>
                        	<input type="text" name="ORDR_GEN_DT" UIInput="B" UIFORMAT="C"/>
                        </dd>
					</dl>
					<dl>
						<dt CL="STD_AUFNR">생산오더번호</dt>
                        <dd>
                        	<input type="text" name="ORDER_NO" UIInput="SR" UIFORMAT="U" />
                        </dd>
					</dl>
					<!-- 20230213 여한진 지종코드, 평량 검색조건 추가 -->
					<dl>
						<dt CL="STD_PCODE">지종코드</dt>
						<dd>							
							<input type="text" class="input" name="PCODE" UIInput='SR,PCODE' UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_BS_WGT">평량</dt>
						<dd>							
							<input type="text" class="input" name="BS_WGT" UIInput="SR"/>
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
					<li><a href="#tab1-1"><span CL="STD_GRD_SCH11">일반</span></a></li>
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
										<td GH="100" GCol="input,PRD_REQ_DT" GF="C" style="text-align: center;" validate="required">생산요청일</td>
										<td GH="150" GCol="text,WRK_ORDR_NO" style="text-align: center;">작업지시번호</td>
										<td GH="80" GCol="text,WRK_ORDR_SEQNO" style="text-align:center;">지시순번</td>
										<td GH="140" GCol="input,MATNR,MATKY" style="text-align: center;" validate="required">자재코드</td>
										<td GH="100" GCol="text,WRK_ORDR_DIV" style="text-align: center;">지시구분</td>
										<td GH="100" GCol="text,WRK_ORDR_QTY" GF="N 10,3">지시량</td>
										<td GH="80" GCol="text,ORDR_UNIT" style="text-align: center;">지시단위</td>
										<td GH="100" GCol="text,TOT_WGT" GF="N 10,3">총중량</td>
										<td GH="80" GCol="text,WUNIT" style="text-align: center;">중량단위</td>
										<td GH="100" GCol="input,WERKS,PLANT" style="text-align:center;" validate="required">플랜트</td>
										<td GH="100" GCol="input,ORDR_GEN_DT" GF="C" style="text-align:center;" validate="required">작업지시일자</td>
										<td GH="80" GCol="input,WRK_SEQNO" style="text-align: center;">작업순서</td>
										<td GH="250" GCol="input,WRK_ORDR_REMARK" GF="S 300">작업지시비고</td>
										<td GH="100" GCol="select,USE_YN">
											<select class="input" CommonCombo="USE_YN" style="text-align: center;">	<!-- 사용여부 -->
												<option value="Y">사용</option>
												<option value="N">미사용</option>
											</select>
										</td>
										<td GH="100" GCol="select,MACHINE" style="text-align: center;" validate="required"> <!-- 생산호기 -->
											<select class="input" Combo="Produce,MACHINE" style="text-align: center;">
												<option value=""></option>
											</select>
										</td>
										<td GH="0" GCol="input,BOM_NO,BOM">BOM</td>
										<td GH="100" GCol="input,PCODE" style="text-align: center;">지종코드</td>
										<td GH="100" GCol="input,BS_WGT" style="text-align: center;">평량</td>
										<td GH="100" GCol="input,JRCNT" style="text-align: right;">J/R 개수</td>
										<td GH="100" GCol="input,JWIDTH" style="text-align: center;">J/R 지폭</td>
										<td GH="100" GCol="input,JROLLCNT" GF="N 10">J/R 권치수</td>
										<td GH="80" GCol="text,ROLLUNIT" style="text-align: center;">권치수단위</td>
										
										<td GH="100" GCol="text,ORDER_NO" style="text-align: center;">오더번호</td>
										<td GH="320" GCol="text,MATNR_NM" style="text-align: center;">자재명</td>
										<td GH="80" GCol="text,SHEET" style="text-align: center;">판지구분자</td>
										<!-- 202209027 여한진 화면에서 필요헚는 컬럼 주척 처리 -->
										<!-- <td GH="80" GCol="text,EXPORT_YN" style="text-align: center;">수출여부</td>
										<td GH="150" GCol="text,PACKTYPE">포장방법</td>
										<td GH="150" GCol="text,KUNNR">판매처</td>
										<td GH="100" GCol="text,PKCNT" GF="N 10">폭수</td> -->
										<!-- 202209026 여한진 화면에서 필요헚는 컬럼 주척 처리 -->
										<!-- <td GH="150" GCol="text,ORDER_DIV_NM">오더유형 텍스트</td> -->
										<!-- <td GH="150" GCol="text,NAUFNR">오더 변경 번호</td> -->
										<td GH="150" GCol="text,PRD_STR_DTM" style="text-align:center;">생산시작시간</td>
										<td GH="150" GCol="text,PRD_END_DTM" style="text-align:center;">생산완료시간</td>
										<td GH="100" GCol="text,COMP_YN_NM" style="text-align:center;">작업지시상태 (N:대기 I:작업중 Y:완료)</td>
										<td GH="300" GCol="text,PLN_ORDR_REMARK">계획오더비고</td>
										<td GH="140" GCol="text,REGDATE" style="text-align: center;">등록일시</td>
										<td GH="100" GCol="text,REGNM" style="text-align: center;">등록자</td>
										<td GH="140" GCol="text,UPDDATE" style="text-align: center;">수정일시</td>
										<td GH="100" GCol="text,UPDNM" style="text-align: center;">수정자</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="1" />
						<jsp:param name="showAuthCd" value="1,2,3,4,5,6,7,9,10" />
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