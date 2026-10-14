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
	    	id : "gridList1",
			editable : true,
			pkcol : "WAREKY,SKUKEY",
			module : "WmsInventory",
			command : "SD03TAB1",
			dataRequest : true
	    });
		gridList.setGrid({
	    	id : "gridList2",
			editable : true,
			pkcol : "WAREK,SKUKEY",
			module : "WmsInventory",
			command : "SD03TAB2",
			dataRequest : true
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
			
	 		gridList.gridList({
		    	id : gridId,
		    	param : param,
		    	url : "/wms/inventory/json/areaSD03.data"
		    });  
		}
		$('#bottomTabs').tabs("option", "active", tabIdx);
	}
	
	function tabChg(num){
		var gridId = "gridList"+num;
		var param = inputList.setRangeParam("searchArea");
		//$("input[value='"+ num +"']").prop("checked",true); //현재 TAB 재조회를 위해 추가
		
		param.put("OPT", num);
		
 		gridList.gridList({
	    	id : gridId,
	    	param : param,
	    	url : "/wms/inventory/json/areaSD03.data"
	    });  
		
	}
	
	function searchHelpEventOpenBefore(searchCode, gridType, $inputObj){
		if(searchCode == "SHZONMA"){
			return dataBind.paramData("searchArea");
		}else if(searchCode == "SHLOCMA"){
			return dataBind.paramData("searchArea");
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
		<button CB="Search SEARCH BTN_DISPLAY"></button>
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
							<input type="text" name="WAREKY" id="WAREKY" value="<%=wareky%>" readonly="readonly" size="8px" />
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
				<tr>
					<th CL="STD_LOTA01">공급사</th>
					<td>
						<input type="text" name="S.LOTA01" UIInput="R" />
					</td>
				</tr>
				<tr>
					<th CL="STD_LOTA02">Cost Center</th>
					<td>
						<input type="text" name="S.LOTA02" UIInput="R" />
					</td>
				</tr>
				<tr>
					<th CL="STD_LOTA03">개별바코드</th>
					<td>
						<input type="text" name="S.LOTA03" UIInput="R" />
					</td>
				</tr>
				<tr>
					<th CL="STD_LOTA04">Mall PO번호</th>
					<td>
						<input type="text" name="S.LOTA04" UIInput="R" />
					</td>
				</tr>
				<tr>
					<th CL="STD_LOTA05">Mall PO Item번호</th>
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
				<tr>
					<th CL="STD_LOTA07">Mall SD번호</th>
					<td>
						<input type="text" name="LOTA07" UIInput="R" />
					</td>
				</tr>
				<tr>
					<th CL="STD_LOTA09">WMS PO번호</th>
					<td>
						<input type="text" name="S.LOTA09" UIInput="R" />
					</td>
				</tr>
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
<!-- 												<th CL='STD_QTSPMO'>이동중</th> -->
<!-- 												<th CL='STD_QTSPMI'>입고중</th> -->
												<th CL='STD_QTRTRN'>이고중수량</th>
												<th CL='STD_UOMKEY'>단위</th>
												<th CL='STD_WHIPRI'>재고금액</th>
												<th CL='STD_UNTPRI'>평균단가</th>
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
<!-- 												<td GCol="text,QTSPMO" GF="N"></td> -->
<!-- 												<td GCol="text,QTSPMI" GF="N"></td> -->
												<td GCol="text,QTRTRN" GF="N"></td>
												<td GCol="text,UOMKEY"></td>
												<td GCol="text,QTSIWH1" GF="N"></td>
												<td GCol="text,UNITPR" GF="N"></td>
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
											<col width="100" />
											<col width="100" />
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
<!-- 												<th CL='STD_QTSPMO'>이동중</th> -->
<!-- 												<th CL='STD_QTSPMI'>입고중</th> -->
												<th CL='STD_QTRTRN'>이고중수량</th>
												<th CL='STD_UOMKEY'>단위</th>
												<th CL='STD_WHIPRI'>재고금액</th>
												<th CL='STD_UNTPRI'>평균단가</th>
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
<!-- 												<td GCol="text,QTSPMO" GF="N"></td> -->
<!-- 												<td GCol="text,QTSPMI" GF="N"></td> -->
												<td GCol="text,QTRTRN" GF="N"></td>
												<td GCol="text,UOMKEY"></td>
												<td GCol="text,QTSIWH1" GF="N"></td>
												<td GCol="text,UNITPR" GF="N"></td>
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