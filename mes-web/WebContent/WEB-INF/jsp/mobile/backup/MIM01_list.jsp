<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	String SKUKEY = request.getParameter("SKUKEY");
%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>Mobile WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script>	
	$(document).ready(function(){
		$('table tr:odd').css("backgroundColor","#fff");       // odd  홀수
		$('table tr:even').css("backgroundColor","#f5f5fc");   // even 짝수
		$('table tr th').css("padding", "10px 5px");
		$('table tr td').css("padding", "10px 5px");
		$('table tr td input').css("display", "block");
		$(".imgFileUpload").css("width","100%");
		$(".imgData").css("width","100%");
		
		netUtil.setForm("imgUploadFm1");
		netUtil.setForm("imgUploadFm2");
		netUtil.setForm("imgUploadFm3");
		netUtil.setForm("imgUploadFm4");
		netUtil.setForm("imgUploadFm5");
		netUtil.setForm("imgUploadFm6");
		netUtil.setForm("imgUploadFm7");
		netUtil.setForm("imgUploadFm8");
		netUtil.setForm("imgUploadFm9");
		
		searchList();
	});

	function searchList(){
		var param = new DataMap();
		param.put("SKUKEY", "<%=SKUKEY%>");
		
		netUtil.send({
			module : "Mobile",
			command : "MIM01",
			bindId : "searchArea",
			sendType : "map",
			bindType : "field",
			param : param
		});
	}
 	
 	// 이미지 파일 업로드 체크
 	function imgFileCheck(val, fmID){
 		var $obj = $("#"+fmID);
 		
 		if($obj.find(".imgData").val() != ""){
 			commonUtil.msgBox("파일을 삭제 후 다시 등록하여 주시기 바랍니다.");
 			$obj.find(".imgFileUpload").focus();
 			return;
 		}
 		
 		if(val == null || val == "") {
 			commonUtil.msgBox("파일을 첨부하여 주시기 바랍니다.");
 			$obj.find(".imgFileUpload").focus();
 			return;
 		}
 		
 		// 확장자 체크
 		var exeIdx = val.lastIndexOf('.');
 		var exeNm = " ";
 		if(exeIdx != -1){
 			exeNm = val.substring(exeIdx + 1).toLowerCase();
 		}
 		
 		if(!(exeNm == "gif"
 		  || exeNm == "jpg"
 		  || exeNm == "jpeg"
 		  || exeNm == "bmp"
 		  || exeNm == "png")){
 			commonUtil.msgBox("gif, jpg, jpeg, bmp, png 확장자만 업로드 할 수 있습니다. (현재 첨부파일 확장자: "+exeNm+")");
 			$obj.find(".imgFileUpload").focus();
 			return;
 		}
 		
 		// 사이즈 체크
 		var maxSize = 20971520; // 20MB
 		var fSize = Math.round(val.fileSize);
 		if(fSize > maxSize){
 			commonUtil.msgBox("첨부파일 사이즈는 20MB 이내로 등록 가능합니다. (현재 첨부파일 사이즈: "+fSize+"Byte)");
 			$obj.find(".imgFileUpload").focus();
 			return;
 		}
 		
 		netUtil.sendForm(fmID);
 	}
 	
 	function netUtilEventSetFormSuccess(formId, data){
		commonUtil.msgBox("MASTER_M0999");
		searchList();
	}
 	
 	// 파일 삭제
 	function deleteImg(fmID){
 		if(!commonUtil.msgConfirm(configData.MSG_MASTER_DELETE_CONFIRM)){
			return;
		}
 		
 		var $obj = $("#"+fmID);
 		
 		var param = new DataMap();
 		param.put("SKUKEY", $obj.find("input[name='SKUKEY']").val());
 		param.put("FTYPE",  $obj.find(".imgFileUpload").attr("name"));
 		
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
</script>
</head>
<body>
	<div class="main_wrap" id="main">
		<div id="main_container">
			<div class="tem5_content">
				<div id="searchArea">
					<table class="table type1">
						<colgroup>
							<col width="110px" />
							<col width="150px" />
							<col width="15px" />
						</colgroup>
						<tbody style="padding:10px 0;">
							<!-- 메인이미지 start -->
							<tr>
								<th CL="STD_MAINIMG"></th>
								<td>
									<form action="/imv/imvImg/fileUp/image.data" enctype="multipart/form-data" method="post" id="imgUploadFm1" name="imgUploadFm1">
										<input type="hidden" name="SKUKEY" value="<%=SKUKEY%>" />
										<input type="file" name="M" class="imgFileUpload" />
										<input type="text" name="MAIN" readonly="readonly" class="imgData" />
									</form>
								</td>
								<td>
									<input type="button" CL="BTN_UPLOAD" onClick="imgFileCheck(document.imgUploadFm1.M.value, 'imgUploadFm1');" />
									<input type="button" CL="BTN_DELETE" onClick="deleteImg('imgUploadFm1');" />
								</td>
							</tr>
							<!-- 메인이미지 end -->
							
							<!-- 서브이미지 start -->
							<tr>
								<th CL="STD_SUBIMG1"></th>
								<td>
									<form action="/imv/imvImg/fileUp/image.data" enctype="multipart/form-data" method="post" id="imgUploadFm2" name="imgUploadFm2">
										<input type="hidden" name="SKUKEY" value="<%=SKUKEY%>" />
										<input type="file" name="S1" class="imgFileUpload" />
										<input type="text" name="SUB1" readonly="readonly" class="imgData" />
									</form>
								</td>
								<td>
									<input type="button" CL="BTN_UPLOAD" onClick="imgFileCheck(document.imgUploadFm2.S1.value, 'imgUploadFm2');" />
									<input type="button" CL="BTN_DELETE" onClick="deleteImg('imgUploadFm2');" />
								</td>
							</tr>
							<tr>
								<th CL="STD_SUBIMG2"></th>
								<td>
									<form action="/imv/imvImg/fileUp/image.data" enctype="multipart/form-data" method="post" id="imgUploadFm3" name="imgUploadFm3">
										<input type="hidden" name="SKUKEY" value="<%=SKUKEY%>" />
										<input type="file" name="S2" class="imgFileUpload" />
										<input type="text" name="SUB2" readonly="readonly" class="imgData" />
									</form>
								</td>
								<td>
									<input type="button" CL="BTN_UPLOAD" onClick="imgFileCheck(document.imgUploadFm3.S2.value, 'imgUploadFm3');" />
									<input type="button" CL="BTN_DELETE" onClick="deleteImg('imgUploadFm3');" />
								</td>
							</tr>
							<tr>
								<th CL="STD_SUBIMG3"></th>
								<td>
									<form action="/imv/imvImg/fileUp/image.data" enctype="multipart/form-data" method="post" id="imgUploadFm4" name="imgUploadFm4">
										<input type="hidden" name="SKUKEY" value="<%=SKUKEY%>" />
										<input type="file" name="S3" class="imgFileUpload" />
										<input type="text" name="SUB3" readonly="readonly" class="imgData" />
									</form>
								</td>
								<td>
									<input type="button" CL="BTN_UPLOAD" onClick="imgFileCheck(document.imgUploadFm4.S3.value, 'imgUploadFm4');" />
									<input type="button" CL="BTN_DELETE" onClick="deleteImg('imgUploadFm4');" />
								</td>
							</tr>
							<tr>
								<th CL="STD_SUBIMG4"></th>
								<td>
									<form action="/imv/imvImg/fileUp/image.data" enctype="multipart/form-data" method="post" id="imgUploadFm5" name="imgUploadFm5">
										<input type="hidden" name="SKUKEY" value="<%=SKUKEY%>" />
										<input type="file" name="S4" class="imgFileUpload" />
										<input type="text" name="SUB4" readonly="readonly" class="imgData" />
									</form>
								</td>
								<td>
									<input type="button" CL="BTN_UPLOAD" onClick="imgFileCheck(document.imgUploadFm5.S4.value, 'imgUploadFm5');" />
									<input type="button" CL="BTN_DELETE" onClick="deleteImg('imgUploadFm5');" />
								</td>
							</tr>
							<!-- 서브이미지 end -->
							
							<!-- 상세이미지 start -->
							<tr>
								<th CL="STD_DETAILIMG1"></th>
								<td>
									<form action="/imv/imvImg/fileUp/image.data" enctype="multipart/form-data" method="post" id="imgUploadFm6" name="imgUploadFm6">
										<input type="hidden" name="SKUKEY" value="<%=SKUKEY%>" />
										<input type="file" name="D1" class="imgFileUpload" />
										<input type="text" name="DETAIL1" readonly="readonly" class="imgData" />
									</form>
								</td>
								<td>
									<input type="button" CL="BTN_UPLOAD" onClick="imgFileCheck(document.imgUploadFm6.D1.value, 'imgUploadFm6');" />
									<input type="button" CL="BTN_DELETE" onClick="deleteImg('imgUploadFm6');" />
								</td>
							</tr>
							<tr>
								<th CL="STD_DETAILIMG2"></th>
								<td>
									<form action="/imv/imvImg/fileUp/image.data" enctype="multipart/form-data" method="post" id="imgUploadFm7" name="imgUploadFm7">
										<input type="hidden" name="SKUKEY" value="<%=SKUKEY%>" />
										<input type="file" name="D2" class="imgFileUpload" />
										<input type="text" name="DETAIL2" readonly="readonly" class="imgData" />
									</form>
								</td>
								<td>
									<input type="button" CL="BTN_UPLOAD" onClick="imgFileCheck(document.imgUploadFm7.D2.value, 'imgUploadFm7');" />
									<input type="button" CL="BTN_DELETE" onClick="deleteImg('imgUploadFm7');" />
								</td>
							</tr>
							<tr>
								<th CL="STD_DETAILIMG3"></th>
								<td>
									<form action="/imv/imvImg/fileUp/image.data" enctype="multipart/form-data" method="post" id="imgUploadFm8" name="imgUploadFm8">
										<input type="hidden" name="SKUKEY" value="<%=SKUKEY%>" />
										<input type="file" name="D3" class="imgFileUpload" />
										<input type="text" name="DETAIL3" readonly="readonly" class="imgData" />
									</form>
								</td>
								<td>
									<input type="button" CL="BTN_UPLOAD" onClick="imgFileCheck(document.imgUploadFm8.D3.value, 'imgUploadFm8');" />
									<input type="button" CL="BTN_DELETE" onClick="deleteImg('imgUploadFm8');" />
								</td>
							</tr>
							<tr>
								<th CL="STD_DETAILIMG4"></th>
								<td>
									<form action="/imv/imvImg/fileUp/image.data" enctype="multipart/form-data" method="post" id="imgUploadFm9" name="imgUploadFm9">
										<input type="hidden" name="SKUKEY" value="<%=SKUKEY%>" />
										<input type="file" name="D4" class="imgFileUpload" />
										<input type="text" name="DETAIL4" readonly="readonly" class="imgData" />
									</form>
								</td>
								<td>
									<input type="button" CL="BTN_UPLOAD" onClick="imgFileCheck(document.imgUploadFm9.D4.value, 'imgUploadFm9');" />
									<input type="button" CL="BTN_DELETE" onClick="deleteImg('imgUploadFm9');" />
								</td>
							</tr>
							<!-- 상세이미지 end -->
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>
</body>