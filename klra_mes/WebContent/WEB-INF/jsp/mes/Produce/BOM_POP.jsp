<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="project.common.bean.DataMap,project.common.bean.DataMap,java.util.*"%>
<%
	DataMap param = (DataMap)request.getAttribute("param");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>BOM 조회</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		/* 
		gridList.setGrid({
			id : "gridList"
	    });
		 */
	});
	
	// 조회
	function searchList(){
		alert("haha")
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			gridList.gridList({
				id : "gridList",
				param : param
			});
		}
	}
	
	// 버튼(조회, 저장 등) 클릭
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
						<dt CL="STD_MATNR">자재코드</dt>
						<dd>
							<input type="text" class="input" name="MATNR" UIFormat="U" readonly />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_MATNR_NM">자재명</dt>
						<dd>
							<input type="text" class="input" name="MAKTX" readonly />
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
					<li><a href="#tab1-1"><span>BOM111231231</span></a></li>
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
										<td GH="40" GCol="rowCheck"></td>
										<td GH="100" GCol="text,VERID">생산버전</td>
										<td GH="120" GCol="text,TEXT1">버전내용</td>
										<td GH="100" GCol="text,BMENG" GF="N 13,3">기준수량</td>
										<td GH="100" GCol="text,BMEIN">기준단위</td>
										<td GH="100" GCol="text,STLAL">대체BOM</td>
										<td GH="100" GCol="text,STLNR">자재번호</td>
										<td GH="100" GCol="text,MENGE" GF="N 13,3">구성품수량</td>
										<td GH="100" GCol="text,MEINS">구성품단위</td>
										<td GH="100" GCol="text,AUSCH" GF="N 5,2">스크랩(%)</td>
										<td GH="100" GCol="text,ITSOB">특별유형</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<div class="btn_lit tableUtil">
						<%-- <%
							if(param.containsKey("multyType")){
						%>
						<button type='button' GBtn="multiSelect" onClick="multiSelect()"><span></span></button>
						<%
							}
						%> --%>
						<button type='button' GBtn="sortReset"></button>
						<button type='button' GBtn="layout"></button>
						<button type='button' GBtn="excel"></button>
						<span class='txt_total' >총 건수 : <span GInfoArea='true'>4</span></span>
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