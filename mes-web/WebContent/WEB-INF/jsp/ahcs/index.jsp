<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html xml:lang="ko" lang="ko">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<title>로그인</title>
<link type="text/css" rel="stylesheet" href="/common/theme/ahcs/css/login.css" />
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
<script type="text/javascript" src="/common/theme/ahcs/js/common.js"></script>
<script type="text/javascript" src="/common/theme/ahcs/js/head.js"></script>
<script>

var $langky;
var topLabelFrame;

$(document).ready(function(){
	$langky = jQuery("#LANGKY");
	
	topLabelFrame = window;
	
	inputList.setCombo();

	//checkEZPlatformApp();
	var USERID = $.cookie("USERID");
	if(USERID){
		jQuery("#USERID").val(USERID);
	}
	var PASSWD = $.cookie("PASSWD");
	if(PASSWD){
		jQuery("#PASSWD").val(PASSWD);
	}

	$("body").show();
});

function login(){
	if(validate.check("searchArea")){
		var param = dataBind.paramData("searchArea");
		param.put("LOGINPAGE", "/ahcs/index.page");
		param.put("LANGKY", "KO");
		var json = netUtil.sendData({
			url : "/ahcs/json/login.data",
			param : param
		});
		
		if(json && json.data){
			if(json.data == "F"){
				commonUtil.msg("아이디 또는 비밀번호가 일치 하지 않습니다.");  //LOGIN_M0001
			}else{
				for(var prop in param.map){
					$.cookie(prop, param.get(prop),{
					     "expires" : 365
					});
				}
				//this.location.href = "/common/main.page";
				this.location.href = "/ahcs/template.page";
			}
		}
	}
}
</script>
</head>
<body>
<!-- 탑 시작 -->
<div id="top_layout">
	<div class="top_wrap">
    	<div class="logo_wrap">
        	<h1><img src="/common/theme/ahcs/images/inc/logo.gif" alt="Allen Care" /></h1>
            <p>Healthcare Integrated System</p>
        </div>
        <div class="util_wrap">
            <div class="drop_lang drop_select">
                <div><a href="#">Korean</a></div>
                <ul>
                    <li><a href="#">Korean1</a></li>
                    <li><a href="#">Korean2</a></li>
                    <li><a href="#">Korean3</a></li>
                </ul>
            </div>
        </div>
    </div>
</div>
<!-- 탑 끝 -->
<!-- 비쥬얼 시작 -->
<div id="visual_layout">
	<div class="visual_wrap">
    	<img src="/common/theme/ahcs/images/login/login_visual_img.jpg" alt="비쥬얼 이미지" />
    </div>
</div>
<!-- 비쥬얼 끝 -->
<!-- 컨텐츠 시작 -->
<div id="contents_layout">
	<div class="contents_wrap" id="searchArea">
    	<!-- tab 시작 -->
    	<div class="tab_wrap">
        	<!-- tab_con1 시작 -->
        	<div class="tab_con n1 on">
            	<div class="btn">
                	<a href="#">공지사항</a>
				</div>
                <div class="contents">
                	<ul class="notice_txt">
                    	<li><a href="#">공지사항 2015년 건강보험료 연말정산분이 포함되어 있습니다.</a><span>2016-05-01</span></li>
                    	<li><a href="#">5월 교육신청자분들은 교육 준비 꼭 부탁 드립니다.</a><span>2016-05-01</span></li>
                    	<li><a href="#">16년 1분기 EOQ 시상 및 신규 입사자  본사교육이 있습니다.</a><span>2016-05-01</span></li>
                    	<li><a href="#">회사 보안 강화를 위한 외부인 출입 통제 관리 교육이 있습니다.</a><span>2016-05-01</span></li>
                    </ul>
                </div>
                <div class="more">
                	<a href="#">MORE +</a>
                </div>
            </div>
        	<!-- tab_con1 끝 -->
        	<!-- tab_con2 시작 -->
        	<div class="tab_con n2">
            	<div class="btn">
                	<a href="#">자료실</a>
				</div>
                <div class="contents">
                	<ul class="notice_txt">
                    	<li><a href="#">자료실 2015년 건강보험료 연말정산분이 포함되어 있습니다.</a><span>2016-05-01</span></li>
                    	<li><a href="#">5월 교육신청자분들은 교육 준비 꼭 부탁 드립니다.</a><span>2016-05-01</span></li>
                    	<li><a href="#">16년 1분기 EOQ 시상 및 신규 입사자  본사교육이 있습니다.</a><span>2016-05-01</span></li>
                    	<li><a href="#">회사 보안 강화를 위한 외부인 출입 통제 관리 교육이 있습니다.</a><span>2016-05-01</span></li>
                    </ul>
                </div>
                <div class="more">
                	<a href="#">MORE +</a>
                </div>
            </div>
        	<!-- tab_con2 끝 -->
        </div>
    	<!-- tab 끝 -->
        <div class="login_wrap">
        	<div class="title">
            	<span>Healthcare Integrated System</span>헬스케어 <strong>통합시스템</strong>
            </div>
            <ul class="idpw">
            	<li class="id">
                	<label for="USERID">아이디</label>
                	<input id="USERID" name="USERID" type="text">
                </li>
            	<li class="pw">
                	<label for="PASSWD">비밀번호</label>
                	<input id="PASSWD" name="PASSWD" type="password">
                </li>
            </ul>
            <div class="option">
            	<span class="check_wrap">
                	<input id="USERIDCHECK" name=""USERIDCHECK type="checkbox" value="">
                    <label for="USERIDCHECK">아이디 저장</label>
                </span>
                <span class="f_r">
                	<a href="#">아이디 찾기</a> | <a href="#">비밀번호 찾기</a>
                </span>
            </div>
            <div class="btn">
            	<a href="#" onclick="login()">Login</a>
            </div>
            <ul class="txt_list">
            	<li>담당자 외 불법으로 사용시 법적 제재를 받을 수 있습니다.</li>
            	<li>비밀번호 분실 시 관리자에게 문의바랍니다.</li>
            	<li>문의전화 : Tel. 02-0000-0000</li>
            </ul>
        </div>
    </div>
</div>
<!-- 컨텐츠 끝 -->
<!-- 푸터 시작 -->
<div id="foot_layout">
	<div class="foot_wrap">
    	Copyright © 2016 Allen Care Co., Ltd All rights reserved. webmaster@allencare.co.kr
    </div>
</div>
<!-- 푸터 끝 -->
</body>
</html>