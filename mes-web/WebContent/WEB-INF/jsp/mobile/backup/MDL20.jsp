
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
		$("#PTNRKY").focus();
	});
	
	function sendData(){
		var $obj1 = $("#PTNRKY");
		var $obj2 = $("#BOXNO");
		if($obj1.val() == "" && $obj2.val() == ""){
			alert("거래처코드 또는 박스번호를 입력하세요.");
			$obj.focus();
		}else{ 
			location.href="/mobile/MDL20_list.page?PTNRKY="+$obj1.val()+"&BOXNO="+$obj2.val();
		} 
	}
	
	function linkPopCloseEvent(data){
		if(col=='ptnrky'){
			var PTNRKY = data.get("PTNRKY");
			$("#PTNRKY").val(PTNRKY);
		}else if(col=='boxno'){
			var BOXNO = data.get("BOXNO");
			$("#BOXNO").val(BOXNO);
		}
	}
	
	function linkPopupOpen(colName){
		col = colName;
		if(colName == 'ptnrky'){
			var $obj = $("#PTNRKY");
			mobile.linkPopOpen('/mobile/MDL20_search.page',$obj.val() );
		}else if(colName == 'boxno'){
			var $obj = $("BOXNO");
			mobile.linkPopOpen('/mobile/MDL20_boxSearch.page', $obj.val());
		}
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
						<col width="80px"  />
						<col />
						<col width="60px" />
					</colgroup>
					<tbody>
						<tr>
							<th>거래처코드</th>
							<td>
								<input type="text" class="text" id="PTNRKY"  onfocus="clearText(this)" onkeypress="commonUtil.enterKeyCheck(event, 'sendData()')"/>
							</td>
							<td>
								<input type="button" value="p" class="bt" onclick="linkPopupOpen('ptnrky')"/>
							</td>
						</tr>
						<tr>
							<th>BOX NO</th>
							<td>
								<input type="text" class="text" id="BOXNO"  onfocus="clearText(this)" onkeypress="commonUtil.enterKeyCheck(event, 'sendData()')"/>
							</td>
							<td>
								<input type="button" value="p" class="bt" onclick="linkPopupOpen('boxno')"/>
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