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
			url : "/mes/Produce/SCH03/json/datalist.data",
			bigdata : false,
			colHoldType : true,
            colHold : "WERKS,SDATE,AUFNR,SEQ",
            colorType : true
		});
		
 		gridList.setGrid({
			id : "gridListSub",
	    	url : "/mes/Produce/SCH03/json/datalist.data",
	    	bigdata : false,
	    	colHoldType : true,
            colHold : "AUFNR,POSNR"
	    });
 		$("#WERKS").val('P500');
	});

	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "Produce,MACHINE"){
			var param = new DataMap();
			
			param.put("WERKS", 'P500');
		}
		return param;
	}

	// 조회(HEADER)
	function searchList(){
		if(validate.check("searchArea")){
			gridList.resetGrid("gridListSub")
			
			var param = inputList.setRangeParam("searchArea");
			param.put("P_TYPE","LIST");
			
			gridList.gridList({
				id : "gridList",
				param : param
			});
		}
	}
	
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
		}
	}
	
	// 행 더블 클릭
	function gridListEventRowDblclick(gridId, rowNum){
		if(gridId === "gridList") searchSubList(gridId, rowNum)
	}
	
	// 조회(ITEM)
	function searchSubList(gridId, rowNum){
		var param = inputList.setRangeParam("searchArea");
		param.put("P_TYPE", "SUB_LIST");
		param.put("AUFNR", gridList.getColData(gridId, rowNum, "AUFNR"));			
		
		gridList.gridList({
			id : "gridListSub",
			param : param
		});
	}
	
	// 2022-10-19(수요일) 안상현, 삭제구분이 "삭제"인 경우, 라인 오렌지
 	function gridListRowColorChange(gridId, rowNum, rowData){
		if(gridId === "gridList" && rowData.get("DELETEGBN") === "삭제"){
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
					<input type="button" id="button-1" CB="Search SEARCH BTN_SEARCH" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap">
				  	<dl>
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>							
							<input type="text" class="input" id="WERKS" name="WERKS"  readonly="readonly"/>
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
						<dt CL="STD_SDATE">생산요청일자</dt>
                        <dd><input type="text" id="SDATE" name="SDATE" UIInput="B" UIFORMAT="C M1"/></dd>
					</dl>
					<dl>
						<dt CL="STD_AUFNR">오더번호</dt>
						<dd>
							<input type="text" class="input" id="AUFNR" name="AUFNR" UIInput="SR" UIFormat="U" />
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
							<table class="table_b">
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="100" GCol="text,WERKS" style="text-align: center;">플랜트</td>
										<td GH="100" GCol="text,SDATE" GF="C" style="text-align:center;">생산요청일</td>
										<td GH="150" GCol="text,AUFNR" style="text-align:center;">오더번호</td>
										<td GH="80" GCol="text,SEQ" GF="N 10">작업순서</td>
										<td GH="100" GCol="text,AUART">오더유형</td>
										<td GH="200" GCol="text,ORDER_DIV_NM">오더유형 텍스트</td>
										<td GH="200" GCol="text,MATNR" style="text-align: center;">자재코드</td>
										<td GH="300" GCol="text,MATNR_NM">자재명</td>
										<td GH="100" GCol="text,FQTY" GF="N 10">오더량</td>
										<td GH="150" GCol="text,MEINS">오더단위</td>
										<td GH="100" GCol="text,ARBPL">Work Center</td>
										<td GH="100" GCol="text,AENAM">작업지시자</td>
										<td GH="100" GCol="text,MACHINE" style="text-align: center;">생산호기</td>
										<td GH="200" GCol="text,BOM_NO">BOM Num</td>
										<td GH="200" GCol="text,ATN_BOM_NO">대체BOM</td>
										<td GH="100" GCol="text,BMENG" GF="N 10">모품목기준수량</td>
										<td GH="100" GCol="text,BMEIN" style="text-align: center;">모품목기준수량단위</td>
										<td GH="100" GCol="text,START_DATE" GF="C" style="text-align:center;">릴리즈일자</td>
										<td GH="100" GCol="text,END_DATE" GF="C" style="text-align:center;">생산종료일자</td>
										<td GH="150" GCol="text,DLFL">오더 삭제 지시자</td>
										<td GH="300" GCol="text,RMK">비고</td>
										<td GH="80" GCol="text,DELETEGBN" style="text-align: center;">삭제구분</td>
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
						<jsp:param name="showAuthCd" value="1,2,3,7,9,10" />
					</jsp:include>						
				</div>
			</div>
			<div class="content_layout tabs bottom_layout">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span>오더 BOM</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-1" >
					<div class="table_list01">
						<div class="scroll">
							<table class="table_b">
								<tbody id="gridListSub">
									<tr CGRow="true">
										<td GH="0" GCol="text,AUFNR" style="text-align:center;">오더번호</td>
										<td GH="100" GCol="text,POSNR" style="text-align:center;">오더Item번호</td>
										<td GH="200" GCol="text,MATNR" style="text-align: center;">자재코드</td>
										<td GH="300" GCol="text,MATNR_NM">자재명</td>
										<td GH="100" GCol="text,BDMNG" GF="N 10">오더BOM수량(기준정보)</td>
										<td GH="150" GCol="text,MEINS" style="text-align: center;">오더BOM단위(기준정보)</td>
										<td GH="150" GCol="text,MEINS_NM">오더BOM단위(명)</td>
										<td GH="0" GCol="text,BMENG" GF="N 10">BOM 수량</td>
										<td GH="0" GCol="text,BMEIN" style="text-align:center;">BOM 수량단위</td>
										<td GH="0" GCol="text,UNIT_NM" style="text-align:center;">BOM 수량단위 (명)</td>
										<td GH="100" GCol="text,LGORT" style="text-align:center;">저장위치</td>
										<td GH="100" GCol="text,STOR_LOC_NM">저장위치명</td>
										<td GH="100" GCol="text,DELETEYN" style="text-align:center;">삭제여부</td>								
										<td GH="150" GCol="text,REGDATE" style="text-align:center;">등록일시</td>
										<td GH="100" GCol="text,REGNM">등록자</td>
										<td GH="150" GCol="text,UPDDATE" style="text-align:center;">수정일시</td>
										<td GH="100" GCol="text,UPDNM">수정자</td>
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
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>