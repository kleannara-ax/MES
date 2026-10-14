<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.common.bean.*,com.common.util.*,com.common.bean.CommonConfig,java.util.*"%>    
<%
	String sysTitle   = CommonConfig.SYSTEM_TITLE;
	String sysVersion = CommonConfig.SYSTEM_VERSION;
%>     
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<style type="text/css">
	/* Error */	
	.error_box {
		position: fixed;
		left: 50%;
		top: 30%;
		margin-left: -230px;
		width: 450px;
	}
	
	.error_box .error_tit {
		color: #666666;
		font-size: 36px;
		line-height: 50px;
		text-align: center;
		font-weight: 900;
	}
	
	.error_box .error_tit2 {
		margin-top: 20px;
		color: #666666;
		font-size: 20px;
		line-height: 26px;
		text-align: center;
	}
	
	.error_box .error_tit span {
		display: inline-block;
		width: 100%;
		font-size: 72px;
		font-weight: normal;
	}
	
	.error_box .error_txt {
		margin: 30px 0 0 0;
		color: #666666;
		font-size: 12px;
		text-align: center;
		line-height: 17px;
	}
	
	.error_box .error_txt a {
		color: #ec6c01;
	}	
</style>
<title><%=sysTitle%> <%=sysVersion%></title>
<script type="text/javascript">
	function fnGoMain() {
		try{
			if(commonUtil.isMobile()){
				this.location.href = "/mobile/index.page";
			}else{
				this.location.href = "/common/index.page";	
			}	
		}catch(e){
			this.location.href = "/common/index.page";	
		}
	}
</script>
</head>


<body>
	<div class="error_box">
		<p class="error_tit">
			<span>500</span>
			Internal Server Error
		</p>
		<p class="error_tit2">
			죄송합니다.
			<br />
			내부서버에 문제가 발생하였습니다.
		</p>
		<p class="error_txt">
			문의사항이나 궁금하신 사항은
			<br /><a href="https://www.hankook-networks.com">홈페이지</a>
			한국네트웍스(주) SCM솔루션팀
			<br />
			통하여 연락 주시면 신속하게 답변 드리겠습니다.
		</p>
		<p align="center"><br><br>
			<a href="#" onclick="fnGoMain(); return false;">메인으로 이동</a>
		</p>
	</div>
</body>
</html>