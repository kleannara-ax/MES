<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<html> 
<head>
<link rel="stylesheet" type="text/css" href="../../css/common.css"/>
<title>이미지 타입의 마크를 원본 이미지에 삽입하는 워터마크 예제입니다.</title>
</head>

<body> 
	<div class="content_title_area">
	<div class="content_title">샘플 설명</div>
	<div class="content_desc">이미지 타입의 마크를 원본 이미지에 삽입하는 워터마크 예제입니다.</div>
	<div class="content_title">샘플 경로</div>
	<div class="content_desc">NamoCrossUploaderJaSamples/ImageProcessing/ImageWatermark</div>
	</div><br />

	<div class="form_area">
		<form action="UploadProcess.jsp" method="post" enctype="multipart/form-data">
		 	<table class="form_table"><tbody> 
	    		<tr><td>이미지 파일</td><td><input type="file" name="files"></td></tr>
	    		<tr><td>삽입 할 이미지 파일</td><td><input type="file" name="inFiles"></td></tr>
	   		</tbody></table>
	   		<input type="submit" value="전송">  
		</form> 
	</div>
</body>

</html>