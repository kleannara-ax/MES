<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		setTopSize(800);
	 	gridList.setGrid({
	    	id : "gridList",
			editable : true,
			module : "System",
			command : "LG02"
		}); 
	});
	
	function searchList(){
		var param = inputList.setRangeParam("searchArea");
		
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
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

<!-- content -->
<div class="content">
	<div class="innerContainer">

		<!-- contentContainer -->
		<div class="contentContainer">

			<!-- TOP FieldSet -->
			<div class="foldSect" id="foldSect">
				<div class="tabs">
				  <ul class="tab type2">
					<li><a href="#tabs-1"><span CL='STD_SELECTOPTIONS'></span></a></li>
				  </ul>
				  <div id="tabs-1">
					<div class="section type1">
						<table class="table type1" id="searchArea">
							<colgroup>
								<col />
								<col />
								<col />
								<col />
								<col />
								<col />
							</colgroup>
							<tbody>
								<tr>
								<th CL="STD_LOGDAT">이력일자</th>
									<td>
										<input type="text" name="SL.LOGDAT" UIInput="R" UIFormat="C N" />
									</td>
								</tr>
								<tr>
									<th CL="STD_LOGTYP">이력유형</th>
									<td>
										<select Combo="System,LOGTYP_PRO_COMBO" name="LOGTYP" validate="required" style="width:160px">
											<option value="">------- 선택 -------</option>
										</select>
									</td>
								</tr>
								<tr>
									<th CL="STD_LOGUSR">사용자ID</th>
									<td>
										<input type="text" name="SL.LOGUSR" UIInput="R,SHUSRMA" size="8px" />
									</td>
								</tr>
								<tr>
									<th CL="STD_LOGUNM">사용자명</th>
									<td>
										<input type="text" name="US.NMLAST" UIInput="R"  validate="required"/>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				  </div>
				</div>
			</div>
			
			<!-- BOTTOM FieldSet -->
			<div class="bottomSect" style="top:200px;">
				<button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button>
				<div class="tabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span CL='STD_LIST'></span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableBody">
									<table>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GH="40 STD_NUMBER" GCol="rownum">번호</td>
												<td GH="100 STD_LOGDAT" GCol="text,LOGDAT" GF="C">이력일자</td>
												<td GH="100 STD_LOGTIM" GCol="text,LOGTIM" GF="T">로그인시간</td>
												<td GH="100 STD_LOGTYP" GCol="text,LOGTYP">로그타입</td>
												<td GH="100 STD_LOGTNM" GCol="text,LOGTNM">로그타입명</td>
												<td GH="100 STD_LOGUSR" GCol="text,LOGUSR">로그사용자ID</td>
												<td GH="100 STD_LOGUNM" GCol="text,NMLAST">로그사용자명</td>
												<td GH="100 STD_LOGIPA" GCol="text,LOGIPA">로그IP</td>
												<td GH="100 STD_PROGID" GCol="text,PROGID">이력일자</td>
												<td GH="100 STD_PROGNM" GCol="text,PROGNM">이력일자</td>
											</tr>
										</tbody>
									</table>
								</div>
							</div>
							<div class="tableUtil">
								<div class="leftArea">
									<button type="button" GBtn="find"></button>
									<button type="button" GBtn="sortReset"></button>
									<button type="button" GBtn="copy"></button>
									<button type="button" GBtn="layout"></button>
									<button type="button" GBtn="total"></button>
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
		</div>
		<!-- //contentContainer -->
	</div>
</div>
<!-- //content -->
<%@ include file="/common/include/bottom.jsp" %>
</body>
</html>