<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<head>
<style type="text/css">
button {float: right; }
input:read-only { 
    background-color: #e2e2e2;
}
select:DISABLED {
	background-color: #e2e2e2;
}
</style>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>Mobile WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script>
	var data;
	var chkObjId = "";
	var activeType = false;
	
	$(document).ready(function(){
		gridList.setGrid({
            id : "gridList",
            editable : true,
            module : "WmsMobileInventoryPhysicalCount",
            command : "PDMV46",
			bindArea : "searchArea",
            gridMobileType : true
        });

		data = mobile.getLinkPopData();

		showDetail();
        searchList();
        $("#BARCOD").focus();
	});
	
	function showDetail(){ 
		$("#main").hide();
		$("#detailInfo").show();
		
		$('#FAILYN').hide();
	}
	function searchList() { 
		data.put("SES_WAREKY", "<%=wareky%>");
		data.put("SES_OWNER", "<%=ownrky%>");
		
		gridList.gridList({
			id : "gridList",
			param : data
		}); 
	}
	
	function gridListEventDataBindEnd(gridId, dataLength, excelLoadType){
		if(gridId == "gridList" && dataLength > 0){
			PlaySound('s');
			var locaky = data.get("LOCAKY");
			var rowCnt = gridList.getGridDataCount("gridList");
			var compareLocaky;
			for(var i=0 ; i<rowCnt ; i++){
				compareLocaky = gridList.getColData("gridList", i, "LOCAKY");
				if(locaky == compareLocaky){
					gridList.setRowFocus("gridList", i, true);
				}
			}
			
		}
	} 
	
	function preItem(){
		scanCnt = 0;
		var rowCnt = gridList.getGridDataCount("gridList");
		var fRow = gridList.getFocusRowNum("gridList");

		if(fRow == 0){
			gridList.setRowFocus("gridList", rowCnt-1, true);
		}else{
			gridList.setPreRowFocus('gridList');
		}
	}
	
	function nextItem(){
		scanCnt = 0;
		var rowCnt = gridList.getGridDataCount("gridList");
		var fRow = Number(gridList.getFocusRowNum("gridList"));
		
		if(rowCnt == fRow+1){
			gridList.setRowFocus("gridList", 0, true);
		}else{
			gridList.setNextRowFocus('gridList');
		}
	}
	
	function showMain(){
		mobile.linkPopClose();
	} 
	
	var scanCnt = 0;
	function scanBarcod(){
		var barcod = $('#BARCOD').val();
		var skukey = $('#SKUKEY').val();
		
		var param = inputList.setRangeParam("searchArea");
		
		var json = netUtil.sendData({
			module : "WmsMobileInventoryPhysicalCount",
			command : "BARCODCHK",
			sendType : "map",
			param : param
		});

		if (json.data["CNT"] > 0) {
			$('#FAILYN').hide();
			
			scanCnt ++;
			$('#QTYPDA').val(scanCnt);
			$("#QTYPDA").focus();//focus 변경 인식용 아무의미 없음(하지만 삭제하면 안됨)
			PlaySound('s');
		}else{
			$('#FAILYN').show();
			$("#QTYPDA").focus();//focus 변경 인식용 아무의미 없음(하지만 삭제하면 안됨)
			PlaySound('e');
		}
		
		//$('#BARCOD').val("");
		$('#BARCOD').select();
		
	}
	
	function saveDataAction(){
		if(activeType){
			return;
		}
		activeType = true;
		saveData();
		activeType = false;
	}
	
	var taskCnt = 0;
	function saveData(){
		if(gridList.validationCheck("gridList", "select")){
			var param = new DataMap();
			var fRow = gridList.getFocusRowNum("gridList");
			var head = gridList.getRowData("gridList", fRow);
			var rowCnt = gridList.getGridDataCount("gridList");
			
			var qtypda = $('#QTYPDA').val();
			
			param.put("head",head);
			param.put("QTYPDA", qtypda);
			param.put("PDARDO", data.get("PDARDO"));
			
			if(head.length < 1){
				commonUtil.msgBox("COMMON_M0462"); //수정된 데이터가 없습니다.
				PlaySound('e');
				return;
			}
			
			var json = netUtil.sendData({
				url:"/mobile/mobilePhysicalCount/json/SavePDMV47.data",
				param : param
			});
			
			if(json && json.data){
				commonUtil.msgBox("MASTER_M0564");
				PlaySound('s');
				taskCnt ++;
				
				if(rowCnt == taskCnt){
					commonUtil.msgBox("INV_M0728", data.get("PHYIKY"));
					//alert("실사문서번호 "+data.get("PHYIKY")+" 의 실사작업이 완료되었습니다.");
					
					
					taskCnt = 0;
					
					 mobile.linkPopClose('save');
				}else{
					nextItem();
				}
				
			}else{
				commonUtil.msgBox("VALID_M0002");
				PlaySound('e');
			}
		}
	}
	
	function clearText(data){
	    if(data!=null||data!=""){
	       data.value="";
	    }      
	 }
	
	function focusCheck(objId){
		$("#"+objId).select();
	}
</script>
</head>
<body>                    

	<div class="main_wrap" id="main">
		<div class="tem5_content"> 
			<div class="tableWrap_search section">
					<div class="tableHeader">
						<table style="width: 100%">
							<colgroup>
									<col width="30px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
							</colgroup>
							<thead>
								<tr>
									<th CL='STD_NO'>No.</th>
									<th CL='STD_LOCAKY'></th>
									<th CL='STD_SKUKEY'></th>
									<th CL='STD_QTSIWH'></th>   
								</tr>
							</thead>
						</table>				
					</div>					
					<div class="tableBody">
						<table style="width: 100%">
							<colgroup>
									<col width="30px" />
									<col width="100px" />
									<col width="100px" />
									<col width="100px" />
							</colgroup>
							<tbody id="gridList">
								<tr CGRow="true">
									<td GCol="rownum">1</td>
									<td GCol="text,LOCAKY"></td>
									<td GCol="text,SKUKEY"></td>
								    <td GCol="text,QTSIWH"></td>
								</tr>
							</tbody>
						</table>
					</div>
				</div> 
		</div>
	</div>
	
	<div class="main_wrap" id="detailInfo"> 
		<div class="tem4_content">
			<div class="select_box" id="searchArea">
				<table class="info_table">
					<colgroup>
						<col width="100px"  />
						<col />
						<col width="65px" />
					</colgroup>
					<tbody>
						<tr>
							<th CL="STD_LOCAKY">LOC</th>
							<td colspan="3">
								<input type="text" class="text" name="LOCAKY" id="LOCAKY" readonly="readonly" />
							</td>
						</tr>
						<tr>
							<th CL="STD_BARCOD">바코드</th>
							<td colspan="3">
								<input type="text" class="text" name="BARCOD" id="BARCOD" onfocus="focusCheck(this.id)" onkeypress="commonUtil.enterKeyCheck(event, 'scanBarcod()')" />
							</td>
						</tr>
						<tr>
							<th CL="STD_SKUKEY">SKU번호</th>
							<td colspan="2">
								<input type="text" class="text" name="EANCOD" id="EANCOD" readonly="readonly" />
							</td>
							<td>
								<input type="text" class="text" name="SKUKEY" id="SKUKEY" readonly="readonly" style="width: 98%" />
							</td>
						</tr>
						<tr>
							<th CL="STD_DESC01">SKU명</th>
							<td colspan="3">
								<input type="text" class="text" name="DESC01" readonly="readonly" />
							</td>
						</tr>
						<tr>
							<th CL="STD_DUOMKY">판매단위</th>
							<td>
								<input type="text" class="text" name="UOMKEY" id="UOMKEY" readonly="readonly" />
							</td>
							<th CL="STD_QTDUOM">입수</th>
							<td>
								<input type="text" class="text" name="QTIPSU" id="QTIPSU" readonly="readonly" />
							</td>
						</tr>
						<tr>
							<th CL="STD_LOTA13">유통기한</th>
							<td>
								<input type="text" class="text" name="LOTA13" readonly="readonly" GF="D" />
							</td>
							<th CL="STD_LOTA11">제조일자</th>
							<td>
								<input type="text" class="text" name="LOTA11" readonly="readonly" GF="D" />
							</td>
						</tr>
						<tr>
							<th CL="STD_QTYPDA">실사수량</th>
							<td colspan="3">
								<input type="text" class="text" name="QTYPDA" id="QTYPDA" onkeyup="setQtypda()"  style="height: 200px;font-size: 50pt;font-weight: bold;text-align: center;"/>
							</td>
						</tr>
						<tr>
							<th></th>
							<td colspan="3">
								<input type="text" class="text" name="FAILYN" id="FAILYN" value="이종상품" style="background-color: red;font-weight: bold;font-color: white;text-align: center;"/>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div> 
		<div class="footer_5">
			<table>
				<tr>
					<td class=f_1 onclick="preItem()"><label CL='<'></label></td> 
					<td class=f_1 onclick="showMain()"><label CL='BTN_CLOSE'></label></td>
					<td class=f_1 onclick="saveDataAction()"><label CL='BTN_SAVE'></label></td>
					<td class=f_1 onclick="nextItem()"><label CL='>'></label></td>
				</tr>
			</table>
		</div>
		<!-- end footer_5 -->
	</div>  
</body>