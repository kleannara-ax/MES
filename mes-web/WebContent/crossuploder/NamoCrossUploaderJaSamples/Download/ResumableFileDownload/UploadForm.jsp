<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<html> 
<head>
<link rel="stylesheet" type="text/css" href="../../css/common.css"/>
<title>이어받기가 가능한 파일 다운로드 예제입니다.</title>
</head>

<body> 
	<div class="content_title_area">
	<div class="content_title">샘플 설명</div>
	<div class="content_desc">이어받기가 가능한 파일 다운로드 예제입니다. <br />
		클라이언트에서 이어받기 요청이 있어야 하며, 이어받기 요청이 없을 경우 일반 다운로드와 동일하게 동작합니다.<br />
		다운로드 할 파일을  업로드 해 주십시오.<br />
		다운로드 테스트를 위해 업로드 한 파일의 정보는 session 객체에 저장됩니다.
	</div>
	<div class="content_title">샘플 경로</div>
	<div class="content_desc">NamoCrossUploaderJaSamples/Download/AttachmentFileDownload</div>
	</div><br />

	<div class="form_area">
		<form action="UploadProcess.jsp" method="post" enctype="multipart/form-data">
	    	<div>파일<input type="file" name="files"></div>
	   		<input type="submit" value="전송">  
		</form> 
	</div>
</body>

</html>