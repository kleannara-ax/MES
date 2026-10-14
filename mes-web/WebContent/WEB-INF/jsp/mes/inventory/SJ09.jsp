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
<script type="text/javascript">
	$(document).ready(function(){
		setTopSize(270);
		gridList.setGrid({
	    	id : "gridList",
			editable : true,
			module : "WmsInventory",
			command : "SJ09",
			itemGrid : "gridListSub",
			itemSearch : true
	    });
		
		gridList.setGrid({
	    	id : "gridListSub",
			editable : true,
			module : "WmsInventory",
			command : "SJ09Sub"
	    });
		$("#USERAREA").val("<%=user.getUserg5()%>");
		gridList.setReadOnly("gridListSub", true, ['LOTA06']);
	});
	
	function gridListEventItemGridSearch(gridId, rowNum, itemGridList){
		if(gridId == "gridList"){
	        var rowData = gridList.getRowData(gridId, rowNum);
	        var param = inputList.setRangeParam("searchArea");
	        param.putAll(rowData);
	        
	        gridList.gridList({
	           id : "gridListSub",
	           param : param
	        });
		}
	}
	
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			
			/* var json = netUtil.sendData({
				module : "WmsInbound",
				command : "AREAKYval",
				sendType : "map",
				param : param
			});
			
			if(json.data["CNT"] <= 0) {
				commonUtil.msgBox("MASTER_M0048");
				$("#searchArea").find("[name=AREA]").val("").focus();
				return;
			} */
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });		
		}
		gridList.setReadOnly("gridListSub", true, ['LOTA06']);
	}
	
	/* function gridListEventDataBindEnd(gridId, dataLength){
		if(gridId == "gridList" && dataLength > 0){
			searchSubList(0);
		}
	}
	
	function searchSubList(headRowNum){
		var data = gridList.getRowData("gridList", headRowNum);
		var param = new DataMap();
		param.put("SADJKY", data.get("SADJKY"));
		
		gridList.gridList({
	    	id : "gridListSub",
	    	command : "SJ09Sub",
	    	param : param
	    });

		lastFocusNum = rowNum;
	}
	
	function gridListEventRowDblclick(gridId, rowNum){
		if(gridId == "gridList"){
			if(gridList.getColData("gridList", rowNum, "STATUS") == "C"){
				return false;
			}
			dblIdx = rowNum;
			searchSubList(rowNum);
		}
	}
	
	function gridListEventRowFocus(gridId, rowNum){
		if(gridId == "gridList"){
			var modRowCnt = gridList.getModifyRowCount("gridListSub");
			if(modRowCnt == 0){
				if(dblIdx != rowNum){
					gridList.resetGrid("gridListSub");
					dblIdx = -1;
				}
			}
		}
	} */
	
	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}
	}
	
	function searchHelpEventOpenBefore(searchCode, gridType, $inputObj){
		if(searchCode == "SHZONMA"){
			var param = inputList.setRangeParam("searchArea");
			param.put("AREAKY", param.get("AREA"));
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
	
	function gridExcelDownloadEventBefore(gridId){
		var param = inputList.setRangeParam("searchArea");
		if(gridId == "gridListSub"){
			var rowNum = gridList.getFocusRowNum("gridList");
			var sadjky = gridList.getColData("gridList", rowNum, "SADJKY");
		
			param.put("SADJKY",sadjky);
		}
		return param;
	}
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY">
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
							<input type="text" name="WAREKY" size="8px" value="<%=wareky%>" readonly="readonly" />
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
							<input type="text" name="I.ZONEKY" id="ZONE" UIInput="R,SHZONMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_LOCAKY">지번</th>
						<td>
							<input type="text" name="I.LOCAKY" UIInput="R,SHLOCMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_TRNUID">팔레트ID</th>
						<td>
							<input type="text" name="TRNUID" UIInput="R"/>
						</td>
					</tr>
				</tbody>
			</table>
		</div>
		<div class="searchInBox">
			<h2 class="tit type1" CL="STD_DOCUMENTINFO">문서정보</h2>
			<table class="table type1">
				<colgroup>
					<col width="100" />   
					<col />
				</colgroup>
				<tbody>
					<tr>
						<th CL="STD_SADJKY">조정문서번호</th>
						<td>
							<input type="text" name="I.SADJKY" UIInput="R" />
						</td>
					</tr>
					<tr>
						<th CL="STD_ADJDAT">조정일자</th>
						<td>
							<input type="text" name="I.CREDAT" UIInput="R" UIFormat="C" />
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
							<input type="text" name="I.SKUKEY" UIInput="R,SHSKUMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_DESC01">품명</th>
						<td>
							<input type="text" name="I.DESC01" UIInput="R" />
						</td>
					</tr>
					<tr>
						<th CL="STD_DESC02">규격</th>
						<td>
							<input type="text" name="I.DESC02" UIInput="R" />
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
<!-- 						<input type="text" name="I.LOTA01" UIInput="R" /> -->
<!-- 					</td> -->
<!-- 				</tr> -->
<!-- 				<tr> -->
<!-- 					<th CL="STD_LOTA02">부서코드</th> -->
<!-- 					<td> -->
<!-- 						<input type="text" name="I.LOTA02" UIInput="R" /> -->
<!-- 					</td> -->
<!-- 				</tr> -->
<!-- 				<tr> -->
<!-- 					<th CL="STD_LOTA03">개별바코드</th> -->
<!-- 					<td> -->
<!-- 						<input type="text" name="I.LOTA03" UIInput="R" /> -->
<!-- 					</td> -->
<!-- 				</tr> -->
<!-- 				<tr> -->
<!-- 					<th CL="STD_LOTA04">Mall PO번호</th> -->
<!-- 					<td> -->
<!-- 						<input type="text" name="I.LOTA04" UIInput="R" /> -->
<!-- 					</td> -->
<!-- 				</tr> -->
<!-- 				<tr> -->
<!-- 					<th CL="STD_LOTA05">Mall PO Item번호</th> -->
<!-- 					<td> -->
<!-- 						<input type="text" name="I.LOTA05" UIInput="R" /> -->
<!-- 					</td> -->
<!-- 				</tr> -->
				<tr>
					<th CL="STD_LOTA06">재고상태</th>
					<td>
						<input type="text" name="I.LOTA06" UIInput="R,SHCMCDV" />
					</td>
				</tr>
<!-- 				<tr> -->
<!-- 					<th CL="STD_LOTA07">Mall SD번호</th> -->
<!-- 					<td> -->
<!-- 						<input type="text" name="I.LOTA07" UIInput="R" /> -->
<!-- 					</td> -->
<!-- 				</tr> -->
<!-- 				<tr> -->
<!-- 					<th CL="STD_LOTA09">WMS PO번호</th> -->
<!-- 					<td> -->
<!-- 						<input type="text" name="I.LOTA09" UIInput="R" /> -->
<!-- 					</td> -->
<!-- 				</tr> -->
				<tr>
					<th CL="STD_LOTA11">제조일자</th>
					<td>
						<input type="text" name="I.LOTA11" UIInput="R" UIFormat="C" />
					</td>
				</tr>
				<tr>
					<th CL="STD_LOTA12">입고일자</th>
					<td>
						<input type="text" name="I.LOTA12" UIInput="R" UIFormat="C" />
					</td>
				</tr>
				<tr>
					<th CL="STD_LOTA13">유효기간</th>
					<td>
						<input type="text" name="I.LOTA13" UIInput="R" UIFormat="C" />
					</td>
				</tr>
				<!-- 	<tr>
						<th CL="STD_ADJDAT">조정일자</th>
						<td>
							<input type="text" name="I.CREDAT" UIInput="R" UIFormat="C" />
						</td>
					</tr> -->
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
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<th CL='STD_SADJKY'></th>
												<th CL='STD_WAREKY'></th>
												<th CL='STD_ADJUTY'></th>
												<th CL='STD_ADJDSC'></th>
												<th CL='STD_DOCDAT'></th>
												<th CL='STD_DOCCAT'></th>
												<th CL='STD_DOCCATNM'></th>
												<th CL='STD_ADJUCA'></th>
												<th CL='STD_ADJUCANM'></th>
												<th CL='STD_DOCTXT'></th>
												<th CL='STD_CREUSR'></th>
												<th CL='STD_CREDAT'></th>
												<th CL='STD_CRETIM'></th>
												<th CL='STD_CUSRNM'></th>
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
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<td GCol="text,SADJKY"></td>
												<td GCol="text,WAREKY"></td>
												<td GCol="text,ADJUTY"></td>
												<td GCol="text,ADJDSC"></td>
												<td GCol="text,DOCDAT" GF="D"></td>
												<td GCol="text,DOCCAT"></td>
												<td GCol="text,DOCCATNM"></td>
												<td GCol="text,ADJUCA"></td>
												<td GCol="text,ADJUCANM"></td>
												<td GCol="text,DOCTXT"></td>
												<td GCol="text,CREUSR"></td>
												<td GCol="text,CREDAT" GF="D"></td>
												<td GCol="text,CRETIM" GF="T"></td>
												<td GCol="text,CUSRNM"></td>
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
					<ul class="tab type2"  id="commonMiddleArea">
						<li><a href="#tabs1-1" CL="STD_ADJLIST"><span>조정 가능 목록</span></a></li>
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
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
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
												<th CL='STD_SADJIT'></th>
												<th CL='STD_RSNADJ'></th>
												<th CL='STD_STOKKY'></th>
												<th CL='STD_LOTNUM'></th>
												<th CL='STD_LOCAKY'></th>
												<th CL='STD_TRNUID'></th>
												<th CL='STD_SECTID'></th>
												<th CL='STD_PACKID'></th>
												<th CL='STD_QTADJU'></th>
												<th CL='STD_QTBLKD'></th>
												<th CL='STD_QTYUOM'></th>
												<th CL='STD_TRUNTY'></th>
												<th CL='STD_MEASKY'></th>
												<th CL='STD_UOMKEY'></th>
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
												<th CL='STD_AWMSNO'></th>
												<th CL='STD_AREAKY'></th>
												<th CL='STD_DESC01'></th>
												<th CL='STD_DESC02'></th>
												<th CL='STD_ASKU01'></th>
												<th CL='STD_ASKU02'></th>
												<th CL='STD_ASKU03'></th>
												<th CL='STD_ASKU04'></th>
												<th CL='STD_ASKU05'></th>
												<th CL='STD_EANCOD'></th>
												<th CL='STD_GTINCD'></th>
												<th CL='STD_SKUG01'></th>
												<th CL='STD_SKUG02'></th>
												<th CL='STD_SKUG03'></th>
												<th CL='STD_SKUG04'></th>
												<th CL='STD_SKUG05'></th>
												<th CL='STD_GRSWGT'></th>
												<th CL='STD_NETWGT'></th>
												<th CL='STD_WGTUNT'></th>
												<th CL='STD_LENGTH'></th>
												<th CL='STD_WIDTHW'></th>
												<th CL='STD_HEIGHT'></th>
												<th CL='STD_CUBICM'></th>
												<th CL='STD_CAPACT'></th>
												<!-- <th CL='STD_WORKID'></th>
												<th CL='STD_WORKNM'></th>
												<th CL='STD_HHTTID'></th> -->
												<th CL='STD_SMANDT'></th>
												<th CL='STD_SEBELN'></th>
												<th CL='STD_SEBELP'></th>
												<th CL='STD_SZMBLNO'></th>
												<th CL='STD_SZMIPNO'></th>
												<th CL='STD_STRAID'></th>
												<th CL='STD_SVBELN'></th>
												<th CL='STD_SPOSNR'></th>
												<th CL='STD_STKNUM'></th>
												<th CL='STD_STPNUM'></th>
												<th CL='STD_SWERKS'></th>
												<th CL='STD_SLGORT'></th>
												<th CL='STD_SDATBG'></th>
												<th CL='STD_STDLNR'></th>
												<th CL='STD_SMBLNR'></th>
												<th CL='STD_SZEILE'></th>
												<th CL='STD_SMJAHR'></th>
												<th CL='STD_SXBLNR'></th>
												<th CL='STD_SAPSTS'></th>
												<th CL='STD_ADJRSN'></th>
												<th CL='STD_RSNCDNM'></th>
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
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
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
												<td GCol="text,SADJKY"></td>
												<td GCol="text,SADJIT"></td>
												<td GCol="text,RSNADJ"></td>
												<td GCol="text,STOKKY"></td>
												<td GCol="text,LOTNUM"></td>
												<td GCol="text,LOCAKY"></td>
												<td GCol="text,TRNUID"></td>
												<td GCol="text,SECTID"></td>
												<td GCol="text,PACKID"></td>
												<td GCol="text,QTADJU" GF="N"></td>
												<td GCol="text,QTBLKD" GF="N"></td>
												<td GCol="text,QTYUOM" GF="N"></td>
												<td GCol="text,TRUNTY"></td>
												<td GCol="text,MEASKY"></td>
												<td GCol="text,UOMKEY"></td>
												<td GCol="text,QTPUOM" GF="N"></td>
												<td GCol="text,DUOMKY"></td>
												<td GCol="text,QTDUOM"></td>
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
												<td GCol="text,AWMSNO"></td>
												<td GCol="text,AREAKY"></td>
												<td GCol="text,DESC01"></td>
												<td GCol="text,DESC02"></td>
												<td GCol="text,ASKU01"></td>
												<td GCol="text,ASKU02"></td>
												<td GCol="text,ASKU03"></td>
												<td GCol="text,ASKU04"></td>
												<td GCol="text,ASKU05"></td>
												<td GCol="text,EANCOD"></td>
												<td GCol="text,GTINCD"></td>
												<td GCol="text,SKUG01"></td>
												<td GCol="text,SKUG02"></td>
												<td GCol="text,SKUG03"></td>
												<td GCol="text,SKUG04"></td>
												<td GCol="text,SKUG05"></td>
												<td GCol="text,GRSWGT"></td>
												<td GCol="text,NETWGT"></td>
												<td GCol="text,WGTUNT"></td>
												<td GCol="text,LENGTH"></td>
												<td GCol="text,WIDTHW"></td>
												<td GCol="text,HEIGHT"></td>
												<td GCol="text,CUBICM"></td>
												<td GCol="text,CAPACT"></td>
												<!-- <td GCol="text,WORKID"></td>
												<td GCol="text,WORKNM"></td>
												<td GCol="text,HHTTID"></td> -->
												<td GCol="text,SMANDT"></td>
												<td GCol="text,SEBELN"></td>
												<td GCol="text,SEBELP"></td>
												<td GCol="text,SZMBLNO"></td>
												<td GCol="text,SZMIPNO"></td>
												<td GCol="text,STRAID"></td>
												<td GCol="text,SVBELN"></td>
												<td GCol="text,SPOSNR"></td>
												<td GCol="text,STKNUM"></td>
												<td GCol="text,STPNUM"></td>
												<td GCol="text,SWERKS"></td>
												<td GCol="text,SLGORT"></td>
												<td GCol="text,SDATBG"></td>
												<td GCol="text,STDLNR"></td>
												<td GCol="text,SMBLNR"></td>
												<td GCol="text,SZEILE"></td>
												<td GCol="text,SMJAHR"></td>
												<td GCol="text,SXBLNR"></td>
												<td GCol="text,SAPSTS"></td>
												<td GCol="text,ADJRSN"></td>
												<td GCol="text,RSNCDNM"></td>
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