<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String plant = (String)request.getSession().getAttribute(CommonConfig.SES_USER_PLANT_KEY);
	String indbcd = request.getParameter("IND_BCD");
	String wrkordrno = request.getParameter("WRK_ORDR_NO");
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
	<title>Mobile Mes</title>
	<%@ include file="/mobile/include/head.jsp" %>
	<script>
		$(document).ready(function(){
			gridList.setGrid({
				id : "gridList",
		    	url : "/mobile/Mobile/PDA_WRK07_POP/json/datalist.data",
		    	bigdata : false,
		    	gridMobileType : true
			});
			searchList()
		});

		function searchList(){
			PlaySound('s');
			var param = new DataMap();
			
			param.put("P_TYPE","LIST2");
			param.put("WERKS", '<%=plant%>');
			
			gridList.gridList({
				id : "gridList",
				param : param
			});
		}

		function closePop(){
			var data = gridList.getSelectData("gridList");
			
			if(data.length < 1){
				PlaySound('e');
				return alert("저장위치를 선택하시기 바랍니다.");
			}else if(data.length > 1){
				PlaySound('e');
				return alert("하나의 저장위치만 선택하시기 바랍니다.");
       		}
			
			for(var i = 0; i < data.length; i++){
				var storlocCd = data[i].get("STOR_LOC_CD");
				var storlocnm = data[i].get("STOR_LOC_NM");
			}
			
			var paramStr = 'IND_BCD=<%=indbcd%>&STOR_LOC_CD=' + storlocCd + '&STOR_LOC_NM=' + storlocnm + '&WRK_ORDR_NO=<%=wrkordrno%>';
			
			location.href = '/mobile/PDA_WRK07.page?' + paramStr;
		}
		
		function closePop2(){
			var paramStr = 'IND_BCD=<%=indbcd%>&WRK_ORDR_NO=<%=wrkordrno%>';
			
			location.href = '/mobile/PDA_WRK07.page?' + paramStr;
		}
	</script>
</head>
<body>
<div class="main_wrap">
	<div class="main_header_pop">
		<ul>
			<li class="t01"></li>
			<li class="tit" id="title">저장위치 목록</li>
		</ul>
	</div>
	<div class="tem4_content">
		<div class="tableWrap_search section">
			<div class="tableHeader">
				<table style="width:100%;">
					<colgroup>
						<col width="2px" />
						<col width="2px" />
						<col width="5px" />
						<col width="8px" />
					</colgroup>
					<thead>
						<tr>
							<th CL="STD_NO">No.</th>
							<th CL='선택'></th>
							<th CL='STD_STOR_LOC_CD'></th>		<!-- 저장위치코드 -->
							<th CL='STD_STOR_LOC_NM'></th>	<!-- 저장위치명 -->
						</tr>
					</thead>
				</table>
			</div>

			<div class="tableBody">
				<table style="width:100%;">
					<colgroup>
						<col width="2px" />
						<col width="2px" />
						<col width="5px" />
						<col width="8px" />
					</colgroup>
					<tbody id="gridList">
						<tr CGRow="true">
							<td GCol="rownum"></td>
							<td GCol="rowCheck"></td>
							<td GCol="text,STOR_LOC_CD" style='text-align:center;'></td>
							<td GCol="text,STOR_LOC_NM"></td>
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
					<td class=f_1 onclick="closePop2();" style="width: 50%"><label>닫기</label></td>
					<td class=f_1 onclick="closePop();" style="width: 50%;"><label >선택</label></td>
				</tr>
			</table>
		</div><!-- end footer_5 -->
	</div>
</div>
</body>