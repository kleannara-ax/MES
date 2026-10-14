<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>WMS</title>
<%@ include file="/mobile/include/tmsHead.jsp" %>
<style type='text/css'>

html, body {
    width: 100%;
    height: 100%;
} 

.filebox{background:#000055;color:#fff;font-weight:bold}

.camerafilebox label {
  display: inline-block; 
}
.camerafilebox input[type="file"] {  /* 파일 필드 숨기기 */
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip:rect(0,0,0,0);
  border: 0;
}
</style>
<!-- 지도API -->

<script type="text/javascript"> 

    var searchType = false;
    $(document).ready(function(){ 
		parent.searchList();
    });
     

</script>
</head>
 <body> 
    
</body>
</html>