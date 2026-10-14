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
<script type="text/javascript" src="/common/js/ezgencontrol.js"></script>
<script type="text/javascript">
	var sFlag = true;
	
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
	    	name : "gridList",
			editable : true,
			pkcol : "WAREKY,LOCAKY",
			module : "WmsLabel",
			command : "LB02",
			validation : "ZONEKY,TKZONE",
	    });
		<%-- $("#USERAREA").val("<%=user.getUserg5()%>"); --%>
	});
	
	function searchList(){
		if(validate.check("searchArea")){
			sFlag = true;
			var param = inputList.setRangeParam("searchArea");
			
			if($('input[name="I_INDUPK"]').is(":checked")== true){
				param.put("INDUPK", "V");
			}else{
				param.put("INDUPK", "");
			}
		
			if($('input[name="I_INDUPA"]').is(":checked")== true){
				param.put("INDUPA", "V");
			}else{
				param.put("INDUPA", "");
			}
			
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}
	
	function reportPrint(){
		
		var head = gridList.getSelectData("gridList");
		
		if (head.length == 0){
			commonUtil.msgBox("VALID_M0006");
			return;
		}
		var url = "";
		var where = "AND (";
		for(var i=0; i<head.length; i++){
			var row = head[i];
			var key = row.get("LOCAKY");
			where += "LOCAKY='"+key+"'";
			if(i==head.length-1) break;
			where += " OR ";	
		}
		where += ")"; 
		url = "/ezgen/locba_s.ezg";
		
		var map = new DataMap();
		WriteEZgenElement(url, where, "", "<%=langky%>", map, 650, 350);
	}
	
	function searchHelpEventOpenBefore(searchCode, gridType){
		if(searchCode == "SHWAHMA"){
			var param = new DataMap();
			param.put("COMPKY", "<%=compky%>");
			return param;
	    }else if(searchCode == "SHAREMA"){
			var param = new DataMap();
			param.put("WAREKY", "<%=wareky%>");
			return param;
		}else if(searchCode == "SHZONMA"){
			var param = new DataMap();
			param.put("WAREKY", "<%=wareky%>");
			return param;
		}else if(searchCode == "SHLOCMA"){
			var param = new DataMap();
			param.put("WAREKY", "<%=wareky%>");
			return param;
		}
	}
	
	function commonBtnClick(btnName){
		if(btnName == "Print"){
			reportPrint();
		}else if(btnName == "Search"){
			searchList();
		}
	}

	function gridExcelDownloadEventBefore(gridId){
		if(gridId == "gridList"){
			var param = inputList.setRangeParam("searchArea");
			param.put(configData.DATA_EXCEL_REQUEST_FILE_NAME, "LB02Item");
			return param;
		}
	}
</script>
</head>
<body>

<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY"></button>
		<button CB="Print PRINT BTN_LOCPRINT"></button>
	</div>
	<div class="util2">
		<button class="button type2" id="showPop" type="button"><img src="/common/images/ico_btn4.png" alt="List" /></button>
	</div>
</div>

<!-- searchPop -->
<div class="searchPop">

	<button type="button" class="closer">X</button>
	<div class="searchInnerContainer" id="searchArea">
	
		<p class="util">
			<button CB="Search SEARCH BTN_DISPLAY"></button>
		</p>

		<div class="searchInBox">
			<h2 class="tit" CL="STD_SELECTOPTIONS">검색조건</h2>
			<table class="table type1">
				<colgroup>
					<col width="7%" />
					<col width="7%" />
					<col width="7%" />
					<col />
				</colgroup>
				<tbody>
					<tr>
						<th CL="STD_WAREKY">거점</th>
						<td>
							<input type="text" name="WAREKY" value="<%=wareky%>" readonly style="width: 134px"/>
						</td>
					</tr>
					<tr>
						<th CL="STD_AREAKY">영역</th>
						<td GCol="select,AREAKY">
							<select Combo="WmsAdmin,AREACOMBO" name="AREAKY" style="width: 134px"id="USERAREA"></select>
						</td>
						</tr>
					<tr>
						<th CL="STD_ZONEKY">구역</th>
						<td>
							<input type="text" name="ZONEKY" UIInput="R,SHZONMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_TKZONE">작업구역</th>
						<td>
							<input type="text" name="TKZONE" UIInput="R" />
						</td>
					</tr>
					<tr>
						<th CL="STD_LOCAKY">지번</th>
						<td>
							<input type="text" name="LOCAKY" UIInput="R,SHLOCMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_LOCATY">로케이션유형</th>
						<td GCol="select,LOCATY">
							<select CommonCombo="LOCATY" name="LOCATY" style="width: 134px">
							</select>
						</td>
					</tr>
					<tr>
						<th CL="STD_STATUS">상태</th>
						<td GCol="select,STATUS">
							<select CommonCombo="STATUS" name="STATUS" style="width: 134px">
							</select>
						</td>
					</tr>
					<tr>
						<th CL="STD_INDUPK">입고가능</th>
						<td>
							<input type="checkbox" name="I_INDUPK" checked="checked" />
						</td>
						<th CL="STD_INDUPA">파킹가능</th>
						<td>
							<input type="checkbox" name="I_INDUPA" checked="checked" />
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
						<li><a href="#tabs1-1"><span CL='STD_ITEMLIST'>Item리스트</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
											<col width="50" />
											<col width="50" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<!-- <col width="100" /> -->
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<!-- <col width="100" />
											<col width="100" /> -->
											<col width="100" />
											<col width="100" />
											<!-- <col width="100" />
											<col width="100" />
											<col width="100" /> -->
											<col width="100" />
											<!-- <col width="100" /> -->
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
											<col width="100" />  -->
											<col width="100" />
											<col width="100" />
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
												<th CL='STD_WAREKY'></th>
												<th CL='STD_LOCAKY'></th>
												<th CL='STD_LOCATY'></th>
												<th CL='STD_SHORTX'></th>
												<!-- <th CL='STD_TASKTY'></th> -->
												<th CL='STD_ZONEKY'></th>
												<th CL='STD_TKZONE'></th>
												<th CL='STD_AREAKY'></th>
												<!-- <th CL='STD_FACLTY'></th>
												<th CL='STD_ARLVLL'></th> -->
												<th CL='STD_INDCPC'></th>
												<th CL='STD_INDTUT'></th>
												<!-- <th CL='STD_IBROUT'></th>
												<th CL='STD_OBROUT'></th>
												<th CL='STD_RPROUT'></th> -->
												<th CL='STD_STATUS'></th>
												<!-- <th CL='STD_ABCANV'></th> -->
												<th CL='STD_LENGTH'></th>
												<th CL='STD_WIDTHW'></th>
												<th CL='STD_HEIGHT'></th>
												<th CL='STD_CUBICM'></th>
												<th CL='STD_MAXCPC'></th>
												<!-- <th CL='STD_MAXQTY'></th>
												<th CL='STD_MAXWGT'></th>
												<th CL='STD_MAXLDR'></th>
												<th CL='STD_MAXSEC'></th>
												<th CL='STD_MIXSKU'></th>
												<th CL='STD_MIXLOT'></th>
												<th CL='STD_RPNCAT'></th>
												<th CL='STD_INDQTC'></th>
												<th CL='STD_QTYCHK'></th>
												<th CL='STD_NEDSID'></th> -->
												<th CL='STD_INDUPA'></th>
												<th CL='STD_INDUPK'></th>
												<!-- <th CL='STD_AUTLOC'></th> -->
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
											<col width="50" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<!-- <col width="100" /> -->
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<!-- <col width="100" />
											<col width="100" /> -->
											<col width="100" />
											<col width="100" />
											<!-- <col width="100" />
											<col width="100" />
											<col width="100" /> -->
											<col width="100" />
											<!-- <col width="100" /> -->
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
											<col width="100" />  -->
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
											
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GCol="rownum"></td>
												<td GCol="rowCheck"></td>
												<td GCol="text,WAREKY"></td>
												<td GCol="text,LOCAKY"></td>
												<td GCol="select,LOCATY">
													<select CommonCombo="LOCATY"></select>
												</td>
												<td GCol="text,SHORTX"></td>
												<!-- <td GCol="text,TASKTY"></td> -->
												<td GCol="text,ZONEKY"></td>
												<td GCol="text,TKZONE"></td>
												<td GCol="text,AREAKY"></td>
												<!-- <td GCol="text,FACLTY"></td>
												<td GCol="text,ARLVLL"></td> -->
												<td GCol="check,INDCPC"></td>
												<td GCol="check,INDTUT"></td>
												<!-- <td GCol="text,IBROUT"></td>
												<td GCol="text,OBROUT"></td>
												<td GCol="text,RPROUT"></td> -->
												<td GCol="select,STATUS">
													<select CommonCombo="STATUS"></select>
												</td>
												<!-- <td GCol="text,ABCANV"></td> -->
												<td GCol="text,LENGTH"></td>
												<td GCol="text,WIDTHW"></td>
												<td GCol="text,HEIGHT"></td>
												<td GCol="text,CUBICM"></td>
												<td GCol="text,MAXCPC"></td>
										   <!-- <td GCol="text,MAXQTY"></td>
												<td GCol="text,MAXWGT"></td>
												<td GCol="text,MAXLDR"></td>
												<td GCol="text,MAXSEC"></td>
												<td GCol="text,MIXSKU"></td>
												<td GCol="text,MIXLOT"></td>
												<td GCol="text,RPNCAT"></td>
												<td GCol="text,INDQTC" ></td>
												<td GCol="text,QTYCHK"></td>
												<td GCol="text,NEDSID"></td> -->
												<td GCol="check,INDUPA"></td>
												<td GCol="check,INDUPK"></td>
												<!-- <td GCol="text,AUTLOC"></td> -->
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