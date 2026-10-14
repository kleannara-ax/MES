<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>DN Image List</title>
<%@ include file="/mobile/include/head.jsp" %>
<style>
	#imgUploadFm div{
		display:inline-block;
		vertical-align:middle;
	}
	
	#imgUploadFm div select {
		padding:2px 0;
	}
	
	#fileBox {
		width:300px;
	}
	
	#fileBox input {
		margin-bottom: 5px;
	}
	
	#imgUploadFm div span {
		width:20px;
		height:20px;
		display:inline-block;
		line-height:18px;
	    font-size:13px;
	}
</style>
<script>	
	window.resizeTo('450','643');
	
	$(document).ready(function(){
		gridList.setGrid({
			id : "gridList",
			editable : false,
			module : "Mobile",
			command : "MIM02",
			gridMobileType : true
	    });
		
		var data = mobile.getLinkPopData();
	    dataBind.dataNameBind(data, "fileUploadArea");
	    
	    //netUtil.setForm("imgUploadFm");
	    
		searchList();
	});
	
	function searchList(){
		var param = inputList.setRangeParam("fileUploadArea");
		
		netUtil.setForm("imgUploadFm");
		$("#imgUploadFm div").find('input[type="file"]').remove();
		$('#fileBox').append('<input type="file" name="file0" id="file0" />');
		
		gridList.resetGrid("gridList");
		
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
	}
	
	function fileAdd(){
		var cnt = $("#imgUploadFm div").find('input[type="file"]').length;
		
		$('#fileBox').next().css("vertical-align", "top");
		$('#fileBox').append('<input type="file" name="file'+cnt+'" id="file'+cnt+'" />');
	}
	
	function fileRemove(){
		var cnt = $("#imgUploadFm div").find('input[type="file"]').length;
		
		if(cnt == 1){
			return;
		}
		
		$('#fileBox').find("[name=file"+(cnt - 1)+"]").remove();
	}
	
	function saveData(){
		var $obj = $("#imgUploadFm");
		
		var flag = false;
		$obj.find('input[type="file"]').each(function(){
			var fileObject = document.getElementById($(this).attr("id"));
			
			var val = fileObject.files[0];
			
			// value 체크
			if(val == null || val == "") {
	 			commonUtil.msgBox("VALID_M1605");
	 			fileObject.focus();
	 			flag = true;
	 			return false;
	 		}
			
			var name = val.name;
			var size = val.size;
			
			// 확장자 체크
	 		var exeIdx = name.lastIndexOf('.');
	 		var exeNm = " ";
	 		if(exeIdx != -1){
	 			exeNm = name.substring(exeIdx + 1).toLowerCase();
	 		}
	 		
	 		if((exeNm == "bat"
	 		  || exeNm == "exe")){
	 			commonUtil.msgBox("VALID_M1606",exeNm);
	 			fileObject.focus();
	 			flag = true;
	 			return false;
	 		}
	 		
	 		// 사이즈 체크
	 		var maxSize = 20971520; // 20MB
	 		var fSize = Math.round(size);
	 		if(fSize > maxSize){
	 			commonUtil.msgBox("VALID_M1607", fSize);
	 			fileObject.focus();
	 			flag = true;
	 			return false;
	 		}
		});
		
		if(flag){
			return;
		}
		
 		netUtil.sendForm("imgUploadFm");
	}
	
	function netUtilEventSetFormSuccess(formId, data){
		if(data == null || $.trim(data) == "") {
			commonUtil.msgBox("MASTER_M1111"); // 저장에 실패하였습니다. 관리자에게 문의하시기 바랍니다.
			return;
		} else {
			commonUtil.msgBox("MASTER_M0999");
			searchList();
		}
	}
	
	// 파일 삭제
 	function deleteData(){
 		var list = gridList.getSelectData("gridList");
 		
 		if(list.length == 0){
			commonUtil.msgBox("VALID_M0006");
			return;
		}
 		
 		var param = new DataMap();
 		
 		for(var i = 0; i < list.length; i++){
 			var row = list[i];
 			
 			param = new DataMap();
 			param.put("EBELN", $("input[name='EBELN']").val());
 			param.put("DOC_ATTACH_ID", row.get("DOC_ATTACH_ID"));
 			
 			var json = netUtil.sendData({
 				module : "Mobile",
 				command : "MIM02_REEBELN2",
 				sendType : "map",
 				param : param
 			});
 			
 			if(json && json.data){
 				if(json.data["MSG"] != 'OK'){
 					commonUtil.msgBox(json.data["MSG"]); // 에러처리
 					return;
 				}
 			}
 		}
 		
 		if(!commonUtil.msgConfirm(configData.MSG_MASTER_DELETE_CONFIRM)){
			return;
		}
 		
 		param = new DataMap();
 		param.put("list", list);
 		
 		var json = netUtil.sendData({
			url : "/mobile/Mobile/json/dnFileDelete.data",
			param : param
		});
 		
 		if(json){
 			if(json.data != ""){
 				commonUtil.msgBox("VALID_M0003");
 				searchList();
 			}
 		}
 	}
	
 	function popClose(){
 		this.close();
 	}
</script>
</head>
<body>
	<div class="main_wrap" id="main">
		<div id="main_container">
			<div class="tem5_content">
				<div class="tableWrap_search section" style="overflow:auto;">
					<div class="tableHeader">
						<table style="width:100%">
							<colgroup>
								<col width="30px" />
								<col width="30px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
							</colgroup>
							<thead>
								<tr>
									<th CL='STD_NO'>No.</th>
									<th GBtnCheck="true"></th>
									<th CL="STD_FILE_NAME"></th>
									<th CL="STD_IFDTFN"></th>
									<th CL="STD_REG_DATE"></th>
								</tr>
							</thead>
						</table>				
					</div>					
					<div class="tableBody" style="height:290px; overflow-y:scroll;">
						<table style="width:100%;">
							<colgroup>
								<col width="30px" />
								<col width="30px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
							</colgroup>
							<tbody id="gridList">
								<tr CGRow="true">
									<td GCol="rownum">1</td>
									<td GCol="rowCheck"></td>
									<td GCol="text,FILE_NAME"></td>
									<td GCol="text,TRANS_FILE_NAME"></td>
									<td GCol="text,REG_DATE"></td>
								</tr>
							</tbody>
						</table>
					</div>
					<div id="fileUploadArea">
						<table>
							<tr>
								<td style="padding-top:10px;">
									<form action="/mobile/Mobile/json/saveMIM02.data" enctype="multipart/form-data" method="post" id="imgUploadFm">
										<input type="hidden" name="EBELN" />
										<div id="fileBox">
										</div>
										<div>
											<span id="fileAdd" class="bt" onclick="fileAdd()">+</span>
											<span id="fileRemove" class="bt" onclick="fileRemove()">-</span>
										</div>
									</form>
								</td>
							</tr>
							<tr>
								<td style="padding:0 30px 0 30px; height:60px; text-align:left;">
									<p style="font-size:13px;">* <span CL="STD_M1607,3"></span></p>
									<p style="font-size:13px;">* <span CL="STD_M1606,3"></span></p>
								</td>
							</tr>
						</table>
					</div>
					<!-- end table_body -->
					<div class="footer_5">
						<table>
							<tr>
								<td onclick="deleteData()"><label CL='BTN_DELETE'></label></td>
								<td class="f_1" onclick="saveData()"><label CL='BTN_SAVE'></label></td>
								<td onclick="popClose()"><label CL="BTN_CLOSE"></label></td>
							</tr>
						</table>
					</div><!-- end footer_5 -->
				</div>
			</div>
		</div>
	</div>
</body>