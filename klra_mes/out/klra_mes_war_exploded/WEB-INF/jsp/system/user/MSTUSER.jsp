<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript">
    
	$(document).ready(function() { 
		gridList.setGrid({
			id : "gridList",
			editable : true,
			module : "System",
			command : "USER",
			//bindArea : "tabs1-2",
			validation : "UROLKY,MENUKY",
			colHoldType : "true",
			colHold : "USERID, DELMAK, DEPT_CD, EMPLID, NMLAST"
		});

		
		gridList.setReadOnly("gridList", true, ["USERG5"]);
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

	function gridListEventDataBindEnd(gridId, dataLength){
		if(gridId == "gridList"){
			for(var i = 0; i < dataLength; i++){
				var status = gridList.getColData(gridId, i, "STATUS");
				
				if(status == "Y"){
					/* 
					gridList.setRowReadOnly(gridId, i, true, ["DELMAK","DEPT_CD","EMPLID","UROLKY","MENUGID","PDAMKY","NMFIRS","ADDR01","ADDR02","ADDR03","ADDR04","ADDR05","CITY01","REGN01","POSTCD",
						"NATNKY","TELN01","TELN02","TELN03","TLEXT1","FAXTL1","FAXTL2","POBOX1","POBPC1","EMAIL1","EMAIL2","COMPKY","USERG1","USERG2","USERG3","USERG4","PROC_CD","WRK_CLASS","EMPLY_DIV","RETR_YN","USERG5","LANGKY","STATUS",
						"LLOGID","LLOGIT","LLOGOD","LLOGOT","CREDAT","CRETIM","CREUSR","CUSRNM","LMODAT","LMOTIM","LMOUSR","LUSRNM"]);
					*/
					gridList.setRowReadOnly(gridId, i, true, ["DELMAK","DEPT_CD","EMPLID","NMFIRS","ADDR01","ADDR02","ADDR03","ADDR04","ADDR05","CITY01","REGN01","POSTCD",
						"NATNKY","TELN01","TELN02","TELN03","TLEXT1","FAXTL1","FAXTL2","POBOX1","POBPC1","EMAIL1","EMAIL2","COMPKY","PROC_CD","WRK_CLASS","EMPLY_DIV","RETR_YN","USERG5","LANGKY","STATUS",
						"LLOGID","LLOGIT","LLOGOD","LLOGOT","CREDAT","CRETIM","CREUSR","CUSRNM","LMODAT","LMOTIM","LMOUSR","LUSRNM"]);
				}
			}
		}
	}
	
	
	function saveData() {
		if(gridList.validationCheck("gridList", "modify")){
			//var list = gridList.getModifyList("gridList");
			var list = gridList.getModifyData("gridList", "A");
			var param = new DataMap();
			param.put("list", list);
			
			var json = netUtil.send({
				url : "/mes/system/json/UI01.data",
				param : param,
				returnParam : param,
				successFunction : "saveEnd",
				failFunction : "saveFail"
			});
			
			
		}
	}
	
	function saveEnd(json, param){
		
		if(json && json.data){
			if(json.data != "0"){
				//alert("비밀번호가 초기화 되었습니다.");
				alert(commonUtil.getMsg(configData.MSG_SYSTEM_SAVEOK));
			}else{
				alert(commonUtil.getMsg("COMMON_M0465")); // 저장 실패하였습니다.
			}
			searchList();
		}else{
			alert(commonUtil.getMsg("COMMON_M0465")); // 저장 실패하였습니다.
			searchList();
		}
	}

	function saveFail(a, b, c, param){ // a:request, b:status, c:error
		var resultText = a.responseText.trim();
		alert(commonUtil.getMsg("COMMON_M0465")); // 저장 실패하였습니다.
		searchList();
	}
	
	
	function gridListEventRowAddAfter(gridId, rowNum){
		if(gridId == "gridList") {
			gridList.setColValue(gridId, rowNum, "NATNKY", "KR");
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
			var param = new DataMap();
	        param.put("PROGID", "<%= menuId%>");
	        param.put("LGTYPE", "SEARCH");
	        var json = netUtil.sendData({
	            url: "/mes/system/json/saveLog.data",
	            param : param
	        });
			
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}else if(btnName == "Pwreset"){
			pwReset();
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
	
	function pwReset(){
		//if(gridList.validationCheck("gridList", "select")){
		var chkList = gridList.getSelectRowNumList("gridList");

		if(chkList.length < 1){
			alert("선택된 데이터가 없습니다.");
			return;
		}else{
			var chkGrid = gridList.getSelectData("gridList");
			var param = new DataMap();
			param.put("list", chkGrid);
			
			var json = netUtil.send({
				url : "/mes/system/json/initPwUI01.data",
				param : param,
				returnParam : param,
				successFunction : "pwResetEnd",
				failFunction : "pwResetFail"
			});
			
			//alert("비밀번호가 초기화 되었습니다.");
			//searchList();
		}
		//}
	}
	
	function pwResetEnd(json, param){
	  	
		if(json && json.data){
			if(json.data != "0"){
				alert("비밀번호가 초기화 되었습니다.");
			}else{
				alert(commonUtil.getMsg("COMMON_M0465")); // 저장 실패하였습니다.
			}
			searchList();
		}else{
			alert(commonUtil.getMsg("COMMON_M0465")); // 저장 실패하였습니다.
			searchList();
		}
	}

	function pwResetFail(a, b, c, param){ // a:request, b:status, c:error
		var resultText = a.responseText.trim();
		alert(commonUtil.getMsg("COMMON_M0465")); // 저장 실패하였습니다.
		searchList();
	}
</script>
</head>
<body>
<%@ include file="/common/include/webdek/layout.jsp" %>
<!-- content -->
<div class="content_wrap">
	<div class="content_inner">
		<%@ include file="/common/include/webdek/title.jsp" %>
		<div class="content_serch" id="searchArea">
			<div class="btn_wrap">
				<div class="fl_l">
				</div>
				<div class="fl_r">
					<input type="button" CB="Search SEARCH BTN_SEARCH" />
					<input type="button" CB="Save SAVE BTN_SAVE" />
					<input type="button" CB="Pwreset SAVE BTN_PWRESET">
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_USERID"></dt>
						<dd>
							<input type="text" class="text" name="U.USERID" UIInput="R,SHUSRMA" />
						</dd>
					</dl>
					<dl>
						<dt CL="STD_NMLAST">이름</dt>
						<dd><input type="text" name="NMLAST" UIInput="R" /></dd>
					</dl>
					<dl>
						<dt CL="STD_NMFIRS">관련업무</dt>
						<dd><input type="text" name="NMFIRS" UIInput="R" ></dd>
					</dl>
					<dl>
						<dt CL="STD_MENUKY">메뉴키</dt>
						<dd><input type="text" name="MENUKY" UIInput="R,SHMNUDF" /></dd>
					</dl>
					<dl>
						<dt>부서</dt>
						<dd><input type="text" name="DEPART" UIInput="SR,DEPT" /></dd>
					</dl>
					<!-- <dl>
						<dt CL="DELYN"></dt>
						<dd>
							<select name="DELYN" class="input" CommonCombo="DELYN" ComboCodeView=false>
								<option value="" CL="STD_ALL"></option>
							</select>
						</dd>
					</dl> -->
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
        <div class="search_next_wrap">
			<div class="content_layout tabs">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span>일반</span></a></li>
				</ul>
				<div class="table_box section" id="tab1-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="40" GCol="rowCheck"></td>										
										<td GH="100" GCol="add,USERID" GF="S 60"></td>													<!-- USERID -->
										<td GH="100 STD_DELMAK" GCol="check,DELMAK"></td>												<!-- 삭제 -->
										<td GH="100" GCol="input,DEPT_CD,DEPT" GF="S 60"></td>											<!-- 부서코드 -->
										<td GH="100" GCol="input,EMPLID,EMPLY" validate="required,MASTER_M0001" GF="S 60"></td> 		<!-- 사원번호 -->	
										<td GH="100" GCol="add,NMLAST" GF="S 60" validate="required,SYSTEM_M0100"></td>					<!-- 이름 -->	
										<td GH="100" GCol="input,USER_NM"></td>															<!-- 사원명 -->
										<td GH="100" GCol="input,PROC_CD,OP" style="text-align:center;"></td>							<!-- 공정코드 -->
										<td GH="100" GCol="text,WRK_TEAM" style="text-align:center;"></td>								<!--작업팀명-->  
										<td GH="100" GCol="input,WRK_CLASS" style="text-align:center;" GF="N 13"></td>							<!-- 작업반 -->		
										<td GH="100" GCol="input,INSPR_NM"></td>														<!-- 검사자(단축) -->
										<td GH="100" GCol="input,UROLKY,SHROLDF" GF="S 200" ></td> 										<!-- 사용권한 키 -->
										<td GH="100" GCol="input,MENUGID,SHMSTMENUG" GF="S 10" validate="required" ></td> 				<!-- 메뉴 그룹 ID -->
										<td GH="100" GCol="input,PDAMKY,SHMNUDF" GF="S 60" ></td>										<!-- PDA Menu key -->
										<td GH="100" GCol="input,NMFIRS" GF="S 60" ></td>												<!-- 관려업무 -->
										<td GH="0" GCol="input,ADDR01" GF="S 180" ></td>												<!-- 대표주소 -->
										<td GH="0" GCol="input,ADDR02" GF="S 180" ></td> 												<!-- 납품주소 -->
										<td GH="100" GCol="input,ADDR03" GF="S 180" ></td>												<!-- 주소3 -->
										<td GH="0" GCol="input,ADDR04" GF="S 180" ></td>												<!-- 봉투라벨주소1 -->
										<td GH="0" GCol="input,ADDR05" GF="S 180" ></td>												<!-- 봉투라벨주소2 -->
										<td GH="0" GCol="input,CITY01" GF="S 180" ></td>												<!-- 도시 -->
										<td GH="0" GCol="input,REGN01" GF="S 12" ></td>													<!-- 관할거점 -->
										<td GH="0" GCol="input,POSTCD" GF="S 30" ></td>													<!-- 우편번호 -->
										<td GH="100" GCol="select,NATNKY">																<!-- 국가 -->
											<select Combo="System,NATNKYCOMBO">
											</select>
										</td>
										<td GH="160" GCol="input,TELN01" GF="S 20" validate="tel(GRID_COL_TELN01_*)"></td>				<!-- 전화번호 -->
										<td GH="0" GCol="input,TELN02" GF="S 20" validate="tel(GRID_COL_TELN02_*)"></td>				<!-- SMS수신번호 -->
										<td GH="0" GCol="input,TELN03" GF="S 20" validate="tel(GRID_COL_TELN03_*)"></td>				<!-- 전화번호3 -->
										<td GH="0" GCol="input,TLEXT1" GF="S 10"></td>													<!-- Ext. -->
										<td GH="0" GCol="input,FAXTL1" GF="S 20" validate="tel(GRID_COL_TELN01_*)"></td>				<!-- 팩스번호 -->
										<td GH="0" GCol="input,FAXTL2" GF="S 20"></td>													<!-- 팩스번호2 -->
										<td GH="0" GCol="input,POBOX1" GF="S 10" ></td>													<!-- P.O Box1 -->
										<td GH="0" GCol="input,POBPC1" GF="S 10" ></td>													<!-- POBox우편 -->
										<td GH="200" GCol="input,EMAIL1" GF="S 120" validate="email(GRID_COL_EMAIL1_*)"></td>			<!-- E-MAIL -->
										<td GH="0" GCol="input,EMAIL2" GF="S 120" validate="email(GRID_COL_EMAIL2_*)"></td>				<!-- E-MAIL 2 -->
										<td GH="100" GCol="input,COMPKY" GF="S 4" validate="required"></td>												<!-- 회사 -->
										<td GH="100" GCol="input,USERG1" GF="S 40" ></td>												<!-- 사용자그룹1 -->
										<td GH="100" GCol="input,USERG2" GF="S 40" validate="remote(checkPv)" ></td>					<!-- 사용자그룹2 -->
										<td GH="100" GCol="input,USERG3" GF="S 40" ></td>												<!-- 사용자그룹3 -->
										<td GH="100" GCol="input,USERG4" GF="S 40" ></td>												<!-- Plant -->
										<td GH="100" GCol="input,EMPLY_DIV"></td>														<!-- 직원구분 -->
										<td GH="100" GCol="select,RETR_YN">
											<select>
												<option value=""> </option>
												<option value="">Y</option>
												<option value="">N</option>
											</select></td>																				<!-- 퇴사구분 -->
										<td GH="0" GCol="select,USERG5">																<!-- 메인창고 -->
											<select Combo="System,AREAKYCOMBO">
												<option value="">Option</option>
											</select>
										</td>
										<td GH="0" GCol="select,LANGKY">																<!-- 언어 -->
											<select Combo="System,LANGKYCOMBO" ></select>
										</td>
										<td GH="0" GCol="text,STATUS"></td>
										<td GH="0" GCol="text,LLOGID" GF="D" style="text-align:center;"></td>							<!-- LastLD -->
										<td GH="0" GCol="text,LLOGIT" GF="T" style="text-align:center;"></td>							<!-- LastLT -->
										<td GH="0" GCol="text,LLOGOD" GF="D" style="text-align:center;"></td>							<!-- LastLD -->
										<td GH="0" GCol="text,LLOGOT" GF="T" style="text-align:center;"></td>							<!-- LastLT -->
										<td GH="100" GCol="text,CREDAT" GF="D" style="text-align:center;"></td>							<!-- 생성일자 -->
										<td GH="100" GCol="text,CRETIM" GF="T" style="text-align:center;" ></td>						<!-- 생성시간 -->
										<td GH="0" GCol="text,CREUSR" style="text-align:center;"></td>									<!-- STD_CREUSR -->
										<td GH="100" GCol="text,CUSRNM"></td>															<!-- STD_CURNM -->
										<td GH="100" GCol="text,LMODAT" GF="D" style="text-align:center;"></td>							<!-- 수정일자 -->
										<td GH="100" GCol="text,LMOTIM" GF="T" style="text-align:center;"></td>							<!-- 수정시간 -->
										<td GH="0" GCol="text,LMOUSR" style="text-align:center;"></td>									<!-- 수정자 -->
										<td GH="100" GCol="text,LUSRNM"></td>															<!-- 수정자명 -->					 
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<div class="btn_lit tableUtil">
						<button type='button' GBtn="find"></button>
						<button type='button' GBtn="sortReset"></button>
						<button type='button' GBtn="add"></button>
						<button type='button' GBtn="copy"></button>
						<button type='button' GBtn="delete"></button>
						<button type='button' GBtn="total"></button>
						<button type='button' GBtn="layout"></button>
						<button type='button' GBtn="excel"></button>
						<button type='button' GBtn="excelUpload"></button>
						<span class='txt_total' >총 건수 : <span GInfoArea='true'>4</span></span>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>