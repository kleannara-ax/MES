var httpRequest;
var opts;

function bigDataStart(){
	httpRequest = new XMLHttpRequest();
	httpRequest.onreadystatechange = handleResponse;
	/* 2022.06.03 KKJ 챠트js와 충돌로인한 무한루프 발생 */
	if (typeof opts.url !== "undefined"){
		httpRequest.open("POST", opts.url);
		httpRequest.send(opts.param);
	}
}

function handleResponse(e){
	if(httpRequest.readyState == 4){
		if(httpRequest.status == 200){
			setData(httpRequest.responseText);
		}else{
			setData("Exception message");
		}
	}
}

function setData(tmpMsg){
	self.postMessage(tmpMsg);
}

onmessage = function(event){
	opts = event.data;
	bigDataStart();
};