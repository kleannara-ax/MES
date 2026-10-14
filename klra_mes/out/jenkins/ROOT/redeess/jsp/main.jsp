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
	window.onload = function(){
		var bg = new Array();
		bg[bg.length] = "/redeess/images/60.jpg";
		bg[bg.length] = "/redeess/images/222.jpg";
		bg[bg.length] = "/redeess/images/269.jpg";
		bg[bg.length] = "/redeess/images/3375.jpg"; 
		bg[bg.length] = "/redeess/images/8478.jpg";
		 /*bg[bg.length] = "/redeess/images/717.jpg";
		bg[bg.length] = "/redeess/images/268.jpg";
		bg[bg.length] = "/redeess/images/736.jpg";
		bg[bg.length] = "/redeess/images/715.jpg";
		bg[bg.length] = "/redeess/images/922.jpg";*/
		var obj = document.getElementById('backGround');
		var temp;
		setTimeout(function(){
		    do {
		        var size = Math.floor(Math.random()*(bg.length));
		    } while(size == temp);
		    temp = size;
		    obj.style.backgroundImage = 'url('+ bg[size] + ')';
		    setTimeout(arguments.callee, 10000);
		}, 0);
	}
</script>
</head>
<body >
<div class="section">
	<div class="carousel">
		<div id="backGround" class="carousel-item"><div><h1>Beyond#1 in Korea,<br />Toward Global Top3 Solution Provider</h1><p>래디스는 대한민국 SCM 분야 1등을 뛰어넘어,<br /> Global Top3 Solution Provider</p></div></div>
		<div class="carousel-item"><div><h1>Beyond#1 in Korea,<br /> Toward Global Top3 Solution Provider</h1><p>래디스는 대한민국 SCM 분야 1등을 뛰어넘어,<br /> Global Top3 Solution Provider</p></div></div>
		<%@ include file="/redeess/include/top.jsp" %>
	</div>
	<div class="room-block"></div>
	<div class="wrapper block">
		<h1>Solutions & Services</h1>
		<p>래디스는 컨설팅, 맞춤형 솔루션 구축, 클라우드 서비스, 글로벌 웹 표준 플랫폼 SW/컴포넌트 사업에 이르는 Total 솔루션 제공을 통해 차별화된 가치를 제공합니다.</p>
		<div>
			<span></span>
			<ul>
				<li>컨설팅</li>
				<li>IT 정보 전략 및 ISP 컨설팅</li>
				<li>SCM 프로세스 컨설팅</li>
				<li>기준정보 관리/표준체계 컨설팅</li>
			</ul>
		</div>
		<div>
			<span></span>
			<ul>
				<li>맞춤형 솔루션 구축</li>
				<li>구매 SCM 솔루션</li>
				<li>품질 관리 솔루션</li>
				<li>마스터 데이터 관리 솔루션</li>
			</ul>
		</div>
		<div>
			<span></span>
			<ul>
				<li>클라우드 서비스</li>
				<li>간접구매 글로벌</li>
				<li>검증된 Catalog</li>
				<li>기준정보 관리/표준체계 컨설팅</li>
			</ul>
		</div>
		<div>
			<span></span>
			<ul>
				<li>플랫폼SW/Cpmponent</li>
				<li>글로벌 웹 표준 개발 플랫폼</li>
				<li>그리드 컴포넌트, 차트 컴포넌트</li>
				<li>리포트 컴포넌트</li>
			</ul>
		</div>
	</div>
	<div class="room-block"></div>
	<div class="bg-fiexd">
		<input type="radio" id="news1" name="news" checked />
		<input type="radio" id="news2" name="news" />
		<input type="radio" id="news3" name="news" />
		<div class="news-inner">
			<div  class="news-wrap">
				<div class="news-text">
					<h3>래디스 4년 연속 매출성장 . . . 하이마트등 20개 고객사 확보</h3>
					<p>래디스가 기업의 물류 업무를 지원하는 솔루션 사업을 앞세워 4년 연속 성장을 이어가고 있다. 향후 운영 비용을 최소화한 클라우드 기반 물류지원 솔류션 등 신사업을 앞세워 수익성 개선에 총력을 기울인다는 방침이다. 25일 관련업계에 따르면 지난해 래디스의 매출액은 20억원으로 전년 대비 5.7%증가했다.</p>
					<!-- <a href="">기사 전문보기</a> -->
				</div>
				<div class="news-text">
					<h3>래디스 4년 연속 매출성장 . . .</h3>
					<p>래디스가 기업의 물류 업무를 지원하는 솔루션 사업을 앞세워 4년 연속 성장을 이어가고 있다. 향후 운영 비용을 최소화한 클라우드 기반 물류지원 솔류션 등 신사업을 앞세워 수익성 개선에 총력을 기울인다는 방침이다. 25일 관련업계에 따르면 지난해 래디스의 매축액은 287억원으로 전년 대비 5.7%증가했다.</p>
					<!-- <a href="">기사 전문보기</a> -->
				</div>
				<div class="news-text">
					<h3>삼성등 130개 고객사 확보</h3>
					<p>래디스가 기업의 물류 업무를 지원하는 솔루션 사업을 앞세워 4년 연속 성장을 이어가고 있다. 향후 운영 비용을 최소화한 클라우드 기반 물류지원 솔류션 등 신사업을 앞세워 수익성 개선에 총력을 기울인다는 방침이다. 25일 관련업계에 따르면 지난해 래디스의 매축액은 287억원으로 전년 대비 5.7%증가했다.</p>
					<!-- <a href="">기사 전문보기</a> -->
				</div>
			</div>
		</div>
	</div>
	<div class="room-block"></div>
	<div class="wrapper block two-block">
		<h1>주요 기술</h1>
		<p>급변하는 IT 환경에 빠른 대응을 위한 새로운 기술의 빠른 실현</p>
		<div>
			<span></span>
			<ul>
				<li>Big Data & AI 기반 Analysis</li>
				<li>강력한 데이터 연관성 분석</li>
				<li>R 및 Python 연계를 통한 고급 예측/통계 분석</li>
			</ul>
		</div>
		<div>
			<span></span>
			<ul>
				<li>RPA 기반 Automation</li>
				<li>업무 자동화 스크립트 관리</li>
				<li>업무 실행 로봇 제어 및 실시간 모니터링</li>
			</ul>
		</div>
		<div>
			<span></span>
			<ul>
				<li>Blockchain 기반 인증 및 보안</li>
				<li>로그인 인증 보안/권한 관리</li>
				<li>투찰/개찰 금액 암호화</li>
				<li>계약문서 검증 및 진위 확인</li>
			</ul>
		</div>
		<div>
			<span></span>
			<ul>
				<li>웹 표준 플랫폼</li>
				<li>Portal/그리드 개인화, MDI 사용환경 제공</li>
				<li>업무 표준 공통 기능 관리</li>
				<li>다양한 UI 편의 기능 제공</li>
			</ul>
		</div>
		<div>
			<span></span>
			<ul>
				<li>웹 표준 컴포넌트</li>
				<li>웹 표준 고성능 데이터 그리드</li>
				<li>다양한 상용 차트 제공</li>
				<li>데이터 그룹핑 및 통계</li>
			</ul>
		</div>
	</div>
	<div class="room-block"></div>
	<div class="bg-fiexd">
		<div class="smart">
			<h1>SCM혁신 솔루션, SMARTSUITE</h1>
			<p>SMARTSUITE는 Value Chain 전체의 업무 최적화를 도모할 수 있는 통합 솔루션입니다. SMARTSUITE 솔루션이 보유한 Basic, Advanced, Trade 3가지 영역의 선택적 적용을 통해 조달, 전략, 개발, 협업 등 전 Value Chain 최적화를 도모할 수 있으며 Value Chain 전 영역을 아우르고 있습니다</p>
			<!-- <a href="">자세히 보기</a> -->
		</div>
	</div>
	<div class="room-block"></div>
	<div class="wrapper block three-block">
		<h1>Customers</h1>
		<p>래디스는 전략적 파트너십을 바탕으로 다양한 산업 분야에서 국내·외 주요 선도 기업을 고객군으로 보유하고 있습니다.</p>
		<ul>
			<li><a href="/redeess/html/customers.html">Reference<span>2020년</span></a></li>
			<li><a href="/redeess/html/customers.html">Reference<span>2019년</span></a></li>
			<li><a href="/redeess/html/customers.html">Reference<span>2018년</span></a></li>
			<li><a href="/redeess/html/customers.html">Reference<span>2017년</span></a></li>
			<li><a href="/redeess/html/customers.html">Reference<span>2016년</span></a></li>
			<li><a href="/redeess/html/customers.html">Reference<span>2015년</span></a></li>
			<li><a href="/redeess/html/customers.html">Reference<span>2013년</span></a></li>
		</ul>
		<!-- <img src="/redeess/images/partner01.jpg" alt="partner01.jpg" />
		<img src="/redeess/images/partner02.jpg" alt="partner02.jpg" />
		<img src="/redeess/images/partner03.jpg" alt="partner03.jpg" />
		<img src="/redeess/images/partner04.jpg" alt="partner04.jpg" />
		<img src="/redeess/images/partner05.jpg" alt="partner05.jpg" /> -->
	</div>
	<div class="room-block"></div>
	<%@ include file="/redeess/include/bottom.jsp" %>
</div>
</body>
</html>