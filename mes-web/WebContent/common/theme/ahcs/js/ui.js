var topLabelFrame;

UIList = function() {
	this.selectTreeNode = new DataMap();
	this.oEditors = [];
	topLabelFrame = window;
	if(!topLabelFrame.labelFrame){
		topLabelFrame = window.top;
	}
	if(!topLabelFrame.labelFrame){
		try{
			topLabelFrame = window.opener.topLabelFrame;
		}catch(e){}		
	}
	this.btnMap = new DataMap();
	this.$dateUi = jQuery("<input type='hidden' />");
	this.shortKeyBtnMap = new DataMap();
	
	this.$getVariant = null;
	this.$saveVariant = null;
	
	this.autocompleteMap = new DataMap();
	
	this.dateDefaultMap = new DataMap();
	
	this.lastBtnName;
};

UIList.prototype = {
	// UI로 설정된 객체를 UI로 지정해준다.
	UICheck : function($obj) {
		if(!$obj){
			$obj = jQuery('body');
		}
		/*
		topLabelFrame = window.top;
		
		if(!topLabelFrame.labelFrame){
			topLabelFrame = window.opener.topLabelFrame;
		}
		*/
		
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
			if(tag == "INPUT"){
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
			
			var iconClass = configData.BUTTON_ICON.get(bType);
			var labelTxt = ui.getLabel(lCode);
			var titleTxt = labelTxt;
			
			if(bName == configData.BUTTON_COMMAND_SEARCH){
				titleTxt += " [alt+"+configData.COMMON_KEY_EVENT_SEARCH+"]";
			}else if(bName == configData.BUTTON_COMMAND_SAVE){
				titleTxt += " [alt+"+configData.COMMON_KEY_EVENT_SAVE+"]";
			}else if(bName == configData.BUTTON_COMMAND_CREATE){
				titleTxt += " [alt+"+configData.COMMON_KEY_EVENT_CREATE+"]";
			}
			
			var shortKey = $tObj.attr(configData.SHORT_KET_ATT);
			if(shortKey){
				uiList.shortKeyBtnMap.put(shortKey, $tObj);
				titleTxt += " [alt+"+shortKey+"]";
			}
			
			$tObj.attr("title", titleTxt);
			$tObj.text("");
			$tObj.append("<span class='"+configData.BUTTON_ICON_CLASS+" "+iconClass+"'>Icon</span>");
			$tObj.append("<span class='"+configData.BUTTON_TEXT_CLASS+"'>"+labelTxt+"</span>");
			
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
							url : "/common/variant/json/delete.data",
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
								+ "<span> Default : <input class=variantDefault type='checkbox' name='saveVariantDEFCHK' value='V' CheckEmptyVal=' '/></span>"
								+ "</span>";
				uiList.$saveVariant = jQuery($tmpSaveVariant);
				
				var $tmpSaveBtn = jQuery("<span> <button type='button' class='savebtn'>X</button> </span>");
				$tmpSaveBtn.click(function(event){
					//uiList.$saveVariant.hide();
					//if(validate.check("saveVariant")){
						var map = dataBind.paramData("saveVariant");						
						if(!map.containsKey("saveVariantPARMKY") || $.trim(map.get("saveVariantPARMKY")) == ""){
							commonUtil.msgBox(configData.VALIDATE_MSG_GROUPKEY+"_"+configData.VALIDATION_REQUIRED);
							$("#saveVariant").find("[name=saveVariantPARMKY]").focus();
							return;
						}
						map.put("PARMKY", map.get("saveVariantPARMKY"));
						if(!map.containsKey("saveVariantSHORTX") || $.trim(map.get("saveVariantSHORTX")) == ""){
							commonUtil.msgBox(configData.VALIDATE_MSG_GROUPKEY+"_"+configData.VALIDATION_REQUIRED);
							$("#saveVariant").find("[name=saveVariantSHORTX]").focus();
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
							url : "/common/variant/json/insert.data",
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
				var $btnObj;
				if($obj.get(0).tagName == "BUTTON"){
					$btnObj = $obj;
				}else{
					$btnObj = $obj.parent();
				}
				var active = $btnObj.attr(configData.BUTTON_ACTIVE_TYPE_ATT);
				var btnName = $btnObj.attr(configData.BUTTON_NAME_ATT);
				var btnType = $btnObj.attr(configData.BUTTON_TYPE_ATT);
				if(btnType == configData.BUTTON_TYPE_GETVARIANT){
					uiList.$getVariant.show();
				}else if(btnType == configData.BUTTON_TYPE_SAVEVARIANT){
					uiList.$saveVariant.show();
				}
				if(active == "true"){
					try{
						commonBtnClick(btnName);
					}catch(e){
					}
					uiList.lastBtnName = btnName;
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
			if(inputAtt == configData.INPUT_RANGE || inputAtt == configData.INPUT_BETWEEN){
				return;
			}
			var formatAtt = $tObj.attr(configData.INPUT_FORMAT);
			var validateAtt;
			if(formatAtt){
				var formatList = formatAtt.split(" ");
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
				}else if(formatList[0] == configData.INPUT_FORMAT_NUMBER){
					validateAtt = configData.VALIDATION_NUMBER;
					$tObj.addClass(configData.INPUT_NUMBER_CLASS);
					
					var sizeList;
					if(formatList.length > 1){
						sizeList = formatList[1].split(",");
					}
					if(sizeList){
						var maxLength = parseInt(sizeList[0]);
						maxLength += parseInt((maxLength-1)/3);
						if(sizeList.length > 1){
							maxLength += parseInt(sizeList[1])+1;
						}				
						$tObj.attr("maxlength",maxLength);
					}
					
					var inputObj = $tObj;
					$tObj.change(function(event){
						var tmpValue = uiList.getDataFormat(formatList, inputObj.val(), true);
						inputObj.val(tmpValue);
					});
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
						var tmpValue = uiList.getDataFormat(formatList, inputObj.val(), true);
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
				}
			}
			
			if(validateAtt){
				var tmpAtt = $tObj.attr(configData.VALIDATION_ATT);
				if(tmpAtt){
					validateAtt = tmpAtt + " " + validateAtt;
				}
				$tObj.attr(configData.VALIDATION_ATT, validateAtt);
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
			return topLabelFrame.getLabel(lCode[0], lCode[1]);
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
					buttonImage: '/common/images/btn_calendar.gif',					
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
					buttonImage: '/common/images/btn_calendar.gif', 
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
			var tmpHtml = '<a href="#" onClick="uiList.fsShareClick()"><img src="/common/images/facebook_icon.jpg" style="border:0px;"></a>';
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
				sSkinURI: "/common/webeditor/SmartEditor2Skin.html",	
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
	createCalender : function($input) {
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
			changeMonth: true,
		    changeYear: true,
		    showOn: "both",
		    buttonImage: theme.INPUT_CALENDAR_ICON,
			onSelect: function(dates){
				$input.trigger("change");
			}
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
	// tabId에서 선택산 index를 open해준다.
	getDateViewFormat : function(dateStr) {
		if(dateStr){
			dateStr = this.getDateDataFormat(dateStr);
			var yyyy = dateStr.substring(0,4);
			var mm = dateStr.substring(4,6);
			var dd = dateStr.substring(6,8);
			dateStr = commonUtil.replaceAll(site.COMMON_DATE_TYPE, 'yyyy', yyyy);
			dateStr = commonUtil.replaceAll(dateStr, 'mm', mm);
			dateStr = commonUtil.replaceAll(dateStr, 'dd', dd);
			return dateStr;
		}else{
			return dateStr;
		}
	},
	getDateDataFormat : function(dateStr) {
		if(dateStr){
			dateStr = dateStr.replace(/[^\d]+/g, '');
			/*
			if(site.COMMON_DATE_TYPE == "yyyy/mm/dd"){
				dateStr = commonUtil.replaceAll(dateStr, "/", "");
			}else if(site.COMMON_DATE_TYPE == "yyyy.mm.dd"){
				dateStr = commonUtil.replaceAll(dateStr, ".", "");
			}
			*/
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
			if(tmpNum &&  (numStr.length > tmpNum)){
				numStr = numStr.substring(0,tmpNum);
			}
			try{
				if(isNaN(numStr)){
					numStr = numStr1.replace(/[^\d]+/g, '');
				}
				return numStr.replace(/(\d)(?=(?:\d{3})+(?!\d))/g, '$1,');
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
			if(numStr1 == ""){
				numStr1 = "0";
			}
			if(isNaN(numStr1)){
				numStr1 = numStr1.replace(/[^\d]+/g, '');
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
				numStr1 = numStr1.replace(/(\d)(?=(?:\d{3})+(?!\d))/g, '$1,');
			}catch(e){
			}
			if(numStr2){
				return numStr1+"."+numStr2;
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
			numStr = numStr.replace(",","");
			if(numberType){
				var sizeList = ["100","100"];
				if(numberType){
					sizeList = numberType.split(",");
				}
				if(sizeList.length == 1 || sizeList[1] == "0"){
					if(numStr.indexOf(".") != -1){
						numStr = numStr.substring(0,numStr.indexOf("."));
					}
				}else{
					var tmpNum = parseInt(sizeList[0]);
					var numStr1 = numStr;
					var numStr2 = "";
					if(numStr.indexOf(".") != -1){
						numStr1 = numStr.substring(0,numStr.indexOf("."));
						numStr2 = numStr.substring(numStr.indexOf(".")+1);
					}
					if(numStr1 == ""){
						numStr1 = "0";
					}
					if(isNaN(numStr1)){
						numStr1 = numStr1.replace(/[^\d]+/g, '');
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
	getDataFormat : function(formatList, data, viewType) {
		var formatType = formatList[0];
		if(viewType){
			if(formatType == configData.INPUT_FORMAT_CALENDER){
				data = this.getDateViewFormat(data);
			}else if(formatType == configData.INPUT_FORMAT_DATE){
				data = this.getDateViewFormat(data);
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