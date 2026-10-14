<%@page import="java.io.Console"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<%
	String data = request.getParameter("test");
%>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp"%>
<link rel="stylesheet" type="text/css"
	href="/common/theme/webdek/css/demo_layout.css">
<script type="text/javascript">
	$(document).ready(function() {
		gridList.setGrid({
			id : "gridList",
			url : "/mes/Work/WRK52_procResult/json/procResultList.data",
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

	function searchList() {
		if (validate.check("searchArea")) {
			const range = inputList.setRangeParam("searchArea");
			const range_data_param = range.get("RANGE_DATA_PARAM");
			const prfm_dt = range_data_param.get("PRFM_DT_Range");
			const mach_cd = range_data_param.get("MACH_CD_Single");
			const prfm_dt_date = prfm_dt.split("↓");
			let machCd = "";
			if(mach_cd != undefined){
				const mach_cd_date = mach_cd.split("↓");
				machCd = mach_cd_date[1];
			}
			const SDate = prfm_dt_date[1];
			const EDate = prfm_dt_date[2];
			

			if(range.get("PROC_CD") == undefined | range.get("PROC_CD") == ""){
				alert("공정코드 입력은 필수입니다. 공정코드를 선택해주세요.");
				return;
			}
			
			const param = inputList.setRangeParam("searchArea")
			param.put("WERKS",		range.get("WERKS"))		//플랜트
			param.put("PROC_CD",	range.get("PROC_CD"))	//공정코드
			param.put("SDATE",		SDate)					//실적일자_시작
			param.put("EDATE",		EDate)					//실적일자_종료 
			param.put("MATNR",		$("#MATNR").val())		//자재코드
			param.put("ORDER_NO",	$("#ORDER_NO").val())	//오더번호
			param.put("MACHINE",	$("#MACHINE").val())	//생산호기
			param.put("MACH_CD",	machCd)	//설비코드
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    })
		}
	}
	
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
</script>
</head>
<body>
	<%@ include file="/common/include/webdek/layout.jsp"%>
	<!-- content -->
	<div class="content_wrap">
		<div class="content_inner">
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
							<dt CL="STD_PROC_CD">공정코드</dt>
							<dd>
								<SELECT class="input" id="PROC_CD" name="PROC_CD">
<!-- 									<option value="">ALL</option> -->
									<option value="J">점보롤</option>
									<option value="M">밀롤</option>
									<option value="C">재단</option>
									<option value="P">포장</option>
								</SELECT>
<!-- 								<input type="text" class="input" id="PROC_CD" name="PROC_CD" UIInput="S,OP" UIFormat="U"/> -->
							</dd>
						</dl>
						<dl>
							<dt CL="STD_PRFM_DT">실적일자</dt>
							<dd>
								<input type="hidden" id="CNL_RMK" name="CNL_RMK" />
								<input type="text" name="PRFM_DT" UIInput="B" UIFORMAT="C M1" />
							</dd>
						</dl>
						<dl>
							<dt CL="STD_MATNR">자재코드</dt>
							<dd>
								<input type="text" class="input" id="MATNR" name="MATNR" UIInput="MATKY" UIFORMAT="U" />
							</dd>
						</dl>
						<dl>
							<dt CL="STD_ORDER_NO">오더번호</dt>
							<dd>
								<input type="text" class="input" id="ORDER_NO" name="ORDER_NO" />
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
								<input type="text" class="input" name="MACH_CD" id="MACH_CD" UIInput="SR,MACH" UIFormat="U"/>
<!-- 								<input type="text" class="input" name="MACH_CD" id="MACH_CD" UIInput="MACH" UIFormat="U"/> -->
							</dd>
						</dl>
					</div>
					<div class="btn_tab">
						<input type="button" class="btn_more" value="more"
							onclick="searchMore()" />
					</div>
				</div>
			</div>
			<div class="search_next_wrap">
				<div class="content_layout tabs">
					<ul class="tab tab_style02">
						<li><a href="#tab1-1"><span CL="STD_GRD_WRK52_PROCRESULT">일반</span></a></li>
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
											<td GH="100" GCol="text,PRFM_DT_YM" style="text-align:center;">실적년월</td>
											<td GH="100" GCol="text,PRFM_DT" style="text-align:center;" GF='D'>실적일자</td>
											<td GH="140" GCol="text,ORDER_NO" style="text-align:center;">오더번호</td>
											<td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>
											<td GH="80" GCol="text,MACHINE" style="text-align: center;">호기</td>
											<td GH="80" GCol="text,PCODE" style="text-align:center;">지종</td>
											<td GH="100" GCol="text,BS_WGT" style="text-align:center;">평량</td>
											<td GH="100" GCol="text,WLEN" style="text-align:center;">가로</td>
											<td GH="100" GCol="text,VLEN" style="text-align:center;">세로</td>
											<td GH="100" GCol="text,PKTYPE" style="text-align:center;">포장타입</td>
											<td GH="150" GCol="text,MATNR_DIV_NM" style="text-align:center;">자재구분명</td>
											<td GH="100" GCol="text,EXPORT_GBN" style="text-align: center;">내/외수</td>
											<td GH="100" GCol="text,CORE" GF="13" style="text-align: center">지관</td>
											
											<td GH="80" GCol="text,UNIT_KG" style="text-align: center;">단위(KG)</td>
											<td GH="100" GCol="text,PRFM_QTY_KG" GF="N 13,3">실적량</td>
											
											<td GH="80" GCol="text,UNIT_EA" style="text-align: center;">단위(EA)</td>
											<td GH="100" GCol="text,PRFM_QTY_EA" GF="N 13,3">실적량</td>
											
											<td GH="80" GCol="text,UNIT_R" style="text-align: center;">단위(R)</td>
											<td GH="100" GCol="text,PRFM_QTY_R" GF="N 13,3">실적량</td>
										
										
											<td GH="100" GCol="text,SHEET_GBN" style="text-align:center;">판지구분자</td>
											<td GH="100" GCol="text,PKCNT" style="text-align: center;">폭수</td>	
										
											<td GH="100" GCol="text,MACH_CD" style="text-align: center;">설비코드</td>
											<td GH="140" GCol="text,MACH_NM" style="text-align: center;">설비명</td>
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