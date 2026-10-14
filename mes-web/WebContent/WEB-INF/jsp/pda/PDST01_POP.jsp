<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<head>
<style type="text/css">
button {float: right; }
input:read-only { 
    background-color: #e2e2e2;
}
select:DISABLED {
	background-color: #e2e2e2;
}
</style>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>Smile Mobile WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script>
	$(document).ready(function(){
		var data = mobile.getLinkPopData();

		dataBind.dataNameBind(data, "bindArea");
	});
	
	function showMain(){
		mobile.linkPopClose();
	}
	
</script>
</head>
<body>
	<div id="menu-container">
		<div class="menu-item"  CL='MENU_PDST10_POP'></div> <!-- 재고현황(상세) -->
	</div>
	<div class="main_wrap" id="searchArea">
		<div class="tem4_content">
			<div class="select_box" id="bindArea">
				<hr />
				<table>
					<colgroup>
						<col width="80px" />
						<col />
						<col width="80px" />
						<col />
					</colgroup>
					<tbody>
						<tr>
							<th CL="STD_LOCAKY">LOC</th>
							<td colspan="3">
								<input type="text" class="text" name="LOCAKY" id="LOCAKY" readonly="readonly" />
							</td>
						</tr>
						<tr>
							<th CL="STD_TRNUID">P/T</th>
							<td colspan="3">
								<input type="text" class="text" name="TRNUID" id="TRNUID" readonly="readonly" />
							</td>
						</tr>
						<tr>
							<th CL="STD_SELLER">SELLER</th>
							<td colspan="3">
								<input type="text" class="text" name="NAME01" id="NAME01" readonly="readonly" />
							</td>
						</tr>
						<tr>
							<th CL="STD_SKUKEY">SKU번호</th>
							<td colspan="2">
								<input type="text" class="text" name="EANCOD" readonly="readonly" />
							</td>
							<td>
								<input type="text" class="text" name="SKUKEY" readonly="readonly" />
							</td>
						</tr>
						<tr>
							<th CL="STD_DESC01">SKU명</th>
							<td colspan="3">
								<!-- <input type="text" class="text" name="DESC01" readonly="readonly" /> -->
								<textarea name="DESC01" id="DESC01" cols="40" row="2" style="width:98%; margin-right:3px;height:40px;border:solid 1px #d5d5d5;" disabled readonly>
								</textarea>
							</td>
						</tr>
						<tr>
							<th CL="STD_ASKU01">유통기한관리</th>
							<td>
								<input type="text" class="text" name="ASKU01" id="ASKU01" readonly="readonly" style="width: 98%" />
							</td>
							<th CL="STD_LOTA13">유통기한</th>
							<td>
								<input type="text" class="text" name="LOTA13" id="LOTA13" readonly="readonly" />
							</td>
						</tr>
						<tr>
							<th CL="STD_LOTA12">입고일자</th>
							<td>
								<input type="text" class="text" name="LOTA12" id="LOTA12" readonly="readonly" style="width: 98%" />
							</td>
							<th CL="STD_SHLMTD"></th>
							<td>
								<input type="text" class="text" name="SHP_LIMIT" id="SHP_LIMIT" readonly="readonly" UIFormat="D" />
							</td>
						</tr>
							<tr>
							<th CL="STD_PLOCOV">재고상태</th>
							<td colspan="3">
								<input type="text" class="text" name="PLOCOV" id="PLOCOV" readonly="readonly" />
							</td>
						</tr>
						<tr>
							<th CL="STD_LOTA10">재고상태</th>
							<td>
								<input type="text" class="text" name="LOTA10" id="LOTA10" readonly="readonly" />
							</td>
							<th CL="STD_QTSIWH">재고수량</th>
							<td>
								<input type="text" class="text" name="QTSIWH" id="QTSIWH" readonly="readonly" />
							</td>
						</tr>
						<tr>
							<th CL="STD_USEQTY">가용수량</th>
							<td>
								<input type="text" class="text" name="USEQTY" id="USEQTY" readonly="readonly" />
							</td>
							<th CL="STD_QTSALO">할당수량</th>
							<td>
								<input type="text" class="text" name="QTSALO" id="QTSALO" readonly="readonly" style="width: 98%" />
							</td>
						</tr>
						<tr>
							<th CL="STD_QTSPMO">이동 OUT수량</th>
							<td>
								<input type="text" class="text" name="QTSPMO" id="QTSPMO" readonly="readonly" />
							</td>
							<th CL="STD_QTSPMI">이동 IN수량</th>
							<td>
								<input type="text" class="text" name="QTSPMI" id="QTSPMI" readonly="readonly" style="width: 98%" />
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			
				<!-- end table_body -->
			<div class="footer_5">
				<table>
					<tr>
						<td class=f_1 onclick ="showMain()" width="50%"><label CL='BTN_CLOSE'></label></td>
					</tr>
				</table>
			</div><!-- end footer_5 -->	
		</div>
	</div>
</body>