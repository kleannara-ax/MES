<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>SKU Image List</title>
<%@ include file="/mobile/include/head.jsp" %>
<style type="text/css">
	.tem5_content {
		width:1280px;
	}

	#imgListBox {
		width:1280px;
		height:400px;
		position:relative;
		margin:10px;
	}
	
	#imgBox1 {
		width:400px;
	}
	
	#imgBox2 {
		width:870px;
	}
	
	#imgListBox .img_box {
		margin-right:1px;
		height:100%;
		float:left;
	}
	
	#imgListBox .img_box .img_sub_box {
		width:100%;
		height:50%;
	}
	
	#subImgBox {
		margin-bottom:1px;
	}
	
	#imgListBox .img_box div {
		margin-right:1px;
		width:100%;
		text-align:center;
		float:left;
		vertical-align:middle;
	}
	
	#imgListBox .img_box .no_img_box {
		height:100%;
		background-color:#ccc;
		color:#fff;
	}
	
	#imgListBox .img_box div:after {
		width:0;
		height:100%;
		display:inline-block;
		vertical-align:middle;
		content:"";
		clear:both;
	}
	
	#imgListBox #imgBox1 div {
		margin:0;
		width:100%;
		height:100%;
	}
	
	#imgListBox #imgBox2 .img_sub_box div {
		width:23.5%;
		height:100%;
	}
	
	#imgListBox .img_box div img {
		width:100%;
		display:inline-block;
		vertical-align:middle;
	}
	
	#skuInfoBox {
		width: 400px;
		margin: 10px;
	}
	
	.bottomSect .tabs {
	    top: 1px;
	    padding-top: 0px !important;
	    border-bottom: 2px solid #222;
	}
	
	#skuInfoBox table tr {
		margin-bottom: 5px;
	}
	#skuInfoBox table th {
		text-align: left;
	}
</style>
<script type="text/javascript">
	window.resizeTo('450','760');
	
	var data;
	$(document).ready(function(){
		data = mobile.getLinkPopData();
	    dataBind.dataNameBind(data, "searchArea");
	    
		searchList();
	});
	
	function searchList(){
		var param = inputList.setRangeParam("searchArea");
		
		var json = netUtil.sendData({
			module : "Mobile",
			command : "SKU_IMG",
			sendType : "list",
			param : param
		});
		
		if(json && json.data){
			if(json.data.length > 0){
				var row;
				for(var i = 0; i < json.data.length; i++){
					row = json.data[i];
					var img = '<img src="'+row.IMGFILE+'" />';
					$("#"+row.DOC_TYPE_CODE).removeClass("no_img_box").text("").append(img);
				}
			}
		}
		
		param.put("OWNRKY", "<%=ownrky%>");
		
		// 상세정보
		var jsonD = netUtil.sendData({
			module : "Mobile",
			command : "SKU_IMG",
			sendType : "map",
			param : param
		});
		
		if(jsonD && jsonD.data){
			dataBind.dataNameBind(jsonD.data, "skuInfoBox");
		}
	}
	
	function fn_closing(){
		mobile.linkPopClose(data);
	}
</script>
</head>
<body>
	<div class="main_wrap" id="main">
		<div id="main_container">
			<div class="tem5_content">
				<div id="searchArea">
					<input type="hidden" name="SKUKEY" />
				</div>
				<div id="imgListBox">
					<div id="imgBox1" class="img_box">
						<div class="no_img_box" id="M">NO IMAGE</div>
					</div>
					<div id="imgBox2" class="img_box">
						<div id="subImgBox" class="img_sub_box">
							<div class="no_img_box" id="S1">NO IMAGE</div>
							<div class="no_img_box" id="S2">NO IMAGE</div>
							<div class="no_img_box" id="S3">NO IMAGE</div>
							<div class="no_img_box" id="S4">NO IMAGE</div>
						</div>
						<div id="detailImgBox" class="img_sub_box">
							<div class="no_img_box" id="D1">NO IMAGE</div>
							<div class="no_img_box" id="D2">NO IMAGE</div>
							<div class="no_img_box" id="D3">NO IMAGE</div>
							<div class="no_img_box" id="D4">NO IMAGE</div>
						</div>
					</div>
				</div>
				
				<div id="skuInfoBox" class="bottomSect">
					<div class="tabs"></div>
					<div id="tabs-1" style="margin-top: 10px;">
						<div class="section type1">
							<table class="table type1">
								<colgroup>
									<col width="100" />
									<col />
								</colgroup>
								<tbody>
									<tr>
										<th CL="STD_SKUKEY"></th>
										<td>
											<input type="text" name="SKUKEY" readonly="readonly" />
										</td>
									</tr>
									<tr>
										<th CL="STD_DESC01"></th>
										<td>
											<input type="text" name="DESC01" readonly="readonly" />
										</td>
									</tr>
									<tr>
										<th CL="STD_SKUG05"></th>
										<td>
											<input type="text" name="SKUG05" readonly="readonly" />
										</td>
									</tr>
									<tr>
										<th CL="STD_DUOMKY"></th>
										<td>
											<input type="text" name="DUOMKY" readonly="readonly" />
										</td>
									</tr>
									<tr>
										<th CL="STD_DESC02"></th>
										<td>
											<input type="text" name="DESC02" readonly="readonly" />
										</td>
									</tr>
									<tr>
										<th CL="STD_DESC04"></th>
										<td>
											<input type="text" name="DESC04" readonly="readonly" />
										</td>
									</tr>
									<tr>
										<th CL="STD_BUYER"></th>
										<td>
											<input type="text" name="LOTL04" readonly="readonly" />
										</td>
									</tr>
									<tr>
										<th CL="STD_TELN01"></th>
										<td>
											<input type="text" name="PHONE" readonly="readonly" />
										</td>
									</tr>
									<tr>
										<th CL="STD_EMAIL1"></th>
										<td>
											<input type="text" name="EMAIL" readonly="readonly" />
										</td>
									</tr>
									<tr>
										<th CL="STD_LEADTM"></th>
										<td>
											<input type="text" name="LEADTM" readonly="readonly" UIFormat="D" />
										</td>
									</tr>
									<tr>
										<th CL="STD_HSCODE"></th>
										<td>
											<input type="text" name="HSCODE" readonly="readonly" />
										</td>
									</tr>
									<tr>
										<th CL="STD_ATTACH"></th>
										<td>
											<input type="text" name="ATTACH" readonly="readonly" />
										</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
				</div>
				
				<div class="footer_5">
					<table>
						<tr>
							<td onclick="fn_closing()" style="text-align:center;"><label CL='BTN_CLOSE'></label></td>
						</tr>
					</table>
				</div><!-- end footer_5 -->
			</div>
		</div>
	</div>
</body>
</html>