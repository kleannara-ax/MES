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
var chgTopGridHeigth = 0;

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
						topGridHeight = target1Height;
					} else {
						target1.css({ height : 'auto', bottom : 10 });
						target2.css({ height : 0, top : 'auto' });
						trigger.eq(0).addClass('folded');
						topGridHeight = target1Height;
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
						topGridHeight = target1Height;
					} else {
						target1.css({ height : 0 });
						target2.css({ top : 8 });
						trigger.eq(1).addClass('folded');
						topGridHeight = target1Height;
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

//레이어 팝업
function LayerPop() {
	var loader = $('<div class="contentLayoutSave"></div>').appendTo('body');
	
	loader.stop().animate({
		top : '0px'
	}, 30, function() {
	});

	$('.layerPopup').show();
}

function LayerPopClose() {
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
	
	try{
		window.top.logoEffectStart();
	}catch(e){}
}

// 로딩 닫기
function loadingClose() {
	
	$contentLoading.hide();
	
	try{
		window.top.logoEffectStop();
	}catch(e){}
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

var mFileUploadLayer_file = "<input type='file' validate='required'/>";
var mFileUploadLayer_view = "<span class='fileNameView' onClick='downloadMFileRow(this)'></span><input class='button type6' type='button' class='file_dele' onClick='deleteMFileRow(this)'><label> - </label></button><br/>";
var $mFileUploadLayer;
function showMFileUpload(guuid, list, fileType){
	var loader = $('<div class="contentLayoutSave"></div>').appendTo('body');
	
	loader.stop().animate({
		top : '0px'
	}, 30, function() {
	});
	
    
	if($mFileUploadLayer == undefined){
		$mFileUploadLayer = $("#mFileUploadLayer");
	}
	if(fileType == "none"){
		$mFileUploadLayer.find("form").hide();
	}else{
		$mFileUploadLayer.find("form").show();
	}
	if(guuid && guuid.length == 36){
		$mFileUploadLayer.find("[name=GUUID]").val(guuid);
	}else{
		$mFileUploadLayer.find("[name=GUUID]").val("");
	}
	if(list){
		var $tmpViewArea = $mFileUploadLayer.find(".table_list01").eq(0);
		for(var i=0;i<list.length;i++){
			var $tmpObj = $(mFileUploadLayer_view);
			$tmpObj.filter("span").text(list[i]["NAME"]).attr("UUID",list[i]["UUID"]);				
			$tmpViewArea.append($tmpObj);
			if(fileType == "none"){
				$tmpViewArea.find(".file_dele").remove();
			}
		}
	}	
	$mFileUploadLayer.show();
}

function hideMFileUpload(){
	$mFileUploadLayer.hide();
	$mFileUploadLayer.find("[name=GUUID]").val("");
	//$mFileUploadLayer.find("form").find(":file:gt(0)").remove();
	//$mFileUploadLayer.find("form").find(":file").val("");
	var $tmpFileList = $mFileUploadLayer.find("form").find(":file");	
	$tmpFileList.eq(0).val("");
	if($tmpFileList.length > 1){
		for(var i=1;i<$tmpFileList.length;i++){
			//$tmpFileList.eq(i).next().remove();
			$tmpFileList.eq(i).remove();
		}
	}	
	$mFileUploadLayer.find(".table_list01").eq(0).children().remove();
	
	var loader = $('.contentLayoutSave');

	loader.stop().animate({
		top : '100%'
	}, 30, function() {
		loader.remove();
	});
	
	$mFileUploadLayer.hide();
}

function mFileAdd(){
	var $tmpUploadBtn = $mFileUploadLayer.find("[type=submit]");
	var tmpNum = $mFileUploadLayer.find("form").find(":file").length;
	var $tmpObj = $(mFileUploadLayer_file);
	$tmpObj.filter("input").attr("name","file"+tmpNum);
	$tmpUploadBtn.before($tmpObj);
}

function deleteMFileRow(obj){
	var $obj = $(obj);
	var uuid = $obj.prev().attr("UUID");
	if(gridList.deleteMFileRow(uuid)){
		$obj.prev().remove();
		$obj.next().remove();
		$obj.remove();	
	}
}

function downloadMFileRow(obj){
	var $obj = $(obj);
	var uuid = $obj.attr("UUID");
	commonUtil.fileDownload(uuid);
}

var $fileUploadLayer;
function showFileUpload(){
	var loader = $('<div class="contentLayoutSave"></div>').appendTo('body');
	
	loader.stop().animate({
		top : '0px'
	}, 30, function() {
	});
	
	if($fileUploadLayer == undefined){
		$fileUploadLayer = $("#fileUploadLayer");
	}
	$fileUploadLayer.find("#"+configData.DATA_FILE_UPLOAD_FILENAME_ID).text("");
	$fileUploadLayer.find("[name=fileUp]").val("");
	$fileUploadLayer.show();
}

function hideFileUpload(){
	
	var loader = $('.contentLayoutSave');

	loader.stop().animate({
		top : '100%'
	}, 30, function() {
		loader.remove();
	});
	
	$fileUploadLayer.hide();
}

/*function setTopSize(height){
	topGridHeight = height+"px";
	$('.bottomSect.top').css("height",height+"px");
	$('.bottomSect.bottom').css("top",(height+20)+"px");	
}*/
function setTopSize(height,topGridSize){
	topGridHeight = height+"px";
	
	if(topGridSize == undefined || topGridSize == null || topGridSize == ""){
		topGridSize = 0;
	}
	
	chgTopGridHeigth = topGridSize;
	
	$('.bottomSect.top').css("height",height+"px");
	$('.bottomSect.bottom').css("top",((height+topGridSize)+20)+"px");	
}

//configData.MENU_ID = top.getMenuId();
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

/*function changeMiddleHeight($dragObj, ui){
	var height = parseInt(topGridHeight.substring(0, topGridHeight.length-2));
	height = height + ui.position.top;
	//setTopSize(height);
	$('.bottomSect.top').css("height",height+"px");
	$('.bottomSect.bottom').css("top",(height+20)+"px");
}*/

function changeMiddleHeight($dragObj, ui){
	var height = parseInt(topGridHeight.substring(0, topGridHeight.length-2));
	height = height + ui.position.top;
	//setTopSize(height);
	$('.bottomSect.top').css("height",height+"px");
	$('.bottomSect.bottom').css("top",((height + chgTopGridHeigth)+20)+"px");
}

function setMiddleHeight($dragObj, ui){
	var height = parseInt(topGridHeight.substring(0, topGridHeight.length-2));
	height = height + ui.position.top;
	var bottomHeight = commonUtil.getCssNum($('.bottomSect.bottom'), "height");	
	if(height < 100){
		setTopSize(100,chgTopGridHeigth);
	}else if((bottomHeight-100)<ui.position.top){
		setTopSize(height-100,chgTopGridHeigth);
	}else{
		topGridHeight = height+"px";
	}
	
	gridList.scrollResize();
}

var $showPop;
var $searchPop;
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
	
	topGridHeight = $('.bottomSect.top').css("height");
	
	$contentLoading = jQuery("#contentLoading");
	$showPop = jQuery("#showPop");
	$searchPop = jQuery('.searchPop');
	if($showPop.length > 0){
		$showPop.attr("title", "[alt+"+site.COMMON_KEY_EVENT_SEARCH_POP+"]");
		$searchPop.find(".closer").attr("title", "[alt+"+site.COMMON_KEY_EVENT_SEARCH_POP+"]");
	}
	
	//uiList.autocompleteSet();
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
		editedClassType : false,
		addType : true,
		rowDblClickEventFn : "inputList.rangeRowClick"
	});
		
	gridList.setGrid({
		id : configData.INPUT_RANGE_RANGEGRID_ID,
		editable : false,
		sortType : false,
		viewFormat : true,
		autoNewRowType : true,
		editedClassType : false,
		addType : true,
		rowDblClickEventFn : "inputList.rangeRowClick"
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
		copyEventType : false,
		rowClickEventFn : "gridList.subTotalRowClick"
	});
	
	gridList.setGrid({
		id : configData.GRID_SUBTOTAL_DATA_ID,
		editable : false,
		sortType : false,
		copyEventType : false,
		rowClickEventFn : "gridList.subTotalRowClick"
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
			}else if(code == site.COMMON_KEY_EVENT_SEARCH_POP_CODE){
				if($searchPop.is(":visible")){
					$searchPop.find(".closer").trigger("click");
				}else{
					$showPop.trigger("click");
				}
			}
			
			var codeChar=String.fromCharCode(code);
			
			if(uiList.shortKeyBtnMap.containsKey(codeChar)){
				uiList.shortKeyBtnMap.get(codeChar).trigger("click");
			}
			
			//event fn
			if(commonUtil.checkFn("commonShortKeyEvent")){
				commonShortKeyEvent(code, codeChar);
			}
			
			gridList.shortKeyDown($obj, code);
		}
	});
	
	jQuery("body").find("input :first").focus();
});

$(window).resize(function(){
    gridList.scrollResize();
    //gridList.reloadAll();
});