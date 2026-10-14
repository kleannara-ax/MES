	<%@ page language="java" contentType="text/html; charset=UTF-8"
		pageEncoding="UTF-8"%>
	<script type="text/javascript">
	$(function(){	
		$('.mobile_submenu').hide();
			$('.submenu_all').click(function(){
				$('.mobile_submenu').show();
			});
		$('.mobile_submenu_close').click(function(){
			$('.mobile_submenu').hide();
		});
	});
	</script>
	
	<div class="mobile_submenu">
		<p><span><img src="/mobile/images/logo01.png" alt="logo" title="webdek" /></span><span class="mobile_submenu_close"></span></p>
		<p><span>홍길동 님, 안녕하세요!</span></p>
		<p class="submenu_home"><button onClick="location.href='/mobile/jsp/mobile.jsp'">주문하기</button><button>주문내역</button><button>내거래처</button><button>내적립금</button></p>
		<p><button onClick="location.href='/mobile/index.page'">로그인</button><button>주문조회</button></p>
		<ul>
			<li><a href="#">사용자변경</a></li>
			<li><a href="#">푸시알림</a><input type="checkbox" id="push" name="push"/><label for="push"><span></span></label></li>
			<li><a href="/demo/mobile/gridSingle.page">grid</a></li>
			<li><a href="/demo/mobile/input.page">input</a></li>
		</ul>
	</div>