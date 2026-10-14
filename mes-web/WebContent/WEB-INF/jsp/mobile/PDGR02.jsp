<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String flag = request.getParameter("FLAG");
%>
<!doctype html>
<head>
<style type="text/css">
button{ vertical-align: bottom; height: 37px; }
input:read-only{ background-color: #e2e2e2; }
select:DISABLED{ background-color: #e2e2e2; }
.tem5_content .tableWrap_search{ overflow: hidden; }
</style>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script>
	var data;
	var opt;
	var sebeln;
	var skukey;
	var barcod;
	var flag;
	var itemlist = [];
	var activeType = false;
	var curIdx = 0;
	
	$(document).ready(function(){
		$("#SEBELN").focus();

		data = mobile.getLinkPopData();
		flag = "<%=flag%>";

		if(flag == 'Y'){
			PlaySound('s');

			resetData();
			$("#SEBELN").focus();
		}

		if(data && flag != 'Y'){
			sebeln = data.get("SEBELN");
			skukey = data.get("SKUKEY");
			barcod = data.get("BARCOD");

			$('#SEBELN').val(sebeln);
			
			if(barcod){
				$('#BARCOD').val(barcod);
			}else{
				$('#BARCOD').val(skukey);
			}

			searchList();
			opt = "pop";
			$('#menu-container').show();
		}else{
			$("#SEBELN").focus();
			opt = " ";
			$('#menu-container').hide();
		}
	});

	//PO No. 스캔시
	function scanEbeln(){
		$("[name=BARCOD]").val("");
		
		var param = inputList.setRangeParam("paramArea");
		
		if(data){
			param = new DataMap();
			param.put("SEBELN", sebeln);
		}

		var json = netUtil.sendData({
			module : "WmsMobileInboundGoodsReceipt",
			command : "IFWMS103COUNT_101",
			sendType : "map",
			param : param
		});

		var cnt = json.data["CNT"];
		
		$("#skipRight").show();
		$("#skipLeft").show();

		if(cnt == 0){
			PlaySound('e');
			commonUtil.msgBox("VALID_M1586");   //완료되었거나 존재하지 않는 ASN 정보입니다.
			
			$('#SEBELN').select();
			return;
		}else{
			param = new DataMap();
			param.put("SES_WAREKY", "<%=wareky%>");
			param.put("SES_OWNER", "<%=ownrky%>");
			param.put("RCPTTY", "101");
			param.put("SEBELN", $("#SEBELN").val());
			
			var json2 = netUtil.send({
				module : "WmsMobileInboundGoodsReceipt",
				command : "PDGR02",
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
			param.put("RCPTTY", "101");

			if(data){
				param = new DataMap();
				param.put("SEBELN", sebeln);
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
				command : "IFWMS103_BARCOD_COUNT",
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
					command : "PDGR02",
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

		if(sebeln){
			$("#SEBELN").val(sebeln);
		}
		if(barcod){
			$("#BARCOD").val(barcod);
		}

		$('#TRNUID').focus();
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

	function saveDataAction(){
		if(activeType){
			return;
		}
		activeType = true;
		saveData();
		activeType = false;
	}

	function saveData(){
		var qtyord = Number($('#QTYORD').val());	//입고오더수량
		var menger = Number($('#MENGER_R').val());	//기입고수량
		var qtyrcv = Number($('#QTYRCV').val());	//입고남은수량
		var trnuid = $('#TRNUID').val();
		var lota11 = $('#LOTA11').val();
		var lota12 = $('#LOTA12').val();

		var param = inputList.setRangeParam("searchArea");

		if(param.get("SKUKEY") == "" || param.get("SKUKEY") == null){
			commonUtil.msgBox("IN_M0146");		// 조회된 ASN/SKU 정보가 없습니다. ASN/바코드를 스캔하세요.
			
			$('#SEBELN').focus();
			return;
		}

		if(qtyrcv == 0){
			commonUtil.msgBox("IN_M0149");		//확정수량은 0보다 커야합니다.
			return;
		}

		var sumqty = (qtyrcv + menger);
		if(sumqty > qtyord){
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
				url : "/mobile/mobileInboundGoodsReceipt/json/SavePDGR02.data",
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
				$("[name=SEBELP]").val("");    //오더아이템순번
				$("[name=SKUKEY]").val("");    //품번
				$("[name=DESC01]").val("");    //품명
				$("[name=BARCOD]").val("");    //바코드
				$("[name=LOCAKY]").val("");    //지번
				$("[name=LOTA11]").val("");    //제조일자
				$("[name=LOTA13]").val("");    //유통기한
				$("[name=TRNUID]").val("");    //PLT ID
				$("[name=UOMKEY]").val("");    //단위
				$("[name=QTYORD]").val("");    //입고오더수량
				$("[name=MENGER]").val("");    //기입고수량
				$("[name=QTYRCV]").val("");    //입고남은수량
				$("[name=LOTA11]").val("");
				$("[name=LOTA13]").val("");
				$("[name=EANCOD]").val("");

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
			command : "PDGR02_RE",
			bindId : "bindArea",
			sendType : "map",
			bindType : "field"
		}); 
	}

	//파렛트 분할 버튼 클릭시
/* 	function dividePlt(){
		var param = "SEBELN="+ $('#SEBELN').val()+"&"
					+ "SEBELP="+$('#SEBELP').val()+"&"
					+ "PTNRKY="+$('#PTNRKY').val()+"&"
					+ "SKUKEY="+$('#SKUKEY').val()+"&"
					+ "RCPTTY="+$('#RCPTTY').val()+"&"
					+ "LOTA11="+$('#LOTA11').val()+"&"
					+ "LOTA13="+$('#LOTA13').val()+"&"
					+ "QTYRCV="+$('#QTYRCV').val(); 

		location.href="/mobile/PDGR01_POP.page?"+param;	
	} */

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

	//파렛트ID 엔터시
 	function trnuid(){
		$('#QTYRCV').select();
	}

	//초기화 버튼
	function clearData(){
		if(!commonUtil.msgConfirm("VALID_M0011")){		//데이터 초기화됩니다. 계속 하시겠습니까?
			return;
		}
		
	    $("[name=SEBELN]").val("");    //PO No.
	    $("[name=BARCOD]").val("");	   //바코드
	    $("[name=SEBELP]").val("");    //오더아이템순번
	    $("[name=SKUKEY]").val("");    //품번
	    $("[name=DESC01]").val("");    //품명
	    $("[name=EANCOD]").val("");    //바코드
	    $("[name=LOCAKY]").val("");    //지번
	    $("[name=LOTA11]").val("");    //제조일자
	    $("[name=LOTA13]").val("");    //유통기한
	    $("[name=TRNUID]").val("");    //파렛트 ID
	    $("[name=UOMKEY]").val("");    //단위
	    $("[name=QTYORD]").val("");    //오더수량
	    $("[name=MENGER]").val("");    //기입고수량
	    $("[name=QTYRCV]").val("");    //남은수량
	    $("[name=EANCOD]").val("");
	    
	    $("#SEBELN").focus();
		$("#skipRight").show();
		$("#skipLeft").show();
	}
	
	//화면 왼쪽으로 이동하는 이벤트
	function skipLeft(){
		var curEbelp = $("[name=SEBELP]").val(); //현재화면에 있는 제품 데이터
		var barcode = $("[name=BARCOD]").val();
		
		var param = new DataMap();
		param.put("SEBELN",$("[name=SEBELN]").val());
		param.put("SES_WAREKY", "<%=wareky%>");
		param.put("SES_OWNER", "<%=ownrky%>");

		var json = netUtil.sendData({
			url : "/mobile/mobileInboundGoodsReceipt/json/GR02ITEMLIST.data",
			param : param
		});
		
		itemlist = json.data;
		var totalCnt = itemlist.length;
		
		var json2 = netUtil.sendData({
			module : "WmsMobileInboundGoodsReceipt", 
			command : "GR02SAMELIST",
			sendType : "map",
			param : param
		});
	
		var cnt = json2.data["CNT"];
		
		if(itemlist.length == 0){
			commonUtil.msgBox("VALID_M0020");
			$("#skipLeft").hide();
		}
		
		for(var i=0; i<itemlist.length; i++){
			var listdata = (json.data[i]).SEBELP;
			if(barcode == ""){
				if(curEbelp == listdata){
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
					if(curEbelp == listdata){
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

	//화면 오른쪽으로 이동하는 이벤트
	function skipRight(){
		var param = new DataMap();
		param.put("SEBELN",$("[name=SEBELN]").val());
		param.put("SES_WAREKY", "<%=wareky%>");
		param.put("SES_OWNER", "<%=ownrky%>");
		param.put("SKUKEY",$("[name=SKUKEY]").val());
		
		var curEbelp = $("[name=SEBELP]").val(); //현재화면에 있는 제품 데이터
		var barcode = $("[name=BARCOD]").val();

		var json = netUtil.sendData({
			url : "/mobile/mobileInboundGoodsReceipt/json/GR02ITEMLIST.data",
			param : param
		});
		
		itemlist = json.data;
		var totalCnt = itemlist.length;
		
		var json2 = netUtil.sendData({
			module : "WmsMobileInboundGoodsReceipt", 
			command : "GR02SAMELIST",
			sendType : "map",
			param : param
		});
	
		var cnt = json2.data["CNT"];
		
		if(itemlist.length == 0){
			commonUtil.msgBox("VALID_M0021");
			$("#skipRight").hide();
		}
		for(var i=0; i<itemlist.length; i++){
			var listdata = (json.data[i]).SEBELP;
			if(barcode == ""){
				if(curEbelp == listdata){
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
					if(curEbelp == listdata){
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
		$("[name=SEBELP]").val(data.SEBELP);    //ASN Item
		$("[name=LOCAKY]").val(data.LOCAKY);    //Location
		$("[name=TRNUID]").val(data.TRNUID);    //파렛트 ID
		$("[name=UOMKEY]").val(data.UOMKEY);    //단위
		$("[name=SKUKEY]").val(data.SKUKEY);    //품번
		$("[name=EANCOD]").val(data.EANCOD);    //바코드
		$("[name=QTYRCV]").val(data.QTYRCV);    //확정수량
		$("[name=SEBELN]").val(data.SEBELN);
		$("[name=LOTA06]").val(data.LOTA06);
		$("[name=QTYORD]").val(data.QTYORD);
		$("[name=MENGER]").val(data.MENGER);
	}
	
</script>
</head>
<body>
	<div id="menu-container">
		<div class="menu-item"></div>
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
							<th>PO No.</th>
							<td colspan="3">
								<input type="text" class="text" name="SEBELN" id="SEBELN" onfocus="fn_onfocus(this.id)" onkeypress="commonUtil.enterKeyCheck(event, 'scanEbeln()')" style="text-align: center;" validate="required,IN_M0011" />
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
							<th CL="STD_RCPTTY">입고유형</th>
							<td colspan="3">
								<select Combo="WmsMobileInboundGoodsReceipt,RCPTTYCOMBOPDGR02" name="RCPTTY" id="RCPTTY" disabled="disabled"></select>
							</td>
							<th>
								<%if(langky.equals("KR")){%>오더<br>순번<%}%>
								<%if(langky.equals("EN")){%>PO<br>ItemNo.<%}%>
							</th>
							<td colspan="1">
								<input type="text" class="text" name="SEBELP" id="SEBELP" readonly="readonly" />
							</td>
						</tr>
						<tr>
							<th CL="STD_SKUKY1">SKU번호</th>
							<td colspan="2">
								<input type="text" class="text" name="SKUKEY" id="SKUKEY" readonly="readonly" />
							</td>
							<td colspan="3">
								<input type="text" class="text" name="EANCOD" id="EANCOD" readonly="readonly" />
							</td>
						</tr>
						<tr>
							<th CL="STD_DESC01">품명</th>
							<td colspan="5">
								<input type="text" class="text" name="DESC01" readonly="readonly" />
							</td>
						</tr>
						<tr>
							<th CL="STD_LOCAKY">지번</th>
							<td colspan="5">
								<input type="text" class="text" name="LOCAKY" id="LOCAKY" onfocus="fn_onfocus(this.id)"/>
							</td>
						</tr>
						<tr>
							<th CL="STD_TRNUID">P/T</th>
							<td colspan="5">
								<input type="text" class="text" name="TRNUID" id="TRNUID" onkeypress="commonUtil.enterKeyCheck(event, 'trnuid()')"/>
							</td>
							<!-- <td colspan="2" class=f_1 style="height:40px; background: #a9a7a7; border-radius:10px; font-weight:bold;" onclick ="dividePlt()" >
								<label CL='BTN_PALLETS'></label>
							</td> -->
						</tr>
						<tr>
							<th CL="STD_LOTA11">제조일자</th>
							<td colspan="2">
								<input type="text" class="text" name="LOTA11" id="LOTA11" UIFormat="C" style="width:55%; float:left;" onclick="lota1113Check()"/>
							</td>
							<th CL="STD_LOTA13">유통기한</th>
							<td colspan="2">
								<input type="text" class="text" name="LOTA13" id="LOTA13" UIFormat="C" style="width:55%; float:left;" onclick="lota1113Check()"/>
							</td>
						</tr>
						<tr>
							<th CL="STD_LOTA06">재고상태</th>
							<td GCol="select,LOTA06" colspan="3">
								<select CommonCombo="LOTA06"></select>
							</td>
							<th CL="STD_DUOMKY">단위</th>
							<td colspan="1">
								<input type="text" class="text" name="UOMKEY" id="UOMKEY" readonly="readonly" />
							</td>
						</tr>
						<tr>
							<th CL="STD_QTYORG">오더수량</th>
							<td>
								<input type="text" class="text" name="QTYORD" id="QTYORD" UIFormat="N 10" readonly="readonly" />
							</td>
							<th>
								<%if(langky.equals("KR")){%>기입고<br>수량<%}%>
								<%if(langky.equals("EN")){%>Confirm<br>Quantity<%}%>
							</th>
							<td>
								<input type="text" class="text" name="MENGER" id="MENGER_R" UIFormat="N 10" readonly="readonly" />
							</td>
							<th>
								<%if(langky.equals("KR")){%>남은<br>수량<%}%>
								<%if(langky.equals("EN")){%>Quantity<br>Remain<%}%>
							</th>
							<td>
								<input type="text" class="text" name="QTYRCV" id="QTYRCV" UIFormat="N 10" />
							</td>
							
						</tr>
						<input type="hidden" name="PTNRKY" id="PTNRKY" />
						<input type="hidden" name="LOTA10" id="LOTA10" />
						<input type="hidden" name="LOTA12" id="LOTA12" />
					</tbody>
				</table>
			</div>
			
			<!-- end table_body -->
			<div class="footer_5" style="position:fixed;">
				<table>
					<tr>
						<td class=f_1 onclick ="skipLeft()" id="skipLeft" width="15%"><label CL='BTN_LEFT'>왼쪽</label></td>
						<td  class=f_1 onclick="clearData()" width="35%"><label CL='BTN_CLEAR'></label></td>
						<td class=f_1 onclick="saveDataAction()" width="35%"><label CL='BTN_PUTAWA'></label></td>
						<td class=f_1 onclick ="skipRight()" id="skipRight" width="15%"><label CL='BTN_RIGHT'>오른쪽</label></td>
						<!--<td class=f_1 onclick ="showMain()" width="33.3%"><label CL='BTN_CLOSE'></label></td>-->
					</tr>
				</table>
			</div>
			<!-- end footer_5 -->

		</div>
	</div>
</body>