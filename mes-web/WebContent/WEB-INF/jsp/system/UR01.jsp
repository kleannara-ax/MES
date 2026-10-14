<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript">
	var tabNum = 1; 
	$(document).ready(function(){
		 gridList.setGrid({
	    	id : "gridList1",
			editable : true,
			pkcol : "UROLKY,WAREKY",
			module : "System",
			command : "UR01WK",
			validation : "WAREKY" 
	    }); 
		gridList.setGrid({
	    	id : "gridList2",
			editable : true,
			pkcol : "UROLKY,PROGID",
			module : "System",
			command : "UR01PG",
			validation : "PROGID"  
		 }); 
		 gridList.setGrid({
	    	id : "gridList3",
			editable : true,
			pkcol : "UROLKY,USERID",
			module : "System",
			command : "UR01US",
			validation : "USERID" 
	    }); 
	});
	
	function searchList() {
		//var param = dataBind.paramData("searchArea");
		
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");		
			//alert(param);
			gridList.gridList({
				id : "gridList1",
				param : param
			});
			gridList.gridList({
				id : "gridList2",
				param : param
			});
			gridList.gridList({
				id : "gridList3",
				param : param
			});
			netUtil.send({
				module : "System",
				command : "UR01TOP",
				bindId : "ur01top",
				sendType : "map",
				bindType : "field",
				param : param
			});
		}
	}
	
	function saveData(){
		var gridId = "gridList" + tabNum;

		var list = dataBind.paramData("foldSect");
		
		var paramF = new DataMap();
		
		paramF.put("list", list);
		
		var json = netUtil.sendData({
			url : "/wms/system/json/UR01.data",
			param : paramF
		});  
		//alert(JSON.stringify(json))
		
		var modCnt = gridList.getModifyRowCount(gridId);

		if(modCnt == 0){
			commonUtil.msgBox("MASTER_M0545");
			return;
		}
		
		
		if(gridList.validationCheck(gridId, "modify")){
			var param = dataBind.paramData("searchArea");
			
			var json = gridList.gridSave({
		    	id : gridId,
		    	param : param
		    });
			
			if(json && json.data){
				searchList();
			}
		}
	}
 
    function tabChg(num){
        var gridId = "gridList"+num;
       /*  var param = dataBind.paramData("searchArea");
           
        gridList.gridList({
            id : gridId,
            param : param
         });  */
      
        tabNum = num
     } 
    
	function gridListEventRowAddBefore(gridId, rowNum){
		var param = inputList.setRangeParam("searchArea");
		
		var urolky = param.get("UROLKY");
		
		var newData = new DataMap();
		
		newData.put("UROLKY", urolky);
		
		return newData;
	}
	
	function warekyCheck(valueTxt, $colObj){
		var rowNum = gridList.getColObjRowNum("gridList1", $colObj);
		var rowCount = gridList.getGridDataCount("gridList1");
		for(var i=0;i<rowCount;i++){
			if(i != rowNum){
				var wareky = gridList.getColData("gridList1", i, "WAREKY");
				
				if(wareky == valueTxt){
					return false;
				}
			}			
		}
		return true;
	} 
	
	function progidCheck(valueTxt, $colObj){
		var rowNum = gridList.getColObjRowNum("gridList2", $colObj);
		var rowCount = gridList.getGridDataCount("gridList2");
		
		for(var i=0;i<rowCount;i++){
			if(i != rowNum){
				var progid = gridList.getColData("gridList2", i, "PROGID");
				
				if(progid == valueTxt){
					return false;
				}
			}			
		}
		return true;
	}
	
	function useridCheck(valueTxt, $colObj){
		var rowNum = gridList.getColObjRowNum("gridList3", $colObj);
		var rowCount = gridList.getGridDataCount("gridList3");
		for(var i=0;i<rowCount;i++){
			if(i != rowNum){
				var userid = gridList.getColData("gridList", i, "USERID");
				
				if(userid == valueTxt){
					return false;
				}
			}			
		}
		return true;
	}
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId == "gridList3" && colName == "USERID"){
			if(colValue != ""){
				var param = new DataMap();
				
				param.put("USERID",colValue);
				
				var json = netUtil.sendData({
					module : "System",
					command : "USERIDval",
					sendType : "map",
					param : param
				});
				
				if(json.data["CNT"] >= 1) {
					var param = new DataMap();
					
					param.put("USERID",colValue);
					
					var cmd = 'NMLAST';
					
					for(var i = 0 ; i < 2 ; i ++){
						if(i == 1){
							 cmd = 'NMFIRS';
						}
						var json = netUtil.sendData({
							module : "System",
							command : cmd,
							sendType : "map",
							param : param
						});
						
						if(json && json.data){
							gridList.setColValue("gridList3", rowNum, cmd, json.data[cmd]); 
						}
					}
					
				} else if (json.data["CNT"] <= 1) {
					commonUtil.msgBox("MASTER_M0541");
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
			<!-- <button CB="GetVariant GETVARIANT BTN_GETVARIANT"></button>
			<button CB="SaveVariant SAVEVARIANT BTN_SAVEVARIANT"></button> -->
		</p>
		
		<div class="searchInBox">
			<h2 class="tit" CL="STD_SELECTOPTIONS">검색조건</h2>
			<table class="table type1">
				<colgroup>
					<col width="100" />
					<col />
					<col width="100" />
					<col />
				</colgroup>
				<tbody>
					<tr>
						<th CL="STD_UROLKY">권한관리키</th>
						<td colspan="3">
							<input type="text" name="UROLKY" UIInput="S,SHROLDF" validate="required,SYSTEM_M0084" value="" />
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

			<!-- TOP FieldSet -->
			<div class="foldSect" id="foldSect" >
				<div class="tabs">
				  <ul class="tab type2">
					<li><a href="#tabs-1"><span CL='STD_GENERAL'>탭메뉴1</span></a></li>
				  </ul>
				  <div id="tabs-1">
					<div class="section type1">
						<table class="table type1" id="ur01top">
							<colgroup>
								<col />
								<col />
								<col />
								<col />
							</colgroup>
							<tbody>
								<tr>
									<th CL="STD_UROLKY">사용자권한키</th>
									<td>
										<input type="text" name="UROLKY" readonly="readonly" />
									</td>
								</tr>
								<tr>
									<th CL="STD_SHORTX">설명</th>
									<td>
										<input type="text" name="SHORTX" />
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				  </div>
				</div>
			</div>
			
			<!-- BOTTOM FieldSet -->
			<div class="bottomSect">
				<button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button>
				<div class="tabs" id="bottomTabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1" id="tabs01" onclick="tabChg(1)"><span CL="STD_CONNECTIVITY">탭메뉴1</span></a></li>
						<li><a href="#tabs1-2" id="tabs02" onclick="tabChg(2)"><span CL="STD_PROGRAMS">탭메뉴2</span></a></li>
						<li><a href="#tabs1-3" id="tabs03" onclick="tabChg(3)"><span CL="STD_ASSIGNTOUSER">탭메뉴3</span></a></li>
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
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'></th>
												<th CL='STD_UROLKY'>사용자권한키</th>
												<th CL='STD_WAREKY'>거점</th>
												<th CL='STD_CREDOC'>문서생성권한</th>
												<th CL='STD_ACTVAT'>활성화</th>
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
										</colgroup>
										<tbody id="gridList1">
											<tr CGRow="true">
												<td GCol="rownum">1</td>											
												<td GCol="text,UROLKY"></td>
												<td GCol="input,WAREKY,SHWAHMA"></td>
												<td GCol="check,CREDOC"></td>
												<td GCol="check,ACTVAT"></td>
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
					<div id="tabs1-2">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
											<col width="40" />
											<col width="100" />
											<col width="100" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'></th>
												<th CL='STD_UROLKY'>사용자권한키</th>
												<th CL='STD_PROGID'>프로그램id</th>
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
										</colgroup>
										<tbody id="gridList2">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<td GCol="text,UROLKY"></td> 
												<td GCol="input,PROGID,SHPROGM" validate="required,SYSTEM_M0006" GF="S 20"></td>
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
					<div id="tabs1-3">
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
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'></th>
												<th CL='STD_UROLKY'>사용자권한키</th>
												<th CL='STD_USERID'>사용자ID</th>
												<th CL='STD_NMLAST'>이름</th>
												<th CL='STD_NMFIRS'>관련업무</th>
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
										</colgroup>
										<tbody id="gridList3">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<td GCol="text,UROLKY"></td>
												<td GCol="input,USERID,SHUSRMA" validate="required,MASTER_M0001" GF="S 20"></td>  
												<td GCol="text,NMLAST"></td>
												<td GCol="text,NMFIRS"></td>
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