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
	    	url : "/mes/Work/WRK31/json/datalist.data",
	    	bigdata : false
	    });
	});
	
	function comboEventDataBindeBefore(comboAtt) {
		if(comboAtt == "Produce,MACHINE"){
			var param = new DataMap();
			param.put("WERKS", 'P100');
		}
		return param;
	}
	
	
	function searchList() {
		if(validate.check("searchArea")) {
			// 2023-03-13(월요일) 안상현, RANGE 검색 추가
			const range = inputList.setRangeParam("searchArea")
			const range_data_param = range.get("RANGE_DATA_PARAM")
			const prfm_dt = range_data_param.get("PRFM_DT_Range")
			const date = prfm_dt.split("↓")
			const SDate = date[1]
			const EDate = date[2]
			
			const param = inputList.setRangeParam("searchArea")
			param.put("P_TYPE", "LIST")
			param.put("SDATE", SDate)
			param.put("EDATE", EDate)
			param.put("MACHINE", $("#MACHINE").val()) // 생산호기
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    })
		}
	}
	
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
						<dt CL="STD_PRFM_DT">실적일자</dt>
						<dd>
							<input type="text" class="input" id="PRFM_DT" name="PRFM_DT" UIInput="B" UIFormat="C M1" />
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
					<dl>
						<dt CL="STD_PROC_CD">공정</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 공정 RANGE 검색 추가 -->
							<input type="text" id="PROC_CD" name="PROC_CD" UIInput="SR,OP" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PCODE">지종코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 지종코드 RANGE 검색 추가 -->
							<input type="text" id="PCODE" name="PCODE" UIInput="SR,PCODE" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_BS_WGT">평량</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 평량 RANGE 검색 추가 -->
							<input type="text" id="BS_WGT" name="BS_WGT" UIInput="SR" UIFormat="U" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_WIDTHW">가로</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 가로 RANGE 검색 추가 -->
							<input type="text" id="WLEN" name="WLEN" class="input" IAname="WLEN" UIInput="SR" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_WIDTHH">세로</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 세로 RANGE 검색 추가 -->
							<input type="text" id="VLEN" name="VLEN" class="input" IAname="VLEN" UIInput="SR" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_NATNKY">국가</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 국가 RANGE 검색 추가 -->
							<input type="text" id="NTN_NM" name="NTN_NM" class="input" IAname="NTN_NM" UIInput="SR" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_ROUTE">항차</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 국가 RANGE 검색 추가 -->
							<input type="text" id="ROUTE" name="ROUTE" class="input" IAname="ROUTE" UIInput="SR" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_BARCOD">바코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 개별바코드 RANGE 검색 추가 -->
							<input type="text" id="IND_BCD" name="IND_BCD" class="input" IAname="IND_BCD" UIInput="SR,INDBCD" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_LOT_NO">LOT_NO</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, LOT번호 RANGE 검색 추가 -->
							<input type="text" id="LOT_NO" name="LOT_NO" class="input" IAname="LOT_NO" UIInput="SR" UIFormat="U"/>
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
					<li><a href="#tab1-1"><span CL="STD_GRD_WRK31">일반</span></a></li>
					<li class="btn_zoom_wrap">
						<ul> 
							<!-- <li><button class="btn btn_smaller"><span>축소</span></button></li> -->
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
										<td GH="90" GCol="text,PROC_NM" style="text-align:left;">공정명</td>
										<td GH="90" GCol="text,MACHINE" style="text-align:center;">호기</td>
										<td GH="120" GCol="text,MACH_NM" style="text-align:left;">설비명</td>
										<td GH="90" GCol="text,PRFM_DT" style="text-align:center;" GF="D">실적일자</td>
										<td GH="70" GCol="text,WRK_CLASS" style="text-align:right;">반</td>
										<td GH="100" GCol="text,LOT_NO" style="text-align:center;">LOT_NO</td>
										<td GH="140" GCol="text,IND_BCD" style="text-align:center;"></td>
										
										<td GH="140" GCol="text,MATNR" style="text-align: center;">자재코드</td>
										<td GH="320" GCol="text,MATNR_NM">자재명</td>
										
										<td GH="70" GCol="text,DOMESTIC" style="text-align:center;"></td>
										<td GH="90" GCol="text,PCODE" style="text-align:center;"></td>
										<td GH="110" GCol="text,PCODE_NM" style="text-align:left;"></td>
										<td GH="90" GCol="text,BS_WGT" style="text-align:right;"></td>
										<td GH="90" GCol="text,WLEN" style="text-align:right;"></td>
										<td GH="90" GCol="text,WIDTH" style="text-align:right;"></td>
										<td GH="90" GCol="text,WIDTH_NO" style="text-align:right;"></td>
										<td GH="90" GCol="text,VLEN" style="text-align:right;"></td>
										<td GH="90" GCol="text,CORE" style="text-align:right;"></td>
										<!-- <td GH="90" GCol="text,PACKTYPE_1" style="text-align:center;"></td> -->
										
										<td GH="90" GCol="text,PRFM_ROLLCNT" style="text-align:right;" GF="N 6"></td>
										<td GH="80" GCol="text,ROLLUNIT" style="text-align: center;">권치수단위</td>
										
										<td GH="90" GCol="text,PRFM_PCNT" style="text-align:right;" GF="N 13,2"></td>
										<td GH="80" GCol="text,RUNIT" style="text-align: center;">연수단위</td>
										
										<td GH="90" GCol="text,PRFM_WGT" style="text-align:right;" GF="N 13,2"></td>
										<td GH="80" GCol="text,WUNIT" style="text-align: center;">중량단위</td>
										
										<td GH="90" GCol="text,DISPO_CD" style="text-align:center;"></td>
										<td GH="90" GCol="text,DISPO_CAUSE" style="text-align:left;"></td>
										<td GH="90" GCol="text,DISPO_ROLLCNT" style="text-align:right;" GF="N 6"></td>
										<td GH='100' GCol='text,DISPO_ROLLUNIT' style='text-align:center';>폐품권치수단위</td>
										
										<td GH="90" GCol="text,DISPO_PCNT" style="text-align:right;" GF="N 13,2"></td>
										<td GH='100' GCol='text,DISPO_RUNIT' style='text-align:center';>폐품연수단위</td>
										
										<td GH="90" GCol="text,DISPO_WGT" style="text-align:right;" GF="N 13,2"></td>
										<td GH='100' GCol='text,DISPO_WUNIT' style='text-align:center';>페품중량단위</td>
										
										<td GH="90" GCol="text,CUTTR_RSPEED" style="text-align:right;">선속</td>
										<td GH="90" GCol="text,SPEEDUNIT" style="text-align:center;">선속단위</td>
										<td GH="90" GCol="text,RUN_TM" style="text-align:right;"></td>
										<!-- <td GH="80" GCol="text,RUN_STA" style="text-align:center;"></td> -->
										
										<td GH="90" GCol="text,WRK_DATE" style="text-align:center;" GF="D">실적일자</td>
										<td GH="100" GCol="text,WRKNM" style="text-align:left;"></td>
										<td GH="150" GCol="text,LOC_NM" style="text-align:left;">로케이션명</td>
										<td GH="110" GCol="text,PST_INPT_MACHINE_NM" style="text-align:center;">후공정투입호기명</td>
										<td GH="120" GCol="text,PST_INPT_MACH_NM" style="text-align:left;">후공정투입설비명</td>
										<td GH="110" GCol="text,PST_PRFM_RLCNT" style="text-align:right;" GF="N 6"></td>
										<td GH='140' GCol='text,AF_ROLLUNIT' style='text-align:center';>후공정권치수단위</td>
										
										<td GH="90" GCol="text,PST_PRFM_PCNT" style="text-align:right;" GF="N 13,2"></td>
										<td GH='140' GCol='text,AF_RUNIT' style='text-align:center';>후공정연수단위</td>
										
										<td GH="90" GCol="text,PST_PRFM_WGT" style="text-align:right;" GF="N 13,2"></td>
										<td GH='140' GCol='text,AF_WUNIT' style='text-align:center';>후공정중량단위</td>
										
										<td GH="110" GCol="text,PST_DISPO_RLCNT" style="text-align:right;" GF="N 6"></td>
										<td GH='140' GCol='text,AF_DISPO_ROLLUNIT' style='text-align:center';>후공정폐품권치수단위</td>
										
										<td GH="90" GCol="text,PST_DISPO_PCNT" style="text-align:right;" GF="N 13,2"></td>
										<td GH='140' GCol='text,AF_DISPO_RUNIT' style='text-align:center';>후공정폐품연수단위</td>
										
										<td GH="90" GCol="text,PST_DISPO_WGT" style="text-align:right;" GF="N 13,2"></td>
										<td GH='140' GCol='text,AF_DISPO_WUNIT' style='text-align:center';>후공정폐품중량단위</td>
										
										<td GH="90 공정상태" GCol="text,STCK_STA" style="text-align:center;">공정상태</td>
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
	</div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>