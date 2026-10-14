<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
<link rel="stylesheet" type="text/css" href="/crossuploder/NamoCrossUploaderFxSamples/css/namocrossuploader.css" />
<script type="text/javascript" src="/crossuploder/NamoCrossUploaderFxSamples/js/swfobject.js"></script>
<script type="text/javascript" src="/common/js/jquery.js"></script>
<script type="text/javascript" src="/common/js/crossUp.js"></script>
<script type="text/javascript">
	$(document).ready(function(){
		 /**
		* NamoCrossUploader 객체를 생성합니다.
        * 객체의 크기 변경, Javascript로 전송하는 이벤트 이름 변경 및 기타 설정은 함수 내부를 참조해 주십시오. 
        * createNamoCrossUploader 함수는 namocrossuploader.js 파일에 구현되어 있습니다. 
        * 각각의 Id는 변경 가능합니다.
        */
        createNamoCrossUploader(
            "crossUploadManager",   // NamoCrossUploader의 Manager 객체 Id
            "crossUploadMonitor",   // NamoCrossUploader의 Monitor 객체 Id 
            "flashContentManager",  // NamoCrossUploader의 Manager 객체가 위치할 HTML Id (body 태크 내에 선언된 Id와 동일해야 함)
            "flashContentMonitor"  // NamoCrossUploader의 Monitor 객체가 위치할 HTML Id (body 태크 내에 선언된 Id와 동일해야 함)
            );
	});
</script>
</head>
<body>
	<div class="form_area">
        <!-- NamoCrossUploader의 Manager 객체가 위치할 HTML Id -->
        <div id="flashContentManager" style="display: none;">
            <p>To view this page ensure that Adobe Flash Player version 11.1.0 or greater is installed.</p>
            <script type="text/javascript"> 
                var pageHost = ((document.location.protocol == "https:") ? "https://" : "http://"); 
                document.write("<a href='http://www.adobe.com/go/getflashplayer'><img src='" 
                                + pageHost + "www.adobe.com/images/shared/download_buttons/get_flash_player.gif' alt='Get Adobe Flash player' /></a>" ); 
            </script> 
        </div>
        <!-- NamoCrossUploader의 Monitor 객체가 위치할 HTML Id와 Monitor Layer Id-->
		<div id="monitorLayer" style="display: none;">
			<div id="flashContentMonitor" style="display:none;">
			</div>
		</div>
		<!-- NamoCrossUploader의 Monitor 창이 출력될 때 화면의 백그라운드 Layer Id -->
		<div id="monitorBgLayer" style="display: none;">
		</div>

		<br /><br />
		<!-- NamoCrossUploader의 업로드 버턴이 invisible 또는 disable 됐을 때 HTML 내에서 직접 업로드를 시작 -->
		<input type="button" id="startUpload" value="업로드" onclick="onStartUpload()" style="visibility:hidden"/>
	</div>
</body>
</html>