<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>Mobile WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script type="text/javascript">
$(document).ready(function(){
	//$("#SKUKEY").focus();
});

	function sendData(){
		var $obj = $("#SKUKEY");
		if($obj.val() == ""){
			//alert("품번을 입력해주세요.");
			commonUtil.msgBox("VALID_M1567");
			$obj.focus();
		}else{
			location.href="/mobile/MSD01_list.page?SKUKEY="+$obj.val();
		}
	}
	
	/* function seachData(){
		var $obj = $("#DESC01");
		if($obj.val() == ""){
			alert("품명을 입력해주세요.");
			$obj.focus();
		}else{
			location.href="/mobile/MSD01_search.page?DESC01="+$obj.val();
			//location.href="/mobile/MSD01_search.page";
		}
	} */
	
	function linkPopCloseEvent(data){
		var SKUKEY = data.get("SKUKEY");
		$("#SKUKEY").val(SKUKEY);
	}
	
	function menuOpen(){
		window.top.menuOpen();
	}
	
	function linkPopupOpen(){
		var $obj = $("#DESC01");
		if($obj.val() == ""){
			//alert("품명을 입력해주세요.");
			commonUtil.msgBox("VALID_M1563");
			$obj.focus();
		}else{
			mobile.linkPopOpen('/mobile/MSD01_search.page',$obj.val());
		}
	}
	
	function clearText(data){
	    if(data!=null||data!=""){
	       data.value="";
	    }      
	 }
	
</script>
</head>
<body>
	<div class="main_wrap">
		<div class="tem3_content">
			<div class="search">
				<table>
					<colgroup>
						<col width="80px"  />
						<col />
						<col width="60px" />
					</colgroup>
					<tbody>
						<tr>
							<th CL="STD_SKUKEY"></th>
							<td>
								<input type="text" class="text" id="SKUKEY" onfocus="clearText(this)"  onkeypress="commonUtil.enterKeyCheck(event, 'sendData()')" />
							</td>
							<td>
								<input type="button" class="bt" CL="STD_DISPLAY" onclick="sendData()"/>
							</td>
						</tr>
						<tr>
							<th CL="STD_DESC01"></th>
							<td>
								<input type="text" class="text" id="DESC01" onfocus="clearText(this)" />
							</td>
							<td>
								<input type="button" class="bt" CL="STD_SCHELP" onclick="linkPopupOpen()"/>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="bottom">
				<a href="#" onClick="menuOpen()"><input type="button" CL="STD_MAIN" class="bottom_bt" /></a>
			</div>
		</div>
	</div>
</body>