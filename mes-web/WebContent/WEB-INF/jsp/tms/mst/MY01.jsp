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
			module : "TmsAdmin",
			command : "ZSDT020"
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

		var list = gridList.getGridData("gridList"); 
		param.put("list", list); 
		
		if(gridList.validationCheck("gridList")){

			var json = netUtil.sendData({
				url : "/tms/mst/json/saveMY01.data",
				param : param
			}); 
		}
		
		if(json && json.data){
			searchList();
		}	
	}
	
	var checkValidationType = true;
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){		
		if(gridId == "gridList" && colName == "FWDCD"){  //운송사
			if(colValue != ""){
				var param = new DataMap();
				param.put("FWDKEY",colValue);
				var json = netUtil.sendData({
					module : "TmsAdmin",
					command : "FWDKEYval",
					sendType : "map",
					param : param
				});
				if(json.data["CNT"] > 0) {
					var param = new DataMap();
					param.put("FWDKEY",colValue);
					var json = netUtil.sendData({
						module : "TmsAdmin",
						command : "FWDKEYnm",
						sendType : "map",
						param : param
					});
					 if(json && json.data){
						gridList.setColValue("gridList", rowNum, "FWDNME", json.data["FWDNME"]);  
					 } 
					checkValidationType = true;
				 }else if (json.data["CNT"] < 1) {			
					commonUtil.msgBox("VALID_M0227", colValue);
					gridList.setColValue("gridList", rowNum, "FWDCD", "");
					gridList.setColValue("gridList", rowNum, "FWDNME", "");
					checkValidationType = false;
				 }			
			}else if(colValue==""){
				gridList.setColValue("gridList", rowNum, "FWDNME", "");
				checkValidationType = true;
			}
		}else if(gridId == "gridList" && colName == "SFRGR"){  //차량유형
			if(colValue != ""){
				var param = new DataMap();
				param.put("VHCTYP",colValue);
				var json = netUtil.sendData({
					module : "TmsAdmin",
					command : "VHCTYPval",
					sendType : "map",
					param : param
				});
				if(json.data["CNT"] > 0) {
					var param = new DataMap();
					param.put("VHCTYP",colValue);
					var json = netUtil.sendData({
						module : "TmsAdmin",
						command : "VHCTYPnm",
						sendType : "map",
						param : param
					});
					if(json && json.data){
						gridList.setColValue("gridList", rowNum, "VHCSTX", json.data["CDESC1"]); 
					} 
					checkValidationType = true;
				} else if (json.data["CNT"] < 1) {
					commonUtil.msgBox("VALID_M0228", colValue);
					gridList.setColValue("gridList", rowNum, "SFRGR", "");
					gridList.setColValue("gridList", rowNum, "VHCSTX", ""); 
					checkValidationType = false;
				}			
			}else if(colValue==""){
				gridList.setColValue("gridList", rowNum, "VHCSTX", "");
				checkValidationType = true;
			}
		}
	}
		
 	function gridListEventRowAddBefore(gridId, rowNum, beforeData){

		var newData = new DataMap();
		newData.put("MANDT", "100");

		return newData;
	}  
 	
	function searchHelpEventOpenBefore(searchCode, gridType, $inputObj){
		if(searchCode == "SHCMCDV"){

			//var param =dataBind.paramData("searchArea");
			var param = inputList.setRangeParam("searchArea");
			
			if($inputObj.name != null){
				if($inputObj.name == "FARETP"){        //운임유형
					param.put("CMCDKY", "FARETP");    
				}else if($inputObj.name == "PLNPOT"){  //운송계획지점유형
					param.put("CMCDKY", "PLNPOT");
				}else if($inputObj.name == "DELITP"){  //배송유형
					param.put("CMCDKY", "DELITP");
				}else if($inputObj.name == "SFRGR"){   //차량유형
					param.put("CMCDKY", "VHCTYP");
				}else if($inputObj.name == "TRACHA"){  //운송경로
					param.put("CMCDKY", "TRACHA");
				}else if($inputObj.name == "SVCLVL"){  //서비스레벨
					param.put("CMCDKY", "SVCLVL");
				}else if($inputObj.name == "WANGBOK"){  //왕복조건
					param.put("CMCDKY", "PLYTER");
				}else if($inputObj.name == "DOKCHA"){  //독차조건
					param.put("CMCDKY", "EXCTER");
				}				
			}else{
				if($inputObj.attr("name") == "FARETP"){       
					param.put("CMCDKY", "FARETP");	
				}else if($inputObj.attr("name") == "PLNPOT"){
					param.put("CMCDKY", "PLNPOT");	
				}else if($inputObj.attr("name") == "DELITP"){ 
					param.put("CMCDKY", "DELITP");	
				}else if($inputObj.attr("name") == "SFRGR"){
					param.put("CMCDKY", "VHCTYP");	
				}else if($inputObj.attr("name") == "TRACHA"){
					param.put("CMCDKY", "TRACHA");	
				}else if($inputObj.attr("name") == "SVCLVL"){
					param.put("CMCDKY", "SVCLVL");	
				}else if($inputObj.attr("name") == "WANGBOK"){
					param.put("CMCDKY", "PLYTER");	
				}else if($inputObj.attr("name") == "DOKCHA"){
					param.put("CMCDKY", "EXCTER");	
				}
			}
			return param;
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
						<th CL="STD_COMPKY">Company Code</th>
						<td>
							<%-- <input type="text" name="COMPKY" value="<%=compky%>"  readonly="readonly" style="width:110px" />  <!-- UIInput="S,SHCOMMA"   --> --%>
							<input type="text" name="COMPKY" value="100"  readonly="readonly" style="width:110px" />  <!-- UIInput="S,SHCOMMA"   -->
						</td>
					</tr>
					<tr>
						<th>운임유형</th>
						<td>
							<input type="text" name="FARETP" UIInput="R,SHCMCDV" />
						</td>
					</tr>
					<tr>
						<th>운송계획지점</th>
						<td>
							<input type="text" name="PLNPOT" UIInput="R,SHCMCDV" />
						</td>
					</tr>
					<tr>
						<th>배송유형</th>
						<td>
							<input type="text" name="DELITP" UIInput="R,SHCMCDV" />
						</td>
					</tr>
					<tr>
						<th>운송사</th>
						<td>
							<input type="text" name="FWDCD" UIInput="R,SHCPN" />
						</td>
					</tr>
					<tr>
						<th>차량유형</th>
						<td>
							<input type="text" name="SFRGR" UIInput="R,SHCMCDV" />
						</td>
					</tr>					
					<tr>
						<th>운송경로</th>
						<td>
							<input type="text" name="TRACHA" UIInput="R,SHCMCDV" />
						</td>
					</tr>
					<tr>
						<th>서비스레벨</th>
						<td>
							<input type="text" name="SVCLVL" UIInput="R,SHCMCDV" />
						</td>
					</tr>
					<tr>
						<th>왕복조건</th>
						<td>
							<input type="text" name="WANGBOK" UIInput="R,SHCMCDV" />
						</td>
					</tr>
					<tr>
						<th>독차조건</th>
						<td>
							<input type="text" name="DOKCHA" UIInput="R,SHCMCDV" />
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
											<col width="40" />
											<col width="180" />
											<col width="180" />
											<col width="180" />
											<col width="65" />
											<col width="130" />
											<col width="65" />
											<col width="130" />
											<col width="65" />
											<col width="65" />
											<col width="110" />
											<col width="110" />
											<col width="110" />
											<col width="80" />
											<col width="80" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'></th>
												<th CL='STD_COMPKY'> 회사 </th>
												<th CL='STD_FARETP'>운임유형</th>
												<th CL='STD_PLNPOT'>운송계획지점</th>
												<th CL='STD_DELITP'>배송유형</th>
												<th CL='STD_FWDKEY'>운송사</th>
												<th CL='STD_DRIVNM'>운송사명</th>	
												<th CL='STD_ZPOSIT'>차량유형</th>
												<th CL='STD_VHCSTX'>차량유형명</th>
												<th CL='STD_TRACHA'>운송경로</th>
												<th CL='STD_COMPKY'>회사코드</th>
												<th CL='STD_SVCLVL'>서비스레벨</th>
												<th CL='STD_PLYTER'>왕복조건</th>
												<th CL='STD_EXCTER'>독차조건</th>
												<th CL='STD_PRIORTY'>우선순위</th>
												<th CL='STD_PRICE'>금액</th>
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="40" />											
											<col width="40" />
											<col width="180" />
											<col width="180" />
											<col width="180" />
											<col width="65" />
											<col width="130" />
											<col width="65" />
											<col width="130" />
											<col width="65" />
											<col width="65" />
											<col width="110" />
											<col width="110" />
											<col width="110" />
											<col width="80" />
											<col width="80" />
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<td GCol="input,MANDT" value="100" validate="required"> 회사 </td>
												<td GCol="select,FARETP" validate="required">
													<select CommonCombo="FARETP" id="FARETP">
														<option value="">선택</option>
													</select>	
												</td>
												<td GCol="select,PLNPOT" validate="required">
													<select CommonCombo="PLNPOT">
														<option value="">선택</option>
													</select>	
												</td>
												<td GCol="select,DELITP" validate="required">
													<select CommonCombo="DELITP">
														<option value="">선택</option>
													</select>	
												</td>
                                                <td GCol="input,FWDCD,SHCPN" validate="required"></td>
												<td GCol="text,FWDNME">운송사명</th>	
												<td GCol="input,SFRGR,SHCMCDV" validate="required" name="VHCTYP"></td>												
												<td GCol="text,VHCSTX">차량유형명</td>
												<td GCol="input,TRACHA">운송경로</td>
												<td GCol="input,COMPKY">회사코드</td>
												<td GCol="select,SVCLVL" validate="required">
													<select CommonCombo="SVCLVL" >
														<option value="">선택</option>
													</select>	
												</td>
												<td GCol="select,WANGBOK" validate="required">
													<select CommonCombo="PLYTER">
														<option value="">선택</option>
													</select>	
												</td>
												<td GCol="select,DOKCHA" validate="required">
													<select CommonCombo="EXCTER">
														<option value="">선택</option>
													</select>	
												</td>												
                                                <td GCol="input,PRIORTY">우선순위</td>
                                                <td GCol="input,PRICE" GF="N 10">금액</td>
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