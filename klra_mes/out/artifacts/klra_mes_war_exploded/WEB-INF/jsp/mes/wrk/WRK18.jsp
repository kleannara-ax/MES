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
	    	url : "/mes/Work/WRK18/json/datalist.data",
	    	bigdata : false,
	    	colHoldType : true,
	    	colHold : "DISPO_CD,DISPO_NM"
	    });
	});

	// 조회
	function searchList(){
		if(validate.check("searchArea")){
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
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    })
		}
	}
	
	// 버튼(조회, 저장 등) 클릭
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
						<dt CL="STD_DISPO_CD">폐품코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 폐품코드 RANGE 검색 추가 -->
							<input type="text" class="input" id="DISPO_CD" name="DISPO_CD" UIInput="SR,ERR" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PRFM_DT">실적일자</dt>
						<dd>
							<input type="text" class="input" name="PRFM_DT" UIInput="B" UIFormat="C M1"/>
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
					<li><a href="#tab1-1"><span CL="STD_GRD_WRK18">일반</span></a></li>
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
										<td GH="100" GCol="text,DISPO_CD" style="text-align: right;">폐품코드</td>
										<td GH="150" GCol="text,DISPO_NM">폐품명</td>
										<td GH="150" GCol="text,MA_2_JUM" GF="N 10,3">2호기 점보롤</td>
										<td GH="150" GCol="text,MA_2_MIL" GF="N 10,3">2호기 밀롤</td>
										<td GH="150" GCol="text,MA_2_SL" GF="N 10,3">2호기 슬리터</td>
										
										<td GH="150" GCol="text,MA_2_JAE" GF="N 10,3">2호기 재단</td>
										<td GH="150" GCol="text,MA_2_JAEM" GF="N 10,3">2호기 수재단</td>
										<td GH="150" GCol="text,MA_2_PO" GF="N 10,3">2호기 포장</td>

										<td GH="150" GCol="text,MA_2_GYE" GF="N 10,3">2호기 계</td>
										
										<td GH="150" GCol="text,MA_3_JUM" GF="N 10,3">3호기 점보롤</td>
										<td GH="150" GCol="text,MA_3_MIL" GF="N 10,3">3호기 밀롤</td>
										<td GH="150" GCol="text,MA_3_SL" GF="N 10,3">3호기 슬리터</td>
										
										<td GH="150" GCol="text,MA_3_JAE" GF="N 10,3">3호기 재단</td>
										<td GH="150" GCol="text,MA_3_JAEM" GF="N 10,3">3호기 수재단</td>
										
										<td GH="150" GCol="text,MA_3_PO" GF="N 10,3">3호기 포장</td>
										<td GH="150" GCol="text,MA_3_GYE" GF="N 10,3">3호기 계</td>
										<td GH="150" GCol="text,TOT_JUM" GF="N 10,3">점보롤 합계</td>
										<td GH="150" GCol="text,TOT_MIL" GF="N 10,3">밀롤 합계</td>
										<td GH="150" GCol="text,TOT_JAE" GF="N 10,3">재단 합계</td>
										<td GH="150" GCol="text,TOT_SJAE" GF="N 10,3">수재단 합계</td>
										<td GH="150" GCol="text,TOT_SIL" GF="N 10,3">슬리터 합계</td>
										<td GH="150" GCol="text,TOT_PO" GF="N 10,3">포장 합계</td>
										<td GH="150" GCol="text,TOT" GF="N 10,3">총 합계</td>
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