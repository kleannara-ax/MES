<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	String DOORKY = request.getParameter("DOORKY");
	String DOTYPE = request.getParameter("DOTYPE");
	
	String txt = DOORKY.substring(0,1);
	if(txt.equals("O")){
		txt ="Picking By Shp.Doc.";
	}else if(txt.equals("S")){
		txt ="Picking By Sku";
	}else if(txt.equals("C")){
		txt ="Picking By Customer";
	}else if(DOTYPE.equals("1")){
		txt ="Picking By Request";
	}
%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>Mobile WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script type="text/javascript" src="/mobile/js/signature_pad.min.js"></script>
<style type="text/css">
	#signPad {
		margin:10px;
		position:relative;
		width:98%;
		height:200px;
	}
	
	.m-signature-pad {
	  position: absolute;
	  font-size: 10px;
	  width: 100%;
	  height: 100%;
	  border: 1px solid #e8e8e8;
	  background-color: #fff;
	  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.27), 0 0 40px rgba(0, 0, 0, 0.08) inset;
	  border-radius: 4px;
	}
	
	.m-signature-pad--body {
	  position: absolute;
	  left: 15px;
	  right: 15px;
	  top: 15px;
	  bottom: 15px;
	  border: 1px solid #f4f4f4;
	}
	
	.m-signature-pad--body
	  canvas {
	    position: absolute;
	    left: 0;
	    top: 0;
	    width: 100%;
	    height: 100%;
	    border-radius: 4px;
	    box-shadow: 0 0 5px rgba(0, 0, 0, 0.02) inset;
	  }
	
	@media screen and (min-device-width: 768px) and (max-device-width: 1024px) {
	  .m-signature-pad {
	    margin: 10%;
	  }
	}
	
	@media screen and (max-height: 320px) {
	  .m-signature-pad--body {
	    left: 0;
	    right: 0;
	    top: 0;
	    bottom: 0;
	  }
	}
</style>
<script>
	var sign;
	var canvas;

	$(document).ready(function(){
		canvas = $("#signature-pad canvas")[0];
		
		sign = new SignaturePad(canvas, {
		    minWidth: 3,
		    maxWidth: 5,
		    penColor: "rgb(66, 133, 244)"
		});
		
		gridList.setGrid({
	    	id : "gridList",
			editable : false,
			module : "Mobile",
			command : "MOS01",
			gridMobileType : true
	    });
		
		searchList();
		resizeCanvas();
		 
		$(window).on("resize", function(){
		    resizeCanvas();
		});
	});
	
	var doorky = "<%=DOORKY%>";
	var dotype = "<%=DOTYPE%>";
	function searchList(){
		var param = new DataMap();
		param.put("DOORKY", doorky);
		param.put("DOTYPE", dotype);
		param.put("WAREKY", "<%=wareky%>");
		
		clearData();
		
		gridList.resetGrid("gridList");
		gridList.setReadOnly("gridList", false);
		
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
		
		$("input[name='DOORKY']").val(doorky);
	}
	
	function showScan(){
		location.href="/mobile/MOS01.page?DOORKY="+doorky+"&DOTYPE="+dotype;
	}
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if( dataLength == 0 ){
			location.href="/mobile/MOS01.page?DOORKY="+doorky+"&DOTYPE="+dotype;
		}
 	}
	
	function saveData(){
		if(sign.isEmpty()) {
            commonUtil.msgBox("SYSTEM_M0102");
            return;
        } else {
        	if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
				return;
			}
        	
        	var list = gridList.getGridAvailData("gridList");
			var row = list[0];
        	
        	var param = new DataMap();
			param.put("DOCCAT", row.get("DOCCAT"));
			param.put("DOCUTY", row.get("DOCUTY"));
			param.put("DOCUKY", row.get("DOCUKY"));
			param.put("SIGN", sign.toDataURL());
        	
        	var json = netUtil.sendData({
        		url : "/mobile/Mobile/json/saveWKSIGN.data",
        		param : param
        	});
        	
        	if(json && json.data){
        		commonUtil.msgBox("MASTER_M0999");
        		
        		clearData();
        		location.href="/mobile/MOS01.page?DOORKY="+doorky+"&DOTYPE="+dotype+"&PASSYN=true";
        	}
        }
	}
	
	function clearData(){
		sign.clear();
	}
	
	function resizeCanvas(){
	    var canvas = $("#signature-pad canvas")[0];
	
	    var ratio =  Math.max(window.devicePixelRatio || 1, 1);
	    canvas.width = canvas.offsetWidth * ratio;
	    canvas.height = canvas.offsetHeight * ratio;
	    canvas.getContext("2d").scale(ratio, ratio);
	}
</script>
</head>

<body>
	<div class="main_wrap">
	   <div class="tem4_content">
			<div id="searchArea">
				<table class="table type1">
					<colgroup>
						<col width="100" />
					<col />
					</colgroup>
					<tbody>
						<tr>
							<th CL="STD_PKBARCODE">피킹바코드</th>
							<td>
								<input type="text" class="text" name="DOORKY" readonly="readonly" />
							</td>
						</tr>
						<tr>
							<th CL="STD_PKTYPE">피킹유형</th>
							<td>
								<input type="text" class="text" name="PKTYPE" value="<%=txt%>" readonly="readonly" />
							</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>
		<div class="tem4_content">	
			<div class="tableWrap_search section">
				<div class="tableHeader">
					<table style="width: 100%">
						<colgroup>
							<col width="40px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="200px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
						</colgroup>
						<thead>
							<tr class="thead">
								<th CL='STD_NO'></th>
								<th CL='STD_AREAKY'>창고</th>
								<th CL='STD_LOCAKY,3'>로케이션</th>
								<th CL="STD_SKUKEY">품번</th>
								<th CL="STD_DESC01">품명</th>
								<th CL="STD_QTTAOR">지시수량</th>
								<th CL="STD_QTCOMP">피킹수량</th>
								<th CL="STD_UOMKEY">단위</th>
								<th CL="STD_TASKKY">작업오더번호</th>
								<th CL="STD_TASKIT">작업오더순번</th>
								<th CL="STD_SHPOKY">출고오더번호</th>
								<th CL="STD_SHPOIT">출고오더순번</th>
							</tr>
						</thead>
					</table>				
				</div>				
				<div class="tableBody" style="height:200px;">
					<table style="width: 100%">
						<colgroup>
							<col width="40px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="200px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
							<col width="80px" />
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rownum"></td>
								<td GCol="text,AREAKY"></td>
								<td GCol="text,LOCASR"></td>					
								<td GCol="text,SKUKEY"></td>				
								<td GCol="text,DESC01"></td>					
								<td GCol="text,QTTAOR" GF="N"></td>
								<td GCol="text,QTCOMP" GF="N"></td>
								<td GCol="text,UOMKEY"></td>
								<td GCol="text,TASKKY"></td>
								<td GCol="text,TASKIT"></td>
								<td GCol="text,SHPOKY" ></td>
								<td GCol="text,SHPOIT" ></td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
			<div id="signPad">
				<div id="signature-pad" class="m-signature-pad">
			        <div class="m-signature-pad--body">
			            <canvas name="CANVAS"></canvas>
			        </div>
			    </div>
			</div>
		</div>
		<div class="footer_5">
			<table>
				<colgroup>
						<col width="100" />
						<col width="100"/>
						<col width="100" />
				</colgroup>
				<tr>
					<td onclick="showScan()"><label CL='STD_CDSCAN'></label></td>
					<td onclick="clearData()"><label CL='BTN_CLEAR'></label></td>
					<td class=f_1 onclick ="saveData()"><label CL='BTN_SAVE'></label></td>
				</tr>
			</table>
		</div><!-- end footer_5 -->
	</div>
</body>