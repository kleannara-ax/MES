<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<head>
<style type="text/css">
button {
	vertical-align: bottom;
    height: 37px;
}
</style>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>Smile Mobile WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script>
	//var chkFlag = true;
	var chkObjId = "";
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			editable : false,
			module : "WmsMobileInventoryDisplay",
			command : "PDST10",
			gridMobileType : true
	    });
		
		$("#LOCAKY").focus();
	});
	
	function searchList(){
		
		var locaky = $('#LOCAKY').val();
		var trnuid = $('#TRNUID').val();
		var barcod = $('#BARCOD').val();
		
		if(locaky == "" && trnuid == "" && barcod == ""){
			commonUtil.msgBox("MASTER_M0314");
			PlaySound('e');
			$("#LOCAKY").focus();
			return;
		}
		
		var param = inputList.setRangeParam("searchArea");
		param.put("SES_WAREKY", "<%=wareky%>");
		param.put("SES_OWNER", "<%=owner%>");
		
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
	}
	
	function gridListEventDataBindEnd(gridId, dataLength){
		var locaky = $('#LOCAKY').val();
		var trnuid = $('#TRNUID').val();
		var barcod = $('#BARCOD').val();
		if(gridId == "gridList" && dataLength > 0){
			PlaySound('s');
			if(chkObjId != ""){
				$('#'+chkObjId).focus();
				$('#'+chkObjId).select();
			}
		}else if(gridId == "gridList" && dataLength == 0){
			PlaySound('e');
			if(chkObjId != ""){
				$('#'+chkObjId).focus();
				$('#'+chkObjId).select();
			}
			return;
		}
	}
	
	function detail(){
		var fRow = gridList.getFocusRowNum("gridList");
		var row = gridList.getRowData("gridList", fRow);

		var rowCnt = gridList.getGridDataCount("gridList");
		
		if(rowCnt < 1){
			//commonUtil.msgBox("VALID_M0006");
			PlaySound('e');
			return;
		}else{
			mobile.linkPopOpen('/mobile/PDST10_POP.page',row);
		}
		
	}
	
	function clearText(data){
	    if(data!=null||data!=""){
	       data.value="";
	    }      
	 }
	
	function showMain() {
		window.top.menuOpen();
	}
	
	function gridListEventRowDblclick(gridId, rowNum, colName, colValue){
		var fRow = gridList.getFocusRowNum("gridList");
		var row = gridList.getRowData("gridList", fRow);

		mobile.linkPopOpen('/mobile/PDST10_POP.page',row);
	}
	
	function linkPopCloseEvent(){
		$("#ASNINV").focus();
	}
	
	function focusCheck(objId){
		if(objId != chkObjId){
			chkObjId = objId;
			$("#"+chkObjId).select();
			
			if(objId == "LOCAKY"){
				gridList.resetGrid("gridList");
				$("#TRNUID").val("");
				$("#BARCOD").val("");
			}
		}
	}
</script>
</head>
<body>
<div class="main_wrap" id="searchArea">
	<div id="main_container">
		<div class="tem4_content">
			<div class="select_box">
				<table>
					<colgroup>
						<col width="70px"  />
						<col />
						<col width="60px" />
						<col />
					</colgroup>
					<tbody>
						<tr>
							<th CL="STD_LOCAKY" width="100">로케이션</th>
							<td>
								<input type="text" class="text" name="LOCAKY" id="LOCAKY" onfocus="focusCheck(this.id)" onkeypress="commonUtil.enterKeyCheck(event, 'searchList()')" />
							</td>
						</tr>
						<tr>
							<th CL="STD_TRNUID">팔레트 ID</th>
							<td>
								<input type="text" class="text" name="TRNUID" id="TRNUID" onfocus="focusCheck(this.id)" onkeypress="commonUtil.enterKeyCheck(event, 'searchList()')" />
							</td>
						</tr>
						<tr>
							<th CL="STD_BARCOD">바코드</th>
							<td>
								<input type="text" class="text" name="BARCOD" id="BARCOD" onfocus="focusCheck(this.id)" onkeypress="commonUtil.enterKeyCheck(event, 'searchList()')" />
							</td>
						</tr>
					</tbody>
				</table>
				<div class="tableWrap_search section">
					<div class="tableHeader">
						<table style="width: 100%">
							<colgroup>
									<col width="30px" />
									<col width="90px" />
									<col width="90px" />
									<col width="90px" />
									<col width="70px" />
									<col width="140px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="90px" />
							</colgroup>
							<thead>
								<tr>
									<th CL='STD_NO'>No.</th>
									<th CL='STD_LOCAKY'></th>
									<th CL='STD_TRNUID'></th>
									<th CL='STD_BARCOD'></th>
									<th CL='STD_SKUKEY'></th>
									<th CL='STD_DESC01'></th>
									<th CL='STD_QTSAVLB'></th>
									<th CL='STD_QTALOC'></th>
									<th CL='STD_QTSPMO'></th>
									<th CL='STD_QTSPMI'></th>
									<th CL='STD_INSMK'></th>
								</tr>
							</thead>
						</table>				
					</div>					
					<div class="tableBody">
						<table style="width: 100%">
							<colgroup>
									<col width="30px" />
									<col width="90px" />
									<col width="90px" />
									<col width="90px" />
									<col width="70px" />
									<col width="140px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
									<col width="90px" />
							</colgroup>
							<tbody id="gridList">
								<tr CGRow="true">
									<td GCol="rownum">1</td>
									<td GCol="text,LOCAKY"></td>
									<td GCol="text,TRNUID"></td>
									<td GCol="text,EANCOD"></td>
									<td GCol="text,SKUKEY"></td>
									<td GCol="text,DESC01"></td>
									<td GCol="text,USEQTY" GF="N"></td>
									<td GCol="text,QTSALO" GF="N"></td>
									<td GCol="text,QTSPMO" GF="N"></td>
									<td GCol="text,QTSPMI" GF="N"></td>
									<td GCol="text,LOTA10"></td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
			</div>
		</div>
		
		<!-- end table_body -->
		<div class="footer_5">
			<table>
				<tr>
					<td class=f_1 onclick ="showMain()" width="33%"><label CL='BTN_CLOSE'></label></td>
					<td class=f_1 onclick ="detail()" width="33%"><label CL='STD_DISDTL'></label></td>
				</tr>
			</table>
		</div><!-- end footer_5 -->	
	</div>
	</div>
	</div>
</body>