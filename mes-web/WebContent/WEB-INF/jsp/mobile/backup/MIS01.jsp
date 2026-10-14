<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	String DOORKY = "";
	if(request.getParameter("DOORKY") != null){
		DOORKY = request.getParameter("DOORKY");
	}
	
	String DOTYPE = "1";
	if(request.getParameter("DOTYPE") != null){
		DOTYPE = request.getParameter("DOTYPE");
	}
	
	boolean passYN = false;
	if(request.getParameter("PASSYN") != null){
		passYN = Boolean.parseBoolean(request.getParameter("PASSYN"));
	}
%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>Mobile WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		$("#DOORKY").focus().val("<%=DOORKY%>");
	});
	
	var passYN = <%=passYN%>;
	function sendData(){
		var $obj = $("#DOORKY");
		var doType = $("input[name='DOTYPE']:checked").val();

		if($obj.val() == ""){
			commonUtil.msgBox("IN_M0010"); //구매오더 번호를 입력해 주세요.
			$obj.focus();
		}else{
			
			// 저장 후 다시 스캔 하면 메세지가 나오지 않도록
			if(!passYN){
				var param = new DataMap();
				// 서명유무 체크
				param.put("SIGNTYPE", "IN");
				param.put("DOTYPE", doType);
				param.put("DOCUKY", $obj.val());
				
				var json = netUtil.sendData({
					module : "Mobile",
					command : "WKSIGN",
					sendType : "map",
					param : param
				});
				
				if(json && json.data){
					if(!commonUtil.msgConfirm("IN_M0138")){
						return;
					}
				}
			}
			
			
			location.href="/mobile/MIS01_list.page?DOORKY="+$obj.val()+"&DOTYPE="+doType;
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
								<input type="radio" name="DOTYPE" value="1" id="TRANS" <%if(DOTYPE.equals("1")){%>checked="checked"<%}%> />
								<label for="TRANS" CL="STD_330"></label> 
								<input type="radio" name="DOTYPE" value="2" id="SALES" <%if(DOTYPE.equals("2")){%>checked="checked"<%}%> />
								<label for="SALES" CL="STD_GP00_SEARCH_F1"></label>
							</td>
						</tr>
						<tr>
							<th CL='STD_STKNUM1'>번호</th>
							<td>
								<input type="text" class="text" id="DOORKY" onfocus="clearText(this)" onkeypress="commonUtil.enterKeyCheck(event, 'sendData()')"/>
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