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
//var chkFlag = true;
var chkObjId = "";
var shpokyValue;
$(document).ready(function(){
	gridList.setGrid({
    	id : "gridList",
		editable : false,
		module : "WmsMobileOutboundPicking",
		command : "PDDL05",
		gridMobileType : true
    });
	
	gridList.setGrid({
        id : "gridItemList",
        module : "WmsMobileOutboundPicking",
        command : "PDDL05Detail",
        editable : true,
        gridMobileType : true
    });
	gridDetail("main");
	$("#GRPOKY").focus();
});

function searchList(){
	var grpoky = $('#GRPOKY').val();
	var skukey = $('#SKUKEY').val();
	shpokyValue = grpoky;
	if(grpoky == "" && skukey == ""){
		commonUtil.msgBox("MASTER_M0314");
		PlaySound('e');
		$("#GRPOKY").focus();
		return;
	}
	
	var param = inputList.setRangeParam("searchArea");
	param.put("SES_WAREKY", "<%=wareky%>");
	param.put("SES_OWNER", "<%=ownrky%>");
	
	gridList.gridList({
    	id : "gridList",
    	param : param
    });
	gridDetail("main");
}



function searchDetailList() {
    if (validate.check("searchArea")) {
        var param = inputList.setRangeParam("searchArea2");

        gridList.gridList({
            id : "gridItemList",
            param : param
        });
	    gridDetail("detailInfo");
    }
}

function gridDetail(data) {
    if (data == "main") {
        $("#main").show();
        $("#detailInfo").hide();
        $("#itemGrid").hide();
    } else if (data == "detailInfo") {
        $("#detailInfo").show();
        $("#itemGrid").show();
        $("#main").hide();
        //searchDetailList();
    }
}

function clearText(data){
    if(data!=null||data!=""){
       data.value="";
    }      
 }

function showMain() {
	window.top.menuOpen();
}

function linkPopCloseEvent(){
	//$("#ASNINV").focus();
}

function focusCheck(objId){
	if(objId != chkObjId){
		chkObjId = objId;
		$("#"+chkObjId).select();
		
		if(objId == "GRPOKY"){
			gridList.resetGrid("gridList");
			$("#SKUKEY").val("");
		}
	}
}

function saveData(){
	if(gridList.validationCheck("gridList", "modify")){
		var item = gridList.getSelectData("gridList");
		var itemData = gridList.getRowData("gridList", gridList.getFocusRowNum("gridList"));

		
		if(item.length == 0){
			commonUtil.msgBox("VALID_M0006");	//선택된 데이터가 없습니다.
			return;
		}
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){ //저장하시겠습니까?
			return;
		}
		var param = new DataMap();		
		param.put("head", item);
		
		var json = netUtil.sendData({
			url : "/mobile/Mobile/json/SavePDDL05.data",
			param : param
		});
		
		if(json && json.data){
			searchList();
			commonUtil.msgBox("MASTER_M0564"); //저장 완료되었습니다.
		}
	}
}

function gridListEventColValueChange(gridId, rowNum, colName, colValue){
	if(gridId == "gridList" && colName == "QTSHPC"){
		var rowData = gridList.getRowData(gridId, rowNum);
		var qtjcmp = new Number(rowData.get("QTJCMP"));
		if(qtjcmp < colValue){
			commonUtil.msgBox("VALID_M0559");
			gridList.setColValue("gridList", rowNum, "QTSHPC", 0);
			gridList.setFocus("gridList", rowNum, "QTSHPC");
			return;
		} else if(colValue < 0){
			commonUtil.msgBox("VALID_M0600");
			gridList.setColValue("gridList", rowNum, "QTSHPC", 0);
			gridList.setFocus("gridList", rowNum, "QTSHPC");
			return;
		}
	}else if(gridId == "gridItemList" && colName == "QTSHPC"){
		var rowData = gridList.getRowData(gridId, rowNum);
		var qtjcmp = new Number(rowData.get("QTJCMP"));
		if(qtjcmp < colValue){
			commonUtil.msgBox("VALID_M0559");
			gridList.setColValue("gridItemList", rowNum, "QTSHPC", 0);
			gridList.setFocus("gridItemList", rowNum, "QTSHPC");
			return;
		} else if(colValue < 0){
			commonUtil.msgBox("VALID_M0600");
			gridList.setColValue("gridItemList", rowNum, "QTSHPC", 0);
			gridList.setFocus("gridItemList", rowNum, "QTSHPC");
			return;
		}
	}
}

function gridListEventDataBindEnd(gridId, dataLength){
	var grpoky = $('#GRPOKY').val();
	var skukey = $('#SKUKEY').val();
	var rowNum = gridList.getFocusRowNum('gridList');
	var list = gridList.getGridData(gridId);
	var rowData;
	$("input[name='S_SHPOKY']").val(gridList.getColData("gridList", rowNum, "SHPOKY"));
	$("input[name='S_SHPOIT']").val(gridList.getColData("gridList", rowNum, "SHPOIT"));
	$("input[name='S_SKUKEY']").val(gridList.getColData("gridList", rowNum, "SKUKEY"));
	$("input[name='S_DESC01']").val(gridList.getColData("gridList", rowNum, "DESC01"));
	$("input[name='TOTCMP']").val(gridList.getColData("gridList", rowNum, "QTJCMP"));
	$("input[name='TOTGMS']").val(gridList.getColData("gridList", rowNum, "QTSHPC"));
	if(gridId == "gridList" && dataLength > 0){
		PlaySound('s');
		if(chkObjId != ""){
			$('#'+chkObjId).focus();
			$('#'+chkObjId).select();
		}
		
		for(var i = 0; i< list.length;i++){
			rowData = list[i];
			if(rowData.get("STATIT") == "FCK" || rowData.get("STATIT") == "PCK"){
				gridList.setRowReadOnly(gridId, i, true, ["rowCheck","QTSHPC"]);
			}
		}
	}else if(gridId == "gridList" && dataLength == 0){
		PlaySound('e');
		if(chkObjId != ""){
			$('#'+chkObjId).focus();
			$('#'+chkObjId).select();
		}
		return;
	}else if(gridId == "gridItemList" && dataLength > 0){
		distribution(gridList.getFocusRowNum("gridList"));
	}
}

//자동분배
function distribution(rowNum){
	var list = gridList.getGridData("gridList");
	var Tablist = gridList.getGridData("gridItemList");
	var shpoky = gridList.getColData("gridList", rowNum,"SHPOKY"); //그룹오더번호
	var totqtj = gridList.getColData("gridList", rowNum,"QTJCMP"); //피킹수량
	var qtshpc = gridList.getColData("gridList", rowNum,"QTSHPC"); //검수수량
	
	//분배오더순위
	var param = new DataMap();
	param.put("SHPOKY",shpoky);
	var json = netUtil.sendData({
		module : "WmsMobileOutboundPicking",
		command : "PDDL05SEQ",
		param : param
	});
	
	$("#PRIORT").val(json.data[0].SEQCUS); //분배오더순위
	$("#QTJCMP").val(totqtj); //피킹수량
	$("#QTSHPC").val(qtshpc); //검수수량
	
	for(var i=0; i<Tablist.length; i++){
		var qtjcmp = gridList.getColData("gridItemList", i,"QTJCMP"); //완료수량
		var testttt = parseInt(qtshpc/qtjcmp);
		if(testttt !=0){
			gridList.setColValue("gridItemList", i, "QTSHPC", Math.max(qtjcmp));
		}else{
			/* if(qtshpc=0){
				gridList.setColValue("gridItemList", i, "QTSHPC", 0);
			} */
			gridList.setColValue("gridItemList", i, "QTSHPC", qtshpc%qtjcmp);
			return;
		}
		qtshpc = qtshpc - Math.max(qtjcmp);
	}
}
</script>
</head>
<body>
	<div class="main_wrap" id="main">
		<div class="tem4_content">
			<div class="select_box" id="bindArea">
				<div id="searchArea">
					<table>
						<colgroup>
							<col width="60px" />
							<col />
							<col width="80px" />
							<col />
						</colgroup>
						<tbody>
							<tr>
								<th CL='STD_GRODID'>그룹오더번호</th>
								<td colspan="2">
									<input type="text" class="text" name="SHPOKY" id="SHPOKY" style="text-align: center;" onfocus="focusCheck(this.id)" onkeypress="commonUtil.enterKeyCheck(event, 'searchList()')" validate="required" />
								</td>
							</tr>
							<tr>
								<th CL='STD_SKUKEY'>품번</th>
								<td colspan="2">
									<input type="text" class="text" name="SKUKEY" id="SKUKEY" style="text-align: center;" onfocus="focusCheck(this.id)" onkeypress="commonUtil.enterKeyCheck(event, 'searchList()')" />
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="tableWrap_search section" style="margin-bottom: 0px;">
					<div class="tableHeader">
						<table style="width: 950px"> 
							<colgroup>
								<col width="10px" />
								<col width="10px" />
								<col width="20px" />
								<col width="20px" />
								<col width="20px" />
								<col width="20px" />
								<col width="20px" />
								<!-- <col width="20px" /> -->
								<col width="20px" />
							</colgroup>
							<thead>
								<tr class="thead">
									<th CL='STD_NO'>순번</th>
									<th CL='STD_SPOSIT'></th>
									<th CL='STD_GRODID'></th>
									<th CL='STD_GRPOIT'></th>
									<th CL='STD_DESC01'>품명</th>
									<th CL='STD_QTJCMP'>피킹수량</th>
									<th CL='STD_QTCHEK'>검수수량</th>
									<!-- <td CL='STD_STATIT'>아이템 상태</td> -->
									<th CL='STD_STATNM'>아이템 상태명</th>
								</tr>
							</thead>
						</table>
					</div>
					<div class="tableBody">
						<table style="width: 950px">
							<colgroup>
								<col width="10px" />
								<col width="10px" />
								<col width="20px" />
								<col width="20px" />
								<col width="20px" />
								<col width="20px" />
								<col width="20px" />
								<!-- <col width="20px" /> -->
								<col width="20px" />
							</colgroup>
							<tbody id="gridList">
								<tr CGRow="true">
									<td GCol="rownum"></td>
									<td GCol="rowCheck"></td>
									<td GCol="text,SHPOKY"></td>
									<td GCol="text,SHPOIT"></td>
									<td GCol="text,DESC01"></td>
									<td GCol="text,QTJCMP"></td>
									<td GCol="input,QTSHPC" GF="N 10,0"></td>
									<!-- <td GCol="text,STATIT">아이템 상태</td> -->
									<td GCol="text,STATNM">아이템 상태명</td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
				<!-- end table_body -->
				<div class="footer_5">
					<table>
						<tr>
							<td class=f_1 onclick ="showMain()" width="33%"><label CL='BTN_CLOSE'></label></td>
							<td class=f_1 onclick ="saveData()" width="33%"><label CL='BTN_SAVE'></label></td>
							<td class=f_1 onclick ="searchDetailList();" width="33%"><label CL='BTN_DISDTL'></label></td>
						</tr>
					</table>
				</div><!-- end footer_5 -->	
			</div>
		</div>
	</div>
	
	<!-- detailInfo start -->
    <div id="detailInfo">
        <!-- tem3_content start -->
        <div class="tem4_content">
            <div class="select_box" id="bindArea">
				<div id="searchArea2">
					<table>
						<colgroup>
							<col width="60px" />
							<col />
							<col width="80px" />
							<col />
						</colgroup>
						<tbody>
							<tr>
								<th CL='STD_GRODID'>그룹오더번호</th>
								<td>
									<input type="text" class="text" name="S_SHPOKY" id="S_SHPOKY" style="text-align: center;" disabled="disabled"/>
								</td>
								<th CL='STD_GRODNM'></th>
								<td>
									<input type="text" class="text" name="S_SHPOIT" id="S_SHPOIT" style="text-align: center;" disabled="disabled"/>
								</td>
							</tr>
							<tr>
								<th CL='STD_SKUKEY'>품번</th>
								<td>
									<input type="text" class="text" name="S_SKUKEY" id="S_SKUKEY" style="text-align: center;" disabled="disabled"/>
								</td>
								<th CL='STD_DESC01'></th>
								<td>
									<input type="text" class="text" name="S_DESC01" id="S_DESC01" style="text-align: center;" disabled="disabled"/>
								</td>
							</tr>
							<tr>
								<th CL='STD_TOTCMP'>총피킹수량</th>
								<td>
									<input type="text" class="text" name="TOTCMP" id="TOTCMP" style="text-align: center;" disabled="disabled"/>
								</td>
								<th CL='STD_TOTGMS'>총검수수량</th>
								<td>
									<input type="text" class="text" name="TOTGMS" id="TOTGMS" style="text-align: center;" disabled="disabled"/>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="tableWrap_search section" style="margin-bottom: 0px;">
					<div class="tableHeader">
						<table style="width: 900px"> 
							<colgroup>
								<col width="10px" />
								<col width="20px" />
								<col width="20px" />
								<col width="20px" />
								<col width="20px" />
								<col width="20px" />
							</colgroup>
							<thead>
								<tr class="thead">
									<th CL='STD_NO'>순번</th>
									<th CL='STD_SHPOKY'></th>
									<th CL='STD_SHPOIT'></th>
									<th CL='STD_PTNRKY'>거래처</th>
									<th CL='STD_QTJCMP'>피킹수량</th>
									<th CL='STD_QTCHEK'>검수수량</th>
								</tr>
							</thead>
						</table>
					</div>
					<div class="tableBody">
						<table style="width: 900px">
							<colgroup>
								<col width="10px" />
								<col width="20px" />
								<col width="20px" />
								<col width="20px" />
								<col width="20px" />
								<col width="20px" />
							</colgroup>
							<tbody id="gridItemList">
								<tr CGRow="true">
									<td GCol="rownum"></td>
									<td GCol="text,SHPOKY"></td>
									<td GCol="text,SHPOIT"></td>
									<td GCol="text,PTNRNM"></td>
									<td GCol="text,QTJCMP"></td>
									<td GCol="input,QTSHPC" GF="N 10,0"></td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
				<!-- end table_body -->
				<div class="footer_5">
					<table>
						<tr>
							<td class=f_1 onclick ="gridDetail('main');" width="33%"><label CL='BTN_CLOSE'></label></td>
							<td class=f_1 onclick ="saveData();" width="33%"><label CL='BTN_SAVE'></label></td>
						</tr>
					</table>
				</div><!-- end footer_5 -->	
			</div>
    </div>
    <!-- detailInfo end -->
</body>