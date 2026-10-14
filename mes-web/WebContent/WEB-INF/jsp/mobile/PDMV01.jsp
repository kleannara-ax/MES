<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<head>
<style type="text/css">
button {float: right; }
input:read-only { 
    background-color: #e2e2e2;
}
select:DISABLED {
	background-color: #e2e2e2;
}
</style>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>Mobile WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script type="text/javascript" src="/wms/js/wms.js"></script>
<script>
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			editable : false,
			module : "WmsMobilePutaway",
			command : "PDMV04",
			gridMobileType : true,
			emptyMsgType:false
	    });
		
		$("#LOCASR").focus();
	});
	
	function searchList(){
		var locaky = $('#LOCAKY').val();
		var trnuid = $('#TRNUID').val();
		var skukey = $('#SKUKEY').val();
		
		if(locaky == "" && trnuid == "" && skukey == ""){
			commonUtil.msgBox("MASTER_M0314");
			PlaySound('e');
			$("#LOCAKY").focus();
			return;
		}
		
		var param = inputList.setRangeParam("searchArea");
		
		param.put("SES_WAREKY", "<%=wareky%>");
		param.put("SES_OWNER", "<%=ownrky%>");
		
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
		
		/* if(validate.check("searchArea")){
			var param = new DataMap();
			param.put("LOCAKY", $("#LOCASR").val());
			
			gridList.gridList({
			   	id : "gridList",
			   	param : param
			});	
		} */
	}
	
	//task 생성
	function makeTaskNomal(){
		
		if(!checkValidation()){
			return;
		}
			
		var data 		= gridList.getSelectData("gridList");
		var qtsiwhTot 	= Number(gridList.getGridBox("gridList").getColSum("ORDQTY"));
		var qttaorTot 	= 0;
		var typeArray 	= new Array();
		
		for(var i = 0; i < data.length; i++){
			var dataMap = data[i];
			data[i].put("LOCATG", $("#LOCAAC").val());
			typeArray.push(data[i].get("TASOTY"));
			qttaorTot += Number(data[i].get("QTTAOR"));
		}
		
		var param = new DataMap();
		param.put("TYPE",	typeArray);
		param.put("TRNUTG", $("#TRNUTG").val());
		param.put("LOCATG", $("#LOCAAC").val());
		param.put("DATA", 	data);
		param.put("list", 	data);
		
		var json = netUtil.sendData({
			url : "/mobile/MobilePutaway/json/makeTaskNomal_PDMV04.data",
			param : param
		});
		
		if(json && json.data){
			if(json.data["MSG"] != 'OK'){
				PlaySound('e');
				var msgList	 = json.data["MSG"].split(" ");
				var msgTxt	 = commonUtil.getMsg(msgList[0], (msgList.length > 1 ? msgList[1].split("/") : null));
				commonUtil.msg(msgTxt);
				
				$("#LOCAAC").focus();
				$("#LOCAAC").select();
				
				return;
			}else{
				PlaySound('s');
				if(qtsiwhTot != qttaorTot && $.trim($("#LOCASR").val()) != ""){
					commonUtil.msgBox("MOBILE_M5527");
					searchList();
				}else{
					$("#LOCASR").val("");
					$("#LOCAAC").val("");
					$("#TRNUTG").val("");
					//gridList.resetGrid("gridList");
					$("#LOCASR").focus();
				}
			}
		}
	}
	
	//search bind end event 처리 = 조회 후 그리드에 data set 이후 발생
	function gridListEventDataBindEnd(gridId, dataLength){
		if(gridId=="gridList"){
			if(dataLength > 0){
				PlaySound("s");
			}else{
				PlaySound("e");
			}
			$("#LOCASR").focus();
			$("#LOCASR").select();
		}
 	}
	
	function eventKeydown(event,objId){
		if(event.keyCode == "13"){
			if(objId =="LOCASR"){
				$("#TRNUTG").val("");
				$("#LOCAAC").val("");
				searchList();
			}else if(objId =="LOCAAC"){
				var param = new DataMap();
				param.put("LOCAKY", $("#LOCAAC").val());
				
				var json = netUtil.sendData({
					module : "WmsMobilePutaway",
					command : "PDMV03CHKLOC",
					sendType : "map",
					param : param
				});
				
				if(json && json.data){
					if(parseInt(json.data["CNT"]) == 1){
						$("#TRNUTG").focus();
						$("#TRNUTG").select();
						return;
					}else{
						commonUtil.msgBox("MOBILE_M0023");
						PlaySound('e');
						$("#LOCAAC").focus();
						$("#LOCAAC").select();
						return;
					}
				}
			}
		}
	}
	
	//필수값 체크
	function checkValidation(){
		var data = gridList.getSelectData("gridList");
		
		if(!validate.check("saveArea") || !gridList.validationCheck("gridList", "select")){
			return false;	
		}else if(data.length == 0){
			PlaySound('e');
			commonUtil.msgBox("VALID_M0006");
			return false;
		}
		
		return true;
	}
	
	function validationEventMsg(valObjType, objId, objIndex, objName, objValue, ruleText){
		PlaySound("e");
		if(objId == "LOCASR"){
			//return commonUtil.getMsg("VALID_M1568");
		}else if(objId == "LOCAAC"){
			return commonUtil.getMsg("MOBILE_M0026");
		}else if(objId == "gridList" && objName == "QTTAOR" ){
			return commonUtil.getMsg("MOBILE_M0022");
		}
	}
	
	function focusCheck(objId){
		try{
			$("#"+objId).select();
		}catch(e){}
	}
</script>
</head>
<body>
	<div class="main_wrap">
		<div class="tem4_content">
			<div class="select_box" id="searchArea">
				<table>
					<colgroup>
						<col width="120px" />
						<col />
						<col width="80px" />
						<col />
						<col width="80px" />
						<col />
						<col width="80px" />
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
							<th CL="STD_SKUKEY">바코드</th>
							<td>
								<input type="text" class="text" name="SKUKEY" id="SKUKEY" onfocus="focusCheck(this.id)" onkeypress="commonUtil.enterKeyCheck(event, 'searchList()')" />
							</td>
						</tr>
					</tbody>
				</table>
			</div>	
			<div class="tableWrap_search section" style="margin-bottom: 0px;">
				<div class="tableHeader">
					<table style="width: 825px"> 
						<colgroup>
							<col width="40px" />
							<col width="80px" />
							<col width="120px" />
							<col width="120px" />
							<col width="100px" />
							<col width="100px" />
							<col width="100px" />
							<col width="55px" />
							<col width="55px" />
							<col width="80px" />
							<col width="80px" />
						</colgroup>
						<thead>
							<tr class="thead">
								<th GBtnCheck="true"></th>
								<th CL='STD_SKUKEY'>SKU번호</th>
								<th CL='STD_SKUNM'>SKU명</th>
								<th CL='STD_BARCOD'>바코드</th>
								<th CL='STD_TRNUID'>팔레트ID</th>
								<th CL='STD_FROMLOC'>From 지번</th>
								<th CL='STD_LOTA13'>유통기한</th>
								<th CL='STD_ALLSTK'>가용수량</th>
								<th CL='STD_ORDQTY'>지시수량</th>
								<th CL='STD_QTSPMO'>이동OUT중</th>
								<th CL='STD_QTPUOM_1'>입수량</th>
							</tr>
						</thead>
					</table>				
				</div>
				<div class="tableBody">
					<table style="width: 825px">
						<colgroup>
							<col width="40px" />
							<col width="80px" />
							<col width="120px" />
							<col width="120px" />
							<col width="100px" />
							<col width="100px" />
							<col width="100px" />
							<col width="55px" />
							<col width="55px" />
							<col width="80px" />
							<col width="80px" />
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rowCheck"></td>
								<td GCol="text,SKUKEY">품번</td>
								<td GCol="text,DESC01">품명</td>
								<td GCol="text,EANCOD">바코드</td>
								<td GCol="text,TRNUID">파렛트ID</td>
								<td GCol="text,LOCASR">From 지번</td>
								<td GCol="text,LOTA13">유통기한</td>
								<td GCol="text,QTSIWH">가용수량</td>
								<td GCol="input,QTTAOR" GF="N" validate="min(1)">지시수량</td>
								<td GCol="text,QTSPMO">이동중수량</td>
								<td GCol="text,QTPUOM">입수량</td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
			<div class="select_box" id="saveArea">
				<table>
					<colgroup>
						<col width="120px" />
						<col />
						<col width="80px" />
						<col />
						<col width="80px" />
						<col />
						<col width="80px" />
						<col />
					</colgroup>
					<tbody>
						<tr>
							<th CL='STD_LOCATG'>To 로케이션</th>
							<td colspan="4">
								<input type="text" class="text" name="LOCAAC" id="LOCAAC" validate="required" onkeydown="eventKeydown(event,this.id)"/>
							</td>
						</tr>
						<tr>
							<th CL='STD_TRNUTG'>To 팔레트ID</th>
							<td colspan="4">
								<input type="text" class="text" name="TRNUTG" id="TRNUTG"/>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="footer_5">
				<table>
					<tr>
					<!--<td class=f_1 width="50%"><label CL='BTN_ROUTE'></label></td>-->
						<td class=f_1 onclick ="makeTaskNomal()" width="50%"><label CL='BTN_CONFIRM'></label></td>
					</tr>
				</table>
			</div>
		</div>
	</div>
</body>