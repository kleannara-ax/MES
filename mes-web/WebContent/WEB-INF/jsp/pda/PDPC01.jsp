<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<head>
<style type="text/css">
button {
	vertical-align: bottom;
    height: 37px;
}
</style>
<style type="text/css">
.tem5_content .tableWrap_search select	{width:172px;  height:25px; }
.tem5_content .tableWrap_search .text_2{width:90%; margin-right:3px;height:22px;border:#b8b8b8;}

.select-editable { position:relative; background-color:white; border:solid 1px #b8b8b8; width:172px; height:25px; }
.select-editable select { top:0px; left:0px; width:172px; height:25px; font-size:14px;  border:none;  }
.select-editable input { position:absolute; top:0px; left:0px; width:90%; height:23px; font-size:12px;  border:none;   }
.select-editable select:focus, .select-editable input:focus { outline:none; }
</style>


<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>Mobile WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script>
	var chkObjId = "";
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			editable : false,
			module : "WmsMobileInventoryPhysicalCount",
			command : "PDMV46",
			gridMobileType : true
	    });
		// searchList();
		$("#PHYIKY").focus();
	});
	
	function searchList(){
		var param = inputList.setRangeParam("searchArea");
		param.put("SES_WAREKY", "<%=wareky%>");
		param.put("SES_OWNER", "<%=owner%>");
		
// 		param.put("PDANON", ($('#PDANON').prop("checked") == "V" ? "V" : " "));
// 		param.put("PDAGAP", ($('#PDAGAP').prop("checked") == "V" ? "V" : " "));
		
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
	}
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if(gridId="gridList" && dataLength > 0 ){
			var docdat = $('#DOCDAT').val();
			var phyiky = $("#PHYIKY").val();
			var locaky = $("#LOCAKY").val();
			PlaySound('s');
			$("#LOCAKY").focus();
		}else{
			PlaySound('e');
			$("#"+chkObjId).focus();
			$("#"+chkObjId).select();
		}
	}
	
	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "WmsMobileInventoryPhysicalCount,PHYIKYCOMBO"){
			var param = new DataMap();
			
			var docdat = $('#DOCDAT').val();
			param.put("DOCDAT", docdat);
			
			return param;
		}
	}
	
	function reloadCombo(){
		$comboObj = $("#PHYIKYCOMBO");
		inputList.reloadCombo($comboObj, configData.INPUT_COMBO, "WmsMobileInventoryPhysicalCount,PHYIKYCOMBO");
		
		$("#PHYIKY").focus();
	}
	
	function detail(){
		var fRow = gridList.getFocusRowNum("gridList");
		var row = gridList.getRowData("gridList", fRow);
		var pdardo = $(':radio[name="PDARDO"]:checked').val();
		
		row.put("PDARDO", pdardo);

		var rowCnt = gridList.getGridDataCount("gridList");
		
		if(rowCnt < 1){
			commonUtil.msgBox("VALID_M0006");
			PlaySound('e');
			return;
		}else{
			mobile.linkPopOpen('/mobile/PDMV47.page',row);
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
	
	function gridListEventRowDblclick(gridId, rowNum, colName, colValue){
		/* var fRow = gridList.getFocusRowNum("gridList");
		var row = gridList.getRowData("gridList", fRow); */
		var data = inpuList.setRangeParam("searchArea");
		mobile.linkPopOpen('/mobile/PDMV47.page',data);
	}
	
	function linkPopCloseEvent(opt){
		if(opt == 'save'){
			$('#PHYIKY').val("");
			
			reloadCombo();

			gridList.resetGrid("gridList");
			$('#PHYIKY').focus();
		}else{
			$("#PHYIKY").focus();
		}
	}
	
	function focusCheck(objId){
		if(objId != chkObjId){
			chkObjId = objId;
			$("#"+chkObjId).select();
		}
	}
</script>
</head>
<body>
<div class="main_wrap" id="searchArea">
	<div id="main_container">
		<div class="tem4_content">
			<div class="select_box">
				<table>
					<colgroup>
						<col width="100px"  />
						<col />
						<col width="60px" />
					</colgroup>
					<tbody>
						<tr>
							<th CL="STD_PHYDAT">실사일자</th>
							<td>
								<input type="text" class="text2" name="DOCDAT" id="DOCDAT"  UIFormat="C N" onchange="reloadCombo()"/>
							</td>
						</tr>
						<tr>
							<th CL='STD_PHYIKY'></th>
							<td colspan="3">
							<style>
				               .select-editable { position:relative; background-color:white; border:solid 1px #d5d5d5; width:100%; height:35px; }
				               .select-editable select { position:absolute; top:0px; left:0px; width:100%; height:35px; font-size:14px;  border:none;  }
				               .select-editable input { position:absolute; top:0px; left:0px; width:90%; height:33px; font-size:12px;  border:none;   }
				               .select-editable select:focus, .select-editable input:focus { outline:none; }
			                </style>
			                <div class="select-editable">
			                    <select  Combo="WmsMobileInventoryPhysicalCount,PHYIKYCOMBO" onchange="this.nextElementSibling.value=this.value,searchList()" id="PHYIKYCOMBO">
		                           <option value=""></option>
			                    </select>
			                    <input type="text" name="PHYIKY" id="PHYIKY" value="" onfocus="focusCheck(this.id)" onkeypress="commonUtil.enterKeyCheck(event, 'searchList()')" />
				             </div>
				             </td>
						</tr>
						<tr>
							<th CL="STD_LOCAKY">LOC</th>
							<td>
								<input type="text" class="text" name="LOCAKY" id="LOCAKY" onfocus="focusCheck(this.id)" onkeypress="commonUtil.enterKeyCheck(event, 'searchList()')" />
							</td>
						</tr>
					</tbody>
				</table>
				<table>
					<colgroup>
						<col width="100px" />
						<col width="28%" />
						<col width="100px" />
						<col width="*" />
					</colgroup>
					<tbody>
						<tr>
							<th CL="STD_PDANON">NONE</th>
							<td>
								<input type="radio" name="PDARDO" id="PDANON" style="width: 25px; height: 25px" value="1" checked="checked" onclick="searchList()"/>
							</td>
							<th CL="STD_PDAGAP">GAP</th>
							<td>
								<input type="radio" name="PDARDO" id="PDAGAP" style="width: 25px; height: 25px" value="2" onclick="searchList()" />
							</td>
						</tr>
					</tbody>
				</table>
				<div class="tableWrap_search section">
					<div class="tableHeader">
						<table style="width: 100%">
							<colgroup>
									<col width="30px" />
									<col width="90px" />
									<col width="90px" />
									<col width="70px" />
									<col width="120px" />
							</colgroup>
							<thead>
								<tr>
									<th CL='STD_NO'>No.</th>
									<th CL='STD_LOCAKY'></th>
									<th CL='STD_BARCOD'></th>
									<th CL='STD_SKUKEY'></th>
									<th CL='STD_DESC01'></th>
								</tr>
							</thead>
						</table>				
					</div>					
					<div class="tableBody">
						<table style="width: 100%">
							<colgroup>
									<col width="30px" />
									<col width="90px" />
									<col width="90px" />
									<col width="70px" />
									<col width="120px" />
							</colgroup>
							<tbody id="gridList">
								<tr CGRow="true">
									<td GCol="rownum">1</td>
									<td GCol="text,LOCAKY"></td>
									<td GCol="text,EANCOD"></td>
									<td GCol="text,SKUKEY"></td>
									<td GCol="text,DESC01"></td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
			</div>
		</div>
		
		<!-- end table_body -->
		<div class="footer_5">
			<table>
				<tr>
					<td class=f_1 onclick ="showMain()" width="33%"><label CL='BTN_CLOSE'></label></td>
					<td class=f_1 onclick ="detail()" width="33%"><label CL='BTN_STWORK'></label></td>
				</tr>
			</table>
		</div><!-- end footer_5 -->	
	</div>
	</div>
	</div>
</body>