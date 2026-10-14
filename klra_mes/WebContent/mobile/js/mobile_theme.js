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
	
	this.GRID_CALENDAR_ICON = "/common/theme/webdek/images/cal.png";
	this.INPUT_CALENDAR_ICON = "/common/theme/webdek/images/cal.png";
	this.MONTH_PICKER_ICON = "/common/theme/webdek/mobile_img/btn_month.png"; 
	
	this.GRID_EDIT_INPUT_HTML = "<input id='"+configData.GRID_EDIT_INPUT_ID+"' type='text' style='width:100%;height:100%;' class='GEditBack'/>";
	this.GRID_EDIT_CHECKBOX_HTML = "<input type='checkbox' class='GEditBack' />";
	
	this.GRID_BTN_WIDTH = 27;
	this.GRID_DEFAULT_ROW_HEIGHT = 25;
	this.GRID_COL_MINWIDTH = 30;
	
	this.findViewType = false;
	
	this.fontWidth = 8;
	
	this.SEARCH_ONE_ROW = 120;
	
	this.GRID_BOX_CLASS = "section";
	this.GRID_HEAD_CLASS = "table_thead";
	this.GRID_BODY_CLASS = "scroll";
	this.GRID_BOTTOM_CLASS = "tableUtil";
	this.GRID_TAB_BOX_CLASS = "bottomSect";
	this.GRID_COLFIXHEAD_CLASS = "colFixHead";
	this.GRID_COLFIXBODY_CLASS = "colFixBody";
	
	this.GRID_LAYOUT_HEAD_COL_LEFT_CLASS = "GLHeadColLeft";
	this.GRID_LAYOUT_HEAD_COL_RIGHT_CLASS = "link_line";
	
	this.BUTTON_TYPE_SEARCH = "SEARCH";
	this.BUTTON_TYPE_EXECUTE = "EXECUTE";
	this.BUTTON_TYPE_PREV = "PREV";
	this.BUTTON_TYPE_ADD = "ADD";
	this.BUTTON_TYPE_SAVE = "SAVE";
	this.BUTTON_TYPE_PENCIL = "PENCIL";
	this.BUTTON_TYPE_EXPAND = "EXPAND";
	this.BUTTON_TYPE_REFLECT = "REFLECT";
	this.BUTTON_TYPE_CLOSE = "CLOSE";
	this.BUTTON_TYPE_CHECK = "CHECK";
	this.BUTTON_TYPE_PRINT = "PRINT";
	this.BUTTON_TYPE_SEND = "SEND";
	this.BUTTON_TYPE_WORK = "WORK";
	this.BUTTON_TYPE_SPEAK = "SPEAK";
	this.BUTTON_TYPE_FILE = "FILE";
	this.BUTTON_TYPE_COPY = "COPY";
	this.BUTTON_TYPE_UP = "UP";
	this.BUTTON_TYPE_DOWN = "DOWN";
	this.BUTTON_TYPE_INSFLD = "INSFLD";
	this.BUTTON_TYPE_CART = "CART";
	this.BUTTON_TYPE_ALLOCATE = "ALLOCATE";
	this.BUTTON_TYPE_NOTE = "NOTE";
	this.BUTTON_TYPE_CREATE = "CREATE";
	this.BUTTON_TYPE_RECALL = "RECALL";
	this.BUTTON_TYPE_SAVEAS = "SAVEAS";
	this.BUTTON_TYPE_DELETE = "DELETE";
	this.BUTTON_TYPE_WCANCLE = "WCANCLE";
	this.BUTTON_TYPE_CALENDER = "CALENDER";
	this.BUTTON_TYPE_GETVARIANT = "GETVARIANT";
	this.BUTTON_TYPE_SAVEVARIANT = "SAVEVARIANT";
	this.BUTTON_TYPE_APPROVE = "APPROVE";
	this.BUTTON_TYPE_REJECT = "REJECT";	
	this.BUTTON_TYPE_GRID_FILE = "GRID_FILE";
	this.BUTTON_TYPE_RESET = "RESET";
	this.BUTTON_TYPE_MAP = "MAP";
	this.BUTTON_TYPE_EXCEL_UP = "EXCEL_UP";
	this.BUTTON_TYPE_TEMP_SAVE = "TEMP_SAVE";
	this.BUTTON_TYPE_APPLY = "APPLY";
	this.BUTTON_TYPE_CANCEL_APPLY = "CANCEL_APPLY";
	this.BUTTON_TYPE_CANCEL = "CANCEL";
	this.BUTTON_TYPE_COPY_GRID = "COPY_GRID";
	this.BUTTON_TYPE_VIEW_INFO = "VIEW_INFO";
	this.BUTTON_TYPE_VIEW_DETAIL = "VIEW_DETAIL";
	this.BUTTON_TYPE_DELIVERY = "DELIVERY";
	this.BUTTON_TYPE_PRINT_OUT = "PRINT_OUT";
	this.BUTTON_TYPE_VIEW_MAP = "VIEW_MAP";
	this.BUTTON_TYPE_LOCA = "LOCA";
	
	this.BUTTON_ICON = new DataMap();
	this.BUTTON_ICON.put(this.BUTTON_TYPE_SEARCH, "basic_search");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_SAVE, "btn_color");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_ADD, "basic_add_new");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_DELETE, "basic_del");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_RESET, "basic_reset");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_EXCEL_UP, "btn_excel_up");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_TEMP_SAVE, "btn_temp_save");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_APPLY, "btn_apply");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_CANCEL_APPLY, "btn_cancel");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_CANCEL, "btn_cancel");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_COPY_GRID, "btn_icon_copy");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_VIEW_INFO, "btn_view_info");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_VIEW_DETAIL, "btn_view_detail");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_DELIVERY, "btn_delivery");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_PRINT_OUT, "btn_print");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_VIEW_MAP, "btn_view_map");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_LOCA, "btn_loca");
	
	this.BUTTON_ICON.put(this.BUTTON_TYPE_EXECUTE, "top_icon_01");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_PREV, "top_icon_31");		
	this.BUTTON_ICON.put(this.BUTTON_TYPE_PENCIL, "top_icon_04");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_EXPAND, "top_icon_05");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_REFLECT, "top_icon_23");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_CLOSE, "top_icon_08");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_CHECK, "top_icon_08");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_PRINT, "top_icon_09");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_SEND, "top_icon_10");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_WORK, "top_icon_11");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_SPEAK, "top_icon_12");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_FILE, "top_icon_13");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_COPY, "top_icon_14");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_UP, "top_icon_15");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_DOWN, "top_icon_16");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_INSFLD, "top_icon_17");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_CART, "top_icon_18");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_ALLOCATE, "top_icon_19");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_NOTE, "top_icon_20");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_CREATE, "top_icon_21");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_RECALL, "top_icon_22");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_SAVEAS, "top_icon_07");	
	this.BUTTON_ICON.put(this.BUTTON_TYPE_WCANCLE, "top_icon_24");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_CALENDER, "top_icon_20");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_GETVARIANT, "top_icon_26");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_SAVEVARIANT, "top_icon_27");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_APPROVE, "top_icon_28");
	this.BUTTON_ICON.put(this.BUTTON_TYPE_REJECT, "top_icon_29");	
	this.BUTTON_ICON.put(this.BUTTON_TYPE_GRID_FILE, "grid_icon_16");
};

Theme.prototype = {
	setGridBtn : function(gridBox, $obj) {
		$obj.addClass("btn");
		//$obj.addClass("type4");
		var btnType = $obj.attr(configData.GRID_BTN);
		var btnLabelKey = "";
		var tmpHtml;
		if(btnType == configData.GRID_BTN_FIND){
			gridBox.findBtnType = true;
			var $gridBtnGroup = $obj.parent();
			var tmpFindAreaHtml = '<div class="util-left">'
								+ '<input class="input currencysummary" type="text" />'
								+ '<button type="button" class="btn btn_list_prev" title="'+uiList.getLabel("BTN_FINDPREV")+'"></button>'
								+ '<button type="button" class="btn btn_list_next" title="'+uiList.getLabel("BTN_FINDNEXT")+'"></button>'	
								+ '<span class="select-number">( 0 / 0 )</span>'
								+ '<button type="button" class="btn btn_showdetail" title="'+uiList.getLabel("BTN_FINDDATA")+'"></button>'	
								+ '</div>';
			var $findArea = jQuery(tmpFindAreaHtml);
			$obj.remove();
			$gridBtnGroup.prepend($findArea);

			gridBox.$findInput = $findArea.find(".currencysummary");
			gridBox.$findInfo = $findArea.find(".select-number");
			$findArea.find(".btn_list_prev").click(function(event){
				gridBox.findDataFocusMove(-1);			
			});
			$findArea.find(".btn_list_next").click(function(event){
				gridBox.findDataFocusMove(1);			
			});
			
			$findArea.find(".btn_showdetail").click(function(event){
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
		}else if(btnType == configData.GRID_BTN_SORT_RESET){
			$obj.addClass("btn_sortreset");
			$obj.click(function(event){
				gridBox.sortReset();
			});
			
			btnLabelKey = "BTN_SORTRESET";
		}else if(btnType == configData.GRID_BTN_UP){
			//tmpHtml = "▲";
			$obj.click(function(event){
				gridBox.rowUp();
			});
			btnLabelKey = "BTN_ROWUP";
		}else if(btnType == configData.GRID_BTN_DOWN){
			//tmpHtml = "▼";
			$obj.click(function(event){
				gridBox.rowDown();
			});
			btnLabelKey = "BTN_ROWDOWN";
		}else if(btnType == configData.GRID_BTN_ADD){
			$obj.click(function(event){
				gridBox.addRow();
			});
			btnLabelKey = "BTN_ADDROW";
			
			gridBox.addType = true;
		}else if(btnType == configData.GRID_BTN_DELETE){
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
			gridBox.layoutType = true;
			$obj.click(function(event){
				layoutSave.setLauyout(gridBox);
			});
			btnLabelKey = "BTN_LAYOUT";
			
			gridBox.columnEditType = true;
		}else if(btnType == configData.GRID_BTN_FILTER){
			gridBox.layoutType = true;
			$obj.click(function(event){
				gridList.filterLayoutView(gridBox.id);
			});
			btnLabelKey = "BTN_FILTER";
		}else if(btnType == configData.GRID_BTN_TOTAL){
			$obj.click(function(event){
				gridBox.viewTotal();
			});
			btnLabelKey = "BTN_TOTAL";
			
			gridBox.totalType = true;
		}else if(btnType == configData.GRID_BTN_SUB_TOTAL){
			$obj.click(function(event){
				gridList.subTotalLayoutView(gridBox.id);
			});
			btnLabelKey = "BTN_SUB_TOTAL";
		}else if(btnType == configData.GRID_BTN_EXCEL){
			$obj.click(function(event){
				gridBox.gridExcelRequest();
			});
			btnLabelKey = "BTN_EXCELDN";
		}else if(btnType == configData.GRID_BTN_EXCEL_VIEW){
			$obj.click(function(event){
				gridBox.gridExcelRequest(false, true);
			});
			btnLabelKey = "BTN_EXCELDN";
		}else if(btnType == configData.GRID_BTN_EXCEL_UP){
			$obj.click(function(event){
				gridList.excelUpLayoutView(gridBox.id);
				/*
				if(gridList.excelUpGridId == gridBox.id){
					gridList.excelUploadTemplateDown();
				}else{
					var $tmpExcelUpForm = jQuery("#"+configData.DATA_EXCEL_UPLOAD_FORM_ID);
					if($tmpExcelUpForm.length == 0){
						var tmpFormHtml = "<form action='/common/grid/excel/fileUp/excel.data' enctype='multipart/form-data' method='post' id='"+configData.DATA_EXCEL_UPLOAD_FORM_ID+"'>"
								+ "<input type='file' name='gridExcelUp' validate='required excel'/>"
								+ "<input type='submit' value='upload'/>"
								+ "</form>";
						$tmpExcelUpForm = jQuery(tmpFormHtml);
						$obj.parent().before($tmpExcelUpForm);
						gridList.setGridExcelUpForm(configData.DATA_EXCEL_UPLOAD_FORM_ID);
					}else{
						$obj.parent().before($tmpExcelUpForm);
					}
					
					gridList.excelUpGridId = gridBox.id;
				}
				*/
			});
			btnLabelKey = "BTN_EXCELUP";
		}else if(btnType == configData.GRID_BTN_CHECK){
			$obj.click(function(event){
				if(gridBox.$checkHead){
					gridBox.changeCheckHead(true);
				}
			});
			btnLabelKey = "BTN_CHECKALL";
		}else if(btnType == configData.GRID_BTN_WRITE){
			$obj.click(function(event){
				//event fn
				if(commonUtil.checkFn("gridListEventBtnClick")){
					gridListEventBtnClick(gridBox.id, configData.GRID_BTN_WRITE);
				}
			});
			btnLabelKey = "BTN_WRITE";
		}else if(btnType == configData.GRID_BTN_COPY){
			$obj.click(function(event){
				gridBox.copyRow();
			});
			btnLabelKey = "BTN_COPY";
		}else if(btnType == configData.GRID_BTN_COLFIX){
			$obj.click(function(event){
				gridBox.colFix();
			});
			btnLabelKey = "BTN_COLFIX";
		}
		
		if(tmpHtml){
			$obj.append(tmpHtml);
		}
		if(btnLabelKey){
			var labelTxt = uiList.getLabel(btnLabelKey);
			$obj.attr("title", labelTxt);
		}else{
			$obj.attr("title", btnType);
		}
	},
	setGridPgecountInfo : function(gridBox) {
		var tmpHtml = "<div class='paging'>"
			+ "<a href='#'><img src='/common/theme/webdek/images/btn_first.png' /></a>"
			+ "	<a href='#'><img src='/common/theme/webdek/images/btn_prev.png' /></a>"
			+ "<span></span>"
			+ "	<a href='#'><img src='/common/theme/webdek/images/btn_next.png' /></a>"
			+ "<a href='#'><img src='/common/theme/webdek/images/btn_last.png' /></a>"
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
		var $searchBtn = jQuery('<button type="button" class="btn btn_search"></button>');
		return $searchBtn;
	},
	setInputSearch : function($obj){
		$obj.addClass(configData.INPUT_SEARCH_CLASS);
		var $pObj = $obj.parent();
		var $inputArea = $("<span class='input_box btn1'></span>");
		$inputArea.append($obj);
		$pObj.append($inputArea);
		
	},
	getInputSearchBtn : function(inputObj){
		var $searchBtn = jQuery("<button type='button' class='btn btn_search'><span>search</span></button>");
		//inputObj.$rangeBox.addClass("btn1");
		return $searchBtn;
	},
	getInputSearchText : function(inputObj){
		inputObj.$obj.css("width","100px");
		var $searchText = jQuery("<input type='text' name='"+inputObj.name+"_SNAME' class='input' readonly='readonly' style='width:130px' />");
		//inputObj.$rangeBox.addClass("btn1");
		return $searchText;
	},
	setInputRangeBox : function(inputObj, $obj){
		var $pObj = $obj.parent();
		var $rangeBox;
		if($pObj.hasClass("input_box")){			
			$rangeBox = $pObj;
		}else{
			$rangeBox = $("<span class='input_box btn1'></input>");
			$pObj.append($rangeBox);
		}
		$rangeBox.append($obj);
		
		return $rangeBox;
	},
	getInputRangeFrom : function(inputObj){
		var widthStyle = "";
		if(inputObj.options[0] == configData.INPUT_BETWEEN || inputObj.options[0] == configData.INPUT_RANGE){
			widthStyle = "style='width:80px'";
		}
		return jQuery("<input type='text' class='input "+theme.INPUT_SEARCH_CLASS+"' "+widthStyle+" />");
	},
	getInputRangeTo : function(inputObj){
		var widthStyle = "";
		if(inputObj.options[0] == configData.INPUT_BETWEEN || inputObj.options[0] == configData.INPUT_RANGE){
			widthStyle = "style='width:80px'";
		}
		return jQuery("<input type='text' class='input "+theme.INPUT_RANGE_CLASS+"' "+widthStyle+" />");
	},
	getInputRangeDash : function(inputObj){
		return "<span> ~ </span>";
	},
	getInputRangeBtn : function($rangeBox){
		var $rangeBtn = jQuery('<button type="button" class="btn btn_mult"></button>');
		$rangeBox.append($rangeBtn);
		return $rangeBtn;
	},
	getMultiValueBtn : function(inputObj, labelText){
		var $valueBtn = jQuery("<button class='"+configData.BUTTON_CLASS+"' type='button' style='margin-left:10px;'></button>");
		$valueBtn.append("<span class='"+configData.BUTTON_TEXT_CLASS+"'style='margin-left:10px;'>"+labelText+"</span>");
		return $valueBtn;
	},
	createMultiInput : function(inputObj) {
		if(inputObj.options[0] == configData.INPUT_RANGE || inputObj.options[0] == configData.INPUT_SHORT_RANGE){
			inputObj.$from = jQuery("<input type='text' class='"+theme.INPUT_RANGE_CLASS+"' />");
			inputObj.$to = jQuery("<input type='text' class='"+theme.INPUT_RANGE_CLASS+"' />");
			inputObj.$rangeBox.append(inputObj.$from);
			if(inputObj.options[1]){
				inputObj.$fbtn = jQuery("<button type='button' class='btn btn_search'><span>search</span></button>");
				inputObj.$rangeBox.append(inputObj.$fbtn);
				inputObj.$rangeBox.addClass("btn2");
			}else if(inputObj.formatList && inputObj.formatList[0] == configData.INPUT_FORMAT_CALENDER){
				inputObj.$rangeBox.addClass("btn2");
			}else{
				inputObj.$rangeBox.addClass("btn1");
			}
			inputObj.$rangeBox.append(inputObj.$to);
			inputObj.$rangeBtn = jQuery('<button type="button" class="btn btn_mult"><span>mult</span></button>');
			inputObj.$rangeBox.append(inputObj.$rangeBtn);
		}else if(inputObj.options[0] == configData.INPUT_BETWEEN){
			var tmpHtml = '<span class="fl_l" style="width:45%">'
				+ '<span class="input_box btn1">'
				+ '<input type="text" class="input bfrom" />'
				//+ '<button type="button" class="btn btn_search"><span>search</span></button>'
				+ '</span>'
				+ '</span>'
				+ '<span class="fl_l ta_c"style="width:10%;line-height:2">~</span>'
				+ '<span class="fl_l" style="width:45%">'
				+ '<span class="input_box btn1">'
				+ '<input type="text" class="input bto" />'
				//+ '<button type="button" class="btn btn_search"><span>search</span></button>'
				+ '</span>'
				+ '</span>';
			inputObj.$rangeBox = inputObj.$rangeBox.parent();
			inputObj.$rangeBox.html(tmpHtml);
			inputObj.$from = inputObj.$rangeBox.find(".bfrom");
			inputObj.$to = inputObj.$rangeBox.find(".bto");
			
			//inputObj.$from = jQuery("<input type='text' class='"+theme.INPUT_RANGE_CLASS+"' />");
			//inputObj.$to = jQuery("<input type='text' class='"+theme.INPUT_RANGE_CLASS+"' />");
			//inputObj.$rangeBox.append(this.$from);
			if(inputObj.options[1]){
				inputObj.$fbtn = this.getInputSearchBtn(inputObj);
				//inputObj.$rangeBox.append(inputObj.$fbtn);
				inputObj.$from.after(inputObj.$fbtn);
			}
			
			if(inputObj.formatList){
				if(inputObj.formatList[0] == configData.INPUT_FORMAT_CALENDER){
					inputObj.$rangeBox.css("min-width","215px");
				}
			}
			//inputObj.$rangeBox.append(inputObj.$to);
		}
	},
	setInputCalendarEffect : function($input){
		var $pObj = $input.parent();
		if(!$pObj.hasClass("input_box")){			
			var $pChilds = $pObj.children();
			var $inputArea = $("<span class='input_box btn1'></input>");
			$inputArea.append($pChilds);
			$pObj.append($inputArea);
		}		
		
		$input.next(".ui-datepicker-trigger").addClass("btn");
		$input.next(".ui-datepicker-trigger").addClass("btn_calender");
		$input.next(".ui-datepicker-trigger").text("");
		//$input.parent().addClass("btn1");
	},
	setGridCalendarEffect : function($input){
		$input.next(".ui-datepicker-trigger").addClass("btn");
		$input.next(".ui-datepicker-trigger").addClass("btn_calender");
		$input.next(".ui-datepicker-trigger").text("");
		/*
		$input.next(".ui-datepicker-trigger").css({
			"width":"26px"
			});*/
	},
	getGridDeleteBtn : function(gridBox){
		var $btnObj = jQuery("<button class='button type3' type='button' onclick='gridList.deleteBtnClick(\""+gridBox.id+"\",this)'><img src='/common/theme/webdek/images/grid_icon_10.png' /></button>");
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
			colHtml += "<col width='"+attList[0]+"px'/>";
			lblTxt = "";
			ghbtn = "";
			if(attList.length == 1){
				attList = $gh.attr(configData.GRID_COL).split(",");
				if(attList[0] == configData.GRID_COL_TYPE_ROWNUM){
					lblTxt = uiList.getLabel("STD_NUMBER");
				}else if(attList[0] == configData.GRID_COL_TYPE_ROWCHECK){
					ghbtn = " GBtnCheck='true'";
				}else if(attList[0] == configData.GRID_COL_TYPE_CHECKBOX){
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
		
		var tmpHtml = "<div class='table_thead "+configData.GRID_HEAD_CLASS+"'>" 
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
			tmpHtml = "<div class='btn_lit tableUtil'>"
					+ "<button type='button' class='btn btn_add' GBtn='add'><span></span></button>"
					+ "<button type='button' class='btn btn_del' GBtn='delete'><span>삭제</span></button>"
					+ "<button type='button' class='btn btn_sum' GBtn='total'><span></span></button>"
					+ "<button type='button' class='btn btn_reset' GBtn='sortReset'><span></span></button>"
					+ "<button type='button' class='btn btn_excel_d' GBtn='excel'><span></span></button>"
					+ "<button type='button' class='btn btn_excel_u' GBtn='excelUpload'><span></span></button>"
					+ "<button type='button' class='btn btn_excel_e' GBtn='excelView'><span></span></button>"
					+ "<button type='button' class='btn btn_column_edit' GBtn='layout'><span></span></button>"
					+ "<button type='button' class='btn btn_upload' GBtn='find'><span></span></button>"
					+ "<span class='txt_total' GInfoArea='true'>전체 999,999</span>"
					+ "<button type='button' class='btn btn_extend'><span></span></button>"
					+ "</div>";
			gridBox.$gridLayout.prepend(tmpHtml);
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
		var agent = navigator.userAgent.toLowerCase();
		var $tmpDiv ;
		if ( (navigator.appName == 'Netscape' && navigator.userAgent.search('Trident') != -1) || (agent.indexOf("msie") != -1) ) {
			$tmpDiv = jQuery("<div style='position:absolute; margin-top:-13px;'></div>");
		}else {
			$tmpDiv = jQuery("<div style='position:absolute; margin-top:1px;'></div>");
		}
		$obj.parent().css("height","28px").append($tmpDiv);
		var $tmpInputObj;
		if(comboInput && !isNaN(comboInput)){
			$tmpInputObj = jQuery("<input type='text' style='vertical-align: top; width: "+comboInput+"px; height: 21px; margin-right: 3px'/>");
			$tmpDiv.append($tmpInputObj);
		}
		$tmpDiv.append($obj);
		return $tmpInputObj;
	},
	setMultipleCombo : function($obj, comboInput){
		var agent = navigator.userAgent.toLowerCase();
		var $tmpDiv ;
		if ( (navigator.appName == 'Netscape' && navigator.userAgent.search('Trident') != -1) || (agent.indexOf("msie") != -1) ) {
			$tmpDiv = jQuery("<div style='position:absolute; margin-top:-13px;'></div>");
		}else {
			$tmpDiv = jQuery("<div style='position:absolute; margin-top:1px;'></div>");
		}
		
		$obj.parent().css("height","28px").append($tmpDiv);
		var $tmpInputObj;
		if(comboInput && !isNaN(comboInput)){
			$tmpInputObj = jQuery("<input type='text' style='vertical-align: top; width: "+comboInput+"px; height: 21px; margin-right: 3px'/>");
			$tmpDiv.append($tmpInputObj);
		}		
		$obj.attr("multiple","multiple");
		$tmpDiv.append($obj);		
		return $tmpInputObj;
	},
	setComboLayout : function($obj){
		var $msDrop = $obj.parent().find(".ms-drop");
		var tmpName = $obj.attr("name");
		$msDrop.attr("ms-drop", tmpName);
		//$msDrop.css("width","200px");
		var $msChoice = $obj.parent().find(".ms-choice");
		$msChoice.attr("ms-choice", tmpName);
		
		var topWidth = $obj.parent().find(".ms-parent").width();
		$msDrop.css("width", topWidth);
		
		$msChoice.find("div").click(function(event){
			//alert(event);
			var msChoiceSpanWidth = $(this).prev().width() + 8;
			
			var tmpTop = event.pageY - event.offsetY-45;
			var tmpLeft = event.pageX - event.offsetX - msChoiceSpanWidth;
			//var tmpTop =  event.screenY - window.pageYOffset - event.offsetY-45;
			//var tmpLeft = event.screenX - window.pageXOffset - event.offsetX-108;
			$msDrop.css("top",(tmpTop)+"px");
			$msDrop.css("left",(tmpLeft)+"px");
		});
		$msChoice.find("span").click(function(event){
			//alert(event);
			var tmpTop = event.pageY - event.offsetY-45;
			var tmpLeft = event.pageX - event.offsetX;
			//var tmpTop =  event.screenY - window.pageYOffset - event.offsetY-45;
			//var tmpLeft = event.screenX - window.pageXOffset - event.offsetX;
			$msDrop.css("top",(tmpTop)+"px");
			$msDrop.css("left",(tmpLeft)+"px");
		});
		$("body").append($msDrop);
	},
	multiComboEvent : function(event){
		//alert(event);
		/*if(Browser.chrome){
			return;
		}
		var tmpTop = event.pageY - event.offsetY-45;
		var tmpLeft = event.pageX - event.offsetX;
		var $obj = $(event.target);
		var tmpName = $obj.attr("ms-choice");
		var $msDrop = $("body").find("[ms-drop='"+tmpName+"']");
		$msDrop.css("top",(tmpTop)+"px");
		$msDrop.css("left",(tmpLeft)+"px");*/
		
		var $obj = $(event.target);
		var $msParent = $obj.offsetParent();
		var $msChoice = $msParent.find(".ms-choice");
		var position = $msChoice.find("span").offset();
		
		var tmpName = $msChoice.attr("ms-choice");
		var $msDrop = $("body").find("[ms-drop='"+tmpName+"']");
		
		$msDrop.css("position","absolute");
		$msDrop.css("top",(position.top + $msChoice.height())+"px");
		$msDrop.css("left",(position.left)+"px");

	},
	gridHeadColObj : function($thObj, colName, colText){
		return jQuery("<span><span title=\""+$thObj.attr(configData.GRID_COL_VALUE)+"\" "+configData.GRID_COL_NAME+"='"+colName+"'>"+colText+"</span><span class='link_line' "+configData.GRID_COL_NAME+"='"+colName+"'></span></span>");
		//return jQuery("<table class='thInTable' style='width:100%;' title=\""+$thObj.attr(configData.GRID_COL_VALUE)+"\"><tr><td style='width:10px;'></td><td "+configData.GRID_COL_NAME+"='"+colName+"' >"+colText+"</td><td style='width:3px;' class='"+theme.GRID_LAYOUT_HEAD_COL_RIGHT_CLASS+"'></td></tr></table>");
	},
	gridHeadColText : function($gridHeadObj){
		$gridHeadObj.find("span["+configData.GRID_COL_NAME+"="+colName+"]").text(colText);
	},
	gridHeadColWidth : function(thWidth, uiLeft){
		return uiLeft;
	},
	setGridScrollMarginBottom : function($tableBox, marginBottom){
		$tableBox.css("margin-bottom", marginBottom);
	},
	setGridScrollMarginTop : function($tableBox, marginTop){
		$tableBox.css("margin-top", marginTop);
	},
	viewTotal : function(gridObj, viewType){
		if(viewType){
			var bodyHeight = commonUtil.getCssNum(gridObj.$gridBody, "height");
			bodyHeight -= gridObj.rowHeight;
			gridObj.$gridBody.css("height", bodyHeight+"px");
		}else{
			var bodyHeight = commonUtil.getCssNum(gridObj.$gridBody, "height");
			bodyHeight += gridObj.rowHeight;
			gridObj.$gridBody.css("height", bodyHeight+"px");
		}
	},
	setInputBtn : function($btnObj, iconClass, labelTxt){
		$btnObj.val(labelTxt);
		$btnObj.addClass("btn_basic");
		$btnObj.addClass(iconClass);
	},
	getInputBtnObj : function($obj){
		return $obj;
	},
	getGridBtnObj : function(gridId, iconClass, labelTxt, valTxt){
		var btnHtml = "<input type='button' class='btn_basic "+iconClass+" "+configData.GRID_COL_TYPE_BTN_CLASS+valTxt+"' "
			+ " onclick='gridList.btnClick(\""+gridId+"\",this)' value='"+labelTxt+"' />";
		var $btnObj = jQuery(btnHtml);

		return $btnObj;
	},
	getValidataInputText : function($obj){
		return $obj.parent().parent().prev().text();
	},
	toString : function() {
		return "Theme";
	}
};

var theme = new Theme();