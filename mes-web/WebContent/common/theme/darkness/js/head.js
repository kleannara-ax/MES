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
					gridList.scrollResize();
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
					gridList.scrollResize();
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
					gridList.scrollResize();
				}
			});
		}
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

(function() {
	$(function() {
		$('.tabs').tabs({
			activate: function( event, ui ) {
				if (Browser.ie){
					$(event.target).find('.table.type2').find('.tableBody').trigger("scroll");
				}				
			}
		});
	});
})();

// 테이블 스크롤
/*
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
*/

// 레인지 팝업
function rangePop() {
	var loader = $('<div class="contentLayoutSave"></div>').appendTo('body');
	
	loader.stop().animate({
		top : '0px'
	}, 30, function() {
	});

	$('.layerPopup').show();
}

function rangePopClose() {
	var loader = $('.contentLayoutSave');

	loader.stop().animate({
		top : '100%'
	}, 30, function() {
		loader.remove();
	});
	
	rangeObj.resetRange();
	$('.layerPopup').hide();
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
// 로딩 열기
function loadingOpen() {
	
	$contentLoading.show();

}

// 로딩 닫기
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

function showClipSave(){
	var loader = $('<div class="contentLayoutSave"></div>').appendTo('body');
	
	loader.stop().animate({
		top : '0px'
	}, 30, function() {
	});
	
    $('#ClipSavePop').show();
}

function hideClipSave(){
	 var loader = $('.contentLayoutSave');

	loader.stop().animate({
		top : '100%'
	}, 30, function() {
		loader.remove();
	});
	
	$('#ClipSavePop').hide();
}

function showExcelUpload(){
	var loader = $('<div class="contentLayoutSave"></div>').appendTo('body');
	
	loader.stop().animate({
		top : '0px'
	}, 30, function() {
	});
	
    $('#ExcelUploadPop').show();
}

function hideExcelUpload(){
	 var loader = $('.contentLayoutSave');

	loader.stop().animate({
		top : '100%'
	}, 30, function() {
		loader.remove();
	});
	
	$('#ExcelUploadPop').hide();
}

function showGridFilter(){
	var loader = $('<div class="contentLayoutSave"></div>').appendTo('body');
	
	loader.stop().animate({
		top : '0px'
	}, 30, function() {
	});
	
    $('#GridFilterPop').show();
}

function hideGridFilter(){
	 var loader = $('.contentLayoutSave');

	loader.stop().animate({
		top : '100%'
	}, 30, function() {
		loader.remove();
	});
	
	$('#GridFilterPop').hide();
}

function showGridSubTotal(){
	var loader = $('<div class="contentLayoutSave"></div>').appendTo('body');
	
	loader.stop().animate({
		top : '0px'
	}, 30, function() {
	});
	
    $('#GridSubTotalPop').show();
}

function hideGridSubTotal(){
	 var loader = $('.contentLayoutSave');

	loader.stop().animate({
		top : '100%'
	}, 30, function() {
		loader.remove();
	});
	
	$('#GridSubTotalPop').hide();
}

function setTopSize(height){
	topGridHeight = height+"px";
	$('.bottomSect.top').css("height",height+"px");
	$('.bottomSect.bottom').css("top",(height+20)+"px");	
}

configData.MENU_ID = top.getMenuId();
//commonUtil.consoleMsg(configData.MENU_ID);

function layoutSaveClose(){
	var loader = $('.contentLayoutSave');

	loader.stop().animate({
		top : '100%'
	}, 30, function() {
		loader.remove();
	});
	
    $('#layoutSavePop').hide();
}

function changeMiddleHeight($dragObj, ui){
	var height = parseInt(topGridHeight.substring(0, topGridHeight.length-2));
	height = height + ui.position.top;
	//setTopSize(height);
	$('.bottomSect.top').css("height",height+"px");
	$('.bottomSect.bottom').css("top",(height+20)+"px");
}

function setMiddleHeight($dragObj, ui){
	var height = parseInt(topGridHeight.substring(0, topGridHeight.length-2));
	height = height + ui.position.top;
	topGridHeight = height+"px";
	
	gridList.scrollResize();
}

$(document).ready(function(){
	/*
	 $('#close').click(function() {
		 var loader = $('.contentLayoutSave');

			loader.stop().animate({
				top : '100%'
			}, 30, function() {
				loader.remove();
			});
			
	        $('#layoutSavePop').hide();
	});
	*/
	 
	$(document.body).hide();
	$('#layoutSavePop').hide();
	//$('.searchPop').stop(true, true).fadeIn(150);	
	
	$contentLoading = jQuery("#contentLoading");
	
	uiList.autocompleteSet();
	uiList.UICheck();
	inputList.setCombo();
	inputList.setInput();
	inputList.setSearchAreaDefaultParam();
	inputList.setAutocomplete();
	uiList.autocompleteCheck();
	$(document.body).show();
	//$(window).resize(function(event){
		//alert(window.outerHeight);
		//gridList.resize();
	//});
	
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
	
	gridList.setGrid({
		id : configData.GRID_SUBTOTAL_COL_ID,
		editable : false,
		sortType : false,
		copyEventType : false
	});
	
	gridList.setGrid({
		id : configData.GRID_SUBTOTAL_DATA_ID,
		editable : false,
		sortType : false,
		copyEventType : false
	});
	
	var $middleArea = jQuery("#"+configData.MIDDLE_AREA);
	if($middleArea.length > 0){
		$middleArea.draggable({ 
			axis: "y",
			cursor: "n-resize",
			helper: "none",
			//revert: true,
			start: function(event, ui) {
				var $obj = jQuery(event.target);
				//$obj.text(ui.position.left);
			},
			drag: function(event, ui) {
				var $obj = jQuery(event.target);
				if ((Browser.ie6) || (Browser.ie7) || (Browser.ie8)) {

				}else{
					changeMiddleHeight($obj, ui);
				}				
			},
			stop: function(event, ui) {
				var $obj = jQuery(event.target);
				if ((Browser.ie6) || (Browser.ie7) || (Browser.ie8)) {
					changeMiddleHeight($obj, ui);
				}
				setMiddleHeight($obj, ui);
			}
		});
	}
	
	jQuery("body").keydown(function(event){
		var $obj = $(event.target);
		var code = event.keyCode;
		
		//8 backspace
		if(code == 8){
			var tmpTagName = $obj.get(0).tagName;
			
			switch(tmpTagName){
				case "TEXTAREA":
					break;
				case "INPUT":
					var tmpType = $obj.attr("type");
					if(tmpType.toLowerCase() == "text"){
						break;
					}
				default:
					commonUtil.cancleEvent(event);
			}
		}
		//s-83, c-67, v-86, 0-79, f-70
		if(code!= 18 && event.altKey){
			//alert(code);
			/*
			if(code == 67){
				alert("copy");
			}else if(code == 86){
				alert("paste");
				var copyData;
				if (window.clipboardData) { // Internet Explorer
					copyData = window.clipboardData.getData("Text");
			    }else{  
			    	copyData = "";
			    }
				alert(copyData);
			}*/
			if(code == site.COMMON_KEY_EVENT_SEARCH_CODE){
				$obj.blur();
				searchList();
			}else if(code == site.COMMON_KEY_EVENT_SAVE_CODE){
				$obj.blur();
				saveData();
			}else if(code == site.COMMON_KEY_EVENT_CREATE_CODE){
				$obj.blur();
				createData();
			}			
			
			var codeChar=String.fromCharCode(code);
			
			if(uiList.shortKeyBtnMap.containsKey(codeChar)){
				uiList.shortKeyBtnMap.get(codeChar).trigger("click");
			}
			
			try{					
				commonShortKeyEvent(code, codeChar);
			}catch(e){
			}
		}
	});
	
	jQuery("body").find("input :first").focus();
});

$(window).resize(function(){
    gridList.scrollResize();
    //gridList.reloadAll();
});