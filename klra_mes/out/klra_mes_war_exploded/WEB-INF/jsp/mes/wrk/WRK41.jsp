<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>MES</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function() {
		gridList.setGrid({
	    	id : "gridList",
	    	url : "/mes/Work/WRK41/json/datalist.data",
	    	bigdata : false
	    });
	});

	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "Produce,MACHINE"){
			var param = new DataMap();
			
			param.put("WERKS", 'P100');
		}
		return param;
	}
	
	function searchList(){
		if(validate.check("searchArea")){
			// 2023-03-13(월요일) 안상현, RANGE 검색 추가
			/* const range = inputList.setRangeParam("searchArea")
			const range_data_param = range.get("RANGE_DATA_PARAM")
			const inp_dt = range_data_param.get("INP_DT_Range")
			const date = inp_dt.split("↓")
			const SDate = date[1]
			const EDate = date[2] */
			
			const param = inputList.setRangeParam("searchArea")
			param.put("P_TYPE", "LIST")
			/* param.put("SDATE", SDate)
			param.put("EDATE", EDate)
			param.put("MACHINE", $("#MACHINE").val()) // 생산호기
			param.put("MAT_LINE_CD", $("#MAT_LINE_CD").val()) // 원료라인 */
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    })
		}
	}
	
	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
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
						<dt CL="STD_INP_DT">투입일자</dt>
						<dd>
							<input type="text" class="input" name="INV006.INP_DT" UIInput="B" UIFormat="C M1"/>
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
						<dt CL="STD_MAT_LINE_CD">원료라인</dt>
						<dd>
							<select class="input" id="MAT_LINE_CD" name="MAT_LINE_CD" CommonCombo="MATLINECD">
								<option value="">All</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 자재코드 RANGE 검색 추가 -->
							<input type="text" class="input" name="INV006.MATNR" UIInput="SR,MATKY" UIFormat="U"/>
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
					<li><a href="#tab1-1"><span CL="STD_GRD_WRK41">리스트</span></a></li>
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
										<td GH="40" GCol="rownum">1</td>
<!-- 										<td GH="40" GCol="rowCheck"></td> -->
										<td GH="100" GCol="text,INP_DT" GF='D' style="text-align:center;">투입일자</td>
										<td GH="100" GCol="text,MACHINE" style="text-align:center;">호기</td>
										<td GH="100" GCol="text,MAT_LINE_CD" style="text-align:center;">원료라인</td>
										<td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH="320" GCol="text,MATNR_NM">자재명</td>
										<td GH="100" GCol="text,SUPY_CD" style="text-align:center;">공급업체</td>
										<td GH="130" GCol="text,SUPY_NM">공급업체명</td>
										<td GH="100" GCol="text,WEIGHT_QTY" GF='N 13'>베일수</td>
										<td GH="100 베일수단위" GCol="text,EAUNIT">베일수단위</td>
										
										<td GH="100" GCol="text,USE_QTY" GF='N 13'>사용량</td>
										<td GH="100 사용량단위" GCol="text,USE_UNIT">단위</td>
										
										<td GH="140" GCol="text,REGDATE" style="text-align:center;"></td>
										<td GH="100" GCol="text,REGNM"></td>
										<td GH="140" GCol="text,UPDDATE" style="text-align:center;"></td>
										<td GH="100" GCol="text,UPDNM"></td>
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