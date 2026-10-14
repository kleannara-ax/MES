<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<html> 
<head>
<link rel="stylesheet" type="text/css" href="../../css/common.css"/>
<title>이미지 파일의 크기를 변경하는 예제입니다. (Thumbnail)</title>
</head>

<body> 
	<div class="content_title_area">
	<div class="content_title">샘플 설명</div>
	<div class="content_desc">이미지 파일의 크기를 변경하는 예제입니다. (Thumbnail)<br />
	샘플에서는 50% 비율로 크기를 줄인 것과, 너비 100, 높이 100의 명시적인 크기로 각각의 이미지를 변경합니다.</div>
	<div class="content_title">샘플 경로</div>
	<div class="content_desc">NamoCrossUploaderJaSamples/ImageProcessing/ResizeImage</div>
	</div><br />

	<div class="form_area">
		<form action="UploadProcess.jsp" method="post" enctype="multipart/form-data">
	    	<div>이미지 파일<input type="file" name="files"></div>
	   		<input type="submit" value="전송">  
		</form> 
	</div>
</body>

</html>