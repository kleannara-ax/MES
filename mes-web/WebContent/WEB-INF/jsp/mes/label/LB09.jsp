<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript">
	var sFlag = true;
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
	    	name : "gridList",
			editable : true,
			checkHead : "gridListCheckHead",
			pkcol : "WAREKY,LOCAKY",
			module : "WmsLabel",
			command : "LB09",
			validation : "ZONEKY,TKZONE",
			bindArea : "tabs1-2" 
	    });
	});
	
	function searchList(){
		if(validate.check("searchArea")){
			sFlag = true;
			
			var param = inputList.setRangeParam("searchArea");
			param.put("type", "search");
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}
	
	function printList(){
		
		var chkHeadLen = gridList.getSelectRowNumList("gridList").length;
		var rowHeadIdx = gridList.getSelectRowNumList("gridList");
		if(chkHeadLen == 0 ){
			commonUtil.msgBox("VALID_M0006");
			return;
		}
	}
	
	function searchHelpEventOpenBefore(searchCode, gridType){
		if(searchCode == "SHWAHMA"){
			var param = new DataMap();
			param.put("COMPKY", "<%=compky%>");
			return param;
	    }else if(searchCode == "SHSKUMA"){
			var param = new DataMap();
			param.put("WAREKY", "<%=wareky%>");
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
								<input type="text" name="WAREKY" UIInput="S,SHWAHMA" validate="required,M0434" value="<%=wareky%>"/>
							</td>
						</tr>
						<tr>
							<th CL="STD_REFDKY">참조문서번호</th>
							<td>
								<input type="text" name="REFDKY" UIInput="R" />
							</td>
						</tr>
						<tr>
							<th CL="STD_FS_SKU_HDR1_1">바코드</th>
							<td>
								<input type="text" name="BARCOD" UIInput="R" />
							</td>
						</tr>
						<tr>
							<th CL="STD_SKUKEY">품번코드</th>
							<td>
								<input type="text" name="SKUKEY" UIInput="R,SHSKUMA" />
							</td>
						</tr>
						<tr>
							<th CL="STD_DESC01">품명</th>
							<td>
								<input type="text" name="DESC01" UIInput="R" />
							</td>
						</tr>
						<tr>
							<th CL="STD_CREDAT">생성일자</th>
							<td>
								<input type="text" name="CREDAT" UIInput="R" />
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
			<div class="bottomSect type1">
				<div class="tabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span CL='STD_GENERAL'>일반</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
											<col width="50" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
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
												<th CL='STD_NUMBER'></th>
												<th CL='STD_REFDKY'></th>
												<th CL='STD_FS_SKU_HDR1_1'></th>
												<th CL='STD_WAREKY'></th>
												<th CL='STD_SKUKEY'></th>
												<th CL='STD_DESC01'></th>
												<th CL='STD_DESC02'></th>
												<th CL='STD_PRTDAT'></th>
												<th CL='STD_QTDUOM'></th>
												<th CL='STD_QTYBOX'></th>
												<th CL='STD_REMQTY'></th>
												<th CL='STD_QTDPRT'></th>
												<th CL='STD_LOTA05'></th>
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
											<col width="50" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
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
												<td GCol="rownum"></td>
												<td GCol="text,REFDKY"></td>
												<td GCol="text,BARCOD"></td>
												<td GCol="text,WAREKY"></td>
												<td GCol="text,SKUKEY"></td>
												<td GCol="text,DESC01"></td>
												<td GCol="text,DESC02"></td>
												<td GCol="text,PRTDAT" GF="D"></td>
												<td GCol="text,QTDUOM" GF="N"></td>
												<td GCol="text,QTDBOX" GF="N"></td>
												<td GCol="text,QTDREM" GF="N"></td>
												<td GCol="text,QTDPRT" GF="N"></td>
												<td GCol="text,LOTA05"></td>
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
		<!-- //contentContainer -->
	</div>
</div>
<!-- //content -->
<%@ include file="/common/include/bottom.jsp" %>
</body>
</html>