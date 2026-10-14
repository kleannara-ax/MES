<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Input default</title>
<%@ include file="/common/include/head.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		/*
		var date1 = uiList.getDateObj("19730325");
		var date2 = uiList.getDateObj("19730425");
		var day = (date2 - date1)/1000/60/60/24; 
		alert(day);
		*/

		//$('.monthpicker').monthpicker({changeYear:true, minDate: "-10 Y", maxDate: "+10 Y",monthNamesShort: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'] });
		/*
		//$("#dialog").dialog();
		$("#dialog").dialog({
//		 	    autoOpen:false, //자동으로 열리지않게
//		 	    position:[100,200], //x,y  값을 지정
			    //"center", "left", "right", "top", "bottom"
			    modal: true, //모달대화상자
			    resizable:false, //크기 조절 못하게
			    draggable:false
			    
//		 	    buttons:{
//		 	        "save":function(){
//		 	            $(this).dialog("close");
//		 	        },"reset":function(){
//		 	            $(this).dialog("close");
//		 	        }
//		 	    }
		});
		
		//창 열기 버튼을 클릭했을경우
		$(".dialog").on("click",function(){
			$("#dialog").dialog("open"); //다이얼로그창 오픈   
			$(".ui-widget-overlay").css({zIndex:999}); // 마스크레이어 css
			
			$(".ui-dialog").css({ // 모달팝업 css
				zIndex:1000,
				width:"430px",
				top:"50%",
				left:"50%",
				transform:"translate(-50%,-50%)"
				});
		});
		

		$("#dialog .tableUtil .leftArea button").on("click",function(){
		    $("#dialog").dialog("close"); //다이얼로그창 닫기     
		});
		*/
	});
	
	function searchList(){
		var param = inputList.setRangeDataParam("searchArea");
		
		alert(param.toString());
		/*
		if(validate.check("searchArea")){
			var sqlName = $("#searchArea").find("[name=COLNAME]").val();
			inputList.setRangeSqlName("NAME01", sqlName);
			var param = inputList.setRangeDataParam("searchArea");
			
			alert(param.toString());
			
			inputList.copyRangeParam(param, "CREDAT1", "CREDAT1_COPY");
			
			alert(param.toString());
			
			var json = netUtil.sendData({
				url : "/demo/input/json/default.data",
				param : param
			});
			
			if(json && json.data){
				alert(json.data);
			}
		}
		*/
	}

	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Test"){
			test();
		}else if(btnName == "Test1"){
			test(true);
		}else if(btnName == "Test2"){
			test(false);
		}
	}
	
	function test(type){
		//inputList.setRangeReadOnly("NAME01", type);
		var $mCombo = $("[name=MULTICOMBO]");
		//inputList.setMultiComboSelectAll($mCombo, false);
		//inputList.setMultiComboValue($mCombo, ["RCV","SHP"]);
		//inputList.addMultiComboValue($mCombo, ["RCV","SHP"]);
		//inputList.removeMultiComboValue($mCombo, ["RCV","SHP"]);
		//inputList.resetMultiComboValue($mCombo);
		var param = inputList.setRangeDataParam("searchArea");
		
		alert(param.toString());
	}
	
	function test1(){
		var param =new DataMap();
		param.put("CREDAT", "20121212");
		dataBind.dataNameBind(param, "searchArea");
	}
	
	function uiListCreateCalenderEvent($input){
		if($input.attr("name") == "CREDAT"){
			$input.datepicker("option", "maxDate", '+0d +0m +0w' );
		}
	}
	
	function inputListEventRangeDataChange(rangeName, singleData, rangeData){
		//commonUtil.debugMsg("inputListEventRangeDataChange : ", arguments);
	}
	
	function addData(obj){
		var values = obj.value;
		values = values.split(",");
		$ms.multipleSelect("setSelects", values);
		//alert($ms.multipleSelect('getSelects'));
		//$ms.find("option").eq(0).hide();
		//$ms.multipleSelect('refresh');
	}
	
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY"></button>
		<button CB="Test1 SEARCH BTN_TEST1"></button>
		<button CB="Test2 SEARCH BTN_TEST2"></button>
	</div>
	<div class="util3">
		<button class="button type2" id="showPop" type="button"><img src="/common/images/ico_btn4.png" alt="List" /></button>
	</div>
</div>

<!-- searchPop -->
<div class="searchPop" id="searchArea">
	<button type="button" class="closer">X</button>
	<div class="searchInnerContainer">
		<p class="util">
			<button CB="Search SEARCH BTN_DISPLAY"></button>
			<button CB="Test SEARCH BTN_TEST"></button>
			<button CB="GetVariant GETVARIANT BTN_GETVARIANT"></button>
			<button CB="SaveVariant SAVEVARIANT BTN_SAVEVARIANT"></button>
		</p>
		<div class="searchInBox">
			<h2 class="tit" CL="STD_SELECTOPTIONS"></h2>
			<table class="table type1">
				<colgroup>
					<col width="100" />
					<col />
				</colgroup>
				<tbody>
					<tr>
						<th>Phone</th>
						<td>
							<input class="dialog"  type="text"/>
						</td>
					</tr>
					<tr>
						<th>Search help</th>
						<td>
							<input type="text" name="WAREKY" UIInput="S,SHAREMA" IAname="WAREKY" UISave="false" UIFormat="U" validate="required number"/>
						</td>
					</tr>
					<tr>
						<th>Calender</th>
						<td>
							<input type="text" name="CREDAT" UIFormat="C Y" readonly="readonly"/>
						</td>
					</tr>
					<tr>
						<th>Calender(DM)</th>
						<td>
							<input type="text" name="CREDATDM" UIFormat="DM" validate="required"/>
						</td>
					</tr>
					<tr>
						<th>Calender(CM)</th>
						<td>
							<input type="text" name="CREDATCM" UIFormat="CM" validate="required"/>
						</td>
					</tr>
					<tr>
						<th>Calender(Month)</th>
						<td>
							<input type="text" name="MONTHSELECT" UIFormat="MS">
						</td>
					</tr>
					<tr>
						<th>timepicker</th>
						<td>
							<input type="text" name="TIMESELECT" UIFormat="THM">
						</td>
					</tr>
					<tr>
						<th>Number String</th>
						<td>
							<input type="text" name="CREDATN1" UIFormat="NS 5" value="111111111"/>
						</td>
					</tr>
					<tr>
						<th>Number</th>
						<td>
							<input type="text" name="CREDATN" UIFormat="N 5" value="111111111"/>
						</td>
					</tr>
					<tr>
						<th>Number2</th>
						<td>
							<input type="text" name="CREDATN2" UIFormat="N 7,2" value="111111111"/>
						</td>
					</tr>
					<tr>
						<th>Common combo</th>
						<td>
							<select name="LOCATY" CommonCombo="LOCATY" class="normalInput">
							</select>
						</td>
					</tr>
					<tr>
						<th>Reason combo</th>
						<td>
							<select ReasonCombo="450" name="REASON" class="normalInput">
							</select>
						</td>
					</tr>
					<tr>
						<th>Combo</th>
						<td>
							<select name="AREAKY" Combo="WmsAdmin,AREAKYCOMBO" class="normalInput">
								<option value="">선택</option>
							</select>
						</td>
					</tr>
					<tr>
						<th>Search combo</th>
						<td>
							<select name="SEARCHCOMBO" Combo="WmsAdmin,AREAKYCOMBO" ComboType="SC,50">
						    </select>
						</td>
					</tr>
					<tr>
						<th>Multiple combo</th>
						<td>
							<select name="MULTICOMBO" Combo="WmsAdmin,AREAKYCOMBO" ComboType="MC,50">
						    </select>
						</td>
					</tr>
					<tr>
						<th>Multiple search combo</th>
						<td>
							<select name="MULTISEARCHCOMBO" Combo="WmsAdmin,AREAKYCOMBO" ComboType="MS,50">
						    </select>
						</td>
					</tr>
					<tr>
						<th>Range</th>
						<td>
							<input type="text" name="NAME01" UIInput="SR" UISave="false" UIFormat="U" readonly="readonly" value="1" validate="required"/>
						</td>
					</tr>
					<tr>
						<th>Dialog</th>
						<td>
							<input class="dialog"  type="text"/>
						</td>
					</tr>
					<tr>
						<th>Range(Search Help)</th>
						<td>
							<input type="text" name="NAME02" UIInput="SR,SHAREMA" UIFormat="U" validate="required"/>
						</td>
					</tr>
					<tr>
						<th>Range(Date M1)</th>
						<td>
							<input  class="dialog"  type="text" />
						</td>
					</tr>
					<tr>
						<th>Range(Date M2)</th>
						<td>
							<input type="text" name="CREDAT12" UIInput="SR" UIFormat="C M2" validate="required"/>
						</td>
					</tr>
					<tr>
						<th>Range(Date M3)</th>
						<td>
							<input type="text" name="CREDAT13" UIInput="SR" UIFormat="C M3" validate="required"/>
						</td>
					</tr>
					<tr>
						<th>Range(Date W1)</th>
						<td>
							<input type="text" name="CREDAT1W" UIInput="R" UIFormat="C W1" validate="required"/>
						</td>
					</tr>
					<tr>
						<th>Range(Date Y)</th>
						<td>
							<input type="text" name="CREDAT2" UIInput="R" UIFormat="C Y"/>
						</td>
					</tr>
					<tr>
						<th>Range(Date -3)</th>
						<td>
							<input type="text" name="CREDAT3" UIInput="R" UIFormat="C -3"/>
						</td>
					</tr>
					<tr>
						<th>Range(Date 3)</th>
						<td>
							<input type="text" name="CREDAT4" UIInput="R" UIFormat="C 3"/>
						</td>
					</tr>
					<tr>
						<th>Range(Date -3 3)</th>
						<td>
							<input type="text" name="CREDAT33" UIInput="R" UIFormat="C -3 3"/>
						</td>
					</tr>
					<tr>
						<th>Range(DM)</th>
						<td>
							<input type="text" name="CREDAT5" UIInput="R" UIFormat="DM"/>
						</td>
					</tr>
					<tr>
						<th>Range(CM)</th>
						<td>
							<input type="text" name="CREDAT6" UIInput="R" UIFormat="CM"/>
						</td>
					</tr>
					<tr>
						<th>Range(Number)</th>
						<td>
							<input type="text" name="AGE" UIInput="R" UIFormat="N 10" validate="required"/>
						</td>
					</tr>
					<tr>
						<th>Range(Time)</th>
						<td>
							<input type="text" name="CRETM" UIInput="R" UIFormat="T"/>
						</td>
					</tr>
					<tr>
						<th>Between(Date 3)</th>
						<td>
							<input type="text" name="CREDAT5" UIInput="B" UIFormat="C 3"/>
						</td>
					</tr>
					<tr>
						<th>Between(Search Help)</th>
						<td>
							<input type="text" name="NAME03" UIInput="B,SHAREMA" UIFormat="U"/>
						</td>
					</tr>
					<tr>
						<th>Between(Number)</th>
						<td>
							<input type="text" name="AGE" UIInput="B" UIFormat="N 10"/>
						</td>
					</tr>
					<!-- tr>
						<th>Multi(Common)</th>
						<td>
							<select name="LOCATYM" CommonCombo="LOCATY" UIInput="M">
								<option value="">---</option>
							</select>
						</td>
					</tr>
					<tr>
						<th>Search(Common)</th>
						<td>
							<select name="LOCATYS" CommonCombo="LOCATY" UIInput="C">
								<option value="">---</option>
							</select>
						</td>
					</tr-->
				</tbody>
			</table>
		</div>
	</div>
</div>
<!-- //searchPop -->
<!-- content -->
<div class="content">
	<div class="innerContainer">
		<!-- contentContainer -->
		<div class="contentContainer">
			<div class="bottomSect type1">
				<div class="tabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span CL='STD_SEARCH'>탭메뉴1</span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
											<col width="40" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="100" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<th CL='STD_WAREKY'></th>
												<th CL='STD_AREAKY'></th>
												<th CL='STD_ZONEKY'></th>
												<th CL='STD_LOCAKY'></th>
												<th CL='STD_TKZONE'></th>
												<th CL='STD_LOCATY'></th>
												<th CL='STD_STATUS'></th>
												<th CL='STD_INDUPA'></th>
												<th CL='STD_INDUPK'></th>
												<th CL='STD_INDCPC'></th>
												<th CL='STD_MAXCPC'></th>
												<th CL='STD_WIDTHW'></th>
												<th CL='STD_HEIGHT'></th>
												<th CL='STD_MIXSKU'></th>
												<th CL='STD_MIXLOT'></th>
												<th CL='STD_CREDAT'></th>
												<th CL='STD_CRETIM'></th>
												<th CL='STD_CREUSR'></th>
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="40" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="100" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
											<col width="80" />
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
							<div class="tableUtil">
								<div class="leftArea">
									<button type="button" GBtn="find"></button>
									<button type="button" GBtn="sortReset"></button>
									<button type="button" GBtn="add"></button>
									<button type="button" GBtn="copy"></button>
									<button type="button" GBtn="delete"></button>
									<button type="button" GBtn="layout"></button>
									<button type="button" GBtn="total"></button>
									<button type="button" GBtn="excel"></button>
								</div>
								<div class="rightArea">
									<p class="record" GInfoArea="true">0 Record</p>
								</div>
							</div>
						</div>
					</div>					
				</div>
			</div>
		</div>
		<!-- //contentContainer -->
	</div>
</div>
<!-- //content -->
<%@ include file="/common/include/bottom.jsp" %>
	<div id="dialog">
		<div class="tabs ui-tabs ui-widget ui-widget-content ui-corner-all" id="rangePopupTabs">
			<ul class="selection ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all" role="tablist">
				<li class="ui-state-default ui-corner-top" role="tab" tabindex="-1" aria-controls="tab1" aria-labelledby="ui-id-2" aria-selected="false" aria-expanded="false"><a href="#tab1" cl="BOTTOM_SINGLEVAL" class="ui-tabs-anchor" role="presentation" tabindex="-1" id="ui-id-2">단건조회</a></li>
				<li class="ui-state-default ui-corner-top ui-tabs-active ui-state-active" role="tab" tabindex="0" aria-controls="tab2" aria-labelledby="ui-id-3" aria-selected="true" aria-expanded="true"><a href="#tab2" cl="BOTTOM_RANGES" class="ui-tabs-anchor" role="presentation" tabindex="-1" id="ui-id-3">범위조회</a></li>
			</ul>
			<div id="tab1" aria-labelledby="ui-id-2" class="ui-tabs-panel ui-widget-content ui-corner-bottom" role="tabpanel" aria-hidden="true" style="display: none;">
				<div class="table type2 section">
					<div class="tableHeader tbl_space tbl_small" style="margin-left: 0px;">
						<table>
							<colgroup>
								<col width="40px" gcolname="rownum">
								<col width="50px" gcolname="LOGICAL">
								<col width="40px" gcolname="OPER">
								<col width="258px" gcolname="DATA">
							</colgroup>
							<thead>
								<tr>
									<th cl="BOTTOM_NUM" gcolname="rownum" gcolvalue="번호">번호</th>
									<th cl="BOTTOM_LOGICAL" gcolname="LOGICAL" gcolvalue="BOTTOM_LOGICAL"><table class="thInTable" style="width:100%;" title="BOTTOM_LOGICAL"><tbody><tr><td style="width:10px;"></td><td gcolname="LOGICAL">BOTTOM_LOGICAL</td><td style="width: 3px; position: relative;" class="GLHeadColRight ui-draggable ui-draggable-handle" gcolname="LOGICAL"></td></tr></tbody></table></th>
									<th cl="BOTTOM_OPER" gcolname="OPER" gcolvalue="수식"><table class="thInTable" style="width:100%;" title="수식"><tbody><tr><td style="width:10px;"></td><td gcolname="OPER">수식</td><td style="width: 3px; position: relative;" class="GLHeadColRight ui-draggable ui-draggable-handle" gcolname="OPER"></td></tr></tbody></table></th>
									<th cl="BOTTOM_SINGLE" gcolname="DATA" gcolvalue="조건"><table class="thInTable" style="width:100%;" title="조건"><tbody><tr><td style="width:10px;"></td><td gcolname="DATA">조건</td><td style="width: 3px; position: relative;" class="GLHeadColRight ui-draggable ui-draggable-handle" gcolname="DATA"></td></tr></tbody></table></th>
								</tr>
							</thead>
						</table>
					</div>
					<div class="tableBody tbl_small">
						<table style="padding-bottom: 0px; padding-top: 0px;">
							<colgroup>
								<col width="40px" gcolname="rownum" class="gridColObject">
								<col width="50px" gcolname="LOGICAL">
								<col width="40px" gcolname="OPER">
								<col width="242px" gcolname="DATA">
							</colgroup>
							<tbody id="rangeSingleList" gbox="true" class="ui-selectable">
														
							<tr cgrow="true" grownum="0" class="grsl_ grfo_ focusRow" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">1</td>
									<td gcol="select,LOGICAL" class="ico gcmo_LOGICAL gcrc_LOGICAL editable" gcoltype="select" gcolname="LOGICAL">
										<select value="OR" gcdo_logical_a="" style="width: 100%; height: 100%;">
											<option value="OR" selected="selected" gcop_logicalor_a="">OR</option>
											<option value="AND" gcop_logicaland_a="">AND</option>
										</select>
									</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
											<option value="LT" gcop_operlt_a="">＜</option>
											<option value="GT" gcop_opergt_a="">＞</option>
											<option value="LE" gcop_operle_a="">≤</option>
											<option value="GE" gcop_operge_a="">≥</option>
										</select>
									</td>
									<td gcol="input,DATA" gcoltype="input" gcolname="DATA" class="gcmo_DATA gcrc_DATA gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="1" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">2</td>
									<td gcol="select,LOGICAL" class="ico gcmo_LOGICAL gcrc_LOGICAL editable" gcoltype="select" gcolname="LOGICAL">
										<select value="OR" gcdo_logical_a="" style="width: 100%; height: 100%;">
											<option value="OR" selected="selected" gcop_logicalor_a="">OR</option>
											<option value="AND" gcop_logicaland_a="">AND</option>
										</select>
									</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
											<option value="LT" gcop_operlt_a="">＜</option>
											<option value="GT" gcop_opergt_a="">＞</option>
											<option value="LE" gcop_operle_a="">≤</option>
											<option value="GE" gcop_operge_a="">≥</option>
										</select>
									</td>
									<td gcol="input,DATA" gcoltype="input" gcolname="DATA" class="gcmo_DATA gcrc_DATA gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="2" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">3</td>
									<td gcol="select,LOGICAL" class="ico gcmo_LOGICAL gcrc_LOGICAL editable" gcoltype="select" gcolname="LOGICAL">
										<select value="OR" gcdo_logical_a="" style="width: 100%; height: 100%;">
											<option value="OR" selected="selected" gcop_logicalor_a="">OR</option>
											<option value="AND" gcop_logicaland_a="">AND</option>
										</select>
									</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
											<option value="LT" gcop_operlt_a="">＜</option>
											<option value="GT" gcop_opergt_a="">＞</option>
											<option value="LE" gcop_operle_a="">≤</option>
											<option value="GE" gcop_operge_a="">≥</option>
										</select>
									</td>
									<td gcol="input,DATA" gcoltype="input" gcolname="DATA" class="gcmo_DATA gcrc_DATA gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="3" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">4</td>
									<td gcol="select,LOGICAL" class="ico gcmo_LOGICAL gcrc_LOGICAL editable" gcoltype="select" gcolname="LOGICAL">
										<select value="OR" gcdo_logical_a="" style="width: 100%; height: 100%;">
											<option value="OR" selected="selected" gcop_logicalor_a="">OR</option>
											<option value="AND" gcop_logicaland_a="">AND</option>
										</select>
									</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
											<option value="LT" gcop_operlt_a="">＜</option>
											<option value="GT" gcop_opergt_a="">＞</option>
											<option value="LE" gcop_operle_a="">≤</option>
											<option value="GE" gcop_operge_a="">≥</option>
										</select>
									</td>
									<td gcol="input,DATA" gcoltype="input" gcolname="DATA" class="gcmo_DATA gcrc_DATA gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="4" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">5</td>
									<td gcol="select,LOGICAL" class="ico gcmo_LOGICAL gcrc_LOGICAL editable" gcoltype="select" gcolname="LOGICAL">
										<select value="OR" gcdo_logical_a="" style="width: 100%; height: 100%;">
											<option value="OR" selected="selected" gcop_logicalor_a="">OR</option>
											<option value="AND" gcop_logicaland_a="">AND</option>
										</select>
									</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
											<option value="LT" gcop_operlt_a="">＜</option>
											<option value="GT" gcop_opergt_a="">＞</option>
											<option value="LE" gcop_operle_a="">≤</option>
											<option value="GE" gcop_operge_a="">≥</option>
										</select>
									</td>
									<td gcol="input,DATA" gcoltype="input" gcolname="DATA" class="gcmo_DATA gcrc_DATA gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="5" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">6</td>
									<td gcol="select,LOGICAL" class="ico gcmo_LOGICAL gcrc_LOGICAL editable" gcoltype="select" gcolname="LOGICAL">
										<select value="OR" gcdo_logical_a="" style="width: 100%; height: 100%;">
											<option value="OR" selected="selected" gcop_logicalor_a="">OR</option>
											<option value="AND" gcop_logicaland_a="">AND</option>
										</select>
									</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
											<option value="LT" gcop_operlt_a="">＜</option>
											<option value="GT" gcop_opergt_a="">＞</option>
											<option value="LE" gcop_operle_a="">≤</option>
											<option value="GE" gcop_operge_a="">≥</option>
										</select>
									</td>
									<td gcol="input,DATA" gcoltype="input" gcolname="DATA" class="gcmo_DATA gcrc_DATA gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="6" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">7</td>
									<td gcol="select,LOGICAL" class="ico gcmo_LOGICAL gcrc_LOGICAL editable" gcoltype="select" gcolname="LOGICAL">
										<select value="OR" gcdo_logical_a="" style="width: 100%; height: 100%;">
											<option value="OR" selected="selected" gcop_logicalor_a="">OR</option>
											<option value="AND" gcop_logicaland_a="">AND</option>
										</select>
									</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
											<option value="LT" gcop_operlt_a="">＜</option>
											<option value="GT" gcop_opergt_a="">＞</option>
											<option value="LE" gcop_operle_a="">≤</option>
											<option value="GE" gcop_operge_a="">≥</option>
										</select>
									</td>
									<td gcol="input,DATA" gcoltype="input" gcolname="DATA" class="gcmo_DATA gcrc_DATA gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="7" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">8</td>
									<td gcol="select,LOGICAL" class="ico gcmo_LOGICAL gcrc_LOGICAL editable" gcoltype="select" gcolname="LOGICAL">
										<select value="OR" gcdo_logical_a="" style="width: 100%; height: 100%;">
											<option value="OR" selected="selected" gcop_logicalor_a="">OR</option>
											<option value="AND" gcop_logicaland_a="">AND</option>
										</select>
									</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
											<option value="LT" gcop_operlt_a="">＜</option>
											<option value="GT" gcop_opergt_a="">＞</option>
											<option value="LE" gcop_operle_a="">≤</option>
											<option value="GE" gcop_operge_a="">≥</option>
										</select>
									</td>
									<td gcol="input,DATA" gcoltype="input" gcolname="DATA" class="gcmo_DATA gcrc_DATA gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="8" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">9</td>
									<td gcol="select,LOGICAL" class="ico gcmo_LOGICAL gcrc_LOGICAL editable" gcoltype="select" gcolname="LOGICAL">
										<select value="OR" gcdo_logical_a="" style="width: 100%; height: 100%;">
											<option value="OR" selected="selected" gcop_logicalor_a="">OR</option>
											<option value="AND" gcop_logicaland_a="">AND</option>
										</select>
									</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
											<option value="LT" gcop_operlt_a="">＜</option>
											<option value="GT" gcop_opergt_a="">＞</option>
											<option value="LE" gcop_operle_a="">≤</option>
											<option value="GE" gcop_operge_a="">≥</option>
										</select>
									</td>
									<td gcol="input,DATA" gcoltype="input" gcolname="DATA" class="gcmo_DATA gcrc_DATA gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="9" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">10</td>
									<td gcol="select,LOGICAL" class="ico gcmo_LOGICAL gcrc_LOGICAL editable" gcoltype="select" gcolname="LOGICAL">
										<select value="OR" gcdo_logical_a="" style="width: 100%; height: 100%;">
											<option value="OR" selected="selected" gcop_logicalor_a="">OR</option>
											<option value="AND" gcop_logicaland_a="">AND</option>
										</select>
									</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
											<option value="LT" gcop_operlt_a="">＜</option>
											<option value="GT" gcop_opergt_a="">＞</option>
											<option value="LE" gcop_operle_a="">≤</option>
											<option value="GE" gcop_operge_a="">≥</option>
										</select>
									</td>
									<td gcol="input,DATA" gcoltype="input" gcolname="DATA" class="gcmo_DATA gcrc_DATA gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="10" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">11</td>
									<td gcol="select,LOGICAL" class="ico gcmo_LOGICAL gcrc_LOGICAL editable" gcoltype="select" gcolname="LOGICAL">
										<select value="OR" gcdo_logical_a="" style="width: 100%; height: 100%;">
											<option value="OR" selected="selected" gcop_logicalor_a="">OR</option>
											<option value="AND" gcop_logicaland_a="">AND</option>
										</select>
									</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
											<option value="LT" gcop_operlt_a="">＜</option>
											<option value="GT" gcop_opergt_a="">＞</option>
											<option value="LE" gcop_operle_a="">≤</option>
											<option value="GE" gcop_operge_a="">≥</option>
										</select>
									</td>
									<td gcol="input,DATA" gcoltype="input" gcolname="DATA" class="gcmo_DATA gcrc_DATA gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="11" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">12</td>
									<td gcol="select,LOGICAL" class="ico gcmo_LOGICAL gcrc_LOGICAL editable" gcoltype="select" gcolname="LOGICAL">
										<select value="OR" gcdo_logical_a="" style="width: 100%; height: 100%;">
											<option value="OR" selected="selected" gcop_logicalor_a="">OR</option>
											<option value="AND" gcop_logicaland_a="">AND</option>
										</select>
									</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
											<option value="LT" gcop_operlt_a="">＜</option>
											<option value="GT" gcop_opergt_a="">＞</option>
											<option value="LE" gcop_operle_a="">≤</option>
											<option value="GE" gcop_operge_a="">≥</option>
										</select>
									</td>
									<td gcol="input,DATA" gcoltype="input" gcolname="DATA" class="gcmo_DATA gcrc_DATA gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="12" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">13</td>
									<td gcol="select,LOGICAL" class="ico gcmo_LOGICAL gcrc_LOGICAL editable" gcoltype="select" gcolname="LOGICAL">
										<select value="OR" gcdo_logical_a="" style="width: 100%; height: 100%;">
											<option value="OR" selected="selected" gcop_logicalor_a="">OR</option>
											<option value="AND" gcop_logicaland_a="">AND</option>
										</select>
									</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
											<option value="LT" gcop_operlt_a="">＜</option>
											<option value="GT" gcop_opergt_a="">＞</option>
											<option value="LE" gcop_operle_a="">≤</option>
											<option value="GE" gcop_operge_a="">≥</option>
										</select>
									</td>
									<td gcol="input,DATA" gcoltype="input" gcolname="DATA" class="gcmo_DATA gcrc_DATA gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="13" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">14</td>
									<td gcol="select,LOGICAL" class="ico gcmo_LOGICAL gcrc_LOGICAL editable" gcoltype="select" gcolname="LOGICAL">
										<select value="OR" gcdo_logical_a="" style="width: 100%; height: 100%;">
											<option value="OR" selected="selected" gcop_logicalor_a="">OR</option>
											<option value="AND" gcop_logicaland_a="">AND</option>
										</select>
									</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
											<option value="LT" gcop_operlt_a="">＜</option>
											<option value="GT" gcop_opergt_a="">＞</option>
											<option value="LE" gcop_operle_a="">≤</option>
											<option value="GE" gcop_operge_a="">≥</option>
										</select>
									</td>
									<td gcol="input,DATA" gcoltype="input" gcolname="DATA" class="gcmo_DATA gcrc_DATA gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="14" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">15</td>
									<td gcol="select,LOGICAL" class="ico gcmo_LOGICAL gcrc_LOGICAL editable" gcoltype="select" gcolname="LOGICAL">
										<select value="OR" gcdo_logical_a="" style="width: 100%; height: 100%;">
											<option value="OR" selected="selected" gcop_logicalor_a="">OR</option>
											<option value="AND" gcop_logicaland_a="">AND</option>
										</select>
									</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
											<option value="LT" gcop_operlt_a="">＜</option>
											<option value="GT" gcop_opergt_a="">＞</option>
											<option value="LE" gcop_operle_a="">≤</option>
											<option value="GE" gcop_operge_a="">≥</option>
										</select>
									</td>
									<td gcol="input,DATA" gcoltype="input" gcolname="DATA" class="gcmo_DATA gcrc_DATA gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="15" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">16</td>
									<td gcol="select,LOGICAL" class="ico gcmo_LOGICAL gcrc_LOGICAL editable" gcoltype="select" gcolname="LOGICAL">
										<select value="OR" gcdo_logical_a="" style="width: 100%; height: 100%;">
											<option value="OR" selected="selected" gcop_logicalor_a="">OR</option>
											<option value="AND" gcop_logicaland_a="">AND</option>
										</select>
									</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
											<option value="LT" gcop_operlt_a="">＜</option>
											<option value="GT" gcop_opergt_a="">＞</option>
											<option value="LE" gcop_operle_a="">≤</option>
											<option value="GE" gcop_operge_a="">≥</option>
										</select>
									</td>
									<td gcol="input,DATA" gcoltype="input" gcolname="DATA" class="gcmo_DATA gcrc_DATA gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="16" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">17</td>
									<td gcol="select,LOGICAL" class="ico gcmo_LOGICAL gcrc_LOGICAL editable" gcoltype="select" gcolname="LOGICAL">
										<select value="OR" gcdo_logical_a="" style="width: 100%; height: 100%;">
											<option value="OR" selected="selected" gcop_logicalor_a="">OR</option>
											<option value="AND" gcop_logicaland_a="">AND</option>
										</select>
									</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
											<option value="LT" gcop_operlt_a="">＜</option>
											<option value="GT" gcop_opergt_a="">＞</option>
											<option value="LE" gcop_operle_a="">≤</option>
											<option value="GE" gcop_operge_a="">≥</option>
										</select>
									</td>
									<td gcol="input,DATA" gcoltype="input" gcolname="DATA" class="gcmo_DATA gcrc_DATA gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="17" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">18</td>
									<td gcol="select,LOGICAL" class="ico gcmo_LOGICAL gcrc_LOGICAL editable" gcoltype="select" gcolname="LOGICAL">
										<select value="OR" gcdo_logical_a="" style="width: 100%; height: 100%;">
											<option value="OR" selected="selected" gcop_logicalor_a="">OR</option>
											<option value="AND" gcop_logicaland_a="">AND</option>
										</select>
									</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
											<option value="LT" gcop_operlt_a="">＜</option>
											<option value="GT" gcop_opergt_a="">＞</option>
											<option value="LE" gcop_operle_a="">≤</option>
											<option value="GE" gcop_operge_a="">≥</option>
										</select>
									</td>
									<td gcol="input,DATA" gcoltype="input" gcolname="DATA" class="gcmo_DATA gcrc_DATA gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="18" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">19</td>
									<td gcol="select,LOGICAL" class="ico gcmo_LOGICAL gcrc_LOGICAL editable" gcoltype="select" gcolname="LOGICAL">
										<select value="OR" gcdo_logical_a="" style="width: 100%; height: 100%;">
											<option value="OR" selected="selected" gcop_logicalor_a="">OR</option>
											<option value="AND" gcop_logicaland_a="">AND</option>
										</select>
									</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
											<option value="LT" gcop_operlt_a="">＜</option>
											<option value="GT" gcop_opergt_a="">＞</option>
											<option value="LE" gcop_operle_a="">≤</option>
											<option value="GE" gcop_operge_a="">≥</option>
										</select>
									</td>
									<td gcol="input,DATA" gcoltype="input" gcolname="DATA" class="gcmo_DATA gcrc_DATA gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="19" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">20</td>
									<td gcol="select,LOGICAL" class="ico gcmo_LOGICAL gcrc_LOGICAL editable" gcoltype="select" gcolname="LOGICAL">
										<select value="OR" gcdo_logical_a="" style="width: 100%; height: 100%;">
											<option value="OR" selected="selected" gcop_logicalor_a="">OR</option>
											<option value="AND" gcop_logicaland_a="">AND</option>
										</select>
									</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
											<option value="LT" gcop_operlt_a="">＜</option>
											<option value="GT" gcop_opergt_a="">＞</option>
											<option value="LE" gcop_operle_a="">≤</option>
											<option value="GE" gcop_operge_a="">≥</option>
										</select>
									</td>
									<td gcol="input,DATA" gcoltype="input" gcolname="DATA" class="gcmo_DATA gcrc_DATA gridColInputText editable"></td>
								</tr></tbody>
						</table>
					</div>
				</div>
			</div>
			<div id="tab2" aria-labelledby="ui-id-3" class="ui-tabs-panel ui-widget-content ui-corner-bottom" role="tabpanel" aria-hidden="false" style="display: block;">
				<div class="table type2 section">
					<div class="tableHeader tbl_space tbl_big" style="margin-left: 0px;">
						<table>
							<colgroup>
								<col width="40px" gcolname="rownum">
								<col width="40px" gcolname="OPER">
								<col width="158px" gcolname="FROM">
								<col width="150px" gcolname="TO">
							</colgroup>
							<thead>
								<tr>
									<th cl="BOTTOM_NUM" gcolname="rownum" gcolvalue="번호">번호</th>
									<th cl="BOTTOM_OPER" gcolname="OPER" gcolvalue="수식"><table class="thInTable" style="width:100%;" title="수식"><tbody><tr><td style="width:10px;"></td><td gcolname="OPER">수식</td><td style="width: 3px; position: relative;" class="GLHeadColRight ui-draggable ui-draggable-handle" gcolname="OPER"></td></tr></tbody></table></th>
									<th cl="BOTTOM_FROM" gcolname="FROM" gcolvalue="FROM"><table class="thInTable" style="width:100%;" title="FROM"><tbody><tr><td style="width:10px;"></td><td gcolname="FROM">FROM</td><td style="width: 3px; position: relative;" class="GLHeadColRight ui-draggable ui-draggable-handle" gcolname="FROM"></td></tr></tbody></table></th>
									<th cl="BOTTOM_TO" gcolname="TO" gcolvalue="TO"><table class="thInTable" style="width:100%;" title="TO"><tbody><tr><td style="width:10px;"></td><td gcolname="TO">TO</td><td style="width: 3px; position: relative;" class="GLHeadColRight ui-draggable ui-draggable-handle" gcolname="TO"></td></tr></tbody></table></th>
								</tr>
							</thead>
						</table>
					</div>
					<div class="tableBody tbl_space tbl_big">
						<table style="padding-bottom: 0px; padding-top: 0px;">
							<colgroup>
								<col width="40px" gcolname="rownum" class="gridColObject">
								<col width="40px" gcolname="OPER">
								<col width="158px" gcolname="FROM">
								<col width="134px" gcolname="TO">
							</colgroup>
							<tbody id="rangeRangeList" gbox="true" class="ui-selectable">
														
							<tr cgrow="true" grownum="0" class="grsl_ grfo_ focusRow" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">1</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
										</select>
									</td>
									<td gcol="input,FROM" gcoltype="input" gcolname="FROM" class="gcmo_FROM gcrc_FROM gridColInputText editable"></td>
									<td gcol="input,TO" gcoltype="input" gcolname="TO" class="gcmo_TO gcrc_TO gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="1" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">2</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
										</select>
									</td>
									<td gcol="input,FROM" gcoltype="input" gcolname="FROM" class="gcmo_FROM gcrc_FROM gridColInputText editable"></td>
									<td gcol="input,TO" gcoltype="input" gcolname="TO" class="gcmo_TO gcrc_TO gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="2" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">3</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
										</select>
									</td>
									<td gcol="input,FROM" gcoltype="input" gcolname="FROM" class="gcmo_FROM gcrc_FROM gridColInputText editable"></td>
									<td gcol="input,TO" gcoltype="input" gcolname="TO" class="gcmo_TO gcrc_TO gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="3" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">4</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
										</select>
									</td>
									<td gcol="input,FROM" gcoltype="input" gcolname="FROM" class="gcmo_FROM gcrc_FROM gridColInputText editable"></td>
									<td gcol="input,TO" gcoltype="input" gcolname="TO" class="gcmo_TO gcrc_TO gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="4" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">5</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
										</select>
									</td>
									<td gcol="input,FROM" gcoltype="input" gcolname="FROM" class="gcmo_FROM gcrc_FROM gridColInputText editable"></td>
									<td gcol="input,TO" gcoltype="input" gcolname="TO" class="gcmo_TO gcrc_TO gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="5" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">6</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
										</select>
									</td>
									<td gcol="input,FROM" gcoltype="input" gcolname="FROM" class="gcmo_FROM gcrc_FROM gridColInputText editable"></td>
									<td gcol="input,TO" gcoltype="input" gcolname="TO" class="gcmo_TO gcrc_TO gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="6" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">7</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
										</select>
									</td>
									<td gcol="input,FROM" gcoltype="input" gcolname="FROM" class="gcmo_FROM gcrc_FROM gridColInputText editable"></td>
									<td gcol="input,TO" gcoltype="input" gcolname="TO" class="gcmo_TO gcrc_TO gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="7" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">8</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
										</select>
									</td>
									<td gcol="input,FROM" gcoltype="input" gcolname="FROM" class="gcmo_FROM gcrc_FROM gridColInputText editable"></td>
									<td gcol="input,TO" gcoltype="input" gcolname="TO" class="gcmo_TO gcrc_TO gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="8" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">9</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
										</select>
									</td>
									<td gcol="input,FROM" gcoltype="input" gcolname="FROM" class="gcmo_FROM gcrc_FROM gridColInputText editable"></td>
									<td gcol="input,TO" gcoltype="input" gcolname="TO" class="gcmo_TO gcrc_TO gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="9" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">10</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
										</select>
									</td>
									<td gcol="input,FROM" gcoltype="input" gcolname="FROM" class="gcmo_FROM gcrc_FROM gridColInputText editable"></td>
									<td gcol="input,TO" gcoltype="input" gcolname="TO" class="gcmo_TO gcrc_TO gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="10" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">11</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
										</select>
									</td>
									<td gcol="input,FROM" gcoltype="input" gcolname="FROM" class="gcmo_FROM gcrc_FROM gridColInputText editable"></td>
									<td gcol="input,TO" gcoltype="input" gcolname="TO" class="gcmo_TO gcrc_TO gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="11" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">12</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
										</select>
									</td>
									<td gcol="input,FROM" gcoltype="input" gcolname="FROM" class="gcmo_FROM gcrc_FROM gridColInputText editable"></td>
									<td gcol="input,TO" gcoltype="input" gcolname="TO" class="gcmo_TO gcrc_TO gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="12" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">13</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
										</select>
									</td>
									<td gcol="input,FROM" gcoltype="input" gcolname="FROM" class="gcmo_FROM gcrc_FROM gridColInputText editable"></td>
									<td gcol="input,TO" gcoltype="input" gcolname="TO" class="gcmo_TO gcrc_TO gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="13" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">14</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
										</select>
									</td>
									<td gcol="input,FROM" gcoltype="input" gcolname="FROM" class="gcmo_FROM gcrc_FROM gridColInputText editable"></td>
									<td gcol="input,TO" gcoltype="input" gcolname="TO" class="gcmo_TO gcrc_TO gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="14" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">15</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
										</select>
									</td>
									<td gcol="input,FROM" gcoltype="input" gcolname="FROM" class="gcmo_FROM gcrc_FROM gridColInputText editable"></td>
									<td gcol="input,TO" gcoltype="input" gcolname="TO" class="gcmo_TO gcrc_TO gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="15" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">16</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
										</select>
									</td>
									<td gcol="input,FROM" gcoltype="input" gcolname="FROM" class="gcmo_FROM gcrc_FROM gridColInputText editable"></td>
									<td gcol="input,TO" gcoltype="input" gcolname="TO" class="gcmo_TO gcrc_TO gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="16" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">17</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
										</select>
									</td>
									<td gcol="input,FROM" gcoltype="input" gcolname="FROM" class="gcmo_FROM gcrc_FROM gridColInputText editable"></td>
									<td gcol="input,TO" gcoltype="input" gcolname="TO" class="gcmo_TO gcrc_TO gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="17" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">18</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
										</select>
									</td>
									<td gcol="input,FROM" gcoltype="input" gcolname="FROM" class="gcmo_FROM gcrc_FROM gridColInputText editable"></td>
									<td gcol="input,TO" gcoltype="input" gcolname="TO" class="gcmo_TO gcrc_TO gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="18" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">19</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
										</select>
									</td>
									<td gcol="input,FROM" gcoltype="input" gcolname="FROM" class="gcmo_FROM gcrc_FROM gridColInputText editable"></td>
									<td gcol="input,TO" gcoltype="input" gcolname="TO" class="gcmo_TO gcrc_TO gridColInputText editable"></td>
								</tr><tr cgrow="true" grownum="19" class="grsl_ grfo_" style="height: 22px;">
									<td gcol="rownum" gcoltype="rownum" gcolname="rownum" class="rownum gridColObject">20</td>
									<td gcol="select,OPER" class="ico gcmo_OPER gcrc_OPER editable" gcoltype="select" gcolname="OPER">
										<select value="E" gcdo_oper_a="" style="width: 100%; height: 100%;">
											<option value="E" selected="selected" gcop_opere_a="">=</option>
											<option value="N" gcop_opern_a="">≠</option>
										</select>
									</td>
									<td gcol="input,FROM" gcoltype="input" gcolname="FROM" class="gcmo_FROM gcrc_FROM gridColInputText editable"></td>
									<td gcol="input,TO" gcoltype="input" gcolname="TO" class="gcmo_TO gcrc_TO gridColInputText editable"></td>
								</tr></tbody>
						</table>
					</div>
				</div>
			</div>	
			<div class="tableUtil btn_wrap">
				<div class="leftArea">
					<button class="button type2" type="button" onclick="rangeObj.confirmRange()"><img src="/common/theme/darkness/images/ico_confirm.png" alt=""><label cl="BOTTOM_CONFIRM">확인</label></button>
					<button class="button type2" type="button" onclick="rangeObj.clearRange('rangeRangeList')"><img src="/common/theme/darkness/images/ico_cancel.png" alt=""><label cl="BOTTOM_CLEAR">초기화</label></button>
				</div>
				<div class="rightArea">
				</div>
			</div>
		</div>
	</div>
</body>
</html>