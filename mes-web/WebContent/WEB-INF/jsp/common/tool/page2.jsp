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
		
		gridList.setGrid({
	    	id : "gridListItem",
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
		
		param.put("sql", param.get("sql2"));
		gridList.gridList({
	    	id : "gridListItem",
	    	param : param
	    });
	}
	
	function saveData(){
		if(gridList.validationCheck("gridList", "all")){
			var list = gridList.getGridAvailData("gridList");
			var list2 = gridList.getGridAvailData("gridListItem");
			var param = inputList.setRangeParam("searchArea");
			param.put("list", list);
			param.put("list2", list2);
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
			<button CB="GetVariant GETVARIANT BTN_GETVARIANT"></button>
			<button CB="SaveVariant SAVEVARIANT BTN_SAVEVARIANT"></button>
		</p>
		<div class="searchInBox">
			<h2 class="tit" CL="STD_HEADGRID"></h2>
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
		<div class="searchInBox">
			<h2 class="tit" CL="STD_ITEMGRID"></h2>
			<table class="table type1">
				<colgroup>
					<col width="100" />
					<col />
				</colgroup>
				<tbody>
					<tr>
						<th>MODULE</th>
						<td>
							<input type="text" name="MODULE2" validate="required" IAname="MODULE"/>
						</td>
					</tr>
					<tr>
						<th>COMMAND</th>
						<td>
							<input type="text" name="COMMAND2" validate="required" IAname="COMMAND"/>
						</td>
					</tr>
					<tr>
						<th>TABLE</th>
						<td>
							<textarea rows="10" cols="100" name="sql2" validate="required"></textarea>
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
						<li><a href="#tabs1-1"><span CL="STD_GENERAL"></span></a></li>
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
				</div>
			</div>

			<div class="bottomSect bottom">
				<button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button>
				<div class="tabs">
					<ul class="tab type2" id="commonMiddleArea">
						<li><a href="#tabs1-1"><span CL='STD_SEARCH'></span></a></li>
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
										<tbody id="gridListItem">
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