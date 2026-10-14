<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grid default</title>
<%@ include file="/common/include/webdek/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			module : "System",
			command : "SYSLABEL"
	    });
	});

	function searchList(){
		if(validate.check("searchArea")){
			//var param = inputList.setRangeParam("searchArea");

			gridList.gridList({
		    	id : "gridList",
		    	param : null
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
					<input type="button" CB="New ADD BTN_NEW" />
					<input type="button" CB="Delete DELETE BTN_DELETE" />
					<input type="button" CB="Reset RESET BTN_RESET" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="Search"></dt>
						<dd>
							<input type="text" class="input" name="Search" UIInput="S,SHAREMA" IAname="Search" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="Calendar"></dt>
						<dd>
							<input type="text" class="input" name="Calendar" UIFormat="C Y" />
						</dd>
					</dl>
					<dl>
						<dt CL="SingleRange"></dt>
						<dd>
							<input type="text" class="input" name="SingleRange" UIInput="SR"/>
						</dd>
					</dl>
					<dl>
						<dt CL="SingleSearch"></dt>
						<dd>
							<input type="text" class="input" name="SingleSearch" UIInput="SR,SHAREMA"/>
						</dd>
					</dl>
					<dl>
						<dt CL="SingleCalendar"></dt>
						<dd>
							<input type="text" class="input" name="SingleCalendar" UIInput="SR" UIFormat="C N"/>
						</dd>
					</dl>
					<dl>
						<dt CL="BetweenCalendar"></dt>
						<dd>
							<input type="text" class="input" name="BetweenCalendar" UIInput="B" UIFormat="C W1"/>
						</dd>
					</dl>
					<dl>
						<dt CL="RangeNumber"></dt>
						<dd>
							<input type="text" class="input" name="RangeNumber" UIInput="R" UIFormat="N 20"/>
						</dd>
					</dl>
					<dl>
						<dt CL="RangeSearch"></dt>
						<dd>
							<input type="text" class="input" name="RangeSearch" UIInput="R,SHAREMA" UIFormat="U"/>
						</dd>
					</dl>
					<dl>
						<dt CL="RangeCalendar"></dt>
						<dd>
							<input type="text" class="input" name="RangeCalendar" UIInput="R" UIFormat="C W1"/>
						</dd>
					</dl>
					<dl>
						<dt CL="Month"></dt>
						<dd>
							<input type="text" class="input" name="Month" UIFormat="MS" />
						</dd>
					</dl>
					<dl>
						<dt CL="Time"></dt>
						<dd>
							<input type="text" class="input" name="Time" UIFormat="THM" />
						</dd>
					</dl>					
					<dl>
						<dt CL="CommonCombo"></dt>
						<dd>
							<select name="CommonCombo" class="input" CommonCombo="LANGKY">
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="Combo"></dt>
						<dd>
							<select name="Combo" class="input" Combo="Common,COMCODE">
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="SearchCombo"></dt>
						<dd class="multiCombo">
							<select name="SearchCombo" class="input" Combo="Common,COMCODE" ComboType="SC,50">
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="MultiCombo"></dt>
						<dd class="multiCombo">
							<select name="MultiCombo" class="input" Combo="Common,COMCODE" ComboType="MC,50">
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="MultiSearchCombo"></dt>
						<dd class="multiCombo">
							<select name="MultiSearchCombo" class="input" Combo="Common,COMCODE" ComboType="MS,50">
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
					<li><a href="#tab1-1"><span>일반</span></a></li>
				</ul>
				<div class="table_box section" id="tab1-1">
					<div class="table_list01">
						<div class="table_thead tableHeader" style="margin-left: 0px;">
							<table>
								<colgroup>
									<col width="40px" />
									<col width="80px" />
									<col width="80px" />
									<col width="80px" />
									<col width="80px" />
									<col width="80px" />
									<col width="100px" />
									<col width="80px" />
									<col width="80px" />
									<col width="80px" />
									<col width="80px" />
									<col width="80px" />
									<col width="80px" />
									<col width="80px" />
									<col width="80px" />
									<col width="80px" />
									<col width="80px" />
									<col width="80px" />
									<col width="80px" />
								</colgroup>
								<thead>
									<tr>
										<th CL='STD_NUMBER' rowspan="3">번호</th>
										<th CL='STD_WAREKY' rowspan="2" colspan="2"></th>
										<!-- th CL='STD_AREAKY'></th-->
										<th CL='STD_ZONEKY' colspan="3"></th>
										<!-- th CL='STD_LOCAKY'></th-->
										<!-- th CL='STD_TKZONE'></th-->
										<th CL='STD_LOCATY' rowspan="3"></th>
										<th CL='STD_STATUS'></th>
										<th CL='STD_INDUPA'></th>
										<th CL='STD_INDUPK' rowspan="3"></th>
										<th CL='STD_INDCPC' rowspan="3"></th>
										<th CL='STD_MAXCPC' rowspan="3"></th>
										<th CL='STD_WIDTHW' rowspan="3"></th>
										<th CL='STD_HEIGHT' rowspan="3"></th>
										<th CL='STD_MIXSKU' rowspan="3"></th>
										<th CL='STD_MIXLOT' rowspan="3"></th>
										<th CL='STD_CREDAT' rowspan="3"></th>
										<th CL='STD_CRETIM' rowspan="3"></th>
										<th CL='STD_CREUSR' rowspan="3"></th>
									</tr>
									<tr>
										<!-- th CL='STD_NUMBER'>번호</th-->
										<!-- th CL='STD_WAREKY'></th>
										<th CL='STD_AREAKY'></th-->
										<th CL='STD_ZONEKY' rowspan="2"></th>
										<th CL='STD_LOCAKY' colspan="2"></th>
										<!-- th CL='STD_TKZONE'--></th>
										<!-- th CL='STD_LOCATY'></th-->
										<th CL='STD_STATUS' rowspan="2" colspan="2"></th>
										<!-- th CL='STD_INDUPA'></th-->
										<!-- th CL='STD_INDUPK'></th>
										<th CL='STD_INDCPC'></th>
										<th CL='STD_MAXCPC'></th>
										<th CL='STD_WIDTHW'></th>
										<th CL='STD_HEIGHT'></th>
										<th CL='STD_MIXSKU'></th>
										<th CL='STD_MIXLOT'></th>
										<th CL='STD_CREDAT'></th>
										<th CL='STD_CRETIM'></th>
										<th CL='STD_CREUSR'></th-->
									</tr>
									<tr>
										<!-- th CL='STD_NUMBER'>번호</th-->
										<th CL='STD_WAREKY'></th>
										<th CL='STD_AREAKY'></th>
										<!-- th CL='STD_ZONEKY'></th-->
										<th CL='STD_LOCAKY'></th>
										<th CL='STD_TKZONE'></th>
										<!-- th CL='STD_LOCATY'></th-->
										<!-- th CL='STD_STATUS'></th>
										<th CL='STD_INDUPA'></th-->
										<!-- th CL='STD_INDUPK'></th>
										<th CL='STD_INDCPC'></th>
										<th CL='STD_MAXCPC'></th>
										<th CL='STD_WIDTHW'></th>
										<th CL='STD_HEIGHT'></th>
										<th CL='STD_MIXSKU'></th>
										<th CL='STD_MIXLOT'></th>
										<th CL='STD_CREDAT'></th>
										<th CL='STD_CRETIM'></th>
										<th CL='STD_CREUSR'></th-->
									</tr>
								</thead>
							</table>
						</div>
						<div class="scroll" style="height: calc(100% - 77px)">
							<table class="table_c">
								<colgroup>
									<col width="40px" />
									<col width="80px" />
									<col width="80px" />
									<col width="80px" />
									<col width="80px" />
									<col width="80px" />
									<col width="100px" />
									<col width="80px" />
									<col width="80px" />
									<col width="80px" />
									<col width="80px" />
									<col width="80px" />
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
										<td GCol="rownum">1</td>
										<td GCol="text,WAREKY"></td>
										<td GCol="text,AREAKY"></td>
										<td GCol="input,ZONEKY,SHZONMA" GF="S 10"></td> 
										<td GCol="input,LOCAKY" validate="required,HHT_T0032" GF="S 20"></td>
										<td GCol="input,TKZONE,SHZONMA" GF="S 10"></td>
										<td GCol="select,LOCATY">
											<select CommonCombo="LOCATY">
											</select>
										</td>
										<td GCol="select,STATUS">
											<select CommonCombo="STATUS">
											</select>
										</td>
										<td GCol="check,INDUPA"></td>
										<td GCol="check,INDUPK"></td>
										<td GCol="check,INDCPC"></td>
										<td GCol="input,MAXCPC" GF="N 20,3"></td>
										<td GCol="input,WIDTHW" GF="N 20,3"></td>
										<td GCol="input,HEIGHT" GF="N 20,3"></td>
										<td GCol="check,MIXSKU"></td>
										<td GCol="check,MIXLOT"></td>
										<td GCol="text,CREDAT"></td>
										<td GCol="text,CRETIM"></td>
										<td GCol="text,CREUSR"></td>
									</tr>									
								</tbody>
							</table>
						</div>
					</div>
					<div class="btn_lit tableUtil">
						<button type='button' GBtn="find"></button>
						<button type='button' GBtn="sortReset"></button>
						<button type='button' GBtn="add"></button>
						<button type='button' GBtn="copy"></button>
						<button type='button' GBtn="delete"></button>
						<button type='button' GBtn="total"></button>
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