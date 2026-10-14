<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>IMV Mobile WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script>
	$(document).ready(function(){
		$("#EBELN").focus();
	});
	
	function sendData(){
		var $obj = $("#EBELN");
		if($obj.val() == ""){
			commonUtil.msgBox("TASK_M0338"); //작업지시 번호를 입력해 주세요.
			$obj.focus();
		}else{
			location.href="/mobile/MRL19_list.page?EBELN="+$obj.val();
		}
	}
	
	function clearText(data){
	    if(data!=null||data!=""){
	       data.value="";
	    }      
	 }
	
	function showMain(){
		window.top.menuOpen();
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
							<th CL='STD_EBELN'>작업지시번호</th>
							<td>
								<input type="text" class="text" id="EBELN" onfocus="clearText(this)" onkeypress="commonUtil.enterKeyCheck(event, 'sendData()')"/>
							</td>
							<td>
								<input type="button" CL="BTN_DISPLAY" class="bt" onclick="sendData()"/>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="bottom">
				<a href="#" onClick="showMain()"><input type="button" CL="STD_MAIN" class="bottom_bt" /></a>
			</div>
		</div>
	</div>
</body>