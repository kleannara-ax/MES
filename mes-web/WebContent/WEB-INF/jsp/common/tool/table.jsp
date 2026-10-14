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
		
	});
	
	function searchList(){
		var param = inputList.setRangeParam("searchArea");
		
		var json = netUtil.sendData({
			url : "/common/json/COLUMN_LIST.data",
			param : param
		});
		
		searchOpen(false);
		
		$("#selectArea").html(json.select);
		$("#insertArea").html(json.insert);
		$("#updateArea").html(json.update);
		$("#deleteArea").html(json.del);
		$("#beanArea").html(json.bean);
		$("#rscubemapArea").html(json.rscubemap);
		$("#rsmapArea").html(json.rsmap);
		$("#insertBlank").html(json.insertBlank);
	}
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button class="button type1 last" type="button" onclick="searchList()"><img src="/common/images/top_icon_03.png" alt="Search" /></button>
	</div>
	<div class="util2">
		<button class="button type2" id="showPop" type="button"><img src="/common/images/ico_btn4.png" alt="List" /></button>
	</div>
</div>

<!-- searchPop -->
<div class="searchPop" id="searchArea">
	<button type="button" class="closer">X</button>
	<div class="searchInnerContainer">
		<p class="searchBtn"><input type="submit" class="button type1 widthAuto" value="검색"  onclick="searchList()" CL="BTN_DISPLAY"/></p>
		<div class="searchInBox">
			<h2 class="tit" CL="STD_SELECTOPTIONS">검색조건</h2>
			<table class="table type1">
				<colgroup>
					<col width="100" />
					<col />
				</colgroup>
				<tbody>
					<tr>
						<th>TABLE</th>
						<td>
							<select name="table" Combo="Common,TABLE">
								<option value="">선택</option>
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
						<li><a href="#tabs1-1"><span>select</span></a></li>
						<li><a href="#tabs1-2"><span>insert</span></a></li>
						<li><a href="#tabs1-3"><span>update</span></a></li>
						<li><a href="#tabs1-4"><span>delete</span></a></li>
						<li><a href="#tabs1-5"><span>bean</span></a></li>
						<li><a href="#tabs1-6"><span>rsmap</span></a></li>
						<li><a href="#tabs1-7"><span>rscubemap</span></a></li>
						<li><a href="#tabs1-8"><span>insert blank</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="searchBox">
							<xmp id="selectArea"></xmp>
						</div>
					</div>
					<div id="tabs1-2">
						<div class="searchBox">
							<xmp id="insertArea"></xmp>
						</div>
					</div>
					<div id="tabs1-3">
						<div class="searchBox">
							<xmp id="updateArea"></xmp>
						</div>
					</div>
					<div id="tabs1-4">
						<div class="searchBox">
							<xmp id="deleteArea"></xmp>
						</div>
					</div>
					<div id="tabs1-5">
						<div class="searchBox">
							<xmp id="beanArea"></xmp>
						</div>
					</div>
					<div id="tabs1-6">
						<div class="searchBox">
							<xmp id="rsmapArea"></xmp>
						</div>
					</div>
					<div id="tabs1-7">
						<div class="searchBox">
							<xmp id="rscubemapArea"></xmp>
						</div>
					</div>
					<div id="tabs1-8">
						<div class="searchBox">
							<xmp id="insertBlank"></xmp>
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