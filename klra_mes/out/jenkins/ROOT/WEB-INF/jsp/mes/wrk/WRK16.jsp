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
			url : "/mes/Work/WRK16/json/datalist.data",
			bigdata:false
	    });
		
		
	});

	function searchList(){
		if(validate.check("searchArea")){
			// 2023-03-13(월요일) 안상현, RANGE 검색 추가
			/* const range = inputList.setRangeParam("searchArea")
			const range_data_param = range.get("RANGE_DATA_PARAM")
			const prfm_dt = range_data_param.get("K.PRFM_DT_Range")
			const date = prfm_dt.split("↓")
			const SDate = date[1]
			const EDate = date[2] */
			
			const param = inputList.setRangeParam("searchArea")
			param.put("P_TYPE", "LIST")
			//param.put("SDATE", SDate)
			//param.put("EDATE", EDate)
			//param.put("IND_BCD",$("#IND_BCD").val()) // 개별바코드
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    })
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
		}
	}

	const barcode = () => {
		var url = "/mes/wrk/WRK17_POP01.page";
		page.linkPopOpen(url, 'P100', "height=600,width=850");
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
						<dd><input type="text" name="K.PRFM_DT" UIInput="B" UIFORMAT="C M1"/></dd>
					</dl>
					<dl>
						<dt CL="호기">생산호기</dt>
						<dd>
							<select class="input" id="MACHINE" name="MACHINE" Combo="Produce,MACHINE">
								<option value="">ALL</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="공정">공정</dt>
						<dd>
							<!-- 2023-03-13(월요일) 안상현, 공정 RANGE 검색 추가 -->
							<input type="text" name="PROC_CD" UIInput="SR,OP" UIFormat="U" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_IND_BCD">개별바코드</dt>
						<dd>
							<input type="text" class="input" id="IND_BCD" name="IND_BCD" UIInput="SR,INDBCD" UIFormat="U"/>
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
					<li><a href="#tab1-1"><span CL="STD_GRD_WRK16">리스트</span></a></li>
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
										<td GH="100 플랜트" GCol="text,WERKS" style="text-align: center"></td>
										<td GH="100 생산요청일자" GCol="text,PRD_REQ_DT" style="text-align: center"></td>
										<td GH="140" GCol="text,MATNR" style="text-align: center"></td>
										<td GH="100 오더번호" GCol="text,ORDER_NO" style="text-align: center"></td>
										<td GH="100" GCol="text,MACHINE" style="text-align: center">생산호기</td>
										<!-- <td GH="100 FROM생산호기" GCol="text,MACHINE" style="text-align: center"></td>
										<td GH="100 TO생산호기" GCol="text,TO_MACHINE" style="text-align: center"></td> -->
										<td GH="100 지종" GCol="text,PCODE" style="text-align: center"></td>
										<td GH="100 평량" GCol="text,BS_WGT" style="text-align: center"></td>
										<td GH="100 지시수량" GCol="text,WRK_ORDR_QTY" GF='N 13,2'></td>
										<td GH='80' GCol='text,OUTUNIT' style='text-align:center;'>수량단위</td>
										<td GH="100 실적일자" GCol="text,PRFM_DT" GF="D" style="text-align: center"></td>
										<td GH="100 개별바코드" GCol="text,IND_BCD" style="text-align: center"></td>
										<td GH="100 LOT번호" GCol="text,LOT_NO" style="text-align: center"></td>
										<td GH="100 공정코드" GCol="text,PROC_CD" style="text-align: center"></td>
										<td GH="100" GCol="text,PROC_NM" style="text-align: center">공정명</td>
										<td GH="100 실적설비" GCol="text,MACH_CD" style="text-align: center"></td>
										<td GH="120 실적설비명" GCol="text,MACH_NM"></td>
										<td GH="100 실적수량" GCol="text,PRFM_QTY" GF="N 13"></td>
										<td GH='80' GCol='text,PRFM_UNIT' style='text-align:center;'>실적단위</td>
										<td GH="100 연수" GCol="text,PCNT" GF="N 13,1"></td>
										<td GH="80" GCol="text,RUNIT" style="text-align: center;">연수단위</td>
										<td GH="100 중량" GCol="text,WGT" GF="N 13,3"></td>
										<td GH="80" GCol="text,WUNIT" style="text-align:center;">중량단위</td>
										
<!-- 										<td GH="100" GCol="select,CNL_YN">
											<select CommonCombo="CNL_YN">          취소여부
												<option value=""> </option>
											</select>
										</td> -->
										<td GH="100" GCol="text,CNL_YN" style="text-align: center;">취소여부</td>
										<td GH="100" GCol="text,CNL_RMK">취소사유</td>
										
										<td GH="100 SAP확정번호" GCol="text,SDOC_NO" style="text-align: center"></td>
										<td GH="100 SAP확정순번" GCol="text,SDOC_SEQNO" style="text-align: center"></td>
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