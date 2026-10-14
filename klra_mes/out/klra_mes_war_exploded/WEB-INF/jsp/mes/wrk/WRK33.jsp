<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>MES</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function() {
		gridList.setGrid({
	    	id : "gridList",
	    	url : "/mes/Work/WRK33/json/datalist.data",
	    	bigdata : false
	    });
		
		gridList.setGrid({
	    	id : "gridListSub1",
	    	url : "/mes/Work/WRK33/json/datalist.data",
	    	bigdata : false
	    });
	});
	
	function searchList() {
		if(validate.check("searchArea")){
			const range = inputList.setRangeParam("searchArea")
/* 			const range_data_param = range.get("RANGE_DATA_PARAM")
			const prfm_dt = range_data_param.get("A.PRFM_DT_Range")
			const date = prfm_dt.split("↓")
			const SDate = date[1]
			const EDate = date[2]
			 */
			const param = inputList.setRangeParam("searchArea")
			param.put("P_TYPE", "LIST")
			
			gridList.gridList({
				id : "gridList",
				param : param
			});
		}
	}
	
	function commonBtnClick(btnName) {
		if(btnName == "Search") {
			searchList();
		}
	}
	
	function gridListEventRowDblclick(gridId, rowNum, colName) {
		if (gridId != 'gridList') return;
		
		if (!validate.check("searchArea")) return;
		
		var param = inputList.setRangeParam("searchArea");
/* 		param.map.WERKS = gridList.getRowData('gridList', gridList.getFocusRowNum('gridList') ).map.WERKS;
		param.map.MACH_CD = gridList.getRowData('gridList', gridList.getFocusRowNum('gridList') ).map.MACH_CD; */
		param.map.PROC_NM = gridList.getRowData('gridList', gridList.getFocusRowNum('gridList') ).map.PROC_NM;
		param.map.VBELN = gridList.getRowData('gridList', gridList.getFocusRowNum('gridList') ).map.VBELN;
		param.map.PRFM_DT = gridList.getRowData('gridList', gridList.getFocusRowNum('gridList') ).map.PRFM_DT;
		param.map.MATNR = gridList.getRowData('gridList', gridList.getFocusRowNum('gridList') ).map.MATNR;
		
		param.put("P_TYPE","SUB_LIST1");
		gridList.gridList({
			id : "gridListSub1",
			param : param
		});
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
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					
					<dl>
						<dt CL="STD_VBELN">판매문서번호</dt>
						<dd>
							<input type="text" class="input" id="VBELN" name="VBELN" UIInput="SR" validate='required'/>
						</dd>
					</dl>
					
<!-- 					<dl>
						<dt CL="STD_PRFM_DT">실적일자</dt>
						<dd>
							<input type="text" id="PRFM_DT" name="PRFM_DT" UIInput="B" UIFormat="C M1"/>
						</dd>
					</dl>
					
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							2023-03-13(월요일) 안상현, 자재코드 RANGE 검색 추가
							<input type="text" class="input" id="MATNR" name="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl> -->
					
					<!-- 2023-03-13(월요일) 안상현, 판매문서번호, 견적문서품목번호 삭제
					<dl>
						<dt CL="STD_VBELN"></dt>
						<dd>
							<input type="text" class="input" name="VBELN" validate="required"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_OPOSNR"></dt>
						<dd>
							<input type="text" class="input" name="OPOSNR"/>
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
					<li><a href="#tab1-1"><span CL="STD_GRD_WRK33_1">리스트</span></a></li>
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
										<td GH="100" GCol="text,VBELN" style="text-align:center;">판매문서번호</td>
										<td GH="140" GCol="text,POSNR" style="text-align:center;">판매문서품목번호</td>
										<td GH="100" GCol="text,PROC_NM" style="text-align:left;">공정명</td>
										<td GH="100" GCol="text,PRFM_DT" style="text-align:center;" GF="D">실적일자</td>
										
										<td GH="100" GCol="text,ROLLCNT" style="text-align:right;" GF="N 6"></td>
										<td GH='80' GCol='text,ROLLUNIT' style="text-align:center;">권치수단위</td>
										<td GH="100 연수" GCol="text,PCNT" style="text-align:right;" GF="N 13,2"></td>
										<td GH='80' GCol='text,RUNIT' style="text-align:center;">연수단위</td>
										<td GH="100" GCol="text,WGT" style="text-align:right;" GF="N 13,3"></td>
										<td GH='80' GCol='text,WUNIT' style="text-align:center;">중량단위</td>
										<td GH="100" GCol="text,DISPO_ROLLCNT" style="text-align:right;" GF="N 6"></td>
										<td GH='100' GCol='text,DIROLLUNIT' style="text-align:center;">폐품권치수단위</td>
										<td GH="100" GCol="text,DISPO_PCNT" style="text-align:right;" GF="N 13,2"></td>
										<td GH='80' GCol='text,DISPO_RUNIT' style="text-align:center;">폐품연수단위</td>
										<td GH="100" GCol="text,DISPO_WGT" style="text-align:right;" GF="N 13,3"></td>
										<td GH='80' GCol='text,DISPO_WUNIT' style="text-align:center;">폐품중량단위</td>
										<td GH="140" GCol="text,MATNR" style="text-align:center;"></td>
										<td GH="100" GCol="text,PCODE" style="text-align:center;"></td>
<!-- 										<td GH="110" GCol="text,PCODE_NM" style="text-align:left;"></td> -->
										<td GH="100" GCol="text,BS_WGT" style="text-align:right;"></td>
										<td GH="140" GCol="text,SPEC" style="text-align:center;">규격</td>
										<td GH="130" GCol="text,CUST_NM" style="text-align:left;">거래처명</td>
										<td GH="100" GCol="text,ROUTE" style="text-align:right;">항차</td>
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
					<li><a href="#tab1-2"><span CL="STD_GRD_WRK33_2">상세</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-2">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridListSub1">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="100" GCol="text,PROC_NM" style="text-align:left;">공정명</td>
										<td GH="100" GCol="text,IND_BCD" style="text-align:center;"></td>
										<td GH="100" GCol="text,LOT_NO" style="text-align:center;">LOT_NO</td>
										<td GH="100" GCol="text,WRK_DATE" style="text-align:center;">작업일시</td>
										<td GH="100" GCol="text,STA" style="text-align:center;">상태</td>
										<td GH="120" GCol="text,MACH_NM" style="text-align:left;">설비명</td>
										<td GH="100" GCol="text,ROLLCNT" style="text-align:right;" GF="N 6"></td>
										<td GH='80' GCol='text,ROLLUNIT' style="text-align:center;">권치수단위</td>
										<td GH="100 연수" GCol="text,PCNT" style="text-align:right;" GF="N 13,2"></td>
										<td GH='80' GCol='text,RUNIT' style="text-align:center;">연수단위</td>
										<td GH="100" GCol="text,WGT" style="text-align:right;" GF="N 13,3"></td>
										<td GH='80' GCol='text,WUNIT' style="text-align:center;">중량단위</td>
										<td GH="100" GCol="text,CREDAT" style="text-align:center;" GF="D">생성일자</td>
										<td GH="100" GCol="text,WRKNM" style="text-align:left;"></td>
										<td GH="100" GCol="text,DISPO_ROLLCNT" style="text-align:right;" GF="N 6"></td>
										<td GH='100' GCol='text,DIROLLUNIT' style="text-align:center;">폐품권치수단위</td>
										<td GH="100" GCol="text,DISPO_PCNT" style="text-align:right;" GF="N 13,2"></td>
										<td GH='80' GCol='text,DISPO_RUNIT' style="text-align:center;">폐품연수단위</td>
										<td GH="100" GCol="text,DISPO_WGT" style="text-align:right;" GF="N 13,3"></td>
										<td GH='80' GCol='text,DISPO_WUNIT' style="text-align:center;">폐품중량단위</td>
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