<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	request.setCharacterEncoding("UTF-8");
	String AREAKY = request.getParameter("AREAKY");
	String LOCAKY = request.getParameter("LOCAKY");
	String SKUKEY = request.getParameter("SKUKEY");
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
			command : "MIP04",
			bindArea : "searchArea",
			gridMobileType : true
	    });
		
		searchList();
	});
	
	function searchList(){
		var param = new DataMap();
		param.put("AREAKY", "<%=AREAKY%>");
		param.put("WAREKY", "<%=wareky%>");
		param.put("SKUKEY", "<%=SKUKEY%>");
		param.put("LOCAKY", "<%=LOCAKY%>");
		
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
	}
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if( gridId == "gridList" && dataLength < 1 ){
			location.href="/mobile/MIP04.page";
		}else{
			showMain();	
		}
	}
	
	function showMain() {
		$("#detailInfo").hide();
		$("#main").show();
	}
	
	function saveData(){	
		var docdat = $('#DOCDAT').val();
		var doctxt = $('#DOCTXT').val();
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		} 
		if(gridList.validationCheck("gridList", "all")){
			var docunum = wms.getDocSeq("515");
			var list = gridList.getSelectModifyList("gridList");
			
			if(list.length == 0){
				commonUtil.msgBox("INV_M0055",docunum);
				return;
			}
			
			var param = new DataMap();
			param.put("list", list);
			param.put("DOCDAT", docdat);
			param.put("DOCTXT", doctxt);
			param.put("PHYIKY", docunum);
			
			var json = netUtil.sendData({
				url : "/mobile/Mobile/json/SaveMIP04.data",
				param : param
			});
			
			if(json && json.data){
				commonUtil.msgBox("INV_M0051", docunum); 
				showPre();
			}	 
		}
	}
 
 	function clearText(data){
		if(data!=null||data!=""){
	    	data.value="";
	    }      
	}
	
 	function showPre(){
 		location.href="/mobile/MIP04.page";
 	}
 	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue){
		if(gridId == "gridList"){
			var useqty = new Number(gridList.getColData(gridId, rowNum, "USEQTY"));
			if(colName == "QTSPHY"){
				var value = new Number(gridList.getColData(gridId, rowNum, "QTADJU"));
				var chgValue = value + useqty;
				if(colValue != chgValue){
					var qtsphy = new Number(colValue);
					var qtadju = qtsphy - useqty;
					gridList.setColValue("gridList", rowNum, "QTADJU", qtadju);
				}
			}else if(colName == "QTADJU"){
				var value = new Number(gridList.getColData(gridId, rowNum, "QTSPHY"));
				var chgValue = value - useqty;
				if(colValue != chgValue){
					var qtadju = new Number(colValue);
					var qtsphy = qtadju + useqty;
					gridList.setColValue("gridList", rowNum, "QTSPHY", qtsphy);
				}
			}			
		}
	}
	
	function setRsnadj(){
		var rsnadjCombo = $("#rsnadjCombo").val();
		if(rsnadjCombo){
			var selectNumList = gridList.getSelectRowNumList("gridList");
			
			if(selectNumList.length < 1){
				commonUtil.msgBox("VALID_M0006"); //선택된 데이터가 없습니다.
			} 
			
			for(var i=0;i<selectNumList.length;i++){
				var rowNum = selectNumList[i];
				gridList.setColValue("gridList", rowNum, "RSNADJ", rsnadjCombo);
			}
		}else{
			commonUtil.msgBox("MASTER_M0688"); //사유코드를 선택해주세요.
		}
	}
</script>
</head>
<body>
	<div class="main_wrap" id="main">
	<div id="main_container">
		<div class="tem5_content">
			<div class="tableWrap_search section">
				<table class="util" id="MPT01TOP">
					<colgroup>
						<col width="100" />
					</colgroup>
					<tr>
						<th CL='STD_DOCDAT'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:</th> <!-- 전기일자 -->
						<td>
							<input type="text" name="DOCDAT" id="DOCDAT" UIFormat="C N" />
						</td>
					</tr>
					<tr>
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
						<th CL='STD_DOCTXT'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:</th> <!-- 비고 -->
						<td>
							<input type="text" name="DOCTXT" id="DOCTXT" size="100"/>
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
							<col width="100" />
							<col width="100" />
						</colgroup>
						<thead>
							<tr>
								<th CL='STD_NUMBER'>번호</th>
								<th GBtnCheck="true"></th>
								<th CL='STD_RSNADJ'></th>
								<th CL='STD_QTSPHY'></th>
								<th CL='STD_QTADJU'></th>
								<th CL='STD_QTYSTL'></th>
								<th CL='STD_QTSIWH'></th>
								<th CL='STD_USEQTY'></th>
								<th CL='STD_LOCAKY'></th>
								<th CL='STD_SKUKEY'></th>
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
							<col width="100" />
							<col width="100" />
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rownum">1</td>
								<td GCol="rowCheck"></td>
								<td GCol="select,RSNADJ" validate="required,INV_M0054">
									<select ReasonCombo="510">
										<option value=""> </option>
									</select>
								</td>
								<td GCol="input,QTSPHY" validate="required min(0),IN_M0048" GF="N 20,3"></td>
								<td GCol="input,QTADJU" GF="N 20,3"></td>
								<td GCol="text,QTYSTL" GF="N"></td>
								<td GCol="text,QTSIWH" GF="N"></td>
								<td GCol="text,USEQTY" GF="N"></td>
								<td GCol="text,LOCAKY"></td>
								<td GCol="text,SKUKEY"></td>
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