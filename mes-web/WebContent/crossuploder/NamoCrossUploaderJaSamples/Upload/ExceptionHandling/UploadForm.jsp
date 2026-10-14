<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<html> 
<head>
<link rel="stylesheet" type="text/css" href="../../css/common.css"/>
<title>업로드 외 로직에서 예외 발생 시 예외 처리 및 이미 업로드 된 파일을 삭제하는 예제입니다.</title>
</head>

<body> 
	<div class="content_title_area">
	<div class="content_title">샘플 설명</div>
	<div class="content_desc">업로드 외 로직에서  예외 발생 시 예외 처리 및 이미 업로드 된 파일을 삭제하는 예제입니다.(예외는 2번째 파일 저장시 발생)<br />
		파일업로드 자체에서 예외가 발생했을 경우는 내부적으로 임시파일들을 모두 삭제합니다. 
	</div>
	<div class="content_title">샘플 경로</div>
	<div class="content_desc">NamoCrossUploaderJaSamples/Upload/ExceptionHandling</div>
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