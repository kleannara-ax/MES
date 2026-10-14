<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
		gridList.setGrid({
	    	id : "gridList1",
			editable : true,
			pkcol : "WAREKY,SKUKEY",
			module : "WmsInventory",
			command : "SD01TAB1",
			dataRequest : true
	    });
		gridList.setGrid({
	    	id : "gridList2",
			editable : true,
			pkcol : "WAREK,SKUKEY",
			module : "WmsInventory",
			command : "SD01TAB2",
			dataRequest : true
	    });
		/**
		gridList.setGrid({
	    	id : "gridList3",
			editable : true,
			pkcol : "WAREK,SKUKEY",
			module : "WmsInventory",
			command : "SD01TAB3",
			dataRequest : true
	    });
		**/
		gridList.setGrid({
			id : "gridList3",
			editable : true,
			module : "WmsInventory",
			command : "SD01TAB3",
			colorType  : true,
			autoCopyRowType : false,
			totalCols  : ["QTSIWH"]
		});		
		var areaky = "<%=user.getUserg5()%>";
		var wareky = "<%=wareky%>";
		
		var param = new DataMap();
		param.put("WAREKY",wareky);
		param.put("AREAKY",areaky);
	
		var json = netUtil.sendData({
			module : "WmsInventory",
			command : "AREAKYVal",
			sendType : "map",
			param : param
		});
		
		if(json.data["CNT"] != 0){
			inputList.setRangeData("S.AREAKY", configData.INPUT_RANGE_RANGE_FROM, areaky);
		}
	});
	
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			
			var tabIdx = param.get("Opt") -1 ; //0부터 시작하므로 -1 추가
		 	
			var gridId = "gridList"+param.get("Opt");
			param.put("OPT", param.get("Opt"));
			
			gridList.resetGrid(gridId);
			gridList.setReadOnly(gridId, false);
			
	 		gridList.gridList({
		    	id : gridId,
		    	param : param,
		    	url : "/wms/inventory/json/areaSD02.data"
		    });  
		 	$('#bottomTabs').tabs("option", "active", tabIdx);
		}
	}
	
	function tabChg(num){
		var gridId = "gridList"+num;
		var param = inputList.setRangeParam("searchArea");
		$("input[value='"+ num +"']").prop("checked",true); //현재 TAB 재조회를 위해 추가
		
		
		gridList.resetGrid(gridId);
		gridList.setReadOnly(gridId, false);
		
		gridList.gridList({
	    	id : gridId,
	    	param : param
	    });
	}
	
	function searchHelpEventOpenBefore(searchCode, gridType, $inputObj){
		if(searchCode == "SHZONMA"){
			return dataBind.paramData("searchArea");
		}else if(searchCode == "SHLOCMA"){
			return dataBind.paramData("searchArea");
		}else if(searchCode == "SHSKUMA"){
			var param = new DataMap();

			param.put("WAREKY", "<%=wareky%>");
			param.put("OWNRKY", "<%=ownrky%>");
			return param;
		}else if(searchCode == "SHCMCDV"){
			var param = new DataMap();
			param.put("CMCDKY", "LOTA06");
			return param;
		}
	}
	
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			searchList();
		}
	}
	
	/* 그리드 폰트 컬러 이벤트 */
	function gridListColTextColorChange(gridId, rowNum, colName, colValue){
		if(gridId == "gridList3"){
			if( colName == "EXPRTN_DE_DAYCNT" ){
				return configData.GRID_COLOR_TEXT_RED_CLASS;
			}
		}
	}	
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY">조회</button>
	</div>
	<div class="util2">
		<button class="button type2" id="showPop" type="button"><img src="/common/images/ico_btn4.png" alt="List" /></button>
	</div>

</div>

<!-- searchPop -->
<div class="searchPop" id="searchArea" style="overflow-y:scroll;">
	<button type="button" class="closer">X</button>
	<div class="searchInnerContainer">
		<p class="util">
			<button CB="Search SEARCH BTN_DISPLAY"></button>
			<!--<button CB="GetVariant GETVARIANT BTN_GETVARIANT"></button>-->
			<!--<button CB="SaveVariant SAVEVARIANT BTN_SAVEVARIANT"></button>-->
		</p>
		<div class="searchInBox">
			<h2 class="tit type1" CL="STD_IFDLMT">구분자</h2>
				<table class="table type1">
					<colgroup>
						<col width="100" />
						<col />
					</colgroup>
					<tbody>
						<tr>
							<td>
								<input type="radio" name="Opt" value="1" checked="checked">
								<label for="Opt" CL="STD_BYSKUKEY"></label>
								<input type="radio" name="Opt" value="2" />
								<label for="Opt" CL="STD_BYAREAKY"></label>
								<input type="radio" name="Opt" value="3" />
								<label for="Opt" CL="STD_BYLOCAKY"></label>
							</td>
						</tr>
					</tbody>
				</table>
		</div>
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
							<input type="text" name="WAREKY" id="WAREKY" value="<%=wareky%>" readonly="readonly" style="width: 160px;" />
						</td>
					</tr>
					<tr>
						<th CL="STD_OWNRKY">화주</th>
						<td>
							<select Combo="WmsOrder,OWNRKYCOMBO" name="OWNRKY" id="OWNRKY" style="width: 160px;">
							</select>
						</td>
					</tr>
<!-- 					<tr> -->
<!-- 						<th CL="STD_AREAKY">창고</th> -->
<!-- 						<td> -->
<!-- 						<input type="text" name="S.AREAKY" UIInput="R,SHAREMA" /> -->
<!-- 						</td> -->
<!-- 					</tr> -->
					<tr>
						<th CL="STD_ZONEKY">구역</th>
						<td>
							<input type="text" name="S.ZONEKY" UIInput="R,SHZONMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_LOCAKY">지번</th>
						<td>
							<input type="text" name="S.LOCAKY" UIInput="R,SHLOCMA"/>
						</td>
					</tr>
					<tr>
						<th CL="STD_TRNUID">팔레트ID</th>
						<td>
							<input type="text" name="S.TRNUID" UIInput="R"/>
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
					<td><input type="text" name="S.SKUKEY" UIInput="R,SHSKUMA" /></td>
				</tr>
				<tr>
					<th CL="STD_DESC01"></th>
					<td>
						<input type="text" name="S.DESC01" UIInput="R" />
					</td>
				</tr>
				<tr>
					<th CL="STD_DESC02"></th>
					<td>
						<input type="text" name="S.DESC02" UIInput="R" />
					</td>
				</tr>
				<tr>
					<th CL="STD_SKUTYPE"></th>
					<td>
						<input type="text" name="M.ASKL03" UIInput="R" />
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
<!-- 					<th CL="STD_LOTA01"></th> -->
<!-- 					<td> -->
<!-- 						<input type="text" name="S.LOTA01" UIInput="R" /> -->
<!-- 					</td> -->
<!-- 				</tr> -->
<!-- 				<tr> -->
<!-- 					<th CL="STD_LOTA02"></th> -->
<!-- 					<td> -->
<!-- 						<input type="text" name="S.LOTA02" UIInput="R" /> -->
<!-- 					</td> -->
<!-- 				</tr> -->
<!-- 				<tr> -->
<!-- 					<th CL="STD_LOTA03"></th> -->
<!-- 					<td> -->
<!-- 						<input type="text" name="S.LOTA03" UIInput="R" /> -->
<!-- 					</td> -->
<!-- 				</tr> -->
<!-- 				<tr> -->
<!-- 					<th CL="STD_LOTA04"></th> -->
<!-- 					<td> -->
<!-- 						<input type="text" name="S.LOTA04" UIInput="R" /> -->
<!-- 					</td> -->
<!-- 				</tr> -->
<!-- 				<tr> -->
<!-- 					<th CL="STD_LOTA05"></th> -->
<!-- 					<td> -->
<!-- 						<input type="text" name="S.LOTA05" UIInput="R" /> -->
<!-- 					</td> -->
<!-- 				</tr> -->
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
<!-- 				<tr> -->
<!-- 					<th CL="STD_LOTA07"></th> -->
<!-- 					<td> -->
<!-- 						<input type="text" name="LOTA07" UIInput="R" /> -->
<!-- 					</td> -->
<!-- 				</tr> -->
<!-- 				<tr> -->
<!-- 					<th CL="STD_LOTA09"></th> -->
<!-- 					<td> -->
<!-- 						<input type="text" name="S.LOTA09" UIInput="R" /> -->
<!-- 					</td> -->
<!-- 				</tr> -->
				
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

<div class="content">
	<div class="innerContainer">
		<!-- contentContainer -->
		<div class="contentContainer">
			<div class="bottomSect type1">
				<div class="tabs"  id="bottomTabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1" id="tab01" onclick="tabChg(1);"><span CL='STD_BYSKUKEY'>탭메뉴1</span></a></li>
						<li><a href="#tabs1-2" id="tab02" onclick="tabChg(2);"><span CL='STD_BYAREAKY'>탭메뉴1</span></a></li>
						<li><a href="#tabs1-3" id="tab03" onclick="tabChg(3);"><span CL='STD_BYLOCAKY'>탭메뉴1</span></a></li>
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
<!-- 											<col width="100" /> -->
											<col width="100" />
											<!-- <col width="100" /> -->
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<th CL='STD_WAREKY'>거점</th>
												<th CL='STD_SKUKEY'>품번코드</th>
												<th CL='STD_DESC02'>품번코드</th>
												<th CL='STD_DESC01'>품명</th>
												<th CL='STD_QTSIWH'>재고수량</th>
												<th CL='STD_USEQTY'>가용수량</th>
												<th CL='STD_QTSBLK'>보류수량</th>
												<th CL='STD_QTSALO'>할당수량</th>
												<th CL='STD_QTSOUT'>출고중수량</th>
 												<th CL='STD_QTSPMO'>이동중</th>
<!-- 												<th CL='STD_QTSPMI'>입고중</th> -->
												<th CL='STD_UOMKEY'>단위</th>
												<!-- <th CL='STD_LOTA10'>LOTA10</th> -->
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
<!-- 											<col width="100" /> -->
											<col width="100" />
											<!-- <col width="100" /> -->
										</colgroup>
										<tbody id="gridList1">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
											    <td GCol="text,WAREKY"></td>
												<td GCol="text,SKUKEY"></td>
												<td GCol="text,DESC02"></td>
												<td GCol="text,DESC01"></td>
												<td GCol="text,QTSIWH" GF="N"></td>
												<td GCol="text,USEQTY" GF="N"></td>
												<td GCol="text,QTSBLK" GF="N"></td>
												<td GCol="text,QTSALO" GF="N"></td>
												<td GCol="text,QTSOUT" GF="N"></td>
 												<td GCol="text,QTSPMO" GF="N"></td>
<!-- 												<td GCol="text,QTSPMI" GF="N"></td> -->
												<td GCol="text,UOMKEY"></td>
												<!-- <td GCol="text,LOTA10"></td> -->
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
					<div id="tabs1-2">
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
<!-- 											<col width="100" /> -->
											<col width="100" />
											<!-- <col width="100" /> -->
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<th CL='STD_WAREKY'>거점</th>
												<th CL='STD_AREAKY'>창고</th>
												<th CL='STD_SKUKEY'>품번코드</th>
												<th CL='STD_DESC02'>품번코드</th>
											    <th CL='STD_DESC01'>품명</th>
												<th CL='STD_QTSIWH'>재고수량</th>
												<th CL='STD_USEQTY'>가용수량</th>
												<th CL='STD_QTSBLK'>보류수량</th>
												<th CL='STD_QTSALO'>할당수량</th>
												<th CL='STD_QTSOUT'>출고중수량</th>
 												<th CL='STD_QTSPMO'>이동중</th>
<!-- 												<th CL='STD_QTSPMI'>입고중</th> -->
												<th CL='STD_UOMKEY'>단위</th>
												<!-- <th CL='STD_LOTA10'>LOTA10</th> -->
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
<!-- 											<col width="100" /> -->
											<col width="100" />
											<!-- <col width="100" /> -->
										</colgroup>
										<tbody id="gridList2">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
										        <td GCol="text,WAREKY"></td>
												<td GCol="text,AREAKY"></td>
												<td GCol="text,SKUKEY"></td>
												<td GCol="text,DESC02"></td>
												<td GCol="text,DESC01"></td>
												<td GCol="text,QTSIWH" GF="N"></td>
												<td GCol="text,USEQTY" GF="N"></td>
												<td GCol="text,QTSBLK" GF="N"></td>
												<td GCol="text,QTSALO" GF="N"></td>
												<td GCol="text,QTSOUT" GF="N"></td>
												<td GCol="text,QTSPMO" GF="N"></td>
<!-- 												<td GCol="text,QTSPMI" GF="N"></td> -->
												<td GCol="text,UOMKEY"></td>
												<!-- <td GCol="text,LOTA10"></td> -->
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
					<div id="tabs1-3">
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
											<!--<col width="100" />
										    <col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" /> 
											<col width="100" /> 
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
										    <col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" /> -->
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<th CL='STD_WAREKY'>거점</th>
												<th CL='STD_AREAKY'>창고</th>
												<th CL='STD_ZONEKY'>구역</th>
												<th CL='STD_PZPTNANM'>구역</th>
												<th CL='STD_LOCAKY'>지번</th>
											    <th CL='STD_SKUKEY'>품번코드</th>
												<th CL='STD_ASKU01'>WMS 통합코드</th>
												<th CL='STD_DESC01'>품명</th>
												<th CL='STD_DESC02'>규격</th>
												<th CL='STD_UOMKEY'>단위</th>
												<th CL='STD_QTSIWH'>재고수량</th>
												<th CL='STD_USEQTY'>가용수량</th>
												<th CL='STD_QTSBLK'>보류수량</th>
												<th CL='STD_QTSALO'>할당수량</th>
												<th CL='STD_QTSPMO'>이동중</th>
												<th CL='STD_QTSPMI'>입고중</th>
												<th CL='STD_QTSOUT'>출고중</th>
												<th CL='STD_SKUG01'>품목유형1</th>
												<th CL='STD_SKUG05'></th>
											    <th CL='STD_TRNUID'>P/T</th>
												<th CL='STD_QTDUOM'>입수</th>
												<th CL='STD_BOXQTY'>박스수</th>
												<th CL='STD_REMQTY'>잔량</th>
												<th CL='STD_LOTA13'>유효기간</th>
												<th CL='STD_WSD_EXPRTN_DE_DAYCNT'>유통기한잔여일수</th>
												<!-- <th CL='STD_LOTA01'>S/N번호</th>
												<th CL='STD_LOTA02'>재고유형</th>
												<th CL='STD_LOTA02NM'>재고유형</th>
												<th CL='STD_LOTA03'>벤더</th>
												<th CL='STD_LOTA04'>문서번호</th>
												<th CL='STD_LOTA05'>재고분류</th>
												<th CL='STD_LOTA06'>재고상태</th>
												<th CL='STD_LOTA07'>LOT속성7</th>
												<th CL='STD_LOTA08'>LOT속성8</th>
											    <th CL='STD_LOTA09'>LOT속성9</th>
												<th CL='STD_LOTA10'>LOT속성10</th>
												<th CL='STD_LOTA11'>제조일자</th>
												<th CL='STD_LOTA12'>입고일자</th>
												
												<th CL='STD_LOTA14'>LOT속성14</th>
												<th CL='STD_LOTA15'>LOT속성15</th>
												<th CL='STD_LOTA16'>LOT속성16</th>
												<th CL='STD_LOTA17'>LOT속성17</th>
												<th CL='STD_LOTA18'>LOT속성18</th>
												<th CL='STD_LOTA19'>LOT속성19</th>
												<th CL='STD_LOTA20'>LOT속성20</th> -->
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
											<!-- <col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
										    <col width="100" />
										    <col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
										    <col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" /> -->
										</colgroup>
										<tbody id="gridList3">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
											    <td GCol="text,WAREKY"></td>
												<td GCol="text,AREAKY"></td>
												<td GCol="text,ZONEKY"></td>
												<td GCol="text,PZPTNANM"></td>
												<td GCol="text,LOCAKY"></td>
												<td GCol="text,SKUKEY"></td>
												<td GCol="text,ASKU01"></td>
												<td GCol="text,DESC01"></td>
												<td GCol="text,DESC02"></td>
												<td GCol="text,UOMKEY"></td>
												<td GCol="text,QTSIWH" GF="N"></td>
												<td GCol="text,USEQTY" GF="N"></td>
												<td GCol="text,QTSBLK" GF="N"></td>
                                                <td GCol="text,QTSALO" GF="N"></td>
												<td GCol="text,QTSPMO" GF="N"></td>
												<td GCol="text,QTSPMI" GF="N"></td>
												<td GCol="text,QTSOUT" GF="N"></td>
												<td GCol="text,SKUG01"></td>
												<td GCol="text,SKUG05"></td>
												<td GCol="text,TRNUID"></td>
												<td GCol="text,QTDUOM" GF="N"></td>
												<td GCol="text,BOXQTY" GF="N"></td>
												<td GCol="text,REMQTY" GF="N"></td>
												<td GCol="text,LOTA13" GF="D"></td>
												<td GCol="text,EXPRTN_DE_DAYCNT"   GF="N"></td>
												<!-- <td GCol="text,LOTA01"></td>
												<td GCol="text,LOTA02"></td>
												<td GCol="text,LOTA02NM"></td>
												<td GCol="text,LOTA03"></td>
												<td GCol="text,LOTA04"></td>
                                                <td GCol="text,LOTA05"></td>
												<td GCol="text,LOTA06"></td>
												<td GCol="text,LOTA07"></td>
												<td GCol="text,LOTA08"></td>
												<td GCol="text,LOTA09"></td>
												<td GCol="text,LOTA10"></td>
												<td GCol="text,LOTA11" GF="D"></td>
												<td GCol="text,LOTA12" GF="D"></td>
												
												<td GCol="text,LOTA14"></td>
												<td GCol="text,LOTA15"></td>
												<td GCol="text,LOTA16" GF="N"></td>
                                                <td GCol="text,LOTA17" GF="N"></td>
												<td GCol="text,LOTA18" GF="N"></td>
												<td GCol="text,LOTA19" GF="N"></td>
												<td GCol="text,LOTA20" GF="N"></td> -->
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