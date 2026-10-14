<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/demo_layout.css">
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			module : "Demo",
			command : "DEMO"
	    });
	});

	function searchList(){
		if(validate.check("searchArea")){
			var param = inputList.setRangeParam("searchArea");

			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}
	function saveData(){
		if(gridList.validationCheck("gridList", "all")){
			gridList.gridSave({
		    	id : "gridList",
		    	modifyType : "A"
		    });
		}
	}

	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
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
					<input type="button" CB="Search SEARCH BTN_SEARCH" />
					<input type="button" CB="Save SAVE BTN_SAVE" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="OWNRKY"></dt>
						<dd>
							<input type="text" class="input" name="OWNRKY" UIInput="S,OWNRKY" IAname="OWNRKY" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="SKUKEY"></dt>
						<dd>
							<input type="text" class="input" name="SKUKEY" UIInput="SR"/>
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
					<li><a href="#tab1-1"><span>일반</span></a></li>
				</ul>
				<div class="table_box section" id="tab1-1">
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="40" GCol="rowCheck"></td>
										<td GH="80" GCol="input,OWNRKY"></td>
										<td GH="80" GCol="input,SKUKEY"></td>
										<td GH="80" GCol="check,DELMAK"></td>
										<td GH="150" GCol="input,CUBICM" GF="N 20,1"></td>
										<td GH="200" GCol="input,DESC01"></td>
										<td GH="80" GCol="input,DESC02"></td>
										<td GH="80" GCol="input,VENDKY"></td>
										<td GH="80" GCol="input,ASKU01"></td>
										<td GH="80" GCol="input,ASKU02"></td>
										<td GH="80" GCol="input,ASKU03"></td>
										<td GH="80" GCol="input,ASKU04"></td>
										<td GH="80" GCol="input,ASKU05"></td>
										<td GH="80" GCol="input,ASKL01"></td>
										<td GH="80" GCol="input,ASKL02"></td>
										<td GH="80" GCol="input,ASKL03"></td>
										<td GH="80" GCol="input,ASKL04"></td>
										<td GH="80" GCol="input,ASKL05"></td>
										<td GH="80" GCol="input,EANCOD"></td>
										<td GH="80" GCol="input,GTINCD"></td>
										<td GH="80" GCol="input,SKUG01"></td>
										<td GH="80" GCol="input,SKUG02"></td>
										<td GH="80" GCol="check,SKUG03,false"></td>
										<td GH="80" GCol="input,SKUG04"></td>
										<td GH="80" GCol="input,SKUG05"></td>
										<td GH="80" GCol="input,SKUL01"></td>
										<td GH="80" GCol="input,SKUL02"></td>
										<td GH="80" GCol="input,SKUL03"></td>
										<td GH="80" GCol="input,SKUL04"></td>
										<td GH="80" GCol="input,SKUL05"></td>
										<!-- td GH="80" GCol="input,GRSWGT" GF="N 10"></td>
										<td GH="80" GCol="input,NETWGT" GF="N 10"></td>
										<td GH="80" GCol="input,WGTUNT"></td>
										<td GH="80" GCol="input,LENGTH" GF="N 10"></td>
										<td GH="80" GCol="input,WIDTHW" GF="N 10"></td>
										<td GH="80" GCol="input,HEIGHT" GF="N 10"></td>
										<td GH="80" GCol="input,CAPACT" GF="N 10"></td>
										<td GH="80" GCol="input,DUOMKY"></td>
										<td GH="80" GCol="input,QTDUOM" GF="N 10"></td-->
										<td GH="80" GCol="input,ABCANV"></td>
										<td GH="80" GCol="input,LOTL01"></td>
										<td GH="80" GCol="input,LOTL02"></td>
										<td GH="80" GCol="input,LOTL03"></td>
										<td GH="80" GCol="input,LOTL04"></td>
										<td GH="80" GCol="input,LOTL05"></td>
										<td GH="80" GCol="input,LOTL06"></td>
										<td GH="80" GCol="input,LOTL07"></td>
										<td GH="80" GCol="input,LOTL08"></td>
										<td GH="80" GCol="input,LOTL09"></td>
										<td GH="80" GCol="input,LOTL10"></td>
										<td GH="80" GCol="input,LOTL11"></td>
										<td GH="80" GCol="input,LOTL12"></td>
										<td GH="80" GCol="input,LOTL13"></td>
										<td GH="80" GCol="input,LOTL14"></td>
										<td GH="80" GCol="input,LOTL15"></td>
										<td GH="80" GCol="input,LOTL16"></td>
										<td GH="80" GCol="input,LOTL17"></td>
										<td GH="80" GCol="input,LOTL18"></td>
										<td GH="80" GCol="input,LOTL19"></td>
										<!-- td GH="80" GCol="input,LOTL20" GF="N 10"></td>
										<td GH="80" GCol="input,OUTDMT" GF="N 10"></td>
										<td GH="80" GCol="input,RIMDMT" GF="N 10"></td>
										<td GH="80" GCol="input,INNDPT" GF="N 10"></td>
										<td GH="80" GCol="input,SECTWD" GF="N 10"></td>
										<td GH="80" GCol="input,WEIGHT" GF="N 10"></td-->
										<td GH="80" GCol="input,DLGORT"></td>
										<td GH="80" GCol="input,BATMNG"></td>
										<td GH="80" GCol="input,LGPRO"></td>
										<td GH="80" GCol="input,CSTDAT"></td>
										<td GH="80" GCol="input,CPSKUG"></td>
										<td GH="80" GCol="input,DESC03"></td>
										<td GH="80" GCol="input,DESC04"></td>
										<!-- td GH="80" GCol="input,QTYMON" GF="N 10"></td>
										<td GH="80" GCol="input,QTYSTD" GF="N 10"></td>
										<td GH="80" GCol="input,QTYCNT" GF="N 10"></td-->
										<td GH="80" GCol="input,BUFMNG"></td>
										<td GH="80" GCol="input,CREDAT"></td>
										<td GH="80" GCol="input,CRETIM"></td>
										<td GH="80" GCol="input,CREUSR"></td>
										<td GH="80" GCol="input,LMODAT"></td>
										<td GH="80" GCol="input,LMOTIM"></td>
										<td GH="80" GCol="input,LMOUSR"></td>
										<td GH="80" GCol="input,INDBZL"></td>
										<td GH="80" GCol="input,INDARC"></td>
										<td GH="80" GCol="input,UPDCHK"></td>
										
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<div class="btn_lit tableUtil">
						<button type='button' GBtn="find"></button>
						<button type="button" GBtn="filter"></button>
						<button type='button' GBtn="sortReset"></button>
						<button type='button' GBtn="add"></button>
						<button type='button' GBtn="copy"></button>
						<button type='button' GBtn="delete"></button>
						<button type='button' GBtn="total"></button>
						<button type="button" GBtn="subTotal"></button>
						<button type='button' GBtn="layout"></button>
						<button type='button' GBtn="excel"></button>
						<button type='button' GBtn="excelUpload"></button>
						<span class='txt_total' >총 건수 : <span GInfoArea='true'>4</span></span>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>