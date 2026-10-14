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
	$contentLoading.removeClass("none");
	if(!$(".search_inner .add").hasClass("none")){
		$(".search_inner .add").addClass("none");
	}
}

// 로딩 닫기
function loadingClose() {
	$contentLoading.addClass("none");
}

configData.MENU_ID;
if(commonUtil.checkFn("top.getMenuId")){
	configData.MENU_ID = top.getMenuId();
}else if(commonUtil.checkFn("getMenuId")){
	configData.MENU_ID = getMenuId();
}

commonUtil.consoleMsg(configData.MENU_ID);

var $layerBack;
var $columnSaveLayer;
var $gridBodyMenuLayer;
var $gridHeadMenuLayer;
var $multiInputLayer;
var $clipboardLayer;
var $clipboardLayerBtn;
var $clipboardLayerDesc;
var $clipboardLayerText;
var $excelUploadLayer;
var $fileUploadLayer;
var $mFileUploadLayer;
var $subTotalLayer;
var $rangeLayer;
var $LayerPop;
var $filterLayer;

var $searchArea;
$(document).ready(function(){
	$(document.body).hide();	

	$layerBack = $("#layerBack");

	$gridBodyMenuLayer = $("#gridBodyMenuLayer");
	$gridHeadMenuLayer = $("#gridHeadMenuLayer");
	$gridBodyMenuLayer.contextmenu(function(event) {
		return false;
	});
	$gridHeadMenuLayer.contextmenu(function(event) {
		return false;
	});

	$contentLoading = jQuery("#contentLoading");
	
	page.loadComponent();

	gridList.setGrid({
		id : configData.GRID_LAYOUT_SAVE_INVISIBLE_ID,
		editable : false,
		sortType : false,
		copyEventType : false,
		gridHeadType : false,
		contextMenuType : false,
		rowDblClickEventFn : "layoutSave.layoutRowDblclick"
	});
	gridList.appendCols(configData.GRID_LAYOUT_SAVE_INVISIBLE_ID,["COLTEXT"]);
		
	gridList.setGrid({
		id : configData.GRID_LAYOUT_SAVE_VISIBLE_ID,
		editable : false,
		sortType : false,
		copyEventType : false,
		gridHeadType : false,
		contextMenuType : false,
		rowDblClickEventFn : "layoutSave.layoutRowDblclick"
	});
	gridList.appendCols(configData.GRID_LAYOUT_SAVE_VISIBLE_ID,["COLTEXT","COLWIDTH"]);
	
	gridList.setGrid({
		id : configData.INPUT_RANGE_SINGLEGRID_ID,
		editable : false,
		sortType : false,
		viewFormat : true,
		autoNewRowType : true,
		enterKeyType : "R",
		editedClassType : false,
		gridHeadType : false,
		contextMenuType : false,
		addType : true,
		rowDblClickEventFn : "inputList.rangeRowClick"
	});
	gridList.appendCols(configData.INPUT_RANGE_SINGLEGRID_ID,["DATA"]);
		
	gridList.setGrid({
		id : configData.INPUT_RANGE_RANGEGRID_ID,
		editable : false,
		sortType : false,
		viewFormat : true,
		autoNewRowType : true,
		editedClassType : false,
		gridHeadType : false,
		contextMenuType : false,
		addType : true,
		rowDblClickEventFn : "inputList.rangeRowClick"
	});
	gridList.appendCols(configData.INPUT_RANGE_RANGEGRID_ID,["FROM","TO"]);
	
	gridList.setGrid({
		id : configData.GRID_FILTER_COL_ID,
		editable : false,
		sortType : false,
		copyEventType : false,
		firstRowFocusType : false,
		rowClickEventFn : "gridList.filterColRowClick"
	});
	gridList.appendCols(configData.GRID_FILTER_COL_ID,["rowcheck","COLTEXT"]);
	
	gridList.setGrid({
		id : configData.GRID_FILTER_DATA_ID,
		editable : false,
		sortType : false,
		copyEventType : false,
		firstRowFocusType : false,
		rowClickEventFn : "gridList.filterDataRowClick"
	});
	gridList.appendCols(configData.GRID_FILTER_DATA_ID,["rowcheck","COLTEXT"]);
	
	gridList.setGrid({
		id : configData.GRID_SUBTOTAL_COL_ID,
		sortType : false,
		copyEventType : false,
		gridHeadType : false,
		contextMenuType : false
	});
	gridList.appendCols(configData.GRID_SUBTOTAL_COL_ID,["rowcheck","COLTEXT"]);
		
	gridList.setGrid({
		id : configData.GRID_SUBTOTAL_DATA_ID,
		sortType : false,
		copyEventType : false,
		gridHeadType : false,
		contextMenuType : false
	});
	gridList.appendCols(configData.GRID_SUBTOTAL_DATA_ID,["rowcheck","COLTEXT"]);

	jQuery("body").click(function(event){
		hideContextMenu();
	});
	
	$searchArea = jQuery("#"+configData.SEARCH_AREA_ID);
	
	searchMoreInit();
	initLayoutContent();
	
	jQuery("body").click(function(event){
		hideContextMenu();
	});
	
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
			if(code == site.COMMON_KEY_EVENT_SEARCH_CODE){
				$obj.blur();
				if(commonUtil.checkFn("searchList")){
					searchList();
				}
			}else if(code == site.COMMON_KEY_EVENT_SAVE_CODE){
				$obj.blur();
				if(commonUtil.checkFn("saveData")){
					saveData();
				}
			}else if(code == site.COMMON_KEY_EVENT_CREATE_CODE){
				$obj.blur();
				if(commonUtil.checkFn("createData")){
					createData();
				}
			}else if(code == site.COMMON_KEY_EVENT_SEARCH_POP_CODE){
				$(".btn_more").trigger("click");
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
	
	$(".btn_more").click(function() {
		if($(".search_inner .add").hasClass("none")){
			$(".search_inner .add").removeClass("none");
		}
		else {
			$(".search_inner .add").addClass("none");
		}
		return false;
	});
	
	if($searchArea.length > 0){
		$searchArea.find(":text").keydown(function(event){
			var $obj = $(event.target);
			var code = event.keyCode;
			if(code == 13 && commonUtil.checkFn("searchList")){
				$obj.trigger("change");
				searchList();
			}
		});
	}
	
//	setSizeDraggableEvent();
	fullSizeEvent();
	
	$(document.body).show();
});

var $fullSizeBtn;
var $fullSizeSelectBtn;
var $fullSizeSelectContent;
var fullSizeType = false;
var fullSizeBodyHeight;
var fullSizeBodyWidth;
var fullSizeOrgHeight;
var fullSizeOrgWidth;
var scrollHeight ;
var SelectContent
var fullSizeHGap;
var fullSizeWGap;
var contentWrapH;
var contentWrapW;
function fullSizeEvent(){
	$sizeDragBtn = jQuery(".btn_bigger");
	$sizeDragBtn.attr("title",uiList.getLabel("STN_SIZE_FULL"));
	$sizeDragBtn.click(function(event){
		$fullSizeSelectBtn = jQuery(event.target);
		fullSizeOn();
	});
}

function fullSizeOn(){
	$fullSizeSelectContent = $fullSizeSelectBtn.parents(".content_layout");	
	if(fullSizeType){

		$fullSizeSelectContent.removeClass("fullSizeLayoutInner");
		$fullSizeSelectContent.removeClass("fullSizeLayout");
		$fullSizeSelectContent.siblings().show();
		$(".content-horizontal-wrap").show();
		$(".content_serch").show();
		$(".content_inner>.btn_wrap").show();
		
		fullSizeType = false;
		$fullSizeSelectBtn.attr("title",uiList.getLabel("STN_SIZE_FULL"));
	}else{
		$fullSizeSelectContent.addClass("fullSizeLayout");
		if($fullSizeSelectContent.length > 1){
			$fullSizeSelectContent.eq(0).removeClass("fullSizeLayout").addClass("fullSizeLayoutInner");
		}
		$fullSizeSelectContent.siblings().hide();
		$(".content-horizontal-wrap").hide();
		$(".content_serch").hide();
		$(".content_inner>.btn_wrap").hide();
		$fullSizeSelectBtn.parents(".content-horizontal-wrap").show();
		
		fullSizeType = true;
		$fullSizeSelectBtn.attr("title",uiList.getLabel("STN_SIZE_ORG"));
	}
	
	/* 2020.05.19 김호영 - 지쏀맵 사용 id 존재시 크기 조절 함수 호출 */
	if($("#map").length > 0){
		map.updateSize();
	}
	
	gridList.scrollResize();
	
}

var $sizeDragBtn;
var $sizeDragBtnObj;
var sizeDragBtnType;
var $sizeDragBeforeObj;
var $sizeDragAfterObj;
var sizeDragBeforeMinCheck;
var sizeDragAfterMinCheck;
var sizeDragYmin = 150;
var sizeDragLastPosition = 0;
function setSizeDraggableEvent(){
	$sizeDragBtn = jQuery(".handler_wrap");
	
	if($sizeDragBtn.length > 0){
		/*
		for(var i=0;i<$sizeDragBtn.length;i++){
			$sizeDragBtn.eq(i).attr("sizeDragBtnNum", i);
		}
		*/	
	
		$sizeDragBtn.draggable({
			axis: "y",
			cursor: "n-resize",
			helper: "none",
			containment : "parent",
			//revert: true,
			start: function(event, ui) {
				var $obj = jQuery(event.target);
				//$obj.text(ui.position.left);
				sizeDragBtnType = "V";
				startSizeDraggableEvent($obj, ui);
			},
			drag: function(event, ui) {
				var $obj = jQuery(event.target);
				//changeSizeDraggableEvent($obj, ui);
				//$obj.css("top", "0px");
			},
			stop: function(event, ui) {
				var $obj = jQuery(event.target);

				stopSizeDraggableEvent($obj, ui);
				$obj.css("top", "0px");
			}
		});
	}
	
	$sizeDragBtn = jQuery(".handlerH_wrap");
	if($sizeDragBtn.length > 0){
		/*
		for(var i=0;i<$sizeDragBtn.length;i++){
			$sizeDragBtn.eq(i).attr("sizeDragBtnNum", i);
		}
		*/	
	
		$sizeDragBtn.draggable({
			axis: "x",
			cursor: "n-resize",
			helper: "none",
			containment : "parent",
			//revert: true,
			start: function(event, ui) {
				var $obj = jQuery(event.target);
				//$obj.text(ui.position.left);
				sizeDragBtnType = "V";
				startHSizeDraggableEvent($obj, ui);
			},
			drag: function(event, ui) {
				var $obj = jQuery(event.target);
				//changeSizeDraggableEvent($obj, ui);
				//$obj.css("left", "0px");
			},
			stop: function(event, ui) {
				var $obj = jQuery(event.target);

				stopHSizeDraggableEvent($obj, ui);
				$obj.css("left", "0px");				
			}
		});
	}
}

function startSizeDraggableEvent($dragObj, ui){
	$sizeDragBtnObj = $dragObj;
	$sizeDragBeforeObj = $sizeDragBtnObj.prev();
	$sizeDragAfterObj = $sizeDragBtnObj.next();
	sizeDragLastPosition = 0;	
}

function changeSizeDraggableEvent($dragObj, ui){
	console.log("changeSizeDraggableEvent 1 "+ui.position.top);
	var tmpMTop = (ui.position.top-sizeDragLastPosition);
	console.log("changeSizeDraggableEvent 2 "+tmpMTop);
	sizeDragLastPosition = ui.position.top;
	console.log("changeSizeDraggableEvent 3 "+sizeDragLastPosition);
	if(sizeDragBtnType == "V"){
		sizeDragBeforeMinCheck = commonUtil.getCssNum($sizeDragBeforeObj, "height");
		sizeDragAfterMinCheck = commonUtil.getCssNum($sizeDragAfterObj, "height");
		var tmpHeight = sizeDragBeforeMinCheck + tmpMTop;
		if(tmpHeight < sizeDragYmin){
			tmpMTop += (sizeDragYmin - tmpHeight);
		}
		tmpHeight = sizeDragAfterMinCheck - tmpMTop;
		if(tmpHeight < sizeDragYmin){
			tmpMTop -= (sizeDragYmin - tmpHeight);
		}
		
		tmpHeight = commonUtil.getCssNum($sizeDragBeforeObj, "height");
		console.log(tmpHeight);
		tmpHeight += tmpMTop;
		$sizeDragBeforeObj.css("height", tmpHeight+"px");
		$sizeDragBeforeObj.find(".scroll").each(function(i, findElement){
			var $tmpObj = jQuery(findElement);
			tmpHeight = commonUtil.getCssNum($tmpObj, "height");
			tmpHeight += tmpMTop;
			$tmpObj.css("height", tmpHeight+"px");
		});
		
		tmpHeight = commonUtil.getCssNum($sizeDragAfterObj, "height");
		console.log(tmpHeight);
		tmpHeight -= tmpMTop;
		$sizeDragAfterObj.css("height", tmpHeight+"px");		
		$sizeDragAfterObj.find(".scroll").each(function(i, findElement){
			var $tmpObj = jQuery(findElement);
			tmpHeight = commonUtil.getCssNum($tmpObj, "height");
			tmpHeight -= tmpMTop;
			$tmpObj.css("height", tmpHeight+"px");
		});
	}
}

function stopSizeDraggableEvent($dragObj, ui){
	console.log(ui.position.top);
	var tmpMTop = ui.position.top;
	if(sizeDragBtnType == "V"){		
		sizeDragBeforeMinCheck = commonUtil.getCssNum($sizeDragBeforeObj, "height");
		sizeDragAfterMinCheck = commonUtil.getCssNum($sizeDragAfterObj, "height");
		var tmpHeight = sizeDragBeforeMinCheck + tmpMTop;
		if(tmpHeight < sizeDragYmin){
			tmpMTop += (sizeDragYmin - tmpHeight);
		}
		tmpHeight = sizeDragAfterMinCheck - tmpMTop;
		if(tmpHeight < sizeDragYmin){
			tmpMTop -= (sizeDragYmin - tmpHeight);
		}
		
		tmpHeight = commonUtil.getCssNum($sizeDragBeforeObj, "height");
		tmpHeight += tmpMTop;
		$sizeDragBeforeObj.css("height", tmpHeight+"px");
		$sizeDragBeforeObj.find(".scroll").each(function(i, findElement){
			var $tmpObj = jQuery(findElement);
			tmpHeight = commonUtil.getCssNum($tmpObj, "height");
			tmpHeight += tmpMTop;
			$tmpObj.css("height", tmpHeight+"px");
		});
		$sizeDragBeforeObj.find(".content_layout").each(function(i, findElement){
			var $tmpObj = jQuery(findElement);
			tmpHeight = commonUtil.getCssNum($tmpObj, "height");
			tmpHeight += tmpMTop;
			$tmpObj.css("height", tmpHeight+"px");
		});
		
		tmpHeight = commonUtil.getCssNum($sizeDragAfterObj, "height");
		tmpHeight -= tmpMTop;
		$sizeDragAfterObj.css("height", tmpHeight+"px");		
		$sizeDragAfterObj.find(".scroll").each(function(i, findElement){
			var $tmpObj = jQuery(findElement);
			tmpHeight = commonUtil.getCssNum($tmpObj, "height");
			tmpHeight -= tmpMTop;
			$tmpObj.css("height", tmpHeight+"px");
		});
		$sizeDragAfterObj.find(".content_layout").each(function(i, findElement){
			var $tmpObj = jQuery(findElement);
			tmpHeight = commonUtil.getCssNum($tmpObj, "height");
			tmpHeight -= tmpMTop;
			$tmpObj.css("height", tmpHeight+"px");
		});
		
		if(tmpMTop > 0){
			$sizeDragBeforeObj.find(".content_layout").find(".handlerH_wrap").css("margin-right","");
			$sizeDragAfterObj.find(".content_layout").find(".handlerH_wrap").css("margin-right","-15px");
		}else{
			$sizeDragBeforeObj.find(".content_layout").find(".handlerH_wrap").css("margin-right","-15px");
			$sizeDragAfterObj.find(".content_layout").find(".handlerH_wrap").css("margin-right","");
		}
	}
}

function startHSizeDraggableEvent($dragObj, ui){
	$sizeDragBtnObj = $dragObj;
	$sizeDragBeforeObj = $sizeDragBtnObj.prev();
	$sizeDragAfterObj = $sizeDragBtnObj.next();
	sizeDragLastPosition = ui.position.left;
}

function stopHSizeDraggableEvent($dragObj, ui){
	console.log(ui.position.left);
	var tmpMLeft = ui.position.left - sizeDragLastPosition;
	if(sizeDragBtnType == "V"){
		if(tmpMLeft > 0){
			$dragObj.css("margin-right","-15px");
		}else{
			$dragObj.css("margin-right","");
		}
		sizeDragBeforeMinCheck = commonUtil.getCssNum($sizeDragBeforeObj, "width");
		sizeDragAfterMinCheck = commonUtil.getCssNum($sizeDragAfterObj, "width");
		var tmpWidth = sizeDragBeforeMinCheck + tmpMLeft;
		if(tmpWidth < sizeDragYmin){
			tmpMLeft += (sizeDragYmin - tmpWidth);
		}
		tmpWidth = sizeDragAfterMinCheck - tmpMLeft;
		if(tmpWidth < sizeDragYmin){
			tmpMLeft -= (sizeDragYmin - tmpWidth);
		}
		
		tmpWidth = commonUtil.getCssNum($sizeDragBeforeObj, "width");
		tmpWidth += tmpMLeft;		
		$sizeDragBeforeObj.css("width", tmpWidth+"px");
		
		tmpWidth = commonUtil.getCssNum($sizeDragAfterObj, "width");
		tmpWidth -= tmpMLeft;
		$sizeDragAfterObj.css("width", tmpWidth+"px");
		
		$sizeDragAfterObj.find(".content_layout").each(function(i, findElement){
			var $tmpObj = jQuery(findElement);
			tmpWidth = commonUtil.getCssNum($tmpObj, "width");
			tmpWidth -= tmpMLeft;
			$tmpObj.css("width", tmpWidth+"px");
		});
	}
}

var buttomAutoResize = false;

var bodyHeight;
var bodyWidth;
var contentWrapClass = "content_inner";
var gridWrapContentClass = "content_layout";
var gridHorizontalWrapContentClass = "content-horizontal-wrap";
var $gridHorizontalWrapContentChilds;
var gridHorizontalWrapContentChildsPadding = 10;
var contentWrapPadding = 60;
var contentSearchPadding = 20;
var gridResizeHeight = 10;
var $contentWrap;
var $contentList;
var $lastGridLayout;
var $lastGridScroll;
var lastSearchContentHeight = 0;
var lastGridContentHeight;
var lastGridContentHeightMin = 300;
var lastGridLayoutPadding = 0;
var gridLayoutPadding = 121;
var fixLayoutHeightSum = 0;
var gridLayoutList = new Array();
var gridLayoutPaddingList = new Array();
var contentVerticalWrapClass = "content-vertical-wrap";
var contentVerticalWrapClassList = new Array();
var contentVerticalWrapClassChildList = new Array();
var contentVerticalWrapClassChildRateList = new Array();
var contentVerticalWrapPadding = 40;
function initLayoutContent(){
	return;
	if(!buttomAutoResize){
		return;
	}
	bodyHeight = commonUtil.getCssNum($("body"), "height");
	bodyWidth = commonUtil.getCssNum($("body"), "width");
	
	$contentWrap = jQuery("."+contentWrapClass);
	$contentList = $contentWrap.children();
	
	for(var i=0;i<$contentList.length;i++){
		if($contentList.eq(i).hasClass(gridWrapContentClass)){
			$lastGridLayout = $contentList.eq(i);
			lastGridContentHeight = commonUtil.getCssNum($lastGridLayout, "height");
			lastGridLayoutPadding = gridPaddingCheck($lastGridLayout);
			$lastGridScroll = $lastGridLayout.find(".scroll");
			$lastGridScroll.css("height", (lastGridContentHeight - lastGridLayoutPadding - gridLayoutPadding)+"px");
			gridLayoutList.push($contentList.eq(i));
			gridLayoutPaddingList.push(lastGridLayoutPadding);
		}else if($contentList.eq(i).hasClass(gridHorizontalWrapContentClass)){
			$lastGridLayout = $contentList.eq(i);
			lastGridContentHeight = commonUtil.getCssNum($lastGridLayout, "height");
			lastGridLayoutPadding = gridPaddingCheck($lastGridLayout);
			$lastGridScroll = $lastGridLayout.find(".scroll");
			$lastGridScroll.css("height", (lastGridContentHeight - lastGridLayoutPadding - gridLayoutPadding)+"px");
			gridLayoutList.push($contentList.eq(i));
			gridLayoutPaddingList.push(lastGridLayoutPadding);
			
			$gridHorizontalWrapContentChilds = $lastGridLayout.find("."+gridWrapContentClass);
		}else if($contentList.eq(i).hasClass("content_serch")){
			fixLayoutHeightSum += contentSearchPadding;
		}
		var $contentVertical = $contentList.eq(i).find("."+contentVerticalWrapClass);
		if($contentVertical.length > 0){
			contentVerticalWrapClassList.push($contentVertical);
			var $contentWrapList = $contentVertical.find("."+gridWrapContentClass);
			contentVerticalWrapClassChildList.push($contentWrapList);
			
			var childRateList = new Array();
			if($contentWrapList.length > 0){
				var childHeightList = new Array();
				var tmpHeight = 0;
				var tmpHeightSum = 0;

				for(var j=0;j<$contentWrapList.length;j++){
					tmpHeight = commonUtil.getCssNum($contentWrapList.eq(j), "height");
					tmpHeightSum += tmpHeight;
					childHeightList.push(tmpHeight);
				}
				
				var tmpRate;
				for(var j=0;j<childHeightList.length;j++){
					tmpRate = parseInt(parseFloat(childHeightList[j])/parseFloat(tmpHeightSum)*100);
					childRateList.push(tmpRate);
				}
			}
			contentVerticalWrapClassChildRateList.push(childRateList);
		}
		fixLayoutHeightSum += commonUtil.getCssNum($contentList.eq(i), "height");
	}
	
	if(!lastGridContentHeight){
		return;
	}	
	
	fixLayoutHeightSum -= lastGridContentHeight;
	fixLayoutHeightSum += contentWrapPadding;
	if(gridLayoutList.length > 1){
		fixLayoutHeightSum += (gridLayoutList.length -1) * gridResizeHeight;
	}

	if($searchArea.length){
		lastSearchContentHeight = commonUtil.getCssNum($searchArea, "height");
	}
	
	lastGridContentResize();
}

function gridPaddingCheck($tmpGridLayoutContent){
	return 0;
}

function lastGridContentResize(){
	if(!buttomAutoResize){
		return;
	}
	if(!lastGridContentHeight){
		return;
	}
	bodyHeight = commonUtil.getCssNum($("body"), "height");
	bodyWidth = commonUtil.getCssNum($("body"), "width");
	
	$contentWrap.css("height", (bodyHeight-contentWrapPadding)+"px");
	lastGridContentHeight = bodyHeight - fixLayoutHeightSum;
	
	var tmpSheight = commonUtil.getCssNum($searchArea, "height");
	
	if(lastSearchContentHeight < tmpSheight){
		lastGridContentHeight -= (tmpSheight - lastSearchContentHeight);
	}
	
	if(lastGridContentHeight < lastGridContentHeightMin){
		lastGridContentHeight = lastGridContentHeightMin;
	}
	$lastGridLayout.css("height", lastGridContentHeight+"px");
	if($lastGridLayout.hasClass(gridHorizontalWrapContentClass)){
		$gridHorizontalWrapContentChilds.css("height", (lastGridContentHeight-gridHorizontalWrapContentChildsPadding)+"px");
		$lastGridScroll.css("height", (lastGridContentHeight - lastGridLayoutPadding - gridLayoutPadding-gridHorizontalWrapContentChildsPadding)+"px");
	}else{
		$lastGridScroll.css("height", (lastGridContentHeight - lastGridLayoutPadding - gridLayoutPadding)+"px");
	}
	
	for(var i=0;i<contentVerticalWrapClassList.length;i++){
		var $contentWrapList = contentVerticalWrapClassChildList[i];
		var rateList = contentVerticalWrapClassChildRateList[i];
		var tmpHeight;
		var tmpHeightSum = 0;
		for(var j=0;j<$contentWrapList.length-1;j++){
			tmpHeight = parseInt(lastGridContentHeight * rateList[j] / 100)
			tmpHeightSum += tmpHeight + contentVerticalWrapPadding;
			$contentWrapList.eq(j).css("height", tmpHeight);
			$contentWrapList.eq(j).find(".scroll").css("height", (tmpHeight - lastGridLayoutPadding - gridLayoutPadding));
		}
		tmpHeight = lastGridContentHeight - tmpHeightSum;
		$contentWrapList.eq($contentWrapList.length-1).css("height", tmpHeight);
		$contentWrapList.eq($contentWrapList.length-1).find(".scroll").css("height", (tmpHeight - lastGridLayoutPadding - gridLayoutPadding));
	}
	
	if(lastSearchContentHeight){
		lastSearchContentHeight = commonUtil.getCssNum($searchArea, "height");
	}
}

function showLayoutSave(){
	$layerBack.show();
	if($columnSaveLayer == undefined){
		$columnSaveLayer = $("#columnSaveLayer");
	}
	$columnSaveLayer.show();
}

function hideLayoutSave(){
	$columnSaveLayer.hide();
	$layerBack.hide();
}

function rangePop() {
	$layerBack.show();
	if($rangeLayer == undefined){
		$rangeLayer = $("#rangeLayer");
	}
	$rangeLayer.show();
}

function rangePopClose() {
	$rangeLayer.hide();
	$layerBack.hide();
}

function multiInputPop() {
	$layerBack.show();
	if($multiInputLayer == undefined){
		$multiInputLayer = $("#multiInputLayer");
	}
	$multiInputLayer.show();
}

function multiInputClose() {
	$multiInputLayer.hide();
	$layerBack.hide();
}

function showClipSave(){
	$layerBack.show();
	if($clipboardLayer == undefined){
		$clipboardLayer = $("#clipboardLayer");
		$clipboardLayerBtn = $("#clipboardLayerBtn");
		$clipboardLayerDesc = $("#clipboardLayerDesc")
		$clipboardLayerText = $("#clipboardLayerText");
	}
	$clipboardLayerBtn.show();
	$clipboardLayerDesc.hide();
	$clipboardLayer.show();	
}

function hideClipSave(){
	$clipboardLayer.hide();
	$layerBack.hide();
}

function showClipCopy(){
	$layerBack.show();
	if($clipboardLayer == undefined){
		$clipboardLayer = $("#clipboardLayer");
		$clipboardLayerBtn = $("#clipboardLayerBtn");
		$clipboardLayerDesc = $("#clipboardLayerDesc")
		$clipboardLayerText = $("#clipboardLayerText");
	}
	$clipboardLayerBtn.hide();
	$clipboardLayerDesc.show();
	$clipboardLayer.show();
}

function showExcelUpload(){
	$layerBack.show();
	if($excelUploadLayer == undefined){
		$excelUploadLayer = $("#excelUploadLayer");
	}
	$excelUploadLayer.show();
}

function hideExcelUpload(){
	$excelUploadLayer.hide();
	$layerBack.hide();
}

function showGridSubTotal(){
	$layerBack.show();
	if($subTotalLayer == undefined){
		$subTotalLayer = $("#subTotalLayer");
	}
	$subTotalLayer.show();
}

function hideGridSubTotal(){
	$subTotalLayer.hide();
	$layerBack.hide();
}


function showGridFilter(){
	$layerBack.show();
	if($filterLayer == undefined){
		$filterLayer = $("#filterLayer");
	}
	$filterLayer.show();
}

function hideGridFilter(){
	$filterLayer.hide();
	$layerBack.hide();
}

var fileUploadLayer_view = "<span class='fileNameView' onClick='downloadMFileRow(this)'></span>";
function showFileUpload(extType, fileData){
	if($fileUploadLayer == undefined){
		$fileUploadLayer = $("#fileUploadLayer");
	}
	if(extType == undefined){
		extType = "all";
	}
	$fileUploadLayer.find("#"+configData.DATA_FILE_UPLOAD_FILENAME_ID).text("");
	$fileUploadLayer.find("#"+configData.DATA_FILE_UPLOAD_FILEIMAGE_ID).attr("src","");
	$fileUploadLayer.find("[name=fileUp]").val("");
	$fileUploadLayer.find("[name=FILE_TYPE]").val(extType);

	$layerBack.show();
	$fileUploadLayer.show();
	
	if(fileData){
		var $tmpViewArea = $fileUploadLayer.find(".table_list01").eq(1);
		var $tmpObj = $(mFileUploadLayer_view);
		$tmpObj.filter("span").text(fileData["NAME"]).attr("UUID",fileData["UUID"]);				
		$tmpViewArea.prepend($tmpObj);
	}
}

function hideFileUpload(){
	$fileUploadLayer.find(".table_list01").eq(1).children().remove();
	$fileUploadLayer.hide();
	$layerBack.hide();
}

var mFileUploadType = "G";
var mFileUploadLayer_file = "<input type='file' validate='required'/><br/>";
var mFileUploadLayer_view = "<span class='fileNameView' onClick='downloadMFileRow(this)'></span><input type='button' class='file_dele' onClick='deleteMFileRow(this)'/><br/>";
function showMFileUpload(guuid, list, fileType, extType){
	$layerBack.show();
	if($mFileUploadLayer == undefined){
		$mFileUploadLayer = $("#mFileUploadLayer");
	}
	if(extType == undefined){
		extType = "all";
	}
	$mFileUploadLayer.find("[name=FILE_TYPE]").val(extType);
	if(fileType == "none"){
		$mFileUploadLayer.find("form").hide();
	}else{
		$mFileUploadLayer.find("form").show();
	}
	if(guuid){
		$mFileUploadLayer.find("[name=GUUID]").val(guuid);
	}
	if(list){
		var $tmpViewArea = $mFileUploadLayer.find(".table_list01").eq(1);
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
			$tmpFileList.eq(i).next().remove();
			$tmpFileList.eq(i).remove();
		}
	}	
	$mFileUploadLayer.find(".table_list01").eq(1).children().remove();
	$layerBack.hide();
}

function mFileAdd(){
	//var $tmpUploadBtn = $mFileUploadLayer.find("[type=submit]");
	var $tmpUploadBtn = $mFileUploadLayer.find(".btn_basic");
	var tmpNum = $mFileUploadLayer.find("form").find(":file").length;
	var $tmpObj = $(mFileUploadLayer_file);
	$tmpObj.filter("input").attr("name","file"+tmpNum);
	$tmpUploadBtn.before($tmpObj);
}

function deleteMFileRow(obj){
	var $obj = $(obj);
	var uuid = $obj.prev().attr("UUID");
	if(mFileUploadType == "G"){
		if(gridList.deleteMFileRow(uuid)){
			$obj.prev().remove();
			$obj.next().remove();
			$obj.remove();	
		}
	}else{
		if(!confirm(commonUtil.getMsg(configData.MSG_MASTER_DELETE_CONFIRM))){
			return false;
		}
		var param = new DataMap();
		param.put("UUID", uuid);
		var json = netUtil.sendData({
			module : "System",
			command : "SYSFILE",
			sendType : "delete",
			param : param
		});
		if(json && json.data){
			commonUtil.msgBox("삭제하였습니다.");
			$obj.prev().remove();
			$obj.next().remove();
			$obj.remove();
			//event fn
			if(commonUtil.checkFn("deleteMFileRowEndEvent")){
				deleteMFileRowEndEvent(uuid);
			}
		}
	}
}

function downloadMFileRow(obj){
	var $obj = $(obj);
	var uuid = $obj.attr("UUID");
	commonUtil.fileDownload(uuid);
}

function showGridBodyMenuLayer(clientX, clientY, gridBox){
	//$layerBack.show();
	var tmpHeight = commonUtil.getCssNum($gridBodyMenuLayer, "height");
	var tmpWidth = commonUtil.getCssNum($gridBodyMenuLayer, "width");
	var tmpClientX = clientX;
	var tmpClientY = clientY;
	/*
	if(tmpClientX > (bodyWidth - tmpWidth)){
		tmpClientX = bodyWidth - tmpWidth;
	}
	*/
	if(tmpClientY > (bodyHeight - tmpHeight - 20)){
		tmpClientY = bodyHeight - tmpHeight - 20;
	}
	$gridBodyMenuLayer.css("left",tmpClientX+"px");
	$gridBodyMenuLayer.css("top",tmpClientY+"px");
	
	if(gridBox.addType == false){
		$gridBodyMenuLayer.find(".addMenu").hide();
	}
	
	if(gridBox.deleteType == false){
		$gridBodyMenuLayer.find(".delMenu").hide();
	}
	
	if(gridBox.contextMenuColName == configData.GRID_COL_TYPE_ROWNUM){
		if(gridBox.selectedRowStart == null){
			$gridBodyMenuLayer.find(".select_srart > input").attr("value", "Select start");
		}else{
			$gridBodyMenuLayer.find(".select_srart > input").attr("value", "Select end");
		}
	}else{
		if(gridBox.selectedAreaRowStart == null){
			$gridBodyMenuLayer.find(".select_srart > input").attr("value", "Select start");
		}else{
			$gridBodyMenuLayer.find(".select_srart > input").attr("value", "Select end");
		}
	}
	
	$gridBodyMenuLayer.show();
}

function showGridHeadMenuLayer(clientX, clientY, gridBox){
	//$layerBack.show();
	var tmpHeight = commonUtil.getCssNum($gridHeadMenuLayer, "height");
	var tmpWidth = commonUtil.getCssNum($gridHeadMenuLayer, "width");
	var tmpClientX = clientX;
	var tmpClientY = clientY;
	/*
	if(tmpClientX > (bodyWidth - tmpWidth)){
		tmpClientX = bodyWidth - tmpWidth;
	}
	*/
	if(tmpClientY > (bodyHeight - tmpHeight - 20)){
		tmpClientY = bodyHeight - tmpHeight - 20;
	}
	$gridHeadMenuLayer.css("left",tmpClientX+"px");
	$gridHeadMenuLayer.css("top",tmpClientY+"px");
	
	if(gridBox.sortType == false){
		$gridHeadMenuLayer.find(".sortMenu").hide();
	}
	
	if(gridBox.columnEditType == false){
		$gridHeadMenuLayer.find(".columnEdit").hide();
	}
	
	if(gridBox.totalType == false){
		$gridHeadMenuLayer.find(".totalMenu").hide();
	}
	
	if(gridBox.selectedHeadStart == null){
		$gridHeadMenuLayer.find(".select_srart > input").attr("value", "Select start");
	}else{
		$gridHeadMenuLayer.find(".select_srart > input").attr("value", "Select end");
	}
	
	$gridHeadMenuLayer.show();
}

function hideContextMenu(){
	$gridBodyMenuLayer.hide();
	$gridHeadMenuLayer.hide();
	$gridBodyMenuLayer.find(".addMenu").show();
	$gridBodyMenuLayer.find(".delMenu").show();
	$gridHeadMenuLayer.find(".sortMenu").show();
	$gridHeadMenuLayer.find(".columnEdit").show();
	$gridHeadMenuLayer.find(".totalMenu").show();
}

$(window).resize(function(){
	searchMoreResize();
	lastGridContentResize();
    gridList.scrollResize();
    //gridList.reloadAll();
});

var searchMoreHeightDefault = 61;
var searchMoreHeight = 0;
var $searchArea;
var $searchWrap;
var $searchNextWrap;
var $searchWrapBtn;
var $searchWrapItemList;
var searchWrapItemWidthList = new Array();

function searchMoreInit(){
	$searchWrap = $(".search_wrap");
	$searchNextWrap = $(".search_next_wrap")
	$searchWrapBtn = $(".btn_tab");	
	$searchWrapItemList = $searchWrap.find("DL");
	for(var i=0;i<$searchWrapItemList.length;i++){
		searchWrapItemWidthList.push($searchWrapItemList.eq(i).find("DT").width() + $searchWrapItemList.eq(i).find("DD").width());
	}
	searchMoreResize();
}

function searchMoreResize(){
	bodyWidth = commonUtil.getCssNum($("body"), "width");
	bodyWidth -= 82;
	var searchRowCount = 1;
	var searchRowWidthSum = 0;
	//var newRowCount = false;
	if(searchWrapItemWidthList.length){
		for(var i=0;i<searchWrapItemWidthList.length;i++){
			searchRowWidthSum += searchWrapItemWidthList[i]+20;
			if(searchRowWidthSum > bodyWidth){
				searchRowCount++;
				searchRowWidthSum = searchWrapItemWidthList[i];
				//newRowCount = true;
			}else{
				//newRowCount = false;
			}
		}
	}else{
		var searchRowCount = 0;
	}
	/*
	if(newRowCount){
		searchRowCount++;
	}
	*/
	
	if(searchRowCount == 1){
		searchMoreHeight = 30;
		$searchWrapBtn.hide();
		$searchWrap.height(searchMoreHeight+"px");		
		$searchArea.css("height","70px");
		$searchNextWrap.removeClass("searchRow2").addClass("searchRow1");
	}else if(searchRowCount == 2){
		searchMoreHeight = 61;
		$searchWrap.height(searchMoreHeight+"px");
		$searchWrapBtn.hide();
		$searchArea.css("height","100px");
		$searchNextWrap.removeClass("searchRow1").addClass("searchRow2");
	}else if(searchRowCount > 2){
		searchMoreHeight = 61;
		$searchWrapBtn.show();
		$searchArea.css("height","100px");
		$searchNextWrap.removeClass("searchRow1").addClass("searchRow2");
	}else{
		$searchNextWrap.removeClass("searchRow1").removeClass("searchRow2");
	}
	
	// 2022-07-15(금요일) 안상현, 조회 버튼 클릭 후, 조회 조건 크기 축소화를 위한 RETURN
	return searchRowCount
}

function searchMore(){
	if($searchWrapBtn.hasClass("on")){
		$searchWrapBtn.removeClass("on");
		$searchWrapBtn.removeClass("on");
		$searchWrap.height(searchMoreHeight+"px");
	}else{
		$searchWrapBtn.addClass("on");
		$searchWrapBtn.addClass("on");
		$searchWrap.height("auto");
	}
}