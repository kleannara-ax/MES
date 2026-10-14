<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.common.bean.DataMap,com.common.util.RequestMap,java.util.*"%>
<%
	String ASNDKY = (String)request.getParameter("ASNDKY");
	String ASNDIT = (String)request.getParameter("ASNDIT");
	String SKUKEY = (String)request.getParameter("SKUKEY");
	
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
var gridList1rowNum = -1 ;
var gridList2rowNum = -1 ;

$(document).ready(function(){
	var data = mobile.getLinkPopData();
	dataBind.dataNameBind(data, "searchArea"); 
	
	param.put("ASNDKY", data.get("ASNDKY"));
	param.put("ASNDIT", data.get("ASNDIT"));
	param.put("SKUKEY", data.get("SKUKEY"));
	
	gridList.setGrid({
    	id : "gridList",
		editable : false,
		module : "Mobile",
		command : "NONE_FAIL",
		gridMobileType : true
	//	bindArea : "searchArea" 
    });
	
	gridList.setGrid({
    	id : "gridListsearch1",
		editable : false,
		module : "Mobile",
		gridMobileType : true
	//	bindArea : "searchArea" 
    });
	
	gridList.setGrid({
    	id : "gridListsearch2",
		editable : false,
		module : "Mobile",
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
		showMain('main');
	}
	
	
	function searchList1(){
		gridList.gridList({
			module : "Mobile" ,
			   	id : "gridListsearch1",
		   command : "MGR01_FAIL_SEARCH1",
			 param : param
		});
	}
	

	
	function searchList2(){
		gridList.gridList({
			module : "Mobile" ,
			   	id : "gridListsearch2",
		   command : "MGR01_FAIL_SEARCH2",
			 param : param
		});
	}


	function saveData() {
		var param = dataBind.paramData("main_wrap");
		var list = gridList.getGridData("gridList");
		
		for(var i=0; i<list.length; i++){
			var QCITEM = list[i].get("QCITEM");
			var FAILIT = list[i].get("FAILIT");
			if(QCITEM.trim() == "" || FAILIT.trim() == ""){
				alert("항목코드를 입력하세요.");
				return;
			}
		}
		param.put("list",list); 
		param.put("ASNDKY",  $("[name=ASNDKY]").val());
		param.put("ASNDIT",  $("[name=ASNDIT]").val());
		
		var json = netUtil.sendData({
	        url:"/mobile/Mobile/json/SaveMGR01_whyfail.data",
			param : param
		});  
		
		if(json && json.data){
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
			commonUtil.msgBox("VALID_M0001");
		//	searchList();
			//wms.linkPopClose();
			
		}else{
			commonUtil.msgBox("VALID_M0000");
		}
	}
	
	
	function  gridListEventColBtnclick(gridId, rowNum, btnName){
		if(gridId == "gridList"){
			if(btnName == "Qtsamp"){
				searchList1();
				gridList1rowNum = rowNum;
				showWhyFail('Qtsamp');
				
			}else if(btnName == "Qtfail"){
				var qcitem =  gridList.getColData("gridList",rowNum,"QCITEM").trim();
				if(qcitem == ""){
					alert("검사항목코드를 먼저 입력하세요.");
					
				}else {
					var qcitem =  gridList.getColData("gridList",rowNum,"QCITEM").trim();
					param.put("QCITEM",qcitem);
					searchList2();
					gridList2rowNum = rowNum;
					showWhyFail('Qtfail');
				} 
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
	
	
	
	function showMain(divId) {
		if(divId=='Qtsamp'){
			$("#whyFail_1").hide();
			$("#main_wrap").show();
		}else if(divId=='Qtfail'){
			$("#whyFail_2").hide();
			$("#main_wrap").show();
		}else{
			$("#whyFail_1").hide();
			$("#whyFail_2").hide();
			$("#main_wrap").show();
		}
	}
	function showWhyFail(divId) {
		if(divId=='Qtsamp'){
			$("#main_wrap").hide();
			$("#whyFail_1").show();
		}else if(divId=='Qtfail'){
			$("#main_wrap").hide();
			$("#whyFail_2").show();
		}
	}


	function gridListEventDataBindEnd(gridId, dataLength){
		if(gridId == "gridListsearch1"){
			if( dataLength == 0 ){
				showMain();
			}
		}else if (gridId == "gridListsearch2"){
			if( dataLength == 0 ){
				showMain();
			}
		}
 	}
 	
	
	function selectCode(gridId){
		var rowNum = gridList.getSelectIndex(gridId);
		var rowData = gridList.getRowData(gridId, rowNum);
		
		if(gridId== "gridListsearch1"){
			var qcitem = rowData.get("QCITEM");
			var itemname = rowData.get("ITMENAME");
			gridList.setColValue("gridList", gridList1rowNum, "QCITEM", qcitem);  
			gridList.setColValue("gridList", gridList1rowNum, "QCITNAME", itemname); 
			showMain();
		}
		else if(gridId== "gridListsearch2"){
			var failit = rowData.get("FAILIT");
			var failname = rowData.get("ITNAME");
			gridList.setColValue("gridList", gridList2rowNum, "FAILIT", failit);  
			gridList.setColValue("gridList", gridList1rowNum, "FAITNAME",failname ); 
			showMain();
		}
		
	
		
	}
	

</script>

</head>
<body>
	<div class="main_wrap" id="main_wrap">
		<div id="main_container">
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
								<td GCol="btn,Qtsamp" GB="Qtsamp SEARCH 확인" ></td>
								<td GCol="text,QCITNAME"></td>
								<td GCol="input,FAILIT"></td>
								<td GCol="btn,Qtfail" GB="Qtfail SEARCH 등록" ></td>
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
							<td onclick="mobile.linkPopClose()">닫기</td>  
							<!-- <td onclick='location.href="/mobile/MGR01_list.page"'>닫기</td> -->
							<td onclick="saveData()">저장</td>
							<td class=f_1 onclick="deleteData()">－</td>
						</tr>
					</table>
				</div><!-- end footer_5 -->	
			</div>
	</div>
</div>
	<div class="whyFail_wrap"  id="whyFail_1">
		<div class="tem5_content">
				<div class="search_box">
					<table>
						<colgroup>
							<col />
							<col width="100px"  />
						</colgroup>
						<tbody id="searchArea1">
						<input type="hidden" name="SKUKEY" />
							<!-- <tr>
								<td class="second">
									<input type="text" id="SKUKEY" name="SKUKEY"  class="text" validate="required"/>
								</td>
								<td>
									<input type="button" value="조회" class="bt" onclick="searchList()"/>
								</td>
							</tr> -->
						</tbody>
					</table>
				</div>
				
				<div class="info_box">
					<div class="tableHeader">
						<table>
							<colgroup>
									<col width="40px" />
									<col width="40px" />
									<col width="40px" />
									<col width="40px" />
							</colgroup>
								<thead>
									<tr>
										<th CL='STD_NUMBER'>번호</th>
								        <th >선택</th>
										<th CL='STD_QCITEM'>검사항목코드</th>
										<th CL='STD_ITMENAME'>검사항목명</th>
									</tr>
								</thead>
						</table>
					</div>
					
					<div class="tableBody">
					<form>
						<table>
							<colgroup>
									<col width="40px" />
									<col width="40px" />
									<col width="40px" />
									<col width="40px" />
							</colgroup>
							<tbody id="gridListsearch1">
								<tr CGRow="true" >
									<td GCol="rownum"></td>
									<td GCol="rowCheck,radio"></td>
									<td GCol="text,QCITEM"></td>
									<td GCol="text,ITMENAME"></td>
								</tr>	
							</tbody>
						</table>
					</form>			
					</div>
				</div>
				<div class="bottom">
					<input type="button" value="선택" class="bottom_bt" onclick="selectCode('gridListsearch1')"/>
				</div>
		</div>	
	</div>	
	<div class="whyFail_wrap" id="whyFail_2">
		<div class="tem5_content">
				<div class="search_box">
					<table>
						<colgroup>
							<col />
							<col width="100px"  />
						</colgroup>
						<tbody id="searchArea2">
							<tr>
								<td>
								<input type="hidden" name="QCITEM" />
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="info_box">
					<div class="tableHeader">
						<table>
							<colgroup>
									<col width="40px" />
									<col width="40px" />
									<col width="40px" />
									<col width="40px" />
									<col width="40px" />
							</colgroup>
							<tbody>
								<tr class="thead">
									<th CL='STD_NUMBER'>번호</th>
								    <th >선택</th>
									<th CL='STD_FAILIT'>불량항목코드</th>
									<th CL='STD_ITNAME'>불량항목명</th>
									<th CL='STD_QCITEM'>검사항목코드</th>
								</tr>
							</tbody>
						</table>
					
				</div>
				<div class="tableBody">
					<table>
						<colgroup>
								<col width="40px" />
								<col width="40px" />
								<col width="40px" />
								<col width="40px" />
								<col width="40px" />
							</colgroup>
							<tbody id="gridListsearch2">
								<tr CGRow="true">
									<td GCol="rownum"></td>
									<td GCol="rowCheck,radio"></td>
									<td GCol="text,FAILIT"></td>
									<td GCol="text,ITNAME"></td>
									<td GCol="text,QCITEM"></td>
								</tr>
							</tbody>
						</table>							
					</div>
				</div>
				<div class="bottom">
					<input type="button" value="선택" class="bottom_bt" onclick="selectCode('gridListsearch2')"/>
<!-- 					<input type="button" value="선택" class="bottom_bt" onclick="showWhyFail('whyFail2')"/> -->
				
				</div>
		</div>	
	</div>		
	
	
</body>