$('head').append('<link rel="stylesheet" href="/common/theme/webdek/css/bl.css" type="text/css" />');

BlCommon = function(){
	this.upperChk = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	this.lowerChk = "abcdefghijklmnopqrstuvwxyz";
	this.numChk = "0123456789";
	this.LAT = 127.101153;
	this.LON = 37.318876;
};

BlCommon.prototype = {
		/**
		* 자동차번호 유효성 체크
		* @param {String} value
		* @returns {Boolean}  
		*/
		checkPlate : function (value){
		var NSValue = value.replace(/ /gi, "");
		var region = NSValue.substring(0, 2);
	
		var checkRegion = "서울,부산,대구,인천,대전,광주,울산,제주,경기,강원,충남,충북,전남,전북,경남,경북";
		var arrCheckRegion = checkRegion.split(',');
	
		for(var i = 0; i < arrCheckRegion.length; i++){
			if(region==arrCheckRegion[i]){
				NSValue = NSValue.substring(2, NSValue.length);
				break;
			}
		}
	
		var typeOfCar = Number(NSValue.substring(0, 2));
		if(isNaN(typeOfCar) || typeOfCar <= 0){
			return false;
		}
	
		var use = NSValue.substring(2, 3);
		var checkUse = "가,나,다,라,마,"
		+"거,너,더,러,머,버,서,어,저,"
		+"고,노,도,로,모,보,소,오,조,"
		+"구,누,두,루,무,부,수,우,주,"
		+"바,사,아,자,"
		+"배,"
		+"허,하,호,"
		+"국,합,육,해,공";
		var arrCheckUse = checkUse.split(',');
		var resultUse = 0;
	
		for(var j = 0; j < arrCheckUse.length; j++){
			if(use==arrCheckUse[j]){
				resultUse = 1;
				break;
			}
		}
	
		if(resultUse == 0) return false;
		var serialNumber = NSValue.substring(3, value.length);
	
		if(isNaN(serialNumber) || serialNumber < 1000){
			return false;
		}
	
		return true;
	}

	/**
	* 숫자 천자리(3)마다 , 표시
	* @param {String} x
	* @returns {String}  
	*/
	,comma : function (x) {
		return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
	}

	/**
	* 문자열이 NULL인지 체크
	* @param {String} str
	* @returns {Boolean} 
	*/
	,isNull : function(str) {
		if( !str ) return true;
		if( str == "" ) return true;
		if( str == null || str == "null" ) return true;
		if( str == undefined || str == "undefined" ) return true;
		if( str == NaN || str == "NaN" ) return true;
		if( typeof str == "object" && !Object.keys(str).length ) return true;
		
		return false;
	}

	/**
	* Object 존재여부
	* @param {Object} obj
	* @returns {Boolean}
	* ex) isEmpty($("input[name=test]"));
	*/
	,isEmpty : function(obj) {
		if( typeof obj === 'string' ){
			if( this.isNull(obj) ) return true;
			if( obj.replace(/ /gi, "") == "" ) return true;
		}else{
			if( commonUtil.isEmpty(obj) ) return true;
			if( obj == null ) return true;
			if( obj == undefined ) return true;
			if( typeof obj == "object" && !Object.keys(obj).length ) return true;
		}
		
		return false;
	}

	/**
	* 문자열에 특정 문자(chars)가 있는지 체크
	* 특정 문자를 허용하지 않으려 할 때 사용
	* @param str
	* @param chars
	*/
	,containsChars : function(str, chars) {
		if( this.isNull(chars) ){
			return false;
		}
		
		var flag = false;
		
		if( !this.isNull(str) ){
			var strLen = str.length;
			for( var idx = 0; idx < strLen; idx++ ){
				if( chars.indexOf(str.charAt(idx)) > -1 ) flag = true;
			}
		}
		
		return flag;
	}
	
	/**
	* 문자열이 특정 문자(chars)만으로 되어있는지 체크
	* 특정 문자만 허용하려 할 때 사용
	* @param val
	* @param chars
	*/
	,containsCharsOnly : function(val, chars) {
		if( this.isNull(chars) ){
			return false;
		}
		
		var flag = false;
		
		if( !this.isNull(val) ){
			flag = this.containsChars(val, chars);
		}
		
		return flag;
	}

	/**
	* 입력값이 알파벳인지 체크
	* @param val
	*/
	,isAlphabet : function(val) {
		var chars = this.upperChk + this.lowerChk;
		return this.containsCharsOnly(val, chars);
	}

	/**
	* 입력값이 알파벳 대문자인지 체크
	* @param val
	*/
	,isUpperCase : function(val) {
		return this.containsCharsOnly(val, this.upperChk);
	}

	/**
	* 입력값이 알파벳 소문자인지 체크
	* @param val
	*/
	,isLowerCase : function(val) {
		return this.containsCharsOnly(val, this.lowerChk);
	}

	/**
	* 입력값에 숫자만 있는지 체크
	* @param val
	*/
	,isNumber : function(val) {
		return $.isNumeric(val);
	}

	/**
	* 입력값이 알파벳 and 숫자로 되어있는지 체크
	* @param val
	*/
	,isAlphaNum : function(val) {
		var chars = this.upperChk + this.lowerChk + this.numChk;
		return this.containsCharsOnly(val, chars);
	}

	/**
	* 입력값이 숫자 and 대시(-)로 되어있는지 체크
	* @param val
	*/
	,isNumDash : function(val) {
		var chars = "-" + this.numChk;
		return this.containsCharsOnly(val, chars);
	}

	/**
	* 입력값이 숫자 and 콤마(,)로 되어있는지 체크
	* @param val
	*/
	,isNumComma : function(val) {
		var chars = "," + this.numChk;
		return this.containsCharsOnly(val, chars);
	}

	/**
	* 입력값이 사용자가 정의한 포맷 형식인지 체크
	* @param val
	* @param format
	*/
	,isValidFormat : function(val, format) {
		if( this.isNull(format) ){
			return false;
		}
		
		if( !this.isNull(val) ){
			if( val.search(format) > -1 ) return true;
		}
		
		return false;
	}

	/**
	* 입력값이 이메일 형식인지 체크
	* @param val
	*/
	,isValidEmail : function(val) {
		return this.isValidFormat(val, /^((\w|[\-\.])+)@((\w|[\-\.])+)\.([A-Za-z]+)$/);
	}

	/** 
	* 입력값이 전화번호 형식(숫자-숫자-숫자)인지 체크
	* @param val
	*/ 
	,isValidPhone : function(val) {
		return this.isValidFormat(val, /^(\d+)-(\d+)-(\d+)$/);
	}
	
	/** 
	* 입력값이 날짜 형식인지 체크
	* @param val
	*/ 
	,isValidDate : function(val) {
		var format = /^(19|20)\d{2}\.(0[1-9]|1[012])\.(0[1-9]|[12][0-9]|3[0-1])$/;
		
		if( configData.COMMON_DATE_TYPE == "yyyy-mm-dd" ){
			format = /^(19|20)\d{2}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[0-1])$/;
		}
		
		return this.isValidFormat(val, format);
	}

	/**
	* 입력값의 바이트 길이를 리턴
	* @param val
	*/ 
	,getByteLength : function(val) {
		var byteLength = 0;
		
		if( !this.isNull(val) ){
			var valLen = val.length;
			for( var idx = 0; idx < valLen; idx++ ){
				var oneChar = escape(val.charAt(idx));
				if( oneChar.length == 1 ){
					byteLength ++;
				}else if( oneChar.indexOf("%u") > -1 ){
					byteLength += 2;
				}else if( oneChar.indexOf("%") > -1 ){
					byteLength += oneChar.length / 3;
				}
			}
		}
		
		return byteLength;
	}
	
	/**
	* 입력값에서 대시(-)를 없앤다.
	* @param val
	*/
	,removeDash : function(val) {
		var value = "";
		
		if( !this.isNull(val) ) value = val.replace(/-/gi, "");
		
		return value;
	}

	/**
	* 입력값에서 콤마(,)를 없앤다.
	* @param val
	*/
	,removeComma : function(val) {
		var value = "";
		
		if( !this.isNull(val) ) value = val.replace(/,/gi, "");
		
		return value;
	}

	/**
	* 선택된 라디오 or 체크박스가 있는지 체크
	* @param input : Input Object
	* 
	* ex) hasChecked($("input[name=test]"))
	*/
	,hasChecked : function(input) {
		var flag = false;
		
		if( !this.isEmpty(input) ){
			input.each(function(){
				if( $(this).prop("checked") == true ) flag = true;
			});
		}
		
		return flag;
	}
	
	/**
	* 선택된 라디오의 값을 리턴
	* @param input : Input Object
	* 
	* ex) radioCheckedVal($("input[name=test]"))
	*/
	,radioCheckedVal : function(input) {
		var value = "";
		
		if( this.hasChecked(input) ){
			input.each(function(){
				var $this = $(this);
				if( $this.prop("checked") == true ) value = $this.val();
			});
		}
		
		return value;
	}
	
	/**
	* 선택된 체크박스의 값을 리턴
	* @param input : Input Object
	* 
	* ex) checkBoxCheckedVal($("input[name=test]"));
	*/
	,checkBoxCheckedVal : function(input) {
		var value = "";
		
		if( this.hasChecked(input) ){
			var valueArr = [];
			
			input.each(function(){
				var $this = $(this);
				if( $this.prop("checked") == true ) valueArr.push($this.val());
			});
			
			if( valueArr.length > 0 ) value = valueArr.join(",");
		}
		
		return value;
	}
	
	/**
	* number to float
	* @param num
	*/
	,parseFloat : function(num) {
		if( !this.isEmpty(num) ){
			if( this.isNumber(num) ) {
				return parseFloat(num);
			}
		}else{
			num = 0;
		}
		
		return num;
	}
	
	/**
	 * list 형태의 데이터를 where in string으로 반환
	 * 
	 * @param list
	 */
	,listToWhereInStr : function(list){
		var str = "";
		
		if( !this.isEmpty(list) ){
			var listLen = list.length;
			for( var i = 0; i < listLen; i++ ){
				if( i > 0 ) str += ",";
				str += "'" + list[i] + "'";
			}
		}
		
		return str;
	}
	
	/**
	* 특수문자를 제거합니다.
	* 
	* @param str : 특수문자를 제거할 문자열
	*/
	,specialTextRemove : function(str) {
		if ( this.isNull(str) ){
			str = "";
		} else {
			str = str.replace(/[#\&\+\-%@=\/\\\:;,\.'\"\^`~\_|\!\?\*$#<>()\[\]\{\}]/gi, "");
		}
		
		return str;
	}
	
	/**
	* 영역 날짜 검색 조건 체크
	*
	* @param srhName : 검색 조건 Name
	* @param srhCnt  : 검색 기간 제한
	*/
	,calDateCount : function(strDate, endDate) {
		var input1  =  strDate; 
		var input2  =  endDate; 
		
		var date1  =  new Date(input1.substr(0,4), input1.substr(4,2) -1, input1.substr(6,2)); 
		var date2  =  new Date(input2.substr(0,4), input2.substr(4,2) -1, input2.substr(6,2)); 
		
		var interval =  date2 - date1; 
		var day   =  1000*60*60*24; 
		
		return parseInt((interval/day));
	}
	
	/**
	* 영역 날짜 검색 조건 체크
	*
	* @param srhName : 검색 조건 Name
	* @param srhCnt  : 검색 기간 제한
	*/
	,rangeDateSearhCheck : function(srhName, srhCnt) {
		var exit = false;
		var strSrhStartVal = $("input[name='" + srhName +"']").next().val();
		var strSrhEndVal   = $("input[name='" + srhName +"']").next().next().next().val();
		var strCalQty= 0;
		
		if( this.isNull(strSrhStartVal) ){
			//alert("필수 검색 정보가 입력되지 않았습니다.");
			commonUtil.msgBox("MASTER_M0434");
			$("input[name='" + srhName +"']").next().focus();
			exit = true;	
			return exit;
		}
		
		if( this.isNull(strSrhEndVal) ){
			//alert("필수 검색 정보가 입력되지 않았습니다.");
			commonUtil.msgBox("MASTER_M0434");
			$("input[name='" + srhName +"']").next().next().next().focus();
			exit = true;		
			return exit;
		}
		
		strCalQty = this.calDateCount(this.specialTextRemove(strSrhStartVal), this.specialTextRemove(strSrhEndVal));
		
		if(strCalQty > srhCnt){
// 			alert("검색기간은 srhCnt 을 초과할수 없습니다.");
			alert(commonUtil.getMsg("OUT_M0217", srhCnt));
			exit = true;	
			return exit;
		}
		
		if(strCalQty < 0){
// 			alert("검색기간을 확인해주세요.");
			commonUtil.msgBox("OUT_M0210");
			exit = true;
			return exit;
		}		
		
		return exit;
	}
	
	/**
	* 싱글 또는 영역 날짜 검색 조건 체크
	*
	* @param srhName : 검색 조건 Name
	* @param srhCnt  : 검색 기간 제한
	*/	
	,singleOrRangeDateSearhCheck : function(srhName, srhCnt) {
		var exit = false;
		var strSrhStartVal = $("input[name='" + srhName +"']").next().val();
		var strSrhEndVal   = $("input[name='" + srhName +"']").next().next().next().val();
		var strCalQty= 0;
		
		if( this.isNull(strSrhStartVal) ){
			//alert("필수 검색 정보가 입력되지 않았습니다.");
			commonUtil.msgBox("MASTER_M0434");
			$("input[name='" + srhName +"']").next().focus();
			exit = true;	
			return exit;
		}
		
		if( !this.isNull(strSrhStartVal) && !this.isNull(strSrhEndVal) ){
			strCalQty = calDateCount(this.specialTextRemove(strSrhStartVal), this.specialTextRemove(strSrhEndVal));
			
			if(strCalQty > srhCnt){
	// 			alert("검색기간은 srhCnt 을 초과할수 없습니다.");
				alert(commonUtil.getMsg("OUT_M0217", srhCnt));
				exit = true;	
				return exit;
			}
			if(strCalQty < 0){
	// 			alert("검색기간을 확인해주세요.");
				commonUtil.msgBox("OUT_M0210");
				exit = true;
				return exit;
			}		
		}
		
		
		return exit;
	}
	
	/**
	* 창고 기준 현재 날짜/시간을 디비에서 조회해서 반환
	*
	* @param srhType : 리턴 조건
	*/
	,searchGetDbDateTime : function(srhType) {
		var rntVal;
		var param = new DataMap();
		
		var json = netUtil.sendData({
			module : "BLCOMMON",
			command : "SEARCHGETDATETIME",
			sendType : "map",
			param : param
		});
		
		if(srhType == "D"){
			rntVal = json.data["GETDATE"];
		}else if(srhType == "T"){
			rntVal = json.data["GETTIME"];
		}else{
			rntVal = "";
		}
		
		return rntVal;
	}
	
	,multiComboReset : function(areaId){
		var $selectList = $("#" + areaId).find("select");
		if( $selectList.length > 0 ){
			$selectList.each(function(){
				var $selectObj = $(this);
				if( !hausysUtil.isEmpty($selectObj.attr("UIInput")) ){
					if( $selectObj.attr("UIInput") == "M" ){
						$selectObj.change(function(){
							if( hausysUtil.isEmpty($selectObj.val()) ){
								inputList.resetRange($selectObj.attr("name"));
								inputList.setRangeDataParam(areaId);
								
								$selectObj.parent().find("button").remove();
							}
							
							var $button = $selectObj.parent().find("button");
							if( $button.length > 0 ){
								$button.each(function(){
									$(this).click(function(){
										if( $selectObj.parent().find("button").length == 0 ){
											$selectObj.find("option:eq(0)").prop("selected", true);
										}
									});
								});
							} else {
								$selectObj.find("option:eq(0)").prop("selected", true);
							}
						});
					}
				}
			});
		}
	}
	
	,getUniqueArray : function(array) {	    
	    var result = [];
	    $.each(array, function(index, element) {   // 배열의 원소수만큼 반복
	        if ($.inArray(element, result) == -1) {  // result 에서 값을 찾는다.  //값이 없을경우(-1)
	            result.push(element);              // result 배열에 값을 넣는다.
	        }
	    });
	    return result;
	}
	
	,getUniqueArrayCount : function(array) {	    
	    var result = [];
	    $.each(array, function(index, element) {   // 배열의 원소수만큼 반복
	        if ($.inArray(element, result) == -1) {  // result 에서 값을 찾는다.  //값이 없을경우(-1)
	            result.push(element);              // result 배열에 값을 넣는다.
	        }
	    });
	    return result.length;
	}
	
	,getPageUrl : function (){
		var popupLink = location.href;
		popupLink = popupLink.substring( popupLink, popupLink.lastIndexOf("/")+1);
		return popupLink;
	}
	
	/**
	 * 해당 개체의 disable 혹은 readonly 등의 속성을 처리(개체에 따라)
	 * @param {JQueryObject} _obj
	 * @param {Boolean} boolable - ex) true, false
	 * @returns NA
	 */
	,objNotInput : function (_obj, boolable) {	
		var attribute;
		
		if(_obj.is($("input[type='text']"))) {
			attribute = "readonly";
		}
		else {
			attribute = "disabled";
		}
		
		if(boolable) {
			_obj.removeAttr(attribute);
		}
		else {
			_obj.attr(attribute, attribute);
		}
	}
	
	/**
	 * 해당 개체안의 개체에 대한 disable, readonly등을 지정
	 * @param {String} strArea - id, 혹은 class
	 * @param {Boolean} boolable - ex) true, false
	 * @param {Array} exceptObjs - 제외할 개체에 대한 id 또는 name
	 * @returns NA
	 * @사용예 bl.objectsNotInput("areaData", false , ["ORG_CD","ORG_NM"])
	 * @대상 : input[type='text'],input[type='button'],select,textarea,button,input[type='checkbox']
	 */
	,objectsNotInput : function (strArea, boolable, exceptObjs) {
		var _objs;
		if($("#" + strArea).length >= 1) {
			_objs = $("#" + strArea);
		}
		else  if($("." + strArea).length >= 1) {
			_objs = $("." + strArea);
		}
		else {
			return;
		}
		
		
		if(exceptObjs == null || exceptObjs == undefined) {
			exceptObjs = new Array();
		}
		
		if((typeof exceptObjs) == "String") {
			eobjs = exceptObjs.split(",");
		} else {
			eobjs = exceptObjs;
		}
		
		var except = true;
		_objs.find(" input[type='text'],input[type='button'],select,textarea,button,input[type='checkbox']").each(function () {
			var i = 0;
			var len = eobjs.length;
			except = true;
			while(i < eobjs.length) {
				if(eobjs[i] == $(this).attr("id") || eobjs[i] == $(this).attr("name")) {
					except = false;
					break;
				}
				
				i++;
			}
			if(except) { 
				bl.objNotInput($(this), boolable);
			}
		});
	}
	/**
	 * 해당 개체의 개체에 따른 값 초기화(select는 첫번째 항목 선택)
	 * @param {JQueryObject} _obj
	 * @returns {Boolean}
	 * @사용예 objInitInputs("areaData", ["ORG_CD","ORG_NM"])
	 * @대상 : textarea, input[text,checkbox],select
	 */
	,objInitInput : function (_obj) {	
		var attribute;
		
		if(_obj.is($("select"))) {
			_obj.find("option:first").prop("selected",true);
			return true;
		}
		else if(_obj.is($("input[type='checkbox']"))) {
			_obj.prop("checked",false);
			return true;
		}
		else if(_obj.is($("input[uiinput='SR']"))){
//			console.log(_obj);
			inputList.resetRange($(_obj).name);
			return true;
		}
		else if(_obj.is($("input[uiinput='R']"))){
			inputList.resetRange($(_obj).name);
			return true;
		}
		else{
			_obj.val("");
			return true;
		}
		
		return false;
	}
	
	/**
	 * 해당 개체안의 개체에 대한 값을 초기화
	 * @param {String} strArea - id 혹은 클래스
	 * @param {Array} exceptObjs - 제외할 개체에 대한 id
	 * @returns NA
	 * @사용예 objInitInputs("areaData", ["ORG_CD","ORG_NM"])
	 */
	,objInitInputs : function (strArea, exceptObjs) {
		var _objs;
		
		if($("#" + strArea).length >= 1) {
			_objs = $("#" + strArea)
		}
		else if($("." + strArea).length >= 1) {
			_objs = $("." + strArea)
		}
		else {
			return;
		}
		
		
		var eobjs;
		
		if(exceptObjs == null || exceptObjs == undefined) {
			exceptObjs = new Array();
		}
		
		if((typeof exceptObjs) == "String") {
			eobjs = exceptObjs.split(",");
		} else {
			eobjs = exceptObjs;
		}
		
		var except = true;
		_objs.find(" input[type='text'],input[type='hidden'],input[type='checkbox'],input[uiinput='SR'],input[uiinput='R'],select,textarea").each(function () {
			except = true;
			var i = 0;
			var len = eobjs.length;
			while(i < eobjs.length) {
				if(eobjs[i] == $(this).attr("id") || eobjs[i] == $(this).attr("name")) {
					except = false;
					break;
				}
				
				i++;
			}
			if(except) bl.objInitInput($(this));
		});
	}
	
	/**
	 * 해당 그리드 리스트의 선택되고 수정된 데이터 와 삭제된 데이터를 리턴
	 * @param {String} gridId - gridList Id
	 * @returns {Array}
	 * @사용예 bl.getSelectDelModifyList("gridList")
	 */
	,getSelectDelModifyList : function (gridId) {
		var deleteList = gridList.getModifyList(gridId, "A");
		var list = new Array(); 
		var selectList = gridList.getSelectData(gridId);
		
		for(var i = 0; i < deleteList.length; i++) {
			if( deleteList[i].get(configData.GRID_ROW_STATE_ATT) == "D" ) {
				list.push(deleteList[i]);
			}
		}
		
		for(var i = 0; i < selectList.length; i++) {
			if( selectList[i].get(configData.GRID_ROW_STATE_ATT) != "R" ) {
				list.push(selectList[i]);
			}
		}
		
		return list;
	}
	,getWorkingDate : function (fromdate, diff) {
		if(bl.isNull(fromdate)) {
			return "";
		}
		else if(bl.isNull(diff)) {
			return "";
		}
		var param = new DataMap();
		param.put("FROMDATE",fromdate);
		param.put("DIFF",diff);
		var json = netUtil.send({
			url : "/GCLC/BL/json/getWORKINGDATE.data",
			param : param,
			async : false
		});
		
		return json.data;
	}
	,setPrintData : function (list) {
		var param = new DataMap();
		param.put("list",list);
		param.put("MENU_ID",configData.MENU_ID);
		var json = netUtil.send({
			url : "/GCLC/BLMD/json/setBarcode.data",
			param : param,
			async : false
		});
		
		if(bl.isNull(json) || bl.isNull(json.key)) {
			commonUtil.msgBox("BL_ERRORSETPRINTPARAM");		// 파라메터 생성중 오류가 발생하였습니다.
			return;
		}
		
		var dataMap = new DataMap();
		dataMap.put("P_SEQ_NO",json.key);
		
		return dataMap;
	}
	
	/*
	 * KHS 2020.06.16
	 * geocoding
	 * 주소정보를 api를 통해 법정동 코드 및 좌표로 변경하여 json 객체로 리턴
	 * 파라미터 : addr -> 검색할 주소(도로명, 법정동)
	 */
	,geocoding : function (addr) {
		var json = netUtil.send({
			url : "http://210.116.106.77:4774/gcenmap/wservice/geocoding?addr=" + encodeURIComponent(addr),
			async : false
		});
		
		var param = new DataMap();
		if(json.result.length == 1 && !bl.isNull(json.result[0])) {
			LDG_CD = json.result[0].bemdcode;
			if(json.result[0].ricode != "") {
				LDG_CD = json.result[0].ricode; 
			}
			else {
				LDG_CD = LDG_CD + "00";
			}
			param.put("SIDO_CD",json.result[0].sggcode);
			param.put("LDG_CD",LDG_CD);
			param.put("LAT",json.result[0].lat);
			param.put("LON",json.result[0].lon);
			param.put("UMTK_X_VAL",json.result[0].kx);
			param.put("UMTK_Y_VAL",json.result[0].ky);
			param.put("POST_NO",json.result[0].post);
			param.put("ADDR_CRT_ERR_YN","");
		}
		else {
			param.put("SIDO_CD","");
			param.put("LDG_CD","");
			param.put("LAT","");
			param.put("LON","");
			param.put("UMTK_X_VAL","");
			param.put("UMTK_Y_VAL","");
			param.put("POST_NO","");
			param.put("ADDR_CRT_ERR_YN","Y");
		}
		
		return param;
	}
	
	/*
	 * KHS 2020.07.21
	 * reversegeo
	 * 좌표정보를 주소정보로 변환하여 리턴
	 * 파라미터 : lon, lat -> 법정동주소
	 */
	,reversegeo : function (lon, lat) {
		var json = netUtil.send({
			url : "http://210.116.106.77:4774/gcenmap/wservice/reverse?lon=" + lon + "&lat=" + lat,
			async : false
		});
		
		var param = new DataMap();
		if(json.result.length == 1 && !bl.isNull(json.result[0])) {
			param.put("ADDR",json.result[0].sidoname + " " + json.result[0].sggname + " " + json.result[0].hemdname);
		}
		else {
			param.put("ADDR","");
		}
		
		return param;
	}
	
	/*
	 * KHY
	 * gridDuplicationCheck
	 * grid list에 해당 컬럼의 데이타 중복 여부 체크 (현재 보여지고 있는 데이타 기준)
	 * 파라미터 : gridId -> 중복 체크 할 그리드 ID ,
	 *          colName -> 중복 체크 할 컬럼명,
	 *          colValue -> 중복 체크 값
	 *          rowNum -> 중복 체크 제외 로우번호
	 */
	, gridDuplicationCheck : function(gridId, colName, colValue, rowNum) {
		var tmpRowNum;
		var viewDataList = gridList.getGridBox(gridId).viewDataList;
		if(typeof rowNum == "undefined") rowNum = "-1";
		for(var i=0;i<viewDataList.length;i++){
			tmpRowNum = viewDataList[i];
			if(tmpRowNum != rowNum){
				var tmpValue = gridList.getColData(gridId,tmpRowNum, colName);
				if(colValue == tmpValue){
					return false;
				}			
			}
		}
		
		return true;
	}
	
	/*
	 * KHY 2020.04.17
	 * dataListcontainsIndex
	 * datamap list에서 파라티터 value 값 존재 하는 index 리턴
	 * 파라미터 : list -> 인덱스를 찾을 datamap list
	 *          value -> 찾을 value
	 */
	
	, dataListcontainsIndex : function(list,value) {
		if(typeof list != "object") return false;
		for(var i=0;i < list.length; i++){
			var map = list[i];
			if(map.containsValue(value)){
				return i;
			}
		}
		return false;
	}
	
	/*
	 * KHY 2020.04.17
	 * dataListcontainsIndex
	 * datamap list에서 파라티터 value 값 존재 하는 index 리턴
	 * 파라미터 : list -> 인덱스를 찾을 datamap list
	 *          value -> 찾을 value
	 */
	
	, dataListcontainsCnt : function(list,key,value) {
		if(typeof list != "object") return false;
		var cnt = 0;
		for(var i=0;i < list.length; i++){
			var map = list[i];
			if(map[key] == value){
				cnt++;
			}
		}
		return cnt;
	}
	/**
	* 지정 그리드의 필터 조건에 맞는 찾아 DataMap 배열로 반환 (KHS 2020.06.24)
	* param : (String) gridId
	* param : (json) filterMap
	*			colName > 비교할 컬럼
	*			condition > 비교조건  ex) == , => , <=, != 
	*			colValue > 비교 값 (숫자, 문자)
	* return : Array[DataMap]
	* ex : filterMap = {"colName" : "ACT_DT" , "condition" : "==" , "colValue" : "20200624"}
	*      or 
	*      filterMap = [{"colName" : "ACT_DT" , "condition" : ">=" , "colValue" : "20200624"}
	*                  {"colName" : "ACT_DT" , "condition" : "<=" , "colValue" : "20200630"}]
	*		gridListGetFilterList(gridId, filterMap) 
	*/
	, gridListGetFilterList : function (gridId, filtersMap) {
		var list = gridList.getGridAvailData(gridId, true);
		var fMap = new Array();
		if(Array.isArray(filtersMap)) {
			fMap = filtersMap;
		}
		else {
			fMap.push(filtersMap);
		}
		
		var rtnList = new Array();
		
		for(var j = 0; j < fMap.length; j++) {
			rtnList = new Array();
			if(fMap[j] == undefined) return rtnList;
			if(fMap[j].colName == undefined) return rtnList;
			if(fMap[j].condition == undefined) return rtnList;
			if(fMap[j].colValue == undefined) return rtnList;
			
			for(var i = 0; i < list.length; i++) {
				colVal = list[i].get(fMap[j].colName);
				if(eval(colVal + fMap[j].condition + fMap[j].colValue)) {
					rtnList.push(list[i]);
				}
			}
			
			list = rtnList;
		}
		
		return rtnList;
	}
	
	/**
	* loc의 내용을 저장할 배열변수 
	*/
	, locBank : new Array()
	
	/**
	* 지정 배송처의 좌표를 찾아 리턴하는 함수 (KHS 2020.06.24)
	* param : (String) CD > 배송처 코드
	* param : (function) callbackFunction
	*			DataMap.LON > 위도
	*			DataMap.LAT > 경도 
	* ex : getLoc("12345", function (data) { console.log(data.get("LAT")); }); 
	*/
	, getLoc : function (CD, callbackFunction) {
		var param = new DataMap();
		param.put("LAT","");
		param.put("LON","");
		
		for(var i = 0; i < bl.locBank.length; i++) {
			if(bl.locBank[i].get("CD") == CD) {
				param.put("LON",bl.locBank[i].get("LON"));
				param.put("LAT",bl.locBank[i].get("LAT"));
				break;
			}
		}
		
		if(param.get("LAT") == "" || param.get("LON") == "") {
			param.put("CLNT_CD", CD);
			var json = netUtil.sendData({
				module : "BLCOMMON",
				command : "GETBZPTN",
				sendType : "map",
				param : param,
				async : false
			});
			
			if(json.data) {
				param.put("LON",json.data.LON);
				param.put("LAT",json.data.LAT);
			}
			else {
				param.put("LON","");
				param.put("LAT","");
			}
			bl.locBank.push(param);
		}
		
		if(callbackFunction && {}.toString.call(callbackFunction) === '[object Function]') {
			return callbackFunction(param);
		}
		else {
			return bl.locBank;
		}
	}
	,getWeekDays : function (dt) {
		if(bl.isNull(dt)) {
			return "";
		}
		
		var param = new DataMap();
		param.put("DT",dt);

		var json = netUtil.send({
			url : "/GCLC/BL/json/getWeekDays.data",
			param : param,
			async : false
		});
		
		return json.data;
	}
	,getAddressInfoByBzptn : function (clntCd) {
		if(bl.isNull(clntCd)) {
			return "";
		}
		
		var param = new DataMap();
		param.put("CLNT_CD",clntCd);

		var json = netUtil.send({
			url : "/GCLC/BL/json/getAddressInfoByBzptn.data",
			param : param,
			async : false
		});
		
		return json.data;
	}

	,errorSound : function () {
	    var audio = document.createElement('audio');
	    audio.setAttribute('src', '/common/theme/webdek/sounds/beep_error.mp3');
	    
	    audio.play();
	}
	
	, successSound : function(){
	    var audio = document.createElement('audio');
	    audio.setAttribute('src', '/common/theme/webdek/sounds/beep_success.mp3');
	    
	    audio.play();
	}
} 

var bl = new BlCommon();