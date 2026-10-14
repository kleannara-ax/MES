<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.text.*"  %>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>자동화센터관리 시스템</title>
<%@ include file="/mobile/include/head.jsp" %>
<%
  java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("yyyyMMdd");
  String today = formatter.format(new java.util.Date());
%>
<script type="text/javascript">

	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			editable : false,
			module : "Mobile",
			command : "BOXDT",
			gridMobileType : true,
			colGroupCols : "BOXNO"
	    });
	});
	
	function searchList(){
		var param = dataBind.paramData("searchArea");
		var $obj = $("[name=COLTEXT]");
	
		if($obj.val() == ""){
			alert("거래처코드 또는 거래처명 또는 작업일자를 입력하세요.");
			$obj.focus();
			return;
		}
		
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
	}
	
	function selectData(){
		var selectList = gridList.getSelectData("gridList");
		
		if(selectList.length == 0){
			commonUtil.msgBox("VALID_M0006");
			//alert("선택된 데이터가 없습니다.");
			return;
		}else{
			var rowNum = gridList.getSelectIndex("gridList");
			var rowData = gridList.getRowData("gridList", rowNum);
			rowData.put("AAA","aaa");
			mobile.linkPopClose(rowData);
		}
	}	

	function clearText(data){
		if(data!=null||data!=""){
	    	data.value="";
	    }      
	}
	
	function comboChange(data){
		if(data.value == "WRKDAT"){
			$('input[name="COLTEXT"]').val("<%= today%>");
		}else{
			$('input[name="COLTEXT"]').val("");
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
							<col style="width:100px" />
						</colgroup>
						<tbody id="searchArea">
							<tr>
								<td class="first">
									<select name="COLNAME" onchange="comboChange(this)">
										<option value="PTNRKY">거래처코드</option>
										<option value="NAME01">거래처명</option>
										<option value="WRKDAT">작업일자</option>
									</select>
								</td>
								<td rowspan="2">
									<a href="#"><input type="button" value="조회" class="bt" onclick='searchList()'/></a>
								</td>
							</tr>
							<tr>
								<td class="second">
									<input type="text" class="text" name ="COLTEXT" onkeypress="commonUtil.enterKeyCheck(event, 'searchList()')"  onfocus="clearText(this)"/>
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
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="150px" />
							<col width="100px" />
							<col width="100px" />
							<col width="100px" />
						</colgroup>
						<thead>
							<tr class="thead">
								<th CL='STD_NUMBER'>번호</th>
								<th >선택</th>
								<th>박스번호</th>
								<th>거래처 코드</th>
								<th>거래처명</th>
								<th>품번</th>
								<th>품명</th>
								<th>수량</th>
								<th>작업일자</th>
							</tr>
						</thead>
					</table>				
				</div>
				<div class="tableBody">
					<table>
						<colgroup>
							<col width="40px" />
							<col width="40px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="150px" />
							<col width="100px" />
							<col width="100px" />
							<col width="100px" />
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rownum"></td>
								<td GCol="rowCheck,radio"></td>
								<td GCol="text,BOXNO" ></td>
								<td GCol="text,PTNRKY"></td>
								<td GCol="text,NAME01"></td>
								<td GCol="text,SKUKEY01"></td>
								<td GCol="text,DESC01"></td>
								<td GCol="text,QTY"></td>
								<td GCol="text,WRKDAT"></td>
							</tr>
						</tbody>
					</table>
				</div>
				</div>
				
				<div class="bottom">
					<input type="button" value="선택" class="bottom_bt" onclick="selectData()" />
				</div>
		</div>	
	</div>
</body>