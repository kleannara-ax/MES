<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	request.setCharacterEncoding("UTF-8");
	String TASKKY = request.getParameter("TASKKY");
%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>IMV Mobile WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script>
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			editable : false,
			module : "Mobile",
			command : "MPT02",
			bindArea : "searchArea",
			gridMobileType : true
	    });
		searchList();
	});
	
	function searchList(){
		var param = new DataMap();
		param.put("TASKKY", "<%=TASKKY%>");
		param.put("WAREKY", "<%=wareky%>");
		
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });

		netUtil.send({
			module : "Mobile",
			command : "MPT02TOP",
			bindId : "MPT02TOP",
			sendType : "map",
			bindType : "field",
			param : param
		});
	}
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if( gridId == "gridList" && dataLength < 1 ){
			location.href="/mobile/MPT02.page";
		}else{
			showMain();	
		}
	}
	
	function showMain() {
		$("#detailInfo").hide();
		$("#main").show();
	}
	
	function savaData(){
		if(gridList.validationCheck("gridList", "select")){
			var locaky = $('#LOCAKY').val();
			
		 	if(locaky != ""){
				var param = new DataMap();
				param.put("LOCAKY",locaky);
			
				var json = netUtil.sendData({
					module : "Mobile",
					command : "LOCATION_VALIDATION",
					sendType : "map",
					param : param
				});
				
				if(json.data["CNT"] < 1){
					commonUtil.msgBox("MASTER_M0047");  // 존재하지 않는 로케이션입니다.;
					$('#LOCAKY').val("");
					$('#LOCAKY').focus();
					return;
				}
			} 

		 	var param = new DataMap();
			var list = gridList.getSelectData("gridList");
			if(list.length < 1){
				commonUtil.msgBox("VALID_M0006"); //선택한 데이터가 없습니다.
				return;
			}
			
			param.put("list",list);
			param.put("LOCAKY",locaky);
	
			var json = netUtil.sendData({
				url:"/mobile/Mobile/json/SaveMPT02.data",
				param : param
			});
			
	
			if(json && json.data){
				if(json.data.length > 5 && json.data.length != 10){
					var msgList = json.data.split("†");
					var msgTxt = commonUtil.getMsg(msgList[0], (msgList.length > 1 ? msgList[1].split("/") : null));
					commonUtil.msg(msgTxt);
					return;
				} 
				
				commonUtil.msgBox("MASTER_M0564");
				$('#LOCAKY').val("");
				searchList();
			}else{
				commonUtil.msgBox("VALID_M0002");
			}
		}
	}
 
 	function clearText(data){
		if(data!=null||data!=""){
	    	data.value="";
	    }      
	}

 	function showPre(){
 		location.href="/mobile/MPT02.page";
 	}
 	
  	function chkData(){
 		var taskBarcd = $('#TASKIT').val();

 		if(taskBarcd == ""){
 			commonUtil.msgBox("VALID_M0936"); //바코드를 입력해주세요.
 			return;
 		}
 		
 		var taskkyVal;
 		var taskitVal;
 		var compareVal;
 		
 		var rowCnt = gridList.getGridData("gridList");
 		for(var i = 0 ; i < rowCnt.length ; i ++){
 			taskkyVal = gridList.getColData("gridList", i, "TASKKY");
 			taskitVal = gridList.getColData("gridList", i, "TASKIT");
 			compareVal = taskkyVal + taskitVal;
 			
 			if(compareVal == taskBarcd){
 				gridList.setRowCheck("gridList", i, true);
 			}
 		}
 	} 
 	
</script>
</head>
<body>
	<div class="main_wrap" id="main">
	<div id="main_container">
		<div class="tem5_content">
			<div class="tableWrap_search section">
				<table class="util" id="MPT02TOP">
					<colgroup>
						<col width="100" />
					</colgroup>
					<tr>
						<th CL='STD_TASKKY'>&nbsp;&nbsp;&nbsp;</th> <!-- 작업지시번호  -->
						<td>
							<input type="text" name="TASKKY" readonly="readonly"/>
						</td>
					</tr>
					<tr>
						<th CL='STD_DOCDAT'>&nbsp;&nbsp;&nbsp;</th> <!-- 전기일자  -->
						<td>
							<input type="text" name="DOCDAT" readonly="readonly" />
						</td>
					</tr>
					<tr>
						<th CL='STD_IBARCD'>&nbsp;&nbsp;&nbsp;</th> <!-- 선택바코드  -->
						<td>
							<input type="text" class="text" id="TASKIT" onfocus="clearText(this)" onkeypress="commonUtil.enterKeyCheck(event, 'chkData()')" style="height: 35px;"/>
						</td>
						<td rowspan="3">
							<input type="button" CL="STD_DISPLAY" class="bt" onclick="chkData()"/> <!-- value="선택" -->
						</td>
					</tr>
				</table>
				<div class="tableHeader">
					<table style="width: 100%">
						<colgroup>
								<col width="30px" />
								<col width="30px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px" />
								<col width="180px" />
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
						</colgroup>
						<thead>
							<tr>
								<th CL='STD_NO'>No.</th>
								<th GBtnCheck="true"></th>
								<th CL='STD_TASKKY'></th>
								<th CL='STD_TASKIT'></th>
								<th CL='STD_AREAKY'></th>
								<th CL='STD_LOCASR'></th>
								<th CL='STD_LOCATG'></th>
								<th CL='STD_SKUKEY'></th>
								<th CL='STD_DESC01'></th>
								<th CL='STD_ORDQTY'></th>
								<th CL='STD_QTCOMP'></th>
								<th CL='STD_UOMKEY'></th>
							</tr>
						</thead>
					</table>				
				</div>					
				<div class="tableBody">
					<table style="width: 100%">
						<colgroup>
								<col width="30px" />
								<col width="30px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px" />
								<col width="180px" />
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rownum">1</td>
								<td GCol="rowCheck"></td>
								<td GCol="text,TASKKY"></td>
								<td GCol="text,TASKIT"></td>
								<td GCol="text,AREAKY"></td>
								<td GCol="text,LOCASR"></td>
								<td GCol="text,LOCATG"></td>
								<td GCol="text,SKUKEY"></td>					
								<td GCol="text,DESC01"></td>
								<td GCol="text,QTTAOR" GF="N"></td>
								<td GCol="input,QTCOMP" GF="N" validate="max(GRID_COL_QTTAOR_*),HHT_T0019"></td>
								<td GCol="text,UOMKEY"></td>
							</tr>
						</tbody>
					</table>
				</div>
				</div>
				<div>
					<table>
						<tr height="50px">
							<th CL="STD_LOCAKY">적치로케이션</th>	
							<td><input type="text" name="LOCAKY" id="LOCAKY" /></td>
						</tr>
					</table>
				</div>
				<!-- end table_body -->
				<div class="footer_5">
					<table>
						<tr>
							<td onclick="showPre()"><label CL='STD_CDSCAN'></label></td>
							<td class=f_1 onclick ="savaData()"><label CL='BTN_SAVE'></label></td>
						</tr>
					</table>
				</div><!-- end footer_5 -->	
			</div>
	</div>
	</div>
</body>