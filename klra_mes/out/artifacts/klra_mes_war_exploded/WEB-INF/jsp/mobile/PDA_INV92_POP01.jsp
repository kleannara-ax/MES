<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
	String machcd = request.getParameter("MACH_CD");
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
		//var mach_cd;
		$(document).ready(function(){
			gridList.setGrid({
				id : "gridList",
		    	url : "/mobile/Mobile/PDA_INV02/json/datalist.data",
		    	bigdata : false,
		    	gridMobileType : true
			});

			//var data = mobile.getLinkPopData();
			//mach_cd = data.get("MACH_CD");
			
		});

		function searchList(){
			var param = new DataMap();
			var sdate = $("#SDATE").val();
			var edate = $("#EDATE").val();
			var sdate_rp = commonUtil.replaceAll(sdate, "-", "");
			var edate_rp = commonUtil.replaceAll(edate, "-", "");
			
			param.put("P_TYPE","SUB_LIST2");
			param.put("SDATE", sdate_rp);
			param.put("EDATE", edate_rp);
			param.put("MACH_CD", '<%=machcd%>');
			
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
			} else if(data.length > 1){
				PlaySound('e');
				commonUtil.msg("하나의 작업지시만 선택하시기 바랍니다.");
       			return;
       		}
			
			for(var i = 0; i < data.length; i++){
				var wrkordrno = data[i].get("WRK_ORDR_NO");	//작업지시번호
				var wrkordrseqno = data[i].get("WRK_ORDR_SEQNO");	//작업지시순번
				var matnrnm = data[i].get("MATNR_NM");	//자재명
			}
			
			//var param = new DataMap();
			
			//param.put("wrkordrno", wrkordrno);
			//param.put("wrk_ordr_seqno", wrk_ordr_seqno);
			//param.put("matnr_nm", matnr_nm);
			
			//mobile.linkPopClose(param);
			var paramStr = "MACH_CD=<%=machcd%>&WRK_ORDR_NO=" + wrkordrno + "&WRK_ORDR_SEQNO=" + wrkordrseqno + "&MATNR_NM=" + matnrnm;
	       	
	        location.href = "/mobile/PDA_INV92.page?" + paramStr;
		}
	</script>
</head>
<body>
<div class="main_wrap">
	<div class="main_header">
		<ul>
			<li class="tit" id="title" style="width:100%;">생산 작업지시</li>
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
								<input type="text" class="text" id="SDATE" UIFormat="C M1" style="width:50%;text-align:center;float:left;"/>
							</td>
							<td>~</td>
							<td>
								<input type="text" class="text" id="EDATE" UIFormat="C N" style="width:50%;text-align:center;float:left;"/>
							<td><button type='button' class="bt" style="height: 36px" onclick="searchList();">조회</button></td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div class="tableWrap_search section">
			<div class="tableHeader">
				<table style="width:340%;">
					<colgroup>
						<col width="10px" />
						<col width="10px" />
						<col width="40px" />
						<col width="15px" />
						<col width="15px" />
						<col width="20px" />
						<col width="50px" />
						<col width="30px" />
					</colgroup>
					<thead>
					<tr>
						<th>No.</th>
						<th>선택</th>
						<th>지시번호</th>
						<th>오더번호</th>
						<th>지시순번</th>
						<th>자재코드</th>
						<th>자재명</th>
						<th>계획수량</th>
					</tr>
					</thead>
				</table>
			</div>

			<div class="tableBody">
				<table style="width:340%;">
					<colgroup>
						<col width="10px" />
						<col width="10px" />
						<col width="40px" />
						<col width="15px" />
						<col width="15px" />
						<col width="20px" />
						<col width="50px" />
						<col width="30px" />
					</colgroup>
					<tbody id="gridList">
						<tr CGRow="true">
							<td GCol="rownum"></td>
							<td GCol="rowCheck"></td>
							<td GCol="text,WRK_ORDR_NO">지시번호</td>
							<td GCol="text,ORDER_NO">오더번호</td>
							<td GCol="text,WRK_ORDR_SEQNO">지시순번</td>	
							<td GCol="text,MATNR" style="text-align:center;">자재코드</td>	
							<td GCol="text,MATNR_NM">자재명</td>	
							<td GCol="text,WRK_ORDR_QTY" GF="N 16,3">계획수량</td>
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