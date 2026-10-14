<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			module : "Demo",
			command : "FWCMFL001_DEMO"
	    });
		
		gridList.appendCols("gridList", ["UUID_FILEVIEW","ATTACH_FILEVIEW","BYTE_FILESIZEVIEW"]);
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
		if(gridList.validationCheck("gridList", "all")){
			var modifyList = gridList.getModifyList("gridList", "A");
        	var modifyListLen = modifyList.length;
        	
        	if(modifyListLen > 0){
        		 if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
                     return;
                 }
				 
        		 var param = new DataMap();
        		 param.put("list",modifyList);
        		 
                 netUtil.send({
                     url : "/demo/hwls/json/saveFile.data",
                     param : param,
                     successFunction : "saveCallBack"
                 });
        	}
		}		
	}
	
	function saveCallBack(json, status){
		if(json && json.data){
			searchList();
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
		<button CB="Search SEARCH BTN_DISPLAY"></button>
		<button CB="Save SAVE STD_SAVE"></button>
	</div>
</div>
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
						<div class="section type1" id="gridButtonArea">
							<div class="table type2">
								<div class="tableBody">
									<table>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GH="40" GCol="rownum">1</td>
												<td GH="40" GCol="rowCheck"></td>
												<td GH="250 STD_ATTACH"   GCol="file,ATTACH"/></td>
												<td GH="250 STD_FILEDOWN" GCol="fileDownload,UUID"/></td>
												<td GH="100 STD_FILESIZE" GCol="fileSize,BYTE"/></td>
												<td GH="500 STD_ETCTXT"   GCol="input,ETCTXT"/></td>
											</tr>									
										</tbody>
									</table>
								</div>
							</div>							
							<div class="tableUtil">
								<div class="leftArea">
									<button type="button" GBtn="find"></button>
									<button type="button" GBtn="add"></button>
									<button type="button" GBtn="delete"></button>
								</div>
								<div class="rightArea">
									<p class="record" GInfoArea="true">0 Record</p>
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