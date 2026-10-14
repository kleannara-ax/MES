<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/demo_layout.css">
<script type="text/javascript">
	$(document).ready(function(){
		
	});
</script>
</head>
<body>
<%@ include file="/common/include/webdek/layout.jsp" %>
<!-- content -->
<!--  
horizontal : 수평
vertical : 수직
-->
<div class="content_wrap">
	<div class="content_inner">
		<%@ include file="/common/include/webdek/title.jsp" %>
		<div class="search_next_wrap">
			<div class="content_layout tabs top_layout">
				<ul class="tab tab_style02">
					<li class="btn_zoom_wrap">
						<ul>
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-1">
					<div class="table_list01">
						<div class="scroll">
							1
						</div>
					</div>
				</div>
			</div>
			
			<div class="content-horizontal-wrap h-wrap-min bottom_layout">
				<div class="content-vertical-wrap content_left">	
					<div class="content_layout tabs more_H_layout">
						<ul class="tab tab_style02">
							<li class="btn_zoom_wrap">
								<ul>
									<li><button class="btn btn_bigger"><span>확대</span></button></li>
								</ul>
							</li>
						</ul>
						<div class="inner_search_wrap">
							2
						</div>
					</div>
					<div class="content_layout tabs  more_H_layout">
						<ul class="tab tab_style02">
							<li class="btn_zoom_wrap">
								<ul>
									<li><button class="btn btn_bigger"><span>확대</span></button></li>
								</ul>
							</li>
						</ul>
						<div class="inner_search_wrap">
							3
						</div>
					</div>
					<div class="content_layout tabs more_H_layout" >
						<ul class="tab tab_style02">
							<li class="btn_zoom_wrap">
								<ul>
									<li><button class="btn btn_bigger"><span>확대</span></button></li>
								</ul>
							</li>
						</ul>
						<div class="inner_search_wrap">
							4
						</div>
					</div>
				</div>
				
				<div class="content-vertical-wrap content_right">
					<div class="content_layout tabs more_H_layout">
						<ul class="tab tab_style02">
							<li class="btn_zoom_wrap">
								<ul>
									<li><button class="btn btn_bigger"><span>확대</span></button></li>
								</ul>
							</li>
						</ul>
						<div class="inner_search_wrap">
							5
						</div>
					</div>
					
					<div class="content_layout tabs more_H_layout">
						<ul class="tab tab_style02">
							<li class="btn_zoom_wrap">
								<ul>
									<li><button class="btn btn_bigger"><span>확대</span></button></li>
								</ul>
							</li>
						</ul>
						<div class="inner_search_wrap">
							6
						</div>
					</div>
					
					<div class="content_layout tabs more_H_layout">
						<ul class="tab tab_style02">
							<li class="btn_zoom_wrap">
								<ul>
									<li><button class="btn btn_bigger"><span>확대</span></button></li>
								</ul>
							</li>
						</ul>
						<div class="inner_search_wrap">
							7
						</div>
					</div>
				</div>
			</div>
		</div>
		
	</div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>