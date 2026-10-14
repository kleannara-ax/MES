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
		gridList.setGrid({
	    	id : "gridList",
	    	name : "gridList",
			editable : true,
			pkcol : "FWDKEY",
			module : "TmsAdmin",
			command : "SHCPN",
			validation : "FWDKEY,WADN01"
	    });
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
		var param = dataBind.paramData("searchArea");
		var json = gridList.gridSave({
	    	id : "gridList",
	    	param : param,
	    });
		
		if(json && json.data){
			searchList();
		}			
	}


 	function commonBtnClick(btnName){
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}else if(btnName == "Create"){
			creatList();
		}
	}
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY">
		</button>
		<button CB="Save SAVE STD_SAVE">
		</button>
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
						<th CL="STD_COMPKY">회사</th>
						<td>
							<input type="text" name="COMPKY" value="<%=compky%>"  readonly="readonly" style="width:110px" />  <!-- UIInput="S,SHCOMMA"   -->
						</td>
					</tr>
					<tr>
						<th CL="STD_FWDKEY">운송사</th>
						<td>
							<input type="text" name="FWDKEY" UIInput="R,SHCPN" />
						</td>
					</tr>
					<tr>
						<th CL="STD_WADN01">관리자</th>
						<td>
							<input type="text" name="WADN01" UIInput="R,SHWADN01" />
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
											<col width="80" />
											<col width="100" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="80" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'></th>
												<th  CL='STD_PGRC04'>운송사</th>
												<th  CL='STD_DRIVNM'>운송사명</th>												
												<th  CL='STD_GROUP5'>주소</th>
												<th  CL='STD_NATNKY'>국가</th>
												<th  CL='STD_VATREG'>사업자등록번호</th>
												<th  CL='STD_FAXTL1'>팩스번호</th>
												<th  CL='STD_TELN01'>전화번호</th>
												<th  CL='STD_WADM01'>e-mail</th>
												<th  CL='STD_WADN01'>관리자명</th>
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="40" />
											<col width="80" />
											<col width="100" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="150" />
											<col width="80" />
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GCol="rownum">1</td>											
												<td GCol="input,FWDKEY" validate="required"></td>
												<td GCol="input,FWDNME">운송사명</th>												
												<td GCol="input,ADDR01" GF="S 180">주소</th>
												<td GCol="select,NATNKY">
													<select CommonCombo="NATNKY" name="NATNKY" id="NATNKY" disabled="disabled">국가</select>
												</td>
												<td GCol="input,VATREG" GF="S 20">사업자등록번호</th>
												<td GCol="input,FAXTL1" GF="S 20">팩스번호</th>
												<td GCol="input,TELN01" validate="tel(GRID_COL_TELN01_*)" GF="S 20">전화번호</th>
												<td GCol="input,WADM01" validate="email(GRID_COL_WADM01_*)" GF="S 60">e-mail</th>
												<td GCol="input,WADN01" GF="S 60">관리자명</th>															
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
									<button type="button" GBtn="add"></button>
									<button type="button" GBtn="delete"></button>
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