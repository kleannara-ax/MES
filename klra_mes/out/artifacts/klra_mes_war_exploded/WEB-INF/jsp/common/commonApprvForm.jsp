<%@ page import="project.common.bean.CommonConfig" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
		 pageEncoding="UTF-8"%>
<%
	Object SES_USER_ID = request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY);
%>
<form id="approval" name="approval" method="post">
	<input type="hidden" name="targetUrl" value="/groupware/approval/apprDocPost.do"/>
	<input type="hidden" name="userId" value="<%=SES_USER_ID%>"/>
	<input type="hidden" name="formCd" value="MES001"/> <!--MES001:검사성적서, MES0002:재고실사 결과통보, MES003:페기처리 결과 통보-->
	<input type="hidden" name="appKey01" value=""/>		<!-- DOC_ID -->
	<input type="hidden" name="appKey02" value=""/>
	<input type="hidden" name="appKey03" value=""/>
	<input type="hidden" name="appKey04" value=""/>
	<input type="hidden" name="appKey05" value=""/>
	<input type="hidden" name="title" id="aprvTitle" value=""/>	<!--MES001:검사성적서, MES0002:재고실사 결과통보, MES003:페기처리 결과 통보-->
	<input type="hidden" name="htmlParam" value=""/>
	<input type="hidden" name="formEditorData" value=""/>	<!-- HTML -->
	<%--  <input type="hidden" name="attachFile" value="1.jpg|D:\통합결재\깨끗한나라 EP 통합 결재 API 연계 가이드_V0.6_20210721.docx"/>--%>
	<%--  <input type="hidden" name="attachFile" value="2.jpg|http://rule.kleannara,.com/2.jpg"/>--%>
	<%--  <input type="hidden" name="attachFile" value="3.jpg|http://rule.kleannara,.com/3.jpg"/>--%>
</form>
<script>
	function openApprvPop(formCd,DOC_ID,HTML) {
		// 먼저 EP인증여부 판단
		var encData = getCookieValue('encData');
		if(!encData) {
			alert("EP로그인이 되지 않습니다.")
			return
		}

		var param = new DataMap();
		param.put("encData", encData);
		var json = netUtil.sendData({
			url : "/mes/gw/login/json/data.data",
			param : param
		});
		if(!json || !json.login || json.login != 'Y') {
			if(json.message) {
				// alert("인증실패 메시지:"+json.message)
				alert('EP 인증이 되지 않았습니다. EP 로그인을 하세요.')
			}else {
				alert('EP 인증이 되지 않았습니다. EP 로그인을 하세요.')
			}
			return;
		}
		//
		console.log('DOC_ID===>',DOC_ID)
		if(DOC_ID == undefined || !DOC_ID) return;
		if(HTML == undefined || !HTML) return;
		$("[name='formCd").val(formCd);
		$("[name='appKey01']").val(DOC_ID);
		// $("[name='htmlParam']").val(HTML);
		$("[name='formEditorData']").val(HTML);
		if(formCd == 'MES001') {
			$("#aprvTitle").val('검사성적서')
		}
		if(formCd == 'MES002') {
			$("#aprvTitle").val('재고실사 결과통보')
		}
		if(formCd == 'MES003') {
			$("#aprvTitle").val('페기처리 결과통보')
		}
		var pop_title = "approvalSyncFormPopup" ;

		var features = "channelmode=no, directories=no, location=no, menubar=no, scrollbars=yes, status=no, titlebar=no, toolbar=no, width=1070, height=635, fullscreen=no, left=745, top=207, resizable=no, scrollbars=yes";
		var popupOpen = window.open(null, pop_title, features);
		var frmData = document.approval ;

		// 개발서버
		frmData.action = '<%=CommonConfig.getGW_SITE()%>/support/ssoProxy.do';
		// 운영서버
		// frmData.action = 'https://gw.kleannara.com/support/ssoProxy.do';

		frmData.target = pop_title ;
		frmData.submit();

		var isPopUp = true;

		/*
        * 팝업 호출 이후 1초간격으로 팝업닫힘을 체크하며
        * 팝업이 닫히면 닫힌 이후 처리로직 구현
        */
		var interval = window.setInterval(function() {
			try {
				//console.log('popupOpen = ' + popupOpen);
				if (popupOpen == null || popupOpen.closed) {
					isPopUp = false;
					//console.log('popupOpen = ' + isPopUp);
					// alert('팝업 닫힘');
					// 팝업 닫힌 후 로직 구현
					clearInterval(interval);
					window.opener.searchList();
				}
			} catch (e) {
				console.log(e);
				clearInterval(interval);
			}
		}, 1000);

	}


	const getCookieValue = (key) => {
		let cookieKey = key + "=";
		let result = "";
		const cookieArr = document.cookie.split(";");

		for(let i = 0; i < cookieArr.length; i++) {
			if(cookieArr[i][0] === " ") {
				cookieArr[i] = cookieArr[i].substring(1);
			}

			if(cookieArr[i].indexOf(cookieKey) === 0) {
				result = cookieArr[i].slice(cookieKey.length, cookieArr[i].length);
				return result;
			}
		}
		return result;
	}



</script>

