var $contentLoading;

//로딩 열기
function loadingOpen() {
	if($contentLoading.length == 0){
		$contentLoading = $('<div class="contentLoading"></div>');
		jQuery('body').append($contentLoading);
	}

	$contentLoading.show();
}

// 로딩 닫기
function loadingClose() {

	$contentLoading.hide();
}

function popupOpen(url, windowName) {
	var sWidth = window.screen.availWidth;
	var sHeight = window.screen.availHeight;

	window.opener = self;
	window.open(url, windowName, "height="+sHeight+",width="+sWidth+",left=0,top=0,resizable=no");
}

$(document).ready(function(){
	
	$contentLoading = jQuery("#contentLoading");
	
	uiList.UICheck();
	inputList.setCombo();
});