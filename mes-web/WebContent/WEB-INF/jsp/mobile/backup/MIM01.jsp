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
		var $obj = $("#SKUKEY");
		var skukey = $.trim($obj.val());
		
		if(skukey == ""){
			commonUtil.msgBox("VALID_M1567"); //품번을 입력해주세요.
			$obj.focus();
		}else{
			// 2016.10.21   IMK품목일 경우
			if(skukey.indexOf('-K') > -1){
				commonUtil.msgBox("MASTER_M1113"); // IMK품목코드는 이미지 업로드를 하실 수 없습니다.
				$obj.val("").focus();
				return;
			}
			
			var param = new DataMap();
			param.put("SKUKEY", skukey);
			param.put("OWNRKY", "<%=ownrky%>");
			param.put("WAREKY", "<%=wareky%>");
			
			var skuType = $('input[name="SKUTYPE"]:checked').val();
			
			if(skuType == "IMV"){
				var json = netUtil.sendData({
					module : "Mobile",
					command : "MIM01_SKUKEY",
					sendType : "map",
					param : param
				});
				
				if(json.data['CNT'] == 0){
					commonUtil.msgBox("MASTER_M1104"); //품번을 확인해주세요.
					return;
				} else {
					if(json.data['ASKL04'] == "S"){
						commonUtil.msgBox("MASTER_M1110", json.data['ASKL05']); //입력한 품목코드는 서브품목입니다. 메인품목코드 [{(0)}]를 입력해주세요.
						return;
					}
				}
				
				dataBind.paramData("searchArea", param);
				mobile.linkPopOpen("/mobile/MIM01_POP.page", param);
			} else if(skuType == "BUYER") {
				var json = netUtil.sendData({
					module : "Mobile",
					command : "MIM01_MATNR",
					sendType : "map",
					param : param
				});
				
				if(json.data['CNT'] == 0){
					commonUtil.msgBox("MASTER_M1104"); //품번을 확인해주세요.
					return;
				}
				
				dataBind.paramData("searchArea", param);
				mobile.linkPopOpen("/mobile/MIM01_BUYER_POP.page", param);
			}
		}
	}
	
	function menuOpen(){
		window.top.menuOpen();
	}
	
	function linkPopCloseEvent(data){
		var param = new DataMap();
		var skukey = data.get("SKUKEY");
		$("#SKUKEY").val(skukey);
		param.put("SKUKEY", skukey);
		dataBind.paramData("searchArea", data);
		mobile.linkPopOpen("/mobile/MIM01_POP.page", param);
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
						<col width="80px"  />
						<col />
						<col width="60px" />
					</colgroup>
					<tbody>
						<tr>
							<th CL="STD_SKUG03,2"></th>
							<td colspan="2">
								<input type="radio" name="SKUTYPE" class="sku_type" id="IMV" value="IMV" checked="checked" />
								<label for="IMV">IMV</label>
								<input type="radio" name="SKUTYPE" class="sku_type" id="BUYER" value="BUYER" />
								<label for="BUYER">BUYER</label>
							</td>
						</tr>
						<tr>
							<th CL="STD_SKUKEY"></th>
							<td>
								<input type="text" class="text" id="SKUKEY" onfocus="clearText(this)"  onkeypress="commonUtil.enterKeyCheck(event, 'sendData()')" />
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