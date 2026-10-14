<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/demo_layout.css">
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
	    	module : "System",
			command : "SYSCOMMPOP",
			pkcol : "COMMPOPID",
			itemGrid : "gridList2",
			itemSearch : true,
			selectRowDeleteType : true
	    });
		
		gridList.setGrid({
	    	id : "gridList2",
	    	module : "System",
			command : "SYSCPOPITEM",
			pkcol : "COMMPOPID,CPOPITEMID",
			emptyMsgType : false,
			selectRowDeleteType : true
	    });
	});

	function searchList(){
		if(validate.check("searchArea")){
			gridList.resetGrid("gridList2");
			
			var param = inputList.setRangeParam("searchArea");
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}

	function gridListEventItemGridSearch(gridId, rowNum, itemGridList){
		if(gridId == "gridList"){
			var rowData = gridList.getRowData(gridId, rowNum);
			var param = inputList.setRangeParam("searchArea");
			param.putAll(rowData);
			
			dataBind.dataNameBind(param, "gridListDetail");
			
			gridList.gridList({
		    	id : "gridList2",
		    	param : param,
		    	pkcol : "COMMPOPID"
		    });
		}
	}
	
	function gridListEventRowClick(gridId, rowNum, colName){
		if(gridId == "gridList"){
			var row = gridList.getRowData(gridId, rowNum);
			dataBind.dataNameBind(row, "gridListDetail");
		}
	}
	
	function gridListEventRowAddBefore(gridId, rowNum, beforeData){
		var newData = new DataMap();
		if(gridId == "gridList"){
			newData.put("DELETEYN", "N");
		}else if(gridId == "gridList2"){
			var commpopId = gridList.getColData("gridList", gridList.getFocusRowNum("gridList"), "COMMPOPID");
			
			newData.put("COMMPOPID", commpopId);
			newData.put("ITEMTYPE", "ALL");
			newData.put("SEARCHTYPE", "INPUT");
			newData.put("SFORMAT", "");
			newData.put("GWIDTH", "100");
			newData.put("DELETEYN", "N");
		}
		return newData;
	}
	
	function saveData(){
		if(gridList.validationCheck("gridList", "select")
				&& gridList.validationCheck("gridList2", "select")){
			var head = gridList.getSelectData("gridList", true);
			var item = gridList.getSelectData("gridList2", true);
			
			var gRowStatusAtt = configData.GRID_ROW_STATE_ATT;
			var gRowStatusAttDelete = configData.GRID_ROW_STATE_DELETE;
			
			var headModify = gridList.getModifyList("gridList", "A");
			var headModifyDelete = headModify.filter(function(data){
				return data.get(gRowStatusAtt) == gRowStatusAttDelete;
			});
			if(headModifyDelete.length > 0){
				for(var i in headModifyDelete){
					head.push(headModifyDelete[i]);
				}
			}
			
			var itemModify = gridList.getModifyList("gridList2", "A");
			var itemModifyDelete = itemModify.filter(function(data){
				return data.get(gRowStatusAtt) == gRowStatusAttDelete;
			});
			if(itemModifyDelete.length > 0){
				for(var i in itemModifyDelete){
					item.push(itemModifyDelete[i]);
				}
			}
			
			if(head.length == 0 && item.length == 0){
				commonUtil.msgBox(configData.MSG_SYSTEM_SAVEEMPTY);
				return;
			}else{
				if(!confirm(commonUtil.getMsg(configData.MSG_MASTER_SAVE_CONFIRM))){
					return;
				}
			}
			
			var param = new DataMap();
			param.put("head", head);
			param.put("item", item);
			
			netUtil.send({
				url : "/system/json/saveCommonPop.data",
				param : param,
				successFunction : "saveSuccessCallBack"
			});
		}
	}
	
	function saveSuccessCallBack(json, status){
		if(json && json.data){
			if(json.data > 0){
				commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
				searchList();
			}else{
				commonUtil.msgBox(configData.MSG_SYSTEM_SAVEEMPTY);
			}
		}
	}

	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			var param = new DataMap();
	        param.put("PROGID", "<%= menuId%>");
	        param.put("LGTYPE", "SEARCH");
	        var json = netUtil.sendData({
	            url: "/mes/system/json/saveLog.data",
	            param : param
	        });
			
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}else if(btnName == "Reload"){
			reloadSearch();
		}
	}
	
	function reloadSearch(){
		netUtil.send({
			url : "/common/search/json/reload.data"
		});
	}
</script>
</head>
<body>
<%@ include file="/common/include/webdek/layout.jsp" %>
<!-- content -->
<div class="content_wrap">
	<div class="content_inner">
		<%@ include file="/common/include/webdek/title.jsp" %>
		<div class="content_serch" id="searchArea">
			<div class="btn_wrap">
				<div class="fl_l">
				</div>
				<div class="fl_r">
					<input type="button" CB="Search SEARCH BTN_SEARCH" />
					<input type="button" CB="Save SAVE BTN_SAVE" />
					<input type="button" CB="Reload RESET BTN_REFLBL" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_COMMPOPID"></dt>
						<dd>
							<input type="text" class="input" name="C.COMMPOPID" UIInput="R" IAname="Search" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_DELETEYN"></dt>
						<dd>
							<select name="DELETEYN" class="input" CommonCombo="DELYN" ComboCodeView=false>
								<option value="" CL="STD_ALL"></option>
							</select>
						</dd>
					</dl>
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
        <div class="search_next_wrap">
			<div class="content_layout tabs top_layout">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span>일반</span></a></li>
					<li><a href="#tab1-2"><span>상세</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<!-- <li><button class="btn btn_smaller"><span>축소</span></button></li> -->
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH="40"  GCol="rownum">1</td>
										<td GH="40"  GCol="rowCheck"></td>
										<td GH="120" GCol="input,COMMPOPID" validate="required"></td>
										<td GH="120" GCol="input,CPOPLABEL"></td>
										<td GH="150" GCol="input,CPOPNAME"></td>
										<td GH="150" GCol="input,VIEWTNAME"></td>
										<td GH="200" GCol="input,CPOPDESC"></td>
										<td GH="80"  GCol="input,CPOPTYPE"></td>
										<td GH="80"  GCol="input,SIZEW" GF="NS 4"></td>
										<td GH="80"  GCol="input,SIZEH" GF="NS 4"></td>
										<td GH="80"  GCol="input,EXETYPE"></td>
										<td GH="80"  GCol="text,CREATEUSER"></td>
										<td GH="100" GCol="text,CREATEDATE" GF="DTS"></td>
										<td GH="80"  GCol="text,UPDATEUSER"></td>
										<td GH="100" GCol="text,UPDATEDATE" GF="DTS"></td>
										<td GH="80"  GCol="select,DELETEYN">
											<select class="input" CommonCombo="DELYN" ComboCodeView=false></select>
										</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<div class="btn_lit tableUtil">
						<button type='button' GBtn="find"></button>
						<button type='button' GBtn="sortReset"></button>
						<button type='button' GBtn="add"></button>
						<button type='button' GBtn="copy"></button>
						<button type='button' GBtn="delete"></button>
						<button type='button' GBtn="layout"></button>
						<button type='button' GBtn="excel"></button>
						<button type='button' GBtn="excelUpload"></button>
						<span class='txt_total' >총 건수 : <span GInfoArea='true'>4</span></span>
					</div>
				</div>
				<div class="table_box" id="tab1-2">
					<div class="inner_search_wrap">
						<table class="detail_table">
							<colgroup>
								<col width="14%" />
								<col width="19%" />
								<col width="14%" />
								<col width="19%" />
								<col width="14%" />
								<col width="19%" />
							</colgroup>
							<tbody id="gridListDetail">			
								<tr>
									<th CL="STD_COMMPOPID"></th>
									<td>
										<input type="text" class="input" name="COMMPOPID" UIInput="COMMPOPID" IAname="COMMPOPID" UIFormat="U" readonly />
									</td>
									<th CL="STD_CPOPLABEL"></th>
									<td>
										<input type="text" class="input" name="CPOPLABEL" UIInput="S,SHAREMA" IAname="CPOPLABEL" UIFormat="U" readonly />
									</td>
									<th CL="STD_CPOPNAME"></th>
									<td>
										<input type="text" class="input" name="CPOPNAME" UIInput="S,SHAREMA" IAname="CPOPNAME" UIFormat="U" readonly />
									</td>
								</tr>
								<tr>
									<th CL="STD_VIEWTNAME"></th>
									<td>
										<input type="text" class="input" name="VIEWTNAME" UIInput="S,SHAREMA" IAname="VIEWTNAME" UIFormat="U" readonly />
									</td>
									<th CL="STD_CPOPDESC"></th>
									<td>
										<input type="text" class="input" name="CPOPDESC" UIInput="S,SHAREMA" IAname="CPOPDESC" UIFormat="U" readonly />
									</td>
									<th CL="STD_CPOPTYPE"></th>
									<td>
										<input type="text" class="input" name="CPOPTYPE" UIInput="S,SHAREMA" IAname="CPOPTYPE" UIFormat="U" readonly />
									</td>
								</tr>
								<tr>
									<th CL="STD_EXETYPE"></th>
									<td>
										<input type="text" class="input" name="EXETYPE" UIInput="S,SHAREMA" IAname="EXETYPE" UIFormat="U" readonly />
									</td>
									<th CL="STD_CREATEUSER"></th>
									<td>
										<input type="text" class="input" name="CREATEUSER" UIInput="S,SHAREMA" IAname="CREATEUSER" UIFormat="U" readonly />
									</td>
									<th CL="STD_CREATEDATE"></th>
									<td>
										<input type="text" class="input" name="CREATEDATE" GCol="CREATEDATE" UIFormat="DTS" readonly />
									</td>
								</tr>
								<tr>
									<th CL="STD_UPDATEUSER"></th>
									<td>
										<input type="text" class="input" name="UPDATEUSER" UIInput="S,SHAREMA" IAname="UPDATEUSER" UIFormat="U" readonly/>
									</td>
									<th CL="STD_UPDATEDATE"></th>
									<td>
										<input type="text" class="input" name="UPDATEDATE" GCol="UPDATEDATE" UIFormat="DTS" readonly />
									</td>
									<th CL="STD_DELETEYN"></th>
									<td>
										<select name="DELETEYN" class="input" CommonCombo="DELYN" ComboCodeView=false disabled></select>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
			</div>
			<div class="content_layout tabs bottom_layout">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span>일반</span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-1" >
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridList2">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="40" GCol="rowCheck"></td>
										<td GH="80" GCol="input,COMMPOPID" validate="required"></td>
										<td GH="80" GCol="input,CPOPITEMID" validate="required"></td>
										<td GH="80" GCol="input,CPOPITLABEL"></td>
										<td GH="80" GCol="input,CPOPITNAME"></td>
										<td GH="80" GCol="select,ITEMTYPE">
											<select class="input">
												<option value="ALL">all</option>
												<option value="SEARCH">search</option>
												<option value="GRID">grid</option>
											</select>
										</td>
										<td GH="80" GCol="select,SEARCHTYPE">
											<select class="input">
												<option value="INPUT">input</option>
												<option value="SELECT">select</option>
												<option value="COMBO">combo</option>
												<option value="MULTI">multi</option>
												<option value="CHECK">check</option>
												<option value="LIKE">like</option>
												<option value="HIDDEN">hidden</option>
											</select>
										</td>
										<td GH="80" GCol="select,SFORMAT">
											<select class="input">
												<option value="">string</option>
												<option value="DATE">date</option>
												<option value="UPPER">upper</option>
												<option value="READONLY">readonly</option>
											</select>
										</td>
										<td GH="80" GCol="input,SOPTION"></td>
										<td GH="80" GCol="input,SDEFAULT"></td>
										<td GH="80" GCol="input,SREQUIRED"></td>
										<td GH="80" GCol="input,GWIDTH" validate="required"></td>
										<td GH="80" GCol="input,RETURNCOL"></td>
										<td GH="80" GCol="input,SORTORDER"></td>
										<td GH="80" GCol="text,CREATEUSER"></td>
										<td GH="100" GCol="text,CREATEDATE" GF="DTS"></td>
										<td GH="80" GCol="text,UPDATEUSER"></td>
										<td GH="100" GCol="text,UPDATEDATE" GF="DTS"></td>
										<td GH="60" GCol="select,DELETEYN">
											<select class="input" CommonCombo="DELYN" ComboCodeView=false></select>
										</td>								
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<div class="btn_lit tableUtil">
						<button type='button' GBtn="find"></button>
						<button type='button' GBtn="sortReset"></button>
						<button type='button' GBtn="add"></button>
						<button type='button' GBtn="copy"></button>
						<button type='button' GBtn="delete"></button>
						<button type='button' GBtn="layout"></button>
						<button type='button' GBtn="excel"></button>
						<button type='button' GBtn="excelUpload"></button>
						<span class='txt_total' >총 건수 : <span GInfoArea='true'>4</span></span>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>