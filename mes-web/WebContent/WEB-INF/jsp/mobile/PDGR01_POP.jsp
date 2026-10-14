<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String asninv = request.getParameter("ASNINV");
	String asndit = request.getParameter("ASNDIT");
	String locaky = request.getParameter("LOCAKY");
	String skukey = request.getParameter("SKUKEY");
	String asntty = request.getParameter("ASNTTY");
	String lota11 = request.getParameter("LOTA11");
	String lota13 = request.getParameter("LOTA13");
	String rcvlmt = request.getParameter("RCVLMT");
	String qtable = request.getParameter("QTABLE");
%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script>
	var data = new DataMap();
	
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			editable : false,
			module : "WmsMobileInboundGoodsReceipt",
			command : "PDGR01_POP",
			bindArea : "main",
			gridMobileType : true
	    });
		
		data.put("ASNINV", "<%=asninv%>");
		data.put("ASNDIT", "<%=asndit%>");
		data.put("LOCAKY", "<%=locaky%>");
		data.put("SKUKEY", "<%=skukey%>");
		data.put("ASNTTY", "051");
		
		
		searchList();
	});
	
	function searchList(){
		data.put("SES_WAREKY", "<%=wareky%>");
		data.put("SES_OWNER", "<%=ownrky%>");
		
		gridList.gridList({
	    	id : "gridList",
	    	param : data
	    });
	}
	
 	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
 		var today = new Date();
		var year = today.getFullYear();
	    var month = today.getMonth()+1;
	    var date = today.getDate();
	    if(month < 10){
	    	month = "0" + month;
	    }
	    if(date < 10){
	    	date = "0" + date;
	    }
		var sysdate = year+month+date;
		
 		if(gridId == "gridList" && colName == "LOTA11"&& colValue.trim() != ""){
 			var lota11 = gridList.getColData(gridId, rowNum, "LOTA11");
 			
	 	 	if(lota11 != ""){
				//제조일자 validation
				if(lota11 > sysdate){
					commonUtil.msgBox("VALID_M1607");	//제조일자는 오늘/과거일자만 입력 가능합니다.
					gridList.setColValue("gridList", rowNum, "LOTA11", " ");
					gridList.setColFocus("gridList", rowNum, "LOTA11");
					return;
				}
 			}
		}else if(gridId == "gridList" && colName == "LOTA13"&& colValue.trim() != ""){
			var lota13 = gridList.getColData(gridId, rowNum, "LOTA13");
	 	 	
	 	 	if(lota13 != ""){	
				//유통기한 validation
				if(lota13 <= sysdate){
					commonUtil.msgBox("VALID_M1606");	//유통기한은 미래일자만 입력 가능합니다.
					gridList.setColValue("gridList", rowNum, "LOTA13", " ");
					gridList.setColFocus("gridList", rowNum, "LOTA13");
					return;
				}
			}
		}
	}
 	
 	function gridListEventDataBindEnd(gridId, dataLength, excelLoadType){
	 	if(gridId == "gridList" && dataLength > 0){
	 		PlaySound('s');
			
		 		gridList.setColValue(gridId, 0, "LOTA11", "<%= lota11%>");
		 		gridList.setColValue(gridId, 0, "LOTA13", "<%= lota13%>");
		 		gridList.setColValue(gridId, 0, "RCVLMT", "<%= rcvlmt%>");
	 		
	 		gridList.setColFocus("gridList", 0, "TRNUID");
	 	}else{
	 		PlaySound('e');
	 		
			location.href="/mobile/PDGR01.page?FLAG=N";	
	 	}
	}
 	
 	function addRow(){
 		if(!commonUtil.msgConfirm("INV_M0725")){	//팔레트를 추가하시겠습니까?
			return;
		}else{
			var fRow = gridList.getFocusRowNum("gridList");

			gridList.addNewRow("gridList","");
			gridList.setColFocus("gridList", fRow, "TRNUID");
		}
 	}
 	
 	function removeRow(){
 		if(!commonUtil.msgConfirm("INV_M0726")){   //팔레트를 삭제하시겠습니까?
			return;
		}else{
			var fRow = gridList.getFocusRowNum("gridList");
			gridList.removeRow("gridList", fRow, false);
		}
 	}
 	
	function gridListEventRowAddBefore(gridId, rowNum, beforeData){
		var beforeRow = gridList.getRowData(gridId, rowNum-1);
		
		return beforeRow;
	}
 	
	function saveData(){
		if(gridList.validationCheck("gridList", "data")){
			if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
				return;
			}
			
			var param = inputList.setRangeParam("main");
			var list = gridList.getGridData("gridList");
			param.put("list", list);
			
			var sumQty = 0;
			var qtyasn = "<%= qtable%>";
			
		 	if(sumQty > qtyasn){
				commonUtil.msgBox("VALID_M1722");	//"PDA로 초과입고 할 수 없습니다.
				return;
			} 
			
			param.put("ASNTTY", "112");
			param.put("SUMQTY", sumQty);
			var json = netUtil.sendData({
				url : "/mobile/mobileInboundGoodsReceipt/json/SavePDGR01_POP.data",
				param : param
			});
			
		    if(json.data.length > 5 && json.data.length != 10){
		    	PlaySound('e');
		    	
				var msgList = json.data.split("†");
				var msgTxt = commonUtil.getMsg(msgList[0], (msgList.length > 1 ? msgList[1].split("/") : null));
				commonUtil.msg(msgTxt);
				return;
			} 
			
			if(json && json.data){
				PlaySound('s');
				
				commonUtil.msgBox("MASTER_M0564"); //저장완료

				if(data){
					var asntty = $('#ASNTTY').val();
					var asndky = $('#ASNINV').val();
					var skukey = $('#SKUKEY').val();
					
						location.href="/mobile/PDGR01.page?FLAG=Y&ASNDKY="+asndky+"&ASNTTY="+asntty+"&SKUKEY="+skukey;	
				}else{
					resetData();
					$("#ASNINV").focus();
				}
			}else{
				PlaySound('e');
			}
			resetData();
		}
	}
	
 	function showMain() {
		$("#detailInfo").hide();
		$("#main").show();
	}
	
 	function clearText(data){
		if(data!=null||data!=""){
	    	data.value="";
	    }      
	}
	
 	function closePop(){
 		var asntty = $('#ASNTTY').val();
 		
		location.href="/mobile/PDGR01.page?FLAG=N";
 	}
 	
 	
</script>
</head>
<body>
	<div id="menu-container">
		<div class="menu-item"></div><!-- 입고확정 팔레트 분할 -->
	</div>
	<div class="main_wrap" id="main">
	<div id="main_container">
		<div class="tem4_content">
			<div class="select_box">
				<table>
					<colgroup>
						<col width="70px" />
						<col />
						<col width="70px" />
					</colgroup>
					<tr>
						<th CL='STD_ASN'>ASN</th> 
						<td colspan="2">
							<input type="text" class="text" name="ASNINV" id="ASNINV" readonly="readonly"/>
						</td colspan="2">
						<th>
							<%if(langky.equals("KR")){%>ASN<br>타입<%}%>
							<%if(langky.equals("EN")){%>ASN<br>type<%}%>
						</th> 
						<td>
							<input type="text" class="text" name="ASNTTY" id="ASNTTY" readonly="readonly" style="width: 200%;"/>
							<input type="hidden" name="PTNRKY" id="PTNRKY" />
						</td>
					</tr>
					<tr>
						<th CL='STD_SKUKEY'>품번</th> 
						<td colspan="2">
							<input type="text" class="text" name="SKUKEY" id="SKUKEY" readonly="readonly"/>
						</td>
						<th CL='STD_UOMKEY'>단위</th> 
						<td colspan="2">
							<input type="text" class="text" name="UOMKEY" id="UOMKEY" readonly="readonly"/>
						</td>
					</tr>
					<tr>
						<th CL='STD_DESC01'>품명</th> 
						<td colspan="5">
							<input type="text" class="text" name="DESC01" id="DESC01" readonly="readonly"/>
						</td>
					</tr>
					<tr>
						<th CL='STD_QTYORG2'>예정수량</th> 
						<td>
							<input type="text" class="text" name="QTYASN" id="QTYASN" UIFormat="N 10" readonly="readonly" style="width: 98%"/>
						</td>
						<th>
							<%if(langky.equals("KR")){%>기확정<br>수량<%}%>
							<%if(langky.equals("EN")){%>Confirm<br>Quantity<%}%>
						</th> 
						<td>
							<input type="text" class="text" name="QTYRCV1" id="QTYRCV1" UIFormat="N 10" readonly="readonly"/>
						</td>
						<th>
							<%if(langky.equals("KR")){%>남은<br>수량<%}%>
							<%if(langky.equals("EN")){%>Quantity<br>Remain<%}%>
						</th>
						<td>
							<input type="text" class="text" name="QTABLE" id="QTABLE" UIFormat="N 10" readonly="readonly" />
						</td>
					</tr>
				</table>
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
									<col width="100px" style="display: none;" />
									<col width="100px" style="display: none;" />
									<col width="100px" style="display: none;" />
									<col width="100px" style="display: none;" />
									<col width="100px" style="display: none;" />
									<col width="100px" style="display: none;" />
							</colgroup>
							<thead>
								<tr>
									<th CL='STD_NO'>No.</th>
									<th CL='STD_SKUKEY'>품번</th>
									<th CL='STD_TRNUID'>파렛트 바코드</th>
									<th CL='STD_QTYRCV'>입고수량</th>
									<th CL='STD_LOTA11'>제조일자</th>
									<th CL='STD_LOTA13'>유통기한</th>
									<th CL='STD_PTNRKY' style="display: none;"></th>
									<th CL='STD_RCVLMT' style="display: none;"></th>
									<th CL='STD_LOTA12' style="display: none;"></th>
									<th CL='STD_QTYMON' style="display: none;"></th>
									<th CL='STD_QTYSTD' style="display: none;"></th>
									<th CL='STD_ASKU01' style="display: none;"></th>
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
									<col width="100px" style="display: none;" />
									<col width="100px" style="display: none;" />
									<col width="100px" style="display: none;" />
									<col width="100px" style="display: none;" />
									<col width="100px" style="display: none;" />
									<col width="100px" style="display: none;" />
							</colgroup>
							<tbody id="gridList">
								<tr CGRow="true">
									<td GCol="rownum">1</td>
									<td GCol="text,SKUKEY">품번</td>
									<td GCol="input,TRNUID" validate="required,MASTER_M1128">파렛트 바코드</td>
									<td GCol="input,QTYRCV" GF="N 10">입고수량</td>
									<td GCol="input,LOTA11" GF="D 8">제조일자</td>
									<td GCol="input,LOTA13" GF="D 8">유통기한</td>
									<td GCol="text,PTNRKY" style="display: none;"></td>
									<td GCol="text,RCVLMT" GF="D" style="display: none;"></td>
									<td GCol="text,LOTA12" GF="D" style="display: none;"></td>
									<td GCol="text,EXPIRED_LIMIT" GF="N" style="display: none;"></td>
									<td GCol="text,WARNING_LIMIT" GF="N" style="display: none;"></td>
									<td GCol="text,ASKU01" GF="N" style="display: none;"></td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
				<!-- end table_body -->
				<div class="footer_5" style="position:fixed;">
					<table>
						<tr>
							<td class=f_1 onclick="removeRow()" style="width: 25%;"><label CL='BTN_REMOVE'></label></td>
							<td class=f_1 onclick="closePop()" style="width: 25%;"><label CL='BTN_CLOSE'></label></td>
							<td class=f_1 onclick="saveData()" style="width: 25%;"><label CL='BTN_SAVE'></label></td>
							<td class=f_1 onclick="addRow()" style="width: 25%;"><label CL='BTN_ADDROW'></label></td>
						</tr>
					</table>
				</div><!-- end footer_5 -->	
			</div>
	</div>
	</div>
</body>