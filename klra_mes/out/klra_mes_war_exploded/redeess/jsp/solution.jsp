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
		<h1>Innovation with Your Procurement, WEBDeK SCM</h1>
	</div>
	<div class="room-block02"></div>
	<div class="wrapper">
		<div class="tab">
			<h2><img src="/redeess/images/webdek.png" alt="webdek" /></h2>
			<p>WEBDeK SCM는 SCM Value Chain 전체의 업무 최적화를 도모할 수 있는 통합 솔루션입니다.</p>
			<ul class="ul-clicktab">
				<li class="on"><a href="#ul01">IT outsourcing</a></li>
				<li><a href="#ul02">Mentor</a></li>
				<li><a href="#ul03">Partners</a></li>
				<li><a href="#ul04">Technolgy</a></li>
			</ul>
			<div class="tab-block tab-block01 on">
				<h3 id="ul01">IT outsourcing</h3>
				<span>제품 개발 단계의 선행 소싱 및 TCO 관점의 전략 소싱 지원을 통해 최적의 소싱 및 원가 절감을 실현합니다.</span>
				<p>제품 개발 단계부터 개발, 물류 및 유관 조직과의 유기적인 정보 공유와 협업을 지원합니다. 개발 단계의 업체 소싱, EPI1), ESI2), 목표 원가 관리 등을 통해 고객 가치 차별화 및 개발 비용 절감이 가능합니다. 카테고리 별 차별화된 소싱전략 실행 및 프로세스를 지원하고, 상세 Pricing Factor 설정 및 견적 상세화를 통한 TCO 관점의 전략 소싱을 실현합니다.
					<br/><span>※ EPI: Early Procurement Involvement ｜ ESI: Early Supplier Involvement</span>
				</p>
				<ul class="solution-item">
					<li>
						<p><span>WEB</span><span>DeK</span> <span>SI</span></p>
						<ul>
							<li>효율적인 프로젝트 수행을 위한 SI 아웃소싱 서비스</li>
						</ul>
					</li>
					<li>
						<p><span>WEB</span><span>DeK</span> <span>Cunsulting</span></p>
						<ul>
							<li>IT 프로젝트의 성곡적인 수행을 위한 컨설팅 서비스</li>
						</ul>
					</li>
					<li>
						<p><span>WEB</span><span>DeK</span> <span>Framework</span></p>
						<ul>
							<li>생산성 및 효율성이 보상된 자체 개발 프레임 워크</li>
						</ul>
					</li>
				</ul>
				<ul class="solution-item">
					<li>
						<p><span>WEB</span><span>DeK</span> <span>Portal</span></p>
						<ul>
							<li>User Experience를 고려한 최강의 Protal 솔루션</li>
						</ul>
					</li>
					<li>
						<p><span>WEB</span><span>DeK</span> <span>SM</span></p>
						<ul>
							<li>효율적인 프로젝트 수행을 위한 SI 아웃소싱 서비스</li>
						</ul>
					</li>
					<li>
						<p><span>WEB</span><span>DeK</span> <span>CMS</span></p>
						<ul>
							<li>서비스의 콘텐츠를 효율적으로 관리할 수 있는 CMS 솔루션</li>
						</ul>
					</li>
				</ul>
				<div class="inquiry">
					<p>솔루션&컨설팅 상담 문의</p>
					<span>영업담당자</span>
					<span><a href="">support@redeess.com</a></span>
					<span>02-6463-6462</span>
				</div>
			</div>
			<div class="tab-block tab-block02">
				<h3 id="ul02"> Mentor</h3>
				<ul class="solution-item Mentor-img">
					<li>
						<span>다양한 분야의 Mentor 지원</span>
						<img src="/redeess/images/img02.jpg" alt="img02" />
					</li>
					<li>
						<span>Speciallist</span>
						<img src="/redeess/images/img03.jpg" alt="img03" />
					</li>
					<li>
						<span>Mentor로 활동</span>
						<img src="/redeess/images/img04.jpg" alt="img04" />
					</li>
				</ul>
				<div class="inquiry">
					<p>솔루션&컨설팅 상담 문의</p>
					<span>영업담당자</span>
					<span><a href="">support@redeess.com</a></span>
					<span>02-6463-6462</span>
				</div>
			</div>
			<div class="tab-block tab-block03">
				<h3 id="ul03">Partners</h3>
				<ul class="solution-item">
					<li>
						<img src="/redeess/images/partner01.jpg" alt="partner01" />
					</li>
					<li>
						<img src="/redeess/images/partner02.jpg" alt="partner02" />
					</li>
					<li>
						<img src="/redeess/images/partner03.jpg" alt="partner03" />
					</li>
				</ul>
				<ul class="solution-item">
					<li>
						<img src="/redeess/images/partner04.jpg" alt="partner04" />
					</li>
					<li>
						<img src="/redeess/images/partner05.jpg" alt="partner05" />
					</li>
					<li>
						<img src="/redeess/images/partner06.jpg" alt="partner06" />
					</li>
				</ul>
				<ul class="solution-item">
					<li>
						<img src="/redeess/images/partner07.jpg" alt="partner07" />
					</li>
					<li>
						<img src="/redeess/images/partner08.jpg" alt="partner08" />
					</li>
					<li>
						<img src="/redeess/images/partner09.jpg" alt="partner09" />
					</li>
				</ul>
				<ul class="solution-item">
					<li>
						<img src="/redeess/images/partner10.jpg" alt="partner10" />
					</li>
					<li>
						<img src="/redeess/images/partner11.jpg" alt="partner11" />
					</li>
					<li>
						<img src="/redeess/images/partner12.jpg" alt="partner12" />
					</li>
				</ul>
				<ul class="solution-item">
					<li>
						<img src="/redeess/images/partner13.jpg" alt="partner13" />
					</li>
					<li>
						<img src="/redeess/images/partner14.jpg" alt="partner14" />
					</li>
					<li>
						<img src="/redeess/images/partner15.jpg" alt="partner15" />
					</li>
				</ul>
				<ul class="solution-item">
					<li>
						<img src="/redeess/images/partner16.jpg" alt="partner16" />
					</li>
					<li>
						<img src="/redeess/images/partner17.jpg" alt="partner17" />
					</li>
					<li>
						<img src="/redeess/images/partner18.jpg" alt="partner18" />
					</li>
				</ul>
				<ul class="solution-item">
					<li>
						<img src="/redeess/images/partner19.jpg" alt="partner19" />
					</li>
					<li>
						<img src="/redeess/images/partner20.jpg" alt="partner20" />
					</li>
					<li>
						<img src="/redeess/images/partner21.jpg" alt="partner21" />
					</li>
				</ul>
				<ul class="solution-item">
					<li>
						<img src="/redeess/images/partner22.jpg" alt="partner22" />
					</li>
					<li>
						<img src="/redeess/images/partner23.jpg" alt="partner23" />
					</li>
					<li>
						<img src="/redeess/images/partner24.jpg" alt="partner24" />
					</li>
				</ul>
				<ul class="solution-item">
					<li>
						<img src="/redeess/images/partner25.jpg" alt="partner25" />
					</li>
					<li>
						<img src="/redeess/images/partner26.jpg" alt="partner26" />
					</li>
					<li>
						<img src="/redeess/images/partner27.jpg" alt="partner27" />
					</li>
				</ul>
				<ul class="solution-item">
					<li>
						<img src="/redeess/images/partner28.jpg" alt="partner28" />
					</li>
					<li>
						<img src="/redeess/images/partner29.jpg" alt="partner29" />
					</li>
					<li>
						<img src="/redeess/images/partner30.jpg" alt="partner30" />
					</li>
				</ul>
				<ul class="solution-item">
					<li>
						<img src="/redeess/images/partner31.jpg" alt="partner31" />
					</li>
					<li>
						<img src="/redeess/images/partner32.jpg" alt="partner32" />
					</li>
					<li>
						<img src="/redeess/images/partner33.jpg" alt="partner33" />
					</li>
				</ul>
				<ul class="solution-item">
					<li>
						<img src="/redeess/images/partner34.jpg" alt="partner34" />
					</li>
					<li>
						<img src="/redeess/images/partner35.jpg" alt="partner35" />
					</li>
					<li>
						<img src="/redeess/images/partner36.jpg" alt="partner36" />
					</li>
				</ul>
				<ul class="solution-item">
					<li>
						<img src="/redeess/images/partner37.jpg" alt="partner37" />
					</li>
					<li>
						<img src="/redeess/images/partner38.jpg" alt="partner38" />
					</li>
					<li>
						<img src="/redeess/images/partner39.jpg" alt="partner39" />
					</li>
				</ul>
				<ul class="solution-item">
					<li>
						<img src="/redeess/images/partner40.jpg" alt="partner40" />
					</li>
					<li>
						<img src="/redeess/images/partner41.jpg" alt="partner41" />
					</li>
					<li>
						<img src="/redeess/images/partner42.jpg" alt="partner42" />
					</li>
				</ul>
				<ul class="solution-item">
					<li>
						<img src="/redeess/images/partner43.jpg" alt="partner43" />
					</li>
					<li>
						<img src="/redeess/images/partner44.jpg" alt="partner44" />
					</li>
					<li>
						<img src="/redeess/images/partner45.jpg" alt="partner45" />
					</li>
				</ul>
				<ul class="solution-item">
					<li>
						<img src="/redeess/images/partner46.jpg" alt="partner46" />
					</li>
					<li>
						<img src="/redeess/images/partner47.jpg" alt="partner47" />
					</li>
					<li>
						<img src="/redeess/images/partner48.jpg" alt="partner48" />
					</li>
				</ul>
				<div class="inquiry">
					<p>솔루션&컨설팅 상담 문의</p>
					<span>영업담당자</span>
					<span><a href="">support@redeess.com</a></span>
					<span>02-6463-6462</span>
				</div>
			</div>
			<div class="tab-block tab-block04">
				<h3 id="ul04">Technolgy</h3>
				<span>WEB Dek Framework은 Spring, iBatis, jQuery 기반의 생산성 및 성능 중심의 Framework입니다.</span>
				<h4>Client Side</h4>
				<ul class="solution-item">
					<li>
						<img src="/redeess/images/img05.jpg" alt="img05" />
					</li>
					<li>
						<img src="/redeess/images/img06.png" alt="img06" />
					</li>
					<li>
						<img src="/redeess/images/img07.png" alt="img07" />
					</li>
				</ul>
				<h4>Server Side</h4>
				<ul class="solution-item">
					<li>
						<img src="/redeess/images/img08.png" alt="img08" />
					</li>
					<li>
						<img src="/redeess/images/img12.png" alt="img12" />
					</li>
					<li>
						<img src="/redeess/images/img09.png" alt="img09" />
					</li>
				</ul>
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