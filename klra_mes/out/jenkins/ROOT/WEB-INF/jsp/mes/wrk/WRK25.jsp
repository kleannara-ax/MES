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
	    	url : "/mes/Work/WRK25/json/datalist.data",
	    	bigdata : false
	    });
	});
	
	function comboEventDataBindeBefore(comboAtt) {
		if(comboAtt == "Produce,MACHINE"){
			var param = new DataMap();
			param.put("WERKS", 'P100');  // PS는 플랜트 P100
		}
		return param;
	}

	function searchList() {
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			
			param.put("P_TYPE","LIST");
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}
	
// 	function saveData() {
// 		if(gridList.validationCheck("gridList", "all")){
// 			gridList.gridSave({
// 		    	id : "gridList",
// 		    	modifyType : "A"
// 		    });
// 		}
// 	}

	function commonBtnClick(btnName) {
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search") {
			searchList();
		}
// 		else if (btnName == "Save") {
// 			saveData();
// 		}
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
						<dt CL="STD_PRD_REQ_DT">생산요청일자</dt>
						<dd>
							<input type="text" class="input" name="SCH015.PRD_REQ_DT" UIInput="B" UIFormat="C M1"/>
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
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
        <div class="search_next_wrap">
			<div class="content_layout tabs">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span CL="STD_GRD_WRK25">일반</span></a></li>
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
										<td GH="40" GCol="rownum">1</td>
										<td GH="100" GCol="text,JWRK_ORDR_NO" style="text-align: center">JR작업지시번호</td>
										<td GH="120" GCol="text,JWRK_ORDR_SEQNO" style="text-align: center">JR작업지시번호순번</td>
										
										<td GH="90 JRLOT" GCol="text,JJOB_IND_BCD" style="text-align: center"></td>
										<td GH="90 지종" GCol="text,PCODE" style="text-align: center"></td>
										<td GH="90 생산라인구분" GCol="text,PRDTYPETXT" style="text-align: center"></td>
										<td GH="120 JR계획권치수" GCol="text,JPLNROLLCNT"  GF='N 13,3'></td>
										<td GH="120 JR실적권치수" GCol="text,JROLLCNT"  GF='N 13,3'></td>
										<td GH="80" GCol="text,JROLLUNIT" style="text-align:center;">권치수단위</td>
										<td GH="120 MRLOT" GCol="text,MJOB_IND_BCD" style="text-align: center"></td>
										<td GH="140 MR작업지시번호" GCol="text,MJOB_WRK_ORDR_NO" style="text-align: center"></td>
										<td GH="120 MR작업지시순번" GCol="text,MJOB_WRK_ORDR_SEQNO" style="text-align: center"></td>
										<td GH="120 판매문서번호" GCol="text,VBELN" style="text-align: center"></td>
										<td GH="140" GCol="text,MATNR" style="text-align: center">자재코드</td>
										
										<td GH="120 납품요청일" GCol="text,VDATU" GF="D" style="text-align: center"></td>
										<td GH="120 평량" GCol="text,BS_WGT" style="text-align: center"></td>
										<td GH="120 CT지폭" GCol="text,CT_WGT" style="text-align: center"></td>
										<td GH="120 MR지폭" GCol="text,MWIDTH" style="text-align: center"></td>
										<td GH="120" GCol="text,MRCNT" style="text-align: center">MR폭수</td>
										
										<td GH="120" GCol="text,SLITER">슬리터여부</td>
										
										<td GH="120 슬리터개수" GCol="text,CUTTER" GF="N 13"></td>
										<td GH="120 MR계획권치수" GCol="text,MPLNROLLCNT" GF="N 13,3"></td>
										<td GH="120 MR계획권치수단위" GCol="text,MR_PL_ROLLUNIT" style="text-align: center;">MR계획권치수단위</td>
										<td GH="120 MR실적권치수" GCol="text,MROLLCNT" GF="N 13,3"></td>
										<td GH="120 MR실적권치수단위" GCol="text,MR_PD_ROLLUNIT" style="text-align: center;">MR실적권치수단위</td>
										
										<td GH="120" GCol="text,MRWGT" GF='N 13,3'>MR실적중량</td>
										
										<td GH="100" GCol="text,MRWUNIT" style="text-align:center;">MR중량단위</td>
										
										<td GH="120 슬리터계획권치수" GCol="text,SPLNROLLCNT" GF="N 13,3">슬리터계획권치수</td>
										<td GH="140 슬리터계획권치수단위" GCol="text,SR_PL_ROLLUNIT" style="text-align: center;">슬리터계획권치수단위</td>
										
										<td GH="120 슬리터실적권치수" GCol="text,SROLLCNT" GF="N 13,3">슬리터실적권치수</td>
										<td GH="140 슬리터실적권치수단위" GCol="text,SR_PD_ROLLUNIT" style="text-align: center;">슬리터실적권치수단위</td>
										
										<td GH="120 슬리터중량" GCol="text,SRWGT" GF="N 13,3">슬리터중량</td>
										<td GH="120 슬리터중량단위" GCol="text,SRWUNIT" style="text-align: center;">슬리터중량단위</td>
										
										<td GH="120 규격" GCol="text,CSPEC"></td>
										<td GH="120" GCol="text,CPLT_PER_CNT" GF="N 13,3">CT계획팔레트당연수</td>
										<td GH="120" GCol="text,CP_CNT" GF="N 13,3">CT실적팔레트당연수</td>
										<td GH="100" GCol="text,CPLUNIT" style="text-align: center;">연수단위</td>
										
										<td GH="100" GCol="text,CPLT_CNT" GF="N 13">CT팔레트수</td>
										<td GH="100" GCol="text,CPLTUNIT" style="text-align: center;">CT팔레트수 단위</td>
										
										<td GH="120 판매처" GCol="text,PKUNNR"></td>
										<td GH="120 판매처명" GCol="text,PKUNNR_NM"></td>
										<td GH="120" GCol="text,PPLANQTY" GF="N 13,0">포장계획연수</td>
										<td GH="120" GCol="text,PPRD_QTY" GF="N 13,0">포장실적연수</td>
										<td GH="100" GCol="text,PPRUNIT" style="text-align: center;">포장연수단위</td>
										
										<td GH="120 포장타입" GCol="text,PPACKTYPE" style="text-align: center"></td>
										<td GH="120 Roll/Sheet" GCol="text,MSHEET"></td>
										<td GH="120 비고" GCol="text,PORDER_RMK"></td>
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