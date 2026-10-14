DataRequestOptions = function() {
	this.name="DataRequest";
	this.url="";
	this.module="";
	this.command="";
	this.param=new DataMap();
	this.gridId=null;
	this.data="";
}

DataRequest = function() {
	this.workerType = false;
	if(Browser.ie11 && Browser.win10){
		return;
	}
	if(!window.Worker){
		this.workerType = false;
	}else{
		this.workerType = true;
	}
};

DataRequest.prototype = {
	sendDataRequest : function(options) {
		commonUtil.displayLoading(true);
		
		var dataRequestOptions = new DataRequestOptions();
		
		var opts = jQuery.extend( dataRequestOptions, options);
		
		if(!opts.url){
			if(!opts.module && !opts.command){
				alert("DataRequest sendDataRequest : url error");
				return;
			}
			opts.url = "/common/"+opts.module+"/datalist/json/"+opts.command+".data";
		}
		
		if(opts.param){
			opts.param = opts.param.jsonString();
		}else{
			opts.param = "";
		}
		
		
		var dataRequest = this;
		
		if(this.workerType){
			var ajaxWorker = new Worker("/common/js/worker-ajax.js");
			
			ajaxWorker.postMessage(opts);
			ajaxWorker.onmessage = function(event) {
				var tmpMsg = event.data;
				dataRequest.setData(opts, tmpMsg);
				ajaxWorker.terminate();
			};
		}else{
			//var tmpMsg = dataRequest.getDataRequest(opts);
			//dataRequest.setData(opts, tmpMsg);
			jQuery.ajax({
				type: "post",
				url: opts.url,
				data: opts.param,
				dataType: "text",
			    success: function (text) {	    	
			    	dataRequest.setData(opts, text);  	
			    }
			});
		}
	},
	setData : function(opts, fdata) {
		commonUtil.displayLoading(false);

		if(fdata == "Exception message"){
			commonUtil.msg("System error.\nPlease contact your administer.");
			return;
		}else if(fdata.indexOf("Exception message") != -1){
			commonUtil.msg(fdata);
			return;
		}else if(fdata.indexOf("Session empty") != -1){
			commonUtil.msg("session timeout");
			window.top.location.href = "/index.jsp";
			return;
		}
		opts.data = fdata;
		
		var dataCount = gridList.viewDataStart(opts.gridId, opts.data, true);
		
		gridList.gridEventDataBindEnd(opts.gridId);
	},
	getDataRequest : function(opts) {
		httpRequest = new XMLHttpRequest();
		httpRequest.open("POST", opts.url, false);
		httpRequest.send(opts.param);
		
		return httpRequest.responseText;
	},
	toString : function() {
		return "DataRequest";
	}
};