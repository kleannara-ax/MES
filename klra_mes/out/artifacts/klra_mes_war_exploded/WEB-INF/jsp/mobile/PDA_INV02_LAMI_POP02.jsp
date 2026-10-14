
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String machCd = (String)request.getSession().getAttribute(CommonConfig.SES_MACH_CD);
	String plant = (String)request.getSession().getAttribute(CommonConfig.SES_USER_PLANT_KEY);
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
	<title>투입이력</title>
	<%@ include file="/mobile/include/head.jsp" %>
	<script>
		var machCd;
		
		$(document).ready(function(){
			gridList.setGrid({
				id : "gridList",
				url : "/mobile/Mobile/PDA_INV02_LAMI/json/datalist.data",
				bigdata : false,
				gridMobileType : true
			});
			
			//var data = mobile.getLinkPopData();	
			//machCd = data.get("MACH_CD");
			
			searchList();
		});

		function searchList(){
			PlaySound('s');
			var param = new DataMap();
			
			param.put("P_TYPE", "SUB_LIST3");
			param.put("WERKS", "<%=plant%>");
			param.put("MACH_CD", '<%=machcd%>');
			param.put("START_DT", $("#START_DT").val());
			param.put("END_DT", $("#END_DT").val());

			gridList.gridList({
				id : "gridList",
				param : param
			});
		}
		
		function Inpcancel(){
			var data = gridList.getSelectData("gridList");
       		
       		if(data.length < 1){
       			commonUtil.msg("투입 취소할 자재를 선택하세요.");
       			return;
       		}
       		
       		var param = new DataMap();
       		
       		param.put("P_TYPE", "SUB_SAVE1");
       		param.put("list", data);
	 		param.put("WERKS", '<%=plant%>');		// 플랜트
	 		param.put("MACH_CD", '<%=machcd%>');			// 설비
	 		
	 		commonUtil.msgConfirm("투입한 자재를 취소하시겠습니까?", null, function(){
		 		netUtil.send({
	 				url : "/mobile/Mobile/PDA_INV02_LAMI/json/datalist.data",
	 				param : param,
	 				successFunction : "saveSuccessCallBack"
	 		   	});
	 		}, function(){
	 			searchList();
	 		});
        }
        
        function saveSuccessCallBack(json){
			if(json.P_SUCCESS == 'Y'){
				PlaySound('s');
 	 			commonUtil.msg("투입 취소되었습니다.");
 	 			
 	 			//mobile.linkPopClose();
 	 			location.href = "/mobile/PDA_INV02_LAMI_POP02.page?MACH_CD=<%=machcd%>";
 	 		} else{
 	 			PlaySound('e');
 	 		}
        }
	</script>
</head>
<body>
<div class="main_wrap">
	<div class="main_header">
		<ul>
			<li class="tit" id="title" style="width:100%;">자재 투입이력</li>
		</ul>
	</div>
	<div class="tem4_content">
		<div class="select_box" id="bindArea">
			<div class="searchArea" id="searchArea">
				<table>
				</table>
			</div>
		</div>
		
		<div class="select_box" id="bindArea">
			<div id="searchArea">
				<table>
					<colgroup>
						<col width="30px"  />
						<col width="70px"  />
						<col width="30px"/>
						<col width="70px" />
						<col width="65px" />
						<col width="70px" />
					</colgroup>
					<tbody>
						<tr>
							<td>일자</td>
							<td>
								<input type="text" class="text" id="START_DT" UIFormat="C N" style="width:50%;text-align:center;float:left;"/>
							</td>
							<td> ~ </td>
							<td>
								<input type="text" class="text" id="END_DT" UIFormat="C N" style="width:50%;text-align:center;float:left;"/>
							</td>
							<td></td>
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
				<table>
					<colgroup>
						<col width="10px" />
						<!-- <col width="10px" /> -->
						<col width="20px" />
						<col width="10px" />
						<col width="30px" />
						<col width="20px" />
						<col width="10px"/>
						<col width="10px"/>
					</colgroup>
					<thead>
						<tr>
							<th>No</th>
							<!-- <th>선택</th> -->
							<th>투입일자</th>
							<th>자재번호</th>
							<th>자재명</th>
							<th>업체/개별바코드</th>
							<th>투입량</th>
							<th>단위</th>
						</tr>
					</thead>
				</table>
			</div>

			<div class="tableBody">
				<table>
					<colgroup>
						<col width="10px" />
						<!-- <col width="10px" /> -->
						<col width="20px" />
						<col width="10px" />
						<col width="30px" />
						<col width="20px" />
						<col width="10px"/>
						<col width="10px"/>
					</colgroup>
					<tbody id="gridList">
						<tr CGRow="true">
							<td GCol="rownum">1</td>
							<!-- <td GCol="rowCheck"></td> -->
							<td GCol="text,INP_DT">투입일자</td>
							<td GCol="text,MATNR">자재코드</td>
							<td GCol="text,MATNR_NM">자재명</td>
							<td GCol="text,IND_BCD">업체/개별바코드</td>
							<td GCol="text,INP_QTY" GF='N 13,3'>투입량</td>
							<td GCol="text,UNIT">단위</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<!-- end table_body -->
		<div class="footer_5" style="position:fixed;">
			<table>
				<tr>
					<td class=f_1 onclick="history.back();" style="width: 100%"><label>닫기</label></td>
					<!-- <td class=f_1 onclick="Inpcancel();" style="width: 50%;"><label >투입취소</label></td> -->
				</tr>
			</table>
		</div><!-- end footer_5 -->
	</div>
</div>
</body>