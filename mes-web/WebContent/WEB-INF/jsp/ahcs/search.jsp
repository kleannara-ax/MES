<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.common.bean.DataMap,com.common.bean.DataMap,java.util.*"%>
<%
	DataMap param = (DataMap)request.getAttribute("param");
	DataMap head = (DataMap)request.getAttribute("head");
	List itemList = (List)request.getAttribute("itemList");
	
	DataMap dm = (DataMap)param.get("SES_USER_INFO_ID");
	
	String area = dm.getString("AREA");
	
	TreeMap search = new TreeMap();
	TreeMap grid = new TreeMap();
	
	String returnParam = null;
	DataMap row;
	for(int i=0;i<itemList.size();i++){
		row = (DataMap)itemList.get(i);
		if(row.getString("INDRVL").equals("V")){
			returnParam = row.getString("DBFILD");
		}
		if(row.getString("INDUSO").equals("V")){
			search.put(row.getString("POSSOS"), new Integer(i));
		}
		if(row.getString("INDULS").equals("V")){
			grid.put(row.getString("POSLIS"),  new Integer(i));
		}
	}
	
	String title = head.getString("SHORTX");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title><%=title%></title>
<%@ include file="/common/include/searchHead.jsp" %>
<script type="text/javascript">
	configData.MENU_ID = '<%=param.getString("SHLPKY")%>';

	window.resizeTo('<%=head.getString("WIDTHW")%>','<%=head.getString("HEIGHT")%>');
	
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
	    	editable : true,
	    	//module : "Common",
			//command : "SEARCH",
			url : "/common/search/json/data.data",
			bigdata : false,
			dataRequest : true
			//url : "/common/json/searchSql.data"
	    });	
		

		<%
			if(head.containsKey("EXECTY") && "V".equals(head.getString("EXECTY")) ){
		%>
			searchList();
		<%
			}
		%>
		
	});
	
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeDataParam("searchArea");
			var inputParam = dataBind.paramData("searchArea");
			param.put(configData.INPUT_SEARCH_PARAM_KET, inputParam);
			if($.trim(dwhere)){
				param.put("WHARE_SQL", dwhere);
			}
	
			param.put("SHLPKY","<%=param.getString("SHLPKY")%>");
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
		
		//showSearch();
	}
	
	function searchHelpEventCloseAfter(searchCode, multyType, selectData, rowData){
		try{
			window.opener.searchHelpEventCloseAfter(searchCode, multyType, selectData, rowData);
		}catch(e){
		}
	}
	
	function gridListEventRowDblclick(gridId, rowNum){
		if(gridId != "gridList"){
			return;
		}
		var rowData = gridList.getRowData(gridId, rowNum);
	<%
		if(param.containsKey("multyType")){
	%>
		var dataList = new Array();
		dataList.push(rowData.get("<%=returnParam%>"));
		
		var rowList = new Array();
		rowList.push(rowData);
		
		window.opener.page.returnSearchHelp(dataList);
		searchHelpEventCloseAfter(configData.MENU_ID, true, dataList, rowList);
	<%
		}else{
	%>
		window.opener.page.returnSearchHelp(rowData.get("<%=returnParam%>"));
		searchHelpEventCloseAfter(configData.MENU_ID, false, rowData.get("<%=returnParam%>"), rowData);
	<%
		}
	%>
		this.close();
	}
	
	function multiSelect(){
		var selectData = gridList.getSelectData("gridList");
		var rowData;
		var dataList = new Array();
		for(var i=0;i<selectData.length;i++){
			rowData = selectData[i];
			dataList.push(rowData.get("<%=returnParam%>"));
		}
		window.opener.page.returnSearchHelp(dataList);
		searchHelpEventCloseAfter(configData.MENU_ID, true, dataList, selectData);
		this.close();
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
		<button class="button type2" id="showPop" type="button"><img src="/common<%=theme%>/images/ico_btn4.png" alt="List" /></button>
	</div>
</div>

<!-- searchPop -->
<div class="searchPop" id="searchArea">
	<button type="button" class="closer">X</button>
	<div class="searchInnerContainer">
		<p class="util searchBtn">
			<button CB="Search SEARCH BTN_DISPLAY"></button>
		</p>
		<div class="searchInBox">
			<h2 class="tit" CL="STD_SELECTOPTIONS"></h2>
			<table class="table type1">
				<colgroup>
					<col width="100" />
					<col />
				</colgroup>
				<tbody>
				<%
					Iterator skey = search.keySet().iterator();
					String ltype = "1";
					String dfValue;
					while (skey.hasNext()) {
						String key = skey.next().toString();
						row = (DataMap)itemList.get(((Integer)search.get(key)).intValue());
						if(row.getString("LBTXTY").equals("M")){
							ltype = "2";
						}else if(row.getString("LBTXTY").equals("L")){
							ltype = "3";
						}else{
							ltype = "1";
						}
						
						dfValue = row.getString("DFVSOS").trim();
						if(!dfValue.equals("")){
							dfValue = "value='"+dfValue+"' ";
						}
				%>
					<tr>
						<th CL="<%=row.getString("LABLGR")+"_"+row.getString("LABLKY")+","+ltype%>"></th>
						<td>
							<%
								if(row.getString("OBJETY").equals("CHB")){
							%>
								<input type="checkbox" name="<%=row.getString("DBFILD")%>" value="V" <%if( row.getString("INDNED").equals("V")){ %> disabled="disabled" <%}%>/>
							<%
								}else if(row.getString("OBJETY").equals("DAT")){
							%>
								<input type="text" <%=dfValue%>name="<%=row.getString("DBFILD")%>" UIInput="R" UIFormat="C N" <%if( row.getString("INDNED").equals("V")){ %> readonly="readonly" <%}%>/>
							<%
								}else if(row.getString("OBJETY").equals("TXT") && row.getString("SHLPKY").equals(" ")){
							%>
								<input type="text" <%=dfValue%>name="<%=row.getString("DBFILD")%>" <%if( row.getString("RQFLDS").equals("V")){ %> validate="required" <%}%> />
							<%
								}else if(row.getString("OBJETY").equals("TXT") && !row.getString("SHLPKY").equals(" ")){
							%>
								<input type="text" <%=dfValue%>name="<%=row.getString("DBFILD")%>" UIInput="S,<%=row.getString("SHLPKY")%>" <%if( row.getString("RQFLDS").equals("V")){ %> validate="required" <%}%> />
							<%
								}else if(row.getString("OBJETY").equals("RNG") && row.getString("SHLPKY").equals(" ")){
							%>
								<input type="text" <%=dfValue%>name="<%=row.getString("DBFILD")%>" UIInput="R" <%if( row.getString("RQFLDS").equals("V")){ %> validate="required" <%}%> />
							<%
								}else if(row.getString("OBJETY").equals("RNG") && !row.getString("SHLPKY").equals(" ")){
							%>
								<input type="text" <%=dfValue%>name="<%=row.getString("DBFILD")%>" UIInput="R,<%=row.getString("SHLPKY")%>" <%if( row.getString("RQFLDS").equals("V")){ %> validate="required" <%}%> />
							<%
								}else if(row.getString("SHLPKY").equals(" ")){
							%>
								<input type="text" <%=dfValue%>name="<%=row.getString("DBFILD")%>" UIInput="R" <%if( row.getString("INDNED").equals("V")){ %> readonly="readonly" <%}%>/>
							<%
								}else if(!row.getString("SHLPKY").equals(" ") && !row.getString("SHLPKY").equals(param.getString("SHLPKY")) && !row.getString("INDNED").equals("V")){
							%>
								<input type="text" <%=dfValue%>name="<%=row.getString("DBFILD")%>" UIInput="R,<%=row.getString("SHLPKY")%>" <%if( row.getString("RQFLDS").equals("V")){ %> validate="required" <%}%> />
							<%
								}else{
							%>
								<input type="text" <%=dfValue%>name="<%=row.getString("DBFILD")%>" <%if( row.getString("RQFLDS").equals("V")){ %> validate="required" <%}%> <%if( row.getString("INDNED").equals("V")){ %> readonly="readonly" <%}%> />
							<%
								}
							%>
						</td>
					</tr>
				<%
						}
				%>
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
										<%
											if(param.containsKey("multyType")){
										%>
											<col width="40" />
										<%
											}
										%>
											
										<%
											skey = grid.keySet().iterator();
											while (skey.hasNext()) {
												String key = skey.next().toString();
												 
												row = (DataMap)itemList.get(((Integer)grid.get(key)).intValue());
												
												if( row.getInt("DBLENG") != row.getInt("OUTLEN") && row.getInt("OUTLEN") >= 70 ) {
										%>
											<col width="<%=row.getInt("OUTLEN")%>" />
										<%
												}else{
										%>
											<col width="70" />
										<%
												}
											}
										%>
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
										<%
											if(param.containsKey("multyType")){
										%>
											<th GBtnCheck="true"></th>
										<%
											}
										%>
										
										<%
											skey = grid.keySet().iterator();
											while (skey.hasNext()) {
												String key = skey.next().toString();
												row = (DataMap)itemList.get(((Integer)grid.get(key)).intValue());
										%>
											<th CL="<%=row.getString("LABLGR")+"_"+row.getString("LABLKY")+","+ltype%>"></th>
										<%
											}
										%>
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="40" />
										<%
											if(param.containsKey("multyType")){
										%>
											<col width="40" />
										<%
											}
										%>
										
										<%
											skey = grid.keySet().iterator();
											while (skey.hasNext()) {
												String key = skey.next().toString();
												 
												row = (DataMap)itemList.get(((Integer)grid.get(key)).intValue());
												
												if( row.getInt("DBLENG") != row.getInt("OUTLEN") && row.getInt("OUTLEN") >= 70) {
										%>
											<col width="<%=row.getInt("OUTLEN")%>" />
										<%
												}else{
										%>
											<col width="70" />
										<%
												}
											}
										%>
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
											<%
												if(param.containsKey("multyType")){
											%>
												<td GCol="rowCheck"></td>
											<%
												}
											%>
												
											<%
												skey = grid.keySet().iterator();
												while (skey.hasNext()) {
													String key = skey.next().toString();
													row = (DataMap)itemList.get(((Integer)grid.get(key)).intValue());
													
													if( row.getInt("DBLENG") != row.getInt("OUTLEN") ) {
													  ;
													}
											%>
												<td GCol="text,<%=row.getString("DBFILD")%>"></td>
											<%
												}
											%>
											</tr>									
										</tbody>
									</table>
								</div>
							</div>
							<div class="tableUtil">
								<div class="leftArea">
									<%
										if(param.containsKey("multyType")){
									%>
										<button class="button type4" type="button" title="select" onClick="multiSelect()"><img src="/common<%=theme%>/images/grid_icon_01.png" /></button>
									<%
										}
									%>
									<button type="button" GBtn="find"></button>
									<button type="button" GBtn="sortReset"></button>
									<button type="button" GBtn="layout"></button>
								</div>
								<div class="rightArea">
									<p class="record" GInfoArea="true">17 Record</p>
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
<!-- layerPop -->
<div class="layerPopup box_wrapper">
	<button type="button" class="closer">X</button>
	<div class="tabs" id="rangePopupTabs">
		<ul class="selection">
			<li><a href="#tab1"><img src="/common<%=theme%>/images/ico_t1.png" alt="" /> Single values(Inc)</a></li>
			<li><a href="#tab2"><img src="/common<%=theme%>/images/ico_t2.png" alt="" /> Ranges(Inc)</a></li>
		</ul>
		<div id="tab1">
		<div class="table type2 section" >
			<div class="tableHeader tbl_space tbl_small">
				<table>
					<colgroup>
						<col width="40px" />
						<col width="40px" />
						<col width="250px" />
					</colgroup>
					<thead>
						<tr>
							<th>Num</th>
							<th>Oper</th>
							<th>Single</th>
						</tr>
					</thead>
				</table>
			</div>
			<div class="tableBody tbl_small">
				<table>
					<colgroup>
						<col width="40px" />
						<col width="40px" />
						<col width="250px" />
					</colgroup>
					<tbody id="rangeSingleList">
						<tr CGRow="true">
							<td GCol="rownum">1</td>
							<td GCol="select,OPER" class="ico">
								<select>
									<option value="E">=</option>
									<option value="N">≠</option>
									<option value="LT">＜</option>
									<option value="GT">＞</option>
									<option value="LE">≤</option>
									<option value="GE">≥</option>
								</select>
							</td>
							<td GCol="input,DATA">DATA</td>
						</tr>						
					</tbody>
				</table>
			</div>
		</div>
			<div class="tableUtil btn_wrap">
				<div class="leftArea">
					<button class="button type2" type="button" onClick="rangeObj.confirmRange()"><img src="/common<%=theme%>/images/ico_confirm.png" alt="" /> Confirm</button>
					<button class="button type2" type="button" onClick="rangeObj.clearRange('rangeSingleList')"><img src="/common<%=theme%>/images/ico_cancel.png" alt="" /> Clear</button>
				</div>
				<div class="rightArea">
				</div>
			</div>
		</div>
		<div id="tab2">
		<div class="table type2 section">
			<div class="tableHeader tbl_space tbl_big">
				<table>
					<colgroup>
						<col width="41px" />
						<col width="41px" />
						<col width="158px"/>
						<col width="174px"/>
					</colgroup>
					<thead>
						<tr>
							<th>Num</th>
							<th>Oper</th>
							<th>From</th>
							<th>To</th>
						</tr>
					</thead>
				</table>
			</div>
			<div class="tableBody tbl_space tbl_big">
				<table>
					<colgroup>
						<col width="40px" />
						<col width="40px" />
						<col width="155px"/>
						<col width="154px"/>
					</colgroup>
					<tbody id="rangeRangeList">
						<tr CGRow="true">
							<td GCol="rownum">1</td>
							<td GCol="select,OPER" class="ico">
								<select>
									<option value="E">=</option>
									<option value="N">≠</option>
								</select>
							</td>
							<td GCol="input,FROM">FROM</td>
							<td GCol="input,TO">TO</td>
						</tr>						
					</tbody>
				</table>
			</div>
			
		</div>
			<div class="tableUtil btn_wrap">
				<div class="leftArea">
					<button class="button type2" type="button" onClick="rangeObj.confirmRange()"><img src="/common<%=theme%>/images/ico_confirm.png" alt="" /> Confirm</button>
					<button class="button type2" type="button" onClick="rangeObj.clearRange('rangeRangeList')"><img src="/common<%=theme%>/images/ico_cancel.png" alt="" /> Clear</button>
				</div>
				<div class="rightArea">
				</div>
			</div>
		</div>		
	</div>
</div>
<!-- //layerPop -->

<!-- layout Save -->
<div id="layoutSavePop" class="layoutSavePop box_wrap">
	<div>
		<div class="section left box_wrapper">
			<div class="table type3">
				<div class="tableHeader">
					<table>
						<colgroup>
							<col width="200" />
						</colgroup>
						<thead>
							<tr>
								<th>&nbsp;&nbsp;Invisible</th>
							</tr>
						</thead>
					</table>
				</div>
				<div class="tableBody tbl_wrap">
					<table>
						<colgroup>
							<col />
						</colgroup>
						<tbody id="invisibleList">
							<tr CGRow="true">
								<td GCol="text,COLTEXT" layoutColName="GRID_COL_COLNAME_*" layoutColWidth="GRID_COL_COLWIDTH_*"></td>
							</tr>							
						</tbody>                 
					</table>
				</div>
			</div>
		</div>
		<div class="btnGroup btn_wrap">
				<button type="button" onClick="layoutSave.moveLeftAll()" title="leftAll">
					<img src="/common<%=theme%>/images/btn_first.png" />
				</button>
				</br>
				<button type="button" onClick="layoutSave.moveLeft()" title="left">
					<img src="/common<%=theme%>/images/btn_prev.png" />
				</button>
				</br>
				<button type="button" onClick="layoutSave.moveRight()" title="right">
					<img src="/common<%=theme%>/images/btn_next.png" />
				</button>
				</br>
				<button type="button" onClick="layoutSave.moveRightAll()" title="rightAll">
					<img src="/common<%=theme%>/images/btn_last.png" />
				</button>
		</div>
		<div class="section right box_wrapper">
			<div class="table type3">
				<div class="tableHeader">
					<table>
						<colgroup>
							<col width="200" />
						</colgroup>
						<thead>
							<tr>
								<th>&nbsp;&nbsp;Visible</th>
							</tr>
						</thead>
					</table>
				</div>
				<div class="tableBody tbl_wrap">
					<table>
						<colgroup>
							<col width="200" />
						</colgroup>
						<tbody id="visibleList">
							<tr CGRow="true">
								<td GCol="text,COLTEXT" layoutColName="GRID_COL_COLNAME_*" layoutColWidth="GRID_COL_COLWIDTH_*"></td>
							</tr>
						</tbody>                 
					</table>
				</div>
			</div>
		</div>
		</div>
	<div class="layoutSaveTableUtil box_wrap">
			<div class="leftArea" >
				<!-- button class="button type6" type="button" onClick="layoutSave.confirmLayout()" title="Confirm"><img src="/common<%=theme%>/images/ico_confirm.png" /> Confirm</button-->
				<button class="button type6" type="button" onClick="layoutSaveClose()" title="Cancel"><img src="/common<%=theme%>/images/ico_cancel.png" /> Cancel</button>
				<button class="button type6" type="button" onClick="layoutSave.saveLayout()" title="Save"><img src="/common<%=theme%>/images/ico_cancel.png" /> Save</button>
			</div>
			<div class="rightArea">
				<button class="button type4" type="button" GBtnFind="true" title="moveTop" onclick="layoutSave.moveTop()"><img src="/common<%=theme%>/images/btn_up_02.png" /></button>
				<button class="button type4" type="button" GBtnCheck="true" title="moveUp" onclick="layoutSave.moveUp()"><img src="/common<%=theme%>/images/btn_up.png" /></button>									
				<button class="button type4" type="button" GBtnDelete="true" title="moveDown" onclick="layoutSave.moveDown()"><img src="/common<%=theme%>/images/btn_down.png" /></button>
				<button class="button type4" type="button" GBtnAdd="true" title="moveBottom" onclick="layoutSave.moveBottom()"><img src="/common<%=theme%>/images/btn_down_02.png" /></button>
			</div>
		</div>
	</div>
	<div class="contentLoading" id="contentLoading"></div>
<!-- layout Save -->
</div>
</body>
</html>