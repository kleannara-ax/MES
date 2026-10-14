<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			url : "/common/json/SQL_COLOBJ_LIST.data",
			bigdata : false,
			defaultRowStatus : configData.GRID_ROW_STATE_INSERT
	    });
	});
	
	function searchList(){
		var param = inputList.setRangeParam("searchArea");
		
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
	}
	
	function saveData(){
		if(gridList.validationCheck("gridList", "all")){
			var list = gridList.getGridAvailData("gridList");
			var param = inputList.setRangeParam("searchArea");
			param.put("list", list);
			var json = netUtil.sendData({
		    	url : "/common/json/SQL_COLOBJ_SAVE.data",
		    	param : param
		    });
			if(json.MSG && json.MSG != 'OK'){
				var msgList = json.MSG.split(" ");
				var msgTxt = commonUtil.getMsg(msgList[0], msgList.pop());
				commonUtil.msg(msgTxt);
			}else if(json.data){
				commonUtil.msgBox("MASTER_M0564");
			}
			
			page.linkPageOpen("CPAGE");
		}
	}
	
	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}
	}
	
	function searchHelpEventOpenBefore(searchCode, gridType, $inputObj){
		//commonUtil.debugMsg("searchHelpEventOpenBefore : ", arguments);
		if($inputObj.attr(configData.GRID_ID_ATT) == "gridList" && searchCode == "SHLBLKY"){
			var rowNum = $inputObj.attr(configData.GRID_INPUT_ROW_NUM);
			var param = gridList.getRowData("gridList", rowNum);
			param.put("SHLBLGR", param.get("LABLGR"));			
			return param;
		}
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		//commonUtil.debugMsg("gridListEventColValueChange : ", arguments);
		if(gridId == "gridList"){
			if(colName == "LABLKY"){
				var rowData = gridList.getRowData("gridList", rowNum);
				if(rowData.get("LABLGR")){
					var json = netUtil.sendData({
						sendType : "map",
						module : "Common",
						command : "LABLM",
				    	param : rowData
					});
					
					if(json && json.data){
						var LBLTXS = "";
						if(rowData.get("LBTXTY") == "S"){
							LBLTXS = json.data["LBLTXS"];
						}else if(rowData.get("LBTXTY") == "M"){
							LBLTXS = json.data["LBLTXM"];
						}else if(rowData.get("LBTXTY") == "L"){
							LBLTXS = json.data["LBLTXL"];
						}
						
						gridList.setColValue(gridId, rowNum, "LBLTXS", LBLTXS);
						
						if(rowData.get("GLBTXTY") == "S"){
							LBLTXS = json.data["LBLTXS"];
						}else if(rowData.get("GLBTXTY") == "M"){
							LBLTXS = json.data["LBLTXM"];
						}else if(rowData.get("GLBTXTY") == "L"){
							LBLTXS = json.data["LBLTXL"];
						}
						
						gridList.setColValue(gridId, rowNum, "GLBLTXS", LBLTXS);
					}
				}
			}else if(colName == "LBTXTY"){
				var rowData = gridList.getRowData("gridList", rowNum);
				if(rowData.get("LABLGR") && rowData.get("LABLKY")){
					var json = netUtil.sendData({
						sendType : "map",
						module : "Common",
						command : "LABLM",
				    	param : rowData
					});
					if(json && json.data){
						var LBLTXS = "";
						if(rowData.get("LBTXTY") == "S"){
							LBLTXS = json.data["LBLTXS"];
						}else if(rowData.get("LBTXTY") == "M"){
							LBLTXS = json.data["LBLTXM"];
						}else if(rowData.get("LBTXTY") == "L"){
							LBLTXS = json.data["LBLTXL"];
						}
						
						gridList.setColValue(gridId, rowNum, "LBLTXS", LBLTXS);
					}
				}
			}else if(colName == "GLBTXTY"){
				var rowData = gridList.getRowData("gridList", rowNum);
				if(rowData.get("LABLGR") && rowData.get("LABLKY")){
					var json = netUtil.sendData({
						sendType : "map",
						module : "Common",
						command : "LABLM",
				    	param : rowData
					});
					if(json && json.data){
						var LBLTXS = "";
						if(rowData.get("GLBTXTY") == "S"){
							LBLTXS = json.data["LBLTXS"];
						}else if(rowData.get("GLBTXTY") == "M"){
							LBLTXS = json.data["LBLTXM"];
						}else if(rowData.get("GLBTXTY") == "L"){
							LBLTXS = json.data["LBLTXL"];
						}
						
						gridList.setColValue(gridId, rowNum, "GLBLTXS", LBLTXS);
					}
				}
			}else if(colName == "OBJETY"){
				if(colValue == "CHB"){
					gridList.setColValue(gridId, rowNum, "COLTY", "CHECK");
				}else if(colValue == "CAL"){
					gridList.setColValue(gridId, rowNum, "COLTY", "INPUT");
				}else if(colValue == "NFL"){
					gridList.setColValue(gridId, rowNum, "FLDALN", "R");
				}
			}
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
		<p class="searchBtn"><input type="submit" class="button type1 widthAuto" value="검색"  onclick="searchList()" CL="BTN_DISPLAY"/></p>
		<div class="searchInBox">
			<h2 class="tit" CL="STD_SELECTOPTIONS">검색조건</h2>
			<table class="table type1">
				<colgroup>
					<col width="100" />
					<col />
				</colgroup>
				<tbody>
					<tr>
						<th>MODULE</th>
						<td>
							<input type="text" name="MODULE" validate="required" IAname="MODULE"/>
						</td>
					</tr>
					<tr>
						<th>COMMAND</th>
						<td>
							<input type="text" name="COMMAND" validate="required" IAname="COMMAND"/>
						</td>
					</tr>
					<tr>
						<th>TABLE</th>
						<td>
							<textarea rows="10" cols="100" name="sql" validate="required"></textarea>
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
						<li><a href="#tabs1-1"><span>cols</span></a></li>
						<li><a href="#tabs1-2"><span>search</span></a></li>
						<li><a href="#tabs1-3"><span>cols</span></a></li>
						<li><a href="#tabs1-4"><span>head</span></a></li>
						<li><a href="#tabs1-5"><span>rows</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
											<col width="40" />
											<col width="80" />
											<col width="150" />
											<col width="80" />
											<col width="80" />
											<col width="150" />
											<col width="100" />
											<col width="100" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="150" />
											<col width="100" />
											<col width="50" />
											<col width="50" />
											<col width="80" />
											<col width="50" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<th CL='STD_DDICKY'></th>
												<th CL='STD_SHORTX'></th>
												<th CL='STD_LABLGR'></th>
												<th CL='STD_LABLKY'></th>
												<th CL='STD_LBLTXS'></th>
												<th CL='STD_OBJETY'></th>
												<th CL='STD_COLTY'></th>
												<th CL='STD_DBLENG'></th>
												<th CL='STD_DBDECP'></th>
												<th CL='STD_OUTLEN'></th>
												<th CL='STD_OPTION'></th>
												<th CL='STD_SELECTOPTIONS' GBtnCheck="SELECTOPTIONS"></th>
												<th CL='STD_RANGE'></th>
												<th CL='STD_SORTOR'></th>
												<th CL='STD_GRID' GBtnCheck="GRID"></th>
												<th CL='STD_SORTOR'></th>
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="40" />
											<col width="80" />
											<col width="150" />
											<col width="80" />
											<col width="80" />
											<col width="150" />
											<col width="100" />
											<col width="100" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="150" />
											<col width="100" />
											<col width="50" />
											<col width="50" />
											<col width="80" />
											<col width="50" />
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<td GCol="text,DDICKY"></td>
												<td GCol="text,SHORTX"></td>
												<td GCol="input,LABLGR,SHLBLGR" validation="required"></td>
												<td GCol="input,LABLKY,SHLBLKY" validation="required"></td>
												<td GCol="text,LBLTXS"></td>
												<td GCol="select,OBJETY">
													<select CommonCombo="DATATY">
													</select>
												</td>
												<td GCol="select,COLTY">
													<select CommonCombo="COLTY">
													</select>
												</td>
												<td GCol="input,DBLENG" GF="N"></td>
												<td GCol="input,DBDECP" GF="N"></td>
												<td GCol="input,OUTLEN" GF="N" validation="max(500)"></td>
												<td GCol="input,SHLPKY,SHSHLPH"></td>
												<td GCol="check,SELECTOPTIONS"></td>
												<td GCol="check,RANGE"></td>
												<td GCol="input,SELECTORDER" GF="N"></td>
												<td GCol="check,GRID"></td>
												<td GCol="input,GRIDORDER" GF="N"></td>
											</tr>									
										</tbody>
									</table>
								</div>
							</div>
							<div class="tableUtil">
								<div class="leftArea">
									<button type="button" GBtn="find"></button>
									<button type="button" GBtn="sortReset"></button>
									<button type="button" GBtn="add"></button>
									<button type="button" GBtn="copy"></button>
									<button type="button" GBtn="delete"></button>
								</div>
								<div class="rightArea">
									<p class="record" GInfoArea="true">0 Record</p>
								</div>
							</div>
						</div>
					</div>
					<div id="tabs1-2">
						<div class="searchBox">
							<xmp id="searchArea"></xmp>
						</div>
					</div>
					<div id="tabs1-3">
						<div class="searchBox">
							<xmp id="colsArea"></xmp>
						</div>
					</div>
					<div id="tabs1-4">
						<div class="searchBox">
							<xmp id="headArea"></xmp>
						</div>
					</div>
					<div id="tabs1-5">
						<div class="searchBox">
							<xmp id="rowsArea"></xmp>
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