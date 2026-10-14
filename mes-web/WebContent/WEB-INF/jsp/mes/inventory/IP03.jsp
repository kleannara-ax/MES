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
<script language="JavaScript" src="/common/js/ezgencontrol.js"> </script>
<script type="text/javascript">
    var dblIdx = -1;
	$(document).ready(function(){
		setTopSize(300);
		gridList.setGrid({
	    	id : "gridList",
	    	name : "gridList",
			editable : true,
			module : "WmsInventory",
			command : "IP03"
	    });
		
		gridList.setGrid({
	    	id : "gridListSub",
	    	name : "gridListSub",
			editable : true,
			module : "WmsInventory",
			command : "IP03Sub"
	    });
		$("#USERAREA").val("<%=user.getUserg5()%>");
	});
	
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
		gridList.setReadOnly("gridListSub", true, ['LOTA06']);
	}
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if(gridId == "gridList" && dataLength > 0){
			searchSubList(0);
		}
	}
	
	function searchSubList(headRowNum){
		var data = gridList.getRowData("gridList", headRowNum);
		var param = new DataMap();
		param.put("PHYIKY", data.get("PHYIKY"));
		
		gridList.gridList({
	    	id : "gridListSub",
	    	param : param
	    });

		lastFocusNum = headRowNum;
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
	}
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Print"){
			printList();
		}
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
	
	function printList(){
		var url = "";
		var phyiky = "";
		
		var list = gridList.getSelectRowNumList("gridList", true);
		//var listcnt = gridList.getGridDataCount("gridList");
		
		/* if(listcnt < 1){
			commonUtil.msgBox("VALID_M0006");
			return;
		} */
		if(list.length < 1){
			commonUtil.msgBox("VALID_M0006");
			return;
		}

		var where =   "AND PHYIKY IN (" ;
		//for(var i=0 ; i<listcnt ; i++){
		for(var i=0 ; i<list.length ; i++){
			phyiky = gridList.getColData("gridList", list[i], "PHYIKY");		
			if(i>0){
				where += ", "
			}
			where += "'" + phyiky +"'";
		}
		where += ")";

		url = "/ezgen/physical_count_difference_list.ezg";
				
		var map = new DataMap();
		WriteEZgenElement(url, where, "", '<%= langky%>', map, 900, 650);	
		
	}		
	
	function gridExcelDownloadEventBefore(gridId){
		var param = inputList.setRangeParam("searchArea");
		if(gridId == "gridListSub"){
			var rowNum = gridList.getFocusRowNum("gridList");
			var phyiky = gridList.getColData("gridList", rowNum, "PHYIKY");
		
			param.put("PHYIKY",phyiky);
		}
		return param;
	}
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY"></button>
		<button CB="Print PRINT BTN_PRINT31"></button>			
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
							<input type="text" name="I.AREAKY" id="AREAKY" UIInput="R,SHAREMA" />
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
							<input type="text" name="I.LOCAKY" UIInput="R,SHLOCMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_TRNUID">팔레트ID</th>
						<td>
							<input type="text" name="I.TRNUID" UIInput="R" />
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
					<th CL="STD_PHYIKY">실사문서번호</th>
					<td>
						<input type="text" name="H.PHYIKY" UIInput="R" />
					</td>
				</tr>
				<tr>
					<th CL="STD_DOCDAT">문서일자</th>
					<td>
						<input type="text" name="DOCDAT" UIInput="R" UIFormat="C" />
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
<!-- 					<tr> -->
<!-- 						<th CL="STD_LOTA01">업체코드</th> -->
<!-- 						<td> -->
<!-- 							<input type="text" name="I.LOTA01" UIInput="R" /> -->
<!-- 						</td> -->
<!-- 					</tr> -->
<!-- 					<tr> -->
<!-- 						<th CL="STD_LOTA02">부서코드</th> -->
<!-- 						<td> -->
<!-- 							<input type="text" name="I.LOTA02" UIInput="R" /> -->
<!-- 						</td> -->
<!-- 					</tr> -->
<!-- 					<tr> -->
<!-- 						<th CL="STD_LOTA03">개별바코드</th> -->
<!-- 						<td> -->
<!-- 							<input type="text" name="I.LOTA03" UIInput="R" /> -->
<!-- 						</td> -->
<!-- 					</tr> -->
<!-- 					<tr> -->
<!-- 						<th CL="STD_LOTA04">Mall PO번호</th> -->
<!-- 						<td> -->
<!-- 							<input type="text" name="I.LOTA04" UIInput="R" /> -->
<!-- 						</td> -->
<!-- 					</tr> -->
<!-- 					<tr> -->
<!-- 						<th CL="STD_LOTA05">Mall PO Item번호</th> -->
<!-- 						<td> -->
<!-- 							<input type="text" name="I.LOTA05" UIInput="R" /> -->
<!-- 						</td> -->
<!-- 					</tr> -->
					<tr>
						<th CL="STD_LOTA06">재고상태</th>
						<td>
							<input type="text" name="I.LOTA06" UIInput="R,SHCMCDV" />
						</td>
					</tr>
<!-- 					<tr> -->
<!-- 						<th CL="STD_LOTA07">Mall SD번호</th> -->
<!-- 						<td> -->
<!-- 							<input type="text" name="I.LOTA07" UIInput="R" /> -->
<!-- 						</td> -->
<!-- 					</tr> -->
<!-- 					<tr> -->
<!-- 						<th CL="STD_LOTA09">WMS PO번호</th> -->
<!-- 						<td> -->
<!-- 							<input type="text" name="I.LOTA09" UIInput="R" /> -->
<!-- 						</td> -->
<!-- 					</tr> -->
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
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<th GBtnCheck="true"></th>
												<!-- <th CL='STD_ENDCK'></th> -->
												<th CL='STD_PHYIKY'></th>
												<th CL='STD_WAREKY'></th>
												<!-- <th CL='STD_ADJUTY'></th> -->
												<th CL='STD_DOCDAT'></th>
												<th CL='STD_DOCCAT'></th>
												<th CL='STD_ADJUTYNM'></th>
												<!-- <th CL='STD_ADJUCA'></th> -->
												<th CL='STD_CREDAT'></th>
												<th CL='STD_CRETIM'></th>
												<th CL='STD_CREUSR'></th>
												<th CL='STD_DOCTXT'></th>
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="40" />
											<col width="40" />
											<!-- <col width="100" /> -->
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<!-- <col width="100" /> -->
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<td GCol="rowCheck"></td>
												<!-- <td GCol="text,INDDCL"></td> -->
												<td GCol="text,PHYIKY"></td>
												<td GCol="text,WAREKY"></td>
												<!-- <td GCol="text,ADJUTY"></td> -->
												<td GCol="text,DOCDAT" GF="D"></td>
												<td GCol="text,DOCCAT"></td>
												<td GCol="text,DOCCATNM"></td>
												<!-- <td GCol="text,ADJUCA"></td> -->
												<td GCol="text,CREDAT" GF="D"></td>
												<td GCol="text,CRETIM" GF="T"></td>
												<td GCol="text,CREUSR"></td>
												<td GCol="text,DOCTXT"></td>
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
											<col width="100" />
											<col width="100" />
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
												<th CL='STD_PHYIKY'></th>               <!-- 재고조사번호 -->
												<th CL='STD_SADJIT,2'></th>             <!-- 조정Item -->
												<th CL='STD_RSNADJ'></th>               <!-- 조정사유코드 -->
												<th CL='STD_STOKKY'></th>               <!-- 재고키 -->
												<th CL='STD_LOTNUM,2'></th>             <!-- Lot number -->
												<th CL='STD_LOCAKY'></th>               <!-- 지번 -->
												<th CL='STD_TRNUID,2'></th>             <!-- P/T ID -->
												<th CL='STD_SECTID,2'></th>             <!-- SectionID -->
												<th CL='STD_PACKID'></th>               <!-- Set품번코드 -->
												<th CL='STD_QTADJU'></th>               <!-- 조정수량 -->
												<th CL='STD_QTYUOM,2'></th>             <!-- Quantity by UOM -->
												<th CL='STD_TRUNTY'></th>               <!-- 팔렛타입 -->
												<th CL='STD_MEASKY'></th>               <!-- 단위구성 -->
												<th CL='STD_UOMKEY'></th>               <!-- 단위 -->
												<th CL='STD_QTPUOM,2'></th>             <!-- Unit per measure -->
												<th CL='STD_DUOMKY'></th>               <!-- 단위 -->
												<th CL='STD_QTDUOM'></th>               <!-- 입수 -->
												<th CL='STD_SUBSIT,2'></th>               <!-- 다음Item 번호 -->
												<th CL='STD_SUBSFL,2'></th>               <!-- 서브Item플래그 -->
												<th CL='STD_REFDKY,2'></th>               <!-- 참조문서본호 -->
												<th CL='STD_REFDIT,2'></th>               <!-- 참조문서Item -->
												<th CL='STD_REFCAT'></th>               <!-- 참조문서유형 -->
												<th CL='STD_OWNRKY'></th>               <!-- 화주 -->
												<th CL='STD_SKUKEY'></th>               <!-- 품번코드 -->
												<th CL='STD_LOTA01'></th>               <!-- S/N번호 -->
												<th CL='STD_LOTA02'></th>               <!-- 재고유형 -->
												<th CL='STD_LOTA02NM'></th>               <!-- 재고유형 -->
												<th CL='STD_LOTA03'></th>               <!-- 벤더 -->
												<th CL='STD_LOTA04'></th>               <!-- 문서번호 -->
												<th CL='STD_LOTA05'></th>               <!-- 재고분류 -->
												<th CL='STD_LOTA06'></th>               <!-- 재고상태 -->
												<th CL='STD_LOTA07'></th>               <!-- LOT속성7 -->
												<th CL='STD_LOTA08'></th>               <!-- LOT속성8-->
												<th CL='STD_LOTA09'></th>               <!-- LOT속성9 -->
												<th CL='STD_LOTA10'></th>               <!-- LOT속성10 -->
												<th CL='STD_LOTA11'></th>               <!-- 제조일자 -->
												<th CL='STD_LOTA12'></th>               <!-- 입고일자 -->
												<th CL='STD_LOTA13'></th>               <!-- 유효기간 -->
												<th CL='STD_LOTA14'></th>               <!-- LOT속성14 -->
												<th CL='STD_LOTA15'></th>               <!-- LOT속성15 -->
												<th CL='STD_LOTA16'></th>               <!-- LOT속성16 -->
												<th CL='STD_LOTA17'></th>               <!-- LOT속성17 -->
												<th CL='STD_LOTA18'></th>               <!-- LOT속성18 -->
												<th CL='STD_LOTA19'></th>               <!-- LOT속성19-->
												<th CL='STD_LOTA20'></th>               <!-- LOT속성20 -->
												<th CL='STD_AWMSNO'></th>               <!-- SEQ(ERP)-->
												<th CL='STD_AREAKY'></th>               <!-- 창고 -->
												<th CL='STD_DESC01'></th>               <!-- 품명 -->
												<th CL='STD_DESC02'></th>               <!-- 규격 -->
												<th CL='STD_ASKU01'></th>               <!-- WMS통합코드 -->
												<th CL='STD_ASKU02'></th>               <!-- 수출(E)/내수(D) -->
												<th CL='STD_ASKU03'></th>               <!-- erp 오더유형 -->
												<th CL='STD_ASKU04'></th>               <!-- 거래처 입고빈 -->
												<th CL='STD_ASKU05'></th>               <!-- 제질 -->
												<th CL='STD_EANCOD'></th>               <!-- EAN -->
												<th CL='STD_GTINCD'></th>               <!-- UPC -->
												<th CL='STD_SKUG01'></th>               <!-- 품목유형1 -->
												<th CL='STD_SKUG02'></th>               <!-- 품목유형2 -->
												<th CL='STD_SKUG03'></th>               <!-- 품목유형3 -->
												<th CL='STD_SKUG04'></th>               <!-- 품종 -->
												<th CL='STD_SKUG05'></th>               <!-- 모업체품번 -->
												<th CL='STD_GRSWGT'></th>               <!-- 총중량 -->
												<th CL='STD_NETWGT'></th>               <!-- KIT순중량 -->
												<th CL='STD_WGTUNT'></th>               <!-- 중량단위 -->
												<th CL='STD_LENGTH'></th>               <!-- 길이 -->
												<th CL='STD_WIDTHW'></th>              
												<th CL='STD_HEIGHT'></th>              
												<th CL='STD_CUBICM'></th>              
												<th CL='STD_CAPACT'></th>              
												<th CL='STD_WORKID'></th>         <!-- KO/STD/WORKID -->     
												<th CL='STD_WORKNM'></th>         <!-- KO/STD/WORKNM -->         
												<th CL='STD_HHTTID'></th>              
												<th CL='STD_SMANDT'></th>              
												<th CL='STD_SEBELN'></th>              
												<th CL='STD_SEBELP'></th>              
												<th CL='STD_SZMBLNO'></th>             
												<th CL='STD_SZMIPNO'></th>             
												<th CL='STD_STRAID,2'></th>      <!-- 고객주문번호 -->        
												<th CL='STD_SVBELN'></th>              
												<th CL='STD_SPOSNR'></th>              
												<th CL='STD_STKNUM'></th>              
												<th CL='STD_STPNUM'></th>              
												<th CL='STD_SWERKS'></th>              
												<th CL='STD_SLGORT'></th>              
												<th CL='STD_SDATBG'></th>              
												<th CL='STD_STDLNR,2'></th>     <!-- 반품출하문서번호 -->            
												<th CL='STD_SSORNU'></th>     <!-- 반품출하문서아이템 -->         
												<th CL='STD_SSORIT,2'></th>      <!-- Mat.Doc.No -->         
												<th CL='STD_SMBLNR,2'></th>      <!-- Mat.Doc.It -->        
												<th CL='STD_SZEILE'></th>              
												<th CL='STD_SMJAHR'></th>              
												<th CL='STD_SXBLNR'></th>              
												<th CL='STD_SAPSTS'></th>              
												<th CL='STD_QTYSTL'></th>              
												<th CL='STD_QTSIWH'></th>              
												<th CL='STD_QTYBIZ'></th>    <!-- 실물재고 -->          
												<th CL='STD_USEQTY'></th>    <!-- 가용수량 -->           
												<th CL='STD_QTSPHY'></th>              
												<!-- <th CL='STD_AUTLOC'></th> -->     
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
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
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
												<td GCol="text,PHYIKY"></td>
												<td GCol="text,PHYIIT"></td>
												<td GCol="text,RSNADJ"></td>
												<td GCol="text,STOKKY"></td>
												<td GCol="text,LOTNUM"></td>
												<td GCol="text,LOCAKY"></td>
												<td GCol="text,TRNUID"></td>
												<td GCol="text,SECTID"></td>
												<td GCol="text,PACKID"></td>
												<td GCol="text,QTADJU" GF="N"></td>
												<td GCol="text,QTYUOM" GF="N"></td>
												<td GCol="text,TRUNTY"></td>
												<td GCol="text,MEASKY"></td>
												<td GCol="text,UOMKEY"></td>
												<td GCol="text,QTPUOM"></td>
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
												<td GCol="text,LOTA16"></td>
												<td GCol="text,LOTA17"></td>
												<td GCol="text,LOTA18"></td>
												<td GCol="text,LOTA19"></td>
												<td GCol="text,LOTA20"></td>
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
												<td GCol="text,WORKID"></td>
												<td GCol="text,WORKNM"></td>
												<td GCol="text,HHTTID"></td>
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
												<td GCol="text,SSORNU"></td>
												<td GCol="text,SSORIT"></td>
												<td GCol="text,SMBLNR"></td>
												<td GCol="text,SZEILE"></td>
												<td GCol="text,SMJAHR"></td>
												<td GCol="text,SXBLNR"></td>
												<td GCol="text,SAPSTS"></td>
												<td GCol="text,QTYSTL" GF="N"></td>
												<td GCol="text,QTSIWH" GF="N"></td>
												<td GCol="text,QTYBIZ"></td>
												<td GCol="text,USEQTY" GF="N"></td>
												<td GCol="text,QTSPHY" GF="N"></td>
												<!-- <td GCol="text,AUTLOC"></td> -->
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