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
	    	url : "/mes/Work/WRK38/json/datalist.data",
	    	bigdata : false
	    });
	});

	// 조회
	function searchList() {
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea")
			param.put("P_TYPE","LIST")
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}
	
	
	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "Produce,MACHINE"){
			var param = new DataMap();
			
			param.put("WERKS", 'P100');
		}
		return param;
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
<!-- 					<dl>
						<dt CL="STD_WRHS_RCV_DATE">창고입고일시</dt>
						<dd>
							<input type="text" id="WRHS_RCV_DATE" name="WRHS_RCV_DATE" UIInput="B" UIFormat="C M1"/>
						</dd>
					</dl> -->
					
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 자재코드 RANGE 검색 추가 -->
							<input type="text" class="input" name="MATNR" id="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					
					<dl>
						<dt CL="STD_STOR_LOC_CD">저장위치코드</dt>
						<dd>
							<input type="hidden" id="WERKS" name="WERKS" value="P100" />
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
							<!-- 2023-03-13(월요일) 안상현, 설비코드 RANGE 검색 추가 -->
							<input type="text" id="MACH_CD" name="MACH_CD" UIInput="SR,MACH" UIFormat="U"/>
						</dd>
					</dl>
					
					<dl>
						<dt CL="STD_IND_BCD">개별바코드</dt>
						<dd>
							<input type="text" class="input" id="IND_BCD" name="IND_BCD" UIInput="SR,INDBCD" UIFormat="U" />
						</dd>
					</dl>
					
					<dl>
						<dt CL="STD_PCODE">지종코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 지종코드 RANGE 검색 추가 -->
							<input type="text" class="input" id="PCODE" name="PCODE" UIInput="SR,PCODE" UIFormat="U"/>
						</dd>
					</dl>
					
					<dl>
						<dt CL="STD_BS_WGT">평량</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 평량 RANGE 검색 추가 -->
							<input type="text" id="BS_WGT" name="BS_WGT" class="input" UIInput="SR" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_WIDTH">지폭</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 지폭(가로) RANGE 검색 추가 -->
							<input type="text" id="WIDTH" name="WIDTH" class="input" IAname="WLEN" UIInput="SR"/>
						</dd>
					</dl>
					
					<dl>
						<dt CL="STD_MACHINE">생산호기</dt>
						<dd>
							<select class="input" id="MACHINE" name="MACHINE" Combo="Produce,MACHINE">
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
					<li><a href="#tab1-1"><span CL="STD_GRD_WRK38">리스트</span></a></li>
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
										<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="130" GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH="250" GCol="text,MATNR_NM" style="text-align:left;">자재명</td>
										<td GH="100" GCol="text,LOT_NO" style="text-align:center;">LOT번호</td>
										<td GH="140" GCol="text,IND_BCD" style="text-align:center;">개별바코드</td>
										<td GH="130" GCol="text,PRD_NO" style="text-align:center;">생산번호</td>
										<td GH="100" GCol="text,STOR_LOC_CD" style="text-align:center;">저장위치코드</td>
										<td GH="100" GCol="text,STOR_LOC_CD_NM" style="text-align:center;">저장위치명</td>
										<td GH="100" GCol="text,LOC_CD" style="text-align:center;">로케이션코드</td>
										<td GH="150" GCol="text,LOC_CD_NM" style="text-align:center;">로케이션명</td>
										
										<td GH="90" GCol="text,STCK_QTY" style="text-align:right;" GF="N 13,2">재고</td>
										<td GH="100" GCol="text,STCKUNIT" style="text-align:center;">재고단위</td>
										
										<td GH="90" GCol="text,ROLLCNT" style="text-align:right;" GF="N 13,2">권치수</td>
										<td GH="100" GCol="text,ROLLUNIT" style="text-align:center;">권치수단위</td>
										
										<td GH="90" GCol="text,WGT" style="text-align:right;" GF="N 13,2"></td>
										<td GH="100" GCol="text,WUNIT" style="text-align:center;">중량단위</td>
										
										<td GH="90" GCol="text,DOMESTIC" style="text-align:center;">내수구분</td>
										<td GH="90" GCol="text,PCODE" style="text-align:center;">지종코드</td>
										<td GH="110" GCol="text,PCODE_NM" style="text-align:left;">지종명</td>
										<td GH="90" GCol="text,BS_WGT" style="text-align:right;">평량</td>
										<td GH="90" GCol="text,WLEN" style="text-align:right;">가로길이</td>
										<td GH="90" GCol="text,VLEN" style="text-align:right;">세로길이</td>
										<td GH="90" GCol="text,O_WIDTH" style="text-align:right;">(지시)실지폭</td>
										<td GH="90" GCol="text,P_WIDTH" style="text-align:right;">(생산)실지폭</td>
										<td GH="90" GCol="text,PACKTYPE" style="text-align:center;">포장방식</td>
										<td GH="90" GCol="text,PRFM_DT" style="text-align:center;" GF="D">실적일자</td>
										<td GH="150 창고입고일시" GCol="text,REGDATE" style="text-align:center;">창고입고일시</td>
										<td GH="100" GCol="text,STCK_STA" style="text-align: center;">재고상태</td>
										
										<td GH="100" GCol="text,MACH_CD" style="text-align: center;">설비코드</td>
										<td GH="150" GCol="text,MACH_NM" style="text-align:center;">설비명</td>
										
										<td GH="90" GCol="text,VBELN" style="text-align:center;">판매문서번호</td>
										<td GH="100" GCol="text,POSNR" style="text-align: center;">판매문서 품목번호</td>
										<td GH="140" GCol="text,KUNNR_NM" style="text-align:left;">거래처명</td>
										<td GH="90" GCol="text,NTN_NM" style="text-align:center;">국가명</td>
										<td GH="100" GCol="text,WRKNM" style="text-align:left;">작업자</td>
											
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="1" />
						<jsp:param name="showAuthCd" value="1,2,7,9,10" />
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