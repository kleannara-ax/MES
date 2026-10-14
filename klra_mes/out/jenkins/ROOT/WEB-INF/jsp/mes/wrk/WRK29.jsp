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
			url : "/mes/Work/WRK29/json/datalist.data",
			bigdata:false,
	    });
	});

	function searchList(){
		if(validate.check("searchArea")){
			// 2023-03-13(월요일) 안상현, RANGE 검색 추가
			/* const range = inputList.setRangeParam("searchArea")
			const range_data_param = range.get("RANGE_DATA_PARAM")
			const prfm_dt = range_data_param.get("WRK002.PRFM_DT_Range")
			const date = prfm_dt.split("↓")
			const SDate = date[1]
			const EDate = date[2] */
			
			const param = inputList.setRangeParam("searchArea")
			param.put("P_TYPE", "LIST")
			//param.put("SDATE", SDate)
			//param.put("EDATE", EDate)
			
			//param.put("MACHINE",$("#MACHINE").val()) // 생산호기
			
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
	function comboEventDataBindeBefore(comboAtt) {
		if(comboAtt == "Produce,MACHINE"){
			var param = new DataMap();
			param.put("WERKS", 'P100');  // PS는 플랜트 P100
		}
		return param;
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
						<dd>
							<input type="text" name="PRFM_DT" id="PRFM_DT" UIInput="B" UIFORMAT="C M1"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MACHINE">생산호기</dt>
						<dd>
							<select class="input" id="MACHINE" name="MACHINE" Combo="Produce,MACHINE">
								<option value="">선택</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="지종">지종</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 지종코드 RANGE 검색 추가 -->
							<input type="text" name="PCODE" id="PCODE" UIInput="SR,PCODE" UIFormat="U"/>
						</dd>
					</dl>
					
					<dl>
						<dt CL="평량">평량</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 평량 RANGE 검색 추가 -->
							<input type="text" name="BS_WGT" id="BS_WGT" class="input" IAname="BS_WGT" UIInput="SR" UIFormat="U"/>
						</dd>
					</dl>
					
					<dl>
						<dt CL="가로">가로</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 가로 RANGE 검색 추가 -->
							<input type="text" name="WLEN" id="WLEN" class="input" IAname="WLEN" UIInput="SR" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="세로">세로</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 세로 RANGE 검색 추가 -->
							<input type="text" name="VLEN" id="VLEN" class="input" IAname="VLEN" UIInput="SR" UIFormat="U"/>
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
					<li><a href="#tab1-1"><span CL="STD_GRD_WRK29">일반</span></a></li>
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
										<td GH="180" GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH="320" GCol="text,MATNR_NM">자재코드</td>
										<td GH="100" GCol="text,IND_BCD" style="text-align: center">개별바코드</td>
										<td GH="100" GCol="text,LOT_NO" style="text-align: center">LOT NO</td>
										<td GH="100 지종" GCol="text,PCODE" style="text-align:center"></td>
										<td GH="100 평량" GCol="text,BS_WGT" style="text-align:center"></td>
										<td GH="100 가로길이" GCol="text,WLEN" style="text-align:center"></td>
										<td GH="100" GCol="text,VLEN" style="text-align:center"></td>
										<td GH="100 규격" GCol="text,MATNR_SPEC"></td>
										<td GH="100 포장방법" GCol="text,PACKTYPE" style="text-align:center"></td>
										<td GH="100 연수" GCol="text,PCNT" GF="N 13,1"></td>
										<td GH='80' GCol='text,RUNIT' style="text-align:center;">연수단위</td>
										
										<td GH="100" GCol="text,WGT" GF="N 13,3">중량</td>
										<td GH="100" GCol="text,WUNIT" style="text-align:center;">중량단위</td>
										
										<td GH="100 판매오더" GCol="text,VBELN" style="text-align:center"></td>
										<td GH="100 항차" GCol="text,ROUTE" style="text-align: center"></td>
										<td GH="100 생산일자" GCol="text,PRD_DT" GF="D" style="text-align:center"></td>
										<td GH="100 호기" GCol="text,MACHINE" style="text-align: center"></td>
										<td GH="100 C/T" GCol="text,CJOB_IND_BCD" style="text-align: center"></td>
										<td GH="100 M/R" GCol="text,MJOB_IND_BCD" style="text-align: center"></td>
										<td GH="100 J/R" GCol="text,JJOB_IND_BCD" style="text-align: center"></td>
										<td GH="100 비고" GCol="text,RMK"></td>
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