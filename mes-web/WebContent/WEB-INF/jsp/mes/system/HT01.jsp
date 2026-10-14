<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/head.jsp"%>
<script type="text/javascript">
	var credat ="";
	$(document).ready(function() { 
		gridList.setGrid({
			id : "gridList",
			editable : false,
			module : "System",
			command : "USER_LOGIN",
			validation : "CREDAT"
		});
	}); 
	

	function searchList() {
		if(validate.check("searchArea")){	
			var param = inputList.setRangeParam("searchArea");
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}

	function commonBtnClick(btnName){
		if(btnName == "Search"){
			searchList();
		}
	}
	

</script>
</head>
<body>
	<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY"></button>
	</div>
	</div>
	<div class="util2">
		<button class="button type2" id="showPop" type="button"><img src="/common/images/ico_btn4.png" alt="List" /></button>
	</div>

	<!-- searchPop -->
	<div class="searchPop" id="searchArea">
		<button type="button" class="closer">X</button>
		<div class="searchInnerContainer">
			<p class="util">
				<button CB="Search SEARCH BTN_DISPLAY"></button>
				<button CB="GetVariant GETVARIANT BTN_GETVARIANT"></button>
				<button CB="SaveVariant SAVEVARIANT BTN_SAVEVARIANT"></button>
			</p>
			
			<div class="searchInBox">
				<h2 class="tit" CL="STD_SELECTOPTIONS">검색조건</h2>
				<table class="table type1">
					<colgroup>
						<col width="100" />
						<col />
					</colgroup>
					<tbody>
						<tr>
							<th CL="STD_LOGDAT">로그인일자</th>
							<td><input type="text" name="L.CREDAT" UIInput="R"  validate="required,VALID_M4000" UIFormat="C Y"/></td>
						</tr>
						<tr>
							<th CL="STD_USERID">사용자 ID</th>
							<td><input type="text" name="L.USERID" UIInput="R,SHUSRMA" /></td>
						</tr>
						<tr>
							<th CL="STD_NMLAST">이름</th>
							<td><input type="text" name="L.NMLAST" UIInput="R" /></td>
						</tr>
						<tr>
							<th CL="STD_MODULE">모듈</th>
							<td> <select CommonCombo="MODULE" name = "MODULE" style="width: 155px">
								    <option value = "" SELECTED>All</option>
								 </select> 
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
									<div class="tableHeader">
										<table>
											<colgroup>
												<col width="40" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />	
												<col width="120" />	
											</colgroup>
											<thead>
												<tr>
													<th CL='STD_NUMBER'></th>
													<th CL='STD_MODULE'></th>
													<th CL='STD_LOGTYP'></th>
													<th CL='STD_LOGDAT'></th>
													<th CL='STD_LOGTIM'></th>
													<th CL='STD_USERID'></th>
													<th CL='STD_NMLAST'></th>
													<th CL='STD_USERIP'></th>
												</tr>
											</thead>
										</table>
									</div>
									<div class="tableBody">
										<table>
											<colgroup>
												<col width="40" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
											</colgroup>
											<tbody id="gridList">
												<tr CGRow="true">
													<td GCol="rownum">1</td>
													<td GCol="text,MODULE"></td>
													<td GCol="text,LOGTYNM"></td>
													<td GCol="text,CREDAT" GF="D 8"></td>
													<td GCol="text,CRETIM" GF="T 6"></td>
													<td GCol="text,USERID"></td>
													<td GCol="text,NMLAST"></td>
													<td GCol="text,USERIP"></td>
												</tr>                
											</tbody>                 
										</table>
									</div>
								</div>
								<div class="tableUtil">
								<div class="leftArea">
									<button type="button" GBtn="find"></button>
									<button type="button" GBtn="sortReset"></button>
									<button type="button" GBtn="layout"></button>
									<button type="button" GBtn="excel"></button>
								</div>
								<div class="rightArea">
									<p class="record" GInfoArea="true"></p>
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