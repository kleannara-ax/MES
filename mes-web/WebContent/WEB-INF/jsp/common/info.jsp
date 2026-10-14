<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<script type="text/javascript" src="/common/js/jquery.js"></script>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<script type="text/javascript">
	$(document).ready(function(){
		var $slider = $('.slider');
		var $slide = 'li';
		var $transition_time = 1000; // 1초
		var $time_between_slides = 4000; // 4초
		
		function slides(){
			return $slider.find($slide);
		}
		
		// 전체 fadeOut
		slides().fadeOut();
		
		// 가장 처음에는 1번재 그림 활성화
		// 활성화 중인 그림이 몇번째인지 알아내기 위해서 active클래스 부여
		slides().first().addClass('active');
		slides().first().fadeIn($transition_time);
		
		// 5초마다 스크롤 넘기기 무한반복
		$interval = setInterval(function(){
			// 현재
			var $i = $slider.find($slide + '.active').index();
			
			slides().eq($i).removeClass('active');
			slides().eq($i).fadeOut($transition_time);
			
			// 마지막장까지 갔으면 처음으로
			if (slides().length == $i + 1) {
				$i = -1;
			}
			slides().eq($i + 1).fadeIn($transition_time);
			slides().eq($i + 1).addClass('active');
		}, $transition_time + $time_between_slides);
	});
</script>
<style type="text/css">
	body {
		overflow: hidden;
	}
	.slider li {
		display: none;
		position: absolute; 
		top: 0; 
		left: 0; 
	}
	
	.slider li img{
		width: 105em;
		height: 56em;
	}
	
	#overflow {
		overflow: hidden;
	}
</style>
<title>Insert title here</title>
</head>
<body>
<div id="overflow">
	<ul class="slider">
		<li>
			<img src="/common/images/gfwmsInfo1.png" style="width:100%;height:100%;"/>
		</li>
		<li>
			<img src="/common/images/gfwmsInfo2.png" style="width:100%;height:100%;" />
		</li>
		<li>
			<img src="/common/images/gfwmsInfo3.png" style="width:100%;height:100%;" />
		</li>
	</ul>
</div>
<!-- <img src="/common/images/airwms.png" /> -->
<!-- <img src="/common/images/reifen3.jpg" style="width:79%; margin:-8px 0 0 11%; position:fixed;"/> -->
</body>
</html>