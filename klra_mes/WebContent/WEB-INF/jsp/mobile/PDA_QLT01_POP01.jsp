<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String indbcd = request.getParameter("IND_BCD");
	String deptcd = request.getParameter("DEPT_CD");
	String deptnm = request.getParameter("DEPT_NM");
%>

<!doctype html>
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
	<meta name="format-detection" content="telephone=no" />
	<title>Mobile Mes</title>
	<%@ include file="/mobile/include/head.jsp" %>
	<script>
	
	$(document).ready(function(){
		gridList.setGrid({
			id : "gridList",
	    	url : "/mobile/Mobile/PDA_QLT01/json/datalist.data",
	    	bigdata : false,
	    	gridMobileType : true
		});
		searchList();
	});
	
	
	function searchList(){
		PlaySound('s');
		
		var param = new DataMap();
		
		param.put("P_TYPE","SUB_LIST1");
		
		gridList.gridList({
			id : "gridList",
			param : param
		});
	}

	function closePop(){
		var data = gridList.getSelectData("gridList");
		
		if(data.length < 1){
			PlaySound('e');
			commonUtil.msg("불량 항목을 선택하시기 바랍니다.");
			return;
		} /* else if(data.length > 1){
   			alert("하나의 항목만 선택하시기 바랍니다.");
   			PlaySound('e');
   			return;
   		} */
   		var INSP_ITEM_CD = "";
   		var INSP_ITEM_NM = "";
   		
		for(var i = 0; i < data.length; i++){
			var insp_item_cd = data[i].get("INSP_ITEM_CD");
			var insp_item_nm = data[i].get("INSP_ITEM_NM");
			
			INSP_ITEM_CD = INSP_ITEM_CD + ',' + insp_item_cd;
			INSP_ITEM_NM = INSP_ITEM_NM + ',' + insp_item_nm;

		}
		
		/* var param = new DataMap();
		
		param.put("insp_item_cd", INSP_ITEM_CD);
		param.put("insp_item_cd", INSP_ITEM_CD.replace(',',""));
		param.put("insp_item_nm", INSP_ITEM_NM.replace(',',"")); */
		
		var paramStr = 'IND_BCD=<%=indbcd%>&DEPT_CD=<%=deptcd%>&DEPT_NM=<%=deptnm%>&INSP_ITEM_CD=' + INSP_ITEM_CD.replace(',','') + '&INSP_ITEM_NM=' + INSP_ITEM_NM.replace(',','');
		
		location.href='/mobile/PDA_QLT01.page?' + paramStr;
	}
	
	</script>
</head>
<body>
<div class="main_wrap">
	<div class="main_header_pop">
		<ul>
			<li class="t01"></li>
			<li class="tit" id="title">불량 항목 선택</li>
		</ul>
	</div>
	<div class="tem4_content">
		<div class="tableWrap_search section">
			<div class="tableHeader">
				<table style="width: 100%">
					<colgroup>
						<col width="10px" />
						<col width="10px" />
						<col width="15px" />
						<col width="15px" />
					</colgroup>
					<thead>
					<tr>
						<th CL='No.'>.</th>
						<th CL='선택'>.</th>
						<th CL='검사항목코드'></th>
						<th CL='검사항목명'></th>
					</tr>
					</thead>
				</table>
			</div>

			<div class="tableBody">
				<!-- 					<table style="width: 100%; overflow:hidden;word-wrap:break-word;"> -->
				<table style="width: 100%;">
					<colgroup>
						<col width="10px" />
						<col width="10px" />
						<col width="15px" />
						<col width="15px" />
					</colgroup>
					<tbody id="gridList">
					<tr CGRow="true">
						<td GCol="rownum"></td>
						<td GCol="rowCheck"></td>
						<td GCol="text,INSP_ITEM_CD"></td>
						<td GCol="text,INSP_ITEM_NM"></td>	
					</tr>
					</tbody>
				</table>
			</div>
		</div>

		

		<!-- end table_body -->
		<div class="footer_5" style="position:fixed;">
			<!-- 			<div class="footer_5" "> -->
			<table>
				<tr>
					<td class=f_1 onclick="history.back();" style="width: 50%"><label>닫기</label></td>
					<td class=f_1 onclick="closePop();" style="width: 50%;"><label >선택</label></td>
				</tr>
			</table>
		</div><!-- end footer_5 -->
	</div>
</div>
</body>