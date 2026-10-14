var Browser = {
	chk : navigator.userAgent.toLowerCase()
}

Browser = {
	ie : Browser.chk.indexOf('msie') != -1,
	ie6 : Browser.chk.indexOf('msie 6') != -1,
	ie7 : Browser.chk.indexOf('msie 7') != -1,
	ie8 : Browser.chk.indexOf('msie 8') != -1,
	ie9 : Browser.chk.indexOf('msie 9') != -1,
	ie10 : Browser.chk.indexOf('msie 10') != -1,
	ie11 : Browser.chk.indexOf('rv:11') != -1,
	win10 : Browser.chk.indexOf('windows nt 10') != -1,
	opera : !!window.opera,
	safari : Browser.chk.indexOf('safari') != -1,
	safari3 : Browser.chk.indexOf('applewebkir/5') != -1,
	mac : Browser.chk.indexOf('mac') != -1,
	chrome : Browser.chk.indexOf('chrome') != -1,
	firefox : Browser.chk.indexOf('firefox') != -1
}

CommonUtil = function() {
	this.loadingViewType = true; // ajax호출시 자동으로 표시되는 loading의 표시 유무
	this.loadingCount = 0; // ajax의 비동기 호출 시 여러건의 call back을 감지하여 모두 완료되어야ㅣloading을 해지한다.
	/*
	this.browser;
	this.bversion;
	
	if(jQuery.browser.msie){
		this.browser = "msie";
	}else if(jQuery.browser.mozilla){
		this.browser = "mozilla";
	}else if(jQuery.browser.safari){
		this.browser = "safari";
	}else if(jQuery.browser.opera){
		this.browser = "opera";
	}
	
	var bversion = jQuery.browser.version;
	if(bversion.indexOf(".")){
		bversion = bversion.substring(0,bversion.indexOf("."));
	}
	this.bversion = bversion;
	*/
	//alert(JSON.stringify(Browser));
};
CommonUtil.prototype = {
	// logding을 사용하지 않도록 설정
	loadingViewOff : function() {
		this.loadingViewType = false;
	},
	// loading을 사용하도록 설정
	loadingViewOn : function() {
		this.loadingViewType = true;
	},
	// loading을 표시한다. type - true:표시, false:해지
	displayLoading : function(type) {
		if(!this.loadingViewType){
			return;
		}
		if(type){
			this.loadingCount++;
			if(this.loadingCount == 1){
				loadingOpen();
			}
		}else{
			this.loadingCount--;
			if(this.loadingCount == 0){
				//searchOpen(false);
				loadingClose();
			}
		}
	},
	displayLoadingClose : function() {
		if(!this.loadingViewType){
			return;
		}
		loadingClose();
	},
	isDisplayLoading : function() {
		if(this.loadingViewType && this.loadingCount > 0){
			return true;
		}else{
			return false;
		}
	},
	// input에서 enter key조작시 특정 함수 호출
	enterKeyCheck : function(event, fncName) {
		if(event.keyCode == 13){
			try{
				eval(fncName);
			}catch(e){				
			}			
		}
	},
	backKeyCheck : function(obj) {
		var $obj = $(obj);
		$obj.keydown(function(event){
			var $obj = $(event.target);
			var code = event.keyCode;
			
			//8 backspace
			if(code == 8){
				commonUtil.cancleEvent(event);
			}
		});
	},
	backKeyDownEvent : function(event) {
		var $obj = $(event.target);
		var code = event.keyCode;
		
		//8 backspace
		if(code == 8){
			commonUtil.cancleEvent(event);
		}
	},
	controllKeyCheck : function(event) {
		var code = event.keyCode;
		if(code == 8 || code == 9 || code == 46 || code == 35 || code == 36 || code == 37 || code == 39){
			return true;
		}
		return false;
	},
	numberKeyCheck : function(event, charList) {
		var code = event.keyCode;
		if( ( code >=48 && code <= 57 ) || ( code >=96 && code <= 105 ) || this.controllKeyCheck(event)){
			return true;
		}else if(charList){
			if(code == 188){
				code = 44;
			}
			if(code == 190){
				code = 46;
			}
			var tmpString = String.fromCharCode(code);
			if(charList.indexOf(tmpString) != -1){
				return true;
			}
		}
		return false;
	},
	cancleEvent : function(event){
		if(event.preventDefault){
			event.preventDefault();
		}else{
			event.returnValue = false;
		}
	},
	// $obj jQuery객체에서 값을 셋팅한다.
	setElementValue : function($obj, data) {
		var tag = $obj[0].tagName;
		var formatAtt = $obj.attr(configData.INPUT_FORMAT);
		if(formatAtt){
			var formatList = formatAtt.split(" ");
			data = uiList.getDataFormat(formatList, data, true);
		}
		if(tag == "INPUT"){
			if($obj.attr("type") == 'checkbox'){
				if($obj.val() == data){
					$obj.prop("checked", true);
				}else{
					$obj.prop("checked", false);
				}
			}else if($obj.attr("type") == 'radio'){
				var rName = $obj.attr("name");
				jQuery("[name='"+rName+"']").each(function(i, findElement){
					$fObj = jQuery(findElement);
					if($fObj.val() == data){
						$fObj.prop("checked", true);
						return;
					}
				});
			}else{
				$obj.val(data);
			}
		}else if(tag == "SELECT"){
			var comboTypeAttr = $obj.attr(configData.INPUT_COMBO_TYPE);
			if(comboTypeAttr){
				if(data){
					data = data.split(",");
					inputList.setMultiComboValue($obj, data);
				}else{
					$obj.val(data);
				}
			}else{
				$obj.val(data);
			}			
		}else if(tag == "TEXTAREA"){
			$obj.val(data);
		}else if(tag == "IFRAME" || tag == "EMBED"){
			$obj.attr("src", data);
			$obj.get(0).contentDocument.location.reload(true);
		}else if(tag == "DIV"){
			$obj.html(data);
		}else if(tag == "IMG"){
			$obj.attr("src", data);
		}else{
			$obj.html(data);
		}
	},
	// $obj jQuery객체에 값을 추출한다.
	getElementValue : function($obj) {
		var tag = $obj.attr("tagName");
		if(tag == "INPUT" || tag == "SELECT" || tag == "TEXTAREA"){
			return $obj.val();
		}else{
			return $obj.html();
		}
	},
	// vId에 해당하는 jQuery객체를 가져온다. 지정 영역이 없는 경우 body전체를 영역으로 잡는다.
	getArea : function(vId) {
		var $obj;
		if(vId){
			if(typeof vId == "string"){
				$obj = jQuery("#"+vId);
			}else{
				$obj = jQuery(vId);
			}			
		}else{
			$obj = jQuery("body");
		}
		return $obj;
	},
	// obj의 타입을 가져온다.
	getObjType : function(obj) {
		var typeStr;
		if(obj instanceof Object){
			if(obj instanceof DataMap){
				typeStr = "map";
			}else if(obj instanceof Array){
				typeStr = "array";
			}else if(obj instanceof jQuery){
				typeStr = "jquery";
			}else if(obj instanceof Element){
				typeStr = "element";
			}else{
				typeStr = "object";
			}
		}else{
			typeStr = (typeof obj);
		}
		return typeStr;
	},
	// obj의 값이 어떤 형태이건 jQuery객체로 반환한다.
	getJObj : function(obj) {
		var $obj;
		switch(this.getObjType(obj)){
			case "jquery":
				$obj = obj;
				break;
			case "string":
			case "number":
				$obj = jQuery("#"+obj);
				break;
			default:
				$obj = jQuery(obj);
		}
		return $obj;
	},
	// 지정한 obj의 id를 반환한다.
	getObjId : function(obj) {
		var idStr;
		switch(this.getObjType(obj)){
			case "element":
				idStr = obj.id;
				break;
			default:
				$obj = this.getJObj(obj).attr("id");
		}
		return $obj;
	},
	// obj가 어떤 형태이건 값이 없는지 판단한다.
	isEmpty : function(obj) {
		var isStr = false;
		if(obj){
			if(obj instanceof Object){
				if(obj instanceof DataMap){
					isStr = (obj.size() == 0);
				}else if(obj instanceof Array){
					isStr = (obj.length == 0);
				}else if(obj instanceof jQuery){
					isStr = (obj.length == 0);
				}
			}
		}else{
			isStr = true;
		}
		return isStr;
	},
	// obj가 어떤 형태이건 값이 있는지 판단한다.
	isNotEmpty : function(obj) {
		return !this.isEmpty(obj);
	},
	// obj가 Empty이면 지정한 val을 리턴한다.
	NVL : function(obj, val) {
		if(obj){
			return obj;
		}else{
			return val;
		}
	},
	// popup을 open한다.
	popupOpen : function(url, width, height) {
		window.open(url,'popup','width='+width+',height='+height+',scrollbars=yes');
	},
	// 해당 txt를 화면에 보여준다.
	msg : function(txt, title) {
		alert(txt);
	},
	msgBox : function(key, param, title) {
		var msg = this.getMsg(key, param);
		
		alert(msg);
	},
	getMsg : function(key, param) {
		if(!param){
			param = "";
		}
		
		var msg = commonMessage.getMessage(key);
		
		msg = this.format(msg, param);
		
		return msg;
	},
	msgConfirm : function(key, param) {
		var msgTxt = this.getMsg(key, param);
		return confirm(msgTxt);
	},
	format : function( source, params ) {
		if(source){
			if ( arguments.length === 1 ) {
				return function() {
					var args = $.makeArray( arguments );
					args.unshift( source );
					return commonUtil.format( this, args );
				};
			}
			if ( arguments.length > 2 && params.constructor !== Array  ) {
				params = $.makeArray( arguments ).slice( 1 );
			}
			if ( params.constructor !== Array ) {
				params = [ params ];
			}
			$.each( params, function( i, n ) {
				source = source.replace( new RegExp( "\\{" + i + "\\}", "g" ), function() {
					return n;
				});
			});
		}
		return source;
	},
	debugMsg : function(txt, params) {
		if(params){
			for(var i=0;i<params.length;i++){
				txt += " / "+params[i];
			}
		}		
		
		alert(txt);
	},
	consoleMsg : function(txt, params) {
		try{
			if(console){
				if(params){
					for(var i=0;i<params.length;i++){
						txt += " / "+params[i];
					}
				}
				
				console.debug(txt);
				
			}
		}catch(e){}
	},
	getInParam : function(list, colName) {
		var inParam = "";
		for(var i=0;i<list.length;i++){
			if(i != 0){
				inParam += ",";
			}
			inParam += "'"+list[i].get(colName)+"'";
		}
		
		return inParam;
	},
	leftTrim : function(data, char) {
		if(data.length > 0){
			if(data.substring(0,1) == char){
				data = data.substring(1);
				data = this.leftTrim(data, char);
			}
		}		
		
		return data;
	},
	// data의 길이가 len보다 작으면 왼쪽부터 char를 채운다.
	leftPadding : function(data, char, len) {
		var strData = new String(data);
		return this.fillString(char, len-strData.length)+strData;
	},
	rightPadding : function(data, char, len) {
		var strData = new String(data);
		return strData + this.fillString(char, len-strData.length);
	},
	// char를 len개수만큼 만들어서 리턴한다.
	fillString : function(char, len) {
		var s = '', i = 0;
		while (i++ < len) { 
			s += char; 
		}
		return s;
	},
	delimiterString : function(data, char, len) {
		var endIndex = data.indexOf(char);
		if(endIndex == -1){
			endIndex = data.length;			
		}
		if(endIndex <= len){
			return data;
		}else{
			data = data.substring(0, endIndex - len)+char+data.substring(endIndex - len);
			if(endIndex > len*2){
				data = this.delimiterString(data, char, len);
			}
		}
		return data;
	},
	comma : function(val){
	  var n = val;
	  var result = format("#,##0", n);
	  if(result == "-"){
	   return "0";
	  }else{
	   return format("#,##0", n);
	  }
	},
	// str에 포함된 char를 nChar로 변경한다.
	replaceAll : function(str, char, nChar) {
		var data;
		if(typeof str == "number"){
			data = str + "";
		}else{
			data = str;
		}
		data = data.split(char).join(nChar);
		/*
		var index = 0;
		while((index = data.indexOf(char, index)) != -1){
			data = data.substring(0, index)+nChar+data.substring(index+char.length);
		}
		*/
		return data;
	},
	parseInt : function(str) {
		if(typeof str == "number"){
			return str;
		}else{
			var num = new Number(str);
			return num;
		}
	},
	leftMenuToggle : function() {
		window.top.sizeToggle();
	},
	sessionIdCheck : function(obj) {
		$tObj = this.getJObj($tObj);
		if(configData.SES_USER_ID){
			$tObj.hide();
		}else{
			$tObj.show();
		}
	},
	setRequestUrl : function(tmpUrl, tmpUri) {
		configData.REQUEST_URL = tmpUrl;
		configData.SHARE_URL = tmpUrl;
		configData.REQUEST_URI = tmpUri;
	},
	isJObjNotEmpty : function($obj) {
		return !this.isJObjEmpty($obj);
	},
	isJObjEmpty : function($obj) {
		return ($obj == undefined || $obj == null || $obj.length == 0);
	},
	log : function(msg) {
		if(configData.DEBUG_MODE){
			jQuery("<br/><span>"+msg+"</span>").appendTo("body");
		}		
	},
	removeRow : function(list, rowNum) {
		if(list){
			rowNum = parseInt(rowNum);
			if(list.length > 0 && rowNum >= 0){
				list = list.slice(0,rowNum).concat(list.slice(rowNum+1));
			}
		}
		return list;
	},
	getAjaxUploadFileList : function(data) {
		if(data){
			data = data.substring(data.indexOf("[")+1,data.indexOf("]"));
			return data.split(",");
		}
		return data;
	},
	getAjaxUploadFileGroupKey : function(data) {
		if(data){
			data = data.substring(data.indexOf("[")+1,data.indexOf("]"));
		}
		return data;
	},
	getAjaxUploadGroupFileList : function(data) {
		if(data){
			data = data.substring(data.indexOf("[")+1,data.indexOf("]"));
			var param = new DataMap();
			param.put("GUUID", data);
			
			var json = netUtil.sendData({
				url : "/common/Common/list/json/FWCMFL0010.data",
				param : param
			});
			
			if(json && json.data){
				return json.data;
			}
		}
		return data;
	},
	copyMap : function(data) {
		var map = new DataMap();
		for (var prop in data) {
			map.put(prop, data[prop]);
		}
		return map;
	},
	getCssNum : function(obj, cssAtt) {
		var $obj = this.getJObj(obj);
		var tmpStr = $obj.css(cssAtt);
		if(tmpStr){
			if(tmpStr.indexOf("px") != -1){
				tmpStr = tmpStr.substring(0, tmpStr.lastIndexOf("px"));
			}
		}else{
			return 0;
		}
		
		if(!isNaN(tmpStr)){
			return parseInt(tmpStr);
		}else{
			return 0;
		}
	},
	getAttrNum : function(obj, cssAtt) {
		var $obj = this.getJObj(obj);
		var tmpStr = $obj.attr(cssAtt);
		if(tmpStr){
			if(tmpStr.indexOf("px") != -1){
				tmpStr = tmpStr.substring(0, tmpStr.lastIndexOf("px"));
			}
		}else{
			return 0;
		}
		
		if(!isNaN(tmpStr)){
			return parseInt(tmpStr);
		}else{
			return 0;
		}
	},
	stringToMap : function(param) {
		var paramStr = "";
		for (var prop in param.map) {
			if(paramStr.length > 0){
				paramStr += configData.DATA_ROW_SEPARATOR;
			}
			paramStr += prop + configData.DATA_COL_SEPARATOR + param.get(prop);
		}
		return paramStr;
	},
	stringToList : function(list) {
		var listStr = "";
		for(var i=0;i<list.length;i++){
			if(i != 0){
				listStr += configData.DATA_ROW_SEPARATOR;
			}
			listStr += list[i];
		}
		return listStr;
	},
	stringBindMap : function(str, param) {
		for (var prop in param.map) {
			str = this.replaceAll(str, "#"+prop+"#", "'"+param.get(prop)+"'");
		}
		return str;
	},
	stringInMap : function(str, param) {
		var map = new DataMap();
		for (var prop in param.map) {
			if(str.indexOf("#"+prop+"#") != -1){
				map.put(prop, param.get(prop));
			}
		}
		return map;
	},
	functionErrorCatch : function(e, txt) {
		if(e.message.indexOf(txt) != -1){
			throw e;
		}
	},
	datastringFromMap : function(data) {
		var headString = "";
		if(data["data"].length > 0){
			var map = data["data"][0];
			for(var prop in map) {
				headString += (prop + configData.DATA_COL_SEPARATOR);
			}
			headString = headString.substring(0,headString.length-1);
			
			var dataString = this.stringFromMap(data["data"]);
			//dataList.unshift(headString);
					
			return headString+configData.DATA_ROW_SEPARATOR+dataString;
		}else{
			return "";
		}
		
	},
	stringFromMap : function(data) {
		//data = data.slice(0,1000);
		var dataList = new Array();
		for(var i=0;i<data.length;i++){
			var map = data[i];
			var dataString = "";
			for(var prop in map) {
				dataString += (map[prop] + configData.DATA_COL_SEPARATOR);
			}
			
			dataString = dataString.substring(0,dataString.length-1);			

			dataList.push(dataString);
		}
		
		return dataList.join(configData.DATA_ROW_SEPARATOR);
	},
	stringToNumber : function(numStr) {
		var tmpSign = "";
		if(isNaN(numStr)){
			if(numStr.substring(0,1) == "-"){
				tmpSign = "-";
			}
			numStr = tmpSign+numStr.replace(/[^\d]+/g, '');
		}
		return numStr;
	},
	checkFn : function(fn) {
		try{
			if(eval(fn)){
				return true;
			}
		}catch(e){}
		return false;
	},
	setMenuId : function(param) {
		if(param == null || typeof param == "string"){
			return;
		}else if(param instanceof DataMap){
			param.put(configData.COMMON_MENU_ID_KEY, configData.MENU_ID);
		}else if(param instanceof jQuery){
			var tmpTagName = param.get(0).tagName;
			if(tmpTagName == "FORM"){
				if(param.find("[name='"+configData.COMMON_MENU_ID_KEY+"']").length == 0){
					param.append("<input type='hidden' name='"+configData.COMMON_MENU_ID_KEY+"' value='"+configData.MENU_ID+"' />");
				}
			}
		}else if(param instanceof Object){
			param[configData.COMMON_MENU_ID_KEY] = configData.MENU_ID;
		}		
	},
	textAllSelect : function($obj) {
		$obj = this.getJObj($obj);
		if (window.getSelection) {
	        var selected = window.getSelection();
	            selected.selectAllChildren($obj.get(0));
	        //console.log(selected.toString());
	    } else if (document.body.createTextRange) {
	        var range = document.body.createTextRange();
	            range.moveToElementText($obj.get(0));
	            range.select();
	    }
	},
	isMobile : function() {
		var filter = "win16|win32|win64|mac";
		if(navigator.platform){
			if(0 > filter.indexOf(navigator.platform.toLowerCase())){
				//alert("Mobile");
				return true;
			}else{
				//alert("PC");
				return false;
			}
		}
	},
	copyClipboard : function(saveData, copyEventType) {
		
		if(window.clipboardData) { // Internet Explorer
			window.clipboardData.setData("Text", saveData);
	    }else{
	    	var successful = false;
			showClipCopy();
			$clipboardLayerText.val(saveData);
			$clipboardLayerText.select();
			try {
				successful = document.execCommand('copy');
			}catch(e){};

			hideClipSave();
			if(successful == false){
				if(copyEventType){
		    		//window.prompt("Ctrl+C copy clipboard", saveData);
		    		//$clipboardLayerText.val(saveData);
		    		showClipCopy();
		    		//$clipboardLayerText.select();
		    	}
			}
	    }
				
		return;
	},
	pasteClipboard : function() {
		var clipData = "";
		
		if (window.clipboardData){
			copyData = window.clipboardData.getData("Text").toString();
		//}else if(event.clipboardData){
			//clipData = event.clipboardData.getData('text/plain');
		}else{
			var successful = false;
			
			showClipCopy();
			$clipboardLayerText.val("");
			$clipboardLayerText.focus();
			try{
				successful = document.execCommand("paste");
			}catch(e){};
		    
			hideClipSave();
			if(successful){
				clipData = $clipboardLayerText.val();
			}
		}
		
		return clipData;
	},
	fileDownload : function(uuid) {
		if(!uuid){
			return;
		}
		jQuery("#fileDownloadForm").remove();
		
		// 비동기 전달을 위해 전달에 필요한 파라메터에 각 값들은 jsonString형태로 전송한다.
		var formHtml = "<form action='/common/fileDown/file.data' method='post' id='fileDownloadForm'>"
					 + "<input type='text' name='UUID' value='"+uuid+"' />"
					 + "</form>";
		jQuery(formHtml).hide().appendTo('body');
		jQuery("#fileDownloadForm").submit();
	},
	toString : function() {
		return "Common";
	}
};

var commonUtil = new CommonUtil();