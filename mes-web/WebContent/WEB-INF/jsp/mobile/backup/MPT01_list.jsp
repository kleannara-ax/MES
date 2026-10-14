<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	request.setCharacterEncoding("UTF-8");
	String LOTA07 = request.getParameter("LOTA07");
	String AREAKY = request.getParameter("AREAKY");
	String LOTA12 = request.getParameter("LOTA12");
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
			command : "MPT01",
			bindArea : "searchArea",
			gridMobileType : true
	    });
		searchList();
	});
	
	function searchList(){
		var param = new DataMap();
		param.put("LOTA07", "<%=LOTA07%>");
		param.put("AREAKY", "<%=AREAKY%>");
		param.put("LOTA12", "<%=LOTA12%>");
		param.put("WAREKY", "<%=wareky%>");
		param.put("SKUKEY", "<%=SKUKEY%>");
		
		gridList.gridList({
	    	id : "gridList",
	    	param : param
	    });
	}
	
	function gridListEventDataBindEnd(gridId, dataLength){
		if( gridId == "gridList" && dataLength < 1 ){
			location.href="/mobile/MPT01.page";
		}else{
			showMain();	
		}
	}
	
	function showMain() {
		$("#detailInfo").hide();
		$("#main").show();
	}
	
	function savaData(){
		var locaky = $('#LOCAKY').val();
		var docdat = $('#DOCDAT').val();
		if(locaky == ""){
			commonUtil.msgBox("VALID_M1568"); //로케이션을 입력해주세요.
			return;
		}

		if(locaky != ""){
			var param = new DataMap();
			param.put("LOCAKY",locaky);

			var json = netUtil.sendData({
				module : "Mobile",
				command : "LOCATION_VALIDATION",
				sendType : "map",
				param : param
			});
			
			if(json.data["CNT"] < 1){
				commonUtil.msgBox("MASTER_M0047");  // alert("존재하지 않는 로케이션입니다.");
				$('#LOCAKY').val("");
				$('#LOCAKY').focus();
				return;
			}
		} 
		
		var param = new DataMap();
		var list = gridList.getSelectData("gridList");
		
		if(list.length < 1){
			commonUtil.msgBox("VALID_M0006"); // 선택된 데이터가 없습니다.
			return;
		}
		
		param.put("list",list);
		param.put("LOCAKY",locaky);
		param.put("DOCDAT",docdat);

		var json = netUtil.sendData({
			url:"/mobile/Mobile/json/SaveMPT01.data",
			param : param
		});

		var jsonLngth = json.data.length;
		
		if(jsonLngth > 5 && jsonLngth != 10){
			var msgList = json.data.split("†");
			var msgTxt = commonUtil.getMsg(msgList[0], (msgList.length > 1 ? msgList[1].split("/") : null));
			commonUtil.msg(msgTxt);
			return;
		} 

		if(json && json.data){
			commonUtil.msgBox("MASTER_M0564");
			$('#LOCAKY').val("");
			searchList();
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
 		location.href="/mobile/MPT01.page";
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
								<col width="180px"/>
								<col width="100px" />
								<col width="100px" />
								<col width="100px"/>
								<col width="100px" />
								<col width="100px"/>
								<col width="100px" />
								<col width="100px"/>
						</colgroup>
						<thead>
							<tr>
								<th CL='STD_NO'>No.</th>
								<th GBtnCheck="true"></th>
								<th CL='STD_LOTNUM'></th>
								<th CL='STD_AREAKY'></th>
								<th CL='STD_LOCAKY'></th>
								<th CL='STD_SKUKEY'></th>
								<th CL='STD_DESC01'></th>
								<th CL='STD_QTSIWH'></th>
								<th CL='STD_QTTAOR'></th>
								<th CL='STD_UOMKEY'></th>
								<th CL='STD_LOTA11'></th>
								<th CL='STD_LOTA13'></th>
								<th CL='STD_LOTA12'></th>
								<th CL='STD_LOTA07'></th>
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
								<col width="180px"/>
								<col width="100px" />
								<col width="100px" />
								<col width="100px"/>
								<col width="100px" />
								<col width="100px"/>
								<col width="100px" />
								<col width="100px"/>
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rownum">1</td>
								<td GCol="rowCheck"></td>
								<td GCol="text,LOTNUM"></td>
								<td GCol="text,AREAKY"></td>
								<td GCol="text,LOCAKY"></td>
								<td GCol="text,SKUKEY"></td>
								<td GCol="text,DESC01"></td>
								<td GCol="text,QTSIWH" GF="N"></td>					
								<td GCol="input,QTTAOR" GF="N" validate="max(GRID_COL_QTSIWH_*)"></td>
								<td GCol="text,UOMKEY"></td>
								<td GCol="text,LOTA11" GF="C"></td>
								<td GCol="text,LOTA13" GF="C"></td>
								<td GCol="text,LOTA12"></td>
								<td GCol="text,LOTA07"></td>
							</tr>
						</tbody>
					</table>
				</div>
				</div>
				<div>
					<table>
						<tr height="50px">
							<th CL="STD_LOCAKY">적치로케이션</th>	
							<td><input type="text" name="LOCAKY" id="LOCAKY" /></td>
						</tr>
					</table>
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