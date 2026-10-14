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