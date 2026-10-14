<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>Moblie WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script type="text/javascript">
$(document).ready(function(){
	$("#LOCAKY").focus();
});

	function sendData(){
		var $obj = $("#LOCAKY");
		if($obj.val() == ""){
			commonUtil.msgBox("VALID_M1568");
			$obj.focus();
		}else{
			location.href="/mobile/MSD02_list.page?LOCAKY="+$obj.val();
		}
	}
	
	/* function linkPopCloseEvent(data){
		var LOCAKY = data.get("LOCAKY");
		$("#LOCAKY").val(LOCAKY);
	} */
	
	function menuOpen(){
		window.top.menuOpen();
	}
	
	/* function linkPopupOpen(){
		var $obj = $("LOCAKY");
		// var rowNum = gridList.getFocusRowNum('gridList');
	   //  var param = gridList.getRowData('gridList',rowNum);
	     mobile.linkPopOpen('/mobile/MSD02_search.page', $obj.val());
	} */
	
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
							<th CL='STD_LOCAKY,3'></th>
							<td>
								<input type="text" class="text" id="LOCAKY" onkeypress="commonUtil.enterKeyCheck(event, 'sendData()')" onfocus="clearText(this)"/>
							</td>
							<td>
								<input type="button" class="bt" CL="STD_DISPLAY" onclick="sendData()"/>
							</td>
						
							<!-- <td>
								<input type="button" value="p" class="bt" onclick="linkPopupOpen()"/>
							</td> -->
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