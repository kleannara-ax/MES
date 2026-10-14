<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript" src="/wms/js/wms.js"></script>
<script type="text/javascript">
	$(document).ready(function(){
		setTopSize(200);
		gridList.setGrid({
	    	id : "gridList",
	    	name : "gridList",
			editable : true,
			module : "WmsInventory",
			command : "SJ05"
	    });
		
		gridList.setGrid({
	    	id : "gridListSub",
	    	name : "gridListSub",
			editable : true,
			module : "WmsInventory",
			command : "SJ05Sub"
	    });
	});
	
	function searchList(){
		uiList.setActive("Search", false);
		uiList.setActive("Save", true);
		uiList.setActive("Reflect", true);
		
		var param = inputList.setRangeParam("searchArea");
		
		if(param.get("ADJUTY") == '465'){
			param.put("LOTA", "00");
		}else if(param.get("ADJUTY") == '460'){
			param.put("LOTA", "50");
		}
		
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
		
		gridList.gridList({
	    	id : "gridListSub",
	    	param : param
	    });
		
		$("#arsnadjCombo").val("");
		
		gridList.setReadOnly("gridList", false);
		gridList.setReadOnly("gridListSub", false);

	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId == "gridList"){
			uiList.setActive("Save", true);
		}
	}
	
	function gridListEventDataViewEnd(gridId, dataLength){
		//commonUtil.debugMsg("gridListEventDataViewEnd : ", arguments);
		if(gridId == "gridList"){
			uiList.setActive("Search", true);
		}
	}
	
	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}else if(btnName == "Reflect"){
			setArsnadj();
		}
	}
	
	function saveData(){		
		
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		}
		
		if(gridList.validationCheck("gridListSub", "all")){
			
			var docunum = wms.getDocSeq("460");
			gridList.gridColModify("gridList", 0, "SADJKY", docunum);

			var head = gridList.getRowData("gridList", 0);
			
			//alert(head);
			
			var list = gridList.getSelectModifyList("gridListSub");
			
			if(list.length == 0){
				commonUtil.msgBox("INV_M0055",docunum);
				return;
			}
			
			//alert(list);
			
			var param = new DataMap();
			
			param.put("head", head);
			param.put("list", list);
			
			var json = netUtil.sendData({
				url : "/wms/inventory/json/saveAdjd.data",
				param : param
			});
			
			if(json && json.data){
				commonUtil.msgBox("INV_M0010", docunum);
				
				var paramH = new DataMap();
				paramH.put("SADJKY", docunum);
				
				gridList.gridList({
			    	id : "gridList",
			    	command : "SJ05L",
			    	param : paramH
			    });
				
				gridList.gridList({
			    	id : "gridListSub",
			    	command : "SJ04M",
			    	param : paramH
			    });
				
				gridList.setReadOnly("gridList", true);
				gridList.setReadOnly("gridListSub", true);
			}		
			uiList.setActive("Save", false);
			uiList.setActive("Reflect", false);
		}		
	}
	
	function setArsnadj(){
		var arsnadjCombo = $("#arsnadjCombo").val();
		if(arsnadjCombo){
			var selectNumList = gridList.getSelectRowNumList("gridListSub");
			for(var i=0;i<selectNumList.length;i++){
				var rowNum = selectNumList[i];
				gridList.setColValue("gridListSub", rowNum, "ARSNADJ", arsnadjCombo);
			}
		}
	}
	
	function searchHelpEventOpenBefore(searchCode, gridType){
		//commonUtil.debugMsg("searchHelpEventOpenBefore : ", arguments);
		if(searchCode == "SHAREMA"){
			return dataBind.paramData("searchArea");
		}else if(searchCode == "SHWAHMA"){
			return dataBind.paramData("searchArea");
		}
	}
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY">
		</button>
		<button CB="Save SAVE STD_SAVE">
	</div>
	<div class="util2">
		<button class="button type2" id="showPop" type="button"><img src="/common/images/ico_btn4.png" alt="List" /></button>
	</div>
</div>

<!-- searchPop -->
<div class="searchPop" id="searchArea">
	<button type="button" class="closer">X</button>
	<div class="searchInnerContainer">
		<p class="util">
			<button CB="Search SEARCH BTN_DISPLAY"></button>
			<button CB="GetVariant GETVARIANT BTN_GETVARIANT"></button>
			<button CB="SaveVariant SAVEVARIANT BTN_SAVEVARIANT"></button>
		</p>
		<div class="searchInBox">
			<h2 class="tit" CL="STD_SELECTOPTIONS">검색조건</h2>
			<table class="table type1">
				<colgroup>
					<col width="100" />
					<col />
				</colgroup>
				<tbody>
					<tr>
						<th CL="STD_WAREKY">거점</th>
						<td>
							<input type="text" name="WAREKY" UIInput="S,SHWAHMA" value="<%=wareky%>" readonly="readonly"/>
						</td>
					</tr>
					<tr>
						<th CL="STD_ADJUTY">조정문서 유형</th>
							<td GCol="select,ADJUTY">
								<select Combo="WmsInventory,DOCUTY46COMBO" name="ADJUTY"></select>
							</td>
					</tr>
					<tr>
						<th CL="STD_AREAKY">창고</th>
						<td>
							<input type="text" name="S.AREAKY" UIInput="R,SHAREMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_ZONEKY">구역</th>
						<td>
							<input type="text" name="S.ZONEKY" UIInput="R,SHZONMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_LOCAKY">지번</th>
						<td>
							<input type="text" name="S.LOCAKY" UIInput="R,SHLOCMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_SKUKEY">품번코드</th>
						<td>
							<input type="text" name="S.SKUKEY" UIInput="R,SHSKUMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_DESC01">품명</th>
						<td>
							<input type="text" name="S.DESC01" UIInput="R" />
						</td>
					</tr>
					<tr>
						<th CL="STD_TRNUID">P/T ID</th>
						<td>
							<input type="text" name="S.TRNUID" UIInput="R" />
						</td>
					</tr>
				</tbody>
			</table>
		</div>
		<div class="searchInBox">
			<h2 class="tit type1">LOT정보</h2>
			<table class="table type1">
				<colgroup>
					<col width="100" />
					<col />
				</colgroup>
				<tbody>
					<tr>
						<th CL="STD_LOTA01">S/N번호</th>
						<td>
							<input type="text" name="S.LOTA01" UIInput="R" />
						</td>
					</tr>
					<tr>
						<th CL="STD_LOTA11">제조일자</th>
						<td>
							<input type="text" name="S.LOTA11" UIInput="R" UIFormat="C" />
						</td>
					</tr>
					<tr>
						<th CL="STD_LOTA03">벤더</th>
						<td>
							<input type="text" name="S.LOTA03" UIInput="R" />
						</td>
					</tr>
					<tr>
						<th CL="STD_LOTA05">재고분류</th>
						<td>
							<input type="text" name="S.LOTA05" UIInput="R" />
						</td>
					</tr>
					<tr>
						<th CL="STD_LOTA06">재고상태</th>
						<td>
							<input type="text" name="S.LOTA06" UIInput="R,SHCMCDV" />
						</td>
					</tr>
				</tbody>
			</table>
		</div>
	</div>
</div>
<!-- //searchPop -->

<!-- content -->
<div class="content">
	<div class="innerContainer">

		<!-- contentContainer -->
		<div class="contentContainer">

			<div class="bottomSect top">
				<button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button>
				<div class="tabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span>일반</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
											<col width="40" />
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
											<col width="100" />
											<col width="100" />
											<col width="100" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<th CL='STD_SADJKY'></th>
												<th CL='STD_WAREKY'></th>
												<th CL='STD_ADJUTY'></th>
												<th CL='STD_ADJSTX'></th>
												<th CL='STD_DOCDAT'></th>
												<th CL='STD_DOCCAT'></th>
												<th CL='STD_DOCCATNM'></th>
												<th CL='STD_ADJUCA'></th>
												<th CL='STD_DOCTXT'></th>
												<th CL='STD_CREDAT'></th>
												<th CL='STD_CRETIM'></th>
												<th CL='STD_CREUSR'></th>
												<th CL='STD_CUSRNM'></th>
												<th CL='STD_LMODAT'></th>
												<th CL='STD_LMOTIM'></th>
												<th CL='STD_LMOUSR'></th>
												<th CL='STD_LUSRNM'></th>
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="40" />
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
											<col width="100" />
											<col width="100" />
											<col width="100" />
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<td GCol="text,SADJKY"></td>
												<td GCol="text,WAREKY"></td>
												<td GCol="text,ADJUTY"></td>
												<td GCol="text,ADJSTX"></td>
												<td GCol="input,DOCDAT" GF="C 8"></td>
												<td GCol="text,DOCCAT"></td>
												<td GCol="text,DOCCATNM"></td>
												<td GCol="text,ADJUCA"></td>
												<td GCol="input,DOCTXT" GF="S 1000"></td>
												<td GCol="text,CREDAT"></td>
												<td GCol="text,CRETIM"></td>
												<td GCol="text,CREUSR"></td>
												<td GCol="text,CUSRNM"></td>
												<td GCol="text,LMODAT"></td>
												<td GCol="text,LMOTIM"></td>
												<td GCol="text,LMOUSR"></td>
												<td GCol="text,LUSRNM"></td>
											</tr>									
										</tbody>
									</table>
								</div>

							</div>
							<div class="tableUtil">
								<div class="leftArea">
									<button type="button" GBtn="find"></button>
									<button type="button" GBtn="sortReset"></button>
									<button type="button" GBtn="copy"></button>
									<button type="button" GBtn="layout"></button>
									<button type="button" GBtn="total"></button>
									<button type="button" GBtn="excel"></button>
								</div>
								<div class="rightArea">
									<p class="record" GInfoArea="true"></p>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>

			<div class="bottomSect bottom">
				<button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button>
				<div class="tabs">
					<ul class="tab type2" id="commonMiddleArea">
						<li><a href="#tabs1-1"><span>조정 가능 목록</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<table class="util">
									<tr>
										<th CL="STD_RSNADJ"></th>
										<td>
											<select ReasonCombo="410" id="arsnadjCombo">
												<option value=""> </option>
											</select>
										</td>
										<td>
											<button CB="Reflect REFLECT BTN_REFLECT">
											</button>
										</td>
									</tr>
								</table>
							<div class="table type2" style="top:30px;">
								<div class="tableHeader">
									<table>
										<colgroup>
											<col width="40" />
											<col width="40" />
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
												<th CL='STD_NUMBER'>번호</th>
												<th GBtnCheck="true"></th>
												<th CL='STD_STOKKY'></th>
												<th CL='STD_LOTNUM'></th>
												<th CL='STD_SECTID'></th>
												<th CL='STD_PACKID'></th>
												<th CL='STD_TRNUID'></th>
												<th CL='STD_TRUNTY'></th>
												<th CL='STD_OWNRKY'></th>
												<th CL='STD_AREAKY'></th>
												<th CL='STD_LOCAKY'></th>
												<th CL='STD_SKUKEY'></th>
												<th CL='STD_DESC01'></th>
												<th CL='STD_DESC02'></th>
												<th CL='STD_MEASKY'></th>
												<th CL='STD_DUOMKY'></th>
												<th CL='STD_QTYUOM'></th>
												<th CL='STD_UOMKEY'></th>
												<th CL='STD_QTPUOM'></th>
												<th CL='STD_QTDUOM'></th>
												<th CL='STD_QTSIWH'></th>
												<th CL='STD_USEQTY'></th>
												<th CL='STD_QTSBLK'></th>
												<th CL='STD_EANCOD'></th>
												<th CL='STD_GTINCD'></th>
												<th CL='STD_SKUG01'></th>
												<th CL='STD_SKUG02'></th>
												<th CL='STD_SKUG03'></th>
												<th CL='STD_SKUG04'></th>
												<th CL='STD_SKUG05'></th>
												<th CL='STD_GRSWGT'></th>
												<th CL='STD_NETWGT'></th>
												<th CL='STD_BATMNG'></th>
												<th CL='STD_ASKU01'></th>
												<th CL='STD_ASKU02'></th>
												<th CL='STD_ASKU03'></th>
												<th CL='STD_ASKU04'></th>
												<th CL='STD_ASKU05'></th>
												<th CL='STD_STOKKY'></th>
												<th CL='STD_RSNADJ'></th>
												<th CL='STD_LOTNUM'></th>
												<th CL='STD_LOCATG'></th>
												<th CL='STD_SECTID'></th>
												<th CL='STD_PACKID'></th>
												<th CL='STD_TRNUID'></th>
												<th CL='STD_OWNRKY'></th>
												<th CL='STD_CHNSKUKEY'></th>
												<th CL='STD_TRUNTY'></th>
												<th CL='STD_MEASKY'></th>
												<th CL='STD_QTADJU'></th>
												<th CL='STD_DUOMKY'></th>
												<th CL='STD_QTYUOM'></th>
												<th CL='STD_UOMKEY'></th>
												<th CL='STD_QTPUOM'></th>
												<th CL='STD_QTBLKD'></th>
												<th CL='STD_DESC01'></th>
												<th CL='STD_PTLT01'></th>
												<th CL='STD_PTLT02'></th>
												<th CL='STD_PTLT03'></th>
												<th CL='STD_LOTA04'></th>
												<th CL='STD_LOTA05'></th>
												<th CL='STD_LOTA06_TO'></th>
												<th CL='STD_LOTA07'></th>
												<th CL='STD_LOTA08'></th>
												<th CL='STD_LOTA09'></th>
												<th CL='STD_LOTA10'></th>
												<th CL='STD_LOTA11_TO'></th>
												<th CL='STD_LOTA12'></th>
												<th CL='STD_LOTA13_TO'></th>
												<th CL='STD_LOTA14'></th>
												<th CL='STD_LOTA15'></th>
												<th CL='STD_LOTA16'></th>
												<th CL='STD_LOTA17'></th>
												<th CL='STD_LOTA18'></th>
												<th CL='STD_LOTA19'></th>
												<th CL='STD_LOTA20'></th>
												<th CL='STD_DESC02'></th>
												<th CL='STD_EANCOD'></th>
												<th CL='STD_GTINCD'></th>
												<th CL='STD_SKUG01'></th>
												<th CL='STD_SKUG02'></th>
												<th CL='STD_SKUG03'></th>
												<th CL='STD_SKUG04'></th>
												<th CL='STD_SKUG05'></th>
												<th CL='STD_GRSWGT'></th>
												<th CL='STD_NETWGT'></th>
												<th CL='STD_AREAKY'></th>
												<th CL='STD_BATMNG_1'></th>
												<th CL='STD_ASKU01'></th>
												<th CL='STD_ASKU02'></th>
												<th CL='STD_MASKU03_1'></th>
												<th CL='STD_ASKU04'></th>
												<th CL='STD_ASKU05_TO'></th>
												<th CL='STD_ADJRSN'></th>
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="40" />
											<col width="40" />
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
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
										</colgroup>
										<tbody id="gridListSub">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<td GCol="rowCheck"></td>
												<td GCol="text,STOKKY"></td>
												<td GCol="text,LOTNUM"></td>
												<td GCol="text,SECTID"></td>
												<td GCol="text,PACKID"></td>
												<td GCol="text,TRNUID"></td>
												<td GCol="text,TRUNTY"></td>
												<td GCol="text,OWNRKY"></td>
												<td GCol="text,AREAKY"></td>
												<td GCol="text,LOCAKY"></td>
												<td GCol="text,SKUKEY"></td>
												<td GCol="text,DESC01"></td>
												<td GCol="text,DESC02"></td>
												<td GCol="text,MEASKY"></td>
												<td GCol="text,DUOMKY"></td>
												<td GCol="text,QTYUOM"></td>
												<td GCol="text,UOMKEY"></td>
												<td GCol="text,QTPUOM"></td>
												<td GCol="text,QTDUOM"></td>
												<td GCol="text,QTSIWH"></td>
												<td GCol="text,USEQTY"></td>
												<td GCol="text,QTSBLK"></td>
												<td GCol="text,EANCOD"></td>
												<td GCol="text,GTINCD"></td>
												<td GCol="text,SKUG01"></td>
												<td GCol="text,SKUG02"></td>
												<td GCol="text,SKUG03"></td>
												<td GCol="text,SKUG04"></td>
												<td GCol="text,SKUG05"></td>
												<td GCol="text,GRSWGT"></td>
												<td GCol="text,NETWGT"></td>
												<td GCol="text,BATMNG"></td>
												<td GCol="text,ASKU01"></td>
												<td GCol="text,ASKU02"></td>
												<td GCol="text,ASKU03"></td>
												<td GCol="text,ASKU04"></td>
												<td GCol="text,ASKU05"></td>
												<td GCol="text,ASTOKKY"></td>
												<td GCol="select,ARSNADJ" validate="required,INV_M0054">
													<select ReasonCombo="410">
														<option value=""> </option>
													</select>
												</td>
												<td GCol="text,ALOTNUM"></td>
												<td GCol="text,ALOCAKY"></td>
												<td GCol="text,ASECTID"></td>
												<td GCol="text,APACKID"></td>
												<td GCol="input,ATRNUID" GF="S 30"></td>
												<td GCol="text,AOWNRKY"></td>
												<td GCol="text,ASKUKEY"></td>
												<td GCol="text,ATRUNTY"></td>
												<td GCol="text,AMEASKY"></td>
												<td GCol="input,AQTADJU" validate="max(GRID_COL_AQTADJU_*),INV_M0024" GF="N 20,3"></td>
												<td GCol="text,ADUOMKY"></td>
												<td GCol="text,AQTYUOM"></td>
												<td GCol="text,AUOMKEY"></td>
												<td GCol="text,AQTPUOM"></td>
												<td GCol="text,AQTBLKD"></td>
												<td GCol="text,ADESC01"></td>
												<td GCol="input,ALOTA01" GF="S 20"></td>
												<td GCol="text,ALOTA02"></td>
												<td GCol="input,ALOTA03" GF="S 20"></td>
												<td GCol="text,ALOTA04"></td>
												<td GCol="text,ALOTA05"></td>
												<td GCol="select,ALOTA06">
													<select CommonCombo="LOTA06"></select>
												</td>
												<td GCol="text,ALOTA07"></td>
												<td GCol="text,ALOTA08"></td>
												<td GCol="text,ALOTA09"></td>
												<td GCol="text,ALOTA10"></td>
												<td GCol="input,ALOTA11" GF="C 8"></td>
												<td GCol="text,ALOTA12"></td>
												<td GCol="text,ALOTA13"></td>
												<td GCol="text,ALOTA14"></td>
												<td GCol="text,ALOTA15"></td>
												<td GCol="text,ALOTA16"></td>
												<td GCol="text,ALOTA17"></td>
												<td GCol="text,ALOTA18"></td>
												<td GCol="text,ALOTA19"></td>
												<td GCol="text,ALOTA20"></td>
												<td GCol="text,ADESC02"></td>
												<td GCol="text,AEANCOD"></td>
												<td GCol="text,AGTINCD"></td>
												<td GCol="text,ASKUG01"></td>
												<td GCol="text,ASKUG02"></td>
												<td GCol="text,ASKUG03"></td>
												<td GCol="text,ASKUG04"></td>
												<td GCol="text,ASKUG05"></td>
												<td GCol="text,AGRSWGT"></td>
												<td GCol="text,ANETWGT"></td>
												<td GCol="text,AAREAKY"></td>
												<td GCol="text,ABATMNG"></td>
												<td GCol="text,AASKU01"></td>
												<td GCol="text,AASKU02"></td>
												<td GCol="text,AASKU03"></td>
												<td GCol="text,AASKU04"></td>
												<td GCol="text,AASKU05"></td>
												<td GCol="input,AADJRSN" GF="S 255"></td>
											</tr>									
										</tbody>
									</table>
								</div>

							</div>
							<div class="tableUtil">
								<div class="leftArea">
									<button type="button" GBtn="find"></button>
									<button type="button" GBtn="sortReset"></button>
									<button type="button" GBtn="copy"></button>
									<button type="button" GBtn="layout"></button>
									<button type="button" GBtn="total"></button>
									<button type="button" GBtn="excel"></button>
								</div>
								<div class="rightArea">
									<p class="record" GInfoArea="true"></p>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
		<!-- //contentContainer -->
	</div>
</div>
<!-- //content -->
<%@ include file="/common/include/bottom.jsp" %>
</body>
</html>