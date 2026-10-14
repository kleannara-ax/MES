<%@ page import="com.common.bean.*,com.common.util.*,com.common.bean.CommonConfig,java.util.*"%>
<%
	DataMap paramDataMap = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
	if(paramDataMap == null){
		paramDataMap = new DataMap(request);
	}
	String menuId = paramDataMap.getString(CommonConfig.MENU_ID_KEY);
	String langky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_LANGUAGE_KEY);
	
	String theme =(String)request.getSession().getAttribute(CommonConfig.SES_USER_THEME_KEY);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>WMS</title>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<link rel="stylesheet" type="text/css" href="/common<%=theme%>/css/common.css">
<link rel="stylesheet" type="text/css" href="/common<%=theme%>/css/content_body.css">
<link rel="stylesheet" type="text/css" href="/common<%=theme%>/css/content_ui.css">
<link rel="stylesheet" type="text/css" href="/common<%=theme%>/css/theme.css">
<script type="text/javascript" src="/common/js/jquery.js"></script>
<script type="text/javascript" src="/common/js/jquery-ui.js"></script>
<script type="text/javascript" src="/common/js/jquery-ui.custom.js"></script>
<%
	if(langky != null && (langky.equals("CN") || langky.equals("ZH"))){
%>
<script type="text/javascript" src="/common/js/datepicker/jquery.ui.datepicker-zh-CN.js"></script>
<%
	}else{
%>
<script type="text/javascript" src="/common/js/datepicker/jquery.ui.datepicker-ko.js"></script>
<%
	}
%>
<script type="text/javascript" src="/common/js/jquery.plugin.js"></script>
<script type="text/javascript" src="/common/js/jquery.form.js"></script>
<script type="text/javascript" src="/common/js/jquery.cookie.js"></script>
<script type="text/javascript" src="/common/js/jquery.mousewheel.js"></script>
<script type="text/javascript" src="/common/js/json2.js"></script>
<script type="text/javascript" src="/common/js/big.js"></script>
<script type="text/javascript" src="/common/js/dataMap.js"></script>
<script type="text/javascript" src="/common/js/configData.js"></script>
<script type="text/javascript" src="/common/js/label.js"></script>
<script type="text/javascript" src="/common/lang/label-<%=langky%>.js"></script>
<script type="text/javascript" src="/common/lang/message-<%=langky%>.js"></script>
<script type="text/javascript" src="/common/js/site.js"></script>
<script type="text/javascript" src="/common/js/commonUtil.js"></script>
<script type="text/javascript" src="/common<%=theme%>/js/theme.js"></script>
<script type="text/javascript" src="/common/js/dataBind.js"></script>
<script type="text/javascript" src="/common/js/input.js"></script>
<script type="text/javascript" src="/common/js/netUtil.js"></script>
<script type="text/javascript" src="/common/js/ui.js"></script>
<script type="text/javascript" src="/common/js/worker-ajax.js"></script>
<script type="text/javascript" src="/common/js/bigdata.js"></script>
<script type="text/javascript" src="/common/js/dataRequest.js"></script>
<script type="text/javascript" src="/common/js/grid.js"></script>
<script type="text/javascript" src="/common/js/layoutSave.js"></script>
<script type="text/javascript" src="/common/js/validateUtil.js"></script>
<script type="text/javascript" src="/common/js/page.js"></script>
<script>
//탭 인덱스 변경
(function() {
	$(function() {
		var tab = $('.tab.type2')
			, tabTrigger = tab.children('a');

		tabTrigger.each(function(i) {

			var zIndex = tabTrigger.length - i;

			$(this).css('zIndex',zIndex);

		});
	});
})();

var topGridHeight = "160px";
//그리드 크기 조절
(function() {
	$(function() {
		var trigger = $('.fullSizer')
		, target1 = $('.bottomSect.top')
		, target1Height = target1.css('height')
		, target2 = $('.bottomSect.bottom')
		, target2OriginTop = target2.css('top');
		
		if(target1.length > 0){
			trigger.eq(0).on({
				click : function() {
					if ( trigger.eq(0).hasClass('folded') ) {
						target1.css({ height : target1Height, bottom : 'auto' });
						target2.css({ top : target2OriginTop, height : 'auto' });
						trigger.eq(0).removeClass('folded');
					} else {
						target1.css({ height : 'auto', bottom : 10 });
						target2.css({ height : 0, top : 'auto' });
						trigger.eq(0).addClass('folded');
					}
				}
			});
		
			trigger.eq(1).on({
				click : function() {
					if ( trigger.eq(1).hasClass('folded') ) {
						target1.css({ height : target1Height, bottom : 'auto' });
						target2.css({ top : target2OriginTop, height : 'auto' });
						trigger.eq(1).removeClass('folded');
					} else {
						target1.css({ height : 0 });
						target2.css({ top : 8 });
						trigger.eq(1).addClass('folded');
					}
				}
			});
		}else{
			target2 = $('.bottomSect');
			target2OriginTop = target2.css('top');
			trigger.eq(0).on({
				click : function() {
					if ( trigger.eq(0).hasClass('folded') ) {
						target2.css({ top : target2OriginTop, height : 'auto' });
						trigger.eq(0).removeClass('folded');
					} else {
						target2.css({ top : 8 });
						trigger.eq(0).addClass('folded');
					}
				}
			});
		}		
	});
})();

// jQuery 탭 기능
(function() {
	$(function() {
		$('.tabs').tabs();
	});
})();


// 검색 팝업
(function() {
	$(function() {
		var trigger = $('#showPop')
			, pop = $('.searchPop')
			, closer = pop.find('.closer');

		trigger.on({
			click : function() {
				pop.stop(true, true).fadeIn(150);
			}
		});

		closer.on({
			click : function() {
				pop.stop(true, true).fadeOut(150);
			}
		});
	});
})();

// 테이블 스크롤
(function() {
	$(function() {
		var table = $('.table.type2');

		table.each(function() {
			var _this = $(this)
				, header = _this.find('.tableHeader')
				, body = _this.find('.tableBody');

			body.on({
				scroll : function(e) {
					var scrollLeft = $(this).scrollLeft();

					//console.log(scrollLeft);
					header.css({
						marginLeft : -scrollLeft
					});
				}
			});
		});
	});
})();

//레인지 팝업
function rangePop() {

	var	pop = $('.layerPopup')
		, closer = pop.find('.closer');

	pop.stop(true, true).fadeIn(150);
	closer.on({
		click : function() {
			pop.stop(true, true).fadeOut(150);
		}
	});
}

function rangePopClose() {
	var	pop = $('.layerPopup');
	pop.stop(true, true).fadeOut(150);
}

// 경고창
function alertMessage() {

	var alert = $('.alertMessage')
		, closer = alert.find('.closer');

	alert.fadeIn(150);

	closer.on({
		click : function() {
			alert.fadeOut(150);
		}
	});
}

// 로딩 열기
function loadingOpen() {

	var loader = $('<div class="contentLoading"></div>').appendTo('body');

	loader.stop().animate({
		top : '0px'
	}, 30, function() {
	});
}

var $contentLoading;
//로딩 열기
function loadingOpen() {
	
	$contentLoading.show();
}

//로딩 닫기
function loadingClose() {
	
	$contentLoading.hide();
}

function searchOpen(showType){
	var pop = $('.searchPop');
	if(!showType){
		showType = false;
	}
	if (showType) {
		pop.stop(true, true).fadeIn(150);
	} else {
		pop.stop(true, true).fadeOut(150);
	}
}

function showLayoutSave(){
	var loader = $('<div class="contentLayoutSave"></div>').appendTo('body');
	
	loader.stop().animate({
		top : '0px'
	}, 30, function() {
	});
	
    $('#layoutSavePop').show();
}

function hideLayoutSave(){
	 var loader = $('.contentLayoutSave');

	loader.stop().animate({
		top : '100%'
	}, 30, function() {
		loader.remove();
	});
	
	$('#layoutSavePop').hide();
}

function setTopSize(height){
	$('.bottomSect.top').css("height",height+"px");
	$('.bottomSect.bottom').css("top",(height+20)+"px");
}

configData.MENU_ID = '<%=menuId%>';

function layoutSaveClose(){
	var loader = $('.contentLayoutSave');

	loader.stop().animate({
		top : '100%'
	}, 30, function() {
		loader.remove();
	});
	
    $('#layoutSavePop').hide();
}

</script>
<script type="text/javascript">
	$(document).ready(function(){
		var searchParam = window.opener.page.getSearchParam();
		if(searchParam){
			dataBind.dataNameBind(searchParam, "searchArea");			
		}
		
		$("body").hide();
		
		$contentLoading = jQuery("#contentLoading");
		
		$('.searchPop').stop(true, true).fadeIn(150);	
		
		uiList.UICheck();
		inputList.setCombo();
		inputList.setInput();
		$("body").show();
		$(window).resize(function(event){
			//alert(window.outerHeight);
			gridList.resize();
		});
		
		gridList.setGrid({
			id : configData.GRID_LAYOUT_SAVE_INVISIBLE_ID,
			editable : false,
			sortType : false,
			copyEventType : false,
			rowDblClickEventFn : "layoutSave.layoutRowDblclick"
		});
			
		gridList.setGrid({
			id : configData.GRID_LAYOUT_SAVE_VISIBLE_ID,
			editable : false,
			sortType : false,
			copyEventType : false,
			rowDblClickEventFn : "layoutSave.layoutRowDblclick"
		});
			
		gridList.setGrid({
			id : configData.INPUT_RANGE_SINGLEGRID_ID,
			editable : false,
			sortType : false,
			viewFormat : true,
			autoNewRowType : true,
			enterKeyType : "R",
			editedClassType : false
		});
			
		gridList.setGrid({
			id : configData.INPUT_RANGE_RANGEGRID_ID,
			editable : false,
			sortType : false,
			viewFormat : true,
			autoNewRowType : true,
			editedClassType : false
		});
		
		gridList.setGrid({
			id : configData.GRID_FILTER_COL_ID,
			editable : false,
			sortType : false,
			copyEventType : false,
			firstRowFocusType : false,
			rowClickEventFn : "gridList.filterColRowClick"
		});
			
		gridList.setGrid({
			id : configData.GRID_FILTER_DATA_ID,
			editable : false,
			sortType : false,
			copyEventType : false,
			firstRowFocusType : false,
			rowClickEventFn : "gridList.filterDataRowClick"
		});
	});
</script>
<script type="text/javascript">
	$(document).ready(function(){
		gridList.setGrid({
	    	id : "gridList",
			module : "Demo",
			command : "DEMOHEAD",
			itemGrid : "gridListItem",
			itemSearch : true
	    });
		gridList.setGrid({
	    	id : "gridListItem",
			module : "Demo",
			command : "DEMOITEM"
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
	
	function gridListEventItemGridSearch(gridId, rowNum, itemGridList){
		if(gridId == "gridList"){
			var param = gridList.getRowData(gridId, rowNum);
			
			gridList.gridList({
		    	id : "gridListItem",
		    	param : param
		    });
		}
	}
	
	function saveData(){
		alert(gridList.getItemGridViewCheck("gridList"));
		return;
		if(gridList.validationCheck("gridList", "all")){
			var json = gridList.gridSave({
		    	id : "gridList"
		    });
		}
	}
	
	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Search"){
			searchList();
		}else if(btnName == "Save"){
			saveData();
		}else if(btnName == "Test"){
			test();
		}else if(btnName == "Test1"){
			test1();
		}
	}
	
	function test(){
		//gridList.setHeadText("gridList", "SHORTX", "Test");
		gridList.setRowReadOnly("gridListItem", 1, true, ["ZONEKY","AREAKY"]);
	}
	
	function test1(){
		//gridList.setHeadText("gridList", "SHORTX", "Test");
		gridList.setRowReadOnly("gridListItem", 1, false);
	}
</script>
</head>
<body>
<div class="contentHeader">
	<div class="util">
		<button CB="Search SEARCH BTN_DISPLAY"></button>
		<button CB="Save SAVE STD_SAVE"></button>
		<button CB="Test WORK STD_TEST"></button>
		<button CB="Test1 WORK STD_TEST"></button>
	</div>
	<div class="util2">
		<button class="button type2" id="showPop" type="button"><img src="/common/images/ico_btn4.png" alt="List" /></button>
	</div>
</div>

<!-- searchPop -->
<div class="searchPop" id="searchArea">
	<button type="button" class="closer">X</button>
	<div class="searchInnerContainer">
		<p class="util">
			<button CB="Search SEARCH BTN_DISPLAY"></button>
			<button CB="GetVariant GETVARIANT BTN_GETVARIANT"></button>
			<button CB="SaveVariant SAVEVARIANT BTN_SAVEVARIANT"></button>
		</p>
		<div class="searchInBox">
			<h2 class="tit" CL="STD_SELECTOPTIONS">검색조건</h2>
			<table class="table type1">
				<colgroup>
					<col width="100" />
					<col />
				</colgroup>
				<tbody>
					<tr>
						<th CL="STD_WAREKY">거점</th>
						<td>
							<input type="text" name="WAREKY" UIInput="S,SHWAHMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_AREAKY">창고</th>
						<td>
							<input type="text" name="AREAKY" UIInput="R,SHAREMA" />
						</td>
					</tr>
					<tr>
						<th CL="STD_ZONEKY">Zone Code</th>
						<td>
							<input type="text" name="ZONEKY" UIInput="R,SHZONMA" />
						</td>
					</tr>
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

			<div class="bottomSect top">
				<button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button>
				<div class="tabs">
					<ul class="tab type2">
						<li><a href="#tabs1-1"><span CL="STD_GENERAL"></span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
											<col width="40" />
											<col width="40" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />											
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
										</colgroup>
										<thead>
											<tr>
												<th CL='STD_NUMBER'>번호</th>
												<th GBtnCheck="true"></th>
												<th CL='STD_WAREKY'>거점</th>
												<th CL='STD_AREAKY'>창고</th>
												<th CL='STD_ZONEKY'>구역</th>
												<th CL='STD_ZONETY'>구역타입</th>
												<th CL='STD_SHORTX'>설명</th>
												<th CL='STD_CREDAT'>생성일자</th>
												<th CL='STD_CRETIM'>생성시간</th>
												<th CL='STD_CREUSR'>생성자</th>
												<th CL='STD_LMODAT'>수정일자</th>
												<th CL='STD_LMOTIM'>수정시간</th>
												<th CL='STD_LMOUSR'>수정자</th>
											</tr>
										</thead>
									</table>
								</div>
								<div class="tableBody">
									<table>
										<colgroup>
											<col width="40" />
											<col width="40" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />											
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
											<col width="100" />
										</colgroup>
										<tbody id="gridList">
											<tr CGRow="true">
												<td GCol="rownum">1</td>
												<td GCol="rowCheck"></td>
												<td GCol="text,WAREKY"></td>
												<td GCol="input,AREAKY,SHAREMA,true" GF="S 10" validate="required,MASTER_M0254"></td>
												<td GCol="input,ZONEKY,SHZONMA" validate="required" ></td>
												<td GCol="select,ZONETY" validate="required">
													<select CommonCombo="ZONETY">
														<option value=" "></option>
													</select>
												</td>
												<td GCol="input,SHORTX" GF="S 180"></td> 
												<td GCol="text,CREDAT"></td>
												<td GCol="text,CRETIM"></td>
												<td GCol="text,CREUSR"></td>
												<td GCol="text,LMODAT" GF="D"></td>
												<td GCol="text,LMOTIM" GF="T"></td>
												<td GCol="text,LMOUSR"></td>
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
									<p class="record" GInfoArea="true"></p>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>

			<div class="bottomSect bottom">
				<button type="button" class="button type2 fullSizer"><img src="/common/images/ico_full.png" alt="Full Size"></button>
				<div class="tabs">
					<ul class="tab type2" id="commonMiddleArea">
						<li><a href="#tabs1-1"><span CL='STD_SEARCH'></span></a></li>
					</ul>
					<div id="tabs1-1">
						<div class="section type1">
							<div class="table type2">
								<div class="tableHeader">
									<table>
										<colgroup>
											<col width="40" />
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
												<th CL='STD_NUMBER'></th>
												<th GBtnCheck="true"></th>
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
										<tbody id="gridListItem">
											<tr CGRow="true">
												<td GCol="rownum"></td>
												<td GCol="rowCheck"></td>
												<td GCol="text,WAREKY"></td>
												<td GCol="add,AREAKY"></td>
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
												<td GCol="input,CREDAT" GF="C"></td>
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
									<button type="button" GBtn="filter"></button>
									<button type="button" GBtn="sortReset"></button>
									<button type="button" GBtn="add"></button>
									<button type="button" GBtn="copy"></button>
									<button type="button" GBtn="delete"></button>
									<button type="button" GBtn="layout"></button>
									<button type="button" GBtn="total"></button>
									<button type="button" GBtn="subTotal"></button>
									<button type="button" GBtn="excel"></button>
									<button type="button" GBtn="excelUpload"></button>
									<button type="button" GBtn="colFix"></button>									
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
</body>
</html>