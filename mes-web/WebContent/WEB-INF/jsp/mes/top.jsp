<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.common.bean.DataMap,com.common.bean.CommonConfig"%>
<%
	String wareky = request.getSession().getAttribute(CommonConfig.SES_USER_WHAREHOUSE_KEY).toString();
	String userid = request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY).toString();
	String username = request.getSession().getAttribute(CommonConfig.SES_USER_NAME_KEY).toString();
	String compky = request.getSession().getAttribute(CommonConfig.SES_USER_COMPANY_KEY).toString();
%>
<!doctype html>
<html lang="ko">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta charset="utf-8">
<title></title>
<meta name="viewport" content="width=1150">
<link rel="stylesheet" type="text/css" href="/common/css/common.css">
<link rel="stylesheet" type="text/css" href="/common/css/top.css">
<script type="text/javascript" src="/common/js/jquery.js"></script>
<script type="text/javascript" src="/common/js/json2.js"></script>
<script type="text/javascript" src="/common/js/dataMap.js"></script>
<script type="text/javascript" src="/common/js/configData.js"></script>
<script type="text/javascript" src="/common/js/commonUtil.js"></script>
<script type="text/javascript" src="/common/js/dataBind.js"></script>
<script type="text/javascript" src="/common/js/input.js"></script>
<script type="text/javascript" src="/common/js/netUtil.js"></script>
<script type="text/javascript" src="/common/js/validateUtil.js"></script>
<script type="text/javascript" src="/common/js/ui.js"></script>
<script>
(function() {

	$(function() {

		var gnb = $('.gnb')
			, trigger = gnb.find('.list').children('li')
			, list = trigger.children('ul');

		trigger.each(function() {
			var _this = $(this)
				, thisTrigger = _this.children('a')
				, thisList = _this.children('ul');

			thisTrigger.on({
				click : function() {
					list.hide();
					thisList.show();

					trigger.removeClass('active');
					_this.addClass('active');
				}
			});
		});
	});

})();
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
	inputList.setCombo();
	$("select[name=WAREKY]").val("<%=wareky%>");
	
	uiList.UICheck();
});

function changeWareky(){
	var param = dataBind.paramData("searchArea");
	var json = netUtil.sendData({
		url : "/wms/common/json/changeWareky.data",
		param : param
	});
	
	if(json && json.data){
		
	}
	
	window.top.closeAll();
}

function logout(){
	location.href = "/common/json/logout.page";
}

function changePage(menuId){	
	window.top.menuPage(menuId);
}

function logoEffectStart(){

}

function logoEffectStop(){

}

</script>
</head>
<body>
<!-- header -->
<div class="header">
	<div class="innerContainer">
		<span class="logo">
			<a href="#" onClick="window.top.reloadPage()">
				<img src="/common/images/logo.png" alt="" />
			</a>
		</span>

		<div class="gnb">
			<ul class="list">
				<li>
					<a href="#">d</a>
					<ul>
						<!--<li><a href="#" onClick="changePage('ML01')" CL="MENU_ML01,3">ML01</a></li><!-- 지번 -->
						<!--<li><a href="#" onClick="changePage('BZ01')" CL="MENU_BZ01,3">BZ01</a></li><!-- 파트너 -->
						<!--<li><a href="#" onClick="changePage('SK01')" CL="MENU_SK01,3">SK01</a></li><!-- SKU -->
						<!--<li><a href="#" onClick="changePage('SM01')" CL="MENU_SM01,3">SM01</a></li><!-- 단위구성 -->
						<!--<li><a href="#" onClick="changePage('TP01')" CL="MENU_TP01,3">TP01</a></li><!-- 적치전략 -->
						<!--<li><a href="#" onClick="changePage('TA01')" CL="MENU_TA01,3">TA01</a></li><!-- 할당전략 -->
						<!--<li><a href="#" onClick="changePage('TR01')" CL="MENU_TR01,3">TR01</a></li><!-- 전략연결 -->
						<li><a href="#" onClick="changePage('ML01')" CL="STD_LOCAKY">ML01</a></li><!-- 지번 -->
						<li><a href="#" onClick="changePage('BZ01')" CL="MENU_MST_PTNR,3">BZ01</a></li><!-- 파트너 -->
						<li><a href="#" onClick="changePage('SK01')" CL="__MENU_SKUMOD,3">SK01</a></li><!-- SKU -->
						<li><a href="#" onClick="changePage('SM01')" CL="STD_MEASKY">SM01</a></li><!-- 단위구성 -->
						<li><a href="#" onClick="changePage('TP01')" CL="BTN_PUTSTRATEGY">TP01</a></li><!-- 적치전략 -->
						<li><a href="#" onClick="changePage('TA01')" CL="MENU_TA01,3">TA01</a></li><!-- 할당전략 -->
						<li><a href="#" onClick="changePage('TR01')" CL="MENU_TR01,3">TR01</a></li><!-- 전략연결 -->
					</ul>
				</li>
				<li>
					<a href="#">d</a>
					<ul>
						<!--<li><a href="#" onClick="changePage('TM06')" CL="MENU_TM06,3">TM06</a></li><!-- 공급사 발주 -->
						<!--<li><a href="#" onClick="changePage('AS01')" CL="MENU_AS01,3">AS01</a></li><!-- 입하예정 정보 입력 -->
						<!--<li><a href="#" onClick="changePage('GR00')" CL="MENU_GR00,3">GR00</a></li><!-- 생산 입하 -->
						<!--<li><a href="#" onClick="changePage('GR01')" CL="MENU_GR01,3">GR01</a></li><!-- ASN 입하 -->
						<!--<li><a href="#" onClick="changePage('GR02')" CL="MENU_GR02,3">GR02</a></li><!-- 구매 입하 -->
						<!--<li><a href="#" onClick="changePage('GR06')" CL="MENU_GR06,3">GR06</a></li><!-- 출고반품 입하 -->
						<!--<li><a href="#" onClick="changePage('GR15')" CL="MENU_GR15,3">GR15</a></li><!-- 창간이동 입하 -->
						<!--<li><a href="#" onClick="changePage('PT01')" CL="MENU_PT01,3">PT01</a></li><!-- 적치 -->
						<li><a href="#" onClick="changePage('TM06')" CL="MENU_TM06,3">TM06</a></li><!-- 공급사 발주 -->
						<li><a href="#" onClick="changePage('AS01')" CL="MENU_AS01,3">AS01</a></li><!-- 입하예정 정보 입력 -->
						<li><a href="#" onClick="changePage('GR01')" CL="HHTSTD_WSH1E1TITLE,3">GR01</a></li><!-- ASN 입하 -->
						<li><a href="#" onClick="changePage('GR02')" CL="HHTSTD_WSH100M1SUB2,3">GR02</a></li><!-- 구매 입하 -->
						<li><a href="#" onClick="changePage('GR06')" CL="MENU_GR06,3">GR06</a></li><!-- 출고반품 입하 -->
						<li><a href="#" onClick="changePage('GR15')" CL="MENU_GR15,3">GR15</a></li><!-- 창간이동 입하 -->
						<li><a href="#" onClick="changePage('PT01')" CL="HHTSTD_WZTSB5TITLE,3">PT01</a></li><!-- 적치 -->
					</ul>
				</li>
				<li>
					<a href="#">d</a>
					<ul>
						<!--<li><a href="#" onClick="changePage('TM05')" CL="MENU_TM05,3">TM05</a></li><!-- 거래처 오더 -->
						<!--<li><a href="#" onClick="changePage('TM04')" CL="MENU_TM04,3">TM04</a></li><!-- 오더 조회/삭제 -->
						<!--<li><a href="#" onClick="changePage('DL01')" CL="MENU_DL01,3">DL01</a></li><!-- 고객오더 할당 -->
						<!--<li><a href="#" onClick="changePage('DL03')" CL="MENU_DL03,3">DL03</a></li><!-- 창간오더 할당 -->
						<!--<li><a href="#" onClick="changePage('DL04')" CL="MENU_DL06,3">DL04</a></li><!-- 피킹 완료 -->
						<!--<li><a href="#" onClick="changePage('DL06')" CL="MENU_DL04,3">DL06</a></li><!-- 오더할당 관리 -->
						<!--<li><a href="#" onClick="changePage('DL08')" CL="MENU_DL08,3">DL08</a></li><!-- 출하 처리 -->
						<li><a href="#" onClick="changePage('TM05')" CL="MENU_TM05,3">TM05</a></li><!-- 거래처 오더 -->
						<li><a href="#" onClick="changePage('TM04')" CL="MENU_TM04,3">TM04</a></li><!-- 오더 조회/삭제 -->
						<li><a href="#" onClick="changePage('DL01')" CL="MENU_DL01,3">DL01</a></li><!-- 고객오더 할당 -->
						<li><a href="#" onClick="changePage('DL03')" CL="MENU_DL03,3">DL03</a></li><!-- 창간오더 할당 -->
						<li><a href="#" onClick="changePage('DL04')" CL="STD_PICKYN">DL04</a></li><!-- 피킹 완료 -->
						<li><a href="#" onClick="changePage('DL06')" CL="MENU_DL04,3">DL06</a></li><!-- 오더할당 관리 -->
						<li><a href="#" onClick="changePage('DL08')" CL="MENU_DL08,3">DL08</a></li><!-- 출하 처리 -->
					
					</ul>
				</li>
				<li>
					<a href="#">d</a>
					<ul>
						<!--<li><a href="#" onClick="changePage('SD01')" CL="MENU_SD01,3">SD01</a></li><!-- 재고 현황 -->
						<!--<li><a href="#" onClick="changePage('SD02')" CL="MENU_SD02,3">SD02</a></li><!-- 문서별재고 추적 -->
						<!--<li><a href="#" onClick="changePage('SJ04')" CL="MENU_SJ04,3">SJ04</a></li><!-- 속성변경 -->
						<!--<li><a href="#" onClick="changePage('SJ05')" CL="MENU_SJ05,3">SJ05</a></li><!-- 검사 합격/불합격 -->
						<!--<li><a href="#" onClick="changePage('IP01')" CL="MENU_IP01,3">IP01</a></li><!-- 재고실사지시 -->
						<!--<li><a href="#" onClick="changePage('IP02')" CL="MENU_IP02,3">IP02</a></li><!-- 재고실사 -->
						<li><a href="#" onClick="changePage('SD01')" CL="MENU_SD01,3">SD01</a></li><!-- 재고 현황 -->
						<li><a href="#" onClick="changePage('SD02')" CL="MENU_SD02,3">SD02</a></li><!-- 문서별재고 추적 -->
						<li><a href="#" onClick="changePage('SJ04')" CL="__MENU_PRPMOD,3">SJ04</a></li><!-- 속성변경 -->
						<li><a href="#" onClick="changePage('SJ05')" CL="MENU_SJ05,3">SJ05</a></li><!-- 검사 합격/불합격 -->
						<li><a href="#" onClick="changePage('IP01')" CL="MENU_IP01,3">IP01</a></li><!-- 재고실사지시 -->
						<li><a href="#" onClick="changePage('IP02')" CL="MENU_INV_PHYD,3">IP02</a></li><!-- 재고실사 -->
					</ul>
				</li>
				<li>
					<a href="#">d</a>
					<ul>
						<!--<li><a href="#" onClick="changePage('RL01')" CL="MENU_RL01,3">RL01</a></li><!-- 입하실적 집계표 -->
						<!--<li><a href="#" onClick="changePage('RL02')" CL="MENU_RL02,3">RL02</a></li><!-- 출하실적 집계표 -->
						<li><a href="#" onClick="changePage('RL01')" CL="MENU_RL01,3">RL01</a></li><!-- 입하실적 집계표 -->
						<li><a href="#" onClick="changePage('RL02')" CL="MENU_RL02,3">RL02</a></li><!-- 출하실적 집계표 -->
					</ul>
				</li>
			</ul>
		</div>	
	</div>
</div>
<!-- //header -->
</body>
</html>