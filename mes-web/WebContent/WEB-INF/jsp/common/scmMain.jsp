<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>SCM</title>
</head>
<body>
<script type="text/javascript">
	var sWidth = window.screen.availWidth;
	var sHeight = window.screen.availHeight;
	
	var windowName = "SCM";
	window.opener = self;
	window.open("/scm/main.page", windowName, "height="+sHeight+",width="+sWidth+",resizable=yes");
	
</script>
</body>
</html>