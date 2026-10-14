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
	    	url : "/mes/Work/WRK46/json/datalist.data",
	    	bigdata : false,
	    	colHoldType : true,
	    	colHold : "WERKS, MACH_CD, MACH_NM, PROC_NM",
	    	gridScrollType : false
	    });
	});
	
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			
			param.put("P_TYPE", "LIST");
			
			gridList.gridList({
				id : "gridList",
				param : param
			});
		}
	}
	
	// 조회 완료된 후
	function gridListEventDataBindEnd(gridId, dataLength){
		var list = gridList.getGridData(gridId);
		
		const $obj = $("#gridList").find("tr")
		
		$("#gridList").find("["+configData.GRID_ROW_NUM+"]").each(function(i, tr){
			$(tr).find("td").each(function(j, td){
				
				const $td = $(td)
				const gcolname = $td.attr("gcolname")
				if(gcolname == "ABN_NM"){
					$td.css("backgroundColor",list[i].get("USARG1"))
					$td.css("color",list[i].get("USARG2"))
					$td.css("fontWeight","bold")
				}
			})
		})
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
						<dt CL="STD_PLANT">플랜트</dt>
						<dd>
							<input type="text" name="WERKS" validate="required" UIInput="S,PLANT" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MACH_CD">설비코드</dt>
						<dd>
							<input type="text" name="A.MACH_CD" UIInput="SR,MACH" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PROC_CD">공정코드</dt>
						<dd>
							<input type="text" name="A.PROC_CD" UIInput="SR,OP" UIFormat="U"/>
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
					<li><a href="#tab1-1"><span CL="STD_GENERAL"></span></a></li>
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
										<td GH="100" GCol="text,WERKS" style="text-align:center;">플랜트</td>
										<td GH="100" GCol="text,MACH_CD" style="text-align:center;">설비코드</td>
										<td GH="160" GCol="text,MACH_NM">설비명</td>
										<td GH="0" GCol="text,PROC_CD" style="text-align:center;">공정코드</td>
										<td GH="120" GCol="text,PROC_NM">공정명</td>
										<td GH="100" GCol="text,PRD_REQ_DT" GF='D' style="text-align:center;">생산요청일자</td>
										<td GH="100" GCol="text,ORDER_NO">오더번호</td>
										<td GH="150" GCol="text,WRK_ORDR_NO">작업지시번호</td>
										<td GH="100" GCol="text,LOT_NO">LOT_NO</td>
										<td GH="140" GCol="text,MATNR" style="text-align:center;">자재코드</td>
										<td GH="320" GCol="text,MATNR_NM">자재명</td>
										<td GH="100" GCol="text,UNIT" style="text-align:center;">단위</td>
										<td GH="100" GCol="text,WRK_ORDR_QTY" GF="N 13,3">지시수량</td>
										<td GH="100" GCol="text,PRFM_QTY" GF="N 13,3">실적수량</td>
										<td GH="140" GCol="text,PRD_STR_DTM" GF="DTS" style="text-align:center;">생산시작시간</td>
										<td GH="100" GCol="text,LAPSE_TM" GF="N 10" style="text-align:right;">경과시간</td>
										<td GH="80" GCol="text,WRK_CLASS" style="text-align:center;">작업반</td>
										<td GH="80" GCol="text,WRK_SHIFT" style="text-align:center;">작업조</td>
										<td GH="100" GCol="text,EMPLY_NM">작업자</td>
										<td GH="150" GCol="text,ABN_NM">비가동항목명</td>
										<td GH="150" GCol="text,ABN_DTM" style="text-align:right;">비가동 시작시간</td>
										<td GH="150" GCol="text,ABN_DUDATE" GF="N 10" style="text-align:right;">비가동 경과시간(분)</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param value="1" name="authCd"/>
						<jsp:param value="1,2,3,7,9,10" name="showAuthCd"/>
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