<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>MES</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
	    	url : "/mes/Master/MAS15/json/datalist.data",
	    	bigdata : false,
	    	selectRowDeleteType : true
	    });
	});
	
	function searchHelpEventCloseAfter(searchCode, multyType, selectData, rowData){
		if(searchCode == "PLANT"){
			reloadCombo();
		}
	}
	
	function reloadCombo(){
		$comboObj = $("#PROC_CD");
		inputList.reloadCombo($comboObj, configData.INPUT_COMBO, "mes,PROC_CD");
	}

	function comboEventDataBindeBefore(comboAtt){
		if(comboAtt == "mes,PROC_CD"){
			var param = new DataMap();
			
			param.put("WERKS", $("#WERKS").val().toUpperCase());
		}
		return param;
	}
	
	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");
			
			param.put("P_TYPE", "LIST");
			
			gridList.gridList({
				id : "gridList",
				param : param
				});
			}
		}
		
	function searchHelpEventOpenBefore(searchCode, gridType, $inputObj, rowNum){
		var param = new DataMap();
		
		if(searchCode == "OP" || searchCode == "ERR"){
			if(gridType == false){
				var werks = gridList.getColData("gridList", rowNum, "WERKS");
				param.put("WERKS", werks);
			}
		}
		return param;
	}
	
	function searchHelpEventCloseAfter(searchCode, gridType, selectData, rowData){
		if(gridType == false){
			if(searchCode == "OP"){
				gridList.setColValue("gridList", gridList.getFocusRowNum("gridList"), "PROC_NM", rowData.get("PROC_NM"));
			} else if(searchCode == "ERR"){
				gridList.setColValue("gridList", gridList.getFocusRowNum("gridList"), "DISPO_NM", rowData.get("DISPO_NM"));
				gridList.setColValue("gridList", gridList.getFocusRowNum("gridList"), "DISPO_DIV", rowData.get("DISPO_DIV"));
			}
		}
	}
	
	function saveData(){
		if(gridList.getModifyRowCount("gridList") == 0 ){
			commonUtil.msgBox("MASTER_M0545");
			
			return;
		}
		if(!commonUtil.msgConfirm(configData.MSG_MASTER_SAVE_CONFIRM)){
			return;
		}
		if(gridList.validationCheck("gridList", "data")){
			var list = gridList.getGridData("gridList");
	
			var param = new DataMap();
	
			param.put("P_TYPE","SAVE");
			param.put("list", list);
	
			var json = netUtil.sendData({
				url : "/mes/Master/MAS15/json/datalist.data",
				param : param
			});
			
			if(json){
				if(json.data){
					searchList();
				}
			}
			
			
		}
	}
	
	function commonBtnClick(btnName){
		if(btnName == "Search"){
			var param = new DataMap();
	        param.put("PROGID", "<%= menuId%>");
	        param.put("LGTYPE", "SEARCH");
	        var json = netUtil.sendData({
	            url: "/mes/system/json/saveLog.data",
	            param : param
	        });
			
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}
	}
</script>
</head>
<body>
<%@ include file="/common/include/webdek/layout.jsp" %>
<!-- content -->
<div class="content_wrap">
	<div class="content_inner">
		<%@ include file="/common/include/webdek/title.jsp" %>
		<div class="content_serch" id="searchArea">
			<div class="btn_wrap">
				<div class="fl_l">
				</div>
				<div class="fl_r">
					<input type="button" id="button-0-1" CB="Search SEARCH BTN_SEARCH" />
					<input type="button" id="button-0-2" CB="Save SAVE BTN_SAVE" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="STD_WERKS">플랜트</dt>
						<dd>
							<input type="text" id="WERKS" id='WERKS' name="WERKS" validate="required" UIInput="S,PLANT" UIFormat="U" onkeyup="reloadCombo()"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_PROC_CD">공정</dt>
						<dd>
							<select class="input" id='PROC_CD' name="PROC_CD" UIInput="SR,OP" UIFormat="U">
								<option value=''>All</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_DISPO_CD">폐품코드</dt>
						<dd>
							<input type="text" class="input" name="M024.DISPO_CD" UIInput="SR,ERR" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="STD_DISPO_DIV">폐품항목유형</dt>
						<dd>
							<select class="input" name="DISPO_DIV" CommonCombo="PROCGRP">
								<option value="">All</option>
							</select>
						</dd>
					</dl>
				</div>
				<div class="btn_tab">
					<input type="button" class="btn_more" value="more" onclick="searchMore()"/>
				</div>
			</div>
		</div>
        <div class="search_next_wrap">
			<div class="content_layout tabs">
				<ul class="tab tab_style02">
					<li><a href="#tab1-1"><span CL="STD_GENERAL"></span></a></li>
					<li class="btn_zoom_wrap">
						<ul>
							<!-- <li><button class="btn btn_smaller"><span>축소</span></button></li> -->
							<li><button class="btn btn_bigger"><span>확대</span></button></li>
						</ul>
					</li>
				</ul>
				<div class="table_box section" id="tab1-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="40" GCol="rowCheck"></td>
										<td GH="100" GCol="add,WERKS,PLANT" validate="required" style="text-align:center;" GF="U">플랜트</td>
										<td GH="100" GCol="add,PROC_CD,OP" validate="required" style="text-align:center;">공정코드</td>
										<td GH="120" GCol="text,PROC_NM">공정명</td>
										<td GH="100" GCol="text,DISPO_DIV" style="text-align:center;">폐품유형</td>
										<td GH="100" GCol="text,DISPO_DIV_NM">폐품유형명</td>
										<td GH="100" GCol="add,DISPO_CD,ERR" validate="required" style="text-align:center;">폐품코드</td>
										<td GH="200" GCol="text,DISPO_NM" >폐품명</td>
										<td GH="230" GCol="input,RMK">비고</td>
										<td GH="140" GCol="text,REGDATE" style="text-align:center;"></td>
										<td GH="100" GCol="text,REGNM"></td>
										<td GH="140" GCol="text,UPDDATE" style="text-align:center;"></td>
										<td GH="100" GCol="text,UPDNM"></td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<jsp:include page="/WEB-INF/jsp/common/commonBtnAuth.jsp">
						<jsp:param name="authCd" value="1" />
						<jsp:param name="showAuthCd" value="1,2,3,4,5,6,9,10" />
						</jsp:include>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>