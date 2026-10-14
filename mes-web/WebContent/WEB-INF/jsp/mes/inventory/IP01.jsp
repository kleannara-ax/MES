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
<script language="JavaScript" src="/common/js/ezgencontrol.js"> </script>
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
	    	name : "gridList",
			editable : true,
			module : "WmsInventory",
			command : "IP01"
	    });
		
		gridList.setGrid({
	    	id : "gridListSub",
	    	name : "gridListSub",
			editable : true,
			module : "WmsInventory",
			command : "IP01Sub"
	    });
		
		$("#USERAREA").val("<%=user.getUserg5()%>");
		gridList.setReadOnly("gridListSub", true, ['LOTA06']);
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
		uiList.setActive("Print", false);
		gridList.setReadOnly("gridList", false);
		gridList.setReadOnly("gridListSub", false);
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId == "gridList"){
			uiList.setActive("Save", true);
		}
	}
	
	function gridListEventDataBindEnd(gridId, dataCount){
		if(gridId == "gridList"){
			uiList.setActive("Search", true);
		}else if(gridId == "gridListSub" && dataCount>0 && searchType){
			uiList.setActive("Search", false);
			uiList.setActive("Save", true);
			
			var param = inputList.setRangeParam("searchArea");
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}
	
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}else if(btnName == "Print"){
			printList();
		}
	}
	
	function saveData(){		
	
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		}
		
		if(gridList.validationCheck("gridListSub", "all")){
			var docunum = wms.getDocSeq("510");
			gridList.gridColModify("gridList", 0, "PHYIKY", docunum);

			var head = gridList.getRowData("gridList", 0);
			
			var list = gridList.getSelectData("gridListSub");
			
			if(list.length == 0){
				commonUtil.msgBox("INV_M0055",docunum);
				return;
			}
			
			var param = new DataMap();
			
			param.put("head", head);
			param.put("list", list);
			
			var json = netUtil.sendData({
				url : "/wms/inventory/json/savePhyd.data",
				param : param
			});
			
			if(json && json.data){
				
				commonUtil.msgBox("INV_M0051", docunum);
				
				searchType = false;
				
				var paramH = new DataMap();
				paramH.put("PHYIKY", docunum);
				
				gridList.gridList({
			    	id : "gridList",
			    	command : "IP01L",
			    	param : paramH
			    });
				
				gridList.gridList({
			    	id : "gridListSub",
			    	command : "IP04M",
			    	param : paramH
			    });
				gridList.setReadOnly("gridList", true);
				gridList.setReadOnly("gridListSub", true);
			}		
			uiList.setActive("Save", false);
			uiList.setActive("Print", true);
		}		
	}
	
	function printList(){
		var url = "";
		var phyiky = "";
		
		//var list = gridList.getSelectRowNumList("gridList");
		//var list = gridList.getRowData("gridList", 0);
		var list = gridList.getGridData("gridList");
		//var listcnt = gridList.getGridDataCount("gridList");
		
		if(list.length < 1){
			commonUtil.msgBox("VALID_M0006");
			return;
		}
		
		var where =   "AND PHYIKY IN (" ;
		for(var i=0 ; i<list.length ; i++){
			phyiky = gridList.getColData("gridList", i, "PHYIKY");
			if(i>0){
				where += ", "
			}
			where += "'" + phyiky +"'";
		}
		where += ")";
		url = "/ezgen/physical_count_stock_list.ezg";
				
		var map = new DataMap();
		WriteEZgenElement(url, where, "", '<%= langky%>', map, 900, 650);	
		
	}	
	
	function searchHelpEventOpenBefore(searchCode, gridType, $inputObj){
		if(searchCode == "SHZONMA"){
			var param = inputList.setRangeParam("searchArea");
			param.put("AREAKY", param.get("AREA"));
			return param;
		}else if(searchCode == "SHLOCMA"){
			var param = inputList.setRangeParam("searchArea");
			param.put("AREAKY", param.get("AREA"));
			param.put("ZONEKY", param.get("ZONE"));
			return param;
		}else if(searchCode == "SHSKUMA"){
			var param = new DataMap();
			param.put("WAREKY", "<%= wareky%>");
			param.put("OWNRKY", "<%=ownrky%>");
			return param;
		}else if(searchCode == "SHCMCDV"){
			var param = new DataMap();
			param.put("CMCDKY", "LOTA06");
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
		<button CB="Print PRINT BTN_PRINT30">
		</button>	
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
							<input type="text" name="WAREKY" value="<%=wareky%>"  size="8px"  readonly="readonly"/>
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
							<input type="text" name="AREAKY" id="AREAKY" UIInput="R,SHAREMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_ZONEKY"></th>
						<td>
							<input type="text" name="ZONEKY" id="ZONE" UIInput="R,SHZONMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_LOCAKY">지번</th>
						<td>
							<input type="text" name="LOCAKY" UIInput="R,SHLOCMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_TRNUID">P/T ID</th>
						<td>
							<input type="text" name="TRNUID" UIInput="R" />
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
						<th CL="STD_SKUKEY">품번코드</th>
						<td>
							<input type="text" name="SKUKEY" UIInput="R,SHSKUMA_L" />
						</td>
					</tr>
					<tr>
						<th CL="STD_DESC01">품명</th>
						<td>
							<input type="text" name="DESC01" UIInput="R" />
						</td>
					</tr>
					<tr>
						<th CL="STD_DESC02">규격</th>
						<td>
							<input type="text" name="DESC02" UIInput="R" />
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
<!-- 				<tr> -->
<!-- 					<th CL="STD_LOTA01">업체코드</th> -->
<!-- 					<td> -->
<!-- 						<input type="text" name="LOTA01" UIInput="R" /> -->
<!-- 					</td> -->
<!-- 				</tr> -->
<!-- 				<tr> -->
<!-- 					<th CL="STD_LOTA02">부서코드</th> -->
<!-- 					<td> -->
<!-- 						<input type="text" name="LOTA02" UIInput="R"  /> -->
<!-- 					</td> -->
<!-- 				</tr> -->
<!-- 				<tr> -->
<!-- 					<th CL="STD_LOTA03">개별바코드</th> -->
<!-- 					<td> -->
<!-- 						<input type="text" name="LOTA03" UIInput="R" /> -->
<!-- 					</td> -->
<!-- 				</tr> -->
<!-- 				<tr> -->
<!-- 					<th CL="STD_LOTA04">Mall PO번호</th> -->
<!-- 					<td> -->
<!-- 						<input type="text" name="LOTA04" UIInput="R" /> -->
<!-- 					</td> -->
<!-- 				</tr> -->
<!-- 				<tr> -->
<!-- 					<th CL="STD_LOTA05">Mall PO Item번호</th> -->
<!-- 					<td> -->
<!-- 						<input type="text" name="LOTA05" UIInput="R" /> -->
<!-- 					</td> -->
<!-- 				</tr> -->
				<tr>
					<th CL="STD_LOTA06">재고상태</th>
					<td>
						<input type="text" name="LOTA06" UIInput="R,SHCMCDV" />
					</td>
				</tr>
<!-- 				<tr> -->
<!-- 					<th CL="STD_LOTA07">Mall SD번호</th> -->
<!-- 					<td> -->
<!-- 						<input type="text" name="LOTA07" UIInput="R" /> -->
<!-- 					</td> -->
<!-- 				</tr> -->
<!-- 				<tr> -->
<!-- 					<th CL="STD_LOTA09">WMS PO번호</th> -->
<!-- 					<td> -->
<!-- 						<input type="text" name="LOTA09" UIInput="R" /> -->
<!-- 					</td> -->
<!-- 				</tr> -->
				<tr>
					<th CL="STD_LOTA11">제조일자</th>
					<td>
						<input type="text" name="LOTA11" UIInput="R" UIFormat="C" />
					</td>
				</tr>
				<tr>
					<th CL="STD_LOTA12">입고일자</th>
					<td>
						<input type="text" name="LOTA12" UIInput="R" UIFormat="C" />
					</td>
				</tr>
				<tr>
					<th CL="STD_LOTA13">유효기간</th>
					<td>
						<input type="text" name="LOTA13" UIInput="R" UIFormat="C" />
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
						<li><a href="#tabs1-1" CL="STD_GENERAL"><span>일반</span></a></li>
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
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<th CL='STD_PHYIKY'></th>
												<th CL='STD_WAREKY'></th>
												<th CL='STD_DOCCAT'></th>
												<th CL='STD_PHSCTY'></th>
												<th CL='STD_DOCCATNM'></th>
												<th CL='STD_DOCDAT'></th>
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
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<td GCol="text,PHYIKY"></td>
												<td GCol="text,WAREKY"></td>
												<td GCol="text,DOCCAT"></td>
												<td GCol="text,PHSCTY"></td>
												<td GCol="text,DOCCATNM"></td>
												<td GCol="input,DOCDAT" GF="C 8"></td>
												<td GCol="input,DOCTXT" GF="S 1000"></td>
												<td GCol="text,CREDAT" GF="D"></td>
												<td GCol="text,CRETIM" GF="T"></td>
												<td GCol="text,CREUSR"></td>
												<td GCol="text,CUSRNM"></td>
												<td GCol="text,LMODAT" GF="D"></td>
												<td GCol="text,LMOTIM" GF="T"></td>
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
							<div class="table type2">
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
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<th GBtnCheck="true"></th>
												<th CL='STD_PHYIKY'></th>
												<th CL='STD_PHYIIT'></th>
												<th CL='STD_STOKKY'></th>
												<th CL='STD_LOTNUM'></th>
												<th CL='STD_LOCAKY'></th>
												<th CL='STD_TRNUID'></th>
												<th CL='STD_SECTID'></th>
												<th CL='STD_PACKID'></th>
												<th CL='STD_QTYUOM'></th>
												<th CL='STD_TRUNTY'></th>
												<th CL='STD_MEASKY'></th>
												<th CL='STD_UOMKEY'></th>
												<th CL='STD_QTADJU'></th>
												<th CL='STD_QTYPDA'></th>
												<th CL='STD_QTPUOM'></th>
												<th CL='STD_DUOMKY'></th>
												<th CL='STD_QTDUOM'></th>
												<th CL='STD_SUBSIT'></th>
												<th CL='STD_SUBSFL'></th>
												<th CL='STD_REFDKY'></th>
												<th CL='STD_REFDIT'></th>
												<th CL='STD_REFCAT'></th>
												<th CL='STD_OWNRKY'></th>
												<th CL='STD_SKUKEY'></th>
												<th CL='STD_LOTA01'></th>
												<th CL='STD_LOTA02'></th>
												<th CL='STD_LOTA02NM'></th>
												<th CL='STD_LOTA03'></th>
												<th CL='STD_LOTA04'></th>
												<th CL='STD_LOTA05'></th>
												<th CL='STD_LOTA06'></th>
												<th CL='STD_LOTA07'></th>
												<th CL='STD_LOTA08'></th>
												<th CL='STD_LOTA09'></th>
												<th CL='STD_LOTA10'></th>
												<th CL='STD_LOTA11'></th>
												<th CL='STD_LOTA12'></th>
												<th CL='STD_LOTA13'></th>
												<th CL='STD_LOTA14'></th>
												<th CL='STD_LOTA15'></th>
												<th CL='STD_LOTA16'></th>
												<th CL='STD_LOTA17'></th>
												<th CL='STD_LOTA18'></th>
												<th CL='STD_LOTA19'></th>
												<th CL='STD_LOTA20'></th>
												<th CL='STD_AREAKY'></th>
												<th CL='STD_ZONEKY'></th>
												<th CL='STD_DESC01'></th>
												<th CL='STD_SKUG01'></th>
												<th CL='STD_QTYSTL'></th>
												<th CL='STD_QTSIWH'></th>
												<th CL='STD_USEQTY'></th>
												<th CL='STD_QTSALO'></th>
												<th CL='STD_QTSPMI'></th>
												<th CL='STD_QTSPMO'></th>
												<th CL='STD_QTSBLK'></th>
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
										</colgroup>
										<tbody id="gridListSub">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<td GCol="rowCheck"></td>
												<td GCol="text,PHYIKY"></td>
												<td GCol="text,PHYIIT"></td>
												<td GCol="text,STOKKY"></td>
												<td GCol="text,LOTNUM"></td>
												<td GCol="text,LOCAKY"></td>
												<td GCol="text,TRNUID"></td>
												<td GCol="text,SECTID"></td>
												<td GCol="text,PACKID"></td>
												<td GCol="text,QTYUOM" GF="N"></td>
												<td GCol="text,TRUNTY"></td>
												<td GCol="text,MEASKY"></td>
												<td GCol="text,UOMKEY"></td>
												<td GCol="text,QTADJU" GF="N"></td>
												<td GCol="text,QTYPDA" GF="N"></td>
												<td GCol="text,QTPUOM" GF="N"></td>
												<td GCol="text,DUOMKY"></td>
												<td GCol="text,QTDUOM" GF="N"></td>
												<td GCol="text,SUBSIT"></td>
												<td GCol="text,SUBSFL"></td>
												<td GCol="text,REFDKY"></td>
												<td GCol="text,REFDIT"></td>
												<td GCol="text,REFCAT"></td>
												<td GCol="text,OWNRKY"></td>
												<td GCol="text,SKUKEY"></td>
												<td GCol="text,LOTA01"></td>
												<td GCol="text,LOTA02"></td>
												<td GCol="text,LOTA02NM"></td>
												<td GCol="text,LOTA03"></td>
												<td GCol="text,LOTA04"></td>
												<td GCol="text,LOTA05"></td>
												<td GCol="select,LOTA06">
													<select CommonCombo="LOTA06"></select>
												</td>
												<td GCol="text,LOTA07"></td>
												<td GCol="text,LOTA08"></td>
												<td GCol="text,LOTA09"></td>
												<td GCol="text,LOTA10"></td>
												<td GCol="text,LOTA11" GF="D"></td>
												<td GCol="text,LOTA12" GF="D"></td>
												<td GCol="text,LOTA13" GF="D"></td>
												<td GCol="text,LOTA14"></td>
												<td GCol="text,LOTA15"></td>
												<td GCol="text,LOTA16" GF="N"></td>
												<td GCol="text,LOTA17" GF="N"></td>
												<td GCol="text,LOTA18" GF="N"></td>
												<td GCol="text,LOTA19" GF="N"></td>
												<td GCol="text,LOTA20" GF="N"></td>
												<td GCol="text,AREAKY"></td>
												<td GCol="text,ZONEKY"></td>
												<td GCol="text,DESC01"></td>
												<td GCol="text,SKUG01"></td>
												<td GCol="text,QTYSTL" GF="N"></td>
												<td GCol="text,QTSIWH" GF="N"></td>
												<td GCol="text,USEQTY" GF="N"></td>
												<td GCol="text,QTSALO" GF="N"></td>
												<td GCol="text,QTSPMI" GF="N"></td>
												<td GCol="text,QTSPMO" GF="N"></td>
												<td GCol="text,QTBLKD" GF="N"></td>
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