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
	$(document).ready(function() {
		gridList.setGrid({
	    	id : "gridList",
	    	url : "/mes/Work/WRK39/json/datalist.data",
	    	bigdata : false
	    });
	});

	// 조회
	function searchList() {
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			
			param.put("P_TYPE","LIST");
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}
	
	// 버튼 클립(조회)
	function commonBtnClick(btnName) {
		if(btnName == "Search") {
			searchList();
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
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_MATNR"></dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 자재코드 RANGE 검색 추가 -->
							<input type="text" class="input" name="INV001.MATNR" id="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					
					<dl>
						<dt CL="STD_PCODE">지종코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 지종코드 RANGE 검색 추가 -->
							<input type="text" name="MAS001.PCODE" UIInput="SR,PCODE" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_BS_WGT">평량</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 지종코드 RANGE 검색 추가 -->
							<input type="text" name="MAS001.BS_WGT" UIInput="SR" UIFormat="U" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_WLEN">가로</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 가로 RANGE 검색 추가 -->
							<input type="text" name="WLEN" class="input" IAname="WRK002.WLEN" UIInput="SR" UIFormat="U"/>
						</dd>
					</dl>
					<!-- <dl>
						<dt CL="STD_VLEN">세로</dt>
						<dd>
							2023-03-13(월요일) 안상현, 세로 RANGE 검색 추가
							<input type="text" name="WRK002.VLEN" class="input" IAname="VLEN" UIInput="SR" UIFormat="U"/>
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
					<li><a href="#tab1-1"><span CL="STD_GRD_WRK39">리스트</span></a></li>
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
										<td GH="0" GCol="text,STOR_LOC_CD" style="text-align:center;">저장위치코드</td>
										
										<td GH="140" GCol="text,WRHS_RCV_DATE" style="text-align:center;"></td>
										<td GH="130" GCol="text,MATNR" style="text-align:center;"></td>
										<td GH="250" GCol="text,MATNR_NM" style="text-align:left;"></td>
										<td GH="100" GCol="text,LOT_NO" style="text-align:center;"></td>
										<td GH="140" GCol="text,IND_BCD" style="text-align:center;"></td>
										<td GH="90" GCol="text,ROLLCNT" style="text-align:right;" GF="N 6">권치수</td>
										<td GH="100" GCol="text,ROLLUNIT" style="text-align:center;">권치수단위</td>
										
										<!-- <td GH="90" GCol="text,PCNT" style="text-align:right;" GF="N 13,2"></td> -->
										<td GH="90" GCol="text,WGT" style="text-align:right;" GF="N 13,2"></td>
										<td GH="100" GCol="text,WUNIT" style="text-align:center;">중량단위</td>
										
										<td GH="90" GCol="text,PRD_PRFM_DT" style="text-align:center;" GF="D"></td>
										<td GH="140" GCol="text,PRD_MACH_NM" style="text-align:left;"></td>
										
										<td GH="100" GCol="text,WRKNM" style="text-align:left;"></td>
										<td GH="130" GCol="text,PRD_NO" style="text-align:center;"></td>
										<td GH="90" GCol="text,DOMESTIC" style="text-align:center;"></td>
										<td GH="90" GCol="text,PCODE" style="text-align:center;"></td>
										<td GH="110" GCol="text,PCODE_NM" style="text-align:left;"></td>
										<td GH="90" GCol="text,BS_WGT" style="text-align:right;" GF="N 9,2"></td>
										<td GH="90" GCol="text,WLEN" style="text-align:right;" GF="N 4"></td>
										<!-- <td GH="90" GCol="text,VLEN" style="text-align:right;" GF="N 4"></td> -->
										<td GH="90" GCol="text,ORDR_WIDTH" style="text-align:right;" GF="N 4"></td>
										<td GH="90" GCol="text,PRD_WIDTH" style="text-align:right;" GF="N 13,2"></td>
										<td GH="90" GCol="text,PACKTYPE" style="text-align:center;"></td>
										
										<td GH="100 거래처코드" GCol="text,KUNNR" style="text-align:center;">거래처</td>
										<td GH="140" GCol="text,KUNNR_NM" style="text-align:left;"></td>
										
										<td GH="90" GCol="text,NTN_NM" style="text-align:center;"></td>
										<td GH="90" GCol="text,VBELN" style="text-align:center;"></td>
										<td GH="130" GCol="text,WRK_ORDR_REMARK" style="text-align:left;"></td>
										
                                        <td GH="100" GCol="text,JR_LOT_NO" style="text-align:center;">점보롤 LOTNO</td>
                                        <td GH="100" GCol="text,JR_IND_BCD" style="text-align:center;">점보롤 개별바코드</td>
                                        <td GH="130" GCol="text,ORDER_RMK" style="text-align:left;">오더 비고</td>
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