<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="project.common.bean.*,project.common.util.*,project.common.bean.CommonConfig,java.util.*"%>
<%
	Object SES_USER_ID = request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY);
	
	String langky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_LANGUAGE_KEY);
	String theme =(String)request.getSession().getAttribute(CommonConfig.SES_USER_THEME_KEY);
	
	RSA rsa = RSA.getEncKey();
	request.setAttribute("publicKeyModulus", rsa.getPublicKeyModulus());
	request.setAttribute("publicKeyExponent", rsa.getPublicKeyExponent());
	request.getSession().setAttribute("__rsaPrivateKey__", rsa.getPrivateKey());
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Password Change</title>
<style>
.pw_title{text-align:center;line-height:68px;background:#ECECEC;font-size:20px;color:#222222;font-weight:bold;border-top:3px solid #222222;}
.tit{text-align:center;line-height:68px;background:#ECECEC;font-size:20px;color:#222222;font-weight:bold;border-top:3px solid #222222;}
.login{text-align: center;}
.login button{margin-top: 8px; width:119px; height:33px;background: #222222;color:#ffffff;font-size:15px;font-weight:bold;}
</style>
<script type="text/javascript" src="/common/js/jquery.js"></script>
<script type="text/javascript" src="/common/js/jquery-ui.js"></script>
<%
	if(langky != null && (langky.equals("CN") || langky.equals("ZH"))){
%>
<script type="text/javascript" src="/common/js/datepicker/jquery.ui.datepicker-zh-CN.js"></script>
<%
	}else{
%>
<script type="text/javascript" src="/common/js/datepicker/jquery.ui.datepicker-ko.js"></script>
<%
	}
%>
<script type="text/javascript" src="/common/js/jquery.plugin.js"></script>
<script type="text/javascript" src="/common/js/jquery.form.js"></script>
<script type="text/javascript" src="/common/js/jquery.cookie.js"></script>
<script type="text/javascript" src="/common/js/json2.js"></script>
<script type="text/javascript" src="/common/js/big.js"></script>
<script type="text/javascript" src="/common/js/dataMap.js"></script>
<script type="text/javascript" src="/common/js/configData.js"></script>
<script type="text/javascript" src="/common/js/commonUtil.js"></script>
<script type="text/javascript" src="/common/js/dataBind.js"></script>
<script type="text/javascript" src="/common/js/input.js"></script>
<script type="text/javascript" src="/common/js/netUtil.js"></script>
<script type="text/javascript" src="/common/js/ui.js"></script>
<script type="text/javascript" src="/common/js/worker-ajax.js"></script>
<script type="text/javascript" src="/common/js/bigdata.js"></script>
<script type="text/javascript" src="/common/js/grid.js"></script>
<script type="text/javascript" src="/common/js/layoutSave.js"></script>
<script type="text/javascript" src="/common/js/validateUtil.js"></script>
<script type="text/javascript" src="/common/js/page.js"></script>

<script type="text/javascript" src="/mes/js/jsbn.js"></script>
<script type="text/javascript" src="/mes/js/rsa.js"></script>
<script type="text/javascript" src="/mes/js/prng4.js"></script>
<script type="text/javascript" src="/mes/js/rng.js"></script>
<script type="text/javascript">

	//로딩 열기
	function loadingOpen() {	
		var loader = $('<div class="contentLoading"></div>').appendTo('body');
	
		loader.stop().animate({
			top : '0px'
		}, 30, function() {
		});
	}
	
	// 로딩 닫기
	function loadingClose() {
	
		var loader = $('.contentLoading');
	
		loader.stop().animate({
			top : '100%'
		}, 30, function() {
			loader.remove();
		});
	}
	
	var labelObj = new Object();
	
	CommonLabel = function() {
		this.labelHistory = new Array();
		this.label = new DataMap();
	};

	CommonLabel.prototype = {
		getLabel : function(key, type) {
			if(this.label.containsKey(key)){
				var ltxt = this.label.get(key);
				this.labelHistory.push(key+" "+ltxt.split(configData.DATA_COL_SEPARATOR)[type]);
				return ltxt.split(configData.DATA_COL_SEPARATOR)[type];
			}else{
				return key;
			}
		},
		resetHistory : function(){
			this.labelHistory = new Array();
		},
		showHistory : function() {
			var data = this.labelHistory.join("\n");
			if (window.clipboardData) { // Internet Explorer
		        window.clipboardData.setData("Text", data);
		    } else {  
		    	var temp = prompt("Ctrl+C를 눌러 클립보드로 복사하세요", data);
		    }
		},
		toString : function() {
			return "CommonLabel";
		}
	};
	
	CommonMessage = function() {
		this.message = new DataMap();
	};
	
	CommonMessage.prototype = {
		getMessage : function(key) {
			var mtxt = this.message.get(key);
			if(mtxt){
				commonLabel.labelHistory.push(key+" "+mtxt.split(configData.DATA_COL_SEPARATOR)[1]);
				return mtxt.split(configData.DATA_COL_SEPARATOR)[1];
			}else{
				return key;
			}
		},
		toString : function() {
			return "CommonMessage";
		}
	};
	
	var commonMessage = new CommonMessage();
	
	function getLabel(key, type){
		if(!type){
			type = 1;
		}
		return commonLabel.getLabel(key, type);
	}
	function getMessage(key){
		return commonMessage.getMessage(key);
	}

	window.resizeTo('700','650');
	
	var langky;
	
	$(document).ready(function(){
		try{
		    topLabelFrame = window;
		}catch(e){
			;
		}
		uiList.UICheck();
		inputList.setInput();
		inputList.setCombo();
		
		var data = page.getLinkPopData();
		dataBind.dataNameBind(data, "searchArea");
		langky = data.get("LANGKY");
	});

	function commonBtnClick(btnName){
		if(btnName == "Save"){
			saveData();
		}
	}
	
	function saveData(){
		//if(validate.check("searchArea")){
			var param = dataBind.paramData("searchArea");

			if($.trim(param.get("USERID")) == ""){
				//commonUtil.msgBox("VALID_M0701");   //사원번호 / ID은(는) 필수 입력항목입니다.
				alert("사원번호 / ID은(는) 필수 입력항목입니다.");
				return;
			}
			if($.trim(param.get("PASSWD")) == ""){
				//commonUtil.msgBox("VALID_M0702");   //현재 패스워드는 필수 입력항목입니다.
				alert("현재 패스워드는 필수 입력항목입니다.");
				return;
			}	
			if($.trim(param.get("PASSWD1")) == ""){
				//commonUtil.msgBox("VALID_M0703");   //신규 패스워드는 필수 입력항목입니다.
				alert("신규 패스워드는 필수 입력항목입니다.");
				return;
			}	
			if($.trim(param.get("PASSWD2")) == ""){
				//commonUtil.msgBox("VALID_M0704");   //확인 패스워드는 필수 입력항목입니다.
				alert("확인 패스워드는 필수 입력항목입니다.");
				return;
			}				

			//1. 변경 비빌번호 두개가 일치하지 않습니다.
			if(param.get("PASSWD1") != param.get("PASSWD2")){
				//commonUtil.msgBox("VALID_M0711");   //변경 비빌번호 두개가 일치하지 않습니다.
				alert("변경 비빌번호 두개가 일치하지 않습니다.");
				return;
			}		
			
			//2. ID와 비빌번호는 같을 수 없습니다.
			if(param.get("USERID") == param.get("PASSWD1")){
				//commonUtil.msgBox("VALID_M0712");   //ID와 비빌번호는 같을 수 없습니다.
				alert("ID와 비빌번호는 같을 수 없습니다.");
				return;
			}	
			
			//3. 변경 비빌번호와 현재 비밀번호는 같을 수 없습니다.
			if(param.get("PASSWD") == param.get("PASSWD1")){
				//commonUtil.msgBox("VALID_M0713");   //변경 비빌번호와 현재 비밀번호는 같을 수 없습니다.
				alert("변경 비빌번호와 현재 비밀번호는 같을 수 없습니다.");
				return;
			}				
			
			var chk = 0;
			var currentPwd;
			currentPwd = String(param.get("PASSWD1"));
			if(currentPwd.search(/[0-9]/g) != -1) chk++;
			if(currentPwd.search(/[A-Z]/g) != -1) chk++;
			if(currentPwd.search(/[a-z]/g) != -1) chk++;
			if(currentPwd.search(/[!@#$%^&*0?_~]/g) != -1) chk++;

			if(chk < 2)
			{
				//commonUtil.msgBox("VALID_M0714");   //비밀번호는 숫자, 영대문자, 영소문자, 특수문자를 두가지 이상 혼용하여야 합니다.
				alert("비밀번호는 숫자, 영대문자, 영소문자, 특수문자를 두가지 이상 혼용하여야 합니다.");
				return;
			}	
			//길이(2개 혼용시 10자이상)
			if(chk == 2 && !/^[a-zA-Z0-9!@#$%^&*0?_~]{10,15}$/.test(currentPwd))
			{			
				//commonUtil.msgBox("VALID_M0715");   //비밀번호는 숫자, 영대문자, 영소문자, 특수문자 중 2종류 조합시 10~15자리를 사용해야 합니다.
				alert("비밀번호는 숫자, 영대문자, 영소문자, 특수문자 중 2종류 조합시 10~15자리를 사용해야 합니다.");
				return;			
			}
			//길이(3개 혼용시 8자이상)
			if(chk > 2 && !/^[a-zA-Z0-9!@#$%^&*0?_~]{8,15}$/.test(currentPwd))
			{
				//commonUtil.msgBox("VALID_M0716");   //비밀번호는 숫자, 영대문자, 영소문자, 특수문자 중 3종류 이상 조합시 8~15자리를 사용해야 합니다.
				alert("비밀번호는 숫자, 영대문자, 영소문자, 특수문자 중 3종류 이상 조합시 8~15자리를 사용해야 합니다.");
				return;							
			}

			//동일한 문자/숫자 4이상, 연속된 문자
			if(/(\w)\1\1\1/.test(currentPwd) || isContinuedValue(currentPwd)){			
				//commonUtil.msgBox("VALID_M0717");   //비밀번호에 4자 이상의 연속 또는 반복 문자 및 숫자를 사용하실 수 없습니다.
				alert("비밀번호에 4자 이상의 연속 또는 반복 문자 및 숫자를 사용하실 수 없습니다.");
				return;				
			}
			
			//아이디 포함 여부
			if(currentPwd.search(param.get("USERID")) > -1)
			{
				//commonUtil.msgBox("VALID_M0718");   //아이디가 포함된 비밀번호는 사용하실 수 없습니다.
				alert("아이디가 포함된 비밀번호는 사용하실 수 없습니다.");
				return;							
			}	
			
			var rsaPublicKeyModulus = document.getElementById("rsaPublicKeyModulus").value;
			var rsaPublicKeyExponent = document.getElementById("rsaPublicKeyExponent").value;
			var encPassword = fnRsaEnc($('input[name=PASSWD]').val(), rsaPublicKeyModulus, rsaPublicKeyExponent);
			var encPassword1 = fnRsaEnc($('input[name=PASSWD1]').val(), rsaPublicKeyModulus, rsaPublicKeyExponent);
			var encPassword2 = fnRsaEnc($('input[name=PASSWD2]').val(), rsaPublicKeyModulus, rsaPublicKeyExponent);
			param.put("PASSWD", encPassword);
			param.put("PASSWD1", encPassword1);
			param.put("PASSWD2", encPassword2);
			
			var json = netUtil.sendData({
		    	url : "/common/json/password.data",
		    	param : param
		    });
			
			if(json && json.data){
				if(json.data == "F"){
					alert("아이디 또는 비밀번호가 일치 하지 않습니다.");
					return;
				}else if(json.data == "F_PWD_BEFVAL"){
					alert("이전 비밀번호와 동일합니다. 다른 비밀번호를 입력하십시오.");
					return;
				}else if(json.data == "F_LOGIN_RSA"){
					alert("비밀번호 암호화 과정에서 실패하였습니다.");
					return;
				}else{
					alert("비밀번호 변경 완료되었습니다. \n로그인 페이지로 이동합니다.");
					this.close();
				}
			}
		//}		
	}
	
	function fnRsaEnc(value, rsaPublicKeyModulus, rsaPpublicKeyExponent) {
		var rsa = new RSAKey();
		rsa.setPublic(rsaPublicKeyModulus, rsaPpublicKeyExponent);
		var encValue = rsa.encrypt(value); 
		return encValue;
	}
	 
    function isContinuedValue(value) {
        var intCnt1 = 0;
        var intCnt2 = 0;
        var temp0 = "";
        var temp1 = "";
        var temp2 = "";
        var temp3 = "";
 
        for (var i = 0; i < value.length-3; i++) {
            temp0 = value.charAt(i);
            temp1 = value.charAt(i + 1);
            temp2 = value.charAt(i + 2);
            temp3 = value.charAt(i + 3);
 
            if (temp0.charCodeAt(0) - temp1.charCodeAt(0) == 1
                    && temp1.charCodeAt(0) - temp2.charCodeAt(0) == 1
                    && temp2.charCodeAt(0) - temp3.charCodeAt(0) == 1) {
                intCnt1 = intCnt1 + 1;
            }
 
            if (temp0.charCodeAt(0) - temp1.charCodeAt(0) == -1
                    && temp1.charCodeAt(0) - temp2.charCodeAt(0) == -1
                    && temp2.charCodeAt(0) - temp3.charCodeAt(0) == -1) {
                intCnt2 = intCnt2 + 1;
            }
        }
 
        return (intCnt1 > 0 || intCnt2 > 0);
    };	
	
	function fn_closing(){
		this.close();
	}		
</script>
</head>
<body>
<!-- searchPop -->
<div class="searchPop" id="searchArea">
	<div class="searchInnerContainer">
		<input type="hidden" id="rsaPublicKeyModulus" value="${publicKeyModulus}">
		<input type="hidden" id="rsaPublicKeyExponent" value="${publicKeyExponent}">
		<div class="pw_title">비밀번호 변경</div>
		<div class="searchInBox">
			<table class="table type1" style="margin:3% 0 0 20%;">
				<colgroup>
					<col width="100" />
					<col />
				</colgroup>
				<tbody>
					<tr>
						<th style="width:50%;">사용자 ID</th>
						<td>
							<input type="text" id="USERID" name="USERID" class="normalInput" validate="required"/>
						</td>
					</tr>
					<tr>
						<th>현재패스워드</th>
						<td>
							<input type="password" name="PASSWD" class="normalInput" validate="required"/>
						</td>
					</tr>
					<tr>
						<th>신규패스워드</th>
						<td>
							<input type="password" name="PASSWD1" class="normalInput" validate="required"/>
						</td>
					</tr>
					<tr>
						<th>확인패스워드</th>
						<td>
							<input type="password" name="PASSWD2" class="normalInput" validate="required"/>
						</td>
					</tr>
				</tbody>
			</table>
		</div>
		<!-- 비밀번호 변경 규칙 -->
		<div class="searchInBox" style="margin-top:5%;">
		    <h2 class="tit" CL="비밀번호 변경 규칙">비밀번호 변경 규칙</h2>
			<table class="table type1" style="text-align:left; font-size:15px;">
				<colgroup>
					<col width="100" />
					<col width="300" />					
					<col width="250" />
				</colgroup>
				<tbody>
					<tr>
						<th rowspan="3">[사용가능]</th>
						<th>숫자/영문/특수문자 3가지 조합 8~15자리</th>
						<th>(예시) g00day@@, knwms12#</th>
					</tr>
					<tr>
						<th>숫자/영문/특수문자 2가지 조합 10~15자리</th>
						<th>(예시) niceday123, password@@</th>						
					</tr>
					<tr>
						<th>대/소문자 구분</th>
					</tr>
					<tr>
						<th></th>
					</tr>
					<tr style="color:red;">
						<th>[사용제한]</th>
						<th>4자 이상 연속/중복 불가</th>
						<th>(예시) abcd, aaaa, 1234, 1111</th>
					</tr>
				</tbody>
			</table>
		</div>	
		<div class="btn login" style="text-align: center; margin-top: 5%;" >
			<button onclick="saveData();">저장</button>
			<button onclick="fn_closing();">취소</button>				
		</div>			
	</div>
</div>
<!-- //searchPop -->
</body>
</html>