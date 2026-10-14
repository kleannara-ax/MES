<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/head.jsp" %>
<%
	String[] cols = (String[])request.getAttribute("cols");
	Boolean result = (Boolean)request.getAttribute("result");
	if(result == null){
		result = true;
	}
%>
<script type="text/javascript">
	var result = <%=result%>; 
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
	    	url : "/common/json/SQL_GRID_DATA_LIST.data",
	    	colorType : true
	    });
		
		<%
			if(cols != null){
		%>
		netUtil.send({
			bindType : "grid",
			bindId : "gridList",
			sendType : "list",
			url : "/common/json/EXCEL_GRID_DATA_LIST.data"
		});
		<%
			}
		%>

		if(result == false){
			uiList.setActive("Save", false);
		}
	});
	
	function searchList(){
		if(validate.check("searchArea")){
			$("#excelUp").submit();
		}
	}
	
	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}
	}
	
	function gridListRowBgColorChange(gridId, rowNum){
		if(gridId == "gridList"){
			if(gridList.getColData(gridId, rowNum, "RESULT_CODE") == "E"){
				return configData.GRID_COLOR_BG_YELLOW_CLASS;
			}
		}
	}
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY"></button>
		<button CB="Save SAVE STD_SAVE"></button>
	</div>
	<div class="util3">
		<button class="button type2" id="showPop" type="button"><img src="/common/images/ico_btn4.png" alt="List" /></button>
	</div>
</div>

<!-- searchPop -->
<div class="searchPop" id="searchArea">
	<button type="button" class="closer">X</button>
	<div class="searchInnerContainer">
		<p class="util">
			<button CB="Search SEARCH BTN_DISPLAY"></button>
		</p>
		<div class="searchInBox">
			<table class="table type1">
				<colgroup>
					<col width="30" />
					<col />
				</colgroup>
				<tbody>
					<tr>
						<th>EXCEL</th>
						<td>
							<form action="/common/grid/excel/fileUp/data.data" enctype="multipart/form-data" method="post" id="excelUp">
								<input type="hidden" name="beanName" value="commonService" />
								<input type="hidden" name="funcName" value="excelDataValidation" />
								<input type="file" name="excelFile" validate="required"/>
							</form>
						</td>
					</tr>					
				</tbody>
			</table>
		</div>
	</div>
</div>
<!-- //searchPop -->
<!-- content -->
<div class="content">
	<div class="innerContainer">
		<!-- contentContainer -->
		<div class="contentContainer">
			<div class="bottomSect type1">
				<div class="tabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span CL='STD_SEARCH'>탭메뉴1</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableBody">
									<table>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GH="40" GCol="rownum">1</td>
												<td GH="40" GCol="text,RESULT_CODE"></td>
												<td GH="200" GCol="text,RESULT_MSG"></td>
												<%
													if(cols != null){
														for(int i=0;i<cols.length;i++){
												%>
												<td GH="100" GCol="text,<%=cols[i]%>"></td>
												<%
														}
													}
												%>											
											</tr>									
										</tbody>
									</table>
								</div>
							</div>							
							<div class="tableUtil">
								<div class="leftArea">
									<button type="button" GBtn="find"></button>
									<button type="button" GBtn="filter"></button>
									<button type="button" GBtn="sortReset"></button>
								</div>
								<div class="rightArea">
									<p class="record" GInfoArea="true">0 Record</p>
								</div>
							</div>
						</div>
					</div>					
				</div>
			</div>
		</div>
		<!-- //contentContainer -->
	</div>
</div>
<!-- //content -->
<%@ include file="/common/include/bottom.jsp" %>
</body>
</html>