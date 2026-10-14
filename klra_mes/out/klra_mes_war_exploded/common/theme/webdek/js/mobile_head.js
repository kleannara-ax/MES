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


var $searchArea;
$(document).ready(function(){
	$(document.body).hide();	

	$contentLoading = jQuery("#contentLoading");
	
	page.loadComponent();

	$searchArea = jQuery("#"+configData.SEARCH_AREA_ID);	
	
	$(document.body).show();
});