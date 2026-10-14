<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="project.common.bean.DataMap,java.util.ArrayList,project.common.bean.CommonConfig"%>
<%@ page import="project.common.util.*"%>
<%
    ArrayList list = (ArrayList)request.getAttribute("WAHMACOMBO");
    ArrayList list1 = (ArrayList)request.getAttribute("LANGKY");
    ArrayList list2 = (ArrayList)request.getAttribute("MSG");
    
    DataMap row;
    
    RSA rsa = RSA.getEncKey();
    request.setAttribute("publicKeyModulus", rsa.getPublicKeyModulus());
    request.setAttribute("publicKeyExponent", rsa.getPublicKeyExponent());
    request.getSession().setAttribute("__rsaPrivateKey__", rsa.getPrivateKey());
    
%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>Mobile MES</title>
<link rel="stylesheet" type="text/css" href="/mobile/css/mobile.css" />
<script type="text/javascript" src="/common/js/jquery.js"></script>
<script type="text/javascript" src="/common/js/json2.js"></script>
<script type="text/javascript" src="/common/js/jquery.cookie.js"></script>
<script type="text/javascript" src="/common/js/dataMap.js"></script>
<script type="text/javascript" src="/common/js/configData.js"></script>
<script type="text/javascript" src="/common/js/label.js"></script>
<script type="text/javascript" src="/common/js/commonUtil.js"></script>
<script type="text/javascript" src="/common/js/dataBind.js"></script>
<script type="text/javascript" src="/common/js/input.js"></script>
<script type="text/javascript" src="/common/js/netUtil.js"></script>
<script type="text/javascript" src="/common/js/ui.js"></script>
<script type="text/javascript" src="/common/js/validateUtil.js"></script>
<script type="text/javascript" src="/mes/js/jsbn.js"></script>
<script type="text/javascript" src="/mes/js/rsa.js"></script>
<script type="text/javascript" src="/mes/js/prng4.js"></script>
<script type="text/javascript" src="/mes/js/rng.js"></script>
<script>
var msgMap = new DataMap();
<%
for(int i=0;i<list2.size();i++){
    row = (DataMap)list2.get(i);
%>
msgMap.put("<%=row.get("MESGKY")%>","<%=row.get("MESGTX")%>");
<%
}
%>

var $langky;

function getMsg(msgCode){
    msgCode = $langky.val()+"_"+msgCode;
    return msgMap.get(msgCode);
}

function getLabel(){
    return "";
}

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
    $langky = jQuery("#LANGKY");
    
    $("select[name=WAREKY]").val("WH01");
    $("select[name=LANGKY]").val("KR");
    var WAREKY = $.cookie("WAREKY");
    if(WAREKY){
        jQuery("#WAREKY").val(WAREKY);
    }
    var LANGKY = $.cookie("LANGKY");
    if(LANGKY){
        jQuery("#LANGKY").val(LANGKY);
    }
    var USERID = $.cookie("USERID");
    if(USERID){
        jQuery("#USERID").val(USERID);
    }
    /*
    var PASSWD = $.cookie("PASSWD");
    if(PASSWD){
        jQuery("#PASSWD").val(PASSWD);
    }
    */
    
    changeWh(); 
    viewInfo();
});

function viewInfo(){
    var tmpMsg1 = getMsg("M0008");
    var tmpMsg2 = getMsg("M0009");
    $("#LOGINMSG1").text(tmpMsg1);
    $("#LOGINMSG2").text(tmpMsg2);
    var tmpVal = $("#LANGKY option:selected").text();
    jQuery("#LANGKY_TX").text(tmpVal);
}

function login(){
    //this.location.href = "/common/main.page";
    if(validate.check("searchArea")){
        var param = dataBind.paramData("searchArea");
        var plntky = jQuery("#PLNTKY").val();
        var rsaPublicKeyModulus = document.getElementById("rsaPublicKeyModulus").value;
        var rsaPublicKeyExponent = document.getElementById("rsaPublicKeyExponent").value;
        var encPassword = fnRsaEnc($('input[name=PASSWD]').val(), rsaPublicKeyModulus, rsaPublicKeyExponent);
        param.put("PASSWD", encPassword);
        param.put("PLNTKY", plntky);
        
        var json = netUtil.sendData({
            url : "/common/json/login.data",
            param : param
        });
        
        if(json && json.data){
            if(json.data == "F"){
                commonUtil.msg("LOGIN_M0001");
            }else{
                for(var prop in param.map){
                    $.cookie(prop, param.get(prop),{expires:7});
                }
                this.location.href = "/mobile/main.data";
            }
        }
    }   
}

function changeWh(){
    var tmpVal = $("#WAREKY option:selected").text();
    jQuery("#WAREKY_TX").text(tmpVal);
    
    var param = new DataMap();
    var wareky = jQuery("#WAREKY").val();
    param.put("WAREKY", wareky);
    var json = netUtil.sendData({
        module : "Mobile",
        command : "STLMA",
        sendType : "list",
        param : param
    });
    
    $('#PLNTKY').children('option').remove();
    jQuery("#PLNTKY_TX").text("");
    
    var option ="";
    if(json && json.data){
        if(json.data.length > 0){
            var vCol = "";
            var vVal = "";
            
            for(var i=0; i<json.data.length; i++){
                plntky = json.data[i].PLNTKY;
                cdesc1 = json.data[i].CDESC1;
                if(i==0){
                    vCol=plntky;
                    vVal=cdesc1;
                }
                option +="<option value="+plntky+">"+plntky+"["+cdesc1 +"]</option>";
            }
            jQuery("#PLNTKY_TX").text("["+vCol+"]"+vVal);
            $("#PLNTKY").append(option);        
        }
    }
    
}

function changeSt(){
    var ptlVal = $("#PLNTKY option:selected").text();
    jQuery("#PLNTKY_TX").text(ptlVal);
}


function fnRsaEnc(value, rsaPublicKeyModulus, rsaPpublicKeyExponent) {
    var rsa = new RSAKey();
    rsa.setPublic(rsaPublicKeyModulus, rsaPpublicKeyExponent);
    var encValue = rsa.encrypt(value); 
    return encValue;

}

</script>
</head>
<body>
    <div class="login_wrap">
        <div class="main_header">
            <ul>
                <li class="login_tit">WMS System</li>
            </ul>
            <h1>Login</h1>  
            <div class="login_area" id="searchArea">
                <div class="login_box">
                    <input type="text" class="id" id="USERID" name="USERID" placeholder="ID"/>
                    <input type="hidden" id="rsaPublicKeyModulus" value="${publicKeyModulus}">
                    <input type="hidden" id="rsaPublicKeyExponent" value="${publicKeyExponent}">
                    <input type="password" class="pw" id="PASSWD"  name="PASSWD" placeholder="PASSWORD" />
                </div>
                        <%
                            row = (DataMap)list.get(0);
                        %>
                <div class="select" style="padding:15px 0 0 0;height:35px;"><a id="WAREKY_TX">[<%=row.get("VALUE_COL")%>]<%=row.get("TEXT_COL")%></a>
                    <select id="WAREKY" name="WAREKY" validate="required" onChange="changeWh()">
                        <%
                            for(int i=0;i<list.size();i++){
                                row = (DataMap)list.get(i);
                        %>
                            <option value='<%=row.get("VALUE_COL")%>'>[<%=row.get("VALUE_COL")%>]<%=row.get("TEXT_COL")%></option>
                        <%
                            }
                        %>
                    </select>
                </div>
                
                
                <div class="select" style="padding:15px 0 0 0;height:35px;"><a id="PLNTKY_TX"></a>
                    <select id="PLNTKY" name="PLNTKY" validate="required" onChange="changeSt()">
                    
                    </select>
                </div>
                
                
                        <%
                            row = (DataMap)list1.get(0);
                        %>
                <div class="select" style="padding:15px 0 0 0;height:35px;"><a id="LANGKY_TX">[<%=row.get("VALUE_COL")%>]<%=row.get("TEXT_COL")%></a>
                    <select id="LANGKY" name="LANGKY" validate="required" onChange="viewInfo()" style="width:100%">
                    <%
                        for(int i=0;i<list1.size();i++){
                            row = (DataMap)list1.get(i);
                    %>
                        <option value='<%=row.get("VALUE_COL")%>'>[<%=row.get("VALUE_COL")%>]<%=row.get("TEXT_COL")%></option>
                    <%
                        }
                    %>
                    </select>
                </div>
            </div>
            <div class="login_btn">
                <ul class="btn1" onClick="login()">
                    <li class="img"><img src="/mobile/img/ico_login.png" /></li>
                    <li class="btn_txt">LOGIN</li>
                </ul>
            </div>
            <div>
                <ul class="login_txt">
                    <li id="LOGINMSG1"></li>
                    <li class="two" id="LOGINMSG2"></li>
                </ul>       
            </div>
        </div>      
    </div>
</body>