<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/head.jsp"%>
<script type="text/javascript">
	$(document).ready(function() {
		gridList.setGrid({
			id : "gridList",
			editable : true,
			pkcol : "DDICKY",
			module : "System",
			command : "DATADIC"
		});
		
		searchList();
	});

	function searchList() {
		//var param = dataBind.paramData("searchArea");
		var param = inputList.setRangeParam("searchArea");
		gridList.gridList({
			id : "gridList",
			param : param
		});
	}

	function saveData(){
		var modCnt = gridList.getModifyRowCount("gridList");
		
		if(modCnt == 0){
			commonUtil.msgBox("MASTER_M0545");
			return;
		}
		
		if(gridList.validationCheck("gridList", "modify")){
			var param = dataBind.paramData("searchArea");
			var json = gridList.gridSave({
		    	id : "gridList",
		    	param : param
		    });
			
			if(json && json.data){
				searchList();
			}	
		}
	}

	function gridListEventRowAddBefore(gridId, rowNum) {
		var param = inputList.setRangeParam("searchArea");
		var datfty = param.get("DATFTY");

		var newData = new DataMap();
		newData.put("DATFTY", datfty);

		return newData;
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
			<button CB="Search SEARCH BTN_DISPLAY">조회</button>
			<button CB="Save SAVE STD_SAVE">저장</button>
		</div>
		<!-- <div class="util2">
			<button class="button type2" id="showPop" type="button">
				<img src="/common/images/ico_btn4.png" alt="List" />
			</button>
		</div> -->
	</div>

	<!-- searchPop -->
	<!-- 
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
							<th CL="STD_DDICKY">DB 필드 사전 키</th>
							<td><input type="text" name="DDICKY" UIInput="S,SHDDICKY" /></td>
						</tr>
						<tr>
							<th CL="STD_DATFTY">데이터 타입</th>
							<td>
								<select Combo="System,DATFTYCOMBO" name="DATFTY"></select>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>
	</div>
	-->
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
							<!-- <li><a href="#tabs1-2"><span CL='STD_DETAIL'>탭메뉴1</span></a></li> -->
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
												<col width="350" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<!-- <col width="120" />
												<col width="120" /> -->
											</colgroup>
											<thead>
												<tr>
													<th CL='STD_NUMBER'></th>
													<th CL='STD_DDICKY'></th>
													<th CL='STD_DATFTY'></th>
													<th CL='STD_SHORTX'></th>
													<th CL='STD_DBFILD'></th>
													<th CL='STD_PDATTY'></th>
													<th CL='STD_OBJETY'></th>
													<th CL='STD_DBLENG'></th>
													<th CL='STD_DBDECP'></th>
													<th CL='STD_OUTLEN'></th>
													<th CL='STD_SHLPKY'></th>
													<th CL='STD_FLDALN'></th>
													<th CL='STD_LABLGR'></th>
													<th CL='STD_LABLKY'></th>
													<th CL='STD_LBTXTY'></th>
													<th CL='STD_UCASOL'></th>
													<th CL='STD_CREDAT'></th>
													<th CL='STD_CRETIM'></th>
													<th CL='STD_CREUSR'></th>
													<th CL='STD_CUSRNM'></th>
													<th CL='STD_LMODAT'></th>
													<th CL='STD_LMOTIM'></th>
													<th CL='STD_LMOUSR'></th>
													<th CL='STD_LUSRNM'></th>
													<!-- <th CL='STD_INDBZL'></th>
													<th CL='STD_INDARC'></th> -->
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
												<col width="350" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<!-- <col width="120" />
												<col width="120" /> -->
											</colgroup>
											<tbody id="gridList">
												<tr CGRow="true">
													<td GCol="rownum">1</td>
													<td GCol="input,DDICKY" validate="required,SYSTEM_M0102" GF="S 20"></td>
													<td GCol="select,DATFTY" validate="required,MASTER_M0434">
														<select Combo="System,DATFTYCOMBO">
															<option value=""></option>
														</select>
													</td>
													<td GCol="input,SHORTX" GF="S 180"></td>
													<td GCol="input,DBFILD" GF="S 20"></td>
													<td GCol="input,PDATTY" GF="S 4"></td>
													<td GCol="select,OBJETY" validate="required,MASTER_M0434">
														<select CommonCombo="OBJETY" name="OBJETY">
															<option value=""></option>
														</select>
													</td>
													<td GCol="input,DBLENG" GF="N 6"></td>
													<td GCol="input,DBDECP" GF="N 3"></td>
													<td GCol="input,OUTLEN" GF="N 6"></td>
													<td GCol="input,SHLPKY,SHSHLPH" GF="S 20"></td>
													<td GCol="input,FLDALN" GF="S 4"></td>
													<td GCol="input,LABLGR,SHLBLGR" GF="S 10"></td>
													<td GCol="input,LABLKY,SHLBLKY" GF="S 20"></td>
													<td GCol="input,LBTXTY" GF="S 4"></td>
													<td GCol="check,UCASOL"></td>
													<td GCol="text,CREDAT" GF="D"></td>
													<td GCol="text,CRETIM" GF="T"></td>
													<td GCol="text,CREUSR" ></td>
													<td GCol="text,CUSRNM"></td>
													<td GCol="text,LMODAT" GF="D"></td>
													<td GCol="text,LMOTIM" GF="T"></td>
													<td GCol="text,LMOUSR"></td>
													<td GCol="text,LUSRNM"></td>
													<!-- <td GCol="input,INDBZL" GF="S 1"></td>
													<td GCol="input,INDARC" GF="S 1"></td> -->
												</tr>
											</tbody>
										</table>
									</div>
								</div>
								<div class="tableUtil">
									<div class="leftArea">
										<button type="button" GBtn="find"></button>
										<button type="button" GBtn="sortReset"></button>
										<button type="button" GBtn="add"></button>
										<button type="button" GBtn="delete"></button>
										<button type="button" GBtn="layout"></button>
										<button type="button" GBtn="total"></button>
										<button type="button" GBtn="excel"></button>										
									</div>
									<div class="rightArea">
										<p class="record" GInfoArea="true">17 Record</p>
									</div>
								</div>
							</div>
						</div>
						<!-- <div id="tabs1-2">
							<div class="section type1" style="overflow-y: scroll;">
								<div class="controlBtns type2" GNBtn="gridList">
									<a href="#"><img src="/common/images/btn_first.png" alt="" /></a>
									<a href="#"><img src="/common/images/btn_prev.png" alt="" /></a>
									<a href="#"><img src="/common/images/btn_next.png" alt="" /></a>
									<a href="#"><img src="/common/images/btn_last.png" alt="" /></a>
								</div>
								<br />
								<div class="searchInBox">
									<h2 class="tit" CL="STD_SELECTOPTIONS">검색조건</h2>
									<table class="table type1">
										<colgroup>
											<col width="8%" />
											<col />
											<col />
											<col />
											<col />
											<col />
										</colgroup>
										<tbody>
											<tr>
												<th CL="STD_DDICKY">DB 필드 사전 키</th>
												<td><input type="text" name="DDICKY" readonly="readonly" UIInput="S"/></td>
											</tr>
											<tr>
												<th CL='STD_DATFTY'>데이터 타입</th>
												<td><select name="DATFTY" Combo="System,DATFTYCOMBO"></select></td>
											</tr>
											<tr>
												<th CL='STD_SHORTX'>설명</th>
												<td>
													<input type="text" name="SHORTX" style="width: 350px;" />
												</td>
											</tr>
											<tr>
												<th CL='STD_DBFILD'>DB 필드 이름</th>
												<td>
													<input type="text" name="DBFILD" />
												</td>
											</tr>
											<tr>
												<th CL='STD_PDATTY'>데이터 타입</th>
												<td>
													<input type="text" name="PDATTY" />
												</td>
											</tr>
											<tr>
												<th CL='STD_OBJETY'>오브젝트 타입</th>
												<td>
													<input type="text" name="OBJETY" />
												</td>
											</tr>
											<tr>
												<th CL='STD_DBLENG'>DB 길이</th>
												<td>
													<input type="text" name="DBLENG" />
												</td>
											</tr>
											<tr>
												<th CL='STD_DBDECP'>소수점</th>
												<td>
													<input type="text" name="DBDECP" />
												</td>
											</tr>
											<tr>
												<th CL='STD_OUTLEN'>Output 길이</th>
												<td>
													<input type="text" name="OUTLEN" />
												</td>
											</tr>
											<tr>
												<th CL='STD_SHLPKY,3'>서치헬프 : 헬프 오브젝트키</th>
												<td>
													<input type="text" name="SHLPKY" UIInput="S,SHSHLPH" />
												</td>
											</tr>
											<tr>
												<th CL='STD_FLDALN'>필드 정렬</th>
												<td>
													<input type="text" name="FLDALN" />
												</td>
											</tr>
											<tr>
												<th CL='STD_LABLGR'>라벨 그룹</th>
												<td>
													<input type="text" name="LABLGR" UIInput="S,SHLBLGR" />
												</td>
											</tr>
											<tr>
												<th CL='STD_LABLKY'>라벨 키</th>
												<td>	
													<input type="text" name="LABLKY" UIInput="S,SHLBLKY" />
												</td>
											</tr>
											<tr>
												<th CL='STD_LBTXTY'>라벨명 타입</th>
												<td>
													<input type="text" name="LBTXTY" />
												</td>
											</tr>
											<tr>
												<th CL='STD_UCASOL'>대문자만 허용</th>
												<td>
													<input type="checkbox" name="UCASOL" />
												</td>
											</tr>
										</tbody>
									</table>
								</div>
								<br />
								<div class="searchInBox">
									<h2 class="tit" CL="STD_MANAGE">관리</h2>
									<table class="table type1">
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
												<th CL="STD_CREATIONDATETIME">생설일시</th>
												<td>
													<input type="text" class="inputText width1" name="CREDAT" /> 
													<input type="text" class="inputText width1" name="CRETIM" />
												</td>
												<th CL="STD_LASTMODIFIEDDATETIME">수정일시</th>
												<td>
													<input type="text" class="inputText width1" name="LMODAT" /> 
													<input type="text" class="inputText width1" name="LMOTIM" />
												</td>
											</tr>
											<tr>
												<th CL="STD_CREUSR">생성자</th>
												<td><input type="text" name="CREUSR" /> <input
													type="text" name="CUSRNM" disabled="disabled" /></td>
											</tr>

											<tr>
												<th CL="STD_LMOUSR">수정자</th>
												<td>
													<input type="text" name="LMOUSR" /> 
													<input type="text" name="LUSRNM" disabled="disabled" />
												</td>
											</tr>
										</tbody>
									</table>
								</div>
							</div>
						</div> -->
					</div>
				</div>
				<!-- //contentContainer -->
			</div>
		</div>
		<!-- //content -->
		<%@ include file="/common/include/bottom.jsp"%>
</body>
</html>