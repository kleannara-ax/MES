<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>슈피겐코리아 모바일 WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script>
$(document).ready(function(){
	//$("#STKNUM").focus();
});

function sendData(){
	var $obj = $("#STKNUM");
	if($obj.val() == ""){
		alert("총괄지시번호를 입력하세요.");
		$obj.focus();
	}else{
		location.href="/mobile/MDL07_list.page?STKNUM="+$obj.val();
	}
}

function linkPopCloseEvent(data){
	var STKNUM = data.get("STKNUM");
	$("#STKNUM").val(STKNUM);
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
						<col width="100px"  />
						<col />
						<col width="60px" />
					</colgroup>
					<tbody>
						<tr>
							<th>총괄지시번호</th>
							<td>
								<input type="text" class="text" id="STKNUM" onkeypress="commonUtil.enterKeyCheck(event, 'sendData()')" onfocus="clearText(this)"/>
							</td>
							<td>
								<input type="button" value="p" class="bt" onclick="popupOpen('/mobile/MDL07_search.page','MDL07_search')"/>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="bottom">
				<a href="#" onClick="sendData()"><input type="button" value="확인" class="bottom_bt" /></a>
			</div>
		</div>
	</div>
</body>