<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>슈피겐코리아 모바일 WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script>
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			editable : false,
			url : '/IF/list/json/MGR06SEARCH.data',
			gridMobileType : true
	    });
	});
	
	function searchList(){
		var param = dataBind.paramData("searchArea");
		var $obj = $("[name=COLTEXT]");
		if($obj.val() == ""){
			alert("입고오더번호 또는 품번코드 또는 품명을 입력하세요.");
			$obj.focus();
			return;
		}
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
	}
	
	function selectData(){
		//var rowNum = gridList.getFocusRowNum("gridList");
		var rowNum = gridList.getSelectIndex("gridList");
		var rowData = gridList.getRowData("gridList", rowNum);
		mobile.linkPopClose(rowData);
	}
	
	function clearText(data){
		if(data!=null||data!=""){
	    	data.value="";
	    }      
	}

</script>
</head>
<body>
	<div class="main_wrap">
		<div class="tem4_content">
				<div class="select_box">
					<table>
						<colgroup>
							<col  />
							<col width="100px" />
						</colgroup>
						<tbody id="searchArea">
							<tr>
								<td class="first">
									<select name="COLNAME">
										<option value="SEBELN">입고오더번호</option>
										<option value="SKUKEY">품번코드</option>
										<option value="DESC01">품명</option>
									</select>
								</td>
								<td rowspan="2">
									<a href="#"><input type="button" value="조회" class="bt" onclick='searchList()'/></a>
								</td>
							</tr>
							<tr>
								<td class="second">
									<input type="text" class="text" name="COLTEXT" onkeypress="commonUtil.enterKeyCheck(event, 'searchList()')" onfocus="clearText(this)"/>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="tableWrap_search section">
				<div class="tableHeader">
					<table>
						<colgroup>
								<col width="40px" />
								<col width="40px" />
								<col width="60px" />
								<col width="55px" />
								<col width="80px" />
								<col width="80px" />
								<col width="150px"/>
								<col width="80px"/>
								<col width="80px" />
								<col width="80px" />
								<col width="80px"/>
								<col width="80px" />
								<col width="80px"/>
								<col width="80px" />
								<col width="80px" />
						</colgroup>
						<thead>
							<tr class="thead">
								<th CL='STD_NUMBER'>번호</th>
								<th >선택</th>
								<th CL='STD_OUTRTNCD'>출고반품입고유형</th>
								<th CL='STD_EBELN'>ERP주문번호</th>
								<th CL='STD_SEBELN'>입고오더번호</th>
								<th CL='STD_SKUKEY'>품번코드</th>
								<th CL='STD_DESC01'>품명</th>
								<th CL='STD_REQDAT'>입고요청일자</th>
								<th CL='STD_REQNO'>요청번호</th>
								<th CL='STD_DOCCATNM'>문서유형</th>
								<th CL='STD_WAREKYNM'>CenterName</th>
								<th CL='STD_DPTNKY'>업체코드</th>
								<th CL='STD_DPTNKYNM'>업체코드명</th>
								<th CL='STD_RCPTTYNM'>입하유형</th>
								<th CL='STD_STATDO'>문서상태명</th>
							</tr>
						</thead>
					</table>				
				</div>
				<div class="tableBody">
					<table>
						<colgroup>
								<col width="40px" />
								<col width="40px" />
								<col width="60px" />
								<col width="55px" />
								<col width="80px" />
								<col width="80px" />
								<col width="150px"/>
								<col width="80px"/>
								<col width="80px" />
								<col width="80px" />
								<col width="80px"/>
								<col width="80px" />
								<col width="80px"/>
								<col width="80px" />
								<col width="80px" />
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rownum"></td>
								<td GCol="rowCheck,radio"></td>
								<td GCol="text,SZMBLNONM">출고반품입고유형</td>
								<td GCol="text,SEBELN" >ERP주문번호</td>
								<td GCol="text,WMSREQSEQ">입고오더번호</td>
								<td GCol="text,SKUKEY"></td>
								<td GCol="text,DESC01"></td>
								<td GCol="text,REQDAT"></td>
								<td GCol="text,REQNO"></td>
								<td GCol="text,DOCCATNM"></td>
								<td GCol="text,WAREKYNM"></td>
							    <td GCol="text,DPTNKY"></td>
								<td GCol="text,DPTNKYNM"></td>
								<td GCol="text,RCPTTYNM"></td>
								<td GCol="text,STATDO"></td>
							</tr>
						</tbody>
					</table>
				</div>
				</div>
				
				<div class="bottom">
					<input type="button" value="선택" class="bottom_bt" onclick="selectData()"/>
				</div>
		</div>	
	</div>
</body>