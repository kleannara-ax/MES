<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
			id : "gridList1",
			editable : true,
			module : "Erpif",
			command : "IFWMSLOG",
			colHoldType: true,
			colHold : "SEQNO,IFID,IFKNM,SYSFR,SYSTO",
		});

		// 검색조건 - 인터페이스 ID
		var $selIFID = $('select[name="A.IFID"]');
		inputList.setMultiComboSelectAll($("A.IFID"),true);
		$selIFID.multipleSelect('checkAll');
		// 검색조건 - 데이터수신
		var $selCOMSTAT = $('select[name="A.COMSTAT"]');
		inputList.setMultiComboSelectAll($("A.COMSTAT"),true);
		$selCOMSTAT.multipleSelect('setSelects', ['S','R','E']);

		$('[ms-drop="A.IFID"]').css("width","400px");
		
		// 조회
		searchList();
	});
	
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			// 조회
			searchList();
		} else if(btnName == "Detail") {
			// 상세조회
			if(gridList.getGridDataCount("gridList1") > 0) {
				var rowData = gridList.getRowData("gridList1", gridList.getFocusRowNum("gridList1"));
				page.linkPopOpen("/mes/erpif/IF01POPD.page", rowData);
			} else {
				commonUtil.msgBox("VALID_M0005"); // 조회된 데이터가 없습니다.
			}
		}
	}
	
	function searchList(){
		if(validate.check("searchArea")){
			var ifid = $('#IFID').val();
			var param = inputList.setRangeDataParam("searchArea");
			console.log(param);
			// 멀티콤보박스 전체 선택시 SQL상 조건절 OR 형태로 전체 추가되지 않도록 RANGE 제거
			if(inputList.getMultiComboValue($("#IFID")).length == $('#IFID > option').length) {param.get("RANGE_DATA_PARAM").remove("IFID_Single")};

			gridList.gridList({
				id : "gridList1",
				param : param
			});
		}
		
		$("#tab1").trigger('click'); 
	}
	
	function gridListEventRowDblclick(gridId, rowNum){
		if(gridId == "gridList1"){
			commonBtnClick("Detail");
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
					<input type="button" CB="Search SEARCH BTN_DISPLAY" />
					<input type="button" CB="Detail SEARCH BTN_DISDTL" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL1="STD_CDATE">처리일자</dt>
						<dd>
							<input type="text" name="A.CREDAT" UIInput="R" UIFormat="C -0" validate="required(STD_CDATE)"/>
						</dd>
					</dl>
					<dl>
						<dt CL1="STD_IFID">인터페이스ID</dt>
						<dd>
							<select Combo="Erpif,IFCOMBO" style="width:200px;" class="input" name="A.IFID" id="IFID" ComboType="MS" validate="required(STD_IFID)"></select>
						</dd>
					</dl>
					<dl>
						<dt CL1="ITF_COMSTAT">통신상태</dt>
						<dd>
							<select CommonCombo="COMSTAT" style="width:200px;" class="input" name="A.COMSTAT" id="COMSTAT" ComboType="MS"></select>
						</dd>
					</dl>
					<dl>
						<dt CL="그룹구분">그룹구분</dt>
						<dd>
							<select Combo="Erpif,IFGRPCD" ComboCodeView="true" style="width:200px;" class="input" name="B.GRP_CD" id="GRP_CD" ComboType="MS"></select>
						</dd>
					</dl>
					<dl>
						<dt CL1="ITF_COMSTAT">페이지 사이즈</dt>
						<dd>
							<select CommonCombo="PAGESIZE" style="width:200px;" class="input" name="PAGESIZE" id="PAGESIZE" ComboType="S" onchange="searchList()"></select>
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
				<div class="table_box section" id="tabs1-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridList1">
									<tr CGRow="true">
										<td GH="40" GCol="rownum"></td>
										<td GH="230 STD_LOGSEQ" GCol="text,SEQNO">로그순서</td>
										<td GH="100 STD_IFID" GCol="text,IFID">인터페이스ID</td>
										<td GH="250 STD_IFKNM" GCol="text,IFKNM">인터페이스명</td>
										<td GH="50 송신" GCol="text,SYSFR">송신</td>
										<td GH="50 수신" GCol="text,SYSTO">수신</td>
										<td GH="100 STD_IFTBL" GCol="text,IFTBL">인터페이스테이블</td>
										<td GH="80 통신상태" GCol="text,COMSTATNM">통신상태</td>
										<td GH="140 STD_REGDATE" GCol="text,CDATE" GF="DTS">등록일시</td>
										<td GH="1100 STD_ERRTXT" GCol="text,ERRTXT">에러내역</td>
										<td GH="150 재전송여부" GCol="text,RESENDYN">재전송여부</td>
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