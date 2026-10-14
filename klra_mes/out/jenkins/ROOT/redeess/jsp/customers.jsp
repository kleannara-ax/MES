<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta charset="utf-8" name="viewport" content="width=device-width, initial-scale=1.0" , minmum-scale=1.0, user-scalable=no />
<title>redeess</title>
<%@ include file="/redeess/include/head.jsp" %>
<script>
	$(document).ready(function() {
	    $(".ul-clicktab li").click(function(){
	      var i = $(this).index();
	      $(".tab-block").removeClass("on");
	      $(".tab-block").eq(i).addClass("on");
	      $(".ul-clicktab li").removeClass("on");
	      $(this).eq(i).addClass("on");
	      $(".ul-clicktab li a").removeClass("on");
	      $(this).addClass("on");
	    });
	  });
</script>
</head>
<body>

<div class="section">
	<%@ include file="/redeess/include/top.jsp" %>
	<div class="header-text">
		<h1>Customers</h1>
	</div>
	<div class="room-block02"></div>
	<div class="wrapper">
		<div class="tab">
			<p>래디스는 전략적 파트너십을 바탕으로 다양한 산업 분야에서 국내·외 주요 선도 기업을 고객군으로 보유하고 있습니다.</p>
			<ul class="ul-clicktab">
				<!-- <li><a href="#ul01">2022</a></li> -->
				<li class="on"><a href="#ul02">2021</a></li>
				<li><a href="#ul03">2020</a></li>
				<li><a href="#ul04">2019</a></li>
				<li><a href="#ul05">2018</a></li>
				<li><a href="#ul06">2017</a></li>
				<li><a href="#ul07">2016</a></li>
				<li><a href="#ul08">2015</a></li>
				<li><a href="#ul09">2013</a></li>
			</ul>
			<!-- <div class="tab-block tab-block01  coutomers-color">
				<h3 id="ul01">2022</h3>
				<p><span></span></p>
				<div class="inquiry">
					<p>솔루션&컨설팅 상담 문의</p>
					<span>영업담당자</span>
					<span><a href="">support@redeess.com</a></span>
					<span>02-6463-6462</span>
				</div>
			</div> -->
			<div class="tab-block tab-block02 on coutomers-color">
				<h3 id="ul02">2021</h3>
				<p><span></span></p>
				<div class="inquiry">
					<p>솔루션&컨설팅 상담 문의</p>
					<span>영업담당자</span>
					<span><a href="">support@redeess.com</a></span>
					<span>02-6463-6462</span>
				</div>
			</div>
			<div class="tab-block tab-block03 coutomers-color">
				<h3 id="ul03">2020</h3>
				<p><span>2020.05 ~ 2020.06</span>알콘 물류 서비스</p>
				<p><span>2020.05 ~ 2021.04</span>아이쿱생협 WMS 구축 프로젝트</p>
				<p><span>2020.02 ~ 2020.07</span>중원 WMS 구축</p>
				<p><span>2020.01 ~ 2020.02</span>CJFreshway 물류 서비스</p>
				<div class="inquiry">
					<p>솔루션&컨설팅 상담 문의</p>
					<span>영업담당자</span>
					<span><a href="">support@redeess.com</a></span>
					<span>02-6463-6462</span>
				</div>
			</div>
			<div class="tab-block tab-block04 coutomers-color">
				<h3 id="ul04">2019</h3>
				<p><span>2019.11 ~ 2019.12</span>하이마트 물류 서비스</p>
				<p><span>2019.11 ~ 2020.08</span>GCLC(㈜녹십자랩셀) & GCCL(㈜지씨씨엘) 운영시스템 구축</p>
				<p><span>2019.11 ~ 2020.04</span>평화드림 WMS 구축</p>
				<p><span>2019.08 ~ 2020.02</span>안연케어 WMS 구축</p>
				<p><span>2019.07 ~ 2019.11</span>LG화학 WMS 구축</p>
				<p><span>2019.02 ~ 2019.07</span>대림바스 WMS 구축</p>
				<p><span>2019.01 ~ 2019.10</span>엘지하우시스 미국법인 표면소재 GWMS 2단계_RDC</p>
				<div class="inquiry">
					<p>솔루션&컨설팅 상담 문의</p>
					<span>영업담당자</span>
					<span><a href="">support@redeess.com</a></span>
					<span>02-6463-6462</span>
				</div>
			</div>
			<div class="tab-block tab-block05 coutomers-color">
				<h3 id="ul05">2018</h3>
				<p><span>2018.11 ~ 2020.02</span>신세계센트럴시티 고속버스 소화물 시스템</p>
				<p><span>2018.10 ~ 2019.10</span>한화스마트 물류정보시스템 구축</p>
				<p><span>2018.08 ~ 2019.04</span>카버코리아 WMS 구축</p>
				<p><span>2018.08 ~ 2019.02</span>아이마켓코리아 WMS 업그레이드</p>
				<p><span>2018.06 ~ 2019.03</span>신세계인터내셔널 물류 WMS 구축</p>
				<p><span>2018.03 ~ 2018.08</span>상신브레이크 WMS 재구축</p>
				<p><span>2018.02 ~ 2018.12</span>LG하우시스 WMS 시스템</p>
				<p><span>2018.02 ~ 2018.08</span>상신브레이크 시스템</p>
				<p><span>2018.01 ~ 2018.12</span>LG생활건강 WMS 시스템 유지보수</p>
				<p><span>2018.01 ~ 2018.12</span>LG하우시스 WMS 시스템 유지보수</p>
				<p><span>2018.01 ~ 2018.12</span>엠프론티어 WMS 시스템 유지보수</p>
				<div class="inquiry">
					<p>솔루션&컨설팅 상담 문의</p>
					<span>영업담당자</span>
					<span><a href="">support@redeess.com</a></span>
					<span>02-6463-6462</span>
				</div>
			</div>
			<div class="tab-block tab-block06 coutomers-color">
				<h3 id="ul06">2017</h3>
				<p><span>2017.12 ~ 2018.03</span>삼성메디슨 시장품질 시스템</p>
				<p><span>2017.11 ~ 2018.03</span>클리오 WMS 시스템</p>
				<p><span>2017.09 ~ 2018.03</span>LG화학 WMS 시스템</p>
				<p><span>2017.08 ~ 2018.02</span>사조시스템즈 WMS 시스템</p>
				<p><span>2017.05 ~ 2017.06</span>현대모비스 WOS 시스템</p>
				<p><span>2017.05 ~ 2018.03</span>삼양사 WMS 시스템</p>
				<p><span>2017.04 ~ 2017.11</span>영원무역 WMS 시스템</p>
				<p><span>2017.03 ~ 2017.12</span>동원산업 SCM 시스템</p>
				<p><span>2017.03 ~ 2017.04</span>LS전선 TMS 시스템</p>
				<p><span>2017.02 ~ 2017.04</span>카버코리아 DPS 시스템</p>
				<p><span>2017.02 ~ 2017.08</span>LG생활건강 WMS 시스템</p>
				<p><span>2017.02 ~ 2017.12</span>이베이 WMS 시스템</p>
				<p><span>2017.02 ~ 2017.09</span>롯데인도네시아 WMS 시스템</p>
				<p><span>2017.02 ~ 2017.08</span>코카콜라 WMS 시스템</p>
				<p><span>2017.01 ~ 2017.03</span>엠프론티어 적재최적화 시스템</p>
				<p><span>2017.01 ~ 2017.12</span>LG하우시스 WMS 시스템 유지보수</p>
				<p><span>2017.01 ~ 2017.12</span>엠프론티어 WMS 시스템 유지보수</p>
				<p><span>2017.01 ~ 2017.12</span>한국타이어 WMS 시스템 유지보수</p>
				<div class="inquiry">
					<p>솔루션&컨설팅 상담 문의</p>
					<span>영업담당자</span>
					<span><a href="">support@redeess.com</a></span>
					<span>02-6463-6462</span>
				</div>
			</div>
			<div class="tab-block tab-block07 coutomers-color">
				<h3 id="ul07">2016</h3>
				<p><span>2016.12 ~ 2017.07</span>빙그레 WMS 시스템</p>
				<p><span>2016.12 ~ 2017.05</span>LG하우시스 WMS 시스템 확산</p>
				<p><span>2016.10 ~ 2017.02</span>LG화학 WMS 시스템 확산</p>
				<p><span>2016.10 ~ 2017.02</span>카버코리아 WMS 시스템</p>
				<p><span>2016.10 ~ 2017.03</span>배민프레시 WMS 시스템</p>
				<p><span>2016.09 ~ 2017.01</span>LG생활건강 WMS 시스템</p>
				<p><span>2016.08 ~ 2016.11</span>이베이 적제최적화 시스템</p>
				<p><span>2016.07 ~ 2017.01</span>이베이 WMS 시스템</p>
				<p><span>2016.07 ~ 2016.11</span>현대모비스 WOS 시스템</p>
				<p><span>2016.07 ~ 2017.01</span>안영케어 내부 시스템 WEBDeK 적용 프로젝트</p>
				<p><span>2016.06 ~ 2017.06</span>안영케어 WMS 시스템</p>
				<p><span>2016.05 ~ 2016.08</span>IMV WMS 시스템</p>
				<p><span>2016.04 ~ 2016.06</span>GS리테일 WMS 시스템 개선</p>
				<p><span>2016.04 ~ 2016.10</span>슈피겐코리아 생산관리 시스템</p>
				<p><span>2016.02 ~ 2016.06</span>현대캐피탈 WEBDeK 납품</p>
				<p><span>2016.02 ~ 2016.06</span>LG화학 WMS 시스템 확산</p>
				<p><span>2016.01 ~ 2016.04</span>SD WMS 시스템</p>
				<p><span>2016.01 ~ 2016.10</span>보령메디앙스 WMS 시스템</p>
				<p><span>2016.01 ~ 2016.07</span>LS전선 TMS 시스템</p>
				<p><span>2016.01 ~ 2016.03</span>슈피겐코리아 WMS 시스템</p>
				<div class="inquiry">
					<p>솔루션&컨설팅 상담 문의</p>
					<span>영업담당자</span>
					<span><a href="">support@redeess.com</a></span>
					<span>02-6463-6462</span>
				</div>
			</div>
			<div class="tab-block tab-block08 coutomers-color">
				<h3 id="ul08">2015</h3>
				<p><span>2015.12 ~ 2016.03</span>중국 천진철강 WMS 시스템</p>
				<p><span>2015.12 ~ 2016.03</span>이마트 자동창고관리 시스템</p>
				<p><span>2015.12 ~ 2016.07</span>LG하우시스 WMS 시스템</p>
				<p><span>2015.11 ~ 2016.06</span>더파머스 통합물류 시스템</p>
				<p><span>2015.11 ~ 2016.04</span>현대 커머셜 WEBDeK 납품</p>
				<div class="inquiry">
					<p>솔루션&컨설팅 상담 문의</p>
					<span>영업담당자</span>
					<span><a href="">support@redeess.com</a></span>
					<span>02-6463-6462</span>
				</div>
			</div>
			<div class="tab-block tab-block09 coutomers-color">
				<h3 id="ul09">2013</h3>
				<p><span>2013.07 ~ 2014.02</span>아이마켓코리아물류통합시스템</p>
				<p><span>2013.05 ~ 2014.02</span>아워홈통합물류관리시스템</p>
				<div class="inquiry">
					<p>솔루션&컨설팅 상담 문의</p>
					<span>영업담당자</span>
					<span><a href="">support@redeess.com</a></span>
					<span>02-6463-6462</span>
				</div>
			</div>
		</div>
	</div>
	<div class="room-block"></div>
	<%@ include file="/redeess/include/bottom.jsp" %>
</div>
</body>
</html>