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
	$(document).ready(function(){
		gridList.setGrid({
			id : "gridList",
			url : "/mes/Work/WRK24/json/datalist.data",
			bigdata : false
	    });
		$('#P200Flag').hide();
	});
	
	function searchHelpEventCloseAfter(searchCode, multyType, selectData, rowData){
		if(searchCode == "PLANT"){
			reloadCombo();
		}
	}
	
	function reloadCombo(){
		$comboObj = $("#MACHINE");
		inputList.reloadCombo($comboObj, configData.INPUT_COMBO, "Produce,MACHINE");
		
		if($('#WERKS').val().toUpperCase() == 'P200'){
			$('#P200Flag').show();
		}else{
			$('#P200Flag').hide();
		}
	}

	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "Produce,MACHINE"){
			var param = new DataMap();
			
			param.put("WERKS", $("#WERKS").val().toUpperCase());
		}
		return param;
	}
	
	//20221023 여한진 화장지 같은 경우 생산호기가 합지랑 가공이 구분이 가지 않아서 공정코드로 구분하기 위해
	function procCdcheck(){
		if($('#WERKS').val().toUpperCase() == 'P200'){
			if ($('#P200PROC').val() == '') return alert('공정구분을 선택하세요.');
			
			$("#MACHINE").find("option").map(function(){
				//20221023 여한진 화장기 합지 또는 가공에 따라서 
				const text = $(this).text()
				
				if($('#P200PROC').val() == 'AA'){
					// "합지 :" 문자열을 포함하지 않을 경우
					if(text.indexOf("합지") === -1 && text.indexOf("All") === -1){
						$(this).hide()
					}else{
						$(this).show()
					}	
				}else if($('#P200PROC').val() == 'RA'){
					// "가공 :" 문자열을 포함하지 않을 경우
					if(text.indexOf("가공") === -1 && text.indexOf("All") === -1){
						$(this).hide()
					}else{
						$(this).show()
					}	
				}else{
					// "예외생산 :" 문자열을 포함하지 않을 경우
					if(text.indexOf("예외생산") === -1){
						$(this).hide()
					}else{
						$(this).show()
					}
				}
					
			})	
		}
	}
	
	function reset(){
		$('#MACHINE').val('');
	}
	
	function searchList() {
		if (validate.check("searchArea")) {
			// 2022-08-17(수요일) 안상현, P100 검색 제어
			if($("#WERKS").val().toUpperCase() === "P100"){
				alert("P100은 PS 생산 출고 현황에서 조회 가능합니다.")
				return
			}
			
			/* var range = inputList.setRangeParam("searchArea");
			var range_data_param = range.get("RANGE_DATA_PARAM");
			var prfm_dt = range_data_param.get("PRFM_DT_Range");
			var date = prfm_dt.split('↓');
			var SDate = date[1];
			var EDate = date[2]; */
			
			var param = inputList.setRangeParam("searchArea");
			param.put("P_TYPE", "LIST");
			/* param.put("SDATE", SDate);
			param.put("EDATE", EDate);
			
			param.put("MACHINE",range.get('MACHINE'));
			param.put("EMPLY_NM",range.get('EMPLY_NM'));

			param.put("WERKS",range.get('WERKS'));
			param.put("MATNR",range.get('MATNR'));
			param.put('IND_BCD', range.get('IND_BCD')); */
			
			gridList.gridList({
				id : "gridList",
				param : param
			});
	
		}
	}
	
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			var param = new DataMap();
	        param.put("PROGID", "<%=menuId%>");
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
		page.linkPopOpen(url, $('#WERKS').val().toUpperCase(), "height=600,width=850");
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
					<div class="fl_l"></div>
					<div class="fl_r">
						<input type="button" id="button-0-1" CB="Search SEARCH BTN_SEARCH" />
					</div>
				</div>
				<div class="search_inner">
					<div class="search_wrap ">

						<dl>
							<dt CL="STD_PLANT"></dt>
							<dd>
								<!-- 2022-08-17(수요일) 안상현, 플랜트 필수 검색 조건 추가 -->
								<input type="text" class="input" name="WERKS" id="WERKS" UIInput="S,PLANT" UIFormat="U" validate="required" onkeyup='reloadCombo()' />
							</dd>
						</dl>

						<dl>
							<dt>실적일자</dt>
							<dd>
								<input type="text" name="PRFM_DT" id="PRFM_DT" UIInput="B" UIFORMAT="C M1" />
							</dd>
						</dl>

						<dl>
							<dt CL="STD_MACHINE">생산호기</dt>
							<dd>
								<select class="input" id="MACHINE" name="MACHINE" Combo="Produce,MACHINE" onclick='procCdcheck();'>
									<option value="">ALL</option>
								</select>
							</dd>
						</dl>
						<!-- 2022-08-17(수요일) 안상현, 검색 조건 지종코드 제거
					<dl>
						<dt CL="STD_PCODE"></dt>
						<dd>
							<input type="text" class="input" name="PCODE" UIInput="S,PCODE" UIFormat="U"/>
						</dd>
					</dl>
					 -->
						<dl>
							<dt CL="STD_MATNR"></dt>
							<dd>
								<input type="text" class="input" name="MATNR" id="MATNR" UIInput="SR,MATKY" UIFormat="U" />
							</dd>
						</dl>

						<dl>
							<dt>작업자</dt>
							<dd>
								<input type="text" class="input" id="EMPLY_NM" name="EMPLY_NM" UIFormat="U" UIInput="SR"/>
							</dd>
						</dl>
						<dl id='P200Flag'>
							<dt>공정구분</dt>
							<dd>
								<select class="input" id="P200PROC" CommonCombo='P200PROC' onclick='reset();'>
									<option value=''>All</option>
								</select>
							</dd>
						</dl>
						<!-- 20230207 여한진 개별바코드 검색조건 추가 -->
						<dl>
							<dt CL="STD_IND_BCD"></dt>
							<dd>
								<input type="text" class="input" id="IND_BCD" name="IND_BCD" UIInput="SR,INDBCD" UIFormat="U"/>
							</dd>
						</dl>
					</div>
					<div class="btn_tab">
						<input type="button" class="btn_more" value="more" onclick="searchMore()" />
					</div>
				</div>
			</div>
			<div class="search_next_wrap">
				<div class="content_layout tabs">
					<ul class="tab tab_style02">
						<li><a href="#tab1-1"><span>일반</span></a></li>
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
											<td GH="60" GCol="text,ORDER_SEQNO"	style="text-align: center;">오더순번</td>
											<td GH="100" GCol="text,LOT_NO" style="text-align: center;">LOT번호</td>
											<td GH="140" GCol="text,WRK_ORDR_NO" style="text-align: center;">작업지시번호</td>
											<td GH="100" GCol="text,WRK_ORDR_SEQNO" style="text-align: center;">작업지시순번</td>
											<td GH="140" GCol="text,MATNR" style="text-align: center;">자재코드</td>
											<td GH="320" GCol="text,MATNR_NM">자재명</td>
											<td GH="100" GCol="text,STOR_LOC_FR" style="text-align: center;"></td>
											<td GH="100" GCol="text,STOR_LOC_TO" style="text-align: center;"></td>
											<td GH="140" GCol="text,IND_BCD" style="text-align: center;">개별바코드</td>
											<td GH="80" GCol="text,UNIT" style="text-align: center;">단위</td>
											<td GH="100" GCol="text,PLT_QTY" GF='N 13,1'></td>
											<td GH="100" GCol="text,BOX_QTY" GF='N 13'></td>
											<td GH="100" GCol="text,BAG_QTY" GF='N 13'></td>
											<td GH="100" GCol="text,EA_QTY" GF='N 13'></td>

											<td GH="100" GCol="text,WGT" GF='N 13,3'>중량</td>
											<td GH="100" GCol="text,QTY" GF='N 13'>입고요청량</td>
											<!-- 2022-08-17(수요일) 안상현, HL 지종코드, 지종명 제거
										<td GH="100" GCol="text,PCODE" style="text-align: center;">지종</td>
										<td GH="180" GCol="text,PCODE_NM">지종명</td>
										 -->
											<td GH="100" GCol="text,EMPLY_NO" style="text-align: center;">작업자ID</td>
											<td GH="100" GCol="text,EMPLY_NM" style="text-align: center;">작업자명</td>
											<td GH="100" GCol="text,PRD_DT" GF='D' style="text-align: center;">입고일자</td>
											<td GH="100" GCol="text,PRFM_DT" GF='D' style="text-align: center;">실적일자</td>
											<td GH="100" GCol="text,DSTBT_DDLIN" GF='D' style="text-align: center;">유통기한</td>
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
	<%@ include file="/common/include/webdek/bottom.jsp"%>
</body>
</html>