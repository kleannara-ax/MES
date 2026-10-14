<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String plant = (String)request.getSession().getAttribute(CommonConfig.SES_USER_PLANT_KEY);
	String wrk_ordr_no = request.getParameter("WRK_ORDR_NO");
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
		});

		function searchList(){
			var param = new DataMap();
			var fr_wrk_req_dt = $("#FR_WRK_REQ_DT").val();
			var to_wrk_req_dt = $("#TO_WRK_REQ_DT").val();
			var fr_wrk_req_dt_rp = commonUtil.replaceAll(fr_wrk_req_dt, "-", "");
			var to_wrk_req_dt_rp = commonUtil.replaceAll(to_wrk_req_dt, "-", "");
			
			param.put("P_TYPE","LIST");
			param.put("FR_WRK_REQ_DT", fr_wrk_req_dt_rp);
			param.put("TO_WRK_REQ_DT", to_wrk_req_dt_rp);
			param.put("WERKS", '<%=plant%>');
			
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
				commonUtil.msg("작업지시를 선택하시기 바랍니다.");
				return;
			}else if(data.length > 1){
				PlaySound('e');
       			commonUtil.msg("하나의 작업지시만 선택하시기 바랍니다.");
       			return;
       		}
			
			for(var i = 0; i < data.length; i++){
				var wrkordrno = data[i].get("WRK_ORDR_NO");
			}
			
			location.href = '/mobile/PDA_WRK07.page?WRK_ORDR_NO=' + wrkordrno;
		}

	</script>
</head>
<body>
<div class="main_wrap">
	<div class="main_header_pop">
		<ul>
			<li class="t01"></li>
			<li class="tit" id="title">재고실사 작업지시</li>
		</ul>
	</div>
	<div class="tem4_content">
		<div class="select_box" id="bindArea">
			<div id="searchArea">
				<table>
					<colgroup>
						<col width="70px"  />
						<col />
						<col width="5px">
						<col />
						<col width="70px"  />
					</colgroup>
					<tbody>
						<tr>
							<td>작업일자</td>
							<td>
								<input type="text" class="text" id="FR_WRK_REQ_DT" UIFormat="C M1" style="width:50%;text-align:center;float:left;"/>
							</td>
							<td>~</td>
							<td>
								<input type="text" class="text" id="TO_WRK_REQ_DT" UIFormat="C N" style="width:50%;text-align:center;float:left;"/>
							<td>
								<button type='button' class="bt" style="height: 36px" onclick="searchList();">조회</button>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div class="tableWrap_search section">
			<div class="tableHeader">
				<table style="width:140%;">
					<colgroup>
						<col width="10px" />
						<col width="10px" />
						<col width="20px" />
						<col width="30px" />
						<col width="20px" />
						<col width="40px" />
					</colgroup>
					<thead>
						<tr>
							<th CL="STD_NO">No.</th>
							<th CL='선택'></th>
							<th CL='STD_WERKS'></th>		<!-- 플랜트 -->
							<th CL='STD_WRK_ORDR_NO'></th>	<!-- 작업지시번호 -->
							<th>실사예정일</th>
							<th>비고</th>
						</tr>
					</thead>
				</table>
			</div>

			<div class="tableBody">
				<table style="width:140%;">
					<colgroup>
						<col width="10px" />
						<col width="10px" />
						<col width="20px" />
						<col width="30px" />
						<col width="20px" />
						<col width="40px" />
					</colgroup>
					<tbody id="gridList">
						<tr CGRow="true">
							<td GCol="rownum"></td>
							<td GCol="rowCheck"></td>
							<td GCol="text,WERKS" style='text-align:center;'></td>
							<td GCol="text,WRK_ORDR_NO" style='text-align:center;'></td>
							<td GCol="text,WRK_REQ_DT" GF='D' style='text-align:center;'></td>
							<td GCol="text,WRK_ORDR_RMK"></td>
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