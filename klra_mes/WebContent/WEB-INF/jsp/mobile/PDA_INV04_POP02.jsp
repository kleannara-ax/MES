
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String machCd = (String)request.getSession().getAttribute(CommonConfig.SES_MACH_CD);
	String plant = (String)request.getSession().getAttribute(CommonConfig.SES_USER_PLANT_KEY);
	String inpdate = request.getParameter("INP_DATE");
	String wrkmeth = request.getParameter("WRK_METH");
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
		//const data = mobile.getLinkPopData()	
	
		$(document).ready(function(){
			gridList.setGrid({
				id : "gridList",
				url : "/mobile/Mobile/PDA_INV04/json/datalist.data",
				bigdata : false,
				gridMobileType : true
			});
			
			searchList();
		});

		function showMain() {
	           window.top.menuOpen();
	       }
		
		function searchList(){
			PlaySound('s');
			
			var param = new DataMap();
			
			param.put("P_TYPE", "SUB_LIST3");
			param.put("WERKS", "<%=plant%>");
			
			param.put("MACH_CD", '<%=machCd%>');
			param.put("INP_DATE", '<%=inpdate%>');
			param.put('WRK_METH', '<%=wrkmeth%>');

			gridList.gridList({
				id : "gridList",
				param : param
			});
		}
		
		function Inpcancel(){
			var list = gridList.getSelectData("gridList");
       		
       		if(list.length < 1){
       			commonUtil.msg("투입할 자재를 선택하세요.");
       			return;
       		}
       		
       		var param = new DataMap();
       		
       		param.put("P_TYPE", "SUB_SAVE1");
       		param.put("list", list);
	 		
       		commonUtil.msgConfirm('투입 취소하시겠습니까?', null, function(){
       			netUtil.send({
     				url : "/mobile/Mobile/PDA_INV04/json/datalist.data",
     				param : param,
     				successFunction : "saveSuccessCallBack"
     		   	});
       		}, function(){
       			$('#IND_BCD').focus();
       		});
        }
        
        function saveSuccessCallBack(json){
     	   if(json&&json.data){
     		  	PlaySound('s');
 	 			commonUtil.msgBox("투입취소되었습니다.", null, null, function(){
 	 				searchList();
 	 			}
 	 		} else{
 	 			PlaySound('e');
 	 		}
        }
	</script>
</head>
<body>
<div class="main_wrap">
	<div class="main_header_pop">
		<ul>
			<li class="tit" id="title">자재 투입이력</li>
		</ul>
	</div>
	<div class="tem4_content">
		<div class="select_box" id="bindArea">
			<div class="searchArea" id="searchArea">
				<table>
				</table>
			</div>
		</div>

		<div class="tableWrap_search section">
			<div class="tableHeader">
				<table style='width:230%;'>
					<colgroup>
						<col width="3px" />
						<col width="3px" />
						<col width="6px" />
						<col width="6px" />
						<col width="8px" />
						<col width="6px" />
						<col width="5px" />
						<col width="4px"/>
						<col width="4px"/>
						<col width="3px"/>
					</colgroup>
					<thead>
						<tr>
							<th>No</th>
							<th>선택</th>
							<th>투입일시</th>
							<th>자재번호</th>
							<th>자재명</th>
							<th>업체/개별바코드</th>
							<th>LOT번호</th>
							<th>사용량</th>
							<th>재고수량</th>
							<th>단위</th>
						</tr>
					</thead>
				</table>
			</div>

			<div class="tableBody">
				<table style='width:230%;'>
					<colgroup>
						<col width="3px" />
						<col width="3px" />
						<col width="6px" />
						<col width="6px" />
						<col width="8px" />
						<col width="6px" />
						<col width="5px" />
						<col width="4px"/>
						<col width="4px"/>
						<col width="3px"/>
					</colgroup>
					<tbody id="gridList">
						<tr CGRow="true">
							<td GCol="rownum"></td>
							<td GCol="rowCheck"></td>
							<td GCol='text,REGDATE'></td>				<!-- 투입일시 -->	
							<td GCol="text,MATNR" style='text-align:center;'></td>					<!-- 자재코드 -->
							<td GCol="text,MATNR_NM"></td>				<!-- 자재명 -->
							<td GCol="text,IND_BCD"></td>				<!-- 업체/개별바코드 -->	
							<td GCol="text,LOT_NO"></td>				<!-- LOT NO -->
							<td GCol="text,INP_QTY" GF="N 13,3"></td>	<!-- 사용량 -->
							<td GCol="text,STCK_QTY" GF="N 13,3"></td>	<!-- 재고수량 -->
							<td GCol="text,UNIT" style='text-align:center;'></td>					<!-- 단위 -->
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div class="tableWrap_search section" style='display:none;'>
			<div class="tableHeader">
				<table style='width:100%;'>
					<colgroup>
						<col width="5px" />
						<col width="5px" />
						<col width="6px" />
						<col width="6px" />
					</colgroup>
					<thead>
						<tr>
							<th>플랜트</th>
							<th>설비코드</th>
							<th>문서번호</th>
							<th>작업조</th>
						</tr>
					</thead>
				</table>
			</div>

			<div class="tableBody">
				<table style='width:100%;'>
					<colgroup>
						<col width="5px" />
						<col width="5px" />
						<col width="6px" />
						<col width="6px" />
					</colgroup>
					<tbody id="gridList">
						<tr CGRow="true">
							<td GCol="text,WERKS" style='text-align:center;'></td>		<!-- 플랜트 -->
							<td GCol="text,MACH_CD" style='text-align:center;'></td>	<!-- 설비코드 -->
							<td GCol='text,PDOC_NO' style='text-align:center;'></td>	<!-- 문서번호 -->	
							<td GCol="text,WRK_SHIFT" style='text-align:center;'></td>		<!-- 작업조 -->
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<!-- end table_body -->
		<div class="footer_5" style="position:fixed;">
			<table>
				<tr>
					<td class=f_1 onclick="showMain();" style="width: 50%"><label>닫기</label></td>
					<td class=f_1 onclick="Inpcancel();" style="width: 50%;"><label >투입취소</label></td>
				</tr>
			</table>
		</div><!-- end footer_5 -->
	</div>
</div>
</body>