<%@ page language="java" contentType="text/html; charset=UTF-8" 
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>납품문서관리</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript" src="/wms/js/wms.js"></script>
<script type="text/javascript">
	var dblIdx = 0;
	
	$(document).ready(function(){  // 조회단 조회기능
		setTopSize(250);
		gridList.setGrid({
	    	id : "gridList",
			module : "TmsAdmin",
			command : "DNORD",
			itemGrid : "gridListSub",
			emptyMsgType:false
	    });
	    
		gridList.setGrid({			// 일반에서 세부조회기능기능
	    	id : "gridListSub",
			module : "TmsAdmin",
			command : "DNORDSub",

	    });
	    
	});
	
	function searchList(){		//조회단 name값 가져가기 
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			//var param1 = document.getByID("SALORD");
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });			
		}
	}
	 
	function searchSubList(headRowNum){ //세부조회단 name값 가져가기 
		var rowVal = gridList.getColData("gridList", headRowNum, "DELORD");	  
		
		var param = new DataMap();		
		param.put("DELORD", rowVal);
		
		gridList.gridList({
			id : "gridListSub",
			param : param
		});

		lastFocusNum = rowNum;
		dblIdx = rowNum;
	}
	var lastFocusNum = -1;
	
	function gridListEventItemGridSearch(gridId, rowNum, itemGridList){ //그리드 안에서 이벤트 발생시 찾기

		if(gridId == "gridList"){
			var param = gridList.getRowData(gridId, rowNum);
			
			gridList.gridList({
		    	id : "gridListSub",
		    	param : param
		    });
		}
	}
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if(gridId == "gridList" && dataLength > 0){
	    	searchSubList(0);
		}
	}   

 	//function gridListEventRowAddBefore(gridId, rowNum){ 
	//	var newData = new DataMap();
	//	newData.put("COMPKY",  "<%=compky%>");
	//	newData.put("WAREKY", "<%=wareky%>");  
	//	return newData; } 
		
	function cancelData(){ //DNC취소 기능
		var cancelHeadIdx = gridList.getSelectRowNumList("gridList");
		var cancelHeadLen = cancelHeadIdx.length;

		if( cancelHeadLen == 0 ){ // 체크			
			commonUtil.msgBox("VALID_M0006"); //"선택된 데이터가 없습니다."
			return;			
		}	else if (cancelHeadLen > 0) {
			
			for(var i = 0 ; i < cancelHeadLen ; i ++){
				var rowNum = cancelHeadIdx[i];
								
				var checkDN = gridList.getColData("gridList", rowNum, "DNCMP");				
				alert(checkDN);		
				if(checkDN == 'C'){              // DNCMP 상태값 확인
				commonUtil.msgBox("OUT_M0049");  // 이미 취소되었습니다.
				return;
				}
				
				var param = new DataMap();
				
				var DELORD = gridList.getColData("gridList", rowNum, "DELORD");
				
				param.put("DELORD", DELORD);

				var json = netUtil.sendData({
					id : "gridList",
					url : "/tms/ord/json/saveDNORD.data",
					param : param,
					sendType : "map"		
				});
				commonUtil.msgBox("OUT_M0150");
				searchList();
			}
		}			
	}
	
	//시뮬레이션 Set 생성 
	function simulData(){ 		
		var chkHeadIdx = gridList.getSelectRowNumList("gridList");
		var chkHeadLen = chkHeadIdx.length;
		// 체크 여부 확인
		if( chkHeadLen == 0 ){  
			commonUtil.msgBox("VALID_M0006");
			return;
		} // 체크 내용이 있으면 
		else if (chkHeadLen > 0){
			//체크된 hard의 item 납품문서 성격 validation			
			var checkDoc = gridList.getGridBox("gridList").selectRow.keys();
			var checkVgtyp;
			var checkVgtyp_IN="";
			
			for( i=0; i < checkDoc.length; i++ ){
				checkVgtyp=gridList.getColData("gridList", checkDoc[i], "VGTYP");				
				if( i > 0 ){
					checkVgtyp_IN +=",";
				}
				checkVgtyp_IN += "'"+checkVgtyp+"'";				
			}
			var param = new DataMap();			
			param = inputList.setRangeParam("searchArea");
			param.put("VGTYP_IN", checkVgtyp_IN); 
					   	
			var json = netUtil.sendData({
				module : "TmsAdmin",
				command : "DNORDVG_CNT",
				sendType : "map",
				param : param
			});
			if(json.data["CNT"] > 1) {    
				commonUtil.msgBox("INV_DNO01");   //doc section 유형이 상이합니다. 
				return;			
			}	 				
			
			var param1 = new DataMap();
			var json = netUtil.sendData({ // SIMUL UPCHECK 컬럼 값 확인 	
				module : "TmsAdmin",
				command : "SIMULID_CNT",
				sendType : "map",
				param : param1
			});
			if(json.data["CNT"] > 0) {    // SIMUL UPCHECK 컬럼 UPDATE  
				var param = new DataMap();
				var json = netUtil.sendData({
					module : "TmsAdmin",
					command : "SIMULID_UPDCHK",
					sendType : "map",
					param : param1
				});
				
			}			
			
			
			// 기존(DNTAK) 생성여부 확인 validation
 			for(var i = 0 ; i < chkHeadLen ; i ++){  
				var rowNum = chkHeadIdx[i];
				var param = new DataMap();
                var DELORD = gridList.getColData("gridList", rowNum, "DELORD");
				var DELITN = gridList.getColData("gridList", rowNum, "DELITN");
				var DELIDN = gridList.getColData("gridList", rowNum, "DELIDN");
                
                param.put("DELORD", DELORD);
				param.put("DELITN", DELITN);
				param.put("DELIDN", DELIDN);
										
				var json = netUtil.sendData({   
					module : "TmsAdmin",
					command : "DNTAKID_CNT",
					sendType : "map",
					param : param
				});
				if(json.data["CNT"] > 0){
					commonUtil.msgBox("INV_DNO02"); //해당 내역으로 생성되어 있습니다. 
					return;	
				}				
			}

			//SIMUL 테이블 생성
 			var simulSeq = wms.getDocSeq("998"); //시퀀스
			var param = new DataMap();
			param.put("WAREKY", "2000");
			param.put("SIMKEY", simulSeq);

			var json = netUtil.sendData({				
				url : "/tms/ord/json/saveSIMUL.data",
				param : param
			});	 
							
			//체크된 hard의 item 조회 및 저장 -- DNTAK 생성			
			var checkRows=gridList.getGridBox("gridList").selectRow.keys();
			var checkDelord;
			var checkDelord_IN="";
			for( i=0; i < checkRows.length; i++ ){
				checkDelord=gridList.getColData("gridList", checkRows[i], "DELORD"); 
				if( i > 0 ){
					checkDelord_IN +=",";
				}
				checkDelord_IN += "'"+checkDelord+"'";
			}

			var param = inputList.setRangeParam("searchArea");
			param.put("DELORD_IN", checkDelord_IN); 
			param.put("SIMKEY", simulSeq);
		   	
			var json = netUtil.sendData({
				url : "/tms/ord/json/saveTMO01.data",
				param : param
			});
			//===============================================================
			page.linkPopOpen("/tms/ord/TMO01POP.page", ""); 
		}
		searchList();		
	}
	
	function searchHelpEventOpenBefore(searchCode, gridType, $inputObj){ //서치헬프 기능
		if(searchCode == "SHCMCDV"){
			var param =dataBind.paramData("searchArea");
			var param = inputList.setRangeParam("searchArea");
			param.put("CMCDKY", "STOPTP");
			return param;
		}else if(searchCode == "SHWAHMA"){
			return dataBind.paramData("searchArea");
		}
	}
	
	function commonBtnClick(btnName){  //버튼클릭 기능		
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Simul"){
			simulData();
		}else if(btnName == "Cancel"){
			cancelData();
		}
	}
	

	function gridExcelDownloadEventBefore(gridId){
		if(gridId == "gridListSub"){
			var param = inputList.setRangeParam("searchArea"); 
			var rowVal = gridList.getColData("gridList", gridList.getSelectIndex("gridList"), "DELORD"); 
			param.put("DELORD", rowVal);
			param.put(configData.DATA_EXCEL_REQUEST_FILE_NAME, "");
			return param; 
		}
	}

</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY"></button>
		<button CB="Simul FILE STD_SIMKEYS"></button>
		<button CB="Cancel PENCIL STD_CANCED"></button>
		
	</div>
	<div class="util2">
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
						<th CL="STD_COMPKY">Company Code</th>
						<td>
							<input type="text" name="COMPKY" value="<%=compky%>"  readonly="readonly" style="width:110px" />  <!-- UIInput="S,SHCOMMA"   -->
						</td>
					</tr>
					<tr>
						<th CL="STD_WAREKY">거점</th>
						<td>
							<input type="text" name="WAREKY" value="<%=wareky%>" UIInput="S,SHWAHMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_SHPTKY">출하지점</th>
						<td>
							<input type="text" name="A.SHPTKY" UIInput="R,SHPTKY" />
						</td>
					</tr>
					<tr>
						<th>Sales Order</th>
						<td>
							<input type="text" name="SALORD" UIInput="R,SALORD" />
						</td>
					</tr>
					<tr>
						<th>Delivery Note</th>
						<td>
							<input type="text" name="DELORD" UIInput="R,DELORD" />
						</td>
					</tr>
					<tr>
						<th CL="STD_SRESWK">도착지</th>
						<td>
							<input type="text" name="SHPTKY" UIInput="R,SHPTOP" />
						</td>
					</tr>
					<tr>
						<th CL="STD_SHTOTY">도착지유형</th>
						<td>
							<input type="text" name="SHTOTY" UIInput="R,SHCMCDV" />
						</td>
					</tr>
					<tr>
						<th>배송유형</th>
							<td GCol="select,DELITP">
								<select CommonCombo="DELITP" name="VSART" style="width: 155px">
									<option value="">선택</option>
								</select>
							</td>
					</tr>
					<tr>
						<th CL="STD_PKGKY">포장유형</th>
						<td>
							<input type="text" name="PKTYP" UIInput="S,PKGKY" />
						</td>
					</tr>
					<tr>
						<th>긴급도</th>
							<td GCol="select,URGNT">
								<select CommonCombo="URGNT" name="URGNT" style="width: 155px">
									<option value="">선택</option>
								</select>
							</td>
					</tr>
					<tr>
						<th>Doc Section</th>
						<td GCol="select,VGTYP">
								<select CommonCombo="VGTYP" name="VGTYP" style="width: 155px">
									<option value="">선택</option>
								</select>
						</td>
					</tr>
 					<tr>
						<th CL="STD_CREDAT">생성일자</th>
						<td>
							<input type="text" name="A.CREDAT" UIInput="R" UIFormat="C Y"/>
						</td>
					</tr>
					 <tr>
						<th>배송요청일</th>
						<td>
							<input type="text" name="VDATU" UIInput="R" UIFormat="C Y" />
						</td>
					</tr>
					<tr>
						<th>배송요청시간</th>
						<td>
							<input type="text" name="VTIME" UIInput="R" UIFormat="T" />
						</td>
					</tr>
					<tr>
						<th>출하요청일</th>
						<td>
							<input type="text" name="SDATU" UIInput="R" UIFormat="C Y" />
						</td>						
					</tr>  
					<tr>
						<th>단독배송여부</th>
							<td GCol="select,MIXLOD">
								<select CommonCombo="MIXLOD" name="MIXLOD" style="width: 155px">
									<option value="">선택</option>									      								
								</select>
							</td>
						</td>
					</tr>
					<tr>
						<th>톤수제한여부</th>
							<td GCol="select,VHCINEQ">
								<select CommonCombo="VHCINEQ" name="VHCINEQ" style="width: 155px">
									<option value="">선택</option>      								
								</select>		
							</td>				
					</tr>
					<tr>
						<th>적재단수필드</th>
						<td>
							<input type="text" name="FLTLVL" UIFormat="N 20" style="width: 155px"/>
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
		
			<div class="bottomSect top">
				<button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button>
				<div class="tabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span CL='STD_GENERAL'>탭메뉴1</span></a></li>												
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
										    <col width="40" />
											<col width="40" />
											<col width="100"/> 
											<col width="100"/> 
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>											
											<col width="100"/>
											<col width="100"/> 
											<col width="100"/> 
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>											
											<col width="100"/>
											<col width="100"/> 
											<col width="100"/> 
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>											
											<col width="100"/>
											<col width="100"/> 
											<col width="100"/> 
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>											
											<col width="100"/>
											<col width="100"/> 
											<col width="100"/> 
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>											
											<col width="100"/>
											<col width="100"/> 
											<col width="100"/> 
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>
										</colgroup>
										<thead>
											<tr>
											    <th CL='STD_NUMBER'>번호</th>
												<th GBtnCheck="true"></th>
												<th CL='STD_COMPKY'>회사</th>
												<th CL='STD_WAREKY'>거점</th>		
												<th CL='STD_AREA'>Plant</th>
												<th CL='STD_SHPTKY'>출하지점 </th>
												<th CL='STD_ADDSHP'>추가출하지점</th>
												<th CL='STD_ORGSHP'>원출하지점 </th>
												<th CL='STD_PLNPOT'>운송계획지점</th>
												<th CL='STD_DELITP'>배송유형 </th>
												<th CL='STD_VGTYP'>Doc Section</th>												
												<th CL='STD_SHPTYP'>선적유형</th>
												<th CL='STD_LFART'>납품유형 </th>
												<th CL='STD_SHTOGBO'>영업조직 </th>
												<th CL='STD_SHPCON'>출하조건</th>
												<th CL='STD_SVCLVL'>서비스레벨</th>
												<th CL='STD_PAYCON'>인도조건</th>
												<th CL='STD_DELORD'>Delivery Note </th>
												<th CL='STD_SRESWK'>도착지코드 </th>
												<th CL='STD_SHIPNM'>도착지명</th>
												<th CL='STD_SHTOTY'>도착지유형</th>
												<th CL='STD_SHTOGB'>도착지유형명</th>
												<th CL='STD_POSTCD'>우편번호 </th>
												<th CL='STD_ADDR'>주소</th>
												<th CL='STD_RTPATH'>운송경로</th>
												<th CL='STD_TRPTKY'>운송사</th>
												<th CL='STD_ZPOSIT'>차량유형</th>
												<th CL='STD_VHCFNO'>차량번호</th>
												<th CL='STD_DRIVER'>기사명</th>
												<th CL='STD_DRVTL'>기사전화번호 </th>
												<th CL='STD_SDATU'>출하요청일 </th>
												<th CL='STD_VDATUD'>배송요청일</th>
												<th CL='STD_VTIME'>배송요청시간</th>
												<th CL='STD_EXPTNK'>판매처</th>
												<th CL='STD_EXPTNK'>유통경로</th>
												<th CL='STD_VKBUR'>영업팀</th>
												<th CL='STD_VKGRP'>영업그룹</th>
												<th CL='STD_GRTXT'>출하요청텍스트</th>
												<th CL='STD_MIXLOD'>단독배송여부</th>
												<th CL='STD_vhcineqd'>톤수제한</th>
												<th CL='STD_URGNT'>긴급도</th>																								
 												<th CL='STD_CREDAT'>생성일자</th>
												<th CL='STD_CRETIM'>생성시간</th>												
												<th CL='STD_CREUSR'>생성자</th>
												<th CL='STD_LMODAT'>수정일자</th>
												<th CL='STD_LMOTIM'>수정시간</th>
												<th CL='STD_LMOUSR'>수정자</th>											
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
										    <col width="40" />
											<col width="40" />
											<col width="100"/> 
											<col width="100"/> 
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>											
											<col width="100"/>
											<col width="100"/> 
											<col width="100"/> 
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>											
											<col width="100"/>
											<col width="100"/> 
											<col width="100"/> 
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>											
											<col width="100"/>
											<col width="100"/> 
											<col width="100"/> 
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>											
											<col width="100"/>
											<col width="100"/> 
											<col width="100"/> 
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>											
											<col width="100"/>
											<col width="100"/> 
											<col width="100"/> 
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>
											<col width="100"/>
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
											    <td GCol="rownum">1</td>
												<td GCol="rowCheck"></td>												
												<td GCol="text,MANDT">회사</td>
												<td GCol="text,WAREKY">거점</td>		
												<td GCol="text,WERKS">Plant</td>
												<td GCol="select,SHPTKY">
													<select CommonCombo="SHPTKY" name="SHPTKY" disabled="disabled"></select>	
												</td>																	
												<td GCol="text,ADDSHP">추가출하지점</td>
												<td GCol="text,ORGSHP">원출하지점</td>
												<td GCol="select,PLNPOT">
													<select CommonCombo="PLNPOT" name="PLNPOT" disabled="disabled"></select>	
												</td>
												<td GCol="select,VSART">
													<select CommonCombo="DELITP" name="VSART" disabled="disabled"></select>	
												</td>																							
												<td GCol="select,VGTYP">
													<select CommonCombo="VGTYP" name="VGTYP" disabled="disabled"></select>	
												</td>
												<td GCol="select,SHPTYP">
													<select CommonCombo="DELITP" name="SHPTYP" disabled="disabled"></select>	
												</td>
												<td GCol="text,AUART">납품유형</td>												
												<td GCol="select,SHTOGB">
													<select CommonCombo="SHTOGB" name="SHTOGB" disabled="disabled"></select>													
												</td>
												<td GCol="select,SHPCON">
													<select CommonCombo="SHPCON" name="SHPCON" disabled="disabled"></select>													
												</td>
												<td GCol="select,SVCLVL">
													<select CommonCombo="SVCLVL" name="SVCLVL" disabled="disabled"></select>													
												</td>
												<td GCol="text,PAYCON">인도조건</td>
												<td GCol="text,DELORD">Delivery Note</td>
												<td GCol="text,SHPTOP">도착지코드</td>
												<td GCol="text,SHIPNM">도착지명</td>												
												<td GCol="select,SHTOTY">
													<select CommonCombo="STOPTP" name="SHTOTY" disabled="disabled"></select>													
												</td>
												<td GCol="text,SHTOGBO">도착지유형명</td>
												<td GCol="text,SOSTOP">우편번호</td>
												<td GCol="text,ADDR01">주소</td>
												<td GCol="text,ROUTE">운송경로</td>
												<td GCol="text,FWDCD">운송사</td>	
												<td GCol="select,VHCTYP">
													<select CommonCombo="VHCTYP" name="VHCTYP" disabled="disabled"></select>													
												</td>
												<td GCol="text,VHCFNO">차량번호</td>
												<td GCol="text,DRVNM">기사명</td>
												<td GCol="text,DRVTL">기사전화번호</td>
												<td GCol="text,SDATU">출하요청일</td>
												<td GCol="text,VDATU">배송요청일</td>
												<td GCol="text,VTIME">배송요청시간</td>
												<td GCol="text,KUNAG">판매처</td>
												<td GCol="select,VTWEG">
													<select CommonCombo="VKBUR" name="VTWEG" disabled="disabled"></select>													
												</td>										
												<td GCol="text,VKBUR">영업팀</td>
												<td GCol="text,VKGRP">영업그룹</td>
												<td GCol="text,GRTXT">출하요청텍스트</td>
												<td GCol="select,MIXLOD">
													<select CommonCombo="MIXLOD" name="MIXLOD" disabled="disabled"></select>
												</td>
												<td GCol="select,vhcineq">
													<select CommonCombo="vhcineq" name="vhcineq" disabled="disabled"></select>
												</td>
												<td GCol="select,URGNT">
													<select CommonCombo="URGNT" name="URGNT" disabled="disabled"></select>
												</td>																								
 												<td GCol="text,CREDAT">생성일자</td>
												<td GCol="text,CRETIM">생성시간</td>												
												<td GCol="text,CREUSR">생성자</td>
												<td GCol="text,LMODAT">수정일자</td>
												<td GCol="text,LMOTIM">수정시간</td>
												<td GCol="text,LMOUSR">수정자</td>													
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
		        
		        
			<div class="bottomSect bottom">
				<button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button>
				<div class="tabs">
					<ul class="tab type2" id="commonMiddleArea">
						<li><a href="#tabs1-1"><span CL='STD_SEARCH'>탭메뉴1</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
											<col width="40" />
											<!-- <col width="50" /> -->
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<!-- <th GBtnCheck="true"></th> -->
												<th CL='STD_DELITN'>Delivery Item </th>
												<th CL='STD_DELIDN'>Delivery Detail</th>
												<th CL='STD_SALORD'>Sales Order No</th>
												<th CL='STD_SALITN'>Salaes Order Item</th>
												<th CL='STD_MATKL'>Material Group</th>
												<th CL='STD_MTLCDE'>Material</th>
												<th CL='STD_MTLTXT'>Material Desc</th>
												<th CL='STD_LOTNUM'>배치번호</th>
												<th CL='STD_JOJANG'>조장</th>
												<th CL='STD_JOJANGSU'>조장수</th>
												<th CL='STD_LFIMG1'>Delivery Qty</th>
												<th CL='STD_VRKME1'>Delivery UOM</th>
												<th CL='STD_BRGEW'>Gross Weight</th>
												<th CL='STD_BRWEI'>Gross Weight UOM</th>
												<th CL='ITF_NTGEW'>Net Weight</th>
												<th CL='STD_NTWEI'>Net Weight UOM</th>
												<th CL='STD_PKTYP'>포장재 유형</th>
												<th CL='STD_PKMATNR'>포장재 코드</th>
												<th CL='STD_MENGE'>포장재 수량</th>
												<th CL='STD_ZMEINS'>포장재 수량 단위</th>
												<th CL='STD_WIDTH'>폭</th>
												<th CL='STD_LENGTH'>길이</th>
												<th CL='STD_HEIGHT'>높이</th>
												<th CL='STD_PKWEI'>포장재 중량</th>
												<th CL='STD_PKWEI1'>적재단수</th>	
 												<th CL='STD_CREDAT'>생성일자</th>
												<th CL='STD_CRETIM'>생성시간</th>												
												<th CL='STD_CREUSR'>생성자</th>
												<th CL='STD_LMODAT'>수정일자</th>
												<th CL='STD_LMOTIM'>수정시간</th>
												<th CL='STD_LMOUSR'>수정자</th>			
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="40" />
											<!-- <col width="50" /> -->
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
										</colgroup>
										<tbody id="gridListSub">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<!-- <td GCol="rowCheck"></td>  -->				
												<td GCol="text,DELORD">Delivery Item </td>
												<td GCol="text,DELITN">Delivery Detail</td>
												<td GCol="text,DELIDN">Sales Order No</td>
												<td GCol="text,SALORD">Slaes Order Item</td>
												<td GCol="text,SALITN">Material Group</td>
												<td GCol="text,MATKL">Material</td>
												<td GCol="text,MTLCDE">Material Desc</td>
												<td GCol="text,MTLTXT">배치번호</td>
												<td GCol="text,LOTNUM">조장  </td>
												<td GCol="text,JOJANG">조장수</td>
												<td GCol="text,JOJANGSU">Delivery Qty</td>
												<td GCol="text,LFIMG">Delivery UOM</td>
												<td GCol="text,VRKME">Gross Weight</td>
												<td GCol="text,BRGEW">Gross Weight UOM</td>
												<td GCol="text,BRWEI">Net Weight</td>
												<td GCol="text,NTGEW">Net Weight UOM</td>
												<td GCol="text,NTWEI">포장재 유형</td>
												<td GCol="text,PKTYP">포장재 코드</td>
												<td GCol="text,PKMATNR">포장재 수량</td>
												<td GCol="text,MENGE">포장재 수량 단위</td>
												<td GCol="text,WIDTH">폭  </td>
												<td GCol="text,LENGTH">길이 </td>
												<td GCol="text,HEIGHT">높이</td>
												<td GCol="text,PKWEI">포장재 중량</td>
												<td GCol="text,fltlvl">적재단수</td>	
												<td GCol="text,CREDAT">생성일자</td> 
												<td GCol="text,CRETIM">생성시간</td>   
												<td GCol="text,CREUSR">생성자</td> 
												<td GCol="text,LMODAT">수정일자</td>   
												<td GCol="text,LMOTIM">수정시간</td> 
												<td GCol="text,LMOUSR">수정자</td>										
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