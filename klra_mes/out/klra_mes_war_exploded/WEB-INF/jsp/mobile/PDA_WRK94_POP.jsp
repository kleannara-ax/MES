<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String plant = (String)request.getSession().getAttribute(CommonConfig.SES_USER_PLANT_KEY);
	String indbcd = request.getParameter("IND_BCD");
	String procCd = request.getParameter("PROC_CD");
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
		    	url : "/mobile/Mobile/PDA_WRK94/json/datalist.data",
		    	bigdata : false,
		    	gridMobileType : true
			});
			console.log('112212121', '<%=indbcd%>');
			searchList();
		});

		function searchList(){
			PlaySound('s');
			var param = new DataMap();

  		   param.put("P_TYPE", "SUB_LIST1");
  		   param.put("WERKS", '<%=plant%>');
  		   param.put("PROC_CD", '<%=procCd%>');
  		   param.put("IND_BCD", '<%=indbcd%>');

			gridList.gridList({
				id : "gridList",
				param : param
			});
		}

		function closePop(){
			var data = gridList.getSelectData("gridList");
			
			if(data.length < 1){
				PlaySound('e');
				return alert("생산오더를 선택하시기 바랍니다.");
			}else if(data.length > 1){
				PlaySound('e');
				return alert("하나의 생산오더만 선택하시기 바랍니다.");
       		}

			for(var i = 0; i < data.length; i++){
				var flag = data[i].get("FLAG");
				var indBcd = data[i].get("IND_BCD");
				var lotNo = data[i].get("LOT_NO");
				var orderNo2 = data[i].get("ORDER_NO");
				var matnr = data[i].get("MATNR");
				var qty = data[i].get("QTY");
				var others = data[i].get("OTHERS");
				var stck_sta = data[i].get("STCK_STA");
			}

/*			
 			if (stck_sta != "투입가능") {
				PlaySound('e');
				return alert("이미 투입된 생산오더 입니다.");
				
			}
 */
 			var paramStr = 'IND_BCD=' + indBcd + '&FLAG=' + flag + '&LOT_NO=' + lotNo + '&ORDER_NO=' + orderNo2 + '&MATNR=' + matnr + '&QTY=' + qty + '&OTHERS=' + others;
			console.log('paramStr = ', paramStr);
			location.href = '/mobile/PDA_WRK94.page?' + paramStr;
		}
		
		function closePop2(){
			var paramStr = 'IND_BCD=<%=indbcd%>';
			
			location.href = '/mobile/PDA_WRK94.page?' + paramStr;
		}
	</script>
</head>
<body>
<div class="main_wrap">
	<div class="main_header_pop">
		<ul>
			<li class="t01"></li>
			<li class="tit" id="title">생산오더 목록</li>
		</ul>
	</div>
	<div class="tem4_content">
		<div class="tableWrap_search section">
			<div class="tableHeader">
				<table style="width:100%;">
					<colgroup>
						<col width="2px" />
						<col width="2px"  hidden/>
						<col width="5px"  hidden/>
						<col width="8px"  hidden/>
						<col width="8px" />
						<col width="8px"  hidden/>
						<col width="8px" />
						<col width="8px" hidden/>
						<col width="8px"/>
					</colgroup>
					<thead>
						<tr>
							<th CL="선택"></th>
							<th CL='구분' hidden></th>
							<th CL='개별바코드' hidden></th>
							<th CL='LOT_NO' hidden></th>
							<th CL='오더번호'></th>
							<th CL='자재(제품)코드' hidden></th>
							<th CL='불출수량'></th>
							<th CL='OTHER' hidden></th>
							<th CL='투입여부'></th>
						</tr>
					</thead>
				</table>
			</div>

			<div class="tableBody">
				<table style="width:100%;">
					<colgroup>
						<col width="2px" />
						<col width="2px"  hidden/>
						<col width="5px"  hidden/>
						<col width="8px"  hidden/>
						<col width="8px" />
						<col width="8px"  hidden/>
						<col width="8px" />
						<col width="8px"  hidden/>
						<col width="8px" />
					</colgroup>
					<tbody id="gridList">
						<tr CGRow="true">
							<td GCol="rowCheck"></td>
							<td GCol="text,FLAG" hidden></td>
							<td GCol="text,IND_BCD" style='text-align:center;' hidden></td>
							<td GCol="text,LOT_NO" hidden></td>
							<td GCol="text,ORDER_NO"></td>
							<td GCol="text,MATNR" hidden></td>
							<td GCol="text,QTY"></td>
							<td GCol="text,OTHERS" hidden></td>
							<td GCol="text,STCK_STA"></td>
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