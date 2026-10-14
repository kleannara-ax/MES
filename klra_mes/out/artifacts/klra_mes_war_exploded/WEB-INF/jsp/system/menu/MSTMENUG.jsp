<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			module : "System",
			command : "MSTMENUG",
			pkcol : "COMPID,MENUGROUPID",
			selectRowDeleteType : true
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
	
	function saveData(){
		if(gridList.validationCheck("gridList", "all")){
			var list = gridList.getModifyData("gridList", "A");
			if(list.length == 0){
				commonUtil.msgBox(configData.MSG_SYSTEM_SAVEEMPTY);
				return;
			}else{
				if(!confirm(commonUtil.getMsg(configData.MSG_MASTER_SAVE_CONFIRM))){
					return;
				}
			}
			
			var param = new DataMap();
			param.put("list", list);
			
			netUtil.send({
				url : "/system/json/saveMstMenuG.data",
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
		}
	}
	
	function gridListEventRowAddBefore(gridId, rowNum, beforeData) {
		if (gridId == "gridList") {
			var newData = new DataMap();
			
			newData.put("COMPID", "<%=compky%>");
			newData.put("DELYN", "N");
			
			return newData;
		}
	}
</script>
<style type="text/css">
 .content_wrap{background: none;}
</style>
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
					<!-- <dl>
						<dt CL="STD_COMPID"></dt>
						<dd>
							<input type="text" class="input" name="COMPID" IAname="Search"/>
						</dd>
					</dl> -->
					<dl>
						<dt CL="STD_MENUGROUPID"></dt>
						<dd>
							<input type="text" class="input" name="M.MENUGROUPID" UIInput="R" IAname="Search"/>
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
			<div class="content_layout tabs">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span>일반</span></a></li>
				</ul>
				<div class="table_box section" id="tab1-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="40" GCol="rowCheck"></td>
										<td GH="80" GCol="input,COMPID" validate="required"></td>
										<td GH="80" GCol="input,MENUGROUPID" validate="required"></td>
										<td GH="150" GCol="input,MENUGLABEL"></td>
										<td GH="80" GCol="input,MENUGNAME"></td>
										<td GH="150" GCol="text,CREATEUSER"></td>
										<td GH="150" GCol="text,CREATEDATE" GF="DTS"></td>
										<td GH="150" GCol="text,UPDATEUSER"></td>
										<td GH="150" GCol="text,UPDATEDATE" GF="DTS"></td>
										<td GH="150" GCol="select,DELETEYN">
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