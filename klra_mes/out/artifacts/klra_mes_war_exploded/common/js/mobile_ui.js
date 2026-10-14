UIList = function() {
	this.selectTreeNode = new DataMap();
	this.oEditors = [];
	this.btnMap = new DataMap();
	this.$dateUi = jQuery("<input type='hidden' />");
	this.shortKeyBtnMap = new DataMap();
	
	this.$getVariant = null;
	this.$saveVariant = null;
	
	this.autocompleteMap = new DataMap();
	
	this.dateDefaultMap = new DataMap();
	
	this.lastBtnName;
	
	this.actionMap = new DataMap();
};

UIList.prototype = {
	// UI로 설정된 객체를 UI로 지정해준다.
	actionCheck : function() {
		var $obj = jQuery('body');
		$obj.find('['+configData.ACTION_ATT+"]").each(function(i,findElement){
			var $tObj = jQuery(findElement);
			var aCode = $tObj.attr(configData.ACTION_ATT);
			var removeType = false;
			if(aCode.substring(0,1) == "!"){
				aCode = aCode.substring(1);
				removeType = uiList.actionMap.containsKey(aCode);
			}else{
				removeType = !uiList.actionMap.containsKey(aCode);
			}
			
			if(removeType){
				$tObj.remove();
			}
		});
	},
	UICheck : function($obj) {
		if(!$obj){
			$obj = jQuery('body');
		}
		var ui = this;
		
		$obj.find('['+configData.LABEL_ATT+"]").each(function(i,findElement){
			var $tObj = jQuery(findElement);
			//var lCode = $tObj.attr(configData.LABEL_ATT).split(",");
			var labelTxt = ui.getLabel($tObj.attr(configData.LABEL_ATT));
			var tag = $tObj[0].tagName;
			var tmpTxt = $tObj.text();
			if(tmpTxt.indexOf("*") != -1){
				tmpTxt = " *";
			}else{
				tmpTxt = "";
			}
			if(tag == "INPUT" || tag == "BUTTON"){
				$tObj.val(labelTxt+tmpTxt);
			}else{
				$tObj.text(labelTxt+tmpTxt);
			}			
		});
		
		$obj.find('['+configData.BUTTON_ATT+"]").each(function(i,findElement){
			var $tObj = jQuery(findElement);
			var bCode = $tObj.attr(configData.BUTTON_ATT).split(" ");
			var bName = bCode[0];
			var bType = bCode[1];
			var lCode = bCode[2];
			var activeType = bCode[3];
			$tObj.addClass(configData.BUTTON_CLASS);
			$tObj.attr(configData.BUTTON_TYPE_ATT, bType);
			$tObj.attr(configData.BUTTON_NAME_ATT, bName);
			if(activeType){
				if(activeType=="false"){
					//$tObj.addClass(configData.BUTTON_INACTIVE_CLASS);
					$tObj.hide();
				}
			}else{
				activeType = "true";
			}
			$tObj.attr(configData.BUTTON_ACTIVE_TYPE_ATT, activeType);
			
			var iconClass = theme.BUTTON_ICON.get(bType);
			var labelTxt = ui.getLabel(lCode);
			var titleTxt = labelTxt;
			
			if(bName == configData.BUTTON_COMMAND_SEARCH){
				titleTxt += " [alt+"+site.COMMON_KEY_EVENT_SEARCH+"]";
			}else if(bName == configData.BUTTON_COMMAND_SAVE){
				titleTxt += " [alt+"+site.COMMON_KEY_EVENT_SAVE+"]";
			}else if(bName == configData.BUTTON_COMMAND_CREATE){
				titleTxt += " [alt+"+site.COMMON_KEY_EVENT_CREATE+"]";
			}
			
			var shortKey = $tObj.attr(configData.SHORT_KET_ATT);
			if(shortKey){
				uiList.shortKeyBtnMap.put(shortKey, $tObj);
				titleTxt += " [alt+"+shortKey+"]";
			}
			
			$tObj.attr("title", titleTxt);
			$tObj.text("");
			theme.setInputBtn($tObj, iconClass, labelTxt);
			
			if(bType == configData.BUTTON_TYPE_GETVARIANT){
				var $tmpGetVariant = "<span class='variant'>"
								+ "<span> Key : <select class='viewData' id='getVariantList' onChange='inputList.changeVariant(this)'><option value=''>-----</optioin></select></span>"
								+ "</span>";
				uiList.$getVariant = jQuery($tmpGetVariant);
				var $tmpDelete = jQuery("<span> <button type='button' class='deletebtn'>-</button> </span>");
				$tmpDelete.click(function(event){
					var $getVariantList = jQuery("#getVariantList");
					var tmpValue = $getVariantList.val();
					if(tmpValue){
						var param = new DataMap();
						param.put("PARMKY", tmpValue);
						param.put("PROGID", configData.MENU_ID);
						var json = netUtil.sendData({
							url : site.commonUrl+"/variant/json/delete.data",
					    	param : param
						});
						if(json && json.data){
							//alert(JSON.stringify(json));
							$getVariantList.find("[value="+tmpValue+"]").remove();
						}
					}
				});
				uiList.$getVariant.append($tmpDelete);
				var $tmpGetClose = jQuery("<span> <button type='button' class='closer2'>X</button> </span>");
				$tmpGetClose.click(function(event){
					uiList.$getVariant.hide();
				});
				uiList.$getVariant.append($tmpGetClose);
				
				$tObj.after(uiList.$getVariant);
			}else if(bType == configData.BUTTON_TYPE_SAVEVARIANT){
				var $tmpSaveVariant = "<span class='variant' id='saveVariant'>"
								+ "<span> Key: <input type='text' class='viewData' name='saveVariantPARMKY' /></span>"
								+ "<span> Desc : <input type='text' class='viewData' name='saveVariantSHORTX' /></span>"
								+ "<span> Default : <input class=variantDefault type='checkbox' name='saveVariantDEFCHK' value='"+site.defaultCheckValue+"' CheckEmptyVal='"+site.emptyValue+"'/></span>"
								+ "</span>";
				uiList.$saveVariant = jQuery($tmpSaveVariant);
				
				var $tmpSaveBtn = jQuery("<span> <button type='button' class='savebtn'>X</button> </span>");
				$tmpSaveBtn.click(function(event){
					//uiList.$saveVariant.hide();
					//if(validate.check("saveVariant")){
						var map = dataBind.paramData("saveVariant");						
						if(!map.containsKey("saveVariantPARMKY") || $.trim(map.get("saveVariantPARMKY")) == ""){
							commonUtil.msgBox(configData.VALIDATE_MSG_GROUPKEY+"_"+configData.VALIDATION_REQUIRED);
							$("#saveVariant").find("[name='saveVariantPARMKY']").focus();
							return;
						}
						map.put("PARMKY", map.get("saveVariantPARMKY"));
						if(!map.containsKey("saveVariantSHORTX") || $.trim(map.get("saveVariantSHORTX")) == ""){
							commonUtil.msgBox(configData.VALIDATE_MSG_GROUPKEY+"_"+configData.VALIDATION_REQUIRED);
							$("#saveVariant").find("[name='saveVariantSHORTX']").focus();
							return;
						}
						map.put("SHORTX", map.get("saveVariantSHORTX"));
						map.put("DEFCHK", map.get("saveVariantDEFCHK"));
						var $getVariantList = jQuery("#getVariantList");
						if($getVariantList.find("[value="+map.get("PARMKY")+"]").length > 0){
							map.put("UCOUNT", "1");
						}
						
						map.put("PROGID", configData.MENU_ID);
						var param = inputList.getSearchAreaVariant();
						map.put("saveVariant", param);
						//alert(map.toString());
						var json = netUtil.sendData({
							url : site.commonUrl+"/variant/json/insert.data",
					    	param : map
						});
						if(json && json.data){
							//alert(JSON.stringify(json));
							if($getVariantList.find("[value="+map.get("PARMKY")+"]").length == 0){
								var tmpHtml = "<option value='"+map.get("PARMKY")+"'>["+map.get("PARMKY")+"]"+map.get("SHORTX")+"</option>";
								$getVariantList.append(tmpHtml);
							}							
						}
					//}					
				});
				uiList.$saveVariant.append($tmpSaveBtn);
				
				var $tmpSaveClose = jQuery("<span> <button type='button' class='closer2'>X</button> </span>");
				$tmpSaveClose.click(function(event){
					uiList.$saveVariant.hide();
				});
				uiList.$saveVariant.append($tmpSaveClose);
				
				$tObj.after(uiList.$saveVariant);
			}
			
			$tObj.click(function(event){
				var $obj = jQuery(event.target);
				var $btnObj = theme.getInputBtnObj($obj);
				var active = $btnObj.attr(configData.BUTTON_ACTIVE_TYPE_ATT);
				var btnName = $btnObj.attr(configData.BUTTON_NAME_ATT);
				var btnType = $btnObj.attr(configData.BUTTON_TYPE_ATT);
				var btnMCheck = $btnObj.attr(configData.BUTTON_MODIFY_CHECK_ATT);
				if(btnType == configData.BUTTON_TYPE_GETVARIANT){
					uiList.$getVariant.show();
				}else if(btnType == configData.BUTTON_TYPE_SAVEVARIANT){
					uiList.$saveVariant.show();
				}
				if(active == "true"){
					if(commonUtil.isDisplayLoading()){
						commonUtil.msgBox("MASTER_LOADING");//다른 명령 실행중으로 중복 실행이 불가합니다.
					}else{
						if((btnName == configData.BUTTON_COMMAND_SEARCH || btnMCheck) && !checkGridModifyState("MASTER_GRIDMODIFYSEARCH")){//수정된 그리드 데이터가 있습니다.\n저장하지 않고 조회 하시겠습니까?						
							return;
						}
						//event fn
						if(commonUtil.checkFn("commonBtnClick")){
							commonBtnClick(btnName);
						}
						uiList.lastBtnName = btnName;
					}
				}
			});			
			
			if(ui.btnMap.containsKey(bName)){
				//alert("중복 버튼 생성 : "+bName);
			}
			ui.btnMap.put(bName, $tObj);
		});
		
		$obj.find('['+configData.INPUT_FORMAT+"]").each(function(i,findElement){
			var $tObj = jQuery(findElement);
			var inputObj = $tObj;
			var inputAtt = $tObj.attr(configData.INPUT);
			if(inputAtt == configData.INPUT_RANGE || inputAtt == configData.INPUT_SHORT_RANGE || inputAtt == configData.INPUT_BETWEEN){
				return;
			}
			var formatAtt = $tObj.attr(configData.INPUT_FORMAT);
			var validateAtt = "";
			
			if(formatAtt){
				var formatList = formatAtt.split(" ");
				if($tObj.val()){
					var tmpValue = uiList.getDataFormat(formatList, $tObj.val(), true);
					$tObj.val(tmpValue);
				}
				var sizeList;
				if(formatList.length > 1){
					sizeList = formatList[1].split(",");
				}
				
				if(formatList[0] == configData.INPUT_FORMAT_STRING || formatList[0] == configData.INPUT_FORMAT_UPPERCASE || formatList[0] == configData.INPUT_FORMAT_LOWERCASE){
					if(sizeList){
						$tObj.attr("maxlength",sizeList[0]);
					}
					if(formatList[0] == configData.INPUT_FORMAT_UPPERCASE){
						$tObj.addClass(configData.INPUT_FORMAT_UPPERCASE_CLASS);
						/*
						$tObj.keyup(function(event){
							var tmpValue = inputObj.val();
							tmpValue = tmpValue.toUpperCase();
							inputObj.val(tmpValue);
						});
						*/
					}else if(formatList[0] == configData.INPUT_FORMAT_LOWERCASE){
						$tObj.addClass(configData.INPUT_FORMAT_LOWERCASE_CLASS);
						/*
						$tObj.keyup(function(event){
							var tmpValue = inputObj.val();
							tmpValue = tmpValue.toLowerCase();
							inputObj.val(tmpValue);
						});
						*/
					}
				}else if(formatList[0] == configData.INPUT_FORMAT_NUMBER_STRING){
					validateAtt = configData.VALIDATION_NUMBER;
					$tObj.addClass(configData.INPUT_NUMBER_CLASS);
					
					$tObj.attr("maxlength",formatList[1]);
					
					$tObj.keyup(function(event){
						if(commonUtil.numberKeyCheck(event)){
							return;
						}
						var $obj = $(event.target);
						var tmpValue = $obj.val();
						tmpValue = tmpValue.replace(/[^\d]+/g, '');
						$obj.val(tmpValue);				
					});
					$tObj.change(function(event){
						var $obj = $(event.target);
						var tmpValue = $obj.val();
						tmpValue = tmpValue.replace(/[^\d]+/g, '');
						$obj.val(tmpValue);
					});
				}else if(formatList[0] == configData.INPUT_FORMAT_KO_STRING){
					validateAtt = configData.VALIDATION_NUMBER;
					$tObj.addClass(configData.INPUT_NUMBER_CLASS);
					
					$tObj.attr("maxlength",formatList[1]);
					
					$tObj.keyup(function(event){
						var $obj = $(event.target);
						var tmpValue = $obj.val();
						tmpValue = tmpValue.replace(/[a-z0-9]|[ \[\]{}()<>?|`~!@#$%^&*-_+=,.;:\"'\\]/g, '');
						$obj.val(tmpValue);				
					});
					$tObj.change(function(event){
						var $obj = $(event.target);
						var tmpValue = $obj.val();
						tmpValue = tmpValue.replace(/[a-z0-9]|[ \[\]{}()<>?|`~!@#$%^&*-_+=,.;:\"'\\]/g, '');
						$obj.val(tmpValue);
					});
				}else if(formatList[0] == configData.INPUT_FORMAT_NUMBER){
					validateAtt = configData.VALIDATION_NUMBER;
					$tObj.addClass(configData.INPUT_NUMBER_CLASS);
					
					var sizeList;
					if(formatList.length > 1){
						sizeList = formatList[1].split(",");
					}
					if(sizeList){
						var numberLength = parseInt(sizeList[0]);
						var commaLength = parseInt((maxLength-1)/3);
						var maxLength = numberLength + commaLength;
						if(sizeList.length > 1){
							maxLength += parseInt(sizeList[1])+1;
						}		
						$tObj.attr("maxlength",maxLength);
						$tObj.keyup(function(event){
							/*
							if(commonUtil.numberKeyCheck(event, [",","."])){
								return;
							}
							*/
							var $obj = $(event.target);
							var tmpValue = $obj.val();
							var tmpArray = tmpValue.split(",");
							var tmpMaxLength = numberLength+tmpArray.length-1;
							if(sizeList.length > 1){
								tmpMaxLength += parseInt(sizeList[1])+1;
							}
							$obj.attr("maxlength",tmpMaxLength);
							if(sizeList.length == 1){
								if(commonUtil.numberKeyCheck(event, [","])){
									return;									
								}
								tmpValue = tmpValue.replace(/[^\d]+/g, '');
								$obj.val(tmpValue);
							}else{
								if(commonUtil.numberKeyCheck(event, [",","."])){
									return;					
								}
								if(sizeList.length == 1){
									tmpValue = tmpValue.replace(/[^\d]+/g, '');
									$obj.val(tmpValue);
								}else{
									var tmpNumber = tmpValue.split(".");
									if(tmpNumber == 1){
										tmpValue = tmpValue.replace(/[^\d]+/g, '');
									}else{
										tmpValue = tmpNumber[0].replace(/[^\d]+/g, '');
											+ site.decimalSeparator
											+ tmpNumber[1].replace(/[^\d]+/g, '');										
									}
									$obj.val(tmpValue);
								}
							}							
						});
					}
					
					var inputObj = $tObj;
					$tObj.change(function(event){
						var tmpValue = uiList.getDataFormat(formatList, inputObj.val(), true);
						inputObj.val(tmpValue);
					});
					$tObj.blur(function(event){
						var tmpValue = uiList.getDataFormat(formatList, inputObj.val(), true);
						inputObj.val(tmpValue);
					});
					
					$tObj.addClass(configData.INPUT_NORMAL_CLASS);
				}else if(formatList[0] == configData.INPUT_FORMAT_CALENDER || formatList[0] == configData.INPUT_FORMAT_DATE){
					var now = new Date();
					if(formatList[1]){
						uiList.dateDefaultMap.put($tObj.attr("name"), formatList[1]);
						if(formatList[1] == configData.INPUT_FORMAT_CALENDER_TOMORROW){
							formatList[1] = "1";
						}else if(formatList[1] == configData.INPUT_FORMAT_CALENDER_YESTERDAY){
							formatList[1] = "-1";
						}
						
						if(formatList[1] == configData.INPUT_FORMAT_CALENDER_NOW){						
							$tObj.val(uiList.dateFormat(now, site.COMMON_DATE_TYPE));
						/*}else if(formatList[1] == configData.INPUT_FORMAT_CALENDER_YESTERDAY){
							now.setDate(now.getDate()-1);
							$tObj.val(uiList.dateFormat(now, site.COMMON_DATE_TYPE));
						}else if(formatList[1] == configData.INPUT_FORMAT_CALENDER_TOMORROW){
							now.setDate(now.getDate()+1);
							$tObj.val(uiList.dateFormat(now, site.COMMON_DATE_TYPE));*/
						}else if(formatList[1] == configData.INPUT_FORMAT_CALENDER_MONTH1){
							now.setDate(1);
							$tObj.val(uiList.dateFormat(now, site.COMMON_DATE_TYPE));
						}else if(!isNaN(formatList[1])){
							var tmpNum = parseInt(formatList[1]);
							now.setDate(now.getDate()+tmpNum);
							$tObj.val(uiList.dateFormat(now, site.COMMON_DATE_TYPE));
						}
					}
					
					if(formatList[0] == configData.INPUT_FORMAT_CALENDER){
						$tObj.removeClass(configData.INPUT_NORMAL_CLASS);
						$tObj.addClass(configData.INPUT_BUTTON_CLASS);
						uiList.createInputCalender($tObj);
					}else{
						$tObj.addClass(configData.INPUT_NORMAL_CLASS);
					}
					
					$tObj.attr("maxlength",site.COMMON_DATE_TYPE.length);
					validateAtt = configData.VALIDATION_DATE;
					
					$tObj.change(function(event){
						var tmpValue = uiList.getDataFormat(formatList, inputObj.val());
						tmpValue = uiList.getDataFormat(formatList, tmpValue, true);
						inputObj.val(tmpValue);
					});
					/*
					var validateAtt = $tObj.attr(configData.VALIDATION_ATT);
					if(validateAtt && validateAtt.indexOf(configData.VALIDATION_DATE) == -1){
						validateAtt += " "+configData.VALIDATION_DATE;
					}else{
						validateAtt = configData.VALIDATION_DATE;
					}
					$tObj.attr(configData.VALIDATION_ATT, validateAtt);
					*/
				}else if(formatList[0] == configData.INPUT_FORMAT_TIME){
					$tObj.attr("maxlength",site.COMMON_TIME_TYPE.length);
					$tObj.change(function(event){
						var tmpValue = uiList.getDataFormat(formatList, inputObj.val(), true);
						inputObj.val(tmpValue);
					});
				}else if(formatList[0] == configData.INPUT_FORMAT_DATETIME){
					$tObj.attr("maxlength",site.COMMON_DATETIME_TYPE.length);
					$tObj.change(function(event){
						var tmpValue = uiList.getDataFormat(formatList, inputObj.val(), true);
						inputObj.val(tmpValue);
					});
				}else if(formatList[0] == configData.INPUT_FORMAT_DATETIMESECOND){
					$tObj.attr("maxlength",site.COMMON_DATETIMESECOND_TYPE.length);
					$tObj.change(function(event){
						var tmpValue = uiList.getDataFormat(formatList, inputObj.val(), true);
						inputObj.val(tmpValue);
					});
				}else if(formatList[0] == configData.INPUT_FORMAT_MONTH_SELECT){
					$tObj.attr("maxlength",site.COMMON_DATE_MONTH_TYPE.length);
					uiList.createInputMonthSelect($tObj);
					$tObj.change(function(event){
						var tmpValue = uiList.getDataFormat(formatList, inputObj.val(), true);
						inputObj.val(tmpValue);
					});
				}else if(formatList[0] == configData.INPUT_FORMAT_TIMEHM_SELECT){
					$tObj.attr("maxlength",site.COMMON_TIMEHM_TYPE.length);
					uiList.createInputTimeSelect($tObj);
					$tObj.change(function(event){
						var tmpValue = uiList.getDataFormat(formatList, inputObj.val(), true);
						inputObj.val(tmpValue);
					});
				}else{
					$tObj.change(function(event){
						var tmpValue = uiList.getDataFormat(formatList, inputObj.val(), true);
						inputObj.val(tmpValue);
					});
				}
			}
			
			if(validateAtt){
				var tmpAtt = $tObj.attr(configData.VALIDATION_ATT);
				validateAtt = tmpAtt + " " + validateAtt;
				$tObj.attr(configData.VALIDATION_ATT, validateAtt);
			}
			
			/*
			var tmpAtt = $tObj.attr(configData.VALIDATION_ATT);
			if(tmpAtt){
				var tmpAttList = tmpAtt.split(" ");
				for(var i=0;i<tmpAttList.length;i++){
					if(tmpAttList[i].split(",")[0] == configData.VALIDATION_REQUIRED){
						$tObj.addClass(site.REQUIRED_INPUT_CLASS);
						break;
					}
				}
				if(validateAtt){
					validateAtt = tmpAtt + " " + validateAtt;
				}else{
					validateAtt = tmpAtt;
				}				
			}
			if(validateAtt){
				$tObj.attr(configData.VALIDATION_ATT, validateAtt);
			}
			*/	
		});
		
		$obj.find('['+configData.VALIDATION_ATT+"]").each(function(i,findElement){
			var $tObj = jQuery(findElement);
			var tmpAtt = $tObj.attr(configData.VALIDATION_ATT);
			if(tmpAtt){
				var tmpAttList = tmpAtt.split(" ");
				for(var i=0;i<tmpAttList.length;i++){
					if(tmpAttList[i].split(",")[0] == configData.VALIDATION_REQUIRED){
						$tObj.addClass(site.REQUIRED_INPUT_CLASS);
						break;
					}else if(tmpAttList[i].split(",")[0] == configData.VALIDATION_PHONE){
						$tObj.css("IME-MODE","disabled");
						$tObj.attr("maxlength",12);
						$tObj.keyup(function(event){
							if(commonUtil.numberKeyCheck(event)){
								return;
							}
							var $obj = $(event.target);
							var tmpValue = $obj.val();
							tmpValue = tmpValue.replace(/[^\d]+/g, '');
							$obj.val(tmpValue);
						});
						$tObj.change(function(event){
							var $obj = $(event.target);
							var tmpValue = $obj.val();
							tmpValue = tmpValue.replace(/[^\d]+/g, '');
							$obj.val(tmpValue);
						});
						break;
					}
				}
			}
		});
	},
	autocompleteSet : function(areaId) {
		var $area = jQuery('#'+configData.SEARCH_AREA_ID);
		$area.find(":text").each(function(index,findElement){
			var $obj = jQuery(findElement);
			var ianame = $obj.attr("name");
			if(ianame){
				uiList.setAutoComplete($obj, ianame);
				$obj.removeAttr(configData.INPUT_AUTOCOMPLETE_NAME);
			}			
		});
	},
	autocompleteCheck : function() {
		var $body = jQuery('body');
		$body.find("["+configData.INPUT_AUTOCOMPLETE_NAME+"]").each(function(index,findElement){
			var $obj = jQuery(findElement);
			var ianame = $obj.attr(configData.INPUT_AUTOCOMPLETE_NAME);
			uiList.setAutoComplete($obj, ianame);
		});
	},
	setAutoComplete : function($obj, ianame) {
		var ckname = configData.INPUT_AUTOCOMPLETE_NAME+"_"+configData.MENU_ID+"_"+ianame;
		$obj.attr(configData.INPUT_AUTOCOMPLETE_COOKIE_NAME, ckname);
		var autocompleteList = $.cookie(ckname);
		if(autocompleteList){
			autocompleteList = autocompleteList.split(configData.DATA_COL_SEPARATOR);
		}else{
			autocompleteList = new Array();
		}
		uiList.autocompleteMap.put(ckname, autocompleteList);
		$obj.autocomplete({
			source : autocompleteList,
			minLength: 0,
			delay: 0,
			change: function( event, ui ) {
				var $obj = $(event.target);
				$obj.trigger("change");
			}
		});
		$obj.focusout(function(){
			var $eobj = jQuery(event.target);
			var tmpValue = $eobj.val();
			if(tmpValue){
				var autocompleteList;
				//var ianame = $eobj.attr(configData.INPUT_AUTOCOMPLETE_NAME);
				var ckname = $obj.attr(configData.INPUT_AUTOCOMPLETE_COOKIE_NAME);
				if(uiList.autocompleteMap.containsKey(ckname)){
					var pushType = true;
					autocompleteList = uiList.autocompleteMap.get(ckname);
					for(var i=0;i<autocompleteList.length;i++){
						if(tmpValue == autocompleteList[i]){
							pushType = false;
							break;
						}
					}
					if(pushType){
						if(autocompleteList.length == configData.INPUT_AUTOCOMPLETE_COUNT){
							autocompleteList.pop();								
						}
						autocompleteList.unshift(tmpValue);
					}
					tmpValue = autocompleteList.join(configData.DATA_COL_SEPARATOR);
				}else{
					autocompleteList = new Array();
					autocompleteList.push(tmpValue);
				}
				
				uiList.autocompleteMap.put(ckname, autocompleteList);
				$.cookie(ckname, tmpValue);
				$eobj.autocomplete("option", "source", autocompleteList);
			}
		});
	},
	setActive : function(bName, activeType) {
		if(activeType == undefined){
			activeType = true;
		}
		activeType = new String(activeType);
		if(this.btnMap.containsKey(bName)){
			var $btnObj = this.btnMap.get(bName);
			$btnObj.attr(configData.BUTTON_ACTIVE_TYPE_ATT, activeType);
			if(activeType=="false"){
				//$btnObj.addClass(configData.BUTTON_INACTIVE_CLASS);
				$btnObj.hide();
			}else{
				//$btnObj.removeClass(configData.BUTTON_INACTIVE_CLASS);
				$btnObj.show();
			}
		}		
	},
	getLabel : function(labelAtt) {
		if(labelAtt){
			var lCode = labelAtt.split(",");
			if(!lCode[1]){
				lCode[1] = 1;
			}
			return commonLabel.getLabel(lCode[0], lCode[1]);
			/*
			var ltxt = labelObj[lCode[0]];
			if(ltxt){
				return ltxt.split(configData.DATA_COL_SEPARATOR)[lCode[1]];
			}else{
				return lCode[0];
			}
			*/
		}		
	},
	typeCheck : function($obj) {
		if(!$obj){
			$obj = jQuery('body');
		}
		// calendar 지정
		$obj.find('['+configData.DATA_TYPE_ATT+"="+configData.DATA_TYPE_DATE+"]").datepicker(
				{ dateFormat: 'yy-mm-dd',
					showOn: 'button', 
					autoSize: true,
					buttonImage: site.commonUrl+'/images/btn_calendar.gif',					
					buttonImageOnly: true,
					showButtonPanel: true
					 });
		var now = new Date();
		var tmpRange = (now.getFullYear()-110)+":"+(now.getFullYear()+10);
		// 연,월 combo가 표시되는 calendar 지정
		$obj.find('['+configData.DATA_TYPE_ATT+"="+configData.DATA_TYPE_SELECTDATE+"]").datepicker(
				{ dateFormat: 'yy-mm-dd',
					showOn: 'button', 
					autoSize: true,
					buttonImage: site.commonUrl+'/images/btn_calendar.gif', 
					buttonImageOnly: true,
					showButtonPanel: true,
					changeMonth: true,
					changeYear: true,
					yearRange: tmpRange
					 });
		
		// button 지정
		$obj.find('['+configData.DATA_TYPE_ATT+"="+configData.DATA_TYPE_BUTTON+"]").button();
		
		// grid에 포함된 button 지정
		$obj.find('['+configData.DATA_TYPE_ATT+"="+configData.DATA_TYPE_GRID_BUTTON+"]").button();
		
		// tab 지정
		$obj.find('['+configData.DATA_TYPE_ATT+"="+configData.DATA_TYPE_TAB+"]").tabs();
		
		// menu 지정
		$obj.find('['+configData.DATA_TYPE_ATT+"="+configData.DATA_TYPE_MENU+"]").menu();
		
		// accordion 지정
		$obj.find('['+configData.DATA_TYPE_ATT+"="+configData.DATA_TYPE_ACCORDION+"]").accordion();
		
		$obj.find('['+configData.DATA_TYPE_ATT+"="+configData.DATA_TYPE_FACEBOOK_SHARE+"]").each(function(i,findElement){
			var $tObj = jQuery(findElement);
			var tmpHtml = '<a href="#" onClick="uiList.fsShareClick()"><img src="/images/facebook_icon.jpg" style="border:0px;"></a>';
			//tmpHtml += '<script src="http://static.ak.fbcdn.net/connect.php/js/FB.Share" type="text/javascript"></script>';
			$tObj.html(tmpHtml);
		});
	},
	fsShareClick : function(){
		var tmpUrl = 'http://www.facebook.com/sharer.php?u='+configData.SHARE_URL;
		window.open(tmpUrl);
	},
	twShareClick : function(){
		var tmpUrl = 'http://twitter.com/home?status= '+configData.SHARE_URL;
		window.open(tmpUrl);
	},
	// web editor로 지정했던 객체를 초기화 해준다.
	resetEditor : function(editorId){
		
	},
	// web editor를 지정해준다.
	checkEditor : function($obj) {
		if(!$obj){
			$obj = jQuery('body');
		}
		
		$obj.find('['+configData.DATA_TYPE_ATT+"="+configData.DATA_TYPE_EDITOR+"]").each(function(i,findElement){
			jQuery(findElement).addClass('webeditor');
			var objId = findElement.id;
			nhn.husky.EZCreator.createInIFrame({
				oAppRef: uiList.oEditors,
				elPlaceHolder: objId,
				sSkinURI: "/webeditor/SmartEditor2Skin.html",	
				htParams : {bUseToolbar : true,
					fOnBeforeUnload : function(){
						//alert("아싸!");	
					}
				}, //boolean
				fOnAppLoad : function(){
					//예제 코드
					//var $textObj = commonUtil.getJObj(objId);
					//uiList.oEditors.getById[objId].exec("PASTE_HTML", [commonUtil.getElementValue($textObj)]);
				},
				fCreator: "createSEditor2"
			});
		});
	},

	// table의 colNum에 해당하는 td중 연속해서 같은 값을 가진 경우 rowspan을 해준다.
	colGrouping : function(tableId, colNum) {
		var $obj = jQuery("#"+tableId);
		var $rowList = $obj.find("tr");
		var $startRow;
		var groupCount = 0;
		var startData;
		$rowList.each(function(index, findElement){
			var $row = jQuery(findElement);
			var $col = $row.find('td').eq(colNum);
			var tmpData = commonUtil.getElementValue($col);
			if(index == 0){
				groupCount = 1;
				$startRow = $row;
				startData = tmpData;
				return;
			}		
			if(startData == tmpData){
				$col.remove();
				groupCount++;
			}else{
				if(groupCount > 1){
					$startRow.find('td').eq(colNum).attr('rowspan', groupCount);
				}
				groupCount = 1;
				$startRow = $row;
				startData = commonUtil.getElementValue($row.find('td').eq(colNum));
			}
		});
		if(groupCount > 1){
			$startRow.find('td').eq(colNum).attr('rowspan', groupCount);
		}
	},
	// 날자 형식에 맞춰서 출력해준다.
	dateFormat : function(date, format) {		 
	    return format.replace(/(yyyy|yy|MM|dd|E|hh|mm|ss|a\/p)/gi, function($1) {
	        switch ($1) {
	            case "yyyy": return date.getFullYear();
	            case "yy": return commonUtil.leftPadding(date.getFullYear() % 1000, '0', 2);
	            case "mm": return commonUtil.leftPadding(date.getMonth() + 1, '0', 2);
	            case "dd": return commonUtil.leftPadding(date.getDate(), '0', 2);
	            case "E": return configData.WEEK_NAME[date.getDay()];
	            case "HH": return commonUtil.leftPadding(date.getHours(), '0', 2);
	            case "hh": return commonUtil.leftPadding(((h = date.getHours() % 12) ? h : 12), '0', 2);
	            case "MM": return commonUtil.leftPadding(date.getMinutes(), '0', 2);
	            case "ss": return commonUtil.leftPadding(date.getSeconds(), '0', 2);
	            case "a/p": return date.getHours() < 12 ? configData.DATE_AM : configData.DATE_PM;
	            default: return $1;
	        }
	    });
	},
	createNumberInput : function($input) {
		return;
		$input.keyup(function(event){
			var colValue = $(this).val();
			var tmpValue = "";
			if(colValue.indexOf("-") == 0){
				tmpValue = "-";
				colValue.substring(1);
			}
			$(this).val(tmpValue+colValue.replace(/[^0-9]/gi, ""));
			$(this).trigger("change");
		});
	},
	createCalender : function($input, gridId) {
		$input.datepicker({
			dateFormat : site.COMMON_DATE_TYPE_UI,
			showButtonPanel: true,
			showOn: "button",
			buttonImage: theme.GRID_CALENDAR_ICON,
			buttonImageOnly: true,
			changeMonth: true,
		    changeYear: true,
			onSelect: function(dateText, inst){
				$input.trigger("change");
				$input.attr("btnType","out");
				$input.trigger("blur");
			},
			onClose: function(dateText, inst) { 
				$input.attr("btnType","out");
			},
			beforeShow : function(dateText, inst) { 
				$input.next(".ui-datepicker-trigger").off("mouseout");
			}
		});
		
		theme.setGridCalendarEffect($input);
		
		return $input.next(".ui-datepicker-trigger");
		//$input.attr("btnType","over");
	},
	createCalenderOld : function($input, $btn) {
		$input.datepick({
			dateFormat : site.COMMON_DATE_TYPE,
			showOnFocus: false,
			showTrigger: $btn,
			onSelect: function(dates){
				$input.trigger("change");
			},
			onClose: function(dates) { 
				$input.attr("btnType","out");
			},
			onShow: function(dates) { 
				$input.attr("btnType","over"); 
			}
		});
		//$input.attr("btnType","over");
		$input.datepick('show');	
	},
	createInputCalender : function($input) {
		$input.datepicker({
			dateFormat : site.COMMON_DATE_TYPE_UI,
			showButtonPanel: true,
			changeMonth: true,
		    changeYear: true,
		    showOn: "both",
		    buttonImage: theme.INPUT_CALENDAR_ICON,
			onSelect: function(dates){
				$input.trigger("change");
			},
			beforeShow: function (input, inst) { 
				var readonlyAtt = $input.attr("readonly");
				if(readonlyAtt) {
                  if(inst.o_dpDiv === undefined) {
                      inst.o_dpDiv = inst.dpDiv;
                  }
                  inst.dpDiv = $('<div style="display: none;"></div>');
              } else {
                  if(inst.o_dpDiv !== undefined) {
                      inst.dpDiv = inst.o_dpDiv;
                  }
              }
			}
		});
		
		$input.addClass(configData.INPUT_CALENDAR_CLASS);
		
		theme.setInputCalendarEffect($input);
		
		//event fn
		if(commonUtil.checkFn("uiListCreateCalenderEvent")){
			uiListCreateCalenderEvent($input);
		}
		/*
		var readonlyAtt = $input.attr("readonly");
		if(readonlyAtt){
			$input.datepicker("option", "minDate", -1);
			$input.datepicker("option", "maxDate", -2); 
		}
		*/		
	},
	createMonthSelect : function($input, gridId) {
		$input.addClass(configData.INPUT_MONTH_SELECT_CLASS);
		$input.monthpicker({
			changeYear:true,
			showOn:"button",
			buttonImage:"/common/mobile_img/btn_month.png",
			dateFormat : site.COMMON_DATE_MONTH_TYPE_UI,
			minDate: "-10 Y", 
			maxDate: "+10 Y",
			monthNamesShort: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'],
			onSelect: function(){
				$input.focus();
				$input.trigger("change");
				//$input.attr("btnType","out");
				//$input.trigger("blur");
			},
			onClose: function() { 
				$input.attr("btnType","out");
			},
			beforeShow : function() { 
				$input.next(".ui-monthpicker-trigger").off("mouseout");
			}
		});
		
		return $input.next(".ui-monthpicker-trigger");
	},
	createInputMonthSelect : function($input) {
		$input.addClass(configData.INPUT_MONTH_SELECT_CLASS);
		$input.monthpicker({
			changeYear:true,
			showOn:"button",
			buttonImage: theme.MONTH_PICKER_ICON,
			dateFormat : site.COMMON_DATE_MONTH_TYPE_UI,
			monthNamesShort: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'] 
		});
	},
	createInputTimeSelect : function($input) {
		$input.addClass(configData.INPUT_TIME_SELECT_CLASS);
		$input.timepicker({
			showNowButton: true,
			showOn:'button'
		});
	},
	setInputOption : function($input, formatType, optionKey, optionValue) {
		if(formatType == configData.INPUT_FORMAT_CALENDER){
			$input.datepicker("option", optionKey, optionValue);
		}
	},
	createRangeInputCalender : function($input) {
		$input.datepicker({
			dateFormat : site.COMMON_DATE_TYPE_UI,
			showButtonPanel: true,
			changeMonth: true,
		    changeYear: true,
			onSelect: function(dates){
				$input.trigger("change");
			}
		});
	},
	createInputCalenderOld : function($input) {
		$input.datepick({
			dateFormat : site.COMMON_DATE_TYPE,
			onSelect: function(dates){
				$input.trigger("change");
			}
		});
	},
	createMask : function($input, colFormat) {
		var options =  { 
		  onChange: function(cep){
			  $input.trigger("change");
		  },
		  onInvalid: function(val, e, f, invalid, options){
		    var error = invalid[0];
		    alert("Digit: ", error.v, " is invalid for the position: ", error.p, ". We expect something like: ", error.e);
		  }
		};
		if(colFormat == configData.INPUT_FORMAT_TIME){
			$input.mask('00:00:00');
		}
	},
	getDateObj : function(dateStr) {	
		var now = new Date();
		if(dateStr){
			dateStr = this.getDateDataFormat(dateStr);
			var yyyy = dateStr.substring(0,4);
			var mm = dateStr.substring(4,6);
			var dd = dateStr.substring(6,8);
			var now = new Date();
			now.setFullYear(yyyy, mm-1, dd);
		}else{
			return new Date();
		}
	    return now;
	},
	// tabId에서 선택산 index를 open해준다.
	getDateViewFormat : function(dateStr) {
		if(dateStr && dateStr.length >= 8) {
			//dateStr = this.getDateDataFormat(dateStr);	
			dateStr = dateStr.replace(/[^\d]+/g, '');
			var yyyy = dateStr.substring(0,4);
			var mm = dateStr.substring(4,6);
			var dd = dateStr.substring(6,8);
			dateStr = commonUtil.replaceAll(site.COMMON_DATE_TYPE, 'yyyy', yyyy);
			dateStr = commonUtil.replaceAll(dateStr, 'mm', mm);
			dateStr = commonUtil.replaceAll(dateStr, 'dd', dd);
			return dateStr;
		} else {
			return dateStr;
		}
	},
	getDateMonthViewFormat : function(dateStr) {
		if(dateStr && dateStr.length >= 6) {
			//dateStr = this.getDateDataFormat(dateStr);	
			dateStr = dateStr.replace(/[^\d]+/g, '');
			var yyyy = dateStr.substring(0,4);
			var mm = dateStr.substring(4,6);
			dateStr = commonUtil.replaceAll(site.COMMON_DATE_MONTH_TYPE, 'yyyy', yyyy);
			dateStr = commonUtil.replaceAll(dateStr, 'mm', mm);
			return dateStr;
		} else {
			return dateStr;
		}
	},
	getDateNumber : function(dateStr) {
		var dateNumMap = new DataMap();
		if(dateStr && dateStr.length >= 8) {
			var yyyy = dateStr.substring(site.COMMON_DATE_TYPE_DATA.indexOf("yyyy"),site.COMMON_DATE_TYPE_DATA.indexOf("yyyy")+4);
			var mm = dateStr.substring(site.COMMON_DATE_TYPE_DATA.indexOf("mm"),site.COMMON_DATE_TYPE_DATA.indexOf("mm")+2);
			var dd = dateStr.substring(site.COMMON_DATE_TYPE_DATA.indexOf("dd"),site.COMMON_DATE_TYPE_DATA.indexOf("dd")+2);
			
			dateNumMap.put("yyyy",yyyy);
			dateNumMap.put("mm",mm);
			dateNumMap.put("dd",dd);
		}
		
		return dateNumMap;
	},
	getDateDataFormat : function(dateStr) {
		if(dateStr){
			dateStr = dateStr.replace(/[^\d]+/g, '');
			if(dateStr && dateStr.length >= 8) {
				var dateNumMap = this.getDateNumber(dateStr);
				dateStr = dateNumMap.get("yyyy")+dateNumMap.get("mm")+dateNumMap.get("dd")+"";
			}
			/*
			if(site.COMMON_DATE_TYPE == "yyyy/mm/dd"){
				dateStr = commonUtil.replaceAll(dateStr, "/", "");
			}else if(site.COMMON_DATE_TYPE == "yyyy.mm.dd"){
				dateStr = commonUtil.replaceAll(dateStr, ".", "");
			}
			*/
			/*
			if(!validate.isValidDate(dateStr)){
				commonUtil.msgBox(configData.VALIDATE_MSG_GROUPKEY+"_"+configData.VALIDATION_DATE);
			}
			*/
		}		
		return dateStr;
	},
	getDateMonthDataFormat : function(dateStr) {
		if(dateStr){
			dateStr = dateStr.replace(/[^\d]+/g, '');
			if(dateStr && dateStr.length >= 8) {
				var dateNumMap = this.getDateNumber(dateStr);
				dateStr = dateNumMap.get("yyyy")+dateNumMap.get("mm");
			}
		}		
		return dateStr;
	},
	getNumberViewFormat : function(numStr, numberType) {
		//var str = String(numStr);
		
		if(numStr == undefined || numStr == null){
			numStr = "0";
		}

		if(!isNaN(numStr)){
			numStr = String(numStr);
		}
		var sizeList = ["100","100"];
		if(numberType){
			sizeList = numberType.split(",");
		}
		var tmpNum = parseInt(sizeList[0]);
		if(sizeList.length == 1 || sizeList[1] == "0"){
			if(numStr.indexOf(".") != -1){
				numStr = numStr.substring(0,numStr.indexOf("."));
			}
			numStr = commonUtil.leftTrim(numStr, "0");
			if(numStr == ""){
				numStr = "0";
			}
			if(isNaN(numStr)){
				numStr = commonUtil.stringToNumber(numStr);
			}
			if(tmpNum &&  (numStr.length > tmpNum)){
				numStr = numStr.substring(0,tmpNum);
			}
			try{
				if(isNaN(numStr)){
					numStr = numStr1.replace(/[^\d]+/g, '');
				}
				return numStr.replace(/(\d)(?=(?:\d{3})+(?!\d))/g, '$1'+site.thousandSeparator);
			}catch(e){
				return numStr;
			}
		}else{
			var numStr1 = numStr;
			var numStr2 = "";
			if(numStr.indexOf(".") != -1){
				numStr1 = numStr.substring(0,numStr.indexOf("."));
				numStr2 = numStr.substring(numStr.indexOf(".")+1);
			}
			numStr1 = commonUtil.leftTrim(numStr1, "0");
			if(numStr1 == ""){
				numStr1 = "0";
			}
			if(isNaN(numStr1)){
				numStr1 = commonUtil.stringToNumber(numStr1);
			}
			if(isNaN(numStr2)){
				numStr2 = numStr2.replace(/[^\d]+/g, '');
			}
			if(numStr1.length > tmpNum){
				numStr1 = numStr1.substring(0,tmpNum);
			}
			tmpNum = parseInt(sizeList[1]);
			if(numStr2.length > tmpNum){
				numStr2 = numStr2.substring(0,tmpNum);
			}
			try{
				numStr1 = numStr1.replace(/(\d)(?=(?:\d{3})+(?!\d))/g, '$1'+site.thousandSeparator);
			}catch(e){
			}
			if(numStr2){
				return numStr1+site.decimalSeparator+numStr2;
			}else{
				return numStr1;
			}
		}
	},
	getNumberDataFormat : function(numStr, numberType) {
		try{			
			if(!isNaN(numStr)){
				numStr = String(numStr);
			}
			numStr = commonUtil.replaceAll(numStr, site.thousandSeparator, "");
			//numStr = numStr.replace(",","");
			if(numberType){
				var sizeList = ["100","100"];
				if(numberType){
					sizeList = numberType.split(",");
				}
				if(sizeList.length == 1 || sizeList[1] == "0"){
					if(numStr.indexOf(site.decimalSeparator) != -1){
						numStr = numStr.substring(0,numStr.indexOf(site.decimalSeparator));
					}
					numStr = commonUtil.leftTrim(numStr, "0");
					if(numStr == ""){
						numStr = "0";
					}
				}else{
					var tmpNum = parseInt(sizeList[0]);
					var numStr1 = numStr;
					var numStr2 = "";
					if(numStr.indexOf(site.decimalSeparator) != -1){
						numStr1 = numStr.substring(0,numStr.indexOf(site.decimalSeparator));
						numStr2 = numStr.substring(numStr.indexOf(site.decimalSeparator)+1);
					}
					numStr1 = commonUtil.leftTrim(numStr1, "0");
					if(numStr1 == ""){
						numStr1 = "0";
					}
					if(isNaN(numStr1)){
						numStr1 = commonUtil.stringToNumber(numStr1);
					}
					if(isNaN(numStr2)){
						numStr2 = numStr2.replace(/[^\d]+/g, '');
					}
					if(numStr1.length > tmpNum){
						numStr1 = numStr1.substring(0,tmpNum);
					}
					tmpNum = parseInt(sizeList[1]);
					if(numStr2.length > tmpNum){
						numStr2 = numStr2.substring(0,tmpNum);
					}
					if(numStr2){
						numStr = numStr1+"."+numStr2;
					}else{
						numStr = numStr1;
					}
				}
			}
			
			//return numStr.replace(/[^\d]+/g, '');
			return numStr;
		}catch(e){
			return numStr;
		}		
	},
	getTimeViewFormat : function(numStr) {
		try{
			if(this.getTimeDataFormat(numStr).length > 6){
				numStr = this.getTimeDataFormat(numStr).substring(0,6);
			}
			if(site.COMMON_TIME_TYPE.indexOf(":") != -1){
				return numStr.replace(/(\d)(?=(?:\d{2})+(?!\d))/g, '$1:');
			}else{
				return numStr.replace(/[^\d]+/g, '');
			}
		}catch(e){
			return numStr;
		}
	},
	getTimeDataFormat : function(numStr) {
		try{
			return numStr.replace(/[^\d]+/g, '');
		}catch(e){
			return numStr;
		}	
	},
	getTimeHSViewFormat : function(numStr) {
		try{
			if(this.getTimeDataFormat(numStr).length > 4){
				numStr = this.getTimeDataFormat(numStr).substring(0,4);
			}
			if(site.COMMON_TIMEHM_TYPE.indexOf(":") != -1){
				return numStr.replace(/(\d)(?=(?:\d{2})+(?!\d))/g, '$1:');
			}else{
				return numStr.replace(/[^\d]+/g, '');
			}
		}catch(e){
			return numStr;
		}
	},
	getTimeHSDataFormat : function(numStr) {
		try{
			return numStr.replace(/[^\d]+/g, '');
		}catch(e){
			return numStr;
		}	
	},
	getDateTimeDataFormat : function(datetimeStr) {
		if(datetimeStr) {
			datetimeStr = datetimeStr.replace(/[^\d]+/g, '');
		}
		return datetimeStr;
	},
	// Date Time Format
	getDateTimeViewFormat : function(datetimeStr) {
		if(datetimeStr && datetimeStr !== " ") {
			datetimeStr = this.getDateTimeDataFormat(datetimeStr);
			var yyyy = datetimeStr.substring(0,4);
			var mm = datetimeStr.substring(4,6);
			var dd = datetimeStr.substring(6,8);
			var HH = datetimeStr.substring(8,10);
			var MM = datetimeStr.substring(10,12);
			datetimeStr = site.COMMON_DATETIME_TYPE.replace(/yyyy/g, yyyy);
			datetimeStr = datetimeStr.replace(/mm/g, mm);
			datetimeStr = datetimeStr.replace(/dd/g, dd);
			datetimeStr = datetimeStr.replace(/HH/g, HH);
			datetimeStr = datetimeStr.replace(/MM/g, MM);
			return datetimeStr;
		} else {
			return datetimeStr;
		}
	},
	// Date Time Format(include second)
	getDateTimeSecondViewFormat : function(datetimeStr) {
		if(datetimeStr && datetimeStr !== " ") {
			datetimeStr = this.getDateTimeDataFormat(datetimeStr);
			var yyyy = datetimeStr.substring(0,4);
			var mm = datetimeStr.substring(4,6);
			var dd = datetimeStr.substring(6,8);
			var HH = datetimeStr.substring(8,10);
			var MM = datetimeStr.substring(10,12);
			var SS = datetimeStr.substring(12,14);
			
			datetimeStr = commonUtil.replaceAll(site.COMMON_DATETIMESECOND_TYPE, 'yyyy', yyyy);
			datetimeStr = commonUtil.replaceAll(datetimeStr, 'mm', mm);
			datetimeStr = commonUtil.replaceAll(datetimeStr, 'dd', dd);
			datetimeStr = commonUtil.replaceAll(datetimeStr, 'HH', HH);
			datetimeStr = commonUtil.replaceAll(datetimeStr, 'MM', MM);
			datetimeStr = commonUtil.replaceAll(datetimeStr, 'SS', SS);
			
			return datetimeStr;
		}else{
			return datetimeStr;
		}
	},
	getDataFormat : function(formatList, data, viewType) {
		var formatType = formatList[0];
		if(viewType){
			if(formatType == configData.INPUT_FORMAT_CALENDER){
				data = this.getDateViewFormat(data);
			}else if(formatType == configData.INPUT_FORMAT_DATE){
				data = this.getDateViewFormat(data);
			}else if(formatType == configData.INPUT_FORMAT_DATETIME){
				data = this.getDateTimeViewFormat(data);
			}else if(formatType == configData.INPUT_FORMAT_DATETIMESECOND){
				data = this.getDateTimeSecondViewFormat(data);
			}else if(formatType == configData.INPUT_FORMAT_MONTH_SELECT){
				data = this.getDateMonthViewFormat(data);
			}else if(formatType == configData.INPUT_FORMAT_TIMEHM_SELECT){
				data = this.getTimeHSViewFormat(data);
			}else if(formatType == configData.INPUT_FORMAT_NUMBER){
				data = this.getNumberViewFormat(data, formatList[1]);
			}else if(formatType == configData.INPUT_FORMAT_TIME){
				data = this.getTimeViewFormat(data);
			}else if(formatType == configData.INPUT_FORMAT_UPPERCASE){
				data = data.toUpperCase();
			}else if(formatType == configData.INPUT_FORMAT_LOWERCASE){
				data = data.toLowerCase();
			}
		}else{
			if(formatType == configData.INPUT_FORMAT_CALENDER){
				data = this.getDateDataFormat(data);
			}else if(formatType == configData.INPUT_FORMAT_DATE){
				data = this.getDateDataFormat(data);
			}else if(formatType == configData.INPUT_FORMAT_DATETIME){
				data = this.getDateTimeViewFormat(data);
			}else if(formatType == configData.INPUT_FORMAT_MONTH_SELECT){
				data = this.getDateMonthDataFormat(data);
			}else if(formatType == configData.INPUT_FORMAT_TIMEHM_SELECT){
				data = this.getTimeHSDataFormat(data);
			}else if(formatType == configData.INPUT_FORMAT_NUMBER){
				data = this.getNumberDataFormat(data, formatList[1]);
			}else if(formatType == configData.INPUT_FORMAT_TIME){
				data = this.getTimeDataFormat(data);
			}else if(formatType == configData.INPUT_FORMAT_UPPERCASE){
				data = data.toUpperCase();
			}else if(formatType == configData.INPUT_FORMAT_LOWERCASE){
				data = data.toLowerCase();
			}
		}
		
		data = site.getDataFormat(formatList, data, viewType);
		
		return data;
	},
	getLastClickBtnName : function() {
		return lastBtnName;
	},
	tabOpen : function(tabId, index) {
		jQuery("#"+tabId).tabs("option","active",index);
	},
	zeroFormat : function() {
		return "UIList";
	},
	toString : function() {
		return "UIList";
	}
};

var uiList = new UIList();