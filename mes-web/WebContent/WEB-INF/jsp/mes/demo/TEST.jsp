<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>MES</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
			id : "gridList",
			editable : true,
			pkcol : "WAREKY",
			module : "WmsAdmin",
			command : "WAHMA"
		});
		searchList();
	});
	
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			gridList.gridList({
				id : "gridList",
				param : param
			});
		}
	}
	
	function saveData(){
		var param = dataBind.paramData("searchArea")
		
		if(gridList.validationCheck("gridList", "all")){
			var json = gridList.gridSave({
				id : "gridList",
				param : param
			});
		}
		
		if(json && json.data){
			searchList();
		}
	}
	
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}
	}
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY" />
		<button CB="Save SAVE STD_SAVE" />
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
			<h2 class="tit" CL="STD_SELECTOPTIONS">검색조건</h2>
			<table class="table type1">
				<colgroup>
					<col width="100" />
					<col />
				</colgroup>
				<tbody>
					<tr>
						<th CL="STD_COMPKY">회사</th>
						<td>
							<input type="text" name="COMPKY" value="<%=compky %>" readonly="readonly" />
						</td>
					</tr>
					<tr>
						<th CL="STD_WAREKY">거점</th>
						<td>
							<input type="text" name="WAREKY" UIInput="R,SHWAHMA" value="<%wareky %>"/>
							<input type="text" name="WAREKY" UIInput="R,SHWAHMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_DELMAK">삭제</th>
						<td>
							<input type="checkbox" name="DELMAK" value="V" />
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
			<div class="bottomSect type1">
				<div class="tabs"></div>
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span CL='STD_LIST'>탭메뉴1</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								
								<div class="tableBody">
									<table>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GH="40"					GCol="rownum">1</td>
												<td GH="100 STD_COMPKY"		GCol="text,COMPKY" />회사</td>
												<td GH="100 STD_WAREKY"		Gcol="input,WAREKY" />거점</td>
												<td GH="100 STD_NAME01"		GCol="input,NAME01"	GF="S 180" />거점명</td>
												<td GH="100 STD_DELMAK"		GCol="check,DELMAK">삭제</td>
												<td GH="100 STD_NAME02"		GCol="input,NAME02"	GF="S 180" />대표자이름</td>
												<td GH="100 STD_ADDR01"		GCol="input,ADDR01"	GF="S 180" />대표주소</td>
												<td GH="100 STD_POSTCD"		GCol="input,POSTCD"	GF="S 30" />우편번호</td>
												<td GH="100 STD_NATNKY"		GCol="select,NATNKY" /><select CommonCombo="NATNKY"></select>국가</td>
												<td GH="100 STD_VATREG"		GCol="input,VATREG"	GF="S 20" />사업자등록번호</td>
												<td GH="100 STD_FAXTL1"		GCol="input,FAXTL1"	GF="S 20" />팩스번호</td>
 												<td GH="100 STD_TELN01"		GCol="input,TELN01"	GF="S 20"  validate="tel(GRID_COL_TELN01_*)"/>전화번호</td>
<!--  												<td GH="100 STD_TELN01"		GCol="input,TELN01"	GF="S 20"/>전화번호</td> -->
												
												<td GH="100 STD_WADN01"		GCol="input,WADN01"	GF="S 60" />관리자명</td>
												<td GH="100 STD_WADT01"		GCol="input,WADT01"	GF="S 60" />관리자연락처</td>
												<td GH="100 STD_WADM01"		GCol="input,WADM01"	GF="S 60"  validate="email(GRID_COL_WADM01_*)"/>e-Mail</td>
												<td GH="100 STD_CREDAT"		GCol="text,CREDAT"	GF="D" />생성일자</td>
												<td GH="100 STD_CRETIM"		GCol="text,CRETIM"	GF="T" />생성시간</td>
												<td GH="100 STD_CREUSR"		GCol="text,CREUSR"	/>생성자ID</td>
												<td GH="100 STD_CUSRNM"		GCol="text,CUSRNM"	/>생성자명</td>
												<td GH="100 STD_LMODAT"		GCol="text,LMODAT"	GF="D" />수정일자</td>
												<td GH="100 STD_LMOTIM"		GCol="text,LMOTIM"	GF="T" />수정시간</td>
												<td GH="100 STD_LMOUSR"		GCol="text,LMOUSR"	/>수정자ID</td>
												<td GH="100 STD_LUSRNM"		GCol="text,LUSRNM"	/>수정자명</td>
											</tr>
										</tbody>
									</table>
								</div>
							</div>
							<div class="tableUtil">
								<div class="leftArea">
									<button type="button" GBtn="find"></button>
									<button type="button" GBtn="up"></button>
									<button type="button" GBtn="down"></button>
									<button type="button" GBtn="add"></button>
									<button type="button" GBtn="delete"></button>
									<button type="button" GBtn="layout"></button>
									<button type="button" GBtn="excel"></button>
									<button type="button" GBtn="sortReset"></button>
									<button type="button" GBtn="copy"></button>
								</div>
							</div>
							<div class="rightArea">
								<p class="record" GInfoArea="true"></p>
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