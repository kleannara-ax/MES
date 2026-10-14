<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<html> 
<head>
<link rel="stylesheet" type="text/css" href="../../css/common.css"/>
<title>업로드 한 파일을 BLOB 타입으로 DB에 저장하고, 다운로드하는 예제입니다.</title>
</head>

<body> 
	<div class="content_title_area">
	<div class="content_title">샘플 설명</div>
	<div class="content_desc">업로드 한 파일을 BLOB 타입으로 DB에 저장하고, 다운로드하는 예제입니다.<br />
		본 샘플에서는 save() 또는 saveAs() Method로 파일을 저장하지 않은 채, 임시 파일을 BLOB 타입으로 DB에 저장합니다.<br />
		필요 시에는 save() Method 등을 통해 파일을 저장할 수 있습니다.<br />
		<font color="red">또한 DBMS에 바로 저장을 하는 것이기 때문에 업로드 크기는 DBMS에서 설정됩니다. txt 타입 등의 작은 크기의 파일을 선택해 주십시오.</font><br />
		테스트를 위해서는 DBMS와 JDBC 드라이버가 설치되어 있어야 합니다. <br />
		아래 DB 정보를 참고하셔서 적절한 테스트를 진행해 주십시오. <br /><br />
		<table class='form_table'><tbody> 
			<tr><td class='form_table_title' colspan=2><b>[테스트 시 사용된 DB 정보]</b></td></tr>
			<tr><td>DBMS</td><td>MySQL</td></tr>
			<tr><td>DB</td><td>blob_db</td></tr>
			<tr><td>Table</td><td>blob_table</td></tr>
			<tr><td>Column</td>
			<td>
			id INT(11) [PK, Not Null, Auto Increment]<br />
			filename VARCHAR(45) [Not Null]<br />
			filedata BLOB<br />
			</td></tr>
		</tbody></table>
	</div>
	<div class="content_title">샘플 경로</div>
	<div class="content_desc">NamoCrossUploaderJaSamples/Others/BLOB</div>
	</div><br />

	<div class="form_area">
		<form action="UploadProcess.jsp" method="post" enctype="multipart/form-data">
	    	<div>파일<input type="file" name="files"></div>
	   		<input type="submit" value="전송">  
		</form> 
	</div>
</body>

</html>