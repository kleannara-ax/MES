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
			command : "MDL06SEARCH",
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
	
	function selectData(){
		var param =  new DataMap();
		
		var selectList = gridList.getSelectData("gridList");
		if(selectList.length == 0){
			commonUtil.msgBox("VALID_M0006");
			//alert("선택된 데이터가 없습니다.");
			return;
		}else{
			var rowNum = gridList.getSelectIndex("gridList");
			var rowData = gridList.getRowData("gridList", rowNum);
			mobile.linkPopClose(rowData);
		}
	}	
	
	function clearText(data){
		if(data!=null||data!=""){
	    	data.value="";
	    }      
	}
	
	/* function gridListEventRowDblclick(gridId, rowNum){
		var rowData = gridList.getRowData(gridId, rowNum);
		mobile.linkPopClose(rowData);
	} */
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
									<option value="SHPOKY">출하문서번호</option>
									<option value="TASKKY">작업지시번호</option>
									<option value="SKUKEY">품번</option>
									<option value="DESC01">품명</option>
								</select>
							</td>
							<td rowspan="2">
								<a href="#"><input type="button" value="조회" class="bt" onclick='searchList()'/></a>
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
			<!-- end select_box -->
					
					
			<div class="tableWrap_search section">
				<div class="tableHeader">
					<table style="width: 100%"> 
						<colgroup>
							<col width="60px" />
							<col width="60px" />
							<col width="80px" />
							<col width="200px" />
							<col width="80px" />
							<col width="100px"/>
							<col width="100px" />
							<col width="100px"/>
						</colgroup>
						<thead>
							<tr class="thead">
								<th>번호</th>
								<th>선택</th>
								<th>품목</th>
								<th>품명</th>
								<th>수량</th>
								<th>지번</th>
								<th>출하문서번호</th>
								<th>작업지시번호</th>
							</tr>
						</thead>
					</table>				
				</div>
				<!-- end tableHeader -->
				
				<div class="tableBody">
					<table style="width: 100%">
						<colgroup>
							<col width="60px" />
							<col width="60px" />
							<col width="80px" />
							<col width="200px" />
							<col width="80px" />
							<col width="100px"/>
							<col width="100px" />
							<col width="100px"/>
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rownum"></td>
								<td GCol="rowCheck,radio"></td>
								<td GCol="text,SKUKEY"></td>
								<td GCol="text,DESC01"></td>					
								<td GCol="text,TRNQTY"></td>
								<td GCol="text,LOCASR"></td>
								<td GCol="text,SHPOKY"></td>
								<td GCol="text,TASKKY" ></td>
							</tr>
						</tbody>
					</table>
				</div>
				<!-- end tableBody -->
				
			</div>
			<!-- end tableWrap_search -->	
				
			<div class="bottom">
				<input type="button" value="선택" class="bottom_bt" onClick="selectData()"/>
			</div>
			<!-- end bottom -->	
			
		</div>
		<!-- end tem4_content -->	
			
	</div>
	<!-- end main_wrap -->
</body>