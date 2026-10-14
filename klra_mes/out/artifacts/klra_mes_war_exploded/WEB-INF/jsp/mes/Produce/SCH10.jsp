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
	    	url : "/mes/Produce/SCH10/json/datalist.data",
	    	bigdata : false,
	    	pkcol :"WERKS",
	    	colHoldType : true,
	    	colHold : "PRD_REQ_DT,WRK_ORDR_NO,WRK_ORDR_SEQNO,MATNR,MATNR_NM",
	    	colorType : true
	    });
	});

	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "Produce,MACHINE"){
			var param = new DataMap();
			
			param.put("WERKS", 'P500');
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
		
		if(gridList.validationCheck("gridList", "all")){
			var list = gridList.getGridData("gridList");
		
			var param = new DataMap();
			
			param.put("P_TYPE","SAVE");
			param.put("list", list);
		
			var json = netUtil.sendData({
				url : "/mes/Produce/SCH10/json/datalist.data",
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
		// 컬럼 focus
		gridList.setColFocus(gridId, rowNum, "WRK_ORDR_QTY");
	}
	
	// 조회 완료된 후
	function gridListEventDataBindEnd(gridId, dataLength){
		var list = gridList.getGridData(gridId);
		for(var i=0; i < list.length; i++) {
			if(list[i].get("COMP_YN") != "N"){ // 작업지시상태(N : 대기, I : 진행중, Y : 완료, 오더 삭제 : 작업지시 삭제)
				gridList.setRowReadOnly(gridId, i, true, ["PRD_REQ_DT", "WRK_SEQNO","WRK_ORDR_QTY","WRK_ORDR_REMARK","USE_FLAG"]); // 작업순서,지시량,작업지시비고,오더 삭제여부 수정 안되게
			}
			
			if(list[i].get("USE_STATE") != "Y"){ // 사용여부(N : 미사용, Y : 사용)
				gridList.setRowReadOnly(gridId, i, true, ["PRD_REQ_DT", "WRK_SEQNO","WRK_ORDR_QTY","WRK_ORDR_REMARK"]); // 작업순서,지시량,작업지시비고 수정 안되게
			}
		}
	}
	
	// 2022-10-18(일요일) 안상현, 오더 삭제여부가 "오더 삭제"인 경우 오렌지로 라인 표시
 	function gridListRowColorChange(gridId, rowNum, rowData){
		if(gridId === "gridList" && rowData.get("USE_STATE") === "N"){
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
					<input type="button" id="button-0-1" CB="Search SEARCH BTN_SEARCH" />
					<input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
				  	<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>							
							<input type="text" class="input" id="WERKS" name="WERKS" value="P500" readonly />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<input type="text" id="MATNR" name="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PRD_REQ_DT">생성요청일자</dt>
                        <dd>
                        	<input type="text" name="PRD_REQ_DT" UIInput="B" UIFORMAT="C M1"/>
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
					<dl>
						<dt CL="STD_USE_FLAG">오더 삭제여부</dt>
						<dd>
							<select class="input" name="USE_FLAG" CommonCombo="USEFLAG">
								<option value="">All</option>
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
			<div class="content_layout tabs">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span>일반</span></a></li>
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
										<!-- 20220919 여한진 생산요청일자 수정가능하도록 바꿈 -->
										<td GH="100" GCol="input,PRD_REQ_DT" GF="C" style="text-align: center;">생산요청일</td>
										<td GH="150" GCol="text,WRK_ORDR_NO" style="text-align: center;">작업지시번호</td>
										<td GH="200" GCol="text,MATNR" style="text-align: center;" >자재코드</td>
										<td GH="300" GCol="text,MATNR_NM">자재명</td>
										<td GH="100" GCol="text,WRK_ORDR_QTY" GF="N 10">지시량</td>	
										<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="100" GCol="text,ORDER_NO">오더번호</td>
										<td GH="100" GCol="text,ORDER_SEQNO" GF="N 5" style="text-align: center;">오더순번</td>								
										<td GH="80" GCol="input,WRK_SEQNO" GF="N 5" style="text-align: center;">작업순서</td>
										<td GH="100" GCol="text,UNIT" style="text-align: center;">단위</td>
										<td GH="250" GCol="input,WRK_ORDR_REMARK">작업지시비고</td>
										<td GH="100" GCol="text,USE_FLAG">오더 삭제여부</td>
										<td GH="100" GCol="text,MACHINE" style="text-align: center;">생산호기</td>
										<td GH="100" GCol="text,FQTY" GF="N 10">오더량</td>
										<td GH="100" GCol="text,ORDR_GEN_DT" GF="C" style="text-align:center;">작업지시일자</td>
										<td GH="100" GCol="text,PQTY" GF="N 10">팔레트 적재수량</td>
										<td GH="100" GCol="text,PRFM_QTY" GF="N 10">실적수량</td>
										<td GH="150" GCol="text,PRD_STR_DTM" style="text-align:center;">생산시작시간</td>
										<td GH="150" GCol="text,PRD_END_DTM" style="text-align:center;">생산완료시간</td>
										<td GH="100" GCol="text,COMP_YN_NM" style="text-align:center;">작업지시상태 (N:대기 I:작업중 Y:완료 오더 삭제:작업지시 삭제)</td>
										<td GH="300" GCol="text,PLN_ORDR_REMARK" GF="S 1000">계획오더비고</td>
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
						<jsp:param name="showAuthCd" value="1,2,3,5,7,9,10" />
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