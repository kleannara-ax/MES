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
	var searchFlag = true;
	
	$(document).ready(function(){
		gridList.setGrid({
			id : "gridHeadList",
	    	name : "gridList",
			editable : true,
			pkcol : "WAREKY",
			module : "WmsTask",
			command : "MV01HEAD"
	    });
		
		gridList.setGrid({
			id : "gridList",
	    	name : "gridList",
			editable : true,
			module : "WmsTask",
			command : "MV01BODY"
	    });
		$("#USERAREA").val("<%=user.getUserg5()%>");
 		gridList.setReadOnly("gridList", true, ['LOTA06']);
	});
	
	function searchList(){
		searchFlag = true;
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}
	
	function gridListEventDataBindEnd(gridId, dataCount){
		if(gridId == "gridHeadList"){
			uiList.setActive("Search", true);
		}else if(gridId == "gridList" && dataCount > 0 && searchFlag){
			var param = inputList.setRangeParam("searchArea");
			
			gridList.gridList({
		    	id : "gridHeadList",
		    	param : param
		    });
			
			$("#arsnadjCombo").val("");
			
			gridList.setReadOnly("gridList", false);
			gridList.setReadOnly("gridHeadList", false);
			gridList.setReadOnly("gridList", true, ['LOTA06']);

			uiList.setActive("Save", true);
			uiList.setActive("Reflect", true);
		}
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId == "gridHeadList"){
			uiList.setActive("Save", true);
		}else if(gridId == "gridList"){
			uiList.setActive("Reflect", true);			
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
	
	function saveData(){		
		if(gridList.validationCheck("gridList", "select")){
			if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
				return;
			}
			var chkRowCnt = gridList.getSelectRowNumList("gridList").length;
			var chkRowIdx = gridList.getSelectRowNumList("gridList");
			
			var flag = "";
			for(var j = 0; j < chkRowCnt; j++){
				var valString = gridList.getColData("gridList", chkRowIdx[j], "LOCATG");
				var qtyalab = gridList.getColData("gridList", chkRowIdx[j], "AVAILABLEQTY");
				var qtraor = gridList.getColData("gridList", chkRowIdx[j], "QTTAOR");
				if(valString == null || valString == "" || valString == " "){
					flag = "1";
					break;
				}
				
				if(parseInt(qtyalab) < parseInt(qtraor)){
					flag = "2";
					break;
				}
			}
			
			if(flag == "1"){
				commonUtil.msgBox("COMMON_M0009", STD_LOCATG); //{To 지번}을(를) 입력해주세요.
				return;
			}else if(flag == "2"){
				commonUtil.msgBox("TASK_M0023"); //* 상품[{0}]는 작업수량[{1}] 이 가용재고 수량[{2}]을 초과하였습니다.
				return;
			}
			
			if(chkRowCnt > 0){
// 				var docunum = wms.getDocSeq("320");
// 				gridList.gridColModify("gridHeadList", 0, "TASKKY", docunum);
// 				for(var i = 0; i < chkRowCnt; i++){
// 					gridList.gridColModify("gridList", chkRowIdx[i], "TASKKY", docunum);
// 				}
				
				var head = gridList.getRowData("gridHeadList", 0);
				var list = gridList.getSelectData("gridList");
				
				var param = new DataMap();
				param.put("head", head);
				param.put("list", list);
				
				var json = netUtil.sendData({
					url : "/wms/task/json/MV01CreatTaskOrder.data",
					param : param
				});
				
				if(json.MSG && json.MSG != 'OK'){
					var msgList = json.MSG.split("†");
					var msgTxt = commonUtil.getMsg(msgList[0], (msgList.length > 1 ? msgList[1].split("/") : null));
					commonUtil.msg(msgTxt);
					return;
					
// 					gridList.gridColModify("gridHeadList", 0, "TASKKY", "");
// 					for(var i = 0; i < chkRowCnt; i++){
// 						gridList.gridColModify("gridList", chkRowIdx[i], "TASKKY", "");
// 					}
				}else if(json.data){
					if(json.data){
						commonUtil.msgBox("COMMON_M0007", json.data); //{0}이 저장이 완료되었습니다.
						
						searchFlag = false;
						
						var paramH = new DataMap();
						paramH.put("TASKKY", json.data);
					
						gridList.gridList({
					    	id : "gridHeadList",
					    	command : "PT01HEAD",
					    	param : paramH
					    }); 
						
						gridList.gridList({
					    	id : "gridList",
					    	command : "PT01SUB",
					    	param : paramH
					    });
						
						gridList.setReadOnly("gridHeadList", true);
						gridList.setReadOnly("gridList", true);
					}
					uiList.setActive("Save", false);
					uiList.setActive("Reflect", false);
				}
			}else{
				commonUtil.msgBox("TASK_M0003"); //* 레코드가 선택되지 않았습니다.
				return false;
			}
		}
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue) {
		if (gridId == "gridList") {
			if (colName == "LOCATG") {
				if(colValue != ""){
					var param = inputList.setRangeParam("searchArea");
					var areaky = gridList.getColData("gridList", rowNum, "AREAKY");
					
					param.put("ALOCAKY",colValue);
					
					//지번 VALIDATION
					var json = netUtil.sendData({
						module : "WmsInventory",
						command : "LOCAKYval2",
						sendType : "map",
						param : param
					});
					
					if (json.data["CNT"] < 1) {
						commonUtil.msgBox("VALID_M0204", colValue);	//" "는 존재하지 않는 지번입니다. 		
						
						gridList.setColValue("gridList", rowNum, "LOCATG", "");
						gridList.setFocus("gridList", "LOCATG");
					}
				}
			}
		}
	}
	
	function setRsnadj(){
		var rsnadjCombo = $("#rsnadjCombo").val();
		/* var locaInput = $("#locaInput").val(); */
		if(rsnadjCombo){
			var selectNumList = gridList.getSelectRowNumList("gridList");
			for(var i=0;i<selectNumList.length;i++){
				var rowNum = selectNumList[i];
				gridList.setColValue("gridList", rowNum, "RSNCOD", rsnadjCombo);
				/* gridList.setColValue("gridList", rowNum, "LOCATG", locaInput); */
			}
		}
	}
	
	function searchHelpEventOpenBefore(searchCode, gridType){
		if(searchCode == "SHLOCMA"){
			var param = inputList.setRangeParam("searchArea");
			 //2020.04.02 LHJ 수정
			param.put("AREAKY" || "ZONEKY" || "LOCAKY", " ");  	
		    
		    return param;
		}else if(searchCode == "SHCMCDV"){
			var param = new DataMap();
			param.put("CMCDKY", "LOTA06");
			
			return param;
		}
	}
	
	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "WmsTask,TASOTYCD" || 
				comboAtt == "WmsTask,BZPTNCOMBO" ||
				comboAtt == "WmsTask,RSNCOMBO" ){
			var param = new DataMap();
			param.put("MENUID", configData.MENU_ID);
			return param;
		}
	}
	
	function gridExcelDownloadEventBefore(gridId){
		var param = inputList.setRangeParam("searchArea");
		if(gridId == "gridList"){
			var rowNum = gridList.getFocusRowNum("gridHeadList");
			var taskky = gridList.getColData("gridHeadList", rowNum, "TASKKY");
		
			param.put("TASKKY",taskky);
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
		<button CB="Save SAVE STD_SAVE">
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
			<!--<button CB="GetVariant GETVARIANT BTN_GETVARIANT"></button>-->
			<!--<button CB="SaveVariant SAVEVARIANT BTN_SAVEVARIANT"></button>-->
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
							<td><input type="text" name="WAREKY" size="8px" value="<%=wareky%>" style="width: 160px;" readonly="readonly"/>
							<%-- <td><input type="text" name="WAREKY" UIInput="S,SHWAHMA" validate="required,M0434" value="<%=wareky%>" readonly="readonly"/> --%>
						</td>
					</tr>
					<tr>
						<th CL="STD_OWNRKY">화주</th>
						<td>
							<select Combo="WmsOrder,OWNRKYCOMBO" name="OWNRKY" id="OWNRKY" style="width: 160px;" >
							</select>
						</td>
					</tr>
					<tr>
						<th CL="STD_TASOTY">작업타입</th>
						<td GCol="select,TASOTY">
							<select Combo="WmsTask,DOCTCOMBO" name="TASOTY" style="width: 160px;">
							</select>
						</td>
					</tr>
					<tr>
						<th CL="STD_AREAKY">창고</th>
						<td>
							<input type="text" name="STKKY.AREAKY" id="AREAKY" UIInput="R,SHAREMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_ZONEKY"></th>
						<td>
							<input type="text" name="STKKY.ZONEKY" id="ZONE" UIInput="R,SHZONMA" />
						</td>
					</tr>
 					<tr>
						<th CL="STD_LOCAKY">지번</th>
						<td>
							<input type="text" name="STKKY.LOCAKY" UIInput="R,SHLOCMA"/>
						</td>
					</tr>		
				</tbody>
			</table>
		</div>
		
		<div class="searchInBox">
			<h2 class="tit" CL="STD_SKUINFO">품목조건</h2>
			<table class="table type1">
				<colgroup>
					<col width="100" />
					<col />
				</colgroup>
				<tbody>
 					<tr>
						<th CL="STD_SKUKEY">품번코드</th>
						<td>
							<input type="text" name="STKKY.SKUKEY" UIInput="R,SHSKUMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_DESC01">품명</th>
						<td>
							<input type="text" name="STKKY.DESC01" UIInput="R" />
						</td>
					</tr>
					<tr>
						<th CL="STD_DESC02">규격</th>
						<td>
							<input type="text" name="STKKY.DESC02" UIInput="R" />
						</td>
					</tr>
				</tbody>
			</table>
		</div>
		
		<div class="searchInBox">
			<h2 class="tit" CL="STD_LOTINFO">LOT정보</h2>
			<table class="table type1">
				<colgroup>
					<col width="100" />
					<col />
				</colgroup>
				<tbody>
<!-- 					<tr> -->
<!-- 						<th CL="STD_LOTA01">업체코드</th> -->
<!-- 						<td> -->
<!-- 							<input type="text" name="STKKY.LOTA01" UIInput="R" /> -->
<!-- 						</td> -->
<!-- 					</tr> -->
<!-- 					<tr> -->
<!-- 						<th CL="STD_LOTA02">부서코드</th> -->
<!-- 						<td> -->
<!-- 							<input type="text" name="STKKY.LOTA02" UIInput="R" /> -->
<!-- 						</td> -->
<!-- 					</tr> -->
<!-- 					<tr> -->
<!-- 						<th CL="STD_LOTA03">개별바코드</th> -->
<!-- 						<td> -->
<!-- 							<input type="text" name="STKKY.LOTA03" UIInput="R" /> -->
<!-- 						</td> -->
<!-- 					</tr> -->
<!-- 					<tr> -->
<!-- 						<th CL="STD_LOTA04">Mall PO번호</th> -->
<!-- 						<td> -->
<!-- 							<input type="text" name="STKKY.LOTA04" UIInput="R" /> -->
<!-- 						</td> -->
<!-- 					</tr> -->
<!-- 					<tr> -->
<!-- 						<th CL="STD_LOTA05">Mall PO Item번호</th> -->
<!-- 						<td> -->
<!-- 							<input type="text" name="STKKY.LOTA05" UIInput="R" /> -->
<!-- 						</td> -->
<!-- 					</tr> -->
					<tr>
						<th CL="STD_LOTA06">재고상태</th>
						<td>
							<input type="text" name="STKKY.LOTA06" UIInput="R,SHCMCDV" />
						</td>
					</tr>
<!-- 					<tr> -->
<!-- 						<th CL="STD_LOTA07">Mall SD번호</th> -->
<!-- 						<td> -->
<!-- 							<input type="text" name="STKKY.LOTA07" UIInput="R" /> -->
<!-- 						</td> -->
<!-- 					</tr> -->
<!-- 					<tr> -->
<!-- 						<th CL="STD_LOTA09">WMS PO번호</th> -->
<!-- 						<td> -->
<!-- 							<input type="text" name="STKKY.LOTA09" UIInput="R" /> -->
<!-- 						</td> -->
<!-- 					</tr> -->
					<tr>
						<th CL="STD_LOTA11">제조일자</th>
						<td>
							<input type="text" name="STKKY.LOTA11" UIInput="R" UIFormat="C" />
						</td>
					</tr>
					<tr>
						<th CL="STD_LOTA12">입고일자</th>
						<td>
							<input type="text" name="STKKY.LOTA12" UIInput="R" UIFormat="C" />
						</td>
					</tr>
					<tr>
						<th CL="STD_LOTA13">유효기간</th>
						<td>
							<input type="text" name="STKKY.LOTA13" UIInput="R" UIFormat="C" />
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
						<li><a href="#tabs" CL="STD_LIST"><span>리스트</span></a></li>
					</ul>
					<div id="tabs">
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
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<th CL='STD_TASKKY'></th>
												<th CL='STD_WAREKY'></th>
												<th CL='STD_WAREKYNM'></th>
												<th CL='STD_TASOTY'></th>
												<th CL='STD_TASOTYNM'></th>
												<th CL='STD_DOCDAT'></th>
												<th CL='STD_QTTAOR'></th>
												<th CL='STD_QTCOMP'></th>
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
											<col width="100" />
											<col width="100" />
										</colgroup>
										<tbody id="gridHeadList">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<td GCol="text,TASKKY"></td>
												<td GCol="text,WAREKY"></td>
												<td GCol="text,WAREKYNM"></td>
												<td GCol="text,TASOTY"></td>
												<td GCol="text,TASOTYNM"></td>
												<td GCol="input,DOCDAT" GF="C 8"></td>
												<td GCol="text,QTTAOR"></td>
												<td GCol="text,QTCOMP"></td>
												<td GCol="text,DOCTXT"></td>
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
						<li><a href="#tabs1-1" CL="STD_ITEMLST"><span>ITEM 리스트</span></a></li>
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
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
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
												<th GBtnCheck="true"></th>
												<th CL='STD_TASKKY'></th>
												<th CL='STD_TASKIT'></th>
												<!-- <th CL='STD_STOKKY'></th> -->
												<th CL='STD_WAREKY'></th>
												<th CL='STD_AREAKY'></th>
												<th CL='STD_QTSAVLB'></th>
												<th CL='STD_TASKTY'></th>
												<th CL='STD_STATIT'></th>
												<th CL='STD_RSNCOD'></th>
												<th CL='STD_TASRSN'></th>
												<th CL='STD_QTTAOR'></th>
												<th CL='STD_QTCOMP'></th>
												<th CL='STD_OWNRKY'></th>
												<th CL='STD_SKUKEY'></th>
												<th CL='STD_DESC01'></th>
												<th CL='STD_DESC02'></th>
												<th CL='STD_LOTNUM'></th>
												<th CL='STD_ACTCDT'></th>
												<th CL='STD_ACTCTI'></th>
												<th CL='STD_QTYUOM'></th>
												<th CL='STD_TKFLKY'></th>
												<th CL='STD_STEPNO'></th>
												<th CL='STD_LSTTFL'></th>
												<th CL='STD_LOCASR'></th>
												<th CL='STD_SECTSR'></th>
												<th CL='STD_PAIDSR'></th>
												<th CL='STD_TRNUSR'></th>
												<th CL='STD_STRUTY'></th>
												<th CL='STD_SMEAKY'></th>
												<th CL='STD_SUOMKY'></th>
												<th CL='STD_QTSPUM'></th>
												<th CL='STD_SDUOKY'></th>
												<th CL='STD_QTSDUM'></th>
												<th CL='STD_LOCATG'></th>
												<th CL='STD_AREATG'></th>
												<th CL='STD_SECTTG'></th>
												<th CL='STD_PAIDTG'></th>
												<th CL='STD_TRNUTG'></th>
												<th CL='STD_TTRUTY'></th>
												<th CL='STD_TMEAKY'></th>
												<th CL='STD_TUOMKY'></th>
												<th CL='STD_QTTPUM'></th>
												<th CL='STD_TDUOKY'></th>
												<th CL='STD_QTTDUM'></th>
												<th CL='STD_LOCAAC'></th>
												<th CL='STD_SECTAC'></th>
												<th CL='STD_PAIDAC'></th>
												<th CL='STD_TRNUAC'></th>
												<th CL='STD_ATRUTY'></th>
												<th CL='STD_AMEAKY'></th>
												<th CL='STD_AUOMKY'></th>
												<th CL='STD_QTAPUM'></th>
												<th CL='STD_ADUOKY'></th>
												<th CL='STD_QTADUM'></th>
												<th CL='STD_REFDKY'></th>
												<th CL='STD_REFDIT'></th>
												<th CL='STD_REFCAT'></th>
												<th CL='STD_REFDAT'></th>
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
												<th CL='STD_PHYIKY'></th>
												<th CL='STD_PHYIIT'></th>
												<th CL='STD_DROPID'></th>
												<th CL='STD_ASKU01'></th>
												<th CL='STD_ASKU02'></th>
												<th CL='STD_ASKU94'></th>
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
												<th CL='STD_PTLT01'></th>
												<th CL='STD_PTLT02'></th>
												<th CL='STD_PTLT03'></th>
												<th CL='STD_PTLT04'></th>
												<th CL='STD_PTLT05'></th>
												<th CL='STD_PTLT06'></th>
												<th CL='STD_PTLT07'></th>
												<th CL='STD_PTLT08'></th>
												<th CL='STD_PTLT09'></th>
												<th CL='STD_PTLT10'></th>
												<th CL='STD_PTLT11'></th>
												<th CL='STD_PTLT12'></th>
												<th CL='STD_PTLT13'></th>
												<th CL='STD_PTLT14'></th>
												<th CL='STD_PTLT15'></th>
												<th CL='STD_PTLT16'></th>
												<th CL='STD_PTLT17'></th>
												<th CL='STD_PTLT18'></th>
												<th CL='STD_PTLT19'></th>
												<th CL='STD_PTLT20'></th>
												<th CL='STD_AWMSNO'></th>
												<th CL='STD_AWMSTS'></th>
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
												<th CL='STD_SSORIT,2'></th>
												<th CL='STD_SMBLNR'></th>
												<th CL='STD_SZEILE'></th>
												<th CL='STD_SMJAHR'></th>
												<th CL='STD_SXBLNR'></th>
												<th CL='STD_SAPSTS'></th>
												<th CL='STD_DOORKY'></th>
												<th CL='STD_PASTKY'></th>
												<th CL='STD_ALSTKY'></th>
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
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
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
												<td GCol="rowCheck"></td>
												<td GCol="text,TASKKY"></td>
												<td GCol="text,TASKIT"></td>
												<!-- <td GCol="text,STOKKY"></td> -->
												<td GCol="text,WAREKY"></td>
												<td GCol="text,AREAKY"></td>
												<td GCol="text,AVAILABLEQTY" GF="N"></td>
												<td GCol="text,TASKTY"></td>
												<td GCol="text,STATIT"></td>
												<td GCol="select,RSNCOD">
													<select ReasonCombo="320">
														<option value=""> </option>
													</select>
												</td>
												<td GCol="input,TASRSN" GF="S 255"></td>
												<td GCol="input,QTTAOR" GF="N 20,3" validate="max(GRID_COL_AVAILABLEQTY_*)"></td>
												<td GCol="text,QTCOMP"></td>
												<td GCol="text,OWNRKY"></td>
												<td GCol="text,SKUKEY"></td>
												<td GCol="text,DESC01"></td>
												<td GCol="text,DESC02"></td>
												<td GCol="text,LOTNUM"></td>
												<td GCol="text,ACTCDT"></td>
												<td GCol="text,ACTCTI"></td>
												<td GCol="text,QTYUOM" GF="N"></td>
												<td GCol="text,TKFLKY"></td>
												<td GCol="text,STEPNO"></td>
												<td GCol="text,LSTTFL"></td>
												<td GCol="text,LOCASR"></td>
												<td GCol="text,SECTSR"></td>
												<td GCol="text,PAIDSR"></td>
												<td GCol="text,TRNUSR"></td>
												<td GCol="text,STRUTY"></td>
												<td GCol="text,SMEAKY"></td>
												<td GCol="text,SUOMKY"></td>
												<td GCol="text,QTSPUM"></td>
												<td GCol="text,SDUOKY"></td>
												<td GCol="text,QTSDUM"></td>
												<td GCol="input,LOCATG,SHLOCMA" GF="S 20"></td>
												<td GCol="text,AREATG"></td>
												<td GCol="text,SECTTG"></td>
												<td GCol="text,PAIDTG"></td>
												<td GCol="input,TRNUTG" GF="S 20"></td>
												<td GCol="text,TTRUTY"></td>
												<td GCol="text,TMEAKY"></td>
												<td GCol="text,TUOMKY"></td>
												<td GCol="text,QTTPUM"></td>
												<td GCol="text,TDUOKY"></td>
												<td GCol="text,QTTDUM"></td>
												<td GCol="text,LOCAAC"></td>
												<td GCol="text,SECTAC"></td>
												<td GCol="text,PAIDAC"></td>
												<td GCol="text,TRNUAC"></td>
												<td GCol="text,ATRUTY"></td>
												<td GCol="text,AMEAKY"></td>
												<td GCol="text,AUOMKY"></td>
												<td GCol="text,QTAPUM"></td>
												<td GCol="text,ADUOKY"></td>
												<td GCol="text,QTADUM"></td>
												<td GCol="text,REFDKY"></td>
												<td GCol="text,REFDIT"></td>
												<td GCol="text,REFCAT"></td>
												<td GCol="text,REFDAT"></td>
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
												<td GCol="text,PHYIKY"></td>
												<td GCol="text,PHYIIT"></td>
												<td GCol="text,DROPID"></td>
												<td GCol="text,ASKU01"></td>
												<td GCol="text,ASKU02"></td>
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
												<td GCol="text,LOTA11" GF="C N"></td>
												<td GCol="text,LOTA12" GF="C N"></td>
												<td GCol="text,LOTA13" GF="C N"></td>
												<td GCol="text,LOTA14"></td>
												<td GCol="text,LOTA15"></td>
												<td GCol="text,LOTA16" GF="N"></td>
												<td GCol="text,LOTA17" GF="N"></td>
												<td GCol="text,LOTA18" GF="N"></td>
												<td GCol="text,LOTA19" GF="N"></td>
												<td GCol="text,LOTA20" GF="N"></td>
												<td GCol="text,PTLT01"></td>
												<td GCol="text,PTLT02"></td>
												<td GCol="text,PTLT03"></td>
												<td GCol="text,PTLT04"></td>
												<td GCol="text,PTLT05"></td>
												<td GCol="text,PTLT06"></td>
												<td GCol="text,PTLT07"></td>
												<td GCol="text,PTLT08"></td>
												<td GCol="text,PTLT09"></td>
												<td GCol="text,PTLT10"></td>
												<td GCol="text,PTLT11"></td>
												<td GCol="text,PTLT12"></td>
												<td GCol="text,PTLT13"></td>
												<td GCol="text,PTLT14"></td>
												<td GCol="text,PTLT15"></td>
												<td GCol="text,PTLT16"></td>
												<td GCol="text,PTLT17"></td>
												<td GCol="text,PTLT18"></td>
												<td GCol="text,PTLT19"></td>
												<td GCol="text,PTLT20"></td>
												<td GCol="text,AWMSNO"></td>
												<td GCol="text,AWMSTS"></td>
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
												<td GCol="text,DOORKY"></td>
												<td GCol="text,PASTKY"></td>
												<td GCol="text,ALSTKY"></td>
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