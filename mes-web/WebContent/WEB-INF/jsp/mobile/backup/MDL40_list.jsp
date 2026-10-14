<%@page import="org.apache.poi.util.SystemOutLogger"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	request.setCharacterEncoding("UTF-8");
	String CREDAT = request.getParameter("CREDAT").replace("/", "");
%>
<!doctype html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width, target-densitydpi=medium-dpi" />
<meta name="format-detection" content="telephone=no" />
<title>슈피겐코리아 모바일 WMS</title>
<%@ include file="/mobile/include/head.jsp" %>
<script>
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			editable : false,
			module : "Mobile",
			command : "MDL40",
			gridMobileType : true
	    });
		
		onloadSearch();
		$("#REGINO").focus();
	});

	function onloadSearch(){
		var param = new DataMap();
		param.put("CREDAT", "<%= CREDAT%>");
		$("#REGINO").val("");
		gridList.gridList({
	    	id : "gridList", 
	    	param : param
	    });
	}
	
	function searchList(){
		var param = dataBind.paramData("searchArea");
		var obj = $("[name=REGINO]").val();
		if(obj == ""){
			alert("운송장번호를 입력하세요.");
			$("[name=REGINO]").focus();
			return;
		}
		$("#REGINO").val("");
	}
 	
	function reginoCheck(orgNo){
		var regVal;
		var cnt = gridList.getGridDataCount("gridList");
		var result = true;
		for(var i = 0 ; i < cnt ; i ++){
			regVal = gridList.getColData("gridList", i, "REGINO");
			
			if(regVal == obj){
				PlaySound('beep');
				gridList.setRowFocus("gridList", i, true);
				result = false;
			}
		}
		return result;
		
	}
	
	function PlaySound(soundObj) {
		var sound = document.getElementById(soundObj);
		if (sound){
			sound.play();
		}
	}
	
 	function clearText(data){
		if(data!=null||data!=""){
	    	data.value="";
	    }      
	}
 	
 	function showMain(){
 		location.href="/mobile/MDL40.page";
 	}
 	
 	function saveRegino(){
 		var param = new DataMap();
		var regino = $("#REGINO").val();
		
		param.put("REGINO", regino);
		var json = netUtil.sendData({
			url:"/mobile/Mobile/json/SaveRtnRegino.data",
			param : param
		});
		if(json && json.data){
			onloadSearch();
		}
 	}
</script>
</head>
<body>
	<div class="main_wrap" >
	<div id="main_container">
		<div class="tem3_content">
			<div class="searchWrap">
				<table>
					<colgroup>
						<col width="50px"  />
						<col />
						<col width="60px" />
					</colgroup>
					<tbody id="searchArea">
						<tr class="t_title">
							<th>운송장번호</th>
							<td>
								<input type="text" class="text" id="REGINO" name="REGINO" onfocus="clearText(this)" onkeypress="commonUtil.enterKeyCheck(event, 'saveRegino()')"/>
							</td>
							<td>
								<input type="button" value="저장" class="bt" onclick="saveRegino()"/>
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
							<col width="13%" />
							<col width="40%" />
							<col width="20%" />
							<col width="27%" />
						</colgroup>
						<thead>
							<tr>
								<th CL='STD_NUMBER'></th>
								<th>송장번호</th>
								<th>수량</th>
								<th>수취인명</th>
							</tr>
						</thead>
					</table>				
				</div>					
				<div class="tableBody">
					<table>
						<colgroup>
							<col width="13%" />
							<col width="40%" />
							<col width="20%" />
							<col width="27%" />
						</colgroup>
						<tbody id="gridList">
							<tr CGRow="true">
								<td GCol="rownum">1</td>
								<td GCol="text,REGINO"></td>
								<td GCol="text,QTY"></td>
								<td GCol="text,DNAME2"></td>
							</tr>
						</tbody>
					</table>
				</div>
				</div>
			</div>
			<div class="footer_5">
				<table>
					<tr>
						<td onclick="showMain()">이전 화면</td>
					</tr>
				</table>
			</div><!-- end footer_5 -->	
		</div>
	</div>
	<audio src="/common/images/beep-05_back.wav"  id="beep" />
</body>