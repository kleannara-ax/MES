<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>IMV Mobile WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<%
	String areaky = paramDataMap.getMap("SES_USER_INFO_ID").getString("ETC");
%>
<script>
	$(document).ready(function(){
		$("#AREAKY").val("<%= areaky%>");
	});
	
	function sendData(){
		var $obj1 = $("#AREAKY");
		var $obj2 = $("#LOCAKY");		
		var $obj3 = $("#SKUKEY");
		var param = new DataMap();

		if($obj2.val() == "" && $obj3.val() == ""){
			commonUtil.msgBox("REPORT_M0019"); /* 조회조건을 입력하세요. */
			return;
		}
		location.href="/mobile/MIP04_list.page?AREAKY="+$obj1.val()+"&LOCAKY="+$obj2.val()+"&SKUKEY="+$obj3.val();
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
							<th CL="STD_AREAKY">창고</th>
							<td>
								<select Combo="WmsAdmin,AREACOMBO" name="AREAKY" id="AREAKY">
								</select>
							</td>
							<td>
								<input type="button" CL="BTN_DISPLAY" class="bt" onclick="sendData()"/>
							</td>
						</tr>
						<tr>
							<th CL="STD_LOCAKY"></th>
							<td>
								<input type="text" class="text_1" id="LOCAKY" onfocus="clearText(this)" onkeypress="commonUtil.enterKeyCheck(event, 'sendData()')" />
							</td>
						</tr>
						<tr>
							<th CL="STD_SKUKEY"></th>
							<td>
								<input type="text" class="text_1" id="SKUKEY" onfocus="clearText(this)" onkeypress="commonUtil.enterKeyCheck(event, 'sendData()')" />
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