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
			editable : true,
			pkcol : "LANGKY,MESGGR,MESGKY",
			module : "System",
			command : "MESSAGE"
	    });
	});
	
	function searchList(){
		//var param = dataBind.paramData("searchArea");
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			//alert(param);
			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
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
			
			//alert(json);
			if(json && json.data){
				//loadMessage();
				searchList();
			}	
		}
	}
	
	function loadMessage(){
		var json = netUtil.sendData({
			url : "/common/message/json/reload.data"
		});
		if(json && json.data){
			
		}
	}
	
	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}else if(btnName == "Reload"){
			loadMessage();
		}
	}
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY"></button>
		<button CB="Save SAVE STD_SAVE"></button>
		<button CB="Reload EXECUTE BTN_RELOAD"></button>
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
				</colgroup>
				<tbody>
					<tr>
						<th CL="STD_LANGKY">언어</th>
						<td>
							<input type="text" name="LANGKY" value="<%=langky%>" UIInput="R,SHMSGLK" />
						</td>
					</tr>
					<tr>
						<th CL="STD_MESGGR">메시지 그룹</th> 
						<td>
							<input type="text" name="MESGGR" UIInput="R,SHMSGGR" />
						</td>
					</tr>
					<tr>
						<th CL="STD_MESGKY">메시지 키</th> 
						<td>
							<input type="text" name="MESGKY" UIInput="R,SHMSGKY" />
						</td>
					</tr>
					<tr>
						<th CL="STD_MESGTX">메시지 설명</th> 
						<td>
							<input type="text" name="MESGTX" UIInput="R" />
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
											<col width="50" /> 
											<col width="100" />
											<col width="100" />
											<col width="200" />
											<!-- <col width="50" /> -->
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<th CL='STD_LANGKY'>언어</th>
												<th CL='STD_MESGGR'>메시지 그룹</th>
												<th CL='STD_MESGKY'>메시지 키</th>
												<th CL='STD_MESGTX'>라벨 설명</th>
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="40" />
											<col width="50" /> 
											<col width="100" />
											<col width="100" />
											<col width="200" />
											<!-- <col width="50" /> -->
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GCol="rownum">1</td>                              
												<td GCol="input,LANGKY,SHMSGLK" validate="required,SYSTEM_M0024" GF="S 3"></td>            
												<td GCol="input,MESGGR,SHMSGGR" validate="required" GF="S 10"></td>      
												<td GCol="input,MESGKY,SHMSGKY" validate="required" GF="S 20"></td>      
												<td GCol="input,MESGTX" GF="S 1000"></td>
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
		<!-- //contentContainer -->
	</div>
</div>
<!-- //content -->
<%@ include file="/common/include/bottom.jsp" %>
</body>
</html>