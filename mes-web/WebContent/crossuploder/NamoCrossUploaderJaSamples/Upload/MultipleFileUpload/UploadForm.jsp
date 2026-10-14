<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<html> 
<head>
<link rel="stylesheet" type="text/css" href="../../css/common.css"/>
<title>동일한 file field의 name 값으로 2개 이상의 파일을 업로드하는 예제입니다.</title>
</head>

<body> 
	<div class="content_title_area">
		<div class="content_title">샘플 설명</div>
		<div class="content_desc">동일한 file field의 name 값으로 2개 이상의 파일을 업로드하는 예제입니다.</div>
		<div class="content_title">샘플 경로</div>
		<div class="content_desc">NamoCrossUploaderJaSamples/Upload/MultipleFileUpload</div>
	</div><br />
	
	<div class="form_area">
		<form action="UploadProcess.jsp" method="post" enctype="multipart/form-data">
	    	<div>파일1<input type="file" name="files"></div>
	    	<div>파일2<input type="file" name="files"></div>
	    	<div>파일3<input type="file" name="files"></div>
	   		<input type="submit" value="전송">  
		</form> 
	</div>
</body>

</html>