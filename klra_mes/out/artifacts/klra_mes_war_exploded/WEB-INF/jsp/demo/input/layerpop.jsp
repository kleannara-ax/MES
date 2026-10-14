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
			var param = inputList.setRangeParam("searchArea");

			gridList.gridList({
		    	id : "gridList",
		    	param : param
		    });
		}
	}

	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}
	}
	
	function LayerPop() {
		$layerBack.show();
		if($LayerPop == undefined){
			$LayerPop = $("#LayerPop");
		}
		$LayerPop.show();
		$layerBack.show();
	}

	function LayerPopClose() {
		$LayerPop = $("#LayerPop");
		$LayerPop.hide();
		$layerBack.hide();
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
					<button name="LayerPop" type="button" class="button btn_basic basic_layerpop" onclick="LayerPop()">레이어팝업</button>
					<input type="button" CB="Search SEARCH BTN_SEARCH" />
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="Search"></dt>
						<dd>
							<input type="text" class="input" name="Search" UIInput="S,SYSLABEL" IAname="Search" UIFormat="U" validate="required min(10)" required="required"/>
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
							<select name="Combo" class="input" Combo="Demo,COMCODE">
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="SearchCombo"></dt>
						<dd class="multiCombo">
							<select name="SearchCombo" class="input" Combo="Demo,COMCODE" ComboType="SC,50">
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="MultiCombo"></dt>
						<dd class="multiCombo">
							<select name="MultiCombo" class="input" Combo="Demo,COMCODE" ComboType="MC,50">
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="MultiSearchCombo"></dt>
						<dd class="multiCombo">
							<select name="MultiSearchCombo" class="input" Combo="Demo,COMCODE" ComboType="MS,50">
							</select>
						</dd>
					</dl>
					<dl>
						<dt CL="Combo param"></dt>
						<dd>
							<select name="ComboParam" class="input" Combo="Demo,COMCODE,LANGKY">
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
				<ul class="tab tab_style02" >
					<li><a href="#tab1-1"><span>일반</span></a></li>
				</ul>
				<div class="table_box section" id="tab1-1" >
					<div class="table_list01">
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="40" GCol="rowCheck"></td>
										<td GH="80" GCol="text,LABELGID"></td>
										<td GH="150" GCol="text,LABELID"></td>
										<td GH="80" GCol="select,LANGCODE">
											<select class="input" CommonCombo="LANGKY">
											</select>
										</td>
										<td GH="150" GCol="text,LABEL"></td>
										<td GH="80" GCol="text,LABELTYPE"></td>
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
<!-- LayerPop popup -->
<div class="layer_popup" id="LayerPop" style="left:50%;top:50%;width:700px;margin:-250px 0 0 -350px; display: none;"><!-- 팝업 위치는 알아서 변경해주세요 -->
	<div class="tabs content_layout" style="height: 300px;">
		<div id="LayerPop-tab1">
			<div class="table_box section">
				<h1 class="pop-title">LayerPop</h1>
				<div class="inner_search_wrap">
					<table class="detail_table">
						<colgroup>
							<col width="14%" />
							<col width="19%" />
							<col width="14%" />
							<col width="19%" />
							<col width="14%" />
							<col width="19%" />
						</colgroup>
						<tbody>			
							<tr>
								<th CL="Search"></th>
								<td>
									<input type="text" class="input" name="Search" UIInput="S,SHAREMA" IAname="Search" UIFormat="U"/>
								</td>
								<th CL="Calendar"></th>
								<td>
									<input type="text" class="input" name="Calendar" UIFormat="C Y" />
								</td>
								<th CL="SingleRange"></th>
								<td>
									<input type="text" class="input" name="SingleRange" UIInput="SR"/>
								</td>
							</tr>
							<tr>
								<th CL="SingleSearch"></th>
								<td>
									<input type="text" class="input" name="SingleSearch" UIInput="SR,SHAREMA"/>
								</td>
								<th CL="SingleCalendar"></th>
								<td>
									<input type="text" class="input" name="SingleCalendar" UIInput="SR" UIFormat="C N"/>
								</td>
								<th CL="BetweenCalendar"></th>
								<td>
									<input type="text" class="input" name="BetweenCalendar" UIInput="B" UIFormat="C W1"/>
								</td>
							</tr>
							<tr>
								<th CL="RangeNumber"></th>
								<td>
									<input type="text" class="input" name="RangeNumber" UIInput="R" UIFormat="N 20"/>
								</td>
								<th CL="RangeSearch"></th>
								<td>
									<input type="text" class="input" name="RangeSearch" UIInput="R,SHAREMA" UIFormat="U"/>
								</td>
								<th CL="RangeCalendar"></th>
								<td>
									<input type="text" class="input" name="RangeCalendar" UIInput="R" UIFormat="C W1"/>
								</td>
							</tr>
							<tr>
								<th CL="Month"></th>
								<td>
									<input type="text" class="input" name="Month" UIFormat="MS" />
								</td>
								<th CL="Time"></th>
								<td>
									<input type="text" class="input" name="Time" UIFormat="THM" />
								</td>
								<th CL="CommonCombo"></th>
								<td>
									<select name="CommonCombo" class="input" CommonCombo="LANGKY">
									</select>
								</td>
							</tr>
							<tr>
								<th CL="Combo"></th>
								<td>
									<select name="Combo" class="input" Combo="Demo,COMCODE">
									</select>
								</td>
								<th>input</th>
								<td>
									<input type="text" class="input" />
								</td>
								<th>MEMO</th>
								<td>
									<input type="text" class="input" style="width: 100%;"/>
								</td>
							</tr>
							<tr>
								<th>input</th>
								<td>
									<input type="text" class="input" />
								</td>
								<th>MEMO</th>
								<td colspan="3">
									<input type="text" class="input" style="width: 100%;"/>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="btn_wrap">
					<div class="fl_l">
						<!-- input type="button" class="btn_basic" value="add" /-->
						<input type="button" class="btn_gray" value="reset"/>
					</div>
					<div class="fl_r">
						<input type="button" class="btn_basic" value="confirm" />
						<input type="button" class="btn_gray" value="close" onclick="LayerPopClose();"/>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- searchinput popup -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>