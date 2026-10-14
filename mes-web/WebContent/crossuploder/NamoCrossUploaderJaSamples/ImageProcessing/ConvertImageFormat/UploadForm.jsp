<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<html> 
<head>
<link rel="stylesheet" type="text/css" href="../../css/common.css"/>
<title>이미지 파일의 포맷을 변경하는 예제입니다.</title>
</head>

<body> 
	<div class="content_title_area">
	<div class="content_title">샘플 설명</div>
	<div class="content_desc">이미지 파일의 포맷을 변경하는 예제입니다.</div>
	<div class="content_title">샘플 경로</div>
	<div class="content_desc">NamoCrossUploaderJaSamples/ImageProcessing/ConvertImageFormat</div>
	</div><br />

	<div class="form_area">
		<form action="UploadProcess.jsp" method="post" enctype="multipart/form-data">
	    	<div>이미지 파일<input type="file" name="files"></div>
	   		<input type="submit" value="전송">  
		</form> 
	</div>
</body>

</html>