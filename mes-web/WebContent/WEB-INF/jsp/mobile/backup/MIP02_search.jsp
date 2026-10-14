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
			module : "Mobile",
			command : "MIP02Sub",
			gridMobileType : true
	    });
		
	});
	function searchList(){
		if(validate.check("searchArea")){
			var param = dataBind.paramData("searchArea");
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
					
		}
	}
	
	function sendData(){
		var data = gridList.getSelectData("gridList");
		
		if (data.length == 0) {
			alert("선택된 데이터가 없습니다.");
			return;
		} else {
			var rowNum = gridList.getFocusRowNum("gridList");
			var rowData = gridList.getRowData("gridList", rowNum);
			//alert(rowData);
			mobile.linkPopClose(rowData);
		}
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
									<select name="COLNAME" id="COLNAME">
										<option value="PHYIKY" >실사문서번호</option>
										<option value="AREAKY">영역</option>
										<option value="ZONEKY">구역</option>
										<option value="LOCAKY">지번</option>
										<option value="SKUKEY">품번</option>
										<option value="DESC01">품명</option>
									</select>
								</td>
								<td rowspan="2">
									<a href="#"><input type="button" value="조회" class="bt" onclick="searchList()"/></a>
								</td>
							</tr>
							<tr>
								<td class="second">
									<input type="text" class="text" name ="COLTEXT" validate="required" onkeypress="commonUtil.enterKeyCheck(event, 'searchList()')" onfocus="clearText(this)"/>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="tableWrap_search">
				<div class="tableHeader">
					<table style="width: 100%">
						<colgroup>
								<col width="60px" />
								<col width="60px" />
								<col width="100px" />
								<col width="250px"/>
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="80px"/>
								<col width="80px" />
								<col width="80px" />
								<col width="80px"/>
								<col width="80px"/>
								<col width="80px"/>
								<col width="80px"/>
								<col width="100px"/>
						</colgroup>
						<thead>
							<tr class="thead">
								<th>번호</th>
								<th GBtnCheck="true">선택</th>
								<th>품번코드</th>
								<th>품명</th>
								<th>영역코드</th>
								<th>구역코드</th>
								<th>지번</th>
								<th>단위</th>
								<th>재고수량</th>
								<th>PDA실사수량</th>
								<th>재고조사수량</th>
								<th>센터코드</th>
								<th>문서유형</th>
								<th>조사타입</th>
								<th>문서일자</th>
								
							</tr>
						</thead>
					</table>				
				</div>
				<div class="tableBody">
					<table style="width: 100%">
						<colgroup>
								<col width="60px" />
								<col width="60px" />
								<col width="100px" />
								<col width="250px"/>
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="80px"/>
								<col width="80px" />
								<col width="80px" />
								<col width="80px"/>
								<col width="80px"/>
								<col width="80px"/>
								<col width="80px"/>
								<col width="100px"/>
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rownum">1</td>
								<td GCol="rowCheck,radio"></td>
								<td GCol="text,SKUKEY"></td>
								<td GCol="text,DESC01"></td>
								<td GCol="text,AREAKY"></td>
								<td GCol="text,ZONEKY"></td>
								<td GCol="text,LOCAKY"></td>
								<td GCol="text,UOMKEY"></td>
								<td GCol="text,QTSIWH" GF="N 8"></td>
								<td GCol="text,QTYPDA" GF="N 8"></td>
								<td GCol="text,QTSPHY"></td>				
								<td GCol="text,WAREKY"></td>			
								<td GCol="text,DOCCAT"></td>			
								<td GCol="text,PHSCTY"></td>			
								<td GCol="text,DOCDAT"></td>		
							
							</tr>
							
							
							
								
							
							
															
						</tbody>
					</table>
				</div>
				</div>
				
				<div class="bottom">
					<input type="button" value="선택" class="bottom_bt" onclick="sendData()"/>
				</div>
		</div>	
	</div>
</body>