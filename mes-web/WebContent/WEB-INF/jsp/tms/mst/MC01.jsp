<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>월대차량관리</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
	    	name : "gridList",
			editable : true,
			/* pkcol : "MANDT,VHCFNO,FWDKEY,VHCTYP", */ 
			module : "TmsAdmin",
			command : "VHCMT",
			validation : "VHCFNO,FWDKEY,VHCTYP,PERVNM,PERHNO"
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
		/*	var json = gridList.gridSave({
	    	id : "gridList",
	    	param : param
	    });	*/ 
		if(gridList.validationCheck("gridList")){
			var list = gridList.getGridData("gridList"); 
			param.put("list", list); 
			
			var json = netUtil.sendData({
				url : "/tms/mst/json/saveMC01.data",
				param : param
			}); 
	
			if(json && json.data){
					searchList();
			} 
		}
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){		
		if(gridId == "gridList" && colName == "FWDKEY"){  //운송사
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
					gridList.setColValue("gridList", rowNum, "FWDKEY", ""); 
					gridList.setColValue("gridList", rowNum, "FWDNME", ""); 
					checkValidationType = false;
				 }			
			}else if(colValue==""){
				gridList.setColValue("gridList", rowNum, "FWDNME", "");
				checkValidationType = true;
			}
		}else if(gridId == "gridList" && colName == "VHCTYP"){  //차량유형
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
						gridList.setColValue("gridList", rowNum, "VHCSTS", json.data["CDESC1"]); 
					} 
					checkValidationType = true;
				} else if (json.data["CNT"] < 1) {
					commonUtil.msgBox("VALID_M0228", colValue);
					gridList.setColValue("gridList", rowNum, "VHCTYP", ""); 
					gridList.setColValue("gridList", rowNum, "VHCSTS", ""); 
					checkValidationType = false;
				}			
			}else if(colValue==""){
				gridList.setColValue("gridList", rowNum, "VHCSTS", "");
				checkValidationType = true;
			}
		}else if(gridId == "gridList" && colName == "SFRGR"){  //차량번호 VHCFNO
			if(colValue != ""){
				var param = new DataMap();
				param.put("AREAKY",colValue);
				var json = netUtil.sendData({
					module : "TmsAdmin",
					command : "DEPREGval",
					sendType : "map",
					param : param
				});
				if(json.data["CNT"] > 0) {
					var param = new DataMap();
					param.put("AREAKY",colValue);
					var json = netUtil.sendData({
						module : "TmsAdmin",
						command : "DEPREGnm",
						sendType : "map",
						param : param
					});
					 if(json && json.data){
						gridList.setColValue("gridList", rowNum, "VHCSTX", json.data["SHORTX"]); 
					}  
					checkValidationType = true;
				 }  else if (json.data["CNT"] < 1) {		
					commonUtil.msgBox("VALID_M0229", colValue);
					gridList.setColValue("gridList", rowNum, "VHCSTX", ""); 
					checkValidationType = false;
				}  			
			}else if(colValue==""){
				gridList.setColValue("gridList", rowNum, "VHCSTX", "");
				checkValidationType = true;
			}
		}
	}
		
	
	function searchHelpEventOpenBefore(searchCode, gridType, $inputObj){
		if(searchCode == "SHCMCDV"){
			//var param =dataBind.paramData("searchArea");
			var param = inputList.setRangeParam("searchArea");
			param.put("CMCDKY", "VHCTYP");
			return param;
		}else if(searchCode == "SHWAHMA"){
			return dataBind.paramData("searchArea");
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
						<th CL="STD_WAREKY">Center Code</th>
						<td>
							<input type="text" name="WAREKY" value="<%=wareky%>" UIInput="S,SHAREMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_SHPTKY">출하지점 Code</th>
						<td>
							<input type="text" name="SHPTKY" UIInput="R,SHPTKY" />
						</td>
					</tr> 					
					<tr>
						<th CL="STD_ZPOSIT">차량유형 Code</th>
						<td>
							<input type="text" name="VHCTYP" UIInput="R,SHCMCDV" />
						</td>
					</tr>
<!-- 					<tr>
						<th CL="STD_CODEKY">차량유형명 Code</th>
						<td>
							<input type="text" name="VHCSTX" UIInput="S,SHWAHMA" />
						</td>
					</tr> -->
					<tr>
						<th CL="STD_STDNLR">차량번호</th>
						<td>
							<input type="text" name="VHCFNO" UIInput="R,VHCFNO" />
						</td>
					</tr>
					<tr>
						<th CL="STD_DRIVER">기사명 Code</th>
						<td>
							<input type="text" name="PERVNM" UIInput="S,PERVNM" />
						</td>
					</tr>
					<tr>
						<th CL="STD_TRPTKY">운송사 Code</th>
						<td>
							<input type="text" name="FWDKEY" UIInput="S,SHCPN" />
						</td>
					</tr>
<!-- 					<tr>
						<th CL="STD_DRIVNM">운송사명 Code</th>
						<td>
							<input type="text" name="FWDNME" UIInput="S,SHWAHMA" />
						</td>
					</tr>	 -->			    
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
											<col width="100" /> 
											<col width="100" /> 
											<col width="100" /> 
											<col width="100" />
											<col width="150" />
											<col width="100" />
											<col width="100" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'></th>
												<th CL='STD_VEHINO'>차량번호</th>
												<th CL='STD_TRPTKY'>운송사</th>												
												<th CL='STD_DRIVNM'>운송사명</th>
												<th CL='STD_DRIVER'>기사명</th>
												<th CL='STD_GROUP6'>전화번호</th>
												<th CL='STD_ZPOSIT'>차량유형</th>
												<th CL='STD_VHCSTX'>차량유형명</th>																					
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="40" />
											<col width="100" /> 
											<col width="100" /> 
											<col width="100" /> 
											<col width="100" />
											<col width="150" />
											<col width="100" />
											<col width="100" />						
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<td GCol="input,VHCFNO,VHCFNO" validate="required" >차량번호</td>												
												<td GCol="input,FWDKEY,SHCPN" validate="required" >운송사</td>	
												<td GCol="text,FWDNME">운송사명</td>
												<td GCol="input,PERVNM" validate="required">기사명</td>
												<td GCol="input,PERHNO" validate="tel(GRID_COL_TELN01_*)">전화번호1</td>
												<td GCol="input,VHCTYP,SHCMCDV" validate="required" >차량유형</td>											
												<td GCol="text,VHCSTS" validate="required" >차량유형명</td>
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