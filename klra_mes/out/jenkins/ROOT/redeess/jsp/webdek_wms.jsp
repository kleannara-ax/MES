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
		<h1>WEBDek WMS Cloud</h1>
	</div>
	<div class="room-block02" style="height:300px;"></div>
	<div class="wrapper">
		<div class="tab wms-tab">
			<h2><img src="/redeess/images/main_webdek_wms.png" alt="webdek" /></h2>
			<ul class="ul-clicktab">
				<li class="on"><a href="#ul01">WMS</a></li>
				<li><a href="#">시스템 개념도</a></li>
				<li><a href="#">하드웨어 구성도</a></li>
				<li><a href="#">소프트웨어 구성도</a></li>
				<li><a href="#">요금안내</a></li>
				<li><a href="#">솔루션 특장점</a></li>
				<li><a href="#">도입효과</a></li>
			</ul>
			
			<div class="tab-block tab-block01 on">
				<p>
					<span>WMS</span>
					 창고/물류관리시스템은 공급망 전체의 원활한 흐름을 지원하기 위해 창고/물류를 효율적으로 관리하기 위한 것으로,제품의 입,출고,보관,품질보전,보관효율, 창고비, 운송지원, 정보처리 등을 지원하며, 창고의 자재입고에서 제품출하까지 관리하는 시스템이다.
				</p>
				<p>
					<span>WMS는</span>
					 생산관리시스템(MES)등과 연계하여, 개별제품에 대한 생산 및 출하이력을 실시간으로 제공하며 전산화된 품질 추적이 가능합니다. WMS는 각 공장,물류창고별 분산된 창고를 마치 하나의 창고를 보듯이 통합 하여 재고관리를 할 수 있습니다.
					 또한 Inbound Process(외부에서 창고로 입고되어 보관되기까지 입고관리 활동), Outbound Process(창고에서 출하되어 나가는 출고관리 활동) 그리고 Internal Process(재고의 이동,조정,정리 등의 창고 내에서 행해지는 활동)으로 구성되어 있습니다.
				</p>
				<div class="inquiry">
					<p>솔루션&컨설팅 상담 문의</p>
					<span>영업담당자</span>
					<span><a href="">support@redeess.com</a></span>
					<span>02-6463-6462</span>
				</div>
			</div>
			
			<div class="tab-block tab-block02">
				<p>
					<span>시스템 개념도</span>
					제조기업 전산환경의 핵심인 제조와 물류의 흐름을 계획하고 관리하는 제품으로 외부전산환경(ERP/SCM/CRM..)과 연계하여 유기적으로 통합되어 진다.
					구매를 통해 들어와 수입검사를 거처 자재/저장품이 입고되는 과정부터 바코드를 이용하여 자동으로 관리 가능하며, 생산공정의 제공과 반제품을 거쳐 포장에서 부터 출하/출고의 전과정을 바코드라벨을 통하여 출하/출고 과정을 자동으로 추적 및 관리할 수 있다.
				</p>
				<img src="/redeess/images/wms01.jpg" alt="wms01" />
				<div class="inquiry">
					<p>솔루션&컨설팅 상담 문의</p>
					<span>영업담당자</span>
					<span><a href="">support@redeess.com</a></span>
					<span>02-6463-6462</span>
				</div>
			</div>
			
			<div class="tab-block tab-block03">
				<p>
					<span>클라우드를 이용한 인프라 구축</span>
					클라우드를 이용한 인프라 구축
					Cloud를 이용하여 시스템의 인프라를 구축할 경우, 안전성(서버 다중화/백업 스토리지), 보안성 뿐만 아니라 구축비용과 관리비용까지 대폭 절감 할 수 있습니다. 또한 향후 시스템 증설 시 유연하게 대체할 수 있으며, 시스템의 감가상각비용이 발생하지 않습니다.
				</p>
				<img src="/redeess/images/wms02.jpg" alt="wms02" />
				<div class="inquiry">
					<p>솔루션&컨설팅 상담 문의</p>
					<span>영업담당자</span>
					<span><a href="">support@redeess.com</a></span>
					<span>02-6463-6462</span>
				</div>
			</div>
			
			<div class="tab-block tab-block04">
				<p>
					<span>클라우드를 이용한 인프라 구축</span>
					사업군과 비즈니스형태에 따라 다양한 소프트웨어 구성이 가능합니다.
				</p>
				<img src="/redeess/images/wms03.jpg" alt="wms03" />
				<div class="inquiry">
					<p>솔루션&컨설팅 상담 문의</p>
					<span>영업담당자</span>
					<span><a href="">support@redeess.com</a></span>
					<span>02-6463-6462</span>
				</div>
			</div>
			
			<div class="tab-block tab-block05">
				<h3 id="ul05">TASK별 요금 측정</h3>
				
				<ul class="solution-item">
					<li>
						<p>Light</p>
						<ul>
							<li>- 기본 이용료 : 1,000,000만원</li>
							<li>- TASK : 1,000건 / 1일</li>
							<li>- 초과금액 : 1Row당 500원추가</li>
						</ul>
					</li>
					<li>
						<p>Basic</p>
						<ul>
							<li>- 기본 이용료 : 1,500,000만원</li>
							<li>- TASK : 3,000건 / 1일</li>
							<li>- 초과금액 : 1Row당 300원추가</li>
						</ul>
					</li>
					<li>
						<p>Enterprise</p>
						<ul>
							<li>- 기본 이용료 : 2,000,000만원</li>
							<li>- TASK : 10,000건 / 1일</li>
							<li>- 초과금액 : 1Row당 100원추가</li>
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
			
			<div class="tab-block tab-block06">
				<ul class="solution-item">
					<li>
						<p>1. 적정한 인원계획 수립 가능</p>
						<ul>
							<li>- 적정 소요인원에서 고용수준 유지가 가능하고 인력 추가 필요시 단기 임시직을 활용하여 운영</li>
						</ul>
					</li>
				</ul>
				<ul class="solution-item">
					<li>
						<p>2. 창고공간의 효율적인 관리</p>
						<ul>
							<li>- 재고 순환조사, 지능형 피킹, 재고보충, 크로스 도킹 등 창고 현실에 맞는 효율적 창고 운영이 가능</li>
						</ul>
					</li>
				</ul>
				<ul class="solution-item">
					<li>
						<p>3. 노동 생산성의 향상</p>
						<ul>
							<li>- 기존의 작업을 디지털화하여 입출고 과정의 오류를 없애고 물품의 재고파악, 피킹 등 업무량을 혁신적으로 감소</li>
						</ul>
					</li>
				</ul>
				<ul class="solution-item">
					<li>
						<p>4. 자재에 대한 정보 실시간 제공</p>
						<ul>
							<li>- 제품에 대한 정보를 실시간으로 제공받아 자재 및 재고의 위치를 실시간으로 파악 가능</li>
						</ul>
					</li>
				</ul>
				<ul class="solution-item">
					<li>
						<p>5. Paperless 작업 가능</p>
						<ul>
							<li>- 모든 프로세스에 대해 PSA, RFID 등으로 관리 가능하여 종이나 서류작성없이 작업과 관리가 가능</li>
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
			
			<div class="tab-block tab-block07">
				<img src="/redeess/images/wms04.jpg" alt="wms04" />
				<ul class="solution-item">
					<li>
						<p>1. 창고관리</p>
						<ul>
							<li>- 자재 선입/선출관리</li>
						</ul>
					</li>
				</ul>
				<ul class="solution-item">
					<li>
						<p>2. 재고관리</p>
						<ul>
							<li>- 자재 재고관리</li>
						</ul>
					</li>
				</ul>
				<ul class="solution-item">
					<li>
						<p>3. 바코드/RFID 관리</p>
						<ul>
							<li>- 이동/Location 관리</li>
						</ul>
					</li>
				</ul>
				<ul class="solution-item">
					<li>
						<p>4. 현황모니터링</p>
						<ul>
							<li>- 실시간 모니터링</li>
						</ul>
					</li>
				</ul>
				<ul class="solution-item">
					<li>
						<p>5. Interface</p>
						<ul>
							<li>- 각종 통계 및 자료도출</li>
						</ul>
					</li>
				</ul>
				<ul class="solution-item">
					<li>
						<p>6. 업무운영</p>
						<ul>
							<li>- 정보시스템에 의한 신속하고 정확한 물류업무 수행</li>
							<li>- 로케이션 관리를 통한 창고내 공간 활용의 최적화</li>
							<li>- 물류업무 표준화를 통한 업무 능력 향상</li>
							<li>- 현장의 데이터 분석 지원으로 업무 효율 향상</li>
						</ul>
					</li>
				</ul>
				<ul class="solution-item">
					<li>
						<p>7. 재무회계</p>
						<ul>
							<li>- 물류생산성 향상을 통한 물류비 절감</li>
							<li>- 리드타임(Lead Time) 감소로 창고 운영 비용 절감</li>
							<li>- 작업의 효율적 시간관리로 인한 인건비 절감</li>
							<li>- 적정재고 관리를 통한 재고 비용 감소</li>
						</ul>
					</li>
				</ul>
				<ul class="solution-item">
					<li>
						<p>8.경영전략</p>
						<ul>
							<li>- 정보 관리수준 향상 및 IT 인프라 확보를 통한 경쟁우위 확보</li>
							<li>- 각종 정보기술을 활용한 기업의 물류 경쟁력 확보</li>
							<li>- 물류시장의 급속한 환경변화에 대한 신속 대응 체제 확립</li>
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
			
		</div>
	</div>
	<div class="room-block"></div>
	<%@ include file="/redeess/include/bottom.jsp" %>
</div>
</body>
</html>