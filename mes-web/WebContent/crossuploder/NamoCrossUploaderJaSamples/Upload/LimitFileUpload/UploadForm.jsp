<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<html> 
<head>
<link rel="stylesheet" type="text/css" href="../../css/common.css"/>
<title>파일 확장자, 전체 Content-Length 및 개별 파일 크기를 제한하는 예제입니다.</title>
</head>

<body> 
	<div class="content_title_area">
	<div class="content_title">샘플 설명</div>
	<div class="content_desc">파일 확장자, 전체 Content-Length 및 개별 파일 크기를 제한하는 예제입니다.</div>
	<table class="form_table"><tbody>
	<tr><td colspan="2">[업로드 제한 정보]</td></tr>
	<tr><td>허용할 파일 확장자: </td><td>jpg, jpeg, txt (대소문자를 구분하지 않으며, 허용할 파일 확장자와 허용하지 않을 파일 확장자를 선택적으로 설정 가능합니다)</td></tr>
	<tr><td>전체 Content-Length 제한: </td><td>10 MB</td></tr>
	<tr><td>개별 파일 크기 제한: </td><td>10 KB</td></tr>
	</tbody></table><br />
	
	<div class="content_title">샘플 경로</div>
	<div class="content_desc">NamoCrossUploaderJaSamples/Upload/LimitFileUpload</div>
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