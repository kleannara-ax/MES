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
		//$("#ASNDKY").focus();
	});
	
	function sendData(){
		var $obj = $("#SEBELN");
		if($obj.val() == ""){
			commonUtil.msgBox("IN_M0010"); //구매오더 번호를 입력해 주세요.
			$obj.focus();
		}else{
			var param = new DataMap();
			param.put("SEBELN", $obj.val());
			param.put("WAREKY", "<%=wareky%>");
			
			var json = netUtil.sendData({
				module : "Mobile",
				command : "MGR02_EBELN",
				sendType : "map",
				param : param
			});
			
			if(json.data['CNT'] < 1){
				commonUtil.msgBox("IN_M0132"); //구매오더번호를 확인해주세요.
				$("#SEBELN").val("");
				return;
			} 
			
			location.href="/mobile/MGR02_list.page?SEBELN="+$obj.val();
		}
	}
	
	function linkPopCloseEvent(data){
		if(data == 0){
			$("#SEBELN").val("");
			$("#SEBELN").focus();
		}
		var SEBELN = data.get("SEBELN");
		$("#SEBELN").val(SEBELN);
	}
	
	function linkPopupOpen(){
		var $obj = $("#SEBELN");
		mobile.linkPopOpen('/mobile/MGR02_search.page',$obj.val() );
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
							<th CL='STD_EBELN'>오더번호</th>
							<td>
								<input type="text" class="text" id="SEBELN"  onfocus="clearText(this)" onkeypress="commonUtil.enterKeyCheck(event, 'sendData()')"/>
							</td>
							<td>
								<input type="button" CL="STD_SCHELP" class="bt" onclick="linkPopupOpen()"/>
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