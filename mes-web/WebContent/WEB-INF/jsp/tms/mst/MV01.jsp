<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>차량유형관리</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
	    	name : "gridList",
			editable : true,
			module : "TmsAdmin",
			command : "VHCTY",
			validation : "MANDT,VHCTYP,VHCSTX"
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

		if(gridList.validationCheck("gridList")){
			var MVlist = gridList.getGridData("gridList"); 
			param.put("MVlist", MVlist); 
			
			var json = netUtil.sendData({
				url : "/tms/mst/json/saveMV01.data",
				param : param
			}); 

			if(json && json.data){
					searchList();
			}  
        }				
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		
		if(colName == "VHCWHD" || colName == "VHCLNG" || colName == "VHCHIG"){     
	 		var VHCWHD = gridList.getColData("gridList", rowNum, "VHCWHD");   //폭
			var VHCLNG = gridList.getColData("gridList", rowNum, "VHCLNG");   //길이
			var VHCHIG = gridList.getColData("gridList", rowNum, "VHCHIG");   //높이	
		    var totMhd = (parseInt(VHCWHD) / 100) * (parseInt(VHCLNG) / 100);
			var totWhd = (parseInt(VHCWHD) / 100) * (parseInt(VHCLNG) / 100) * (parseInt(VHCHIG) / 100);
		    gridList.setColValue("gridList", rowNum, "RESUNT3", totMhd);	    gridList.setColValue("gridList", rowNum, "RESUNT4", totWhd);  
		}
		
 		if(gridId == "gridList" && colName == "VHCTYP"){  	
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
					commonUtil.msgBox("VALID_M0229", colValue);
					gridList.setColValue("gridList", rowNum, "VHCTYP", ""); 					
					gridList.setColValue("gridList", rowNum, "VHCSTX", ""); 
					checkValidationType = false;
				}			
			}else if(colValue==""){
				gridList.setColValue("gridList", rowNum, "VHCTYP", "");
				gridList.setColValue("gridList", rowNum, "VHCSTX", "");
				checkValidationType = true;
			}
		} 
	}
	
	function searchHelpEventOpenBefore(searchCode, gridType){
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
						<th CL="STD_ZPOSIT">차량유형 Code</th>
						<td>
							<input type="text" name="VHCTYP" UIInput="R,SHCMCDV" />
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
											<col width="100" /> 
											<col width="150" /> 
											<col width="80" /> 
											<col width="80" />
											<col width="80" />
											<!-- <col width="100" /> -->
											<col width="100" />
											<col width="100" />
											<col width="100" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'></th>
												<th CL='STD_ZPOSIT'>차량유형</th>
												<th CL='STD_VHCSTX'>차량유형명</th>
												<th CL='STD_VHCWHD'>폭</th>
												<th CL='STD_VHCHIG'>높이</th>
												<th CL='STD_VHCLNG'>길이</th>
												<th CL='STD_RESUNT2'>제한단위1(KG)</th>
												<th CL='STD_RESUNT3'>제한단위2(M2)</th>
												<th CL='STD_RESUNT4'>제한단위3(M3)</th>
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="40" />
											<col width="100" /> 
											<col width="150" /> 
											<col width="80" /> 
											<col width="80" />
											<col width="80" />
											<col width="100" />
											<col width="100" />
											<col width="100" /
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GCol="rownum">1</td> 
												<td GCol="input,VHCTYP,SHCMCDV" validate="required" ></td>
												<td GCol="text,VHCSTX" validate="required" >차량유형명</td>
												<td GCol="input,VHCWHD" validate="required maxlength(10)" GF="N 10,3">폭(m)</td>
												<td GCol="input,VHCHIG" validate="required maxlength(10)" GF="N 10,3">높이(m)</td>
												<td GCol="input,VHCLNG" validate="required maxlength(10)" GF="N 10,3">길이(m)</td>
												<td GCol="input,RESUNT2" validate="required maxlength(10)" GF="N 10,3" >제한단위2(KG)</td>
												<td GCol="text,RESUNT3" GF="N 10,3">제한단위3(M2)</td>
												<td GCol="text,RESUNT4" GF="N 10,3">제한단위4(M3)</td>
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