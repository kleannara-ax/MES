<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>SKU Image List</title>
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
	
	var fileCodeList = new Array();
	var newFileCodeList = new Array();
	
	$(document).ready(function(){
		gridList.setGrid({
			id : "gridList",
			editable : false,
			module : "Mobile",
			command : "MIM01",
			gridMobileType : true
	    });
		
		var data = mobile.getLinkPopData();
	    dataBind.dataNameBind(data, "fileUploadArea");
	    
		searchList();
	});
	
	function searchList(){
		var param = inputList.setRangeParam("fileUploadArea");
		
		netUtil.setForm("imgUploadFm");
	    $("#IMG_FILE_TYPE_CODE").val("M");
		
		gridList.resetGrid("gridList");
		
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
	}
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if(gridId == "gridList"){
			if(dataLength > 0){
				var list = gridList.getGridData("gridList");
				
				for(var i = 0; i < list.length; i++){
					fileCodeList.push(list[i].get("DOC_TYPE_CODE"));
				}
			}
			
			$("#imgUploadFm div").find('input[type="file"]').remove();
			$('#fileBox').append('<input type="file" name="M" id="M" />');
			
			if($.inArray("M", fileCodeList) === -1) {
				fileCodeList.push("M");
			};
			newFileCodeList.push("M");
		}
	}
	
	function fileAdd(){
		var code = $("#IMG_FILE_TYPE_CODE").val();
		
		if(code == "M"){
			commonUtil.msgBox("VALID_M1608");
			return;
		}
		
		var codeList = [code+'1', code+'2', code+'3', code+'4'];
		
		var cnt = 0;
		for(var i = 0; i < fileCodeList.length; i++){
			for(var j = 0; j < codeList.length; j++){
				if(fileCodeList[i] == codeList[j]){
					cnt++;
				}
			}
		}
		
		var len = $("#imgUploadFm div").find('input[type="file"]').length;
		if(cnt == 4){
			commonUtil.msgBox("VALID_M1609",len);
			return;
		}
		
		$('#fileBox').prev().css("vertical-align", "top");
		$('#fileBox').next().css("vertical-align", "top");
		
		var fileCode;
		$.each(codeList, function(i, el){
			if($.inArray(el, fileCodeList) === -1) {
				fileCode = el;
				return false;
			};
		});
		
		$('#fileBox').append('<input type="file" name="'+fileCode+'" id="'+fileCode+'" />');
		
		fileCodeList.push(fileCode);
		newFileCodeList.push(fileCode);
	}
	
	function fileRemove(){
		var cnt = $("#imgUploadFm div").find('input[type="file"]').length;
		
		if(cnt == 1){
			return;
		}
		
		var code = $("#IMG_FILE_TYPE_CODE").val();
		var codeList = [code+'4', code+'3', code+'2', code+'1'];
		
		var fileCode;
		$.each(codeList, function(i, el){
			if($.inArray(el, fileCodeList) > -1) {
				fileCode = el;
				return false;
			};
		});
		
		$('#fileBox').find("[name="+fileCode+"]").remove();
		
		fileCodeList.splice($.inArray(fileCode, fileCodeList),1);
		newFileCodeList.splice($.inArray(fileCode, newFileCodeList),1);

		var len = $("#imgUploadFm div").find('input[type="file"]').length;
		if(len == 1){
			$('#fileBox').prev().css("vertical-align", "middle");
			$('#fileBox').next().css("vertical-align", "middle");
		}
	}
	
	function fileClear(){
		var code = $("#IMG_FILE_TYPE_CODE").val();
		
		fileCodeList = new Array();
		newFileCodeList = new Array();
		var list = gridList.getGridData("gridList");
		for(var i = 0; i < list.length; i++){
			fileCodeList.push(list[i].get("DOC_TYPE_CODE"));
		}
		
		$("#imgUploadFm div").find('input[type="file"]').remove();
		if(code == "M"){
			$('#fileBox').append('<input type="file" name="'+code+'" id="'+code+'" />');
			
			if($.inArray(code, fileCodeList) === -1) {
				fileCodeList.push(code);
			};
			newFileCodeList.push(code);
		} else {
			var codeList = [code+'1', code+'2', code+'3', code+'4'];
			var fileCode;
			
			$.each(codeList, function(i, el){
				if($.inArray(el, fileCodeList) === -1) {
					fileCode = el;
					return false;
				};
			});
			
			$('#fileBox').append('<input type="file" name="'+fileCode+'" id="'+fileCode+'" />');
			
			fileCodeList.push(fileCode);
			newFileCodeList.push(fileCode);
		}
	}
	
	function saveData(){
		var $obj = $("#imgUploadFm");
		var list = gridList.getGridData("gridList");
		
		// 재등록 여부
		for(var i = 0; i < list.length; i++){
			var rowCode = list[i].get("DOC_TYPE_CODE");
			if($.inArray(rowCode, newFileCodeList) > -1) {
				commonUtil.msgBox("VALID_M1610",rowCode);
				return;
			};
		}
		
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
	 		
	 		if(!(exeNm == "gif"
	 		  || exeNm == "jpg"
	 		  || exeNm == "jpeg"
	 		  || exeNm == "bmp"
	 		  || exeNm == "png")){
	 			commonUtil.msgBox("VALID_M1611",exeNm);
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
		if(data.data != "SAVE") {
			commonUtil.msg(data.data);
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
		
 		if(!commonUtil.msgConfirm(configData.MSG_MASTER_DELETE_CONFIRM)){
			return;
		}
 		
 		var param = new DataMap();
 		param.put("list", list);
 		
 		var json = netUtil.sendData({
			url : "/mobile/Mobile/json/imgFileDelete.data",
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
								<col width="30px" />
								<col width="200px" />
								<col width="100px" />
							</colgroup>
							<thead>
								<tr>
									<th CL='STD_NO'>No.</th>
									<th GBtnCheck="true"></th>
									<th CL="STD_FILE_CODE"></th>
									<th CL="STD_IFDTFN"></th>
									<th CL="STD_FILE_SIZE"></th>
								</tr>
							</thead>
						</table>				
					</div>					
					<div class="tableBody" style="height:290px;">
						<table style="width:100%;">
							<colgroup>
								<col width="30px" />
								<col width="30px" />
								<col width="30px" />
								<col width="200px" />
								<col width="100px" />
							</colgroup>
							<tbody id="gridList">
								<tr CGRow="true">
									<td GCol="rownum">1</td>
									<td GCol="rowCheck"></td>
									<td GCol="text,DOC_TYPE_CODE"></td>
									<td GCol="text,TRANS_FILE_NAME"></td>
									<td GCol="text,FILE_SIZE_BYTES"></td>
								</tr>
							</tbody>
						</table>
					</div>
					<div id="fileUploadArea">
						<table>
							<tr>
								<td style="padding-top:10px;"><!-- /imv/imvImg/fileUp/image -->
									<form action="/mobile/Mobile/json/saveMIM01.data" enctype="multipart/form-data" method="post" id="imgUploadFm">
										<input type="hidden" name="SKUKEY" />
										<div>
											<select id="IMG_FILE_TYPE_CODE" name="IMG_FILE_TYPE_CODE" onchange="fileClear()">
												<option CL="STD_MAINIMG" value="M"></option>
												<option CL="STD_SUBIMG1" value="S"></option>
												<option CL="STD_DETAILIMG1" value="D"></option>
											</select>
										</div>
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
									<p style="font-size:13px;">* <span CL="STD_M1611,3"></span></p>
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