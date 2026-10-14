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
			pkcol : "USERID",
			module : "System",
			command : "USER",
			bindArea : "tabs1-2",
			validation : "UROLKY,MENUKY"
		});
	}); 

	function searchList() {
		//var param = dataBind.paramData("searchArea");
	
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			//alert(param);
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
		$('.tabs').tabs("option","active",0);
	}

	function saveData() {
		if(gridList.validationCheck("gridList", "modify")){
			var list = gridList.getModifyList("gridList");
			var param = dataBind.paramData("searchArea");
			var paramR = new DataMap();
			paramR.put("list", list);
	
			var json = gridList.gridSave({
			    id : "gridList",
			    param : param
			});
			   
			if(json && json.data){
				json = netUtil.sendData({
				url : "/wms/system/json/UI01.data",
					param : paramR
				});  
				searchList();		
			}
		}
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId=="gridList" && colName=="UROLKY"){
			if(colValue != ""){
				var param = new DataMap();
				param.put("UROLKY",colValue);
				var json = netUtil.sendData({
					module : "System",
					command : "UROval",
					sendType : "map",
					param : param
				});
				
			 if(json.data["CNT"] < 1){
					commonUtil.msgBox("SYSTEM_M0086", colValue);
					gridList.setColValue("gridList", rowNum, "UROLKY", "");
				}
			}
			
		}else if(gridId=="gridList" && colName=="USERID"){
			if(colValue != ""){
				var param = new DataMap();
				param.put("USERID",colValue);
				var json = netUtil.sendData({
					module : "System",
					command : "USERval",
					sendType : "map",
					param : param
				});
				if(json.data["CNT"]>0){
					commonUtil.msgBox("SYSTEM_M0055", colValue);
					gridList.setColValue("gridList", rowNum, "USERID", "");
				}
			}
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
	
	function checkPv(colValue, rowNum, colName){
		var rowData = gridList.getRowData("gridList", rowNum);
		if(rowData.get("USERG1") == "PV" && $.trim(colValue) == ""){
			gridList.setColFocus("gridList", rowNum, colName);
			return false;
		}
		return true;
	}
</script>
</head>
<body>
	<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY">
		</button>
		<button CB="Save SAVE STD_SAVE ">
		</button>
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
				<!-- <button CB="GetVariant GETVARIANT BTN_GETVARIANT"></button>
				<button CB="SaveVariant SAVEVARIANT BTN_SAVEVARIANT"></button> -->
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
							<th CL="STD_USERID">사용자 ID</th>
							<td><input type="text" name="U.USERID" UIInput="R,SHUSRMA" /></td>
						</tr>
						<tr>
							<th CL="STD_NMLAST">이름</th>
							<td><input type="text" name="NMLAST" UIInput="R" /></td>
						</tr>
						<tr>
							<th CL="STD_NMFIRS">관련업무</th>
							<td><input type="text" name="NMFIRS" UIInput="R" ></td>
						</tr>
						<tr>
							<th CL="STD_MENUKY">메뉴키</th>
							<td><input type="text" name="MENUKY" UIInput="R,SHMNUDF" /></td>
						</tr>
						<tr>
							<th CL="STD_DEPART">부서</th>
							<td><input type="text" name="DEPART" UIInput="R,SHDOCTP" /></td>
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
							<li><a href="#tabs1-2"><span CL='STD_DETAIL'>탭메뉴2</span></a></li>
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
												<col width="450" />
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
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" />
												<!-- <col width="120" /> -->
												<!-- <col width="120" />
												<col width="120" />
												<col width="120" />
												<col width="120" /> -->
											</colgroup>
											<thead>
												<tr>
													<th CL='STD_NUMBER'></th>
													<th CL='STD_USERID'></th>
													<th CL='STD_PASSWD'></th>
													<th CL='STD_DELMAK'></th>
													<th CL='STD_UROLKY'></th>
													<th CL='STD_NMLAST'></th>
													<th CL='STD_NMFIRS'></th>
													<th CL='STD_ADDR01'></th>
													<th CL='STD_ADDR02'></th>
													<th CL='STD_ADDR03'></th>
													<th CL='STD_ADDR04'></th>
													<th CL='STD_ADDR05'></th>
													<th CL='STD_CITY01'></th>
													<th CL='STD_REGN01'></th>
													<th CL='STD_POSTCD'></th>
													<th CL='STD_NATNKY'></th>
													<th CL='STD_TELN01'></th>
													<th CL='STD_TELN02'></th>
													<th CL='STD_TELN03'></th>
													<th CL='STD_TLEXT1'></th>
													<th CL='STD_FAXTL1'></th>
													<th CL='STD_FAXTL2'></th>
													<th CL='STD_POBOX1'></th>
													<th CL='STD_POBPC1'></th>
													<th CL='STD_EMAIL1'></th>
													<th CL='STD_EMAIL2'></th>
													<th CL='STD_COMPKY'></th>
													<th CL='STD_DEPART'></th>
													<th CL='STD_EMPLID'></th>
													<th CL='STD_USERG1'></th>
													<th CL='STD_USERG2'></th>
													<th CL='STD_USERG3'></th>
													<th CL='STD_USERG4'></th>
													<th CL='STD_USERG5'></th>
													<th CL='STD_LANGKY'></th>
													<th CL='STD_DATEFM'></th>
													<th CL='STD_DATEDL'></th>
													<th CL='STD_DECPFM'></th>
													<th CL='STD_LLOGID,2'></th>
													<th CL='STD_LLOGIT,2'></th>
													<th CL='STD_LLOGOD,2'></th>
													<th CL='STD_LLOGOT,2'></th>
													<th CL='STD_MENUKY'></th>
													<!-- <th CL='STD_LLOGWH'></th>
													<th CL='STD_TIMFMT'></th> -->
													<th CL='STD_CURRFM'></th>
													<!-- <th CL='STD_RECNTF'></th> -->
													<!-- <th CL='STD_PGSIZE'></th> -->
													<th CL='STD_CREDAT'></th>
													<th CL='STD_CRETIM'></th>
													<th CL='STD_CREUSR'></th>
													<th CL='STD_CUSRNM'></th>
													<th CL='STD_LMODAT'></th>
													<th CL='STD_LMOTIM'></th>
													<th CL='STD_LMOUSR'></th>
													<th CL='STD_LUSRNM'></th>
													<!-- <th CL='STD_INDARC'></th> -->
													
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
												<col width="450" />
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
													<td GCol="input,USERID,SHUSRMA" validate="required,MASTER_M0001"  GF="S 200" ></td>
													<td GCol="input,PASSWD" validate="required,COMMON_M0034" GF="S 200" ></td>
													<td GCol="check,DELMAK"></td>
													<td GCol="input,UROLKY,SHROLDF" GF="S 200" ></td>
													<td GCol="input,NMLAST" GF="S 60" validate="required,SYSTEM_M0100"></td>
													<td GCol="input,NMFIRS" GF="S 60" ></td>
													<td GCol="input,ADDR01" GF="S 180" ></td>
													<td GCol="input,ADDR02" GF="S 180" ></td> 
													<td GCol="input,ADDR03" GF="S 180" ></td>
													<td GCol="input,ADDR04" GF="S 180" ></td>
													<td GCol="input,ADDR05" GF="S 180" ></td>
													<td GCol="input,CITY01" GF="S 180" ></td>
													<td GCol="input,REGN01" GF="S 12" ></td>
													<td GCol="input,POSTCD" GF="S 30" ></td>
													<td GCol="select,NATNKY">
														<select Combo="System,NATNKYCOMBO"></select>
													</td>
													<td GCol="input,TELN01" GF="S 20" validate="tel(GRID_COL_TELN01_*)"></td>
													<td GCol="input,TELN02" GF="S 20" validate="tel(GRID_COL_TELN02_*)"></td>
													<td GCol="input,TELN03" GF="S 20" validate="tel(GRID_COL_TELN03_*)"></td>
													<td GCol="input,TLEXT1" GF="S 10"></td>
													<td GCol="input,FAXTL1" GF="S 20" validate="tel(GRID_COL_TELN01_*)"></td>
													<td GCol="input,FAXTL2" GF="S 20"></td>
													<td GCol="input,POBOX1" GF="S 10" ></td>
													<td GCol="input,POBPC1" GF="S 10" ></td>
													<td GCol="input,EMAIL1" GF="S 120" validate="email(GRID_COL_EMAIL1_*)"></td>
													<td GCol="input,EMAIL2" GF="S 120" validate="email(GRID_COL_EMAIL2_*)"></td>
													<td GCol="input,COMPKY" GF="S 4" ></td>
													<td GCol="input,DEPART,SHPTNRTY_1" GF="S 20" ></td>
													<td GCol="input,EMPLID" GF="S 20" ></td>
													<td GCol="input,USERG1" GF="S 40" validate="required"></td>
													<td GCol="input,USERG2" GF="S 40" validate="remote(checkPv)" ></td>
													<td GCol="input,USERG3" GF="S 40" ></td>
													<td GCol="input,USERG4" GF="S 40" ></td>
													<td GCol="select,USERG5">
														<select Combo="System,AREAKYCOMBO">
														<option value="">Select</option>
														</select>
													</td>
													<td GCol="select,LANGKY">
														<select Combo="System,LANGKYCOMBO"></select>
													</td>
													<td GCol="select,DATEFM">
														<select Combo="System,DATEFMCOMBO"></select>
													</td>
													<td GCol="select,DATEDL">
														<select Combo="System,DATEDLCOMBO"></select>
													</td>
													<td GCol="select,DECPFM">
														<select Combo="System,DECPFMCOMBO"></select>
													</td>
													<td GCol="input,LLOGID" GF="S 8" ></td>
													<td GCol="input,LLOGIT" GF="S 6" ></td>
													<td GCol="input,LLOGOD" GF="S 8" ></td>
													<td GCol="input,LLOGOT" GF="S 6" ></td>
													<td GCol="input,MENUKY,SHMNUDF" GF="S 10" validate="required" ></td>
													<td GCol="select,CURRFM">
														<select Combo="System,CURRFMCOMBO"></select>
													</td>
													<td GCol="text,CREDAT" GF="D" ></td>
													<td GCol="text,CRETIM" GF="T" ></td>
													<td GCol="text,CREUSR" ></td>
													<td GCol="text,CUSRNM"></td>
													<td GCol="text,LMODAT" GF="D" ></td>
													<td GCol="text,LMOTIM" GF="T" ></td>
													<td GCol="text,LMOUSR"></td>
													<td GCol="text,LUSRNM"></td>
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

						<div id="tabs1-2">
							<div class="section type1">
								<div class="controlBtns type2" GNBtn="gridList">
									<a href="#"><img src="/common/images/btn_first.png" alt="" /></a>
									<a href="#"><img src="/common/images/btn_prev.png" alt="" /></a>
									<a href="#"><img src="/common/images/btn_next.png" alt="" /></a>
									<a href="#"><img src="/common/images/btn_last.png" alt="" /></a>
								</div>
								<br/>
								<div class="searchInBox">
								<h2 class="tit" CL="STD_SELECTOPTIONS">검색조건</h2>
									<table class="table type1">
										<colgroup>
											<col width="8%"/>
											<col />
											<col />
											<col />
											<col />
											<col />
										</colgroup>
										<tbody>
											<tr>
												<th CL="STD_USERID">사용자 ID</th>
												<td>
													<input type="text" name="USERID" readonly="readonly" UIInput="S,SHUSRMA" />
												</td>
												<th CL='STD_PASSWD'>비밀번호</th>
												<td>
													<input type="text" name="PASSWD" />
												</td>
												<th CL='STD_MENUKY'>메뉴키</th>
												<td>
													<input type="text" name="MENUKY" UIInput="S,SHMNUDF" />
												</td>
											</tr>
											<tr>
												<th CL='STD_NMLAST'>이름</th>
												<td>
													<input type="text" name="NMLAST"  />
												</td>
												<th CL='STD_DEPART'>부서</th>
												<td>
													<input type="text" name="DEPART" />
												</td>
												<th CL='STD_UROLKY'>권한</th>
												<td>
													<input type="text" name="UROLKY" UIInput="S,SHROLDF" />
												</td>
											</tr>
											<tr>
												<th CL='STD_NMFIRS'>관련업무</th>
												<td>
													<input type="text" name="NMFIRS" />
												</td>
											</tr>
											<tr>
												<th CL='STD_DELMAK'>삭제</th>
												<td>
													<input type="checkbox" name="DELMAK" />
												</td>
											</tr>
										</tbody>
									</table>
								</div>
								<br />
								<div class="searchInBox">
								<h2 class="tit" CL="STD_ADDRESSINFO"></h2>
									<table class="table type1">
										<colgroup>
											<col width="7%"/>
											<col width="26%"/>
											<col width="7%"/>
											<col width="25%"/>
											<col width="7%"/>
											<col width=""/>
										</colgroup>
										<tbody>
											<tr>
												<th CL='STD_ADDR01'>대표주소</th>
												<td colspan="3">
													<input type="text" name="ADDR01" style="width: 565px" />
												</td>
												<th CL='STD_CITY01'>도시</th>
												<td>
													<input type="text" name="CITY01" />
												</td>
											</tr>
											<tr>
												<th></th>
												<td colspan="3">
													<input type="text" name="ADDR02" style="width: 565px" />
												</td>
												<th CL='STD_REGN01'>관할거점</th>
												<td>
													<input type="text" name="REGN01" UIInput="S" />
												</td>
											</tr>
											<tr>
												<th></th>
												<td colspan="3">
													<input type="text" name="ADDR03" style="width: 565px" />
												</td>
												<th CL='STD_POSTCD'>우편번호</th>
												<td>
													<input type="text" name="POSTCD" />
												</td>
											</tr>
											<tr>
												<th></th>
												<td colspan="3">
													<input type="text" name="ADDR04" style="width: 565px" />
												</td>
												<th CL='STD_NATNKY'>국가</th>
												<td>
													<select name="NATNKY" Combo="System,NATNKYCOMBO"></select>
												</td>
											</tr>
											<tr>
												<th></th>
												<td colspan="3">
													<input type="text" name="ADDR05" style="width: 565px" />
												</td>
											</tr>
											<tr>
												<th CL='STD_TELN01'>전화번호</th>
												<td>
													<input type="text" name="TELN01" />
												</td>
												<th CL='STD_FAXTL1'>팩스번호</th>
												<td>
													<input type="text" name="FAXTL1" />
												</td>
											</tr>
											<tr>
												<th CL='STD_TELN02'>SNS 수신번호</th>
												<td>
													<input type="text" name="TELN02" />
												</td>
												<th CL='STD_FAXTL2'>영업소레벨</th>
												<td>
													<input type="text" name="FAXTL2" />
												</td>
											</tr>
											<tr>
												<th CL='STD_TELN03'>거래처담당자전번</th>
												<td>
													<input type="text" name="TELN03" />
												</td>
											</tr>
											<tr>
												<th CL='STD_TLEXT1'>전화번호1 : Ext</th>
												<td>
													<input type="text" name="TLEXT1" />
												</td>
											</tr>
											<tr>
												<th CL='STD_EMAIL1'>이메일 1</th>
												<td>
													<input type="text" name="EMAIL1" />
												</td>
												<th CL='STD_USERG1'>창고</th>
												<td>
													<input type="text" name="USERG1" />
												</td>
											</tr>
											<tr>
												<th CL='STD_EMAIL2'>이메일 2</th>
												<td>
													<input type="text" name="EMAIL2" />
												</td>
												<th CL='STD_USERG2'>구역</th>
												<td>
													<input type="text" name="USERG2" />
												</td>
											</tr>
											<tr>
												<th CL='STD_POBOX1'>P.O Box1</th>
												<td>
													<input type="text" name="POBOX1" />
												</td>
												<th CL='STD_USERG3'>정상창고</th>
												<td>
													<input type="text" name="USERG3" />
												</td>
											</tr>
											<tr>
												<th CL='STD_POBPC1'>PO Box 우편번호</th>
												<td>
													<input type="text" name="POBPC1" />
												</td>
												<th CL='STD_USERG4'>수리창고</th>
												<td>
													<input type="text" name="USERG4" />
												</td>
											</tr>
										</tbody>
									</table>
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