<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.common.bean.*,com.common.util.*,com.common.bean.CommonConfig,java.util.*"%>
<%
	request.setCharacterEncoding("UTF-8");
	String WAREKY = request.getParameter("WAREKY");
	String OWNRKY = request.getParameter("OWNRKY");
	String AREAKY = request.getParameter("AREAKY");
	String RQSHPD = request.getParameter("RQSHPD");
	String SHPOKY = request.getParameter("SHPOKY");
	String SKUKEY = request.getParameter("SKUKEY");
	String DESC01 = request.getParameter("DESC01");
	String CREUSR = request.getParameter("CREUSR");
	
	User user = (User)request.getSession().getAttribute(CommonConfig.SES_USER_OBJECT_KEY);
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
	    	id : "gridHeadList",
			editable : true,
			module : "Mobile",
			command : "MOM05",
			validation : "SHPRQK",
			gridMobileType : true
	    });
		
		searchList();
	});
	
	function searchList(){
		var param = inputList.setRangeParam("searchArea");
		
		if(param.get("WAREKY") == undefined || param.get("WAREKY") == "undefined") param.put("WAREKY", "");
		if(param.get("OWNRKY") == undefined || param.get("OWNRKY") == "undefined") param.put("OWNRKY", "");
		if(param.get("AREAKY") == undefined || param.get("AREAKY") == "undefined") param.put("AREAKY", "");
		if(param.get("RQSHPD") == undefined || param.get("RQSHPD") == "undefined") param.put("RQSHPD", "");
		if(param.get("SHPOKY") == undefined || param.get("SHPOKY") == "undefined") param.put("SHPOKY", "");
		if(param.get("SKUKEY") == undefined || param.get("SKUKEY") == "undefined") param.put("SKUKEY", "");
		if(param.get("DESC01") == undefined || param.get("DESC01") == "undefined") param.put("DESC01", "");
		if(param.get("CREUSR") == undefined || param.get("CREUSR") == "undefined") param.put("CREUSR", "");
		
		gridList.setReadOnly("gridHeadList", true, ['INDTRN','INDRCV','INDDEL','INDSHP']);
		
		gridList.gridList({
	    	id : "gridHeadList",
	    	param : param
	    });
		
		
		showMain();
	}
	
	function deleteData(){
		var head = gridList.getSelectData("gridHeadList");
		
		if(head.length == 0){
			// 선택된 데이터가 없습니다.
			commonUtil.msgBox("VALID_M0006");
			return;
		}
		
		if(!commonUtil.msgConfirm("MASTER_M0020")){
			return;
		}
		
		var param = new DataMap();
		param.put("head", head); 
		
		var json = netUtil.sendData({
			url : "/wms/order/json/saveOM05.data",
			param : param
		});   
		
		if(json.data.length > 5 && json.data.length != 10){
			var msgList = json.data.split("†");
			var msgTxt = commonUtil.getMsg(msgList[0], (msgList.length > 1 ? msgList[1].split("/") : null));
			commonUtil.msg(msgTxt);
			return;
		} 
		
		if(json.data == "OK"){
			commonUtil.msgBox("VALID_M0003");  //삭제 성공
			
			gridList.resetGrid("gridHeadList");
			
			searchList();
		}
	}
	
	function showMain() {
		$("#main").show();
	}
	
	function showDetail(){
 		var focusNum = gridList.getFocusRowNum("gridHeadList");
 		var rowData = gridList.getRowData("gridHeadList", focusNum);
		mobile.linkPopOpen('/mobile/MOM05_detail.page', rowData);
 	}
	
 	function clearText(data){
		if(data!=null||data!=""){
	    	data.value="";
	    }      
	}
</script>
</head>
<body>
	<div class="main_wrap" id="main">
		<div id="searchArea">
			<input type="hidden" name="WAREKY" value="<%=WAREKY%>" />
			<input type="hidden" name="OWNRKY" value="<%=OWNRKY%>" />
			<input type="hidden" name="AREAKY" value="<%=AREAKY%>" />
			<input type="hidden" name="RQSHPD" value="<%=RQSHPD%>" />
			<input type="hidden" name="SHPOKY" value="<%=SHPOKY%>" />
			<input type="hidden" name="SKUKEY" value="<%=SKUKEY%>" />
			<input type="hidden" name="DESC01" value="<%=DESC01%>" />
			<input type="hidden" name="CREUSR" value="<%=CREUSR%>" />
		</div>
		<div id="main_container">
			<div class="tem5_content">
				<div class="tableWrap_search section">
					<div class="tableHeader">
						<table style="width: 100%">
							<colgroup>
								<col width="30px" />
								<col width="30px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
							</colgroup>
							<thead>
								<tr>
									<th CL='STD_NUMBER'></th>
									<th GBtnCheck="true"></th>
									<th CL='STD_SHPRQK'>출고요청번호</th>	 
									<th CL='STD_SRQTYP'>요청구분</th>	 
									<th CL='STD_SRQTNM'>요청구분명</th>	 
									<th CL='STD_WAREKY'>거점</th>
									<th CL='STD_WARENM'>거점명</th>
									<th CL='STD_RQSHPD'>출고요청일자</th>
									<th CL='STD_AREAKY'>창고</th>
									<th CL='STD_AREANM'>창고명</th>
									<th CL='STD_SKUCNT'>상품수</th>
									<th CL='STD_INDTRN'>이고출고여부</th>
									<th CL='STD_INDRCV,3'>이고입고여부</th>
									<th CL='STD_INDDEL'>요청취소여부</th>
									<th CL='STD_INDSHP'>출고완료여부</th>
									<th CL='STD_RDDALL'></th>
									<th CL='STD_OWNRKY'></th>
									<th CL='STD_OWNRNM'></th>
									<th CL='EZG_REQUSR'>User NM</th>
									<th CL='STD_EMPLID2'>employee ID</th>
									<th CL='STD_TEAMLD'></th>
									<th CL='STD_CREDAT'></th>
									<th CL='STD_CREUSR'></th>
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
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
								<col width="100px" />
							</colgroup>
							<tbody id="gridHeadList">
								<tr CGRow="true">
									<td GCol="rownum">1</td>
									<td GCol="rowCheck"></td>
									<td GCol="text,SHPRQK"></td> 
									<td GCol="text,SRQTYP"></td> 
									<td GCol="text,SRQTNM"></td> 
									<td GCol="text,WAREKY"></td> 
									<td GCol="text,WARENM"></td> 
									<td GCol="text,RQSHPD" GF="D"></td> 
									<td GCol="text,AREAKY"></td>  
									<td GCol="text,AREANM"></td>  
									<td GCol="text,CNTSKU" GF="N"></td> 
									<td GCol="check,INDTRN"></td> 
									<td GCol="check,INDRCV"></td> 
									<td GCol="check,INDDEL"></td> 
									<td GCol="check,INDSHP"></td> 
									<td GCol="text,RDDALL"></td> 
									<td GCol="text,OWNRKY"></td> 
									<td GCol="text,OWNRNM"></td>
									<td GCol="text,STDLNR"></td>
									<td GCol="text,WORKID"></td>
									<td GCol="text,C00101"></td>
									<td GCol="text,CREDAT" GF="D"></td>
									<td GCol="text,CREUSR"></td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
				<!-- end table_body -->
				<div class="footer_5">
					<table>
						<tr>
							<td onclick="showDetail()"><label CL='STD_DETAIL'></label></td>
							<td class="f_1" onclick ="deleteData()"><label CL='BTN_DELETE'></label></td>
						</tr>
					</table>
				</div><!-- end footer_5 -->	
			</div>
		</div>
	</div>
</body>