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
	
	this.GRID_CALENDAR_ICON = "/common/theme/darkness/images/cal_icon2.png";
	this.INPUT_CALENDAR_ICON = "/common/theme/darkness/images/cal_icon2.png";
	
	this.GRID_EDIT_INPUT_HTML = "<input id='"+configData.GRID_EDIT_INPUT_ID+"' type='text' style='width:100%;height:100%;' class='GEditBack'/>";
	this.GRID_EDIT_CHECKBOX_HTML = "<input type='checkbox' class='GEditBack' />";
	
	this.GRID_BTN_WIDTH = 27;
	this.GRID_DEFAULT_ROW_HEIGHT = 22;
	this.GRID_COL_MINWIDTH = 30;
	
	this.findViewType = false;
	
	this.fontWidth = 15;
};

Theme.prototype = {
	setGridBtn : function(gridBox, $obj) {
		$obj.addClass("button");
		$obj.addClass("type4");
		var btnType = $obj.attr(configData.GRID_BTN);
		var btnLabelKey = "";
		var tmpHtml;
		if(btnType == configData.GRID_BTN_FIND){
			tmpHtml = "<img src='/common/theme/darkness/images/grid_icon_03.png' />";
			gridBox.findBtnType = true;
			var tmpInputHtml = "<span><input type='text' />"
						+ "<button class='button type8' type='button' ><img src='/common/theme/darkness/images/ico_up.png' /></button>"
						+ "<button class='button type8' type='button' ><img src='/common/theme/darkness/images/ico_down.png' /></button>"
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
			
			gridBox.$findInput.keydown(function(event){
				if(event.keyCode == 13){
					var $obj = jQuery(event.target);
					var tmpTxt = $obj.val();
					gridBox.findData(tmpTxt);
				}				
			});
			
			btnLabelKey = "BTN_FINDDATA";
		}else if(btnType == configData.GRID_BTN_FIND+"1"){
			tmpHtml = "<img src='/common/theme/darkness/images/grid_icon_03.png' />";
			gridBox.findBtnType = true;
			var tmpInputHtml = "<button class='button type8' type='button' ><img src='/common/theme/darkness/images/btn_next.png' /></button>"
						+ "<span>"
						+ "<input type='text' />"
						+ "<button class='button type8' type='button' ><img src='/common/theme/darkness/images/ico_up.png' /></button>"
						+ "<button class='button type8' type='button' ><img src='/common/theme/darkness/images/ico_down.png' /></button>"
						//+ "<button class='button type8' type='button' ><img src='/common/theme/darkness/images/ico_left1.png' /></button>"
						+ "<span> (0/0) </span></span>";
			var $tmpObj = jQuery(tmpInputHtml);
			$obj.before($tmpObj);
			gridBox.$findInput = $tmpObj.find("input");
			gridBox.$findInfo = $tmpObj.find("span");
			gridBox.$findInput.parent().hide();
			$obj.hide();
			$tmpObj.eq(0).click(function(event){
				if(theme.findViewType){
					gridBox.$findInput.parent().hide();
					$obj.hide();
					theme.findViewType = false;
				}else{
					gridBox.$findInput.parent().show();
					$obj.show();
					theme.findViewType = true;
				}				
			});
			var $tmpBtn = $tmpObj.eq(1).find("button");
			$tmpBtn.eq(0).click(function(event){
				gridBox.findDataFocusMove(-1);			
			});
			$tmpBtn.eq(1).click(function(event){
				gridBox.findDataFocusMove(1);			
			});
			/*
			$tmpBtn.eq(2).click(function(event){
				var tmpTxt = gridBox.$findInput.val();
				gridBox.changeRowHeight(tmpTxt);			
			});
			*/
			$obj.click(function(event){
				var $obj = jQuery(event.target);
				var tmpTxt = gridBox.$findInput.val();
				gridBox.findData(tmpTxt);			
			});
			
			btnLabelKey = "BTN_FINDDATA";
		}else if(btnType == configData.GRID_BTN_SORT_RESET){
			tmpHtml = "<img src='/common/theme/darkness/images/ico_btn5.png' />";
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
			tmpHtml = "<img src='/common/theme/darkness/images/grid_icon_04.png' />";
			$obj.click(function(event){
				gridBox.addRow();
			});
			btnLabelKey = "BTN_ADDROW";
			
			gridBox.addType = true;
		}else if(btnType == configData.GRID_BTN_DELETE){
			tmpHtml = "<img src='/common/theme/darkness/images/grid_icon_02.png' />";
			$obj.click(function(event){
				if(gridBox.selectRowDeleteType){
					gridBox.deleteSelectRow();
				}else{
					gridBox.deleteRow();
				}
			});
			btnLabelKey = "BTN_DELETEROW";
			
			gridBox.deleteType = true;
		}else if(btnType == configData.GRID_BTN_LAYOUT){
			tmpHtml = "<img src='/common/theme/darkness/images/grid_icon_07.png' />";
			gridBox.layoutType = true;
			$obj.click(function(event){
				layoutSave.setLauyout(gridBox);
			});
			btnLabelKey = "BTN_LAYOUT";
			
			gridBox.columnEditType = true;
		}else if(btnType == configData.GRID_BTN_FILTER){
			tmpHtml = "<img src='/common/theme/darkness/images/ico_btn8.png' />";
			gridBox.layoutType = true;
			$obj.click(function(event){
				gridList.filterLayoutView(gridBox.id);
			});
			btnLabelKey = "BTN_FILTER";
		}else if(btnType == configData.GRID_BTN_TOTAL){
			tmpHtml = "<img src='/common/theme/darkness/images/grid_icon_08.png' />";
			$obj.click(function(event){
				gridBox.viewTotal();
			});
			btnLabelKey = "BTN_TOTAL";
			
			gridBox.totalType = true;
		}else if(btnType == configData.GRID_BTN_SUB_TOTAL){
			tmpHtml = "<img src='/common/theme/darkness/images/ico_btn7.png' />";
			$obj.click(function(event){
				gridList.subTotalLayoutView(gridBox.id);
			});
			btnLabelKey = "BTN_SUB_TOTAL";
		}else if(btnType == configData.GRID_BTN_EXCEL){
			tmpHtml = "<img src='/common/theme/darkness/images/ico_btn9.png' />";
			$obj.click(function(event){
				gridBox.gridExcelRequest();
			});
			btnLabelKey = "BTN_EXCELDN";
			
			gridBox.excelDownType = true;
		}else if(btnType == configData.GRID_BTN_EXCEL_UP){
			tmpHtml = "<img src='/common/theme/darkness/images/ico_btn10.png' />";
			$obj.click(function(event){
				gridList.excelUpLayoutView(gridBox.id);
			});
			btnLabelKey = "BTN_EXCELUP";
		}else if(btnType == configData.GRID_BTN_CHECK){
			tmpHtml = "<img src='/common/theme/darkness/images/grid_icon_02.png' />";
			$obj.click(function(event){
				if(gridBox.$checkHead){
					gridBox.changeCheckHead(true);
				}
			});
			btnLabelKey = "BTN_CHECKALL";
		}else if(btnType == configData.GRID_BTN_WRITE){
			tmpHtml = "<img src='/common/theme/darkness/images/grid_icon_01.png' />";
			$obj.click(function(event){
				//event fn
				if(commonUtil.checkFn("gridListEventBtnClick")){
					gridListEventBtnClick(gridBox.id, configData.GRID_BTN_WRITE);
				}
			});
			btnLabelKey = "BTN_WRITE";
		}else if(btnType == configData.GRID_BTN_COPY){
			tmpHtml = "<img src='/common/theme/darkness/images/grid_icon_15.png' />";
			$obj.click(function(event){
				gridBox.copyRow();
			});
			btnLabelKey = "BTN_COPY";
			
			gridBox.addType = true;
		}else if(btnType == configData.GRID_BTN_COLFIX){
			tmpHtml = "<img src='/common/images/ico_left1.png' />";
			$obj.click(function(event){
				gridBox.colFix();
			});
			btnLabelKey = "BTN_COLFIX";
			
			gridBox.colFixBtnType = true;
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
			+ "<a href='#'><img src='/common/theme/darkness/images/btn_first.png' /></a>"
			+ "	<a href='#'><img src='/common/theme/darkness/images/btn_prev.png' /></a>"
			+ "<span></span>"
			+ "	<a href='#'><img src='/common/theme/darkness/images/btn_next.png' /></a>"
			+ "<a href='#'><img src='/common/theme/darkness/images/btn_last.png' /></a>"
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
		//var iconClass = configData.BUTTON_ICON.get(configData.BUTTON_TYPE_SEARCH);
		//var $searchBtn = jQuery("<button class='"+configData.BUTTON_CLASS+"' type='button' style='height:100%;'><span class='"+configData.BUTTON_ICON_CLASS+" "+iconClass+"'>Icon</span></button>");
		var $searchBtn = jQuery("<button class='button type3' type='button' ><img src='/common/theme/darkness/images/ico_find.png' /></button>");
		return $searchBtn;
	},
	getInputSearchBtn : function(inputObj){
		var $searchBtn = jQuery("<button class='button type3' type='button' ><img src='/common/theme/darkness/images/ico_find.png' /></button>");
		return $searchBtn;
	},
	getInputRangeDash : function(inputObj){
		return "<span> ~ </span>";
	},
	getInputRangeBtn : function(inputObj){
		var $rangeBtn = jQuery("<button class='button type3' type='button'><img src='/common/theme/darkness/images/ico_enter.png' /></button>");
		return $rangeBtn;
	},
	getMultiValueBtn : function(inputObj, labelText){
		var $valueBtn = jQuery("<button class='"+configData.BUTTON_CLASS+"' type='button' style='margin-left:10px;'></button>");
		$valueBtn.append("<span class='"+configData.BUTTON_TEXT_CLASS+"'style='margin-left:10px;'>"+labelText+"</span>");
		return $valueBtn;
	},
	setInputCalendarEffect : function($input){
		$input.next(".ui-datepicker-trigger").css({
			"margin-left":"5px",
			"margin-right":"6px",
			"opacity":"0.6"
			});
	},
	setGridCalendarEffect : function($input){
		$input.next(".ui-datepicker-trigger").css({
			"margin-left":"5px",
			"opacity":"0.6"
			});
	},
	getGridDeleteBtn : function(gridBox){
		var $btnObj = jQuery("<button class='button type3' type='button' onclick='gridList.deleteBtnClick(\""+gridBox.id+"\",this)'><img src='/common/theme/darkness/images/grid_icon_10.png' /></button>");
		$btnObj.attr(configData.GRID_COL_TYPE_BTN_ROWNUM_ATT, configData.GRID_COL_DATA_NAME_ROWNUM);
		return $btnObj;
	},
	createGridHead : function(gridBox) {
		var $ghList = gridBox.$box.find("["+configData.GRID_HEAD+"]");
		var $gh;
		var attList;
		var colType;
		var colName;
		var lblTxt;
		var colHtml = "";
		var thHtml = "";
		var ghbtn = "";
		for(var i=0;i<$ghList.length;i++){
			$gh = $ghList.eq(i);
			attList = $gh.attr(configData.GRID_HEAD).split(" ");
			colHtml += "<col width='"+attList[0]+"'/>";
			lblTxt = "";
			ghbtn = "";
			if(attList.length == 1){
				attList = $gh.attr(configData.GRID_COL).split(",");
				if(attList[0] == configData.GRID_COL_TYPE_ROWNUM){
					lblTxt = uiList.getLabel("STD_NUMBER");
				}else if(attList[0] == configData.GRID_COL_TYPE_ROWCHECK){
					ghbtn = " GBtnCheck='true'";
				}else if(attList[0] == configData.GRID_COL_TYPE_CHECKBOX && !attList[2]){
					ghbtn = " GBtnCheck='"+attList[1]+"'";
				}
				if(attList.length > 1){
					lblTxt = uiList.getLabel("STD_"+attList[1]);
				}
			}else{				
				lblTxt = uiList.getLabel(attList[1]);
			}
			thHtml += "<th"+ghbtn+">"+lblTxt+"</th>";
		}
		
		var tmpHtml = "<div class='"+configData.GRID_HEAD_CLASS+"'>" 
			+ "<table>"
			+ "<colgroup>"
			+ colHtml
			+ "</colgroup>"
			+ "<thead></tr>"
			+ thHtml
			+ "</tr></thead></table></div>";
		/*
		var $headDiv = gridBox.$gridLayout.find(".grid_head");
		if($headDiv.length > 0){
			$headDiv.html(tmpHtml);
		}else{
			tmpHtml = "<div class='grid_head'>"+tmpHtml+"</div>";
			gridBox.$gridBody.before(tmpHtml);
		}
		*/
		gridBox.$gridBody.before(tmpHtml);
		gridBox.$gridBody.find("colgroup").remove();
		tmpHtml = "<colgroup>"+ colHtml+ "</colgroup>";
		gridBox.$box.before(tmpHtml);
		
		var $utilDiv = gridBox.$gridLayout.find("."+configData.GRID_BOTTOM_CLASS);
		if($utilDiv.length == 0){
			tmpHtml = "<div class='tableUtil'>"
					+ "	<div class='leftArea'>"
					+ "		<button type='button' GBtn='find'></button>"
					+ "		<button type='button' GBtn='filter'></button>"
					+ "		<button type='button' GBtn='sortReset'></button>"
					+ "		<button type='button' GBtn='add'></button>"
					+ "		<button type='button' GBtn='copy'></button>"
					+ "		<button type='button' GBtn='delete'></button>"
					+ "		<button type='button' GBtn='layout'></button>"
					+ "		<button type='button' GBtn='total'></button>"
					+ "		<button type='button' GBtn='subTotal'></button>"
					+ "		<button type='button' GBtn='excel'></button>"
					+ "		<button type='button' GBtn='excelUpload'></button>"
					+ "		<button type='button' GBtn='colFix'></button>									"
					+ "	</div>"
					+ "	<div class='rightArea'>"
					+ "		<p class='record' GInfoArea='true'>0 Record</p>"
					+ "	</div>"
					+ "</div>";
			gridBox.$gridLayout.append(tmpHtml);
		}
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
	setSearchCombo : function($obj, comboInput){		
		var $tmpDiv = jQuery("<div style='position:absolute;'></div>");
		$obj.parent().css("height","30px").append($tmpDiv);
		var $tmpInputObj;
		if(comboInput && !isNaN(comboInput)){
			$tmpInputObj = jQuery("<input type='text' style='vertical-align: top; width: "+comboInput+"px; height: 26px; margin-right: 3px'/>");
			$tmpDiv.append($tmpInputObj);
		}
		$tmpDiv.append($obj);
		return $tmpInputObj;
	},
	setMultipleCombo : function($obj, comboInput){		
		var $tmpDiv = jQuery("<div style='position:absolute;'></div>");
		$obj.parent().css("height","30px").append($tmpDiv);
		var $tmpInputObj;
		if(comboInput && !isNaN(comboInput)){
			$tmpInputObj = jQuery("<input type='text' style='vertical-align: top; width: "+comboInput+"px; height: 26px; margin-right: 3px'/>");
			$tmpDiv.append($tmpInputObj);
		}		
		$obj.attr("multiple","multiple");
		$tmpDiv.append($obj);
		return $tmpInputObj;
	},
	toString : function() {
		return "Theme";
	}
};

var theme = new Theme();