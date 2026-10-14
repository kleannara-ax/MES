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
	    	url : "/mes/Work/WRK22/json/datalist.data",
	    	bigdata : false
	    });
	});
	
// 	function comboEventDataBindeBefore(comboAtt) {
// 		if(comboAtt == "Produce,MACHINE"){
// 			var param = new DataMap();
// 			param.put("WERKS", 'P100');  // PS는 플랜트 P100
// 		}
// 		return param;
// 	}

	function searchList() {
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			
			if(param.get('WERKS') == 'P100'){
				$('#WERKS').val('');
				return alert('PS(제지)팀은 창고 재고현황 조회(PS)화면을 이용하세요.');
			}
			
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
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" class="input" id="WERKS" name="WERKS" validate="required" UIInput="S,PLANT" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_STOR_LOC_CD">저장위치</dt>
						<dd>
							<input type="text" id="STOR_LOC_CD" name="STOR_LOC_CD" UIInput="SR,LOC" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<input type="text" class="input" name="MATNR" UIInput="SR,MATKY" UIFormat="U"/>
						</dd>
					</dl>
<!-- 					<dl> -->
<!-- 						<dt CL="STD_MATNR">자재코드</dt> -->
<!-- 						<dd><input type="text" class="input" name="MATNR" UIFormat="U"/></dd> -->
<!-- 					</dl> -->
					<dl>
						<dt CL="STD_MATNR_NM">자재명</dt>
						<dd><input type="text" class="input" name="MATNR_NM" UIInput="SR"/></dd>
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
										<td GH="40" GCol="rownum">1</td>
										<td GH="90" GCol="text,STOR_LOC_CD" style="text-align:center;"></td>
										<td GH="100" GCol="text,STOR_LOC_NM" style="text-align:left;"></td>
										<td GH="140" GCol="text,WRHS_RCV_DATE" style="text-align:center;"></td>
										<td GH="130" GCol="text,MATNR" style="text-align:center;"></td>
										<td GH="250" GCol="text,MATNR_NM" style="text-align:left;"></td>
										<td GH="100" GCol="text,LOT_NO" style="text-align:center;"></td>
										<td GH="140" GCol="text,IND_BCD" style="text-align:center;"></td>
										<td GH="90" GCol="text,PRFM_DT" style="text-align:center;" GF="D"></td>
										<td GH="90" GCol="text,PRD_DT" style="text-align:center;" GF="D"></td>
										<td GH="60" GCol="text,STCK_STA" style="text-align:center;"></td>
										<td GH="60" GCol="text,UNIT" style="text-align:center;"></td>
										<td GH="90" GCol="text,STCK_QTY" style="text-align:right;" GF="N 13,2"></td>
										
										<td GH="90" GCol="text,UCFMTY_AMT" style="text-align:right;" GF="N 13,3"></td>
										
										<td GH="90" GCol="text,PALETTE" style="text-align:right;" GF="N 13,1"></td>
										<td GH="90" GCol="text,BOX_QTY" style="text-align:right;" GF="N 13"></td>
										<td GH="90" GCol="text,BAG_QTY" style="text-align:right;" GF="N 13"></td>
										<td GH="90" GCol="text,EA_QTY" style="text-align:right;" GF="N 13"></td>
										<td GH="90" GCol="text,ROLLCNT" style="text-align:right;" GF="N 13,2"></td>
										<td GH="90" GCol="text,WGT" style="text-align:right;" GF="N 13,2"></td>
										<td GH="100" GCol="text,MACH_CD" style="text-align:center;"></td>
										<td GH="100" GCol="text,MACHINE" style="text-align:center;"></td>
										<td GH="100" GCol="text,ORDER_NO" style="text-align:center;"></td>
										<td GH="150" GCol="text,WRK_ORDR_NO" style="text-align:center;"></td>
										<td GH="90" GCol="text,WRK_ORDR_SEQNO" style="text-align:right;"></td>
										
										<td GH="100" GCol="text,WRKNM" style="text-align:left;"></td>
										<td GH="130" GCol="text,ORDER_RMK" style="text-align:left;"></td>
										<td GH="130" GCol="text,WRK_ORDR_REMARK" style="text-align:left;"></td>
										
										<td GH="0" GCol="text,PCODE" style="text-align:center;"></td>
										<td GH="0" GCol="text,PCODE_NM" style="text-align:left;"></td>
										<td GH="0" GCol="text,KUNNR_NM" style="text-align:left;"></td>
										<td GH="0" GCol="text,NTN_NM" style="text-align:center;"></td>
										<td GH="0" GCol="text,PRFM_RMK" style="text-align:left;"></td>
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