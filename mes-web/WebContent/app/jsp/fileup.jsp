<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
</head>
<body>
<form action="/app/image/fileUp/json.data" enctype="multipart/form-data" method="post">
	<input type="file" name="file1" />
	<input type="file" name="file2" />
	<input type="hidden" name="imageThumbnailSize" value="100" />
	<input type="submit" value="upload"/>
</form>
</body>
</html>