Validate = function() {

};

// 설정된 validate에 대한 확인을 해준다.
Validate.prototype = {
	check : function(vId, rangeCheckType) {
		var checkResult = true;
		var $areaObj = commonUtil.getArea(vId);
		if(rangeCheckType == undefined){
			rangeCheckType = true;
		}
		if(rangeCheckType){
			checkResult = inputList.checkValidation();
			if(!checkResult){
				return false;
			}
		}
		return this.checkList($areaObj);
	},
	checkList : function($areaObj) {
		var $checkList = $areaObj.find("["+configData.VALIDATION_ATT+"]");
		
		var checkResult = true;
		var $findObj;
		
		for(var index=0;index<$checkList.length;index++){
			$findObj = $checkList.eq(index);
			/*
			if($findObj.attr("readonly")){
				continue;
			}
			*/
			
			var valueText;
			var inputType = $findObj.attr("type");
			if(inputType && inputType == "checkbox" || inputType == "radio"){
				var nameText = $findObj.attr("name");
				if($areaObj.find("[name='"+nameText+"']").filter("[checked=checked]").length == 0){
					valueText = "";
				}
			}else{
				valueText = $findObj.val();
			}
			var valAtt = $findObj.attr(configData.VALIDATION_ATT);
			
			var valList = valAtt.split(" ");
			var ruleList;
			var ruleText;
			var optionText;
			for(var j=0;j<valList.length;j++){
				ruleList = valList[j].split(",");
				if(ruleList[0].indexOf("(") == -1){
					ruleText = ruleList[0];
					if(ruleList.length == 1 && ruleList[0] == configData.VALIDATION_REQUIRED){
						//optionText = $findObj.parent().prev().text();
						optionText = theme.getValidataInputText($findObj);
						optionText = commonUtil.replaceAll(optionText, " ", "");
						valList[j] = ruleText+"("+optionText+")";
					}else if(ruleList.length == 1 && ruleText == configData.VALIDATION_DATE){
						valueText = uiList.getDateDataFormat(valueText);
					}
				}else{
					ruleText = ruleList[0].substring(0,ruleList[0].indexOf("("));
					optionText = ruleList[0].substring(ruleList[0].indexOf("(")+1, ruleList[0].length-1);
					if(ruleList.length == 1 && ruleText == configData.VALIDATION_REQUIRED){
						optionText = uiList.getLabel(optionText);
						optionText = commonUtil.replaceAll(optionText, " ", "");
						valList[j] = ruleText+"("+optionText+")";
					}
				}
				
				checkResult = this.checkObject(valueText, valList[j], $findObj, configData.VALIDATION_OBJECT_TYPE_INPUT, $findObj.attr("id"), $findObj.attr("id"), $findObj.attr("name"));
				if(!checkResult){
					break;
				}
			}
			if(!checkResult){
				$findObj.focus();
				break;
			}
		}
		
		return checkResult;
	},
	checkObject : function(valueText, valAtt, $colObj, valObjType, objId, objIndex, objName) {
		var checkResult = true;
		var $findObj;
		
		var ruleText;
		var optionText;
		
		var msgCode;
		
		var valList = valAtt.split(" ");
		for(var i=0;i<valList.length;i++){	
			optionText = "";
			var ruleList = valList[i].split(",");				
			
			msgCode = ruleList[1];
			if(ruleList[0].indexOf("(") == -1){
				ruleText = ruleList[0];
				optionText = "true";
			}else{
				ruleText = ruleList[0].substring(0,ruleList[0].indexOf("("));
				optionText = ruleList[0].substring(ruleList[0].indexOf("(")+1, ruleList[0].length-1);
			}			

			valueText = $.trim(valueText);
			var valueLength = valueText.length;
			
			if(ruleText == "required"){					
				if(valueText == ""){
					checkResult = false;
					break;
				}
			}else if(ruleText == "minlength"){
				var minNum = parseInt(optionText);
				if(valueLength < minNum){
					checkResult = false;
					break;
				}
			}else if(ruleText == "maxlength"){
				var maxNum = parseInt(optionText);
				if(valueLength > maxNum){
					checkResult = false;
					break;
				}
			}else if(ruleText == "rangelength"){
				var optionList = optionText.split(",");
				var minNum = parseInt(optionList[0]);
				var maxNum = parseInt(optionList[1]);
				if(valueLength < minNum || valueLength > maxNum){
					checkResult = false;
					break;
				}
			}else if(ruleText == "email"){
				if(valueText){
					var regCheck = /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$/i.test(valueText);
					if(!regCheck){
						checkResult = false;
						break;
					}
				}
			}else if(ruleText == "url"){
				if(valueText){
					var regCheck = /^(https?|ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(\#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(valueText);
					if(!regCheck){
						//errorMsg = commonUtil.format(this.msg(ruleText), labelAtt);
						checkResult = false;
						break;
					}
				}
			}else if(ruleText == "number"){
				if(valueText){
					var regCheck;
					if(site.decimalSeparator == "."){
						regCheck = /^-?(?:\d+|\d{1,3}(?:,\d{3})+)(?:\.\d+)?$/.test(valueText);
					}else{
						regCheck = /^-?(?:\d+|\d{1,3}(?:.\d{3})+)(?:\,\d+)?$/.test(valueText);
					}
					if(!regCheck){
						checkResult = false;
						break;
					}
				}
			}else if(ruleText == "digits"){
				if(valueText){
					var regCheck = /^\d+$/.test(valueText);
					if(!regCheck){
						checkResult = false;
						break;
					}
				}
			}else if(ruleText == "tel"){
				if(valueText){
					var regCheck = /^\d{2,4}-\d{3,4}-\d{4}$/.test(valueText);
					if(!regCheck){
						checkResult = false;
						break;
					}
				}
			}else if(ruleText == "phone"){
				if(valueText){					
					var regCheck = /^\d{11,11}$/.test(valueText);
					if(!regCheck){
					//if(valueLength < 9){
						checkResult = false;
						break;
					}else if(valueText.substring(0,1) != "0"){
						checkResult = false;
						break;
					}else if(valueText.substring(0,2) == "01"){
						if(valueLength < 10){
							checkResult = false;
							break;
						}
					}
				}
			}else if(ruleText == "equalTo"){
				if(valueText != optionText){
					checkResult = false;
					break;
				}
			}else if(ruleText == "unequal"){
				if(valueText == optionText){
					checkResult = false;
					break;
				}
			}else if(ruleText == "min"){
				if(isNaN(valueText)){
					checkResult = false;
					break;
				}
				var minNum = parseFloat(optionText);
				var valueNum = parseFloat(valueText)
				if(valueNum < minNum){
					checkResult = false;
					break;
				}
			}else if(ruleText == "max"){
				if(isNaN(valueText)){
					checkResult = false;
					break;
				}
				var maxNum = parseFloat(optionText);
				var valueNum = parseFloat(valueText)
				if(valueNum > maxNum){
					checkResult = false;
					break;
				}
			}else if(ruleText == "gt"){
				if(isNaN(valueText)){
					checkResult = false;
					break;
				}
				var minNum = parseFloat(optionText);
				var valueNum = parseFloat(valueText)
				if(valueNum <= minNum){
					checkResult = false;
					break;
				}
			}else if(ruleText == "lt"){
				if(isNaN(valueText)){
					checkResult = false;
					break;
				}
				var maxNum = parseFloat(optionText);
				var valueNum = parseFloat(valueText)
				if(valueNum >= maxNum){
					checkResult = false;
					break;
				}
			}else if(ruleText == "pair"){
				var $pObj = jQuery("#"+optionText);
				var pValueText = $pObj.val();
				if(valueText != "" && pValueText == ""){					
					checkResult = false;
					break;
				}
				if(valueText == "" && pValueText != ""){					
					checkResult = false;
					break;
				}
			}else if(ruleText == "between"){
				var $pObj = jQuery("#"+optionText);
				var pValueText = $pObj.val();
				var pLabelAtt = $pObj.attr(configData.DATA_LABEL_ATT);
				if(pLabelAtt){
					pLabelAtt += this.msg("msgAnd");
				}else{
					pLabelAtt = "";
				}
				if(valueText > pValueText){				
					checkResult = false;
					break;
				}
			}else if(ruleText == "equal"){
				var $pObj = jQuery("#"+optionText);
				var pValueText = $pObj.val();
				var pLabelAtt = $pObj.attr(configData.DATA_LABEL_ATT);

				if(valueText != pValueText){				
					checkResult = false;
					break;
				}
			}else if(ruleText == "remote"){
				var remoteRs = false;
				try{
					remoteRs = eval(optionText+"('"+valueText+"', '"+objIndex+"', '"+objName+"')");
				}catch(e){}
				if(!remoteRs){
					checkResult = false;
					break;
				}
			}else if(ruleText == "duplication"){
				var remoteRs = false;
				try{
					remoteRs = eval(optionText+"('"+valueText+"', '"+objIndex+"', '"+objName+"')");
				}catch(e){}
				if(!remoteRs){
					checkResult = false;
					break;
				}
			}else if(ruleText == "date"){
				if(valueText){
					//valueText = uiList.getDateDataFormat(valueText);
					if(!this.isValidDate(valueText)){
		            	checkResult = false;
						break;
		            }
				}
				
				//2022.05.29 이범준 [Date Between] from ~ to 필수 체크
				if(site.dateBetweenCheck){
					if(valueText == ""){
						var rangeMap = inputList.rangeMap;
						if(rangeMap != undefined && rangeMap != null){
							if(rangeMap.containsKey(objName)){
								var inputRangeMap = rangeMap.get(objName);
								var inputAtt = inputRangeMap.inputAtt;
								if(inputAtt != undefined && inputAtt != "" && inputAtt == configData.INPUT_BETWEEN){
									msgCode = "";
									if($colObj.index() == 1){
										msgCode = "VALID_fromdate"; //label
									}else if($colObj.index() == 4){
										msgCode = "VALID_todate";   //label
									}
									checkResult = false;
									break;
								}
							}
						}
					}
				}
				
				/*
				var dateFormat = 'yyyymmdd';
				var ListofDays = [0,31,29,31,30,31,30,31,31,30,31,30,31];

				try{
					if(valueText){
						valueText = uiList.getDateDataFormat(valueText);
						var year = new Number(valueText.substring(0, 4));
			            var month = new Number(valueText.substring(4, 6));
			            var day = new Number(valueText.substring(6, 8));
		
			            if(isNaN(year) || isNaN(month) || isNaN(day)){
			            	checkResult = false;
							break;
			            }
			            if(month < 1 || month > 12){
			            	checkResult = false;
							break;
			            }
			            if(day < 1 || day > ListofDays[month]){
			            	checkResult = false;
							break;
			            }
					}		            
				}catch(e){}*/
			}else if(ruleText == "excel"){
				if(valueText){
					var extName = valueText.substring(valueText.lastIndexOf(".")+1);
					extName = extName.toLowerCase();
					if(extName != "xls" && extName != "xlsx"){
						checkResult = false;
						break;
					}
				}
			}else if(ruleText == "image"){
				if(valueText){
					var extName = valueText.substring(valueText.lastIndexOf(".")+1);
					extName = extName.toLowerCase();
					if(extName != "gif" && extName != "jpg" && extName != "png"){
						checkResult = false;
						break;
					}
				}
			}
		}
		
		if(checkResult){
			return true;
		}else{
			//commonUtil.msg(errorMsg);
			var param = new Array();
			if(optionText){
				param.push(optionText);
			}
			param.push(valueText);

			var msg = this.getMsg(valObjType, objId, objIndex, objName, valueText, ruleText, msgCode, param);
			//commonUtil.msg(msg);
			//2020.12.09 이범준
			if(configData.isMobile){
				if(valObjType == "grid"){
					mobileCommon.alert({
						message : msg,
						confirm : function(){
							if(objId != undefined && objIndex > -1 && objName != undefined){
								setTimeout(function(){
									try {
										gridList.setColFocus(objId, objIndex, objName);
									} catch (e) {
										$("#alert").fadeOut(300);
									}
								},300);
							}
						}
					});
				}else{
					mobileCommon.alert({
						message : msg,
						confirm : function(){
							if(areaId != undefined && areaId != null && $.trim(areaId) != "" ){
								try {
									mobileCommon.select("",areaId,objName);
								} catch (e) {
									$("#alert").fadeOut(300);
								}
							}else{
								$("#alert").fadeOut(300);
							}
						}
					});
				}
			}else{
				commonUtil.msg(msg);
			}
			
			return false;
		}
	},
	getMsg : function(valObjType, objId, objIndex, objName, objValue, ruleText, msgCode, param) {
		var msg;
		if(msgCode){
			msg = commonUtil.getMsg(msgCode, param);
		}else{
			//event fn
			if(commonUtil.checkFn("validationEventMsg")){
				msg = validationEventMsg(valObjType, objId, objIndex, objName, objValue, ruleText);
				msg = commonUtil.format(msg, param);
			}
		}
		
		if(!msg){
			msg = commonUtil.getMsg(configData.VALIDATE_MSG_GROUPKEY+"_"+ruleText, param);
			//msg = configData.VALIDATE_MSG.get(valType);
			msg = commonUtil.format(msg, param);
		}
		
		return msg;
	},
	isValidDate : function(param) {
        try
        {
            //param = param.replace(/-/g,'');
 
            // 자리수가 맞지않을때
            if( isNaN(param) || param.length!=8 ) {
                return false;
            }
             
            var year = Number(param.substring(0, 4));
            var month = Number(param.substring(4, 6));
            var day = Number(param.substring(6, 8));
 
            var dd = day / 0;
 
             
            if( month<1 || month>12 ) {
                return false;
            }
             
            var maxDaysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
            var maxDay = maxDaysInMonth[month-1];
             
            // 윤년 체크
            if( month==2 && ( year%4==0 && year%100!=0 || year%400==0 ) ) {
                maxDay = 29;
            }
             
            if( day<=0 || day>maxDay ) {
                return false;
            }
            return true;
 
        } catch (err) {
            return false;
        }                       
    },
	toString : function() {
		return "Validate";
	}
};

var validate = new Validate();