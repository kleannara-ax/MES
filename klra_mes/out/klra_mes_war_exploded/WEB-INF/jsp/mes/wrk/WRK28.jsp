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
		var showflag = "자재사용량";
		
		gridList.setGrid({
			id : "gridList",
			url:"/mes/Work/WRK28/json/datalist.data",
			bigdata : false,
			colGroupCols : "PIND_BCD"
		})
	});


	function searchList() {
		if (validate.check("searchArea")) {
			// 2023-03-13(월요일) 안상현, RANGE 검색 추가
			/* const range = inputList.setRangeParam("searchArea")
			const range_data_param = range.get("RANGE_DATA_PARAM")
			const prfm_dt = range_data_param.get("PRFM_DT_Range")
			const date = prfm_dt.split("↓")
			const SDate = date[1]
			const EDate = date[2] */
			
			const param = inputList.setRangeParam("searchArea")
			param.put("P_TYPE", "LIST")
			//param.put("SDATE", SDate)
			//param.put("EDATE", EDate)
			param.put("INOUT_GU", $("#INOUT_GU").val()) // 지시구분
			param.put("CNL_YN", $("#CNL_YN").val()) // 취소여부
			//param.put("IND_BCD", $("#IND_BCD").val()) // 개별바코드
			param.put("CHKFG", $("#CHKFG").val()) // 원지포함
			
			if (document.getElementById('CHKFG').checked) {
				param.put("CHKFG", 'ON');
			} else {
				param.put("CHKFG", 'OFF');
			}
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    })
			/* 
			var range = inputList.setRangeParam("searchArea");
			var range_data_param = range.get("RANGE_DATA_PARAM");
			var prfm_dt = range_data_param.get("PRFM_DT_Range");
			var date = prfm_dt.split('↓');
			var SDate = date[1];
			var EDate = date[2];

			var param = new DataMap();
			param.put("P_TYPE", "LIST");
			param.put("SDATE", SDate);
			param.put("EDATE", EDate);
			
			param.put("PCODE",$("#PCODE").val().toUpperCase());
			param.put("BS_WGT",$("#BS_WGT").val());
			param.put("WLEN",$("#WLEN").val());
			param.put("VLEN",$("#VLEN").val());
			param.put("INOUT_GU",$("#INOUT_GU").val());
			param.put("CNL_YN", $("#CNL_YN").val());
			param.put("IND_BCD", $("#IND_BCD").val());
			param.put("CHKFG", $("#CHKFG").val());
			
			if (document.getElementById('CHKFG').checked) {
				param.put("CHKFG", 'ON');
			} else {
				param.put("CHKFG", 'OFF');
			}
			
			gridList.gridList({
				id : "gridList",
				param : param
			});
			*/
		}
	}
	

	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
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

	const barcode = () => {
		var url = "/mes/wrk/WRK23_POP01.page";
		page.linkPopOpen(url, "", "height=600,width=850");
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
						<dt>포장실적일자</dt>
						<dd><input type="text" name="PRFM_DT" id="PRFM_DT" UIInput="B" UIFORMAT="C M1"/></dd>
					</dl>
					
					<dl>
						<dt>지종</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 지종코드 RANGE 검색 추가 -->
							<input type="text" name="PCODE" id="PCODE" UIInput="SR,PCODE" UIFormat="U"/>
						</dd>
					</dl>
					
					<dl>
						<dt>평량</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 평량 RANGE 검색 추가 -->
							<input type="text" name="BS_WGT" id="BS_WGT" class="input" UIInput="SR" UIFormat="U"/>
						</dd>
					</dl>
					
					<dl>
						<dt>가로</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 가로 RANGE 검색 추가 -->
							<input type="text" name="WLEN" id="WLEN" class="input" UIInput="SR" UIFormat="U"/>
						</dd>
					</dl>
					
					<dl>
						<dt>세로</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 세로 RANGE 검색 추가 -->
							<input type="text" name="VLEN" id="VLEN" class="input" UIInput="SR" UIFormat="U"/>
						</dd>
					</dl>
					
					<dl>
						<dt>지시구분</dt>
						<dd>
							<select class="input" id="INOUT_GU" name="INOUT_GU">
								<option value="">All</option>
								<option value="N">정규</option>
								<option value="E">예외</option>
							</select>
						</dd>
					</dl>
					
					<!-- 20221103 진승화 취소여부 검색조건 추가 -->
					<dl>
						<dt>취소여부</dt>
						<dd>
							<select class="input" id="CNL_YN" name="CNL_YN">
								<option value="N">N</option>
								<option value="Y">Y</option>
							</select>
						</dd>
					</dl>
					
					<!-- 20221103 진승화 개별바코드 검색조건 추가 -->
					<dl>
						<dt CL="STD_IND_BCD">개별바코드</dt>
						<dd>
							<input type="text" class="input" id="IND_BCD" name="IND_BCD" maxlength="20" UIInput="SR,INDBCD" UIFormat="U"/>
						</dd>
					</dl>
					
					<dl>
						<dt>원지포함</dt>
						<dd><input type="checkbox" name="CHKFG" id="CHKFG" class="input" UIFormat="U"/></dd>
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
					<li><a href="#tab1-1"><span CL="STD_GRD_WRK28">일반</span></a></li>
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
										<td GH="80" GCol="text,PCODE" style="text-align:center;">지종코드</td>
										<td GH="80" GCol="text,PCODE_NM">지종명</td>
										<td GH="80" GCol="text,BS_WGT" style="text-align:right;">평량</td>
										<td GH="80" GCol="text,WLEN" style="text-align:right;">가로</td>
										<td GH="80" GCol="text,VLEN" style="text-align:right;">세로</td>
										<td GH="180" GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH="320" GCol="text,MATNR_NM">자재코드</td>
										<td GH="100" GCol="text,PACKTYPE" style="text-align:center;">포장타입</td>
										<td GH="100" GCol="text,PACKTYPE_NM">포장타입</td>
										<td GH="100" GCol="text,ORDER_NO" style="text-align:center;">오더번호</td>
										<td GH="80" GCol="text,DOMESTIC" style="text-align:center;">내수구분</td>
										<td GH="100" GCol="text,DOMESTIC_NM">내수구분명</td>
										<td GH="100" GCol="text,KUNNR" style="text-align:center;">판매처</td>
										<td GH="140" GCol="text,KUNNRT">판매처명</td>
										<td GH="80" GCol="text,LAND1" style="text-align:center;">국가</td>
										<td GH="100" GCol="text,LAND1_NM">국가명</td>
										<td GH="100" GCol="text,CLOT_NO" style="text-align:center;">재단LOT NO</td>
										<td GH="100" GCol="text,CIND_BCD" style="text-align:center;">재단바코드</td>
										<td GH="100" GCol="text,CPRD_DT" GF="D" style="text-align:center;">재단작업일</td>
										<td GH="100" GCol="text,CMACH_CD" style="text-align:center;">재단설비</td>
										<td GH="140" GCol="text,CMACH_NM">재단설비명</td>
										<td GH="100" GCol="text,CREGID">재단작업자</td>
										<td GH="100" GCol="text,CREGNM">재단작어자명</td>
										<td GH="100" GCol="text,WRK_ORDR_DIV" style="text-align:center;">작업지시구분</td>
										<td GH="120" GCol="text,WRK_ORDR_DIV_NM">작업지시구분명</td>
										<td GH="100" GCol="text,PALETTECNT" style="text-align:right;" GF="N 13,3">팔레트당연수</td>
										<td GH="100" GCol="text,CPALETTECNT" style="text-align:right;" GF="N 13,3">재단팔레트당연수</td>
										<td GH="100" GCol="text,CRUNIT" style="text-align:center;">재단연수단위</td>
										
										<td GH="100" GCol="text,CWGT" GF="N 13,3">재단중량</td>
										<td GH="100" GCol="text,CWUNIT" style="text-align:center;">재단중량단위</td>
										
										<td GH="100" GCol="text,STOR_LOC_CD" style="text-align:center;">저장 위치 코드</td>
										<!-- <td GH="120" GCol="text,LOC_NM">로케이션명</td> -->
										
										<td GH="100" GCol="text,PPRD_DT" GF="D" style="text-align:center;">포장생산일자</td>
										<td GH="100" GCol="text,PPRFM_DT" GF="D" style="text-align:center;">포장실적일자</td>
										<td GH="100" GCol="text,PLOT_NO" style="text-align:center;">포장LOT NO</td>
										<td GH="100" GCol="text,PIND_BCD" style="text-align:center;">포장바코드</td>
										<td GH="100" GCol="text,PPCNT" GF="N 13,2">포장연수</td>
										<td GH="100" GCol="text,PRD_RUNIT" style="text-align:center;">포장연수단위</td>
										
										<td GH="100" GCol="text,IN_PER_CNT" style="text-align:right;">속당매수</td>
										<td GH="100" GCol="text,SCNT" GF="N 13,1">속수</td>
										<td GH="100" GCol="text,MCNT" GF="N 13">매수</td>
										<td GH="100" GCol="text,PWGT" GF="N 13,3">포장중량</td>
										<td GH="100" GCol="text,PRD_WUNIT" style="text-align:center;">포장중량단위</td>
										
										<td GH="100" GCol="text,DISPO_CD" style="text-align:center;">폐품코드</td>
										<td GH="100" GCol="text,DISPOPCNT" GF="N 13,1">폐품 연수</td>
										<td GH="100" GCol="text,DISPO_RUNIT" style="text-align:center;">폐품연수단위</td>
										<td GH="100" GCol="text,DISPO_WGT" GF="N 13,3">폐품중량</td>
										<td GH="100" GCol="text,DISPO_WUNIT" style="text-align:center;">폐품중량단위</td>
										
										<td GH="80" GCol="text,STCK_STA" style="text-align:center;">재고상태</td>
										<td GH="100" GCol="text,STA_NM">재고상태명</td>
										<td GH="100" GCol="text,PMACH_CD" style="text-align:center;">포장설비</td>
										<td GH="140" GCol="text,PMACH_NM">포장설비명</td>
										<td GH="100" GCol="text,WRK_CLASS">반</td>
										<td GH="100" GCol="text,PREGID">포장작업자</td>
										<td GH="100" GCol="text,PREGNM">포장작업명</td>
										<td GH="100" GCol="text,CONTAINER">컨테이너</td>
										<td GH="100" GCol="text,HANG">항차</td>
										<td GH="180" GCol="text,RMK">비고</td>
										<td GH="100" GCol="text,JORDER_NO" style="text-align:center;">점보롤오더번호</td>
										<td GH="100" GCol="text,MORDER_NO" style="text-align:center;">밀롤오더번호</td>
										<!-- 221103 진승화 하위 5개 항목 추가 -->
										<td GH="100" GCol="text,CNL_YN" style="text-align:center;">취소 여부</td>
										<td GH="100" GCol="text,VBELN" style="text-align:center;">판매문서번호</td>
										<td GH="100" GCol="text,POSNR" style="text-align:right;">판매문서번호순번</td>
										<td GH="100" GCol="text,SDOC_NO" style="text-align:center;">SAP확정문서번호</td>
										<td GH="100" GCol="text,SDOC_SEQNO" style="text-align:right;">SAP확정문서번호순번</td>
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