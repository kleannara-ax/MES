<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp"%>
<link rel="stylesheet" type="text/css"
	href="/common/theme/webdek/css/demo_layout.css">
<script type="text/javascript">
	$(document).ready(function() {
		gridList.setGrid({
			id : "gridList",
			url : "/mes/Work/WRK48/json/datalist.data",
			bigdata : false,
			colHoldType : true,
			colHold : "WERKS,WRK_ORDR_NO, WRK_ORDR_SEQNO, MACHINE"
		});
	});

	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "Produce,MACHINE"){
			var param = new DataMap();
			
			param.put("WERKS", 'P100');
		}
		return param;
	}

	// 조회
	const searchList = () => {
		// 검색 조건 validation
		if(validate.check("searchArea")){
			// 2023-03-13(월요일) 안상현, Range 검색 추가
			const range = inputList.setRangeParam("searchArea")
			const range_data_param = range.get("RANGE_DATA_PARAM")
			const prfm_dt = range_data_param.get("A.PRFM_DT_Range")
			const date = prfm_dt.split("↓")
			const SDate = date[1]
			const EDate = date[2]
			
			const param = inputList.setRangeParam("searchArea")
			param.put("P_TYPE", "LIST")
			param.put("SDATE", SDate)
			param.put("EDATE", EDate)
			//param.put("IND_BCD", $("#IND_BCD").val())
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    })
		}
	}
	
	// 버튼 클릭(조회)
	function commonBtnClick(btnName) {
		if (btnName == "Search") {
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
	
	const barcode = () => {
		var url = "/mes/wrk/WRK17_POP01.page";
		page.linkPopOpen(url, "P100", "height=600,width=850");
	}
</script>
</head>
<body>
	<%@ include file="/common/include/webdek/layout.jsp"%>
	<!-- content -->
	<div class="content_wrap">
		<div class="content_inner">
			<%@ include file="/common/include/webdek/title.jsp"%>
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
								<input type="text" id="PRFM_DT" name="A.PRFM_DT" UIInput="B" UIFORMAT="C M1" />
							</dd>
						</dl>
						<!-- 20230216 여한진 자재코드, 오더번호, 판매문서번호, 판매문서 항목번호, 거래처코드, LOT번호, 개별바코드 검색조건 추가 -->
						<dl>
							<dt CL="STD_MATNR">자재코드</dt>
							<dd>
								<!-- 2023-03-13(월요일) 안상현, 자재코드 RANGE 검색 추가 -->
								<input type="text" id="MATNR" name="A.MATNR" UIInput="SR,MATKY" UIFormat="U"/>
							</dd>
						</dl>
						<dl>
							<dt CL="STD_ORDER_NO">오더번호</dt>
							<dd>
								<!-- 2023-03-13(월요일) 안상현, 오더번호 RANGE 검색 추가 -->
								<input type="text" class="input" id="ORDER_NO" name="ORDER_NO" UIInput="SR,MATKY" />
							</dd>
						</dl>
						<dl>
							<dt CL="STD_VBELN">판매문서번호</dt>
							<dd>
								<input type="text" class='input' id='VBELN' name="VBELN" UIInput="SR"/>
							</dd>
						</dl>
						<dl>
							<dt CL="STD_POSNR">판매문서 품목번호</dt>
							<dd>
								<input type="text" class='input' id='POSNR' name="POSNR" UIInput="SR"/>
							</dd>
						</dl>
						<dl>
							<dt CL="STD_CUST_CD">거래처코드</dt>
							<dd>
								<!-- 2023-03-13(월요일) 안상현, 거래처코드 RANGE 검색 추가 -->
								<input type="text" id="CUST_CD" name="CUST_CD" UIInput="SR,CUST" UIFormat="U" />
							</dd>
						</dl>
						<dl>
							<dt CL="STD_LOT_NO">LOT번호</dt>
							<dd>
								<!-- 2023-03-13(월요일) 안상현, LOT번호 RANGE 검색 추가 -->
								<input type="text" class="input" id="LOT_NO" name="LOT_NO" UIInput="SR" UIFormat="U"/>
							</dd>
						</dl>
						<dl>
							<dt CL="STD_IND_BCD">개별바코드</dt>
							<dd>
								<input type="text" class="input" id="IND_BCD" name="IND_BCD" UIInput="SR,INDBCD" UIFormat="U"/>
							</dd>
						</dl>
						<dl>
							<dt CL="STD_MACHINE">생산호기</dt>
							<dd>
								<select class="input" id="MACHINE" name="MACHINE" Combo="Produce,MACHINE">
									<option value="">ALL</option>
								</select>
							</dd>
						</dl>
						
						<dl>
							<dt CL="STD_MACH_CD">설비코드</dt>
							<dd>
								<input type="hidden" id="WERKS" name="WERKS" value="P100" />
								<!-- 2023-03-13(월요일) 안상현, 설비코드 RANGE 검색 추가 -->
								<input type="text" class="input" name="A.MACH_CD" id="MACH_CD" UIInput="SR,MACH" UIFormat="U"/>
							</dd>
						</dl>
						
						<!-- 20230216 여한진 운전상태가 01-정상(가동)만 있어서 검색조건 필요없으므로 주석처리 -->
						<!-- <dl>
							<dt CL="STD_RUN_STA">운전상태</dt>
							<dd>
								<select class="input" id="RUN_STA" name="RUN_STA" CommonCombo="RUNSTA">
									<option value="">ALL</option>
								</select>
							</dd>
						</dl> -->
						
						<!-- 20221104 진승화 취소여부 검색조건 추가 -->
						<dl>
							<dt>취소여부</dt>
							<dd>
								<select class="input" id="CNL_YN" name="CNL_YN">
									<option value="N">N</option>
									<option value="Y">Y</option>
								</select>
							</dd>
						</dl>
						<!-- -->
					</div>
					<div class="btn_tab">
						<input type="button" class="btn_more" value="more" onclick="searchMore()" />
					</div>
				</div>
			</div>
			<div class="search_next_wrap">
				<div class="content_layout tabs">
					<ul class="tab tab_style02">
						<li><a href="#tab1-1"><span CL="STD_GRD_WRK48">리스트</span></a></li>
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
											<td GH="40" GCol="rowCheck"></td>
											<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
											<td GH="140" GCol="text,WRK_ORDR_NO" style="text-align:center;">작업지시번호</td>
											<td GH="100" GCol="text,WRK_ORDR_SEQNO" style="text-align:center;">순번</td>
											<td GH="100" GCol="text,MACHINE" style="text-align: center;">호기</td>
											<td GH="100" GCol="text,PROC_NM" style="text-align:center;">공정명</td>
											<td GH="100" GCol="text,MACH_CD" style="text-align: center;">설비코드</td>
											<td GH="150" GCol="text,MACH_NM" style="text-align:center;">설비명</td>
											
											<td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>
											<td GH="320" GCol="text,MATNR_NM" style="text-align:center;">자재코드</td>
											
											<td GH="140" GCol="text,PRD_STR_DATE" style="text-align: center;">시작시간</td>
											<td GH="140" GCol="text,PRD_END_DATE" style="text-align: center;">종료시간</td>
											<!-- 221104 진승화 생산시간 추가   -->
											<td GH="80 생산시간(분)" GCol="text,TM" GF="N 13" style="text-align: center">생산시간(분)</td>
											<td GH="100" GCol="text,WRK_CLASS" style="text-align: center;">작업반</td>
											<td GH="100" GCol="text,PCODE_NM" style="text-align:center;">지종명</td>
											<td GH="100" GCol="text,BS_WGT" style="text-align:center;">평량</td>
											<td GH="100" GCol="text,RSPEED" style="text-align:center;">선속</td>
											<!-- 20221203 여한진 하위 2개 컬럼 추가 -->
											<td GH="100" GCol="text,WIDTH" style="text-align:center;">실지폭</td>
											<td GH="100" GCol="text,WIDTH_NO" style="text-align:center;">실지폭</td>
											<td GH='100' GCol='text,SPEC' style="text-align:center;">규격</td>
											<td GH="100" GCol="text,LOT_NO" style="text-align:center;">LOT번호</td>
											<td GH="120" GCol="text,IND_BCD" style="text-align:center;">개별바코드</td>
											<td GH="100" GCol="text,RUN_STA" style="text-align:center;">운전상태</td>
											
											<td GH="60" GCol="text,CNL_YN" style="text-align:center;">취소여부</td>
											<td GH="140" GCol="text,CNL_RMK" style="text-align:center;">취소비고</td>
											
											<td GH="100" GCol="text,PRFM_ROLLCNT" GF="N 6,0">실적권치수</td>
											<td GH="100" GCol="text,PRMUNIT" style="text-align: center;">실적권치수단위</td>
											
											<td GH="100" GCol="text,PRFM_WGT" GF="N 13,3">실적중량</td>
											<td GH="100" GCol="text,PRWUNIT" style="text-align: center;">실적중량단위</td>
											
											<td GH="100" GCol="text,DISPO_ROLLCNT" GF="N 6,0">폐품권치수</td>
											<td GH="100" GCol="text,DIMUNIT" style="text-align: center;">폐품권치수단위</td>
											
											<td GH="100" GCol="text,DISPO_WGT" GF="N 13,3">폐품중량</td>
											<td GH="100" GCol="text,DIWUNIT" style="text-align: center;">폐품중량단위</td>
											
											<td GH="100" GCol="text,DISPO_CD" style="text-align:center;">폐품코드</td>
											<td GH="100" GCol="text,PRFM_DT" style="text-align:center;" GF='D'>실적일자</td>
											<td GH="140" GCol="text,PRD_DATE" style="text-align:center;">생산일시</td>
											<!-- 20230215 여한진 하위 컬럼 주석처리 및 추가 -->
											<!-- <td GH="120" GCol="text,NAUFNR" style="text-align:center;">비계획생산오더번호</td> -->
											<td GH="100" GCol="text,PRE_ORDER_NO" style="text-align:center;">이전오더번호</td>
											
											<td GH="0" GCol="text,LOT_CHG_YN" style="text-align:center;">LOT 변경여부</td>
											<td GH="100" GCol="text,REGNM" style="text-align:center;">작업자</td>
											<td GH="330" GCol="text,ORDER_RMK">오더비고</td>
											<td GH="100" GCol="text,ORDER_NO" style="text-align: center;">생산오더번호</td>
											
											<!-- 221104 진승화 하위 5개 항목 추가 -->
											
											<td GH="330" GCol="text,RMK">비고</td>
											<td GH="100" GCol="text,VBELN" style="text-align: center">판매문서번호</td>
											<td GH="100" GCol="text,POSNR" style="text-align: center">판매문서품목번호</td>
											
											<td GH="100" GCol="text,CUST_CD" style="text-align:center;">거래처</td>
											
											<!-- 20221203 여한진 하위 1개 항목 수정 -->
											<td GH="240" GCol="text,KUNNR_NM" style="text-align:center;">거래처</td>
											<td GH="100" GCol="text,SDOC_NO" style="text-align: center">SAP확정문서번호</td>
											<td GH="100" GCol="text,SDOC_SEQNO" style="text-align: center">SAP확정문서번호순번</td>
											<!-- 20221203 여한진 하위 2개 항목 수정 -->
											<td GH="100" GCol="text,MRCOM_YN" style="text-align:center;">밀롤완료</td>
											<td GH="100" GCol="text,JRCOM_YN" style="text-align:center;">점보롤완료</td>
											
											<td GH="100" GCol="text,SHEET" style="text-align:center;">판지구분자</td>
											<td GH="100" GCol="text,JR_LOT_NO" style="text-align:center;">점보롤 LOTNO</td>
											<td GH="100" GCol="text,JR_IND_BCD" style="text-align:center;">점보롤 개별바코드</td>
											<td GH="140" GCol="text,JR_PRD_STR_DATE" style="text-align: center;">점보롤 시작시간</td>
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
	<%@ include file="/common/include/webdek/bottom.jsp"%>
</body>
</html>