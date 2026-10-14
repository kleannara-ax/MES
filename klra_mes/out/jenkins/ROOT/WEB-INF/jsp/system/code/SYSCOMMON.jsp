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
			command : "SYSCOMMON",
			pkcol : "COMMONID,COMPID",
			itemGrid : "gridListItem",
			itemSearch : true
	    });
		
		gridList.setGrid({
	    	id : "gridListItem",
	    	module : "System",
			command : "SYSCOMMITEM",
			pkcol : "COMMONID,CITEMID",
			emptyMsgType : false
	    });
	});

	function searchList(){
		if(validate.check("searchArea")){
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
			
			gridList.gridList({
		    	id : "gridListItem",
		    	param : param,
		    	pkcol : "COMMONID"
		    });
		}
	}
	
	function saveData(){
		var gridIdArr = ["gridList", "gridListItem"];
		
		var resultCount = 0;
		
		if(!gridList.validationCheck(gridIdArr[0])){
			return;
		}
		
		if(!gridList.validationCheck(gridIdArr[1])){
			return;
		}
		
		var modifyHeadData = gridList.getModifyData(gridIdArr[0]);
		var modifyItemData = gridList.getModifyData(gridIdArr[1]);
		
		if(modifyHeadData.length > 0 || modifyItemData.length > 0){
			if(!confirm(commonUtil.getMsg(configData.MSG_MASTER_SAVE_CONFIRM))){
				return false;
			}
		}else{
			commonUtil.msgBox(configData.MSG_SYSTEM_SAVEEMPTY);
		}
		
		var json = {};
		
		if(modifyHeadData.length > 0){
			json = gridList.gridSave({
		    	id : gridIdArr[0],
		    	modifyType : "A",
		    	msgType : false
		    });
		}
		
		if(modifyItemData.length > 0){
			json = gridList.gridSave({
		    	id : gridIdArr[1],
		    	modifyType : "A",
		    	msgType : false
		    });
		}
		
		resultCount = resultCount + json.data;
		
		if(resultCount > 0){
			commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
			searchList();
		}
	}
	
	function gridListEventRowAddBefore(gridId, rowNum, beforeData) {
		if (gridId == "gridList") {
			var newData = new DataMap();
			
			newData.put("COMPID", "<%=compky%>");
			newData.put("DELYN", "N");
			
			return newData;
		}else if (gridId == "gridListItem") {
			var headFocusRowNum = gridList.getFocusRowNum("gridList");
			if(headFocusRowNum < 0){
				commonUtil.msgBox("선택된 HEAD ROW가 없습니다.");
				return;
			}
			
			var gridInfo = gridList.getRowData("gridList", headFocusRowNum);
			console.log(gridInfo.get("COMMONID"));
			var newData = new DataMap();
			newData.put("COMMONID", gridInfo.get("COMMONID"));
			newData.put("COMPID", "<%=compky%>");
			
			return newData;
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
		}
		
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
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_COMMONID"></dt>
						<dd>
							<input type="text" class="input" name="COMMONID" UIInput="S,SHAREMA" IAname="COMMONID" UIFormat="U"/>
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
					<li class="btn_zoom_wrap">
						<ul>
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
										<td GH="80"  GCol="input,COMMONID"  validate="required"></td>
										<td GH="80"  GCol="input,COMMLABEL"></td>
										<td GH="100" GCol="input,COMMNAME"  validate="required"></td>
										<td GH="80"  GCol="input,COMMTYPE"></td>
										<td GH="80"  GCol="text,CREATEUSER"></td>
										<td GH="100" GCol="text,CREATEDATE" GF="D"></td>
										<td GH="80"  GCol="text,UPDATEUSER"></td>
										<td GH="100" GCol="text,UPDATEDATE" GF="D"></td>
										<td GH="100" GCol="select,DELETEYN">
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
						<button type='button' GBtn="total"></button>
						<button type='button' GBtn="layout"></button>
						<button type='button' GBtn="excel"></button>
						<button type='button' GBtn="excelUpload"></button>
						<span class='txt_total' >총 건수 : <span GInfoArea='true'>4</span></span>
					</div>
				</div>
			</div>
			
			<div class="content_layout tabs bottom_layout">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span>일반</span></a></li>
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
								<tbody id="gridListItem">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="40" GCol="rowCheck"></td>
										<td GH="80" GCol="input,CITEMID"></td>
										<td GH="80" GCol="input,CODELABEL"></td>
										<td GH="100" GCol="input,CODENAME"></td>
										<td GH="80" GCol="input,ITEMTYPE"></td>
										<td GH="80" GCol="input,SORTORDER"></td>
										<td GH="80" GCol="text,CREATEUSER"></td>
										<td GH="100" GCol="text,CREATEDATE"></td>
										<td GH="80" GCol="text,UPDATEUSER"></td>
										<td GH="100" GCol="text,UPDATEDATE"></td>
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
						<button type='button' GBtn="total"></button>
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