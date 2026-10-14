<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			module : "Demo",
			command : "JLBLM"
	    });
	});
	
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			
			var json = netUtil.send({
				url : "/demo/sample2/json/list.data",
				param : param,
				bindType : "grid",
				bindId : "gridList",
				sendType : "list"
			});

			/*
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
			*/
		}
	}
	
	function saveData(){
		if(gridList.validationCheck("gridList", "all")){
			var json = gridList.gridSave({
		    	id : "gridList"
		    });
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
	<div class="util3">
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
			<h2 class="tit" CL="STD_SELECTOPTIONS"></h2>
			<table class="table type1">
				<colgroup>
					<col width="100" />
					<col />
				</colgroup>
				<tbody>
					<tr>
						<th CL="STD_LANGKY"></th>
						<td>
							<select name="LANGKY" Combo="Demo,LANGKYCOMBO">
								<option value="">선택</option>
							</select>
						</td>
					</tr>
					<tr>
						<th CL="STD_LABLGR"></th>
						<td>
							<input type="text" name="LABLGR" IAname="LABLGR"/>
						</td>
					</tr>
					<tr>
						<th CL="STD_LABLKY"></th>
						<td>
							<input type="text" name="LABLKY" IAname="LABLKY"/>
						</td>
					</tr>
					<tr>
						<th CL="STD_LBLTXL"></th>
						<td>
							<input type="text" name="LBLTXL" UIInput="R" IAname="LBLTXL"/>
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
						<li><a href="#tabs1-1"><span CL='STD_SEARCH'>탭메뉴1</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
											<col width="40" />
											<col width="40" />
											<col width="80" />
											<col width="100" />
											<col width="100" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="100" />
											<col width="100" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<th GBtnCheck="true"></th>
												<th CL='STD_LANGKY'></th>
												<th CL='STD_LABLGR'></th>
												<th CL='STD_LABLKY'></th>
												<th CL='STD_LBLTXS'></th>
												<th CL='STD_LBLTXM'></th>
												<th CL='STD_LBLTXL'></th>
												<th CL='STD_CREDAT'></th>
												<th CL='STD_CRETIM'></th>
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="40" />
											<col width="40" />
											<col width="80" />
											<col width="100" />
											<col width="100" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="100" />
											<col width="100" />
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GCol="rownum"></td>
												<td GCol="rowCheck"></td>
												<td GCol="select,LANGKY">
													<select Combo="Demo,LANGKYCOMBO">
														<option value="">선택</option>
													</select>
												</td>
												<td GCol="text,LABLGR"></td>
												<td GCol="text,LABLKY"></td>
												<td GCol="text,LBLTXS"></td>
												<td GCol="text,LBLTXM"></td>
												<td GCol="text,LBLTXL"></td>
												<td GCol="input,CREDAT" GF="C" validate="required,MASTER_M0434"></td>
												<td GCol="text,CRETIM" GF="T"></td>
											</tr>									
										</tbody>
									</table>
								</div>
							</div>
							<div class="tableUtil">
								<div class="leftArea">
									<button type="button" GBtn="find"></button>
									<button type="button" GBtn="filter"></button>
									<button type="button" GBtn="sortReset"></button>
									<button type="button" GBtn="add"></button>
									<button type="button" GBtn="copy"></button>
									<button type="button" GBtn="delete"></button>
									<button type="button" GBtn="layout"></button>
									<button type="button" GBtn="total"></button>
									<button type="button" GBtn="subTotal"></button>
									<button type="button" GBtn="excel"></button>
									<button type="button" GBtn="excelUpload"></button>
									<button type="button" GBtn="colFix"></button>									
								</div>
								<div class="rightArea">
									<!-- span GCheckInfoArea="true">(0/0)</span-->
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