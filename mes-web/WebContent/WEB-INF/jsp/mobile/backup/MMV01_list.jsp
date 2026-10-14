<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	request.setCharacterEncoding("UTF-8");
	String AREAKY = request.getParameter("AREAKY");
	String LOCAKY = request.getParameter("LOCAKY");
	String SKUKEY = request.getParameter("SKUKEY");
	String LOCATG = request.getParameter("LOCATG");
	String TASOTY = "320";
	String PTNRKY = " ";
%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>IMV Mobile WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script>
var headData;
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			editable : false,
			//module : "Mobile",
			//command : "MMV07",
			module : "WmsTask",
			command : "MV01BODY",
			bindArea : "searchArea",
			gridMobileType : true
	    });
		
		searchHeadData();
		
// 		searchList();
	});
	
	function searchList(){
		var param = new DataMap();
		param.put("AREAKY", "<%=AREAKY%>");
		param.put("WAREKY", "<%=wareky%>");
		param.put("SKUKEY", "<%=SKUKEY%>");
		param.put("LOCAKY", "<%=LOCAKY%>");
		param.put("TASOTY", "<%=TASOTY%>");
		param.put("PTNRKY", "<%=PTNRKY%>");
		param.put("PROGID", "MMV01");
		
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
	}

function searchHeadData() {
	//var param = inputList.setRangeParam("searchArea");
	var param = new DataMap();
	param.put("AREAKY", "<%=AREAKY%>");
	param.put("WAREKY", "<%=wareky%>");
	param.put("SKUKEY", "<%=SKUKEY%>");
	param.put("LOCAKY", "<%=LOCAKY%>");
	param.put("TASOTY", "<%=TASOTY%>");
	param.put("PTNRKY", "<%=PTNRKY%>");
	
	var json = netUtil.sendData({
		url : "/common/WmsTask/list/json/MV01HEAD.data",
		param : param,
	});
	
	headData = json.data;
	searchList();
}	
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if( gridId == "gridList" && dataLength < 1 ){
			location.href="/mobile/MMV01.page";
		}else{
			showMain();	
		}
	}
	
	function showMain() {
		$("#detailInfo").hide();
		$("#main").show();
	}
	
	
	function saveData(){
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		}
		if(gridList.validationCheck("gridList", "all")){
			var chkRowCnt = gridList.getSelectRowNumList("gridList").length;
			var chkRowIdx = gridList.getSelectRowNumList("gridList");
			
			var flag = "";
			for(var j = 0; j < chkRowCnt; j++){
				var valString = gridList.getColData("gridList", chkRowIdx[j], "LOCATG");
				var qtyalab = gridList.getColData("gridList", chkRowIdx[j], "AVAILABLEQTY"); // 가용수량
				var qtraor = gridList.getColData("gridList", chkRowIdx[j], "QTTAOR");  // 작업수량
				
				if(valString == null || valString ==  "" || valString == " "){
					flag = "1";
					break;
				}
				
				if(parseInt(qtyalab) < parseInt(qtraor)){
					flag = "2";
					break;
				}
			}
			
			if(flag == "1"){
				commonUtil.msgBox("COMMON_M0009", "To Location");
				return;
			}else if(flag == "2"){
				commonUtil.msgBox("TASK_M0023");
				return;
			}
			
			if(chkRowCnt > 0){
				
				//재고 이동 
				var docunum = wms.getDocSeq("320");
				headData[0].TASKKY = docunum;
				
				for(var i = 0; i < chkRowCnt; i++){
					gridList.setColValue("gridList", chkRowIdx[i], "TASKKY", docunum);
				}
				
				var head = headData[0];
				var list = gridList.getSelectData("gridList");
				
				var param = new DataMap();
				param.put("head", head);
				param.put("list", list);
				
				var json = netUtil.sendData({
					url : "/wms/task/json/MV01CreatTaskOrder.data",
					param : param
				});
				
				if(json.MSG && json.MSG != 'OK'){
					var msgList = json.data.split("†");
					var msgTxt = commonUtil.getMsg(msgList[0], (msgList.length > 1 ? msgList[1].split("/") : null));
					commonUtil.msg(msgTxt);
					return;
					
					headData[0].TASKKY = "";
					for(var i = 0; i < chkRowCnt; i++){
						gridList.setColValue("gridList", chkRowIdx[i], "TASKKY", "");
					}
				}else if(json.data){
					if(json.data){
						commonUtil.msgBox("COMMON_M0007", docunum);
						gridList.resetGrid("gridList");
						searchHeadData();
					}
				}
			}else{
				commonUtil.msgBox("TASK_M0003");
				return false;
			}
		}
	}
 
 	function clearText(data){
		if(data!=null||data!=""){
	    	data.value="";
	    }      
	}
	
 	function showPre(){
 		location.href="/mobile/MMV01.page";
 	}
 	
 	function commonBtnClick(btnName){
		if(btnName == "Reflect"){
			reflect();
		}
	}
 	
 	function reflect(){
 		var locatg = $.trim($("#LOCATG").val());
 		
 		if(locatg == ""){
 			commonUtil.msgBox("Please input To Location.");
 			$("#LOCATG").focus();
 			return;
 		}
 		
 		var list = gridList.getSelectData("gridList");
 		if(list.length ==  0){
 			commonUtil.msgBox("VALID_M0006"); //선택된 데이터가 없습니다.
			return;
 		}
 		
 		for(var i = 0; i < list.length; i++){
 			gridList.setColValue("gridList", list[i].get("GRowNum"), "LOCATG", locatg);
 		}
 	}
</script>
</head>
<body>
	<div class="main_wrap" id="main">
	<div id="main_container">
		<div class="tem5_content" >
			<div class="tableWrap_search section">
				<table class="util" id="MPT01TOP">
					<colgroup>
						<col width="100" />
					</colgroup>
					<tr>
						<th CL='STD_DOCDAT'>&nbsp;&nbsp;:</th> <!-- 전기일자 -->
						<td>
							<input type="text" name="DOCDAT" id="DOCDAT" UIFormat="C N" />
						</td>
					</tr>
				<!-- 	<tr>
						<th CL="STD_RSNADJ"></th>
						<td>
							<select ReasonCombo="510" id="rsnadjCombo" style="width: 174px;">
								<option value=""> </option>
							</select>
						</td>
						<td>
							<input type="button" CL="BTN_APPLYB" class="bt" onclick="setRsnadj()"/>
						</td>
					</tr>
					<tr>
						<th CL='STD_DOCTXT'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:</th> 비고
						<td>
							<input type="text" name="DOCTXT" id="DOCTXT" size="100"/>
						</td>
					</tr> -->
					<tr>
						<th CL='STD_LOCATG'>&nbsp;&nbsp;&nbsp;:</th>
						<td>
							<input type="text" name="LOCATG" id="LOCATG" size="20" />
							<button CB="Reflect REFLECT BTN_REFLECT"></button>
						</td>
					</tr>
				</table>
				<div class="tableHeader">
					<table style="width: 100%">
						<colgroup>
							<col width="40" />
							<col width="40" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
<!-- 							<col width="100" /> -->
							<col width="100" />
							<col width="100" />
<!-- 							<col width="100" /> -->
							<col width="100" />
						</colgroup>
						<thead>
							<tr>
								<th CL='STD_NUMBER'>번호</th>
								<th GBtnCheck="true"></th>
								<th CL='STD_SKUKEY'></th>
								<th CL='STD_DESC01'></th>
								<th CL='STD_DESC02'></th>
								<th CL='STD_SKUG05'></th>
								<th CL='STD_QTSIWH'></th>
								<th CL='STD_USEQTY'></th>
								<th CL='STD_QTTAOR'></th>
<!-- 								<th CL='STD_QTADJU'></th> -->
<!-- 								<th CL='STD_QTYSTL'></th> -->
								<th CL='STD_LOCAKY'></th>
								<th CL='STD_LOCATG'></th>
							</tr>
						</thead>
					</table>
				</div>
				<div class="tableBody">
					<table>
						<colgroup>
							<col width="40" />
							<col width="40" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
							<col width="100" />
<!-- 							<col width="100" /> -->
							<col width="100" />
							<col width="100" />
<!-- 							<col width="100" /> -->
							<col width="100" />
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rownum">1</td>
								<td GCol="rowCheck"></td>
								<td GCol="text,SKUKEY"></td>
								<td GCol="text,DESC01"></td>
								<td GCol="text,DESC02"></td>
								<td GCol="text,SKUG05"></td>
								<td GCol="text,QTSIWH" GF="N"></td>
								<td GCol="text,AVAILABLEQTY" GF="N"></td>
								<!-- <td GCol="select,RSNADJ" validate="required,INV_M0054">
									<select ReasonCombo="510">
										<option value=""> </option>
									</select>
								</td> -->
								<td GCol="input,QTTAOR" validate="required min(0),IN_M0048 max(GRID_COL_AVAILABLEQTY_*)" GF="N 20"></td>
<!-- 								<td GCol="input,QTADJU" GF="N 20,3"></td> -->
<!-- 								<td GCol="text,QTYSTL"></td> -->
								<td GCol="text,LOCAKY"></td>
								<td GCol="input,LOCATG" GF="S 20"></td>
							</tr>									
						</tbody>
					</table>
				</div>
				</div>
				<!-- end table_body -->
				<div class="footer_5">
					<table>
						<tr>
							<td onclick="showPre()"><label CL='STD_CDSCAN'></label></td>
							<td class=f_1 onclick ="saveData()"><label CL='BTN_SAVE'></label></td>
						</tr>
					</table>
				</div><!-- end footer_5 -->	
			</div>
	</div>
	</div>
</body>