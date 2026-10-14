<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.common.bean.DataMap,com.common.util.RequestMap,java.util.*"%>
<%
	String ASNDKY = (String)request.getParameter("ASNDKY");
	String ASNDIT = (String)request.getParameter("ASNDIT");
	String SKUKEY = (String)request.getParameter("SKUKEY");
	/* String DESC01 = (String)request.getParameter("DESC01"); */
%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>슈피겐코리아 모바일 WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script type="text/javascript">
var param = new DataMap();
var cmd;
var popbtn; 
var rowseq1 = -1 ;
var rowseq2 = -1 ;
$(document).ready(function(){
	//var data = mobile.getLinkPopData();
	//dataBind.dataNameBind(data, "searchArea");
	
	 var data =  new DataMap();
	data.put("ASNDKY", '<%=ASNDKY%>');
	data.put("ASNDIT", '<%=ASNDIT%>');
	data.put("SKUKEY", '<%=SKUKEY%>');
	dataBind.dataNameBind(data, "searchArea"); 
	
	param.put("ASNDKY", '<%=ASNDKY%>');
	param.put("ASNDIT", '<%=ASNDIT%>');
	param.put("SKUKEY", '<%=SKUKEY%>');
	
	gridList.setGrid({
    	id : "gridList",
		editable : false,
		module : "Mobile",
		command : "NONE_FAIL",
		gridMobileType : true
	//	bindArea : "searchArea" 
    });
	
	
	var json = netUtil.sendData({
		module : "Mobile" ,
		command : "MGR01_CHECK_FAIL",
		sendType : "map",
		param : data
	});
	
	if(json && json.data){
		if(json.data["CNT"] >= 1){
			cmd = "EXIST_FAIL";
			searchList();
		} 
		
		else if (json.data["CNT"] < 1){
			cmd = "NONE_FAIL" ; 
			searchList();
		}
	}

});

	function searchList(){
		gridList.gridList({
			module : "Mobile" ,
			   	id : "gridList",
			command : cmd,
			param : param
		});
		
	}


function saveData() {
	var param = dataBind.paramData("main_wrap");
	var list = gridList.getGridData("gridList");
	
	for(var i=0; i<list.length; i++){
		var QCITEM = list[i].get("QCITEM");
		var FAILIT = list[i].get("FAILIT");
		if(QCITEM == " " || FAILIT == " "){
			alert("항목코드를 입력하세요.");
			return;
		}
	}
	param.put("list",list); 
	param.put("ASNDKY", '<%=ASNDKY%>');
	param.put("ASNDIT", '<%=ASNDIT%>');
	
	var json = netUtil.sendData({
        url:"/mobile/Mobile/json/SaveMGR01_whyfail.data",
		param : param
	});  
	
	if(json && json.data){
		commonUtil.msgBox("VALID_M0001");
		cmd = "EXIST_FAIL";
		searchList();
		//wms.linkPopClose();
		
	}else{
		commonUtil.msgBox("VALID_M0000");
	}
}

function  gridListEventColBtnclick(gridId, rowNum, btnName){
	if(btnName == "Qtsamp"){
		popbtn = "P1" ;
		rowseq1 = rowNum;
		 var popparam = new DataMap();
		popparam.put("KINDQC","6018002");
		var SKUKEY = $("[name=SKUKEY]").val();
		popparam.put("SKUKEY",SKUKEY);
		mobile.linkPopOpen('/mobile/MGR01_whyfail_search1.page',popparam );
		/* var SKUKEY = $("[name=SKUKEY]").val();
		location.href="/mobile/MGR01_whyfail_search1.page?KINDQC=6018002&SKUKEY="+SKUKEY; */
		
	}else{
		var rownum = gridList.getFocusRowNum("gridList");
		var qcitem =  gridList.getColData("gridList",rownum,"QCITEM").trim();
		if(qcitem == ""){
			alert("검사항목코드를 먼저 입력하세요.");
			return;
		}else {
			popbtn = "P2" ;
			rowseq2 = rowNum;
			var popparam = new DataMap();
			popparam.put("QCITEM",qcitem);
			mobile.linkPopOpen('/mobile/MGR01_whyfail_search2.page', popparam); 
			/* var SKUKEY = $("[name=SKUKEY]").val();
			location.href="/mobile/MGR01_whyfail_search2.page?QCITEM="+qcitem+"&SKUKEY="+SKUKEY; */
			
		}
	}
}

function linkPopCloseEvent(data){
	if(data.get("data") != "NULL"){
		if(popbtn== "P1"){
			var QCITEM = data.get("QCITEM");
			var ITNAME = data.get("ITMENAME");
			gridList.setColValue("gridList", rowseq1, "QCITNAME", ITNAME);
			gridList.setColValue("gridList", rowseq1, "QCITEM", QCITEM);
			gridList.setColFocus("gridList", rowseq1, "QCITEM");
			
		}else{
			var FAILIT = data.get("FAILIT");
			var ITNAME = data.get("ITNAME");
			
			gridList.setColValue("gridList", rowseq2, "FAITNAME", ITNAME);
			gridList.setColValue("gridList", rowseq2, "FAILIT", FAILIT);
			gridList.setColFocus("gridList", rowseq2, "FAILIT");
			
		}
	}
}

function addData(){
	gridList.getGridBox('gridList').addRow();
}

function deleteData(){
	gridList.getGridBox('gridList').deleteRow();
}	
</script>

</head>
<body>
	<div class="main_wrap" id="main_wrap">
		<h2 class="why_title">불합격사유</h2>
		<div class="w_table_wrap">
			<div class="w_table1" id="searchArea">
			<table>
					<colgroup>
						<col width="60px"/>
						<col />
					</colgroup>
					<tbody >
						<tr><input type="hidden" name="TMPNUM" /><input type="hidden" name="ASNDKY" /><input type="hidden" name="ASNDIT" /></tr>
						<tr>
							<th>품번</th>
							<td><span class="inp_group">
								<input type="text" name="SKUKEY" readonly="readonly" class="textInput">
							</span>
							</td>
							
						</tr>
						<tr>
							<th>품명</th>
							<td>
								<span class="inp_group">
									<input type="text" style="height:70px" name="DESC01" readonly="readonly" class="textInput">
								</span>
							</td>
						</tr>
					</tbody>
			</table>
			</div>
			</div>
			
			
			
			<div class="tem5_content">
			<div class="tableWrap_search section">
				<div class="tableHeader">
					<table>
						<colgroup>
							<col width="20" />
							<col width="40" />
							<col width="40" />
							<col width="80" />
							<col width="80" />
							<col width="40" />
							<col width="100" />
							<col width="100" />
							<col width="50" />
						</colgroup>
						<thead>
							<tr>
									<th CL="STD_NUMBER"></th>
									<th CL="STD_QCITEM"></th>
									<th>조회</th>
									<th CL="STD_ITNAME"></th>
									<th CL="STD_FAILIT"></th>
									<th>조회</th>
									<th CL="STD_ITNAME"></th>
									<th CL="STD_REMARK"></th>
									<th CL="STD_QCUSER"></th>
							</tr>
						</thead>
					</table>				
				</div>					
				<div class="tableBody" >
					<table id ="fail_reason_table">
						<colgroup>
							<col width="20" />
							<col width="40" />
							<col width="40" />
							<col width="80" />
							<col width="80" />
							<col width="40" />
							<col width="100" />
							<col width="100" />
							<col width="50" />
						</colgroup>
						<tbody id="gridList" class="searchBody">
							<tr CGRow="true">
								<td GCol="rownum"></td>
								<td GCol="input,QCITEM"></td>
								<td GCol="btn,Qtsamp" GB="Qtsamp SEARCH 확인"></td>
								<td GCol="text,QCITNAME"></td>
								<td GCol="input,FAILIT"></td>
								<td GCol="btn,Qtfail" GB="Qtfail SEARCH 등록"></td>
								<td GCol="text,FAITNAME"></td>
								<td GCol="input,REMARK"></td>
								<td GCol="input,QCUSER"></td>
							</tr>
						</tbody>
					</table>
				</div>
				</div>
				<!-- end table_body -->
				<div class="footer_5">
					<table>
						<tr>
							<td class=f_1 onclick="addData()" >＋</td>
							<!-- <td onclick="mobile.linkPopClose()">닫기</td>  -->
							<td onclick='location.href="/mobile/MGR01_list.page"'>닫기</td>
							<td onclick="saveData()">저장</td>
							<td class=f_1 onclick="deleteData()">－</td>
						</tr>
					</table>
				</div><!-- end footer_5 -->	
			</div>
			</div>
</body>