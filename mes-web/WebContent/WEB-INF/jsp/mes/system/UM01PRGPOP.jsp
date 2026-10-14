<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>   
 <%@ page import="com.common.bean.DataMap,com.common.bean.CommonConfig"%>
<%
	String langky = request.getSession().getAttribute(CommonConfig.SES_USER_LANGUAGE_KEY).toString();
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>프로그램추가</title>
<%@ include file="/common/include/popHead.jsp" %>
<script type="text/javascript">

	window.resizeTo('550','240');
	
	$(document).ready(function(){
		
		var data = page.getLinkPopData();
		dataBind.dataNameBind(data, "searchArea");
	});
	
	function fn_closing(){
		this.close();
	}
	
	function fn_reflect(){

		if(validate.check("searchArea")){
			uiList.setActive("Reflect", false);
			var param = inputList.setRangeParam("searchArea");
			param.put("TYPE","PRG");
			page.linkPopClose(param);
		}
	}
	
	function commonBtnClick(btnName){
		if(btnName == "Reflect"){
			fn_reflect();
		}else if(btnName == "Check"){
			fn_closing();
		}
	}
 	
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="Reflect REFLECT BTN_REFLECT">
		</button>
		<button CB="Check CHECK BTN_CLOSE">
		</button>
	</div>
</div>

<!-- content -->
<div class="content">
	<div class="innerContainer">

		<!-- contentContainer -->
		<div class="contentContainer">

			<!-- TOP FieldSet -->
			<div class="foldSect">
				<div class="tabs">
				  <ul class="tab type2">
					<li><a href="#tabs-1"><span CL='STD_GENERAL'>탭메뉴1</span></a></li>
				  </ul>
				  <div id="tabs-1">
					<div class="section type1">
						<table class="table type1" id=searchArea>
							<colgroup>
								<col />
								<col />
								<col />
								<col />
							</colgroup>
							<tbody>
								<tr>
									<th CL="STD_AMNUID"></th>
									<td>
										<input type="text" name="AMNUID" readonly="readonly"/>
									</td>
								</tr>
								<tr>
									<th CL="STD_PROGID">설명</th>
									<td><input type="text" name="MENUID" UIInput="S,SHPROGM"  validate="required" /></td>
								</tr>
							</tbody>
						</table>
					</div>
				  </div>
				</div>
			</div>
			
		<!-- //contentContainer -->
	    
	    </div>
	</div>
</div>
<!-- //content -->
</body>
</html>