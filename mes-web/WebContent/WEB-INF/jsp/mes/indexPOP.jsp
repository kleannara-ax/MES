<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.common.bean.DataMap,java.util.ArrayList,com.common.bean.CommonConfig"%>
<%@ page import="com.common.util.XSSRequestWrapper"%>
<%
    XSSRequestWrapper sFilter = new XSSRequestWrapper(request);

    ArrayList list2 = (ArrayList)request.getAttribute("MSG");
    DataMap row; 
    String theme      = sFilter.getXSSFilter(CommonConfig.SYSTEM_THEME_PATH);
	String sysTitle   = sFilter.getXSSFilter(CommonConfig.SYSTEM_TITLE);
	String sysVersion = sFilter.getXSSFilter(CommonConfig.SYSTEM_VERSION);    
	
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<title><%=sysTitle%> <%=sysVersion%></title>
<link rel="stylesheet" type="text/css" href="/common/css/password.css">
<script type="text/javascript" src="/common/js/jquery.js"></script>
<script type="text/javascript" src="/common/js/jquery-ui.js"></script>
<script type="text/javascript" src="/common/js/json2.js"></script>
<script type="text/javascript" src="/common/js/jquery.cookie.js"></script>
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
<script type="text/javascript" src="/common/js/validateUtil.js"></script>
<script type="text/javascript" src="/common/js/page.js"></script>
<script type="text/javascript" src="/mes/js/mes.js"></script>
<script>
    window.resizeTo('500','610');

	var msgMap = new DataMap();
	<%
	    for(int i=0;i<list2.size();i++){
	        row = (DataMap)list2.get(i);
	%>
            msgMap.put("<%=sFilter.getXSSFilter(row.getString("MESGKY"))%>","<%=sFilter.getXSSFilter(row.getString("MESGTX"))%>");
    <%
	    }
	%>
	var $langky;

	function getMsg(msgCode){		
	    msgCode = $langky.val()+"_"+msgCode;
	    return msgMap.get(msgCode);
	}
	
	$(document).ready(function(){
	    $langky = jQuery("#LANGKY");
   		try{
   			//document.getElementById("AUTHKY").value = opener.document.getElementById("AUTHKY").value;
   			document.getElementById("USERID").value = opener.document.getElementById("USERID").value;
   			document.getElementById("WAREKY").value = opener.document.getElementById("WAREKY").value;
   			document.getElementById("LANGKY").value = opener.document.getElementById("LANGKY").value;
		}catch(e){
			alert("인증되지 않았습니다. 재인증 바랍니다.");
			location.href = '/mes/index/index.page';
			return;
		}
	});

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
	

    function check(param){
    	
    	// 1. 변경 비밀번호 두개가 일치하지 않습니다.
        if(param.get("NEWPASSWD") != param.get("NEWPASSWD2")){
            alert("변경 비밀번호 두개가 일치하지 않습니다.");
            return false;
        }
        
        // 2. ID와 비밀번호는 같을 수 없습니다
        if(param.get("USERID") == param.get("NEWPASSWD")){
            alert("ID와 비밀번호는 같을 수 없습니다");
            return false;
        }  
        
        // 3. 영문자 숫자 패턴 체크
        // 4. 영문자 숫자 패턴 & 자리수 체크
        // 영문, 숫자, 특수문자 2종 이상 혼용
        var newPassword= String(param.get("NEWPASSWD"));
        var chk = 0;
        if(newPassword.search(/[0-9]/g) != -1 ) chk ++;
        if(newPassword.search(/[a-z]/ig)  != -1 ) chk ++;
        if(newPassword.search(/[!@#$%^&*()?_~]/g)  != -1  ) chk ++;
        if(chk < 2){ 
            alert("비밀번호 규칙을 확인 후 다시 등록해주세요1.");
            return false;
        }else if(chk < 3 && String(param.get("NEWPASSWD")).length < 10){
            alert("비밀번호 규칙을 확인 후 다시 등록해주세요2.");
            return false;
        }else if(chk < 4 && String(param.get("NEWPASSWD")).length < 8){
            alert("비밀번호 규칙을 확인 후 다시 등록해주세요3.");
            return false;
        }

        // 5. 1234567890 / ABCDEFG 등 연속된 숫자가 4자리 이상이면 안될 것-> 역순 포함 
        if(/(\w)\1\1\1/.test(newPassword) || isContinuedValue(newPassword)) {
            alert("비밀번호는 연속된 문자가 4자리이상이면 안됩니다.");
            return false;
        }
        
        var json = netUtil.sendData({
            url : "/mes/json/loginChk.data",
            param : param
        }); 
        
        if(json && json.data){
            if(json.data == "F"){
                alert("아이디 또는 비밀번호가 일치 하지 않습니다.");
                return false;
            }else if ( json.data == "D" ){
            	alert("삭제된 아이디입니다. 관리자에게 문의하세요.");
                return false;
            }else if ( json.data == "N" ){
            	alert(json.Msg);
                return false;
            }
        }
        return true;
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
    }
    
    
	function change(){
		if(validate.check("searchArea")){
            var param = dataBind.paramData("searchArea");
             if(!check(param)) {
                 return;
             }
             
			json = netUtil.sendData({
				url : "/mes/json/updatepassword.data",
				param : param
			});
			
			if(json && json.data){
				alert("저장이 성공하였습니다.");
				this.close();
			}else{
				alert("저장이 실패하였습니다.");
			}
		}	
	}
	
	function validationEventMsg(valObjType, objIndex, objId, objName, objValue, valType){
	    if(objName == "USERID"){
	        return getMsg("M0002");      //LOGIN_M0002
	    }else if(objName == "NEWPASSWD"){
            return getMsg("M0003");      //LOGIN_M0003
        }else if(objName == "NEWPASSWD2"){
            return getMsg("M0003");      //LOGIN_M0003
        }else if(objName == "WAREKY"){
	        return getMsg("M0004");      //LOGIN_M0004
	    }else if(objName == "LANGKY"){
	        return getMsg("M0005");      //LOGIN_M0005
	    }
	}

	// 값 존재 체크
	function isNull(sValue) {
	    var value = (sValue+"").replace(" ", "");
	    
	    if( new String(value).valueOf() == "undefined")
	        return true;
	    if( value == null )
	        return true;
	    if( value.toString().length == 0 )
	        return true;
	    
	    return false;
	}
	// keyPress Enter 처리 함수
	function checkList(num){
	    // 필수입력값 체크 
	    // 모두 입력 sendData
	    // 미입력 빈값 포커스
	    
	    var param  = dataBind.paramData("searchArea");
	    
	    var USERID     = $.trim(param.get("USERID"));
        var NEWPASSWD  = $.trim(param.get("NEWPASSWD"));
        var NEWPASSWD2 = $.trim(param.get("NEWPASSWD2"));
	        
	    if( isNull( USERID ) ||  isNull( NEWPASSWD ) ||  isNull( NEWPASSWD2 )){
	        if(isNull( USERID )){
	            $("[name='USERID']").focus();
	        }else if ( isNull( NEWPASSWD ) ){
                $("[name='NEWPASSWD']").focus();
            }else if ( isNull( NEWPASSWD2 ) ){
                $("[name='NEWPASSWD2']").focus();
            }
	    }else{
	    	change();
	    }
	}
</script>
</head>
<body>
<div class="bg">
    <div class="outerwrap">
        <div class="passwrap" id="searchArea">
        <input type="hidden" id="WAREKY" name="WAREKY"/>
        <input type="hidden" id="LANGKY" name="LANGKY"/>
        <input type="hidden" id="AUTHKY" name="AUTHKY"/>

             <div class="change">
            
                <h1>Password Change</h1>
                
                <div class="id">
                    <input type="text"     id="USERID"     name="USERID"     placeholder="ID"           validate="required" onkeypress="commonUtil.enterKeyCheck(event, 'checkList()')" maxlength="80" style="ime-mode:inactive" readonly="readonly"/>
                </div>
                
                <div class="pw">
                    <input type="password" id="NEWPASSWD"  name="NEWPASSWD"  placeholder="New Password" validate="required" onkeypress="commonUtil.enterKeyCheck(event, 'checkList()')" maxlength="80"/>
                </div>
                
                <div class="pw">
                    <input type="password" id="NEWPASSWD2" name="NEWPASSWD2" placeholder="New Password Confirm" validate="required" onkeypress="commonUtil.enterKeyCheck(event, 'checkList()')" maxlength="80"/>
                </div>
                
                <div class="selectWrap2">
                	<button id="Change" onclick="change()">Change</button>
                </div>   
                    
                <div class="selectWrap3">                      
	                <h1 style="font-family:dotum; font-size:13px; color:#666; text-align: left">[ 비밀번호 규칙 ]</h1>
	                <h1 style="font-family:dotum; font-size:11.5px; color:#666; text-align: left">다음 각 항목의 문자종류 중 2종류 이상 조합하여</h1>
	                <h1 style="font-family:dotum; font-size:11.5px; color:#666; text-align: left">최소 10자리 이상 또는 3종류 이상 조합하여</h1>
	                <h1 style="font-family:dotum; font-size:11.5px; color:#666; text-align: left">최소 8자리 이상으로 설정해야 합니다.</h1>
	                <h1 style="font-family:dotum; font-size:11.5px; color:#666; text-align: left">- 영문 대문자 (26개)</h1>
	                <h1 style="font-family:dotum; font-size:11.5px; color:#666; text-align: left">- 영문 소문자 (26개)</h1>
	                <h1 style="font-family:dotum; font-size:11.5px; color:#666; text-align: left">- 숫자 (10개)</h1>
	                <h1 style="font-family:dotum; font-size:11.5px; color:#666; text-align: left">- 특수문자 (32개)</h1>
                </div>                   
            </div>

        </div>
    </div>
</div>  
</body>
</html>