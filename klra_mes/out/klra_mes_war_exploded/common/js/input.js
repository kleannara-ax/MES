InputObj = function($obj) {
	this.$obj = $obj;//생성 옵션
	//this.$obj.val(this.$obj.attr("id"));
	this.inputAtt = $obj.attr(configData.INPUT);
	this.options = this.inputAtt.split(",");	
	this.name = $obj.attr("name");
	this.readonlyAtt = $obj.attr("readonly");
	
	// configData.INPUT_FORMAT : UIFormat 
	this.formatAtt = $obj.attr(configData.INPUT_FORMAT);
	this.formatList;

	this.validateAtt = $obj.attr(configData.VALIDATION_ATT);
	this.validateList = new Array();

	this.$rangeBox;
	this.$from;
	this.$to;
	this.singleData = new Array();
	this.rangeData = new Array();
	this.$searchBtn;
	this.$searchText;
	this.options;
	this.searchType;
	
	this.saveAtt;
	this.setInput();
	// Cuty JJin 2018.10.10 PJW
	// Range Name
	this.rangeName;
}

InputObj.prototype = {
	searchView : function (searchType, multyType){
		this.searchType = searchType;
		this.readonlyAtt = this.$obj.attr("readonly");
		page.searchHelp(this, this.options[1], multyType);
	},
	setAutocomplete : function() {
		if(this.options[0] == configData.INPUT_MULTIPLE){
			return;
		}
		var ianame = configData.MENU_ID+"_"+this.name;
		uiList.setAutoComplete(this.$from, this.name+"_RF");
		uiList.setAutoComplete(this.$to, this.name+"_RT");
		this.$obj.removeAttr(configData.INPUT_AUTOCOMPLETE_NAME);
	},
	setInput : function() {
		var inputObj = this;
		var requiredInputType = false;
		
		if(this.$obj.attr(configData.INPUT_SAVE) == "false"){
			this.saveAtt = false;
		}else{
			this.saveAtt = true;
		}
		// Cuty JJin 2018.10.10 PJW
		// Range Name 처리
		if($.trim(this.$obj.attr(configData.INPUT_RANGE_NAME))){
			this.rangeName = this.$obj.attr(configData.INPUT_RANGE_NAME);
		}else{
			this.rangeName = configData.INPUT_RNAGE_DATA_PARAM;
		}
		
		var sizeList;
		if(this.formatAtt){
			this.formatList = this.formatAtt.split(" ");
			if(this.formatList.length > 1){
				sizeList = this.formatList[1].split(",");
			}
		}
		
		if(this.validateAtt){
			this.validateAtt = this.validateAtt.split(" ");
			for(var i=0;i<this.validateAtt.length;i++){
				this.validateList.push(this.validateAtt[i].split(",")[0]);
				if(this.validateAtt[i].split(",")[0] == configData.VALIDATION_REQUIRED){
					requiredInputType = true;
				}else if(this.validateAtt[i].split(",")[0].indexOf(configData.VALIDATION_REQUIRED) > -1){
					//2022.05.29 이범준 [required(라벨) 시 필수 입력 이미지 표기]
					requiredInputType = true;
				}
			}
			if(this.options[0] != configData.INPUT_SEARCH){
				this.$obj.removeAttr(configData.VALIDATION_ATT);
			}
		}
		
		if(this.options[0] == configData.INPUT_SEARCH){
			//this.$obj.addClass(configData.INPUT_SEARCH_CLASS);
			theme.setInputSearch(this.$obj);
			this.$searchBtn = theme.getInputSearchBtn(this);
			this.$searchBtn.click(function(event){
				inputObj.searchView("obj");
			});
			var $btnObj = this.$searchBtn;
			this.$obj.keydown(function(event){
				var $obj = $(event.target);
				var code = event.keyCode;
				if(code!= 18 && event.altKey){
					if(code == site.COMMON_KEY_EVENT_SEARCH_HELP_CODE){
						$btnObj.trigger("click");
					}
				}else{
					site.searchEnterEvent(code, $btnObj);
				}
			});
			this.$obj.after(this.$searchBtn);
			if(this.options.length == 3){
				this.$searchText = theme.getInputSearchText(this);
				this.$searchBtn.after(this.$searchText);
			}
		}else if(this.options[0] == configData.INPUT_MULTIPLE){
			//this.$obj.attr("multiple","multiple");
			this.$obj.change(function(event){
				inputObj.addMultiComboValue();
			});
		}else if(this.options[0] == configData.INPUT_SEARCH_COMBO){
			//this.$obj.attr("multiple","multiple");
			var $tmpBox = jQuery("<div class='ui-widget'></div>");
			this.$obj.parent().append($tmpBox);
			$tmpBox.append(this.$obj);
			this.$obj.combobox();
		}else if(this.options[0] == configData.INPUT_RANGE || this.options[0] == configData.INPUT_SHORT_RANGE || this.options[0] == configData.INPUT_BETWEEN){
			//this.$obj.removeAttr(configData.INPUT_SAVE);
			this.$obj.hide();	
			this.$obj.attr("name", configData.INPUT_RANG);
			//this.$rangeBox = this.$obj.parent();
			this.$rangeBox = theme.setInputRangeBox(this, this.$obj);
			if(this.options[1]){
				//this.$from = jQuery("<input type='text' class='"+theme.INPUT_SEARCH_CLASS+"' />");
				this.$from = theme.getInputRangeFrom(this);
				var $fBtn = theme.getInputSearchBtn(this);
				//this.$to = jQuery("<input type='text' class='"+theme.INPUT_RANGE_CLASS+"' />");
				this.$to = theme.getInputRangeTo(this);
				this.$rangeBox.append(this.$from);
				this.$rangeBox.append($fBtn);
				if(this.options[0] != configData.INPUT_SHORT_RANGE){
					this.$rangeBox.append(theme.getInputRangeDash());			
				}
				this.$rangeBox.append(this.$to);
				$fBtn.click(function(event){
					inputObj.searchView("from", true);
				});
				if(this.options[0] == configData.INPUT_BETWEEN){
					var $tBtn = theme.getInputSearchBtn(this);
					this.$rangeBox.append($tBtn);
					$tBtn.click(function(event){
						inputObj.searchView("to", true);
					});
				}
				
				this.$from.keydown(function(event){
					var $obj = $(event.target);
					var code = event.keyCode;
					if(code!= 18 && event.altKey){
						if(code == site.COMMON_KEY_EVENT_SEARCH_HELP_CODE){
							$fBtn.trigger("click");
						}
					}else {
						site.searchEnterEvent(code, $fBtn);
					}
				});
				/*
				$tBtn.click(function(event){
					inputObj.searchView("to");
				});
				*/
			}else{
				//this.$from = jQuery("<input type='text' class='"+theme.INPUT_RANGE_CLASS+"' />");
				this.$from = theme.getInputRangeFrom(this);
				//this.$to = jQuery("<input type='text' class='"+theme.INPUT_RANGE_CLASS+"' />");
				this.$to = theme.getInputRangeTo(this);
				this.$rangeBox.append(this.$from);
				if(this.options[0] != configData.INPUT_SHORT_RANGE){
					this.$rangeBox.append(theme.getInputRangeDash());			
				}
				this.$rangeBox.append(this.$to);
				if(this.formatList){
					if(this.formatList[0] == configData.INPUT_FORMAT_NUMBER){
						var maxLength = parseInt(sizeList[0]);
						maxLength += parseInt((maxLength-1)/3);
						if(sizeList.length > 1){
							maxLength += parseInt(sizeList[1])+1;
						}				
						this.$from.attr("maxlength",maxLength);
						this.$to.attr("maxlength",maxLength);
					}else if(this.formatList[0] == configData.INPUT_FORMAT_CALENDER){
						this.$from.removeClass(configData.INPUT_RANGE_CLASS);
						this.$from.addClass(configData.INPUT_BUTTON_CLASS);
						uiList.createInputCalender(this.$from);
						if(this.options[0] == configData.INPUT_RANGE){
							//uiList.createRangeInputCalender(this.$to);
							uiList.createInputCalender(this.$to);
							this.$to.removeClass(configData.INPUT_CALENDAR_CLASS);
							this.$to.removeClass(configData.INPUT_NORMAL_CLASS);
							this.$to.addClass(configData.INPUT_SEARCH_CLASS);
						}else if(this.options[0] != configData.INPUT_SHORT_RANGE){
							uiList.createInputCalender(this.$to);
						}
						
						this.$from.attr("maxlength",site.COMMON_DATE_TYPE.length);
						this.$to.attr("maxlength",site.COMMON_DATE_TYPE.length);
					}else if(this.formatList[0] == configData.INPUT_FORMAT_DATE){
						this.$from.attr("maxlength",site.COMMON_DATE_TYPE.length);
						this.$to.attr("maxlength",site.COMMON_DATE_TYPE.length);
					}else if(this.formatList[0] == configData.INPUT_FORMAT_CALENDER_MONTH){ // 2019.03.07 jw : : Input Data Type Month Added
						this.$from.removeClass(configData.INPUT_RANGE_CLASS);
						this.$from.addClass(configData.INPUT_BUTTON_CLASS);
						uiList.createInputCalender(this.$from);
						if(this.options[0] == configData.INPUT_RANGE){
							uiList.createInputCalender(this.$to);
							this.$to.removeClass(configData.INPUT_CALENDAR_MONTH_CLASS);
							this.$to.removeClass(configData.INPUT_NORMAL_CLASS);
							this.$to.addClass(configData.INPUT_SEARCH_CLASS);
						}else if(this.options[0] != configData.INPUT_SHORT_RANGE){
							uiList.createInputCalender(this.$to);
						}
						
						this.$from.attr("maxlength",site.COMMON_DATE_MONTH_TYPE.length);
						this.$to.attr("maxlength",site.COMMON_DATE_MONTH_TYPE.length);
					}else if(this.formatList[0] == configData.INPUT_FORMAT_DATE_MONTH){ // 2019.03.07 jw : : Input Data Type Month Added
						this.$from.attr("maxlength",site.COMMON_DATE_MONTH_TYPE.length);
						this.$to.attr("maxlength",site.COMMON_DATE_MONTH_TYPE.length);
					}else if(this.formatList[0] == configData.INPUT_FORMAT_TIME){
						this.$from.attr("maxlength",site.COMMON_TIME_TYPE.length);
						this.$to.attr("maxlength",site.COMMON_TIME_TYPE.length);
					}
				}
				//this.$rangeBox.append($tBtn);
			}
			
			if(requiredInputType){
				this.$from.addClass(site.REQUIRED_INPUT_CLASS);
				//2022.05.29 이범준 [Date Between] : TO Input 필수 항목 이미지 표시.
				if(this.options[0] == configData.INPUT_BETWEEN && site.dateBetweenCheck){
					this.$to.addClass(site.REQUIRED_INPUT_CLASS);
				}
			}
			
			if(this.options[0] == configData.INPUT_SHORT_RANGE){
				this.$to.hide();
			}
			
			if(this.formatList){
				if(this.formatList[0] == configData.INPUT_FORMAT_STRING || this.formatList[0] == configData.INPUT_FORMAT_UPPERCASE || this.formatList[0] == configData.INPUT_FORMAT_LOWERCASE){
					if(sizeList){
						this.$from.attr("maxlength",sizeList[0]);
						this.$to.attr("maxlength",sizeList[0]);
					}
					if(this.formatList[0] == configData.INPUT_FORMAT_UPPERCASE){
						this.$from.addClass(configData.INPUT_FORMAT_UPPERCASE_CLASS);
						this.$to.addClass(configData.INPUT_FORMAT_UPPERCASE_CLASS);
						/*
						this.$from.keyup(function(event){
							var tmpValue = inputObj.$from.val();
							tmpValue = tmpValue.toUpperCase();
							inputObj.$from.val(tmpValue);
						});
						this.$to.keyup(function(event){
							var tmpValue = inputObj.$to.val();
							tmpValue = tmpValue.toUpperCase();
							inputObj.$to.val(tmpValue);
						});
						*/
					}else if(this.formatList[0] == configData.INPUT_FORMAT_LOWERCASE){
						this.$from.addClass(configData.INPUT_FORMAT_LOWERCASE_CLASS);
						this.$to.addClass(configData.INPUT_FORMAT_LOWERCASE_CLASS);
						/*
						this.$from.keyup(function(event){
							var tmpValue = inputObj.$from.val();
							tmpValue = tmpValue.toLowerCase();
							inputObj.$from.val(tmpValue);
						});
						this.$to.keyup(function(event){
							var tmpValue = inputObj.$to.val();
							tmpValue = tmpValue.toLowerCase();
							inputObj.$to.val(tmpValue);
						});
						*/
					}
				}
			}
			
			var autoCompleteAtt = this.$obj.attr(configData.INPUT_AUTOCOMPLETE_NAME);
			if(autoCompleteAtt){
				uiList.setAutoComplete(this.$from, autoCompleteAtt);
				uiList.setAutoComplete(this.$to, autoCompleteAtt);
			}
			
			if(this.readonlyAtt){
				this.$from.attr("readonly", true);
				this.$to.attr("readonly", true);
			}
			
			this.$from.change(function(event){
				inputObj.searchType = "from";
				inputObj.valueChange(true);
				if(inputObj.formatList){
					var tmpValue = uiList.getDataFormat(inputObj.formatList, inputObj.$from.val());
					tmpValue = uiList.getDataFormat(inputObj.formatList, tmpValue, true);
					inputObj.$from.val(tmpValue);
				}
			});
			
			this.$to.change(function(event){
				inputObj.searchType = "to";
				inputObj.valueChange(true);
				if(inputObj.formatList){
					var tmpValue = uiList.getDataFormat(inputObj.formatList, inputObj.$to.val());
					tmpValue = uiList.getDataFormat(inputObj.formatList, tmpValue, true);
					inputObj.$to.val(tmpValue);
				}
			});
			
			if(this.options[0] == configData.INPUT_RANGE || this.options[0] == configData.INPUT_SHORT_RANGE){
				var $rangeBtn = theme.getInputRangeBtn(this.$rangeBox);
				//this.$rangeBox.append($rangeBtn);

				$rangeBtn.click(function(event){
					//rangePop();
					rangeObj.setRange(inputObj);
				});
			}

			if(this.$obj.val()){
				this.searchType = "from";
				this.$from.val(this.$obj.val());
				this.valueChange();
				this.$obj.val("");
			}
			
			if(this.formatList){
				if(this.formatList[0] == configData.INPUT_FORMAT_CALENDER){
					this.validateList.push(configData.VALIDATION_DATE);
					var now = new Date();
					if(this.formatList[1] == configData.INPUT_FORMAT_CALENDER_TOMORROW){
						this.formatList[1] = "1";
					}else if(this.formatList[1] == configData.INPUT_FORMAT_CALENDER_YESTERDAY){
						this.formatList[1] = "-1";
					}
					
					
					if(this.formatList[1] == configData.INPUT_FORMAT_CALENDER_NOW){
						this.searchType = "from";
						var tmpValue = uiList.dateFormat(now, site.COMMON_DATE_TYPE);
						this.$from.val(tmpValue);
						this.valueChange();
					}else if(this.formatList[1] == configData.INPUT_FORMAT_CALENDER_MONTH1){
						now.setDate(1);
						this.searchType = "from";
						var tmpValue = uiList.dateFormat(now, site.COMMON_DATE_TYPE);
						this.$from.val(tmpValue);
						this.valueChange();
						
						now = new Date();
						this.searchType = "to";
						var tmpValue = uiList.dateFormat(now, site.COMMON_DATE_TYPE);
						this.$to.val(tmpValue);	
						this.valueChange();
					}else if(this.formatList[1] == configData.INPUT_FORMAT_CALENDER_MONTH2){ // 2019.02.25 jw : Input UIFormat Default Value "M2" Added
						now.setDate(1);
						this.searchType = "from";
						var tmpValue = uiList.dateFormat(now, site.COMMON_DATE_TYPE);
						this.$from.val(tmpValue);
						this.valueChange();
						
						now = new Date(now.getFullYear(), now.getMonth() + 1, 0);
						this.searchType = "to";
						var tmpValue = uiList.dateFormat(now, site.COMMON_DATE_TYPE);
						this.$to.val(tmpValue);	
						this.valueChange();
					}else if(this.formatList[1] == configData.INPUT_FORMAT_CALENDER_MONTH3){ // 2019.03.11 jw : Input UIFormat Default Value "M3" Added
						now = new Date(now.getFullYear(), 0, 1)
						this.searchType = "from";
						var tmpValue = uiList.dateFormat(now, site.COMMON_DATE_TYPE);
						this.$from.val(tmpValue);
						this.valueChange();
						
						now = new Date(now.getFullYear(), 12, 0)
						this.searchType = "to";
						var tmpValue = uiList.dateFormat(now, site.COMMON_DATE_TYPE);
						this.$to.val(tmpValue);	
						this.valueChange();
					}else if(this.formatList[1] == configData.INPUT_FORMAT_CALENDER_WEEK1){
						var tmpDay = now.getDay();
						if(tmpDay > 1){
							now.setDate(now.getDate()-(tmpDay-1));
						}						
						this.searchType = "from";
						var tmpValue = uiList.dateFormat(now, site.COMMON_DATE_TYPE);
						this.$from.val(tmpValue);
						this.valueChange();
						
						now = new Date();
						this.searchType = "to";
						var tmpValue = uiList.dateFormat(now, site.COMMON_DATE_TYPE);
						this.$to.val(tmpValue);	
						this.valueChange();
					}else if(!isNaN(this.formatList[1])){
						// input 날짜 포맷 C -7 7 20180629 PJW
						if(!isNaN(this.formatList[2])){
							var tmpNumFrom = parseInt(this.formatList[1]);
							var tmpNumTo = parseInt(this.formatList[2]);
							
							now.setDate(now.getDate()+tmpNumFrom);
							this.searchType = "from";
							var tmpValue = uiList.dateFormat(now, site.COMMON_DATE_TYPE);
							this.$from.val(tmpValue);
							this.valueChange();
							
							if(tmpNumFrom != tmpNumTo) {
								now = new Date();
								now.setDate(now.getDate()+tmpNumTo);
								this.searchType = "to";
								var tmpValue = uiList.dateFormat(now, site.COMMON_DATE_TYPE);
								this.$to.val(tmpValue);	
								this.valueChange();
							}
						}else{
							var tmpNum = parseInt(this.formatList[1]);
							if(tmpNum < 0){
								now.setDate(now.getDate()+tmpNum);
								this.searchType = "from";
								var tmpValue = uiList.dateFormat(now, site.COMMON_DATE_TYPE);
								this.$from.val(tmpValue);
								this.valueChange();
								
								now = new Date();
								this.searchType = "to";
								var tmpValue = uiList.dateFormat(now, site.COMMON_DATE_TYPE);
								this.$to.val(tmpValue);	
								this.valueChange();
							}else{
								this.searchType = "from";
								var tmpValue = uiList.dateFormat(now, site.COMMON_DATE_TYPE);
								this.$from.val(tmpValue);
								this.valueChange();
								
								now.setDate(now.getDate()+tmpNum);
								this.searchType = "to";
								var tmpValue = uiList.dateFormat(now, site.COMMON_DATE_TYPE);
								this.$to.val(tmpValue);
								this.valueChange();
							}
						}
					}
				}else if(this.formatList[0] == configData.INPUT_FORMAT_CALENDER_MONTH){ // 2019.03.07 jw : : Input Data Type Month Added
					this.validateList.push(configData.VALIDATION_DATE_MONTH);
					var now = new Date();
					
					if(this.formatList[1] == configData.INPUT_FORMAT_CALENDER_NOW){
						this.searchType = "from";
						var tmpValue = uiList.dateFormat(now, site.COMMON_DATE_MONTH_TYPE);
						this.$from.val(tmpValue);
						this.valueChange();
					}else if(this.formatList[1] == configData.INPUT_FORMAT_CALENDER_MONTH_BETWEEN){
						now.setMonth(0);
						this.searchType = "from";
						var tmpValue = uiList.dateFormat(now, site.COMMON_DATE_MONTH_TYPE);
						this.$from.val(tmpValue);
						this.valueChange();
						
						now.setMonth(11);
						this.searchType = "to";
						var tmpValue = uiList.dateFormat(now, site.COMMON_DATE_MONTH_TYPE);
						this.$to.val(tmpValue);	
						this.valueChange();
					}else if(!isNaN(this.formatList[1])){
						// input 날짜 포맷 C -7 7 20180629 PJW
						if(!isNaN(this.formatList[2])){
							var tmpNumFrom = parseInt(this.formatList[1]);
							var tmpNumTo = parseInt(this.formatList[2]);
							
							now.setMonth(now.getMonth()+tmpNumFrom);
							this.searchType = "from";
							var tmpValue = uiList.dateFormat(now, site.COMMON_DATE_MONTH_TYPE);
							this.$from.val(tmpValue);
							this.valueChange();
							
							if(tmpNumFrom != tmpNumTo) {
								now = new Date();
								now.setMonth(now.getMonth()+tmpNumTo);
								this.searchType = "to";
								var tmpValue = uiList.dateFormat(now, site.COMMON_DATE_MONTH_TYPE);
								this.$to.val(tmpValue);	
								this.valueChange();
							}
						}else{
							var tmpNum = parseInt(this.formatList[1]);
							if(tmpNum < 0){
								now.setMonth(now.getMonth()+tmpNum);
								this.searchType = "from";
								var tmpValue = uiList.dateFormat(now, site.COMMON_DATE_MONTH_TYPE);
								this.$from.val(tmpValue);
								this.valueChange();
								
								now = new Date();
								this.searchType = "to";
								var tmpValue = uiList.dateFormat(now, site.COMMON_DATE_MONTH_TYPE);
								this.$to.val(tmpValue);	
								this.valueChange();
							}else{
								this.searchType = "from";
								var tmpValue = uiList.dateFormat(now, site.COMMON_DATE_MONTH_TYPE);
								this.$from.val(tmpValue);
								this.valueChange();
								
								now.setMonth(now.getMonth()+tmpNum);
								this.searchType = "to";
								var tmpValue = uiList.dateFormat(now, site.COMMON_DATE_MONTH_TYPE);
								this.$to.val(tmpValue);
								this.valueChange();
							}
						}
					}
				}
			}
		}
		
		if(requiredInputType){
			this.$obj.addClass(site.REQUIRED_INPUT_CLASS);
		}
	},
	addMultiComboValue : function(tmpValue) {
		if(tmpValue == undefined){
			tmpValue = this.$obj.val();
		}
		if(tmpValue){
			var dataMap;
			for(var i=0;i<this.singleData.length;i++){
				dataMap = this.singleData[i];
				if(dataMap.get(configData.INPUT_RANGE_SINGLE_DATA) == tmpValue){
					return;
				}
			}
			var inputObj = this;
			
			dataMap = new DataMap();
			dataMap.put(configData.INPUT_RANGE_LOGICAL, "OR");
			dataMap.put(configData.INPUT_RANGE_OPERATOR, "E");
			dataMap.put(configData.INPUT_RANGE_SINGLE_DATA, tmpValue);
			this.singleData.push(dataMap);
			var labelText =this.$obj.find("option:selected").text();
			this.addMultiComboBtn(tmpValue, labelText);
		}		
	},
	addMultiComboBtn : function(tmpValue, labelText) {
		var $valObj = theme.getMultiValueBtn(this, labelText);
		var inputObj = this;
		$valObj.click(function(event){
			inputObj.removeMultiComboValue(tmpValue);
			$valObj.remove();
		});
		this.$obj.parent().append($valObj);
	},
	removeMultiComboValue : function(removeValue) {
		var dataMap;
		for(var i=0;i<this.singleData.length;i++){
			dataMap = this.singleData[i];
			if(dataMap.get(configData.INPUT_RANGE_SINGLE_DATA) == removeValue){
				this.singleData = commonUtil.removeRow(this.singleData, i);
				return true;
			}
		}
		return false;
	},
	removeMultiComboAll : function() {
		this.singleData = new Array();
		this.$obj.siblings().remove();
	},
	setReadOnly : function(readOnlyType) {
		this.readonlyAtt = readOnlyType;
		if(this.readonlyAtt){
			this.$from.attr("readonly", true);
			this.$to.attr("readonly", true);
		}else{
			this.$from.removeAttr("readonly");
			this.$to.removeAttr("readonly");
		}
	},
	valueChange : function(eventType) {
		if(eventType == undefined){
			eventType = false;
		}
		if(this.searchType == "from"){
			if(this.rangeData.length > 1){
				this.$to.val("");
				this.singleData = new Array();
				this.rangeData = new Array();
			}
		}else if(this.searchType == "to"){
			if(this.singleData.length > 1){
				this.$from.val("");
				this.singleData = new Array();
				this.rangeData = new Array();
			}
		}
		var fromVal  = this.$from.val();
		var toVal = this.$to.val();
		if(this.formatList){
			fromVal = uiList.getDataFormat(this.formatList, fromVal);
			toVal = uiList.getDataFormat(this.formatList, toVal);
		}
		
		this.singleData = new Array();
		this.rangeData = new Array();
		var dataMap = new DataMap();
		//2022.05.29 이범준 [Date Between] from ~ to 필수 체크
		if(this.inputAtt == configData.INPUT_BETWEEN && site.dateBetweenCheck 
				&& this.validateAtt == configData.VALIDATION_REQUIRED){
			this.singleData = new Array();
			dataMap.put(configData.INPUT_RANGE_OPERATOR, "E");
			dataMap.put(configData.INPUT_RANGE_RANGE_FROM, fromVal);
			dataMap.put(configData.INPUT_RANGE_RANGE_TO, toVal);
			this.rangeData.push(dataMap);
		}else{
			if(fromVal == "" && toVal == ""){
				//this.singleData = new Array();
				//this.rangeData = new Array();
			}else if(fromVal == ""){
				dataMap.put(configData.INPUT_RANGE_LOGICAL, "OR");
				dataMap.put(configData.INPUT_RANGE_OPERATOR, "E");
				dataMap.put(configData.INPUT_RANGE_SINGLE_DATA, toVal);
				this.singleData.push(dataMap);
			}else if(toVal == ""){
				dataMap.put(configData.INPUT_RANGE_LOGICAL, "OR");
				dataMap.put(configData.INPUT_RANGE_OPERATOR, "E");
				dataMap.put(configData.INPUT_RANGE_SINGLE_DATA, fromVal);
				this.singleData.push(dataMap);
			}else{
				this.singleData = new Array();
				dataMap.put(configData.INPUT_RANGE_OPERATOR, "E");
				dataMap.put(configData.INPUT_RANGE_RANGE_FROM, fromVal);
				dataMap.put(configData.INPUT_RANGE_RANGE_TO, toVal);
				this.rangeData.push(dataMap);
			}
		}
		
		if(eventType){
			//event fn
			if(commonUtil.checkFn("inputListEventRangeDataChange")){
				inputListEventRangeDataChange(this.name, this.singleData, this.rangeData);
			}
		}
	},
	setValue : function(data) {
		if(data){
			if(this.formatList){
				data = uiList.getDataFormat(this.formatList, data);
			}
			var dataMap = new DataMap();
			if(this.searchType == "from"){
				if(this.$to.val() && this.singleData.length == 1){
					var toData = this.singleData[0].get(configData.INPUT_RANGE_SINGLE_DATA);
					this.singleData = new Array();
					this.rangeData = new Array();
					dataMap.put(configData.INPUT_RANGE_OPERATOR, "E");
					dataMap.put(configData.INPUT_RANGE_RANGE_FROM, data);
					dataMap.put(configData.INPUT_RANGE_RANGE_TO, toData);
					this.rangeData.push(dataMap);
				}else if(this.rangeData.length == 1){
					dataMap = this.rangeData[0];
					dataMap.put(configData.INPUT_RANGE_RANGE_FROM, data);
				}else{
					this.singleData = new Array();
					dataMap.put(configData.INPUT_RANGE_LOGICAL, "OR");
					dataMap.put(configData.INPUT_RANGE_OPERATOR, "E");
					dataMap.put(configData.INPUT_RANGE_SINGLE_DATA, data);
					this.singleData.push(dataMap);
				}
			}else if(this.searchType == "to"){
				if(this.singleData.length == 1){
					var fromData = this.singleData[0].get(configData.INPUT_RANGE_SINGLE_DATA);
					this.singleData = new Array();
					this.rangeData = new Array();
					dataMap.put(configData.INPUT_RANGE_OPERATOR, "E");
					dataMap.put(configData.INPUT_RANGE_RANGE_FROM, fromData);
					dataMap.put(configData.INPUT_RANGE_RANGE_TO, data);
					this.rangeData.push(dataMap);					
				}else if(this.rangeData.length == 1){ 
					dataMap = this.rangeData[0];
					dataMap.put(configData.INPUT_RANGE_RANGE_TO, data);
				}else{
					this.singleData = new Array();
					dataMap.put(configData.INPUT_RANGE_LOGICAL, "OR");
					dataMap.put(configData.INPUT_RANGE_OPERATOR, "E");
					dataMap.put(configData.INPUT_RANGE_SINGLE_DATA, data);
					this.singleData.push(dataMap);
				}		
			}
		}else{
			if(this.searchType == "from"){
				this.singleData = new Array();
				if(this.rangeData.length == 1){
					var dataMap = this.rangeData[0];
					data = dataMap.get(configData.INPUT_RANGE_RANGE_TO);
					this.rangeData = new Array();
					this.searchType = "to";
					this.setValue(data);
				}
			}else if(this.searchType == "to"){
				if(this.rangeData.length == 1){
					var dataMap = this.rangeData[0];
					data = dataMap.get(configData.INPUT_RANGE_RANGE_FROM);
					this.rangeData = new Array();
					this.searchType = "from";
					this.setValue(data);
				}else if(this.singleData.length == 1 && this.$from.val() == ""){					
					this.singleData = new Array();
				}else{
					this.rangeData = new Array();
				}				
			}
		}
	},
	setFormatValue : function(rangeType, viewType) {
		if(this.formatList){
			var rowData;
			if(rangeType){
				for(var i=0;i<this.rangeData.length;i++){
					rowData = this.rangeData[i];
					rowData.put(configData.INPUT_RANGE_RANGE_FROM, uiList.getDataFormat(this.formatList, rowData.get(configData.INPUT_RANGE_RANGE_FROM), viewType));
					rowData.put(configData.INPUT_RANGE_RANGE_TO, uiList.getDataFormat(this.formatList, rowData.get(configData.INPUT_RANGE_RANGE_TO), viewType));
				}
			}else{
				for(var i=0;i<this.singleData.length;i++){
					rowData = this.singleData[i];
					rowData.put(configData.INPUT_RANGE_SINGLE_DATA, uiList.getDataFormat(this.formatList, rowData.get(configData.INPUT_RANGE_SINGLE_DATA), viewType));
				}
			}
		}		
	},
	setSearchValue : function(data, text) {
		if(this.searchType == "obj"){
			this.$obj.val(data);
			if(this.$searchText){
				this.$searchText.val(text);
			}
		}else if(this.searchType == "from"){
			//this.$from.val(data);
			//this.singleData[0] = data;
			this.singleData = new Array();
			for(var i=0;i<data.length;i++){
				var dataMap = new DataMap();
				dataMap.put(configData.INPUT_RANGE_LOGICAL, "OR");
				dataMap.put(configData.INPUT_RANGE_OPERATOR, "E");
				dataMap.put(configData.INPUT_RANGE_SINGLE_DATA, data[i]);
				this.singleData.push(dataMap);
			}
			this.setMultiData(true);
		}		
	},
	removeValidation : function(valAtt) {
		for(var i=0;i<this.validateList.length;i++){
			if(valAtt == this.validateList[i]){
				this.validateList = commonUtil.removeRow(this.validateList, i);
				this.validateAtt = commonUtil.removeRow(this.validateAtt, i);
				break;
			}
		}
	},
	addValidation : function(valAtt){
		if(!this.validateAtt){
			this.validateAtt = new Array();
		}
		var valList = valAtt.split(",");
		for(var i=0;i<this.validateList.length;i++){
			if(valList[0] == this.validateList[i]){
				this.validateList[i] = valList[0];
				this.validateAtt[i] = valAtt;
				return;
			}
		}
		this.validateAtt.push(valAtt);
		this.validateList.push(valAtt.split(",")[0]);
	},
	checkValidation : function() {
		var checkResult = true;
		var valAtt;
		for(var i=0;i<this.validateList.length;i++){
			valAtt = this.validateList[i];
			if(valAtt.indexOf(configData.VALIDATION_REQUIRED) == 0){
				if(this.singleData.length == 0 && this.rangeData.length == 0){
					var ruleText;
					var optionText;
					if(this.validateAtt[i].indexOf(",") == -1){
						if(this.validateAtt[i].indexOf("(") == -1){
							//optionText = this.$obj.parent().prev().text();
							optionText = theme.getValidataInputText(this.$obj);
							optionText = commonUtil.replaceAll(optionText, " ", "");
							//this.validateAtt[i] = valAtt+"("+optionText+")";
							valAtt = valAtt+"("+optionText+")";
						}else{
							ruleText = valAtt.substring(0,valAtt.indexOf("("));
							optionText = valAtt.substring(valAtt.indexOf("(")+1, valAtt.length-1);
							optionText = uiList.getLabel(optionText);
							optionText = commonUtil.replaceAll(optionText, " ", "");
							//this.validateAtt[i] = ruleText+"("+optionText+")";
							valAtt = ruleText+"("+optionText+")";
						}
					}else{
						ruleText = this.validateAtt[i].substring(0,this.validateAtt[i].indexOf(","));
						optionText = this.validateAtt[i].substring(this.validateAtt[i].indexOf(",")+1, this.validateAtt[i].length-1);
						optionText = uiList.getLabel(optionText);
						valAtt = ruleText+"("+optionText+")";
					}
					
					//checkResult = validate.checkObject("", this.validateAtt[i], this.$from, configData.VALIDATION_OBJECT_TYPE_RANGE, "", "", this.name);
					checkResult = validate.checkObject("", valAtt, this.$from, configData.VALIDATION_OBJECT_TYPE_RANGE, "", "", this.name);
					this.$from.focus();
					break;
				}
			}else{
				var dataMap;
				var valueText;
				var singleCount = this.singleData.length;
				if(singleCount > 0){
					for(var j=0;j<this.singleData.length;j++){
						dataMap = this.singleData[j];
						valueText = dataMap.get(configData.INPUT_RANGE_SINGLE_DATA);
						checkResult = validate.checkObject(valueText, valAtt, this.$from, configData.VALIDATION_OBJECT_TYPE_RANGE, "", "", this.name);
						if(!checkResult){
							this.$from.focus();
							break;
						}
					}					
				}
				var rangeCount = this.rangeData.length;
				if(rangeCount > 0){
					for(var j=0;j<this.rangeData.length;j++){
						dataMap = this.rangeData[j];
						valueText = dataMap.get(configData.INPUT_RANGE_RANGE_FROM);
						checkResult = validate.checkObject(valueText, valAtt, this.$from, configData.VALIDATION_OBJECT_TYPE_RANGE, "", "", this.name);
						if(!checkResult){
							this.$from.focus();
							break;
						}
						valueText = dataMap.get(configData.INPUT_RANGE_RANGE_TO);
						checkResult = validate.checkObject(valueText, valAtt, this.$to, configData.VALIDATION_OBJECT_TYPE_RANGE, "", "", this.name);
						if(!checkResult){
							this.$to.focus();
							break;
						}
						if(this.formatList){
							// 2019.03.07 jw : : Input Data Type Month Added
							// configData.INPUT_FORMAT_CALENDER : C
							// configData.INPUT_FORMAT_CALENDER_MONTH : CM
							if(this.formatList[0] == configData.INPUT_FORMAT_CALENDER || this.formatList[0] == configData.INPUT_FORMAT_CALENDER_MONTH){
								// configData.INPUT_RANGE_RANGE_FROM : FROM
								// configData.INPUT_RANGE_RANGE_TO : TO
								if(dataMap.get(configData.INPUT_RANGE_RANGE_FROM) > dataMap.get(configData.INPUT_RANGE_RANGE_TO)){									
									checkResult = false;
									commonUtil.msgBox("VALIDATE_datebetween", this.name);//시작일은 종료일 보다 미래일 수 없습니다.
									this.$from.focus();
									break;
								}
								// 2022-07-07(목요일) 안상현, 종료일자 - 시작일자 > 변수 경우
								else{
									const from = dataMap.get(configData.INPUT_RANGE_RANGE_FROM).replace(/(\d{4})(\d{2})(\d{2})/, "$1-$2-$3")
									const to = dataMap.get(configData.INPUT_RANGE_RANGE_TO).replace(/(\d{4})(\d{2})(\d{2})/, "$1-$2-$3")
									const diffDate = Date.parse(from) - Date.parse(to)
									
									if(this.formatList[2] && (Math.abs(diffDate / (1000 * 60 * 60 * 24)) + 1) > this.formatList[2]){
										alert("시작일자와 종료일자의 차이가 "+this.formatList[2]+"일을 초과합니다.")
										this.$from.focus()
										return
									}
								}
								
							}else if(this.formatList[0] == configData.INPUT_FORMAT_NUMBER){
								if(dataMap.get(configData.INPUT_RANGE_RANGE_FROM) >= dataMap.get(configData.INPUT_RANGE_RANGE_TO)){									
									checkResult = false;
									commonUtil.msgBox("VALIDATE_numberbetween", this.name);//숫자 범위값의 시작값이 클 수 없습니다.
									this.$from.focus();
									break;
								}
							}
						}
					}					
				}
			}
		}		
		
		return checkResult;
	},
	getDataCount : function(dataType){
		if(dataType){
			if(dataType == configData.INPUT_RANGE_TYPE_SINGLE){
				return this.singleData.length;
			}else if(dataType == configData.INPUT_RANGE_TYPE_RANGE){
				return this.rangeData.length;
			}
		}else{
			return this.singleData.length+this.rangeData.length;
		}
		return 0;
	},
	setMultiData : function(eventType) {
		if(eventType == undefined){
			eventType = false;
		}
		
		var singleCount = this.singleData.length;
		var tmpTxt = "";
		if(this.options[0] == configData.INPUT_MULTIPLE){
			this.$obj.siblings().remove();
			if(singleCount > 0){
				for(var i=0;i<singleCount;i++){
					tmpTxt = this.singleData[i].get(configData.INPUT_RANGE_SINGLE_DATA);
					//this.addMultiComboValue(tmpTxt);
					var labelText =this.$obj.find("option[value='"+tmpTxt+"']").text();
					this.addMultiComboBtn(tmpTxt, labelText);
				}
			}					
		}else if(this.options[0] == configData.INPUT_SEARCH_COMBO){
			
		}else{
			this.$from.val("");
			this.$to.val("");
		}
		
		if(singleCount == 1){
			tmpTxt = this.singleData[0].get(configData.INPUT_RANGE_SINGLE_DATA);
			if(this.formatList){
				tmpTxt = uiList.getDataFormat(this.formatList, tmpTxt, true);
			}
		}else if(singleCount > 1){
			tmpTxt = "Single("+singleCount+") ";
		}
		
		if(this.options[0] == configData.INPUT_MULTIPLE || this.options[0] == configData.INPUT_SEARCH_COMBO){
			
		}else{
			this.$from.val(tmpTxt);
		}
		tmpTxt = "";
		var rangeCount = this.rangeData.length;
		if(singleCount == 0 && rangeCount == 1){
			var dataMap = this.rangeData[0];
			tmpTxt = dataMap.get(configData.INPUT_RANGE_RANGE_FROM);
			if(this.formatList){
				tmpTxt = uiList.getDataFormat(this.formatList, tmpTxt, true);
			}
			this.$from.val(tmpTxt);
			tmpTxt = dataMap.get(configData.INPUT_RANGE_RANGE_TO);
			if(this.formatList){
				tmpTxt = uiList.getDataFormat(this.formatList, tmpTxt, true);
			}
			if(this.options[0] == configData.INPUT_SHORT_RANGE){
				tmpTxt = "Range(1) ";
				this.$from.val(tmpTxt);
			}else{
				this.$to.val(tmpTxt);
			}			
		}else if(rangeCount > 0){
			tmpTxt = "Range("+rangeCount+") ";
			if(this.options[0] == configData.INPUT_SHORT_RANGE){
				if(singleCount > 0){
					tmpTxt = "Multi("+(singleCount+rangeCount)+") ";
				}
				this.$from.val(tmpTxt);
			}else{
				this.$to.val(tmpTxt);
			}			
		}
		
		if(eventType){
			//event fn
			if(commonUtil.checkFn("inputListEventRangeDataChange")){
				inputListEventRangeDataChange(this.name, this.singleData, this.rangeData);
			}
		}
	},
	resetData : function() {
		this.singleData = new Array();
		this.rangeData = new Array();
		this.setMultiData();
	},
	dataCheck : function() {
		if(this.options[0] == configData.INPUT_RANGE || this.options[0] == configData.INPUT_SHORT_RANGE || this.options[0] == configData.INPUT_BETWEEN){
			if(this.rangeData.length == 0 && this.$from.val() && this.$to.val()){
				this.$from.trigger("change");
				this.$to.trigger("change");
			}
			if(this.rangeData.length == 0 && this.singleData.length == 0 && (this.$from.val() || this.$to.val())){
				this.$from.trigger("change");
				this.$to.trigger("change");
			}
		}
	},
	toString : function() {
		return "InputObj";
	}
}

RangeObject = function() {
	this.$singleGrid;
	this.$rangeGrid;
	this.$input;
};

RangeObject.prototype = {
	resetRange : function() {
		this.$input = null;
	},
	setRange : function($input) {
		if(!this.$singleGrid){
			this.$singleGrid = gridList.getGridBox(configData.INPUT_RANGE_SINGLEGRID_ID);
			var addCols = new Array();
			addCols.push(configData.INPUT_RANGE_LOGICAL);
			addCols.push(configData.INPUT_RANGE_OPERATOR);
			addCols.push(configData.INPUT_RANGE_SINGLE_DATA);
			this.$singleGrid.resetCols(addCols);
			
			this.$rangeGrid = gridList.getGridBox(configData.INPUT_RANGE_RANGEGRID_ID);
			addCols = new Array();
			addCols.push(configData.INPUT_RANGE_OPERATOR);
			addCols.push(configData.INPUT_RANGE_RANGE_FROM);
			addCols.push(configData.INPUT_RANGE_RANGE_TO);
			this.$rangeGrid.resetCols(addCols);
		}
		this.$input = $input;
		
		if($input.readonlyAtt){			
			this.$singleGrid.setReadOnlyProp(true);
			this.$rangeGrid.setReadOnlyProp(true);
		}else{
			this.$singleGrid.setReadOnlyProp(false);
			this.$rangeGrid.setReadOnlyProp(false);			
		}
		
		if($input.formatList){
			var singleFormat = new DataMap();
			singleFormat.put(configData.INPUT_RANGE_SINGLE_DATA, $input.formatList);
			this.$singleGrid.resetColFormat(singleFormat, [configData.INPUT_RANGE_SINGLE_DATA]);
			
			var rangeFormat = new DataMap();
			rangeFormat.put(configData.INPUT_RANGE_RANGE_FROM, $input.formatList);
			rangeFormat.put(configData.INPUT_RANGE_RANGE_TO, $input.formatList);
			this.$rangeGrid.resetColFormat(rangeFormat, [configData.INPUT_RANGE_RANGE_FROM,configData.INPUT_RANGE_RANGE_TO]);			
		}else{
			this.$singleGrid.resetColFormat(null, [configData.INPUT_RANGE_SINGLE_DATA]);
			this.$rangeGrid.resetColFormat(null, [configData.INPUT_RANGE_RANGE_FROM,configData.INPUT_RANGE_RANGE_TO]);
		}
		
		if($input.options[1]){
			var singleFormat = new DataMap();
			singleFormat.put(configData.INPUT_RANGE_SINGLE_DATA, $input.options[1]);
			this.$singleGrid.resetColSearch(singleFormat);
			
			var rangeFormat = new DataMap();
			rangeFormat.put(configData.INPUT_RANGE_RANGE_FROM, $input.options[1]);
			rangeFormat.put(configData.INPUT_RANGE_RANGE_TO, $input.options[1]);
			this.$rangeGrid.resetColSearch(rangeFormat);
		}else{
			this.$singleGrid.resetColSearch();
			this.$rangeGrid.resetColSearch();
		}
		if(this.$input.singleData.length == 0 && this.$input.rangeData.length > 0){
			$('#rangePopupTabs').tabs("option", "active", 1);
		}else{
			$('#rangePopupTabs').tabs("option", "active", 0);
		}		
		
		this.setRangeData(this.$singleGrid, this.$input.singleData);
		this.setRangeData(this.$rangeGrid, this.$input.rangeData, true);
		
		rangePop();
	},
	
	setRangeData : function($grid, data, rangeType) {
		var dataCount = data.length;
		$grid.reset();
		
		if(dataCount > 0){
			for(var i=0;i<dataCount;i++){
				$grid.addRow(data[i], false);
			}
		}
		var newMap = new DataMap();
		newMap.put("LOGICAL", "OR");
		newMap.put("OPER", "E");
		for(var i=dataCount;i<20;i++){
			$grid.addRow(newMap, false);
		}
		
		$grid.setScrollTop();

		$grid.rowFocus(0, false, true);
	},
	confirmRange : function() {
		var singleData = gridList.getGridData(configData.INPUT_RANGE_SINGLEGRID_ID);
		this.$input.singleData = new Array();
		for(var i=0;i<singleData.length;i++){
			var dataMap = singleData[i];
			if(dataMap.get(configData.INPUT_RANGE_SINGLE_DATA)){
				this.$input.singleData.push(dataMap);
			}
		}
		
		var rangeData = gridList.getGridData(configData.INPUT_RANGE_RANGEGRID_ID);
		this.$input.rangeData = new Array();
		for(var i=0;i<rangeData.length;i++){
			var dataMap = rangeData[i];
			if(dataMap.get(configData.INPUT_RANGE_RANGE_FROM) && dataMap.get(configData.INPUT_RANGE_RANGE_TO)){
				this.$input.rangeData.push(dataMap);
			}
		}
		
		this.$input.setMultiData(true);
		rangePopClose();
	},
	clearRange : function(gridId) {
		if(this.$input.readonlyAtt){
			return;
		}
		if(gridId == configData.INPUT_RANGE_SINGLEGRID_ID){
			//this.$input.singleData = new Array();
			//this.setRangeData(this.$singleGrid, this.$input.singleData);
			this.setRangeData(this.$singleGrid, new Array());
			this.$singleGrid.rowFocus(0, false, true);
		}else if(gridId == configData.INPUT_RANGE_RANGEGRID_ID){
			//this.$input.rangeData = new Array();
			//this.setRangeData(this.$rangeGrid, this.$input.rangeData);
			this.setRangeData(this.$rangeGrid, new Array());
			this.$rangeGrid.rowFocus(0, false, true);
		}
	},
	getRangeName : function() {
		return this.$input.name;
	},
	toString : function() {
		return "RangeObject";
	}
}

var rangeObj = new RangeObject();

InputList = function() {	
	this.searchMap = new DataMap();
	this.rangeMap = new DataMap();
	this.comboDataMap = new DataMap();
	this.comboMap = new DataMap();
	this.multiComboMap = new DataMap();
	this.userParamMap = new DataMap();
	this.userParamList = new Array();
	this.operMap = new DataMap();
	this.operMap.put("E", "=");
	this.operMap.put("N", "!=");
	this.operMap.put("LT", "<");
	this.operMap.put("GT", ">");
	this.operMap.put("LE", "<=");
	this.operMap.put("GE", ">=");
	
	this.comboCodeViewType = true;
	
	this.rangeSqlNameMap = new DataMap();
	
	// Cuty JJin 2018.10.10 PJW
	// rangeNameList Name
	this.rangeNameList = new Array();
};

InputList.prototype = {
	setInput : function(areaId) {
		
		var $area = commonUtil.getArea(areaId);
		$area.find("["+ configData.INPUT +"]").each(function(i, findElement){
			var $obj = jQuery(findElement);				
			var inputAtt = $obj.attr(configData.INPUT);
						
			var inputObj = new InputObj($obj);
			if(inputObj.options[0] == configData.INPUT_SEARCH){
				inputList.searchMap.put($obj.attr("name"), inputObj);
			}else if(inputObj.options[0] == configData.INPUT_RANGE || inputObj.options[0] == configData.INPUT_SHORT_RANGE || inputObj.options[0] == configData.INPUT_BETWEEN || inputObj.options[0] == configData.INPUT_MULTIPLE){				
				inputList.rangeMap.put($obj.attr("name"), inputObj);
			}
			
			// Cuty JJin 2018.10.10 PJW
			// Range Name 에 따른 함수 추가 
			if(inputObj.rangeName){
				if(inputList.rangeNameList.length > 0){
					var checkRange = true;
					for(var i=0; i<inputList.rangeNameList.length;i++){
						if(inputList.rangeNameList[i] == inputObj.rangeName){
							checkRange = false;
							break;
						}
					}
					if(checkRange){
						inputList.rangeNameList.push(inputObj.rangeName);
					}
				}else{
					inputList.rangeNameList.push(inputObj.rangeName);
				}
			}
		});
	},
	// Cuty JJin 2018.10.10
	// Range Name 에 따른 함수 추가
	setRangeMultiParam : function(areaId, map) {
		return this.setRangeDataMultiParam(areaId, map);
	},
	setRangeDataMultiParam : function(areaId, map) {
		if(!map){ 
			map = new DataMap();
		}
		map = dataBind.paramData(areaId);
		
		for(var i=0; i<this.rangeNameList.length; i++){
			var rParam = this.getRangeDataMultiParam(this.rangeNameList[i]);	
			map.put( (this.rangeNameList[i] == configData.INPUT_RNAGE_DATA_PARAM) ? configData.INPUT_RNAGE_DATA_PARAM : configData.INPUT_RNAGE_DATA_PARAM +this.rangeNameList[i], rParam);
		}
		
		map.put("RANGE_NAME_LIST", this.rangeNameList);
		return map;
	},
	getRangeDataMultiParam : function(rangeName) {
		var param = new DataMap();

		var sqlName;
		for(var prop in this.rangeMap.map){
			var inputObj = this.rangeMap.get(prop);
			
			if(inputObj.rangeName != rangeName){
				continue;
			}
			
			if(this.rangeSqlNameMap.containsKey(prop)){
				sqlName = this.rangeSqlNameMap.get(prop);
			}else{
				sqlName = prop;
			}
			
			inputObj.dataCheck();
			if(inputObj.singleData.length > 0){
				var tmpData;
				var rowData;
				var tmpList = new Array();
				for(var i=0;i<inputObj.singleData.length;i++){
					rowData = inputObj.singleData[i];
					tmpData = rowData.get(configData.INPUT_RANGE_OPERATOR)
								+ configData.DATA_COL_SEPARATOR
								+ rowData.get(configData.INPUT_RANGE_SINGLE_DATA)
								+ configData.DATA_COL_SEPARATOR
								+ rowData.get(configData.INPUT_RANGE_LOGICAL);
					tmpList.push(tmpData);
				}
				param.put(sqlName+"_"+configData.INPUT_RANGE_TYPE_SINGLE, tmpList.join(configData.DATA_ROW_SEPARATOR));
			}
			if(inputObj.rangeData.length > 0){
				var tmpData;
				var rowData;
				var tmpList = new Array();
				for(var i=0;i<inputObj.rangeData.length;i++){
					rowData = inputObj.rangeData[i];
					tmpData = rowData.get(configData.INPUT_RANGE_OPERATOR)
								+ configData.DATA_COL_SEPARATOR
								+ rowData.get(configData.INPUT_RANGE_RANGE_FROM)
								+ configData.DATA_COL_SEPARATOR
								+ rowData.get(configData.INPUT_RANGE_RANGE_TO);
					tmpList.push(tmpData);
				}
				param.put(sqlName+"_"+configData.INPUT_RANGE_TYPE_RANGE, tmpList.join(configData.DATA_ROW_SEPARATOR));
			}
		}
		
		//2019.02.20 멀티콤보 추가
		var $comboObj;
		var comboValues;
		
		for(var prop in this.multiComboMap.map){
			if(this.rangeSqlNameMap.containsKey(prop)){
				sqlName = this.rangeSqlNameMap.get(prop);
			}else{
				sqlName = prop;
			}
			$comboObj = this.multiComboMap.get(prop);
			
			
			var comboRangeName;
			if(rangeName == configData.INPUT_RNAGE_DATA_PARAM) {
				if($comboObj.attr(configData.INPUT_RANGE_NAME) == undefined) {
					comboRangeName = rangeName;
				} else {
					comboRangeName = "X";
				}
			} else {
				if($comboObj.attr(configData.INPUT_RANGE_NAME) == undefined) {
					comboRangeName = "X";
				} else {
					comboRangeName = $comboObj.attr(configData.INPUT_RANGE_NAME);
				}
			}
			
			if(rangeName != comboRangeName) {
				continue;
			}
			
			comboValues = $comboObj.multipleSelect("getSelects");
			if(comboValues && comboValues.length > 0){
				var tmpList = new Array();
				for(var i=0;i<comboValues.length;i++){
					rowData = comboValues[i];
					tmpData = "E"
								+ configData.DATA_COL_SEPARATOR
								+ rowData
								+ configData.DATA_COL_SEPARATOR
								+ "OR";
					tmpList.push(tmpData);
				}
				param.put(sqlName+"_"+configData.INPUT_RANGE_TYPE_SINGLE, tmpList.join(configData.DATA_ROW_SEPARATOR));
			}			
		}
		
		return param;
	},
	setRangeParam : function(areaId, map) {
		return this.setRangeDataParam(areaId, map);
	},
	setRangeDataParam : function(areaId, map) {
		if(!map){ 
			map = new DataMap();
		}
		map = dataBind.paramData(areaId);
		
		var rParam = this.getRangeDataParam();
		
		// configData.INPUT_PARAM_GROUP : PGroup
		if(rParam.containsKey(configData.INPUT_PARAM_GROUP)){
			// configData.INPUT_PARAM_GROUP : PGroup
			map.put(configData.INPUT_PARAM_GROUP, rParam.get(configData.INPUT_PARAM_GROUP));
			rParam.remove(configData.INPUT_PARAM_GROUP);
		}
		
		map.put(configData.INPUT_RNAGE_DATA_PARAM, rParam);
		
		return map;
	},
	copyRangeParam : function(param, sourceName, targetName) {
		if(param.containsKey(configData.INPUT_RNAGE_DATA_PARAM)){
			var rangeData = param.get(configData.INPUT_RNAGE_DATA_PARAM).get(sourceName+"_"+configData.INPUT_RANGE_TYPE_RANGE);
			var singleData = param.get(configData.INPUT_RNAGE_DATA_PARAM).get(sourceName+"_"+configData.INPUT_RANGE_TYPE_SINGLE);
			param.get(configData.INPUT_RNAGE_DATA_PARAM).put(targetName+"_"+configData.INPUT_RANGE_TYPE_RANGE, rangeData);
			param.get(configData.INPUT_RNAGE_DATA_PARAM).put(targetName+"_"+configData.INPUT_RANGE_TYPE_SINGLE, singleData);
		}
	},
	getRangeParam : function(areaId) {
		var map = new DataMap();

		map = dataBind.paramData(areaId);

		for(var prop in this.rangeMap.map){
			var inputObj = this.rangeMap.get(prop);
			var sData = inputObj.singleData;
			var rData = inputObj.rangeData;
			map.put(prop+"_SINGLE", sData);
			map.put(prop+"_RANGE", rData);
		}
		
		return map;
	},
	appendRangeParam : function(map, sourceName, targetName) {
		var sqlTxt = map.get(configData.INPUT_RNAGE_SQL);

		var inputObj = this.rangeMap.get(sourceName);
	},
	getWhereInString : function(dataList, colName) {
		var inStr = "";
		var rowMap;
		for(var i=0;i<dataList.length;i++){
			rowMap = dataList[i];
			if(i != 0){
				inStr += ",";
			}
			inStr += "\u0027"+rowMap.get(colName)+"\u0027";
		}
		return inStr;
	},
	getComboCodeViewAtt : function($obj) {
		// configData.INPUT_COMBO_CODE_VIEW_TYPE : ComboCodeView
		var comboCodeView = $obj.attr(configData.INPUT_COMBO_CODE_VIEW_TYPE);
		if(comboCodeView == "false"){
			return false;
		}else{
			return true;
		}
	},
	setCombo : function(areaId) {
		var $scanArea = commonUtil.getArea(areaId);
		
		var $comboList = $scanArea.find("select["+configData.INPUT_COMMON_COMBO+"]");
		for(var i=0;i<$comboList.length;i++){
			var commonCode = $comboList.eq(i).attr(configData.INPUT_COMMON_COMBO);
			var codeViewType = this.getComboCodeViewAtt($comboList.eq(i));
			var optionHtml;
			if(theme.comboCash && this.comboMap.containsKey(commonCode)){
				optionHtml = this.comboMap.get(commonCode);
			}else{			
				var param = new DataMap();
				param.put("CODE", commonCode);
				
				var json = netUtil.sendData({
					module : "Common",
					command : "COMCOMBO",
					sendType : "list",
					param : param
				});
				
				optionHtml = this.selectHtml(json.data, codeViewType);
				this.comboMap.put(commonCode, optionHtml);
				this.comboDataMap.put(commonCode, json.data);
			}
						
			$comboList.eq(i).find("["+configData.INPUT_COMBO_OPTION+"]").remove();
			
			$comboList.eq(i).append(optionHtml);
			
			
			
			//$comboList.eq(i).scombobox();
		}
		
		$comboList = $scanArea.find("select["+configData.INPUT_REASON_COMBO+"]");
		for(var i=0;i<$comboList.length;i++){
			var reasonCode = $comboList.eq(i).attr(configData.INPUT_REASON_COMBO);
			var codeViewType = this.getComboCodeViewAtt($comboList.eq(i));
			var optionHtml;
			if(theme.comboCash && this.comboMap.containsKey(reasonCode)){
				optionHtml = this.comboMap.get(reasonCode);
			}else{			
				var param = new DataMap();
				param.put("DOCUTY", reasonCode);
				
				var json = netUtil.sendData({
					module : "Wms",
					command : "RSNCD",
					sendType : "list",
					param : param
				});
				
				optionHtml = this.selectHtml(json.data, codeViewType);
				this.comboMap.put(reasonCode, optionHtml);
				this.comboDataMap.put(reasonCode, json.data);
			}
						
			$comboList.eq(i).find("["+configData.INPUT_COMBO_OPTION+"]").remove();
			
			$comboList.eq(i).append(optionHtml);
		}
		
		$comboList = $scanArea.find("["+configData.INPUT_COMBO+"]");
		var groupType;
		for(var i=0;i<$comboList.length;i++){
			var comboCode = $comboList.eq(i).attr(configData.INPUT_COMBO).split(",");
			var codeViewType = this.getComboCodeViewAtt($comboList.eq(i));
			var codeKey = comboCode[0]+"_"+comboCode[1];
			if(comboCode[2] != undefined){
				codeKey += "_" + comboCode[2];
			}
			var optionHtml;
			//오류로 인한 주석처리 20220225
			//if(theme.comboCash && this.comboMap.containsKey(codeKey)){
			if(this.comboMap.containsKey(codeKey)){
				optionHtml = this.comboMap.get(codeKey);
			}else{	
				var param = new DataMap();
				//event fn
				if(commonUtil.checkFn("comboEventDataBindeBefore")){
					param = comboEventDataBindeBefore(comboCode, $comboList.eq(i));
				}
				
				if(param == undefined){
					param = new DataMap();
				}
				
				if(comboCode.length > 2) {
					for(var j=2;j<comboCode.length;j++){
						param.put("CODE"+(j-1), comboCode[j]);
					}
				}	
				
				var json = netUtil.sendData({
					module : comboCode[0],
					command : comboCode[1],
					sendType : "list",
					param : param
				});
				
				optionHtml = this.selectHtml(json.data, codeViewType);
				
				this.comboMap.put(codeKey, optionHtml);
				this.comboDataMap.put(codeKey, json.data);
			}			
			
			$comboList.eq(i).find("["+configData.INPUT_COMBO_OPTION+"]").remove();
			
			$comboList.eq(i).append(optionHtml);
		}
		
		$scanArea.find("["+ configData.INPUT_COMBO_TYPE +"]").each(function(i, findElement){
			var $obj = jQuery(findElement);
			var tmpAtt = $obj.attr(configData.INPUT_COMBO_TYPE);
			var name = $obj.attr("name");
			tmpAtt = tmpAtt.split(",");
			var comboAtt = tmpAtt[0];
			var comboInput = tmpAtt[1];
			var selectMsg = commonUtil.getMsg(configData.MSG_SELECTDATA);
			//inputList.multiComboMap.put($obj.attr("name"), $obj);
			if(comboAtt == configData.INPUT_SEARCH_COMBO){
				var tmpWidth = commonUtil.getCssNum($obj, "width");
				if(tmpWidth < 100){
					tmpWidth = '230px';
				}else{
					tmpWidth += "px";
				}
				var $tmpInput = theme.setSearchCombo($obj, comboInput);				
				$obj.multipleSelect({
		            width: tmpWidth,
		            selectAll: false,
		            filter: true,
		            single: true,
		            placeholder: selectMsg,
		            onClose: function(view) {
		            	//event fn
						if(commonUtil.checkFn("multiComboChange")){
							var values =  $obj.multipleSelect("getSelects");
							multiComboChange(name, values);
						}
		            }
		        });
				theme.setComboLayout($obj);
				//$obj.multipleSelect("setSelects", [site.emptyValue]);
				$obj.multipleSelect("setSelects", new Array());
				if(comboInput){
					$tmpInput.keypress(function(event){
						if(event.keyCode == 13){
							var tmpValue = $tmpInput.val();
							if(tmpValue){
								$obj.multipleSelect("setSelects", [tmpValue]);
								$tmpInput.val("");
								//event fn
								if(commonUtil.checkFn("multiComboChange")){
									var values =  $obj.multipleSelect("getSelects");
									multiComboChange(name, values);
								}
							}
						}
					});
					$tmpInput.change(function(event){
						var tmpValue = $tmpInput.val();
						if(tmpValue){
							$obj.multipleSelect("setSelects", [tmpValue]);
							$tmpInput.val("");
							//event fn
							if(commonUtil.checkFn("multiComboChange")){
								var values =  $obj.multipleSelect("getSelects");
								multiComboChange(name, values);
							}
						}
					});
				}
			}else if(comboAtt == configData.INPUT_MULTIPLE_COMBO || comboAtt == configData.INPUT_MULTIPLE_SEARCH_COMBO){
				inputList.multiComboMap.put($obj.attr("name"), $obj);
				var tmpWidth = commonUtil.getCssNum($obj, "width");
				if(tmpWidth < 100){
					tmpWidth = '230px';
				}else{
					tmpWidth += "px";
				}
				var filterType = true;
				if(comboAtt == configData.INPUT_MULTIPLE_COMBO){
					filterType = false;
				}
				var $tmpInput = theme.setMultipleCombo($obj, comboInput);				
				$obj.multipleSelect({
		            width: tmpWidth,
		            filter: filterType,
		            placeholder: selectMsg,
		            onClose: function(view) {
		            	//event fn
						if(commonUtil.checkFn("multiComboChange")){
							var values =  $obj.multipleSelect("getSelects");
							multiComboChange(name, values);
						}
		            }
		        });
				theme.setComboLayout($obj);
				//$obj.multipleSelect("setSelects", [site.emptyValue]);
				$obj.multipleSelect("setSelects", new Array());
				if(comboInput){
					$tmpInput.keypress(function(event){
						if(event.keyCode == 13){
							
							var tmpValues = $tmpInput.val();
							if(tmpValues){
								tmpValues = tmpValues.split(",");
								var values =  $obj.multipleSelect("getSelects");
								if(values.length > 0){
									values = values.concat(tmpValues);
								}else{
									values = tmpValues;
								}		
								
								$obj.multipleSelect("setSelects", values);
								$tmpInput.val("");
								//event fn
								if(commonUtil.checkFn("multiComboChange")){
									var values =  $obj.multipleSelect("getSelects");
									multiComboChange(name, values);
								}
							}
						}
					});
					$tmpInput.change(function(event){
						var tmpValues = $tmpInput.val();
						if(tmpValues){
							tmpValues = tmpValues.split(",");
							var values =  $obj.multipleSelect("getSelects");
							if(values.length > 0){
								values = values.concat(tmpValues);
							}else{
								values = tmpValues;
							}		
							
							$obj.multipleSelect("setSelects", values);
							$tmpInput.val("");
							//event fn
							if(commonUtil.checkFn("multiComboChange")){
								var values =  $obj.multipleSelect("getSelects");
								multiComboChange(name, values);
							}
						}
					});
				}
			}
		});
	},
	setGridCombo : function($obj, event) {
		theme.setGridCombo($obj, event);
	},
	getMultiComboValue : function(obj) {
		var $obj = commonUtil.getJObj(obj);
		var values =  $obj.multipleSelect("getSelects");
		return values;
	},
	setMultiComboSelectAll : function($obj, checkType) {
		if(checkType){
			$obj.multipleSelect("checkAll");
		}else{
			$obj.multipleSelect("uncheckAll");
		}		
	},
	setMultiComboValue : function(obj, values, eventType) {
		var $obj = commonUtil.getJObj(obj);
		if(typeof values == "string"){
			var tmpValues = new Array();
			tmpValues.push(values);
			$obj.multipleSelect("setSelects", tmpValues);
		}else{
			$obj.multipleSelect("setSelects", values);
		}
		if(eventType){
			//event fn
			if(commonUtil.checkFn("multiComboChange")){
				var values =  $obj.multipleSelect("getSelects");
				var name = $obj.attr("name");
				multiComboChange(name, values);
			}
		}		
	},
	addMultiComboValue : function(obj, values, eventType) {
		var $obj = commonUtil.getJObj(obj);
		var tmpValues = $obj.multipleSelect("getSelects");
		if(typeof values == "string"){
			tmpValues.push(values);
			$obj.multipleSelect("setSelects", tmpValues);
		}else{
			tmpValues = tmpValues.concat(values);
			$obj.multipleSelect("setSelects", tmpValues);
		}
		
		if(eventType){
			//event fn
			if(commonUtil.checkFn("multiComboChange")){
				var values =  $obj.multipleSelect("getSelects");
				var name = $obj.attr("name");
				multiComboChange(name, tmpValues);
			}
		}		
	},
	removeMultiComboValue : function(obj, values, eventType) {
		var $obj = commonUtil.getJObj(obj);
		var tmpValues = $obj.multipleSelect("getSelects");
		var newValues = new Array();
		var tmpStr;
		for(var i=0;i<tmpValues.length;i++){
			tmpStr = tmpValues[i];
			if(values.indexOf(tmpStr) == -1){
				newValues.push(tmpStr);
			}
		}
		$obj.multipleSelect("setSelects", newValues);
		if(eventType){
			//event fn
			if(commonUtil.checkFn("multiComboChange")){
				var values =  $obj.multipleSelect("getSelects");
				var name = $obj.attr("name");
				multiComboChange(name, values);
			}
		}		
	},
	resetMultiComboValue : function(obj, eventType) {
		var $obj = commonUtil.getJObj(obj);
		$obj.multipleSelect("setSelects", new Array());
		if(eventType){
			//event fn
			if(commonUtil.checkFn("multiComboChange")){
				var values =  $obj.multipleSelect("getSelects");
				var name = $obj.attr("name");
				multiComboChange(name, values);
			}
		}
	},
	reloadCombo : function($comboObj, comboType, comboData, codeViewType, paramData) {
		var optionHtml;
		var json;
		var comboCodeView = this.getComboCodeViewAtt($comboObj);
		if(codeViewType == undefined){
			codeViewType = true;
		}
		
		if(comboType == configData.INPUT_COMMON_COMBO){
			var param = new DataMap();
			param.put("CODE", comboData);
			
			json = netUtil.sendData({
				module : "Common",
				command : "COMCOMBO",
				sendType : "list",
				param : param
			});
			
			optionHtml = this.selectHtml(json.data, codeViewType);
		}else if(comboType == configData.INPUT_REASON_COMBO){
			var param = new DataMap();
			param.put("DOCUTY", comboData);
			
			json = netUtil.sendData({
				module : "Wms",
				command : "RSNCD",
				sendType : "list",
				param : param
			});
			
			optionHtml = this.selectHtml(json.data, codeViewType);
			
		}else if(comboType == configData.INPUT_COMBO){
			var comboCode = comboData.split(",");
			var codeKey = comboCode[0]+"_"+comboCode[1];
			var param;
			if(paramData){
				param = paramData;
			}else{
				param = new DataMap();
				//event fn
				if(commonUtil.checkFn("comboEventDataBindeBefore")){
					param = comboEventDataBindeBefore(comboCode, $comboObj);
				}
			}
			
			json = netUtil.sendData({
				module : comboCode[0],
				command : comboCode[1],
				sendType : "list",
				param : param
			});
			
			optionHtml = this.selectHtml(json.data, codeViewType);
		}else{
			var comboCode = comboData.split(",");
			var codeKey = comboCode[0]+"_"+comboCode[1];
			var param;
			if(paramData){
				param = paramData;
			}else{
				param = new DataMap();
				//event fn
				if(commonUtil.checkFn("comboEventDataBindeBefore")){
					param = comboEventDataBindeBefore(comboCode, $comboObj);
				}
			}
			
			json = netUtil.sendData({
				module : comboCode[0],
				command : comboCode[1],
				sendType : "list",
				param : param
			});
			
			optionHtml = this.selectHtml(json.data, codeViewType);
		}
		
		this.comboMap.put(comboData, optionHtml);
		this.comboDataMap.put(comboData, json.data);
					
		$comboObj.find("["+configData.INPUT_COMBO_OPTION+"]").remove();
		
		$comboObj.append(optionHtml);
		
		var comboAtt = $comboObj.attr(configData.INPUT_COMBO_TYPE);
		if(comboAtt){
			comboAtt = comboAtt.split(",");		
			if(comboAtt[0] == configData.INPUT_SEARCH_COMBO || comboAtt[0] == configData.INPUT_MULTIPLE_COMBO){
				$comboObj.multipleSelect('refresh');
				//event fn
				if(commonUtil.checkFn("multiComboChange")){
					var values =  $comboObj.multipleSelect("getSelects");
					var name = $comboObj.attr("name");
					multiComboChange(name, values);
				}
			}
		}		
		
		//2019.02.25 afterEvent 추가
		//event fn
		if(commonUtil.checkFn("comboEventDataBindeAfter")){
			comboEventDataBindeAfter(comboCode, $comboObj);
		}
	},
	reloadComboDataReset : function($comboObj, comboAtt) {
		var optionHtml = this.comboMap.get(comboAtt);
					
		$comboObj.find("["+configData.INPUT_COMBO_OPTION+"]").remove();
		
		$comboObj.append(optionHtml);
	},
	reloadComboData : function(comboAtt, codeViewType, reloadData) {
		var comboCode = comboAtt.split(",");
		var codeKey = comboCode[0]+"_"+comboCode[1];
		
		optionHtml = this.selectHtml(reloadData, codeViewType);
		
		this.comboMap.put(comboAtt, optionHtml);
		this.comboDataMap.put(comboAtt, reloadData);
	},
	getComboData : function(comboCode, codeValue, groupValue) {
		var dataMap = this.comboDataMap.get(comboCode);
		var codeText;
		for(var i=0;i<dataMap.length;i++){
			if(groupValue){
				if(dataMap[i].GROUP_COL == groupValue && dataMap[i].VALUE_COL == codeValue){
					codeText = dataMap[i].TEXT_COL;
					break;
				}
			}else{
				if(dataMap[i].VALUE_COL == codeValue){
					codeText = dataMap[i].TEXT_COL;
					break;
				}
			}
		}		
		
		return codeText;
	},
	selectHtml : function(data, codeViewType) {
		var selectHtml= ""; // 기본 option을 포함한 html을 가진다.
		// data를 option으로 만들어준다.
		var group;
		var text;
		for(var i=0;i<data.length;i++){
			group = "";
			text = "";
			if(data[i]){
				if(data[i][configData.INPUT_COMBO_GROUP_COL]){
					group = " "+configData.INPUT_COMBO_OPTION_GROUP+" = "+data[i][configData.INPUT_COMBO_GROUP_COL]+" ";
				}
				text = data[i][configData.INPUT_COMBO_TEXT_COL];
				if(this.comboCodeViewType && codeViewType){
					text = "["+data[i][configData.INPUT_COMBO_VALUE_COL]+"]"+text;
				}
				selectHtml += "<option "+configData.INPUT_COMBO_OPTION+"='true'"
						+ group
						+ "  value='"+data[i][configData.INPUT_COMBO_VALUE_COL]+"'>"
						+ text+"</option>\n";
			}
		}
		return selectHtml;
	},
	getRangeData : function(rangeName, type) {
		var $inputObj = this.rangeMap.get(rangeName);
		if($inputObj){
			if(type == configData.INPUT_RANGE_TYPE_SINGLE){
				return $inputObj.singleData;
			}else if(type == configData.INPUT_RANGE_TYPE_RANGE){
				return $inputObj.rangeData;
			}else{
				var data = new DataMap();
				data.put(configData.INPUT_RANGE_TYPE_SINGLE, $inputObj.singleData);
				data.put(configData.INPUT_RANGE_TYPE_RANGE, $inputObj.rangeData);
				return data;
			}
		}
	},
	setRangeData : function(rangeName, type, data) {
		var $inputObj = this.rangeMap.get(rangeName);
		if($inputObj){
			$inputObj.searchType = "from";
			$inputObj.$from.val($inputObj.$obj.val());
			$inputObj.valueChange();
			
			if(type == configData.INPUT_RANGE_RANGE_FROM){
				$inputObj.searchType = "from";
				$inputObj.$from.val(data);
				$inputObj.valueChange();
			}else if(type == configData.INPUT_RANGE_RANGE_TO){
				$inputObj.searchType = "to";
				$inputObj.$to.val(data);
				$inputObj.valueChange();
			}else if(type == configData.INPUT_RANGE_TYPE_SINGLE){
				$inputObj.singleData = data;
			}else if(type == configData.INPUT_RANGE_TYPE_RANGE){
				$inputObj.rangeData = data;
			}
			$inputObj.setMultiData();
		}
	},
	resetRange : function(rangeName) {
		var $inputObj;
		if(!rangeName){
			for(var prop in this.rangeMap.map){
				$inputObj = this.rangeMap.get(prop);
				$inputObj.resetData();
			}
		}else{
			$inputObj = this.rangeMap.get(rangeName);
			if($inputObj){
				$inputObj.resetData();
			}
		}
	},
	addUserParamMap : function(ctrlid, ctrval) {
		this.userParamMap.put(ctrlid, ctrval);
	},
	addUserParamList : function(parmky, shortx) {
		var map = new DataMap();
		map.put("PARMKY", parmky);
		map.put("SHORTX", shortx);
		this.userParamList.push(map);
	},
	bindSearchAreaDefaultParam : function(defMap) {
		dataBind.dataNameBind(defMap, configData.SEARCH_AREA_ID, null, site.emptyValue);
		this.dataRangeBind(defMap);
		this.dataMultiComboBind(defMap);
	},
	setSearchAreaDefaultParam : function() {
		if(this.userParamMap.size() > 0){
			//alert(this.userParamMap.toString());
			this.bindSearchAreaDefaultParam(this.userParamMap);
		}
		if(this.userParamList.length > 0){
			var $getVariantList = jQuery("#getVariantList");
			if($getVariantList.length > 0){
				var row;
				var tmpHtml;
				for(var i=0;i<this.userParamList.length;i++){
					row = this.userParamList[i];
					tmpHtml = "<option value='"+row.get("PARMKY")+"'>["+row.get("PARMKY")+"]"+row.get("SHORTX")+"</option>";
					$getVariantList.append(tmpHtml);
				}
			}
		}
	},
	changeVariant : function(obj) {
		var $getVariantList = jQuery(obj);
		if(!$getVariantList.val()){
			return;
		}
		//alert($getVariantList.val());
		var param = new DataMap();
		param.put("PARMKY", $getVariantList.val());
		param.put("PROGID", configData.MENU_ID);
		var json = netUtil.sendData({
			module : "Common",
			command : "USRPI",
	    	param : param
		});
		if(json && json.data){
			//alert(JSON.stringify(json));
			var defMap = new DataMap();
			for(var i=0;i<json.data.length;i++){
				defMap.put(json.data[i]["CTRLID"],json.data[i]["CTRVAL"]);
			}
			this.bindSearchAreaDefaultParam(defMap);
			
			var tmpDesc = $getVariantList.find("option[value="+param.get("PARMKY")+"]").text();
			tmpDesc = tmpDesc.substring(tmpDesc.indexOf("]")+1);
			var $saveVariantInput = jQuery("#saveVariant input");
			$saveVariantInput.eq(0).val(param.get("PARMKY"));
			$saveVariantInput.eq(1).val(tmpDesc);
		}
	},
	getSearchAreaVariant : function() {
		var param = dataBind.paramData(configData.SEARCH_AREA_ID, null, true);
		for(var prop in uiList.dateDefaultMap.map){
			if(param.containsKey(prop)){
				param.remove(prop);
			}
		}
		
		for(var prop in param.map){
			if(jQuery("#"+configData.SEARCH_AREA_ID).find("[name='"+prop+"']").attr(configData.INPUT_SAVE) == configData.INPUT_SAVE_FALSE){
				param.remove(prop);
			}
		}

		for(var prop in this.rangeMap.map){
			if(uiList.dateDefaultMap.containsKey(prop)){
				continue;
			}
			var inputObj = this.rangeMap.get(prop);
			if(!inputObj.saveAtt){
				continue;
			}
			if(inputObj.singleData.length > 0){
				var tmpData;
				var rowData;
				var tmpList = new Array();
				for(var i=0;i<inputObj.singleData.length;i++){
					rowData = inputObj.singleData[i];
					tmpData = rowData.get(configData.INPUT_RANGE_OPERATOR)
								+ configData.DATA_COL_SEPARATOR
								+ rowData.get(configData.INPUT_RANGE_SINGLE_DATA)
								+ configData.DATA_COL_SEPARATOR
								+ rowData.get(configData.INPUT_RANGE_LOGICAL);
					tmpList.push(tmpData);
				}
				param.put(prop+"_"+configData.INPUT_RANGE_TYPE_SINGLE, tmpList.join(configData.DATA_ROW_SEPARATOR));
			}
			if(inputObj.rangeData.length > 0){
				var tmpData;
				var rowData;
				var tmpList = new Array();
				for(var i=0;i<inputObj.rangeData.length;i++){
					rowData = inputObj.rangeData[i];
					tmpData = rowData.get(configData.INPUT_RANGE_OPERATOR)
								+ configData.DATA_COL_SEPARATOR
								+ rowData.get(configData.INPUT_RANGE_RANGE_FROM)
								+ configData.DATA_COL_SEPARATOR
								+ rowData.get(configData.INPUT_RANGE_RANGE_TO);
					tmpList.push(tmpData);
				}
				param.put(prop+"_"+configData.INPUT_RANGE_TYPE_RANGE, tmpList.join(configData.DATA_ROW_SEPARATOR));
			}
		}
		
		for(var prop in this.multiComboMap.map){
			var $comboObj = this.multiComboMap.get(prop);
			if($comboObj.attr(configData.INPUT_SAVE) == configData.INPUT_SAVE_FALSE){
				continue;
			}
			
			var values =  $comboObj.multipleSelect("getSelects");
			if(values && values.length > 0){
				var tmpData;
				var rowData;
				var tmpList = new Array();
				for(var i=0;i<values;i++){
					rowData = values[i];
					tmpData = "="
								+ configData.DATA_COL_SEPARATOR
								+ rowData.get(configData.INPUT_RANGE_SINGLE_DATA)
								+ configData.DATA_COL_SEPARATOR
								+ "OR";
					tmpList.push(tmpData);
				}
				param.put(prop+"_"+configData.INPUT_RANGE_TYPE_SINGLE, tmpList.join(configData.DATA_ROW_SEPARATOR));
			}
		}
		
		return param;
	},
	
	getRangeDataParam : function() {
		var param = new DataMap();

		var sqlName;
		var tmpData;
		var rowData;
		
		for(var prop in this.rangeMap.map){
			var inputObj = this.rangeMap.get(prop);
			if(this.rangeSqlNameMap.containsKey(prop)){
				sqlName = this.rangeSqlNameMap.get(prop);
			}else{
				sqlName = prop;
			}
			
			inputObj.dataCheck();
			if(inputObj.singleData.length > 0){
				var tmpList = new Array();
				for(var i=0;i<inputObj.singleData.length;i++){
					rowData = inputObj.singleData[i];
					tmpData = rowData.get(configData.INPUT_RANGE_OPERATOR)
								+ configData.DATA_COL_SEPARATOR
								+ rowData.get(configData.INPUT_RANGE_SINGLE_DATA)
								+ configData.DATA_COL_SEPARATOR
								+ rowData.get(configData.INPUT_RANGE_LOGICAL);
					tmpList.push(tmpData);
				}
				param.put(sqlName+"_"+configData.INPUT_RANGE_TYPE_SINGLE, tmpList.join(configData.DATA_ROW_SEPARATOR));
			}
			
			if(inputObj.rangeData.length > 0){
				var tmpList = new Array();
				for(var i=0;i<inputObj.rangeData.length;i++){
					rowData = inputObj.rangeData[i];
					// configData.INPUT_RANGE_OPERATOR : OPER
					tmpData = rowData.get(configData.INPUT_RANGE_OPERATOR)
								// configData.DATA_COL_SEPARATOR : ↓
								+ configData.DATA_COL_SEPARATOR
								
								// configData.INPUT_RANGE_RANGE_FROM : FROM
								+ rowData.get(configData.INPUT_RANGE_RANGE_FROM)
								
								// configData.DATA_COL_SEPARATOR : ↓
								+ configData.DATA_COL_SEPARATOR
								
								// configData.INPUT_RANGE_RANGE_TO : TO
								+ rowData.get(configData.INPUT_RANGE_RANGE_TO);
					tmpList.push(tmpData);
				}
				// configData.INPUT_RANGE_TYPE_RANGE : Range
				param.put(sqlName+"_"+configData.INPUT_RANGE_TYPE_RANGE, tmpList.join(configData.DATA_ROW_SEPARATOR));
			}
		}
		
		var $comboObj;
		var comboValues;
		for(var prop in this.multiComboMap.map){
			if(this.rangeSqlNameMap.containsKey(prop)){
				sqlName = this.rangeSqlNameMap.get(prop);
			}else{
				sqlName = prop;
			}
			$comboObj = this.multiComboMap.get(prop);
			comboValues = $comboObj.multipleSelect("getSelects");
			if(comboValues && comboValues.length > 0){
				var tmpList = new Array();
				for(var i=0;i<comboValues.length;i++){
					rowData = comboValues[i];
					tmpData = "E"
								+ configData.DATA_COL_SEPARATOR
								+ rowData
								+ configData.DATA_COL_SEPARATOR
								+ "OR";
					tmpList.push(tmpData);
				}
				param.put(sqlName+"_"+configData.INPUT_RANGE_TYPE_SINGLE, tmpList.join(configData.DATA_ROW_SEPARATOR));
			}			
		}
		
		var pgroupMap = new DataMap();
		var tmpList;
		jQuery('['+configData.INPUT_PARAM_GROUP+"]").each(function(i,findElement){
			var $tObj = jQuery(findElement);
			//var lCode = $tObj.attr(configData.LABEL_ATT).split(",");
			var groupAtt = $tObj.attr(configData.INPUT_PARAM_GROUP);
			var nameAtt = $tObj.attr("name");
			var groupList = groupAtt.split(",");
			for(var i=0;i<groupList.length;i++){
				if(pgroupMap.containsKey(groupList[i])){
					tmpList = pgroupMap.get(groupList[i]);
					tmpList.push(nameAtt);
				}else{
					tmpList = new Array();
					tmpList.push(nameAtt);
					pgroupMap.put(groupList[i], tmpList);
				}
			}			
		});
		
		if(pgroupMap.size() > 0){
			param.put(configData.INPUT_PARAM_GROUP, pgroupMap);
		}
		
		return param;
	},
	dataMultiComboBind : function(defMap) {
		for(var prop in this.multiComboMap.map){
			var singleName = prop+"_"+configData.INPUT_RANGE_TYPE_SINGLE;
			if(defMap.containsKey(singleName)){
				var $comboObj = this.multiComboMap.get(prop);
				
				var singleData = defMap.get(singleName);
				var rowList = singleData.split(configData.DATA_ROW_SEPARATOR);
				var dataList;
				for(var i=0;i<rowList.length;i++){
					dataList = rowList[i].split(configData.DATA_COL_SEPARATOR);
					$comboObj.multipleSelect("setSelects", dataList);
				}
			}
		}
	},
	dataRangeBind : function(defMap) {
		for(var prop in this.rangeMap.map){
			if(uiList.dateDefaultMap.containsKey(prop)){
				continue;
			}
			var inputObj = this.rangeMap.get(prop);
			if(!inputObj.saveAtt){
				continue;
			}
			inputObj.singleData = new Array();
			inputObj.rangeData = new Array();
			var singleName = prop+"_"+configData.INPUT_RANGE_TYPE_SINGLE;
			if(defMap.containsKey(singleName)){
				var singleData = defMap.get(singleName);
				var rowList = singleData.split(configData.DATA_ROW_SEPARATOR);
				var dataList;
				for(var i=0;i<rowList.length;i++){
					dataList = rowList[i].split(configData.DATA_COL_SEPARATOR);
					var dataMap = new DataMap();
					dataMap.put(configData.INPUT_RANGE_OPERATOR, dataList[0]);
					dataMap.put(configData.INPUT_RANGE_SINGLE_DATA, dataList[1]);
					if(dataList[2]){
						dataMap.put(configData.INPUT_RANGE_LOGICAL, dataList[2]);
					}					
					inputObj.singleData.push(dataMap);
				}
			}
			
			var rangeName =  prop+"_"+configData.INPUT_RANGE_TYPE_RANGE;
			if(defMap.containsKey(rangeName)){
				var rangeData = defMap.get(rangeName);
				var rowList = rangeData.split(configData.DATA_ROW_SEPARATOR);
				var dataList;
				for(var i=0;i<rowList.length;i++){
					dataList = rowList[i].split(configData.DATA_COL_SEPARATOR);
					var dataMap = new DataMap();
					dataMap.put(configData.INPUT_RANGE_OPERATOR, dataList[0]);
					dataMap.put(configData.INPUT_RANGE_RANGE_FROM, dataList[1]);
					dataMap.put(configData.INPUT_RANGE_RANGE_TO, dataList[2]);
					inputObj.rangeData.push(dataMap);
				}
			}			
			
			inputObj.setMultiData();
		}
	},
	removeValidation : function(inputName, valAtt, areaId) {
		if(this.rangeMap.containsKey(inputName)){
			var inputObj = this.rangeMap.get(inputName);
			inputObj.removeValidation(valAtt);
		}else{
			var $areaObj = commonUtil.getArea(areaId);
			var $inputObj = $areaObj.find("[NAME='"+inputName+"']");
			if($inputObj){
				var tmpValAtt = $inputObj.attr(configData.VALIDATION_ATT);
				if(tmpValAtt){
					var valList = tmpValAtt.split(" ");
					var valAttSplit = valAtt.split(",");
					for(var i=0;i<valList.length;i++){
						var ruleList = valList[i].split(",");
						if(ruleList[0] == valAttSplit[0]){
							valList = commonUtil.removeRow(valList, i);
							if(valList.length > 0){
								$inputObj.removeAttr(configData.VALIDATION_ATT);
							}else{
								$inputObj.attr(configData.VALIDATION_ATT, valList.join(" "));
							}
							return;
						}
					}
				}
			}
		}
	},
	addValidation : function(inputName, valAtt, areaId) {
		if(this.rangeMap.containsKey(inputName)){
			var inputObj = this.rangeMap.get(inputName);
			inputObj.addValidation(valAtt);
		}else{
			var $areaObj = commonUtil.getArea(areaId);
			var $inputObj = $areaObj.find("[NAME='"+inputName+"']");
			if($inputObj){
				var tmpValAtt = $inputObj.attr(configData.VALIDATION_ATT);
				if(tmpValAtt){
					var valList = tmpValAtt.split(" ");
					var valAttSplit = valAtt.split(",");
					for(var i=0;i<valList.length;i++){
						var ruleList = valList[i].split(",");
						if(ruleList[0] == valAttSplit[0]){
							valList[i] = valAtt;
							$inputObj.attr(configData.VALIDATION_ATT, valList.join(" "));
							return;
						}
					}
				}
				$inputObj.attr(configData.VALIDATION_ATT, valAtt);
			}
		}
	},
	checkValidation : function() {
		var checkResult = true;
		for(var prop in this.rangeMap.map){
			var inputObj = this.rangeMap.get(prop);
			checkResult = inputObj.checkValidation();
			if(!checkResult){
				break;
			}
		}
		return checkResult;
	},
	getDataCount : function(rangeName, dataType){
		var inputObj = this.rangeMap.get(rangeName);
		if(inputObj){
			return inputObj.getDataCount(dataType);
		}
		return 0;
	},
	setAutocomplete : function() {
		for(var prop in this.rangeMap.map){
			var inputObj = this.rangeMap.get(prop);
			inputObj.setAutocomplete();
		}
	},
	setRangeReadOnly : function(rangeName, readOnlyType) {
		var inputObj = this.rangeMap.get(rangeName);
		inputObj.setReadOnly(readOnlyType);
	},
	setRangeSqlName : function(rangeName, sqlName) {
		this.rangeSqlNameMap.put(rangeName, sqlName);
	},
	rangeRowClick : function(gridId, rowNum, colName) {
		
	},
	addSearchListParam : function(param, paramName, dataList) {
		var tmpList = new Array();
		for(var i=0;i<dataList.length;i++){
			var tmpData = "E"
				+ configData.DATA_COL_SEPARATOR
				+ dataList[i]
				+ configData.DATA_COL_SEPARATOR
				+ "OR";
			
			tmpList.push(tmpData);
		}
		
		if(param.containsKey(configData.INPUT_RNAGE_DATA_PARAM)){
			param.get(configData.INPUT_RNAGE_DATA_PARAM).put(paramName+"_"+configData.INPUT_RANGE_TYPE_SINGLE, tmpList.join(configData.DATA_ROW_SEPARATOR));
		}else{
			var rangeParamMap = new DataMap();
			rangeParamMap.put(paramName+"_"+configData.INPUT_RANGE_TYPE_SINGLE, tmpList.join(configData.DATA_ROW_SEPARATOR));
			param.put(configData.INPUT_RNAGE_DATA_PARAM,rangeParamMap);
		}		
	},
	toString : function() {
		return "InputList";
	}
};

var inputList = new InputList();