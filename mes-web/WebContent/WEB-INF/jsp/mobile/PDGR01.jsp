<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String flag = request.getParameter("FLAG");
%>
<!doctype html>
<head>
<style type="text/css">
button {
	vertical-align: bottom;
	height: 37px;
}
input:read-only { 
	background-color: #e2e2e2;
}
select:DISABLED {
	background-color: #e2e2e2;
}
th {
	white-space: nowrap;
	overflow: hidden;
}
.tem5_content .tableWrap_search {overflow: hidden;}
</style>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script>
	var data;
	var opt;
	var asndky;
	var skukey;
	var barcod;
	var rcvlmtOrg;
	var flag;
	var itemlist = [];
	var activeType = false;
	var curIdx = 0;
	
	$(document).ready(function(){
		$("#ASNINV").focus();
		
		data = mobile.getLinkPopData();
		flag = "<%=flag%>";
		
		if(flag == 'Y'){
			PlaySound('s');
			
			resetData();
			$("#ASNINV").focus();
		}
		
		if(data && flag != 'Y'){
			asndky = data.get("ASNDKY");
			skukey = data.get("SKUKEY");
			barcod = data.get("BARCOD");
			
			
			$('#ASNINV').val(asndky);
			
			if(barcod){
				$('#BARCOD').val(barcod);
			}else{
				$('#BARCOD').val(skukey);
			}
			
			searchList();
			opt = "pop";
			
			$('#menu-container').show();
		}else{
			$("#ASNINV").focus();
			opt = " ";
			$('#menu-container').hide();
		}
		
	});
	
	//ASN 스캔시
	function scanAsn(){
		$("[name=BARCOD]").val("");
		
		var param = inputList.setRangeParam("paramArea");
		
		if(data){
			param = new DataMap();
			param.put("ASNINV", asndky);
		}
		
		var json = netUtil.sendData({
			module : "WmsMobileInboundGoodsReceipt", 
			command : "ASNCOUNT_112",
			sendType : "map",
			param : param
		});
		
		var cnt = json.data["CNT"];
		
		$("#skipRight").show();
		$("#skipLeft").show();
		
		if(cnt == 0){
			PlaySound('e');
			commonUtil.msgBox("VALID_M1586");   //완료되었거나 존재하지 않는 ASN 정보입니다.
			
			$('#ASNINV').select();
			return;
		}else{
			var json = netUtil.send({
				module : "WmsMobileInboundGoodsReceipt",
				command : "PDGR01",
				bindId : "bindArea",
				sendType : "map",
				bindType : "field",
				param : param
			}); 
			
			PlaySound('s');
			$('#BARCOD').focus();
		}
	}
	
	//바코드 스캔시
	function searchList(){
		inputList.removeValidation("TRNUID", "required");
		
		$("#skipRight").show();
		$("#skipLeft").show();
		
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("paramArea");
			param.put("SES_WAREKY", "<%=wareky%>");
			param.put("SES_OWNER", "<%=ownrky%>");
			
			if(data){
				param = new DataMap();
				param.put("ASNINV", asndky);
				param.put("SKUKEY", skukey);
				if(barcod){
					param.put("BARCOD", barcod);
				}else{
					param.put("BARCOD", skukey);
				}
				data = null;
			}
			
			var json = netUtil.sendData({
				module : "WmsMobileInboundGoodsReceipt",
				command : "ASN_BARCOD_COUNT",
				sendType : "map",
				param : param
			});
			
			var cnt = json.data["CNT"];
	
			if(cnt == 0){
				PlaySound('e');
				
				commonUtil.msgBox("VALID_M1586");	//완료되었거나 존재하지 않는 ASN 정보입니다.
				
				$('#BARCOD').select();
				return;
				
				if(data){
					mobile.linkPopClose('reSearch');
				}
			}else{
				var json = netUtil.send({
					module : "WmsMobileInboundGoodsReceipt",
					command : "PDGR01",
					bindId : "bindArea",
					sendType : "map",
					bindType : "field",
					param : param,
					successFunction : "bindEnd"
				}); 
			}
		}
	}
	
	function bindEnd(){
		PlaySound('s');
		
		if(asndky){
			$("#ASNINV").val(asndky);
		}
		if(barcod){
			$("#BARCOD").val(barcod);
		}
		
		$('#TEXTUOM').text($('#UOMKEY').val());
		$('#TRNUID').focus();
		
		rcvlmtOrg = $('#RCVLMT').val();
	}
	 
	function showMain(){
		if(opt == "pop"){
			mobile.linkPopClose();
		}else if(flag == 'Y'){
			mobile.linkPopClose();
		}else{
			window.top.menuOpen();
		}
	}
	
	function saveDataAction(){ //ASN입고 버튼 누를 시 
		if(activeType){
			return;
		}
		activeType = true;
		saveData();
		activeType = false;
	}

	function saveData(){
		var rcvlmt = $('#RCVLMT').val();
		var qtyrcv = Number($('#QTYRCV').val());
		var qtyasn = Number($('#QTABLE').val());
		var trnuid = $('#TRNUID').val();
		var locaky = $('#LOCAKY').val();

		var qtybox = Number($('#QTYBOX').val());
		var qtyrmn = Number($('#QTYRMN').val());
		
		var lota11 = $('#LOTA11').val();
		var lota12 = $('#LOTA12').val();
		
		var param = inputList.setRangeParam("searchArea");

		if(param.get("SKUKEY") == "" || param.get("SKUKEY") == null){
			commonUtil.msgBox("IN_M0146");		// 조회된 ASN/SKU 정보가 없습니다. ASN/바코드를 스캔하세요.
			
			$('#ASNINV').focus();
			return;
		}
		
		if(qtybox == 0 && qtyrmn == 0){
			commonUtil.msgBox("IN_M0149");		//확정수량은 0보다 커야합니다.
			return;
		}
		
		if(qtyrcv > qtyasn){
			commonUtil.msgBox("VALID_M1722");	//PDA에서는 초과입고 할 수 없습니다.
			return;
		}else if(qtyrcv == 0){
			commonUtil.msgBox("IN_M0149");		//확정수량은 0보다 커야합니다.
			return;
		}
		
		if(lota11 > lota12){
			commonUtil.msgBox("VALID_M1738");  	//제조일자가 입고일자보다 늦을 수 없습니다.
			return;
		}
		
		if(validate.check("searchArea")){
			if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
				return;
			}
			
			var json = netUtil.sendData({
				url : "/mobile/mobileInboundGoodsReceipt/json/SavePDGR01.data",
				param : param
			});
			
			if(json.data.length > 5 && json.data.length != 10){
				var msgList = json.data.split("†");
				var msgTxt = commonUtil.getMsg(msgList[0], (msgList.length > 1 ? msgList[1].split("/") : null));
				commonUtil.msg(msgTxt);
				return;
			} 
			
			if(json && json.data){
				PlaySound('s');
				commonUtil.msgBox("MASTER_M0564"); //저장완료
				
				//데이터 초기화
				$("[name=RCVLMT]").val("");	   //입고 제한일
				$("[name=SKUKEY]").val("");    //품번
				$("[name=DESC01]").val("");    //품명
				$("[name=EANCOD]").val("");    //바코드
				$("[name=LOTA11]").val("");    //제조일자
				$("[name=LOTA13]").val("");    //유통기한
				$("[name=TRNUID]").val("");    //PLT ID
				$("[name=UOMKEY]").val("");    //단위
				$("[name=QTIPSU]").val("");    //입수
				$("[name=QTYASN]").val("");    //예정수량
				$("[name=QTYRCV1]").val("");   //기확정수량
				$("[name=QTABLE]").val("");    //남은수량
				$("[name=QTYBOX]").val("");    //BOX수
				$("[name=QTYRCV]").val("");    //확정수량
				$("[name=QTYRMN]").val("");    //남은수량
				$("[name=LOCAKY]").val("");    //Location
				$("[name=ASNDIT]").val("");    //ASN Item
				$("[name=LOTA11]").val("");
				$("[name=LOTA13]").val("");
				
				$('#BARCOD').select();
				
				if(data){
					mobile.linkPopClose('save');
				}else{
					$('#BARCOD').select();
				}
			}else{
				PlaySound('e');
				
				$('#BARCOD').select();
			}
		}
	}
	
	function resetData(){
		var json = netUtil.send({
			module : "WmsMobileInboundGoodsReceipt",
			command : "PDGR01_RE",
			bindId : "bindArea",
			sendType : "map",
			bindType : "field"
		}); 
	}
	
	//수량 계산
	function setQtyrcv(){
		var qtipsu = Number($('#QTIPSU').val());
		var qtybox = Number($('#QTYBOX').val());
		var qtyrmn = Number($('#QTYRMN').val());
		
		var qtyrcv = (qtipsu * qtybox) + qtyrmn;
		$('#QTYRCV').val(qtyrcv);
	}
	
	//파렛트 분할 버튼 클릭시
	function dividePlt(){
		var param = "ASNINV="+ $('#ASNDKY').val()+"&"
					+ "ASNDIT="+$('#ASNDIT').val()+"&"
					+ "LOCAKY="+$('#LOCAKY').val()+"&"
					+ "PTNRKY="+$('#PTNRKY').val()+"&"
					+ "SKUKEY="+$('#SKUKEY').val()+"&"
					+ "ASNTTY="+$('#RCPTTY').val()+"&"
					+ "LOTA11="+$('#LOTA11').val()+"&"
					+ "LOTA13="+$('#LOTA13').val()+"&"
					+ "RCVLMT="+$('#RCVLMT').val()+"&"
					+ "QTABLE="+$('#QTABLE').val(); 

		location.href="/mobile/PDGR01_POP.page?"+param;	
	}
	
	//제조일자(LOTA11), 유통기한(LOTA13) 날짜형식 check
	function lota1113Check(){
		var slota11 = $('#LOTA11').val().split(".");
		var lota11 = slota11[0]+slota11[1]+slota11[2];
		
		var slota13 = $('#LOTA13').val().replace(".","");
		var lota13 = slota13[0]+slota13[1]+slota13[2];
		
		var today = new Date();
		var year = today.getFullYear();
		var month = today.getMonth()+1;
		var date = today.getDate();
		
		if (month < 10){
			month = "0" + month;
		}
		if (date < 10){ 
			date = "0" + date;
		}
		var sysdate = year+month+date;
		
		if(slota11 != ""){
			//제조일자는 과거일자만 가능하도록 체크(미래일자는 x)
			if(lota11 > sysdate){
				commonUtil.msgBox("VALID_M1607");	//제조일자는 오늘/과거일자만 입력 가능합니다.
				$('#LOTA11').val("");
				$("#LOTA11").focus();
				return;
			}
		}else if(slota13 != ""){
			//유통기한은 미래일자만 가능하도록 체크(과거일자는 x)
			if(lota13 <= sysdate){
				commonUtil.msgBox("VALID_M1606");	//유통기한은 미래일자만 입력 가능합니다.
				$('#LOTA13').val("");
				$("#LOTA13").focus();
				return;
			}
		}
		
		$("#TRNUID").select();
	} 
	
	function fn_onfocus(objId){
		$("#"+objId).select();
	}
	
 	function trnuid(){
		$('#QTYBOX').select();
	}

	//초기화 버튼
	function clearData(){
		if(!commonUtil.msgConfirm("VALID_M0011")){		//데이터 초기화됩니다. 계속 하시겠습니까?
			return;
		}
		
		$("[name=ASNINV]").val("");    //ASN
		$("[name=BARCOD]").val("");	   //바코드
		$("[name=RCVLMT]").val("");	   //입고 제한일
		$("[name=SKUKEY]").val("");    //품번
		$("[name=DESC01]").val("");    //품명
		$("[name=EANCOD]").val("");    //바코드
		$("[name=LOTA11]").val("");    //제조일자
		$("[name=LOTA13]").val("");    //유통기한
		$("[name=TRNUID]").val("");    //파렛트 ID
		$("[name=UOMKEY]").val("");    //단위
		$("[name=QTIPSU]").val("");    //입수
		$("[name=QTYASN]").val("");    //예정수량
		$("[name=QTYRCV1]").val("");   //기확정수량
		$("[name=QTABLE]").val("");    //남은수량
		$("[name=QTYBOX]").val("");    //BOX수
		$("[name=QTYRCV]").val("");    //확정수량
		$("[name=QTYRMN]").val("");    //EA
		$("[name=ASNDIT]").val("");    //ASN Item
		$("[name=LOCAKY]").val("");    //Location
		
		$("#ASNINV").focus();
		$("#skipRight").show();
		$("#skipLeft").show();
	}
	
	//데이터 왼쪽으로 넘기는 이벤트
	function skipLeft(){
		var param = new DataMap();
		param.put("ASNDKY",$("[name=ASNINV]").val());
		param.put("SKUKEY",$("[name=SKUKEY]").val());
		
		var asndit = $("[name=ASNDIT]").val(); //현재화면에 있는 제품 데이터
		var barcode = $("[name=BARCOD]").val();
		
		var json = netUtil.sendData({
			url : "/mobile/mobileInboundGoodsReceipt/json/GR01ITEMLIST.data",
			param : param
		});
		
		itemlist = json.data;
		var totalCnt = itemlist.length;
		
		var json2 = netUtil.sendData({
			module : "WmsMobileInboundGoodsReceipt", 
			command : "GR01SKULIST",
			sendType : "map",
			param : param
		});
	
		var cnt = json2.data["CNT"];
		
		if(itemlist.length == 0){
			commonUtil.msgBox("VALID_M0020");
			$("#skipLeft").hide();
		}
		
		for(var i=0; i<itemlist.length; i++){
			var listdata = (json.data[i]).ASNDIT;
			if(barcode == ""){
				if(asndit == listdata){
					curIdx = i-1;
					if(curIdx == -1){
						commonUtil.msgBox("VALID_M0020"); //첫 페이지입니다.
						$("#skipLeft").hide();
					}
					showItem(curIdx);
					return false;
				}else{
					curIdx--;
				}
			}else if(barcode != ""){ //동일제품  바코드 입력 시 동일제품 데이터 모두 조회
				if(cnt > 2){
					if(asndit == listdata){
						curIdx = i-1;
						if(curIdx == -1){
							commonUtil.msgBox("VALID_M0020");
							$("#skipLeft").hide();
						}
						showItem(curIdx);
						return false;
					}else{
						curIdx--;
					}
				}else{
					commonUtil.msgBox("VALID_M0020");
					$("#skipLeft").hide();
					return false;
				}
			}
		}
	}

	//데이터 오른쪽으로 넘기는 이벤트
	function skipRight(){
		var param = new DataMap();
		param.put("ASNDKY",$("[name=ASNINV]").val());
		param.put("SKUKEY",$("[name=SKUKEY]").val());
		
		var asndit = $("[name=ASNDIT]").val(); //현재화면에 있는 제품 데이터
		var barcode = $("[name=BARCOD]").val();
		
		var json = netUtil.sendData({
			url : "/mobile/mobileInboundGoodsReceipt/json/GR01ITEMLIST.data",
			param : param
		});
		
		itemlist = json.data;
		var totalCnt = itemlist.length;
		
		var json2 = netUtil.sendData({
			module : "WmsMobileInboundGoodsReceipt", 
			command : "GR01SKULIST",
			sendType : "map",
			param : param
		});
		
		var cnt = json2.data["CNT"];

		if(itemlist.length == 0){
			commonUtil.msgBox("VALID_M0021");
			$("#skipRight").hide();
		}
		for(var i=0; i<itemlist.length; i++){
			var listdata = (json.data[i]).ASNDIT;
			if(barcode == ""){
				if(asndit == listdata){
					curIdx = i+1;
					if(curIdx == totalCnt){
						commonUtil.msgBox("VALID_M0021");
						$("#skipRight").hide();
					}
					showItem(curIdx);
					return false;
				}else{
					curIdx++;
				}
			}else if(barcode != ""){ //동일제품  바코드 입력 시 동일제품 데이터 모두 조회
				if(cnt > 2){
					if(asndit == listdata){
						curIdx = i+1;
						if(curIdx == totalCnt){
							commonUtil.msgBox("VALID_M0021");
							$("#skipRight").hide();
						}
						showItem(curIdx);
						return false;
					}else{
						curIdx++;
					}
				}else{
					commonUtil.msgBox("VALID_M0021");
					$("#skipRight").hide();
					return false;
				}
			}
		}
	}

	function showItem(curIdx){
		var data = itemlist[curIdx];
		$("[name=DESC01]").val(data.DESC01);    //품명
		$("[name=BARCOD]").val(data.BARCOD);   //바코드
		$("[name=RCVLMT]").val(data.RCVLMT);   //입고 제한일
		$("[name=SKUKEY]").val(data.SKUKEY);    //품번
		$("[name=EANCOD]").val(data.EANCOD);    //바코드
		$("[name=TRNUID]").val(data.TRNUID);    //파렛트 ID
		$("[name=UOMKEY]").val(data.UOMKEY);    //단위
		$("[name=QTIPSU]").val(data.QTIPSU);    //입수
		$("[name=QTYASN]").val(data.QTYASN);    //예정수량
		$("[name=QTYRCV1]").val(data.QTYRCV1);   //기확정수량
		$("[name=QTABLE]").val(data.QTABLE);    //남은수량
		$("[name=QTYBOX]").val(data.QTYBOX);    //BOX수
		$("[name=QTYRCV]").val(data.QTYRCV);    //확정수량
		$("[name=QTYRMN]").val(data.QTYRMN);    //EA
		$("[name=ASNDIT]").val(data.ASNDIT);    //ASN Item
		$("[name=LOCAKY]").val(data.LOCAKY);    //Location
	}

</script>
</head>
<body>
	<div id="menu-container">
		<div class="menu-item"></div> <!-- 입고 -->
	</div>
	<div class="main_wrap" id="searchArea">
		<div class="tem4_content">
			<div class="select_box" id="bindArea">
				<table>
					<colgroup>
						<col width="65px" />
						<col />
						<col width="65px" />
						<col />
					</colgroup>
					<tbody id="paramArea">
						<tr>
							<!-- <th  CL='STD_ASN'></th> -->
							<th>ASN</th>
							<td colspan="3">
								<input type="text" class="text" name="ASNINV" id="ASNINV" onfocus="fn_onfocus(this.id)" onkeypress="commonUtil.enterKeyCheck(event, 'scanAsn()')" style="text-align: center;" />
							</td>
						</tr>
						<tr>
							<th  CL='STD_BARCOD'></th>
							<td colspan="3">
								<input type="text" class="text" name="BARCOD" id="BARCOD" onfocus="fn_onfocus(this.id)" onkeypress="commonUtil.enterKeyCheck(event, 'searchList()')" style="text-align: center;" />
							</td>
						</tr>
					</tbody>
				</table>
				<hr />
				<table>
					<colgroup>
						<col width="70px" />
						<col width="60px"/>
						<col width="60px"/>
						<col width="70px"/>
						<col width="60px"/>
						<col width="60px"/>
					</colgroup>
					<tbody>
						<tr>
							<th style="font-size: 14px">
								<%if(langky.equals("KR")){%>입고<br>제한일<%}%>
								<%if(langky.equals("EN")){%>Limited<br>Date<%}%>
							</th>
							<td colspan="2" style="font-size: 14px">
								<input type="text" class="text" name="RCVLMT" id="RCVLMT" readonly="readonly" style="width: 98%"/>
							</td>
							<th CL="STD_RCPTTY" style="font-size: 14px">입고유형</th>
							<td colspan="2">
								<select Combo="WmsMobileInboundGoodsReceipt,RCPTTYCOMBOPDGR01" name="ASNTTY" id="RCPTTY" disabled="disabled"></select>
							</td>
						</tr>
						<tr>
							<th CL="STD_SKUKY1" style="font-size: 14px">SKU번호</th>
							<td colspan="2">
								<input type="text" class="text" name="EANCOD" id="EANCOD" readonly="readonly" />
							</td>
							<td colspan="3" style="font-size: 14px">
								<input type="text" class="text" name="SKUKEY" id="SKUKEY" readonly="readonly" />
							</td>
						</tr>
						<tr>
							<th CL="STD_DESC01" style="font-size: 14px">품명</th>
							<td colspan="5">
								<input type="text" class="text" name="DESC01" readonly="readonly" />
							</td>
						</tr>
						<tr>
							<th CL="STD_LOTA11" style="font-size: 14px">제조일자</th>
							<td colspan="2">
								<input type="text" class="text" name="LOTA11" id="LOTA11" UIFormat="C" style="width:55%; float:left;" onclick="lota1113Check()"/>
							</td>
							<th CL="STD_LOTA13" style="font-size: 14px">유통기한</th>
							<td colspan="2">
								<input type="text" class="text" name="LOTA13" id="LOTA13" UIFormat="C" style="width:55%; float:left;" onclick="lota1113Check()"/>
							</td>
						</tr>
						<tr>
							<th CL="STD_LOCAKY" style="font-size: 14px">지번</th>
							<td colspan="2">
								<input type="text" class="text" name="LOCAKY" id="LOCAKY" onfocus="fn_onfocus(this.id)" style="float:left;"/>
							</td>
							<th CL="STD_ASNDIT" style="font-size: 14px">ASN Item</th>
							<td colspan="2">
								<input type="text" class="text" name="ASNDIT" id="ASNDIT" readonly="readonly" style="float:left;"/>
							</td>
						</tr>
						<tr>
							<th CL="STD_TRNUID" style="font-size: 14px">P/T</th>
							<td colspan="5">
								<input type="text" class="text" name="TRNUID" id="TRNUID" onkeypress="commonUtil.enterKeyCheck(event, 'trnuid()')"/>
							</td>
							<!-- <td colspan="2" class=f_1 style="height:40px; background: #a9a7a7; border-radius:10px; font-weight:bold;" onclick ="dividePlt()" >
								<label CL='BTN_PALLETS'></label>
							</td> -->
						</tr>
						<tr>
							<th CL="STD_DUOMKY" style="font-size: 14px">단위</th>
							<td>
								<input type="text" class="text" name="UOMKEY" id="UOMKEY" readonly="readonly" />
							</td>
							<th CL="STD_QTDUOM" style="font-size: 14px">입수</th>
							<td>
								<input type="text" class="text" name="QTIPSU" id="QTIPSU" UIFormat="N 10" readonly="readonly" />
							</td>
							<th CL="STD_QTYSCAN" style="font-size: 14px">스캔수량</th>
							<td>
								<input type="text" class="text" name="QTYSCAN" id="QTYSCAN" UIFormat= "N 10" readonly="readonly" />
							</td>
						</tr>
						<tr>
							<th CL="STD_QTYORG2" style="font-size: 14px">예정수량</th>
							<td>
								<input type="text" class="text" name="QTYASN" id="QTYASN" UIFormat="N 10" readonly="readonly" />
							</td>
							<th style="font-size: 14px">
								<%if(langky.equals("KR")){%>기확정<br>수량<%}%>
								<%if(langky.equals("EN")){%>Confirm<br>Quantity<%}%>
							</th>
							<td>
								<input type="text" class="text" name="QTYRCV1" id="QTYRCV1" UIFormat="N 10" readonly="readonly" />
							</td>
							<th style="font-size: 14px">
								<%if(langky.equals("KR")){%>남은<br>수량<%}%>
								<%if(langky.equals("EN")){%>Quantity<br>Remain<%}%>
							</th>
							<td>
								<input type="text" class="text" name="QTABLE" id="QTABLE" UIFormat="N 10" readonly="readonly" />
							</td>
							
						</tr>
						<tr>
							<th CL="STD_QTSBOX" style="font-size: 14px">BOX수</th>
							<td>
								<input type="text" class="text" name="QTYBOX" id="QTYBOX" UIFormat="N 10" onchange="setQtyrcv()" />
							</td>
							<th CL="STD_EA" style="font-size: 14px">EA</th>
							<td>
								<input type="text" class="text" name="QTYRMN" id="QTYRMN" onchange="setQtyrcv()" UIFormat="N 10" />
							</td>
							<th style="font-size: 14px">
								<%if(langky.equals("KR")){%>총<br>수량<%}%>
								<%if(langky.equals("EN")){%>Total<br>Quantity<%}%>
							</th>
							<td>
								<input type="text" class="text" name="QTYRCV" id="QTYRCV" onchange="setQtyrcv()" UIFormat="N 10" readonly="readonly"/>
							</td>
						</tr>
						<input type="hidden" name="PTNRKY" id="PTNRKY" />
						<input type="hidden" name="ASNDKY" id="ASNDKY" />
						<input type="hidden" name="LOTA10" id="LOTA10" />
						<input type="hidden" name="LOTA12" id="LOTA12" />
						<input type="hidden" name="EXPIRED_LIMIT" id="EXPIRED_LIMIT" />
						<input type="hidden" name="WARNING_LIMIT" id="WARNING_LIMIT" />
						<input type="hidden" name="VEHINO" id="VEHINO" />
						<input type="hidden" name="DOCKNO" id="DOCKNO" />
						<input type="hidden" name="DRELIN" id="DRELIN" />
						<input type="hidden" name="INSPTY" id="INSPTY" />
						<input type="hidden" name="INVCNO" id="INVCNO" />
						<input type="hidden" name="INDDCL" id="INDDCL" />
						<input type="hidden" name="VEHDAT" id="VEHDAT" />
						<input type="hidden" name="REFDKY" id="REFDKY" />
						<input type="hidden" name="REFDIT" id="REFDIT" />
						<input type="hidden" name="REFCAT" id="REFCAT" />
						<input type="hidden" name="REFDAT" id="REFDAT" />
						<input type="hidden" name="SEBELN" id="SEBELN" />
						<input type="hidden" name="SEBELP" id="SEBELP" />
					</tbody>
				</table>
			</div>
			
				<!-- end table_body -->
			<div class="footer_5" style="position:fixed;">
				<table>
					<tr>
						<td class=f_1 onclick ="skipLeft()" id="skipLeft" width="15%"><label CL='BTN_LEFT'>왼쪽</label></td>
						<td  class=f_1 onclick="clearData()" width="35%"><label CL='BTN_CLEAR'></label></td>
						<td class=f_1 onclick="saveDataAction()" width="35%"><label CL='BTN_ASNRCV'></label></td>
						<td class=f_1 onclick ="skipRight()" id="skipRight" width="15%"><label CL='BTN_RIGHT'>오른쪽</label></td>
						<!--<td class=f_1 onclick ="showMain()" width="33.3%"><label CL='BTN_CLOSE'></label></td>-->
					</tr>
				</table>
			</div><!-- end footer_5 -->	
		</div>
	</div>
</body>