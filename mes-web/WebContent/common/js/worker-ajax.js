var httpRequest;
var opts;

function bigDataStart(){
	httpRequest = new XMLHttpRequest();
	httpRequest.onreadystatechange = handleResponse;	
	httpRequest.open("POST", opts.url);
	httpRequest.send(opts.param);
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