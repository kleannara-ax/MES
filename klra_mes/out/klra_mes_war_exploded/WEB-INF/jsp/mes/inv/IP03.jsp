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
			name : "gridList",
			module : "Inv",
			command : "PHYDH",
			editable : false,
			itemGrid : "gridListSub",
			itemSearch : true
		});
		
		gridList.setGrid({
			id : "gridListSub",
			name : "gridListSub",
			module : "Inv",
			command : "PHYDI",
			editable : false,
		});
		
		initSearchArea();
	});
	
	function initSearchArea() {
		//uiList.setActive("PrintPhydList", false);
		//uiList.setActive("PrintGapList", false);
	}
	
	function comboEventDataBindeBefore(comboAtt){
		if (false) {
			if(comboAtt == "Wms,PLNTKYCOMBO"){
				var param = new DataMap();
				param.put("WAREKYS", "'<%=wareky%>'");
				param.put("OWNRKY", "<%=ownrky%>");
				param.put("LANGKY", "<%=langky%>");
				return param;
			} else if(comboAtt == "airfw,COMCOMBO"){
				var param = new DataMap();
				param.put("CODE", 'SKUL01');
				return param;
			}
		}
	}
	
	function commonBtnClick(btnName){
		if (btnName == "Search"){
			searchList();
		}
	}
	
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			param.put("WAREKY", "<%=wareky%>");
			param.put("OWNRKY", "<%=ownrky%>");
			param.put("LANGKY", "<%=langky%>");
			
			gridList.gridList({
				id : "gridList",
				param : param
			});
		}
	}

	function gridListEventDataBindEnd(gridId, dataCount){
		if(gridId == "gridList" && dataCount > 0){
			gridListEventRowDblclick(gridId, 0);
			
			// 버튼 활성화
			//uiList.setActive("PrintPhydList", true);
			//uiList.setActive("PrintGapList", true);
		}
		else if (gridId == "gridListSub" && dataCount > 0) {
			
			var list = gridList.getGridData(gridId);
			var INSP_CNT = 0;
			
			for(var i=0; i < list.length; i++) {
				var REAL_INSP_QTY = list[i].get("REAL_INSP_QTY");

				if( REAL_INSP_QTY > 0){
					INSP_CNT++;
				}
			}

			if (INSP_CNT) {
				$("#insp_cnt").text(INSP_CNT + " / " + $("#insp_cnt").text())
			}
		}
		//gridList.setReadOnly("gridList", true);
		gridList.setReadOnly("gridList", true, ['INDDCL']);
		gridList.setReadOnly("gridListSub", true);
	}
	
	function gridListEventRowDblclick(gridId, rowNum, colName, colValue){
		if (gridId == "gridList"){
			gridList.resetGrid("gridListSub");
			
			var param = inputList.setRangeParam("searchArea");
			param.put("LANGKY","<%=langky%>");
			param.put("PHYIKY", gridList.getColData(gridId, rowNum, "PHYIKY"));
			
			gridList.gridList({
				id : "gridListSub",
				param : param
			});
		}
	}
	
	function printPhydList(){
	}
	
	function printGapList(){
	}
	
	function searchHelpEventOpenBefore(searchCode, gridType, $inputObj){
	}
	
	function gridListEventItemGridSearch(gridId, rowNum, itemGridList){
	    if(gridId == "gridList"){
	        gridListEventRowDblclick(gridId, rowNum);
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
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap">
					<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" id="WERKS" name="PI.LOTA02" UIInput="S,PLANT" UIFormat="U" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_STOR_LOC_CD">저장위치코드</dt>
						<dd>
							<input type="text" class="input" id="STOR_LOC_CD" name="PI.LOTA01" UIInput="SR,LOC" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_CREDAT">생성일자</dt>
						<dd>
							<input type="text" class="input" name="PH.DOCDAT" UIInput="R" UIFormat="C -7 N" validate="required"/>
						</dd>
					</dl>
					<!-- 
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<input type="text" name="PI.SKUKEY" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PHYIKY">재고실사번호</dt>
						<dd>
							<input type="text" class="input" name="PH.PHYIKY" UIInput="R" />
						</dd>
					</dl>
					 -->
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
										<td GH="40" GCol="rowCheck" GBtnCheck="true" ></td>
										<td GH="100 STD_PHYIKY"		GCol="text,PHYIKY"				>재고실사번호</td>
										<td GH="100 STD_CREDAT"		GCol="text,DOCDAT" GF="C 8"		>전기일자</td>
										<td GH="80 STD_DOCCAT"		GCol="text,DOCCAT"				>문서카테고리</td>
										<td GH="100 STD_DOCCATNM"	GCol="text,DOCCATNM"			>문서카테고리명</td>
										<td GH="80 STD_DOCUTY"		GCol="text,DOCUTY"				>문서유형</td>
										<td GH="180 STD_DOCUTYNM"	GCol="text,DOCUTYNM"			>문서유형명</td>
										<td GH="200 STD_WRK_ORDR_RMK"		GCol="text,DOCTXT"	GF="S 1000"	>비고</td>
										<td GH="80 STD_WAREKY"		GCol="text,WAREKY"				>거점</td>
										<td GH="100 STD_WARENM"		GCol="text,WARENM"				>거점명</td>
										<td GH="100 STD_CREDAT"		GCol="text,CREDAT"	GF="D"		>생성일자</td>
										<td GH="100 STD_CRETIM"		GCol="text,CRETIM"	GF="T"		>생성시간</td>
										<td GH="100 STD_USERID"		GCol="text,CREUSR"				>생성자ID</td>
										<td GH="100 STD_CUSRNM"		GCol="text,CUSRNM"				>생성자명</td>
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
										<td GH="100 STD_PHYIIT"			GCol="text,PHYIIT"				>재고실사번호	</td>
										<td GH="100 STD_WERKS"			GCol="text,LOTA02"				>플랜트		</td>
										<td GH="100 STD_STOR_LOC_CD"	GCol="text,LOTA01"				>저장위치		</td>
										<td GH="100 STD_STOR_LOC_CD"	GCol="text,LOCAKY"				>로케이션		</td>
										<td GH="100 STD_LOT_NO"			GCol="text,LOTA15"				>LOT번호		</td>
										<td GH="100 STD_IND_BCD"		GCol="text,LOTA14"				>LOT번호		</td>
										<td GH="150 STD_MATNR"			GCol="text,SKUKEY"				>품목코드		</td>
										<td GH="100 STD_STCK_QTY"		GCol="text,QTSIWH"		GF="N 13,1">재고수량	</td>
										<td GH="100" 					GCol="text,REAL_INSP_QTY" GF="N 13,1">실사수량 </td>
										<td GH="100" 					GCol="text,PI_GAP_YN" 			>실사차이여부	</td>
										<td GH="100 STD_INP_QTY" 		GCol="text,PRE_IN_QTY"	GF="N 13,1">투입수량	</td>
										<td GH="100" 					GCol="text,USE_QTY" 	GF="N 13,1">사용수량	</td>
										<td GH="100 STD_WASTE04_QTY"	GCol="text,WASTE04_QTY" GF="N 13,1">폐품(가공)	</td>
										<td GH="100 STD_WASTE22_QTY"	GCol="text,WASTE22_QTY" GF="N 13,1">폐품(영업, 잔량)</td>
										<td GH="100 STD_UNIT"			GCol="text,UOMKEY"				>단위			</td>
										<td GH="100 STD_STKAMT"			GCol="text,STKAMT"		GF="N 20">금액		</td>
										<td GH="100 STD_STCK_STA" 		GCol="text,LOTA06"				>재고상태		</td>
										<td GH="100 STD_MACHINE"		Gcol="text,LOTA04"				>호기			</td>
										<td GH="100 STD_CREDAT"			GCol="text,CREDAT"		GF="D"	>생성일자		</td>
										<td GH="100 STD_CRETIM"			GCol="text,CRETIM"		GF="T"	>생성시간		</td>
										<td GH="100 STD_USERID"			GCol="text,CREUSR"				>생성자명		</td>
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
						<span class='txt_total' >실사완료 / 총 건수 : <span GInfoArea='true' id='insp_cnt'>0</span></span>
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