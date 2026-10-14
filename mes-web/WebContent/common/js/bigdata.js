BigdataOptions = function() {
	this.name="Bigdata";
	this.url="";
	this.module="";
	this.command="";
	this.viewCount=50;
	this.param=new DataMap();
	this.gridData=null;
	this.fsuccess=null;
	this.ferror=null;
	this.lsuccess=null;
	this.lerror=null;
	this.data="";
	this.colList=null;
	this.dataList=null;
}

Bigdata = function() {
	this.workerType;
	if(!window.Worker){
		//alert("Bigdata : Worker error");
		//return;
		this.workerType = false;
	}else{
		this.workerType = true;
	}
	
	//this.workerType = false;
};

Bigdata.prototype = {
	sendBigdata : function(options) {
		commonUtil.displayLoading(true);
		
		var bigDataOptions = new BigdataOptions();
		
		var opts = jQuery.extend( bigDataOptions, options);
		
		if(!opts.url){
			if(!opts.module && !opts.command){
				alert("Bigdata sendBigdata : url error");
				return;
			}
			opts.url = "/common/"+opts.module+"/asynclist/json/"+opts.command+".data";
		}
		
		var firstRow = opts.viewCount;
		if(opts.gridData){
			var gridBox = gridList.getGridBox(opts.gridData);
			firstRow = gridBox.viewRowCount;
		}
		
		opts.param.put(configData.GRID_REQUEST_VIEW_COUNT, firstRow);
		
		opts.param = opts.param.jsonString();
		
		var bigdata = this;
		
		if(this.workerType){
			var ajaxWorker = new Worker("/common/js/worker-ajax.js");
			
			ajaxWorker.postMessage(opts);
			ajaxWorker.onmessage = function(event) {
				var tmpMsg = event.data;
				bigdata.setFirstdata(opts, tmpMsg);
				ajaxWorker.terminate();
			};
		}else{
			var tmpMsg = bigdata.getBigData(opts);
			bigdata.setFirstdata(opts, tmpMsg);
		}
	},
	setFirstdata : function(opts, fdata) {
		//var key = fdata.substring(0,36);	
		if(!fdata){
			fdata = "END ";
		}
		
		var key = fdata.substring(0,fdata.indexOf(" "));
		
		opts.data = fdata.substring(fdata.indexOf(" ")+1);
		
		var startType = false;
		
		if(key == "END" || !opts.data){
			startType = true;
		}
		
		var dataCount = gridList.viewDataStart(opts.gridData, opts.data, startType);
		
		if(dataCount == 0 || key == "END" || !opts.data){
			
			commonUtil.displayLoading(false);
			
			gridList.gridEventDataBindEnd(opts.gridData);			
			return;
		}

		var param = new DataMap();
		param.put("DATA_KEY", key);
		opts.param = param.jsonString();
		
		var bigdata = this;
		
		opts.url = "/common/Common/asynclist/json/next.data";
		
		if(this.workerType){
			var ajaxWorker = new Worker("/common/js/worker-ajax.js");
			//opts.url = "/common/Common/asynclist/json/next.data";
			ajaxWorker.postMessage(opts);
			ajaxWorker.onmessage = function(event) {
				var tmpMsg = event.data;
				bigdata.setLastdata(opts, tmpMsg);
				ajaxWorker.terminate();
			};
		}else{
			var tmpMsg = bigdata.getBigData(opts);
			bigdata.setLastdata(opts, tmpMsg);
		}
	},
	setLastdata : function(opts, fdata) {
		//gridList.setData(opts.gridData, fdata);
		gridList.appendDataList(opts.gridData, fdata);
		
		commonUtil.displayLoading(false);
		gridList.gridEventDataBindEnd(opts.gridData);
	},
	getBigData : function(opts) {
		httpRequest = new XMLHttpRequest();
		httpRequest.open("POST", opts.url, false);
		httpRequest.send(opts.param);
		
		return httpRequest.responseText;
	},
	toString : function() {
		return "Bigdata";
	}
};