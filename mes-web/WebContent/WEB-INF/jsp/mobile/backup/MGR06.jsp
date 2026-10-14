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
	//$("#SEBELN").focus();
});

function sendData(){
	var $obj = $("#SEBELN");
	if($obj.val() == ""){
		alert("입고오더번호를 입력하세요.");
		$obj.focus();
	}else{
		location.href="/mobile/MGR06_list.page?SEBELN="+$obj.val();
	}
}

function linkPopCloseEvent(data){
	var SEBELN = data.get("WMSREQSEQ");
	$("#SEBELN").val(SEBELN);
}

function linkPopupOpen(){
	var $obj = $("#SEBELN");
	mobile.linkPopOpen('/mobile/MGR06_search.page',$obj.val() );
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
							<th CL="STD_SEBELN">입고오더번호</th>
							<td>
								<input type="text" class="text" id="SEBELN" onfocus="clearText(this)" onkeypress="commonUtil.enterKeyCheck(event, 'sendData()')"/>
							</td>
							<td>
								<input type="button" value="p" class="bt" onclick="linkPopupOpen()"/>
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