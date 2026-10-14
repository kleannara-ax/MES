var contentLoading;

//로딩 열기
function loadingOpen() {
	
	contentLoading.style.display = "inline";
}

// 로딩 닫기
function loadingClose() {
	
	contentLoading.style.display = "none";
}

onmessage = function(event){
	opts = event.data;
	if(opts == "S" ){
		contentLoading = document.getElementById("contentLoading");
	}else if(opts == "O" ){
		loadingOpen();
	}else if(opts == "C" ){
		loadingClose();
	}
};