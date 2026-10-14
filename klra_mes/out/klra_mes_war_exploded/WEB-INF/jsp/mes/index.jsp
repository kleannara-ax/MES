<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="project.common.bean.DataMap,java.util.ArrayList,project.common.bean.CommonConfig,project.common.util.RSA"%>
<%
ArrayList list = (ArrayList)request.getAttribute("WAHMACOMBO");
ArrayList list1 = (ArrayList)request.getAttribute("LANGKY");
ArrayList list2 = (ArrayList)request.getAttribute("MSG");

DataMap row;

Object SES_USER_ID = request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY);

RSA rsa = RSA.getEncKey();
request.setAttribute("publicKeyModulus", rsa.getPublicKeyModulus());
request.setAttribute("publicKeyExponent", rsa.getPublicKeyExponent());
request.getSession().setAttribute("__rsaPrivateKey__", rsa.getPrivateKey());
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<title>MES</title>
<link rel="shortcut icon" href="/common/theme/webdek/images/logo01.png" type="image/x-ico" />
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no">
<script type="text/javascript" src="/common/theme/webdek/js/login/jquery-1.11.3.min.js"></script>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/login/layout.css" />
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/login/sub.css" />

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
<script type="text/javascript" src="/common/js/label.js"></script>

<script type="text/javascript" src="/mes/js/jsbn.js"></script>
<script type="text/javascript" src="/mes/js/rsa.js"></script>
<script type="text/javascript" src="/mes/js/prng4.js"></script>
<script type="text/javascript" src="/mes/js/rng.js"></script>

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

$(document).ready(function() {
	if ("N" == "<%=request.getAttribute("data")%>") {
		alert('아이디:<%=request.getAttribute("sproId")%> 존재하지 않습니다. 관리자에게 문의 하세요.')
	}
	$("#COMPID").val("AIRFW");
	
	var COLOR = $.cookie("COLOR");
	if(COLOR){
		//jQuery("#LANGKY").val(LANGKY);
		$("input[value="+COLOR+"]").attr("checked","checked");
	}
	
	var LANGKY = $.cookie("LANGKY");
	if(LANGKY){
		$("input[value="+LANGKY+"]").attr("checked","checked");
	}
	var USERID = $.cookie("USERID");
	if(USERID){
		jQuery("#USERID").val(USERID);
	}
});

function login(){
	//this.location.href = "/common/main.page";
	if(validate.check("searchArea")){
		var param = dataBind.paramData("searchArea");
		param.put("WAREKY", $("#WAREKY").val());
		param.put("LANGKY", $("#LANGKY").val());
		
		var rsaPublicKeyModulus = document.getElementById("rsaPublicKeyModulus").value;
		var rsaPublicKeyExponent = document.getElementById("rsaPublicKeyExponent").value;
		var encPassword = fnRsaEnc($('input[name=PASSWD]').val(), rsaPublicKeyModulus, rsaPublicKeyExponent);
		param.put("PASSWD", encPassword);
		
		var json = netUtil.sendData({
			url : "/mes/json/login.data",
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
			}
            if(json.data == "P"){
                commonUtil.msg("로그인 하고자 하는 보안(암호)키가 갱신되었습니다. \n기존 로그인 화면을 닫거나  페이지 새로고침을 하여 다시 진행해 주십시오.");
                console.log(location.href)
                // if(location.href.startsWith("http://mes.kleannara.com")) {
                //     location.href = 'https://mes.kleannara.com/index.page'
                // }
                // else {
                location.reload();
                //}
                return;
            }
            else if(json.data == "F_LOGIN_LOCK"){
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

function changePassword(){
    //if(validate.check("searchArea")){
        var param = dataBind.paramData("searchArea");
        page.linkPopOpen("/mes/password01.page", param);
    //}   
}
</script>
</head>
<body>
    <div id="A_Wrap">
        <div id="A_Container">
            <div class="login_form" id="searchArea">
	            <input type="hidden" id="rsaPublicKeyModulus" value="${publicKeyModulus}">
	            <input type="hidden" id="rsaPublicKeyExponent" value="${publicKeyExponent}">
                <div class="inner">
                    <h1 class="logo" onclick="location.href='javascript:;'">logo <img src="/common/theme/webdek/images/login/logo.png" alt="logo"> </h1>
                    <div class="logint_layout">
                        <div class="left">
                            <img src="/common/theme/webdek/images/login/login_img01.gif" />
                        </div>
                        <div class="center">
                            <form class="" action="index.html" method="post">
                                <h3 class="nanumgothic title">LOGIN</h3>
                                <ul class="login_list">
                                    <li>
                                        <select class="hyundai" id="LANGKY" name="LANGKY">
                                        <%
					                        for(int i=0;i<list1.size();i++){
					                            row = (DataMap)list1.get(i);
					                    %>
					                        <option value='<%=row.get("VALUE_COL")%>' <%="KR".equals(row.get("VALUE_COL")) ? "selected" : ""%>>[<%=row.get("VALUE_COL")%>]<%=row.get("TEXT_COL")%></option>
					                    <%
					                        }
					                    %>
                                        </select>
                                    </li>
                                    <li>
                                        <select class="hyundai" id="WAREKY" name="WAREKY">
                                            <%
						                        for(int i=0;i<list.size();i++){
						                            row = (DataMap)list.get(i);
						                    %>
						                        <option value='<%=row.get("VALUE_COL")%>'>[<%=row.get("VALUE_COL")%>]<%=row.get("TEXT_COL")%></option>
						                    <%
						                        }
						                    %>
                                        </select>
                                    </li>
                                    <li class="user">
                                        <input type="text" id="USERID" name="USERID" value="" onkeypress="commonUtil.enterKeyCheck(event, 'login()')">
                                    </li>
                                    <li class="pass">
                                        <input type="password" id="PASSWD" name="PASSWD" value="" onkeypress="commonUtil.enterKeyCheck(event, 'login()')">
                                    </li>
                                </ul>
                                <div class="chk_box">
                                    <input type="checkbox" id="save_id" onclick="idSave()">
                                    <label for="save_id"><span></span>
                                        <p>아이디 저장</p>
                                    </label>
                                </div>
                                <button type="button" name="button" class="login_btn hyundai" onclick="login();">로그인</button>
                                <ul class="searchList">
                                    <li>
                                        <a href="/downloadPlatformApp.html">Install Report Tool</a>
                                    </li>
                                    <li>
                                        <a href="javascript:changePassword();">비밀번호 변경</a>
                                    </li>
                                </ul>
                                <p class="customer"><strong class="nanumgothic">고객 센터 0000-0000</strong> (평일 09:00-18:00)</p>
                            </form>
                        </div>
                        <div class="right">
                            <ul>
                                <li>
                                    <div class="img_box">
                                        <img src="/common/theme/webdek/images/login/login_img02.png" />
                                    </div>
                                </li>
                                <li>
                                    <div class="img_box">
                                        <img src="/common/theme/webdek/images/login/login_img03.png" />
                                    </div>
                                </li>
                                <li>
                                    <div class="img_box">
                                        <img src="/common/theme/webdek/images/login/login_img04.png" />
                                    </div>
                                </li>
                            </ul>
                        </div>
                    </div>
                    <p class="hyundai copy">Copyrightⓒ 2022 KleanNara, All Rights Reserved. </p>
                </div>
            </div>
        </div>
    </div>
</body>

</html>