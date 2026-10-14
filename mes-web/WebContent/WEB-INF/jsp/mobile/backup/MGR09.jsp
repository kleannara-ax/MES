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
	//$("#SKUKEY").focus();
});

	function sendData(){
		var $skuobj = $("#SKUKEY");
		var $locobj = $("#LOCAKY");
		
		if($skuobj.val() == "" && $locobj.val()== "0"){
			alert("LOT 입력하거나 지번을 선택하세요.");
			$skuobj.focus();
		}else{
			location.href="/mobile/MGR09_list.page?SKUKEY="+$skuobj.val()+"&LOCAKY="+$locobj.val();	
		}
	}
	
	function linkPopCloseEvent(data){
		var SKUKEY = data.get("SKUKEY");
		$("#SKUKEY").val(SKUKEY);
	}

	function linkPopupOpen(){
		var $obj = $("SKUKEY");
		mobile.linkPopOpen('/mobile/MGR09_search.page', $obj.val());
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
						<col width="40px" />
						<col />
						<col width="60px" />
					</colgroup>
					<tbody>
						<tr>
							<th>LOT</th>
							<td>
								<input type="text" class="text" id="SKUKEY" onkeypress="commonUtil.enterKeyCheck(event, 'sendData()')"  onfocus="clearText(this)"/>
							</td>
							<!-- <td>
								<input type="button" value="p" class="bt" onclick="linkPopupOpen()" />
							</td> -->
						</tr>
						<tr>
							<th>지번</th>
							<td>
								<select class="MGR09_select" id="LOCAKY">
									<option value="0">선택</option>
									<option value="RCV">[RCV]입고</option>
									<option value="RTN">[RTN]반품</option>
								</select>
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