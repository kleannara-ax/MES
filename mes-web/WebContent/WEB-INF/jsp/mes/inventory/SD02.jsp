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
		gridList.setGrid({
	    	id : "gridList",
	    	editable : true,
			pkcol : "STOKKY",
			module : "WmsInventory",
			command : "STKKY",
			dataRequest : true
	    });
		
		gridList.setReadOnly("gridList", true, ['LOTA06']);
		
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
			inputList.setRangeData("AREAKY", configData.INPUT_RANGE_RANGE_FROM, areaky);
		}
	});
	
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
 			inputList.copyRangeParam(param, "AREAKY", "SLGORT");
			gridList.gridList({
				id : "gridList",
		    	param : param,
		    	url : "/wms/inventory/json/areaSD02.data"
		    });
		}
		gridList.setReadOnly("gridList", true, ['LOTA06']);
	}
	
	function searchHelpEventOpenBefore(searchCode, gridType){
		if(searchCode == "SHSKUMA"){
			var param = new DataMap();
			param.put("WAREKY", "<%=wareky%>");
			param.put("OWNRKY", "<%=ownrky%>");
			return param;
		}else if(searchCode == "SHLOCMA"){
			return dataBind.paramData("searchArea");
		}else if(searchCode == "SHCMCDV"){
			var param = new DataMap();
			param.put("CMCDKY", "LOTA06");
			return param;
		}else if(searchCode == "SHZONMA"){
			return dataBind.paramData("searchArea");
		}
	}
	
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			searchList();
		}
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
<div class="searchPop" id="searchArea" style="overflow-y:scroll;">
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
							<input type="text" name="WAREKY" value="<%=wareky%>" readonly="readonly" style="width:160px;"/>
						</td>
					</tr>
					<tr>
						<th CL="STD_OWNRKY">화주</th>
						<td>
							<select Combo="WmsOrder,OWNRKYCOMBO" name="OWNRKY" id="OWNRKY" style="width:160px;">
							</select>
						</td>
					</tr>
					<!-- <tr>
						<th CL="STD_AREAKY">창고</th>
						<td GCol="select,AREAKY">
							<select Combo="WmsOrder,AREAKYCOMBO" name="AREAKY" id="USERAREA" validate="required">
							</select>
						</td>
					</tr> -->
					<tr>
						<th CL="STD_AREAKY">창고</th>
						<td>
<!-- 						<input type="text" name="AREAKY" UIInput="R" /> -->
						<input type="text" name="AREAKY" UIInput="R,SHAREMA" id="AREAKY"/>
						</td>
					</tr>
					<tr>
						<th CL="STD_ZONEKY">구역</th>
						<td>
							<input type="text" name="ZONEKY" UIInput="R,SHZONMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_LOCAKY">지번</th>
						<td>
							<input type="text" name="LOCAKY" UIInput="R,SHLOCMA"/>
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
	<h2 class="tit type1" CL="STD_SKUINFO">품목정보</h2>
	<table class="table type1">
		<colgroup>
			<col width="100" />
			<col />
		</colgroup>
		<tbody>
				<tr>
					<th CL="STD_SKUKEY">품번코드</th>
					<td><input type="text" name="SKUKEY" UIInput="R,SHSKUMA" /></td>
				</tr>
				<tr>
					<th CL="STD_DESC01"></th>
					<td>
						<input type="text" name="DESC01" UIInput="R" />
					</td>
				</tr>
				<tr>
					<th CL="STD_DESC02"></th>
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
<!-- 					<th CL="STD_LOTA01">공급사</th> -->
<!-- 					<td> -->
<!-- 						<input type="text" name="LOTA01" UIInput="R" /> -->
<!-- 					</td> -->
<!-- 				</tr> -->
<!-- 				<tr> -->
<!-- 					<th CL="STD_LOTA02">Cost Center</th> -->
<!-- 					<td> -->
<!-- 						<input type="text" name="LOTA02" UIInput="R"/> -->
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
<div class="searchInBox">
	<h2 class="tit type1" CL="STD_DOCUMENTINFO">문서정보</h2>
	<table class="table type1">
		<colgroup>
			<col width="100" />   
			<col />
		</colgroup>
		<tbody>
				<tr>
					<th CL="STD_RECVKY,2">입하문서번호</th>
					<td>
						<input type="text" name="RECVKY" UIInput="R" />
					</td>
				</tr>
				<tr>
					<th CL="STD_SHPOKY">출하문서번호</th>
					<td>
						<input type="text" name="SHPOKY" UIInput="R" />
					</td>
				</tr>
				<tr>
					<th CL="STD_TASKKY">작업지시번호</th>
					<td>
						<input type="text" name="TASKKY" UIInput="R" />
					</td>
				</tr>
				<tr>
					<th CL="STD_SADJKY">조정문서번호</th>
					<td>
						<input type="text" name="SADJKY" UIInput="R" />
					</td>
				</tr>
				<tr>
					<th CL="STD_PHYIKY">재고조사번호</th>
					<td>
						<input type="text" name="PHYIKY" UIInput="R" />
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

			<div class="bottomSect type1 ">
				<div class="tabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span CL='STD_SEARCH'>조회</span></a></li>
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
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<th CL='STD_SEBELN'>ECMS 주문번호</th>
												<th CL='STD_SPOSNR'>ECMS 주문 Item</th>
												<th CL='STD_STOKKY'>재고키</th>
												<th CL='STD_WAREKY'>거점</th>
										        <th CL='STD_AREAKY'>창고</th>
												<th CL='STD_ZONEKY'>구역</th>
												<th CL='STD_PZPTNANM'>구역</th>
												<th CL='STD_LOCAKY'>지번</th>
												<th CL='STD_TRNUID'>P/T ID</th>
												<th CL='STD_SKUKEY'>품번코드</th>
												<th CL='STD_DESC01'>품명</th>
												<th CL='STD_QTSIWH'>재고수량</th>
												<th CL='STD_QTSALO'>할당수량</th>
												<th CL='STD_QTSPMI'>입고중</th>
												<th CL='STD_QTSPMO'>이동중</th>
												<th CL='STD_SRCSKY'>Src.재고키</th>
												<th CL='STD_ASNDKY'>ASN 문서번호</th>
												<th CL='STD_RECVKY,2'>입하문서번호</th>
												<th CL='STD_SHPOKY'>출하문서번호</th>
												<th CL='STD_TASKKY'>작업지시번호</th>
												<th CL='STD_SADJKY'>조정문서번호</th>
												<th CL='STD_PHYIKY'>재고조사번호</th>
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
												<th CL='STD_LOTA11'>제조일자</th>
												<th CL='STD_LOTA12'>입고일자</th>
												<th CL='STD_LOTA13'></th>
												<th CL='STD_LOTA14'></th>
												<th CL='STD_LOTA15'></th>
												<th CL='STD_LOTA16'></th>
												<th CL='STD_LOTA17'></th>
												<th CL='STD_LOTA18'></th>
												<th CL='STD_LOTA19'></th>
												<th CL='STD_LOTA20'></th>
												<th CL='STD_ASKU01'></th>
												<th CL='STD_ASKU02'></th>
												<th CL='STD_ASKU03'></th>
												<th CL='STD_ASKU04'></th>
												<th CL='STD_ASKU05'></th>
												<th CL='STD_SKUG01'></th>
												<th CL='STD_SKUG02'></th>
												<th CL='STD_SKUG03'></th>
												<th CL='STD_SKUG04'></th>
												<th CL='STD_SKUG05'></th>
												<th CL='STD_CRETIM'>생성시간</th>
												<th CL='STD_CREDAT'>생성일자</th>
												<th CL='STD_LMOUSR'>수정자</th>
												<th CL='STD_SAPSTS'>ERP Mvt</th>
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
										</colgroup>
										<tbody id="gridList">
							                <tr CGRow="true">
								                <td GCol="rownum">1</td>
								                <td GCol="text,SEBELN"></td>
												<td GCol="text,SPOSNR"></td>
												<td GCol="text,STOKKY"></td>
												<td GCol="text,WAREKY"></td>
												<td GCol="text,AREAKY"></td>
												<td GCol="text,ZONEKY"></td>
												<td GCol="text,PZPTNANM"></td>
												<td GCol="text,LOCAKY"></td>
												<td GCol="text,TRNUID"></td>
												<td GCol="text,SKUKEY"></td>
												<td GCol="text,DESC01"></td>
												<!-- <td GCol="text,LOTA06"></td> -->
												<td GCol="text,QTSIWH" GF="N"></td>
												<td GCol="text,QTSALO" GF="N"></td>
												<td GCol="text,QTSPMI" GF="N"></td>
												<td GCol="text,QTSPMO" GF="N"></td>
												<td GCol="text,SRCSKY"></td>
												<td GCol="text,ASNDKY"></td>
												<td GCol="text,RECVKY"></td>
												<td GCol="text,SHPOKY"></td>
												<td GCol="text,TASKKY"></td>
												<td GCol="text,SADJKY"></td>
												<td GCol="text,PHYIKY"></td>
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
												<td GCol="text,ASKU01"></td>
												<td GCol="text,ASKU02"></td>
												<td GCol="text,ASKU03"></td>
												<td GCol="text,ASKU04"></td>
												<td GCol="text,ASKU05"></td>
												<td GCol="text,SKUG01"></td>
												<td GCol="text,SKUG02"></td>
												<td GCol="text,SKUG03"></td>
												<td GCol="text,SKUG04"></td>
												<td GCol="text,SKUG05"></td>
												<td GCol="text,CRETIM" GF="T"></td>
												<td GCol="text,CREDAT" GF="C"></td>
									            <td GCol="text,LMOUSR"></td>
												<td GCol="text,SAPSTS"></td>
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