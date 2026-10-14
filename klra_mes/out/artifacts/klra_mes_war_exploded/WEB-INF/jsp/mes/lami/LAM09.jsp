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
		var showflag = "자재사용량";
		
		gridList.setGrid({
			id : "gridList_A",
			url:"/mes/Lam/LAM09/json/datalist.data",
			bigdata : false,
	    	colorType : true
		});
		
		gridList.setGrid({
			id : "gridList_B",
			url:"/mes/Lam/LAM09/json/datalist.data",
			bigdata : false,
	    	colorType : true
		});

		$("#MACH_CD").val('PLS01');
	});

	let id = "gridList_A" // 일반

	function searchList(gridId,list) {
		if (validate.check("searchArea")) {
			var matnr = $("#MATNR").val();
			var gbn = $("#GBN").val();

			var param = new DataMap();
			param.put("P_TYPE", list);
			param.put("P_SDATE",$("#BUDAT").parent().children().eq(1).val().replace(/-/gi,""));
			param.put("P_EDATE",$("#BUDAT").parent().children().eq(4).val().replace(/-/gi,""));
			param.put("P_MATNR", matnr);
			param.put("P_GBN", gbn);
			gridList.gridList({
				id : gridId,
				param : param
			});
		}
	}
	
	// 품목별, LOT별 조회 제어
	const f = (gridId) => {
		id = gridId
		
		if(gridId === "gridList_A"){
			$("#dl_IND_BCD").hide()
			$("#dl_LOT_NO").hide()
			//$("#dl_CNL_YN").hide()
		}else{
			$("#dl_IND_BCD").show()
			$("#dl_LOT_NO").show()
			//$("#dl_CNL_YN").show()
		}
	}
	
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			var param = new DataMap();
	        param.put("PROGID", "<%= menuId%>");
	        param.put("LGTYPE", "SEARCH");
	        var json = netUtil.sendData({
	            url: "/mes/system/json/saveLog.data",
	            param : param
	        });
			
	        if(id === "gridList_A") searchList("gridList_A","LIST1");
	        else searchList("gridList_B","LIST");
//			searchList();
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
						<dt>변경일자</dt>
						<dd>
                        	<input type="text" name="BUDAT" id="BUDAT" UIInput="B" UIFORMAT="C M1"/>
                        </dd>
					</dl>
					<dl>
						<dt>변경전 자재</dt>
						<dd>
							<select class="input" name="MATNR" id="MATNR" Combo="Lam,MATNR">
								<option value="">ALL</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt>변경구분</dt>
						<dd>
							<select class="input" name="GBN" id="GBN">
								<option value="">ALL</option>
								<option value="N">변경</option>
								<option value="Y">취소</option>
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
					<li>
						<a href="#tab1-1" onclick="f(`gridList_A`)">
							<span>일반</span>
						</a>
					</li>
					<li>
						<a href="#tab1-2" onclick="f(`gridList_B`)">
							<span>실적대비</span>
						</a>
					</li>
					<li class="btn_zoom_wrap">
						<ul>
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridList_A">
									<tr CGRow="true">
										<td GH="100" GCol="text,CHGDAT" style="text-align:center;">변경일자</td>
										<td GH="150" GCol="text,MATNR_FROM" style="text-align:left;">변경전 자재</td>
										<td GH="250" GCol="text,MATNR_FROM_NM" style="text-align:left;">변경전 자재명</td>
										<td GH="80" GCol="text,LOT_NO" style="text-align:left;">변경전 LOT_NO</td>
										<td GH="90" GCol="text,IND_BCD" style="text-align:left;">개별바코드</td>
										<td GH="150" GCol="text,MATNR_TO" style="text-align:left;">변경후 자재</td>
										<td GH="250" GCol="text,MATNR_TO_NM" style="text-align:left;">변경후 자재명</td>
										<td GH="90" GCol="text,PRFM_QTY" GF="N 13,3" style="text-align:right;">변경중량</td>
										<td GH="100" GCol="text,SDOC_NO" style="text-align:left;">확정번호</td>
										<td GH="100" GCol="text,SDOC_SEQNO" style="text-align:right;">확정순번</td>
										<td GH="80" GCol="text,GBN" style="text-align:center;">구분</td>
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
								<tbody id="gridList_B">
									<tr CGRow="true">
										<td GH="80" GCol="text,PRFM_DT" style="text-align:center;">실적일자</td>
										<td GH="150" GCol="text,MATNR" style="text-align:left;">자재코드</td>
										<td GH="250" GCol="text,MATNR_NM" style="text-align:left;">자재명</td>
										<td GH="100" GCol="text,LOT_NO" style="text-align:left;">LOT_NO</td>
										<td GH="100" GCol="text,IND_BCD" style="text-align:left;">개별바코드</td>
										<td GH="90" GCol="text,PRFM_QTY" GF="N 13,3" style="text-align:right;">실적중량</td>
										<td GH="150" GCol="text,MATNR_TO" style="text-align:left;">변경후 자재</td>
										<td GH="250" GCol="text,MATNR_TO_NM" style="text-align:left;">변경후 자재명</td>
										<td GH="80" GCol="text,BUDAT" style="text-align:center;">변경일자</td>
										<td GH="90" GCol="text,MENGE" GF="N 13,3" style="text-align:right;">실적중량</td>
										<td GH="120" GCol="text,GBN" style="text-align:center;">구분</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="2" />
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