<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<html> 
<head>
<link rel="stylesheet" type="text/css" href="../../css/common.css"/>
<title>이미지 파일의 메타데이터 정보를 가져오는 예제입니다.</title>
</head>

<body> 
	<div class="content_title_area">
		<div class="content_title">샘플 설명</div>
		<div class="content_desc">이미지 파일의 메타데이터 정보를 가져오는 예제입니다.</div>
		<div class="content_desc_warning"><b>[Apache License, Version 2.0]</b><br />
		해당 기능은 NamoCrossUploader Server Java Edition 제품에서 제공하지 않으며,<br />
		Apache License, Version 2.0에 따르는 별도의 오픈소스(metadata-extractor-2.6.4.jar) 라이브러리와 연동하는 방법을 설명합니다.<br />
		Apache License, Version 2.0은 사용에 따른 소스코드 공개의 의무가 존재하지 않으며, 상업적 이용에 대해 제한을 두지 않고 있습니다.<br />
		배포 시 일반적으로 라이선스 사본 및 저작권 고지사항 포함 등을 요구하고 있습니다. 자세한 사항은 <a href="http://www.apache.org/licenses/LICENSE-2.0"><b>Apache License, Version 2.0</b></a> 을 참조해 주십시오.
		</div>
		<div class="content_title">샘플 경로</div>
		<div class="content_desc">NamoCrossUploaderJaSamples/ImageProcessing/ImageMetadataInformation</div>
	</div><br />

	<div class="form_area">
		<form action="UploadProcess.jsp" method="post" enctype="multipart/form-data">
	    	<div>이미지 파일<input type="file" name="files"></div>
	   		<input type="submit" value="전송">  
		</form> 
	</div>
</body>

</html>