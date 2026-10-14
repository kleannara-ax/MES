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
			url : "/mes/Work/WRK32/json/datalist.data",
			bigdata : false
	    });
		$("#WERKS").val('P100');
	});
	
	function searchList() {
		if (validate.check("searchArea")) {
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
			param.put("WERKS", $("#WERKS").val()) // 플랜트
			param.put("MACHINE", $("#MACHINE").val()) // 생산호기
			param.put("IND_BCD", $("#IND_BCD").val().toUpperCase()) // 개별바코드
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    })
		}
	}
	
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
	
	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "Produce,MACHINE"){
			var param = new DataMap();
			
			param.put("WERKS", 'P100');
		}
		return param;
	}
	
	const barcode = () => {
		var url = "/mes/wrk/WRK17_POP01.page";
		page.linkPopOpen(url, $('#WERKS').val().toUpperCase(), "height=600,width=850");
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
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" name="WERKS" id="WERKS"  UIFormat="U" readonly="readonly"/>
						</dd>
					</dl>
					
				  	<dl>
						<dt>실적일자</dt>
						<dd>
							<input type="text" name="PRFM_DT" id="PRFM_DT" UIInput="B" UIFORMAT="C M1"/>
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
						<dt CL="STD_PCODE">지종코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 지종코드 RANGE 검색 추가 -->
							<input type="text" class="input" id="PCODE" name="MAS001.PCODE" UIInput="SR,PCODE" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 자재코드 RANGE 검색 추가 -->
							<input type="text" class="input" id="MATNR" name="WRK015.MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt>작업자</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 작업자 RANGE 검색 추가 -->
							<input type="text" class="input" id="EMPLY_NM" name="EMPLY_NM" UIInput="SR" UIFormat="U"/>
						</dd>
					</dl>
					<!-- 20230207 여한진 개별바코드 검색조건 추가 -->
					<dl>
						<dt CL="STD_IND_BCD">개별바코드</dt>
						<dd>
							<input type="text" class="input" id="IND_BCD" name="IND_BCD" UIInput="SR,INDBCD" UIFormat="U"/>
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
					<li><a href="#tab1-1"><span CL="STD_GRD_WRK32">리스트</span></a></li>
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
							<table class="table_b">
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH="100" GCol="text,WERKS" style="text-align: center;">플랜트</td>
										<td GH="100" GCol="text,MACHINE" style="text-align: center;">생산호기</td>
										<td GH="100" GCol="text,ORDER_NO" style="text-align: center;">오더번호</td>
										<td GH="100" GCol="text,LOT_NO" style="text-align: center;">LOT번호</td>
										<td GH="140" GCol="text,WRK_ORDR_NO" style="text-align: center;">작업지시번호</td>
										<td GH="100" GCol="text,WRK_ORDR_SEQNO" style="text-align: center;">작업지시순번</td>
										<td GH="140" GCol="text,MATNR" style="text-align: center;">자재코드</td>
										<td GH="320" GCol="text,MATNR_NM">자재명</td>
										<td GH="100" GCol="text,STOR_LOC_FR" style="text-align: center;"></td>
										<td GH="100" GCol="text,STOR_LOC_TO" style="text-align: center;"></td>
										<td GH="100" GCol="text,IND_BCD" style="text-align: center;">개별바코드</td>
									
										<td GH="100" GCol="text,WGT" GF='N 13,3'>중량</td>
										<td GH="80" GCol="text,WUNIT" style="text-align: center;">중량단위</td>
										
										<td GH="100 수량" GCol="text,QTY" GF='N 13,2'>입고요청량</td>
										<td GH="80" GCol="text,OUTUNIT" style="text-align: center;">수량단위</td>
										
										<td GH="100" GCol="text,PCODE" style="text-align: center;">지종</td>
										<td GH="100" GCol="text,PCODE_NM">지종명</td>
										<td GH="100" GCol="text,BS_WGT" style="text-align:right;">평량</td>
										<td GH="100" GCol="text,WLEN" style="text-align:right;">가로</td>
										<td GH="100" GCol="text,VLEN" style="text-align:right;">세로</td>
										<td GH="100" GCol="text,CON_TYPE" style="text-align: center;">컨테이너타입</td>
										<td GH="100" GCol="text,PACKTYPE" style="text-align: center;">포장타입</td>
										
										<td GH="100" GCol="text,VBELN_TYPE" style="text-align: center;">판매문서유형</td>
										<td GH="100" GCol="text,VBELN" style="text-align: center;">판매문서</td>
										
										<td GH="100" GCol="text,POSNR" style="text-align: center;">판매문서 항목번호</td>
										<td GH="130" GCol="text,KUNNR" style="text-align: center;">판매처</td>
										<td GH="100" GCol="text,CORE" style="text-align: center;">지관</td>
										<td GH="100" GCol="text,EMPLY_NO" style="text-align: center;">작업자ID</td>
										<td GH="100" GCol="text,EMPLY_NM" style="text-align: center;">작업자명</td>
										<td GH="100" GCol="text,NTN_CD" style="text-align: center;">국가코드</td>
										<td GH="100" GCol="text,PRD_DT" GF='D' style="text-align: center;">입고일자</td>
										<td GH="100" GCol="text,PRFM_DT" GF='D' style="text-align: center;">실적일자</td>
										<td GH="120" GCol="text,STCK_NO" style="text-align: center;"> 특별재고번호</td>
										<td GH="100" GCol="text,REQ_STA" style="text-align: center;">요청상태</td>
										
										
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