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
			command : "IP04"
	    });
		
		gridList.setGrid({
	    	id : "gridListSub",
	    	name : "gridListSub",
			editable : true,
			module : "WmsInventory",
			command : "IP04Sub"
	    });

		$("#USERAREA").val("<%=user.getUserg5()%>");
	});
	
	function searchList(){
		uiList.setActive("Save", true);
		uiList.setActive("Reflect", true);
		gridList.resetGrid("gridList");
		gridList.resetGrid("gridListSub");
		
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			
			gridList.gridList({
		    	id : "gridListSub",
		    	param : param
		    });
			
			/* gridList.gridList({
		    	id : "gridList",
		    	param : param
		    }); */
		}
		
		$("#rsnadjCombo").val("");
		
		gridList.setReadOnly("gridList", false);
		gridList.setReadOnly("gridListSub", false);
		
	}
	
	function saveData(){	
		
		 if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		} 
		
		if(gridList.validationCheck("gridListSub", "all")){
			var docunum = wms.getDocSeq(gridList.getColData("gridList", 0, "PHSCTY"));
			gridList.gridColModify("gridList", 0, "PHYIKY", docunum);

			var head = gridList.getRowData("gridList", 0);
			
			//alert(head);
			
			var list = gridList.getSelectModifyList("gridListSub");
			
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
					
				var paramH = new DataMap();
				paramH.put("PHYIKY", docunum);
					
				gridList.gridList({
				   	id : "gridList",
				    command : "IP04L",
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
			uiList.setActive("Reflect", false);
		}
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId == "gridListSub"){
			var useqty = new Number(gridList.getColData(gridId, rowNum, "USEQTY"));
			if(colName == "QTSPHY"){
				var value = new Number(gridList.getColData(gridId, rowNum, "QTADJU"));
				var chgValue = value + useqty;
				if(colValue != chgValue){
					var qtsphy = new Number(colValue);
					//var useqty = new Number(gridList.getColData(gridId, rowNum, "USEQTY"));
					var qtadju = qtsphy - useqty;
					gridList.setColValue("gridListSub", rowNum, "QTADJU", qtadju);
				}
			}else if(colName == "QTADJU"){
				var value = new Number(gridList.getColData(gridId, rowNum, "QTSPHY"));
				var chgValue = value - useqty;
				if(colValue != chgValue){
					var qtadju = new Number(colValue);
					var qtsphy = qtadju + useqty;
					gridList.setColValue("gridListSub", rowNum, "QTSPHY", qtsphy);
				}
			}			
		}
		
		if(gridId == "gridList"){
			uiList.setActive("Save", true);
			uiList.setActive("Reflect", true);
		}
	}
	
	function gridListEventDataViewEnd(gridId, dataLength){
		if(gridId == "gridList"){
			uiList.setActive("Search", true);
		}
	}
	
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}else if(btnName == "Reflect"){
			setRsnadj();
		}
	}
	
	function setRsnadj(){
		var rsnadjCombo = $("#rsnadjCombo").val();
		if(rsnadjCombo){
			var selectNumList = gridList.getSelectRowNumList("gridListSub");
			for(var i=0;i<selectNumList.length;i++){
				var rowNum = selectNumList[i];
				gridList.setColValue("gridListSub", rowNum, "RSNADJ", rsnadjCombo);
			}
		}
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
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if(gridId == "gridListSub" && dataLength > 0){
			var param = inputList.setRangeParam("searchArea");
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
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
						<th CL="STD_ZONEKY">구역</th>
						<td>
							<input type="text" name="ZONEKY" UIInput="R,SHZONMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_LOCAKY">지번</th>
						<td>
							<input type="text" name="LOCAKY" UIInput="R,SHLOCMA" />
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
<!-- 						<input type="text" name="LOTA02" UIInput="R" /> -->
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
<!-- 						<input type="text" name="LOTA03" UIInput="R" /> -->
<!-- 					</td> -->
<!-- 				</tr> -->
<!-- 				<tr> -->
<!-- 					<th CL="STD_LOTA05">Mall PO Item번호</th> -->
<!-- 					<td> -->
<!-- 						<input type="text" name="LOTA03" UIInput="R" /> -->
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
<!-- 						<input type="text" name="LOTA03" UIInput="R" /> -->
<!-- 					</td> -->
<!-- 				</tr> -->
<!-- 				<tr> -->
<!-- 					<th CL="STD_LOTA09">WMS PO번호</th> -->
<!-- 					<td> -->
<!-- 						<input type="text" name="LOTA03" UIInput="R" /> -->
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
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<th CL='STD_PHYIKY'></th>
												<th CL='STD_WAREKY'></th>
												<th CL='STD_DOCCAT'></th>
												<th CL='STD_PHSCTY'></th>
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
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<td GCol="text,PHYIKY"></td>
												<td GCol="text,WAREKY"></td>
												<td GCol="text,DOCCAT"></td>
												<td GCol="text,PHSCTY"></td>
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
								<table class="util">
									<tr>
										<th CL="STD_RSNADJ"></th>
										<td>
											&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
											<select ReasonCombo="520" id="rsnadjCombo">
												<option value=""> </option>
											</select>
										</td>
										<td>
											&nbsp;&nbsp;
											<button CB="Reflect REFLECT BTN_REFLECT"></button>
										</td>
									</tr>
								</table>
							<div class="table type2" style="top:45px;">
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
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
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
												<th CL='STD_RSNADJ'></th>
												<th CL='STD_STOKKY'></th>
												<th CL='STD_LOTNUM'></th>
												<th CL='STD_LOCAKY'></th>
												<th CL='STD_TRNUID'></th>
												<th CL='STD_SECTID'></th>
												<th CL='STD_PACKID'></th>
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
												<th CL='STD_ZONEKY'></th>
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
												<th CL='STD_WORKID'></th>
												<th CL='STD_WORKNM'></th>
												<th CL='STD_HHTTID'></th>
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
												<th CL='STD_SSORNU'></th>
												<th CL='STD_SSORIT'></th>
												<th CL='STD_SMBLNR'></th>
												<th CL='STD_SZEILE'></th>
												<th CL='STD_SMJAHR'></th>
												<th CL='STD_SXBLNR'></th>
												<th CL='STD_SAPSTS'></th>
												<th CL='STD_QTYSTL'></th>
												<th CL='STD_QTSIWH'></th>
												<th CL='STD_QTYBIZ'></th>
												<th CL='STD_USEQTY'></th>
												<th CL='STD_QTSPHY'></th>
												<th CL='STD_QTADJU'></th>
												<th CL='STD_QTSALO'></th>
												<th CL='STD_QTSPMI'></th>
												<th CL='STD_QTSPMO'></th>
												<th CL='STD_QTSBLK'></th>
												<th CL='STD_PURCKY'></th>
												<th CL='STD_PURCIT'></th>
												<th CL='STD_ASNDKY'></th>
												<th CL='STD_ASNDIT'></th>
												<th CL='STD_RECVKY'></th>
												<th CL='STD_RECVIT'></th>
												<th CL='STD_SHPOKY'></th>
												<th CL='STD_SHPOIT'></th>
												<th CL='STD_GRPOKY'></th>
												<th CL='STD_GRPOIT'></th>
												<th CL='STD_SADJKY'></th>
												<th CL='STD_SADJIT'></th>
												<th CL='STD_SDIFKY'></th>
												<th CL='STD_SDIFIT'></th>
												<th CL='STD_TASKKY'></th>
												<th CL='STD_TASKIT'></th>
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
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
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
												<!-- <td GCol="text,RSNADJ"></td> -->
												<td GCol="select,RSNADJ" validate="required,INV_M0054">
													<select ReasonCombo="520">
														<option value=""> </option>
													</select>
												</td>
												<td GCol="text,STOKKY"></td>
												<td GCol="text,LOTNUM"></td>
												<td GCol="text,LOCAKY"></td>
												<td GCol="text,TRNUID"></td>
												<td GCol="text,SECTID"></td>
												<td GCol="text,PACKID"></td>
												<td GCol="text,QTBLKD"></td>
												<td GCol="text,QTYUOM"></td>
												<td GCol="text,TRUNTY"></td>
												<td GCol="text,MEASKY"></td>
												<td GCol="text,UOMKEY"></td>
												<td GCol="text,QTPUOM"></td>
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
												<td GCol="text,LOTA16"></td>
												<td GCol="text,LOTA17"></td>
												<td GCol="text,LOTA18"></td>
												<td GCol="text,LOTA19"></td>
												<td GCol="text,LOTA20"></td>
												<td GCol="text,AWMSNO"></td>
												<td GCol="text,AREAKY"></td>
												<td GCol="text,ZONEKY"></td>
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
												<td GCol="text,QTYSTL"></td>
												<td GCol="text,QTSIWH"></td>
												<td GCol="text,QTYBIZ"></td>
												<td GCol="text,USEQTY"></td>
												<td GCol="input,QTSPHY" validate="required min(0),IN_M0048" GF="N 20,3"></td>
												<td GCol="input,QTADJU" GF="N 20,3"></td>
												<td GCol="text,QTSALO"></td>
												<td GCol="text,QTSPMI"></td>
												<td GCol="text,QTSPMO"></td>
												<td GCol="text,QTSBLK"></td>
												<td GCol="text,PURCKY"></td>
												<td GCol="text,PURCIT"></td>
												<td GCol="text,ASNDKY"></td>
												<td GCol="text,ASNDIT"></td>
												<td GCol="text,RECVKY"></td>
												<td GCol="text,RECVIT"></td>
												<td GCol="text,SHPOKY"></td>
												<td GCol="text,SHPOIT"></td>
												<td GCol="text,GRPOKY"></td>
												<td GCol="text,GRPOIT"></td>
												<td GCol="text,SADJKY"></td>
												<td GCol="text,SADJIT"></td>
												<td GCol="text,SDIFKY"></td>
												<td GCol="text,SDIFIT"></td>
												<td GCol="text,TASKKY"></td>
												<td GCol="text,TASKIT"></td>

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