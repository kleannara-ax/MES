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
		$("#SHPOKY").focus();
	});
	
	function sendData(){
		var $obj = $("#SHPOKY");

		if($obj.val() == ""){
			commonUtil.msgBox("VALID_M1571");
			//alert("출고문서번호를 입력해주세요.");
			$obj.focus();
		}else{
			location.href="/mobile/MDL08_list.page?SHPOKY="+$obj.val();
		}
	}
	
	function menuOpen(){
		window.top.menuOpen();
	}
	
	function clearText(data){
		if(data!=null||data!=""){
	    	data.value="";
	    }      
	}
</script>

</head>
<body>
<!-- <span CL="MENU_DL06,3"></span> -->
	<div class="main_wrap">
		<div class="tem3_content">
			<div class="search">
				<table>
					<colgroup>
						<col width="100px"  />
						<col />
						<col width="60px" />
					</colgroup>
					<tbody>
						<tr>
							<th CL="STD_SHIPORDNO"></th>
							<td>
								<input type="text" class="text" id="SHPOKY" onkeypress="commonUtil.enterKeyCheck(event, 'sendData()')"  onfocus="clearText(this)"/>
							</td>
							<td>
								<input type="button" CL="STD_DISPLAY" class="bt" onclick="sendData()" >
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