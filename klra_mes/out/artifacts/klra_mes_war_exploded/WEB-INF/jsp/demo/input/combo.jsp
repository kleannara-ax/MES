<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript">
	inputList.comboCash = false;	
	
	$(document).ready(function(){
		
	});
	
	function comboEventDataBindeBefore(comboAtt, $comboObj){
		//commonUtil.debugMsg("comboEventDataBindeBefore : ", arguments);
		if(comboAtt = "Demo,COMCODE_EVENT"){
			var param = new DataMap();
			param.put("PARAM", "LANGKY");
			return param;
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
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="Combo"></dt>
						<dd>
							<select name="Combo" class="input" Combo="Demo,COMCODE">
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="ComboText"></dt>
						<dd>
							<select name="ComboText" class="input" Combo="Demo,COMCODE" ComboCodeView="false">
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="Combo param"></dt>
						<dd>
							<!-- Combo="MODULE,COMMAND,CODE1,CODE2,..." -->
							<select name="ComboParam" class="input" Combo="Demo,COMCODE_PARAM,LANGKY">
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="Combo event"></dt>
						<dd>
							<select name="ComboEvent" class="input" Combo="Demo,COMCODE_EVENT">
							</select>
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