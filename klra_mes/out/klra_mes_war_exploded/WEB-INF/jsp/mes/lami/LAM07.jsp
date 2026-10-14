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
			url:"/mes/Lam/LAM07/json/datalist.data",
			bigdata : false,
	    	colorType : true
		});

		$("#MACH_CD").val('PLP01');
	});

	function searchList() {
		if (validate.check("searchArea")) {
			var param = new DataMap();
			param.put("P_TYPE", "LIST");
			param.put("MACH_CD",$("#MACH_CD").val().toUpperCase());
			param.put("LOC_CD",$("#LOC_CD").val());
			param.put("P_SDATE",$("#BUDAT").parent().children().eq(1).val().replace(/-/gi,""));
			param.put("P_EDATE",$("#BUDAT").parent().children().eq(4).val().replace(/-/gi,""));
			gridList.gridList({
				id : "gridList",
				param : param
			});
	
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
			searchList();
		}
	}
	// 행 더블 클릭
	function gridListEventRowDblclick(gridId, rowNum){
	}
	//상세정보 조회
	function searchSubList(gridId, rowNum){
		var list = gridList.getRowData(gridId, rowNum);
		
		var param = new DataMap();
		
		param.put("P_TYPE", "DETAIL");
		param.put("list", list);		
		param.put("MACH_CD",$("#MACH_CD").val().toUpperCase());
		param.put("LOC_CD",$("#LOC_CD").val());
		param.put("PRD_NO",list.get("PRD_NO"));	
		param.put("P_SDATE",$("#BUDAT").parent().children().eq(1).val().replace(/-/gi,""));
		param.put("P_EDATE",$("#BUDAT").parent().children().eq(4).val().replace(/-/gi,""));
		
		gridList.gridList({
			id : "gridList2",
			param : param
		});
	}
	
	
	function gridListRowColorChange(gridId, rowNum, rowData){
		if(gridId === "gridList" && rowData.get("END_FLAG1") === "작업완료"){
			return configData.GRID_COLOR_BG_ORANGE_CLASS;
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
				<div class="search_wrap">
					<dl>
						<dt CL="STD_MACHINE">생산호기</dt>
						<dd>
							<input type="text" class="input" id="MACH_CD" name="MACH_CD"  readonly="readonly"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_BUDAT">생산요청일자</dt>
                        <dd><input type="text" id="BUDAT" name="BUDAT" UIInput="B" UIFORMAT="C M1"/></dd>
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
							<table class="table_c">
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH="80" GCol="text,PRD_REQ_DT" style="text-align:center;">생산요청일자</td>
										<td GH="80" GCol="text,PRFM_DT" style="text-align:center;">실적일자</td>
										<td GH="150" GCol="text,MATNR" style="text-align:left;">자재코드</td>
										<td GH="250" GCol="text,MATNR_NM" style="text-align:left;">자재명</td>
										<td GH="90" GCol="text,LOT_NO" style="text-align:center;">LOT_NO</td>
										<td GH="90" GCol="text,IND_BCD" style="text-align:center;">개별바코드</td>
										<td GH="90" GCol="text,PRFM_QTY" GF="N 13,3" style="text-align:right;">실적중량</td>
										<td GH="150" GCol="text,WRK_ORDR_NO" style="text-align:left;">작업지시번호</td>
										<td GH="120" GCol="text,WRK_ORDR_SEQNO" style="text-align:right;">작업지시순번</td>
										<td GH="120" GCol="text,ORDER_NO" style="text-align:left;">오더번호</td>
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