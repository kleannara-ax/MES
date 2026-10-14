var labelFrame = true;
var msgFrame = true;

CommonLabel = function() {
	this.label = new DataMap();
};

CommonLabel.prototype = {
	getLabel : function(key) {
		if(this.label.containsKey(key)){
			return this.label.get(key);
		}else{
			return key;
		}
	},
	toString : function() {
		return "CommonLabel";
	}
};

var commonLabel = new CommonLabel();

CommonMessage = function() {
	this.message = new DataMap();
};

CommonMessage.prototype = {
	getMessage : function(key) {
		if(this.message.containsKey(key)){
			return this.message.get(key);
		}else{
			return key;
		}
	},
	toString : function() {
		return "CommonMessage";
	}
};

var commonMessage = new CommonMessage();

function getLabel(key){
	return commonLabel.getLabel(key);
}
function getMessage(key){
	return commonMessage.getMessage(key);
}

var $contentLoading;

function loadingOpen() {
	$contentLoading = $('<div class="contentLoading"></div>');
	jQuery('body').append($contentLoading);
	$contentLoading.show();
}

function loadingClose() {
	$contentLoading.hide();
}

function rangePop(){
	$('.search_pop_option').css('display','block');
	$('.search_pop_option .pop_wrap').css('width', ($('.search_pop_option .pop_body').width())+60);
	$('.search_pop_option .pop_wrap').css('margin-top', -(($('.search_pop_option .pop_wrap').height())/2));
	$('.search_pop_option .pop_wrap').css('margin-left', -(($('.search_pop_option .pop_body').width())/2));
}

function rangePopClose(){
	$(".search_pop_option").css('display','none');
}

function showLayoutSave(){
	$('.grid_pop_layout').css('display','block');
	$('.grid_pop_layout .pop_wrap').css('width', ($('.grid_pop_layout .pop_body').width())+60);
	$('.grid_pop_layout .pop_wrap').css('margin-top', -(($('.grid_pop_layout .pop_wrap').height())/2));
	$('.grid_pop_layout .pop_wrap').css('margin-left', -(($('.grid_pop_layout .pop_body').width())/2));
}

function hideLayoutSave(){
	$(".grid_pop_layout").css('display','none');
}

function pageOpen(obj, menuId, url){	
	var $obj = $(obj).parent();

	if(url.indexOf("?") == -1){
		url += "?"+configData.COMMON_MENU_ID_KEY+"="+menuId;
	}else{
		url += "&"+configData.COMMON_MENU_ID_KEY+"="+menuId;
	}
	
	window.location.href=url;
}

function showExcelUpload(){
	$("#layer_pop4").css('display','block');
	$("#layer_pop4 .pop_wrap").css('margin-top', -(($("#layer_pop4 .pop_wrap").height())/2));
	$("#layer_pop4 .pop_wrap").css('margin-left', -((($("#layer_pop4 .pop_body").width())+60)/2));
}

function hideExcelUpload(){
	$("#layer_pop4").css('display','none');
}

function showGridFilter(){
	$("#layer_pop4.id_filter").css('display','block');
	$("#layer_pop4.id_filter .pop_wrap").css('margin-top', -(($("#layer_pop4.id_filter .pop_wrap").height())/2));
	$("#layer_pop4.id_filter .pop_wrap").css('margin-left', -((($("#layer_pop4.id_filter .pop_body").width())+60)/2));
}

function hideGridFilter(){
	$("#layer_pop4.id_filter").css('display','none');
}

function showGridSubTotal(){
	$("#layer_pop4.id_total").css('display','block');
	$("#layer_pop4.id_total .pop_wrap").css('margin-top', -(($("#layer_pop4.id_total .pop_wrap").height())/2));
	$("#layer_pop4.id_total .pop_wrap").css('margin-left', -((($("#layer_pop4.id_total .pop_body").width())+60)/2));
}

function hideGridSubTotal(){
	$('#layer_pop4.id_total').css('display','none');
}

function hideSaveVariant(){
	$('#layer_pop4.SaveVariant_pop_layout').css('display','none');
}

function hideGetVariant(){
	$('#layer_pop4.GetVariant_pop_layout').css('display','none');
}

function pageLoadSet(){
	var $obj = $("#ledfMenuRoot").find("["+configData.COMMON_MENU_ID_KEY+"="+configData.MENU_ID+"]");
	if($obj.length == 0){
		return;
	}
	$obj.parent().addClass("on").trigger("click");
	$("#pageTitle").text($obj.text());
	$("#pageTitleSub").text($obj.text());
	
	var pList = new Array();
	var $pObj = $obj.parent().parent().parent();
	pList.push($pObj);
	
	menuPsearch($pObj, pList);
	for(var i=pList.length-1;i>0;i--){
		//pList[i].find("> a").trigger("click");
		//pList[i].find("> h2").find("> a").trigger("click");
	}
}

function menuPsearch($obj, pList){
	if($obj.parent().id == "ledfMenuRoot"){
		return;
	}
	var $pObj = $obj.parent().parent();
	
	if($pObj[0].tagName == "LI"){
		pList.push($pObj);
		menuPsearch($pObj, pList);
	}
}

$(document).ready(function(){
	$('.tabs').tabs();
	
	$contentLoading = jQuery("#contentLoading");
	
	$(document.body).hide();
	uiList.actionCheck();
	uiList.autocompleteSet();
	uiList.UICheck();
	inputList.setInput();
	inputList.setCombo();
	inputList.setSearchAreaDefaultParam();
	inputList.setAutocomplete();
	uiList.autocompleteCheck();
	
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
		rowDblClickEventFn : "inputList.rangeRowClick"
	});
		
	gridList.setGrid({
		id : configData.INPUT_RANGE_RANGEGRID_ID,
		editable : false,
		sortType : false,
		viewFormat : true,
		autoNewRowType : true,
		editedClassType : false,
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
	
	pageLoadSet();
	
	$(document.body).show();
});