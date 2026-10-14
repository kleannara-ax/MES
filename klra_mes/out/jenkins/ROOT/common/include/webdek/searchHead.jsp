<%@ page import="project.common.bean.DataMap,project.common.bean.CommonConfig"%>
<%
	String wareky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_WHAREHOUSE_KEY);
	String compky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_COMPANY_KEY);
	String langky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_LANGUAGE_KEY);
	String ownrky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_OWNER_KEY);

	String theme =(String)request.getSession().getAttribute(CommonConfig.SES_USER_THEME_KEY);
%>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/layout.css">
<link rel="stylesheet" type="text/css" href="/common/theme/webedek/css/content_ui.css">
<script type="text/javascript" src="/common/js/jquery.js"></script>
<script type="text/javascript" src="/common/js/jquery-ui.js"></script>
<script type="text/javascript" src="/common/js/jquery-ui.custom.js"></script>
<%
	if(langky == null){
%>
<script type="text/javascript" src="/common/js/datepicker/jquery.ui.datepicker-ko.js"></script>
<%
	}else if(langky.equals("ZH")){
%>
<script type="text/javascript" src="/common/js/datepicker/jquery.ui.datepicker-zh-CN.js"></script>
<%
	}else if(langky.equals("EN")){
%>
<script type="text/javascript" src="/common/js/datepicker/jquery.ui.datepicker-en-GB.js"></script>
<%
	}else{
%>
<script type="text/javascript" src="/common/js/datepicker/jquery.ui.datepicker-ko.js"></script>
<%
	}
%>
<script type="text/javascript" src="/common/js/jquery.plugin.js"></script>
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
<script type="text/javascript" src="/common/theme/webdek/js/theme.js"></script>
<script type="text/javascript" src="/common/js/dataBind.js"></script>
<script type="text/javascript" src="/common/js/input.js"></script>
<script type="text/javascript" src="/common/js/netUtil.js"></script>
<script type="text/javascript" src="/common/js/ui.js"></script>
<script type="text/javascript" src="/common/js/worker-ajax.js"></script>
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

var $contentLoading;
//로딩 열기
function loadingOpen() {
	
	$contentLoading.show();
}

//로딩 닫기
function loadingClose() {
	
	$contentLoading.hide();
}

function showSearch(showType){
	var pop = $('.searchPop');

	if ( pop.is(':hidden') ) {
		pop.stop(true, true).fadeIn(150);
	} else {
		pop.stop(true, true).fadeOut(150);
	}
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
		$("body").hide();
		
		$contentLoading = jQuery("#contentLoading");
		
		$('.searchPop').stop(true, true).fadeIn(150);	
		
		uiList.UICheck();
		inputList.setCombo();
		inputList.setInput();
		
		var openerParam = opener.dataBind.paramData("searchArea");
		if(openerParam){
			dataBind.dataNameBind(openerParam, "searchArea");
			for(var prop in openerParam.map){
				if(inputList.rangeMap.containsKey(prop)){
					inputList.setRangeData(prop, configData.INPUT_RANGE_RANGE_FROM, openerParam.get(prop));
				}else if(prop.indexOf(".")){
					var tmpProp = prop.substring(prop.indexOf(".")+1);
					if(inputList.rangeMap.containsKey(tmpProp)){
						inputList.setRangeData(tmpProp, configData.INPUT_RANGE_RANGE_FROM, openerParam.get(prop));
					}				
				}
			}
		}
		
		for(var prop in opener.inputList.rangeMap.map){			
			if(inputList.rangeMap.containsKey(prop)){
				var tmpObj = opener.inputList.rangeMap.get(prop);
				var inputObj = inputList.rangeMap.get(prop);
				inputObj.singleData = tmpObj.singleData;
				inputObj.rangeData = tmpObj.rangeData;				
				inputObj.setMultiData();
			}else if(prop.indexOf(".")){
				var tmpProp = prop.substring(prop.indexOf(".")+1);
				if(inputList.rangeMap.containsKey(tmpProp)){
					var tmpObj = opener.inputList.rangeMap.get(prop);
					var inputObj = inputList.rangeMap.get(tmpProp);
					inputObj.singleData = tmpObj.singleData;
					inputObj.rangeData = tmpObj.rangeData;				
					inputObj.setMultiData();
				}				
			}
		}
		
		var searchParam = window.opener.page.getSearchParam();
		
		if(searchParam){			
			dataBind.dataNameBind(searchParam, "searchArea");
			for(var prop in searchParam.map){
				if(inputList.rangeMap.containsKey(prop)){
					var obj = searchParam.get(prop);
					if(typeof obj == "string"){
						var inputObj = inputList.rangeMap.get(prop);
						inputObj.searchType = "from";
						inputObj.$from.val(obj);
						inputObj.valueChange();
					}else if(obj && obj.length > 0){
						if(typeof obj[0] == "string"){
							var sList = new Array();
							for(var i=0;i<obj.length;i++){
								var tmpMap = new DataMap();
								tmpMap.put(configData.INPUT_RANGE_LOGICAL, "OR");
								tmpMap.put(configData.INPUT_RANGE_OPERATOR, "E");
								tmpMap.put(configData.INPUT_RANGE_SINGLE_DATA, obj[i]);
								sList.push(tmpMap);
							}
							inputList.setRangeData(prop, configData.INPUT_RANGE_TYPE_SINGLE, sList);
						}else{
							var sList = new Array();
							var rList = new Array();
							var tmpMap;
							for(var i=0;i<obj.length;i++){
								tmpMap = obj[i];
								if(tmpMap.containsKey(configData.INPUT_RANGE_SINGLE_DATA)){
									if(!tmpMap.containsKey(configData.INPUT_RANGE_LOGICAL)){
										tmpMap.put(configData.INPUT_RANGE_LOGICAL, "OR");
									}
									if(!tmpMap.containsKey(configData.INPUT_RANGE_OPERATOR)){
										tmpMap.put(configData.INPUT_RANGE_OPERATOR, "E");
									}
									sList.push(tmpMap);
								}else{
									if(!tmpMap.containsKey(configData.INPUT_RANGE_OPERATOR)){
										tmpMap.put(configData.INPUT_RANGE_OPERATOR, "E");
									}
									rList.push(tmpMap);
								}
							}
							if(sList.length > 0){
								inputList.setRangeData(prop, configData.INPUT_RANGE_TYPE_SINGLE, sList);
							}
							if(rList.length > 0){
								inputList.setRangeData(prop, configData.INPUT_RANGE_TYPE_RANGE, rList);
							}
						}						
					}
				}
			}
		}
		
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
	});
</script>