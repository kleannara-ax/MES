<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.common.bean.*,com.common.util.*,com.common.bean.CommonConfig,java.util.*"%>
<%
	User user = (User)request.getSession().getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>IMV Mobile WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<style>
	.tem5_content .bt {
	    width: 55px;
	    height: 24px;
	    vertical-align: middle;
        line-height: 12px;
   		font-size: 13.5px;
	}
	
	.search select {
		height:24px;
	}
</style>
<script>
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
	    	name : "gridList",
			editable : false,
			module : "Mobile",
			command : "MOM01",
			gridMobileType : true
	    });
		
		// 출고요청일 당일 설정
		var now = new Date();
		now.setDate(now.getDate());
		var tmpValue = uiList.dateFormat(now, site.COMMON_DATE_TYPE);
		$("#MOM01TOP").find("[name=RQSHPD]").val(tmpValue).trigger("change");
		
		$("#AREAKY").val("<%=user.getUserg5()%>");
	 	$("#rsncodCombo").val("001");
		$("#tasrsn").val("");
		
		searchList();
	});
	
	function searchList(){
		var param = inputList.setRangeParam("MOM01TOP");

		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
		
		var $obj = $("#MOM01TOP");
		$('select[name="AREAKY"]').attr("disabled",false);
		$('select[name="SRQTYP"]').attr("disabled",false);
		$obj.find("[name=STDLNR]").attr("readonly",false);
		$obj.find("[name=WORKID]").attr("readonly",false);
		$obj.find("[name=C00101]").attr("readonly",false);
		gridList.setReadOnly("gridList", false);
		gridList.setReadOnly("gridList", true, ['ASKU05']);
	}
	
	function changeArea(){
		var $obj = $("#MOM01TOP");
		$obj.find("[name=STDLNR]").val("");
		$obj.find("[name=WORKID]").val("");
		$obj.find("[name=C00101]").val("");
		$obj.find("[name=SRQTYP]").val("1");
		
		searchList();
	}
	
	function changeSrqtyp(){
		var $obj = $("#MOM01TOP");
		$obj.find("[name=STDLNR]").val("");
		$obj.find("[name=WORKID]").val("");
		$obj.find("[name=C00101]").val("");
		
		searchList();
	}
	
	function setRsncod(){
		var rsncodCombo = $("#rsncodCombo").val();
		var selectNumList = gridList.getSelectRowNumList("gridList");
		
		if(selectNumList.length < 1){
			commonUtil.msgBox("VALID_M1501"); //"사유코드를 적용할 레코드를 선택해주세요"
		}
		
		if(rsncodCombo){
			for(var i=0;i<selectNumList.length;i++){
				var rowNum = selectNumList[i];
				gridList.setColValue("gridList", rowNum, "RSNCOD", rsncodCombo);
			}
			gridList.setColFocus("gridList", rowNum, "RSNCOD");
		}
	}
		
	function setTasrsn(){
		var tasrsn = $("#tasrsn").val();
		var selectNumList = gridList.getSelectRowNumList("gridList");
		
		if(selectNumList.length < 1){
			commonUtil.msgBox("VALID_M1570"); //"상세사유를 적용할 레코드를 선택해주세요"
		}
		
		if(tasrsn){
			for(var i=0;i<selectNumList.length;i++){
				var rowNum = selectNumList[i];
				gridList.setColValue("gridList", rowNum, "TASRSN", tasrsn);
			}
			gridList.setColFocus("gridList", rowNum, "TASRSN");
		}
	}
	
	function setLota02(){
		var lota02 = $("#lota02").val();
		var selectNumList = gridList.getSelectRowNumList("gridList");
		
		if(selectNumList.length < 1){
			commonUtil.msgBox("VALID_M1614"); //"코스트센터를 적용할 레코드를 선택해주세요"
		}
		
		if(lota02){
			for(var i=0;i<selectNumList.length;i++){
				var rowNum = selectNumList[i];
				gridList.setColValue("gridList", rowNum, "COSTCT", lota02);
			}
			gridList.setColFocus("gridList", rowNum, "COSTCT");
		}
	}
	
	function clearData(){
		if(!commonUtil.msgConfirm("VALID_M0011")){
			return;
		}
		
		var $obj = $("#MOM01TOP");
		$obj.find("[name=AREAKY]").val("");
		$obj.find("[name=STDLNR]").val("");
		$obj.find("[name=WORKID]").val("");
		$obj.find("[name=C00101]").val("");
		$obj.find("[name=SRQTYP]").val("1");
		$("#AREAKY").val("<%=user.getUserg5()%>");
		$("#rsncodCombo").val("001");
		$("#tasrsn").val("");
		
		searchList();
	}
	
	function showMain() {
		$("#main").show();
	}
 
 	function clearText(data){
		if(data!=null||data!=""){
	    	data.value="";
	    }      
	}
 	
	function getSku(){
		var param = inputList.setRangeParam("MOM01TOP");
		param.put("OWNRKY", "<%=ownrky%>");
		param.put("WAREKY", "<%=wareky%>");
		param.put("AREAKY", $("#AREAKY").val());
		param.put("USERID", "<%=user.getUserid()%>");
	 	
 		gridList.gridList({
	    	id : "gridList",
	    	param : param,
	    	module : "Mobile",
	    	command : "GETSKU"
 	    });  
	}
	
	function saveData(){
		if(validate.check("MOM01TOP") && gridList.validationCheck("gridList", "select")){
			var list = gridList.getSelectData("gridList");
			
			if(list.length == 0){
				commonUtil.msgBox("VALID_M0006");
				return;
			}
			
			var SRQTYP = $("#MOM01TOP").find("[name=SRQTYP]").val();
			if(SRQTYP != "2"){
		        var skukey, desc01, qtyord, uomkey, qtsiwh, qtttwh, row;
		        for(var i = 0; i < list.length; i++){
		        	row = list[i];
		        	skukey = row.get("SKUKEY");
		        	desc01 = row.get("DESC01");
		        	qtyord = parseFloat(row.get("QTYORD"));
		        	qtsiwh = parseFloat(row.get("QTSIWH"));
		        	qtttwh = parseFloat(row.get("QTTTWH"));
		        	
		        	
		        	if(qtyord > qtsiwh + qtttwh){
		        		var msgKey = "ORDER_M0002";
		        		var msgParams = [skukey, desc01, qtsiwh, qtttwh, qtsiwh+qtttwh, qtyord];
		        		commonUtil.msg(commonUtil.getMsg(msgKey, msgParams));
		        		return;
		        	}
		        }
	        }
			
			for(var i = 0; i < list.length; i++){
				var row = list[i];
				
				// 2016.10.17 skukey 최소량, 증가량, 최대량 check
				var qtyord = $.trim(row.get("QTYORD"));
				if(qtyord == "" || qtyord == "0"){
					commonUtil.msgBox("VALID_M1616");
					gridList.setColFocus("gridList", row.get("GRowNum"), "QTYORD");
					return;
				} else {
					var flag = setQtyord("gridList", row.get("GRowNum"), "QTYORD", parseFloat(qtyord));
					if(!flag){
						return;
					}
				}
				
				// 2016.10.24 코스트센터 validation check
				var costct = $.trim(row.get("COSTCT"));
				if(costct == ""){
					commonUtil.msgBox("VALID_M1624"); // 코스트센터를 선택해주세요.
					gridList.setColFocus("gridList", row.get("GRowNum"), "COSTCT");
					return;
				}
			}
			
			if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
				return;
			}
			
			var param = inputList.setRangeParam("MOM01TOP");
			
			var rqshpd = param.get("RQSHPD");
			if(rqshpd.indexOf(".") > -1){
				rqshpd = rqshpd.replace(/[^0-9]/gi, "");
				param.put("RQSHPD", rqshpd);
			}
			
			param.put("list", list);
			
			var json = netUtil.sendData({
				url : "/wms/order/json/saveOM01.data",
				param : param
			});
			
			if(json && json.data){
				commonUtil.msgBox("MASTER_M0564");
				
				/* var $obj = $("#MOM01TOP");
				$('select[name="AREAKY"]').attr("disabled",true);
				$('select[name="SRQTYP"]').attr("disabled",true);
				$obj.find("[name=STDLNR]").attr("readonly",true);
				$obj.find("[name=WORKID]").attr("readonly",true);
				$obj.find("[name=C00101]").attr("readonly",true);
				gridList.setReadOnly("gridList", true); */
				
				var $obj = $("#MOM01TOP");
				$obj.find("[name=AREAKY]").val("");
				$obj.find("[name=STDLNR]").val("");
				$obj.find("[name=WORKID]").val("");
				$obj.find("[name=C00101]").val("");
				$obj.find("[name=SRQTYP]").val("1");
				$("#AREAKY").val("<%=user.getUserg5()%>");
				$("#rsncodCombo").val("001");
				$("#tasrsn").val("");
				
				searchList();
			}
		}
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue) {
 		if (gridId == "gridList") {
 			if (colName == "INPUTSKU") {
 				if(colValue != ""){
 					if($("#MOM01TOP").find("[name=AREAKY]").val() == ""){
 						commonUtil.msgBox("MASTER_M0254");
 						gridList.setColValue("gridList", rowNum, "INPUTSKU", "");
 						$("#MOM01TOP").find("[name=AREAKY]").focus();
 					}else{
	 					var param = inputList.setRangeParam("MOM01TOP");
						param.put("INPUTSKU", colValue);
						param.put("OWNRKY", "<%=ownrky%>");
						param.put("WAREKY", "<%=wareky%>");
	
						var json = netUtil.sendData({
							module : "WmsOrder",
							command : "SKUKEYval",
							sendType : "map",
							param : param
						});
						
						if(json.data["CNT"] >= 2) {
							commonUtil.msgBox("VALID_M1574");
							gridList.setColValue("gridList", rowNum, "SKUKEY", "");
							gridList.setColValue("gridList", rowNum, "DESC01", "");
							gridList.setColValue("gridList", rowNum, "DESC02", "");
							gridList.setColValue("gridList", rowNum, "SKUG05", "");
							gridList.setColValue("gridList", rowNum, "UOMKEY", "");
							gridList.setColValue("gridList", rowNum, "QTSIWH", "");
							gridList.setColValue("gridList", rowNum, "QTTTWH", "");
							gridList.setColValue("gridList", rowNum, "QTYORD", "");
							gridList.setColValue("gridList", rowNum, "MATNR", "");
							gridList.setColValue("gridList", rowNum, "ASKU05", "");
							gridList.setRowCheck("gridList", rowNum, false);
							return false;
						}
							
						var json = netUtil.sendData({
							module : "WmsOrder",
							command : "OM01SKUKEY",
							sendType : "map",
							param : param
						});
							
						if(json.data != null){
							gridList.setColValue("gridList", rowNum, "SKUKEY", json.data["SKUKEY"]);
							gridList.setColValue("gridList", rowNum, "MATNR", json.data["MATNR"]);
							gridList.setColValue("gridList", rowNum, "ASKU05", json.data["ASKU05"]);
							gridList.setColValue("gridList", rowNum, "DESC01", json.data["DESC01"]);
							gridList.setColValue("gridList", rowNum, "DESC02", json.data["DESC02"]);
							gridList.setColValue("gridList", rowNum, "SKUG05", json.data["SKUG05"]);
							gridList.setColValue("gridList", rowNum, "UOMKEY", json.data["UOMKEY"]);
							gridList.setColValue("gridList", rowNum, "QTSIWH", json.data["QTSIWH"]);
							gridList.setColValue("gridList", rowNum, "QTTTWH", json.data["QTTTWH"]);
							gridList.setColValue("gridList", rowNum, "TEXT", "");
							gridList.setRowCheck("gridList", rowNum, true);
						}else if(json.data == null){
							gridList.setColValue("gridList", rowNum, "SKUKEY", "");
							gridList.setColValue("gridList", rowNum, "DESC01", "");
							gridList.setColValue("gridList", rowNum, "DESC02", "");
							gridList.setColValue("gridList", rowNum, "SKUG05", "");
							gridList.setColValue("gridList", rowNum, "UOMKEY", "");
							gridList.setColValue("gridList", rowNum, "QTSIWH", "");
							gridList.setColValue("gridList", rowNum, "QTTTWH", "");
							gridList.setColValue("gridList", rowNum, "QTYORD", "");
							gridList.setColValue("gridList", rowNum, "MATNR", "");
							gridList.setColValue("gridList", rowNum, "ASKU05", "");
							gridList.setColValue("gridList", rowNum, "TEXT",  "Not Exist IMV Item Code");
							gridList.setRowCheck("gridList", rowNum, false);
						}
						
						var SRQTYP = $("#MOM01TOP").find("[name=SRQTYP]").val();
						if(SRQTYP == "4"){
							var json = netUtil.sendData({
								module : "WmsOrder",
								command : "OM01SKUKEY2",
								sendType : "map",
								param : param
							});
							
							if(json && json.data){
								null;
							}else{
								commonUtil.msgBox("VALID_M1564", colValue); //특수교환 상품이 아닙니다.
								gridList.setColValue("gridList", rowNum, "INPUTSKU", "");
								gridList.setColValue("gridList", rowNum, "SKUKEY", "");
								gridList.setColValue("gridList", rowNum, "DESC01", "");
								gridList.setColValue("gridList", rowNum, "DESC02", "");
								gridList.setColValue("gridList", rowNum, "SKUG05", "");
								gridList.setColValue("gridList", rowNum, "UOMKEY", "");
								gridList.setColValue("gridList", rowNum, "QTSIWH", "");
								gridList.setColValue("gridList", rowNum, "QTTTWH", "");
								gridList.setColValue("gridList", rowNum, "QTYORD", "");
								gridList.setColValue("gridList", rowNum, "MATNR",  "");
								gridList.setColValue("gridList", rowNum, "ASKU05",  "");
								gridList.setColValue("gridList", rowNum, "TEXT",   "");
								gridList.setRowCheck("gridList", rowNum, false);
							}
						}
 					}
 				}else{//값이 지워졌을 떄
					gridList.setColValue("gridList", rowNum, "SKUKEY", "");
					gridList.setColValue("gridList", rowNum, "MATNR",   "");
					gridList.setColValue("gridList", rowNum, "DESC01", "");
					gridList.setColValue("gridList", rowNum, "DESC02", "");
					gridList.setColValue("gridList", rowNum, "SKUG05", "");
					gridList.setColValue("gridList", rowNum, "UOMKEY", "");
					gridList.setColValue("gridList", rowNum, "QTSIWH", "");
					gridList.setColValue("gridList", rowNum, "QTTTWH", "");
					gridList.setColValue("gridList", rowNum, "QTYORD", "");
					gridList.setColValue("gridList", rowNum, "ASKU05",   "");
					gridList.setColValue("gridList", rowNum, "TEXT",   "");
					gridList.setRowCheck("gridList", rowNum, false);
				}
 			} else if(colName == "QTYORD"){
 				if(colValue != ""){
 					var qtyord = parseFloat(colValue);
 					
 					if(qtyord < 0){
 						commonUtil.msgBox("VALID_M1616");
						gridList.setColFocus(gridId, rowNum, colName);
						return;
 					} else {
 						var flag = setQtyord(gridId, rowNum, colName, qtyord);
 						if(!flag){
 							return;
 						}
 					}
 				}
 			}
 		}
	}
	
	function setQtyord(gridId, rowNum, colName, qtyord){
		var flag = true;
		
		var param = new DataMap();
		var skukey = gridList.getColData(gridId, rowNum, "INPUTSKU");
		param.put("OWNRKY", "<%=ownrky%>");
		param.put("SKUKEY", skukey);
		
		var json = netUtil.sendData({
			module : "WmsAdmin",
			command : "SKUUT",
			sendType : "map",
			param : param
		});
		
		if(json && json.data){
			var min = parseFloat(json.data["QTYMIN"]);
			var inc = parseFloat(json.data["QTYINC"]);
			var max = parseFloat(json.data["QTYMAX"]);
			
			// 최소
			if(min > qtyord){
				commonUtil.msgBox("VALID_M1620", min); // {0} 이상의 값으로 입력하여 주시기 바랍니다.
				gridList.setColValue(gridId, rowNum, colName, min);
				gridList.setColFocus(gridId, rowNum, colName);
				flag = false;
				return flag;
			}
			
			// 최대
			if(max < qtyord){
				commonUtil.msgBox("VALID_M1621", max); // {0} 이하의 값으로 입력하여 주시기 바랍니다.
				gridList.setColValue(gridId, rowNum, colName, max);
				gridList.setColFocus(gridId, rowNum, colName);
				flag = false;
				return flag;
			}
			
			// 증가
			var mod = qtyord % inc;
			if(mod != 0){
				var arr = new Array();
				arr.push(skukey);
				arr.push(inc);
				commonUtil.msgBox("VALID_M1622", arr); // 품목코드 [{0}]의 주문수량은 {1}의 배수로 입력하시기 바랍니다.
				gridList.setColFocus(gridId, rowNum, colName);
				flag = false;
				return flag;
			}
			
			flag = true;
		}
		
		return flag;
	}
	
	var focusRowNum = 0;
	function gridListEventRowDblclick(gridId, rowNum, colName, colValue){
		if(gridId == "gridList"){
			if(colName == "INPUTSKU"){
				if(colValue != ""){
					var rowData = gridList.getRowData(gridId, rowNum);
					
					focusRowNum = rowData.get("GRowNum");
					
					dataBind.paramData("searchArea", rowData);
					mobile.linkPopOpen("/mobile/MOM01_search.page", rowData);
				}
			} else if(colName == "rownum"){
				var newData = new DataMap();
				var ownrnm = gridList.getColData("gridList", 0, "OWNRNM");
				newData.put("OWNRKY", "<%=ownrky%>");
				newData.put("OWNRNM", ownrnm);
				
				gridList.setAddRow(gridId, newData);
			}
		}
	}
	
	function linkPopCloseEvent(data){
		var SKUKEY = data.get("SKUKEY");
		gridList.setColValue("gridList", focusRowNum, "INPUTSKU", SKUKEY);
	}
	
	function gridListEventRowAddBefore(gridId, rowNum){
		if(gridId == "gridList"){
			var newData = new DataMap();
			var ownrnm = gridList.getColData("gridList", 0, "OWNRNM");
			newData.put("OWNRKY", "<%=ownrky%>");
			newData.put("OWNRNM", ownrnm);
			return newData;
		}
	}
</script>
</head>
<body>
	<div class="main_wrap" id="main">
		<div id="main_container">
			<div class="tem5_content">
				<table class="util search" id="MOM01TOP" style="margin:15px 0; width:100%;">
					<colgroup>
						<col width="100" />
					</colgroup>
					<input type="hidden" name="SHPOKY" />
					<input type="hidden" name="RQSHPD" />
					<input type="hidden" name="WAREKY" value="<%=wareky%>" />
					<input type="hidden" name="OWNRKY" value="<%=ownrky%>" />
					<tr>
						<th CL="STD_AREAKY,3">출고요청창고</th>
						<td GCol="select,AREAKY">
							<select Combo="WmsOrder,AREAKYCOMBO" onchange="changeArea();" name="AREAKY" id="AREAKY" validate="required"></select>
							<input type="button" class="bt" onclick="getSku()" CL="BTN_GETSKU" style="width:160px;" />
						</td>
					</tr>
					<tr>
						<th CL="STD_SRQTYP">요청구분</th>
						<td GCol="select,SRQTYP">
							<select Combo="WmsOrder,OM01COMBO" onchange="changeSrqtyp();" name="SRQTYP" validate="required"></select>
						</td>
					</tr>
					<tr>
						<th CL="EZG_REQUSR">요청자</th>
						<td>
							<input type="text" class="text" name="STDLNR" validate="required" />
						</td>
					</tr>
					<tr>
						<th CL="STD_EMPLID2">사원ID</th>
						<td>
							<input type="text" class="text" name="WORKID" validate="required" />
						</td>
					</tr>
					<tr>
						<th CL="STD_TEAMLD">팀리더</th>
						<td>
							<input type="text" class="text" name="C00101" validate="required" />
						</td>
					</tr>
					<tr>
						<th CL="STD_RSNCOD"></th>
						<td>
							<select ReasonCombo="380" id="rsncodCombo"></select>
							<input type="button" class="bt" onclick="setRsncod()" CL="BTN_REFLECT" />
						</td>
					</tr>
					<tr>
						<th CL="STD_TASRSN"></th>
						<td>
							<input type="text" class="text" name="tasrsn" id="tasrsn" />
							<input type="button" class="bt" onclick="setTasrsn()" CL="BTN_REFLECT" />
						</td>
					</tr>
					<tr>
						<th CL="EZG_LOTA02"></th>
						<td>
							<select Combo="WmsOrder,COSTCTCOMBO" id="lota02" style="width:200px;"></select>
							<input type="button" class="bt" onclick="setLota02()" CL="BTN_REFLECT" />
						</td>
					</tr>
				</table>
				<div class="tableWrap_search section">
					<div class="tableHeader" style="display:table;">
						<table style="width:100%;">
							<colgroup>
								<col width="30" />
								<col width="30" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
								<col width="60" />
								<col width="60" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
							</colgroup>
							<thead>
								<tr>
									<th CL='STD_NUMBER'></th>
									<th GBtnCheck="true"></th>
									<th CL='STD_SearchCode,2'></th>
									<th CL='STD_DESC01'></th>
									<th CL='STD_SKUG05'></th>
									<th CL='STD_BDMNG,3'></th>
									<th CL='STD_QTTTTWH'></th>
									<th CL='STD_QTSCNT'></th>
									<th CL='EZG_LOTA02'></th>
									<th CL='STD_DOCTXT'></th>
									<th CL='STD_RSNCOD'></th>
									<th CL='STD_TASRSN'></th>
									<th CL='STD_SearchCode,3'></th>
									<th CL='STD_MATNR,3'></th>
									<th CL='STD_ASKU05'></th>
									<th CL='STD_DESC02'></th>
									<th CL='STD_UOMKEY'></th>
									<th CL='STD_LOTA10'></th>
									<!-- <th CL='STD_LOTA16'></th> -->
									<th CL='STD_LOTA17'></th>
									<th CL='STD_VALIDC'></th>
									<th CL='STD_OWNRKY'></th>
									<th CL='STD_OWNERNAME'></th>
								</tr>
							</thead>
						</table>				
					</div>					
					<div class="tableBody" style="display:table;">
						<table style="width:100%;">
							<colgroup>
								<col width="30" />
								<col width="30" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
								<col width="60" />
								<col width="60" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
								<col width="100" />
							</colgroup>
							<tbody id="gridList">
								<tr CGRow="true">
									<td GCol="rownum"></td>
									<td GCol="rowCheck"></td>
									<td GCol="input,INPUTSKU" validate="required" GF="S 20"></td>
									<td GCol="text,DESC01"></td>
									<td GCol="text,SKUG05"></td>
									<td GCol="input,QTYORD" validate="required gt(0)" GF="N 20,3"></td>
									<td GCol="text,QTTTWH" GF="N 20,3"></td>
									<td GCol="text,QTSIWH" GF="N 20,3"></td>
									<td GCol="select,COSTCT">
										<select Combo="WmsOrder,COSTCTCOMBO" validate="required">
											<option value=""> </option>
										</select>
									</td>
									<td GCol="input,DOCTXT" GF="S 180"></td>
									<td GCol="select,RSNCOD">
										<select ReasonCombo="380" validate="required">
											<option value=""> </option>
										</select>
									</td>
									<td GCol="input,TASRSN" validate="required" GF="S 255"></td>
									<td GCol="text,SKUKEY"></td>
									<td GCol="text,MATNR"></td>
									<td GCol="check,ASKU05"></td>
									<td GCol="text,DESC02"></td>
									<td GCol="text,UOMKEY"></td>
									<td GCol="text,LOTA10" GF="S 20"></td>
									<!-- <td GCol="text,LOTA16" GF="N 20,3"></td> -->
									<td GCol="text,LOTA17" GF="N 20,3"></td>
									<td GCol="text,TEXT"></td>
									<td GCol="text,OWNRKY" GF="S 10"></td>
									<td GCol="text,OWNRNM"></td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
				<!-- end table_body -->
				<div class="footer_5">
					<table>
						<colgroup>
							<col width="100" />
							<col width="100" />
						</colgroup>
						<tr>
							<td onclick="clearData()"><label CL='BTN_CLEAR'></label></td>
							<td class="f_1" onclick ="saveData()"><label CL='BTN_SAVE'></label></td>
						</tr>
					</table>
				</div><!-- end footer_5 -->	
			</div>
	</div>
	</div>
</body>