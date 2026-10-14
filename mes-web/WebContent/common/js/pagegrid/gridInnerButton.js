GridInnerButton = function(id){
	this.gridInnerButtonAreaId = id;	
	this.checkBoxClass = "contentCheckBox";
	this.checkBoxId = "allColSelectBox";
	this.ulClass = "contentCheckBox";
	this.liCheckBoxClass = "contentCheckBoxArea";
	this.liUserBoxClass = "contentUserBoxArea";
	this.liTextAreaClass = "contentCheckBoxTextArea";
	this.clickColorClass = "contentCheckBoxColor";
	
	this.selectBoxClass = "contentSelectBox";
	this.liSelectBoxTextClass = "contentSelectBoxTextArea";
	this.liSelectBoxClass = "contentSelectBoxSelectArea";
	this.liSelectBoxButtonClass = "contentSelectBoxButtonArea";
	
	this.gridButtonList = new Array();
	this.buttonFunctionList = new Array();
	
	this.selectAllButtonMap = new DataMap();
	
	this.userCheckMap = new DataMap();
	
	this.seachIcon = "/common/images/btn_zoom.png";
	this.downLoarIcon = "/common/images/ico_btn9.png";
	this.excuteIcon = "/common/images/btn_next.png";
	this.reflect = "/common/images/ico_btn3.png";
	this.create = "/common/images/ico_btn12.png";
	this.stop = "/common/images/ico_btn11.png";
	this.hold = "/common/images/ico_btn14.png";
	this.cancel = "/common/images/ico_btn13.png";
	this.save = "/common/images/ico_btn2.png";
}

GridInnerButton.prototype = {
	setGridInnerButton : function(option){
		this.gridInnerButtonAreaId = option.areaId;
		
		var defaults = new Object({
			areaId : this.gridInnerButtonAreaId,
			buttonId : null,
			gridId : null,
			buttonType : null,
			label : null,
			icon : null,
			select  : [],
			userFunction : function(){}
		});
		
		var $gridInnerButtonArea = $("#" + this.gridInnerButtonAreaId);
		var $gridInnerButtonAreaFirstArea = $gridInnerButtonArea.find(".table");
		
		defaults.buttonId = option.buttonId;
		defaults.buttonType = option.buttonType;
		defaults.gridId = option.gridId;
		defaults.label = option.label;
		defaults.select = option.select;
		
		var label = "";
		if(defaults.label != undefined && $.trim(defaults.label) != "" || defaults.label != null){
			label = labelObj[defaults.label].split(configData.DATA_COL_SEPARATOR)[1];
		}
		
		if(typeof option.userFunction == "function"){
			defaults.userFunction = option.userFunction; 
			this.setGridInnerButtonArray(defaults.buttonId,"function",defaults.userFunction);
		}
		
		if(option.icon == "search"){
			defaults.icon = this.seachIcon;
		}else if(option.icon == "download"){
			defaults.icon = this.downLoarIcon;
		}else if(option.icon == "excute"){
			defaults.icon = this.excuteIcon;
		}else if(option.icon == "reflect"){
			defaults.icon = this.reflect;
		}else if(option.icon == "create"){
			defaults.icon = this.create;
		}else if(option.icon == "stop"){
			defaults.icon = this.stop;
		}else if(option.icon == "hold"){
			defaults.icon = this.hold;
		}else if(option.icon == "cancel"){
			defaults.icon = this.cancel;
		}else if(option.icon == "save"){
			defaults.icon = this.save;
		}
		
		this.buttonDrawHtml(defaults.buttonId, defaults.buttonType, $gridInnerButtonAreaFirstArea, label, defaults.icon, option.icon,defaults.select);
		this.buttonClickEvent(defaults.buttonId, defaults.buttonType, defaults.gridId);
	},
	
	setGridInnerButtonArray : function(buttonId, type, obj, buttonType){
		if(type == "function"){
			var typeMap = new DataMap();
			typeMap.put(buttonId,obj);
			
			this.buttonFunctionList.push(typeMap);
			this.gridButtonList.push(this.buttonFunctionList);
		}else if(type == "button"){
			var htmlMap = new DataMap();
			var htmlMapData = new DataMap();
			htmlMapData.put(buttonId,obj);
			htmlMap.put("button", htmlMapData);
			this.gridButtonList.push(htmlMap);
		}
	},
	
	buttonDrawHtml : function(buttonId, buttonType, area, label, icon, iconType, selectArr){
		var gridInnerButton = this;
		var html;
		
		area.css("top","40px");
		
		var $ul= $("<ul></ul>").addClass(this.checkBoxClass).attr("id",buttonId);
		var $liTextArea= $("<li></li>").addClass(this.liTextAreaClass).text(label);
		var $box;
		var $liCheckboxArea;
		
		if(buttonType == "AllCheckButton"){
			$liCheckboxArea= $("<li></li>").addClass(this.liCheckBoxClass);
			$box= $("<input></input>").attr("type","checkbox");
			html = $ul.append($liCheckboxArea.append($box)).append($liTextArea);
		}else if(buttonType == "userButton"){
			$liCheckboxArea= $("<li></li>").addClass(this.liUserBoxClass);
			
			$box = $("<img></img>").attr("src",icon);
			if(iconType == "excute"){
				$box.attr("style","width: 13px;padding :2px 0 0 0;");
			}else if(iconType == "reflect"){
				$box.attr("style","width: 18px;");
			}else if(iconType == "create" || iconType == "stop" || iconType == "hold" || iconType == "cancel"){
				$box.attr("style","width: 18px;");
				$ul.css("width","118px");
				//$liCheckboxArea.attr("style","padding-top: 6px; padding-left: 8px;");
				$liTextArea.css("width","80px");
				$liTextArea.css("text-align","center");
			}else if(iconType == "save"){
				$box.attr("style","width: 20px;");
				$ul.css("width","98px");
				//$liCheckboxArea.attr("style","padding-top: 6px; padding-left: 8px;");
				$liTextArea.css("width","60px");
				$liTextArea.css("text-align","center");
			}
			html = $ul.append($liCheckboxArea.append($box)).append($liTextArea);
		}else if(buttonType == "selectButton"){
			if(selectArr.length != 2){
				return;
			}
			var $selectUl = $("<ul></ul>").addClass(this.selectBoxClass).attr("id",buttonId);
			var $selectTextLi = $("<li></li>").addClass(this.liSelectBoxTextClass).text(label + " : ");
			var $selectLi = $("<li></li>").addClass(this.liSelectBoxClass);
			var $select  = $("<select></select>").attr({"Combo":selectArr[0],"name":selectArr[1],"ComboType":"C,combo"});
			var $emptyOtion = "<option value=' ' CL='STD_SELECT'>"+uiList.getLabel("STD_SELECT")+"</option>\n";
			$select.append($emptyOtion);
			$selectLi.append($select);
			var $selectButtonLi = $("<li></li>").attr("id",buttonId+"_button").addClass(this.liSelectBoxButtonClass).text("적용");
			
			html = $selectUl.append($selectTextLi).append($selectLi).append($selectButtonLi);
		}else if(buttonType == "userCheckButton"){
			$liCheckboxArea= $("<li></li>").addClass(this.liCheckBoxClass);
			
			$ul.css("width","157px")
			$liTextArea.css("width","120px");
			$liTextArea.css("text-align","left");
			
			$box= $("<input></input>").attr("type","checkbox");
			html = $ul.append($liCheckboxArea.append($box)).append($liTextArea);
		}
		
		area.before(html);
		
		inputList.setCombo(buttonId);
		
		this.setGridInnerButtonArray(buttonId, "button", html, buttonType);
	},
	
	buttonChageColor : function($obj,bool){
		if(bool){
			$obj.addClass(gridInnerButton.clickColorClass);
		}else{
			$obj.removeClass(gridInnerButton.clickColorClass);
		}
	},
	
	buttonClickEvent : function(buttonId,buttonType,gridId){
		if(buttonType == "AllCheckButton"){
			var $thisChk = $("#" + buttonId).find("[type=checkbox]");
			$thisChk.attr("onclick","$('#" + buttonId +"').click();");
			
			gridInnerButton.selectAllButtonMap.put(gridId,"");
			
			$("#" + buttonId).off("click").on("click",function(e){
				var $checkbox = $(this).find("[type=checkbox]");
				
				var defaultLayoutData = gridList.getGridBox(gridId).defaultLayOutData;
				var invisibleLayOutData = gridList.getGridBox(gridId).invisibleLayOutData;
				var visibleLayOutData = gridList.getGridBox(gridId).visibleLayOutData;
				
				var rowSep = configData.DATA_ROW_SEPARATOR;
				var colSep = configData.DATA_COL_SEPARATOR;
				
				var visibleLayOutArr = [];
				if(visibleLayOutData != "" && visibleLayOutData != undefined && visibleLayOutData != null){
					var visibleRow = visibleLayOutData.split(rowSep);
					for(var i = 0; i < visibleRow.length; i++){
						var map = new DataMap();
						var visibleData = visibleRow[i].split(colSep);
						map.put(visibleData[0],visibleData[1]);
						
						visibleLayOutArr.push(map);
					}
				}
				
				var invisibleLayOutArr = [];
				if(invisibleLayOutData != "" && invisibleLayOutData != undefined && invisibleLayOutData != null){
					var invisibleRow = invisibleLayOutData.split(rowSep);
					for(var i = 0; i < invisibleRow.length; i++){
						var map = new DataMap();
						var invisibleData = invisibleRow[i].split(colSep);
						map.put(invisibleData[0],invisibleData[1]);
						
						invisibleLayOutArr.push(map);
					}
				}
				
				
				var defaultLayoutText = "";
				if(defaultLayoutData != "" && defaultLayoutData != undefined && defaultLayoutData != null){
					var defaultLayoutRow = defaultLayoutData.split(rowSep);
					for(var i = 0; i < defaultLayoutRow.length; i++){
						var defaultData = defaultLayoutRow[i].split(colSep);
						
						var col = defaultData[0];
						var size = defaultData[1];
						var colName = defaultData[2];
						
						if(visibleLayOutArr.length > 0){
							for(var j = 0; j < visibleLayOutArr.length; j++){
								var data = visibleLayOutArr[j];
								if(data.containsKey(col)){
									size = data.get(col);
								}
							}
						}
						
						if(invisibleLayOutArr.length > 0){
							for(var j = 0; j < invisibleLayOutArr.length; j++){
								var data = invisibleLayOutArr[j];
								if(data.containsKey(col)){
									size = data.get(col);
								}
							}
						}
						
						if(i == 0){
							defaultLayoutText += col + colSep + size + colSep + colName;
						}else{
							defaultLayoutText += rowSep + col + colSep + size + colSep + colName;
						}
					}
				}
				
				if($checkbox.is(":checked")){
					$checkbox.prop("checked",false);
					gridInnerButton.buttonChageColor($("#" + buttonId),false);
					
					commonUtil.displayLoading(true);
					
					setTimeout(function() { 
						try {
							var txt = "";
							
							var param = new DataMap();
							param.put("MENUID",configData.MENU_ID);
							param.put("GRIDID",gridId);
							
							var json = netUtil.sendData({
								module : "System",
								command : "USRLO_LAYDAT",
								sendType : "map",
								param : param
							});
							if(json && json.data){
								var defaultLayoutTextArr = [];
								var defaultLayoutTextRow = defaultLayoutText.split(rowSep);
								for(var i = 0; i < defaultLayoutTextRow.length; i++){
									var map = new DataMap();
									var defaultData = defaultLayoutTextRow[i].split(colSep);
									
									var col = defaultData[0];
									var colName = defaultData[2];
									
									map.put(col,colName);
									
									defaultLayoutTextArr.push(map);
								}
								
								var layoutDataText = "";
								
								var layoutData = json.data["LAYDAT"];
								var layoutDataRow = layoutData.split(rowSep);
								for(var i = 0; i < layoutDataRow.length; i++){
									var defaultData = layoutDataRow[i].split(colSep);
									
									var col = defaultData[0];
									var size = defaultData[1];
									var colName = "";
									
									if(defaultLayoutTextArr.length > 0){
										for(var j = 0; j < defaultLayoutTextArr.length; j++){
											var data = defaultLayoutTextArr[j];
											if(data.containsKey(col)){
												colName = data.get(col);
											}
										}
									}
									
									if(i == 0){
										layoutDataText += col + colSep + size + colSep + colName;
									}else{
										layoutDataText += rowSep + col + colSep + size + colSep + colName;
									}
								}
								
								txt = layoutDataText;
							}else{
								txt = defaultLayoutText;
							} 
							
							gridList.getGridBox(gridId).visibleLayOutData = txt;
							gridList.getGridBox(gridId).setLayout(true);
							
							gridList.setBtnActive(gridId, "layout", true);
							
							commonUtil.displayLoading(false);
						} catch (e) {
							commonUtil.displayLoading(false);
							commonUtil.msg(e);
						}
					},200);
				}else{
					$checkbox.prop("checked",true);
					gridInnerButton.buttonChageColor($("#" + buttonId),true);
					
					commonUtil.displayLoading(true);
					
					setTimeout(function() { 
						try {
							gridList.getGridBox(gridId).visibleLayOutData = defaultLayoutText;
							gridList.getGridBox(gridId).setLayout(true);
							
							gridList.setBtnActive(gridId, "layout", false);
							
							commonUtil.displayLoading(false);
						} catch (e) {
							commonUtil.displayLoading(false);
							commonUtil.msg(e);
						}
					},200);
				}
			});
		}else if(buttonType == "userButton"){
			var functionList = gridInnerButton.buttonFunctionList; 
			if(functionList.length > 0){
				for(var i = 0; i < functionList.length; i++){
					var functionMap = functionList[i];
					var fnc =functionMap.get(buttonId);
					$("#" + buttonId).off("click").on("click",function(e){
						gridInnerButton.buttonChageColor($("#" + buttonId),true);
						
						setTimeout(function(){
							gridInnerButton.buttonChageColor($("#" + buttonId),false);
						}, 100);
						
						setTimeout(function() {
							if(typeof fnc == "function"){
								fnc();
							}
						},150);
					});
				}
			}
		}else if(buttonType == "selectButton"){
			var functionList = gridInnerButton.buttonFunctionList; 
			if(functionList.length > 0){
				for(var i = 0; i < functionList.length; i++){
					var functionMap = functionList[i];
					var fnc =functionMap.get(buttonId);
					$("#" + buttonId + "_button").off("click").on("click",function(e){
						gridInnerButton.buttonChageColor($("#" + buttonId + "_button"),true);
						
						setTimeout(function(){
							gridInnerButton.buttonChageColor($("#" + buttonId + "_button"),false);
						}, 100);
						
						setTimeout(function() {
							if(typeof fnc == "function"){
								fnc();
							}
						},150);
					});
				}
			}
		}else if(buttonType == "userCheckButton"){
			var $thisChk = $("#" + buttonId).find("[type=checkbox]");
			$thisChk.attr("onclick","$('#" + buttonId +"').click();");
			
			$("#" + buttonId).off("click").on("click",function(e){
				var $checkbox = $(this).find("[type=checkbox]");
				
				if($checkbox.is(":checked")){
					$checkbox.prop("checked",false);
					gridInnerButton.buttonChageColor($("#" + buttonId),false);
					gridInnerButton.userCheckMap.put(buttonId,false);
					
					setTimeout(function(){
						var functionList = gridInnerButton.buttonFunctionList; 
						if(functionList.length > 0){
							for(var i = 0; i < functionList.length; i++){
								var functionMap = functionList[i];
								var fnc =functionMap.get(buttonId);
								if(typeof fnc == "function"){
									fnc();
								}
							}
						}	
					});
				}else{
					$checkbox.prop("checked",true);
					gridInnerButton.buttonChageColor($("#" + buttonId),true);
					gridInnerButton.userCheckMap.put(buttonId,true);
					
					setTimeout(function(){
						setTimeout(function(){
							var functionList = gridInnerButton.buttonFunctionList; 
							if(functionList.length > 0){
								for(var i = 0; i < functionList.length; i++){
									var functionMap = functionList[i];
									var fnc =functionMap.get(buttonId);
									if(typeof fnc == "function"){
										fnc();
									}
								}
							}	
						});
					});
				}
			});
		}
	}
}

var gridInnerButton = new GridInnerButton();