<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script type="text/javascript">
	var searchType = false;
	$(document).ready(function(){
	    gridList.setGrid({
			id : "gridList",
			editable : true,
			module : "WmsMobile",
			command : "TR56",
			bindArea: "itemArea",
			gridMobileType : true
	    });
	    
 	    gridList.setGrid({
			id : "gridSubList",
			editable : true,
			module : "WmsMobile",
			command : "TR56POP",
			gridMobileType : true
	    });
	    
	    netUtil.setForm("saveForm");
	    
	    getGPSInfo("getGPSInfo");

		if($.isApp){
			var data = {'callbackFn' : 'getGPSInfo'};
			$.callApp('10', data);
		}
	});
	
	var gpsInfo;
	function getGPSInfo(data){
		$('#gpsinfo').val(data);
		var obj = eval("("+data+")");
		gpsInfo =  obj;
	}

	var subchk = 0;

	function searchList(){
		searchType = true;
    	var param = dataBind.paramData("searchArea");

    	gridList.gridList({
    		id : "gridList",
    		param : param
    	});
    	showMain();
    	subchk = 0;
	}
	

	function searchSubList(){
    	var param = dataBind.paramData("itemArea");

    	if(subchk==0){
	    	gridList.gridList({
	    		id : "gridSubList",
	    		param : param
	    	});
    	}
    	gridList.	
		lastFocusNum = -1;
		dblIdx = -1;    	
		subchk++;
	}

/*  	var lastFocusNum = -1;
	function gridListEventDataBindEnd(gridId, dataLength){
		var shipad =  gridList.getColData("gridSubList", 0, "SHIPAD")				

	} */

	function Clear(){
		
		var list = gridList.getGridData("gridSubList");
		
		var param = dataBind.paramData("itemArea");
		
		var pcksts = gridList.getColData("gridSubList", 0, "PCKSTS");
		var tcheck = gridList.getColData("gridSubList", 0, "UPDCHK");
		
		if(tcheck =="1") {
			alert("이미 작업진행하셨습니다");
			return;
		}
		if(pcksts == "" || pcksts != "V"){
			alert("픽업상태를 V로 체크해주십시요.")
			return;
		}
		
		param.put("list",list); 
			
		var json = netUtil.sendData({
			url : "/wms/outbound/json/TR56POPSave.data",
			param : param
		});
		
		if(json && json.data){
			searchList();
		}else{
			commonUtil.msgBox("VALID_M0000");
		}
	}
	
	function Fail(){
		var list = gridList.getGridData("gridSubList");
		
		var param = dataBind.paramData("itemArea");
		
		var pcksts = gridList.getColData("gridSubList", 0, "RSNCOD");
		var tcheck = gridList.getColData("gridSubList", 0, "UPDCHK");
		
		if(tcheck =="1") {
			alert("이미 작업진행하셨습니다");
			return;
		}
		if(pcksts == "00"){
			alert("사유를 체크해주십시요.")
			return;
		}
		param.put("list",list); 
			
		var json = netUtil.sendData({
			url : "/wms/outbound/json/TR56POPFail.data",
			param : param
		});
		
		if(json && json.data){
			searchList();
		}else{
			commonUtil.msgBox("VALID_M0000");
		}	
	}

	var rowData;
	var $telObj;
	function gridListEventRowFocus(gridId, rowNum, colName){
		if(searchType){
			searchType = false;
			$telObj = $("#telNo");
			gridList.setRowFocus(gridId, -1, false);
			return;
		}
		rowData = gridList.getRowData(gridId, rowNum);
		var telNo = rowData.get("SHIPTN");
		//var telNo = "01071760770";
		$telObj.attr("href","tel:"+telNo);
		$telObj.text(telNo);
		var shipad = rowData.get("SHIPAD");
		$("#SHIPAD").text(shipad);
		var shipad1 = rowData.get("SHIPAD1");
		$("#SHIPAD1").text(shipad1);
		var shipad2 = rowData.get("SHIPAD2");
		$("#SHIPAD2").text(shipad2);
		var shipad3 = rowData.get("SHIPAD3");
		$("#SHIPAD3").text(shipad3);
		
		showDetail();
		

		if(gridId=="gridList"){
			searchSubList();
			gridList.setRowFocus(gridId, -1, false);
			subchk = 0;
		}else{
			gridList.setRowFocus(gridId, -1, false);
			return;
		}


	}

	var $callBarcodeObj;
	function callBarcode(objId){
		//alert(objId);
		$callBarcodeObj = $("#"+objId);
		var data = {'callbackFn' : 'getBarCode'};
		$.callApp('20', data);
	}
	
	function getBarCode(data){
		var obj = eval("("+data+")");
		$callBarcodeObj.val(obj["SCAN_RESULT"]);
	}
	
	function showMain() {
		$("#detailInfo").hide();
		$("#main").show();
	}
	
	function showDetail() {
		$("#main").hide();
		$("#detailInfo").show();
	}
	
	function photoPop(){
		mobile.linkPopOpen("/mobile/photo.page");
	}
	
	function linkPopCloseEvent(data){
		$("#UUID").val(data);
	}
	
	function photoSave(){
		netUtil.sendForm("saveForm");
	}
	
	function netUtilEventSetFormSuccess(formId, data){
		if(data.indexOf("[")){
			var uuid = data.substring(data.indexOf("[")+1,data.indexOf("]"));
			$("#UUID").val(uuid);
		}		
	}
</script>
</head>
<body>
	<div class="main_wrap" id="main" >
		<div class="tem5_content">
			<div class="searchSection">
				<table>
					<colgroup>
						<col width="70px"  />
						<col width="70px" />
						<col />
						<col />
					</colgroup>
					<tbody>
						<tr>
							<td>
								<input type="button" value="조회" class="bt" onclick="searchList()"/>
							</td>
							<td>
								<input type="button" value="알림" style="width: 70px; float:left ;" class="bt" />
							</td>
							<td>
							<!-- 	<input type="text"  id="gpsinfo" /> -->
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<!-- <div class="MGR20_top_search" id="searchArea">
				<table>
					<colgroup>
						<col width="70px"  />
						<col />
						<col width="30px"  />
						<col width="70px"  />
						<col />
					</colgroup>
					<tbody>
						<tr>
							<th>주문번호</th>
							<td>
								<input type="text" class="text" name="PGRC03" id="PGRC03"/>
							</td>
							<td>
								<input type="button" value="B" class="bt" onclick="callBarcode('PGRC03')"/>
							</td>
							<th>수령자명</th>
							<td>
								<input type="text" class="text"  name="SHIPNM"/>
							</td>
						</tr>
						<tr>
							<th>송장번호</th>
							<td>
								<input type="text" class="text"  name="INVNUM" id="INVNUM"/>
							</td>
							<td>
								<input type="button" value="B" class="bt" onclick="callBarcode('INVNUM')"/>
							</td>
							<th>판매처</th>
							<td>
								<input type="text" class="text"  name="EXPTNK" />
							</td>
						</tr>
					</tbody>
				</table>
			</div> -->
			<div class="tableWrap_search section" >

 				<div class="tableHeader">
					<table style="width: 100%">
						<colgroup>
							<col width="60px" />
							<col width="150px"/>
							<col width="200px" />	
							<col width="100px" />
						</colgroup>
						<thead>
							<tr>
								<th>번호</th>
								<th>업체명</th>
								<th>지번주소</th>
								<th>배송상태</th>
							</tr>
						</thead>
					</table>				
				</div>					
				<div class="tableBody">
					<table style="width: 100%">
						<colgroup>
							<col width="60px" />
							<col width="150px"/>
							<col width="200px" />
							<col width="100px" />
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rownum">1</td>
								<td GCol="text,NAME01"></td>
								<td GCol="text,ADDR01"></td>
								<td GCol="text,PCKSTS"></td>
							</tr>
						</tbody>
					</table>
				</div>
			</div><!-- end table_body -->
		</div>
	</div>
	<div class="detailInfo_wrap" id="detailInfo">
		<h2 class="info_title">상세정보</h2>
		<div class="d_table_wrap">
			<div id="itemArea">
				<input type="hidden" name="PTNRKY" />
				<input type="hidden" name="EBELN" />
				<input type="hidden" name="EBELP" />
				<table class="info_table">
					<colgroup>
						<col width="180x"/>
						<col />
					</colgroup>
						<tbody>
							<tr>
								<th>MD명</th>
								<td name="SALN01" id="SALN01">
								</td>
							</tr>
							<tr>
								<th>픽업시간</th>
								<td  name="PCKTIM" id="PCKTIM">
								</td>
							</tr>
							<tr>
								<th CL='STD_SHIPAD'></th>
								<td  name="ADDR01"  id="ADDR01">
								</td>
							</tr>
							<tr>
								<th CL='STD_SHIPAD1'></th>
								<td  name="ADDR02"  id="ADDR02">
								</td>
							</tr>
							<tr>
								<th CL='STD_SHIPAD2'></th>
								<td  name="ADDR03"  id="ADDR03">
								</td>
							</tr>
							<tr>
								<th CL='STD_SHIPAD3'></th>
								<td  name="ADDR04"  id="ADDR04">
								</td>
							</tr>
							<tr>
								<th>담당자명</th>
								<td name="CTTN01" id="CTTN01">
								</td>
							</tr>
							<tr>
								<th>전화번호</th>
								<td name="CTTT01" id="CTTT01">
								</td>
							</tr>
<!-- 							<tr>
								<th>사진</th>
								<td>
									<form action="/mobile/TE52/fileUp/save.data" enctype="multipart/form-data" method="post" id="saveForm">
										<input type="file" id="camera" name="camera" accept="image/*" capture="camera" onchange="photoSave()" />
									</form>
									<input type="text" name="UUID" id="UUID" readonly="readonly"/>
									<input type="button" value="사진첨부" class="bt" onclick="photoPop()"/>
								</td>
							</tr>
							<tr>
								<th>전화걸기</th>
								<td>
									<a href="tel:010" id="telNo"></a>
								</td>
							</tr> -->
					</tbody>
				</table>
				<div class="tableWrap_search section" >
					<div class="tableHeader">
						<table>
							<colgroup>
								<col width="30" />
								<col width="155" />
								<col width="70" />
								<col width="70" />
								<col width="70" />
								<col width="70" />
								<col width="70" />
								<col width="50" />
							</colgroup>
							<thead>
								<tr>
									<th CL="STD_NUMBER"></th>
									<th>품명</th>
									<th>입고박스</th>
									<th>입고개수</th>
									<th>판매단위</th>
									<th>Unit단위</th>
									<th>보관방법</th>
									<th>V</th>
								</tr>
							</thead>
						</table>
					</div>
					<div class="tableBody">
						<table>
							<colgroup>
								<col width="30" />
								<col width="155" />
								<col width="70" />
								<col width="70" />
								<col width="70" />
								<col width="70" />
								<col width="70" />
								<col width="50" />
							</colgroup>
							<tbody id="gridSubList">
								<tr CGRow="true" >
									<td GCol="rownum"></td>
									<td GCol="text,DESC01"></td>
									<td GCol="text,RCVBOX"></td>
									<td GCol="text,RCVQTY"></td>
									<td GCol="text,SALQUM"></td>
									<td GCol="text,UNITQM"></td>
									<td GCol="text,MBLNO"></td>
									<td GCol="select,PCKSTS">
										<select name="PCKSTS" >
											<option value="00">선택</option>
											<option value="10">실패</option>
											<option value="V">V</option>
										</select>
									</td> 
																				
								</tr>
							</tbody>
						</table>
					</div>
			</div><!-- end table_body -->
			</div>		
		</div>
		<div class="footer_5">
			<table>
				<tr>
					<td onclick="gridList.setPreRowFocus('gridList')">&lt;</td>
 					<td class=f_1  onclick="Clear()">픽업완료</td>
 					<td onclick="Fail()">픽업실패</td>
					<td onclick="searchList()">닫기</td>
					<td onclick="gridList.setNextRowFocus('gridList')">&gt;</td>
				</tr>
			</table>
		</div>
</div>
</body>
</html>