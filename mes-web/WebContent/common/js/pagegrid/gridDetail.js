GridDetail = function(){
	this.gridId = null;
	this.gridReflectId = null;
	this.gridDetailId = "detail_";
	this.gridReflectType = "reflect_";
	this.gridReflushType = "reflush_";
	this.layoutClass = "gridDetailLayer";
	this.headerClass = "gridDetailLayer-header";
	this.reflectClass = "gridDetailLayer-reflect";
	this.detailClass = "gridDetailLayer-detail";
	this.headerTextAreaClass = "gridDetailLayer-header-textarea";
	this.headerButtonAreaClass = "gridDetailLayer-header-buttonarea";
	this.detailRowTable = "gridDetailLayer-detail-table";
	this.detailRowClass = "gridDetailLayer-detail-row";
	this.detailThClass = "gridDetailLayer-detail-cell-th";
	this.detailTdClass = "gridDetailLayer-detail-cell";
	
	this.gridDetailMap = new DataMap();
	
	this.gridListCount = 0;
	this.upCount = 0;
	this.queCount = 10;
	this.queUpCount = 0;
	this.queMaxCount = 0;
	
	this.itv1 = null;
	this.itv2 = null;
	
	this.resize = 0;
	this.reflectWidth = 0;
	this.reflectHeight = 0;
	
	this.detailHeight = 0;
	this.detailHeight = 0;
	
	this.selectBoxReloadList = new Array();
}

GridDetail.prototype = {
	setGridDetail : function(option){
		this.gridId = option.gridId;
		
		if(this.gridId == null || this.gridId == undefined || $.trim(this.gridId) == ""){
			commonUtil.msg("'Grid Id' does not exist in parameter.");
			return;
		}
		
		var defaults = new Object({
			move : true,
			holder : false,
			reflect : false,
			gridReflect : false,
			table : []
		});
		
		var optionMap = new DataMap(option);
		optionMap.remove("gridId");
		this.gridDetailsettingValidation(defaults,optionMap);
		this.gridDetailMap.put(this.gridId,optionMap);
		
		this.drawGridDetailLayout(this.gridId);
	},
	
	setGridReflect : function(option){
		this.gridReflectId = this.gridReflectType + option.gridId;
		this.gridId = option.gridId;
		
		if(this.gridId == null || this.gridId == undefined || $.trim(this.gridId) == ""){
			commonUtil.msg("'Grid Id' does not exist in parameter.");
			return;
		}
		
		var defaults = new Object({
			move : true,
			holder : false,
			reflect : true,
			gridReflect : true,
			table : []
		});
		
		option["reflect"] = defaults.reflect;
		
		var optionMap = new DataMap(option);
		this.gridDetailMap.put(this.gridReflectId,optionMap);
		this.drawGridReflectLayout(this.gridReflectId,option.gridId);
	},
	
	gridDetailsettingValidation : function(defaults,option){
		var isTableKey = false;
		
		var keys = Object.keys(defaults);
		for(var i = 0; i < keys.length; i++){
			var key = keys[i];
			if(option.containsKey(key)){
				var value = option.get(key);
				if(key != "table"){
					if(typeof value != "boolean"){
						commonUtil.msg("'"+ key + "' does not Boolean Type : [true / false]");
						return;
					}
				}else if(key == "table"){
					isTableKey = true;
					if(value.constructor != Array){
						commonUtil.msg("'"+ key + "' does not Array Type");
						return;
					}
				}
			}
		}
		
		if(!isTableKey)
			commonUtil.msg("'table' does not exist in parameter.");
			return;
	},
	
	drawGridReflectLayout : function(uiId,gridId){
		this.drawGridDetailLayout(uiId,gridId);
		
		var layoutId = uiId;
		
		var $html = this.gridDetailMap.get(layoutId).get("template").clone();
		$html.attr({"id":layoutId});
		
		//$html.find(".reflectBox").attr({"id":layoutId+"_button"});
		//$html.find(".reflushBox").attr({"id":this.gridReflushType + layoutId.replace(this.gridReflectType,"") +"_button"});
		
		var $contentBody = $("#"+gridId).parents(".content");
		$contentBody.after($html);
		
		uiList.UICheck($("#"+layoutId));
		inputList.setCombo(layoutId);
		inputList.setInput(layoutId);
		
		this.gridDetailClickEvent(layoutId);
		
		this.initRelectData(layoutId);
		
		gridDetail.resize = $("body").width();
		gridDetail.reflectWidth = $("#"+layoutId).width();
		gridDetail.reflectHeight = $("#"+layoutId).height();
	},
	
	drawGridDetailLayout : function(gridId,reflctGridId){
		var isReflect = false;
		var displayType = "block";
		if(reflctGridId != undefined){
			isReflect = true;
			displayType = "none";
		}
		
		var rowCnt = this.gridDetailMap.get(gridId).get("table").length;
		var rowDataCnt = 0;
		for(var i = 0; i < rowCnt; i++){
			rowDataCnt = this.gridDetailMap.get(gridId).get("table")[i].length;
		}
		var wapperWidth = $("body").width()/2;
		var wapperHeight = (rowDataCnt*30) + 43;
		
		var maxWidth = $("body").width() - 3;
		var maxHeight = $("body").height() - 3;
		
		var $wapperDiv = $("<div></div>").attr({"class": this.layoutClass,"style":"display:"+displayType+";max-width:" + (maxWidth - 3) +"px;max-height:" + (maxHeight - 3) + "px;"});/*"max-width:" + maxWidth +"px;max-height:" + maxHeight + "px;"*/
		if(!isReflect){
			$wapperDiv.addClass("gridDetailBox");
		}
		
		var $headDiv = $("<div></div>").attr({"class": this.headerClass});
		var $reflectDiv = $("<div></div>").attr({"class": this.reflectClass});
		
//		var $ul= $("<ul></ul>").addClass("reflectBox");
//		
//		var $liTextArea= $("<li></li>").addClass("textArea").text(labelObj["STD_COMMIT"].split(configData.DATA_COL_SEPARATOR)[1]);
//		var $liCheckboxArea= $("<li></li>").addClass("boxArea");
//		var $box= $("<img></img>").attr("src","/common/images/ico_btn3.png");
//		$ul.append($liCheckboxArea.append($box)).append($liTextArea);
//		$reflectDiv.append($ul);
		
		var $button = $("<button>").addClass("reflectBox btn_reflect").attr({"id":gridId+"_button"});;
		var $buttonTxt = $("<p>").text(labelObj["STD_COMMIT"].split(configData.DATA_COL_SEPARATOR)[1]);
		var $buttonImg = $("<div>").css("background", "url('/common/images/ico_btn3.png') no-repeat center center");
		
		$button.append($buttonImg);
		$button.append($buttonTxt);
		$reflectDiv.append($button);
		
		if(isReflect){
			var $resetButton = $("<button>").addClass("reflushBox btn_reflect").attr({"id":this.gridReflushType + gridId.replace(this.gridReflectType,"") +"_button"});
			var $resetButtonTxt = $("<p>").text(labelObj["STD_REFLUSH"].split(configData.DATA_COL_SEPARATOR)[1]);
			var $resetButtonImg = $("<div>").css("background", "url('/common/images/ico_left3.png') no-repeat center center");
			
			$resetButton.append($resetButtonImg);
			$resetButton.append($resetButtonTxt);
			$reflectDiv.append($resetButton);
			
//			var $reflushUl= $("<ul></ul>").addClass("reflushBox");
//			var $liRefulshTextArea= $("<li></li>").attr("style","padding-left: 11px;").addClass("textArea").text(labelObj["STD_REFLUSH"].split(configData.DATA_COL_SEPARATOR)[1]);
//			var $liRefulshCheckboxArea= $("<li></li>").addClass("boxArea");
//			var $reflushBox= $("<img></img>").attr("src","/common/images/ico_left3.png");
//			$reflushBox.attr("style","width: 15px;");
//			$reflushUl.append($liRefulshCheckboxArea.append($reflushBox)).append($liRefulshTextArea);
//			$reflectDiv.append($reflushUl);
		}
		
		var $detailDiv = $("<div></div>").attr({"class": this.detailClass,"style":"max-width:" + maxWidth +"px;max-height:" + (maxHeight - 83) + "px;"});
		var $headDivTextArea = $("<div></div>").attr({"class": this.headerTextAreaClass});
		var $headDivButtonArea = $("<div></div>").attr({"class": this.headerButtonAreaClass});
		
		var title = this.gridDetailMap.get(gridId).get("title");
		var titleLabel = "";
		if(title != undefined && title != null && $.trim(title) != ""){
			titleLabel = labelObj[title] == undefined?"":labelObj[title].split(configData.DATA_COL_SEPARATOR)[1];
		}
		
		if(isReflect && titleLabel == ""){
			titleLabel = labelObj["STD_ALLREF"] == undefined?"":labelObj["STD_ALLREF"].split(configData.DATA_COL_SEPARATOR)[1];
		}
		
		$headDivTextArea.append("<p>"+titleLabel+"</p>");
		$headDivButtonArea.append("<p>X</p>");
		
		$headDiv.append($headDivTextArea);
		$headDiv.append($headDivButtonArea);
		
		var table = gridDetail.gridDetailMap.get(gridId).get("table");
		
		for(var i = 0; i < table.length; i++){
			var tableData = table[i];
			if(tableData.length > 0){
				var $table;
				if(isReflect){
					$table = this.drawGridDetailLayoutBottomArea(reflctGridId,table[i],i,true);
				}else{
					$table = this.drawGridDetailLayoutBottomArea(gridId,table[i],i,false);
				}
				
				$detailDiv.append($table);
				$wapperDiv.append($headDiv);
				if(this.gridDetailMap.get(gridId).get("reflect")){
					$wapperDiv.append($reflectDiv);
				}
				$wapperDiv.append($detailDiv);
			}
		}

		this.gridDetailMap.get(gridId).put("template",$wapperDiv);
	},
	
	drawGridDetailLayoutBottomArea : function(gridId,gridListTable,tableCount,isReflect){
		var gridColMap = gridList.getGridBox(gridId).colTextMap;
		
		var $table = $("<table>").attr({"class":this.detailRowTable});
		if(tableCount > 0){
			$table.addClass("gridDetailLayerAppendTable");
		}
		
		$table.append("<tbody>");
		
		if(gridListTable.length > 0){
			for(var i = 0; i < gridListTable.length; i++){
				var $tr = $("<tr>");
				var row = gridListTable[i];
				if(row.constructor === Array){
					if(row.length > 0){
						for(var j = 0; j < row.length; j++){
							var rowItem = row[j];
							var colName = rowItem.name;
							var colText = gridColMap.get(colName);
							var colSpan = rowItem.colSpan===undefined?"":rowItem.colSpan;
							var type = rowItem.type;
							var selectOption = rowItem.selectOption;
							var reloadCombo = rowItem.reloadCombo===undefined?false:rowItem.reloadCombo;
							
							var $th = $("<th>");
							if(isReflect && (colName != "" && colName != undefined && colName != null)){
								var $checkboxArea = $("<p>").addClass("checkboxArea");
								var $checkbox = $("<input>").attr({"type":"checkbox","id":"chk_"+colName,"name":"chk_"+colName,"value":"V"});
								$checkboxArea.append($checkbox);
								var $thTextArea = $("<p>").addClass("thTextArea");
								var $thTextLabel = $("<label>").attr({"for":"chk_"+colName}).html(colText === undefined?"":colText);
								$thTextArea.append($thTextLabel);
								
								$th.append($checkboxArea);
								$th.append($thTextArea);
							}else{
								$th.html(colText === undefined?"":colText);
							}
							
							if(type != undefined){
								var height = type.height;
								var typename = type.name;
								if(typename == "textarea" && height > 0){
									$th.attr("style","height :" + height + "px;");
								}
							}
							
							$tr.append($th);
							
							var $td = this.drawGridDetailInput(gridId,colName,colSpan,type,isReflect,selectOption,reloadCombo);
							$tr.append($td);
						}
					}
				}else{
					var colName = row.name;
					var colText = gridColMap.get(colName);
					var colSpan = row.colSpan===undefined?"":row.colSpan;
					var type = row.type;
					var selectOption = row.selectOption;
					var reloadCombo = row.reloadCombo===undefined?false:row.reloadCombo;
					
					var $th = $("<th>");
					if(isReflect && ($.trim(colName) != "" && colName != undefined && colName != null)){
						var $checkboxArea = $("<p>").addClass("checkboxArea");
						var $checkbox = $("<input>").attr({"type":"checkbox","id":"chk_"+colName,"name":"chk_"+colName,"value":"V"});
						$checkboxArea.append($checkbox);
						var $thTextArea = $("<p>").addClass("thTextArea");
						var $thTextLabel = $("<label>").attr({"for":"chk_"+colName}).html(colText === undefined?"":colText);
						$thTextArea.append($thTextLabel);
						
						$th.append($checkboxArea);
						$th.append($thTextArea);
					}else{
						$th.html(colText === undefined?"":colText);
					}
					
					if(type != undefined){
						var height = type.height;
						var typename = type.name;
						if(typename == "textarea" && height > 0){
							$th.attr("style","height :" + height + "px;");
						}
					}
					
					$tr.append($th);
					
					var $td = this.drawGridDetailInput(gridId,colName,colSpan,type,isReflect,selectOption,reloadCombo);
					$tr.append($td);
				}
				
				$table.append($tr);
			}
		}
		
		return $table;
	},
	
	drawGridDetailInput : function(gridId,colName,colSpan,type,isReflect,selectOption,reloadCombo){
		var gridColFormatMap = gridList.getGridBox(gridId).colFormatMap;
		var gridColTypeMap = gridList.getGridBox(gridId).colTypeMap; 
		var gridComboDataMap = gridList.getGridBox(gridId).comboDataMap; 
		var gridComboList = gridList.getGridBox(gridId).comboList; 
		var readOnlyColList = gridList.getGridBox(gridId).readOnlyColList; 
		var validationMap = gridList.getGridBox(gridId).validationMap; 
		
		var colType = gridColTypeMap.get(colName);
		var colTypeLen = 0;
		if(colType != undefined){
			colTypeLen = colType.split(",").length;
			colType = colType.split(",")[0];
		}
		
		var colFormatText = "";
		var colFormatData = gridColFormatMap.get(colName);
		if(colFormatData != undefined){
			var colFormatDataLen = colFormatData.length;
			if(colFormatDataLen > 0){
				if(colFormatDataLen == 1){
					colFormatText = colFormatData[0];
				}else if(colFormatDataLen > 1){
					colFormatText = colFormatData[0] + " " + colFormatData[1];
				}
			}
		}
		
		var readOnlyColType = false;
		if(readOnlyColList != undefined){
			var readOnlyColListLen = readOnlyColList.length;
			if(readOnlyColListLen > 0){
				for(var i = 0; i < readOnlyColListLen; i++){
					var readOnlyCol = readOnlyColList[i];
					if(readOnlyCol == colName){
						readOnlyColType = true;
					}
				}
			}
		}
		
		var validationType = false;
		if(validationMap != undefined){
			var validation = validationMap.get(colName);
			if(validation != undefined){
				if(validation.indexOf(configData.VALIDATION_REQUIRED) > -1){
					validationType = true;
				}
			}
		}
		
		var $td = $("<td>");
		if(colSpan != ""){
			$td.attr("colSpan",colSpan);
		}
		
		var $input;
		if(colType == "text"){
			$input = $("<input>").attr({"type":"text","name":colName,"autocomplete":"off","UIformat":colFormatText,"disabled":true});
			if(colFormatText === ""){
				$input.removeAttr(configData.INPUT_FORMAT)
			}
			
			if(type != undefined){
				var height = type.height;
				var typename = type.name;
				if(typename == "textarea" && height > 0){
					$td.attr("style","height :" + height + "px;");
					$input = $("<textarea>").attr({"name":colName,"disabled":true}); 
				}
			}
			
			$td.append($input);
		}else if(colType == "input"){
			$input = $("<input>").attr({"type":"text","name":colName,"autocomplete":"off","UIformat":colFormatText});
			if(colFormatText === ""){
				$input.removeAttr(configData.INPUT_FORMAT);
			}else if(colFormatText == configData.INPUT_FORMAT_CALENDER){
				$input.css("width", "85%");
			}
			
			var searchId = "";
			if(colTypeLen >= 3){
				searchId = gridColTypeMap.get(colName).split(",")[2];
				$input.attr({"UIInput":"S," + searchId});
//				$input.css("width", "70%"); // 2019.09.18 이민혜   css틀어짐에 따라 지정 안함.
			}
			
			if(readOnlyColType){
				$input.attr("disabled",true);
			}else{
				if(validationType){
					$td.addClass("gridDetailLayerInputRequired");
				}else{
					$td.addClass("gridDetailLayerInput");
				}
			}
			
			$td.append($input);
		}else if(colType == "select"){
			var comboName = "";
			var comboType = "";
			var comboUiOption = "";
			
			var gridComboListLen = gridComboList.length;
			if(gridComboListLen > 0){
				for(var k = 0; k < gridComboListLen; k++){
					var selectRow = gridComboList[k];
					if(selectRow.get(configData.GRID_COL_NAME) == colName){
						comboName = selectRow.get(configData.GRID_COL_NAME);
						comboType = selectRow.get(configData.INPUT_COMBO_TYPE);
						comboUiOption = selectRow.get(configData.INPUT_COMBO_OPTION);
						break;
					}
				}
			}
			
			var $select; 
			switch (comboType) {
			case configData.INPUT_COMMON_COMBO:
				$select = $("<select>").attr({"CommonCombo":comboUiOption, "name":comboName, "style":"width: 100%;"});
				break;
			case configData.INPUT_REASON_COMBO:
				$select = $("<select>").attr({"ReasonCombo":comboUiOption, "name":comboName, "style":"width: 100%;"});						
				break;
			case configData.INPUT_COMBO:
				$select = $("<select>").attr({"Combo":comboUiOption, "name":comboName, "style":"width: 100%;"});
				if(reloadCombo){	
					var reloadComboArr = gridDetail.selectBoxReloadList;
					if(reloadComboArr.indexOf(comboName) == -1){
						var arr = [comboName,comboUiOption];
						gridDetail.selectBoxReloadList.push(arr);
					}
				}
				break;	
			default:
				$select = "";
				break;
			}
			if($select != undefined || $select != ""){
				var option = gridComboDataMap.get(comboName);
				var keys = option.keys();
				var keyLen = keys.length; 
				
				var $option;
				var $emptyOtion;
				
				for(var i = 0; i < keyLen; i++){
					var key = keys[i];
					var val = option.get(key);
					if($.trim(val) == ""){
						if(selectOption){
							$emptyOtion = "<option value='"+key+"' CL='STD_SELECT'>" + val +"</option>\n";
						}else{
							$emptyOtion = "<option value='"+key+"'>" + val +"</option>\n";
						}
					}else{
						if(selectOption){
							$emptyOtion = "<option value=' ' CL='STD_SELECT'>" + val +"</option>\n";
						}
					}
				}
				
				if(isReflect){
					var label = labelObj["STD_SELECT"].split(configData.DATA_COL_SEPARATOR)[1];
					$emptyOtion = "<option value=''>"+label+"</option>\n";
				}
				
				$select.append($emptyOtion);
			}
			
			if(readOnlyColType){
				$select.attr("disabled",true);
				$select.addClass("gridDetailLayerSelectDisplayNone");
			}else{
				if(validationType){
					$td.addClass("gridDetailLayerInputRequired");
				}else{
					$td.addClass("gridDetailLayerInput");
				}
			}
			
			$td.append($select);
		}else if(colType == "check"){
			$input = $("<input>").attr({"type":"checkbox","name":colName,"value":"V"});
			if(readOnlyColType){
				$input.attr("disabled",true);
			}else{
				if(validationType){
					$td.addClass("gridDetailLayerInputRequired");
				}else{
					$td.addClass("gridDetailLayerInput");
				}
			}
			$td.append($input);
		}
		
		return $td;
	},
	
	gridDetailResize : function(layoutId){
		var defaultBodyWidth = gridDetail.resize;
		var bodyWidth = $("body").width();
		var bodyHeight = $("body").height();
		
		var resizeType = "";
		if(gridDetail.resize > bodyWidth){
			resizeType = "UP";
		}else{
			resizeType = "DOWN";
		}
		var display = $("#"+layoutId).css("display");
		if(layoutId.indexOf(gridDetail.gridReflectType) > -1){
			var layerWidth = gridDetail.reflectWidth;
			var layerHeight = gridDetail.reflectHeight;
			var changeWidth = layerWidth;
			
			if(bodyWidth < layerWidth){
				changeWidth = bodyWidth - 30;
				
				var marginLeft = (bodyWidth - changeWidth) - 15;
				var marginTop = (bodyHeight - layerHeight)/3;
				
				$("#"+layoutId).attr("style","display: "+ display +";max-width:" + changeWidth +"px;max-height:" + (layerHeight + 30) + "px;margin-left: " 
						+ marginLeft + "px;margin-top: " + marginTop +"px;");
			}else{
				var marginLeft = (bodyWidth - layerWidth)/2;
				var marginTop = (bodyHeight - layerHeight)/3;
				
				$("#"+layoutId).attr("style","display: "+ display +";max-width:" + (layerWidth + 10) +"px;max-height:" + (layerHeight + 34) + "px;margin-left: " 
						+ marginLeft + "px;margin-top: " + marginTop +"px;");
				
				$("#"+layoutId + " .gridDetailLayer-detail").attr("style","max-width:" + (layerWidth + 10) + "px;max-height:" + (layerHeight + 34) + "px;");
			}
		}else{
			var layerWidth = gridDetail.detailWidth;
			var layerHeight = gridDetail.detailHeight;
			
			var changeWidth = layerWidth;
			var changeHeight = layerHeight;
			
			var marginLeft = (bodyWidth - layerWidth)/2;
			var marginTop = (bodyHeight - layerHeight)/3;
			
			if(bodyWidth < layerWidth){
				changeWidth = bodyWidth - 30;
				marginLeft = (bodyWidth - changeWidth)/2;
			}else{
				changeWidth = layerWidth;
				marginLeft = (bodyWidth - layerWidth)/2;
			}
			
			if(bodyHeight < layerHeight){
				changeHeight  = (bodyHeight - 30);
				marginTop = (bodyHeight - changeHeight) - 76;
			}else{
				changeHeight = layerHeight;
				marginTop = (bodyHeight - layerHeight)/3;
			}
			
			$("#"+layoutId).attr("style","max-width:" + (changeWidth + 30) +"px;max-height:" + (changeHeight + 30) + "px;margin-left: " 
					+ marginLeft + "px;margin-top: " + marginTop +"px;");
			
			// 2019.09.18 이민혜   css틀어짐에 따라 height 값만 지정
//			$("#"+layoutId + " .gridDetailLayer-detail").attr("style","max-width:" + changeWidth + "px;max-height:" + (changeHeight - 80) + "px;");
			$("#"+layoutId + " .gridDetailLayer-detail").attr("style","height:" + (changeHeight - 80) + "px;");
		}
	},
	
	gridDetailClickEvent : function(layoutId){
		$(window).resize(function(e){
			gridDetail.gridDetailResize(layoutId);
		});
		
		if(layoutId.indexOf(gridDetail.gridReflectType) > -1){
			$("#" + layoutId).draggable();
		}else{
			var gridId = gridDetail.getGridMap(layoutId).get("gridId");
			var isMove = gridDetail.gridDetailMap.get(gridId).get("move");
			if(isMove){
				$("#" + layoutId).draggable();
			}
		}
		
		//reflectBoxHover reflect_gridList_button reflush_gridList_button
		$("#" + layoutId + " #reflect_gridList_button").on("mouseenter",function(){
			$(this).addClass("reflectBoxHover");
		});
		$("#" + layoutId + " #reflect_gridList_button").on("mouseleave",function(){
			$(this).removeClass("reflectBoxHover");
		});
		$("#" + layoutId + " #reflush_gridList_button").on("mouseenter",function(){
			$(this).addClass("reflectBoxHover");
		});
		$("#" + layoutId + " #reflush_gridList_button").on("mouseleave",function(){
			$(this).removeClass("reflectBoxHover");
		});
		
		$("#" + layoutId + " ." + this.headerButtonAreaClass).on("click",function(){
			gridDetail.removeGridDetail(layoutId);
		});
		
		$("#" + layoutId + " tbody tr td input").on("focusin",function(){
			$(this).parent().addClass("gridDetailLayerInputFocusIn");
		});
		
		$("#" + layoutId + " tbody tr td input").on("focusout",function(){
            $(this).parent().removeClass("gridDetailLayerInputFocusIn");
            if(layoutId.indexOf(gridDetail.gridReflectType) > -1){
            	var $input = $("#"+layoutId).find("input");
            	$input.each(function(){
            		var key = $(this).attr("name");
            		var value = $.trim($(this).val());
            		
            		if($(this).hasClass("inputNumber")){
            			if(value > 0 && (value != undefined && value != "" && value != null)){
            				$("#"+layoutId + " #chk_" + key).prop("checked",true);
            			}
            		}else{
            			if(value != undefined && value != "" && value != null){
            				$("#"+layoutId + " #chk_" + key).prop("checked",true);
            			}
            		}
            	});
            }
        });
		
		
		if($("#" + layoutId + " tbody tr td input[type='checkbox']").is(":checked")){
			
		}
		
		$("#" + layoutId + " tbody tr td select").on("focusin",function(){
			$(this).parent().addClass("gridDetailLayerInputFocusIn");
		});
		
		$("#" + layoutId + " tbody tr td select").on("focusout",function(){
            $(this).parent().removeClass("gridDetailLayerInputFocusIn");
            if(layoutId.indexOf(gridDetail.gridReflectType) > -1){
            	var $select = $("#"+layoutId).find("select");
            	$select.each(function(){
            		var key = $(this).attr("name");
            		var value = $.trim($(this).val());
        			if(value != undefined && value != "" && value != null){
        				$("#"+layoutId + " #chk_" + key).prop("checked",true);
        			}
            	});
            }
        });
		
		$("#" + layoutId + " tbody tr td input[type=text]").on("focus",function(){
		    var value = $(this).val().replace(" ","");
		    $(this).val(value);
			$(this).select();
		});
		
		$("#" + gridDetail.gridReflushType + layoutId.replace(gridDetail.gridReflectType,"") +"_button").off("click").on("click",function(e){
			$("#" + gridDetail.gridReflushType + layoutId.replace(gridDetail.gridReflectType,"") +"_button").addClass("reflectBoxColor");
			$("#" + gridDetail.gridReflushType + layoutId.replace(gridDetail.gridReflectType,"") +"_button .boxArea").addClass("reflectBoxBgColor");
			
			setTimeout(function(){
				$("#" + gridDetail.gridReflushType + layoutId.replace(gridDetail.gridReflectType,"") +"_button").removeClass("reflectBoxColor");
				$("#" + gridDetail.gridReflushType + layoutId.replace(gridDetail.gridReflectType,"") +"_button .boxArea").removeClass("reflectBoxBgColor");
			}, 100);
			
			setTimeout(function(){
				gridDetail.initRelectData(layoutId);
			},150);
		});
		
		$("#" + layoutId+"_button").on("mouseenter",function(){
			$(this).addClass("reflectBoxHover");
		});
		$("#" + layoutId+"_button").on("mouseleave",function(){
			$(this).removeClass("reflectBoxHover");
		});
		
		$("#" + layoutId+"_button").off("click").on("click",function(e){
			$("#" + layoutId + " tbody tr td select").focusout();
			$("#" + layoutId + " tbody tr td input").focusout();
			
			$("#" + layoutId+"_button").addClass("reflectBoxColor");
			$("#" + layoutId+"_button .boxArea").addClass("reflectBoxBgColor");
			
			setTimeout(function(){
				$("#" + layoutId+"_button").removeClass("reflectBoxColor");
				$("#" + layoutId+"_button .boxArea").removeClass("reflectBoxBgColor");
			}, 100);
			
			setTimeout(function(){
				if(layoutId.indexOf(gridDetail.gridReflectType) > -1){
					var gridId = gridDetail.getReflectGridId(layoutId,gridDetail.gridReflectType);

					var data = gridDetail.getGridReflctData(gridId);
					
					if(data.isEmpty()){
						var msg = commonUtil.getMsg("VALID_M0014");
						
						var $msgBox = $("<div>").addClass("progressComplete");
						var $msgBoxText = $("<p>").addClass("failText").text(msg);
						$msgBox.append($msgBoxText);
						
						$("#"+layoutId+" .gridDetailLayer-reflect").append($msgBox);
						
						setTimeout(function(){
							$(".progressComplete").fadeOut("fast","linear",function(){
								$(".progressComplete").remove();
							});
						},2000);
						
						return;
					}
					
					if(!gridDetail.checkReflectValidation(gridId, layoutId, data)){
						return;
					}
					
					var list = gridList.getSelectRowNumList(gridId, true);
					var listCount = list.length;
					
					if(listCount == 0){
						var msg = commonUtil.getMsg("VALID_M0006");
						
						var $msgBox = $("<div>").addClass("progressComplete");
						var $msgBoxText = $("<p>").addClass("failText").text(msg);
						$msgBox.append($msgBoxText);
						
						$("#"+layoutId+" .gridDetailLayer-reflect").append($msgBox);
						
						setTimeout(function(){
							$(".progressComplete").fadeOut("fast","linear",function(){
								$(".progressComplete").remove();
							});
						},2000);
						
						return;
					}
					
					gridDetail.validateReflectData(layoutId);
					
					gridDetail.gridListCount = listCount;
					if(listCount > 0){
						$("#reflectLoading").show();
						$(".gridDetailLayer-reflect button").hide();
						$("#"+layoutId+" .gridDetailLayer-header-buttonarea").hide();
						$(".gridDetailLayer-detail").find("input,select").attr("disabled",true);
						
						gridDetail.showProgressBar(gridId);
						gridDetail.queMaxCount = Math.ceil(listCount/gridDetail.queCount);
						
						setTimeout(function(){
							$(".progressComplete").remove();
							gridDetail.gridReflctQueExecute(gridId,data,layoutId);
						},1);
					}
				}else{
					var gridMap = gridDetail.getGridMap(layoutId);
					var gridId = gridMap.get("gridId");
					var rowNum = commonUtil.parseInt(gridMap.get("rowNum"));
					
					var $detail = $("#" + layoutId);
					$detail.find("input,select").each(function(){
						if(!$(this).attr("disabled")){
							var colName = $(this).attr("name");
							var colValue = $(this).val();
							
							if(gridList.getColData(gridId, rowNum, colName) != colValue){
								
								// 2019.09.18 박지현   벨리데이션 추가
								if( !gridDetail.checkDetailValidation(gridId, rowNum, colName, colValue) ){
									return false;
								}
								
								gridList.setColValue(gridId, rowNum, colName, colValue);
								gridList.setRowCheck(gridId, rowNum, true);
							}
						}
					});
					
					var msg = commonUtil.getMsg("VALID_M0013");
					
					var $msgBox = $("<div>").addClass("progressComplete");
					var $msgBoxText = $("<p>").addClass("completeText").text(msg);
					$msgBox.append($msgBoxText);
					
					$("#"+layoutId+" .gridDetailLayer-reflect").append($msgBox);
					
					setTimeout(function(){
						$(".progressComplete").fadeOut("fast","linear",function(){
							$(".progressComplete").remove();
						});
					},2000);
				}
			},200);
		});
	},
	
	checkReflectValidation : function(gridId, layoutId, dataMap){
		var result = true;
		
		if( commonUtil.checkFn("validationOfDataReflects") ){
			result = validationOfDataReflects(gridId, layoutId, dataMap);
		}
		
		return result;
	},
	
	checkDetailValidation : function(gridId, rowNum, colName, colValue){
		var result = true;
		
		if( commonUtil.checkFn("validationOfDataDetail") ){
			result = validationOfDataDetail(gridId, rowNum, colName, colValue);
		}
		
		return result;
	},
	
	getGridMap : function(layerId){
		var map = new DataMap();
		
		var layerArr = layerId.split("_");
		var rowNum = layerArr[layerArr.length - 1];
		
		var detailLayerId = layerId.replace(this.gridDetailId,"");
		var gridId = detailLayerId.replace("_"+rowNum,"");
		
		map.put("gridId",gridId);
		map.put("rowNum",rowNum);
		
		return map;
	},
	
	getReflectGridId : function(layerId,txt){
		return layerId.replace(txt,"");
	},
	
	validateReflectData : function(layerId,key){
		var $layer = $("#"+layerId);
		var $reflect = $("#"+ layerId + " table tr td").find("input,select");
		var isChecked = $("#" + layerId + " #chk_" + key).is(":checked");
		
		return isChecked;
	},
	
	getGridReflctData : function(gridId){
		var data = new DataMap();
		var layerId = gridDetail.gridReflectType + gridId;
		
		var $reflect = $("#"+ layerId + " table tr td").find("input,select");
		$reflect.each(function(){
			var key = $(this).attr("name");
			var val = $(this).val();
			
			if(gridDetail.validateReflectData(layerId,key)){
				data.put(key,val);
			}
		});
		
		return data;
	},
	
	initRelectData : function(layerId){
		var $reflect = $("#"+ layerId + " table tr td").find("input,select");
		$reflect.each(function(){
			var key = $(this).attr("name");
			$("#chk_" + key).prop("checked",false);
			if($(this).hasClass("inputNumber")){
				$(this).val(0);
			}else{
				$(this).val("");
			}
		});
	},
	
	gridReflctQueExecute : function(gridId,data,layoutId){
		var queCount = gridDetail.queCount;
		var listCount = gridDetail.gridListCount;
		if(queCount > listCount){
			queCount = listCount;
		}
		//console.log("1: ",queCount,listCount);
		if((gridDetail.queUpCount + 1) == gridDetail.queMaxCount){
			queCount = listCount - (queCount * gridDetail.queUpCount);
		}
		//console.log("2: ",queCount,listCount);	
		var rowNum = (gridDetail.queUpCount * gridDetail.queCount);
		//console.log("ROW:: ",rowNum);
		gridDetail.executeProgress(gridId,listCount,gridDetail.upCount);
		
		setTimeout(function(){
			for(var i = 0; i < queCount; i++){
				var list =  gridList.getSelectRowNumList(gridId,true);
				var idx = list[(rowNum + i)];
				
				gridDetail.gridReflctExecute(gridId,idx,data,layoutId);
			}
			
			gridDetail.queUpCount++;
			//console.log("UP:: ",gridDetail.queUpCount,"MAX:: ",gridDetail.queMaxCount);
			if(gridDetail.queUpCount < gridDetail.queMaxCount){
				gridDetail.gridReflctQueExecute(gridId,data,layoutId);
			}else{
				gridDetail.executeProgress(gridId,listCount,gridDetail.upCount);
				gridDetail.queMaxCount = 0;
				gridDetail.gridListCount = 0;
				gridDetail.queUpCount = 0;
				gridDetail.upCount = 0;
			}
		}, 25);
	},
	
	gridReflctExecute : function(gridId,rowNum,data,layoutId){
		var keys = data.keys();
		var keysLen = keys.length;
		for(var i = 0; i < keysLen; i++){
			var colName = keys[i];
			var colValue = data.get(colName);
			
			var readOnlyColTf = gridDetail.gridReflctReadOnlyCheckData(gridId,rowNum,colName);
			if(readOnlyColTf){
				var layerId = gridDetail.gridReflectType + gridId;
				var gridColTypeMap = gridList.getGridBox(gridId).colTypeMap;
				var colType = gridColTypeMap.get(colName);
				var colTypeSplit = colType.split(',');
				colType = colTypeSplit[0]; 
				if(colType == "check"){
					if($("#" + layoutId + " tbody tr td input[type='checkbox']").is(":checked")){
						colValue = "V";
					}else if(!($("#" + layoutId + " tbody tr td input[type='checkbox']").is(":checked"))){
						colValue = data.get(colName);
					}
				}
				
				gridList.setColValue(gridId, rowNum, colName, colValue);
			}
		}
		
		gridDetail.upCount++;
	},
	
	gridReflctReadOnlyCheckData : function(gridId,rowNum,colName){
		var gridBox = gridList.getGridBox(gridId);
		var readOnlyCellCount = (gridBox.readOnlyCellMap == null || gridBox.readOnlyCellMap == undefined) ? 0 : gridBox.readOnlyCellMap.size(); 
		if(readOnlyCellCount > 0){
			var readOnlyRow = gridBox.readOnlyCellMap.get(rowNum);
			if(readOnlyRow){
				return readOnlyRow.get(colName)?false:true;
			}
		}
		return true;
	},
	
	showProgressBar : function(gridId){
		var $layer = $("#"+ this.gridReflectType + gridId+ " .gridDetailLayer-reflect .reflectBox");
		var $wapper = $("<div>").addClass("progressbarWapper");
		var $progress = $("<div>").attr("id","progress").addClass("progressbarGuage");
		var $percent = $("<p>").attr("id","percent").addClass("percentText").text("0%");
		
		$wapper.append($progress).append($percent);
		$layer.after($wapper);
		
		$percent.css("left",$wapper.width()/2+"px");
	},
	
	executeProgress : function(gridId,gridListCount,upCount){
		//var progressCount = Math.ceil(100/this.gridListCount * this.upCount); 
		var progressCount = Math.floor(100/this.gridListCount * this.upCount);
		//console.log(">>>>>>>",progressCount + "%");
		if(progressCount >= 100){
			progressCount = 100;
			
			setTimeout(function(){
				$("#progress").attr("style","width: " + progressCount + "%;");
				$("#percent").text(progressCount + "%");
				
				gridDetail.gridListCount = 0;
				gridDetail.upCount=0;
				
				clearTimeout(gridDetail.itv1);
				clearTimeout(gridDetail.itv2);
				
				gridDetail.itv1 = null;
				gridDetail.itv2 = null;
			},100);
			
			setTimeout(function(){
				if(progressCount >= 100){
					$(".progressComplete").remove();
					
					var $layer = $("#"+ gridDetail.gridReflectType + gridId + " .gridDetailLayer-reflect");
					if(!$layer.hasClass("progressComplete")){
						$("#reflectLoading").hide();
						$(".gridDetailLayer-reflect button").show();
						$("#"+ gridDetail.gridReflectType + gridId + " .gridDetailLayer-header-buttonarea").show();
						$(".gridDetailLayer-detail").find("input,select").attr("disabled",false);
						
						$("#progress").attr("style","width: 0%;");
						$("#percent").text("0%");
						
						$(".progressbarWapper").remove();
						
						var msg = commonUtil.getMsg("VALID_M0012");
						
						var $msgBox = $("<div>").addClass("progressComplete");
						var $msgBoxText = $("<p>").addClass("completeText").text(msg);
						$msgBox.append($msgBoxText);
						$layer.append($msgBox);
						
						setTimeout(function(){
							$(".progressComplete").fadeOut("fast","linear",function(){
								$(".progressComplete").remove();
							});
						},2000);
					}
				}
			},300);
		}else{
			$("#progress").attr("style","width: " + progressCount + "%;");
			$("#percent").text(progressCount + "%");
		}
	},
	
	openGridDetail : function(gridId,rowNum){
		this.createGridDetail(gridId,rowNum);
	},
	
	createGridDetail : function(gridId,rowNum){
		var layoutId = this.gridDetailId + gridId +"_"+ rowNum;
		
		var $html = this.gridDetailMap.get(gridId).get("template").clone();
		$html.attr({"id":layoutId});
		
		$html.find(".reflectBox").attr({"id":layoutId+"_button"});
		
		var $contentBody = $("#"+gridId).parents(".content");
		$contentBody.after($html);
		
		uiList.UICheck($("#"+layoutId));
		inputList.setCombo(layoutId);
		inputList.setInput(layoutId);
		
		gridDetail.reloadComboData(layoutId);
		
		gridDetail.detailWidth = $("#"+layoutId).width();
		gridDetail.detailHeight = $("#"+layoutId).height();
		
		this.gridDetailClickEvent(layoutId);
		
		gridDetail.gridDetailResize(layoutId);
		
		gridDetail.setDesabledClass(gridId,rowNum,layoutId);
	},
	
	setDesabledClass : function(gridId,rowNum,layoutId){
		var $gridHtml = $("#"+gridId+" tr["+configData.GRID_ROW_NUM+"="+(rowNum)+"] td");
		var $gridDetailHtml = $("#"+layoutId).find("input,select");
		$gridHtml.each(function(){
			if($(this).hasClass(configData.GRID_EDIT_BACK_CLASS) && $(this).hasClass(configData.GRID_COL_TYPE_DISABLE_CLASS)){
				var name = $(this).attr(configData.GRID_COL) == undefined ? "" : $(this).attr(configData.GRID_COL).split(",")[1];
				$gridDetailHtml.each(function(){
					var detailName = $(this).attr("name");
					if(name == detailName){
						if($(this).hasClass("searchInput") || $(this).hasClass("calendarInput")){
							$(this).next().remove();
						}
						$(this).attr("disabled","disabled");
					}
				}); 
			}
		});
	},
	
	reloadComboData : function(gridId){
		var reloadComboArr = gridDetail.selectBoxReloadList;
		var reloadComboArrLen = reloadComboArr.length;
		if(reloadComboArrLen > 0){
			for(var i = 0; i < reloadComboArrLen; i++){
				var name = reloadComboArr[i][0];
				var comboUiOpt = reloadComboArr[i][1];
				inputList.reloadCombo($("#"+gridId+" [name="+name+"]"), configData.INPUT_COMBO, comboUiOpt);
			}
		}
	},
	
	showGridDetail : function(layoutId){
		$("#"+layoutId).show();
	},
	
	showReflectDetail : function(gridId){
		var result = true;
		
		if( commonUtil.checkFn("openReflectBefore") ){
			result = openReflectBefore(gridId);
		}
		
		if(result){
			gridDetail.gridDetailResize(this.gridReflectType + gridId);
			
			gridDetail.reloadComboData(this.gridReflectType + gridId);
			
			this.initRelectData(this.gridReflectType + gridId);
			var $layout = $("#" + this.gridReflectType + gridId);
			$layout.fadeIn("fast","linear",function(){
				$layout.show();
			});
		}
	},
	
	hideGridDetail : function(layoutId){
		$("#"+layoutId).hide();
	},
	
	removeGridDetail : function(layoutId){
		var $layout = $("#"+layoutId);
		$layout.fadeOut("fast","linear",function(){
			if(layoutId.indexOf(gridDetail.gridReflectType) > -1){
				gridDetail.hideGridDetail(layoutId);
			}else{
				$layout.remove();
			}
			
		});
	},
	
	gridDetailBind : function(gridId, rowNum){
		$(".gridDetailLayer.gridDetailBox").remove();
		
		this.createGridDetail(gridId, rowNum);
		
		var data = gridList.getRowData(gridId, rowNum);
		var bindArea = this.gridDetailId + gridId + "_" + rowNum;
		
		$(".gridDetailLayer-detail-table td input,select,textarea").each(function(){
			var isDisabeld = $(this).attr("disabled"); 
			if(isDisabeld){
				$(this).parent().css("background-color","#efefef");
			}
		});
		
		dataBind.dataNameBind(data, bindArea);
	},
	
	gridReflect : function(gridId){
		
	}
}

var gridDetail = new GridDetail();