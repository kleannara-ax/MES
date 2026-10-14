<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>IMV Mobile WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script>
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridItemList",
			editable : true,
			module : "Mobile",
			command : "MOM05Sub",
			gridMobileType : true
	    });
		
		var data = mobile.getLinkPopData();
		dataBind.dataNameBind(data, "searchArea");
		
		searchList();
	});
	
	function searchList(){
		var param = inputList.setRangeParam("searchArea");
		
		gridList.resetGrid("gridItemList");
		gridList.setReadOnly("gridItemList", false);
		gridList.setReadOnly("gridItemList", true, ['RSNCOD']);
		
		gridList.gridList({
	    	id : "gridItemList",
	    	param : param
	    });
		
		showMain();
	}
	
	function showMain() {
		$("#main").show();
	}
	
	function popClose(){
 		this.close();
 	}
</script>
</head>
<body>
	<div class="main_wrap" id="main">
		<div id="searchArea">
			<input type="hidden" name="SHPRQK" />
		</div>
		<div id="main_container">
			<div class="tem5_content">
				<div class="tableWrap_search section">
					<div class="tableHeader">
						<table style="width: 100%">
							<colgroup>
								<col width="30px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
							</colgroup>
							<thead>
								<tr>
									<th CL='STD_NUMBER'>번호</th>
									<th CL='STD_SHPRQK'>출고요청번호</th>
									<th CL='STD_SHPRQI'>출고요청순번</th>
									<th CL='STD_SKUKEY'>품번</th>
									<th CL='STD_DESC01'>품명</th>
									<th CL='STD_MATNR,3'>품명</th>
									<th CL='STD_DESC02'>모델</th>
									<th CL='STD_SKUG05'>규격</th>
									<th CL='STD_QTYORD'>출고요청수량</th>
									<th CL='STD_UOMKEY'>단휘</th>
									<th CL='STD_QTYTRN'>이고요청수량</th>
									<th CL='STD_QTYTRS'>이고출고수량</th>
									<th CL='STD_QTYTRR'>이고입고수량</th>
									<th CL='STD_QTALOC'>할당수량</th>
									<th CL='STD_QTJCMP'>피킹완료수량</th>
									<th CL='STD_QTSHPD'>출고완료수량</th>
									<th CL='STD_QTUSHP'>미출수량</th>
									<th CL='STD_TRNSHP'>이고출고문서번호</th>
									<th CL='STD_TRNITM'>이고출고문서순번</th>
									<th CL='STD_SHPOKY'>출고문서번호</th>
									<th CL='STD_SHPOIT'>출고문서순번</th>
									<th CL='STD_LOTA10'></th>
									<!-- <th CL='STD_LOTA16'></th> -->
									<th CL='STD_LOTA17'></th>
									<th CL='STD_LOTA02'></th>
									<th CL='STD_RSNCOD'></th>
									<th CL='STD_TASRSN'></th>
									<th CL='STD_DOCTXT'></th>
								</tr>
							</thead>
						</table>				
					</div>					
					<div class="tableBody">
						<table style="width: 100%">
							<colgroup>
								<col width="30px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
							</colgroup>
							<tbody id="gridItemList">
								<tr CGRow="true">
									<td GCol="rownum"></td>                 
									<td GCol="text,SHPRQK"></td>           <!-- 출고요청번호 -->
									<td GCol="text,SHPRQI"></td>           <!-- 출고요청순번 -->
									<td GCol="text,SKUKEY"></td>           <!-- 품번             -->
									<td GCol="text,DESC01"></td>           <!-- 품명              -->
									<td GCol="text,MATNR"></td>            <!-- BQMS Code              -->
									<td GCol="text,DESC02"></td>           <!-- 모델              -->
									<td GCol="text,SKUG05"></td>           <!-- 규격              -->
									<td GCol="text,QTYORD" GF="N"></td>    <!-- 출고요청수량  -->
									<td GCol="text,UOMKEY"></td>           <!-- 단휘              -->
									<td GCol="text,QTYTRN" GF="N"></td>    <!-- 이고요청수량  -->
									<td GCol="text,QTYTRS" GF="N"></td>    <!-- 이고출고수량  -->
									<td GCol="text,QTYTRR" GF="N"></td>    <!-- 이고입고수량  -->
									<td GCol="text,QTALOC" GF="N"></td>    <!-- 할당수량        -->
									<td GCol="text,QTJCMP" GF="N"></td>    <!-- 피킹완료수량  -->
									<td GCol="text,QTSHPD" GF="N"></td>    <!-- 출고완료수량  -->
									<td GCol="text,QTUSHP" GF="N"></td>    <!-- 미출수량        -->
									<td GCol="text,TRNSHP"></td>           <!-- 이고출고문서번호 -->
									<td GCol="text,TRNSHI"></td>           <!-- 이고출고문서순번 -->
									<td GCol="text,SHPOKY"></td>           <!-- 출고문서번호  -->
									<td GCol="text,SHPOIT"></td>           <!-- 출고문서순번  -->
									<td GCol="text,LOTA10" GF="S 20"></td>
									<!-- <td GCol="text,LOTA16" GF="N 20,3"></td> -->
									<td GCol="text,LOTA17" GF="N 20,3"></td>
									<td GCol="text,LOTA02"></td>           <!-- 출고문서순번  -->
									<td GCol="select,RSNCOD">
										<select ReasonCombo="380"></select>
									</td>
									<td GCol="text,TASRSN"></td>    
									<td GCol="text,DOCTXT"></td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
				<!-- end table_body -->
				<div class="footer_5">
					<table>
						<tr>
							<td onclick="popClose()"><label CL='BTN_CLOSE'></label></td>
						</tr>
					</table>
				</div><!-- end footer_5 -->	
			</div>
		</div>
	</div>
</body>