<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String PHYIKY = request.getParameter("PHYIKY");
%>
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
	    	id : "gridList",
			editable : false,
			module : "Mobile",
			command : "MIP02",
			bindArea : "searchArea",
			gridMobileType : true
	    }); 
		
		searchList();
	});
	
	function searchList(){
		var param = new DataMap();
		param.put("PHYIKY", "<%=PHYIKY%>");
		param.put("WAREKY", "<%=wareky%>");
		
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });

		showMain();
	}
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if( gridId == "gridList" && dataLength < 1 ){
			location.href="/mobile/MIP02.page";
		}else{
			showMain();	
		}
	}
	
	function showMain() {
		$("#detailInfo").hide();
		$("#main").show();
		$("#PHYIKY").val("<%=PHYIKY%>");
	}
	
	function savaData(){
		if(gridList.validationCheck("gridList", "select")){
			var param = new DataMap();
			var list = gridList.getSelectData("gridList");
			param.put("list",list);
	
			if(list.length < 1){
				commonUtil.msgBox("VALID_M0006"); //선택한 데이터가 없습니다.
				return;
			}
			
			var json = netUtil.sendData({
				url:"/mobile/Mobile/json/SaveMIP02.data",
				param : param
			});
			
			if(json && json.data){
				commonUtil.msgBox("MASTER_M0564");
				
				searchList();
			}else{
				commonUtil.msgBox("VALID_M0002");
			}
		}
	}
 
 	function clearText(data){
		if(data!=null||data!=""){
	    	data.value="";
	    }      
	}
	
 	function showPre(){
 		location.href="/mobile/MIP02.page";
 	}
 	
 	function chkData(){
 		var phyiBarcd = $('#PHYIIT').val();

 		if(phyiBarcd == ""){
 			commonUtil.msgBox("VALID_M0936"); //바코드를 입력해주세요.
 			return;
 		}
 		
 		var phyikyVal;
 		var phyiitVal;
 		var compareVal;
 		
 		var rowCnt = gridList.getGridData("gridList");
 		for(var i = 0 ; i < rowCnt.length ; i ++){
 			phyikyVal = gridList.getColData("gridList", i, "PHYIKY");
 			phyiitVal = gridList.getColData("gridList", i, "PHYIIT");
 			compareVal = phyikyVal + phyiitVal;
 			
 			if(compareVal == phyiBarcd){
 				gridList.setRowCheck("gridList", i, true);
 			}
 		}
 	} 
</script>
</head>
<body>
	<div class="main_wrap" id="main">
	<div id="main_container">
		<div class="tem5_content">
			<div class="tableWrap_search section">
				<table class="util">
					<colgroup>
						<col width="100" />
					</colgroup>
					<tr >
						<th CL="EZG_PHYKKY">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:</th>
						<td>
							<input type="text" name="PHYIKY" id="PHYIKY" readonly="readonly" size="50px" />
						</td>
					</tr>
					<tr>
						<th CL='STD_IBARCD'>&nbsp;&nbsp;&nbsp;</th> <!-- 선택바코드  -->
						<td>
							<input type="text" class="text" id="PHYIIT" onfocus="clearText(this)" onkeypress="commonUtil.enterKeyCheck(event, 'chkData()')" style="height: 35px;"/>
						</td>
						<td rowspan="3">
							<input type="button" CL="STD_DISPLAY" class="bt" onclick="chkData()"/> <!-- value="선택" -->
						</td>
					</tr>
				</table>
				<div class="tableHeader">
					<table>
						<colgroup>
								<col width="35px" />
								<col width="30px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px" />
								<col width="100px" />
								<col width="100px"/>
								<col width="100px"/>
						</colgroup>
						<thead>
							<tr>
								<th>No.</th>
								<th GBtnCheck="true"></th>
								<th CL='STD_PHYIKY'></th> 
								<th CL='STD_PHYIIT'></th> 
								<th CL='STD_SKUKEY'></th>
								<th CL='STD_DESC01'></th>
								<th CL='STD_LOCAKY'></th>
								<th CL='STD_QTSIWH'></th>
								<th CL='STD_QTYPDA'></th>
								<th CL='STD_UOMKEY'></th>
								<th CL='STD_LOTA13'></th>
							</tr>
						</thead>
					</table>				
				</div>					
				<div class="tableBody">
					<table>
						<colgroup>
								<col width="35px" />
								<col width="30px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px" />
								<col width="100px" />
								<col width="100px"/>
								<col width="100px"/>
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rownum">1</td>
								<td GCol="rowCheck"></td>
								<td GCol="text,PHYIKY"></td>
								<td GCol="text,PHYIIT"></td>
								<td GCol="text,SKUKEY"></td>
								<td GCol="text,DESC01"></td>
								<td GCol="text,LOCAKY"></td>
								<td GCol="text,QTSIWH" GF="N"></td>					
								<td GCol="input,QTYPDA" GF="N 20"></td>
								<td GCol="text,UOMKEY"></td>
								<td GCol="text,LOTA13" GF="C"></td>
							</tr>
						</tbody>
					</table>
				</div>
				</div>
				<!-- end table_body -->
				<div class="footer_5">
					<table>
						<tr>
							<td onclick="showPre()"><label CL='STD_CDSCAN'></label></td>
							<td class=f_1 onclick ="savaData()"><label CL='BTN_SAVE'></label></td>
						</tr>
					</table>
				</div><!-- end footer_5 -->	
			</div>
	</div>
	</div>
</body>