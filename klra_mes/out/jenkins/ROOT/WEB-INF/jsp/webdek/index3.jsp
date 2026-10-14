<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="project.common.bean.DataMap,java.util.ArrayList,project.common.bean.CommonConfig"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<title>MES</title>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/login.css">
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/login3.css">
<link rel="shortcut icon" href="/common/theme/webdek/images/logo01.png" type="image/x-ico" />
<script type="text/javascript" src="/common/js/jquery.js"></script>
<script type="text/javascript" src="/common/js/jquery-ui.js"></script>
<script type="text/javascript" src="/common/js/json2.js"></script>
<script type="text/javascript" src="/common/js/jquery.cookie.js"></script>
<script type="text/javascript" src="/common/js/dataMap.js"></script>
<script type="text/javascript" src="/common/js/configData.js"></script>
<script type="text/javascript" src="/common/js/site.js"></script>
<script type="text/javascript" src="/common/js/commonUtil.js"></script>
<script type="text/javascript" src="/common/js/dataBind.js"></script>
<script type="text/javascript" src="/common/js/input.js"></script>
<script type="text/javascript" src="/common/js/netUtil.js"></script>
<script type="text/javascript" src="/common/js/ui.js"></script>
<script type="text/javascript" src="/common/js/worker-ajax.js"></script>
<script type="text/javascript" src="/common/js/grid.js"></script>
<script type="text/javascript" src="/common/js/validateUtil.js"></script>
<script type="text/javascript" src="/common/theme/webdek/js/theme.js"></script>
<script type="text/javascript" src="/common/js/page.js"></script>
<script>

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

$(document).ready(function(){
	$("#COMPID").val("WDSCM");
	//$("#COMPID").val("GCCL");

	//inputList.setCombo();

	var COLOR = $.cookie("COLOR");
	if(COLOR){
		//jQuery("#LANGKY").val(LANGKY);
		$("input[value="+COLOR+"]").attr("checked","checked");
	}
	
	var LANGKY = $.cookie("LANGKY");
	if(LANGKY){
		//jQuery("#LANGKY").val(LANGKY);
		$("input[value="+LANGKY+"]").attr("checked","checked");
	}
	var USERID = $.cookie("USERID");
	if(USERID){
		jQuery("#USERID").val(USERID);
	}
	var PASSWD = $.cookie("PASSWD");
	if(PASSWD){
		jQuery("#PASSWD").val(PASSWD).focus();
	}

	//checkEZPlatformApp();
});

function login(){
	//this.location.href = "/common/main.page";
	if(validate.check("searchArea")){
		var param = dataBind.paramData("searchArea");
		param.put("LANGKY","KO");
		
		var json = netUtil.sendData({
			url : "/common/json/login.data",
			param : param
		});
		if(json && json.data){
			if(json.data == "N"){
				commonUtil.msg("접속 정보가 다릅니다.\n다시 로그인 해주세요.");
				return;
			} else if(json.data == "F"){
				if(json.cnt < 5){
	                commonUtil.msg("로그인 접속 오류 ( "+json.cnt+"/5 )");
				}else{
                    commonUtil.msg("로그인이 제한됩니다.");
				}
				return;
			}else if(json.data == "F_LOGIN_LOCK"){
 				commonUtil.msg("비밀번호 5회 오류로 사용이 제한 되었습니다. \n비밀번호 찾기를 통해 임시 비밀번호를 발급받아주세요.");
				return;
			}else if(json.data == "F_LOGIN_INIT"){
				commonUtil.msg("비밀번호를 변경해주세요.");
	            page.linkPopOpen("/GCLC/CM/CM10/CM1107_POP.page","", "height=335,width=500,resizable=yes");
				return;
			}else if(json.data == "F_USE_LOCK"){
                commonUtil.msg("사용 승인되지 않은 계정입니다.");
			}else if(json.data == "F_PASSWORD_CHANGE"){
                commonUtil.msg("비밀번호를 변경해주세요.(180일 경과)");
                page.linkPopOpen("/GCLC/CM/CM10/CM1107_POP.page","", "height=335,width=500,resizable=yes");
            }else if(json.data == "NM"){
                commonUtil.msg("메뉴 권한이 없습니다.");
                return;
            }else{
				for(var prop in param.map){
					$.cookie(prop, param.get(prop),{expires : 7});
				}
				if(json && json.data){
					this.location.href = "/main.page";
				}
			}
		}
	}	
}

function fnRsaEnc(value, rsaPublicKeyModulus, rsaPpublicKeyExponent) {
	var rsa = new RSAKey();
	rsa.setPublic(rsaPublicKeyModulus, rsaPpublicKeyExponent);
	var encValue = rsa.encrypt(value); 
	return encValue;
}

function validationEventMsg(valObjType, objIndex, objId, objName, objValue, valType){
	//commonUtil.debugMsg("validationEventMsg : ", arguments);
	if(objName == "USERID"){
		return "ID required.";
	}else if(objName == "PASSWD"){
		return "Password required.";
	}else if(objName == "LANGKY"){
		return "Language required.";
	}
}

function checkEZPlatformApp(){
   if(typeof window.localStorage == 'undefined') {
      //alert("로컬 스토리지를 지원하지 않습니다."); //LOGIN_M0006
      //alert(getMsg("SYSTEM_NOLOCALSTORAGE"));
      commonUtil.msgBox("SYSTEM_NOLOCALSTORAGE");
      return;
   }
   var version = window.localStorage.getItem('EZPlatformApp');
   if( version != "1.0.0.11" ){
	   window.open('/downloadPlatformApp.html','egzen','width=500,height=300');
   }
}
</script>
</head>
<body class="weddek">
	<!-- <div class="bg-gradient"></div>
	<div class="bg-gradient"></div> -->
	<div class="show">
		<!-- <div class="logos">
			<img src="/common/theme/webdek/images/login/LOGO_1.png" />
			<img src="/common/theme/webdek/images/login/LOGO_2.png" />
			<img src="/common/theme/webdek/images/login/LOGO_3.png" />
			<img src="/common/theme/webdek/images/login/WEBDekWMS.png" />
		</div> -->
		<div class="signin" id="searchArea">
		    <div class="inputbox">
				<img class="login_logo" src="/common/theme/webdek/images/login/logo.png" />
		    	<label class="User_style">Username</label>
			    <input type="text" id="USERID" name="USERID" validate="required" onkeypress="commonUtil.enterKeyCheck(event, 'login()')" placeholder="ID"/>
			    <label class="User_style">Password</label>
			    <input type="password" id="PASSWD" name="PASSWD" validate="required" onkeypress="commonUtil.enterKeyCheck(event, 'login()')" placeholder="Password"/>
			    <div class="save_ID"><input id="save_id" type="checkbox" /><span></span><label for="save_id">아이디 저장</label></div>
			    <button class="find_IDPW" onClick="window.open('/FIND_IDPW_POP.jsp','idfind','width=560,height=510,location=no,status=no,scrollbars=no');">ID/비밀번호 찾기</button>
			    <input type="button" name="SignIn" value="Log in" onclick="login()">
			    <p>Copyright ⓒ 2020 SCMInno. All rights reserved.</p>
		    </div>
		    <div class="radio" style="display:none">
		        <input type="radio" id="RED" name="COLOR" value="red"  /><label for="RED">Red</label>
		        <input type="radio" id="SKYBLUE" name="COLOR" value="skyblue" /><label for="SKYBLUE">Sky Blue</label>
		        <input type="radio" id="navy" name="COLOR" value="navy" checked="checked"/><label for="navy">Navy</label>
		        <input type="radio" id="GRAY" name="COLOR" value="gray" /><label for="GRAY">Gray</label>
		        <input type="radio" id="BLACK" name="COLOR" value="black" /><label for="BLACK">Black</label>
		    </div>
		</div>
	<footer>
		<select onchange="if(this.value) location.href=(this.value);">
			<option>Family Site</option>
			<option value="http://www.scminno.com/">SCMInno</option>
			<option value="http://www.redeess.com/">Redeess</option>
		</select>
        <span>v1.0.0</span>
	</footer>
	</div>
</body>
</html>