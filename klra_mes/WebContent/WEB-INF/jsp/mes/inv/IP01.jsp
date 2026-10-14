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
	var searchType = "";
	
	$(document).ready(function(){
		gridList.setGrid({
			id : "gridList",
			name : "gridList",
			editable : true,
			module : "Inv",
			command : "IP01"
		});
		
		gridList.setGrid({
			id : "gridListSub",
			name : "gridListSub",
			editable : true,
			module : "Inv",
			command : "IP01Sub"
		});

		uiList.setActive("Save", false);
		uiList.setActive("PrintPhydList", false);
		initSearchArea();
	});
	
	function initSearchArea() {
		
	}
	
	function comboEventDataBindeBefore(comboAtt){
		var param = new DataMap();
		if(comboAtt == "Produce,MACHINE"){
			//param.put("WERKS", 'P200');
		}
	
		return param;
	}
	
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}
	}
	
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			param.put("WAREKY", "<%=wareky%>");
			param.put("OWNRKY", "<%=ownrky%>");
			param.put("LANGKY", "<%=langky%>");
			param.put("PHSCTY", "511"); /* 2022.04.08 511만 적용*/

			searchType = "NEW";
			
			gridList.gridList({
				id : "gridList",
				param : param
			});
			
			gridList.gridList({
				id : "gridListSub",
				param : param
			});
		}
		gridList.setReadOnly("gridList", false);
		gridList.setReadOnly("gridListSub", false);
	}
	
	function gridListEventDataBindEnd(gridId, dataCount){
		gridList.setReadOnly("gridListSub", true, ['LOTA06']);
		
		if(searchType == "NEW"){
			uiList.setActive("Save", true);
			uiList.setActive("PrintPhydList", false);
			
		}else if(searchType = "SAVE"){
			uiList.setActive("Save", false);
			uiList.setActive("PrintPhydList", true);
		}
		
		if (gridId == "gridList") {
			uiList.setActive("Search", true);
		}
	}
	
	function saveData(){
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		}
		
		if(gridList.validationCheck("gridListSub", "select")){
			var chkRowCnt = gridList.getSelectRowNumList("gridListSub").length;
			var chkRowIdx = gridList.getSelectRowNumList("gridListSub");
			
			if(chkRowCnt > 0){
				var head = gridList.getRowData("gridList", 0);
				var list = gridList.getSelectData("gridListSub");
				
				var param = new DataMap();
				param.put("head", head);
				param.put("list", list);
				param.put("OWNRKY", "<%=ownrky%>");
				param.put("PROGID", "<%=menuId%>");
				param.put("LANGKY","<%=langky%>");
				
				var json = netUtil.sendData({
					url : "/mes/Inv/json/saveIP01.data",
					param : param
				});
				
				if(json && json.data){
					commonUtil.msgBox("MASTER_M0564"); //저장이 완료되었습니다.
				}
			}else{
				commonUtil.msgBox("TASK_M0003");
				return false;
			}
		}
	}
	
	function printPhydList(){
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
	}
	
	function searchHelpEventOpenBefore(searchCode, gridType, $inputObj){
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
					<input type="button" CB="Save SAVE BTN_SAVE"/><!-- 지시서 저장 -->
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap">
					<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" id="WERKS" name="WERKS" UIInput="S,PLANT" UIFormat="U" validate="required"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_STOR_LOC_CD">저장위치코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 저장위치 RANGE 검색 추가 -->
							<input type="text" class="input" id="STOR_LOC_CD" name="STOR_LOC_CD" UIInput="SR,LOC" UIFormat="U"/>
						</dd>
					</dl>
				 	<dl>
						<dt CL="STD_LOC_CD">로케이션 코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 로케이션 RANGE 검색 추가 -->
							<input type="text" id="LOC_CD" name="LOC_CD" UIInput="SR,LOCATION" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MACH_CD">설비코드</dt>
						<dd>
							<input type="text" id="MACH_CD" name="MACH_CD" UIInput="SR,MACH" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MACHINE">생산호기</dt>
						<dd>
							<select class="input" id="MACHINE" name="MACHINE" ComboType="MS" Combo="Produce,MACHINE">
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 자재코드 RANGE 검색 추가 -->
							<input type="text" name="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					
					<dl>
						<dt CL="STD_PCODE">지종코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 지종코드 RANGE 검색 추가 -->
							<input type="text" class="input" id="PCODE" name="PCODE" UIInput="SR,PCODE" UIFormat="U"/>
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
					<li><a href="#tab1-1"><span CL="STD_LIST">리스트</span></a></li>
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
										<td GH="40" 				GCol="rownum">1</td>
										<td GH="100 STD_PHYIKY"		GCol="input,PHYIKY">재고실사번호</td>
										<td GH="90 STD_CREDAT"		GCol="input,DOCDAT" GF="C 8" validate="required">생성일자</td>
										<!-- <td GH="80 STD_BLIND"		GCol="check,BLIND">블라인드</td> -->
										<td GH="80 STD_DOCCAT"		GCol="text,DOCCAT">문서카테고리</td>
										<td GH="100 STD_DOCCATNM"	GCol="text,DOCCATNM">문서카테고리명</td>
										<td GH="60 STD_DOCUTY"		GCol="text,DOCUTY">문서유형</td>
										<td GH="140 STD_DOCUTYNM"	GCol="text,DOCUTYNM">문서유형명</td>
										<td GH="200 STD_WRK_ORDR_RMK"		GCol="input,DOCTXT" GF="S 1000">비고</td>
										<td GH="60 STD_WAREKY"		GCol="text,WAREKY">거점</td>
										<td GH="100 STD_WARENM"		GCol="text,WARENM">거점명</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<div class="btn_lit tableUtil">
						<button type='button' GBtn="find"></button>
						<button type='button' GBtn="sortReset"></button>
						<button type='button' GBtn="layout"></button>
						<button type='button' GBtn="total"></button>
						<button type='button' GBtn="excel"></button>
						<button type='button' GBtn="subTotal"></button>
						<span class='txt_total' >총 건수 : <span GInfoArea='true'>0</span></span>
					</div>
				</div>
			</div>
			
			<div class="content_layout tabs bottom_layout">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span CL="STD_DETAILLIST">상세리스트</span></a></li>
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
								<tbody id="gridListSub">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="40" GBtnCheck="true" GCol="rowCheck"></td>
										<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="100" GCol="text,STOR_LOC_CD" style="text-align:center;">저장위치코드</td>

										<td GH="100" GCol="text,IND_BCD" style="text-align:center;">개별바코드</td>
										<td GH="100" GCol="text,LOC_CD" style="text-align:center;">로케이션코드</td>
										<td GH="100" GCol="text,MACH_CD" style="text-align:center;">설비코드</td>
										<td GH="100" GCol="text,MACHINE" style="text-align:center;">생산호기</td>
										
										<td GH="100" GCol="text,LOT_NO" style="text-align:center;">LOT번호</td>
										<td GH="130" GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH="90" GCol="text,STCK_QTY" style="text-align:right;" GF="N 13,2">재고</td>
										<td GH="100" GCol="text,UNIT" style="text-align:center;">재고단위</td>
										<td GH="100" GCol="text,STCK_STA" style="text-align: center;">재고상태</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<div class="btn_lit tableUtil">
						<button type='button' GBtn="find"></button>
						<button type='button' GBtn="sortReset"></button>
						<button type='button' GBtn="layout"></button>
						<button type='button' GBtn="total"></button>
						<button type='button' GBtn="excel"></button>
						<button type='button' GBtn="subTotal"></button>
						<span class='txt_total' >총 건수 : <span GInfoArea='true'>0</span></span>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- //content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>