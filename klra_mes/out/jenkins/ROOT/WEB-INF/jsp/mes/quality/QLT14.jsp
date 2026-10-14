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
	    	url : "/mes/Quality/QLT14/json/datalist.data",
	    	bigdata : false,
	    	colHoldType : true,
	    	colHold : "MACHINETXT, LOT_NO, IND_BCD"
	    });
	});

	// 플랜트에 따른 설비코드 검색조건 셋팅
	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "Produce,MACHINE"){
			var param = new DataMap();
			
			param.put("WERKS", "P100");
		}
		
		return param;
	}

	// 조회
	function searchList(){
		if(validate.check("searchArea")){
			var param =inputList.setRangeParam("searchArea");
			
			param.put("P_TYPE", "LIST");
			/* param.put("WERKS", $("#WERKS").val());
			param.put("MACHINE", $("#MACHINE").val()); */
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}
	
	/* 2022-09-14(화요일) 안상현, RANGE_SQL로 처리 가능해서 제거
	function parse(str){
		var y = str.substr(0, 4);
		var m = str.substr(4, 2);
		var d = str.substr(6, 2);
		var h = "00";
		var mm = "00";
		var s = "00";
		
		return y + "-" + m + "-" + d + " " + h + ":" + mm + ":" + s;
	}
 	*/
 	
	// 버튼 클릭(조회)
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
							<input type="text" class="input" id="WERKS" name="WERKS" UIFormat="U" value="P100" readonly />
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
						<dt CL="STD_PRFM_DT">실적일자</dt>
						<dd>
							<input type="text" name="PRFM_DT" UIInput="B" UIFormat="C M1"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MSRM_DATE">검사일시</dt>
						<dd>
							<input type="text" name="MSRM_DATE" UIInput="B" UIFormat="C"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PCODE">지종코드</dt>
						<dd>
							<input type="text" name="MAS001.PCODE" UIInput="SR,PCODE" UIFormat="U"/>
						</dd>
					</dl>
					 <dl>
						<dt CL="STD_BS_WGT">평량</dt>
						<dd>
							<input type="text" name="BS_WGT" UIInput="SR" UIFormat="U" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_ORDER_NO">오더번호</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 오더번호 RANGE 검색 추가 -->
							<input type="text" class="input" name="ORDER_NO" UIInput="SR" UIFormat="U" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_LOT_NO">LOT번호</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 오더번호 RANGE 검색 추가 -->
							<input type="text" class="input" name="Q20.LOT_NO" UIInput="SR" UIFormat="U" />
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
					<li><a href="#tab1-1"><span CL="STD_GRD_QLT14">검사이력</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-1">
					<div class="table_list01">
						<div class="table_thead tableHeader" style="margin-left: 0px;">
							<table>
								<colgroup>
									<!-- 번호 ~ 검사일시 18개 -->
									<col width="40px"/>
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="120px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px"/>
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="140px" />
									
									<!-- 1. 물리적상태검사 -->
									<!-- 	i) 실평량  -->
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<!-- 	ii) 두께  -->
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<!-- 	iii) 밀도 -->
									<col width="100px" />
									<!-- 	iv) 수분 -->
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<!-- 	v) 백색도 -->
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<!-- 	vi) 광택도 -->
									<col width="100px" />
									<!-- 	vii) PPS -->
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<!-- 	viii) 평활도 -->
									<col width="100px" />
									<!-- 	ix) 흡수도 -->
									<col width="100px" />
									<col width="100px" />
									<!-- 	x) 인쇄층분리 -->
									<col width="100px" />
									<!-- 	xi) 픽킹 -->
									<col width="100px" />
									<!-- 	xii) 모틀링 -->
									<col width="100px" />
									<!-- 	xiii) Curl -->
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<!-- 	xiv) 내절도 -->
									<col width="100px" />
									<col width="100px" />
									<!-- 	xv) Stiffness -->
									<col width="100px" />
									<col width="100px" />
									<!-- 	xvi) 파열강도 -->
									<col width="100px" />
									<!-- 	xvii) 톰슨 -->
									<col width="100px" />
									<col width="100px" />
									<!-- 	xviii) 중간 -->
									<col width="100px" />
									<!-- 	xix) 인터널 -->
									<col width="100px" />
									<col width="100px" />
									
									<!-- 2. 반점검사 -->
									<!-- 	i) 색반점 -->
									<col width="100px" />
									<!-- 	ii) 표면반점 -->
									<col width="100px" />
									<!-- 	iii) 기름반점 -->
									<col width="100px" />
									<col width="100px" />
									<!-- 	iv) 화면반점 -->
									<col width="100px" />
									
									<!-- 3. 관능 -->
									<!-- 	i) 냄새 -->
									<col width="100px" />
									
									<!-- 4. 부착량상태 DATA -->
									<!-- 	i) 표면 -->
									<col width="120px" />
									<col width="120px" />
									<!-- 	ii) 이면 -->
									<col width="120px" />
									<col width="120px" />
									<!-- 	iii) 후이면 -->
									<col width="120px" />
									<col width="120px" />
									<!-- 	iv) 후면 -->
									<col width="120px" />
									<col width="120px" />
									<!-- 	v) 뒤비침 -->
									<col width="100px" />
									
									<!-- 5. 뭉치검사 -->
									<!-- 	i) 뭉치 -->
									<col width="100px" />
									<col width="100px" />
									<!-- 	ii) 외관 -->
									<col width="100px" />
									<!-- 	iii) 선속 -->
									<col width="100px" />
									
									<!-- 6. 색상 -->
									<!-- 	i) 표면 -->
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<!-- 	ii) 후면 -->
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<!-- 	iii) 후면 껄 -->
									<col width="100px" />
									
									<!-- 7. 금속검출 -->
									<!-- 	i) 금속검출 -->
									<col width="120px" />
									<col width="120px" />
									<col width="120px" />
									<col width="120px" />
									<col width="120px" />
									
									<!-- 8. 공정현황 -->
									<!-- 	i) 전분 -->
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<!-- 	ii) 원료배합 -->
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<!-- 	iii) 공정특이사항 -->
									<col width="100px" />
									
									<!-- 자재명 ~ 비고사항 4개 -->
									<col width="320px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
								</colgroup>
								<thead>
									<tr>
										<th rowspan="3">번호</th>
										<th rowspan="3" CL="STD_MACHINETXT">생산호기명</th>
										<th rowspan='3' CL='STD_ORDER_NO'>오더번호</th>
										<th rowspan="3" CL="STD_LOT_NO">LOT번호</th>
										<th rowspan="3" CL="STD_IND_BCD">개별바코드</th>
										<th rowspan="3" CL="STD_WRK_CLASS">반</th>
										<th rowspan="3" CL="STD_PCODE">지종코드</th>
										<th rowspan="3" CL="STD_BS_WGT">평량</th>
										<th rowspan="3" CL="STD_PRDTYPE">생산라인구분</th>
										<th rowspan="3" CL="STD_RSPEED">선속</th>
										<th rowspan="3" CL="STD_PRD_DT">생산일자</th>
										<th rowspan="3" CL="STD_PRFM_DT">실적일자</th>
										<th rowspan="3" CL="STD_STR_TM">시작시간</th>
										<th rowspan="3" CL="STD_END_TM">종료시간</th>
										<th rowspan="3" CL="STD_TM">생산시간(분)</th>
										<th rowspan="3" CL="STD_JROLLCNT">J/R권치수(M)</th>
										<th rowspan="3" CL="STD_ROLLUNIT">권치수단위</th>										
										<th rowspan="3" CL="STD_WGT">중량</th>
										<th rowspan="3" CL="STD_WUNIT">중량단위</th>
										<th rowspan="3" CL="STD_MSRM_NM">검사자</th>
										<th rowspan="3" CL="STD_MSRM_DATE">검사일시</th>
										
										<!-- 1. 물리적상태검사 -->
										<th colspan="44" CL="STD_CLASS_LEVEL1_1">물리적상태검사</th>
										<!-- 2. 반점검사 -->
										<th colspan="5" CL="STD_CLASS_LEVEL1_2">반점검사</th>
										<!-- 3. 관능 -->
										<th CL="STD_CLASS_LEVEL1_3">관능</th>
										<!-- 4. 부착량상태 DATA -->
										<th colspan="9" CL="STD_CLASS_LEVEL1_4">부착량상태 DATA</th>
										<!-- 5. 뭉치검사 -->
										<th colspan="4" CL="STD_CLASS_LEVEL1_5">뭉치검사</th>
										<!-- 6. 색상 -->
										<th colspan="9" CL="STD_CLASS_LEVEL1_6">색상</th>
										<!-- 7. 금속검출 -->
										<th colspan="5" CL="STD_CLASS_LEVEL1_7">금속검출</th>
										<!-- 8. 공정현황 -->
										<th colspan="14" CL="STD_CLASS_LEVEL1_8">공정현황</th>
										
										<th rowspan="3" CL="STD_MATNR_NM">규격</th>
										<th rowspan="3" CL="STD_REGNM">J/R작업자</th>
										<th rowspan="3" CL="STD_ROUTE">항차</th>
										<th rowspan="3" CL="STD_ORDER_RMK">비고사항</th>
									</tr>
									<tr>
										<!-- 1. 물리적상태검사 -->
										<th colspan="4" CL="STD_CLASS_LEVEL2_1">실평량</th>
										<th colspan="4" CL="STD_CLASS_LEVEL2_2">두께</th>
										<th rowspan="2" CL="STD_CLASS_LEVEL2_3">밀도</th>
										<th colspan="4" CL="STD_CLASS_LEVEL2_4">수분</th>
										<th colspan="5" CL="STD_CLASS_LEVEL2_5">백색도</th>
										<th rowspan="2" CL="STD_CLASS_LEVEL2_6">광택도</th>
										<th colspan="5" CL="STD_CLASS_LEVEL2_7">PPS</th>
										<th rowspan="2" CL="STD_CLASS_LEVEL2_8">평활도</th>
										<th colspan="2" CL="STD_CLASS_LEVEL2_9">흡수도</th>
										<th rowspan="2" CL="STD_CLASS_LEVEL2_10">인쇄층분리</th>
										<th rowspan="2" CL="STD_CLASS_LEVEL2_11">픽킹</th>
										<th rowspan="2" CL="STD_CLASS_LEVEL2_12">모틀링</th>
										<th colspan="4" CL="STD_CLASS_LEVEL2_13">Curl</th>
										<th colspan="2" CL="STD_CLASS_LEVEL2_14">내절도</th>
										<th colspan="2" CL="STD_CLASS_LEVEL2_15">Stiffness</th>
										<th rowspan="2" CL="STD_CLASS_LEVEL2_16">파열강도</th>
										<th colspan="2" CL="STD_CLASS_LEVEL2_17">톰슨</th>
										<th CL="STD_CLASS_LEVEL2_18">층간</th>
										<th colspan="2" CL="STD_CLASS_LEVEL2_19">인터널</th>
										
										<!-- 2. 반점검사 -->
										<th rowspan="2" CL="STD_CLASS_LEVEL2_20">색반점</th>
										<th rowspan="2" CL="STD_CLASS_LEVEL2_21">표면반점</th>
										<th colspan="2" CL="STD_CLASS_LEVEL2_22">기름반점</th>
										<th rowspan="2" CL="STD_CLASS_LEVEL2_23">화면반점</th>
										
										<!-- 3. 관능 -->
										<th rowspan="2" CL="STD_CLASS_LEVEL2_24">냄새</th>
										
										<!-- 4. 부착량상태 DATA -->
										<th colspan="2" CL="STD_CLASS_LEVEL2_25">표면</th>
										<th colspan="2" CL="STD_CLASS_LEVEL2_26">이면</th>
										<th colspan="2" CL="STD_CLASS_LEVEL2_27">후이면</th>
										<th colspan="2" CL="STD_CLASS_LEVEL2_28">이면</th>
										<th rowspan="2" CL="STD_CLASS_LEVEL2_29">뒤비침</th>
										
										<!-- 5. 뭉치검사 -->
										<th colspan="2" CL="STD_CLASS_LEVEL2_30">뭉치</th>
										<th CL="STD_CLASS_LEVEL2_31">외관</th>
										<th rowspan="2" CL="STD_CLASS_LEVEL2_32">선속</th>
										
										<!-- 6. 색상 -->
										<th colspan="4" CL="STD_CLASS_LEVEL2_33">표면</th>
										<th colspan="4" CL="STD_CLASS_LEVEL2_34">후면</th>
										<th rowspan="2" CL="STD_CLASS_LEVEL2_35">후면 껄</th>
										
										<!-- 7. 금속검출 -->
										<th rowspan="2" CL="STD_CLASS_LEVEL2_36">금속검출기(MD)</th>
										<th rowspan="2" CL="STD_CLASS_LEVEL2_37">금속검출기(CD)</th>
										<th rowspan="2" CL="STD_CLASS_LEVEL2_38">금속검출기(위상 각)</th>
										<th rowspan="2" CL="STD_CLASS_LEVEL2_39">금속검출기 20장(MD)</th>
										<th rowspan="2" CL="STD_CLASS_LEVEL2_40">금속검출기 20장(CD)</th>
										
										<!-- 8. 공정현황 -->
										<th colspan="3" CL="STD_CLASS_LEVEL2_41">전분</th>
										<th colspan="10" CL="STD_CLASS_LEVEL2_42">원료배합</th>
										<th rowspan="2" CL="STD_CLASS_LEVEL2_43">공정특이사항</th>
									</tr>
									<tr>
										<!-- 1. 물리적상태검사 -->
										<!-- 	i) 실평량 -->
										<th CL="STD_CLASS_LEVEL3_1">평량(전측)</th>
										<th CL="STD_CLASS_LEVEL3_2">평량(중측)</th>
										<th CL="STD_CLASS_LEVEL3_3">평량(후측)</th>
										<th CL="STD_CLASS_LEVEL3_4">평량(평균)</th>
										<!-- 	ii) 두께 -->
										<th CL="STD_CLASS_LEVEL3_5">두께(전측)</th>
										<th CL="STD_CLASS_LEVEL3_6">두께(중측)</th>
										<th CL="STD_CLASS_LEVEL3_7">두께(후측)</th>
										<th CL="STD_CLASS_LEVEL3_8">두께(평균)</th>
										<!-- 	iii) 밀도 -->
										<!-- 	iv) 수분 -->
										<th CL="STD_CLASS_LEVEL3_9">수분(전측)</th>
										<th CL="STD_CLASS_LEVEL3_10">수분(중측)</th>
										<th CL="STD_CLASS_LEVEL3_11">수분(후측)</th>
										<th CL="STD_CLASS_LEVEL3_12">수분(평균)</th>
										<!-- 	v) 백색도 -->
										<th CL="STD_CLASS_LEVEL3_13">표면 백색도(전측)</th>
										<th CL="STD_CLASS_LEVEL3_14">표면 백색도(중측)</th>
										<th CL="STD_CLASS_LEVEL3_15">표면 백색도(후측)</th>
										<th CL="STD_CLASS_LEVEL3_16">표면 백색도(평균)</th>
										<th CL="STD_CLASS_LEVEL3_17">표면 백색도(후측)</th>
										<!-- 	vi) 광택도 -->
										<!-- 	vii) PPS -->
										<th CL="STD_CLASS_LEVEL3_18">표면 PPS(전측)</th>
										<th CL="STD_CLASS_LEVEL3_19">표면 PPS(중측)</th>
										<th CL="STD_CLASS_LEVEL3_20">표면 PPS(후측)</th>
										<th CL="STD_CLASS_LEVEL3_21">표면 PPS(평균)</th>
										<th CL="STD_CLASS_LEVEL3_22">후면 PPS</th>
										<!-- 	viii) 평활도 -->
										<!-- 	ix) 흡수도 -->
										<th CL="STD_CLASS_LEVEL3_23">흡수도(표면)</th>
										<th CL="STD_CLASS_LEVEL3_24">흡수도(후면)</th>
										<!-- 	x) 인쇄층분리 -->
										<!-- 	xi) 픽킹 -->
										<!-- 	xii) 모틀링 -->
										<!-- 	xiii) Curl -->
										<th CL="STD_CLASS_LEVEL3_25">Curl 방향</th>
										<th CL="STD_CLASS_LEVEL3_26">Curl 높이(전측)</th>
										<th CL="STD_CLASS_LEVEL3_27">Curl 높이(중측)</th>
										<th CL="STD_CLASS_LEVEL3_28">Curl 높이(후측)</th>
										<!-- 	xiv) 내절도 -->
										<th CL="STD_CLASS_LEVEL3_29">내절도 MD</th>
										<th CL="STD_CLASS_LEVEL3_30">내절도 CD</th>
										<!-- 	xv) Stiffness -->
										<th CL="STD_CLASS_LEVEL3_31">Stiffness MD</th>
										<th CL="STD_CLASS_LEVEL3_32">Stiffness CD</th>
										<!-- 	xvi) 파열강도 -->
										<!-- 	xvii) 톰슨 -->
										<th CL="STD_CLASS_LEVEL3_33">톰슨(표면)</th>
										<th CL="STD_CLASS_LEVEL3_34">톰슨(후면)</th>
										<!-- 	xviii) 중간 -->
										<th CL="STD_CLASS_LEVEL3_35">Blister pack</th>
										<!-- 	xix) 인터널 -->
										<th CL="STD_CLASS_LEVEL3_36">층간</th>
										<th CL="STD_CLASS_LEVEL3_37">인터널</th>
										
										<!-- 2. 반점검사 -->
										<!-- 	i) 색반점 -->
										<!-- 	ii) 표면반점 -->
										<!-- 	iii) 기름반점 -->
										<th CL="STD_CLASS_LEVEL3_38">기름반점(표면)</th>
										<th CL="STD_CLASS_LEVEL3_39">기름반점(후면)</th>
										<!-- 	iv) 화면반점 -->
										
										<!-- 3. 관능 -->
										<!-- 	i) 냄새 -->
										
										<!-- 4. 부착량상태 DATA -->
										<!-- 	i) 표면 -->
										<th CL="STD_CLASS_LEVEL3_40">표면 부착량</th>
										<th CL="STD_CLASS_LEVEL3_41">표면 원료 백색도</th>
										<!-- 	ii) 이면 -->
										<th CL="STD_CLASS_LEVEL3_42">이면 부착량</th>
										<th CL="STD_CLASS_LEVEL3_43">이면 원료 백색도</th>
										<!-- 	iii) 후이면 -->
										<th CL="STD_CLASS_LEVEL3_44">후이면 부착량</th>
										<th CL="STD_CLASS_LEVEL3_45">후이면 원료 백색도</th>
										<!-- 	iv) 후면 -->
										<th CL="STD_CLASS_LEVEL3_46">후면 부착량</th>
										<th CL="STD_CLASS_LEVEL3_47">후면 원료 백색도</th>
										<!-- 	v) 뒤비침 -->
										
										<!-- 5. 뭉치검사 -->
										<!-- 	i) 뭉치 -->
										<th CL="STD_CLASS_LEVEL3_48">뭉치(위치,크기)</th>
										<th CL="STD_CLASS_LEVEL3_49">뭉치(제거여부)</th>
										<!-- 	ii) 외관 -->
										<th CL="STD_CLASS_LEVEL3_50">외관(염료줄)</th>
										
										<!-- 6. 색상 -->
										<!-- 	i) 표면 -->
										<th CL="STD_CLASS_LEVEL3_51">표면 색차(L)</th>
										<th CL="STD_CLASS_LEVEL3_52">표면 색차(a)</th>
										<th CL="STD_CLASS_LEVEL3_53">표면 색차(b)</th>
										<th CL="STD_CLASS_LEVEL3_54">표면 색차(△E)</th>
										<!-- 	ii) 후면 -->
										<th CL="STD_CLASS_LEVEL3_55">후면 색차(L)</th>
										<th CL="STD_CLASS_LEVEL3_56">후면 색차(a)</th>
										<th CL="STD_CLASS_LEVEL3_57">후면 색차(b)</th>
										<th CL="STD_CLASS_LEVEL3_58">후면 색차(△E)</th>
										<!-- 	iii) 후면 껄-->
										
										<!-- 7. 금속검출 -->
										<!-- 	i) 금속검출 -->
										
										<!-- 8. 공정현황 -->
										<!-- 	i) 전분 -->
										<th CL="STD_CLASS_LEVEL3_59">S/P 농도</th>
										<th CL="STD_CLASS_LEVEL3_60">B/C 농도</th>
										<th CL="STD_CLASS_LEVEL3_61">전분/코팅 농도</th>
										<!-- 	ii) 원료배합 -->
										<th CL="STD_CLASS_LEVEL3_62">표면 배합</th>
										<th CL="STD_CLASS_LEVEL3_63">표이면 배합</th>
										<th CL="STD_CLASS_LEVEL3_64">심면 배합</th>
										<th CL="STD_CLASS_LEVEL3_65">후이면 배합</th>
										<th CL="STD_CLASS_LEVEL3_66">후면 배합</th>
										<th CL="STD_CLASS_LEVEL3_67">목분 유량</th>
										<th CL="STD_CLASS_LEVEL3_68">표면 유량</th>
										<th CL="STD_CLASS_LEVEL3_69">표이면 유량</th>
										<th CL="STD_CLASS_LEVEL3_70">후이면 유량</th>
										<th CL="STD_CLASS_LEVEL3_71">후면 유량</th>
										<!-- 	iii) 공정특이사항 -->
									</tr>
								</thead>  
							</table>
						</div>
						<div class="scroll" style="height: calc(100% - 80px)">
							<table class="table_b">
								<tbody id="gridList">
									<tr CGRow="true">
										<!-- 번호 ~ 검사일시 18개 -->
										<td Gcol="rownum">번호</td>
										<td GCol="text,MACHINETXT" style="text-align:center;">생산호기명</td>
										<td GCol='text,ORDER_NO' style='text-align:center;'>오더번호</td>
										<td GCol="text,LOT_NO" style='text-align:center;'>LOT번호</td>
										<td GCol="text,IND_BCD" style='text-align:center;'>개별바코드</td>
										<td GCol="text,WRK_CLASS" style="text-align:center;">작업반</td>
										<td GCol="text,PCODE" style="text-align:center;">지종코드</td>
										<td GCol="text,BS_WGT" style="text-align:right;">평량</td>
										<td GCol="text,PRDTYPE" style="text-align:center;">생산라인구분</td>
										<td GCol="text,RSPEED" style="text-align:right;">선속</td>
										<td GCol="text,PRD_DT" GF="D" style="text-align:center;">생산일자</td>
										<td GCol="text,PRFM_DT" GF="D" style="text-align:center;">실적일자</td>
										<td GCol="text,STR_TM" GF="T" style="text-align:center;">시작시간</td>
										<td GCol="text,END_TM" GF="T" style="text-align:center;">종료시간</td>
										<td GCol="text,TM" GF="T" style="text-align:center;">생산시간(분)</td>
										<td GCol="text,JROLLCNT" GF="N 6">J/R권치수(M)</td>
										<td GCol='text,ROLLUNIT' style="text-align:center;">권치수단위</td>
										<td GCol="text,WGT" GF="N 13,3">중량</td>
										<td GCol='text,WUNIT' style="text-align:center;">중량단위</td>
										<td GCol="text,MSRM_NM">검사자</td>
										<td GCol="text,MSRM_DATE" style="text-align:center;">검사일시</td>
										
										<!-- 1. 물리적상태검사 -->
										<!-- 	i) 실평량 -->										
										<td GCol="text,CLASS_LEVEL3_1" style="text-align:right;">평량(전측)</td>
										<td GCol="text,CLASS_LEVEL3_2" style="text-align:right;">평량(중측)</td>
										<td GCol="text,CLASS_LEVEL3_3" style="text-align:right;">평량(후측)</td>
										<td GCol="text,CLASS_LEVEL3_4" style="text-align:right;">평량(평균)</td>
										<!-- 	ii) 두께 -->
										<td GCol="text,CLASS_LEVEL3_5" style="text-align:right;">두께(전측)</td>
										<td GCol="text,CLASS_LEVEL3_6" style="text-align:right;">두께(중측)</td>
										<td GCol="text,CLASS_LEVEL3_7" style="text-align:right;">두께(후측)</td>
										<td GCol="text,CLASS_LEVEL3_8" style="text-align:right;">두께(평균)</td>
										<!-- 	iii) 밀도-->
										<td GCol="text,CLASS_LEVEL2_3" style="text-align:right;">밀도</td>
										<!-- 	iv) 수분 -->
										<td GCol="text,CLASS_LEVEL3_9"  style="text-align:right;">수분(전측)</td>
										<td GCol="text,CLASS_LEVEL3_10" style="text-align:right;">수분(중측)</td>
										<td GCol="text,CLASS_LEVEL3_11" style="text-align:right;">수분(후측)</td>
										<td GCol="text,CLASS_LEVEL3_12" style="text-align:right;">수분(평균)</td>
										<!-- 	v) 백색도 -->
										<td GCol="text,CLASS_LEVEL3_13" style="text-align:right;">표면 백색도(전측)</td>
										<td GCol="text,CLASS_LEVEL3_14" style="text-align:right;">표면 백색도(중측)</td>
										<td GCol="text,CLASS_LEVEL3_15" style="text-align:right;">표면 백색도(후측)</td>
										<td GCol="text,CLASS_LEVEL3_16" style="text-align:right;">표면 백색도(평균)</td>
										<td GCol="text,CLASS_LEVEL3_17" style="text-align:right;">후면 백색도</td>
										<!-- 	vi) 광택도 -->
										<td GCol="text,CLASS_LEVEL2_6"  style="text-align:right;">광택도</td>
										<!-- 	vii) PPS -->
										<td GCol="text,CLASS_LEVEL3_18" style="text-align:right;">표면 PPS(전측)</td>
										<td GCol="text,CLASS_LEVEL3_19" style="text-align:right;">표면 PPS(중측)</td>
										<td GCol="text,CLASS_LEVEL3_20" style="text-align:right;">표면 PPS(후측)</td>
										<td GCol="text,CLASS_LEVEL3_21" style="text-align:right;">표면 PPS(평균)</td>
										<td GCol="text,CLASS_LEVEL3_22" style="text-align:right;">후면 PPS</td>
										<!-- 	viii) 평활도 -->
										<td GCol="text,CLASS_LEVEL2_8" style="text-align:right;">평활도</td>
										<!-- 	ix) 흡수도 -->
										<td GCol="text,CLASS_LEVEL3_23" style="text-align:right;">흡수도(표면)</td>
										<td GCol="text,CLASS_LEVEL3_24" style="text-align:right;">흡수도(후면)</td>
										<!-- 	x) 인쇄층분리 -->
										<td GCol="text,CLASS_LEVEL2_10" style="text-align:right;">인쇄층분리</td>
										<!-- 	xi) 픽킹 -->
										<td GCol="text,CLASS_LEVEL2_11" style="text-align:right;">픽킹</td>
										<!-- 	xii) 모틀링 -->
										<td GCol="text,CLASS_LEVEL2_12" style="text-align:right;">모틀링</td>
										<!-- 	xiii) Curl -->
										<td GCol="text,CLASS_LEVEL3_25">Curl 방향</td>
										<td GCol="text,CLASS_LEVEL3_26" style="text-align:right;">Curl 높이(전측)</td>
										<td GCol="text,CLASS_LEVEL3_27" style="text-align:right;">Curl 높이(중측)</td>
										<td GCol="text,CLASS_LEVEL3_28" style="text-align:right;">Curl 높이(후측)</td>
										<!-- 	xiv) 내절도 -->
										<td GCol="text,CLASS_LEVEL3_29" style="text-align:right;">내절도 MD</td>
										<td GCol="text,CLASS_LEVEL3_30" style="text-align:right;">내절도 CD</td>
										<!-- 	xv) Stiffness -->
										<td GCol="text,CLASS_LEVEL3_31" style="text-align:right;">Stiffness MD</td>
										<td GCol="text,CLASS_LEVEL3_32" style="text-align:right;">Stiffness CD</td>
										<!-- 	xvi) 파열강도 -->
										<td GCol="text,CLASS_LEVEL2_16" style="text-align:right;">파열강도</td>
										<!-- 	xvii) 톰슨 -->
										<td GCol="text,CLASS_LEVEL3_33" style="text-align:right;">톰슨(표면)</td>
										<td GCol="text,CLASS_LEVEL3_34" style="text-align:right;">톰슨(후면)</td>
										<!-- 	xviii) 중간 -->
										<td GCol="text,CLASS_LEVEL3_35" style="text-align:right;">Blister pack</td>
										
										<!-- 	xix) 인터널 -->
										<td GCol="text,CLASS_LEVEL3_36" style="text-align:right;">층간</td>
										<td GCol="text,CLASS_LEVEL3_37" style="text-align:right;">인터널</td>
										
										<!-- 2. 반점검사 -->
										<!-- 	i) 색반점 -->
										<td GCol="text,CLASS_LEVEL2_20" style="text-align:right;">색반점</td>
										<!-- 	ii) 표면반점 -->
										<td GCol="text,CLASS_LEVEL2_21" style="text-align:right;">표면반점</td>
										<!-- 	iii) 기름반점 -->
										<td GCol="text,CLASS_LEVEL3_38" style="text-align:right;">기름반점(표면)</td>
										<td GCol="text,CLASS_LEVEL3_39" style="text-align:right;">기름반점(후면)</td>
										<!-- 	iv) 화면반점 -->
										<td GCol="text,CLASS_LEVEL2_23" style="text-align:right;">화면반점</td>
										
										<!-- 3. 관능 -->
										<!-- 	i) 냄새 -->
										<td GCol="text,CLASS_LEVEL2_24" style="text-align:right;">냄새</td>
										
										<!-- 4. 부착량상태 DATA -->
										<!-- 	i) 표면 -->
										<td GCol="text,CLASS_LEVEL3_40" style="text-align:right;">표면 부착량</td>
										<td GCol="text,CLASS_LEVEL3_41" style="text-align:right;">표면 원료 백색도</td>
										<!-- 	ii) 이면 -->
										<td GCol="text,CLASS_LEVEL3_42" style="text-align:right;">이면 부착량</td>
										<td GCol="text,CLASS_LEVEL3_43" style="text-align:right;">이면 원료 백색도</td>
										<!-- 	iii) 후이면 -->
										<td GCol="text,CLASS_LEVEL3_44" style="text-align:right;">후이면 부착량</td>
										<td GCol="text,CLASS_LEVEL3_45" style="text-align:right;">후이면 원료 백색도</td>
										<!-- 	iv) 후면 -->
										<td GCol="text,CLASS_LEVEL3_46" style="text-align:right;">후면 부착량</td>
										<td GCol="text,CLASS_LEVEL3_47" style="text-align:right;">후면 원료 백색도</td>
										<!-- 	v) 뒤비침 -->
										<td GCol="text,CLASS_LEVEL2_29" style="text-align:right;">뒤비침</td>
										
										<!-- 5. 뭉치검사 -->
										<!-- 	i) 뭉치 -->
										<td GCol="text,CLASS_LEVEL3_48" style="text-align:right;">뭉치(위치,크기)</td>
										<td GCol="text,CLASS_LEVEL3_49" style="text-align:right;">뭉치(제거여부)</td>
										<!-- 	ii) 외관 -->
										<td GCol="text,CLASS_LEVEL3_50" style="text-align:right;">외관(염료줄)</td>
										<!-- 	iii) 선속 -->
										<td GCol="text,CLASS_LEVEL2_32" style="text-align:right;">선속</td>
										
										<!-- 6. 색상 -->
										<!-- 	i) 표면 -->
										<td GCol="text,CLASS_LEVEL3_51" style="text-align:right;">표면 색차(L)</td>
										<td GCol="text,CLASS_LEVEL3_52" style="text-align:right;">표면 색차(a)</td>
										<td GCol="text,CLASS_LEVEL3_53" style="text-align:right;">표면 색차(b)</td>
										<td GCol="text,CLASS_LEVEL3_54" style="text-align:right;">표면 색차(△E)</td>
										<!-- 	ii) 후면 -->
										<td GCol="text,CLASS_LEVEL3_55" style="text-align:right;">후면 색차(L)</td>
										<td GCol="text,CLASS_LEVEL3_56" style="text-align:right;">후면 색차(a)</td>
										<td GCol="text,CLASS_LEVEL3_57" style="text-align:right;">후면 색차(b)</td>
										<td GCol="text,CLASS_LEVEL3_58" style="text-align:right;">후면 색차(△E)</td>
										<!-- 	iii) 후면 껄 -->
										<td GCol="text,CLASS_LEVEL2_35" style="text-align:right;">후면 껄</td>
										
										<!-- 7. 금속검출 -->
										<!-- 	i) 금속검출 -->
										<td GCol="text,CLASS_LEVEL2_36" style="text-align:right;">금속검출기(MD)</td>
										<td GCol="text,CLASS_LEVEL2_37" style="text-align:right;">금속검출기(CD)</td>
										<td GCol="text,CLASS_LEVEL2_38" style="text-align:right;">금속검출기(위상 각)</td>
										<td GCol="text,CLASS_LEVEL2_39" style="text-align:right;">금속검출기 20장(MD)</td>
										<td GCol="text,CLASS_LEVEL2_40" style="text-align:right;">금속검출기 20장(CD)</td>
										
										<!-- 8. 공정현황 -->
										<!-- 	i) 전분 -->
										<td GCol="text,CLASS_LEVEL3_59" style="text-align:right;">S/P 농도</td>
										<td GCol="text,CLASS_LEVEL3_60" style="text-align:right;">B/C 농도</td>
										<td GCol="text,CLASS_LEVEL3_61" style="text-align:right;">전분/코팅 농도</td>
										<!-- 	ii) 원료배합 -->
										<td GCol="text,CLASS_LEVEL3_62">표면 배합</td>
										<td GCol="text,CLASS_LEVEL3_63">표이면 배합</td>
										<td GCol="text,CLASS_LEVEL3_64">심면 배합</td>
										<td GCol="text,CLASS_LEVEL3_65">후이면 배합</td>
										<td GCol="text,CLASS_LEVEL3_66">후면 배합</td>
										<td GCol="text,CLASS_LEVEL3_67" style="text-align:right;">목분 유량</td>
										<td GCol="text,CLASS_LEVEL3_68" style="text-align:right;">표면 유량</td>
										<td GCol="text,CLASS_LEVEL3_69" style="text-align:right;">표이면 유량</td>
										<td GCol="text,CLASS_LEVEL3_70" style="text-align:right;">후이면 유량</td>
										<td GCol="text,CLASS_LEVEL3_71" style="text-align:right;">후면 유량</td>
										<!-- 	iii) 공정특이사항 -->
										<td GCol="text,CLASS_LEVEL2_43">공정특이사항</td>
										
										<!-- 자재명 ~ 비고사항 4개 -->
										<td GCol="text,MATNR_NM">자재명</td>
										<td GCol="text,REGNM">등록자</td>
										<td GCol="text,ROUTE">항차</td>
										<td GCol="text,ORDER_RMK">비고사항</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
                    	<jsp:param value="1" name="authCd"/>
                    	<jsp:param value="1,2,3,7,9,10" name="showAuthCd"/>
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