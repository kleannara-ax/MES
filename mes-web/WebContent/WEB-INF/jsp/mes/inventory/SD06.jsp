<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript">
	var dblIdx = 0;
	
	$(document).ready(function(){
		setTopSize(250);
		gridList.setGrid({
	    	id : "gridList",
			editable : true,
			module : "WmsInventory",
			command : "SD06"
	    });
		
		gridList.setGrid({
	    	id : "gridListSub",
			editable : true,
			module : "WmsInventory",
			command : "SD06Sub"
	    });
	});

	function searchList(){
		var param = inputList.setRangeParam("searchArea");
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
	}
	
	function searchSubList(headRowNum){
		var skukey = gridList.getColData("gridList", headRowNum, "SKUKEY");
		var lotnum = gridList.getColData("gridList", headRowNum, "LOTNUM");
		var param = inputList.setRangeParam("searchArea");
		param.put("SKUKEY", skukey);
		param.put("LOTNUM", lotnum);
		
		gridList.gridList({
			id : "gridListSub",
			param : param
		});

		lastFocusNum = rowNum;
		dblIdx = rowNum;
	}
	
	var lastFocusNum = -1;
	function gridListEventDataBindEnd(gridId, dataLength){
		if(gridId == "gridList" && dataLength > 0){
			searchSubList(0);
		}
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
	
	//그리드 위에 클릭시 아이템 리셋
	function gridListEventRowFocus(gridId, rowNum){
		if(gridId == "gridList"){
			var modRowCnt = gridList.getModifyRowCount("gridListSub");
			if(modRowCnt == 0){
				if(dblIdx != rowNum){
					gridList.resetGrid("gridListSub");
					dblIdx = -1;
				}
			//저장
			}else{
				if(commonUtil.msgConfirm("COMMON_M0462")){
				//if(confirm("값이 변화된 데이터가 있습니다. 이동하시겠습니까?")){
					gridList.resetGrid("gridListSub");
				}else{
					gridListEventRowFocus("gridList", dblIdx);
					return;
				}
			}
		}
	}
	
	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Execute"){
			test3();
		}
	} 
	
</script>
</head>
<body>

<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY"></button>
		
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
					<%-- <tr>
						<th CL="STD_WAREKY">거점</th>
						<td>
							<input type="text" name="WAREKY" value="<%=wareky%>" readonly="readonly" style="width:160px;"/>
						</td>
					</tr> --%>
					<tr>
						<th CL="STD_SKUKEY">품번코드</th>
						<td><input type="text" name="S.SKUKEY" UIInput="R,SHSKUMA" /></td>
					</tr>
					<tr>
						<th CL="STD_DESC01">품명</th>
						<td><input type="text" name="S.DESC01" UIInput="R" /></td>
					</tr>
					<tr>
						<th CL="STD_LOTNUM">Lot.NO</th>
						<td>
							<input type="text" name="S.LOTNUM" UIInput="R"/>  <!-- SHLOTAT -->
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
						<li><a href="#tabs1-1" CL='STD_GENERAL'><span>일반</span></a></li>
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
											<col width="130" />
											<col width="100" />
											<col width="130" />
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
												<th CL='STD_SKUKEY'>제품코드</th>
												<th CL='STD_DESC01'>제품명</th>
												<th CL='STD_LOTNUM'>Lot.NO</th>      
												<th CL='STD_QTSWH1'>WH01재고</th>
												<th CL='STD_QTSPMO'>이동중재고</th>
												<th CL='STD_QTSWH2'>WH02재고</th>
												<th CL='STD_QTSIWH'>총재고수량</th>
												<th CL='STD_CREDAT'>생성일자</th>
												<th CL='STD_CRETIM'>생성시간</th>
												<th CL='STD_CREUSR'>생성자</th>
												<th CL='STD_LMODAT'>수정일자</th>
												<th CL='STD_LMOTIM'>수정시간</th>
												<th CL='STD_LMOUSR'>수정자</th>   
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
											<col width="130" />
											<col width="100" />
											<col width="130" />
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
												<td GCol="text,SKUKEY">제품코드</td>    
												<td GCol="text,DESC01">제품명</td>       
												<td GCol="text,LOTNUM">Lot.NO</td>
												<td GCol="text,QTSWH1" GF="N">WH01재고</td> 
												<td GCol="text,QTSPMO" GF="N">이동중재고</td>
												<td GCol="text,QTSWH2" GF="N">WH02재고</td>
												<td GCol="text,QTSIWH" GF="N">총재고수량</td>
												<td GCol="text,CREDAT" GF="D">생성일자</td>
												<td GCol="text,CRETIM" GF="T">생성시간</td>
												<td GCol="text,CREUSR">생성자</td>
												<td GCol="text,LMODAT" GF="D">수정일자</td>
												<td GCol="text,LMOTIM" GF="T">수정시간</td>
												<td GCol="text,LMOUSR">수정자</td>
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
						<li><a href="#tabs1-1" CL='STD_ITEM'><span>아이템</span></a></li>
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
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<th CL='STD_WAREKY'>센터</th>
												<th CL='STD_LOTA01'>S/N번호</th>
												<th CL='STD_LOTA02'>재고유형</th>
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
												<th CL='STD_LOTA13'>유효기간</th>
												<th CL='STD_LOTA14'>LOT속성14</th>
												<th CL='STD_LOTA15'>LOT속성15</th>
												<th CL='STD_LOTA16'>LOT속성16</th>
												<th CL='STD_LOTA17'>LOT속성17</th>
												<th CL='STD_LOTA18'>LOT속성18</th>
												<th CL='STD_LOTA19'>LOT속성19</th>
												<th CL='STD_LOTA20'>LOT속성20</th>
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
										</colgroup>
										<tbody id="gridListSub">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<td GCol="text,WAREKY">센터</td>
												<td GCol="text,LOTA01"></td>
												<td GCol="text,LOTA02"></td>
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
												<td GCol="text,LOTA13" GF="D"></td>
												<td GCol="text,LOTA14"></td>
												<td GCol="text,LOTA15"></td>
												<td GCol="text,LOTA16" GF="N"></td>
                                                <td GCol="text,LOTA17" GF="N"></td>
												<td GCol="text,LOTA18" GF="N"></td>
												<td GCol="text,LOTA19" GF="N"></td>
												<td GCol="text,LOTA20" GF="N"></td>
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