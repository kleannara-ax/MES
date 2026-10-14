Site = function() {
	this.commonUrl = "/common";
	this.defaultCheckValue = "V";
	this.emptyValue = " ";
	
	this.COMMON_DATE_TYPE_DATA = "yyyymmdd";
	this.COMMON_DATE_TYPE = "yyyy.mm.dd";
	this.COMMON_DATE_TYPE_UI = "yy.mm.dd";
//	this.COMMON_DATE_TYPE_DATA = "ddmmyyyy"; 
//	this.COMMON_DATE_TYPE = "dd.mm.yyyy";
//	this.COMMON_DATE_TYPE_UI = "dd.mm.yy";
	this.COMMON_DATE_MONTH_TYPE = "yyyy.mm"; // 2019.03.07 jw : : Input Data Type Month Added
	this.COMMON_DATE_MONTH_TYPE_UI = "yy.mm"; // 2019.03.07 jw : : Input Data Type Month Added
	
	this.COMMON_TIME_TYPE = "HH:MM:SS";
	this.COMMON_TIMEHM_TYPE = "HH:MM";
	
	this.COMMON_DATETIME_TYPE = "yyyy.mm.dd HH:MM";
	this.COMMON_DATETIMESECOND_TYPE = "yyyy.mm.dd HH:MM:SS";
	
	this.decimalSeparator = ".";
	this.thousandSeparator = ",";
	
//	this.decimalSeparator = ",";
//	this.thousandSeparator = ".";
	
	this.excelRequestMaxRow = 0;
	
	this.COMMON_KEY_EVENT_SEARCH = "F"; // 조회
	this.COMMON_KEY_EVENT_SAVE = "S"; // 저장
	this.COMMON_KEY_EVENT_CREATE = "C"; // 생성
	this.COMMON_KEY_EVENT_SEARCH_POP = "W"; // 조회창 전환
	this.COMMON_KEY_EVENT_SEARCH_HELP = "A"; // search help
	
	/*
	this.COMMON_KEY_EVENT_SEARCH_CODE = this.COMMON_KEY_EVENT_SEARCH.charCodeAt(0);
	this.COMMON_KEY_EVENT_SAVE_CODE = this.COMMON_KEY_EVENT_SAVE.charCodeAt(0);
	this.COMMON_KEY_EVENT_CREATE_CODE = this.COMMON_KEY_EVENT_CREATE.charCodeAt(0);
	this.COMMON_KEY_EVENT_SEARCH_POP_CODE = this.COMMON_KEY_EVENT_SEARCH_POP.charCodeAt(0);
	this.COMMON_KEY_EVENT_SEARCH_HELP_CODE = this.COMMON_KEY_EVENT_SEARCH_HELP.charCodeAt(0);
	*/
	
	this.COMMON_KEY_EVENT_SEARCH_CODE = 70;//f - 조회
	this.COMMON_KEY_EVENT_SAVE_CODE = 83;//s - 저장
	this.COMMON_KEY_EVENT_CREATE_CODE = 67;//c - 생성
	this.COMMON_KEY_EVENT_SEARCH_POP_CODE = 87;//w 조회창 전환
	this.COMMON_KEY_EVENT_SEARCH_HELP_CODE = 65;//a - search help
	
	this.GRID_KEY_EVENT_ROWCOPY_CODE = 81;//행복사 : alt+q
	this.GRID_KEY_EVENT_ADDROW_CODE = 78;//행추가 : alt+n
	this.GRID_KEY_EVENT_DELETEROW_CODE = 68;//행삭제 : alt+d
	this.GRID_KEY_EVENT_LAYOUT_CODE = 76;//레이아웃 : alt+l
	this.GRID_KEY_EVENT_TOTAL_CODE = 84;//합계 : alt+t
	this.GRID_KEY_EVENT_EXCELDOWN_CODE = 69;//엑셀다운로드 : alt+e
	this.GRID_KEY_EVENT_SORT_CODE = 82;//정렬 : alt+r
	
	this.buttonLoadingCheck = true;
	
	this.gridSearchHelpEnter = false;
	
	this.REQUIRED_INPUT_CLASS = "requiredInput";
	
	this.DEFAUTL_GRID_ID = "gridList";
	
	this.INPUT_FORMAT_LOCATION = "LOC";
	this.INPUT_FORMAT_LOCATION5 = "LOC5";
	this.INPUT_FORMAT_LOCATION7 = "LOC7";
	this.INPUT_FORMAT_BARCODE = "BAR";
	
	this.GRID_MODIFY_CHECK = true;
};

Site.prototype = {
	getDataFormat : function(formatList, data, viewType) {
		var formatType = formatList[0];
		if(viewType){
			if(formatType == configData.INPUT_FORMAT_LOCATION){
				data = this.getLocationViewFormat(data);
			}else if(formatType == configData.INPUT_FORMAT_LOCATION5){
				data = this.getLocationViewFormat5(data);
			}else if(formatType == configData.INPUT_FORMAT_LOCATION7){
				data = this.getLocationViewFormat7(data);
			}else if(formatType == configData.INPUT_FORMAT_BARCODE){
				data = this.getBarcodeViewFormat(data);
			}
		}else{
			if(formatType == configData.INPUT_FORMAT_LOCATION){
				data = this.getLocationDataFormat(data);
			}else if(formatType == configData.INPUT_FORMAT_LOCATION5){
				data = this.getLocationDataFormat(data);
			}else if(formatType == configData.INPUT_FORMAT_LOCATION7){
				data = this.getLocationDataFormat(data);
			}else if(formatType == configData.INPUT_FORMAT_BARCODE){
				data = this.getBarcodeDataFormat(data);
			}
		}
		
		return data;
	},
	getLocationViewFormat : function(str) {
		if(str && str !== " " && str.length >= 7) {
			str = this.getLocationDataFormat(str);			
			var s1 = str.substring(0,1);
			var s2 = str.substring(1,3);
			var s3 = str.substring(3,5);
			var s4 = str.substring(5,6);
			var s5 = str.substring(6,7);
			str = commonUtil.replaceAll(configData.COMMON_LOCATION_TYPE, 'a', s1);
			str = commonUtil.replaceAll(str, 'bb', s2);
			str = commonUtil.replaceAll(str, 'cc', s3);
			str = commonUtil.replaceAll(str, 'd', s4);
			str = commonUtil.replaceAll(str, 'e', s5);
			return str;
		} else {
			return str;
		}
	},
	getLocationViewFormat5 : function(str) {
		var result = "";
		var s1, s2, s3, s4, s5;
		
		str = this.getLocationDataFormat(str);
		if(str.length >= 1) s1 = str.substring(0, 1);
		if(str.length >= 2) s2 = str.substring(1, 2);
		if(str.length >= 3) s3 = str.substring(2, 3);
		if(str.length >= 4) s4 = str.substring(3, 4);
		if(str.length == 5) s5 = str.substring(4, 5);
		
		if( s1 ) result += s1;
		if( s2 ) result += "-"+ s2;
		if( s3 ) result += s3;
		if( s4 ) result += "-"+ s4;
		if( s5 ) result += s5;
		
		return result;
	},
	getLocationViewFormat7 : function(str) {
		var result = "";
		var s1, s2, s3, s4, s5, s6, s7, s8, s9;
		
		str = this.getLocationDataFormat(str);
		if(str.length >= 1) s1 = str.substring(0, 1);
		if(str.length >= 2) s2 = str.substring(1, 2);
		if(str.length >= 3) s3 = str.substring(2, 3);
		if(str.length >= 4) s4 = str.substring(3, 4);
		if(str.length >= 5) s5 = str.substring(4, 5);
		if(str.length >= 6) s6 = str.substring(5, 6);
		if(str.length >= 7) s7 = str.substring(6, 7);
		
		if( s1 ) result += s1;
		if( s2 ) result += "-"+ s2;
		if( s3 ) result += s3;
		if( s4 ) result += "-"+ s4;
		if( s5 ) result += s5;
		if( s6 ) result += "-"+ s6;
		if( s7 ) result += "-"+ s7;
		
		return result;
	},
	getBarcodeViewFormat : function(str) {
		if(str && str !== " " && str.length >= 20) {
			str = this.getLocationDataFormat(str);			
			var s1 = str.substring(0,1);
			var s2 = str.substring(1,17);
			var s3 = str.substring(17,20);
			str = commonUtil.replaceAll(configData.COMMON_BARCODE_TYPE, 'A', s1);
			str = commonUtil.replaceAll(str, '2345678901234567', s2);
			str = commonUtil.replaceAll(str, 'XYZ', s3);
			return str;
		} else {
			return str;
		}
	},
	getLocationDataFormat : function(str) {
		if(str){
			str = str.replace(/-/g, '');			
			/*
			if(configData.COMMON_DATE_TYPE == "yyyy/mm/dd"){
				dateStr = commonUtil.replaceAll(dateStr, "/", "");
			}else if(configData.COMMON_DATE_TYPE == "yyyy.mm.dd"){
				dateStr = commonUtil.replaceAll(dateStr, ".", "");
			}
			*/
			/*
			if(!validate.isValidDate(dateStr)){
				commonUtil.msgBox(configData.VALIDATE_MSG_GROUPKEY+"_"+configData.VALIDATION_DATE);
			}
			*/
		}		
		return str;
	},
	getBarcodeDataFormat : function(str) {
		if(str){
			str = str.replace(/-/g, '');			
			/*
			if(configData.COMMON_DATE_TYPE == "yyyy/mm/dd"){
				dateStr = commonUtil.replaceAll(dateStr, "/", "");
			}else if(configData.COMMON_DATE_TYPE == "yyyy.mm.dd"){
				dateStr = commonUtil.replaceAll(dateStr, ".", "");
			}
			*/
			/*
			if(!validate.isValidDate(dateStr)){
				commonUtil.msgBox(configData.VALIDATE_MSG_GROUPKEY+"_"+configData.VALIDATION_DATE);
			}
			*/
		}		
		return str;
	},
	searchEnterEvent : function(keyCode, $inputObj) {
		if(keyCode == 13){
			$inputObj.trigger("click");
		}
	},
	toString : function() {
		return "Site";
	}
};

var site = new Site();