Theme = function() {
	this.$inputObj;
	this.searchOpenGridId;;
	this.param;
	this.popData;
	
	this.INPUT_SEARCH_CLASS = "searchInput";
	this.INPUT_RANGE_CLASS = "normalInput";
	this.INPUT_NUMBER_CLASS = "inputNumber";
	this.INPUT_BUTTON_CLASS = "searchInput";
	this.INPUT_NORMAL_CLASS = "normalInput";
	
	this.GRID_CALENDAR_ICON = "/common/images/cal_icon.png";
	this.INPUT_CALENDAR_ICON = "/common/images/cal_icon.png";
	
	this.GRID_EDIT_INPUT_HTML = "<input id='"+configData.GRID_EDIT_INPUT_ID+"' type='text' style='width:100%;height:100%;' class='GEditBack'/>";
	this.GRID_EDIT_CHECKBOX_HTML = "<input type='checkbox' class='GEditBack' />";
	
	this.GRID_BTN_WIDTH = 22;
	this.GRID_DEFAULT_ROW_HEIGHT = 15;
	this.GRID_COL_MINWIDTH = 30;
};

Theme.prototype = {
	setGridBtn : function(gridBox, $obj) {
		$obj.addClass("button");
		$obj.addClass("type4");
		var btnType = $obj.attr(configData.GRID_BTN);
		var btnLabelKey = "";
		var tmpHtml;
		if(btnType == configData.GRID_BTN_FIND){
			tmpHtml = "<img src='/common/images/grid_icon_03.png' />";
			gridBox.findBtnType = true;
			var tmpInputHtml = "<span><input type='text' />"
						+ "<button class='button type8' type='button' ><img src='/common/images/ico_up.png' /></button>"
						+ "<button class='button type8' type='button' ><img src='/common/images/ico_down.png' /></button>"
						+ "<span> (0/0) </span></span>";
			var $tmpObj = jQuery(tmpInputHtml);
			$obj.before($tmpObj);
			gridBox.$findInput = $tmpObj.find("input");
			gridBox.$findInfo = $tmpObj.find("span");
			var $tmpBtn = $tmpObj.find("button");
			$tmpBtn.eq(0).click(function(event){
				gridBox.findDataFocusMove(-1);			
			});
			$tmpBtn.eq(1).click(function(event){
				gridBox.findDataFocusMove(1);			
			});
			$obj.click(function(event){
				var $obj = jQuery(event.target);
				var tmpTxt = gridBox.$findInput.val();
				gridBox.findData(tmpTxt);			
			});
			
			btnLabelKey = "BTN_FINDDATA";
		}else if(btnType == configData.GRID_BTN_SORT_RESET){
			tmpHtml = "<img src='/common/images/ico_btn5.png' />";
			$obj.click(function(event){
				gridBox.sortReset();
			});
			
			btnLabelKey = "BTN_SORTRESET";
		}else if(btnType == configData.GRID_BTN_UP){
			tmpHtml = "▲";
			$obj.click(function(event){
				gridBox.rowUp();
			});
			btnLabelKey = "BTN_ROWUP";
		}else if(btnType == configData.GRID_BTN_DOWN){
			tmpHtml = "▼";
			$obj.click(function(event){
				gridBox.rowDown();
			});
			btnLabelKey = "BTN_ROWDOWN";
		}else if(btnType == configData.GRID_BTN_ADD){
			tmpHtml = "<img src='/common/images/grid_icon_04.png' />";
			$obj.click(function(event){
				gridBox.addRow();
			});
			btnLabelKey = "BTN_ADDROW";
		}else if(btnType == configData.GRID_BTN_DELETE){
			tmpHtml = "<img src='/common/images/grid_icon_02.png' />";
			$obj.click(function(event){
				gridBox.deleteRow();
			});
			btnLabelKey = "BTN_DELETEROW";
		}else if(btnType == configData.GRID_BTN_LAYOUT){
			tmpHtml = "<img src='/common/images/grid_icon_07.png' />";
			gridBox.layoutType = true;
			$obj.click(function(event){
				layoutSave.setLauyout(gridBox);
			});
			btnLabelKey = "BTN_LAYOUT";
		}else if(btnType == configData.GRID_BTN_FILTER){
			tmpHtml = "<img src='/common/images/ico_btn8.png' />";
			gridBox.layoutType = true;
			$obj.click(function(event){
				gridList.filterLayoutView(gridBox.id);
			});
			btnLabelKey = "BTN_FILTER";
		}else if(btnType == configData.GRID_BTN_TOTAL){
			tmpHtml = "<img src='/common/images/grid_icon_08.png' />";
			$obj.click(function(event){
				gridBox.viewTotal();
			});
			btnLabelKey = "BTN_TOTAL";
		}else if(btnType == configData.GRID_BTN_SUB_TOTAL){
			tmpHtml = "<img src='/common/images/ico_btn7.png' />";
			$obj.click(function(event){
				gridList.subTotalLayoutView(gridBox.id);
			});
			btnLabelKey = "BTN_SUB_TOTAL";
		}else if(btnType == configData.GRID_BTN_EXCEL){
			tmpHtml = "<img src='/common/images/ico_btn9.png' />";
			$obj.click(function(event){
				gridBox.gridExcelRequest();
			});
			btnLabelKey = "BTN_EXCELDN";
		}else if(btnType == configData.GRID_BTN_EXCEL_UP){
			tmpHtml = "<img src='/common/images/ico_btn10.png' />";
			$obj.click(function(event){
				gridList.excelUpLayoutView(gridBox.id);
			});
			btnLabelKey = "BTN_EXCELUP";
		}else if(btnType == configData.GRID_BTN_CHECK){
			tmpHtml = "<img src='/common/images/grid_icon_02.png' />";
			$obj.click(function(event){
				if(gridBox.$checkHead){
					gridBox.changeCheckHead(true);
				}
			});
			btnLabelKey = "BTN_CHECKALL";
		}else if(btnType == configData.GRID_BTN_WRITE){
			tmpHtml = "<img src='/common/images/grid_icon_01.png' />";
			$obj.click(function(event){
				//event fn
				if(commonUtil.checkFn("gridListEventBtnClick")){
					gridListEventBtnClick(gridBox.id, configData.GRID_BTN_WRITE);
				}
			});
			btnLabelKey = "BTN_WRITE";
		}else if(btnType == configData.GRID_BTN_COPY){
			tmpHtml = "<img src='/common/images/grid_icon_15.png' />";
			$obj.click(function(event){
				gridBox.copyRow();
			});
			btnLabelKey = "BTN_COPY";
		}else if(btnType == configData.GRID_BTN_COLFIX){
			tmpHtml = "<img src='/common/images/ico_left1.png' />";
			$obj.click(function(event){
				gridBox.colFix();
			});
			btnLabelKey = "BTN_COLFIX";
		}
		
		if(tmpHtml){
			$obj.append(tmpHtml);
			if(btnLabelKey){
				var labelTxt = uiList.getLabel(btnLabelKey);
				$obj.attr("title", labelTxt);
			}else{
				$obj.attr("title", btnType);
			}
		}
	},
	setGridPgecountInfo : function(gridBox) {
		var tmpHtml = "<div class='paging'>"
			+ "<a href='#'><img src='/common/images/btn_first.png' /></a>"
			+ "	<a href='#'><img src='/common/images/btn_prev.png' /></a>"
			+ "<span></span>"
			+ "	<a href='#'><img src='/common/images/btn_next.png' /></a>"
			+ "<a href='#'><img src='/common/images/btn_last.png' /></a>"
			+ "</div>";
		gridBox.$paging = jQuery(tmpHtml);
		var $tmpLink = gridBox.$paging.find("a");
		$tmpLink.eq(0).click(function(event){
			gridBox.linkFirst();
		});
		$tmpLink.eq(1).click(function(event){
			gridBox.linkPrev();
		});
		$tmpLink.eq(2).click(function(event){
			gridBox.linkNext();
		});
		$tmpLink.eq(3).click(function(event){
			gridBox.linkLast();
		});
		
		gridBox.$gridBottom.find(">div").eq(0).after(gridBox.$paging);
	},
	setGridFinddataInfo : function($findInfo, findIndex, findCount){
		$findInfo.text(" ("+findIndex+" / "+findCount+") ");
	},
	getGridSearchBtn : function(gridBox, $input){
		var iconClass = configData.BUTTON_ICON.get(configData.BUTTON_TYPE_SEARCH);
		var $searchBtn = jQuery("<button class='"+configData.BUTTON_CLASS+"' type='button' style='height:100%;'><span class='"+configData.BUTTON_ICON_CLASS+" "+iconClass+"'>Icon</span></button>");
		return $searchBtn;
	},
	getInputSearchBtn : function(inputObj){
		var $searchBtn = jQuery("<button class='button type3' type='button' ><img src='/common/images/ico_find.png' /></button>");
		return $searchBtn;
	},
	getInputRangeDash : function(inputObj){
		return "<span> ~ </span>";
	},
	getInputRangeBtn : function(inputObj){
		var $rangeBtn = jQuery("<button class='button type3' type='button'><img src='/common/images/ico_enter.png' /></button>");
		return $rangeBtn;
	},
	getMultiValueBtn : function(inputObj, labelText){
		var $valueBtn = jQuery("<button class='"+configData.BUTTON_CLASS+"' type='button' style='margin-left:5px;'></button>");
		$valueBtn.append("<span class='"+configData.BUTTON_TEXT_CLASS+"'style='margin-left:5px;'>"+labelText+"</span>");
		return $valueBtn;
	},
	setInputCalendarEffect : function($input){
		$input.next(".ui-datepicker-trigger").css({
			"margin-left":"3px",
			"margin-right":"3px",
			"opacity":"0.5"
			});
		$input.parent().find(".ui-autocomplete-input").keydown(function(event) {
		    if (event.which === $.ui.keyCode.ENTER) {
		        event.preventDefault();
		    }
		});
	},
	setGridCalendarEffect : function($input){
		$input.next(".ui-datepicker-trigger").css({
			"opacity":"0.5"
			});
	},
	createInput : function($obj){
		var $input = jQuery(theme.GRID_EDIT_INPUT_HTML);
		if($obj.hasClass(configData.GRID_COL_TYPE_INPUT_NUMBER_CLASS)){
			$obj.css({
				"padding-right" : "0px",
				"padding-left" : "0px"
			});
			/*
			$input.css({
				"margin-right" : "-5px"
			});
			*/
		}else{
			$obj.css({
				"padding-right" : "0px",
				"padding-left" : "0px"
			});
			/*
			$input.css({
				"margin-left" : "-5px"
			});
			*/
		}
		
		return $input;
	},
	removeInput : function($obj){
		if($obj.hasClass(configData.GRID_COL_TYPE_INPUT_NUMBER_CLASS)){
			$obj.css({
				"padding-right" : "5px",
				"padding-left" : "5px"
			});
		}else{
			$obj.css({
				"padding-right" : "5px",
				"padding-left" : "5px"
			});
		}
	},
	toString : function() {
		return "Theme";
	}
};

var theme = new Theme();