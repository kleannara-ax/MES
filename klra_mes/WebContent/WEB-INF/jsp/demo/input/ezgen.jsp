<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript" src="/common/js/ezgencontrol.js"></script>
<script type="text/javascript">
	$(document).ready(function(){

	});
	/*
	* @ window.open형태로 팝업 호출
	
	*/
	function ezgen(filesrc, width, height, andvalue){
		window.open("/common/common_ezprint.page?filename=/ezgen/barcodel.ezg&width=1110&height=620", "ezgen")
		//window.open("/common/common_ezprint.page?filename=" + filesrc + "&width=" + width + "&height=" + height + "&andvalue=" + andvalue, "ezgen");
		
		var wherestr = "";
		var orderbystr = "";
		var width = 1000;
		var height = 620;
		var dataMap = new DataMap();
		dataMap.put("OTHER_PARAM","ABCDEFG");
		WriteEZgenElement("/ezgen/barcodel",wherestr,orderbystr,<%=langky%>,dataMap,width,height);
	}

	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Print"){
			ezgen();
		}
	}
</script>
</head>
<body>
<%@ include file="/common/include/webdek/layout.jsp" %>
<!-- content -->
<div class="content_wrap">
	<div class="content_inner">
		<%@ include file="/common/include/webdek/title.jsp" %>
		<div class="content_serch" id="searchArea">
			<div class="btn_wrap">
				<div class="fl_l">
				</div>
				<div class="fl_r">
					<input type="button" CB="Print SEARCH BTN_PRINT" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="Search"></dt>
						<dd>
							<input type="text" class="input" name="Search" UIInput="S,SHAREMA" IAname="Search" UIFormat="U"/>
						</dd>
					</dl>
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>