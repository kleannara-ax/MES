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
			url : "/mes/Work/WRK30/json/datalist.data",
			bigdata:false,
		});
	});

	function searchList(){
		if(validate.check("searchArea")){
			var proc_cd = $("#PROC_CD").val().toUpperCase().trim();
			
			if(proc_cd != ''){
				if(proc_cd != "CB" && proc_cd != "SA"){
					alert("슬리터, 수재단 공정만 조회 가능합니다.")
					return;
				}
			}
			
			// 2023-03-13(월요일) 안상현, RANGE 검색 추가
			const range = inputList.setRangeParam("searchArea")
			const range_data_param = range.get("RANGE_DATA_PARAM")
			const prfm_dt = range_data_param.get("WRK002.PRFM_DT_Range")
			const date = prfm_dt.split("↓")
			const SDate = date[1]
			const EDate = date[2]
			
			const param = inputList.setRangeParam("searchArea")
			param.put("P_TYPE", "LIST")
			param.put("SDATE", SDate)
			param.put("EDATE", EDate)
			param.put("INOUT_GU", $("#INOUT_GU").val()) // 지시구분
			param.put("CNL_YN", $("#CNL_YN").val()) // 취소여부
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    })
		}
	}
	function saveData(){
		if(gridList.validationCheck("gridList", "all")){
			gridList.gridSave({
		    	id : "gridList",
		    	modifyType : "A"
		    });
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
						<dt CL="실적일자">실적일자</dt>
						<dd><input type="text" id="PRFM_DT" name="WRK002.PRFM_DT" UIInput="B" UIFORMAT="C M1"/></dd>
					</dl>
					<dl>
						<dt CL="공정코드">공정코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 공정코드 RANGE 검색 추가 -->
							<input type="text" class="input" id="PROC_CD" name="MAS012.PROC_CD" UIInput="SR,OP" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="지종">지종</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 지종코드 RANGE 검색 추가 -->
							<input type="text" name="PCODE" UIInput="SR,PCODE" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="평량">평량</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 평량 RANGE 검색 추가 -->
							<input type="text" name="BS_WGT" class="input" IAname="BS_WGT" UIInput="SR" UIFormat="U"/>
						</dd>
					</dl>

					<dl>
						<dt CL="가로">가로</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 가로 RANGE 검색 추가 -->
							<input type="text" name="WRK002.WLEN" class="input" IAname="WLEN" UIInput="SR" UIFormat="U"/>
						</dd>
					</dl>

					<dl>
						<dt CL="세로">세로</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 세로 RANGE 검색 추가 -->
							<input type="text" name="WRK002.VLEN" class="input" IAname="VLEN" UIInput="SR" UIFormat="U"/>
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
					
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
        <div class="search_next_wrap">
			<div class="content_layout tabs">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span CL="STD_GRD_WRK30">일반</span></a></li>
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
										<td GH="115 구분" GCol="text,FILD31" style="text-align: center">구분</td>
										<td GH="100" GCol="text,PRFM_DT" GF="D" style="text-align: center">실적일자</td>
										<td GH="100" GCol="text,MACH_CD" style="text-align: center">설비코드</td>
										<td GH="100" GCol="text,MACH_NM" style="text-align: center">설비명</td>
										<td GH="140" GCol="text,MATNR" style="text-align: center">자재코드</td>
										<td GH="280" GCol="text,MATNR_NM" style="text-align: center">자재명</td>
										<td GH="100 내수/수출" GCol="text,INOUT_DIV">내수/수출</td>
										<td GH="100" GCol="text,PCODE" style="text-align: center">지종코드</td>
										<td GH="100" GCol="text,PCODE_NM">지종명</td>
										<td GH="100" GCol="text,BS_WGT" style="text-align:right">평량</td>
										<td GH="100 가로길이" GCol="text,WLEN" style="text-align:right"></td>
										<td GH="100 세로길이" GCol="text,VLEN" style="text-align:right"></td>
										<td GH="100 실지폭" GCol="text,WIDTH" style="text-align:right"></td>
										<td GH="100 작업상태" GCol="text,COMP_YN" style="text-align:right">작업상태</td>
										<td GH="140 거래처" GCol="text,KUNNRT"></td>
										<td GH="100 국가" GCol="text,KUNNR_NM" style="text-align: center"></td>
										<td GH="100" GCol="text,LOT_NO" style="text-align: center"></td>
										<td GH="100" GCol="text,IND_BCD" style="text-align: center">개별바코드</td>
										<td GH="100" GCol="text,ROLLCNT" GF='N 13,3'>권치수</td>
										<td GH='100' GCol='text,ROLLUNIT' style="text-align:center">권치수단위</td>
										
										<td GH="100 연수" GCol="text,PCNT" GF='N 13,3'>연수</td>
										<td GH='100' GCol='text,RUNIT' style="text-align:center">연수단위</td>
										
										<td GH="100" GCol="text,WGT" GF='N 13,3'>중량</td>
										<td GH='100' GCol='text,WUNIT' style="text-align:center">중량단위</td>
										
										<td GH="100" GCol="text,DISPO_CD" style="text-align: center">폐품코드</td>
										<td GH="100" GCol="text,DISPO_ROLLCNT" GF='N 13,3'>폐품권치수</td>
										<td GH='100' GCol='text,DISPO_ROLLUNIT' style="text-align:center">폐품권치수단위</td>
										
										<td GH="100" GCol="text,DISPO_PCNT" GF='N 13,3'>폐품연수</td>
										<td GH='100' GCol='text,DISPO_RUNIT' style="text-align:center">폐품연수단위</td>
										
										<td GH="100" GCol="text,DISPO_WGT" GF='N 13,3'>폐품중량</td>
										<td GH='100' GCol='text,DISPO_WUNIT' style="text-align:center">폐품중량단위</td>
										
										<td GH="100 생산시간(분)" GCol="text,TM" GF='N 10'>생산시간(분)</td>
										<td GH="100 지관" GCol="text,CORE"></td>
										<td GH="100 속당매/속수" GCol="text,SCNT" style="text-align:right"></td>
										<td GH="100 팔레트당연수" GCol="text,PLT_QTY" style="text-align:right"></td>
										<td GH="100 포장방법" GCol="text,PACKTYPE" style="text-align: center"></td>
										<td GH="100" GCol="text,VBELN" style="text-align: center">판매문서번호</td>
										<td GH="100" GCol="text,POSNR" style="text-align: right">판매문서품목번호</td>
										<td GH="300 지시사항" GCol="text,ORDER_RMK"></td>
										<td GH="100" GCol="text,SDOC_NO" style="text-align: center">SAP확정문서번호</td>
										<td GH="100" GCol="text,SDOC_SEQNO" style="text-align: right">SAP확정문서번호순번</td>
										<td GH="100" GCol="text,CNL_YN" style="text-align: center">취소여부</td>
										
										<!-- <td GH='80' GCol='text,UNIT' style="text-align:center">단위</td>
										<td GH='100' GCol='text,PRFM_QTY' GF='N 13,1'>실적수량</td>
										<td GH="100 중량" GCol="text,WGT" GF='N 13,3'></td>
										<td GH="80 폐품M/RE" GCol="text,BAD_MRE" style="text-align: center"></td>
										<td GH="80 폐품중량" GCol="text,BAD_WGT" GF='N 13,3'></td>
										<td GH="140 비고" GCol="text,RMK"></td>
										<td GH="80 실적호기" GCol="text,MACH_CD" style="text-align: center"></td>
										<td GH="140 실적호기명" GCol="text,MACH_NM"></td>
										
										221103 진승화 생산시간 추가  
										<td GH="140 생산번호" GCol="text,PRD_NO" style="text-align: center"></td>
										<td GH="80 폭수" GCol="text,PKCNT" style="text-align:right"></td>
										<td GH="140 자재코드" GCol="text,MATNR" style="text-align: center"></td> -->
										<!-- 221103 진승화 하위 3개 항목 추가 -->
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