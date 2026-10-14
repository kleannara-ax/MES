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
			module : "System",
			command : "MSTGRADE",
			pkcol : "COMPID,GRADEID"
	    });
		
		var date = new Date();
		date.setDate(date.getDate()+2);
		//$('#CTEST').datepicker( "option", "minDate",date);
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
	
	function gridListEventColValueChange(gridId, rowNum, colName, colValue) {
		if(gridId == 'gridList') {
			if(colName == 'COMPID') {
				console.log(gridId);
				var param = gridList.getRowData(gridId, rowNum);
				console.log(param);
		        var json = netUtil.sendData({
		        	module   : "System",
		        	command  : "MSTGRADE",
		        	sendType : "map",
		        	param    : param
		        });
				if(colValue != null && colValue != "") {
			        if(json && json.data){
		        		console.log(json.data);
		        		gridList.setColValue(gridId, rowNum, "COMPNAME", json.data["COMPNAME"]);
			        } else {
			        	alert(colValue + "는 존재하지 않는 회사ID입니다.");
		        		gridList.setColValue(gridId, rowNum, "COMPID", "");
		        		gridList.setColValue(gridId, rowNum, "COMPNAME", "");
			        }
				} else {
	        		gridList.setColValue(gridId, rowNum, "COMPID", "");
	        		gridList.setColValue(gridId, rowNum, "COMPNAME", "");
				}
			} else if(colName == 'GRADEID') {
				console.log(gridId);
				var param = gridList.getRowData(gridId, rowNum);
				console.log(param);
		        var json = netUtil.sendData({
		        	module   : "System",
		        	command  : "MSTGRADE2",
		        	sendType : "map",
		        	param    : param
		        });
		        if(colValue != null && colValue != "") {
			        if(json && json.data){
		        		console.log(json.data);
// 		        		gridList.setColValue(gridId, rowNum, "COMPNAME", json.data["COMPNAME"]);
// 			        } else {
			        	alert(colValue + "는 중복된 값입니다. 다시 입력해주세요.");
		        		gridList.setColValue(gridId, rowNum, "GRADEID", "");
			        }
		        }
			}
		}
	}

	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}else if(btnName == "Reset"){
			Reset();
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
	
	function Reset(){
		$("[name='Search2']").removeAttr("readonly").removeProp("readonly");
		$("[name='Calendar2']").removeAttr("readonly").removeProp("readonly");
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
<!-- 					<button name="LayerPop" type="button" class="button btn_basic basic_layerpop" onclick="LayerPop()">레이어팝업</button> -->
					<input type="button" CB="Search SEARCH BTN_SEARCH" />
					<input type="button" CB="Save SAVE BTN_SAVE" />
<!-- 					<input type="button" CB="New ADD BTN_NEW" /> -->
<!-- 					<input type="button" CB="Delete DELETE BTN_DELETE" /> -->
<!-- 					<input type="button" CB="Reset RESET BTN_RESET" /> -->
				</div>
			</div>
			<div class="search_inner">
				<div class="search_wrap ">
					<dl>
						<dt CL="회사ID"></dt>
						<dd>
							<input type="text" class="input" name="COMPID" UIInput="S,COMPID" IAname="Search" UIFormat="U" />
						</dd>
					</dl>
					<dl>
						<dt CL="직위ID"></dt>
						<dd>
							<input type="text" class="input" name="GRADEID" UIInput="S,GRADEID" IAname="Search" UIFormat="U" />
						</dd>
					</dl>
					<dl>
						<dt CL="DELYN"></dt>
						<dd>
							<select name="DELYN" class="input" CommonCombo="DELYN">
								<option></option>
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
						<div class="scroll">
							<table class="table_c">
								<tbody id="gridList">
									<tr CGRow="true">
										<td GH="40" GCol="rownum">1</td>
										<td GH="40" GCol="rowCheck"></td>
<!-- 										<td GH="80" GCol="text,GUUID"></td> -->
<!-- 										<td GH="250 STD_ATTACH"   GCol="file,ATTACH"/></td> -->
<!-- 										<td GH="250 STD_FILEDOWN" GCol="fileDownload,UUID"/></td> -->
<!-- 										<td GH="100 STD_FILESIZE" GCol="fileSize,BYTE"/></td>             -->
										<td GH="80" GCol="input,COMPID" validate="required"></td>          
										<td GH="80" GCol="text,COMPNAME"></td>          
										<td GH="80" GCol="input,GRADEID" validate="required"></td>         
										<td GH="100" GCol="input,GRADELABEL"></td>         
										<td GH="80" GCol="input,GRADENAME"></td>          
										<td GH="80" GCol="input,SORTORDER" GF="N"></td>            
										<td GH="80" GCol="input,CREATEUSER"></td>        
										<td GH="100" GCol="input,CREATEDATE" GF="C"></td>
										<td GH="80" GCol="input,UPDATEUSER"></td>        
										<td GH="100" GCol="input,UPDATEDATE" GF="C"></td>
										<td GH="100" GCol="select,DELETEYN">             
											<select class="input" CommonCombo="DELYN">   
											</select>                                    
										</td>
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
<!-- <!-- LayerPop popup -->
<!-- <div class="layer_popup" id="LayerPop" style="left:50%;top:50%;width:700px;margin:-250px 0 0 -350px; display: none;">팝업 위치는 알아서 변경해주세요 -->
<!-- 	<div class="tabs content_layout" style="height: 300px;"> -->
<!-- 		<div id="LayerPop-tab1"> -->
<!-- 			<div class="table_box section"> -->
<!-- 				<h1 class="pop-title">LayerPop</h1> -->
<!-- 				<div class="inner_search_wrap"> -->
<!-- 					<table class="detail_table"> -->
<!-- 						<colgroup> -->
<!-- 							<col width="14%" /> -->
<!-- 							<col width="19%" /> -->
<!-- 							<col width="14%" /> -->
<!-- 							<col width="19%" /> -->
<!-- 							<col width="14%" /> -->
<!-- 							<col width="19%" /> -->
<!-- 						</colgroup> -->
<!-- 						<tbody>			 -->
<!-- 							<tr> -->
<!-- 								<th CL="Search"></th> -->
<!-- 								<td> -->
<!-- 									<input type="text" class="input" name="Search" UIInput="S,SHAREMA" IAname="Search" UIFormat="U"/> -->
<!-- 								</td> -->
<!-- 								<th CL="Calendar"></th> -->
<!-- 								<td> -->
<!-- 									<input type="text" class="input" name="Calendar" UIFormat="C Y" /> -->
<!-- 								</td> -->
<!-- 								<th CL="SingleRange"></th> -->
<!-- 								<td> -->
<!-- 									<input type="text" class="input" name="SingleRange" UIInput="SR"/> -->
<!-- 								</td> -->
<!-- 							</tr> -->
<!-- 							<tr> -->
<!-- 								<th CL="SingleSearch"></th> -->
<!-- 								<td> -->
<!-- 									<input type="text" class="input" name="SingleSearch" UIInput="SR,SHAREMA"/> -->
<!-- 								</td> -->
<!-- 								<th CL="SingleCalendar"></th> -->
<!-- 								<td> -->
<!-- 									<input type="text" class="input" name="SingleCalendar" UIInput="SR" UIFormat="C N"/> -->
<!-- 								</td> -->
<!-- 								<th CL="BetweenCalendar"></th> -->
<!-- 								<td> -->
<!-- 									<input type="text" class="input" name="BetweenCalendar" UIInput="B" UIFormat="C W1"/> -->
<!-- 								</td> -->
<!-- 							</tr> -->
<!-- 							<tr> -->
<!-- 								<th CL="RangeNumber"></th> -->
<!-- 								<td> -->
<!-- 									<input type="text" class="input" name="RangeNumber" UIInput="R" UIFormat="N 20"/> -->
<!-- 								</td> -->
<!-- 								<th CL="RangeSearch"></th> -->
<!-- 								<td> -->
<!-- 									<input type="text" class="input" name="RangeSearch" UIInput="R,SHAREMA" UIFormat="U"/> -->
<!-- 								</td> -->
<!-- 								<th CL="RangeCalendar"></th> -->
<!-- 								<td> -->
<!-- 									<input type="text" class="input" name="RangeCalendar" UIInput="R" UIFormat="C W1"/> -->
<!-- 								</td> -->
<!-- 							</tr> -->
<!-- 							<tr> -->
<!-- 								<th CL="Month"></th> -->
<!-- 								<td> -->
<!-- 									<input type="text" class="input" name="Month" UIFormat="MS" /> -->
<!-- 								</td> -->
<!-- 								<th CL="Time"></th> -->
<!-- 								<td> -->
<!-- 									<input type="text" class="input" name="Time" UIFormat="THM" /> -->
<!-- 								</td> -->
<!-- 								<th CL="CommonCombo"></th> -->
<!-- 								<td> -->
<!-- 									<select name="CommonCombo" class="input" CommonCombo="LANGKY"> -->
<!-- 									</select> -->
<!-- 								</td> -->
<!-- 							</tr> -->
<!-- 							<tr> -->
<!-- 								<th CL="Combo"></th> -->
<!-- 								<td> -->
<!-- 									<select name="Combo" class="input" Combo="Demo,COMCODE"> -->
<!-- 									</select> -->
<!-- 								</td> -->
<!-- 								<th>input</th> -->
<!-- 								<td> -->
<!-- 									<input type="text" class="input" /> -->
<!-- 								</td> -->
<!-- 								<th>MEMO</th> -->
<!-- 								<td> -->
<!-- 									<input type="text" class="input" style="width: 100%;"/> -->
<!-- 								</td> -->
<!-- 							</tr> -->
<!-- 							<tr> -->
<!-- 								<th>input</th> -->
<!-- 								<td> -->
<!-- 									<input type="text" class="input" /> -->
<!-- 								</td> -->
<!-- 								<th>MEMO</th> -->
<!-- 								<td colspan="3"> -->
<!-- 									<input type="text" class="input" style="width: 100%;"/> -->
<!-- 								</td> -->
<!-- 							</tr> -->
<!-- 						</tbody> -->
<!-- 					</table> -->
<!-- 				</div> -->
<!-- 				<div class="btn_wrap"> -->
<!-- 					<div class="fl_l"> -->
<!-- 						input type="button" class="btn_basic" value="add" / -->
<!-- 						<input type="button" class="btn_gray" value="reset"/> -->
<!-- 					</div> -->
<!-- 					<div class="fl_r"> -->
<!-- 						<input type="button" class="btn_basic" value="confirm" /> -->
<!-- 						<input type="button" class="btn_gray" value="close" onclick="LayerPopClose();"/> -->
<!-- 					</div> -->
<!-- 				</div> -->
<!-- 			</div> -->
<!-- 		</div> -->
<!-- 	</div> -->
<!-- </div> -->
<!-- searchinput popup -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>