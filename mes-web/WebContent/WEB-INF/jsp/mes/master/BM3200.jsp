<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript">
	<%-- $(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
	    	name : "gridList",
			editable : true,
			pkcol : "PLANT,MATCODE",
			module : "WmsAdmin",
			command : "BM01",
			bindArea : "tabs1-2" 
	    });
	});
	
	function searchHelpEventOpenBefore(searchCode, gridType){
		//commonUtil.debugMsg("searchHelpEventOpenBefore : ", arguments);
		if(searchCode == "SHAREMA"){
			return dataBind.paramData("searchArea");
		}else if(searchCode == "SHWAHMA"){
			return dataBind.paramData("searchArea");
		}
	}
	function searchList(){
		//var param = dataBind.paramData("searchArea");
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			//alert(param);
			gridList.gridList({
				id : "gridList",
				param : param
			});
		}
	}
	
	function saveData(){
		if(gridList.validationCheck("gridList", "modify")){
			//검색조건을 pram에 추가
			var param = dataBind.paramData("searchArea");
			//그리드의 수정사항(추가)을 list에 저장
			var list = gridList.getModifyData("gridList", "A");
			
			//저장확인 메세지 -> 저장하시겠습니까?
			if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
				return;
			}
			
			var param = new DataMap();
			param.put("list", list);
			
			var json = netUtil.send({
				url : "/mes/master/json/saveBM01.data",
				param : param,
				returnParam : param,
				successFunction : "saveEnd",
				failFunction : "saveFail"
			});
			
		}
	}
	
	function saveEnd(json, param){
		
		if(json && json.data){
			if(json.data != "0"){
				alert(commonUtil.getMsg(configData.MSG_SYSTEM_SAVEOK));
			}else{
				alert(commonUtil.getMsg("COMMON_M0465")); // 저장 실패하였습니다.
			}
			searchList();
		}else{
			alert(commonUtil.getMsg("COMMON_M0465")); // 저장 실패하였습니다.
			searchList();
		}
	}
	
	function saveFail(a, b, c, param){ // a:request, b:status, c:error
		var resultText = a.responseText.trim();
		alert(commonUtil.getMsg("COMMON_M0465")); // 저장 실패하였습니다.
		searchList();
	}
	
 	function gridListEventRowAddBefore(gridId, rowNum){
		var areatyt = inputList.getComboData("AREATY", "STOR");
		var newData = new DataMap();
		newData.put("WAREKY",  "<%=wareky%>");
		//newData.put("AREAKY", "RECV");
		newData.put("AREATY", "STOR");
		newData.put("AREATYT", areatyt);
		
		return newData;
	}  
	
	function gridListEventRowRemove(gridId, rowNum){
		var rowAea = gridList.getColData("gridList", rowNum, "AREAKY");
		  if(gridId == "gridList"){
			var param = new DataMap();
			param.put("AREAKY", rowAea);
			//2020.04.14 
			param.put("WAREKY", "<%=wareky%>");
			var json = netUtil.sendData({
				module : "WmsAdmin",
				command : "AREMAval",
				sendType : "map",
				param : param
			});
			
			if(json && json.data){
				if(json.data["CNT"] >= 1){
					commonUtil.msgBox("VALID_M0017");//구역이 존재하는 영역을 삭제할 수 없습니다.
					return false;
				} else if (json.data["CNT"] == 0){
					return true;
				}
			}
		}  
	} --%>
	
	//미사용여부 확인 에러 발생시 주석해제 22.02.18
	/* function areakyCheck(valueTxt, $colObj){
		var rowNum = gridList.getColObjRowNum("gridList", $colObj);
		var rowCount = gridList.getGridDataCount("gridList");
		for(var i=0;i<rowCount;i++){
			if(i != rowNum){
				var areaky = gridList.getColData("gridList", i, "AREAKY");
				if(areaky == valueTxt){
					return false;
				}
			}			
		}
		return true;
	} */
	
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}
	}
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY"></button>
		<button CB="Save SAVE STD_SAVE"></button>
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
			<!-- <button CB="GetVariant GETVARIANT BTN_GETVARIANT"></button>
			<button CB="SaveVariant SAVEVARIANT BTN_SAVEVARIANT"></button> -->
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
						<th CL="STD_PLANT">플랜트</th>
						<td>
							<input type="text" id="PLANT" name="PLANT" value="100" readonly="readonly" />
						</td>
					</tr>
					<tr>
						<th CL="STD_OPCODE">공정</th>
						<td>
							<input type="text" id="OPCODE" name="OPCODE" UIInput="R,OP"/>
						</td>
					</tr>
					<tr>
						<th CL="STD_OPNAME">공정명</th>
						<td>
							<input type="text" id="OPNAME" name="OPNAME"/>
						</td>
					</tr>
					<tr>
						<th CL="STD_STOPCODE">비가동항목</th>
						<td>
							<input type="text" id="STOPCODE" name="STOPCODE" UIInput="R,STOP"/>
						</td>
					</tr>
					<tr>
						<th CL="STD_STOPNAME">비가동항목명</th>
						<td>
							<input type="text" id="STOPNAME" name="STOPNAME"/>
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
			<button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button>
				<div class="tabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span CL='STD_OPSTOPLIST'>공정 별 비 가동 항목 정보</span></a></li>
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
												<th CL='STD_NUMBER'></th>
												<th CL='STD_PLANT'></th>
												<th CL='STD_OPCODE'></th>
												<th CL='STD_OPNAME'></th>
												<th CL='STD_STOPCODE'></th>
												<th CL='STD_STOPNAME'></th>
												<th CL='STD_STOPTYPE'></th>
												<th CL='STD_MAKEDATE'></th>
												<th CL='STD_MAKETIME'></th>
												<th CL='STD_MAKEID'></th>
												<th CL='STD_MAKENAME'></th>
												<th CL='STD_EDITDATE'></th>
												<th CL='STD_EDITTIME'></th>
												<th CL='STD_EDITID'></th>
												<th CL='STD_EDITNAME'></th>
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
												<td GCol="rownum"></td>
												<td GCol="text,PLANT"></td>
												<td GCol="input,OPCODE" id="OPCODE" validate="required"></td>
												<td GCol="text,OPNAME"></td>
												<td GCol="input,STOPCODE" id="OPCODE" validate="required"></td>
												<td GCol="text,STOPNAME"></td>
												<td GCol="text,STOPTYPE"></td>
												<td GCol="text,MAKEDATE"></td>
												<td GCol="text,MAKETIME"></td>
											    <td GCol="text,MAKEID"></td>
												<td GCol="text,MAKENAME"></td>
												<td GCol="text,EDITDATE"></td>
												<td GCol="text,EDITTIME"></td>
												<td GCol="text,EDITID"></td>
												<td GCol="text,EDITNAME"></td>
											</tr>									
										</tbody>
									</table>
								</div>
							</div>
							<div class="tableUtil">
								<div class="leftArea">
									<button type="button" GBtn="find"></button>
									<button type="button" GBtn="up"></button>
									<button type="button" GBtn="down"></button>
									<button type="button" GBtn="add"></button>
									<button type="button" GBtn="delete"></button>
									<button type="button" GBtn="layout"></button>
									<button type="button" GBtn="excel"></button>
									<button type="button" GBtn="sortReset"></button>
									<button type="button" GBtn="copy"></button>
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