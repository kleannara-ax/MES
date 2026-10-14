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
		$("#SKUKEY").val("");
	});

	function sendData(){
		var $obj = $("#EBELN");
		
		if($obj.val() == ""){
			commonUtil.msgBox("VALID_M1572");//alert("운송지시번호를 입력해주세요.");
			$obj.focus();
		}else{
			var param = new DataMap();
			param.put("EBELN", $obj.val());
			
			var json = netUtil.sendData({
				module : "Mobile",
				command : "MIM02_EBELN",
				sendType : "map",
				param : param
			});
			
			if(json.data['CNT'] < 1){
				commonUtil.msgBox("IN_M0132"); //운송지시번호를 확인하세요.
				return;
			}
			
			json = netUtil.sendData({
				module : "Mobile",
				command : "MIM02_REEBELN",
				sendType : "map",
				param : param
			});
			
			if(json && json.data){
				if(json.data["MSG"] != 'OK'){
					commonUtil.msgBox(json.data["MSG"]); // 에러처리
					return;
				}
			}
			
// 			location.href="/mobile/MIM02_list.page?EBELN="+$obj.val();
			dataBind.paramData("searchArea", param);
			mobile.linkPopOpen("/mobile/MIM02_POP.page", param);
		}
	}
	
	function linkPopCloseEvent(data){
		var EBELN = data.get("EBELN");
		$("#EBELN").val(EBELN);
	}
	
	function menuOpen(){
		window.top.menuOpen();
	}
	
	function clearText(data){
	    if(data != null || data != ""){
	       data.value = "";
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
						<col width="120px"  />
						<col />
						<col width="60px" />
					</colgroup>
					<tbody>
						<tr>
							<th CL="STD_EBELN"></th>
							<td>
								<input type="text" class="text" id="EBELN" onfocus="clearText(this)"  onkeypress="commonUtil.enterKeyCheck(event, 'sendData()')" />
							</td>
							<td>
								<input type="button" class="bt" CL="STD_DISPLAY" onclick="sendData()"/>
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