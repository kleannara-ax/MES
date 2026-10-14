<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/popHead.jsp" %>
<%@ include file="/aprove/include/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			module : "System",
			command : "SHLPI"
	    });
		
		gridList.setGrid({
	    	id : "gridListAprov",
			module : "Aprove",
			command : "FWAPRI0010"
	    });
		
		searchList();
	});
	
	function searchList(){
		var param = new DataMap();
		param.put("SHLPKY", "<%=LINKKEY%>");
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
		
		param.put("APRKEY", "<%=APRKEY%>");
		gridList.gridList({
	    	id : "gridListAprov",
	    	param : param
	    });
	}
	
	function aproveAfterEvent(aproveType, successType){
		// aproveType[A,R,D] Approve, Return, Delete
		commonUtil.debugMsg("aproveAfterEvent : ", arguments);
	}
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<%@ include file="/aprove/include/button.jsp" %>
	</div>
</div>
<!-- content -->
<div class="content">
		<div class="innerContainer">
			<!-- contentContainer -->
		<div class="contentContainer">
			<!-- TOP FieldSet -->
			<div class="foldSect" id="searchArea">
				<div class="tabs">
				  <ul class="tab type2">
					<li><a href="#tabs-1"><span CL='STD_GENERAL'>탭메뉴1</span></a></li>
				  </ul>
				  <div id="tabs-1">
					<div class="section type1">
						<table class="table type1" id="yh01top">
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
									<th CL="STD_ARDESC">설명</th>
									<td>
										<input type="text" name="ARDESC" style="width: 500px"/>
									</td>
								</tr>
								<tr>
									<th CL="STD_REDESC">설명</th>
									<td>
										<%=REDESC%>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				  </div>
				</div>
			</div>			
			<!-- BOTTOM FieldSet -->
			<div class="bottomSect top" style="top:130px;">
				<div class="tabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span CL='STD_LIST'>탭메뉴1</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableBody">
									<table>
										<tbody id="gridListAprov">
											<tr CGRow="true">
												<td GH="80" GCol="rownum">1</td>
												<td GH="100" GCol="text,APUSER" ></td>
												<td GH="100" GCol="text,APRTYPE" ></td>
												<td GH="100" GCol="text,ARDESC" ></td>
											</tr>
										</tbody>
									</table>
								</div>
							</div>
							<div class="tableUtil">
								<div class="leftArea">

								</div>
								<div class="rightArea">
									<p class="record"></p>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
			<div class="bottomSect bottom">
				<div class="tabs">
					<ul class="tab type2" id="commonMiddleArea">
						<li><a href="#tabs3-1"><span CL='STD_SEARCH'></span></a></li>
					</ul>
					<div id="tabs3-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableBody">
									<table>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GH="80" GCol="rownum">1</td>
												<td GH="80" GCol="text,SHLPKY" GF="S 10"></td>
												<td GH="80" GCol="text,DBFILD" GF="S 20"></td>
												<td GH="80" GCol="text,DDICKY" GF="S 20"></td>
												<td GH="80" GCol="text,INDUSO"></td>
												<td GH="80" GCol="text,POSSOS" GF="S 3"></td>
												<td GH="80" GCol="text,INDNED"></td>
												<td GH="80" GCol="text,RQFLDS"></td>
												<td GH="80" GCol="text,INDULS"></td>
												<td GH="80" GCol="text,POSLIS" GF="S 3"></td>
												<td GH="80" GCol="text,INDRVL"></td>
												<td GH="80" GCol="text,DFVSOS" GF="S 60"></td>
											</tr>
										</tbody>
									</table>
								</div>
							</div>
							<div class="tableUtil">
								<div class="leftArea">

								</div>
								<div class="rightArea">
									<p class="record"></p>
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