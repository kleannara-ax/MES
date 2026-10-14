<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	request.setCharacterEncoding("UTF-8");
	String SEBELN = request.getParameter("SEBELN");
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
			command : "MGR01",
			bindArea : "searchArea",
			gridMobileType : true
	    });
		searchList();
	});
	
	function searchList(){
		var param = new DataMap();
		param.put("SEBELN", "<%=SEBELN%>");
		param.put("WAREKY", "<%=wareky%>");
		
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
		
		netUtil.send({
			module : "Mobile",
			command : "MGR01TOP",
			bindId : "MGR01TOP",
			sendType : "map",
			bindType : "field",
			param : param
		});
		showMain();
		gridList.setReadOnly("gridList", true, ['ASKU05']);
	}
	
	function showMain() {
		$("#detailInfo").hide();
		$("#main").show();
	}
	
	function savaData(){
		var param = new DataMap();
		var list = gridList.getGridData("gridList");
		var doctxt = $('#DOCTXT').val();
		
		param.put("list",list);
		param.put("WAREKY","<%=wareky%>");
		param.put("DOCTXT",doctxt);

		var json = netUtil.sendData({
			url:"/mobile/Mobile/json/SaveMGR01.data",
			param : param
		});
		
		if(json.data.length > 5 && json.data.length != 10){
			if(json.data.indexOf("†") > -1){
				var msgList = json.data.split("†");
				var msgTxt = commonUtil.getMsg(msgList[0], (msgList.length > 1 ? msgList[1].split("/") : null));
				commonUtil.msg(msgTxt);
				return;
			} else {
				commonUtil.msgBox(json.data);
				return;
			}
		} 
		
		if(json && json.data){
			commonUtil.msgBox("MASTER_M0564");
			showPre();
		}else{
			commonUtil.msgBox("VALID_M0002");
		}
			
	}
 
 	function clearText(data){
		if(data!=null||data!=""){
	    	data.value="";
	    }      
	}
	
 	function showPre(){
 		location.href="/mobile/MGR01.page";
 	}
 	
	function gridListEventRowDblclick(gridId, rowNum, colName, colValue){
		if(gridId == "gridList"){
			var rowData = gridList.getRowData(gridId, rowNum);
			
			var param = new DataMap();
			param.put("SKUKEY", rowData.get("SKUKEY"));
			
			var json = netUtil.sendData({
				module : "Mobile",
				command : "SKU_IMG_CNT",
				sendType : "map",
				param : param
			});
			
			dataBind.paramData("searchArea", rowData);
			
			if(json.data["CNT"] == 0){
				json = netUtil.sendData({
					module : "Mobile",
					command : "MIM01_SKUKEY",
					sendType : "map",
					param : param
				});
				
				if(json.data['CNT'] == 0){
					commonUtil.msgBox("MASTER_M1104"); //품번을 확인해주세요.
					return;
				} else {
					if(json.data['ASKL04'] == "S"){
						commonUtil.msgBox("MASTER_M1112", json.data['ASKL05']); // 메인품목코드가 아닙니다. [메인품목코드:{(0)}]
						return;
					}
				}
				
				// 이미지등록 팝업
				mobile.linkPopOpen("/mobile/MIM01_POP.page", rowData);
			} else {
				// 이미지목록 팝업
				mobile.linkPopOpen("/mobile/SKU_IMG_POP.page", rowData);
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
				<table class="util" id="MGR01TOP">
					<colgroup>
						<col width="100" />
					</colgroup>
					<tr >
						<th CL='STD_EBELN'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:</th>
						<td>
							<input type="text" name="SEBELN" id="SEBELN" readonly="readonly" size="50px" />
						</td>
					</tr>
					<tr>
						<th CL='STD_DOCTXT'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:</th>
						<td>
							<input type="text" name="DOCTXT" id="DOCTXT" size="50px" />
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
								<col width="100px" />
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px"/>
								<col width="100px" />
								<col width="100px"/>
								<col width="100px" />
						</colgroup>
						<thead>
							<tr>
								<th CL='STD_NO'></th>
								<th CL='STD_ASKU05_M,3'>이미지 등록 유무</th>
								<th CL='STD_SKUKEY'></th>
								<th CL='STD_QTYRCV'></th>
								<th CL='STD_DESC01'></th>
								<th CL='STD_RCVDAT'></th>
								<th CL='STD_LOTA12'></th>
								<th CL='STD_AREAKY'></th>
								<th CL='STD_AREANM'></th>
								<th CL='STD_UOMKEY'></th>
								<th CL='STD_LOCAKY'></th>
								<th CL='STD_LOTA11'></th>
								<th CL='STD_RIMDMT'></th>
								<th CL='STD_LOTA10'></th>
								<th CL='STD_LOTA17'></th>
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
								<col width="100px" />
								<col width="100px"/>
								<col width="100px" />
								<col width="100px"/>
								<col width="100px" />
								<col width="100px"/>
								<col width="100px" />
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rownum">1</td>
								<td GCol="check,ASKU05"></td>
								<td GCol="text,SKUKEY"></td>
								<td GCol="text,QTYRCV" GF="N"></td>
								<td GCol="text,DESC01"></td>					
								<td GCol="text,ASNDAT" GF="C"></td>
								<td GCol="text,DOCDAT" GF="C"></td>
								<td GCol="text,AREAKY"></td>
								<td GCol="text,AREANM"></td>
								<td GCol="text,UOMKEY"></td>
								<td GCol="text,LOCAKY"></td>
								<td GCol="text,LOTA11" GF="C"></td>
								<td GCol="text,LOTA13" GF="C"></td>
								<td GCol="text,LOTA10" ></td>
								<td GCol="text,LOTA17" GF="N"></td>
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
							<td class=f_1 onclick ="savaData()"><label CL='BTN_SAVE'></label></td>
						</tr>
					</table>
				</div><!-- end footer_5 -->	
			</div>
	</div>
	</div>
</body>