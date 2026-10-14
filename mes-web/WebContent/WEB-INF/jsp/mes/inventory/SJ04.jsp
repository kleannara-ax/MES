<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/head.jsp" %>
<%
	User user = (User)request.getSession().getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
%>
<script type="text/javascript" src="/wms/js/wms.js"></script>
<script type="text/javascript">
	$(document).ready(function(){
		setTopSize(200);
		
		gridList.setGrid({
	    	id : "gridList",
	    	name : "gridList",
			editable : true,
			module : "WmsInventory",
			command : "SJ04"
	    });
		
		gridList.setGrid({
	    	id : "gridListSub",
	    	name : "gridListSub",
			editable : true,
			module : "WmsInventory",
			command : "SJ04Sub"
	    });
		$("#USERAREA").val("<%=user.getUserg5()%>");
		gridList.setReadOnly("gridListSub", true, ['ALOTA06']);
	});
	
	var searchType = true;
	
	function searchList(){
		searchType = true;
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			
			gridList.gridList({
		    	id : "gridListSub",
		    	param : param
		    });
		}
		uiList.setActive("Save", true);
		uiList.setActive("Reflect", true);
	}
	
	function gridListEventDataBindEnd(gridId, dataCount){
		if(gridId == "gridList"){
			uiList.setActive("Search", true);
		}/* else if(gridId == "gridListSub" && dataLength > 0){
			searchHeadList();
	} */else if(gridId == "gridListSub" && dataCount > 0 && searchType){
			uiList.setActive("Search", false);
			uiList.setActive("Save", true);
			uiList.setActive("Reflect", true);
			
			var param = inputList.setRangeParam("searchArea");
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });

			$("#arsnadjCombo").val("");
			
			gridList.setReadOnly("gridList", false);
			gridList.setReadOnly("gridListSub", false);
			gridList.setReadOnly("gridListSub", true, ['ALOTA06']);
		}
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId == "gridList"){
			uiList.setActive("Save", true);
		}else if(gridId == "gridListSub"){
			uiList.setActive("Reflect", true);	
			
			//지번 벨리데이션
			if (colName == "ALOCAKY") {
				var areaky = gridList.getColData(gridId, rowNum, "AREAKY");
				
				if(colValue != ""){
					var param = inputList.setRangeParam("searchArea");
					
					param.put("ALOCAKY", colValue);
					param.put("AREAKY", areaky);
					var json = netUtil.sendData({
						module : "WmsInventory",
						command : "LOCAKYval",
						sendType : "map",
						param : param
					});
					
					if (json.data["CNT"] < 1) {
						commonUtil.msgBox("VALID_M0204", colValue);	//" "는 존재하지 않는 지번입니다. 		
						
						gridList.setColValue("gridListSub", rowNum, "ALOCAKY", "");
						gridList.setFocus("gridListSub", "ALOCAKY");
					}
				}
			}
		}
	}
	
	function commonBtnClick(btnName){
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
		
		if(gridList.validationCheck("gridListSub", "select")){
			
			var docunum = wms.getDocSeq(gridList.getColData("gridList", 0, "ADJUTY"));
			gridList.gridColModify("gridList", 0, "SADJKY", docunum);

			var head = gridList.getRowData("gridList", 0);
			
			var list = gridList.getSelectModifyList("gridListSub");
			
			if(list.length == 0){
				commonUtil.msgBox("INV_M0055",docunum); //기존값과 동일합니다. 확인해주세요.
				return;
			}
			
			var param = new DataMap();
			
			param.put("head", head);
			param.put("list", list);
			
			var json = netUtil.sendData({
				url : "/wms/inventory/json/saveAdjd.data",
				param : param
			});
			
			if(json && json.data){
				
				commonUtil.msgBox("INV_M0010", docunum);  // 조정 문서 {0}은 생성이 성공하였습니다.
				
				searchType = false;
				
				var paramH = new DataMap();
				paramH.put("SADJKY", docunum);
				
				gridList.gridList({
			    	id : "gridList",
			    	command : "SJ04L",
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
		if(searchCode == "SHSKUMA"){
			var param = new DataMap();
			param.put("WAREKY", "<%= wareky%>");
			param.put("OWNRKY", "<%=ownrky%>");
			return param;
		}else if(searchCode == "SHCMCDV"){
			var param = new DataMap();
			param.put("CMCDKY", "LOTA06");
			return param;
		}else if(searchCode == "SHLOCMA"){
			var rowNum = gridList.getFocusRowNum("gridListSub");
			var areaky = gridList.getColData("gridListSub", rowNum, "AREAKY");
			var param = new DataMap();
			param.put("AREAKY",areaky);
			return param;
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
		</button>
	</div>
	<div class="util2">
		<button class="button type2" id="showPop" type="button"><img src="/common/images/ico_btn4.png" alt="List" /></button>
	</div>
</div>

<!-- searchPop -->
<div class="searchPop">
	<button type="button" class="closer">X</button>
	<div class="searchInnerContainer">
		<p class="util">
			<button CB="Search SEARCH BTN_DISPLAY"></button>
			<button CB="GetVariant GETVARIANT BTN_GETVARIANT"></button>
			<button CB="SaveVariant SAVEVARIANT BTN_SAVEVARIANT"></button>
		</p>
		<div class="searchInBox" id="searchArea">
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
							<input type="text" name="WAREKY"  value="<%=wareky%>" size="8px"  readonly="readonly"/>
						</td>
					</tr>
					<tr>
						<th CL="STD_OWNRKY">화주</th>
						<td>
							<select Combo="WmsOrder,OWNRKYCOMBO" name="OWNRKY" id="OWNRKY">
							</select>
						</td>
					</tr>
					<tr>
						<th CL="STD_AREAKY">창고</th>
						<td>
							<input type="text" name="S.AREAKY" id="AREAKY" UIInput="R,SHAREMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_ZONEKY"></th>
						<td>
							<input type="text" name="S.ZONEKY" id="ZONE" UIInput="R,SHZONMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_LOCAKY">지번</th>
						<td>
							<input type="text" name="S.LOCAKY" UIInput="R,SHLOCMA" />
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
			<h2 class="tit type1" CL="STD_SKUINFO">품목정보</h2>
			<table class="table type1">
				<colgroup>
					<col width="100" />
					<col />
				</colgroup>
				<tbody>
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
						<th CL="STD_DESC02">품명</th>
						<td>
							<input type="text" name="S.DESC02" UIInput="R" />
						</td>
					</tr>
				</tbody>
			</table>
		</div>
		<div class="searchInBox">
			<h2 class="tit type1" CL="STD_LOTINFO">LOT정보</h2>
			<table class="table type1">
				<colgroup>
					<col width="100" />
					<col />
				</colgroup>
				<tbody>
<!-- 					<tr> -->
<!-- 						<th CL="STD_LOTA01">업체코드</th> -->
<!-- 						<td> -->
<!-- 							<input type="text" name="S.LOTA01" UIInput="R" /> -->
<!-- 						</td> -->
<!-- 					</tr> -->
<!-- 					<tr> -->
<!-- 					<th CL="STD_LOTA02">부서코드</th> -->
<!-- 						<td> -->
<!-- 							<input type="text" name="S.LOTA02" UIInput="R" /> -->
<!-- 						</td> -->
<!-- 					</tr> -->
<!-- 					<tr> -->
<!-- 						<th CL="STD_LOTA03">개별바코드</th> -->
<!-- 						<td> -->
<!-- 							<input type="text" name="S.LOTA03" UIInput="R" /> -->
<!-- 						</td> -->
<!-- 					</tr> -->
<!-- 					<tr> -->
<!-- 						<th CL="STD_LOTA04">Mall PO번호</th> -->
<!-- 						<td> -->
<!-- 							<input type="text" name="S.LOTA04" UIInput="R" /> -->
<!-- 						</td> -->
<!-- 					</tr> -->
<!-- 					<tr> -->
<!-- 						<th CL="STD_LOTA05">Mall PO Item번호</th> -->
<!-- 						<td> -->
<!-- 							<input type="text" name="S.LOTA05" UIInput="R" /> -->
<!-- 						</td> -->
<!-- 					</tr> -->
<tr>
					<th CL="STD_LOTA10">프로젝트명</th>
						<td>
							<input type="text" name="S.LOTA10" UIInput="R" />
						</td>
					</tr>
					<tr>
						<th CL="STD_LOTA06">재고상태</th>
						<td>
							<input type="text" name="S.LOTA06" UIInput="R,SHCMCDV" />
						</td>
					</tr>
<!-- 					<tr> -->
<!-- 						<th CL="STD_LOTA07">Mall SD번호</th> -->
<!-- 						<td> -->
<!-- 							<input type="text" name="S.LOTA07" UIInput="R" /> -->
<!-- 						</td> -->
<!-- 					</tr> -->
<!-- 					<tr> -->
<!-- 						<th CL="STD_LOTA09">WMS PO번호</th> -->
<!-- 						<td> -->
<!-- 							<input type="text" name="S.LOTA09" UIInput="R" /> -->
<!-- 						</td> -->
<!-- 					</tr> -->
					<tr>
						<th CL="STD_LOTA11">제조일자</th>
						<td>
							<input type="text" name="S.LOTA11" UIInput="R" UIFormat="C" />
						</td>
					</tr>
					<tr>
						<th CL="STD_LOTA12">입고일자</th>
						<td>
							<input type="text" name="S.LOTA12" UIInput="R" UIFormat="C" />
						</td>
					</tr>
					<tr>
						<th CL="STD_LOTA13">유효기간</th>
						<td>
							<input type="text" name="S.LOTA13" UIInput="R" UIFormat="C" />
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
						<li><a href="#tabs1-1" CL="STD_GENERAL"><span></span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableBody">
									<table>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GH="40"					GCol="rownum">1</td>
												<td GH="100 STD_SADJKY"		GCol="text,SADJKY" /></td>
												<td GH="100 STD_WAREKY"		GCol="text,WAREKY" /></td>
												<td GH="100 STD_ADJUTY"		GCol="text,ADJUTY" /></td>
												<td GH="100 STD_DOCDAT"		GCol="input,DOCDAT"	GF="C 8"/></td>
												<td GH="100 STD_DOCCAT"		GCol="text,DOCCAT" /></td>
												<td GH="100 STD_DOCCATNM"	GCol="text,DOCCATNM" /></td>
												<td GH="100 STD_ADJUCA"		GCol="text,ADJUCA" /></td>
												<td GH="100 STD_ADJSTX"		GCol="text,ADJUCANM" /></td>
												<td GH="100 STD_DOCTXT"		GCol="input,DOCTXT"	GF="S 1000" /></td>
												<td GH="100 STD_CREDAT"		GCol="text,CREDAT"	GF="D" /></td>
												<td GH="100 STD_CRETIM"		GCol="text,CRETIM"	GF="T" /></td>
												<td GH="100 STD_CREUSR"		GCol="text,CREUSR" /></td>
												<td GH="100 STD_CUSRNM"		GCol="text,CUSRNM" /></td>
												<td GH="100 STD_LMODAT"		GCol="text,LMODAT"	GF="D" /></td>
												<td GH="100 STD_LMOTIM"		GCol="text,LMOTIM"	GF="T" /></td>
												<td GH="100 STD_LMOUSR"		GCol="text,LMOUSR" /></td>
												<td GH="100 STD_LUSRNM"		GCol="text,LUSRNM" /></td>
											</tr>									
										</tbody>
									</table>
								</div>

							</div>
							<div class="tableUtil">
								<div class="leftArea">
									<button type="button" GBtn="find"></button>
									<button type="button" GBtn="sortReset"></button>
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
						<li><a href="#tabs1-1" CL="STD_ADJLIST"><span>조정 가능 목록</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
								<table class="util">
									<tr>
										<th CL="STD_RSNADJ"></th>
										<td>
											&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
											<select ReasonCombo="430" id="arsnadjCombo">
												<option value=""> </option>
											</select>
										</td>
										<td>
											&nbsp;&nbsp;
											<button CB="Reflect REFLECT BTN_REFLECT">
											</button>
										</td>
									</tr>
								</table>
							<div class="table type2"  style="top:45px;">
								<div class="tableBody">
									<table>
										<tbody id="gridListSub">
										<tr CGRow="true">
												<td GH="40"					GCol="rownum">1</td>
												<td GH="40"					GCol="rowCheck">V</td>
												<td GH="100 STD_STOKKY"		GCol="text,STOKKY" /></td>
												<td GH="100 STD_LOTNUM"		GCol="text,LOTNUM" /></td>
												<td GH="100 STD_SECTID"		GCol="text,SECTID" /></td>
												<td GH="100 STD_PACKID"		GCol="text,PACKID" /></td>
												<td GH="100 STD_TRNUID"		GCol="text,TRNUID" /></td>
												<td GH="100 STD_TRUNTY"		GCol="text,TRUNTY" /></td>
												<td GH="100 STD_OWNRKY"		GCol="text,OWNRKY" /></td>
												<td GH="100 STD_AREAKY"		GCol="text,AREAKY" /></td>
												<td GH="100 STD_LOCAKY"		GCol="text,LOCAKY" /></td>
												<td GH="100 STD_SKUKEY"		GCol="text,SKUKEY" /></td>
												<td GH="100 STD_DESC01"		GCol="text,DESC01" /></td>
												<td GH="100 STD_DESC02"		GCol="text,DESC02" /></td>
												<td GH="100 STD_MEASKY"		GCol="text,MEASKY" /></td>
												<td GH="100 STD_DUOMKY"		GCol="text,DUOMKY" /></td>
												<td GH="100 STD_QTYUOM"		GCol="text,QTYUOM" 	GF="N" /></td>
												<td GH="100 STD_UOMKEY"		GCol="text,UOMKEY" /></td>
												<td GH="100 STD_QTPUOM"		GCol="text,QTPUOM" 	GF="N" /></td>
												<td GH="100 STD_QTDUOM"		GCol="text,QTDUOM" 	GF="N" /></td>
												<td GH="100 STD_QTSIWH"		GCol="text,QTSIWH" 	GF="N" /></td>
												<td GH="100 STD_USEQTY"		GCol="text,USEQTY" 	GF="N" /></td>
												<td GH="100 STD_QTSBLK"		GCol="text,QTSBLK" /></td>
												<td GH="100 STD_EANCOD"		GCol="text,EANCOD" /></td>
												<td GH="100 STD_GTINCD"		GCol="text,GTINCD" /></td>
												<td GH="100 STD_SKUG01"		GCol="text,SKUG01" /></td>
												<td GH="100 STD_SKUG02"		GCol="text,SKUG02" /></td>
												<td GH="100 STD_SKUG03"		GCol="text,SKUG03" /></td>
												<td GH="100 STD_SKUG04"		GCol="text,SKUG04" /></td>
												<td GH="100 STD_SKUG05"		GCol="text,SKUG05" /></td>
												<td GH="100 STD_GRSWGT"		GCol="text,GRSWGT" /></td>
												<td GH="100 STD_NETWGT"		GCol="text,NETWGT" /></td>
												<td GH="100 STD_BATMNG"		GCol="text,BATMNG" /></td>
												<td GH="100 STD_ASKU01"		GCol="text,ASKU01" /></td>
												<td GH="100 STD_ASKU02"		GCol="text,ASKU02" /></td>
												<td GH="100 STD_ASKU03"		GCol="text,ASKU03" /></td>
												<td GH="100 STD_ASKU04"		GCol="text,ASKU04" /></td>
												<td GH="100 STD_ASKU05"		GCol="text,ASKU05" /></td>
												<td GH="100 STD_STOKKY"		GCol="text,ASTOKKY" /></td>
												<td GH="100 STD_RSNADJ"		GCol="select,ARSNADJ" 	validate="required" />
												<select ReasonCombo="430">
														<option value=""> </option>
													</select>
												</td>
												<td GH="100 STD_LOTNUM"		GCol="text,ALOTNUM" /></td>
												<td GH="100 STD_LOCATG"		GCol="input,ALOCAKY,SHLOCMA" /></td>
												<td GH="100 STD_SECTID"		GCol="text,ASECTID" /></td>
												<td GH="100 STD_PACKID"		GCol="text,APACKID" /></td>
												<td GH="100 STD_ATRNUID"		GCol="input,ATRNUID" /></td>
												<td GH="100 STD_OWNRKY"		GCol="text,AOWNRKY" GF="S 255"/></td>
												<td GH="100 STD_SKUKEY"		GCol="text,ASKUKEY" /></td>
												<td GH="100 STD_TRUNTY"		GCol="text,ATRUNTY" /></td>
												<td GH="100 STD_MEASKY"		GCol="text,AMEASKY" /></td>
												<td GH="100 STD_QTADJU"		GCol="input,AQTADJU" validate="max(GRID_COL_AQTADJU_*),INV_M0024"	GF="N 20,3" /></td>
												<td GH="100 STD_DUOMKY"		GCol="text,ADUOMKY" /></td>
												<td GH="100 STD_QTYUOM"		GCol="text,AQTYUOM" /></td>
												<td GH="100 STD_UOMKEY"		GCol="text,AUOMKEY" /></td>
												<td GH="100 STD_QTPUOM"		GCol="text,AQTPUOM" GF="N" /></td>
												<td GH="100 STD_QTBLKD"		GCol="text,AQTBLKD" GF="N" /></td>
												<td GH="100 STD_DESC01"		GCol="text,ADESC01" /></td>
												<td GH="100 STD_LOTA01"		GCol="text,ALOTA01" /></td>
												<td GH="100 STD_LOTA02"		GCol="text,ALOTA02" /></td>
												<td GH="100 STD_LOTA02NM"	GCol="text,LOTA02NM" /></td>
												<td GH="100 STD_PTLT03"			GCol="input,ALOTA03" /></td>
												<td GH="100 STD_LOTA04"		GCol="input,ALOTA04" /></td>
												<td GH="100 STD_LOTA05"		GCol="input,ALOTA05" /></td>
												<td GH="100 STD_LOTA06_TO"	GCol="select,ALOTA06" /><select CommonCombo="LOTA06"></select>	</td>
												<td GH="100 STD_LOTA07"		GCol="text,ALOTA07" /></td>
												<td GH="100 STD_LOTA08"		GCol="text,ALOTA08" /></td>
												<td GH="100 STD_LOTA09"		GCol="text,ALOTA09" /></td>
												<td GH="100 STD_LOTA10"		GCol="input,ALOTA10" /></td>
												<td GH="100 STD_LOTA11_TO"	GCol="input,ALOTA11" GF="C"/></td>
												<td GH="100 STD_LOTA12"		GCol="input,ALOTA12" GF="C" /></td>
												<td GH="100 STD_LOTA13_TO"	GCol="input,ALOTA13" GF="C" /></td>
												<td GH="100 STD_LOTA14"		GCol="text,ALOTA14" /></td>
												<td GH="100 STD_LOTA15"		GCol="text,ALOTA15" /></td>
												<td GH="100 STD_LOTA16"		GCol="text,ALOTA16"	GF="N" /></td>
												<td GH="100 STD_LOTA17"		GCol="text,ALOTA17"	GF="N" /></td>
												<td GH="100 STD_LOTA18"		GCol="text,ALOTA18"	GF="N" /></td>
												<td GH="100 STD_LOTA19"		GCol="text,ALOTA19"	GF="N" /></td>
												<td GH="100 STD_LOTA20"		GCol="text,ALOTA20"	GF="N" /></td>
												<td GH="100 STD_DESC02"		GCol="text,ADESC02" /></td>
												<td GH="100 STD_EANCOD"		GCol="text,AEANCOD" /></td>
												<td GH="100 STD_GTINCD"		GCol="text,AGTINCD" /></td>
												<td GH="100 STD_SKUG01"		GCol="text,ASKUG01" /></td>
												<td GH="100 STD_SKUG02"		GCol="text,ASKUG02" /></td>
												<td GH="100 STD_SKUG03"		GCol="text,ASKUG03" /></td>
												<td GH="100 STD_SKUG04"		GCol="text,ASKUG04" /></td>
												<td GH="100 STD_SKUG05"		GCol="text,ASKUG05" /></td>
												<td GH="100 STD_GRSWGT"		GCol="text,AGRSWGT" /></td>
												<td GH="100 STD_NETWGT"		GCol="text,ANETWGT" /></td>
												<td GH="100 STD_AREAKY"		GCol="text,AAREAKY" /></td>
												<td GH="100 STD_BATMNG_1"	GCol="text,ABATMNG" /></td>
												<td GH="100 STD_ASKU01"		GCol="text,AASKU01" /></td>
												<td GH="100 STD_ASKU02"		GCol="text,AASKU02" /></td>
												<td GH="100 STD_MASKU03_1"	GCol="text,AASKU03" /></td>
												<td GH="100 STD_ASKU04"		GCol="text,AASKU04" /></td>
												<td GH="100 STD_ASKU05"		GCol="text,AASKU05" /></td>
												<td GH="100 STD_ADJRSN"		GCol="input,AADJRSN" GF="S 255"/></td>
											</tr>
										</tbody>
									</table>
								</div>
							</div>
							<div class="tableUtil">
								<div class="leftArea">
									<button type="button" GBtn="find"></button>
									<button type="button" GBtn="sortReset"></button>
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