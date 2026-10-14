<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript">
	var saveCount = 0;

	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			module : "Demo",
			command : "SYSFILEDEMO"
	    });
		
		gridList.appendCols("gridList", ["UUID_FILEVIEW","ATTACH_FILEVIEW","BYTE_FILESIZEVIEW"]);
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
			}
			
			var fileNotfoundList = list.filter(function(data){
				return ($.trim(data.get("ATTACH")) == "" && data.get(configData.GRID_ROW_STATE_ATT) != "D");
			});
			
			if(fileNotfoundList.length > 0){
				commonUtil.msgBox("VALID_required", [uiList.getLabel("STD_ATTACH")]);
				return;
			}
			
			if(!confirm(commonUtil.getMsg(configData.MSG_MASTER_SAVE_CONFIRM))){
				return false;
			}
			
			var param = new DataMap();
			param.put("list", list);
			alert('1')
			netUtil.send({
				url : "/demo/json/saveSysFileDemo.data",
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
	
	function fileUpload(){
		if(saveCount > 0){
			return;
		}
		
		if(!$("[name=file]").val()){
			commonUtil.msgBox("VALID_required", ["File"]);
			return;
		}
		
		if(!confirm(commonUtil.getMsg(configData.MSG_MASTER_SAVE_CONFIRM))){
			return false;
		}
		
		saveCount++;
		
		var $form = $("#fileUploadForm");
		var formData = new FormData($form[0]);
		formData.append("file",$("#file")[0].files[0]);
		$.ajax({
			url:"/demo/fileUp/file.data",
			data:formData,
			type:"POST",
			enctype:"multipart/form-data",
			processData:false,
			contentType:false,
			dataType:"json",
			error : function(a, b, c){
				saveCount = 0;
				
				var errMsg = a.responseText;
				if(errMsg.indexOf("Session empty") > -1){
					commonUtil.msgBox("세션이 만료되어 로그인 화면으로 이동합니다.");
					window.top.location.href = "/index.jsp";
				}else{
					errMsg = commonUtil.replaceAll(errMsg, "\r\n", "");
					commonUtil.msgBox(errMsg);
				}
			},
			success:function(json){
				saveCount = 0;
				
				if(json && json.data){
					if(json.data > 0){
						commonUtil.msgBox(configData.MSG_SYSTEM_SAVEOK);
						initFileInput();
						searchList();
					}else{
						commonUtil.msgBox(configData.MSG_SYSTEM_SAVEEMPTY);
					}
				}
			}
		});
	}
	
	function initFileInput(){
		$("#file").val("");
		$("#file").attr("type", "text");
		$("#file").attr("type", "file");
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
						<dt CL="STD_ATTACH"></dt>
						<dd>
							<input type="text" class="input" name="B.NAME" UIInput="R" IAname="Search"/>
						</dd>
						<dt CL="File Upload"></dt>
						<dd style="width: 450px;">
							<form id="fileUploadForm" action="/demo/fileUp/file.data" enctype="multipart/form-data" method="post">
								<input type="file" class="input" id="file" name="file" style="width: 350px;"/>
								<input type="button" value="upload" onclick="fileUpload();">
							</form>
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
										<td GH="250 STD_ATTACH"   GCol="file,ATTACH" validate="required"/></td>
										<td GH="250 STD_FILEDOWN" GCol="fileDownload,UUID"/></td>
										<td GH="100 STD_FILESIZE" GCol="fileSize,BYTE"/></td>
										<td GH="250 STD_REMAKS"   GCol="input,SHORTX" GF="S 300">
										<td GH="100"  GCol="text,CREATEUSER"></td>
										<td GH="120" GCol="text,CREATEDATE" GF="DTS"></td>
										<td GH="100"  GCol="text,UPDATEUSER"></td>
										<td GH="120" GCol="text,UPDATEDATE" GF="DTS"></td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<div class="btn_lit tableUtil">
						<button type='button' GBtn="find"></button>
						<button type='button' GBtn="sortReset"></button>
						<button type='button' GBtn="add"></button>
						<button type='button' GBtn="delete"></button>
						<button type='button' GBtn="layout"></button>
						<span class='txt_total' >총 건수 : <span GInfoArea='true'>0</span></span>
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