NetResult = function() {
	this.url=null;
	this.sendType="list";
	this.module=null;
	this.command=null;
	this.param=null;
	this.jsonStr=null;
	this.returnParam=null;
	this.async=true;
	this.successFunction=null;
	this.failFunction=null;
	this.data=null;
	this.bindType="";
	this.bindId=null;
	this.formId=null;
	this.scrollReset=false;
	this.scrollLoading="";
}

NetResult.prototype = {	
	setData : function(json) {
		if(this.bindType == "grid"){
			if(this.sendType == "list" || this.sendType == "paging"){
				var dataLength = gridList.viewJsonData(this.bindId, json);
				gridList.gridEventDataBindEnd(this.bindId, dataLength);
				if(commonUtil.checkFn("gridListEventDataViewEnd")){
					gridListEventDataViewEnd(this.bindId, dataLength);
				}
			}else if(this.sendType == "append"){
				gridList.appendJson(this.bindId, json);
			}else if(this.sendType == "count"){
				gridList.pageBind(this.bindId, json.data);
			}else if(this.sendType == "scrollPaging"){
				/*2019.02.27 이범준 [Scroll page append 시  초기화]*/
				if(this.scrollReset){
					var gridBox = gridList.getGridBox(this.bindId);
					var tmpState = gridBox.defaultRowStatus;
					gridBox.defaultRowStatus = tmpState;
					gridBox.reset();
				}
				
				gridList.scrollPageAppend(this.bindId, json);
			}else if(this.sendType == "appendPaging"){
				gridList.appendPageAppend(this.bindId, json);
			}else if(this.sendType == "excelLoad"){
				var dataCount = gridList.viewJsonData(this.bindId, json, configData.GRID_ROW_STATE_INSERT);
				gridList.gridEventDataBindEnd(this.bindId, true);
				if(commonUtil.checkFn("gridListEventDataViewEnd")){
					gridListEventDataViewEnd(this.bindId, dataCount);
				}
				hideExcelUpload();
			}
		}else if(this.bindType == "layout"){
			if(this.sendType == "list"){
				gridList.setLayoutData(this.bindId, json);
			}else if(this.sendType == "insert"){
				//alert(this.bindId);
			}else if(this.sendType == "update"){
				//alert(this.bindId);
			}
		}else if(this.bindType == "field"){
			if(this.sendType == "map"){
				dataBind.dataNameBind(json.data, this.bindId);
			}
		}else if(this.bindType == "tree"){
			treeList.viewJsonData(this.bindId, json);
		}
	},
	toString : function() {
		return "NetResult";
	}
}

// ajax, form등의 데이터 통신을 위한 객체
NetUtil = function() {
	
};

NetUtil.prototype = {
	send : function(options) {
		commonUtil.displayLoading(true);
		var start;
		if(configData.PERFORMANCE_TRACE_ADVICE){
			start = new Date();
		}
		
		var netResult = new NetResult();
		
		var opts = jQuery.extend( netResult, options);
		
		if(!opts.url){
			if(!opts.module && !opts.command){
				alert("Bigdata sendBigdata : url error");
				return;
			}
			if(opts.sendType == "scrollPaging" || opts.sendType == "appendPaging"){
				opts.url = "/common/"+opts.module+"/paging/json/"+opts.command+".data";
			}else if(opts.sendType == "append"){
				opts.url = "/common/"+opts.module+"/list/json/"+opts.command+".data";
			}else{
				opts.url = "/common/"+opts.module+"/"+opts.sendType+"/json/"+opts.command+".data";
			}
		}
		
		commonUtil.setMenuId(opts.param);
		
		if(opts.param == null){
			opts.jsonStr = "";
		}else if(typeof opts.param == "string"){
			opts.jsonStr = opts.param;
		}else{
			opts.jsonStr = opts.param.jsonString();
		}
		
		while(opts.jsonStr.indexOf("??") != -1){
			opts.jsonStr = commonUtil.replaceAll(opts.jsonStr, "??", "?");
		}
		
		jQuery.ajax({
			type: "post",
			url: opts.url,
			async: opts.async,
			data: opts.jsonStr,
			dataType: "json",
			error: function(a, b, c){
				if(!netUtil.sessionCheck(a)){
		    		return;		    		
		    	}
				commonUtil.displayLoading(false);
				if(opts.sendType == "excelLoad"){
					commonUtil.msgBox("ERROR_EXCELLOAD");//엑셀 형식이 유효하지 않습니다.
				}else{
					if(opts.failFunction){
			        	//event fn
						if(commonUtil.checkFn(opts.failFunction)){
							eval(opts.failFunction+"(a, b, c, opts.returnParam)");
						}	        	        			        				        	
			        }else{
			        	returnData = netUtil.defaultFailFunction(a, b, c);
			        }	
				}		        	        
		    },
		    success: function (json) {
		    	opts.data = json;		    	
		    	if(opts.async){
		    		netResult.setData(json);
		    		if(opts.successFunction){
		    			if(commonUtil.checkFn(opts.successFunction)){
		    				eval(opts.successFunction+"(json, opts.returnParam)");
		    			}
		    		}
			    	commonUtil.displayLoading(false);
		    	}else{		    		
		    		commonUtil.displayLoading(false);
		    		returnData = json;
		    	}		    	
		    }
		});
		
		if(!opts.async){
			return opts.data;
		}
	},
	sendData : function(options) {
		commonUtil.displayLoading(true);
		var start;
		if(configData.PERFORMANCE_TRACE_ADVICE){
			start = new Date();
		}
		
		var defaults = new Object({
			url : null,
			sendType : "list",
	    	module : null,
			command : null,
			param : null,
			jsonStr : null,
			returnParam : null,
			failFunction : null
		});
		
		var opts = jQuery.extend( defaults, options);
		
		if(opts.module && opts.command){
			opts.url = "/common/"+opts.module+"/"+opts.sendType+"/json/"+opts.command+".data";			
		}		
		
		commonUtil.setMenuId(opts.param);
		
		if(opts.param == null){
			opts.jsonStr = "";
		}else if(typeof opts.param == "string"){
			opts.jsonStr = opts.param;
		}else{
			opts.jsonStr = opts.param.jsonString();
		}
		
		while(opts.jsonStr.indexOf("??") != -1){
			opts.jsonStr = commonUtil.replaceAll(opts.jsonStr, "??", "?");
		}

		var returnData;
		jQuery.ajax({
			type: "post",
			url: opts.url,
			async: false,
			data: opts.jsonStr,
			dataType: "json",			
			error: function(a, b, c){
				if(!netUtil.sessionCheck(a)){
		    		return;		    		
		    	}
				commonUtil.displayLoading(false);
				if(opts.failFunction){
		        	//event fn
					if(commonUtil.checkFn(opts.failFunction)){
						eval(opts.failFunction+"(a, b, c, opts.returnParam)");
					}	        	        			        				        	
		        }else{
		        	returnData = netUtil.defaultFailFunction(a, b, c);
		        }
		    },
		    success: function (json) {
		    	commonUtil.displayLoading(false);
		    	returnData = json;
		    }
		});
		//commonUtil.displayLoading(false);
		return returnData;
	},
	
	sendXmlData : function(options) {
		commonUtil.displayLoading(true);
		var start;
		if(configData.PERFORMANCE_TRACE_ADVICE){
			start = new Date();
		}
		
		var defaults = new Object({
			url : null,
			sendType : "list",
	    	module : null,
			command : null,
			param : null,
			xmlStr : null,
			returnParam : null,
			failFunction : null
		});
		
		var opts = jQuery.extend( defaults, options);
		
		if(opts.module && opts.command){
			opts.url = "/common/"+opts.module+"/"+opts.sendType+"/xml/"+opts.command+".data";			
		}		
		
		if(opts.param == null){
			opts.xmlStr = "<?xml version='1.0' encoding='UTF-8'?>";
		}else if(typeof opts.param == "string"){
			opts.xmlStr = "<?xml version='1.0' encoding='UTF-8'?>"+opts.param;
		}else{
			opts.xmlStr = "<?xml version='1.0' encoding='UTF-8'?><XML>"+opts.param.html()+"</XML>";
		}
		
		alert(opts.xmlStr);

		var returnData;
		jQuery.ajax({
			type: "post",
			url: opts.url,
			async: false,
			data: opts.xmlStr,
			dataType: "xml",			
			error: function(a, b, c){
				if(!netUtil.sessionCheck(a)){
		    		return;		    		
		    	}
				commonUtil.displayLoading(false);
				returnData = netUtil.defaultFailFunction(a, b, c);				
		    },
		    success: function (json) {
		    	commonUtil.displayLoading(false);
		    	returnData = json;
		    }
		});
		//commonUtil.displayLoading(false);
		return returnData;
	},
	// form 전송을 비동기로 처리한다.
	// formId - request form tag id, [successFunction] 정상 callback 시 실행 함수, [failFunction] 실패 callback 시 실행 함수, [param] callback 함수에 전달한 데이터
	setForm : function(formId) {
		var $formObj = jQuery("#"+formId);
		var sendUrl = $formObj.attr("action");	
		
		commonUtil.setMenuId($formObj);
		
		$formObj.ajaxForm({
			type: "post",
			url: sendUrl,
			uploadProgress: function(event, position, total, percentComplete){
		    },
			beforeSubmit:function() { 
				if(validate.check(formId)){
					commonUtil.displayLoading(true);
					return true;
				}else{
					return false;
				}				
		    },
		    error: function(a, b, c){
		    	if(!netUtil.sessionCheck(a)){
		    		return;		    		
		    	}
		    	//event fn
		    	if(commonUtil.checkFn("netUtilEventSetFormError")){
		    		netUtilEventSetFormError(a, b, c, formId);
		    	}else{
		    		netUtil.defaultFailFunction(a, b, c);
		    	}
		        commonUtil.displayLoading(false);
		    },
		    success: function (data) {
		    	//event fn
		    	if(commonUtil.checkFn("netUtilEventSetFormSuccess")){
		    		netUtilEventSetFormSuccess(formId, data);
		    	}
		    	commonUtil.displayLoading(false);
		    }
		});
	},
	// formId의 form tag를 submit한다.
	sendForm : function(formId) {
		var $formObj = jQuery("#"+formId);
		if(validate.check(formId)){
			$formObj.submit();
		}
	},
	// sendUrl에서 받은 html을 리턴한다.
	getHtmlData : function(sendUrl) {
		try{
			commonUtil.displayLoading(true);
			var returnData;
			jQuery.ajax({
				type: "get",
				async: false,
				url: sendUrl,
				dataType: "html",
				error: function(a, b, c){				
			        commonUtil.displayLoading(false);
			        netUtil.defaultFailFunction(a, b, c);
			    },
			    success: function(html) {
			    	commonUtil.displayLoading(false);
			    	returnData = html;
			    }
			});
			return returnData;
		}catch(e){
			commonUtil.msg("NetUtil.getHtmlData : "+e);
		}
	},
	// ajax 실패 call back 함수가 없는 경우 기본 실행 함수
	defaultFailFunction : function(a, b, c) {		
		var errTxt = a.responseText;
		commonUtil.msg(errTxt);
		var errData = {
			error : errTxt
		}
		
		return errData;
	},	
	checkResult : function(json) {		
		if(json && json.data){
			return true;
		}else{
			return false;
		}
	},
	sessionCheck : function(a) {		
		var errTxt = a.responseText;
		if(errTxt.indexOf("Session empty") != -1){
			commonUtil.msg("session이 만료되었습니다.");
			window.top.location.href = "/index.jsp";
			return false;
		}
		return true;
	},
	toString : function() {
		return "NetUtil";
	}
};

var netUtil = new NetUtil();