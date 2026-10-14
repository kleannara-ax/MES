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
		$("#DOORKY").focus();
	});
	
	function sendData(){
		var $obj = $("#DOORKY");
		var doType = $("input[name='DOTYPE']:checked").val();

		if($obj.val() == ""){
			commonUtil.msgBox("VALID_M1569");
			//alert("오더번호를 입력해주세요.");
			$obj.focus();
		}else{
			var flag = "";
			if(doType == "1"){
				var param = new DataMap();
				param.put("DOORKY", $obj.val());
				
				var json = netUtil.sendData({
					url : "/mobile/Mobile/json/validateMobileShpokyCheck.data",
					//returnParam: "map",
					param : param
				});
				
				flag = json.data;
			} else {
				flag = "OK";
			}
			
			if(flag == "OK"){
				location.href="/mobile/MDL06_list.page?DOORKY="+$obj.val()+"&DOTYPE="+doType;
			}else if(flag != "OK"){
				commonUtil.msgBox(flag);
				return;
			}
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
							<th></th>
							<td>
								<input type="radio" name="DOTYPE" value="1" />
								<label for="DOTYPE" CL="STD_SHIPREQ"></label> 
								<input type="radio" name="DOTYPE" value="2" checked="checked"/>
								<label for="DOTYPE" CL="STD_PICKPRT"></label>
							</td>
						</tr>
						<tr>
							<th CL="STD_PKBARCODE">피킹바코드</th>
							<td>
								<input type="text" class="text" id="DOORKY" onkeypress="commonUtil.enterKeyCheck(event, 'sendData()')"  onfocus="clearText(this)"/>
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