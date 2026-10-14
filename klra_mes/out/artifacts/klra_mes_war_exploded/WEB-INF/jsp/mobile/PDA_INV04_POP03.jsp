<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
	String plant = (String)request.getSession().getAttribute(CommonConfig.SES_USER_PLANT_KEY);
	String machCd = (String)request.getSession().getAttribute(CommonConfig.SES_MACH_CD);
	String indbcd = request.getParameter("IND_BCD");
	String inpqty = request.getParameter("INP_QTY");
%>

<!doctype html>
<head>
	<style type="text/css">
		.tem5_content .tableWrap_search select	{width:172px;  height:25px; }
		.tem5_content .tableWrap_search .text_2{width:90%; margin-right:3px;height:22px;border:#b8b8b8;}

		.select-editable { position:relative; background-color:white; border:solid 1px #b8b8b8; width:172px; height:25px; }
		.select-editable select { top:0px; left:0px; width:172px; height:25px; font-size:14px;  border:none;  }
		.select-editable input { position:absolute; top:0px; left:0px; width:90%; height:23px; font-size:12px;  border:none;   }
		.select-editable select:focus, .select-editable input:focus { outline:none; }

		.select-editable { position:relative; background-color:white; border:solid 1px #d5d5d5; width:100%; height:35px; }
		.select-editable select { position:absolute; top:0px; left:0px; width:100%; height:35px; font-size:14px;  border:none;  }
		.select-editable input { position:absolute; top:0px; left:0px; width:90%; height:33px; font-size:12px;  border:none;   }
		.select-editable select:focus, .select-editable input:focus { outline:none; }
		/* .tableBody{height: 395px !important;} */

	</style>

	<meta charset="utf-8">
	<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
	<meta name="format-detection" content="telephone=no" />
	<title>MObile MES</title>
	<%@ include file="/mobile/include/head.jsp" %>
	<script>
		var mach_cd;
		$(document).ready(function(){
			gridList.setGrid({
				id : "gridList",
		    	url : "/mobile/Mobile/PDA_INV04/json/datalist.data",
		    	bigdata : false,
		    	gridMobileType : true
			});
			
			searchList();
		});

		function searchList(){
			var param = new DataMap();
			param.put("P_TYPE","SUB_LIST");
        	param.put("WERKS", '<%=plant%>');
        	param.put("MACH_CD", '<%=machCd%>');
	 		
			gridList.gridList({
				id : "gridList",
				param : param
			});
			PlaySound('s');
		}

		function closePop(){
			var data = gridList.getSelectData("gridList");
			
			if(data.length < 1){
				PlaySound('e');
				commonUtil.msg("작업조를 선택하시기 바랍니다.");
				return;
			} else if(data.length > 1){
				PlaySound('e');
       			commonUtil.msg("하나의 작업조만 선택하시기 바랍니다.");
       			return;
       		}
			
			for(var i = 0; i < data.length; i++){
				var wrk_meth = data[i].get("WRK_METH");
				var wrk_meth_nm = data[i].get("WRK_METH_NM");
				var strTm = data[i].get('STR_TM').substr(0,2) + ':' + data[i].get('STR_TM').substr(2,2);
				var endTm = data[i].get('END_TM').substr(0,2) + ':' + data[i].get('END_TM').substr(2,2);
			}
			paramStr = 'IND_BCD=<%=indbcd%>&INP_QTY=<%=inpqty%>&WRK_METH=' + wrk_meth + '&WRK_METH_NM=' + wrk_meth_nm + '&STR_TM=' + strTm + '&END_TM=' + endTm;
			
			location.href = '/mobile/PDA_INV04.page?' + paramStr;
		}
	</script>
</head>
<body>
<div class="main_wrap">
	<div class="main_header_pop">
		<ul>
			<li class="tit" id="title">작업조</li>
		</ul>
	</div>
	<div class="tem4_content">
		<div class="select_box" id="bindArea">
			<div id="searchArea">
				<table>
				</table>
			</div>
		</div>

		<div class="tableWrap_search section">
			<div class="tableHeader">
				<table style="width:120%;">
					<colgroup>
						<col width="2px" />
						<col width="2px" />
						<col width="5px" />
						<col width="5px" />
						<col width="5px" />
						<col width="5px" />
					</colgroup>
					<thead>
					<tr>
						<th>No.</th>
						<th>선택</th>
						<th>작업조</th>
						<th>작업조명</th>
						<th>시작시간</th>
						<th>종료시간</th>
					</tr>
					</thead>
				</table>
			</div>

			<div class="tableBody">
				<table style="width:120%;">
					<colgroup>
						<col width="2px" />
						<col width="2px" />
						<col width="5px" />
						<col width="5px" />
						<col width="5px" />
						<col width="5px" />
					</colgroup>
					<tbody id="gridList">
						<tr CGRow="true">
							<td GCol="rownum"></td>
							<td GCol="rowCheck"></td>
							<td GCol="text,WRK_METH" style="text-align:center;">작업조</td>
							<td GCol="text,WRK_METH_NM">작업조명</td>	
							<td GCol="text,STR_TM" GF='T' style="text-align:center;">시작시간</td>
							<td GCol="text,END_TM" GF='T' style="text-align:center;">종료시간</td>	
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