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
	    	url : "/mes/Produce/SCH19/json/datalist.data",
	    	bigdata : false
// 	    	colHoldType : true,
//             colHold : "WERKS,PLANTNM,PROC_CD,PROC_NM"
	    });
		
		gridList.setGrid({
	    	id : "gridList2",
	    	url : "/mes/Produce/SCH19/json/datalist.data",
	    	bigdata : false
	    });
		
		//20220913 여한진 플랜트 값에 따라 그리드를 다르게 보여줌
		$('#tab1-1').show();
		$('#tab1-2').hide();

		$("#WERKS").val('P100');
	});
	
	function searchList() {
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			
			param.put("P_TYPE","LIST");
			
			if(param.get('WERKS') == 'P100'){
				gridList.resetGrid('gridList2');
				
				$('#tab1-1').show();
				$('#tab1-2').hide();
				
				gridList.gridList({
			    	id : "gridList",
			    	param : param
			    });
			}else{
				gridList.resetGrid('gridList');
				
				$('#tab1-1').hide();
				$('#tab1-2').show();
				
				gridList.gridList({
			    	id : "gridList2",
			    	param : param
			    });
			}
		}
	}
	
	function commonBtnClick(btnName) {
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search") {
			searchList();
		}
// 		else if (btnName == "Save") {
// 			saveData();
// 		}
	}
	
	// 조회
// 	function searchList(){
// 		if(validate.check("searchArea")){
// 			var param = inputList.setRangeParam("searchArea");

// 			param.put("P_TYPE", "LIST");
			
// 			// configData.INPUT_RNAGE_DATA_PARAM : RANGE_DATA_PARAM
// 			// configData.DATA_COL_SEPARATOR : ↓
// 			const data = param.get("RANGE_DATA_PARAM").get("PRD_DT_Range").split("↓")
// 			const condi = data[1] + "," + data[2]
// 			param.put("OUT_SQL", condi)
			
// 			gridList.gridList({
// 		    	id : "gridList",
// 		    	param : param
// 		    });
// 		}
// 	}
	
	// 버튼을 클릭한 경우
// 	function commonBtnClick(btnName){
// 		if(btnName == "Search"){
// 			var param = new DataMap();
<%-- 	        param.put("PROGID", "<%= menuId%>"); --%>
// 	        param.put("LGTYPE", "SEARCH");
// 	        var json = netUtil.sendData({
// 	            url: "/mes/system/json/saveLog.data",
// 	            param : param
// 	        });
			
// 			searchList();
// 		}
// 	}
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
							<!-- <input type="text" class="input" id="WERKS" name="WERKS" validate="required" UIInput="SR,PLANT" UIFormat="U"/> -->
							<input type="text" class="input" id="WERKS" name="WERKS" readonly="readonly"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PROC_CD">공정코드</dt>
						<dd>
							<input type="text" class="input" id="PROC_CD" name="PROC_CD" UIInput="SR,OP" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MACH_CD">설비코드</dt>
						<dd>
							<input type="text" class="input" id="MACH_CD" name="MACH_CD" UIInput="SR,MACH" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PRD_DT">생산일자</dt>
						<dd>
							<input type="text" id="PRD_DT" name="PRD_DT" UIInput="B" UIFormat="C M1"/>
						</dd>
					</dl>
					<!-- 20230214 여한진 오더번호, LOT번호 검색조건 추가 -->
					<dl>
						<dt CL="STD_ORDER_NO">오더번호</dt>
						<dd>
							<input type="text" class="input" name="ORDER_NO" UIInput="SR" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_LOT_NO">LOT번호</dt>
						<dd>
							<input type="text" class="input" name="LOT_NO" UIInput="SR" UIFormat="U"/>
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
					<li><a href="#tab1-1"><span CL="STD_GRD_SCH19">리스트</span></a></li>
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
										<td GH="40" GCol="rownum" style="text-align:center;">1</td>
										<!-- <td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td> -->
										<td GH="100" GCol="text,PROC_CD" style="text-align:center;">공정코드</td>
										<td GH="140" GCol="text,PROC_NM" style="text-align:center;">공정명</td>
										<td GH="100" GCol="text,MACH_CD" style="text-align:center;">설비코드</td>
										<td GH="140" GCol="text,MACH_NM" style="text-align:center;">설비명</td>
										<td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH="320" GCol="text,MATNR_NM" style="text-align:center;">자재명</td>
										<!-- <td GH="100" GCol="text,IND_BCD" style="text-align:center;">업체/개별 바코드</td> -->
										
										<td GH="100" GCol='text,PRFM_DT' style='text-align:center;' GF='D'>생산일자</td> 
										<td GH="100" GCol="text,ORDER_NO" style="text-align:center;">오더번호</td>
										<td GH="140" GCol="text,WRK_ORDR_NO" style="text-align:center;">작업지시번호</td>
										<td GH="100" GCol="text,WRK_ORDR_SEQNO" style="text-align:center;">작업지시순번</td>
										<td GH="100" GCol="text,SPEC" style="text-align:center;">규격</td>
										
										<td GH="100" GCol="text,PRD_LOT_NO" style="text-align:center;">실적LOT_NO</td>
										<td GH="100" GCol="text,PRD_QTY"  GF="N 13,3">실적량</td>
										<td GH="100 실적단위" GCol="text,PRD_UNIT" style="text-align:center;">실적단위</td>
										<td GH="100 연수" GCol="text,PCNT" GF="N 13,1">연수</td>
										<td GH="100 연수단위" GCol="text,RUNT" style="text-align:center;">연수단위</td>
										<td GH="100" GCol="text,SCNT" style="text-align:center;">속수</td>
										<td GH="100" GCol="text,MCNT" style="text-align:center;">매수</td>
										<td GH="100" GCol="text,PRD_WGT" GF="N 13,3">실적중량</td>
										<td GH="100 실적중량단위" GCol="text,PRD_WUNIT" style="text-align:center;">실적중량단위</td>
										<td GH="100" GCol="text,PRD_ROLLCNT" GF="N 13,3">실적권치수</td>
										<td GH="100" GCol="text,PRD_ROLLUNIT" style="text-align:center;">실적권치수단위</td>
										<td GH="100 투입LOT번호" GCol="text,LOT_NO_M" style="text-align:center;">투입LOT</td>
										<td GH="100" GCol="text,IN_QTY" GF="N 13,3">투입량</td>
										<td GH="100" GCol="text,IN_UNIT" style="text-align:center;">투입단위</td>
										<td GH="100" GCol="text,USE_QTY" GF="N 13,3">사용량</td>
										<td GH="100" GCol="text,USE_UNIT" style="text-align:center;">사용량단위</td>
										<td GH="100" GCol="text,REM_QTY" GF="N 13,3">잔량</td>
										<td GH="100" GCol="text,REM_UNIT" style="text-align:center;">잔량단위</td>
										<td GH='100' GCol='text,PERCENT' GF='N 13,3'>달성율</td>
										
<!-- 									<td GH="100" GCol="text,SEQNO" style="text-align:center;">순번</td>
										<td GH="100 투입단위" GCol="text,UNIT" style="text-align:center;">단위</td>
										<td GH="100" GCol="text,IN_QTY" GF="N 13,3">투입량</td>
										<td GH="100 잔량" GCol="text,STCK_QTY" GF="N 13,3">재고량</td>
										<td GH="100" GCol="text,RESL_UNIT" style="text-align:center;">단위</td>
										<td GH="100" GCol="text,PRFM_QTY" GF="N 13,3">실적수량</td>
										<td GH="100" GCol="text,WIDTH" style="text-align:center;">실지폭</td>
										<td GH="100" GCol="text,ROLLCNT" GF='N 13'>권치수</td>
										<td GH="100 실적중량" GCol="text,WGT" GF='N 13,3'>중량</td> -->
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
				<div class="table_box section" id="tab1-2">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_b">
								<tbody id="gridList2">
									<tr CGRow="true">
										<td GH="40" GCol="rownum" style="text-align:center;">1</td>
										<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="100" GCol="text,PROC_NM" style="text-align:left;">공정명</td>
										<td GH="100" GCol="text,MACH_CD" style="text-align:center;">설비코드</td>
										<td GH="140" GCol="text,MACH_NM" style="text-align:left;">설비명</td>
										<td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH="320" GCol="text,MATNR_NM" style="text-align:left;">자재명</td>
										<td GH="120" GCol="text,IND_BCD" style="text-align:center;">업체/개별 바코드</td>
										<td GH="100" GCol="text,ORDER_NO" style="text-align:right;">오더번호</td>
										<td GH="100" GCol="text,ORDER_SEQNO" style="text-align:right;">오더순번</td>
										<td GH="100" GCol='text,PRD_DT' style='text-align:center;' GF='D'>생산일자</td> 
										<td GH="100" GCol="text,WRK_ORDR_NO" style="text-align:center;">작업지시번호</td>
										<td GH="120" GCol="text,WRK_ORDR_SEQNO" style="text-align:right;">작업지시순번</td>
										<td GH="100" GCol="text,LOT_NO" style="text-align:center;">LOT_NO</td>
										<td GH="100" GCol="text,UNIT" style="text-align:center;">LOT_NO</td>
										<td GH="100" GCol="text,SEQNO" style="text-align:right;">순번</td>
										<td GH="100" GCol="text,IN_QTY" GF="N 13,2">투입량</td>
										<td GH="100" GCol="text,USE_QTY" GF="N 13,2">사용량</td>
										<td GH="100" GCol="text,STCK_QTY" GF="N 13,2">재고량</td>
										<td GH="100" GCol="text,RESL_UNIT" style="text-align:center;">단위</td>
										<td GH="100" GCol="text,PLT_QTY" GF="N 13,1">PLT수량</td>
										<td GH="100" GCol="text,BOX_QTY" GF="N 13">BOX수량</td>
										<td GH="100" GCol="text,BAG_QTY" GF="N 13">BAG수량</td>
										<td GH="100" GCol="text,EA_QTY" GF="N 13">EA수량</td>
										<td GH="100" GCol="text,WGT" GF="N 13,2">중량</td>
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