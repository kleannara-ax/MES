<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>IMV Mobile WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script type="text/javascript">

	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			editable : false,
			module : "Mobile",
			command : "MGR01SEARCH",
			gridMobileType : true
	    });

		var data = mobile.getLinkPopData();
		$("[name=COLTEXT]").val(data);
		
		var $obj = $("[name=COLTEXT]");
		
		if($obj.val() != ""){
			searchList();
		}else{
			$obj.focus();
		}
	});
	
	function searchList(){
		var param = dataBind.paramData("searchArea");
		var $obj = $("[name=COLTEXT]");
	
		if($obj.val() == ""){
			commonUtil.msgBox("IN_M0010"); //구매오더 번호를 입력해 주세요.
			$obj.focus();
			return;
		}
		
		param.put("WAREKY","<%=wareky%>");
	
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
	}

	function selectData(){
		var rowNum = gridList.getSelectIndex("gridList");
		var rowData = gridList.getRowData("gridList", rowNum);
		mobile.linkPopClose(rowData);
	}	

	function clearText(data){
		if(data!=null||data!=""){
	    	data.value="";
	    }      
	}
	
	function closePop(){
		mobile.linkPopClose(0);
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
									<select name="COLNAME">
										<option value="SEBELN">Purchase Order Number</option>
									</select>
								</td>
								<td rowspan="2">
									<a href="#"><input type="button" CL="BTN_DISPLAY" class="bt" onclick='searchList()'/></a>
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
					<table style="width: 100%">
						<colgroup>
							<col width="30px" />
							<col width="30px" />
							<col width="80px" />
							<col width="80px" />
							<col width="150px" />
							<col width="100px" />
							<col width="100px"/>
							<col width="100px"/>
						</colgroup>
						<thead>
							<tr class="thead">
								<th CL='STD_NUMBER'>번호</th>
								<th> </th>
								<th CL='STD_EBELN'>오더번호</th>
								<th CL='STD_RCVDAT'>입고예정일자</th>
								<th CL='STD_AREAKY'>창고</th>
								<th CL='STD_AREANM'>창고명</th>
								<th CL='STD_SKUCNT'>상품수</th>
								<th CL='STD_DOCTXT'>비고</th>
							</tr>
						</thead>
					</table>				
				</div>
				<div class="tableBody">
					<table style="width: 100%">
						<colgroup>
							<col width="30px" />
							<col width="30px" />
							<col width="80px" />
							<col width="80px" />
							<col width="150px" />
							<col width="100px" />
							<col width="100px"/>
							<col width="100px"/>
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rownum"></td>
								<td GCol="rowCheck,radio"></td>
								<td GCol="text,SEBELN" ></td>
								<td GCol="text,ASNDAT"></td>
								<td GCol="text,AREAKY"></td>
								<td GCol="text,AREANM"></td>
								<td GCol="text,SKUCNT"></td>
								<td GCol="text,DOCTXT"></td>
							</tr>
						</tbody>
					</table>
				</div>
				</div>
				
				<div class="bottom">
					<input type="button" CL='STD_CDSCAN' class="bottom_bt2" onclick="closePop()" />
					<input type="button" CL='BTN_APPLYB' class="bottom_bt2" onclick="selectData()" />
				</div>
		</div>	
	</div>
</body>